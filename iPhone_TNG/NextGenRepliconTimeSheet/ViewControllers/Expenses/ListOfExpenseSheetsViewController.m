#import "ListOfExpenseSheetsViewController.h"
#import "AppDelegate.h"
#import "SVPullToRefresh.h"
#import "ExpenseModel.h"
#import "ExpenseSheetObject.h"
#import "NewExpenseSheetViewController.h"
#import "ListOfExpenseEntriesViewController.h"
#import "ExpenseService.h"
#import "DefaultTableViewCellStylist.h"
#import "SearchTextFieldStylist.h"
#import <Blindside/BSInjector.h>



@interface ListOfExpenseSheetsViewController ()

@property (nonatomic) DefaultTableViewCellStylist *defaultTableViewCellStylist;
@property (nonatomic) SearchTextFieldStylist *searchTextFieldStylist;
@property (nonatomic) NSNotificationCenter *notificationCenter;
@property (nonatomic) ExpenseService *expenseService;
@property (nonatomic) NSUserDefaults *userDefaults;
@property (nonatomic) ExpenseModel *expenseModel;
@property (weak, nonatomic) id<BSInjector> injector;


@property (nonatomic, weak) id <SpinnerDelegate> spinnerDelegate;

@end


@implementation ListOfExpenseSheetsViewController
@synthesize expenseSheetsTableView;
@synthesize expenseSheetsArray;
@synthesize leftButton;
@synthesize rightBarButton;
@synthesize navcontroller;
@synthesize tempSheetsDBArray;
@synthesize msgLabel;
@synthesize isCalledFromMenu;
@synthesize isDeltaUpdate;

#define Each_Cell_Row_Height_58 58
#define HeightOfNoExpMsgLabel 80

- (instancetype) init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark -

- (id)initWithDefaultTableViewCellStylist:(DefaultTableViewCellStylist *)defaultTableViewCellStylist
                   searchTextFieldStylist:(SearchTextFieldStylist *)searchTextFieldStylist
                       notificationCenter:(NSNotificationCenter *)notificationCenter
                          spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                           expenseService:(ExpenseService *)expenseService
                             expenseModel:(ExpenseModel *)expenseModel
                             userDefaults:(NSUserDefaults *)userDefaults {
    self = [super initWithNibName:nil bundle:nil];
    if (self != nil)
    {
        if (self.expenseSheetsArray == nil) {
            self.defaultTableViewCellStylist = defaultTableViewCellStylist;
            self.searchTextFieldStylist = searchTextFieldStylist;
            self.notificationCenter = notificationCenter;
            self.spinnerDelegate = spinnerDelegate;
            self.expenseService = expenseService;
            self.expenseModel = expenseModel;
            self.userDefaults = userDefaults;

            self.expenseSheetsArray = [[NSMutableArray alloc] init];

            isDeltaUpdate=FALSE;
        }

    }
    return self;
}

#pragma mark View lifeCycle Methods


- (void)loadView
{
    [super loadView];
    [self.view setBackgroundColor:RepliconStandardBackgroundColor];
    [Util setToolbarLabel: self withText: RPLocalizedString(Expense_Sheets_title, Expense_Sheets_title)];

    if (expenseSheetsTableView==nil) {
        //Fix for ios7//JUHI
        float version= [[UIDevice currentDevice].systemVersion newFloatValue];
        float height=44.0;
        if (version>=7.0)
        {
            height=64.0;
        }
        CGFloat heightOfTabBar = CGRectGetHeight(self.tabBarController.tabBar.frame);

        UITableView *tempexpenseSheetsTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-height-heightOfTabBar) style:UITableViewStylePlain];
        self.expenseSheetsTableView=tempexpenseSheetsTableView;
        self.expenseSheetsTableView.separatorColor=[UIColor clearColor];

    }
    self.expenseSheetsTableView.delegate=self;
    self.expenseSheetsTableView.dataSource=self;
    [self.view addSubview:expenseSheetsTableView];
    UIView *bckView = [UIView new];
    [bckView setBackgroundColor:RepliconStandardBackgroundColor];
    [self.expenseSheetsTableView setBackgroundView:bckView];


    UIBarButtonItem *tempRightButtonOuterBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addExpenseSheetAction:)];

    self.rightBarButton=tempRightButtonOuterBtn;
    [self.navigationItem setRightBarButtonItem:self.rightBarButton animated:NO];


    [self configureTableForPullToRefresh];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.translucent = NO;

    NSArray *expenseArray=[self.expenseModel getAllExpenseSheetsFromDB];
    if ([expenseArray count]==0) {
        [self fetchExpenseSheets];
    }

    [self checkToShowMoreButton];
    [self displayAllExpenseSheets];
    [self.expenseSheetsTableView reloadData];
    [self showMessageLabel];

    [self.expenseSheetsTableView setContentOffset:currentContentOffset];


}

-(void)fetchExpenseSheets
{
    [self.notificationCenter addObserver: self
                                selector: @selector(handleAllExpenseSheetRequestsServed)
                                    name: AllExpenseSheetRequestsServed
                                  object: nil];
    [self.expenseService fetchExpenseSheetData:nil];
    [self.spinnerDelegate showTransparentLoadingOverlay];

}

- (void)handleAllExpenseSheetRequestsServed {
    [self.notificationCenter removeObserver:self name:AllExpenseSheetRequestsServed object:nil];
    [self.spinnerDelegate hideTransparentLoadingOverlay];

    [self checkToShowMoreButton];
    [self displayAllExpenseSheets];
    [self.expenseSheetsTableView reloadData];
    [self showMessageLabel];
}



- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEXT_RECENT_EXPENSESHEET_RECEIVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PULL_TO_REFRESH_EXPENSESHEET_NOTIFICATION object:nil];
    ListOfExpenseSheetsViewController *weakSelf = self;
    [weakSelf.expenseSheetsTableView.pullToRefreshView stopAnimating];
    [weakSelf.expenseSheetsTableView.infiniteScrollingView stopAnimating];
    [self.view setUserInteractionEnabled:YES];



}


#pragma mark -
#pragma mark - UITableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return Each_Cell_Row_Height_58;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [expenseSheetsArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TimeSheetCellIdentifier";
    cell = (ListOfExpenseSheetsCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
    {
        CGFloat width = CGRectGetWidth(self.view.frame);
        cell = [[ListOfExpenseSheetsCustomCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil width:width];
        cell.contentView.backgroundColor = [UIColor whiteColor];

    }
    if ([self.expenseSheetsArray count]>0)
    {

        NSString *approvalStatus    =[[expenseSheetsArray objectAtIndex:indexPath.row] expenseSheetApprovalStatus];
        NSString *description       =[[expenseSheetsArray objectAtIndex:indexPath.row] expenseSheetDescription];
        NSString *reimburseAmount   =[[expenseSheetsArray objectAtIndex:indexPath.row] expenseSheetReimbursementAmount];
        NSString *reimburseCurrency =[[expenseSheetsArray objectAtIndex:indexPath.row] expenseSheetReimbursementCurrencyName];

        NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];

        NSLocale *locale=[NSLocale currentLocale];
        [myDateFormatter setLocale:locale];
        [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        myDateFormatter.dateFormat = @"MMM dd yyyy";
        NSString *expenseDate =[myDateFormatter stringFromDate:[[expenseSheetsArray objectAtIndex:indexPath.row] expenseSheetDate]];

        NSString *convertedReimburseAmount=nil;
        if (reimburseAmount!=nil && ![reimburseAmount isKindOfClass:[NSNull class]])
        {
            convertedReimburseAmount=[Util getRoundedValueFromDecimalPlaces:[reimburseAmount newDoubleValue] withDecimalPlaces:2];
        }

        NSString *reimburseAmountStr=[NSString stringWithFormat:@"%@ %@",reimburseCurrency,convertedReimburseAmount];

        if (convertedReimburseAmount==nil || [convertedReimburseAmount isKindOfClass:[NSNull class]] || [convertedReimburseAmount isEqualToString:NULL_STRING] || [convertedReimburseAmount isEqualToString:NILL_STRING])
        {
            reimburseAmountStr=@"";
        }


        UIImage *statusImage=nil;
        if ([approvalStatus isEqualToString:NOT_SUBMITTED_STATUS])
        {
            statusImage=[Util thumbnailImage:Not_Submitted_Box];
        }
        else if ([approvalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS])
        {
            statusImage=[Util thumbnailImage:Waiting_for_Approval_Box];
        }
        else if ([approvalStatus isEqualToString:REJECTED_STATUS])
        {
            statusImage=[Util thumbnailImage:Rejected_Box];
        }
        else if ([approvalStatus isEqualToString:APPROVED_STATUS])
        {
            statusImage=[Util thumbnailImage:Approved_Box];
        }

        [cell createCellLayoutWithParams:description upperrightstr:reimburseAmountStr lowerrightStr:expenseDate lowerleftImage:statusImage approvalStatus:approvalStatus];


    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        return;
    }
    CLS_LOG(@"-----Row clicked on ListOfExpenseSheetsViewController -----");
    currentContentOffset=self.expenseSheetsTableView.contentOffset;

    ListOfExpenseEntriesViewController *listOfExpenseEntries = [self.injector getInstance:[ListOfExpenseEntriesViewController class]];
    listOfExpenseEntries.expenseSheetStatus=[[expenseSheetsArray objectAtIndex:indexPath.row] expenseSheetApprovalStatus];
    listOfExpenseEntries.parentDelegate=self;
    listOfExpenseEntries.expenseSheetTitle=[[expenseSheetsArray objectAtIndex:indexPath.row] expenseSheetDescription];
    listOfExpenseEntries.expenseSheetURI=[[expenseSheetsArray objectAtIndex:indexPath.row] expenseSheetURI];
    NSString *reimburseAmount   =[[expenseSheetsArray objectAtIndex:indexPath.row] expenseSheetReimbursementAmount];
    NSString *reimburseCurrency =[[expenseSheetsArray objectAtIndex:indexPath.row] expenseSheetReimbursementCurrencyName];
    NSString *reimburseCurrencyUri =[[expenseSheetsArray objectAtIndex:indexPath.row] expenseSheetReimbursementCurrencyURI];
    NSString *reimburseAmountStr=[NSString stringWithFormat:@"%@ %@",reimburseCurrency,reimburseAmount];
    listOfExpenseEntries.reimburseAmountString=reimburseAmountStr;
    NSString *incurredAmount   =[[expenseSheetsArray objectAtIndex:indexPath.row] expenseSheetIncurredAmount];
    NSString *incurredCurrency =[[expenseSheetsArray objectAtIndex:indexPath.row] expenseSheetIncurredCurrencyName];
    NSString *incurredAmountStr=[NSString stringWithFormat:@"%@ %@",incurredCurrency,incurredAmount];
    listOfExpenseEntries.totalIncurredAmountString=incurredAmountStr;

    listOfExpenseEntries.reimbursementCurrencyName=reimburseCurrency;
    listOfExpenseEntries.reimbursementCurrencyURI =reimburseCurrencyUri;

    [[NSNotificationCenter defaultCenter] removeObserver:listOfExpenseEntries name:EXPENSESHEET_ENTRY_RECIEVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:listOfExpenseEntries selector:@selector(RecievedData) name:EXPENSESHEET_ENTRY_RECIEVED_NOTIFICATION object:nil];
    [self.navigationController pushViewController:listOfExpenseEntries animated:YES];

    NSString *expenseSheetURI=[[expenseSheetsArray objectAtIndex:indexPath.row] expenseSheetURI];
    ExpenseModel *expenseModel = [[ExpenseModel alloc] init];
    NSArray *dbTimesheetArray = [expenseModel getAllExpenseExpenseEntriesFromDBForExpenseSheetUri:expenseSheetURI];

    if ([dbTimesheetArray count]==0)
    {
        AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
        [[RepliconServiceManager expenseService]fetchExpenseEntryDataForExpenseSheet:expenseSheetURI withDelegate:self];

    }
    else
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:EXPENSESHEET_ENTRY_RECIEVED_NOTIFICATION object:nil];
    }



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
    ListOfExpenseSheetsViewController *weakSelf = self;


    //setup pull to refresh widget
    [self.expenseSheetsTableView addPullToRefreshWithActionHandler:^{
        [weakSelf.view setUserInteractionEnabled:NO];
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {


                           [weakSelf.expenseSheetsTableView.pullToRefreshView startAnimating];

                           [weakSelf refreshAction];

                       });
    }];

    // setup infinite scrolling
    [self.expenseSheetsTableView addInfiniteScrollingWithActionHandler:^{

        [weakSelf.view setUserInteractionEnabled:YES];
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {

                           [weakSelf.expenseSheetsTableView.infiniteScrollingView startAnimating];
                           [weakSelf moreAction];


                       });
    }];

}

/************************************************************************************************************
 @Function Name   : displayAllExpenseSheets
 @Purpose         : To create timesheet objects from the list of timesheets array from DB
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
-(void)displayAllExpenseSheets
{
    if ([expenseSheetsArray count] > 0) {
        [expenseSheetsArray removeAllObjects];
    }

    NSMutableArray *dbexpenseSheetsArray =[[NSMutableArray alloc] init];
    self.tempSheetsDBArray=dbexpenseSheetsArray;


    self.tempSheetsDBArray=[self.expenseModel getAllExpenseSheetsFromDB];
    for (int i=0; i<[tempSheetsDBArray count]; i++)
    {
        NSDictionary *expenseDict=[tempSheetsDBArray objectAtIndex:i];
        ExpenseSheetObject *expenseObj   = [[ExpenseSheetObject alloc] init];
        expenseObj.expenseSheetApprovalStatus=[expenseDict objectForKey:@"approvalStatus"];
        expenseObj.expenseSheetDescription=[expenseDict objectForKey:@"description"];
        expenseObj.expenseSheetURI=[expenseDict objectForKey:@"expenseSheetUri"];
        expenseObj.expenseSheetReimbursementAmount=[expenseDict objectForKey:@"reimbursementAmount"];
        expenseObj.expenseSheetReimbursementCurrencyName=[expenseDict objectForKey:@"reimbursementAmountCurrencyName"];
        expenseObj.expenseSheetReimbursementCurrencyURI=[expenseDict objectForKey:@"reimbursementAmountCurrencyUri"];
        expenseObj.expenseSheetIncurredAmount=[expenseDict objectForKey:@"incurredAmount"];
        expenseObj.expenseSheetIncurredCurrencyName=[expenseDict objectForKey:@"incurredAmountCurrencyName"];
        expenseObj.expenseSheetIncurredCurrencyURI=[expenseDict objectForKey:@"incurredAmountCurrencyUri"];
        expenseObj.expenseSheetDate=[Util convertTimestampFromDBToDate:[[expenseDict objectForKey:@"expenseDate"] stringValue]];

        [self.expenseSheetsArray addObject:expenseObj];


    }



}


-(void)goBack:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEXT_RECENT_EXPENSESHEET_RECEIVED_NOTIFICATION object:nil];
    [[[UIApplication sharedApplication]delegate]performSelector:@selector(flipToHomeViewController)];
}

/************************************************************************************************************
 @Function Name   : moreAction
 @Purpose         : To fetch more records of timesheet when tableview is scrolled to bottom
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)moreAction
{
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {


        [Util showOfflineAlert];
        [self performSelector:@selector(refreshTableViewOnConnectionError) withObject:nil afterDelay:0.2];

    }
    else{
        CLS_LOG(@"-----More action triggered on ListOfExpenseSheetsViewController-----");
        [[RepliconServiceManager expenseService]fetchNextExpenseSheetData:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animateTableRowsAfterMoreAction:)
                                                     name:NEXT_RECENT_EXPENSESHEET_RECEIVED_NOTIFICATION
                                                   object:nil];

    }

}


-(void)refreshTableViewOnConnectionError
{
    ListOfExpenseSheetsViewController *weakSelf = self;
    [weakSelf.expenseSheetsTableView.infiniteScrollingView stopAnimating];

    self.expenseSheetsTableView.showsInfiniteScrolling=FALSE;
    self.expenseSheetsTableView.showsInfiniteScrolling=TRUE;



}

/************************************************************************************************************
 @Function Name   : refreshAction
 @Purpose         : To fetch modified records of timesheet when tableview is pulled to refresh
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)refreshAction
{
    if(![NetworkMonitor isNetworkAvailableForListener: self])
    {
        [self.view setUserInteractionEnabled:YES];
        ListOfExpenseSheetsViewController *weakSelf = self;
        [weakSelf.expenseSheetsTableView.pullToRefreshView stopAnimating];
        [Util showOfflineAlert];
        return;
    }
    CLS_LOG(@"-----Check for update action triggered on ListOfExpenseSheetsViewController-----");
    //implemented as per US8689//JUHI
    ExpenseModel *expenseModel = [[ExpenseModel alloc] init];
    [expenseModel deleteAllSystemCurrencyFromDB];
    [expenseModel deleteAllSystemPaymentMethodFromDB];


    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromRefreshedData)
                                                 name:PULL_TO_REFRESH_EXPENSESHEET_NOTIFICATION
                                               object:nil];
    [[RepliconServiceManager expenseService]fetchExpenseSheetUpdateData:nil];
}
-(void)refreshActionForUriNotFoundError

{

    if(![NetworkMonitor isNetworkAvailableForListener: self])

    {

        [Util showOfflineAlert];

        return;

    }

    [self.spinnerDelegate showTransparentLoadingOverlay];


    CLS_LOG(@"-----Check for update action triggered on ListOfExpenseSheetsViewController-----");

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewFromRefreshedData)

                                                 name:PULL_TO_REFRESH_EXPENSESHEET_NOTIFICATION

                                               object:nil];

    [[RepliconServiceManager expenseService]fetchExpenseSheetUpdateData:nil];

}


/************************************************************************************************************
 @Function Name   : checkToShowMoreButton
 @Purpose         : To check to enable more action or not everytime view appears
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)checkToShowMoreButton
{

    NSNumber *expenseSheetsCount =	[[NSUserDefaults standardUserDefaults]objectForKey:@"ExpenseDownloadCount"];
    NSNumber *fetchCount  =    [[AppProperties getInstance] getAppPropertyFor:@"expenseSheetDownloadCount"];

    if (isDeltaUpdate && [self.expenseSheetsArray count]>=10)
    {
        self.expenseSheetsTableView.showsInfiniteScrolling=TRUE;
        isDeltaUpdate=FALSE;
    }
    else{
        if (([expenseSheetsCount intValue]<[fetchCount intValue]))
        {
            self.expenseSheetsTableView.showsInfiniteScrolling=FALSE;
        }
        else
        {
            self.expenseSheetsTableView.showsInfiniteScrolling=FALSE;
            self.expenseSheetsTableView.showsInfiniteScrolling=TRUE;
        }
    }



}

/************************************************************************************************************
 @Function Name   : checkToShowMoreButton
 @Purpose         : To animate tableview with new records requested through more action
 @param           : (NSNotification*)notification
 @return          : nil
 *************************************************************************************************************/


-(void)animateTableRowsAfterMoreAction:(NSNotification *)notificationObject
{
    [self.view setUserInteractionEnabled:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEXT_RECENT_EXPENSESHEET_RECEIVED_NOTIFICATION object:nil];
    ListOfExpenseSheetsViewController *weakSelf = self;
    [weakSelf.expenseSheetsTableView.infiniteScrollingView stopAnimating];

    NSDictionary *theData = [notificationObject userInfo];
    NSNumber *n = [theData objectForKey:@"isErrorOccured"];
    BOOL isErrorOccured = [n boolValue];
    if (isErrorOccured)
    {
        self.expenseSheetsTableView.showsInfiniteScrolling=FALSE;
    }
    else
    {
        [self displayAllExpenseSheets];
        [self.expenseSheetsTableView reloadData];
        [self checkToShowMoreButton];
    }

}

/************************************************************************************************************
 @Function Name   : refreshViewFromRefreshedData
 @Purpose         : To reload tableview everytime when pull to refresh action is made
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)refreshViewFromRefreshedData
{
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    [self.view setUserInteractionEnabled:YES];
    [self checkToShowMoreButton];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PULL_TO_REFRESH_EXPENSESHEET_NOTIFICATION object:nil];
    ListOfExpenseSheetsViewController *weakSelf = self;
    [weakSelf.expenseSheetsTableView.pullToRefreshView stopAnimating];
    [self displayAllExpenseSheets];
    [self.expenseSheetsTableView reloadData];
    [self showMessageLabel];

}
/************************************************************************************************************
 @Function Name   : addExpenseSheetAction
 @Purpose         : To add a new expense sheet
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)addExpenseSheetAction:(id)sender
{
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        return;
    }
    CLS_LOG(@"-----Add new expense sheet action on ListOfExpenseSheetsViewController-----");
    NewExpenseSheetViewController *newExpenseSheetViewController = [[NewExpenseSheetViewController alloc]init];
    newExpenseSheetViewController.tnewExpenseSheetDelegate = self;

    self.navcontroller = [[UINavigationController alloc]initWithRootViewController:newExpenseSheetViewController];
    [self presentViewController:self.navcontroller animated:YES completion:nil];
}

-(void)gotoExpenseSheetEntry:(NSString*)expenseSheeturi
{
    ExpenseModel *expenseModel=[[ExpenseModel alloc]init];

    NSDictionary *expenseSheetDict=(NSDictionary *)[[expenseModel getExpenseSheetInfoSheetIdentity:expenseSheeturi] objectAtIndex:0];

    ListOfExpenseEntriesViewController *listOfExpenseEntries = [self.injector getInstance:[ListOfExpenseEntriesViewController class]];
    listOfExpenseEntries.expenseSheetStatus=[expenseSheetDict objectForKey:@"approvalStatus"];
    listOfExpenseEntries.expenseSheetTitle=[expenseSheetDict objectForKey:@"description"];
    listOfExpenseEntries.expenseSheetURI=[expenseSheetDict objectForKey:@"expenseSheetUri"];
    NSString *reimburseAmount   =[expenseSheetDict objectForKey:@"reimbursementAmount"];
    NSString *reimburseCurrency =[expenseSheetDict objectForKey:@"reimbursementAmountCurrencyName"];
    NSString *reimburseAmountStr=[NSString stringWithFormat:@"%@ %@",reimburseCurrency,reimburseAmount];
    listOfExpenseEntries.reimburseAmountString=reimburseAmountStr;
    NSString *incurredAmount   =[expenseSheetDict objectForKey:@"incurredAmount"];
    NSString *incurredCurrency =[expenseSheetDict objectForKey:@"incurredAmountCurrencyName"];
    NSString *incurredAmountStr=[NSString stringWithFormat:@"%@ %@",incurredCurrency,incurredAmount];
    listOfExpenseEntries.totalIncurredAmountString=incurredAmountStr;
    listOfExpenseEntries.parentDelegate=self;
    listOfExpenseEntries.reimbursementCurrencyName=reimburseCurrency;
    listOfExpenseEntries.reimbursementCurrencyURI=[expenseSheetDict objectForKey:@"reimbursementAmountCurrencyUri"];
    [[NSNotificationCenter defaultCenter] removeObserver:listOfExpenseEntries name:EXPENSESHEET_ENTRY_RECIEVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:listOfExpenseEntries selector:@selector(RecievedData) name:EXPENSESHEET_ENTRY_RECIEVED_NOTIFICATION object:nil];
    [self.navigationController pushViewController:listOfExpenseEntries animated:YES];

    [[NSNotificationCenter defaultCenter]postNotificationName:EXPENSESHEET_ENTRY_RECIEVED_NOTIFICATION object:nil];

}

-(void)showMessageLabel
{
    if (!self.expenseService.didSuccessfullyFetchExpenses)
    {
        [self.msgLabel removeFromSuperview];
        return;
    }

    if ([self.expenseSheetsArray count]>0)
    {
        [self.msgLabel removeFromSuperview];
    }
    else
    {
        [self.msgLabel removeFromSuperview];
        UILabel *tempMsgLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, HeightOfNoExpMsgLabel)];
        tempMsgLabel.text=RPLocalizedString(_NO_EXPENSES_AVAILABLE, _NO_EXPENSES_AVAILABLE);
        self.msgLabel=tempMsgLabel;
        self.msgLabel.backgroundColor=[UIColor clearColor];
        self.msgLabel.numberOfLines=2;
        self.msgLabel.textAlignment=NSTextAlignmentCenter;
        self.msgLabel.font=[UIFont fontWithName:RepliconFontFamily size:16];

        [self.view addSubview:self.msgLabel];
    }
}


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
    self.expenseSheetsTableView=nil;
    self.leftButton=nil;
    self.rightBarButton=nil;
    self.navcontroller=nil;
}


-(void) dealloc
{
    self.expenseSheetsTableView.delegate = nil;
    self.expenseSheetsTableView.dataSource = nil;
}
@end
