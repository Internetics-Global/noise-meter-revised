//
//  IDPSoundBoard.m
//  NoiseMeter
//
//  Created by Bourne Wang on 14-02-21.
//  Copyright (c) 2013年 Internetics Pty Ltd. All rights reserved.
//

#import "IDPSoundBoard.h"
#import <AudioToolbox/AudioToolbox.h>
#import "NMDecibelLogger.h"

#import <objc/runtime.h>

#define MCSOUNDBOARD_AUDIO_FADE_STEPS   30

static const void *SoundTypeKey = &SoundTypeKey;

@implementation IDPSoundBoard {
    NSMutableDictionary *_sounds;
    NSMutableDictionary *_audio;
    
    /**
     *  No logging is allowed during playback, it's necessary to resume logging after we stop logging during playback
     */
    BOOL                 _isNeedToResumeLogging;
}

#pragma mark – Life Cycle

+ (IDPSoundBoard *)sharedInstance
{
    __strong static id _sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedObject = [[self alloc] init];
        
    });
    return _sharedObject;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _sounds = [NSMutableDictionary dictionary];
        _audio = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark – System Sound play related

- (void)addSoundAtPath:(NSString *)filePath forKey:(id)key
{
    NSURL* fileURL = [NSURL fileURLWithPath:filePath];
    SystemSoundID soundId;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &soundId);
    
    [_sounds setObject:[NSNumber numberWithInt:soundId] forKey:key];
}

+ (void)addSoundAtPath:(NSString *)filePath forKey:(id)key
{
    [[self sharedInstance] addSoundAtPath:filePath forKey:key] ;
}

/**
 *  Be careful, we don't disable logging during playSoundForKey,
 */
- (void)playSoundForKey:(id)key
{
    SystemSoundID soundId = [(NSNumber *)[_sounds objectForKey:key] intValue];
    AudioServicesPlaySystemSound(soundId);
}

+ (void)playSoundForKey:(id)key
{
    [[self sharedInstance] playSoundForKey:key];
}

#pragma mark – Audio play related

- (void)addAudioAtPath:(NSString *)filePath forKey:(id)key forType:(EnumSoundType) soundType
{
    NSLog(@"%s",__FUNCTION__);
    NSURL* fileURL = [NSURL fileURLWithPath:filePath];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:NULL];
    player.delegate = self;
    objc_setAssociatedObject(player, SoundTypeKey, [NSNumber numberWithInt:soundType], OBJC_ASSOCIATION_ASSIGN);
    
    [_audio setObject:player forKey:key];
}

+ (void)addAudioAtPath:(NSString *)filePath forKey:(id)key forType:(EnumSoundType) soundType
{
    [[self sharedInstance] addAudioAtPath:filePath forKey:key forType:soundType];
}

- (void)removeAudioForKey:(id)key {
    NSLog(@"%s",__FUNCTION__);
    AVAudioPlayer *player = [_audio objectForKey:key];
    [self stopAudioForKey:key fadeOutInterval:0]; //we will directly stop player since we can know the details of playback state (pause, playing, etc)
    [_audio removeObjectForKey:key];
    player = nil;
}

+ (void)removeAudioForKey:(id)key {
    [[self sharedInstance] removeAudioForKey:key];
}


- (void)fadeIn:(NSTimer *)timer
{
    AVAudioPlayer *player = timer.userInfo;
    float volume = player.volume;
    volume = volume + 1.0 / MCSOUNDBOARD_AUDIO_FADE_STEPS;
    volume = volume > 1.0 ? 1.0 : volume;
    player.volume = volume;
    
    if (volume == 1.0) {
        [timer invalidate];
    }
}

- (void)playAudioForKey:(id)key fadeInInterval:(NSTimeInterval)fadeInInterval
{
    
    if (Key_PlayerBackground != key) {
        //由于Key_PlayerBackground用于保持后台运行，所以这时不能stopLogging，
        if ([NMDecibelLogger defaultLogger].logging) {
            _isNeedToResumeLogging = YES;
            [[NMDecibelLogger defaultLogger] stopLogging];
        } else {
            _isNeedToResumeLogging = NO;
        }
    }
    
    
    
    NSLog(@"%s",__FUNCTION__);
    AVAudioPlayer *player = [_audio objectForKey:key];
    
    // If fade in inteval interval is not 0, schedule fade in
    if (fadeInInterval > 0.0) {
        player.volume = 0.0;
        NSTimeInterval interval = fadeInInterval / MCSOUNDBOARD_AUDIO_FADE_STEPS;
        [NSTimer scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(fadeIn:)
                                       userInfo:player
                                        repeats:YES];
    }
    
    [player play];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:K_Notification_Update_Meter_Play_Status object:self userInfo:@{@"isPlaying":@YES}];
}

+ (void)playAudioForKey:(id)key fadeInInterval:(NSTimeInterval)fadeInInterval
{
    [[self sharedInstance] playAudioForKey:key fadeInInterval:fadeInInterval];
}

+ (void)playAudioForKey:(id)key
{
    [[self sharedInstance] playAudioForKey:key fadeInInterval:0.0];
}


- (void)fadeOutAndStop:(NSTimer *)timer
{
    AVAudioPlayer *player = timer.userInfo;
    float volume = player.volume;
    volume = volume - 1.0 / MCSOUNDBOARD_AUDIO_FADE_STEPS;
    volume = volume < 0.0 ? 0.0 : volume;
    player.volume = volume;
    
    if (volume == 0.0) {
        [timer invalidate];
        [player pause];
    }
}

- (void)stopAudioForKey:(id)key fadeOutInterval:(NSTimeInterval)fadeOutInterval
{
    NSLog(@"%s",__FUNCTION__);
    AVAudioPlayer *player = [_audio objectForKey:key];
    
    // If fade in inteval interval is not 0, schedule fade in
    if (fadeOutInterval > 0) {
        NSTimeInterval interval = fadeOutInterval / MCSOUNDBOARD_AUDIO_FADE_STEPS;
        [NSTimer scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(fadeOutAndStop:)
                                       userInfo:player
                                        repeats:YES];
    } else {
        [player stop];
    }
}

+ (void)stopAudioForKey:(id)key fadeOutInterval:(NSTimeInterval)fadeOutInterval
{
    [[self sharedInstance] stopAudioForKey:key fadeOutInterval:fadeOutInterval];
}

+ (void)stopAudioForKey:(id)key
{
    [[self sharedInstance] stopAudioForKey:key fadeOutInterval:0.0];
}


- (void)fadeOutAndPause:(NSTimer *)timer
{
    AVAudioPlayer *player = timer.userInfo;
    float volume = player.volume;
    volume = volume - 1.0 / MCSOUNDBOARD_AUDIO_FADE_STEPS;
    volume = volume < 0.0 ? 0.0 : volume;
    player.volume = volume;
    
    if (volume == 0.0) {
        [timer invalidate];
        [player stop];
    }
    
    if (_isNeedToResumeLogging) {
        [[NMDecibelLogger defaultLogger] stopLogging];
    }
}

- (void)pauseAudioForKey:(id)key fadeOutInterval:(NSTimeInterval)fadeOutInterval
{
    AVAudioPlayer *player = [_audio objectForKey:key];
    
    // If fade in inteval interval is not 0, schedule fade in
    if (fadeOutInterval > 0) {
        NSTimeInterval interval = fadeOutInterval / MCSOUNDBOARD_AUDIO_FADE_STEPS;
        [NSTimer scheduledTimerWithTimeInterval:interval
                                         target:self
                                       selector:@selector(fadeOutAndPause:)
                                       userInfo:player
                                        repeats:YES];
    } else {
        [player pause];
        
        if (_isNeedToResumeLogging) {
            [[NMDecibelLogger defaultLogger] stopLogging];
        }
    }
}


+ (void)pauseAudioForKey:(id)key fadeOutInterval:(NSTimeInterval)fadeOutInterval
{
    NSLog(@"%s",__FUNCTION__);
    [[self sharedInstance] pauseAudioForKey:key fadeOutInterval:fadeOutInterval];
}

+ (void)pauseAudioForKey:(id)key
{
    [[self sharedInstance] pauseAudioForKey:key fadeOutInterval:0.0];
}


- (AVAudioPlayer *)audioPlayerForKey:(id)key
{
    return [_audio objectForKey:key];
}

+ (AVAudioPlayer *)audioPlayerForKey:(id)key
{
    return [[self sharedInstance] audioPlayerForKey:key];
}

#pragma mark – Utilities

/**
 *  Reset audio output route speaker or headset
 */
+ (void) resetAudioRoute:(BOOL) isHeadsetOutput {
    NSLog(@"%s",__FUNCTION__);
    BOOL success = FALSE;
    NSError *error;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        
        if (isHeadsetOutput) {
            success = [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:&error];
        } else {
            success = [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        }
        
        if (!success)  {
            NSLog(@"%s:AVAudioSession error overrideOutputAudioPort %@",__FUNCTION__,error);
        }
    } else {
        UInt32 audioRouteOverride;
        
        if (isHeadsetOutput) {
            audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
        } else {
            audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
        }
        
        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
    }
}

+ (int) lengthOfAudioFile:(NSURL *) url {
    AudioFileID audioFileID;
    AudioFileOpenURL((__bridge CFURLRef)url, kAudioFileReadPermission, 0, &audioFileID);
    NSTimeInterval seconds;
    UInt32 propertySize = sizeof(seconds);
    OSStatus st = AudioFileGetProperty(audioFileID, kAudioFilePropertyEstimatedDuration, &propertySize, &seconds);
    if (st == 0) {
        NSLog(@"%s: length of audio file is %f (seconds)",__FUNCTION__,seconds);
        return seconds;
    } else {
        NSLog(@"%s:Error to get the length of audio file",__FUNCTION__);
        return 0;
    }
}

#pragma mark – AVAudioPlayer notification
/**
 *  如果player.numberOfLoops = -1，则不会执行到这里到这里
 *  如果执行了player stop]，也会执行到这里
 *  这个方法会将player置成nil,以快速回收资源
 */
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"%s",__FUNCTION__);
    EnumSoundType soundType = [objc_getAssociatedObject(player, SoundTypeKey) integerValue];
    player.delegate = nil;
    player = nil;
    if ([self.IDPDelegate respondsToSelector:@selector(didFinishSoundPlay:)]) {
        [self.IDPDelegate didFinishSoundPlay:soundType];
    } else {
        NSLog(@"%s:self.IDPDelegate can not respondsToSelector of didFinishSoundPlay",__FUNCTION__);
    }
    
    if (_isNeedToResumeLogging) {
        [[NMDecibelLogger defaultLogger] startLogging];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:K_Notification_Update_Meter_Play_Status object:self userInfo:@{@"isPlaying":@NO}];
    
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSLog(@"%s",__FUNCTION__);
    
    if (_isNeedToResumeLogging) {
        [[NMDecibelLogger defaultLogger] startLogging];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:K_Notification_Update_Meter_Play_Status object:self userInfo:@{@"isPlaying":@NO}];
    
}




#pragma mark – Memory management
- (void)dealloc {
    NSLog(@"%s",__FUNCTION__);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark – save last 10 second recorded

static void checkError(OSStatus err,const char *message){
    if(err){
        char property[5];
        *(UInt32 *)property = CFSwapInt32HostToBig(err);
        property[4] = '\0';
        NSLog(@"%s = %-4.4s,%d",message, property,(int)err);
        exit(1);
    }
}

+ (void)saveLast10SecondAudio:(NSURL*)fromURL
                        toURL:(NSURL*)toURL
{
    NSLog(@"%s",__FUNCTION__);
    
    //step1: set outputFormat, etc
    AudioStreamBasicDescription outputFormat;
    outputFormat.mSampleRate         = 22050.0;
    outputFormat.mFormatID                        = kAudioFormatLinearPCM;
    outputFormat.mFormatFlags                = kAudioFormatFlagIsBigEndian
    | kLinearPCMFormatFlagIsSignedInteger
    | kLinearPCMFormatFlagIsPacked;
    outputFormat.mFramesPerPacket        = 1;
    outputFormat.mChannelsPerFrame        = 2;
    outputFormat.mBitsPerChannel    = 16;
    outputFormat.mBytesPerPacket    = 4;
    outputFormat.mBytesPerFrame                = 4;
    outputFormat.mReserved                        = 0;
    
    
    OSStatus err;
    ExtAudioFileRef infile,outfile;
    
    err = ExtAudioFileOpenURL((__bridge CFURLRef)fromURL, &infile);
    checkError(err,"ExtAudioFileOpenURL");
    
    err = ExtAudioFileSetProperty(infile,
                                  kExtAudioFileProperty_ClientDataFormat,
                                  sizeof(AudioStreamBasicDescription),
                                  &outputFormat);
    checkError(err,"ExtAudioFileSetProperty");
    
    err = ExtAudioFileCreateWithURL((__bridge CFURLRef)toURL,
                                    kAudioFileAIFFType,//AIFFで保存する
                                    &outputFormat,
                                    NULL,
                                    kAudioFileFlags_EraseFile,
                                    &outfile);
    checkError(err,"ExtAudioFileCreateWithURL");
    
    //step2: seak position
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:fromURL options:nil];
    double duration = CMTimeGetSeconds(songAsset.duration);
    
    long seekStart = 0;
    if (duration >= 10) {
        seekStart = (duration - 10) *44100; //sampling rate
    }
    
    err = ExtAudioFileSeek(infile, seekStart); //从seakStart开始
    checkError(err,"ExtAudioFileSeek");
    
    UInt32 readFrameSize = 1024;
    
    UInt32 bufferSize = sizeof(char) * readFrameSize * outputFormat.mBytesPerPacket;
    char *buffer = malloc(bufferSize);
    
    AudioBufferList audioBufferList;
    audioBufferList.mNumberBuffers = 1;
    audioBufferList.mBuffers[0].mNumberChannels = outputFormat.mChannelsPerFrame;
    audioBufferList.mBuffers[0].mDataByteSize = bufferSize;
    audioBufferList.mBuffers[0].mData = buffer;
    
    while(1){
        readFrameSize = 1024;
        err = ExtAudioFileRead(infile, &readFrameSize, &audioBufferList);
        checkError(err,"ExtAudioFileRead");
        
        if(readFrameSize == 0)break;
        
        err = ExtAudioFileWrite(outfile,
                                readFrameSize,
                                &audioBufferList);
        checkError(err,"ExtAudioFileWrite");
    }
    
    ExtAudioFileDispose(infile);
    ExtAudioFileDispose(outfile);
    free(buffer);
}

#pragma mark – Background running service

/**
 *  使用场合：仅在后台时被激活（前台不被激活）
 *  1. 当在前台时，通过timerFire，对_currentReading进行更新，从而实现KVO
 *  2. 在后台时，如果没有音乐播放，则timerFire无法执行。通过runBackgroundSound实现Mute音乐的背景loop播放，从而保持代码一直处于活跃状态，_currentReading的更新也是通过timerFire
 */
- (void) runBackgroundSound {
    
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    AVAudioPlayer *player = [IDPSoundBoard audioPlayerForKey:Key_PlayerBackground];
    if (player == nil) {
        //choose demo.mpe (mute) or loop.mpe (non-mute)
        [IDPSoundBoard addAudioAtPath:[[NSBundle mainBundle] pathForResource:@"demo.mp3" ofType:nil] forKey:Key_PlayerBackground forType:EnumSoundType_Background];
        player = [IDPSoundBoard audioPlayerForKey:Key_PlayerBackground];
        player.numberOfLoops = -1;  // Endless
        
    }
    
    if ([player isPlaying]) {
        NSLog(@"%s:Already background running",__FUNCTION__);
    } else {
        [IDPSoundBoard playAudioForKey:Key_PlayerBackground fadeInInterval:2.0];
        NSLog(@"%s:Begin background running",__FUNCTION__);
    }
    
    //    });
    
}

+ (void) runBackgroundSound {
    [[self sharedInstance] runBackgroundSound];
}


- (void) stopBackgroundSoundRunning {
    NSLog(@"%s",__FUNCTION__);
    [_backgroundRunningTimer invalidate];
    _backgroundRunningTimer = nil; //确保被nil
    [self removeAudioForKey:Key_PlayerBackground]; //if not stop, will stop automatically
    
}

+ (void) stopBackgroundSoundRunning {
    [[self sharedInstance] stopBackgroundSoundRunning];
}




@end
