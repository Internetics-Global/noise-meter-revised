//
//  AlertView.h
//  NoiseMeter
//
//  Created by Dave Finster on 6/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface AlertView : BaseViewController<UIPickerViewDelegate, UIPickerViewDataSource>{
    UIPickerView * _pickerView;
    UIButton     * _setButton;
    UILabel      * _explanation;
}

@end
