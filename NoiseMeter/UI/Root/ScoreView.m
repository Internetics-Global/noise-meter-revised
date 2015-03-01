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
    _scores = [SoundLevelCapture sortedScoreArray];
    [_scoreTable reloadData];
}

- (void)loadView
{
    [super loadView];
    
    [self style:NO];
    
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
    
    
    _scoreTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_resetButton.frame) + 5, self.view.frame.size.width, self.view.frame.size.height - (_meterBackground.frame.origin.y) ) style:UITableViewStylePlain];
    
    
    _scoreTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scoreTable.backgroundView = nil;
    _scoreTable.separatorColor = [UIColor clearColor];
    _scoreTable.backgroundColor = kGrayColor;
    _scoreTable.opaque = YES;
    [self reloadData];
    
    __weak __typeof(&*self)weakSelf = self;
    _scoreArrayDataSource = [[ScoreArrayDataSource alloc] initWithReloadTableBlock:^() {
        [weakSelf reloadData];
    }];
    _scoreTable.dataSource = _scoreArrayDataSource;

    
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

@end
