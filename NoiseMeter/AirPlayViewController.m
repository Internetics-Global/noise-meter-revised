//
//  AirPlayViewController.m
//  NoiseMeter
//
//  Created by Bourne Wang on 3/22/14.
//  Copyright (c) 2014 Internetics Pty Ltd. All rights reserved.
//

#import "AirPlayViewController.h"
#import "ASDepthModalViewController.h"
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


- (IBAction)closePopupAction:(id)sender
{
    [ASDepthModalViewController dismiss];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _volumeView = [ [MPVolumeView alloc] init] ;
//    _volumeView.backgroundColor = [UIColor blueColor];
    [_volumeView setShowsRouteButton:YES];
    _volumeView.frame = CGRectMake(208, 37, CGRectGetWidth(_volumeView.frame), CGRectGetHeight(_volumeView.frame));
    [_volumeView sizeToFit];
    [_volumeView setShowsVolumeSlider:NO];
    [self.view addSubview:_volumeView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL success;
        NSError *error;
        
        [[AVAudioSession sharedInstance] setDelegate:self];
        
        //every time when you change the category, it will automatically trigger audioRouteChangeListenerCallback
        success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        if (!success) {
            NSLog(@"%s:AVAudioSession error setting category %@",__FUNCTION__,error);
        }
        
        APP_DELEGATE.isOnAirPlaySettingView = YES;
    });
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        APP_DELEGATE.isOnAirPlaySettingView = NO;
        
        BOOL success;
        NSError *error;
        
        [[AVAudioSession sharedInstance] setDelegate:self];
        
        //every time when you change the category, it will automatically trigger audioRouteChangeListenerCallback
        success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        if (!success) {
            NSLog(@"%s:AVAudioSession error setting category %@",__FUNCTION__,error);
        }
        
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
    });
    
    
}

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
- (IBAction)dismiss:(id)sender {
    [ASDepthModalViewController dismiss];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
