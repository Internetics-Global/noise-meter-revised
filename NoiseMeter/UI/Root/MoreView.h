//
//  MoreView.h
//  NoiseMeter
//
//  Created by Dave Finster on 20/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "GAITrackedViewController.h"

@interface MoreView : GAITrackedViewController<UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>{
    UITableView *_optionTable;
    MFMailComposeViewController *_mailer;
}

@end
