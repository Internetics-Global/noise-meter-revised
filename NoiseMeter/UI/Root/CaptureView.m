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

@interface CaptureView ()

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
    [UIView animateWithDuration:0.25 animations:^(void){
        _formBackground.frame = CGRectMake(_formBackground.frame.origin.x, _formBackground.frame.origin.y - 160, _formBackground.frame.size.width, _formBackground.frame.size.height);
        _enterLabel.frame = CGRectMake(_enterLabel.frame.origin.x, _enterLabel.frame.origin.y - 160, _enterLabel.frame.size.width, _enterLabel.frame.size.height);
        _nameField.frame = CGRectMake(_nameField.frame.origin.x, _nameField.frame.origin.y - 160, _nameField.frame.size.width, _nameField.frame.size.height);
        _saveButton.frame = CGRectMake(_saveButton.frame.origin.x, _saveButton.frame.origin.y - 160, _saveButton.frame.size.width, _saveButton.frame.size.height);
    }];
}

- (void)keyboardDown
{
    [UIView animateWithDuration:0.25 animations:^(void){
        _formBackground.frame = CGRectMake(_formBackground.frame.origin.x, _formBackground.frame.origin.y + 160, _formBackground.frame.size.width, _formBackground.frame.size.height);
        _enterLabel.frame = CGRectMake(_enterLabel.frame.origin.x, _enterLabel.frame.origin.y + 160, _enterLabel.frame.size.width, _enterLabel.frame.size.height);
        _nameField.frame = CGRectMake(_nameField.frame.origin.x, _nameField.frame.origin.y + 160, _nameField.frame.size.width, _nameField.frame.size.height);
        _saveButton.frame = CGRectMake(_saveButton.frame.origin.x, _saveButton.frame.origin.y + 160, _saveButton.frame.size.width, _saveButton.frame.size.height);
    }];
}

- (void)loadView
{
    [super loadView];
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
    [_nameField setBorderStyle:UITextBorderStyleRoundedRect];
    _nameField.delegate = self;
    [self.view addSubview:_nameField];
    
    _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveButton.frame =CGRectMake(20, _nameField.frame.origin.y + _nameField.frame.size.height + 22, 280, 37);
    [_saveButton setImage:[UIImage imageNamed:@"button_save.png"] forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_saveButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardUp) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDown) name:UIKeyboardWillHideNotification object:nil];
}

- (void)save
{
    if ((_nameField.text == nil) || (_nameField.text.length == 0)) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    SoundLevelCapture *cap = [SoundLevelCapture instance];
    cap.name = _nameField.text;
    cap.soundLevel = [NSDecimalNumber decimalNumberWithString:[_reading stringValue]];
    cap.date = [NSDate date];
    [[NMDataManager defaultManager] saveContext];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SoundCaptured" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
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
    self.trackedViewName = @"CaptureView Screen";
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
