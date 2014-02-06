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

@end
