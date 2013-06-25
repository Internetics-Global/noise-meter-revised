//
//  ScoreView.h
//  NoiseMeter
//
//  Created by Dave Finster on 6/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScoreView : UIViewController<UITableViewDelegate, UITableViewDataSource>{
    UITableView *_scoreTable;
    UIImageView *_meterBackground;
    NSArray *_scores;
    UIButton *_resetButton;
    UIImageView *_tableHeader;
}

@end
