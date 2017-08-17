//
//  BookedTimeOffEntryCellView.h
//  Replicon
//
//  Created by Juhi Gautam on 29/06/12.
//  Copyright (c) 2012 Replicon Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NumberKeypadDecimalPoint.h"

@interface BookedTimeOffEntryCellView : UITableViewCell<UITextFieldDelegate>{
    UILabel *upperLefttLb;
    UIButton *fieldButton;
    UILabel *lowerLeftLb;
    UIImageView    *lineImageView;
    UISlider *timeSlider;
    UISlider *hoursSlider;
    UILabel *setTimeLb;
    UILabel *setHourLb;
    id		detailsObj;	
    UILabel *weekLb;
    UILabel *monthLb;
    UILabel *dateLb;
    NSInteger selectedTag;
    BOOL isSelected;
    id __weak delegate;
//    UILabel *hrsLb;
    UIImageView *indicatorImageView;
    BOOL hasHourPermission;
    BOOL hasOneforthPermission;
    BOOL hasHalfPermission;
    BOOL hasNonePermission;
    double shiftHours;//Implementation for US8837//JUHI
    UIView *separatorView;
    UILabel *durationBtHours;
    BOOL isStatus;
    UILabel *rightLb;
    BOOL isFirstSlide;
    BOOL hasFullPermission;
    double hackShiftHrs;
    
    UIButton *timeEntryButton;
    UITextField *HourEntryField;
    UIImageView *hourAsterikImgView;

}
@property (nonatomic,strong)UILabel *rightLb;
@property BOOL isSelected;
@property BOOL hasHourPermission;
@property BOOL hasOneforthPermission;
@property BOOL hasHalfPermission;
@property BOOL hasNonePermission;
@property BOOL hasFullPermission;
@property double shiftHours;//Implementation for US8837//JUHI
@property NSInteger selectedTag;
@property (nonatomic,strong)UILabel *upperLefttLb;
@property (nonatomic,strong)UILabel *setTimeLb;
@property (nonatomic,strong)UILabel *setHourLb;
@property (nonatomic,strong)UIButton *fieldButton;
@property (nonatomic,strong)UILabel *lowerLeftLb;
@property (nonatomic,strong)UISlider *timeSlider;
@property (nonatomic,strong)UISlider *hoursSlider;
@property (nonatomic,strong)UILabel *weekLb;
@property (nonatomic,strong)UILabel *monthLb;
@property (nonatomic,strong)UILabel *dateLb;
//@property (nonatomic,retain)UILabel *hrsLb;
@property (nonatomic,strong)UIImageView *indicatorImageView;
@property(nonatomic, strong) UIImageView    *lineImageView;
@property (nonatomic,strong) id					detailsObj;
@property (nonatomic,weak) id					delegate;
@property (nonatomic,strong) UIView *separatorView;
@property (nonatomic,strong)UILabel *durationBtHours;

@property (nonatomic,strong)UIButton *timeEntryButton;
@property (nonatomic,strong)UITextField *HourEntryField;
@property (nonatomic,strong) UIImageView *hourAsterikImgView;
@property (nonatomic, strong) NumberKeypadDecimalPoint *numberKeyPad;

@property double hackShiftHrs;//Implementation for US8837//JUHI
@property BOOL isStatus;
-(void)createCellLayoutWithParamsfiledname:(NSString*)upperstr fieldbutton:(NSString*)fieldstr time:(NSString*)timeStr hours:(NSString*)hourStr rowHeight:(NSInteger)rowHt;


@end
