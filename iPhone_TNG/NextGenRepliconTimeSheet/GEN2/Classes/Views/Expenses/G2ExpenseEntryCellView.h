//
//  ExpenseEntryCellView.h
//  Replicon
//
//  Created by Devi Malladi on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2Constants.h"
#import "G2NumberKeypadDecimalPoint.h"
#import "G2Util.h"
/**enum EXPENSESHEET_ATTRIBUTES1{
 DATE,
 REIMBURSEMENT_CURRENCY
 };**/


@interface G2ExpenseEntryCellView : UITableViewCell<UITextFieldDelegate> {
	UILabel *fieldName;
	UIButton *fieldButton;
	UITextField *fieldText;
	UITextField *amountTextField;
	id __weak  expenseEntryCellDelegate;
	
	NSIndexPath *indexPath;
	G2NumberKeypadDecimalPoint *numberKeyPad;
	NSMutableDictionary *dataObj;
	int decimalPlaces;
	
	UISwitch *switchMark;
}
-(void)addFieldsForNewExpenseSheet:(float)width height:(float)_height;
-(void)addTextFieldsForTextUdfsAtIndexRow:(NSInteger)tagIndexText;
-(void)addTextFieldsForAmountAtIndexRow:(int)tagIndexText;

@property(nonatomic,strong)	UISwitch *switchMark;
@property(nonatomic,weak)	id expenseEntryCellDelegate;
@property(nonatomic,strong)	UITextField *fieldText;
@property(nonatomic,strong)	UITextField *amountTextField;
@property(nonatomic,strong)UILabel *fieldName;
@property(nonatomic,strong)UIButton *fieldButton;
//-(void)addFieldAtIndex:(int)ind atSection:(int)sec;
@property (nonatomic, strong) G2NumberKeypadDecimalPoint *numberKeyPad;
-(void) addFieldAtIndex: (NSIndexPath *) _indexPath withTagIndex: (NSInteger)_tagIndex withObj: (NSMutableDictionary *)_dataObj;

@property (nonatomic) NSInteger tagIndex;
@property (nonatomic) int decimalPlaces;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSMutableDictionary *dataObj;

-(void)switchChanged:(UISwitch*)sender;
-(void) setCellViewState: (BOOL)isSelected;
-(void)grayedOutRequiredCell;
-(void)enableRequiredCell;

@end
