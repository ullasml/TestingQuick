//
//  NewExpenseSheetViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 26/03/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ExpenseEntryCustomCell.h"
#import "Util.h"
#import "FrameworkImport.h"
#import "CustomPickerView.h"
#import "ExpenseModel.h"
#import "SupportDataModel.h"
#import "RepliconServiceManager.h"
#import "LoginModel.h"

enum EXPENSESHEET_ATTRIBUTES{
	KEYBOARD,
	DATE,
	REIMBURSEMENT_CURRENCY
};


@interface NewExpenseSheetViewController : UIViewController <UITextFieldDelegate,
UIPickerViewDelegate,UIActionSheetDelegate,UITableViewDelegate,UITableViewDataSource>{

	UIPickerView				*reimbursementCurrencyPickerView;
	NSArray                     *tnewExpenseSheetVariables;
	UITextField					*descriptionTextField;
	UITableView					*date_reimbursement_tableview;
	ExpenseEntryCustomCell		*cell;
	
	UIDatePicker				*datePicker;
	UIView						*pickerBackgroundView;
	BOOL						isPickerVisible;

	UIToolbar					*keyboardToolbar;
	BOOL						keyboardToolbarShouldHide;
	UIView						*sectionHeader;
	NSMutableArray              *reimbursementCurrencyArr;
	NSString					*selectedDate;
	NSUInteger					selectedIndex;
	
	CustomPickerView			*pickerViewC;
	NSUInteger					selectedPicker;

	NSString					*selectedCurrency;
	UIBarButtonItem *saveButton;
	
	NSIndexPath *highlightedIndexPath;
	
	id __weak tnewExpenseSheetDelegate;
    
}
-(void)configurePicker;
-(void)reloadPickerDataForSelectedPicker:(NSInteger)_selectedPicker;
-(void)showDatePicker;


@property (nonatomic ,strong)	UIView						*sectionHeader;
@property (nonatomic ,strong)	UIToolbar					*keyboardToolbar;
@property (nonatomic ,strong)	UIDatePicker				*datePicker;
@property (nonatomic ,strong)	UIView						*pickerBackgroundView;

@property (nonatomic ,strong)	CustomPickerView			*pickerViewC;
@property (nonatomic ,weak)	id tnewExpenseSheetDelegate;

@property (nonatomic ,strong)	UITextField			*descriptionTextField;
@property (nonatomic ,strong)	UITableView			*date_reimbursement_tableview;
@property (nonatomic ,strong)	NSArray             *tnewExpenseSheetVariables;

@property (nonatomic ,strong)	UIBarButtonItem			*saveButton;
@property (nonatomic ,strong)	NSMutableArray      *reimbursementCurrencyArr;
@property (nonatomic ,strong)	UIPickerView		*reimbursementCurrencyPickerView;
@property (nonatomic ,strong)   NSString			*selectedDate;
@property (nonatomic ,strong)	NSString			*selectedCurrency;
@property (nonatomic ,strong)	NSIndexPath *highlightedIndexPath;
-(void)hilightTheCellTapped:(NSIndexPath*)indexPath;
-(ExpenseEntryCustomCell*)getCellForIndexPath:(NSIndexPath*)indexPath;

-(void)handleCurrencyPicker;
-(void)handleDatePicker;
-(void)showErrorAlert:(NSError *) error;
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
-(void)handleReceivedData:(NSMutableDictionary *)responseDict;
@end
