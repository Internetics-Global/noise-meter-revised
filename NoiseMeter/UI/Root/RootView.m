//
//  RootView.m
//  NoiseMeter
//
//  Created by Dave Finster on 6/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import "RootView.h"
#import "MeterView.h"
#import "ScoreView.h"
#import "AlertView.h"
#import "MoreView.h"

@interface RootView ()

@end

@implementation RootView

- (id)init
{
    self = [super init];
   
    return self;
}

- (void)loadView
{
    [super loadView];
    
    if (_tabBarController == nil) {
        _tabBarController = [[UITabBarController alloc] init];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            int statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
            int screenHeight = CGRectGetHeight([UIApplication sharedApplication].keyWindow.frame);
            _tabBarController.view.frame = CGRectMake(0, 20, 320, screenHeight - statusBarHeight);
            
        } else {
            _tabBarController.view.frame = self.view.bounds;
        }
        _tabBarController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        NSMutableArray *_viewControllers = [[NSMutableArray alloc] init];
        
        MeterView *meter = [[MeterView alloc] init];
        UINavigationController *meterNav = [[UINavigationController alloc] initWithRootViewController:meter];
        [meterNav setNavigationBarHidden:YES];
        [_viewControllers addObject:meterNav];
        
        ScoreView *score = [[ScoreView alloc] init];
        UINavigationController *scoreNav = [[UINavigationController alloc] initWithRootViewController:score];
        [scoreNav setNavigationBarHidden:YES];
        [_viewControllers addObject:scoreNav];
        
        AlertView *alert = [[AlertView alloc] init];
        UINavigationController *alertNav = [[UINavigationController alloc] initWithRootViewController:alert];
        [alertNav setNavigationBarHidden:YES];
        [_viewControllers addObject:alertNav];
        
        MoreView *more = [[MoreView alloc] init];
        UINavigationController *moreNav = [[UINavigationController alloc] initWithRootViewController:more];
        [moreNav setNavigationBarHidden:YES];
        [_viewControllers addObject:moreNav];
        
        _tabBarController.viewControllers = _viewControllers;
    }
    
    [self.view addSubview:_tabBarController.view];

    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.trackedViewName = @"RootView Screen";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
    _tabBarController = nil;
}

@end
