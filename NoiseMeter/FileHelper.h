//
//  FileHelper.h
//  NoiseMeter
//
//  Created by Bourne Wang on 14-1-30.
//  Copyright (c) 2014年 Internetics Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileHelper : NSObject

+ (NSURL *) getRecordedAudioFile:(NSString *) fileName;

+ (NSString *) convertDate: (NSDate *) date;

+ (NSURL *) getDefaultRecordedaAudioFile;  //temp.caf


//删除tmp目录下的所有文件，除了tmp.caf文件外
+ (void) removeAllExceptTempCafFile;

+ (void) saveNewCreatedAlarm:(NSURL *) originalPath;
+ (int) getMaxNumberCreatedAlarmFiles;
+ (NSString *) getCreatedAlarmFile:(NSString *) fileName;

+ (NSString *) preloadedUpgradeHTMLFile;


+ (NSString *) appVersion;
+ (NSString *) build;

@end
