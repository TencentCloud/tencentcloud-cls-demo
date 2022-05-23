

#import <Foundation/Foundation.h>
#import "LogProducerClient.h"
#import "LogProducerConfig.h"
#import "Log.h"
#import "TimeUtils.h"



@interface LogProducerClient ()

@end

@implementation LogProducerClient

- (id) initWithLogProducerConfig:(LogProducerConfig *)logProducerConfig
{
    return [self initWithLogProducerConfig:logProducerConfig callback:nil];
}

- (id) initWithLogProducerConfig:(LogProducerConfig *)logProducerConfig callback:(on_log_producer_send_done_function)callback
{
    if (self = [super init])
    {
        log_producer_env_init(LOG_GLOBAL_ALL);
        self->producer = create_log_producer(logProducerConfig->config, *callback, nil);
        self->client = get_log_producer_client(self->producer, nil);
        enable = YES;
    }

    return self;
}

- (void)DestroyLogProducer
{
    if (!enable) {
        return;
    }
    enable = NO;
    destroy_log_producer(self->producer);
    log_producer_env_destroy();
}

- (LogProducerResult)AddLog:(Log *) log
{
    return [self AddLog:log flush:0];
}

- (LogProducerResult)AddLog:(Log *) log flush:(int) flush
{
    if (!enable || self->client == NULL || log == nil) {
        return LogProducerInvalid;
    }
    NSMutableDictionary *logContents = log->content;
    
    int pairCount = (int)[logContents count];
        
    char **keyArray = (char **)malloc(sizeof(char *)*(pairCount));
    char **valueArray = (char **)malloc(sizeof(char *)*(pairCount));
    
    int32_t *keyCountArray = (int32_t*)malloc(sizeof(int32_t)*(pairCount));
    int32_t *valueCountArray = (int32_t*)malloc(sizeof(int32_t)*(pairCount));
    
    
    int ids = 0;
    for (NSString *key in logContents) {
        NSString *value = logContents[key];

        char* keyChar=[self convertToChar:key];
        char* valueChar=[self convertToChar:value];

        keyArray[ids] = keyChar;  //记录contents 所有的key
        valueArray[ids] = valueChar; ////记录contents 所有的value
        keyCountArray[ids] = (int32_t)strlen(keyChar); //记录contents 所有的key的大小
        valueCountArray[ids] = (int32_t)strlen(valueChar); //记录contents 所有的value的大小
        
        ids = ids + 1;
    }
    log_producer_result res = log_producer_client_add_log_with_len_time_int32(self->client, log->logTime, pairCount, keyArray, keyCountArray, valueArray, valueCountArray, flush);
    
    for(int i=0;i<pairCount;i++) {
        free(keyArray[i]);
        free(valueArray[i]);
    }
    free(keyArray);
    free(valueArray);
    free(keyCountArray);
    free(valueCountArray);
    return res;
}

-(char*)convertToChar:(NSString*)strtemp
{
    NSUInteger len = [strtemp lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1;
    if (len > 1000000) return strdup([strtemp UTF8String]);
    char cStr [len];
    [strtemp getCString:cStr maxLength:len encoding:NSUTF8StringEncoding];
    return strdup(cStr);
}

@end

