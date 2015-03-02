//
//  ScoreArrayDataSource.h
//  NoiseMeter
//
//  Created by Bourne Wang on 9/02/2015.
//  Copyright (c) 2015 Internetics Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ReloadTableBlock)(void);

@interface ScoreArrayDataSource : NSObject <UITableViewDataSource>

@property (assign, nonatomic) BOOL   sortedByDate;


- (id)initWithReloadTableBlock:(ReloadTableBlock) aReloadTableBlock;

@end
