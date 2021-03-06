//
//  CLSTcpPing.m
//  TencentCloudLogProducer
//
//  Created by herrylv on 2022/6/7.
//

#import <arpa/inet.h>
#import <netdb.h>
#import <netinet/in.h>
#import <sys/socket.h>
#import <unistd.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#import "CLSTcpPing.h"

#import <TencentCloudLogProducer.h>

@interface CLSTcpPingResult ()

- (instancetype)init:(NSInteger)code
                  ip:(NSString *)ip
                 max:(NSTimeInterval)maxTime
                 min:(NSTimeInterval)minTime
                 avg:(NSTimeInterval)avgTime
                loss:(NSInteger)loss
               count:(NSInteger)count
           totalTime:(NSTimeInterval)totalTime
              stddev:(NSTimeInterval)stddev;
@end

@implementation CLSTcpPingResult

- (NSString *)description {
    if (_code == 0 || _code == kCLSRequestStoped) {
        return [NSString stringWithFormat:@"tcp connect success min/avg/max = %.3f/%.3f/%.3fms", _minTime, _avgTime, _maxTime];
    }
    return [NSString stringWithFormat:@"tcp connect failed"];
}

- (instancetype)init:(NSInteger)code
                  ip:(NSString *)ip
                 max:(NSTimeInterval)maxTime
                 min:(NSTimeInterval)minTime
                 avg:(NSTimeInterval)avgTime
                loss:(NSInteger)loss
               count:(NSInteger)count
           totalTime:(NSTimeInterval)totalTime
              stddev:(NSTimeInterval)stddev {
    if (self = [super init]) {
        _code = code;
        _ip = ip;
        _minTime = minTime;
        _avgTime = avgTime;
        _maxTime = maxTime;
        _loss = loss;
        _count = count;
        _totalTime = totalTime;
        _stddev = stddev;
    }
    return self;
}

@end

@interface CLSTcpPing ()

@property (readonly) NSString *host;
@property (readonly) NSUInteger port;
@property (readonly) id<CLSOutputDelegate> output;
@property (readonly) CLSTcpPingCompleteHandler complete;
@property(nonatomic, strong) baseSender *sender;
@property (readonly) NSInteger interval;
@property (readonly) NSInteger count;
@property (atomic) BOOL stopped;
@end

@implementation CLSTcpPing

- (instancetype)init:(NSString *)host
                port:(NSInteger)port
              output:(id<CLSOutputDelegate>)output
            complete:(CLSTcpPingCompleteHandler)complete
               count:(NSInteger)count
              sender: (baseSender *)sender{
    if (self = [super init]) {
        _host = host == nil ? @"" : host;
        _port = port;
        _output = output;
        _complete = complete;
        _count = count;
        _stopped = NO;
        _sender = sender;
    }
    return self;
}

- (void)run {
    NSDate *begin = [NSDate date];
    [self.output write:[NSString stringWithFormat:@"connect to host %@:%lu ...\n", _host, (unsigned long)_port]];
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_len = sizeof(addr);
    addr.sin_family = AF_INET;
    addr.sin_port = htons(_port);
    const char *hostaddr = [_host UTF8String];
    if (hostaddr == NULL) {
        hostaddr = "\0";
    }
    addr.sin_addr.s_addr = inet_addr(hostaddr);
    if (addr.sin_addr.s_addr == INADDR_NONE) {
        struct hostent *host = gethostbyname(hostaddr);
        if (host == NULL || host->h_addr == NULL) {
            [self.output write:@"Problem accessing the DNS"];
            if (_complete != nil) {
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    _complete([self buildResult:-1006 ip:nil durations:nil loss:0 count:0 totalTime:0]);
                });
                [_sender report:[self buildResult:-1006 ip:nil durations:nil loss:0 count:0 totalTime:0].description method:@"tcpPing" domain:_host];
            }
            return;
        }
        addr.sin_addr = *(struct in_addr *)host->h_addr;
        [self.output write:[NSString stringWithFormat:@"connect to ip %s:%lu ...\n", inet_ntoa(addr.sin_addr), (unsigned long)_port]];
    }
    NSString *ip = [NSString stringWithUTF8String:inet_ntoa(addr.sin_addr)];
    NSTimeInterval *intervals = (NSTimeInterval *)malloc(sizeof(NSTimeInterval) * _count);
    int index = 0;
    int r = 0;
    int loss = 0;
    do {
        NSDate *t1 = [NSDate date];
        r = [self connect:&addr];
        NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:t1];
        intervals[index] = duration * 1000;
        if (r == 0) {
            [self.output write:[NSString stringWithFormat:@"connected to %s:%lu, %f ms\n", inet_ntoa(addr.sin_addr), (unsigned long)_port, duration * 1000]];
        } else {
            [self.output write:[NSString stringWithFormat:@"connect failed to %s:%lu, %f ms, error %d\n", inet_ntoa(addr.sin_addr), (unsigned long)_port, duration * 1000, r]];
            loss++;
        }

        if (index < _count && !_stopped ) {
            [NSThread sleepForTimeInterval:0.1];
        }
    } while (++index < _count && !_stopped );

    if (_complete) {
        NSInteger code = r;
        if (_stopped) {
            code = kCLSRequestStoped;
        }
        __block NSDate *startDate = begin;
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            _complete([self buildResult:code ip:ip durations:intervals loss:loss count:index totalTime:[[NSDate date] timeIntervalSinceDate:startDate] * 1000]);
            free(intervals);
        });
    }
    [_sender report:[self buildResult:r ip:ip durations:intervals loss:loss count:index totalTime:[[NSDate date] timeIntervalSinceDate:begin] * 1000].description method:@"tcpPing" domain:_host];
    
}

- (CLSTcpPingResult *)buildResult:(NSInteger)code
                               ip:(NSString *)ip
                        durations:(NSTimeInterval *)durations
                             loss:(NSInteger)loss
                            count:(NSInteger)count
                        totalTime:(NSTimeInterval)time {
    if (code != 0 && code != kCLSRequestStoped) {
        return [[CLSTcpPingResult alloc] init:code ip:ip max:0 min:0 avg:0 loss:1 count:1 totalTime:time stddev:0];
    }
    NSTimeInterval max = 0;
    NSTimeInterval min = 10000000;
    NSTimeInterval sum = 0;
    NSTimeInterval sum2 = 0;
    for (int i = 0; i < count; i++) {
        if (durations[i] > max) {
            max = durations[i];
        }
        if (durations[i] < min) {
            min = durations[i];
        }
        sum += durations[i];
        sum2 += durations[i] * durations[i];
    }
    NSTimeInterval avg = sum / count;
    NSTimeInterval avg2 = sum2 / count;
    NSTimeInterval stddev = sqrt(avg2 - avg * avg);
    return [[CLSTcpPingResult alloc] init:code ip:ip max:max min:min avg:avg loss:loss count:count totalTime:time stddev:stddev];
}
/*
- (int)connect:(struct sockaddr_in *)addr {
    int sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (sock == -1) {
        return errno;
    }
    int on = 1;
    setsockopt(sock, SOL_SOCKET, SO_NOSIGPIPE, &on, sizeof(on));
    setsockopt(sock, IPPROTO_TCP, TCP_NODELAY, (char *)&on, sizeof(on));

    struct timeval timeout;
    timeout.tv_sec = 0;
    timeout.tv_usec = 10;
    setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, (char *)&timeout, sizeof(timeout));
    setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO, (char *)&timeout, sizeof(timeout));

    if (connect(sock, (struct sockaddr *)addr, sizeof(struct sockaddr)) < 0) {
        int err = errno;
        close(sock);
        return err;
    }
    close(sock);
    return 0;
}
*/
- (int)connect:(struct sockaddr_in *)addr {
    int sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (sock == -1) {
        return errno;
    }
    int on = 1;
    setsockopt(sock, SOL_SOCKET, SO_NOSIGPIPE, &on, sizeof(on));
    setsockopt(sock, IPPROTO_TCP, TCP_NODELAY, (char *)&on, sizeof(on));

    struct timeval timeout;
    timeout.tv_sec = 0;
    timeout.tv_usec = 10;
    setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, (char *)&timeout, sizeof(timeout));
    setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO, (char *)&timeout, sizeof(timeout));
    int flags;
    flags = fcntl(sock, F_GETFL, 0);
    if (flags == -1)
    {
        close(sock);
        return -1;
    }
    flags |= O_NONBLOCK;
    if (fcntl(sock, F_SETFL, flags) == -1)
    {
        close(sock);
        return -1;
    }
    if (connect(sock, (struct sockaddr *)addr, sizeof(struct sockaddr)) < 0) {
        struct timeval tv;
        fd_set wset;
        tv.tv_sec = 3; //timeout
        tv.tv_usec = 0;
        FD_ZERO(&wset);
        FD_SET(sock, &wset);
        int n = select(sock + 1, NULL, &wset, NULL, &tv);
        if (n < 0)
        {
            close(sock);
            return -1;
        }
        else if (n == 0)
        {
            close(sock);
            return -1;
        }
    }
    flags &= ~ O_NONBLOCK;
    fcntl(sock,F_SETFL, flags);
    close(sock);
    return 0;
    
}
+ (instancetype)start:(NSString *)host
               output:(id<CLSOutputDelegate>)output
             complete:(CLSTcpPingCompleteHandler)complete
               sender: (baseSender *)sender{
    return [CLSTcpPing start:host port:80 count:3 output:output complete:complete sender:sender];
}

+ (instancetype)start:(NSString *)host
                 port:(NSUInteger)port
                count:(NSInteger)count
               output:(id<CLSOutputDelegate>)output
             complete:(CLSTcpPingCompleteHandler)complete
               sender: (baseSender *)sender;
{
    CLSTcpPing *t = [[CLSTcpPing alloc] init:host
                                        port:port
                                      output:output
                                    complete:complete
                                       count:count
                                      sender:sender];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [t run];
    });
    return t;
}

- (void)stop {
    _stopped = YES;
}

@end
