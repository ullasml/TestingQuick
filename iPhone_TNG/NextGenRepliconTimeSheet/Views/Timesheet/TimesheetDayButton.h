//
//  TimesheetDayButton.h
//  InOutTest
//
//  Created by Abhishek Nimbalkar on 5/13/13.
//  Copyright (c) 2013 Aby Nimbalkar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimesheetDayButton : UIButton

{
    NSInteger _date;
    NSString* _dayName;
    UILabel* _dayNameTxt;
    int _btnTag;
    id __weak _entryDelegate;
    BOOL _dayOff;
    BOOL _dayFilled;
}

@property (nonatomic, assign) BOOL _dayOff;
@property (nonatomic, strong) NSString* _dayName;
@property (nonatomic, strong) UILabel* _dayNameTxt;
@property (nonatomic, assign) int _btnTag;
@property (nonatomic, weak) id _entryDelegate;
@property (nonatomic, assign) BOOL _dayFilled;


- (id)initWithDate:(NSInteger)date andDay:(NSString*)dayName dayOff:(BOOL)dayIsOff isTimesheetDayFilled:(BOOL)timesheetDayFilled  frame:(CGRect )frame withTag:(int)tag withDelegate:(id)delegate;
- (void)highlightButton:(BOOL)highlight forButton:(UIButton *)btn;
- (void)markAsDayOff:(BOOL)isDayOff;
@end

@protocol TimesheetDayButtonClickProtocol;
@protocol TimesheetDayButtonClickProtocol <NSObject>
-(void)timesheetDayBtnClicked:(id)sender isManualClick:(BOOL)isManualBtnClick;
@end
