#import "ApprovalsTimeOffHistoryViewController.h"

#import "Util.h"
#import "Constants.h"
#import "SVPullToRefresh.h"
#import "AppDelegate.h"
#import "ApprovalsModel.h"
#import "ApprovalsScrollViewController.h"
#import "ErrorBannerViewParentPresenterHelper.h"


@interface ApprovalsTimeOffHistoryViewController ()

@property (nonatomic) NSNotificationCenter                  *notificationCenter;
@property (nonatomic) ApprovalsService                      *approvalsService;
@property (nonatomic) LoginModel                            *loginModel;
@property (nonatomic) id<SpinnerDelegate>                   spinnerDelegate;
@property (nonatomic) id<BSInjector>                        injector;
@property (nonatomic) ApprovalsModel                        *approvalsModel;
@property (nonatomic) ErrorBannerViewParentPresenterHelper  *errorBannerViewParentPresenterHelper;

@end

@implementation ApprovalsTimeOffHistoryViewController
@synthesize approvalHistoryTableView;
@synthesize historyArr;
@synthesize cell;
@synthesize msgLabel;
@synthesize selectedIndexPath;
@synthesize scrollViewController;

#define Each_Cell_Row_Height_58 58
#define HeightOFMsgLabel 80

- (instancetype)initWithErrorBannerViewParentPresenterHelper:(ErrorBannerViewParentPresenterHelper *)errorBannerViewParentPresenterHelper
                                          notificationCenter:(NSNotificationCenter *)notificationCenter
                                             spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                                            approvalsService:(ApprovalsService *)approvalsService
                                              approvalsModel:(ApprovalsModel *)approvalsModel
                                                  loginModel:(LoginModel *)loginModel {
    self = [super init];
    if (self)
    {
        self.errorBannerViewParentPresenterHelper = errorBannerViewParentPresenterHelper;
        self.notificationCenter = notificationCenter;
        self.approvalsService = approvalsService;
        self.spinnerDelegate = spinnerDelegate;
        self.approvalsModel = approvalsModel;
        self.loginModel = loginModel;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;

    [self.view setBackgroundColor:[Util colorWithHex:@"#f8f8f8" alpha:1]];



    [Util setToolbarLabel:self withText:RPLocalizedString(PREVIOUS_APPROVALS_TIMEOFFS, PREVIOUS_APPROVALS_TIMEOFFS)];


	//[self.navigationController.navigationBar setTintColor:RepliconStandardNavBarTintColor];

    [self createHistoryList];



    if (approvalHistoryTableView==nil) {
        UITableView *tempTimeOffsTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [self heightForTableView]) style:UITableViewStylePlain];
        self.approvalHistoryTableView=tempTimeOffsTableView;
        self.approvalHistoryTableView.separatorColor=[UIColor clearColor];

    }

    self.approvalHistoryTableView.delegate=self;
    self.approvalHistoryTableView.dataSource=self;
    [self.view addSubview:approvalHistoryTableView];





    UIView *bckView = [UIView new];
	[bckView setBackgroundColor:RepliconStandardBackgroundColor];
	[self.approvalHistoryTableView setBackgroundView:bckView];

    [self configureTableForPullToRefresh];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self changeTableViewInset];
}

- (void)changeTableViewInset
{
    [self.errorBannerViewParentPresenterHelper setTableViewInsetWithErrorBannerPresentation:self.approvalHistoryTableView];
}

-(void)createHistoryList{

    ApprovalsModel *approval = [[ApprovalsModel alloc]init];
    historyArr=[[NSMutableArray alloc]init];
    self.historyArr=[approval getAllPreviousTimeOffsOfApprovalFromDB ];



}

#pragma mark -
#pragma mark Other Methods

/************************************************************************************************************
 @Function Name   : configureTableForPullToRefresh
 @Purpose         : To extend tableview to add pull to refresh and infinite scrolling view
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)configureTableForPullToRefresh
{
    ApprovalsTimeOffHistoryViewController *weakSelf = self;


    //setup pull to refresh widget
    [self.approvalHistoryTableView addPullToRefreshWithActionHandler:^{

        int64_t delayInSeconds = 0.0;
        [weakSelf.approvalHistoryTableView.pullToRefreshView startAnimating];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {

                           [weakSelf refreshAction];


                       });
    }];

    // setup infinite scrolling
    [self.approvalHistoryTableView addInfiniteScrollingWithActionHandler:^{


        int64_t delayInSeconds = 0.0;
        [weakSelf.approvalHistoryTableView.infiniteScrollingView startAnimating];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {

                           [weakSelf moreAction];



                       });
    }];

}

/************************************************************************************************************
 @Function Name   : refreshAction
 @Purpose         : To fetch refreshed data of pending approvals timesheets
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)refreshAction
{


    if(![NetworkMonitor isNetworkAvailableForListener: self])
    {
        [self.view setUserInteractionEnabled:YES];
        self.approvalHistoryTableView.showsInfiniteScrolling=TRUE;
        ApprovalsTimeOffHistoryViewController *weakSelf = self;
        [weakSelf.approvalHistoryTableView.pullToRefreshView stopAnimating];
        [Util showOfflineAlert];
        return;
    }
    [self.notificationCenter removeObserver:self name:PENDING_APPROVALS_TIMEOFF_NOTIFICATION object:nil];
    [self.notificationCenter addObserver:self selector:@selector(refreshViewFromPullToRefreshedData)
                                                 name:PENDING_APPROVALS_TIMEOFF_NOTIFICATION
                                               object:nil];
    [[RepliconServiceManager approvalsService]fetchSummaryOfPreviousTimeOffsApprovalsForUser:self];

}
-(void)refreshActionForUriNotFoundError

{

    if(![NetworkMonitor isNetworkAvailableForListener: self])

    {

        [Util showOfflineAlert];

        return;

    }

    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];

    CLS_LOG(@"-----Check for update action triggered on ApprovalsTimeOffHistoryViewController-----");

    [self.notificationCenter addObserver:self selector:@selector(refreshViewFromPullToRefreshedData)

                                                 name:PENDING_APPROVALS_TIMEOFF_NOTIFICATION

                                               object:nil];

    [[RepliconServiceManager approvalsService]fetchSummaryOfPreviousTimeOffsApprovalsForUser:self];
}
/************************************************************************************************************
 @Function Name   : refreshViewFromPullToRefreshedData
 @Purpose         : To reload tableview everytime when pull to refresh action is made
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)refreshViewFromPullToRefreshedData
{
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    [self.notificationCenter removeObserver:self name:PENDING_APPROVALS_TIMEOFF_NOTIFICATION object:nil];
    [self.view setUserInteractionEnabled:YES];
    self.approvalHistoryTableView.showsInfiniteScrolling=TRUE;
    ApprovalsTimeOffHistoryViewController *weakSelf = self;
    [weakSelf.approvalHistoryTableView.pullToRefreshView stopAnimating];
    [self handlePreviousApprovalsDataReceivedAction];


    if ([self.historyArr count]==0)
    {
        [self showMessageLabel];
        //[self.approvalHistoryTableView setScrollEnabled:FALSE];
    }


}

/************************************************************************************************************
 @Function Name   : moreAction
 @Purpose         : To fetch more data of pending approvals timesheets
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)moreAction
{
    if(![NetworkMonitor isNetworkAvailableForListener: self])
    {
        [self.view setUserInteractionEnabled:YES];
        ApprovalsTimeOffHistoryViewController *weakSelf = self;
        [weakSelf.approvalHistoryTableView.infiniteScrollingView stopAnimating];
        self.approvalHistoryTableView.showsInfiniteScrolling=FALSE;
        [Util showOfflineAlert];
        return;
    }
    [self.notificationCenter removeObserver:self name:PENDING_APPROVALS_TIMEOFF_NOTIFICATION object:nil];
    [self.notificationCenter addObserver:self selector:@selector(reloadViewAfterMoreDataFetchForPreviousTimeOffs)
                                                 name:PENDING_APPROVALS_TIMEOFF_NOTIFICATION
                                               object:nil];
    [[RepliconServiceManager approvalsService]fetchSummaryOfNextPreviousTimeOffsApprovalsForUser:self];
}
/************************************************************************************************************
 @Function Name   : reloadViewAfterMoreDataFetchForPreviousTimesheets
 @Purpose         : To reload tableview everytime when more records is made
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)reloadViewAfterMoreDataFetchForPreviousTimeOffs
{
    [self.notificationCenter removeObserver:self name:PENDING_APPROVALS_TIMEOFF_NOTIFICATION object:nil];
    ApprovalsTimeOffHistoryViewController *weakSelf = self;
    [weakSelf.approvalHistoryTableView.infiniteScrollingView stopAnimating];
    [self handlePreviousApprovalsDataReceivedAction];
}

/************************************************************************************************************
 @Function Name   : checkToShowMoreButton
 @Purpose         : To check to enable more action or not everytime view appears
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)checkToShowMoreButton
{

    NSNumber *timeOffsCount =	[[NSUserDefaults standardUserDefaults]objectForKey:@"PreviousApprovalsTODownloadCount"];
    NSNumber *fetchCount  =    [[AppProperties getInstance] getAppPropertyFor:@"approvalsDownloadCount"];

    if (([timeOffsCount intValue]<[fetchCount intValue]))
    {
		self.approvalHistoryTableView.showsInfiniteScrolling=FALSE;
	}
    else
    {
        self.approvalHistoryTableView.showsInfiniteScrolling=TRUE;
    }
    [self changeTableViewInset];
}

-(void)handlePreviousApprovalsDataReceivedAction
{
    [self.notificationCenter removeObserver: self name: PENDING_APPROVALS_TIMEOFF_NOTIFICATION object: nil];
    [self.notificationCenter removeObserver:self name:PREVIOUS_APPROVALS_NOTIFICATION object:nil];
    [self createHistoryList];
    if ([self.historyArr count]==0)
    {
        [self showMessageLabel];
        //[self.approvalHistoryTableView setScrollEnabled:FALSE];
    }
    [self checkToShowMoreButton];
    [self.approvalHistoryTableView reloadData];

}
#pragma mark -
#pragma mark - UITableView Delegates
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)tableViewcell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableViewcell setBackgroundColor:[UIColor clearColor]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return Each_Cell_Row_Height_58;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [historyArr count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	static NSString *CellIdentifier = @"PendingApprovalsCellIdentifier";

	cell = (ApprovalsPendingCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        cell = [[ApprovalsPendingCustomCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.contentView.backgroundColor = [Util colorWithHex:@"#f8f8f8" alpha:1];

	}
	NSString		*leftStr =@"";

    NSString        *leftLowerStr=@"";


    NSMutableDictionary *userDict=[self.historyArr objectAtIndex:indexPath.row];


    leftStr   = [userDict objectForKey:@"username"];
    leftLowerStr=[userDict objectForKey:@"timeoffTypeName"];


    NSString *time=nil;

    //Implemented As Per US7524

    NSDate *startDate=[Util convertTimestampFromDBToDate:[userDict objectForKey:@"startDate"] ];
    NSDate *endDate=[Util convertTimestampFromDBToDate:[userDict objectForKey:@"endDate"] ];

    NSDateFormatter *temp = [[NSDateFormatter alloc] init];
    [temp setDateFormat:@"MMM dd"];

    NSLocale *locale = [NSLocale currentLocale];
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [temp setTimeZone:timeZone];
    [temp setLocale:locale];

    NSString *startDateStr = [temp stringFromDate:startDate];
    NSString *endDateStr = [temp stringFromDate:endDate];
    [temp setDateFormat:@"yyyy"];
    NSString *year = [temp stringFromDate:endDate];

    NSString *date = nil;
    [temp setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *stDt = [temp dateFromString:[temp stringFromDate:startDate]];
    NSDate *endDt =  [temp dateFromString:[temp stringFromDate:endDate]];

    if ((stDt!=nil && endDt!=nil) && [stDt compare:endDt]==NSOrderedSame)
    {
        date=[Util convertPickerDateToStringShortStyle:startDate];
    }
    else
        date =[NSString stringWithFormat:@"%@ - %@ , %@",startDateStr,endDateStr,year];

    
    NSString *timeOffDisplayFormatUri = userDict[@"timeOffDisplayFormatUri"];
    if ([timeOffDisplayFormatUri isEqualToString:TIME_Off_DISPLAY_WORK_DAYS_FORMAT_URI]) {
        if (fabs([[userDict objectForKey:@"totalTimeoffDays"] newDoubleValue]) != 1.00) {
            time=[NSString stringWithFormat:@"%@ %@", [Util getRoundedValueFromDecimalPlaces:[[userDict objectForKey:@"totalTimeoffDays"]newDoubleValue]withDecimalPlaces:2],RPLocalizedString(@"days", @"")];
        }
        else {
            time=[NSString stringWithFormat:@"%@ %@",[Util getRoundedValueFromDecimalPlaces:[[userDict objectForKey:@"totalTimeoffDays"]newDoubleValue]withDecimalPlaces:2],RPLocalizedString(@"day", @"")];
        }
    }
    else{
        if (fabs([[userDict objectForKey:@"totalDurationDecimal"] newDoubleValue]) != 1.00) {
            time=[NSString stringWithFormat:@"%@ %@",[Util getRoundedValueFromDecimalPlaces:[[userDict objectForKey:@"totalDurationDecimal"]newDoubleValue]withDecimalPlaces:2],RPLocalizedString(@"hours", @"")];
        }
        else {
            time=[NSString stringWithFormat:@"%@ %@",[Util getRoundedValueFromDecimalPlaces:[[userDict objectForKey:@"totalDurationDecimal"]newDoubleValue]withDecimalPlaces:2],RPLocalizedString(@"hour", @"")];
        }
    }



    [cell setDelegate:self];
    [cell setTableDelegate:self];

    [cell createCellLayoutWithParams:leftStr
                     leftLowerString:leftLowerStr
                            rightstr:time
                    rightLowerString:date
                      radioButtonTag:indexPath.row];



     [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];


    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];


	return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    CLS_LOG(@"-----Row selected on ApprovalsTimeOffHistoryViewController -----");
    self.selectedIndexPath=indexPath;
    NSMutableDictionary *userDict=[self.historyArr objectAtIndex:indexPath.row];
    NSString *timeoffUri=[userDict objectForKey:@"timeoffUri"];

    //Implemented Approvals Pending DrillDown Loading UI
    [self navigateToBookedTimeOffEntryViewController];

    [self.notificationCenter removeObserver:self name:APPROVALS_TIMEOFF_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [self.notificationCenter addObserver:self.scrollViewController selector:@selector(viewAllEntriesScreen:) name:APPROVALS_TIMEOFF_SUMMARY_RECIEVED_NOTIFICATION object:nil];

    ApprovalsModel *approvalsModel = [[ApprovalsModel alloc] init];
	NSArray *dbTimesheetArray = [approvalsModel getAllPreviousTimeoffFromDBForTimeoff:timeoffUri];

    if ([dbTimesheetArray count]==0)
    {
        if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
        {
            [Util showOfflineAlert];
            return;

        }
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
        [[RepliconServiceManager approvalsService]fetchApprovalPendingTimeoffEntryDataForBookedTimeoff:timeoffUri withDelegate:self];

    }
    else
    {
        [self.notificationCenter postNotificationName:APPROVALS_TIMEOFF_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    }

}

-(void)navigateToBookedTimeOffEntryViewController
{
    [self.approvalHistoryTableView deselectRowAtIndexPath:self.selectedIndexPath animated:YES];
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    [self.notificationCenter removeObserver:self name:APPROVALS_TIMEOFF_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    ApprovalsScrollViewController *tempscrollViewController =[[ApprovalsScrollViewController alloc]init];
    self.scrollViewController=tempscrollViewController;

    [self.scrollViewController setIndexCount:selectedIndexPath.row];
    [self.scrollViewController setListOfPendingItemsArray:self.historyArr];
    self.scrollViewController.currentViewIndex=0;
    NSString *approvalStatus=[[self.historyArr objectAtIndex:self.selectedIndexPath.row] objectForKey:@"approvalStatus"];
    self.scrollViewController.sheetStatus=approvalStatus;
    self.scrollViewController.delegate=self;
    self.scrollViewController.hasPreviousTimeSheets=FALSE;
    self.scrollViewController.hasPreviousTimeSheets=FALSE;
    [scrollViewController setHidesBottomBarWhenPushed:NO];
    [self.navigationController pushViewController:self.scrollViewController animated:YES];
}

-(void)showMessageLabel
{


    [self.msgLabel removeFromSuperview];
    UILabel *tempMsgLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, HeightOFMsgLabel)];
    tempMsgLabel.text=RPLocalizedString(APPROVAL_NO_TIMEOFFS_HISTORY_VALIDATION, APPROVAL_NO_TIMEOFFS_HISTORY_VALIDATION);
    self.msgLabel=tempMsgLabel;
    self.msgLabel.backgroundColor=[UIColor clearColor];
    self.msgLabel.numberOfLines=2;
    self.msgLabel.textAlignment=NSTextAlignmentCenter;
    self.msgLabel.font=[UIFont fontWithName:RepliconFontFamily size:16];

    [self.view addSubview:self.msgLabel];
}




#pragma mark NetworkMonitor

-(void) networkActivated {


}

#pragma mark -
#pragma mark Memory Manangement

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    self.approvalHistoryTableView.delegate=nil;
    self.approvalHistoryTableView.dataSource=nil;
}

#pragma mark - Frame math

- (CGFloat)heightForTableView
{
    return CGRectGetHeight([[UIScreen mainScreen] bounds]) -
    (CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) +
     CGRectGetHeight(self.navigationController.navigationBar.frame) +
     CGRectGetHeight(self.tabBarController.tabBar.frame));
}


@end
