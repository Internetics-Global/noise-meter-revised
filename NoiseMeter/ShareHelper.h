//
//  ShareHelper.h
//  NoiseMeter
//
//  Created by Bourne Wang on 14-3-12.
//  Copyright (c) 2014年 Internetics Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareHelper : NSObject

+ (UIImage *)fullScreenshot;

+ (void) postToTwitter:(UIViewController *) currentViewController withImage:(UIImage *)image withMsg:(NSString *) msg;
+ (void)postToFacebook:(UIViewController *) currentViewController withImage :(UIImage *)image withMsg:(NSString *) msg;
@end
