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
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTask;

/**
 *  Used to identify whether current view is on CreateAlarmSoundViewController
 *  add this because it could conflict with timerFire
 */
@property (assign, nonatomic) BOOL isCreatingCustomAlarmFile;

/**
 *  used to record the flag when we switched meter off
 *  A. If we switched Meter off， then Background running should be off.
 *  B. If we switched Meter on， and if background running setting before we switched Meter off is on, now we put background running on
 *. C. If we switched Meter on， and if background running setting before we switched Meter off is off, now we put background running off
 */
@property (assign, nonatomic) BOOL isNotAllowBackgroundRunningWhenLastMeterOff;

@property (assign, nonatomic) BOOL isOnAirPlayMode;

@end
