//
//  AmountViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 01/04/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NumberKeypadDecimalPoint.h"

@interface AmountViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,UIPickerViewDelegate, UIPickerViewDataSource,UIScrollViewDelegate,UITextFieldDelegate>
{
    UIScrollView *scrollView;
    UIView *footerViewAmount;
    UIPickerView *pickerView;
    UIToolbar        *toolbar;
	UIBarButtonItem  *doneButton;
    UIBarButtonItem  *spaceButton;
    UITextField *textFieldSelected;
    UITableView *amountTableView;
    UILabel *currencyLabel;
    UIButton *currencyTappedButton;
    UILabel *currencyValueLabel;
    UILabel *ratedLabel;
    UILabel *ratedValueLable;
    UILabel *ratedTaxesLabel;
	UILabel *ratedTaxValueLable;
    UILabel *totalAmountLabel;
	UILabel *totalAmountValue;

    NSMutableArray *flatExpenseFieldsArray;
    NSMutableArray *ratedLablesArray;
    NSMutableArray *expenseTaxesInfoArray;
    NSMutableArray *fieldValuesArray;
    NSMutableArray *ratedExpenseArray;
    NSMutableArray *defaultValuesArray;
    NSMutableArray *addRateAndAmountLables;
    NSMutableArray *taxesLablesArray;
    NSMutableArray *ratedValuesArray;
    NSMutableArray *pickerDataSourceArray;

    NSString *kilometerUnitValue;
    NSString *buttonTitle;
    NSString *expenseType;
    NSString *ratedBaseCurrency;
    NSString *selectedCurrencyUri;
    NSString *amountValueEntered;
    NSIndexPath *selectedIndexPath;
    BOOL inEditState;
    BOOL isAmountEdit;
    double rate;
    NSInteger selectedFieldTag;
    NSInteger totalRows;
    CGFloat tableHeight;
    CGFloat scrollHeight;
    BOOL canNotEdit;
    id __weak amountControllerDelegate;
}

@property(nonatomic,strong) UIScrollView *scrollView;
@property(nonatomic,strong) UIPickerView *pickerView;
@property(nonatomic,strong) UIToolbar       *toolbar;
@property(nonatomic,strong) UIBarButtonItem *doneButton;
@property(nonatomic,strong) UIBarButtonItem *spaceButton;
@property(nonatomic,strong) UITableView *amountTableView;
@property(nonatomic,strong) UIView *footerViewAmount;
@property(nonatomic,strong)	UITextField *textFieldSelected;
@property(nonatomic,strong) UILabel *currencyLabel;
@property(nonatomic,strong) UIButton *currencyTappedButton;
@property(nonatomic,strong) UILabel *currencyValueLabel;
@property(nonatomic,strong) UIButton *rateTappedButton;
@property(nonatomic,strong) UILabel *ratedLabel;
@property(nonatomic,strong) UILabel *ratedValueLable;
@property(nonatomic,strong) UILabel *ratedTaxesLabel;
@property(nonatomic,strong) UILabel *ratedTaxValueLable;
@property(nonatomic,strong) UILabel *totalAmountLabel;
@property(nonatomic,strong) UILabel *totalAmountValue;
@property(nonatomic,strong) NSMutableArray *flatExpenseFieldsArray;
@property(nonatomic,strong) NSMutableArray *ratedLablesArray;
@property(nonatomic,strong) NSMutableArray *expenseTaxesInfoArray;
@property(nonatomic,strong) NSMutableArray *fieldValuesArray;
@property(nonatomic,strong) NSMutableArray *ratedExpenseArray;
@property(nonatomic,strong) NSMutableArray *defaultValuesArray;
@property(nonatomic,strong) NSMutableArray *addRateAndAmountLables;
@property(nonatomic,strong) NSMutableArray *taxesLablesArray;
@property(nonatomic,strong) NSMutableArray *ratedValuesArray;
@property(nonatomic,strong) NSMutableArray *pickerDataSourceArray;
@property(nonatomic,strong) NSString *kilometerUnitValue;
@property(nonatomic,strong)	NSString *buttonTitle;
@property(nonatomic,strong) NSString *ratedBaseCurrency;
@property(nonatomic,strong) NSString *selectedCurrencyUri;
@property(nonatomic,strong) NSString *expenseType;
@property(nonatomic,strong) NSString *amountValueEntered;
@property(nonatomic,strong)	NSIndexPath *selectedIndexPath;
@property(nonatomic,assign) double rate;
@property(nonatomic,assign) BOOL isAmountEdit;
@property(nonatomic,assign) BOOL inEditState;
@property(nonatomic,weak) id amountControllerDelegate;
@property(nonatomic,assign) BOOL canNotEdit;
@property(nonatomic,strong) NSString *expenseStatus;
@property (nonatomic,strong) NumberKeypadDecimalPoint *numberKeyPad;

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
-(void)pickerDone:(UIBarButtonItem *)button;
-(void)highLightCurrencyTappedRow;
-(void)dehighLightCurrencyTappedRow;
-(void)highLightRateTappedRow;
-(void)dehighLightRateTappedRow;

-(void)calculateTaxesForEnterdAmount:(NSString*)amountEnterd;
-(void)setEnteredAmountValue:(NSString *)_textValue;
-(void)updateValues:(UITextField*)textField;
-(void)updateRatedExpenseData:(UITextField*)kilometerTextField;
-(void)taxAmountEditedByUser:(UITextField*)taxTextField;
-(void)userSelectedTextField:(UITextField*)textField;
-(void)showKilometersOverLay:(UITextField*)kilometerTextField;
-(void)getTagFromTextFiled:(UITextField*)textFiledTapped;
-(void)buttonActionsHandling:(UIButton*)sender :(UIEvent*)event;
@end
