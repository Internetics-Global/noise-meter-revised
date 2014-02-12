//
//  NSUserDefaultsHelper.m
//  NoiseMeter
//
//  Created by Bourne Wang on 14-2-6.
//  Copyright (c) 2014年 Internetics Pty Ltd. All rights reserved.
//

#import "NSUserDefaultsHelper.h"

@implementation NSUserDefaultsHelper

+ (BOOL) isAdRemoved {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL flag = [userDefaults boolForKey:@"AD_REMOVED"];
    return flag;
}

+ (void) setAdRemoveFlag:(BOOL) flag {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:flag forKey:@"AD_REMOVED"];
    [userDefaults synchronize];
    NSLog(@"%s:the flag AD_REMOVED is set",__FUNCTION__);
}

+ (BOOL) isOutputToEarpiece {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL flag = [userDefaults boolForKey:@"OUTPUT_EARPIECE"];
    return flag;
}

+ (void) setOutputToEarpieceFlag:(BOOL) flag {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:flag forKey:@"OUTPUT_EARPIECE"];
    [userDefaults synchronize];
}

+ (BOOL) isNotAllowBackgroundRunning {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL flag = [userDefaults boolForKey:@"NOT_BACKGROUND_RUNNING"];
    return flag;
}

+ (void) setNotAllowBackgroundRunningFlag:(BOOL) flag {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:flag forKey:@"NOT_BACKGROUND_RUNNING"];
    [userDefaults synchronize];
}

+ (BOOL) isLoggingPause {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL flag = [userDefaults boolForKey:@"LOGGING_PAUSE"];
    return flag;
}

+ (void) setLoggingPauseFlag:(BOOL) flag {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:flag forKey:@"LOGGING_PAUSE"];
    [userDefaults synchronize];
}

+ (BOOL) isNotShowMeterOffDialog {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL flag = [userDefaults boolForKey:@"NOT_SHOW_METEROFF_DIALOG"];
    return flag;
}

+ (void) setNotShowMeterOffDialogFlag:(BOOL) flag {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:flag forKey:@"NOT_SHOW_METEROFF_DIALOG"];
    [userDefaults synchronize];
}


@end
