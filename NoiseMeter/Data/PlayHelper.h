//
//  PlayHelper.h
//  NoiseMeter
//
//  Created by Bourne Wang on 14-2-5.
//  Copyright (c) 2014年 Internetics Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlayHelper : NSObject

+ (void) playAudioFile:(NSURL *) url;

+ (BOOL) isPlaying;

+ (void) changeToPlayBackMode;
+ (void) changeToPlayAndRecordMode;

@end
