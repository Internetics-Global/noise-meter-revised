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
    
    if ([NSUserDefaultsHelper isProVersion]) {
        
    } else {
        //free version
        
        BOOL val = [[NSUserDefaults standardUserDefaults] boolForKey:K_Reminder_Free_Flag];
        if (val == FALSE) {
            [UIAlertView showWithTitle:@"Thank you for using NoiseDown" message:@"Have you seen the great new features in our PRO versions?\nIf you haven't already upgraded, visit SETTINGS > UPGRADE to see what's on offer including background running, continuous mode, silent mode, email found files and much more." cancelButtonTitle:@"OK" otherButtonTitles:nil tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:K_Reminder_Free_Flag];
            }];
        }
    }
    
    
    
}


@end
