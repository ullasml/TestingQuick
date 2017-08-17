#import "ApprovalsScrollViewController.h"
#import "Constants.h"
#import "Util.h"
#import "AppDelegate.h"
#import "ApprovalsNavigationController.h"
#import "CurrentTimesheetViewController.h"
#import "ListOfExpenseEntriesViewController.h"
#import "ApprovalsPendingExpenseViewController.h"
#import "ApprovalsPendingTimesheetViewController.h"
#import "ApprovalsPendingTimeOffViewController.h"
#import "ApprovalsTimesheetHistoryViewController.h"
#import "ApprovalsExpenseHistoryViewController.h"
#import "ApprovalsTimeOffHistoryViewController.h"
#import "LoginModel.h"
#import "DefaultTheme.h"
#import "ButtonStylist.h"
#import "DefaultTableViewCellStylist.h"
#import "SearchTextFieldStylist.h"
#import "SpinnerDelegate.h"
#import "TimeOffDetailsViewController.h"
#import "ApprovalStatusPresenter.h"
#import "TimesheetContainerController.h"

// TODO: Need to check this is really required or not
@interface CurrentTimesheetViewController ()

@property (nonatomic) CurrentTimesheetViewController *currentTimesheetViewController;

@end

@interface ApprovalsScrollViewController ()

@property (nonatomic, strong) MultiDayTimeOffViewController *multiDayTimeOffViewController;

@end

@implementation ApprovalsScrollViewController
@synthesize  mainScrollView;
@synthesize currentViewIndex;
@synthesize hasPreviousTimeSheets;
@synthesize hasNextTimeSheets;
@synthesize indexCount;
@synthesize listOfPendingItemsArray;
@synthesize sheetStatus;
@synthesize delegate;
@synthesize rightBarButtonItem;
@synthesize bookedTimeOffEntryController;
@synthesize listOfExpenseEntriesViewController;
@synthesize approvalsModuleName;
@synthesize isGen4User;
@synthesize widgetTSViewController;
@synthesize validationMessageArray;


enum  {
	PREVIOUS_BUTTON_TAG,
	NEXT_BUTTON_TAG,
};

#pragma mark - UIViewController

- (void)loadView
{
    [super loadView];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.view setBackgroundColor:[Util colorWithHex:@"#f8f8f8" alpha:1]];
    if ([delegate isKindOfClass:[ApprovalsPendingTimesheetViewController class]])
    {
        [Util setToolbarLabel: self withText: RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle)];
    }
    else if([delegate isKindOfClass:[ApprovalsPendingExpenseViewController class]])
    {
        [Util setToolbarLabel: self withText: RPLocalizedString(ExpenseTabbarTitle, ExpenseTabbarTitle)];
    }
    else if ([delegate isKindOfClass:[ApprovalsPendingTimeOffViewController class]])
    {
        [Util setToolbarLabel: self withText: RPLocalizedString(BookedTimeOffTabbarTitle, BookedTimeOffTabbarTitle)];
    }
    else if ([delegate isKindOfClass:[ApprovalsTimesheetHistoryViewController class]])
    {
        [Util setToolbarLabel: self withText: RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle)];
    }
    else if ([delegate isKindOfClass:[ApprovalsExpenseHistoryViewController class]])
    {
        [Util setToolbarLabel: self withText: RPLocalizedString(ExpenseTabbarTitle, ExpenseTabbarTitle)];
    }
    else if ([delegate isKindOfClass:[ApprovalsTimeOffHistoryViewController class]])
    {
        [Util setToolbarLabel: self withText: RPLocalizedString(BookedTimeOffTabbarTitle, BookedTimeOffTabbarTitle)];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    BOOL isWidgetTimesheetControllerPresented = (self.widgetTSViewController != nil && ![self.widgetTSViewController isKindOfClass:[NSNull class]] && [self isGen4WidgetTimesheet]);
    
    if (isWidgetTimesheetControllerPresented) {
        [self.widgetTSViewController setTableViewInset];
        [self viewAllEntriesScreen:nil];
    }
}

- (BOOL)isGen4WidgetTimesheet
{
    ApprovalsModel *approvalsModel = [[ApprovalsModel alloc] init];
    NSMutableDictionary *userDict=[self.listOfPendingItemsArray objectAtIndex: self.indexCount];
    if ([delegate isKindOfClass:[ApprovalsPendingTimesheetViewController class]])
    {
        NSArray *dbTimesheetInfoArray=[approvalsModel getTimeSheetInfoSheetIdentityForPending:[userDict objectForKey:@"timesheetUri"]];
        BOOL isWidgetTimesheet=NO;
        if ([dbTimesheetInfoArray count]>0) {
            NSArray *enabledWidgetsUriArray=[approvalsModel getAllSupportedAndNotSupportedPendingWidgetsForTimesheetUri:[userDict objectForKey:@"timesheetUri"]];
            if (enabledWidgetsUriArray.count>0)
            {
                isWidgetTimesheet=TRUE;
            }
        }
        if (self.isGen4User||isWidgetTimesheet)
        {
            return YES;
        }
    }
    else if ([delegate isKindOfClass:[ApprovalsTimesheetHistoryViewController class]] || [delegate isKindOfClass:[TimesheetContainerController class]])
    {
        self.mainScrollView.pagingEnabled = NO;
        NSArray *dbTimesheetInfoArray=[approvalsModel getTimeSheetInfoSheetIdentityForPrevious:[userDict objectForKey:@"timesheetUri"]];
        BOOL isWidgetTimesheet=NO;
        if ([dbTimesheetInfoArray count]>0) {
            NSArray *enabledWidgetsUriArray=[approvalsModel getAllSupportedAndNotSupportedPreviousWidgetsForTimesheetUri:[userDict objectForKey:@"timesheetUri"]];
            if (enabledWidgetsUriArray.count>0)
            {
                isWidgetTimesheet=TRUE;
            }
        }
        if (self.isGen4User||isWidgetTimesheet)
        {
            return YES;
        }
    }
    return NO;
}


#pragma mark - Other Methods
/************************************************************************************************************
 @Function Name   : refreshScrollView
 @Purpose         : To refresh the view everytime next/previous button is clicked
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)refreshScrollView
{
    if (self.mainScrollView)
    {
        [self.mainScrollView removeFromSuperview];
        self.mainScrollView = nil;
    }
    
    self.mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.mainScrollView.pagingEnabled = NO;
    [self.view addSubview:self.mainScrollView];

    if ([delegate isKindOfClass:[ApprovalsPendingTimesheetViewController class]])
    {
        if ([self isGen4WidgetTimesheet])
        {
            [self.navigationItem setRightBarButtonItem:nil];
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            NSString *approvalComments = self.widgetTSViewController.approverComments;
            WidgetTSViewController *widgetTSViewCtrl=[[WidgetTSViewController alloc]init];
            widgetTSViewCtrl.approverComments = approvalComments;
            self.widgetTSViewController=widgetTSViewCtrl;
            [self.widgetTSViewController setApprovalsModuleName:APPROVALS_PENDING_TIMESHEETS_MODULE];
            NSDate *startDate=nil;
            NSDate *endDate=nil;
            NSString *startDatesheetStr = nil;
            NSString *endDatesheetStr = nil;
            NSMutableDictionary *userDict=[self.listOfPendingItemsArray objectAtIndex: self.indexCount];
            if ([userDict objectForKey:@"timesheetPeriod"]!=nil && ![[userDict objectForKey:@"timesheetPeriod"] isKindOfClass:[NSNull class]]) {
                
                NSString *period=[userDict objectForKey:@"timesheetPeriod"];
                NSRange textRange=[period rangeOfString:@"-" options:NSBackwardsSearch];
                NSUInteger index=textRange.location;
                
                NSString *startDateStr = [period substringToIndex:index-1];
                NSString *endDateStr = [period substringFromIndex:index+1];
                
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                df.dateStyle = NSDateFormatterMediumStyle;
                
                [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                NSLocale *locale=[NSLocale currentLocale];
                [df setLocale:locale];
                
                [df setDateFormat:@"MMM dd, yyyy"];
                
                startDate=[df dateFromString:startDateStr];
                
                endDate=[df dateFromString:endDateStr];
                
                [df setDateFormat:@"yyyy-MM-dd"];
                
                startDateStr=[df stringFromDate:startDate];
                startDate=[df dateFromString:startDateStr];
                
                endDateStr=[df stringFromDate:endDate];
                endDate=[df dateFromString:endDateStr];
                
                [df setDateFormat:@"MMM dd"];
                startDatesheetStr=[df stringFromDate:startDate];
                endDatesheetStr=[df stringFromDate:endDate];
                
                
            }
            self.widgetTSViewController.errorAndWarningsArray=[NSMutableArray arrayWithArray:self.validationMessageArray];
            self.widgetTSViewController.timesheetStartDate=startDate;
            self.widgetTSViewController.timesheetEndDate=endDate;
            self.widgetTSViewController.sheetPeriod=[userDict objectForKey:@"timesheetPeriod"];
            self.widgetTSViewController.userName=[userDict objectForKey:@"username"];
            self.widgetTSViewController.userUri=[userDict objectForKey:@"userUri"];
            self.widgetTSViewController.sheetIdentity=[userDict objectForKey:@"timesheetUri"];
            
            self.widgetTSViewController.selectedSheet=[NSString stringWithFormat:@"%@ - %@", startDatesheetStr, endDatesheetStr];
            [self.widgetTSViewController setParentDelegate:self];
            self.approvalsModuleName=APPROVALS_PENDING_TIMESHEETS_MODULE;
            
            ApprovalsModel *approval = [[ApprovalsModel alloc]init];
            
            
            [self.widgetTSViewController setCurrentNumberOfView:self.indexCount+1 ];
            [self.widgetTSViewController setTotalNumberOfView:[self.listOfPendingItemsArray count]];
            [self.widgetTSViewController.view setFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
            [self.widgetTSViewController setSheetApprovalStatus:self.sheetStatus];
            
            //[self.widgetTSViewController updateTimesheetFormat];
            //[self.widgetTSViewController createTableHeader];
            NSMutableArray *arrayFromDB=[approval getAllPendingTimesheetDaySummaryFromDBForTimesheet:[userDict objectForKey:@"timesheetUri"]];
            if (arrayFromDB!=nil)
            {
                BOOL isextended=NO;
                if (isextended)
                {
                    [self.widgetTSViewController showMessageLabel];
                }
                else
                {
                    [self.widgetTSViewController.widgetTableView reloadData];
                    [self.widgetTSViewController createTableFooter];
                }
            }
            
            self.widgetTSViewController.currentViewTag=self.indexCount;
            
            
            
            
            UIView *timeEntryListView = self.widgetTSViewController.view;
            timeEntryListView.frame=CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
            [self.mainScrollView addSubview:timeEntryListView];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self.widgetTSViewController name:GEN4_TIMESHEET_VALIDATION_DATA_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self.widgetTSViewController selector:@selector(validationDataReceived:) name:GEN4_TIMESHEET_VALIDATION_DATA_NOTIFICATION object:nil];
            [[RepliconServiceManager timesheetService] sendRequestToGetValidationDataForTimesheet:[userDict objectForKey:@"timesheetUri"]];
            
        }
        else
        {
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            id <Theme> theme = [[DefaultTheme alloc] init];
            ButtonStylist *buttonStylist = [[ButtonStylist alloc] initWithTheme:theme];
            AppDelegate *appDelegate = (id)[[UIApplication sharedApplication] delegate];
            ApprovalStatusPresenter *approvalStatusPresenter = [[ApprovalStatusPresenter alloc] initWithTheme:theme];
            
            self.currentTimesheetViewController = [[CurrentTimesheetViewController alloc] initWithApprovalStatusPresenter:approvalStatusPresenter
                                                                                                                    theme:theme
                                                                                                         supportDataModel:[[SupportDataModel alloc] init]
                                                                                                           timesheetModel:[[TimesheetModel alloc] init]
                                                                                                            buttonStylist:buttonStylist
                                                                                                              appDelegate:appDelegate];
            
            //US9453 to address DE17320 Ullas M L
            NSMutableDictionary *userDict=[self.listOfPendingItemsArray objectAtIndex: self.indexCount];
            ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
            NSMutableArray *enableOnlyUdfUriArr=[approvalsModel getEnabledOnlyUdfArrayForTimesheetUriForPending:[userDict objectForKey:@"timesheetUri"]];
            NSMutableArray *enableOnlyUdfUriArray=[NSMutableArray array];
            for (int k=0; k<[enableOnlyUdfUriArr count]; k++)
            {
                NSString *udfUri=[[enableOnlyUdfUriArr objectAtIndex:k] objectForKey:@"udfUri"];
                [enableOnlyUdfUriArray addObject:udfUri];
            }
            [approvalsModel updateCustomFieldTableForEnableUdfuriArray:enableOnlyUdfUriArray];
            
            self.currentTimesheetViewController.sheetPeriod=[userDict objectForKey:@"timesheetPeriod"];
            self.currentTimesheetViewController.userName=[userDict objectForKey:@"username"];
            self.currentTimesheetViewController.userUri=[userDict objectForKey:@"userUri"];
            self.currentTimesheetViewController.sheetIdentity=[userDict objectForKey:@"timesheetUri"];
            [self.currentTimesheetViewController setApprovalsModuleName:APPROVALS_PENDING_TIMESHEETS_MODULE];
            self.approvalsModuleName=APPROVALS_PENDING_TIMESHEETS_MODULE;
            
            ApprovalsModel *approval = [[ApprovalsModel alloc]init];
            NSDictionary *approvalStatusDict=[approval getApprovalStatusInfoForPendingTimesheetIdentity:[userDict objectForKey:@"timesheetUri"]];
            NSString *approvalStatus=[approvalStatusDict objectForKey:@"approvalStatus"];
            if ([approvalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS])
            {
                [self.currentTimesheetViewController.view setFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
                [self.currentTimesheetViewController setSheetApprovalStatus:self.sheetStatus];
                [self.currentTimesheetViewController setCurrentNumberOfView:self.indexCount+1 ];
                [self.currentTimesheetViewController setTotalNumberOfView:[self.listOfPendingItemsArray count]];
                [self.currentTimesheetViewController setParentDelegate:self];
                [self.currentTimesheetViewController updateTimesheetFormat];
                
                [self.currentTimesheetViewController createTableHeader];
                //Implemented Approvals Pending DrillDown Loading UI
                NSMutableArray *arrayFromDB=[approval getAllPendingTimesheetDaySummaryFromDBForTimesheet:[userDict objectForKey:@"timesheetUri"]];
                
                
                
                if (arrayFromDB!=nil)
                {
                    //Implemetation for ExtendedInOut
                    
                    NSMutableArray *userDetailsArray=[approval getAllPendingTimeEntriesForSheetFromDB:[userDict objectForKey:@"timesheetUri"]];
                    
                    if ([userDetailsArray count]>0)
                    {
                        NSDictionary *userDict=[userDetailsArray objectAtIndex:0];
                        NSString *timesheetFormat=[userDict objectForKey:@"timesheetFormat"] ;
                        if ([timesheetFormat isEqualToString:EXTENDED_INOUT_TIMESHEET])
                        {
                            self.currentTimesheetViewController.isExtendedInOut=TRUE;
                        }
                        else if ([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                        {
                            self.currentTimesheetViewController.isExtendedInOut=TRUE;
                        }
                    }
                    else
                    {
                        NSMutableArray *arrayDict=[approval getPendingApprovalDataForTimesheetSheetURI:[userDict objectForKey:@"timesheetUri"]];
                        
                        if ([arrayDict count]>0)
                        {
                            NSString *tsFormat=[[arrayDict objectAtIndex:0] objectForKey:@"timesheetFormat"];
                            if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
                            {
                                if ([tsFormat isEqualToString:EXTENDED_INOUT_TIMESHEET])
                                {
                                    self.currentTimesheetViewController.isExtendedInOut=YES;
                                }
                                else if ([tsFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [tsFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                                {
                                    self.currentTimesheetViewController.isExtendedInOut=TRUE;
                                }
                                else if ([tsFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                                {
                                    self.currentTimesheetViewController.isExtendedInOut=FALSE;
                                }
                            }
                            
                        }
                    }
                    BOOL isextended=NO;
                    if (isextended)
                    {
                        [self.currentTimesheetViewController showMessageLabel];
                    }
                    else
                    {
                        [self.currentTimesheetViewController createCurrentTimesheetEntryList];
                        if (self.currentTimesheetViewController.currentTimesheetArray != nil && [self.currentTimesheetViewController.currentTimesheetArray count]>0) {
                            [self.currentTimesheetViewController createUdfs];
                            [self.currentTimesheetViewController.currentTimesheetTableView reloadData];
                            [self.currentTimesheetViewController createFooter];
                        }
                        else
                            [self.currentTimesheetViewController showTimesheetFormatNotSupported];
                    }
                }
                
                self.currentTimesheetViewController.currentViewTag=self.indexCount;
                
                
            }
            else
            {
                [self.currentTimesheetViewController.view setFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
                [self.currentTimesheetViewController setSheetApprovalStatus:self.sheetStatus];
                [self.currentTimesheetViewController setCurrentNumberOfView:self.indexCount+1 ];
                [self.currentTimesheetViewController setTotalNumberOfView:[self.listOfPendingItemsArray count]];
                [self.currentTimesheetViewController setParentDelegate:self];
                [self.currentTimesheetViewController createTableHeader];
                self.currentTimesheetViewController.currentViewTag=self.indexCount;
                [self.currentTimesheetViewController showMessageLabel];
                
                
                
            }
            
            if ([self.currentTimesheetViewController.totalHours newDoubleValue]==0.0)
            {
                [self.navigationItem setRightBarButtonItem:nil];
            }
            else
            {
                UIBarButtonItem *tempRightButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(SUMMARY_BTN_TITLE, SUMMARY_BTN_TITLE)  style:UIBarButtonItemStylePlain
                                                                                          target:self.currentTimesheetViewController action:@selector(timesheetSummaryAction:)];
                self.rightBarButtonItem=tempRightButtonOuterBtn;
                [self.navigationItem setRightBarButtonItem:self.rightBarButtonItem animated:NO];
                
            }
            //}
            
            
            UIView *timeEntryListView = self.currentTimesheetViewController.view;
            timeEntryListView.frame=CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
            [self.mainScrollView addSubview:timeEntryListView];
            
        }
        
    }
    else if([delegate isKindOfClass:[ApprovalsPendingExpenseViewController class]])
    {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        
        id<Theme> theme = [[DefaultTheme alloc] init];
        DefaultTableViewCellStylist *defaultTableViewCellStylist = [[DefaultTableViewCellStylist alloc] initWithTheme:theme];
        SearchTextFieldStylist *searchTextFieldStylist = [[SearchTextFieldStylist alloc] initWithTheme:theme];
        id<SpinnerDelegate>spinnerDelegate = (id)[[UIApplication sharedApplication] delegate];
        
        ListOfExpenseEntriesViewController *currenExpenseSheetViewCtrl= [[ListOfExpenseEntriesViewController alloc] initWithDefaultTableViewCellStylist:defaultTableViewCellStylist
                                                                                                                                 searchTextFieldStylist:searchTextFieldStylist
                                                                                                                                        spinnerDelegate:spinnerDelegate];
        self.listOfExpenseEntriesViewController=currenExpenseSheetViewCtrl;
        
        NSMutableDictionary *userDict=[self.listOfPendingItemsArray objectAtIndex: self.indexCount];
        self.listOfExpenseEntriesViewController.sheetPeriod=[userDict objectForKey:@"description"];//UI Changes//JUHI
        self.listOfExpenseEntriesViewController.userName=[userDict objectForKey:@"username"];
        self.listOfExpenseEntriesViewController.expenseSheetURI=[userDict objectForKey:@"expenseSheetUri"];
        [self.listOfExpenseEntriesViewController setParentDelegate:self];
        [self.listOfExpenseEntriesViewController setApprovalsModuleName:APPROVALS_PENDING_EXPENSES_MODULE];
        self.approvalsModuleName=APPROVALS_PENDING_EXPENSES_MODULE;
        ApprovalsModel *approval = [[ApprovalsModel alloc]init];
        NSDictionary *approvalStatusDict=[approval getApprovalStatusInfoForPendingExpenseSheetIdentity:[userDict objectForKey:@"expenseSheetUri"]];
        NSString *approvalStatus=[approvalStatusDict objectForKey:@"approvalStatus"];
        
        if ([approvalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS])
        {
            [self.listOfExpenseEntriesViewController.view setFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
            [self.listOfExpenseEntriesViewController setCurrentNumberOfView:self.indexCount+1 ];
            [self.listOfExpenseEntriesViewController setTotalNumberOfView:[self.listOfPendingItemsArray count]];
            [self.listOfExpenseEntriesViewController createTableHeader];
            [self.listOfExpenseEntriesViewController setExpenseSheetStatus:self.sheetStatus];
            
            [self.listOfExpenseEntriesViewController displayAllExpenseEntries:NO];
            
            //Implemented Approvals Pending DrillDown Loading UI
            NSArray *dbexpenseEntriesArray= [approval getAllPendingExpenseExpenseEntriesFromDBForExpenseSheetUri:[userDict objectForKey:@"expenseSheetUri"]];
            if (dbexpenseEntriesArray!=nil)
            {
                [self.listOfExpenseEntriesViewController createFooter];
                [[self.listOfExpenseEntriesViewController expenseEntriesTableView] reloadData];
            }
            
            self.listOfExpenseEntriesViewController.currentViewTag=self.indexCount;
        }
        else
        {
            [self.listOfExpenseEntriesViewController.view setFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
            [self.listOfExpenseEntriesViewController setCurrentNumberOfView:self.indexCount+1 ];
            [self.listOfExpenseEntriesViewController setTotalNumberOfView:[self.listOfPendingItemsArray count]];
            [self.listOfExpenseEntriesViewController createTableHeader];
            [self.listOfExpenseEntriesViewController setExpenseSheetStatus:self.sheetStatus];
            self.listOfExpenseEntriesViewController.currentViewTag=self.indexCount;
            self.listOfExpenseEntriesViewController.expenseEntriesArray=nil;
            [self.listOfExpenseEntriesViewController.expenseEntriesTableView setTableFooterView:nil];
            [self.listOfExpenseEntriesViewController setIsCalledFromTabBar:YES];
            [self.listOfExpenseEntriesViewController showMessageLabel];
        }
        
        
        
        UIView *timeEntryListView = self.listOfExpenseEntriesViewController.view;
        timeEntryListView.frame=CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
        [self.mainScrollView addSubview:timeEntryListView];
        
        
        
    }
    else if ([delegate isKindOfClass:[ApprovalsPendingTimeOffViewController class]])
    {
        NSMutableDictionary *userDict=[self.listOfPendingItemsArray objectAtIndex: self.indexCount];
        
        ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
        NSMutableArray *enableOnlyUdfUriArr=[approvalsModel getEnabledOnlyUdfArrayForTimeoffUriForPending:[userDict objectForKey:@"timeoffUri"]];
        NSMutableArray *enableOnlyUdfUriArray=[NSMutableArray array];
        for (int k=0; k<[enableOnlyUdfUriArr count]; k++)
        {
            NSString *udfUri=[[enableOnlyUdfUriArr objectAtIndex:k] objectForKey:@"udfUri"];
            [enableOnlyUdfUriArray addObject:udfUri];
        }
        [approvalsModel updateCustomFieldTableForEnableUdfuriArrayForTimeoffs:enableOnlyUdfUriArray];
        NSDictionary *dict=[approvalsModel getStatusInfoForPendingTimeOffIdentity:[userDict objectForKey:@"timeoffUri"]];
        NSString *status=[dict objectForKey:@"approvalStatus"];
        
        if (status!=nil)
        {
            self.sheetStatus=status;
            
        }
        BOOL isMultiDayTimeOff=[approvalsModel isMultiDayTimeOff:[userDict objectForKey:@"timeoffUri"] :@"PendingApprovalTimeoffEntries"];
        if(isMultiDayTimeOff){
            AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
            self.multiDayTimeOffViewController = [appDelegate.injector getInstance:InjectorKeyMultiDayTimeOffViewController];
            [self.multiDayTimeOffViewController setupWithModelType:TimeOffModelTypePendingApproval screenMode:VIEW_BOOKTIMEOFF navigationFlow:PENDING_APPROVER_NAVIGATION delegate:self timeOffUri:[userDict objectForKey:@"timeoffUri"] timeSheetURI:nil date:nil];
            [self.multiDayTimeOffViewController setupForApprovalWithUserName:[userDict objectForKey:@"username"] timeoffType:[userDict objectForKey:@"timeoffTypeName"] currentViewTag:@(self.indexCount) totalViewCount:@([self.listOfPendingItemsArray count])];
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            UIView *timeEntryListView = self.multiDayTimeOffViewController.view;
            timeEntryListView.frame=CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
            [self.mainScrollView addSubview:timeEntryListView];
        }
        
        else{
            TimeOffDetailsViewController *tempbookedTimeOffEntryController= [[TimeOffDetailsViewController alloc]init];
            self.bookedTimeOffEntryController=tempbookedTimeOffEntryController;
            self.bookedTimeOffEntryController.userName =[userDict objectForKey:@"username"];
            self.bookedTimeOffEntryController.userUri =[userDict objectForKey:@"userUri"];
            self.bookedTimeOffEntryController.timeoffType=[userDict objectForKey:@"timeoffTypeName"];
            self.bookedTimeOffEntryController.isStatusView=YES;
            self.bookedTimeOffEntryController._screenMode=VIEW_BOOKTIMEOFF;
            [self.bookedTimeOffEntryController setSheetIdString:[userDict objectForKey:@"timeoffUri"]];
            [self.bookedTimeOffEntryController setSheetStatus:self.sheetStatus];
            self.bookedTimeOffEntryController.approvalDelegate = self;
            //Implemented Approvals Pending DrillDown Loading UI
            NSMutableArray *arrayFromDB=[approvalsModel getAllPendingTimeoffFromDBForTimeoff:[userDict objectForKey:@"timeoffUri"]];
            
            if (arrayFromDB!=nil)
            {
                //Implemented for Last Action Time for bookedTimeoff
                if ([userDict objectForKey:@"dueDate"]!=nil&&![[userDict objectForKey:@"dueDate"]isKindOfClass:[NSNull class]])
                {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    NSLocale *locale=[NSLocale currentLocale];
                    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                    [dateFormatter setLocale:locale];
                    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
                    NSDate *nowDateFromLong = [Util convertTimestampFromDBToDate:[[userDict objectForKey:@"dueDate"] stringValue]];
                    NSDate *entryDateInLocalTime=[Util convertUTCToLocalDate:nowDateFromLong];
                    NSString *labelText=[NSString stringWithFormat:@"%@ %@",RPLocalizedString(APPROVAL_SUBMITTED_ON, @""),[dateFormatter stringFromDate:entryDateInLocalTime]];
                    [self.bookedTimeOffEntryController setDueDate:labelText];
                }
                else
                    [self.bookedTimeOffEntryController setDueDate:self.sheetStatus];
            }
            else
                [self.bookedTimeOffEntryController setDueDate:@""];
            
            [self.bookedTimeOffEntryController setCurrentNumberOfView:self.indexCount+1 ];
            [self.bookedTimeOffEntryController setTotalNumberOfView:[self.listOfPendingItemsArray count]];
            [self.bookedTimeOffEntryController setNavigationFlow:PENDING_APPROVER_NAVIGATION];
            [self.bookedTimeOffEntryController setApprovalsModuleName:APPROVALS_PENDING_TIMEOFF_MODULE];
            self.approvalsModuleName=APPROVALS_PENDING_TIMEOFF_MODULE;
            [self.view addSubview:bookedTimeOffEntryController.view];
            [self.bookedTimeOffEntryController TimeOffDetailsResponse];
            self.bookedTimeOffEntryController.currentViewTag=self.indexCount;
            
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            UIView *timeEntryListView = self.bookedTimeOffEntryController.view;
            timeEntryListView.frame=CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
            [self.mainScrollView addSubview:timeEntryListView];
        }
    }
    else if ([delegate isKindOfClass:[ApprovalsTimesheetHistoryViewController class]] || [delegate isKindOfClass:[TimesheetContainerController class]])
    {
        self.mainScrollView.pagingEnabled = NO;
        if ([self isGen4WidgetTimesheet])
        {
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            WidgetTSViewController *currenTimesheetViewCtrl=[[WidgetTSViewController alloc]init];
            self.widgetTSViewController=currenTimesheetViewCtrl;
            [self.widgetTSViewController setApprovalsModuleName:APPROVALS_PREVIOUS_TIMESHEETS_MODULE];
            NSDate *startDate=nil;
            NSDate *endDate=nil;
            NSString *startDatesheetStr = nil;
            NSString *endDatesheetStr = nil;
            NSMutableDictionary *userDict=[self.listOfPendingItemsArray objectAtIndex: self.indexCount];
            if ([userDict objectForKey:@"timesheetPeriod"]!=nil && ![[userDict objectForKey:@"timesheetPeriod"] isKindOfClass:[NSNull class]]) {
                
                NSString *period=[userDict objectForKey:@"timesheetPeriod"];
                NSRange textRange=[period rangeOfString:@"-" options:NSBackwardsSearch];
                NSUInteger index=textRange.location;
                
                NSString *startDateStr = [period substringToIndex:index-1];
                NSString *endDateStr = [period substringFromIndex:index+1];
                
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                df.dateStyle = NSDateFormatterMediumStyle;
                
                [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                NSLocale *locale=[NSLocale currentLocale];
                [df setLocale:locale];
                
                [df setDateFormat:@"MMM dd, yyyy"];
                
                startDate=[df dateFromString:startDateStr];
                
                endDate=[df dateFromString:endDateStr];
                
                [df setDateFormat:@"yyyy-MM-dd"];
                
                startDateStr=[df stringFromDate:startDate];
                startDate=[df dateFromString:startDateStr];
                
                endDateStr=[df stringFromDate:endDate];
                endDate=[df dateFromString:endDateStr];
                
                [df setDateFormat:@"MMM dd"];
                startDatesheetStr=[df stringFromDate:startDate];
                endDatesheetStr=[df stringFromDate:endDate];
                
                
            }
            
            self.widgetTSViewController.timesheetStartDate=startDate;
            self.widgetTSViewController.timesheetEndDate=endDate;
            self.widgetTSViewController.sheetPeriod=[userDict objectForKey:@"timesheetPeriod"];
            self.widgetTSViewController.userName=[userDict objectForKey:@"username"];
            self.widgetTSViewController.sheetIdentity=[userDict objectForKey:@"timesheetUri"];
            self.widgetTSViewController.userUri=[userDict objectForKey:@"userUri"];
            self.widgetTSViewController.selectedSheet=[NSString stringWithFormat:@"%@ - %@", startDatesheetStr, endDatesheetStr];
            [self.widgetTSViewController setParentDelegate:self];
            [self.widgetTSViewController.view setFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
            [self.widgetTSViewController setSheetApprovalStatus:self.sheetStatus];
            [self.widgetTSViewController setCurrentNumberOfView:0 ];
            [self.widgetTSViewController setTotalNumberOfView:0];
            
            
            self.approvalsModuleName=APPROVALS_PREVIOUS_TIMESHEETS_MODULE;
            //[self.widgetTSViewController updateTimesheetFormat];
            [self.widgetTSViewController createTableHeader];
            //[self.widgetTSViewController createCurrentTimesheetEntryList];
            [self.widgetTSViewController.widgetTableView reloadData];
            [self.widgetTSViewController createTableFooter];
            self.widgetTSViewController.currentViewTag=0;
            
            UIView *timeEntryListView = self.widgetTSViewController.view;
            timeEntryListView.frame=CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
            [self.mainScrollView addSubview:timeEntryListView];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self.widgetTSViewController name:GEN4_TIMESHEET_VALIDATION_DATA_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self.widgetTSViewController selector:@selector(validationDataReceived:) name:GEN4_TIMESHEET_VALIDATION_DATA_NOTIFICATION object:nil];
            [[RepliconServiceManager timesheetService] sendRequestToGetValidationDataForTimesheet:[userDict objectForKey:@"timesheetUri"]];
        }
        else
        {
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            
            id <Theme> theme = [[DefaultTheme alloc] init];
            ButtonStylist *buttonStylist = [[ButtonStylist alloc] initWithTheme:theme];
            AppDelegate *appDelegate = (id)[[UIApplication sharedApplication] delegate];
            ApprovalStatusPresenter *approvalStatusPresenter = [[ApprovalStatusPresenter alloc] initWithTheme:theme];
            
            self.currentTimesheetViewController = [[CurrentTimesheetViewController alloc] initWithApprovalStatusPresenter:approvalStatusPresenter
                                                                                                                    theme:theme
                                                                                                         supportDataModel:[[SupportDataModel alloc] init]
                                                                                                           timesheetModel:[[TimesheetModel alloc] init]
                                                                                                            buttonStylist:buttonStylist
                                                                                                              appDelegate:appDelegate];
            
            NSMutableDictionary *userDict=[self.listOfPendingItemsArray objectAtIndex: self.indexCount];
            self.currentTimesheetViewController.sheetPeriod=[userDict objectForKey:@"timesheetPeriod"];
            self.currentTimesheetViewController.userName=[userDict objectForKey:@"username"];
            self.currentTimesheetViewController.sheetIdentity=[userDict objectForKey:@"timesheetUri"];
            self.currentTimesheetViewController.userUri=[userDict objectForKey:@"userUri"];
            
            //US9453 to address DE17320 Ullas M L
            ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
            //Fix for MOBI-634_UdfAreNotDisplayedForPreviousTimesheet//JUHI
            NSMutableArray *enableOnlyUdfUriArr=[approvalsModel getEnabledOnlyUdfArrayForTimesheetUriForPrevious:[userDict objectForKey:@"timesheetUri"]];
            NSMutableArray *enableOnlyUdfUriArray=[NSMutableArray array];
            for (int k=0; k<[enableOnlyUdfUriArr count]; k++)
            {
                NSString *udfUri=[[enableOnlyUdfUriArr objectAtIndex:k] objectForKey:@"udfUri"];
                [enableOnlyUdfUriArray addObject:udfUri];
            }
            [approvalsModel updateCustomFieldTableForEnableUdfuriArray:enableOnlyUdfUriArray];
            
            [self.currentTimesheetViewController.view setFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
            [self.currentTimesheetViewController setSheetApprovalStatus:self.sheetStatus];
            [self.currentTimesheetViewController setCurrentNumberOfView:0 ];
            [self.currentTimesheetViewController setTotalNumberOfView:0];
            [self.currentTimesheetViewController setParentDelegate:self];
            [self.currentTimesheetViewController setApprovalsModuleName:APPROVALS_PREVIOUS_TIMESHEETS_MODULE];
            self.approvalsModuleName=APPROVALS_PREVIOUS_TIMESHEETS_MODULE;
            [self.currentTimesheetViewController updateTimesheetFormat];
            
            //Implemented Approvals Pending DrillDown Loading UI
            [self.currentTimesheetViewController createTableHeader];
            ApprovalsModel *approval = [[ApprovalsModel alloc]init];
            NSMutableArray *arrayFromDB=[approval getAllPreviousTimesheetDaySummaryFromDBForTimesheet:[userDict objectForKey:@"timesheetUri"]];
            
            if (arrayFromDB!=nil)
            {
                //Implemetation for ExtendedInOut
                
                NSMutableArray *userDetailsArray=[approval getAllPreviousTimeEntriesForSheetFromDB:[userDict objectForKey:@"timesheetUri"]];
                
                if ([userDetailsArray count]!=0)
                {
                    NSDictionary *userDict=[userDetailsArray objectAtIndex:0];
                    NSString *timesheetFormat=[userDict objectForKey:@"timesheetFormat"] ;
                    if ([timesheetFormat isEqualToString:EXTENDED_INOUT_TIMESHEET])
                    {
                        self.currentTimesheetViewController.isExtendedInOut=TRUE;
                    }
                    else if ([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                    {
                        self.currentTimesheetViewController.isExtendedInOut=TRUE;
                    }
                    else if ([timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                    {
                        self.currentTimesheetViewController.isExtendedInOut=FALSE;
                    }
                }
                else
                {
                    NSMutableArray *arrayDict=[approval getPreviousApprovalDataForTimesheetSheetURI:[userDict objectForKey:@"timesheetUri"]];
                    if ([arrayDict count]>0)
                    {
                        NSString *tsFormat=[[arrayDict objectAtIndex:0] objectForKey:@"timesheetFormat"];
                        if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
                        {
                            if ([tsFormat isEqualToString:EXTENDED_INOUT_TIMESHEET])
                            {
                                self.currentTimesheetViewController.isExtendedInOut=YES;
                            }
                            else if ([tsFormat isEqualToString:GEN4_INOUT_TIMESHEET])
                            {
                                self.currentTimesheetViewController.isExtendedInOut=TRUE;
                            }
                            else if ([tsFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                            {
                                self.currentTimesheetViewController.isExtendedInOut=FALSE;
                            }
                        }
                        
                    }
                }
                
                [self.currentTimesheetViewController createCurrentTimesheetEntryList];
                [self.currentTimesheetViewController createUdfs];
                
                [self.currentTimesheetViewController.currentTimesheetTableView reloadData];
                [self.currentTimesheetViewController createFooter];
                if ([self.currentTimesheetViewController.totalHours newDoubleValue]==0.0)
                {
                    [self.navigationItem setRightBarButtonItem:nil];
                }
                else
                {
                    UIBarButtonItem *tempRightButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(SUMMARY_BTN_TITLE, SUMMARY_BTN_TITLE)  style:UIBarButtonItemStylePlain
                                                                                              target:self.currentTimesheetViewController action:@selector(timesheetSummaryAction:)];
                    self.rightBarButtonItem=tempRightButtonOuterBtn;
                    [self.navigationItem setRightBarButtonItem:self.rightBarButtonItem animated:NO];
                    
                }
            }
            
            
            self.currentTimesheetViewController.currentViewTag=0;
            
            
            UIView *timeEntryListView = self.currentTimesheetViewController.view;
            timeEntryListView.frame=CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
            [self.mainScrollView addSubview:timeEntryListView];
        }
    }
    else if([delegate isKindOfClass:[ApprovalsExpenseHistoryViewController class]])
    {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        
        
        id<Theme> theme = [[DefaultTheme alloc] init];
        DefaultTableViewCellStylist *defaultTableViewCellStylist = [[DefaultTableViewCellStylist alloc] initWithTheme:theme];
        SearchTextFieldStylist *searchTextFieldStylist = [[SearchTextFieldStylist alloc] initWithTheme:theme];
        id<SpinnerDelegate>spinnerDelegate = (id)[[UIApplication sharedApplication] delegate];
        
        ListOfExpenseEntriesViewController *currenExpenseSheetViewCtrl= [[ListOfExpenseEntriesViewController alloc] initWithDefaultTableViewCellStylist:defaultTableViewCellStylist
                                                                                                                                 searchTextFieldStylist:searchTextFieldStylist
                                                                                                                                        spinnerDelegate:spinnerDelegate];
        
        self.listOfExpenseEntriesViewController=currenExpenseSheetViewCtrl;
        [self.listOfExpenseEntriesViewController setExpenseSheetStatus:self.sheetStatus];
        NSMutableDictionary *userDict=[self.listOfPendingItemsArray objectAtIndex: self.indexCount];
        self.listOfExpenseEntriesViewController.sheetPeriod=[userDict objectForKey:@"description"];//UI Changes//JUHI
        self.listOfExpenseEntriesViewController.userName=[userDict objectForKey:@"username"];
        self.listOfExpenseEntriesViewController.expenseSheetURI=[userDict objectForKey:@"expenseSheetUri"];
        [self.listOfExpenseEntriesViewController setParentDelegate:self];
        [self.listOfExpenseEntriesViewController setApprovalsModuleName:APPROVALS_PREVIOUS_EXPENSES_MODULE];
        self.approvalsModuleName=APPROVALS_PREVIOUS_EXPENSES_MODULE;
        [self.listOfExpenseEntriesViewController.view setFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
        [self.listOfExpenseEntriesViewController setCurrentNumberOfView:self.indexCount+1 ];
        [self.listOfExpenseEntriesViewController setTotalNumberOfView:[self.listOfPendingItemsArray count]];
        [self.listOfExpenseEntriesViewController createTableHeader];
        
        [self.listOfExpenseEntriesViewController displayAllExpenseEntries:NO];
        //Implemented Approvals Pending DrillDown Loading UI
        ApprovalsModel *approval = [[ApprovalsModel alloc]init];
        
        NSArray *dbexpenseEntriesArray= [approval getAllPreviousExpenseExpenseEntriesFromDBForExpenseSheetUri:[userDict objectForKey:@"expenseSheetUri"]];
        
        if (dbexpenseEntriesArray!=nil)
        {
            [self.listOfExpenseEntriesViewController createFooter];
            [[self.listOfExpenseEntriesViewController expenseEntriesTableView] reloadData];
        }
        self.listOfExpenseEntriesViewController.currentViewTag=self.indexCount;
        UIView *timeEntryListView = self.listOfExpenseEntriesViewController.view;
        timeEntryListView.frame=CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
        [self.mainScrollView addSubview:timeEntryListView];
        
        
        
    }
    else if([delegate isKindOfClass:[ApprovalsTimeOffHistoryViewController class]])
    {
        ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
        NSMutableDictionary *userDict=[self.listOfPendingItemsArray objectAtIndex: self.indexCount];
        BOOL isMultiDayTimeOff=[approvalsModel isMultiDayTimeOff:[userDict objectForKey:@"timeoffUri"] :@"PreviousApprovalTimeoffEntries"];
        if(isMultiDayTimeOff){
            AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
            self.multiDayTimeOffViewController = [appDelegate.injector getInstance:InjectorKeyMultiDayTimeOffViewController];
            [self.multiDayTimeOffViewController setupWithModelType:TimeOffModelTypePreviousApproval screenMode:VIEW_BOOKTIMEOFF navigationFlow:PREVIOUS_APPROVER_NAVIGATION delegate:self timeOffUri:[userDict objectForKey:@"timeoffUri"] timeSheetURI:nil date:nil];
            [self.multiDayTimeOffViewController setupForApprovalWithUserName:[userDict objectForKey:@"username"] timeoffType:[userDict objectForKey:@"timeoffTypeName"] currentViewTag:nil totalViewCount:nil];
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            UIView *timeEntryListView = self.multiDayTimeOffViewController.view;
            timeEntryListView.frame=CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
            [self.mainScrollView addSubview:timeEntryListView];
        }
        
        else{
            
            TimeOffDetailsViewController *bookedTimeOffEntryViewController = [[TimeOffDetailsViewController alloc]init];
            self.bookedTimeOffEntryController = bookedTimeOffEntryViewController;
            [self.bookedTimeOffEntryController setSheetStatus:APPROVED_STATUS];
            self.bookedTimeOffEntryController.userName=[userDict objectForKey:@"username"];
            self.bookedTimeOffEntryController.userUri=[userDict objectForKey:@"userUri"];
            self.bookedTimeOffEntryController.timeoffType=[userDict objectForKey:@"timeoffTypeName"];
            self.bookedTimeOffEntryController.isStatusView=YES;
            self.bookedTimeOffEntryController._screenMode=VIEW_BOOKTIMEOFF;
            [self.bookedTimeOffEntryController setSheetIdString:[userDict objectForKey:@"timeoffUri"]];
            
            NSMutableArray *enableOnlyUdfUriArr=[approvalsModel getEnabledOnlyUdfArrayForTimeoffUriForPrevious:[userDict objectForKey:@"timeoffUri"]];
            NSMutableArray *enableOnlyUdfUriArray=[NSMutableArray array];
            for (int k=0; k<[enableOnlyUdfUriArr count]; k++)
            {
                NSString *udfUri=[[enableOnlyUdfUriArr objectAtIndex:k] objectForKey:@"udfUri"];
                [enableOnlyUdfUriArray addObject:udfUri];
            }
            [approvalsModel updateCustomFieldTableForEnableUdfuriArrayForTimeoffs:enableOnlyUdfUriArray];
            
            
            //Implemented Approvals Pending DrillDown Loading UI
            ApprovalsModel *approval = [[ApprovalsModel alloc]init];
            NSMutableArray *arrayFromDB=[approval getAllPreviousTimeoffFromDBForTimeoff:[userDict objectForKey:@"timeoffUri"]];
            
            if (arrayFromDB) {
                [self.bookedTimeOffEntryController setDueDate:self.sheetStatus];
            }
            else {
                [bookedTimeOffEntryController setDueDate:@""];
            }
            [bookedTimeOffEntryController setCurrentNumberOfView:0];
            [bookedTimeOffEntryController setTotalNumberOfView:0];
            [bookedTimeOffEntryController setParentDelegate:self];
            [self.bookedTimeOffEntryController setDueDate:@""];
            
            [self.bookedTimeOffEntryController setCurrentNumberOfView:0];
            [self.bookedTimeOffEntryController setTotalNumberOfView:0];
            self.bookedTimeOffEntryController.approvalDelegate = self;
            [self.bookedTimeOffEntryController setNavigationFlow:PREVIOUS_APPROVER_NAVIGATION];
            [self.bookedTimeOffEntryController setApprovalsModuleName:APPROVALS_PREVIOUS_TIMEOFF_MODULE];
            self.approvalsModuleName=APPROVALS_PREVIOUS_TIMEOFF_MODULE;
            
            [self.view addSubview:bookedTimeOffEntryController.view];
            [self.bookedTimeOffEntryController TimeOffDetailsReceived];
            
            CGRect screenRect = [[UIScreen mainScreen] bounds];
            UIView *timeEntryListView = bookedTimeOffEntryController.view;
            timeEntryListView.frame=CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
            [self.mainScrollView addSubview:timeEntryListView];
            
        }
    }
    self.mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    CGPoint point=CGPointMake(self.view.frame.size.width *currentViewIndex, 0 );
    self.mainScrollView.contentOffset=point;
    
}

/************************************************************************************************************
 @Function Name   : fetchPendingTimesheet
 @Purpose         : To fetch data for next/previous record if its not available in the DB
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)fetchPendingTimesheet
{

    NSMutableDictionary *userDict=[self.listOfPendingItemsArray objectAtIndex: self.indexCount];
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        return;

    }
    CLS_LOG(@"-----Next timesheet fetch action ApprovalsScrollViewController -----");
    //Implementation For Mobi-92//JUHI
    NSString *timesheetURI=[userDict objectForKey:@"timesheetUri"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewAllEntriesScreen:) name:APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION object:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
    ApprovalsModel *approvalsModel = [[ApprovalsModel alloc] init];
	NSArray *dbTimesheetArray = [approvalsModel getAllPendingTimesheetDaySummaryFromDBForTimesheet:timesheetURI];
    NSArray *dbTimesheetInfoArray=[approvalsModel getTimeSheetInfoSheetIdentityForPending:timesheetURI];
    BOOL isWidgetTimesheet=NO;
    if ([dbTimesheetInfoArray count]>0) {
        NSString *timesheetFormat=[[dbTimesheetInfoArray objectAtIndex:0] objectForKey:@"timesheetFormat"];
        if (timesheetFormat!=nil && ![timesheetFormat isKindOfClass:[NSNull class]] && ([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET]))
        {
            isWidgetTimesheet=YES;
        }
        self.sheetStatus = dbTimesheetInfoArray[0][@"approvalStatus"];

    }
    if ([dbTimesheetArray count]==0)
    {
        [[RepliconServiceManager approvalsService]fetchPendingTimeSheetSummaryDataForTimesheet:timesheetURI withDelegate:self];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName: APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION object:nil userInfo:nil];
    }

}
/************************************************************************************************************
 @Function Name   : fetchPendingExpensesheet
 @Purpose         : To fetch data for next/previous record if its not available in the DB
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)fetchPendingExpensesheet
{
    if (self.listOfPendingItemsArray!=nil && ![self.listOfPendingItemsArray isKindOfClass:[NSNull class]] && [self.listOfPendingItemsArray count]>0) {
        NSMutableDictionary *userDict=[self.listOfPendingItemsArray objectAtIndex: self.indexCount];
        if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
        {
            [Util showOfflineAlert];
            return;
            
        }
        CLS_LOG(@"-----Next expensesheet fetch action ApprovalsScrollViewController -----");
        NSString *expenseSheetUri=[userDict objectForKey:@"expenseSheetUri"];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:APPROVALS_EXPENSE_SUMMARY_RECIEVED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewAllEntriesScreen:) name:APPROVALS_EXPENSE_SUMMARY_RECIEVED_NOTIFICATION object:nil];
        
        ApprovalsModel *approvalsModel = [[ApprovalsModel alloc] init];
        NSArray *dbTimesheetArray = [approvalsModel getAllPendingExpenseExpenseEntriesFromDBForExpenseSheetUri:expenseSheetUri];
        
        if ([dbTimesheetArray count]==0)
        {
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
            [[RepliconServiceManager approvalsService]fetchApprovalPendingExpenseEntryDataForExpenseSheet:expenseSheetUri withDelegate:self];
            
        }
        else
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:APPROVALS_EXPENSE_SUMMARY_RECIEVED_NOTIFICATION object:nil];
        }
    }
    else
    {
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/************************************************************************************************************
 @Function Name   : fetchPendingTimeoffs
 @Purpose         : To fetch data for next/previous record if its not available in the DB
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)fetchPendingTimeoffs
{

    NSMutableDictionary *userDict=[self.listOfPendingItemsArray objectAtIndex: self.indexCount];
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        return;

    }
    CLS_LOG(@"-----Next timeoffsheet fetch action ApprovalsScrollViewController -----");
    NSString *timeoffUri=[userDict objectForKey:@"timeoffUri"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APPROVALS_TIMEOFF_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewAllEntriesScreen:) name:APPROVALS_TIMEOFF_SUMMARY_RECIEVED_NOTIFICATION object:nil];

    ApprovalsModel *approvalsModel = [[ApprovalsModel alloc] init];
	NSArray *dbTimesheetArray = [approvalsModel getAllPendingTimeoffFromDBForTimeoff:timeoffUri];

    if ([dbTimesheetArray count]==0)
    {
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
        [[RepliconServiceManager approvalsService]fetchApprovalPendingTimeoffEntryDataForBookedTimeoff:timeoffUri withDelegate:self];

    }
    else
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:APPROVALS_TIMEOFF_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    }

}
/************************************************************************************************************
 @Function Name   : viewAllEntriesScreen
 @Purpose         : To refresh the view everytime next/previous button is clicked
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)viewAllEntriesScreen:(NSNotification *)notification
{
    if (notification)
    {
        self.widgetTSViewController.approverComments = nil;
    }
    id notificationInfo=[notification userInfo];
    if (notificationInfo!=nil && ![notificationInfo isKindOfClass:[NSNull class]])
    {
        id widgetTimesheetValidationResult=[notificationInfo objectForKey:@"widgetTimesheetValidationResult"];
        if (widgetTimesheetValidationResult!=nil && ![widgetTimesheetValidationResult isKindOfClass:[NSNull class]])
        {
            self.validationMessageArray=[widgetTimesheetValidationResult objectForKey:@"validationMessages"];
        }
    }
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APPROVALS_TIMEOFF_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APPROVALS_EXPENSE_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    NSUInteger count=[self.listOfPendingItemsArray count];
    //Implemented Approvals Pending DrillDown Loading UI
    if ([delegate isKindOfClass:[ApprovalsTimesheetHistoryViewController class]]||[delegate isKindOfClass:[TimesheetContainerController class]]||[delegate isKindOfClass:[ApprovalsExpenseHistoryViewController class]]||[delegate isKindOfClass:[ApprovalsTimeOffHistoryViewController class]])
    {
        [self refreshScrollView];

    }
    else
    {
        if (count>0)
        {
            NSInteger indexCountPostition=self.indexCount;
            if (indexCountPostition==0||count==1)
            {
                self.hasPreviousTimeSheets=FALSE;
            }
            else
            {
                self.hasPreviousTimeSheets=TRUE;
            }

            if (indexCountPostition==count-1 || count==0)
            {
                self.hasNextTimeSheets=FALSE;
            }
            else
            {
                self.hasNextTimeSheets=TRUE;
            }


            [self refreshScrollView];
        }

    }

}
/************************************************************************************************************
 @Function Name   : handlePreviousNextButtonFromApprovalsListforViewTag
 @Purpose         : To hanle next/previous button actions
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

- (void)handlePreviousNextButtonFromApprovalsListforViewTag:(NSInteger)currentViewtag forbuttonTag:(NSInteger)buttonTag
{
    if (buttonTag==PREVIOUS_BUTTON_TAG)
    {

        self.indexCount=currentViewtag-1;

    }
    else if (buttonTag==NEXT_BUTTON_TAG)
    {
        self.indexCount=currentViewtag+1;
    }
    self.isGen4User=NO;
    //[self viewAllEntriesScreen:nil];
    if ([delegate isKindOfClass:[ApprovalsPendingTimesheetViewController class]])
    {
        [self fetchPendingTimesheet];
    }
    else if([delegate isKindOfClass:[ApprovalsPendingExpenseViewController class]])
    {
        [self fetchPendingExpensesheet];
    }
    else if ([delegate isKindOfClass:[ApprovalsPendingTimeOffViewController class]])
    {
        if (self.mainScrollView)
        {
            [self.mainScrollView    removeFromSuperview];
            self.mainScrollView=nil;
        }
	[self fetchPendingTimeoffs];

    }


}

/************************************************************************************************************
 @Function Name   : handleApproveOrRejectActionWithApproverComments
 @Purpose         : To handle footer view button actions
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)handleApproveOrRejectActionWithApproverComments:(NSString *)approverComments andSenderTag:(NSInteger)senderTag
{
    id comments=approverComments;
    if (comments==nil || [comments isKindOfClass:[NSNull class]])
    {
        comments=[NSNull null];
    }
    NSMutableDictionary *userDict=[self.listOfPendingItemsArray objectAtIndex: self.indexCount];

    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        return;

    }

    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];

    if (senderTag==APPROVE_BUTTON_TAG)
    {
		[[NSNotificationCenter defaultCenter] removeObserver: self name: APPROVAL_REJECT_NOTIFICATION object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(approveOrRejectCompletedAction)
                                                     name: APPROVAL_REJECT_NOTIFICATION
                                                   object: nil];

        if ([delegate isKindOfClass:[ApprovalsPendingTimesheetViewController class]])
        {
            NSString *timesheetUri=[userDict objectForKey:@"timesheetUri"];
            NSMutableArray *sheetIdArray=[NSMutableArray arrayWithObject:timesheetUri];

            [[RepliconServiceManager approvalsService]sendRequestToApproveTimesheetsWithURI:sheetIdArray withComments:comments  andDelegate:self];
        }
        else if([delegate isKindOfClass:[ApprovalsPendingExpenseViewController class]])
        {
            NSString *expenseSheetUri=[userDict objectForKey:@"expenseSheetUri"];
            NSMutableArray *sheetIdArray=[NSMutableArray arrayWithObject:expenseSheetUri];

            [[RepliconServiceManager approvalsService]sendRequestToApproveExpenseSheetsWithURI:sheetIdArray withComments:comments  andDelegate:self];

        }
        else if ([delegate isKindOfClass:[ApprovalsPendingTimeOffViewController class]] || [delegate isKindOfClass:[MultiDayInOutViewController class]])
        {
            NSString *timeoffUri=[userDict objectForKey:@"timeoffUri"];
            NSMutableArray *sheetIdArray=[NSMutableArray arrayWithObject:timeoffUri];
            [[RepliconServiceManager approvalsService]sendRequestToApproveTimeOffsWithURI:sheetIdArray withComments:comments  andDelegate:self];
        }
    }
    else if (senderTag==REJECT_BUTTON_TAG)
    {
        [[NSNotificationCenter defaultCenter] removeObserver: self name: APPROVAL_REJECT_NOTIFICATION object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(approveOrRejectCompletedAction)
                                                     name: APPROVAL_REJECT_NOTIFICATION
                                                   object: nil];
        LoginModel *loginModel = [[LoginModel alloc] init];
        NSArray *allDetailsArray = [loginModel getAllUserDetailsInfoFromDb];
        
        BOOL hasValidCharacter =  NO;
        if (comments != [NSNull null]) {
            hasValidCharacter = [comments stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0;
        }
        
        if ([delegate isKindOfClass:[ApprovalsPendingTimesheetViewController class]])
        {
            BOOL isCommentsRequiredForApproval = [[allDetailsArray.firstObject objectForKey:@"areTimeSheetRejectCommentsRequired"] boolValue];
            BOOL canReject =  (isCommentsRequiredForApproval && hasValidCharacter) || !isCommentsRequiredForApproval;
            if (canReject) {
                NSString *timesheetUri=[userDict objectForKey:@"timesheetUri"];
                NSMutableArray *sheetIdArray=[NSMutableArray arrayWithObject:timesheetUri];
                [[RepliconServiceManager approvalsService]sendRequestToRejectTimesheetsWithURI:sheetIdArray withComments:comments  andDelegate:self];
                return;
            }
        }
        else if([delegate isKindOfClass:[ApprovalsPendingExpenseViewController class]])
        {
            BOOL isCommentsRequiredForApproval = [[allDetailsArray.firstObject objectForKey:@"areExpenseRejectCommentsRequired"] boolValue];
            BOOL canReject =  (isCommentsRequiredForApproval && hasValidCharacter) || !isCommentsRequiredForApproval;
            if (canReject) {
                NSString *expenseSheetUri=[userDict objectForKey:@"expenseSheetUri"];
                NSMutableArray *sheetIdArray=[NSMutableArray arrayWithObject:expenseSheetUri];
                [[RepliconServiceManager approvalsService]sendRequestToRejectExpenseSheetsWithURI:sheetIdArray withComments:comments  andDelegate:self];
                return;
            }
        }
        else if ([delegate isKindOfClass:[ApprovalsPendingTimeOffViewController class]] || [delegate isKindOfClass:[MultiDayInOutViewController class]])
        {
            BOOL isCommentsRequiredForApproval = [[allDetailsArray.firstObject objectForKey:@"areTimeOffRejectCommentsRequired"] boolValue];
            BOOL canReject =  (isCommentsRequiredForApproval && hasValidCharacter) || !isCommentsRequiredForApproval;
            if (canReject) {
                NSString *timeoffUri=[userDict objectForKey:@"timeoffUri"];
                NSMutableArray *sheetIdArray=[NSMutableArray arrayWithObject:timeoffUri];
                
                [[RepliconServiceManager approvalsService]sendRequestToRejectTimeOffsWithURI:sheetIdArray withComments:comments  andDelegate:self];
                return;
            }
        }
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];

        [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                       otherButtonTitle:nil
                                               delegate:self
                                                message:RPLocalizedString(rejectionCommentsErrorText, @"")
                                                  title:nil
                                                    tag:LONG_MIN];


        [[NSNotificationCenter defaultCenter] removeObserver: self name: APPROVAL_REJECT_NOTIFICATION object: nil];
    }
}

/************************************************************************************************************
 @Function Name   : approveOrRejectCompletedAction
 @Purpose         : To handle approved or rejection recieved data state
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)approveOrRejectCompletedAction
{
//    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: APPROVAL_REJECT_NOTIFICATION object: nil];
    if (self.hasNextTimeSheets)
    {


    }
    else if (self.hasPreviousTimeSheets)
    {
        self.indexCount=self.indexCount-1;
    }

    if ([delegate isKindOfClass:[ApprovalsPendingTimesheetViewController class]])
    {
        ApprovalsModel *approval = [[ApprovalsModel alloc]init];
        NSMutableArray *listOfUsersArr=[approval getAllPendingTimeSheetsGroupedByDueDatesWithStatus:WAITING_FOR_APRROVAL_STATUS];

        if ([listOfUsersArr count]!=0)
        {
            NSMutableArray *allPendingTSArray=[NSMutableArray array];
            for (int i=0; i<[listOfUsersArr count]; i++)
            {
                NSMutableArray *sectionedUsersArr=[listOfUsersArr objectAtIndex:i];
                for (int j=0; j<[sectionedUsersArr count]; j++)
                {
                    [allPendingTSArray addObject:[sectionedUsersArr objectAtIndex:j]];
                }
            }
            self.listOfPendingItemsArray=allPendingTSArray;
            self.isGen4User=NO;
            [self fetchPendingTimesheet];
        }
        else
        {
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }

    }
    else if([delegate isKindOfClass:[ApprovalsPendingExpenseViewController class]])
    {
        ApprovalsModel *approval = [[ApprovalsModel alloc]init];
        NSMutableArray *listOfUsersArr=[approval getAllPendingExpenseSheetsGroupedByDueDatesWithAnyApprovalStatus];

        if ([listOfUsersArr count]!=0)
        {
            //Fix for defect DE19027
            if ([listOfUsersArr count]==1)
            {
                if ([(NSMutableArray *)[listOfUsersArr objectAtIndex:0] count]!=0)
                {
                    NSMutableArray *allPendingTSArray=[NSMutableArray array];
                    for (int i=0; i<[listOfUsersArr count]; i++)
                    {
                        NSMutableArray *sectionedUsersArr=[listOfUsersArr objectAtIndex:i];
                        for (int j=0; j<[sectionedUsersArr count]; j++)
                        {
                            [allPendingTSArray addObject:[sectionedUsersArr objectAtIndex:j]];
                        }
                    }
                    self.listOfPendingItemsArray=allPendingTSArray;
                    [self fetchPendingExpensesheet];
                }
                else
                {
                    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                    [self.navigationController popViewControllerAnimated:YES];


                }
            }
            else{
                NSMutableArray *allPendingTSArray=[NSMutableArray array];
                for (int i=0; i<[listOfUsersArr count]; i++)
                {
                    NSMutableArray *sectionedUsersArr=[listOfUsersArr objectAtIndex:i];
                    for (int j=0; j<[sectionedUsersArr count]; j++)
                    {
                        [allPendingTSArray addObject:[sectionedUsersArr objectAtIndex:j]];
                    }
                }
                self.listOfPendingItemsArray=allPendingTSArray;
                [self fetchPendingExpensesheet];
            }
        }
        else
        {
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if ([delegate isKindOfClass:[ApprovalsPendingTimeOffViewController class]])
    {
        ApprovalsModel *approval = [[ApprovalsModel alloc]init];
        NSMutableArray *listOfUsersArr=[approval getAllPendingTimeoffs];

        if ([listOfUsersArr count]!=0)
        {
            NSMutableArray *allPendingTSArray=[NSMutableArray array];
            for (int i=0; i<[listOfUsersArr count]; i++)
            {
                [allPendingTSArray addObject:[listOfUsersArr objectAtIndex:i]];
            }
            self.listOfPendingItemsArray=allPendingTSArray;
            [self fetchPendingTimeoffs];

            ApprovalsPendingTimeOffViewController *approvalsPendingTimeOffsCtrl=(ApprovalsPendingTimeOffViewController *)delegate;

            UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:approvalsPendingTimeOffsCtrl.checkOrClearAllBtn];
            [approvalsPendingTimeOffsCtrl.navigationItem setRightBarButtonItem:rightBtn animated:NO];

        }
        else
        {
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
            [self.navigationController popViewControllerAnimated:YES];
            ApprovalsPendingTimeOffViewController *approvalsPendingTimeOffsCtrl=(ApprovalsPendingTimeOffViewController *)delegate;

            [approvalsPendingTimeOffsCtrl.navigationItem setRightBarButtonItem:nil animated:NO];
        }

    }

}

-(void)pushToViewController:(UIViewController *)viewController
{
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void)addActiVityIndicator
{

    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityView setFrame:CGRectMake(0, 0, 30, 30)];
    [activityView setBackgroundColor:[UIColor clearColor]];
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    self.navigationItem.rightBarButtonItem = item;
    [activityView startAnimating];
}

-(void)removeActiVityIndicator
{
     self.navigationItem.rightBarButtonItem = nil;
}


@end
