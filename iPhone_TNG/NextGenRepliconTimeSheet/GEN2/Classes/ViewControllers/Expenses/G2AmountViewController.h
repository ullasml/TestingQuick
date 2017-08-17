//
//  AmountViewController.h
//  Replicon
//
//  Created by Manoj  on 09/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import"G2AmountCellView.h"
#import"G2Constants.h"
#import"G2CustomPickerView.h"
#import"G2CalculatorViewController.h"
#import "G2ExpensesModel.h"
#import"G2Util.h"
#import "G2SupportDataModel.h"

enum  {
	G2PREVIOUS_AMOUNT,
	G2NEXT_AMOUNT
};

enum  {
	G2CURRENCY,
	G2AMOUNT
};

@interface G2AmountViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource,UIScrollViewDelegate> {
	
	G2SupportDataModel	*supportDataModel;
    UIScrollView *scrollView;
	
	UITableView *amountTableView;
	NSMutableArray *flatWithTaxesArray;
	NSString *typeString;
	
	NSMutableArray *expenseTaxesInfoArray;
	NSMutableArray *ratedExpenseArray;
	UILabel *ratedLabel;
	UILabel *currencyLabel;
	UILabel *currencyValueLabel;
	UILabel *ratedValueLable;
	NSMutableArray *ratedLablesArray;
	
	G2CustomPickerView *pickerViewC;
	
	UIPickerView *pickerView1;
	UISegmentedControl *toolbarSegmentControl;
	
	BOOL isFromAddExpense;
    BOOL isFromEditExpense;
	
	G2ExpensesModel *expensesModel;
	NSString *currecncyString;
	UIView *footerViewAmount;
	UILabel *totalAmountLable;
	UILabel *totalAmountValue;
	
	
	NSMutableArray *fieldValuesArray;
	
	id __weak amountControllerDelegate;
	
	BOOL isCurrencySelected;
	  double rate;
	NSMutableArray *ratedValuesArray;
	NSMutableArray *defaultValuesArray;
	
	NSString *kilometerUnitValue;
	NSMutableArray *taxesLablesArray;
	NSString*ratedBaseCurrency;
	NSMutableArray *addRateAndAmountLables;
	
	BOOL inEditState;
@private
	NSInteger selectedFieldTag;
	NSArray *currenciesArray;
	UITextField *textFieldSelected;
	NSMutableArray *flatExpenseFieldsArray;
	NSString *amountValueEntered;
	UILabel *ratedTaxesLabel;
	UILabel *ratedTaxValueLable;
	NSString *buttonTitle;
	BOOL doneTapped;
	int defaultRowInPicker;
    BOOL isComplexAmountComputation;
	NSIndexPath *selectedIndexPath;
    BOOL isAmountEdit;
}
@property(nonatomic,strong)	NSMutableArray *addRateAndAmountLables;
@property(nonatomic,strong)	NSArray *currenciesArray;
@property(nonatomic,strong)	G2CustomPickerView *pickerViewC;
@property(nonatomic,strong)	UIPickerView *pickerView1;
@property(nonatomic,strong)	UISegmentedControl *toolbarSegmentControl;
@property(nonatomic,strong)	UILabel *currencyLabel;
@property(nonatomic,strong)	UILabel *currencyValueLabel;
@property(nonatomic,strong)	UILabel *ratedValueLable;
@property BOOL inEditState;
@property BOOL doneTapped;
@property  double  rate;
@property(nonatomic,strong)	NSIndexPath *selectedIndexPath;
@property(nonatomic,strong)	NSString *buttonTitle;
@property(nonatomic,strong) NSString *amountValueEntered;
@property(nonatomic,strong) UILabel *totalAmountValue,*totalAmountLable;
@property(nonatomic,strong)	NSString*ratedBaseCurrency;
@property(nonatomic,strong)	NSMutableArray *taxesLablesArray;
@property(nonatomic,strong)	NSString *kilometerUnitValue;
@property(nonatomic,strong)	NSMutableArray *defaultValuesArray;
@property(nonatomic,strong)	NSMutableArray *ratedValuesArray;
@property(nonatomic,strong) NSString *currecncyString;
@property(nonatomic,weak)	id amountControllerDelegate;
@property(nonatomic,strong)	NSMutableArray *fieldValuesArray;
@property(nonatomic,strong)	UITextField *textFieldSelected;
@property(nonatomic,strong)	NSMutableArray *ratedLablesArray;
@property(nonatomic,strong)	UILabel *ratedLabel;
@property(nonatomic,strong) NSMutableArray *ratedExpenseArray;
@property(nonatomic,strong)	NSString *typeString;
@property(nonatomic,strong) NSMutableArray *expenseTaxesInfoArray;
@property(nonatomic,strong)NSMutableArray *flatExpenseFieldsArray;
@property(nonatomic,strong)NSMutableArray *flatWithTaxesArray;
@property(nonatomic,strong)	UITableView *amountTableView;
@property(nonatomic,strong)UIScrollView *scrollView;
@property(nonatomic,assign)BOOL isComplexAmountComputation;
-(void)addRateAndAmountFields:(float)y :(int)tag;
-(void)cancelAction:(id)sender;
-(void)doneAction:(id)sender;
-(void)buttonActions:(UIButton*)sender;
-(void)addPicker;
- (void)segmentClick:(UISegmentedControl *)segmentControl;
- (void)pickerPrevious:(UIBarButtonItem *)button;
-(void)pickerNext:(UIBarButtonItem *)button;
-(void)addAmountAction;
-(void)addUsdAction;
-(void)getValueFromZCal:(NSString*)value;
-(void)updateValues:(UITextField*)textField;
-(void)userSelectedTextField:(UITextField*)textField;
-(void)showKilometersOverLay:(UITextField*)kilometerTextField;
-(void)updateRatedExpenseData:(UITextField*)kilometerTextField;
-(void)ratedTaxesLable:(int)tagValue :(float)yPosition;
-(NSString*)replaceStringToCalculateAmount:(NSString*)currentString replaceWith:(NSString*)replString originalString:(NSString*)string;
-(void)calculateTaxesForEnterdAmount:(NSString*)amountEnterd;
-(void)taxAmountEditedByUser:(UITextField*)taxTextField;
-(void)setValueToSelectedTaxField:(UITextField*)textField;
-(void)registerForKeyBoardNotifications;
- (void)showToolBarWithAnimation;
- (void)hideToolBarWithAnimation ;
-(void)setEnteredAmountValue:(NSString *)_textValue;
- (void)showToolBarWithAnimationForUsdAction;
-(NSString*)replaceStringToCalculateTaxAmounts:(NSString*)currentString replaceWith:(NSString*)replString originalString:(NSString*)string;
-(void)updateCurrencyPicker;
-(void)addCurrencyLabel:(float)y :(int)tag;
-(void)cellTappedAtIndex:(NSIndexPath*)cellIndexPath;
-(G2AmountCellView *)getCellAtIndexPath:(NSIndexPath*)cellIndexPath;
-(void)getTagFromTextFiled:(UITextField*)textFiledTapped;
-(void)highLightTheSelectedCell:(NSIndexPath*)tappedIndex;
-(void)dehilightCellWhenFocusChanged:(NSIndexPath*)indexPath;
-(void)buttonActionsHandling:(UIButton*)sender :(UIEvent*)event;
-(void)updateAmountValue;
-(void)resetTableViewUsingSelectedIndex:(NSIndexPath*)selectedIndex;
@property(nonatomic,assign)BOOL isFromAddExpense;
@property(nonatomic,assign)BOOL isFromEditExpense;
- (void)pickerDone:(UIBarButtonItem *)button;
@end
