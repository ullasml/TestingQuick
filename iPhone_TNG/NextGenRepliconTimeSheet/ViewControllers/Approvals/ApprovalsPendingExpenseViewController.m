#import "ApprovalsPendingExpenseViewController.h"
#import "Constants.h"
#import "Util.h"
#import "ApprovalsNavigationController.h"
#import "ApprovalsPendingCustomCell.h"
#import "SVPullToRefresh.h"
#import <QuartzCore/QuartzCore.h>
#import "RepliconServiceManager.h"
#import "AppDelegate.h"
#import "ApprovalsModel.h"
#import "ApprovalsPendingTimeOffTableViewHeader.h"
#import "ApproveRejectHeaderStylist.h"
#import "DefaultTheme.h"
#import "TeamSectionHeaderView.h"
#import "TeamTableStylist.h"
#import <Blindside/BSInjector.h>
#import "ApprovalsService.h"


@interface ApprovalsPendingExpenseViewController ()

@property (nonatomic) NSNotificationCenter *notificationCenter;
@property (nonatomic) ApprovalsService *approvalsService;
@property (nonatomic) LoginModel *loginModel;
@property (nonatomic) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic) id<BSInjector> injector;
@property (nonatomic) ApprovalsModel *approvalsModel;
@property (nonatomic) LoginService *loginService;


@end


@implementation ApprovalsPendingExpenseViewController

@synthesize approvalpendingTSTableView;
@synthesize sectionHeaderlabel;
@synthesize sectionHeader;
@synthesize selectedIndexPath;
@synthesize expenseSheetsArray;
@synthesize leftButton;
@synthesize selectedSheetsIDsArr;
@synthesize msgLabel;
@synthesize totalRowsCount;
@synthesize commentsTextView;
@synthesize scrollViewController;
@synthesize selectedUserIndexpath;


#define HeightOFMsgLabel 80
#define Each_Cell_Row_Height_58 58


- (instancetype)initWithNotificationCenter:(NSNotificationCenter *)notificationCenter
                           spinnerDelegate:(id<SpinnerDelegate>)spinnerDelegate
                          approvalsService:(ApprovalsService *)approvalsService
                            approvalsModel:(ApprovalsModel *)approvalsModel
                                loginModel:(LoginModel *)loginModel
                              loginService:(LoginService *)loginService
{
    self = [super init];
    if (self)
    {
        self.notificationCenter = notificationCenter;
        self.approvalsService = approvalsService;
        self.loginModel = loginModel;
        self.spinnerDelegate = spinnerDelegate;
        self.approvalsModel = approvalsModel;
        self.loginService = loginService;
    }
    return self;
}

#pragma mark - NSObject

- (void)dealloc
{
    [self.notificationCenter removeObserver:self];
    self.approvalpendingTSTableView.delegate = nil;
    self.approvalpendingTSTableView.dataSource = nil;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - View lifecycle

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

    [self refreshTableView];
    [self reloadPendingApprovalsWhenLaunchedFromDeepLink];
    // MI-558: No need to clear selected sheeds ID everytime view appear
    //[self.selectedSheetsIDsArr removeAllObjects];

    [self.approvalpendingTSTableView reloadData];
}

- (void)createListArrays
{
    self.listOfUsersArr = [self.approvalsModel getAllPendingExpenseSheetsGroupedByDueDates];
}

- (void)showMessageLabel
{
    [self.msgLabel removeFromSuperview];
    UILabel *tempMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, HeightOFMsgLabel)];
    tempMsgLabel.text = RPLocalizedString(APPROVAL_NO_EXPENSESHEETS_PENDING_VALIDATION, APPROVAL_NO_EXPENSESHEETS_PENDING_VALIDATION);
    self.msgLabel = tempMsgLabel;
    self.msgLabel.numberOfLines = 2;
    self.msgLabel.textAlignment = NSTextAlignmentCenter;
    self.msgLabel.font = [UIFont fontWithName:RepliconFontFamilyLight size:16];

    [self.view addSubview:self.msgLabel];

    [self.approvalpendingTSTableView.tableHeaderView setHidden:YES];

}

- (void)intialiseTableViewWithFooter
{
    self.totalRowsCount = 0;
    [self.approvalpendingTSTableView removeFromSuperview];

    UITableView *tempapprovalpendingTSTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), [self heightForTableView])];
    self.approvalpendingTSTableView = tempapprovalpendingTSTableView;
    self.approvalpendingTSTableView.rowHeight = Each_Cell_Row_Height_58;
    self.approvalpendingTSTableView.sectionHeaderHeight = 44.0f;

    self.approvalpendingTSTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    approvalpendingTSTableView.delegate = self;
    approvalpendingTSTableView.dataSource = self;
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

- (void)loadView
{
    [super loadView];

    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.approvalpendingTSTableView.contentInset = UIEdgeInsetsMake(0., 0., CGRectGetHeight(self.tabBarController.tabBar.frame), 0);
     [self intialiseTableViewWithFooter];
    [Util setToolbarLabel:self withText:RPLocalizedString(PENDING_APPROVALS_EXPENSES, PENDING_APPROVALS_EXPENSES)];

    NSMutableArray *tempselectedSheetsIDsArr = [[NSMutableArray alloc] init];
    self.selectedSheetsIDsArr = tempselectedSheetsIDsArr;
}
-(void)viewDidLoad
{
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
}

#pragma mark -
#pragma mark - UITableView Delegates

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
    NSString *rightLowerStr = @"";

    NSMutableArray *sectionedUsersArr = [self.listOfUsersArr objectAtIndex:indexPath.section];

    NSMutableDictionary *userDict = [sectionedUsersArr objectAtIndex:indexPath.row];
    leftStr = [userDict objectForKey:@"username"];
    NSString *reimburseAmount = [userDict objectForKey:@"reimbursementAmount"];
    NSString *reimburseCurrency = [userDict objectForKey:@"reimbursementAmountCurrencyName"];
    NSString *convertedReimburseAmount = nil;
    if (reimburseAmount != nil && ![reimburseAmount isKindOfClass:[NSNull class]])
    {
        convertedReimburseAmount = [Util getRoundedValueFromDecimalPlaces:[reimburseAmount newDoubleValue]
                                                        withDecimalPlaces:2];
    }

    NSString *reimburseAmountStr = [NSString stringWithFormat:@"%@ %@", reimburseCurrency, convertedReimburseAmount];
    rightStr = reimburseAmountStr;

    NSDate *expenseDate = [Util convertTimestampFromDBToDate:[[userDict objectForKey:@"expenseDate"] stringValue]];
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];

    NSLocale *locale = [NSLocale currentLocale];
    [myDateFormatter setLocale:locale];
    [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    myDateFormatter.dateFormat = @"MMM dd, yyyy";
    NSString *expenseDateStr = [myDateFormatter stringFromDate:expenseDate];

    leftLowerStr = expenseDateStr;

    rightLowerStr = [userDict objectForKey:@"description"];

    [cell setDelegate:self];
    [cell setTableDelegate:self];

    [cell createCellLayoutWithParams:leftStr
                     leftLowerString:leftLowerStr
                            rightstr:rightStr
                    rightLowerString:rightLowerStr
                      radioButtonTag:indexPath.row];

    UIImage *radioButtonImage = nil;
    if ([self.selectedSheetsIDsArr containsObject:[userDict objectForKey:@"expenseSheetUri"]])
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
    NSMutableArray *sectionedUsersArr = self.listOfUsersArr[section];
    NSMutableDictionary *userDict = sectionedUsersArr.firstObject;
    NSString *headerTitle = userDict[@"approval_dueDateText"];
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

    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        return;

    }
    CLS_LOG(@"-----Row selected on ApprovalsPendingExpenseViewController -----");
    NSMutableArray *sectionedUsersArr = [self.listOfUsersArr objectAtIndex:indexPath.section];
    NSMutableDictionary *userDict = [sectionedUsersArr objectAtIndex:indexPath.row];
    NSString *expenseSheetUri = [userDict objectForKey:@"expenseSheetUri"];

    self.selectedUserIndexpath = indexPath;

    [self.spinnerDelegate hideTransparentLoadingOverlay];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:APPROVALS_EXPENSE_SUMMARY_RECIEVED_NOTIFICATION
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
            if (self.selectedUserIndexpath.section == i)
            {
                indexCount = indexCount + self.selectedUserIndexpath.row + 1;
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

        ApprovalsScrollViewController *tempscrollViewController = [[ApprovalsScrollViewController alloc] init];
        self.scrollViewController = tempscrollViewController;

        [self.scrollViewController setIndexCount:indexCount];
        [self.scrollViewController setListOfPendingItemsArray:allPendingTSArray];
        self.scrollViewController.currentViewIndex = 0;
        self.scrollViewController.sheetStatus = WAITING_FOR_APRROVAL_STATUS;
        self.scrollViewController.delegate = self;

        if (indexCount == 0)
        {
            self.scrollViewController.hasPreviousTimeSheets = FALSE;
        }
        else
        {
            self.scrollViewController.hasPreviousTimeSheets = TRUE;
        }

        if (indexCount == countOfUsers - 1 || countOfUsers == 0)
        {
            self.scrollViewController.hasNextTimeSheets = FALSE;
        }
        else
        {
            self.scrollViewController.hasNextTimeSheets = TRUE;
        }

        [scrollViewController setHidesBottomBarWhenPushed:NO];
        [self.navigationController pushViewController:self.scrollViewController animated:YES];
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:APPROVALS_EXPENSE_SUMMARY_RECIEVED_NOTIFICATION
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self.scrollViewController
                                             selector:@selector(viewAllEntriesScreen:)
                                                 name:APPROVALS_EXPENSE_SUMMARY_RECIEVED_NOTIFICATION
                                               object:nil];

    NSArray *dbTimesheetArray = [self.approvalsModel getAllPendingExpenseExpenseEntriesFromDBForExpenseSheetUri:expenseSheetUri];

    if ([dbTimesheetArray count] == 0)
    {
        [self.spinnerDelegate showTransparentLoadingOverlay];
        [self.approvalsService fetchApprovalPendingExpenseEntryDataForExpenseSheet:expenseSheetUri
                                                                                          withDelegate:self];

    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:APPROVALS_EXPENSE_SUMMARY_RECIEVED_NOTIFICATION
                                                            object:nil];
    }
}

#pragma mark -
#pragma mark view update Methods

- (void)updatePreviouslySelectedExpenseSheetsRadioButtonStatus
{
    for (int k = 0; k < [self.listOfUsersArr count]; k++)
    {
        NSMutableArray *sectionedUsersArr = [self.listOfUsersArr objectAtIndex:k];
        for (int i = 0; i < [sectionedUsersArr count]; i++)
        {
            NSMutableDictionary *userDict = [sectionedUsersArr objectAtIndex:i];
            NSString *timesheetUri = [userDict objectForKey:@"expenseSheetUri"];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PENDING_APPROVALS_EXPENSE_NOTIFICATION object:nil];
    [self.spinnerDelegate hideTransparentLoadingOverlay];
    [self.view setUserInteractionEnabled:YES];
    [self createListArrays];
    [self updatePreviouslySelectedExpenseSheetsRadioButtonStatus];


    if ([self.listOfUsersArr count] > 0)
    {

        [self.msgLabel removeFromSuperview];
        self.approvalpendingTSTableView.scrollEnabled = TRUE;
        [self.approvalpendingTSTableView.tableHeaderView setHidden:NO];

    }
    else if ([self.listOfUsersArr count] == 0)
    {
        [self showMessageLabel];
       
    }
    self.approvalpendingTSTableView.frame = CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), [self heightForTableView]);

    [self refreshTableView];

    [self checkToShowMoreButton];

    [self.approvalpendingTSTableView reloadData];
    
    // After receiving more rows, "Select All" button is enabled instead of "Clear All"
    ApprovalsPendingTimeOffTableViewHeader *approvalsPendingTimeOffTableViewHeader = (ApprovalsPendingTimeOffTableViewHeader *) self.approvalpendingTSTableView.tableHeaderView;
    [approvalsPendingTimeOffTableViewHeader.toggleButton setTitle:RPLocalizedString(@"Select All", @"Select All") forState:UIControlStateNormal];
    approvalsPendingTimeOffTableViewHeader.toggleButton.tag = CHECK_ALL_BUTTON_TAG;
}

- (void)approve_reject_Completed
{
     [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APPROVAL_REJECT_DONE_NOTIFICATION object:nil];
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

    if ([self.listOfUsersArr count] == 0)
    {
        [self showMessageLabel];
        [self.approvalpendingTSTableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    }
    else
    {
        [self.msgLabel removeFromSuperview];
        [self.approvalpendingTSTableView.tableHeaderView setHidden:NO];
    }

    // MI-558: No need to clear selected ID everytime view referesh
    //[self.selectedSheetsIDsArr removeAllObjects];

    //ApprovalsPendingTimeOffTableViewHeader *approvalsPendingTimeOffTableViewHeader = (ApprovalsPendingTimeOffTableViewHeader *) self.approvalpendingTSTableView.tableHeaderView;
    //approvalsPendingTimeOffTableViewHeader.toggleButton.tag = CLEAR_ALL_BUTTON_TAG;
    //[approvalsPendingTimeOffTableViewHeader didToggleButtonForSelectOrClearAll:nil];
}


- (void)updateTabBarItemBadge
{
}

#pragma mark -
#pragma mark Other Methods

- (void)configureTableForPullToRefresh
{
    ApprovalsPendingExpenseViewController *weakSelf = self;

    [self.approvalpendingTSTableView addPullToRefreshWithActionHandler:^{

        int64_t delayInSeconds = 0.0;
        [weakSelf.approvalpendingTSTableView.pullToRefreshView startAnimating];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
            [weakSelf refreshAction];
        });
    }];

    // setup infinite scrolling
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
        ApprovalsPendingExpenseViewController *weakSelf = self;
        [weakSelf.approvalpendingTSTableView.pullToRefreshView stopAnimating];
        [Util showOfflineAlert];
        return;
    }
    CLS_LOG(@"-----Update record fetch action ApprovalsPendingExpenseViewController -----");
    [self.notificationCenter removeObserver:self name:PENDING_APPROVALS_EXPENSE_NOTIFICATION object:nil];
    [self.notificationCenter addObserver:self selector:@selector(refreshViewFromPullToRefreshedData)
                                                 name:PENDING_APPROVALS_EXPENSE_NOTIFICATION
                                               object:nil];
    [self.approvalsService fetchSummaryOfExpenseSheetPendingApprovalsForUser:self];
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

    CLS_LOG(@"-----Check for update action triggered on ApprovalsPendingExpenseViewController-----");

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromPullToRefreshedData)

                                                 name:PENDING_APPROVALS_EXPENSE_NOTIFICATION

                                               object:nil];

    [self.approvalsService fetchSummaryOfExpenseSheetPendingApprovalsForUser:self];
}


- (void)refreshViewFromPullToRefreshedData
{
    ApprovalsPendingTimeOffTableViewHeader *approvalsPendingTimeOffTableViewHeader = (ApprovalsPendingTimeOffTableViewHeader *) self.approvalpendingTSTableView.tableHeaderView;
    [approvalsPendingTimeOffTableViewHeader.toggleButton setTitle:RPLocalizedString(@"Select All", @"Select All") forState:UIControlStateNormal];
    approvalsPendingTimeOffTableViewHeader.toggleButton.tag = CHECK_ALL_BUTTON_TAG;
    [self.spinnerDelegate hideTransparentLoadingOverlay];
    [self.view setUserInteractionEnabled:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PENDING_APPROVALS_EXPENSE_NOTIFICATION object:nil];
    ApprovalsPendingExpenseViewController *weakSelf = self;
    [weakSelf.approvalpendingTSTableView.pullToRefreshView stopAnimating];
    
    // MI-558:  Need to clear selected everytime view pull to refresh
    [self.selectedSheetsIDsArr removeAllObjects];
    self.approvalpendingTSTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 37);
    [self handlePendingApprovalsDataReceivedAction];
}

- (void)moreAction
{
    if (![NetworkMonitor isNetworkAvailableForListener:self])
    {
        [self.view setUserInteractionEnabled:YES];
        ApprovalsPendingExpenseViewController *weakSelf = self;
        weakSelf.approvalpendingTSTableView.showsInfiniteScrolling = FALSE;
        [Util showOfflineAlert];
        return;
    }
    CLS_LOG(@"-----More record fetch action ApprovalsPendingExpenseViewController -----");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PENDING_APPROVALS_EXPENSE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadViewAfterMoreDataFetchForPendingexpenseSheets)
                                                 name:PENDING_APPROVALS_EXPENSE_NOTIFICATION
                                               object:nil];
    [self.approvalsService fetchSummaryOfNextPendingExpenseApprovalsForUser:self];
}

- (void)reloadViewAfterMoreDataFetchForPendingexpenseSheets
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PENDING_APPROVALS_EXPENSE_NOTIFICATION object:nil];
    ApprovalsPendingExpenseViewController *weakSelf = self;
    [weakSelf.approvalpendingTSTableView.infiniteScrollingView stopAnimating];
    self.approvalpendingTSTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 37);
    [self handlePendingApprovalsDataReceivedAction];
}

- (void)checkToShowMoreButton
{
    NSNumber *expenseSheetsCount = [[NSUserDefaults standardUserDefaults] objectForKey:@"pendingApprovalsExpDownloadCount"];
    NSNumber *fetchCount = [[AppProperties getInstance] getAppPropertyFor:@"approvalsDownloadCount"];

    self.approvalpendingTSTableView.showsInfiniteScrolling = [expenseSheetsCount intValue] >= [fetchCount intValue];
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
        [self.selectedSheetsIDsArr addObject:[userDict objectForKey:@"expenseSheetUri"]];
    }
    else
    {
        [self.selectedSheetsIDsArr removeObject:[userDict objectForKey:@"expenseSheetUri"]];
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
                                                message:RPLocalizedString(APPROVAL_EXPENSESHEET_VALIDATION_MSG, @"")
                                                  title:nil
                                                    tag:0];


        return;
    }
    else
    {
        NSArray *allDetailsArray = [self.loginModel getAllUserDetailsInfoFromDb];
        BOOL isCommentsRequiredForApproval = [[allDetailsArray.firstObject objectForKey:@"areExpenseRejectCommentsRequired"] boolValue];
        if (isCommentsRequiredForApproval) {
            ApprovalCommentsController *approvalCommentsController = [self.injector getInstance:[ApprovalCommentsController class]];
            [approvalCommentsController setUpApprovalActionType:RejectActionType delegate:self commentsRequired:isCommentsRequiredForApproval];
            [self.navigationController pushViewController:approvalCommentsController animated:YES];
        }
        else
        {
            CLS_LOG(@"-----Reject action on ApprovalsPendingExpenseViewController -----");
            [self resetView:NO];
            [commentsTextView resignFirstResponder];
            id comments = self.commentsTextView.text;
            if (comments == nil || [comments isKindOfClass:[NSNull class]])
            {
                comments = [NSNull null];
            }
            [self rejectExpenseSheetsWithComments:comments];

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
                                                message:RPLocalizedString(APPROVAL_EXPENSESHEET_VALIDATION_MSG, @"")
                                                  title:nil
                                                    tag:0];


        return;
    }
    else
    {
        CLS_LOG(@"-----Approve action on ApprovalsPendingExpenseViewController -----");
        [self resetView:NO];
        [commentsTextView resignFirstResponder];
        id comments = self.commentsTextView.text;
        if (comments == nil || [comments isKindOfClass:[NSNull class]])
        {
            comments = [NSNull null];
        }
        [self approveExpenseSheetsWithComments:comments];
    }
}

#pragma mark NetworkMonitor

- (void)networkActivated
{
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
                [self.selectedSheetsIDsArr addObject:[userDict objectForKey:@"expenseSheetUri"]];
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
                [self.selectedSheetsIDsArr removeObject:[userDict objectForKey:@"expenseSheetUri"]];
            }
        }
        [self.listOfUsersArr replaceObjectAtIndex:i withObject:sectionedUsersArr];
    }

    self.totalRowsCount = 0;
    [self.selectedSheetsIDsArr removeAllObjects];
    [self.approvalpendingTSTableView reloadData];
}

#pragma mark - <ApprovalCommentsControllerDelegate>

-(void)approvalsCommentsControllerDidRequestApproveAction:(ApprovalCommentsController *)approvalCommentsController withComments:(NSString *)comments
{
    [self approveExpenseSheetsWithComments:comments];
}
-(void)approvalsCommentsControllerDidRequestRejectAction:(ApprovalCommentsController *)approvalCommentsController withComments:(NSString *)comments
{
    [self rejectExpenseSheetsWithComments:comments];
}


#pragma mark Private

-(void)rejectExpenseSheetsWithComments:(NSString *)comments
{
    [self.spinnerDelegate showTransparentLoadingOverlay];
    [self.approvalsService sendRequestToRejectExpenseSheetsWithURI:self.selectedSheetsIDsArr
                                                      withComments:comments
                                                       andDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APPROVAL_REJECT_DONE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(approve_reject_Completed)
                                                 name:APPROVAL_REJECT_DONE_NOTIFICATION
                                               object:nil];
    [self.navigationController popToViewController:self animated:YES];
}

-(void)approveExpenseSheetsWithComments:(NSString *)comments
{
    [self.spinnerDelegate showTransparentLoadingOverlay];
    [self.approvalsService sendRequestToApproveExpenseSheetsWithURI:self.selectedSheetsIDsArr
                                                       withComments:comments
                                                        andDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APPROVAL_REJECT_DONE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(approve_reject_Completed)
                                                 name:APPROVAL_REJECT_DONE_NOTIFICATION
                                               object:nil];
    [self.navigationController popToViewController:self animated:YES];
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
