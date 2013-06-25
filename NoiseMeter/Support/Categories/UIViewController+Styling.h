//
//  UIViewController+Styling.h
//  NoiseMeter
//
//  Created by Dave Finster on 6/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Styling)

- (void)style;
- (void)displayHelpOverlayWithText:(NSString *)text;
- (void)dismissHelpOverlay;

@end
