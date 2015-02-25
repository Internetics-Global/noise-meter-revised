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
#import "IDPSoundBoard.h"

@interface MeterView : BaseViewController<UITableViewDelegate,UIAlertViewDelegate>{
    UIView         * _meterBackground;
    
    UILabel        * _currentReadingLabel;
    UIView         * _currentReadingBaseView;
    UILabel        * _currentReadingDesLabel;
    
    NSNumber       * _peakReading;
    UILabel        * _peakLabel;
    UIView         * _peakBaseView;
    UILabel        * _peakDesLabel;
    
    UITableView    * _topScoreTable;
    NSArray        * _scores;
    UIButton       * _captureButton;
    NSNumber       * _currentReading;
    UIImageView    * _formBackground;
    
    UILabel        * _titleLabel;
    UIButton       * _infoButton;
    UIButton       * _moreButton;
    UIButton       * _cancelButton;
    
    SoundLevelView * _soundLevelView;
    
    UIImageView    * _overlayImageView;
}


@end
