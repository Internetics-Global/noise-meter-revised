//
//  SoundLevelView.m
//  NoiseMeter
//
//  Created by Bourne Wang on 14-2-5.
//  Copyright (c) 2014年 Internetics Pty Ltd. All rights reserved.
//

#import "SoundLevelView.h"
#import "NMDecibelLogger.h"

#define kNumberSlices 17.0
//#define kMaxSoundLevel 99
#define kMinSoundLevel 30
#define kSliceInterval 3.0

@implementation SoundLevelView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _maxAllowedSoundLevel = [[NMDecibelLogger defaultLogger] alertThreshold];
    }
    return self;
}


- (void) setupSubviews {
    int maxHeight = CGRectGetHeight(self.frame);
    int width = CGRectGetWidth(self.frame)/kNumberSlices;
    
    for (int i = 1; i <= kNumberSlices; i++) {
        int height = maxHeight * (i/(kNumberSlices + 5)) + 25;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(width *(i-1), (maxHeight - height), width - kSliceInterval, height)];
        NSString *fileName = [NSString stringWithFormat:@"%d.png",i];
        [imageView setImage:[UIImage imageNamed:fileName]];
        imageView.tag = i - 1;
        [imageView setBackgroundColor:[UIColor clearColor]];
        [imageView setContentMode:UIViewContentModeScaleToFill];
        [self addSubview:imageView];
        imageView.hidden = YES;
    }
}

- (void) setSoundLevelValue:(float) val {
    
    if (val > _maxAllowedSoundLevel) {
        val = _maxAllowedSoundLevel;
    }
    
    if (val < kMinSoundLevel) {
        val = kMinSoundLevel;
    }
    
    float inteval = (_maxAllowedSoundLevel - kMinSoundLevel)/kNumberSlices;
    int no = (val - kMinSoundLevel)/inteval;
    NSArray *myViews = self.subviews;
    
    if (no > [myViews count]) {
        no = [myViews count];
    }
    
    for (int i = 0; i< no; i++) {
      [myViews[i] setHidden:NO];
    }
    
    for (int i = no; i< kNumberSlices; i++) {
      [myViews[i] setHidden:YES];
    }
    
}




@end
