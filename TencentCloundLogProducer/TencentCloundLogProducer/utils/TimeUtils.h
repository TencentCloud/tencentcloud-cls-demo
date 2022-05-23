

#import <Foundation/Foundation.h>
#import "Log.h"

NS_ASSUME_NONNULL_BEGIN

@interface TimeUtils : NSObject
+(void) updateServerTime: (NSInteger) timeInMillis;
+(NSInteger) getTimeInMilliis;
+(void) fixTime: (Log *)log;
@end

NS_ASSUME_NONNULL_END
