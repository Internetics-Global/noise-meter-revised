//
//  InternalWebView.h
//  NoiseMeter
//
//  Created by Dave Finster on 21/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InternalWebView : BaseViewController<UIWebViewDelegate>{
    UIWebView *_webView;
    UIActivityIndicatorView *_activity;
    NSString *_destination;
}

- (id)initWithDestination:(NSString *)destination;

@end
