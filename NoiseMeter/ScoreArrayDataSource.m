//
//  ScoreArrayDataSource.m
//  NoiseMeter
//
//  Created by Bourne Wang on 9/02/2015.
//  Copyright (c) 2015 Internetics Pty Ltd. All rights reserved.
//

#import "ScoreArrayDataSource.h"
#import "SoundLevelCaptureCell.h"
#import "PlayHelper.h"
#import <MessageUI/MessageUI.h>
#import "FileHelper.h"
#import "UIAlertView+Blocks.h"

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
    _scores = [SoundLevelCapture sortedScoreArray];
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
    
    
    cell.playButton.tag = indexPath.row;
    [cell.playButton addTarget:self action:@selector(playRecordedSound:) forControlEvents:UIControlEventTouchDown];
    
    cell.shareButton.tag = indexPath.row;
    [cell.shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchDown];
    
    BOOL flag = [NSUserDefaultsHelper isAdRemoved];
    if (flag) {
        cell.playButton.hidden = NO;
        cell.shareButton.hidden = NO;
    } else {
        cell.playButton.hidden = YES;
        cell.shareButton.hidden = YES;
    }
    
    if ([NSUserDefaultsHelper isAdRemoved]) {
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
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Delete"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                title:@"Rename"];
    
    return rightUtilityButtons;
}

- (void) playRecordedSound: (id) sender {
    
    long index = ((UIButton *) sender).tag;
    
    NSURL *url = [self selecedRecordedFile:index];
    
    [PlayHelper playAudioFile:url];
}

- (void) share: (id) sender {
    
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
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Please configure your mail in setting" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
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
        case 0:
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
        case 1:
        {
        
            
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
    _scores = [SoundLevelCapture sortedScoreArray];
    _reloadTableBlock();
    
}





@end
