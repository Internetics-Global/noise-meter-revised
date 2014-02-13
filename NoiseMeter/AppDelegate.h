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

/**
 *  Used to identify whether current view is on CreateAlarmSoundViewController
 *  add this because it could conflict with timerFire
 */
@property (assign, nonatomic) BOOL isCreatingCustomAlarmFile;

@end
