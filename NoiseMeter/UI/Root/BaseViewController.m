//
//  BaseViewController.m
//  NoiseMeter
//
//  Created by Bourne Wang on 14-2-6.
//  Copyright (c) 2014年 Internetics Pty Ltd. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(purchasedFinishedNotification:)
                                                    name:@"PURCHASE_FINISHED_NOTIFICATION"
                                                   object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)purchasedFinishedNotification:(NSNotification *)notification {
    NSArray *viewArray = [self.view subviews];
    for (UIView *myView in viewArray) {
        if ((myView.tag == K_TOP_IMAGEVIEW_TAG) &&
                ([myView isKindOfClass:[UIImageView class]])) {
            [((UIImageView *)myView) setImage:[UIImage imageNamed:@"top_logo-pro.png"]];
            break;
        }
    }
    
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
