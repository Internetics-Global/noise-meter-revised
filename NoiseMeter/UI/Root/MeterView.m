//
//  MeterView.m
//  NoiseMeter
//
//  Created by Dave Finster on 6/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import "MeterView.h"
#import "NMDecibelLogger.h"
#import "CaptureView.h"
#import "SoundLevelCapture.h"
#import "SoundLevelCaptureCell.h"
#import "PurchaseViewController.h"
#import "FileHelper.h"
#import "IDPSoundBoard.h"

@interface MeterView ()

@end

@implementation MeterView

#pragma mark – Life Cycle

- (id)init
{
    self = [super init];
    self.title = @"Meter";
    self.tabBarItem.image = [UIImage imageNamed:@"icon_meter.png"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(alarmFinishedNotification:)
                                                 name:@"ALARM_FINISHED_NOTIFICATION"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pauseLoggingSwitchNotification:)
                                                 name:@"PAUSE_LOGGING_SWITCH_NOTIFICATION"
                                               object:nil];
    
    
    
    return self;
}

- (void)loadView
{
    [super loadView];
    
    [self style];
    
    _meterBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_count.png"]];
    _meterBackground.frame = CGRectMake(0, 79, 320, 150);
    _meterBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    _meterBackground.userInteractionEnabled = YES;
    [self.view addSubview:_meterBackground];
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchLoggingStatus)];
    singleTapGesture.numberOfTapsRequired = 1;
    singleTapGesture.numberOfTouchesRequired = 1;
    [_meterBackground addGestureRecognizer:singleTapGesture];
    
    _infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_infoButton setImage:[UIImage imageNamed:@"button_info.png"] forState:UIControlStateNormal];
    _infoButton.frame = CGRectMake(self.view.frame.size.width - 30, _meterBackground.frame.origin.y, 30, 30);
    [_infoButton addTarget:self action:@selector(infoShowV2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_infoButton];
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelButton setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
    _cancelButton.frame = CGRectMake(10, _meterBackground.frame.origin.y + 10, 30, 30);
    [_cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.hidden = YES;
    [self.view addSubview:_cancelButton];
    
    _currentReadingLabel = [[UILabel alloc] initWithFrame:
                            CGRectMake(10, _meterBackground.frame.origin.y, 200, 50)];
    _currentReadingLabel.textAlignment = UITextAlignmentLeft;
    _currentReadingLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:40];
    _currentReadingLabel.textColor = [UIColor greenColor];
    _currentReadingLabel.backgroundColor = [UIColor clearColor];
    _currentReadingLabel.userInteractionEnabled = YES;
    [self.view addSubview:_currentReadingLabel];
    
    _soundLevelView = [[SoundLevelView alloc] initWithFrame:CGRectMake(10, _meterBackground.frame.origin.y + 40, 310, _meterBackground.frame.size.height -65)];
    [_soundLevelView setupSubviews];
    _soundLevelView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_soundLevelView];
    [_soundLevelView addGestureRecognizer:singleTapGesture];
    
    [[NMDecibelLogger defaultLogger] addObserver:self forKeyPath:@"currentReading" options:NSKeyValueObservingOptionNew context:NULL];
    [[NMDecibelLogger defaultLogger] startLogging];
    
    _captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_captureButton setImage:[UIImage imageNamed:@"button_capture.png"] forState:UIControlStateNormal];
    _captureButton.frame = CGRectMake(self.view.frame.size.width - 89, _meterBackground.frame.origin.y + _meterBackground.frame.size.height - 20, 89, 29);
    [self.view addSubview:_captureButton];
    _captureButton.hidden = YES;
    [_captureButton addTarget:self action:@selector(capture) forControlEvents:UIControlEventTouchUpInside];
    
    _peakLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, _captureButton.frame.origin.y, 200, 29)];
    _peakLabel.textColor = [UIColor whiteColor];
    _peakLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_peakLabel];
    _peakLabel.hidden = YES;
    
    [self reloadData];
    
    _formBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_count.png"]];
    _formBackground.frame = CGRectMake(0, _meterBackground.frame.origin.y + _meterBackground.frame.size.height + 10, 320, 150);
    _formBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_formBackground];
    
    _topScoreTable = [[UITableView alloc] initWithFrame:CGRectMake(0, _captureButton.frame.origin.y + _captureButton.frame.size.height - 5, self.view.frame.size.width, self.view.frame.size.height - (_meterBackground.frame.origin.y + _meterBackground.frame.size.height)) style:UITableViewStylePlain];
    _topScoreTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _topScoreTable.backgroundView = nil;
    _topScoreTable.separatorColor = [UIColor colorWithRed:0.152 green:0.156 blue:0.164 alpha:1.0];
    _topScoreTable.backgroundColor = [UIColor clearColor];
    _topScoreTable.opaque = YES;
    _topScoreTable.delegate = self;
    _topScoreTable.scrollEnabled = NO;
    _topScoreTable.dataSource = self;
    [self.view addSubview:_topScoreTable];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"SoundCaptured" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failed) name:@"RecordFail" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    _peakReading = nil;
    //_captureButton.hidden = YES;
    _peakLabel.hidden = YES;
    [super viewDidDisappear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.trackedViewName = @"MeterView Screen";
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (([[NMDecibelLogger defaultLogger] logging]) && ([[NMDecibelLogger defaultLogger] playingAlarm] == FALSE)) {
        _cancelButton.hidden = YES;
        _captureButton.hidden = YES;
        
        CGRect rect = _currentReadingLabel.frame;
        rect.origin.x = 10;
        _currentReadingLabel.frame = rect;
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    _currentReadingLabel = nil;
    [_soundLevelView setSoundLevelValue:0];
    _meterBackground = nil;
    [[NMDecibelLogger defaultLogger] stopLogging];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SoundCaptured" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RecordFail" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSUserDefaultsHelper setLoggingPauseFlag:NO];
    
    _playingIndex = -1;
}

#pragma mark – Logging related

- (void)failed
{
    NSLog(@"%s: record failure occur",__FUNCTION__);
    _currentReadingLabel.text = @"N/A";
    [_soundLevelView setSoundLevelValue:0];
    _currentReadingLabel.textColor = [UIColor redColor];
    
    _cancelButton.hidden = NO;
    CGRect rect = _currentReadingLabel.frame;
    rect.origin.x = 50;
    _currentReadingLabel.frame = rect;
}

/**
 *  call this method in observeValueForKeyPath when meter level is normal(not over threshold nor failed)
 */
- (void)success
{
    if (_cancelButton.hidden == FALSE) {
        _cancelButton.hidden = YES;
        _captureButton.hidden = YES;
        
        CGRect rect = _currentReadingLabel.frame;
        rect.origin.x = 10;
        _currentReadingLabel.frame = rect;
    }
}

- (void)reloadData
{
    _scores = [SoundLevelCapture all];
    NSSortDescriptor *desc = [NSSortDescriptor sortDescriptorWithKey:@"soundLevel" ascending:NO];
    _scores = [_scores sortedArrayUsingDescriptors:[NSArray arrayWithObject:desc]];
    _titleLabel.numberOfLines = 3;
    if ([_scores count] == 0) 
    {
        _titleLabel.text = @"  Top Noise Makers:\n\n  None recorded";
    }
    else 
    {
        _titleLabel.text = @"  Top Noise Makers:\n\n";
    }
    [_topScoreTable reloadData];
}

- (void) cancel {
    
    NSLog(@"%s",__FUNCTION__);
    [[NMDecibelLogger defaultLogger] alarmComplete];
    
}



- (void)capture
{
    NSLog(@"%s",__FUNCTION__);
    CaptureView *cap = [[CaptureView alloc] initWithReading:_peakReading];
    [self.navigationController pushViewController:cap animated:YES];
}

#pragma mark – TableView delegate and datasource

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_headerView == nil) 
    {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 45)];
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, _headerView.frame.size.width - 10, _headerView.frame.size.height)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 3;
        if ([_scores count] == 0) 
        {
            _titleLabel.text = @"  Top Noise Makers:\n\n  None recorded";
        }
        else 
        {
            _titleLabel.text = @"  Top Noise Makers:\n\n";
        }
        _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:_titleLabel.font.pointSize];
        _titleLabel.textColor = [UIColor whiteColor];
        [_headerView addSubview:_titleLabel];
    }
    return _headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([_scores count] == 0) 
    {
        return 66;
    }
    else 
    {
        return 45;
    }
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
        cell.textLabel.textColor = [UIColor whiteColor];
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

#pragma mark – KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([[IDPSoundBoard audioPlayerForKey:Key_PlayerRecorded] isPlaying]) {
        _currentReadingLabel.text = @"Playing";
        return;
    }
    
    if ([NSUserDefaultsHelper isLoggingPause]) {
        _currentReadingLabel.text = @"Meter off";
        return;
    }
    
    if ([[NMDecibelLogger defaultLogger] logging] == FALSE) {
        return;
    }
    
    if ([keyPath isEqualToString:@"currentReading"]) 
    {
        _currentReading = [[NMDecibelLogger defaultLogger] currentReading];
        
        if ([_currentReading integerValue] < 0) {
            //mean not right reading, we need to retry. This is important when an incoming call
            NSLog(@"%s:_currentReading is < 0",__FUNCTION__);
            sleep(0.1);
            [[NMDecibelLogger defaultLogger] startLogging];
            return;
        }
        
        _currentReadingLabel.text = [NSString stringWithFormat:@"%.1f", [_currentReading floatValue]];
        [_soundLevelView setSoundLevelValue:[_currentReading floatValue]];
        NSNumber *threshold = [NMDecibelLogger defaultLogger].alertThreshold;
        if ((_peakReading == nil) || ([_peakReading floatValue] < [_currentReading floatValue])) 
        {
            _peakReading = _currentReading;
            
        }
        
        if ((threshold != nil) && ([threshold floatValue] < [_currentReading floatValue])) 
        {
            _currentReadingLabel.textColor = [UIColor redColor];
            [[NMDecibelLogger defaultLogger] playAlarm];
        }
        else 
        {
            _currentReadingLabel.textColor = [UIColor greenColor];
            [self success];
        }
        
        
        if ((threshold != nil) && ([threshold floatValue] < [_currentReading floatValue])) 
        {
            _peakLabel.hidden = NO;
            _peakLabel.text = [NSString stringWithFormat:@"Last Peak: %.1f", [_peakReading floatValue]];
            _captureButton.hidden = NO;
            _cancelButton.hidden = NO;
            CGRect rect = _currentReadingLabel.frame;
            rect.origin.x = 50;
            _currentReadingLabel.frame = rect;
        }
        
    }
    else 
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


#pragma mark – Notification related

- (void)alarmFinishedNotification:(NSNotification *)notification {
    _captureButton.hidden = YES;
    _cancelButton.hidden = YES;
    
    CGRect rect = _currentReadingLabel.frame;
    rect.origin.x = 10;
    _currentReadingLabel.frame = rect;
}

- (void)pauseLoggingSwitchNotification:(NSNotification *)notification {
    
    if ([NSUserDefaultsHelper isLoggingPause]) {
        [[NMDecibelLogger defaultLogger] stopLogging];
        
        _currentReadingLabel.text = @"Meter off";
        [NSUserDefaultsHelper setLoggingPauseFlag:YES];
        
    } else {
        [[NMDecibelLogger defaultLogger] startLogging];
        [NSUserDefaultsHelper setLoggingPauseFlag:NO];
    }
}



- (void)purchasedFinishedNotification:(NSNotification *)notification {
    
    [super purchasedFinishedNotification:notification];
    
    [_topScoreTable reloadData];
}


#pragma mark – IBAction and Others

- (void) playRecordedSound: (id) sender {
    
    _playingIndex = ((UIButton *) [sender view]).tag;
    
    [_topScoreTable reloadData];
    
    SoundLevelCapture *caputure = [_scores objectAtIndex:_playingIndex];
    
    NSDate *date = caputure.date;
	NSString *dateString = [FileHelper convertDate:date];
    
    NSURL *url = [FileHelper getRecordedAudioFile:dateString];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        usleep(10000);
        _currentReadingLabel.text = @"Playing";
    });
    
    [IDPSoundBoard addAudioAtPath:[url path] forKey:Key_PlayerRecorded forType:EnumSoundType_Recorded];
    AVAudioPlayer *player = [IDPSoundBoard audioPlayerForKey:Key_PlayerRecorded];
    player.numberOfLoops = 0;  // Endless
    [IDPSoundBoard sharedInstance].IDPDelegate = self;
    [IDPSoundBoard playAudioForKey:Key_PlayerRecorded fadeInInterval:2.0];
    
}


- (void) switchLoggingStatus {
    
    if (_cancelButton.hidden == NO) {
        return;
    }
    
    if ([NSUserDefaultsHelper isLoggingPause] == FALSE) {
        [[NMDecibelLogger defaultLogger] stopLogging];
        
        _currentReadingLabel.text = @"Meter off";
        [NSUserDefaultsHelper setLoggingPauseFlag:YES];
        
        if ([NSUserDefaultsHelper isNotShowMeterOffDialog] == NO) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Meter off. Tap again to resume." delegate:self cancelButtonTitle:@"Don't show again" otherButtonTitles:@"OK",nil];
            [alert show];
        }
        
        APP_DELEGATE.isNotAllowBackgroundRunningWhenLastMeterOff = [NSUserDefaultsHelper isNotAllowBackgroundRunning];
        [NSUserDefaultsHelper setNotAllowBackgroundRunningFlag:YES];
        
    } else {
        [[NMDecibelLogger defaultLogger] startLogging];
        [NSUserDefaultsHelper setLoggingPauseFlag:NO];
        
        if (APP_DELEGATE.isNotAllowBackgroundRunningWhenLastMeterOff == FALSE) {
          [NSUserDefaultsHelper setNotAllowBackgroundRunningFlag:NO];
        } else {
          [NSUserDefaultsHelper setNotAllowBackgroundRunningFlag:YES];
        }
        
    }
    
    
}


- (void)infoShowV2
{
    _overlayImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _overlayImageView.contentMode = UIViewContentModeScaleToFill;
    if (iPhone5) {
        _overlayImageView.frame = CGRectMake(0, 0, 320, 568);
        [_overlayImageView setImage:[UIImage imageNamed:@"overlay568"]];
    } else {
        _overlayImageView.frame = CGRectMake(0, 0, 320, 480);
        [_overlayImageView setImage:[UIImage imageNamed:@"overlay"]];
    }
    _overlayImageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *stg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeOverlay)];
    stg.numberOfTapsRequired = 1;
    stg.numberOfTouchesRequired = 1;
    [_overlayImageView addGestureRecognizer:stg];
    
    _overlayImageView.alpha = 0;
    [[UIApplication sharedApplication].keyWindow addSubview:_overlayImageView];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:_overlayImageView];
    [UIView animateWithDuration:0.4 animations:^() {
      _overlayImageView.alpha = 1;
    }];
    
}



- (void) goToPurchasePage {
    PurchaseViewController *purchaseViewController = [[PurchaseViewController alloc] initWithNibName:@"PurchaseViewController" bundle:nil];
    [self.navigationController pushViewController:purchaseViewController animated:YES];
}

#pragma mark – UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [NSUserDefaultsHelper setNotShowMeterOffDialogFlag:YES];
    }
}

#pragma mark – UITapGestureRecognizer

- (void) closeOverlay {
    [UIView animateWithDuration:0.4 animations:^() {
        _overlayImageView.alpha = 0;
    }];
    [_overlayImageView removeFromSuperview];
    _overlayImageView = nil;
}

#pragma mark – IDPSoundBoardDelegate

- (void)didFinishSoundPlay:(EnumSoundType)soundType {
    if (soundType == EnumSoundType_Recorded) {
        _playingIndex = -1;
        [_topScoreTable reloadData];
        
    }
}


#pragma mark – Memory management

- (void)dealloc
{
    [self viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark – Rotation Control
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
