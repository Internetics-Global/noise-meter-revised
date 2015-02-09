//
//  SoundLevelCaptureCell.h
//  NoiseMeter
//
//  Created by Dave Finster on 13/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundLevelCapture.h"

@interface SoundLevelCaptureCell : UITableViewCell{
    SoundLevelCapture *_capture;
    UILabel *_nameLabel;
    UILabel *_levelLabel;
    UILabel *_dateLabel;
}

@property (nonatomic, strong) SoundLevelCapture *capture;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIButton *shareButton;

@end
