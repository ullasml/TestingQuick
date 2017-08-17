//
//  AddNewExpenseViewController.h
//  Replicon
//
//  Created by Devi Malladi on 3/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "G2ExpenseEntryCellView.h"
#import "G2Constants.h"

#import "G2CustomPickerView.h"
#import "G2AddDescriptionViewController.h"
#import "G2RepliconServiceManager.h"
#import "FrameworkImport.h"
#import "G2AmountViewController.h"
#import "G2DataListViewController.h"

#import"G2Util.h"

@class G2ReceiptsViewController;

enum  G2ExpenseEntryTableSection{
	G2EXPENSE_SECTION ,
	G2DETAILS_SECTION
};
/*enum  {
 PREVIOUS1,
 NEXT1
 };*/


@interface G2AddNewExpenseViewController : UIViewController<UINavigationControllerDelegate,UITableViewDelegate,NetworkServiceProtocol,UITableViewDataSource,UIImagePickerControllerDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UIActionSheetDelegate,G2ServerResponseProtocol,UINavigationControllerDelegate> {
	NSMutableArray		*firstSectionfieldsArray;
	NSMutableArray		*secondSectionfieldsArray;
	NSMutableArray *totalCalucatedAmountArray;
	NSMutableArray		*clientsArray;
	NSMutableArray		*projectsArray;
	//NSMutableArray      *udfsArray;
	UITableView			*tnewExpenseEntryTable;
	UIDatePicker		*datePicker;
	
	enum ProjectPermissionType		permissionType;	
	
	G2CustomPickerView	*pickerViewC;
	NSMutableString *b64String;
	
	UIPickerView		*pickerView1;
	UISegmentedControl *toolbarSegmentControl;
	NSArray *dataSourceArray;
	NSMutableArray		*rateAndAmountsArray;
	NSString *baseCurrency;
	NSString *totalCalucatedAmount;
	//ravi
	NSIndexPath *currentIndexPath; //hack
	int deimalPlacesCount;
	
	BOOL previousWasTaxExpense;
	BOOL typeAvailableForProject;
    BOOL isComplexAmountCalucationScenario;
	NSString *expesneSheetStatus;
	BOOL isDataPickerChosen;//DE5011 ullas
	BOOL isEntriesAvailable;
	G2AmountViewController *amountviewController;
	NSMutableArray *ratedValuesArray;
	id __weak tnewEntryDelegate;
	NSString *expenseSheetID;
	BOOL taxExpenseChnged;
    NSInteger selectedRowForClients;
    G2ExpensesModel *expensesModel;
    G2SupportDataModel *supportDataModel;
	G2ReceiptsViewController *receiptViewController;
 UIScrollView *mainScrollView; 
    BOOL hasClient;
    int tmpSelectedClientIndex;//DE4850 ullas
    BOOL boolIsProjSelForFirstTime;//DE4850 ullas
    double rate;
    BOOL clientAndProjectBothPresentFromPrevious;
    NSInteger udfStartIndex;//DE8142
    BOOL fromReloaOfDataView;
    G2DataListViewController *dataListViewCtrl;
}

@property(nonatomic,strong)G2DataListViewController *dataListViewCtrl;
@property(nonatomic,strong)G2ReceiptsViewController *receiptViewController;
@property(nonatomic,strong)G2SupportDataModel *supportDataModel;
@property(nonatomic,strong)G2ExpensesModel *expensesModel;
@property BOOL taxExpenseChnged;
@property(nonatomic,strong)	UISegmentedControl *toolbarSegmentControl;
@property(nonatomic,strong)	G2CustomPickerView	*pickerViewC;
@property(nonatomic,strong)	UIDatePicker		*datePicker;
@property(nonatomic,strong) UIPickerView		*pickerView1;
@property(nonatomic,weak)	id tnewEntryDelegate;
@property	BOOL isEntriesAvailable,isComplexAmountCalucationScenario;
@property(nonatomic,strong)	NSString *expesneSheetStatus;
@property(nonatomic,strong) UITableView *tnewExpenseEntryTable;
@property(nonatomic,assign) BOOL isDataPickerChosen;
@property(nonatomic,strong)	NSMutableArray *defaultRateAndAmountsArray;
@property(nonatomic,strong)	NSMutableArray *ratedCalculatedValuesArray;
@property(nonatomic,strong)	NSString *kilometersUnitsValue;
@property(nonatomic,strong)	NSString *baseCurrency;
@property(nonatomic,strong)	NSMutableArray *amountValuesArray;
@property(nonatomic,strong) NSString *amountValue;
@property(nonatomic,strong,setter=setDescription:) NSString *defaultDescription;
@property(nonatomic,strong)	NSMutableString *b64String;
@property(nonatomic,strong) NSMutableArray		*firstSectionfieldsArray;
@property(nonatomic,strong) NSMutableArray		*ratedValuesArray;
@property(nonatomic,strong) NSMutableArray		*secondSectionfieldsArray;
@property(nonatomic,strong)NSMutableArray		*rateAndAmountsArray;
@property(nonatomic,strong) NSString *expenseSheetID;
@property(nonatomic,strong) NSString *currencyIdentity;
@property(nonatomic,strong)NSMutableArray		*totalCalucatedAmountArray;
@property(nonatomic,strong) NSNumber *netAmount;
@property(nonatomic,strong) NSIndexPath *selectedIndexPath;
@property(nonatomic,strong)	UITextField *numberUdfText;
@property(nonatomic,strong) UIScrollView *mainScrollView;
@property (nonatomic, assign) BOOL fromReloaOfDataView;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, assign) BOOL hasClient;
@property  double  rate;
-(void)tableViewMoveToTop:(NSIndexPath*)selectedIndex;

-(void)checkMarkAction:(G2ExpenseEntryCellView *)cell withEvent: (UIEvent *) event;
-(void)numericKeyPadAction:(G2ExpenseEntryCellView*)cell withEvent: (UIEvent *) event ;
-(NSString*)replaceStringToCalculateAmount:(NSString*)currentString replaceWith:(NSString*)replString originalString:(NSString*)string;
-(NSMutableArray *)getfirstSectionFields;
-(NSMutableArray *)getSecondSectionFields;
-(void)enableExpenseFieldAtIndex:(NSIndexPath *)indexPath;
-(void)configurePicker;
- (void)pickerPrevious:(id )button;
- (void)pickerNext:(id )button;
-(void)showDatePicker;
-(void)setCheckMarkImage:(NSString *)imgName withFieldButton: (G2ExpenseEntryCellView*)entryCell;
-(void)changeSegmentControlState:(NSIndexPath *)indexpath;
-(void)reloadDataPicker:(NSIndexPath *)indexPath;
-(void)disableExpenseFieldAtIndex:(NSIndexPath *)indexPath;
-(void)reloadDatePicker:(NSIndexPath *)indexPath;
-(void)setValuesForRatedExpenseType:(NSMutableArray *)_arrayrated;
-(void)setCurrencyId:(NSString *)_identity selectedIndex:(NSNumber *)_selectedRowIndex;
-(void)addValuesToNumericUdfs:(UITextField*)textFields;
-(void)handlePermissions;
- (void)showToolBarWithAnimation;
- (void)hideToolBarWithAnimation;
-(void) keyboardWillShow:(NSNotification *)note;
-(void) keyboardWillHide:(NSNotification *)note;
-(void)registerForKeyBoardNotifications;
-(void)hidePickersForKeyBoard:(UITextField*)textField;
-(void)resetTableViewUsingSelectedIndex:(NSIndexPath*)selectedIndex;
-(void)viewWillDisappear:(BOOL)animated;
-(void)setRatedUnits:(NSString*)ratedKilometerEntry;

- (void) buttonPressed: (G2ExpenseEntryCellView *) _cell withEvent: (UIEvent *) event;
-(void)handleButtonClicks:(NSIndexPath*)selectedButtonIndex;

//.......................
-(void)moveToNextScreen:(G2ExpenseEntryCellView *)cell withEvent: (UIEvent *) event;
-(void)imagePicker:(G2ExpenseEntryCellView *)cell withEvent: (UIEvent *) event;
-(void)setTotalAmountToRatedType:(NSString*)totalAmountCalculated;

//Picker Actions
-(void)dataPickerAction:(G2ExpenseEntryCellView *)_cell withEvent: (UIEvent *) event forRowIndex: (NSIndexPath *) rowIndex;
-(void)datePickerAction:(G2ExpenseEntryCellView *)cell withEvent: (UIEvent *) event;

-(void)hideKeyBoard;
-(void)moveTableToTop:(int)y;
- (void)scrollTableView:(UITableView *)tableView toIndexPath:(NSIndexPath *)indexPath withBottomPadding:(CGFloat)bottomPadding;
-(void)updateNumberOfDecimalPlaces:(NSNumber*)decimalPlaces;
-(void)showErrorAlert:(NSError *) error;
///-----------------
-(NSNumber *)getBillClientInfo;
-(void)checkClientWithName;
//-(void)showMemoryAlert;
-(void)setAmountArrayToNil;
-(void)updateFieldsWithDefaultValues;
-(BOOL)checkAvailabilityOfTypeForSelectedProject:(NSString*)_projectId;
-(void)changeAmountRowFieldType :(NSString *)expenseTypeMode;
//DE2705//Juhi
//-(void)reloadCellAtIndex:(NSIndexPath*)indexPath;
-(void)reloadCellAtIndex:(NSIndexPath*)indexPath andRow:(NSInteger)row;
-(void)DisableCellAtIndexForCheckmark:(NSIndexPath*)indexPath;
-(void)updatePaymentMethodOnCell:(G2ExpenseEntryCellView*)entryCell;
-(void)switchButtonHandlings:(id)entryCellObj;
-(void)changeCurrencyFieldEnableStatus:(BOOL)disableCurrencyField;
-(NSIndexPath *)getNextEnabledFieldFromCurrentIndex:(NSIndexPath *)_currentIndexPath;
-(NSIndexPath *)getPreviousEnabledFieldFromCurrentIndex:(NSIndexPath *)_currentIndexPath;
-(void)setDeletedFlags;

-(void)tableCellTappedAtIndex:(NSIndexPath*)indexPath;
-(void)tableViewCellUntapped:(NSIndexPath*)indexPath;
-(G2ExpenseEntryCellView*)getCellForIndexPath:(NSIndexPath*)indexPath;
-(void)deselectRowAtIndexPath:(NSIndexPath*)indexPath;
-(void)animateCellWhichIsSelected;
-(void)amountFiledHandlings:(id)amountCell;
-(void)updateDependentFields:(NSIndexPath*)indexPath WithSelectedValues:(NSString *)selectedValue;
-(void)updateCurrencyFieldToBasecurrency;
- (id) initWithTitle: (NSString *)titleText sheetID:_sheetIdentity;
-(void)highLightCellWhichIsSelected:(NSIndexPath*)indexTapped;
-(void)typeFiledHandlings:(id)typeCell;
- (void)pickerDone:(UIBarButtonItem *)button;
-(void)cancelAction:(id)sender;
-(void)updateRatedExpenseData:(NSString *)kilometerString;
-(void)updateAmountWhenTypeUnAvailable:(BOOL)showAlert;
-(void)showAllClients;
-(void)showAllProjectswithMoreButton:(BOOL)isShowMoreButton;
-(void)didSelectionRowFromDataListSecond:(NSInteger)row;
- (void)didSelectRowFromDataList:(NSInteger)row inComponent:(NSInteger)componentIndex;
-(NSMutableArray *)genarateProjectsListForDtaListView;
-(void)expensesFinishedDownloadingProjects: (id)notificationObject;
-(void)updateTypePickerOn_Client_ProjectChange;
@end
