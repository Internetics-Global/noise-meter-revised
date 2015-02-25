//
//  AboutView.m
//  NoiseMeter
//
//  Created by Dave Finster on 20/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import "AboutView.h"
#import "FileHelper.h"

@interface AboutView ()

@end

@implementation AboutView


- (void)loadView
{
    [super loadView];
    
    [self style];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
      _textView = [[UITextView alloc] initWithFrame:CGRectMake(10, KNavigationBarHeight + KTopLogoHeight, self.view.frame.size.width - 20, 300)];
    } else {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(10,  KTopLogoHeight, self.view.frame.size.width - 20, 300)];
    }
    
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _textView.text = @"\"Keep The Noise Down\" is great way to measure and control the noise levels in your home, workplace, classroom, or anywhere you need to \"keep the noise down\". \n\nPlease note that the decibel limits shown are for an approximate guidance only, are not scientifically tested or calculated and should not be relied upon for accuracy. Readings will vary from device to device and environment to environment.\n\nKeep the Noise Down is an app developed by Internetics. We welcome your feedback.";
    _textView.backgroundColor = [UIColor clearColor];
    _textView.textColor = [UIColor whiteColor];
    _textView.editable = NO;
    [self.view addSubview:_textView];
    
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_textView.frame) + 10, 320, 30)];
    versionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    versionLabel.backgroundColor = [UIColor clearColor];
    versionLabel.text = [NSString stringWithFormat:@"Version:%@ - Build:%@",[FileHelper appVersion],[FileHelper build]];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    versionLabel.textColor = [UIColor darkGrayColor];
    versionLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    [self.view addSubview:versionLabel];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _textView = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _textView.font = [UIFont fontWithName:@"Helvetica" size:14];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.screenName = @"AboutView Screen";

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
