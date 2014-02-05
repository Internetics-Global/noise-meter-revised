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

@implementation PlayHelper

+ (void) playAudioFile:(NSURL *) url {
    
    static SystemSoundID audioEffect = 0;
    
    //play audio function need to be purchased
    BOOL flag = [[NSUserDefaults standardUserDefaults] boolForKey:@"AD_REMOVED"];
    if (flag == FALSE) {
        return;
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
    
    AudioServicesRemoveSystemSoundCompletion(audioEffect);
    AudioServicesDisposeSystemSoundID(audioEffect);
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &audioEffect);
    AudioServicesPlaySystemSound(audioEffect);
    AudioServicesAddSystemSoundCompletion(audioEffect,
                                          NULL,
                                          NULL,
                                          systemAudioCallback,
                                          (__bridge_retained void *) self);
    
    
    //    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    //    [audioPlayer play];
}

#pragma mark – systemAudioCallback
void systemAudioCallback(SystemSoundID soundId, void *clientData)
{
    NSLog(@"System sound finished playing!");
    AudioServicesRemoveSystemSoundCompletion(soundId);
    AudioServicesDisposeSystemSoundID(soundId);
    
    [[NMDecibelLogger defaultLogger] startLogging];
}

@end
