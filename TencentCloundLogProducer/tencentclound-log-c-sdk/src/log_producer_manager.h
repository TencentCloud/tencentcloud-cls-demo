//
// Created by herrylv on 06/5/2022
//

#ifndef LOG_C_SDK_LOG_PRODUCER_MANAGER_H
#define LOG_C_SDK_LOG_PRODUCER_MANAGER_H

#include "log_define.h"
LOG_CPP_START

#include "log_builder.h"
#include "log_multi_thread.h"
#include "log_producer_config.h"
#include "log_producer_sender.h"
#include "log_queue.h"

typedef struct _log_producer_manager {
  log_producer_config *producer_config;
  volatile uint32_t shutdown;
  volatile uint32_t networkRecover;
  volatile uint32_t totalBufferSize;
  log_queue *loggroup_queue;
  log_queue *sender_data_queue;
  THREAD *send_threads;
  THREAD flush_thread;
  CRITICALSECTION lock;
  COND triger_cond;
  log_group_builder *builder;
  int32_t firstLogTime;
  char *source;
  char *pack_prefix;
  volatile uint32_t pack_index;
  on_log_producer_send_done_function send_done_function;
  void *user_param;
  log_producer_send_param **send_param_queue;
  uint64_t send_param_queue_size;
  volatile uint64_t send_param_queue_read;
  volatile uint64_t send_param_queue_write;
  ATOMICINT multi_thread_send_count;

  // used for disk saver
  on_log_producer_send_done_uuid_function uuid_send_done_function;
  void *uuid_user_param;

} log_producer_manager;

extern log_producer_manager *
create_log_producer_manager(log_producer_config *producer_config);
extern void destroy_log_producer_manager(log_producer_manager *manager);

extern log_producer_result
log_producer_manager_add_log_int32(log_producer_manager *producer_manager,
                                   int32_t pair_count, char **keys,
                                   int32_t *key_lens, char **values,
                                   int32_t *val_lens, int flush, int64_t uuid);

LOG_CPP_END

#endif // LOG_C_SDK_LOG_PRODUCER_MANAGER_H
