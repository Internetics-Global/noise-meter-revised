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

+ (NSString *) convertDate: (NSDate *) date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSLocale *au = [[NSLocale alloc] initWithLocaleIdentifier:@"en_AU"];
	[dateFormatter setLocale:au];
	[dateFormatter setDateFormat:@"dd.MM.yyyy.HH.mm.ss"];
	NSString *dateString = [dateFormatter stringFromDate:date];
    
    return dateString;
}

+ (void) removeAllExceptTMPCAF {
   NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:nil];
    for (NSString *file in dirContents) {
        if (![file isEqualToString:@"tmp.caf"]) {
            [[NSFileManager defaultManager] removeItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:file] error:nil];
        }
    }
    
    
}


@end
