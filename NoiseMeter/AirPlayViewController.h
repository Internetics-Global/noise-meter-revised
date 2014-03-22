//
//  AirPlayViewController.h
//  NoiseMeter
//
//  Created by Bourne Wang on 3/22/14.
//  Copyright (c) 2014 Internetics Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface AirPlayViewController : UIViewController {
    MPVolumeView *_volumeView;
}

@property (weak, nonatomic) IBOutlet UITextView *titleTextView;

@end
