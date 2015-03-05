//
//  ScoreView.h
//  NoiseMeter
//
//  Created by Dave Finster on 6/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDPSoundBoard.h"

@interface ScoreView : BaseViewController<UITableViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate>{
    UITableView * _scoreTable;
    UIImageView * _meterBackground;
    NSArray     * _scores;
    UIButton    * _resetButton;
    UIButton    * _shareButton;
    UIImageView * _tableHeader;

    UIImage        * _fullScrenshotImage;
    UIButton       * _moreButton;
    UIButton       * _infoButton;
}

@end
