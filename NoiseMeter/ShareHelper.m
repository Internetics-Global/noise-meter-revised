//
//  ShareHelper.m
//  NoiseMeter
//
//  Created by Bourne Wang on 14-3-12.
//  Copyright (c) 2014年 Internetics Pty Ltd. All rights reserved.
//

#import "ShareHelper.h"
#import <Social/Social.h>

@implementation ShareHelper


+ (UIImage *)fullScreenshot {
    UIWindow *screenWindow = [[UIApplication sharedApplication] keyWindow];
    
    UIGraphicsBeginImageContext(screenWindow.frame.size);
    
    [screenWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return viewImage;

}

+ (void) postToTwitter:(UIImage *)image withMsg:(NSString *) msg{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *controller = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [controller addImage:image];
        [controller setInitialText:msg];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:controller animated:YES completion:nil];
    }
}

+ (void)postToFacebook :(UIImage *)image withMsg:(NSString *) msg{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [controller addImage:image];
        [controller setInitialText:msg];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:controller animated:YES completion:Nil];
    }
}

@end
