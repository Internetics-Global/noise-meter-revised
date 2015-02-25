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
#import <MediaPlayer/MediaPlayer.h>
#import <MessageUI/MessageUI.h>
#import "ScoreArrayDataSource.h"
#import "NMDataManager.h"
#import "IDPSoundBoard.h"

//忽略那种短暂的噪声
#define K_Second_IgnoreSuddenNoise     0.5

//当alarm出现后，继续保持录音的时间
#define K_Second_DelayAlarmSound       1.0

//在silent mode中，为了防止不断的capture,需要设置最短时间，在这个时间内如果重复出现alarm，则忽略
#define K_Second_SilentMode        1.0

@interface MeterView () <MFMailComposeViewControllerDelegate> {
    MPVolumeView *_volumeView;
    
    BOOL         *_isAlarmPrepareToBeTriggered;
    
    ScoreArrayDataSource *_scoreArrayDataSource;
    
    //用于判断是否delay的时间是否大于K_Second_DelayAlarmSound
    NSDate       *_startForDelayAlarmSound;
    
    //用于判断下一个capture事件
    NSDate       *_startForSilentMode;
}

@end

@implementation MeterView

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
    
    _startForDelayAlarmSound = [NSDate date];
    _startForSilentMode =  [NSDate date];
    
    
    
    return self;
}

- (void)failed
{
    _currentReadingLabel.text = @"N/A";
    [_soundLevelView setSoundLevelValue:0];
    _currentReadingLabel.textColor = [UIColor redColor];
    
    _cancelButton.hidden = NO;
    
//    CGRect rect = _currentReadingLabel.frame;
//    rect.origin.x = 50;
//    _currentReadingLabel.frame = rect;
    
}

/**
 *  call this method in observeValueForKeyPath when meter level is normal(not over threshold nor failed)
 */
- (void)success
{
    if (_cancelButton.hidden == FALSE) {
        _cancelButton.hidden = YES;
        _captureButton.hidden = YES;
        
//        CGRect rect = _currentReadingLabel.frame;
//        rect.origin.x = 10;
//        _currentReadingLabel.frame = rect;
    }
}

- (void)reloadData
{
    _scores = [SoundLevelCapture sortedScoreArray];
    _titleLabel.numberOfLines = 2;
    if ([_scores count] == 0) 
    {
        _titleLabel.text = @"  Top Noise Makers:\n  None recorded";
    }
    else 
    {
        _titleLabel.text = @"  Top Noise Makers:";
    }
    [_topScoreTable reloadData];
}

- (void) cancel {
    
    [[NMDecibelLogger defaultLogger] alarmComplete];
    
}


- (void)infoShowV2
{
    _overlayImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _overlayImageView.contentMode = UIViewContentModeScaleAspectFill;
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
    
    [[UIApplication sharedApplication].keyWindow addSubview:_overlayImageView];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:_overlayImageView];
    
}

- (void)loadView
{
    [super loadView];
    
    [self style];
    
    //1. info
    _infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_infoButton setImage:[UIImage imageNamed:@"button_info.png"] forState:UIControlStateNormal];
    _infoButton.frame = CGRectMake(self.view.frame.size.width - 30, 15, 20, 20);
    [_infoButton addTarget:self action:@selector(infoShowV2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_infoButton];
    
    //2. meter base view
    _meterBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 60, 320, 248)];
    _meterBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    _meterBackground.userInteractionEnabled = YES;
    _meterBackground.backgroundColor = [UIColor colorWithRed:55.0/255 green:55.0/255 blue:55.0/255 alpha:0.9];
    [self.view addSubview:_meterBackground];
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchLoggingStatus)];
    singleTapGesture.numberOfTapsRequired = 1;
    singleTapGesture.numberOfTouchesRequired = 1;
    [_meterBackground addGestureRecognizer:singleTapGesture];
    
    //3. sound level view
    _soundLevelView = [[SoundLevelView alloc] initWithFrame:CGRectMake((CGRectGetWidth(_meterBackground.frame) - KSoundMeterViewWidth)/2, (CGRectGetHeight(_meterBackground.frame) - KSoundMeterViewWidth)/2, KSoundMeterViewWidth, KSoundMeterViewWidth)];
    _soundLevelView.autoresizingMask = UIViewAutoresizingNone;
    [_soundLevelView setupSubviews];
    _soundLevelView.backgroundColor = [UIColor clearColor];
    [_meterBackground addSubview:_soundLevelView];
    [_soundLevelView addGestureRecognizer:singleTapGesture];
    
    [[NMDecibelLogger defaultLogger] addObserver:self forKeyPath:@"currentReading" options:NSKeyValueObservingOptionNew context:NULL];
    [[NMDecibelLogger defaultLogger] startLogging];
    
    //4. current reading base view
    _currentReadingBaseView = [[UIView alloc] initWithFrame:CGRectMake(15, 15, 70, 70)];
    _currentReadingBaseView.backgroundColor = [UIColor darkGrayColor];
    _currentReadingBaseView.layer.cornerRadius = 5;
    _currentReadingBaseView.layer.masksToBounds = YES;
    [_meterBackground addSubview:_currentReadingBaseView];
    
    _currentReadingDesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 70, 25)];
    _currentReadingDesLabel.textAlignment = UITextAlignmentCenter;
    _currentReadingDesLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:22];
    _currentReadingDesLabel.textColor = [UIColor grayColor];
    _currentReadingDesLabel.backgroundColor = [UIColor clearColor];
    _currentReadingDesLabel.layer.cornerRadius = 5;
    _currentReadingDesLabel.text = @"NOW";
    _currentReadingDesLabel.layer.masksToBounds = YES;
    [_currentReadingBaseView addSubview:_currentReadingDesLabel];
    
    _currentReadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 70, 40)];
    _currentReadingLabel.textAlignment = UITextAlignmentCenter;
    _currentReadingLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:32];
    _currentReadingLabel.textColor = [UIColor grayColor];
    _currentReadingLabel.backgroundColor = [UIColor clearColor];
    _currentReadingLabel.layer.cornerRadius = 5;
    _currentReadingLabel.layer.masksToBounds = YES;
    [_currentReadingBaseView addSubview:_currentReadingLabel];
    
    //5. cancel button
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelButton setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
    _cancelButton.frame = CGRectMake(CGRectGetMaxX(_currentReadingBaseView.frame) + 5, CGRectGetMinY(_currentReadingBaseView.frame), 30, 30);
    [_cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.hidden = YES;
    [_meterBackground addSubview:_cancelButton];
    

    //6. peak view
    _peakBaseView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_meterBackground.frame) - 90, CGRectGetHeight(_meterBackground.frame) - 90, 70, 70)];
    _peakBaseView.backgroundColor = [UIColor darkGrayColor];
    _peakBaseView.layer.cornerRadius = 5;
    _peakBaseView.layer.masksToBounds = YES;
    [_meterBackground addSubview:_peakBaseView];
    
    _peakDesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 70, 25)];
    _peakDesLabel.textAlignment = UITextAlignmentCenter;
    _peakDesLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:22];
    _peakDesLabel.textColor = [UIColor grayColor];
    _peakDesLabel.backgroundColor = [UIColor clearColor];
    _peakDesLabel.layer.cornerRadius = 5;
    _peakDesLabel.text = @"HIGH";
    _peakDesLabel.layer.masksToBounds = YES;
    [_peakBaseView addSubview:_peakDesLabel];
    
    _peakLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 70, 40)];
    _peakLabel.textAlignment = UITextAlignmentCenter;
    _peakLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:32];
    _peakLabel.textColor = [UIColor grayColor];
    _peakLabel.backgroundColor = [UIColor clearColor];
    _peakLabel.layer.cornerRadius = 5;
    _peakLabel.layer.masksToBounds = YES;
    [_peakBaseView addSubview:_peakLabel];
    
    _peakBaseView.hidden = YES;
    
    //7. capture view
    _captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_captureButton setImage:[UIImage imageNamed:@"button_capture.png"] forState:UIControlStateNormal];
    _captureButton.frame = CGRectMake(self.view.frame.size.width - 89, _meterBackground.frame.origin.y + _meterBackground.frame.size.height - 20, 89, 29);
    [self.view addSubview:_captureButton];
    _captureButton.hidden = YES;
    [_captureButton addTarget:self action:@selector(capture) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    [self reloadData];
    
    
    _formBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_count.png"]];
    _formBackground.frame = CGRectMake(0, _meterBackground.frame.origin.y + _meterBackground.frame.size.height + 10, 320, 150);
    _formBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_formBackground];
    
    _topScoreTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_meterBackground.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(_meterBackground.frame) - 44) style:UITableViewStylePlain];
    _topScoreTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _topScoreTable.backgroundView = nil;
    _topScoreTable.separatorColor = [UIColor colorWithRed:0.152 green:0.156 blue:0.164 alpha:1.0];
    _topScoreTable.backgroundColor = [UIColor colorWithRed:22.0/255 green:24.0/255 blue:25.0/255 alpha:1];
    _topScoreTable.opaque = YES;
    _topScoreTable.delegate = self;
    
    __weak __typeof(&*self)weakSelf = self;
    _scoreArrayDataSource = [[ScoreArrayDataSource alloc] initWithReloadTableBlock:^() {
        [weakSelf reloadData];
    }];
    _topScoreTable.dataSource = _scoreArrayDataSource;
    
    [self.view addSubview:_topScoreTable];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"SoundCaptured" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failed) name:@"RecordFail" object:nil];
    
    
}

- (void) goToPurchasePage {
    PurchaseViewController *purchaseViewController = [[PurchaseViewController alloc] initWithNibName:@"PurchaseViewController" bundle:nil];
    [self.navigationController pushViewController:purchaseViewController animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:55.0/255 green:55.0/255 blue:55.0/255 alpha:0.9];
    
    [NSUserDefaultsHelper setLoggingPauseFlag:NO];
}


- (void)capture
{
    CaptureView *cap = [[CaptureView alloc] initWithReading:_peakReading];
    [self.navigationController pushViewController:cap animated:YES];
}


- (void) catchAndSaveSound_With_StartLoggingAgain {
    
    [self catchAndSaveSound_Without_StartLoggingAgain];
    
    [[NMDecibelLogger defaultLogger] startLogging];

    
}

- (void) catchAndSaveSound_Without_StartLoggingAgain {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *timeString = [formatter stringFromDate:[NSDate date]];
    
    //Record last 10 second audio just before alarm
    NSURL *fromURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp.caf"]];
    
    NSDate *date = [NSDate date];
    NSString *dateString = [FileHelper convertDate:date];
    
    NSURL *toURL = [FileHelper getRecordedAudioFile:dateString];
    if ([[NMDecibelLogger defaultLogger] logging]) {
        [[NMDecibelLogger defaultLogger] stopLogging];
    }
    [IDPSoundBoard saveLast10SecondAudio:fromURL toURL:toURL];
    
    SoundLevelCapture *cap = [SoundLevelCapture instance];
    cap.name = timeString;
    cap.soundLevel = [NSDecimalNumber decimalNumberWithString:[_peakReading stringValue]];
    cap.date = date;
    [[NMDataManager defaultManager] saveContext];
    [self reloadData];
    
    
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    int headerHeight = [self tableView:tableView heightForHeaderInSection:section];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, headerHeight)];
    headerView.backgroundColor = [UIColor colorWithRed:22.0/255 green:24.0/255 blue:25.0/255 alpha:1];
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, headerView.frame.size.width - 10, headerView.frame.size.height - 10)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.numberOfLines = 2;
    if ([_scores count] == 0)
    {
        _titleLabel.text = @"  Top Noise Makers:\n  None recorded";
    }
    else
    {
        _titleLabel.text = @"  Top Noise Makers:";
    }
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    _titleLabel.textColor = [UIColor whiteColor];
    [headerView addSubview:_titleLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(headerView.frame) -0.5, CGRectGetWidth(headerView.frame), 0.5)] ;
    lineView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.1];
    [headerView addSubview:lineView];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([_scores count] == 0) 
    {
        return 60;
    }
    else 
    {
        return 40;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (_isAlarmPrepareToBeTriggered) {
        //wait for finish on delay alarm sound
        return;
    }
    
    if (([[IDPSoundBoard audioPlayerForKey:Key_PlayerRecorded] isPlaying])) {
        _currentReadingLabel.text = @"Playing";
        return;
    }
    
    if ([NSUserDefaultsHelper isLoggingPause]) {
        _currentReadingLabel.text = @"Meter off";
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
        
        _currentReadingLabel.text = [NSString stringWithFormat:@"%d", [_currentReading intValue]];
        [_soundLevelView setSoundLevelValue:[_currentReading floatValue]];
        NSNumber *threshold = [NMDecibelLogger defaultLogger].alertThreshold;
        if ((_peakReading == nil) || ([_peakReading floatValue] < [_currentReading floatValue])) 
        {
            _peakReading = _currentReading;
            
        }
        
        
        //do some here
        NSTimeInterval executionTime =[[NSDate date] timeIntervalSinceDate:_startForDelayAlarmSound];
        
        
        if ((threshold != nil) && ([threshold floatValue] < [_currentReading floatValue]))
        {
            _currentReadingLabel.textColor = [UIColor redColor];
            if ([NSUserDefaultsHelper isIgnoreSuddenNoise]) {
                if (executionTime > K_Second_IgnoreSuddenNoise) {
                    if ([NSUserDefaultsHelper isDelayAlarmSound]) {
                        _isAlarmPrepareToBeTriggered = YES;
                        double delayInSeconds = K_Second_DelayAlarmSound;
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            [self triggerAlarmInDifferentMode];
                            _isAlarmPrepareToBeTriggered = NO;
                        });
                    } else {
                        [self triggerAlarmInDifferentMode];
                    }
                    
                }
            } else {
                if ([NSUserDefaultsHelper isDelayAlarmSound]) {
                    _isAlarmPrepareToBeTriggered = YES;
                    double delayInSeconds = K_Second_DelayAlarmSound;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [self triggerAlarmInDifferentMode];
                        _isAlarmPrepareToBeTriggered = NO;
                    });
                } else {
                    [self triggerAlarmInDifferentMode];
                }
            }
        }
        else
        {
            //NSLog(@"Not reach threahold");
            _startForDelayAlarmSound = [NSDate date];
            _currentReadingLabel.textColor = [UIColor grayColor];
            [self success];
        }
        
        
        if ((threshold != nil) && ([threshold floatValue] < [_currentReading floatValue])) 
        {
            _peakBaseView.hidden = NO;
            _peakLabel.text = [NSString stringWithFormat:@"%d", [_peakReading intValue]];
            _captureButton.hidden = NO;
            _cancelButton.hidden = NO;
            
//            CGRect rect = _currentReadingLabel.frame;
//            rect.origin.x = 50;
//            _currentReadingLabel.frame = rect;
        }
        
    }
    else 
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

/**
 *  做如下几个动作
    1. play alarm，如果需要
    2. 保存声音文件，如果需要
    3. 2秒后自动关闭alarm并继续Logging，如果需要  (continuous mode)
 */
- (void) triggerAlarmInDifferentMode {
    if ([NSUserDefaultsHelper isSilentMode]) {
        //为了防止不停的catch，设置了K_Second_SilentMode内不允许重新catch
        NSTimeInterval executionTime2 =[[NSDate date] timeIntervalSinceDate:_startForSilentMode];
        if (executionTime2 > K_Second_SilentMode) {
            _startForSilentMode = [NSDate date];
            [self catchAndSaveSound_With_StartLoggingAgain];
            
        }
        
    } else if ([NSUserDefaultsHelper isContinuousMode]) {
        
        NSTimeInterval executionTime2 =[[NSDate date] timeIntervalSinceDate:_startForSilentMode];
        if (executionTime2 > K_Second_SilentMode) {
            _startForSilentMode = [NSDate date];
            
            [self catchAndSaveSound_Without_StartLoggingAgain];//1.抓取音频，并存盘。这时没有loging,所以不用担心triggerAlarmInDifferentMode会被不断执行
            
            [[NMDecibelLogger defaultLogger] playAlarm];//2.播放alarm
            
            //delayInSeconds后关闭alarm，然后重新开始recording
            double delayInSeconds = 3;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self cancel];
                [[NMDecibelLogger defaultLogger] startLogging];
                
            });
            
            
        }
        
        
    } else {
        [[NMDecibelLogger defaultLogger] playAlarm];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    _peakReading = nil;
    //_captureButton.hidden = YES;
    _peakBaseView.hidden = YES;
    [super viewDidDisappear:animated];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.screenName = @"MeterView Screen";
    
    if ([NSUserDefaultsHelper isProVersion]) {
        _topScoreTable.frame = CGRectMake(0, CGRectGetMaxY(_meterBackground.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(_meterBackground.frame) - 44);
    } else {
        _topScoreTable.frame = CGRectMake(0, CGRectGetMaxY(_meterBackground.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(_meterBackground.frame) - 44 - CGRectGetHeight(self.generalADButton.frame));
    }
    
    [self reloadData];
    
    [_soundLevelView refreshMeterImageView];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (([[NMDecibelLogger defaultLogger] logging]) && ([[NMDecibelLogger defaultLogger] playingAlarm] == FALSE)) {
        _cancelButton.hidden = YES;
        _captureButton.hidden = YES;
        
//        CGRect rect = _currentReadingLabel.frame;
//        rect.origin.x = 10;
//        _currentReadingLabel.frame = rect;
    }
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)alarmFinishedNotification:(NSNotification *)notification {
    _captureButton.hidden = YES;
    _cancelButton.hidden = YES;
    
//    CGRect rect = _currentReadingLabel.frame;
//    rect.origin.x = 10;
//    _currentReadingLabel.frame = rect;
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

- (void)dealloc
{
    [self viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"didFailToReceiveAdWithError, %@",[error description]);
}

#pragma mark – Others
- (void) switchLoggingStatus {
    
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [NSUserDefaultsHelper setNotShowMeterOffDialogFlag:YES];
    }
}

#pragma mark – UITapGestureRecognizer
- (void) closeOverlay {
    [_overlayImageView removeFromSuperview];
    _overlayImageView = nil;
}




@end
