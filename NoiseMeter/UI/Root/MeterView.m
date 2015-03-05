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
#import "MoreView.h"

#import "UIButton+Extensions.h"

#import "AMPopTip.h"
#import <Parse/PFAnalytics.h>

//忽略那种短暂的噪声
#define K_Second_IgnoreSuddenNoise     0.5

//当alarm出现后，继续保持录音的时间
#define K_Second_DelayAlarmSound       1.0

//在silent mode中，为了防止不断的capture,需要设置最短时间，在这个时间内如果重复出现alarm，则忽略
#define K_Second_SilentMode        1.0

#define K_Meter_Square_Background_Color  [UIColor colorWithRed:40.0/255 green:40.0/255 blue:40.0/255 alpha:0.6]

#define K_Square_Width  70.0
#define K_Square_Margin  8.0

#define K_Square_FontSize 18
#define K_Square_FontSize_Des 26

#define K_Square_Font_Name  @"AvenirNext-Bold"



@interface MeterView () <MFMailComposeViewControllerDelegate> {
    MPVolumeView *_volumeView;
    
    /**
     *当在Delay Alarm Sound = YES时,设置这个标志用来，防止在这段时间内重新触发alarm
     *如果 ＝ YES，则不允许触发observeValueForKeyPath
     */
    BOOL         _isAlarmPrepareToBeTriggered;
    
    ScoreArrayDataSource *_scoreArrayDataSource;
    
    //用于判断是否delay的时间是否大于K_Second_DelayAlarmSound
    NSDate       *_startForDelayAlarmSound;
    
    //用于判断下一个capture事件
    NSDate       *_startForSilentMode;
    
    AMPopTip *_popTipMeterPause;
    AMPopTip *_popTipMeterCapture;
    AMPopTip *_popTipInfo;
    AMPopTip *_popTipTabBarLevel;
    AMPopTip *_popTipTabBarScore;

    
}

@end

@implementation MeterView

- (NSString *)iconImageName {
    return @"icon_meter";
}

- (id)init
{
    self = [super init];
    self.title = @"Meter";
    self.tabBarItem.image = [UIImage imageNamed:@"icon_meter.png"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(alarmFinishedNotification:)
                                                 name:K_Notification_Alarm_Finished
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pauseLoggingSwitchNotification:)
                                                 name:K_Notification_Log_Pause_Switch_Setting
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateMeterPlayStatusNotification:)
                                                 name:K_Notification_Update_Meter_Play_Status
                                               object:nil];
    
    _startForDelayAlarmSound = [NSDate date];
    _startForSilentMode =  [NSDate date];
    
    
    
    return self;
}

- (void)failed
{
    _currentReadingLabel.text = @"N/A";
    
    int maxValue = [[[NMDecibelLogger defaultLogger] alertThreshold] intValue];
    [_soundLevelView setSoundLevelValue:0 withMaxLevel:maxValue];
    _currentReadingLabel.textColor = [UIColor redColor];
    
    _cancelButton.hidden = NO;
    
}

/**
 *  call this method in observeValueForKeyPath when meter level is normal(not over threshold nor failed)
 */
- (void)success
{
    if (_cancelButton.hidden == FALSE) {
        _cancelButton.hidden = YES;
        //_captureMeterBaseView.hidden = YES;
        
    }
}

- (void)reloadData
{
    _scores = [SoundLevelCapture sortedScoreArrayByNoiseLevel];
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
    
    [self style:NO];
    
    //1. info and more
    _infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_infoButton setImage:[UIImage imageNamed:@"button_info.png"] forState:UIControlStateNormal];
    _infoButton.frame = CGRectMake(self.view.frame.size.width - 35, 18, 20, 20);
    [_infoButton addTarget:self action:@selector(switchTips) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_infoButton];
    _infoButton.showsTouchWhenHighlighted = YES;
    [_infoButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    
    _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_moreButton setImage:[UIImage imageNamed:@"icon_more.png"] forState:UIControlStateNormal];
    _moreButton.frame = CGRectMake(15, 18, 20, 20);
    [_moreButton addTarget:self action:@selector(moreButtonCLicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_moreButton];
    _moreButton.showsTouchWhenHighlighted = YES;
    [_moreButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    
    //2. meter base view
    
    if (iPhone5) {
        _meterBackground = [[UIView alloc] initWithFrame:CGRectMake(0, KTopLogoHeight, 320, 248)];
    } else {
        _meterBackground = [[UIView alloc] initWithFrame:CGRectMake(0, KTopLogoHeight, 320, 200)];
    }
    _meterBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    _meterBackground.userInteractionEnabled = YES;
    _meterBackground.backgroundColor = kMeterOverlapColor;
    [self.view addSubview:_meterBackground];
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchLoggingStatus)];
    singleTapGesture.numberOfTapsRequired = 1;
    singleTapGesture.numberOfTouchesRequired = 1;
    [_meterBackground addGestureRecognizer:singleTapGesture];
    
    //3. sound level view
    if (iPhone5) {
        _soundLevelView = [[SoundLevelView alloc] initWithFrame:CGRectMake((CGRectGetWidth(_meterBackground.frame) - KSoundMeterViewWidth)/2, (CGRectGetHeight(_meterBackground.frame) - KSoundMeterViewWidth)/2, KSoundMeterViewWidth, KSoundMeterViewWidth)];
    } else {
        _soundLevelView = [[SoundLevelView alloc] initWithFrame:CGRectMake((CGRectGetWidth(_meterBackground.frame) - KSoundMeterViewWidth_iPhone4)/2, (CGRectGetHeight(_meterBackground.frame) - KSoundMeterViewWidth_iPhone4)/2, KSoundMeterViewWidth_iPhone4, KSoundMeterViewWidth_iPhone4)];
    }
    _soundLevelView.autoresizingMask = UIViewAutoresizingNone;
    _soundLevelView.isForMeterView = YES;
    [_soundLevelView setupSubviews];
    _soundLevelView.backgroundColor = [UIColor clearColor];
    [_meterBackground addSubview:_soundLevelView];
    [_soundLevelView addGestureRecognizer:singleTapGesture];
    
    [[NMDecibelLogger defaultLogger] startLogging];
    
    //4. current reading base view
    _currentReadingBaseView = [[UIView alloc] initWithFrame:CGRectMake(K_Square_Margin, K_Square_Margin, K_Square_Width, K_Square_Width)];
    _currentReadingBaseView.backgroundColor = K_Meter_Square_Background_Color;
    _currentReadingBaseView.layer.cornerRadius = 8;
    _currentReadingBaseView.layer.masksToBounds = YES;
    [_meterBackground addSubview:_currentReadingBaseView];
    
    _currentReadingDesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 11, K_Square_Width, 25)];
    _currentReadingDesLabel.textAlignment = NSTextAlignmentCenter;
    _currentReadingDesLabel.font = [UIFont fontWithName:K_Square_Font_Name size:K_Square_FontSize];
    _currentReadingDesLabel.textColor = [UIColor lightGrayColor];
    _currentReadingDesLabel.backgroundColor = [UIColor clearColor];
    _currentReadingDesLabel.layer.cornerRadius = 5;
    _currentReadingDesLabel.text = @"NOW";
    _currentReadingDesLabel.layer.masksToBounds = YES;
    [_currentReadingBaseView addSubview:_currentReadingDesLabel];
    
    _currentReadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, K_Square_Width, 40)];
    _currentReadingLabel.textAlignment = NSTextAlignmentCenter;
    _currentReadingLabel.font = [UIFont fontWithName:K_Square_Font_Name size:K_Square_FontSize_Des];
    _currentReadingLabel.textColor = [UIColor lightGrayColor];
    _currentReadingLabel.backgroundColor = [UIColor clearColor];
    _currentReadingLabel.layer.cornerRadius = 5;
    _currentReadingLabel.layer.masksToBounds = YES;
    [_currentReadingBaseView addSubview:_currentReadingLabel];
    
    //5. cancel button
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelButton setImage:[UIImage imageNamed:@"cancel.png"] forState:UIControlStateNormal];
    _cancelButton.frame = CGRectMake(CGRectGetWidth(_meterBackground.frame)/2 - 25, CGRectGetHeight(_meterBackground.frame)/2 - 25, 50, 50);
    [_cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.hidden = YES;
    [_meterBackground addSubview:_cancelButton];
    

    //6. peakview
    _peakBaseView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_meterBackground.frame) - K_Square_Margin - K_Square_Width, CGRectGetHeight(_meterBackground.frame) - K_Square_Margin - K_Square_Width, K_Square_Width, K_Square_Width)];
    _peakBaseView.backgroundColor = K_Meter_Square_Background_Color;
    _peakBaseView.layer.cornerRadius = 8;
    _peakBaseView.layer.masksToBounds = YES;
    [_meterBackground addSubview:_peakBaseView];
    
    _peakDesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 11, K_Square_Width, 25)];
    _peakDesLabel.textAlignment = NSTextAlignmentCenter;
    _peakDesLabel.font = [UIFont fontWithName:K_Square_Font_Name size:K_Square_FontSize];
    _peakDesLabel.textColor = [UIColor lightGrayColor];
    _peakDesLabel.backgroundColor = [UIColor clearColor];
    _peakDesLabel.layer.cornerRadius = 5;
    _peakDesLabel.text = @"HIGH";
    _peakDesLabel.layer.masksToBounds = YES;
    [_peakBaseView addSubview:_peakDesLabel];
    
    _peakLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, K_Square_Width, 40)];
    _peakLabel.textAlignment = NSTextAlignmentCenter;
    _peakLabel.font = [UIFont fontWithName:K_Square_Font_Name size:K_Square_FontSize_Des];
    _peakLabel.textColor = [UIColor lightGrayColor];
    _peakLabel.backgroundColor = [UIColor clearColor];
    _peakLabel.layer.cornerRadius = 5;
    _peakLabel.layer.masksToBounds = YES;
    [_peakBaseView addSubview:_peakLabel];
    
    
    //7. info view
    _infoMeterBaseView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_meterBackground.frame) - K_Square_Margin - K_Square_Width, K_Square_Margin, K_Square_Width, K_Square_Width)];
    _infoMeterBaseView.backgroundColor = K_Meter_Square_Background_Color;
    _infoMeterBaseView.layer.cornerRadius = 8;
    _infoMeterBaseView.layer.masksToBounds = YES;
    [_meterBackground addSubview:_infoMeterBaseView];
    
    UITapGestureRecognizer *singleTapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchLoggingStatus)];
    singleTapGesture2.numberOfTapsRequired = 1;
    singleTapGesture2.numberOfTouchesRequired = 1;
    [_infoMeterBaseView addGestureRecognizer:singleTapGesture2];
    
    
    _infoMeterDesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 11, K_Square_Width, 25)];
    _infoMeterDesLabel.textAlignment = NSTextAlignmentCenter;
    _infoMeterDesLabel.font = [UIFont fontWithName:K_Square_Font_Name size:16];
    _infoMeterDesLabel.textColor = [UIColor lightGrayColor];
    _infoMeterDesLabel.backgroundColor = [UIColor clearColor];
    _infoMeterDesLabel.layer.cornerRadius = 5;
    _infoMeterDesLabel.text = @"METER";
    _infoMeterDesLabel.layer.masksToBounds = YES;
    [_infoMeterBaseView addSubview:_infoMeterDesLabel];
    
    _infoMeterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, K_Square_Width, 40)];
    _infoMeterLabel.textAlignment = NSTextAlignmentCenter;
    _infoMeterLabel.font = [UIFont fontWithName:K_Square_Font_Name size:K_Square_FontSize_Des];
    _infoMeterLabel.textColor = [UIColor lightGrayColor];
    _infoMeterLabel.backgroundColor = [UIColor clearColor];
    _infoMeterLabel.layer.cornerRadius = 5;
    _infoMeterLabel.text = @"OFF";
    _infoMeterLabel.layer.masksToBounds = YES;
    [_infoMeterBaseView addSubview:_infoMeterLabel];
    
    _infoMeterBaseView.hidden = YES;
    
    //8. capture view
    _captureMeterBaseView = [[UIView alloc] initWithFrame:CGRectMake(K_Square_Margin, CGRectGetHeight(_meterBackground.frame) - K_Square_Margin - K_Square_Width, K_Square_Width, K_Square_Width)];
    _captureMeterBaseView.backgroundColor = K_Meter_Square_Background_Color;
    _captureMeterBaseView.layer.cornerRadius = 8;
    _captureMeterBaseView.layer.masksToBounds = YES;
    [_meterBackground addSubview:_captureMeterBaseView];
    
    _captureMeterDesLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 8, K_Square_Width - 6, 20)];
    _captureMeterDesLabel.textAlignment = NSTextAlignmentCenter;
    _captureMeterDesLabel.font = [UIFont fontWithName:K_Square_Font_Name size:20];
    _captureMeterDesLabel.textColor = [UIColor lightGrayColor];
    _captureMeterDesLabel.backgroundColor = [UIColor clearColor];
    _captureMeterDesLabel.layer.cornerRadius = 5;
    _captureMeterDesLabel.text = @"LAST";
    _captureMeterDesLabel.layer.masksToBounds = YES;
    [_captureMeterBaseView addSubview:_captureMeterDesLabel];
    
    _captureMeterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, K_Square_Width, 30)];
    _captureMeterLabel.textAlignment = NSTextAlignmentCenter;
    _captureMeterLabel.font = [UIFont fontWithName:K_Square_Font_Name size:K_Square_FontSize_Des];
    _captureMeterLabel.textColor = [UIColor lightGrayColor];
    _captureMeterLabel.backgroundColor = [UIColor clearColor];
    _captureMeterLabel.layer.cornerRadius = 5;
    _captureMeterLabel.text = @"33";
    _captureMeterLabel.layer.masksToBounds = YES;
    [_captureMeterBaseView addSubview:_captureMeterLabel];
    
    _captureMeterImageView= [[UIImageView alloc] initWithFrame:CGRectMake(6, 48, 70-12, 20)];
    [_captureMeterImageView setImage:[UIImage imageNamed:@"capture_save"]];
    [_captureMeterImageView setContentMode:UIViewContentModeScaleAspectFit];
    [_captureMeterBaseView addSubview:_captureMeterImageView];
    
    UITapGestureRecognizer *oneTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(capture)];
    oneTap.numberOfTapsRequired = 1;
    [_captureMeterBaseView addGestureRecognizer:oneTap];
    
    [self reloadData];
    
    
    _formBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_count.png"]];
    _formBackground.frame = CGRectMake(0, _meterBackground.frame.origin.y + _meterBackground.frame.size.height + 10, 320, 150);
    _formBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_formBackground];
    
    _topScoreTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_meterBackground.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(_meterBackground.frame) - KNavigationBarHeight) style:UITableViewStylePlain];
    _topScoreTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _topScoreTable.backgroundView = nil;
    _topScoreTable.separatorColor = [UIColor clearColor];
    _topScoreTable.backgroundColor = kGrayColor;
    _topScoreTable.opaque = YES;
    _topScoreTable.delegate = self;
    
    __weak __typeof(&*self)weakSelf = self;
    _scoreArrayDataSource = [[ScoreArrayDataSource alloc] initWithReloadTableBlock:^() {
        [weakSelf reloadData];
    }];
    _scoreArrayDataSource.sortedByDate = NO;
    _topScoreTable.dataSource = _scoreArrayDataSource;
    
    [self.view addSubview:_topScoreTable];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:K_Notification_Sound_Captured object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failed) name:K_Notification_Record_Fail object:nil];
    
    
}

- (void) moreButtonCLicked {
//    MoreView *moreViewController = [[MoreView alloc] initWithNibName:nil bundle:nil];
//    [self.navigationController pushViewController:moreViewController animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:K_Notification_Show_Left_Setting_View object:nil userInfo:nil];
    
}

- (void) goToPurchasePage {
    PurchaseViewController *purchaseViewController = [[PurchaseViewController alloc] initWithNibName:@"PurchaseViewController" bundle:nil];
    [self.navigationController pushViewController:purchaseViewController animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:85.0/255 green:85.0/255 blue:85.0/255 alpha:1];
    
    [NSUserDefaultsHelper setLoggingPauseFlag:NO];
}


- (void)capture
{
    NSUInteger noOfRecords = [[SoundLevelCapture all] count];
    if ((noOfRecords >= 11) && ([NSUserDefaultsHelper isProVersion] == FALSE)) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You have reached the maximum number of recordings" message:@"You can upgrade to Noise Down PRO for an unlimited number." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        float lastNoisePeakValue = [NSUserDefaultsHelper lastNoisePeakValue];
        CaptureView *cap = [[CaptureView alloc] initWithReading:[NSNumber numberWithFloat:lastNoisePeakValue]];
        [self.navigationController pushViewController:cap animated:YES];
    }
    
    
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
    NSURL *fromURL = [FileHelper getDefaultRecordedTempAudioFile];
    
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
    headerView.backgroundColor = [UIColor colorWithRed:44.0/255 green:44.0/255 blue:44.0/255 alpha:1];
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
    _titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    _titleLabel.textColor = [UIColor lightGrayColor];
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
    
    //NSLog(@"observeValueForKeyPath in MeterView is called");
    
    if (_isAlarmPrepareToBeTriggered) {
        return;
    }
    
    if (([[IDPSoundBoard audioPlayerForKey:Key_PlayerRecorded] isPlaying])) {
        _infoMeterLabel.text = @"OFF";
        _infoMeterBaseView.hidden = NO;
        return;
    }
    
    if ([NSUserDefaultsHelper isLoggingPause]) {
        _infoMeterBaseView.hidden = NO;
        _infoMeterLabel.text = @"OFF";
        return;
    } else {
        _infoMeterBaseView.hidden = YES;
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
        
        int maxValue = [[[NMDecibelLogger defaultLogger] alertThreshold] intValue];
        _currentReadingLabel.text = [NSString stringWithFormat:@"%d", [_currentReading intValue]];
        [_soundLevelView setSoundLevelValue:[_currentReading floatValue] withMaxLevel:maxValue];
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
                            [self triggerAlarmConditionally];
                            _isAlarmPrepareToBeTriggered = NO;
                        });
                    } else {
                        [self triggerAlarmConditionally];
                    }
                    
                }
            } else {
                if ([NSUserDefaultsHelper isDelayAlarmSound]) {
                    _isAlarmPrepareToBeTriggered = YES;
                    double delayInSeconds = K_Second_DelayAlarmSound;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        [self triggerAlarmConditionally];
                        _isAlarmPrepareToBeTriggered = NO;
                    });
                } else {
                    [self triggerAlarmConditionally];
                }
            }
        }
        else
        {
            //NSLog(@"Not reach threahold");
            _startForDelayAlarmSound = [NSDate date];
            _currentReadingLabel.textColor = [UIColor lightGrayColor];
            [self success];
        }
        
        
        if ((threshold != nil) && ([threshold floatValue] < [_currentReading floatValue])) 
        {
            [NSUserDefaultsHelper setLastNoisePeak:[_currentReading floatValue]];
            
            _peakBaseView.hidden = NO;
            _peakLabel.text = [NSString stringWithFormat:@"%d", [_peakReading intValue]];
            
            _captureMeterLabel.text = [NSString stringWithFormat:@"%d", [_currentReading intValue]];
            _captureMeterBaseView.hidden = NO;
            
            _infoMeterBaseView.hidden = YES;
        
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
- (void) triggerAlarmConditionally {
    
    if ([NSUserDefaultsHelper isSilentMode] == FALSE && ([NSUserDefaultsHelper isContinuousMode] == FALSE)) {
        // in silent mode and continous mode, we never show cancel button
        _cancelButton.hidden = NO;
    }
    
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
            
            [self catchAndSaveSound_Without_StartLoggingAgain];//1.抓取音频，并存盘。这时没有loging,所以不用担心triggerAlarmConditionally会被不断执行
            
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
//    _peakBaseView.hidden = YES;
    [super viewDidDisappear:animated];
    
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSDictionary *dimensions = @{@"category": @"MeterView Screen"};
    [PFAnalytics trackEvent:@"page" dimensions:dimensions];
    
    if ([NSUserDefaultsHelper isProVersion]) {
        _topScoreTable.frame = CGRectMake(0, CGRectGetMaxY(_meterBackground.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(_meterBackground.frame));
    } else {
        _topScoreTable.frame = CGRectMake(0, CGRectGetMaxY(_meterBackground.frame), self.view.frame.size.width, self.view.frame.size.height - CGRectGetMaxY(_meterBackground.frame) - CGRectGetHeight(self.generalADButton.frame));
    }
    
    [self reloadData];
    
    [_soundLevelView refreshMeterImageView];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NMDecibelLogger defaultLogger] addObserver:self forKeyPath:@"currentReading" options:NSKeyValueObservingOptionNew context:NULL];
    
    if (([[NMDecibelLogger defaultLogger] logging]) && ([[NMDecibelLogger defaultLogger] playingAlarm] == FALSE)) {
        _cancelButton.hidden = YES;
        float lastPeakVal = [NSUserDefaultsHelper lastNoisePeakValue];
        if ((int)lastPeakVal == 0) {
          _captureMeterBaseView.hidden = YES;
        } else {
          _captureMeterBaseView.hidden = NO;
            _captureMeterLabel.text = [NSString stringWithFormat:@"%d",(int)lastPeakVal];
        }
        
    }
    
    float lastPeakValue = [NSUserDefaultsHelper lastNoisePeakValue];
    if ((int)lastPeakValue == 0) {
        _peakBaseView.hidden = YES;
    } else {
        _peakBaseView.hidden = NO;
        _peakLabel.text = [NSString stringWithFormat:@"%.f",lastPeakValue];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self hideTips];
    
    [[NMDecibelLogger defaultLogger] removeObserver:self forKeyPath:@"currentReading" context:NULL];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    
    _currentReadingLabel = nil;
    int maxValue = [[[NMDecibelLogger defaultLogger] alertThreshold] intValue];
    [_soundLevelView setSoundLevelValue:0 withMaxLevel:maxValue];
    _meterBackground = nil;
    
    [[NMDecibelLogger defaultLogger] stopLogging];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:K_Notification_Sound_Captured object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:K_Notification_Record_Fail object:nil];
    
    
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)alarmFinishedNotification:(NSNotification *)notification {
    //_captureMeterBaseView.hidden = YES;
    _cancelButton.hidden = YES;
    
//    CGRect rect = _currentReadingLabel.frame;
//    rect.origin.x = 10;
//    _currentReadingLabel.frame = rect;
}



/**
 *  K_Notification_Log_Pause_Switch_Setting
 */
- (void)pauseLoggingSwitchNotification:(NSNotification *)notification {
    
    if ([NSUserDefaultsHelper isLoggingPause]) {
        [[NMDecibelLogger defaultLogger] stopLogging];
        
        _infoMeterBaseView.hidden = NO;
        _infoMeterLabel.text = @"OFF";
        [NSUserDefaultsHelper setLoggingPauseFlag:YES];
        
    } else {
        [[NMDecibelLogger defaultLogger] startLogging];
        [NSUserDefaultsHelper setLoggingPauseFlag:NO];
        
        _infoMeterBaseView.hidden = YES;
    }
}

/**
 *  K_Notification_Update_Meter_Play_Status
 */
- (void) updateMeterPlayStatusNotification :(NSNotification *) notification {
    NSDictionary *dict = [notification userInfo];
    BOOL isPlaying = [dict objectForKey:@"isPlaying"];
    if (isPlaying) {
        _infoMeterBaseView.hidden = NO;
        _infoMeterLabel.text = @"OFF";
    } else {
        _infoMeterBaseView.hidden = YES;
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
    
    if (_cancelButton.hidden == FALSE) {
        return;
    }
    
    if ([NSUserDefaultsHelper isLoggingPause] == FALSE) {
        [[NMDecibelLogger defaultLogger] stopLogging];
        
        _infoMeterBaseView.hidden = NO;
        _infoMeterLabel.text = @"OFF";
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
        
        _infoMeterBaseView.hidden = YES;
        
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


#pragma mark – Tooltip related

- (void) switchTips {
    
    if ((_popTipMeterPause.isVisible) || (_popTipTabBarLevel.isVisible) || (_popTipMeterCapture.isVisible) || (_popTipTabBarScore.isVisible) || (_popTipInfo.isVisible)) {
        [self hideTips];
    } else {
        [self showTips];
    }
    
    
}

- (void) hideTips {
    [_popTipMeterPause hide];
    [_popTipMeterCapture hide];
    [_popTipTabBarLevel hide];
    [_popTipTabBarScore hide];
    [_popTipInfo hide];
}

- (void) showTips {
    
    if (_popTipInfo == nil) {
        _popTipInfo = [AMPopTip popTip];
        _popTipInfo.textColor = [UIColor blackColor];
        _popTipInfo.arrowSize = CGSizeMake(8, 20);
        _popTipInfo.popoverColor = [UIColor greenColor];
        _popTipInfo.shouldDismissOnTap = YES;
        _popTipInfo.shouldDismissOnTapOutside = NO;
        _popTipInfo.dismissHandler = ^() {
            
        };
    }
    [_popTipInfo showText:@"Turn help on or off" direction:AMPopTipDirectionDown maxWidth:140 inView:self.view fromFrame:CGRectMake(_infoButton.center.x, _infoButton.center.y + 20, 0, 0) duration:0];
    
    if (_popTipMeterPause == nil) {
        _popTipMeterPause = [AMPopTip popTip];
        _popTipMeterPause.textColor = [UIColor blackColor];
        _popTipMeterPause.arrowSize = CGSizeMake(20, 8);
        _popTipMeterPause.popoverColor = [UIColor greenColor];
        _popTipMeterPause.shouldDismissOnTap = YES;
        _popTipMeterPause.shouldDismissOnTapOutside = NO;
        _popTipMeterPause.dismissHandler = ^() {
            
        };
    }
    [_popTipMeterPause showText:@"Tap the meter to turn on and off" direction:AMPopTipDirectionRight maxWidth:140 inView:self.view fromFrame:CGRectMake(_meterBackground.center.x, _meterBackground.center.y, 0, 0) duration:0];
    
    if (_popTipMeterCapture == nil) {
        _popTipMeterCapture = [AMPopTip popTip];
        _popTipMeterCapture.textColor = [UIColor blackColor];
        _popTipMeterCapture.arrowSize = CGSizeMake(30, 8);
        _popTipMeterCapture.popoverColor = [UIColor greenColor];
        _popTipMeterCapture.shouldDismissOnTap = YES;
        _popTipMeterCapture.shouldDismissOnTapOutside = NO;
        _popTipMeterCapture.dismissHandler = ^() {
            
        };
    }
    if (_captureMeterBaseView.hidden == YES) {
        [_popTipMeterCapture hide];
    } else {
        [_popTipMeterCapture showText:@"Save the last noise to your list" direction:AMPopTipDirectionRight maxWidth:140 inView:self.view fromFrame:CGRectMake(CGRectGetMinX(_meterBackground.frame) + 65, CGRectGetMaxY(_meterBackground.frame) - 17, 0, 0) duration:0];
    }
    
    if (_popTipTabBarLevel == nil) {
        _popTipTabBarLevel = [AMPopTip popTip];
        _popTipTabBarLevel.textColor = [UIColor blackColor];
        _popTipTabBarLevel.arrowSize = CGSizeMake(8, 80);
        _popTipTabBarLevel.popoverColor = [UIColor greenColor];
        _popTipTabBarLevel.shouldDismissOnTap = YES;
        _popTipTabBarLevel.shouldDismissOnTapOutside = NO;
        _popTipTabBarLevel.dismissHandler = ^() {
            
        };
    }
    [_popTipTabBarLevel showText:@"Adjust the sensitivity of the meter" direction:AMPopTipDirectionUp maxWidth:180 inView:self.view fromFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 50, CGRectGetHeight(self.view.frame), 0, 0) duration:0];
    
    if (_popTipTabBarScore == nil) {
        _popTipTabBarScore = [AMPopTip popTip];
        _popTipTabBarScore.textColor = [UIColor blackColor];
        _popTipTabBarScore.arrowSize = CGSizeMake(8, 30);
        _popTipTabBarScore.popoverColor = [UIColor greenColor];
        _popTipTabBarScore.shouldDismissOnTap = YES;
        _popTipTabBarScore.shouldDismissOnTapOutside = NO;
        _popTipTabBarScore.dismissHandler = ^() {
            
        };
    }
    [_popTipTabBarScore showText:@"Name the noisiest" direction:AMPopTipDirectionUp maxWidth:140 inView:self.view fromFrame:CGRectMake(self.view.center.x, CGRectGetHeight(self.view.frame), 0, 0) duration:0];
    
}



@end
