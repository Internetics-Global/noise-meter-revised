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
#import "NSUserDefaultsHelper.h"
#import "IDPSoundboard.h"
#import "FileHelper.h"
#import "REFrostedViewController.h"
#import "MoreView.h"
#import <ParseCrashReporting/ParseCrashReporting.h>
#import <Parse/Parse.h>

#import "VersionReminder.h"

@interface AppDelegate ()
@end

@implementation AppDelegate

@synthesize window = _window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //##warning: only for test purpose,need to be removed in formal version
    //NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //[userDefaults setBool:TRUE forKey:@"AD_REMOVED"];
    
    [self setupParse];
    
    
    [self setAppirater];
    [self setGoogleAnalytics];
    [Flurry startSession:@"YBZ58DG2BDVN6D962Z3P"];
    
    [self downloadProIntroductionHTMLFile];

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor clearColor];
    [self.window makeKeyAndVisible];
    
    

    
    // configure sliding view controller
    RootView *rootView = [[RootView alloc] init];
    MoreView *moreViewController = [[MoreView alloc] initWithNibName:nil bundle:nil];
    REFrostedViewController *frostedViewController = [[REFrostedViewController alloc] initWithContentViewController:rootView menuViewController:moreViewController];
    frostedViewController.direction = REFrostedViewControllerDirectionLeft;
    frostedViewController.contentFrame = CGRectMake(0, 20, CGRectGetWidth(self.window.bounds), CGRectGetHeight(self.window.bounds) - 20); //in iOS7+, status bar is overlapped
    frostedViewController.menuViewSize = self.window.frame.size;
    self.window.rootViewController = frostedViewController;
    
    
    [Appirater appLaunched:YES];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [[UITabBar appearance] setBarTintColor:[UIColor blackColor]];
        [[UITabBar appearance] setTintColor:[UIColor colorWithRed:56.0/255 green:172.0/255 blue:238.0/255 alpha:1]];
    }
    
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge
                                                                                             |UIRemoteNotificationTypeSound
                                                                                             |UIRemoteNotificationTypeAlert) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
      [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    }
    
    
    if (TARGET_IPHONE_SIMULATOR) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert You are using simulator" message:@"Background running and IAP are not supported on simulator" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    double delayInSeconds = 5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self setupVersionReminder];
    });
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if ([NSUserDefaultsHelper isProClassRoomVersion]) {
        [currentInstallation setChannels:@[@"classroom"]];
    } else if ([NSUserDefaultsHelper isProVersion]) {
        [currentInstallation setChannels:@[@"pro"]];
    } else {
        [currentInstallation setChannels:@[@"free"]];
    }
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
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
        if ([NSUserDefaultsHelper isProVersion]) {
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
    
    if ([NSUserDefaultsHelper isProVersion] && ([NSUserDefaultsHelper isNotAllowBackgroundRunning] == FALSE)) {
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
    
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [GAI sharedInstance].dispatchInterval = 120;
    
    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
    
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:@"UA-42160166-1"];
    [tracker set:kGAIUseSecure value:[@NO stringValue]];
    [tracker send:[[[GAIDictionaryBuilder createEventWithCategory:@"UX"
                                                           action:@"appstart"
                                                            label:nil
                                                            value:nil] set:@"start" forKey:kGAISessionControl] build]];

}

- (void) downloadProIntroductionHTMLFile {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^(void) {
        NSString *filePath = [FileHelper cachedProIntroductionHTMLFile];
        NSURL *url = [NSURL URLWithString:k_Pro_Introduction_URL];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        [urlData writeToFile:filePath atomically:YES];
        NSLog(@"Done on downloadProIntroductionHTMLFile");
    });
    
}

- (void) downloadProClassRoomIntroductionHTMLFile {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^(void) {
        NSString *filePath = [FileHelper cachedProClassroomIntroductionHTMLFile];
        NSURL *url = [NSURL URLWithString:k_Pro_Classroom_Introduction_URL];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        [urlData writeToFile:filePath atomically:YES];
        NSLog(@"Done on downloadProClassRoomIntroductionHTMLFile");
    });
    
}


- (void) setupVersionReminder {
    
    [VersionReminder setupVersionReminder];
    
}

- (void) setupParse {
    [ParseCrashReporting enable];
    [Parse setApplicationId:@"KRILAj7tzOBrSGLs7DJHmWbCrGnlUZr44YGebIGK"
                  clientKey:@"HtoZ3RftAr6CWkrZnORvsvzwPGOpbRrK2YdIMozh"];
    //simulate a crash issue
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [NSException raise:NSGenericException format:@"Everything is ok. This is just a test crash."];
//    });
}




@end
