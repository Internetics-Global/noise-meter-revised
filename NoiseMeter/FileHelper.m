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

@end
