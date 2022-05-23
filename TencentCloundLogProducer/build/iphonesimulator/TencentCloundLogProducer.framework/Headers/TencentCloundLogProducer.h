//
//  TencentCloundLogProducer.h
//  TencentCloundLogProducer
//
//  Created by herrylv on 2022/5/6.
//

#import <Foundation/Foundation.h>


FOUNDATION_EXPORT double TencentCloundLogProducerVersionNumber;


FOUNDATION_EXPORT const unsigned char TencentCloundLogLogProducerVersionString[];

#ifndef TencentCloundlogCommon_h
#define TencentCloundlogCommon_h

#define SLSLog(fmt, ...) NSLog((@"[SLSiOS] %s " fmt), __FUNCTION__, ##__VA_ARGS__);
#ifdef DEBUG
    #define SLSLogV(fmt, ...) NSLog((@"[SLSiOS] %s:%d: " fmt), __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
    #define SLSLogV(...);
#endif

#endif /* TencentCloundlogCommon_h */


#import "LogProducerClient.h"
#import "LogProducerConfig.h"
#import "Log.h"
#import "TimeUtils.h"

#if __has_include("LogProducerClient+Bricks.h")
#import "LogProducerClient+Bricks.h"
#import "SLSAdapter.h"
#import "SLSConfig.h"
#import "TCData.h"
#import "IPlugin.h"
#endif

#if __has_include(<TencentCloundLogProducer/SLSCrashReporterPlugin.h>)
#import "SLSCrashReporterPlugin.h"
#import "IReporterSender.h"
#import "IFileParser.h"
#endif

