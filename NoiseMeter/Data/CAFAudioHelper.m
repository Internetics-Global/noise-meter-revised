//
//  CAFAudioHelper.m
//  NoiseMeter
//
//  Created by Bourne Wang on 14-1-30.
//  Copyright (c) 2014年 Internetics Pty Ltd. All rights reserved.
//

#import "CAFAudioHelper.h"

#import <AVFoundation/AVFoundation.h>

@implementation CAFAudioHelper


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


@end
