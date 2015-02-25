//
//  SelectMeter.h
//  NoiseMeter
//
//  Created by Bourne Wang on 25/02/2015.
//  Copyright (c) 2015 Internetics Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SelectMeterView : BaseViewController<UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate>{
    UITableView *_alertTable;
}

@end
