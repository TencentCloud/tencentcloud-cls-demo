#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "Log.h"
#import "LogProducerClient.h"
#import "LogProducerConfig.h"
#import "TencentCloundLogProducer.h"
#import "HttpConfigProxy.h"
#import "TimeUtils.h"
#import "log_define.h"
#import "log_http_interface.h"
#import "log_inner_include.h"
#import "log_multi_thread.h"
#import "log_producer_client.h"
#import "log_producer_common.h"
#import "log_producer_config.h"

FOUNDATION_EXPORT double TencentCloundLogProducerVersionNumber;
FOUNDATION_EXPORT const unsigned char TencentCloundLogProducerVersionString[];
