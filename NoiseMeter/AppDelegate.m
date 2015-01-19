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
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import "TestFlight.h"


@implementation AppDelegate

@synthesize window = _window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //##warning: only for test purpose,need to be removed in formal version
    //NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //[userDefaults setBool:TRUE forKey:@"AD_REMOVED"];
    
    [TestFlight takeOff:@"fc71ce67-b62a-4e6e-9cf9-5071518588c3"];
    
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
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [[UITabBar appearance] setBarTintColor:[UIColor blackColor]];
        [[UITabBar appearance] setTintColor:[UIColor colorWithRed:56.0/255 green:172.0/255 blue:238.0/255 alpha:1]];
    }
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    
    return YES;
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"applicationDidEnterBackground");
    
    if ([[NMDecibelLogger defaultLogger] playingAlarm]) {
      [[NMDecibelLogger defaultLogger] alarmComplete];
    }
    
    if ([NSUserDefaultsHelper isNotAllowBackgroundRunning]) {
      [[NMDecibelLogger defaultLogger] stopLogging];
    } else {
        if ([NSUserDefaultsHelper isAdRemoved]) {
            if (isUseLongRunningtTask) {
                //do nothing and will keep runnning in background
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
    if ([[NMDecibelLogger defaultLogger] playingAlarm] == FALSE) {
        [[NMDecibelLogger defaultLogger] startLogging];
    }
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
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
    // Create tracker instance.
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-42160166-1"];
    [tracker set:kGAIUseSecure value:[@NO stringValue]];
    
    [tracker send:[[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                           action:@"appstart"
                                                            label:nil
                                                            value:nil] set:@"start" forKey:kGAISessionControl] build]];
}


@end
