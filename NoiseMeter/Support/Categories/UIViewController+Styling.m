//
//  UIViewController+Styling.m
//  NoiseMeter
//
//  Created by Dave Finster on 6/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import "UIViewController+Styling.h"
#import "ScoreView.h"
#import "PurchaseViewController.h"
#import "MoreView.h"

@implementation UIViewController (Styling)

- (void)back
{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else if (self.frostedViewController) {
        RootView *rootView = [[RootView alloc] init];
        self.frostedViewController.contentViewController = rootView;
        [self.frostedViewController hideMenuViewController];
    }
}



- (void)style:(BOOL) isToShowBackButton
{

    self.view.backgroundColor = kGrayColor;
    
    UIView *topBlackView = [[UIView alloc] init];
    topBlackView.backgroundColor = [UIColor blackColor];
    topBlackView.frame = CGRectMake(0, 0, self.view.frame.size.width, KTopLogoHeight);
    [self.view addSubview:topBlackView];
    
    UIImageView *_topImage;
    if ([NSUserDefaultsHelper isProClassRoomVersion] ) {
      _topImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_logo-pro-classroom.png"]];
    
    } else if ([NSUserDefaultsHelper isProVersion]) {
      _topImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_logo-pro.png"]];
    } else {
      _topImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top_logo.png"]];
    }
    _topImage.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _topImage.tag = K_TOP_IMAGEVIEW_TAG;
    _topImage.frame = CGRectMake(30, 0, self.view.frame.size.width - 30*2, KTopLogoHeight);
    [_topImage setContentMode:UIViewContentModeScaleAspectFit];
    [self.view addSubview:_topImage];
    
    if (isToShowBackButton) {
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.backgroundColor = [UIColor clearColor];
        [closeButton setImage:[UIImage imageNamed:@"close-white"] forState:UIControlStateNormal];
        closeButton.frame = CGRectMake(10, CGRectGetMidY(topBlackView.frame) - 11, 22, 22);
        
        [self.view addSubview:closeButton];
        [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchDown];
    }
    
    
    
}

#pragma mark Help Overlay

- (void)displayHelpOverlayWithText:(NSString *)text{
	UIView *overlay = nil;
    UIView *textView = nil;
    if ([self.view viewWithTag:50] != nil) 
    {
        overlay = [self.view viewWithTag:50];
        textView = [self.view viewWithTag:51];
    }
    else 
    {
        overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 490.0)];
        textView = [[UIView alloc] initWithFrame:CGRectMake(35, (self.view.frame.size.height-230)/2, 250.0, 230.0)];
    }
	[overlay setAlpha:0.0];
	[overlay setBackgroundColor:[UIColor blackColor]];
	[textView setBackgroundColor:[UIColor clearColor]];
	[textView setAlpha:0.0];
	UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 250.0, 230.0)];
	[image setImage:[UIImage imageNamed:@"overlay02.png"]];
	[textView addSubview:image];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8, 5, 250.0, 20.0)];
	label.text = @"Help";
	[label setBackgroundColor:[UIColor clearColor]];
	[label setFont:[UIFont fontWithName:@"Arial-BoldMT" size:15.0]];
	[textView addSubview:label];
	UITextView *scroller = [[UITextView alloc] initWithFrame:CGRectMake(0, 30, 250.0, 150.0)];
	if (text != nil) {
		scroller.text = text;
	}else {
		scroller.text = @"Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.";
	}
	[scroller setBackgroundColor:[UIColor clearColor]];
	[scroller setEditable:NO];
	[scroller setFont:[UIFont fontWithName:@"Arial-BoldMT" size:13.0]];
	[textView addSubview:scroller];
	UIButton *okayButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[okayButton setFrame:CGRectMake(25, 190, 200.0, 30.0)];
	[okayButton setBackgroundImage:[UIImage imageNamed:@"button_close.png"] forState:UIControlStateNormal];
	[okayButton addTarget:self action:@selector(dismissHelpOverlay) forControlEvents:UIControlEventTouchUpInside];
	[textView addSubview:okayButton];
    [overlay setTag:50];
    [textView setTag:51];
	[self.view addSubview:overlay];
	[self.view addSubview:textView];
	[UIView beginAnimations:@"FadeInAnimation" context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.5];
	[overlay setAlpha:0.8];
	[textView setAlpha:0.9];
	[UIView commitAnimations];	
}

- (void)dismissHelpOverlay{
	[UIView beginAnimations:@"FadeOutAnimation" context:NULL];
	[UIView setAnimationDuration:0.5];
	[[self.view viewWithTag:50] setAlpha:0.0];
	[[self.view viewWithTag:51] setAlpha:0.0];
	[UIView commitAnimations];	
}

- (UIButton *) findBackButton {
    NSArray *subViews = [self.view subviews];
    for (UIView *myView in subViews) {
        if ((myView.tag == 314) && ([myView isMemberOfClass:[UIButton class]])) {
            return ((UIButton *) myView);
        }
    }
    
    return nil;
}

- (UIImageView *) findTopBarImageView {
    UIImageView *imageView = nil;
    NSArray *viewArray = [self.view subviews];
    for (UIView *myView in viewArray) {
        if ((myView.tag == K_TOP_IMAGEVIEW_TAG) &&
            ([myView isKindOfClass:[UIImageView class]])) {
            imageView =  ((UIImageView *) myView);
            break;
        }
    }
    
    return imageView;
}

- (void) dismiss {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
