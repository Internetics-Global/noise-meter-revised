//
//  ScoreView.m
//  NoiseMeter
//
//  Created by Dave Finster on 6/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import "ScoreView.h"
#import "NMDataManager.h"
#import "NMDecibelLogger.h"
#import "SoundLevelCapture.h"
#import "SoundLevelCaptureCell.h"
#import <AVFoundation/AVFoundation.h>
#import "FileHelper.h"
#import "IDPSoundBoard.h"
#import "ShareHelper.h"
#import <MessageUI/MessageUI.h>
#import "SWTableViewCell.h"
#import "ScoreArrayDataSource.h"


@interface ScoreView () <MFMailComposeViewControllerDelegate,SWTableViewCellDelegate> {
    ScoreArrayDataSource *_scoreArrayDataSource;
}


@end

@implementation ScoreView

#pragma mark – Life Cycle

- (id)init
{
    self = [super init];
    self.title = @"Scores";
    self.tabBarItem.image = [UIImage imageNamed:@"icon_scores.png"];
    
    return self;
}

- (void)reloadData
{
    _scores = [SoundLevelCapture sortedScoreArray];
    [_scoreTable reloadData];
}

- (void)loadView
{
    [super loadView];
    
    [self style];
    
    _meterBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_count.png"]];
    _meterBackground.frame = CGRectMake(0, 79 + 29, 320, 150);
    _meterBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_meterBackground];
    
    _resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_resetButton setImage:[UIImage imageNamed:@"button_reset.png"] forState:UIControlStateNormal];
    [_resetButton addTarget:self action:@selector(resetButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    _resetButton.frame = CGRectMake(self.view.frame.size.width- 73, 79, 73, 29);
    [self.view addSubview:_resetButton];
    [self reloadData];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        _scoreTable = [[UITableView alloc] initWithFrame:CGRectMake(0, _meterBackground.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - (_meterBackground.frame.origin.y) - 49) style:UITableViewStylePlain];
    } else {
        _scoreTable = [[UITableView alloc] initWithFrame:CGRectMake(0, _meterBackground.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - (_meterBackground.frame.origin.y)) style:UITableViewStylePlain];
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareButton setImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
        _shareButton.frame = CGRectMake(0, CGRectGetMinY(_resetButton.frame), 73, 29);
        [_shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_shareButton];
    }
    
    _scoreTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scoreTable.backgroundView = nil;
    _scoreTable.separatorColor = [UIColor colorWithRed:0.152 green:0.156 blue:0.164 alpha:1.0];
    _scoreTable.backgroundColor = [UIColor clearColor];
    _scoreTable.opaque = YES;
    
    __weak __typeof(&*self)weakSelf = self;
    _scoreArrayDataSource = [[ScoreArrayDataSource alloc] initWithReloadTableBlock:^() {
        [weakSelf reloadData];
    }];
    _scoreTable.dataSource = _scoreArrayDataSource;

    
    _scoreTable.delegate= self;
    [self.view addSubview:_scoreTable];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"SoundCaptured" object:nil];
    
}

- (void) viewDidLoad {
    [super viewDidLoad];
    _playingIndex = -1;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _scoreTable = nil;
    _meterBackground = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SoundCaptured" object:nil];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.screenName = @"ScoreView Screen";
    
    [self reloadData];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NMDecibelLogger defaultLogger] startLogging];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([_scores count] == 0) {
       _shareButton.hidden = YES;
    } else {
        _shareButton.hidden = NO;
    }
}


#pragma mark – Tableview datasource and delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_tableHeader == nil) 
    {
        _tableHeader = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_logo_scores.png"]];
        
    }
    return _tableHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}


#pragma mark – UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        for (int i = 0; i < [_scores count]; i++) {
            [[[_scores objectAtIndex:i] managedObjectContext] deleteObject:[_scores objectAtIndex:i]];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SoundCaptured" object:nil];
        [[NMDataManager defaultManager] saveContext];
        
        [FileHelper removeAllExceptTMPCAF];
    }
}


#pragma mark – IDPSoundBoardDelegate

- (void)didFinishSoundPlay:(EnumSoundType)soundType {
    if (soundType == EnumSoundType_Recorded) {
        _playingIndex = -1;
        [_scoreTable reloadData];
        
    }
}



#pragma mark – IBAction

- (void)resetButtonClicked
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset all recordings" message:@"Are you sure you want to reset? You will lose all recordings." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
    alert.tag = 0;
    [alert show];
    
}

#pragma mark – Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark – Notification

- (void)purchasedFinishedNotification:(NSNotification *)notification {
    
    [super purchasedFinishedNotification:notification];
    [_scoreTable reloadData];
}



#pragma mark – Share action

- (void) share {
    _fullScrenshotImage = [ShareHelper fullScreenshot];
    UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                            @"Share on Facebook",
                            @"Share on Twitter",
                            
                            nil];
    popup.tag = 1;
    [popup showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    __weak __typeof(&*self)weakSelf = self;
    
    if (buttonIndex == 0) {
        [ShareHelper postToFacebook:weakSelf withImage:_fullScrenshotImage withMsg:@"How noisy! This noisy! \nSent from noise control app Noise Down! (http://tinyurl.com/nejj2gv)"];
    } else if (buttonIndex == 1) {
        [ShareHelper postToTwitter:weakSelf withImage:_fullScrenshotImage withMsg:@"How noisy! This noisy! \nSent from noise control app Noise Down! (http://tinyurl.com/nejj2gv)"];
    }
}

@end
