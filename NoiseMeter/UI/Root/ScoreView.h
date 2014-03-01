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

@interface ScoreView : BaseViewController<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,IDPSoundBoardDelegate>{
    UITableView *_scoreTable;
    UIImageView *_meterBackground;
    NSArray *_scores;
    UIButton *_resetButton;
    UIImageView *_tableHeader;
    
    int  _playingIndex;
}

@end
