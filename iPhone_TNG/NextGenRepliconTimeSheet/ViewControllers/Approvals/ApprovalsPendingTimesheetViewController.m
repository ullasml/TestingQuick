#import "ApprovalsPendingTimesheetViewController.h"
#import "Constants.h"
#import "Util.h"
#import "ApprovalsNavigationController.h"
#import "ApprovalsPendingCustomCell.h"
#import "SVPullToRefresh.h"
#import <QuartzCore/QuartzCore.h>
#import "RepliconServiceManager.h"
#import "AppDelegate.h"
#import "ApprovalsModel.h"
#import "DefaultTheme.h"
#import "TeamTableStylist.h"
#import "TeamSectionHeaderView.h"
#import "ApprovalsPendingTimeOffTableViewHeader.h"
#import "ApproveRejectHeaderStylist.h"
#import "UserPermissionsStorage.h"
#import <Blindside/BSInjector.h>
#import "TimesheetDetailsController.h"
#import "TimesheetForDateRange.h"
#import <KSDeferred/KSDeferred.h>
#import "SpinnerOperationsCounter.h"
#import "MinimalTimesheetDeserializer.h"
#import "ApprovalCommentsController.h"
#import "PersistentUserSession.h"
#import "UserSession.h"
#import "TimesheetRepository.h"
#import "ApproveTimesheetContainerController.h"
#import "SpinnerDelegate.h"
#import "LegacyTimesheetApprovalInfo.h"
#import <repliconkit/ReachabilityMonitor.h>
#import "LoginService.h"
#import "ErrorBannerViewParentPresenterHelper.h"


@interface ApprovalsPendingTimesheetViewController () <ApprovalsPendingTimeOffTableViewHeaderDelegate>

@property (nonatomic) MinimalTimesheetDeserializer      *minimalTimesheetDeserializer;
@property (nonatomic) UserPermissionsStorage            *userPermissionsStorage;
@property (nonatomic, weak) id<SpinnerDelegate>         spinnerDelegate;
@property (nonatomic) NSNotificationCenter              *notificationCenter;
@property (nonatomic) ReachabilityMonitor               *reachabilityMonitor;
@property (nonatomic) ApprovalsService                  *approvalsService;
@property (nonatomic) ApprovalsModel                    *approvalsModel;
@property (nonatomic) id<UserSession>                   userSession;
@property (nonatomic) LoginModel                        *loginModel;

@property (nonatomic, weak) id<BSInjector>                 injector;
@property (nonatomic) LoginService                         *loginService;
@property (nonatomic) ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper;

@end

@implementation ApprovalsPendingTimesheetViewController

@synthesize approvalpendingTSTableView;
@synthesize sectionHeaderlabel;
@synthesize sectionHeader;
@synthesize selectedIndexPath;
@synthesize leftButton;
@synthesize selectedSheetsIDsArr;
@synthesize msgLabel;
@synthesize totalRowsCount;
@synthesize commentsTextView;
@synthesize scrollViewController;
@synthesize delegate;

#define WidthOfTextView 300
#define HeightOFMsgLabel 80
#define ButtonSpace 11

- (instancetype)initWithErrorBannerViewParentPresenterHelper:(ErrorBannerViewParentPresenterHelper *)errorBannerViewParentPresenterHelper
                                minimalTimesheetDeserializer:(MinimalTimesheetDeserializer *)minimalTimesheetDeserializer
                                      userPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                                         reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                                          notificationCenter:(NSNotificationCenter *)notificationCenter
                                            approvalsService:(ApprovalsService *)approvalsService
                                             spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                                              approvalsModel:(ApprovalsModel *)approvalsModel
                                                 userSession:(id <UserSession>)userSession
                                                  loginModel:(LoginModel *)loginModel
                                                loginService:(LoginService *)loginService
{
    self = [super init];
    if (self) {
        self.errorBannerViewParentPresenterHelper = errorBannerViewParentPresenterHelper;
        self.minimalTimesheetDeserializer = minimalTimesheetDeserializer;
        self.userPermissionsStorage = userPermissionsStorage;
        self.reachabilityMonitor = reachabilityMonitor;
        self.notificationCenter = notificationCenter;
        self.approvalsService = approvalsService;
        self.spinnerDelegate = spinnerDelegate;
        self.approvalsModel = approvalsModel;
        self.loginService = loginService;
        self.userSession = userSession;
        self.loginModel = loginModel;
    }
    return self;
}

#pragma mark - NSObject

- (void)dealloc
{
    self.approvalpendingTSTableView.delegate = nil;
    self.approvalpendingTSTableView.dataSource = nil;
}

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.translucent = NO;
    [self createListArrays];

    if ([self.listOfUsersArr count] == 0)
    {
        
        self.approvalpendingTSTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    self.approvalpendingTSTableView.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), [self heightForTableView]);

    // MI-558: No need to clear selected sheeds ID everytime view appear
    //[self.selectedSheetsIDsArr removeAllObjects];
    [self refreshTableView];
    [self reloadPendingApprovalsWhenLaunchedFromDeepLink];
    [self changeTableViewInset];
}

- (void)changeTableViewInset
{
    [self.errorBannerViewParentPresenterHelper setTableViewInsetWithErrorBannerPresentation:self.approvalpendingTSTableView];
}

- (void)createListArrays
{
    self.listOfUsersArr = [self.approvalsModel getAllPendingTimeSheetsGroupedByDueDatesWithStatus:WAITING_FOR_APRROVAL_STATUS];
}

- (void)showMessageLabel
{
    [self.msgLabel removeFromSuperview];
    UILabel *tempMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, HeightOFMsgLabel)];
    tempMsgLabel.text = RPLocalizedString(APPROVAL_NO_TIMESHEETS_PENDING_VALIDATION, APPROVAL_NO_TIMESHEETS_PENDING_VALIDATION);
    self.msgLabel = tempMsgLabel;
    self.msgLabel.numberOfLines = 2;
    self.msgLabel.textAlignment = NSTextAlignmentCenter;
    self.msgLabel.font = [UIFont fontWithName:RepliconFontFamily size:16];
    [self.msgLabel setAccessibilityLabel:@"no_timesheets_pending_for_approval_label"];
    [self.view addSubview:self.msgLabel];

    [self.approvalpendingTSTableView.tableHeaderView setHidden:YES];
}

- (void)intialiseTableViewWithFooter
{
    self.totalRowsCount = 0;
    [self.approvalpendingTSTableView removeFromSuperview];
    self.approvalpendingTSTableView = [self setupTableView];
    self.approvalpendingTSTableView.rowHeight = 58.0f;
    self.approvalpendingTSTableView.sectionHeaderHeight = 44.0f;
    
    self.approvalpendingTSTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.approvalpendingTSTableView.delegate = self;
    self.approvalpendingTSTableView.dataSource = self;
    [self.approvalpendingTSTableView setAccessibilityLabel:@"approval_ts_list_tbl_view"];
    [self.view addSubview:approvalpendingTSTableView];
    
    ApprovalsPendingTimeOffTableViewHeader *approvalsPendingTimeOffTableViewHeader = [[ApprovalsPendingTimeOffTableViewHeader alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    approvalsPendingTimeOffTableViewHeader.delegate = self;
    self.approvalpendingTSTableView.tableHeaderView = approvalsPendingTimeOffTableViewHeader;
    
    DefaultTheme *theme = [[DefaultTheme alloc] init];
    ApproveRejectHeaderStylist *approveRejectHeaderStylist = [[ApproveRejectHeaderStylist alloc] initWithTheme:theme];
    [approveRejectHeaderStylist styleApproveRejectHeader:approvalsPendingTimeOffTableViewHeader];
    
    [self configureTableForPullToRefresh];
    [self checkToShowMoreButton];
}

- (UITableView *)setupTableView
{
    return [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), [self heightForTableView])];
}

- (void)loadView
{
    [super loadView];
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.approvalpendingTSTableView.contentInset = UIEdgeInsetsMake(0., 0., CGRectGetHeight(self.tabBarController.tabBar.frame), 0);
    [self intialiseTableViewWithFooter];

    [Util setToolbarLabel:self withText:RPLocalizedString(PENDING_APPROVALS_TIMESHEETS, PENDING_APPROVALS_TIMESHEETS)];

    NSMutableArray *tempselectedSheetsIDsArr = [[NSMutableArray alloc] init];
    self.selectedSheetsIDsArr = tempselectedSheetsIDsArr;
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    self.totalRowsCount = 0;
    return [self.listOfUsersArr count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *sectionedUsersArr = [self.listOfUsersArr objectAtIndex:section];
    self.totalRowsCount = self.totalRowsCount + [sectionedUsersArr count];
    return [sectionedUsersArr count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PendingApprovalsCellIdentifier";

    cell = (ApprovalsPendingCustomCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[ApprovalsPendingCustomCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                 reuseIdentifier:CellIdentifier];
    }
    NSString *leftStr = @"";
    NSString *rightStr = @"";
    NSString *leftLowerStr = @"";

    NSMutableArray *sectionedUsersArr = [self.listOfUsersArr objectAtIndex:indexPath.section];

    NSMutableDictionary *userDict = [sectionedUsersArr objectAtIndex:indexPath.row];
    leftStr = [userDict objectForKey:@"username"];
    if ([userDict objectForKey:@"totalDurationDecimal"] != nil && ![[userDict objectForKey:@"totalDurationDecimal"] isKindOfClass:[NSNull class]])
    {
        rightStr = [Util getRoundedValueFromDecimalPlaces:[[userDict objectForKey:@"totalDurationDecimal"] newDoubleValue]
                                        withDecimalPlaces:2];
    }
    
    NSDate *timesheetStartDate=[Util convertTimestampFromDBToDate:[userDict objectForKey:@"startDate"] ];
    NSDate *timesheetEndDate=[Util convertTimestampFromDBToDate:[userDict objectForKey:@"endDate"] ];
    
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale=[NSLocale currentLocale];;
    [myDateFormatter setLocale:locale];
    [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    myDateFormatter.dateFormat = @"MMM dd";
    NSString *timesheetPeriod=[NSString stringWithFormat:@" %@ - %@",[myDateFormatter stringFromDate:timesheetStartDate],[myDateFormatter stringFromDate:timesheetEndDate]];

    leftLowerStr = timesheetPeriod;

    [cell setDelegate:self];
    [cell setTableDelegate:self];

    NSString *overTime = @"";
    NSString *timeOff = @"";
    NSString *regular = @"";
    NSString *projectHours = @"";
    
    if ([userDict objectForKey:@"overtimeDurationDecimal"] != nil && ![[userDict objectForKey:@"overtimeDurationDecimal"] isKindOfClass:[NSNull class]])
    {
        overTime = [Util getRoundedValueFromDecimalPlaces:[[userDict objectForKey:@"overtimeDurationDecimal"] newDoubleValue]
                                        withDecimalPlaces:2];
    }

    NSString *meal = [NSString stringWithFormat:@"%@", [userDict objectForKey:@"mealBreakPenalties"]];

    if ([userDict objectForKey:@"timeoffDurationDecimal"] != nil && ![[userDict objectForKey:@"timeoffDurationDecimal"] isKindOfClass:[NSNull class]])
    {
        timeOff = [Util getRoundedValueFromDecimalPlaces:[[userDict objectForKey:@"timeoffDurationDecimal"] newDoubleValue]
                                       withDecimalPlaces:2];
    }

    if ([userDict objectForKey:@"regularDurationDecimal"] != nil && ![[userDict objectForKey:@"regularDurationDecimal"] isKindOfClass:[NSNull class]])
    {
        regular = [Util getRoundedValueFromDecimalPlaces:[[userDict objectForKey:@"regularDurationDecimal"] newDoubleValue]
                                       withDecimalPlaces:2];
    }
    if ([userDict objectForKey:@"projectDurationDecimal"] != nil && ![[userDict objectForKey:@"projectDurationDecimal"] isKindOfClass:[NSNull class]])
    {
        projectHours = [Util getRoundedValueFromDecimalPlaces:[[userDict objectForKey:@"projectDurationDecimal"] newDoubleValue]
                                       withDecimalPlaces:2];
    }
    BOOL displaySummaryByPayCode = TRUE;
    if(userDict[@"displaySummaryByPayCode"] != nil && userDict[@"displaySummaryByPayCode"] != (id)[NSNull null]){
        displaySummaryByPayCode = [userDict[@"displaySummaryByPayCode"] boolValue];
    }

    [cell createCellLayoutWithParams:leftStr
                     leftLowerString:leftLowerStr
                            rightstr:rightStr
                      radioButtonTag:indexPath.row
                         overTimeStr:overTime
                             mealStr:meal
                          timeOffStr:timeOff
                          regularStr:regular
                      projectHourStr:projectHours
     displaySummaryByPayCode:displaySummaryByPayCode];

    UIImage *radioButtonImage = nil;
    if ([self.selectedSheetsIDsArr containsObject:[userDict objectForKey:@"timesheetUri"]])
    {
        radioButtonImage = [UIImage imageNamed:@"icon_crewCheck"];
    }
    else
    {
        radioButtonImage = [UIImage imageNamed:@"icon_crewEmpty"];
    }

    [cell.radioButton setImage:radioButtonImage forState:UIControlStateNormal];


    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSMutableArray *sectionedUsersArr = [self.listOfUsersArr objectAtIndex:section];
    NSMutableDictionary *userDict = [sectionedUsersArr objectAtIndex:0];
    NSString *headerTitle = [userDict objectForKey:@"approval_dueDateText"];
    NSString *sectionTitle = [NSString stringWithFormat:@"Due %@", headerTitle];

    TeamSectionHeaderView *teamSectionHeaderView = [[TeamSectionHeaderView alloc] init];
    teamSectionHeaderView.sectionTitleLabel.text = sectionTitle;

    DefaultTheme *theme = [[DefaultTheme alloc] init];
    TeamTableStylist *teamTableStylist = [[TeamTableStylist alloc] initWithTheme:theme];
    [teamTableStylist applyThemeToSectionHeaderView:teamSectionHeaderView];

    return teamSectionHeaderView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.reachabilityMonitor isNetworkReachable] == NO)
    {
        [Util showOfflineAlert];
        return;
    }
    CLS_LOG(@"-----Row selected on ApprovalsPendingTimesheetViewController -----");


    NSMutableArray *sectionedUsersArr = [self.listOfUsersArr objectAtIndex:indexPath.section];
    NSMutableDictionary *userDict = [sectionedUsersArr objectAtIndex:indexPath.row];
    NSString *timesheetURI = [userDict objectForKey:@"timesheetUri"];


    self.selectedUserIndexpath = indexPath;

    NSArray *dbTimesheetArray = [self.approvalsModel getAllPendingTimesheetDaySummaryFromDBForTimesheet:timesheetURI];
    NSArray *dbTimesheetInfoArray = [self.approvalsModel getTimeSheetInfoSheetIdentityForPending:timesheetURI];

    BOOL isWidgetTimesheet = NO;
    if ([dbTimesheetInfoArray count] > 0)
    {
        NSArray *enabledWidgetsUriArray=[self.approvalsModel getAllSupportedAndNotSupportedPendingWidgetsForTimesheetUri:timesheetURI];
        if (enabledWidgetsUriArray.count>0)
        {
            isWidgetTimesheet=TRUE;
        }
    }

    [self.spinnerDelegate hideTransparentLoadingOverlay];
    [self.notificationCenter removeObserver:self
                                       name:APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION
                                     object:nil];

    NSUInteger countOfUsers = 0;
    NSMutableArray *allPendingTSArray = [NSMutableArray array];
    for (int i = 0; i < [self.listOfUsersArr count]; i++)
    {
        NSMutableArray *sectionedUsersArr = [self.listOfUsersArr objectAtIndex:i];
        countOfUsers = countOfUsers + [sectionedUsersArr count];
        for (int j = 0; j < [sectionedUsersArr count]; j++)
        {
            [allPendingTSArray addObject:[sectionedUsersArr objectAtIndex:j]];
        }
    }

    if (countOfUsers > 0)
    {
        NSInteger indexCount = 0;
        for (int i = 0; i < [self.listOfUsersArr count]; i++)
        {
            NSMutableArray *sectionedUsersArr = [self.listOfUsersArr objectAtIndex:i];
            if (indexPath.section == i)
            {
                indexCount = indexCount + indexPath.row + 1;
                break;
            }
            else
            {
                indexCount = indexCount + [sectionedUsersArr count];
            }
        }
        indexCount = indexCount - 1;
        if (indexCount < 0)
        {
            indexCount = 0;
        }

        id<Timesheet> timesheet = [self.minimalTimesheetDeserializer deserialize:userDict];
        ApproveTimesheetContainerController *nextViewController = [self.injector getInstance:[ApproveTimesheetContainerController class]];
        NSString *title = userDict[@"username"];

        LegacyTimesheetApprovalInfo *info = [[LegacyTimesheetApprovalInfo alloc]
                                             initWithAllApprovalsTimesheetsArray:allPendingTSArray
                                             isWidgetTimesheet:isWidgetTimesheet
                                             dbTimesheetArray:dbTimesheetArray
                                             countOfUsers:countOfUsers
                                             indexCount:indexCount
                                             delegate:self
                                             isFromPendingApprovals:YES
                                             isFromPreviousApprovals:NO];

        [nextViewController setupWithLegacyTimesheetApprovalInfo:info timesheet:timesheet delegate:self title:title andUserUri:userDict[@"userUri"]];

        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

#pragma mark -
#pragma mark view update Methods

- (void)updatePreviouslySelectedTimesheetsRadioButtonStatus
{
    for (int k = 0; k < [self.listOfUsersArr count]; k++)
    {
        NSMutableArray *sectionedUsersArr = [self.listOfUsersArr objectAtIndex:k];
        for (int i = 0; i < [sectionedUsersArr count]; i++)
        {
            NSMutableDictionary *userDict = [sectionedUsersArr objectAtIndex:i];
            NSString *timesheetUri = [userDict objectForKey:@"timesheetUri"];
            if ([self.selectedSheetsIDsArr containsObject:timesheetUri])
            {
                [userDict setObject:[NSNumber numberWithBool:YES] forKey:@"IsSelected"];
                [sectionedUsersArr replaceObjectAtIndex:i withObject:userDict];
            }
            else
            {
                [userDict setObject:[NSNumber numberWithBool:NO] forKey:@"IsSelected"];
                [sectionedUsersArr replaceObjectAtIndex:i withObject:userDict];
            }
        }
        [self.listOfUsersArr replaceObjectAtIndex:k withObject:sectionedUsersArr];
    }
}

- (void)handlePendingApprovalsDataReceivedAction
{
    [self.notificationCenter removeObserver:self name:PENDING_APPROVALS_TIMESHEET_NOTIFICATION object:nil];
    [self.spinnerDelegate hideTransparentLoadingOverlay];
    [self.view setUserInteractionEnabled:YES];
    [self createListArrays];
    [self updatePreviouslySelectedTimesheetsRadioButtonStatus];

    

    if ([self.listOfUsersArr count] > 0)
    {
//        CGRect screenRect = [[UIScreen mainScreen] bounds];
//        CGRect frame = self.view.frame;
//        frame.size.height = screenRect.size.height;
//        self.view.frame = frame;

        [self.msgLabel removeFromSuperview];
        self.approvalpendingTSTableView.scrollEnabled = TRUE;
    }
    
    self.approvalpendingTSTableView.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), [self heightForTableView]);

    [self refreshTableView];
    [self checkToShowMoreButton];

    // MI-558: After receiving more rows, "Select All" button is enabled instead of "Clear All"
    ApprovalsPendingTimeOffTableViewHeader *approvalsPendingTimeOffTableViewHeader = (ApprovalsPendingTimeOffTableViewHeader *) self.approvalpendingTSTableView.tableHeaderView;
    [approvalsPendingTimeOffTableViewHeader.toggleButton setTitle:RPLocalizedString(@"Select All", @"Select All") forState:UIControlStateNormal];
    approvalsPendingTimeOffTableViewHeader.toggleButton.tag = CHECK_ALL_BUTTON_TAG;
}

- (void)approve_reject_Completed:(NSNotification *)notification
{
    if (![self.navigationController.topViewController isKindOfClass:[ApprovalsPendingTimesheetViewController class]])
    {
         [self.navigationController popToViewController:self animated:YES];
    }


    [self.notificationCenter removeObserver:self name:APPROVAL_REJECT_DONE_NOTIFICATION object:nil];
    self.commentsTextView.text = @"";
    [self handlePendingApprovalsDataReceivedAction];

    [self.selectedSheetsIDsArr removeAllObjects];

    ApprovalsPendingTimeOffTableViewHeader *approvalsPendingTimeOffTableViewHeader = (ApprovalsPendingTimeOffTableViewHeader *) self.approvalpendingTSTableView.tableHeaderView;
     approvalsPendingTimeOffTableViewHeader.toggleButton.tag = CLEAR_ALL_BUTTON_TAG;
    [approvalsPendingTimeOffTableViewHeader didToggleButtonForSelectOrClearAll:nil];
}

- (void)refreshTableView
{
    self.totalRowsCount = 0;
    [self.approvalpendingTSTableView reloadData];

    if ([self.listOfUsersArr count] == 0)
    {
        [self showMessageLabel];
        [self.approvalpendingTSTableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-64)];
    } else
    {
        [self.msgLabel removeFromSuperview];
        [self.approvalpendingTSTableView.tableHeaderView setHidden:NO];
    }

    // MI-558: No need to clear selected everytime view appear
    //[self.selectedSheetsIDsArr removeAllObjects];

    //ApprovalsPendingTimeOffTableViewHeader *approvalsPendingTimeOffTableViewHeader = (ApprovalsPendingTimeOffTableViewHeader *) self.approvalpendingTSTableView.tableHeaderView;
    // approvalsPendingTimeOffTableViewHeader.toggleButton.tag = CLEAR_ALL_BUTTON_TAG;
    //[approvalsPendingTimeOffTableViewHeader didToggleButtonForSelectOrClearAll:nil];
}


- (void)updateTabBarItemBadge
{
}

#pragma mark -
#pragma mark Other Methods

- (void)configureTableForPullToRefresh
{
    ApprovalsPendingTimesheetViewController *weakSelf = self;

    [self.approvalpendingTSTableView addPullToRefreshWithActionHandler:^{
        int64_t delayInSeconds = 0.0;
        [weakSelf.approvalpendingTSTableView.pullToRefreshView startAnimating];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [weakSelf refreshAction];
        });
    }];

    [self.approvalpendingTSTableView addInfiniteScrollingWithActionHandler:^{
        int64_t delayInSeconds = 0.0;
        [weakSelf.approvalpendingTSTableView.infiniteScrollingView startAnimating];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [weakSelf moreAction];
        });
    }];
}

- (void)refreshAction
{
    if (![NetworkMonitor isNetworkAvailableForListener:self])
    {
        [self.view setUserInteractionEnabled:YES];
        ApprovalsPendingTimesheetViewController *weakSelf = self;
        [weakSelf.approvalpendingTSTableView.pullToRefreshView stopAnimating];
        [Util showOfflineAlert];
        return;
    }
    CLS_LOG(@"-----Update record fetch action ApprovalsPendingTimesheetViewController -----");
    [self.notificationCenter removeObserver:self name:PENDING_APPROVALS_TIMESHEET_NOTIFICATION object:nil];
    [self.notificationCenter addObserver:self selector:@selector(refreshViewFromPullToRefreshedData)
                                                 name:PENDING_APPROVALS_TIMESHEET_NOTIFICATION
                                               object:nil];
    [[RepliconServiceManager approvalsService] fetchSummaryOfTimeSheetPendingApprovalsForUser:self];
    [self.loginService fetchGetMyNotificationSummary];
}

- (void)refreshActionForUriNotFoundError
{
    if (![NetworkMonitor isNetworkAvailableForListener:self])
    {
        [Util showOfflineAlert];
        return;
    }

    [self.spinnerDelegate showTransparentLoadingOverlay];

    CLS_LOG(@"-----Check for update action triggered on ApprovalsPendingTimesheetViewController-----");

    [self.notificationCenter addObserver:self selector:@selector(refreshViewFromPullToRefreshedData)
                                                 name:PENDING_APPROVALS_TIMESHEET_NOTIFICATION
                                               object:nil];

    [[RepliconServiceManager approvalsService] fetchSummaryOfTimeSheetPendingApprovalsForUser:self];
}

- (void)refreshViewFromPullToRefreshedData
{
    ApprovalsPendingTimeOffTableViewHeader *approvalsPendingTimeOffTableViewHeader = (ApprovalsPendingTimeOffTableViewHeader *) self.approvalpendingTSTableView.tableHeaderView;
    [approvalsPendingTimeOffTableViewHeader.toggleButton setTitle:RPLocalizedString(@"Select All", @"Select All") forState:UIControlStateNormal];
    approvalsPendingTimeOffTableViewHeader.toggleButton.tag = CHECK_ALL_BUTTON_TAG;
    [self.spinnerDelegate hideTransparentLoadingOverlay];
    [self.view setUserInteractionEnabled:YES];
    [self.notificationCenter removeObserver:self name:PENDING_APPROVALS_TIMESHEET_NOTIFICATION object:nil];
    ApprovalsPendingTimesheetViewController *weakSelf = self;
    [weakSelf.approvalpendingTSTableView.pullToRefreshView stopAnimating];
    
    // MI-558:  Need to clear selected everytime view pull to refresh
    [self.selectedSheetsIDsArr removeAllObjects];
    self.approvalpendingTSTableView.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), [self heightForTableView]);
    [self handlePendingApprovalsDataReceivedAction];
}

- (void)moreAction
{
    if (![NetworkMonitor isNetworkAvailableForListener:self])
    {
        [self.view setUserInteractionEnabled:YES];
        ApprovalsPendingTimesheetViewController *weakSelf = self;
        weakSelf.approvalpendingTSTableView.showsInfiniteScrolling = FALSE;
        [Util showOfflineAlert];
        return;
    }
    CLS_LOG(@"-----More record fetch action ApprovalsPendingTimesheetViewController -----");
    [self.notificationCenter removeObserver:self name:PENDING_APPROVALS_TIMESHEET_NOTIFICATION object:nil];
    [self.notificationCenter addObserver:self
                                             selector:@selector(reloadViewAfterMoreDataFetchForPendingTimesheets)
                                                 name:PENDING_APPROVALS_TIMESHEET_NOTIFICATION
                                               object:nil];
    [[RepliconServiceManager approvalsService] fetchSummaryOfNextPendingTimesheetApprovalsForUser:self];
}

- (void)reloadViewAfterMoreDataFetchForPendingTimesheets
{
    [self.notificationCenter removeObserver:self name:PENDING_APPROVALS_TIMESHEET_NOTIFICATION object:nil];
    ApprovalsPendingTimesheetViewController *weakSelf = self;
    [weakSelf.approvalpendingTSTableView.infiniteScrollingView stopAnimating];
    self.approvalpendingTSTableView.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), [self heightForTableView]);
    [self handlePendingApprovalsDataReceivedAction];
}

- (void)checkToShowMoreButton
{
    NSNumber *timeSheetsCount = [[NSUserDefaults standardUserDefaults] objectForKey:@"pendingApprovalsTSDownloadCount"];
    NSNumber *fetchCount = [[AppProperties getInstance] getAppPropertyFor:@"approvalsDownloadCount"];

    if (([timeSheetsCount intValue] < [fetchCount intValue]))
    {
        self.approvalpendingTSTableView.showsInfiniteScrolling = FALSE;
    }
    else
    {
        self.approvalpendingTSTableView.showsInfiniteScrolling = TRUE;
    }
    [self changeTableViewInset];
}

- (void)handleButtonClickforSelectedUser:(NSIndexPath *)indexPath isSelected:(BOOL)isSelected
{
    NSMutableArray *sectionedUsersArr = [self.listOfUsersArr objectAtIndex:indexPath.section];
    NSMutableDictionary *userDict = [sectionedUsersArr objectAtIndex:indexPath.row];
    [userDict setObject:[NSNumber numberWithBool:isSelected] forKey:@"IsSelected"];
    [sectionedUsersArr replaceObjectAtIndex:indexPath.row withObject:userDict];
    [self.listOfUsersArr replaceObjectAtIndex:indexPath.section withObject:sectionedUsersArr];

    if (isSelected)
    {
        [self.selectedSheetsIDsArr addObject:[userDict objectForKey:@"timesheetUri"]];
    }
    else
    {
        [self.selectedSheetsIDsArr removeObject:[userDict objectForKey:@"timesheetUri"]];
    }


     ApprovalsPendingTimeOffTableViewHeader *approvalsPendingTimeOffTableViewHeader = (ApprovalsPendingTimeOffTableViewHeader *) self.approvalpendingTSTableView.tableHeaderView;
    if (self.selectedSheetsIDsArr.count== self.totalRowsCount)
    {
         approvalsPendingTimeOffTableViewHeader.toggleButton.tag = CHECK_ALL_BUTTON_TAG;
        [approvalsPendingTimeOffTableViewHeader didToggleButtonForSelectOrClearAll:nil];
    }
    else if (self.selectedSheetsIDsArr.count== 0)
    {
        approvalsPendingTimeOffTableViewHeader.toggleButton.tag = CLEAR_ALL_BUTTON_TAG;
        [approvalsPendingTimeOffTableViewHeader didToggleButtonForSelectOrClearAll:nil];
    }
    else if(self.selectedSheetsIDsArr.count < self.totalRowsCount)
    {
        approvalsPendingTimeOffTableViewHeader.toggleButton.tag = CHECK_ALL_BUTTON_TAG;
        [approvalsPendingTimeOffTableViewHeader.toggleButton setTitle:RPLocalizedString(@"Select All", @"Select All") forState:UIControlStateNormal];
    }



}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self resetView:YES];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [textView setSelectedRange:NSMakeRange(0, 0)];
    return YES;
}

- (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound)
    {
        return YES;
    }
    [self resetView:NO];
    [txtView resignFirstResponder];
    return NO;
}

- (void)resetView:(BOOL)isReset
{
    approvalpendingTSTableView.userInteractionEnabled = !isReset;
}

#pragma mark -
#pragma mark approve and reject methods

- (void)rejectAction:(id)sender
{

    if ([self.selectedSheetsIDsArr count] == 0)
    {

        [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                       otherButtonTitle:nil
                                               delegate:self
                                                message:RPLocalizedString(APPROVAL_TIMESHEET_VALIDATION_MSG, @"")
                                                  title:nil
                                                    tag:0];

        return;
    }
    else
    {
        NSArray *allDetailsArray = [self.loginModel getAllUserDetailsInfoFromDb];
        BOOL isCommentsRequiredForApproval = [[allDetailsArray.firstObject objectForKey:@"areTimeSheetRejectCommentsRequired"] boolValue];
        if (isCommentsRequiredForApproval) {
            ApprovalCommentsController *approvalCommentsController = [self.injector getInstance:[ApprovalCommentsController class]];
            [approvalCommentsController setUpApprovalActionType:RejectActionType delegate:self commentsRequired:isCommentsRequiredForApproval];
            [self.navigationController pushViewController:approvalCommentsController animated:YES];
        }
        else
        {

            [commentsTextView resignFirstResponder];
            id comments = self.commentsTextView.text;
            if (comments == nil || [comments isKindOfClass:[NSNull class]])
            {
                comments = [NSNull null];
            }
            [self rejectTimesheetsWithComments:comments];

        }

    }

}

- (void)approveAction:(id)sender
{
    if ([self.selectedSheetsIDsArr count] == 0)
    {
        [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                       otherButtonTitle:nil
                                               delegate:self
                                                message:RPLocalizedString(APPROVAL_TIMESHEET_VALIDATION_MSG, @"")
                                                  title:nil
                                                    tag:0];
        return;
    }
    else
    {
        [commentsTextView resignFirstResponder];
        id comments = self.commentsTextView.text;
        if (comments == nil || [comments isKindOfClass:[NSNull class]])
        {
            comments = [NSNull null];
        }
        [self approveTimesheetsWithComments:comments];
    }


}

#pragma mark - <ApprovalsPendingTimeOffTableViewHeaderDelegate>

- (void)approvalsPendingTimeOffTableViewHeaderDidSignalIntentToApprove:(ApprovalsPendingTimeOffTableViewHeader *)approvalsPendingTimeOffTableViewHeader
{
    [self approveAction:nil];
}

- (void)approvalsPendingTimeOffTableViewHeaderDidSignalIntentToReject:(ApprovalsPendingTimeOffTableViewHeader *)approvalsPendingTimeOffTableViewHeader
{
    [self rejectAction:nil];
}

- (void)approvalsPendingTimeOffTableViewHeaderDidSignalIntentToSelectAll:(ApprovalsPendingTimeOffTableViewHeader *)approvalsPendingTimeOffTableViewHeader
{
    for (int i = 0; i < [self.listOfUsersArr count]; i++)
    {
        NSMutableArray *sectionedUsersArr = [self.listOfUsersArr objectAtIndex:i];
        for (int i = 0; i < [sectionedUsersArr count]; i++)
        {
            NSMutableDictionary *userDict = [sectionedUsersArr objectAtIndex:i];
            if ([[userDict objectForKey:@"IsSelected"] intValue] != 1)
            {
                [userDict setObject:[NSNumber numberWithBool:YES] forKey:@"IsSelected"];
                [sectionedUsersArr replaceObjectAtIndex:i withObject:userDict];
                [self.selectedSheetsIDsArr addObject:[userDict objectForKey:@"timesheetUri"]];
            }
        }
        [self.listOfUsersArr replaceObjectAtIndex:i withObject:sectionedUsersArr];
    }

    self.totalRowsCount = 0;
    [self.approvalpendingTSTableView reloadData];
}

- (void)approvalsPendingTimeOffTableViewHeaderDidSignalIntentToClearAll:(ApprovalsPendingTimeOffTableViewHeader *)approvalsPendingTimeOffTableViewHeader
{
    for (int i = 0; i < [self.listOfUsersArr count]; i++)
    {
        NSMutableArray *sectionedUsersArr = [self.listOfUsersArr objectAtIndex:i];
        for (int i = 0; i < [sectionedUsersArr count]; i++)
        {
            NSMutableDictionary *userDict = [sectionedUsersArr objectAtIndex:i];
            if ([[userDict objectForKey:@"IsSelected"] intValue] != 0)
            {
                [userDict setObject:[NSNumber numberWithBool:NO] forKey:@"IsSelected"];
                [sectionedUsersArr replaceObjectAtIndex:i withObject:userDict];
                [self.selectedSheetsIDsArr removeObject:[userDict objectForKey:@"timesheetUri"]];
            }
        }
        [self.listOfUsersArr replaceObjectAtIndex:i withObject:sectionedUsersArr];
    }

    self.totalRowsCount = 0;
    [self.selectedSheetsIDsArr removeAllObjects];
    [self.approvalpendingTSTableView reloadData];
}

#pragma mark - <ApprovalCommentsControllerDelegate>

- (void)approvalsCommentsControllerDidRequestApproveAction:(ApprovalCommentsController *)approvalCommentsController withComments:(NSString *)comments
{
    [self approveTimesheetsWithComments:comments];
}
- (void)approvalsCommentsControllerDidRequestRejectAction:(ApprovalCommentsController *)approvalCommentsController withComments:(NSString *)comments
{
    [self rejectTimesheetsWithComments:comments];
}


#pragma mark - <ApproveTimesheetContainerControllerDelegate>

- (void)approveTimesheetContainerController:(ApproveTimesheetContainerController *)approveTimesheetContainerController
                        didApproveTimesheet:(id<Timesheet>)timesheet;
{
    [self.selectedSheetsIDsArr removeAllObjects];
    [self.selectedSheetsIDsArr addObject:[timesheet uri]];
    [self approveAction:nil];
}

#pragma mark NetworkMonitor

- (void)networkActivated
{

}

#pragma mark - Private

-(void)approveTimesheetsWithComments:(NSString *)comments
{
    if ([self.reachabilityMonitor isNetworkReachable] == NO)
    {
        [Util showOfflineAlert];
        return;
    }

    CLS_LOG(@"-----Approve action on ApprovalsPendingTimesheetViewController -----");
    [self resetView:NO];
    NSString *commentsToBeSent = @"";
    if (comments) {
        commentsToBeSent = comments;
    }
    [self.spinnerDelegate showTransparentLoadingOverlay];
    [self.approvalsService sendRequestToApproveTimesheetsWithURI:self.selectedSheetsIDsArr
                                                    withComments:commentsToBeSent
                                                     andDelegate:self];
    [self.notificationCenter removeObserver:self name:APPROVAL_REJECT_DONE_NOTIFICATION object:nil];
    [self.notificationCenter addObserver:self
                                selector:@selector(approve_reject_Completed:)
                                    name:APPROVAL_REJECT_DONE_NOTIFICATION
                                  object:nil];
}

-(void)rejectTimesheetsWithComments:(NSString *)comments
{
    if ([self.reachabilityMonitor isNetworkReachable] == NO)
    {
        [Util showOfflineAlert];
        return;
    }
    
    CLS_LOG(@"-----Reject action on ApprovalsPendingTimesheetViewController -----");
    [self resetView:NO];
    NSString *commentsToBeSent = @"";
    if (comments) {
        commentsToBeSent = comments;
    }
    [self.spinnerDelegate showTransparentLoadingOverlay];
    [self.approvalsService sendRequestToRejectTimesheetsWithURI:self.selectedSheetsIDsArr
                                                   withComments:commentsToBeSent
                                                    andDelegate:self];
    [self.notificationCenter removeObserver:self name:APPROVAL_REJECT_DONE_NOTIFICATION object:nil];

    [self.notificationCenter addObserver:self
                                selector:@selector(approve_reject_Completed:)
                                    name:APPROVAL_REJECT_DONE_NOTIFICATION
                                  object:nil];
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

-(void)reloadPendingApprovalsWhenLaunchedFromDeepLink{
    if(self.isFromDeepLink && [self.listOfUsersArr count] == 0){
        [self.msgLabel removeFromSuperview];
        if ([NetworkMonitor isNetworkAvailableForListener:self]){
            [self.spinnerDelegate showTransparentLoadingOverlay];
        }
        [self refreshAction];
        self.isFromDeepLink = NO;
    }
}

@end
