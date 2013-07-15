//
//  AppDelegate.h
//  NoiseMeter
//
//  Created by Dave Finster on 17/02/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootView.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    RootView *_rootView;
    BOOL _comingFromBackground;
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

@end
