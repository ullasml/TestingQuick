//
//  ApprovalsTimesheetHistoryViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 21/01/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import "ApprovalsTimesheetHistoryViewController.h"
#import "Util.h"
#import "Constants.h"
#import "SVPullToRefresh.h"
#import "AppDelegate.h"
#import "ApprovalsModel.h"
#import "MinimalTimesheetDeserializer.h"
#import <repliconkit/ReachabilityMonitor.h>
#import "UserSession.h"
#import "ApproveTimesheetContainerController.h"
#import "InjectorProvider.h"
#import <Blindside/BSInjector.h>
#import "LegacyTimesheetApprovalInfo.h"
#import "ErrorBannerViewParentPresenterHelper.h"


@interface ApprovalsTimesheetHistoryViewController ()

@property (nonatomic) ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper;
@property (nonatomic) MinimalTimesheetDeserializer *minimalTimesheetDeserializer;
@property (nonatomic) UserPermissionsStorage *userPermissionsStorage;
@property (nonatomic, weak) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic) NSNotificationCenter *notificationCenter;
@property (nonatomic) ReachabilityMonitor *reachabilityMonitor;
@property (nonatomic) ApprovalsService *approvalsService;
@property (nonatomic) ApprovalsModel *approvalsModel;
@property (nonatomic) id<UserSession> userSession;
@property (nonatomic) LoginModel *loginModel;


@property (nonatomic, weak) id<BSInjector> injector;


@end


@implementation ApprovalsTimesheetHistoryViewController
@synthesize approvalHistoryTableView;
@synthesize historyArr;
@synthesize cell;
@synthesize msgLabel;
@synthesize scrollViewController;
@synthesize selectedIndexPath;

#define Each_Cell_Row_Height_58 58
#define HeightOFMsgLabel 80

- (instancetype)initWithErrorBannerViewParentPresenterHelper:(ErrorBannerViewParentPresenterHelper *)errorBannerViewParentPresenterHelper
                                minimalTimesheetDeserializer:(MinimalTimesheetDeserializer *)minimalTimesheetDeserializer
                                      userPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                                         reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                                          notificationCenter:(NSNotificationCenter *)notificationCenter
                                            approvalsService:(ApprovalsService *)approvalsService
                                             spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                                              approvalsModel:(ApprovalsModel *)approvalsModel
                                                 userSession:(id <UserSession>)userSession
                                                  loginModel:(LoginModel *)loginModel {
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
        self.userSession = userSession;
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
     [Util setToolbarLabel:self withText:RPLocalizedString(PREVIOUS_APPROVALS_TIMESHEETS, PREVIOUS_APPROVALS_TIMESHEETS)];
	//[self.navigationController.navigationBar setTintColor:RepliconStandardNavBarTintColor];

    [self createHistoryList];

    if (self.approvalHistoryTableView==nil) {
        self.approvalHistoryTableView = [self setupTableView];
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

-(UITableView *)setupTableView
{
    return [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [self heightForTableView]) style:UITableViewStylePlain];
}

-(void)createHistoryList{

    historyArr=[[NSMutableArray alloc]init];
    self.historyArr=[self.approvalsModel getAllPreviousTimesheetsOfApprovalFromDB ];
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
    ApprovalsTimesheetHistoryViewController *weakSelf = self;


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


    if ([self.reachabilityMonitor isNetworkReachable] == NO)
    {
        [self.view setUserInteractionEnabled:YES];
        self.approvalHistoryTableView.showsInfiniteScrolling=TRUE;
        ApprovalsTimesheetHistoryViewController *weakSelf = self;
        [weakSelf.approvalHistoryTableView.pullToRefreshView stopAnimating];
        [Util showOfflineAlert];
        return;
    }
    [self.notificationCenter removeObserver:self name:PENDING_APPROVALS_TIMESHEET_NOTIFICATION object:nil];
    [self.notificationCenter addObserver:self selector:@selector(refreshViewFromPullToRefreshedData)
                                                 name:PENDING_APPROVALS_TIMESHEET_NOTIFICATION
                                               object:nil];
    [[RepliconServiceManager approvalsService]fetchSummaryOfPreviousTimeSheetApprovalsForUser:self];

}
-(void)refreshActionForUriNotFoundError

{

    if ([self.reachabilityMonitor isNetworkReachable] == NO)

    {

        [Util showOfflineAlert];

        return;

    }

    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];

    CLS_LOG(@"-----Check for update action triggered on ApprovalsTimesheetHistoryViewController-----");

    [self.notificationCenter addObserver:self selector:@selector(refreshViewFromPullToRefreshedData)

                                                 name:PENDING_APPROVALS_TIMESHEET_NOTIFICATION

                                               object:nil];

    [[RepliconServiceManager approvalsService]fetchSummaryOfPreviousTimeSheetApprovalsForUser:self];
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
    [self.notificationCenter removeObserver:self name:PENDING_APPROVALS_TIMESHEET_NOTIFICATION object:nil];
    [self.view setUserInteractionEnabled:YES];
    self.approvalHistoryTableView.showsInfiniteScrolling=TRUE;
    ApprovalsTimesheetHistoryViewController *weakSelf = self;
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
    if ([self.reachabilityMonitor isNetworkReachable] == NO)
    {
        [self.view setUserInteractionEnabled:YES];
        ApprovalsTimesheetHistoryViewController *weakSelf = self;
        [weakSelf.approvalHistoryTableView.infiniteScrollingView stopAnimating];
        self.approvalHistoryTableView.showsInfiniteScrolling=FALSE;
        [Util showOfflineAlert];
        return;
    }
    [self.notificationCenter removeObserver:self name:PENDING_APPROVALS_TIMESHEET_NOTIFICATION object:nil];
    [self.notificationCenter addObserver:self selector:@selector(reloadViewAfterMoreDataFetchForPreviousTimesheets)
                                                 name:PENDING_APPROVALS_TIMESHEET_NOTIFICATION
                                               object:nil];
    [[RepliconServiceManager approvalsService]fetchSummaryOfNextPreviousTimeSheetApprovalsForUser:self];
}
/************************************************************************************************************
 @Function Name   : reloadViewAfterMoreDataFetchForPreviousTimesheets
 @Purpose         : To reload tableview everytime when more records is made
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)reloadViewAfterMoreDataFetchForPreviousTimesheets
{
    [self.notificationCenter removeObserver:self name:PENDING_APPROVALS_TIMESHEET_NOTIFICATION object:nil];
    ApprovalsTimesheetHistoryViewController *weakSelf = self;
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

    NSNumber *timeSheetsCount =	[[NSUserDefaults standardUserDefaults]objectForKey:@"PreviousApprovalsTSDownloadCount"];
    NSNumber *fetchCount  =    [[AppProperties getInstance] getAppPropertyFor:@"approvalsDownloadCount"];

    if (([timeSheetsCount intValue]<[fetchCount intValue]))
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
    [self.notificationCenter removeObserver: self name: PENDING_APPROVALS_TIMESHEET_NOTIFICATION object: nil];
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
    [tableViewcell setBackgroundColor:RepliconStandardBackgroundColor];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return Each_Cell_Row_Height_58;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [self.historyArr count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	static NSString *CellIdentifier = @"PendingApprovalsCellIdentifier";

	cell = (ApprovalsPendingCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        cell = [[ApprovalsPendingCustomCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.contentView.backgroundColor = [Util colorWithHex:@"#f8f8f8" alpha:1];

	}
	NSString		*leftStr =@"";
	NSString		*rightStr = @"";
    NSString        *leftLowerStr=@"";


    NSMutableDictionary *userDict=[self.historyArr objectAtIndex:indexPath.row];
    leftStr   = [userDict objectForKey:@"username"];

    if ([userDict objectForKey:@"totalDurationDecimal"]!=nil && ![[userDict objectForKey:@"totalDurationDecimal"] isKindOfClass:[NSNull class]])
    {
         rightStr   = [Util getRoundedValueFromDecimalPlaces:[[userDict objectForKey:@"totalDurationDecimal"]newDoubleValue]withDecimalPlaces:2];
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

    NSString *overTime=@"";
     NSString *timeOff=@"";
     NSString *regular=@"";
    NSString *projectHours = @"";
    
    if ([userDict objectForKey:@"overtimeDurationDecimal"]!=nil && ![[userDict objectForKey:@"overtimeDurationDecimal"] isKindOfClass:[NSNull class]])
    {
        overTime=[Util getRoundedValueFromDecimalPlaces:[[userDict objectForKey:@"overtimeDurationDecimal"]newDoubleValue]withDecimalPlaces:2];
    }


    NSString *meal=[NSString stringWithFormat:@"%@",[userDict objectForKey:@"mealBreakPenalties"]];

    if ([userDict objectForKey:@"timeoffDurationDecimal"]!=nil && ![[userDict objectForKey:@"timeoffDurationDecimal"] isKindOfClass:[NSNull class]])
    {
        timeOff=[Util getRoundedValueFromDecimalPlaces:[[userDict objectForKey:@"timeoffDurationDecimal"]newDoubleValue]withDecimalPlaces:2];
    }

    if ([userDict objectForKey:@"regularDurationDecimal"]!=nil && ![[userDict objectForKey:@"regularDurationDecimal"] isKindOfClass:[NSNull class]])
    {
        regular=[Util getRoundedValueFromDecimalPlaces:[[userDict objectForKey:@"regularDurationDecimal"]newDoubleValue]withDecimalPlaces:2];
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



    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];


    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

	return cell;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    CLS_LOG(@"-----Row selected on ApprovalsTimesheetHistoryViewController -----");

    self.selectedIndexPath=indexPath;

    [self createHistoryList];

    NSMutableDictionary *userDict=[self.historyArr objectAtIndex:indexPath.row];
    NSString *timesheetURI=[userDict objectForKey:@"timesheetUri"];


	NSArray *dbTimesheetArray = [self.approvalsModel getAllPreviousTimesheetDaySummaryFromDBForTimesheet:timesheetURI];


    [self.spinnerDelegate hideTransparentLoadingOverlay];
    [self.notificationCenter removeObserver:self
                                       name:APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION
                                     object:nil];


    NSArray *dbTimesheetInfoArray=[self.approvalsModel getTimeSheetInfoSheetIdentityForPrevious:timesheetURI];
    BOOL isWidgetTimesheet=NO;
    if ([dbTimesheetInfoArray count]>0) {
        NSArray *enabledWidgetsUriArray=[self.approvalsModel getAllSupportedAndNotSupportedPreviousWidgetsForTimesheetUri:timesheetURI];
        if (enabledWidgetsUriArray.count>0)
        {
            isWidgetTimesheet=TRUE;
        }
    }



    id<Timesheet> timesheet = [self.minimalTimesheetDeserializer deserialize:userDict];
    ApproveTimesheetContainerController *nextViewController = [self.injector getInstance:[ApproveTimesheetContainerController class]];
    NSString *title = userDict[@"username"];
    LegacyTimesheetApprovalInfo *info = [[LegacyTimesheetApprovalInfo alloc]
                                         initWithAllApprovalsTimesheetsArray:self.historyArr
                                                    isWidgetTimesheet:isWidgetTimesheet
                                                    dbTimesheetArray:dbTimesheetArray
                                                                        countOfUsers:0
                                                                         indexCount:indexPath.row
                                                                        delegate:self
                                                     isFromPendingApprovals:NO
                                                     isFromPreviousApprovals:YES];

    [nextViewController setupWithLegacyTimesheetApprovalInfo:info timesheet:timesheet delegate:(id)self title:title andUserUri:userDict[@"userUri"]];

    [self.navigationController pushViewController:nextViewController animated:YES];



    [self.approvalHistoryTableView deselectRowAtIndexPath:indexPath animated:NO];

}

-(void)timesheetSummaryReceived:(NSNotification*)notification
{
    [self.notificationCenter removeObserver:self name:APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION object:nil];
    [self navigateToCurrentTimesheetViewController];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    ApprovalsScrollViewController *ctrl=(ApprovalsScrollViewController *)self.scrollViewController;
    NSDictionary *notificationObj=[notification userInfo];
    if (notificationObj!=nil && ![notificationObj isKindOfClass:[NSNull class]])
    {
        if ([notificationObj objectForKey:@"approvalDetails"]!=nil && ![[notificationObj objectForKey:@"approvalDetails"] isKindOfClass:[NSNull class]])
        {
            NSString *timesheetUri=[[[notificationObj objectForKey:@"approvalDetails"] objectForKey:@"timesheet"] objectForKey:@"uri"];

            NSArray *dbTimesheetInfoArray=[self.approvalsModel getTimeSheetInfoSheetIdentityForPrevious:timesheetUri];
            if ([dbTimesheetInfoArray count]>0) {
                NSArray *enabledWidgetsUriArray=[self.approvalsModel getAllSupportedAndNotSupportedPreviousWidgetsForTimesheetUri:timesheetUri];
                if (enabledWidgetsUriArray.count>0)
                {
                    ctrl.isGen4User=TRUE;
                }
            }
        }


    }


    [ctrl viewAllEntriesScreen:nil];
}
-(void)showMessageLabel
{


    [self.msgLabel removeFromSuperview];
    UILabel *tempMsgLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, HeightOFMsgLabel)];
    tempMsgLabel.text=RPLocalizedString(APPROVAL_NO_TIMESHEETS_HISTORY_VALIDATION, APPROVAL_NO_TIMESHEETS_HISTORY_VALIDATION);
    self.msgLabel=tempMsgLabel;
    self.msgLabel.backgroundColor=[UIColor clearColor];
    self.msgLabel.numberOfLines=2;
    self.msgLabel.textAlignment=NSTextAlignmentCenter;
    self.msgLabel.font=[UIFont fontWithName:RepliconFontFamily size:16];

    [self.view addSubview:self.msgLabel];
}

-(void)navigateToCurrentTimesheetViewController
{
    [self.approvalHistoryTableView deselectRowAtIndexPath:self.selectedIndexPath animated:YES];
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    [self.notificationCenter removeObserver:self name:APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION object:nil];
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
