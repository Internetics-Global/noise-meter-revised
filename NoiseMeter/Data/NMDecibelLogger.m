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
    
    AVAudioSession *sesson = [AVAudioSession sharedInstance];
    [sesson setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [sesson setMode:AVAudioSessionModeVideoRecording error:&error];
    if (![sesson setActive:YES error:&error]) {
        NSLog(@"Error %@",[error localizedDescription]);
        return NO;
    }
    
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
                
                if (([UIApplication sharedApplication].applicationState != UIApplicationStateBackground ) && (isUseLongRunningtTask == NO)) {
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
    
    if (([UIApplication sharedApplication].applicationState == UIApplicationStateBackground ) && (isUseLongRunningtTask == NO)) {
        //send local notification
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = @"Sound reachs the threshhold";
        localNotification.fireDate = [NSDate date];
        localNotification.timeZone = [NSTimeZone defaultTimeZone];	
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}

- (void)alarmComplete
{
    AudioServicesDisposeSystemSoundID(audioEffect);
    _playingAlarm = NO;
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
}

@end
