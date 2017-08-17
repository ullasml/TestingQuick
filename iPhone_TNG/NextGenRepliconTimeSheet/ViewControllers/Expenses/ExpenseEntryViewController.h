#import <UIKit/UIKit.h>
#import "ExpenseEntryCustomCell.h"
#import "Constants.h"
#import "ExpenseEntryObject.h"
#import "SearchViewController.h"
#import "SelectProjectOrTaskViewController.h"
#import "AddDescriptionViewController.h"
#import "ReceiptsViewController.h"
#import "DropDownViewController.h"
#import "SpinnerDelegate.h"
#import "SelectionController.h"


@class DefaultTableViewCellStylist;
@class SearchTextFieldStylist;

enum  ExpenseEntryTableSection{
	EXPENSE_SECTION ,
	DETAILS_SECTION
};
enum RowSelected {
	INVALID_ROW = -1,
	PROJECT_ROW,
    TYPE_ROW,
	CURRENCY_ROW,
    PAYMENT_ROW
};
@interface ExpenseEntryViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,UpdateEntryFieldProtocol,UpdateEntryProjectAndTaskFieldProtocol,UIPickerViewDelegate, UIPickerViewDataSource,UIActionSheetDelegate,UIImagePickerControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UpdateDropDownFieldProtocol ,SelectionControllerDelegate>

{
    AddDescriptionViewController    *addDescriptionViewController;
    ExpenseEntryCustomCell          *cell;
    ReceiptsViewController          *receiptViewController;
    NSMutableArray          *firstSectionfieldsArray;
	NSMutableArray          *secondSectionfieldsArray;
    NSMutableArray          *dataSourceArray;
    NSMutableArray          *defaultRateAndAmountsArray;
    NSMutableArray          *ratedCalculatedValuesArray;
    NSMutableArray          *amountValuesArray;
    UITableView             *expenseEntryTableView;
    UIView                  *footerView;
    UIAlertView             *memoryExceedAlert;
    UIBarButtonItem         *saveButton;
    UIPickerView            *pickerView;
	UIDatePicker            *datePicker;
	UIToolbar               *toolbar;
	UIBarButtonItem         *doneButton;
    UIBarButtonItem         *spaceButton;
    NSIndexPath             *currentIndexPath;
    NSString                *b64String;
    NSString                *expenseSheetStatus;
    NSString                *base64Encoded;
    NSString                *kilometersUnitsValue;
    NSString                *defaultDescription;
    NSString                *amountValue;
    NSString                *baseCurrency;
    NSString                *baseCurrencyName;
    NSString                *baseCurrencyUri;
    NSData                  *base64Decoded;
    int                     rowTypeSelected;
    int                     memoryWarnCount;
    NSInteger               screenMode;
    BOOL                    imageDeletePressed;
    BOOL                    isProjectAllowed,isClientAllowed;
    BOOL                    isProjectRequired;
    BOOL                    canNotEdit;
    BOOL                    isTypeChanged;
    BOOL                    isAmountDoneClicked;
    UITextField             *lastUsedTextField;
    BOOL                    isSaveClicked;//Fix for DE15534
    id                      __weak parentDelegate;
    NSString                *receiptFileType;//Impelemnted for Pdf Receipt //JUHI
    //Implementation for US8771 HandleDateUDFEmptyValue//JUHI
    UIBarButtonItem *cancelButton;
    NSString *previousDateUdfValue;
    UIBarButtonItem *pickerClearButton;
     BOOL isDisclaimerRequired;//Implementation as per US9172//JUHI
}
@property(nonatomic,strong) NSString *receiptFileType;//Impelemnted for Pdf Receipt //JUHI
@property(nonatomic,strong) AddDescriptionViewController *addDescriptionViewController;
@property(nonatomic,strong) ReceiptsViewController *receiptViewController;
@property(nonatomic,strong) UIBarButtonItem *saveButton;
@property(nonatomic,strong) UIPickerView *pickerView;
@property(nonatomic,strong) UIDatePicker *datePicker;
@property(nonatomic,strong) UIToolbar *toolbar;
@property(nonatomic,strong) UIBarButtonItem *doneButton;
@property(nonatomic,strong) UIBarButtonItem *spaceButton;
@property(nonatomic,strong) UITableView	*expenseEntryTableView;
@property(nonatomic,strong) UIView *footerView;
@property(nonatomic,strong) NSMutableArray *firstSectionfieldsArray;
@property(nonatomic,strong) NSMutableArray *secondSectionfieldsArray;
@property(nonatomic,strong) NSMutableArray *dataSourceArray;
@property(nonatomic,strong) NSMutableArray *defaultRateAndAmountsArray;
@property(nonatomic,strong) NSMutableArray *ratedCalculatedValuesArray;
@property(nonatomic,strong) NSMutableArray *amountValuesArray;
@property(nonatomic,strong) ExpenseEntryObject *expenseEntryObject;
@property(nonatomic,strong) NSIndexPath *currentIndexPath;
@property(nonatomic,strong) NSString *expenseSheetStatus;
@property(nonatomic,strong)	NSString *b64String;
@property(nonatomic,strong) NSString *base64Encoded;
@property(nonatomic,strong) NSString *kilometersUnitsValue;
@property(nonatomic,strong) NSString *defaultDescription;
@property(nonatomic,strong) NSString *amountValue;
@property(nonatomic,strong)	NSString *baseCurrency;
@property(nonatomic,strong)	NSString *baseCurrencyName;
@property(nonatomic,strong)	NSString *baseCurrencyUri;
@property(nonatomic,strong)	NSData *base64Decoded;
@property(nonatomic,assign) int rowTypeSelected;
@property(nonatomic,assign) NSInteger screenMode;
@property(nonatomic,assign) BOOL canNotEdit;
@property(nonatomic,assign) BOOL isProjectAllowed,isClientAllowed;
@property(nonatomic,assign) BOOL isProjectRequired;
@property(nonatomic,assign) BOOL imageDeletePressed;
@property(nonatomic,assign) BOOL isTypeChanged;
@property(nonatomic,assign) BOOL isAmountDoneClicked;
@property(nonatomic,strong) UITextField	*lastUsedTextField;
@property(nonatomic,assign) BOOL isSaveClicked;//Fix for DE15534
@property(nonatomic,weak) id parentDelegate;
//Implementation for US8771 HandleDateUDFEmptyValue//JUHI
@property(nonatomic,strong) UIBarButtonItem *cancelButton;
@property(nonatomic,strong) NSString *previousDateUdfValue;
@property(nonatomic,strong) UIBarButtonItem *pickerClearButton;
@property(nonatomic,assign)BOOL isDisclaimerRequired;//Implementation as per US9172//JUHI
//Implementation For EXP-151//JUHI
@property(nonatomic,strong)NSString *reimbursementCurrencyName;
@property(nonatomic,strong)NSString *reimbursementCurrencyURI;
//MOBI-271//JUHI
@property(nonatomic,strong)NSString *previousPaymentName;
@property(nonatomic,strong)NSString *previousPaymentUri;
@property (nonatomic, weak, readonly) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic, readonly) DefaultTableViewCellStylist *defaultTableViewCellStylist;
@property (nonatomic, readonly) SearchTextFieldStylist *searchTextFieldStylist;
@property(nonatomic,readonly) BOOL canEditTask;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary  UNAVAILABLE_ATTRIBUTE;


- (instancetype)initWithDefaultTableViewCellSylist:(DefaultTableViewCellStylist *)defaultTableViewCellStylist
                            searchTextFieldStylist:(SearchTextFieldStylist *)searchTextFieldStylist
                                   spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                                         NS_DESIGNATED_INITIALIZER;


-(void)updateFieldWithClient:(NSString*)client clientUri:(NSString*)clientUri project:(NSString *)projectname projectUri:(NSString *)projectUri task:(NSString*)taskName andTaskUri:(NSString*)taskUri taskPermission:(BOOL)hasTaskPermission timeAllowedPermission:(BOOL)hasTimeAllowedPermission;
-(void)updateFieldWithFieldName:(NSString*)fieldName andFieldURI:(NSString*)fieldUri;
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
-(void)getReceiptImage;
-(NSData*)getBase64DecodedString:(NSString*)base64EncodedString;
-(void)setDeletedFlags;
-(void)setCurrencyUri:(NSString *)_currencyIdentity currencyName:(NSString *)_currencyName;
-(void)pickerDone:(id)sender;
-(void)setAmountArrayBaseCurrency:(NSMutableArray*)_amountArray withUri:(NSString *)currencyUri;
-(void)updateTypeOnPickerSelectionWithTypeName:(NSString *)typeName withTypeUri:(NSString *)typeUri;
-(void)resetTableSize:(BOOL)isResetTable;
-(void)setTotalAmountToRatedType:(NSString*)totalAmountCalculated andCurrenyName:(NSString *)currencyName;
-(void)pickerClear:(id)sender;
-(void)setUpWithExpenseEntryObject:(id)_expenseEntryObj screenMode:(NSInteger)_screenMode;
-(void)setValuesForRatedExpenseType:(NSMutableArray *)_arrayrated andCurrencyName:(NSString *)currencyName;
-(void)setDescription:(NSString *)_description;
-(void)setRatedUnits:(NSString*)ratedKilometerEntry;
-(void)showCustomPickerIfApplicable:(UITextField *)textField;
-(void)switchButtonHandlings:(NSNumber*)number onIndexpathRow:(NSNumber *)row;
@end
