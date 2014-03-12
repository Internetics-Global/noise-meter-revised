//
//  PurchaseViewController.m
//  NoiseMeter
//
//  Created by Bourne Wang on 13-7-20.
//  Copyright (c) 2013年 Internetics Pty Ltd. All rights reserved.
//

#import "PurchaseViewController.h"
#import "RMStore.h"

@interface PurchaseViewController ()

@end

@implementation PurchaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [self style];
    [super viewDidLoad];
    
    [_purchaseButton addTarget:self action:@selector(purchaseNow) forControlEvents:UIControlEventTouchDown];
    
    //request product info
    NSSet *products = [NSSet setWithArray:@[IAPProductID]];
    [[RMStore defaultStore] requestProducts:products success:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        NSLog(@"Products loaded");
        [self updateProduct:products withInvalidProductIdentifiers: invalidProductIdentifiers];
    } failure:^(NSError *error) {
        NSLog(@"Something went wrong");
    }];
    
    
    
    self.webview.delegate = self;
    
    _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activity.frame = CGRectMake(self.view.frame.size.width/2 - 5, 30, 21, 21);
    [self.view addSubview:_activity];
    
    _backButton = [self findBackButton];
    
}



- (void) viewDidUnload {
    [self setPurchaseButton:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") == FALSE) {
        _purchaseButton.frame = CGRectOffset(_purchaseButton.frame, 0, 49);
        _restoreButton.frame = CGRectOffset(_restoreButton.frame, 0, 49);
    } else {
        CGRect rect = self.webview.frame;
        rect.size.height = rect.size.height - 29;
        self.webview.frame = rect;
    }
    
    
    if (iPhone5) {
        CGRect rect = self.webview.frame;
        rect.size.height = rect.size.height + 19;
        self.webview.frame = rect;
    }
    
    self.webview.alpha = 0;
    
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.noisedown.com/upgrade.html"]]];
    
    
    _activity.center = self.webview.center;
    
//    NSString *resourcePath = [ [NSBundle mainBundle] resourcePath];
//    NSString *filePath  = [resourcePath stringByAppendingPathComponent:@"upgradeInstruction.html"];
//    NSString *htmlstring =[[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
//    [self.webview loadHTMLString:htmlstring  baseURL:[NSURL fileURLWithPath: [[NSBundle mainBundle]  bundlePath]]];


}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.trackedViewName = @"PurchaseView Screen";
}



#pragma mark – Restore and buy

- (void) updateProduct:(NSArray *)products withInvalidProductIdentifiers:(NSArray *) invalidProductIdentifiers  {
    if (_backButton) {
        _backButton.enabled = YES;
    }
    
    if (products.count == 0) {
        
        NSLog(@"Fail to get purchase info (myProduct.count = 0)");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:@"Fail to purchase, try again later"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    if ([invalidProductIdentifiers count] >0) {
        NSLog(@"Invalid product ID");
        return;
    }
    
    SKProduct *skProduct = [products lastObject];
    NSLog(@"Product title: %@" , skProduct.localizedTitle);
    NSLog(@"Product description: %@" , skProduct.localizedDescription);
    NSLog(@"Product price: %@" , skProduct.price);
    NSLog(@"Product id: %@" , skProduct.productIdentifier);
    
    
    NSString *purchasePrice = [self localizedPrice:skProduct];
    [_purchaseButton setTitle:[NSString stringWithFormat:@"Purchase - %@ ",purchasePrice] forState:UIControlStateNormal];
    
}

- (IBAction)restoreAction:(id)sender {
    
    if (TARGET_IPHONE_SIMULATOR) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Can not test IAP in simulator" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [[RMStore defaultStore] restoreTransactionsOnSuccess:^{
        NSLog(@"Transactions restored");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PURCHASE_FINISHED_NOTIFICATION" object:self];
        
        [NSUserDefaultsHelper setNotAllowBackgroundRunningFlag:FALSE];
        
        [self.navigationController popViewControllerAnimated:YES];
        
        [NSUserDefaultsHelper setAdRemoveFlag:YES];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Successfully restored PRO upgrade" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    } failure:^(NSError *error) {
        NSLog(@"Something went wrong");
    }];
    
}



#pragma mark – Purchase

- (void) purchaseNow {
    
    if (TARGET_IPHONE_SIMULATOR) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Can not test IAP in simulator" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [[RMStore defaultStore] addPayment:IAPProductID success:^(SKPaymentTransaction *transaction) {
        NSLog(@"Product purchased");
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PURCHASE_FINISHED_NOTIFICATION" object:self];
        
        [NSUserDefaultsHelper setNotAllowBackgroundRunningFlag:FALSE];
        
        [self.navigationController popViewControllerAnimated:YES];
        
        [NSUserDefaultsHelper setAdRemoveFlag:YES];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Thank you for upgrading to Noise Down Pro" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        NSLog(@"Something went wrong");
    }];
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



#pragma mark – UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_activity startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_activity stopAnimating];
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.webview.alpha = 1.0f;
                     }];
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [_activity stopAnimating];
}

#pragma mark – Memory management

- (void)dealloc
{
    [self viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



@end
