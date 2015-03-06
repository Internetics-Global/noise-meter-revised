//
//  CaptureView.m
//  NoiseMeter
//
//  Created by Dave Finster on 13/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import "CaptureView.h"
#import "SoundLevelCapture.h"
#import "NMDataManager.h"
#import "NMDecibelLogger.h"
#import "IDPSoundBoard.h"
#import "SoundLevelCapture.h"
#import "FileHelper.h"
#import "NSUserDefaultsHelper.h"
#import <Parse/PFAnalytics.h>


@interface CaptureView () {
    BOOL   _up;
    BOOL   _down;
}

@end

@implementation CaptureView

- (id)initWithReading:(NSNumber *)reading
{
    self = [super init];
    _reading = reading;
    return self;
}

- (void)keyboardUp
{
    
    if (_up == true) {
        return;
    }
    
    _up = true;
    _down = false;

    
    [UIView animateWithDuration:0.25 animations:^(void){
        _formBackground.frame = CGRectMake(_formBackground.frame.origin.x, _formBackground.frame.origin.y - 160, _formBackground.frame.size.width, _formBackground.frame.size.height);
        _enterLabel.frame = CGRectMake(_enterLabel.frame.origin.x, _enterLabel.frame.origin.y - 160, _enterLabel.frame.size.width, _enterLabel.frame.size.height);
        _nameField.frame = CGRectMake(_nameField.frame.origin.x, _nameField.frame.origin.y - 160, _nameField.frame.size.width, _nameField.frame.size.height);
        _saveButton.frame = CGRectMake(_saveButton.frame.origin.x, _saveButton.frame.origin.y - 160, _saveButton.frame.size.width, _saveButton.frame.size.height);
        _cancelButton.frame = CGRectMake(_cancelButton.frame.origin.x, _cancelButton.frame.origin.y - 160, _cancelButton.frame.size.width, _cancelButton.frame.size.height);
        _playbackButton.frame = CGRectMake(_playbackButton.frame.origin.x, _playbackButton.frame.origin.y - 160, _playbackButton.frame.size.width, _playbackButton.frame.size.height);

    }];
}

- (void)keyboardDown
{
    if (_down == true) {
        return;
    }
    
    _down = true;
    _up = false;

    
    [UIView animateWithDuration:0.25 animations:^(void){
        _formBackground.frame = CGRectMake(_formBackground.frame.origin.x, _formBackground.frame.origin.y + 160, _formBackground.frame.size.width, _formBackground.frame.size.height);
        _enterLabel.frame = CGRectMake(_enterLabel.frame.origin.x, _enterLabel.frame.origin.y + 160, _enterLabel.frame.size.width, _enterLabel.frame.size.height);
        _nameField.frame = CGRectMake(_nameField.frame.origin.x, _nameField.frame.origin.y + 160, _nameField.frame.size.width, _nameField.frame.size.height);
        _saveButton.frame = CGRectMake(_saveButton.frame.origin.x, _saveButton.frame.origin.y + 160, _saveButton.frame.size.width, _saveButton.frame.size.height);
        _cancelButton.frame = CGRectMake(_cancelButton.frame.origin.x, _cancelButton.frame.origin.y + 160, _cancelButton.frame.size.width, _cancelButton.frame.size.height);
        _playbackButton.frame = CGRectMake(_playbackButton.frame.origin.x, _playbackButton.frame.origin.y + 160, _playbackButton.frame.size.width, _playbackButton.frame.size.height);

    }];
    
    
}

- (void)loadView
{
    [super loadView];
    [self style:NO];
    _meterBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_count.png"]];
    _meterBackground.frame = CGRectMake(0, KTopLogoHeight, 320, 130);
    _meterBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_meterBackground];
    
    _currentReadingLabel = [[UILabel alloc] initWithFrame:_meterBackground.frame];
    _currentReadingLabel.textAlignment = NSTextAlignmentCenter;
    _currentReadingLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:90];
    _currentReadingLabel.text = [NSString stringWithFormat:@"%.1f", [_reading floatValue]];
    _currentReadingLabel.center = _meterBackground.center;
    _currentReadingLabel.textColor = [UIColor redColor];
    _currentReadingLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_currentReadingLabel];
    
    _formBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_count.png"]];
    _formBackground.frame = CGRectMake(0, CGRectGetMaxY(_meterBackground.frame) + 10, 320, 180);
    _formBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_formBackground];
    
    _enterLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, _formBackground.frame.origin.y + 10, self.view.frame.size.width - 40, 20)];
    _enterLabel.backgroundColor = [UIColor clearColor];
    _enterLabel.textColor = [UIColor whiteColor];
    _enterLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:_enterLabel.font.pointSize];
    _enterLabel.text = @"Enter name:";
    [self.view addSubview:_enterLabel];
    
    _nameField = [[UITextField alloc] initWithFrame:CGRectMake(20, _enterLabel.frame.origin.y + _enterLabel.frame.size.height + 10, self.view.frame.size.width - 40, 33)];
//    [_nameField setBorderStyle:UITextBorderStyleRoundedRect];
    _nameField.backgroundColor = [UIColor whiteColor];
    [_nameField setTextAlignment:NSTextAlignmentCenter];
    _nameField.delegate = self;
    [self.view addSubview:_nameField];
    
    _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveButton.frame =CGRectMake(20, _nameField.frame.origin.y + _nameField.frame.size.height + 10, 280, 37);
    [_saveButton setBackgroundImage:[UIImage imageNamed:@"grey_button_for_level"] forState:UIControlStateNormal];
    [_saveButton setBackgroundImage:[UIImage imageNamed:@"orange_button_for_level"] forState:UIControlStateHighlighted];
//    _saveButton.layer.cornerRadius = 5;
//    _saveButton.layer.masksToBounds = YES;
    [_saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [_saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_saveButton];
    
    
    _playbackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _playbackButton.frame =CGRectMake(20, _saveButton.frame.origin.y + _saveButton.frame.size.height + 10, 280, 37);
    [_playbackButton setBackgroundImage:[UIImage imageNamed:@"grey_button_for_level"] forState:UIControlStateNormal];
    [_playbackButton setBackgroundImage:[UIImage imageNamed:@"orange_button_for_level"] forState:UIControlStateHighlighted];
//    _playbackButton.layer.cornerRadius = 5;
//    _playbackButton.layer.masksToBounds = YES;
    [_playbackButton setTitle:@"Playback" forState:UIControlStateNormal];
    [_playbackButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_playbackButton addTarget:self action:@selector(playback) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playbackButton];
    if ([NSUserDefaultsHelper isProVersion]) {
        _playbackButton.hidden = FALSE;
    } else {
        _playbackButton.hidden = TRUE;
    }
    
    _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if ([NSUserDefaultsHelper isProVersion]) {
        _playbackButton.frame =CGRectMake(20, _saveButton.frame.origin.y + _saveButton.frame.size.height + 10, 130, 37);
        _cancelButton.frame =CGRectMake(20 + 150, _saveButton.frame.origin.y + _saveButton.frame.size.height + 10, 130, 37);
        [_cancelButton setBackgroundImage:[UIImage imageNamed:@"grey_button_for_level"] forState:UIControlStateNormal];
    } else {
        _cancelButton.frame =CGRectMake(20, _saveButton.frame.origin.y + _saveButton.frame.size.height + 10, 280, 37);
        [_cancelButton setBackgroundImage:[UIImage imageNamed:@"grey_button_for_level"] forState:UIControlStateNormal];
    }
    [_cancelButton setBackgroundImage:[UIImage imageNamed:@"orange_button_for_level"] forState:UIControlStateHighlighted];
    ;
//    _cancelButton.layer.cornerRadius = 5;
//    _cancelButton.layer.masksToBounds = YES;
    [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cancelButton];

    

}

-(void) viewWillAppear: (BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(keyboardUp)
               name:UIKeyboardWillShowNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(keyboardDown)
               name:UIKeyboardWillHideNotification
             object:nil];
    
}

- (void) viewWillDisappear: (BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self
                  name:UIKeyboardWillShowNotification
                object:nil];
    [nc removeObserver:self
                  name:UIKeyboardWillHideNotification
                object:nil];
}

- (void) playback {
    
    NSURL *fromURL = [FileHelper getDefaultRecordedTempAudioFile];
    NSURL *capturePlaybackURL = [FileHelper getFileForCapturePlayback];
    [IDPSoundBoard saveLast10SecondAudio:fromURL toURL:capturePlaybackURL];
    
    [IDPSoundBoard addAudioAtPath:[capturePlaybackURL path] forKey:Key_PlayerRecorded forType:EnumSoundType_Recorded];
    AVAudioPlayer *player = [IDPSoundBoard audioPlayerForKey:Key_PlayerRecorded];
    player.numberOfLoops = 0;  // Endless
    [IDPSoundBoard playAudioForKey:Key_PlayerRecorded fadeInInterval:2.0 withFinishBlock:nil];
    
}


- (void) cancel {
    [[NMDecibelLogger defaultLogger] stopLogging];
    [[NMDecibelLogger defaultLogger] startLogging];
    [self.navigationController popViewControllerAnimated:YES];
    [NMDecibelLogger defaultLogger].playingAlarm = FALSE;
}

- (void)save
{
    if ((_nameField.text == nil) || (_nameField.text.length == 0)) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    //Record last 10 second audio just before alarm
    NSURL *fromURL = [FileHelper getDefaultRecordedTempAudioFile];
    
    NSDate *date = [NSDate date];
	NSString *dateString = [FileHelper convertDate:date];
    
    NSURL *toURL = [FileHelper getRecordedAudioFile:dateString];
    if ([[NMDecibelLogger defaultLogger] logging]) {
      [[NMDecibelLogger defaultLogger] stopLogging];
    }
    [IDPSoundBoard saveLast10SecondAudio:fromURL toURL:toURL];
    [[NMDecibelLogger defaultLogger] startLogging];
    
    SoundLevelCapture *cap = [SoundLevelCapture instance];
    cap.name = _nameField.text;
    cap.soundLevel = [NSDecimalNumber decimalNumberWithString:[_reading stringValue]];
    cap.date = date;
    [[NMDataManager defaultManager] saveContext];
    [[NSNotificationCenter defaultCenter] postNotificationName:K_Notification_Sound_Captured object:nil];
    
    [NSUserDefaultsHelper setLastNoisePeak:0];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    [NMDecibelLogger defaultLogger].playingAlarm = FALSE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _currentReadingLabel = nil;
    
    _meterBackground = nil;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSDictionary *dimensions = @{@"category": @"CaptureView Screen"};
    [PFAnalytics trackEvent:@"page" dimensions:dimensions];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    [self viewDidUnload];
    _reading = nil;
}

@end
