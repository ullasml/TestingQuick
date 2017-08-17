//
//  TimeEntryCellView.h
//  Replicon
//
//  Created by Swapna P on 4/29/11.
//  Copyright 2011 EnLume. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2Constants.h"
#import "G2Util.h"
#import "G2NumberKeypadDecimalPoint.h" 

@interface G2TimeEntryCellView : UITableViewCell<UITextFieldDelegate> {
	UILabel				*fieldName;
	UIButton			*fieldButton;
	UITextField			*textField;
	UIImageView			*folderImageView;
	G2NumberKeypadDecimalPoint *numberKeyPad;
	id					textFieldDelegate;
	id					detailsObj;	
}
-(void)newTimeEntryFields:(NSInteger)tagValue;
-(void) layoutCell: (NSInteger)tagValue withType: (NSString *) fieldType withfieldName:(NSString *) labelName
	withFieldValue: (id) fieldValue withTextColor:(UIColor *)_color;
-(void)addFieldsForTaskViewController:(int)tagValue;
-(void)clientProjectCellLayout:(NSString *)_fieldName fieldVal:(NSString *)_fieldValue withTag:(int)_tagVal;

@property (nonatomic,strong) UILabel			*fieldName;
@property (nonatomic,strong) UIButton			*fieldButton;
@property (nonatomic,strong) UITextField		*textField;
@property (nonatomic,strong) UIImageView		*folderImageView;
@property (nonatomic,strong) G2NumberKeypadDecimalPoint *numberKeyPad;
@property (nonatomic,strong) id					textFieldDelegate;
@property (nonatomic,strong) id					detailsObj;

@end
