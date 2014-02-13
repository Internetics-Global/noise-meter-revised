//
//  SelectAlertView.m
//  NoiseMeter
//
//  Created by Dave Finster on 21/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import "SelectAlertView.h"
#import "NMDecibelLogger.h"
#import "CreateAlarmSoundViewController.h"
#import "FileHelper.h"
#import "PurchaseViewController.h"

@interface SelectAlertView ()

@end

@implementation SelectAlertView

- (void)loadView
{
    [super loadView];
    
    [self style];
    
    _alertTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 105, self.view.frame.size.width, self.view.frame.size.height - 105) style:UITableViewStyleGrouped];
    _alertTable.delegate = self;
    _alertTable.dataSource = self;
    _alertTable.opaque = NO;
    _alertTable.backgroundView = nil;
    _alertTable.backgroundColor = [UIColor clearColor];
    _alertTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_alertTable];

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *setButton = [UIButton buttonWithType:UIButtonTypeCustom];
    int screenHeight = CGRectGetHeight([UIApplication sharedApplication].keyWindow.frame);
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        setButton.frame = CGRectMake(20,  screenHeight - 120, 280, 37);
    } else {
        setButton.frame = CGRectMake(20, screenHeight - 71, 280, 37);
    }
    
    setButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [setButton setImage:[UIImage imageNamed:@"createCustomAlarmButton"] forState:UIControlStateNormal];
    [setButton addTarget:self action:@selector(createCustomAlarmButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:setButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_alertTable reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (3 + [FileHelper getMaxNumberCreatedAlarmFiles]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.row == 0)
    {
        cell.textLabel.text = @"Alarm";
        cell.backgroundColor = [UIColor whiteColor];
        if ([[[NMDecibelLogger defaultLogger] alarmName] isEqualToString:@"home_alarm"]) 
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = @"Siren";
        cell.backgroundColor = [UIColor whiteColor];
        if ([[[NMDecibelLogger defaultLogger] alarmName] isEqualToString:@"siren_wail"]) 
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else if (indexPath.row == 2)
    {
        cell.textLabel.text = @"Alien";
        cell.backgroundColor = [UIColor whiteColor];
        if ([[[NMDecibelLogger defaultLogger] alarmName] isEqualToString:@"scifialarm"]) 
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    else {
        cell.textLabel.text = [NSString stringWithFormat:@"CustomAlarm%d",indexPath.row - 3];
        cell.backgroundColor = [UIColor whiteColor];
        
        if ([[[NMDecibelLogger defaultLogger] alarmName] isEqualToString:
             [NSString stringWithFormat:@"%d",indexPath.row - 3]])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0)
    {
        [[NMDecibelLogger defaultLogger] setAlarmName:@"home_alarm"];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(indexPath.row == 1)
    {
        [[NMDecibelLogger defaultLogger] setAlarmName:@"siren_wail"];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (indexPath.row == 2)
    {
        [[NMDecibelLogger defaultLogger] setAlarmName:@"scifialarm"];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [[NMDecibelLogger defaultLogger] setAlarmName:[NSString stringWithFormat:@"%d",(indexPath.row - 3)]];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void) createCustomAlarmButtonClicked {
    if ([NSUserDefaultsHelper isAdRemoved] == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Upgarde to Pro to enable this function" delegate:self cancelButtonTitle:@"Not yet" otherButtonTitles:@"More details",nil];
        [alert show];
    } else {
        CreateAlarmSoundViewController *createAlarmSoundViewController = [[CreateAlarmSoundViewController alloc] init];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:createAlarmSoundViewController animated:YES completion:nil];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _alertTable = nil;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.trackedViewName = @"SelectedAlertView Screen";
}

#pragma mark – UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        PurchaseViewController *purchaseViewController = [[PurchaseViewController alloc] initWithNibName:@"PurchaseViewController" bundle:nil];
        [self.navigationController pushViewController:purchaseViewController animated:YES];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
