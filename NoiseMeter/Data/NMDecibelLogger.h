//
//  NMDecibelLogger.h
//  NoiseMeter
//
//  Created by Dave Finster on 6/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
@interface NMDecibelLogger : NSObject<AVAudioRecorderDelegate>{
    AVAudioRecorder *_recorder;
    NSDictionary *_recorderSettings;
    BOOL _logging;
    NSNumber *_currentReading;
    NSTimer *_sampleTimer;
    SystemSoundID audioEffect;
    BOOL _playingAlarm;
}

@property (strong, nonatomic, readonly) NSNumber *currentReading;
@property (strong, nonatomic) NSNumber *alertThreshold;
@property (strong, nonatomic) NSString *alarmName;

@property (nonatomic, strong) AVQueuePlayer *player;

+ (NMDecibelLogger *)defaultLogger;
- (float)rawReading;
- (void)startLogging;
- (void)stopLogging;
- (void)playAlarm;
- (void)ensureLogging;
- (void) updateReading;
- (void)alarmComplete;

@end
