//
//  SelectAlertView.m
//  NoiseMeter
//
//  Created by Dave Finster on 21/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import "SelectAlertView.h"
#import "NMDecibelLogger.h"
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
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
        if ([[[NMDecibelLogger defaultLogger] alarmName] isEqualToString:@"home_alarm"]) 
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else if (indexPath.row == 1) 
    {
        cell.textLabel.text = @"Siren";
        if ([[[NMDecibelLogger defaultLogger] alarmName] isEqualToString:@"siren_wail"]) 
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else if (indexPath.row == 2) 
    {
        cell.textLabel.text = @"Alien";
        if ([[[NMDecibelLogger defaultLogger] alarmName] isEqualToString:@"scifialarm"]) 
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
    }
    else if(indexPath.row == 1)
    {
        [[NMDecibelLogger defaultLogger] setAlarmName:@"siren_wail"];
    }
    else 
    {
        [[NMDecibelLogger defaultLogger] setAlarmName:@"scifialarm"];
    }
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    _alertTable = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
