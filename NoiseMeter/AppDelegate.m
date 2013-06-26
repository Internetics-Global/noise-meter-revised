//
//  AppDelegate.m
//  NoiseMeter
//
//  Created by Dave Finster on 17/02/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "NMDecibelLogger.h"
@implementation AppDelegate

@synthesize window = _window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    _rootView = [[RootView alloc] init];
    self.window.rootViewController = _rootView;
    _comingFromBackground = YES;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[NMDecibelLogger defaultLogger] stopLogging];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NMDecibelLogger defaultLogger] startLogging];
    _comingFromBackground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (_comingFromBackground) 
    {
        _comingFromBackground = NO;
    }
    else 
    {
        [[NMDecibelLogger defaultLogger] ensureLogging];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
}

@end
