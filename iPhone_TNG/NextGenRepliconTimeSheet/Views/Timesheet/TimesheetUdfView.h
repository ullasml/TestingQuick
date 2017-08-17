//
//  TimesheetUdfView.h
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 19/12/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NumberKeypadDecimalPoint.h"

@interface TimesheetUdfView : UIView<UITextFieldDelegate>{
    UILabel *fieldName;
    UITextField *fieldValue;
    UILabel *fieldButton;
    NSString *udfType;
    id __weak delegate;
    NSInteger totalCount;
    NumberKeypadDecimalPoint *numberKeyPad;
    NSInteger decimalPoints;
    BOOL isSelected;
}
@property (nonatomic,strong)UITextField *fieldValue;
@property (nonatomic,strong)UILabel *fieldName;
@property (nonatomic,strong)UILabel *fieldButton;
@property (nonatomic,strong)NSString *udfType;
@property (nonatomic,weak) id	delegate;
@property NSInteger totalCount;
@property (nonatomic, strong) NumberKeypadDecimalPoint *numberKeyPad;
@property(nonatomic,assign) NSInteger decimalPoints;
@property(nonatomic,assign ) BOOL isSelected;
-(void)setSelectedColor:(BOOL)selected;
@end
