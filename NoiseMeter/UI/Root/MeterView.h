//
//  MeterView.h
//  NoiseMeter
//
//  Created by Dave Finster on 6/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import <iAd/iAd.h>
#import "SoundLevelView.h"

@interface MeterView : BaseViewController<UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate>{
    UIImageView *_meterBackground;
    UILabel *_currentReadingLabel;
    UITableView *_topScoreTable;
    NSArray *_scores;
    UIButton *_captureButton;
    UIView *_headerView;
    NSNumber *_currentReading;
    UIImageView *_formBackground;
    NSNumber *_peakReading;
    UILabel *_peakLabel;
    UILabel *_titleLabel;
    UIButton *_infoButton;
    UIButton *_cancelButton;
    
    SoundLevelView *_soundLevelView;
}

@end
