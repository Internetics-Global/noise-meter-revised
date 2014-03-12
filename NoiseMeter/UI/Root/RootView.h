//
//  RootView.h
//  NoiseMeter
//
//  Created by Dave Finster on 6/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface RootView : GAITrackedViewController <UITabBarControllerDelegate>{
    UITabBarController *_tabBarController;
}

@end
