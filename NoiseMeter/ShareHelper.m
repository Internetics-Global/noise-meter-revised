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

+ (void) postToTwitter:(UIViewController *) currentViewController withImage:(UIImage *)image withMsg:(NSString *) msg{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *controller = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [controller addImage:image];
        [controller setInitialText:msg];
        [currentViewController presentViewController:controller animated:YES completion:nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Twitter Account" message:@"There are no Twitter accounts configured. You can add or create a Facebook account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

+ (void)postToFacebook:(UIViewController *) currentViewController withImage :(UIImage *)image withMsg:(NSString *) msg{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [controller addImage:image];
        [controller setInitialText:msg];
        [currentViewController presentViewController:controller animated:YES completion:Nil];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Facebook Account" message:@"There are no Facebook accounts configured. You can add or create a Facebook account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

@end
