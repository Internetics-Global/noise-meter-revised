//
//  PurchaseViewController.m
//  NoiseMeter
//
//  Created by Bourne Wang on 13-7-20.
//  Copyright (c) 2013年 Internetics Pty Ltd. All rights reserved.
//

#import "PurchaseViewController.h"

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
    
    [_purchaseButton addTarget:self action:@selector(purchaseAction) forControlEvents:UIControlEventTouchDown];
    
    // Listen to purchase
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void) viewDidUnload {
    [self setPurchaseButton:nil];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.trackedViewName = @"PurchaseView Screen";
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


- (void) purchaseAction {
    
    if ([SKPaymentQueue canMakePayments]) {
        
        NSSet * set = [NSSet setWithArray:@[IAPProductID]];
        SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
        request.delegate = self;
        [request start];
        
    } else {
        NSLog(@"Failure，forbid to allow for purchase");
    }
    
}


- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *myProduct = response.products;
    
    if (myProduct.count == 0) {
        NSLog(@"Fail to get purchase info (myProduct.count = 0)");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:@"Fail to purchase, try again later"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    NSArray *invalidProductID = response.invalidProductIdentifiers;
    if ([invalidProductID count] >0) {
        NSLog(@"Invalid product ID");
        return;
    }
    
    skProduct = [myProduct lastObject];
    NSLog(@"Product title: %@" , skProduct.localizedTitle);
    NSLog(@"Product description: %@" , skProduct.localizedDescription);
    NSLog(@"Product price: %@" , skProduct.price);
    NSLog(@"Product id: %@" , skProduct.productIdentifier);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:[NSString stringWithFormat:@"Confirm to buy (%@)?",[self localizedPrice:skProduct]]
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK", nil];
    alertView.delegate = self;
    [alertView show];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        SKPayment * payment = [SKPayment paymentWithProduct:skProduct];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
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


- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                NSLog(@"Done of purchase transactionIdentifier = %@", transaction.transactionIdentifier);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PURCHASE_FINISHED_NOTIFICATION" object:self];
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"Fail to purchase,%@",transaction.error.localizedDescription);
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Fail to purchase: have bought this before");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PURCHASE_FINISHED_NOTIFICATION" object:self];
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"Add item into list to purchase");
                break;
            default:
                break;
        }
    }
    
}

- (void)dealloc
{
    [self viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
