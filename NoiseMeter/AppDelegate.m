//
//  AppDelegate.m
//  NoiseMeter
//
//  Created by Dave Finster on 17/02/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "NMDecibelLogger.h"
#import "Appirater.h"
#import "NSUserDefaultsHelper.h"
#import "IDPSoundboard.h"
#import "FileHelper.h"
#import "REFrostedViewController.h"
#import "MoreView.h"

#import "VersionReminder.h"

@import Firebase;
@import FirebaseAnalytics;

@interface AppDelegate ()
@end

@implementation AppDelegate

@synthesize window = _window;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //In Parse, different GoogleService-Info.plist for different target
    {
        //    [ParseCrashReporting enable];
        //#ifdef TARGET_PRO_VERSION
        //    [Parse setApplicationId:@"xQnOZXmWIt7FOlk75RSDLZelhQIt5VQIE13bPX81"
        //                  clientKey:@"f1egk5mV5DQcYk9xsP7dkQVl4r1rrf44FWogXKvb"];
        //#else
        //    [Parse setApplicationId:@"KRILAj7tzOBrSGLs7DJHmWbCrGnlUZr44YGebIGK"
        //                  clientKey:@"HtoZ3RftAr6CWkrZnORvsvzwPGOpbRrK2YdIMozh"];
        //#endif
        //    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    }
    
    //A utility that reminds your iPhone app's users to review the app.
    [self setAppirater];
    
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
    
    
    
    
    // Register for remote notifications
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        // iOS 7.1 or earlier
        UIRemoteNotificationType allNotificationTypes =
        (UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge);
        [application registerForRemoteNotificationTypes:allNotificationTypes];
    } else {
        // iOS 8 or later
        // [END_EXCLUDE]
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    
    [FIRApp configure];
    
    // Add observer for InstanceID token refresh callback.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenRefreshNotification:)
                                                 name:kFIRInstanceIDTokenRefreshNotification object:nil];
    
    
//    if (TARGET_IPHONE_SIMULATOR) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert You are using simulator" message:@"Background running and IAP are not supported on simulator" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//    }
    
    double delayInSeconds = 5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self setupVersionReminder];
    });
    
     [[UIApplication sharedApplication] beginReceivingRemoteControlEvents]; //allow to show volume control in notification center
    
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    //In Firebase, built-in support on cateogry of free and IAP, so we don't need to do any thing
    {
        //    // Store the deviceToken in the current installation and save it to Parse.
        //    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        //    if ([NSUserDefaultsHelper isProVersion]) {
        //        [currentInstallation setChannels:@[@"pro"]];
        //    } else {
        //        [currentInstallation setChannels:@[@"free"]];
        //    }
        //    [currentInstallation setDeviceTokenFromData:deviceToken];
        //    [currentInstallation saveInBackground];
    }
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

    NSLog(@"%@", userInfo);
}

- (void)tokenRefreshNotification:(NSNotification *)notification {
    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"InstanceID token: %@", refreshedToken);
    
    // Connect to FCM since connection may have failed when attempted before having a token.
    [self connectToFcm];
    
    // TODO: If necessary send token to appliation server.
}

- (void)connectToFcm {
    [[FIRMessaging messaging] connectWithCompletion:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Unable to connect to FCM. %@", error);
        } else {
            NSLog(@"Connected to FCM.");
        }
    }];
}



- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"applicationDidEnterBackground");
    
    [[FIRMessaging messaging] disconnect];
    NSLog(@"Disconnected from FCM");
    
    //stop the alarm if it's still playing
    if ([[NMDecibelLogger defaultLogger] playingAlarm]) {
      [[NMDecibelLogger defaultLogger] alarmComplete];
    }
    
    if ([NSUserDefaultsHelper isNotAllowBackgroundRunning]) {
      [[NMDecibelLogger defaultLogger] stopLogging];
    } else {
    }
	
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    //如果没有alarm，则自动恢复logging
    if ([[NMDecibelLogger defaultLogger] playingAlarm] == FALSE) {
        [[NMDecibelLogger defaultLogger] startLogging];
    }
    
//    if ([NSUserDefaultsHelper isProVersion] && ([NSUserDefaultsHelper isNotAllowBackgroundRunning] == FALSE)) {
//        [IDPSoundBoard stopBackgroundSoundRunning];
//    }
    
    [Appirater appEnteredForeground:YES];
}


- (void) applicationDidBecomeActive:(UIApplication *)application {
    
    [self connectToFcm];
    
    if ([NSUserDefaultsHelper isNotAllowBackgroundRunning] == FALSE) {
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            [IDPSoundBoard restartBackgroundSound];
        });
        
    }

    
}



- (void) setAppirater {
    [Appirater setAppId:@"512411644"];
    [Appirater setDaysUntilPrompt:1];
    [Appirater setUsesUntilPrompt:1];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    [Appirater setDebug:FALSE];
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

#pragma mark – music control on lock view
- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    
    if (event.type == UIEventTypeRemoteControl) {
        
        switch (event.subtype) {
                
            case UIEventSubtypeRemoteControlPause:
                [IDPSoundBoard setBackgroundSoundMusicVolume:0.001];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [IDPSoundBoard playNextBackgroundMusic];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [IDPSoundBoard playPreviousBackgroundMusic];
                break;
            case UIEventSubtypeRemoteControlPlay:
                break;
            default:
                break;
        }
    }
}



@end
