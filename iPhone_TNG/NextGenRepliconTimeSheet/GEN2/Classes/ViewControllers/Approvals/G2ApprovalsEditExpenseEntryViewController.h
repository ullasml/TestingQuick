//
//  ApprovalsEditExpenseEntryViewController.h
//  Replicon
//
//  Created by Dipta Rakshit on 2/14/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "G2ExpenseEntryCellView.h"
#import "G2Constants.h"
#import "G2ExpensesModel.h"
#import "G2CustomPickerView.h"
#import "G2AddDescriptionViewController.h"
//#import "ReceiptsViewController.h"
#import "G2RepliconServiceManager.h"
#import "FrameworkImport.h"
#import "G2AmountViewController.h"
#import "G2SupportDataModel.h"
#import "G2Util.h"

enum APPROVAL_EDIT_EXPENSE {
	APPROVAL_EDIT_EXPENSE_EXPENSE1 ,
	APPROVAL_EDIT_EXPENSE_DETAILS1
};
/*enum EDITEXPENSE_PREVIOUSNEXT {
 EDIT_EXPENSE_PREVIOUS1,
 EDIT_EXPENSE_NEXT1
 };*/
@class G2ReceiptsViewController;



@interface G2ApprovalsEditExpenseEntryViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,NetworkServiceProtocol,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIPickerViewDelegate,UIPickerViewDataSource> {
	
	NSMutableArray		*firstSectionfieldsArray;
	NSMutableArray		*secondSectionfieldsArray;
	
	NSMutableArray		*clientsArray;
	NSMutableArray		*projectsArray;
	NSMutableArray		*currenciesArray;
	//NSMutableArray		*paymentMethodsArray;
	NSMutableArray		*expenseTypeWithTaxCodesArr;
	NSArray				*permissionArray;
	NSMutableArray      *udfsArray;
	NSString			*expenseEnter;
	
	UITableView			*editExpenseEntryTable;
	//ExpensesModel		*expensesModel;
	//SupportDataModel	*supportDataModel;
	UIDatePicker		*datePicker;
	UILabel				*topToolbarLabel;
	NSString			*sheetTitle;
	NSString			*descEntry;
	//ReceiptsViewController *receiptViewController;
	
	BOOL				isProjectSelected;
	BOOL				expenseTypeSelected;
	BOOL				isPaymentSelected;
	BOOL				nonProjectSpecific;
	BOOL				projectSpecific;
	BOOL				both;
	BOOL				isBilClientSelected;
	BOOL				isReimburseSelected;
	BOOL				projectAvailToUser;
	
	NSString			*selectedProjectName;
	NSString			*selectedClientName;
	NSString			*selectedTypeName;
	NSString			*selectedDate;
	NSString			*selectedPaymentMethodName;
	
	NSInteger			selectedClientIndex;
	NSInteger           selectedProjectIndex;
	NSInteger           selectedExpenseTypeIndex;
	NSInteger           selectedPaymentMethodIndex;
	
	
	G2CustomPickerView	*pickerViewC;
	
	
	UIPickerView		*pickerView1;
	UISegmentedControl *toolbarSegmentControl;
	NSArray *dataSourceArray;
	
	NSIndexPath *selectedIndexPath;
	
	NSString *expenseSheetStatus;
	
	//AmountController Variables
	NSMutableArray *amountValuesArray;
	//NSMutableArray *baseCurrencyArray;
	NSMutableArray *ratedCalculatedValuesArray;
	NSMutableArray *defaultRateAndAmountsArray;
	
	NSString *baseCurrency;
	NSString *kilometersUnitsValue;
	NSString *amountValue;
	NSString *defaultDescription;
	NSString *b64String;
	NSUInteger totalFieldsCount;
	
	NSString *expenseSheetID;
	NSString *currencyIdentity;
	NSNumber *netAmount;
	NSMutableDictionary *editExpenseEntryDict;
	NSMutableDictionary	*expenseEntryDetailsDict;
	NSData *base64Decoded;
	NSString *base64Encoded;
	
	UITextField *numberUdfText;
	
	NSMutableArray *clientsArr;
	BOOL imageSelected;
	UIView *footerView;
	UIButton *deletButton;
	//..............................
	UIBarButtonItem  *saveButton;
	BOOL imageDeletePressed;
	
	//.....................
	enum ProjectPermissionType permissionType;
    
	//ravi
	NSIndexPath *currentIndexPath; //hack
	int deimalPlacesCount;
	NSMutableArray *taxCodesAndFormulasArray;
	
	//-----
	UIAlertView *memoryExceedAlert;
	NSTimer *imagedownloadTimer;
	
	BOOL imgDownloaded;
	BOOL memoryAlertShown;
	UIImageView *checkImageView;
	BOOL previousWasTaxExpense;
	
	BOOL typeAvailableForProject;
	
	int memoryWarnCount;
	BOOL canNotEdit;
	
	
	G2AmountViewController *amountviewController;
	
	id __weak editControllerDelegate;
	
	NSString *expenseUnitLable;
    NSInteger selectedRowForClients;
    NSString *selectedDataIdentityStr;
    NSMutableArray *fieldsArray;
    NSMutableArray *expenseUnitLabelArray;
    G2AddDescriptionViewController *addDescriptionViewController;
    G2ReceiptsViewController *receiptViewController;
    UIScrollView *mainScrollView;
    BOOL hasClient;
    int countEditExpenseUDF;
}
////////.........................
@property(nonatomic,strong)G2ReceiptsViewController *receiptViewController;
@property(nonatomic,strong)  G2AddDescriptionViewController *addDescriptionViewController;
@property(nonatomic,strong)   NSMutableArray *expenseUnitLabelArray;
@property(nonatomic,strong)  NSMutableArray *fieldsArray;
@property(nonatomic,strong) G2AmountViewController *amountviewController;
@property(nonatomic,strong) NSString *selectedDataIdentityStr;
@property(nonatomic,strong)NSArray *dataSourceArray;
@property(nonatomic,strong)UIImageView *checkImageView;
@property(nonatomic,strong)UIView *footerView;
@property(nonatomic,strong)UIPickerView		*pickerView1;
@property(nonatomic,strong)UISegmentedControl *toolbarSegmentControl;
@property(nonatomic,strong)UIDatePicker		*datePicker;
@property(nonatomic,strong)	G2CustomPickerView	*pickerViewC;
@property(nonatomic,strong)	UIBarButtonItem  *saveButton;
@property(nonatomic,strong)	NSMutableArray      *udfsArray;
@property(nonatomic,strong)	NSMutableArray		*currenciesArray;
@property(nonatomic,strong)	NSMutableArray *expenseTypeWithTaxCodesArr;
@property(nonatomic,strong)	NSString *expenseUnitLable;
@property(nonatomic,weak)	id editControllerDelegate;
@property BOOL canNotEdit;
@property BOOL imageDeletePressed;
@property(nonatomic,strong)	NSMutableArray *taxCodesAndFormulasArray;
@property(nonatomic,strong)	NSString *expenseSheetStatus;
@property(nonatomic,strong)	UITextField *numberUdfText;
@property(nonatomic,strong) UITableView *editExpenseEntryTable;
@property(nonatomic,strong)	NSMutableArray *defaultRateAndAmountsArray;
@property(nonatomic,strong)	NSMutableArray *ratedCalculatedValuesArray;
@property(nonatomic,strong)	NSString *kilometersUnitsValue;
@property(nonatomic,strong)	NSString *baseCurrency;
@property(nonatomic,strong)	NSMutableArray *amountValuesArray;
@property(nonatomic,strong) NSString *amountValue;
@property(nonatomic,strong,setter=setDescription:) NSString *defaultDescription;
@property(nonatomic,strong)	NSString *b64String;

@property(nonatomic,strong) NSMutableArray		*firstSectionfieldsArray;
@property(nonatomic,strong) NSMutableArray		*secondSectionfieldsArray;
@property(nonatomic,strong) NSString *expenseSheetID;
@property(nonatomic,strong) NSString *currencyIdentity;
@property(nonatomic,strong) UILabel	*topToolbarLabel;
@property(nonatomic,strong) NSNumber *netAmount;
@property(nonatomic,strong) NSIndexPath *selectedIndexPath;
@property(nonatomic,strong)	NSMutableDictionary *editExpenseEntryDict;
@property(nonatomic,strong)	NSMutableDictionary	*expenseEntryDetailsDict;
@property(nonatomic,strong)	NSData *base64Decoded;
@property(nonatomic,strong) NSString *base64Encoded;
@property(nonatomic,strong)	NSMutableArray *clientsArr;
@property(nonatomic,strong) UIButton *deletButton;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, assign) BOOL hasClient;

@property(nonatomic,strong) UIScrollView *mainScrollView; 
-(void)checkMarkAction:(G2ExpenseEntryCellView *)cell withEvent: (UIEvent *) event;
-(void)numericKeyPadAction:(G2ExpenseEntryCellView*)cell withEvent: (UIEvent *) event ;
- (void) buttonPressed: (G2ExpenseEntryCellView *) _cell withEvent: (UIEvent *) event;
-(void)moveToNextScreen:(G2ExpenseEntryCellView *)cell withEvent: (UIEvent *) event;
-(void)imagePicker:(G2ExpenseEntryCellView *)cell withEvent: (UIEvent *) event;
-(void)dataPickerAction:(G2ExpenseEntryCellView *)cell withEvent: (UIEvent *) event;
-(void)datePickerAction:(G2ExpenseEntryCellView *)cell withEvent: (UIEvent *) event;
-(void)showErrorAlert:(NSError *) error;
-(void)tableViewMoveToTop:(NSIndexPath*)selectedIndex;
-(void)hidePickersForKeyBoard:(UITextField*)textField;
-(void)addValuesToNumericUdfs:(UITextField*)textFields;
-(NSString*)replaceStringToCalculateAmount:(NSString*)currentString replaceWith:(NSString*)replString originalString:(NSString*)string;
-(void)setRatedUnits:(NSString*)ratedKilometerEntry;
-(NSMutableArray *)setfirstSectionFields;
-(NSMutableArray *)setSecondSectionFields;
-(void)enableExpenseFieldAtIndex:(NSIndexPath *)indexPath;
-(void)configurePicker;
- (void)pickerPrevious:(id )button;
- (void)pickerNext:(id )button;
-(void)showDatePicker;
//-(void)setCheckMarkImage:(NSString *)imgName withFieldButton:(id)fieldButton;
-(void)setCheckMarkImage:(NSString *)imgName withFieldButton: (G2ExpenseEntryCellView*)entryCell;
-(void)changeSegmentControlState:(NSIndexPath *)indexpath;
-(void)reloadDataPicker:(NSIndexPath *)indexPath;
-(void)disableExpenseFieldAtIndex:(NSIndexPath *)indexPath;
-(void)reloadDatePicker:(NSIndexPath *)indexPath;
-(void)setValuesForRatedExpenseType:(NSMutableArray *)_arrayrated;
-(void)setCurrencyId:(NSString *)_identity selectedIndex:(NSNumber *)_selectedRowIndex;
-(void)getReceiptImage;
-(NSData*)getBase64DecodedString:(NSString*)base64EncodedString;
-(void)handleEditedExpenseEntryResponse:(id)response;
-(void)handleExpenseSheetInfoResponse:(id)response;
-(void)handlePermissions;
-(void)resetTableViewUsingSelectedIndex:(NSIndexPath*)selectedIndex;
-(void)createFooterView;
-(void)handleDeleteExpenseEntryResponse:(id)response;
-(void)deleteAction:(id)sender;
-(void)confirmAlert :(NSString *)_buttonTitle confirmMessage:(NSString*) message;
-(void)setDeletedFlags;
-(void)setTotalAmountToRatedType:(NSString*)totalAmountCalculated;
-(void)hideKeyBoard;
-(void)updateNumberOfDecimalPlaces:(NSNumber*)decimalPlaces;
//...
//-(void)checkClientWithName;
-(NSNumber *)getBillClientInfo;

-(void)showUnsupportedAlertMessage;
-(void)setAmountArrayToNil;

-(void)checkClientWithName;
-(void)updateFieldsWithDefaultValues;
-(BOOL)checkAvailabilityOfTypeForSelectedProject:(NSString*)_projectId;
-(void)addTitleToNavigation;
-(void)changeAmountRowFieldType :(NSString *)expenseTypeMode;
-(void)reloadCellAtIndex:(NSIndexPath*)indexPath;
-(void)DisableCellAtIndexForCheckmark:(NSIndexPath*)indexPath;
-(void)updatePaymentMethodOnCell:(G2ExpenseEntryCellView*)entryCell;
-(void)alertViewNotToShow;
-(void)changeCurrencyFieldEnableStatus:(BOOL)disableCurrencyField;
-(NSIndexPath *)getNextEnabledFieldFromCurrentIndex:(NSIndexPath *)_currentIndexPath;
-(NSIndexPath *)getPreviousEnabledFieldFromCurrentIndex:(NSIndexPath *)_currentIndexPath;

-(void)tableCellTappedAtIndex:(NSIndexPath*)indexPath;
-(void)tableViewCellUntapped:(NSIndexPath*)indexPath;
-(G2ExpenseEntryCellView*)getCellForIndexPath:(NSIndexPath*)indexPath;
-(void)deselectRowAtIndexPath:(NSIndexPath*)indexPath;
-(void)animateCellWhichIsSelected;
-(void)handleButtonClicks:(NSIndexPath*)selectedButtonIndex;
-(void)disableSwitchWhenNoClient;
-(void)setRecieptCellEnbled;
-(BOOL)billClientShouldDisble;
-(void)switchButtonHandlings:(id)entryCellObj;
-(void)updateDependentFields:(NSIndexPath*)indexPath WithSelectedValues:(NSString *)selectedValue;
-(void)updateCurrencyFieldToBasecurrency;
-(void)highLightCellWhichIsSelected:(NSIndexPath*)indexTapped;
-(BOOL)currencyFieldHandlings;
-(void)updatePickerWhenProjectNoLongerAvailForUser;
-(BOOL)isProjectAvailableToUser;
-(void)disableAllFieldsForWaitingSheets:(G2ExpenseEntryCellView*)cellObj;
-(void)updateAmountWhenTypeUnAvailable:(BOOL)showAlert;
-(void)handleScreenBlank;
-(void)didSelectionForPickerSecondComponent:(UIPickerView *)pickerView withRow:(NSInteger)row withCell:(G2ExpenseEntryCellView *)entryCell;
-(BOOL)checkAvailabilityOfTypeForNonProject;
@end
