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
#import "UIButton+Extensions.h"

#import "AMPopTip.h"


@interface ScoreView () <MFMailComposeViewControllerDelegate,SWTableViewCellDelegate> {
    ScoreArrayDataSource *_scoreArrayDataSource;
    
    AMPopTip *_popTipShare;
    AMPopTip *_popTipReset;
    AMPopTip *_popTipEmpty;
    AMPopTip *_popTipMail;
    AMPopTip *_popTipSound;
}


@end

@implementation ScoreView

#pragma mark – Life Cycle

- (NSString *)iconImageName {
    return @"icon_scores";
}

- (id)init
{
    self = [super init];
    self.title = @"Scores";
    self.tabBarItem.image = [UIImage imageNamed:@"icon_scores.png"];
    
    return self;
}

- (void)reloadData
{
    _scores = [SoundLevelCapture sortedScoreArrayByDate];
    [_scoreTable reloadData];
}

- (void)loadView
{
    [super loadView];
    
    [self style:NO];
    
    _infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_infoButton setImage:[UIImage imageNamed:@"button_info.png"] forState:UIControlStateNormal];
    _infoButton.frame = CGRectMake(self.view.frame.size.width - 35, 18, 20, 20);
    [_infoButton addTarget:self action:@selector(switchTips) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_infoButton];
    [_infoButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    
    _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_moreButton setImage:[UIImage imageNamed:@"icon_more.png"] forState:UIControlStateNormal];
    _moreButton.frame = CGRectMake(15, 18, 20, 20);
    [_moreButton addTarget:self action:@selector(moreButtonCLicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_moreButton];
    [_moreButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    
    _tableHeader = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_logo_scores.png"]];
    _tableHeader.frame = CGRectMake(0, KTopLogoHeight, CGRectGetWidth(self.view.frame), 40);
    _tableHeader.contentMode = UIViewContentModeScaleAspectFit;
    _tableHeader.backgroundColor =[UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1];
    [self.view addSubview:_tableHeader];
    
    _resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_resetButton setImage:[UIImage imageNamed:@"button_reset.png"] forState:UIControlStateNormal];
    [_resetButton addTarget:self action:@selector(resetButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    _resetButton.frame = CGRectMake(self.view.frame.size.width- 80, CGRectGetMaxY(_tableHeader.frame) + 5, 73, 29);
    [self.view addSubview:_resetButton];
    

    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareButton setImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];
        _shareButton.frame = CGRectMake(5, CGRectGetMinY(_resetButton.frame), 89, 29);
        [_shareButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_shareButton];
    }
    
    
    _scoreTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_resetButton.frame) + 5, self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(_resetButton.frame) ) style:UITableViewStylePlain];
    
    
    _scoreTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scoreTable.backgroundView = nil;
    _scoreTable.separatorColor = [UIColor clearColor];
    _scoreTable.backgroundColor = kGrayColor;
    _scoreTable.opaque = YES;
    
    __weak __typeof(&*self)weakSelf = self;
    _scoreArrayDataSource = [[ScoreArrayDataSource alloc] initWithReloadTableBlock:^() {
        [weakSelf reloadData];
    }];
    _scoreArrayDataSource.sortedByDate = YES;
    _scoreTable.dataSource = _scoreArrayDataSource;
    [self reloadData];
    
    _scoreTable.delegate= self;
    [self.view addSubview:_scoreTable];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:K_Notification_Sound_Captured object:nil];
    
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:K_Notification_Sound_Captured object:nil];
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
    
}


#pragma mark – Tableview datasource and delegate


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
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
        [[NSNotificationCenter defaultCenter] postNotificationName:K_Notification_Sound_Captured object:nil];
        [[NMDataManager defaultManager] saveContext];
        
        [FileHelper removeAllExceptTempCafFile];
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset all recordings" message:@"Are you sure you want to reset? You will lose all your recordings." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
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
    
    if ([NSUserDefaultsHelper isProClassRoomVersion]) {
        _fullScrenshotImage = [ShareHelper fullScreenshot];
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
                                @"Share on Facebook",
                                @"Share on Twitter",
                                
                                nil];
        popup.tag = 1;
        [popup showInView:[UIApplication sharedApplication].keyWindow];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"This is a Noise Down CLASSROOM function" message:@"You can upgrade the app to get it!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    __weak __typeof(&*self)weakSelf = self;
    
    if (buttonIndex == 0) {
        [ShareHelper postToFacebook:weakSelf withImage:_fullScrenshotImage withMsg:@"How noisy! This noisy! \nSent from noise control app Noise Down! (http://tinyurl.com/nejj2gv)"];
    } else if (buttonIndex == 1) {
        [ShareHelper postToTwitter:weakSelf withImage:_fullScrenshotImage withMsg:@"How noisy! This noisy! \nSent from noise control app Noise Down! (http://tinyurl.com/nejj2gv)"];
    }
}

- (void) moreButtonCLicked {
    //    MoreView *moreViewController = [[MoreView alloc] initWithNibName:nil bundle:nil];
    //    [self.navigationController pushViewController:moreViewController animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:K_Notification_Show_Left_Setting_View object:nil userInfo:nil];
    
}

#pragma mark – Tooltip

- (void) switchTips {
    
    if ((_popTipShare.isVisible) || (_popTipReset.isVisible) || (_popTipEmpty.isVisible) || (_popTipMail.isVisible) || (_popTipSound.isVisible)) {
        [self hideTips];
    } else {
        [self showTips];
    }
}

- (void) hideTips {
    [_popTipShare hide];
    [_popTipReset hide];
    [_popTipEmpty hide];
    [_popTipMail hide];
    [_popTipSound hide];
}

- (void) showTips {
    
    __weak __typeof(&*self)weakSelf = self;
    
    if (_popTipShare == nil) {
        _popTipShare = [AMPopTip popTip];
        _popTipShare.textColor = [UIColor darkGrayColor];
        _popTipShare.arrowSize = CGSizeMake(8, 120);
        _popTipShare.popoverColor = [UIColor greenColor];
        _popTipShare.shouldDismissOnTap = YES;
        _popTipShare.shouldDismissOnTapOutside = NO;
        _popTipShare.dismissHandler = ^() {
            
        };
    }
    [_popTipShare showText:@"Share your Noise League on social media" direction:AMPopTipDirectionDown maxWidth:160 inView:self.view fromFrame:CGRectMake(_shareButton.center.x + 5, _shareButton.center.y, 0, 0) duration:0];
    
    if (_popTipReset == nil) {
        _popTipReset = [AMPopTip popTip];
        _popTipReset.textColor = [UIColor darkGrayColor];
        _popTipReset.arrowSize = CGSizeMake(8, 160);
        _popTipReset.popoverColor = [UIColor greenColor];
        _popTipReset.shouldDismissOnTap = YES;
        _popTipReset.shouldDismissOnTapOutside = NO;
        _popTipReset.dismissHandler = ^() {
            
        };
    }
    [_popTipReset showText:@"Reset this list" direction:AMPopTipDirectionDown maxWidth:180 inView:self.view fromFrame:CGRectMake(_resetButton.center.x, _resetButton.center.y, 0, 0) duration:0];
    
    
    if (_popTipMail == nil) {
        _popTipMail = [AMPopTip popTip];
        _popTipMail.textColor = [UIColor darkGrayColor];
        _popTipMail.arrowSize = CGSizeMake(8, 20);
        _popTipMail.popoverColor = [UIColor greenColor];
        _popTipMail.shouldDismissOnTap = YES;
        _popTipMail.shouldDismissOnTapOutside = NO;
        _popTipMail.dismissHandler = ^() {
            
        };
    }
    if ([_scores count] == 0) {
        [_popTipMail hide];
    } else {
        [_popTipMail showText:@"Email individual recordings" direction:AMPopTipDirectionDown maxWidth:110 inView:self.view fromFrame:CGRectMake(CGRectGetMidX(_scoreTable.frame) - 28,CGRectGetMinY(_scoreTable.frame) + 20, 0, 0) duration:0];
    }
    
    if (_popTipSound == nil) {
        _popTipSound = [AMPopTip popTip];
        _popTipSound.textColor = [UIColor darkGrayColor];
        _popTipSound.arrowSize = CGSizeMake(8, 20);
        _popTipSound.popoverColor = [UIColor greenColor];
        _popTipSound.shouldDismissOnTap = YES;
        _popTipSound.shouldDismissOnTapOutside = NO;
        _popTipSound.dismissHandler = ^() {
            
        };
    }
    if ([_scores count] == 0) {
        [_popTipSound hide];
    } else {
        [_popTipSound showText:@"Play recordings" direction:AMPopTipDirectionUp maxWidth:180 inView:self.view fromFrame:CGRectMake(CGRectGetMidX(_scoreTable.frame),CGRectGetMinY(_scoreTable.frame) + 20, 0, 0) duration:0];
    }
    
    if (_popTipEmpty == nil) {
        _popTipEmpty = [AMPopTip popTip];
        _popTipEmpty.textColor = [UIColor darkGrayColor];
        _popTipEmpty.arrowSize = CGSizeZero;
        _popTipEmpty.popoverColor = [UIColor greenColor];
        _popTipEmpty.shouldDismissOnTap = YES;
        _popTipEmpty.shouldDismissOnTapOutside = NO;
        _popTipEmpty.dismissHandler = ^() {
            
        };
    }
    if ([_scores count] == 0) {
        [_popTipEmpty showText:@"When you save noise recordings they will appear here in list form." direction:AMPopTipDirectionUp maxWidth:180 inView:self.view fromFrame:CGRectMake(_scoreTable.center.x, CGRectGetMinY(_scoreTable.frame) + 80, 0, 0) duration:0];
    } else {
        [_popTipEmpty hide];
    }
    
}

@end
