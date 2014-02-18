//
//  PlayHelper.m
//  NoiseMeter
//
//  Created by Bourne Wang on 14-2-5.
//  Copyright (c) 2014年 Internetics Pty Ltd. All rights reserved.
//

#import "PlayHelper.h"
#import "NMDecibelLogger.h"
#import <AVFoundation/AVFoundation.h>

static SystemSoundID gAudioEffect = 0;
static BOOL _isPlaying = NO;

@implementation PlayHelper

+ (void) playAudioFile:(NSURL *) url {
    
    //play audio function need to be purchased
    BOOL flag = [NSUserDefaultsHelper isAdRemoved];
    if (flag == FALSE) {
        return;
    }
    
    if (_isPlaying) {
        return;
    } else {
        _isPlaying = YES;
    }
    
    if (url == nil) {
        NSLog(@"%s:missing audio file",__FUNCTION__);
        [[[UIAlertView alloc] initWithTitle:@"Alert" message:@"No recorded audio file" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]
         show];
        return;
    }
    
    if ([[NMDecibelLogger defaultLogger] logging]) {
        [[NMDecibelLogger defaultLogger] stopLogging];
    }
    
    [[NMDecibelLogger defaultLogger].keepAlivePlayer pause]; //这非常重要，否则无法发出声音
    [self changeToPlayBackMode];
    
    if (gAudioEffect != 0) {
        AudioServicesRemoveSystemSoundCompletion(gAudioEffect);
        AudioServicesDisposeSystemSoundID(gAudioEffect);
    }
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &gAudioEffect);
    AudioServicesPlaySystemSound(gAudioEffect);
//    AudioServicesAddSystemSoundCompletion(audioEffect,
//                                          NULL,
//                                          NULL,
//                                          systemAudioCallback,
//                                          (__bridge_retained void *) self);
    
    AudioFileID audioFileID;
    AudioFileOpenURL((__bridge CFURLRef)url, kAudioFileReadPermission, 0, &audioFileID);
    NSTimeInterval seconds;
    UInt32 propertySize = sizeof(seconds);
    OSStatus st = AudioFileGetProperty(audioFileID, kAudioFilePropertyEstimatedDuration, &propertySize, &seconds);
    
    
    // fire the timer
    if (st == 0)
    {
        [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(soundDidFinishPlaying) userInfo:nil repeats:NO];
    }

}

#pragma mark – systemAudioCallback
+ (void) soundDidFinishPlaying {
    NSLog(@"System sound finished playing!");
    AudioServicesRemoveSystemSoundCompletion(gAudioEffect);
    AudioServicesDisposeSystemSoundID(gAudioEffect);
    
    [[NMDecibelLogger defaultLogger].keepAlivePlayer play];
    [self changeToPlayAndRecordMode];
    
    [[NMDecibelLogger defaultLogger] startLogging];
    
    _isPlaying = FALSE;
}

+ (BOOL) isPlaying {
    return _isPlaying;
}

+ (void) changeToPlayBackMode {
    NSError *error;
    BOOL success;
    
    success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (!success) {
        NSLog(@"%s:AVAudioSession error setting category %@",__FUNCTION__,error);
    }
}

+ (void) changeToPlayAndRecordMode {
    NSError *error;
    BOOL success;
    
    success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (!success) {
        NSLog(@"%s:AVAudioSession error setting category %@",__FUNCTION__,error);
    }
}


@end
