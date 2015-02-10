//
//  FileHelper.m
//  NoiseMeter
//
//  Created by Bourne Wang on 14-1-30.
//  Copyright (c) 2014年 Internetics Pty Ltd. All rights reserved.
//

#import "FileHelper.h"

@implementation FileHelper

+ (NSURL *) getRecordedAudioFile:(NSString *) fileName {
    NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:
                            fileName]];
    return url;
}

+ (NSString *) getCreatedAlarmFile:(NSString *) fileName {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    if ([fileName rangeOfString:@".caf"].length == 0) {
        fileName = [NSString stringWithFormat:@"%@.caf",fileName];
    }
    NSString *filePath = [documentsPath stringByAppendingPathComponent:
                          fileName];
    return filePath;
}

+ (NSString *) convertDate: (NSDate *) date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSLocale *au = [[NSLocale alloc] initWithLocaleIdentifier:@"en_AU"];
	[dateFormatter setLocale:au];
	[dateFormatter setDateFormat:@"dd.MM.yyyy.HH.mm.ss"];
	NSString *dateString = [dateFormatter stringFromDate:date];
    
    return dateString;
}

+ (void) removeAllExceptTempCafFile {
   NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:nil];
    for (NSString *file in dirContents) {
        if (![file isEqualToString:@"tmp.caf"]) {
            [[NSFileManager defaultManager] removeItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:file] error:nil];
        }
    }
    
    
}

+ (NSURL *) getDefaultRecordedaAudioFile {
    NSURL *url = [self getRecordedAudioFile:@"tmp.caf"];
    return url;
}


+ (void) saveNewCreatedAlarm:(NSURL *) originalPath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    int i = 0;
    while (1) {
        NSString *filePath = [documentsPath stringByAppendingPathComponent:
                              [NSString stringWithFormat:@"%d.caf",i]];
        BOOL fileExists = [fileManager fileExistsAtPath:filePath];
        if (fileExists == FALSE) {
            break;
        }
        i++;
    }
    
    NSString *destPath = [documentsPath stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"%d.caf",i]];
    
    NSError *error = nil;
    [[NSFileManager defaultManager] copyItemAtPath:[originalPath path] toPath:destPath error:&error];
    if (error) {
        NSLog(@"%s:%@",__FUNCTION__,[error description]);
    }
    
}

+ (int) getMaxNumberCreatedAlarmFiles {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    int i = 0;
    while (1) {
        NSString *filePath = [documentsPath stringByAppendingPathComponent:
                              [NSString stringWithFormat:@"%d.caf",i]];
        BOOL fileExists = [fileManager fileExistsAtPath:filePath];
        if (fileExists == FALSE) {
            break;
        }
        i++;
    }
    
    return (i);
}

+ (NSString *) preloadedUpgradeHTMLFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0],@"upgrade.html"];
    return filePath;
}

@end
