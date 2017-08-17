#import "ExpenseEntryViewController.h"
#import "AppDelegate.h"
#import "Util.h"
#import "AmountViewController.h"
#import "LoginModel.h"
#import "DropDownViewController.h"
#import "ListOfExpenseEntriesViewController.h"
#import "ApprovalsScrollViewController.h"
#import "TimeEntryViewController.h"
#import "CommonSearchViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MacTypes.h>
#import "TimesheetNavigationController.h"
#import "ExpensesNavigationController.h"
#import "BookedTimeOffNavigationController.h"
#import "AttendanceNavigationController.h"
#import "PunchHistoryNavigationController.h"
#import "ShiftsNavigationController.h"
#import "ApprovalsNavigationController.h"
#import "TeamTimeNavigationController.h"
#import "RepliconServiceProvider.h"
#import "DefaultTableViewCellStylist.h"
#import "SearchTextFieldStylist.h"
#import <repliconkit/ReachabilityMonitor.h>
#import "SupervisorDashboardNavigationController.h"
#import <Blindside/BSInjector.h>
#import "SelectionController.h"
#import "ExpenseClientProjectTaskRepository.h"
#import "PunchCardObject.h"
#import "UIView+Additions.h"
#import "InjectorKeys.h"
#import "RepliconAppDelegate.h"

#define FIRSTSECTION_TAG_INDEX 6000
#define SECONDSECTION_TAG_INDEX 6050
#define Each_Cell_Row_Height_44 44
#define Button_space 30
#define PICKER_ROW_HEIGHT 40
#define Toolbar_Height 45
#define Picker_Height 216
#define RECEIPT_TAG_INDEX 300
#define Image_Alert_tag 100
#define Image_Alert_Unsupported 5000
#define DELETE_EXPENSEENTRY_ALERT_TAG 9999
#define PICKER_VIEW_TAG_EXPENSE_VIEW 777
#define spaceForOffSet 358


@interface ExpenseEntryViewController ()

@property (nonatomic) DefaultTableViewCellStylist *defaultTableViewCellStylist;

@property (nonatomic) SearchTextFieldStylist *searchTextFieldStylist;
@property (nonatomic) id <SpinnerDelegate> spinnerDelegate;
@property (weak, nonatomic) id<BSInjector> injector;
@property(nonatomic,assign) BOOL canEditTask;
@end


@implementation ExpenseEntryViewController
@synthesize firstSectionfieldsArray;
@synthesize secondSectionfieldsArray;
@synthesize defaultRateAndAmountsArray;
@synthesize ratedCalculatedValuesArray;
@synthesize screenMode;
@synthesize expenseEntryTableView;
@synthesize footerView;
@synthesize canNotEdit;
@synthesize expenseSheetStatus;
@synthesize expenseEntryObject;
@synthesize currentIndexPath;
@synthesize saveButton;
@synthesize isProjectAllowed,isClientAllowed;
@synthesize pickerView;
@synthesize datePicker;
@synthesize toolbar;
@synthesize doneButton;
@synthesize spaceButton;
@synthesize dataSourceArray;
@synthesize rowTypeSelected;
@synthesize addDescriptionViewController;
@synthesize b64String;
@synthesize base64Encoded;
@synthesize base64Decoded;
@synthesize kilometersUnitsValue;
@synthesize imageDeletePressed;
@synthesize receiptViewController;
@synthesize amountValue;
@synthesize defaultDescription;
@synthesize baseCurrency;
@synthesize amountValuesArray;
@synthesize isTypeChanged;
@synthesize isProjectRequired;
@synthesize isAmountDoneClicked;
@synthesize lastUsedTextField;
@synthesize baseCurrencyName;
@synthesize baseCurrencyUri;
@synthesize isSaveClicked;
@synthesize parentDelegate;
@synthesize receiptFileType;
@synthesize cancelButton;
@synthesize previousDateUdfValue;
@synthesize pickerClearButton;
@synthesize isDisclaimerRequired;//Implementation as per US9172//JUHI
//Implementation For EXP-151//JUHI
@synthesize reimbursementCurrencyName;
@synthesize reimbursementCurrencyURI;
//MOBi-271//JUHI
@synthesize previousPaymentName;
@synthesize previousPaymentUri;

- (instancetype)initWithDefaultTableViewCellSylist:(DefaultTableViewCellStylist *)defaultTableViewCellStylist
                            searchTextFieldStylist:(SearchTextFieldStylist *)searchTextFieldStylist
                                   spinnerDelegate:(id<SpinnerDelegate>)spinnerDelegate
{
    self = [super initWithNibName:nil bundle:nil];
	if (self)
    {
        self.defaultTableViewCellStylist = defaultTableViewCellStylist;
        self.spinnerDelegate = spinnerDelegate;
        self.searchTextFieldStylist = searchTextFieldStylist;
    }

	return self;
}

#pragma mark -
#pragma mark View lifeCycle Methods

-(void)setUpWithExpenseEntryObject:(id)_expenseEntryObj screenMode:(NSInteger)_screenMode
{
    self.screenMode=_screenMode;
    self.expenseEntryObject=(ExpenseEntryObject *)_expenseEntryObj;
}

- (void)loadView
{
    [super loadView];

    self.view.backgroundColor = [Util colorWithHex:@"#f8f8f8" alpha:1];

    if (expenseEntryTableView == nil)
    {
        self.expenseEntryTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), [self heightForTableView])];;
        self.expenseEntryTableView.separatorColor = [Util colorWithHex:@"#EEEEEE" alpha:1.0f];
    }

    self.expenseEntryTableView.delegate = self;
    self.expenseEntryTableView.dataSource = self;
    [self.view addSubview:expenseEntryTableView];

    self.navigationController.navigationBar.translucent = NO;

    UIView *bckView = [UIView new];
    [bckView setBackgroundColor:[Util colorWithHex:@"#f8f8f8" alpha:1]];
    [self.expenseEntryTableView setBackgroundView:bckView];

    if (screenMode == ADD_EXPENSE_ENTRY)
    {

        [Util setToolbarLabel:self withText:RPLocalizedString(ADD_EXPENSE_TITLE, ADD_EXPENSE_TITLE)];

        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]
                initWithTitle:RPLocalizedString (Cancel_Button_Title, Cancel_Button_Title)
                        style:UIBarButtonItemStylePlain
                       target:self
                       action:@selector(cancelAction:)];
        [self.navigationItem setLeftBarButtonItem:leftButton animated:NO];

    }
    else if (screenMode == EDIT_EXPENSE_ENTRY)
    {
        if ([expenseSheetStatus isEqualToString:APPROVED_STATUS] || [expenseSheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS])
        {
            [Util setToolbarLabel:self withText:RPLocalizedString(VIEW_EXPENSE_TITLE, VIEW_EXPENSE_TITLE)];
        }
        else
        {
            [Util setToolbarLabel:self withText:RPLocalizedString(EDIT_EXPENSE_TITLE, EDIT_EXPENSE_TITLE)];
        }
    }

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(Save_Button_Title, Save_Button_Title)
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(saveAction:)];

    [self.navigationItem setRightBarButtonItem:rightButton animated:NO];

    //Fix For Enable And Disable Save Button
    self.navigationItem.rightBarButtonItem.enabled = NO;

    [self configurePicker];

    if ([self.expenseEntryTableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        self.expenseEntryTableView.layoutMargins = UIEdgeInsetsZero;
    }

    if ([self.expenseEntryTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        self.expenseEntryTableView.separatorInset = UIEdgeInsetsZero;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    isProjectAllowed = NO;
    isProjectRequired = NO;
    isClientAllowed = NO;
    self.canEditTask = NO;

    UIViewController *viewControllerCtrl = (UIViewController *) parentDelegate;

    if ([viewControllerCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [viewControllerCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
        NSString *sheetIdentity = expenseEntryObject.expenseEntryExpenseSheetUri;
        ApprovalsModel *approvalModel = [[ApprovalsModel alloc] init];
        ApprovalsScrollViewController *scrollViewCtrl = (ApprovalsScrollViewController *) parentDelegate;

        if ([scrollViewCtrl.approvalsModuleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE])
        {
            self.isProjectAllowed = [approvalModel getPendingExpenseCapabilityStatusForGivenPermissions:@"expenseEntryAgainstProjectsAllowed" forSheetUri:sheetIdentity];
            self.isClientAllowed = [approvalModel getPendingExpenseCapabilityStatusForGivenPermissions:@"hasExpensesClientAccess" forSheetUri:sheetIdentity];
            self.isProjectRequired = [approvalModel getPendingExpenseCapabilityStatusForGivenPermissions:@"expenseEntryAgainstProjectsRequired" forSheetUri:sheetIdentity];
            self.canEditTask = [approvalModel getPendingExpenseCapabilityStatusForGivenPermissions:@"canEditTask" forSheetUri:sheetIdentity];
        }
        else
        {
            self.isProjectAllowed = [approvalModel getPreviousExpenseCapabilityStatusForGivenPermissions:@"expenseEntryAgainstProjectsAllowed" forSheetUri:sheetIdentity];
            self.isClientAllowed = [approvalModel getPreviousExpenseCapabilityStatusForGivenPermissions:@"hasExpensesClientAccess" forSheetUri:sheetIdentity];
            self.isProjectRequired = [approvalModel getPreviousExpenseCapabilityStatusForGivenPermissions:@"expenseEntryAgainstProjectsRequired" forSheetUri:sheetIdentity];
            self.canEditTask = [approvalModel getPreviousExpenseCapabilityStatusForGivenPermissions:@"canEditTask" forSheetUri:sheetIdentity];
        }
    }
    else if ([parentDelegate isKindOfClass:[ListOfExpenseEntriesViewController class]])
    {
        LoginModel *loginModel = [[LoginModel alloc] init];
        NSMutableArray *userDetailsArray = [loginModel getAllUserDetailsInfoFromDb];
        if (userDetailsArray.count != 0)
        {
            NSDictionary *userDict = userDetailsArray[0];
            self.isProjectAllowed = [userDict[@"expenseEntryAgainstProjectsAllowed"] boolValue];
            self.isProjectRequired = [userDict[@"expenseEntryAgainstProjectsRequired"] boolValue];
            self.isClientAllowed = [userDict[@"hasExpensesClientAccess"] boolValue];
            self.canEditTask = [userDict[@"canEditTask"] boolValue];;
        }
    }

    memoryWarnCount = 0;
    imageDeletePressed = NO;
    self.isSaveClicked = NO;
    [self setfirstSectionFields];
    [self setSecondSectionFields];
    [self registerForKeyboardNotification];
}

-(void)registerForKeyboardNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillBeOnScreen:) name:UIKeyboardWillShowNotification object:nil];
}

-(void)deregisterKeyboardNotification{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [center removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

-(void)keyboardWillBeOnScreen:(NSNotification *)notification
{
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setFloat:keyboardFrame.size.height forKey:@"KeyBoardHeight"];
    [userDefaults synchronize];
}

-(void)keyboardOnScreen:(NSNotification *)notification
{
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    
    NSArray *allWindows = [[UIApplication sharedApplication] windows];
    NSUInteger topWindow = [allWindows count] - 1;
    UIWindow *keyboardWindow = [allWindows objectAtIndex:topWindow];
    for (UIView *view in keyboardWindow.subviews){
        if([view isKindOfClass:[DecimalPointButton class]] || [view isKindOfClass:[MinusButton class]] || [view isKindOfClass:[DoneButton class]] || [view isKindOfClass:[SeparatorView class]]){
            CGRect buttonFrame = view.frame;
            buttonFrame.size.height = keyboardFrame.size.height/4;
            buttonFrame.origin.y = SCREEN_HEIGHT - buttonFrame.size.height;
            [UIView animateWithDuration:0.2f animations:^{
                view.frame = buttonFrame;
            }];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self resetTableSize:NO];
    [self createFooterView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self showDataPicker:NO];
    [self showDatePicker:NO];

    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    for (UIView *view in appDelegate.window.subviews)
    {
        if ([view isKindOfClass:[UIPickerView class]])//Mobi-240 Ullas M L
        {
            if ([view tag] == PICKER_VIEW_TAG_EXPENSE_VIEW)
            {
                [view removeFromSuperview];
            }
        }
    }
    [self deregisterKeyboardNotification];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];

    BOOL isPresent = NO;

    for (UIView *view in appDelegate.window.subviews)
    {
        if ([view isKindOfClass:[UIPickerView class]])//Mobi-240 Ullas M L
        {
            if ([view tag] == PICKER_VIEW_TAG_EXPENSE_VIEW)
            {
                isPresent = YES;
            }
        }
    }

    if (!isPresent && pickerView != nil)
    {
        [self.pickerView removeFromSuperview];
        [appDelegate.window addSubview:self.pickerView];
    }
}

#pragma mark -
#pragma mark  Datasource Methods
-(NSMutableArray *)setfirstSectionFields
{
    if (firstSectionfieldsArray == nil)
    {
		NSMutableArray *tempfirstSectionfieldsArray = [[NSMutableArray alloc] init];
        self.firstSectionfieldsArray=tempfirstSectionfieldsArray;

	}
    else
        [self.firstSectionfieldsArray   removeAllObjects];

    
    if (isClientAllowed && isProjectAllowed) {
        if (screenMode==EDIT_EXPENSE_ENTRY)
        {
            NSString *clientIdentity =expenseEntryObject.expenseEntryClientUri;
            NSString *clientName =expenseEntryObject.expenseEntryClientName;

            if (clientIdentity!=nil &&![clientIdentity isKindOfClass:[NSNull class]] && ![clientIdentity isEqualToString:@""] &&
                clientName!=nil     &&![clientName isKindOfClass:[NSNull class]]&& ![clientName isEqualToString:@""])
            {
                NSMutableDictionary *clientDict = [NSMutableDictionary dictionary];
                [clientDict setObject:RPLocalizedString(Client, @"") forKey:@"fieldName"];
                [clientDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
                [clientDict setObject:clientIdentity forKey: @"clientIdentity"];
                [clientDict setObject:clientName forKey: @"defaultValue"];
                [firstSectionfieldsArray addObject:clientDict];
            }
            else
            {
                if (isProjectAllowed==YES && isProjectRequired==NO)
                {
                    NSMutableDictionary *clientDict = [NSMutableDictionary dictionary];
                    [clientDict setObject:RPLocalizedString(Client, @"") forKey:@"fieldName"];
                    [clientDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
                    [clientDict setObject:[NSNull null] forKey: @"clientIdentity"];
                    [clientDict setObject:RPLocalizedString(NONE_STRING, @"") forKey: @"defaultValue"];
                    [firstSectionfieldsArray addObject:clientDict];
                }
                else
                {
                    NSMutableDictionary *clientDict = [NSMutableDictionary dictionary];
                    [clientDict setObject:RPLocalizedString(Client, @"") forKey:@"fieldName"];
                    [clientDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
                    [clientDict setObject:[NSNull null] forKey: @"projectIdentity"];
                    [clientDict setObject:RPLocalizedString(NONE_STRING, @"") forKey: @"defaultValue"];
                    [firstSectionfieldsArray addObject:clientDict];
                }
            }
        }
        else
        {
            if (isProjectRequired==NO)
            {
                NSMutableDictionary *clientDict = [NSMutableDictionary dictionary];
                [clientDict setObject:RPLocalizedString(Client, @"") forKey:@"fieldName"];
                [clientDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
                [clientDict setObject:[NSNull null] forKey: @"clientIdentity"];
                [clientDict setObject:RPLocalizedString(NONE_STRING, @"") forKey: @"defaultValue"];
                
                [firstSectionfieldsArray addObject:clientDict];
            }
            else
            {
                NSMutableDictionary *clientDict = [NSMutableDictionary dictionary];
                [clientDict setObject:RPLocalizedString(Client, @"") forKey:@"fieldName"];
                [clientDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
                [clientDict setObject:[NSNull null] forKey: @"clientIdentity"];
                [clientDict setObject:RPLocalizedString(NONE_STRING, @"") forKey: @"defaultValue"];
                [firstSectionfieldsArray addObject:clientDict];
            }
        }
    }
    
    if (isProjectAllowed)
    {
        //CLIENT PROJECT FIELD
        if (screenMode==EDIT_EXPENSE_ENTRY)
        {
            NSString *projectIdentity =expenseEntryObject.expenseEntryProjectUri;
            NSString *projectName =expenseEntryObject.expenseEntryProjectName;
            
            if (projectIdentity!=nil &&![projectIdentity isKindOfClass:[NSNull class]] && ![projectIdentity isEqualToString:@""] &&
                projectName!=nil     &&![projectName isKindOfClass:[NSNull class]]&& ![projectName isEqualToString:@""])
            {
                NSMutableDictionary *projectClientDict = [NSMutableDictionary dictionary];
                [projectClientDict setObject:RPLocalizedString(PROJECT, @"") forKey:@"fieldName"];
                [projectClientDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
                [projectClientDict setObject:projectIdentity forKey: @"projectIdentity"];
                [projectClientDict setObject:projectName forKey: @"defaultValue"];
                [firstSectionfieldsArray addObject:projectClientDict];
            }
            else
            {
                if (isProjectAllowed==YES && isProjectRequired==NO)
                {
                    NSMutableDictionary *projectClientDict = [NSMutableDictionary dictionary];
                    [projectClientDict setObject:RPLocalizedString(PROJECT, @"") forKey:@"fieldName"];
                    [projectClientDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
                    [projectClientDict setObject:[NSNull null] forKey: @"projectIdentity"];
                    [projectClientDict setObject:RPLocalizedString(NONE_STRING, @"") forKey: @"defaultValue"];
                    [firstSectionfieldsArray addObject:projectClientDict];
                }
                else
                {
                    NSMutableDictionary *projectClientDict = [NSMutableDictionary dictionary];
                    [projectClientDict setObject:RPLocalizedString(PROJECT, @"") forKey:@"fieldName"];
                    [projectClientDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
                    [projectClientDict setObject:[NSNull null] forKey: @"projectIdentity"];
                    [projectClientDict setObject:RPLocalizedString(SELECT_STRING, @"") forKey: @"defaultValue"];
                    [firstSectionfieldsArray addObject:projectClientDict];
                }
                
            }
            
        }
        else
        {
            if (isProjectRequired==NO)
            {
                NSMutableDictionary *projectClientDict = [NSMutableDictionary dictionary];
                [projectClientDict setObject:RPLocalizedString(PROJECT, @"") forKey:@"fieldName"];
                [projectClientDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
                [projectClientDict setObject:[NSNull null] forKey: @"projectIdentity"];
                [projectClientDict setObject:RPLocalizedString(NONE_STRING, @"") forKey: @"defaultValue"];
                [firstSectionfieldsArray addObject:projectClientDict];
            }
            else
            {
                NSMutableDictionary *projectClientDict = [NSMutableDictionary dictionary];
                [projectClientDict setObject:RPLocalizedString(PROJECT, @"") forKey:@"fieldName"];
                [projectClientDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
                [projectClientDict setObject:[NSNull null] forKey: @"projectIdentity"];
                [projectClientDict setObject:RPLocalizedString(SELECT_STRING, @"") forKey: @"defaultValue"];
                [firstSectionfieldsArray addObject:projectClientDict];
            }
        }
    }
    
    //For Task
    if (isProjectAllowed)
    {
        if (self.canEditTask)
        {
            if (screenMode==EDIT_EXPENSE_ENTRY)
            {
                NSString *taskIdentity =expenseEntryObject.expenseEntryTaskUri;
                NSString *taskName =expenseEntryObject.expenseEntryTaskName;

                if (taskIdentity!=nil &&![taskIdentity isKindOfClass:[NSNull class]] && ![taskIdentity isEqualToString:@""] &&
                    taskName!=nil     &&![taskName isKindOfClass:[NSNull class]]&& ![taskName isEqualToString:@""])
                {
                    NSMutableDictionary *taskDict = [NSMutableDictionary dictionary];
                    [taskDict setObject:RPLocalizedString(Task, @"") forKey:@"fieldName"];
                    [taskDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
                    [taskDict setObject:taskIdentity forKey: @"taskIdentity"];
                    [taskDict setObject:taskName forKey: @"defaultValue"];
                    [firstSectionfieldsArray addObject:taskDict];
                }
                else
                {
                    if (isProjectAllowed==YES && isProjectRequired==NO)
                    {
                        NSMutableDictionary *taskDict = [NSMutableDictionary dictionary];
                        [taskDict setObject:RPLocalizedString(Task, @"") forKey:@"fieldName"];
                        [taskDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
                        [taskDict setObject:[NSNull null] forKey: @"taskIdentity"];
                        [taskDict setObject:RPLocalizedString(NONE_STRING, @"") forKey: @"defaultValue"];
                        [firstSectionfieldsArray addObject:taskDict];
                    }
                    else
                    {
                        NSMutableDictionary *taskDict = [NSMutableDictionary dictionary];
                        [taskDict setObject:RPLocalizedString(Task, @"") forKey:@"fieldName"];
                        [taskDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
                        [taskDict setObject:[NSNull null] forKey: @"taskIdentity"];
                        [taskDict setObject:RPLocalizedString(NONE_STRING, @"") forKey: @"defaultValue"];
                        [firstSectionfieldsArray addObject:taskDict];
                    }
                }
            }
            else
            {
                if (isProjectRequired==NO)
                {
                    NSMutableDictionary *taskDict = [NSMutableDictionary dictionary];
                    [taskDict setObject:RPLocalizedString(Task, @"") forKey:@"fieldName"];
                    [taskDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
                    [taskDict setObject:[NSNull null] forKey: @"taskIdentity"];
                    [taskDict setObject:RPLocalizedString(NONE_STRING, @"") forKey: @"defaultValue"];

                    [firstSectionfieldsArray addObject:taskDict];
                }
                else
                {
                    NSMutableDictionary *taskDict = [NSMutableDictionary dictionary];
                    [taskDict setObject:RPLocalizedString(Task, @"") forKey:@"fieldName"];
                    [taskDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
                    [taskDict setObject:[NSNull null] forKey: @"taskIdentity"];
                    [taskDict setObject:RPLocalizedString(NONE_STRING, @"") forKey: @"defaultValue"];
                    [firstSectionfieldsArray addObject:taskDict];
                }
            }

        }

    }

    //TYPE FIELD
    if (screenMode==EDIT_EXPENSE_ENTRY)
    {
        NSString *typeIdentity =expenseEntryObject.expenseEntryExpenseCodeUri;
        NSString *typeName =expenseEntryObject.expenseEntryExpenseCodeName;
        if (typeIdentity!=nil &&![typeIdentity isKindOfClass:[NSNull class]] && ![typeIdentity isEqualToString:@""] &&
            typeName!=nil     &&![typeName isKindOfClass:[NSNull class]] && ![typeName isEqualToString:@""])
        {
            NSMutableArray *tmpDataSourceArray=[NSMutableArray array];
            NSNumber *selectedTypeIndex = [NSNumber numberWithInt:0];
            NSMutableDictionary *expenseTypeDict=[NSMutableDictionary dictionary];
            [expenseTypeDict setObject:RPLocalizedString(TYPE, @"") forKey:@"fieldName"];
           [expenseTypeDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
            [expenseTypeDict setObject:typeName forKey:@"defaultValue"];
            [expenseTypeDict setObject:selectedTypeIndex forKey:@"selectedIndex"];
            [expenseTypeDict setObject:typeIdentity forKey:@"selectedDataIdentity"];
            [expenseTypeDict setObject:tmpDataSourceArray forKey:@"dataSourceArray"];
            [expenseTypeDict setObject:typeName forKey:@"selectedDataSource"];

            [firstSectionfieldsArray addObject:expenseTypeDict];

        }

    }
    else
    {
        NSMutableArray *tmpDataSourceArray=[NSMutableArray array];
        NSNumber *selectedTypeIndex = [NSNumber numberWithInt:0];
        NSMutableDictionary *expenseTypeDict=[NSMutableDictionary dictionary];
        [expenseTypeDict setObject:RPLocalizedString(TYPE, @"") forKey:@"fieldName"];
        [expenseTypeDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
        [expenseTypeDict setObject:RPLocalizedString(SELECT, @"") forKey:@"defaultValue"];
        [expenseTypeDict setObject:selectedTypeIndex forKey:@"selectedIndex"];
        [expenseTypeDict setObject:@"" forKey:@"selectedDataIdentity"];
        [expenseTypeDict setObject:tmpDataSourceArray forKey:@"dataSourceArray"];
        [expenseTypeDict setObject:RPLocalizedString(SELECT, @"") forKey:@"selectedDataSource"];

        [firstSectionfieldsArray addObject:expenseTypeDict];

    }


    //AMOUNT FIELD

    //Implemented as per US7626
    if (screenMode==EDIT_EXPENSE_ENTRY)
    {

        NSString *expenseAmount =[Util getRoundedValueFromDecimalPlaces:[[expenseEntryObject expenseEntryIncurredAmountTotal] newDoubleValue] withDecimalPlaces:2];
        if (expenseAmount!=nil && ![expenseAmount isEqualToString:@""])
        {
            NSMutableDictionary *amountDict = [NSMutableDictionary dictionary];
            [amountDict setObject:RPLocalizedString(AMOUNT, @"") forKey:@"fieldName"];
            [amountDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
            [amountDict setObject:expenseAmount forKey:@"expenseAmount"];


            LoginModel *loginModel=[[LoginModel alloc]init];
            NSMutableArray *userDetailsArray=[loginModel getAllUserDetailsInfoFromDb];

            if ([userDetailsArray count]!=0)
            {
                NSDictionary *userDict=[userDetailsArray objectAtIndex:0];
                NSString *tempBaseCurrencyName=[userDict objectForKey:@"baseCurrencyName"];
                NSString *tempBaseCurrencyUri=[userDict objectForKey:@"baseCurrencyUri"];

                if (tempBaseCurrencyName!=nil && tempBaseCurrencyUri!=nil && ![tempBaseCurrencyName isKindOfClass:[NSNull class]] && ![tempBaseCurrencyUri isKindOfClass:[NSNull class]] )
                {
                    self.baseCurrencyUri=tempBaseCurrencyUri;
                    self.baseCurrencyName=tempBaseCurrencyName;
                }
            }
            NSString *currencyIdentity =expenseEntryObject.expenseEntryIncurredAmountTotalCurrencyUri;
            NSString *currencyName =expenseEntryObject.expenseEntryIncurredAmountTotalCurrencyName;
            if (currencyIdentity!=nil &&![currencyIdentity isKindOfClass:[NSNull class]] && ![currencyIdentity isEqualToString:@""] &&
                currencyName!=nil     &&![currencyName isKindOfClass:[NSNull class]] && ![currencyName isEqualToString:@""])
            {
                NSString *amt=[NSString stringWithFormat:@"%@ %@",currencyName,expenseAmount];
                NSMutableArray *tmpDataSourceArray=[NSMutableArray array];
                NSNumber *selectedCurrencyIndex = [NSNumber numberWithInt:0];
                [amountDict setObject:amt forKey:@"defaultValue"];
                [amountDict setObject:currencyName forKey:@"currencyName"];
                [amountDict setObject:selectedCurrencyIndex forKey:@"selectedIndex"];
                [amountDict setObject:currencyIdentity forKey:@"selectedDataIdentity"];
                [amountDict setObject:tmpDataSourceArray forKey:@"dataSourceArray"];
                [amountDict setObject:currencyName forKey:@"selectedDataSource"];
            }
            [firstSectionfieldsArray addObject:amountDict];
        }
    }
    else
    {
        NSMutableDictionary *amountDict = [NSMutableDictionary dictionary];
        [amountDict setObject:RPLocalizedString(AMOUNT, @"") forKey:@"fieldName"];
        [amountDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
        [amountDict setObject:RPLocalizedString(ADD, @"") forKey:@"defaultValue"];

        LoginModel *loginModel=[[LoginModel alloc]init];
        NSMutableArray *userDetailsArray=[loginModel getAllUserDetailsInfoFromDb];

        if ([userDetailsArray count]!=0)
        {
            NSDictionary *userDict=[userDetailsArray objectAtIndex:0];
            NSString *tempBaseCurrencyName=[userDict objectForKey:@"baseCurrencyName"];
            NSString *tempBaseCurrencyUri=[userDict objectForKey:@"baseCurrencyUri"];

            if (tempBaseCurrencyName!=nil && tempBaseCurrencyUri!=nil && ![tempBaseCurrencyName isKindOfClass:[NSNull class]] && ![tempBaseCurrencyUri isKindOfClass:[NSNull class]] )
            {
                self.baseCurrencyUri=tempBaseCurrencyUri;
                self.baseCurrencyName=tempBaseCurrencyName;


            }

        }

        else
        {
            self.baseCurrencyUri=nil;
            self.baseCurrencyName=nil;
        }

        NSMutableArray *tmpDataSourceArray=[NSMutableArray array];
        NSNumber *selectedCurrencyIndex = [NSNumber numberWithInt:0];
        NSString *currencyIdentity =reimbursementCurrencyURI;
        NSString *currencyName =reimbursementCurrencyName;
        if (currencyIdentity!=nil &&![currencyIdentity isKindOfClass:[NSNull class]] && ![currencyIdentity isEqualToString:@""] && currencyName!=nil     &&![currencyName isKindOfClass:[NSNull class]] && ![currencyName isEqualToString:@""])
        {

            [amountDict setObject:currencyName forKey:@"currencyName"];

            [amountDict setObject:currencyIdentity forKey:@"selectedDataIdentity"];

        }
        else{
            [amountDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"currencyName"];
            [amountDict setObject:@"" forKey:@"selectedDataIdentity"];
        }

        [amountDict setObject:selectedCurrencyIndex forKey:@"selectedIndex"];

        [amountDict setObject:tmpDataSourceArray forKey:@"dataSourceArray"];
        [amountDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"selectedDataSource"];

        [firstSectionfieldsArray addObject:amountDict];
    }

    return firstSectionfieldsArray;
}
-(NSMutableArray *)setSecondSectionFields
{
    if (secondSectionfieldsArray == nil)
    {
        NSMutableArray *tempsecondSectionfieldsArray = [[NSMutableArray alloc] init];
        self.secondSectionfieldsArray=tempsecondSectionfieldsArray;

    }
    else
    {
        [self.secondSectionfieldsArray   removeAllObjects];
    }


    BOOL isBillClientPermission=NO;
    BOOL isPaymentMethodPermission=NO;
    BOOL isReimbursePermission=NO;
    BOOL isReceiptPermission=NO;
    UIViewController *viewControllerCtrl=(UIViewController *)parentDelegate;
    //Approval context Flow for Expenses
     if ([viewControllerCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [viewControllerCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
        NSString *sheetIdentity=expenseEntryObject.expenseEntryExpenseSheetUri;
        ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
        ApprovalsScrollViewController *scrollViewCtrl=(ApprovalsScrollViewController *)parentDelegate;
        if ([scrollViewCtrl.approvalsModuleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE])
        {
            isBillClientPermission=[approvalModel getPendingExpenseCapabilityStatusForGivenPermissions:@"hasExpenseBillClient" forSheetUri:sheetIdentity];
            isPaymentMethodPermission=[approvalModel getPendingExpenseCapabilityStatusForGivenPermissions:@"hasExpensePaymentMethod" forSheetUri:sheetIdentity];
            isReimbursePermission=[approvalModel getPendingExpenseCapabilityStatusForGivenPermissions:@"hasExpenseReimbursements" forSheetUri:sheetIdentity];
            isReceiptPermission=[approvalModel getPendingExpenseCapabilityStatusForGivenPermissions:@"hasExpenseReceiptView" forSheetUri:sheetIdentity];
        }
        else
        {
            isBillClientPermission=[approvalModel getPreviousExpenseCapabilityStatusForGivenPermissions:@"hasExpenseBillClient" forSheetUri:sheetIdentity];
            isPaymentMethodPermission=[approvalModel getPreviousExpenseCapabilityStatusForGivenPermissions:@"hasExpensePaymentMethod" forSheetUri:sheetIdentity];
            isReimbursePermission=[approvalModel getPreviousExpenseCapabilityStatusForGivenPermissions:@"hasExpenseReimbursements" forSheetUri:sheetIdentity];
            isReceiptPermission=[approvalModel getPreviousExpenseCapabilityStatusForGivenPermissions:@"hasExpenseReceiptView" forSheetUri:sheetIdentity];
        }



    }
    //User context Flow for Expenses
    else if ([parentDelegate isKindOfClass:[ListOfExpenseEntriesViewController class]])
    {
        LoginModel *loginModel=[[LoginModel alloc]init];
        NSMutableArray *userDetailsArray=[loginModel getAllUserDetailsInfoFromDb];


        if ([userDetailsArray count]!=0)
        {
            NSDictionary *userDict=[userDetailsArray objectAtIndex:0];
            isBillClientPermission      =[[userDict objectForKey:@"hasExpenseBillClient"] boolValue];
            isPaymentMethodPermission   =[[userDict objectForKey:@"hasExpensePaymentMethod"] boolValue];
            isReimbursePermission       =[[userDict objectForKey:@"hasExpenseReimbursements"] boolValue];
            isReceiptPermission         =[[userDict objectForKey:@"hasExpenseReceiptView"] boolValue];
        }
    }





    //ENTRY DATE FIELD
    if (screenMode==EDIT_EXPENSE_ENTRY)
    {
        NSString *entryDate=[Util convertPickerDateToString:expenseEntryObject.expenseEntryIncurredDate];
        if (entryDate!=nil && ![entryDate isEqualToString:@""])
        {
            NSMutableDictionary *entryDateDict = [NSMutableDictionary dictionary];
            [entryDateDict setObject:RPLocalizedString(DATE_TEXT, @"") forKey:@"fieldName"];
            [entryDateDict setObject:DATE_PICKER forKey:@"fieldType"];
            [entryDateDict setObject:entryDate forKey:@"defaultValue"];

            [secondSectionfieldsArray addObject:entryDateDict];
        }

    }
    else
    {
        NSDate *todayDate=[NSDate date ];
        NSMutableDictionary *entryDateDict = [NSMutableDictionary dictionary];
        [entryDateDict setObject:RPLocalizedString(DATE_TEXT, @"") forKey:@"fieldName"];
        [entryDateDict setObject:DATE_PICKER forKey:@"fieldType"];
        //[entryDateDict setObject:[Util convertPickerDateToString:todayDate] forKey:@"defaultValue"];
        [entryDateDict setObject:[Util convertDateToString:todayDate] forKey:@"defaultValue"];
        [expenseEntryObject setExpenseEntryIncurredDate:todayDate];
        [secondSectionfieldsArray addObject:entryDateDict];

    }

    //DESCRIPTION FIELD
    if (screenMode==EDIT_EXPENSE_ENTRY)
    {
        NSString *description=expenseEntryObject.expenseEntryDescription;
        if (description!=nil && ![description isEqualToString:@""]&& ![description isKindOfClass:[NSNull class]]&&![description isEqualToString:@"<null>"])
        {
            NSMutableDictionary *descriptionDict = [NSMutableDictionary dictionary];
            [descriptionDict setObject:RPLocalizedString(DESCRIPTION, @"") forKey:@"fieldName"];
            [descriptionDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
            [descriptionDict setObject:description forKey:@"defaultValue"];

            [secondSectionfieldsArray addObject:descriptionDict];
        }
        else
        {
            NSMutableDictionary *descriptionDict = [NSMutableDictionary dictionary];
            [descriptionDict setObject:RPLocalizedString(DESCRIPTION, @"") forKey:@"fieldName"];
            [descriptionDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
            if (canNotEdit)
            {
                if (description!=nil && ![description isEqualToString:@""]&& ![description isKindOfClass:[NSNull class]]&&![description isEqualToString:@"<null>"])
                {
                   [descriptionDict setObject:description forKey:@"defaultValue"];
                }
                else
                {
                    [descriptionDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];

                }

            }
            else
            {
                [descriptionDict setObject:RPLocalizedString(ADD, @"") forKey:@"defaultValue"];
            }
            [secondSectionfieldsArray addObject:descriptionDict];

        }

    }
    else
    {
        NSMutableDictionary *descriptionDict = [NSMutableDictionary dictionary];
        [descriptionDict setObject:RPLocalizedString(DESCRIPTION, @"") forKey:@"fieldName"];
        [descriptionDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
        [descriptionDict setObject:RPLocalizedString(ADD, @"") forKey:@"defaultValue"];

        [secondSectionfieldsArray addObject:descriptionDict];
    }

    //BILL CLIENT FIELD
    if (isBillClientPermission && isProjectAllowed)
    {
        NSString *billingUri=expenseEntryObject.expenseEntryBillingUri;
        BOOL billClient = NO;
        if (billingUri!=nil && [billingUri isEqualToString:BILLABLE_EXPENSE_URI])
        {
            billClient = YES;
        }
        NSMutableDictionary *billClientDict=[NSMutableDictionary dictionary];
        [billClientDict setObject:RPLocalizedString(BILL_CLIENT, @"") forKey:@"fieldName"];
        [billClientDict setObject:CHECK_MARK forKey:@"fieldType"];
        [billClientDict setObject:billClient?Check_ON_Image:Check_OFF_Image forKey:@"defaultValue"];
        if (billClient)
        {
            [expenseEntryObject setExpenseEntryBillingUri:BILLABLE_EXPENSE_URI];
        }
        else
        {
            [expenseEntryObject setExpenseEntryBillingUri:NOT_BILLABLE_EXPENSE_URI];
        }

        [secondSectionfieldsArray addObject:billClientDict];
    }


    //EXPENSE RECEIPT FIELD

    if (isReceiptPermission) {
        BOOL hasExpenseReceipt=NO;
        NSString *receiptName=expenseEntryObject.expenseEntryExpenseReceiptName;
        NSString *receiptUri=expenseEntryObject.expenseEntryExpenseReceiptUri;
        if (receiptUri!=nil &&![receiptUri isKindOfClass:[NSNull class]] && ![receiptUri isEqualToString:@""] &&
            receiptName!=nil     &&![receiptName isKindOfClass:[NSNull class]] && ![receiptName isEqualToString:@""])
        {
            hasExpenseReceipt=YES;
        }
        NSMutableDictionary *receiptDict=[NSMutableDictionary dictionary];
        [receiptDict setObject:RPLocalizedString(RECEIPT_PHOTO, @"") forKey:@"fieldName"];
        [receiptDict setObject:IMAGE_PICKER forKey:@"fieldType"];
        if (canNotEdit)
        {
            if (hasExpenseReceipt)
            {
                [receiptDict setObject:(hasExpenseReceipt ? RPLocalizedString(YES_STRING,@"")  :RPLocalizedString(ADD, @"") ) forKey:@"defaultValue"];
            }
            else
            {
                [receiptDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
            }

        }
        else
        {
            [receiptDict setObject:(hasExpenseReceipt ? RPLocalizedString(YES_STRING,@"")  :RPLocalizedString(ADD, @"") ) forKey:@"defaultValue"];
        }


        [secondSectionfieldsArray addObject:receiptDict];
    }




   //REIMBURSEMENT FIELD

    if (isReimbursePermission)
    {

        NSString *reimburseUri=expenseEntryObject.expenseEntryReimbursementUri;
        BOOL canReimburse = NO;
        //UI Changes//JUHI
        if (screenMode==EDIT_EXPENSE_ENTRY)
        {
            if (reimburseUri!=nil && [reimburseUri isEqualToString:REIMBURSABLE_EXPENSE_URI])
            {
                canReimburse = YES;
            }
        }
        else
            canReimburse=YES;

        NSString *reimbursementImage = canReimburse?Check_ON_Image : Check_OFF_Image;
        NSMutableDictionary *reimburseDict=[NSMutableDictionary dictionary];
        [reimburseDict setObject:RPLocalizedString(REIMBURSE, @"") forKey:@"fieldName"];
        [reimburseDict setObject:CHECK_MARK forKey:@"fieldType"];
        [reimburseDict setObject:reimbursementImage forKey:@"defaultValue"];

        if (canReimburse)
        {
            [expenseEntryObject setExpenseEntryReimbursementUri:REIMBURSABLE_EXPENSE_URI];
        }
        else
        {
            [expenseEntryObject setExpenseEntryReimbursementUri:NOT_REIMBURSABLE_EXPENSE_URI];
        }

        [secondSectionfieldsArray addObject:reimburseDict];
    }


    //PAYMENT FIELD
    if (isPaymentMethodPermission)
    {
        if (screenMode==EDIT_EXPENSE_ENTRY)
        {
            NSString *paymentIdentity =expenseEntryObject.expenseEntryPaymentMethodUri;
            NSString *paymentName =expenseEntryObject.expenseEntryPaymentMethodName;

            if ([paymentIdentity isKindOfClass:[NSNull class]]||[paymentName isKindOfClass:[NSNull class]])
            {
                paymentIdentity=RPLocalizedString(SELECT, @"");
                paymentName=RPLocalizedString(SELECT, @"");
            }
            if (paymentIdentity!=nil && ![paymentIdentity isEqualToString:@""] &&
                paymentName!=nil     && ![paymentName isEqualToString:@""])
            {
                NSMutableArray *tmpDataSourceArray=[NSMutableArray array];
                NSNumber *selectedPaymentIndex = [NSNumber numberWithInt:0];
                NSMutableDictionary *paymentDict=[NSMutableDictionary dictionary];
                [paymentDict setObject:RPLocalizedString(PAYMENT_METHOD, @"") forKey:@"fieldName"];
                [paymentDict setObject:DATA_PICKER forKey:@"fieldType"];
                [paymentDict setObject:selectedPaymentIndex forKey:@"selectedIndex"];
                [paymentDict setObject:paymentIdentity forKey:@"selectedDataIdentity"];
                [paymentDict setObject:tmpDataSourceArray forKey:@"dataSourceArray"];
                [paymentDict setObject:paymentName forKey:@"selectedDataSource"];
                if (canNotEdit)
                {
                    // Fix for defect DE16374
                    if (![paymentName isKindOfClass:[NSNull class]]&& paymentName!=nil && ![paymentName isEqualToString:RPLocalizedString(SELECT, @"")])
                    {
                        [paymentDict setObject:paymentName forKey:@"defaultValue"];

                    }
                    else
                        [paymentDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];

                }
                else
                {
                    [paymentDict setObject:paymentName forKey:@"defaultValue"];
                }
                [secondSectionfieldsArray addObject:paymentDict];
            }

        }
        else
        {
            NSMutableArray *tmpDataSourceArray=[NSMutableArray array];
            NSNumber *selectedPaymentIndex = [NSNumber numberWithInt:0];
            NSMutableDictionary *paymentDict=[NSMutableDictionary dictionary];
            [paymentDict setObject:RPLocalizedString(PAYMENT_METHOD, @"") forKey:@"fieldName"];
            [paymentDict setObject:DATA_PICKER forKey:@"fieldType"];
            [paymentDict setObject:RPLocalizedString(SELECT, @"") forKey:@"defaultValue"];
            [paymentDict setObject:selectedPaymentIndex forKey:@"selectedIndex"];
            [paymentDict setObject:@"" forKey:@"selectedDataIdentity"];
            [paymentDict setObject:tmpDataSourceArray forKey:@"dataSourceArray"];
            [paymentDict setObject:RPLocalizedString(SELECT, @"") forKey:@"selectedDataSource"];

            [secondSectionfieldsArray addObject:paymentDict];

        }

    }
    [self createUdfs];
    return secondSectionfieldsArray;
}

-(void)createUdfs
{
    int decimalPlace=0;
    LoginModel *loginModel=[[LoginModel alloc]init];
    NSMutableArray *udfArray=[loginModel getEnabledOnlyUDFsforModuleName:EXPENSES_UDF];

    for (int i=0; i<[udfArray count]; i++)
    {
        NSDictionary *udfDict = [udfArray objectAtIndex: i];
        // NSString *moduleNameStr=nil;
        // moduleNameStr=[NSString stringWithFormat:@"%@UDF%d",[udfDict objectForKey:@"moduleName"],[[udfDict objectForKey:@"fieldIndex"]intValue]+1];
        NSMutableDictionary *dictInfo = [NSMutableDictionary dictionary];
        [dictInfo setObject:[udfDict objectForKey:@"name"] forKey:@"fieldName"];
        [dictInfo setObject:[udfDict objectForKey:@"uri"] forKey:@"identity"];
        if ([[udfDict objectForKey:@"udfType"] isEqualToString: NUMERIC_UDF_TYPE])
        {
            [dictInfo setObject:NUMERIC_UDF_TYPE forKey:@"fieldTypeUri"];
            [dictInfo setObject:NUMERIC_KEY_PAD forKey:@"fieldType"];

            if ([expenseEntryObject.expenseEntryApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[expenseEntryObject.expenseEntryApprovalStatus  isEqualToString:APPROVED_STATUS] ) {
                [dictInfo setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
            }
            else
               [dictInfo setObject:RPLocalizedString(ADD, @"") forKey:@"defaultValue"];

            if ([udfDict objectForKey:@"numericDecimalPlaces"]!=nil && !([[udfDict objectForKey:@"numericDecimalPlaces"] isKindOfClass:[NSNull class]]))
            {
                decimalPlace=[[udfDict objectForKey:@"numericDecimalPlaces"] intValue];
                [dictInfo setObject:[udfDict objectForKey:@"numericDecimalPlaces"] forKey:@"defaultDecimalValue"];
            }

            if ([udfDict objectForKey:@"numericMinValue"]!=nil && !([[udfDict objectForKey:@"numericMinValue"] isKindOfClass:[NSNull class]])) {
                [dictInfo setObject:[udfDict objectForKey:@"numericMinValue"] forKey:@"defaultMinValue"];
            }
            if ([udfDict objectForKey:@"numericMaxValue"]!=nil && !([[udfDict objectForKey:@"numericMaxValue"] isKindOfClass:[NSNull class]])) {
                [dictInfo setObject:[udfDict objectForKey:@"numericMaxValue"] forKey:@"defaultMaxValue"];
            }

            if ([udfDict objectForKey:@"numericDefaultValue"]!=nil && !([[udfDict objectForKey:@"numericDefaultValue"] isKindOfClass:[NSNull class]])&&![[udfDict objectForKey:@"numericDefaultValue"] isEqualToString:@""])
            {
                [dictInfo setObject:[Util getRoundedValueFromDecimalPlaces:[[udfDict objectForKey:@"numericDefaultValue"] newDoubleValue] withDecimalPlaces:decimalPlace] forKey:@"defaultValue"];
            }
        }
        else if ([[udfDict objectForKey:@"udfType"] isEqualToString:TEXT_UDF_TYPE])
        {
            [dictInfo setObject:UDFType_TEXT forKey:@"fieldType"];
            [dictInfo setObject:TEXT_UDF_TYPE forKey:@"fieldTypeUri"];
            if ([expenseEntryObject.expenseEntryApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[expenseEntryObject.expenseEntryApprovalStatus  isEqualToString:APPROVED_STATUS] ) {
                [dictInfo setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
            }
            else
                [dictInfo setObject:RPLocalizedString(ADD, @"") forKey:@"defaultValue"];
            if ([udfDict objectForKey:@"textDefaultValue"]!=nil && ![[udfDict objectForKey:@"textDefaultValue"]isKindOfClass:[NSNull class]]){
                if (![[udfDict objectForKey:@"textDefaultValue"] isEqualToString:@""]&&(![[udfDict objectForKey:@"textDefaultValue"] isEqualToString:@"null"])) {
                    [dictInfo setObject:[udfDict objectForKey:@"textDefaultValue"] forKey:@"defaultValue"];
                }
            }
            if ([udfDict objectForKey:@"textMaxValue"]!=nil && !([[udfDict objectForKey:@"textMaxValue"] isKindOfClass:[NSNull class]]))
                [dictInfo setObject:[udfDict objectForKey:@"textMaxValue"] forKey:@"defaultMaxValue"];
        }
        else if ([[udfDict objectForKey:@"udfType"] isEqualToString:DATE_UDF_TYPE])
        {
            [dictInfo setObject: DATE_PICKER forKey: @"fieldType"];
            [dictInfo setObject:DATE_UDF_TYPE forKey:@"fieldTypeUri"];
            if ([expenseEntryObject.expenseEntryApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[expenseEntryObject.expenseEntryApprovalStatus  isEqualToString:APPROVED_STATUS] ) {
                [dictInfo setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
            }
            else
                [dictInfo setObject:RPLocalizedString(SELECT_STRING, @"") forKey:@"defaultValue"];

            if ([udfDict objectForKey:@"dateMaxValue"]!=nil && !([[udfDict objectForKey:@"dateMaxValue"] isKindOfClass:[NSNull class]]))
            {
                [dictInfo setObject:[udfDict objectForKey:@"dateMaxValue"] forKey:@"defaultMaxValue"];
            }
            if ([udfDict objectForKey:@"dateMinValue"]!=nil && !([[udfDict objectForKey:@"dateMinValue"] isKindOfClass:[NSNull class]]))
            {
                [dictInfo setObject:[udfDict objectForKey:@"dateMinValue"] forKey:@"defaultMinValue"];
            }

            if ([udfDict objectForKey:@"isDateDefaultValueToday"]!=nil && !([[udfDict objectForKey:@"isDateDefaultValueToday"] isKindOfClass:[NSNull class]]))
            {
                if ([[udfDict objectForKey:@"isDateDefaultValueToday"]intValue]==1)
                {
                    //[dictInfo setObject:[Util convertPickerDateToString:[NSDate date]] forKey:@"defaultValue"];
                    [dictInfo setObject:[Util convertDateToString:[NSDate date]] forKey:@"defaultValue"];

                }else
                {
                    if ([udfDict objectForKey:@"dateDefaultValue"]!=nil && !([[udfDict objectForKey:@"dateDefaultValue"] isKindOfClass:[NSNull class]]))
                    {
                        [dictInfo setObject:[Util convertPickerDateToString:[Util convertTimestampFromDBToDate:[[udfDict objectForKey:@"dateDefaultValue"] stringValue]]] forKey:@"defaultValue"];

                    }
                    else
                    {
                        if ([expenseEntryObject.expenseEntryApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[expenseEntryObject.expenseEntryApprovalStatus  isEqualToString:APPROVED_STATUS] ) {
                            [dictInfo setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
                        }
                        else
                            [dictInfo setObject:RPLocalizedString(SELECT_STRING, @"") forKey:@"defaultValue"];
                    }
                }
            }
            else {
                if ([udfDict objectForKey:@"dateDefaultValue"]!=nil && !([[udfDict objectForKey:@"dateDefaultValue"] isKindOfClass:[NSNull class]]))
                {
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];

                    NSLocale *locale=[NSLocale currentLocale];
                    [dateFormat setLocale:locale];
                    [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                    [dateFormat setDateFormat:@"MMMM dd, yyyy"];

                    NSDate *dateToBeUsed = [Util convertTimestampFromDBToDate:[[udfDict objectForKey:@"dateDefaultValue"] stringValue]];
                    NSString *dateStr = [dateFormat stringFromDate:dateToBeUsed];
                    dateToBeUsed=[dateFormat dateFromString:dateStr];

                    if (dateToBeUsed==nil) {
                        [dateFormat setDateFormat:@"d MMMM yyyy"];
                        dateToBeUsed = [dateFormat dateFromString:dateStr];

                    }


                    NSString *dateDefaultValueFormatted = [Util convertPickerDateToString:dateToBeUsed];

                    if(dateDefaultValueFormatted != nil)
                    {
                        [dictInfo setObject:dateDefaultValueFormatted forKey:@"defaultValue"];

                    }
                    else
                    {
                        [dictInfo setObject:[Util convertPickerDateToString:[Util convertTimestampFromDBToDate:[[udfDict objectForKey:@"dateDefaultValue"] stringValue]]] forKey:@"defaultValue"];
                    }
                }
                else
                {
                    if ([expenseEntryObject.expenseEntryApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[expenseEntryObject.expenseEntryApprovalStatus  isEqualToString:APPROVED_STATUS] ) {
                        [dictInfo setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
                    }
                    else
                        [dictInfo setObject:RPLocalizedString(SELECT_STRING, @"") forKey:@"defaultValue"];
                }
            }
        }
        else if ([[udfDict objectForKey:@"udfType"] isEqualToString:DROPDOWN_UDF_TYPE])
        {
            [dictInfo setObject:UDFType_DROPDOWN forKey:@"fieldType"];
            [dictInfo setObject:DROPDOWN_UDF_TYPE forKey:@"fieldTypeUri"];
            if ([expenseEntryObject.expenseEntryApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[expenseEntryObject.expenseEntryApprovalStatus  isEqualToString:APPROVED_STATUS] ) {
                [dictInfo setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
            }
            else
                [dictInfo setObject:RPLocalizedString(SELECT_STRING, @"") forKey:@"defaultValue"];

            if ([udfDict objectForKey:@"textDefaultValue"]!=nil &&![[udfDict objectForKey:@"textDefaultValue"]isKindOfClass:[NSNull class]])
            {
                if (![[udfDict objectForKey:@"textDefaultValue"] isEqualToString:@""])
                {
                    [dictInfo setObject:[udfDict objectForKey:@"textDefaultValue"] forKey:@"defaultValue"];
                    [dictInfo setObject:[udfDict objectForKey:@"dropDownOptionDefaultURI"] forKey:@"dropDownOptionUri"];
                }
            }
        }
        NSArray *selectedudfArray=nil;
        UIViewController *viewControllerCtrl=(UIViewController *)parentDelegate;
        //Approval context Flow for Expenses
        if ([viewControllerCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [viewControllerCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
        {
            ApprovalsScrollViewController *scrollViewCtrl=(ApprovalsScrollViewController *)parentDelegate;
            if ([scrollViewCtrl.approvalsModuleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE])
            {
                ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
                selectedudfArray=[approvalsModel getPendingExpenseCustomFieldsForSheetURI:expenseEntryObject.expenseEntryExpenseSheetUri moduleName:EXPENSES_UDF entryURI:expenseEntryObject.expenseEntryExpenseEntryUri andUdfURI:[dictInfo objectForKey: @"identity"]];

            }
            else
            {
                ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
                selectedudfArray=[approvalsModel getPreviousExpenseCustomFieldsForSheetURI:expenseEntryObject.expenseEntryExpenseSheetUri moduleName:EXPENSES_UDF entryURI:expenseEntryObject.expenseEntryExpenseEntryUri andUdfURI:[dictInfo objectForKey: @"identity"]];

            }

        }
        //User context Flow for Expenses
        else if ([parentDelegate isKindOfClass:[ListOfExpenseEntriesViewController class]])
        {
            ExpenseModel *expenseModel=[[ExpenseModel alloc]init];
            selectedudfArray=[expenseModel getExpenseCustomFieldsForSheetURI:expenseEntryObject.expenseEntryExpenseSheetUri moduleName:EXPENSES_UDF entryURI:expenseEntryObject.expenseEntryExpenseEntryUri andUdfURI:[dictInfo objectForKey: @"identity"]];

        }


        if ([selectedudfArray count]>0)
        {
            NSMutableDictionary *selUDFDataDict=[selectedudfArray objectAtIndex:0];
            NSMutableDictionary *udfDetailDict=[[NSMutableDictionary alloc]init];
            if (selUDFDataDict!=nil && ![selUDFDataDict isKindOfClass:[NSNull class]]) {
                NSString *udfvaleFormDb=[selUDFDataDict objectForKey: @"udfValue"];
                if (udfvaleFormDb!=nil && ![udfvaleFormDb isKindOfClass:[NSNull class]])
                {
                    if (![udfvaleFormDb isEqualToString:@""]) {
                        if ([[selUDFDataDict objectForKey:@"entry_type"] isEqualToString:DATE_UDF_TYPE])
                        {
                            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];

                            NSLocale *locale=[NSLocale currentLocale];
                            [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                            [dateFormat setLocale:locale];
                            [dateFormat setDateFormat:@"yyyy-MM-dd"];
                            NSDate *setDate=[dateFormat dateFromString:udfvaleFormDb];
                            if (!setDate) {
                                [dateFormat setDateFormat:@"MMMM dd, yyyy"];
                                setDate=[dateFormat dateFromString:udfvaleFormDb];

                                if (setDate==nil) {
                                    [dateFormat setDateFormat:@"d MMMM yyyy"];
                                    setDate = [dateFormat dateFromString:udfvaleFormDb];
                                    if (setDate==nil)
                                    {
                                        [dateFormat setDateFormat:@"d MMMM, yyyy"];
                                        setDate = [dateFormat dateFromString:udfvaleFormDb];

                                    }
                                }

                            }
                            [dateFormat setDateFormat:@"MMMM dd, yyyy"];
                            udfvaleFormDb=[dateFormat stringFromDate:setDate];
                            NSDate *dateToBeUsed = [dateFormat dateFromString:udfvaleFormDb];
                            [udfDetailDict setObject:[Util convertDateToString:dateToBeUsed] forKey:@"defaultValue"];

                        }
                        else{
                            if ([[selUDFDataDict objectForKey:@"entry_type"] isEqualToString:NUMERIC_UDF_TYPE])
                            {
                                [udfDetailDict setObject:[Util getRoundedValueFromDecimalPlaces:[udfvaleFormDb newDoubleValue] withDecimalPlaces:decimalPlace] forKey:@"defaultValue"];
                            }
                            else
                                [udfDetailDict setObject:udfvaleFormDb forKey:@"defaultValue"];
                            if ([[selUDFDataDict objectForKey:@"entry_type"] isEqualToString:DROPDOWN_UDF_TYPE])
                            {
                                [udfDetailDict setObject:[selUDFDataDict objectForKey: @"dropDownOptionURI" ] forKey:@"dropDownOptionUri"];
                            }
                        }

                    }
                    else
                    {
                        if (([expenseSheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[expenseSheetStatus isEqualToString:APPROVED_STATUS ])) {
                            [udfDetailDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
                        }
                        else
                            [udfDetailDict setObject:[dictInfo objectForKey: @"defaultValue" ] forKey:@"defaultValue"];

                    }

                }
                else
                {
                    if (([expenseSheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[expenseSheetStatus isEqualToString:APPROVED_STATUS ])) {
                        [udfDetailDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
                    }
                    else
                        [udfDetailDict setObject:[dictInfo objectForKey: @"defaultValue" ] forKey:@"defaultValue"];

                }
                [udfDetailDict setObject:[dictInfo objectForKey: @"fieldName" ] forKey:@"fieldName"];

                [udfDetailDict setObject:[dictInfo objectForKey: @"fieldType"] forKey:@"fieldType"];
                [udfDetailDict setObject:[dictInfo objectForKey: @"identity"] forKey:@"uri"];
                if ([dictInfo objectForKey: @"defaultDecimalValue" ]!=nil)
                {
                    [udfDetailDict setObject:[dictInfo objectForKey: @"defaultDecimalValue" ] forKey:@"defaultDecimalValue"];
                }
                if ([dictInfo objectForKey: @"defaultMinValue" ]!=nil)
                {
                    [udfDetailDict setObject:[dictInfo objectForKey: @"defaultMinValue" ] forKey:@"defaultMinValue"];
                }
                if ([dictInfo objectForKey: @"defaultMaxValue" ]!=nil)
                {
                    [udfDetailDict setObject:[dictInfo objectForKey: @"defaultMaxValue" ] forKey:@"defaultMaxValue"];
                }
                [udfDetailDict setObject:[dictInfo objectForKey: @"fieldTypeUri"] forKey:@"fieldTypeUri"];
                [secondSectionfieldsArray addObject:udfDetailDict];

            }
        }
        else{
            NSMutableDictionary *udfDetailDict=[[NSMutableDictionary alloc]init];

            if (([expenseSheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[expenseSheetStatus isEqualToString:APPROVED_STATUS ])) {
                [udfDetailDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
            }
            else
                [udfDetailDict setObject:[dictInfo objectForKey: @"defaultValue" ] forKey:@"defaultValue"];

            [udfDetailDict setObject:[dictInfo objectForKey: @"fieldName" ] forKey:@"fieldName"];

            [udfDetailDict setObject:[dictInfo objectForKey: @"fieldType"] forKey:@"fieldType"];
            [udfDetailDict setObject:[dictInfo objectForKey: @"identity"] forKey:@"uri"];
            if ([dictInfo objectForKey: @"defaultDecimalValue" ]!=nil)
            {
                [udfDetailDict setObject:[dictInfo objectForKey: @"defaultDecimalValue" ] forKey:@"defaultDecimalValue"];
            }
            if ([dictInfo objectForKey: @"defaultMinValue" ]!=nil)
            {
                [udfDetailDict setObject:[dictInfo objectForKey: @"defaultMinValue" ] forKey:@"defaultMinValue"];
            }
            if ([dictInfo objectForKey: @"defaultMaxValue" ]!=nil)
            {
                [udfDetailDict setObject:[dictInfo objectForKey: @"defaultMaxValue" ] forKey:@"defaultMaxValue"];
            }
            if ([dictInfo objectForKey: @"dropDownOptionUri" ]!=nil)
            {
                [udfDetailDict setObject:[dictInfo objectForKey: @"dropDownOptionUri" ] forKey:@"dropDownOptionUri"];
            }
            [udfDetailDict setObject:[dictInfo objectForKey: @"fieldTypeUri"] forKey:@"fieldTypeUri"];
            [secondSectionfieldsArray addObject:udfDetailDict];


        }

    }
}



#pragma mark -
#pragma mark  UITableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	if (section == EXPENSE_SECTION)
    {

		UILabel	*expenseLabel= [[UILabel alloc] initWithFrame:CGRectMake(10.15,0.0,250.0,30.0)];
		[expenseLabel setBackgroundColor:[UIColor clearColor]];
		[expenseLabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_14]];
		[expenseLabel setText:RPLocalizedString(@"Expense",@"")];
		UIView *expenseHeader = [UIView new];
        [expenseHeader setBackgroundColor:[Util colorWithHex:@"#EEEEEE" alpha:1.0f]];
		[expenseHeader addSubview:expenseLabel];


        return expenseHeader;
	}
    else if (section ==DETAILS_SECTION)
    {

		UILabel	*detailLabel= [[UILabel alloc] initWithFrame:CGRectMake(10.0,0.0,250.0,30.0)];
        [detailLabel setBackgroundColor:[UIColor clearColor]];
		[detailLabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_14]];
		[detailLabel setText:RPLocalizedString(@"Detail",@"")];
		UIView	*otherHeader = [UIView new];
        [otherHeader setBackgroundColor:[Util colorWithHex:@"#EEEEEE" alpha:1.0f]];
		[otherHeader addSubview:detailLabel];


        return otherHeader;
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSMutableDictionary *dataDictObj=nil;
    if ( indexPath.row <[firstSectionfieldsArray count]&& indexPath.section == EXPENSE_SECTION)
    {
        dataDictObj=[firstSectionfieldsArray objectAtIndex:indexPath.row];
    }
	if ( indexPath.row <[secondSectionfieldsArray count] && indexPath.section== DETAILS_SECTION)
    {
        dataDictObj=[secondSectionfieldsArray objectAtIndex:indexPath.row];
    }
    NSString *fieldName=[dataDictObj objectForKey:@"fieldName"];
    NSString *defaultValue=[dataDictObj objectForKey:@"defaultValue"];
    CGSize nameSize;
    CGSize valueSize;
    float heightName=0.0;
    float heightValue=0.0;
    if (defaultValue)
    {


        // Let's make an NSAttributedString first
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:defaultValue];
        //Add LineBreakMode
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
        [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        // Add Font
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]} range:NSMakeRange(0, attributedString.length)];

        //Now let's make the Bounding Rect
        valueSize = [attributedString boundingRectWithSize:CGSizeMake(150, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

        if (valueSize.width==0 && valueSize.height ==0)
        {
            valueSize=CGSizeMake(0.0, 0.0);
        }
        heightValue=valueSize.height;


    }
    if (fieldName)
    {


        // Let's make an NSAttributedString first
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:fieldName];
        //Add LineBreakMode
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
        [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        // Add Font
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]} range:NSMakeRange(0, attributedString.length)];

        //Now let's make the Bounding Rect
        nameSize = [attributedString boundingRectWithSize:CGSizeMake(150, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

        if (nameSize.width==0 && nameSize.height ==0)
        {
            nameSize=CGSizeMake(0.0, 0.0);
        }
        heightName=nameSize.height;
    }
    
    heightValue=valueSize.height+38;
    heightName=nameSize.height+38;
    
    if (heightName>Each_Cell_Row_Height_44 || heightValue>Each_Cell_Row_Height_44)
    {
        if (heightName>=heightValue)
        {
            if (heightName>Each_Cell_Row_Height_44)
            {
                return heightName-16;
            }
            return Each_Cell_Row_Height_44;
        }
        else
        {
            //float tempHeightName = heightValue+38;
            if (heightValue>heightName)
            {
                if (heightValue>=92)
                {
                    return heightValue-10;
                }
                else
                {
                    if ([[dataDictObj objectForKey:@"fieldType"]isEqualToString: CHECK_MARK])
                    {
                        return Each_Cell_Row_Height_44;
                    }
                    return heightValue-28;
                }
                
            }
            
            return Each_Cell_Row_Height_44;
            
        }
    }
    else
    {
        return Each_Cell_Row_Height_44;
    }

    return Each_Cell_Row_Height_44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == EXPENSE_SECTION) {
		return [firstSectionfieldsArray count];
	}
	if (section == DETAILS_SECTION) {
		return [secondSectionfieldsArray count];
	}
	return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"ExpenseEntryCellIdentifier";
	cell = (ExpenseEntryCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (cell == nil)
    {
        cell = [[ExpenseEntryCustomCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil width:CGRectGetWidth(self.view.bounds)];
	}
    cell.expenseEntryCellDelegate=self;
	cell.canNotEdit=canNotEdit;
    if ( indexPath.row <[firstSectionfieldsArray count]&& indexPath.section == EXPENSE_SECTION)
    {
		NSInteger tagIndex = FIRSTSECTION_TAG_INDEX+indexPath.row;
		[cell addFieldAtIndex:indexPath withTagIndex:tagIndex withObj:[firstSectionfieldsArray objectAtIndex:indexPath.row]];
	}
	if ( indexPath.row <[secondSectionfieldsArray count] && indexPath.section== DETAILS_SECTION)
    {
		NSInteger tagIndex = SECONDSECTION_TAG_INDEX+indexPath.row;

        if ([[secondSectionfieldsArray objectAtIndex:indexPath.row] objectForKey:@"fieldTypeUri"]!=nil && ![[[secondSectionfieldsArray objectAtIndex:indexPath.row] objectForKey:@"fieldTypeUri"] isKindOfClass:[NSNull class]])
        {
            [cell addFieldAtIndex:indexPath withTagIndex:indexPath.row withObj:[secondSectionfieldsArray objectAtIndex:indexPath.row]];
        }
        else
            [cell addFieldAtIndex:indexPath withTagIndex:tagIndex withObj:[secondSectionfieldsArray objectAtIndex:indexPath.row]];
	}

    NSString *fieldName = [[cell dataObj] objectForKey:@"fieldName"];

    if ([[[cell dataObj] objectForKey:@"fieldType"] isEqualToString:MOVE_TO_NEXT_SCREEN])
    {
		[[cell fieldName] setText:[[cell dataObj]  objectForKey:@"fieldName"]];

		if ([[[cell dataObj]  objectForKey:@"defaultValue"] isEqualToString:@""])
        {
			[[cell fieldButton] setText:RPLocalizedString(ADD,@"")];
		}
        else
        {
			if (indexPath.section == 0 && [[[cell dataObj]  objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(AMOUNT, @"")])
            {
				[[cell fieldButton] setText:[[cell dataObj]  objectForKey:@"defaultValue"]];
			}
            else
            {
				[[cell fieldButton] setText:[[cell dataObj]  objectForKey:@"defaultValue"]];
			}
		}
	}
	else if ([[[cell dataObj] objectForKey:@"fieldType"]isEqualToString:CHECK_MARK])
    {
		if ([[[cell dataObj] objectForKey:@"fieldName"] isEqualToString: RPLocalizedString(BILL_CLIENT, @"")])
        {
            [cell.expenseSwitch setOn:[[cell.dataObj objectForKey:@"defaultValue"] isEqualToString:Check_ON_Image]];
            if ([self billClientShouldDisable])
            {
                [cell grayedOutRequiredCell];
            }
            else
            {
                [cell enableRequiredCell];
            }
		}
        else
        {
			[cell.fieldButton setUserInteractionEnabled:YES];
		}
	}
	else if ([[[cell dataObj] objectForKey:@"fieldType"] isEqualToString:IMAGE_PICKER] ||
             [[[cell dataObj] objectForKey:@"fieldType"] isEqualToString:DATA_PICKER] ||
			 [[[cell dataObj] objectForKey:@"fieldType"] isEqualToString:DATE_PICKER]||[[[cell dataObj] objectForKey:@"fieldType"] isEqualToString:UDFType_DROPDOWN]||[[[cell dataObj] objectForKey:@"fieldType"] isEqualToString:UDFType_TEXT])
    {
        NSLog(@"%@",[[cell dataObj] objectForKey:@"fieldName"]);
        NSLog(@"%@",[[cell dataObj] objectForKey:@"defaultValue"]);
		[[cell fieldName] setText:[[cell dataObj] objectForKey:@"fieldName"]];
		[[cell fieldButton] setText:[[cell dataObj] objectForKey:@"defaultValue"]];

		if ([[[cell dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(CURRENCY, @"")])
        {
			if ([self currencyFieldHandlings])
			{
				[cell grayedOutRequiredCell];
			}
            else
            {
				[cell enableRequiredCell];
			}
		}
	}
    else if ([[[cell dataObj] objectForKey:@"fieldType"]isEqualToString:NUMERIC_KEY_PAD])
    {
		[cell.fieldButton setHidden:YES];
		[cell.fieldText setHidden:NO];
	}
    else
    {
		[cell.fieldButton setHidden:NO];
		[cell.fieldText setHidden:YES];
	}

	if (canNotEdit)
    {
       [self disableAllFieldsForWaitingSheets:cell];
    }

    if (indexPath.section==EXPENSE_SECTION && screenMode==ADD_EXPENSE_ENTRY)
    {
        NSString *fieldName=[[cell dataObj] objectForKey:@"fieldName"];
        NSString *defaultValue=[[cell dataObj] objectForKey:@"defaultValue"];
        if ([fieldName isEqualToString:RPLocalizedString(TYPE, @"")]&&
            [defaultValue isEqualToString:RPLocalizedString(SELECT, @"")])
        {
            if (isProjectAllowed==YES && isProjectRequired==NO)
            {
                [cell enableRequiredCell];
            }
            else if(isProjectAllowed==NO)
            {
                [cell enableRequiredCell];
            }
            else
            {
                [cell grayedOutRequiredCell];
            }
	    if (isProjectAllowed)
            {
                NSMutableDictionary *projectDict=[firstSectionfieldsArray objectAtIndex:0];
                NSString *projectUri=[projectDict objectForKey:@"projectIdentity"];
                if (projectUri!=nil && ![projectUri isKindOfClass:[NSNull class]]&&![projectUri isEqualToString:@""])
                {
                    [cell enableRequiredCell];
                }
            }
        }
        else if ([fieldName isEqualToString:RPLocalizedString(CURRENCY, @"")])
        {
            if (isAmountDoneClicked==NO)
            {
                [cell grayedOutRequiredCell];
            }
        }
        else if ([fieldName isEqualToString:RPLocalizedString(AMOUNT, @"")]&&
                 [defaultValue isEqualToString:RPLocalizedString(ADD, @"")])
        {
            NSIndexPath *typeIndex = nil;
            if (isProjectAllowed && isClientAllowed)
            {
                if (self.canEditTask)
                {
                    typeIndex = [NSIndexPath indexPathForRow:3 inSection:EXPENSE_SECTION];
                }
                else
                {
                    typeIndex = [NSIndexPath indexPathForRow:2 inSection:EXPENSE_SECTION];
                }

            }
            else if(isProjectAllowed)
            {
                if (self.canEditTask)
                {
                    typeIndex = [NSIndexPath indexPathForRow:2 inSection:EXPENSE_SECTION];
                }
                else
                {
                    typeIndex = [NSIndexPath indexPathForRow:1 inSection:EXPENSE_SECTION];
                }
                
            }
            else
                typeIndex = [NSIndexPath indexPathForRow:0 inSection:EXPENSE_SECTION];
            
            NSString *typeValue=[[firstSectionfieldsArray objectAtIndex:typeIndex.row] objectForKey:@"defaultValue"];
            if ([typeValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
            {
                [cell grayedOutRequiredCell];
            }
        }
    }
    
    else if (indexPath.section==EXPENSE_SECTION && screenMode==EDIT_EXPENSE_ENTRY)
    {
        if ([fieldName isEqualToString:RPLocalizedString(CURRENCY, @"")])
        {
            NSString *defaultValue=[[cell dataObj] objectForKey:@"defaultValue"];
            if (isAmountDoneClicked==NO||[defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]) {
                [cell grayedOutRequiredCell];
            }
        }
        else if ([fieldName isEqualToString:RPLocalizedString(AMOUNT, @"")])
        {
            NSIndexPath *typeIndex = nil;
            if (isProjectAllowed && isClientAllowed)
            {
                if (self.canEditTask)
                {
                    typeIndex = [NSIndexPath indexPathForRow:3 inSection:EXPENSE_SECTION];
                }
                else
                {
                    typeIndex = [NSIndexPath indexPathForRow:2 inSection:EXPENSE_SECTION];
                }

            }
            else if(isProjectAllowed)
            {
                if (self.canEditTask)
                {
                    typeIndex = [NSIndexPath indexPathForRow:2 inSection:EXPENSE_SECTION];
                }
                else
                {
                    typeIndex = [NSIndexPath indexPathForRow:1 inSection:EXPENSE_SECTION];
                }
                
            }
            else
                typeIndex = [NSIndexPath indexPathForRow:0 inSection:EXPENSE_SECTION];
            
            NSString *typeValue=[[firstSectionfieldsArray objectAtIndex:typeIndex.row] objectForKey:@"defaultValue"];
            if ([typeValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
            {
                [cell grayedOutRequiredCell];
            }
        }
    }
    
    if ([[[cell dataObj] objectForKey:@"fieldType"]isEqualToString:CHECK_MARK])
    {
		if ([[[cell dataObj] objectForKey:@"fieldName"] isEqualToString: RPLocalizedString(BILL_CLIENT, @"")])
        {
            [cell.expenseSwitch setOn:[[cell.dataObj objectForKey:@"defaultValue"] isEqualToString:Check_ON_Image]];
            if ([self billClientShouldDisable])
            {
                [cell grayedOutRequiredCell];
            }
            else
            {
                [cell enableRequiredCell];
            }
        }
    }
    
    if ([[[cell dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(CURRENCY, @"")])
    {
        if ([self currencyFieldHandlings])
        {
            [cell grayedOutRequiredCell];
        }
    }

    if ((self.expenseEntryObject.expenseEntryProjectName == nil || [self.expenseEntryObject.expenseEntryProjectName isKindOfClass:[NSNull class]]) && [[[cell dataObj] objectForKey:@"fieldName"] isEqualToString:RPLocalizedString(Task, @"")]) {
        [cell grayedOutRequiredCell];
    }

    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self handleButtonClicks: indexPath];
}

-(void)alertForImageDownloadTimeOut
{
	[memoryExceedAlert show];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:@"IMAGE_DOWNLOAD_TIMEOUT" object:nil];
	if(base64Decoded !=nil)
	{
		base64Decoded=nil;
	}
	if(b64String !=nil)
	{
		b64String=nil;
	}
}

#pragma mark -
#pragma mark Picker Delegates methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	return self.view.frame.size.width;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return PICKER_ROW_HEIGHT;
}
- (NSInteger)pickerView:(UIPickerView *)pickerViews numberOfRowsInComponent:(NSInteger)component
{
    if ([dataSourceArray count]>0)
    {
        [pickerViews setUserInteractionEnabled:YES];
    }
    else
    {
        [pickerViews setUserInteractionEnabled:NO];
    }

    return [dataSourceArray count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (dataSourceArray != nil && ![dataSourceArray isKindOfClass:[NSNull class]] &&[dataSourceArray count]>0) {
        if (rowTypeSelected==TYPE_ROW)
        {
            return [[dataSourceArray objectAtIndex:row] objectForKey:@"expenseCodeName"];
        }
        else if (rowTypeSelected==CURRENCY_ROW)
        {
            return [[dataSourceArray objectAtIndex:row] objectForKey:@"currenciesName"];
        }
        else if (rowTypeSelected==PAYMENT_ROW)
        {
            return [[dataSourceArray objectAtIndex:row] objectForKey:@"paymentMethodsName"];
        }
    }
	return @"";

}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (dataSourceArray != nil && ![dataSourceArray isKindOfClass:[NSNull class]] &&[dataSourceArray count]>0) {
        if (rowTypeSelected==TYPE_ROW)
        {
            NSString *typeName=[[dataSourceArray objectAtIndex:row] objectForKey:@"expenseCodeName"];
            NSString *typeUri=[[dataSourceArray objectAtIndex:row] objectForKey:@"expenseCodeUri"];
            [self updateTypeOnPickerSelectionWithTypeName:typeName withTypeUri:typeUri];
        }
        else if (rowTypeSelected==CURRENCY_ROW)
        {
            NSString *currencyName=[[dataSourceArray objectAtIndex:row] objectForKey:@"currenciesName"];
            NSString *currencyUri=[[dataSourceArray objectAtIndex:row] objectForKey:@"currenciesUri"];
            [self updateCurrencyOnPickerSelectionWithCurrencyName:currencyName withCurrencyUri:currencyUri];
        }
        else if (rowTypeSelected==PAYMENT_ROW)
        {
            NSString *paymentName=[[dataSourceArray objectAtIndex:row] objectForKey:@"paymentMethodsName"];
            NSString *paymentUri=[[dataSourceArray objectAtIndex:row] objectForKey:@"paymentMethodsUri"];
            [self updatePaymentOnPickerSelectionWithPaymentName:paymentName withCurrencyUri:paymentUri];
        }
    }
}

#pragma mark -
#pragma mark Picker Methods

-(void)configurePicker
{
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    UIPickerView *temppickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.pickerView=temppickerView;
     CGFloat pickerYPosition = self.view.height-self.pickerView.height-self.tabBarController.tabBar.height;
	[pickerView setFrame: CGRectMake(0.0,
                                     pickerYPosition,
                                     self.view.width,
                                     self.pickerView.height)];
	pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	pickerView.delegate = self;
    pickerView.dataSource = self;
	pickerView.showsSelectionIndicator = YES;
	pickerView.hidden = YES;
	pickerView.tag=PICKER_VIEW_TAG_EXPENSE_VIEW;
	UIDatePicker *tempdatePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    self.datePicker=tempdatePicker;

    CGFloat datePickerYPosition = pickerYPosition-self.navigationController.navigationBar.height-statusBarHeight;
	[datePicker setFrame:CGRectMake(0.0,
                                    datePickerYPosition,
                                    self.pickerView.width,
                                    self.pickerView.height)];
	datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.timeZone=[NSTimeZone timeZoneForSecondsFromGMT:0];
	datePicker.hidden = YES;
	datePicker.date = [NSDate date];
	[datePicker addTarget:self action:@selector(updateDateComponent:) forControlEvents:UIControlEventValueChanged];


	UIBarButtonItem *tmpDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                   target:self
                                                                                   action:@selector(pickerDone:)];
	self.doneButton=tmpDoneButton;


	UIBarButtonItem *tmpSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:nil
                                                                                    action:nil];
	self.spaceButton=tmpSpaceButton;

	//Implementation for US8771 HandleDateUDFEmptyValue//JUHI
    UIBarButtonItem *tmpCancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                     target:self
                                                                                     action:@selector(pickerCancel:)];
    self.cancelButton=tmpCancelButton;


    //Implementation for US8771 HandleDateUDFEmptyValue//JUHI
    UIBarButtonItem *tmpClearButton = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString(@"Clear", @"Clear") style: UIBarButtonItemStylePlain target: self action: @selector(pickerClear:)];
    self.pickerClearButton=tmpClearButton;

	if (toolbar == nil) {
        toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,self.datePicker.y-Toolbar_Height,self.view.frame.size.width,Toolbar_Height)];
	}
	//Fix for ios7//JUHI
    self.doneButton.tintColor=RepliconStandardWhiteColor;
    self.cancelButton.tintColor=RepliconStandardWhiteColor;
    self.pickerClearButton.tintColor=RepliconStandardWhiteColor;
    UIImage *backgroundImage = [Util thumbnailImage:TOOLBAR_IMAGE];
    [toolbar setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
    [toolbar setTintColor:[Util colorWithHex:@"#dddddd" alpha:1]];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];

	[toolbar setTranslucent:YES];
    toolbar.hidden=YES;

	NSArray *toolArray = [NSArray arrayWithObjects:spaceButton, doneButton,nil];
	[toolbar setItems:toolArray];
    [self.view addSubview:toolbar];
	[self.view addSubview:pickerView];
    [self.view addSubview:datePicker];
}
-(void)showDataPicker:(BOOL)showDataPicker
{

    if (showDataPicker)
    {
        [self resetTableSize:YES];
        [self.toolbar setHidden:NO];
        [self.pickerView setHidden:NO];
  //      appDelegate.rootTabBarController.tabBar.hidden=TRUE;
        ExpenseModel *expenseModel=[[ExpenseModel alloc]init];
        if (rowTypeSelected==TYPE_ROW)
        {
            self.dataSourceArray=[expenseModel getExpenseCodesFromDatabase];
        }
        else if (rowTypeSelected==CURRENCY_ROW)
        {
            self.dataSourceArray=[expenseModel getSystemCurrenciesFromDatabase];
        }
        else if (rowTypeSelected==PAYMENT_ROW)
        {
            self.dataSourceArray=[expenseModel getSystemPaymentMethodFromDatabase];
        }


    }
    else
    {
        [self resetTableSize:NO];
        [self.toolbar setHidden:YES];
        [self.pickerView setHidden:YES];
//        appDelegate.rootTabBarController.tabBar.hidden=FALSE;
        [dataSourceArray removeAllObjects];
    }
}

-(void)showDatePicker:(BOOL)showDatePicker
{
    if (showDatePicker)
    {
        [self resetTableSize:YES];
        [self.toolbar setHidden:NO];
        [self.datePicker setHidden:NO];
    }
    else
    {
        [self resetTableSize:NO];
        [self.toolbar setHidden:YES];
        [self.datePicker setHidden:YES];
    }
}
-(void)pickerDone:(id)sender
{
    [self resetTableSize:NO];
    self.rowTypeSelected=INVALID_ROW;
    self.pickerView.hidden=YES;
    self.datePicker.hidden=YES;
    self.toolbar.hidden=YES;
    [expenseEntryTableView deselectRowAtIndexPath:currentIndexPath animated:YES];
    //Implementation for US8771 HandleDateUDFEmptyValue//JUHI
    NSArray *toolArray = [NSArray arrayWithObjects:spaceButton, doneButton,nil];
    [toolbar setItems:toolArray];
//    AppDelegate *appDelegate=[[UIApplication sharedApplication]delegate];
//    appDelegate.rootTabBarController.tabBar.hidden=FALSE;
}
-(void)updateDateComponent:(id)sender
{
    //Implementation for US8771 HandleDateUDFEmptyValue//JUHI
    NSString *selectedDateString=nil;
    if ([sender isKindOfClass:[NSString class]])
    {
        selectedDateString=sender;
    }
    else
        //selectedDateString=[Util convertPickerDateToString:datePicker.date];
        selectedDateString=[Util convertDateToString:datePicker.date];
    [self updateFieldAtIndex:self.currentIndexPath WithSelectedValues:selectedDateString];

    NSMutableDictionary *entryDateDict = [secondSectionfieldsArray objectAtIndex:currentIndexPath.row];
    //Fix For Enable And Disable Save Button
    if(![selectedDateString isEqualToString:[entryDateDict objectForKey:@"defaultValue"]])
    {

        self.navigationItem.rightBarButtonItem.enabled=YES;
    }
    [entryDateDict removeObjectForKey:@"defaultValue"];
    [entryDateDict setObject:selectedDateString forKey:@"defaultValue"];

    [secondSectionfieldsArray replaceObjectAtIndex:currentIndexPath.row withObject:entryDateDict];
    if ([entryDateDict objectForKey:@"fieldTypeUri"]!=nil && ![[entryDateDict objectForKey:@"fieldTypeUri"]isKindOfClass:[NSNull class]])
    {
        if (![[entryDateDict objectForKey:@"fieldTypeUri"] isEqualToString:DATE_UDF_TYPE])
        {
            [expenseEntryObject setExpenseEntryIncurredDate:datePicker.date];
        }
    }
    else
    {
        [expenseEntryObject setExpenseEntryIncurredDate:datePicker.date];
    }
}


#pragma mark -
#pragma mark HandleButtonClicks

-(void)handleButtonClicks:(NSIndexPath*)selectedButtonIndex
{
    self.currentIndexPath = [NSIndexPath indexPathForRow: selectedButtonIndex.row inSection: selectedButtonIndex.section];
    [self showDataPicker:NO];
    [self showDatePicker:NO];
    [self.expenseEntryTableView scrollToRowAtIndexPath:selectedButtonIndex atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
     [lastUsedTextField resignFirstResponder];
	ExpenseEntryCustomCell *entryCell=nil;
	entryCell = (ExpenseEntryCustomCell *)[expenseEntryTableView cellForRowAtIndexPath:selectedButtonIndex];

	if (entryCell == nil || [entryCell dataObj] == nil)	{
		return;
	}

	if([[[entryCell dataObj] objectForKey: @"fieldType"] isEqualToString:DATA_PICKER])
    {
		[self dataPickerAction: entryCell withEvent: nil];
	}
	else if([[[entryCell dataObj] objectForKey: @"fieldType"] isEqualToString:DATE_PICKER])
    {
		[self datePickerAction: entryCell withEvent:nil];
	}
	else if([[[entryCell dataObj] objectForKey: @"fieldType"] isEqualToString:MOVE_TO_NEXT_SCREEN])
    {
		[self moveToNextScreen: entryCell withEvent:nil];
	}
	else if([[[entryCell dataObj] objectForKey: @"fieldType"] isEqualToString:IMAGE_PICKER])
    {
		[self imagePicker: entryCell withEvent:nil];
	}
	else if([[[entryCell dataObj] objectForKey: @"fieldType"] isEqualToString:CHECK_MARK])
    {
		[self switchButtonHandlings:nil onIndexpathRow:nil];
	}
	else if ([[[entryCell dataObj] objectForKey: @"fieldType"] isEqualToString:NUMERIC_KEY_PAD])
    {
		[self TextAndNumericKeyPadAction: entryCell withEvent:nil];
	}
    else if ([[[entryCell dataObj] objectForKey: @"fieldType"] isEqualToString:UDFType_DROPDOWN]){
        [self dropDownOptionAction: entryCell withEvent:nil];    }
    else if ([[[entryCell dataObj] objectForKey: @"fieldType"] isEqualToString:UDFType_TEXT]){
        [self textUdfAction: entryCell withEvent:nil];
    }
	else {
		DLog(@"Error: Invalid field type");
	}
    if (screenMode == EDIT_EXPENSE_ENTRY)
    {
        [self.expenseEntryTableView scrollToRowAtIndexPath:selectedButtonIndex atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }

    
}
-(void)dropDownOptionAction:(ExpenseEntryCustomCell*)_cell withEvent:(UIEvent *)event
{
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        return;
    }

    DropDownViewController *dropDownViewCtrl=[[DropDownViewController alloc]init];
    dropDownViewCtrl.entryDelegate=self;
    NSMutableDictionary *udfDetailDict=[self.secondSectionfieldsArray objectAtIndex:currentIndexPath.row];
    dropDownViewCtrl.dropDownUri=[udfDetailDict objectForKey:@"uri"];
    [self.navigationController pushViewController:dropDownViewCtrl animated:YES];
    [expenseEntryTableView deselectRowAtIndexPath:currentIndexPath animated:YES];

}
-(void)updateDropDownFieldWithFieldName:(NSString*)fieldName andFieldURI:(NSString*)fieldUri{

    NSMutableDictionary *entryDateDict = [secondSectionfieldsArray objectAtIndex:currentIndexPath.row];

    //Implemetation For MOBI-300//JUHI
    if (fieldName!=nil && ![fieldName isKindOfClass:[NSNull class]]&&[fieldName isEqualToString:RPLocalizedString(NONE_STRING, NONE_STRING)]&& (fieldUri==nil || [fieldUri isKindOfClass:[NSNull class]]))
    {
        fieldName=RPLocalizedString(SELECT_STRING, @"");
        [entryDateDict removeObjectForKey:@"dropDownOptionUri"];
        [entryDateDict setObject:fieldUri forKey:@"dropDownOptionUri"];
    }


    //Fix For Enable And Disable Save Button
    if (![fieldName isEqualToString:[entryDateDict objectForKey:@"defaultValue"]])
    {

        self.navigationItem.rightBarButtonItem.enabled=YES;
    }
    if (fieldName!=nil && ![fieldName isKindOfClass:[NSNull class]])
    {
       [self updateFieldAtIndex:self.currentIndexPath WithSelectedValues:fieldName];
        [entryDateDict removeObjectForKey:@"defaultValue"];
        [entryDateDict setObject:fieldName forKey:@"defaultValue"];
    }
    if (fieldUri!=nil && ![fieldUri isKindOfClass:[NSNull class]])
    {
        [entryDateDict removeObjectForKey:@"dropDownOptionUri"];
        [entryDateDict setObject:fieldUri forKey:@"dropDownOptionUri"];
    }

     [secondSectionfieldsArray replaceObjectAtIndex:currentIndexPath.row withObject:entryDateDict];
}

-(void)dataPickerAction:(ExpenseEntryCustomCell*)_cell withEvent:(UIEvent *)event
{
   if (currentIndexPath.section == EXPENSE_SECTION)
    {
        NSDictionary *_rowData = [firstSectionfieldsArray objectAtIndex:currentIndexPath.row];
        NSString *fieldName=[_rowData objectForKey:@"fieldName"] ;
        NSMutableArray  *expensesArray = [_rowData objectForKey:@"dataSourceArray"];
        if ([fieldName isEqualToString:RPLocalizedString(TYPE, @"")])
        {
            if ([expensesArray count]==0)
            {
                if (![NetworkMonitor isNetworkAvailableForListener:self])
                {
                    [Util showOfflineAlert];
                    return;
                }
                else
                {
                    NSString *projectUri=nil;
                    if (isProjectAllowed)
                    {
                        NSMutableDictionary *projectDict=[firstSectionfieldsArray objectAtIndex:0];
                        projectUri=[projectDict objectForKey:@"projectIdentity"];
                    }
                    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION object:nil];
                    [[NSNotificationCenter defaultCenter] addObserver:self
                                                             selector:@selector(updateTypeAfterDownloadingExpenseTypes:)
                                                                 name:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION
                                                               object:nil];

                    //Implemented as per US8683//JUHI
                    ExpenseModel *expenseModel=[[ExpenseModel alloc]init];
                    NSMutableArray *array=[expenseModel getExpenseCodesFromDatabase];

                    if ([array count]>0)
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION object:nil];
                    }
                    else
                        [[RepliconServiceManager expenseService]fetchExpenseCodesBasedOnProjectsForExpenseSheetUri:expenseEntryObject.expenseEntryExpenseSheetUri withSearchText:@"" withProjectUri:projectUri andDelegate:self ];

                    return;
                }
            }

        }
        else if ([fieldName isEqualToString:RPLocalizedString(CURRENCY, @"")])
        {
            if ([expensesArray count]==0)
            {
                if (![NetworkMonitor isNetworkAvailableForListener:self])
                {
                    [Util showOfflineAlert];
                    return;
                }
                else
                {
                    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                                    name:CURRENCY_PAYMENTMETHOD_SUMMARY_RECIEVED_NOTIFICATION object:nil];
                    [[NSNotificationCenter defaultCenter] addObserver:self
                                                             selector:@selector(updateCurrencyAfterDownloading:)
                                                                 name:CURRENCY_PAYMENTMETHOD_SUMMARY_RECIEVED_NOTIFICATION
                                                               object:nil];
                    //Implemented as per US8683//JUHI
                    ExpenseModel *expensesModel=[[ExpenseModel alloc]init];
                    NSMutableArray *array=[expensesModel getSystemCurrenciesFromDatabase];

                    if ([array count]>0)
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:CURRENCY_PAYMENTMETHOD_SUMMARY_RECIEVED_NOTIFICATION object:nil];
                    }
                    else
                        [[RepliconServiceManager expenseService]fetchExpenseCurrencyAndPaymentMethodDatawithDelegate:self];
                    return;
                }
            }

        }

    }
    if (currentIndexPath.section == DETAILS_SECTION)
    {
        NSDictionary *_rowData = [secondSectionfieldsArray objectAtIndex:currentIndexPath.row];
        NSString *fieldName=[_rowData objectForKey:@"fieldName"] ;
        NSMutableArray  *expensesArray = [_rowData objectForKey:@"dataSourceArray"];
        if ([fieldName isEqualToString:RPLocalizedString(PAYMENT_METHOD, @"")])
        {
            //MOBI-271//JUHI
            self.previousPaymentName=[[secondSectionfieldsArray objectAtIndex:currentIndexPath.row]objectForKey:@"selectedDataSource"];
            self.previousPaymentUri=[[secondSectionfieldsArray objectAtIndex:currentIndexPath.row]objectForKey:@"selectedDataIdentity"];
            NSArray *toolArray = [NSArray arrayWithObjects:cancelButton,pickerClearButton,spaceButton,doneButton,nil];
            [toolbar setItems:toolArray];
            if ([expensesArray count]==0)
            {
                if (![NetworkMonitor isNetworkAvailableForListener:self])
                {
                    [Util showOfflineAlert];
                    return;
                }
                else
                {
                    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                                    name:CURRENCY_PAYMENTMETHOD_SUMMARY_RECIEVED_NOTIFICATION object:nil];
                    [[NSNotificationCenter defaultCenter] addObserver:self
                                                             selector:@selector(updatePaymentAfterDownloading:)
                                                                 name:CURRENCY_PAYMENTMETHOD_SUMMARY_RECIEVED_NOTIFICATION
                                                               object:nil];
                    //Implemented as per US8683//JUHI
                    ExpenseModel *expensesModel=[[ExpenseModel alloc]init];
                    NSMutableArray *array=[expensesModel getSystemPaymentMethodFromDatabase];

                    if ([array count]>0)
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:CURRENCY_PAYMENTMETHOD_SUMMARY_RECIEVED_NOTIFICATION object:nil];
                    }
                    else
                        [[RepliconServiceManager expenseService]fetchExpenseCurrencyAndPaymentMethodDatawithDelegate:self];
                    return;
                }
            }

        }

    }
}
-(void)datePickerAction:(ExpenseEntryCustomCell*)cell withEvent:(UIEvent *)event
{
    if (currentIndexPath.section == DETAILS_SECTION)
    {//Implementation for US8771 HandleDateUDFEmptyValue//JUHI
       
        if ([[[secondSectionfieldsArray objectAtIndex:currentIndexPath.row]objectForKey:@"fieldTypeUri"]isEqualToString:DATE_UDF_TYPE]){
            self.previousDateUdfValue=[[secondSectionfieldsArray objectAtIndex:currentIndexPath.row]objectForKey:@"defaultValue"];
            NSArray *toolArray = [NSArray arrayWithObjects:cancelButton,pickerClearButton,spaceButton,doneButton,nil];
            [toolbar setItems:toolArray];
        }


        //Implemented for US8763_HandleWhenDateUDFDoesNotHaveDefaultValue//JUHI
        if ([[[secondSectionfieldsArray objectAtIndex:currentIndexPath.row]objectForKey:@"defaultValue"]isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
        {
            datePicker.date=[NSDate date];
            [self updateDateComponent:self.datePicker];

        }
        else
            datePicker.date = [Util convertStringToPickerDate:[[secondSectionfieldsArray objectAtIndex:currentIndexPath.row]objectForKey:@"defaultValue"]];

        
        [self showDatePicker:YES];
        [self.expenseEntryTableView scrollToRowAtIndexPath:currentIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }

}
-(void)moveToNextScreen:(ExpenseEntryCustomCell*)entryCell withEvent:(UIEvent *)event
{
    if (currentIndexPath.section == EXPENSE_SECTION)
    {
		if([[[entryCell dataObj] objectForKey: @"fieldType"] isEqualToString:MOVE_TO_NEXT_SCREEN])
        {
            if ([entryCell.fieldName.text isEqualToString:RPLocalizedString(Client, @"")] || [entryCell.fieldName.text isEqualToString:RPLocalizedString(PROJECT, @"")] || [entryCell.fieldName.text isEqualToString:RPLocalizedString(Task, @"")])
            {
                if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
                {
                    [Util showOfflineAlert];
                }
                else
                {
                    SelectionScreenType screenType;
                    if (isClientAllowed && isProjectAllowed) {
                        if (currentIndexPath.row == 0)
                            screenType = ClientSelection;
                        else if (currentIndexPath.row == 1)
                            screenType = ProjectSelection;
                        else
                            screenType = TaskSelection;
                    }
                    else
                    {
                        if (currentIndexPath.row == 0)
                            screenType = ProjectSelection;
                        else
                            screenType = TaskSelection;
                    }
                    
                    
                    ProjectType *project;
                    ClientType *client;
                    TaskType *task;

                    client = [[ClientType alloc] initWithName:self.expenseEntryObject.expenseEntryClientName uri:self.expenseEntryObject.expenseEntryClientUri];
                    project = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:client name:self.expenseEntryObject.expenseEntryProjectName uri:self.expenseEntryObject.expenseEntryProjectUri];
                    task = [[TaskType alloc] initWithProjectUri:project.uri taskPeriod:nil name:self.expenseEntryObject.expenseEntryTaskName uri:self.expenseEntryObject.expenseEntryTaskUri];
                    
                    PunchCardObject *punchCardObject = [[PunchCardObject alloc]
                                                                         initWithClientType:client
                                                                                projectType:project
                                                                              oefTypesArray:nil
                                                                                  breakType:NULL
                                                                                   taskType:task
                                                                                   activity:NULL
                                                                                        uri:nil];

                    SelectionController *selectionController=[self.injector getInstance:InjectorKeySelectionControllerForExpensesModule];
                    [selectionController setUpWithSelectionScreenType:screenType punchCardObject:punchCardObject delegate:self];
                    [self.navigationController pushViewController:selectionController animated:YES];

                    [expenseEntryTableView deselectRowAtIndexPath:currentIndexPath animated:YES];
                }

            }
            else if ([entryCell.fieldName.text isEqualToString:RPLocalizedString(AMOUNT, @"")])
            {
                if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
                {
                    [Util showOfflineAlert];

                }
                else
                {
                    NSIndexPath *typeIndex = nil;
                    if (isProjectAllowed && isClientAllowed)
                    {
                        if (self.canEditTask)
                        {
                            typeIndex = [NSIndexPath indexPathForRow:3 inSection:EXPENSE_SECTION];
                        }
                        else
                        {
                            typeIndex = [NSIndexPath indexPathForRow:2 inSection:EXPENSE_SECTION];
                        }

                    }
                    else if(isProjectAllowed)
                    {
                        if (self.canEditTask)
                        {
                            typeIndex = [NSIndexPath indexPathForRow:2 inSection:EXPENSE_SECTION];
                        }
                        else
                        {
                            typeIndex = [NSIndexPath indexPathForRow:1 inSection:EXPENSE_SECTION];
                        }
                        
                    }
                    else
                        typeIndex = [NSIndexPath indexPathForRow:0 inSection:EXPENSE_SECTION];

                    NSString *expenseCodeUri=[[firstSectionfieldsArray objectAtIndex:typeIndex.row] objectForKey:@"selectedDataIdentity"];
                    if (![expenseSheetStatus isEqualToString:APPROVED_STATUS]&&![expenseSheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS])
                    {
                        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                                        name:EXPENSECODE_DETAILS_RECIEVED_NOTIFICATION object:nil];
                        [[NSNotificationCenter defaultCenter] addObserver:self
                                                                 selector:@selector(expenseCodeDetailsDataReceived)
                                                                     name:EXPENSECODE_DETAILS_RECIEVED_NOTIFICATION
                                                                   object:nil];

                        [[RepliconServiceManager expenseService]fetchExpenseCodesDetailsForExpenseCodeURI:expenseCodeUri andSheetUri:expenseEntryObject.expenseEntryExpenseSheetUri andProjectUri:expenseEntryObject.expenseEntryProjectUri];
                    }
                    else
                    {
                        [self fetchExpenseCodeDetailsDataFromDatabaseForNonEditableEntries];
                    }
                }
            }
	   else if ([entryCell.fieldName.text isEqualToString:RPLocalizedString(TYPE, @"")])
            {
                if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
                {
                    [Util showOfflineAlert];
                }
                else
                {
                    if (([expenseSheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||([expenseSheetStatus isEqualToString:APPROVED_STATUS ])))
                    {
                        //do nothing
                    }
                    else
                    {
                        CommonSearchViewController *tempCommonSearchViewController = [[CommonSearchViewController alloc] initWithDefaultTableViewCellStylist:self.defaultTableViewCellStylist
                                                                                                                                     repliconServiceProvider:[[RepliconServiceProvider alloc] init]
                                                                                                                                      searchTextFieldStylist:self.searchTextFieldStylist
                                                                                                                                         reachabilityMonitor:[[ReachabilityMonitor alloc] init]
                                                                                                                                             spinnerDelegate:self.spinnerDelegate];
                        NSString *projectUri=nil;
                        if (isProjectAllowed && isClientAllowed)
                        {
                            NSMutableDictionary *projectDict=[firstSectionfieldsArray objectAtIndex:1];
                            projectUri=[projectDict objectForKey:@"projectIdentity"];
                        }
                        else if (isProjectAllowed)
                        {
                            NSMutableDictionary *projectDict=[firstSectionfieldsArray objectAtIndex:0];
                            projectUri=[projectDict objectForKey:@"projectIdentity"];
                        }
                            
                        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
                        if (projectUri==nil||[projectUri isKindOfClass:[NSNull class]]||[projectUri isEqualToString:NULL_STRING])
                        {
                            projectUri=@"";
                        }
                        [dataDict setObject:projectUri forKey:@"projectIdentity"];
                        [dataDict setObject:expenseEntryObject.expenseEntryExpenseSheetUri forKey:@"expenseSheetUri"];

                        if(screenMode==EDIT_EXPENSE_ENTRY)
                        {
                            NSString *expenseTypeName=expenseEntryObject.expenseEntryExpenseCodeName;
                            if (expenseTypeName==nil||[expenseTypeName isKindOfClass:[NSNull class]]||[expenseTypeName isEqualToString:NULL_STRING])
                            {
                                expenseTypeName=@"";
                            }

                            [dataDict setObject:expenseTypeName forKey:@"expenseTypeName"];
                            [dataDict setObject:expenseSheetStatus forKey:@"expenseSheetStatus"];
                        }
                        else
                        {
                            NSString *expenseTypeName=expenseEntryObject.expenseEntryExpenseCodeName;
                            if (expenseTypeName==nil||[expenseTypeName isKindOfClass:[NSNull class]]||[expenseTypeName isEqualToString:NULL_STRING])
                            {
                                expenseTypeName=@"";
                            }
                            [dataDict setObject:expenseTypeName forKey:@"expenseTypeName"];
                            [dataDict setObject:NOT_SUBMITTED_STATUS forKey:@"expenseSheetStatus"];
                        }

                        tempCommonSearchViewController.dataDict=dataDict;
                        tempCommonSearchViewController.delegate=self;
                        tempCommonSearchViewController.screenMode=EXPENSE_TYPE_SEARCH_SCREEN;
                        [self.navigationController pushViewController:tempCommonSearchViewController animated:YES];
                        [expenseEntryTableView deselectRowAtIndexPath:currentIndexPath animated:YES];
                    }

                }
            }
        }

    }
    if (currentIndexPath.section == DETAILS_SECTION)
    {
		AddDescriptionViewController *tempaddDescriptionViewController  = [[AddDescriptionViewController alloc]init];
        self.addDescriptionViewController=tempaddDescriptionViewController;


        addDescriptionViewController.fromExpenseDescription =YES;
		[addDescriptionViewController setDescTextString:[[entryCell dataObj] objectForKey:@"defaultValue"]];
		[addDescriptionViewController setViewTitle: [[entryCell dataObj]objectForKey:@"fieldName"]];
		addDescriptionViewController.descControlDelegate=self;
		if (canNotEdit)
        {
            [addDescriptionViewController setIsNonEditable:YES];
        }
        else
        {
            [addDescriptionViewController setIsNonEditable:NO];
        }
		[self.navigationController pushViewController:addDescriptionViewController animated:YES];
        [expenseEntryTableView deselectRowAtIndexPath:currentIndexPath animated:YES];

	}
}
-(void)textUdfAction:(ExpenseEntryCustomCell*)entryCell withEvent:(UIEvent *)event{

    AddDescriptionViewController *addDescriptionViewCtrl=[[AddDescriptionViewController alloc]init];

    addDescriptionViewCtrl.fromTextUdf =YES;
    if ([[[entryCell dataObj] objectForKey:@"defaultValue"] isEqualToString:RPLocalizedString(ADD, @"")]||[[[entryCell dataObj] objectForKey:@"defaultValue"] isEqualToString:RPLocalizedString(NONE_STRING, @"")])
    {
        [addDescriptionViewCtrl setDescTextString:@""];
    }
    else
        [addDescriptionViewCtrl setDescTextString:[[entryCell dataObj] objectForKey:@"defaultValue"]];

    [addDescriptionViewCtrl setViewTitle:[[entryCell dataObj]objectForKey:@"fieldName"]];
    addDescriptionViewCtrl.descControlDelegate=self;

    if (([expenseSheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||([expenseSheetStatus isEqualToString:APPROVED_STATUS ])))
    {
        [addDescriptionViewCtrl setIsNonEditable:YES];
    }
    else
        [addDescriptionViewCtrl setIsNonEditable:NO];
    [self.navigationController pushViewController:addDescriptionViewCtrl animated:YES];
    [expenseEntryTableView deselectRowAtIndexPath:currentIndexPath animated:YES];


}
-(void)updateTextUdf:(NSString*)udfTextValue
{
    NSMutableDictionary *udfDetailDict = [secondSectionfieldsArray objectAtIndex:currentIndexPath.row];


    NSString *udfTextStr=nil;

    if (udfTextValue!=nil && ![udfTextValue isKindOfClass:[NSNull class]])
    {
        if ([udfTextValue isEqualToString:@""])
        {
            udfTextStr=RPLocalizedString(ADD, @"");
        }
        else
            udfTextStr=udfTextValue;
    }
    else
        udfTextStr=RPLocalizedString(ADD, @"");

    //Fix For Enable And Disable Save Button
    if (![udfTextStr isEqualToString:[udfDetailDict objectForKey:@"defaultValue"]])
    {

        self.navigationItem.rightBarButtonItem.enabled=YES;
    }

    [self updateFieldAtIndex:self.currentIndexPath WithSelectedValues:udfTextStr];
    [udfDetailDict removeObjectForKey:@"defaultValue"];
    [udfDetailDict setObject:udfTextStr forKey:@"defaultValue"];
    [self.secondSectionfieldsArray replaceObjectAtIndex:currentIndexPath.row withObject:udfDetailDict];

    [self.expenseEntryTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.currentIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)TextAndNumericKeyPadAction:(ExpenseEntryCustomCell*)entryCell withEvent:(UIEvent *)event
{
    self.lastUsedTextField=[entryCell fieldText];
    [self.lastUsedTextField becomeFirstResponder];
    [self resetTableSize:YES];
}


-(void)showCustomPickerIfApplicable:(UITextField *)textField {

	//[self tableViewCellUntapped:selectedIndexPath];

	NSIndexPath *indexFromField = nil;

    indexFromField = [NSIndexPath indexPathForRow:textField.tag inSection:DETAILS_SECTION];

	if (indexFromField != currentIndexPath) {
		[expenseEntryTableView deselectRowAtIndexPath:currentIndexPath animated:YES];
	}

	[self setCurrentIndexPath:indexFromField];
	[expenseEntryTableView selectRowAtIndexPath:currentIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}
-(void)imagePicker:(id)sender withEvent:(UIEvent *)event
{
    [pickerView setHidden:YES];
	[datePicker setHidden:YES];
		memoryWarnCount = 0;
	ExpenseEntryCustomCell *entryCell = (ExpenseEntryCustomCell *)[expenseEntryTableView cellForRowAtIndexPath: currentIndexPath];


	if ([[[entryCell dataObj] objectForKey:@"defaultValue"] isEqualToString:RPLocalizedString(@"Yes", @"Yes")]) {
		if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
			[expenseEntryTableView deselectRowAtIndexPath:currentIndexPath animated:TRUE];
			[Util errorAlert:@"" errorMessage:RPLocalizedString(@"This receipt cannot be viewed while offline", @"This receipt cannot be viewed while offline")];
            [self pickerDone:nil];
			return;
		}else {
			[self getReceiptImage];
		}

	}
    else {

		UIActionSheet *receiptActionSheet;
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES)
		{
			receiptActionSheet=[[UIActionSheet alloc]initWithTitle:nil delegate:self
												 cancelButtonTitle: RPLocalizedString (Cancel_Button_Title, Cancel_Button_Title)
											destructiveButtonTitle:nil
												 otherButtonTitles:RPLocalizedString (TAKE_PHOTO_BTN_TITLE, TAKE_PHOTO_BTN_TITLE),RPLocalizedString (CHOOSE_FROM_LIB_BTN_TITLE, CHOOSE_FROM_LIB_BTN_TITLE),nil];
		}
		else
		{
			receiptActionSheet=[[UIActionSheet alloc]initWithTitle: nil delegate:self
												 cancelButtonTitle: RPLocalizedString (Cancel_Button_Title, Cancel_Button_Title)
											destructiveButtonTitle: nil
												 otherButtonTitles: RPLocalizedString (CHOOSE_FROM_LIB_BTN_TITLE, CHOOSE_FROM_LIB_BTN_TITLE),nil];
		}

		[receiptActionSheet setDelegate:self];
		[receiptActionSheet setTag:RECEIPT_TAG_INDEX];
		//Fix for ios7//JUHI
         float version=[[UIDevice currentDevice].systemVersion newFloatValue];
         if (version>=7.0)
         {
             receiptActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
             [receiptActionSheet setBackgroundColor:[UIColor clearColor]];
         }
         else
         [receiptActionSheet setBackgroundColor:[UIColor redColor]];
		[receiptActionSheet setFrame:CGRectMake(0,203, 320, 280)];
        [receiptActionSheet showInView:self.view];
//		[receiptActionSheet showFromTabBar:self.tabBarController.tabBar];


	}

}

-(void)getReceiptImage{
	AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];

    ReceiptsViewController *tempreceiptViewController=[[ReceiptsViewController alloc]init];
    self.receiptViewController=tempreceiptViewController;



	[receiptViewController setReceiptURI:expenseEntryObject.expenseEntryExpenseReceiptUri];
    [receiptViewController setSheetId:expenseEntryObject.expenseEntryExpenseSheetUri];
	[receiptViewController setEntryId:expenseEntryObject.expenseEntryExpenseEntryUri];
    [receiptViewController setReceiptName:expenseEntryObject.expenseEntryExpenseReceiptName];
	if (canNotEdit) {
		[receiptViewController setCanNotDelete:YES];
	}else {
		[receiptViewController setCanNotDelete:NO];
	}

	[receiptViewController setB64String: b64String];
    [receiptViewController setReceiptFileType:self.receiptFileType];//Impelemnted for Pdf Receipt //JUHI
	[receiptViewController setInNewEntry: NO];
	[receiptViewController setRecieptDelegate: self];
	[delegate setCurrVisibleViewController: receiptViewController];


    if(screenMode==ADD_EXPENSE_ENTRY)
    {
        UINavigationController *tempnavcontroller = [[UINavigationController alloc]initWithRootViewController:self.receiptViewController];
        [self presentViewController:tempnavcontroller animated:NO completion:nil];

    }
	else
    {
        [self.navigationController pushViewController:self.receiptViewController animated:NO];
    }


    [expenseEntryTableView deselectRowAtIndexPath:currentIndexPath animated:YES];

}

-(NSData*)getBase64DecodedString:(NSString*)base64EncodedString{

	NSData *decodedString  = [Util decodeBase64WithString:base64EncodedString];
	return decodedString;
}

-(void)setDeletedFlags
{
	imageDeletePressed=YES;
	if (b64String != nil && ![b64String isKindOfClass: [NSNull class]] ) {

		b64String = nil;
	}
	[self setDescription: RPLocalizedString(@"Add", @"")];

    expenseEntryObject.expenseEntryExpenseReceiptUri=nil;
    expenseEntryObject.expenseEntryExpenseReceiptName=nil;
}

-(void)switchButtonHandlings:(NSNumber*)number onIndexpathRow:(NSNumber *)row
{
    if (number!=nil)
    {
        BOOL onSwitch = NO;
        if ([number intValue])
        {
            onSwitch=YES;
        }

        [[secondSectionfieldsArray objectAtIndex:[row intValue]] setObject:onSwitch?Check_ON_Image:Check_OFF_Image forKey:@"defaultValue"];

        NSString *fieldName=[[secondSectionfieldsArray objectAtIndex:[row intValue]] objectForKey:@"fieldName"];
        if ([fieldName isEqualToString:RPLocalizedString(BILL_CLIENT, @"")])
        {
            if (onSwitch)
            {
                //Fix For Enable And Disable Save Button
                if (![[expenseEntryObject expenseEntryBillingUri] isEqualToString:BILLABLE_EXPENSE_URI])
                {

                    self.navigationItem.rightBarButtonItem.enabled=YES;
                }
                [expenseEntryObject setExpenseEntryBillingUri:BILLABLE_EXPENSE_URI];
            }
            else
            {
                //Fix For Enable And Disable Save Button
                if (![[expenseEntryObject expenseEntryBillingUri] isEqualToString:NOT_BILLABLE_EXPENSE_URI])
                {

                    self.navigationItem.rightBarButtonItem.enabled=YES;
                }
                [expenseEntryObject setExpenseEntryBillingUri:NOT_BILLABLE_EXPENSE_URI];
            }
        }
        else if ([fieldName isEqualToString:RPLocalizedString(REIMBURSE, @"")])
        {
            if (onSwitch)
            {
                //Fix For Enable And Disable Save Button
                if (![[expenseEntryObject expenseEntryReimbursementUri] isEqualToString:REIMBURSABLE_EXPENSE_URI])
                {

                    self.navigationItem.rightBarButtonItem.enabled=YES;
                }
                [expenseEntryObject setExpenseEntryReimbursementUri:REIMBURSABLE_EXPENSE_URI];
            }
            else
            {
                //Fix For Enable And Disable Save Button
                if (![[expenseEntryObject expenseEntryReimbursementUri] isEqualToString:NOT_REIMBURSABLE_EXPENSE_URI])
                {

                    self.navigationItem.rightBarButtonItem.enabled=YES;
                }
                [expenseEntryObject setExpenseEntryReimbursementUri:NOT_REIMBURSABLE_EXPENSE_URI];
            }

        }
    }

}
#pragma mark -
#pragma mark Handling Methods

-(void)disableAllFieldsForWaitingSheets:(ExpenseEntryCustomCell*)cellObj
{
    NSString *fieldName=[[cell dataObj] objectForKey:@"fieldName"];
    if (![fieldName isEqualToString:RPLocalizedString(AMOUNT, @"")])
    {
        if([[[cellObj dataObj] objectForKey:@"fieldType"]isEqualToString:IMAGE_PICKER] &&
           ! [[[cellObj dataObj] objectForKey:@"defaultValue"] isEqualToString:RPLocalizedString(ADD, @"")]&&! [[[cellObj dataObj] objectForKey:@"defaultValue"] isEqualToString:RPLocalizedString(NONE_STRING, @"")] )
        {
            [cellObj setUserInteractionEnabled:YES];
            [saveButton setEnabled:NO];
            [footerView setHidden:YES];
            [cellObj enableRequiredCell];
        }
        else if ([[[cellObj dataObj] objectForKey:@"fieldType"]isEqualToString:MOVE_TO_NEXT_SCREEN] &&
                 ! [[[cellObj dataObj] objectForKey:@"defaultValue"] isEqualToString:RPLocalizedString(ADD, @"")]&&! [[[cellObj dataObj] objectForKey:@"defaultValue"] isEqualToString:RPLocalizedString(NONE_STRING, @"")]&&! [fieldName isEqualToString:RPLocalizedString(Project, @"")] && ! [fieldName isEqualToString:RPLocalizedString(Client, @"")] && ! [fieldName isEqualToString:RPLocalizedString(Task, @"")] && ! [fieldName isEqualToString:RPLocalizedString(TYPE, @"")])
        {
            [cellObj setUserInteractionEnabled:YES];
            [saveButton setEnabled:NO];
            [footerView setHidden:YES];
            [cellObj enableRequiredCell];
        }
        else if ([[[cellObj dataObj] objectForKey:@"fieldType"]isEqualToString:UDFType_TEXT] &&
                 ! [[[cellObj dataObj] objectForKey:@"defaultValue"] isEqualToString:RPLocalizedString(ADD, @"")]&&! [[[cellObj dataObj] objectForKey:@"defaultValue"] isEqualToString:RPLocalizedString(NONE_STRING, @"")])
        {
            [cellObj setUserInteractionEnabled:YES];
            [saveButton setEnabled:NO];
            [footerView setHidden:YES];
            [cellObj enableRequiredCell];
        }
        else if ([[[cell dataObj] objectForKey:@"fieldType"]isEqualToString:CHECK_MARK])
        {
            if ([[cell.dataObj objectForKey:@"defaultValue"] isEqualToString:Check_OFF_Image])
            {
                [cellObj.expenseSwitch setOn:NO];
            }
            else
            {
                [cellObj.expenseSwitch setOn:YES];
            }
            [cellObj.expenseSwitch setUserInteractionEnabled:NO];
            [cellObj setUserInteractionEnabled:NO];
            [saveButton setEnabled:NO];
            [footerView setHidden:YES];
            [cellObj grayedOutRequiredCell];
        }
        else
        {
            [cellObj setUserInteractionEnabled:NO];
            [saveButton setEnabled:NO];
            [footerView setHidden:YES];
            [cellObj grayedOutRequiredCell];
        }

    }
	[self.navigationItem setRightBarButtonItem:nil animated:NO];
}

-(BOOL)currencyFieldHandlings
{
    return YES;

}

#pragma mark -
#pragma mark Selection Handling Methods

-(void)updateFieldWithClient:(NSString*)client clientUri:(NSString*)clientUri project:(NSString *)projectname projectUri:(NSString *)projectUri task:(NSString*)taskName andTaskUri:(NSString*)taskUri taskPermission:(BOOL)hasTaskPermission timeAllowedPermission:(BOOL)hasTimeAllowedPermission
{
    NSString *clientProject=@"";
    NSString *tempClient=[NSString stringWithFormat:@"%@",client];
    if ([tempClient isKindOfClass:[NSNull class]]||client==nil||[tempClient isEqualToString:@""])
    {
        clientProject=[NSString stringWithFormat:@"%@",projectname];
    }
    else
    {
        if (self.isClientAllowed)
        {
            clientProject=[NSString stringWithFormat:@"%@ / %@",client,projectname];
        }
        else
        {
            clientProject=[NSString stringWithFormat:@"%@",projectname];
        }
    }
    if (isProjectAllowed)
    {
        //Fix for defect DE16375
        NSString *projectName=[NSString stringWithFormat:@"%@",clientProject];
        NSString *projectIdentity=nil;
        if (projectUri!=nil)
        {
            projectIdentity=[NSString stringWithFormat:@"%@",projectUri];
        }
        NSMutableDictionary *projectClientDict = [NSMutableDictionary dictionary];
        [projectClientDict setObject:RPLocalizedString(PROJECT, @"") forKey:@"fieldName"];
        [projectClientDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
        if (projectIdentity!=nil)
        {
            [projectClientDict setObject:projectIdentity forKey: @"projectIdentity"];
        }
        else
        {
            [projectClientDict setObject:[NSNull null] forKey: @"projectIdentity"];
        }

        [projectClientDict setObject:projectName forKey: @"defaultValue"];
        [firstSectionfieldsArray replaceObjectAtIndex:0 withObject:projectClientDict];
    }

    if ([projectname isEqualToString:RPLocalizedString(NONE_STRING, @"")])
    {
        for (int k=0; k<[secondSectionfieldsArray count]; k++)
        {
            NSString *fieldName=[[secondSectionfieldsArray objectAtIndex:k] objectForKey:@"fieldName"];
            if ([fieldName isEqualToString:RPLocalizedString(BILL_CLIENT, @"")])
            {
                NSIndexPath *billClientIndexPath=[NSIndexPath indexPathForRow:k inSection:DETAILS_SECTION];
                ExpenseEntryCustomCell *billClientCell=(ExpenseEntryCustomCell *) [self.expenseEntryTableView cellForRowAtIndexPath:billClientIndexPath];
                [billClientCell grayedOutRequiredCell];
                [billClientCell.expenseSwitch setUserInteractionEnabled:NO];
                [billClientCell.expenseSwitch setOn:NO];
                [expenseEntryObject setExpenseEntryBillingUri:NOT_BILLABLE_EXPENSE_URI];

            }
        }
    }
    else
    {
        for (int k=0; k<[secondSectionfieldsArray count]; k++)
        {
            NSString *fieldName=[[secondSectionfieldsArray objectAtIndex:k] objectForKey:@"fieldName"];
            if ([fieldName isEqualToString:RPLocalizedString(BILL_CLIENT, @"")])
            {
                NSIndexPath *billClientIndexPath=[NSIndexPath indexPathForRow:k inSection:DETAILS_SECTION];
                ExpenseEntryCustomCell *billClientCell=(ExpenseEntryCustomCell *) [self.expenseEntryTableView cellForRowAtIndexPath:billClientIndexPath];
                [billClientCell enableRequiredCell];
                [billClientCell.expenseSwitch setUserInteractionEnabled:YES];
            }
        }

    }
    
    NSString *previousExpenseProjectName = [expenseEntryObject expenseEntryProjectName];
    if (previousExpenseProjectName != nil && ![previousExpenseProjectName isKindOfClass:[NSNull class]]) {
        if (![projectname isEqualToString:previousExpenseProjectName])
            self.navigationItem.rightBarButtonItem.enabled=YES;
    }
    
    [expenseEntryObject setExpenseEntryProjectName:projectname];
    [expenseEntryObject setExpenseEntryProjectUri:projectUri];
    [self updateFieldAtIndex:self.currentIndexPath WithSelectedValues:clientProject];

    //Enable Type Field and default to select
    NSIndexPath *typeIndex = nil;
    if (isProjectAllowed && isClientAllowed)
    {
        if (self.canEditTask)
        {
            typeIndex = [NSIndexPath indexPathForRow:3 inSection:EXPENSE_SECTION];
        }
        else
        {
            typeIndex = [NSIndexPath indexPathForRow:2 inSection:EXPENSE_SECTION];
        }

    }
    else if(isProjectAllowed)
    {
        if (self.canEditTask)
        {
            typeIndex = [NSIndexPath indexPathForRow:2 inSection:EXPENSE_SECTION];
        }
        else
        {
            typeIndex = [NSIndexPath indexPathForRow:1 inSection:EXPENSE_SECTION];
        }

    }
    else
        typeIndex = [NSIndexPath indexPathForRow:0 inSection:EXPENSE_SECTION];

    [self updateFieldAtIndex:typeIndex WithSelectedValues:RPLocalizedString(SELECT, @"")];
    [[firstSectionfieldsArray objectAtIndex:typeIndex.row] setObject:RPLocalizedString(SELECT, @"") forKey:@"defaultValue"];
    NSIndexPath *typeIndexpath=[NSIndexPath indexPathForRow:typeIndex.row inSection:EXPENSE_SECTION];
    ExpenseEntryCustomCell *typeCell=(ExpenseEntryCustomCell *) [self.expenseEntryTableView cellForRowAtIndexPath:typeIndexpath];
    [typeCell enableRequiredCell];

     [expenseEntryObject setExpenseEntryExpenseCodeName:@""];

    //Disable Amount Field and default to add

    NSIndexPath *amountIndex = nil;
    if (isProjectAllowed && isClientAllowed)
    {
        if (self.canEditTask)
        {
            amountIndex = [NSIndexPath indexPathForRow:4 inSection:EXPENSE_SECTION];
        }
        else
        {
            amountIndex = [NSIndexPath indexPathForRow:3 inSection:EXPENSE_SECTION];
        }
    }

    else if(isProjectAllowed)
    {
        if (self.canEditTask)
        {
            amountIndex = [NSIndexPath indexPathForRow:3 inSection:EXPENSE_SECTION];
        }
        else
        {
            amountIndex = [NSIndexPath indexPathForRow:2 inSection:EXPENSE_SECTION];
        }
    }

    else
        amountIndex = [NSIndexPath indexPathForRow:1 inSection:EXPENSE_SECTION];
    [self updateFieldAtIndex:amountIndex WithSelectedValues:RPLocalizedString(ADD, @"")];
    [[firstSectionfieldsArray objectAtIndex:amountIndex.row] setObject:RPLocalizedString(ADD, @"") forKey:@"defaultValue"];
    NSIndexPath *amountIndexpath=[NSIndexPath indexPathForRow:amountIndex.row inSection:EXPENSE_SECTION];
    ExpenseEntryCustomCell *amountCell=(ExpenseEntryCustomCell *) [self.expenseEntryTableView cellForRowAtIndexPath:amountIndexpath];
    [amountCell grayedOutRequiredCell];

    //Disable Currency Field and default to None
    //Implemented as per US7626
    if (screenMode==ADD_EXPENSE_ENTRY)
    {
        if (self.baseCurrencyName!=nil && ![self.baseCurrencyName isKindOfClass:[NSNull class]])
        {
            [[firstSectionfieldsArray objectAtIndex:amountIndexpath.row] setObject:self.baseCurrencyName forKey:@"currencyName"];
        }
        else
        {
            [[firstSectionfieldsArray objectAtIndex:amountIndexpath.row] setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"currencyName"];
        }
    }
    else
    {
        [[firstSectionfieldsArray objectAtIndex:amountIndexpath.row] setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"currencyName"];
    }

    [self.expenseEntryTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:self.currentIndexPath,typeIndex, nil] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)updateFieldWithFieldName:(NSString*)fieldName andFieldURI:(NSString*)fieldUri
{

}

-(void)updateTypeAfterDownloadingExpenseTypes: (id)notificationObject
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EXPENSECODE_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    
    self.rowTypeSelected=TYPE_ROW;
    [self showDataPicker:YES];
    [self.pickerView reloadAllComponents];
    
    NSIndexPath *typeIndex = nil;
    if (isProjectAllowed && isClientAllowed)
    {
        if (self.canEditTask)
        {
            typeIndex = [NSIndexPath indexPathForRow:3 inSection:EXPENSE_SECTION];
        }
        else
        {
            typeIndex = [NSIndexPath indexPathForRow:2 inSection:EXPENSE_SECTION];
        }

    }
    else if(isProjectAllowed)
    {
        if (self.canEditTask)
        {
            typeIndex = [NSIndexPath indexPathForRow:2 inSection:EXPENSE_SECTION];
        }
        else
        {
            typeIndex = [NSIndexPath indexPathForRow:1 inSection:EXPENSE_SECTION];
        }

    }
    else
        typeIndex = [NSIndexPath indexPathForRow:0 inSection:EXPENSE_SECTION];
    
    ExpenseEntryCustomCell *currencyCell=(ExpenseEntryCustomCell *) [self.expenseEntryTableView cellForRowAtIndexPath:typeIndex];
    NSString *defaultTypeName=currencyCell.fieldButton.text;
    int selProjIndex = [Util getObjectIndex:self.dataSourceArray withKey:@"expenseCodeName" forValue:defaultTypeName];

    if(selProjIndex > -1)
    {
        [self pickerView:pickerView didSelectRow:selProjIndex inComponent:0];
    }
    else
    {
        if([dataSourceArray count]>0)
        {
            [self pickerView:pickerView didSelectRow:0 inComponent:0];
        }
    }

    if([dataSourceArray count]>0)
    {
        NSIndexPath *amountIndexapth = nil;
        if (isProjectAllowed && isClientAllowed)
            amountIndexapth = [NSIndexPath indexPathForRow:4 inSection:EXPENSE_SECTION];
        else if (isProjectAllowed)
            amountIndexapth = [NSIndexPath indexPathForRow:3 inSection:EXPENSE_SECTION];
        else
            amountIndexapth = [NSIndexPath indexPathForRow:1 inSection:EXPENSE_SECTION];
        
        ExpenseEntryCustomCell *amountCell=(ExpenseEntryCustomCell *) [self.expenseEntryTableView cellForRowAtIndexPath:amountIndexapth];
        [amountCell enableRequiredCell];
    }
}

-(void)updateTypeOnPickerSelectionWithTypeName:(NSString *)typeName withTypeUri:(NSString *)typeUri
{

    NSIndexPath *typeIndex = nil;
    if (isProjectAllowed && isClientAllowed)
    {
        if (self.canEditTask)
        {
            typeIndex = [NSIndexPath indexPathForRow:3 inSection:EXPENSE_SECTION];
        }
        else
        {
            typeIndex = [NSIndexPath indexPathForRow:2 inSection:EXPENSE_SECTION];
        }

    }
    else if(isProjectAllowed)
    {
        if (self.canEditTask)
        {
            typeIndex = [NSIndexPath indexPathForRow:2 inSection:EXPENSE_SECTION];
        }
        else
        {
            typeIndex = [NSIndexPath indexPathForRow:1 inSection:EXPENSE_SECTION];
        }

    }
    else
        typeIndex = [NSIndexPath indexPathForRow:0 inSection:EXPENSE_SECTION];
    
    if (![typeName isEqualToString:[expenseEntryObject expenseEntryExpenseCodeName]])
    {
        self.navigationItem.rightBarButtonItem.enabled=YES;
    }
    
    [expenseEntryObject setExpenseEntryExpenseCodeName:typeName];
    [expenseEntryObject setExpenseEntryExpenseCodeUri:typeUri];

    int selProjIndex = [Util getObjectIndex:self.dataSourceArray withKey:@"expenseCodeName" forValue:typeName];
    if(selProjIndex > -1)
    {
        [pickerView selectRow: selProjIndex inComponent:0 animated: NO];
    }
    else
    {
        selProjIndex=0;
        [pickerView selectRow: 0 inComponent:0 animated: NO];
    }
    NSString *defaultTypeName=[[firstSectionfieldsArray objectAtIndex:typeIndex.row] objectForKey:@"defaultValue"];
    if ([defaultTypeName isEqualToString:typeName])
    {
        [self updateFieldAtIndex:typeIndex WithSelectedValues:typeName];
        return;
    }

    NSNumber *selectedTypeIndex = [NSNumber numberWithInt:selProjIndex];
    NSMutableDictionary *expenseTypeDict=[NSMutableDictionary dictionary];
    [expenseTypeDict setObject:RPLocalizedString(TYPE, @"") forKey:@"fieldName"];
    [expenseTypeDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
    [expenseTypeDict setObject:typeName forKey:@"defaultValue"];
    [expenseTypeDict setObject:selectedTypeIndex forKey:@"selectedIndex"];
    [expenseTypeDict setObject:typeUri forKey:@"selectedDataIdentity"];
    [expenseTypeDict setObject:[NSArray array] forKey:@"dataSourceArray"];
    [expenseTypeDict setObject:typeName forKey:@"selectedDataSource"];
    [firstSectionfieldsArray replaceObjectAtIndex:typeIndex.row withObject:expenseTypeDict];
    NSIndexPath *typeIndexpath=[NSIndexPath indexPathForRow:typeIndex.row inSection:EXPENSE_SECTION];
    ExpenseEntryCustomCell *customCell=(ExpenseEntryCustomCell *) [self.expenseEntryTableView cellForRowAtIndexPath:typeIndexpath];
    [customCell enableRequiredCell];
    [self updateFieldAtIndex:typeIndex WithSelectedValues:typeName];

    NSIndexPath *amountIndex = nil;
    if (isProjectAllowed && isClientAllowed)
    {
        if (self.canEditTask)
        {
            amountIndex = [NSIndexPath indexPathForRow:4 inSection:EXPENSE_SECTION];
        }
        else
        {
            amountIndex = [NSIndexPath indexPathForRow:3 inSection:EXPENSE_SECTION];
        }
    }

    else if(isProjectAllowed)
    {
        if (self.canEditTask)
        {
            amountIndex = [NSIndexPath indexPathForRow:3 inSection:EXPENSE_SECTION];
        }
        else
        {
            amountIndex = [NSIndexPath indexPathForRow:2 inSection:EXPENSE_SECTION];
        }
    }

    else
        amountIndex = [NSIndexPath indexPathForRow:1 inSection:EXPENSE_SECTION];

    if (screenMode==ADD_EXPENSE_ENTRY)
    {
        if (self.baseCurrencyName!=nil && ![self.baseCurrencyName isKindOfClass:[NSNull class]])
        {
            [[firstSectionfieldsArray objectAtIndex:amountIndex.row] setObject:self.baseCurrencyName forKey:@"currencyName"];
        }
        else
        {
            [[firstSectionfieldsArray objectAtIndex:amountIndex.row] setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"currencyName"];
        }
    }
    else
    {
        [[firstSectionfieldsArray objectAtIndex:amountIndex.row] setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"currencyName"];
    }

    [self updateFieldAtIndex:amountIndex WithSelectedValues:RPLocalizedString(ADD, @"")];
    [[firstSectionfieldsArray objectAtIndex:amountIndex.row] setObject:RPLocalizedString(ADD, @"") forKey:@"defaultValue"];
    NSIndexPath *amountIndexpath=[NSIndexPath indexPathForRow:amountIndex.row inSection:EXPENSE_SECTION];
    ExpenseEntryCustomCell *amountCell=(ExpenseEntryCustomCell *) [self.expenseEntryTableView cellForRowAtIndexPath:amountIndexpath];
    [amountCell enableRequiredCell];

    self.isTypeChanged=YES;
    self.isAmountDoneClicked=NO;
    ExpenseModel *expenseModel=[[ExpenseModel alloc]init];
    NSArray *taxCodeArray=[expenseModel getAllExpenseTaxCodesFromDB];
    NSArray *taxCodeDetails=[expenseModel getAllDetailsForExpenseCodeFromDB];
    NSMutableArray *incurredAmountTaxesArray=[NSMutableArray array];
    for (int i=0; i<[taxCodeArray count]; i++)
    {
        NSMutableDictionary *tempIncurredAmountDict=[NSMutableDictionary dictionary];
        [tempIncurredAmountDict setObject:@"0.00" forKey:@"taxAmount"];
        [tempIncurredAmountDict setObject:@"" forKey:@"taxCurrencyName"];
        [tempIncurredAmountDict setObject:@""  forKey:@"taxCurrencyUri"];
        [tempIncurredAmountDict setObject:[[taxCodeArray objectAtIndex:i] objectForKey:@"uri"] forKey:@"taxCodeUri"];
        [incurredAmountTaxesArray addObject:tempIncurredAmountDict];
    }
    ;
    [expenseEntryObject setExpenseEntryQuantity:nil];
    [expenseEntryObject setExpenseEntryIncurredAmountNet:@"0.00"];
    [expenseEntryObject setExpenseEntryIncurredAmountTotal:@"0.00"];
    [expenseEntryObject setExpenseEntryIncurredTaxesArray:incurredAmountTaxesArray];
    [expenseEntryObject setExpenseEntryRateCurrencyName:[[taxCodeDetails objectAtIndex:0] objectForKey:@"expenseCodeCurrencyName"]];
    [expenseEntryObject setExpenseEntryRateCurrencyUri:[[taxCodeDetails objectAtIndex:0] objectForKey:@"expenseCodeCurrencyUri"]];
    [expenseEntryObject setExpenseEntryRateAmount:nil];

    if (screenMode==ADD_EXPENSE_ENTRY)
    {
        [expenseEntryObject setExpenseEntryIncurredAmountNetCurrencyName:nil];
    }

 [self.expenseEntryTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:typeIndex] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)updateCurrencyAfterDownloading:(id)notificationObject
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:CURRENCY_PAYMENTMETHOD_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    //Implemented as per US8683//JUHI
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    self.rowTypeSelected=CURRENCY_ROW;
    [self showDataPicker:YES];
    [self.pickerView reloadAllComponents];

    NSIndexPath *currencyIndex = [NSIndexPath indexPathForRow:currentIndexPath.row inSection:DETAILS_SECTION];

    NSString *defaultCurrencyName=[[firstSectionfieldsArray objectAtIndex:currencyIndex.row] objectForKey:@"defaultValue"];
    int selProjIndex = [Util getObjectIndex:self.dataSourceArray withKey:@"currenciesName" forValue:defaultCurrencyName];
    if(selProjIndex > -1 )
    {
        [self pickerView:pickerView didSelectRow:selProjIndex inComponent:0];
    }
    else
    {
        if([dataSourceArray count]>0)
        {
            [self pickerView:pickerView didSelectRow:0 inComponent:0];
        }
    }
}

-(void)updateCurrencyOnPickerSelectionWithCurrencyName:(NSString *)currencyName withCurrencyUri:(NSString *)currencyUri
{
    //Implemented as per US7626
	NSIndexPath *currencyIndex = nil;
    if (isProjectAllowed && isClientAllowed)
        currencyIndex = [NSIndexPath indexPathForRow:3 inSection:EXPENSE_SECTION];
    else if (isProjectAllowed)
        currencyIndex = [NSIndexPath indexPathForRow:2 inSection:EXPENSE_SECTION];
    else
        currencyIndex = [NSIndexPath indexPathForRow:0 inSection:EXPENSE_SECTION];

    int selProjIndex = [Util getObjectIndex:self.dataSourceArray withKey:@"currenciesName" forValue:currencyName];
    if(selProjIndex > -1)
    {
        [pickerView selectRow: selProjIndex inComponent:0 animated: NO];
    }
    else
    {
        selProjIndex=0;
    }

    NSNumber *selectedCurrencyIndex = [NSNumber numberWithInt:selProjIndex];
    NSMutableDictionary *currencyDict=[firstSectionfieldsArray objectAtIndex:currencyIndex.row];

    [currencyDict removeObjectForKey:@"currencyName"];
    [currencyDict removeObjectForKey:@"selectedIndex"];
    [currencyDict removeObjectForKey:@"selectedDataIdentity"];
    [currencyDict removeObjectForKey:@"dataSourceArray"];
    [currencyDict removeObjectForKey:@"selectedDataSource"];

    [currencyDict setObject:currencyName forKey:@"currencyName"];
    [currencyDict setObject:selectedCurrencyIndex forKey:@"selectedIndex"];
    [currencyDict setObject:currencyUri forKey:@"selectedDataIdentity"];
    [currencyDict setObject:self.dataSourceArray forKey:@"dataSourceArray"];
    [currencyDict setObject:currencyName forKey:@"selectedDataSource"];

    [firstSectionfieldsArray replaceObjectAtIndex:currencyIndex.row withObject:currencyDict];

    [expenseEntryObject setExpenseEntryIncurredAmountNetCurrencyName:currencyName];
    [expenseEntryObject setExpenseEntryIncurredAmountNetCurrencyUri:currencyUri];
}

-(void)updatePaymentAfterDownloading:(id)notificationObject
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:CURRENCY_PAYMENTMETHOD_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    
    self.rowTypeSelected=PAYMENT_ROW;
    [self showDataPicker:YES];
    [self.pickerView reloadAllComponents];

    NSIndexPath *paymentIndex = [NSIndexPath indexPathForRow:currentIndexPath.row inSection:DETAILS_SECTION];

    NSString *defaultPaymentName=[[secondSectionfieldsArray objectAtIndex:paymentIndex.row] objectForKey:@"defaultValue"];
    int selProjIndex = [Util getObjectIndex:self.dataSourceArray withKey:@"paymentMethodsName" forValue:defaultPaymentName];
    if (selProjIndex > -1)
    {
        [self pickerView:pickerView didSelectRow:selProjIndex inComponent:0];
    }
    else
    {
        if ([dataSourceArray count]>0)
        {
           [self pickerView:pickerView didSelectRow:0 inComponent:0];
        }
    }
}

-(void)updatePaymentOnPickerSelectionWithPaymentName:(NSString *)paymentName withCurrencyUri:(NSString *)paymentUri
{
	NSIndexPath *paymentIndex = [NSIndexPath indexPathForRow:currentIndexPath.row inSection:DETAILS_SECTION];
    int selProjIndex = [Util getObjectIndex:self.dataSourceArray withKey:@"paymentMethodsName" forValue:paymentName];
    if(selProjIndex > -1)
    {
        [pickerView selectRow: selProjIndex inComponent:0 animated: NO];
    }
    else
    {
        selProjIndex=0;
    }
    //Fix For Enable And Disable Save Button
    NSString *expenseEntryPaymentMethodName = [expenseEntryObject expenseEntryPaymentMethodName];
    if (expenseEntryPaymentMethodName != nil && ![expenseEntryPaymentMethodName isKindOfClass:[NSNull class]]) {
    if (![paymentName isEqualToString:[expenseEntryObject expenseEntryPaymentMethodName]])
    {

        self.navigationItem.rightBarButtonItem.enabled=YES;
    }
    }
    [expenseEntryObject setExpenseEntryPaymentMethodName:paymentName];
    [expenseEntryObject setExpenseEntryPaymentMethodUri:paymentUri];

    NSNumber *selectedPaymentIndex = [NSNumber numberWithInt:selProjIndex];
    NSMutableDictionary *paymentDict=[NSMutableDictionary dictionary];
    [paymentDict setObject:RPLocalizedString(PAYMENT_METHOD, @"") forKey:@"fieldName"];
    [paymentDict setObject:DATA_PICKER forKey:@"fieldType"];
    [paymentDict setObject:paymentName forKey:@"defaultValue"];
    [paymentDict setObject:selectedPaymentIndex forKey:@"selectedIndex"];
    [paymentDict setObject:paymentUri forKey:@"selectedDataIdentity"];
    [paymentDict setObject:self.dataSourceArray forKey:@"dataSourceArray"];
    [paymentDict setObject:paymentName forKey:@"selectedDataSource"];

    [secondSectionfieldsArray replaceObjectAtIndex:paymentIndex.row withObject:paymentDict];

    [self updateFieldAtIndex:paymentIndex WithSelectedValues:paymentName];
}

#pragma mark - <SelectionControllerDelegate>

-(void)selectionController:(SelectionController *)selectionController didChooseClient:(ClientType *)client
{
    NSString *clientName = client.name;
    NSString *defaultClientName = firstSectionfieldsArray[0][@"defaultValue"];
    BOOL hasDefaultValue =  [defaultClientName isEqualToString:RPLocalizedString(NONE_STRING, @"")] || [defaultClientName isEqualToString:RPLocalizedString(SELECT, @"")];
    NSString *clientValue = self.expenseEntryObject.expenseEntryClientName;
    BOOL isPreviousValueNil = clientValue == nil || [clientValue isKindOfClass:[NSNull class]];
    BOOL isSelectedValueNotNil = clientName != nil && ![clientName isKindOfClass:[NSNull class]];
    BOOL firstTimeSelection  = isPreviousValueNil && isSelectedValueNotNil;
    BOOL changingPreviousValue = !isPreviousValueNil && isSelectedValueNotNil && ![clientName isEqualToString:clientValue];
    
    if (firstTimeSelection  || changingPreviousValue || (isSelectedValueNotNil && hasDefaultValue)) {
            NSMutableDictionary *projectDict = firstSectionfieldsArray[1];
            [projectDict setObject:[NSNull null] forKey: @"projectIdentity"];
            [projectDict setObject:RPLocalizedString(NONE_STRING, @"") forKey: @"defaultValue"];
            
            NSMutableDictionary *taskDict = firstSectionfieldsArray[2];
            [taskDict setObject:[NSNull null] forKey: @"taskIdentity"];
            [taskDict setObject:RPLocalizedString(NONE_STRING, @"") forKey: @"defaultValue"];
            
            if (isProjectRequired) {
                [projectDict setObject:RPLocalizedString(SELECT, @"") forKey: @"defaultValue"];
                [taskDict setObject:RPLocalizedString(NONE_STRING, @"") forKey: @"defaultValue"];
            }
            [firstSectionfieldsArray replaceObjectAtIndex:1 withObject:projectDict];
            if (self.canEditTask)
            {
                [firstSectionfieldsArray replaceObjectAtIndex:2 withObject:taskDict];
            }

            
            self.expenseEntryObject.expenseEntryProjectName = nil;
            self.expenseEntryObject.expenseEntryProjectUri = nil;
            self.expenseEntryObject.expenseEntryTaskName = nil;
            self.expenseEntryObject.expenseEntryTaskUri = nil;
        
            [self.expenseEntryTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:EXPENSE_SECTION], nil] withRowAnimation:UITableViewRowAnimationNone];
        if (self.canEditTask)
            {
                [self.expenseEntryTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:EXPENSE_SECTION], nil] withRowAnimation:UITableViewRowAnimationNone];
            }
    }
    
        
    self.navigationItem.rightBarButtonItem.enabled=YES;
    
    if (isSelectedValueNotNil) {
        NSMutableDictionary *clientDict = [NSMutableDictionary dictionary];
        [clientDict setObject:RPLocalizedString(Client, @"") forKey:@"fieldName"];
        [clientDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
        if (client.uri!=nil)
            [clientDict setObject:client.uri forKey: @"clientIdentity"];
        else
            [clientDict setObject:[NSNull null] forKey: @"clientIdentity"];
        
        if (client.name!=nil)
            [clientDict setObject:client.name forKey: @"defaultValue"];
        else
            [clientDict setObject:RPLocalizedString(NONE_STRING, @"") forKey: @"defaultValue"];
        
        [firstSectionfieldsArray replaceObjectAtIndex:0 withObject:clientDict];
        
        
        self.expenseEntryObject.expenseEntryClientName = client.name;
        self.expenseEntryObject.expenseEntryClientUri = client.uri;
        
        [self.expenseEntryTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:EXPENSE_SECTION], nil] withRowAnimation:UITableViewRowAnimationNone];
        
        NSString *defaultString = RPLocalizedString(@"None", @"");
        if (isProjectRequired)
        {
            defaultString = RPLocalizedString(@"Select", @"");
        }
        
        ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:defaultString uri:nil];
        [self selectionController:nil didChooseProject:project];
    }
}

- (void)displayBillClientBasedOnProjectBillability:(ProjectType *)project {
    
    for (int k=0; k<[secondSectionfieldsArray count]; k++)
    {
        NSString *fieldName=[[secondSectionfieldsArray objectAtIndex:k] objectForKey:@"fieldName"];
        if ([fieldName isEqualToString:RPLocalizedString(BILL_CLIENT, @"")])
        {
            NSIndexPath *billClientIndexPath=[NSIndexPath indexPathForRow:k inSection:DETAILS_SECTION];
            ExpenseEntryCustomCell *billClientCell=(ExpenseEntryCustomCell *) [self.expenseEntryTableView cellForRowAtIndexPath:billClientIndexPath];
            
            if([self shouldDisableBillClientForProject:project]) {
                [billClientCell grayedOutRequiredCell];
                [billClientCell.expenseSwitch setUserInteractionEnabled:NO];
                [billClientCell.expenseSwitch setOn:NO];
                [expenseEntryObject setExpenseEntryBillingUri:NOT_BILLABLE_EXPENSE_URI];
            }
            else {
                [billClientCell enableRequiredCell];
                [billClientCell.expenseSwitch setUserInteractionEnabled:YES];
                if([project.client.uri isEqualToString:ClientTypeNoClientUri]){
                    [expenseEntryObject setExpenseEntryBillingUri:NOT_BILLABLE_EXPENSE_URI];
                }else{
                    [expenseEntryObject setExpenseEntryBillingUri:BILLABLE_EXPENSE_URI];
                }
            }

        }
    }
}

-(void)selectionController:(SelectionController *)selectionController didChooseProject:(ProjectType *)project
{
    NSInteger index = 0;
    if (isClientAllowed)
        index = 1;
    
    NSString *projectname = project.name;
    NSMutableDictionary *projectDict = [NSMutableDictionary dictionary];
    [projectDict setObject:RPLocalizedString(PROJECT, @"") forKey:@"fieldName"];
    [projectDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
    
    if (project.uri!=nil)
        [projectDict setObject:project.uri forKey: @"projectIdentity"];
    else
        [projectDict setObject:[NSNull null] forKey: @"projectIdentity"];
    
    if (project.name!=nil)
        [projectDict setObject:project.name forKey: @"defaultValue"];
    else
        [projectDict setObject:RPLocalizedString(NONE_STRING, @"") forKey: @"defaultValue"];
    
    [firstSectionfieldsArray replaceObjectAtIndex:index withObject:projectDict];

    [self displayBillClientBasedOnProjectBillability:project];
    
    if (self.expenseEntryObject.expenseEntryProjectName != nil && ![self.expenseEntryObject.expenseEntryProjectName isKindOfClass:[NSNull class]]) {
        if (![projectname isEqualToString:[expenseEntryObject expenseEntryProjectName]])
            self.navigationItem.rightBarButtonItem.enabled=YES;
    }
    else
        self.navigationItem.rightBarButtonItem.enabled=YES;

    if (project.uri!=nil && ![project.uri isKindOfClass:[NSNull class]])
    {
        self.expenseEntryObject.expenseEntryProjectName = project.name;
        self.expenseEntryObject.expenseEntryProjectUri = project.uri;
        self.expenseEntryObject.displayBillToClient = ![self shouldDisableBillClientForProject:project];
        self.expenseEntryObject.disableBillToClient = [self shouldDisableBillClientForProject:project];
    }
    else
    {
        self.expenseEntryObject.expenseEntryProjectName = nil;
        self.expenseEntryObject.expenseEntryProjectUri = nil;
    }

    
    NSIndexPath *typeIndex = nil;
    if (isProjectAllowed && isClientAllowed)
    {
        if (self.canEditTask)
        {
            typeIndex = [NSIndexPath indexPathForRow:3 inSection:EXPENSE_SECTION];
        }
        else
        {
           typeIndex = [NSIndexPath indexPathForRow:2 inSection:EXPENSE_SECTION];
        }

    }
    else if(isProjectAllowed)
    {
        if (self.canEditTask)
        {
            typeIndex = [NSIndexPath indexPathForRow:2 inSection:EXPENSE_SECTION];
        }
        else
        {
            typeIndex = [NSIndexPath indexPathForRow:1 inSection:EXPENSE_SECTION];
        }

    }
    else
        typeIndex = [NSIndexPath indexPathForRow:0 inSection:EXPENSE_SECTION];
    
    [self updateFieldAtIndex:typeIndex WithSelectedValues:RPLocalizedString(SELECT, @"")];



    [[firstSectionfieldsArray objectAtIndex:typeIndex.row] setObject:RPLocalizedString(SELECT, @"") forKey:@"defaultValue"];
    NSIndexPath *typeIndexpath=[NSIndexPath indexPathForRow:typeIndex.row inSection:EXPENSE_SECTION];
    ExpenseEntryCustomCell *typeCell=(ExpenseEntryCustomCell *) [self.expenseEntryTableView cellForRowAtIndexPath:typeIndexpath];
    [typeCell enableRequiredCell];
    
    [expenseEntryObject setExpenseEntryExpenseCodeName:@""];
    
    NSIndexPath *amountIndex = nil;
    if (isProjectAllowed && isClientAllowed)
    {
        if (self.canEditTask)
        {
            amountIndex = [NSIndexPath indexPathForRow:4 inSection:EXPENSE_SECTION];
        }
        else
        {
            amountIndex = [NSIndexPath indexPathForRow:3 inSection:EXPENSE_SECTION];
        }
    }

    else if(isProjectAllowed)
    {
        if (self.canEditTask)
        {
            amountIndex = [NSIndexPath indexPathForRow:3 inSection:EXPENSE_SECTION];
        }
        else
        {
            amountIndex = [NSIndexPath indexPathForRow:2 inSection:EXPENSE_SECTION];
        }
    }

    else
        amountIndex = [NSIndexPath indexPathForRow:1 inSection:EXPENSE_SECTION];

    
    [self updateFieldAtIndex:amountIndex WithSelectedValues:RPLocalizedString(ADD, @"")];
    [[firstSectionfieldsArray objectAtIndex:amountIndex.row] setObject:RPLocalizedString(ADD, @"") forKey:@"defaultValue"];
    NSIndexPath *amountIndexpath=[NSIndexPath indexPathForRow:amountIndex.row inSection:EXPENSE_SECTION];
    ExpenseEntryCustomCell *amountCell=(ExpenseEntryCustomCell *) [self.expenseEntryTableView cellForRowAtIndexPath:amountIndexpath];
    [amountCell grayedOutRequiredCell];
    
    if (isProjectAllowed)
    {
        if (self.canEditTask)
        {
            NSIndexPath *taskIndexpath=[NSIndexPath indexPathForRow:typeIndex.row-1 inSection:EXPENSE_SECTION];
            ExpenseEntryCustomCell *taskCell=(ExpenseEntryCustomCell *) [self.expenseEntryTableView cellForRowAtIndexPath:taskIndexpath];
            if (project.uri!=nil && ![project.uri isKindOfClass:[NSNull class]])
            {
                if (project.hasTasksAvailableForTimeAllocation)
                {
                    [taskCell enableRequiredCell];
                }
                else
                {
                    [taskCell grayedOutRequiredCell];
                }

            }
            else
            {
               [taskCell grayedOutRequiredCell];
            }

            [self updateFieldAtIndex:taskIndexpath WithSelectedValues:RPLocalizedString(NONE_STRING, @"")];

            self.expenseEntryObject.expenseEntryTaskName = nil;
            self.expenseEntryObject.expenseEntryTaskUri = nil;

        }

    }
    
    if (screenMode==ADD_EXPENSE_ENTRY)
    {
        if (self.baseCurrencyName!=nil && ![self.baseCurrencyName isKindOfClass:[NSNull class]])
            [[firstSectionfieldsArray objectAtIndex:amountIndexpath.row] setObject:self.baseCurrencyName forKey:@"currencyName"];
        else
            [[firstSectionfieldsArray objectAtIndex:amountIndexpath.row] setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"currencyName"];
    }
    else
        [[firstSectionfieldsArray objectAtIndex:amountIndexpath.row] setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"currencyName"];
    
    [self.expenseEntryTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:index inSection:EXPENSE_SECTION], nil] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)selectionController:(SelectionController *)selectionController didChooseTask:(TaskType *)task
{
    NSInteger index = 1;
    if (isClientAllowed)
        index = 2;

    NSString *tasktName = task.name;
    NSMutableDictionary *taskDict = [NSMutableDictionary dictionary];
    [taskDict setObject:RPLocalizedString(Task, @"") forKey:@"fieldName"];
    [taskDict setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
    if (task.uri!=nil)
        [taskDict setObject:task.uri forKey: @"taskIdentity"];
    else
        [taskDict setObject:[NSNull null] forKey: @"taskIdentity"];
    
    if (task.name!=nil)
        [taskDict setObject:task.name forKey: @"defaultValue"];
    else
        [taskDict setObject:RPLocalizedString(NONE_STRING, @"") forKey: @"defaultValue"];
    
    [firstSectionfieldsArray replaceObjectAtIndex:index withObject:taskDict];
    
    if (self.expenseEntryObject) {
        
    }
    
    if (self.expenseEntryObject.expenseEntryTaskName != nil && ![self.expenseEntryObject.expenseEntryTaskName isKindOfClass:[NSNull class]]) {
        if (![tasktName isEqualToString:[expenseEntryObject expenseEntryTaskName]])
            self.navigationItem.rightBarButtonItem.enabled=YES;
    }
    else
        self.navigationItem.rightBarButtonItem.enabled=YES;
    
    self.expenseEntryObject.expenseEntryTaskName = task.name;
    self.expenseEntryObject.expenseEntryTaskUri = task.uri;
    
    [self.expenseEntryTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:index inSection:EXPENSE_SECTION], nil] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)selectionController:(SelectionController *)selectionController didChooseActivity:(Activity *)activity
{

}

-(id <ClientProjectTaskRepository> )selectionControllerNeedsClientProjectTaskRepository
{
    ExpenseClientProjectTaskRepository * expenseClientProjectTaskRepository = [self.injector getInstance:[ExpenseClientProjectTaskRepository class]];
    [expenseClientProjectTaskRepository setUpWithExpenseSheetUri:self.expenseEntryObject.expenseEntryExpenseSheetUri];
    return expenseClientProjectTaskRepository;
}

#pragma mark -
#pragma mark Other Methods

- (void)createFooterView
{
    if (screenMode == ADD_EXPENSE_ENTRY)
    {
        self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.expenseEntryTableView.frame), Button_space)];

        [footerView setBackgroundColor:[Util colorWithHex:@"#f8f8f8" alpha:1]];
        [self.expenseEntryTableView setTableFooterView:footerView];
    }
    else if (screenMode == EDIT_EXPENSE_ENTRY)
    {
        if (![expenseSheetStatus isEqualToString:APPROVED_STATUS] && ![expenseSheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS])
        {
            CGFloat deleteButtonWidth = 278.0f;
            CGFloat deleteButtonHeight = 45.0f;

            CGFloat footerWidth = CGRectGetWidth(self.expenseEntryTableView.frame);
            CGFloat footerHeight = Button_space * 2 + deleteButtonHeight;

            CGFloat deleteButtonX = (footerWidth - deleteButtonWidth) / 2.0f;

            self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, footerWidth, footerHeight)];
            footerView.backgroundColor = [Util colorWithHex:@"#f8f8f8" alpha:1];

            UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
            deleteButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            deleteButton.layer.borderWidth = 1.0f;
            deleteButton.layer.cornerRadius = deleteButtonHeight / 2.0f;
            deleteButton.frame = CGRectMake(deleteButtonX, Button_space, deleteButtonWidth, deleteButtonHeight);
            deleteButton.titleLabel.font = [UIFont fontWithName:RepliconFontFamilySemiBold size:RepliconFontSize_17];
            [deleteButton setTitle:RPLocalizedString(Delete_Button_title, @"") forState:UIControlStateNormal];
            [deleteButton setTitleColor:[Util colorWithHex:@"#FF6B53" alpha:1.0] forState:UIControlStateNormal];

            [deleteButton addTarget:self
                             action:@selector(deleteAction:)
                   forControlEvents:UIControlEventTouchUpInside];

            [footerView addSubview:deleteButton];

            [self.expenseEntryTableView setTableFooterView:footerView];
        }
    }
}

-(void)updateFieldAtIndex:(NSIndexPath*)indexPath WithSelectedValues:(NSString *)selectedValue
{
	ExpenseEntryCustomCell *entryCell = (ExpenseEntryCustomCell *)[expenseEntryTableView cellForRowAtIndexPath:indexPath];
	[entryCell.fieldButton setText:selectedValue];
	if (entryCell.fieldText != nil)
    {
		[[entryCell fieldText] setText:selectedValue];
	}
}

- (void)resetTableSize:(BOOL)isResetTable
{
    if (isResetTable)
    {
        CGRect frame = self.view.bounds;

        if (screenMode == EDIT_EXPENSE_ENTRY)
        {
            frame.size.height = frame.size.height - Picker_Height + 10 - 44;
        }
        else
        {
            frame.size.height = frame.size.height - Picker_Height + 10 - 44;
        }

        ExpenseEntryCustomCell *theCell = (ExpenseEntryCustomCell *)[expenseEntryTableView cellForRowAtIndexPath:currentIndexPath];

        CGRect screenRect = [[UIScreen mainScreen] bounds];
        float offset = screenRect.size.height - spaceForOffSet;

        if (currentIndexPath.section == 1)
        {
            [expenseEntryTableView setContentOffset:CGPointMake(0, theCell.center.y - offset) animated:NO];
        }

        [self.expenseEntryTableView setFrame:frame];
    }
    else
    {
        [self.expenseEntryTableView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), [self heightForTableView])];
    }
}

-(void)expenseCodeDetailsDataReceived
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EXPENSECODE_DETAILS_RECIEVED_NOTIFICATION object:nil];
    ExpenseModel *expenseModel=[[ExpenseModel alloc] init];
    NSArray *detailsArray=[expenseModel getAllDetailsForExpenseCodeFromDB];
    AmountViewController *amountviewController=[[AmountViewController alloc]init];

    if (screenMode==ADD_EXPENSE_ENTRY)
    {
        NSMutableArray *taxDetailsArray=[expenseModel getAllExpenseTaxCodesFromDB];
        [amountviewController setExpenseTaxesInfoArray:(NSMutableArray*)taxDetailsArray];
    }
    else
    {
        NSMutableArray *taxDetailsArray=[NSMutableArray array];
        //Fix for defect DE18775//JUHI
        NSArray *expenseEntryDetailsArray=[expenseModel getAllTaxCodeUriEntryDetailsFromDBForExpenseEntryUri:expenseEntryObject.expenseEntryExpenseEntryUri andExpenseCodeUri:expenseEntryObject.expenseEntryExpenseCodeUri];
        if ([expenseEntryDetailsArray count]>0 && expenseEntryDetailsArray!=nil)
        {
            NSDictionary *taxCodeUriDict=[expenseEntryDetailsArray objectAtIndex:0];

            for (int i=1; i<=5; i++)
            {
                NSString *taxCodeUri=[taxCodeUriDict objectForKey:[NSString stringWithFormat:@"taxCodeUri%d",i]];
                NSArray *taxCodeInfoArray=[expenseModel getExpenseTaxCodesFromDBForTaxCodeUri:taxCodeUri];
                if ([taxCodeInfoArray count]>0 && taxCodeInfoArray!=nil)
                {
                    [taxDetailsArray addObject:[taxCodeInfoArray objectAtIndex:0]];
                }

            }
            [amountviewController setExpenseTaxesInfoArray:(NSMutableArray*)taxDetailsArray];
        }
        else
        {
            NSMutableArray *taxDetailsArray=[expenseModel getAllExpenseTaxCodesFromDB];
            [amountviewController setExpenseTaxesInfoArray:(NSMutableArray*)taxDetailsArray];
        }


    }



    NSString *expenseType=nil;
    if ([detailsArray count]!=0)
    {
        expenseType=[[detailsArray objectAtIndex:0] objectForKey:@"expenseCodeType"];
        amountviewController.expenseType=[[detailsArray objectAtIndex:0] objectForKey:@"expenseCodeType"];
    }

    if ([expenseType isEqualToString:Flat_With_Taxes]||[expenseType isEqualToString:Flat_WithOut_Taxes])
    {
        NSMutableArray *fieldsValueArray=[self getTaxesWithTotalAmountArray:expenseType];
        [amountviewController setFieldValuesArray:fieldsValueArray];
        if (screenMode==EDIT_EXPENSE_ENTRY)
        {
            [amountviewController setSelectedCurrencyUri:expenseEntryObject.expenseEntryIncurredAmountNetCurrencyUri];
        }
        else
        {
            if (expenseEntryObject.expenseEntryIncurredAmountNetCurrencyName!=nil)
            {
                [amountviewController setSelectedCurrencyUri:expenseEntryObject.expenseEntryIncurredAmountNetCurrencyUri];
            }
            else
            {
                if (self.reimbursementCurrencyURI!=nil && ![self.reimbursementCurrencyName isKindOfClass:[NSNull class]])
                {
                    [amountviewController setSelectedCurrencyUri:self.reimbursementCurrencyURI];
                }
            }
        }

    }
    else if ([expenseType isEqualToString:Rated_With_Taxes]||[expenseType isEqualToString:Rated_WithOut_Taxes])
    {
        NSString *expenseUnitLable=[[detailsArray objectAtIndex:0] objectForKey:@"expenseCodeUnitName"];
        NSString *expenseRatedCurrency=[[detailsArray objectAtIndex:0] objectForKey:@"expenseCodeCurrencyName"];
        double expenseRate=[[[detailsArray objectAtIndex:0] objectForKey:@"expenseCodeRate"] newDoubleValue];


        NSMutableArray *ratedDefaultValuesArray=[self getTaxesWithTotalAmountArray:expenseType];
        NSString *expenseAmount=expenseEntryObject.expenseEntryIncurredAmountNet;
        NSString *expenseQuantity =expenseEntryObject.expenseEntryQuantity;

        if (expenseEntryObject.expenseEntryRateAmount!=nil &&![expenseEntryObject.expenseEntryRateAmount isKindOfClass:[NSNull class]])
        {
            expenseRate=[expenseEntryObject.expenseEntryRateAmount newDoubleValue];
            NSString *currencyIdentity =expenseEntryObject.expenseEntryIncurredAmountTotalCurrencyUri;
            NSString *currencyName =expenseEntryObject.expenseEntryIncurredAmountTotalCurrencyName;
            if (currencyIdentity!=nil &&![currencyIdentity isKindOfClass:[NSNull class]] && ![currencyIdentity isEqualToString:@""] &&
                currencyName!=nil     &&![currencyName isKindOfClass:[NSNull class]] && ![currencyName isEqualToString:@""])
            {
                expenseRatedCurrency=currencyName;
            }
        }

        NSMutableArray *tempDefaultRateAndAmountsArray=[NSMutableArray arrayWithObjects:
                                         [Util getRoundedValueFromDecimalPlaces:[expenseQuantity newDoubleValue] withDecimalPlaces:2],
                                         [Util getRoundedValueFromDecimalPlaces:expenseRate withDecimalPlaces:4],
                                         [Util getRoundedValueFromDecimalPlaces:[expenseAmount newDoubleValue] withDecimalPlaces:2],
                                         nil];
        [amountviewController setRatedExpenseArray:[NSMutableArray arrayWithObjects:expenseUnitLable,nil]];
        [amountviewController setRate:expenseRate];
        [amountviewController setRatedValuesArray:ratedDefaultValuesArray];
        [amountviewController setRatedBaseCurrency:expenseRatedCurrency];
        [amountviewController setDefaultValuesArray:tempDefaultRateAndAmountsArray];
        [self setDefaultRateAndAmountsArray:defaultRateAndAmountsArray];
    }
    [amountviewController setCanNotEdit:canNotEdit];
    [amountviewController setAmountControllerDelegate:self];
    [self.navigationController pushViewController:amountviewController animated:YES];
    [expenseEntryTableView deselectRowAtIndexPath:currentIndexPath animated:YES];

}

-(NSMutableArray *)getTaxesWithTotalAmountArray:(NSString *)expenseType
{
    if ((self.isTypeChanged||screenMode==ADD_EXPENSE_ENTRY)&&isAmountDoneClicked==NO)
    {
        self.isTypeChanged=NO;
        ExpenseModel *expenseModel=[[ExpenseModel alloc]init];
        NSArray *taxCodeArray=[expenseModel getAllExpenseTaxCodesFromDB];
        NSMutableArray *incurredAmountTaxesArray=[NSMutableArray array];
        for (int i=0; i<[taxCodeArray count]; i++)
        {
            NSMutableDictionary *tempIncurredAmountDict=[NSMutableDictionary dictionary];
            [tempIncurredAmountDict setObject:@"0.00" forKey:@"taxAmount"];
            [tempIncurredAmountDict setObject:@"" forKey:@"taxCurrencyName"];
            [tempIncurredAmountDict setObject:@""  forKey:@"taxCurrencyUri"];
            [tempIncurredAmountDict setObject:[[taxCodeArray objectAtIndex:i] objectForKey:@"uri"] forKey:@"taxCodeUri"];
            [incurredAmountTaxesArray addObject:tempIncurredAmountDict];
        }
        [expenseEntryObject setExpenseEntryIncurredTaxesArray:incurredAmountTaxesArray];


    }
    NSMutableArray *taxesWithTotalAmountArray=[NSMutableArray array];
    NSMutableArray *entryTaxesAmountArray=expenseEntryObject.expenseEntryIncurredTaxesArray;


    if ([expenseType isEqualToString:Flat_With_Taxes]||[expenseType isEqualToString:Flat_WithOut_Taxes])
    {
        if (screenMode==EDIT_EXPENSE_ENTRY)
        {
            [taxesWithTotalAmountArray addObject:expenseEntryObject.expenseEntryIncurredAmountNetCurrencyName];
        }
        else
        {
            if (expenseEntryObject.expenseEntryIncurredAmountNetCurrencyName!=nil)
            {
                [taxesWithTotalAmountArray addObject:expenseEntryObject.expenseEntryIncurredAmountNetCurrencyName];
            }
            else
            {
                if (self.reimbursementCurrencyName!=nil && ![self.reimbursementCurrencyName isKindOfClass:[NSNull class]])
                {
                    [taxesWithTotalAmountArray addObject:self.reimbursementCurrencyName];
                }
                else
                {
                    [taxesWithTotalAmountArray addObject:RPLocalizedString(SELECT, @"")];
                }

            }

        }
        if ([expenseType isEqualToString:Flat_WithOut_Taxes])
        {

            NSString *taxAmount =[Util getRoundedValueFromDecimalPlaces:[expenseEntryObject.expenseEntryIncurredAmountTotal newDoubleValue] withDecimalPlaces:2];
            [taxesWithTotalAmountArray addObject:taxAmount];
        }
        else
        {
            NSString *taxAmount =[Util getRoundedValueFromDecimalPlaces:[expenseEntryObject.expenseEntryIncurredAmountNet newDoubleValue] withDecimalPlaces:2];
            [taxesWithTotalAmountArray addObject:taxAmount];
        }


        for (int k=0; k<[entryTaxesAmountArray count]; k++)
        {
            NSString *tempTaxAmount=[[entryTaxesAmountArray objectAtIndex:k] objectForKey:@"taxAmount"];
            if (![tempTaxAmount isEqualToString:NULL_STRING]&&tempTaxAmount!=nil)
            {
                NSString *taxAmount =[Util getRoundedValueFromDecimalPlaces:[tempTaxAmount newDoubleValue] withDecimalPlaces:2];
                [taxesWithTotalAmountArray addObject:taxAmount];
            }


        }
        NSString *totalAmount =[Util getRoundedValueFromDecimalPlaces:[[expenseEntryObject expenseEntryIncurredAmountTotal] newDoubleValue] withDecimalPlaces:2];
        [taxesWithTotalAmountArray addObject:totalAmount];


    }
    else
    {
        for (int k=0; k<[entryTaxesAmountArray count]; k++)
        {
            NSString *tempTaxAmount=[[entryTaxesAmountArray objectAtIndex:k] objectForKey:@"taxAmount"];
            //if (![tempTaxAmount isEqualToString:NULL_STRING]&&tempTaxAmount!=nil)
            //{
            NSString *taxAmount =[Util getRoundedValueFromDecimalPlaces:[tempTaxAmount newDoubleValue] withDecimalPlaces:2];
            [taxesWithTotalAmountArray addObject:taxAmount];
            //}
            
        }
        
        NSString *totalAmount =[Util getRoundedValueFromDecimalPlaces:[[expenseEntryObject expenseEntryIncurredAmountTotal] newDoubleValue] withDecimalPlaces:2];
        [taxesWithTotalAmountArray addObject:totalAmount];
        
    }

    return taxesWithTotalAmountArray;
}


-(void)fetchExpenseCodeDetailsDataFromDatabaseForNonEditableEntries
{
    NSArray *entryArray=nil;
    NSArray *detailsArray=nil;
    NSArray *taxDetailsArray=nil;
    UIViewController *viewControllerCtrl=(UIViewController *)parentDelegate;
    //Approval context Flow for Expenses
    if ([viewControllerCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [viewControllerCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
        ApprovalsModel *approvalModel=[[ApprovalsModel alloc] init];
        ApprovalsScrollViewController *scrollViewCtrl=(ApprovalsScrollViewController *)parentDelegate;
        if ([scrollViewCtrl.approvalsModuleName isEqualToString:APPROVALS_PENDING_EXPENSES_MODULE])
        {
            entryArray=[approvalModel getPendingExpenseEntryInfoForSheetIdentity:expenseEntryObject.expenseEntryExpenseSheetUri andEntryIdentity:expenseEntryObject.expenseEntryExpenseEntryUri];
            detailsArray=[approvalModel getAllDetailsForPendingExpenseCodeFromDBForEntryUri:expenseEntryObject.expenseEntryExpenseEntryUri];
            taxDetailsArray=[approvalModel  getAllPendingExpenseTaxCodesFromDBForEntryUri:expenseEntryObject.expenseEntryExpenseEntryUri];
        }
        else
        {
            entryArray=[approvalModel getPreviousExpenseEntryInfoForSheetIdentity:expenseEntryObject.expenseEntryExpenseSheetUri andEntryIdentity:expenseEntryObject.expenseEntryExpenseEntryUri];
            detailsArray=[approvalModel getAllDetailsForPreviousExpenseCodeFromDBForEntryUri:expenseEntryObject.expenseEntryExpenseEntryUri];
            taxDetailsArray=[approvalModel  getAllPreviousExpenseTaxCodesFromDBForEntryUri:expenseEntryObject.expenseEntryExpenseEntryUri];
        }




    }
    //User context Flow for Expenses
    if ([parentDelegate isKindOfClass:[ListOfExpenseEntriesViewController class]])
    {
        ExpenseModel *expenseModel=[[ExpenseModel alloc] init];
        entryArray=[expenseModel getExpenseEntryInfoForSheetIdentity:expenseEntryObject.expenseEntryExpenseSheetUri andEntryIdentity:expenseEntryObject.expenseEntryExpenseEntryUri];
        detailsArray=[expenseModel getAllDetailsForExpenseCodeFromDBForEntryUri:expenseEntryObject.expenseEntryExpenseEntryUri];
        taxDetailsArray=[expenseModel  getAllPendingExpenseTaxCodesFromDBForEntryUri:expenseEntryObject.expenseEntryExpenseEntryUri];

    }

    if ([entryArray count]>0 && entryArray!=nil)
    {
        AmountViewController *amountviewController=[[AmountViewController alloc]init];
        NSDictionary *dict=[entryArray objectAtIndex:0];
        NSString *ratedQuantity=[dict objectForKey:@"quantity"];
        NSString *ratedAmount=[dict objectForKey:@"rateAmount"];
         NSString *expenseType=nil;
        if (ratedAmount!=nil && ratedQuantity!=nil &&
            ![ratedAmount isKindOfClass:[NSNull class]]&& ![ratedQuantity isKindOfClass:[NSNull class]] &&
            ![ratedQuantity isEqualToString:@""]&&![ratedAmount isEqualToString:@""]&&![ratedQuantity isEqualToString:NULL_STRING]&&![ratedAmount isEqualToString:NULL_STRING])
        {

            NSMutableArray *tempTaxArray=[NSMutableArray array];
            for (int i=1; i<=5; i++)
            {
                NSString *taxAmount=[dict objectForKey:[NSString stringWithFormat:@"taxAmount%d",i]];
                if (taxAmount!=nil && ![taxAmount isKindOfClass:[NSNull class]]
                    &&![taxAmount isEqualToString:NULL_STRING]&& ![taxAmount isEqualToString:@""])
                {
                    [tempTaxArray addObject:taxAmount];
                }

            }

            if (tempTaxArray!=nil && [tempTaxArray count]>0)
            {
                expenseType=Rated_With_Taxes;
            }
            else
            {
                expenseType=Rated_WithOut_Taxes;
            }

        }
        else
        {
            NSMutableArray *tempTaxArray=[NSMutableArray array];
            for (int i=1; i<=5; i++)
            {
                NSString *taxAmount=[dict objectForKey:[NSString stringWithFormat:@"taxAmount%d",i]];
                if (taxAmount!=nil && ![taxAmount isKindOfClass:[NSNull class]]
                    &&![taxAmount isEqualToString:NULL_STRING]&& ![taxAmount isEqualToString:@""])
                {
                    [tempTaxArray addObject:taxAmount];
                }

            }

            if (tempTaxArray!=nil && [tempTaxArray count]>0)
            {
                expenseType=Flat_With_Taxes;
            }
            else
            {
                expenseType=Flat_WithOut_Taxes;
            }

        }

        [amountviewController setExpenseTaxesInfoArray:(NSMutableArray*)taxDetailsArray];
        if ([expenseType isEqualToString:Flat_With_Taxes]||[expenseType isEqualToString:Flat_WithOut_Taxes])
        {
            [amountviewController setFieldValuesArray:[self getTaxesWithTotalAmountArray:expenseType]];
            [amountviewController setSelectedCurrencyUri:expenseEntryObject.expenseEntryIncurredAmountNetCurrencyUri];
        }
        else if ([expenseType isEqualToString:Rated_With_Taxes]||[expenseType isEqualToString:Rated_WithOut_Taxes])
        {
            NSString *expenseUnitLable=[[detailsArray objectAtIndex:0] objectForKey:@"expenseCodeUnitName"];
            NSString *expenseRatedCurrency=[[detailsArray objectAtIndex:0] objectForKey:@"expenseCodeCurrencyName"];
            double expenseRate=[[[detailsArray objectAtIndex:0] objectForKey:@"expenseCodeRate"] newDoubleValue];
            NSMutableArray *ratedDefaultValuesArray=[self getTaxesWithTotalAmountArray:expenseType];
            NSString *expenseAmount=expenseEntryObject.expenseEntryIncurredAmountNet;
            NSString *expenseQuantity =expenseEntryObject.expenseEntryQuantity;
            NSMutableArray *tempDefaultRateAndAmountsArray=[NSMutableArray arrayWithObjects:
                                                            [Util getRoundedValueFromDecimalPlaces:[expenseQuantity newDoubleValue] withDecimalPlaces:2],
                                                            [Util getRoundedValueFromDecimalPlaces:expenseRate withDecimalPlaces:4],
                                                            [Util getRoundedValueFromDecimalPlaces:[expenseAmount newDoubleValue] withDecimalPlaces:2],
                                                            nil];
            [amountviewController setRatedExpenseArray:[NSMutableArray arrayWithObjects:expenseUnitLable,nil]];
            [amountviewController setRate:expenseRate];
            [amountviewController setRatedValuesArray:ratedDefaultValuesArray];
            [amountviewController setRatedBaseCurrency:expenseRatedCurrency];
            [amountviewController setDefaultValuesArray:tempDefaultRateAndAmountsArray];

        }
        amountviewController.expenseStatus = expenseSheetStatus;
        amountviewController.expenseType=expenseType;
        [amountviewController setCanNotEdit:canNotEdit];
        [amountviewController setAmountControllerDelegate:self];
        [self.navigationController pushViewController:amountviewController animated:YES];
        [expenseEntryTableView deselectRowAtIndexPath:currentIndexPath animated:YES];



    }




}

#pragma mark -
#pragma mark UIImagePickerController

-(void)showUnsupportedAlertMessage
{
	NSString *_msg = RPLocalizedString(@"This receipt is in a format not supported by the image viewer \n \n Please log in to Replicon to view the receipt", "");

    [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                   otherButtonTitle:nil
                                           delegate:self
                                            message:_msg
                                              title:nil
                                                tag:Image_Alert_Unsupported];

	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];

}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES){
		if (buttonIndex==0) {

            //Fix for MOBI-849//JUHI
            NSArray *devices = [AVCaptureDevice devices];
            AVCaptureDevice *frontCamera;
            AVCaptureDevice *backCamera;

            for (AVCaptureDevice *device in devices) {

//                NSLog(@"Device name: %@", [device localizedName]);

                if ([device hasMediaType:AVMediaTypeVideo]) {

                    if ([device position] == AVCaptureDevicePositionBack) {
                        NSLog(@"Device position : back");
                        backCamera = device;
                    }
                    else {
                        NSLog(@"Device position : front");
                        frontCamera = device;
                    }
                }
            }
            NSError *error = nil;
            AVCaptureDeviceInput *input=nil;
            if (frontCamera)
            {
                input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
            }
            else if (backCamera)
            {
                input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
            }



            if (!input)
            {

                [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                               otherButtonTitle:nil
                                                       delegate:self
                                                        message:RPLocalizedString(CameraDisableMsg, @"")
                                                          title:@""
                                                            tag:001];

            }
            else
            {
                UIImagePickerController *imgCameraPicker;
                imgCameraPicker = [[UIImagePickerController alloc]init];
                imgCameraPicker.delegate=self;
                imgCameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController: imgCameraPicker animated:YES completion:nil];
                [expenseEntryTableView deselectRowAtIndexPath:currentIndexPath animated:YES];
                imgCameraPicker.allowsEditing= NO;
            }



		}
		if (buttonIndex==1) {
			UIImagePickerController *imgPicker = [[UIImagePickerController alloc]init];
			imgPicker.delegate=self;
			imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			[self presentViewController:imgPicker animated:YES completion:nil];
            [expenseEntryTableView deselectRowAtIndexPath:currentIndexPath animated:YES];


		}

		if (buttonIndex==2) {

		}
	}else {

		if (buttonIndex==0) {
			UIImagePickerController *imgPicker = [[UIImagePickerController alloc]init];
			imgPicker.delegate=self;
			imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
			[self presentViewController:imgPicker animated:YES completion:nil];
            [expenseEntryTableView deselectRowAtIndexPath:currentIndexPath animated:YES];

		}
		if (buttonIndex==1) {
            [expenseEntryTableView deselectRowAtIndexPath:currentIndexPath animated:YES];

		}
	}
}




- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{

    CLS_LOG(@"-----Choose image action on ExpenseEntryViewController -----");
    [picker dismissViewControllerAnimated:NO completion:^{
        ReceiptsViewController *tempreceiptViewController=[[ReceiptsViewController alloc]init];
        self.receiptViewController=tempreceiptViewController;
        [receiptViewController setInNewEntry: YES];
        [receiptViewController setRecieptDelegate: self];
        [receiptViewController setSheetId:expenseEntryObject.expenseEntryExpenseSheetUri];
        [receiptViewController setEntryId:expenseEntryObject.expenseEntryExpenseEntryUri];
        [receiptViewController.receiptImageView setFrame:self.view.frame];
        UIImage	 *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        //Impelemnted for Pdf Receipt
        [receiptViewController initializeImageView];
        [receiptViewController setImage:image];
        //Impelemnted for Pdf Receipt
        [receiptViewController.scrollView setFrame:receiptViewController.view.frame];
        [receiptViewController resetScrollView];

        AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [delegate setCurrVisibleViewController: receiptViewController];

        if(screenMode==ADD_EXPENSE_ENTRY)
        {
            UINavigationController *tempnavcontroller = [[UINavigationController alloc]initWithRootViewController:self.receiptViewController];
            [self presentViewController:tempnavcontroller animated:NO completion:nil];

        }
        else
        {
            [self.navigationController pushViewController:self.receiptViewController animated:NO];
        }

        [expenseEntryTableView deselectRowAtIndexPath:currentIndexPath animated:YES];
    }];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    CLS_LOG(@"-----Cancel Image button action on ExpenseEntryViewController -----");
	[self dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark -
#pragma mark Data Update Methods

-(void)setValuesForRatedExpenseType:(NSMutableArray *)_arrayrated andCurrencyName:(NSString *)currencyName
{

	[self setDefaultRateAndAmountsArray:[NSMutableArray arrayWithArray:[_arrayrated objectAtIndex:0]]];
	[self setRatedCalculatedValuesArray:[NSMutableArray arrayWithArray:[_arrayrated objectAtIndex:1]]];

    NSMutableArray *calculatedTaxesArray=[_arrayrated objectAtIndex:1];
    NSMutableArray *entryTaxesAmountArray=expenseEntryObject.expenseEntryIncurredTaxesArray;
    ExpenseModel *expenseModel=[[ExpenseModel alloc] init];
    NSArray *detailsArray=[expenseModel getAllDetailsForExpenseCodeFromDB];

    NSString *currencyUri=[[detailsArray objectAtIndex:0] objectForKey:@"expenseCodeCurrencyUri"];



    if (currencyName==nil||[currencyName isKindOfClass:[NSNull class]]||[currencyName isEqualToString:RPLocalizedString(NONE_STRING, @"")])
    {
        currencyName=[[detailsArray objectAtIndex:0] objectForKey:@"expenseCodeCurrencyName"];

    }


    currencyUri= [expenseModel getSystemCurrencyUriFromDBForCurrencyName:currencyName];



    if (currencyUri==nil || [currencyUri isKindOfClass:[NSNull class]])
    {
        currencyUri=[[detailsArray objectAtIndex:0] objectForKey:@"expenseCodeCurrencyUri"];
    }


   //Implemented as per US7626

    [expenseEntryObject setExpenseEntryRateCurrencyName:currencyName];
    [expenseEntryObject setExpenseEntryRateCurrencyUri:currencyUri];
    NSMutableArray *recalculatedTaxesArray=[NSMutableArray array];
    for (int i=0; i<[entryTaxesAmountArray count]; i++)
    {
        NSMutableDictionary *tempDict=[entryTaxesAmountArray objectAtIndex:i];
        if (i<[calculatedTaxesArray count]-1)
        {
            [tempDict setObject:[calculatedTaxesArray objectAtIndex:i] forKey:@"taxAmount"];
            [tempDict setObject:currencyName forKey:@"taxCurrencyName"];
            [tempDict setObject:currencyUri   forKey:@"taxCurrencyUri"];


        }

        [recalculatedTaxesArray addObject:tempDict];

    }

    [expenseEntryObject setExpenseEntryIncurredTaxesArray:recalculatedTaxesArray];
    //Fix For Enable And Disable Save Button
    if (![[[_arrayrated objectAtIndex:0] objectAtIndex:2] isEqualToString:[expenseEntryObject expenseEntryIncurredAmountNet]])
    {
        self.navigationItem.rightBarButtonItem.enabled=YES;
    }
    [expenseEntryObject setExpenseEntryIncurredAmountNet:[[_arrayrated objectAtIndex:0] objectAtIndex:2]];
}
-(void)setRatedUnits:(NSString*)ratedKilometerEntry
{
	self.kilometersUnitsValue=ratedKilometerEntry;
    //Fix For Enable And Disable Save Button
    if (![ratedKilometerEntry isEqualToString:[expenseEntryObject expenseEntryRateAmount]])
    {

        self.navigationItem.rightBarButtonItem.enabled=YES;
    }
    [expenseEntryObject setExpenseEntryQuantity:ratedKilometerEntry];
    //[expenseEntryObject setExpenseEntryRateAmount:self.kilometersUnitsValue];
}
-(void)setDescription:(NSString *)_description
{
    if (currentIndexPath.section == DETAILS_SECTION)
    {
        defaultDescription = [[secondSectionfieldsArray objectAtIndex:currentIndexPath.row] objectForKey:@"defaultValue"];
        if(defaultDescription == _description)
        {
            return;
        }
        if (_description!=nil && ![_description isKindOfClass:[NSNull class]] && ![_description isEqualToString:@""])
        {
            defaultDescription=_description;
        }
        else
            defaultDescription=RPLocalizedString(ADD, @"");

        //Fix For Enable And Disable Save Button
        if (![defaultDescription isEqualToString:[[secondSectionfieldsArray objectAtIndex:currentIndexPath.row] objectForKey:@"defaultValue"]])
        {

            self.navigationItem.rightBarButtonItem.enabled=YES;
        }


        [[secondSectionfieldsArray objectAtIndex:currentIndexPath.row] setObject:defaultDescription forKey:@"defaultValue"];
        [self updateFieldAtIndex:currentIndexPath WithSelectedValues:[[secondSectionfieldsArray objectAtIndex:currentIndexPath.row]objectForKey:@"defaultValue"]];
		NSString *fieldName=[[secondSectionfieldsArray objectAtIndex:currentIndexPath.row] objectForKey:@"fieldName"];
        if ([fieldName isEqualToString:RPLocalizedString(DESCRIPTION, @"")])
        {
            [expenseEntryObject setExpenseEntryDescription:_description];
        }
		[self updateFieldAtIndex:currentIndexPath WithSelectedValues:defaultDescription];
        
        [self.expenseEntryTableView reloadData];
	}
}
-(void)setTotalAmountToRatedType:(NSString*)totalAmountCalculated andCurrenyName:(NSString *)currencyName
{
    //Fix for defect DE18775//JUHI
	amountValue=totalAmountCalculated;
    //Fix For Enable And Disable Save Button
    if (![amountValue isEqualToString:[expenseEntryObject expenseEntryIncurredAmountTotal]])
    {

        self.navigationItem.rightBarButtonItem.enabled=YES;
    }
    [expenseEntryObject setExpenseEntryIncurredAmountTotal:amountValue];
    //Implemented as per US7626
    //NSString *currencyNameStr=[[firstSectionfieldsArray objectAtIndex:currentIndexPath.row]objectForKey:@"currencyName"];
    NSString *currencyNameStr=currencyName;
    if (currencyNameStr==nil||[currencyNameStr isKindOfClass:[NSNull class]]||[currencyNameStr isEqualToString:RPLocalizedString(NONE_STRING, @"")])
    {
        ExpenseModel *expenseModel=[[ExpenseModel alloc] init];
        NSArray *detailsArray=[expenseModel getAllDetailsForExpenseCodeFromDB];
        NSString *expenseRatedCurrency=[[detailsArray objectAtIndex:0] objectForKey:@"expenseCodeCurrencyName"];
        currencyNameStr=expenseRatedCurrency;

    }

    ExpenseModel *expenseModel=[[ExpenseModel alloc]init];
    NSString *currencyId= [expenseModel getSystemCurrencyUriFromDBForCurrencyName:currencyNameStr];


    NSString *amtValue=[NSString stringWithFormat:@"%@ %@",currencyNameStr,amountValue];
    [[firstSectionfieldsArray objectAtIndex:currentIndexPath.row]setObject:amtValue forKey:@"defaultValue"];
    [[firstSectionfieldsArray objectAtIndex:currentIndexPath.row]setObject:amtValue forKey:@"expenseAmount"];
    if (currencyId!=nil && ![currencyId isKindOfClass:[NSNull class]])
    {
        [[firstSectionfieldsArray objectAtIndex:currentIndexPath.row]setObject:currencyId forKey:@"selectedDataIdentity"];
    }

    [self updateFieldAtIndex:currentIndexPath WithSelectedValues:amtValue];
    [expenseEntryObject setExpenseEntryIncurredAmountNetCurrencyUri:currencyId];
    [expenseEntryObject setExpenseEntryIncurredAmountNetCurrencyName:currencyNameStr];

    [expenseEntryObject setExpenseEntryIncurredAmountTotalCurrencyUri:currencyId];
    [expenseEntryObject setExpenseEntryIncurredAmountTotalCurrencyName:currencyNameStr];

}
-(void)setAmountArrayBaseCurrency:(NSMutableArray*)_amountArray withUri:(NSString *)currencyUri
{
	[self setAmountValuesArray:[NSMutableArray arrayWithArray:_amountArray]];
	[self setBaseCurrency:[amountValuesArray objectAtIndex:0]];
    self.isAmountDoneClicked=YES;
    //Fix For Enable And Disable Save Button
    if (![[_amountArray objectAtIndex:1] isEqualToString:[expenseEntryObject expenseEntryIncurredAmountNet]])
    {

        self.navigationItem.rightBarButtonItem.enabled=YES;
    }
    [expenseEntryObject setExpenseEntryIncurredAmountNet:[_amountArray objectAtIndex:1]];

    NSString *amountValueCalculated=[amountValuesArray objectAtIndex:[_amountArray count]-1] ;
    //Implemented as per US7626
    [expenseEntryObject setExpenseEntryIncurredAmountTotal:amountValueCalculated];
    NSString *expAmt=[NSString stringWithFormat:@"%@ %@",[amountValuesArray objectAtIndex:0],amountValueCalculated];
    [[firstSectionfieldsArray objectAtIndex:currentIndexPath.row]setObject:amountValueCalculated forKey:@"expenseAmount"];
    [[firstSectionfieldsArray objectAtIndex:currentIndexPath.row]setObject:expAmt forKey:@"defaultValue"];
    [self updateFieldAtIndex:currentIndexPath WithSelectedValues:expAmt];


    NSMutableArray *calculatedTaxesArray=[NSMutableArray array];
    for (int k=0; k<[amountValuesArray count]; k++)
    {
        if (k==0 || k==1 ||k==[amountValuesArray count]-1)
        {

        }
        else
        {
            [calculatedTaxesArray addObject:[amountValuesArray objectAtIndex:k]];
        }
    }

    NSString *currencyName=[self.amountValuesArray objectAtIndex:0];
    NSString *currencyId= [NSString stringWithFormat:@"%@",currencyUri];
    NSMutableArray *entryTaxesAmountArray=expenseEntryObject.expenseEntryIncurredTaxesArray;
    NSMutableArray *recalculatedTaxesArray=[NSMutableArray array];
    for (int i=0; i<[entryTaxesAmountArray count]; i++)
    {
        NSMutableDictionary *tempDict=[entryTaxesAmountArray objectAtIndex:i];
        if (i<[calculatedTaxesArray count])
        {
            [tempDict setObject:[calculatedTaxesArray objectAtIndex:i] forKey:@"taxAmount"];
            [tempDict setObject:currencyName forKey:@"taxCurrencyName"];
            if (currencyId!=nil)
            {
                [tempDict setObject:currencyId   forKey:@"taxCurrencyUri"];
            }
            else
            {
                [tempDict setObject:[[entryTaxesAmountArray objectAtIndex:i] objectForKey:@"taxCurrencyUri"] forKey:@"taxCurrencyUri"];
            }


        }

        [recalculatedTaxesArray addObject:tempDict];

    }

    [expenseEntryObject setExpenseEntryIncurredTaxesArray:recalculatedTaxesArray];
    NSIndexPath *currencyIndexPath = nil;
    if (isProjectAllowed)
    {
        currencyIndexPath = [NSIndexPath indexPathForRow:2 inSection:EXPENSE_SECTION];
    }
    else
    {
        currencyIndexPath = [NSIndexPath indexPathForRow:1 inSection:EXPENSE_SECTION];
    }


	ExpenseEntryCustomCell *customCell = (ExpenseEntryCustomCell *)[self.expenseEntryTableView cellForRowAtIndexPath:currencyIndexPath];
	[[customCell dataObj] setObject:baseCurrency forKey:@"currencyName"];


    //Implemented as per US7626
}

-(void)setCurrencyUri:(NSString *)_currencyIdentity currencyName:(NSString *)_currencyName
{
    //Implemented as per US7626
    NSIndexPath *currencyIndexPath = nil;
    if (isProjectAllowed)
    {
        currencyIndexPath = [NSIndexPath indexPathForRow:2 inSection:EXPENSE_SECTION];
    }
    else
    {
        currencyIndexPath = [NSIndexPath indexPathForRow:1 inSection:EXPENSE_SECTION];
    }
    if (_currencyIdentity!=nil)
    {
        [[firstSectionfieldsArray objectAtIndex:currencyIndexPath.row] setObject:_currencyIdentity forKey:@"selectedDataIdentity"];
        //Fix For Enable And Disable Save Button
        if (![_currencyIdentity isEqualToString:[expenseEntryObject expenseEntryIncurredAmountNetCurrencyUri]])
        {

            self.navigationItem.rightBarButtonItem.enabled=YES;
        }
        [expenseEntryObject setExpenseEntryIncurredAmountNetCurrencyUri:_currencyIdentity];
        [expenseEntryObject setExpenseEntryIncurredAmountNetCurrencyName:_currencyName];//Fix for defect DE18775//JUHI
    }
    else
    {
        ExpenseModel *expenseModel=[[ExpenseModel alloc]init];
        NSMutableArray *currencyArray=[expenseModel getAllSystemCurrencyUriFromDB];
        if ([currencyArray count]==0)
        {
            if ([_currencyIdentity isEqualToString:self.baseCurrencyUri])
            {
                [[firstSectionfieldsArray objectAtIndex:currencyIndexPath.row] setObject:self.baseCurrencyUri forKey:@"selectedDataIdentity"];
                //Fix For Enable And Disable Save Button
                if (![_currencyIdentity isEqualToString:[expenseEntryObject expenseEntryIncurredAmountNetCurrencyUri]])
                {

                    self.navigationItem.rightBarButtonItem.enabled=YES;
                }
                [expenseEntryObject setExpenseEntryIncurredAmountNetCurrencyUri:self.baseCurrencyUri];
                 [expenseEntryObject setExpenseEntryIncurredAmountNetCurrencyName:baseCurrencyName];//Fix for defect DE18775//JUHI
            }
            else
            {
                [[firstSectionfieldsArray objectAtIndex:currencyIndexPath.row] setObject:[expenseEntryObject expenseEntryIncurredAmountNetCurrencyUri] forKey:@"selectedDataIdentity"];

            }

        }

    }
    //Implemented as per US7626
}

#pragma mark -
#pragma mark Save Response Handler
-(void)cancelAction:(id)sender
{
    CLS_LOG(@"-----Cancel action on ExpenseEntryViewController -----");
    if(base64Decoded !=nil)
	{
		base64Decoded=nil;
	}
   if(screenMode==ADD_EXPENSE_ENTRY )
   {
       [self dismissViewControllerAnimated:YES completion:nil];

   }
   else
   {
        [self.navigationController popViewControllerAnimated:FALSE];
   }

    [datePicker removeFromSuperview];
    datePicker=nil;
    [pickerView removeFromSuperview];
    pickerView=nil;
    [toolbar removeFromSuperview];
    toolbar=nil;
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    for (UIView *view in appDelegate.window.subviews)
    {
        if ([view isKindOfClass:[UIPickerView class]])//Mobi-240 Ullas M L
        {
            if ([view tag]==PICKER_VIEW_TAG_EXPENSE_VIEW)
            {
                [view removeFromSuperview];
            }

        }
    }
}

-(void)saveAction:(id)sender
{
    //Fix for DE15534
    CLS_LOG(@"-----Save expense entry action on ExpenseEntryViewController -----");
    self.isSaveClicked=YES;
    [self.lastUsedTextField resignFirstResponder];
    [self showDataPicker:NO];
    [self showDatePicker:NO];
    [self pickerDone:nil];
	if (![NetworkMonitor isNetworkAvailableForListener:self])
    {
		[Util showOfflineAlert];
		return;
	}

    for (int i=0; i<[firstSectionfieldsArray count]; i++)
    {
        NSString *defaultValue=[[firstSectionfieldsArray objectAtIndex:i] objectForKey:@"defaultValue"];
        NSString *fieldName=[[firstSectionfieldsArray objectAtIndex:i] objectForKey:@"fieldName"];
        if ([fieldName isEqualToString:RPLocalizedString(PROJECT, @"")])
        {
            NSString *clientName = self.expenseEntryObject.expenseEntryClientName;
            BOOL isClientValueAvailable = (clientName != nil && ![clientName isKindOfClass:[NSNull class]]);
            BOOL showProjectAlertMsgWithClient = isClientValueAvailable && ([defaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")] || [defaultValue isEqualToString:RPLocalizedString(SELECT, @"")]);
            BOOL showProjectAlertMsgWithoutClient = !isClientValueAvailable && [defaultValue isEqualToString:RPLocalizedString(SELECT, @"")];
            
            if (showProjectAlertMsgWithClient || showProjectAlertMsgWithoutClient) {
                [Util errorAlert:@"" errorMessage:RPLocalizedString(InvalidProjectSelectedError, @"")];
                return;
            }
        }
        else if ([fieldName isEqualToString:RPLocalizedString(Client, @"")])
        {
            if ([defaultValue isEqualToString:RPLocalizedString(SELECT, @"")])
            {
                [Util errorAlert:@"" errorMessage:RPLocalizedString(CLIENT_SELECT_ERROR, @"")];
                return;
            }
        }
        else if ([fieldName isEqualToString:RPLocalizedString(Task, @"")])
        {
            if ([defaultValue isEqualToString:RPLocalizedString(SELECT, @"")])
            {
                [Util errorAlert:@"" errorMessage:RPLocalizedString(InvalidTaskSelectedError, @"")];
                return;
            }
        }
        else if ([fieldName isEqualToString:RPLocalizedString(TYPE, @"")])
        {
            if ([defaultValue isEqualToString:RPLocalizedString(SELECT, @"")])
            {
                [Util errorAlert:@"" errorMessage:RPLocalizedString(TYPE_SELECT_ERROR, @"")];
                return;
            }
        }
        else if ([fieldName isEqualToString:RPLocalizedString(AMOUNT, @"")])
        {
            if ([defaultValue isEqualToString:RPLocalizedString(ADD, @"")])
            {
                [Util errorAlert:@"" errorMessage:RPLocalizedString(AMOUNT_ADD_ERROR, @"")];
                return;
            }
        }
        //Implemented as per US7626
    }
    ExpenseModel *expenseModel=[[ExpenseModel alloc]init];
    NSArray *expenseSheetDetailsArray = [expenseModel getExpensesInfoForSheetIdentity:expenseEntryObject.expenseEntryExpenseSheetUri];
    NSString *sheetUri=[[expenseSheetDetailsArray objectAtIndex:0] objectForKey:@"expenseSheetUri"];
    NSString *sheetDateString=[[expenseSheetDetailsArray objectAtIndex:0] objectForKey:@"expenseDate"];
    NSString *sheetDescription=[[expenseSheetDetailsArray objectAtIndex:0] objectForKey:@"description"];
    NSString *sheetReimburseCurrencyUri=[[expenseSheetDetailsArray objectAtIndex:0] objectForKey:@"reimbursementAmountCurrencyUri"];



    NSDate *sheetDate = [Util convertTimestampFromDBToDate:sheetDateString];
    NSDictionary *dateDict=[Util convertDateToApiDateDictionary:sheetDate];

    [expenseEntryObject setReceiptImageData:b64String];
    NSMutableDictionary *expenseDetailsDict=[NSMutableDictionary dictionary];

    [expenseDetailsDict setObject:sheetUri forKey:@"expenseSheetUri"];
	[expenseDetailsDict setObject:dateDict forKey:@"date"];
	[expenseDetailsDict setObject:sheetDescription forKey:@"description"];
    [expenseDetailsDict setObject:sheetReimburseCurrencyUri forKey:@"reimbursementCurrencyUri"];

    NSMutableArray *expenseEntriesArray=[self getExpenseEntryObjectArrayForSave];
    NSMutableArray *udfArray=[NSMutableArray array];
    for (int k=0; k<[secondSectionfieldsArray count]; k++)
    {
        NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
        NSMutableDictionary *dict=[secondSectionfieldsArray objectAtIndex:k];
        NSString *fieldType=[dict objectForKey:@"fieldTypeUri"];
        NSString *fieldUri=[dict objectForKey:@"uri"];
        NSString *fieldValue=[dict objectForKey:@"defaultValue"];
        if ([fieldType isEqualToString:TEXT_UDF_TYPE])
        {
            if ([fieldValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
            {
                fieldValue=RPLocalizedString(NONE_STRING, @"");
            }
            [dataDict setObject:UDFType_TEXT forKey:@"udfType"];
            [dataDict setObject:fieldValue forKey:@"udfValue"];
            [dataDict setObject:fieldUri forKey:@"udfUri"];
            [udfArray addObject:dataDict];

        }
        else if ([fieldType isEqualToString:NUMERIC_UDF_TYPE])
        {
            if ([fieldValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
            {
                fieldValue=RPLocalizedString(NONE_STRING, @"");
            }
            [dataDict setObject:UDFType_NUMERIC forKey:@"udfType"];
            [dataDict setObject:fieldValue forKey:@"udfValue"];
            [dataDict setObject:fieldUri forKey:@"udfUri"];
            [udfArray addObject:dataDict];

        }
        else if ([fieldType isEqualToString:DATE_UDF_TYPE])
        {
            if ([fieldValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
            {
                fieldValue=RPLocalizedString(NONE_STRING, @"");
            }
            [dataDict setObject:UDFType_DATE forKey:@"udfType"];
            [dataDict setObject:fieldValue forKey:@"udfValue"];
            [dataDict setObject:fieldUri forKey:@"udfUri"];
            [udfArray addObject:dataDict];

        }
        else if ([fieldType isEqualToString:DROPDOWN_UDF_TYPE])
        {
            fieldValue=[dict objectForKey:@"dropDownOptionUri"];
            //Implemetation For MOBI-300//JUHI
            if (fieldValue!=nil && ![fieldValue isKindOfClass:[NSNull class]])
            {
                if ([fieldValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]||fieldValue==nil || [fieldValue isKindOfClass:[NSNull class]]|| [fieldValue isEqualToString:@""]|| [fieldValue isEqualToString:NULL_STRING])
                {
                    fieldValue=RPLocalizedString(NONE_STRING, @"");
                }
            }
            else if(fieldValue==nil || [fieldValue isKindOfClass:[NSNull class]]|| [fieldValue isEqualToString:@""]|| [fieldValue isEqualToString:NULL_STRING])
            {
                fieldValue=RPLocalizedString(NONE_STRING, @"");

            }
            [dataDict setObject:UDFType_DROPDOWN forKey:@"udfType"];
            [dataDict setObject:fieldValue forKey:@"udfValue"];
            [dataDict setObject:fieldUri forKey:@"udfUri"];
            [udfArray addObject:dataDict];

        }

    }
    expenseEntryObject.expenseEntryUdfArray=udfArray;
    [expenseEntriesArray addObject:expenseEntryObject];


    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EXPENSE_SHEET_SAVE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(expenseSheetSaveSummaryReceived:)
                                                 name:EXPENSE_SHEET_SAVE_NOTIFICATION
                                               object:nil];
    [[RepliconServiceManager expenseService] sendRequestToSaveExpenseSheetForExpenseSheetDict:expenseDetailsDict withExpenseEntriesArray:expenseEntriesArray withDelegate:self isProjectAllowed:self.isProjectAllowed isProjectRequired:self.isProjectRequired isDisclaimerAccepted:isDisclaimerRequired isExpenseSubmit:NO withComments:nil];//Implementation as per US9172//JUHI


}
-(void)deleteAction:(id)sender
{
    [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"No", @"No")
                                   otherButtonTitle:RPLocalizedString(@"Yes", @"Yes")
                                           delegate:self
                                            message:RPLocalizedString(Delete_ExpenseEntry_Confirmation, Delete_ExpenseEntry_Confirmation)
                                              title:nil
                                                tag:DELETE_EXPENSEENTRY_ALERT_TAG];


}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && alertView.tag==DELETE_EXPENSEENTRY_ALERT_TAG)
    {
        if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
        {
            [Util showOfflineAlert];
            return;
        }
        CLS_LOG(@"-----Delete expense entry action on ExpenseEntryViewController -----");

         [(UIAlertView *)alertView dismissWithClickedButtonIndex:[(UIAlertView *)alertView cancelButtonIndex] animated:NO];

        ExpenseModel *expenseModel=[[ExpenseModel alloc]init];
        NSArray *expenseSheetDetailsArray = [expenseModel getExpensesInfoForSheetIdentity:expenseEntryObject.expenseEntryExpenseSheetUri];
        NSString *sheetUri=[[expenseSheetDetailsArray objectAtIndex:0] objectForKey:@"expenseSheetUri"];
        NSString *sheetDateString=[[expenseSheetDetailsArray objectAtIndex:0] objectForKey:@"expenseDate"];
        NSString *sheetDescription=[[expenseSheetDetailsArray objectAtIndex:0] objectForKey:@"description"];
        NSString *sheetReimburseCurrencyUri=[[expenseSheetDetailsArray objectAtIndex:0] objectForKey:@"reimbursementAmountCurrencyUri"];
        NSDate *sheetDate = [Util convertTimestampFromDBToDate:sheetDateString];
        NSDictionary *dateDict=[Util convertDateToApiDateDictionary:sheetDate];
        NSMutableDictionary *expenseDetailsDict=[NSMutableDictionary dictionary];
        [expenseDetailsDict setObject:sheetUri forKey:@"expenseSheetUri"];
        [expenseDetailsDict setObject:dateDict forKey:@"date"];
        [expenseDetailsDict setObject:sheetDescription forKey:@"description"];
        [expenseDetailsDict setObject:sheetReimburseCurrencyUri forKey:@"reimbursementCurrencyUri"];

        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:EXPENSE_SHEET_SAVE_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(expenseSheetSaveSummaryReceived:)
                                                     name:EXPENSE_SHEET_SAVE_NOTIFICATION
                                                   object:nil];
        NSMutableArray *expenseEntriesArray=[self getExpenseEntryObjectArrayForSave];





        [[RepliconServiceManager expenseService] sendRequestToSaveExpenseSheetForExpenseSheetDict:expenseDetailsDict withExpenseEntriesArray:expenseEntriesArray withDelegate:self isProjectAllowed:self.isProjectAllowed isProjectRequired:self.isProjectRequired isDisclaimerAccepted:isDisclaimerRequired isExpenseSubmit:NO withComments:nil];//Implementation as per US9172//JUHI

    }


}

-(void)expenseSheetSaveSummaryReceived:(NSNotification *) notification
{
    NSDictionary *errorDict=(NSDictionary *)[notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EXPENSE_SHEET_SAVE_NOTIFICATION object:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    if (![[errorDict objectForKey:@"ERROR"]boolValue])
    {
        if(screenMode==ADD_EXPENSE_ENTRY )
        {
            [self dismissViewControllerAnimated:YES completion:nil];

        }
        else
        {
            [self.navigationController popViewControllerAnimated:FALSE];
        }

        [datePicker removeFromSuperview];
        datePicker=nil;
        [pickerView removeFromSuperview];
        pickerView=nil;
        [toolbar removeFromSuperview];
        toolbar=nil;
        AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
        for (UIView *view in appDelegate.window.subviews)
        {
            if ([view isKindOfClass:[UIPickerView class]])//Mobi-240 Ullas M L
            {
                if ([view tag]==PICKER_VIEW_TAG_EXPENSE_VIEW)
                {
                    [view removeFromSuperview];
                }

            }
        }

    }

}

-(NSMutableArray *)getExpenseEntryObjectArrayForSave
{
    NSMutableArray *returnObjectsArray=[NSMutableArray array];
    ExpenseModel *expenseModel=[[ExpenseModel alloc]init];

    NSMutableArray *dbexpenseEntriesArray=[expenseModel getAllExpenseEntriesFromDBExceptEntryWithUri:expenseEntryObject.expenseEntryExpenseEntryUri ForExpenseSheetUri:expenseEntryObject.expenseEntryExpenseSheetUri];

    for (int i=0; i<[dbexpenseEntriesArray count]; i++)
    {
        NSDictionary *expenseDict=[dbexpenseEntriesArray objectAtIndex:i];
        ExpenseEntryObject *expenseEntryObj   = [[ExpenseEntryObject alloc] init];

        expenseEntryObj.expenseEntryIncurredDate=[Util convertTimestampFromDBToDate:[[expenseDict objectForKey:@"incurredDate"] stringValue]];
        expenseEntryObj.expenseEntryDescription=[expenseDict objectForKey:@"expenseEntryDescription"];

        expenseEntryObj.expenseEntryApprovalStatus=[expenseDict objectForKey:@"approvalStatus"];
        expenseEntryObj.expenseEntryBillingUri=[expenseDict objectForKey:@"billingUri"];
        expenseEntryObj.expenseEntryExpenseCodeName=[expenseDict objectForKey:@"expenseCodeName"];
        expenseEntryObj.expenseEntryExpenseCodeUri=[expenseDict objectForKey:@"expenseCodeUri"];
        expenseEntryObj.expenseEntryExpenseEntryUri=[expenseDict objectForKey:@"expenseEntryUri"];
        expenseEntryObj.expenseEntryExpenseReceiptName=[expenseDict objectForKey:@"expenseReceiptName"];
        expenseEntryObj.expenseEntryExpenseReceiptUri=[expenseDict objectForKey:@"expenseReceiptUri"];
        expenseEntryObj.expenseEntryExpenseSheetUri=[expenseDict objectForKey:@"expenseSheetUri"];
        expenseEntryObj.expenseEntryIncurredAmountNet=[expenseDict objectForKey:@"incurredAmountNet"];
        expenseEntryObj.expenseEntryIncurredAmountNetCurrencyName=[expenseDict objectForKey:@"incurredAmountNetCurrencyName"];
        expenseEntryObj.expenseEntryIncurredAmountNetCurrencyUri=[expenseDict objectForKey:@"incurredAmountNetCurrencyUri"];
        expenseEntryObj.expenseEntryIncurredAmountTotal=[expenseDict objectForKey:@"incurredAmountTotal"];
        expenseEntryObj.expenseEntryIncurredAmountTotalCurrencyName=[expenseDict objectForKey:@"incurredAmountTotalCurrencyName"];
        expenseEntryObj.expenseEntryIncurredAmountTotalCurrencyUri=[expenseDict objectForKey:@"incurredAmountTotalCurrencyUri"];
        expenseEntryObj.expenseEntryPaymentMethodName=[expenseDict objectForKey:@"paymentMethodName"];
        expenseEntryObj.expenseEntryPaymentMethodUri=[expenseDict objectForKey:@"paymentMethodUri"];
        expenseEntryObj.expenseEntryProjectName=[expenseDict objectForKey:@"projectName"];
        expenseEntryObj.expenseEntryProjectUri=[expenseDict objectForKey:@"projectUri"];
        expenseEntryObj.expenseEntryQuantity=[expenseDict objectForKey:@"quantity"];
        expenseEntryObj.expenseEntryRateAmount=[expenseDict objectForKey:@"rateAmount"];
        expenseEntryObj.expenseEntryRateCurrencyName=[expenseDict objectForKey:@"rateCurrencyName"];
        expenseEntryObj.expenseEntryRateCurrencyUri=[expenseDict objectForKey:@"rateCurrencyUri"];
        expenseEntryObj.expenseEntryReimbursementUri=[expenseDict objectForKey:@"reimbursementUri"];
        expenseEntryObj.expenseEntryTaskName=[expenseDict objectForKey:@"taskName"];
        expenseEntryObj.expenseEntryTaskUri=[expenseDict objectForKey:@"taskUri"];
        expenseEntryObj.expenseEntryClientName=[expenseDict objectForKey:@"clientName"];
        expenseEntryObj.expenseEntryClientUri=[expenseDict objectForKey:@"clientUri"];


        NSMutableArray *incurredAmountTaxesArray=[NSMutableArray array];
        NSMutableDictionary *tempIncurredAmountDict1=[NSMutableDictionary dictionary];
        NSMutableDictionary *tempIncurredAmountDict2=[NSMutableDictionary dictionary];
        NSMutableDictionary *tempIncurredAmountDict3=[NSMutableDictionary dictionary];
        NSMutableDictionary *tempIncurredAmountDict4=[NSMutableDictionary dictionary];
        NSMutableDictionary *tempIncurredAmountDict5=[NSMutableDictionary dictionary];

        NSString *taxAmount1        =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxAmount1"]];
        NSString *taxCurrencyName1  =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyName1"]];
        NSString *taxCurrencyUri1   =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyUri1"]];
        NSString *taxCodeUri1       =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCodeUri1"]];

        [tempIncurredAmountDict1 setObject:taxAmount1       forKey:@"taxAmount"];
        [tempIncurredAmountDict1 setObject:taxCurrencyName1 forKey:@"taxCurrencyName"];
        [tempIncurredAmountDict1 setObject:taxCurrencyUri1  forKey:@"taxCurrencyUri"];
        [tempIncurredAmountDict1 setObject:taxCodeUri1       forKey:@"taxCodeUri"];

        NSString *taxAmount2        =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxAmount2"]];
        NSString *taxCurrencyName2  =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyName2"]];
        NSString *taxCurrencyUri2   =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyUri2"]];
        NSString *taxCodeUri2       =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCodeUri2"]];

        [tempIncurredAmountDict2 setObject:taxAmount2       forKey:@"taxAmount"];
        [tempIncurredAmountDict2 setObject:taxCurrencyName2 forKey:@"taxCurrencyName"];
        [tempIncurredAmountDict2 setObject:taxCurrencyUri2  forKey:@"taxCurrencyUri"];
        [tempIncurredAmountDict2 setObject:taxCodeUri2       forKey:@"taxCodeUri"];

        NSString *taxAmount3        =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxAmount3"]];
        NSString *taxCurrencyName3  =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyName3"]];
        NSString *taxCurrencyUri3   =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyUri3"]];
        NSString *taxCodeUri3       =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCodeUri3"]];

        [tempIncurredAmountDict3 setObject:taxAmount3       forKey:@"taxAmount"];
        [tempIncurredAmountDict3 setObject:taxCurrencyName3 forKey:@"taxCurrencyName"];
        [tempIncurredAmountDict3 setObject:taxCurrencyUri3  forKey:@"taxCurrencyUri"];
        [tempIncurredAmountDict3 setObject:taxCodeUri3       forKey:@"taxCodeUri"];

        NSString *taxAmount4        =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxAmount4"]];
        NSString *taxCurrencyName4  =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyName4"]];
        NSString *taxCurrencyUri4   =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyUri4"]];
        NSString *taxCodeUri4       =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCodeUri4"]];

        [tempIncurredAmountDict4 setObject:taxAmount4       forKey:@"taxAmount"];
        [tempIncurredAmountDict4 setObject:taxCurrencyName4 forKey:@"taxCurrencyName"];
        [tempIncurredAmountDict4 setObject:taxCurrencyUri4  forKey:@"taxCurrencyUri"];
        [tempIncurredAmountDict4 setObject:taxCodeUri4       forKey:@"taxCodeUri"];

        NSString *taxAmount5        =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxAmount5"]];
        NSString *taxCurrencyName5  =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyName5"]];
        NSString *taxCurrencyUri5   =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCurrencyUri5"]];
        NSString *taxCodeUri5       =[NSString stringWithFormat:@"%@",[expenseDict objectForKey:@"taxCodeUri5"]];

        [tempIncurredAmountDict5 setObject:taxAmount5       forKey:@"taxAmount"];
        [tempIncurredAmountDict5 setObject:taxCurrencyName5 forKey:@"taxCurrencyName"];
        [tempIncurredAmountDict5 setObject:taxCurrencyUri5  forKey:@"taxCurrencyUri"];
        [tempIncurredAmountDict5 setObject:taxCodeUri5       forKey:@"taxCodeUri"];


        [incurredAmountTaxesArray addObject:tempIncurredAmountDict1];
        [incurredAmountTaxesArray addObject:tempIncurredAmountDict2];
        [incurredAmountTaxesArray addObject:tempIncurredAmountDict3];
        [incurredAmountTaxesArray addObject:tempIncurredAmountDict4];
        [incurredAmountTaxesArray addObject:tempIncurredAmountDict5];

        if (self.baseCurrencyName!=nil && ![self.baseCurrencyName isKindOfClass:[NSNull class]])
        {
            expenseEntryObj.expenseEntryBaseCurrency=self.baseCurrencyName;
        }

        expenseEntryObj.expenseEntryIncurredTaxesArray=incurredAmountTaxesArray;
        NSArray *tempUdfArray=[expenseModel getExpenseCustomFieldsForExpenseSheetURI:[expenseDict objectForKey:@"expenseSheetUri"] moduleName:EXPENSES_UDF entryURI:[expenseDict objectForKey:@"expenseEntryUri"]];
        NSMutableArray *udfArray=[NSMutableArray array];
        for (int k=0; k<[tempUdfArray count]; k++)
        {
            NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
            NSMutableDictionary *dict=[tempUdfArray objectAtIndex:k];
            NSString *fieldType=[dict objectForKey:@"entry_type"];
            NSString *fieldUri=[dict objectForKey:@"udf_uri"];
            NSString *fieldValue=[dict objectForKey:@"udfValue"];
            if ([fieldType isEqualToString:TEXT_UDF_TYPE])
            {
                [dataDict setObject:UDFType_TEXT forKey:@"udfType"];
            }
            else if ([fieldType isEqualToString:NUMERIC_UDF_TYPE])
            {
                [dataDict setObject:UDFType_NUMERIC forKey:@"udfType"];
            }
            else if ([fieldType isEqualToString:DATE_UDF_TYPE])
            {
                [dataDict setObject:UDFType_DATE forKey:@"udfType"];
            }
            else if ([fieldType isEqualToString:DROPDOWN_UDF_TYPE])
            {
                [dataDict setObject:UDFType_DROPDOWN forKey:@"udfType"];
                fieldValue=[dict objectForKey:@"dropDownOptionURI"];
            }
            if (fieldValue==nil || [fieldValue isKindOfClass:[NSNull class]]|| [fieldValue isEqualToString:@""]|| [fieldValue isEqualToString:NULL_STRING])
            {
                fieldValue=RPLocalizedString(NONE_STRING, @"");
            }
            [dataDict setObject:fieldValue forKey:@"udfValue"];
            [dataDict setObject:fieldUri forKey:@"udfUri"];
            [udfArray addObject:dataDict];

        }
        expenseEntryObj.expenseEntryUdfArray=udfArray;
        [returnObjectsArray addObject:expenseEntryObj];


    }


    return returnObjectsArray;

}
//Implementation for US8771 HandleDateUDFEmptyValue//JUHI
-(void)pickerCancel:(id)sender
{
    [self resetTableSize:NO];
    self.rowTypeSelected=INVALID_ROW;
    self.pickerView.hidden=YES;
    self.datePicker.hidden=YES;
    self.toolbar.hidden=YES;
    [expenseEntryTableView deselectRowAtIndexPath:currentIndexPath animated:YES];
    NSArray *toolArray = [NSArray arrayWithObjects:spaceButton, doneButton,nil];
    [toolbar setItems:toolArray];
    //MOBI-271//JUHI
    if (currentIndexPath.section == DETAILS_SECTION)
    {
        NSDictionary *_rowData = [secondSectionfieldsArray objectAtIndex:currentIndexPath.row];
        NSString *fieldName=[_rowData objectForKey:@"fieldName"] ;
        BOOL hasPaymentMethods = self.dataSourceArray != nil && ![self.dataSourceArray isKindOfClass:[NSNull class]] && [self.dataSourceArray count]>0;
        if ([fieldName isEqualToString:RPLocalizedString(PAYMENT_METHOD, @"")] && hasPaymentMethods)
        {
            [self updatePaymentOnPickerSelectionWithPaymentName:self.previousPaymentName withCurrencyUri:self.previousPaymentUri];
        }
    }
    else
    [self updateDateComponent:self.previousDateUdfValue];

}
-(void)pickerClear:(id)sender
{
    [self resetTableSize:NO];
    self.rowTypeSelected=INVALID_ROW;
    self.pickerView.hidden=YES;
    self.datePicker.hidden=YES;
    self.toolbar.hidden=YES;
    [expenseEntryTableView deselectRowAtIndexPath:currentIndexPath animated:YES];
    NSArray *toolArray = [NSArray arrayWithObjects:spaceButton, doneButton,nil];
    [toolbar setItems:toolArray];
    //MOBI-271//JUHI
    if (currentIndexPath.section == DETAILS_SECTION)
    {
        NSDictionary *_rowData = [secondSectionfieldsArray objectAtIndex:currentIndexPath.row];
        NSString *fieldName=[_rowData objectForKey:@"fieldName"] ;
        BOOL hasPaymentMethods = self.dataSourceArray != nil && ![self.dataSourceArray isKindOfClass:[NSNull class]] && [self.dataSourceArray count]>0;
        if ([fieldName isEqualToString:RPLocalizedString(PAYMENT_METHOD, @"")] && hasPaymentMethods)
        {
            [self updatePaymentOnPickerSelectionWithPaymentName:RPLocalizedString(SELECT_STRING, @"") withCurrencyUri:@""];
        }
    }
    else
        [self updateDateComponent:RPLocalizedString(SELECT_STRING, @"")];

}

-(void)dismissCameraView
{

}

#pragma mark - Helper Methods

- (BOOL)shouldDisableBillClientForProject:(ProjectType *)project
{
    BOOL disableBillClient = FALSE;
    if(!self.isClientAllowed) {
        disableBillClient = TRUE;
    }
    else if(!IsNotEmptyString(project.client.name)) {
        disableBillClient = TRUE;
    }
    else if([project.name isEqualToString:RPLocalizedString(NONE_STRING, @"")]) {
        disableBillClient = TRUE;
    }
    else if(![project isProjectBillable]) {
        disableBillClient = TRUE;
    }
    return disableBillClient;
}

- (int)getProjectIndexBasedOnClientPermission {
    int index = 0;
    if (self.isClientAllowed) {
        index = 1;
    }
    return index;
}

- (NSString *)getProjectDefaultString {
    NSString *projectDefaultValue = @"";
    NSInteger index = [self getProjectIndexBasedOnClientPermission];
    
    if (isProjectAllowed) {
        NSIndexPath *projectIndex = [NSIndexPath indexPathForRow:index inSection:EXPENSE_SECTION];
        projectDefaultValue=[[firstSectionfieldsArray objectAtIndex:projectIndex.row] objectForKey:@"defaultValue"];
    }
    
    return projectDefaultValue;
}

- (NSString *)getClientDefaultString {
    NSString *clientDefaultValue = @"";
    NSInteger index = 0;
    
    if (isClientAllowed) {
        NSIndexPath *clientIndex = [NSIndexPath indexPathForRow:index inSection:EXPENSE_SECTION];
        clientDefaultValue=[[firstSectionfieldsArray objectAtIndex:clientIndex.row] objectForKey:@"defaultValue"];
    }
    
    return clientDefaultValue;
}

- (BOOL)billClientShouldDisable
{

    BOOL shouldDisableBillClientField = NO;
    
    NSString *projectDefaultValue = [self getProjectDefaultString];
    NSString *clientDefaultValue = [self getClientDefaultString];
    NSString *noneDefaultString = RPLocalizedString(NONE_STRING, @"");

    if([projectDefaultValue isEqualToString:noneDefaultString] || [clientDefaultValue isEqualToString:noneDefaultString]) {
        shouldDisableBillClientField = YES;
    }
    else if(self.expenseEntryObject.displayBillToClient == NO || self.expenseEntryObject.disableBillToClient == YES) {
        shouldDisableBillClientField = YES;
    }
    
    return shouldDisableBillClientField;
}

#pragma mark -
#pragma mark NetworkMonitor

-(void) networkActivated
{

}

#pragma mark -
#pragma mark Memory Based Methods
- (void)didReceiveMemoryWarning
{

    [super didReceiveMemoryWarning];


}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.expenseEntryTableView=nil;
    self.footerView=nil;
    self.saveButton=nil;
    self.pickerView=nil;
    self.datePicker=nil;
    self.toolbar=nil;
    self.doneButton=nil;
    self.spaceButton=nil;
    self.addDescriptionViewController=nil;
    self.receiptViewController=nil;
}


-(void)dealloc
{
    self.expenseEntryTableView.delegate = nil;
    self.expenseEntryTableView.dataSource = nil;
}

- (CGFloat)heightForTableView
{
    static CGFloat paddingForLastCellBottomSeparatorFudgeFactor = 2.0f;
    return CGRectGetHeight([[UIScreen mainScreen] bounds]) -
    (CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) +
     CGRectGetHeight(self.navigationController.navigationBar.frame) +
     CGRectGetHeight(self.tabBarController.tabBar.frame)) +
    paddingForLastCellBottomSeparatorFudgeFactor;
}

@end

