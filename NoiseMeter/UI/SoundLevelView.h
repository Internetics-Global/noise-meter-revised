//
//  SoundLevelView.h
//  NoiseMeter
//
//  Created by Bourne Wang on 14-2-5.
//  Copyright (c) 2014年 Internetics Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SoundLevelView : UIView

- (void) setupSubviews;
- (void) setSoundLevelValue:(float) val;

- (void) refreshMeterImageView;

@end
