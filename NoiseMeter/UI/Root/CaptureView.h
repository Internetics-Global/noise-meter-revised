//
//  CaptureView.h
//  NoiseMeter
//
//  Created by Dave Finster on 13/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface CaptureView : BaseViewController<UITextFieldDelegate>{
    UIImageView *_meterBackground;
    UILabel *_currentReadingLabel;
    UIImageView *_formBackground;
    UILabel *_enterLabel;
    UITextField *_nameField;
    UIButton *_saveButton;
    NSNumber *_reading;
}

- (id)initWithReading:(NSNumber *)reading;

@end
