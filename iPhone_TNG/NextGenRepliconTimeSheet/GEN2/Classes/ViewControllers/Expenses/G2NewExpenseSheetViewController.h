//
//  NewExpenseSheetViewController.h
//  Replicon
//
//  Created by Swapna P on 4/1/11.
//  Copyright 2011 EnLume. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2ExpenseEntryCellView.h"
#import "G2Util.h"
#import "FrameworkImport.h"
#import "G2CustomPickerView.h"
#import "G2ExpensesModel.h"
#import "G2SupportDataModel.h"
#import "G2RepliconServiceManager.h"
enum EXPENSESHEET_PREVIOUSNEXT  {
	SHEET_PREVIOUS,
	SHEET_NEXT
};
//enum EXPENSESHEET_ATTRIBUTES{
//	KEYBOARD,
//	DATE,
//	REIMBURSEMENT_CURRENCY
//};


@interface G2NewExpenseSheetViewController : UIViewController <UITextFieldDelegate,
UIPickerViewDelegate,UIActionSheetDelegate,UITableViewDelegate,UITableViewDataSource>{
	UILabel						*descriptionLabel;
	UIPickerView				*reimbursementCurrencyPickerView;
	NSArray                     *tnewExpenseSheetVariables;
	UITextField					*descriptionTextField;
	UITableView					*date_reimbursement_tableview;
	G2ExpenseEntryCellView		*cell;
	NSMutableDictionary			*expenseDetailsDict;
	UIDatePicker				*datePicker;
	UIView						*pickerBackgroundView;
	BOOL						isPickerVisible;
	UISegmentedControl			*nextPreviousControl;
	UIToolbar					*keyboardToolbar;
	BOOL						keyboardToolbarShouldHide;
	UIView						*sectionHeader;
	NSMutableArray              *reimbursementCurrencyArr;
	NSString					*selectedDate;
	NSUInteger					selectedIndex;
	UISegmentedControl			*toolbarSegmentControl;
	G2CustomPickerView			*pickerViewC;
	NSUInteger					selectedPicker;
	G2ExpensesModel				*expensesModel;
	G2SupportDataModel			*supportDataModel;
	NSString					*selectedCurrency;
	UIBarButtonItem *saveButton;
	
	NSIndexPath *highlightedIndexPath;
	
	id __weak tnewExpenseSheetDelegate;

}
-(void)configurePicker;
-(void)reloadPickerDataForSelectedPicker:(NSInteger)_selectedPicker;
-(void)moveTableToTop:(float)y;
-(void)showDatePicker;
-(void)pickerPrevious:(UIBarButtonItem *)button;
-(void)pickerNext:(UIBarButtonItem *)button;

@property (nonatomic ,strong)	UIView						*sectionHeader;
@property (nonatomic ,strong)	UIToolbar					*keyboardToolbar;
@property (nonatomic ,strong)	UIDatePicker				*datePicker;
@property (nonatomic ,strong)	UIView						*pickerBackgroundView;
@property (nonatomic ,strong)	UISegmentedControl			*toolbarSegmentControl;
@property (nonatomic ,strong)	G2CustomPickerView			*pickerViewC;
@property (nonatomic ,weak)	id tnewExpenseSheetDelegate;
@property (nonatomic ,strong)	UILabel				*descriptionLabel;
@property (nonatomic ,strong)	UITextField			*descriptionTextField;
@property (nonatomic ,strong)	UITableView			*date_reimbursement_tableview;
@property (nonatomic ,strong)	NSArray             *tnewExpenseSheetVariables;
@property (nonatomic ,strong)	UISegmentedControl	*nextPreviousControl;
@property (nonatomic ,strong)	UIBarButtonItem			*saveButton;
@property (nonatomic ,strong)	NSMutableArray      *reimbursementCurrencyArr;
@property (nonatomic ,strong)	UIPickerView		*reimbursementCurrencyPickerView;
@property (nonatomic ,strong)   NSString			*selectedDate;
@property (nonatomic ,strong)	NSString			*selectedCurrency;
@property (nonatomic ,strong)	NSIndexPath *highlightedIndexPath;
-(void)hilightTheCellTapped:(NSIndexPath*)indexPath;
-(G2ExpenseEntryCellView*)getCellForIndexPath:(NSIndexPath*)indexPath;
-(void)deHeighLightTheCellTapped:(NSIndexPath*)indexPath;
-(void)handleCurrencyPicker;
-(void)handleDatePicker;
-(void)showErrorAlert:(NSError *) error;
@end
