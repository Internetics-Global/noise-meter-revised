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
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") == FALSE) {
        _purchaseButton.frame = CGRectOffset(_purchaseButton.frame, 0, 49);
        _restoreButton.frame = CGRectOffset(_restoreButton.frame, 0, 49);
    }
    
    _isOnlyRequestPrice = YES;
    NSSet *productList = [NSSet setWithObjects:IAPProductID, nil];
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productList];
    productsRequest.delegate = self;
    [productsRequest start];
    
}

- (void) viewDidUnload {
    [self setPurchaseButton:nil];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

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

#pragma mark – Restore purchase

- (IBAction)restoreAction:(id)sender {
    
    if (TARGET_IPHONE_SIMULATOR) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Can not test IAP in simulator" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self checkPurchasedItems];
}


- (void) checkPurchasedItems
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}// Call This Function

//Then this delegate Function Will be fired
- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSMutableArray *purchasedItemIDs = [[NSMutableArray alloc] init];
    
    NSLog(@"received restored transactions: %i", queue.transactions.count);
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        NSString *productID = transaction.payment.productIdentifier;
        [purchasedItemIDs addObject:productID];
    }
    
    if ([purchasedItemIDs count] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"You can not restore since you haven't purchased before." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
    
}


#pragma mark – Purchase

- (void) purchaseAction {
    
    if (TARGET_IPHONE_SIMULATOR) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Can not test IAP in simulator" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if ([SKPaymentQueue canMakePayments]) {
        
        NSSet * set = [NSSet setWithArray:@[IAPProductID]];
        SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
        request.delegate = self;
        [request start];
        
    } else {
        NSLog(@"Failure，forbid to allow for purchase");
    }
    
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
  NSLog(@"%@", [error description]);
    
  if (_isOnlyRequestPrice) {
    _isOnlyRequestPrice = NO;
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
    
    
    if (_isOnlyRequestPrice) {
        _isOnlyRequestPrice = NO;
        
        NSString *purchasePrice = [self localizedPrice:skProduct];
        
        [_purchaseButton setTitle:[NSString stringWithFormat:@"Purchase - %@ ",purchasePrice] forState:UIControlStateNormal];
        
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:[NSString stringWithFormat:@"Confirm to buy (%@)?",[self localizedPrice:skProduct]]
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"OK", nil];
        alertView.delegate = self;
        [alertView show];
    }
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
                [self.navigationController popViewControllerAnimated:YES];
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"Fail to purchase,%@",transaction.error.localizedDescription);
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Fail to purchase: have bought this before");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"PURCHASE_FINISHED_NOTIFICATION" object:self];
                [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                [self.navigationController popViewControllerAnimated:YES];
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
