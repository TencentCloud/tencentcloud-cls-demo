//
// Created by herrylv on 06/5/2022
//

#include "log_producer_client.h"
#include "log_producer_manager.h"
#include "inner_log.h"
#include "log_api.h"
#include <stdarg.h>
#include <string.h>

static uint32_t s_init_flag = 0;
static log_producer_result s_last_result = 0;

unsigned int LOG_GET_TIME();

typedef struct _producer_client_private
{

    log_producer_manager *producer_manager;
    log_producer_config *producer_config;

} producer_client_private;

struct _log_producer
{
    log_producer_client *root_client;
};

log_producer_result log_producer_env_init()
{
    // if already init, just return s_last_result
    if (s_init_flag == 1)
    {
        return s_last_result;
    }
    s_init_flag = 1;
    if (0 != cls_log_init(LOG_GLOBAL_ALL))
    {
        s_last_result = LOG_PRODUCER_INVALID;
    }
    else
    {
        s_last_result = LOG_PRODUCER_OK;
    }
    return s_last_result;
}

void log_producer_env_destroy()
{
    if (s_init_flag == 0)
    {
        return;
    }
    s_init_flag = 0;
    cls_log_destroy();
}

log_producer *create_log_producer(log_producer_config *config, on_log_producer_send_done_function send_done_function, void *user_param)
{
    if (!log_producer_config_is_valid(config))
    {
        return NULL;
    }
    log_producer *producer = (log_producer *)malloc(sizeof(log_producer));
    log_producer_client *producer_client = (log_producer_client *)malloc(sizeof(log_producer_client));
    producer_client_private *client_private = (producer_client_private *)malloc(sizeof(producer_client_private));
    producer_client->private_data = client_private;
    client_private->producer_config = config;
    client_private->producer_manager = create_log_producer_manager(config);
    client_private->producer_manager->send_done_function = send_done_function;
    client_private->producer_manager->user_param = user_param;

    aos_debug_log("create producer client success, config : %s", config->logstore);
    producer_client->valid_flag = 1;
    producer->root_client = producer_client;
    return producer;
}

void destroy_log_producer(log_producer *producer)
{
    if (producer == NULL)
    {
        return;
    }
    log_producer_client *client = producer->root_client;
    client->valid_flag = 0;
    producer_client_private *client_private = (producer_client_private *)client->private_data;
    destroy_log_producer_manager(client_private->producer_manager);
    destroy_log_producer_config(client_private->producer_config);
    free(client_private);
    free(client);
    free(producer);
}

extern log_producer_client *get_log_producer_client(log_producer *producer, const char *config_name)
{
    if (producer == NULL)
    {
        return NULL;
    }
    return producer->root_client;
}

log_producer_result
log_producer_client_add_log_with_len_time_int32(log_producer_client *client,
                                                uint32_t time_sec,
                                                int32_t pair_count, char **keys,
                                                int32_t *key_lens, char **values,
                                                int32_t *value_lens, int flush)
{
    if (client == NULL || !client->valid_flag)
    {
        return LOG_PRODUCER_INVALID;
    }

    log_producer_manager *manager = ((producer_client_private *)client->private_data)->producer_manager;
    return log_producer_manager_add_log_int32(manager, pair_count, keys, key_lens, values, value_lens, flush, -1);
}
