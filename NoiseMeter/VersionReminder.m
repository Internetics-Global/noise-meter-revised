//
//  VersionReminder.m
//  NoiseMeter
//
//  Created by Bourne Wang on 27/02/2015.
//  Copyright (c) 2015 Internetics Pty Ltd. All rights reserved.
//

#import "VersionReminder.h"
#import "UIAlertView+Blocks.h"

#define K_Reminder_Free_Flag              @"K_Reminder_Free_Flag"
#define K_Reminder_PRO_Flag               @"K_Reminder_PRO_Flag"
#define K_Reminder_PRO_CLASSROOM_Flag     @"K_Reminder_PRO_CLASSROOM_Flag"


@implementation VersionReminder

+ (void) setupVersionReminder {
    
    if ([NSUserDefaultsHelper isProClassRoomVersion]) {
        
        BOOL val = [[NSUserDefaults standardUserDefaults] boolForKey:K_Reminder_PRO_CLASSROOM_Flag];
        if (val == FALSE) {
            [UIAlertView showWithTitle:@"Thank you for your purchase" message:@"You have the full version of Noise Down CLASSROOM." cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:K_Reminder_PRO_CLASSROOM_Flag];
            }];
        }
        
    } else if ([NSUserDefaultsHelper isProVersion]) {
        
        BOOL val = [[NSUserDefaults standardUserDefaults] boolForKey:K_Reminder_PRO_Flag];
        if (val == FALSE) {
            [UIAlertView showWithTitle:@"Thank you for upgrading Noise Down" message:@"Want even more power? Go to Settings > Upgrade and look at our CLASSROOM edition." cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:K_Reminder_PRO_Flag];
            }];
        }
        
    } else {
        //free version
        
        BOOL val = [[NSUserDefaults standardUserDefaults] boolForKey:K_Reminder_Free_Flag];
        if (val == FALSE) {
            [UIAlertView showWithTitle:@"Thank you for using NoiseDown" message:@"Have you seen the great new features in our PRO or CLASSROOM versions?\nIf you haven't already upgraded, visit SETTINGS > UPGRADE to see what's on offer including background running, continuous mode, silent mode, email found files and much more." cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:K_Reminder_Free_Flag];
            }];
        }
    }
    
    
    
}


@end
