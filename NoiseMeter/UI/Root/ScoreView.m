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

@interface ScoreView ()

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
    _scores = [SoundLevelCapture all];
    NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"soundLevel" ascending:NO];
    _scores = [_scores sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
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
    
    _scoreTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _scoreTable.backgroundView = nil;
    _scoreTable.separatorColor = [UIColor colorWithRed:0.152 green:0.156 blue:0.164 alpha:1.0];
    _scoreTable.backgroundColor = [UIColor clearColor];
    _scoreTable.opaque = YES;
    _scoreTable.dataSource = self;
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
    self.trackedViewName = @"ScoreView Screen";
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NMDecibelLogger defaultLogger] startLogging];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_scores count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SoundLevelCaptureCell *cell = (SoundLevelCaptureCell *)[tableView dequeueReusableCellWithIdentifier:@"Sound"];
    if (cell == nil) {
        cell = [[SoundLevelCaptureCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Sound"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell refreshPlayImageViewVisibility];
    cell.capture = [_scores objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    
    
    cell.playImageView.tag = indexPath.row;
    UITapGestureRecognizer *singTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playRecordedSound:)];
    singTapGesture.numberOfTapsRequired = 1;
    singTapGesture.numberOfTouchesRequired = 1;
    [cell.playImageView addGestureRecognizer:singTapGesture];
    
    if (_playingIndex == indexPath.row) {
        NSMutableArray* imagesArray = [NSMutableArray arrayWithCapacity:3];
        for (int i = 0; 4 > i; ++i) {
            [imagesArray addObject:[UIImage imageNamed:[NSString stringWithFormat:@"soundOnButton%d", i]]];
        }
        cell.playImageView.animationImages = imagesArray;
        cell.playImageView.animationDuration = 0.9;
        cell.playImageView.animationRepeatCount = 0;
        [cell.playImageView startAnimating];
    } else {
        [cell.playImageView setImage:[UIImage imageNamed:@"soundOnButton2"]];
    }
    
    return cell;
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

#pragma mark – IBAction related

- (void) playRecordedSound: (UITapGestureRecognizer *) gesture {
    
    _playingIndex = ((UIButton *) [gesture view]).tag;
    
    [_scoreTable reloadData];
    
    SoundLevelCapture *caputure = [_scores objectAtIndex:_playingIndex];
    
    NSDate *date = caputure.date;
	NSString *dateString = [FileHelper convertDate:date];
    
    NSURL *url = [FileHelper getRecordedAudioFile:dateString];
    
    [IDPSoundBoard addAudioAtPath:[url path] forKey:Key_PlayerRecorded forType:EnumSoundType_Recorded];
    AVAudioPlayer *player = [IDPSoundBoard audioPlayerForKey:Key_PlayerRecorded];
    player.numberOfLoops = 0;  // Endless
    [IDPSoundBoard sharedInstance].IDPDelegate = self;
    [IDPSoundBoard playAudioForKey:Key_PlayerRecorded fadeInInterval:2.0];
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Are you sure you want to reset?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
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


@end
