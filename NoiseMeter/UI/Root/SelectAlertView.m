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
    
    [self style:YES];
    
    

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [resetButton setImage:[UIImage imageNamed:@"button_reset.png"] forState:UIControlStateNormal];
    [resetButton addTarget:self action:@selector(resetButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *topBarImageView = [self findTopBarImageView];
    resetButton.frame = CGRectMake(self.view.frame.size.width- 80, CGRectGetMaxY(topBarImageView.frame), 73, 35);
    [self.view addSubview:resetButton];
    
    _alertTable = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(resetButton.frame) + 5, self.view.frame.size.width, CGRectGetMaxY(self.view.frame) - CGRectGetMaxY(resetButton.frame) - 5) style:UITableViewStyleGrouped];
    _alertTable.delegate = self;
    _alertTable.dataSource = self;
    _alertTable.opaque = NO;
    _alertTable.backgroundView = nil;
    _alertTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _alertTable.separatorColor = [UIColor colorWithRed:97.0/255 green:97.0/255 blue:97.0/255 alpha:1];
    _alertTable.backgroundColor = [UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1];
    [self.view addSubview:_alertTable];
    
    UIButton *createCustomAlarmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    createCustomAlarmButton.frame = CGRectMake(20, CGRectGetMaxY(self.view.frame) - 10 -37, 280, 37);
    createCustomAlarmButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [createCustomAlarmButton setImage:[UIImage imageNamed:@"createCustomAlarmButton"] forState:UIControlStateNormal];
    [createCustomAlarmButton addTarget:self action:@selector(createCustomAlarmButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createCustomAlarmButton];
    
    if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
        [self viewWillAppear:YES];
    }
    
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
    
    else {
        cell.textLabel.text = [NSString stringWithFormat:@"Custom Alarm %d",indexPath.row - 3 + 1]; //index from 1
        
        if ([[[NMDecibelLogger defaultLogger] alarmName] isEqualToString:
             [NSString stringWithFormat:@"%d",indexPath.row - 3]])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
      cell.tintColor = [UIColor whiteColor];
    }
    
    cell.backgroundColor = [UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1];
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
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
    else if (indexPath.row == 2)
    {
        [[NMDecibelLogger defaultLogger] setAlarmName:@"scifialarm"];
    } else {
        [[NMDecibelLogger defaultLogger] setAlarmName:[NSString stringWithFormat:@"%d",(indexPath.row - 3)]];
    }
    
    [self dismissModalViewControllerAnimated:YES];
    
}

- (void) createCustomAlarmButtonClicked {
    if ([NSUserDefaultsHelper isProVersion] == NO) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"This is a PRO function" message:@"Upgrade to Pro to record your own alarms!" delegate:self cancelButtonTitle:@"Not yet" otherButtonTitles:@"More details",nil];
        alert.tag = 0;
        [alert show];
    } else {
        CreateAlarmSoundViewController *createAlarmSoundViewController = [[CreateAlarmSoundViewController alloc] init];
        [self.navigationController pushViewController:createAlarmSoundViewController animated:YES];
        
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _alertTable = nil;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.screenName = @"SelectedAlertView Screen";

}

#pragma mark – UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (alertView.tag) {
        case 0: {
            if (buttonIndex == 1) {
                PurchaseViewController *purchaseViewController = [[PurchaseViewController alloc] initWithNibName:@"PurchaseViewController" bundle:nil];
                [self.navigationController pushViewController:purchaseViewController animated:YES];
            }
            break;
        }
            
            
        case 1: {
            if (buttonIndex == 1) {
                int i = 0;
                NSFileManager *fileManager = [NSFileManager defaultManager];
                while (1) {
                    NSString *filePath = [FileHelper getCreatedAlarmFile:[NSString stringWithFormat:@"%d.caf",i]];
                    BOOL fileExists = [fileManager fileExistsAtPath:filePath];
                    if (fileExists) {
                        NSError *error = nil;
                        [fileManager removeItemAtPath:filePath error:&error];
                        if (error) {
                            NSLog(@"%s:%@",__FUNCTION__,[error description]);
                        }
                    } else {
                        break;
                    }
                    
                    i++;
                }
                
                [_alertTable reloadData];
                
                [[NMDecibelLogger defaultLogger] setAlarmName:@"home_alarm"];
            }
            break;
        }
            
        default:
            break;
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/**
 *  Remove all x.caf file under document folder
 */
- (void) resetButtonClicked {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Are you sure you want to reset?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes",nil];
    alert.tag = 1;
    [alert show];
}

@end
