//
//  ScoreArrayDataSource.m
//  NoiseMeter
//
//  Created by Bourne Wang on 9/02/2015.
//  Copyright (c) 2015 Internetics Pty Ltd. All rights reserved.
//

#import "ScoreArrayDataSource.h"
#import "SoundLevelCaptureCell.h"
#import <MessageUI/MessageUI.h>
#import "FileHelper.h"
#import "UIAlertView+Blocks.h"
#import "IDPSoundBoard.H"

@interface ScoreArrayDataSource () <SWTableViewCellDelegate,MFMailComposeViewControllerDelegate> {
    NSArray           *_scores;
    ReloadTableBlock  _reloadTableBlock;
}

@end

@implementation ScoreArrayDataSource

- (id)initWithReloadTableBlock:(ReloadTableBlock) aReloadTableBlock
{
    self = [super init];
    if (self) {
        _reloadTableBlock = [aReloadTableBlock copy];
    }
    return self;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.sortedByDate) {
      _scores = [SoundLevelCapture sortedScoreArrayByDate];
    } else {
      _scores = [SoundLevelCapture sortedScoreArrayByNoiseLevel];
    }
    
    return [_scores count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SoundLevelCaptureCell *cell = (SoundLevelCaptureCell *)[tableView dequeueReusableCellWithIdentifier:@"Sound"];
    if (cell == nil) {
        cell = [[SoundLevelCaptureCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Sound"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.capture = [_scores objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.playButton.tag = indexPath.row;
    [cell.playButton addTarget:self action:@selector(playRecordedSound:) forControlEvents:UIControlEventTouchDown];
    
    cell.shareButton.tag = indexPath.row;
    [cell.shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchDown];

    
    if ([NSUserDefaultsHelper isProVersion]) {
        cell.rightUtilityButtons = [self rightCellButtons];
        cell.delegate = self;
        cell.tag = indexPath.row;
    }
    
    
    return cell;
}


- (NSArray *)rightCellButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.38f green:0.78f blue:0.8f alpha:1.0]
                                                title:@"Rename"];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];
    
    return rightUtilityButtons;
}

- (void) playRecordedSound: (id) sender {
    
    long index = ((UIButton *) sender).tag;
    
    NSURL *url = [self selecedRecordedFile:index];
    
    [IDPSoundBoard addAudioAtPath:[url path] forKey:Key_PlayerRecorded forType:EnumSoundType_Recorded];
    AVAudioPlayer *player = [IDPSoundBoard audioPlayerForKey:Key_PlayerRecorded];
    player.numberOfLoops = 0;  
    [IDPSoundBoard playAudioForKey:Key_PlayerRecorded fadeInInterval:2.0];
}

- (void) share: (id) sender {
    
    if ([NSUserDefaultsHelper isProClassRoomVersion] == false) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"This is a Noise Down CLASSROOM function" message:@"You can upgrade the app to get it!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    long index = ((UIButton *) sender).tag;
    NSURL *url = [self selecedRecordedFile:index];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] init];
        composeViewController.mailComposeDelegate = self;
        composeViewController.navigationBar.tintColor = [UIColor whiteColor];
        [composeViewController setSubject:@"Hi"];
        [composeViewController setMessageBody:@"" isHTML:YES];
        //mime type: http://www.feedforall.com/mime-types.htm
        [composeViewController addAttachmentData:data mimeType:@"audio/x-aiff" fileName:[NSString stringWithFormat:@"%@.aiff",[url lastPathComponent]]];
        [composeViewController setToRecipients:nil];
        [composeViewController.navigationBar setTintColor:[UIColor blackColor]];
        
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:composeViewController animated:YES completion:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please configure your email in Settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
    
}

- (NSURL *) selecedRecordedFile:(long) tableCellIndex {
    
    SoundLevelCapture *caputure = [_scores objectAtIndex:tableCellIndex];
    
    NSDate *date = caputure.date;
    NSString *dateString = [FileHelper convertDate:date];
    
    NSURL *url = [FileHelper getRecordedAudioFile:dateString];
    return url;
    
}

#pragma mark – MFMailComposeViewController
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissModalViewControllerAnimated:YES];
}


#pragma mark – SWTableViewCellDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    long cellIndex = cell.tag;
    
    switch (index) {
        case 1:
        {
            NSInteger index = cell.tag;
            if ([_scores count] > index) {
                SoundLevelCapture *capture = [_scores objectAtIndex:index];
                [SoundLevelCapture remove:capture];
                [self reloadData];
            } else {
                NSLog(@"error [_scores count] should > index");
            }
            break;
        }
        case 0:
        {
        
            if ([NSUserDefaultsHelper isProClassRoomVersion] == false) {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"This is a Noise Down CLASSROOM function" message:@"You can upgrade the app to get it!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            } else {
                UIAlertView *alertView = [UIAlertView showWithTitle:@"Rename"
                                                            message:@""
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@[@"OK"]
                                                           tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                               if (buttonIndex == [alertView cancelButtonIndex]) {
                                                                   NSLog(@"Cancelled");
                                                               } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"]) {
                                                                   NSString *newName = [alertView textFieldAtIndex:0].text;
                                                                   [self updateCaptureName:cellIndex withNewname:newName];
                                                               }
                                                           }];
                alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            }
            
            
            
            
            break;
        }
        default:
            break;
    }
}

- (void) updateCaptureName:(long) cellIndex withNewname:(NSString *) newName {
    SoundLevelCapture *capture = [_scores objectAtIndex:cellIndex];
    [SoundLevelCapture updateCapture:capture withNewName:newName];
    [self reloadData];
    
}

- (void)reloadData
{
    if (self.sortedByDate) {
        _scores = [SoundLevelCapture sortedScoreArrayByDate];
    } else {
        _scores = [SoundLevelCapture sortedScoreArrayByNoiseLevel];
    }
    _reloadTableBlock();
    
}





@end
