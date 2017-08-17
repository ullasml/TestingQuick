#import "ListOfTimeSheetsViewController.h"
#import "AppDelegate.h"
#import "TimesheetObject.h"
#import "SVPullToRefresh.h"
#import "CurrentTimesheetViewController.h"
#import "LoginModel.h"
#import "WidgetTSViewController.h"
#import "ListOfTimeSheetsCustomCell.h"
#import "DefaultTheme.h"
#import "ButtonStylist.h"
#import "NSString+Double_Float.h"
#import "ApprovalStatusPresenter.h"
#import "ErrorBannerViewController.h"
#import "ErrorDetailsDeserializer.h"
#import "ErrorDetailsStorage.h"
#import "ErrorBannerViewParentPresenterHelper.h"
#import <Blindside/BSInjector.h>
#import "PrefetchTimesheetsHelper.h"
#import "InjectorKeys.h"
#import "BaseSyncOperationManager.h"
#import <repliconkit/repliconkit.h>


@interface ListOfTimeSheetsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic, weak) id<BSInjector> injector;
@property (nonatomic) NSNotificationCenter *notificationCenter;
@property (nonatomic) TimesheetService *timesheetService;
@property (nonatomic) TimesheetModel *timesheetModel;
@property (nonatomic) NSUserDefaults *userdefaults;

@property (nonatomic) UITableView *timeSheetsTableView;
@property (nonatomic) NSMutableArray *timeSheetsArray;
@property (nonatomic) CGPoint currentContentOffset;
@property (nonatomic) UIBarButtonItem *leftButton;
@property (nonatomic) NSIndexPath *selectedIndex;
@property (nonatomic) BOOL isCalledFromMenu;
@property (nonatomic) UILabel *msgLabel;
@property (nonatomic) UIActivityIndicatorView *spinnerView;
@property (nonatomic) ErrorBannerViewController *errorBannerViewController;
@property (nonatomic) ErrorDetailsDeserializer *errorDetailsDeserializer;
@property (nonatomic) ErrorDetailsStorage *errorDetailsStorage;
@property (nonatomic) ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper;
@property (nonatomic,assign) BOOL isFromDeepLink;

@end


static CGFloat const HeightOfNoTSMsgLabel = 80.0f;
static CGFloat const Each_Cell_Row_Height_58 = 58.0f;


@implementation ListOfTimeSheetsViewController

- (instancetype)initWithErrorBannerViewParentPresenterHelper:(ErrorBannerViewParentPresenterHelper *)errorBannerViewParentPresenterHelper
                                   errorBannerViewController:(ErrorBannerViewController *)errorBannerViewController
                                    errorDetailsDeserializer:(ErrorDetailsDeserializer *)errorDetailsDeserializer
                                          notificationCenter:(NSNotificationCenter *)notificationCenter
                                         errorDetailsStorage:(ErrorDetailsStorage *)errorDetailsStorage
                                             spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                                            timesheetService:(TimesheetService *)timesheetService
                                              timeSheetModel:(TimesheetModel *)timesheetModel
                                                userdefaults:(NSUserDefaults *)userdefaults {
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.errorBannerViewParentPresenterHelper = errorBannerViewParentPresenterHelper;
        self.errorBannerViewController = errorBannerViewController;
        self.errorDetailsDeserializer = errorDetailsDeserializer;
        self.errorDetailsStorage = errorDetailsStorage;
        self.notificationCenter = notificationCenter;
        self.timesheetService = timesheetService;
        self.spinnerDelegate = spinnerDelegate;
        self.timesheetModel = timesheetModel;
        self.userdefaults = userdefaults;
        self.timeSheetsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [super doesNotRecognizeSelector:_cmd];

    return nil;
}

#pragma mark - UIViewController

- (void)loadView
{
    [super loadView];
    [self.view setBackgroundColor:RepliconStandardBackgroundColor];
    [Util setToolbarLabel: self withText: RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle)];

    if (!self.timeSheetsTableView) {
        UITableView *temptimeSheetsTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [self heightForTableView]) style:UITableViewStylePlain];
        self.timeSheetsTableView=temptimeSheetsTableView;
        self.timeSheetsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    self.timeSheetsTableView.delegate=self;
    self.timeSheetsTableView.dataSource=self;
    [self.view addSubview:self.timeSheetsTableView];
    UIView *bckView = [UIView new];
    [bckView setBackgroundColor:RepliconStandardBackgroundColor];
    [self.timeSheetsTableView setBackgroundView:bckView];
    [self.timeSheetsTableView setAccessibilityLabel:@"uia_list_of_timesheet_table_identifier"];

    [self configureTableForPullToRefresh];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
            self.edgesForExtendedLayout = UIRectEdgeNone;

    self.spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinnerView.hidesWhenStopped=YES;
    [[WidgetsManager sharedInstance] startPlistManager]; //Stored supported widgets in plist
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //reset selected index
    self.selectedIndex = nil;

    [self checkToShowMoreButton];
    self.timeSheetsArray=[self displayAllTimeSheets];
    [self.timeSheetsTableView reloadData];
    [self showMessageLabel];
    self.navigationItem.rightBarButtonItem.customView.hidden=YES;

    [self fetchTimesheets];
    
    [self.errorBannerViewController addObserver:self];
    [self changeTableviewInset];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    ListOfTimeSheetsViewController *weakSelf = self;
    [weakSelf.timeSheetsTableView.pullToRefreshView stopAnimating];
    [weakSelf.timeSheetsTableView.infiniteScrollingView stopAnimating];
    [self.view setUserInteractionEnabled:YES];
    [self.errorBannerViewController removeObserver];
}

- (void)errorBannerViewChanged
{
    [self changeTableviewInset];
}

-(void)changeTableviewInset
{
    [self.errorBannerViewParentPresenterHelper setTableViewInsetWithErrorBannerPresentation:self.timeSheetsTableView];
}

#pragma mark -
#pragma mark - UITableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.timeSheetsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TimeSheetCellIdentifier";
    ListOfTimeSheetsCustomCell *cell = (ListOfTimeSheetsCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
    {
        cell = [[ListOfTimeSheetsCustomCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];

    }

    if ([self.timeSheetsArray count] > 0)
    {

        TimesheetObject *timesheet = self.timeSheetsArray[indexPath.row];

        NSDate *timesheetStartDate = [timesheet timesheetStartDate];
        NSDate *timesheetEndDate = [timesheet timesheetEndDate];

        NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale=[NSLocale currentLocale];;
        [myDateFormatter setLocale:locale];
        [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        myDateFormatter.dateFormat = @"MMM dd";
        NSString *timesheetStartDateStr = [myDateFormatter stringFromDate:timesheetStartDate];
        myDateFormatter.dateFormat = @"MMM dd, yyyy";
        NSString *timesheetEndDateStr = [myDateFormatter stringFromDate:timesheetEndDate];
        NSString *timesheetPeriodStr=[NSString stringWithFormat:@"%@ - %@",timesheetStartDateStr,timesheetEndDateStr];


        NSString *totalDecimal = [timesheet timesheetTotalDecimal];
        NSString *approvalStatus = [timesheet timesheetStatus];
        NSString *liveApprovalStatusFromDB = [self.timesheetModel getCurrentApprovalStatus:timesheet.timesheetURI];
        if (liveApprovalStatusFromDB!=nil && ![liveApprovalStatusFromDB isKindOfClass:[NSNull class]])
        {
            approvalStatus = liveApprovalStatusFromDB;
        }
        if (approvalStatus!=nil && ![approvalStatus isKindOfClass:[NSNull class]])
        {
            if ([approvalStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION])
            {
                approvalStatus = RPLocalizedString(WAITING_FOR_APRROVAL_STATUS, @"");
            }
            else if ([approvalStatus isEqualToString:TIMESHEET_SUBMITTED])
            {
                approvalStatus = RPLocalizedString(WAITING_FOR_APRROVAL_STATUS, @"");
            }

        }
        NSString *mealPenalties = [timesheet timesheetMealPenalties];
        NSString *overtimeDecimal = [timesheet timesheetOvertimeDecimal];
        NSString *regularDecimal = [timesheet timesheetRegularDecimal];
        NSString *timeOffDecimal = [timesheet timesheetTimeoffDecimal];

        BOOL isPendingSync = NO;

        if ([self.timesheetModel getPendingOperationsArr:timesheet.timesheetURI].count>0)
        {
            isPendingSync = YES;
        }

        [cell createCellLayoutWithParams:timesheetPeriodStr
                      upperlefttextcolor:nil
                           upperrightstr:totalDecimal
                     upperRighttextcolor:nil
                             overTimeStr:overtimeDecimal
                                 mealStr:[NSString stringWithFormat:@"%@",mealPenalties]
                              timeOffStr:timeOffDecimal
                              regularStr:regularDecimal
                          approvalStatus:approvalStatus
                                   width:CGRectGetWidth(self.view.bounds)
                             pendingSync:isPendingSync
         ];
    }
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return Each_Cell_Row_Height_58;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLS_LOG(@"-----Row clicked on ListOfTimeSheetsViewController -----");
    
    self.currentContentOffset=self.timeSheetsTableView.contentOffset;
    self.selectedIndex=indexPath;
    NSString *timesheetURI=[[self.timeSheetsArray objectAtIndex:self.selectedIndex.row] timesheetURI];

    PrefetchTimesheetsHelper *prefetchTimesheetsHelper = [self.injector getInstance:InjectorKeyPrefetchTimesheetsHelper];
    NSMutableArray *allOperations = [NSMutableArray arrayWithArray:prefetchTimesheetsHelper.operations.allObjects];
    for (AFHTTPRequestOperation *operation in allOperations) {
        if ([operation.name isEqualToString:timesheetURI]) {
            [prefetchTimesheetsHelper removeTimesheetOperation:operation];
        }
    }
    TimesheetModel *timesheetModel = [[TimesheetModel alloc] init];
    NSArray *dbTimesheetSummaryArray = [timesheetModel getAllTimesheetDaySummaryFromDBForTimesheet:timesheetURI];
    NSArray *dbTimesheetInfoArray=[timesheetModel getTimeSheetInfoSheetIdentity:timesheetURI];
    BOOL isWidgetTimesheet=NO;
    NSArray *enabledWidgetsUriArray=nil;
    if ([dbTimesheetInfoArray count]>0) {
        enabledWidgetsUriArray=[timesheetModel getAllSupportedAndNotSupportedWidgetsForTimesheetUri:timesheetURI];
        if (enabledWidgetsUriArray.count>0)
        {
            isWidgetTimesheet=TRUE;
        }
    }
    [self.notificationCenter removeObserver:self name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [self.notificationCenter addObserver:self selector:@selector(receivedTimesheetSummaryData:) name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];


    if (isWidgetTimesheet)
    {
        NSArray *dbTimesheetTimeEntriesArray = nil;

        for (NSDictionary *enabledWidgetsDict in enabledWidgetsUriArray)
        {
            NSString *format=@"";

            if ([enabledWidgetsDict[@"widgetUri"] isEqualToString:STANDARD_WIDGET_URI])
            {
                format=GEN4_STANDARD_TIMESHEET;
            }
            else if ([enabledWidgetsDict[@"widgetUri"] isEqualToString:INOUT_WIDGET_URI])
            {
                format=GEN4_INOUT_TIMESHEET;
            }
            else if ([enabledWidgetsDict[@"widgetUri"] isEqualToString:EXT_INOUT_WIDGET_URI])
            {
                format=GEN4_EXT_INOUT_TIMESHEET;
            }
            else if ([enabledWidgetsDict[@"widgetUri"] isEqualToString:DAILY_FIELDS_WIDGET_URI])
            {
                format=GEN4_DAILY_WIDGET_TIMESHEET;
            }
           dbTimesheetTimeEntriesArray = [timesheetModel getAllTimeEntriesForSheetFromDB:timesheetURI forTimeSheetFormat:format];
            if (dbTimesheetTimeEntriesArray!=nil)
            {
                break;
            }


        }

        if ([dbTimesheetTimeEntriesArray count]>0)
        {
            [self.notificationCenter postNotificationName:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];

        }
        else
        {
            for (NSDictionary *enabledWidgetsDict in enabledWidgetsUriArray)
            {
                if ([enabledWidgetsDict[@"widgetUri"] isEqualToString:PUNCH_WIDGET_URI])
                {
                    PunchHistoryModel *punchHistoryModel = [[PunchHistoryModel alloc]init];
                    TimesheetObject *timesheetObj=[self.timeSheetsArray objectAtIndex:indexPath.row];
                    NSDateFormatter *df = [[NSDateFormatter alloc] init];
                    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                    [df setDateFormat:@"YYYY-MM-dd"];
                    NSString *timesheetStartDateStr=[df stringFromDate:timesheetObj.timesheetStartDate];
                    NSString *timesheetEndDateStr=[df stringFromDate:timesheetObj.timesheetEndDate];
                    NSArray *punchesArr = [punchHistoryModel getAllPunchesForWidgetTimesheet:YES approvalsModule:nil startDateStr:timesheetStartDateStr endDateStr:timesheetEndDateStr];
                    if ([punchesArr count]>0)
                    {
                        [self.notificationCenter postNotificationName:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
                        return;

                    }
                }
                else if ([enabledWidgetsDict[@"widgetUri"] isEqualToString:DAILY_FIELDS_WIDGET_URI])
                {
                    NSArray *dailyFieldsOEFArr = [timesheetModel getTimesheetObjectExtensionFieldsForTimeSheetUri:timesheetURI andtimesheetFormat:GEN4_DAILY_WIDGET_TIMESHEET andOEFLevel:DAILY_WIDGET_DAYLEVEL_OEF];
                    if ([dailyFieldsOEFArr count]>0)
                    {
                        [self.notificationCenter postNotificationName:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
                        return;

                    }
                }

            }

            if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
            {
                [Util showOfflineAlert];
                [self.notificationCenter removeObserver:self name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
                return;

            }
            TimesheetModel *tsModel=[[TimesheetModel alloc]init];

            [tsModel deleteTimeEntriesFromDBForForTimesheetIdentity:timesheetURI];
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
            [self.timesheetService fetchTimeSheetSummaryDataForTimesheet:timesheetURI withDelegate:self];

        }


    }

    else
    {
        if ([dbTimesheetSummaryArray count]==0)
        {

            if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
            {
                [Util showOfflineAlert];
                [self.notificationCenter removeObserver:self name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
                return;

            }


            [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
            [self.timesheetService fetchTimeSheetSummaryDataForTimesheet:timesheetURI withDelegate:self];

        }
        else
        {
            [self.notificationCenter postNotificationName:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];


        }

    }

}

#pragma mark - Private

- (void)_prefetchDataForTimesheetObjects:(NSArray *)timesheetObjectsArr
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        int numberOfTimesheetsWhichRequiresCaching = 5;
        for (int index =0 ; index < timesheetObjectsArr.count; index++) {
            TimesheetObject *timesheetObj = timesheetObjectsArr[index];
            [self fetchTimesheetData:timesheetObj.timesheetURI];
            if (index == numberOfTimesheetsWhichRequiresCaching -1) {
                break;
            }
        }

        for (TimesheetObject *timesheetObj in timesheetObjectsArr)
        {
            NSString *timesheetURI = [timesheetObj timesheetURI];

            AFHTTPRequestOperation *operation = [[RepliconServiceManager timesheetRequest]
                                                 sendRequestToFetchBreaksWithTimesheetURI:timesheetURI];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received for URL::::: %@ ",operation.request.URL] forLogLevel:LoggerCocoaLumberjack];

                CLS_LOG(@"Response Received for URL::::: %@ ",operation.request.URL);

                [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received ::::: %@",operation.responseString] forLogLevel:LoggerCocoaLumberjack];

                CLS_LOG(@"Response Received ::::: %@",operation.responseString);

                // store the response to the database
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [[RepliconServiceManager timesheetService] handleBreakDownload:[NSMutableDictionary dictionaryWithObject:responseObject forKey:@"response"]];
                });


            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                // do nothing
                [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Failed ::::: %@ ",[error description]] forLogLevel:LoggerCocoaLumberjack];

                CLS_LOG(@"Response Failed ::::: %@ ",[error description]);

                [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received ::::: %@",operation.responseString] forLogLevel:LoggerCocoaLumberjack];

                CLS_LOG(@"Response Received ::::: %@ ",operation.responseString);
            }];
            [operation start];

            break;
        }

    });

}

-(void)fetchTimesheetData:(NSString *)timesheetUri
{
    PrefetchTimesheetsHelper *prefetchTimesheetsHelper = [self.injector getInstance:InjectorKeyPrefetchTimesheetsHelper];
    NSString *timesheetURI = timesheetUri;

    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
    NSString *timesheetFormat =nil;
    NSArray *dbTimesheetInfoArray=[timesheetModel getTimeSheetInfoSheetIdentity:timesheetURI];
    if ([dbTimesheetInfoArray count]>0)
    {
        timesheetFormat=[[dbTimesheetInfoArray objectAtIndex:0] objectForKey:@"timesheetFormat"];
    }
    BOOL isFreshDataDownload=YES;
    NSMutableArray *daySummaryArr=[timesheetModel getAllTimesheetDaySummaryFromDBForTimesheet:timesheetURI];
    if (daySummaryArr.count>0)
    {
        isFreshDataDownload=NO;
    }
    // Pre-cache data for each timesheet
    if (isFreshDataDownload) {
        AFHTTPRequestOperation *operation = [[RepliconServiceManager timesheetRequest]
                                             fetchTimeSheetSummaryDataForTimesheet:timesheetURI
                                             isFreshDataDownload:YES];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            CLS_LOG(@"----fetchTimeSheetSummaryDataForTimesheet and isFreshDataDownload-------");

            [LogUtil logLoggingInfo:@"----fetchTimeSheetSummaryDataForTimesheet and isFreshDataDownload-------" forLogLevel:LoggerCocoaLumberjack];
            [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received for URL::::: %@ ",operation.request.URL] forLogLevel:LoggerCocoaLumberjack];

            CLS_LOG(@"Response Received for URL::::: %@ ",operation.request.URL);

            [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received ::::: %@",operation.responseString] forLogLevel:LoggerCocoaLumberjack];

            CLS_LOG(@"Response Received ::::: %@",operation.responseString);
            // store the response to the database
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[RepliconServiceManager timesheetService] handleTimesheetsSummaryFetchData:[NSMutableDictionary dictionaryWithObject:responseObject forKey:@"response"] isFromSave:NO];
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Failed ::::: %@ ",[error description]] forLogLevel:LoggerCocoaLumberjack];

            CLS_LOG(@"Response Failed ::::: %@ ",[error description]);

            [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received ::::: %@",operation.responseString] forLogLevel:LoggerCocoaLumberjack];

            CLS_LOG(@"Response Received ::::: %@ ",operation.responseString);
        }];
        [operation start];
        operation.name = timesheetUri;
        [prefetchTimesheetsHelper addTimesheetOperation:operation];
    }

}

-(void)handlePrefetchingOfModifiedSelectedTimesheets:(NSMutableDictionary *)responseObject
{
    NSArray *headerArray = [[[responseObject objectForKey:@"d"] objectForKey:@"listData"] objectForKey:@"header"];
    NSArray *arrayWithUri = [headerArray valueForKey:@"uri"];
    NSUInteger index = [arrayWithUri indexOfObject:TIMESHEET_LIST_COLUMN];
    NSArray *rowsArray=[[[responseObject objectForKey:@"d"] objectForKey:@"listData"] objectForKey:@"rows"];
    if (rowsArray!=nil && ![rowsArray isKindOfClass:[NSNull class]])
    {
        for (int i=0; i<rowsArray.count; i++) {
            NSArray *array=[[rowsArray objectAtIndex:i] objectForKey:@"cells"];
            NSString *timesheetUri = [[array objectAtIndex:index] objectForKey:@"uri"];
            NSLog(@"timesheetUri = %@",timesheetUri);
            BOOL isUpdatedEntries = [self.timesheetModel checkIfTimeEntriesModifiedOrDeleted:timesheetUri timesheetFormat:GEN4_INOUT_TIMESHEET];
            if (!isUpdatedEntries)
            {
                if (self.timeSheetsArray.count>0 && self.selectedIndex!=nil)
                {
                    if (timesheetUri!=nil && ![timesheetUri isKindOfClass:[NSNull class]])
                    {
                        if ([self.navigationController.visibleViewController isKindOfClass:[WidgetTSViewController class]] || [self.navigationController.visibleViewController isKindOfClass:[CurrentTimesheetViewController class]])
                        {
                            if ([NetworkMonitor isNetworkAvailableForListener:self] == YES)
                            {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                                    [self.timesheetService fetchTimeSheetSummaryDataForTimesheet:timesheetUri withDelegate:self];
                                });
                            }
                        }
                        else
                        {
                            if ([NetworkMonitor isNetworkAvailableForListener:self] == YES)
                            {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self.timesheetService fetchTimeSheetSummaryDataForTimesheet:timesheetUri withDelegate:self];
                                });
                            }
                        }

                    }

                }

                else
                {
                    NSArray *timesheetArr = [self.timesheetModel getTimeSheetInfoSheetIdentity:timesheetUri];

                    if ([timesheetArr count]>0)
                    {
                        [self.timesheetModel deleteTimesheetsFromDBForForTimesheetIdentity:timesheetUri];
                        [self.timesheetModel saveTimesheetDataToDB:timesheetArr[0]];
                    }

                }
            }
        }
    }

}

-(void)handlePrefetchingOfModifiedTimesheets:(NSMutableDictionary *)responseObject
{
    NSArray *headerArray = [[[responseObject objectForKey:@"d"] objectForKey:@"listData"] objectForKey:@"header"];
    NSArray *arrayWithUri = [headerArray valueForKey:@"uri"];
    NSUInteger index = [arrayWithUri indexOfObject:TIMESHEET_LIST_COLUMN];
    NSArray *rowsArray=[[[responseObject objectForKey:@"d"] objectForKey:@"listData"] objectForKey:@"rows"];
    if (rowsArray!=nil && ![rowsArray isKindOfClass:[NSNull class]])
    {
        for (int i=0; i<rowsArray.count; i++) {
            NSArray *array=[[rowsArray objectAtIndex:i] objectForKey:@"cells"];
            NSString *timesheetUri = [[array objectAtIndex:index] objectForKey:@"uri"];
            NSLog(@"timesheetUri = %@",timesheetUri);
            if ([self.timesheetModel getPendingOperationsArr:timesheetUri].count==0)
            {
                [self fetchTimesheetData:timesheetUri];

            }
        }
    }
    
}

- (void)fetchTimesheets {
    NSMutableArray *dbTimesheetsArray = [self.timesheetModel getAllTimesheetsFromDB];
    if ([dbTimesheetsArray count] == 0) {
        [self.spinnerDelegate showTransparentLoadingOverlay];
        [self.timesheetService fetchTimeSheetData:nil];
        [self.notificationCenter addObserver:self selector:@selector(handleTimesheetServiceNotification) name:@"allTimesheetRequestsServed" object:nil];
    }
    else
    {
        if ([NetworkMonitor isNetworkAvailableForListener:self] == YES)
        {

//            AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//            [[appDelegate.injector getInstance:[BaseSyncOperationManager class]] startSync];

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

                AFHTTPRequestOperation *operation = [[RepliconServiceManager timesheetRequest]
                                                     fetchTimeSheetUpdateData];
                [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

                    CLS_LOG(@"-----fetchTimeSheetUpdateData -----");

                    [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received for URL::::: %@ ",operation.request.URL] forLogLevel:LoggerCocoaLumberjack];

                    CLS_LOG(@"Response Received for URL::::: %@ ",operation.request.URL);

                    [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received ::::: %@",operation.responseString] forLogLevel:LoggerCocoaLumberjack];

                    CLS_LOG(@"Response Received ::::: %@",operation.responseString);

                    NSDictionary *dictionary = operation.response.allHeaderFields;
                    NSString *serverTimestamp=[dictionary objectForKey:@"Date"];

                    if (serverTimestamp!=nil && ![serverTimestamp isKindOfClass:[NSNull class]])
                    {
                        NSString *key=@"TimeSheetLastModifiedTime";
                        //Implementation of TimeSheetLastModified

                        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
                        [defaults removeObjectForKey:key];
                        [defaults setObject:serverTimestamp forKey:key];
                        [defaults synchronize];
                    }

                    self.timeSheetsTableView.showsPullToRefresh = NO;

                    [self.spinnerView startAnimating];

                    self.view.userInteractionEnabled=NO;

                    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.spinnerView];
                    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        
                        [[RepliconServiceManager timesheetService] handleTimesheetsUpdateFetchData:[NSMutableDictionary dictionaryWithObject:responseObject forKey:@"response"]];


                        if ([responseObject objectForKey:@"d"]!=nil && ![[responseObject objectForKey:@"d"] isKindOfClass:[NSNull class]])
                        {
                            if ([[responseObject objectForKey:@"d"] objectForKey:@"listData"]!=nil && ![[[responseObject objectForKey:@"d"] objectForKey:@"listData"] isKindOfClass:[NSNull class]])
                            {
                                ////Pre fetch if any timesheets modified in wts or mobile
                                [self handlePrefetchingOfModifiedSelectedTimesheets:responseObject];
                                //[self handlePrefetchingOfModifiedTimesheets:responseObject];
                            }
                        }



                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.spinnerView stopAnimating];

                            self.timeSheetsTableView.showsPullToRefresh = YES;

                            self.view.userInteractionEnabled=YES;
                        });

                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.timeSheetsArray=[self displayAllTimeSheets];
                            [self.timeSheetsTableView reloadData];
                            [self showMessageLabel];

                        });
                    });


                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

                    [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Failed ::::: %@ ",[error description]] forLogLevel:LoggerCocoaLumberjack];

                    CLS_LOG(@"Response Failed ::::: %@ ",[error description]);

                    [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received ::::: %@",operation.responseString] forLogLevel:LoggerCocoaLumberjack];

                    CLS_LOG(@"Response Received ::::: %@ ",operation.responseString);
                    [self.spinnerView stopAnimating];
                    self.view.userInteractionEnabled=YES;
                }];
                [operation start];


                
            });


        }

    }
}

- (void)handleTimesheetServiceNotification {
    [self.notificationCenter removeObserver: self name: @"allTimesheetRequestsServed" object: nil];
    [self checkToShowMoreButton];
    self.timeSheetsArray=[self displayAllTimeSheets];
    [self.timeSheetsTableView reloadData];
    [self showMessageLabel];
    [self.spinnerDelegate hideTransparentLoadingOverlay];

   // [self _prefetchDataForTimesheetObjects:self.timeSheetsArray];
}

-(void)receivedTimesheetSummaryData:(NSNotification *)notification
{
    [self.notificationCenter removeObserver:self name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
    if ([self.timeSheetsArray count]>self.selectedIndex.row) {
        NSString *timesheetURI=[[self.timeSheetsArray objectAtIndex:self.selectedIndex.row] timesheetURI];
        NSArray *timesheetInfoArray=[timesheetModel getTimeSheetInfoSheetIdentity:timesheetURI];
        BOOL isGen4Timesheet=NO;
        if ([timesheetInfoArray count]>0)
        {
            NSArray *enabledWidgetsUriArray=[timesheetModel getAllSupportedAndNotSupportedWidgetsForTimesheetUri:timesheetURI];
            if (enabledWidgetsUriArray.count>0)
            {
                isGen4Timesheet=TRUE;
            }
            
            
        }
        
        
        if (isGen4Timesheet)
        {
            NSDate *timesheetStartDate=[[self.timeSheetsArray objectAtIndex:self.selectedIndex.row] timesheetStartDate];
            NSDate *timesheetEndDate=[[self.timeSheetsArray objectAtIndex:self.selectedIndex.row] timesheetEndDate];
            NSString *timesheetURI=[[self.timeSheetsArray objectAtIndex:self.selectedIndex.row] timesheetURI];
            
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
            WidgetTSViewController *widgetsheetView=[[WidgetTSViewController alloc]init];
            widgetsheetView.parentDelegate=self;
            NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
            NSLocale *locale=[NSLocale currentLocale];;
            [myDateFormatter setLocale:locale];
            [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            myDateFormatter.dateFormat = @"MMM dd";
            NSString *sheet=[NSString stringWithFormat:@" %@ - %@",[myDateFormatter stringFromDate:timesheetStartDate],[myDateFormatter stringFromDate:timesheetEndDate]];
            
            widgetsheetView.isCurrentTimesheetPeriod=[Util getCurrenTimeSheetPeriodFromTimesheetStartDate:[[self.timeSheetsArray objectAtIndex:self.selectedIndex.row] timesheetStartDate] andTimesheetEndDate:[[self.timeSheetsArray objectAtIndex:self.selectedIndex.row] timesheetEndDate]];
            widgetsheetView.sheetApprovalStatus=[timesheetModel getTimesheetApprovalStatusForTimesheetIdentity:[[self.timeSheetsArray objectAtIndex:self.selectedIndex.row] timesheetURI]];
            widgetsheetView.selectedSheet=sheet;
            widgetsheetView.sheetIdentity=timesheetURI;
            widgetsheetView.timesheetStartDate=timesheetStartDate;
            widgetsheetView.timesheetEndDate=timesheetEndDate;
            widgetsheetView.dueDate=[NSString stringWithFormat:@"%@",[myDateFormatter stringFromDate:[[self.timeSheetsArray objectAtIndex:self.selectedIndex.row]timeSheetDueDate]]];
            id validationDict=[[notification userInfo] objectForKey:@"widgetTimesheetValidationResult"];
            if (validationDict!=nil && ![validationDict isKindOfClass:[NSNull class]])
            {
                widgetsheetView.errorAndWarningsArray=[[[notification userInfo] objectForKey:@"widgetTimesheetValidationResult"] objectForKey:@"validationMessages"];
            }
            
            if ([NetworkMonitor isNetworkAvailableForListener:self] == YES)
            {
                
                [self.notificationCenter removeObserver:widgetsheetView name:GEN4_TIMESHEET_VALIDATION_DATA_NOTIFICATION object:nil];
                [self.notificationCenter addObserver:widgetsheetView selector:@selector(validationDataReceived:) name:GEN4_TIMESHEET_VALIDATION_DATA_NOTIFICATION object:nil];
                [self.timesheetService sendRequestToGetValidationDataForTimesheet:timesheetURI];
                
            }
            if(self.isFromDeepLink){
                widgetsheetView.isFromDeepLink = YES;
                self.isFromDeepLink = NO;
            }
            [self.navigationController pushViewController:widgetsheetView animated:YES];
        }
        else
        {
            //US9453 to address DE17320 Ullas M L
            TimesheetModel *tsModel=[[TimesheetModel alloc]init];
            NSMutableArray *enableOnlyUdfUriArr=[tsModel getEnabledOnlyUdfArrayForTimesheetUri:timesheetURI];
            NSMutableArray *enableOnlyUdfUriArray=[NSMutableArray array];
            for (int k=0; k<[enableOnlyUdfUriArr count]; k++)
            {
                NSString *udfUri=[[enableOnlyUdfUriArr objectAtIndex:k] objectForKey:@"udfUri"];
                [enableOnlyUdfUriArray addObject:udfUri];
            }
            [tsModel updateCustomFieldTableForEnableUdfuriArray:enableOnlyUdfUriArray];
            
            id <Theme> theme = [[DefaultTheme alloc] init];
            ButtonStylist *buttonStylist = [[ButtonStylist alloc] initWithTheme:theme];
            AppDelegate *appDelegate = (id)[[UIApplication sharedApplication] delegate];
            ApprovalStatusPresenter *approvalStatusPresenter = [[ApprovalStatusPresenter alloc] initWithTheme:theme];
            
            CurrentTimesheetViewController *currentTimesheetViewController = [[CurrentTimesheetViewController alloc] initWithApprovalStatusPresenter:approvalStatusPresenter
                                                                                                                                               theme:theme
                                                                                                                                    supportDataModel:[[SupportDataModel alloc] init]
                                                                                                                                      timesheetModel:[[TimesheetModel alloc] init]
                                                                                                                                       buttonStylist:buttonStylist
                                                                                                                                         appDelegate:appDelegate];
            
            currentTimesheetViewController.parentDelegate=self;
            NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
            NSLocale *locale=[NSLocale currentLocale];
            [myDateFormatter setLocale:locale];
            [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            
            myDateFormatter.dateFormat = @"MMM dd";
            
            currentTimesheetViewController.selectedSheet=[NSString stringWithFormat:@" %@ - %@",[myDateFormatter stringFromDate:[[self.timeSheetsArray objectAtIndex:self.selectedIndex.row] timesheetStartDate]],[myDateFormatter stringFromDate:[[self.timeSheetsArray objectAtIndex:self.selectedIndex.row] timesheetEndDate]]];
            currentTimesheetViewController.isCurrentTimesheetPeriod=[Util getCurrenTimeSheetPeriodFromTimesheetStartDate:[[self.timeSheetsArray objectAtIndex:self.selectedIndex.row] timesheetStartDate] andTimesheetEndDate:[[self.timeSheetsArray objectAtIndex:self.selectedIndex.row] timesheetEndDate]];
            currentTimesheetViewController.sheetApprovalStatus=[[self.timeSheetsArray objectAtIndex:self.selectedIndex.row] timesheetStatus];
            currentTimesheetViewController.sheetIdentity=[[self.timeSheetsArray objectAtIndex:self.selectedIndex.row] timesheetURI];
            currentTimesheetViewController.dueDate=[NSString stringWithFormat:@"%@",[myDateFormatter stringFromDate:[[self.timeSheetsArray objectAtIndex:self.selectedIndex.row]timeSheetDueDate]]];
            currentTimesheetViewController.totalHours=[[self.timeSheetsArray objectAtIndex:self.selectedIndex.row] timesheetTotalDecimal];
            if(self.isFromDeepLink){
                NSDate *startDate = [[self.timeSheetsArray objectAtIndex:self.selectedIndex.row] timesheetStartDate];
                [currentTimesheetViewController enableDeeplinkForTimesheetWithStartDate:startDate];
                self.isFromDeepLink = NO;
            }
            [currentTimesheetViewController RecievedData];
            [self.navigationController pushViewController:currentTimesheetViewController animated:YES];
        }
    }

}

- (void) networkActivated {


}

/************************************************************************************************************
 @Function Name   : configureTableForPullToRefresh
 @Purpose         : To extend tableview to add pull to refresh and infinite scrolling view
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)configureTableForPullToRefresh
{
    ListOfTimeSheetsViewController *weakSelf = self;


    //setup pull to refresh widget
    [self.timeSheetsTableView addPullToRefreshWithActionHandler:^{
        [weakSelf.view setUserInteractionEnabled:NO];
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {


                           [weakSelf.timeSheetsTableView.pullToRefreshView startAnimating];

                           [weakSelf refreshAction];

                       });
    }];

    // setup infinite scrolling
    [self.timeSheetsTableView addInfiniteScrollingWithActionHandler:^{

        [weakSelf.view setUserInteractionEnabled:YES];
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {

                           [weakSelf.timeSheetsTableView.infiniteScrollingView startAnimating];
                           [[NSOperationQueue mainQueue] addOperationWithBlock:^ {

                               [weakSelf moreAction];
                               
                           }];



                       });
    }];

}
/************************************************************************************************************
 @Function Name   : displayAllTimeSheets
 @Purpose         : To create timesheet objects from the list of timesheets array from DB
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
-(NSMutableArray *)displayAllTimeSheets
{
    NSMutableArray *dbTimesheetsArray = [self.timesheetModel getAllTimesheetsFromDB];
    //NSMutableIndexSet *indicesForObjectsToAdd = [[NSMutableIndexSet alloc] init];
    NSMutableArray *newArr = [NSMutableArray array];
    [dbTimesheetsArray enumerateObjectsUsingBlock:^(NSDictionary * timesheetDict, NSUInteger idx, BOOL *stop)
     {
         TimesheetObject *timesheetObj   = [[TimesheetObject alloc] init];
         timesheetObj.timesheetStatus= [timesheetDict objectForKey:@"approvalStatus"];
         timesheetObj.timesheetStartDate=[Util convertTimestampFromDBToDate:[[timesheetDict objectForKey:@"startDate"] stringValue]];
         timesheetObj.timesheetEndDate=[Util convertTimestampFromDBToDate:[[timesheetDict objectForKey:@"endDate"] stringValue]];
         timesheetObj.timeSheetDueDate=[Util convertTimestampFromDBToDate:[[timesheetDict objectForKey:@"dueDate"] stringValue]];
         timesheetObj.timesheetOvertimeHours=[timesheetDict objectForKey:@"overtimeDurationHour"];
         timesheetObj.timesheetRegularHours=[timesheetDict objectForKey:@"regularDurationHour"];
         timesheetObj.timesheetTimeoffHours= [timesheetDict objectForKey:@"timeoffDurationHour"];
         timesheetObj.timesheetTotalHours=[timesheetDict objectForKey:@"totalDurationHour"];
         if ([timesheetDict objectForKey:@"overtimeDurationDecimal"]!=nil && ![[timesheetDict objectForKey:@"overtimeDurationDecimal"] isKindOfClass:[NSNull class]])
         {
             timesheetObj.timesheetOvertimeDecimal=[Util getRoundedValueFromDecimalPlaces:[[timesheetDict objectForKey:@"overtimeDurationDecimal"]newDoubleValue]withDecimalPlaces:2];
         }
         if ([timesheetDict objectForKey:@"regularDurationDecimal"]!=nil && ![[timesheetDict objectForKey:@"regularDurationDecimal"] isKindOfClass:[NSNull class]])
         {
             timesheetObj.timesheetRegularDecimal=[Util getRoundedValueFromDecimalPlaces:[[timesheetDict objectForKey:@"regularDurationDecimal"]newDoubleValue]withDecimalPlaces:2];
         }
         if ([timesheetDict objectForKey:@"timeoffDurationDecimal"]!=nil && ![[timesheetDict objectForKey:@"timeoffDurationDecimal"] isKindOfClass:[NSNull class]])
         {
             timesheetObj.timesheetTimeoffDecimal= [Util getRoundedValueFromDecimalPlaces:[[timesheetDict objectForKey:@"timeoffDurationDecimal"]newDoubleValue]withDecimalPlaces:2];
         }
         if ([timesheetDict objectForKey:@"totalDurationDecimal"]!=nil && ![[timesheetDict objectForKey:@"totalDurationDecimal"] isKindOfClass:[NSNull class]])
         {
             timesheetObj.timesheetTotalDecimal=[Util getRoundedValueFromDecimalPlaces:[[timesheetDict objectForKey:@"totalDurationDecimal"]newDoubleValue]withDecimalPlaces:2];
         }

         timesheetObj.timesheetMealPenalties=[timesheetDict objectForKey:@"mealBreakPenalties"];
         timesheetObj.timesheetURI=[timesheetDict objectForKey:@"timesheetUri"];

         NSString *startDate=[Util convertPickerDateToStringShortStyle:
                              [Util convertTimestampFromDBToDate:[[timesheetDict objectForKey:@"startDate"] stringValue]]];
         NSString *endDate=[Util convertPickerDateToStringShortStyle:
                            [Util convertTimestampFromDBToDate:[[timesheetDict objectForKey:@"endDate"] stringValue]]];
         timesheetObj.timesheetPeriod = [NSString stringWithFormat:@"%@ - %@",startDate,endDate];

         //[indicesForObjectsToAdd addIndex:idx];
         [newArr addObject:timesheetObj];

     }];



    return newArr;

}


-(void)goBack:(id)sender
{

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


            AFHTTPRequestOperation *operation = [[RepliconServiceManager timesheetRequest]
                                                 fetchNextRecentTimeSheetData];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                      CLS_LOG(@"-----fetchNextRecentTimeSheetData-----");
                [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received for URL::::: %@ ",operation.request.URL] forLogLevel:LoggerCocoaLumberjack];

                CLS_LOG(@"Response Received for URL::::: %@ ",operation.request.URL);

                [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received ::::: %@",operation.responseString] forLogLevel:LoggerCocoaLumberjack];

                CLS_LOG(@"Response Received ::::: %@",operation.responseString);
                    [[RepliconServiceManager timesheetService] handleNextRecentTimesheetsFetchData:[NSMutableDictionary dictionaryWithObject:responseObject forKey:@"response"]];

                        [self.view setUserInteractionEnabled:YES];

                        [self.timeSheetsTableView.infiniteScrollingView stopAnimating];

                        self.timeSheetsArray=[self displayAllTimeSheets];
                        [self.timeSheetsTableView reloadData];
                        [self checkToShowMoreButton];
            }
            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Failed ::::: %@ ",[error description]] forLogLevel:LoggerCocoaLumberjack];

                CLS_LOG(@"Response Failed ::::: %@ ",[error description]);

                [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received ::::: %@",operation.responseString] forLogLevel:LoggerCocoaLumberjack];

                CLS_LOG(@"Response Received ::::: %@ ",operation.responseString);
                [self.view setUserInteractionEnabled:YES];

                [self.timeSheetsTableView.infiniteScrollingView stopAnimating];
            }];
            [operation start];


    }

}


-(void)refreshTableViewOnConnectionError
{
    ListOfTimeSheetsViewController *weakSelf = self;
    [weakSelf.timeSheetsTableView.infiniteScrollingView stopAnimating];

    self.timeSheetsTableView.showsInfiniteScrolling=FALSE;
    self.timeSheetsTableView.showsInfiniteScrolling=TRUE;



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
        ListOfTimeSheetsViewController *weakSelf = self;
        [weakSelf.timeSheetsTableView.pullToRefreshView stopAnimating];
        [Util showOfflineAlert];
        return;
    }
    CLS_LOG(@"-----Check for update action triggered on ListOfTimeSheetsViewController-----");


   [self handleTableViewRefresh];

}
-(void)refreshActionForUriNotFoundError
{
    if(![NetworkMonitor isNetworkAvailableForListener: self])
    {
        [Util showOfflineAlert];
        return;
    }
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
    CLS_LOG(@"-----Check for update action triggered on ListOfTimeSheetsViewController-----");
    [self handleTableViewRefresh];
}

-(void)handleTableViewRefresh
{
        AFHTTPRequestOperation *operation = [[RepliconServiceManager timesheetRequest]
                                             fetchTimeSheetUpdateData];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                 CLS_LOG(@"----handleTableViewRefresh------");
            [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received for URL::::: %@ ",operation.request.URL] forLogLevel:LoggerCocoaLumberjack];

            CLS_LOG(@"Response Received for URL::::: %@ ",operation.request.URL);

            [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received ::::: %@",operation.responseString] forLogLevel:LoggerCocoaLumberjack];

            CLS_LOG(@"Response Received ::::: %@",operation.responseString);

/*  NOT REQUIRED TO UPDATE ERROR DETAILS
            NSMutableArray *timeSheetUrisArr = [self.errorDetailsDeserializer deserializeTimeSheetUpdateData:responseObject];
            for (NSString *uri in timeSheetUrisArr)
            {
                [self.errorDetailsStorage deleteErrorDetails:uri];
            }
            [self.errorBannerViewController updateErrorBannerData];
 */

                [[RepliconServiceManager timesheetService] handleTimesheetsUpdateFetchData:[NSMutableDictionary dictionaryWithObject:responseObject forKey:@"response"]];

            NSMutableArray *dbTimesheetsArray = [self.timesheetModel getAllTimesheetsFromDB];
            if (dbTimesheetsArray.count>0)
            {
                NSDictionary *timesheetDict = dbTimesheetsArray[0];
                NSDate *startDate = [Util convertTimestampFromDBToDate:[timesheetDict objectForKey:@"startDate"]];
                NSDate *endDate = [Util convertTimestampFromDBToDate:[timesheetDict objectForKey:@"endDate"]];

                if (![Util date:[NSDate date] isBetweenDate:startDate andDate:endDate])
                {
                     [self createFirstTimesheet];
                }
                else
                {
                    [self actionsAfterRefresh];
                }
            }
            else
            {
                [self createFirstTimesheet];
            }

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Failed ::::: %@ ",[error description]] forLogLevel:LoggerCocoaLumberjack];

            CLS_LOG(@"Response Failed ::::: %@ ",[error description]);

            [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received ::::: %@",operation.responseString] forLogLevel:LoggerCocoaLumberjack];

            CLS_LOG(@"Response Received ::::: %@ ",operation.responseString);
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
            [self.view setUserInteractionEnabled:YES];
            [self.timeSheetsTableView.pullToRefreshView stopAnimating];
        }];
        [operation start];

}

-(void)createFirstTimesheet
{
    AFHTTPRequestOperation *operation = [[RepliconServiceManager timesheetRequest]
                                                    GetOrCreateFirstTimesheets];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        CLS_LOG(@"-----createFirstTimesheet-----");
        [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received for URL::::: %@ ",operation.request.URL] forLogLevel:LoggerCocoaLumberjack];

        CLS_LOG(@"Response Received for URL::::: %@ ",operation.request.URL);

        [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received ::::: %@",operation.responseString] forLogLevel:LoggerCocoaLumberjack];

        CLS_LOG(@"Response Received ::::: %@",operation.responseString);
        [[RepliconServiceManager timesheetService] handleTimesheetsDataOnlyWhenUpdateFetchDataFails:[NSMutableDictionary dictionaryWithObject:responseObject forKey:@"response"]];

        [self actionsAfterRefresh];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Failed ::::: %@ ",[error description]] forLogLevel:LoggerCocoaLumberjack];

        CLS_LOG(@"Response Failed ::::: %@ ",[error description]);

        [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received ::::: %@",operation.responseString] forLogLevel:LoggerCocoaLumberjack];

        CLS_LOG(@"Response Received ::::: %@ ",operation.responseString);

        [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
        [self.view setUserInteractionEnabled:YES];
        [self.timeSheetsTableView.pullToRefreshView stopAnimating];
    }];
    [operation start];


}

/************************************************************************************************************
 @Function Name   : checkToShowMoreButton
 @Purpose         : To check to enable more action or not everytime view appears
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)checkToShowMoreButton
{
    NSNumber *timeSheetsCount =	[self.userdefaults objectForKey:@"timesheetsDownloadCount"];
    NSNumber *fetchCount = [[AppProperties getInstance] getAppPropertyFor:@"timesheetDownloadCount"];

    if (self.isDeltaUpdate && [self.timeSheetsArray count] >= 10)
    {
        self.timeSheetsTableView.showsInfiniteScrolling = YES;
        self.isDeltaUpdate = NO;
    }
    else
    {
        if (([timeSheetsCount intValue]<[fetchCount intValue]))
        {
            self.timeSheetsTableView.showsInfiniteScrolling = NO;
        }
        else
        {
            self.timeSheetsTableView.showsInfiniteScrolling = NO;
            self.timeSheetsTableView.showsInfiniteScrolling = YES;
        }
    }
    [self changeTableviewInset];
}

/************************************************************************************************************
 @Function Name   : checkToShowMoreButton
 @Purpose         : To animate tableview with new records requested through more action
 @param           : (NSNotification*)notification
 @return          : nil
 *************************************************************************************************************/






-(void)showMessageLabel
{
    if (!self.timesheetService.didSuccessfullyFetchTimesheets)
    {
        [self.msgLabel removeFromSuperview];
        return;
    }

    if ([self.timeSheetsArray count]>0)
    {
        [self.msgLabel removeFromSuperview];
    }
    else
    {
        [self.msgLabel removeFromSuperview];
        UILabel *tempMsgLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, HeightOfNoTSMsgLabel)];
        tempMsgLabel.text=RPLocalizedString(_NO_TIMESHEETS_AVAILABLE, _NO_TIMESHEETS_AVAILABLE);
        self.msgLabel=tempMsgLabel;
        self.msgLabel.backgroundColor=[UIColor clearColor];
        self.msgLabel.numberOfLines=3;
        self.msgLabel.textAlignment=NSTextAlignmentCenter;
        self.msgLabel.font=[UIFont fontWithName:RepliconFontFamily size:16];

        [self.view addSubview:self.msgLabel];
    }
}

-(void)actionsAfterRefresh
{
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    [self.view setUserInteractionEnabled:YES];
    [self.timeSheetsTableView.pullToRefreshView stopAnimating];

    [self checkToShowMoreButton];
    self.timeSheetsArray=[self displayAllTimeSheets];
    [self.timeSheetsTableView reloadData];
    [self showMessageLabel];
}

- (void) dealloc
{
    self.timeSheetsTableView.delegate = nil;
    self.timeSheetsTableView.dataSource = nil;
}

- (void)launchCurrentTimeSheet{
    self.isFromDeepLink = YES;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    if([self.timeSheetsTableView cellForRowAtIndexPath:indexPath]){
        [self selectCurrentTimeSheet];
    }
}

- (void)selectCurrentTimeSheet{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.timeSheetsTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self tableView:self.timeSheetsTableView didSelectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.isFromDeepLink && indexPath.section == 0 && indexPath.row == 0){
        [self selectCurrentTimeSheet];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.isFromDeepLink = NO;
}
@end
