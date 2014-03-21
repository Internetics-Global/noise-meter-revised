
//
//  IDPSoundBoard.h
//  NoiseMeter
//
//  Created by Bourne Wang on 14-02-21.
//  Copyright (c) 2013年 Internetics Pty Ltd. All rights reserved.
//

//  All audio related methods are included here except record
//  1. playback:  alarm, recorded, background, new created sound
//  2. save last 10 seconds sound

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

const static NSString *Key_PlayerBackground    = @"Key_PlayerBackground";
const static NSString *Key_PlayerAlarm         = @"Key_PlayerAlarm";
const static NSString *Key_PlayerNewCreated    = @"Key_PlayerNewCreated";
const static NSString *Key_PlayerRecorded      = @"Key_PlayerRecorded";
const static NSString *Key_PlayerBabyAirplay   = @"Key_PlayerBabyAirplay";

typedef NS_ENUM(NSInteger, EnumSoundType)
{
    EnumSoundType_Background = 0, //background sound which is always running
    EnumSoundType_Alarm = 1, // used to play alarm
    EnumSoundType_NewCreated = 2, //the sound that is created as a custom alarm
    EnumSoundType_Recorded = 3, //recorded sound
    EnumSoundType_BabyAirplay = 4 //baby monitor function only
};

@protocol IDPSoundBoardDelegate <NSObject>

- (void)didFinishSoundPlay:(EnumSoundType) soundType;

@end

@interface IDPSoundBoard : NSObject <AVAudioPlayerDelegate> {
    NSTimer *_backgroundRunningTimer;
}

@property (nonatomic, assign) id<IDPSoundBoardDelegate> IDPDelegate;

+ (IDPSoundBoard *)sharedInstance;

#pragma mark – System Sound

+ (void)addSoundAtPath:(NSString *)filePath forKey:(id)key;
+ (void)playSoundForKey:(id)key;

#pragma mark – Audio

+ (void)addAudioAtPath:(NSString *)filePath forKey:(id)key forType:(EnumSoundType) soundType;

/**
 *  if playing, stop first.
 */
+ (void)removeAudioForKey:(id)key;

+ (void)playAudioForKey:(id)key fadeInInterval:(NSTimeInterval)fadeInInterval;
+ (void)playAudioForKey:(id)key;

+ (void)stopAudioForKey:(id)key fadeOutInterval:(NSTimeInterval)fadeOutInterval;
+ (void)stopAudioForKey:(id)key;

+ (void)pauseAudioForKey:(id)key fadeOutInterval:(NSTimeInterval)fadeOutInterval;
+ (void)pauseAudioForKey:(id)key;

/**
 *  Alert: As long as the sound play finished, the instance of AVAudioPlayer will be set to nil
 */
+ (AVAudioPlayer *)audioPlayerForKey:(id)key;

#pragma mark – Utilities

+ (void) resetAudioRoute:(BOOL) isHeadsetOutput;

/**
 *  Seconds that the audio file could play
 */
+ (int) lengthOfAudioFile:(NSURL *) url;

#pragma mark – save last 10 second recorded 

+ (void)saveLast10SecondAudio:(NSURL*)fromURL
                        toURL:(NSURL*)toURL;

#pragma mark – Background running service

/**
 *  Keep running in background to keep alive during background running
 *  该方法内部保证background的音频播放只有一个，即即便多次运行这个方法，也只能实现一个background播放
 */
+ (void) runBackgroundSound;

/**
 *  1. stop the player
 *  2. set player = nil, make sure the resource is free
 */
+ (void) stopBackgroundSoundRunning;

@end
