//
//  AirPlayViewController.m
//  NoiseMeter
//
//  Created by Bourne Wang on 3/21/14.
//  Copyright (c) 2014 Internetics Pty Ltd. All rights reserved.
//

#import "AirPlayViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface AirPlayViewController ()

@end

@implementation AirPlayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _volumeView = [ [MPVolumeView alloc] init] ;
    _volumeView.center = self.view.center;
    [_volumeView setShowsRouteButton:YES];
    [_volumeView sizeToFit];
    [_volumeView setShowsVolumeSlider:NO];
    
    [self.view addSubview:_volumeView];
    
    UILabel *alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_volumeView.frame) + 20, 320, 30)];
    alertLabel.textAlignment = UITextAlignmentCenter;
    alertLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    alertLabel.text = @"Make sure you have connected to an airplay device";
    alertLabel.numberOfLines = 3;
    alertLabel.textColor = [UIColor whiteColor];
    alertLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:alertLabel];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL success;
        NSError *error;
        
        [[AVAudioSession sharedInstance] setDelegate:self];
        
        success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        if (!success) {
            NSLog(@"%s:AVAudioSession error setting category %@",__FUNCTION__,error);
        }
    });
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL success;
        NSError *error;
        
        [[AVAudioSession sharedInstance] setDelegate:self];
        
        success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        if (!success) {
            NSLog(@"%s:AVAudioSession error setting category %@",__FUNCTION__,error);
        }
    });
    
    self.navigationController.navigationBarHidden = YES;
    
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [ [UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [ [UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    
    MPMediaItemArtwork *albumArt = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://dl.dropbox.com/s/14ph9hzxkorq85l/Icon%402x.png"]]]];
    
    NSArray *keys = [NSArray arrayWithObjects:
                     MPMediaItemPropertyTitle,
                     MPMediaItemPropertyArtwork,
                     nil];
    NSArray *values = [NSArray arrayWithObjects:
                       @"Baby monitor by NoiseDown",
                       albumArt,
                       nil];
    NSDictionary *mediaInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaInfo];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Now you can press sleep button and put the phone near the baby. Once your baby cries, sound will directly streamline to your AirPlay device " delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark – Airplay related

- (BOOL) canBecomeFirstResponder {
    return YES;
}

//currently, no use, but we still put here
- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                //[self playPauseToggle: nil]
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                //[self nextTrack: nil]
                break;
                
            default:
                break;
        }
    }
}

@end
