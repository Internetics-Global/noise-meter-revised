//
//  PurchaseViewController.h
//  NoiseMeter
//
//  Created by Bourne Wang on 13-7-20.
//  Copyright (c) 2013年 Internetics Pty Ltd. All rights reserved.
//


@interface PurchaseViewController : BaseViewController <UIWebViewDelegate>{
    
    UIActivityIndicatorView *_activity;
    
    UIButton *_backButton;
    
}
@property (unsafe_unretained, nonatomic) IBOutlet UIButton   *purchaseButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton   *restoreButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIWebView  *webview;



@end
