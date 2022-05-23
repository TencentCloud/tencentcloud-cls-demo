
#import "AppDelegate.h"
#import "DemoUtils.h"
#import "MainViewController.h"

#import <TencentCloundLogProducer/TencentCloundLogProducer.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window=[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    MainViewController *viewController = [[MainViewController alloc] init];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    [navigationController.navigationBar setBarTintColor:[UIColor blueColor]];
    navigationController.view.tintColor = [UIColor whiteColor];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];


    DemoUtils *utils = [DemoUtils sharedInstance];
    [utils setEndpoint:@"ap-guangzhou.cls.tencentcs.com"];
    [utils setAccessKeyId:@""];
    [utils setAccessKeySecret:@""];
    [utils setTopic:@""];
    
    CLSLogV(@"endpoint: %@", [utils endpoint]);
    CLSLogV(@"accessKeyId: %@", [utils accessKeyId]);
    CLSLogV(@"accessKeySecret: %@", [utils accessKeySecret]);
    CLSLogV(@"topic: %@", [utils topic]);
    return YES;
}


@end

