//
//  NMDecibelLogger.m
//  NoiseMeter
//
//  Created by Dave Finster on 6/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import "NMDecibelLogger.h"
#import "FileHelper.h"

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
    
    [IDPSoundBoard resetAudioRoute:[NSUserDefaultsHelper isOutputToEarpiece]];
    
    _recorderSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithInt:kAudioFormatAppleIMA4],AVFormatIDKey,
                         [NSNumber numberWithInt:44100],AVSampleRateKey,
                         [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                         [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
                         [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                         [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                         nil];
    _logging = NO;
    _recorder = [[AVAudioRecorder alloc] initWithURL:[FileHelper getDefaultRecordedTempAudioFile]  settings:_recorderSettings error:&error];
    _recorder.delegate = self;
    _recorder.meteringEnabled = YES;
    
    
    AudioSessionAddPropertyListener (kAudioSessionProperty_AudioRouteChange,
                                     audioRouteChangeListenerCallback,
                                     (__bridge void *)(self));
    
    
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if([def valueForKey:@"alertThreshold"] == nil)
    {
        [def setValue:[NSNumber numberWithInt:95] forKey:@"alertThreshold"];
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
 *   1. caf which is located in mainBundle 
 *   2. caf, which is created by user with name of 0.caf, 1.caf  (index from 0)
 */
- (void)playAlarm:(PlayAlarmFinished)finishBlock
{
    
    if (!_playingAlarm) 
    {
        _playingAlarm = YES;
        
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
                
                [IDPSoundBoard addAudioAtPath:[pathURL path] forKey:Key_PlayerAlarm forType:EnumSoundType_Alarm];
                AVAudioPlayer *player = [IDPSoundBoard audioPlayerForKey:Key_PlayerAlarm];
                player.numberOfLoops = 0;
                [IDPSoundBoard playAudioForKey:Key_PlayerAlarm fadeInInterval:2.0 withFinishBlock:^(BOOL finishSuccess) {
                    
                    if (finishBlock) {
                        finishBlock(finishSuccess);
                    }
                    
                    //这里实际上只是立刻简单执行了alarmComplete，没有任何Timer作用
                    _timer30Second = [NSTimer scheduledTimerWithTimeInterval:(30.0 - 5) target:self selector:@selector(alarmComplete) userInfo:nil repeats:NO];
                }];
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


/**
 *  这个方法被Meter.m中的cancel方法调用，这时需要invalidate定时器，否则即便调用了cancel方法，定时器也会在某一时刻被唤醒
 */
- (void)alarmComplete
{
    NSLog(@"%s",__FUNCTION__);
    //可能已经被关掉，但是也有可能这时没有关闭掉，所以安全起见，需要执行这个方法
    [IDPSoundBoard stopAudioForKey:Key_PlayerAlarm];
    
    [_timer30Second invalidate];
    _timer30Second= nil;
    
    //实际情况中如果没有delay，会造成alarm的声音触发下一个alarm，造成循环alarm
    double delayInSeconds = 1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _playingAlarm = NO;
    });
    
    [[NSNotificationCenter defaultCenter] postNotificationName:K_Notification_Alarm_Finished object:self];
    
    BOOL flag = [NSUserDefaultsHelper isProVersion];
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
    NSLog(@"%s",__FUNCTION__);
    _logging = YES;
    if(![_recorder record])
    {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
          [[NSNotificationCenter defaultCenter] postNotificationName:K_Notification_Record_Fail object:nil];
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


- (float)rawReading
{
    [_recorder updateMeters];
    return [_recorder averagePowerForChannel:0];
}

- (void) updateReading {
    float temp = [self rawReading];
    _currentReading = [NSNumber numberWithFloat:(temp + 100)];
    
    
}

/**
 *  当在前台时，通过timerFire，对_currentReading进行更新，从而实现KVO
 *  在后台时，通过restartBackgroundSound实现Mute音乐的背景loop播放，从而保持代码一直处于活跃状态，_currentReading的更新也是通过timerFire
 */
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
    
    //NSLog(@"%s:timerFire",__FUNCTION__);
}

- (void)stopLogging
{
    [_sampleTimer invalidate];
    _sampleTimer = nil;
    _logging = NO;
    
    sleep(0.5);
    
    [_recorder stop]; //必须执行这个，否则无法进行播放声音
    NSLog(@"%s",__FUNCTION__);
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
    
    NSLog(@"%s",__FUNCTION__);
    
    
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



#pragma mark – Memory mangement
- (void)dealloc
{
    _recorder = nil;
    _recorderSettings = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
