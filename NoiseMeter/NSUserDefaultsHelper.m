//
//  NSUserDefaultsHelper.m
//  NoiseMeter
//
//  Created by Bourne Wang on 14-2-6.
//  Copyright (c) 2014年 Internetics Pty Ltd. All rights reserved.
//

#import "NSUserDefaultsHelper.h"

@implementation NSUserDefaultsHelper


+ (BOOL) isProVersion {
    
    //return YES; //only for debug
    
#ifdef TARGET_PRO_VERSION
    return YES;
#endif
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL flag = [userDefaults boolForKey:@"AD_REMOVED"];
    return flag;
}

+ (void) setProVersionFlag:(BOOL) flag {
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
    BOOL flag = YES;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:@"NOT_BACKGROUND_RUNNING"]) {
      flag = [userDefaults boolForKey:@"NOT_BACKGROUND_RUNNING"];
    }
    else {
        flag = YES;
    }
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

+ (BOOL) isIgnoreSuddenNoise {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL flag = [userDefaults boolForKey:@"IGNORE_SUDDEN_NOISE"];
    return flag;
}

+ (void) setIgnoreSuddenNoise:(BOOL) flag {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:flag forKey:@"IGNORE_SUDDEN_NOISE"];
    [userDefaults synchronize];
}

+ (BOOL) isDelayAlarmSound {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL flag = [userDefaults boolForKey:@"DELAY_ALARM_SOUND"];
    return flag;
}

+ (void) setDelayAlarmSound:(BOOL) flag {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:flag forKey:@"DELAY_ALARM_SOUND"];
    [userDefaults synchronize];
}

+ (BOOL) isContinuousMode {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL flag = [userDefaults boolForKey:@"CONTINUOUS_MODE"];
    return flag;
}

+ (void) setContinuousMode:(BOOL) flag {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:flag forKey:@"CONTINUOUS_MODE"];
    [userDefaults synchronize];
}


+ (BOOL) isSilentMode {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL flag = [userDefaults boolForKey:@"SILENT_MODE"];
    return flag;
}

+ (void) setSilentMode:(BOOL) flag {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:flag forKey:@"SILENT_MODE"];
    [userDefaults synchronize];
}

+ (MeterDisplayType) meterDisplayType {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger type = [userDefaults integerForKey:@"METER_DISPLAY_TYPE"];
    return type;
}

+ (void) setMeterDisplayType:(MeterDisplayType) type {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:type forKey:@"METER_DISPLAY_TYPE"];
    [userDefaults synchronize];
}

+ (float) lastNoisePeakValue {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    float val = [userDefaults floatForKey:@"LAST_NOISE_PEAK_VALUE"];
    return val;
}


+ (void) setLastNoisePeak:(float) val {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setFloat:val forKey:@"LAST_NOISE_PEAK_VALUE"];
    [userDefaults synchronize];
}




@end
