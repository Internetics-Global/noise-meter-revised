//
//  NMDecibelLogger.m
//  NoiseMeter
//
//  Created by Dave Finster on 6/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import "NMDecibelLogger.h"
#import "FileHelper.h"
#import "PlayHelper.h"

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
    
    [self resetAudioRoute];
    
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
    
    
    if ([NSUserDefaultsHelper isAdRemoved]) {
      [self setupKeepAlive];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(purchasedFinishedNotification:)
                                                     name:@"PURCHASE_FINISHED_NOTIFICATION"
                                                   object:nil];
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


/**
 *  we have two kind of playAlarm file because of history reason
 *   1. aifc which is located in mainBundle (recently we changed to also caf format for better performance)
 *   2. caf, which is created by user with name of 0.caf, 1.caf  (index from 0)
 */
- (void)playAlarm
{
    if (!_playingAlarm) 
    {
        NSString *path  = [[NSBundle mainBundle] pathForResource:self.alarmName ofType:@"caf"];
        NSLog(@"path = %@; alarmName = %@", path, self.alarmName);
        
        if ([[NSFileManager defaultManager] fileExistsAtPath : path] == FALSE) {
            NSLog(@"%s:No of aifc formated alarm file",__FUNCTION__);
            path = [FileHelper getCreatedAlarmFile:self.alarmName];
            if ([[NSFileManager defaultManager] fileExistsAtPath : path] == FALSE) {
                NSLog(@"%s:No of caf formated alarm file",__FUNCTION__);
            }
        }
        
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
                
                if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
                    
                } else {
                  [self.keepAlivePlayer pause];
                }
                
                AudioServicesPlaySystemSound(audioEffect);
                _playingAlarm = YES;
                
                if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
                    [NSTimer scheduledTimerWithTimeInterval:(30.0 - 0) target:self selector:@selector(alarmComplete) userInfo:nil repeats:NO];
                } else {
                    AudioFileID audioFileID;
                    AudioFileOpenURL((__bridge CFURLRef)pathURL, kAudioFileReadPermission, 0, &audioFileID);
                    NSTimeInterval seconds;
                    UInt32 propertySize = sizeof(seconds);
                    OSStatus st = AudioFileGetProperty(audioFileID, kAudioFilePropertyEstimatedDuration, &propertySize, &seconds);
                    
                    // fire the timer
                    if (st == 0)
                    {
                        [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(alarmDidFinishPlaying) userInfo:nil repeats:NO];
                    }
                }
                
            }
            
        }
    }
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        //send local notification, which is only effective when in background
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = @"Hey - keep the noise down! The alarm has triggered!";
        localNotification.fireDate = [NSDate date];
        localNotification.timeZone = [NSTimeZone defaultTimeZone];	
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    
    
}

- (void) alarmDidFinishPlaying {
    [self.keepAlivePlayer play];
    _timer30Second = [NSTimer scheduledTimerWithTimeInterval:(30.0 - 5) target:self selector:@selector(alarmComplete) userInfo:nil repeats:NO];
}


/**
 *  这个方法被Meter.m中的cancel方法调用，这时需要invalidate定时器，否则即便调用了cancel方法，定时器也会在某一时刻被唤醒
 */
- (void)alarmComplete
{
    
    [_timer30Second invalidate];
    _timer30Second= nil;
    
    if (audioEffect != 0) {
        AudioServicesRemoveSystemSoundCompletion(audioEffect);
        AudioServicesDisposeSystemSoundID(audioEffect);
        audioEffect = 0;
    }
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
    NSLog(@"%s:playerItemDidReachEnd",__FUNCTION__);
    [self.keepAlivePlayer seekToTime:kCMTimeZero];
    [self.keepAlivePlayer play];
    
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
    
    if ((!_playingAlarm) && (APP_DELEGATE.isCreatingCustomAlarmFile == FALSE))
    {
        [self willChangeValueForKey:@"currentReading"];
        _currentReading = [NSNumber numberWithFloat:([self rawReading] + 100)];
        [self didChangeValueForKey:@"currentReading"];
    }
    
    _sampleTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerFire) userInfo:nil repeats:NO];
    
    NSLog(@"%s:timerFire",__FUNCTION__);
}

- (void)stopLogging
{
    [_sampleTimer invalidate];
    _sampleTimer = nil;
    _logging = NO;
    
    sleep(0.3);
    
    [_recorder stop];
}

/**
 *  Reset audio output route speaker or headset
 */
- (void) resetAudioRoute {
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
    
    
    //following codes are same with [self resetAudioRoute]
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


#pragma mark – PURCHASE_FINISHED_NOTIFICATION

- (void)purchasedFinishedNotification:(NSNotification *)notification {
    [self setupKeepAlive];
}


/**
 *  In order to keep running in background, we setup an endless sound play
 */
- (void) setupKeepAlive {
    
    BOOL flag = [NSUserDefaultsHelper isAdRemoved];
    
    if ((isUseLongRunningtTask) && (flag == true)) {
        NSArray *queue = @[
                           [AVPlayerItem playerItemWithURL:[[NSBundle mainBundle] URLForResource:@"demo" withExtension:@"mp3"]]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:[queue lastObject]];
        
        self.keepAlivePlayer = [[AVQueuePlayer alloc] initWithItems:queue];
        self.keepAlivePlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        
        void (^observerBlock)(CMTime time) = ^(CMTime time) {
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
                
            } else {
                
                if ([NSUserDefaultsHelper isNotAllowBackgroundRunning] == FALSE) {
                    [self updateReading];
                    NSLog(@"Background running: %f",_currentReading.floatValue);
                }
            }
        };
        
        [self.keepAlivePlayer addPeriodicTimeObserverForInterval:CMTimeMake(100, 1000)
                                                  queue:dispatch_get_main_queue()
                                             usingBlock:observerBlock];
        
        
        
        [self.keepAlivePlayer play];
    }
}

#pragma mark – Memory mangement
- (void)dealloc
{
    _recorder = nil;
    _recorderSettings = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
