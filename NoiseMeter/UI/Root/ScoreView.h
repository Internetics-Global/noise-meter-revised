//
//  ScoreView.h
//  NoiseMeter
//
//  Created by Dave Finster on 6/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface ScoreView : GAITrackedViewController<UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate>{
    UITableView *_scoreTable;
    UIImageView *_meterBackground;
    NSArray *_scores;
    UIButton *_resetButton;
    UIImageView *_tableHeader;
}

@end
