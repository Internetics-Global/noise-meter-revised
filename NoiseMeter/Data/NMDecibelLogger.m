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
    
    [[AVAudioSession sharedInstance] setDelegate:self];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
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
    

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL flag = [userDefaults boolForKey:@"AD_REMOVED"];
    
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
                [self updateReading];
                NSLog(@"Background running: %f",_currentReading.floatValue);
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
                
                if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground ) {
                    //we need to keep its status during background
                    [NSTimer scheduledTimerWithTimeInterval:6.0 target:self selector:@selector(alarmComplete) userInfo:nil repeats:NO];     
                }
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
    
    [self startLogging];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RecordFail" object:nil];
    }
    else 
    {
        _sampleTimer = [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(timerFire) userInfo:nil repeats:NO];
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
    _sampleTimer = nil;
    if (!_playingAlarm) 
    {
        [self willChangeValueForKey:@"currentReading"];
        _currentReading = [NSNumber numberWithFloat:([self rawReading] + 100)];
        [self didChangeValueForKey:@"currentReading"];
    }
    _sampleTimer = [NSTimer scheduledTimerWithTimeInterval:0.75 target:self selector:@selector(timerFire) userInfo:nil repeats:NO];
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

@end
