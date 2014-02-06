//
//  NSUserDefaultsHelper.h
//  NoiseMeter
//
//  Created by Bourne Wang on 14-2-6.
//  Copyright (c) 2014年 Internetics Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaultsHelper : NSObject

+ (BOOL) isAdRemoved;
+ (void) setAdRemoveFlag:(BOOL) flag;

@end
