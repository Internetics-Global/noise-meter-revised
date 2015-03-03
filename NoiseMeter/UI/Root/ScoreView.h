//
//  ScoreView.h
//  NoiseMeter
//
//  Created by Dave Finster on 6/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import "IDPSoundBoard.h"

@interface ScoreView : BaseViewController<UITableViewDelegate,UIAlertViewDelegate,IDPSoundBoardDelegate,UIActionSheetDelegate>{
    UITableView * _scoreTable;
    UIImageView * _meterBackground;
    NSArray     * _scores;
    UIButton    * _resetButton;
    UIButton    * _shareButton;
    UIImageView * _tableHeader;

    int              _playingIndex;

    UIImage        * _fullScrenshotImage;
    UIButton       * _moreButton;
}

@end
