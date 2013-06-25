//
//  InternalWebView.m
//  NoiseMeter
//
//  Created by Dave Finster on 21/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import "InternalWebView.h"

@interface InternalWebView ()

@end

@implementation InternalWebView

- (id)initWithDestination:(NSString *)destination
{
    self = [super init];
    _destination = destination;
    return self;
}

- (void)loadView
{
    [super loadView];
    [self style];
    _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activity.frame = CGRectMake(self.view.frame.size.width - 26, 73, 21, 21);
    [self.view addSubview:_activity];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 105, self.view.frame.size.width, self.view.frame.size.height - 105)];
    _webView.delegate = self;
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_webView];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_destination]]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [_activity startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_activity stopAnimating];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    [_webView stopLoading];
    _webView = nil;
	_activity = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
