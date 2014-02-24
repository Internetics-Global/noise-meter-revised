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
#import "TestFlight.h"
#import "NSUserDefaultsHelper.h"
#import "IDPSoundboard.h"


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
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    _rootView = [[RootView alloc] init];
    self.window.rootViewController = _rootView;
    
    [Appirater appLaunched:YES];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [[UITabBar appearance] setBarTintColor:[UIColor blackColor]];
        [[UITabBar appearance] setTintColor:[UIColor colorWithRed:56.0/255 green:172.0/255 blue:238.0/255 alpha:1]];
    }
    
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    
    if (TARGET_IPHONE_SIMULATOR) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert You are using simulator" message:@"Background running and IAP are not supported on simulator" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    return YES;
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"applicationDidEnterBackground");
    
    //stop the alarm if it's still playing
    if ([[NMDecibelLogger defaultLogger] playingAlarm]) {
      [[NMDecibelLogger defaultLogger] alarmComplete];
    }
    
    if ([NSUserDefaultsHelper isNotAllowBackgroundRunning]) {
      [[NMDecibelLogger defaultLogger] stopLogging];
        [IDPSoundBoard stopBackgroundSoundRunning];
    } else {
        if ([NSUserDefaultsHelper isAdRemoved]) {
            [IDPSoundBoard runBackgroundSound];
        }
    }
	
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    //如果没有alarm，则自动恢复logging
    if ([[NMDecibelLogger defaultLogger] playingAlarm] == FALSE) {
        [[NMDecibelLogger defaultLogger] startLogging];
    }
    
    if ([NSUserDefaultsHelper isAdRemoved] && ([NSUserDefaultsHelper isNotAllowBackgroundRunning] == FALSE)) {
        [IDPSoundBoard stopBackgroundSoundRunning];
    }
    
    [Appirater appEnteredForeground:YES];
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
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-42160166-1"];
}




@end
