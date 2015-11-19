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
#import "UIAlertView+Blocks.h"
#import "SelectMeterView.h"
#import "UIButton+Extensions.h"

#import "UIViewController+REFrostedViewController.h"
#import <Parse/PFAnalytics.h>


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

    
    [self style:NO];
    

    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    backButton.frame = CGRectMake(320 - 20 - 15, 18, 20, 20);
    [backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:backButton];
    backButton.showsTouchWhenHighlighted = YES;
    [backButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
    
    //This is a special case for REFrostedViewController
    float statusBarHeight = 0;
    
    UIImageView *topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings_title"]];
    topImageView.frame = CGRectMake(0, KTopLogoHeight + statusBarHeight, CGRectGetWidth(self.view.frame), 40);
    topImageView.contentMode = UIViewContentModeCenter;
    topImageView.backgroundColor =[UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1];
    topImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:topImageView];
    
    CGRect frame;
    if ([NSUserDefaultsHelper isProVersion]) {
        frame = CGRectMake(0, CGRectGetMaxY(topImageView.frame), self.view.frame.size.width, CGRectGetMaxY(self.view.frame) - CGRectGetMaxY(topImageView.frame));
    } else {
        frame = CGRectMake(0, CGRectGetMaxY(topImageView.frame), self.view.frame.size.width, CGRectGetMaxY(self.view.frame) - CGRectGetMaxY(topImageView.frame) - CGRectGetHeight(self.generalADButton.frame) - 44);
    }
    _optionTable = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    
    _optionTable.delegate = self;
    _optionTable.dataSource = self;
    _optionTable.opaque = NO;
    _optionTable.separatorColor = [UIColor colorWithRed:97.0/255 green:97.0/255 blue:97.0/255 alpha:1];
    _optionTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _optionTable.backgroundView = nil;
    _optionTable.backgroundColor = [UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1];
    _optionTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_optionTable];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 40.0f;
//}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 14;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if ((indexPath.row == 0) || (indexPath.row == 3) || (indexPath.row == 4) || (indexPath.row == 5) || (indexPath.row == 6)|| (indexPath.row == 7) || (indexPath.row == 8)) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellToggle"];
        UISwitch *switchView;
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellToggle"];
        switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
//        switchView.transform = CGAffineTransformMakeScale(0.75, 0.75);
        cell.accessoryView = switchView;
        
        if (indexPath.row == 4) {
            
            [switchView addTarget:self action:@selector(speakerOutputSwitchClicked:) forControlEvents:UIControlEventValueChanged];
            
            [cell.textLabel setText:@"Speaker Output"];
            if ([NSUserDefaultsHelper isOutputToEarpiece] == YES) {
                [switchView setOn:NO];
            } else {
                [switchView setOn:YES];
            }
            
        } else if (indexPath.row == 3) {
            [switchView addTarget:self action:@selector(backgroundRunningSwitchClicked:) forControlEvents:UIControlEventValueChanged];
            
            [cell.textLabel setText:@"Run App In The Background"];
            if ([NSUserDefaultsHelper isNotAllowBackgroundRunning] == YES) {
                [switchView setOn:NO];
                
            } else {
                [switchView setOn:YES];
            }
            
            if ([NSUserDefaultsHelper isProVersion]) {
            } else {
                [switchView setOn:NO];
            }
        } else if (indexPath.row == 0) {
            [switchView addTarget:self action:@selector(pauseLoggingSwitchClicked:) forControlEvents:UIControlEventValueChanged];
            
            [cell.textLabel setText:@"Meter On/Off"];
            if ([NSUserDefaultsHelper isLoggingPause] == YES) {
                [switchView setOn:NO];
            } else {
                [switchView setOn:YES];
                
            }
        } else if (indexPath.row == 5) {
            [switchView addTarget:self action:@selector(ignoreSuddenNoiseSwitchClicked:) forControlEvents:UIControlEventValueChanged];
            
            [cell.textLabel setText:@"Ignore Sudden Noise"];
            if ([NSUserDefaultsHelper isIgnoreSuddenNoise] == YES) {
                [switchView setOn:YES];
            } else {
                [switchView setOn:NO];
                
            }
        } else if (indexPath.row == 6) {
            [switchView addTarget:self action:@selector(delayAlarmSoundSwitchClicked:) forControlEvents:UIControlEventValueChanged];
            [cell.textLabel setText:@"Delay Before Sounding Alert"];
            if ([NSUserDefaultsHelper isDelayAlarmSound] == YES) {
                [switchView setOn:YES];
            } else {
                [switchView setOn:NO];
                
            }
        } else if (indexPath.row == 7) {
            [switchView addTarget:self action:@selector(continuousModeSwitchClicked:) forControlEvents:UIControlEventValueChanged];
            [cell.textLabel setText:@"Continuous Mode"];
            if ([NSUserDefaultsHelper isContinuousMode] == YES) {
                [switchView setOn:YES];
            } else {
                [switchView setOn:NO];
                
            }
        } else if (indexPath.row == 8) {
            [switchView addTarget:self action:@selector(silentModeSwitchClicked:) forControlEvents:UIControlEventValueChanged];
            [cell.textLabel setText:@"Silent Mode"];
            if ([NSUserDefaultsHelper isSilentMode] == YES) {
                [switchView setOn:YES];
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
        
        if (indexPath.row == 1)
        {
            cell.textLabel.text = @"Select Alert Sound";
        }else if (indexPath.row == 2)
        {
            cell.textLabel.text = @"Meter Display Shape";
        }
        else if (indexPath.row == 9)
        {
            cell.textLabel.text = @"Instructions / Tips";
        }
        else if (indexPath.row == 10)
        {
            cell.textLabel.text = @"About";
        }
        else if (indexPath.row == 11)
        {
            cell.textLabel.text = @"Visit developer's website";
        }
        else if (indexPath.row == 12)
        {
            cell.textLabel.text = @"Tell a Friend";
        }
        else if (indexPath.row == 13)
        {
            cell.textLabel.text = @"Support";
        }
    }
    
    cell.backgroundColor = [UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    
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
    
    if(indexPath.row == 1)
    {
        SelectAlertView *about = [[SelectAlertView alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:about];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:navController animated:YES completion:nil];
    } else if(indexPath.row == 2)
    {
        if ([NSUserDefaultsHelper isProVersion] == FALSE) {
            
            [UIAlertView showWithTitle:@"This is a Noise Down PRO function" message:@"You can upgrade the app to get it!" style:UIAlertViewStyleDefault cancelButtonTitle:@"Not yet" otherButtonTitles:@[@"More details"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1) {
                    [self showPurchaseView];
                }
                
            }];
            
            
        } else {
            SelectMeterView *about = [[SelectMeterView alloc] init];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:about animated:YES completion:nil];
        }
        
    }
    else if(indexPath.row == 9)
    {
        InternalWebView *web = [[InternalWebView alloc] initWithDestination:@"http://www.noisedown.com/tips.html"];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:web animated:YES completion:nil];

    }
    else if (indexPath.row == 10)
    {
        InternalWebView *web = [[InternalWebView alloc] initWithDestination:@"http://www.noisedown.com/about.html"];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:web animated:YES completion:nil];
    }
    else if(indexPath.row == 11)
    {
        InternalWebView *web = [[InternalWebView alloc] initWithDestination:@"http://www.internetics.net.au"];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:web animated:YES completion:nil];
    }
    
    else if ((indexPath.row == 12) || (indexPath.row ==13))
    {
        if ([MFMailComposeViewController canSendMail])
        {
            if (_mailer != nil)
            {
                _mailer = nil;
            }
            _mailer = [[MFMailComposeViewController alloc] init];
            _mailer.mailComposeDelegate = self;
            if (indexPath.row == 12)
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
            
            double delayInSeconds = 0.4;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:_mailer animated:YES completion:nil];
            });
        }
        else
        {
            
            [UIAlertView showWithTitle:@"No Accounts" message:@"An email account is required to use this function" style:UIAlertViewStyleDefault cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                
            }];
        }
    } else if (indexPath.row == 14) {
        
        [self showPurchaseView];
        
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    _optionTable = nil;
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSDictionary *dimensions = @{@"category": @"MoreView Screen"};
    [PFAnalytics trackEvent:@"page" dimensions:dimensions];
    
    [_optionTable reloadData];
}

- (void) speakerOutputSwitchClicked: (id) sender {
    UISwitch *myswitch = (UISwitch *)sender;
    if ([myswitch isOn]) {
        [NSUserDefaultsHelper setOutputToEarpieceFlag:NO];
    } else {
        [NSUserDefaultsHelper setOutputToEarpieceFlag:YES];
    }
    
    [IDPSoundBoard resetAudioRoute:[NSUserDefaultsHelper isOutputToEarpiece]];
    
}

- (void) backgroundRunningSwitchClicked: (id) sender {
    
    UISwitch *myswitch = (UISwitch *)sender;
    if ([NSUserDefaultsHelper isProVersion] == FALSE) {
        
        [myswitch setOn:NO];
        
        [UIAlertView showWithTitle:@"This is a Noise Down PRO function" message:@"You can upgrade the app to get it!" style:UIAlertViewStyleDefault cancelButtonTitle:@"Not yet" otherButtonTitles:@[@"More details"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self showPurchaseView];
            }
            
        }];
        
        
    } else {
        if ([myswitch isOn]) {
            [NSUserDefaultsHelper setNotAllowBackgroundRunningFlag:NO];
            APP_DELEGATE.isNotAllowBackgroundRunningWhenLastMeterOff = NO;
            
        } else {
            [NSUserDefaultsHelper setNotAllowBackgroundRunningFlag:YES];
            APP_DELEGATE.isNotAllowBackgroundRunningWhenLastMeterOff = YES;
            [IDPSoundBoard stopBackgroundSoundRunning];
            
        }
    }
    
}


- (void) continuousModeSwitchClicked:(id)sender {
    
    UISwitch *myswitch = (UISwitch *)sender;
    
    if ([NSUserDefaultsHelper isProVersion] == FALSE) {
        
        [myswitch setOn:NO];
        
        [UIAlertView showWithTitle:@"This is a Noise Down PRO function" message:@"You can upgrade the app to get it!" style:UIAlertViewStyleDefault cancelButtonTitle:@"Not yet" otherButtonTitles:@[@"More details"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self showPurchaseView];
            }
            
        }];
    } else {
        if ([myswitch isOn]) {
            [NSUserDefaultsHelper setContinuousMode:YES];
            
        } else {
            [NSUserDefaultsHelper setContinuousMode:NO];
        }
        
        [_optionTable reloadData];
    }
    
}

- (void) silentModeSwitchClicked:(id)sender {
    
    UISwitch *myswitch = (UISwitch *)sender;
    
    if ([NSUserDefaultsHelper isProVersion] == FALSE) {
        
        [myswitch setOn:NO];
        
        [UIAlertView showWithTitle:@"This is a Noise Down PRO function" message:@"You can upgrade the app to get it!" style:UIAlertViewStyleDefault cancelButtonTitle:@"Not yet" otherButtonTitles:@[@"More details"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self showPurchaseView];
            }
            
        }];
        
        
    } else {
        
        if ([myswitch isOn]) {
            [NSUserDefaultsHelper setSilentMode:YES];
            
        } else {
            [NSUserDefaultsHelper setSilentMode:NO];
        }
        
        [_optionTable reloadData];
        
    }

    
    
}


- (void) delayAlarmSoundSwitchClicked:(id)sender {
    
    UISwitch *myswitch = (UISwitch *)sender;
    
    if ([NSUserDefaultsHelper isProVersion] == FALSE) {
        [UIAlertView showWithTitle:@"This is a Noise Down PRO function" message:@"You can upgrade the app to get it!" style:UIAlertViewStyleDefault cancelButtonTitle:@"Not yet" otherButtonTitles:@[@"More details"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self showPurchaseView_ClassRoom];
            }
            
        }];
        [myswitch setOn:NO];
    } else {
        if ([myswitch isOn]) {
            [NSUserDefaultsHelper setDelayAlarmSound:YES];
            
        } else {
            [NSUserDefaultsHelper setDelayAlarmSound:NO];
        }
        
        [_optionTable reloadData];
    }

    
}

- (void) ignoreSuddenNoiseSwitchClicked:(id)sender {
    UISwitch *myswitch = (UISwitch *)sender;
    
    if ([NSUserDefaultsHelper isProVersion] == FALSE) {
        
        [myswitch setOn:NO];
        
        [UIAlertView showWithTitle:@"This is a Noise Down PRO function" message:@"You can upgrade the app to get it!" style:UIAlertViewStyleDefault cancelButtonTitle:@"Not yet" otherButtonTitles:@[@"More details"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self showPurchaseView];
            }
            
        }];
        
        
    } else {
        
        if ([myswitch isOn]) {
            [NSUserDefaultsHelper setIgnoreSuddenNoise:YES];
            
        } else {
            [NSUserDefaultsHelper setIgnoreSuddenNoise:NO];
        }
        
        [_optionTable reloadData];
        
    }
    
    
}


- (void) pauseLoggingSwitchClicked: (id) sender {
    
    UISwitch *myswitch = (UISwitch *)sender;
    
    if ([myswitch isOn]) {
        [NSUserDefaultsHelper setLoggingPauseFlag:NO];
        
        if (APP_DELEGATE.isNotAllowBackgroundRunningWhenLastMeterOff == FALSE) {
            [NSUserDefaultsHelper setNotAllowBackgroundRunningFlag:NO];
        } else {
            [NSUserDefaultsHelper setNotAllowBackgroundRunningFlag:YES];
        }
        
        
    } else {
        [NSUserDefaultsHelper setLoggingPauseFlag:YES];
        
        APP_DELEGATE.isNotAllowBackgroundRunningWhenLastMeterOff = [NSUserDefaultsHelper isNotAllowBackgroundRunning];
        [NSUserDefaultsHelper setNotAllowBackgroundRunningFlag:YES];
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:K_Notification_Log_Pause_Switch_Setting object:nil];
    
    [_optionTable reloadData];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void) showPurchaseView {
    double delayInSeconds = 0.45;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        PurchaseViewController *purchaseViewController = [[PurchaseViewController alloc] initWithNibName:@"PurchaseViewController" bundle:nil];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:purchaseViewController animated:YES completion:nil];
    });
}

- (void) showPurchaseView_ClassRoom {
    double delayInSeconds = 0.45;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        PurchaseViewController *purchaseViewController = [[PurchaseViewController alloc] initWithNibName:@"PurchaseViewController" bundle:nil];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:purchaseViewController animated:YES completion:nil];
    });
}

- (void) backButtonClicked {
    [self.frostedViewController hideMenuViewController];
}


@end
