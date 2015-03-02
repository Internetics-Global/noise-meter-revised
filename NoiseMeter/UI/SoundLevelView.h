//
//  SoundLevelView.h
//  NoiseMeter
//
//  Created by Bourne Wang on 14-2-5.
//  Copyright (c) 2014年 Internetics Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kMinSoundLevel 30
#define kMaxSoundLevel 120

@interface SoundLevelView : UIView

@property (assign, nonatomic) int MIN_LEVEL;
@property (assign, nonatomic) int MAX_LEVEL;

//仅用于overlapp的颜色区分
@property (assign, nonatomic) BOOL isForMeterView;

- (void) setupSubviews;
- (void) setSoundLevelValue:(float) val withMaxLevel:(int) maxAllowedSoundLevel;

- (void) refreshMeterImageView;

@end
