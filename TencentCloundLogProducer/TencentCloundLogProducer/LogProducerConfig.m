

#ifdef DEBUG
#define CLSLog(...) NSLog(__VA_ARGS__)
#else
#define CLSLog(...)
#endif

#import <Foundation/Foundation.h>
#import "LogProducerConfig.h"
#import "inner_log.h"
#import "TimeUtils.h"
#import "HttpConfigProxy.h"


@interface LogProducerConfig ()

@end

@implementation LogProducerConfig

- (id) initWithEndpoint:(NSString *) endpoint accessKeyID:(NSString *)accessKeyID accessKeySecret:(NSString *)accessKeySecret
{
    if (self = [super init])
    {
        self->config = create_log_producer_config();
        log_producer_config_set_packet_timeout(self->config, 3000);
        log_producer_config_set_packet_log_count(self->config, 1024);
        log_producer_config_set_packet_log_bytes(self->config, 1024*1024);
        log_producer_config_set_send_thread_count(self->config, 1);
        log_set_get_time_unix_func(time_func);

        [self setEndpoint:endpoint];
        [self setAccessKeyId:accessKeyID];
        [self setAccessKeySecret:accessKeySecret];
    }

    return self;
}

unsigned int time_func() {
    NSInteger timeInMillis = [TimeUtils getTimeInMilliis];
    return timeInMillis;
}

- (void)setEndpoint:(NSString *)endpoint
{
    self->endpoint = endpoint;
    log_producer_config_set_endpoint(self->config, [endpoint UTF8String]);
}

- (NSString *)getEndpoint
{
    return self->endpoint;
}

- (void)SetTopic:(NSString *) topic
{
    const char *topicChar=[topic UTF8String];
    log_producer_config_set_topic(self->config, topicChar);
}

- (void)SetPacketLogBytes:(int) num
{
    log_producer_config_set_packet_log_bytes(self->config, num);
}

- (void)SetPacketLogCount:(int) num
{
    log_producer_config_set_packet_log_count(self->config, num);
}

- (void)SetPacketTimeout:(int) num
{
    log_producer_config_set_packet_timeout(self->config, num);
}

- (void)SetMaxBufferLimit:(int) num
{
    log_producer_config_set_max_buffer_limit(self->config, num);
}

- (void)SetSendThreadCount:(int) num
{
    log_producer_config_set_send_thread_count(self->config, num);
}

- (void)SetConnectTimeoutSec:(int) num;
{
    log_producer_config_set_connect_timeout_sec(self->config, num);
}

- (void)SetSendTimeoutSec:(int) num;
{
    log_producer_config_set_send_timeout_sec(self->config, num);
}

- (void)SetDestroyFlusherWaitSec:(int) num;
{
    log_producer_config_set_destroy_flusher_wait_sec(self->config, num);
}

- (void)SetDestroySenderWaitSec:(int) num;
{
    log_producer_config_set_destroy_sender_wait_sec(self->config, num);
}

- (void)SetCompressType:(int) num;
{
    log_producer_config_set_compress_type(self->config, num);
}

- (int)IsValid;
{
    return log_producer_config_is_valid(self->config);
}

- (void)setAccessKeyId:(NSString *)accessKeyId
{
    log_producer_config_set_access_id(self->config, [accessKeyId UTF8String]);
}

- (void)setAccessKeySecret:(NSString *)accessKeySecret
{
    log_producer_config_set_access_key(self->config, [accessKeySecret UTF8String]);
}

+ (void)Debug
{
    aos_log_set_level(AOS_LOG_DEBUG);
}


@end
