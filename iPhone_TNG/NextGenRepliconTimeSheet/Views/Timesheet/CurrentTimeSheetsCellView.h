//
//  CurrentTimeSheetsCellView.h
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 18/12/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NumberKeypadDecimalPoint.h"
@interface CurrentTimeSheetsCellView : UITableViewCell<UITextFieldDelegate>{
    UILabel *leftLb;
    UILabel *rightLb;
    id __weak delegate;
    UIImageView     *disclosureImageView;
    UIImageView     *commentsImageView;
    UIActivityIndicatorView *activityView;
    id detailObj;
    NSString *fieldType;
    UITextField *fieldValue;
    NumberKeypadDecimalPoint *numberKeyPad;
    NSInteger decimalPoints;
    int rowHeight;
}
@property (nonatomic,strong)UILabel *leftLb;
@property (nonatomic,strong)UILabel *rightLb;
@property (nonatomic,weak)id delegate;
@property(nonatomic, strong)UIImageView  *disclosureImageView;
@property(nonatomic, strong)UIImageView  *commentsImageView;
@property (nonatomic,strong)UIActivityIndicatorView *activityView;
@property(nonatomic,strong)id detailObj;
@property(nonatomic,strong)NSString *fieldType;
@property (nonatomic,strong)UITextField *fieldValue;
@property (nonatomic, strong) NumberKeypadDecimalPoint *numberKeyPad;
@property(nonatomic,assign) NSInteger decimalPoints;
@property(nonatomic,assign) int rowHeight;

- (void)createCellWithLeftString:(NSString *)leftstr
              andLeftStringColor:(UIColor *)leftColor
                  andRightString:(NSString *)rightStr
             andRightStringColor:(UIColor *)rightColor
                     hasComments:(BOOL)hasComments
                      hasTimeoff:(BOOL)hasTimeoff
                         withTag:(NSInteger)tag;
-(void)createCellWithClientValue:(NSString *)clientValue  andProjectValue:(NSString *)projectValue andTaskValue:(NSString *)taskValue andHasClientAccess:(BOOL)hasClientAccess andHasProgramAccess:(BOOL)hasProgramAccess withTag:(NSInteger)tag;
@end
