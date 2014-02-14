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
    
    [self style];
    
    _explanation = [[UILabel alloc] initWithFrame:CGRectMake(10, 89, self.view.frame.size.width - 20, 40)];
    _explanation.numberOfLines = 2;
    _explanation.backgroundColor = [UIColor clearColor];
    _explanation.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    _explanation.textColor = [UIColor whiteColor];
    _explanation.text = @"Select the alarm level. The alarm will sound for levels recorded higher than this figure";
    [self.view addSubview:_explanation];
    
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, _explanation.frame.origin.y + _explanation.frame.size.height + 15, self.view.frame.size.width, 150)];
    _pickerView.backgroundColor = [UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1];
    _pickerView.dataSource = self;
    _pickerView.delegate = self;
    _pickerView.showsSelectionIndicator = YES;
    [self.view addSubview:_pickerView];
    
    if ([NMDecibelLogger defaultLogger].alertThreshold) {
        [_pickerView selectRow:([[NMDecibelLogger defaultLogger].alertThreshold intValue] - 40) inComponent:0 animated:NO];
    }

    _setButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
      _setButton.frame = CGRectMake(20, _pickerView.frame.origin.y + _pickerView.frame.size.height + 30, 280, 37);
    } else {
      _setButton.frame = CGRectMake(20, _pickerView.frame.origin.y + _pickerView.frame.size.height + 60, 280, 37);
    }
    
    _setButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [_setButton setImage:[UIImage imageNamed:@"button_setalarm.png"] forState:UIControlStateNormal];
    [_setButton addTarget:self action:@selector(set) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_setButton];
}

- (void)set
{
    [[NMDecibelLogger defaultLogger] setAlertThreshold:[NSNumber numberWithInt:([_pickerView selectedRowInComponent:0] + 40)]];
    if ([_alertPickerView selectedRowInComponent:0] == 0) 
    {
        [[NMDecibelLogger defaultLogger] setAlarmName:@"home_alarm"];
    }
    else if([_alertPickerView selectedRowInComponent:0] == 1)
    {
        [[NMDecibelLogger defaultLogger] setAlarmName:@"siren_wail"];
    }
    else 
    {
        [[NMDecibelLogger defaultLogger] setAlarmName:@"scifialarm"];
    }
    self.tabBarController.selectedIndex = 0;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == _pickerView) 
    {
        return 60;
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
    self.trackedViewName = @"AlertView Screen";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _alertPickerView = nil;
    _pickerView = nil;
    _setButton = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
