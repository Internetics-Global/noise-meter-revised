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
#import "MoreView.h"
#import "NMDecibelLogger.h"

#import "BCTabBarController.h"
#import "AlertViewV2.h"

@interface RootView () <REFrostedViewControllerDelegate,BCTabBarControllerDelegate> {
    BCTabBarController *_tabBarController;
    
    BOOL                _isToRestartLogging;
}

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
        _tabBarController = [[BCTabBarController alloc] init];
        NSMutableArray *_viewControllers = [[NSMutableArray alloc] init];
        
        MeterView *meter = [[MeterView alloc] init];
        UINavigationController *meterNav = [[UINavigationController alloc] initWithRootViewController:meter];
        [meterNav setNavigationBarHidden:YES];
        [_viewControllers addObject:meterNav];
        
        ScoreView *score = [[ScoreView alloc] init];
        UINavigationController *scoreNav = [[UINavigationController alloc] initWithRootViewController:score];
        [scoreNav setNavigationBarHidden:YES];
        [_viewControllers addObject:scoreNav];
        
        AlertViewV2 *alert = [[AlertViewV2 alloc] init];
        UINavigationController *alertNav = [[UINavigationController alloc] initWithRootViewController:alert];
        [alertNav setNavigationBarHidden:YES];
        [_viewControllers addObject:alertNav];
        
        
        _tabBarController.viewControllers = _viewControllers;
        _tabBarController.delegate = self;
        
    }
    
    //if you do not override addChildViewController, you do not have to call willMoveToParentViewController: method. However you do need to call the didMoveToParentViewController: method after the transition is complete. "Likewise, it is is the responsibility of the container view controller to call the willMoveToParentViewController: method before calling the removeFromParentViewController method. The removeFromParentViewController method calls the didMoveToParentViewController: method of the child view controller."

    [self addChildViewController:_tabBarController];
    _tabBarController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _tabBarController.view.frame=self.view.bounds;
    [self.view addSubview:_tabBarController.view];
    [_tabBarController didMoveToParentViewController:self];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.view.backgroundColor = kGrayColor;
    
    self.frostedViewController.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentMenuViewController:) name:K_Notification_Show_Left_Setting_View object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveNotification:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

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

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark – K_Notification_Show_Left_View
- (void)presentMenuViewController:(NSNotification *) notification {
    [self.frostedViewController presentMenuViewController];
}

#pragma mark – REFrostedViewController related
- (void)frostedViewController:(REFrostedViewController *)frostedViewController willShowMenuViewController:(UIViewController *)menuViewController {
    
    if ([NMDecibelLogger defaultLogger].logging) {
        [[NMDecibelLogger defaultLogger] stopLogging];
        _isToRestartLogging = YES;
    } else {
        _isToRestartLogging = NO;
    }
    
}

- (void)frostedViewController:(REFrostedViewController *)frostedViewController willHideMenuViewController:(UIViewController *)menuViewController {
    if (_isToRestartLogging) {
        [[NMDecibelLogger defaultLogger] startLogging];
    }
    
}

#pragma mark – BCTabBarControllerDelegate related
- (void)tabBarController:(BCTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
    UIViewController *firstviewController;
    
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        firstviewController = [(UINavigationController *) viewController topViewController];
    } else {
        firstviewController = viewController;
    }
    
    //确保必须是BaseViewController子类
    if ([firstviewController isKindOfClass:[BaseViewController class]]) {
        BaseViewController *baseViewController = (BaseViewController *) firstviewController;
        
        if (baseViewController.generalADButton.alpha == 1) {
            baseViewController.generalADButton.alpha = 0;
        }
        
        if ([baseViewController isKindOfClass:[MeterView class]]) {
            //stop the alarm if it's still playing
            if ([[NMDecibelLogger defaultLogger] playingAlarm]) {
                [[NMDecibelLogger defaultLogger] alarmComplete];
            }
        }
        
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^(){
                baseViewController.generalADButton.alpha = 1;
                NSLog(@"%s:ADBanner transient",__FUNCTION__);
            }completion:nil];
        });
    }
    
}

#pragma mark – UIApplicationWillResignActiveNotification
- (void) willResignActiveNotification:(NSNotification *) notification {
    if ((_tabBarController.selectedIndex != 0) && [NSUserDefaultsHelper isNotAllowBackgroundRunning] == FALSE) {
        [_tabBarController setSelectedIndex:0];
    }
    
}



- (void)dealloc {
    _tabBarController = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
