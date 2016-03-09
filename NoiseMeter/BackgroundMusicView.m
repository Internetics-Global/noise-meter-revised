//
//  BackgroundMusicView.m
//  NoiseMeter
//
//  Created by Internetics on 9/03/2016.
//  Copyright © 2016 Internetics Pty Ltd. All rights reserved.
//

#import "BackgroundMusicView.h"
#import <Parse/PFAnalytics.h>


@implementation BackgroundMusicView {
    
    NSArray *_soundName; //the name shown on list
    NSArray *_soundFileName;//the file name
}


- (void)loadView
{
    [super loadView];
    
    [self style:YES];
    
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _soundName = [NSArray arrayWithObjects:@"Mute",@"Birds",@"Birds at sea",@"Nature",@"Piano",nil];
    _soundFileName = [NSArray arrayWithObjects:@"demo.mp3",@"bg_loop_birds.mp3",@"bg_loop_birds_at_sea.mp3",@"bg_loop_nature.mp3",@"bg_loop_piano.mp3",nil];
    
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
    return (6);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSString *fileName = [NSUserDefaultsHelper backgroundMusicFileName];
    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = _soundName[0];
        
        if ([_soundFileName[0] isEqualToString:fileName]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = _soundName[1];
        
        if ([_soundFileName[1] isEqualToString:fileName]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else if (indexPath.row == 2)
    {
        cell.textLabel.text = _soundName[2];
        
        if ([_soundFileName[2] isEqualToString:fileName]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else if (indexPath.row == 3)
    {
        cell.textLabel.text = _soundName[3];
        
        if ([_soundFileName[3] isEqualToString:fileName]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else if (indexPath.row == 4)
    {
        cell.textLabel.text = _soundName[4];
        
        if ([_soundFileName[4] isEqualToString:fileName]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else if (indexPath.row == 5)
    {
        cell.textLabel.text = @"Select from library";
    }
    
    
    
    
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        cell.tintColor = [UIColor whiteColor];
    }
    
    cell.backgroundColor = [UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 5) {
        
        MPMediaPickerController *picker =
        [[MPMediaPickerController alloc]
         initWithMediaTypes: MPMediaTypeAnyAudio];
        
        [picker setDelegate: self];
        [picker setAllowsPickingMultipleItems: YES];
        picker.prompt = @"Select a song from library";
        [self presentViewController:picker animated:YES completion:nil];
        
    } else {
        [NSUserDefaultsHelper setBackgroundMusicFileName:_soundFileName[indexPath.row]];
        
        [self dismissModalViewControllerAnimated:YES];
    }
    
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSDictionary *dimensions = @{@"category": @"BackgroundMusicView Screen"};
    [PFAnalytics trackEvent:@"page" dimensions:dimensions];
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    
    MPMediaItem *item = [[mediaItemCollection items] objectAtIndex:0];
    NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    [NSUserDefaultsHelper setBackgroundMusicFileName:[url absoluteString]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
