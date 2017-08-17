//
//  DailyWidgetCutomCell.h
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 1/7/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "NumberKeypadDecimalPoint.h"
@interface DailyWidgetCutomCell : UITableViewCell<UITextFieldDelegate>
@property(nonatomic,weak)id delegate;
@property(nonatomic,strong)UIImageView *disclosureImageView;
@property (nonatomic,strong) NumberKeypadDecimalPoint *numberKeyPad;;

-(void)createCellLayoutWidgetTitle:(NSString *)title andDescription:(NSString *)description andTitleTextHeight:(float)titleHeight anddescriptionTextHeight:(float)descriptionHeight isNumericFieldType:(BOOL)isNumeric andSelectedRow:(NSInteger)row;
@end
