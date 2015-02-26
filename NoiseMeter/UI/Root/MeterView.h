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
    
    //top left
    UIView         * _currentReadingBaseView;
    UILabel        * _currentReadingLabel;
    UILabel        * _currentReadingDesLabel;
    
    //bottom right
    UIView         * _peakBaseView;
    NSNumber       * _peakReading;
    UILabel        * _peakLabel;
    UILabel        * _peakDesLabel;
    
    //top right
    UIView         * _infoMeterBaseView;
    UILabel        * _infoMeterLabel;
    UILabel        * _infoMeterDesLabel;
    
    //bottom left
    UIView         * _captureMeterBaseView;
    UILabel        * _captureMeterLabel;
    UILabel        * _captureMeterDesLabel;
    UIImageView    * _captureMeterImageView;
    
    UITableView    * _topScoreTable;
    NSArray        * _scores;
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
