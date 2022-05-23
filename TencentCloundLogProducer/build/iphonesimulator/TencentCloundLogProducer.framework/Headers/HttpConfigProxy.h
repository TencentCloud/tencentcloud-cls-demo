

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HttpConfigProxy : NSObject
@property(nonatomic, strong) NSString *userAgent;

- (void) addPluginUserAgent: (NSString *) key value: (NSString *) value;

+ (instancetype) sharedInstance;

@end

NS_ASSUME_NONNULL_END
