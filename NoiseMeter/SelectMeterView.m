//
//  SelectMeter.m
//  NoiseMeter
//
//  Created by Bourne Wang on 25/02/2015.
//  Copyright (c) 2015 Internetics Pty Ltd. All rights reserved.
//

#import "SelectMeterView.h"

@implementation SelectMeterView

- (void)loadView
{
    [super loadView];
    
    [self style:YES];
    
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _alertTable = [[UITableView alloc] initWithFrame:CGRectMake(0, KTopLogoHeight, self.view.frame.size.width, CGRectGetMaxY(self.view.frame) - KTopLogoHeight) style:UITableViewStyleGrouped];
    _alertTable.delegate = self;
    _alertTable.dataSource = self;
    _alertTable.opaque = NO;
    _alertTable.backgroundView = nil;
    _alertTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _alertTable.separatorColor = [UIColor colorWithRed:97.0/255 green:97.0/255 blue:97.0/255 alpha:1];
    _alertTable.backgroundColor = [UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1];
    
    [self.view addSubview:_alertTable];
    
    if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
        [self viewWillAppear:YES];
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_alertTable reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (3);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;

    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = @"Circle";
    }
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = @"Rectangle";
    }
    else if (indexPath.row == 2)
    {
        cell.textLabel.text = @"Triangle";
    }
    
    MeterDisplayType meterDisplayType = [NSUserDefaultsHelper meterDisplayType];
    if (meterDisplayType  == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        cell.tintColor = [UIColor whiteColor];
    }
    
    cell.backgroundColor = [UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1];
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [NSUserDefaultsHelper setMeterDisplayType:indexPath.row];
    
    [self dismissModalViewControllerAnimated:YES];
    
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.screenName = @"SlectMeterView Screen";
    
}

@end
