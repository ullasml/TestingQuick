//
//  InOutEntryDetailsCustomCell.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 28/11/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NumberKeypadDecimalPoint.h"

@interface InOutEntryDetailsCustomCell : UITableViewCell<UITextFieldDelegate>
{
   
}

@property (nonatomic,strong)UITextField *fieldValue;
@property (nonatomic,strong)UILabel *fieldName;
@property (nonatomic,strong)UILabel *fieldButton;
@property (nonatomic,strong)NSString *udfType;
@property (nonatomic,strong) id	delegate;
@property (nonatomic,strong) NumberKeypadDecimalPoint *numberKeyPad;
@property (nonatomic,assign) NSInteger decimalPoints;
@property NSInteger totalCount;
@property (nonatomic,assign)BOOL isNonEditable;

-(void)createCellLayoutWithParamsWithFieldName:(NSString *)fieldNameStr withFieldValue:(NSString *)fieldValueStr isEditState:(BOOL)isEditState;
@end
