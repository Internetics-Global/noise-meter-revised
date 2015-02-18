//
//  BaseViewController.m
//  NoiseMeter
//
//  Created by Bourne Wang on 14-2-6.
//  Copyright (c) 2014年 Internetics Pty Ltd. All rights reserved.
//

#import "BaseViewController.h"

#import "MeterView.h"
#import "ScoreView.h"
#import "AlertView.h"
#import "MoreView.h"
#import "PurchaseViewController.h"
#import "InternalWebView.h"
#import "UIButton+WebCache.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

#pragma mark – Life Cycle

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
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setupGeneralADView];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(purchasedFinishedNotification:)
                                                    name:@"PURCHASE_FINISHED_NOTIFICATION"
                                                   object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [UIView animateWithDuration:0.4 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^(){
            self.generalADButton.alpha = 1;
            NSLog(@"%s:ADBanner transient",__FUNCTION__);
        }completion:nil];
        
    });

}

#pragma mark –  Setup AD view, which is used to prompt user to buy a pro version

- (void) buyAction {
    PurchaseViewController *purchaseViewController = [[PurchaseViewController alloc] initWithNibName:@"PurchaseViewController" bundle:nil];
    [self.navigationController pushViewController:purchaseViewController animated:YES];
}



/**
 *  history introduction:
 *  we once had the logic of "Google Admob and Apple AD framework" here
 *  and finally, we removed all and have this
 */
- (void) setupGeneralADView {
    
    if ([NSUserDefaultsHelper isProClassRoomVersion]) {
        return;
    }
    
    if ([self isMemberOfClass:[MeterView class]] ||
        [self isMemberOfClass:[ScoreView class]] ||
        [self isMemberOfClass:[AlertView class]] ||
        [self isMemberOfClass:[MoreView class]] ) {
        
        if (self.generalADButton == nil) {
            
            self.generalADButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.generalADButton.frame = CGRectMake(0, 0, 320, 50);
            if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
                self.generalADButton.center = CGPointMake(self.view.center.x,
                                                          CGRectGetHeight(self.view.frame) - 49 - 25);
            } else {
                self.generalADButton.center = CGPointMake(self.view.center.x,
                                                          CGRectGetHeight(self.view.frame) - 25);
            }
            
            self.generalADButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
            [self.generalADButton setBackgroundColor:[UIColor redColor]];
            [self.generalADButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [self.generalADButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
            
            if ([NSUserDefaultsHelper isProVersion]) {
                [self.generalADButton sd_setBackgroundImageWithURL:[NSURL URLWithString:k_Pro_Classroom_Banner] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"generalBanner"]];
            } else {
                [self.generalADButton sd_setBackgroundImageWithURL:[NSURL URLWithString:k_Pro_Banner] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"generalBanner"]];
            }
            
            [self.generalADButton addTarget:self action:@selector(buyAction) forControlEvents:UIControlEventTouchUpInside];
            self.generalADButton.alpha = 0;
            [self.view addSubview:self.generalADButton];
            
        }
    }
}


#pragma mark – PURCHASE_FINISHED_NOTIFICATION

- (void)purchasedFinishedNotification:(NSNotification *)notification {
    
    //step1: update top logo
    UIImageView *imageView = [self findTopBarImageView];
    if (imageView) {
        if ([NSUserDefaultsHelper isProClassRoomVersion]) {
          [imageView setImage:[UIImage imageNamed:@"top_logo-pro-classroom.png"]];
        } else {
          [imageView setImage:[UIImage imageNamed:@"top_logo-pro.png"]];
        }
        
    }
    
    if ([NSUserDefaultsHelper isProClassRoomVersion]) {
        //step2: remove the AD view
        [self.generalADButton removeFromSuperview];
        self.generalADButton = nil;
        
        NSArray *subViews = [self.view subviews];
        for (UIView *myView in subViews) {
            if ([myView isKindOfClass:[UITableView class]]) {
                [(UITableView *)myView reloadData];
                break;
            }
        }
    } else {
        
        [self.generalADButton sd_setBackgroundImageWithURL:[NSURL URLWithString:k_Pro_Classroom_Banner] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"generalBanner"]];
    }
    
    
}


#pragma mark – Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
