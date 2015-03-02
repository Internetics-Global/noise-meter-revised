//
//  AlertViewV2.h
//  NoiseMeter
//
//  Created by Bourne Wang on 2/03/2015.
//  Copyright (c) 2015 Internetics Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import "SoundLevelView.h"

@interface AlertViewV2 : BaseViewController{
    UIButton       * _setButton;
    SoundLevelView * _soundLevelView;
    UISlider       *_slider;
}



@end
