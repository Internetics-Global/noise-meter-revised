//
//  AlertView.m
//  NoiseMeter
//
//  Created by Dave Finster on 6/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import "AlertViewV2.h"
#import "NMDecibelLogger.h"
#import "SoundLevelView.h"

@interface AlertViewV2 ()

@end

@implementation AlertViewV2

- (NSString *)iconImageName {
    return @"icon_alert";
}

- (id)init
{
    self = [super init];
    self.title = @"Set Level";
    self.tabBarItem.image = [UIImage imageNamed:@"icon_alert.png"];
    return self;
}
- (void)loadView
{
    [super loadView];
    
    [self style:NO];
    
    UIImageView *topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"set_noise_level_title"]];
    topImageView.frame = CGRectMake(0, KTopLogoHeight, CGRectGetWidth(self.view.frame), 40);
    topImageView.contentMode = UIViewContentModeCenter;
    topImageView.backgroundColor =[UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1];
    [self.view addSubview:topImageView];
    
    
    
    CGRect frame = CGRectMake(20, CGRectGetMaxY(topImageView.frame) + 30, 280, 10);
    _slider = [[UISlider alloc] initWithFrame:frame];
    [_slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [_slider setBackgroundColor:[UIColor clearColor]];
    _slider.minimumValue = kMinSoundLevel;
    _slider.maximumValue = kMaxSoundLevel;
    _slider.continuous = YES;
    [self.view addSubview:_slider];
    
    UILabel *my40Lable = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_slider.frame) + 10, 40, 20)];
    my40Lable.textAlignment = NSTextAlignmentLeft;
    my40Lable.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    my40Lable.text = @"40db";
    my40Lable.numberOfLines = 1;
    my40Lable.textColor = [UIColor whiteColor];
    my40Lable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:my40Lable];
    
    UILabel *my120Lable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_slider.frame) - 40, CGRectGetMaxY(_slider.frame) + 10, 40, 20)];
    my120Lable.textAlignment = NSTextAlignmentRight;
    my120Lable.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    my120Lable.text = @"120db";
    my120Lable.numberOfLines = 1;
    my120Lable.textColor = [UIColor whiteColor];
    my120Lable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:my120Lable];
    
    _setButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _setButton.frame = CGRectMake(20, CGRectGetMaxY(_slider.frame) + 40, 280, 37);
    [_setButton setBackgroundImage:[UIImage imageNamed:@"grey_button_for_level"] forState:UIControlStateNormal];
    [_setButton setBackgroundImage:[UIImage imageNamed:@"orange_button_for_level"] forState:UIControlStateHighlighted];
    [_setButton setTitle:@"Set Level" forState:UIControlStateNormal];
    [_setButton setTintColor:[UIColor whiteColor]];
    [_setButton addTarget:self action:@selector(set) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_setButton];
    
    _soundLevelView = [[SoundLevelView alloc] initWithFrame:CGRectMake(60, CGRectGetMaxY(_setButton.frame) + 20, 200, 200)];
    _soundLevelView.autoresizingMask = UIViewAutoresizingNone;
    [_soundLevelView setupSubviews];
    _soundLevelView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_soundLevelView];
    
}


- (void)set
{
    
    int val = [_slider value];
    
    [[NMDecibelLogger defaultLogger] setAlertThreshold:[NSNumber numberWithInt:val]];
    self.tabBarController.selectedIndex = 0;
    
    [NSUserDefaultsHelper setLastNoisePeak:0.0]; //reset
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.screenName = @"AlertView Screen";
    
    
    
    NSNumber *alertThreshold = [NMDecibelLogger defaultLogger].alertThreshold;
    if (alertThreshold) {
        _slider.value = [alertThreshold integerValue];
    } else {
        _slider.value = 90;
        alertThreshold = [NSNumber numberWithInt:90];
        [[NMDecibelLogger defaultLogger] setAlertThreshold:[NSNumber numberWithInt:90]];
    }
    
    [_setButton setTitle:[NSString stringWithFormat:@"Set Level (%d)",[alertThreshold intValue]] forState:UIControlStateNormal];
    
    [_soundLevelView setSoundLevelValue:[alertThreshold integerValue] withMaxLevel:120];
    [_soundLevelView refreshMeterImageView];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _setButton = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void) sliderAction:(UISlider *) slider {
    
    int slideVal = (int)slider.value;
    
    [_setButton setTitle:[NSString stringWithFormat:@"Set Level (%d)",slideVal] forState:UIControlStateNormal];
    
    [_soundLevelView setSoundLevelValue:slideVal withMaxLevel:kMaxSoundLevel];
    
}


@end
