//
//  NMDecibelLogger.m
//  NoiseMeter
//
//  Created by Dave Finster on 6/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import "NMDecibelLogger.h"

@implementation NMDecibelLogger

@synthesize currentReading = _currentReading;

+ (NMDecibelLogger *)defaultLogger
{
    static NMDecibelLogger *defaultLogger;
	@synchronized(self){
		if (defaultLogger == nil) {
			defaultLogger = [[NMDecibelLogger alloc] init];
		}
		return defaultLogger;
	}
}

- (NSNumber *)alertThreshold
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    return [def valueForKey:@"alertThreshold"];
}

- (void)setAlertThreshold:(NSNumber *)alertThreshold
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setValue:alertThreshold forKey:@"alertThreshold"];
    [def synchronize];
}

- (NSString *)alarmName
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    return [def valueForKey:@"alarmName"];
}

- (void)setAlarmName:(NSNumber *)alarmName
{
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    [def setValue:alarmName forKey:@"alarmName"];
    [def synchronize];
}

- (id)init
{
    self = [super init];
    
    NSError *error;
    BOOL success;
    
    [[AVAudioSession sharedInstance] setDelegate:self];
    
    success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if (!success) {
      NSLog(@"%s:AVAudioSession error setting category %@",__FUNCTION__,error);
    }
    
    [self audioRoute];
    
    _recorderSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithInt:kAudioFormatAppleIMA4],AVFormatIDKey,
                         [NSNumber numberWithInt:44100],AVSampleRateKey,
                         [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                         [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                         [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                         [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                         nil];
    _logging = NO;
    _recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp.caf"]]  settings:_recorderSettings error:&error];
    _recorder.delegate = self;
    _recorder.meteringEnabled = YES;
    
    
    AudioSessionAddPropertyListener (kAudioSessionProperty_AudioRouteChange,
                                     audioRouteChangeListenerCallback,
                                     (__bridge void *)(self));
    
    
    
    BOOL flag = [NSUserDefaultsHelper isAdRemoved];
    
    if ((isUseLongRunningtTask) && (flag == true)) {
        NSArray *queue = @[
                           [AVPlayerItem playerItemWithURL:[[NSBundle mainBundle] URLForResource:@"demo" withExtension:@"mp3"]]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[queue lastObject]];
        
        self.player = [[AVQueuePlayer alloc] initWithItems:queue];
        self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        
        void (^observerBlock)(CMTime time) = ^(CMTime time) {
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
                
            } else {
                
                if ([NSUserDefaultsHelper isNotAllowBackgroundRunning] == FALSE) {
                    [self updateReading];
                    NSLog(@"Background running: %f",_currentReading.floatValue);
                }
            }
        };
        
        [self.player addPeriodicTimeObserverForInterval:CMTimeMake(100, 1000)
                                                  queue:dispatch_get_main_queue()
                                             usingBlock:observerBlock];

        
        
        [self.player play];
    }
    
    
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if([def valueForKey:@"alertThreshold"] == nil)
    {
        [def setValue:[NSNumber numberWithInt:90] forKey:@"alertThreshold"];
        [def synchronize];
    }
    if([def valueForKey:@"alarmName"] == nil)
    {
        [def setValue:@"home_alarm" forKey:@"alarmName"];
        [def synchronize];
    }
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    return self;
}

- (void)playAlarm
{
    if (!_playingAlarm) 
    {
        NSString *path  = [[NSBundle mainBundle] pathForResource:self.alarmName ofType:@"aifc"];
        NSLog(@"%@ - %@", path, self.alarmName);
        if ([[NSFileManager defaultManager] fileExistsAtPath : path])
        {
            NSURL *pathURL = [NSURL fileURLWithPath : path];
            OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
            if (error != kAudioServicesNoError) 
            {
                NSLog(@"Invalid Alarm");
            }
            else 
            {
                [self stopLogging];
                AudioServicesPlaySystemSound(audioEffect);
                _playingAlarm = YES;
                
                [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(alarmComplete) userInfo:nil repeats:NO];
            }
        }
        else 
        {
            NSLog(@"NO file");
        }
    }
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        //send local notification
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = @"Hey - keep the noise down! The alarm has triggered!";
        localNotification.fireDate = [NSDate date];
        localNotification.timeZone = [NSTimeZone defaultTimeZone];	
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    
    
}

- (void)alarmComplete
{
    AudioServicesDisposeSystemSoundID(audioEffect);
    _playingAlarm = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ALARM_FINISHED_NOTIFICATION" object:self];
    
    BOOL flag = [NSUserDefaultsHelper isAdRemoved];
    if (([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) && (flag == false)) {
        //we indirectly call this from applicationDidEnterBackground and we don't it keep running if not been purchased
        [self stopLogging];
    } else {
        [self startLogging];
    }
    
}

- (BOOL)logging
{
    return _logging;
}

- (void)ensureLogging
{
    if (!_logging) 
    {
        [self startLogging];
    }
}

- (void)startLogging
{
    
    _logging = YES;
    if(![_recorder record])
    {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
          [[NSNotificationCenter defaultCenter] postNotificationName:@"RecordFail" object:nil];
        }
        
    }
    else 
    {
        _sampleTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerFire) userInfo:nil repeats:NO];
    }

}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    [self stopLogging];
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(ensureLogging) userInfo:nil repeats:NO];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
    
}


- (float)rawReading
{
    [_recorder updateMeters];
    return [_recorder averagePowerForChannel:0];
}

- (void) updateReading {
    float temp = [self rawReading];
    _currentReading = [NSNumber numberWithFloat:(temp + 100)];
    
    
}

- (void)timerFire
{
    if (([NSUserDefaultsHelper isNotAllowBackgroundRunning]) && ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)) {
        return;
    }
    
    _sampleTimer = nil;
    if (!_playingAlarm)
    {
        [self willChangeValueForKey:@"currentReading"];
        _currentReading = [NSNumber numberWithFloat:([self rawReading] + 100)];
        [self didChangeValueForKey:@"currentReading"];
    }
    _sampleTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerFire) userInfo:nil repeats:NO];
    
    NSLog(@"%s:timeFire",__FUNCTION__);
}

- (void)stopLogging
{
    [_sampleTimer invalidate];
    _sampleTimer = nil;
    _logging = NO;
    [_recorder stop];
}

- (void)dealloc
{
    _recorder = nil;
    _recorderSettings = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark – kAudioSessionProperty_AudioRouteChange

void audioRouteChangeListenerCallback (
                                       void                      *inUserData,
                                       AudioSessionPropertyID    inPropertyID,
                                       UInt32                    inPropertyValueSize,
                                       const void                *inPropertyValue
                                       ) {
    
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange) {
      return;
    }
    
    
    BOOL success = FALSE;
    NSError *error;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        
        if ([NSUserDefaultsHelper isOutputToEarpiece]) {
          success = [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
        } else {
            success = [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        }
        
        if (!success)  {
            NSLog(@"%s:AVAudioSession error overrideOutputAudioPort %@",__FUNCTION__,error);
        }
    } else {
        UInt32 audioRouteOverride;
        
        if ([NSUserDefaultsHelper isOutputToEarpiece]) {
            audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
        } else {
            audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        }
        
        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
    }
        
}

- (void) audioRoute {
    BOOL success = FALSE;
    NSError *error;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        
        if ([NSUserDefaultsHelper isOutputToEarpiece]) {
            success = [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
        } else {
            success = [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        }
        
        if (!success)  {
            NSLog(@"%s:AVAudioSession error overrideOutputAudioPort %@",__FUNCTION__,error);
        }
    } else {
        UInt32 audioRouteOverride;
        
        if ([NSUserDefaultsHelper isOutputToEarpiece]) {
            audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
        } else {
            audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        }
        
        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
    }
}

@end
