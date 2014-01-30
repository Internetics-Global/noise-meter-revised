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

@interface ScoreView ()

@end

@implementation ScoreView

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
    [_resetButton addTarget:self action:@selector(reset) forControlEvents:UIControlEventTouchUpInside];
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
    _scoreTable.delegate = self;
    _scoreTable.dataSource = self;
    [self.view addSubview:_scoreTable];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"SoundCaptured" object:nil];
}

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

- (void)reset
{
    for (int i = 0; i < [_scores count]; i++) {
        [[[_scores objectAtIndex:i] managedObjectContext] deleteObject:[_scores objectAtIndex:i]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SoundCaptured" object:nil];
    [[NMDataManager defaultManager] saveContext];
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
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    cell.capture = [_scores objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:cell.frame];
    backgroundView.backgroundColor = [UIColor orangeColor];
    cell.selectedBackgroundView = backgroundView;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SoundLevelCapture *caputure = [_scores objectAtIndex:indexPath.row];
    
    NSDate *date = caputure.date;
	NSString *dateString = [FileHelper convertDate:date];
    
    NSURL *url = [FileHelper getRecordedAudioFile:dateString];
    [self playAudioFile:url];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    [[NMDecibelLogger defaultLogger] stopLogging];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void) playAudioFile:(NSURL *) url {
    
    //play audio function need to be purchased
//    BOOL flag = [[NSUserDefaults standardUserDefaults] boolForKey:@"AD_REMOVED"];
//    flag = TRUE;
//    if (flag == FALSE) {
//        return;
//    }
    
    if (url == nil) {
        NSLog(@"%s:missing audio file",__FUNCTION__);
        [[[UIAlertView alloc] initWithTitle:@"Alert" message:@"No recorded audio file" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]
         show];
        return;
    }
    
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"only_run_once"]) {
        [[[UIAlertView alloc] initWithTitle:@"Alert" message:@"Playback 10 seconds before alarming" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]
         show];
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"only_run_once"];
    }
    
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
    AudioServicesPlaySystemSound(soundID);
    
    
//    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
//    [audioPlayer play];
}


@end
