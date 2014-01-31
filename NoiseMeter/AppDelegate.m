//
//  AppDelegate.m
//  NoiseMeter
//
//  Created by Dave Finster on 17/02/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "NMDecibelLogger.h"
#import "Flurry.h"
#import "Appirater.h"
#import "GAI.h"
@implementation AppDelegate

@synthesize window = _window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //##warning: only for test purpose,need to be removed in formal version
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setBool:TRUE forKey:@"AD_REMOVED"];
    
    
    [self setAppirater];
    [self setGoogleAnalytics];
    [Flurry startSession:@"YBZ58DG2BDVN6D962Z3P"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    _rootView = [[RootView alloc] init];
    self.window.rootViewController = _rootView;
    _comingFromBackground = YES;
    
    [Appirater appLaunched:YES];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"applicationDidEnterBackground");
    
    [[NMDecibelLogger defaultLogger] alarmComplete];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL flag = [userDefaults boolForKey:@"AD_REMOVED"];
    
    if (flag) {
        if (isUseLongRunningtTask) {
            //will put background running in addPeriodicTimeObserverForInterval
        } else {
            self.backgroundTask = UIBackgroundTaskInvalid;
            self.backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
                NSLog(@"Background handler called. Not running background tasks anymore.");
                [application endBackgroundTask:self.backgroundTask];
                self.backgroundTask = UIBackgroundTaskInvalid;
                [[NMDecibelLogger defaultLogger] stopLogging];
            }];
            
            [NSTimer scheduledTimerWithTimeInterval: 0.1 target: self selector: @selector(recordCallback:) userInfo: nil repeats: YES];
        }
    }
	
}

- (void) recordCallback:(id) sender {
    NSTimeInterval remainTime = [UIApplication sharedApplication].backgroundTimeRemaining;
    if (remainTime >0) {
        NSLog(@"Background time remaining = %.1f seconds", remainTime);
        
        [[NMDecibelLogger defaultLogger] updateReading];
         NSLog(@"%f",[NMDecibelLogger defaultLogger].currentReading.floatValue);
    } else {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
        [[NMDecibelLogger defaultLogger] stopLogging];
    }
    
}



- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NMDecibelLogger defaultLogger] startLogging];
    _comingFromBackground = YES;
    [Appirater appEnteredForeground:YES];
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

- (void) setAppirater {
    [Appirater setAppId:@"512411644"];
    [Appirater setDaysUntilPrompt:1];
    [Appirater setUsesUntilPrompt:1];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:NO];
}

- (void) setGoogleAnalytics {
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set debug to YES for extra debugging information.
    [GAI sharedInstance].debug = YES;
    // Create tracker instance.
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-42160166-1"];
}


@end
