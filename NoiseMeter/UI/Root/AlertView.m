//
//  AlertView.m
//  NoiseMeter
//
//  Created by Dave Finster on 6/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import "AlertView.h"
#import "NMDecibelLogger.h"
@interface AlertView ()

@end

@implementation AlertView

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
    
    _explanation = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(topImageView.frame) + 10, self.view.frame.size.width - 40, 40)];
    _explanation.numberOfLines = 2;
    _explanation.backgroundColor = [UIColor clearColor];
    _explanation.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    _explanation.textColor = [UIColor whiteColor];
    _explanation.text = @"Select the alarm level. The alarm will sound for levels recorded higher than this figure";
    [self.view addSubview:_explanation];
    
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(20, _explanation.frame.origin.y + _explanation.frame.size.height + 15, self.view.frame.size.width - 40, 150)];
    _pickerView.backgroundColor = [UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1];
    _pickerView.dataSource = self;
    _pickerView.delegate = self;
    _pickerView.showsSelectionIndicator = YES;
    [self.view addSubview:_pickerView];
    
    if ([NMDecibelLogger defaultLogger].alertThreshold) {
        [_pickerView selectRow:([[NMDecibelLogger defaultLogger].alertThreshold intValue] - 40) inComponent:0 animated:NO];
    }

    _setButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _setButton.frame = CGRectMake(20, CGRectGetMaxY(_pickerView.frame) + 5, 280, 37);
    [_setButton setBackgroundImage:[UIImage imageNamed:@"grey_button_for_level"] forState:UIControlStateNormal];
    [_setButton setBackgroundImage:[UIImage imageNamed:@"orange_button_for_level"] forState:UIControlStateHighlighted];
    [_setButton setTitle:@"Set Level" forState:UIControlStateNormal];
    [_setButton setTintColor:[UIColor whiteColor]];
    [_setButton addTarget:self action:@selector(set) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_setButton];
}

- (void)set
{
    [[NMDecibelLogger defaultLogger] setAlertThreshold:[NSNumber numberWithInt:([_pickerView selectedRowInComponent:0] + 40)]];
    self.tabBarController.selectedIndex = 0;
    
    [NSUserDefaultsHelper setLastNoisePeak:0.0]; //reset
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == _pickerView) 
    {
        return 90;
    }
    else 
    {
        return 3;
    }
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 44)];
    label.backgroundColor = [UIColor clearColor];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
      label.textColor = [UIColor whiteColor];
    } else {
      label.textColor = [UIColor blackColor];
    }
    
    label.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    label.text = [NSString stringWithFormat:@"%d", row + 40];
    [label setTextAlignment:NSTextAlignmentCenter];
    
    if (pickerView == _pickerView) {
        
        label.text = [NSString stringWithFormat:@"%d", row + 40];
    }
    else
    {
        if (row == 0)
        {
            label.text = @"Alarm";
        }
        else if(row == 1)
        {
            label.text = @"Siren";
        }
        else if (row == 2)
        {
            label.text = @"Alien";
        }
    }
    
    
    return label;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.screenName = @"AlertView Screen";

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _pickerView = nil;
    _setButton = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
