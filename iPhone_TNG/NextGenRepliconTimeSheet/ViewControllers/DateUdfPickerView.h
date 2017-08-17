//
//  DateUdfPickerView.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 1/16/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UdfObject;
@class DateUdfPickerView;

@protocol DateUDFActionDelegate <NSObject>
@optional
- (void)dateUdfPickerChanged:(DateUdfPickerView *)dateUdfPicker withUdfObject:(UdfObject *)udfObject;
- (void)dateUdfPickerCancel:(DateUdfPickerView *)dateUdfPicker withUdfObject:(UdfObject *)udfObject;
- (void)dateUdfPickerClear:(DateUdfPickerView *)dateUdfPicker withUdfObject:(UdfObject *)udfObject;
- (void)dateUdfPickerDone:(DateUdfPickerView *)dateUdfPicker withUdfObject:(UdfObject *)udfObject;
@end

@interface DateUdfPickerView : UIView
@property (nonatomic,assign) id<DateUDFActionDelegate> dateUdfActionDelegate;
-(void)setUpDateUdfPickerViewWithUDFObject:(UdfObject *)udfObject;
@end
