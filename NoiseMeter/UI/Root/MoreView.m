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
    
    _purchasePrice = @"$0.99";
    
    _optionTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 79, self.view.frame.size.width, self.view.frame.size.height - 79) style:UITableViewStyleGrouped];
    _optionTable.delegate = self;
    _optionTable.dataSource = self;
    _optionTable.opaque = NO;
    _optionTable.backgroundView = nil;
    _optionTable.backgroundColor = [UIColor clearColor];
    _optionTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_optionTable];
    
    BOOL flag = [NSUserDefaultsHelper isAdRemoved];
    if (flag == FALSE) {
        _buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            _buyButton.frame = CGRectMake(20, self.view.bounds.size.height - 37 - 10 - 49, 280, 37);
        } else {
            _buyButton.frame = CGRectMake(20, self.view.bounds.size.height - 37 - 10, 280, 37);
        }
        
        _buyButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [_buyButton setBackgroundColor:[UIColor darkGrayColor]];
        [_buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_buyButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
        [_buyButton setTitle:[NSString stringWithFormat:@"Get a pro version %@ ",_purchasePrice] forState:UIControlStateNormal];
        [_buyButton setBackgroundImage:[UIImage imageNamed:@"purchase.png"] forState:UIControlStateNormal];
        [_buyButton addTarget:self action:@selector(buyAction) forControlEvents:UIControlEventTouchUpInside];
        _buyButton.layer.cornerRadius = 5;
        [self.view addSubview:_buyButton];
    }
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (indexPath.row == 0)
    {
        cell.textLabel.text = @"Select Alert Sound";
    }
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = @"Instructions / Tips";
    }
    else if (indexPath.row == 2) 
    {
        cell.textLabel.text = @"About";
    }
    else if (indexPath.row == 3) 
    {
        cell.textLabel.text = @"Visit developer's website";
    }
    else if (indexPath.row == 4) 
    {
        cell.textLabel.text = @"Tell a Friend";
    }
    else if (indexPath.row == 5)
    {
        cell.textLabel.text = @"Support";
    }
    
    return cell;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
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
    else if(indexPath.row == 1)
    {
        InstructionView *about = [[InstructionView alloc] init];
        [self.navigationController pushViewController:about animated:YES];
    }
    else if (indexPath.row == 2) 
    {
        AboutView *about = [[AboutView alloc] init];
        [self.navigationController pushViewController:about animated:YES];
    }
    else if(indexPath.row == 3)
    {
        InternalWebView *web = [[InternalWebView alloc] initWithDestination:@"http://www.internetics.net.au"];
        [self.navigationController pushViewController:web animated:YES];
    }
    
    else
    {
        if ([MFMailComposeViewController canSendMail]) 
        {
            if (_mailer != nil) 
            {
                _mailer = nil;
            }
            _mailer = [[MFMailComposeViewController alloc] init];
            _mailer.mailComposeDelegate = self;
            if (indexPath.row == 4) 
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
            [self presentModalViewController:_mailer animated:YES];
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSSet *productList = [NSSet setWithObjects:IAPProductID, nil];
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productList];
    productsRequest.delegate = self;
    
    // This will trigger the SKProductsRequestDelegate callbacks
    [productsRequest start];
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.trackedViewName = @"MoreView Screen";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void) buyAction {
    
    PurchaseViewController *purchaseViewController = [[PurchaseViewController alloc] initWithNibName:@"PurchaseViewController" bundle:nil];
    [self.navigationController pushViewController:purchaseViewController animated:YES];
    
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"By purchasing a Pro version, you will be able to:"
//                                                    message:@"\n1.background record support.\n2.no more advertisement.\n\nGo to first page and click the AD remove button to buy."
//                                                   delegate:self cancelButtonTitle:@"OK"
//                                          otherButtonTitles:nil, nil];
//    [alert show];
}


- (void)purchasedFinishedNotification:(NSNotification *)notification {
    [super purchasedFinishedNotification:notification];
    
    [_buyButton removeFromSuperview];
    _buyButton = nil;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark – SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSArray *myProduct = response.products;
    if ([myProduct count] == 0) {
        return;
    }
    
    SKProduct *skProduct = [myProduct lastObject];
    _purchasePrice = [self localizedPrice:skProduct];
    
    [_buyButton setTitle:[NSString stringWithFormat:@"Get a pro version %@ ",_purchasePrice] forState:UIControlStateNormal];
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%s:%@",__FUNCTION__, [error description]);
}


- (NSString *)localizedPrice: (SKProduct *) sk
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:sk.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:sk.price];
    return formattedString;
}

@end
