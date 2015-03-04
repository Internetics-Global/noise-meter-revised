//
//  AlertViewV2.h
//  NoiseMeter
//
//  Created by Bourne Wang on 2/03/2015.
//  Copyright (c) 2015 Internetics Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundLevelView.h"

@interface AlertViewV2 : BaseViewController{
    UIButton       * _setButton;
    SoundLevelView * _soundLevelView;
    UISlider       *_slider;
    UILabel        *_sliderAttachedLabel;
    UIButton       * _moreButton;
    UIButton       * _infoButton;
}



@end
