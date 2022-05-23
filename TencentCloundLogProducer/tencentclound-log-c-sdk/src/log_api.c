#include "log_util.h"
#include "log_api.h"
#include <string.h>
#include "sds.h"
#include <curl.h>

int LOG_OS_HttpPost(const char *url,
                    char **header_array,
                    int header_count,
                    const void *data,
                    int data_len);

unsigned int LOG_GET_TIME();

log_status_t cls_log_init(int32_t log_global_flag)
{
    CURLcode ecode;
    if ((ecode = curl_global_init(log_global_flag)) != CURLE_OK)
    {
        return -1;
    }
    return 0;
}
void cls_log_destroy()
{
    curl_global_cleanup();
}

static size_t write_data(void *ptr, size_t size, size_t nmemb, void *stream)
{
    size_t totalLen = size * nmemb;
    sds *buffer = (sds *)stream;
    if (*buffer == NULL)
    {
        *buffer = sdsnewEmpty(256);
    }
    *buffer = sdscpylen(*buffer, ptr, totalLen);
    return totalLen;
}

static size_t header_callback(void *ptr, size_t size, size_t nmemb, void *stream)
{
    size_t totalLen = size * nmemb;
    sds *buffer = (sds *)stream;
    // only copy header start with x-log-
    if (totalLen > 6 && ((memcmp(ptr, "X-Cls-", 6) == 0) ||(memcmp(ptr, "x-cls-", 6) == 0)))
    {
        *buffer = sdscpylen(*buffer, ptr, totalLen);
    }
    return totalLen;
}

static const char cls_month_snames[12][4] =
    {
        "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
static const char cls_day_snames[7][4] =
    {
        "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};

void cls_rfc822_date(char *date_str, struct tm *xt)
{
    const char *s = NULL;
    int real_year = 2000;

    /* example: "Sat, 08 Jan 2000 18:31:41 GMT" */
    /*           12345678901234567890123456789  */

    s = &cls_day_snames[xt->tm_wday][0];
    *date_str++ = *s++;
    *date_str++ = *s++;
    *date_str++ = *s++;
    *date_str++ = ',';
    *date_str++ = ' ';
    *date_str++ = xt->tm_mday / 10 + '0';
    *date_str++ = xt->tm_mday % 10 + '0';
    *date_str++ = ' ';
    s = &cls_month_snames[xt->tm_mon][0];
    *date_str++ = *s++;
    *date_str++ = *s++;
    *date_str++ = *s++;
    *date_str++ = ' ';
    real_year = 1900 + xt->tm_year;
    /* This routine isn't y10k ready. */
    *date_str++ = real_year / 1000 + '0';
    *date_str++ = real_year % 1000 / 100 + '0';
    *date_str++ = real_year % 100 / 10 + '0';
    *date_str++ = real_year % 10 + '0';
    *date_str++ = ' ';
    *date_str++ = xt->tm_hour / 10 + '0';
    *date_str++ = xt->tm_hour % 10 + '0';
    *date_str++ = ':';
    *date_str++ = xt->tm_min / 10 + '0';
    *date_str++ = xt->tm_min % 10 + '0';
    *date_str++ = ':';
    *date_str++ = xt->tm_sec / 10 + '0';
    *date_str++ = xt->tm_sec % 10 + '0';
    *date_str++ = ' ';
    *date_str++ = 'G';
    *date_str++ = 'M';
    *date_str++ = 'T';
    *date_str++ = 0;
    return;
}

void get_now_time_str(char *buffer, int bufLen, int timeOffset)
{
    time_t rawtime = LOG_GET_TIME();
    struct tm *timeinfo;
    if (timeOffset != 0)
    {
        rawtime += timeOffset;
    }
    timeinfo = gmtime(&rawtime);
    cls_rfc822_date(buffer, timeinfo);
}

void post_log_result_destroy(post_log_result *result)
{
    
    if (result != NULL)
    {
        if (result->errorMessage != NULL)
        {
            sdsfree(result->errorMessage);
        }
        if (result->requestID != NULL)
        {
            sdsfree(result->requestID);
        }
        free(result);
    }
}


struct cur_slist
{
    char *data;
    struct cur_slist *next;
};

struct cur_slist *cur_slist_append(struct cur_slist *lst, const char *s)
{
    struct cur_slist *t = (struct cur_slist *)malloc(sizeof(struct cur_slist));
    t->data = strdup(s);
    t->next = NULL;

    if (lst == NULL)
        return t;

    struct cur_slist *orig = lst;

    while (lst->next)
    {
        lst = lst->next;
    }

    lst->next = t;

    return orig;
}

void cur_slist_free_all(struct cur_slist *lst)
{
    while (lst != NULL)
    {
        struct cur_slist *n = lst->next;
        free(lst->data);
        free(lst);
        lst = n;
    }
}

static int is_str_empty(const char *str)
{
    if (!str)
    {
        return 1;
    }

    if (strcmp(str, "") == 0)
    {
        return 1;
    }

    return 0;
}

void GetQueryString(const root_t parameterList,
                    sds queryString)
{
    memset(queryString, 0, strlen(queryString));
    map_t *node;
    for (node = map_first(&parameterList); node; node = map_next(&(node->node)))
    {
        if (node != map_first(&parameterList))
        {
            queryString = sdscat(queryString, "&");
        }
        queryString = sdscat(queryString, node->key);
        queryString = sdscat(queryString, "=");
        unsigned char c_url[strlen(node->val)*3+1];
        memset(c_url,0,strlen(node->val)*3+1);
        urlencode(node->val,c_url);
        queryString = sdscat(queryString, c_url);
    }
}


post_log_result *post_logs_from_lz4buf(const char *endpoint, const char *accesskeyId, const char *accessKey, const char *topic,lz4_log_buf *buffer, log_post_option *option)
{
    const char *operation = "/structuredlog";
    root_t httpHeader = RB_ROOT;
    if (option == NULL || option->compress_type == 1)
    {
        put(&httpHeader, "x-cls-compress-type", "lz4");
    }
    put(&httpHeader, "Host", (char *)endpoint);
    put(&httpHeader, "Content-Type", "application/x-protobuf");
    put(&httpHeader, "User-Agent", "tencent-log-sdk-ios v0.0.1");

    root_t params = RB_ROOT;
    put(&params, "topic_id", topic);

    //计算签名
    char c_signature[1024];
    signature(accesskeyId, accessKey, "POST", operation, params, httpHeader, 300, c_signature);
    put(&httpHeader, "Authorization", c_signature);

    sds queryString = sdsnewEmpty(1024);
    GetQueryString(params, queryString);

    struct curl_slist *headers = NULL;
    map_t *node;
    for (node = map_first(&httpHeader); node; node = map_next(&(node->node)))
    {
        char p[1024];
        memset(p, 0, 1024);
        strcat(p, node->key);
        strcat(p, ":");
        strcat(p, node->val);
        headers = curl_slist_append(headers, p);
    }

    sds queryUrl = sdsnewEmpty(64);
    queryUrl = sdscat(queryUrl, endpoint);
    queryUrl = sdscat(queryUrl, operation);
    if (strlen(queryString) != 0)
    {
        queryUrl = sdscat(queryUrl, "?");
        queryUrl = sdscat(queryUrl, queryString);
    }
    CURL *curl = curl_easy_init();
    post_log_result *result = (post_log_result *)malloc(sizeof(post_log_result));
    memset(result, 0, sizeof(post_log_result));
    if (curl != NULL)
    {

        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        curl_easy_setopt(curl, CURLOPT_URL, queryUrl);
        curl_easy_setopt(curl, CURLOPT_POST, 1);

        sds body = NULL;
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &body);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, write_data);
        curl_easy_setopt(curl, CURLOPT_HEADERFUNCTION, header_callback);
        curl_easy_setopt(curl, CURLOPT_TIMEOUT, 15);

        if (option != NULL)
        {
            if (option->operation_timeout > 0)
            {
                curl_easy_setopt(curl, CURLOPT_TIMEOUT, option->operation_timeout);
            }
            if (option->connect_timeout > 0)
            {
                curl_easy_setopt(curl, CURLOPT_CONNECTTIMEOUT, option->connect_timeout);
            }
        }
        curl_easy_setopt(curl, CURLOPT_NOSIGNAL, 1);
        curl_easy_setopt(curl, CURLOPT_POSTFIELDS, (void *)buffer->data);
        curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, buffer->length);
        curl_easy_setopt(curl, CURLOPT_FILETIME, 1);
        curl_easy_setopt(curl, CURLOPT_VERBOSE, 1); //打印调试信息
        sds header = sdsnewEmpty(64);
        curl_easy_setopt(curl, CURLOPT_HEADERDATA, &header);
        CURLcode res = curl_easy_perform(curl);
        long http_code;
        if (res == CURLE_OK)
        {
            if ((res = curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &http_code)) != CURLE_OK)
            {
                result->statusCode = -2;
            }
            else
            {
                result->statusCode = http_code;
            }
        }
        else
        {
            if (body == NULL)
            {
                body = sdsnew(curl_easy_strerror(res));
            }
            else
            {
                body = sdscpy(body, curl_easy_strerror(res));
            }
            result->statusCode = -1 * (int)res;
        }
        // header and body 's pointer may be modified in callback (size > 256)

        if (sdslen(header) > 0)
        {
            result->requestID = header;
        }
        else
        {
            sdsfree(header);
            header = NULL;
        }

        // body will be NULL or a error string(net error or request error)
        result->errorMessage = body;

        curl_slist_free_all(headers); /* free the list again */
        sdsfree(queryString);
        sdsfree(body);
        sdsfree(queryUrl);
        curl_easy_cleanup(curl);

        //释放map_t headers
        map_t *nodeFree = NULL;
        for (nodeFree = map_first(&httpHeader); nodeFree; nodeFree = map_first(&httpHeader))
        {
            if (nodeFree)
            {
                rb_erase(&nodeFree->node, &httpHeader);
                map_free(nodeFree);
            }
        }

        //释放map_t headers
        for (nodeFree = map_first(&params); nodeFree; nodeFree = map_first(&params))
        {
            if (nodeFree)
            {
                rb_erase(&nodeFree->node, &params);
                map_free(nodeFree);
            }
        }
    }

    return result;
}
