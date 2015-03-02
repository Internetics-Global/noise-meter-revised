//
//  SoundLevelView.m
//  NoiseMeter
//
//  Created by Bourne Wang on 14-2-5.
//  Copyright (c) 2014年 Internetics Pty Ltd. All rights reserved.
//

#import "SoundLevelView.h"
#import "NMDecibelLogger.h"

@interface SoundLevelView () {
    UIImageView *_meterImageView;
}

@end

@implementation SoundLevelView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}


- (void) setupSubviews {
    
    self.MIN_LEVEL = kMinSoundLevel;
    self.MAX_LEVEL = kMaxSoundLevel;
    
    _meterImageView = [[UIImageView alloc] init];
    [_meterImageView setContentMode:UIViewContentModeScaleAspectFill];
    _meterImageView.autoresizingMask = UIViewAutoresizingNone;
    _meterImageView.backgroundColor = [UIColor clearColor];
    _meterImageView.frame = self.bounds;
    _meterImageView.tag = -1;
    [self addSubview:_meterImageView];
    
    [self refreshMeterImageView];
    
    float width = CGRectGetWidth(self.bounds)/kNumberSlices;
    
    for (int i = 1; i <= kNumberSlices; i++) {
        UIView *overlapView = [[UIView alloc] initWithFrame:CGRectMake(width *(i-1), 0, width, CGRectGetWidth(self.bounds))];
        overlapView.tag = i - 1;
        //[overlapView setBackgroundColor:kMeterOverlapColor];
        [overlapView setBackgroundColor:[UIColor colorWithRed:55.0/255 green:55.0/255 blue:55.0/255 alpha:0.9]];
        [self addSubview:overlapView];
        overlapView.hidden = YES;
    }
}

- (void) setSoundLevelValue:(float) val withMaxLevel:(int) maxAllowedSoundLevel {
    
    if (val > maxAllowedSoundLevel) {
        val = self.MAX_LEVEL;
    }
    
    if (val < self.MIN_LEVEL) {
        val = self.MIN_LEVEL;
    }
    
    float inteval = (maxAllowedSoundLevel - self.MIN_LEVEL)/kNumberSlices;
    int no = (val - self.MIN_LEVEL)/inteval;
   
    NSMutableArray *overlapArray = [NSMutableArray array];
    for (UIView *myView in self.subviews) {
        if (myView.tag != -1) {
            [overlapArray addObject:myView];
        }
    }
    
    if (no > [overlapArray count]) {
        no = [overlapArray count];
    }
    
    for (int i = 0; i< kNumberSlices; i++) {
        [overlapArray[i] setHidden:NO];
    }
    
    for (int i = 0; i< no; i++) {
        [overlapArray[i] setHidden:YES];
    }
    
}

/**
 *  Update image
 */
- (void) refreshMeterImageView {
    
    MeterDisplayType meterDisplayType = [NSUserDefaultsHelper meterDisplayType];
    if (meterDisplayType == MeterDisplayType_Circle) {
        [_meterImageView setImage:[UIImage imageNamed:@"bars_circle"]];
    } else if (meterDisplayType == MeterDisplayType_Rectangle) {
        [_meterImageView setImage:[UIImage imageNamed:@"bars_square"]];
    } else if (meterDisplayType == MeterDisplayType_Triangle) {
        [_meterImageView setImage:[UIImage imageNamed:@"bars_triangle"]];
        
    }
    
}




@end
