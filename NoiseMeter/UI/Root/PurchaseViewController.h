//
//  PurchaseViewController.h
//  NoiseMeter
//
//  Created by Bourne Wang on 13-7-20.
//  Copyright (c) 2013年 Internetics Pty Ltd. All rights reserved.
//

#import "GAITrackedViewController.h"
#import <iAd/iAd.h>
#import <StoreKit/StoreKit.h>

@interface PurchaseViewController : BaseViewController < SKProductsRequestDelegate,SKPaymentTransactionObserver,UIAlertViewDelegate> {
    SKProduct *skProduct;
    
}
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *purchaseButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *restoreButton;



@end
