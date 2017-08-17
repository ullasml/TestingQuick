//
//  TimeOffDetailsCellView.h
//  NextGenRepliconTimeSheet
//
//  Created by Vijay M on 2/3/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NumberKeypadDecimalPoint.h"
@class TimeOffDetailsCellView;

@protocol TimeOffBalanceCalculationDelegate <NSObject>
@optional
-(void)calculateBalanceAfterHoursEntered:(NSString *)hoursTxt :(NSInteger)selectedRow;
-(void)removePickerWhileEditing;
-(void)removeDatePickerWhileEditing;
@end

@interface TimeOffDetailsCellView : UITableViewCell
@property (nonatomic,assign)BOOL isStatus;
@property (nonatomic,assign)NSInteger selectedTag;
@property (nonatomic,assign)BOOL isSameDay;
@property (nonatomic,assign)BOOL isFullDay;
@property (nonatomic,strong)UITextField *HourEntryField;
@property (nonatomic,strong)UILabel *setHourLb;
@property (nonatomic,strong)UILabel *setTimeLb;
@property (nonatomic,strong)UIButton *timeEntryButton;
@property (nonatomic,strong)UILabel *rightLb;
@property (nonatomic,strong)UIButton *fieldButton;
@property (nonatomic,strong) id rowDetailsValue;
@property (nonatomic, strong) NumberKeypadDecimalPoint *numberKeyPad;
@property (nonatomic,weak) id timeOffCellDelegate;
@property (nonatomic,weak) id <TimeOffBalanceCalculationDelegate>timeOffBalanceCalculationDelegate;
-(void)createCellLayoutWithParamsfiledname:(NSString*)upperstr fieldbutton:(NSString*)fieldstr time:(NSString*)timeStr hours:(NSString*)hourStr rowHeight:(NSInteger)rowHt;


-(instancetype) initWithFrame:(CGRect)frame  Style:(UITableViewCellStyle) uiTableViewCellStyle reuseIdentifier:(NSString *)identifier;
@end
