//
//  CreateAlarmSoundViewController.m
//  NoiseMeter
//
//  Created by Bourne Wang on 14-2-13.
//  Copyright (c) 2014年 Internetics Pty Ltd. All rights reserved.
//

#import "CreateAlarmSoundViewController.h"
#import "FileHelper.h"

@interface CreateAlarmSoundViewController ()

@end

@implementation CreateAlarmSoundViewController

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
    // Do any additional setup after loading the view from its nib.
    
    _playButton.hidden = YES;
    _saveButton.hidden = YES;
    
    _startButton.layer.cornerRadius =60;
    _startButton.layer.shadowColor = [[UIColor redColor] CGColor];
    _startButton.layer.shadowOpacity = 1.0f;
    _startButton.layer.shadowRadius = 10.0f;
    
    APP_DELEGATE.isCreatingCustomAlarmFile = YES;
    
    [[NMDecibelLogger defaultLogger] stopLogging];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)startButtonClicked:(id)sender {
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        _playButton.hidden = YES;
        _saveButton.hidden = YES;
        
        [[NMDecibelLogger defaultLogger] startLogging];
        
        NSDate*start =[NSDate date];
        while (1) {
            usleep(10000);
            NSDate* methodFinish =[NSDate date];
            NSTimeInterval executionTime =[methodFinish timeIntervalSinceDate:start];
            if (executionTime > 5) {
                NSLog(@"%s:finish recording a new customized alarm sound",__FUNCTION__);
                break;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_alertLabel setText:[NSString stringWithFormat:@"Time left: %.2f",5.0 - executionTime]];
            });
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            usleep(200000);
            [_alertLabel setText:@"Tap the start button to record"];
            
            _playButton.hidden = NO;
            _saveButton.hidden = NO;
        });
        
        sleep(0.5); //the reason why we put here is there's some latency
        [[NMDecibelLogger defaultLogger] stopLogging];
        
        
    });
    
}


- (IBAction)playButtonClicked:(id)sender {
    
    NSURL *path = [FileHelper getDefaultRecordedaAudioFile];
    
    if (path)
    {
        OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef) path, &_audioEffect);
        if (error != kAudioServicesNoError)
        {
          NSLog(@"Invalid");
        }
        else
        {
          AudioServicesPlaySystemSound(_audioEffect);
        }
    }
    else
    {
        NSLog(@"%s:No file",__FUNCTION__);
    }
    
    
}

- (IBAction)closeButtonClicked:(id)sender {
    [self dismiss];
}

- (IBAction)saveButtonClicked:(id)sender {
    if (_audioEffect != 0) {
        AudioServicesRemoveSystemSoundCompletion(_audioEffect);
        AudioServicesDisposeSystemSoundID(_audioEffect);
        _audioEffect = 0;
    }
    
    NSURL *path = [FileHelper getDefaultRecordedaAudioFile];
    [FileHelper saveNewCreatedAlarm:path];
    [self dismiss];
    
}

- (void) dismiss {

  APP_DELEGATE.isCreatingCustomAlarmFile = NO;
    
  [[NMDecibelLogger defaultLogger] startLogging];
    
  [self dismissViewControllerAnimated:YES completion:nil];
  
  if (_audioEffect != 0) {
    AudioServicesRemoveSystemSoundCompletion(_audioEffect);
    AudioServicesDisposeSystemSoundID(_audioEffect);
    _audioEffect = 0;
  }
}

@end
