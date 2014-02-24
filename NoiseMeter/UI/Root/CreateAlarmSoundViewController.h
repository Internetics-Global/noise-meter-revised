//
//  CreateAlarmSoundViewController.h
//  NoiseMeter
//
//  Created by Bourne Wang on 14-2-13.
//  Copyright (c) 2014年 Internetics Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMDecibelLogger.h"

@interface CreateAlarmSoundViewController : UIViewController

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *startButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *playButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *saveButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *alertLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *dismissButton;
@end
