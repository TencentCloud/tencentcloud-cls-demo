

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoUtils : NSObject

@property(nonatomic, strong) NSString *endpoint;
@property(nonatomic, strong) NSString *accessKeyId;
@property(nonatomic, strong) NSString *accessKeySecret;
@property(nonatomic, strong) NSString *topic;

+ (instancetype) sharedInstance;


@end

NS_ASSUME_NONNULL_END
