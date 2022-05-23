

#ifndef LogProducerConfig_h
#define LogProducerConfig_h


#endif /* LogProducerConfig_h */

#import "log_producer_config.h"
#import "log_http_interface.h"


@interface LogProducerConfig : NSObject
{
    @package log_producer_config* config;
    @private NSString *endpoint;
    @private NSString *project;
    @private NSString *logstore;
}

- (id) initWithEndpoint:(NSString *) endpoint accessKeyID:(NSString *)accessKeyID accessKeySecret:(NSString *)accessKeySecret;

- (void)SetTopic:(NSString *) topic;

- (void)SetPacketLogBytes:(int) num;

- (void)SetPacketLogCount:(int) num;

- (void)SetPacketTimeout:(int) num;

- (void)SetMaxBufferLimit:(int) num;

- (void)SetSendThreadCount:(int) num;

- (void)SetConnectTimeoutSec:(int) num;

- (void)SetSendTimeoutSec:(int) num;

- (void)SetDestroyFlusherWaitSec:(int) num;

- (void)SetDestroySenderWaitSec:(int) num;

- (void)SetCompressType:(int) num;

- (int)IsValid;

- (int)IsEnabled;

- (void) setEndpoint: (NSString *)endpoint;

- (NSString *)getEndpoint;

- (void) setAccessKeyId: (NSString *)accessKeyId;

- (void) setAccessKeySecret: (NSString *) accessKeySecret;

+ (void) Debug;

@end
