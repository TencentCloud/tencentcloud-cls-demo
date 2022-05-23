#ifndef LIBLOG_API_H
#define LIBLOG_API_H

#include "log_builder.h"
#include "log_define.h"
#include "sds.h"
#include "signature.h"
LOG_CPP_START

#ifdef WIN32
#undef interface
#endif // WIN32

struct _log_post_option {
  char *interface;       // net interface to send log, NULL as default
  int connect_timeout;   // connection timeout seconds, 0 as default
  int operation_timeout; // operation timeout seconds, 0 as default
  int compress_type;     // 0 no compress, 1 lz4
  int using_https;       // 0 http, 1 https
};
typedef struct _log_post_option log_post_option;

log_status_t cls_log_init(int32_t log_global_flag);
void cls_log_destroy();

post_log_result *post_logs_from_lz4buf(const char *endpoint,
                                       const char *accesskeyId,
                                       const char *accessKey, const char *topic,
                                       lz4_log_buf *buffer,
                                       log_post_option *option);

void post_log_result_destroy(post_log_result *result);
void GetQueryString(const root_t parameterList, sds queryString);
LOG_CPP_END
#endif
