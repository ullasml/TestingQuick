
#import "TimesheetMainPageController.h"
#import "Util.h"
#import "Constants.h"
#import "TimesheetEntryObject.h"
#import "TimesheetObject.h"
#import "EntryCellDetails.h"
#import "RepliconServiceManager.h"
#import "CurrentTimesheetViewController.h"
#import "TimeEntryViewController.h"
#import "LoginModel.h"
#import "TimesheetModel.h"
#import "ApprovalsScrollViewController.h"
#import "PunchEntryViewController.h"
#import "TimeOffDetailsViewController.h"
#import "BookedTimeOffEntry.h"
#import "TimesheetNavigationController.h"
#import "ExpensesNavigationController.h"
#import "BookedTimeOffNavigationController.h"
#import "AttendanceNavigationController.h"
#import "PunchHistoryNavigationController.h"
#import "ShiftsNavigationController.h"
#import "ApprovalsNavigationController.h"
#import "TeamTimeNavigationController.h"
#import "ListOfTimeSheetsViewController.h"
#import "ListOfExpenseSheetsViewController.h"
#import "ListOfBookedTimeOffViewController.h"
#import "AttendanceViewController.h"
#import "TeamTimeViewController.h"
#import "ShiftsViewController.h"
#import "ApprovalsCountViewController.h"
#import "MoreViewController.h"
#import "ResponseHandler.h"
#import "TimesheetSyncOperationManager.h"
#import "SupervisorDashboardNavigationController.h"
#import "OEFObject.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "DailyWidgetDayLevelViewController.h"
#import <repliconkit/repliconkit.h>
#import "UIView+Additions.h"


@interface TimesheetMainPageController ()

@property (nonatomic)AppConfig *appConfig;

@end

@implementation TimesheetMainPageController
@synthesize hasUserChangedAnyValue;
@synthesize scrollView;
@synthesize tsEntryDataArray;
@synthesize pageControl;
@synthesize dayViewController;
@synthesize currentlySelectedPage;
@synthesize viewControllers;
@synthesize delegate;
@synthesize timesheetDataArray;
@synthesize isFirstTimeLoad;
@synthesize isMultiDayInOutTimesheetUser;
@synthesize multiDayInOutViewController;
@synthesize rightBarButton;
@synthesize dbTimeEntriesArray;
@synthesize timesheetURI;
@synthesize parentDelegate;
@synthesize timesheetStatus;
@synthesize overlayView;
@synthesize customPickerView;
@synthesize selectedAdhocTimeoffName;
@synthesize selectedAdhocTimeoffUri;
@synthesize sheetLevelUdfArray;
@synthesize isDisclaimerRequired;
@synthesize isDeleteTimeEntry_AdHoc_RequestInQueue;
@synthesize multiDayInOutType;
@synthesize daySelectionScrollView;
@synthesize daySelectionScrollViewDelegate;
@synthesize indexPathForFirstResponder,isAddTimeEntryClicked,isEditForGen4InQueue;
@synthesize rowLevelArray,previouslySelectedPage;//Implementation for US9371//JUHI
@synthesize isAutoSaveInQueue;
@synthesize isExplicitSaveRequested;
@synthesize timesheetStartDate;
@synthesize timesheetEndDate;
@synthesize userUri;
@synthesize trackTimeEntryChangeDelegate;

#define Intial_InOutRows_Count 2
#define Page_Control_View_Height 50.0f

- (void)loadViewWhenDataReceived
{
    CGFloat width = CGRectGetWidth(self.view.bounds);

    if (self.tsEntryDataArray.count>0)
    {
        if (self.tsEntryDataArray.count>0)
        {
           [Util setToolbarLabel:self withText:[NSString stringWithFormat:@"%@", [[self.tsEntryDataArray objectAtIndex:currentlySelectedPage] entryDateWithDesiredFormat]]];
        }

    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:NO];
        });


    }

    self.isFirstTimeLoad = YES;

    [self createNavigationBarButton];

    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < [tsEntryDataArray count]; i++)
    {
        [controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;

    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(self.tsEntryDataArray.count * CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.scrollEnabled = NO;
    scrollView.delegate = self;
    scrollView.backgroundColor = [Util colorWithHex:@"#f8f8f8" alpha:1];
    [self.view addSubview:scrollView];

    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, width, Page_Control_View_Height)];
    self.pageControl.currentPage = currentlySelectedPage;
    self.pageControl.numberOfPages = self.tsEntryDataArray.count;
    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.hidden = YES;
    pageControl.backgroundColor = [Util colorWithHex:@"#333333" alpha:1.0];
    [pageControl addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pageControl];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];

    
     [self addNextView];
    
    [self.pageControl setHidden:YES];


    NSString *approvalsModuleName = nil;

    if ([self.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [parentDelegate isKindOfClass:[ApprovalsScrollViewController class]] || [self.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]] || [parentDelegate isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)parentDelegate;
//TODO:Commenting below line because variable is unused,uncomment when using
//        ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            approvalsModuleName = APPROVALS_PENDING_TIMESHEETS_MODULE;

        }
        else
        {
            approvalsModuleName = APPROVALS_PREVIOUS_TIMESHEETS_MODULE;
        }
    }

    self.daySelectionScrollView = [[DaySelectionScrollView alloc] initWithFrame:CGRectMake(0, 0, width, Page_Control_View_Height)
                                                             andWithTsDataArray:self.tsEntryDataArray
                                                       withCurrentlySelectedDay:currentlySelectedPage
                                                                   withDelegate:self withTimesheetUri:self.timesheetURI  approvalsModuleName:approvalsModuleName];

    self.daySelectionScrollViewDelegate = (id)daySelectionScrollView;
    [self.view addSubview:daySelectionScrollView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    self.appConfig = [appDelegate.injector getInstance:[AppConfig class]];
    
    self.isTimesheetSaveDone=NO;
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.view setBackgroundColor:[Util colorWithHex:@"#f8f8f8" alpha:1]];
    if ([self.tsEntryDataArray count]>0)
    {
        if ([parentDelegate isKindOfClass:[CurrentTimesheetViewController class]]||
            [parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
            {
                BOOL isGen4Timesheet=NO;
                NSString *timesheetFormat=nil;
                NSArray *array=nil;
                ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)parentDelegate;
                ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
                NSMutableArray *dbTimesheetSummaryArray=nil;
                if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                {
                    dbTimesheetSummaryArray = [approvalsModel getAllPendingTimesheetDaySummaryFromDBForTimesheet:timesheetURI];
                    array=[approvalsModel getTimeSheetInfoSheetIdentityForPending:timesheetURI];

                }
                else
                {
                    dbTimesheetSummaryArray = [approvalsModel getAllPreviousTimesheetDaySummaryFromDBForTimesheet:timesheetURI];
                    array=[approvalsModel getTimeSheetInfoSheetIdentityForPrevious:timesheetURI];
                }


                if ([array count]>0) {

                    if ([(NSMutableArray *)[array objectAtIndex:0] count]>0)
                    {
                        timesheetFormat=[[array objectAtIndex:0] objectForKey:@"timesheetFormat"];
                        if (timesheetFormat!=nil &&![timesheetFormat isKindOfClass:[NSNull class]])
                        {
                            if([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET] ||  [timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                            {
                                isGen4Timesheet=YES;
                            }
                        }
                    }

                }

                if ([dbTimesheetSummaryArray count]==0||!isGen4Timesheet) {
                    [self loadViewWhenDataReceived];
                }
            }
            else{
                [self loadViewWhenDataReceived];
            }

        }

    }
    else
    {
        TimesheetModel *tsModel=[[TimesheetModel alloc]init];
        NSArray *timesheetInfoArray=[tsModel getTimeSheetInfoSheetIdentity:timesheetURI];
        if ([timesheetInfoArray count]>0)
        {
            NSDictionary *tsDict=[timesheetInfoArray objectAtIndex:0];
            NSString *startDateStr=[tsDict objectForKey:@"startDate"];
            NSDate *startDate=[Util convertTimestampFromDBToDate:startDateStr];
            NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];

            NSLocale *locale=[NSLocale currentLocale];
            [myDateFormatter setLocale:locale];
            [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            myDateFormatter.dateFormat = @"EEE, MMM dd";
            [Util setToolbarLabel: self withText:[NSString stringWithFormat:@"%@",[myDateFormatter stringFromDate:startDate]]];
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
        }
    }
}

-(void)addNextView
{
    NSMutableArray *tempDataArray=[[NSMutableArray alloc]init];
    self.timesheetDataArray=tempDataArray;


    if (self.isMultiDayInOutTimesheetUser)
    {
        NSMutableArray *allEntryDatesArray=[NSMutableArray array];
        NSMutableArray *availableEntryDatesArray=[NSMutableArray array];
        for (int i=0; i<[tsEntryDataArray count]; i++)
        {

            NSString *dateString = [[tsEntryDataArray objectAtIndex:i] entryDate];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

            NSLocale *locale=[NSLocale currentLocale];
            [dateFormatter setLocale:locale];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [dateFormatter setDateFormat:@"EEEE, dd MMM yyyy"];
            NSDate *date = [dateFormatter dateFromString:dateString];
            [allEntryDatesArray addObject:date];

        }
        BOOL exit = NO;
        for (int i=0; i<[dbTimeEntriesArray count]; i++)
        {

            NSMutableArray *arrayOfEntries=[dbTimeEntriesArray objectAtIndex:i];
            if ([arrayOfEntries count]>0)
            {
                if ([[arrayOfEntries objectAtIndex:0] isKindOfClass:[NSArray class]])
                {
                    exit = YES;
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    break;
                }

                NSDate *tmpDate = [Util convertTimestampFromDBToDate:[[[arrayOfEntries objectAtIndex:0] objectForKey:@"timesheetEntryDate"] stringValue]];

                NSCalendar *gregorian=[NSCalendar currentCalendar];
                [gregorian setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                NSUInteger flags = ( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay );
                NSDate * date = [gregorian dateFromComponents:[gregorian components:flags fromDate:tmpDate]];
                [availableEntryDatesArray addObject:date];
            }

        }
        BOOL isGen4Timesheet=NO;
        NSArray *array=nil;
        NSString *timesheetFormat=nil;
        if ([self.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [parentDelegate isKindOfClass:[ApprovalsScrollViewController class]] || [self.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]] || [parentDelegate isKindOfClass:[SupervisorDashboardNavigationController class]])
        {
            ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)parentDelegate;
            ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
            if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                array=[approvalsModel getTimeSheetInfoSheetIdentityForPending:timesheetURI];

            }
            else
            {
                array=[approvalsModel getTimeSheetInfoSheetIdentityForPrevious:timesheetURI];
            }
        }
        else
        {
            TimesheetModel *tsModel=[[TimesheetModel alloc]init];
            array=[tsModel getTimeSheetInfoSheetIdentity:timesheetURI];


        }
        if ([array count]>0) {

            if ([(NSMutableArray *)[array objectAtIndex:0] count]>0)
            {
               timesheetFormat=[[array objectAtIndex:0] objectForKey:@"timesheetFormat"];
                if (timesheetFormat!=nil &&![timesheetFormat isKindOfClass:[NSNull class]])
                {
                    if (([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET] ||  [timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET]))
                    {
                        isGen4Timesheet=YES;
                    }
                }

            }

        }
        for (int i=0; i<[tsEntryDataArray count]; i++)
        {
            NSMutableArray *temptimesheetEntryDataArray=[[NSMutableArray alloc]init];
            NSString *dateString = [[tsEntryDataArray objectAtIndex:i] entryDate];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

            NSLocale *locale=[NSLocale currentLocale];
            [dateFormatter setLocale:locale];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [dateFormatter setDateFormat:@"EEEE, dd MMM yyyy"];
            NSDate *date = [dateFormatter dateFromString:dateString];

            BOOL isProjectAccess=FALSE;
            BOOL isActivityAccess=FALSE;
            BOOL isBreakAccess=FALSE;

            if ([availableEntryDatesArray containsObject:date ])
            {
                BOOL isAtleastOneTimeInOutPresent=NO;
                NSUInteger index=[availableEntryDatesArray indexOfObject:date];
                NSArray *array=[dbTimeEntriesArray objectAtIndex:index];
                for (int m=0; m<[array count]; m++)
                {

                    NSMutableDictionary *dict=[array objectAtIndex:m];
                    NSString *timesheetEntryDate=[dict objectForKey:@"timesheetEntryDate"];
                    NSString *timePunchesUri=[dict objectForKey:@"timePunchesUri"];
                    NSString *timeAllocationUri=[dict objectForKey:@"timeAllocationUri"];
                    NSString *activityName=[dict objectForKey:@"activityName"];
                    NSString *activityUri=[dict objectForKey:@"activityUri"];
                    NSString *billingName=[dict objectForKey:@"billingName"];
                    NSString *billingUri=[dict objectForKey:@"billingUri"];
                    NSString *projectName=[dict objectForKey:@"projectName"];
                    NSString *projectUri=[dict objectForKey:@"projectUri"];
                    NSString *clientName=[dict objectForKey:@"clientName"];
                    NSString *clientUri=[dict objectForKey:@"clientUri"];
                    //MOBI-746
                    NSString *programName=[dict objectForKey:@"programName"];
                    NSString *programUri=[dict objectForKey:@"programUri"];
                    NSString *taskName=[dict objectForKey:@"taskName"];
                    NSString *taskUri=[dict objectForKey:@"taskUri"];
                    NSString *timeOffName=[dict objectForKey:@"timeOffTypeName"];
                    NSString *timeOffUri=[dict objectForKey:@"timeOffUri"];
                    NSString *entryType=[dict objectForKey:@"entryType"];
                    NSString *comments=[dict objectForKey:@"comments"];
                    NSString *durationHourFormat=[dict objectForKey:@"durationHourFormat"];

                    NSString *tempTime_in=[dict objectForKey:@"time_in"];
                    NSString *temp_Time_out=[dict objectForKey:@"time_out"];
                    NSString *time_in=[dict objectForKey:@"time_in"];
                    NSString *time_out=[dict objectForKey:@"time_out"];
                    NSString *rowUri=[dict objectForKey:@"rowUri"];
                    //Implentation for US8956//JUHI
                    NSString *breakName=[dict objectForKey:@"breakName"];
                    NSString *breakUri=[dict objectForKey:@"breakUri"];
                    NSString *rowNumber=[dict objectForKey:@"rowNumber"];

                    if (tempTime_in != (id)[NSNull null])
                    {
                        NSArray *timeInCompsArr=[tempTime_in componentsSeparatedByString:@":"];
                        if ([timeInCompsArr count]==3)
                        {
                            NSString *hrsMinsStr=[NSString stringWithFormat:@"%@:%@",[timeInCompsArr objectAtIndex:0],[timeInCompsArr objectAtIndex:1]];
                            NSArray *amPmCompsArr=[[timeInCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
                            if ([amPmCompsArr count]==2)
                            {
                                time_in=[NSString stringWithFormat:@"%@ %@",hrsMinsStr,[amPmCompsArr objectAtIndex:1]];
                            }
                        }
                    }

                    BOOL isMidnightCrossover=FALSE;
                    if (temp_Time_out != (id)[NSNull null])
                    {
                        NSArray *timeOutCompsArr=[temp_Time_out componentsSeparatedByString:@":"];
                        if ([timeOutCompsArr count]==3)
                        {
                            NSString *hrsMinsStr=[NSString stringWithFormat:@"%@:%@",[timeOutCompsArr objectAtIndex:0],[timeOutCompsArr objectAtIndex:1]];
                            NSArray *amPmCompsArr=[[timeOutCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
                            if ([amPmCompsArr count]==2)
                            {
                                time_out=[NSString stringWithFormat:@"%@ %@",hrsMinsStr,[amPmCompsArr objectAtIndex:1]];
                                if ([amPmCompsArr[0]isEqualToString:@"59"] && [hrsMinsStr isEqualToString:@"11:59"] && ([amPmCompsArr[1]isEqualToString:@"PM"] || [amPmCompsArr[1]isEqualToString:@"pm"]))
                                {
                                    isMidnightCrossover=TRUE;
                                }
                            }
                        }
                    }

                    TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc] init];
                    NSMutableDictionary *multiDayInOutDict=[NSMutableDictionary dictionary];
                    NSDate *timentryDate=[Util convertTimestampFromDBToDate:timesheetEntryDate];

                    if (time_in!=nil && ![time_in isKindOfClass:[NSNull class]])
                        [multiDayInOutDict setObject:[time_in lowercaseString] forKey:@"in_time"];
                    else
                        [multiDayInOutDict setObject:@"" forKey:@"in_time"];

                    if (time_out!=nil && ![time_out isKindOfClass:[NSNull class]])
                        [multiDayInOutDict setObject:[time_out lowercaseString] forKey:@"out_time"];
                    else
                        [multiDayInOutDict setObject:@"" forKey:@"out_time"];

                    if (isMidnightCrossover)
                    {
                        [multiDayInOutDict setObject:[NSNumber numberWithBool:YES] forKey:@"isMidnightCrossover"];
                    }

                    NSMutableArray *udfArray=[[NSMutableArray alloc]init];
                    NSMutableArray *tempCustomFieldArray=nil;

                    if (timeOffName!=nil && (![timeOffName isKindOfClass:[NSNull class]] && ![timeOffName isEqualToString:@""]))
                    {
                        if ([entryType isEqualToString:Time_Off_Key])
                        {
                            [tsEntryObject setEntryType:Time_Off_Key];
                            [tsEntryObject setTimeEntryTimeOffRowUri:rowUri];
                        }
                        else
                        {
                            [tsEntryObject setEntryType:Adhoc_Time_OffKey];
                        }


                        tempCustomFieldArray=[self getUDFArrayForModuleName:TIMEOFF_UDF andEntryDate:timentryDate andEntryType:entryType andRowUri:timeAllocationUri isRowEditable:YES];
                        for (int i=0; i<[tempCustomFieldArray count]; i++)
                        {
                            NSDictionary *udfDict = [tempCustomFieldArray objectAtIndex: i];
                            NSString *udfType=[udfDict objectForKey:@"type"];
                            NSString *udfName=[udfDict objectForKey:@"name"];
                            NSString *udfUri=[udfDict objectForKey:@"uri"];

                            if ([udfType isEqualToString:TEXT_UDF_TYPE])
                            {
                                NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                [udfDetails setSystemDefaultValue:systemDefaultValue];
                                [udfDetails setFieldName:udfName];
                                [udfDetails setFieldType:UDFType_TEXT];
                                [udfDetails setFieldValue:defaultValue];
                                [udfDetails setUdfIdentity:udfUri];
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
                                int defaultDecimalValue=[[udfDict objectForKey:@"defaultDecimalValue"] intValue];
                                EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                [udfDetails setSystemDefaultValue:systemDefaultValue];
                                [udfDetails setFieldName:udfName];
                                [udfDetails setFieldType:UDFType_NUMERIC];
                                [udfDetails setFieldValue:defaultValue];
                                [udfDetails setUdfIdentity:udfUri];
                                [udfDetails setDecimalPoints:defaultDecimalValue];
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
                                else{//Implemented for US8763_HandleWhenDateUDFDoesNotHaveDefaultValue//JUHI
                                    if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]) {
                                        defaultValue=RPLocalizedString(SELECT_STRING, @"");
                                    }
                                    else{
                                        NSDate *date=(NSDate *)[udfDict objectForKey:@"defaultValue"];
                                        defaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:date]];
                                    }

                                }
                                id systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                if ([systemDefaultValue isKindOfClass:[NSDate class]])
                                {
                                    systemDefaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:systemDefaultValue]];
                                }
                                EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                [udfDetails setSystemDefaultValue:systemDefaultValue];
                                [udfDetails setFieldName:udfName];
                                [udfDetails setFieldType:UDFType_DATE];
                                [udfDetails setFieldValue:defaultValue];
                                [udfDetails setUdfIdentity:udfUri];
                                [udfArray addObject:udfDetails];


                                ;
                            }
                            else if([udfType isEqualToString:DROPDOWN_UDF_TYPE])
                            {
                                NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                NSString *dropDownOptionUri=[udfDict objectForKey:@"dropDownOptionUri"];
                                EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                [udfDetails setSystemDefaultValue:systemDefaultValue];
                                [udfDetails setFieldName:udfName];
                                [udfDetails setFieldType:UDFType_DROPDOWN];
                                [udfDetails setFieldValue:defaultValue];
                                [udfDetails setUdfIdentity:udfUri];
                                [udfDetails setDropdownOptionUri:dropDownOptionUri];
                                [udfArray addObject:udfDetails];

                            }




                        }
                        if (time_in==nil||[time_in isKindOfClass:[NSNull class]]||time_out==nil||[time_out isKindOfClass:[NSNull class]])
                        {
                            if (multiDayInOutType==EXTENDED_IN_OUT_TIMESHEET_TYPE)
                            {
                                NSString *key=nil;
                               

                                if ([self.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [parentDelegate isKindOfClass:[ApprovalsScrollViewController class]] || [self.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]] || [parentDelegate isKindOfClass:[SupervisorDashboardNavigationController class]])
                                {
                                    ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)parentDelegate;
                                    ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
                                    if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                                    {

                                        isProjectAccess=[approvalsModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:self.timesheetURI];
                                        isActivityAccess=[approvalsModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:self.timesheetURI];
                                        isBreakAccess=[approvalsModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBreakAccess" forSheetUri:self.timesheetURI];
                                    }
                                    else
                                    {
                                        isProjectAccess=[approvalsModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:tsEntryObject.timesheetUri];
                                        isActivityAccess=[approvalsModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:self.timesheetURI];
                                        isBreakAccess=[approvalsModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBreakAccess" forSheetUri:self.timesheetURI];


                                    }

                                    if (isGen4Timesheet) {
                                        SupportDataModel *supportModel=[[SupportDataModel alloc]init];
                                        NSDictionary *dict=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
                                        if (timesheetFormat!=nil &&![timesheetFormat isKindOfClass:[NSNull class]])
                                        {
                                            if([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET])
                                            {
                                                isBreakAccess=[[dict objectForKey:@"allowBreakForInOutGen4"] boolValue];
                                            }
                                            else if([timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                                            {
                                                isProjectAccess=[[dict objectForKey:@"allowProjectsTasksForExtInOutGen4"] boolValue];
                                                isActivityAccess=[[dict objectForKey:@"allowActivitiesForExtInOutGen4"] boolValue];
                                                isBreakAccess=[[dict objectForKey:@"allowBreakForExtInOutGen4"] boolValue];
                                            }
                                            else if([timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                                            {
                                                isBreakAccess=[[dict objectForKey:@"allowBreakForStandardGen4"] boolValue];
                                            }
                                        }

                                    }


                                }
                                else
                                {
                                    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                                    isProjectAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetURI];
                                    isActivityAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetURI];
                                    isBreakAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBreakAccess" forSheetUri:timesheetURI];
                                    if (isGen4Timesheet) {
                                        SupportDataModel *supportModel=[[SupportDataModel alloc]init];
                                        NSDictionary *dict=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
                                        if (timesheetFormat!=nil &&![timesheetFormat isKindOfClass:[NSNull class]])
                                        {
                                            if([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET])
                                            {
                                                isBreakAccess=[[dict objectForKey:@"allowBreakForInOutGen4"] boolValue];
                                            }
                                            else if([timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                                            {
                                                isProjectAccess=[[dict objectForKey:@"allowProjectsTasksForExtInOutGen4"] boolValue];
                                                isActivityAccess=[[dict objectForKey:@"allowActivitiesForExtInOutGen4"] boolValue];
                                                isBreakAccess=[[dict objectForKey:@"allowBreakForExtInOutGen4"] boolValue];
                                            }
                                            else if([timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                                            {
                                                isBreakAccess=[[dict objectForKey:@"allowBreakForStandardGen4"] boolValue];
                                            }
                                        }

                                       
                                    }
                                }



                                if (isProjectAccess)
                                {//Implemented as per TIME-495//JUHI
                                    if (projectUri!=nil && ![projectUri isKindOfClass:[NSNull class]])
                                    {
                                        key=projectUri;
                                    }
                                    else
                                        key=@"";


                                }
                                else if (isActivityAccess)
                                {//Implemented as per TIME-495//JUHI
                                    if (activityUri!=nil && ![activityUri isKindOfClass:[NSNull class]])
                                    {
                                        key=activityUri;
                                    }
                                    else
                                        key=@"";


                                }
                                else if (isBreakAccess)
                                {//Implemented as per TIME-495//JUHI
                                    if (breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]])
                                    {
                                        key=breakUri;
                                    }
                                    else
                                        key=@"";

                                }
                                else
                                {
                                    key=@"";
                                }
                                NSMutableArray *timePunchesArr=[dict objectForKey:key];
                                if (isGen4Timesheet) {
                                    if (key==nil ||[key isKindOfClass:[NSNull class]]||[key isEqualToString:@""]) {
                                        timePunchesArr=[dict objectForKey:[NSNull null]];
                                    }
                                }
                                double totalHours=0;
                                double w_o_RoundedTotalHours=0;

                                for (int count=0; count<[timePunchesArr count]; count++)
                                {
                                    NSMutableDictionary *formattedTimePunchesDict=[NSMutableDictionary dictionary];
                                    NSDictionary *punchDict=[timePunchesArr objectAtIndex:count];

                                    NSString *inTime=nil;
                                    NSString *outTime=nil;


                                    NSString *tempTime_in=[punchDict objectForKey:@"in_time"];
                                    NSString *temp_Time_out=[punchDict objectForKey:@"out_time"];
                                    NSString *time_in=[punchDict objectForKey:@"in_time"];
                                    NSString *time_out=[punchDict objectForKey:@"out_time"];
                                    //NSString *timePunchesUri=[punchDict objectForKey:@"timePunchesUri"];
                                    NSString *clientPunchID=[punchDict objectForKey:@"clientPunchId"];

                                    NSArray *timeInCompsArr=[tempTime_in componentsSeparatedByString:@":"];
                                    if ([timeInCompsArr count]==3)
                                    {
                                        NSString *hrsMinsStr=[NSString stringWithFormat:@"%@:%@",[timeInCompsArr objectAtIndex:0],[timeInCompsArr objectAtIndex:1]];
                                        NSArray *amPmCompsArr=[[timeInCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
                                        if ([amPmCompsArr count]==2)
                                        {
                                            time_in=[NSString stringWithFormat:@"%@ %@",hrsMinsStr,[amPmCompsArr objectAtIndex:1]];
                                        }
                                    }

                                    NSArray *timeOutCompsArr=[temp_Time_out componentsSeparatedByString:@":"];
                                    if ([timeOutCompsArr count]==3)
                                    {
                                        NSString *hrsMinsStr=[NSString stringWithFormat:@"%@:%@",[timeOutCompsArr objectAtIndex:0],[timeOutCompsArr objectAtIndex:1]];
                                        NSArray *amPmCompsArr=[[timeOutCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
                                        if ([amPmCompsArr count]==2)
                                        {
                                            time_out=[NSString stringWithFormat:@"%@ %@",hrsMinsStr,[amPmCompsArr objectAtIndex:1]];
                                        }
                                    }





                                    if (time_in!=nil && ![time_in isKindOfClass:[NSNull class]])
                                        inTime=[time_in lowercaseString];
                                    else
                                        inTime=@"";

                                    if (time_out!=nil && ![time_out isKindOfClass:[NSNull class]])
                                        outTime=[time_out lowercaseString];
                                    else
                                        outTime=@"";



                                    if (time_in!=nil && ![time_in isKindOfClass:[NSNull class]] &&![time_in isEqualToString:@""] && time_out!=nil && ![time_out isKindOfClass:[NSNull class]]&&![time_out isEqualToString:@""])
                                    {
                                        totalHours=totalHours+[[Util getNumberOfHoursForInTime:tempTime_in outTime:temp_Time_out]newDoubleValue];
                                        w_o_RoundedTotalHours=w_o_RoundedTotalHours+[[Util getNumberOfHoursWithoutRoundingForInTime:tempTime_in outTime:temp_Time_out]newDoubleValue];
                                    }

                                    NSString *tempComments=[punchDict objectForKey:@"comments"];
                                    if (tempComments==nil ||[tempComments isKindOfClass:[NSNull class]]||[tempComments isEqualToString:@""])
                                    {
                                        tempComments=@"";
                                    }
                                    NSString *timePunchesUri=[punchDict objectForKey:@"timePunchesUri"];
                                    [formattedTimePunchesDict setObject:tempComments forKey:@"comments"];
                                    [formattedTimePunchesDict setObject:inTime forKey:@"in_time"];
                                    [formattedTimePunchesDict setObject:outTime forKey:@"out_time"];
                                    [formattedTimePunchesDict setObject:udfArray forKey:@"udfArray"];
                                    [formattedTimePunchesDict setObject:timePunchesUri forKey:@"timePunchesUri"];
                                    if (clientPunchID!=nil && ![clientPunchID isKindOfClass:[NSNull class]])
                                    {
                                        [formattedTimePunchesDict setObject:clientPunchID forKey:@"clientID"];
                                    }

                                    [timePunchesArr replaceObjectAtIndex:count withObject:formattedTimePunchesDict];


                                }
                                if (timesheetFormat!=nil &&![timesheetFormat isKindOfClass:[NSNull class]])
                                {
                                    if([timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                                    {
                                        [tsEntryObject setTimeEntryCellOEFArray:[self constructCellOEFObjectForTimeSheetUri:self.timesheetURI andtimesheetFormat:timesheetFormat andOEFLevel:TIMESHEET_CELL_OEF andTimePunchUri:timePunchesUri]];

                                        if (isProjectAccess || isActivityAccess)
                                        {
                                            for (NSDictionary *punchDict in timePunchesArr)
                                            {
                                                NSString *timePunchesUri=[punchDict objectForKey:@"timePunchesUri"];
                                                if (timePunchesUri==nil || [timePunchesUri isKindOfClass:[NSNull class]] || [timePunchesUri isEqualToString:@""])
                                                {
                                                    [timePunchesArr removeObject:punchDict];
                                                }
                                            }
                                            
                                        }
                                        
                                        
                                    }
                                }


                                [tsEntryObject setTimePunchesArray:timePunchesArr];
                                [tsEntryObject setTimeEntryHoursInDecimalFormat:[NSString stringWithFormat:@"%f",totalHours]];
                                [tsEntryObject setTimeEntryHoursInDecimalFormatWithOutRoundOff:[NSString stringWithFormat:@"%f",w_o_RoundedTotalHours]];


                            }

                        }
                        else
                        {
                            if (multiDayInOutType==EXTENDED_IN_OUT_TIMESHEET_TYPE)
                            {
                                NSString *key=nil;

                                if ([self.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [parentDelegate isKindOfClass:[ApprovalsScrollViewController class]] || [self.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]] || [parentDelegate isKindOfClass:[SupervisorDashboardNavigationController class]])
                                {
                                    ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)parentDelegate;
                                    ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
                                    if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                                    {

                                        isProjectAccess=[approvalsModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:self.timesheetURI];
                                        isActivityAccess=[approvalsModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:self.timesheetURI];
                                        isBreakAccess=[approvalsModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBreakAccess" forSheetUri:self.timesheetURI];
                                    }
                                    else
                                    {
                                        isProjectAccess=[approvalsModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:self.timesheetURI];
                                        isActivityAccess=[approvalsModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:self.timesheetURI];
                                        isBreakAccess=[approvalsModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBreakAccess" forSheetUri:self.timesheetURI];


                                    }

                                    if (isGen4Timesheet) {
                                        SupportDataModel *supportModel=[[SupportDataModel alloc]init];
                                        NSDictionary *dict=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
                                        if (timesheetFormat!=nil &&![timesheetFormat isKindOfClass:[NSNull class]])
                                        {
                                            if([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET])
                                            {
                                                isBreakAccess=[[dict objectForKey:@"allowBreakForInOutGen4"] boolValue];
                                            }
                                            else if([timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                                            {
                                                isProjectAccess=[[dict objectForKey:@"allowProjectsTasksForExtInOutGen4"] boolValue];
                                                isActivityAccess=[[dict objectForKey:@"allowActivitiesForExtInOutGen4"] boolValue];
                                                isBreakAccess=[[dict objectForKey:@"allowBreakForExtInOutGen4"] boolValue];
                                            }
                                            else if([timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                                            {
                                                isBreakAccess=[[dict objectForKey:@"allowBreakForStandardGen4"] boolValue];
                                            }
                                        }

                                    }


                                }
                                else
                                {
                                    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                                    isProjectAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetURI];
                                    isActivityAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetURI];
                                    isBreakAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBreakAccess" forSheetUri:timesheetURI];
                                    if (isGen4Timesheet) {
                                        SupportDataModel *supportModel=[[SupportDataModel alloc]init];
                                        NSDictionary *dict=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
                                        if (timesheetFormat!=nil &&![timesheetFormat isKindOfClass:[NSNull class]])
                                        {
                                            if([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET])
                                            {
                                                isBreakAccess=[[dict objectForKey:@"allowBreakForInOutGen4"] boolValue];
                                            }
                                            else if([timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                                            {
                                                isProjectAccess=[[dict objectForKey:@"allowProjectsTasksForExtInOutGen4"] boolValue];
                                                isActivityAccess=[[dict objectForKey:@"allowActivitiesForExtInOutGen4"] boolValue];
                                                isBreakAccess=[[dict objectForKey:@"allowBreakForExtInOutGen4"] boolValue];
                                            }
                                            else if([timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                                            {
                                                isBreakAccess=[[dict objectForKey:@"allowBreakForStandardGen4"] boolValue];
                                            }
                                        }

                                    }

                                }



                                if (isProjectAccess)
                                {//Implemented as per TIME-495//JUHI
                                    if (projectUri!=nil && ![projectUri isKindOfClass:[NSNull class]])
                                    {
                                        key=projectUri;
                                    }
                                    else
                                        key=@"";


                                }
                                else if (isActivityAccess)
                                {//Implemented as per TIME-495//JUHI
                                    if (activityUri!=nil && ![activityUri isKindOfClass:[NSNull class]])
                                    {
                                        key=activityUri;
                                    }
                                    else
                                        key=@"";


                                }
                                else if (isBreakAccess)
                                {//Implemented as per TIME-495//JUHI
                                    if (breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]])
                                    {
                                        key=breakUri;
                                    }
                                    else
                                        key=@"";

                                }
                                else
                                {
                                    key=@"";
                                }

                                NSMutableArray *timePunchesArr=[dict objectForKey:key];
                                if (isGen4Timesheet) {
                                    if (key==nil ||[key isKindOfClass:[NSNull class]]||[key isEqualToString:@""]) {
                                        timePunchesArr=[dict objectForKey:[NSNull null]];
                                    }
                                }
                                double totalHours=0;
                                double w_o_RoundedTotalHours=0;

                                for (int count=0; count<[timePunchesArr count]; count++)
                                {
                                    NSMutableDictionary *formattedTimePunchesDict=[NSMutableDictionary dictionary];
                                    NSDictionary *punchDict=[timePunchesArr objectAtIndex:count];

                                    NSString *inTime=nil;
                                    NSString *outTime=nil;


                                    NSString *tempTime_in=[punchDict objectForKey:@"in_time"];
                                    NSString *temp_Time_out=[punchDict objectForKey:@"out_time"];
                                    NSString *time_in=[punchDict objectForKey:@"in_time"];
                                    NSString *time_out=[punchDict objectForKey:@"out_time"];
                                    //NSString *timePunchesUri=[punchDict objectForKey:@"timePunchesUri"];
                                    NSString *clientPunchID=[punchDict objectForKey:@"clientPunchId"];
                                    NSArray *timeInCompsArr=[tempTime_in componentsSeparatedByString:@":"];
                                    if ([timeInCompsArr count]==3)
                                    {
                                        NSString *hrsMinsStr=[NSString stringWithFormat:@"%@:%@",[timeInCompsArr objectAtIndex:0],[timeInCompsArr objectAtIndex:1]];
                                        NSArray *amPmCompsArr=[[timeInCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
                                        if ([amPmCompsArr count]==2)
                                        {
                                            time_in=[NSString stringWithFormat:@"%@ %@",hrsMinsStr,[amPmCompsArr objectAtIndex:1]];
                                        }
                                    }

                                    NSArray *timeOutCompsArr=[temp_Time_out componentsSeparatedByString:@":"];
                                    if ([timeOutCompsArr count]==3)
                                    {
                                        NSString *hrsMinsStr=[NSString stringWithFormat:@"%@:%@",[timeOutCompsArr objectAtIndex:0],[timeOutCompsArr objectAtIndex:1]];
                                        NSArray *amPmCompsArr=[[timeOutCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
                                        if ([amPmCompsArr count]==2)
                                        {
                                            time_out=[NSString stringWithFormat:@"%@ %@",hrsMinsStr,[amPmCompsArr objectAtIndex:1]];
                                        }
                                    }





                                    if (time_in!=nil && ![time_in isKindOfClass:[NSNull class]])
                                        inTime=[time_in lowercaseString];
                                    else
                                        inTime=@"";

                                    if (time_out!=nil && ![time_out isKindOfClass:[NSNull class]])
                                        outTime=[time_out lowercaseString];
                                    else
                                        outTime=@"";


                                    if (tempTime_in!=nil &&  ![tempTime_in isKindOfClass:[NSNull class]]&&![tempTime_in isEqualToString:@""] &&temp_Time_out!=nil  && ![temp_Time_out isKindOfClass:[NSNull class]]&&![temp_Time_out isEqualToString:@""])
                                    {
                                        totalHours=totalHours+[[Util getNumberOfHoursForInTime:tempTime_in outTime:temp_Time_out]newDoubleValue];
                                        w_o_RoundedTotalHours=w_o_RoundedTotalHours+[[Util getNumberOfHoursWithoutRoundingForInTime:tempTime_in outTime:temp_Time_out]newDoubleValue];
                                    }


                                    NSString *tempComments=[punchDict objectForKey:@"comments"];
                                    if (tempComments==nil ||[tempComments isKindOfClass:[NSNull class]]||[tempComments isEqualToString:@""])
                                    {
                                        tempComments=@"";
                                    }
                                    NSString *timePunchesUri=[punchDict objectForKey:@"timePunchesUri"];
                                    [formattedTimePunchesDict setObject:tempComments forKey:@"comments"];
                                    [formattedTimePunchesDict setObject:inTime forKey:@"in_time"];
                                    [formattedTimePunchesDict setObject:outTime forKey:@"out_time"];
                                    [formattedTimePunchesDict setObject:udfArray forKey:@"udfArray"];
                                    [formattedTimePunchesDict setObject:timePunchesUri forKey:@"timePunchesUri"];
                                    if (clientPunchID!=nil && ![clientPunchID isKindOfClass:[NSNull class]])
                                    {
                                        [formattedTimePunchesDict setObject:clientPunchID forKey:@"clientID"];
                                    }
                                    [timePunchesArr replaceObjectAtIndex:count withObject:formattedTimePunchesDict];


                                }

                                if (timesheetFormat!=nil &&![timesheetFormat isKindOfClass:[NSNull class]])
                                {
                                    if([timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                                    {
                                        [tsEntryObject setTimeEntryCellOEFArray:[self constructCellOEFObjectForTimeSheetUri:self.timesheetURI andtimesheetFormat:timesheetFormat andOEFLevel:TIMESHEET_CELL_OEF andTimePunchUri:timePunchesUri]];

                                        if (isProjectAccess || isActivityAccess)
                                        {
                                            for (NSDictionary *punchDict in timePunchesArr)
                                            {
                                                NSString *timePunchesUri=[punchDict objectForKey:@"timePunchesUri"];
                                                if (timePunchesUri==nil || [timePunchesUri isKindOfClass:[NSNull class]] || [timePunchesUri isEqualToString:@""])
                                                {
                                                    [timePunchesArr removeObject:punchDict];
                                                }
                                            }

                                        }
                                        
                                        
                                    }
                                }

                                [tsEntryObject setTimePunchesArray:timePunchesArr];
                                [tsEntryObject setTimeEntryHoursInDecimalFormat:[NSString stringWithFormat:@"%f",totalHours]];
                                [tsEntryObject setTimeEntryHoursInDecimalFormatWithOutRoundOff:[NSString stringWithFormat:@"%f",w_o_RoundedTotalHours]];



                            }
                            else
                            {
                                [tsEntryObject setTimeEntryHoursInDecimalFormat:[Util getNumberOfHoursForInTime:tempTime_in outTime:temp_Time_out]];
                                [tsEntryObject setTimeEntryHoursInDecimalFormatWithOutRoundOff:[Util getNumberOfHoursWithoutRoundingForInTime:tempTime_in outTime:temp_Time_out]];
                            }


                        }
                        [tsEntryObject setIsTimeoffSickRowPresent:YES];
                        [tsEntryObject setTimeAllocationUri:timeAllocationUri];
                        [tsEntryObject setRowUri:timeAllocationUri];
                        [tsEntryObject setTimeEntryHoursInDecimalFormat:[Util getRoundedValueFromDecimalPlaces: [[dict objectForKey:@"durationDecimalFormat"] doubleValue ]withDecimalPlaces:2 ]];
                        [tsEntryObject setTimeEntryHoursInDecimalFormatWithOutRoundOff:[Util getRoundedValueFromDecimalPlaces: [[dict objectForKey:@"durationDecimalFormat"] doubleValue ]withDecimalPlaces:2 ]];
                    }
                    else
                    {
                        tempCustomFieldArray=[self getUDFArrayForModuleName:TIMESHEET_CELL_UDF andEntryDate:timentryDate andEntryType:entryType andRowUri:timePunchesUri isRowEditable:YES];
                        [tsEntryObject setEntryType:Time_Entry_Key];
                        isAtleastOneTimeInOutPresent=YES;
                        [tsEntryObject setIsTimeoffSickRowPresent:NO];
                        [tsEntryObject setTimePunchUri:timePunchesUri];
                        [tsEntryObject setRowUri:timePunchesUri];

                        if (time_in==nil||[time_in isKindOfClass:[NSNull class]]||time_out==nil||[time_out isKindOfClass:[NSNull class]])
                        {
                            if (multiDayInOutType==EXTENDED_IN_OUT_TIMESHEET_TYPE)
                            {
                                NSString *key=nil;


                                if ([self.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [parentDelegate isKindOfClass:[ApprovalsScrollViewController class]] || [self.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]] || [parentDelegate isKindOfClass:[SupervisorDashboardNavigationController class]])
                                {
                                    ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)parentDelegate;
                                    ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
                                    if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                                    {

                                        isProjectAccess=[approvalsModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:self.timesheetURI];
                                        isActivityAccess=[approvalsModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:self.timesheetURI];
                                        isBreakAccess=[approvalsModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBreakAccess" forSheetUri:self.timesheetURI];

                                    }
                                    else
                                    {
                                        isProjectAccess=[approvalsModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:tsEntryObject.timesheetUri];
                                        isActivityAccess=[approvalsModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:self.timesheetURI];
                                        isBreakAccess=[approvalsModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBreakAccess" forSheetUri:self.timesheetURI];

                                    }

                                    if (isGen4Timesheet) {
                                        SupportDataModel *supportModel=[[SupportDataModel alloc]init];
                                        NSDictionary *dict=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
                                        if (timesheetFormat!=nil &&![timesheetFormat isKindOfClass:[NSNull class]])
                                        {
                                            if([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET])
                                            {
                                                isBreakAccess=[[dict objectForKey:@"allowBreakForInOutGen4"] boolValue];
                                            }
                                            else if([timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                                            {
                                                isProjectAccess=[[dict objectForKey:@"allowProjectsTasksForExtInOutGen4"] boolValue];
                                                isActivityAccess=[[dict objectForKey:@"allowActivitiesForExtInOutGen4"] boolValue];
                                                isBreakAccess=[[dict objectForKey:@"allowBreakForExtInOutGen4"] boolValue];
                                            }
                                            else if([timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                                            {
                                                isBreakAccess=[[dict objectForKey:@"allowBreakForStandardGen4"] boolValue];
                                            }
                                        }

                                    }


                                }
                                else
                                {
                                    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                                    isProjectAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetURI];
                                    isActivityAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetURI];
                                    isBreakAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBreakAccess" forSheetUri:timesheetURI];
                                    if (isGen4Timesheet) {
                                        SupportDataModel *supportModel=[[SupportDataModel alloc]init];
                                        NSDictionary *dict=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
                                        if (timesheetFormat!=nil &&![timesheetFormat isKindOfClass:[NSNull class]])
                                        {
                                            if([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET])
                                            {
                                                isBreakAccess=[[dict objectForKey:@"allowBreakForInOutGen4"] boolValue];
                                            }
                                            else if([timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                                            {
                                                isProjectAccess=[[dict objectForKey:@"allowProjectsTasksForExtInOutGen4"] boolValue];
                                                isActivityAccess=[[dict objectForKey:@"allowActivitiesForExtInOutGen4"] boolValue];
                                                isBreakAccess=[[dict objectForKey:@"allowBreakForExtInOutGen4"] boolValue];
                                            }
                                            else if([timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                                            {
                                                isBreakAccess=[[dict objectForKey:@"allowBreakForStandardGen4"] boolValue];
                                            }
                                        }

                                    }
                                }



                                if (isProjectAccess)
                                {//Implemented as per TIME-495//JUHI
                                    if (projectUri!=nil && ![projectUri isKindOfClass:[NSNull class]])
                                    {
                                        key=projectUri;
                                    }
                                    else
                                        key=@"";


                                }
                                else if (isActivityAccess)
                                {//Implemented as per TIME-495//JUHI
                                    if (activityUri!=nil && ![activityUri isKindOfClass:[NSNull class]])
                                    {
                                        key=activityUri;
                                    }
                                    else
                                        key=@"";


                                }
                                else if (isBreakAccess)
                                {//Implemented as per TIME-495//JUHI
                                    if (breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]])
                                    {
                                        key=breakUri;
                                    }
                                    else
                                        key=@"";

                                }
                                else
                                {
                                    key=@"";
                                }

                                NSMutableArray *timePunchesArr=[dict objectForKey:key];
                                if (isGen4Timesheet) {
                                    if (key==nil ||[key isKindOfClass:[NSNull class]]||[key isEqualToString:@""]) {
                                        timePunchesArr=[dict objectForKey:[NSNull null]];
                                    }
                                }
                                double totalHours=0;
                                double w_o_RoundedTotalHours=0;

                                for (int count=0; count<[timePunchesArr count]; count++)
                                {
                                    NSMutableDictionary *formattedTimePunchesDict=[NSMutableDictionary dictionary];
                                    NSDictionary *punchDict=[timePunchesArr objectAtIndex:count];
                                    tempCustomFieldArray=[self getUDFArrayForModuleName:TIMESHEET_CELL_UDF andEntryDate:timentryDate andEntryType:entryType andRowUri:[punchDict objectForKey:@"timePunchesUri"] isRowEditable:YES];
                                    NSMutableArray *udfArray=[NSMutableArray array];
                                    for (int i=0; i<[tempCustomFieldArray count]; i++)
                                    {
                                        NSDictionary *udfDict = [tempCustomFieldArray objectAtIndex: i];
                                        NSString *udfType=[udfDict objectForKey:@"type"];
                                        NSString *udfName=[udfDict objectForKey:@"name"];
                                        NSString *udfUri=[udfDict objectForKey:@"uri"];

                                        if ([udfType isEqualToString:TEXT_UDF_TYPE])
                                        {
                                            NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                            NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                            EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                            [udfDetails setSystemDefaultValue:systemDefaultValue];
                                            [udfDetails setFieldName:udfName];
                                            [udfDetails setFieldType:UDFType_TEXT];
                                            [udfDetails setFieldValue:defaultValue];
                                            [udfDetails setUdfIdentity:udfUri];
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
                                            int defaultDecimalValue=[[udfDict objectForKey:@"defaultDecimalValue"] intValue];
                                            EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                            [udfDetails setSystemDefaultValue:systemDefaultValue];
                                            [udfDetails setFieldName:udfName];
                                            [udfDetails setFieldType:UDFType_NUMERIC];
                                            [udfDetails setFieldValue:defaultValue];
                                            [udfDetails setUdfIdentity:udfUri];
                                            [udfDetails setDecimalPoints:defaultDecimalValue];
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
                                            else{//Implemented for US8763_HandleWhenDateUDFDoesNotHaveDefaultValue//JUHI
                                                if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]) {
                                                    defaultValue=RPLocalizedString(SELECT_STRING, @"");
                                                }
                                                else{
                                                    NSDate *date=(NSDate *)[udfDict objectForKey:@"defaultValue"];
                                                    defaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:date]];
                                                }

                                            }
                                            id systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                            if ([systemDefaultValue isKindOfClass:[NSDate class]])
                                            {
                                                systemDefaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:systemDefaultValue]];
                                            }
                                            EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                            [udfDetails setSystemDefaultValue:systemDefaultValue];
                                            [udfDetails setFieldName:udfName];
                                            [udfDetails setFieldType:UDFType_DATE];
                                            [udfDetails setFieldValue:defaultValue];
                                            [udfDetails setUdfIdentity:udfUri];
                                            [udfArray addObject:udfDetails];

                                        }
                                        else if([udfType isEqualToString:DROPDOWN_UDF_TYPE])
                                        {
                                            NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                            NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                            NSString *dropDownOptionUri=[udfDict objectForKey:@"dropDownOptionUri"];
                                            EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                            [udfDetails setSystemDefaultValue:systemDefaultValue];
                                            [udfDetails setFieldName:udfName];
                                            [udfDetails setFieldType:UDFType_DROPDOWN];
                                            [udfDetails setFieldValue:defaultValue];
                                            [udfDetails setUdfIdentity:udfUri];
                                            [udfDetails setDropdownOptionUri:dropDownOptionUri];
                                            [udfArray addObject:udfDetails];

                                        }




                                    }
                                    NSString *inTime=nil;
                                    NSString *outTime=nil;


                                    NSString *tempTime_in=[punchDict objectForKey:@"in_time"];
                                    NSString *temp_Time_out=[punchDict objectForKey:@"out_time"];
                                    NSString *time_in=[punchDict objectForKey:@"in_time"];
                                    NSString *time_out=[punchDict objectForKey:@"out_time"];
                                    // NSString *timePunchesUri=[punchDict objectForKey:@"timePunchesUri"];
                                    NSString *clientPunchID=[punchDict objectForKey:@"clientPunchId"];
                                    NSArray *timeInCompsArr=[tempTime_in componentsSeparatedByString:@":"];
                                    if ([timeInCompsArr count]==3)
                                    {
                                        NSString *hrsMinsStr=[NSString stringWithFormat:@"%@:%@",[timeInCompsArr objectAtIndex:0],[timeInCompsArr objectAtIndex:1]];
                                        NSArray *amPmCompsArr=[[timeInCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
                                        if ([amPmCompsArr count]==2)
                                        {
                                            time_in=[NSString stringWithFormat:@"%@ %@",hrsMinsStr,[amPmCompsArr objectAtIndex:1]];
                                        }
                                    }

                                    NSArray *timeOutCompsArr=[temp_Time_out componentsSeparatedByString:@":"];
                                    if ([timeOutCompsArr count]==3)
                                    {
                                        NSString *hrsMinsStr=[NSString stringWithFormat:@"%@:%@",[timeOutCompsArr objectAtIndex:0],[timeOutCompsArr objectAtIndex:1]];
                                        NSArray *amPmCompsArr=[[timeOutCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
                                        if ([amPmCompsArr count]==2)
                                        {
                                            time_out=[NSString stringWithFormat:@"%@ %@",hrsMinsStr,[amPmCompsArr objectAtIndex:1]];
                                        }
                                    }





                                    if (time_in!=nil && ![time_in isKindOfClass:[NSNull class]])
                                        inTime=[time_in lowercaseString];
                                    else
                                        inTime=@"";

                                    if (time_out!=nil && ![time_out isKindOfClass:[NSNull class]])
                                        outTime=[time_out lowercaseString];
                                    else
                                        outTime=@"";



                                    if (time_in!=nil && ![time_in isKindOfClass:[NSNull class]] &&![time_in isEqualToString:@""] && time_out!=nil && ![time_out isKindOfClass:[NSNull class]]&&![time_out isEqualToString:@""])
                                    {
                                        totalHours=totalHours+[[Util getNumberOfHoursForInTime:tempTime_in outTime:temp_Time_out]newDoubleValue];
                                        w_o_RoundedTotalHours=w_o_RoundedTotalHours+[[Util getNumberOfHoursWithoutRoundingForInTime:tempTime_in outTime:temp_Time_out]newDoubleValue];
                                    }

                                    NSString *tempComments=[punchDict objectForKey:@"comments"];
                                    if (tempComments==nil ||[tempComments isKindOfClass:[NSNull class]]||[tempComments isEqualToString:@""])
                                    {
                                        tempComments=@"";
                                    }
                                    NSString *timePunchesUri=[punchDict objectForKey:@"timePunchesUri"];
                                    [formattedTimePunchesDict setObject:tempComments forKey:@"comments"];
                                    [formattedTimePunchesDict setObject:inTime forKey:@"in_time"];
                                    [formattedTimePunchesDict setObject:outTime forKey:@"out_time"];
                                    [formattedTimePunchesDict setObject:udfArray forKey:@"udfArray"];
                                    [formattedTimePunchesDict setObject:timePunchesUri forKey:@"timePunchesUri"];
                                    if (clientPunchID!=nil && ![clientPunchID isKindOfClass:[NSNull class]])
                                    {
                                        [formattedTimePunchesDict setObject:clientPunchID forKey:@"clientID"];
                                    }
                                    [timePunchesArr replaceObjectAtIndex:count withObject:formattedTimePunchesDict];


                                }

                                if (timesheetFormat!=nil &&![timesheetFormat isKindOfClass:[NSNull class]])
                                {
                                    if([timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                                    {
                                        [tsEntryObject setTimeEntryCellOEFArray:[self constructCellOEFObjectForTimeSheetUri:self.timesheetURI andtimesheetFormat:timesheetFormat andOEFLevel:TIMESHEET_CELL_OEF andTimePunchUri:timePunchesUri]];


                                        if (isProjectAccess || isActivityAccess)
                                        {
                                            for (NSDictionary *punchDict in timePunchesArr)
                                            {
                                                NSString *timePunchesUri=[punchDict objectForKey:@"timePunchesUri"];
                                                if (timePunchesUri==nil || [timePunchesUri isKindOfClass:[NSNull class]] || [timePunchesUri isEqualToString:@""])
                                                {
                                                    [timePunchesArr removeObject:punchDict];
                                                }
                                            }

                                        }
                                        
                                        
                                    }
                                }


                                [tsEntryObject setTimePunchesArray:timePunchesArr];
                                [tsEntryObject setTimeEntryHoursInDecimalFormat:[NSString stringWithFormat:@"%f",totalHours]];
                                [tsEntryObject setTimeEntryHoursInDecimalFormatWithOutRoundOff:[NSString stringWithFormat:@"%f",w_o_RoundedTotalHours]];


                            }

                        }
                        else
                        {
                            if (multiDayInOutType==EXTENDED_IN_OUT_TIMESHEET_TYPE)
                            {

                                NSString *key=nil;

                                if ([self.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [parentDelegate isKindOfClass:[ApprovalsScrollViewController class]] || [self.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]] || [parentDelegate isKindOfClass:[SupervisorDashboardNavigationController class]])
                                {
                                    ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)parentDelegate;
                                    ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
                                    if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                                    {

                                        isProjectAccess=[approvalsModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:self.timesheetURI];
                                        isActivityAccess=[approvalsModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:self.timesheetURI];
                                        isBreakAccess=[approvalsModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBreakAccess" forSheetUri:self.timesheetURI];
                                    }
                                    else
                                    {
                                        isProjectAccess=[approvalsModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:self.timesheetURI];
                                        isActivityAccess=[approvalsModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:self.timesheetURI];
                                        isBreakAccess=[approvalsModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBreakAccess" forSheetUri:self.timesheetURI];


                                    }

                                    if (isGen4Timesheet) {
                                        SupportDataModel *supportModel=[[SupportDataModel alloc]init];
                                        NSDictionary *dict=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
                                        if (timesheetFormat!=nil &&![timesheetFormat isKindOfClass:[NSNull class]])
                                        {
                                            if([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET])
                                            {
                                                isBreakAccess=[[dict objectForKey:@"allowBreakForInOutGen4"] boolValue];
                                            }
                                            else if([timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                                            {
                                                isProjectAccess=[[dict objectForKey:@"allowProjectsTasksForExtInOutGen4"] boolValue];
                                                isActivityAccess=[[dict objectForKey:@"allowActivitiesForExtInOutGen4"] boolValue];
                                                isBreakAccess=[[dict objectForKey:@"allowBreakForExtInOutGen4"] boolValue];
                                            }
                                            else if([timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                                            {
                                                isBreakAccess=[[dict objectForKey:@"allowBreakForStandardGen4"] boolValue];
                                            }
                                        }

                                    }



                                }
                                else
                                {
                                    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                                    isProjectAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetURI];
                                    isActivityAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetURI];
                                    isBreakAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBreakAccess" forSheetUri:timesheetURI];
                                    if (isGen4Timesheet) {
                                        SupportDataModel *supportModel=[[SupportDataModel alloc]init];
                                        NSDictionary *dict=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
                                        if (timesheetFormat!=nil &&![timesheetFormat isKindOfClass:[NSNull class]])
                                        {
                                            if([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET])
                                            {
                                                isBreakAccess=[[dict objectForKey:@"allowBreakForInOutGen4"] boolValue];
                                            }
                                            else if([timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                                            {
                                                isProjectAccess=[[dict objectForKey:@"allowProjectsTasksForExtInOutGen4"] boolValue];
                                                isActivityAccess=[[dict objectForKey:@"allowActivitiesForExtInOutGen4"] boolValue];
                                                isBreakAccess=[[dict objectForKey:@"allowBreakForExtInOutGen4"] boolValue];
                                            }
                                            else if([timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                                            {
                                                isBreakAccess=[[dict objectForKey:@"allowBreakForStandardGen4"] boolValue];
                                            }
                                        }

                                    }

                                }



                                if (isProjectAccess)
                                {//Implemented as per TIME-495//JUHI
                                    if (projectUri!=nil && ![projectUri isKindOfClass:[NSNull class]])
                                    {
                                        key=projectUri;
                                    }
                                    else
                                        key=@"";


                                }
                                else if (isActivityAccess)
                                {//Implemented as per TIME-495//JUHI
                                    if (activityUri!=nil && ![activityUri isKindOfClass:[NSNull class]])
                                    {
                                        key=activityUri;
                                    }
                                    else
                                        key=@"";


                                }
                                else if (isBreakAccess)
                                {//Implemented as per TIME-495//JUHI
                                    if (breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]])
                                    {
                                        key=breakUri;
                                    }
                                    else
                                        key=@"";

                                }
                                else
                                {
                                    key=@"";
                                }

                                NSMutableArray *timePunchesArr=[dict objectForKey:key];
                                if (isGen4Timesheet) {
                                    if (key==nil ||[key isKindOfClass:[NSNull class]]||[key isEqualToString:@""]) {
                                        timePunchesArr=[dict objectForKey:[NSNull null]];
                                    }
                                }
                                double totalHours=0;
                                double w_o_RoundedTotalHours=0;

                                for (int count=0; count<[timePunchesArr count]; count++)
                                {

                                    NSMutableDictionary *formattedTimePunchesDict=[NSMutableDictionary dictionary];
                                    NSDictionary *punchDict=[timePunchesArr objectAtIndex:count];
                                    tempCustomFieldArray=[self getUDFArrayForModuleName:TIMESHEET_CELL_UDF andEntryDate:timentryDate andEntryType:entryType andRowUri:[punchDict objectForKey:@"timePunchesUri"] isRowEditable:YES];
                                    NSMutableArray *udfArray=[NSMutableArray array];
                                    for (int i=0; i<[tempCustomFieldArray count]; i++)
                                    {
                                        NSDictionary *udfDict = [tempCustomFieldArray objectAtIndex: i];
                                        NSString *udfType=[udfDict objectForKey:@"type"];
                                        NSString *udfName=[udfDict objectForKey:@"name"];
                                        NSString *udfUri=[udfDict objectForKey:@"uri"];

                                        if ([udfType isEqualToString:TEXT_UDF_TYPE])
                                        {
                                            NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                            NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                            EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                            [udfDetails setSystemDefaultValue:systemDefaultValue];
                                            [udfDetails setFieldName:udfName];
                                            [udfDetails setFieldType:UDFType_TEXT];
                                            [udfDetails setFieldValue:defaultValue];
                                            [udfDetails setUdfIdentity:udfUri];
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
                                            int defaultDecimalValue=[[udfDict objectForKey:@"defaultDecimalValue"] intValue];
                                            EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                            [udfDetails setSystemDefaultValue:systemDefaultValue];
                                            [udfDetails setFieldName:udfName];
                                            [udfDetails setFieldType:UDFType_NUMERIC];
                                            [udfDetails setFieldValue:defaultValue];
                                            [udfDetails setUdfIdentity:udfUri];
                                            [udfDetails setDecimalPoints:defaultDecimalValue];
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
                                            else{//Implemented for US8763_HandleWhenDateUDFDoesNotHaveDefaultValue//JUHI
                                                if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]) {
                                                    defaultValue=RPLocalizedString(SELECT_STRING, @"");
                                                }
                                                else{
                                                    NSDate *date=(NSDate *)[udfDict objectForKey:@"defaultValue"];
                                                    defaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:date]];
                                                }

                                            }
                                            id systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                            if ([systemDefaultValue isKindOfClass:[NSDate class]])
                                            {
                                                systemDefaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:systemDefaultValue]];
                                            }
                                            EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                            [udfDetails setSystemDefaultValue:systemDefaultValue];
                                            [udfDetails setFieldName:udfName];
                                            [udfDetails setFieldType:UDFType_DATE];
                                            [udfDetails setFieldValue:defaultValue];
                                            [udfDetails setUdfIdentity:udfUri];
                                            [udfArray addObject:udfDetails];

                                        }
                                        else if([udfType isEqualToString:DROPDOWN_UDF_TYPE])
                                        {
                                            NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                            NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                            NSString *dropDownOptionUri=[udfDict objectForKey:@"dropDownOptionUri"];
                                            EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                            [udfDetails setSystemDefaultValue:systemDefaultValue];
                                            [udfDetails setFieldName:udfName];
                                            [udfDetails setFieldType:UDFType_DROPDOWN];
                                            [udfDetails setFieldValue:defaultValue];
                                            [udfDetails setUdfIdentity:udfUri];
                                            [udfDetails setDropdownOptionUri:dropDownOptionUri];
                                            [udfArray addObject:udfDetails];

                                        }




                                    }
                                    NSString *inTime=nil;
                                    NSString *outTime=nil;


                                    NSString *tempTime_in=[punchDict objectForKey:@"in_time"];
                                    NSString *temp_Time_out=[punchDict objectForKey:@"out_time"];
                                    NSString *time_in=[punchDict objectForKey:@"in_time"];
                                    NSString *time_out=[punchDict objectForKey:@"out_time"];
                                    //NSString *timePunchesUri=[punchDict objectForKey:@"timePunchesUri"];
                                    NSString *clientPunchID=[punchDict objectForKey:@"clientPunchId"];
                                    NSArray *timeInCompsArr=[tempTime_in componentsSeparatedByString:@":"];
                                    if ([timeInCompsArr count]==3)
                                    {
                                        NSString *hrsMinsStr=[NSString stringWithFormat:@"%@:%@",[timeInCompsArr objectAtIndex:0],[timeInCompsArr objectAtIndex:1]];
                                        NSArray *amPmCompsArr=[[timeInCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
                                        if ([amPmCompsArr count]==2)
                                        {
                                            time_in=[NSString stringWithFormat:@"%@ %@",hrsMinsStr,[amPmCompsArr objectAtIndex:1]];
                                        }
                                    }

                                    NSArray *timeOutCompsArr=[temp_Time_out componentsSeparatedByString:@":"];
                                    if ([timeOutCompsArr count]==3)
                                    {
                                        NSString *hrsMinsStr=[NSString stringWithFormat:@"%@:%@",[timeOutCompsArr objectAtIndex:0],[timeOutCompsArr objectAtIndex:1]];
                                        NSArray *amPmCompsArr=[[timeOutCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
                                        if ([amPmCompsArr count]==2)
                                        {
                                            time_out=[NSString stringWithFormat:@"%@ %@",hrsMinsStr,[amPmCompsArr objectAtIndex:1]];
                                        }
                                    }





                                    if (time_in!=nil && ![time_in isKindOfClass:[NSNull class]])
                                        inTime=[time_in lowercaseString];
                                    else
                                        inTime=@"";

                                    if (time_out!=nil && ![time_out isKindOfClass:[NSNull class]])
                                        outTime=[time_out lowercaseString];
                                    else
                                        outTime=@"";


                                    if (tempTime_in!=nil &&  ![tempTime_in isKindOfClass:[NSNull class]]&&![tempTime_in isEqualToString:@""] &&temp_Time_out!=nil  && ![temp_Time_out isKindOfClass:[NSNull class]]&&![temp_Time_out isEqualToString:@""])
                                    {
                                        totalHours=totalHours+[[Util getNumberOfHoursForInTime:tempTime_in outTime:temp_Time_out]newDoubleValue];
                                        w_o_RoundedTotalHours=w_o_RoundedTotalHours+[[Util getNumberOfHoursWithoutRoundingForInTime:tempTime_in outTime:temp_Time_out]newDoubleValue];
                                    }


                                    NSString *tempComments=[punchDict objectForKey:@"comments"];
                                    if (tempComments==nil ||[tempComments isKindOfClass:[NSNull class]]||[tempComments isEqualToString:@""])
                                    {
                                        tempComments=@"";
                                    }
                                    NSString *timePunchesUri=[punchDict objectForKey:@"timePunchesUri"];
                                    [formattedTimePunchesDict setObject:tempComments forKey:@"comments"];
                                    [formattedTimePunchesDict setObject:inTime forKey:@"in_time"];
                                    [formattedTimePunchesDict setObject:outTime forKey:@"out_time"];
                                    [formattedTimePunchesDict setObject:udfArray forKey:@"udfArray"];
                                    [formattedTimePunchesDict setObject:timePunchesUri forKey:@"timePunchesUri"];
                                    if (clientPunchID!=nil && ![clientPunchID isKindOfClass:[NSNull class]])
                                    {
                                        [formattedTimePunchesDict setObject:clientPunchID forKey:@"clientID"];
                                    }
                                    
                                    [timePunchesArr replaceObjectAtIndex:count withObject:formattedTimePunchesDict];


                                }

                                if (timesheetFormat!=nil &&![timesheetFormat isKindOfClass:[NSNull class]])
                                {
                                    if([timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                                    {
                                        [tsEntryObject setTimeEntryCellOEFArray:[self constructCellOEFObjectForTimeSheetUri:self.timesheetURI andtimesheetFormat:timesheetFormat andOEFLevel:TIMESHEET_CELL_OEF andTimePunchUri:timePunchesUri]];

                                        if (isProjectAccess || isActivityAccess)
                                        {
                                            for (NSDictionary *punchDict in timePunchesArr)
                                            {
                                                NSString *timePunchesUri=[punchDict objectForKey:@"timePunchesUri"];
                                                if (timePunchesUri==nil || [timePunchesUri isKindOfClass:[NSNull class]] || [timePunchesUri isEqualToString:@""])
                                                {
                                                    [timePunchesArr removeObject:punchDict];
                                                }

                                            }
                                            
                                        }
                                        
                                        
                                    }
                                }


                                [tsEntryObject setTimePunchesArray:timePunchesArr];
                                [tsEntryObject setTimeEntryHoursInDecimalFormat:[NSString stringWithFormat:@"%f",totalHours]];
                                [tsEntryObject setTimeEntryHoursInDecimalFormatWithOutRoundOff:[NSString stringWithFormat:@"%f",w_o_RoundedTotalHours]];



                            }
                            else
                            {
                                [tsEntryObject setTimeEntryHoursInDecimalFormat:[Util getNumberOfHoursForInTime:tempTime_in outTime:temp_Time_out]];
                                [tsEntryObject setTimeEntryHoursInDecimalFormatWithOutRoundOff:[Util getNumberOfHoursWithoutRoundingForInTime:tempTime_in outTime:temp_Time_out]];
                            }


                        }

                    }

                    //NSString *timeEntryHoursInDecimal=[Util getRoundedValueFromDecimalPlaces:[durationDecimalFormat newDoubleValue]];
                    BOOL isBothInOutNull=NO;
                    if (multiDayInOutType==EXTENDED_IN_OUT_TIMESHEET_TYPE && isGen4Timesheet)
                    {
                        BOOL isSimpleInOutGen4Timesheet=YES;
                        if (timesheetFormat!=nil &&![timesheetFormat isKindOfClass:[NSNull class]])
                        {
                            if([timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                            {
                                if (isProjectAccess || isActivityAccess)
                                {
                                    isSimpleInOutGen4Timesheet=NO;
                                }
                            }
                        }


                        if (([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[timesheetStatus isEqualToString:APPROVED_STATUS ]||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED]) || !isSimpleInOutGen4Timesheet)
                        {
                            if ([tsEntryObject.timePunchesArray count]>0)
                            {
                                NSString *in_time=[[tsEntryObject.timePunchesArray objectAtIndex:0] objectForKey:@"in_time"];
                                NSString *out_time=[[tsEntryObject.timePunchesArray objectAtIndex:0] objectForKey:@"out_time"];
                                BOOL isinTimeNull=NO;
                                if (in_time==nil||[in_time isKindOfClass:[NSNull class]]||[in_time isEqualToString:@""])
                                {
                                    isinTimeNull=YES;
                                }
                                BOOL isoutTimeNull=NO;
                                if (out_time==nil||[out_time isKindOfClass:[NSNull class]]||[out_time isEqualToString:@""])
                                {
                                    isoutTimeNull=YES;
                                }
                                if (isinTimeNull && isoutTimeNull) {
                                    isBothInOutNull=YES;
                                }
                            }

                            if(!isSimpleInOutGen4Timesheet)
                            {
                                if ([tsEntryObject.timePunchesArray count]==0)
                                {
                                      isBothInOutNull=YES;
                                }
                            }

                        }

                    }
                    [tsEntryObject setTimeEntryDate:timentryDate];
                    [tsEntryObject setTimeEntryActivityName:activityName];
                    [tsEntryObject setTimeEntryActivityUri:activityUri];
                    [tsEntryObject setTimeEntryBillingName:billingName];
                    [tsEntryObject setTimeEntryBillingUri:billingUri];
                    [tsEntryObject setTimeEntryProjectName:projectName];
                    [tsEntryObject setTimeEntryProjectUri:projectUri];
                    [tsEntryObject setTimeEntryClientName:clientName];
                    [tsEntryObject setTimeEntryClientUri:clientUri];
                    //MOBI-746
                    [tsEntryObject setTimeEntryProgramName:programName];
                    [tsEntryObject setTimeEntryProgramUri:programUri];
                    [tsEntryObject setTimeEntryTaskName:taskName];
                    [tsEntryObject setTimeEntryTaskUri:taskUri];
                    [tsEntryObject setTimeEntryTimeOffName:timeOffName];
                    [tsEntryObject setTimeEntryTimeOffUri:timeOffUri];
                    [tsEntryObject setTimeEntryComments:comments];
                    [tsEntryObject setTimeEntryHoursInHourFormat:durationHourFormat];
                    [tsEntryObject setMultiDayInOutEntry:multiDayInOutDict];
                    [tsEntryObject setTimeEntryUdfArray:udfArray];
                    [tsEntryObject setTimesheetUri:timesheetURI];
                    //Implentation for US8956//JUHI
                    [tsEntryObject setBreakName:breakName];
                    [tsEntryObject setBreakUri:breakUri];
                    [tsEntryObject setRownumber:rowNumber];
                    if (!isBothInOutNull || (timeOffName!=nil && (![timeOffName isKindOfClass:[NSNull class]] && ![timeOffName isEqualToString:@""])))
                    {
                        [temptimesheetEntryDataArray addObject:tsEntryObject];
                    }





                }
                if (isAtleastOneTimeInOutPresent==NO)
                {
                    if (multiDayInOutType!=EXTENDED_IN_OUT_TIMESHEET_TYPE)
                    {
                        for (int i=0; i<Intial_InOutRows_Count; i++)
                        {
                            TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc] init];



                            NSDateFormatter *formatter=[[NSDateFormatter alloc] init];

                            NSLocale *locale=[NSLocale currentLocale];
                            [formatter setLocale:locale];
                            [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                            [formatter setDateFormat:@"EEEE, dd MMM yyyy"];
                            NSDate *todayDate=[formatter dateFromString:dateString];


                            NSMutableDictionary *multiDayInOutDict=[NSMutableDictionary dictionary];
                            [multiDayInOutDict setObject:@"" forKey:@"in_time"];
                            [multiDayInOutDict setObject:@"" forKey:@"out_time"];

                            NSMutableArray *tempCustomFieldArray=[self getUDFArrayForModuleName:TIMESHEET_CELL_UDF andEntryDate:todayDate andEntryType:Time_Entry_Key andRowUri:@"" isRowEditable:YES];
                            NSMutableArray *udfArray=[[NSMutableArray alloc]init];
                            for (int i=0; i<[tempCustomFieldArray count]; i++)
                            {
                                NSDictionary *udfDict = [tempCustomFieldArray objectAtIndex: i];
                                NSString *udfType=[udfDict objectForKey:@"type"];
                                NSString *udfName=[udfDict objectForKey:@"name"];
                                NSString *udfUri=[udfDict objectForKey:@"uri"];

                                if ([udfType isEqualToString:TEXT_UDF_TYPE])
                                {
                                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                    NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                                    [udfDetails setFieldName:udfName];
                                    [udfDetails setFieldType:UDFType_TEXT];
                                    [udfDetails setFieldValue:defaultValue];
                                    [udfDetails setUdfIdentity:udfUri];
                                    [udfArray addObject:udfDetails];


                                }
                                else if([udfType isEqualToString:NUMERIC_UDF_TYPE])
                                {
                                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                    NSString *defaultValue=nil;
                                    if ([[tsEntryObject entryType] isEqualToString:Time_Off_Key])
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
                                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                                    [udfDetails setFieldName:udfName];
                                    [udfDetails setFieldType:UDFType_NUMERIC];
                                    [udfDetails setFieldValue:defaultValue];
                                    [udfDetails setUdfIdentity:udfUri];
                                    [udfDetails setDecimalPoints:defaultDecimalValue];
                                    [udfArray addObject:udfDetails];


                                }
                                else if ([udfType isEqualToString:DATE_UDF_TYPE])
                                {
                                    NSString *defaultValue=nil;
                                    id tempDefaultValue=[udfDict objectForKey:@"defaultValue"];
                                    id systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                    if ([systemDefaultValue isKindOfClass:[NSDate class]])
                                    {
                                        systemDefaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:systemDefaultValue]];
                                    }
                                    if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])
                                    {
                                        defaultValue=RPLocalizedString(NONE_STRING, @"");
                                    }
                                    else{
                                        NSDate *date=(NSDate *)[udfDict objectForKey:@"defaultValue"];
                                        defaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:date]];
                                    }

                                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                                    [udfDetails setFieldName:udfName];
                                    [udfDetails setFieldType:UDFType_DATE];
                                    [udfDetails setFieldValue:defaultValue];
                                    [udfDetails setUdfIdentity:udfUri];
                                    [udfArray addObject:udfDetails];

                                }
                                else if([udfType isEqualToString:DROPDOWN_UDF_TYPE])
                                {
                                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                    NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                    NSString *dropDownOptionUri=[udfDict objectForKey:@"dropDownOptionUri"];
                                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                                    [udfDetails setFieldName:udfName];
                                    [udfDetails setFieldType:UDFType_DROPDOWN];
                                    [udfDetails setFieldValue:defaultValue];
                                    [udfDetails setUdfIdentity:udfUri];
                                    [udfDetails setDropdownOptionUri:dropDownOptionUri];
                                    [udfArray addObject:udfDetails];

                                }




                            }

                            [tsEntryObject setTimeEntryDate:todayDate];
                            [tsEntryObject setMultiDayInOutEntry:multiDayInOutDict];
                            [tsEntryObject setTimeAllocationUri:@""];
                            [tsEntryObject setTimePunchUri:@""];
                            [tsEntryObject setTimeEntryHoursInHourFormat:@""];
                            [tsEntryObject setTimeEntryHoursInDecimalFormat:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]];
                            [tsEntryObject setTimeEntryHoursInDecimalFormatWithOutRoundOff:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]];
                            [tsEntryObject setIsTimeoffSickRowPresent:NO];
                            [tsEntryObject setTimeEntryTimeOffName:@""];
                            [tsEntryObject setTimeEntryActivityName:@""];
                            [tsEntryObject setTimeEntryActivityUri:@""];
                            [tsEntryObject setTimeEntryBillingName:@""];
                            [tsEntryObject setTimeEntryBillingUri:@""];
                            [tsEntryObject setTimeEntryProjectName:@""];
                            [tsEntryObject setTimeEntryProjectUri:@""];
                            [tsEntryObject setTimeEntryClientName:nil];
                            [tsEntryObject setTimeEntryClientUri:nil];
                            //MOBI-746
                            [tsEntryObject setTimeEntryProgramName:nil];
                            [tsEntryObject setTimeEntryProgramUri:nil];
                            [tsEntryObject setTimeEntryTaskName:@""];
                            [tsEntryObject setTimeEntryTaskUri:@""];
                            [tsEntryObject setTimeEntryTimeOffName:@""];
                            [tsEntryObject setTimeEntryTimeOffUri:@""];
                            [tsEntryObject setTimeEntryComments:@""];
                            [tsEntryObject setTimeEntryUdfArray:udfArray];
                            [tsEntryObject setTimesheetUri:timesheetURI];
                            //Implentation for US8956//JUHI
                            [tsEntryObject setBreakName:@""];
                            [tsEntryObject setBreakUri:@""];
                            [tsEntryObject setRowUri:@""];
                            [temptimesheetEntryDataArray addObject:tsEntryObject];


                        }
                    }


                }
                int indexOfObject=9999;
                for (int b=0; b<[temptimesheetEntryDataArray count]; b++)
                {
                    TimesheetEntryObject *tsEntryObject=[temptimesheetEntryDataArray objectAtIndex:b];
                    NSString *breakUri=[tsEntryObject breakUri];
                    NSString *timeEntryTimeOffUri=[tsEntryObject timeEntryTimeOffUri];
                    if (isGen4Timesheet)
                    {
                        if ((breakUri==nil||[breakUri isKindOfClass:[NSNull class]])&&(timeEntryTimeOffUri==nil||[timeEntryTimeOffUri isKindOfClass:[NSNull class]]))
                        {
                            indexOfObject=b;
                        }
                    }
                    else
                    {
                        if (breakUri==nil||[breakUri isKindOfClass:[NSNull class]])
                        {
                            indexOfObject=b;
                        }
                    }

                }
                if (isGen4Timesheet)
                {
                    if (indexOfObject==9999)
                    {
                        TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc] init];



                        NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
                        NSLocale *locale=[NSLocale currentLocale];
                        [formatter setLocale:locale];
                        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                        [formatter setDateFormat:@"EEEE, dd MMM yyyy"];
                        NSDate *todayDate=[formatter dateFromString:dateString];


                        NSMutableDictionary *multiDayInOutDict=[NSMutableDictionary dictionary];
                        [multiDayInOutDict setObject:@"" forKey:@"in_time"];
                        [multiDayInOutDict setObject:@"" forKey:@"out_time"];

                        [tsEntryObject setTimeEntryDate:todayDate];
                        [tsEntryObject setMultiDayInOutEntry:multiDayInOutDict];
                        [tsEntryObject setTimeAllocationUri:@""];
                        [tsEntryObject setTimePunchUri:@""];
                        [tsEntryObject setTimeEntryHoursInHourFormat:@""];
                        [tsEntryObject setTimeEntryHoursInDecimalFormat:@"0.00"];
                        [tsEntryObject setTimeEntryHoursInDecimalFormatWithOutRoundOff:@"0.00"];
                        [tsEntryObject setIsTimeoffSickRowPresent:NO];
                        [tsEntryObject setTimeEntryTimeOffName:@""];
                        [tsEntryObject setTimeEntryActivityName:@""];
                        [tsEntryObject setTimeEntryActivityUri:@""];
                        [tsEntryObject setTimeEntryBillingName:@""];
                        [tsEntryObject setTimeEntryBillingUri:@""];
                        [tsEntryObject setTimeEntryProjectName:@""];
                        [tsEntryObject setTimeEntryProjectUri:@""];
                        [tsEntryObject setTimeEntryClientName:nil];
                        [tsEntryObject setTimeEntryClientUri:nil];
                        //MOBI-746
                        [tsEntryObject setTimeEntryProgramName:nil];
                        [tsEntryObject setTimeEntryProgramUri:nil];
                        [tsEntryObject setTimeEntryTaskName:@""];
                        [tsEntryObject setTimeEntryTaskUri:@""];
                        [tsEntryObject setTimeEntryTimeOffName:@""];
                        [tsEntryObject setTimeEntryTimeOffUri:@""];
                        [tsEntryObject setTimeEntryComments:@""];
                        [tsEntryObject setTimeEntryUdfArray:nil];
                        [tsEntryObject setTimesheetUri:timesheetURI];
                        NSMutableDictionary *formattedTimePunchesDict=[NSMutableDictionary dictionary];
                        [formattedTimePunchesDict setObject:@"" forKey:@"comments"];
                        [formattedTimePunchesDict setObject:@"" forKey:@"in_time"];
                        [formattedTimePunchesDict setObject:@"" forKey:@"out_time"];
                        [formattedTimePunchesDict setObject:[NSMutableArray array] forKey:@"udfArray"];
                        [formattedTimePunchesDict setObject:@"" forKey:@"timePunchesUri"];
                        [formattedTimePunchesDict setObject:[Util getRandomGUID] forKey:@"clientID"];
                        NSMutableArray *timePunchesArr=[NSMutableArray array];
                        [timePunchesArr addObject:formattedTimePunchesDict];
                        [tsEntryObject setTimePunchesArray:timePunchesArr];
                        [tsEntryObject setBreakName:@""];
                        [tsEntryObject setBreakUri:@""];
                        [tsEntryObject setRowUri:@""];
                        BOOL isBothInOutNull=NO;
                        if (multiDayInOutType==EXTENDED_IN_OUT_TIMESHEET_TYPE && isGen4Timesheet)
                        {
                            BOOL isSimpleInOutGen4Timesheet=YES;
                            if (timesheetFormat!=nil &&![timesheetFormat isKindOfClass:[NSNull class]])
                            {
                                if([timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                                {
                                    if (isProjectAccess || isActivityAccess)
                                    {
                                        isSimpleInOutGen4Timesheet=NO;
                                    }
                                }
                            }


                            if (([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[timesheetStatus isEqualToString:APPROVED_STATUS ]||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED]) || !isSimpleInOutGen4Timesheet)
                            {
                                if ([tsEntryObject.timePunchesArray count]>0)
                                {
                                    NSString *in_time=[[tsEntryObject.timePunchesArray objectAtIndex:0] objectForKey:@"in_time"];
                                    NSString *out_time=[[tsEntryObject.timePunchesArray objectAtIndex:0] objectForKey:@"out_time"];
                                    BOOL isinTimeNull=NO;
                                    if (in_time==nil||[in_time isKindOfClass:[NSNull class]]||[in_time isEqualToString:@""])
                                    {
                                        isinTimeNull=YES;
                                    }
                                    BOOL isoutTimeNull=NO;
                                    if (out_time==nil||[out_time isKindOfClass:[NSNull class]]||[out_time isEqualToString:@""])
                                    {
                                        isoutTimeNull=YES;
                                    }
                                    if (isinTimeNull && isoutTimeNull) {
                                        isBothInOutNull=YES;
                                    }
                                }

                                if(!isSimpleInOutGen4Timesheet)
                                {
                                    if ([tsEntryObject.timePunchesArray count]==0)
                                    {
                                        isBothInOutNull=YES;
                                    }
                                }

                            }

                        }
                        if (!isBothInOutNull)
                        {
                            [temptimesheetEntryDataArray addObject:tsEntryObject];
                        }

                    }
                    else
                    {
                        TimesheetEntryObject *tEntryObject=(TimesheetEntryObject *)[temptimesheetEntryDataArray objectAtIndex:indexOfObject];
                        NSMutableArray *tmpPunchesArray=[tEntryObject timePunchesArray];

                        BOOL isEmptyEntryAlreadyPresent=NO;
                        for (int y=0; y<[tmpPunchesArray count]; y++)
                        {
                            NSMutableDictionary *timeDict=[tmpPunchesArray objectAtIndex:y];
                            if (timeDict!=nil && ![timeDict isKindOfClass:[NSNull class]])
                            {
                                NSString *inTimeString=[timeDict objectForKey:@"in_time"];
                                NSString *outTimeString=[timeDict objectForKey:@"out_time"];
                                if ((inTimeString==nil || [inTimeString isKindOfClass:[NSNull class]] || [inTimeString isEqualToString:@""]) && (outTimeString==nil || [outTimeString isKindOfClass:[NSNull class]]|| [outTimeString isEqualToString:@""]))
                                {
                                    isEmptyEntryAlreadyPresent=YES;
                                }
                            }
                        }
                        if ([self.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [parentDelegate isKindOfClass:[ApprovalsScrollViewController class]] || [self.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]] || [parentDelegate isKindOfClass:[SupervisorDashboardNavigationController class]])
                        {
                        }
                        else
                        {
                            BOOL isSimpleInOutGen4Timesheet=YES;
                            if (timesheetFormat!=nil &&![timesheetFormat isKindOfClass:[NSNull class]])
                            {
                                if([timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                                {
                                    if (isProjectAccess || isActivityAccess)
                                    {
                                        isSimpleInOutGen4Timesheet=NO;
                                    }
                                }
                            }


                            if ([timesheetStatus isEqualToString:NOT_SUBMITTED_STATUS]||[timesheetStatus isEqualToString:REJECTED_STATUS])
                            {
                                if (isEmptyEntryAlreadyPresent==NO)
                                {
                                    if (isSimpleInOutGen4Timesheet)
                                    {
                                        NSMutableDictionary *formattedTimePunchesDict=[NSMutableDictionary dictionary];
                                        [formattedTimePunchesDict setObject:@"" forKey:@"comments"];
                                        [formattedTimePunchesDict setObject:@"" forKey:@"in_time"];
                                        [formattedTimePunchesDict setObject:@"" forKey:@"out_time"];
                                        [formattedTimePunchesDict setObject:[NSMutableArray array] forKey:@"udfArray"];
                                        [formattedTimePunchesDict setObject:@"" forKey:@"timePunchesUri"];
                                        [formattedTimePunchesDict setObject:[Util getRandomGUID] forKey:@"clientID"];
                                        [tmpPunchesArray addObject:formattedTimePunchesDict];
                                        NSMutableArray *array=[NSMutableArray arrayWithArray:tmpPunchesArray];
                                        [tEntryObject setTimePunchesArray:array];
                                        [temptimesheetEntryDataArray replaceObjectAtIndex:indexOfObject withObject:tEntryObject];
                                    }

                                }
                            }

                        }




                    }

                }
            }
            else
            {
                if (multiDayInOutType!=EXTENDED_IN_OUT_TIMESHEET_TYPE)
                {
                    for (int i=0; i<Intial_InOutRows_Count; i++)
                    {
                        TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc] init];
                        NSDateFormatter *formatter=[[NSDateFormatter alloc] init];

                        NSLocale *locale=[NSLocale currentLocale];
                        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                        [formatter setLocale:locale];
                        [formatter setDateFormat:@"EEEE, dd MMM yyyy"];
                        NSDate *todayDate=[formatter dateFromString:dateString];


                        NSMutableDictionary *multiDayInOutDict=[NSMutableDictionary dictionary];
                        [multiDayInOutDict setObject:@"" forKey:@"in_time"];
                        [multiDayInOutDict setObject:@"" forKey:@"out_time"];
                        NSMutableArray *udfArray=[[NSMutableArray alloc]init];
                        NSMutableArray *tempCustomFieldArray=[self getUDFArrayForModuleName:TIMESHEET_CELL_UDF andEntryDate:todayDate andEntryType:Time_Entry_Key andRowUri:@"" isRowEditable:YES];
                        for (int i=0; i<[tempCustomFieldArray count]; i++)
                        {
                            NSDictionary *udfDict = [tempCustomFieldArray objectAtIndex: i];
                            NSString *udfType=[udfDict objectForKey:@"type"];
                            NSString *udfName=[udfDict objectForKey:@"name"];
                            NSString *udfUri=[udfDict objectForKey:@"uri"];

                            if ([udfType isEqualToString:TEXT_UDF_TYPE])
                            {
                                NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                [udfDetails setSystemDefaultValue:systemDefaultValue];
                                [udfDetails setFieldName:udfName];
                                [udfDetails setFieldType:UDFType_TEXT];
                                [udfDetails setFieldValue:defaultValue];
                                [udfDetails setUdfIdentity:udfUri];
                                [udfArray addObject:udfDetails];


                            }
                            else if([udfType isEqualToString:NUMERIC_UDF_TYPE])
                            {
                                NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                NSString *defaultValue=nil;
                                if ([[tsEntryObject entryType] isEqualToString:Time_Off_Key])
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
                                EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                [udfDetails setSystemDefaultValue:systemDefaultValue];
                                [udfDetails setFieldName:udfName];
                                [udfDetails setFieldType:UDFType_NUMERIC];
                                [udfDetails setFieldValue:defaultValue];
                                [udfDetails setUdfIdentity:udfUri];
                                [udfDetails setDecimalPoints:defaultDecimalValue];
                                [udfArray addObject:udfDetails];


                            }
                            else if ([udfType isEqualToString:DATE_UDF_TYPE])
                            {
                                id systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                if ([systemDefaultValue isKindOfClass:[NSDate class]])
                                {
                                    systemDefaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:systemDefaultValue]];
                                }
                                NSString *defaultValue=nil;
                                id tempDefaultValue=[udfDict objectForKey:@"defaultValue"];
                                if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])
                                {
                                    defaultValue=RPLocalizedString(NONE_STRING, @"");
                                }
                                else{//Implemented for US8763_HandleWhenDateUDFDoesNotHaveDefaultValue//JUHI
                                    if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]) {
                                        defaultValue=RPLocalizedString(SELECT_STRING, @"");
                                    }
                                    else{
                                        NSDate *date=(NSDate *)[udfDict objectForKey:@"defaultValue"];
                                        defaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:date]];
                                    }

                                }

                                EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                [udfDetails setSystemDefaultValue:systemDefaultValue];
                                [udfDetails setFieldName:udfName];
                                [udfDetails setFieldType:UDFType_DATE];
                                [udfDetails setFieldValue:defaultValue];
                                [udfDetails setUdfIdentity:udfUri];
                                [udfArray addObject:udfDetails];

                            }
                            else if([udfType isEqualToString:DROPDOWN_UDF_TYPE])
                            {
                                NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                NSString *dropDownOptionUri=[udfDict objectForKey:@"dropDownOptionUri"];
                                EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                [udfDetails setSystemDefaultValue:systemDefaultValue];
                                [udfDetails setFieldName:udfName];
                                [udfDetails setFieldType:UDFType_DROPDOWN];
                                [udfDetails setFieldValue:defaultValue];
                                [udfDetails setUdfIdentity:udfUri];
                                [udfDetails setDropdownOptionUri:dropDownOptionUri];
                                [udfArray addObject:udfDetails];

                            }




                        }




                        [tsEntryObject setTimeEntryDate:todayDate];
                        [tsEntryObject setMultiDayInOutEntry:multiDayInOutDict];
                        [tsEntryObject setTimeAllocationUri:@""];
                        [tsEntryObject setTimePunchUri:@""];
                        [tsEntryObject setTimeEntryHoursInHourFormat:@""];
                        [tsEntryObject setTimeEntryHoursInDecimalFormat:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]];
                        [tsEntryObject setTimeEntryHoursInDecimalFormatWithOutRoundOff:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]];
                        [tsEntryObject setIsTimeoffSickRowPresent:NO];
                        [tsEntryObject setTimeEntryTimeOffName:@""];
                        [tsEntryObject setTimeEntryActivityName:@""];
                        [tsEntryObject setTimeEntryActivityUri:@""];
                        [tsEntryObject setTimeEntryBillingName:@""];
                        [tsEntryObject setTimeEntryBillingUri:@""];
                        [tsEntryObject setTimeEntryProjectName:@""];
                        [tsEntryObject setTimeEntryProjectUri:@""];
                        [tsEntryObject setTimeEntryClientName:nil];
                        [tsEntryObject setTimeEntryClientUri:nil];
                        [tsEntryObject setTimeEntryTaskName:@""];
                        [tsEntryObject setTimeEntryTaskUri:@""];
                        [tsEntryObject setTimeEntryTimeOffName:@""];
                        [tsEntryObject setTimeEntryTimeOffUri:@""];
                        [tsEntryObject setTimeEntryComments:@""];
                        [tsEntryObject setTimeEntryUdfArray:udfArray];
                        [tsEntryObject setTimesheetUri:timesheetURI];
                        //Implentation for US8956//JUHI
                        [tsEntryObject setBreakName:@""];
                        [tsEntryObject setBreakUri:@""];
                        [tsEntryObject setRowUri:@""];
                        [temptimesheetEntryDataArray addObject:tsEntryObject];


                    }
                }
                else if (isGen4Timesheet)
                {
                    if ([self.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [parentDelegate isKindOfClass:[ApprovalsScrollViewController class]] || [self.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]] || [parentDelegate isKindOfClass:[SupervisorDashboardNavigationController class]])
                    {
                    }
                    else
                    {
                        if ([timesheetStatus isEqualToString:NOT_SUBMITTED_STATUS]||[timesheetStatus isEqualToString:REJECTED_STATUS])
                        {
                            TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc] init];



                            NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
                            NSLocale *locale=[NSLocale currentLocale];
                            [formatter setLocale:locale];
                            [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                            [formatter setDateFormat:@"EEEE, dd MMM yyyy"];
                            NSDate *todayDate=[formatter dateFromString:dateString];


                            NSMutableDictionary *multiDayInOutDict=[NSMutableDictionary dictionary];
                            [multiDayInOutDict setObject:@"" forKey:@"in_time"];
                            [multiDayInOutDict setObject:@"" forKey:@"out_time"];

                            [tsEntryObject setTimeEntryDate:todayDate];
                            [tsEntryObject setMultiDayInOutEntry:multiDayInOutDict];
                            [tsEntryObject setTimeAllocationUri:@""];
                            [tsEntryObject setTimePunchUri:@""];
                            [tsEntryObject setTimeEntryHoursInHourFormat:@""];
                            [tsEntryObject setTimeEntryHoursInDecimalFormat:@"0.00"];
                            [tsEntryObject setTimeEntryHoursInDecimalFormatWithOutRoundOff:@"0.00"];
                            [tsEntryObject setIsTimeoffSickRowPresent:NO];
                            [tsEntryObject setTimeEntryTimeOffName:@""];
                            [tsEntryObject setTimeEntryActivityName:@""];
                            [tsEntryObject setTimeEntryActivityUri:@""];
                            [tsEntryObject setTimeEntryBillingName:@""];
                            [tsEntryObject setTimeEntryBillingUri:@""];
                            [tsEntryObject setTimeEntryProjectName:@""];
                            [tsEntryObject setTimeEntryProjectUri:@""];
                            [tsEntryObject setTimeEntryClientName:nil];
                            [tsEntryObject setTimeEntryClientUri:nil];
                            [tsEntryObject setTimeEntryTaskName:@""];
                            [tsEntryObject setTimeEntryTaskUri:@""];
                            [tsEntryObject setTimeEntryTimeOffName:@""];
                            [tsEntryObject setTimeEntryTimeOffUri:@""];
                            [tsEntryObject setTimeEntryComments:@""];
                            [tsEntryObject setTimeEntryUdfArray:nil];
                            [tsEntryObject setTimesheetUri:timesheetURI];
                            NSMutableDictionary *formattedTimePunchesDict=[NSMutableDictionary dictionary];
                            [formattedTimePunchesDict setObject:@"" forKey:@"comments"];
                            [formattedTimePunchesDict setObject:@"" forKey:@"in_time"];
                            [formattedTimePunchesDict setObject:@"" forKey:@"out_time"];
                            [formattedTimePunchesDict setObject:[NSMutableArray array] forKey:@"udfArray"];
                            [formattedTimePunchesDict setObject:@"" forKey:@"timePunchesUri"];
                            [formattedTimePunchesDict setObject:[Util getRandomGUID] forKey:@"clientID"];
                            NSMutableArray *timePunchesArr=[NSMutableArray array];
                            [timePunchesArr addObject:formattedTimePunchesDict];
                            [tsEntryObject setTimePunchesArray:timePunchesArr];
                            [tsEntryObject setBreakName:@""];
                            [tsEntryObject setBreakUri:@""];
                            [tsEntryObject setRowUri:@""];
                            [temptimesheetEntryDataArray addObject:tsEntryObject];
                        }


                    }

                }


            }
            [timesheetDataArray addObject:temptimesheetEntryDataArray];

        }

    }
    else
    {
        BOOL isGen4StandardTimesheet=NO;
        BOOL isGen4DailyWidgetTimesheetTimesheet=NO;
        
        NSArray *timesheetInfoArray=nil;
        
        
        if ([self.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [parentDelegate isKindOfClass:[ApprovalsScrollViewController class]] || [self.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]] || [parentDelegate isKindOfClass:[SupervisorDashboardNavigationController class]])
        {
            ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)parentDelegate;
            ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
            if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                timesheetInfoArray=[approvalsModel getTimeSheetInfoSheetIdentityForPending:timesheetURI];
                
            }
            else
            {
                timesheetInfoArray=[approvalsModel getTimeSheetInfoSheetIdentityForPrevious:timesheetURI];
            }
        }
        else
        {
            TimesheetModel *tsModel=[[TimesheetModel alloc]init];
            timesheetInfoArray=[tsModel getTimeSheetInfoSheetIdentity:timesheetURI];
            
            
        }
        
        
        if ([timesheetInfoArray count]>0)
        {
            NSString *tsFormat=[[timesheetInfoArray objectAtIndex:0] objectForKey:@"timesheetFormat"];
            if (tsFormat!=nil &&![tsFormat isKindOfClass:[NSNull class]])
            {
                if ([tsFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                {
                    isGen4StandardTimesheet=YES;
                }
                else if ([tsFormat isEqualToString:GEN4_DAILY_WIDGET_TIMESHEET])
                {
                    isGen4DailyWidgetTimesheetTimesheet=YES;
                }
            }


        }
        NSMutableArray *availableEntryDatesArray=[NSMutableArray array];
        NSMutableArray *availableEntriesDictArray=[NSMutableArray array];
        BOOL exit = NO;
        for (int i=0; i<[dbTimeEntriesArray count]; i++)
        {

            if (exit)
            {
                [self.navigationController popViewControllerAnimated:YES];
                break;
            }
            NSMutableArray *arrayOfEntries=[dbTimeEntriesArray objectAtIndex:i];

            for (int k=0; k<[arrayOfEntries count]; k++)
            {
                if (isGen4DailyWidgetTimesheetTimesheet)
                {
                    NSMutableDictionary *entryDict=[arrayOfEntries objectAtIndex:k];
                    NSDate *tmpDate = [Util convertTimestampFromDBToDate:[[entryDict objectForKey:@"timesheetEntryDate"] stringValue]];
                    NSCalendar *gregorian=[NSCalendar currentCalendar];
                    [gregorian setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                    NSUInteger flags = ( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay );
                    NSDate * date = [gregorian dateFromComponents:[gregorian components:flags fromDate:tmpDate]];
                    if (![availableEntryDatesArray containsObject:date])
                    {

                        [availableEntryDatesArray addObject:date];
                        [availableEntriesDictArray addObject:arrayOfEntries];
                    }

                }
                else
                {
                    NSMutableArray *entryArray=[arrayOfEntries objectAtIndex:k];
                    if ([entryArray count]>0)
                    {
                        if ([entryArray isKindOfClass:[NSDictionary class]])
                        {
                            exit = YES;

                             break;
                        }
                        NSDate *tmpDate = [Util convertTimestampFromDBToDate:[[[entryArray objectAtIndex:0] objectForKey:@"timesheetEntryDate"] stringValue]];
                        NSCalendar *gregorian=[NSCalendar currentCalendar];
                        [gregorian setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                        NSUInteger flags = ( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay );
                        NSDate * date = [gregorian dateFromComponents:[gregorian components:flags fromDate:tmpDate]];
                        if (![availableEntryDatesArray containsObject:date])
                        {

                            [availableEntryDatesArray addObject:date];
                            [availableEntriesDictArray addObject:arrayOfEntries];
                        }
                        
                    }
                }

            }

        }


        for (int j=0; j<[tsEntryDataArray count]; j++)
        {

            NSMutableArray *temptimesheetEntryDataArray=[[NSMutableArray alloc]init];
            NSString *dateString = [[tsEntryDataArray objectAtIndex:j] entryDate];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

            NSLocale *locale=[NSLocale currentLocale];
            [dateFormatter setLocale:locale];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [dateFormatter setDateFormat:@"EEEE, dd MMM yyyy"];
            NSDate *date = [dateFormatter dateFromString:dateString];

            if ([availableEntryDatesArray containsObject:date ])
            {
                NSUInteger index=[availableEntryDatesArray indexOfObject:date];
                NSMutableArray *arrayOfEntries=[availableEntriesDictArray objectAtIndex:index];
                // Entry Available on this date

                if (isGen4DailyWidgetTimesheetTimesheet)
                {
                    temptimesheetEntryDataArray=[self createDayLevelDailyWidgetOEFArrayForDate:dateString andTimeEntries:arrayOfEntries];
                }
                else
                {
                    for (int m=0; m<[arrayOfEntries count]; m++)
                    {
                        NSMutableDictionary *dict= nil;
                        NSMutableArray *entryArray=[arrayOfEntries objectAtIndex:m];

                        dict=[entryArray objectAtIndex:0];


                        NSString *value=[dict objectForKey:@"isObjectEmpty"];

                        if ([value isKindOfClass:[NSNull class]]|| value==nil)
                        {
                            //Entry available
                            TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc] init];
                            NSDateFormatter *formatter=[[NSDateFormatter alloc] init];

                            NSLocale *locale=[NSLocale currentLocale];
                            [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                            [formatter setLocale:locale];
                            [formatter setDateFormat:@"EEEE, dd MMM yyyy"];
                            NSDate *todayDate=[formatter dateFromString:dateString];
                            BOOL isRowEditable=NO;
                            BOOL hasTimeEntryValue = NO;
                            if ([[dict objectForKey:@"entryType"] isEqualToString:Time_Entry_Key])
                            {
                                if ([dict objectForKey:@"endDateAllowedTime"]!=nil && ![[dict objectForKey:@"endDateAllowedTime"] isKindOfClass:[NSNull class]] && [dict objectForKey:@"startDateAllowedTime"]!=nil && ![[dict objectForKey:@"startDateAllowedTime"] isKindOfClass:[NSNull class]]) {
                                    NSDate *endDateAllowed=[Util convertTimestampFromDBToDate:[dict objectForKey:@"endDateAllowedTime"]];
                                    NSDate *startDateAllowed=[Util convertTimestampFromDBToDate:[dict objectForKey:@"startDateAllowedTime"]];
                                    isRowEditable=[Util date:todayDate isBetweenDate:startDateAllowed andDate:endDateAllowed];
                                }
                                else
                                {
                                    isRowEditable=YES;
                                }

                            }



                            NSMutableDictionary *multiDayInOutDict=[NSMutableDictionary dictionary];
                            NSString *comments=[dict objectForKey:@"comments"];
                            NSString *projectName=[dict objectForKey:@"projectName"];
                            NSString *projectUri=[dict objectForKey:@"projectUri"];
                            NSString *clientName=[dict objectForKey:@"clientName"];
                            NSString *clientUri=[dict objectForKey:@"clientUri"];
                            //MOBI-746
                            NSString *programName=[dict objectForKey:@"programName"];
                            NSString *programUri=[dict objectForKey:@"programUri"];
                            NSString *timeoffName=[dict objectForKey:@"timeOffTypeName"];
                            NSString *timeoffUri=[dict objectForKey:@"timeOffUri"];
                            NSString *durationDecimal=[dict objectForKey:@"durationDecimalFormat"];
                            NSString *billingName=[dict objectForKey:@"billingName"];
                            NSString *billingUri=[dict objectForKey:@"billingUri"];
                            NSString *activityName=[dict objectForKey:@"activityName"];
                            NSString *activityUri=[dict objectForKey:@"activityUri"];
                            NSString *taskName=[dict objectForKey:@"taskName"];
                            NSString *taskUri=[dict objectForKey:@"taskUri"];
                            NSString *entryType=[dict objectForKey:@"entryType"];
                            NSString *rowUri=[dict objectForKey:@"rowUri"];
                            NSString *rowNumber=[dict objectForKey:@"rowNumber"];
                            if ([dict objectForKey:@"hasTimeEntryValue"]!=nil && [dict objectForKey:@"hasTimeEntryValue"]!=(id)[NSNull null]) {
                                hasTimeEntryValue = [[dict objectForKey:@"hasTimeEntryValue"] boolValue];    
                            }
                            
                            NSMutableArray *tempCustomFieldArray=nil;
                            NSMutableArray *tempRowCustomFieldArray=nil;//Implementation for US9371//JUHI
                            if (timeoffName!=nil && timeoffUri !=nil && ![timeoffUri isKindOfClass:[NSNull class]] &&![timeoffName isKindOfClass:[NSNull class]] && ![timeoffName isEqualToString:@""]&& ![timeoffUri isEqualToString:@""])
                            {
                                if ([entryType isEqualToString:Time_Off_Key])
                                {
                                    [tsEntryObject setEntryType:Time_Off_Key];
                                    tempCustomFieldArray=[self getUDFArrayForModuleName:TIMEOFF_UDF andEntryDate:todayDate andEntryType:entryType andRowUri:rowUri isRowEditable:YES];
                                }
                                else
                                {
                                    [tsEntryObject setEntryType:Adhoc_Time_OffKey];
                                    tempCustomFieldArray=[self getUDFArrayForAdhocTimeoffInStandard:TIMEOFF_UDF andEntryType:entryType andRowUri:rowUri];
                                    isRowEditable=YES;

                                }

                                [tsEntryObject setIsTimeoffSickRowPresent:YES];
                                [tsEntryObject setTimeEntryTimeOffName:timeoffName];
                                [tsEntryObject setTimeEntryTimeOffUri:timeoffUri];
                                [tsEntryObject setTimeEntryProjectName:@""];
                                [tsEntryObject setTimeEntryProjectUri:@""];
                                [tsEntryObject setTimeEntryClientName:nil];
                                [tsEntryObject setTimeEntryClientUri:nil];
                            }
                            else
                            {
                                if(isGen4DailyWidgetTimesheetTimesheet)
                                {

                                    [tsEntryObject setTimeEntryDailyFieldOEFArray:[self constructDailyWidgetOEFObjectForTimeSheetUri:self.timesheetURI andtimesheetFormat:GEN4_DAILY_WIDGET_TIMESHEET andOEFLevel:DAILY_WIDGET_DAYLEVEL_OEF andTimePunchUri:rowUri]];
                                }
                                else if(!isGen4StandardTimesheet)
                                {
                                    tempCustomFieldArray=[self getUDFArrayForModuleName:TIMESHEET_CELL_UDF andEntryDate:todayDate andEntryType:entryType andRowUri:rowUri isRowEditable:isRowEditable];
                                    tempRowCustomFieldArray=[self getUDFArrayForModuleName:TIMESHEET_ROW_UDF andEntryDate:todayDate andEntryType:entryType andRowUri:rowUri isRowEditable:YES];
                                }
                                else if(isGen4StandardTimesheet)
                                {

                                    [tsEntryObject setTimeEntryCellOEFArray:[self constructCellOEFObjectForTimeSheetUri:self.timesheetURI andtimesheetFormat:GEN4_STANDARD_TIMESHEET andOEFLevel:TIMESHEET_CELL_OEF andTimePunchUri:rowUri]];
                                    [tsEntryObject setTimeEntryRowOEFArray:[self constructCellOEFObjectForTimeSheetUri:self.timesheetURI andtimesheetFormat:GEN4_STANDARD_TIMESHEET andOEFLevel:TIMESHEET_ROW_OEF andTimePunchUri:rowUri]];
                                }
                                [tsEntryObject setIsTimeoffSickRowPresent:NO];
                                [tsEntryObject setTimeEntryTimeOffName:@""];
                                [tsEntryObject setTimeEntryTimeOffUri:@""];
                                [tsEntryObject setTimeEntryProjectName:projectName];
                                [tsEntryObject setTimeEntryProjectUri:projectUri];
                                [tsEntryObject setTimeEntryClientName:clientName];
                                [tsEntryObject setTimeEntryClientUri:clientUri];
                                //MOBI-746
                                [tsEntryObject setTimeEntryProgramName:programName];
                                [tsEntryObject setTimeEntryProgramUri:programUri];


                            }


                            NSMutableArray *udfArray=[[NSMutableArray alloc]init];
                            for (int i=0; i<[tempCustomFieldArray count]; i++)
                            {
                                NSDictionary *udfDict = [tempCustomFieldArray objectAtIndex: i];
                                NSString *udfType=[udfDict objectForKey:@"type"];
                                NSString *udfName=[udfDict objectForKey:@"name"];
                                NSString *udfUri=[udfDict objectForKey:@"uri"];

                                if ([udfType isEqualToString:TEXT_UDF_TYPE])
                                {
                                    NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                    if (isRowEditable==NO && [defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                                    {
                                        defaultValue=RPLocalizedString(NONE_STRING, @"");
                                    }
                                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
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
                                    int defaultDecimalValue=[[udfDict objectForKey:@"defaultDecimalValue"] intValue];
                                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
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
                                    if (([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])||(isRowEditable==NO &&[tempDefaultValue isKindOfClass:[NSString class]]&& [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]))
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
                                    [udfArray addObject:udfDetails];

                                }
                                else if([udfType isEqualToString:DROPDOWN_UDF_TYPE])
                                {
                                    NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                    NSString *dropDownOptionUri=[udfDict objectForKey:@"dropDownOptionUri"];
                                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                    [udfDetails setFieldName:udfName];
                                    [udfDetails setFieldType:UDFType_DROPDOWN];
                                    [udfDetails setFieldValue:defaultValue];
                                    [udfDetails setUdfIdentity:udfUri];
                                    [udfDetails setDropdownOptionUri:dropDownOptionUri];
                                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                                    [udfArray addObject:udfDetails];

                                }




                            }//Implementation for US9371//JUHI
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
                                    if (isRowEditable==NO && [defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                                    {
                                        defaultValue=RPLocalizedString(NONE_STRING, @"");
                                    }
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
                                    if (([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])||(isRowEditable==NO &&[tempDefaultValue isKindOfClass:[NSString class]]&& [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]))
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
                                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                    NSString *dropDownOptionUri=[udfDict objectForKey:@"dropDownOptionUri"];
                                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                    [udfDetails setFieldName:udfName];
                                    [udfDetails setFieldType:UDFType_DROPDOWN];
                                    [udfDetails setFieldValue:defaultValue];
                                    [udfDetails setUdfIdentity:udfUri];
                                    [udfDetails setDropdownOptionUri:dropDownOptionUri];
                                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                                    [rowUdfArray addObject:udfDetails];

                                }




                            }
                            [tsEntryObject setIsRowEditable:isRowEditable];
                            [tsEntryObject setTimeEntryComments:comments];
                            if(isGen4StandardTimesheet)
                            {
                                [tsEntryObject setTimeEntryCellOEFArray:[self constructCellOEFObjectForTimeSheetUri:self.timesheetURI andtimesheetFormat:GEN4_STANDARD_TIMESHEET andOEFLevel:TIMESHEET_CELL_OEF andTimePunchUri:rowUri]];
                                [tsEntryObject setTimeEntryRowOEFArray:[self constructCellOEFObjectForTimeSheetUri:self.timesheetURI andtimesheetFormat:GEN4_STANDARD_TIMESHEET andOEFLevel:TIMESHEET_ROW_OEF andTimePunchUri:rowUri]];
                            }
                            else if(isGen4DailyWidgetTimesheetTimesheet)
                            {

                                [tsEntryObject setTimeEntryDailyFieldOEFArray:[self constructDailyWidgetOEFObjectForTimeSheetUri:self.timesheetURI andtimesheetFormat:GEN4_DAILY_WIDGET_TIMESHEET andOEFLevel:DAILY_WIDGET_DAYLEVEL_OEF andTimePunchUri:rowUri]];
                            }
                            else
                            {
                                [tsEntryObject setTimeEntryUdfArray:udfArray];
                                [tsEntryObject setTimeEntryRowUdfArray:rowUdfArray];

                            }

                            [tsEntryObject setTimeEntryDate:todayDate];
                            [tsEntryObject setMultiDayInOutEntry:multiDayInOutDict];
                            [tsEntryObject setTimeAllocationUri:@""];
                            [tsEntryObject setTimePunchUri:@""];
                            [tsEntryObject setTimeEntryHoursInHourFormat:@""];
                            [tsEntryObject setTimeEntryHoursInDecimalFormat:[Util getRoundedValueFromDecimalPlaces: [durationDecimal doubleValue ]withDecimalPlaces:2 ]];
                            [tsEntryObject setTimeEntryActivityName:activityName];
                            [tsEntryObject setTimeEntryActivityUri:activityUri];
                            [tsEntryObject setTimeEntryBillingName:billingName];
                            [tsEntryObject setTimeEntryBillingUri:billingUri];
                            [tsEntryObject setTimeEntryTaskName:taskName];
                            [tsEntryObject setTimeEntryTaskUri:taskUri];
                            [tsEntryObject setTimesheetUri:timesheetURI];
                            [tsEntryObject setRowUri:rowUri];
                            [tsEntryObject setRownumber:rowNumber];
                            [tsEntryObject setHasTimeEntryValue:hasTimeEntryValue];

                            [temptimesheetEntryDataArray addObject:tsEntryObject];


                        }
                        else
                        {
                            //No entry available
                            TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc] init];

                            NSDateFormatter *formatter=[[NSDateFormatter alloc] init];

                            NSLocale *locale=[NSLocale currentLocale];
                            [formatter setLocale:locale];
                            [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                            [formatter setDateFormat:@"EEEE, dd MMM yyyy"];
                            NSDate *todayDate=[formatter dateFromString:dateString];
                            BOOL isRowEditable=NO;
                            if ([[dict objectForKey:@"entryType"] isEqualToString:Time_Entry_Key])
                            {
                                if ([dict objectForKey:@"endDateAllowedTime"]!=nil && ![[dict objectForKey:@"endDateAllowedTime"] isKindOfClass:[NSNull class]] && [dict objectForKey:@"startDateAllowedTime"]!=nil && ![[dict objectForKey:@"startDateAllowedTime"] isKindOfClass:[NSNull class]]) {
                                    NSDate *endDateAllowed=[Util convertTimestampFromDBToDate:[dict objectForKey:@"endDateAllowedTime"]];
                                    NSDate *startDateAllowed=[Util convertTimestampFromDBToDate:[dict objectForKey:@"startDateAllowedTime"]];
                                    isRowEditable=[Util date:todayDate isBetweenDate:startDateAllowed andDate:endDateAllowed];
                                }
                                else
                                {
                                    isRowEditable=YES;
                                }
                            }



                            NSMutableDictionary *multiDayInOutDict=[NSMutableDictionary dictionary];
                            NSString *projectName=[dict objectForKey:@"projectName"];
                            NSString *projectUri=[dict objectForKey:@"projectUri"];
                            NSString *clientName=[dict objectForKey:@"clientName"];
                            NSString *clientUri=[dict objectForKey:@"clientUri"];
                            //MOBI-746
                            NSString *programName=[dict objectForKey:@"programName"];
                            NSString *programUri=[dict objectForKey:@"programUri"];
                            NSString *timeoffName=[dict objectForKey:@"timeOffTypeName"];
                            NSString *timeoffUri=[dict objectForKey:@"timeOffUri"];
                            NSString *billingName=[dict objectForKey:@"billingName"];
                            NSString *billingUri=[dict objectForKey:@"billingUri"];
                            NSString *activityName=[dict objectForKey:@"activityName"];
                            NSString *activityUri=[dict objectForKey:@"activityUri"];
                            NSString *taskName=[dict objectForKey:@"taskName"];
                            NSString *taskUri=[dict objectForKey:@"taskUri"];
                            NSString *entryType=[dict objectForKey:@"entryType"];

                            NSString *rowUri=nil;
                            if (!isGen4StandardTimesheet)
                            {
                                rowUri=[dict objectForKey:@"rowUri"];
                            }

                            NSString *rowNumber=[dict objectForKey:@"rowNumber"];

                            NSMutableArray *tempCustomFieldArray=nil;
                            NSMutableArray *tempRowCustomFieldArray=nil;//Implementation for US9371//JUHI
                            if (timeoffName!=nil && timeoffUri !=nil && ![timeoffUri isKindOfClass:[NSNull class]] &&![timeoffName isKindOfClass:[NSNull class]] && ![timeoffName isEqualToString:@""]&& ![timeoffUri isEqualToString:@""])
                            {
                                if ([entryType isEqualToString:Time_Off_Key])
                                {
                                    [tsEntryObject setEntryType:Time_Off_Key];
                                    tempCustomFieldArray=[self getUDFArrayForModuleName:TIMEOFF_UDF andEntryDate:[todayDate dateByAddingDays:100] andEntryType:entryType andRowUri:rowUri isRowEditable:YES];//passing hacked date since entry is empty and created forcefully
                                }
                                else
                                {
                                    [tsEntryObject setEntryType:Adhoc_Time_OffKey];
                                    tempCustomFieldArray=[self getUDFArrayForAdhocTimeoffInStandard:TIMEOFF_UDF andEntryType:entryType andRowUri:rowUri];
                                    isRowEditable=YES;
                                }

                                [tsEntryObject setIsTimeoffSickRowPresent:YES];
                                [tsEntryObject setTimeEntryTimeOffName:timeoffName];
                                [tsEntryObject setTimeEntryTimeOffUri:timeoffUri];
                                [tsEntryObject setTimeEntryProjectName:@""];
                                [tsEntryObject setTimeEntryProjectUri:@""];
                                [tsEntryObject setTimeEntryClientName:nil];
                                [tsEntryObject setTimeEntryClientUri:nil];
                                //MOBI-746
                                [tsEntryObject setTimeEntryProgramName:nil];
                                [tsEntryObject setTimeEntryProgramUri:nil];
                            }
                            else
                            {
                                if(isGen4DailyWidgetTimesheetTimesheet)
                                {

                                    [tsEntryObject setTimeEntryDailyFieldOEFArray:[self constructDailyWidgetOEFObjectForTimeSheetUri:self.timesheetURI andtimesheetFormat:GEN4_DAILY_WIDGET_TIMESHEET andOEFLevel:DAILY_WIDGET_DAYLEVEL_OEF andTimePunchUri:rowUri]];
                                }
                                else if (!isGen4StandardTimesheet)
                                {
                                    tempCustomFieldArray=[self getUDFArrayForModuleName:TIMESHEET_CELL_UDF andEntryDate:[todayDate dateByAddingDays:100] andEntryType:entryType andRowUri:rowUri isRowEditable:isRowEditable];//passing hacked date since entry is empty and created forcefully
                                    tempRowCustomFieldArray=[self getUDFArrayForModuleName:TIMESHEET_ROW_UDF andEntryDate:todayDate andEntryType:entryType andRowUri:rowUri isRowEditable:YES];
                                }
                                else if(isGen4StandardTimesheet)
                                {

                                    [tsEntryObject setTimeEntryCellOEFArray:[self constructCellOEFObjectForTimeSheetUri:self.timesheetURI andtimesheetFormat:GEN4_STANDARD_TIMESHEET andOEFLevel:TIMESHEET_CELL_OEF andTimePunchUri:rowUri]];
                                    [tsEntryObject setTimeEntryRowOEFArray:[self constructCellOEFObjectForTimeSheetUri:self.timesheetURI andtimesheetFormat:GEN4_STANDARD_TIMESHEET andOEFLevel:TIMESHEET_ROW_OEF andTimePunchUri:rowUri]];
                                }
                                [tsEntryObject setIsTimeoffSickRowPresent:NO];
                                [tsEntryObject setTimeEntryTimeOffName:@""];
                                [tsEntryObject setTimeEntryTimeOffUri:@""];
                                [tsEntryObject setTimeEntryProjectName:projectName];
                                [tsEntryObject setTimeEntryProjectUri:projectUri];
                                [tsEntryObject setTimeEntryClientName:clientName];
                                [tsEntryObject setTimeEntryClientUri:clientUri];
                                //MOBI-746
                                [tsEntryObject setTimeEntryProgramName:programName];
                                [tsEntryObject setTimeEntryProgramUri:programUri];
                            }
                            NSMutableArray *udfArray=[[NSMutableArray alloc]init];
                            for (int i=0; i<[tempCustomFieldArray count]; i++)
                            {
                                NSDictionary *udfDict = [tempCustomFieldArray objectAtIndex: i];
                                NSString *udfType=[udfDict objectForKey:@"type"];
                                NSString *udfName=[udfDict objectForKey:@"name"];
                                NSString *udfUri=[udfDict objectForKey:@"uri"];

                                if ([udfType isEqualToString:TEXT_UDF_TYPE])
                                {
                                    NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                    if (isRowEditable==NO && [defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                                    {
                                        defaultValue=RPLocalizedString(NONE_STRING, @"");
                                    }
                                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
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
                                    int defaultDecimalValue=[[udfDict objectForKey:@"defaultDecimalValue"] intValue];
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
                                    if (([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])||(isRowEditable==NO && [tempDefaultValue isKindOfClass:[NSString class]] &&[tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]))
                                    {
                                        defaultValue=RPLocalizedString(NONE_STRING, @"");
                                    }
                                    else{//Implemented for US8763_HandleWhenDateUDFDoesNotHaveDefaultValue//JUHI
                                        if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]) {
                                            defaultValue=RPLocalizedString(SELECT_STRING, @"");
                                        }
                                        else{
                                            NSDate *date=(NSDate *)[udfDict objectForKey:@"defaultValue"];
                                            defaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:date]];
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
                                    [udfArray addObject:udfDetails];

                                }
                                else if([udfType isEqualToString:DROPDOWN_UDF_TYPE])
                                {
                                    NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                    NSString *dropDownOptionUri=[udfDict objectForKey:@"dropDownOptionUri"];
                                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                    [udfDetails setFieldName:udfName];
                                    [udfDetails setFieldType:UDFType_DROPDOWN];
                                    [udfDetails setFieldValue:defaultValue];
                                    [udfDetails setUdfIdentity:udfUri];
                                    [udfDetails setDropdownOptionUri:dropDownOptionUri];
                                    [udfDetails setSystemDefaultValue:systemDefaultValue];
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
                                    if (isRowEditable==NO && [defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                                    {
                                        defaultValue=RPLocalizedString(NONE_STRING, @"");
                                    }
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
                                    if (([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])||(isRowEditable==NO &&[tempDefaultValue isKindOfClass:[NSString class]]&& [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]))
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
                                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                    NSString *dropDownOptionUri=[udfDict objectForKey:@"dropDownOptionUri"];
                                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                    [udfDetails setFieldName:udfName];
                                    [udfDetails setFieldType:UDFType_DROPDOWN];
                                    [udfDetails setFieldValue:defaultValue];
                                    [udfDetails setUdfIdentity:udfUri];
                                    [udfDetails setDropdownOptionUri:dropDownOptionUri];
                                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                                    [rowUdfArray addObject:udfDetails];
                                    
                                }
                                
                                
                                
                                
                            }
                            [tsEntryObject setIsRowEditable:isRowEditable];
                            [tsEntryObject setTimeEntryDate:todayDate];
                            [tsEntryObject setMultiDayInOutEntry:multiDayInOutDict];
                            [tsEntryObject setTimeAllocationUri:@""];
                            [tsEntryObject setTimePunchUri:@""];
                            [tsEntryObject setTimeEntryHoursInHourFormat:@""];
                            [tsEntryObject setTimeEntryHoursInDecimalFormat:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]];
                            [tsEntryObject setTimeEntryActivityName:activityName];
                            [tsEntryObject setTimeEntryActivityUri:activityUri];
                            [tsEntryObject setTimeEntryBillingName:billingName];
                            [tsEntryObject setTimeEntryBillingUri:billingUri];
                            [tsEntryObject setTimeEntryTaskName:taskName];
                            [tsEntryObject setTimeEntryTaskUri:taskUri];
                            [tsEntryObject setTimeEntryComments:@""];
                            [tsEntryObject setTimeEntryUdfArray:udfArray];
                            [tsEntryObject setTimesheetUri:timesheetURI];
                            if (isGen4StandardTimesheet && (timeoffName!=nil && ![timeoffName isKindOfClass:[NSNull class]]))
                            {
                                [tsEntryObject setRowUri:[dict objectForKey:@"rowUri"]];
                            }
                            else
                            {
                                [tsEntryObject setRowUri:rowUri];
                            }
                            
                            [tsEntryObject setTimeEntryRowUdfArray:rowUdfArray];//Implementation for US9371//JUHI
                            [tsEntryObject setRownumber:rowNumber];
                            [temptimesheetEntryDataArray addObject:tsEntryObject];
                            
                        }
                        
                        
                    }
                }


                [timesheetDataArray addObject:temptimesheetEntryDataArray];


            }
            else
            {
                //No Entry Available on this date.insert Blank entries
                NSMutableArray *timesheetArray=nil;
                //Approval context Flow for Timesheets
                if (([self.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [parentDelegate isKindOfClass:[ApprovalsScrollViewController class]] || [self.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]] || [parentDelegate isKindOfClass:[SupervisorDashboardNavigationController class]]))
                {
                    if (!isGen4DailyWidgetTimesheetTimesheet)
                    {
                        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)parentDelegate;
                        ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
                        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                        {
                            timesheetArray=[approvalsModel getAllPendingDistinctStandardTimeEntriesInfoFromDBForTimesheetUri:timesheetURI];
                        }
                        else
                        {
                            timesheetArray=[approvalsModel getAllPreviousDistinctStandardTimeEntriesInfoFromDBForTimesheetUri:timesheetURI];
                            
                            
                        }
                    }

                }
                //Users context Flow for Timesheets
                else if([parentDelegate isKindOfClass:[CurrentTimesheetViewController class]] || isGen4StandardTimesheet)
                {
                    TimesheetModel *timeSheetModel=[[TimesheetModel alloc]init];
                    timesheetArray=[timeSheetModel getAllDistinctStandardTimeEntriesInfoFromDBForTimesheetUri:timesheetURI];

                }


                for (int i=0; i<[timesheetArray count]; i++)
                {
                    TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc] init];

                    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];

                    NSLocale *locale=[NSLocale currentLocale];
                    [formatter setLocale:locale];
                    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                    [formatter setDateFormat:@"EEEE, dd MMM yyyy"];
                    NSDate *todayDate=[formatter dateFromString:dateString];
                    BOOL isRowEditable=NO;
                    NSString *projectName=@"";
                    NSString *projectUri = @"";
                    NSString *clientName=@"";
                    NSString *clientUri=@"";
                    NSString *programName=@"";
                    NSString *programUri=@"";
                    NSString *timeoffName=@"";
                    NSString *timeoffUri=@"";
                    NSString *entryType=@"";
                    NSString *billingName=@"";
                    NSString *billingUri=@"";
                    NSString *activityName=@"";
                    NSString *activityUri=@"";
                    NSString *taskName=@"";
                    NSString *taskUri=@"";
                    NSString *rowUri=@"";
                    NSString *rowNumber=@"";
                    
                    NSMutableDictionary *multiDayInOutDict=[NSMutableDictionary dictionary];
                    if ([[timesheetArray objectAtIndex:i] count]>0)
                    {
                        if ([[[[timesheetArray objectAtIndex:i] objectAtIndex:0] objectForKey:@"entryType"] isEqualToString:Time_Entry_Key])
                        {
                            if ([[[timesheetArray objectAtIndex:i] objectAtIndex:0] objectForKey:@"endDateAllowedTime"]!=nil && ![[[[timesheetArray objectAtIndex:i] objectAtIndex:0] objectForKey:@"endDateAllowedTime"] isKindOfClass:[NSNull class]] && [[[timesheetArray objectAtIndex:i] objectAtIndex:0] objectForKey:@"startDateAllowedTime"]!=nil && ![[[[timesheetArray objectAtIndex:i] objectAtIndex:0] objectForKey:@"startDateAllowedTime"] isKindOfClass:[NSNull class]])
                            {
                                NSDate *endDateAllowed=[Util convertTimestampFromDBToDate:[[[timesheetArray objectAtIndex:i] objectAtIndex:0] objectForKey:@"endDateAllowedTime"]];
                                NSDate *startDateAllowed=[Util convertTimestampFromDBToDate:[[[timesheetArray objectAtIndex:i] objectAtIndex:0] objectForKey:@"startDateAllowedTime"]];
                                isRowEditable=[Util date:todayDate isBetweenDate:startDateAllowed andDate:endDateAllowed];
                            }
                            else
                            {
                                isRowEditable=YES;
                            }
                        }
                        
                        projectName=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"projectName"];
                        projectUri=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"projectUri"];
                        clientName=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"clientName"];
                        clientUri=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"clientUri"];
                        //MOBI-746
                        programName=[[[timesheetArray objectAtIndex:i] objectAtIndex:0] objectForKey:@"programName"];
                        programUri=[[[timesheetArray objectAtIndex:i] objectAtIndex:0] objectForKey:@"programUri"];
                        timeoffName=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"timeOffTypeName"];
                        timeoffUri=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"timeOffUri"];
                        entryType=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"entryType"];
                        billingName=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"billingName"];
                        billingUri=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"billingUri"];
                        activityName=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"activityName"];
                        activityUri=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"activityUri"];
                        taskName=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"taskName"];
                        taskUri=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"taskUri"];
                        
                        if (!isGen4StandardTimesheet || (timeoffName!=nil && ![timeoffName isKindOfClass:[NSNull class]]))
                        {
                            rowUri=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"rowUri"];
                            
                        }
                        
                        rowNumber =[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"rowNumber"];
                    }
                    
                    NSMutableArray *tempCustomFieldArray=nil;
                    NSMutableArray *tempRowCustomFieldArray=nil;//Implementation for US9371//JUHI
                    if ([entryType isEqualToString:Time_Entry_Key])
                    {
                        if(isGen4DailyWidgetTimesheetTimesheet)
                        {

                            [tsEntryObject setTimeEntryDailyFieldOEFArray:[self constructDailyWidgetOEFObjectForTimeSheetUri:self.timesheetURI andtimesheetFormat:GEN4_DAILY_WIDGET_TIMESHEET andOEFLevel:DAILY_WIDGET_DAYLEVEL_OEF andTimePunchUri:rowUri]];
                        }
                        else if (!isGen4StandardTimesheet)
                        {
                            tempCustomFieldArray=[self getUDFArrayForModuleName:TIMESHEET_CELL_UDF andEntryDate:todayDate andEntryType:entryType andRowUri:rowUri isRowEditable:isRowEditable];
                            tempRowCustomFieldArray=[self getUDFArrayForModuleName:TIMESHEET_ROW_UDF andEntryDate:todayDate andEntryType:entryType andRowUri:rowUri isRowEditable:YES];
                        }
                        else if(isGen4StandardTimesheet)
                        {

                            [tsEntryObject setTimeEntryCellOEFArray:[self constructCellOEFObjectForTimeSheetUri:self.timesheetURI andtimesheetFormat:GEN4_STANDARD_TIMESHEET andOEFLevel:TIMESHEET_CELL_OEF andTimePunchUri:rowUri]];
                            [tsEntryObject setTimeEntryRowOEFArray:[self constructCellOEFObjectForTimeSheetUri:self.timesheetURI andtimesheetFormat:GEN4_STANDARD_TIMESHEET andOEFLevel:TIMESHEET_ROW_OEF andTimePunchUri:rowUri]];
                        }
                        [tsEntryObject setIsTimeoffSickRowPresent:NO];
                        [tsEntryObject setTimeEntryTimeOffName:@""];
                        [tsEntryObject setTimeEntryTimeOffUri:@""];
                        [tsEntryObject setTimeEntryProjectName:projectName];
                        [tsEntryObject setTimeEntryProjectUri:projectUri];
                        [tsEntryObject setTimeEntryClientName:clientName];
                        [tsEntryObject setTimeEntryClientUri:clientUri];
                        //MOBI-746
                        [tsEntryObject setTimeEntryProgramName:programName];
                        [tsEntryObject setTimeEntryProgramUri:programUri];
                    }
                    else
                    {
                        if ([entryType isEqualToString:Time_Off_Key])
                        {
                            [tsEntryObject setEntryType:Time_Off_Key];
                            tempCustomFieldArray=[self getUDFArrayForModuleName:TIMEOFF_UDF andEntryDate:todayDate andEntryType:entryType andRowUri:rowUri isRowEditable:YES];
                        }
                        else
                        {
                            [tsEntryObject setEntryType:Adhoc_Time_OffKey];
                            tempCustomFieldArray=[self getUDFArrayForAdhocTimeoffInStandard:TIMEOFF_UDF andEntryType:entryType andRowUri:rowUri];
                            isRowEditable=TRUE;
                        }

                        [tsEntryObject setIsTimeoffSickRowPresent:YES];
                        [tsEntryObject setTimeEntryTimeOffName:timeoffName];
                        [tsEntryObject setTimeEntryTimeOffUri:timeoffUri];
                        [tsEntryObject setTimeEntryProjectName:@""];
                        [tsEntryObject setTimeEntryProjectUri:@""];
                        [tsEntryObject setTimeEntryClientName:nil];
                        [tsEntryObject setTimeEntryClientUri:nil];
                        //MOBI-746
                        [tsEntryObject setTimeEntryProgramName:nil];
                        [tsEntryObject setTimeEntryProgramUri:nil];
                    }

                    NSMutableArray *udfArray=[[NSMutableArray alloc]init];
                    for (int i=0; i<[tempCustomFieldArray count]; i++)
                    {
                        NSDictionary *udfDict = [tempCustomFieldArray objectAtIndex: i];
                        NSString *udfType=[udfDict objectForKey:@"type"];
                        NSString *udfName=[udfDict objectForKey:@"name"];
                        NSString *udfUri=[udfDict objectForKey:@"uri"];

                        if ([udfType isEqualToString:TEXT_UDF_TYPE])
                        {
                            NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                            if (isRowEditable==NO && [defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                            {
                                defaultValue=RPLocalizedString(NONE_STRING, @"");
                            }
                            NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
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
                            int defaultDecimalValue=[[udfDict objectForKey:@"defaultDecimalValue"] intValue];
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
                            if (([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])||(isRowEditable==NO && [tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]))
                            {
                                defaultValue=RPLocalizedString(NONE_STRING, @"");
                            }
                            else{//Implemented for US8763_HandleWhenDateUDFDoesNotHaveDefaultValue//JUHI
                                if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]) {
                                    defaultValue=RPLocalizedString(SELECT_STRING, @"");
                                }
                                else{
                                    NSDate *date=(NSDate *)[udfDict objectForKey:@"defaultValue"];
                                    defaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:date]];
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
                            [udfArray addObject:udfDetails];

                        }
                        else if([udfType isEqualToString:DROPDOWN_UDF_TYPE])
                        {
                            NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                            NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                            NSString *dropDownOptionUri=[udfDict objectForKey:@"dropDownOptionUri"];
                            EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                            [udfDetails setFieldName:udfName];
                            [udfDetails setFieldType:UDFType_DROPDOWN];
                            [udfDetails setFieldValue:defaultValue];
                            [udfDetails setUdfIdentity:udfUri];
                            [udfDetails setDropdownOptionUri:dropDownOptionUri];
                            [udfDetails setSystemDefaultValue:systemDefaultValue];
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
                            if (isRowEditable==NO && [defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                            {
                                defaultValue=RPLocalizedString(NONE_STRING, @"");
                            }
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
                            if (([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])||(isRowEditable==NO &&[tempDefaultValue isKindOfClass:[NSString class]]&& [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]))
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
                            NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                            NSString *dropDownOptionUri=[udfDict objectForKey:@"dropDownOptionUri"];
                            EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                            [udfDetails setFieldName:udfName];
                            [udfDetails setFieldType:UDFType_DROPDOWN];
                            [udfDetails setFieldValue:defaultValue];
                            [udfDetails setUdfIdentity:udfUri];
                            [udfDetails setDropdownOptionUri:dropDownOptionUri];
                            [udfDetails setSystemDefaultValue:systemDefaultValue];
                            [rowUdfArray addObject:udfDetails];

                        }




                    }



                    [tsEntryObject setIsRowEditable:isRowEditable];
                    [tsEntryObject setTimeEntryDate:todayDate];
                    [tsEntryObject setMultiDayInOutEntry:multiDayInOutDict];
                    [tsEntryObject setTimeAllocationUri:@""];
                    [tsEntryObject setTimePunchUri:@""];
                    [tsEntryObject setTimeEntryHoursInHourFormat:@""];
                    [tsEntryObject setTimeEntryHoursInDecimalFormat:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]];
                    [tsEntryObject setTimeEntryActivityName:activityName];
                    [tsEntryObject setTimeEntryActivityUri:activityUri];
                    [tsEntryObject setTimeEntryBillingName:billingName];
                    [tsEntryObject setTimeEntryBillingUri:billingUri];
                    [tsEntryObject setTimeEntryTaskName:taskName];
                    [tsEntryObject setTimeEntryTaskUri:taskUri];
                    [tsEntryObject setTimeEntryComments:@""];
                    [tsEntryObject setTimeEntryUdfArray:udfArray];
                    [tsEntryObject setTimesheetUri:timesheetURI];
                    [tsEntryObject setRowUri:rowUri];
                    [tsEntryObject setTimeEntryRowUdfArray:rowUdfArray];//Implementation for US9371//JUHI
                    [tsEntryObject setRownumber:rowNumber];
                    [temptimesheetEntryDataArray addObject:tsEntryObject];


                }


                if (isGen4DailyWidgetTimesheetTimesheet)
                {
                    temptimesheetEntryDataArray=[self createDayLevelDailyWidgetOEFArrayForDate:dateString andTimeEntries:nil];


                }


                [timesheetDataArray addObject:temptimesheetEntryDataArray];


            }


        }



    }


    self.pageControl.currentPage = currentlySelectedPage;
    [self changeView:currentlySelectedPage];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];





}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: START_AUTOSAVE object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(backAndSaveAction:)
                                                 name: START_AUTOSAVE
                                               object: nil];
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate performSelector:@selector(startSyncTimer) withObject:nil];
    if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
    {
        MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)delegate;
        ctrl.isGen4RequestInQueue=YES;
        self.isEditForGen4InQueue=NO;
        [[NSNotificationCenter defaultCenter] removeObserver:ctrl name:SAVE_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:ctrl name:SAVE_BREAK_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //self.isTimeOffSave = NO;
    CGRect frame = self.view.bounds;
    frame.origin.y += Page_Control_View_Height;
    frame.size.height -= Page_Control_View_Height;
    self.scrollView.frame = frame;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver: self name: START_AUTOSAVE object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: @"AutoSaveRequestServed" object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PULL_TO_REFRESH_TIMEOFFS_RECEIVED_NOTIFICATION object:nil];

    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate performSelector:@selector(stopSyncTimer) withObject:nil];
    if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
    {
        MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)delegate;
        if (!isEditForGen4InQueue && !ctrl.isGen4RequestInQueue)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:ctrl name:SAVE_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:ctrl name:SAVE_BREAK_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
        }
        if (!isAddTimeEntryClicked)
        {
            ctrl.isGen4RequestInQueue=NO;

        }
        isAddTimeEntryClicked=NO;

        if (hasUserChangedAnyValue)
        {
            if ([self.trackTimeEntryChangeDelegate isKindOfClass:[WidgetTSViewController class]])
            {
                [self.trackTimeEntryChangeDelegate sendValidationCheckRequestOnlyOnChange];
            }
        }


    }


    UINavigationController *selectedNavigationController = appDelegate.rootTabBarController.selectedViewController;

    NSLog(@"%@",selectedNavigationController);

    if ([selectedNavigationController isKindOfClass:[TimesheetNavigationController class]])
    {
        TimesheetModel *tsModel=[[TimesheetModel alloc]init];
        NSArray *timesheetInfoArray=nil;
        timesheetInfoArray=[tsModel getTimeSheetInfoSheetIdentity:timesheetURI];

        NSString *tsFormat=[[timesheetInfoArray objectAtIndex:0] objectForKey:@"timesheetFormat"];

        if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
        {
            if([tsFormat isEqualToString:GEN4_INOUT_TIMESHEET])
            {
                NSArray *stackViewControllers = selectedNavigationController.viewControllers;

                if (stackViewControllers.count==1)
                {
                    // View is disappearing because tab bar was tapped twice
                    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                    if (![timesheetModel isTimesheetContainsInflightSaveOperation:timesheetURI])
                    {
                        [[appDelegate.injector getInstance:[BaseSyncOperationManager class]] startSync];
                    }
                    return;
                }

                else if (stackViewControllers.count > 1 && [stackViewControllers objectAtIndex:stackViewControllers.count-2] == self) {
                    // View is disappearing because a new view controller was pushed onto the stack
                    NSLog(@"New view controller was pushed");
                } else if ([stackViewControllers indexOfObject:self] == NSNotFound) {
                    // View is disappearing because it was popped from the stack
                    NSLog(@"View controller was popped");
                    BOOL isUpdatedEntries = [tsModel checkIfTimeEntriesModifiedOrDeleted:timesheetURI timesheetFormat:tsFormat];
                    if (isUpdatedEntries)
                    {
                        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                        if (![timesheetModel isTimesheetContainsInflightSaveOperation:timesheetURI])
                        {
                            [tsModel updateTimesheetWithOperationName:TIMESHEET_SAVE_OPERATION andTimesheetURI:self.timesheetURI];
                            [tsModel updateAttestationStatusForTimesheetIdentity:timesheetURI withStatus:NO];
                            if (![timesheetModel isTimesheetContainsInflightSaveOperation:timesheetURI])
                            {
                                [[appDelegate.injector getInstance:[BaseSyncOperationManager class]] startSync];
                            }

                        }


                    }
                }
            }
        }

    }

}


- (void) changeView: (NSInteger) aPageControl
{
    NSInteger page = self.pageControl.currentPage;

    [self loadScrollViewWithPage:page fromDayButtonClick:NO];

    CGRect bounds = self.scrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * page;
    [self.scrollView scrollRectToVisible:bounds animated:NO];

    self.isFirstTimeLoad=NO;
}

-(void)timesheetDayBtnClickedWithTag:(NSInteger)page
{

    if (page != self.currentlySelectedPage) {
        self.currentlySelectedPage=page;
        [self loadScrollViewWithPage:page fromDayButtonClick:YES];
        
        self.previouslySelectedPage = page;
        
        CGRect bounds = self.scrollView.bounds;
        bounds.origin.x = CGRectGetWidth(bounds) * page;
        [self.scrollView scrollRectToVisible:bounds animated:NO];
        self.isFirstTimeLoad=NO;
    }
}

-(void)createNextviewController:(NSInteger)page
{
    [self loadScrollViewWithPage:page fromDayButtonClick:YES];
}


-(void)timesheetDayBtnHighLightOnCrossOver:(NSInteger)page
{

}

-(void)loadNextPageOnCrossoverSplit:(NSInteger)page
{
    id sender=nil;
    [sender setTag:page];
    if (daySelectionScrollViewDelegate!=nil &&[daySelectionScrollViewDelegate isKindOfClass:[DaySelectionScrollView class]])
    {
        [daySelectionScrollViewDelegate timesheetDayBtnHighLightOnCrossOver:page];
    }
}

-(void)backAndSaveAction:(id)sender
{
    NSArray *timesheetInfoArray= [self getTimesheetInfoArray];
    BOOL isGen4timesheet = [self isGen4Timesheet:timesheetInfoArray];
    if (!isGen4timesheet)
    {
        NSMutableArray *arrayOfEntries=[NSMutableArray array];
        for (int i=0; i<[timesheetDataArray count]; i++)
        {
            NSMutableArray *entryDataArray=[timesheetDataArray objectAtIndex:i];

            for (int k=0; k<[entryDataArray count]; k++)
            {
                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[entryDataArray objectAtIndex:k];

                if ([tsEntryObject isTimeoffSickRowPresent])
                {
                    if (isMultiDayInOutTimesheetUser)
                    {
                        if ([tsEntryObject.entryType isEqualToString:Adhoc_Time_OffKey ]) {
                            [arrayOfEntries addObject:[entryDataArray objectAtIndex:k]];
                        }
                    }
                    else
                    {
                        [arrayOfEntries addObject:[entryDataArray objectAtIndex:k]];
                    }

                }
                else
                {

                    if (isMultiDayInOutTimesheetUser)
                    {
                        NSMutableDictionary *dict=[tsEntryObject multiDayInOutEntry];
                        NSString *inTime=[dict objectForKey:@"in_time"];
                        NSString *outTime=[dict objectForKey:@"out_time"];
                        if ((inTime!=nil &&![inTime isEqualToString:@""]) || (outTime!=nil&&![outTime isEqualToString:@""]))
                        {
                            [arrayOfEntries addObject:[entryDataArray objectAtIndex:k]];
                        }
                    }
                    else
                    {
                        [arrayOfEntries addObject:[entryDataArray objectAtIndex:k]];
                    }

                }

            }
        }


        if (sender!=nil && [sender isKindOfClass:[UIBarButtonItem class]])
        {

            if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
            {
                [Util showOfflineAlert];
                return;

            }
            [self.view endEditing:YES];
            UIViewController *currentTimesheetCtrl=[self.viewControllers objectAtIndex:self.pageControl.currentPage];
            if ([currentTimesheetCtrl isKindOfClass:[MultiDayInOutViewController class]])
            {
                NSString *tsFormat=[[timesheetInfoArray objectAtIndex:0] objectForKey:@"timesheetFormat"];
                if (tsFormat!=nil &&![tsFormat isKindOfClass:[NSNull class]])
                {
                    if ([tsFormat isEqualToString:INOUT_TIMESHEET])
                    {
                         [(MultiDayInOutViewController *)currentTimesheetCtrl doneButtonPressed];
                    }
                    
                }
               
            }
            
            if ([parentDelegate isKindOfClass:[CurrentTimesheetViewController class]]&&[self.navigationController isKindOfClass:[TimesheetNavigationController class]]&& self.hasUserChangedAnyValue)
            {
                if ([timesheetStatus isEqualToString:NOT_SUBMITTED_STATUS]||[timesheetStatus isEqualToString:REJECTED_STATUS])
                {
                    CLS_LOG(@"-----Save button clicked on TimesheetMainPageController-----");
                    [[NSNotificationCenter defaultCenter] removeObserver:parentDelegate name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
                    [[NSNotificationCenter defaultCenter] addObserver:parentDelegate selector:@selector(RecievedData) name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
                    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                    BOOL iseXteneded=NO;
                    if (multiDayInOutType==EXTENDED_IN_OUT_TIMESHEET_TYPE) {
                        iseXteneded=YES;
                    }
                    if (self.isAutoSaveInQueue)
                    {
                        self.isExplicitSaveRequested=YES;
                    }
                    else
                    {
                        //Implementation for JM-35734_DCAA compliance support//JUHI
                        [[RepliconServiceManager timesheetService]sendRequestToSaveTimesheetDataForTimesheetURI:self.timesheetURI withEntryArray:arrayOfEntries withDelegate:self isMultiInOutTimeSheetUser:self.isMultiDayInOutTimesheetUser isNewAdhocEntryDict:nil isTimesheetSubmit:NO sheetLevelUdfArray:self.sheetLevelUdfArray submitComments:nil isAutoSave:@"NO" isDisclaimerAccepted:self.isDisclaimerRequired rowUri:nil actionMode:0 isExtendedInOutUser:iseXteneded reasonForChange:nil];
                    }

                }

            }
            if (!self.isAutoSaveInQueue)
            {
                if (![self.appConfig getTimesheetSaveAndStay])
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
                [self.customPickerView removeFromSuperview];
                customPickerView=nil;
            }


        }
        else
        {

            if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
            {
                //[Util showOfflineAlert];

                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];

                [appDelegate performSelector:@selector(startSyncTimer) withObject:nil];
                return;

            }
            self.isExplicitSaveRequested=NO;
            //AUTO SAVE
            if (([timesheetStatus isEqualToString:NOT_SUBMITTED_STATUS]||[timesheetStatus isEqualToString:REJECTED_STATUS])&& self.hasUserChangedAnyValue) {

                CLS_LOG(@"-----Auto save triggered on TimesheetMainPageController-----");
                [[NSNotificationCenter defaultCenter] removeObserver:parentDelegate name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
                [[NSNotificationCenter defaultCenter] addObserver: self
                                                         selector: @selector(dataReceivedForAutoSave)
                                                             name: @"AutoSaveRequestServed"
                                                           object: nil];

                [[NSNotificationCenter defaultCenter] removeObserver: self name: START_AUTOSAVE object: nil];
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                [appDelegate performSelector:@selector(stopSyncTimer) withObject:nil];
                BOOL iseXteneded=NO;
                if (multiDayInOutType==EXTENDED_IN_OUT_TIMESHEET_TYPE) {
                    iseXteneded=YES;
                }//Implementation for JM-35734_DCAA compliance support//JUHI
                self.isAutoSaveInQueue=YES;
                [[RepliconServiceManager timesheetService]sendRequestToSaveTimesheetDataForTimesheetURI:self.timesheetURI withEntryArray:arrayOfEntries withDelegate:self isMultiInOutTimeSheetUser:self.isMultiDayInOutTimesheetUser isNewAdhocEntryDict:nil isTimesheetSubmit:NO sheetLevelUdfArray:self.sheetLevelUdfArray submitComments:nil isAutoSave:@"YES" isDisclaimerAccepted:self.isDisclaimerRequired rowUri:nil actionMode:0 isExtendedInOutUser:iseXteneded reasonForChange:nil];
            }


            else if (([timesheetStatus isEqualToString:NOT_SUBMITTED_STATUS]||[timesheetStatus isEqualToString:REJECTED_STATUS])&& !self.hasUserChangedAnyValue)
            {
                [self dataReceivedForAutoSave];
            }

        }



    }
    else{
        
        
        if (sender!=nil && [sender isKindOfClass:[UIBarButtonItem class]])
        {
            
            NSString *tsFormat=[[timesheetInfoArray objectAtIndex:0] objectForKey:@"timesheetFormat"];
            if (tsFormat!=nil &&![tsFormat isKindOfClass:[NSNull class]])
            {
                if([tsFormat isEqualToString:GEN4_INOUT_TIMESHEET])
                {
                    [self.view endEditing:YES];
                    self.hasUserChangedAnyValue = NO;
                    [self.navigationItem setLeftBarButtonItem:nil animated:NO];
                    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                    if (![timesheetModel isTimesheetContainsInflightSaveOperation:timesheetURI])
                    {
                        [timesheetModel updateTimesheetWithOperationName:TIMESHEET_SAVE_OPERATION andTimesheetURI:self.timesheetURI];
                        id<BSInjector, BSBinder> injector = [InjectorProvider injector];
                        [[injector getInstance:[BaseSyncOperationManager class]] startSync];
                        if (![self.appConfig getTimesheetSaveAndStay])
                        {
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                    }
                    else
                    {
                        [self showINProgressAlertView];
                    }

                }
                else
                {
                    if ([NetworkMonitor isNetworkAvailableForListener:self] != NO)
                    {
                        [self.view endEditing:YES];
                        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                        if (![timesheetModel isTimesheetContainsInflightSaveOperation:timesheetURI])
                        {
                            NSMutableDictionary *attestationDict=nil;
                            if ([self.navigationController isKindOfClass:[TimesheetNavigationController class]])
                            {
                                TimesheetModel *tsModel=[[TimesheetModel alloc]init];
                                attestationDict=[tsModel getAttestationDetailsFromDBForTimesheetUri:self.timesheetURI];
                                if (attestationDict)
                                {
                                    //update the attestation flag here
                                    [[RepliconServiceManager timesheetService]sendRequestUpdateTimesheetAttestationStatusForTimesheetURI:self.timesheetURI forAttestationStatusUri:ATTESTATION_STATUS_UNATTESTED];
                                }


                            }

                            [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                            
                            [self callServiceWithName:WIDGET_TIMESHEET_SAVE_SERVICE andTimeSheetURI:self.timesheetURI];
                        }
                        else
                        {
                            [self showINProgressAlertView];
                        }


                    }
                    
                    
                    else
                    {
                        [Util showOfflineAlert];
                        return;
                    }
                }
            }

        }
    }

}


/// THIS METHOD IS CALLED WHEN

-(void)dataReceivedForAutoSave
{

    self.isAutoSaveInQueue=NO;
    [[NSNotificationCenter defaultCenter] removeObserver: self name: @"AutoSaveRequestServed" object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: START_AUTOSAVE object: nil];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(backAndSaveAction:)
                                                 name: START_AUTOSAVE
                                               object: nil];

    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];

    UIViewController *allViewController = appDelegate.rootTabBarController.selectedViewController;


    if ([allViewController isKindOfClass:[TimesheetNavigationController class]])
    {


        TimesheetNavigationController *timeSheetNavController=(TimesheetNavigationController *)allViewController;
        NSArray *timesheetControllers = timeSheetNavController.viewControllers;
        for (UIViewController *viewController in timesheetControllers)
        {
            if ([viewController isKindOfClass:[TimesheetMainPageController class]])
            {
                [appDelegate performSelector:@selector(startSyncTimer) withObject:nil];
            }
        }
    }

    if (self.isExplicitSaveRequested)
    {
        self.isExplicitSaveRequested=NO;
        BOOL isGen4timesheet=NO;
       
        NSArray *timesheetInfoArray=nil;
        
        if ([self.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [parentDelegate isKindOfClass:[ApprovalsScrollViewController class]] || [self.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]] || [parentDelegate isKindOfClass:[SupervisorDashboardNavigationController class]])
        {
            ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)parentDelegate;
            ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
            if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                timesheetInfoArray=[approvalsModel getTimeSheetInfoSheetIdentityForPending:timesheetURI];
                
            }
            else
            {
                timesheetInfoArray=[approvalsModel getTimeSheetInfoSheetIdentityForPrevious:timesheetURI];
            }
        }
        else
        {
            TimesheetModel *tsModel=[[TimesheetModel alloc]init];
            timesheetInfoArray=[tsModel getTimeSheetInfoSheetIdentity:timesheetURI];
            
            
        }
        
        if ([timesheetInfoArray count]>0)
        {
            NSString *tsFormat=[[timesheetInfoArray objectAtIndex:0] objectForKey:@"timesheetFormat"];
            if (tsFormat!=nil &&![tsFormat isKindOfClass:[NSNull class]])
            {
                if ([tsFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [tsFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET] ||  [tsFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                {
                    isGen4timesheet=YES;
                }
            }

        }
        if (!isGen4timesheet)
        {
            NSMutableArray *arrayOfEntries=[NSMutableArray array];
            for (int i=0; i<[timesheetDataArray count]; i++)
            {
                NSMutableArray *entryDataArray=[timesheetDataArray objectAtIndex:i];

                for (int k=0; k<[entryDataArray count]; k++)
                {
                    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[entryDataArray objectAtIndex:k];

                    if ([tsEntryObject isTimeoffSickRowPresent])
                    {
                        if (isMultiDayInOutTimesheetUser)
                        {
                            if ([tsEntryObject.entryType isEqualToString:Adhoc_Time_OffKey ]) {
                                [arrayOfEntries addObject:[entryDataArray objectAtIndex:k]];
                            }
                        }
                        else
                        {
                            [arrayOfEntries addObject:[entryDataArray objectAtIndex:k]];
                        }

                    }
                    else
                    {

                        if (isMultiDayInOutTimesheetUser)
                        {
                            NSMutableDictionary *dict=[tsEntryObject multiDayInOutEntry];
                            NSString *inTime=[dict objectForKey:@"in_time"];
                            NSString *outTime=[dict objectForKey:@"out_time"];
                            if ((inTime!=nil &&![inTime isEqualToString:@""]) || (outTime!=nil&&![outTime isEqualToString:@""]))
                            {
                                [arrayOfEntries addObject:[entryDataArray objectAtIndex:k]];
                            }
                        }
                        else
                        {
                            [arrayOfEntries addObject:[entryDataArray objectAtIndex:k]];
                        }

                    }

                }
            }
            if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
            {
                [Util showOfflineAlert];
                return;

            }

            if ([parentDelegate isKindOfClass:[CurrentTimesheetViewController class]]&&[self.navigationController isKindOfClass:[TimesheetNavigationController class]]&& self.hasUserChangedAnyValue)
            {
                if ([timesheetStatus isEqualToString:NOT_SUBMITTED_STATUS]||[timesheetStatus isEqualToString:REJECTED_STATUS])
                {
                    CLS_LOG(@"-----Save button clicked on TimesheetMainPageController-----");
                    [[NSNotificationCenter defaultCenter] removeObserver:parentDelegate name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
                    [[NSNotificationCenter defaultCenter] addObserver:parentDelegate selector:@selector(RecievedData) name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
                    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                    BOOL iseXteneded=NO;
                    if (multiDayInOutType==EXTENDED_IN_OUT_TIMESHEET_TYPE) {
                        iseXteneded=YES;
                    }

                    //Implementation for JM-35734_DCAA compliance support//JUHI
                    [[RepliconServiceManager timesheetService]sendRequestToSaveTimesheetDataForTimesheetURI:self.timesheetURI withEntryArray:arrayOfEntries withDelegate:self isMultiInOutTimeSheetUser:self.isMultiDayInOutTimesheetUser isNewAdhocEntryDict:nil isTimesheetSubmit:NO sheetLevelUdfArray:self.sheetLevelUdfArray submitComments:nil isAutoSave:@"NO" isDisclaimerAccepted:self.isDisclaimerRequired rowUri:nil actionMode:0 isExtendedInOutUser:iseXteneded reasonForChange:nil];


                }

            }

            [self.navigationController popViewControllerAnimated:YES];
            [self.customPickerView removeFromSuperview];
            customPickerView=nil;


        }
    }


}


-(NSMutableArray *)constructCellOEFObjectForTimeSheetUri:(NSString*)timesheetUri andtimesheetFormat:(NSString *)timesheetFormat andOEFLevel:(NSString *)oefLevel andTimePunchUri:(NSString*)timePunchesUri
{
    NSMutableArray *oefObjectArr=[NSMutableArray array];
    TimesheetModel *timesheetModel = [[TimesheetModel alloc]init];
    NSArray *timesheetObjectExtensionsFieldsArr=[timesheetModel getTimesheetObjectExtensionFieldsForTimeSheetUri:timesheetUri andtimesheetFormat:timesheetFormat andOEFLevel:oefLevel];
    NSArray *timeEntryOEFArr=[timesheetModel getTimesheetEntryObjectExtensionFieldsForTimeSheetUri:timesheetUri andtimesheetEntryUri:timePunchesUri];

    for (NSDictionary *timesheetObjectExtensionsFieldsDict in timesheetObjectExtensionsFieldsArr)
    {
        OEFObject *oefObject=[[OEFObject alloc]init];
        NSString *oefUri=timesheetObjectExtensionsFieldsDict[@"uri"];
        oefObject.oefUri=oefUri;
        oefObject.oefName=timesheetObjectExtensionsFieldsDict[@"displayText"];
        oefObject.oefLevelType=oefLevel;
        oefObject.oefDefinitionTypeUri=timesheetObjectExtensionsFieldsDict[@"definitionTypeUri"];
        for (NSDictionary *timeEntryOEFDict in timeEntryOEFArr)
        {
            if ([timeEntryOEFDict[@"uri"] isEqualToString:oefUri])
            {
                NSString *definitionUri=timesheetObjectExtensionsFieldsDict[@"definitionTypeUri"];;
                if ([definitionUri isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI])
                {
                    oefObject.oefTextValue=timeEntryOEFDict[@"textValue"];
                }
                else if ([definitionUri isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI])
                {
                    oefObject.oefNumericValue=[NSString stringWithFormat:@"%@",timeEntryOEFDict[@"numericValue"]];
                }
                else if ([definitionUri isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI])
                {
                    oefObject.oefDropdownOptionUri=timeEntryOEFDict[@"dropdownOptionUri"];
                    oefObject.oefDropdownOptionValue=timeEntryOEFDict[@"dropdownOptionValue"];
                }

                break;
            }
        }


        [oefObjectArr addObject:oefObject];

    }

    return oefObjectArr;
}

-(NSMutableArray *)constructDailyWidgetOEFObjectForTimeSheetUri:(NSString*)timesheetUri andtimesheetFormat:(NSString *)timesheetFormat andOEFLevel:(NSString *)oefLevel andTimePunchUri:(NSString*)timePunchesUri
{
    NSMutableArray *oefObjectArr=[NSMutableArray array];
    TimesheetModel *timesheetModel = [[TimesheetModel alloc]init];
    NSArray *timesheetObjectExtensionsFieldsArr=[timesheetModel getTimesheetObjectExtensionFieldsForTimeSheetUri:timesheetUri andtimesheetFormat:timesheetFormat andOEFLevel:oefLevel];
    NSArray *timeEntryOEFArr=[timesheetModel getTimesheetEntryObjectExtensionFieldsForTimeSheetUri:timesheetUri andtimesheetEntryUri:timePunchesUri];

    for (NSDictionary *timesheetObjectExtensionsFieldsDict in timesheetObjectExtensionsFieldsArr)
    {
        OEFObject *oefObject=[[OEFObject alloc]init];
        NSString *oefUri=timesheetObjectExtensionsFieldsDict[@"uri"];
        oefObject.oefUri=oefUri;
        oefObject.oefName=timesheetObjectExtensionsFieldsDict[@"displayText"];
        oefObject.oefLevelType=oefLevel;
        oefObject.oefDefinitionTypeUri=timesheetObjectExtensionsFieldsDict[@"definitionTypeUri"];
        for (NSDictionary *timeEntryOEFDict in timeEntryOEFArr)
        {
            if ([timeEntryOEFDict[@"uri"] isEqualToString:oefUri])
            {
                NSString *definitionUri=timesheetObjectExtensionsFieldsDict[@"definitionTypeUri"];;
                if ([definitionUri isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI])
                {
                    oefObject.oefTextValue=timeEntryOEFDict[@"textValue"];
                }
                else if ([definitionUri isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI])
                {
                    oefObject.oefNumericValue=[NSString stringWithFormat:@"%@",timeEntryOEFDict[@"numericValue"]];
                }
                else if ([definitionUri isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI])
                {
                    oefObject.oefDropdownOptionUri=timeEntryOEFDict[@"dropdownOptionUri"];
                    oefObject.oefDropdownOptionValue=timeEntryOEFDict[@"dropdownOptionValue"];
                }

                [oefObjectArr addObject:oefObject];

                break;
            }
        }



        
    }
    
    return oefObjectArr;
}

-(NSMutableArray *)createDayLevelDailyWidgetOEFArrayForDate:(NSString *)dateString andTimeEntries:(NSMutableArray*)timeEntries
{
    TimesheetModel *timeSheetModel=[[TimesheetModel alloc]init];

    NSMutableArray *dailyWidgetOEFArr=[timeSheetModel getTimesheetObjectExtensionFieldsForTimeSheetUri:timesheetURI andtimesheetFormat:GEN4_DAILY_WIDGET_TIMESHEET andOEFLevel:DAILY_WIDGET_DAYLEVEL_OEF];

    NSMutableArray *dayLevelDailyWidgetOEFArray = [NSMutableArray array];

    for (NSDictionary *timesheetObjectExtensionsFieldsDict in dailyWidgetOEFArr)
    {
        OEFObject *oefObject=[[OEFObject alloc]init];
        NSString *oefUri=timesheetObjectExtensionsFieldsDict[@"uri"];
        oefObject.oefUri=oefUri;
        oefObject.oefName=timesheetObjectExtensionsFieldsDict[@"displayText"];
        oefObject.oefLevelType=DAILY_WIDGET_DAYLEVEL_OEF;
        oefObject.oefDefinitionTypeUri=timesheetObjectExtensionsFieldsDict[@"definitionTypeUri"];

        for (NSDictionary *timeEntryDict in timeEntries)
        {
            NSString *rowUri=[timeEntryDict objectForKey:@"rowUri"];
            NSArray *timeEntryOEFArr=[timeSheetModel getTimesheetEntryObjectExtensionFieldsForTimeSheetUri:timesheetURI andtimesheetEntryUri:rowUri];

            for (NSDictionary *timeEntryOEFDict in timeEntryOEFArr)
            {
                if ([timeEntryOEFDict[@"uri"] isEqualToString:oefUri])
                {
                    NSString *definitionUri=timesheetObjectExtensionsFieldsDict[@"definitionTypeUri"];;
                    if ([definitionUri isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI])
                    {
                        oefObject.oefTextValue=timeEntryOEFDict[@"textValue"];
                    }
                    else if ([definitionUri isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI])
                    {
                        oefObject.oefNumericValue=[NSString stringWithFormat:@"%@",timeEntryOEFDict[@"numericValue"]];
                    }
                    else if ([definitionUri isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI])
                    {
                        oefObject.oefDropdownOptionUri=timeEntryOEFDict[@"dropdownOptionUri"];
                        oefObject.oefDropdownOptionValue=timeEntryOEFDict[@"dropdownOptionValue"];
                    }
                    
                    break;
                }
            }
        }

        TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc] init];

        NSDateFormatter *formatter=[[NSDateFormatter alloc] init];

        NSLocale *locale=[NSLocale currentLocale];
        [formatter setLocale:locale];
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [formatter setDateFormat:@"EEEE, dd MMM yyyy"];
        NSDate *todayDate=[formatter dateFromString:dateString];
        BOOL isRowEditable=YES;

        [tsEntryObject setIsRowEditable:isRowEditable];
        [tsEntryObject setTimeEntryDate:todayDate];
        [tsEntryObject setTimeAllocationUri:@""];
        [tsEntryObject setTimePunchUri:@""];
        [tsEntryObject setTimeEntryHoursInHourFormat:@""];
        [tsEntryObject setTimeEntryComments:@""];
        [tsEntryObject setTimesheetUri:timesheetURI];
        [tsEntryObject setEntryType:Time_Entry_Key];
        [tsEntryObject setTimeEntryDailyFieldOEFArray:[NSMutableArray arrayWithObject:oefObject]];
        [dayLevelDailyWidgetOEFArray addObject:tsEntryObject];

    }

    return dayLevelDailyWidgetOEFArray;
}

#pragma mark Action methods
/************************************************************************************************************
 @Function Name   : addInOutTimeEntryRowAction
 @Purpose         : Call back for pressing on add time entry row action for in out
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)addInOutTimeEntryRowAction:(id)sender
{
    CLS_LOG(@"-----Add new in out row button clicked on TimesheetMainPageController-----");
    if (self.pageControl.currentPage<self.viewControllers.count)
    {
        MultiDayInOutViewController *currentTimesheetCtrl=[self.viewControllers objectAtIndex:self.pageControl.currentPage];
        if ([currentTimesheetCtrl isKindOfClass:[MultiDayInOutViewController class]])
        {
            [currentTimesheetCtrl addTimeEntryRowAction];
            [self resetDayScrollViewPosition];
        }

    }

}

/************************************************************************************************************
 @Function Name   : TimeEntryAction
 @Purpose         : Call back for pressing on add time entry row action
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
-(void)addAdhocTimeEntryAction
{
    CLS_LOG(@"-----Add adhoc time entry button clicked on TimesheetMainPageController-----");

    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        [self performSelector:@selector(hideKeyBoard) withObject:nil afterDelay:1];
        return;

    }

    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
    if (![timesheetModel isTimesheetContainsInflightSaveOperation:timesheetURI])
    {
        [self resetDayScrollViewPosition];
        TimeEntryViewController *adhocTimeEntryViewController = [[TimeEntryViewController alloc]init];
        adhocTimeEntryViewController.isDisclaimerRequired=self.isDisclaimerRequired;
        adhocTimeEntryViewController.delegate=self;
        adhocTimeEntryViewController.timesheetURI=timesheetURI;
        adhocTimeEntryViewController.timesheetStatus=timesheetStatus;
        adhocTimeEntryViewController.screenViewMode=ADD_PROJECT_ENTRY;
        TimesheetObject *timesheetObject=[[TimesheetObject alloc]init];
        adhocTimeEntryViewController.timesheetObject=timesheetObject;
        adhocTimeEntryViewController.timesheetDataArray=timesheetDataArray;
        BOOL isGen4timesheet=NO;
        NSString *tsFormat=nil;
        isAddTimeEntryClicked=YES;
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];

        if ([self.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [parentDelegate isKindOfClass:[ApprovalsScrollViewController class]] || [self.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]] || [parentDelegate isKindOfClass:[SupervisorDashboardNavigationController class]])
        {
            ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)parentDelegate;
            ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
            if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                tsFormat=[approvalsModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:YES];

            }
            else
            {
                tsFormat=[approvalsModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:NO];
            }
        }
        else
        {

            tsFormat=[timesheetModel getTimesheetFormatforTimesheetUri:timesheetURI];


        }

        if (tsFormat!=nil &&![tsFormat isKindOfClass:[NSNull class]])
        {
            if ([tsFormat isEqualToString:GEN4_INOUT_TIMESHEET])
            {
                isGen4timesheet=YES;
                adhocTimeEntryViewController.isEditBreak=TRUE;
                adhocTimeEntryViewController.screenMode=EDIT_BREAK_ENTRY;
            }
            else if ([tsFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
            {
                isGen4timesheet=YES;
            }
        }





        adhocTimeEntryViewController.isGen4UserTimesheet=isGen4timesheet;
        if (multiDayInOutType==EXTENDED_IN_OUT_TIMESHEET_TYPE)
        {

            adhocTimeEntryViewController.isExtendedInOutTimesheet=YES;

            if (self.tsEntryDataArray.count>0)
            {
                NSString *formattedDate=[NSString stringWithFormat:@"%@",[[self.tsEntryDataArray objectAtIndex:self.pageControl.currentPage] entryDate]];

                NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
                [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                myDateFormatter.dateFormat = @"EEEE, dd MMM yyyy";

                NSLocale *locale=[NSLocale currentLocale];
                [myDateFormatter setLocale:locale];
                NSDate *date=[myDateFormatter dateFromString:[NSString stringWithFormat:@"%@",formattedDate]];

                adhocTimeEntryViewController.currentPageDate=date;
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popToRootViewControllerAnimated:NO];
                });


            }

        }
        if (isMultiDayInOutTimesheetUser)
        {
            adhocTimeEntryViewController.isMultiDayInOutTimesheetUser=YES;
        }
        else
            adhocTimeEntryViewController.isMultiDayInOutTimesheetUser=NO;
        //Implentation for US8956//JUHI
        SupportDataModel *supportDataModel = [[SupportDataModel alloc] init];
        NSMutableArray *userDetailsArr=[supportDataModel getUserDetailsFromDatabase];



        BOOL _hasTimesheetTimeoffAccess        = FALSE;

        if (userDetailsArr!=nil && ![userDetailsArr isKindOfClass:[NSNull class]])
        {
            NSDictionary *userDetailsDict=[userDetailsArr objectAtIndex:0];
            _hasTimesheetTimeoffAccess        = [[userDetailsDict objectForKey:@"hasTimesheetTimeoffAccess"]boolValue];
        }



        //    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        NSDictionary *dataDic=[timesheetModel getAvailableTimeOffTypeCountInfoForTimesheetIdentity:self.timesheetURI];


        int availableTimeOffTypeCount=0;

        if (dataDic!=nil && ![dataDic isKindOfClass:[NSNull class]])
        {
            availableTimeOffTypeCount=[[dataDic objectForKey:@"availableTimeOffTypeCount"]intValue];
        }
        if (isMultiDayInOutTimesheetUser)
        {
            BOOL isBreakAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBreakAccess" forSheetUri:timesheetURI];
            if (isGen4timesheet) {
                SupportDataModel *supportModel=[[SupportDataModel alloc]init];
                NSDictionary *dict=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
                if (tsFormat!=nil &&![tsFormat isKindOfClass:[NSNull class]])
                {
                    if([tsFormat isEqualToString:GEN4_INOUT_TIMESHEET])
                    {
                        isBreakAccess=[[dict objectForKey:@"allowBreakForInOutGen4"] boolValue];
                    }
                    else if([tsFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                    {
                        isBreakAccess=[[dict objectForKey:@"allowBreakForExtInOutGen4"] boolValue];
                        BOOL isProjectAccess=[[dict objectForKey:@"allowProjectsTasksForExtInOutGen4"] boolValue];
                        BOOL isActivityAccess=[[dict objectForKey:@"allowActivitiesForExtInOutGen4"] boolValue];


                        if (!isProjectAccess && !isActivityAccess && isBreakAccess)
                        {
                            adhocTimeEntryViewController.isEditBreak=TRUE;
                            adhocTimeEntryViewController.screenMode=EDIT_BREAK_ENTRY;
                        }
                        else if (isProjectAccess || isActivityAccess)
                        {
                            adhocTimeEntryViewController.isEditBreak=FALSE;
                            adhocTimeEntryViewController.screenMode=ADD_PROJECT_ENTRY;
                        }

                    }
                    else if([tsFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                    {
                        isBreakAccess=[[dict objectForKey:@"allowBreakForStandardGen4"] boolValue];
                    }
                }

            }

            if (isBreakAccess)
            {
                adhocTimeEntryViewController.isEditBreak=TRUE;
                adhocTimeEntryViewController.selectedBreakString=@"";
            }
            else
                adhocTimeEntryViewController.isEditBreak=FALSE;




        }
        else{
            adhocTimeEntryViewController.isEditBreak=FALSE;

        }
        adhocTimeEntryViewController._hasTimesheetTimeoffAccess=_hasTimesheetTimeoffAccess;
        adhocTimeEntryViewController.availableTimeOffTypeCount=availableTimeOffTypeCount;
        if (tsFormat!=nil &&![tsFormat isKindOfClass:[NSNull class]])
        {
            if([tsFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
            {
                TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                NSDictionary *max_min_dict=[timesheetModel getMaxandMinRowNumberFromTimeEntries:self.timesheetDataArray andTimesheetFormat:GEN4_STANDARD_TIMESHEET];
                adhocTimeEntryViewController.timesheetObject.rowNumber=[NSString stringWithFormat:@"%d",[[max_min_dict objectForKey:@"maxValue"]intValue]+1];
                
            }
        }
        
        
        UINavigationController *tempnavcontroller = [[UINavigationController alloc]initWithRootViewController:adhocTimeEntryViewController];
        
        [tempnavcontroller.navigationBar setTranslucent:NO];
        if ([tempnavcontroller respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            tempnavcontroller.interactivePopGestureRecognizer.enabled = NO;
        }
        [self hideKeyBoard];
        [self presentViewController:tempnavcontroller animated:YES completion:nil];
    }
    else
    {
        [self showINProgressAlertView];
    }


}
/************************************************************************************************************
 @Function Name   : TimeOffAction
 @Purpose         : Call back for pressing on add time off row action
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
-(void)addAdhocTimeOffEntryAction
{
    [self resetDayScrollViewPosition];
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        [self performSelector:@selector(hideKeyBoard) withObject:nil afterDelay:1];
        return;

    }
    CLS_LOG(@"-----Add adhoc timeoff button clicked on TimesheetMainPageController-----");
    if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
    {
        if (self.pageControl.currentPage<self.viewControllers.count)
        {
            MultiDayInOutViewController *currentTimesheetCtrl=[self.viewControllers objectAtIndex:self.pageControl.currentPage];
            if ([currentTimesheetCtrl isKindOfClass:[MultiDayInOutViewController class]])
            {
                if (multiDayInOutType!=EXTENDED_IN_OUT_TIMESHEET_TYPE)
                {
                    //CHANGES TO HANDLE AUTOFILL AND OVERLAP CHECK FROM BAR BUTTONS


                    //        ctrl.timesheetDataArray=self.timesheetDataArray;
                    //        ctrl.timesheetEntryObjectArray=[timesheetDataArray objectAtIndex:self.pageControl.currentPage];
                    currentTimesheetCtrl.isOverlap=NO;
                    [currentTimesheetCtrl doneButtonPressed];


                    if (currentTimesheetCtrl.selectedButtonTag!=-1)
                    {
                        if (currentTimesheetCtrl.isOverlap)
                        {
                            return;
                        }
                        else
                        {
                            if (!currentTimesheetCtrl.isOverlapEntryAllowed) {
                                [currentTimesheetCtrl checkOverlapForPage];
                                if (currentTimesheetCtrl.isOverlap)
                                {
                                    return;

                                }
                            }
                        }
                    }
                    else
                    {
                        if (!currentTimesheetCtrl.isOverlapEntryAllowed) {
                            [currentTimesheetCtrl checkOverlapForPage];
                        }
                        if (currentTimesheetCtrl.isOverlap)
                        {
                            return;

                        }
                    }

                    currentTimesheetCtrl.selectedButtonTag=-1;

                    //END



                    [currentTimesheetCtrl removeMultiInOutTimeEntryKeyBoard];
                    [[currentTimesheetCtrl lastUsedTextField] resignFirstResponder];

                }
                else
                {
                    if (currentTimesheetCtrl!=nil && ![currentTimesheetCtrl isKindOfClass:[NSNull class]])
                    {
                        [[currentTimesheetCtrl multiDayTimeEntryTableView] setContentOffset:CGPointMake(0, 0)];
                    }
                    [[currentTimesheetCtrl lastUsedTextField] resignFirstResponder];
                }
                
                [currentTimesheetCtrl resetTableSize:NO  isTextFieldOrTextViewClicked:NO isUdfClicked:NO];
            }

        }

}
    if ([delegate isKindOfClass:[DayTimeEntryViewController class]])
    {
        if (self.pageControl.currentPage<self.viewControllers.count)
        {
            DayTimeEntryViewController *currentTimesheetCtrl=[self.viewControllers objectAtIndex:self.pageControl.currentPage];
            [[currentTimesheetCtrl lastUsedTextField] resignFirstResponder];
            [currentTimesheetCtrl resetTableSize:NO];
        }

    }


    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
    [timesheetModel deleteAllSavedTimeoffTypes];

    //    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"NextAdHocDownloadPageNo"];
    //    [[NSUserDefaults standardUserDefaults] synchronize];
    //    [[RepliconServiceManager timesheetService]fetchEnabledTimeoffTypesDataForTimesheetForTimesheetUri:self.timesheetURI withSearchText:nil andDelegate:self];
    [self addTimeOffTypeCustomView];



}
/************************************************************************************************************
 @Function Name   : addTimeOffTypeCustomView
 @Purpose         : To add Time Off Type CustomView on to view
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)addTimeOffTypeCustomView
{

    //    [self.navigationController pushViewController:self.adHocListViewCtrl animated:NO];


}

/************************************************************************************************************
 @Function Name   : addTimeOffTypeAction
 @Purpose         : add button action of custom view
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)addTimeOffTypeAction
{

    [self performSelector:@selector(hideKeyBoard) withObject:nil afterDelay:1];

    NSMutableArray *tempCustomFieldArray=[self createUdfs];
    NSMutableArray *udfArray=[NSMutableArray array];
    for (int i=0; i<[tempCustomFieldArray count]; i++)
    {
        NSDictionary *udfDict = [tempCustomFieldArray objectAtIndex: i];
        NSString *udfType=[udfDict objectForKey:@"type"];
        NSString *udfName=[udfDict objectForKey:@"name"];
        NSString *udfUri=[udfDict objectForKey:@"uri"];

        if ([udfType isEqualToString:TEXT_UDF_TYPE])
        {
            NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
            NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
            EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
            [udfDetails setSystemDefaultValue:systemDefaultValue];
            [udfDetails setFieldName:udfName];
            [udfDetails setFieldType:UDFType_TEXT];
            [udfDetails setFieldValue:defaultValue];
            [udfDetails setUdfIdentity:udfUri];
            [udfArray addObject:udfDetails];


        }
        else if([udfType isEqualToString:NUMERIC_UDF_TYPE])
        {
            NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];;
            NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
            int defaultDecimalValue=[[udfDict objectForKey:@"defaultDecimalValue"] intValue];
            EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
            [udfDetails setSystemDefaultValue:systemDefaultValue];
            [udfDetails setFieldName:udfName];
            [udfDetails setFieldType:UDFType_NUMERIC];
            [udfDetails setFieldValue:defaultValue];
            [udfDetails setUdfIdentity:udfUri];
            [udfDetails setDecimalPoints:defaultDecimalValue];
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
            else{//Implemented for US8763_HandleWhenDateUDFDoesNotHaveDefaultValue//JUHI
                if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]) {
                    defaultValue=RPLocalizedString(SELECT_STRING, @"");
                }
                else{
                    NSDate *date=(NSDate *)[udfDict objectForKey:@"defaultValue"];
                    defaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:date]];
                }

            }
            id systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
            if ([systemDefaultValue isKindOfClass:[NSDate class]])
            {
                systemDefaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:systemDefaultValue]];
            }
            EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
            [udfDetails setSystemDefaultValue:systemDefaultValue];
            [udfDetails setFieldName:udfName];
            [udfDetails setFieldType:UDFType_DATE];
            [udfDetails setFieldValue:defaultValue];
            [udfDetails setUdfIdentity:udfUri];
            [udfArray addObject:udfDetails];



        }
        else if([udfType isEqualToString:DROPDOWN_UDF_TYPE])
        {
            NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
            NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
            NSString *dropDownOptionUri=[udfDict objectForKey:@"dropDownOptionUri"];
            EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
            [udfDetails setSystemDefaultValue:systemDefaultValue];
            [udfDetails setFieldName:udfName];
            [udfDetails setFieldType:UDFType_DROPDOWN];
            [udfDetails setFieldValue:defaultValue];
            [udfDetails setUdfIdentity:udfUri];
            [udfDetails setDropdownOptionUri:dropDownOptionUri];
            [udfArray addObject:udfDetails];

        }




    }


    if (self.isMultiDayInOutTimesheetUser)
    {
        //Insert Empty Adhoc Timeoff Entry

        TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc] init];
        if (self.tsEntryDataArray.count>0)
        {
            NSString *pageDate=[[self.tsEntryDataArray objectAtIndex:self.pageControl.currentPage] entryDate];
            NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
            [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            myDateFormatter.dateFormat = @"EEEE, dd MMM yyyy";

            NSLocale *locale=[NSLocale currentLocale];
            [myDateFormatter setLocale:locale];
            [myDateFormatter setDateFormat:@"EEEE, dd MMM yyyy"];
            NSDate *todayDate=[myDateFormatter dateFromString:pageDate];

            [tsEntryObject setTimeEntryDate:todayDate];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popToRootViewControllerAnimated:NO];
            });
            
            
        }


        NSString *rowUri=[Util getRandomGUID];
        [tsEntryObject setTimeEntryProjectName:@""];
        [tsEntryObject setTimeEntryProjectUri:@""];
        [tsEntryObject setTimeEntryClientName:nil];
        [tsEntryObject setTimeEntryClientUri:nil];
        [tsEntryObject setTimeEntryActivityName:@""];
        [tsEntryObject setTimeEntryActivityUri:@""];
        [tsEntryObject setTimeEntryBillingName:@""];
        [tsEntryObject setTimeEntryBillingUri:@""];
        [tsEntryObject setTimeEntryTaskName:@""];
        [tsEntryObject setTimeEntryTaskUri:@""];
        [tsEntryObject setIsTimeoffSickRowPresent:YES];
        [tsEntryObject setTimeEntryTimeOffName:self.selectedAdhocTimeoffName];
        [tsEntryObject setTimeEntryTimeOffUri:self.selectedAdhocTimeoffUri];
        [tsEntryObject setMultiDayInOutEntry:nil];
        [tsEntryObject setTimeEntryUdfArray:udfArray];
        [tsEntryObject setTimesheetUri:timesheetURI];
        [tsEntryObject setTimeAllocationUri:@""];
        [tsEntryObject setTimePunchUri:@""];
        [tsEntryObject setTimeEntryHoursInHourFormat:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]];
        [tsEntryObject setTimeEntryHoursInDecimalFormat:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]];
        [tsEntryObject setTimeEntryComments:@""];
        [tsEntryObject setRowUri:rowUri];
        [tsEntryObject setIsNewlyAddedAdhocRow:YES];
        [tsEntryObject setEntryType:Adhoc_Time_OffKey];
        [tsEntryObject setIsRowEditable:YES];


        if ([timesheetStatus isEqualToString:NOT_SUBMITTED_STATUS]||[timesheetStatus isEqualToString:REJECTED_STATUS])
        {

            NSMutableArray *tmpArray=[self.timesheetDataArray objectAtIndex:self.pageControl.currentPage];

            if ([tmpArray count]!=0)
            {
                TimesheetEntryObject *entryObj=(TimesheetEntryObject *)[tmpArray objectAtIndex:0];
                if ([[entryObj entryType] isEqualToString:Time_Off_Key])
                {
                    [tmpArray insertObject:tsEntryObject atIndex:1];
                }
                else
                {
                    [tmpArray insertObject:tsEntryObject atIndex:0];
                }
            }
            else
            {
                [tmpArray addObject:tsEntryObject];
            }

            [self.timesheetDataArray replaceObjectAtIndex:self.pageControl.currentPage withObject:tmpArray];
        }
        self.hasUserChangedAnyValue=YES;
        self.isTimesheetSaveDone = NO;
        [self reloadViewWithRefreshedDataAfterSave];



    }
    else
    {
        //Insert Empty Adhoc Timeoff Entry
        NSString *rowUri=[Util getRandomGUID];
        if ([timesheetStatus isEqualToString:NOT_SUBMITTED_STATUS]||[timesheetStatus isEqualToString:REJECTED_STATUS])
        {
            NSUInteger count=[self.timesheetDataArray count];
            for (int k=0; k<count; k++)
            {
                NSMutableArray *tmpArray=[NSMutableArray arrayWithArray:[self.timesheetDataArray objectAtIndex:k]];
                NSDate *todayDate = nil;
                if (self.tsEntryDataArray.count>0)
                {
                    NSString *pageDate=[[self.tsEntryDataArray objectAtIndex:k] entryDate];
                    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
                    [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                    myDateFormatter.dateFormat = @"EEEE, dd MMM yyyy";

                    NSLocale *locale=[NSLocale currentLocale];
                    [myDateFormatter setLocale:locale];
                    [myDateFormatter setDateFormat:@"EEEE, dd MMM yyyy"];
                    todayDate=[myDateFormatter dateFromString:pageDate];
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.navigationController popToRootViewControllerAnimated:NO];
                    });
                }


                TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc] init];

                [tsEntryObject setTimeEntryProjectName:@""];
                [tsEntryObject setTimeEntryProjectUri:@""];
                [tsEntryObject setTimeEntryClientName:nil];
                [tsEntryObject setTimeEntryClientUri:nil];
                [tsEntryObject setTimeEntryActivityName:@""];
                [tsEntryObject setTimeEntryActivityUri:@""];
                [tsEntryObject setTimeEntryBillingName:@""];
                [tsEntryObject setTimeEntryBillingUri:@""];
                [tsEntryObject setTimeEntryTaskName:@""];
                [tsEntryObject setTimeEntryTaskUri:@""];
                [tsEntryObject setIsTimeoffSickRowPresent:YES];
                [tsEntryObject setTimeEntryTimeOffName:self.selectedAdhocTimeoffName];
                [tsEntryObject setTimeEntryTimeOffUri:self.selectedAdhocTimeoffUri];
                if (todayDate)
                {
                    [tsEntryObject setTimeEntryDate:todayDate];
                }

                [tsEntryObject setMultiDayInOutEntry:nil];
                [tsEntryObject setTimeEntryUdfArray:udfArray];
                [tsEntryObject setTimesheetUri:timesheetURI];
                [tsEntryObject setTimeAllocationUri:@""];
                [tsEntryObject setTimePunchUri:@""];
                [tsEntryObject setTimeEntryHoursInHourFormat:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]];
                [tsEntryObject setTimeEntryHoursInDecimalFormat:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]];
                [tsEntryObject setTimeEntryComments:@""];
                [tsEntryObject setRowUri:rowUri];
                [tsEntryObject setIsNewlyAddedAdhocRow:YES];
                [tsEntryObject setEntryType:Adhoc_Time_OffKey];
                [tsEntryObject setIsRowEditable:YES];
                if ([tmpArray count]!=0)
                {
                    TimesheetEntryObject *entryObj=(TimesheetEntryObject *)[tmpArray objectAtIndex:0];
                    if ([[entryObj entryType] isEqualToString:Time_Off_Key])
                    {
                        [tmpArray insertObject:tsEntryObject atIndex:1];
                    }
                    else
                    {
                        [tmpArray insertObject:tsEntryObject atIndex:0];
                    }
                }
                else
                {
                    [tmpArray addObject:tsEntryObject];
                }

                [self.timesheetDataArray replaceObjectAtIndex:k withObject:tmpArray];

            }
        }


        self.hasUserChangedAnyValue=YES;
        self.isTimesheetSaveDone = NO;
        [self reloadViewWithRefreshedDataAfterSave];



    }



}

/************************************************************************************************************
 @Function Name   : configurePicker
 @Purpose         : To configure and add picker on to view
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)configurePicker
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];

    [self.customPickerView removeFromSuperview];
    CustomPickerView *tempcustomPickerView= [[CustomPickerView alloc] initWithFrame:
                                             CGRectMake(0, screenRect.size.height-205, self.view.width, 320)];
    self.customPickerView = tempcustomPickerView;


    [self.customPickerView setDelegate:self];
    [self.customPickerView initializePickers];

    AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    //    appdelegate.rootTabBarController.tabBar.hidden=TRUE;
    [appdelegate.window addSubview:self.customPickerView];


}
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




#pragma mark Adhoc save methods

-(void)reloadViewWithRefreshedDataAfterSave

{
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [self createCurrentTimesheetEntryList];



    currentlySelectedPage=self.pageControl.currentPage;

    if (self.isMultiDayInOutTimesheetUser)
    {
        if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
        {



            if (self.pageControl.currentPage >= self.viewControllers.count)
            {
                return;
            }

            MultiDayInOutViewController *currentTimesheetCtrl1=[self.viewControllers objectAtIndex:self.pageControl.currentPage];
            if (currentTimesheetCtrl1!=nil && ![currentTimesheetCtrl1 isKindOfClass:[NSNull class]])
            {
                if ([currentTimesheetCtrl1 isKindOfClass:[MultiDayInOutViewController class]])
                {
                    [currentTimesheetCtrl1 setIsFromSuggestionViewClickedReload:YES];
                    currentTimesheetCtrl1.timesheetEntryObjectArray=[timesheetDataArray objectAtIndex:self.pageControl.currentPage];
                    if (multiDayInOutType==EXTENDED_IN_OUT_TIMESHEET_TYPE)
                    {
                        [currentTimesheetCtrl1 createExtendedInOutArray];
                    }
                    if (self.hasUserChangedAnyValue)
                    {
                        [currentTimesheetCtrl1 changeParentViewLeftBarbutton];
                    }

                    [currentTimesheetCtrl1 calculateNumberOfRowsAndTotalHoursForFooter];
                    [currentTimesheetCtrl1 setIsTableRowSelected:NO];
                    if (currentTimesheetCtrl1!=nil && ![currentTimesheetCtrl1 isKindOfClass:[NSNull class]])
                    {
                        [[currentTimesheetCtrl1 multiDayTimeEntryTableView] reloadData];
                    }

                    if (multiDayInOutType==EXTENDED_IN_OUT_TIMESHEET_TYPE && indexPathForFirstResponder!=nil)
                    {
                        [currentTimesheetCtrl1.multiDayTimeEntryTableView scrollToRowAtIndexPath:self.indexPathForFirstResponder atScrollPosition:UITableViewScrollPositionTop animated:YES];
                        ExtendedInOutCell *cell= (ExtendedInOutCell *)[currentTimesheetCtrl1.multiDayTimeEntryTableView cellForRowAtIndexPath:self.indexPathForFirstResponder];
                        [cell._inTxt becomeFirstResponder];
                        self.indexPathForFirstResponder=nil;
                    }
                    else
                    {
                        [currentTimesheetCtrl1 resetTableSize:NO isTextFieldOrTextViewClicked:NO isUdfClicked:NO];
                    }
                    BOOL isGen4Timesheet=NO;
                    NSString *timesheetFormat=nil;

                    NSArray *array=nil;

                    if ([self.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [parentDelegate isKindOfClass:[ApprovalsScrollViewController class]] || [self.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]] || [parentDelegate isKindOfClass:[SupervisorDashboardNavigationController class]])
                    {
                        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)parentDelegate;
                        ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
                        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                        {
                            array=[approvalsModel getTimeSheetInfoSheetIdentityForPending:timesheetURI];

                        }
                        else
                        {
                            array=[approvalsModel getTimeSheetInfoSheetIdentityForPrevious:timesheetURI];
                        }
                    }
                    else
                    {
                        TimesheetModel *tsModel=[[TimesheetModel alloc]init];
                        array=[tsModel getTimeSheetInfoSheetIdentity:timesheetURI];


                    }


                    if ([array count]>0) {

                        if ([(NSMutableArray *)[array objectAtIndex:0] count]>0)
                        {
                            timesheetFormat=[[array objectAtIndex:0] objectForKey:@"timesheetFormat"];
                            if (timesheetFormat!=nil &&![timesheetFormat isKindOfClass:[NSNull class]])
                            {
                                if ([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET] ||  [timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                                {
                                    isGen4Timesheet=YES;
                                }
                            }
                            
                        }
                        
                    }
                    if (isGen4Timesheet) {
                        [currentTimesheetCtrl1.multiDayTimeEntryTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                    }
                    

                }
            }

        }

    }

    else
    {
        if ([delegate isKindOfClass:[DayTimeEntryViewController class]])
        {
            if (self.pageControl.currentPage >= self.viewControllers.count)
            {
                return;
            }
            DayTimeEntryViewController *currentTimesheetCtrl1=[self.viewControllers objectAtIndex:self.pageControl.currentPage];
            if (currentTimesheetCtrl1!=nil && ![currentTimesheetCtrl1 isKindOfClass:[NSNull class]])
            {
                [currentTimesheetCtrl1.cellHeightsArray removeAllObjects];
                if (self.hasUserChangedAnyValue)
                {
                    [currentTimesheetCtrl1 changeParentViewLeftBarbutton];
                }
                currentTimesheetCtrl1.timesheetEntryObjectArray=[timesheetDataArray objectAtIndex:self.pageControl.currentPage];
                [currentTimesheetCtrl1 calculateAndUpdateTotalHoursValueForFooter];
                if (currentTimesheetCtrl1!=nil && ![currentTimesheetCtrl1 isKindOfClass:[NSNull class]])
                {
                    [[currentTimesheetCtrl1 timeEntryTableView] reloadData];
                }

            }

        }

    }


    if (isDeleteTimeEntry_AdHoc_RequestInQueue)
    {
        [[NSNotificationCenter defaultCenter] removeObserver: self name: START_AUTOSAVE object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(backAndSaveAction:)
                                                     name: START_AUTOSAVE
                                                   object: nil];

        [appDelegate performSelector:@selector(startSyncTimer) withObject:nil];
        self.isDeleteTimeEntry_AdHoc_RequestInQueue=FALSE;
    }



}
//Implemented as per TOFF-115//JUHI
#pragma mark BookedTimeoff save methods

-(void)reloadViewWithRefreshedDataAfterBookedTimeoffSave

{
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [self createCurrentTimesheetEntryList];
    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
    NSMutableArray *allTimeEntriesArray=[timesheetModel getAllTimeEntriesForSheetFromDB:timesheetURI];
    if ([allTimeEntriesArray count]==0)
    {
        NSArray *timesheetInfoArray=nil;
        
        if ([self.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [parentDelegate isKindOfClass:[ApprovalsScrollViewController class]] || [self.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]] || [parentDelegate isKindOfClass:[SupervisorDashboardNavigationController class]])
        {
            ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)parentDelegate;
            ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
            if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                timesheetInfoArray=[approvalsModel getTimeSheetInfoSheetIdentityForPending:timesheetURI];
                
            }
            else
            {
                timesheetInfoArray=[approvalsModel getTimeSheetInfoSheetIdentityForPrevious:timesheetURI];
            }
        }
        else
        {
            TimesheetModel *tsModel=[[TimesheetModel alloc]init];
            timesheetInfoArray=[tsModel getTimeSheetInfoSheetIdentity:timesheetURI];
            
            
        }
        
        
        if ([timesheetInfoArray count]>0)
        {
            NSString *tsFormat=[[timesheetInfoArray objectAtIndex:0] objectForKey:@"timesheetFormat"];
            if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
            {
                if (tsFormat!=nil &&![tsFormat isKindOfClass:[NSNull class]])
                {
                    if ([tsFormat isEqualToString:STANDARD_TIMESHEET] || [tsFormat isEqualToString:GEN4_STANDARD_TIMESHEET] || [tsFormat isEqualToString:GEN4_DAILY_WIDGET_TIMESHEET])
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
        NSString *tsFormat=nil;
        if ([timesheetInfoArray count]>0)
        {
            tsFormat=[[timesheetInfoArray objectAtIndex:0] objectForKey:@"timesheetFormat"];
        }
        if (self.isMultiDayInOutTimesheetUser)
        {
           
            if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
            {
                if ([tsFormat isEqualToString:EXTENDED_INOUT_TIMESHEET])
                {
                    self.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[timesheetModel getTimeEntriesForExtendedInOutSheetFromDB:timesheetURI andTimeSheetFormat:tsFormat]];

                }
                else if([tsFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [tsFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                {
                    self.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[timesheetModel getTimeEntriesForExtendedInOutSheetFromDB:timesheetURI andTimeSheetFormat:tsFormat]];
                }

                else
                {


                    self.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[timesheetModel getTimeEntriesForSheetFromDB:timesheetURI]];


                }
            }
            else
                self.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[timesheetModel getTimeEntriesForSheetFromDB:timesheetURI]];

        }
        else
        {
            self.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[timesheetModel getGroupedStandardTimeEntriesForSheetFromDB:timesheetURI  andTimesheetFormat:tsFormat]];

        }

    }
    else
    {
        NSString *timesheetFormat=[timesheetModel getTimesheetFormatInfoFromDBForTimesheetUri:timesheetURI];
        if (timesheetFormat!=nil && ![timesheetFormat isKindOfClass:[NSNull class]])
        {
            if ([timesheetFormat isEqualToString:STANDARD_TIMESHEET] || [timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
            {
                self.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[timesheetModel getGroupedStandardTimeEntriesForSheetFromDB:timesheetURI andTimesheetFormat:timesheetFormat]];

            }
            else if ([timesheetFormat isEqualToString:EXTENDED_INOUT_TIMESHEET])
            {
                self.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[timesheetModel getTimeEntriesForExtendedInOutSheetFromDB:timesheetURI andTimeSheetFormat:timesheetFormat]];

            }
            else if ([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
            {
                self.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[timesheetModel getTimeEntriesForExtendedInOutSheetFromDB:timesheetURI andTimeSheetFormat:timesheetFormat]];

            }
            else
            {


                self.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[timesheetModel getTimeEntriesForSheetFromDB:timesheetURI]];
                
                
            }
        }


    }

    currentlySelectedPage=self.pageControl.currentPage;
    [self addNextView];
    if (self.isMultiDayInOutTimesheetUser)
    {
        if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
        {



            if (self.pageControl.currentPage >= self.viewControllers.count)
            {
                return;
            }
            for (int i=0; i<[viewControllers count]; i++)
            {
                MultiDayInOutViewController *currentTimesheetCtrl1=[self.viewControllers objectAtIndex:i];
                if (currentTimesheetCtrl1!=nil && ![currentTimesheetCtrl1 isKindOfClass:[NSNull class]])
                {
                    if ([currentTimesheetCtrl1 isKindOfClass:[MultiDayInOutViewController class]])
                    {
                        [currentTimesheetCtrl1 setIsFromSuggestionViewClickedReload:YES];
                        currentTimesheetCtrl1.timesheetEntryObjectArray=[timesheetDataArray objectAtIndex:self.pageControl.currentPage];
                        if (multiDayInOutType==EXTENDED_IN_OUT_TIMESHEET_TYPE)
                        {
                            [currentTimesheetCtrl1 createExtendedInOutArray];
                        }
                        if (self.hasUserChangedAnyValue)
                        {
                            [currentTimesheetCtrl1 changeParentViewLeftBarbutton];
                        }

                        [currentTimesheetCtrl1 calculateNumberOfRowsAndTotalHoursForFooter];
                        [currentTimesheetCtrl1 setIsTableRowSelected:NO];
                        if (currentTimesheetCtrl1!=nil && ![currentTimesheetCtrl1 isKindOfClass:[NSNull class]])
                        {
                            [[currentTimesheetCtrl1 multiDayTimeEntryTableView] reloadData];
                        }

                        if (multiDayInOutType==EXTENDED_IN_OUT_TIMESHEET_TYPE && indexPathForFirstResponder!=nil)
                        {
                            [currentTimesheetCtrl1.multiDayTimeEntryTableView scrollToRowAtIndexPath:self.indexPathForFirstResponder atScrollPosition:UITableViewScrollPositionTop animated:YES];
                            ExtendedInOutCell *cell= (ExtendedInOutCell *)[currentTimesheetCtrl1.multiDayTimeEntryTableView cellForRowAtIndexPath:self.indexPathForFirstResponder];
                            [cell._inTxt becomeFirstResponder];
                            self.indexPathForFirstResponder=nil;
                        }
                        else
                        {
                            [currentTimesheetCtrl1 resetTableSize:NO isTextFieldOrTextViewClicked:NO isUdfClicked:NO];
                        }

                    }
                }
            }



        }

    }

    else
    {
        if ([delegate isKindOfClass:[DayTimeEntryViewController class]])
        {
            if (self.pageControl.currentPage >= self.viewControllers.count)
            {
                return;
            }
            for (int i=0; i<[viewControllers count]; i++)
            {
                DayTimeEntryViewController *currentTimesheetCtrl1=[self.viewControllers objectAtIndex:i];
                if (currentTimesheetCtrl1!=nil && ![currentTimesheetCtrl1 isKindOfClass:[NSNull class]])
                {
                    [currentTimesheetCtrl1.cellHeightsArray removeAllObjects];
                    if (self.hasUserChangedAnyValue)
                    {
                        [currentTimesheetCtrl1 changeParentViewLeftBarbutton];
                    }
                    currentTimesheetCtrl1.timesheetEntryObjectArray=[timesheetDataArray objectAtIndex:self.pageControl.currentPage];
                    [currentTimesheetCtrl1 calculateAndUpdateTotalHoursValueForFooter];
                    if (currentTimesheetCtrl1!=nil && ![currentTimesheetCtrl1 isKindOfClass:[NSNull class]])
                    {
                        [[currentTimesheetCtrl1 timeEntryTableView] reloadData];
                    }

                }
            }


        }

    }


    if (isDeleteTimeEntry_AdHoc_RequestInQueue)
    {
        [[NSNotificationCenter defaultCenter] removeObserver: self name: START_AUTOSAVE object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(backAndSaveAction:)
                                                     name: START_AUTOSAVE
                                                   object: nil];

        [appDelegate performSelector:@selector(startSyncTimer) withObject:nil];
        self.isDeleteTimeEntry_AdHoc_RequestInQueue=FALSE;
    }



}


-(void)createCurrentTimesheetEntryList
{

    NSMutableArray *currentTimesheetArray=[NSMutableArray array];
    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
    NSMutableArray *arrayFromDB=[timesheetModel getAllTimesheetDaySummaryFromDBForTimesheet:timesheetURI];

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
        
        NSString *timeSheetFormat=@"";
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        if([appDelegate.rootTabBarController.selectedViewController isKindOfClass:[ApprovalsNavigationController class]] || [appDelegate.rootTabBarController.selectedViewController isKindOfClass:[SupervisorDashboardNavigationController class]])
        {
           
            ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)[self parentDelegate];
            ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
            if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                timeSheetFormat=[approvalsModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:YES];
            }
            else
            {
                timeSheetFormat=[approvalsModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:NO];
            }
        }
        else
        {
            timeSheetFormat=[timesheetModel getTimesheetFormatforTimesheetUri:timesheetURI];
        }
        if (timeSheetFormat!=nil && ![timeSheetFormat isKindOfClass:[NSNull class]])
        {
            if ([timeSheetFormat isEqualToString:GEN4_PUNCH_WIDGET_TIMESHEET])
            {
                if ([dataDic objectForKey:@"totalPunchTimeDurationDecimal"]!=nil && ![[dataDic objectForKey:@"totalPunchTimeDurationDecimal"] isKindOfClass:[NSNull class]])
                {
                    [timeobj setNumberOfHours:[Util getRoundedValueFromDecimalPlaces:[[dataDic objectForKey:@"totalPunchTimeDurationDecimal"]newDoubleValue]withDecimalPlaces:2]];
                }
                else
                {
                    //[timeobj setNumberOfHours:[Util getRoundedValueFromDecimalPlaces:[@"0" newDoubleValue]withDecimalPlaces:2]];
                }

            }
            else if ([timeSheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [timeSheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
            {
                if ([dataDic objectForKey:@"totalInOutTimeDurationDecimal"]!=nil && ![[dataDic objectForKey:@"totalInOutTimeDurationDecimal"] isKindOfClass:[NSNull class]])
                {
                    [timeobj setNumberOfHours:[Util getRoundedValueFromDecimalPlaces:[[dataDic objectForKey:@"totalInOutTimeDurationDecimal"]newDoubleValue]withDecimalPlaces:2]];
                }
                else
                {
                    //[timeobj setNumberOfHours:[Util getRoundedValueFromDecimalPlaces:[@"0" newDoubleValue]withDecimalPlaces:2]];
                }

            }
            else if (![timeSheetFormat isEqualToString:GEN4_DAILY_WIDGET_TIMESHEET] )
            {
                if ([dataDic objectForKey:@"timesheetEntryTotalDurationDecimal"]!=nil && ![[dataDic objectForKey:@"timesheetEntryTotalDurationDecimal"] isKindOfClass:[NSNull class]])
                {
                    [timeobj setNumberOfHours:[Util getRoundedValueFromDecimalPlaces:[[dataDic objectForKey:@"timesheetEntryTotalDurationDecimal"]newDoubleValue]withDecimalPlaces:2]];
                }
                else
                {
                    //[timeobj setNumberOfHours:[Util getRoundedValueFromDecimalPlaces:[@"0" newDoubleValue]withDecimalPlaces:2]];
                }
                
            }
        }

        
        [timeobj setIsDayOff:[[dataDic objectForKey:@"isDayOff"] boolValue]];
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
    self.tsEntryDataArray=currentTimesheetArray;


}

-(NSMutableArray *)getArrayOfTimeEntryObjectsFromAllTheEntries
{
    NSMutableArray *arrayOfTimeEntriesObjectsForSave=[NSMutableArray array];
    for (int i=0; i<[self.timesheetDataArray count]; i++)
    {
        NSMutableArray *entryDataArray=[self.timesheetDataArray objectAtIndex:i];

        for (int k=0; k<[entryDataArray count]; k++)
        {
            TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[entryDataArray objectAtIndex:k];
            if ([tsEntryObject isTimeoffSickRowPresent])
            {
                if (isMultiDayInOutTimesheetUser)
                {
                    if ([tsEntryObject.entryType isEqualToString:Adhoc_Time_OffKey ])
                    {
                        [arrayOfTimeEntriesObjectsForSave addObject:[entryDataArray objectAtIndex:k]];
                    }
                }
                else
                {
                    [arrayOfTimeEntriesObjectsForSave addObject:[entryDataArray objectAtIndex:k]];
                }

            }
            else
            {

                if (isMultiDayInOutTimesheetUser)
                {
                    NSMutableDictionary *dict=[tsEntryObject multiDayInOutEntry];
                    NSString *inTime=[dict objectForKey:@"in_time"];
                    NSString *outTime=[dict objectForKey:@"out_time"];
                    if ((inTime!=nil &&![inTime isEqualToString:@""]) || (outTime!=nil&&![outTime isEqualToString:@""]))
                    {
                        [arrayOfTimeEntriesObjectsForSave addObject:[entryDataArray objectAtIndex:k]];
                    }
                }
                else
                {
                    [arrayOfTimeEntriesObjectsForSave addObject:[entryDataArray objectAtIndex:k]];
                }

            }

        }
    }

    return arrayOfTimeEntriesObjectsForSave;

}

#pragma mark scrollview delegate


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (self.isMultiDayInOutTimesheetUser)
    {
        if (page!=self.pageControl.currentPage)
        {
            if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
            {
                if (self.pageControl.currentPage<self.viewControllers.count)
                {
                    MultiDayInOutViewController *currentTimesheetCtrl=[self.viewControllers objectAtIndex:self.pageControl.currentPage];
                    if ([currentTimesheetCtrl isKindOfClass:[MultiDayInOutViewController class]])
                    {
                        [currentTimesheetCtrl resetTableSize:NO isTextFieldOrTextViewClicked:YES isUdfClicked:NO];
                        if (currentTimesheetCtrl!=nil && ![currentTimesheetCtrl isKindOfClass:[NSNull class]])
                        {
                            [[currentTimesheetCtrl multiDayTimeEntryTableView] setScrollEnabled:YES];
                        }

                        if ([currentTimesheetCtrl isTableRowSelected])
                        {
                            [currentTimesheetCtrl doneAction:YES sender:nil];
                        }
                        else
                        {
                            [currentTimesheetCtrl doneAction:NO sender:nil];
                        }
                    }
                }

         }
      }

    }
    else
    {
        if (page!=self.pageControl.currentPage)
        {
            if ([delegate isKindOfClass:[DayTimeEntryViewController class]])
            {
                if (self.pageControl.currentPage<self.viewControllers.count)
                {
                    DayTimeEntryViewController *currentTimesheetCtrl=[self.viewControllers objectAtIndex:self.pageControl.currentPage];

                    if (currentTimesheetCtrl != nil && ![currentTimesheetCtrl isKindOfClass:[NSNull class]]) {
                        [currentTimesheetCtrl resetTableSize:NO];
                        if (currentTimesheetCtrl!=nil && ![currentTimesheetCtrl isKindOfClass:[NSNull class]])
                        {
                            [[currentTimesheetCtrl timeEntryTableView] setScrollEnabled:YES];
                        }

                        [currentTimesheetCtrl doneAction:NO sender:nil];
                    }
                }

            }
        }
    }
    //Changes done for day Scroll
    [self scrollViewDidEndDecelerating:self.scrollView];

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (self.tsEntryDataArray.count>0)
    {
        [Util setToolbarLabel: self withText:[NSString stringWithFormat:@"%@",[[self.tsEntryDataArray objectAtIndex:page] entryDateWithDesiredFormat]]];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:NO];
        });
    }

    //[self.navigationController.navigationBar setTintColor:RepliconStandardNavBarTintColor];
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    if (self.isMultiDayInOutTimesheetUser)
    {
        if (page!=self.pageControl.currentPage)
        {
            if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
            {
                if (self.pageControl.currentPage<self.viewControllers.count)
                {
                    MultiDayInOutViewController *currentTimesheetCtrl=[self.viewControllers objectAtIndex:self.pageControl.currentPage];
                    if ([currentTimesheetCtrl isKindOfClass:[MultiDayInOutViewController class]])
                    {
                        if (multiDayInOutType!=EXTENDED_IN_OUT_TIMESHEET_TYPE)
                        {
                            [currentTimesheetCtrl removeMultiInOutTimeEntryKeyBoard];
                        }
                        else
                        {
                            [[currentTimesheetCtrl lastUsedTextField] resignFirstResponder];
                        }
                        if (currentTimesheetCtrl!=nil && ![currentTimesheetCtrl isKindOfClass:[NSNull class]])
                        {
                            [[currentTimesheetCtrl multiDayTimeEntryTableView] scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                        }

                        [currentTimesheetCtrl setSelectedButtonTag:-1];

                        self.pageControl.currentPage = page;
                        if (page!=0)
                        {
                            //[self loadScrollViewWithPage:page - 1];
                        }
                        [self loadScrollViewWithPage:page fromDayButtonClick:NO];
                        //[self loadScrollViewWithPage:page + 1];
                    }

                }

            }

        }

    }
    else
    {
        if (page!=self.pageControl.currentPage)
        {
            if ([delegate isKindOfClass:[DayTimeEntryViewController class]])
            {
                if (self.pageControl.currentPage<self.viewControllers.count)
                {
                    DayTimeEntryViewController *currentTimesheetCtrl=[self.viewControllers objectAtIndex:self.pageControl.currentPage];
                    if (currentTimesheetCtrl!=nil && ![currentTimesheetCtrl isKindOfClass:[NSNull class]])
                    {
                        [[currentTimesheetCtrl timeEntryTableView] scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                    }
                    self.pageControl.currentPage = page;
                    if (page!=0)
                    {
                        [self loadScrollViewWithPage:page - 1 fromDayButtonClick:NO];
                    }
                    [self loadScrollViewWithPage:page fromDayButtonClick:NO];
                    [self loadScrollViewWithPage:page + 1 fromDayButtonClick:NO];
                }

            }

        }


    }


}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{

}

- (void)loadScrollViewWithPage:(NSUInteger)page fromDayButtonClick:(BOOL)dayButtonClick
{
    if (page >= self.viewControllers.count)
        return;
    if (self.isMultiDayInOutTimesheetUser)
    {
        if (self.previouslySelectedPage<self.viewControllers.count)
        {
            MultiDayInOutViewController *previouscontroller = [self.viewControllers objectAtIndex:self.previouslySelectedPage];
            if ((NSNull *)previouscontroller == [NSNull null])
            {
            }
            else if ([previouscontroller isKindOfClass:[DayTimeEntryViewController class]])
            {
               return;
            }
            else
            {
                ExtendedInOutCell *cell= (ExtendedInOutCell *)[previouscontroller.multiDayTimeEntryTableView cellForRowAtIndexPath:previouscontroller.currentlyBeingEditedCellIndexpath];
                if (cell==nil || [cell isKindOfClass:[NSNull class]])
                {
                }
                else
                {
                    if ([cell _inTxt]) {
                        [[cell _inTxt] resignFirstResponder];
                    }
                    if ([cell _outTxt]) {
                        [[cell _outTxt] resignFirstResponder];
                    }
                }
            }
            if (page<self.viewControllers.count)
            {
                MultiDayInOutViewController *controller = [self.viewControllers objectAtIndex:page];
                self.pageControl.currentPage=page;
                if ((NSNull *)controller == [NSNull null])
                {
                    controller = [[MultiDayInOutViewController alloc] init];
                    [controller setSelectedButtonTag:-1];
                    self.delegate=controller;
                    controller.parentDelegate = self.parentDelegate;
                    controller.approvalsDelegate = self.parentDelegate;
                    controller.controllerDelegate=self;
                    [self.viewControllers replaceObjectAtIndex:page withObject:controller];
                }
                else if ([controller isKindOfClass:[DayTimeEntryViewController class]])
                {
                    return;
                }
                else{
                    [controller createFooterView];
                }

                if ([controller isKindOfClass:[MultiDayInOutViewController class]])
                {
                    //Implemented For overlappingTimeEntriesPermitted Persmisson
                    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                    BOOL isOverlapEntryAllow=[timesheetModel getStatusForGivenPermissions:@"overlappingTimeEntriesPermitted" ForTimesheetIdentity:self.timesheetURI];

                    controller.multiDayTimesheetStatus=timesheetStatus;
                    controller.isOverlapEntryAllowed=isOverlapEntryAllow;
                    controller.timesheetDataArray=self.timesheetDataArray;
                    controller.timesheetEntryObjectArray=[timesheetDataArray objectAtIndex:page];
                    controller.isInOutBtnClicked=NO;
                    controller.currentIndexpath=nil;
                    controller.timesheetURI=self.timesheetURI;
                    if (self.tsEntryDataArray.count>0)
                    {
                        NSString *formattedDate=[NSString stringWithFormat:@"%@",[[self.tsEntryDataArray objectAtIndex:page] entryDate]];
                        NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
                        [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];//Mobi-537 Ullas M L
                        myDateFormatter.dateFormat = @"EEEE, dd MMM yyyy";

                        NSLocale *locale=[NSLocale currentLocale];
                        [myDateFormatter setLocale:locale];
                        NSDate *date=[myDateFormatter dateFromString:[NSString stringWithFormat:@"%@",formattedDate]];
                        controller.currentPageDate=date;
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.navigationController popToRootViewControllerAnimated:NO];
                        });

                    }
                    if (multiDayInOutType==EXTENDED_IN_OUT_TIMESHEET_TYPE)
                    {
                        BOOL isOverLapEntryAllowedForExtInOutTimesheet = false;
                        NSArray *timesheetInfoArray = [self getTimesheetInfoArray];
                        BOOL isGen4Timesheet = [self isGen4Timesheet:timesheetInfoArray];
                        if(isGen4Timesheet){
                            isOverLapEntryAllowedForExtInOutTimesheet = [timesheetModel readIsSplitTimeEntryForMidNightCrossOverPermission:AllowSplitTimeMidNightCrossEntry forTimesheetIdentity:self.timesheetURI];
                        }
                        controller.isOverlapEntryAllowed = isOverLapEntryAllowedForExtInOutTimesheet;
                        controller.multiInOutTimesheetType=EXTENDED_IN_OUT_TIMESHEET_TYPE;
                    }
                    else
                    {
                        controller.multiInOutTimesheetType=NOT_EXTENDED_IN_OUT_TIMESHEET_TYPE;
                    }

                    if (multiDayInOutType==NOT_EXTENDED_IN_OUT_TIMESHEET_TYPE)
                    {
                        if (page>0)
                        {
                            NSMutableArray *previousArray=[timesheetDataArray objectAtIndex:page-1];
                            NSDate *startRange;
                            NSDate *endRange;
                            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];

                            //NSLocale *locale=[NSLocale currentLocale];
                            NSLocale *locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
                            [dateFormat setLocale:locale];
                            [dateFormat setDateFormat:@"hh:mm a"];
                            for (int i=0; i<[previousArray count]; i++)
                            {
                                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[previousArray objectAtIndex:i];
                                NSString *inTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"in_time"];
                                NSString *outTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"out_time"];
                                if (inTimeString!=nil && ![inTimeString isKindOfClass:[NSNull class]] && ![inTimeString isEqualToString:@""] &&outTimeString!=nil && ![outTimeString isKindOfClass:[NSNull class]]&& ![outTimeString isEqualToString:@""]) {
                                    startRange=[dateFormat dateFromString:inTimeString];
                                    endRange=[dateFormat dateFromString:outTimeString];
                                    if ([startRange compare:endRange ] == NSOrderedDescending) {
                                        controller.previousCrossOutTime=outTimeString;

                                    }

                                }

                            }

                        }
                        if (page>0 && page<self.viewControllers.count)
                        {
                            if (page+1<self.viewControllers.count) {
                                NSMutableArray *previousArray=[timesheetDataArray objectAtIndex:page+1];
                                if (previousArray!=nil)
                                {
                                    controller.nextCrossIntime=previousArray;
                                }
                            }


                        }
                        if (pageControl.currentPage==page)
                        {
                            //Implemented For overlappingTimeEntriesPermitted Permission
                            if (!controller.isOverlapEntryAllowed) {
                                [controller checkOverlapForPage];
                            }

                        }

                    }
                    else
                    {
                        [controller resetTableSizeForExtendedInOut:NO];
                    }

                    // add the controller's view to the scroll view
                    if (controller.view.superview == nil)
                    {
                        CGFloat scrollViewWidth = CGRectGetWidth(self.scrollView.frame);
                        CGFloat scrollViewHeight = CGRectGetHeight(self.scrollView.frame);

                        controller.view.frame = CGRectMake(scrollViewWidth * page, 0, scrollViewWidth, scrollViewHeight);
                        controller.timesheetEntryObjectArray=[timesheetDataArray objectAtIndex:page];
                        if (multiDayInOutType==EXTENDED_IN_OUT_TIMESHEET_TYPE)
                        {
                            [controller createExtendedInOutArray];
                        }
                        [self addChildViewController:controller];
                        [self.scrollView addSubview:controller.view];
                        [controller didMoveToParentViewController:self];

                    }
                    if (multiDayInOutType==EXTENDED_IN_OUT_TIMESHEET_TYPE)
                    {
                        [controller createExtendedInOutArray];
                        BOOL isGen4timesheet=NO;
                        NSString *timesheetFormat=nil;
                        BOOL isApproverContext=NO;
                        NSArray *array=nil;
                        if ([self.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [parentDelegate isKindOfClass:[ApprovalsScrollViewController class]] || [self.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]] || [parentDelegate isKindOfClass:[SupervisorDashboardNavigationController class]])
                        {
                            ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)parentDelegate;
                            ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
                            if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                            {
                                array=[approvalsModel getTimeSheetInfoSheetIdentityForPending:timesheetURI];

                            }
                            else
                            {
                                array=[approvalsModel getTimeSheetInfoSheetIdentityForPrevious:timesheetURI];
                            }
                            isApproverContext=YES;
                        }
                        else
                        {
                            TimesheetModel *tsModel=[[TimesheetModel alloc]init];
                            array=[tsModel getTimeSheetInfoSheetIdentity:timesheetURI];


                        }
                        if ([array count]>0) {

                            if ([(NSMutableArray *)[array objectAtIndex:0] count]>0)
                            {
                                timesheetFormat=[[array objectAtIndex:0] objectForKey:@"timesheetFormat"];
                                if (timesheetFormat!=nil && ![timesheetFormat isKindOfClass:[NSNull class]])
                                {
                                    if ([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                                    {
                                        isGen4timesheet=YES;
                                    }
                                }

                            }

                        }
                        if (isGen4timesheet&&!isApproverContext)
                        {
                            [controller setIsGen4RequestInQueue:YES];
                            [controller calculateAndUpdateTotalHoursValueForFooter];
                            [controller checkGen4ServerPunchIdForAllTimeEntries];

                        }

                        if (isGen4timesheet)
                        {
                            controller.isGen4UserTimesheet = YES;
                        }
                        
                        
                        //controller.isOverlapEntryAllowed=isOverlapEntryAllow;
                        if (!isOverlapEntryAllow)
                        {
                            if (dayButtonClick)
                            {
                                [controller performSelector:@selector(checkOverlapForPageForExtendedInOutOnLoadForPage:) withObject:[NSString stringWithFormat:@"%lu",(unsigned long)page] ];
                                
                            }
                            
                        }
                        
                    }
                    
                    //Changes done for day Scroll
                    if (self.currentlySelectedPage==page)
                    {
                        [controller setIsFromSuggestionViewClickedReload:YES];//DE18931 Ullas M L
                        [controller calculateNumberOfRows];//19700 Ullas M L
                        if (controller!=nil && ![controller isKindOfClass:[NSNull class]])
                        {
                            [[controller multiDayTimeEntryTableView]reloadData];
                        }
                        
                    }

                }

            }

        }
    }
    else
    {
        // replace the placeholder if necessary
        NSString *tsFormat=@"";
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        if([appDelegate.rootTabBarController.selectedViewController isKindOfClass:[ApprovalsNavigationController class]] || [appDelegate.rootTabBarController.selectedViewController isKindOfClass:[SupervisorDashboardNavigationController class]])
        {

            ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)[self parentDelegate];
            ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
            if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                tsFormat=[approvalsModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:YES];
            }
            else
            {
                tsFormat=[approvalsModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:NO];
            }
        }
        else
        {
            TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
            tsFormat=[timesheetModel getTimesheetFormatforTimesheetUri:timesheetURI];
        }
        if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
        {
            if ([tsFormat isEqualToString:GEN4_DAILY_WIDGET_TIMESHEET])
            {
                if (page<self.viewControllers.count)
                {
                    DailyWidgetDayLevelViewController *dailyWidgetDayLevelViewController = [self.viewControllers objectAtIndex:page];
                    if ((NSNull *)dailyWidgetDayLevelViewController == [NSNull null])
                    {
                        dailyWidgetDayLevelViewController = [[DailyWidgetDayLevelViewController alloc] init];
                        self.delegate=dailyWidgetDayLevelViewController;
                        dailyWidgetDayLevelViewController.sheetIdentity=self.timesheetURI;
                        dailyWidgetDayLevelViewController.controllerDelegate=self;
                        [self.viewControllers replaceObjectAtIndex:page withObject:dailyWidgetDayLevelViewController];
                    }
                    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
                    [dailyWidgetDayLevelViewController.timeEntryTableView setContentOffset:CGPointZero animated:NO];
                    dailyWidgetDayLevelViewController.timesheetDataArray=self.timesheetDataArray;
                    dailyWidgetDayLevelViewController.approvalsDelegate =  parentDelegate;
                    dailyWidgetDayLevelViewController.timesheetEntryObjectArray=[timesheetDataArray objectAtIndex:page];
                    if (self.tsEntryDataArray.count>0)
                    {
                        NSString *formattedDate=[NSString stringWithFormat:@"%@",[[self.tsEntryDataArray objectAtIndex:page] entryDate]];
                        NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
                        [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                        myDateFormatter.dateFormat = @"EEEE, dd MMM yyyy";

                        NSLocale *locale=[NSLocale currentLocale];
                        [myDateFormatter setLocale:locale];
                        NSDate *date=[myDateFormatter dateFromString:[NSString stringWithFormat:@"%@",formattedDate]];
                        dailyWidgetDayLevelViewController.currentPageDate=date;
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.navigationController popToRootViewControllerAnimated:NO];
                        });

                    }

                    // add the controller's view to the scroll view
                    if (dailyWidgetDayLevelViewController.view.superview == nil)
                    {
                        CGFloat frameOriginOffsetY = 0.0f;
                        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
                            //frameOriginOffsetY = 49.0f; // Fixed as per MI-348 ////// Vijay
                        }

                        CGRect frame = self.scrollView.bounds;
                        frame.origin.x = CGRectGetWidth(frame) * page;
                        frame.origin.y += frameOriginOffsetY;
                        frame.size.height -= frameOriginOffsetY;
                        dailyWidgetDayLevelViewController.view.frame = frame;
                        dailyWidgetDayLevelViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
                        dailyWidgetDayLevelViewController.timesheetStatus=timesheetStatus;
                        dailyWidgetDayLevelViewController.timesheetEntryObjectArray=[timesheetDataArray objectAtIndex:page];
                        [self addChildViewController:dailyWidgetDayLevelViewController];
                        [self.scrollView addSubview:dailyWidgetDayLevelViewController.view];
                        [dailyWidgetDayLevelViewController didMoveToParentViewController:self];
                    }

                    [dailyWidgetDayLevelViewController.cellHeightsArray removeAllObjects];
                    //Changes done for day Scroll
                    if (self.currentlySelectedPage==page)
                    {
                        [dailyWidgetDayLevelViewController calculateAndUpdateTotalHoursValueForFooter];
                        if (dailyWidgetDayLevelViewController!=nil && ![dailyWidgetDayLevelViewController isKindOfClass:[NSNull class]])
                        {
                            [[dailyWidgetDayLevelViewController timeEntryTableView]reloadData];
                        }

                    }
                }


            }
            else
            {
                if (page<self.viewControllers.count)
                {
                    DayTimeEntryViewController *controller = [self.viewControllers objectAtIndex:page];
                    if ((NSNull *)controller == [NSNull null])
                    {
                        controller = [[DayTimeEntryViewController alloc] init];
                        self.delegate=controller;
                        controller.sheetIdentity=self.timesheetURI;
                        controller.controllerDelegate=self;
                        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
                    }
                    controller.timesheetDataArray=self.timesheetDataArray;
                    controller.approvalsDelegate =  parentDelegate;
                    controller.timesheetEntryObjectArray=[timesheetDataArray objectAtIndex:page];

                    if (self.tsEntryDataArray.count>0)
                    {
                        NSString *formattedDate=[NSString stringWithFormat:@"%@",[[self.tsEntryDataArray objectAtIndex:page] entryDate]];
                        NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
                        [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                        myDateFormatter.dateFormat = @"EEEE, dd MMM yyyy";

                        NSLocale *locale=[NSLocale currentLocale];
                        [myDateFormatter setLocale:locale];
                        NSDate *date=[myDateFormatter dateFromString:[NSString stringWithFormat:@"%@",formattedDate]];
                        controller.currentPageDate=date;
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.navigationController popToRootViewControllerAnimated:NO];
                        });
                    }

                    // add the controller's view to the scroll view
                    if (controller.view.superview == nil)
                    {
                        CGFloat frameOriginOffsetY = 0.0f;
                        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
                            //frameOriginOffsetY = 49.0f; // Fixed as per MI-348 ////// Vijay
                        }

                        CGRect frame = self.scrollView.bounds;
                        frame.origin.x = CGRectGetWidth(frame) * page;
                        frame.origin.y += frameOriginOffsetY;
                        frame.size.height -= frameOriginOffsetY;
                        controller.view.frame = frame;
                        controller.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
                        controller.standardTimesheetStatus=timesheetStatus;
                        controller.timesheetEntryObjectArray=[timesheetDataArray objectAtIndex:page];
                        [self addChildViewController:controller];
                        [self.scrollView addSubview:controller.view];
                        [controller didMoveToParentViewController:self];
                    }

                    [controller.cellHeightsArray removeAllObjects];
                    //Changes done for day Scroll
                    if (self.currentlySelectedPage==page)
                    {
                        [controller calculateAndUpdateTotalHoursValueForFooter];
                        if (controller!=nil && ![controller isKindOfClass:[NSNull class]])
                        {
                            [[controller timeEntryTableView]reloadData];
                        }

                    }
                }

            }
        }


    }
}

-(void)navigationTitle
{
    //[Util setToolbarLabel: self withText:[NSString stringWithFormat:@"%@",[[self.tsEntryDataArray objectAtIndex:currentlySelectedPage] entryDateWithDesiredFormat]]];
    [self createNavigationBarButton];

}

-(void)addBookTimeOffEntryAction
{

    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        [self performSelector:@selector(hideKeyBoard) withObject:nil afterDelay:1];
        return;
    }


    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
    if (![timesheetModel isTimesheetContainsInflightSaveOperation:timesheetURI])
    {
        if(self.hasUserChangedAnyValue && !self.isTimesheetSaveDone)
        {
            self.isTimesheetSaveDone = YES;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self savingTimesheetWhenClickedOnTimeOff];
                });
            });
        }
        CLS_LOG(@"-----Book timeoff action on TimesheetMainPageController -----");

        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:PULL_TO_REFRESH_TIMEOFFS_RECEIVED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(timeOffDetailsResponse)
                                                     name:PULL_TO_REFRESH_TIMEOFFS_RECEIVED_NOTIFICATION
                                                   object:nil];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate showTransparentLoadingOverlay];
        [[RepliconServiceManager timesheetService] fetchTimeoffData:nil];
        //[bookedTimeOffEntryController TimeOffDetailsReceived];
        [self hideKeyBoard];
    }
    else
    {
        [self showINProgressAlertView];
    }
}

-(void)timeOffDetailsResponse{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PULL_TO_REFRESH_TIMEOFFS_RECEIVED_NOTIFICATION object:nil];
    NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
    NSString *userURI=[standardUserDefaults objectForKey:@"UserUri"];
    TimeoffModel *timeoffModel=[[TimeoffModel alloc]init];
    
    NSMutableArray *timeOffTypesArray=[timeoffModel getAllTimeOffTypesFromDB];
    if ([timeOffTypesArray count]==0)
    {
        [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                       otherButtonTitle:nil
                                               delegate:self
                                                message:RPLocalizedString(noTimeOffTypesAssigned, @"")
                                                  title:nil
                                                    tag:9999];
        return;
    }
    
    BOOL isMultiDayTimeOff=[timeoffModel hasMultiDayTimeOffBooking:userURI];
    if(isMultiDayTimeOff){
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        MultiDayTimeOffViewController *multiDayTimeOffViewController = [appDelegate.injector getInstance:InjectorKeyMultiDayTimeOffViewController];
        NSDate *date = [self dateFromDataArray];
        [multiDayTimeOffViewController setupWithModelType:TimeOffModelTypeTimeOff screenMode:ADD_BOOKTIMEOFF navigationFlow:TIMESHEET_PERIOD_NAVIGATION delegate:self timeOffUri:nil timeSheetURI:timesheetURI date:date];
        UINavigationController *tempnavcontroller = [[UINavigationController alloc] initWithRootViewController:multiDayTimeOffViewController];
        [self presentViewController:tempnavcontroller animated:YES completion:nil];
    } else {
        TimeOffObject *bookedTimeOffObject=[[TimeOffObject alloc]init];
        
        [bookedTimeOffObject setBookedStartDate:nil];
        [bookedTimeOffObject setBookedEndDate:nil];
        bookedTimeOffObject.typeName=nil;
        bookedTimeOffObject.typeIdentity=nil;
        bookedTimeOffObject.comments=nil;
        bookedTimeOffObject.sheetId=nil;
        bookedTimeOffObject.numberOfHours=nil;
        bookedTimeOffObject.approvalStatus=nil;
        bookedTimeOffObject.startDurationEntryType=nil;
        bookedTimeOffObject.endDurationEntryType=nil;
        bookedTimeOffObject.entryDate=nil;
        bookedTimeOffObject.endTime=nil;
        bookedTimeOffObject.startTime=nil;
        bookedTimeOffObject.startNumberOfHours=nil;
        bookedTimeOffObject.endNumberOfHours=nil;
        
        NSDate *date=[self dateFromDataArray];
        if(date!=nil && date!=(id)[NSNull null])
        {
            [bookedTimeOffObject setBookedStartDate:date];
            [bookedTimeOffObject setBookedEndDate:date];
        }
        
        TimeOffDetailsViewController *bookedTimeOffEntryController= [[TimeOffDetailsViewController alloc]initWithEntryDetails:nil sheetId:nil screenMode:ADD_BOOKTIMEOFF];
        bookedTimeOffEntryController.startDateTimesheetString=(NSString *)[[tsEntryDataArray objectAtIndex:0] entryDate];
        bookedTimeOffEntryController.endDateTimesheetString=(NSString *)[[tsEntryDataArray objectAtIndex:[tsEntryDataArray count]-1]entryDate];
        bookedTimeOffEntryController.isStatusView=NO;
        bookedTimeOffEntryController.timesheetURI=timesheetURI;
        [bookedTimeOffEntryController setSheetIdString:[bookedTimeOffObject sheetId]];
        bookedTimeOffEntryController.parentDelegate=self;
        bookedTimeOffEntryController.navigationFlow = TIMESHEET_PERIOD_NAVIGATION;
        [bookedTimeOffEntryController setTimeOffObj:bookedTimeOffObject];
        [bookedTimeOffEntryController TimeOffDetailsReceived];
        UINavigationController *tempnavcontroller = [[UINavigationController alloc] initWithRootViewController:bookedTimeOffEntryController];
        [self presentViewController:tempnavcontroller animated:YES completion:nil];
    }
}

- (NSDate *)dateFromDataArray {
    NSString *formattedDate=[NSString stringWithFormat:@"%@",[[self.tsEntryDataArray objectAtIndex:currentlySelectedPage] entryDate]];
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    myDateFormatter.dateFormat = @"EEEE, dd MMM yyyy";
    
    NSLocale *locale=[NSLocale currentLocale];
    [myDateFormatter setLocale:locale];
    return [myDateFormatter dateFromString:[NSString stringWithFormat:@"%@",formattedDate]];
}

-(void)createNavigationBarButton
{

    SupportDataModel *supportDataModel = [[SupportDataModel alloc] init];
    NSMutableArray *userDetailsArr=[supportDataModel getUserDetailsFromDatabase];

    //Implemented as per TOFF-115//JUHI
    UIImage *iconImage = [UIImage imageNamed:@"icon_vacation_palmtree"];

    BOOL _hasTimesheetTimeoffAccess        = FALSE;
    BOOL hasTimeoffBookingAccess=FALSE;

    if (userDetailsArr!=nil && ![userDetailsArr isKindOfClass:[NSNull class]])
    {
        NSDictionary *userDetailsDict=[userDetailsArr objectAtIndex:0];
        _hasTimesheetTimeoffAccess        = [[userDetailsDict objectForKey:@"hasTimesheetTimeoffAccess"]boolValue];
        hasTimeoffBookingAccess        = [[userDetailsDict objectForKey:@"hasTimeoffBookingAccess"]boolValue];//Implemented as per TOFF-115//JUHI
    }
    //Implemented as per TOFF-115//JUHI
    float version= [[UIDevice currentDevice].systemVersion newFloatValue];
    //Implemented as per US7859
    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
    NSDictionary *dataDic=[timesheetModel getAvailableTimeOffTypeCountInfoForTimesheetIdentity:self.timesheetURI];
    //Implemented as per TIME-495//JUHI
    BOOL isGen4Timesheet=NO;
    NSString *timesheetFormat=nil;
   
    NSArray *array=nil;
    
   if ([self.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [parentDelegate isKindOfClass:[ApprovalsScrollViewController class]] || [self.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]] || [parentDelegate isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)parentDelegate;
        ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            array=[approvalsModel getTimeSheetInfoSheetIdentityForPending:timesheetURI];
            
        }
        else
        {
            array=[approvalsModel getTimeSheetInfoSheetIdentityForPrevious:timesheetURI];
        }
    }
    else
    {
        TimesheetModel *tsModel=[[TimesheetModel alloc]init];
        array=[tsModel getTimeSheetInfoSheetIdentity:timesheetURI];
        
        
    }
    if ([array count]>0) {

        if ([(NSMutableArray *)[array objectAtIndex:0] count]>0)
        {
            timesheetFormat=[[array objectAtIndex:0] objectForKey:@"timesheetFormat"];
            if(timesheetFormat!=nil && ![timesheetFormat isKindOfClass:[NSNull class]])
            {
                 if (([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET] ||  [timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])) {
                    isGen4Timesheet=YES;
                }

            }

        }

    }

    int availableTimeOffTypeCount=0;

    if (dataDic!=nil && ![dataDic isKindOfClass:[NSNull class]])
    {
        availableTimeOffTypeCount=[[dataDic objectForKey:@"availableTimeOffTypeCount"]intValue];
    }


    if (self.isMultiDayInOutTimesheetUser)
    {
        if (multiDayInOutType==EXTENDED_IN_OUT_TIMESHEET_TYPE)
        {

            //Implemented as per TIME-495//JUHI
            if (isGen4Timesheet)
            {

                if (hasTimeoffBookingAccess)
                {
                    SupportDataModel *supportModel=[[SupportDataModel alloc]init];
                    NSDictionary *dict=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
                    BOOL isBreakAccess=NO;
                    BOOL isProjectAccess=NO;
                    BOOL isActivityAccess=NO;
                    if (timesheetFormat!=nil && ![timesheetFormat isKindOfClass:[NSNull class]])
                    {
                        if([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET])
                        {
                            isBreakAccess=[[dict objectForKey:@"allowBreakForInOutGen4"] boolValue];
                        }
                        else if([timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                        {
                            isBreakAccess=[[dict objectForKey:@"allowBreakForExtInOutGen4"] boolValue];
                            isProjectAccess=[[dict objectForKey:@"allowProjectsTasksForExtInOutGen4"] boolValue];
                            isActivityAccess=[[dict objectForKey:@"allowActivitiesForExtInOutGen4"] boolValue];
                        }
                        else if([timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                        {
                            isBreakAccess=[[dict objectForKey:@"allowBreakForStandardGen4"] boolValue];
                        }
                    }

                    UIImage *timeOffImage = [UIImage imageNamed:@"icon_vacation_palmtree"];
                    UIImage *plusImage = [UIImage imageNamed:@"icon_task_plus_button"];

                    UIBarButtonItem *timeOffBarButtonItem = [[UIBarButtonItem alloc] initWithImage:timeOffImage
                                                                                             style:UIBarButtonItemStylePlain
                                                                                            target:self
                                                                                            action:@selector(addBookTimeOffEntryAction)];
                    [timeOffBarButtonItem setAccessibilityLabel:@"uia_timeoff_button_identifier"];



                    NSMutableArray *items = [NSMutableArray arrayWithObject:timeOffBarButtonItem];

                    if (isBreakAccess)
                    {
                        UIBarButtonItem *timeEntryButtonItem = [[UIBarButtonItem alloc] initWithImage:plusImage
                                                                                                style:UIBarButtonItemStylePlain
                                                                                               target:self
                                                                                               action:@selector(addAdhocTimeEntryAction)];
                        [items insertObject:timeEntryButtonItem atIndex:0];
                    }
                    else
                    {
                        if (timesheetFormat!=nil && ![timesheetFormat isKindOfClass:[NSNull class]])
                        {
                            if([timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                            {
                                if (isActivityAccess || isProjectAccess)
                                {
                                    UIBarButtonItem *timeEntryButtonItem = [[UIBarButtonItem alloc] initWithImage:plusImage
                                                                                                            style:UIBarButtonItemStylePlain
                                                                                                           target:self
                                                                                                           action:@selector(addAdhocTimeEntryAction)];
                                    [items insertObject:timeEntryButtonItem atIndex:0];
                                }
                            }
                        }

                    }

                    self.navigationItem.rightBarButtonItems = items;
                }
                else{

                    SupportDataModel *supportModel=[[SupportDataModel alloc]init];
                    NSDictionary *dict=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
                    BOOL isBreakAccess=NO;
                    BOOL isProjectAccess=NO;
                    BOOL isActivityAccess=NO;
                    if (timesheetFormat!=nil && ![timesheetFormat isKindOfClass:[NSNull class]])
                    {
                        if([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET])
                        {
                            isBreakAccess=[[dict objectForKey:@"allowBreakForInOutGen4"] boolValue];
                        }
                        else if([timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                        {
                            isBreakAccess=[[dict objectForKey:@"allowBreakForExtInOutGen4"] boolValue];
                            isProjectAccess=[[dict objectForKey:@"allowProjectsTasksForExtInOutGen4"] boolValue];
                            isActivityAccess=[[dict objectForKey:@"allowActivitiesForExtInOutGen4"] boolValue];
                        }
                        else if([timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                        {
                            isBreakAccess=[[dict objectForKey:@"allowBreakForStandardGen4"] boolValue];
                        }

                        if (isBreakAccess)
                        {
                            UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAdhocTimeEntryAction)];
                            self.navigationItem.rightBarButtonItem = item;
                        }
                        else if([timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                        {
                            if (isActivityAccess || isProjectAccess)
                            {
                                UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAdhocTimeEntryAction)];
                                self.navigationItem.rightBarButtonItem = item;
                            }
                        }
                        else
                        {
                            self.navigationItem.rightBarButtonItem = nil;
                        }
                    }



                }

            }
            else
            {
                //Implemented as per TOFF-115//JUHI
                if (!_hasTimesheetTimeoffAccess && hasTimeoffBookingAccess)
                {
                    UIImage *timeOffImage = [UIImage imageNamed:@"icon_vacation_palmtree"];
                    UIImage *plusImage = [UIImage imageNamed:@"icon_task_plus_button"];

                    UIBarButtonItem *timeOffBarButtonItem = [[UIBarButtonItem alloc] initWithImage:timeOffImage
                                                                                             style:UIBarButtonItemStylePlain
                                                                                            target:self
                                                                                            action:@selector(addBookTimeOffEntryAction)];

                    UIBarButtonItem *timeEntryButtonItem = [[UIBarButtonItem alloc] initWithImage:plusImage
                                                                                            style:UIBarButtonItemStylePlain
                                                                                           target:self
                                                                                           action:@selector(addAdhocTimeEntryAction)];

                    self.navigationItem.rightBarButtonItems = @[timeEntryButtonItem, timeOffBarButtonItem];
                }
                else{
                    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAdhocTimeEntryAction)];
                    self.navigationItem.rightBarButtonItem = item;
                }

            }

            if(timesheetStatus!=nil && ![timesheetStatus isKindOfClass:[NSNull class]])
            {
                if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[timesheetStatus isEqualToString:APPROVED_STATUS ] || [timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED])
                {
                    self.navigationItem.rightBarButtonItem=nil;
                    self.navigationItem.rightBarButtonItems=nil;
                }
            }


        }

        else
        {

            UIImage *addTaskImage=[Util thumbnailImage:ADHOC_TASK_IMAGE];
            UIImage *addTimeoffImage=[Util thumbnailImage:ADHOC_OFF_IMAGE];
            if (version>=7.0)
            {
                addTaskImage=[Util thumbnailImage:ios7_ADHOC_TASK_IMAGE];
                addTimeoffImage=[Util thumbnailImage:ios7_ADHOC_OFF_IMAGE];
            }

            UIView* container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 88, 44)];
            [container setBackgroundColor:[UIColor clearColor]];

            //Implemented as per TIME-495//JUHI
            if (isGen4Timesheet && hasTimeoffBookingAccess)
            {
                UIButton *timeOffBtn=[UIButton buttonWithType:UIButtonTypeCustom];
                [timeOffBtn setFrame:CGRectMake(0, 0, 44, 44)];
                [timeOffBtn setImage:iconImage forState:UIControlStateNormal];

                [timeOffBtn addTarget:self action:@selector(addBookTimeOffEntryAction) forControlEvents:UIControlEventTouchUpInside];
                [container addSubview:timeOffBtn];

            }
            else
            {
                //Implemented as per US7859
                if (_hasTimesheetTimeoffAccess && availableTimeOffTypeCount>0)
                {
                    UIButton *timeOffBtn=[UIButton buttonWithType:UIButtonTypeCustom];
                    [timeOffBtn setFrame:CGRectMake(0, 0, 44, 44)];
                    if (version>=7.0)
                    {
                        [timeOffBtn setImage:[Util thumbnailImage:ios7_ADHOC_OFF_IMAGE] forState:UIControlStateNormal];
                        [timeOffBtn setImage:[Util thumbnailImage:ios7_ADHOC_OFF_PRESSED_IMAGE] forState:UIControlStateHighlighted];
                    }
                    else
                    {
                        [timeOffBtn setImage:[Util thumbnailImage:ADHOC_OFF_IMAGE] forState:UIControlStateNormal];
                        [timeOffBtn setImage:[Util thumbnailImage:ADHOC_OFF_PRESSED_IMAGE] forState:UIControlStateHighlighted];
                    }

                    [timeOffBtn addTarget:self action:@selector(addAdhocTimeEntryAction) forControlEvents:UIControlEventTouchUpInside];
                    if (multiDayInOutType!=EXTENDED_IN_OUT_TIMESHEET_TYPE)
                    {
                        [container addSubview:timeOffBtn];
                    }

                }
                //Implemented as per TOFF-115//JUHI

                else if (!_hasTimesheetTimeoffAccess && hasTimeoffBookingAccess)
                {

                    UIButton *timeOffBtn=[UIButton buttonWithType:UIButtonTypeCustom];
                    [timeOffBtn setFrame:CGRectMake(0, 0, 44, 44)];
                    [timeOffBtn setImage:iconImage forState:UIControlStateNormal];

                    [timeOffBtn addTarget:self action:@selector(addBookTimeOffEntryAction) forControlEvents:UIControlEventTouchUpInside];
                    [container addSubview:timeOffBtn];

                }

            }



            UIButton *timeEntryBtn=[UIButton buttonWithType:UIButtonTypeCustom];

            if (!_hasTimesheetTimeoffAccess && hasTimeoffBookingAccess)
            {
                [timeEntryBtn setFrame:CGRectMake(44, 0, 44, 44)];

            }
            else
            {
                [timeEntryBtn setFrame:CGRectMake(44, 0,44, 44)];

            }
            if (version>=7.0)
            {
                [timeEntryBtn setImage:[Util thumbnailImage:ios7_ADHOC_TASK_IMAGE] forState:UIControlStateNormal];
                [timeEntryBtn setImage:[Util thumbnailImage:ios7_ADHOC_TASK_PRESSED_IMAGE] forState:UIControlStateHighlighted];

            }
            else
            {
                [timeEntryBtn setImage:[Util thumbnailImage:ADHOC_TASK_IMAGE] forState:UIControlStateNormal];
                [timeEntryBtn setImage:[Util thumbnailImage:ADHOC_TASK_PRESSED_IMAGE] forState:UIControlStateHighlighted];

            }
            if (multiDayInOutType==EXTENDED_IN_OUT_TIMESHEET_TYPE)
            {
                [timeEntryBtn addTarget:self action:@selector(addAdhocTimeEntryAction) forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                [timeEntryBtn addTarget:self action:@selector(addInOutTimeEntryRowAction:) forControlEvents:UIControlEventTouchUpInside];
            }

            [container addSubview:timeEntryBtn];

            UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:container];
            self.navigationItem.rightBarButtonItem = item;

            if(timesheetStatus!=nil && ![timesheetStatus isKindOfClass:[NSNull class]])
            {
                if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[timesheetStatus isEqualToString:APPROVED_STATUS ] || [timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED])
                {
                    self.navigationItem.rightBarButtonItem=nil;
                    self.navigationItem.rightBarButtonItems=nil;
                    
                }
            }


            UIBarButtonItem *tempLeftButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(SAVE_STRING,@"")
                                                                                      style:UIBarButtonItemStylePlain
                                                                                     target:self action:@selector(backAndSaveAction:)];
            if (!self.hasUserChangedAnyValue) {
                [self.navigationItem setLeftBarButtonItem:nil animated:NO];
            }
            else
            {
                [self.navigationItem setLeftBarButtonItem:tempLeftButtonOuterBtn animated:NO];
            }
        }
    }
    else
    {

        if (timesheetFormat!=nil && ![timesheetFormat isKindOfClass:[NSNull class]])
        {
            if (isGen4Timesheet && ([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET]))
            {
                if (hasTimeoffBookingAccess) {
                    UIView* container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 88,44)];
                    [container setBackgroundColor:[UIColor clearColor]];
                    UIButton *timeOffBtn=[UIButton buttonWithType:UIButtonTypeCustom];
                    [timeOffBtn setFrame:CGRectMake(0, 0, 44, 44)];
                    [timeOffBtn setImage:iconImage forState:UIControlStateNormal];

                    [timeOffBtn addTarget:self action:@selector(addBookTimeOffEntryAction) forControlEvents:UIControlEventTouchUpInside];
                    [container addSubview:timeOffBtn];

                    UIButton *timeEntryBtn=[UIButton buttonWithType:UIButtonTypeCustom];
                    [timeEntryBtn setFrame:CGRectMake(timeOffBtn.frame.origin.x+timeOffBtn.frame.size.width, 0, 44, 44)];

                    [timeEntryBtn setImage:[Util thumbnailImage:TIMESHEET_TIMEENTRY_ICON] forState:UIControlStateNormal];



                    [timeEntryBtn addTarget:self action:@selector(addAdhocTimeEntryAction) forControlEvents:UIControlEventTouchUpInside];
                    [container addSubview:timeEntryBtn];
                    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:container];
                    self.navigationItem.rightBarButtonItem = item;
                }
                else
                {
                    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAdhocTimeEntryAction)];
                    self.navigationItem.rightBarButtonItem = item;
                }

            }
            else if ([timesheetFormat isEqualToString:GEN4_DAILY_WIDGET_TIMESHEET])
            {
                self.navigationItem.rightBarButtonItem=nil;
                self.navigationItem.rightBarButtonItems=nil;
            }
            else
            {
                //Implemented as per TOFF-115//JUHI
                if (!_hasTimesheetTimeoffAccess && hasTimeoffBookingAccess)
                {
                    UIImage *timeOffImage = [UIImage imageNamed:@"icon_vacation_palmtree"];
                    UIImage *plusImage = [UIImage imageNamed:@"icon_task_plus_button"];

                    UIBarButtonItem *timeOffBarButtonItem = [[UIBarButtonItem alloc] initWithImage:timeOffImage
                                                                                             style:UIBarButtonItemStylePlain
                                                                                            target:self
                                                                                            action:@selector(addBookTimeOffEntryAction)];
                    [timeOffBarButtonItem setAccessibilityLabel:@"uia_timeoff_button_identifier"];


                    UIBarButtonItem *timeEntryButtonItem = [[UIBarButtonItem alloc] initWithImage:plusImage
                                                                                            style:UIBarButtonItemStylePlain
                                                                                           target:self
                                                                                           action:@selector(addAdhocTimeEntryAction)];

                    self.navigationItem.rightBarButtonItems = @[timeEntryButtonItem, timeOffBarButtonItem];
                }
                else{
                    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAdhocTimeEntryAction)];
                    [item setAccessibilityLabel:@"time_dist_add_btn"];
                    self.navigationItem.rightBarButtonItem = item;
                }
            }
        }


        if(timesheetStatus!=nil && ![timesheetStatus isKindOfClass:[NSNull class]])
        {
            if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[timesheetStatus isEqualToString:APPROVED_STATUS ] || [timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED])
            {
                self.navigationItem.rightBarButtonItem=nil;
                self.navigationItem.rightBarButtonItems=nil;
            }
        }



        UIBarButtonItem *tempLeftButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(SAVE_STRING, @"")
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self action:@selector(backAndSaveAction:)];
        if (!self.hasUserChangedAnyValue)
        {
            [self.navigationItem setLeftBarButtonItem:nil animated:NO];
        }
        else
        {
            [self.navigationItem setLeftBarButtonItem:tempLeftButtonOuterBtn animated:NO];
        }
    }
}

-(void)updateAdhocTimeoffUdfValuesAcrossEntireTimesheet:(NSInteger)index withUdfArray:(NSMutableArray *)tempUdfArray
{
    for (int k=0; k<[self.viewControllers count]; k++)
    {
        if (self.isMultiDayInOutTimesheetUser)
        {
            MultiDayInOutViewController *controller = [self.viewControllers objectAtIndex:k];
            if ((NSNull *)controller == [NSNull null])
            {
                controller = [[MultiDayInOutViewController alloc] init];
                [controller setSelectedButtonTag:-1];
                self.delegate=controller;
                controller.controllerDelegate=self;
            }

            if ([controller isKindOfClass:[MultiDayInOutViewController class]])
            {
                controller.timesheetEntryObjectArray=[timesheetDataArray objectAtIndex:k];
                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[controller.timesheetEntryObjectArray objectAtIndex:index];
                [controller.timesheetEntryObjectArray replaceObjectAtIndex:index withObject:tsEntryObject];
                [self.viewControllers replaceObjectAtIndex:k withObject:controller];
            }

        }
        else
        {

            DayTimeEntryViewController *controller = [self.viewControllers objectAtIndex:k];
            if ((NSNull *)controller == [NSNull null])
            {
                controller = [[DayTimeEntryViewController alloc] init];
                self.delegate=controller;
                controller.sheetIdentity=self.timesheetURI;
                controller.controllerDelegate=self;
            }
            controller.timesheetEntryObjectArray=[timesheetDataArray objectAtIndex:k];
            TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[controller.timesheetEntryObjectArray objectAtIndex:index];
            [tsEntryObject setTimeEntryUdfArray:tempUdfArray];
            [controller.timesheetEntryObjectArray replaceObjectAtIndex:index withObject:tsEntryObject];
            [self.viewControllers replaceObjectAtIndex:k withObject:controller];
        }

    }

}

-(NSMutableArray *)getUDFArrayForModuleName:(NSString *)moduleName andEntryDate:(NSDate *)entryDate andEntryType:(NSString *)entryType andRowUri:(NSString *)rowUri isRowEditable:(BOOL)isRowEditable
{
    NSMutableArray *customFieldArray=[NSMutableArray array];
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

            if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS] ||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED] ||[entryType isEqualToString:Time_Off_Key]) {
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
            if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS]||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED]||[entryType isEqualToString:Time_Off_Key] ) {
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

            if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS]||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED]||[entryType isEqualToString:Time_Off_Key] ) {
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
                        if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS]||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED]||[entryType isEqualToString:Time_Off_Key] ) {
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
                    if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS] ||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED]||[entryType isEqualToString:Time_Off_Key]) {
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
            if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS] ||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED]||[entryType isEqualToString:Time_Off_Key]) {
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
                    [dictInfo setObject:[udfDict objectForKey:@"textDefaultValue"] forKey:@"systemDefaultValue"];

                }
            }
        }
        NSString *entryDateTimestamp=[NSString stringWithFormat:@"%f",[Util convertDateToTimestamp:entryDate]];
        NSArray *selectedudfArray=nil;
        //Approval context Flow for Timesheets
        if ([self.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [parentDelegate isKindOfClass:[ApprovalsScrollViewController class]] || [self.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]] || [parentDelegate isKindOfClass:[SupervisorDashboardNavigationController class]])
        {
            ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
            ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)parentDelegate;
            if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                //Implementation for US9371//JUHI
                if ([moduleName isEqualToString:TIMESHEET_ROW_UDF])
                {
                    selectedudfArray=[approvalsModel getPendingTimesheetSheetCustomFieldsForSheetURI:timesheetURI moduleName:moduleName andUdfURI:[dictInfo objectForKey: @"identity"]andRowUri:rowUri];
                }
                else
                    selectedudfArray=[approvalsModel getPendingTimesheetSheetUdfInfoForSheetURI:timesheetURI moduleName:moduleName andUdfURI:[dictInfo objectForKey: @"identity"] entryDate:entryDateTimestamp andRowUri:rowUri];
            }
            else
            {
                //Implementation for US9371//JUHI
                if ([moduleName isEqualToString:TIMESHEET_ROW_UDF])
                {
                    selectedudfArray=[approvalsModel getPreviousTimesheetSheetCustomFieldsForSheetURI:timesheetURI moduleName:moduleName andUdfURI:[dictInfo objectForKey: @"identity"]andRowUri:rowUri];
                }
                else
                    selectedudfArray=[approvalsModel getPreviousTimesheetSheetUdfInfoForSheetURI:timesheetURI moduleName:moduleName andUdfURI:[dictInfo objectForKey: @"identity"] entryDate:entryDateTimestamp andRowUri:rowUri];


            }



        }
        //User context Flow for Timesheets
        else if([parentDelegate isKindOfClass:[CurrentTimesheetViewController class]])
        {
            TimesheetModel *timeSheetModel=[[TimesheetModel alloc]init];
            //Implementation for US9371//JUHI
            if ([moduleName isEqualToString:TIMESHEET_ROW_UDF])
            {
                selectedudfArray=[timeSheetModel getTimesheetSheetCustomFieldsForSheetURI:timesheetURI moduleName:moduleName andUdfURI:[dictInfo objectForKey: @"identity"]andRowUri:rowUri];
            }
            else
                selectedudfArray=[timeSheetModel getTimesheetSheetUdfInfoForSheetURI:timesheetURI moduleName:moduleName andUdfURI:[dictInfo objectForKey: @"identity"] entryDate:entryDateTimestamp andRowUri:rowUri];

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
                        if (([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[timesheetStatus isEqualToString:APPROVED_STATUS ]||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED])) {
                            [udfDetailDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
                        }
                        else
                            [udfDetailDict setObject:[dictInfo objectForKey: @"defaultValue" ] forKey:@"defaultValue"];


                    }

                }
                else
                {
                    if (([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[timesheetStatus isEqualToString:APPROVED_STATUS ]||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED])) {
                        [udfDetailDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
                    }
                    else
                        [udfDetailDict setObject:[dictInfo objectForKey: @"defaultValue" ] forKey:@"defaultValue"];

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

                //                if ([[selUDFDataDict objectForKey:@"entry_type"] isEqualToString:DROPDOWN_UDF_TYPE])
                //                {
                //                    if ([dictInfo objectForKey: @"dropDownOptionUri" ]!=nil)
                //                    {
                //                        [udfDetailDict setObject:[dictInfo objectForKey: @"dropDownOptionUri" ] forKey:@"dropDownOptionUri"];
                //                    }
                //                }

                [customFieldArray addObject:udfDetailDict];

            }
        }
        else{
            NSMutableDictionary *udfDetailDict=[[NSMutableDictionary alloc]init];
            if (([entryType isEqualToString:Time_Off_Key]||[timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[timesheetStatus isEqualToString:APPROVED_STATUS ]||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED])||(!isRowEditable && [entryType isEqualToString:Time_Entry_Key]))
            {
                [udfDetailDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
            }
            else
            {
                [udfDetailDict setObject:[dictInfo objectForKey: @"defaultValue" ] forKey:@"defaultValue"];
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
            if ([dictInfo objectForKey: @"dropDownOptionUri" ]!=nil)
            {
                [udfDetailDict setObject:[dictInfo objectForKey: @"dropDownOptionUri" ] forKey:@"dropDownOptionUri"];
            }
            [customFieldArray addObject:udfDetailDict];


        }

    }

    return customFieldArray;
}

-(NSMutableArray *)getUDFArrayForAdhocTimeoffInStandard:(NSString *)moduleName andEntryType:(NSString *)entryType andRowUri:(NSString *)rowUri
{
    NSMutableArray *customFieldArray=[NSMutableArray array];
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

            if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS] ||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED]||[entryType isEqualToString:Time_Off_Key]) {
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
            if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS] ||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED]||[entryType isEqualToString:Time_Off_Key]) {
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

            if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS] ||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED]||[entryType isEqualToString:Time_Off_Key]) {
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
                        if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS] ||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED]||[entryType isEqualToString:Time_Off_Key]) {
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
                    if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS] ||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED]||[entryType isEqualToString:Time_Off_Key]) {
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
            if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS] ||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED]||[entryType isEqualToString:Time_Off_Key]) {
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
                    [dictInfo setObject:[udfDict objectForKey:@"textDefaultValue"] forKey:@"systemDefaultValue"];

                }
            }
        }
        NSArray *selectedudfArray=nil;
        //Approval context Flow for Timesheets
        if ([self.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [parentDelegate isKindOfClass:[ApprovalsScrollViewController class]] || [self.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]] || [parentDelegate isKindOfClass:[SupervisorDashboardNavigationController class]])
        {
            ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
            ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)parentDelegate;
            if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                selectedudfArray=[approvalsModel getPendingTimesheetSheetUdfInfoForSheetUri:timesheetURI moduleName:moduleName andUdfURI:[dictInfo objectForKey: @"identity"] andRowUri:rowUri];
            }
            else
            {
                selectedudfArray=[approvalsModel getPreviousTimesheetSheetUdfInfoForSheetUri:timesheetURI moduleName:moduleName andUdfURI:[dictInfo objectForKey: @"identity"] andRowUri:rowUri];
            }


        }
        //User context Flow for Timesheets
        else if([parentDelegate isKindOfClass:[CurrentTimesheetViewController class]])
        {
            TimesheetModel *timeSheetModel=[[TimesheetModel alloc]init];
            selectedudfArray=[timeSheetModel getTimesheetSheetUdfInfoForSheetUri:timesheetURI moduleName:moduleName andUdfURI:[dictInfo objectForKey: @"identity"] andRowUri:rowUri];

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
                        if (([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[timesheetStatus isEqualToString:APPROVED_STATUS ]||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED])) {
                            [udfDetailDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
                        }
                        else
                            [udfDetailDict setObject:[dictInfo objectForKey: @"defaultValue" ] forKey:@"defaultValue"];


                    }

                }
                else
                {
                    if (([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[timesheetStatus isEqualToString:APPROVED_STATUS ]||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED])) {
                        [udfDetailDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
                    }
                    else
                        [udfDetailDict setObject:[dictInfo objectForKey: @"defaultValue" ] forKey:@"defaultValue"];

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
                //                if ([[selUDFDataDict objectForKey:@"entry_type"] isEqualToString:DROPDOWN_UDF_TYPE])
                //                {
                //                    if ([dictInfo objectForKey: @"dropDownOptionUri" ]!=nil)
                //                    {
                //                        [udfDetailDict setObject:[dictInfo objectForKey: @"dropDownOptionUri" ] forKey:@"dropDownOptionUri"];
                //                    }
                //                }

                [customFieldArray addObject:udfDetailDict];

            }
        }
        else{
            NSMutableDictionary *udfDetailDict=[[NSMutableDictionary alloc]init];

            if ([entryType isEqualToString:Time_Off_Key]||[timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[timesheetStatus isEqualToString:APPROVED_STATUS ]||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED])
            {
                [udfDetailDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
            }
            else
            {
                [udfDetailDict setObject:[dictInfo objectForKey: @"defaultValue" ] forKey:@"defaultValue"];
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
            if ([dictInfo objectForKey: @"dropDownOptionUri" ]!=nil)
            {
                [udfDetailDict setObject:[dictInfo objectForKey: @"dropDownOptionUri" ] forKey:@"dropDownOptionUri"];
            }
            [customFieldArray addObject:udfDetailDict];


        }

    }
    return customFieldArray;
}



-(void)updateAdHocFieldWithFieldName:(NSString*)fieldName andFieldURI:(NSString*)fieldUri
{

    self.selectedAdhocTimeoffName = fieldName;
    self.selectedAdhocTimeoffUri  = fieldUri;

    [self addTimeOffTypeAction];
}

-(void)resetDayScrollViewPosition
{
    //NSLog(@"resetDayScrollViewPosition");
    if (daySelectionScrollViewDelegate!=nil &&[daySelectionScrollViewDelegate isKindOfClass:[DaySelectionScrollView class]])
    {
        [daySelectionScrollViewDelegate resetDayScrollViewPositionToViewSelectedButton];
    }

}
-(void)checkAndupdateCurrentButtonFilledStatus:(BOOL)hoursPresent andPageSelected:(NSInteger)pageSelected
{
    if (daySelectionScrollViewDelegate!=nil &&[daySelectionScrollViewDelegate isKindOfClass:[DaySelectionScrollView class]])
    {
        [daySelectionScrollViewDelegate updateFilledStatusOfSelectedButton:hoursPresent onPage:pageSelected];
    }
}

-(NSMutableArray *)createUdfs
{
    int decimalPlace=0;
    LoginModel *loginModel=[[LoginModel alloc]init];
    NSMutableArray *udfArray=[loginModel getEnabledOnlyUDFsforModuleName:TIMEOFF_UDF];


    NSMutableArray *customFieldArray=[NSMutableArray array];


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
            [dictInfo setObject:NUMERIC_UDF_TYPE forKey:@"fieldType"];

            if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS]||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED] ) {
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
            if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS]||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED] ) {
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

            if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS]||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED] ) {
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
                        if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS]||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED] ) {
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
                    if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS]||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED] ) {
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
            if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS]||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED] ) {
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

        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        selectedudfArray=[timesheetModel getTimesheetSheetCustomFieldsForSheetURI:timesheetURI moduleName:TIMESHEET_SHEET_UDF andUdfURI:[dictInfo objectForKey: @"identity"]];



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
                        if (([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[timesheetStatus isEqualToString:APPROVED_STATUS ]||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED])) {
                            [udfDetailDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
                        }
                        else
                            [udfDetailDict setObject:[dictInfo objectForKey: @"defaultValue" ] forKey:@"defaultValue"];


                    }

                }
                else
                {
                    if (([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[timesheetStatus isEqualToString:APPROVED_STATUS ]||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED])) {
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

                //                if ([[selUDFDataDict objectForKey:@"entry_type"] isEqualToString:DROPDOWN_UDF_TYPE])
                //                {
                //                    if ([dictInfo objectForKey: @"dropDownOptionUri" ]!=nil)
                //                    {
                //                        [udfDetailDict setObject:[dictInfo objectForKey: @"dropDownOptionUri" ] forKey:@"dropDownOptionUri"];
                //                    }
                //                }
                
                [customFieldArray addObject:udfDetailDict];
                
            }
        }
        else{
            NSMutableDictionary *udfDetailDict=[[NSMutableDictionary alloc]init];
            if (([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[timesheetStatus isEqualToString:APPROVED_STATUS ]||[timesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [timesheetStatus isEqualToString:TIMESHEET_SUBMITTED])) {
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
    
    return customFieldArray;
}
-(void)createBlankEntryForGen4:(NSInteger)index andDate:(NSDate *)todayDate
{
    TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc] init];
    
    
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    NSLocale *locale=[NSLocale currentLocale];
    [formatter setLocale:locale];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [formatter setDateFormat:@"EEEE, dd MMM yyyy"];
    
    
    
    NSMutableDictionary *multiDayInOutDict=[NSMutableDictionary dictionary];
    [multiDayInOutDict setObject:@"" forKey:@"in_time"];
    [multiDayInOutDict setObject:@"" forKey:@"out_time"];
    
    [tsEntryObject setTimeEntryDate:todayDate];
    [tsEntryObject setMultiDayInOutEntry:multiDayInOutDict];
    [tsEntryObject setTimeAllocationUri:@""];
    [tsEntryObject setTimePunchUri:@""];
    [tsEntryObject setTimeEntryHoursInHourFormat:@""];
    [tsEntryObject setTimeEntryHoursInDecimalFormat:@"0.00"];
    [tsEntryObject setTimeEntryHoursInDecimalFormatWithOutRoundOff:@"0.00"];
    [tsEntryObject setIsTimeoffSickRowPresent:NO];
    [tsEntryObject setTimeEntryTimeOffName:@""];
    [tsEntryObject setTimeEntryActivityName:@""];
    [tsEntryObject setTimeEntryActivityUri:@""];
    [tsEntryObject setTimeEntryBillingName:@""];
    [tsEntryObject setTimeEntryBillingUri:@""];
    [tsEntryObject setTimeEntryProjectName:@""];
    [tsEntryObject setTimeEntryProjectUri:@""];
    [tsEntryObject setTimeEntryClientName:nil];
    [tsEntryObject setTimeEntryClientUri:nil];
    [tsEntryObject setTimeEntryTaskName:@""];
    [tsEntryObject setTimeEntryTaskUri:@""];
    [tsEntryObject setTimeEntryTimeOffName:@""];
    [tsEntryObject setTimeEntryTimeOffUri:@""];
    [tsEntryObject setTimeEntryComments:@""];
    [tsEntryObject setTimeEntryUdfArray:nil];
    [tsEntryObject setTimesheetUri:timesheetURI];
    NSMutableDictionary *formattedTimePunchesDict=[NSMutableDictionary dictionary];
    [formattedTimePunchesDict setObject:@"" forKey:@"comments"];
    [formattedTimePunchesDict setObject:@"" forKey:@"in_time"];
    [formattedTimePunchesDict setObject:@"" forKey:@"out_time"];
    [formattedTimePunchesDict setObject:[NSMutableArray array] forKey:@"udfArray"];
    [formattedTimePunchesDict setObject:@"" forKey:@"timePunchesUri"];
    [formattedTimePunchesDict setObject:[Util getRandomGUID] forKey:@"clientID"];
    NSMutableArray *timePunchesArr=[NSMutableArray array];
    [timePunchesArr addObject:formattedTimePunchesDict];
    [tsEntryObject setTimePunchesArray:timePunchesArr];
    [tsEntryObject setBreakName:@""];
    [tsEntryObject setBreakUri:@""];
    [tsEntryObject setRowUri:@""];
    NSMutableArray *temptimesheetEntryDataArray=[self.timesheetDataArray objectAtIndex:self.pageControl.currentPage];
    [temptimesheetEntryDataArray addObject:tsEntryObject];
    [self.timesheetDataArray replaceObjectAtIndex:index withObject:temptimesheetEntryDataArray];
}


-(void)recievedTimesheetSummaryData:(NSNotification *)notification
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    SupportDataModel *supportDataModel=[[SupportDataModel alloc]init];
    NSDictionary *dataDict=[supportDataModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
    BOOL hasTimeoffBookingAccessTemplateLevel=NO;
    BOOL hasTimeoffBookingAccessSystemLevel=NO;
    NSMutableArray *userDetailsArr=[supportDataModel getUserDetailsFromDatabase];
    
    
    
    if (userDetailsArr!=nil && ![userDetailsArr isKindOfClass:[NSNull class]])
    {
        NSDictionary *userDetailsDict=[userDetailsArr objectAtIndex:0];
        
        hasTimeoffBookingAccessSystemLevel = [[userDetailsDict objectForKey:@"hasTimeoffBookingAccess"]boolValue];
    }
    
    if (dataDict!=nil && ![dataDict isKindOfClass:[NSNull class]])
    {
        if (hasTimeoffBookingAccessSystemLevel)
        {
            hasTimeoffBookingAccessTemplateLevel=[[dataDict objectForKey:@"allowTimeoffForGen4"] boolValue];
            hasTimeoffBookingAccessTemplateLevel=YES;
        }
        
        
    }
    
    if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
    {
        hasTimeoffBookingAccessTemplateLevel=YES;
    }
    NSArray *dbTimesheetSummaryArray=nil;
    if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
    {
        ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)parentDelegate;
        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            dbTimesheetSummaryArray = [approvalsModel getAllPendingTimesheetDaySummaryFromDBForTimesheet:timesheetURI];
            
        }
        else
        {
            dbTimesheetSummaryArray = [approvalsModel getAllPreviousTimesheetDaySummaryFromDBForTimesheet:timesheetURI];
        }
    }
    else
    {
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        dbTimesheetSummaryArray = [timesheetModel getAllTimesheetDaySummaryFromDBForTimesheet:timesheetURI];
    }
    BOOL isDataCachedAlready=NO;
    if (notification!=nil &&![notification isKindOfClass:[NSNull class]])
    {
        NSDictionary *userInfo=[notification userInfo];
        if (userInfo!=nil && ![userInfo isKindOfClass:[NSNull class]])
        {
            isDataCachedAlready=[[userInfo objectForKey:@"isDataCache"] boolValue];
        }
        
    }
    if (!isDataCachedAlready &&hasTimeoffBookingAccessTemplateLevel)
    {
        
        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)parentDelegate;
            BOOL isPending=NO;
            if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                isPending=YES;
                
            }
            [[NSNotificationCenter defaultCenter] removeObserver:self name:APPROVALS_TIMESHEET_TIMEOFF_SUMMARY_RECIEVED_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedTimeoffData) name:APPROVALS_TIMESHEET_TIMEOFF_SUMMARY_RECIEVED_NOTIFICATION object:nil];
            [[RepliconServiceManager approvalsService]fetchApprovalsTimeSheetTimeoffSummaryDataForGen4TimesheetWithStartDate:self.timesheetStartDate andEndDate:self.timesheetEndDate withDelegate:self withTimesheetUri:timesheetURI withUserUri:userUri isPending:isPending];
            
        }
        else
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_TIMEOFF_SUMMARY_RECIEVED_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedTimeoffData) name:TIMESHEET_TIMEOFF_SUMMARY_RECIEVED_NOTIFICATION object:nil];
            [[RepliconServiceManager timesheetService]fetchTimeSheetTimeOffSummaryDataForGen4TimesheetWithStartDate:self.timesheetStartDate andEndDate:self.timesheetEndDate withDelegate:self withTimesheetUri:timesheetURI];
        }
        
    }
    else
    {
        [self refreshViewWhenDownloadComplete];
    }
    
}
-(void)receivedTimeoffData
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APPROVALS_TIMESHEET_TIMEOFF_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_TIMEOFF_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [self refreshViewWhenDownloadComplete];
}
-(void)refreshViewWhenDownloadComplete
{
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    NSMutableArray *tmpcurrentTimesheetArray=[[NSMutableArray alloc]init];
    NSMutableArray *arrayFromDB=nil;;
    if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
    {
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        arrayFromDB=[timesheetModel getAllTimesheetDaySummaryFromDBForTimesheet:timesheetURI];
        
        
    }
    else if([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
    {
        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)parentDelegate;
        ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            arrayFromDB=[approvalsModel getAllPendingTimesheetDaySummaryFromDBForTimesheet:timesheetURI];
        }
        else
        {
            arrayFromDB=[approvalsModel getAllPreviousTimesheetDaySummaryFromDBForTimesheet:timesheetURI];
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
        NSString *timeSheetFormat=@"";
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        if([appDelegate.rootTabBarController.selectedViewController isKindOfClass:[ApprovalsNavigationController class]] || [appDelegate.rootTabBarController.selectedViewController isKindOfClass:[SupervisorDashboardNavigationController class]])
        {
            
            ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)[self parentDelegate];
            ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
            if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                timeSheetFormat=[approvalsModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:YES];
            }
            else
            {
                timeSheetFormat=[approvalsModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:NO];
            }
        }
        else
        {
            TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
            timeSheetFormat=[timesheetModel getTimesheetFormatforTimesheetUri:timesheetURI];
        }
        if (timeSheetFormat!=nil && ![timeSheetFormat isKindOfClass:[NSNull class]])
        {
            if ([timeSheetFormat isEqualToString:GEN4_PUNCH_WIDGET_TIMESHEET])
            {
                if ([dataDic objectForKey:@"totalPunchTimeDurationDecimal"]!=nil && ![[dataDic objectForKey:@"totalPunchTimeDurationDecimal"] isKindOfClass:[NSNull class]])
                {
                    [timeobj setNumberOfHours:[Util getRoundedValueFromDecimalPlaces:[[dataDic objectForKey:@"totalPunchTimeDurationDecimal"]newDoubleValue]withDecimalPlaces:2]];
                }
                else
                {
                    //[timeobj setNumberOfHours:[Util getRoundedValueFromDecimalPlaces:[@"0" newDoubleValue]withDecimalPlaces:2]];
                }

            }
            else if ([timeSheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [timeSheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
            {
                if ([dataDic objectForKey:@"totalInOutTimeDurationDecimal"]!=nil && ![[dataDic objectForKey:@"totalInOutTimeDurationDecimal"] isKindOfClass:[NSNull class]])
                {

                    NSString *whereString=[NSString stringWithFormat:@"timesheetUri='%@' and timesheetEntryDate='%@' AND isDeleted=0 and timeSheetFormat='%@'",timesheetURI,[dataDic objectForKey:@"timesheetEntryDate"],timeSheetFormat];
                    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];

                    float newEntryTotal = 0.0;

                    if([appDelegate.rootTabBarController.selectedViewController isKindOfClass:[ApprovalsNavigationController class]] || [appDelegate.rootTabBarController.selectedViewController isKindOfClass:[SupervisorDashboardNavigationController class]])
                    {

                        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)[self parentDelegate];
                        ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
                        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                        {
                            newEntryTotal=[approvalsModel getTimeEntryTotalForEntryWithWhereString:whereString isPending:YES];
                        }
                        else
                        {
                            newEntryTotal=[approvalsModel getTimeEntryTotalForEntryWithWhereString:whereString isPending:NO];
                        }
                    }

                    else
                    {
                       newEntryTotal=[timesheetModel getTimeEntryTotalForEntryWithWhereString:whereString];
                    }


                    [timeobj setNumberOfHours:[Util getRoundedValueFromDecimalPlaces:newEntryTotal withDecimalPlaces:2]];

                }
                else
                {
                    //[timeobj setNumberOfHours:[Util getRoundedValueFromDecimalPlaces:[@"0" newDoubleValue]withDecimalPlaces:2]];
                }

            }

            else if (![timeSheetFormat isEqualToString:GEN4_DAILY_WIDGET_TIMESHEET] )
            {
                if ([dataDic objectForKey:@"timesheetEntryTotalDurationDecimal"]!=nil && ![[dataDic objectForKey:@"timesheetEntryTotalDurationDecimal"] isKindOfClass:[NSNull class]])
                {
                    [timeobj setNumberOfHours:[Util getRoundedValueFromDecimalPlaces:[[dataDic objectForKey:@"timesheetEntryTotalDurationDecimal"]newDoubleValue]withDecimalPlaces:2]];
                }
                else
                {
                    //[timeobj setNumberOfHours:[Util getRoundedValueFromDecimalPlaces:[@"0" newDoubleValue]withDecimalPlaces:2]];
                }
            }
        }

        [timeobj setIsDayOff:[[dataDic objectForKey:@"isDayOff"] boolValue]];
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
        
        [tmpcurrentTimesheetArray addObject:timeobj];
        
    }
    
    self.tsEntryDataArray=tmpcurrentTimesheetArray;
    if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
    {
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        NSMutableArray *allTimeEntriesArray=[timesheetModel getAllTimeEntriesForSheetFromDB:timesheetURI];
        if ([allTimeEntriesArray count]==0)
        {
             NSArray *timesheetInfoArray=[timesheetModel getTimeSheetInfoSheetIdentity:timesheetURI];
            NSString *tsFormat=[[timesheetInfoArray objectAtIndex:0] objectForKey:@"timesheetFormat"];
            if ([timesheetInfoArray count]>0)
            {
                if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
                {
                    if ([tsFormat isEqualToString:STANDARD_TIMESHEET] || [tsFormat isEqualToString:GEN4_STANDARD_TIMESHEET] || [tsFormat isEqualToString:GEN4_DAILY_WIDGET_TIMESHEET])
                    {
                        isMultiDayInOutTimesheetUser=NO;
                    }
                    else
                    {
                        isMultiDayInOutTimesheetUser=YES;
                    }
                }
                
            }
            
            if (isMultiDayInOutTimesheetUser)
            {
                self.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[timesheetModel getTimeEntriesForSheetFromDB:timesheetURI]];
                
            }
            else
            {
                self.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[timesheetModel getGroupedStandardTimeEntriesForSheetFromDB:timesheetURI andTimesheetFormat:tsFormat]];
                
            }
            
        }
        else
        {
            NSString *timesheetFormat=[timesheetModel getTimesheetFormatInfoFromDBForTimesheetUri:timesheetURI];
            if (timesheetFormat!=nil && ![timesheetFormat isKindOfClass:[NSNull class]])
            {
                if ([timesheetFormat isEqualToString:STANDARD_TIMESHEET] || [timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                {
                    self.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[timesheetModel getGroupedStandardTimeEntriesForSheetFromDB:timesheetURI andTimesheetFormat:timesheetFormat]];

                }
                else if ([timesheetFormat isEqualToString:EXTENDED_INOUT_TIMESHEET])
                {
                    self.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[timesheetModel getTimeEntriesForExtendedInOutSheetFromDB:timesheetURI andTimeSheetFormat:timesheetFormat]];

                }
                else if([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                {
                    self.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[timesheetModel getTimeEntriesForExtendedInOutSheetFromDB:timesheetURI andTimeSheetFormat:timesheetFormat]];
                }
                else if([timesheetFormat isEqualToString:GEN4_DAILY_WIDGET_TIMESHEET] )
                {
                    self.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[timesheetModel getTimeEntriesForExtendedInOutSheetFromDB:timesheetURI andTimeSheetFormat:timesheetFormat]];
                }
                else
                {


                    self.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[timesheetModel getTimeEntriesForSheetFromDB:timesheetURI]];
                    
                    
                }
            }

            
        }
        
        
        
    }
    else if([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
    {
        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)parentDelegate;
        ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
        NSMutableArray *allTimeEntriesArray=nil;
        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            allTimeEntriesArray=[approvalModel getAllPendingTimeEntriesForSheetFromDB:timesheetURI];
        }
        else
        {
            allTimeEntriesArray=[approvalModel getAllPreviousTimeEntriesForSheetFromDB:timesheetURI];
        }
        
        if ([allTimeEntriesArray count]==0)
        {
            NSMutableArray *arrayDict=nil;
            if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                arrayDict=[approvalModel getPendingApprovalDataForTimesheetSheetURI:timesheetURI];
                
            }
            else
            {
                arrayDict=[approvalModel getPreviousApprovalDataForTimesheetSheetURI:timesheetURI];
            }
            BOOL tmpisMultiDayInOutTimesheetFormat=NO;
            if ([allTimeEntriesArray count]==0)
            {
                if ([arrayDict count]>0)
                {
                    NSString *tsFormat=[[arrayDict objectAtIndex:0] objectForKey:@"timesheetFormat"];
                    if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
                    {
                        if ([tsFormat isEqualToString:STANDARD_TIMESHEET]  || [tsFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
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
                if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                {
                    self.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[approvalModel getPendingTimeEntriesForSheetFromDB:timesheetURI]];
                }
                else
                {
                    self.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[approvalModel getPreviousTimeEntriesForSheetFromDB:timesheetURI]];
                }
                
                
            }
            else
            {
                if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                {
                    self.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[approvalModel getPendingGroupedStandardTimeEntriesForSheetFromDB:timesheetURI]];
                }
                else
                {
                    self.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[approvalModel getPreviousGroupedStandardTimeEntriesForSheetFromDB:timesheetURI]];
                }
                
                
            }
            
        }
        else
        {
            NSString *timesheetFormat=nil;
            if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                timesheetFormat=[approvalModel getPendingTimesheetFormatInfoFromDBForTimesheetUri:timesheetURI];
            }
            else
            {
                timesheetFormat=[approvalModel getPreviousTimesheetFormatInfoFromDBForTimesheetUri:timesheetURI];
            }
            if (timesheetFormat!=nil && ![timesheetFormat isKindOfClass:[NSNull class]])
            {
                if ([timesheetFormat isEqualToString:STANDARD_TIMESHEET] || [timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                {
                    if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                    {
                        self.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[approvalModel getPendingGroupedStandardTimeEntriesForSheetFromDB:timesheetURI]];
                    }
                    else
                    {
                        self.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[approvalModel getPreviousGroupedStandardTimeEntriesForSheetFromDB:timesheetURI]];

                    }


                }//DE19662 Ullas M L
                else if ([timesheetFormat isEqualToString:EXTENDED_INOUT_TIMESHEET] || [timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                {
                    if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                    {
                        self.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[approvalModel getPendingTimeEntriesForExtendedInOutSheetFromDB:timesheetURI]];
                    }
                    else
                    {
                        self.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[approvalModel getPreviousTimeEntriesForExtendedInOutSheetFromDB:timesheetURI]];

                    }


                }
                else
                {
                    if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                    {
                        self.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[approvalModel getPendingTimeEntriesForSheetFromDB:timesheetURI]];
                    }
                    else
                    {
                        self.dbTimeEntriesArray=[NSMutableArray arrayWithArray:[approvalModel getPreviousTimeEntriesForSheetFromDB:timesheetURI]];
                    }
                    
                    
                }
            }

            
        }
        
        
        
    }
    
    [self loadViewWhenDataReceived];
}

-(void)callServiceWithName:(ServiceName)_serviceName andTimeSheetURI:(NSString *)timeSheetURI
{
    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
    
    if(_serviceName==WIDGET_TIMESHEET_SAVE_SERVICE)
    {
        NSMutableArray *saveTimesheetDataArray = nil;
        NSString *timeSheetFormat=[timesheetModel getTimesheetFormatforTimesheetUri:timesheetURI];
        if (timeSheetFormat!=nil && ![timeSheetFormat isKindOfClass:[NSNull class]])
        {
            if([timeSheetFormat isEqualToString:GEN4_DAILY_WIDGET_TIMESHEET])
            {

                NSMutableArray *dailyWidgetTimeEntriesArr = [self saveDailyWidgetTimeSheetData:self.timesheetDataArray andTimesheetUri:timesheetURI];


                NSMutableArray *enableWidgetsArr=[timesheetModel getAllEnabledWidgetsUriDetailsFromDBForTimesheetUri:timeSheetURI];

                BOOL hasStandardWidget=NO;
                BOOL hasInOutWidget=NO;
                BOOL hasExtInOutWidget=NO;


                id<BSInjector, BSBinder> injector = [InjectorProvider injector];
                TimesheetSyncOperationManager *timesheetSyncOperationManager=[injector getInstance:[TimesheetSyncOperationManager class]];

                for(NSDictionary *widgetUriDict in enableWidgetsArr)
                {

                    if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:STANDARD_WIDGET_URI])
                    {
                        hasStandardWidget=YES;

                    }
                    else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:INOUT_WIDGET_URI])
                    {
                        hasInOutWidget=YES;


                    }
                    else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:EXT_INOUT_WIDGET_URI])
                    {
                        hasExtInOutWidget=YES;


                    }

                }

                if (hasStandardWidget)
                {
                    saveTimesheetDataArray = [timesheetSyncOperationManager createTimesheetDataArray:timesheetURI forTimeSheetFormat:GEN4_STANDARD_TIMESHEET];
                    timeSheetFormat = GEN4_STANDARD_TIMESHEET;
                }
                else if (hasInOutWidget)
                {
                    saveTimesheetDataArray = [timesheetSyncOperationManager createTimesheetDataArray:timesheetURI forTimeSheetFormat:GEN4_INOUT_TIMESHEET];
                    timeSheetFormat = GEN4_INOUT_TIMESHEET;
                }
                else if (hasExtInOutWidget)
                {
                    saveTimesheetDataArray = [timesheetSyncOperationManager createTimesheetDataArray:timesheetURI forTimeSheetFormat:GEN4_EXT_INOUT_TIMESHEET];
                    timeSheetFormat = GEN4_EXT_INOUT_TIMESHEET;
                }

                [self executeRemainingGen4TimesheetSaveActionsforTimesheetUri:timesheetURI andtimesheetFormat:timeSheetFormat andDailyWidgetTimeEntries:dailyWidgetTimeEntriesArr saveTimesheetDataAray:saveTimesheetDataArray];



            }

            else
            {
                NSMutableArray *enableWidgetsArr=[timesheetModel getAllEnabledWidgetsUriDetailsFromDBForTimesheetUri:timeSheetURI];
                NSMutableArray *dailyWidgetTimeEntriesArr = nil;
                for(NSDictionary *widgetUriDict in enableWidgetsArr)
                {

                    if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:DAILY_FIELDS_WIDGET_URI])
                    {
                        id<BSInjector, BSBinder> injector = [InjectorProvider injector];
                        TimesheetSyncOperationManager *timesheetSyncOperationManager=[injector getInstance:[TimesheetSyncOperationManager class]];
                        NSMutableArray *dailyFieldWidgetTimesheetDataArray = [timesheetSyncOperationManager createTimesheetDataArray:timesheetURI forTimeSheetFormat:GEN4_DAILY_WIDGET_TIMESHEET];
                        dailyWidgetTimeEntriesArr = [self saveDailyWidgetTimeSheetData:dailyFieldWidgetTimesheetDataArray andTimesheetUri:timesheetURI];
                        
                        break;
                        
                    }
                }
                [self executeRemainingGen4TimesheetSaveActionsforTimesheetUri:timesheetURI andtimesheetFormat:timeSheetFormat andDailyWidgetTimeEntries:dailyWidgetTimeEntriesArr saveTimesheetDataAray:[NSMutableArray arrayWithArray:self.timesheetDataArray]];
            }
        }

    }
    
    
}

-(void)executeRemainingGen4TimesheetSaveActionsforTimesheetUri:(NSString *)timeSheetURI andtimesheetFormat:(NSString *)timeSheetFormat andDailyWidgetTimeEntries:(NSMutableArray *)dailyWidgetTimeEntries saveTimesheetDataAray:(NSMutableArray *)savetimesheetDataArray
{
    NSMutableArray *hybridEntries=nil;
    TimesheetModel *timesheetModel = [[TimesheetModel alloc]init];
    NSMutableArray *enableWidgetsArr=[timesheetModel getAllEnabledWidgetsUriDetailsFromDBForTimesheetUri:timeSheetURI];
    BOOL isHybridTimesheet=NO;
    BOOL hasStandardWidget=NO;
    BOOL hasInOutWidget=NO;
    BOOL hasExtInOutWidget=NO;
    BOOL hasPunchWidget=NO;

    for(NSDictionary *widgetUriDict in enableWidgetsArr)
    {

        if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:STANDARD_WIDGET_URI])
        {
            hasStandardWidget=YES;

        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:INOUT_WIDGET_URI])
        {
            hasInOutWidget=YES;


        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:EXT_INOUT_WIDGET_URI])
        {
            hasExtInOutWidget=YES;

            
        }
        else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:PUNCH_WIDGET_URI])
        {
            hasPunchWidget=YES;

        }
    }

    if (hasInOutWidget && hasStandardWidget)
    {
        isHybridTimesheet=YES;
    }

    if (hasPunchWidget && hasStandardWidget)
    {
        isHybridTimesheet=YES;
    }


    if (isHybridTimesheet)
    {
        id<BSInjector, BSBinder> injector = [InjectorProvider injector];
        TimesheetSyncOperationManager *timesheetSyncOperationManager=[injector getInstance:[TimesheetSyncOperationManager class]];
        if (timeSheetFormat!=nil && ![timeSheetFormat isKindOfClass:[NSNull class]])
        {
            if([timeSheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
            {
                hybridEntries=[timesheetSyncOperationManager createTimesheetDataArray:self.timesheetURI forTimeSheetFormat:GEN4_INOUT_TIMESHEET];
            }
            if([timeSheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [timeSheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
            {
                hybridEntries=[timesheetSyncOperationManager createTimesheetDataArray:self.timesheetURI forTimeSheetFormat:GEN4_STANDARD_TIMESHEET];
            }
        }

    }



    NSMutableArray *timesheetSyncOperationManagerDataArray=savetimesheetDataArray;

    NSMutableDictionary *queryDict = [[RepliconServiceManager timesheetRequest]constructWidgetTimeSheetTimeEntries:timesheetSyncOperationManagerDataArray andHybridWidgetTimeSheetData:hybridEntries andTimesheetUri:timesheetURI andTimeSheetFormat:timeSheetFormat];

    NSMutableArray *queryDictTimeEntries = queryDict[@"timeEntries"];
    if (!queryDictTimeEntries)
    {
        queryDictTimeEntries=[NSMutableArray array];
    }
    [queryDictTimeEntries addObjectsFromArray:dailyWidgetTimeEntries];
    [queryDict setObject:queryDictTimeEntries forKey:@"timeEntries"];

    AFHTTPRequestOperation *operation = [[RepliconServiceManager timesheetRequest]saveWidgetTimeSheetData:queryDict];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received for URL::::: %@ ",operation.request.URL] forLogLevel:LoggerCocoaLumberjack];

         CLS_LOG(@"Response Received for URL::::: %@ ",operation.request.URL);

        [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received ::::: %@",operation.responseString] forLogLevel:LoggerCocoaLumberjack];

         CLS_LOG(@"Response Received ::::: %@",operation.responseString);

        NSDictionary *errorDict = [responseObject objectForKey:@"error"];
        if (errorDict == nil) {

            dispatch_async(dispatch_get_main_queue(), ^{
                [[RepliconServiceManager timesheetService] handleTimesheetsSummaryFetchData:[NSMutableDictionary dictionaryWithObject:responseObject forKey:@"response"] isFromSave:YES];
                self.hasUserChangedAnyValue=NO;
                self.isTimesheetSaveDone = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_TIMEENTRIES_DB_DATA object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"isDataCache"]];
                if(!self.isTimeOffSave)
                {
                    if (![self.appConfig getTimesheetSaveAndStay])
                    {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                    [self.navigationItem setLeftBarButtonItem:nil animated:NO];
                    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                }
                self.isTimeOffSave = NO;


            });
        }
        else
        {
            // server response error
            self.isTimesheetSaveDone = NO;
            BOOL showExceptionMessage= [[ResponseHandler sharedResponseHandler] checkForExceptions:errorDict serviceURL:[[AppProperties getInstance] getServiceURLFor:@"SaveWidgetTimesheetData"]];
            if (!showExceptionMessage)
            {
                [[ResponseHandler sharedResponseHandler] handleServerResponseError:errorDict serviceURL:[[AppProperties getInstance] getServiceURLFor:@"SaveWidgetTimesheetData"]];
            }
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
        }

    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {

         [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Failed ::::: %@ ",[error description]] forLogLevel:LoggerCocoaLumberjack];

         CLS_LOG(@"Response Failed ::::: %@ ",[error description]);

          [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received ::::: %@",operation.responseString] forLogLevel:LoggerCocoaLumberjack];

        CLS_LOG(@"Response Received ::::: %@ ",operation.responseString);

         NSDictionary *errorDict = [[operation responseObject] objectForKey:@"error"];
         self.isTimesheetSaveDone = NO;

         id errorUserInfoDict=[error userInfo];
         NSString *failedUrl=@"";

         if (errorUserInfoDict!=nil && [errorUserInfoDict isKindOfClass:[NSDictionary class]])
         {
             failedUrl=[errorUserInfoDict objectForKey:@"NSErrorFailingURLStringKey"];
             if (!failedUrl)
             {
                 if ([errorUserInfoDict objectForKey:@"NSErrorFailingURLKey"]!=nil)
                 {
                     failedUrl=[[errorUserInfoDict objectForKey:@"NSErrorFailingURLKey"]absoluteString];
                 }

                 if (!failedUrl)
                 {
                     failedUrl=@"";
                 }

             }
         }

         if (errorDict != nil) {

             // server response error
             BOOL showExceptionMessage= [[ResponseHandler sharedResponseHandler] checkForExceptions:errorDict serviceURL:failedUrl];
             if (!showExceptionMessage)
             {
                 [[ResponseHandler sharedResponseHandler] handleServerResponseError:errorDict serviceURL:failedUrl];
             }
             [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
         }
         else
         {
             NSInteger statusCode=[operation.response statusCode];
             NSString *description=operation.response.description;
             NSDictionary *headerFields = operation.request.allHTTPHeaderFields;
             ApplicateState applicationState = [[headerFields objectForKey:ApplicationStateHeaders]intValue];
             [[ResponseHandler sharedResponseHandler] handleHTTPResponseError:statusCode andDescription:description andError:error applicationState:applicationState];
             [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
         }
     }];
    [operation start];
}

-(NSMutableArray  *)saveDailyWidgetTimeSheetData:(NSMutableArray *)timesheetArray andTimesheetUri:(NSString *)timesheetUri
{

   NSMutableArray *timeEntriesArray=[[RepliconServiceManager timesheetRequest] constructTimeEntriesArrForSavingWidgetTimesheet:timesheetArray andTimeSheetFormat:GEN4_DAILY_WIDGET_TIMESHEET andIsHybridTimesheet:NO];


    return timeEntriesArray;
    
}

-(void)showINProgressAlertView
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:RPLocalizedString(saveInProgressTitle, @"")
                                          message:RPLocalizedString(saveInProgressText, @"")
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:RPLocalizedString(@"OK", @"OK")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"OK action");
                               }];
    [alertController addAction:okAction];


    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)viewDidUnload
{
    self.scrollView = nil;
    self.pageControl = nil;
    self.dayViewController=nil;
    self.multiDayInOutViewController=nil;
    self.rightBarButton=nil;
    self.overlayView=nil;
    self.customPickerView=nil;
}

- (void)dealloc
{
    self.scrollView.delegate = nil;
}

#pragma mark  Timesheet save when TimeOff icon is clicked

-(void)savingTimesheetWhenClickedOnTimeOff
{
    BOOL isGen4timesheet=NO;
    self.isTimeOffSave = YES;
    NSArray *timesheetInfoArray=nil;
    
    if ([self.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [parentDelegate isKindOfClass:[ApprovalsScrollViewController class]] || [self.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]] || [parentDelegate isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)parentDelegate;
        ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            timesheetInfoArray=[approvalsModel getTimeSheetInfoSheetIdentityForPending:timesheetURI];
            
        }
        else
        {
            timesheetInfoArray=[approvalsModel getTimeSheetInfoSheetIdentityForPrevious:timesheetURI];
        }
    }
    else
    {
        TimesheetModel *tsModel=[[TimesheetModel alloc]init];
        timesheetInfoArray=[tsModel getTimeSheetInfoSheetIdentity:timesheetURI];
    }
    
    
    if ([timesheetInfoArray count]>0)
    {
        NSString *tsFormat=[[timesheetInfoArray objectAtIndex:0] objectForKey:@"timesheetFormat"];
        if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
        {
            if ([tsFormat isEqualToString:GEN4_INOUT_TIMESHEET] ||  [tsFormat isEqualToString:GEN4_STANDARD_TIMESHEET] ||  [tsFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
            {
                isGen4timesheet=YES;
            }
        }

    }
    if (!isGen4timesheet)
    {
        NSMutableArray *arrayOfEntries=[NSMutableArray array];
        for (int i=0; i<[timesheetDataArray count]; i++)
        {
            NSMutableArray *entryDataArray=[timesheetDataArray objectAtIndex:i];
            
            for (int k=0; k<[entryDataArray count]; k++)
            {
                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[entryDataArray objectAtIndex:k];
                
                if ([tsEntryObject isTimeoffSickRowPresent])
                {
                    if (isMultiDayInOutTimesheetUser)
                    {
                        if ([tsEntryObject.entryType isEqualToString:Adhoc_Time_OffKey ]) {
                            [arrayOfEntries addObject:[entryDataArray objectAtIndex:k]];
                        }
                    }
                    else
                    {
                        [arrayOfEntries addObject:[entryDataArray objectAtIndex:k]];
                    }
                    
                }
                else
                {
                    
                    if (isMultiDayInOutTimesheetUser)
                    {
                        NSMutableDictionary *dict=[tsEntryObject multiDayInOutEntry];
                        NSString *inTime=[dict objectForKey:@"in_time"];
                        NSString *outTime=[dict objectForKey:@"out_time"];
                        if ((inTime!=nil &&![inTime isEqualToString:@""]) || (outTime!=nil&&![outTime isEqualToString:@""]))
                        {
                            [arrayOfEntries addObject:[entryDataArray objectAtIndex:k]];
                        }
                    }
                    else
                    {
                        [arrayOfEntries addObject:[entryDataArray objectAtIndex:k]];
                    }
                    
                }
                
            }
        }
            if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
            {
                [Util showOfflineAlert];
                return;
                
            }
            
            if ([parentDelegate isKindOfClass:[CurrentTimesheetViewController class]]&&[self.navigationController isKindOfClass:[TimesheetNavigationController class]]&& self.hasUserChangedAnyValue)
            {
                if ([timesheetStatus isEqualToString:NOT_SUBMITTED_STATUS]||[timesheetStatus isEqualToString:REJECTED_STATUS])
                {
                    
                    [[NSNotificationCenter defaultCenter] removeObserver:parentDelegate name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
                    [[NSNotificationCenter defaultCenter] addObserver:parentDelegate selector:@selector(RecievedData) name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
                    //[[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                    
                    CLS_LOG(@"-----Save triggerred when clicked on TimeOff on TimesheetMainPageController-----");
                    BOOL iseXteneded=NO;
                    if (multiDayInOutType==EXTENDED_IN_OUT_TIMESHEET_TYPE) {
                        iseXteneded=YES;
                    }
                    if (self.isAutoSaveInQueue)
                    {
                        self.isExplicitSaveRequested=YES;
                    }
                    else
                    {
                        [[RepliconServiceManager timesheetService]sendRequestToSaveTimesheetDataForTimesheetURI:self.timesheetURI withEntryArray:arrayOfEntries withDelegate:self isMultiInOutTimeSheetUser:self.isMultiDayInOutTimesheetUser isNewAdhocEntryDict:nil isTimesheetSubmit:NO sheetLevelUdfArray:self.sheetLevelUdfArray submitComments:nil isAutoSave:@"NO" isDisclaimerAccepted:self.isDisclaimerRequired rowUri:nil actionMode:0 isExtendedInOutUser:iseXteneded reasonForChange:nil];
                    }
                    
                }
                
            }
            if (!self.isAutoSaveInQueue)
            {
                [self.customPickerView removeFromSuperview];
                customPickerView=nil;
            }
            
        else
        {
            
            if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
            {
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                
                [appDelegate performSelector:@selector(startSyncTimer) withObject:nil];
                return;
                
            }
            self.isExplicitSaveRequested=NO;
            if (([timesheetStatus isEqualToString:NOT_SUBMITTED_STATUS]||[timesheetStatus isEqualToString:REJECTED_STATUS])&& self.hasUserChangedAnyValue) {
                
                CLS_LOG(@"-----Auto save triggered on TimesheetMainPageController-----");
                BOOL iseXteneded=NO;
                if (multiDayInOutType==EXTENDED_IN_OUT_TIMESHEET_TYPE) {
                    iseXteneded=YES;
                }
                self.isAutoSaveInQueue=YES;
                [[RepliconServiceManager timesheetService]sendRequestToSaveTimesheetDataForTimesheetURI:self.timesheetURI withEntryArray:arrayOfEntries withDelegate:self isMultiInOutTimeSheetUser:self.isMultiDayInOutTimesheetUser isNewAdhocEntryDict:nil isTimesheetSubmit:NO sheetLevelUdfArray:self.sheetLevelUdfArray submitComments:nil isAutoSave:@"YES" isDisclaimerAccepted:self.isDisclaimerRequired rowUri:nil actionMode:0 isExtendedInOutUser:iseXteneded reasonForChange:nil];
            }
            
            
            else if (([timesheetStatus isEqualToString:NOT_SUBMITTED_STATUS]||[timesheetStatus isEqualToString:REJECTED_STATUS])&& !self.hasUserChangedAnyValue)
            {
                [self dataReceivedForAutoSave];
            }
            
        }
    }
    else{
        NSString *tsFormat=[[timesheetInfoArray objectAtIndex:0] objectForKey:@"timesheetFormat"];
        if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
        {
            if([tsFormat isEqualToString:GEN4_INOUT_TIMESHEET])
            {
                //No Auto-Save needed here before navigating to timeoff screen. This was causing duplicate entries

                /*TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                [timesheetModel updateTimesheetWithOperationName:TIMESHEET_SAVE_OPERATION andTimesheetURI:self.timesheetURI];
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                if (![timesheetModel isTimesheetContainsInflightSaveOperation:timesheetURI])
                {
                    [[appDelegate.injector getInstance:[BaseSyncOperationManager class]] startSync];
                }
                 */


            }
            else
            {

                if ([NetworkMonitor isNetworkAvailableForListener:self] != NO)
                {
                    NSMutableDictionary *attestationDict=nil;
                    if ([self.navigationController isKindOfClass:[TimesheetNavigationController class]])
                    {
                        TimesheetModel *tsModel=[[TimesheetModel alloc]init];
                        attestationDict=[tsModel getAttestationDetailsFromDBForTimesheetUri:self.timesheetURI];
                        if (attestationDict)
                        {
                            //update the attestation flag here
                            [[RepliconServiceManager timesheetService]sendRequestUpdateTimesheetAttestationStatusForTimesheetURI:self.timesheetURI forAttestationStatusUri:ATTESTATION_STATUS_UNATTESTED];
                        }


                    }


                    [self callServiceWithName:WIDGET_TIMESHEET_SAVE_SERVICE andTimeSheetURI:self.timesheetURI];
                }
                
                else
                {
                    [Util showOfflineAlert];
                    return;
                }
            }
        }

    }
}

-(void)hideKeyBoard
{

    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (self.isMultiDayInOutTimesheetUser)
    {
        if (page==self.pageControl.currentPage)
        {
            if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
            {
                if (self.pageControl.currentPage<self.viewControllers.count)
                {
                    MultiDayInOutViewController *currentTimesheetCtrl=[self.viewControllers objectAtIndex:self.pageControl.currentPage];
                    if ([currentTimesheetCtrl isKindOfClass:[MultiDayInOutViewController class]]) {
                        UITextField *textField = currentTimesheetCtrl.lastUsedTextField;
                        if (textField!=nil &&![textField isKindOfClass:[NSNull class]])
                            [textField resignFirstResponder];
                    }
                }
            }
        }
    }
}

- (NSArray *)getTimesheetInfoArray
{
    NSArray *timesheetInfoArray=nil;
    
    if ([self.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [parentDelegate isKindOfClass:[ApprovalsScrollViewController class]] || [self.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]] || [parentDelegate isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)parentDelegate;
        ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            timesheetInfoArray=[approvalsModel getTimeSheetInfoSheetIdentityForPending:timesheetURI];
            
        }
        else
        {
            timesheetInfoArray=[approvalsModel getTimeSheetInfoSheetIdentityForPrevious:timesheetURI];
        }
    }
    else
    {
        TimesheetModel *tsModel=[[TimesheetModel alloc]init];
        timesheetInfoArray=[tsModel getTimeSheetInfoSheetIdentity:timesheetURI];
    }
    return timesheetInfoArray;
}

- (BOOL)isGen4Timesheet:(NSArray *)timesheetInfoArray{
    BOOL isGen4timesheet = false;
    if ([timesheetInfoArray count]>0)
    {
        NSString *tsFormat=[[timesheetInfoArray objectAtIndex:0] objectForKey:@"timesheetFormat"];
        if (tsFormat!=nil &&![tsFormat isKindOfClass:[NSNull class]])
        {
            if ([tsFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [tsFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET] ||  [tsFormat isEqualToString:GEN4_STANDARD_TIMESHEET] ||  [tsFormat isEqualToString:GEN4_DAILY_WIDGET_TIMESHEET])
            {
                isGen4timesheet=YES;
            }
        }
    }
    return isGen4timesheet;
}

@end
