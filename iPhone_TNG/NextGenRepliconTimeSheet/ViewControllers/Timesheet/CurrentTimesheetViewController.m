#import "CurrentTimesheetViewController.h"
#import "Constants.h"
#import "Util.h"
#import "CurrentTimeSheetsCellView.h"
#import "TimesheetUdfView.h"
#import "TimesheetSummaryViewController.h"
#import "TimesheetModel.h"
#import "AppDelegate.h"
#import "TimesheetModel.h"
#import "LoginModel.h"
#import "TimesheetEntryObject.h"
#import "ApprovalActionsViewController.h"
#import "DropDownViewController.h"
#import "EntryCellDetails.h"
#import "AddDescriptionViewController.h"
#import "ApprovalsScrollViewController.h"
#import "ApprovalsPendingTimesheetViewController.h"
#import "TimesheetSubmitReasonViewController.h"
#import "ApproveTimeSheetChangeViewController.h"
#import "ApproverCommentViewController.h"
#import "ListOfTimeSheetsViewController.h"
#import "ApprovalStatusPresenter.h"
#import "DefaultTheme.h"
#import "ButtonStylist.h"
#import "UIView+Additions.h"

@interface CurrentTimesheetViewController ()

@property (nonatomic) id<Theme> theme;
@property (nonatomic) ButtonStylist *buttonStylist;
@property (nonatomic, weak) UIButton *submitButton;
@property (nonatomic, weak) AppDelegate *appDelegate;

@property (nonatomic, strong) TimesheetModel *timesheetModel;
@property (nonatomic, strong) SupportDataModel *supportDataModel;
@property (nonatomic) ApprovalStatusPresenter *approvalStatusPresenter;

@property(nonatomic,assign) BOOL isFromDeepLink;
@property(nonatomic,strong) NSDate *startDate;

@end


@implementation CurrentTimesheetViewController
@synthesize currentTimesheetTableView;
@synthesize selectedSheet;
@synthesize totalHours;
@synthesize sheetApprovalStatus;
@synthesize sheetIdentity;
@synthesize footerView;
@synthesize totallabelView;
@synthesize currentTimesheetArray;
@synthesize customFieldArray;
@synthesize rightBarButton;
@synthesize timeSheetObj;
@synthesize toolbar;
@synthesize datePicker;
@synthesize navcontroller;
@synthesize lastUsedTextField;
@synthesize dueDate;
@synthesize customPickerView;
@synthesize timesheetSummaryViewController;
@synthesize overlayView;
@synthesize timesheetUdfView;
@synthesize selectedUdfCell;
@synthesize disclaimerSelected;
@synthesize disclaimerTitleLabel;
@synthesize radioButton;
@synthesize parentDelegate;
@synthesize isCurrentTimesheetPeriod;
@synthesize actionType;
@synthesize timesheetMainPageController;
@synthesize isMultiDayInOutTimesheetUser;
@synthesize isSaveClicked;
@synthesize userName;
@synthesize sheetPeriod;
@synthesize currentViewTag;
@synthesize currentNumberOfView;
@synthesize totalNumberOfView;
@synthesize approverComments;
@synthesize approvalsModuleName;
@synthesize isExtendedInOut;
@synthesize isFirstTimeLoad;
@synthesize doneButton;
@synthesize spaceButton;
@synthesize cancelButton;
@synthesize previousDateUdfValue;
@synthesize pickerClearButton;
@synthesize sheetStatus;
@synthesize userUri;

#define HeightOfNoTOMsgLabel 80
#define Each_Cell_Row_Height_44 44
#define TimeOff_Type_TAG 999
#define movementDistanceFor4 226.66
#define movementDistanceFor5 145.66
#define timeoffNonsubmittedHeight 180
#define timeoffApprovedHeight_NonTimeOffNonsubmittedHeight 240
#define spaceHeight 310
#define WithRadioSpaceHeight 100
#define WithOutRadioSpaceHeight 60
#define WithoutRadioSpaceHeight 50
#define resetTableSpaceHeight 190
#define widthOfLabel 300
#define buttonSpace 30
#define ResetHeightios4 115
#define ResetHeightios5 170

- (instancetype)initWithApprovalStatusPresenter:(ApprovalStatusPresenter *)approvalStatusPresenter
                                          theme:(id <Theme>)theme
                               supportDataModel:(SupportDataModel *)supportDataModel
                                 timesheetModel:(TimesheetModel *)timesheetModel
                                  buttonStylist:(ButtonStylist *)buttonStylist
                                    appDelegate:(AppDelegate *)appDelegate {
    self = [super init];
    if (self) {
        self.theme = theme;
        self.buttonStylist = buttonStylist;
        self.appDelegate = appDelegate;
        self.timesheetModel = timesheetModel;
        self.supportDataModel = supportDataModel;
        self.approvalStatusPresenter = approvalStatusPresenter;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.isSaveClicked=NO;

    [self.view setBackgroundColor:RepliconStandardBackgroundColor];

    [Util setToolbarLabel: self withText: selectedSheet];

    self.currentTimesheetTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0 ,self.view.frame.size.width, [self heightForTableView]) style:UITableViewStylePlain];
    self.currentTimesheetTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.currentTimesheetTableView.delegate=self;
    self.currentTimesheetTableView.dataSource=self;
    [self.currentTimesheetTableView setAccessibilityIdentifier:@"uia_timesheet_day_view_details_table_identifier"];

    [self.view addSubview: self.currentTimesheetTableView];

    UIBarButtonItem *tempRightButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(SUMMARY_BTN_TITLE, SUMMARY_BTN_TITLE)  style:UIBarButtonItemStylePlain
                                                                              target:self action:@selector(timesheetSummaryAction:)];
    

    
    self.rightBarButton=tempRightButtonOuterBtn;

    self.isFirstTimeLoad=YES;
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

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.lastUsedTextField resignFirstResponder];
    if ([self.currentTimesheetArray count]>0)
    {
        [self doneClicked];
    }


    [[NSNotificationCenter defaultCenter] removeObserver:self name:SUBMITTED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UNSUBMITTED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [self deregisterKeyboardNotification];
    self.isFromDeepLink = NO;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (isFirstTimeLoad)
    {
        self.isFirstTimeLoad=NO;
    }
    else
    {
        [self createCurrentTimesheetEntryList];
        if ([self.currentTimesheetArray count]==0) {
            if (self.currentTimesheetTableView) {
                [self.currentTimesheetTableView removeFromSuperview];
            }
            return [self showTimesheetFormatNotSupported];
        }
        [self.totallabelView removeFromSuperview];
        UIView *totallbView=[[UIView alloc]initWithFrame:CGRectMake(0.0, 0, self.view.frame.size.width, Each_Cell_Row_Height_44)];

        self.totallabelView=totallbView;
        [self.totallabelView setBackgroundColor:TimesheetTotalHoursBackgroundColor];
        [self addTotalValueLable:self.totalHours];

        [self.footerView addSubview:self.totallabelView];
        [self addTotalValueLable:self.totalHours];
        [self.currentTimesheetTableView reloadData];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(RecievedData) name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [self checkForDeeplinkAndSelectCurrentTimesheet];
}

#pragma mark - Private

- (CGFloat)heightForTableView
{
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    CGFloat statusBarHeight = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
    UINavigationController *navigationController = (UINavigationController *)appDelegate.rootTabBarController.selectedViewController;
    CGFloat navigationBarHeight = CGRectGetHeight(navigationController.navigationBar.frame);
    CGFloat tabBarHeight = CGRectGetHeight(appDelegate.rootTabBarController.tabBar.frame);
    return CGRectGetHeight([[UIScreen mainScreen] bounds]) - (statusBarHeight+navigationBarHeight+tabBarHeight);
}

#pragma mark - Public

-(void)createCurrentTimesheetEntryList
{
    NSMutableArray *tmpcurrentTimesheetArray=[[NSMutableArray alloc]init];
    self.currentTimesheetArray=tmpcurrentTimesheetArray;

    NSMutableArray *arrayFromDB=nil;;
    if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
    {
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        double localTotalHrs = [timesheetModel getAllTimeEntriesTotalForSheetFromDB:sheetIdentity];
        
        self.totalHours=[Util getRoundedValueFromDecimalPlaces:localTotalHrs withDecimalPlaces:2];

        arrayFromDB=[timesheetModel getAllTimesheetDaySummaryFromDBForTimesheet:sheetIdentity];
    }
    else
    {
        ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
        NSDictionary *totalHoursDict=nil;
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            totalHoursDict=[approvalsModel getTotalHoursInfoForPendingTimesheetIdentity:sheetIdentity];
            arrayFromDB=[approvalsModel getAllPendingTimesheetDaySummaryFromDBForTimesheet:sheetIdentity];
        }
        else
        {
            totalHoursDict=[approvalsModel getTotalHoursInfoForPreviousTimesheetIdentity:sheetIdentity];
            arrayFromDB=[approvalsModel getAllPreviousTimesheetDaySummaryFromDBForTimesheet:sheetIdentity];

        }
        if ([totalHoursDict objectForKey:@"totalDurationDecimal"]!=nil && ![[totalHoursDict objectForKey:@"totalDurationDecimal"] isKindOfClass:[NSNull class]])
        {
            self.totalHours=[Util getRoundedValueFromDecimalPlaces:[[totalHoursDict objectForKey:@"totalDurationDecimal"]newDoubleValue]withDecimalPlaces:2];
        }
    }
    

    for (int i=0; i<[arrayFromDB count]; i++)
    {
        NSDictionary *dataDic=[arrayFromDB objectAtIndex:i];
        TimesheetObject *timeobj=[[TimesheetObject alloc]init];

        NSDate *nowDateFromLong = [Util convertTimestampFromDBToDate:[[dataDic objectForKey:@"timesheetEntryDate"] stringValue]];

        NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];

        NSLocale *locale=[NSLocale currentLocale];
        [myDateFormatter setLocale:locale];
        [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        myDateFormatter.dateFormat = @"EEEE, dd MMM yyyy";
        [timeobj setEntryDate:[myDateFormatter stringFromDate:nowDateFromLong]];
        myDateFormatter.dateFormat = @"EEE, MMM dd";
        [timeobj setEntryDateWithDesiredFormat:[myDateFormatter stringFromDate:nowDateFromLong]];
        
        NSString *localTimesheetEntryTotalDurationDecimalStr = nil;
        
        if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
        {
            TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
            localTimesheetEntryTotalDurationDecimalStr = [timesheetModel getEntriesTimeOffBreaksTotalForEntryDate:dataDic[@"timesheetEntryDate"] andTimesheetUri:sheetIdentity];
        }
        else
        {
            ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                localTimesheetEntryTotalDurationDecimalStr = [approvalsModel getEntriesTimeOffBreaksTotalForEntryDate:dataDic[@"timesheetEntryDate"] andTimesheetUri:sheetIdentity isPending:YES];
            }
            else
            {
                localTimesheetEntryTotalDurationDecimalStr = [approvalsModel getEntriesTimeOffBreaksTotalForEntryDate:dataDic[@"timesheetEntryDate"] andTimesheetUri:sheetIdentity isPending:NO];
            }
        }
        if (localTimesheetEntryTotalDurationDecimalStr!=nil && ![localTimesheetEntryTotalDurationDecimalStr isKindOfClass:[NSNull class]])
        {
            double localTimesheetEntryTotalDurationDecimal = [localTimesheetEntryTotalDurationDecimalStr newDoubleValue];
             [timeobj setNumberOfHours:[Util getRoundedValueFromDecimalPlaces:localTimesheetEntryTotalDurationDecimal withDecimalPlaces:2]];
        }
        else
        {
             [timeobj setNumberOfHours:[Util getRoundedValueFromDecimalPlaces:0.0 withDecimalPlaces:2]];
           
        }

        [timeobj setHasComments:[[dataDic objectForKey:@"hasComments"] boolValue]];
        [timeobj setIsHolidayDayOff:[[dataDic objectForKey:@"isHolidayDayOff"] boolValue]];
        [timeobj setIsWeeklyDayOff:[[dataDic objectForKey:@"isWeeklyDayOff"] boolValue]];


        if ([[dataDic objectForKey:@"timeOffDurationDecimal"] intValue]!=0)
        {
            [timeobj setHasTimeOff:TRUE];
        }
        else
        {
            [timeobj setHasTimeOff:FALSE];
        }

        [currentTimesheetArray addObject:timeobj];
    }

}
-(void)createUdfs
{
    int decimalPlace=0;
    LoginModel *loginModel=[[LoginModel alloc]init];
    NSMutableArray *udfArray=[loginModel getEnabledOnlyUDFsforModuleName:TIMESHEET_SHEET_UDF];


    NSMutableArray *tmpCustomFieldArray=[[NSMutableArray alloc]init];
    self.customFieldArray=tmpCustomFieldArray;


    for (int i=0; i<[udfArray count]; i++)
    {
        NSDictionary *udfDict = [udfArray objectAtIndex: i];
        NSMutableDictionary *dictInfo = [NSMutableDictionary dictionary];
        [dictInfo setObject:[udfDict objectForKey:@"name"] forKey:@"fieldName"];
        [dictInfo setObject:[udfDict objectForKey:@"uri"] forKey:@"identity"];
        if ([[udfDict objectForKey:@"udfType"] isEqualToString: NUMERIC_UDF_TYPE])
        {
            [dictInfo setObject:NUMERIC_UDF_TYPE forKey:@"fieldType"];

            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[sheetApprovalStatus isEqualToString:APPROVED_STATUS] ) {
                [dictInfo setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
            }
            else
                [dictInfo setObject:RPLocalizedString(ADD, @"") forKey:@"defaultValue"];

            if ([udfDict objectForKey:@"numericDecimalPlaces"]!=nil && !([[udfDict objectForKey:@"numericDecimalPlaces"] isKindOfClass:[NSNull class]])){
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
            [dictInfo setObject:TEXT_UDF_TYPE forKey:@"fieldType"];
            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[sheetApprovalStatus isEqualToString:APPROVED_STATUS] ) {
                [dictInfo setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
            }
            else
                [dictInfo setObject:RPLocalizedString(ADD, @"") forKey:@"defaultValue"];

            if ([udfDict objectForKey:@"textDefaultValue"]!=nil && ![[udfDict objectForKey:@"textDefaultValue"]isKindOfClass:[NSNull class]]){
                if (![[udfDict objectForKey:@"textDefaultValue"] isEqualToString:@""]&& (![[udfDict objectForKey:@"textDefaultValue"] isEqualToString:@"null"])) {
                    [dictInfo setObject:[udfDict objectForKey:@"textDefaultValue"] forKey:@"defaultValue"];
                }
            }

            if ([udfDict objectForKey:@"textMaxValue"]!=nil && !([[udfDict objectForKey:@"textMaxValue"] isKindOfClass:[NSNull class]]))
                [dictInfo setObject:[udfDict objectForKey:@"textMaxValue"] forKey:@"defaultMaxValue"];
        }
        else if ([[udfDict objectForKey:@"udfType"] isEqualToString:DATE_UDF_TYPE])
        {
            [dictInfo setObject: DATE_UDF_TYPE forKey: @"fieldType"];

            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[sheetApprovalStatus isEqualToString:APPROVED_STATUS] ) {
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
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];

                    NSLocale *locale=[NSLocale currentLocale];
                    [dateFormat setLocale:locale];
                    [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                    [dateFormat setDateFormat:@"MMMM dd, yyyy"];
                    NSString *dateStr = [dateFormat stringFromDate:[NSDate date]];
                    NSDate *dateToBeUsed=[dateFormat dateFromString:dateStr];
                    [dictInfo setObject:dateToBeUsed forKey:@"defaultValue"];


                }else
                {
                    if ([udfDict objectForKey:@"dateDefaultValue"]!=nil && !([[udfDict objectForKey:@"dateDefaultValue"] isKindOfClass:[NSNull class]]))
                    {
                        [dictInfo setObject:[Util convertTimestampFromDBToDate:[[udfDict objectForKey:@"dateDefaultValue"] stringValue]] forKey:@"defaultValue"];

                    }
                    else
                    {
                        if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[sheetApprovalStatus isEqualToString:APPROVED_STATUS] ) {
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
                        [dictInfo setObject:dateToBeUsed forKey:@"defaultValue"];

                    }
                    else
                    {
                        [dictInfo setObject:[Util convertTimestampFromDBToDate:[[udfDict objectForKey:@"dateDefaultValue"] stringValue]] forKey:@"defaultValue"];
                    }
                }
                else
                {
                    if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[sheetApprovalStatus isEqualToString:APPROVED_STATUS] ) {
                        [dictInfo setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
                    }
                    else
                        [dictInfo setObject:RPLocalizedString(SELECT_STRING, @"") forKey:@"defaultValue"];
                }
            }
        }
        else if ([[udfDict objectForKey:@"udfType"] isEqualToString:DROPDOWN_UDF_TYPE])
        {
            [dictInfo setObject:DROPDOWN_UDF_TYPE forKey:@"fieldType"];
            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[sheetApprovalStatus isEqualToString:APPROVED_STATUS] ) {
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
        if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
        {
            TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
            selectedudfArray=[timesheetModel getTimesheetSheetCustomFieldsForSheetURI:sheetIdentity moduleName:TIMESHEET_SHEET_UDF andUdfURI:[dictInfo objectForKey: @"identity"]];

        }
        else
        {
            ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                selectedudfArray=[approvalsModel getPendingTimesheetSheetCustomFieldsForSheetURI:sheetIdentity moduleName:TIMESHEET_SHEET_UDF andUdfURI:[dictInfo objectForKey: @"identity"]];
            }
            else
            {
                selectedudfArray=[approvalsModel getPreviousTimesheetSheetCustomFieldsForSheetURI:sheetIdentity moduleName:TIMESHEET_SHEET_UDF andUdfURI:[dictInfo objectForKey: @"identity"]];
            }


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

                            [udfDetailDict setObject:dateToBeUsed forKey:@"defaultValue"];
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
                        if (([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[sheetApprovalStatus isEqualToString:APPROVED_STATUS ])) {
                            [udfDetailDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
                        }
                        else
                            [udfDetailDict setObject:[dictInfo objectForKey: @"defaultValue" ] forKey:@"defaultValue"];


                    }

                }
                else
                {
                    if (([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[sheetApprovalStatus isEqualToString:APPROVED_STATUS ])) {
                        [udfDetailDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
                    }
                    else
                        [udfDetailDict setObject:[dictInfo objectForKey: @"defaultValue" ] forKey:@"defaultValue"];

                }
                [udfDetailDict setObject:[dictInfo objectForKey: @"fieldName" ] forKey:@"name"];

                [udfDetailDict setObject:[dictInfo objectForKey: @"fieldType"] forKey:@"type"];
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

                if ([[selUDFDataDict objectForKey:@"entry_type"] isEqualToString:DROPDOWN_UDF_TYPE])
                {
                    if ([dictInfo objectForKey: @"dropDownOptionUri" ]!=nil)
                    {
                        [udfDetailDict setObject:[dictInfo objectForKey: @"dropDownOptionUri" ] forKey:@"dropDownOptionUri"];
                    }
                }

                [customFieldArray addObject:udfDetailDict];

            }
        }
        else{
            NSMutableDictionary *udfDetailDict=[[NSMutableDictionary alloc]init];
            if (([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[sheetApprovalStatus isEqualToString:APPROVED_STATUS ])) {
                [udfDetailDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
            }
            else
                [udfDetailDict setObject:[dictInfo objectForKey: @"defaultValue" ] forKey:@"defaultValue"];

            [udfDetailDict setObject:[dictInfo objectForKey: @"fieldName" ] forKey:@"name"];

            [udfDetailDict setObject:[dictInfo objectForKey: @"fieldType"] forKey:@"type"];
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
            [customFieldArray addObject:udfDetailDict];


        }

    }
}
/************************************************************************************************************
 @Function Name   : createTableHeader
 @Purpose         : To extend tableview to configure its header
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)createTableHeader
{
    if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
    {
        UIView *statusView= [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];


        UILabel *statusLb= [[UILabel alloc]initWithFrame:CGRectMake(0, 3, self.view.width, 20)];
        NSString *statusStr=nil;
        if (isCurrentTimesheetPeriod)
        {
            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ])
            {
                statusStr=RPLocalizedString(Submittted, @"");
                statusLb.text=[NSString stringWithFormat:@"%@ - %@",RPLocalizedString(CURRENT_TIMESHEET, @""),statusStr];
            }
            else if ([sheetApprovalStatus isEqualToString:APPROVED_STATUS ]) {
                statusStr=RPLocalizedString(APPROVED_STATUS,APPROVED_STATUS);
                statusLb.text=[NSString stringWithFormat:@"%@ - %@",RPLocalizedString(CURRENT_TIMESHEET, @""),statusStr];
            }
            else if ([sheetApprovalStatus isEqualToString:REJECTED_STATUS ]){
                statusStr=RPLocalizedString(REJECTED_STATUS,@"");
                statusLb.text=[NSString stringWithFormat:@"%@ - %@",RPLocalizedString(CURRENT_TIMESHEET, @""),statusStr];
            }
            else{
                statusStr=dueDate;
                statusLb.text=[NSString stringWithFormat:@"%@ - %@ %@",RPLocalizedString(CURRENT_TIMESHEET, @""),RPLocalizedString(@"Due", @"Due"),statusStr];
            }

        }
        else{
            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ])
            {
                statusStr=RPLocalizedString(Submittted, @"");
                statusLb.text=[NSString stringWithFormat:@"%@",statusStr];
            }
            else if ([sheetApprovalStatus isEqualToString:APPROVED_STATUS ]) {
                statusStr=RPLocalizedString(APPROVED_STATUS,APPROVED_STATUS);
                statusLb.text=[NSString stringWithFormat:@"%@",statusStr];
            }
            else if ([sheetApprovalStatus isEqualToString:REJECTED_STATUS ]){
                statusStr=RPLocalizedString(REJECTED_STATUS,@"");
                statusLb.text=[NSString stringWithFormat:@"%@",statusStr];
            }
            else{
                statusStr=dueDate;
                statusLb.text=[NSString stringWithFormat:@"%@ %@",RPLocalizedString(OVER_DUE, @""),statusStr];
            }
        }

        statusView.backgroundColor=RepliconStandardBlackColor;
        statusLb.textColor=RepliconStandardWhiteColor;
        statusLb.textAlignment=NSTextAlignmentCenter;
        [statusLb setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];
        [statusView addSubview:statusLb];

        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 29, SCREEN_WIDTH, 1)];
        lineView.backgroundColor = [UIColor grayColor];
        [statusView addSubview:lineView];


        [self.currentTimesheetTableView setTableHeaderView:statusView];


    }
    else
    {
        NSString *labelText=nil;
        ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
        NSMutableArray *approvalArray=nil;

        if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            approvalArray=[approvalsModel getLastSubmittedPendingTimesheetApprovalFromDB:sheetIdentity];
        }
        else
        {
            approvalArray=[approvalsModel getLastSubmittedPreviousTimesheetApprovalFromDB:sheetIdentity];
        }



        if ([approvalArray count]>0)
        {
            NSDictionary *dataDict=[approvalArray objectAtIndex:0];
            NSDate *nowDateFromLong = [Util convertTimestampFromDBToDate:[[dataDict objectForKey:@"actionDate"] stringValue]];
            NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];

            NSLocale *locale=[NSLocale currentLocale];
            [myDateFormatter setLocale:locale];
            [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            myDateFormatter.dateFormat = @" MMM dd , yyyy";
            labelText=[myDateFormatter stringFromDate:nowDateFromLong];


        }
        //Implemented Approvals Pending DrillDown Loading UI
        NSString *submittedOnStr=@"";
        if (approvalArray!=nil)
        {
            submittedOnStr=[NSString stringWithFormat:@"%@ %@",RPLocalizedString(APPROVAL_SUBMITTED_ON, @""),labelText];
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_TIMESHEETS_MODULE])
            {
                if ([sheetApprovalStatus isEqualToString:APPROVED_STATUS ]) {
                    submittedOnStr=RPLocalizedString(APPROVED_STATUS,APPROVED_STATUS);
                }
                else if ([sheetApprovalStatus isEqualToString:REJECTED_STATUS ]){
                    submittedOnStr=RPLocalizedString(REJECTED_STATUS,@"");
                }
            }
        }




        ApprovalTablesHeaderView *headerView = [[ApprovalTablesHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40.0 )
                                                                                    withStatus:sheetApprovalStatus
                                                                                      userName:self.userName
                                                                                    dateString:self.sheetPeriod
                                                                                     labelText:submittedOnStr
                                                                        withApprovalModuleName:self.approvalsModuleName
                                                                             isWidgetTimesheet:NO
                                                                      withErrorsAndWarningView:nil];
        ApprovalsScrollViewController *scrollCtrl=(ApprovalsScrollViewController *)parentDelegate;
        if (!scrollCtrl.hasPreviousTimeSheets) {
            headerView.previousButton.hidden=TRUE;
        }
        if (!scrollCtrl.hasNextTimeSheets) {
            headerView.nextButton.hidden=TRUE;
        }
        self.currentTimesheetTableView.tableHeaderView = headerView;
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            headerView.countLbl.text=[NSString stringWithFormat:@"%li of %lu",(long)currentNumberOfView,(unsigned long)totalNumberOfView];
        }
        else
        {
            headerView.countLbl.text=@"";
        }

        headerView.delegate=self;

    }

}
/************************************************************************************************************
 @Function Name   : createFooter
 @Purpose         : To extend tableview to configure its footer
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)createFooter
{

    if ([self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_TIMESHEETS_MODULE])
    {//Fix for Approval status//JUHI
        self.sheetStatus=sheetApprovalStatus;
        sheetApprovalStatus=APPROVED_STATUS;
    }
    float footerHeight = 0;
    UIView *tempfooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                      0.0,
                                                                      self.view.frame.size.width,
                                                                      footerHeight)];
    self.footerView=tempfooterView;



    [footerView setBackgroundColor:[UIColor whiteColor]];
    UIImage *totalLineImage=[Util thumbnailImage:Cell_HairLine_Image];
    UIView *totallbView=[[UIView alloc]initWithFrame:CGRectMake(0.0, 0, self.view.frame.size.width, Each_Cell_Row_Height_44)];

    self.totallabelView=totallbView;
    [self.totallabelView setBackgroundColor:TimesheetTotalHoursBackgroundColor];
    [self addTotalValueLable:self.totalHours];
    [self.footerView addSubview:self.totallabelView];

    UIImageView *totalLineImageview=[[UIImageView alloc]initWithImage:totalLineImage];
    totalLineImageview.frame=CGRectMake(0.0,
                                        44,
                                        SCREEN_WIDTH,
                                        totalLineImage.size.height);


    [totalLineImageview setBackgroundColor:[UIColor clearColor]];
    [totalLineImageview setUserInteractionEnabled:NO];
    [self.footerView addSubview:totalLineImageview];





    float y=Each_Cell_Row_Height_44+totalLineImage.size.height-1;
    footerHeight = Each_Cell_Row_Height_44+totalLineImage.size.height-1;
    for (int i=0; i<[customFieldArray count]; i++)
    {
        NSDictionary *udfDict = [customFieldArray objectAtIndex: i];

        TimesheetUdfView *udfView=[[TimesheetUdfView alloc]initWithFrame:CGRectMake(0.0, y+1, self.view.frame.size.width, 44)];

        [udfView.fieldValue setTextColor:RepliconStandardBlackColor];

        udfView.fieldName.text=[udfDict objectForKey:@"name"];


        if ([[udfDict objectForKey:@"type"] isEqualToString:DATE_UDF_TYPE])
        {
            if ([[udfDict objectForKey:@"defaultValue"]isKindOfClass:[NSString class]] &&[[udfDict objectForKey:@"defaultValue"] isEqualToString:RPLocalizedString(NONE_STRING, @"")])
            {
                [udfView.fieldButton setText:RPLocalizedString(NONE_STRING, @"")];
            }
            else
            {
                //Implemented for US8763_HandleWhenDateUDFDoesNotHaveDefaultValue//JUHI
                if ([[udfDict objectForKey:@"defaultValue"]isKindOfClass:[NSString class]]&&[[udfDict objectForKey:@"defaultValue"] isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
                {
                    [udfView.fieldButton setText:[udfDict objectForKey:@"defaultValue"]];
                }
                else{
                    [udfView.fieldButton setText:[Util convertDateToString:[udfDict objectForKey:@"defaultValue"]]];
                }

            }

            udfView.fieldButton.hidden=NO;
            udfView.fieldValue.hidden=YES;
            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[sheetApprovalStatus isEqualToString:APPROVED_STATUS ])
            {
                udfView.userInteractionEnabled=NO;
            }
            else
                udfView.userInteractionEnabled=YES;
        }
        else if([[udfDict objectForKey:@"type"] isEqualToString:NUMERIC_UDF_TYPE])
        {
            udfView.fieldValue.text=[NSString stringWithFormat:@"%@",[udfDict objectForKey:@"defaultValue"]];
            udfView.fieldButton.hidden=YES;
            udfView.fieldValue.hidden=NO;
            udfView.fieldValue.keyboardType = UIKeyboardTypeNumberPad;
            //Fix for ios7//JUHI
            float version= [[UIDevice currentDevice].systemVersion newFloatValue];

            if (version>=7.0)
            {
                udfView.fieldValue.keyboardAppearance=UIKeyboardAppearanceDark;
            }
            udfView.decimalPoints=[[udfDict objectForKey: @"defaultDecimalValue"]intValue];
            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[sheetApprovalStatus isEqualToString:APPROVED_STATUS ])
            {
                udfView.userInteractionEnabled=NO;
            }
            else
                udfView.userInteractionEnabled=YES;
        }
        else if ([[udfDict objectForKey:@"type"] isEqualToString:DROPDOWN_UDF_TYPE])
        {
            [udfView.fieldButton setText:[udfDict objectForKey:@"defaultValue"]];
            udfView.fieldButton.hidden=NO;
            udfView.fieldValue.hidden=YES;
            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[sheetApprovalStatus isEqualToString:APPROVED_STATUS ])
            {
                udfView.userInteractionEnabled=NO;
            }
            else
                udfView.userInteractionEnabled=YES;
        }

        else if([[udfDict objectForKey:@"type"] isEqualToString:TEXT_UDF_TYPE])
        {
            udfView.fieldButton.text=[udfDict objectForKey:@"defaultValue"];
            udfView.fieldButton.hidden=NO;
            udfView.fieldValue.hidden=YES;
            if (([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[sheetApprovalStatus isEqualToString:APPROVED_STATUS ])&&([udfView.fieldButton.text isEqualToString:RPLocalizedString(ADD, @"")]||[udfView.fieldButton.text isEqualToString:RPLocalizedString(NONE_STRING, @"")]))
            {
                udfView.userInteractionEnabled=NO;
            }
            else
                udfView.userInteractionEnabled=YES;
        }


        udfView.udfType=[udfDict objectForKey:@"type"];
        [udfView setTag:i+1];
        [udfView setTotalCount:[customFieldArray count]];
        [udfView setDelegate:self];
        y=y+Each_Cell_Row_Height_44;
        footerHeight=footerHeight+Each_Cell_Row_Height_44+1;
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, 1)];
        lineView.backgroundColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:0.7];
        [self.footerView addSubview:lineView];

        [footerView addSubview:udfView];


        [udfView bringSubviewToFront:lineView];



        [self.footerView bringSubviewToFront:lineView];


    }


    if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE]|| [self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_TIMESHEETS_MODULE])
    {
        ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
        NSMutableArray *reasonForChangeArray = [approvalsModel getPendingTimesheetChangeReasonEntriesFromDB:self.sheetIdentity];
        if (reasonForChangeArray!=nil) {
            UIView *reasonForChangeView =[[UIView alloc]initWithFrame:CGRectMake(0.0, y+1, self.view.frame.size.width, Each_Cell_Row_Height_44)];
            reasonForChangeView.userInteractionEnabled = YES;

            UIImage *redInfoImage = [Util thumbnailImage:RED_INFOICON];
            UIImageView *redInfoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, redInfoImage.size.width,redInfoImage.size.height)];
            [redInfoImageView setImage:redInfoImage];
            [reasonForChangeView addSubview:redInfoImageView];

            UIButton  *reasonForChangeButton = [[UIButton alloc] initWithFrame:CGRectMake(15+redInfoImage.size.width+5, 0, SCREEN_WIDTH-redInfoImage.size.width-20, Each_Cell_Row_Height_44)];
            reasonForChangeButton.titleLabel.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14];
            reasonForChangeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            reasonForChangeButton.backgroundColor =[ UIColor clearColor] ;
            [reasonForChangeButton setTitle:RPLocalizedString(TimeSheetChangeHistoryTabbarTitle, @"") forState:UIControlStateNormal];
            [reasonForChangeButton setTitleColor:RepliconStandardBlackColor forState:UIControlStateNormal];
            reasonForChangeButton.userInteractionEnabled = YES;
            [reasonForChangeButton addTarget:self action:@selector(reasonForChangeButtonAction) forControlEvents:UIControlEventTouchUpInside];
            [reasonForChangeView addSubview:reasonForChangeButton];

            UIImage *indicatorImage = [Util thumbnailImage:RIGHT_INDICATOR_IMAGE];
            UIImageView *indicatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-indicatorImage.size.width-5, 15, indicatorImage.size.width,indicatorImage.size.height)];
            [indicatorImageView setImage:indicatorImage];
            [reasonForChangeView addSubview:indicatorImageView];
            [footerView addSubview:reasonForChangeView];
            CGRect frame = footerView.frame;
            frame.size.height = frame.size.height+Each_Cell_Row_Height_44;
            footerView.frame = frame;
            y= y+Each_Cell_Row_Height_44;
            footerHeight= footerHeight+Each_Cell_Row_Height_44+1;
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, 1)];
            lineView.backgroundColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:0.7];
            [self.footerView addSubview:lineView];

        }

    }

    BOOL isDisclaimer=YES;
    NSArray *disclaimerDetailsArr=nil;
    NSString *disclaimerStatusString=nil;

    if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
    {
        LoginModel *loginModel=[[LoginModel alloc]init];

        disclaimerStatusString=[loginModel getStatusForDisclaimerPermissionForColumnName:@"disclaimerTimesheetNoticePolicyUri"];



        TimesheetModel *timeSheetModel=[[TimesheetModel alloc]init];
        disclaimerDetailsArr=[timeSheetModel getAllDisclaimerDetailsFromDBForModule:TIMESHEET_MODULE_NAME];

    }
    else
    {
        ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            disclaimerDetailsArr=[approvalsModel getAllPendingDisclaimerDetailsFromDBForModule:TIMESHEET_MODULE_NAME];
            disclaimerStatusString=[approvalsModel getPendingStatusForDisclaimerPermissionForColumnName:@"disclaimerTimesheetNoticePolicyUri" forSheetUri:sheetIdentity];
        }
        else
        {


            disclaimerDetailsArr=[approvalsModel getAllPreviousDisclaimerDetailsFromDBForModule:TIMESHEET_MODULE_NAME];
            disclaimerStatusString=[approvalsModel getPreviousStatusForDisclaimerPermissionForColumnName:@"disclaimerTimesheetNoticePolicyUri" forSheetUri:sheetIdentity];
        }




    }

    NSString *disclamerTitle=nil;
    NSString *disclaimerDesc=nil;

    if (disclaimerDetailsArr!=nil)
    {
        NSDictionary *disclaimerDict=[disclaimerDetailsArr objectAtIndex:0];
        //Implementation as per US9172//JUHI
        if ([disclaimerDict objectForKey:@"title"]!=nil && ![[disclaimerDict objectForKey:@"title"] isKindOfClass:[NSNull class]] && ![[disclaimerDict objectForKey:@"title"] isEqualToString:@"<null>"]) {
            disclamerTitle=[disclaimerDict objectForKey:@"title"];
        }
        else
            disclamerTitle=@"";

        if ([disclaimerDict objectForKey:@"description"]!=nil && ![[disclaimerDict objectForKey:@"description"] isKindOfClass:[NSNull class]] && ![[disclaimerDict objectForKey:@"description"] isEqualToString:@"<null>"]) {
            disclaimerDesc=[disclaimerDict objectForKey:@"description"];
        }
        else
            disclaimerDesc=@"";

    }

    if ((disclamerTitle!=nil && ![disclamerTitle isKindOfClass:[NSNull class]] && ![disclamerTitle isEqualToString:@"<null>"]) || (disclaimerDesc!=nil && ![disclaimerDesc isKindOfClass:[NSNull class]] && ![disclaimerDesc isEqualToString:@"<null>"]))
    {
        if ([disclamerTitle isEqualToString:@""] && [disclaimerDesc isEqualToString:@""])
        {
            isDisclaimer=NO;
        }
        else
        {
            isDisclaimer=YES;
        }
    }
    else
    {
        isDisclaimer=NO;
    }


    BOOL isDisclaimerCheck=NO;

    CGSize expectedAttestationTitleLabelSize;

    CGSize expectedAttestationDescLabelSize ;
    heightofDisclaimerText=0.0;
    if (isDisclaimer)
    {


        NSString *disclaimerAccepted=nil;




        // Let's make an NSAttributedString first
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:disclamerTitle];
        //Add LineBreakMode
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        // Add Font
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_17]} range:NSMakeRange(0, attributedString.length)];

        //Now let's make the Bounding Rect
        expectedAttestationTitleLabelSize = [attributedString boundingRectWithSize:CGSizeMake(300, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;


        UILabel *attestationTitlelabel=[[UILabel alloc] init];
        attestationTitlelabel.text=disclamerTitle;
        attestationTitlelabel.textColor=RepliconStandardBlackColor;
        [attestationTitlelabel setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_17]];
        [attestationTitlelabel setBackgroundColor:[UIColor clearColor]];
        attestationTitlelabel.frame=CGRectMake(12.0,
                                               y+30,
                                               SCREEN_WIDTH-24,
                                               expectedAttestationTitleLabelSize.height);
        attestationTitlelabel.numberOfLines=100;

        [footerView addSubview:attestationTitlelabel];
        
        footerHeight = attestationTitlelabel.frame.origin.y +attestationTitlelabel.frame.size.height;



        // Let's make an NSAttributedString first
        attributedString = [[NSMutableAttributedString alloc] initWithString:disclaimerDesc];
        //Add LineBreakMode
        paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        // Add Font
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_16]} range:NSMakeRange(0, attributedString.length)];

        //Now let's make the Bounding Rect
        expectedAttestationDescLabelSize = [attributedString boundingRectWithSize:CGSizeMake(300, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

        UILabel *attestationDesclabel=[[UILabel alloc] init];
        attestationDesclabel.text=disclaimerDesc ;
        attestationDesclabel.textColor = [Util colorWithHex:@"#666666" alpha:1.0f];
        [attestationDesclabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_16]];
        [attestationDesclabel setBackgroundColor:[UIColor clearColor]];

        attestationDesclabel.frame=CGRectMake(12.0,
                                              attestationTitlelabel.frame.origin.y+10+attestationTitlelabel.frame.size.height,
                                              SCREEN_WIDTH-24,
                                              expectedAttestationDescLabelSize.height);



        attestationDesclabel.numberOfLines=100;

        [footerView addSubview:attestationDesclabel];
        
        footerHeight = attestationDesclabel.frame.origin.y +attestationDesclabel.frame.size.height+15;

        if (disclaimerStatusString!=nil && ![disclaimerStatusString isKindOfClass:[NSNull class]])
        {
            if ([disclaimerStatusString isEqualToString:@"urn:replicon:policy:timesheet:disclaimer-acceptance:disclaimer-acceptance-required"]||[disclaimerStatusString isEqualToString:@"urn:replicon:policy:timesheet:explicit-notice-acceptance:required"])
            {
                isDisclaimerCheck=TRUE;
            }

        }





        if (isDisclaimerCheck)
        {
            NSMutableArray *daySummaryArray=nil;
            if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
            {
                TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                daySummaryArray=[timesheetModel getAllTimesheetDaySummaryFromDBForTimesheet:sheetIdentity];

            }
            else
            {
                ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
                if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                {
                    daySummaryArray=[approvalsModel getAllPendingTimesheetDaySummaryFromDBForTimesheet:sheetIdentity];
                }
                else
                {
                    daySummaryArray=[approvalsModel getAllPreviousTimesheetDaySummaryFromDBForTimesheet:sheetIdentity];
                }



            }

            int noticeExplicitlyAccepted=0;
            if ([daySummaryArray count]>0 && daySummaryArray!=nil)
            {
                noticeExplicitlyAccepted=[[[daySummaryArray objectAtIndex:0] objectForKey:@"noticeExplicitlyAccepted"] intValue];
            }
            UIImage *radioDeselectedImage=nil;
            if (noticeExplicitlyAccepted==0)
            {
                radioDeselectedImage = [Util thumbnailImage:CheckBoxDeselectedImage];
                [self setDisclaimerSelected:NO];
                disclaimerAccepted=RPLocalizedString(@"Accept", @"");
            }
            else
            {
                radioDeselectedImage = [Util thumbnailImage:CheckBoxSelectedImage];
                [self setDisclaimerSelected:YES];
                disclaimerAccepted=RPLocalizedString(@"Accepted", @"");
            }
            self.radioButton = [UIButton buttonWithType:UIButtonTypeCustom];


            [self.radioButton setFrame:CGRectMake(4.0,
                                                  attestationDesclabel.frame.origin.y+expectedAttestationDescLabelSize.height+5,
                                                  radioDeselectedImage.size.width+20.0,
                                                  radioDeselectedImage.size.height+19.0)];



            [self.radioButton setImage:radioDeselectedImage forState:UIControlStateNormal];
            //[self.radioButton setImage:radioSelected forState:UIControlStateHighlighted];
            [self.radioButton setBackgroundColor:[UIColor clearColor]];

            [self.radioButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [self.radioButton setUserInteractionEnabled:YES];
            [self.radioButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 8.0, -6, 0.0)];

            [self.radioButton setAccessibilityLabel:@"disclaimer_btn"];

            [self.radioButton addTarget:self action:@selector(selectRadioButton:) forControlEvents:UIControlEventTouchUpInside];

            [self.footerView addSubview:radioButton];
            
            
            footerHeight = self.radioButton.frame.origin.y +self.radioButton.frame.size.height;

            // Let's make an NSAttributedString first
            attributedString = [[NSMutableAttributedString alloc] initWithString:disclaimerAccepted];
            //Add LineBreakMode
            paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_17]} range:NSMakeRange(0, attributedString.length)];

            //Now let's make the Bounding Rect
            CGSize expectedDisclaimerTitleLabelSize = [attributedString boundingRectWithSize:CGSizeMake(((SCREEN_WIDTH-20)-(radioDeselectedImage.size.width+10.0)), 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

            UILabel *tempDisclaimerTitleLabel=[[UILabel alloc] init];
            self.disclaimerTitleLabel=tempDisclaimerTitleLabel;

            self.disclaimerTitleLabel.text=disclaimerAccepted ;
            self.disclaimerTitleLabel.textColor=RepliconStandardBlackColor;
            [self.disclaimerTitleLabel setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_17]];
            [self.disclaimerTitleLabel setBackgroundColor:[UIColor clearColor]];

            self.disclaimerTitleLabel.frame=CGRectMake(radioDeselectedImage.size.width+20.0,
                                                       attestationDesclabel.frame.origin.y+25.0+expectedAttestationDescLabelSize.height,
                                                       ((SCREEN_WIDTH-20)-(radioDeselectedImage.size.width+10.0)),
                                                       expectedDisclaimerTitleLabelSize.height);




            self.disclaimerTitleLabel.numberOfLines=100;





            [footerView addSubview:disclaimerTitleLabel];
            
            footerHeight = self.radioButton.frame.origin.y +radioDeselectedImage.size.height+15;
            y=radioButton.frame.origin.y+radioDeselectedImage.size.height+15;
        }

        else
        {
            y=attestationDesclabel.frame.origin.y+attestationDesclabel.frame.size.height+15;
            footerHeight=attestationDesclabel.frame.origin.y+attestationDesclabel.frame.size.height+15;
        }

        heightofDisclaimerText=expectedAttestationDescLabelSize.height+650;




    }

    if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[sheetApprovalStatus isEqualToString:APPROVED_STATUS ]||![parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
    {
        [radioButton setUserInteractionEnabled:NO];
    }

    NSDictionary *permittedApprovalAcionsDict=[self.supportDataModel getTimesheetPermittedApprovalActionsDataToDBWithUri:sheetIdentity];


    BOOL canSubmit=FALSE;
    BOOL canUnsubmit=FALSE;
    BOOL canReopen=FALSE;

    if (permittedApprovalAcionsDict!=nil &&  ![permittedApprovalAcionsDict isKindOfClass:[NSNull class]])
    {
        canSubmit=[[permittedApprovalAcionsDict objectForKey:@"canSubmit"]boolValue];
        canUnsubmit=[[permittedApprovalAcionsDict objectForKey:@"canUnsubmit"]boolValue];
        canReopen=[[permittedApprovalAcionsDict objectForKey:@"canReopen"]boolValue];

    }

    UIButton *submitButton;
    if ((canSubmit||canUnsubmit||canReopen))
    {

        submitButton = [UIButton buttonWithType:UIButtonTypeSystem];
        CGFloat buttonWidth = 240.0f;
        CGFloat xOrigin = (CGRectGetWidth(self.view.bounds) - buttonWidth) / 2.0f;
        [submitButton setFrame:CGRectMake(xOrigin, y+buttonSpace, buttonWidth, 44.0f)];

        NSString *buttonTitle;
        if(canSubmit)
        {

            BOOL canResubmit=[self canResubmitTimeSheetForURI:self.sheetIdentity];

            if (canResubmit)
            {
                buttonTitle = RPLocalizedString(Resubmit_Button_title, @"");
                [submitButton addTarget:self action:@selector(reSubmitAction:) forControlEvents:UIControlEventTouchUpInside];
                self.actionType=@"Re-Submit";
            }
            else
            {
                buttonTitle = RPLocalizedString(Submit_Button_title, @"");
                [submitButton addTarget:self action:@selector(submitAction:) forControlEvents:UIControlEventTouchUpInside];
                self.actionType=@"Submit";
            }


        }
        else if(canUnsubmit)
        {
            buttonTitle = RPLocalizedString(Reopen_Button_title, @"");
            [submitButton addTarget:self action:@selector(unSubmitAction:) forControlEvents:UIControlEventTouchUpInside];
            self.actionType=@"Unsubmit";
        }
        else if(canReopen)
        {
            //UI Changes
            //implemented as per Time-723
            buttonTitle = RPLocalizedString(Reopen_Button_title, @"");
            [submitButton addTarget:self action:@selector(unSubmitAction:) forControlEvents:UIControlEventTouchUpInside];
            self.actionType=@"Unsubmit";
        }

        [footerView addSubview:submitButton];
        self.submitButton = submitButton;
        footerHeight = submitButton.frame.origin.y +submitButton.frame.size.height+buttonSpace;
        [self.submitButton setAccessibilityLabel:@"uia_description_done_button_identifier"];

        [self.buttonStylist styleRegularButton:self.submitButton title:buttonTitle];
    }

    NSUInteger buttonHeight = ([self.customFieldArray count]*Each_Cell_Row_Height_44);
    if ((canSubmit||canUnsubmit||canReopen))
    {
        buttonHeight=buttonHeight-timeoffApprovedHeight_NonTimeOffNonsubmittedHeight;
    }
    else
    {
        buttonHeight=buttonHeight-spaceHeight;
    }


    if (isDisclaimer)
    {

        if (isDisclaimerCheck)
        {
            buttonHeight=buttonHeight+expectedAttestationTitleLabelSize.height+expectedAttestationDescLabelSize.height+WithRadioSpaceHeight;
        }
        else
        {
            buttonHeight=buttonHeight+expectedAttestationTitleLabelSize.height+expectedAttestationDescLabelSize.height+WithOutRadioSpaceHeight;
        }

    }
    else
    {
        y=y-buttonSpace;
        footerHeight = footerHeight -buttonSpace;
    }

    if (![parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]] && ![self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_TIMESHEETS_MODULE])
    {
        CGFloat approvalsFooterViewHeight = 205.0;
        ApprovalTablesFooterView *approvalTablesFooterView = [[ApprovalTablesFooterView alloc] initWithFrame:CGRectMake(0, footerHeight+buttonSpace, self.view.width, approvalsFooterViewHeight)
                                                                                                  withStatus:sheetApprovalStatus];
        approvalTablesFooterView.delegate = self;
        [self.footerView addSubview:approvalTablesFooterView];
        footerHeight = approvalTablesFooterView.frame.origin.y +approvalTablesFooterView.frame.size.height;
    }
    CGRect footerFrame = self.footerView.frame;
    footerFrame.size.height = footerHeight+10;
    self.footerView.frame = footerFrame;
    [self.footerView sizeToFit];

    [self.currentTimesheetTableView setTableFooterView:self.footerView];
}

-(float)getWidthForString:(NSString *)string fontSize:(int)fontSize forWidth:(float)width
{

    // Let's make an NSAttributedString first
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    //Add LineBreakMode
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
    // Add Font
    [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} range:NSMakeRange(0, attributedString.length)];

    //Now let's make the Bounding Rect
    CGSize mainSize = [attributedString boundingRectWithSize:CGSizeMake(width, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

    if (mainSize.width==0 && mainSize.height ==0)
    {
        mainSize=CGSizeMake(0,0);
    }
    return mainSize.width;
}

-(void)reasonForChangeButtonAction
{
    ApproveTimeSheetChangeViewController* obj_approveTimeSheetChangeViewController = [[ApproveTimeSheetChangeViewController alloc] init];
    obj_approveTimeSheetChangeViewController.sheetIdentity = self.sheetIdentity;
    [parentDelegate pushToViewController:obj_approveTimeSheetChangeViewController];
}


-(void)addTotalValueLable: (NSString *)totalLabelValue {

    UILabel *totalLabel=[[UILabel alloc]initWithFrame:EntriesTotalLabelFrame];
    [totalLabel setText:[NSString stringWithFormat:@"%@",RPLocalizedString(TotalString, TotalString) ]];//UI Changes//JUHI
    [totalLabel setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];
    [self.totallabelView addSubview:totalLabel];

    UILabel *totalValueLabel=[[UILabel alloc]initWithFrame: EntriesTotalHoursLabelFrame];
    [totalValueLabel setText:totalLabelValue];
    [totalValueLabel setTextAlignment: NSTextAlignmentRight];
    [totalValueLabel setFont:[UIFont fontWithName:RepliconFontFamilySemiBold size:RepliconFontSize_17]];
    totalValueLabel.accessibilityLabel = @"timesheet_total_value_label";
    [self.totallabelView addSubview:totalValueLabel];


}
-(void)RecievedData{

    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [self.appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    [self updateTimesheetFormat];
    if (isMultiDayInOutTimesheetUser)
    {

        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        NSMutableArray *allTimeEntriesArray=[timesheetModel getAllTimeEntriesForSheetFromDB:sheetIdentity];
        if ([allTimeEntriesArray count]==0)
        {

            NSArray *timesheetInfoArray=[timesheetModel getTimeSheetInfoSheetIdentity:sheetIdentity];
            if ([timesheetInfoArray count]>0)
            {
                NSString *tsFormat=[[timesheetInfoArray objectAtIndex:0] objectForKey:@"timesheetFormat"];
                if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
                {
                    if([tsFormat isEqualToString:EXTENDED_INOUT_TIMESHEET])
                    {
                        self.isExtendedInOut=TRUE;
                    }
                    
                }

            }

        }
        else
        {
            NSString *timesheetFormat=[timesheetModel getTimesheetFormatInfoFromDBForTimesheetUri:sheetIdentity];
            if([timesheetFormat isEqualToString:EXTENDED_INOUT_TIMESHEET])
            {
                self.isExtendedInOut=TRUE;
            }
        }



    }
    [self createCurrentTimesheetEntryList];
    
    if (self.currentTimesheetArray == nil || [self.currentTimesheetArray count]==0) {
        return [self showTimesheetFormatNotSupported];
    }

    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
    BOOL canEditTimesheet=[timesheetModel getTimeSheetEditStatusForSheetFromDB:sheetIdentity];

    if (!canEditTimesheet)
    {//Fix for Approval status//JUHI
        self.sheetStatus=sheetApprovalStatus;
        sheetApprovalStatus=APPROVED_STATUS;
    }


    [self createUdfs];
    [self createFooter];

    [currentTimesheetTableView reloadData];
    //Implemented as per US7984
    if ([self.totalHours newDoubleValue]==0.0) {
        [self.navigationItem setRightBarButtonItem:nil];
    }
    else {
        [self.navigationItem setRightBarButtonItem:self.rightBarButton animated:NO];
    }
    
    if (self.timesheetMainPageController)
    {
        self.timesheetMainPageController.hasUserChangedAnyValue = NO;
        [self.timesheetMainPageController.navigationItem setLeftBarButtonItem:nil animated:NO];
    }
    
}
-(void)updateTimesheetFormat
{
    if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
    {
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        NSMutableArray *allTimeEntriesArray=[timesheetModel getAllTimeEntriesForSheetFromDB:sheetIdentity];
        if ([allTimeEntriesArray count]==0)
        {
            NSArray *timesheetInfoArray=[timesheetModel getTimeSheetInfoSheetIdentity:sheetIdentity];
            if ([timesheetInfoArray count]>0)
            {
                NSString *tsFormat=[[timesheetInfoArray objectAtIndex:0] objectForKey:@"timesheetFormat"];
                if (![tsFormat isKindOfClass:[NSNull class]]&& tsFormat!=nil)
                {
                    if ([tsFormat isEqualToString:STANDARD_TIMESHEET])
                    {
                        self.isMultiDayInOutTimesheetUser=NO;
                    }
                    else
                    {
                        self.isMultiDayInOutTimesheetUser=YES;
                    }
                }

            }

        }
        else
        {
            NSString *timesheetFormat=[timesheetModel getTimesheetFormatInfoFromDBForTimesheetUri:sheetIdentity];
            if (![timesheetFormat isKindOfClass:[NSNull class]]&& timesheetFormat!=nil)
            {
                if ([timesheetFormat isEqualToString:STANDARD_TIMESHEET])
                {
                    self.isMultiDayInOutTimesheetUser=NO;
                }
                else
                {
                    self.isMultiDayInOutTimesheetUser=YES;
                }
            }


        }


    }
    else
    {
        ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
        NSMutableArray *allTimeEntriesArray=nil;
        NSMutableArray *arrayDict=nil;
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            arrayDict=[approvalsModel getPendingApprovalDataForTimesheetSheetURI:sheetIdentity];
            allTimeEntriesArray=[approvalsModel getAllPendingTimeEntriesForSheetFromDB:sheetIdentity];

        }
        else
        {
            arrayDict=[approvalsModel getPreviousApprovalDataForTimesheetSheetURI:sheetIdentity];
            allTimeEntriesArray=[approvalsModel getAllPreviousTimeEntriesForSheetFromDB:sheetIdentity];
        }

        if ([allTimeEntriesArray count]==0)
        {
            if ([arrayDict count]>0)
            {
                NSString *tsFormat=[[arrayDict objectAtIndex:0] objectForKey:@"timesheetFormat"];
                if (![tsFormat isKindOfClass:[NSNull class]]&& tsFormat!=nil)
                {
                    if ([tsFormat isEqualToString:STANDARD_TIMESHEET])
                    {
                        self.isMultiDayInOutTimesheetUser=NO;
                    }
                    else
                    {
                        self.isMultiDayInOutTimesheetUser=YES;
                    }

                }

            }

        }
        else
        {

            NSString *timesheetFormat=nil;
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                timesheetFormat=[approvalsModel getPendingTimesheetFormatInfoFromDBForTimesheetUri:sheetIdentity];
            }

            else
            {
                timesheetFormat=[approvalsModel getPreviousTimesheetFormatInfoFromDBForTimesheetUri:sheetIdentity];
            }
            if (![timesheetFormat isKindOfClass:[NSNull class]]&& timesheetFormat!=nil)
            {
                if ([timesheetFormat isEqualToString:STANDARD_TIMESHEET])
                {
                    self.isMultiDayInOutTimesheetUser=NO;
                }
                else
                {
                    self.isMultiDayInOutTimesheetUser=YES;
                }
            }


        }



    }

}
#pragma mark -
#pragma mark - UITableView Delegates
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:RepliconStandardBackgroundColor];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return Each_Cell_Row_Height_44 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([currentTimesheetArray count]>0)
    {
        return [currentTimesheetArray count]+1;
    }

    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier;
    CellIdentifier = @"Cell";
    UITableViewCell *cell = (CurrentTimeSheetsCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CurrentTimeSheetsCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    }
    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }

    [(CurrentTimeSheetsCellView *)cell setDelegate:self];
    UIColor *color=nil;
    [(CurrentTimeSheetsCellView *)cell setFieldType:nil];
    //Implementation for MOBI-261//JUHI
    if (indexPath.row==0)
    {
        UILabel *statusLb= [[UILabel alloc]init];
        NSString *statusStr=nil;

        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        NSMutableArray *arrayFromDB=nil;
        if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
        {

            arrayFromDB=[timesheetModel getAllTimesheetApprovalFromDBForTimesheet:sheetIdentity];
        }
        else if([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            ApprovalsModel *apprvalModel=[[ApprovalsModel alloc]init];
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                arrayFromDB=[apprvalModel getAllPendingTimesheetApprovalFromDBForTimesheet:sheetIdentity];

            }
            else
            {
                arrayFromDB=[apprvalModel getAllPreviousTimesheetApprovalFromDBForTimesheet:sheetIdentity];
            }

        }
        //Fix for Approval status//JUHI
        BOOL canEditTimesheet=[timesheetModel getTimeSheetEditStatusForSheetFromDB:sheetIdentity];
        NSString *statusApproval=nil;
        if (!canEditTimesheet||[self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_TIMESHEETS_MODULE])
        {
            statusApproval=sheetStatus;
            if ([sheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ])
            {
                statusStr=RPLocalizedString(WAITING_FOR_APRROVAL_STATUS, @"");
            }
            else if ([sheetStatus isEqualToString:APPROVED_STATUS ]) {
                statusStr=RPLocalizedString(APPROVED_STATUS,APPROVED_STATUS);
            }
            else if ([sheetStatus isEqualToString:REJECTED_STATUS ]){
                statusStr=RPLocalizedString(REJECTED_STATUS,@"");
            }
            else{
                statusStr=RPLocalizedString(NOT_SUBMITTED_STATUS, @"");

            }
            statusLb.text=[NSString stringWithFormat:@"%@",statusStr];
        }
        else{
            statusApproval=self.sheetApprovalStatus;
            if ([self.sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]) {
                statusStr=RPLocalizedString(WAITING_FOR_APRROVAL_STATUS, @"");
            }
            else if ([self.sheetApprovalStatus isEqualToString:APPROVED_STATUS ]) {
                statusStr=RPLocalizedString(APPROVED_STATUS,APPROVED_STATUS);
            }
            else if ([self.sheetApprovalStatus isEqualToString:REJECTED_STATUS ]){
                statusStr=RPLocalizedString(REJECTED_STATUS,@"");
            }
            else{
                statusStr=RPLocalizedString(NOT_SUBMITTED_STATUS, @"");
            }

            statusLb.text=[NSString stringWithFormat:@"%@",statusStr];
        }

        cell.contentView.backgroundColor = [UIColor whiteColor];


        statusLb.frame=CGRectMake(0, 0, tableView.bounds.size.width, Each_Cell_Row_Height_44);
        statusLb.textAlignment=NSTextAlignmentCenter;
        statusLb.font = [UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_14];

        statusLb.textColor= [self.approvalStatusPresenter colorForStatus:statusApproval];
        [cell.contentView addSubview:statusLb];

        if ([arrayFromDB count]>0)
        {
            
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            attachment.image = [UIImage imageNamed:@"icon_comments_blue"];
            
            NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
            
            NSMutableAttributedString *statusString= [[NSMutableAttributedString alloc] initWithString:[statusLb.text stringByAppendingString:@" "]];
            [statusString appendAttributedString:attachmentString];
            
            statusLb.attributedText = statusString;
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        }
        else
        {
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }

    }
    else{
        // For first row, draw the top separator line
        if (indexPath.row == 1) {
            UIImage *lowerImage = [Util thumbnailImage:Cell_HairLine_Image];
            UIImageView *bottomSeparatorImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), lowerImage.size.height)];
            [bottomSeparatorImageView setImage:lowerImage];
            [cell.contentView addSubview:bottomSeparatorImageView];
        }

        NSInteger index=indexPath.row-1;
        id timeSheetOb=[currentTimesheetArray objectAtIndex:index];

        if ([timeSheetOb isKindOfClass:[TimesheetObject class]])
        {
            if ([timeSheetOb isWeeklyDayOff]||[timeSheetOb isHolidayDayOff])
            {
                color=[Util colorWithHex:@"#999999" alpha:1];
            }

            [(CurrentTimeSheetsCellView *)cell createCellWithLeftString:[timeSheetOb entryDate]
                                                     andLeftStringColor:color
                                                         andRightString:[timeSheetOb numberOfHours]
                                                    andRightStringColor:color
                                                            hasComments:[timeSheetOb hasComments]
                                                             hasTimeoff:[timeSheetOb hasTimeOff]
                                                                withTag:indexPath.row];
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];

    }


    return cell;

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLS_LOG(@"-----Row clicked on CurrentTimesheetViewController----- ");

    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];

    //Implementation for MOBI-261//JUHI
    if (indexPath.row==0)
    {
        ApproverCommentViewController *approverCommentCtrl=[[ApproverCommentViewController alloc]init];
        approverCommentCtrl.sheetIdentity=sheetIdentity;
        approverCommentCtrl.viewType=@"Timesheet";
        if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
        {
            approverCommentCtrl.delegate=self;
        }
        else
        {
            approverCommentCtrl.delegate=parentDelegate;
            approverCommentCtrl.approvalsModuleName=self.approvalsModuleName ;
        }
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        NSMutableArray *arrayFromDB=nil;
        if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
        {

            arrayFromDB=[timesheetModel getAllTimesheetApprovalFromDBForTimesheet:sheetIdentity];
        }
        else if([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            ApprovalsModel *apprvalModel=[[ApprovalsModel alloc]init];
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                arrayFromDB=[apprvalModel getAllPendingTimesheetApprovalFromDBForTimesheet:sheetIdentity];

            }
            else
            {
                arrayFromDB=[apprvalModel getAllPreviousTimesheetApprovalFromDBForTimesheet:sheetIdentity];
            }

        }

        if ([arrayFromDB count]>0)
        {
            if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
            {
                [self.navigationController pushViewController:approverCommentCtrl animated:YES];
            }
            else if([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
            {
                [parentDelegate pushToViewController:approverCommentCtrl];
            }

        }


    }
    else
    {
        NSInteger index=indexPath.row-1;

        TimesheetMainPageController *tmpTimesheetMainPageController=[[TimesheetMainPageController alloc]init];
        float version= [[UIDevice currentDevice].systemVersion newFloatValue];
        if (version<7.0)
        {
            self.timesheetMainPageController=tmpTimesheetMainPageController;
        }
        else
        {
            self.timesheetMainPageController=tmpTimesheetMainPageController;//Ullas M L temporary fix
        }

        self.timesheetMainPageController.tsEntryDataArray=currentTimesheetArray;
        self.timesheetMainPageController.pageControl.currentPage=index;
        self.timesheetMainPageController.currentlySelectedPage=index;
        self.timesheetMainPageController.timesheetURI=sheetIdentity;
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_TIMESHEETS_MODULE])
        {
            self.timesheetMainPageController.timesheetStatus=APPROVED_STATUS;
        }
        else
        {
            self.timesheetMainPageController.timesheetStatus=self.sheetApprovalStatus;
        }
        if (isExtendedInOut)
        {
            self.timesheetMainPageController.multiDayInOutType=EXTENDED_IN_OUT_TIMESHEET_TYPE;
        }
        else
        {
            self.timesheetMainPageController.multiDayInOutType=NOT_EXTENDED_IN_OUT_TIMESHEET_TYPE;
        }

        self.timesheetMainPageController.isDisclaimerRequired=self.disclaimerSelected;
        self.timesheetMainPageController.isMultiDayInOutTimesheetUser=self.isMultiDayInOutTimesheetUser;
        self.timesheetMainPageController.sheetLevelUdfArray=self.customFieldArray;
        self.timesheetMainPageController.hasUserChangedAnyValue=NO;

        if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
        {
            TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
            self.timesheetMainPageController.parentDelegate=self;
            NSMutableArray *allTimeEntriesArray=[timesheetModel getAllTimeEntriesForSheetFromDB:sheetIdentity];
            if ([allTimeEntriesArray count]==0)
            {
                NSArray *timesheetInfoArray=[timesheetModel getTimeSheetInfoSheetIdentity:sheetIdentity];
                if ([timesheetInfoArray count]>0)
                {
                    NSString *tsFormat=[[timesheetInfoArray objectAtIndex:0] objectForKey:@"timesheetFormat"];
                    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
                    {
                        if ([tsFormat isEqualToString:STANDARD_TIMESHEET])
                        {
                            self.isMultiDayInOutTimesheetUser=NO;
                        }
                        else
                        {
                            self.isMultiDayInOutTimesheetUser=YES;
                        }
                    }

                }

                if (self.isMultiDayInOutTimesheetUser)
                {
                    self.timesheetMainPageController.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[timesheetModel getTimeEntriesForSheetFromDB:sheetIdentity]];

                }
                else
                {
                    NSString *timesheetFormat=[timesheetModel getTimesheetFormatInfoFromDBForTimesheetUri:sheetIdentity];
                    self.timesheetMainPageController.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[timesheetModel getGroupedStandardTimeEntriesForSheetFromDB:sheetIdentity andTimesheetFormat:timesheetFormat]];

                }

            }
            else
            {
                NSString *timesheetFormat=[timesheetModel getTimesheetFormatInfoFromDBForTimesheetUri:sheetIdentity];
                if (![timesheetFormat isKindOfClass:[NSNull class]]&& timesheetFormat!=nil)
                {
                    if ([timesheetFormat isEqualToString:STANDARD_TIMESHEET])
                    {
                        self.timesheetMainPageController.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[timesheetModel getGroupedStandardTimeEntriesForSheetFromDB:sheetIdentity andTimesheetFormat:timesheetFormat]];

                    }
                    else if ([timesheetFormat isEqualToString:EXTENDED_INOUT_TIMESHEET])
                    {
                        self.timesheetMainPageController.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[timesheetModel getTimeEntriesForExtendedInOutSheetFromDB:sheetIdentity andTimeSheetFormat:timesheetFormat]];

                    }

                    else
                    {

                        self.timesheetMainPageController.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[timesheetModel getTimeEntriesForSheetFromDB:sheetIdentity]];
                        
                    }
                }


            }

            [self.navigationController pushViewController:self.timesheetMainPageController animated:YES];

        }
        else if([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            self.timesheetMainPageController.parentDelegate=parentDelegate;
            self.timesheetMainPageController.userUri=userUri;
            ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
            NSMutableArray *allTimeEntriesArray=nil;
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                allTimeEntriesArray=[approvalModel getAllPendingTimeEntriesForSheetFromDB:sheetIdentity];
            }
            else
            {
                allTimeEntriesArray=[approvalModel getAllPreviousTimeEntriesForSheetFromDB:sheetIdentity];
            }

            if ([allTimeEntriesArray count]==0)
            {
                NSMutableArray *arrayDict=nil;
                if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                {
                    arrayDict=[approvalModel getPendingApprovalDataForTimesheetSheetURI:sheetIdentity];

                }
                else
                {
                    arrayDict=[approvalModel getPreviousApprovalDataForTimesheetSheetURI:sheetIdentity];
                }
                BOOL tmpisMultiDayInOutTimesheetFormat=NO;
                if ([allTimeEntriesArray count]==0)
                {
                    if ([arrayDict count]>0)
                    {
                        NSString *tsFormat=[[arrayDict objectAtIndex:0] objectForKey:@"timesheetFormat"];
                        if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
                        {
                            if ([tsFormat isEqualToString:STANDARD_TIMESHEET])
                            {
                                tmpisMultiDayInOutTimesheetFormat=NO;
                            }
                            else
                            {
                                tmpisMultiDayInOutTimesheetFormat=YES;
                            }
                        }


                    }

                }

                if (tmpisMultiDayInOutTimesheetFormat)
                {
                    if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                    {
                        self.timesheetMainPageController.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[approvalModel getPendingTimeEntriesForSheetFromDB:sheetIdentity]];
                    }
                    else
                    {
                        self.timesheetMainPageController.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[approvalModel getPreviousTimeEntriesForSheetFromDB:sheetIdentity]];
                    }


                }
                else
                {
                    if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                    {
                        self.timesheetMainPageController.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[approvalModel getPendingGroupedStandardTimeEntriesForSheetFromDB:sheetIdentity]];
                    }
                    else
                    {
                        self.timesheetMainPageController.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[approvalModel getPreviousGroupedStandardTimeEntriesForSheetFromDB:sheetIdentity]];
                    }


                }

            }
            else
            {
                NSString *timesheetFormat=nil;
                if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                {
                    timesheetFormat=[approvalModel getPendingTimesheetFormatInfoFromDBForTimesheetUri:sheetIdentity];
                }
                else
                {
                    timesheetFormat=[approvalModel getPreviousTimesheetFormatInfoFromDBForTimesheetUri:sheetIdentity];
                }
                if (![timesheetFormat isKindOfClass:[NSNull class]]&& timesheetFormat!=nil)
                {
                    if ([timesheetFormat isEqualToString:STANDARD_TIMESHEET] )
                    {
                        if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                        {
                            self.timesheetMainPageController.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[approvalModel getPendingGroupedStandardTimeEntriesForSheetFromDB:sheetIdentity]];
                        }
                        else
                        {
                            self.timesheetMainPageController.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[approvalModel getPreviousGroupedStandardTimeEntriesForSheetFromDB:sheetIdentity]];

                        }


                    }//DE19662 Ullas M L
                    else if ([timesheetFormat isEqualToString:EXTENDED_INOUT_TIMESHEET])
                    {
                        if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                        {
                            self.timesheetMainPageController.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[approvalModel getPendingTimeEntriesForExtendedInOutSheetFromDB:sheetIdentity]];
                        }
                        else
                        {
                            self.timesheetMainPageController.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[approvalModel getPreviousTimeEntriesForExtendedInOutSheetFromDB:sheetIdentity]];

                        }


                    }
                    else
                    {
                        if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                        {
                            self.timesheetMainPageController.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[approvalModel getPendingTimeEntriesForSheetFromDB:sheetIdentity]];
                        }
                        else
                        {
                            self.timesheetMainPageController.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[approvalModel getPreviousTimeEntriesForSheetFromDB:sheetIdentity]];
                        }
                        
                        
                    }

                }

            }

            [parentDelegate pushToViewController:self.timesheetMainPageController];

        }






    }

    [currentTimesheetTableView deselectRowAtIndexPath:indexPath animated:NO];



}
#pragma mark -
#pragma mark - UIPIckerView Delegates
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return self.view.width;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 40;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 2;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return @"data";
}
#pragma mark -
#pragma mark - Other methods

-(void)handleButtonClicks:(NSInteger)selectedButtonTag withType:(NSString*)typeStr
{
    if (selectedUdfCell!=selectedButtonTag)
    {
        timesheetUdfView.isSelected=NO;
        [timesheetUdfView setSelectedColor:timesheetUdfView.isSelected];
    }

    self.selectedUdfCell=selectedButtonTag;
    [lastUsedTextField resignFirstResponder];

    if ([typeStr isEqualToString:DATE_UDF_TYPE])
    {

        TimesheetUdfView *udfview=(TimesheetUdfView*)[self.footerView viewWithTag:selectedUdfCell];
        udfview.isSelected=YES;
        [udfview setSelectedColor:udfview.isSelected];
        [udfview.fieldValue resignFirstResponder];
        self.timesheetUdfView=udfview;
        [self resetTableSize:YES];
        [self datePickerAction];

    }
    if ([typeStr isEqualToString:DROPDOWN_UDF_TYPE])
    {
        TimesheetUdfView *udfview=(TimesheetUdfView*)[self.footerView viewWithTag:selectedUdfCell];
        udfview.isSelected=YES;
        [udfview setSelectedColor:udfview.isSelected];
        [udfview.fieldValue resignFirstResponder];
        self.timesheetUdfView=udfview;
        [self doneClicked];

        [self dataAction:selectedButtonTag];
    }
    if ([typeStr isEqualToString:NUMERIC_UDF_TYPE])
    {
        [self numericKeyPadAction:selectedUdfCell];
    }
    if ([typeStr isEqualToString:TEXT_UDF_TYPE])
    {
        TimesheetUdfView *udfview=(TimesheetUdfView*)[self.footerView viewWithTag:selectedUdfCell];
        udfview.isSelected=YES;
        [udfview setSelectedColor:udfview.isSelected];
        [udfview.fieldValue resignFirstResponder];
        self.timesheetUdfView=udfview;
        [self doneClicked];

        [self textUdfAction:selectedButtonTag];
    }



}
-(void)textUdfAction:(NSInteger)selectedCell{

    TimesheetUdfView *udfview=(TimesheetUdfView*)[self.footerView viewWithTag:selectedUdfCell];

    AddDescriptionViewController *addDescriptionViewCtrl=[[AddDescriptionViewController alloc]init];

    addDescriptionViewCtrl.fromTextUdf =YES;
    if ([[udfview fieldButton].text isEqualToString:RPLocalizedString(ADD, @"")]||[[udfview fieldButton].text isEqualToString:RPLocalizedString(NONE_STRING, @"")])
    {
        [addDescriptionViewCtrl setDescTextString:@""];
    }
    else
        [addDescriptionViewCtrl setDescTextString:[udfview fieldButton].text];

    [addDescriptionViewCtrl setViewTitle:[udfview fieldName].text ];
    addDescriptionViewCtrl.descControlDelegate=self;

    if (([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||([sheetApprovalStatus isEqualToString:APPROVED_STATUS ])))
    {
        [addDescriptionViewCtrl setIsNonEditable:YES];
    }
    else
        [addDescriptionViewCtrl setIsNonEditable:NO];

    if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
    {
        [self.navigationController pushViewController:addDescriptionViewCtrl animated:YES];
    }
    else
    {   [parentDelegate pushToViewController:addDescriptionViewCtrl];
    }



}
-(void)updateTextUdf:(NSString*)udfTextValue
{
    TimesheetUdfView *udfview=(TimesheetUdfView*)[self.footerView viewWithTag:selectedUdfCell];

    NSMutableDictionary *udfDetailDict=[self.customFieldArray objectAtIndex:selectedUdfCell-1];
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

    [udfview.fieldButton setText:udfTextStr];
    [udfDetailDict removeObjectForKey:@"defaultValue"];
    [udfDetailDict setObject:udfTextStr forKey:@"defaultValue"];
    [self.customFieldArray replaceObjectAtIndex:selectedUdfCell-1 withObject:udfDetailDict];

}
-(void)datePickerAction
{

    TimesheetUdfView *udfview=(TimesheetUdfView*)[self.footerView viewWithTag:selectedUdfCell];
    id fieldValue=nil;

    if ([udfview fieldButton].text!=nil)
    {
        fieldValue =[udfview fieldButton].text;
    }

    NSString *dateStr=fieldValue;
    self.previousDateUdfValue=dateStr;
    self.datePicker = [[UIDatePicker alloc] init];

    CGFloat datePickerHeight = 200;
    self.datePicker.frame=CGRectMake(0, self.view.frame.size.height-datePickerHeight, self.view.frame.size.width, datePickerHeight);
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.timeZone=[NSTimeZone timeZoneForSecondsFromGMT:0];
    self.datePicker.hidden = NO;
    [self.datePicker setAccessibilityIdentifier:@"uia_timesheet_level_date_udf_picker_identifier"];
    
    if ([fieldValue isKindOfClass:[NSString class]])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

        NSLocale *locale=[NSLocale currentLocale];
        [dateFormatter setLocale:locale];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        if ([dateStr isEqualToString:RPLocalizedString(SELECT_STRING, @"")]) {
            self.datePicker.date = [NSDate date];

        }
        else{
            [dateFormatter setDateFormat:@"MMMM d, yyyy"];//DE10538//JUHI
            fieldValue = [dateFormatter dateFromString:dateStr];
            self.datePicker.date = fieldValue;
        }

    }

    [self.datePicker addTarget:self
                        action:@selector(updateFieldWithPickerChange:)
              forControlEvents:UIControlEventValueChanged];

    if ([[udfview fieldButton].text isEqualToString:RPLocalizedString(SELECT_STRING, @"")] || [[udfview fieldButton].text isKindOfClass:[NSNull class]] || [udfview fieldButton].text==nil )
    {
        [self updateFieldWithPickerChange:self.datePicker];
    }

    [self.view addSubview:self.datePicker];
//    AppDelegate *delegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    //    delegate.rootTabBarController.tabBar.hidden=TRUE;
//    [delegate.window addSubview:self.datePicker];

    UIToolbar *temptoolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, self.datePicker.frame.origin.y-37, self.view.frame.size.width, 50)];
    self.toolbar=temptoolbar;
    self.toolbar.barStyle = UIBarStyleBlackOpaque;
    //Implementation for US8771 HandleDateUDFEmptyValue//JUHI
    UIBarButtonItem *tempDoneButton = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString( @"Done",  @"Done") style: UIBarButtonItemStylePlain target: self action: @selector(doneClicked)];
    self.doneButton=tempDoneButton;
    [self.doneButton setAccessibilityLabel:@"uia_timesheet_level_date_picker_done_btn_identifier"];

    UIBarButtonItem *tmpCancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                     target:self
                                                                                     action:@selector(pickerCancel:)];
    self.cancelButton=tmpCancelButton;


    UIBarButtonItem *tmpSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:nil
                                                                                    action:nil];
    self.spaceButton=tmpSpaceButton;


    //Implementation for US8771 HandleDateUDFEmptyValue//JUHI
    UIBarButtonItem *tmpClearButton = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString(@"Clear", @"Clear") style: UIBarButtonItemStylePlain target: self action: @selector(pickerClear:)];
    self.pickerClearButton=tmpClearButton;

    self.doneButton.tintColor=RepliconStandardWhiteColor;
    self.cancelButton.tintColor=RepliconStandardWhiteColor;
    self.pickerClearButton.tintColor=RepliconStandardWhiteColor;
    UIImage *backgroundImage = [Util thumbnailImage:TOOLBAR_IMAGE];
    [toolbar setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
    [toolbar setTintColor:[Util colorWithHex:@"#dddddd" alpha:1]];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];

    NSArray *toolArray = [NSArray arrayWithObjects:cancelButton,pickerClearButton,spaceButton,doneButton,nil];
    [toolbar setItems:toolArray];
    [self.view addSubview: self.toolbar];
    [self.toolbar setAccessibilityLabel:@"uia_current_timesheet_toolbar_identifier"];

    NSInteger tag=udfview.tag;
    CGRect frameSize=self.footerView.frame;
    frameSize.origin.y=frameSize.origin.y+ (tag *46.0) - 60.0;

    [[self currentTimesheetTableView] setContentOffset:CGPointMake(0, frameSize.origin.y)];

}
- (void)updateFieldWithPickerChange:(id)sender{

    TimesheetUdfView *udfview=(TimesheetUdfView*)[self.footerView viewWithTag:selectedUdfCell];

    //Implementation for US8771 HandleDateUDFEmptyValue//JUHI
    NSString *selectedDateString=nil;
    if ([sender isKindOfClass:[NSString class]])
    {
        selectedDateString=sender;
    }
    else
        selectedDateString=[Util convertDateToString:[sender date]];

    [[udfview fieldButton] setText:selectedDateString];

    NSMutableDictionary *udfDetailDict=[self.customFieldArray objectAtIndex:selectedUdfCell-1];
    [udfDetailDict removeObjectForKey:@"defaultValue"];

    //Implementation for US8771 HandleDateUDFEmptyValue//JUHI
    if ([sender isKindOfClass:[NSString class]])
    {
        if ([selectedDateString isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
        {
            [udfDetailDict setObject:selectedDateString forKey:@"defaultValue"];
        }
        else{
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

            NSLocale *locale=[NSLocale currentLocale];
            [dateFormatter setLocale:locale];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [dateFormatter setDateFormat:@"MMMM d, yyyy"];
            [udfDetailDict setObject:[dateFormatter dateFromString:selectedDateString] forKey:@"defaultValue"];


        }
    }
    else
        [udfDetailDict setObject:[sender date] forKey:@"defaultValue"];

    [self.customFieldArray replaceObjectAtIndex:selectedUdfCell-1 withObject:udfDetailDict];


}

-(void)updateDropDownFieldWithFieldName:(NSString*)fieldName andFieldURI:(NSString*)fieldUri{
    TimesheetUdfView *udfview=(TimesheetUdfView*)[self.footerView viewWithTag:selectedUdfCell];

    NSMutableDictionary *udfDetailDict=[self.customFieldArray objectAtIndex:selectedUdfCell-1];

    if (fieldName!=nil && ![fieldName isKindOfClass:[NSNull class]])
    {
        //Implemetation For MOBI-300//JUHI
        if ([fieldName isEqualToString:RPLocalizedString(NONE_STRING, NONE_STRING)]&& (fieldUri==nil || [fieldUri isKindOfClass:[NSNull class]]))
        {
            fieldName=RPLocalizedString(SELECT_STRING, @"");
            [udfDetailDict removeObjectForKey:@"dropDownOptionUri"];
            [udfDetailDict setObject:fieldUri forKey:@"dropDownOptionUri"];
        }
        [udfview.fieldButton setText:fieldName];
        [udfDetailDict removeObjectForKey:@"defaultValue"];
        [udfDetailDict setObject:fieldName forKey:@"defaultValue"];
    }
    if (fieldUri!=nil && ![fieldUri isKindOfClass:[NSNull class]])
    {
        [udfDetailDict removeObjectForKey:@"dropDownOptionUri"];
        [udfDetailDict setObject:fieldUri forKey:@"dropDownOptionUri"];
    }

    [self.customFieldArray replaceObjectAtIndex:selectedUdfCell-1 withObject:udfDetailDict];
}

-(void)doneClicked{
    if (timesheetUdfView!=nil)
    {
        timesheetUdfView.isSelected=NO;
        [timesheetUdfView setSelectedColor:timesheetUdfView.isSelected];

    }
    self.datePicker.hidden=YES;
    self.toolbar.hidden=YES;
    [self resetTableSize:NO];

}
-(void)dataAction: (NSInteger)selectedCell
{
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        return;
    }

    DropDownViewController *dropDownViewCtrl=[[DropDownViewController alloc]init];
    dropDownViewCtrl.entryDelegate=self;
    NSMutableDictionary *udfDetailDict=[self.customFieldArray objectAtIndex:selectedUdfCell-1];
    dropDownViewCtrl.dropDownUri=[udfDetailDict objectForKey:@"uri"];
    [self.navigationController pushViewController:dropDownViewCtrl animated:YES];

}

-(void)numericKeyPadAction: (NSInteger)selectedCell {
    [self resetTableSize:YES];
    [lastUsedTextField becomeFirstResponder];
}
-(void)resetTableSize:(BOOL)isResetTable
{
    if (isResetTable)
    {
        CGRect screenRect =[[UIScreen mainScreen] bounds];
        float aspectRatio=(screenRect.size.height/screenRect.size.width);
        float movementDistanceoffSet=0.0;
        if (aspectRatio<1.7)
        {
            movementDistanceoffSet=aspectRatio*movementDistanceFor4;
        }
        else
            movementDistanceoffSet=aspectRatio*movementDistanceFor5;

        self.currentTimesheetTableView.contentOffset=CGPointMake(0.0,movementDistanceoffSet);
        CGRect frame= [[UIScreen mainScreen] bounds];
        frame.size.height=frame.size.height-resetTableSpaceHeight-112;
        [self.currentTimesheetTableView setFrame:frame];
    }
    else{
        //Fix for defect DE16314
        if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
        {
            [self.currentTimesheetTableView setFrame:CGRectMake(0,0,self.view.frame.size.width, [self heightForTableView])];
        }
        else if([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            [self.currentTimesheetTableView setFrame:CGRectMake(0,0,self.view.frame.size.width, [self heightForTableView])];
        }
    }

}
-(void)timesheetSummaryAction:(id)sender{
    CLS_LOG(@"-----Summary button clicked on CurrentTimesheetViewController-----");
    AppDelegate *delegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];

    [lastUsedTextField resignFirstResponder];
    self.datePicker.hidden=YES;
    self.toolbar.hidden=YES;
    [self resetTableSize:NO];
    if (self.timesheetSummaryViewController!=nil) {
        [self.timesheetSummaryViewController.timesheetSummaryTableView removeFromSuperview];//Mobi-530 Ullas M L
    }

    //    delegate.rootTabBarController.tabBar.hidden=FALSE;
    TimesheetSummaryViewController *timesheetSummaryViewCtrl=[[TimesheetSummaryViewController alloc]init];
    self.timesheetSummaryViewController=timesheetSummaryViewCtrl;


    [UIView beginAnimations:@"View Flip" context:nil];
    [UIView setAnimationDuration:0.80];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];


    if ([[sender title] isEqualToString:RPLocalizedString(SUMMARY_BTN_TITLE, SUMMARY_BTN_TITLE)])
    {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight
                               forView:delegate.window cache:NO];
        self.timesheetSummaryViewController.totalHours=self.totalHours;
        self.timesheetSummaryViewController.sheetIdentity=self.sheetIdentity;
        if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
        {
            self.timesheetSummaryViewController.delegate=self;
            self.rightBarButton.title=RPLocalizedString(DAY_BTN_TITLE, DAY_BTN_TITLE) ;
        }
        else if([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            ApprovalsScrollViewController *ctrl=(ApprovalsScrollViewController *)parentDelegate;
            self.timesheetSummaryViewController.delegate=parentDelegate;
            ctrl.rightBarButtonItem.title=RPLocalizedString(DAY_BTN_TITLE, DAY_BTN_TITLE) ;
        }

        [self.currentTimesheetTableView removeFromSuperview];
        [self.view addSubview:self.timesheetSummaryViewController.view];


    }
    else{
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                               forView:delegate.window cache:NO];
        [self.timesheetSummaryViewController.view removeFromSuperview];
        [self.view addSubview:self.currentTimesheetTableView];
        if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
        {
            self.rightBarButton.title=RPLocalizedString(SUMMARY_BTN_TITLE, SUMMARY_BTN_TITLE);
        }
        else if([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            ApprovalsScrollViewController *ctrl=(ApprovalsScrollViewController *)parentDelegate;
            ctrl.rightBarButtonItem.title=RPLocalizedString(SUMMARY_BTN_TITLE, SUMMARY_BTN_TITLE) ;
        }


    }


    [UIView commitAnimations];
}
-(void)navigationTitle{
    [Util setToolbarLabel:self withText:selectedSheet];
    self.rightBarButton.title=RPLocalizedString(DAY_BTN_TITLE, DAY_BTN_TITLE);
    [self.navigationItem setRightBarButtonItem:self.rightBarButton];
    CGRect frame=timesheetSummaryViewController.timesheetSummaryTableView.frame;
    frame.origin.y=45;
    [timesheetSummaryViewController.timesheetSummaryTableView setFrame:frame];

}

-(void)submitAction:(id)sender
{
    CLS_LOG(@"-----Submit button clicked on CurrentTimesheetViewController-----");
    //Fix for DE15534
    self.isSaveClicked=YES;
    [self.lastUsedTextField resignFirstResponder];
    [self doneClicked];


    if ([[NetworkMonitor sharedInstance] networkAvailable] == NO)
    {

        [Util showOfflineAlert];
    }
    else{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SUBMITTED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(submitTimeSheetReceivedData:) name:SUBMITTED_NOTIFICATION object:nil];
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
        //Implementation for JM-35734_DCAA compliance support//JUHI
        NSMutableArray *arrayOfEntriesForSave=[self getArrayOfTimeEntryObjectsFromAllTheEntriesFromDB];

         [[RepliconServiceManager timesheetService]sendRequestToSaveTimesheetDataForTimesheetURI:sheetIdentity withEntryArray:arrayOfEntriesForSave withDelegate:self isMultiInOutTimeSheetUser:self.isMultiDayInOutTimesheetUser isNewAdhocEntryDict:nil isTimesheetSubmit:YES sheetLevelUdfArray:customFieldArray submitComments:nil isAutoSave:@"NO" isDisclaimerAccepted:self.disclaimerSelected rowUri:nil actionMode:0 isExtendedInOutUser:isExtendedInOut reasonForChange:nil];
    
    }


}

-(void)unSubmitAction:(id)sender
{
    if ([[NetworkMonitor sharedInstance] networkAvailable] == NO)
    {

        [Util showOfflineAlert];
    }
    else
    {
        CLS_LOG(@"-----Reopen button clicked on CurrentTimesheetViewController-----");
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UNSUBMITTED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unSubmitTimeSheetReceivedData) name:UNSUBMITTED_NOTIFICATION object:nil];
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
        
        [[RepliconServiceManager timesheetService]sendRequestToUnsubmitTimesheetDataForTimesheetURI:sheetIdentity withComments:nil withDelegate:self];

    }

}


-(void)reSubmitAction:(id)sender
{
    CLS_LOG(@"-----Resubmit button clicked on CurrentTimesheetViewController-----");
    NSMutableArray *arrayOfEntriesForSave=[self getArrayOfTimeEntryObjectsFromAllTheEntriesFromDB];
    ApprovalActionsViewController *approvalActionsViewController = [[ApprovalActionsViewController alloc] init];
    [approvalActionsViewController setIsDisclaimerRequired:self.disclaimerSelected];
    [approvalActionsViewController setSheetIdentity:self.sheetIdentity];
    [approvalActionsViewController setSelectedSheet:self.selectedSheet];
    [approvalActionsViewController setAllowBlankComments:YES];
    [approvalActionsViewController setActionType:@"Re-Submit"];
    [approvalActionsViewController setDelegate:self];
    [approvalActionsViewController setIsMultiDayInOutTimesheetUser:self.isMultiDayInOutTimesheetUser];
    [approvalActionsViewController setTimesheetLevelUdfArray:customFieldArray];
    [approvalActionsViewController setArrayOfEntriesForSave:arrayOfEntriesForSave];
    [approvalActionsViewController setIsExtendedInoutUser:isExtendedInOut];
    [self.navigationController pushViewController:approvalActionsViewController animated:YES];


}

-(void)showTimesheetFormatNotSupported
{
    UILabel *msgLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 150, 280, 150)];
    [msgLabel setNumberOfLines:100];
    msgLabel.text = RPLocalizedString(TIMESHEET_FORMAT_NOT_SUPPORTED_IN_MOBILE, @"");
    msgLabel.backgroundColor = [UIColor clearColor];
    msgLabel.textAlignment = NSTextAlignmentCenter;
    msgLabel.lineBreakMode = NSLineBreakByWordWrapping;
    msgLabel.numberOfLines = 0;
    msgLabel.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14];
    [self.view addSubview:msgLabel];
}



#pragma mark -
#pragma mark - Custom Time off View Delegates










/************************************************************************************************************
 @Function Name   : pickerDoneClickAction
 @Purpose         : To call the call back for clicking done on the picker
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)pickerDoneClickAction:(id)sender
{
    [self.customPickerView removeFromSuperview];

}






-(void)selectRadioButton:(id)sender {

    UIImage *currentRadioButtonImage= [sender imageForState:UIControlStateNormal];

    if (currentRadioButtonImage == [Util thumbnailImage:CheckBoxSelectedImage]) {
        UIImage *deselectedRadioImage = [Util thumbnailImage:CheckBoxDeselectedImage];
        if (sender != nil) {
            [sender setImage:deselectedRadioImage forState:UIControlStateNormal];
            [sender setImage:deselectedRadioImage forState:UIControlStateHighlighted];
            [self setDisclaimerSelected:NO];
            [self.disclaimerTitleLabel setText:RPLocalizedString(@"Accept", @"") ];
        }
    }
    else
    {
        UIImage *selectedRadioImage = [Util thumbnailImage:CheckBoxSelectedImage];
        if (sender != nil) {
            [sender setImage:selectedRadioImage forState:UIControlStateNormal];
            [sender setImage:selectedRadioImage forState:UIControlStateHighlighted];
            [self.disclaimerTitleLabel setText:RPLocalizedString(@"Accepted", @"") ];
            [self setDisclaimerSelected:YES];
        }
    }


}

-(void)submitTimeSheetReceivedData:(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SUBMITTED_NOTIFICATION object:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];

    //Implementation for JM-35734_DCAA compliance support//JUHI
    id dict = notification.userInfo;
    if (dict!=nil && ![dict isKindOfClass:[NSNull class]])
    {

        NSMutableArray *arrayOfEntriesForSave=[self getArrayOfTimeEntryObjectsFromAllTheEntriesFromDB];

        TimesheetSubmitReasonViewController *approvalActionsViewController = [[TimesheetSubmitReasonViewController alloc] init];

        if ([[dict objectForKey:@"timesheetModificationsRequiringChangeReason"] isKindOfClass:[NSArray class]])
        {
            NSMutableArray *responseArray=[dict objectForKey:@"timesheetModificationsRequiringChangeReason"];
            [approvalActionsViewController setReasonDetailArray:responseArray];
        }

        [approvalActionsViewController setIsDisclaimerRequired:self.disclaimerSelected];
        [approvalActionsViewController setActionType:@"Submit"];
        [approvalActionsViewController setSubmitComments:nil];
        [approvalActionsViewController setSheetIdentity:self.sheetIdentity];
        [approvalActionsViewController setIsMultiDayInOutTimesheetUser:self.isMultiDayInOutTimesheetUser];
        [approvalActionsViewController setTimesheetLevelUdfArray:customFieldArray];
        [approvalActionsViewController setArrayOfEntriesForSave:arrayOfEntriesForSave];
        [approvalActionsViewController setIsExtendedInoutUser:isExtendedInOut];
        [self.navigationController pushViewController:approvalActionsViewController animated:YES];

    }
    else
        [self popToListOfTimeSheets];
}


-(void)unSubmitTimeSheetReceivedData
{

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UNSUBMITTED_NOTIFICATION object:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];

    [self popToListOfTimeSheets];
}

-(void)popToListOfTimeSheets
{

    [self.navigationController popToRootViewControllerAnimated:TRUE];

    [datePicker removeFromSuperview];
    datePicker=nil;
}


-(BOOL)canResubmitTimeSheetForURI:(NSString *)sheetUri
{
    TimesheetModel *timeSheetModel=[[TimesheetModel alloc]init];
    NSArray *approvalDetailsDataArr=[timeSheetModel getAllTimesheetApprovalFromDBForTimesheet:sheetUri];

    for (NSDictionary *approvalDetailsDataDict in approvalDetailsDataArr)
    {
        if ([[approvalDetailsDataDict objectForKey:@"actionUri"] isEqualToString:@"urn:replicon:approval-action:submit"])
        {
            return YES;
        }
    }

    return NO;
}
-(NSMutableArray *)getArrayOfTimeEntryObjectsFromAllTheEntriesFromDB
{
    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
    NSMutableArray *timeEntriesArray=nil;
    if (self.isExtendedInOut)
    {
        timeEntriesArray=[timesheetModel getAllExtendedTimeEntriesForSheetFromDB:sheetIdentity];
    }
    else
    {
        timeEntriesArray=[timesheetModel getAllTimeEntriesForSheetFromDB:sheetIdentity];
    }
    NSMutableArray *arrayOfTimeEntriesObjectsForSave=[NSMutableArray array];

    for (int i=0; i<[timeEntriesArray count]; i++)
    {

        NSMutableDictionary *dict=dict=[timeEntriesArray objectAtIndex:i];
        NSString *timesheetEntryDate=[dict objectForKey:@"timesheetEntryDate"];
        NSString *timePunchesUri=[dict objectForKey:@"timePunchesUri"];
        NSString *timeAllocationUri=[dict objectForKey:@"timeAllocationUri"];
        NSString *activityName=[dict objectForKey:@"activityName"];
        NSString *activityUri=[dict objectForKey:@"activityUri"];
        NSString *billingName=[dict objectForKey:@"billingName"];
        NSString *billingUri=[dict objectForKey:@"billingUri"];
        NSString *projectName=[dict objectForKey:@"projectName"];
        NSString *projectUri=[dict objectForKey:@"projectUri"];
        NSString *taskName=[dict objectForKey:@"taskName"];
        NSString *taskUri=[dict objectForKey:@"taskUri"];
        NSString *timeoffName=[dict objectForKey:@"timeOffTypeName"];
        NSString *timeoffUri=[dict objectForKey:@"timeOffUri"];
        NSString *entryType=[dict objectForKey:@"entryType"];
        NSString *comments=[dict objectForKey:@"comments"];
        NSString *durationDecimalFormat=[dict objectForKey:@"durationDecimalFormat"];
        NSString *durationHourFormat=[dict objectForKey:@"durationHourFormat"];
        NSString *time_in=[dict objectForKey:@"time_in"];
        NSString *time_out=[dict objectForKey:@"time_out"];
        NSString *rowUri=[dict objectForKey:@"rowUri"];
        NSMutableArray *timePunchesArr=nil;
        //Implentation for US8956//JUHI
        NSString *breakName=[dict objectForKey:@"breakName"];
        NSString *breakUri=[dict objectForKey:@"breakUri"];
        NSString *rowNumber=[dict objectForKey:@"rowNumber"];
        
        if (self.isExtendedInOut)
        {
            NSString *key=nil;
           
            BOOL isProjectAccess=[self.timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:sheetIdentity];
            BOOL isActivityAccess=[self.timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:sheetIdentity];

            if (isProjectAccess)
            {
                key=projectUri;

            }
            else if (isActivityAccess)
            {
                key=activityUri;

            }
            timePunchesArr=[dict objectForKey:key];
        }



        if (self.isMultiDayInOutTimesheetUser)
        {
            TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc] init];
            NSMutableDictionary *multiDayInOutDict=[NSMutableDictionary dictionary];

            if (time_in!=nil && ![time_in isKindOfClass:[NSNull class]])
            {
                NSArray *timeInCompsArr=[time_in componentsSeparatedByString:@":"];
                if ([timeInCompsArr count]==3)
                {
                    NSString *inhrsMinsStr=[NSString stringWithFormat:@"%@:%@",[timeInCompsArr objectAtIndex:0],[timeInCompsArr objectAtIndex:1]];
                    NSArray *inamPmCompsArr=[[timeInCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
                    time_in=[NSString stringWithFormat:@"%@ %@",inhrsMinsStr,[inamPmCompsArr objectAtIndex:1]];
                }
                [multiDayInOutDict setObject:[time_in lowercaseString] forKey:@"in_time"];
            }
            else
            {
                [multiDayInOutDict setObject:@"" forKey:@"in_time"];
            }


            BOOL isMidnightCrossover=FALSE;
            if (time_out != (id)[NSNull null])
            {
                NSArray *timeOutCompsArr=[time_out componentsSeparatedByString:@":"];
                if ([timeOutCompsArr count]==3)
                {
                    NSString *hrsMinsStr=[NSString stringWithFormat:@"%@:%@",[timeOutCompsArr objectAtIndex:0],[timeOutCompsArr objectAtIndex:1]];
                    NSArray *amPmCompsArr=[[timeOutCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
                    if ([amPmCompsArr count]==2)
                    {
                        time_out=[NSString stringWithFormat:@"%@ %@",hrsMinsStr,[amPmCompsArr objectAtIndex:1]];
                        if ([amPmCompsArr[0]isEqualToString:@"59"] && [hrsMinsStr isEqualToString:@"11:59"] && [amPmCompsArr[1]isEqualToString:@"PM"])
                        {
                            isMidnightCrossover=TRUE;
                        }
                    }
                }
            }

            if (time_out!=nil && ![time_out isKindOfClass:[NSNull class]])
            {
                [multiDayInOutDict setObject:[time_out lowercaseString] forKey:@"out_time"];
            }
            else
            {
                [multiDayInOutDict setObject:@"" forKey:@"out_time"];
            }

            if (isMidnightCrossover)
            {
                [multiDayInOutDict setObject:[NSNumber numberWithBool:YES] forKey:@"isMidnightCrossover"];
            }

            NSDate *tmpDate = [Util convertTimestampFromDBToDate:timesheetEntryDate];
            NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
            myDateFormatter.dateFormat = @"EEEE, dd MMM yyyy";

            NSLocale *locale=[NSLocale currentLocale];
            [myDateFormatter setLocale:locale];
            [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [myDateFormatter setDateFormat:@"EEEE, dd MMM yyyy"];
            NSDate *todayDate=[myDateFormatter dateFromString:[myDateFormatter stringFromDate:tmpDate]];


            NSMutableArray *tempUDF=nil;

            if (timeoffName!=nil && (![timeoffName isKindOfClass:[NSNull class]] && ![timeoffName isEqualToString:@""]))
            {
                if ([entryType isEqualToString:Time_Off_Key])
                {
                    [tsEntryObject setEntryType:Time_Off_Key];
                }
                else
                {
                    [tsEntryObject setEntryType:Adhoc_Time_OffKey];
                }
                tempUDF=[self getUDFArrayForModuleName:TIMEOFF_UDF andEntryDate:todayDate andEntryType:entryType andRowUri:timeAllocationUri];
                [tsEntryObject setIsTimeoffSickRowPresent:YES];
                [tsEntryObject setTimeAllocationUri:timeAllocationUri];
                [tsEntryObject setTimeEntryHoursInDecimalFormat:[Util getRoundedValueFromDecimalPlaces: [[dict objectForKey:@"durationDecimalFormat"] newDoubleValue ]withDecimalPlaces:2 ]];
            }
            else
            {
                tempUDF=[self getUDFArrayForModuleName:TIMESHEET_CELL_UDF andEntryDate:todayDate andEntryType:entryType andRowUri:timePunchesUri];

                [tsEntryObject setEntryType:Time_Entry_Key];
                [tsEntryObject setIsTimeoffSickRowPresent:NO];
                [tsEntryObject setTimePunchUri:timePunchesUri];
                [tsEntryObject setTimeEntryHoursInDecimalFormat:[Util getNumberOfHoursForInTime:time_in outTime:time_out]];
            }


            NSMutableArray *udfArray=[[NSMutableArray alloc]init];
            for (int i=0; i<[tempUDF count]; i++)
            {
                NSDictionary *udfDict = [tempUDF objectAtIndex: i];
                NSString *udfType=[udfDict objectForKey:@"type"];
                NSString *udfName=[udfDict objectForKey:@"name"];
                NSString *udfUri=[udfDict objectForKey:@"uri"];

                if ([udfType isEqualToString:TEXT_UDF_TYPE])
                {
                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                    NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                    [udfDetails setFieldName:udfName];
                    [udfDetails setFieldType:UDFType_TEXT];
                    [udfDetails setFieldValue:defaultValue];
                    [udfDetails setUdfIdentity:udfUri];
                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                    [udfArray addObject:udfDetails];


                }
                else if([udfType isEqualToString:NUMERIC_UDF_TYPE])
                {
                    NSString *defaultValue=nil;
                    if ([entryType isEqualToString:Time_Off_Key])
                    {
                        NSString *tempDefaultValue=[udfDict objectForKey:@"defaultValue"];
                        if (tempDefaultValue!=nil && ![tempDefaultValue isKindOfClass:[NSNull class]]&& ![tempDefaultValue isEqualToString:@""]&&![tempDefaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                        {
                            defaultValue=tempDefaultValue;
                        }
                        else
                        {
                            defaultValue=RPLocalizedString(NONE_STRING, @"");
                        }

                    }
                    else
                    {
                        defaultValue=[udfDict objectForKey:@"defaultValue"];
                    }
                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                    
                    int defaultDecimalValue= [udfDict objectForKey:@"defaultDecimalValue"] ? [[udfDict objectForKey:@"defaultDecimalValue"] intValue] : 0;
                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                    [udfDetails setFieldName:udfName];
                    [udfDetails setFieldType:UDFType_NUMERIC];
                    [udfDetails setFieldValue:defaultValue];
                    [udfDetails setUdfIdentity:udfUri];
                    [udfDetails setDecimalPoints:defaultDecimalValue];
                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                    [udfArray addObject:udfDetails];


                }
                else if ([udfType isEqualToString:DATE_UDF_TYPE])
                {
                    NSString *defaultValue=nil;
                    id tempDefaultValue=[udfDict objectForKey:@"defaultValue"];
                    if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])
                    {
                        defaultValue=RPLocalizedString(NONE_STRING, @"");
                    }
                    else{
                        NSDate *date=(NSDate *)[udfDict objectForKey:@"defaultValue"];
                        defaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:date]];
                    }
                    id systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                    if ([systemDefaultValue isKindOfClass:[NSDate class]])
                    {
                        systemDefaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:systemDefaultValue]];
                    }

                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                    [udfDetails setFieldName:udfName];
                    [udfDetails setFieldType:UDFType_DATE];
                    [udfDetails setFieldValue:defaultValue];
                    [udfDetails setUdfIdentity:udfUri];
                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                    [udfArray addObject:udfDetails];


                    ;
                }
                else if([udfType isEqualToString:DROPDOWN_UDF_TYPE])
                {
                    //NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                    NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                    NSString *dropDownOptionUri=[udfDict objectForKey:@"dropDownOptionUri"];
                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                    [udfDetails setFieldName:udfName];
                    [udfDetails setFieldType:UDFType_DROPDOWN];
                    [udfDetails setFieldValue:defaultValue];
                    [udfDetails setUdfIdentity:udfUri];
                    [udfDetails setDropdownOptionUri:dropDownOptionUri];
                    [udfDetails setSystemDefaultValue:dropDownOptionUri];
                    [udfArray addObject:udfDetails];

                }




            }

            if (isExtendedInOut)
            {
                for (int j=0; j<[timePunchesArr count]; j++)
                {
                    NSString *timePunchesUri=[[timePunchesArr objectAtIndex:j] objectForKey:@"timePunchesUri"];
                    NSMutableArray *tempCellUDF=[self getUDFArrayForModuleName:TIMESHEET_CELL_UDF andEntryDate:todayDate andEntryType:entryType andRowUri:timePunchesUri];

                    NSMutableArray *udfCellArray=[[NSMutableArray alloc]init];
                    for (int i=0; i<[tempCellUDF count]; i++)
                    {
                        NSDictionary *udfDict = [tempCellUDF objectAtIndex: i];
                        NSString *udfType=[udfDict objectForKey:@"type"];
                        NSString *udfName=[udfDict objectForKey:@"name"];
                        NSString *udfUri=[udfDict objectForKey:@"uri"];

                        if ([udfType isEqualToString:TEXT_UDF_TYPE])
                        {
                            NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                            NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                            EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                            [udfDetails setFieldName:udfName];
                            [udfDetails setFieldType:UDFType_TEXT];
                            [udfDetails setFieldValue:defaultValue];
                            [udfDetails setUdfIdentity:udfUri];
                            [udfDetails setSystemDefaultValue:systemDefaultValue];
                            [udfCellArray addObject:udfDetails];


                        }
                        else if([udfType isEqualToString:NUMERIC_UDF_TYPE])
                        {
                            NSString *defaultValue=nil;
                            if ([entryType isEqualToString:Time_Off_Key])
                            {
                                NSString *tempDefaultValue=[udfDict objectForKey:@"defaultValue"];
                                if (tempDefaultValue!=nil && ![tempDefaultValue isKindOfClass:[NSNull class]]&& ![tempDefaultValue isEqualToString:@""]&&![tempDefaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                                {
                                    defaultValue=tempDefaultValue;
                                }
                                else
                                {
                                    defaultValue=RPLocalizedString(NONE_STRING, @"");
                                }

                            }
                            else
                            {
                                defaultValue=[udfDict objectForKey:@"defaultValue"];
                            }
                            NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                            int defaultDecimalValue=[udfDict objectForKey:@"defaultDecimalValue"] ? [[udfDict objectForKey:@"defaultDecimalValue"] intValue] : 0;
                            EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                            [udfDetails setFieldName:udfName];
                            [udfDetails setFieldType:UDFType_NUMERIC];
                            [udfDetails setFieldValue:defaultValue];
                            [udfDetails setUdfIdentity:udfUri];
                            [udfDetails setDecimalPoints:defaultDecimalValue];
                            [udfDetails setSystemDefaultValue:systemDefaultValue];
                            [udfCellArray addObject:udfDetails];


                        }
                        else if ([udfType isEqualToString:DATE_UDF_TYPE])
                        {
                            NSString *defaultValue=nil;
                            id tempDefaultValue=[udfDict objectForKey:@"defaultValue"];
                            if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])
                            {
                                defaultValue=RPLocalizedString(NONE_STRING, @"");
                            }
                            else{
                                NSDate *date=(NSDate *)[udfDict objectForKey:@"defaultValue"];
                                defaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:date]];
                            }
                            id systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                            if ([systemDefaultValue isKindOfClass:[NSDate class]])
                            {
                                systemDefaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:systemDefaultValue]];
                            }

                            EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                            [udfDetails setFieldName:udfName];
                            [udfDetails setFieldType:UDFType_DATE];
                            [udfDetails setFieldValue:defaultValue];
                            [udfDetails setUdfIdentity:udfUri];
                            [udfDetails setSystemDefaultValue:systemDefaultValue];
                            [udfCellArray addObject:udfDetails];


                        }
                        else if([udfType isEqualToString:DROPDOWN_UDF_TYPE])
                        {
                            //NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                            NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                            NSString *dropDownOptionUri=[udfDict objectForKey:@"dropDownOptionUri"];
                            EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                            [udfDetails setFieldName:udfName];
                            [udfDetails setFieldType:UDFType_DROPDOWN];
                            [udfDetails setFieldValue:defaultValue];
                            [udfDetails setUdfIdentity:udfUri];
                            [udfDetails setDropdownOptionUri:dropDownOptionUri];
                            [udfDetails setSystemDefaultValue:dropDownOptionUri];
                            [udfCellArray addObject:udfDetails];

                        }




                    }

                    [[timePunchesArr objectAtIndex:j] setObject:udfCellArray forKey:@"udfArray"];

                }
                [tsEntryObject setTimePunchesArray:timePunchesArr];
            }
            [tsEntryObject setTimeEntryDate:todayDate];
            [tsEntryObject setTimeEntryActivityName:activityName];
            [tsEntryObject setTimeEntryActivityUri:activityUri];
            [tsEntryObject setTimeEntryBillingName:billingName];
            [tsEntryObject setTimeEntryBillingUri:billingUri];
            [tsEntryObject setTimeEntryProjectName:projectName];
            [tsEntryObject setTimeEntryProjectUri:projectUri];
            [tsEntryObject setTimeEntryTaskName:taskName];
            [tsEntryObject setTimeEntryTaskUri:taskUri];
            [tsEntryObject setTimeEntryTimeOffName:timeoffName];
            [tsEntryObject setTimeEntryTimeOffUri:timeoffUri];
            [tsEntryObject setTimeEntryComments:comments];
            [tsEntryObject setTimeEntryHoursInHourFormat:durationHourFormat];
            [tsEntryObject setMultiDayInOutEntry:multiDayInOutDict];
            [tsEntryObject setTimeEntryUdfArray:udfArray];
            [tsEntryObject setTimesheetUri:sheetIdentity];
            //Implentation for US8956//JUHI
            [tsEntryObject setBreakName:breakName];
            [tsEntryObject setBreakUri:breakUri];
            [tsEntryObject setRownumber:rowNumber];
            [arrayOfTimeEntriesObjectsForSave addObject:tsEntryObject];


        }
        else
        {
            TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc] init];
            NSDate *tmpDate = [Util convertTimestampFromDBToDate:timesheetEntryDate];
            NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
            myDateFormatter.dateFormat = @"EEEE, dd MMM yyyy";

            NSLocale *locale=[NSLocale currentLocale];
            [myDateFormatter setLocale:locale];
            [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [myDateFormatter setDateFormat:@"EEEE, dd MMM yyyy"];
            NSDate *todayDate=[myDateFormatter dateFromString:[myDateFormatter stringFromDate:tmpDate]];


            NSMutableDictionary *multiDayInOutDict=[NSMutableDictionary dictionary];


            NSMutableArray *tempUDF=nil;
            NSMutableArray *tempRowCustomFieldArray=nil;//Implementation for US9371//JUHI
            if (timeoffName!=nil && (![timeoffName isKindOfClass:[NSNull class]] && ![timeoffName isEqualToString:@""]))
            {
                if ([entryType isEqualToString:Time_Off_Key])
                {
                    [tsEntryObject setEntryType:Time_Off_Key];
                }
                else
                {
                    [tsEntryObject setEntryType:Adhoc_Time_OffKey];
                }
                tempUDF=[self getUDFArrayForModuleName:TIMEOFF_UDF andEntryDate:todayDate andEntryType:entryType andRowUri:rowUri];
                [tsEntryObject setIsTimeoffSickRowPresent:YES];
                [tsEntryObject setTimeEntryTimeOffName:timeoffName];
                [tsEntryObject setTimeEntryTimeOffUri:timeoffUri];
                [tsEntryObject setTimeEntryProjectName:@""];
                [tsEntryObject setTimeEntryProjectUri:@""];
            }
            else
            {
                if ([entryType isEqualToString:Time_Entry_Key])
                {
                    tempUDF=[self getUDFArrayForModuleName:TIMESHEET_CELL_UDF andEntryDate:todayDate andEntryType:entryType andRowUri:rowUri];
                    tempRowCustomFieldArray=[self getUDFArrayForModuleName:TIMESHEET_ROW_UDF andEntryDate:todayDate andEntryType:entryType andRowUri:rowUri];//Implementation for US9371//JUHI
                    [tsEntryObject setIsTimeoffSickRowPresent:NO];
                    [tsEntryObject setTimeEntryTimeOffName:@""];
                    [tsEntryObject setTimeEntryTimeOffUri:@""];
                    [tsEntryObject setTimeEntryProjectName:projectName];
                    [tsEntryObject setTimeEntryProjectUri:projectUri];
                }
            }







            NSMutableArray *udfArray=[[NSMutableArray alloc]init];
            for (int i=0; i<[tempUDF count]; i++)
            {
                NSDictionary *udfDict = [tempUDF objectAtIndex: i];
                NSString *udfType=[udfDict objectForKey:@"type"];
                NSString *udfName=[udfDict objectForKey:@"name"];
                NSString *udfUri=[udfDict objectForKey:@"uri"];

                if ([udfType isEqualToString:TEXT_UDF_TYPE])
                {
                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                    NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                    [udfDetails setFieldName:udfName];
                    [udfDetails setFieldType:UDFType_TEXT];
                    [udfDetails setFieldValue:defaultValue];
                    [udfDetails setUdfIdentity:udfUri];
                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                    [udfArray addObject:udfDetails];


                }
                else if([udfType isEqualToString:NUMERIC_UDF_TYPE])
                {
                    NSString *defaultValue=nil;
                    if ([entryType isEqualToString:Time_Off_Key])
                    {
                        NSString *tempDefaultValue=[udfDict objectForKey:@"defaultValue"];
                        if (tempDefaultValue!=nil && ![tempDefaultValue isKindOfClass:[NSNull class]]&& ![tempDefaultValue isEqualToString:@""]&&![tempDefaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                        {
                            defaultValue=tempDefaultValue;
                        }
                        else
                        {
                            defaultValue=RPLocalizedString(NONE_STRING, @"");
                        }

                    }
                    else
                    {
                        defaultValue=[udfDict objectForKey:@"defaultValue"];
                    }
                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                    int defaultDecimalValue=[udfDict objectForKey:@"defaultDecimalValue"] ? [[udfDict objectForKey:@"defaultDecimalValue"] intValue] : 0;
                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                    [udfDetails setFieldName:udfName];
                    [udfDetails setFieldType:UDFType_NUMERIC];
                    [udfDetails setFieldValue:defaultValue];
                    [udfDetails setUdfIdentity:udfUri];
                    [udfDetails setDecimalPoints:defaultDecimalValue];
                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                    [udfArray addObject:udfDetails];


                }
                else if ([udfType isEqualToString:DATE_UDF_TYPE])
                {
                    NSString *defaultValue=nil;
                    id tempDefaultValue=[udfDict objectForKey:@"defaultValue"];
                    if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])
                    {
                        defaultValue=RPLocalizedString(NONE_STRING, @"");
                    }
                    else{
                        NSDate *date=(NSDate *)[udfDict objectForKey:@"defaultValue"];
                        defaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:date]];
                    }
                    id systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                    if ([systemDefaultValue isKindOfClass:[NSDate class]])
                    {
                        systemDefaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:systemDefaultValue]];
                    }

                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                    [udfDetails setFieldName:udfName];
                    [udfDetails setFieldType:UDFType_DATE];
                    [udfDetails setFieldValue:defaultValue];
                    [udfDetails setUdfIdentity:udfUri];
                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                    [udfArray addObject:udfDetails];


                    ;
                }
                else if([udfType isEqualToString:DROPDOWN_UDF_TYPE])
                {
                    //NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                    NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                    NSString *dropDownOptionUri=[udfDict objectForKey:@"dropDownOptionUri"];
                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                    [udfDetails setFieldName:udfName];
                    [udfDetails setFieldType:UDFType_DROPDOWN];
                    [udfDetails setFieldValue:defaultValue];
                    [udfDetails setUdfIdentity:udfUri];
                    [udfDetails setDropdownOptionUri:dropDownOptionUri];
                    [udfDetails setSystemDefaultValue:dropDownOptionUri];
                    [udfArray addObject:udfDetails];

                }




            }

            //Implementation for US9371//JUHI
            NSMutableArray *rowUdfArray=[[NSMutableArray alloc]init];
            for (int i=0; i<[tempRowCustomFieldArray count]; i++)
            {
                NSDictionary *udfDict = [tempRowCustomFieldArray objectAtIndex: i];
                NSString *udfType=[udfDict objectForKey:@"type"];
                NSString *udfName=[udfDict objectForKey:@"name"];
                NSString *udfUri=[udfDict objectForKey:@"uri"];

                if ([udfType isEqualToString:TEXT_UDF_TYPE])
                {
                    NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];

                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                    [udfDetails setFieldName:udfName];
                    [udfDetails setFieldType:UDFType_TEXT];
                    [udfDetails setFieldValue:defaultValue];
                    [udfDetails setUdfIdentity:udfUri];
                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                    [rowUdfArray addObject:udfDetails];


                }
                else if([udfType isEqualToString:NUMERIC_UDF_TYPE])
                {
                    NSString *defaultValue=nil;
                    if ([entryType isEqualToString:Time_Off_Key])
                    {
                        NSString *tempDefaultValue=[udfDict objectForKey:@"defaultValue"];
                        if (tempDefaultValue!=nil && ![tempDefaultValue isKindOfClass:[NSNull class]]&& ![tempDefaultValue isEqualToString:@""]&&![tempDefaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                        {
                            defaultValue=tempDefaultValue;
                        }
                        else
                        {
                            defaultValue=RPLocalizedString(NONE_STRING, @"");
                        }

                    }
                    else
                    {
                        defaultValue=[udfDict objectForKey:@"defaultValue"];
                    }
                    int defaultDecimalValue=[[udfDict objectForKey:@"defaultDecimalValue"] intValue];
                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                    [udfDetails setFieldName:udfName];
                    [udfDetails setFieldType:UDFType_NUMERIC];
                    [udfDetails setFieldValue:defaultValue];
                    [udfDetails setUdfIdentity:udfUri];
                    [udfDetails setDecimalPoints:defaultDecimalValue];
                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                    [rowUdfArray addObject:udfDetails];


                }
                else if ([udfType isEqualToString:DATE_UDF_TYPE])
                {
                    NSString *defaultValue=nil;
                    id tempDefaultValue=[udfDict objectForKey:@"defaultValue"];
                    if (([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])||([tempDefaultValue isKindOfClass:[NSString class]]&& [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]))
                    {
                        defaultValue=RPLocalizedString(NONE_STRING, @"");
                    }
                    else{//Implemented for US8763_HandleWhenDateUDFDoesNotHaveDefaultValue//JUHI
                        if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]) {
                            defaultValue=RPLocalizedString(SELECT_STRING, @"");
                        }
                        else{
                            if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]) {
                                defaultValue=RPLocalizedString(SELECT_STRING, @"");
                            }
                            else{
                                NSDate *date=(NSDate *)[udfDict objectForKey:@"defaultValue"];
                                defaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:date]];
                            }

                        }
                    }
                    id systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                    if ([systemDefaultValue isKindOfClass:[NSDate class]])
                    {
                        systemDefaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:systemDefaultValue]];
                    }
                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                    [udfDetails setFieldName:udfName];
                    [udfDetails setFieldType:UDFType_DATE];
                    [udfDetails setFieldValue:defaultValue];
                    [udfDetails setUdfIdentity:udfUri];
                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                    [rowUdfArray addObject:udfDetails];

                }
                else if([udfType isEqualToString:DROPDOWN_UDF_TYPE])
                {
                    NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                    //NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                    NSString *dropDownOptionUri=[udfDict objectForKey:@"dropDownOptionUri"];
                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                    [udfDetails setFieldName:udfName];
                    [udfDetails setFieldType:UDFType_DROPDOWN];
                    [udfDetails setFieldValue:defaultValue];
                    [udfDetails setUdfIdentity:udfUri];
                    [udfDetails setDropdownOptionUri:dropDownOptionUri];
                    [udfDetails setSystemDefaultValue:dropDownOptionUri];
                    [rowUdfArray addObject:udfDetails];

                }




            }


            if (timeoffName!=nil && timeoffUri !=nil && ![timeoffUri isKindOfClass:[NSNull class]] &&![timeoffName isKindOfClass:[NSNull class]] && ![timeoffName isEqualToString:@""]&& ![timeoffUri isEqualToString:@""])
            {
                if ([entryType isEqualToString:Time_Off_Key])
                {
                    [tsEntryObject setEntryType:Time_Off_Key];
                }
                else
                {
                    [tsEntryObject setEntryType:Adhoc_Time_OffKey];
                }

                [tsEntryObject setIsTimeoffSickRowPresent:YES];
                [tsEntryObject setTimeEntryTimeOffName:timeoffName];
                [tsEntryObject setTimeEntryTimeOffUri:timeoffUri];
                [tsEntryObject setTimeEntryProjectName:@""];
                [tsEntryObject setTimeEntryProjectUri:@""];
            }
            else
            {
                [tsEntryObject setIsTimeoffSickRowPresent:NO];
                [tsEntryObject setTimeEntryTimeOffName:@""];
                [tsEntryObject setTimeEntryTimeOffUri:@""];
                [tsEntryObject setTimeEntryProjectName:projectName];
                [tsEntryObject setTimeEntryProjectUri:projectUri];
            }
            [tsEntryObject setTimeEntryComments:comments];
            [tsEntryObject setTimeEntryUdfArray:udfArray];
            [tsEntryObject setTimeEntryDate:todayDate];
            [tsEntryObject setMultiDayInOutEntry:multiDayInOutDict];
            [tsEntryObject setTimeAllocationUri:@""];
            [tsEntryObject setTimePunchUri:@""];
            [tsEntryObject setTimeEntryHoursInHourFormat:@""];
            [tsEntryObject setTimeEntryHoursInDecimalFormat:[Util getRoundedValueFromDecimalPlaces: [durationDecimalFormat newDoubleValue ]withDecimalPlaces:2 ]];
            [tsEntryObject setTimeEntryActivityName:activityName];
            [tsEntryObject setTimeEntryActivityUri:activityUri];
            [tsEntryObject setTimeEntryBillingName:billingName];
            [tsEntryObject setTimeEntryBillingUri:billingUri];
            [tsEntryObject setTimeEntryTaskName:taskName];
            [tsEntryObject setTimeEntryTaskUri:taskUri];
            [tsEntryObject setTimesheetUri:sheetIdentity];
            [tsEntryObject setRowUri:rowUri];
            [tsEntryObject setTimeEntryRowUdfArray:rowUdfArray];//Implementation for US9371//JUHI
            [tsEntryObject setRownumber:rowNumber];
            [arrayOfTimeEntriesObjectsForSave addObject:tsEntryObject];

        }

    }


    return arrayOfTimeEntriesObjectsForSave;
}

-(NSMutableArray *)getUDFArrayForModuleName:(NSString *)moduleName andEntryDate:(NSDate *)entryDate andEntryType:(NSString *)entryType andRowUri:(NSString *)rowUri
{
    NSMutableArray *customUserFieldArray=[NSMutableArray array];
    LoginModel *loginModel=[[LoginModel alloc]init];
    NSMutableArray *udfArray=[loginModel getEnabledOnlyUDFsforModuleName:moduleName];

    int decimalPlace=0;
    for (int i=0; i<[udfArray count]; i++)
    {
        NSDictionary *udfDict = [udfArray objectAtIndex: i];
        NSMutableDictionary *dictInfo = [NSMutableDictionary dictionary];
        [dictInfo setObject:[udfDict objectForKey:@"name"] forKey:@"fieldName"];
        [dictInfo setObject:[udfDict objectForKey:@"uri"] forKey:@"identity"];

        if ([[udfDict objectForKey:@"udfType"] isEqualToString: NUMERIC_UDF_TYPE])
        {
            [dictInfo setObject:NUMERIC_UDF_TYPE forKey:@"fieldType"];

            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[sheetApprovalStatus isEqualToString:APPROVED_STATUS] ) {
                [dictInfo setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
            }
            else
                [dictInfo setObject:RPLocalizedString(ADD, @"") forKey:@"defaultValue"];

            if ([udfDict objectForKey:@"numericDecimalPlaces"]!=nil && !([[udfDict objectForKey:@"numericDecimalPlaces"] isKindOfClass:[NSNull class]])){
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
                [dictInfo setObject:[Util getRoundedValueFromDecimalPlaces:[[udfDict objectForKey:@"numericDefaultValue"] newDoubleValue] withDecimalPlaces:decimalPlace] forKey:@"systemDefaultValue"];

            }
        }
        else if ([[udfDict objectForKey:@"udfType"] isEqualToString:TEXT_UDF_TYPE])
        {
            [dictInfo setObject:TEXT_UDF_TYPE forKey:@"fieldType"];
            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[sheetApprovalStatus isEqualToString:APPROVED_STATUS] ) {
                [dictInfo setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
            }
            else
                [dictInfo setObject:RPLocalizedString(ADD, @"") forKey:@"defaultValue"];

            if ([udfDict objectForKey:@"textDefaultValue"]!=nil && ![[udfDict objectForKey:@"textDefaultValue"]isKindOfClass:[NSNull class]]){
                if (![[udfDict objectForKey:@"textDefaultValue"] isEqualToString:@""]&& (![[udfDict objectForKey:@"textDefaultValue"] isEqualToString:@"null"])) {
                    [dictInfo setObject:[udfDict objectForKey:@"textDefaultValue"] forKey:@"defaultValue"];
                    [dictInfo setObject:[udfDict objectForKey:@"textDefaultValue"] forKey:@"systemDefaultValue"];
                }
            }

            if ([udfDict objectForKey:@"textMaxValue"]!=nil && !([[udfDict objectForKey:@"textMaxValue"] isKindOfClass:[NSNull class]]))
                [dictInfo setObject:[udfDict objectForKey:@"textMaxValue"] forKey:@"defaultMaxValue"];
        }
        else if ([[udfDict objectForKey:@"udfType"] isEqualToString:DATE_UDF_TYPE])
        {
            [dictInfo setObject: DATE_UDF_TYPE forKey: @"fieldType"];

            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[sheetApprovalStatus isEqualToString:APPROVED_STATUS] ) {
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
                    [dictInfo setObject:[NSDate date] forKey:@"defaultValue"];
                    [dictInfo setObject:[NSDate date] forKey:@"systemDefaultValue"];

                }else
                {
                    if ([udfDict objectForKey:@"dateDefaultValue"]!=nil && !([[udfDict objectForKey:@"dateDefaultValue"] isKindOfClass:[NSNull class]]))
                    {
                        [dictInfo setObject:[Util convertTimestampFromDBToDate:[[udfDict objectForKey:@"dateDefaultValue"] stringValue]] forKey:@"defaultValue"];
                        [dictInfo setObject:[Util convertTimestampFromDBToDate:[[udfDict objectForKey:@"dateDefaultValue"] stringValue]] forKey:@"systemDefaultValue"];

                    }
                    else
                    {
                        if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[sheetApprovalStatus isEqualToString:APPROVED_STATUS] ) {
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
                        [dictInfo setObject:dateToBeUsed forKey:@"defaultValue"];
                        [dictInfo setObject:dateToBeUsed forKey:@"systemDefaultValue"];

                    }
                    else
                    {
                        [dictInfo setObject:[Util convertTimestampFromDBToDate:[[udfDict objectForKey:@"dateDefaultValue"] stringValue]] forKey:@"defaultValue"];
                        [dictInfo setObject:[Util convertTimestampFromDBToDate:[[udfDict objectForKey:@"dateDefaultValue"] stringValue]] forKey:@"systemDefaultValue"];
                    }
                }
                else
                {
                    if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[sheetApprovalStatus isEqualToString:APPROVED_STATUS] ) {
                        [dictInfo setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
                    }
                    else
                        [dictInfo setObject:RPLocalizedString(SELECT_STRING, @"") forKey:@"defaultValue"];
                }
            }
        }
        else if ([[udfDict objectForKey:@"udfType"] isEqualToString:DROPDOWN_UDF_TYPE])
        {
            [dictInfo setObject:DROPDOWN_UDF_TYPE forKey:@"fieldType"];
            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[sheetApprovalStatus isEqualToString:APPROVED_STATUS] ) {
                [dictInfo setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
            }
            else
                [dictInfo setObject:RPLocalizedString(SELECT_STRING, @"") forKey:@"defaultValue"];
            if ([udfDict objectForKey:@"textDefaultValue"]!=nil &&![[udfDict objectForKey:@"textDefaultValue"]isKindOfClass:[NSNull class]])
            {
                if (![[udfDict objectForKey:@"textDefaultValue"] isEqualToString:@""])
                {
                    [dictInfo setObject:[udfDict objectForKey:@"textDefaultValue"] forKey:@"systemDefaultValue"];
                    [dictInfo setObject:[udfDict objectForKey:@"textDefaultValue"] forKey:@"defaultValue"];
                    [dictInfo setObject:[udfDict objectForKey:@"dropDownOptionDefaultURI"] forKey:@"dropDownOptionUri"];

                }
            }
        }
        NSString *entryDateTimestamp=[NSString stringWithFormat:@"%f",[Util convertDateToTimestamp:entryDate]];
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];

        //Implementation for US9371//JUHI
        NSArray *selectedudfArray=nil;
        if ([moduleName isEqualToString:TIMESHEET_ROW_UDF])
        {
            selectedudfArray=[timesheetModel getTimesheetSheetCustomFieldsForSheetURI:sheetIdentity moduleName:moduleName andUdfURI:[dictInfo objectForKey: @"identity"]andRowUri:rowUri];
        }
        else
            selectedudfArray=[timesheetModel getTimesheetSheetUdfInfoForSheetURI:sheetIdentity moduleName:moduleName andUdfURI:[dictInfo objectForKey: @"identity"] entryDate:entryDateTimestamp andRowUri:rowUri];

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

                            [udfDetailDict setObject:dateToBeUsed forKey:@"defaultValue"];
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

                        [udfDetailDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];


                    }

                }
                else
                {

                    [udfDetailDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];

                }
                [udfDetailDict setObject:[dictInfo objectForKey: @"fieldName" ] forKey:@"name"];
                if ([dictInfo objectForKey: @"systemDefaultValue"]!=nil && ![[dictInfo objectForKey: @"systemDefaultValue"]isKindOfClass:[NSNull class]]) {
                    [udfDetailDict setObject:[dictInfo objectForKey: @"systemDefaultValue"] forKey:@"systemDefaultValue"];
                }
                else{
                    [udfDetailDict setObject:[NSNull null] forKey:@"systemDefaultValue"];
                }
                [udfDetailDict setObject:[dictInfo objectForKey: @"fieldType"] forKey:@"type"];
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

                [customUserFieldArray addObject:udfDetailDict];

            }
        }
        else{
            NSMutableDictionary *udfDetailDict=[[NSMutableDictionary alloc]init];

            [udfDetailDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];


            [udfDetailDict setObject:[dictInfo objectForKey: @"fieldName" ] forKey:@"name"];
            if ([dictInfo objectForKey: @"systemDefaultValue"]!=nil && ![[dictInfo objectForKey: @"systemDefaultValue"]isKindOfClass:[NSNull class]]) {
                [udfDetailDict setObject:[dictInfo objectForKey: @"systemDefaultValue"] forKey:@"systemDefaultValue"];
            }
            else{
                [udfDetailDict setObject:[NSNull null] forKey:@"systemDefaultValue"];
            }
            [udfDetailDict setObject:[dictInfo objectForKey: @"fieldType"] forKey:@"type"];
            [udfDetailDict setObject:[dictInfo objectForKey: @"identity"] forKey:@"uri"];
            if ([dictInfo objectForKey: @"defaultDecimalValue" ]!=nil)
            {
                [udfDetailDict setObject:[dictInfo objectForKey: @"defaultDecimalValue" ] forKey:@"defaultDecimalValue"];
            }
            if ([dictInfo objectForKey: @"dropDownOptionUri" ]!=nil)
            {
                [udfDetailDict setObject:[dictInfo objectForKey: @"dropDownOptionUri" ] forKey:@"dropDownOptionUri"];
            }
            [customUserFieldArray addObject:udfDetailDict];


        }

    }
    return customUserFieldArray;
}

#pragma mark Approval Footerview Action
- (void)handleButtonClickForFooterView:(NSInteger)senderTag
{
    if ([parentDelegate respondsToSelector:@selector(handleApproveOrRejectActionWithApproverComments:andSenderTag:)])
    {
        [parentDelegate handleApproveOrRejectActionWithApproverComments:self.approverComments andSenderTag:senderTag];
    }

}
-(void)resetViewForApprovalsCommentsAction:(BOOL)isReset andComments:(NSString *)approverCommentsStr
{
    self.approverComments=approverCommentsStr;
    if(isReset){
        self.currentTimesheetTableView.scrollEnabled=NO;
        CGRect frame=self.currentTimesheetTableView.frame;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        float aspectRatio=(screenRect.size.height/screenRect.size.width);
        float heightDueToUdf=[customFieldArray count]*Each_Cell_Row_Height_44;

        if (aspectRatio<1.7)
        {
            self.currentTimesheetTableView.contentOffset=CGPointMake(0.0,339+heightofDisclaimerText+heightDueToUdf);
            if (heightofDisclaimerText>0)
            {
                frame.origin.y=-91;
            }
            else {
                frame.origin.y=-ResetHeightios4;
            }
            [self.currentTimesheetTableView setFrame:frame];
        }
        else {
            if (heightofDisclaimerText>0)
            {
                frame.origin.y=-91;
            }
            else
                frame.origin.y=-ResetHeightios5;
            
            [self.currentTimesheetTableView setFrame:frame];
            
            CGPoint newContentOffset = CGPointMake(0, [self.currentTimesheetTableView contentSize].height -  self.currentTimesheetTableView.bounds.size.height);
            [self.currentTimesheetTableView setContentOffset:newContentOffset animated:NO];
            
        }
    }
    else{
        self.currentTimesheetTableView.scrollEnabled=YES;
        CGRect frame=self.currentTimesheetTableView.frame;
        frame.origin.y=0;
        [self.currentTimesheetTableView setFrame:frame];
    }
}
#pragma mark Approval headerview Action
- (void)handleButtonClickForHeaderView:(NSInteger)senderTag
{

    if ([parentDelegate respondsToSelector:@selector(handlePreviousNextButtonFromApprovalsListforViewTag:forbuttonTag:)])
    {
        [parentDelegate handlePreviousNextButtonFromApprovalsListforViewTag:currentViewTag forbuttonTag:senderTag];
    }


}

-(void)showMessageLabel
{
    self.currentTimesheetTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    UILabel *msgLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, HeightOfNoTOMsgLabel)];
    //Implemetation for ExtendedInOut
    if (isExtendedInOut)
    {
        msgLabel.frame=CGRectMake(12, 110, self.view.frame.size.width-15, 120);
        if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
        {
            msgLabel.text=RPLocalizedString(EXTENDED_INOUT_ERRORMSG, @"");
        }
        else if([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            msgLabel.text=RPLocalizedString(EXTENDED_INOUT_APPROVAL_PENDING_PREVIOUS_MSG, @"");
        }
        msgLabel.numberOfLines=10;
    }
    else{
        msgLabel.text=RPLocalizedString(APPROVAL_TIMESHEET_NOT_WAITINGFORAPPROVAL, @"");
        msgLabel.numberOfLines=2;
    }
    msgLabel.backgroundColor=[UIColor clearColor];

    msgLabel.textAlignment=NSTextAlignmentCenter;
    msgLabel.font=[UIFont fontWithName:RepliconFontFamily size:16];
    [self.view addSubview:msgLabel];


}
//Implementation for US8771 HandleDateUDFEmptyValue//JUHI
-(void)pickerCancel:(id)sender
{
    if (timesheetUdfView!=nil)
    {
        timesheetUdfView.isSelected=NO;
        [timesheetUdfView setSelectedColor:timesheetUdfView.isSelected];

    }
    self.datePicker.hidden=YES;
    self.toolbar.hidden=YES;
    [self resetTableSize:NO];
    NSArray *toolArray = [NSArray arrayWithObjects:spaceButton, doneButton,nil];
    [toolbar setItems:toolArray];
    [self updateFieldWithPickerChange:self.previousDateUdfValue];

}
-(void)pickerClear:(id)sender
{
    if (timesheetUdfView!=nil)
    {
        timesheetUdfView.isSelected=NO;
        [timesheetUdfView setSelectedColor:timesheetUdfView.isSelected];

    }
    self.datePicker.hidden=YES;
    self.toolbar.hidden=YES;
    [self resetTableSize:NO];
    NSArray *toolArray = [NSArray arrayWithObjects:spaceButton, doneButton,nil];
    [toolbar setItems:toolArray];
    [self updateFieldWithPickerChange:RPLocalizedString(SELECT_STRING, @"")];

}

- (void)enableDeeplinkForTimesheetWithStartDate:(NSDate *)startDate{
    self.isFromDeepLink = YES;
    self.startDate = startDate;
}

- (void)checkForDeeplinkAndSelectCurrentTimesheet{
    if(self.isFromDeepLink){
        NSDate *todayDate = [Util convertUTCToLocalDate:[NSDate date]];
        int dayDifference = [Util getDayDifferenceBetweenStartDate:self.startDate andEndDate:todayDate];
        dayDifference = (dayDifference >= 0 && dayDifference <= 6) ? dayDifference : 0;
        dayDifference += 1; //Skipping status cell at index 0
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:dayDifference inSection:0];
        if([self.currentTimesheetTableView cellForRowAtIndexPath:indexPath]){
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self.currentTimesheetTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                [self tableView:self.currentTimesheetTableView didSelectRowAtIndexPath:indexPath];
            });
        }
        self.isFromDeepLink = NO;
    }
}

#pragma mark NetworkMonitor

-(void) networkActivated {


}


-(void)dealloc
{

    self.currentTimesheetTableView.delegate = nil;
    self.currentTimesheetTableView.dataSource = nil;
}

@end
