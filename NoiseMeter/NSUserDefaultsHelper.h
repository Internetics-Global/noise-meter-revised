//
//  NSUserDefaultsHelper.h
//  NoiseMeter
//
//  Created by Bourne Wang on 14-2-6.
//  Copyright (c) 2014年 Internetics Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaultsHelper : NSObject

/**
 *  This is to indicate whether currently it's pro classroom version. pro classroom version is also pro version.
 */
+ (BOOL) isProClassRoomVersion;
+ (void) setProClassRoomVersion:(BOOL) flag;

/**
 *  This is to indicate whether currently it's pro version
 */
+ (BOOL) isProVersion;
+ (void) setProVersionFlag:(BOOL) flag;

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

+ (BOOL) isContinuousMode;
+ (void) setContinuousMode:(BOOL) flag;

+ (BOOL) isSilentMode;
+ (void) setSilentMode:(BOOL) flag;


@end
