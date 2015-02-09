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

#import "CAFAudioHelper.h"
#import "SoundLevelCapture.h"
#import "FileHelper.h"
#import "PlayHelper.h"
#import "NSUserDefaultsHelper.h"

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
        _playbackButton.frame = CGRectMake(_playbackButton.frame.origin.x, _playbackButton.frame.origin.y + 160, _playbackButton.frame.size.width, _playbackButton.frame.size.height);
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self style];
    _meterBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_count.png"]];
    _meterBackground.frame = CGRectMake(0, 79, 320, 150);
    _meterBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_meterBackground];
    
    _currentReadingLabel = [[UILabel alloc] initWithFrame:_meterBackground.frame];
    _currentReadingLabel.textAlignment = UITextAlignmentCenter;
    _currentReadingLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:90];
    _currentReadingLabel.text = [NSString stringWithFormat:@"%.1f", [_reading floatValue]];
    _currentReadingLabel.center = _meterBackground.center;
    _currentReadingLabel.textColor = [UIColor redColor];
    _currentReadingLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_currentReadingLabel];
    
    _formBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_count.png"]];
    _formBackground.frame = CGRectMake(0, _meterBackground.frame.origin.y + _meterBackground.frame.size.height + 10, 320, 150);
    _formBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_formBackground];
    
    _enterLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, _formBackground.frame.origin.y + 10, self.view.frame.size.width - 40, 20)];
    _enterLabel.backgroundColor = [UIColor clearColor];
    _enterLabel.textColor = [UIColor whiteColor];
    _enterLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:_enterLabel.font.pointSize];
    _enterLabel.text = @"Enter name:";
    [self.view addSubview:_enterLabel];
    
    _nameField = [[UITextField alloc] initWithFrame:CGRectMake(20, _enterLabel.frame.origin.y + _enterLabel.frame.size.height + 20, self.view.frame.size.width - 40, 33)];
    [_nameField setBackgroundColor:[UIColor whiteColor]];
    [_nameField setTextAlignment:NSTextAlignmentCenter];
    _nameField.delegate = self;
    [self.view addSubview:_nameField];
    
    _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveButton.frame =CGRectMake(20, _nameField.frame.origin.y + _nameField.frame.size.height + 22, 280, 37);
    _saveButton.backgroundColor = [UIColor orangeColor];
    [_saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [_saveButton setTintColor:[UIColor whiteColor]];
    _saveButton.showsTouchWhenHighlighted = YES;
    [_saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_saveButton];
    
    _playbackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _playbackButton.frame =CGRectMake(20, _saveButton.frame.origin.y + _saveButton.frame.size.height + 22, 280, 37);
    _playbackButton.backgroundColor = [UIColor darkGrayColor];
    [_playbackButton setTitle:@"Playback" forState:UIControlStateNormal];
    [_playbackButton setTintColor:[UIColor whiteColor]];
    _playbackButton.showsTouchWhenHighlighted = YES;
    [_playbackButton addTarget:self action:@selector(playback) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playbackButton];
    if ([NSUserDefaultsHelper isAdRemoved]) {
        _playbackButton.hidden = FALSE;
    } else {
        _playbackButton.hidden = TRUE;
    }
    
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
    
    NSURL *fromURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp.caf"]];
    [PlayHelper playAudioFile:fromURL];
    
}


- (void)save
{
    if ((_nameField.text == nil) || (_nameField.text.length == 0)) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    //Record last 10 second audio just before alarm
    NSURL *fromURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp.caf"]];
    
    NSDate *date = [NSDate date];
	NSString *dateString = [FileHelper convertDate:date];
    
    NSURL *toURL = [FileHelper getRecordedAudioFile:dateString];
    if ([[NMDecibelLogger defaultLogger] logging]) {
      [[NMDecibelLogger defaultLogger] stopLogging];
    }
    [CAFAudioHelper saveLast10SecondAudio:fromURL toURL:toURL];
    [[NMDecibelLogger defaultLogger] startLogging];
    
    SoundLevelCapture *cap = [SoundLevelCapture instance];
    cap.name = _nameField.text;
    cap.soundLevel = [NSDecimalNumber decimalNumberWithString:[_reading stringValue]];
    cap.date = date;
    [[NMDataManager defaultManager] saveContext];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SoundCaptured" object:nil];
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
    self.screenName = @"CaptureView Screen";
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
