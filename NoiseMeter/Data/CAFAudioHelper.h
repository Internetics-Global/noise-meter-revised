//
//  CAFAudioHelper.h
//  NoiseMeter
//
//  Created by Bourne Wang on 14-1-30.
//  Copyright (c) 2014年 Internetics Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CAFAudioHelper : NSObject

+ (void)saveLast10SecondAudio:(NSURL*)fromURL
                        toURL:(NSURL*)toURL;

@end
