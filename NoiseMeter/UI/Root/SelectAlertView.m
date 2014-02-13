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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_alertTable reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (3 + 1 + [FileHelper getMaxNumberCreatedAlarmFiles]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.row == 1)
    {
        cell.textLabel.text = @"Alarm";
        cell.backgroundColor = [UIColor whiteColor];
        if ([[[NMDecibelLogger defaultLogger] alarmName] isEqualToString:@"home_alarm"]) 
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else if (indexPath.row == 2)
    {
        cell.textLabel.text = @"Siren";
        cell.backgroundColor = [UIColor whiteColor];
        if ([[[NMDecibelLogger defaultLogger] alarmName] isEqualToString:@"siren_wail"]) 
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else if (indexPath.row == 3)
    {
        cell.textLabel.text = @"Alien";
        cell.backgroundColor = [UIColor whiteColor];
        if ([[[NMDecibelLogger defaultLogger] alarmName] isEqualToString:@"scifialarm"]) 
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    else if (indexPath.row == 0)
    {
        cell.textLabel.text = @"     Click to create custom alarm";
        cell.backgroundColor = [UIColor orangeColor];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"CustomAlarm%d",indexPath.row - 4];
        cell.backgroundColor = [UIColor whiteColor];
        
        if ([[[NMDecibelLogger defaultLogger] alarmName] isEqualToString:
             [NSString stringWithFormat:@"%d",indexPath.row - 4]])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1)
    {
        [[NMDecibelLogger defaultLogger] setAlarmName:@"home_alarm"];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(indexPath.row == 2)
    {
        [[NMDecibelLogger defaultLogger] setAlarmName:@"siren_wail"];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (indexPath.row == 3)
    {
        [[NMDecibelLogger defaultLogger] setAlarmName:@"scifialarm"];
        [self.navigationController popViewControllerAnimated:YES];
    } else if (indexPath.row == 0) {
        
        if ([NSUserDefaultsHelper isAdRemoved] == FALSE) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Upgarde to Pro to enable this function" delegate:self cancelButtonTitle:@"Not yet" otherButtonTitles:@"More details",nil];
            [alert show];
        } else {
            CreateAlarmSoundViewController *createAlarmSoundViewController = [[CreateAlarmSoundViewController alloc] init];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:createAlarmSoundViewController animated:YES completion:nil];
        }
        
    } else {
        [[NMDecibelLogger defaultLogger] setAlarmName:[NSString stringWithFormat:@"%d",(indexPath.row - 4)]];
        [self.navigationController popViewControllerAnimated:YES];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
