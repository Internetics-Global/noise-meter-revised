//
//  NSUserDefaultsHelper.h
//  NoiseMeter
//
//  Created by Bourne Wang on 14-2-6.
//  Copyright (c) 2014年 Internetics Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaultsHelper : NSObject

+ (BOOL) isAdRemoved;
+ (void) setAdRemoveFlag:(BOOL) flag;

+ (BOOL) isOutputToEarpiece;
+ (void) setOutputToEarpieceFlag:(BOOL) flag;

+ (BOOL) isNotAllowBackgroundRunning;
+ (void) setNotAllowBackgroundRunningFlag:(BOOL) flag;

+ (BOOL) isLoggingPause;
+ (void) setLoggingPauseFlag:(BOOL) flag;

+ (BOOL) isNotShowMeterOffDialog;
+ (void) setNotShowMeterOffDialogFlag:(BOOL) flag;

+ (BOOL) isIgnoreSuddenNoise;
+ (void) setIgnoreSuddenNoise:(BOOL) flag;

+ (BOOL) isDelayAlarmSound;
+ (void) setDelayAlarmSound:(BOOL) flag;

@end
