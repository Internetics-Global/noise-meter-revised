//
//  PurchaseViewController.m
//  NoiseMeter
//
//  Created by Bourne Wang on 13-7-20.
//  Copyright (c) 2013年 Internetics Pty Ltd. All rights reserved.
//

#import "PurchaseViewController.h"
#import "RMStore.h"
#import "FileHelper.h"
#import <Parse/PFAnalytics.h>

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
    [self style:YES];
    [super viewDidLoad];
    
    [_purchaseButton addTarget:self action:@selector(purchaseNow) forControlEvents:UIControlEventTouchDown];
    
    //request product info
    NSSet *products;
    if ([NSUserDefaultsHelper isProVersion] == false) {
        products =[NSSet setWithArray:@[IAPProductID_Pro]];
    } else {
        products =[NSSet setWithArray:@[IAPProductID_Pro_Classroom]];
    }
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
    
    self.view.backgroundColor = [UIColor blackColor];
    
}



- (void) viewDidUnload {
    [self setPurchaseButton:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    
    self.webview.alpha = 0;
    
    NSURLRequest *request;
    NSString *cachedFileStr;
    if ([NSUserDefaultsHelper isProVersion] == false) {
        cachedFileStr = [FileHelper cachedProIntroductionHTMLFile];
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:k_Pro_Introduction_URL]];
        [_purchaseButton setTitle:@"Purchase - $2.99 " forState:UIControlStateNormal];
    } else {
        cachedFileStr = [FileHelper cachedProClassroomIntroductionHTMLFile];
        request = [NSURLRequest requestWithURL:[NSURL URLWithString:k_Pro_Classroom_Introduction_URL]];
        [_purchaseButton setTitle:@"Purchase - $6.99 " forState:UIControlStateNormal];
    }
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:cachedFileStr];
    if (NO) { //TODO:XXX
        NSData *htmlData = [NSData  dataWithContentsOfFile:cachedFileStr];
        NSString *htmlStr = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
        [self.webview loadHTMLString:htmlStr baseURL:nil];
    } else {
      [self.webview loadRequest:request];
    }
    
    
    
    _activity.center = self.webview.center;
    
//    NSString *resourcePath = [ [NSBundle mainBundle] resourcePath];
//    NSString *filePath  = [resourcePath stringByAppendingPathComponent:@"upgradeInstruction.html"];
//    NSString *htmlstring =[[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
//    [self.webview loadHTMLString:htmlstring  baseURL:[NSURL fileURLWithPath: [[NSBundle mainBundle]  bundlePath]]];


}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSDictionary *dimensions = @{@"category": @"PurchaseView Screen"};
    [PFAnalytics trackEvent:@"page" dimensions:dimensions];

}



#pragma mark – Restore and buy

- (void) updateProduct:(NSArray *)products withInvalidProductIdentifiers:(NSArray *) invalidProductIdentifiers  {
    if (_backButton) {
        _backButton.enabled = YES;
    }
    
    if (products.count == 0) {
        
        NSLog(@"Fail to get product info (myProduct.count = 0)");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:@"Failed to get product information, please try again later"
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
    
    [[RMStore defaultStore] restoreTransactionsOnSuccess:^(NSArray *transactions){
        NSLog(@"Transactions restored");
        
        if ([NSUserDefaultsHelper isProVersion] == false) {
            [NSUserDefaultsHelper setProVersionFlag:YES];
        } else {
            [NSUserDefaultsHelper setProClassRoomVersion:YES];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:K_Notification_Alarm_Finished object:self];
        
        [NSUserDefaultsHelper setNotAllowBackgroundRunningFlag:FALSE];
        
        [self dismiss];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Successfully restored" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
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
    
    NSString *productIdentifier;
    NSString *successDest;
    if ([NSUserDefaultsHelper isProVersion] == false) {
        productIdentifier =IAPProductID_Pro;
        successDest = @"Thank you for upgrading";
    } else {
        productIdentifier =IAPProductID_Pro_Classroom;
        successDest = @"Thank you for upgrading";
    }
    
    [[RMStore defaultStore] addPayment:productIdentifier success:^(SKPaymentTransaction *transaction) {
        NSLog(@"Product purchased");
        
        if ([NSUserDefaultsHelper isProVersion] == false) {
            [NSUserDefaultsHelper setProVersionFlag:YES];
        } else {
            [NSUserDefaultsHelper setProClassRoomVersion:YES];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:K_Notification_Alarm_Finished object:self];
        
        [NSUserDefaultsHelper setNotAllowBackgroundRunningFlag:FALSE];
        
        [self dismiss];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:successDest delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    } failure:^(SKPaymentTransaction *transaction, NSError *error) {
        NSLog(@"Something went wrong, or you have cancelled the purchase");
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

- (void) dismiss {
    if(self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
