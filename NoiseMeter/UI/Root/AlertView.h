//
//  AlertView.h
//  NoiseMeter
//
//  Created by Dave Finster on 6/03/12.
//  Copyright (c) 2012 Internetics Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertView : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource>{
    UIPickerView *_pickerView;
    UIPickerView *_alertPickerView;
    UIButton *_setButton;
    UILabel *_explanation;
}

@end
