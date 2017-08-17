//
//  ApprovalsExpenseHistoryViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta Rakshit on 4/8/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import "ApprovalsExpenseHistoryViewController.h"

#import "Util.h"
#import "Constants.h"
#import "SVPullToRefresh.h"
#import "AppDelegate.h"
#import "ApprovalsModel.h"
#import "ApprovalsScrollViewController.h"

@interface ApprovalsExpenseHistoryViewController ()

@property (nonatomic) NSNotificationCenter *notificationCenter;
@property (nonatomic) ApprovalsService *approvalsService;
@property (nonatomic) LoginModel *loginModel;
@property (nonatomic) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic) id<BSInjector> injector;
@property (nonatomic) ApprovalsModel *approvalsModel;


@end

@implementation ApprovalsExpenseHistoryViewController
@synthesize approvalHistoryTableView;
@synthesize historyArr;
@synthesize cell;
@synthesize msgLabel;
@synthesize selectedIndexPath;
@synthesize scrollViewController;

#define Each_Cell_Row_Height_58 58
#define HeightOFMsgLabel 80

- (instancetype)initWithNotificationCenter:(NSNotificationCenter *)notificationCenter
                           spinnerDelegate:(id<SpinnerDelegate>)spinnerDelegate
                          approvalsService:(ApprovalsService *)approvalsService
                            approvalsModel:(ApprovalsModel *)approvalsModel
                                loginModel:(LoginModel *)loginModel
{
    self = [super init];
    if (self)
    {
        self.notificationCenter = notificationCenter;
        self.approvalsService = approvalsService;
        self.loginModel = loginModel;
        self.spinnerDelegate = spinnerDelegate;
        self.approvalsModel = approvalsModel;
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



    [Util setToolbarLabel:self withText:RPLocalizedString(PREVIOUS_APPROVALS_EXPENSES, PREVIOUS_APPROVALS_EXPENSES)];


	//[self.navigationController.navigationBar setTintColor:RepliconStandardNavBarTintColor];

    [self createHistoryList];



    if (approvalHistoryTableView==nil) {
        UITableView *tempexpenseSheetsTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [self heightForTableView])  style:UITableViewStylePlain];
        self.approvalHistoryTableView=tempexpenseSheetsTableView;
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
-(void)createHistoryList{

    ApprovalsModel *approval = [[ApprovalsModel alloc]init];
    historyArr=[[NSMutableArray alloc]init];
    self.historyArr=[approval getAllPreviousExpensesheetsOfApprovalFromDB ];



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
    ApprovalsExpenseHistoryViewController *weakSelf = self;


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
        ApprovalsExpenseHistoryViewController *weakSelf = self;
        [weakSelf.approvalHistoryTableView.pullToRefreshView stopAnimating];
        [Util showOfflineAlert];
        return;
    }
    [self.notificationCenter removeObserver:self name:PENDING_APPROVALS_EXPENSE_NOTIFICATION object:nil];
    [self.notificationCenter addObserver:self selector:@selector(refreshViewFromPullToRefreshedData)
                                                 name:PENDING_APPROVALS_EXPENSE_NOTIFICATION
                                               object:nil];
    [[RepliconServiceManager approvalsService]fetchSummaryOfPreviousExpenseApprovalsForUser:self];

}
-(void)refreshActionForUriNotFoundError

{

    if(![NetworkMonitor isNetworkAvailableForListener: self])

    {

        [Util showOfflineAlert];

        return;

    }

    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];

    CLS_LOG(@"-----Check for update action triggered on ApprovalsExpenseHistoryViewController-----");

    [self.notificationCenter addObserver:self selector:@selector(refreshViewFromPullToRefreshedData)

                                                 name:PENDING_APPROVALS_EXPENSE_NOTIFICATION

                                               object:nil];

    [[RepliconServiceManager approvalsService]fetchSummaryOfPreviousExpenseApprovalsForUser:self];
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
    [self.notificationCenter removeObserver:self name:PENDING_APPROVALS_EXPENSE_NOTIFICATION object:nil];
    [self.view setUserInteractionEnabled:YES];
    self.approvalHistoryTableView.showsInfiniteScrolling=TRUE;
    ApprovalsExpenseHistoryViewController *weakSelf = self;
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
        ApprovalsExpenseHistoryViewController *weakSelf = self;
        [weakSelf.approvalHistoryTableView.infiniteScrollingView stopAnimating];
        self.approvalHistoryTableView.showsInfiniteScrolling=FALSE;
        [Util showOfflineAlert];
        return;
    }
    [self.notificationCenter removeObserver:self name:PENDING_APPROVALS_EXPENSE_NOTIFICATION object:nil];
    [self.notificationCenter addObserver:self selector:@selector(reloadViewAfterMoreDataFetchForPreviousExpensesheets)
                                                 name:PENDING_APPROVALS_EXPENSE_NOTIFICATION
                                               object:nil];
    [[RepliconServiceManager approvalsService]fetchSummaryOfNextPreviousExpenseApprovalsForUser:self];
}
/************************************************************************************************************
 @Function Name   : reloadViewAfterMoreDataFetchForPreviousTimesheets
 @Purpose         : To reload tableview everytime when more records is made
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)reloadViewAfterMoreDataFetchForPreviousExpensesheets
{
    [self.notificationCenter removeObserver:self name:PENDING_APPROVALS_EXPENSE_NOTIFICATION object:nil];
    ApprovalsExpenseHistoryViewController *weakSelf = self;
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

    NSNumber *expenseSheetsCount =	[[NSUserDefaults standardUserDefaults]objectForKey:@"PreviousApprovalsExpDownloadCount"];
    NSNumber *fetchCount  =    [[AppProperties getInstance] getAppPropertyFor:@"approvalsDownloadCount"];

    if (([expenseSheetsCount intValue]<[fetchCount intValue]))
    {
		self.approvalHistoryTableView.showsInfiniteScrolling=FALSE;
	}
    else
    {
        self.approvalHistoryTableView.showsInfiniteScrolling=TRUE;
    }


}

-(void)handlePreviousApprovalsDataReceivedAction
{
    [self.notificationCenter removeObserver: self name: PENDING_APPROVALS_EXPENSE_NOTIFICATION object: nil];
    [self.notificationCenter removeObserver:self name:PREVIOUS_APPROVALS_NOTIFICATION object:nil];
    [self createHistoryList];
    if ([self.historyArr count]==0)
    {
        [self showMessageLabel];
        //[self.approvalHistoryTableView setScrollEnabled:FALSE];
    }
    [self checkToShowMoreButton];
    [self.approvalHistoryTableView reloadData];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
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
	NSString		*rightStr = @"";
    NSString        *leftLowerStr=@"";
    NSString       *rightLowerStr=@"";

     NSMutableDictionary *userDict=[self.historyArr objectAtIndex:indexPath.row];


    leftStr   = [userDict objectForKey:@"username"];
    NSString *reimburseAmount   =[userDict objectForKey:@"reimbursementAmount"];
    NSString *reimburseCurrency =[userDict objectForKey:@"reimbursementAmountCurrencyName"];
    NSString *convertedReimburseAmount=nil;
    if (reimburseAmount!=nil && ![reimburseAmount isKindOfClass:[NSNull class]])
    {
        convertedReimburseAmount=[Util getRoundedValueFromDecimalPlaces:[reimburseAmount newDoubleValue] withDecimalPlaces:2];
    }

    NSString *reimburseAmountStr=[NSString stringWithFormat:@"%@ %@",reimburseCurrency,convertedReimburseAmount];
    rightStr=reimburseAmountStr;


    NSDate *expenseDate =[Util convertTimestampFromDBToDate:[[userDict objectForKey:@"expenseDate"] stringValue]];
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];

    NSLocale *locale=[NSLocale currentLocale];
    [myDateFormatter setLocale:locale];
    [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    myDateFormatter.dateFormat = @"MMM dd, yyyy";
    NSString *expenseDateStr =[myDateFormatter stringFromDate:expenseDate];


    leftLowerStr = expenseDateStr;

    rightLowerStr=[userDict objectForKey:@"description"];

    [cell setDelegate:self];
    [cell setTableDelegate:self];

    [cell createCellLayoutWithParams:leftStr
                     leftLowerString:leftLowerStr
                            rightstr:rightStr
                    rightLowerString:rightLowerStr
                      radioButtonTag:indexPath.row];



    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];


    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

	return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    CLS_LOG(@"-----Row selected on ApprovalsExpenseHistoryViewController -----");
    self.selectedIndexPath=indexPath;
    NSMutableDictionary *userDict=[self.historyArr objectAtIndex:indexPath.row];
    NSString *expenseSheetUri=[userDict objectForKey:@"expenseSheetUri"];


    //Implemented Approvals Pending DrillDown Loading UI
    [self navigateToListOfExpenseEntriesViewController];

    [self.notificationCenter removeObserver:self name:APPROVALS_EXPENSE_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [self.notificationCenter addObserver:self.scrollViewController selector:@selector(viewAllEntriesScreen:) name:APPROVALS_EXPENSE_SUMMARY_RECIEVED_NOTIFICATION object:nil];

    ApprovalsModel *approvalsModel = [[ApprovalsModel alloc] init];
	NSArray *dbTimesheetArray = [approvalsModel getAllPreviousExpenseExpenseEntriesFromDBForExpenseSheetUri:expenseSheetUri];

    if ([dbTimesheetArray count]==0)
    {
        if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
        {
            [Util showOfflineAlert];
            return;

        }
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
        [[RepliconServiceManager approvalsService]fetchApprovalPendingExpenseEntryDataForExpenseSheet:expenseSheetUri withDelegate:self];

    }
    else
    {
        [self.notificationCenter postNotificationName:APPROVALS_EXPENSE_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    }

}

-(void)navigateToListOfExpenseEntriesViewController
{
    [self.approvalHistoryTableView deselectRowAtIndexPath:self.selectedIndexPath animated:YES];
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    [self.notificationCenter removeObserver:self name:APPROVALS_EXPENSE_SUMMARY_RECIEVED_NOTIFICATION object:nil];
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
    tempMsgLabel.text=RPLocalizedString(APPROVAL_NO_EXPENSESHEETS_HISTORY_VALIDATION, APPROVAL_NO_EXPENSESHEETS_HISTORY_VALIDATION);
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
    self.approvalHistoryTableView.delegate = nil;
    self.approvalHistoryTableView.dataSource = nil;
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
