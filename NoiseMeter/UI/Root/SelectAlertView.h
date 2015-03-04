//
//  SelectAlertView.h
//  NoiseMeter
//
//  Created by Dave Finster on 21/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectAlertView : BaseViewController<UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate>{
    UITableView *_alertTable;
}

@end
