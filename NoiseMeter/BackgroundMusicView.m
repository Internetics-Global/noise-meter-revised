//
//  BackgroundMusicView.m
//  NoiseMeter
//
//  Created by Internetics on 9/03/2016.
//  Copyright © 2016 Internetics Pty Ltd. All rights reserved.
//

#import "BackgroundMusicView.h"
#import "IDPSoundBoard.h"
@import FirebaseAnalytics;

#define K_Maximum_Volume           0.2f
#define K_Min_Volume               0.001f
#define K_Maximum_Volume_Nominal   30.0f
#define K_Min_Volume_Nominal        1.0f


@implementation BackgroundMusicView {
    
    NSArray *_soundName; //the name shown on list
    NSArray *_soundFileName;//the file name
    
    UILabel *_volumeSlideDeslabel;
    UISlider *_volumeSlider;
}


- (void)loadView
{
    [super loadView];
    
    [self style:YES];
    
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _soundName = [NSArray arrayWithObjects:@"Birds",@"Birds at sea",@"Nature",@"Piano",@"Guitar",nil];
    _soundFileName = [IDPSoundBoard getBackgroundMusicFiles];
    
    _alertTable = [[UITableView alloc] initWithFrame:CGRectMake(0, KTopLogoHeight, self.view.frame.size.width, 260) style:UITableViewStyleGrouped];
    _alertTable.delegate = self;
    _alertTable.dataSource = self;
    _alertTable.opaque = NO;
    _alertTable.scrollEnabled = FALSE;
    _alertTable.backgroundView = nil;
    _alertTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _alertTable.separatorColor = [UIColor colorWithRed:97.0/255 green:97.0/255 blue:97.0/255 alpha:1];
    _alertTable.backgroundColor = [UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1];
    [self.view addSubview:_alertTable];
    
    
    _volumeSlideDeslabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_alertTable.frame), 320-15*2, 15)];
    _volumeSlideDeslabel.textAlignment = NSTextAlignmentLeft;
    _volumeSlideDeslabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    _volumeSlideDeslabel.text = [NSString stringWithFormat:@"Set volume: %d",(int)[self getNominalVolume:[NSUserDefaultsHelper getBackgroundMusicVolume]]];
    _volumeSlideDeslabel.numberOfLines = 1;
    _volumeSlideDeslabel.textColor = [UIColor whiteColor];
    _volumeSlideDeslabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_volumeSlideDeslabel];
    
    _volumeSlider= [[UISlider alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_volumeSlideDeslabel.frame) + 10, 320 - 15*2, 20)];
    _volumeSlider.backgroundColor = [UIColor grayColor];
    _volumeSlider.minimumValue = K_Min_Volume;
    _volumeSlider.maximumValue = K_Maximum_Volume;
    _volumeSlider.continuous = NO;
    _volumeSlider.value = [NSUserDefaultsHelper getBackgroundMusicVolume];
    _volumeSlider.tintColor = [UIColor greenColor];
    [_volumeSlider addTarget:self action:@selector(volumeSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [_volumeSlider setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview: _volumeSlider];
    
    UILabel *volumeMinlabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(_volumeSlider.frame) + 5, 25, 15)];
    volumeMinlabel.textAlignment = NSTextAlignmentLeft;
    volumeMinlabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    volumeMinlabel.text = [NSString stringWithFormat:@"%d",(int)K_Min_Volume_Nominal];
    volumeMinlabel.numberOfLines = 1;
    volumeMinlabel.textColor = [UIColor whiteColor];
    volumeMinlabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:volumeMinlabel];
    
    UILabel *volumeMaxlabel = [[UILabel alloc] initWithFrame:CGRectMake(295, CGRectGetMaxY(_volumeSlider.frame) + 5, 20, 15)];
    volumeMaxlabel.textAlignment = NSTextAlignmentLeft;
    volumeMaxlabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    volumeMaxlabel.text = [NSString stringWithFormat:@"%d",(int)K_Maximum_Volume_Nominal];
    volumeMaxlabel.numberOfLines = 1;
    volumeMaxlabel.textColor = [UIColor whiteColor];
    volumeMaxlabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:volumeMaxlabel];
    
    
    
    
    if (SYSTEM_VERSION_LESS_THAN(@"5.0")) {
        [self viewWillAppear:YES];
    }

    self.view.backgroundColor = [UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1];
    
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_alertTable reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (5);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSString *fileName = [NSUserDefaultsHelper backgroundMusicFileName];
    
    if (indexPath.row >= 0 && indexPath.row <= 4)
    {
        cell.textLabel.text = _soundName[indexPath.row];
        
        if ([_soundFileName[indexPath.row] isEqualToString:fileName]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellStyleDefault;
        }
    }
//    else if (indexPath.row == 5)
//    {
//        cell.textLabel.text = @"Select from library";   //deprecated since we can not play music from Apple music, see https://forums.developer.apple.com/thread/7791
//    }
    
    
    
    
    
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
        
        if ([NSUserDefaultsHelper isBackgroundMusicOn]) {
            [IDPSoundBoard restartBackgroundSound];
        }
        
        [_alertTable reloadData];
        
        //[self dismissViewControllerAnimated:YES completion:nil];
    }
    
}


- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSDictionary *dimensions = @{
                                 kFIRParameterItemCategory:@"view_page",
                                 kFIRParameterItemName:@"BackgroundMusicView"
                                 };
    [FIRAnalytics logEventWithName:kFIREventViewItem parameters:dimensions];
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void) volumeSliderChanged:(UISlider *) slider {
    
    float volume = slider.value;
    [NSUserDefaultsHelper setBackgroundMusicVolume:volume];
    
    float nominalVolume = [self getNominalVolume:volume];
    
    _volumeSlideDeslabel.text = [NSString stringWithFormat:@"Set volume: %d",(int)nominalVolume];
    
    [IDPSoundBoard updateBackgroundRunningVolume];
    
}

- (float) getNominalVolume :(float)realVolume {
    float nominalVolume = (K_Maximum_Volume_Nominal - K_Min_Volume_Nominal)/(K_Maximum_Volume - K_Min_Volume) * (realVolume - K_Min_Volume) + 1;
    return nominalVolume;
}


- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    
    MPMediaItem *item = [[mediaItemCollection items] objectAtIndex:0];
    NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (url) {
        [NSUserDefaultsHelper setBackgroundMusicFileName:[url absoluteString]];
        if ([NSUserDefaultsHelper isBackgroundMusicOn]) {
            [IDPSoundBoard restartBackgroundSound];
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Not supported, please select another music." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
    
}
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
