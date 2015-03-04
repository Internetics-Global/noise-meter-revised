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
#import "UIButton+Extensions.h"
#import "AMPopTip.h"
#import <Parse/PFAnalytics.h>

#define K_Square_Width  70.0
#define K_Meter_Square_Background_Color  [UIColor colorWithRed:80.0/255 green:80.0/255 blue:80.0/255 alpha:0.6]
#define K_Square_FontSize 18
#define K_Square_FontSize_Des 26
#define K_Square_Font_Name  @"AvenirNext-Bold"

@interface AlertViewV2 () {
    UIView         * _currentReadingBaseView;
    UILabel        * _currentReadingLabel;
    UILabel        * _currentReadingDesLabel;
    
    UIView         * _setReadingBaseView;
    UILabel        * _setReadingLabel;
    UILabel        * _setReadingDesLabel;
    
    AMPopTip *_popTipSlider;
    AMPopTip *_popTipMetter;
    AMPopTip *_popTipSetLabel;
}

@end

@implementation AlertViewV2

- (NSString *)iconImageName {
    return @"icon_alert";
}

#pragma mark – Life cycle

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
    
    _infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_infoButton setImage:[UIImage imageNamed:@"button_info.png"] forState:UIControlStateNormal];
    _infoButton.frame = CGRectMake(self.view.frame.size.width - 35, 18, 20, 20);
    [_infoButton addTarget:self action:@selector(switchTips) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_infoButton];
    _infoButton.showsTouchWhenHighlighted = YES;
    [_infoButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    
    //step1
    _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_moreButton setImage:[UIImage imageNamed:@"icon_more.png"] forState:UIControlStateNormal];
    _moreButton.frame = CGRectMake(15, 18, 20, 20);
    [_moreButton addTarget:self action:@selector(moreButtonCLicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_moreButton];
    _moreButton.showsTouchWhenHighlighted = YES;
    [_moreButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    
    UIImageView *topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"set_noise_level_title"]];
    topImageView.frame = CGRectMake(0, KTopLogoHeight, CGRectGetWidth(self.view.frame), 40);
    topImageView.contentMode = UIViewContentModeCenter;
    topImageView.backgroundColor =[UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1];
    [self.view addSubview:topImageView];
    
    
    //step2
    CGRect frame;
    if (iPhone5) {
        frame = CGRectMake(20, CGRectGetMaxY(topImageView.frame) + 31, 280, 30);
    } else {
        frame = CGRectMake(20, CGRectGetMaxY(topImageView.frame) + 14, 280, 30);
    }
    _slider = [[UISlider alloc] initWithFrame:frame];
    [_slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [_slider setBackgroundColor:[UIColor clearColor]];
    _slider.minimumValue = kMinSoundLevel;
    _slider.maximumValue = kMaxSoundLevel;
    _slider.continuous = YES;
    [self.view addSubview:_slider];
    
    _sliderAttachedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(_slider.frame) - 10, 30, 10)];
    _sliderAttachedLabel.textAlignment = NSTextAlignmentCenter;
    _sliderAttachedLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:10];
    _sliderAttachedLabel.text = @"N/A";
    _sliderAttachedLabel.numberOfLines = 1;
    _sliderAttachedLabel.textColor = [UIColor whiteColor];
    _sliderAttachedLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_sliderAttachedLabel];
    
    UILabel *my40Lable = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(_slider.frame), 40, 20)];
    my40Lable.textAlignment = NSTextAlignmentLeft;
    my40Lable.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    my40Lable.text = @"40db";
    my40Lable.numberOfLines = 1;
    my40Lable.textColor = [UIColor whiteColor];
    my40Lable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:my40Lable];
    
    UILabel *my120Lable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_slider.frame) - 40, CGRectGetMaxY(_slider.frame), 40, 20)];
    my120Lable.textAlignment = NSTextAlignmentRight;
    my120Lable.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    my120Lable.text = @"120db";
    my120Lable.numberOfLines = 1;
    my120Lable.textColor = [UIColor whiteColor];
    my120Lable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:my120Lable];

    
    //step3
    if (iPhone5) {
        frame = CGRectMake((320-150)/2, CGRectGetMaxY(_slider.frame) + 102, 150, 150);
    } else {
        frame =  CGRectMake((320-150)/2, CGRectGetMaxY(_slider.frame) + 82, 150, 150);
    }
    _soundLevelView = [[SoundLevelView alloc] initWithFrame:frame];
    _soundLevelView.autoresizingMask = UIViewAutoresizingNone;
    [_soundLevelView setupSubviews];
    [self.view addSubview:_soundLevelView];
    
    
    //step4
    if (iPhone5) {
        frame = CGRectMake(27, CGRectGetMaxY(_soundLevelView.frame) + 40, 242, 20);
    } else {
        frame = CGRectMake(27, CGRectGetMaxY(_soundLevelView.frame) + 4, 242, 20);
    }
    UILabel *moreLabel = [[UILabel alloc] initWithFrame:frame];
    moreLabel.textAlignment = NSTextAlignmentCenter;
    moreLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    moreLabel.text = @"For more settings please click";
    moreLabel.numberOfLines = 1;
    moreLabel.textColor = [UIColor whiteColor];
    moreLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:moreLabel];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreButton setImage:[UIImage imageNamed:@"icon_more.png"] forState:UIControlStateNormal];
    [moreButton setContentMode:UIViewContentModeScaleAspectFit];
    moreButton.autoresizingMask = UIViewAutoresizingNone;
    moreButton.frame = CGRectMake(CGRectGetMaxX(moreLabel.frame), CGRectGetMinY(moreLabel.frame), 20, 20);
    [moreButton addTarget:self action:@selector(moreButtonCLicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:moreButton];
    
    
    //step5
    if (iPhone5) {
        frame = CGRectMake(20, CGRectGetMaxY(_slider.frame) + 42, K_Square_Width, K_Square_Width);
    } else {
        frame = CGRectMake(20, CGRectGetMaxY(_slider.frame) + 37, K_Square_Width, K_Square_Width);
    }
    _currentReadingBaseView = [[UIView alloc] initWithFrame:frame];
    _currentReadingBaseView.backgroundColor = K_Meter_Square_Background_Color;
    _currentReadingBaseView.layer.cornerRadius = 8;
    _currentReadingBaseView.layer.masksToBounds = YES;
    [self.view addSubview:_currentReadingBaseView];
    
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
    
    frame = CGRectMake(320- 20 - K_Square_Width, CGRectGetMinY(_currentReadingBaseView.frame), K_Square_Width, K_Square_Width);
    _setReadingBaseView = [[UIView alloc] initWithFrame:frame];
    _setReadingBaseView.backgroundColor = K_Meter_Square_Background_Color;
    _setReadingBaseView.layer.cornerRadius = 8;
    _setReadingBaseView.layer.masksToBounds = YES;
    [self.view addSubview:_setReadingBaseView];
    
    _setReadingDesLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 11, K_Square_Width, 25)];
    _setReadingDesLabel.textAlignment = NSTextAlignmentCenter;
    _setReadingDesLabel.font = [UIFont fontWithName:K_Square_Font_Name size:K_Square_FontSize];
    _setReadingDesLabel.textColor = [UIColor lightGrayColor];
    _setReadingDesLabel.backgroundColor = [UIColor clearColor];
    _setReadingDesLabel.layer.cornerRadius = 5;
    _setReadingDesLabel.text = @"SET";
    _setReadingDesLabel.layer.masksToBounds = YES;
    [_setReadingBaseView addSubview:_setReadingDesLabel];
    
    _setReadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, K_Square_Width, 40)];
    _setReadingLabel.textAlignment = NSTextAlignmentCenter;
    _setReadingLabel.font = [UIFont fontWithName:K_Square_Font_Name size:K_Square_FontSize_Des];
    _setReadingLabel.textColor = [UIColor lightGrayColor];
    _setReadingLabel.backgroundColor = [UIColor clearColor];
    _setReadingLabel.layer.cornerRadius = 5;
    _setReadingLabel.layer.masksToBounds = YES;
    [_setReadingBaseView addSubview:_setReadingLabel];
    
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor colorWithRed:55.0/255 green:55.0/255 blue:55.0/255 alpha:1];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSDictionary *dimensions = @{@"category": @"AlertView Screen"};
    [PFAnalytics trackEvent:@"page" dimensions:dimensions];
    
    [[NMDecibelLogger defaultLogger] addObserver:self forKeyPath:@"currentReading" options:NSKeyValueObservingOptionNew context:NULL];
    
    NSNumber *alertThreshold = [NMDecibelLogger defaultLogger].alertThreshold;
    if (alertThreshold) {
        _slider.value = [alertThreshold integerValue];
    } else {
        _slider.value = 90;
        alertThreshold = [NSNumber numberWithInt:90];
        [[NMDecibelLogger defaultLogger] setAlertThreshold:[NSNumber numberWithInt:90]];
    }
    [self updateSilderAttachedPositionWithAnimation:NO];
    
    [_soundLevelView refreshMeterImageView];
    _setReadingLabel.text = [NSString stringWithFormat:@"%d",[alertThreshold intValue]];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self hideTips];
    
    [[NMDecibelLogger defaultLogger] removeObserver:self forKeyPath:@"currentReading" context:NULL];
}

- (void) viewDidDisappear:(BOOL)animated  {
    [super viewDidDisappear:animated];
    
    

}


- (void)viewDidUnload
{
    [super viewDidUnload];
    _setButton = nil;
    
}



- (void) sliderAction:(UISlider *) slider {
    
    [self updateSilderAttachedPositionWithAnimation:YES];
    
    [[NMDecibelLogger defaultLogger] setAlertThreshold:[NSNumber numberWithInt:[_slider value]]];
    
    [NSUserDefaultsHelper setLastNoisePeak:0.0]; //reset
    
    _setReadingLabel.text = [NSString stringWithFormat:@"%d",(int)slider.value];
    
}

- (void) updateSilderAttachedPositionWithAnimation:(BOOL) animated {
    float interval = _slider.maximumValue - _slider.minimumValue;
    float width = CGRectGetWidth(_slider.frame) - CGRectGetWidth(_sliderAttachedLabel.frame);
    
    int xPosition = CGRectGetMinX(_slider.frame) + width * (_slider.value - _slider.minimumValue)/interval;
    
    double duration = 0;
    if (animated) {
        animated = 0.3;
    }
    
    CGRect rect = _sliderAttachedLabel.frame;
    rect.origin.x = xPosition;
    [UIView animateWithDuration:duration animations:^{
        _sliderAttachedLabel.frame = rect;
    } completion:^(BOOL finished) {
        _sliderAttachedLabel.text = [NSString stringWithFormat:@"%d",(int)_slider.value];
    }];
}


- (void) moreButtonCLicked {
    //    MoreView *moreViewController = [[MoreView alloc] initWithNibName:nil bundle:nil];
    //    [self.navigationController pushViewController:moreViewController animated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:K_Notification_Show_Left_Setting_View object:nil userInfo:nil];
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    //NSLog(@"observeValueForKeyPath in AlertViewV2 is called");
    
    if ([keyPath isEqualToString:@"currentReading"])
    {
        NSNumber *currentReading = [[NMDecibelLogger defaultLogger] currentReading];
        
        if ([currentReading integerValue] <= 0) {
        } else {
            
            NSNumber *alertThreshold = [[NMDecibelLogger defaultLogger] alertThreshold];
            if (alertThreshold == nil) {
                alertThreshold = [NSNumber numberWithFloat:90.0f];
            }
            
            _currentReadingLabel.text = [NSString stringWithFormat:@"%d",[currentReading intValue]];
          [_soundLevelView setSoundLevelValue:[currentReading integerValue] withMaxLevel:[alertThreshold intValue]];
        }
    
        
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark – Tooltip

- (void) switchTips {
    
    if ((_popTipSlider.isVisible) || (_popTipMetter.isVisible) || (_popTipSetLabel.isVisible)) {
        [self hideTips];
    } else {
        [self showTips];
    }
    
    
}

- (void) hideTips {
    [_popTipSlider hide];
    [_popTipMetter hide];
    [_popTipSetLabel hide];
}

- (void) showTips {
    
    __weak __typeof(&*self)weakSelf = self;
    
    if (_popTipSlider == nil) {
        _popTipSlider = [AMPopTip popTip];
        _popTipSlider.textColor = [UIColor blackColor];
        _popTipSlider.arrowSize = CGSizeMake(8, 20);
        _popTipSlider.popoverColor = [UIColor greenColor];
        _popTipSlider.shouldDismissOnTap = YES;
        _popTipSlider.shouldDismissOnTapOutside = NO;
        _popTipSlider.dismissHandler = ^() {
            
        };
    }
    [_popTipSlider showText:@"Adjust the decibel level to suit the maximum volume level you want to get" direction:AMPopTipDirectionUp maxWidth:260 inView:self.view fromFrame:CGRectMake(_slider.center.x + 20, _slider.center.y, 0, 0) duration:0];
    
    if (_popTipMetter == nil) {
        _popTipMetter = [AMPopTip popTip];
        _popTipMetter.textColor = [UIColor blackColor];
        _popTipMetter.arrowSize = CGSizeMake(20, 8);
        _popTipMetter.popoverColor = [UIColor greenColor];
        _popTipMetter.shouldDismissOnTap = YES;
        _popTipMetter.shouldDismissOnTapOutside = NO;
        _popTipMetter.dismissHandler = ^() {
            
        };
    }
    [_popTipMetter showText:@"When you adjust the decibel level, see how it affects the meter" direction:AMPopTipDirectionLeft maxWidth:200 inView:self.view fromFrame:CGRectMake(_soundLevelView.center.x, _soundLevelView.center.y, 0, 0) duration:0];
    
    if (_popTipSetLabel == nil) {
        _popTipSetLabel = [AMPopTip popTip];
        _popTipSetLabel.textColor = [UIColor blackColor];
        _popTipSetLabel.arrowSize = CGSizeMake(8, 110);
        _popTipSetLabel.popoverColor = [UIColor greenColor];
        _popTipSetLabel.shouldDismissOnTap = YES;
        _popTipSetLabel.shouldDismissOnTapOutside = NO;
        _popTipSetLabel.dismissHandler = ^() {
            
        };
    }
    [_popTipSetLabel showText:@"This is the current setting" direction:AMPopTipDirectionDown maxWidth:180 inView:self.view fromFrame:CGRectMake(_setReadingBaseView.center.x, _setReadingBaseView.center.y, 0, 0) duration:0];
    
}

@end
