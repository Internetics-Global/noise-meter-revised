//
//  BackgroundMusicView.h
//  NoiseMeter
//
//  Created by Internetics on 9/03/2016.
//  Copyright © 2016 Internetics Pty Ltd. All rights reserved.
//

#import "BaseViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface BackgroundMusicView : BaseViewController<UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate,MPMediaPickerControllerDelegate>{
    UITableView *_alertTable;
}

@end
