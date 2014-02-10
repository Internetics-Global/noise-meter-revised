//
//  MoreView.m
//  NoiseMeter
//
//  Created by Dave Finster on 20/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import "MoreView.h"
#import "InternalWebView.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import "AboutView.h"
#import "SelectAlertView.h"
#import "InstructionView.h"
#import "RootView.h"
#import "MeterView.h"
#import "PurchaseViewController.h"
#import "NMDecibelLogger.h"
@interface MoreView ()

@end

@implementation MoreView

- (id)init{
    self = [super init];
    self.tabBarItem.image = [UIImage imageNamed:@"icon_more.png"];
    self.tabBarItem.title = @"More";
    
    return self;
}

- (void)loadView
{
    [super loadView];
    
    [self style];
    
    _optionTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 79, self.view.frame.size.width, self.view.frame.size.height - 79) style:UITableViewStyleGrouped];
    _optionTable.delegate = self;
    _optionTable.dataSource = self;
    _optionTable.opaque = NO;
    _optionTable.backgroundView = nil;
    _optionTable.backgroundColor = [UIColor clearColor];
    _optionTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_optionTable];

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if ((indexPath.row == 1) || (indexPath.row == 2)) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellToggle"];
        UISwitch *switchView;
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellToggle"];
            switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            cell.accessoryView = switchView;
        }
        
        if (indexPath.row == 1) {
            
            [switchView addTarget:self action:@selector(speakerOutputSwitchClicked:) forControlEvents:UIControlEventValueChanged];
            
            [cell.textLabel setText:@"Speaker Output"];
            if ([NSUserDefaultsHelper isOutputToEarpiece] == YES) {
                [switchView setOn:NO];
            } else {
                [switchView setOn:YES];
            }
            
        } else if (indexPath.row == 2) {
            [switchView addTarget:self action:@selector(backgroundRunningSwitchClicked:) forControlEvents:UIControlEventValueChanged];
            
            [cell.textLabel setText:@"Background Running"];
            if ([NSUserDefaultsHelper isNotBackgroundRunning] == YES) {
                [switchView setOn:NO];
            } else {
                [switchView setOn:YES];
            }
            
            if ([NSUserDefaultsHelper isAdRemoved]) {
            } else {
                [switchView setOn:NO];
            }
        }
        
        
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if (indexPath.row == 0)
        {
            cell.textLabel.text = @"Select Alert Sound";
        }
        else if (indexPath.row == 3)
        {
            cell.textLabel.text = @"Instructions / Tips";
        }
        else if (indexPath.row == 4)
        {
            cell.textLabel.text = @"About";
        }
        else if (indexPath.row == 5)
        {
            cell.textLabel.text = @"Visit developer's website";
        }
        else if (indexPath.row == 6)
        {
            cell.textLabel.text = @"Tell a Friend";
        }
        else if (indexPath.row == 7)
        {
            cell.textLabel.text = @"Support";
        }
    }
    
    return cell;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissModalViewControllerAnimated:YES];
}

-(NSString *)supportText{
	NSMutableString *string = [[NSMutableString alloc] init];
	
	[string appendFormat:@"<b>System Name:</b> %@ <br>", [[UIDevice currentDevice] systemName]];
	[string appendFormat:@"<b>System Version:</b> %@ <br>", [[UIDevice currentDevice] systemVersion]];
	[string appendFormat:@"<b>Model:</b> %@ <br>", [[UIDevice currentDevice] model]];
	if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] isEqualToString:@"4"]) {
		CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
		CTCarrier *carrier = [info subscriberCellularProvider];
		[string appendFormat:@"<b>Carrier:</b> %@ <br>", [carrier carrierName]];
		[string appendFormat:@"<b>Country Code:</b> %@ <br>", [[carrier isoCountryCode] capitalizedString]];
		if ([carrier mobileNetworkCode] == nil) {
			[string appendFormat:@"<b>Airplane Mode/No SIM/Out of Range</b><br>", [carrier isoCountryCode]];
		}
	}
	return string;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == 0)
    {
        SelectAlertView *about = [[SelectAlertView alloc] init];
        [self.navigationController pushViewController:about animated:YES];
    }
    else if(indexPath.row == 3)
    {
        InstructionView *about = [[InstructionView alloc] init];
        [self.navigationController pushViewController:about animated:YES];
    }
    else if (indexPath.row == 4)
    {
        AboutView *about = [[AboutView alloc] init];
        [self.navigationController pushViewController:about animated:YES];
    }
    else if(indexPath.row == 5)
    {
        InternalWebView *web = [[InternalWebView alloc] initWithDestination:@"http://www.internetics.net.au"];
        [self.navigationController pushViewController:web animated:YES];
    }
    
    else if ((indexPath.row == 6) || (indexPath.row == 7))
    {
        if ([MFMailComposeViewController canSendMail]) 
        {
            if (_mailer != nil) 
            {
                _mailer = nil;
            }
            _mailer = [[MFMailComposeViewController alloc] init];
            _mailer.mailComposeDelegate = self;
            if (indexPath.row == 6)
            {
                [_mailer setSubject:@"Keep the Noise Down"];
                [_mailer setMessageBody:@"Hi,<br><br>I just found this fun app called Keep The Noise down. It measures the noise levels in your house, workplace or classroom and an alarm triggers if you go over the limit!<br><br>Check it out at <a href=\"http://www.noisedown.com/app\">http://www.noisedown.com/app</a>" isHTML:YES];
            }
            else 
            {
                [_mailer setToRecipients:[NSArray arrayWithObject:@"support@noisedown.com"]];
                [_mailer setSubject:@"Keep The Noise Down Support"];
                [_mailer setMessageBody:[NSString stringWithFormat:@"Please enter your support request here:<br><br><br><br>%@", [self supportText]] isHTML:YES];
            }
            [[UIApplication sharedApplication].keyWindow.rootViewController presentModalViewController:_mailer animated:YES];
        }
        else 
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Accounts" message:@"An email account is required to use this function" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    _optionTable = nil;
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.trackedViewName = @"MoreView Screen";
}

- (void) speakerOutputSwitchClicked: (id) sender {
    UISwitch *myswitch = (UISwitch *)sender;
    if ([myswitch isOn]) {
        [NSUserDefaultsHelper setOutputToEarpieceFlag:NO];
    } else {
        [NSUserDefaultsHelper setOutputToEarpieceFlag:YES];
    }
    
    [[NMDecibelLogger defaultLogger] audioRoute];
    
}

- (void) backgroundRunningSwitchClicked: (id) sender {
    
    UISwitch *myswitch = (UISwitch *)sender;
    if ([NSUserDefaultsHelper isAdRemoved] == FALSE) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Purchase to enable this function" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [myswitch setOn:NO];
        return;
    }
    
    if ([myswitch isOn]) {
        [NSUserDefaultsHelper setNotBackgroundRunningFlag:NO];
    } else {
        [NSUserDefaultsHelper setNotBackgroundRunningFlag:YES];
    }
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
