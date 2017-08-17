//
//  TimeSheetsUdfCell.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 1/14/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "UdfObject.h"
#import "TimesheetListObject.h"

@class TimeSheetsUdfCell;

@protocol UDFActionDelegate <NSObject>
@optional

- (void)timeSheetsUdfCellSelected:(TimeSheetsUdfCell *)timeSheetsUdfCell withUdfObject:(UdfObject *)udfObject;
- (void)timeSheetsUdfCellResigned:(TimeSheetsUdfCell *)timeSheetsUdfCell withUdfObject:(UdfObject *)udfObject;
- (void)numberUdfValueUpdatedOnCell:(TimeSheetsUdfCell *)timeSheetsUdfCell withUdfObject:(UdfObject *)udfObject;
@end

@interface TimeSheetsUdfCell : UITableViewCell<UITextFieldDelegate>

@property (nonatomic,assign) id<UDFActionDelegate> udfActionDelegate;
@property (nonatomic,strong) UITextField *numberUdfTextField;
@property (nonatomic,strong) UILabel *udfValueLabel;
-(void)createTimesheetUdfViewCellWithUdfObject:(UdfObject *)udfObject withTimesheetListObject:(TimesheetListObject *)timesheetListObject;
@end
