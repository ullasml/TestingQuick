//
//  ShiftPickerViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Prashant Shukla on 09/09/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SupportDataModel.h"
#import "ShiftMainPageViewController.h"


@interface ShiftPickerViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSUInteger                                 dayDiff;

}


@property(nonatomic,strong) UIDatePicker                *datePicker;
@property(nonatomic,strong) SupportDataModel            *supportDataModel;
@property(nonatomic,strong) NSString                    *dayUriString;
@property(nonatomic,strong) ShiftMainPageViewController *shiftMainPageController;
@property (nonatomic,strong)NSMutableDictionary         *dateDict;

@end
