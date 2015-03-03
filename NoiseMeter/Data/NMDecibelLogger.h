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
#import "IDPSoundBoard.h"

@interface NMDecibelLogger : NSObject<AVAudioRecorderDelegate,IDPSoundBoardDelegate>{
    
    AVAudioRecorder * _recorder;
    NSDictionary    * _recorderSettings;
    BOOL            _logging;
    NSNumber        * _currentReading;
    
    /**
     *  用于周期性的读取sound level值，从而触发alarm
     */
    NSTimer         * _sampleTimer;
    
    SystemSoundID   audioEffect;

    NSTimer         * _timer30Second;
}

/**
 *  It's a keyPath in KVC
 */
@property (strong, nonatomic, readonly) NSNumber      *currentReading;


@property (strong, nonatomic          ) NSNumber      *alertThreshold;
@property (strong, nonatomic          ) NSString      *alarmName;

@property (nonatomic, strong          ) AVQueuePlayer *keepAlivePlayer;

/**
 *  if true, then forbid to execute [self willChangeValueForKey:@"currentReading"]
 */
@property (assign, nonatomic          ) BOOL          playingAlarm;

+ (NMDecibelLogger *)defaultLogger;

- (float)rawReading;
- (void) startLogging;
- (void) stopLogging;
- (void) playAlarm;
- (void) ensureLogging;
- (void) updateReading;
- (void) alarmComplete;
- (BOOL) logging;

@end
