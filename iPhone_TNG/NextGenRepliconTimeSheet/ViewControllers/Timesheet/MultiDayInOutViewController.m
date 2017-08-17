#import "MultiDayInOutViewController.h"
#import "MultiDayInOutTimeEntryCustomCell.h"
#import "TimesheetEntryObject.h"
#import "TimeEntryViewController.h"
#import "TimesheetMainPageController.h"
#import "ExtendedInOutCell.h"
#import "InOutProjectHeaderView.h"
#import "ApprovalsScrollViewController.h"
#import "LoginModel.h"
#import "SuggestionView.h"
#import "EditEntryViewController.h"
#import "BookedTimeOffEntry.h"
#import "TimeOffObject.h"
#import "TimeOffDetailsViewController.h"
#import "NSString+Double_Float.h"
#import "ApprovalsNavigationController.h"
#import "SupervisorDashboardNavigationController.h"
#import "OEFObject.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "InjectorKeys.h"
#import "ErrorBannerViewParentPresenterHelper.h"



@interface MultiDayInOutViewController()

@property(nonatomic) NSString *timesheetFormat;
@end



@implementation MultiDayInOutViewController
@synthesize multiDayTimeEntryTableView;
@synthesize timesheetEntryObjectArray;
@synthesize lastUsedTextField;
@synthesize lastUsedTextView;
@synthesize currentIndexpath;
@synthesize isTableRowSelected;
@synthesize sickRowIndexPathArray;
@synthesize isTextFieldClicked;
@synthesize toolbar;
@synthesize selectedIndexPath;
@synthesize numberOfInOutRows;
@synthesize numberOfSickRows;
@synthesize customKeyboardVC;
@synthesize formatString;
@synthesize hourString;
@synthesize minsString;
@synthesize timeString;
@synthesize selectedButtonTag;
@synthesize currentSelectedButtonRow;
@synthesize lastButtonTag;
@synthesize firstButtonTag;
@synthesize inTimeTotalString;
@synthesize outTimeTotalString;
@synthesize isUDFieldClicked;
@synthesize previousCrossOutTime;
@synthesize nextCrossIntime;
@synthesize multiDayTimesheetStatus;
@synthesize isInOutBtnClicked;
@synthesize isOverlap;
@synthesize controllerDelegate;
@synthesize selectedDropdownUdfIndex;
@synthesize selectedTextUdfIndex;
@synthesize isOverlapEntryAllowed;
@synthesize timesheetDataArray;
@synthesize multiInOutTimesheetType;
@synthesize extendedHeaderView;
@synthesize gesture;
@synthesize timesheetURI;
@synthesize currentPageDate;
@synthesize suggestionDetailsDBArray;
@synthesize isFromSuggestionViewClickedReload;
@synthesize inoutTsObjectsArray;
@synthesize inOutTimesheetEntry;
@synthesize overlapRow;
@synthesize overlapSection;
@synthesize overlapFromInTime;
@synthesize overlapFromOutTime;
@synthesize sectionBeingEdited;
@synthesize rowBeingEdited;
@synthesize totalLabelHoursLbl;
@synthesize totallabelView;
@synthesize editTextFieldTag;
@synthesize isOverlapOnReverseLogic;
@synthesize isGen4UserTimesheet,isGen4RequestInQueue,isNavigation;
@synthesize currentlyBeingEditedCellIndexpath;
@synthesize approvalsDelegate;
@synthesize parentDelegate;

#define LABEL_WIDTH 280
#define LABEL_WIDTH_FOR_TIMEOFF 250
#define Total_Hours_Footer_Height_42 28
#define Previous_Entries_Label_height 34
#define Done_Toolbar_Height 50
#define CONTENT_IMAGEVIEW_TAG 9999
#define FOOTER_TOTAL_HOURS_LABEL_TAG 3333
#define OVERLAP_ON_EDIT_ALERT_TAG 1234
#define OVERLAP_ON_LOAD_ALERT_TAG 1234567
#pragma mark View lifeCycle Methods


- (void)loadView
{
    [super loadView];
    self.totallabelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), Total_Hours_Footer_Height_42)];
    self.totallabelView.backgroundColor = [Util colorWithHex:@"#eeeeee" alpha:1.0f];
    [self.view addSubview:totallabelView];

    UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 4, SCREEN_WIDTH-90-30, 20)];
    totalLabel.text = [NSString stringWithFormat:@"%@", RPLocalizedString(totalHoursText, totalHoursText)];
    totalLabel.textColor = [UIColor blackColor];
    totalLabel.font = [UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_14];
    [self.totallabelView addSubview:totalLabel];

    self.totalLabelHoursLbl = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-90-10, 4, 90, 20)];
    self.totalLabelHoursLbl.textColor = [UIColor blackColor];
    self.totalLabelHoursLbl.textAlignment = NSTextAlignmentRight;
    self.totalLabelHoursLbl.tag = FOOTER_TOTAL_HOURS_LABEL_TAG;
    self.totalLabelHoursLbl.font = [UIFont fontWithName:RepliconFontFamilySemiBold size:RepliconFontSize_16];
    [self.totallabelView addSubview:self.totalLabelHoursLbl];

    self.multiDayTimeEntryTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, Total_Hours_Footer_Height_42, CGRectGetWidth([[UIScreen mainScreen] bounds]), [self heightForTableView] - Total_Hours_Footer_Height_42 -50.0f)];
    self.multiDayTimeEntryTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.multiDayTimeEntryTableView.dataSource = self;
    self.multiDayTimeEntryTableView.delegate = self;
    [self.view addSubview:self.multiDayTimeEntryTableView];
    [self.multiDayTimeEntryTableView setAccessibilityIdentifier:@"uia_inout_timesheet_entry_table_identifier"];

    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper = [appDelegate.injector getInstance:[ErrorBannerViewParentPresenterHelper class]];
    [errorBannerViewParentPresenterHelper setTableViewInsetWithErrorBannerPresentation:self.multiDayTimeEntryTableView];

    self.sickRowIndexPathArray = [[NSMutableArray alloc] init];

    [self performSelector:@selector(createFooterView) withObject:nil afterDelay:0.0];

    if (multiInOutTimesheetType == EXTENDED_IN_OUT_TIMESHEET_TYPE)
    {
        [self performSelector:@selector(createExtendedInOutArray) withObject:nil afterDelay:0.0];
    }
}

-(void)viewDidLoad{
    [super viewDidLoad];
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
        if([view isKindOfClass:[ResignButton class]]){
            CGRect buttonFrame = view.frame;
            buttonFrame.size.height = keyboardFrame.size.height/4;
            buttonFrame.origin.y = SCREEN_HEIGHT - buttonFrame.size.height;
            [UIView animateWithDuration:0.2f animations:^{
                view.frame = buttonFrame;
            }];
        }
    }
}

- (void)checkGen4ServerPunchIdForAllTimeEntries
{
    self.isGen4UserTimesheet = YES;
}

-(void)createExtendedInOutArray
{
    if (multiInOutTimesheetType==EXTENDED_IN_OUT_TIMESHEET_TYPE)
    {
        NSMutableArray *tsArray=[[NSMutableArray alloc]init];
        self.inoutTsObjectsArray=tsArray;
        UIViewController *controllerViewCtrl=(UIViewController *)controllerDelegate;
        if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
        {
            ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
            TimesheetMainPageController *controllerViewCtrl=(TimesheetMainPageController *)controllerDelegate;
            ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)[controllerViewCtrl parentDelegate];
            if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {

                self.timesheetFormat=[approvalsModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:YES];
            }
            else
            {
                self.timesheetFormat=[approvalsModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:NO];
            }
        }
        else
        {
            TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
            self.timesheetFormat=[timesheetModel getTimesheetFormatforTimesheetUri:timesheetURI];
        }

        if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
        {
            if([self.timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [self.timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET] ||  [self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
            {
              self.isGen4UserTimesheet=YES;
            }

        }

        for (int i=0; i<[self.timesheetEntryObjectArray count]; i++)
        {
            TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:i];
            if (self.isGen4UserTimesheet && [controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
            {
                if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
                {
                    if([self.timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                    {
                        TimesheetMainPageController *timesheetMainPageController=(TimesheetMainPageController *)controllerDelegate;
                        if([tsEntryObject.timeEntryCellOEFArray count]==0)
                        {
                            tsEntryObject.timeEntryCellOEFArray=[timesheetMainPageController constructCellOEFObjectForTimeSheetUri:timesheetURI andtimesheetFormat:self.timesheetFormat andOEFLevel:TIMESHEET_CELL_OEF andTimePunchUri:tsEntryObject.timePunchUri];
                        }
                        
                    }

                }

            }
            BOOL isTimeoffSickRow=[tsEntryObject isTimeoffSickRowPresent];
            if (!isTimeoffSickRow)
            {
                NSUInteger count=[[tsEntryObject timePunchesArray] count];
                NSMutableArray *tsInOutArray=[NSMutableArray array];
                for (int k=0; k<count; k++)
                {
                    InOutTimesheetEntry *tmpObj=[self createInOutTimesheetobjectArrayForMultiInoutObject:tsEntryObject forRow:k];
                    [tsInOutArray addObject:tmpObj];

                }

                [inoutTsObjectsArray addObject:tsInOutArray];
            }
            else
            {
                [inoutTsObjectsArray addObject:[NSNull null]];
            }

        }
    }
}

- (void)createFooterView
{
    int tempNumberOfSickRows = 0;
    int tempNumberOfInOutRows = 0;
    float totalCalculatedHours = 0;

    for (int i = 0; i < [self.timesheetEntryObjectArray count]; i++)
    {
        TimesheetEntryObject *tsEntryObject = (TimesheetEntryObject *) timesheetEntryObjectArray[i];
        BOOL isTimeoffSickRow = [tsEntryObject isTimeoffSickRowPresent];
        if (isTimeoffSickRow)
        {
            tempNumberOfSickRows++;
        }
        else
        {
            NSString *inTimeString = [tsEntryObject multiDayInOutEntry][@"in_time"];
            NSString *outTimeString = [tsEntryObject multiDayInOutEntry][@"out_time"];

            if ([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||
                    [multiDayTimesheetStatus isEqualToString:APPROVED_STATUS] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] ||
                    [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED] ||
                    [multiDayTimesheetStatus isEqualToString:TIMESHEET_CONFLICTED])
            {
                if ((![inTimeString isKindOfClass:[NSNull class]] && inTimeString != nil && ![inTimeString isEqualToString:@""]) || (![outTimeString isKindOfClass:[NSNull class]] && outTimeString != nil && ![outTimeString isEqualToString:@""]))
                {
                    tempNumberOfInOutRows++;
                }
            }
            else
            {
                tempNumberOfInOutRows++;
            }
        }

        if (multiInOutTimesheetType == EXTENDED_IN_OUT_TIMESHEET_TYPE)
        {
            if ([[tsEntryObject entryType] isEqualToString:Time_Off_Key] || [[tsEntryObject entryType] isEqualToString:Adhoc_Time_OffKey])
            {
                float timeEntryHours = [[tsEntryObject timeEntryHoursInDecimalFormatWithOutRoundOff] newFloatValue];
                totalCalculatedHours = totalCalculatedHours + timeEntryHours;
            }
            else
            {
                NSMutableArray *punchesArray = [tsEntryObject timePunchesArray];
                for (int k = 0; k < [punchesArray count]; k++)
                {

                    NSString *time_in = punchesArray[k][@"in_time"];
                    NSString *time_out = punchesArray[k][@"out_time"];
                    if (time_in != nil && ![time_in isKindOfClass:[NSNull class]] && ![time_in isEqualToString:@""] && time_out != nil && ![time_out isKindOfClass:[NSNull class]] && ![time_out isEqualToString:@""])
                    {
                        NSMutableDictionary *inoutDict = punchesArray[k];
                        BOOL isMidCrossOverForEntry = [Util checkIsMidNightCrossOver:inoutDict];
                        BOOL isSplitEntry = [self isSplitEntryWithInTime:tsEntryObject.multiDayInOutEntry];
                        if (isMidCrossOverForEntry && !isSplitEntry)
                        {
                            totalCalculatedHours=totalCalculatedHours+[[Util getNumberOfHoursWithoutRoundingForInTime:@"12:00 am" outTime:time_out]newDoubleValue];
                            time_out = @"12:00 am";
                        }

                        BOOL isDetectEntryMisdnightCrossover=[tsEntryObject.multiDayInOutEntry[@"isMidnightCrossover"]boolValue];
                        NSString *tempTime_out=time_out;
                        if (isDetectEntryMisdnightCrossover || isSplitEntry)
                        {
                            tempTime_out = [self returnSplitEntryOutTimeWithOutTime:time_out];
                        }
                        totalCalculatedHours = totalCalculatedHours + [[Util getNumberOfHoursWithoutRoundingForInTime:time_in
                                                                                                              outTime:tempTime_out] newDoubleValue];

                    }

                }
            }
        }
        else
        {

            if ([[tsEntryObject entryType] isEqualToString:Time_Off_Key] || [[tsEntryObject entryType] isEqualToString:Adhoc_Time_OffKey])
            {
                float timeEntryHours = [[tsEntryObject timeEntryHoursInDecimalFormatWithOutRoundOff] newFloatValue];
                totalCalculatedHours = totalCalculatedHours + timeEntryHours;
            }
            else
            {
                NSString *inTime = [tsEntryObject multiDayInOutEntry][@"in_time"];
                NSString *outTime = [tsEntryObject multiDayInOutEntry][@"out_time"];

                if (inTime != nil && ![inTime isKindOfClass:[NSNull class]] && ![inTime isEqualToString:@""] && outTime != nil && ![outTime isKindOfClass:[NSNull class]] && ![outTime isEqualToString:@""])
                {
                    float timeEntryHours = [[tsEntryObject timeEntryHoursInDecimalFormatWithOutRoundOff] newFloatValue];
                    totalCalculatedHours = totalCalculatedHours + timeEntryHours;
                }
            }

        }
    }

    numberOfInOutRows = tempNumberOfInOutRows;
    numberOfSickRows = tempNumberOfSickRows;
    NSString *totalHoursString = [NSString stringWithFormat:@"%f", totalCalculatedHours];

    [self.totalLabelHoursLbl setText:[Util getRoundedValueFromDecimalPlaces:[totalHoursString newDoubleValue]
                                                          withDecimalPlaces:2]];

    if (multiInOutTimesheetType == EXTENDED_IN_OUT_TIMESHEET_TYPE && [controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetModel *timesheetModel = [[TimesheetModel alloc] init];
        NSArray *timesheetInfoArray = [timesheetModel getTimeSheetInfoSheetIdentity:timesheetURI];
        NSMutableArray *suggestionDetailsArray = [self getUniqueSuggestionsArrayFromObjects];
        if (timesheetInfoArray.count > 0)
        {
            NSString *tsFormat=[[timesheetInfoArray objectAtIndex:0] objectForKey:@"timesheetFormat"];
            if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
            {
                if ([tsFormat isEqualToString:GEN4_INOUT_TIMESHEET] ||  [tsFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                {
                    suggestionDetailsArray = [NSMutableArray array];
                }
                else
                {
                    suggestionDetailsArray = [self getUniqueSuggestionsArrayFromObjects];
                }
            }

        }

        self.suggestionDetailsDBArray = suggestionDetailsArray;

        UIView *totalFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, suggestionDetailsArray.count * 70 + Previous_Entries_Label_height)];
        totalFooterView.backgroundColor = [Util colorWithHex:@"#eeeeee" alpha:1.0f];

        BOOL isEditState = YES;
        if ([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||
                [multiDayTimesheetStatus isEqualToString:APPROVED_STATUS] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] ||
                [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED] ||
                [multiDayTimesheetStatus isEqualToString:TIMESHEET_CONFLICTED])
        {
            isEditState = NO;
        }
        float ySuggestion = 0;
        if (isEditState)
        {
            if (suggestionDetailsArray.count > 0)
            {
                UILabel *previousEntriesSuggestionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width-20, Previous_Entries_Label_height)];
                [previousEntriesSuggestionLabel setText:RPLocalizedString(PREVIOUS_ENTRIES_STRING, @"")];
                [previousEntriesSuggestionLabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_14]];
                [totalFooterView addSubview:previousEntriesSuggestionLabel];
            }

            for (int i = 0; i < [suggestionDetailsArray count]; i++)
            {
                NSMutableDictionary *dataDict = [self getSuggestionHeightDictForObject:suggestionDetailsArray[i]];
                float height = [dataDict[CELL_HEIGHT_KEY] newFloatValue];
                SuggestionView *projectSuggestionView = [[SuggestionView alloc] initWithFrame:CGRectMake(0, ySuggestion + Previous_Entries_Label_height - 2, self.view.frame.size.width, height)
                                                                              andWithDataDict:dataDict
                                                                                suggestionObj:suggestionDetailsArray[i]
                                                                                      withTag:i
                                                                                 withDelegate:self];
                ySuggestion = ySuggestion + height;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(didTapOnSuggestionView:)];
                for (UIGestureRecognizer *recognizer in projectSuggestionView.gestureRecognizers)
                {
                    [projectSuggestionView removeGestureRecognizer:recognizer];
                }
                [projectSuggestionView addGestureRecognizer:tap];


                [totalFooterView addSubview:projectSuggestionView];
            }
        }

        CGRect frame = totalFooterView.frame;
        frame.size.height = ySuggestion + Previous_Entries_Label_height;
        [totalFooterView setFrame:frame];

        if (totalFooterView.subviews.count)
        {
            [self.multiDayTimeEntryTableView setTableFooterView:totalFooterView];
        }
        else
        {
            [self.multiDayTimeEntryTableView setTableFooterView:nil];
        }
    }
    else
    {
        [self.multiDayTimeEntryTableView setTableFooterView:nil];
    }

    self.gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];

    for (UIGestureRecognizer *recognizer in totallabelView.gestureRecognizers)
    {
        [self.multiDayTimeEntryTableView.tableFooterView removeGestureRecognizer:recognizer];
    }

    [self.multiDayTimeEntryTableView.tableFooterView addGestureRecognizer:self.gesture];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (multiInOutTimesheetType!=EXTENDED_IN_OUT_TIMESHEET_TYPE)
    {
        [self removeMultiInOutTimeEntryKeyBoard];
        MultiDayInOutTimeEntryCustomCell *cell = (MultiDayInOutTimeEntryCustomCell *)[self.multiDayTimeEntryTableView cellForRowAtIndexPath:currentIndexpath];
        [cell doneClicked];
        [self doneAction:NO sender:nil];
    }
    [self deregisterKeyboardNotification];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *timesheetMainPageController = (TimesheetMainPageController *)controllerDelegate;
         MultiDayInOutViewController *multiDayInOutViewController=[timesheetMainPageController.viewControllers objectAtIndex:timesheetMainPageController.pageControl.currentPage];
        if (self == multiDayInOutViewController)
        {
            [self.multiDayTimeEntryTableView reloadData];
        }
    }



}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}





#pragma mark - Tableview Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (multiInOutTimesheetType==EXTENDED_IN_OUT_TIMESHEET_TYPE)
    {
        return [timesheetEntryObjectArray count];
    }

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (multiInOutTimesheetType!=EXTENDED_IN_OUT_TIMESHEET_TYPE)
    {

        return numberOfInOutRows+numberOfSickRows;
    }
    else
    {
        TimesheetEntryObject *tsEntryObject=[timesheetEntryObjectArray objectAtIndex:section];

        if ([tsEntryObject isTimeoffSickRowPresent])
        {
            return 1;
        }
        else
        {

            if(tsEntryObject.timePunchesArray==nil)
            {
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
            }

            return [tsEntryObject.timePunchesArray count]+1;
        }

    }
    return numberOfInOutRows+numberOfSickRows;
}

-(NSMutableDictionary *)getHeightDictForIndex:(NSInteger)index
{
    BOOL isProjectAccess=NO;
    BOOL isClientAccess=NO;
    BOOL isActivityAccess=NO;
    BOOL isBillingAccess=NO;
    BOOL isProgramAccess=NO;
    UIViewController *controllerViewCtrl=(UIViewController *)controllerDelegate;


    if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
         ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
        TimesheetMainPageController *controllerViewCtrl=(TimesheetMainPageController *)controllerDelegate;
        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)[controllerViewCtrl parentDelegate];
        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            if ([self.timesheetEntryObjectArray count]>0)
            {
                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:0];
                NSString *sheetIdentity=[tsEntryObject timesheetUri];
                if (sheetIdentity!=nil && ![sheetIdentity isKindOfClass:[NSNull class]])
                {

                    isProjectAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:sheetIdentity];
                    isClientAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetClientAccess" forSheetUri:sheetIdentity];
                    isActivityAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:sheetIdentity];
                    isBillingAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:sheetIdentity];
                    isProgramAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProgramAccess" forSheetUri:sheetIdentity];//MOBI-746

                }

            }
            self.timesheetFormat=[approvalModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:YES];
        }
        else
        {
            if ([self.timesheetEntryObjectArray count]>0)
            {
                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:0];
                NSString *sheetIdentity=[tsEntryObject timesheetUri];
                if (sheetIdentity!=nil && ![sheetIdentity isKindOfClass:[NSNull class]])
                {

                    isProjectAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:sheetIdentity];
                    isClientAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetClientAccess" forSheetUri:sheetIdentity];
                    isActivityAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:sheetIdentity];
                    isBillingAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:sheetIdentity];
                    isProgramAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProgramAccess" forSheetUri:sheetIdentity];//MOBI-746

                }

            }
             self.timesheetFormat=[approvalModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:NO];

        }

    }
    //User context Flow for timesheets
    else if([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {

        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        isProjectAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetURI];
       isClientAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetClientAccess" forSheetUri:timesheetURI];
        isActivityAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetURI];
        isBillingAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:timesheetURI];
        isProgramAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProgramAccess" forSheetUri:timesheetURI];

        self.timesheetFormat=[timesheetModel getTimesheetFormatforTimesheetUri:timesheetURI];

    }

    if (self.isGen4UserTimesheet) {
        SupportDataModel *supportModel=[[SupportDataModel alloc]init];
        NSDictionary *dict=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];

        if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
        {
            if([self.timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
            {
                isProjectAccess=[[dict objectForKey:@"allowProjectsTasksForExtInOutGen4"] boolValue];
                isActivityAccess=[[dict objectForKey:@"allowActivitiesForExtInOutGen4"] boolValue];
                isClientAccess=[[dict objectForKey:@"allowClientsForExtInOutGen4"] boolValue];
                isBillingAccess=[[dict objectForKey:@"allowBillingForExtInOutGen4"] boolValue];
                isProgramAccess=[[dict objectForKey:@"allowProgramsForExtInOutGen4"] boolValue];
            }
        }


    }

    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:index];
    float cellHeight=0.0;
    float verticalOffset=10.0;
    float upperLabelHeight=0.0;
    float middleLabelHeight=0.0;
    float lowerLabelHeight=0.0;
    float billingRateLabelHeight = 0.0;
    NSString *upperStr=@"";
    NSString *middleStr=@"";
    NSString *lowerStr=@"";
    BOOL isUpperLabelTextWrap=NO;
    BOOL isMiddleLabelTextWrap=NO;
    BOOL isLowerLabelTextWrap=NO;
    NSMutableDictionary *heightDict=[NSMutableDictionary dictionary];
    BOOL isTimeoffSickRow=[tsEntryObject isTimeoffSickRowPresent];
    NSString *breakUri=[tsEntryObject breakUri];
    BOOL isBreakPresent=NO;
    if (breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]] && ![breakUri isEqualToString:@""])
    {
        isBreakPresent=YES;
    }
    if (isTimeoffSickRow||isBreakPresent)
    {
        if (isBreakPresent)
        {
            NSString *breakName=[tsEntryObject breakName];
            middleStr=breakName;
            middleLabelHeight=[self getHeightForString:breakName fontSize:RepliconFontSize_16 forWidth:LABEL_WIDTH];
            [heightDict setObject:@"SINGLE" forKey:LINE];
        }
        else
        {
            NSString *timeEntryTimeOffName=[tsEntryObject timeEntryTimeOffName];
            middleStr=timeEntryTimeOffName;
            middleLabelHeight=[self getHeightForString:timeEntryTimeOffName fontSize:RepliconFontSize_16 forWidth:LABEL_WIDTH_FOR_TIMEOFF];
            [heightDict setObject:@"SINGLE" forKey:LINE];

        }

    }
    else
    {

        NSString *timeEntryTaskName=[tsEntryObject timeEntryTaskName];
        NSString *timeEntryClientName=[tsEntryObject timeEntryClientName];
        if (isProgramAccess) {
            timeEntryClientName=[tsEntryObject timeEntryProgramName];//MOBI-746

        }
        NSString *timeEntryProjectName=[tsEntryObject timeEntryProjectName];
        if (timeEntryTaskName==nil || [timeEntryTaskName isKindOfClass:[NSNull class]]||[timeEntryTaskName isEqualToString:@""])
        {

            if (isProjectAccess)
            {

                BOOL isBothClientAndProjectNull=[self checkIfBothProjectAndClientIsNull:timeEntryClientName projectName:timeEntryProjectName];

                if (isBothClientAndProjectNull)
                {

                    //No task client and project.Only third row consiting of activity/udf's or billing

                    NSString *attributeText=[self getTheAttributedTextForEntryObject:tsEntryObject];
                    isMiddleLabelTextWrap=YES;
                    middleStr=attributeText;
                    middleLabelHeight=[self getHeightForString:attributeText fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                    [heightDict setObject:@"SINGLE" forKey:LINE];

                }
                else
                {

                    NSString *attributeText=[self getTheAttributedTextForEntryObject:tsEntryObject];
                    if (attributeText==nil ||[attributeText isKindOfClass:[NSNull class]]||[attributeText isEqualToString:@""])
                    {

                        //No task No activity/udf's or billing Only project/client

                        if (timeEntryClientName==nil || [timeEntryClientName isKindOfClass:[NSNull class]]||[timeEntryClientName isEqualToString:@""]||[timeEntryClientName isEqualToString:NULL_STRING])
                        {
                            middleStr=[NSString stringWithFormat:@"%@",timeEntryProjectName];
                        }
                        else
                        {
                            middleStr=[NSString stringWithFormat:@"%@ for %@",timeEntryProjectName,timeEntryClientName];
                        }
                        middleLabelHeight=[self getHeightForString:middleStr fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                        [heightDict setObject:@"SINGLE" forKey:LINE];

                    }
                    else
                    {
                        //No task project/client and activity/udf's or billing


                        if (timeEntryClientName==nil || [timeEntryClientName isKindOfClass:[NSNull class]]||[timeEntryClientName isEqualToString:@""]||[timeEntryClientName isEqualToString:NULL_STRING])
                        {
                            upperStr=[NSString stringWithFormat:@"%@",timeEntryProjectName];
                        }
                        else
                        {
                            upperStr=[NSString stringWithFormat:@"%@ for %@",timeEntryProjectName,timeEntryClientName];
                        }
                        lowerStr=attributeText;
                        isLowerLabelTextWrap=YES;
                        upperLabelHeight=[self getHeightForString:upperStr fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                        lowerLabelHeight=[self getHeightForString:lowerStr fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                        [heightDict setObject:@"DOUBLE" forKey:LINE];

                    }

                }

            }
            else
            {
                NSString *attributeText=[self getTheAttributedTextForEntryObject:tsEntryObject];
                middleStr=attributeText;
                middleLabelHeight=[self getHeightForString:middleStr fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                [heightDict setObject:@"SINGLE" forKey:LINE];
                isMiddleLabelTextWrap=YES;


            }


        }
        else
        {
            upperStr=timeEntryTaskName;
            NSString *attributeText=[self getTheAttributedTextForEntryObject:tsEntryObject];
            if (attributeText==nil ||[attributeText isKindOfClass:[NSNull class]]||[attributeText isEqualToString:@""])
            {

                if (timeEntryClientName==nil || [timeEntryClientName isKindOfClass:[NSNull class]]||[timeEntryClientName isEqualToString:@""]||[timeEntryClientName isEqualToString:NULL_STRING])
                {
                    lowerStr=[NSString stringWithFormat:@"in %@",timeEntryProjectName];
                }
                else
                {
                    lowerStr=[NSString stringWithFormat:@"in %@ for %@",timeEntryProjectName,timeEntryClientName];
                }
                upperLabelHeight=[self getHeightForString:upperStr fontSize:RepliconFontSize_16 forWidth:LABEL_WIDTH];
                lowerLabelHeight=[self getHeightForString:lowerStr fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                [heightDict setObject:@"DOUBLE" forKey:LINE];


            }
            else
            {



                if (timeEntryClientName==nil || [timeEntryClientName isKindOfClass:[NSNull class]]||[timeEntryClientName isEqualToString:@""]||[timeEntryClientName isEqualToString:NULL_STRING])
                {
                    middleStr=[NSString stringWithFormat:@"in %@",timeEntryProjectName];
                }
                else
                {
                    middleStr=[NSString stringWithFormat:@"in %@ for %@",timeEntryProjectName,timeEntryClientName];
                }
                lowerStr=[self getTheAttributedTextForEntryObject:tsEntryObject];
                upperLabelHeight=[self getHeightForString:upperStr fontSize:RepliconFontSize_16 forWidth:LABEL_WIDTH];
                middleLabelHeight=[self getHeightForString:middleStr fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                lowerLabelHeight=[self getHeightForString:lowerStr fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                [heightDict setObject:@"TRIPLE" forKey:LINE];

            }

        }


    }

    float numberOfLabels=0;
    NSString *line=[heightDict objectForKey:LINE];
    if ([line isEqualToString:@"SINGLE"])
    {
        numberOfLabels=1;
    }
    else if ([line isEqualToString:@"DOUBLE"])
    {
        numberOfLabels=2;
    }
    else if ([line isEqualToString:@"TRIPLE"])
    {
        numberOfLabels=3;
    }

    NSString *tsBillingName=[tsEntryObject timeEntryBillingName];
    NSString *tmpBillingValue=@"";
    if (tsBillingName!=nil && ![tsBillingName isKindOfClass:[NSNull class]]&& ![tsBillingName isEqualToString:@""])
    {
        tmpBillingValue=[NSString stringWithFormat:@"%@: %@",RPLocalizedString(@"Billing Rate", @""),tsBillingName];
    }
    else
    {
        tmpBillingValue=[NSString stringWithFormat:@"%@: %@",RPLocalizedString(@"Billing Rate", @""),NON_BILLABLE];
    }
    if (!isBillingAccess)
    {
        tmpBillingValue=@"";
    }
    
    billingRateLabelHeight = [self getHeightForString:tmpBillingValue fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
    
    cellHeight=upperLabelHeight+middleLabelHeight+lowerLabelHeight+billingRateLabelHeight +2*verticalOffset+numberOfLabels*5;
    if (cellHeight<EachDayTimeEntry_Cell_Row_Height_55)
    {
        cellHeight=EachDayTimeEntry_Cell_Row_Height_55;
    }

    [heightDict setObject:[NSString stringWithFormat:@"%f",upperLabelHeight] forKey:UPPER_LABEL_HEIGHT];
    [heightDict setObject:[NSString stringWithFormat:@"%f",middleLabelHeight] forKey:MIDDLE_LABEL_HEIGHT];
    [heightDict setObject:[NSString stringWithFormat:@"%f",lowerLabelHeight] forKey:LOWER_LABEL_HEIGHT];
    [heightDict setObject:[NSString stringWithFormat:@"%@",upperStr] forKey:UPPER_LABEL_STRING];
    [heightDict setObject:[NSString stringWithFormat:@"%@",middleStr] forKey:MIDDLE_LABEL_STRING];
    [heightDict setObject:[NSString stringWithFormat:@"%@",lowerStr] forKey:LOWER_LABEL_STRING];
    [heightDict setObject:[NSString stringWithFormat:@"%d",isUpperLabelTextWrap] forKey:UPPER_LABEL_TEXT_WRAP];
    [heightDict setObject:[NSString stringWithFormat:@"%d",isMiddleLabelTextWrap] forKey:MIDDLE_LABEL_TEXT_WRAP];
    [heightDict setObject:[NSString stringWithFormat:@"%d",isLowerLabelTextWrap] forKey:LOWER_LABEL_TEXT_WRAP];
    [heightDict setObject:[NSString stringWithFormat:@"%f",cellHeight] forKey:CELL_HEIGHT_KEY];
    [heightDict setObject:[NSString stringWithFormat:@"%f",billingRateLabelHeight] forKey:BILLING_LABEL_HEIGHT];
    [heightDict setObject:tmpBillingValue forKey:BILLING_RATE];
    return heightDict;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimesheetEntryObject *tsEntryObject=nil;
    NSInteger index=0;
    if (multiInOutTimesheetType==EXTENDED_IN_OUT_TIMESHEET_TYPE)
    {
        tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:indexPath.section];
        index=indexPath.section;
    }
    else
    {
        tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:indexPath.row];
        index=indexPath.row;
    }

    UIViewController *controllerViewCtrl=(UIViewController *)controllerDelegate;
    NSArray *timesheetInfoArray=nil;
    if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
        ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
        TimesheetMainPageController *controllerViewCtrl=(TimesheetMainPageController *)controllerDelegate;
        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)[controllerViewCtrl parentDelegate];
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
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        timesheetInfoArray=[timesheetModel getTimeSheetInfoSheetIdentity:timesheetURI];
    }

    if ([timesheetInfoArray count]>0)
    {
        NSString *tsFormat=[[timesheetInfoArray objectAtIndex:0] objectForKey:@"timesheetFormat"];
        if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
        {
             if(([tsFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [tsFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET] ||  [tsFormat isEqualToString:GEN4_STANDARD_TIMESHEET]) && indexPath.row==0 && (tsEntryObject.breakUri==nil || [tsEntryObject.breakUri isKindOfClass:[NSNull class]] || [tsEntryObject.breakUri isEqualToString:@""]) && ![tsEntryObject isTimeoffSickRowPresent])
            {
                if ([tsFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                {
                    if (self.isGen4UserTimesheet) {
                        SupportDataModel *supportModel=[[SupportDataModel alloc]init];
                        NSDictionary *dict=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
                        BOOL isProjectAccess=[[dict objectForKey:@"allowProjectsTasksForExtInOutGen4"] boolValue];
                        BOOL isActivityAccess=[[dict objectForKey:@"allowActivitiesForExtInOutGen4"] boolValue];
//                        BOOL isClientAccess=[[dict objectForKey:@"allowClientsForExtInOutGen4"] boolValue];
//                        BOOL isBillingAccess=[[dict objectForKey:@"allowBillingForExtInOutGen4"] boolValue];
//                        BOOL isProgramAccess=[[dict objectForKey:@"allowProgramsForExtInOutGen4"] boolValue];

                        if (!isProjectAccess && !isActivityAccess)
                        {
                            return 0.0;
                        }

                    }
                }
                else
                {
                    return 0.0;
                }

            }

            BOOL isBreak=NO;
            if (tsEntryObject.breakUri!=nil && ![tsEntryObject.breakUri isKindOfClass:[NSNull class]]&&![tsEntryObject.breakUri isEqualToString:@""])
            {
                isBreak=YES;
            }
            
            if (isBreak && ([tsFormat isEqualToString:GEN4_INOUT_TIMESHEET]  ||  [tsFormat isEqualToString:GEN4_STANDARD_TIMESHEET]) && indexPath.row==[tsEntryObject.timePunchesArray count])
            {
                return EachDayTimeEntry_Cell_Row_Height_44+10;
            }

        }
    }

    if ([tsEntryObject isTimeoffSickRowPresent]||indexPath.row==0)
    {
        NSMutableDictionary *heightDict=[self getHeightDictForIndex:index];
        float height=[[heightDict objectForKey:CELL_HEIGHT_KEY] newFloatValue];
        return height;
    }
    else if (indexPath.row == tsEntryObject.timePunchesArray.count)
    {
        return EachDayTimeEntry_Cell_Row_Height_44 + 10.0f;
    }

    return EachDayTimeEntry_Cell_Row_Height_44;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"TimeSheetCellIdentifier";
    BOOL isProjectAccess=NO;
    BOOL isClientAccess=NO;
    BOOL isActivityAccess=NO;
    BOOL isBillingAccess=NO;
    BOOL isProgramAccess=NO;
    UIViewController *controllerViewCtrl=(UIViewController *)controllerDelegate;

    if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
        TimesheetMainPageController *controllerViewCtrl=(TimesheetMainPageController *)controllerDelegate;
        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)[controllerViewCtrl parentDelegate];
        ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            if ([self.timesheetEntryObjectArray count]>0)
            {
                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:0];
                NSString *sheetIdentity=[tsEntryObject timesheetUri];
                if (sheetIdentity!=nil && ![sheetIdentity isKindOfClass:[NSNull class]])
                {

                    isProjectAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:sheetIdentity];
                    isClientAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetClientAccess" forSheetUri:sheetIdentity];
                    isActivityAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:sheetIdentity];
                    isBillingAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:sheetIdentity];
                    isProgramAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProgramAccess" forSheetUri:sheetIdentity];

                }

            }
            self.timesheetFormat=[approvalModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:YES];
        }
        else
        {
            if ([self.timesheetEntryObjectArray count]>0)
            {
                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:0];
                NSString *sheetIdentity=[tsEntryObject timesheetUri];
                if (sheetIdentity!=nil && ![sheetIdentity isKindOfClass:[NSNull class]])
                {

                    isProjectAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:sheetIdentity];
                    isClientAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetClientAccess" forSheetUri:sheetIdentity];
                    isActivityAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:sheetIdentity];
                    isBillingAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:sheetIdentity];
                    isProgramAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProgramAccess" forSheetUri:sheetIdentity];

                }

            }
            self.timesheetFormat=[approvalModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:NO];

        }



    }
    //User context Flow for timesheets
    else if([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        
        
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        isProjectAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetURI];
        isClientAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetClientAccess" forSheetUri:timesheetURI];
        isActivityAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetURI];
        isBillingAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:timesheetURI];
        isProgramAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProgramAccess" forSheetUri:timesheetURI];

        self.timesheetFormat=[timesheetModel getTimesheetFormatforTimesheetUri:timesheetURI];
    }


    if (self.isGen4UserTimesheet) {
        SupportDataModel *supportModel=[[SupportDataModel alloc]init];
        NSDictionary *dict=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];

        if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
        {
            if([self.timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
            {
                isProjectAccess=[[dict objectForKey:@"allowProjectsTasksForExtInOutGen4"] boolValue];
                isActivityAccess=[[dict objectForKey:@"allowActivitiesForExtInOutGen4"] boolValue];
                isClientAccess=[[dict objectForKey:@"allowClientsForExtInOutGen4"] boolValue];
                isBillingAccess=[[dict objectForKey:@"allowBillingForExtInOutGen4"] boolValue];
                isProgramAccess=[[dict objectForKey:@"allowProgramsForExtInOutGen4"] boolValue];
            }
        }



    }

    if (multiInOutTimesheetType==EXTENDED_IN_OUT_TIMESHEET_TYPE)
    {
        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:indexPath.section];
        if ([[tsEntryObject entryType] isEqualToString:Time_Off_Key]||[[tsEntryObject entryType] isEqualToString:Adhoc_Time_OffKey])
        {
            MultiDayInOutTimeEntryCustomCell *cell = (MultiDayInOutTimeEntryCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil || ![cell isKindOfClass:[MultiDayInOutTimeEntryCustomCell class]])
            {
                cell = [[MultiDayInOutTimeEntryCustomCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }


            for (UIView *view in cell.contentView.subviews)
            {
                [view removeFromSuperview];
            }

            NSString *timeEntryComments=[tsEntryObject timeEntryComments];
            BOOL commentsImageReq=NO;
            if (timeEntryComments!=nil && [timeEntryComments length]!=0&& ![timeEntryComments isEqualToString:@""])
            {
                commentsImageReq=YES;
            }
            NSString *inTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"in_time"];
            NSString *outTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"out_time"];
            BOOL isTimeoffRow=NO;
            BOOL isTimeoffSickRow=[tsEntryObject isTimeoffSickRowPresent];
            NSMutableDictionary *heightDict=[self getHeightDictForIndex:indexPath.section];
            if (isTimeoffSickRow)
            {



                float height=[[heightDict objectForKey:CELL_HEIGHT_KEY] newFloatValue];

                if([tsEntryObject.entryType isEqualToString:Time_Off_Key])
                {
                    isTimeoffRow=YES;
                    CGRect contentViewFrame=cell.contentView.frame;
                    contentViewFrame.size.height=height;
                    contentViewFrame.size.width=tableView.bounds.size.width;
                    UIImageView *contentImageView=[[UIImageView alloc]initWithFrame:contentViewFrame];
                    contentImageView.backgroundColor=[UIColor clearColor];
                    contentImageView.tag=CONTENT_IMAGEVIEW_TAG;
                    [cell.contentView addSubview:contentImageView];
                    [contentImageView setImage:[UIImage imageNamed:@"holiday_background"]];

                }
                else
                {
                    CGRect contentViewFrame=cell.contentView.frame;
                    contentViewFrame.size.height=height;
                    UIImageView *contentImageView=[[UIImageView alloc]initWithFrame:contentViewFrame];
                    contentImageView.backgroundColor=[UIColor clearColor];
                    contentImageView.tag=CONTENT_IMAGEVIEW_TAG;
                    UIImage *backgroundImage = [Util thumbnailImage:ADHOC_TIMEOFF_BACKGROUND_IMAGE];
                    contentImageView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
                    [cell.contentView addSubview:contentImageView];

                }


                NSIndexPath *sickIndexPath=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
                [sickRowIndexPathArray addObject:sickIndexPath];
            }
            else
            {
                isTimeoffRow=NO;
                [cell.contentView setBackgroundColor:[Util colorWithHex:@"#f8f8f8" alpha:1]];

            }

            BOOL isEditState=YES;
            if ([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
                [multiDayTimesheetStatus isEqualToString:APPROVED_STATUS ]||[[tsEntryObject entryType] isEqualToString:Time_Off_Key] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] ||
                [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED] ||
                [multiDayTimesheetStatus isEqualToString:TIMESHEET_CONFLICTED])
            {
                isEditState=NO;
            }
            UIViewController *controllerViewCtrl=(UIViewController *)controllerDelegate;
            if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
            {
                TimesheetMainPageController *controllerViewCtrl=(TimesheetMainPageController *)controllerDelegate;
                ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)[controllerViewCtrl parentDelegate];
                if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                {
                    [cell setApprovalsModuleName:APPROVALS_PENDING_TIMESHEETS_MODULE];
                }
                else
                {
                    [cell setApprovalsModuleName:APPROVALS_PREVIOUS_TIMESHEETS_MODULE];
                }
            }
            [cell setTimesheetUri:timesheetURI];
            [cell createCellLayoutWithParams:isTimeoffSickRow timeOffString:[tsEntryObject timeEntryTimeOffName] upperrightString:[tsEntryObject timeEntryHoursInDecimalFormat] commentsStr:timeEntryComments commentsImageRequired:commentsImageReq  lastUsedTextField:nil udfArray:[tsEntryObject timeEntryUdfArray] tag:indexPath.section startButtonTag:numberOfSickRows+1 inTimeString:inTimeString outTimeString:outTimeString  isTimeoff:isTimeoffRow  withEditState:isEditState withDataDict:heightDict withDelegate:self withTsEntryObject:tsEntryObject];


            if ([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[multiDayTimesheetStatus isEqualToString:APPROVED_STATUS ]||[tsEntryObject.entryType isEqualToString:Time_Off_Key] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] ||
                [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED] ||
                [multiDayTimesheetStatus isEqualToString:TIMESHEET_CONFLICTED])
            {
                cell.upperRight.enabled=NO;
                cell.inTimeButton.enabled=NO;
                cell.outTimeButton.enabled=NO;
                cell.upperRight.backgroundColor=[UIColor clearColor];
            }


            [cell setDelegate:self];
            if (isTimeoffSickRow)
            {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            else
            {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            if ([tsEntryObject.entryType isEqualToString:Time_Off_Key]&&([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[multiDayTimesheetStatus isEqualToString:APPROVED_STATUS ] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_CONFLICTED] ))
            {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            self.firstButtonTag=numberOfSickRows*2;
            self.lastButtonTag=firstButtonTag+numberOfInOutRows*2-1;
            if (isTimeoffSickRow)
            {
                [cell setTag:TIMEOFF_CELL_TAG];
            }
            else
            {
                [cell setTag:INOUT_CELL_TAG];
            }
            return cell;

        }
        else
        {
            if (indexPath.row==0)
            {

                InOutProjectHeaderView *inOutProjectHeaderViewCell = (InOutProjectHeaderView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (inOutProjectHeaderViewCell == nil || ![inOutProjectHeaderViewCell isKindOfClass:[InOutProjectHeaderView class]])
                {
                    inOutProjectHeaderViewCell = [[InOutProjectHeaderView  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                for (UIView *view in inOutProjectHeaderViewCell.contentView.subviews)
                {
                    [view removeFromSuperview];
                }
                NSMutableDictionary *heightDict=[self getHeightDictForIndex:indexPath.section];

                BOOL isBreakPresent=FALSE;
                NSString *breakUri=[tsEntryObject breakUri];
                if (breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]] && ![breakUri isEqualToString:@""])
                {
                    isBreakPresent=YES;
                }

                if (isProjectAccess || isClientAccess || isActivityAccess || isBreakPresent)
                {
                    [inOutProjectHeaderViewCell initialiseViewWithProjectName:tsEntryObject  isProjectAccess:isProjectAccess  isClientAccess:isClientAccess isActivityAccess:isActivityAccess isBillingAccess:isBillingAccess dataDict:heightDict andTag:indexPath.section];
                }


                [inOutProjectHeaderViewCell setDelegate:self];
                BOOL isEditState=YES;
                if ([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
                    [multiDayTimesheetStatus isEqualToString:APPROVED_STATUS ] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] ||
                    [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED] ||
                    [multiDayTimesheetStatus isEqualToString:TIMESHEET_CONFLICTED])
                {
                    isEditState=NO;
                }
                if (!isEditState)
                {
                    inOutProjectHeaderViewCell.addCellsIconBtn.hidden=TRUE;
                    inOutProjectHeaderViewCell.addCellsIconIamgeView.hidden=TRUE;

                }

                return inOutProjectHeaderViewCell;
            }
            else
            {
                ExtendedInOutCell *extendedcell = (ExtendedInOutCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (extendedcell == nil || ![extendedcell isKindOfClass:[ExtendedInOutCell class]])
                {
                    extendedcell = [[ExtendedInOutCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                }
                for (UIView *view in extendedcell.contentView.subviews)
                {
                    [view removeFromSuperview];
                }
                [extendedcell setDelegate:self];
                [extendedcell setCellRow:indexPath.row];
                [extendedcell setCellSection:indexPath.section];
                BOOL isEditState=YES;
                if ([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS]||[multiDayTimesheetStatus isEqualToString:APPROVED_STATUS] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] ||
                    [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED] ||
                    [multiDayTimesheetStatus isEqualToString:TIMESHEET_CONFLICTED])
                {
                    isEditState=NO;
                }
                UIViewController *controllerViewCtrl=(UIViewController *)controllerDelegate;
                NSString *tempapprovalsModuleName=nil;
                if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
                {
                    TimesheetMainPageController *controllerViewCtrl=(TimesheetMainPageController *)controllerDelegate;
                    ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)[controllerViewCtrl parentDelegate];
                    if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                    {
                        tempapprovalsModuleName=APPROVALS_PENDING_TIMESHEETS_MODULE;
                    }
                    else
                    {
                        tempapprovalsModuleName=APPROVALS_PREVIOUS_TIMESHEETS_MODULE;
                    }
                }
                //User context Flow for timesheets
                else if([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
                {
                    tempapprovalsModuleName=nil;
                }
                
                [extendedcell createCellLayoutWithParamsForTimesheetEntryObject:tsEntryObject forInOutTimesheetEntryObj:[[inoutTsObjectsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row-1]  editState:isEditState forRow:indexPath.row-1 approvalsModuleName:tempapprovalsModuleName isGen4Timesheet:self.isGen4UserTimesheet];
                return extendedcell;
            }


        }

    }
    else
    {
        MultiDayInOutTimeEntryCustomCell *cell = (MultiDayInOutTimeEntryCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[MultiDayInOutTimeEntryCustomCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }


        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }

        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:indexPath.row];
        NSString *timeEntryComments=[tsEntryObject timeEntryComments];
        BOOL commentsImageReq=NO;
        if (timeEntryComments!=nil && [timeEntryComments length]!=0&& ![timeEntryComments isEqualToString:@""])
        {
            commentsImageReq=YES;
        }
        NSString *inTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"in_time"];
        NSString *outTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"out_time"];
        BOOL isTimeoffRow=NO;
        BOOL isTimeoffSickRow=[tsEntryObject isTimeoffSickRowPresent];
        NSMutableDictionary *heightDict=[self getHeightDictForIndex:indexPath.row];
        float height=[[heightDict objectForKey:CELL_HEIGHT_KEY] newFloatValue];
        if (isTimeoffSickRow)
        {

            if([tsEntryObject.entryType isEqualToString:Time_Off_Key])
            {
                isTimeoffRow=YES;
                CGRect contentViewFrame=cell.contentView.frame;
                contentViewFrame.size.height=height;
                contentViewFrame.size.width=tableView.bounds.size.width;
                UIImageView *contentImageView=[[UIImageView alloc]initWithFrame:contentViewFrame];
                contentImageView.backgroundColor=[UIColor clearColor];
                contentImageView.tag=CONTENT_IMAGEVIEW_TAG;
                [cell.contentView addSubview:contentImageView];
                [contentImageView setImage:[UIImage imageNamed:@"holiday_background"]];


            }
            else
            {
                CGRect contentViewFrame=cell.contentView.frame;
                contentViewFrame.size.height=height;
                UIImageView *contentImageView=[[UIImageView alloc]initWithFrame:contentViewFrame];
                contentImageView.backgroundColor=[UIColor clearColor];
                contentImageView.tag=CONTENT_IMAGEVIEW_TAG;
                UIImage *backgroundImage = [Util thumbnailImage:ADHOC_TIMEOFF_BACKGROUND_IMAGE];
                contentImageView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
                [cell.contentView addSubview:contentImageView];

            }


            NSIndexPath *sickIndexPath=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
            [sickRowIndexPathArray addObject:sickIndexPath];
        }
        else
        {
            isTimeoffRow=NO;
            [cell.contentView setBackgroundColor:[Util colorWithHex:@"#f8f8f8" alpha:1]];

        }

        BOOL isEditState=YES;
        if ([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
            [multiDayTimesheetStatus isEqualToString:APPROVED_STATUS ] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] ||
            [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED] ||
            [multiDayTimesheetStatus isEqualToString:TIMESHEET_CONFLICTED])
        {
            isEditState=NO;
        }
        UIViewController *controllerViewCtrl=(UIViewController *)controllerDelegate;
        if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
        {
            TimesheetMainPageController *controllerViewCtrl=(TimesheetMainPageController *)controllerDelegate;
            ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)[controllerViewCtrl parentDelegate];
            if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                [cell setApprovalsModuleName:APPROVALS_PENDING_TIMESHEETS_MODULE];
            }
            else
            {
                [cell setApprovalsModuleName:APPROVALS_PREVIOUS_TIMESHEETS_MODULE];
            }
        }
        [cell setTimesheetUri:timesheetURI];

        [cell createCellLayoutWithParams:isTimeoffSickRow timeOffString:[tsEntryObject timeEntryTimeOffName] upperrightString:[tsEntryObject timeEntryHoursInDecimalFormat] commentsStr:timeEntryComments commentsImageRequired:commentsImageReq  lastUsedTextField:nil udfArray:[tsEntryObject timeEntryUdfArray] tag:indexPath.row startButtonTag:numberOfSickRows+1 inTimeString:inTimeString outTimeString:outTimeString  isTimeoff:isTimeoffRow  withEditState:isEditState withDataDict:heightDict withDelegate:self withTsEntryObject:tsEntryObject];


        if ([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[multiDayTimesheetStatus isEqualToString:APPROVED_STATUS ]||[tsEntryObject.entryType isEqualToString:Time_Off_Key] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] ||
            [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED] ||
            [multiDayTimesheetStatus isEqualToString:TIMESHEET_CONFLICTED])
        {
            cell.upperRight.enabled=NO;
            cell.inTimeButton.enabled=NO;
            cell.outTimeButton.enabled=NO;
        }


        [cell setDelegate:self];
        if (isTimeoffSickRow)
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if ([tsEntryObject.entryType isEqualToString:Time_Off_Key]&&([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[multiDayTimesheetStatus isEqualToString:APPROVED_STATUS ] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_CONFLICTED]))
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        self.firstButtonTag=numberOfSickRows*2;
        self.lastButtonTag=firstButtonTag+numberOfInOutRows*2-1;
        if (isTimeoffSickRow)
        {
            [cell setTag:TIMEOFF_CELL_TAG];
        }
        else
        {
            [cell setTag:INOUT_CELL_TAG];
        }

        return cell;

    }

	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
    {
        if(![self.timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET])
        {
            if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
            {
                [Util showOfflineAlert];
                return;
            }
        }

    }
    self.selectedIndexPath = indexPath;
    TimesheetModel *timesheetModel = [[TimesheetModel alloc]init];
    if (![timesheetModel isTimesheetContainsInflightSaveOperation:timesheetURI])
    {

        [self handleTapAndResetDayScroll];
        TimesheetEntryObject *tsEntryObject = [self getSelectedTimesheetEntryObject];
        if ([[tsEntryObject entryType] isEqualToString:Time_Off_Key])
        {

            SupportDataModel *supportDataModel = [[SupportDataModel alloc] init];
            NSMutableArray *userDetailsArr=[supportDataModel getUserDetailsFromDatabase];

            BOOL hasTimeoffBookingAccess=FALSE;

            if (userDetailsArr!=nil && ![userDetailsArr isKindOfClass:[NSNull class]])
            {
                NSDictionary *userDetailsDict=[userDetailsArr objectAtIndex:0];

                hasTimeoffBookingAccess        = [[userDetailsDict objectForKey:@"hasTimeoffBookingAccess"]boolValue];//Implemented as per TOFF-115//
            }

            if (hasTimeoffBookingAccess)
            {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:PULL_TO_REFRESH_TIMEOFFS_RECEIVED_NOTIFICATION object:nil];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeOffDetailsResponseReceived)
                                                             name:PULL_TO_REFRESH_TIMEOFFS_RECEIVED_NOTIFICATION
                                                           object:nil];
                
                if (![NetworkMonitor isNetworkAvailableForListener:self])
                {
                    [Util showOfflineAlert];
                    return;
                }
                AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                [[RepliconServiceManager timesheetService]fetchTimeoffData:nil];
                
                UITextField *textField = self.lastUsedTextField;
                if (textField!=nil &&![textField isKindOfClass:[NSNull class]])
                    [textField resignFirstResponder];
            }
        }
        else{

            if ([tsEntryObject isTimeoffSickRowPresent])
            {
                BOOL isProjectAccess=NO;
                BOOL isClientAccess=NO;
                BOOL isActivityAccess=NO;
                BOOL isBillingAccess=NO;
                UIViewController *controllerViewCtrl=(UIViewController *)controllerDelegate;

                if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
                {
                    ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];;
                    TimesheetMainPageController *controllerViewCtrl=(TimesheetMainPageController *)controllerDelegate;
                    ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)[controllerViewCtrl parentDelegate];
                    if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                    {
                        if ([self.timesheetEntryObjectArray count]>0)
                        {
                            TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:0];
                            NSString *sheetIdentity=[tsEntryObject timesheetUri];
                            if (sheetIdentity!=nil && ![sheetIdentity isKindOfClass:[NSNull class]])
                            {

                                isProjectAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:sheetIdentity];
                                isClientAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetClientAccess" forSheetUri:sheetIdentity];
                                isActivityAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:sheetIdentity];
                                isBillingAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:sheetIdentity];


                            }

                        }
                        self.timesheetFormat=[approvalModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:YES];
                    }
                    else
                    {
                        if ([self.timesheetEntryObjectArray count]>0)
                        {
                            TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:0];
                            NSString *sheetIdentity=[tsEntryObject timesheetUri];
                            if (sheetIdentity!=nil && ![sheetIdentity isKindOfClass:[NSNull class]])
                            {

                                isProjectAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:sheetIdentity];
                                isClientAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetClientAccess" forSheetUri:sheetIdentity];
                                isActivityAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:sheetIdentity];
                                isBillingAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:sheetIdentity];

                            }

                        }
                        self.timesheetFormat=[approvalModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:NO];

                    }



                }
                //User context Flow for timesheets
                else if([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
                {
                    NSString *sheetIdentity=@"";
                    if ([self.timesheetEntryObjectArray count]>0)
                    {
                        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:0];
                        sheetIdentity=[tsEntryObject timesheetUri];
                    }
                    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                    isProjectAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:sheetIdentity];
                    isClientAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetClientAccess" forSheetUri:sheetIdentity];
                    isActivityAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:sheetIdentity];
                    isBillingAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:sheetIdentity];

                    self.timesheetFormat=[timesheetModel getTimesheetFormatforTimesheetUri:timesheetURI];
                }

                if (self.isGen4UserTimesheet) {
                    SupportDataModel *supportModel=[[SupportDataModel alloc]init];
                    NSDictionary *dict=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];

                    if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
                    {
                        if([self.timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                        {
                            isProjectAccess=[[dict objectForKey:@"allowProjectsTasksForExtInOutGen4"] boolValue];
                            isActivityAccess=[[dict objectForKey:@"allowActivitiesForExtInOutGen4"] boolValue];
                            isClientAccess=[[dict objectForKey:@"allowClientsForExtInOutGen4"] boolValue];
                            isBillingAccess=[[dict objectForKey:@"allowBillingForExtInOutGen4"] boolValue];
                            //isProgramAccess=[[dict objectForKey:@"allowProgramsForExtInOutGen4"] boolValue];
                        }
                    }


                }



                if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
                {
                    ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
                    TimesheetMainPageController *controllerViewCtrl=(TimesheetMainPageController *)controllerDelegate;
                    ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)[controllerViewCtrl parentDelegate];
                    if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                    {

                        self.timesheetFormat=[approvalsModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:YES];
                    }
                    else
                    {
                        self.timesheetFormat=[approvalsModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:NO];
                    }
                }
                else
                {
                    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                    self.timesheetFormat=[timesheetModel getTimesheetFormatforTimesheetUri:timesheetURI];
                }
                
                EditEntryViewController *dayEntryEditVC=[[EditEntryViewController alloc]init];
                dayEntryEditVC.sheetApprovalStatus=multiDayTimesheetStatus;
                dayEntryEditVC.tsEntryObject=tsEntryObject;
                dayEntryEditVC.isProjectAccess=isProjectAccess;
                dayEntryEditVC.isActivityAccess=isActivityAccess;
                dayEntryEditVC.isBillingAccess=isBillingAccess;
                dayEntryEditVC.commentsControlDelegate=self;
                dayEntryEditVC.timesheetFormat=self.timesheetFormat;
                BOOL isEditState=YES;
                if ([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
                    [multiDayTimesheetStatus isEqualToString:APPROVED_STATUS ]||[[tsEntryObject entryType] isEqualToString:Time_Off_Key] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_CONFLICTED])
                {
                    isEditState=NO;
                }
                dayEntryEditVC.isRowUdf=FALSE;//Implementation forMobi-181//JUHI
                dayEntryEditVC.isEditState=isEditState;
                dayEntryEditVC.currentPageDate=self.currentPageDate;
                dayEntryEditVC.row=indexPath.row;
                dayEntryEditVC.section=indexPath.section;
                [self.navigationController pushViewController:dayEntryEditVC animated:YES];
                [self.multiDayTimeEntryTableView deselectRowAtIndexPath:indexPath animated:NO];
            }
        }
    }

    else
    {
        [self showINProgressAlertView];
    }



}

-(void)timeOffDetailsResponseReceived{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PULL_TO_REFRESH_TIMEOFFS_RECEIVED_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_ENTRY_RECEIVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeOffLoadDetails) name:TIMEOFF_ENTRY_RECEIVED_NOTIFICATION object:nil];
    TimesheetEntryObject *tsEntryObject = [self getSelectedTimesheetEntryObject];
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
    [[RepliconServiceManager timesheetService]fetchTimeoffEntryDataForBookedTimeoff:tsEntryObject.timeEntryTimeOffRowUri withTimeSheetUri:[tsEntryObject timesheetUri]];
}


-(void)timeOffLoadDetails {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_ENTRY_RECEIVED_NOTIFICATION object:nil];

    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    TimesheetEntryObject *tsEntryObject = [self getSelectedTimesheetEntryObject];
    TimeoffModel *timeoffModel=[[TimeoffModel alloc]init];
    BOOL isMultiDayTimeOff=[timeoffModel isMultiDayTimeOff:tsEntryObject.timeEntryTimeOffRowUri];
    if(isMultiDayTimeOff){
        
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        MultiDayTimeOffViewController *multiDayTimeOffViewController = [appDelegate.injector getInstance:InjectorKeyMultiDayTimeOffViewController];
        [multiDayTimeOffViewController setupWithModelType:TimeOffModelTypeTimeOff screenMode:EDIT_BOOKTIMEOFF navigationFlow:TIMESHEET_PERIOD_NAVIGATION delegate:controllerDelegate timeOffUri:tsEntryObject.timeEntryTimeOffRowUri timeSheetURI:[tsEntryObject timesheetUri] date:nil];
        [self.navigationController pushViewController:multiDayTimeOffViewController animated:YES];
    }
    else{
        
        TimeOffObject *bookedTimeOffObject=[[TimeOffObject alloc] init];
        bookedTimeOffObject.typeName=[tsEntryObject timeEntryTimeOffName];
        bookedTimeOffObject.typeIdentity=[tsEntryObject timeEntryTimeOffUri];
        bookedTimeOffObject.sheetId=[tsEntryObject timeEntryTimeOffRowUri];
        
        BOOL status=NO;
        
        TimeOffDetailsViewController *bookedTimeOffEntryController= [[TimeOffDetailsViewController alloc]initWithEntryDetails:bookedTimeOffObject sheetId:[bookedTimeOffObject sheetId] screenMode:EDIT_BOOKTIMEOFF];
        bookedTimeOffEntryController.isStatusView=status;
        bookedTimeOffEntryController.navigationFlow=TIMESHEET_PERIOD_NAVIGATION;
        [bookedTimeOffEntryController setSheetIdString:[bookedTimeOffObject sheetId]];
        bookedTimeOffEntryController.parentDelegate = self.parentDelegate;
        bookedTimeOffEntryController.approvalDelegate = self.parentDelegate;
        bookedTimeOffEntryController.timeSheetMainDelegate=controllerDelegate;
        bookedTimeOffEntryController.timesheetURI=[tsEntryObject timesheetUri];
        if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
        {
            TimesheetMainPageController *cntrl=(TimesheetMainPageController*)controllerDelegate;
            
            bookedTimeOffEntryController.userUri=cntrl.userUri;
            if ([controllerDelegate hasUserChangedAnyValue])
            {
                [cntrl savingTimesheetWhenClickedOnTimeOff];
            }
        }
        [bookedTimeOffEntryController TimeOffDetailsReceived];
        [self.navigationController pushViewController:bookedTimeOffEntryController animated:YES];
    }

}


#pragma mark - Other Methods

-(void)resetTableSize:(BOOL)isResetTable isTextFieldOrTextViewClicked:(BOOL)isTextViewClicked isUdfClicked:(BOOL)isUdfClicked
{
    CGFloat width = CGRectGetWidth([[UIScreen mainScreen] bounds]);

    if (isResetTable)
    {
        CGRect frame = CGRectMake(0, Total_Hours_Footer_Height_42, width, [self heightForTableView] - Total_Hours_Footer_Height_42 -50.0f);
        if (isTextViewClicked)
        {
            if (isUdfClicked)
            {
                frame.size.height = frame.size.height - 285 - 49;
            }
            else
            {
                frame.size.height = frame.size.height - 285 - Done_Toolbar_Height - 74;
            }
        }
        else
        {
            frame.size.height = frame.size.height - 120;
        }

        self.multiDayTimeEntryTableView.frame = frame;
    }
    else
    {
        self.multiDayTimeEntryTableView.frame = CGRectMake(0, Total_Hours_Footer_Height_42, width, [self heightForTableView] - Total_Hours_Footer_Height_42 -50.0f);
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{

        if (buttonIndex == 0 && [alertView tag]!=OVERLAP_ON_EDIT_ALERT_TAG &&[alertView tag]!=OVERLAP_ON_LOAD_ALERT_TAG)
        {
            TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[self.timesheetEntryObjectArray objectAtIndex:alertView.tag];
            NSString *deleteRowUri=[tsEntryObject rowUri];
            if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
            {
                TimesheetMainPageController *ctrl=(TimesheetMainPageController *)controllerDelegate;
                if (ctrl.pageControl.currentPage<ctrl.timesheetDataArray.count)
                {
                    NSMutableArray *tsEntryObjectsArray=[NSMutableArray arrayWithArray:[ctrl.timesheetDataArray objectAtIndex:ctrl.pageControl.currentPage]];
                    for (int k=0; k<[tsEntryObjectsArray count]; k++)
                    {
                        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[tsEntryObjectsArray objectAtIndex:k];
                        NSString *objUri=[tsEntryObject rowUri];
                        if (objUri==nil||[objUri isKindOfClass:[NSNull class]]||[objUri isEqualToString:NULL_STRING]||[objUri isEqualToString:NULL_OBJECT_STRING])
                        {
                            objUri=@"";
                        }
                        if (deleteRowUri==nil||[deleteRowUri isKindOfClass:[NSNull class]]||[deleteRowUri isEqualToString:NULL_STRING]||[deleteRowUri isEqualToString:NULL_OBJECT_STRING])
                        {
                            deleteRowUri=@"";
                        }
                        if ([objUri isEqualToString:deleteRowUri])
                        {
                            [tsEntryObjectsArray removeObjectAtIndex:k];
                        }

                    }
                    [ctrl.timesheetDataArray replaceObjectAtIndex:ctrl.pageControl.currentPage withObject:tsEntryObjectsArray];
                }


                if ([multiDayTimesheetStatus isEqualToString:NOT_SUBMITTED_STATUS]||[multiDayTimesheetStatus isEqualToString:REJECTED_STATUS])
                {
                    [ctrl setHasUserChangedAnyValue:YES];
                    [ctrl setTimesheetDataArray:ctrl.timesheetDataArray];
                    [ctrl reloadViewWithRefreshedDataAfterSave];
                }


            }

        }


}
-(NSMutableArray *)getArrayOfTimeEntryObjectsFromAllTheEntries
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

                if ([tsEntryObject.entryType isEqualToString:Adhoc_Time_OffKey ])
                {
                    [arrayOfEntries addObject:[entryDataArray objectAtIndex:k]];
                }


            }
            else
            {
                NSMutableDictionary *dict=[tsEntryObject multiDayInOutEntry];
                NSString *inTime=[dict objectForKey:@"in_time"];
                NSString *outTime=[dict objectForKey:@"out_time"];
                if ((inTime!=nil &&![inTime isEqualToString:@""]) || (outTime!=nil&&![outTime isEqualToString:@""]))
                {
                    [arrayOfEntries addObject:[entryDataArray objectAtIndex:k]];
                }


            }

        }
    }

    return arrayOfEntries;

}


-(void)handleButtonClick:(NSIndexPath*)selectedIndex
{
    [self removeMultiInOutTimeEntryKeyBoard];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (toolbar==nil)
    {
        UIToolbar *temptoolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, screenRect.size.height-380, self.view.frame.size.width, Done_Toolbar_Height)];
        self.toolbar=temptoolbar;

    }
    self.toolbar.barStyle = UIBarStyleBlackOpaque;
    [self.toolbar setHidden:NO];

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString(Done,@"") style: UIBarButtonItemStylePlain target: self action: @selector(doneAction: sender:)];
    //Fix for ios7//JUHI
	float version= [[UIDevice currentDevice].systemVersion newFloatValue];

    if (version<7.0)
    {
        [toolbar setTintColor:[UIColor clearColor]];
    }
    else

    {
        doneButton.tintColor=RepliconStandardWhiteColor;
        UIImage *backgroundImage = [Util thumbnailImage:TOOLBAR_IMAGE];
        [toolbar setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
        [toolbar setTintColor:[Util colorWithHex:@"#dddddd" alpha:1]];
        [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    }

    self.toolbar.items = [NSArray arrayWithObject: doneButton];

    [self.view addSubview: self.toolbar];
}
-(void)doneAction:(BOOL)shouldTextColorChangeToWhite sender:(id)sender
{
    [self.toolbar setHidden:YES];
    [self.multiDayTimeEntryTableView setScrollEnabled:YES];
    if (sender!=nil)
    {
        self.isTextFieldClicked=NO;
        self.isUDFieldClicked=NO;
        [self resetTableSize:NO isTextFieldOrTextViewClicked:NO isUdfClicked:NO];
    }

    if (lastUsedTextView)
    {
        [lastUsedTextView resignFirstResponder];
    }
    if (lastUsedTextField)
    {
        [lastUsedTextField resignFirstResponder];
    }
    AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    for (UIView *view in appdelegate.window.subviews)
    {
        if ([view isKindOfClass:[UIDatePicker class]])
        {
            [view removeFromSuperview];
        }
        else if ([view isKindOfClass:[UIToolbar class]])
        {
            [view setHidden:YES];
        }
    }

    if (self.currentIndexpath!=nil && sender!=nil)
    {
        [self.multiDayTimeEntryTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.currentIndexpath] withRowAnimation:UITableViewRowAnimationNone];
    }

}

-(void)updateTimeEntryHoursForIndex:(NSInteger)index withValue:(NSString *)value withoutRoundOffValue:(NSString *)withoutRoundOffValue isDoneClicked:(BOOL)isDoneClicked
{
    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:index];
    NSString *clientName=tsEntryObject.timeEntryClientName;
    NSString *clientUri=tsEntryObject.timeEntryClientUri;
    NSString *projectName=tsEntryObject.timeEntryProjectName;
    NSString *projectUri=tsEntryObject.timeEntryProjectUri;
    NSString *taskName=tsEntryObject.timeEntryTaskName;
    NSString *taskUri=tsEntryObject.timeEntryTaskUri;
    NSString *activityName=tsEntryObject.timeEntryActivityName;
    NSString *activityUri=tsEntryObject.timeEntryActivityUri;
    NSString *timeOffName=tsEntryObject.timeEntryTimeOffName;
    NSString *timeOffUri=tsEntryObject.timeEntryTimeOffUri;
    NSString *billingName=tsEntryObject.timeEntryBillingName;
    NSString *billingUri=tsEntryObject.timeEntryBillingUri;
    NSString *hoursInHourFormat=tsEntryObject.timeEntryHoursInHourFormat;
    //NSString *hoursInDecimalFormat=tsEntryObject.timeEntryHoursInDecimalFormat;
    NSString *comments=tsEntryObject.timeEntryComments;
    NSMutableArray *udfArray=tsEntryObject.timeEntryUdfArray;
    NSMutableDictionary *multiInoutEntry=tsEntryObject.multiDayInOutEntry;
    NSString *punchUri=tsEntryObject.timePunchUri;
    NSString *allocationUri=tsEntryObject.timeAllocationUri;
    NSString *entryType=tsEntryObject.entryType;
    NSDate *entryDate=tsEntryObject.timeEntryDate;
    BOOL isTimeoffSickRowPresent=tsEntryObject.isTimeoffSickRowPresent;
    NSString *timesheetUri=tsEntryObject.timesheetUri;
    NSMutableArray *timePunchesArray=tsEntryObject.timePunchesArray;
    //Implentation for US8956//JUHI
    NSString *breakName=tsEntryObject.breakName;
    NSString *breakUri=tsEntryObject.breakUri;
    NSString *programName=tsEntryObject.timeEntryProgramName;
    NSString *programUri=tsEntryObject.timeEntryProgramUri;
     NSString *rowUri=tsEntryObject.rowUri;

    if (value!=nil && ![value isKindOfClass:[NSNull class]])
    {
        value=[Util getRoundedValueFromDecimalPlaces:[value newDoubleValue] withDecimalPlaces:2];
    }

    if (isDoneClicked)
    {
        if ([value isEqualToString:@""]||[value isKindOfClass:[NSNull class]]) {
            value=[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]];
        }
        if (multiInOutTimesheetType==EXTENDED_IN_OUT_TIMESHEET_TYPE)
        {
            MultiDayInOutTimeEntryCustomCell *cell = (MultiDayInOutTimeEntryCustomCell *)[self.multiDayTimeEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index]];
            [cell.upperRight setText:value];
        }
        else
        {
            MultiDayInOutTimeEntryCustomCell *cell = (MultiDayInOutTimeEntryCustomCell *)[self.multiDayTimeEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            [cell.upperRight setText:value];

        }


    }
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;
        if (![value isEqualToString:[tsEntryObject timeEntryHoursInDecimalFormat]])
        {
            tsMainPageCtrl.hasUserChangedAnyValue=YES;
            [self changeParentViewLeftBarbutton];
        }

    }

    TimesheetEntryObject *tsTempEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:index];
    //MOBI-746
    [tsTempEntryObject setTimeEntryProgramUri:programUri];
    [tsTempEntryObject setTimeEntryProgramName:programName];
    [tsTempEntryObject setTimeEntryClientName:clientName];
    [tsTempEntryObject setTimeEntryClientUri:clientUri];
    [tsTempEntryObject setTimeEntryProjectName:projectName];
    [tsTempEntryObject setTimeEntryProjectUri:projectUri];
    [tsTempEntryObject setTimeEntryTaskName:taskName];
    [tsTempEntryObject setTimeEntryTaskUri:taskUri];
    [tsTempEntryObject setTimeEntryActivityName:activityName];
    [tsTempEntryObject setTimeEntryActivityUri:activityUri];
    [tsTempEntryObject setTimeEntryTimeOffName:timeOffName];
    [tsTempEntryObject setTimeEntryTimeOffUri:timeOffUri];
    [tsTempEntryObject setTimeEntryBillingName:billingName];
    [tsTempEntryObject setTimeEntryBillingUri:billingUri];
    [tsTempEntryObject setTimeEntryHoursInDecimalFormat:[NSString stringWithFormat:@"%@",value]];
    [tsTempEntryObject setTimeEntryHoursInDecimalFormatWithOutRoundOff:[NSString stringWithFormat:@"%@",withoutRoundOffValue]];
    [tsTempEntryObject setTimeEntryHoursInHourFormat:hoursInHourFormat];
    [tsTempEntryObject setTimeEntryComments:comments];
    [tsTempEntryObject setTimeEntryUdfArray:udfArray];
    [tsTempEntryObject setMultiDayInOutEntry:multiInoutEntry];
    [tsTempEntryObject setTimePunchUri:punchUri];
    [tsTempEntryObject setTimeAllocationUri:allocationUri];
    [tsTempEntryObject setEntryType:entryType];
    [tsTempEntryObject setTimeEntryDate:entryDate];
    [tsTempEntryObject setIsTimeoffSickRowPresent:isTimeoffSickRowPresent];
    [tsTempEntryObject setTimesheetUri:timesheetUri];
    [tsTempEntryObject setTimePunchesArray:timePunchesArray];
    //Implentation for US8956//JUHI
    [tsTempEntryObject setBreakName:breakName];
    [tsTempEntryObject setBreakUri:breakUri];
    [tsTempEntryObject setRowUri:rowUri];

    [self.timesheetEntryObjectArray replaceObjectAtIndex:index withObject:tsTempEntryObject];
    [self calculateAndUpdateTotalHoursValueForFooter];

}
-(void)updateTimeEntryCommentsForIndex:(NSInteger)index withValue:(NSString *)value
{
    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:index];
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;
        if (![value isEqualToString:[tsEntryObject timeEntryComments]])
        {
            tsMainPageCtrl.hasUserChangedAnyValue=YES;
            [self changeParentViewLeftBarbutton];
        }

    }
    NSString *clientName=tsEntryObject.timeEntryClientName;
    NSString *clientUri=tsEntryObject.timeEntryClientUri;
    NSString *projectName=tsEntryObject.timeEntryProjectName;
    NSString *projectUri=tsEntryObject.timeEntryProjectUri;
    NSString *taskName=tsEntryObject.timeEntryTaskName;
    NSString *taskUri=tsEntryObject.timeEntryTaskUri;
    NSString *activityName=tsEntryObject.timeEntryActivityName;
    NSString *activityUri=tsEntryObject.timeEntryActivityUri;
    NSString *timeOffName=tsEntryObject.timeEntryTimeOffName;
    NSString *timeOffUri=tsEntryObject.timeEntryTimeOffUri;
    NSString *billingName=tsEntryObject.timeEntryBillingName;
    NSString *billingUri=tsEntryObject.timeEntryBillingUri;
    NSString *hoursInHourFormat=tsEntryObject.timeEntryHoursInHourFormat;
    NSString *hoursInDecimalFormat=tsEntryObject.timeEntryHoursInDecimalFormat;
    NSString *hoursInDecimalFormatWithoutRoundoff=tsEntryObject.timeEntryHoursInDecimalFormatWithOutRoundOff;
    NSMutableArray *udfArray=tsEntryObject.timeEntryUdfArray;
    NSMutableDictionary *multiInoutEntry=tsEntryObject.multiDayInOutEntry;
    NSString *punchUri=tsEntryObject.timePunchUri;
    NSString *allocationUri=tsEntryObject.timeAllocationUri;
    NSDate *entryDate=tsEntryObject.timeEntryDate;
    NSString *entryType=tsEntryObject.entryType;
    BOOL isTimeoffSickRowPresent=tsEntryObject.isTimeoffSickRowPresent;
    NSString *timesheetUri=tsEntryObject.timesheetUri;
    NSMutableArray *timePunchesArray=tsEntryObject.timePunchesArray;
    //Implentation for US8956//JUHI
    NSString *breakName=tsEntryObject.breakName;
    NSString *breakUri=tsEntryObject.breakUri;
    NSString *programName=tsEntryObject.timeEntryProgramName;
    NSString *programUri=tsEntryObject.timeEntryProgramUri;
    NSString *rowUri=tsEntryObject.rowUri;

    TimesheetEntryObject *tsTempEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:index];
    //MOBI-746
    [tsTempEntryObject setTimeEntryProgramUri:programUri];
    [tsTempEntryObject setTimeEntryProgramName:programName];
    [tsTempEntryObject setTimeEntryClientName:clientName];
    [tsTempEntryObject setTimeEntryClientUri:clientUri];
    [tsTempEntryObject setTimeEntryProjectName:projectName];
    [tsTempEntryObject setTimeEntryProjectUri:projectUri];
    [tsTempEntryObject setTimeEntryTaskName:taskName];
    [tsTempEntryObject setTimeEntryTaskUri:taskUri];
    [tsTempEntryObject setTimeEntryActivityName:activityName];
    [tsTempEntryObject setTimeEntryActivityUri:activityUri];
    [tsTempEntryObject setTimeEntryTimeOffName:timeOffName];
    [tsTempEntryObject setTimeEntryTimeOffUri:timeOffUri];
    [tsTempEntryObject setTimeEntryBillingName:billingName];
    [tsTempEntryObject setTimeEntryBillingUri:billingUri];
    [tsTempEntryObject setTimeEntryHoursInDecimalFormat:hoursInDecimalFormat];
    [tsTempEntryObject setTimeEntryHoursInDecimalFormatWithOutRoundOff:hoursInDecimalFormatWithoutRoundoff];
    [tsTempEntryObject setTimeEntryHoursInHourFormat:hoursInHourFormat];
    [tsTempEntryObject setTimeEntryComments:[NSString stringWithFormat:@"%@",value]];
    [tsTempEntryObject setTimeEntryUdfArray:udfArray];
    [tsTempEntryObject setMultiDayInOutEntry:multiInoutEntry];
    [tsTempEntryObject setTimePunchUri:punchUri];
    [tsTempEntryObject setTimeAllocationUri:allocationUri];
    [tsTempEntryObject setEntryType:entryType];
    [tsTempEntryObject setTimeEntryDate:entryDate];
    [tsTempEntryObject setIsTimeoffSickRowPresent:isTimeoffSickRowPresent];
    [tsTempEntryObject setTimesheetUri:timesheetUri];
    [tsTempEntryObject setTimePunchesArray:timePunchesArray];
    //Implentation for US8956//JUHI
    [tsTempEntryObject setBreakName:breakName];
    [tsTempEntryObject setBreakUri:breakUri];
    [tsTempEntryObject setRowUri:rowUri];
    [self.timesheetEntryObjectArray replaceObjectAtIndex:index withObject:tsTempEntryObject];


}
-(void)updateMultiDayTimeEntryForIndex:(NSInteger)index withValue:(NSMutableDictionary *)multiInoutEntry
{
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;
        tsMainPageCtrl.hasUserChangedAnyValue=YES;
        [self changeParentViewLeftBarbutton];
    }
    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:index];
    NSString *clientName=tsEntryObject.timeEntryClientName;
    NSString *clientUri=tsEntryObject.timeEntryClientUri;
    NSString *projectName=tsEntryObject.timeEntryProjectName;
    NSString *projectUri=tsEntryObject.timeEntryProjectUri;
    NSString *taskName=tsEntryObject.timeEntryTaskName;
    NSString *taskUri=tsEntryObject.timeEntryTaskUri;
    NSString *activityName=tsEntryObject.timeEntryActivityName;
    NSString *activityUri=tsEntryObject.timeEntryActivityUri;
    NSString *timeOffName=tsEntryObject.timeEntryTimeOffName;
    NSString *timeOffUri=tsEntryObject.timeEntryTimeOffUri;
    NSString *billingName=tsEntryObject.timeEntryBillingName;
    NSString *billingUri=tsEntryObject.timeEntryBillingUri;
    NSString *hoursInHourFormat=tsEntryObject.timeEntryHoursInHourFormat;
    NSString *hoursInDecimalFormat=tsEntryObject.timeEntryHoursInDecimalFormat;
    NSString *hoursInDecimalFormatWithoutRoundoff=tsEntryObject.timeEntryHoursInDecimalFormatWithOutRoundOff;
    NSString *comments=tsEntryObject.timeEntryComments;
    NSMutableArray *udfArray=tsEntryObject.timeEntryUdfArray;
    NSString *punchUri=tsEntryObject.timePunchUri;
    NSString *allocationUri=tsEntryObject.timeAllocationUri;
    NSString *entryType=tsEntryObject.entryType;
    NSDate *entryDate=tsEntryObject.timeEntryDate;
    BOOL isTimeoffSickRowPresent=tsEntryObject.isTimeoffSickRowPresent;
    NSString *timesheetUri=tsEntryObject.timesheetUri;
    NSMutableArray *timePunchesArray=tsEntryObject.timePunchesArray;
    //Implentation for US8956//JUHI
    NSString *breakName=tsEntryObject.breakName;
    NSString *breakUri=tsEntryObject.breakUri;
    NSString *programName=tsEntryObject.timeEntryProgramName;
    NSString *programUri=tsEntryObject.timeEntryProgramUri;
    NSString *rowUri=tsEntryObject.rowUri;

    TimesheetEntryObject *tsTempEntryObject=[[TimesheetEntryObject alloc] init];
    //MOBI-746
    [tsTempEntryObject setTimeEntryProgramUri:programUri];
    [tsTempEntryObject setTimeEntryProgramName:programName];
    [tsTempEntryObject setTimeEntryClientName:clientName];
    [tsTempEntryObject setTimeEntryClientUri:clientUri];
    [tsTempEntryObject setTimeEntryProjectName:projectName];
    [tsTempEntryObject setTimeEntryProjectUri:projectUri];
    [tsTempEntryObject setTimeEntryTaskName:taskName];
    [tsTempEntryObject setTimeEntryTaskUri:taskUri];
    [tsTempEntryObject setTimeEntryActivityName:activityName];
    [tsTempEntryObject setTimeEntryActivityUri:activityUri];
    [tsTempEntryObject setTimeEntryTimeOffName:timeOffName];
    [tsTempEntryObject setTimeEntryTimeOffUri:timeOffUri];
    [tsTempEntryObject setTimeEntryBillingName:billingName];
    [tsTempEntryObject setTimeEntryBillingUri:billingUri];
    [tsTempEntryObject setTimeEntryHoursInDecimalFormat:hoursInDecimalFormat];
    [tsTempEntryObject setTimeEntryHoursInDecimalFormatWithOutRoundOff:hoursInDecimalFormatWithoutRoundoff];
    [tsTempEntryObject setTimeEntryHoursInHourFormat:hoursInHourFormat];
    [tsTempEntryObject setTimeEntryComments:comments];
    [tsTempEntryObject setTimeEntryUdfArray:udfArray];
    [tsTempEntryObject setMultiDayInOutEntry:multiInoutEntry];
    [tsTempEntryObject setTimePunchUri:punchUri];
    [tsTempEntryObject setTimeAllocationUri:allocationUri];
    [tsTempEntryObject setTimeEntryDate:entryDate];
    [tsTempEntryObject setIsTimeoffSickRowPresent:isTimeoffSickRowPresent];
    [tsTempEntryObject setEntryType:entryType];
    [tsTempEntryObject setTimesheetUri:timesheetUri];
    [tsTempEntryObject setTimePunchesArray:timePunchesArray];
    //Implentation for US8956//JUHI
    [tsTempEntryObject setBreakName:breakName];
    [tsTempEntryObject setBreakUri:breakUri];
    [tsTempEntryObject setRowUri:rowUri];
    [self.timesheetEntryObjectArray replaceObjectAtIndex:index withObject:tsTempEntryObject];


    NSString *inTime=[multiInoutEntry objectForKey:@"in_time"];
    NSString *outTime=[multiInoutEntry objectForKey:@"out_time"];
    NSString *totalHours=[Util getNumberOfHoursForInTime:inTime outTime:outTime];
    NSString *totalHoursWithOutRounding=[Util getNumberOfHoursWithoutRoundingForInTime:inTime outTime:outTime];

    if (inTime!=nil && ![inTime isKindOfClass:[NSNull class]] && ![inTime isEqualToString:@""] &&outTime!=nil && ![outTime isKindOfClass:[NSNull class]]&& ![outTime isEqualToString:@""])
    {
        [self updateTimeEntryHoursForIndex:index withValue:totalHours withoutRoundOffValue:totalHoursWithOutRounding isDoneClicked:NO];
        [self updateMultiInOutTotalTimeEntryCellForIndex:index withValue:totalHours];
    }
    else
    {
        [self updateTimeEntryHoursForIndex:index withValue:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]] withoutRoundOffValue:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]] isDoneClicked:NO];
        [self updateMultiInOutTotalTimeEntryCellForIndex:index withValue:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]];
    }


}

-(void)updateMultiInOutTotalTimeEntryCellForIndex:(NSInteger)index withValue:(NSString *)value
{
    MultiDayInOutTimeEntryCustomCell *cell = (MultiDayInOutTimeEntryCustomCell *)[self.multiDayTimeEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [cell.upperRightInOutLabel setText:value];
    [self calculateAndUpdateTotalHoursValueForFooter];
}

-(void)addTimeEntryRowAction
{
    //Ullas changes,.To remove if not required
    //start

    self.isOverlap=NO;

    [self doneButtonPressed];

    //BUTTON NOT SELECTED
    if (selectedButtonTag!=-1)
    {
        if (isOverlap)
        {
            return;
        }
        else
        {
            if (!self.isOverlapEntryAllowed) {
                [self checkOverlapForPage];
                if (isOverlap)
                {
                    return;

                }
            }
        }
    }
    //BUTTON  SELECTED
    else
    {
        if (!self.isOverlapEntryAllowed) {
            [self checkOverlapForPage];
        }
        if (isOverlap)
        {
            return;

        }
    }
    //end


    if (isTextFieldClicked||isUDFieldClicked||customKeyboardVC!=nil)
    {
        [self resetTableSize:YES  isTextFieldOrTextViewClicked:isTextFieldClicked isUdfClicked:isUDFieldClicked];

    }
    else
    {
        [self resetTableSize:NO  isTextFieldOrTextViewClicked:NO isUdfClicked:NO];
    }
    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:0];

    TimesheetEntryObject *tsTempEntryObject=[[TimesheetEntryObject alloc] init];
    //MOBI-746
    [tsTempEntryObject setTimeEntryProgramUri:@""];
    [tsTempEntryObject setTimeEntryProgramName:@""];
    [tsTempEntryObject setTimeEntryClientName:@""];
    [tsTempEntryObject setTimeEntryClientUri:@""];
    [tsTempEntryObject setTimeEntryProjectName:@""];
    [tsTempEntryObject setTimeEntryProjectUri:@""];
    [tsTempEntryObject setTimeEntryTaskName:@""];
    [tsTempEntryObject setTimeEntryTaskUri:@""];
    [tsTempEntryObject setTimeEntryActivityName:@""];
    [tsTempEntryObject setTimeEntryActivityUri:@""];
    [tsTempEntryObject setTimeEntryTimeOffName:@""];
    [tsTempEntryObject setTimeEntryTimeOffUri:@""];
    [tsTempEntryObject setTimeEntryBillingName:@""];
    [tsTempEntryObject setTimeEntryBillingUri:@""];
    [tsTempEntryObject setTimeEntryHoursInDecimalFormat:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]];
    [tsTempEntryObject setTimeEntryHoursInDecimalFormatWithOutRoundOff:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]];
    [tsTempEntryObject setTimeEntryHoursInHourFormat:@""];
    [tsTempEntryObject setTimeEntryComments:@""];
    [tsTempEntryObject setTimeEntryUdfArray:nil];

    //Implentation for US8956//JUHI
    [tsTempEntryObject setBreakName:@""];
    [tsTempEntryObject setBreakUri:@""];
    NSMutableDictionary *multiDayInOutEntry=[NSMutableDictionary dictionary];
    [multiDayInOutEntry setObject:@"" forKey:@"in_time"];
    [multiDayInOutEntry setObject:@"" forKey:@"out_time"];
    [tsTempEntryObject setMultiDayInOutEntry:multiDayInOutEntry];
    [tsTempEntryObject setTimePunchUri:@""];
    [tsTempEntryObject setTimeAllocationUri:@""];
    [tsTempEntryObject setTimeEntryDate:[tsEntryObject timeEntryDate]];
    [tsTempEntryObject setEntryType:Time_Entry_Key];
    [tsTempEntryObject setIsTimeoffSickRowPresent:NO];
    [self.timesheetEntryObjectArray addObject:tsTempEntryObject];


    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:numberOfInOutRows+numberOfSickRows inSection:0];
    [self.multiDayTimeEntryTableView beginUpdates];
    [self.multiDayTimeEntryTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    self.numberOfInOutRows=numberOfInOutRows+1;
    [self.multiDayTimeEntryTableView endUpdates];

    if (lastButtonTag==selectedButtonTag)
    {
        [customKeyboardVC enableAndDisablePreviousButton:YES andNextButton:NO];
    }
    else if (firstButtonTag==selectedButtonTag)
    {
        [customKeyboardVC enableAndDisablePreviousButton:NO andNextButton:YES];
    }
    else
    {
        [customKeyboardVC enableAndDisablePreviousButton:YES andNextButton:YES];
    }


}
-(void)deleteTimeEntryRowAction:(int)row
{
    [timesheetEntryObjectArray removeObjectAtIndex:row];
    if (isTextFieldClicked||isUDFieldClicked||customKeyboardVC!=nil)
    {
        [self resetTableSize:YES  isTextFieldOrTextViewClicked:isTextFieldClicked isUdfClicked:isUDFieldClicked];

    }
    else
    {
        [self resetTableSize:NO  isTextFieldOrTextViewClicked:NO isUdfClicked:NO];
    }


    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:row inSection:0];
    [self.multiDayTimeEntryTableView beginUpdates];
    [self.multiDayTimeEntryTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    self.numberOfInOutRows=numberOfInOutRows-1;
    [self.multiDayTimeEntryTableView endUpdates];
}
-(void)calculateAndUpdateTotalHoursValueForFooter
{
    float totalCalculatedHours=0;
    for (int i=0; i<[self.timesheetEntryObjectArray count]; i++)
    {
        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:i];
        if (multiInOutTimesheetType==EXTENDED_IN_OUT_TIMESHEET_TYPE)
        {
            if ([[tsEntryObject entryType] isEqualToString:Time_Off_Key]||[[tsEntryObject entryType] isEqualToString:Adhoc_Time_OffKey])
            {
                float timeEntryHours=[[tsEntryObject timeEntryHoursInDecimalFormatWithOutRoundOff] newFloatValue];
                totalCalculatedHours=totalCalculatedHours+timeEntryHours;
            }
            else
            {
                NSMutableArray *punchesArray=[tsEntryObject timePunchesArray];
                for (int k=0; k<[punchesArray count]; k++)
                {

                    NSString *time_in=[[punchesArray objectAtIndex:k] objectForKey:@"in_time"];
                    NSString *time_out=[[punchesArray objectAtIndex:k] objectForKey:@"out_time"];
                    if (time_in!=nil && ![time_in isKindOfClass:[NSNull class]] &&![time_in isEqualToString:@""] && time_out!=nil && ![time_out isKindOfClass:[NSNull class]]&&![time_out isEqualToString:@""])
                    {
                        NSMutableDictionary *inoutDict=[punchesArray objectAtIndex:k];
                        BOOL isMidCrossOverForEntry=[Util checkIsMidNightCrossOver:inoutDict];
                        BOOL isSplitEntry = [self isSplitEntryWithInTime:tsEntryObject.multiDayInOutEntry];
                        
                        if (isMidCrossOverForEntry && !isSplitEntry)
                        {
                            totalCalculatedHours=totalCalculatedHours+[[Util getNumberOfHoursWithoutRoundingForInTime:time_in outTime:@"12:00 am"]newDoubleValue];
                            time_in=@"12:00 am";
                        }

                        BOOL isDetectEntryMisdnightCrossover=[tsEntryObject.multiDayInOutEntry[@"isMidnightCrossover"]boolValue];
                        NSString *tempTime_out=time_out;
                        if (isDetectEntryMisdnightCrossover || isSplitEntry)
                        {
                            tempTime_out = [self returnSplitEntryOutTimeWithOutTime:time_out];
                        }
                        totalCalculatedHours=totalCalculatedHours+[[Util getNumberOfHoursWithoutRoundingForInTime:time_in outTime:tempTime_out]newDoubleValue];
                    }
                }
            }
        }
        else
        {

            if ([[tsEntryObject entryType] isEqualToString:Time_Off_Key]||[[tsEntryObject entryType] isEqualToString:Adhoc_Time_OffKey])
            {
                float timeEntryHours=[[tsEntryObject timeEntryHoursInDecimalFormatWithOutRoundOff] newFloatValue];
                totalCalculatedHours=totalCalculatedHours+timeEntryHours;
            }
            else
            {
                NSString *inTime=[[tsEntryObject multiDayInOutEntry] objectForKey:@"in_time"];
                NSString *outTime=[[tsEntryObject multiDayInOutEntry] objectForKey:@"out_time"];


                if (inTime!=nil && ![inTime isKindOfClass:[NSNull class]] && ![inTime isEqualToString:@""]&&outTime!=nil && ![outTime isKindOfClass:[NSNull class]] && ![outTime isEqualToString:@""])
                {
                    float timeEntryHours=[[tsEntryObject timeEntryHoursInDecimalFormatWithOutRoundOff] newFloatValue];
                    totalCalculatedHours=totalCalculatedHours+timeEntryHours;
                }
            }
        }
    }

    NSString *totalHoursString=[NSString stringWithFormat:@"%f",totalCalculatedHours];

    [self.totalLabelHoursLbl setText:[Util getRoundedValueFromDecimalPlaces:[totalHoursString newDoubleValue]withDecimalPlaces:2]];


	if (multiInOutTimesheetType==EXTENDED_IN_OUT_TIMESHEET_TYPE && [controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        UIView *totalFooterView=[[UIView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width ,[suggestionDetailsDBArray count]*70+Previous_Entries_Label_height)];
        totalFooterView.backgroundColor = [Util colorWithHex:@"#eeeeee" alpha:1.0f];

        BOOL isEditState=YES;
        if ([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
            [multiDayTimesheetStatus isEqualToString:APPROVED_STATUS ] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] ||
            [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED] ||
            [multiDayTimesheetStatus isEqualToString:TIMESHEET_CONFLICTED])
        {
            isEditState=NO;
        }
        if (isEditState)
        {
            if ([suggestionDetailsDBArray count]>0)
            {
                UILabel *previousEntriesSuggestionLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 0,self.view.frame.size.width - 20,Previous_Entries_Label_height)];
                [previousEntriesSuggestionLabel setText:RPLocalizedString(PREVIOUS_ENTRIES_STRING, @"")];
                [previousEntriesSuggestionLabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_14]];
                [totalFooterView addSubview:previousEntriesSuggestionLabel];
            }
        }

        for (UIView *tmpView in self.multiDayTimeEntryTableView.tableFooterView.subviews)
        {
            if ([tmpView isKindOfClass:[SuggestionView class]])
            {
                [totalFooterView addSubview:tmpView];
            }
        }
        [self.multiDayTimeEntryTableView setTableFooterView:totalFooterView];




    }
    else
    {
        [self.multiDayTimeEntryTableView setTableFooterView:nil];

    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    for (UIGestureRecognizer *recognizer in totallabelView.gestureRecognizers)
    {
        [totallabelView removeGestureRecognizer:recognizer];
    }
    [totallabelView addGestureRecognizer:tap];


    BOOL hoursPresent=NO;
    if ([totalHoursString newFloatValue]>0.0f)
    {
        hoursPresent=YES;
    }
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;
        [tsMainPageCtrl checkAndupdateCurrentButtonFilledStatus:hoursPresent andPageSelected:tsMainPageCtrl.pageControl.currentPage];
    }
    if (isGen4UserTimesheet)
    {
        if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
        {
            if(![self.timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
            {
                [self.multiDayTimeEntryTableView setTableFooterView:nil];
            }
        }


    }

}


- (BOOL)isSplitEntryWithInTime:(NSMutableDictionary*)multiDayInOutDict
{
    BOOL isMidNightCrossOverEntry =  false;
    NSDictionary *multiDayInOutDictionary = multiDayInOutDict;
    NSString *outTimeEntry = multiDayInOutDict[@"out_time"];
    if (multiDayInOutDictionary[@"isMidnightCrossover"]!= nil && ![multiDayInOutDictionary[@"isMidnightCrossover"] isKindOfClass:[NSNull class]]) {
        isMidNightCrossOverEntry = multiDayInOutDictionary[@"isMidnightCrossover"];
    }
    
    BOOL isLocalEntryWithSeconds = ([outTimeEntry isEqualToString:@"11:59:59 pm"] || [outTimeEntry isEqualToString:@"11:59:59 PM"]);
    
    BOOL isServerEntryWithMidNightCross = (([outTimeEntry isEqualToString:@"11:59 pm"] || [outTimeEntry isEqualToString:@"11:59 PM"]) && isMidNightCrossOverEntry);
    
    if (isLocalEntryWithSeconds || isServerEntryWithMidNightCross)
        return YES;
    
    return NO;
}

-(BOOL)isInOutWidgetTimesheet
{
    BOOL isExtInOutWidgetProjectAccess = NO;
    BOOL isExtInOutWidgetActivityAccess= NO;
    BOOL isSimpleInOutGen4Timesheet = YES;
    
    if (self.isGen4UserTimesheet) {
        SupportDataModel *supportModel=[[SupportDataModel alloc]init];
        NSDictionary *dict=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
        if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
        {
            if([self.timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
            {
                isExtInOutWidgetProjectAccess=[[dict objectForKey:@"allowProjectsTasksForExtInOutGen4"] boolValue];
                isExtInOutWidgetActivityAccess=[[dict objectForKey:@"allowActivitiesForExtInOutGen4"] boolValue];
            }
        }
        if (isExtInOutWidgetProjectAccess || isExtInOutWidgetActivityAccess)
            isSimpleInOutGen4Timesheet=NO;
    }
    return isSimpleInOutGen4Timesheet;
}

-(NSString*)returnSplitEntryOutTimeWithOutTime:(NSString*)outTime
{
    NSString *tempTime_out=outTime;
    if ([tempTime_out isEqualToString:@"11:59 pm"])
        tempTime_out=@"12:00 am";
    else if ([tempTime_out isEqualToString:@"11:59:59 pm"])
        tempTime_out=@"12:00:00 am";
    return tempTime_out;
}

#pragma mark - Custom KeyBoard Methods

-(BOOL)launchMultiInOutTimeEntryKeyBoard:(id)sender withRowClicked:(NSUInteger)row
{
    [self handleTapAndResetDayScroll];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:currentSelectedButtonRow inSection:0];
    MultiDayInOutTimeEntryCustomCell *selectedCell = (MultiDayInOutTimeEntryCustomCell *)[self. multiDayTimeEntryTableView cellForRowAtIndexPath:indexPath];

    if ([selectedCell tag]==INOUT_CELL_TAG)
    {
        for (UIView *view in selectedCell.contentView.subviews)
        {
            if ([view isKindOfClass:[UIButton class]])
            {
                UIButton *btn=(UIButton *)view;
                if ([btn tag]==selectedButtonTag)
                {
                    NSString *btnTitle=btn.titleLabel.text;
                    if (![btnTitle isEqualToString:RPLocalizedString(In_Time, In_Time)]&& ![btnTitle isEqualToString:RPLocalizedString(Out_Time, Out_Time)])
                    {
                        NSRange replaceRangeMM = [btnTitle rangeOfString:@"mm"];
                        NSRange replaceRangeHH = [btnTitle rangeOfString:@"hh"];
                        if ((replaceRangeMM.location != NSNotFound||replaceRangeHH.location != NSNotFound) && btnTitle!=nil)
                        {
                            //Ullas removed for multi inout changes.To revert back if required
                            /*[Util errorAlert:RPLocalizedString(Please_enter_valid_time_Message, @"") errorMessage:@""];
                             [btn setBackgroundImage:[Util thumbnailImage:IN_OUT_BUTTON_ON_IMAGE] forState:UIControlStateNormal];
                             selectedButtonTag=[btn tag];
                             return NO;*/

                            //Ullas added for multi inout changes.To revert back if required
                            //start
                            NSString *tempHrsStr=@"";
                            NSString *tempMinsStr=@"";
                            NSString *tempFormatStr=@"";
                            NSArray *timeCompsArr=[btnTitle componentsSeparatedByString:@":"];
                            if ([timeCompsArr count]==2)
                            {
                                tempHrsStr=[NSString stringWithFormat:@"%@",[timeCompsArr objectAtIndex:0]];

                                NSArray *amPmCompsArr=[[timeCompsArr objectAtIndex:1] componentsSeparatedByString:@" "];
                                if ([amPmCompsArr count]==2)
                                {
                                    tempMinsStr=[NSString stringWithFormat:@"%@",[amPmCompsArr objectAtIndex:0]];
                                    tempFormatStr=[NSString stringWithFormat:@"%@",[amPmCompsArr objectAtIndex:1]];

                                }
                            }

                            if (replaceRangeMM.location != NSNotFound)
                            {
                                tempMinsStr=@"00";
                            }
                            if (replaceRangeHH.location != NSNotFound)
                            {
                                tempHrsStr=@"12";
                                tempFormatStr=@"am";
                            }
                            self.timeString=[NSString stringWithFormat:@"%@:%@ %@",tempHrsStr,tempMinsStr,tempFormatStr];
                            [btn setTitle:[NSString stringWithFormat:@"%@",self.timeString] forState:UIControlStateNormal];

                            TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:currentSelectedButtonRow];
                            NSString *inTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"in_time"];
                            NSString *outTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"out_time"];

                            if ([inTimeString isEqualToString:self.timeString]&&[outTimeString isEqualToString:self.timeString])
                            {

                            }
                            else
                            {
                                NSMutableDictionary *entryDict=[tsEntryObject multiDayInOutEntry];
                                if ([btn tag]%2==0)
                                {

                                    if ([inTimeString isEqualToString:self.inTimeTotalString])
                                    {
                                        [entryDict setObject:inTimeString forKey:@"in_time"];
                                    }
                                    else if (![inTimeString isEqualToString:self.timeString]&&[inTimeString isEqualToString:@""])
                                    {
                                        [entryDict setObject:self.timeString forKey:@"in_time"];
                                    }
                                    else if (![inTimeString isEqualToString:self.timeString])
                                    {
                                        [entryDict setObject:self.timeString forKey:@"in_time"];
                                    }
                                }
                                else
                                {

                                    if ([outTimeString isEqualToString:self.outTimeTotalString])
                                    {
                                        [entryDict setObject:outTimeString forKey:@"out_time"];
                                    }
                                    else if (![outTimeString isEqualToString:self.timeString]&&[outTimeString isEqualToString:@""])
                                    {
                                        [entryDict setObject:self.timeString forKey:@"out_time"];
                                    }

                                    else if (![outTimeString isEqualToString:self.timeString])
                                    {
                                        [entryDict setObject:self.timeString forKey:@"out_time"];
                                    }

                                }

                                [self updateMultiDayTimeEntryForIndex:currentSelectedButtonRow withValue:entryDict];
                                if (!self.isOverlapEntryAllowed) {

                                    [self checkOverlapForCurrentInTime];

                                }
                                if (isOverlap)
                                {
                                    [btn setBackgroundImage:[Util thumbnailImage:IN_OUT_BUTTON_ON_IMAGE] forState:UIControlStateNormal];
                                    selectedButtonTag=[btn tag];
                                    return NO;
                                }


                            }

                            //end


                        }
                        else{
                            //Implemented For overlappingTimeEntriesPermitted Permission

                            if (!self.isOverlapEntryAllowed) {

                                [self checkOverlapForCurrentInTime];

                            }
                            if (isOverlap)
                            {
                                [btn setBackgroundImage:[Util thumbnailImage:IN_OUT_BUTTON_ON_IMAGE] forState:UIControlStateNormal];
                                selectedButtonTag=[btn tag];
                                return NO;
                            }
                        }
                    }

                }
            }
        }
    }

    if (lastUsedTextView)
    {
        [lastUsedTextView resignFirstResponder];
    }
    if (lastUsedTextField)
    {
        [lastUsedTextField resignFirstResponder];
    }

    isInOutBtnClicked=YES;
    isTextFieldClicked=YES;
    isUDFieldClicked=YES;
    UIButton *button=(UIButton *)sender;
    self.selectedButtonTag=button.tag;
    self.currentSelectedButtonRow=row;
    NSString *timeStr=[button currentTitle];
    self.hourString=nil;
    self.minsString=nil;

    NSRange replaceRangeAM = [timeStr rangeOfString:@"am"];
    if (replaceRangeAM.location != NSNotFound){
        timeStr= [timeStr stringByReplacingCharactersInRange:replaceRangeAM withString:@""];
        self.formatString=@"am";
    }

    NSRange replaceRangePM = [timeStr rangeOfString:@"pm"];
    if (replaceRangePM.location != NSNotFound){
        timeStr= [timeStr stringByReplacingCharactersInRange:replaceRangePM withString:@""];
        self.formatString=@"pm";
    }

    NSArray *componentsArr=[timeStr componentsSeparatedByString:@":"];
    if ([componentsArr count]>1
        &&![timeStr isEqualToString:RPLocalizedString(In_Time, @"")]
        &&![timeStr isEqualToString:RPLocalizedString(Out_Time, @"")])
    {
        self.hourString = [componentsArr objectAtIndex:0];
        self.minsString =[componentsArr objectAtIndex:1];
    }


    AppDelegate *appdelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    //   appdelegate.rootTabBarController.tabBar.hidden=TRUE;
    [self.customKeyboardVC.view removeFromSuperview];
    if (customKeyboardVC==nil)
    {
        CustomKeyboardViewController *tempVC=[[CustomKeyboardViewController alloc]initWithNibName:@"CustomKeyboardViewController" bundle:nil] ;
        self.customKeyboardVC=tempVC;

    }
    self.multiDayTimeEntryTableView.frame = CGRectMake(0,Total_Hours_Footer_Height_42,CGRectGetWidth([[UIScreen mainScreen] bounds]), CGRectGetHeight([[UIScreen mainScreen] bounds])-self.customKeyboardVC.view.frame.size.height+20-50.0f);
    [self.multiDayTimeEntryTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]  atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    customKeyboardVC.entryDelegate=self;
    [appdelegate.window addSubview:customKeyboardVC.view];
    if (lastButtonTag==selectedButtonTag)
    {
        [customKeyboardVC enableAndDisablePreviousButton:YES andNextButton:NO];
    }
    else if (firstButtonTag==selectedButtonTag)
    {
        [customKeyboardVC enableAndDisablePreviousButton:NO andNextButton:YES];
    }
    else
    {
        [customKeyboardVC enableAndDisablePreviousButton:YES andNextButton:YES];
    }

    return YES;

}
-(void)removeMultiInOutTimeEntryKeyBoard
{
    [self.customKeyboardVC.view removeFromSuperview];
    self.customKeyboardVC=nil;

    NSInteger noOfRows=[self.multiDayTimeEntryTableView numberOfRowsInSection:0];

    for (int row=0; row<noOfRows; row++)
    {
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:row inSection:0];
        MultiDayInOutTimeEntryCustomCell *selectedCell = (MultiDayInOutTimeEntryCustomCell *)[self. multiDayTimeEntryTableView cellForRowAtIndexPath:indexPath];

        if ([selectedCell tag]==INOUT_CELL_TAG)
        {
            for (UIView *view in selectedCell.contentView.subviews)
            {
                if ([view isKindOfClass:[UIButton class]])
                {
                    UIButton *btn=(UIButton *)view;
                    [btn setBackgroundImage:[Util thumbnailImage:IN_OUT_BUTTON_OFF_IMAGE] forState:UIControlStateNormal];
                    //Implemented for InOut BUTTON UI CHANGE As Per TimeEntry Status
                    if ([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[multiDayTimesheetStatus isEqualToString:APPROVED_STATUS ] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] ||
                        [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED] ||
                        [multiDayTimesheetStatus isEqualToString:TIMESHEET_CONFLICTED])
                    {
                        [btn setBackgroundImage:nil forState:UIControlStateNormal];
                    }
                    //                    self.selectedButtonTag=-1;
                }

            }
        }
    }

}

-(void)hoursFieldUpdatedWithText:(NSString*)hoursText andFormat:(NSString*)format
{
    if (self.hourString!=nil)
    {
        self.hourString=nil;
    }
    if (self.formatString!=nil)
    {
        self.formatString=nil;
    }
    self.hourString=[hoursText stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.formatString=[format stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.minsString=[minsString stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.timeString=nil;
    if ([minsString isKindOfClass:[NSNull class]]||minsString==nil)
    {
        minsString=@"mm";
    }
    if ([formatString isKindOfClass:[NSNull class]]||formatString==nil)
    {
        formatString=@"";
    }
    if ([hourString isKindOfClass:[NSNull class]]||hourString==nil)
    {
        hourString=@"hh";
    }

    self.timeString=[NSString stringWithFormat:@"%@:%@ %@",self.hourString,self.minsString,self.formatString];

    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:currentSelectedButtonRow inSection:0];
    MultiDayInOutTimeEntryCustomCell *selectedCell = (MultiDayInOutTimeEntryCustomCell *)[self. multiDayTimeEntryTableView cellForRowAtIndexPath:indexPath];

    if ([selectedCell tag]==INOUT_CELL_TAG)
    {
        for (UIView *view in selectedCell.contentView.subviews)
        {
            if ([view isKindOfClass:[UIButton class]])
            {
                UIButton *btn=(UIButton *)view;

                if ([btn tag]==selectedButtonTag)
                {
                    [btn setTitle:[NSString stringWithFormat:@"%@",timeString] forState:UIControlStateNormal];
                    if ([btn tag]%2==0)
                    {
                        self.inTimeTotalString=timeString;
                    }
                    else
                    {
                        self.outTimeTotalString=timeString;
                    }
                    NSString *btnTitle=btn.titleLabel.text;
                    NSRange replaceRangeMM = [btnTitle rangeOfString:@"mm"];
                    NSRange replaceRangeHH = [btnTitle rangeOfString:@"hh"];

                    if (replaceRangeMM.location == NSNotFound && replaceRangeHH.location == NSNotFound)
                    {
                        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:currentSelectedButtonRow];
                        NSString *inTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"in_time"];
                        NSString *outTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"out_time"];

                        if ([inTimeString isEqualToString:btnTitle]&&[outTimeString isEqualToString:btnTitle])
                        {

                        }
                        else
                        {
                            NSMutableDictionary *entryDict=[NSMutableDictionary dictionary];

                            if ([btn tag]%2==0)
                            {

                                if ([inTimeString isEqualToString:self.inTimeTotalString])
                                {
                                    [entryDict setObject:inTimeString forKey:@"in_time"];
                                }
                                else if (![inTimeString isEqualToString:btnTitle]&&[inTimeString isEqualToString:@""])
                                {
                                    [entryDict setObject:btnTitle forKey:@"in_time"];
                                }
                                else if (![inTimeString isEqualToString:btnTitle])
                                {
                                    [entryDict setObject:btnTitle forKey:@"in_time"];
                                }

                                if (outTimeString==nil||[outTimeString isKindOfClass:[NSNull class]]||[outTimeString isEqualToString:@""])
                                {
                                    [entryDict setObject:@"" forKey:@"out_time"];
                                }
                                else
                                {
                                    [entryDict setObject:outTimeString forKey:@"out_time"];
                                }

                            }
                            else
                            {

                                if ([outTimeString isEqualToString:self.outTimeTotalString])
                                {
                                    [entryDict setObject:outTimeString forKey:@"out_time"];
                                }
                                else if (![outTimeString isEqualToString:btnTitle]&&[outTimeString isEqualToString:@""])
                                {
                                    [entryDict setObject:btnTitle forKey:@"out_time"];
                                }

                                else if (![outTimeString isEqualToString:btnTitle])
                                {
                                    [entryDict setObject:btnTitle forKey:@"out_time"];
                                }

                                if (inTimeString==nil||[inTimeString isKindOfClass:[NSNull class]]||[inTimeString isEqualToString:@""])
                                {
                                    [entryDict setObject:@"" forKey:@"in_time"];
                                }
                                else
                                {
                                    [entryDict setObject:inTimeString forKey:@"in_time"];
                                }


                            }

                            [self updateMultiDayTimeEntryForIndex:currentSelectedButtonRow withValue:entryDict];
                            //Implemented For overlappingTimeEntriesPermitted Permission
                            if (!self.isOverlapEntryAllowed) {

                                [self checkOverlapForCurrentInTime];
                            }
                        }



                    }
                }
            }

        }
    }

}
-(void)minsFieldUpdatedWithText:(NSString*)minText
{
    if (self.minsString!=nil)
    {
        self.minsString=nil;
    }
    self.minsString=[minText stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.timeString=nil;
    if ([minsString isKindOfClass:[NSNull class]]||minsString==nil)
    {
        minsString=@"mm";
    }
    if ([formatString isKindOfClass:[NSNull class]]||formatString==nil)
    {
        formatString=@"";
    }
    if ([hourString isKindOfClass:[NSNull class]]||hourString==nil)
    {
        hourString=@"hh";
    }


    self.timeString=[NSString stringWithFormat:@"%@:%@ %@",hourString,minsString,formatString];

    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:currentSelectedButtonRow inSection:0];
    MultiDayInOutTimeEntryCustomCell *selectedCell = (MultiDayInOutTimeEntryCustomCell *)[self. multiDayTimeEntryTableView cellForRowAtIndexPath:indexPath];

    if ([selectedCell tag]==INOUT_CELL_TAG)
    {
        for (UIView *view in selectedCell.contentView.subviews)
        {
            if ([view isKindOfClass:[UIButton class]])
            {
                UIButton *btn=(UIButton *)view;
                if ([btn tag]==selectedButtonTag)
                {
                    [btn setTitle:[NSString stringWithFormat:@"%@",timeString] forState:UIControlStateNormal];
                    if ([btn tag]%2==0)
                    {
                        self.inTimeTotalString=timeString;
                    }
                    else
                    {
                        self.outTimeTotalString=timeString;
                    }

                    NSString *btnTitle=btn.titleLabel.text;
                    NSRange replaceRangeMM = [btnTitle rangeOfString:@"mm"];
                    NSRange replaceRangeHH = [btnTitle rangeOfString:@"hh"];

                    if (replaceRangeMM.location == NSNotFound && replaceRangeHH.location == NSNotFound)
                    {
                        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:currentSelectedButtonRow];
                        NSString *inTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"in_time"];
                        NSString *outTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"out_time"];

                        if ([inTimeString isEqualToString:btnTitle]&&[outTimeString isEqualToString:btnTitle])
                        {

                        }
                        else
                        {
                            NSMutableDictionary *entryDict=[NSMutableDictionary dictionary];

                            if ([btn tag]%2==0)
                            {

                                if ([inTimeString isEqualToString:self.inTimeTotalString])
                                {
                                    [entryDict setObject:inTimeString forKey:@"in_time"];
                                }
                                else if (![inTimeString isEqualToString:btnTitle]&&[inTimeString isEqualToString:@""])
                                {
                                    [entryDict setObject:btnTitle forKey:@"in_time"];
                                }
                                else if (![inTimeString isEqualToString:btnTitle])
                                {
                                    [entryDict setObject:btnTitle forKey:@"in_time"];
                                }

                                if (outTimeString==nil||[outTimeString isKindOfClass:[NSNull class]]||[outTimeString isEqualToString:@""])
                                {
                                    [entryDict setObject:@"" forKey:@"out_time"];
                                }
                                else
                                {
                                    [entryDict setObject:outTimeString forKey:@"out_time"];
                                }

                            }
                            else
                            {

                                if ([outTimeString isEqualToString:self.outTimeTotalString])
                                {
                                    [entryDict setObject:outTimeString forKey:@"out_time"];
                                }
                                else if (![outTimeString isEqualToString:btnTitle]&&[outTimeString isEqualToString:@""])
                                {
                                    [entryDict setObject:btnTitle forKey:@"out_time"];
                                }

                                else if (![outTimeString isEqualToString:btnTitle])
                                {
                                    [entryDict setObject:btnTitle forKey:@"out_time"];
                                }

                                if (inTimeString==nil||[inTimeString isKindOfClass:[NSNull class]]||[inTimeString isEqualToString:@""])
                                {
                                    [entryDict setObject:@"" forKey:@"in_time"];
                                }
                                else
                                {
                                    [entryDict setObject:inTimeString forKey:@"in_time"];
                                }

                            }

                            [self updateMultiDayTimeEntryForIndex:currentSelectedButtonRow withValue:entryDict];
                            //Implemented For overlappingTimeEntriesPermitted Permission
                            if (!self.isOverlapEntryAllowed) {
                                [self checkOverlapForCurrentInTime];
                            }
                        }
                    }
                }
            }

        }
    }

}
-(void)clearButtonPressed
{
    isOverlap=NO;
    self.minsString=nil;
    self.hourString=nil;
    self.timeString=nil;
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:currentSelectedButtonRow inSection:0];
    MultiDayInOutTimeEntryCustomCell *selectedCell = (MultiDayInOutTimeEntryCustomCell *)[self. multiDayTimeEntryTableView cellForRowAtIndexPath:indexPath];

    if ([selectedCell tag]==INOUT_CELL_TAG)
    {
        for (UIView *view in selectedCell.contentView.subviews)
        {
            if ([view isKindOfClass:[UIButton class]])
            {
                UIButton *btn=(UIButton *)view;
                if ([btn tag]==selectedButtonTag)
                {
                    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:indexPath.row];
                    NSMutableDictionary *entryDict=[tsEntryObject multiDayInOutEntry];
                    if ([btn tag]%2==0)
                    {
                        [btn setTitle:RPLocalizedString(In_Time, @"")  forState:UIControlStateNormal];
                        [entryDict setObject:@"" forKey:@"in_time"];
                    }
                    else
                    {
                        [btn setTitle:RPLocalizedString(Out_Time, @"")  forState:UIControlStateNormal];
                        [entryDict setObject:@"" forKey:@"out_time"];
                    }
                    [self updateMultiDayTimeEntryForIndex:currentSelectedButtonRow withValue:entryDict];

                }
            }

        }
    }
    [self calculateAndUpdateTotalHoursValueForFooter];
}
-(void)doneButtonPressed
{
    [self calculateAndUpdateTotalHoursValueForFooter];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:currentSelectedButtonRow inSection:0];
    MultiDayInOutTimeEntryCustomCell *selectedCell = (MultiDayInOutTimeEntryCustomCell *)[self. multiDayTimeEntryTableView cellForRowAtIndexPath:indexPath];

    if ([selectedCell tag]==INOUT_CELL_TAG)
    {
        for (UIView *view in selectedCell.contentView.subviews)
        {
            if ([view isKindOfClass:[UIButton class]])
            {
                UIButton *btn=(UIButton *)view;
                if ([btn tag]==selectedButtonTag)
                {
                    NSString *btnTitle=btn.titleLabel.text;
                    if ([btnTitle isEqualToString:RPLocalizedString(In_Time, In_Time)]||[btnTitle isEqualToString:RPLocalizedString(Out_Time, Out_Time)])
                    {
                        self.isTextFieldClicked=NO;
                        self.isUDFieldClicked=NO;
                        [self resetTableSize:NO  isTextFieldOrTextViewClicked:NO isUdfClicked:NO];
                        [self removeMultiInOutTimeEntryKeyBoard];
                        return;
                    }
                    else
                    {
                        NSRange replaceRangeMM = [self.timeString rangeOfString:@"mm"];
                        NSRange replaceRangeHH = [self.timeString rangeOfString:@"hh"];
                        //                    if ((replaceRangeMM.location != NSNotFound||replaceRangeHH.location != NSNotFound) || self.timeString==nil)
                        //                    {
                        //                        [Util errorAlert:RPLocalizedString(Please_enter_valid_time_Message, @"") errorMessage:@""];
                        //                        return;
                        //                    }
                        //                    else
                        //                    {

                        //Ullas added for multi inout changes.To revert back if required
                        //start
                        NSString *tempHrsStr=@"";
                        NSString *tempMinsStr=@"";
                        NSString *tempFormatStr=@"";
                        NSArray *timeCompsArr=[btnTitle componentsSeparatedByString:@":"];
                        if ([timeCompsArr count]==2)
                        {
                            tempHrsStr=[NSString stringWithFormat:@"%@",[timeCompsArr objectAtIndex:0]];

                            NSArray *amPmCompsArr=[[timeCompsArr objectAtIndex:1] componentsSeparatedByString:@" "];
                            if ([amPmCompsArr count]==2)
                            {
                                tempMinsStr=[NSString stringWithFormat:@"%@",[amPmCompsArr objectAtIndex:0]];
                                tempFormatStr=[NSString stringWithFormat:@"%@",[amPmCompsArr objectAtIndex:1]];

                            }
                        }

                        if (replaceRangeMM.location != NSNotFound)
                        {
                            tempMinsStr=@"00";
                        }
                        if (replaceRangeHH.location != NSNotFound)
                        {
                            tempHrsStr=@"12";
                            tempFormatStr=@"am";
                        }
                        self.timeString=[NSString stringWithFormat:@"%@:%@ %@",tempHrsStr,tempMinsStr,tempFormatStr];
                        [btn setTitle:[NSString stringWithFormat:@"%@",self.timeString] forState:UIControlStateNormal];
                        //end
                        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:currentSelectedButtonRow];
                        NSString *inTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"in_time"];
                        NSString *outTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"out_time"];

                        if ([inTimeString isEqualToString:self.timeString]&&[outTimeString isEqualToString:self.timeString]&& ![inTimeString isEqualToString:outTimeString])
                        {
                            return;
                        }
                        else
                        {
                            NSMutableDictionary *entryDict=[tsEntryObject multiDayInOutEntry];
                            if ([btn tag]%2==0)
                            {

                                if ([inTimeString isEqualToString:self.inTimeTotalString])
                                {
                                    [entryDict setObject:inTimeString forKey:@"in_time"];
                                }
                                else if (![inTimeString isEqualToString:self.timeString]&&[inTimeString isEqualToString:@""])
                                {
                                    [entryDict setObject:self.timeString forKey:@"in_time"];
                                }
                                else if (![inTimeString isEqualToString:self.timeString])
                                {
                                    [entryDict setObject:self.timeString forKey:@"in_time"];
                                }
                            }
                            else
                            {

                                if ([outTimeString isEqualToString:self.outTimeTotalString])
                                {
                                    [entryDict setObject:outTimeString forKey:@"out_time"];
                                }
                                else if (![outTimeString isEqualToString:self.timeString]&&[outTimeString isEqualToString:@""])
                                {
                                    [entryDict setObject:self.timeString forKey:@"out_time"];
                                }

                                else if (![outTimeString isEqualToString:self.timeString])
                                {
                                    [entryDict setObject:self.timeString forKey:@"out_time"];
                                }

                            }
                            [self updateMultiDayTimeEntryForIndex:currentSelectedButtonRow withValue:entryDict];
                            //Implemented For overlappingTimeEntriesPermitted Permission

                                if (!self.isOverlapEntryAllowed) {

                                    [self checkOverlapForCurrentInTime];

                                }
                                if (isOverlap) {
                                    [btn setBackgroundImage:[Util thumbnailImage:IN_OUT_BUTTON_ON_IMAGE] forState:UIControlStateNormal];
                                    return;

                                }


                        }

                    }

                }

                //}
            }

        }
    }
    self.isTextFieldClicked=NO;
    self.isUDFieldClicked=NO;
    [self resetTableSize:NO  isTextFieldOrTextViewClicked:NO isUdfClicked:NO];
    [self removeMultiInOutTimeEntryKeyBoard];
}
-(void)nextButtonPressed
{
    NSInteger noOfRows=[self.multiDayTimeEntryTableView numberOfRowsInSection:0];
    for (int row=0; row<noOfRows; row++)
    {
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:row inSection:0];
        MultiDayInOutTimeEntryCustomCell *selectedCell = (MultiDayInOutTimeEntryCustomCell *)[self. multiDayTimeEntryTableView cellForRowAtIndexPath:indexPath];

        if ([selectedCell tag]==INOUT_CELL_TAG)
        {
            for (UIView *view in selectedCell.contentView.subviews)
            {
                if ([view isKindOfClass:[UIButton class]])
                {
                    UIButton *btn=(UIButton *)view;
                    NSInteger btnRow=btn.superview.tag;

                    if ([btn tag]==selectedButtonTag+1)
                    {

                        self.currentSelectedButtonRow=btnRow;
                        self.hourString=nil;
                        self.minsString=nil;
                        NSString *timeStr=btn.titleLabel.text;
                        NSRange replaceRangeAM = [timeStr rangeOfString:@"am"];
                        if (replaceRangeAM.location != NSNotFound){
                            timeStr= [timeStr stringByReplacingCharactersInRange:replaceRangeAM withString:@""];
                            self.formatString=@"am";
                        }

                        NSRange replaceRangePM = [timeStr rangeOfString:@"pm"];
                        if (replaceRangePM.location != NSNotFound){
                            timeStr= [timeStr stringByReplacingCharactersInRange:replaceRangePM withString:@""];
                            self.formatString=@"pm";
                        }

                        NSArray *componentsArr=[timeStr componentsSeparatedByString:@":"];
                        if ([componentsArr count]>1
                            &&![timeStr isEqualToString:RPLocalizedString(In_Time, @"")]
                            &&![timeStr isEqualToString:RPLocalizedString(Out_Time, @"")])
                        {
                            self.hourString = [componentsArr objectAtIndex:0];
                            self.minsString =[componentsArr objectAtIndex:1];
                            self.hourString= [self.hourString stringByReplacingOccurrencesOfString:@" " withString:@""];
                            self.minsString= [self.minsString stringByReplacingOccurrencesOfString:@" " withString:@""];

                        }
                        if ([btn tag]%2==0)
                        {
                            self.inTimeTotalString=[NSString stringWithFormat:@"%@:%@ %@",self.hourString,self.minsString,self.formatString];
                        }
                        else
                        {
                            self.outTimeTotalString=[NSString stringWithFormat:@"%@:%@ %@",self.hourString,self.minsString,self.formatString];
                        }

                        [btn setBackgroundImage:[Util thumbnailImage:IN_OUT_BUTTON_ON_IMAGE] forState:UIControlStateNormal];

                    }
                    else
                    {

                        if ([btn tag]==selectedButtonTag)
                        {
                            NSString *btnTitle=btn.titleLabel.text;
                            if ([btnTitle isEqualToString:RPLocalizedString(In_Time, In_Time)]||[btnTitle isEqualToString:RPLocalizedString(Out_Time, Out_Time)])
                            {

                            }
                            else
                            {
                                self.timeString=btnTitle;
                                NSRange replaceRangeMM = [btnTitle rangeOfString:@"mm"];
                                NSRange replaceRangeHH = [btnTitle rangeOfString:@"hh"];
                                if ((replaceRangeMM.location != NSNotFound||replaceRangeHH.location != NSNotFound) || btnTitle==nil)
                                {
                                    //Ullas removed for multi inout changes.To revert back if required
                                    //[Util errorAlert:RPLocalizedString(Please_enter_valid_time_Message, @"") errorMessage:@""];
                                    //return;

                                    //start
                                    NSString *tempHrsStr=@"";
                                    NSString *tempMinsStr=@"";
                                    NSString *tempFormatStr=@"";
                                    NSArray *timeCompsArr=[btnTitle componentsSeparatedByString:@":"];
                                    if ([timeCompsArr count]==2)
                                    {
                                        tempHrsStr=[NSString stringWithFormat:@"%@",[timeCompsArr objectAtIndex:0]];

                                        NSArray *amPmCompsArr=[[timeCompsArr objectAtIndex:1] componentsSeparatedByString:@" "];
                                        if ([amPmCompsArr count]==2)
                                        {
                                            tempMinsStr=[NSString stringWithFormat:@"%@",[amPmCompsArr objectAtIndex:0]];
                                            tempFormatStr=[NSString stringWithFormat:@"%@",[amPmCompsArr objectAtIndex:1]];

                                        }
                                    }

                                    if (replaceRangeMM.location != NSNotFound)
                                    {
                                        tempMinsStr=@"00";
                                    }
                                    if (replaceRangeHH.location != NSNotFound)
                                    {
                                        tempHrsStr=@"12";
                                        tempFormatStr=@"am";
                                    }
                                    self.timeString=[NSString stringWithFormat:@"%@:%@ %@",tempHrsStr,tempMinsStr,tempFormatStr];
                                    [btn setTitle:[NSString stringWithFormat:@"%@",self.timeString] forState:UIControlStateNormal];
                                    //end

                                }
                                //else{

                                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:btnRow];
                                NSString *inTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"in_time"];
                                NSString *outTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"out_time"];

                                if ([inTimeString isEqualToString:self.timeString]&&[outTimeString isEqualToString:self.timeString])
                                {

                                }
                                else
                                {
                                    NSMutableDictionary *entryDict=[tsEntryObject multiDayInOutEntry];
                                    if ([btn tag]%2==0)
                                    {

                                        if ([inTimeString isEqualToString:self.inTimeTotalString])
                                        {
                                            [entryDict setObject:inTimeString forKey:@"in_time"];
                                        }
                                        else if (![inTimeString isEqualToString:self.timeString]&&[inTimeString isEqualToString:@""])
                                        {
                                            [entryDict setObject:self.timeString forKey:@"in_time"];
                                        }
                                        else if (![inTimeString isEqualToString:self.timeString])
                                        {
                                            [entryDict setObject:self.timeString forKey:@"in_time"];
                                        }
                                    }
                                    else
                                    {

                                        if ([outTimeString isEqualToString:self.outTimeTotalString])
                                        {
                                            [entryDict setObject:outTimeString forKey:@"out_time"];
                                        }
                                        else if (![outTimeString isEqualToString:self.timeString]&&[outTimeString isEqualToString:@""])
                                        {
                                            [entryDict setObject:self.timeString forKey:@"out_time"];
                                        }

                                        else if (![outTimeString isEqualToString:self.timeString])
                                        {
                                            [entryDict setObject:self.timeString forKey:@"out_time"];
                                        }

                                    }

                                    [self updateMultiDayTimeEntryForIndex:btnRow withValue:entryDict];
                                    //Implemented For overlappingTimeEntriesPermitted Permission
                                    if (!self.isOverlapEntryAllowed) {

                                        [self checkOverlapForCurrentInTime];

                                    }
                                    if (isOverlap) {
                                        [btn setBackgroundImage:[Util thumbnailImage:IN_OUT_BUTTON_ON_IMAGE] forState:UIControlStateNormal];
                                        return;

                                    }
                                }

                                //}

                            }

                        }

                        [btn setBackgroundImage:[Util thumbnailImage:IN_OUT_BUTTON_OFF_IMAGE] forState:UIControlStateNormal];

                    }


                }

            }
        }

    }

    if (lastButtonTag>selectedButtonTag)
    {
        self.selectedButtonTag=selectedButtonTag+1;
        [self.multiDayTimeEntryTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentSelectedButtonRow inSection:0]  atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        if (lastButtonTag==selectedButtonTag)
        {
            [customKeyboardVC enableAndDisablePreviousButton:YES andNextButton:NO];
        }
        else
        {
            [customKeyboardVC enableAndDisablePreviousButton:YES andNextButton:YES];
        }
    }


}
-(void)previousButtonPressed
{
    NSInteger noOfRows=[self.multiDayTimeEntryTableView numberOfRowsInSection:0];
    for (int row=0; row<noOfRows; row++)
    {
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:row inSection:0];
        MultiDayInOutTimeEntryCustomCell *selectedCell = (MultiDayInOutTimeEntryCustomCell *)[self. multiDayTimeEntryTableView cellForRowAtIndexPath:indexPath];

        if ([selectedCell tag]==INOUT_CELL_TAG)
        {
            for (UIView *view in selectedCell.contentView.subviews)
            {
                if ([view isKindOfClass:[UIButton class]])
                {
                    UIButton *btn=(UIButton *)view;
                    NSInteger btnRow=btn.superview.tag;

                    if ([btn tag]==selectedButtonTag-1)
                    {

                        self.currentSelectedButtonRow=btnRow;
                        self.hourString=nil;
                        self.minsString=nil;
                        NSString *timeStr=btn.titleLabel.text;
                        NSRange replaceRangeAM = [timeStr rangeOfString:@"am"];
                        if (replaceRangeAM.location != NSNotFound){
                            timeStr= [timeStr stringByReplacingCharactersInRange:replaceRangeAM withString:@""];
                            self.formatString=@"am";

                        }

                        NSRange replaceRangePM = [timeStr rangeOfString:@"pm"];
                        if (replaceRangePM.location != NSNotFound){
                            timeStr= [timeStr stringByReplacingCharactersInRange:replaceRangePM withString:@""];
                            self.formatString=@"pm";
                        }

                        NSArray *componentsArr=[timeStr componentsSeparatedByString:@":"];
                        if ([componentsArr count]>1
                            &&![timeStr isEqualToString:RPLocalizedString(In_Time, @"")]
                            &&![timeStr isEqualToString:RPLocalizedString(Out_Time, @"")])
                        {
                            self.hourString = [componentsArr objectAtIndex:0];
                            self.minsString =[componentsArr objectAtIndex:1];
                            self.hourString= [self.hourString stringByReplacingOccurrencesOfString:@" " withString:@""];
                            self.minsString= [self.minsString stringByReplacingOccurrencesOfString:@" " withString:@""];

                        }
                        if ([btn tag]%2==0)
                        {
                            self.inTimeTotalString=[NSString stringWithFormat:@"%@:%@ %@",self.hourString,self.minsString,self.formatString];
                        }
                        else
                        {
                            self.outTimeTotalString=[NSString stringWithFormat:@"%@:%@ %@",self.hourString,self.minsString,self.formatString];
                        }
                        NSString *btnTitle=self.timeString;
                        NSRange replaceRangeMM = [btnTitle rangeOfString:@"mm"];
                        NSRange replaceRangeHH = [btnTitle rangeOfString:@"hh"];
                        if ((replaceRangeMM.location != NSNotFound||replaceRangeHH.location != NSNotFound) && btnTitle!=nil)
                        {
                            //ullas changes.To uncomment later
                            //[btn setBackgroundImage:[Util thumbnailImage:IN_OUT_BUTTON_ON_IMAGE] forState:UIControlStateNormal];

                        }
                        else
                        {
                            //Implemented For overlappingTimeEntriesPermitted Permission
                            if (!self.isOverlapEntryAllowed) {

                                [self checkOverlapForCurrentInTime];

                            }
                            if (isOverlap) {

                                //ullas changes.To remove later
                                //start
                                if (([btn tag]+1)%2==0)
                                {
                                    UIButton *btn=(UIButton *)view;
                                    NSInteger btnRow=btn.superview.tag;
                                    self.currentSelectedButtonRow=btnRow+1;
                                    selectedButtonTag=[btn tag]+1;
                                }
                                //end
                                [btn setBackgroundImage:[Util thumbnailImage:IN_OUT_BUTTON_OFF_IMAGE] forState:UIControlStateNormal];
                                return;

                            }
                            [btn setBackgroundImage:[Util thumbnailImage:IN_OUT_BUTTON_ON_IMAGE] forState:UIControlStateNormal];
                        }

                    }
                    else
                    {

                        if ([btn tag]==selectedButtonTag)
                        {
                            NSString *btnTitle=btn.titleLabel.text;
                            if ([btnTitle isEqualToString:RPLocalizedString(In_Time, In_Time)]||[btnTitle isEqualToString:RPLocalizedString(Out_Time, Out_Time)])
                            {

                            }
                            else
                            {
                                self.timeString=btnTitle;
                                NSRange replaceRangeMM = [btnTitle rangeOfString:@"mm"];
                                NSRange replaceRangeHH = [btnTitle rangeOfString:@"hh"];
                                if ((replaceRangeMM.location != NSNotFound||replaceRangeHH.location != NSNotFound) || btnTitle==nil)
                                {
                                    //Ullas removed for multi inout changes.To revert back if required
                                    //[Util errorAlert:RPLocalizedString(Please_enter_valid_time_Message, @"") errorMessage:@""];
                                    //self.currentSelectedButtonRow=btnRow;
                                    //return;

                                    //Ullas added for multi inout changes.To revert back if required
                                    NSString *tempHrsStr=@"";
                                    NSString *tempMinsStr=@"";
                                    NSString *tempFormatStr=@"";
                                    NSArray *timeCompsArr=[btnTitle componentsSeparatedByString:@":"];
                                    if ([timeCompsArr count]==2)
                                    {
                                        tempHrsStr=[NSString stringWithFormat:@"%@",[timeCompsArr objectAtIndex:0]];

                                        NSArray *amPmCompsArr=[[timeCompsArr objectAtIndex:1] componentsSeparatedByString:@" "];
                                        if ([amPmCompsArr count]==2)
                                        {
                                            tempMinsStr=[NSString stringWithFormat:@"%@",[amPmCompsArr objectAtIndex:0]];
                                            tempFormatStr=[NSString stringWithFormat:@"%@",[amPmCompsArr objectAtIndex:1]];

                                        }
                                    }

                                    if (replaceRangeMM.location != NSNotFound)
                                    {
                                        tempMinsStr=@"00";
                                    }
                                    if (replaceRangeHH.location != NSNotFound)
                                    {
                                        tempHrsStr=@"12";
                                        tempFormatStr=@"am";
                                    }
                                    self.timeString=[NSString stringWithFormat:@"%@:%@ %@",tempHrsStr,tempMinsStr,tempFormatStr];
                                    [btn setTitle:[NSString stringWithFormat:@"%@",self.timeString] forState:UIControlStateNormal];
                                    self.currentSelectedButtonRow=btnRow;

                                }
                                //else
                                //{
                                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:btnRow];
                                NSString *inTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"in_time"];
                                NSString *outTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"out_time"];

                                if ([inTimeString isEqualToString:self.timeString]&&[outTimeString isEqualToString:self.timeString])
                                {

                                }
                                else
                                {
                                    NSMutableDictionary *entryDict=[tsEntryObject multiDayInOutEntry];
                                    if ([btn tag]%2==0)
                                    {

                                        if ([inTimeString isEqualToString:self.inTimeTotalString])
                                        {
                                            [entryDict setObject:inTimeString forKey:@"in_time"];
                                        }
                                        else if (![inTimeString isEqualToString:self.timeString]&&[inTimeString isEqualToString:@""])
                                        {
                                            [entryDict setObject:self.timeString forKey:@"in_time"];
                                        }
                                        else if (![inTimeString isEqualToString:self.timeString])
                                        {
                                            [entryDict setObject:self.timeString forKey:@"in_time"];
                                        }
                                    }
                                    else
                                    {

                                        if ([outTimeString isEqualToString:self.outTimeTotalString])
                                        {
                                            [entryDict setObject:outTimeString forKey:@"out_time"];
                                        }
                                        else if (![outTimeString isEqualToString:self.timeString]&&[outTimeString isEqualToString:@""])
                                        {
                                            [entryDict setObject:self.timeString forKey:@"out_time"];
                                        }

                                        else if (![outTimeString isEqualToString:self.timeString])
                                        {
                                            [entryDict setObject:self.timeString forKey:@"out_time"];
                                        }

                                    }

                                    [self updateMultiDayTimeEntryForIndex:btnRow withValue:entryDict];
                                    //Implemented For overlappingTimeEntriesPermitted Permission
                                    if (!self.isOverlapEntryAllowed) {

                                        [self checkOverlapForCurrentInTime];

                                    }
                                    if (isOverlap) {
                                        [btn setBackgroundImage:[Util thumbnailImage:IN_OUT_BUTTON_ON_IMAGE] forState:UIControlStateNormal];
                                        return;

                                    }
                                }

                                //}

                            }


                        }
                        [btn setBackgroundImage:[Util thumbnailImage:IN_OUT_BUTTON_OFF_IMAGE] forState:UIControlStateNormal];

                    }

                }

            }
        }
    }

    if (firstButtonTag<=selectedButtonTag-1)
    {
        [self.multiDayTimeEntryTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentSelectedButtonRow inSection:0]  atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        self.selectedButtonTag=selectedButtonTag-1;
        if (firstButtonTag==selectedButtonTag)
        {
            [customKeyboardVC enableAndDisablePreviousButton:NO andNextButton:YES];
        }
        else
        {
            [customKeyboardVC enableAndDisablePreviousButton:YES andNextButton:YES];
        }

    }


}
-(void)checkOverlapForCurrentInTime
{
    NSDate *startRange=nil;
    NSDate *endRange=nil;
    NSDate *currentInDate=nil;
    NSDate *currentOutDate=nil;
    isOverlap=NO;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];

    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [dateFormat setTimeZone:timeZone];


    NSLocale *locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
    [dateFormat setLocale:locale];
    [dateFormat setDateFormat:@"hh:mm a"];



    TimesheetEntryObject *entryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:currentSelectedButtonRow];
    NSString *inTimeStr=[[entryObject multiDayInOutEntry] objectForKey:@"in_time"];
    NSString *outTimeStr=[[entryObject multiDayInOutEntry] objectForKey:@"out_time"];
    //NSLog(@"inTimeStr %@ outTimeStr %@",inTimeStr,outTimeStr);
    if (inTimeStr!=nil && ![inTimeStr isKindOfClass:[NSNull class]] && ![inTimeStr isEqualToString:@""] &&![inTimeStr isEqualToString:RPLocalizedString(In_Time, @"")] &&outTimeStr!=nil && ![outTimeStr isKindOfClass:[NSNull class]]&& ![outTimeStr isEqualToString:@""] && ![outTimeStr isEqualToString:RPLocalizedString(Out_Time, @"")])
    {

        currentInDate=[dateFormat dateFromString:inTimeStr];
        currentOutDate=[dateFormat dateFromString:outTimeStr];
        if ([currentInDate compare:currentOutDate ] != NSOrderedDescending)
        {
            if (self.previousCrossOutTime!=nil && ![self.previousCrossOutTime isKindOfClass:[NSNull class]] && ![self.previousCrossOutTime isEqualToString:@""])
            {
                NSDate *previousOutTime=[dateFormat dateFromString:self.previousCrossOutTime];
                if ([currentInDate compare:previousOutTime ] == NSOrderedAscending)
                {
                    [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                    isOverlap=YES;
                    return;
                }
            }
        }


        if ([currentInDate compare:currentOutDate ] == NSOrderedDescending)
        {
            BOOL isNextCrossIntimeCheck=NO;
            if (self.nextCrossIntime!=nil&& ![self.nextCrossIntime isKindOfClass:[NSNull class]]){

                for (int i=0; i<[nextCrossIntime count]; i++)
                {
                    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[nextCrossIntime objectAtIndex:i];
                    NSString *inTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"in_time"];
                    NSString *outTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"out_time"];
                    if (inTimeString!=nil && ![inTimeString isKindOfClass:[NSNull class]] && ![inTimeString isEqualToString:@""] &&outTimeString!=nil && ![outTimeString isKindOfClass:[NSNull class]]&& ![outTimeString isEqualToString:@""])
                    {
                        NSRange replaceRangeMMIn = [inTimeString rangeOfString:@"mm"];
                        NSRange replaceRangeHHIn = [inTimeString rangeOfString:@"hh"];
                        NSRange replaceRangeMMOut = [outTimeString rangeOfString:@"mm"];
                        NSRange replaceRangeHHOut = [outTimeString rangeOfString:@"hh"];

                        if (replaceRangeMMIn.location == NSNotFound && replaceRangeHHIn.location == NSNotFound && replaceRangeHHOut.location==NSNotFound && replaceRangeMMOut.location==NSNotFound)
                        {
                            startRange=[dateFormat dateFromString:inTimeString];
                            endRange=[dateFormat dateFromString:outTimeString];
                            if (([currentOutDate compare:startRange ] == NSOrderedDescending) &&
                                ([currentOutDate compare:endRange ] == NSOrderedAscending)) {
                                isNextCrossIntimeCheck=YES;
                                [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                isOverlap=YES;
                                return;

                            }
                        }
                    }

                }


            }
            if(!isNextCrossIntimeCheck){
                for (int i=0; i<[timesheetEntryObjectArray count]; i++)
                {
                    //Fix for defect DE17705

                    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:i];
                    NSString *inTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"in_time"];
                    NSString *outTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"out_time"];
                    if (inTimeString!=nil && ![inTimeString isKindOfClass:[NSNull class]] && ![inTimeString isEqualToString:@""] &&outTimeString!=nil && ![outTimeString isKindOfClass:[NSNull class]]&& ![outTimeString isEqualToString:@""]) {

                        NSRange replaceRangeMMIn = [inTimeString rangeOfString:@"mm"];
                        NSRange replaceRangeHHIn = [inTimeString rangeOfString:@"hh"];
                        NSRange replaceRangeMMOut = [outTimeString rangeOfString:@"mm"];
                        NSRange replaceRangeHHOut = [outTimeString rangeOfString:@"hh"];

                        if (replaceRangeMMIn.location == NSNotFound && replaceRangeHHIn.location == NSNotFound && replaceRangeHHOut.location==NSNotFound && replaceRangeMMOut.location==NSNotFound)
                        {
                            startRange=[dateFormat dateFromString:inTimeString];
                            endRange=[dateFormat dateFromString:outTimeString];


                            if ([startRange compare:endRange ] == NSOrderedDescending)
                            {
                                if (([currentInDate compare:startRange ] == NSOrderedDescending) &&
                                    ([currentInDate compare:endRange ] == NSOrderedDescending)) {

                                    [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                    isOverlap=YES;
                                    return;


                                }
                                if (([currentOutDate compare:startRange ] == NSOrderedDescending) &&
                                    ([currentOutDate compare:endRange ] == NSOrderedDescending)) {

                                    [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                    isOverlap=YES;
                                    return;

                                }
                                if ([startRange compare:currentInDate ] == NSOrderedDescending &&([startRange compare:currentOutDate ]== NSOrderedDescending))
                                {
                                    [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                    isOverlap=YES;
                                    return;
                                }
                                if (([startRange compare:currentInDate ] == NSOrderedAscending) &&
                                    ([startRange compare:currentOutDate ] == NSOrderedAscending)) {

                                    [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                    isOverlap=YES;
                                    return;


                                }

                                if ([endRange compare:currentInDate ] == NSOrderedDescending &&([endRange compare:currentOutDate ]== NSOrderedAscending))
                                {
                                    [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                    isOverlap=YES;
                                    return;
                                }
                                if (([endRange compare:currentInDate ] == NSOrderedAscending) &&([endRange compare:currentOutDate ] == NSOrderedDescending))
                                {

                                    [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                    isOverlap=YES;
                                    return;
                                }
                            }
                            if (([currentInDate compare:startRange ] == NSOrderedDescending) &&
                                ([currentInDate compare:endRange ] == NSOrderedAscending)) {

                                [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                isOverlap=YES;
                                return;


                            }
                            if (([currentOutDate compare:startRange ] == NSOrderedDescending) &&
                                ([currentOutDate compare:endRange ] != NSOrderedAscending)) {

                                if (([startRange compare:currentInDate ] == NSOrderedDescending) &&
                                    ([startRange compare:currentOutDate ] == NSOrderedAscending)) {

                                    [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                    isOverlap=YES;
                                    return;


                                }


                            }

                            if ([startRange compare:currentInDate ] == NSOrderedSame)
                            {
                                if ([endRange compare:currentInDate ] == NSOrderedDescending &&([endRange compare:currentOutDate ]== NSOrderedAscending))
                                {
                                    [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                    isOverlap=YES;
                                    return;
                                }
                                if (([endRange compare:currentInDate ] == NSOrderedAscending) &&([endRange compare:currentOutDate ] == NSOrderedDescending))
                                {
                                    [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                    isOverlap=YES;
                                    return;

                                }
                                if (([endRange compare:currentInDate ] == NSOrderedAscending) &&([endRange compare:currentOutDate ] == NSOrderedAscending))
                                {
                                    [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                    isOverlap=YES;
                                    return;

                                }
                                if (([endRange compare:currentInDate ] == NSOrderedDescending) &&([endRange compare:currentOutDate ] == NSOrderedDescending))
                                {
                                    [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                    isOverlap=YES;
                                    return;

                                }
                            }

                        }

                    }


                }
            }
        }
        else{
            for (int i=0; i<[timesheetEntryObjectArray count]; i++)
            {
                //Fix for DE17705

                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:i];
                NSString *inTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"in_time"];
                NSString *outTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"out_time"];
                if (inTimeString!=nil && ![inTimeString isKindOfClass:[NSNull class]] && ![inTimeString isEqualToString:@""] &&outTimeString!=nil && ![outTimeString isKindOfClass:[NSNull class]]&& ![outTimeString isEqualToString:@""]) {

                    NSRange replaceRangeMMIn = [inTimeString rangeOfString:@"mm"];
                    NSRange replaceRangeHHIn = [inTimeString rangeOfString:@"hh"];
                    NSRange replaceRangeMMOut = [outTimeString rangeOfString:@"mm"];
                    NSRange replaceRangeHHOut = [outTimeString rangeOfString:@"hh"];

                    if (replaceRangeMMIn.location == NSNotFound && replaceRangeHHIn.location == NSNotFound && replaceRangeHHOut.location==NSNotFound && replaceRangeMMOut.location==NSNotFound)
                    {
                        startRange=[dateFormat dateFromString:inTimeString];
                        endRange=[dateFormat dateFromString:outTimeString];
                        //Fix for DE15486
                        if (currentSelectedButtonRow!=i)
                        {
                            if (([currentInDate compare:startRange ] == NSOrderedSame) &&
                                ([currentInDate compare:endRange ] == NSOrderedAscending)) {

                                [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                isOverlap=YES;
                                return;


                            }
                        }
                        if (([currentInDate compare:startRange ] == NSOrderedDescending) &&
                            ([currentInDate compare:endRange ] == NSOrderedAscending)) {

                            [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                            isOverlap=YES;
                            return;


                        }
                        if ([startRange compare:endRange ] == NSOrderedDescending)
                        {
                            if (([currentInDate compare:startRange ] == NSOrderedDescending) &&
                                ([currentInDate compare:endRange ] == NSOrderedDescending)) {

                                [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                isOverlap=YES;
                                return;


                            }
                            if (([currentOutDate compare:startRange ] == NSOrderedDescending) &&
                                ([currentOutDate compare:endRange ] == NSOrderedDescending)) {

                                [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                isOverlap=YES;
                                return;

                            }//Fix for DE17705
                            if (([currentInDate compare:startRange ] == NSOrderedAscending) &&
                                ([currentInDate compare:endRange ] == NSOrderedAscending)) {

                                [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                isOverlap=YES;
                                return;


                            }
                        }
                        if (([currentOutDate compare:startRange ] == NSOrderedDescending) &&
                            ([currentOutDate compare:endRange ] == NSOrderedAscending)) {

                            [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                            isOverlap=YES;
                            return;

                        }
                        if (([currentOutDate compare:startRange ] == NSOrderedDescending) &&
                            ([currentOutDate compare:endRange ] != NSOrderedAscending)) {

                            if (([startRange compare:currentInDate ] == NSOrderedDescending) &&
                                ([startRange compare:currentOutDate ] == NSOrderedAscending)) {

                                [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                isOverlap=YES;
                                return;


                            }


                        }

                    }

                }


            }
        }


    }
    if (inTimeStr!=nil && ![inTimeStr isKindOfClass:[NSNull class]] && ![inTimeStr isEqualToString:@""] &&(outTimeStr==nil ||[outTimeStr isKindOfClass:[NSNull class]]|| [outTimeStr isEqualToString:@""])){
        //NSLog(@"NO OUTTime");
        return;

    }

}
-(void)checkOverlapForPage{

    if ([multiDayTimesheetStatus isEqualToString:NOT_SUBMITTED_STATUS ]||[multiDayTimesheetStatus isEqualToString:REJECTED_STATUS ])
    {
        isOverlap=NO;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        [dateFormat setTimeZone:timeZone];


        NSLocale *locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
        [dateFormat setLocale:locale];
        [dateFormat setDateFormat:@"hh:mm a"];


        for (int i=0; i<[timesheetEntryObjectArray count]; i++)
        {

            NSDate *currentInDate=nil;
            NSDate *currentOutDate=nil;
            TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:i];
            NSString *inTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"in_time"];
            NSString *outTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"out_time"];
            if (inTimeString!=nil && ![inTimeString isKindOfClass:[NSNull class]] && ![inTimeString isEqualToString:@""] &&outTimeString!=nil && ![outTimeString isKindOfClass:[NSNull class]]&& ![outTimeString isEqualToString:@""]) {
                currentInDate=[dateFormat dateFromString:inTimeString];
                currentOutDate=[dateFormat dateFromString:outTimeString];
                for (int j=0; j<[timesheetEntryObjectArray count]; j++)
                {
                    NSDate *startRange=nil;
                    NSDate *endRange=nil;
                    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:j];
                    NSString *inTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"in_time"];
                    NSString *outTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"out_time"];
                    if ([currentInDate compare:currentOutDate ] != NSOrderedDescending)
                    {
                        if (self.previousCrossOutTime!=nil && ![self.previousCrossOutTime isKindOfClass:[NSNull class]] && ![self.previousCrossOutTime isEqualToString:@""])
                        {
                            NSDate *previousOutTime=[dateFormat dateFromString:self.previousCrossOutTime];
                            if ([currentInDate compare:previousOutTime ] == NSOrderedAscending)
                            {
                                [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                isOverlap=YES;
                                return;
                            }
                        }
                    }
                    if ([currentInDate compare:currentOutDate ] == NSOrderedDescending)
                    {
                        BOOL isNextCrossIntimeCheck=NO;
                        if (self.nextCrossIntime!=nil&& ![self.nextCrossIntime isKindOfClass:[NSNull class]]){

                            for (int k=0; k<[nextCrossIntime count]; k++)
                            {
                                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[nextCrossIntime objectAtIndex:k];
                                NSString *inTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"in_time"];
                                NSString *outTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"out_time"];
                                if (inTimeString!=nil && ![inTimeString isKindOfClass:[NSNull class]] && ![inTimeString isEqualToString:@""] &&outTimeString!=nil && ![outTimeString isKindOfClass:[NSNull class]]&& ![outTimeString isEqualToString:@""])
                                {
                                    NSRange replaceRangeMMIn = [inTimeString rangeOfString:@"mm"];
                                    NSRange replaceRangeHHIn = [inTimeString rangeOfString:@"hh"];
                                    NSRange replaceRangeMMOut = [outTimeString rangeOfString:@"mm"];
                                    NSRange replaceRangeHHOut = [outTimeString rangeOfString:@"hh"];

                                    if (replaceRangeMMIn.location == NSNotFound && replaceRangeHHIn.location == NSNotFound && replaceRangeHHOut.location==NSNotFound && replaceRangeMMOut.location==NSNotFound)
                                    {
                                        startRange=[dateFormat dateFromString:inTimeString];
                                        endRange=[dateFormat dateFromString:outTimeString];
                                        if (([currentOutDate compare:startRange ] == NSOrderedDescending) &&
                                            ([currentOutDate compare:endRange ] == NSOrderedAscending)) {
                                            isNextCrossIntimeCheck=YES;
                                            [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                            isOverlap=YES;
                                            return;

                                        }
                                    }
                                }

                            }


                        }
                        if (!isNextCrossIntimeCheck)
                        {
                            if (i!=j){
                                if (inTimeString!=nil && ![inTimeString isKindOfClass:[NSNull class]] && ![inTimeString isEqualToString:@""] &&![inTimeString isEqualToString:RPLocalizedString(In_Time, @"")] &&outTimeString!=nil && ![outTimeString isKindOfClass:[NSNull class]]&& ![outTimeString isEqualToString:@""] && ![outTimeString isEqualToString:RPLocalizedString(Out_Time, @"")]){

                                    NSRange replaceRangeMMIn = [inTimeString rangeOfString:@"mm"];
                                    NSRange replaceRangeHHIn = [inTimeString rangeOfString:@"hh"];
                                    NSRange replaceRangeMMOut = [outTimeString rangeOfString:@"mm"];
                                    NSRange replaceRangeHHOut = [outTimeString rangeOfString:@"hh"];

                                    if (replaceRangeMMIn.location == NSNotFound && replaceRangeHHIn.location == NSNotFound && replaceRangeHHOut.location==NSNotFound && replaceRangeMMOut.location==NSNotFound){
                                        startRange=[dateFormat dateFromString:inTimeString];
                                        endRange=[dateFormat dateFromString:outTimeString];
                                        if ([startRange compare:endRange ] == NSOrderedDescending)
                                        {
                                            if (([currentInDate compare:startRange ] == NSOrderedDescending) &&
                                                ([currentInDate compare:endRange ] == NSOrderedDescending)) {

                                                [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                                isOverlap=YES;
                                                return;


                                            }
                                            if (([currentOutDate compare:startRange ] == NSOrderedDescending) &&
                                                ([currentOutDate compare:endRange ] == NSOrderedDescending)) {

                                                [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                                isOverlap=YES;
                                                return;

                                            }
                                        }
                                        if (([currentInDate compare:startRange ] == NSOrderedDescending) &&
                                            ([currentInDate compare:endRange ] == NSOrderedAscending)) {

                                            [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                            isOverlap=YES;
                                            return;


                                        }

                                    }
                                }

                            }
                        }
                    }
                    else if (i!=j)
                    {
                        if (inTimeString!=nil && ![inTimeString isKindOfClass:[NSNull class]] && ![inTimeString isEqualToString:@""] &&![inTimeString isEqualToString:RPLocalizedString(In_Time, @"")] &&outTimeString!=nil && ![outTimeString isKindOfClass:[NSNull class]]&& ![outTimeString isEqualToString:@""] && ![outTimeString isEqualToString:RPLocalizedString(Out_Time, @"")]){

                            NSRange replaceRangeMMIn = [inTimeString rangeOfString:@"mm"];
                            NSRange replaceRangeHHIn = [inTimeString rangeOfString:@"hh"];
                            NSRange replaceRangeMMOut = [outTimeString rangeOfString:@"mm"];
                            NSRange replaceRangeHHOut = [outTimeString rangeOfString:@"hh"];

                            if (replaceRangeMMIn.location == NSNotFound && replaceRangeHHIn.location == NSNotFound && replaceRangeHHOut.location==NSNotFound && replaceRangeMMOut.location==NSNotFound)
                            {

                                startRange=[dateFormat dateFromString:inTimeString];
                                endRange=[dateFormat dateFromString:outTimeString];

                                //Fix for DE15486
                                if (([currentInDate compare:startRange ] == NSOrderedSame) &&
                                    ([currentInDate compare:endRange ] == NSOrderedAscending)) {

                                    [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                    isOverlap=YES;
                                    return;


                                }

                                if (([currentInDate compare:startRange ] == NSOrderedDescending) &&
                                    ([currentInDate compare:endRange ] == NSOrderedAscending)) {

                                    [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                    isOverlap=YES;
                                    return;


                                }
                                if ([startRange compare:endRange ] == NSOrderedDescending)
                                {
                                    if (([currentInDate compare:startRange ] == NSOrderedDescending) &&
                                        ([currentInDate compare:endRange ] == NSOrderedDescending)) {

                                        [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                        isOverlap=YES;
                                        return;


                                    }
                                    if (([currentOutDate compare:startRange ] == NSOrderedDescending) &&
                                        ([currentOutDate compare:endRange ] == NSOrderedDescending)) {

                                        [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                        isOverlap=YES;
                                        return;

                                    }
                                }
                                if (([currentOutDate compare:startRange ] == NSOrderedDescending) &&
                                    ([currentOutDate compare:endRange ] == NSOrderedAscending)) {

                                    [Util errorAlert:RPLocalizedString(Overlap_Msg, @"") errorMessage:@""];
                                    isOverlap=YES;
                                    return;

                                }

                            }

                        }

                    }

                }
            }
        }

    }
    else
    {
        self.isOverlap=NO;
    }


}
-(void)calculateNumberOfRowsAndTotalHoursForFooter
{
    int tempNumberOfSickRows=0;
    int tempNumberOfInOutRows=0;
    float totalCalculatedHours=0;
    for (int i=0; i<[self.timesheetEntryObjectArray count]; i++)
    {
        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:i];
        BOOL isTimeoffSickRow=[tsEntryObject isTimeoffSickRowPresent];

        if (isTimeoffSickRow)
        {
            tempNumberOfSickRows++;
        }
        else
        {

            NSString *inTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"in_time"];
            NSString *outTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"out_time"];

            if ([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
                [multiDayTimesheetStatus isEqualToString:APPROVED_STATUS ] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] ||
                [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED] ||
                [multiDayTimesheetStatus isEqualToString:TIMESHEET_CONFLICTED])
            {
                if ((![inTimeString isKindOfClass:[NSNull class]]&& inTimeString!=nil && ![inTimeString isEqualToString:@""]) || (![outTimeString isKindOfClass:[NSNull class]]&& outTimeString!=nil && ![outTimeString isEqualToString:@""]))
                {
                    tempNumberOfInOutRows++;
                }
            }
            else
            {
                tempNumberOfInOutRows++;
            }


        }


        if (multiInOutTimesheetType==EXTENDED_IN_OUT_TIMESHEET_TYPE)
        {
            if ([[tsEntryObject entryType] isEqualToString:Time_Off_Key]||[[tsEntryObject entryType] isEqualToString:Adhoc_Time_OffKey])
            {
                float timeEntryHours=[[tsEntryObject timeEntryHoursInDecimalFormatWithOutRoundOff] newFloatValue];
                totalCalculatedHours=totalCalculatedHours+timeEntryHours;
            }
            else
            {

                NSMutableArray *punchesArray=[tsEntryObject timePunchesArray];
                for (int k=0; k<[punchesArray count]; k++)
                {

                    NSString *time_in=[[punchesArray objectAtIndex:k] objectForKey:@"in_time"];
                    NSString *time_out=[[punchesArray objectAtIndex:k] objectForKey:@"out_time"];
                    if (time_in!=nil && ![time_in isKindOfClass:[NSNull class]] &&![time_in isEqualToString:@""] && time_out!=nil && ![time_out isKindOfClass:[NSNull class]]&&![time_out isEqualToString:@""])
                    {
                        NSMutableDictionary *inoutDict=[punchesArray objectAtIndex:k];
                        BOOL isMidCrossOverForEntry=[Util checkIsMidNightCrossOver:inoutDict];
                        BOOL isSplitEntry = [self isSplitEntryWithInTime:tsEntryObject.multiDayInOutEntry];
                        
                        if (isMidCrossOverForEntry && !isSplitEntry)
                        {
                            totalCalculatedHours=totalCalculatedHours+[[Util getNumberOfHoursWithoutRoundingForInTime:time_in outTime:@"12:00 am"]newDoubleValue];
                            time_in=@"12:00 am";
                        }
                        
                        if (isSplitEntry) {
                            time_out = [self returnSplitEntryOutTimeWithOutTime:time_out];
                        }
                        totalCalculatedHours=totalCalculatedHours+[[Util getNumberOfHoursWithoutRoundingForInTime:time_in outTime:time_out]newDoubleValue];
                    }


                }

            }


        }
        else
        {

            if ([[tsEntryObject entryType] isEqualToString:Time_Off_Key]||[[tsEntryObject entryType] isEqualToString:Adhoc_Time_OffKey])
            {
                float timeEntryHours=[[tsEntryObject timeEntryHoursInDecimalFormatWithOutRoundOff] newFloatValue];
                totalCalculatedHours=totalCalculatedHours+timeEntryHours;
            }
            else
            {
                NSString *inTime=[[tsEntryObject multiDayInOutEntry] objectForKey:@"in_time"];
                NSString *outTime=[[tsEntryObject multiDayInOutEntry] objectForKey:@"out_time"];


                if (inTime!=nil && ![inTime isKindOfClass:[NSNull class]] && ![inTime isEqualToString:@""]&&outTime!=nil && ![outTime isKindOfClass:[NSNull class]] && ![outTime isEqualToString:@""])
                {
                    float timeEntryHours=[[tsEntryObject timeEntryHoursInDecimalFormatWithOutRoundOff] newFloatValue];
                    totalCalculatedHours=totalCalculatedHours+timeEntryHours;
                }
            }



        }
    }


    numberOfInOutRows=tempNumberOfInOutRows;
    numberOfSickRows=tempNumberOfSickRows;
    NSString *totalHoursString=[NSString stringWithFormat:@"%f",totalCalculatedHours];
	[self.totalLabelHoursLbl setText:[Util getRoundedValueFromDecimalPlaces:[totalHoursString newDoubleValue]withDecimalPlaces:2]];


	if (multiInOutTimesheetType==EXTENDED_IN_OUT_TIMESHEET_TYPE && [controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {


        if (isFromSuggestionViewClickedReload)
        {
            isFromSuggestionViewClickedReload=NO;

            NSMutableArray *suggestionDetailsArray=[self getUniqueSuggestionsArrayFromObjects];
            self.suggestionDetailsDBArray=suggestionDetailsArray;

            UIView *totalFooterView=[[UIView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width ,[suggestionDetailsArray count]*70+Previous_Entries_Label_height)];
            totalFooterView.backgroundColor = [Util colorWithHex:@"#eeeeee" alpha:1.0f];


            float ySuggestion=0;
            BOOL isEditState=YES;
            if ([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
                [multiDayTimesheetStatus isEqualToString:APPROVED_STATUS ] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] ||
                [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED] ||
                [multiDayTimesheetStatus isEqualToString:TIMESHEET_CONFLICTED])
            {
                isEditState=NO;
            }

            if (isEditState)
            {
                if ([suggestionDetailsArray count]>0)
                {
                    UILabel *previousEntriesSuggestionLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 0,self.view.frame.size.width - 20 ,Previous_Entries_Label_height)];
                    [previousEntriesSuggestionLabel setText:RPLocalizedString(PREVIOUS_ENTRIES_STRING, @"")];
                    [previousEntriesSuggestionLabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_14]];
                    [totalFooterView addSubview:previousEntriesSuggestionLabel];
                }
                for (int i=0; i<[suggestionDetailsArray count]; i++)
                {

                    NSMutableDictionary *dataDict=[self getSuggestionHeightDictForObject:[suggestionDetailsArray objectAtIndex:i]];
                    float height=[[dataDict objectForKey:CELL_HEIGHT_KEY] newFloatValue];
                    BOOL isSingleLine=NO;
                    BOOL isTwoLine=NO;
                    BOOL isThreeLine=NO;
                    NSString *line=[dataDict objectForKey:LINE];
                    if ([line isEqualToString:@"SINGLE"])
                    {
                        isSingleLine=YES;
                    }
                    else if ([line isEqualToString:@"DOUBLE"])
                    {
                        isTwoLine=YES;
                    }
                    else if ([line isEqualToString:@"TRIPLE"])
                    {
                        isThreeLine=YES;
                    }
                    SuggestionView *projectSuggestionView=[[SuggestionView alloc]initWithFrame:CGRectMake(0, ySuggestion+Previous_Entries_Label_height-2,self.view.frame.size.width ,height) andWithDataDict:dataDict suggestionObj:[suggestionDetailsArray objectAtIndex:i] withTag:i withDelegate:self] ;
                    ySuggestion=ySuggestion+height;
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnSuggestionView:)];
                    for (UIGestureRecognizer *recognizer in projectSuggestionView.gestureRecognizers)
                    {
                        [projectSuggestionView removeGestureRecognizer:recognizer];
                    }
                    [projectSuggestionView addGestureRecognizer:tap];


                    [totalFooterView addSubview:projectSuggestionView];

                }



            }
            CGRect frame=totalFooterView.frame;
            frame.size.height=ySuggestion+Previous_Entries_Label_height;
            [totalFooterView setFrame:frame];
            [self.multiDayTimeEntryTableView setTableFooterView:totalFooterView];



        }
        else
        {
            UIView *totalFooterView=[[UIView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width ,[suggestionDetailsDBArray count]*70)];
            //[totalFooterView addSubview:totallabelView];


            for (UIView *tmpView in self.multiDayTimeEntryTableView.tableFooterView.subviews)
            {
                if ([tmpView isKindOfClass:[SuggestionView class]])
                {
                    [totalFooterView addSubview:tmpView];
                }
            }

            [self.multiDayTimeEntryTableView setTableFooterView:totalFooterView];




        }



    }
    else
    {
        [self.multiDayTimeEntryTableView setTableFooterView:nil];

    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    for (UIGestureRecognizer *recognizer in totallabelView.gestureRecognizers)
    {
        [totallabelView removeGestureRecognizer:recognizer];
    }
    [totallabelView addGestureRecognizer:tap];
    if (isGen4UserTimesheet)
    {
        if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
        {
            if(![self.timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
            {
                [self.multiDayTimeEntryTableView setTableFooterView:nil];
            }
        }

    }

}
//19700 Ullas M L
-(void)calculateNumberOfRows
{
    int tempNumberOfSickRows=0;
    int tempNumberOfInOutRows=0;
    float totalCalculatedHours=0;
    for (int i=0; i<[self.timesheetEntryObjectArray count]; i++)
    {
        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:i];
        BOOL isTimeoffSickRow=[tsEntryObject isTimeoffSickRowPresent];

        if (isTimeoffSickRow)
        {
            tempNumberOfSickRows++;
        }
        else
        {

            NSString *inTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"in_time"];
            NSString *outTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"out_time"];

            if ([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
                [multiDayTimesheetStatus isEqualToString:APPROVED_STATUS ] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] ||
                [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED] ||
                [multiDayTimesheetStatus isEqualToString:TIMESHEET_CONFLICTED])
            {
                if ((![inTimeString isKindOfClass:[NSNull class]]&& inTimeString!=nil && ![inTimeString isEqualToString:@""]) || (![outTimeString isKindOfClass:[NSNull class]]&& outTimeString!=nil && ![outTimeString isEqualToString:@""]))
                {
                    tempNumberOfInOutRows++;
                }
            }
            else
            {
                tempNumberOfInOutRows++;
            }


        }


        if (multiInOutTimesheetType==EXTENDED_IN_OUT_TIMESHEET_TYPE)
        {
            if ([[tsEntryObject entryType] isEqualToString:Time_Off_Key]||[[tsEntryObject entryType] isEqualToString:Adhoc_Time_OffKey])
            {
                float timeEntryHours=[[tsEntryObject timeEntryHoursInDecimalFormatWithOutRoundOff] newFloatValue];
                totalCalculatedHours=totalCalculatedHours+timeEntryHours;
            }
            else
            {
                NSMutableArray *punchesArray=[tsEntryObject timePunchesArray];
                for (int k=0; k<[punchesArray count]; k++)
                {
                    NSString *time_in=[[punchesArray objectAtIndex:k] objectForKey:@"in_time"];
                    NSString *time_out=[[punchesArray objectAtIndex:k] objectForKey:@"out_time"];
                    if (time_in!=nil && ![time_in isKindOfClass:[NSNull class]] &&![time_in isEqualToString:@""] && time_out!=nil && ![time_out isKindOfClass:[NSNull class]]&&![time_out isEqualToString:@""])
                    {
                        NSMutableDictionary *inoutDict=[punchesArray objectAtIndex:k];
                        BOOL isMidCrossOverForEntry=[Util checkIsMidNightCrossOver:inoutDict];
                        BOOL isSplitEntry = [self isSplitEntryWithInTime:tsEntryObject.multiDayInOutEntry];
                        
                        if (isMidCrossOverForEntry && !isSplitEntry)
                        {
                            totalCalculatedHours=totalCalculatedHours+[[Util getNumberOfHoursWithoutRoundingForInTime:time_in outTime:@"12:00 am"]newDoubleValue];
                            time_in=@"12:00 am";
                        }
                        
                        if (isSplitEntry) {
                            time_out = [self returnSplitEntryOutTimeWithOutTime:time_out];
                        }

                        totalCalculatedHours=totalCalculatedHours+[[Util getNumberOfHoursWithoutRoundingForInTime:time_in outTime:time_out]newDoubleValue];
                    }
                }

            }


        }
        else
        {
            NSString *inTime=[[tsEntryObject multiDayInOutEntry] objectForKey:@"in_time"];
            NSString *outTime=[[tsEntryObject multiDayInOutEntry] objectForKey:@"out_time"];


            if (inTime!=nil && ![inTime isKindOfClass:[NSNull class]] && ![inTime isEqualToString:@""]&&outTime!=nil && ![outTime isKindOfClass:[NSNull class]] && ![outTime isEqualToString:@""])
            {
                float timeEntryHours=[[tsEntryObject timeEntryHoursInDecimalFormatWithOutRoundOff] newFloatValue];
                totalCalculatedHours=totalCalculatedHours+timeEntryHours;
            }
        }
    }


    numberOfInOutRows=tempNumberOfInOutRows;
    numberOfSickRows=tempNumberOfSickRows;

}


-(void)changeParentViewLeftBarbutton
{
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;
        UIBarButtonItem *tempLeftButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(SAVE_STRING,@"")
                                                                                      style:UIBarButtonItemStylePlain
                                                                                     target:tsMainPageCtrl action:@selector(backAndSaveAction:)];
        [tempLeftButtonOuterBtn setAccessibilityLabel:@"save_time_dist_btn"];
        [tsMainPageCtrl.navigationItem setLeftBarButtonItem:tempLeftButtonOuterBtn animated:NO];

    }


}
#pragma mark - Extended inout methods


-(void)addEmptyEntryOnSectionIndex:(NSInteger)sectionIndex
{
    // NSMutableArray *entryArray=[timesheetEntryObjectArray objectAtIndex:sectionIndex];
    CLS_LOG(@"-----Add New entry on section Action on MultiDayInOutViewController -----");
    TimesheetEntryObject *tempEntryObject=[timesheetEntryObjectArray objectAtIndex:sectionIndex];
    TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc]init];
    [tsEntryObject setTimeEntryComments:tempEntryObject.timeEntryComments];
    //MOBI-746
    [tsEntryObject setTimeEntryProgramUri:tempEntryObject.timeEntryProgramUri];
    [tsEntryObject setTimeEntryProgramName:tempEntryObject.timeEntryProgramName];
    [tsEntryObject  setTimeEntryProjectName:tempEntryObject.timeEntryProjectName];
    [tsEntryObject  setTimeEntryProjectUri:tempEntryObject.timeEntryProjectUri];
    [tsEntryObject  setTimeEntryClientName:tempEntryObject.timeEntryClientName];
    [tsEntryObject  setTimeEntryClientUri:tempEntryObject.timeEntryClientUri];
    [tsEntryObject  setTimeEntryTaskName:tempEntryObject.timeEntryTaskName];
    [tsEntryObject  setTimeEntryTaskUri:tempEntryObject.timeEntryTaskUri];
    [tsEntryObject  setTimeEntryActivityName:tempEntryObject.timeEntryActivityName];
    [tsEntryObject  setTimeEntryActivityUri:tempEntryObject.timeEntryActivityUri];
    [tsEntryObject  setTimeEntryBillingName:tempEntryObject.timeEntryBillingName];
    [tsEntryObject  setTimeEntryBillingUri:tempEntryObject.timeEntryBillingUri];
//    [tsEntryObject  setTimeOffName:tempEntryObject.timeOffName];
//    [tsEntryObject  setTimeOffTypeUri:tempEntryObject.timeOffTypeUri];
    [tsEntryObject  setTimeEntryHoursInHourFormat:tempEntryObject.timeEntryHoursInHourFormat];
    [tsEntryObject  setTimeEntryHoursInDecimalFormat:tempEntryObject.timeEntryHoursInDecimalFormat];
    [tsEntryObject  setTimeEntryHoursInDecimalFormatWithOutRoundOff:tempEntryObject.timeEntryHoursInDecimalFormatWithOutRoundOff];
    [tsEntryObject  setTimeEntryUdfArray:tempEntryObject.timeEntryUdfArray];
    [tsEntryObject setIsTimeoffSickRowPresent:tempEntryObject.isTimeoffSickRowPresent];
    [tsEntryObject setMultiDayInOutEntry:tempEntryObject.multiDayInOutEntry];
    [tsEntryObject  setTimePunchUri:tempEntryObject.timePunchUri];
    [tsEntryObject  setTimeAllocationUri:tempEntryObject.timeAllocationUri];
    [tsEntryObject  setTimeEntryDate:tempEntryObject.timeEntryDate];
    [tsEntryObject setEntryType:tempEntryObject.entryType];
    //[tsEntryObject setRowUri:tempEntryObject.rowUri];
    [tsEntryObject setIsNewlyAddedAdhocRow:tempEntryObject.isNewlyAddedAdhocRow];
    [tsEntryObject setIsRowEditable:tempEntryObject.isRowEditable];
    [tsEntryObject setBreakName:tempEntryObject.breakName];
    [tsEntryObject  setTimeEntryRowUdfArray:tempEntryObject.timeEntryRowUdfArray];
    [tsEntryObject setBreakUri:tempEntryObject.breakUri];
    [tsEntryObject  setTimeEntryTimeOffRowUri:tempEntryObject.timeEntryTimeOffRowUri];
    [tsEntryObject  setTimeEntryTimeOffName:tempEntryObject.timeEntryTimeOffName];
    [tsEntryObject  setTimeEntryTimeOffUri:tempEntryObject.timeEntryTimeOffUri];
    [tsEntryObject  setTimesheetUri:tempEntryObject.timesheetUri];

    if (multiInOutTimesheetType==EXTENDED_IN_OUT_TIMESHEET_TYPE)
    {
        NSMutableArray *timePunchesArr=[NSMutableArray array];
        //int rowIndex=[timePunchesArr count]-1;
        NSMutableArray *udfArray=[self createUdfs];
        NSMutableArray *tmpUdfArray=[NSMutableArray array];
        for (int i=0; i<[udfArray count]; i++)
        {
            NSDictionary *udfDict = [udfArray objectAtIndex: i];
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
                [tmpUdfArray addObject:udfDetails];


            }
            else if([udfType isEqualToString:NUMERIC_UDF_TYPE])
            {
                NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                int defaultDecimalValue=[[udfDict objectForKey:@"defaultDecimalValue"] intValue];
                EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                [udfDetails setSystemDefaultValue:systemDefaultValue];
                [udfDetails setFieldName:udfName];
                [udfDetails setFieldType:UDFType_NUMERIC];
                [udfDetails setFieldValue:defaultValue];
                [udfDetails setUdfIdentity:udfUri];
                [udfDetails setDecimalPoints:defaultDecimalValue];
                [tmpUdfArray addObject:udfDetails];


            }
            else if ([udfType isEqualToString:DATE_UDF_TYPE])
            {
                NSString *defaultValue=nil;
                id tempDefaultValue=[udfDict objectForKey:@"defaultValue"];
                if ([tempDefaultValue isKindOfClass:[NSString class]] && ([tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]||[tempDefaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]))
                {

                    defaultValue=RPLocalizedString(SELECT_STRING, @"");
                }
                else{

                    defaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:tempDefaultValue]];

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
                [tmpUdfArray addObject:udfDetails];



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
                [tmpUdfArray addObject:udfDetails];

            }

        }
        NSMutableArray *tmpArray=[NSMutableArray array];

        NSString *clientID=[Util getRandomGUID];

        [timePunchesArr addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"",@"in_time",@"",@"out_time",@"",@"comments",tmpUdfArray,@"udfArray",@"",@"timePunchesUri",clientID,@"clientID", nil]];
        tsEntryObject.timePunchesArray=timePunchesArr;

        [tsEntryObject setMultiDayInOutEntry:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"",@"in_time",@"",@"out_time",@"",@"comments",tmpUdfArray,@"udfArray",@"",@"timePunchesUri",clientID,@"clientID", nil]];

        InOutTimesheetEntry *inoutTsObj=[[InOutTimesheetEntry alloc] init];
        [inoutTsObj intializeWithStartAndEndTime];
        [tmpArray addObject:inoutTsObj];
        [self.inoutTsObjectsArray addObject:tmpArray];

    }

    [self.timesheetEntryObjectArray addObject:tsEntryObject];




}

-(void) cellClickedAtIndex:(NSInteger)row andSection:(NSInteger)section
{
    self.isNavigation=TRUE;
    ExtendedInOutEntryViewController *extendedInOutEntryViewController=[[ExtendedInOutEntryViewController alloc]init];
    if (section<timesheetEntryObjectArray.count)
    {
        TimesheetEntryObject *tsEntryObject=[timesheetEntryObjectArray objectAtIndex:section];
        BOOL isProject=NO;
        BOOL isActivityAccess=NO;
        BOOL isBillingAccess=NO;
        //Mobi-569 Ullas M L
        UIViewController *controllerViewCtrl=(UIViewController *)controllerDelegate;

        if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
        {
            ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
            TimesheetMainPageController *controllerViewCtrl=(TimesheetMainPageController *)controllerDelegate;
            ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)[controllerViewCtrl parentDelegate];
            if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                if ([self.timesheetEntryObjectArray count]>0)
                {
                    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:0];
                    NSString *sheetIdentity=[tsEntryObject timesheetUri];
                    if (sheetIdentity!=nil && ![sheetIdentity isKindOfClass:[NSNull class]])
                    {

                        isProject=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:sheetIdentity];
                        isActivityAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:sheetIdentity];
                        isBillingAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:sheetIdentity];

                    }

                }
                self.timesheetFormat=[approvalModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:YES];
            }
            else
            {
                if ([self.timesheetEntryObjectArray count]>0)
                {
                    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:0];
                    NSString *sheetIdentity=[tsEntryObject timesheetUri];
                    if (sheetIdentity!=nil && ![sheetIdentity isKindOfClass:[NSNull class]])
                    {

                        isProject=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:sheetIdentity];
                        isActivityAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:sheetIdentity];
                        isBillingAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:sheetIdentity];

                    }

                }
                self.timesheetFormat=[approvalModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:NO];

            }



        }
        //User context Flow for timesheets
        else if([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
        {

            TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
            isProject=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetURI];

            isActivityAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetURI];
            isBillingAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:timesheetURI];
            self.timesheetFormat=[timesheetModel getTimesheetFormatforTimesheetUri:timesheetURI];

        }

        if (self.isGen4UserTimesheet) {
            SupportDataModel *supportModel=[[SupportDataModel alloc]init];
            NSDictionary *dict=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
            if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
            {
                if([self.timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                {
                    isProject=[[dict objectForKey:@"allowProjectsTasksForExtInOutGen4"] boolValue];
                    isActivityAccess=[[dict objectForKey:@"allowActivitiesForExtInOutGen4"] boolValue];
                    //            isClientAccess=[[dict objectForKey:@"allowClientsForExtInOutGen4"] boolValue];
                    isBillingAccess=[[dict objectForKey:@"allowBillingForExtInOutGen4"] boolValue];
                    //            isProgramAccess=[[dict objectForKey:@"allowProgramsForExtInOutGen4"] boolValue];
                }
            }


        }

        LoginModel *loginModel=[[LoginModel alloc]init];

        extendedInOutEntryViewController.currentPageDate=self.currentPageDate;
        extendedInOutEntryViewController.tsEntryObject=tsEntryObject;
        extendedInOutEntryViewController.isProjectAccess=isProject;
        extendedInOutEntryViewController.isActivityAccess=isActivityAccess;
        extendedInOutEntryViewController.isBillingAccess=isBillingAccess;
        extendedInOutEntryViewController.row=row;
        extendedInOutEntryViewController.section=section;
        extendedInOutEntryViewController.commentsControlDelegate=self;
        BOOL isEditState=YES;
        if ([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
            [multiDayTimesheetStatus isEqualToString:APPROVED_STATUS ]|| [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] ||
            [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED] ||
            [multiDayTimesheetStatus isEqualToString:TIMESHEET_CONFLICTED])
        {
            isEditState=NO;
        }
        //ImplementationForExtendedInOutDeleteBreak_US9103//JUHI
        BOOL isBreak=NO;
        if (tsEntryObject.breakUri!=nil && ![tsEntryObject.breakUri isKindOfClass:[NSNull class]]&&![tsEntryObject.breakUri isEqualToString:@""])
        {
            if (isGen4UserTimesheet)
            {
                SupportDataModel *supportModel=[[SupportDataModel alloc]init];
                NSDictionary *dict=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
                if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
                {
                    if([self.timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                    {
                        isBreak=[[dict objectForKey:@"allowBreakForExtInOutGen4"] boolValue];
                    }
                    else if([self.timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET])
                    {
                        isBreak=[[dict objectForKey:@"allowBreakForInOutGen4"] boolValue];
                    }
                }


            }
            else
            {
                isBreak=[loginModel getStatusForGivenPermissions:@"hasTimesheetBreakAccess"];
            }
            
            extendedInOutEntryViewController.isBreakAccess=isBreak;
        }
        extendedInOutEntryViewController.isEditState=isEditState;
        extendedInOutEntryViewController.isGen4UserTimesheet=isGen4UserTimesheet;
        extendedInOutEntryViewController.timesheetFormat=self.timesheetFormat;
        InOutTimesheetEntry *tmpObj=[self createInOutTimesheetobjectArrayForMultiInoutObject:tsEntryObject forRow:row];
        extendedInOutEntryViewController.hours=tmpObj.hours;
        [self.lastUsedTextField resignFirstResponder];
        [self.navigationController pushViewController:extendedInOutEntryViewController animated:YES];
    }


}
-(void) cellDidFinishEditing:(ExtendedInOutCell*)entryCell
{
    NSIndexPath* cellIndexPath = [self.multiDayTimeEntryTableView indexPathForCell:entryCell];

    TimesheetEntryObject *tsEntryObj=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:entryCell.cellSection];
    BOOL isBreak=NO;
    NSString *breakUri=[tsEntryObj breakUri];
    if (breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]]&& ![breakUri isEqualToString:@""]) {
        isBreak=YES;
    }
    BOOL isEmptyRowPresentOnTheDay=NO;
    for (int k=0; k<[timesheetEntryObjectArray count]; k++) {
        TimesheetEntryObject *entryObj=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:k];

        BOOL isBreakEntry=NO;
        NSString *breakUri=[entryObj breakUri];
        if (breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]]&& ![breakUri isEqualToString:@""]) {
            isBreakEntry=YES;
        }
        if (!isBreakEntry && [[entryObj timePunchesArray] count]>0)
        {
            BOOL isInTimeEmpty=NO;
            BOOL isOutTimeEmpty=NO;
            NSString *in_time=[[[entryObj timePunchesArray] objectAtIndex:0] objectForKey:@"in_time"];
            NSString *out_time=[[[entryObj timePunchesArray] objectAtIndex:0] objectForKey:@"out_time"];
            if (in_time==nil||[in_time isKindOfClass:[NSNull class]]||[in_time isEqualToString:@""])
            {
                isInTimeEmpty=YES;
            }
            if (out_time==nil||[out_time isKindOfClass:[NSNull class]]||[out_time isEqualToString:@""])
            {
                isOutTimeEmpty=YES;
            }
            if (isOutTimeEmpty && isInTimeEmpty)
            {
                isEmptyRowPresentOnTheDay=YES;
            }
        }
    }
    
    NSInteger selectedCell = entryCell.cellSection;
    BOOL isInOutWidgetTimesheet = [self isInOutWidgetTimesheet];
    BOOL isLastRow = ( [timesheetEntryObjectArray count] == selectedCell+1);
    if (isInOutWidgetTimesheet && isLastRow) {
        isEmptyRowPresentOnTheDay =  NO;
    }

    if(cellIndexPath.row == [[tsEntryObj timePunchesArray ] count] && !isBreak && !isEmptyRowPresentOnTheDay)
    {


        if (isGen4UserTimesheet && (![self.timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET] || isInOutWidgetTimesheet ))
        {

            [self addEmptyEntryOnSectionIndex:entryCell.cellSection];
            numberofExtendedInOutRows=1;//[[tsEntryObj timePunchesArray ] count];
            NSIndexPath* newIndex = [NSIndexPath indexPathForRow:numberofExtendedInOutRows inSection:entryCell.cellSection];
            [self.multiDayTimeEntryTableView insertSections:[NSIndexSet indexSetWithIndex:entryCell.cellSection+1] withRowAnimation:UITableViewRowAnimationTop];
            [self.multiDayTimeEntryTableView scrollToRowAtIndexPath:newIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        else{

            if (entryCell._inTxt) {
                [entryCell._inTxt resignFirstResponder];
            }
            if (entryCell._outTxt) {
                [entryCell._outTxt resignFirstResponder];
            }
        }

        if(self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
        {
            if (isGen4UserTimesheet && (![self.timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET] || isInOutWidgetTimesheet ))
            {
                if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
                {
                }
                BOOL emptyEntryPresent=NO;
                NSDate *entryDate=nil;
                NSString *clientPunchID=nil;

                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:entryCell.cellSection+1];
                NSString *timePunchesUri=[[[tsEntryObject timePunchesArray] objectAtIndex:numberofExtendedInOutRows-1] objectForKey:@"timePunchesUri"];
                NSString *clientID=[[[tsEntryObject timePunchesArray] objectAtIndex:numberofExtendedInOutRows-1] objectForKey:@"clientID"];

                NSString *entryUri = timePunchesUri != nil  && timePunchesUri != (id)[NSNull null] && ![timePunchesUri isEqualToString:@""] ? timePunchesUri : clientID;
                NSString *entryUriColumnName = timePunchesUri != nil  && timePunchesUri != (id)[NSNull null] && ![timePunchesUri isEqualToString:@""]  ? @"timePunchesUri" : @"clientPunchId";

                if (timePunchesUri==nil||[timePunchesUri isKindOfClass:[NSNull class]]||[timePunchesUri isEqualToString:@""])
                {
                    emptyEntryPresent=YES;
                    entryDate=[tsEntryObject timeEntryDate];
                    clientPunchID=clientID;
                }
                BOOL isWorkEntry=NO;
                NSString *breakUri=[tsEntryObject breakUri];
                if (breakUri==nil||[breakUri isKindOfClass:[NSNull class]]||[breakUri isEqualToString:@""]||[breakUri isEqualToString:NULL_STRING])
                {
                    isWorkEntry=YES;
                }
                if (emptyEntryPresent)
                {
                    //send request

                    isGen4RequestInQueue=YES;
                    if (isWorkEntry)
                    {
                        [[NSNotificationCenter defaultCenter] removeObserver:self name:SAVE_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
                        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gen4TimeEntrySaveResponseReceived:) name:SAVE_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
                        [[RepliconServiceManager timesheetService] sendRequestToSaveWorkTimeEntryForGen4:self withClientID:entryUri isBlankTimeEntrySave:YES withTimeEntryUri:nil withStartDate:entryDate forTimeSheetUri:self.timesheetURI withTimeDict:nil timesheetFormat:self.timesheetFormat andColumnNameForEntryUri:entryUriColumnName];
                        [self updateUserChangedFlag];
                    }
                    else
                    {
                        [[NSNotificationCenter defaultCenter] removeObserver:self name:SAVE_BREAK_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
                        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gen4BreakEntrySaveResponseReceived:) name:SAVE_BREAK_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
                        [[RepliconServiceManager timesheetService] sendRequestToSaveBreakTimeEntryForGen4:self withBreakUri:breakUri isBlankTimeEntrySave:YES withTimeEntryUri:nil withStartDate:entryDate forTimeSheetUri:self.timesheetURI withTimeDict:nil withClientID:entryUri withBreakName:[tsEntryObject breakName] timesheetFormat:self.timesheetFormat andColumnNameForEntryUri:entryUriColumnName];
                        [self updateUserChangedFlag];
                    }
                    
                }
                
            }
        }



    }
    else if(isBreak)
    {
        [self resetTableSizeForExtendedInOut:NO];
    }
    [self calculateAndUpdateTotalHoursValueForFooter];


}

-(void) willJumpToNextCell:(ExtendedInOutCell *)entryCell
{
    CGFloat yOffset = 0;
    
    if (self.multiDayTimeEntryTableView.contentSize.height > self.multiDayTimeEntryTableView.bounds.size.height) {
        yOffset = self.multiDayTimeEntryTableView.contentSize.height - self.multiDayTimeEntryTableView.bounds.size.height;
    }
    [self.multiDayTimeEntryTableView setContentOffset:CGPointMake(0, yOffset) animated:NO];
    
    BOOL isInTimeEmpty=NO;
    BOOL isOutTimeEmpty=NO;
    if ([timesheetEntryObjectArray count]>entryCell.cellSection+1)
    {
        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:entryCell.cellSection+1];
        if ([[tsEntryObject timePunchesArray] count]>0)
        {
            NSString *in_time=[[[tsEntryObject timePunchesArray] objectAtIndex:0] objectForKey:@"in_time"];
            NSString *out_time=[[[tsEntryObject timePunchesArray] objectAtIndex:0] objectForKey:@"out_time"];
            if (in_time==nil||[in_time isKindOfClass:[NSNull class]]||[in_time isEqualToString:@""])
            {
                isInTimeEmpty=YES;
            }
            if (out_time==nil||[out_time isKindOfClass:[NSNull class]]||[out_time isEqualToString:@""])
            {
                isOutTimeEmpty=YES;
            }

        }
    }



    if (isInTimeEmpty||isOutTimeEmpty)
    {
        NSIndexPath* nextCellIndex = [NSIndexPath indexPathForRow:entryCell.cellRow inSection:entryCell.cellSection+1];
        //NSIndexPath* cellIndexPath = [self.multiDayTimeEntryTableView indexPathForCell:entryCell];

        ExtendedInOutCell* nextCell = (ExtendedInOutCell*)[self.multiDayTimeEntryTableView cellForRowAtIndexPath:nextCellIndex];
        if(nextCell)
        {
            if (isInTimeEmpty)
            {
                [nextCell setInTimeFocus];
            }
        }
    }
    else
    {

        if (timesheetEntryObjectArray.count>1)
        {
            NSUInteger arrayCount = [timesheetEntryObjectArray count];
            BOOL isLastRow = (arrayCount ==  entryCell.cellSection+1);
            if (!isLastRow) {
                NSIndexPath* nextCellIndex = [NSIndexPath indexPathForRow:entryCell.cellRow inSection:timesheetEntryObjectArray.count-1];
                
                ExtendedInOutCell* nextCell = (ExtendedInOutCell*)[self.multiDayTimeEntryTableView cellForRowAtIndexPath:nextCellIndex];
                if(nextCell)
                {
                    [nextCell setInTimeFocus];
                }
            }
        }
        else
        {
            [entryCell._inTxt resignFirstResponder];
            [entryCell._outTxt resignFirstResponder];
        }

    }


    [self calculateAndUpdateTotalHoursValueForFooter];
}


-(void) cellDidBeginEditing:(ExtendedInOutCell *)entryCell
{
    [self resetTableSizeForExtendedInOut:YES];
    
    NSIndexPath* nextCellIndex = [NSIndexPath indexPathForRow:entryCell.cellRow inSection:entryCell.cellSection];
    self.currentlyBeingEditedCellIndexpath=nextCellIndex;
    [self.multiDayTimeEntryTableView scrollToRowAtIndexPath:nextCellIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void)updateExtendedInOutTimeEntryForIndex:(NSInteger)rowIndex forSection:(NSInteger)sectionIndex withValue:(NSMutableDictionary *)multiInoutEntry sendRequest:(BOOL)isSendRequest
{
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;
        tsMainPageCtrl.hasUserChangedAnyValue=YES;
        [self changeParentViewLeftBarbutton];
        if (tsMainPageCtrl.pageControl.currentPage<tsMainPageCtrl.timesheetDataArray.count)
        {
            NSMutableArray *array=[tsMainPageCtrl.timesheetDataArray objectAtIndex:tsMainPageCtrl.pageControl.currentPage];

            if (sectionIndex < [array count])
            {
                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[array objectAtIndex:sectionIndex];

                NSString *clientName=tsEntryObject.timeEntryClientName;
                NSString *clientUri=tsEntryObject.timeEntryClientUri;
                NSString *projectName=tsEntryObject.timeEntryProjectName;
                NSString *projectUri=tsEntryObject.timeEntryProjectUri;
                NSString *taskName=tsEntryObject.timeEntryTaskName;
                NSString *taskUri=tsEntryObject.timeEntryTaskUri;
                NSString *activityName=tsEntryObject.timeEntryActivityName;
                NSString *activityUri=tsEntryObject.timeEntryActivityUri;
                NSString *timeOffName=tsEntryObject.timeEntryTimeOffName;
                NSString *timeOffUri=tsEntryObject.timeEntryTimeOffUri;
                NSString *billingName=tsEntryObject.timeEntryBillingName;
                NSString *billingUri=tsEntryObject.timeEntryBillingUri;
                NSString *hoursInHourFormat=tsEntryObject.timeEntryHoursInHourFormat;
                NSString *comments=tsEntryObject.timeEntryComments;
                NSMutableArray *udfArray=tsEntryObject.timeEntryUdfArray;
                NSString *punchUri=tsEntryObject.timePunchUri;
                NSString *allocationUri=tsEntryObject.timeAllocationUri;
                NSString *entryType=tsEntryObject.entryType;
                NSDate *entryDate=tsEntryObject.timeEntryDate;
                BOOL isTimeoffSickRowPresent=tsEntryObject.isTimeoffSickRowPresent;
                NSString *timesheetUri=tsEntryObject.timesheetUri;
                //Implentation for US8956//JUHI
                NSString *breakName=tsEntryObject.breakName;
                NSString *breakUri=tsEntryObject.breakUri;
                NSString *programName=tsEntryObject.timeEntryProgramName;
                NSString *programUri=tsEntryObject.timeEntryProgramUri;
                NSString *rowUri=tsEntryObject.rowUri;


                TimesheetEntryObject *tsTempEntryObject=[[TimesheetEntryObject alloc] init];
                //MOBI-746
                [tsTempEntryObject setTimeEntryProgramUri:programUri];
                [tsTempEntryObject setTimeEntryProgramName:programName];
                [tsTempEntryObject setTimeEntryClientName:clientName];
                [tsTempEntryObject setTimeEntryClientUri:clientUri];
                [tsTempEntryObject setTimeEntryProjectName:projectName];
                [tsTempEntryObject setTimeEntryProjectUri:projectUri];
                [tsTempEntryObject setTimeEntryTaskName:taskName];
                [tsTempEntryObject setTimeEntryTaskUri:taskUri];
                [tsTempEntryObject setTimeEntryActivityName:activityName];
                [tsTempEntryObject setTimeEntryActivityUri:activityUri];
                [tsTempEntryObject setTimeEntryTimeOffName:timeOffName];
                [tsTempEntryObject setTimeEntryTimeOffUri:timeOffUri];
                [tsTempEntryObject setTimeEntryBillingName:billingName];
                [tsTempEntryObject setTimeEntryBillingUri:billingUri];
                [tsTempEntryObject setTimeEntryHoursInHourFormat:hoursInHourFormat];
                [tsTempEntryObject setTimeEntryComments:comments];
                if (isGen4UserTimesheet)
                {
                    [tsTempEntryObject setTimeEntryCellOEFArray:tsEntryObject.timeEntryCellOEFArray];
                }
                else
                {
                    [tsTempEntryObject setTimeEntryUdfArray:udfArray];
                }

                [tsTempEntryObject setMultiDayInOutEntry:multiInoutEntry];
                [tsTempEntryObject setTimePunchUri:punchUri];
                [tsTempEntryObject setTimeAllocationUri:allocationUri];
                [tsTempEntryObject setTimeEntryDate:entryDate];
                [tsTempEntryObject setIsTimeoffSickRowPresent:isTimeoffSickRowPresent];
                [tsTempEntryObject setEntryType:entryType];
                [tsTempEntryObject setTimesheetUri:timesheetUri];
                //Implentation for US8956//JUHI
                [tsTempEntryObject setBreakName:breakName];
                [tsTempEntryObject setBreakUri:breakUri];
                [tsTempEntryObject setRowUri:rowUri];

                NSMutableArray *punchArray=[NSMutableArray arrayWithArray:tsEntryObject.timePunchesArray];
                NSString *timePunchUri=[[punchArray objectAtIndex:rowIndex] objectForKey:@"timePunchesUri"];
                NSString *clientPunchID=[[punchArray objectAtIndex:rowIndex] objectForKey:@"clientID"];

                NSString *entryUri = timePunchUri != nil  && timePunchUri != (id)[NSNull null] && ![timePunchUri isEqualToString:@""] ? timePunchUri : clientPunchID;
                NSString *entryUriColumnName = timePunchUri != nil  && timePunchUri != (id)[NSNull null] && ![timePunchUri isEqualToString:@""]  ? @"timePunchesUri" : @"clientPunchId";

                if (timePunchUri==nil ||[timePunchUri isKindOfClass:[NSNull class]]||[timePunchUri isEqualToString:@""])
                {
                    timePunchUri=@"";
                }
                if (clientPunchID==nil ||[clientPunchID isKindOfClass:[NSNull class]]||[clientPunchID isEqualToString:@""])
                {
                    clientPunchID=@"";
                }

                if (multiInOutTimesheetType==EXTENDED_IN_OUT_TIMESHEET_TYPE)
                {
                    NSMutableArray *tmpArray=[inoutTsObjectsArray objectAtIndex:sectionIndex];
                    [tmpArray replaceObjectAtIndex:rowIndex withObject:[self createInOutTimesheetobjectArrayForMultiInoutDictionaryObject:multiInoutEntry]];
                    [self.inoutTsObjectsArray replaceObjectAtIndex:sectionIndex withObject:tmpArray];

                }
                NSMutableArray *tmpUdfArray=[[punchArray objectAtIndex:rowIndex] objectForKey:@"udfArray"];
                NSString *commentsSave=[[punchArray objectAtIndex:rowIndex] objectForKey:@"comments"];
                NSString *timePunchesUri=[[punchArray objectAtIndex:rowIndex] objectForKey:@"timePunchesUri"];
                if (tmpUdfArray!=nil && [tmpUdfArray count]!=0)
                {
                    [multiInoutEntry setObject:tmpUdfArray forKey:@"udfArray"];
                }
                if (commentsSave==nil ||[commentsSave isKindOfClass:[NSNull class]] || [commentsSave isEqualToString:@""]|| [commentsSave isEqualToString:NULL_STRING])
                {
                    [multiInoutEntry setObject:@"" forKey:@"comments"];
                }
                else
                {
                    [multiInoutEntry setObject:commentsSave forKey:@"comments"];
                }
                if (timePunchesUri==nil ||[timePunchesUri isKindOfClass:[NSNull class]] || [timePunchesUri isEqualToString:@""]|| [timePunchesUri isEqualToString:NULL_STRING])
                {
                    //[multiInoutEntry setObject:@"" forKey:@"timePunchesUri"];
                }
                else
                {
                    [multiInoutEntry setObject:timePunchesUri forKey:@"timePunchesUri"];
                }
                [multiInoutEntry setObject:clientPunchID forKey:@"clientID"];
                [punchArray replaceObjectAtIndex:rowIndex withObject:multiInoutEntry];
                [tsTempEntryObject setTimePunchesArray:punchArray];
                if (isGen4UserTimesheet && isSendRequest && isGen4RequestInQueue && !isNavigation)
                {

                    isGen4RequestInQueue=YES;

                    if (breakUri==nil||[breakUri isKindOfClass:[NSNull class]]||[breakUri isEqualToString:@""])
                    {
                        [[NSNotificationCenter defaultCenter] removeObserver:self name:SAVE_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
                        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gen4TimeEntrySaveResponseReceived:) name:SAVE_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
                        [[RepliconServiceManager timesheetService] sendRequestToSaveWorkTimeEntryForGen4:self withClientID:entryUri isBlankTimeEntrySave:NO withTimeEntryUri:timePunchUri withStartDate:entryDate forTimeSheetUri:self.timesheetURI withTimeDict:[punchArray objectAtIndex:rowIndex] timesheetFormat:self.timesheetFormat andColumnNameForEntryUri:entryUriColumnName];
                        [self updateUserChangedFlag];
                    }
                    else
                    {

                        [[NSNotificationCenter defaultCenter] removeObserver:self name:SAVE_BREAK_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
                        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gen4BreakEntrySaveResponseReceived:) name:SAVE_BREAK_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
                        [[RepliconServiceManager timesheetService] sendRequestToSaveBreakTimeEntryForGen4:self withBreakUri:breakUri isBlankTimeEntrySave:NO withTimeEntryUri:timePunchUri withStartDate:entryDate forTimeSheetUri:timesheetURI withTimeDict:[punchArray objectAtIndex:rowIndex] withClientID:entryUri withBreakName:breakName timesheetFormat:self.timesheetFormat andColumnNameForEntryUri:entryUriColumnName];
                        [self updateUserChangedFlag];
                    }
                    
                    
                }
                
                NSMutableDictionary *returnDict=[self returnTotalCalculatedHoursForObject:tsEntryObject];
                [tsTempEntryObject setTimeEntryHoursInDecimalFormat:@"WithRoundoff"];
                [tsTempEntryObject setTimeEntryHoursInDecimalFormatWithOutRoundOff:[returnDict objectForKey:@"WithoutRoundoff"]];
                
                [array replaceObjectAtIndex:sectionIndex withObject:tsTempEntryObject];
                [tsMainPageCtrl.timesheetDataArray replaceObjectAtIndex:tsMainPageCtrl.pageControl.currentPage withObject:array];
            }

        }
    }


}
-(NSMutableDictionary *)returnTotalCalculatedHoursForObject:(TimesheetEntryObject *)tsEntryObject
{

    NSArray *timePunchesArr=[tsEntryObject timePunchesArray];
    double totalHours=0;
    double w_o_RoundedTotalHours=0;
    for (int count=0; count<[timePunchesArr count]; count++)
    {
        NSDictionary *punchDict=[timePunchesArr objectAtIndex:count];

        NSString *tempTime_in=[punchDict objectForKey:@"in_time"];
        NSString *temp_Time_out=[punchDict objectForKey:@"out_time"];
        NSString *time_in=[punchDict objectForKey:@"in_time"];
        NSString *time_out=[punchDict objectForKey:@"out_time"];

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


        if (time_in!=nil && ![time_in isKindOfClass:[NSNull class]]&& ![time_in isEqualToString:@""] && time_out!=nil && ![time_out isKindOfClass:[NSNull class]]&& ![time_out isEqualToString:@""])
        {
            totalHours=totalHours+[[Util getNumberOfHoursForInTime:tempTime_in outTime:temp_Time_out]newDoubleValue];
            w_o_RoundedTotalHours=w_o_RoundedTotalHours+[[Util getNumberOfHoursWithoutRoundingForInTime:tempTime_in outTime:temp_Time_out]newDoubleValue];
        }



    }

    [tsEntryObject setTimeEntryHoursInDecimalFormat:[NSString stringWithFormat:@"%f",totalHours]];
    [tsEntryObject setTimeEntryHoursInDecimalFormatWithOutRoundOff:[NSString stringWithFormat:@"%f",w_o_RoundedTotalHours]];

    NSMutableDictionary *returnDict=[NSMutableDictionary dictionary];
    [returnDict setObject:[tsEntryObject timeEntryHoursInDecimalFormat] forKey:@"WithoutRoundoff"];
    [returnDict setObject:[tsEntryObject timeEntryHoursInDecimalFormatWithOutRoundOff] forKey:@"WithRoundoff"];

    return returnDict;


}
-(void)resetTableSizeForExtendedInOut:(BOOL)isResetTable
{
    CGFloat width = CGRectGetWidth([[UIScreen mainScreen] bounds]);


    if (isResetTable)
    {
        self.multiDayTimeEntryTableView.frame = CGRectMake(0, Total_Hours_Footer_Height_42, width, [self heightForTableView]  - 200 -50.0f);
    }
    else
    {
        self.multiDayTimeEntryTableView.frame = CGRectMake(0, Total_Hours_Footer_Height_42, width, [self heightForTableView] - Total_Hours_Footer_Height_42 -50.0f);
    }
}

-(void)projectEditButtonIconClickedForSection:(NSInteger)index
{
    CLS_LOG(@"-----Edit project action on MultiDayInOutViewController -----");
    [self hidekeyboard];

    TimesheetModel *timesheetModel = [[TimesheetModel alloc]init];
    if (![timesheetModel isTimesheetContainsInflightSaveOperation:timesheetURI])
    {
        BOOL isEditState=YES;
        if ([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
            [multiDayTimesheetStatus isEqualToString:APPROVED_STATUS ]|| [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] ||
            [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED] ||
            [multiDayTimesheetStatus isEqualToString:TIMESHEET_CONFLICTED])
        {
            isEditState=NO;
        }

        if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]] && isEditState)
        {
            TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;
            tsMainPageCtrl.isEditForGen4InQueue=YES;
            if (tsMainPageCtrl.pageControl.currentPage<tsMainPageCtrl.timesheetDataArray.count)
            {
                NSMutableArray *array=[tsMainPageCtrl.timesheetDataArray objectAtIndex:tsMainPageCtrl.pageControl.currentPage];
                if (index<array.count)
                {
                    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[array objectAtIndex:index];
                    NSString *projectName=tsEntryObject.timeEntryProjectName;
                    NSString *projectUri=tsEntryObject.timeEntryProjectUri;
                    //MOBI-746
                    NSString *programName=tsEntryObject.timeEntryProgramName;
                    NSString *programUri=tsEntryObject.timeEntryProgramUri;

                    NSString *clientName=tsEntryObject.timeEntryClientName;
                    NSString *clientUri=tsEntryObject.timeEntryClientUri;
                    NSString *taskName=tsEntryObject.timeEntryTaskName;
                    NSString *taskUri=tsEntryObject.timeEntryTaskUri;
                    NSString *activityName=tsEntryObject.timeEntryActivityName;
                    NSString *activityUri=tsEntryObject.timeEntryActivityUri;
                    NSString *billingName=tsEntryObject.timeEntryBillingName;
                    NSString *billingUri=tsEntryObject.timeEntryBillingUri;
                    NSString *timesheetUri=tsEntryObject.timesheetUri;
                    NSString *rowUri=[tsEntryObject timePunchUri];
                    //Implentation for US8956//JUHI
                    NSString *breakName=[tsEntryObject breakName];
                    NSString *breaUri=[tsEntryObject breakUri];
                    //Implementation as per US9109//JUHI

                    NSString *timeoffName=[tsEntryObject timeEntryTimeOffName];
                    NSString *timeoffUri=[tsEntryObject timeEntryTimeOffUri];

                    TimeEntryViewController *timeEntryVC=[[TimeEntryViewController alloc] init];
                    timeEntryVC.delegate=controllerDelegate;
                    timeEntryVC.controllerDelegate=self;
                    TimesheetObject *timesheetObject=[[TimesheetObject alloc] init];
                    if (programUri == nil || [programUri isKindOfClass:[NSNull class]]||[programUri isEqualToString:@""])
                    {
                        programUri=nil;
                    }
                    else
                    {
                        [timesheetObject setProgramName:programName];
                        [timesheetObject setProgramIdentity: programUri];
                    }
                    if (clientUri == nil || [clientUri isKindOfClass:[NSNull class]]||[clientUri isEqualToString:@""])
                    {
                        clientUri=nil;
                    }
                    else
                    {
                        [timesheetObject setClientName:clientName];
                        [timesheetObject setClientIdentity: clientUri];
                    }
                    if (projectUri == nil || [projectUri isKindOfClass:[NSNull class]]||[projectUri isEqualToString:@""])
                    {
                        projectUri=nil;
                    }
                    else
                    {
                        [timesheetObject setProjectName:projectName];
                        [timesheetObject setProjectIdentity: projectUri];
                    }
                    if (taskUri == nil || [taskUri isKindOfClass:[NSNull class]]||[taskUri isEqualToString:@""])
                    {
                        taskUri=nil;
                    }
                    else
                    {
                        [timesheetObject setTaskName: taskName];
                        [timesheetObject setTaskIdentity: taskUri];
                    }
                    if (billingUri == nil || [billingUri isKindOfClass:[NSNull class]]||[billingUri isEqualToString:@""])
                    {
                        billingUri=nil;
                    }
                    else
                    {
                        [timesheetObject setBillingName: billingName];
                        [timesheetObject setBillingIdentity:billingUri];

                    }
                    if (activityUri == nil || [activityUri isKindOfClass:[NSNull class]]||[activityUri isEqualToString:@""])
                    {
                        activityUri=nil;
                    }
                    else
                    {
                        [timesheetObject setActivityName:activityName];
                        [timesheetObject setActivityIdentity:activityUri];
                    }
                    //Implentation for US8956//JUHI
                    if (breaUri == nil || [breaUri isKindOfClass:[NSNull class]]||[breaUri isEqualToString:@""])
                    {
                        breaUri=nil;
                    }
                    else
                    {
                        [timesheetObject setBreakName:breakName];
                        [timesheetObject setBreakUri:breaUri];
                    }//Implementation as per US9109//JUHI
                    if (timeoffUri == nil || [timeoffUri isKindOfClass:[NSNull class]]||[timeoffUri isEqualToString:@""])
                    {
                        timeoffUri=nil;
                    }
                    else
                    {
                        [timesheetObject setTimeOffName:timeoffName];
                        [timesheetObject setTimeOffIdentity:timeoffUri];
                    }
                    [timesheetObject setTimesheetURI:timesheetUri];
                    timeEntryVC.timesheetObject=timesheetObject;


                    timeEntryVC.approvalsModuleName=nil;
                    if ([multiDayTimesheetStatus isEqualToString:NOT_SUBMITTED_STATUS]||[multiDayTimesheetStatus isEqualToString:REJECTED_STATUS])
                    {
                        timeEntryVC.screenViewMode=EDIT_PROJECT_ENTRY;
                    }
                    else
                    {
                        timeEntryVC.screenViewMode=VIEW_PROJECT_ENTRY;
                    }
                    timeEntryVC.timesheetDataArray=self.timesheetDataArray;
                    timeEntryVC.timesheetStatus=multiDayTimesheetStatus;
                    timeEntryVC.rowUriBeingEdited=rowUri;
                    timeEntryVC.timesheetURI=timesheetUri;
                    timeEntryVC.isMultiDayInOutTimesheetUser=YES;
                    timeEntryVC.isExtendedInOutTimesheet=YES;
                    timeEntryVC.approvalsModuleName=APPROVALS_PENDING_TIMESHEETS_MODULE;
                    timeEntryVC.approvalsModuleName=APPROVALS_PENDING_TIMESHEETS_MODULE;
                    timeEntryVC.indexBeingEdited=index;
                    timeEntryVC.isGen4UserTimesheet=self.isGen4UserTimesheet;
                    //Implentation for US8956//JUHI
                    if (breaUri==nil||[breaUri isKindOfClass:[NSNull class]])
                    {
                        timeEntryVC.isEditBreak=FALSE;

                    }
                    else if (breaUri!=nil&&![breaUri isKindOfClass:[NSNull class]]&&![breaUri isEqualToString:@""]&& ([multiDayTimesheetStatus isEqualToString:NOT_SUBMITTED_STATUS]||[multiDayTimesheetStatus isEqualToString:REJECTED_STATUS]))
                    {
                        timeEntryVC.isEditBreak=FALSE;
                        timeEntryVC.selectedBreakString=breakName;
                        timeEntryVC.screenMode=EDIT_BREAK_ENTRY;
                        timeEntryVC._hasTimesheetTimeoffAccess=FALSE;
                    }
                    if ((breaUri!=nil&&![breaUri isKindOfClass:[NSNull class]]&&![breaUri isEqualToString:@""] && ([multiDayTimesheetStatus isEqualToString:NOT_SUBMITTED_STATUS]||[multiDayTimesheetStatus isEqualToString:REJECTED_STATUS]))||(breaUri==nil||[breaUri isKindOfClass:[NSNull class]]||[breaUri isEqualToString:@""])) {
                        if (timeoffUri!=nil&&![timeoffUri isKindOfClass:[NSNull class]]&&![timeoffUri isEqualToString:@""]&& ([multiDayTimesheetStatus isEqualToString:NOT_SUBMITTED_STATUS]||[multiDayTimesheetStatus isEqualToString:REJECTED_STATUS])) {
                            timeEntryVC.isEditBreak=FALSE;
                            timeEntryVC.selectedTimeoffString=timeoffName;
                            timeEntryVC.screenMode=EDIT_Timeoff_ENTRY;
                            SupportDataModel *supportDataModel = [[SupportDataModel alloc] init];
                            NSMutableArray *userDetailsArr=[supportDataModel getUserDetailsFromDatabase];



                            BOOL _hasTimesheetTimeoffAccess        = FALSE;

                            if (userDetailsArr!=nil && ![userDetailsArr isKindOfClass:[NSNull class]])
                            {
                                NSDictionary *userDetailsDict=[userDetailsArr objectAtIndex:0];
                                _hasTimesheetTimeoffAccess        = [[userDetailsDict objectForKey:@"hasTimesheetTimeoffAccess"]boolValue];
                            }


                            
                            TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                            NSDictionary *dataDic=[timesheetModel getAvailableTimeOffTypeCountInfoForTimesheetIdentity:self.timesheetURI];
                            
                            
                            int availableTimeOffTypeCount=0;
                            
                            if (dataDic!=nil && ![dataDic isKindOfClass:[NSNull class]])
                            {
                                availableTimeOffTypeCount=[[dataDic objectForKey:@"availableTimeOffTypeCount"]intValue];
                            }
                            timeEntryVC._hasTimesheetTimeoffAccess=_hasTimesheetTimeoffAccess;
                            timeEntryVC.availableTimeOffTypeCount=availableTimeOffTypeCount;
                        }
                        [self.navigationController pushViewController:timeEntryVC animated:YES];
                    }
                }
            }
            
            
            
        }

    }

    else
    {
        [self showINProgressAlertView];
    }

}

-(void)addInOutButtonIconClickedForSection:(NSInteger)index
{
    [self addEmptyEntryOnSectionIndex:index];
    TimesheetEntryObject *tsEntryObject=[timesheetEntryObjectArray objectAtIndex:index];

    //Note the timesheetentryobject already has the empty row now. So row index should be decremented by 1
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:[tsEntryObject.timePunchesArray count] inSection:index];
    [self.multiDayTimeEntryTableView beginUpdates];
    [self.multiDayTimeEntryTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    [self.multiDayTimeEntryTableView endUpdates];

    ExtendedInOutCell *cell= (ExtendedInOutCell *)[self.multiDayTimeEntryTableView cellForRowAtIndexPath:indexPath];
    if (cell==nil || [cell isKindOfClass:[NSNull class]])
    {
        [self.multiDayTimeEntryTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
        [self.multiDayTimeEntryTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                               withRowAnimation:UITableViewRowAnimationBottom];
        cell= (ExtendedInOutCell *)[self.multiDayTimeEntryTableView cellForRowAtIndexPath:indexPath];
    }
    else
    {
        [self.multiDayTimeEntryTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }


    [cell._inTxt becomeFirstResponder];




}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (multiInOutTimesheetType==EXTENDED_IN_OUT_TIMESHEET_TYPE )
    {

        [self resetTableSize:NO isTextFieldOrTextViewClicked:YES isUdfClicked:NO];
        [[self multiDayTimeEntryTableView] setScrollEnabled:YES];
        if ([self isTableRowSelected])
        {
            [self doneAction:YES sender:nil];
        }
        else
        {
            [self doneAction:NO sender:nil];
        }
        [[[UIApplication sharedApplication] keyWindow] endEditing:YES];

    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handleTapAndResetDayScroll];
}

-(void)handleTapAndResetDayScroll
{
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;
        [tsMainPageCtrl resetDayScrollViewPosition];
    }
}
-(void) didTapOnTableView:(UIGestureRecognizer*) recognizer
{
    [self handleTapAndResetDayScroll];
}
-(void) didTapOnSuggestionView:(UIGestureRecognizer*) recognizer
{
    CLS_LOG(@"-----Add a entry from suggestion on MultiDayInOutViewController -----");

    TimesheetModel *timesheetModel = [[TimesheetModel alloc]init];
    if (![timesheetModel isTimesheetContainsInflightSaveOperation:timesheetURI])
    {
        [self handleTapAndResetDayScroll];

        NSMutableArray *suggestionDetailsArray=[self getUniqueSuggestionsArrayFromObjects];
        NSMutableDictionary *suggestionInfodict=[NSMutableDictionary dictionary];
        if (self.isSuggestionTapped)
        {
            if ([recognizer.view tag]<self.suggestionDetailsDBArray.count) {
                suggestionInfodict=[NSMutableDictionary dictionaryWithDictionary:[self.suggestionDetailsDBArray objectAtIndex:[recognizer.view tag]]];
            }

        }
        else
        {
            if ([recognizer.view tag]<suggestionDetailsArray.count)
            {
                suggestionInfodict=[NSMutableDictionary dictionaryWithDictionary:[suggestionDetailsArray objectAtIndex:[recognizer.view tag]]];
            }


        }
        self.isSuggestionTapped=YES;
        NSString *programName=[suggestionInfodict objectForKey:@"programName"];
        NSString *programUri=[suggestionInfodict objectForKey:@"programUri"];
        NSString *clientName=[suggestionInfodict objectForKey:@"clientName"];
        NSString *clientUri=[suggestionInfodict objectForKey:@"clientUri"];
        NSString *projectName=[suggestionInfodict objectForKey:@"projectName"];
        NSString *projectUri=[suggestionInfodict objectForKey:@"projectUri"];
        NSString *taskName=[suggestionInfodict objectForKey:@"taskName"];
        NSString *taskUri=[suggestionInfodict objectForKey:@"taskUri"];
        NSString *activityName=[suggestionInfodict objectForKey:@"activityName"];
        NSString *activityUri=[suggestionInfodict objectForKey:@"activityUri"];
        NSString *billingName=[suggestionInfodict objectForKey:@"billingName"];
        NSString *billingUri=[suggestionInfodict objectForKey:@"billingUri"];
        NSString *breakUri=[suggestionInfodict objectForKey:@"breakUri"];
        NSString *breakName=[suggestionInfodict objectForKey:@"breakName"];

        int tempNumberOfSickRows=0;
        int tempNumberOfInOutRows=0;
        float totalCalculatedHours=0;
        for (int i=0; i<[self.timesheetEntryObjectArray count]; i++)
        {
            TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:i];
            BOOL isTimeoffSickRow=[tsEntryObject isTimeoffSickRowPresent];

            if (isTimeoffSickRow)
            {
                tempNumberOfSickRows++;
            }
            else
            {

                NSString *inTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"in_time"];
                NSString *outTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"out_time"];

                if ([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
                    [multiDayTimesheetStatus isEqualToString:APPROVED_STATUS ]|| [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] ||
                    [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED] ||
                    [multiDayTimesheetStatus isEqualToString:TIMESHEET_CONFLICTED])
                {
                    if ((![inTimeString isKindOfClass:[NSNull class]]&& inTimeString!=nil && ![inTimeString isEqualToString:@""]) || (![outTimeString isKindOfClass:[NSNull class]]&& outTimeString!=nil && ![outTimeString isEqualToString:@""]))
                    {
                        tempNumberOfInOutRows++;
                    }
                }
                else
                {
                    tempNumberOfInOutRows++;
                }


            }


            if (multiInOutTimesheetType==EXTENDED_IN_OUT_TIMESHEET_TYPE)
            {
                if ([[tsEntryObject entryType] isEqualToString:Time_Off_Key]||[[tsEntryObject entryType] isEqualToString:Adhoc_Time_OffKey])
                {
                    float timeEntryHours=[[tsEntryObject timeEntryHoursInDecimalFormatWithOutRoundOff] newFloatValue];
                    totalCalculatedHours=totalCalculatedHours+timeEntryHours;
                }
                else
                {
                    NSMutableArray *punchesArray=[tsEntryObject timePunchesArray];
                    for (int k=0; k<[punchesArray count]; k++)
                    {

                        NSString *time_in=[[punchesArray objectAtIndex:k] objectForKey:@"in_time"];
                        NSString *time_out=[[punchesArray objectAtIndex:k] objectForKey:@"out_time"];
                        if (time_in!=nil && ![time_in isKindOfClass:[NSNull class]] &&![time_in isEqualToString:@""] && time_out!=nil && ![time_out isKindOfClass:[NSNull class]]&&![time_out isEqualToString:@""])
                        {
                            NSMutableDictionary *inoutDict=[punchesArray objectAtIndex:k];
                            BOOL isMidCrossOverForEntry=[Util checkIsMidNightCrossOver:inoutDict];
                            BOOL isSplitEntry = [self isSplitEntryWithInTime:tsEntryObject.multiDayInOutEntry];

                            if (isMidCrossOverForEntry && !isSplitEntry)
                            {
                                totalCalculatedHours=totalCalculatedHours+[[Util getNumberOfHoursWithoutRoundingForInTime:time_in outTime:@"12:00 am"]newDoubleValue];
                                time_in=@"12:00 am";
                            }
                            
                            if (isSplitEntry) {
                                time_out = [self returnSplitEntryOutTimeWithOutTime:time_out];
                            }

                            totalCalculatedHours=totalCalculatedHours+[[Util getNumberOfHoursWithoutRoundingForInTime:time_in outTime:time_out]newDoubleValue];
                        }


                    }

                }


            }
            else
            {

                if ([[tsEntryObject entryType] isEqualToString:Time_Off_Key]||[[tsEntryObject entryType] isEqualToString:Adhoc_Time_OffKey])
                {
                    float timeEntryHours=[[tsEntryObject timeEntryHoursInDecimalFormatWithOutRoundOff] newFloatValue];
                    totalCalculatedHours=totalCalculatedHours+timeEntryHours;
                }
                else
                {
                    NSString *inTime=[[tsEntryObject multiDayInOutEntry] objectForKey:@"in_time"];
                    NSString *outTime=[[tsEntryObject multiDayInOutEntry] objectForKey:@"out_time"];


                    if (inTime!=nil && ![inTime isKindOfClass:[NSNull class]] && ![inTime isEqualToString:@""]&&outTime!=nil && ![outTime isKindOfClass:[NSNull class]] && ![outTime isEqualToString:@""])
                    {
                        float timeEntryHours=[[tsEntryObject timeEntryHoursInDecimalFormatWithOutRoundOff] newFloatValue];
                        totalCalculatedHours=totalCalculatedHours+timeEntryHours;
                    }
                }



            }
        }


        numberOfInOutRows=tempNumberOfInOutRows;
        numberOfSickRows=tempNumberOfSickRows;
        NSString *totalHoursString=[NSString stringWithFormat:@"%f",totalCalculatedHours];

        [self.totalLabelHoursLbl setText:[Util getRoundedValueFromDecimalPlaces:[totalHoursString newDoubleValue]withDecimalPlaces:2]];


        if (multiInOutTimesheetType==EXTENDED_IN_OUT_TIMESHEET_TYPE && [controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
        {

            if ([recognizer.view tag]<suggestionDetailsArray.count)
            {
                [suggestionDetailsArray removeObjectAtIndex:[recognizer.view tag]];
            }

            if ([recognizer.view tag]<self.suggestionDetailsDBArray.count)
            {
                [self.suggestionDetailsDBArray removeObjectAtIndex:[recognizer.view tag]];
            }



            UIView *totalFooterView=[[UIView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width ,[suggestionDetailsArray count]*70+Previous_Entries_Label_height)];
            totalFooterView.backgroundColor = [Util colorWithHex:@"#eeeeee" alpha:1.0f];


            float ySuggestion=0;
            BOOL isEditState=YES;
            if ([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
                [multiDayTimesheetStatus isEqualToString:APPROVED_STATUS ]|| [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] ||
                [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED] ||
                [multiDayTimesheetStatus isEqualToString:TIMESHEET_CONFLICTED])
            {
                isEditState=NO;
            }

            if (isEditState)
            {
                if ([self.suggestionDetailsDBArray count]>0)
                {
                    UILabel *previousEntriesSuggestionLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 0,self.view.frame.size.width - 20,Previous_Entries_Label_height)];
                    [previousEntriesSuggestionLabel setText:RPLocalizedString(PREVIOUS_ENTRIES_STRING, @"")];
                    [previousEntriesSuggestionLabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_14]];
                    [totalFooterView addSubview:previousEntriesSuggestionLabel];
                }
                for (int i=0; i<[suggestionDetailsArray count]; i++)
                {

                    NSMutableDictionary *dataDict=[self getSuggestionHeightDictForObject:[suggestionDetailsArray objectAtIndex:i]];
                    float height=[[dataDict objectForKey:CELL_HEIGHT_KEY] newFloatValue];
                    SuggestionView *projectSuggestionView=[[SuggestionView alloc]initWithFrame:CGRectMake(0, ySuggestion+Previous_Entries_Label_height-2,self.view.frame.size.width ,height) andWithDataDict:dataDict suggestionObj:[suggestionDetailsArray objectAtIndex:i] withTag:i withDelegate:self] ;
                    ySuggestion=ySuggestion+height;
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnSuggestionView:)];
                    for (UIGestureRecognizer *recognizer in projectSuggestionView.gestureRecognizers)
                    {
                        [projectSuggestionView removeGestureRecognizer:recognizer];
                    }
                    [projectSuggestionView addGestureRecognizer:tap];


                    [totalFooterView addSubview:projectSuggestionView];

                }


            }
            CGRect frame=totalFooterView.frame;
            frame.size.height=ySuggestion+Previous_Entries_Label_height;
            [totalFooterView setFrame:frame];
            [self.multiDayTimeEntryTableView setTableFooterView:totalFooterView];



        }
        else
        {
            [self.multiDayTimeEntryTableView setTableFooterView:totallabelView];

        }
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
        for (UIGestureRecognizer *recognizer in totallabelView.gestureRecognizers)
        {
            [totallabelView removeGestureRecognizer:recognizer];
        }
        [totallabelView addGestureRecognizer:tap];
        //MOBI-746
        if (programUri==nil ||[programUri isKindOfClass:[NSNull class]]||[programUri isEqualToString:NULL_STRING]|| [programUri isEqualToString:@"null"])
        {
            programUri=@"";
            programName=@"";
        }
        if (clientUri==nil ||[clientUri isKindOfClass:[NSNull class]]||[clientUri isEqualToString:NULL_STRING]|| [clientUri isEqualToString:@"null"])
        {
            clientUri=@"";
            clientName=@"";
        }

        if (projectUri==nil ||[projectUri isKindOfClass:[NSNull class]]||[projectUri isEqualToString:NULL_STRING]|| [projectUri isEqualToString:@"null"])
        {
            projectUri=@"";
            projectName=@"";
        }
        if (taskUri==nil ||[taskUri isKindOfClass:[NSNull class]]||[taskUri isEqualToString:NULL_STRING]|| [taskUri isEqualToString:@"null"])
        {
            taskUri=@"";
            taskName=@"";
        }
        if (activityUri==nil ||[activityUri isKindOfClass:[NSNull class]]||[activityUri isEqualToString:NULL_STRING]|| [activityUri isEqualToString:@"null"])
        {
            activityUri=@"";
            activityName=@"";
        }
        if (billingUri==nil ||[billingUri isKindOfClass:[NSNull class]]||[billingUri isEqualToString:NULL_STRING]|| [billingUri isEqualToString:@"null"])
        {
            billingUri=@"";
            billingName=@"";
        }
        if (breakUri==nil ||[breakUri isKindOfClass:[NSNull class]]||[breakUri isEqualToString:NULL_STRING]|| [breakUri isEqualToString:@"null"])
        {
            breakUri=@"";
            breakName=@"";
        }

        if([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
        {
            TimesheetMainPageController *ctrl=(TimesheetMainPageController *)controllerDelegate;
            NSMutableArray *tempCustomFieldArray=[self createUdfs];

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
                    NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
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
                    else{

                        defaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:tempDefaultValue]];

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
            TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc] init];
            NSDate *todayDate=nil;

            if ([timesheetEntryObjectArray count]>0)
            {
                TimesheetEntryObject *entryObject=(TimesheetEntryObject *)[self.timesheetEntryObjectArray objectAtIndex:0];
                todayDate=[entryObject timeEntryDate];
            }
            else
            {
                todayDate=self.currentPageDate;
            }

            NSString *rowUri=[Util getRandomGUID];
            //MOBI-746
            [tsEntryObject setTimeEntryProgramUri:programUri];
            [tsEntryObject setTimeEntryProgramName:programName];
            [tsEntryObject setTimeEntryClientName:clientName];
            [tsEntryObject setTimeEntryClientUri:clientUri];
            [tsEntryObject setTimeEntryProjectName:projectName];
            [tsEntryObject setTimeEntryProjectUri:projectUri];
            [tsEntryObject setTimeEntryActivityName:activityName];
            [tsEntryObject setTimeEntryActivityUri:activityUri];
            [tsEntryObject setTimeEntryBillingName:billingName];
            [tsEntryObject setTimeEntryBillingUri:billingUri];
            [tsEntryObject setTimeEntryTaskName:taskName];
            [tsEntryObject setTimeEntryTaskUri:taskUri];
            [tsEntryObject setIsTimeoffSickRowPresent:NO];
            [tsEntryObject setTimeEntryTimeOffName:@""];
            [tsEntryObject setTimeEntryTimeOffUri:@""];
            [tsEntryObject setTimeEntryDate:todayDate];
            NSMutableDictionary *multiDayInOutEntry=[NSMutableDictionary dictionary];
            [multiDayInOutEntry setObject:@"" forKey:@"in_time"];
            [multiDayInOutEntry setObject:@"" forKey:@"out_time"];
            [multiDayInOutEntry setObject:@"" forKey:@"comments"];
            [multiDayInOutEntry setObject:udfArray forKey:@"udfArray"];
            [tsEntryObject setMultiDayInOutEntry:multiDayInOutEntry];
            [tsEntryObject setTimePunchesArray:[NSMutableArray arrayWithObject:multiDayInOutEntry]];
            if (isGen4UserTimesheet)
            {
                TimesheetMainPageController *timesheetMainPageController=(TimesheetMainPageController *)controllerDelegate;
                [tsEntryObject setTimeEntryCellOEFArray:[timesheetMainPageController constructCellOEFObjectForTimeSheetUri:timesheetURI andtimesheetFormat:self.timesheetFormat andOEFLevel:TIMESHEET_CELL_OEF andTimePunchUri:@""]];

            }
            else
            {
                [tsEntryObject setTimeEntryUdfArray:udfArray];
            }
            [tsEntryObject setTimesheetUri:self.timesheetURI];
            [tsEntryObject setTimeAllocationUri:@""];
            [tsEntryObject setTimePunchUri:@""];
            [tsEntryObject setTimeEntryHoursInHourFormat:@""];
            [tsEntryObject setTimeEntryHoursInDecimalFormat:@""];
            [tsEntryObject setTimeEntryComments:@""];
            [tsEntryObject setRowUri:rowUri];
            [tsEntryObject setIsNewlyAddedAdhocRow:YES];
            [tsEntryObject setBreakName:breakName];
            [tsEntryObject setBreakUri:breakUri];
            
            [self.timesheetEntryObjectArray addObject:tsEntryObject];
            
            NSMutableArray *tmpArray=[NSMutableArray array];
            InOutTimesheetEntry *inoutTsObj=[[InOutTimesheetEntry alloc] init];
            [inoutTsObj intializeWithStartAndEndTime];
            [tmpArray addObject:inoutTsObj];
            [self.inoutTsObjectsArray addObject:tmpArray];
            
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:1 inSection:[self.timesheetEntryObjectArray count]-1];
            [self.multiDayTimeEntryTableView beginUpdates];
            [self.multiDayTimeEntryTableView insertSections:[NSIndexSet indexSetWithIndex:[self.timesheetEntryObjectArray count]-1] withRowAnimation:UITableViewRowAnimationFade];
            [self.multiDayTimeEntryTableView endUpdates];
            
            ExtendedInOutCell *cell= (ExtendedInOutCell *)[self.multiDayTimeEntryTableView cellForRowAtIndexPath:indexPath];
            if (cell==nil || [cell isKindOfClass:[NSNull class]])
            {
                [self.multiDayTimeEntryTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
                [self.multiDayTimeEntryTableView reloadSections:[NSIndexSet indexSetWithIndex:[self.timesheetEntryObjectArray count]-1] withRowAnimation:UITableViewRowAnimationFade];
                cell= (ExtendedInOutCell *)[self.multiDayTimeEntryTableView cellForRowAtIndexPath:indexPath];
            }
            else
            {
                [self.multiDayTimeEntryTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
            }
            [cell._inTxt becomeFirstResponder];
            
            [ctrl setHasUserChangedAnyValue:YES];
            [self changeParentViewLeftBarbutton];
        }
    }
    else
    {
        [self showINProgressAlertView];
    }


}

-(InOutTimesheetEntry * )createInOutTimesheetobjectArrayForMultiInoutObject:(TimesheetEntryObject *)obj forRow:(NSInteger)row
{
    NSMutableDictionary *inoutDict=[[obj timePunchesArray]objectAtIndex:row];
    NSString *inTime=[inoutDict objectForKey:@"in_time"];
    NSString *outTime=[inoutDict objectForKey:@"out_time"];

    BOOL isMidCrossOverForEntry=[Util checkIsMidNightCrossOver:inoutDict];
    BOOL hasSecondsEntry = false;

    InOutTimesheetEntry *tempCurrentEntryObj=[[InOutTimesheetEntry alloc]init];
    [tempCurrentEntryObj intializeWithStartAndEndTime];
    if (inTime==nil||[inTime isKindOfClass:[NSNull class]]||[inTime isEqualToString:@""])
    {
        tempCurrentEntryObj.startTime=-1;
    }
    else
    {
        NSString *hrstr=@"";
        NSString *minsStr=@"";
        NSArray *timeInCompsArr=[inTime componentsSeparatedByString:@":"];
        if ([timeInCompsArr count]==2)
        {
            hrstr=[timeInCompsArr objectAtIndex:0];
            NSArray *minsamPmCompsArr=[[timeInCompsArr objectAtIndex:1] componentsSeparatedByString:@" "];
            if ([minsamPmCompsArr count]==2)
            {
                minsStr=[minsamPmCompsArr objectAtIndex:0];
                NSString *ampmStr=[minsamPmCompsArr objectAtIndex:1];
                if ([ampmStr isEqualToString:@"pm"])
                {
                    if ([hrstr intValue]<12)
                    {
                        hrstr=[NSString stringWithFormat:@"%d",[hrstr intValue]+12];
                    }

                }
                else
                {
                    if ([hrstr intValue]==12)
                    {
                        hrstr=[NSString stringWithFormat:@"%d",[hrstr intValue]-12];
                    }
                }
            }
        }
        else if ([timeInCompsArr count]==3)
        {
            hrstr=[timeInCompsArr objectAtIndex:0];
            NSArray *secamPmCompsArr=[[timeInCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
            if ([secamPmCompsArr count]==2)
            {
                minsStr=[timeInCompsArr objectAtIndex:1];
                NSString *ampmStr=[secamPmCompsArr objectAtIndex:1];
                if ([ampmStr isEqualToString:@"pm"])
                {
                    if ([hrstr intValue]<12)
                    {
                        hrstr=[NSString stringWithFormat:@"%d",[hrstr intValue]+12];
                    }
                    
                }
                else
                {
                    if ([hrstr intValue]==12)
                    {
                        hrstr=[NSString stringWithFormat:@"%d",[hrstr intValue]-12];
                    }
                }
            }
        }

        NSString *startTimeStr=[NSString stringWithFormat:@"%@%@",hrstr,minsStr];
        tempCurrentEntryObj.startTime=[startTimeStr intValue];

    }

    NSString *tempEndTimeStr=nil;
    if (outTime==nil||[outTime isKindOfClass:[NSNull class]]||[outTime isEqualToString:@""])
    {
        tempCurrentEntryObj.endTime=-1;
    }
    else
    {
        NSString *hrstr=@"";
        NSString *minsStr=@"";
        NSArray *timeOutCompsArr=[outTime componentsSeparatedByString:@":"];
        if ([timeOutCompsArr count]==2)
        {
            hrstr=[timeOutCompsArr objectAtIndex:0];
            NSArray *minsamPmCompsArr=[[timeOutCompsArr objectAtIndex:1] componentsSeparatedByString:@" "];
            if ([minsamPmCompsArr count]==2)
            {
                minsStr=[minsamPmCompsArr objectAtIndex:0];
                NSString *ampmStr=[minsamPmCompsArr objectAtIndex:1];
                if ([ampmStr isEqualToString:@"pm"])
                {
                    if ([hrstr intValue]<12)
                    {
                        hrstr=[NSString stringWithFormat:@"%d",[hrstr intValue]+12];
                    }

                }
                else
                {
                    if ([hrstr intValue]==12)
                    {
                        hrstr=[NSString stringWithFormat:@"%d",[hrstr intValue]-12];
                    }
                }
            }
        }
        else if ([timeOutCompsArr count]==3)
        {
            hrstr=[timeOutCompsArr objectAtIndex:0];
            NSArray *secamPmCompsArr=[[timeOutCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
            if ([secamPmCompsArr count]==2)
            {
                minsStr=[timeOutCompsArr objectAtIndex:1];
                NSString *ampmStr=[secamPmCompsArr objectAtIndex:1];
                if ([ampmStr isEqualToString:@"pm"])
                {
                    if ([hrstr intValue]<12)
                    {
                        hrstr=[NSString stringWithFormat:@"%d",[hrstr intValue]+12];
                    }
                    
                }
                else
                {
                    if ([hrstr intValue]==12)
                    {
                        hrstr=[NSString stringWithFormat:@"%d",[hrstr intValue]-12];
                    }
                }
            }
        }
        NSString *endTimeStr=[NSString stringWithFormat:@"%@%@",hrstr,minsStr];
        BOOL isDetectEntryMisdnightCrossover=[obj.multiDayInOutEntry[@"isMidnightCrossover"]boolValue];
        hasSecondsEntry = [self isSplitEntryWithInTime:obj.multiDayInOutEntry];
        tempEndTimeStr=endTimeStr;
        
        if (isDetectEntryMisdnightCrossover || hasSecondsEntry)
        {
            if ([endTimeStr isEqualToString:@"2359"])
            {
                endTimeStr=@"2400";
            }
        }
        tempCurrentEntryObj.endTime=[endTimeStr intValue];

    }
    
    
    if (isMidCrossOverForEntry && !hasSecondsEntry)
    {
        [tempCurrentEntryObj setIsMidnightCrossover:YES];
    }
    else
    {
        [tempCurrentEntryObj setIsMidnightCrossover:NO];
    }

    NSMutableDictionary *dict=[self calculateAndReturnHoursWithCrossOverValue:tempCurrentEntryObj andEntryDict:inoutDict];
    if (tempEndTimeStr!=nil)
    {
        tempCurrentEntryObj.endTime=[tempEndTimeStr intValue];
    }

    tempCurrentEntryObj.hours=[NSString stringWithFormat:@"%@",[dict objectForKey:@"HOURS"]] ;
    tempCurrentEntryObj.crossoverHours=[NSString stringWithFormat:@"%@",[dict objectForKey:@"MIDNIGHTHOURS"]] ;

    self.inOutTimesheetEntry=tempCurrentEntryObj;


    return self.inOutTimesheetEntry;
}

-(InOutTimesheetEntry * )createInOutTimesheetobjectArrayForMultiInoutDictionaryObject:(NSMutableDictionary *)dictObj
{
    BOOL isSplitEntry = NO;
    NSString *inTime=[dictObj objectForKey:@"in_time"];
    NSString *outTime=[dictObj objectForKey:@"out_time"];
    BOOL isMidCrossOverForEntry=[Util checkIsMidNightCrossOver:dictObj];
    InOutTimesheetEntry *tempCurrentEntryObj=[[InOutTimesheetEntry alloc]init];
    [tempCurrentEntryObj intializeWithStartAndEndTime];
    if (inTime==nil||[inTime isKindOfClass:[NSNull class]]||[inTime isEqualToString:@""])
    {
        tempCurrentEntryObj.startTime=-1;
    }
    else
    {
        NSString *hrstr=@"";
        NSString *minsStr=@"";
        NSArray *timeInCompsArr=[inTime componentsSeparatedByString:@":"];
        if ([timeInCompsArr count]==2)
        {
            hrstr=[timeInCompsArr objectAtIndex:0];
            NSArray *minsamPmCompsArr=[[timeInCompsArr objectAtIndex:1] componentsSeparatedByString:@" "];
            if ([minsamPmCompsArr count]==2)
            {
                minsStr=[minsamPmCompsArr objectAtIndex:0];
                NSString *ampmStr=[minsamPmCompsArr objectAtIndex:1];
                if ([ampmStr isEqualToString:@"pm"])
                {
                    if ([hrstr intValue]<12)
                    {
                        hrstr=[NSString stringWithFormat:@"%d",[hrstr intValue]+12];
                    }

                }
                else
                {
                    if ([hrstr intValue]==12)
                    {
                        hrstr=[NSString stringWithFormat:@"%d",[hrstr intValue]-12];
                    }
                }
            }
        }
        else if ([timeInCompsArr count]==3)
        {
            hrstr=[timeInCompsArr objectAtIndex:0];
            NSArray *secamPmCompsArr=[[timeInCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
            if ([secamPmCompsArr count]==2)
            {
                minsStr=[timeInCompsArr objectAtIndex:1];
                NSString *ampmStr=[secamPmCompsArr objectAtIndex:1];
                if ([ampmStr isEqualToString:@"pm"])
                {
                    if ([hrstr intValue]<12)
                    {
                        hrstr=[NSString stringWithFormat:@"%d",[hrstr intValue]+12];
                    }
                    
                }
                else
                {
                    if ([hrstr intValue]==12)
                    {
                        hrstr=[NSString stringWithFormat:@"%d",[hrstr intValue]-12];
                    }
                }
            }
        }
        NSString *startTimeStr=[NSString stringWithFormat:@"%@%@",hrstr,minsStr];
        tempCurrentEntryObj.startTime=[startTimeStr intValue];
    }
    NSString *tempEndTimeStr=nil;
    if (outTime==nil||[outTime isKindOfClass:[NSNull class]]||[outTime isEqualToString:@""])
    {
        tempCurrentEntryObj.endTime=-1;
    }
    else
    {
        NSString *hrstr=@"";
        NSString *minsStr=@"";
        NSArray *timeInCompsArr=[outTime componentsSeparatedByString:@":"];
        if ([timeInCompsArr count]==2)
        {
            hrstr=[timeInCompsArr objectAtIndex:0];
            NSArray *minsamPmCompsArr=[[timeInCompsArr objectAtIndex:1] componentsSeparatedByString:@" "];
            if ([minsamPmCompsArr count]==2)
            {
                minsStr=[minsamPmCompsArr objectAtIndex:0];
                NSString *ampmStr=[minsamPmCompsArr objectAtIndex:1];
                if ([ampmStr isEqualToString:@"pm"])
                {
                    if ([hrstr intValue]<12)
                    {
                        hrstr=[NSString stringWithFormat:@"%d",[hrstr intValue]+12];
                    }

                }
                else
                {
                    if ([hrstr intValue]==12)
                    {
                        hrstr=[NSString stringWithFormat:@"%d",[hrstr intValue]-12];
                    }
                }
            }
        }
        else if ([timeInCompsArr count]==3)
        {
            hrstr=[timeInCompsArr objectAtIndex:0];
            NSArray *secamPmCompsArr=[[timeInCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
            if ([secamPmCompsArr count]==2)
            {
                minsStr=[timeInCompsArr objectAtIndex:1];
                NSString *ampmStr=[secamPmCompsArr objectAtIndex:1];
                if ([ampmStr isEqualToString:@"pm"])
                {
                    if ([hrstr intValue]<12)
                    {
                        hrstr=[NSString stringWithFormat:@"%d",[hrstr intValue]+12];
                    }
                    
                }
                else
                {
                    if ([hrstr intValue]==12)
                    {
                        hrstr=[NSString stringWithFormat:@"%d",[hrstr intValue]-12];
                    }
                }
            }
        }
        
        NSString *endTimeStr=[NSString stringWithFormat:@"%@%@",hrstr,minsStr];
        tempEndTimeStr = endTimeStr;
        
        isSplitEntry = [self isSplitEntryWithInTime:dictObj];
        if (isSplitEntry)
        {
            if ([endTimeStr isEqualToString:@"2359"])
            {
                endTimeStr=@"2400";
            }
        }
        tempCurrentEntryObj.endTime=[endTimeStr intValue];
    }
    
    
    if (isMidCrossOverForEntry && !isSplitEntry)
    {
        [tempCurrentEntryObj setIsMidnightCrossover:YES];
    }
    else
    {
        [tempCurrentEntryObj setIsMidnightCrossover:NO];
    }

    NSMutableDictionary *dict=[self calculateAndReturnHoursWithCrossOverValue:tempCurrentEntryObj andEntryDict:dictObj];
    if (tempEndTimeStr!=nil)
    {
        tempCurrentEntryObj.endTime=[tempEndTimeStr intValue];
    }

    tempCurrentEntryObj.hours=[NSString stringWithFormat:@"%@",[dict objectForKey:@"HOURS"]] ;
    tempCurrentEntryObj.crossoverHours=[NSString stringWithFormat:@"%@",[dict objectForKey:@"MIDNIGHTHOURS"]] ;
    self.inOutTimesheetEntry=tempCurrentEntryObj;
    //NSLog(@"%d %d",tempCurrentEntryObj.startTime,tempCurrentEntryObj.endTime);


    return self.inOutTimesheetEntry;
}

-(NSMutableDictionary *)calculateAndReturnHoursWithCrossOverValue:(InOutTimesheetEntry *)_currentEntry andEntryDict:(NSMutableDictionary *)inoutDict
{

    NSString *finalHoursText=@"";
    NSString *finalMidnightCrossoverHoursText=@"";

    if(_currentEntry.startTime == -1 || _currentEntry.endTime == -1)
    {
        finalHoursText = [NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]];
        finalMidnightCrossoverHoursText=@"";
    }
    else
    {
        if (_currentEntry.endTime < _currentEntry.startTime)
        {
            int diffInHours = (24-((int)(_currentEntry.startTime/100)-(int)(_currentEntry.endTime/100)))*60;
            int diffInMins = (24-((int)(_currentEntry.startTime/100)-(int)(_currentEntry.endTime/100)))*60 + ((_currentEntry.startTime%100)-(_currentEntry.endTime%100));
            int mins = diffInMins%60;
            NSString *minsStr=(mins<10 ? [NSString stringWithFormat:@"0%i", mins] : [NSString stringWithFormat:@"%i", mins]);
            if (mins>0)
            {
                minsStr=[NSString stringWithFormat:@"%f",1-([minsStr newFloatValue]/60)];
            }
            else
            {
                minsStr=[NSString stringWithFormat:@"%f",[minsStr newFloatValue]/60];
            }

            NSString *hrsStr=[NSString stringWithFormat:@"%d",(int)(diffInHours/60)];
            NSString *final=[NSString stringWithFormat:@"%.2f",[hrsStr newFloatValue]+[minsStr newFloatValue]];
            finalHoursText =final ;


            if (_currentEntry.isMidnightCrossover)
            {
                NSString *intimeString=[inoutDict objectForKey:@"in_time"];
                NSString *tmpOuttimeString=@"12:00 am";
                NSString *tmpintimeString=@"12:00 am";
                NSString *outtimeString=[inoutDict objectForKey:@"out_time"];
                NSString *hoursText=[Util getNumberOfHoursForInTime:intimeString outTime:tmpOuttimeString];
                NSString *midnightHours=[Util getNumberOfHoursForInTime:tmpintimeString outTime:outtimeString];
                finalHoursText = hoursText;
                finalMidnightCrossoverHoursText=[NSString stringWithFormat:@"+%@",midnightHours];

            }
            else
            {
                finalMidnightCrossoverHoursText=@"";

            }

        }
        else
        {

            int diffInMins = ((int)(_currentEntry.endTime/100)-(int)(_currentEntry.startTime/100))*60 + ((_currentEntry.endTime%100)-(_currentEntry.startTime%100));
            int mins = diffInMins%60;
            NSString *minsStr=(mins<10 ? [NSString stringWithFormat:@"0%i", mins] : [NSString stringWithFormat:@"%i", mins]);
            minsStr=[NSString stringWithFormat:@"%f",[minsStr newFloatValue]/60];
            NSString *hrsStr=[NSString stringWithFormat:@"%d",(int)(diffInMins/60)];
            NSString *final=[NSString stringWithFormat:@"%.2f",[hrsStr newFloatValue]+[minsStr newFloatValue]];
            finalHoursText =final ;

            if (_currentEntry.isMidnightCrossover)
            {
                NSString *intimeString=[inoutDict objectForKey:@"in_time"];
                NSString *tmpOuttimeString=@"12:00 am";
                NSString *tmpintimeString=@"12:00 am";
                NSString *outtimeString=[inoutDict objectForKey:@"out_time"];
                NSString *hoursText=[Util getNumberOfHoursForInTime:intimeString outTime:tmpOuttimeString];
                NSString *midnightHours=[Util getNumberOfHoursForInTime:tmpintimeString outTime:outtimeString];
                finalHoursText = hoursText;
                finalMidnightCrossoverHoursText=[NSString stringWithFormat:@"+%@",midnightHours];

            }
            else
            {
                finalMidnightCrossoverHoursText=@"";

            }



        }

    }

//    NSMutableDictionary *returnDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:[Util formatDoubleAsStringWithDecimalPlaces:[finalHoursText newDoubleValue]],@"HOURS",[Util formatDoubleAsStringWithDecimalPlaces:[finalMidnightCrossoverHoursText newDoubleValue]] ,@"MIDNIGHTHOURS",nil];

    NSMutableDictionary *returnDict=nil;
    if (![finalMidnightCrossoverHoursText isEqualToString:@""])
    {
        returnDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:[Util formatDoubleAsStringWithDecimalPlaces:[finalHoursText newDoubleValue]],@"HOURS",[Util formatDoubleAsStringWithDecimalPlaces:[finalMidnightCrossoverHoursText newDoubleValue]] ,@"MIDNIGHTHOURS",nil];
    }
    else
    {
        returnDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:[Util formatDoubleAsStringWithDecimalPlaces:[finalHoursText newDoubleValue]],@"HOURS",finalMidnightCrossoverHoursText,@"MIDNIGHTHOURS",nil];
    }


    return returnDict;


}

-(void)updateComments:(NSString *)commentsStr andUdfArray:(NSMutableArray *)entryUdfArray forRow:(NSInteger)row forSection:(NSInteger)section
{
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;
        tsMainPageCtrl.hasUserChangedAnyValue=YES;
        [self changeParentViewLeftBarbutton];
    }

    ExtendedInOutCell *extendedcell = (ExtendedInOutCell *)[self.multiDayTimeEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row+1 inSection:section]];
    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:section];

    NSString *clientName=tsEntryObject.timeEntryClientName;
    NSString *clientUri=tsEntryObject.timeEntryClientUri;
    NSString *projectName=tsEntryObject.timeEntryProjectName;
    NSString *projectUri=tsEntryObject.timeEntryProjectUri;
    NSString *taskName=tsEntryObject.timeEntryTaskName;
    NSString *taskUri=tsEntryObject.timeEntryTaskUri;
    NSString *activityName=tsEntryObject.timeEntryActivityName;
    NSString *activityUri=tsEntryObject.timeEntryActivityUri;
    NSString *timeOffName=tsEntryObject.timeEntryTimeOffName;
    NSString *timeOffUri=tsEntryObject.timeEntryTimeOffUri;
    NSString *billingName=tsEntryObject.timeEntryBillingName;
    NSString *billingUri=tsEntryObject.timeEntryBillingUri;
    NSString *hoursInHourFormat=tsEntryObject.timeEntryHoursInHourFormat;
    NSString *comments=tsEntryObject.timeEntryComments;
    NSString *punchUri=tsEntryObject.timePunchUri;
    NSString *allocationUri=tsEntryObject.timeAllocationUri;
    NSString *entryType=tsEntryObject.entryType;
    NSDate *entryDate=tsEntryObject.timeEntryDate;
    BOOL isTimeoffSickRowPresent=tsEntryObject.isTimeoffSickRowPresent;
    NSString *timesheetUri=tsEntryObject.timesheetUri;
    NSMutableDictionary *multiInoutEntry=tsEntryObject.multiDayInOutEntry;
    //Implentation for US8956//JUHI
    NSString *breakName=tsEntryObject.breakName;
    NSString *breakUri=tsEntryObject.breakUri;
    NSString *programName=tsEntryObject.timeEntryProgramName;
    NSString *programUri=tsEntryObject.timeEntryProgramUri;
    NSString *rowUri=tsEntryObject.rowUri;


    TimesheetEntryObject *tsTempEntryObject=[[TimesheetEntryObject alloc] init];
    //MOBI-746
    [tsTempEntryObject setTimeEntryProgramUri:programUri];
    [tsTempEntryObject setTimeEntryProgramName:programName];
    [tsTempEntryObject setTimeEntryClientName:clientName];
    [tsTempEntryObject setTimeEntryClientUri:clientUri];
    [tsTempEntryObject setTimeEntryProjectName:projectName];
    [tsTempEntryObject setTimeEntryProjectUri:projectUri];
    [tsTempEntryObject setTimeEntryTaskName:taskName];
    [tsTempEntryObject setTimeEntryTaskUri:taskUri];
    [tsTempEntryObject setTimeEntryActivityName:activityName];
    [tsTempEntryObject setTimeEntryActivityUri:activityUri];
    [tsTempEntryObject setTimeEntryTimeOffName:timeOffName];
    [tsTempEntryObject setTimeEntryTimeOffUri:timeOffUri];
    [tsTempEntryObject setTimeEntryBillingName:billingName];
    [tsTempEntryObject setTimeEntryBillingUri:billingUri];
    [tsTempEntryObject setTimeEntryHoursInHourFormat:hoursInHourFormat];
    [tsTempEntryObject setTimeEntryComments:comments];
    if (isGen4UserTimesheet)
    {
        [tsTempEntryObject setTimeEntryCellOEFArray:entryUdfArray];
    }
    else
    {
        [tsTempEntryObject setTimeEntryUdfArray:entryUdfArray];
    }

    [tsTempEntryObject setMultiDayInOutEntry:multiInoutEntry];
    [tsTempEntryObject setTimePunchUri:punchUri];
    [tsTempEntryObject setTimeAllocationUri:allocationUri];
    [tsTempEntryObject setTimeEntryDate:entryDate];
    [tsTempEntryObject setIsTimeoffSickRowPresent:isTimeoffSickRowPresent];
    [tsTempEntryObject setEntryType:entryType];
    [tsTempEntryObject setTimesheetUri:timesheetUri];
    [tsTempEntryObject setRowUri:rowUri];

    //Implentation for US8956//JUHI
    [tsTempEntryObject setBreakName:breakName];
    [tsTempEntryObject setBreakUri:breakUri];
    NSMutableArray *punchArray=tsEntryObject.timePunchesArray;
    NSMutableDictionary *tempDictionary=[NSMutableDictionary dictionaryWithDictionary:[punchArray objectAtIndex:row]];
    if(commentsStr!=nil)
    {
       [tempDictionary setObject:commentsStr forKey:@"comments"];
    }

    if (entryUdfArray!=nil)
    {
        [tempDictionary setObject:entryUdfArray forKey:@"udfArray"];
    }

    [punchArray replaceObjectAtIndex:row withObject:tempDictionary];
    [tsTempEntryObject setTimePunchesArray:punchArray];


    NSMutableArray *commentsImageColorStatusArray=[NSMutableArray array];
    if ([tsTempEntryObject breakUri]!=nil &&![[tsTempEntryObject breakUri] isKindOfClass:[NSNull class]]&&![[tsTempEntryObject breakUri] isEqualToString:@""])
    {
        //Do nothing for break.since breaks have no udf support
    }
    else
    {
        if(!isGen4UserTimesheet)
        {
            LoginModel *loginModel=[[LoginModel alloc]init];
            NSMutableArray *requiredUdfArray=[loginModel getRequiredOnlyUDFsforModuleName:TIMESHEET_CELL_UDF];
            if ([[tsTempEntryObject entryType] isEqualToString:Time_Off_Key]||[[tsTempEntryObject entryType] isEqualToString:Adhoc_Time_OffKey])
            {
                requiredUdfArray=[loginModel getRequiredOnlyUDFsforModuleName:TIMEOFF_UDF];
            }
            else
            {
                requiredUdfArray=[loginModel getRequiredOnlyUDFsforModuleName:TIMESHEET_CELL_UDF];
            }
            NSMutableArray *udfArray=[[[tsTempEntryObject timePunchesArray] objectAtIndex:row] objectForKey:@"udfArray"];
            if ([requiredUdfArray count]!=0)
            {

                for (int k=0; k<[udfArray count]; k++)
                {
                    EntryCellDetails *udfDetails=(EntryCellDetails *)[udfArray objectAtIndex:k];

                    BOOL isUdfMandatory=NO;
                    if ([[tsTempEntryObject entryType] isEqualToString:Time_Off_Key]||[[tsTempEntryObject entryType] isEqualToString:Adhoc_Time_OffKey])
                    {
                        isUdfMandatory=[loginModel getMandatoryStatusforUDFWithIdentity:[udfDetails udfIdentity] forModuleName:TIMEOFF_UDF];
                    }
                    else
                    {
                        isUdfMandatory=[loginModel getMandatoryStatusforUDFWithIdentity:[udfDetails udfIdentity] forModuleName:TIMESHEET_CELL_UDF];
                    }

                    if (isUdfMandatory)
                    {
                        NSString *udfValue=[udfDetails fieldValue];
                        if ([udfValue isEqualToString:RPLocalizedString(ADD_STRING, @"")]|| [udfValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
                        {

                            [commentsImageColorStatusArray addObject:@"RED"];


                        }
                        else
                        {

                            [commentsImageColorStatusArray addObject:@"BLUE"];
                        }
                    }
                    else
                    {

                        [commentsImageColorStatusArray addObject:@"BLUE"];
                    }

                }
            }
            else
            {
                for (int k=0; k<[udfArray count]; k++)
                {
                    EntryCellDetails *udfDetails=(EntryCellDetails *)[udfArray objectAtIndex:k];
                    NSString *udfValue=[udfDetails fieldValue];
                    if ([udfValue isEqualToString:RPLocalizedString(ADD_STRING, @"")]|| [udfValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]|| [udfValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])
                    {
                        
                        [commentsImageColorStatusArray addObject:@"GRAY"];
                        
                    }
                    else
                    {
                        
                        [commentsImageColorStatusArray removeObject:@"GRAY"];
                        [commentsImageColorStatusArray addObject:@"BLUE"];
                    }
                }
            }
        }

        else
        {

            for (int k=0; k<[entryUdfArray count]; k++)
            {
                OEFObject *oefObject=(OEFObject *)[entryUdfArray objectAtIndex:k];
                NSString *oefValue=nil;
                NSString *oefDefinitionTypeUri=oefObject.oefDefinitionTypeUri;
                if ([oefDefinitionTypeUri isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI])
                {
                    oefValue=oefObject.oefTextValue;
                }
                else if ([oefDefinitionTypeUri isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI])
                {
                    oefValue=oefObject.oefNumericValue;
                }
                else if ([oefDefinitionTypeUri isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI])
                {
                    oefValue=oefObject.oefDropdownOptionValue;
                }
                if (oefValue==nil || [oefValue isKindOfClass:[NSNull class]] || [oefValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")] || [oefValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                {

                    [commentsImageColorStatusArray addObject:@"GRAY"];

                }
                else
                {

                    [commentsImageColorStatusArray removeObject:@"GRAY"];
                    [commentsImageColorStatusArray addObject:@"BLUE"];
                }
            }
        }

    }


    NSMutableArray *commentsImageColorStatusArrayForComments=[NSMutableArray array];
    BOOL ifCommentsMandatory=NO;
    NSMutableArray *daySummaryArray=nil;
    UIViewController *controllerViewCtrl=(UIViewController *)controllerDelegate;
    if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
        TimesheetMainPageController *controllerViewCtrl=(TimesheetMainPageController *)controllerDelegate;
        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)[controllerViewCtrl parentDelegate];
        ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            daySummaryArray=[approvalsModel getAllPendingTimesheetDaySummaryFromDBForTimesheet:timesheetUri];
        }
        else
        {
            daySummaryArray=[approvalsModel getAllPreviousTimesheetDaySummaryFromDBForTimesheet:timesheetUri];
        }
    }
    //User context Flow for timesheets
    else if([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        daySummaryArray=[timesheetModel getAllTimesheetDaySummaryFromDBForTimesheet:timesheetUri];
    }

    if ([daySummaryArray count]!=0) {
        if ([[[daySummaryArray objectAtIndex:0] objectForKey:@"isCommentsRequired"] intValue]==1)
        {
            ifCommentsMandatory=YES;
        }
    }

    if (ifCommentsMandatory)
    {
        if (commentsStr!=nil && ![commentsStr isEqualToString:@""]&& ![commentsStr isKindOfClass:[NSNull class]]&&![commentsStr isEqualToString:NULL_STRING])
        {

            [commentsImageColorStatusArrayForComments addObject:@"BLUE"];
        }
        else
        {

            [commentsImageColorStatusArrayForComments addObject:@"RED"];
        }
    }
    else
    {
        if (commentsStr!=nil && ![commentsStr isEqualToString:@""]&& ![commentsStr isKindOfClass:[NSNull class]]&&![commentsStr isEqualToString:NULL_STRING])
        {

            [commentsImageColorStatusArrayForComments addObject:@"BLUE"];
        }
        else
        {

            [commentsImageColorStatusArrayForComments addObject:@"GRAY"];
        }

    }



    UIImage *commentsIconImage = nil;
    if ([commentsImageColorStatusArray containsObject:@"RED"]||[commentsImageColorStatusArrayForComments containsObject:@"RED"])
    {
        commentsIconImage=[UIImage imageNamed:@"icon_comments_red"];
    }
    else if ([commentsImageColorStatusArray containsObject:@"BLUE"]||[commentsImageColorStatusArrayForComments containsObject:@"BLUE"])
    {
        commentsIconImage=[UIImage imageNamed:@"active-comment"];
    }
    else if ([commentsImageColorStatusArray containsObject:@"GRAY"]&&[commentsImageColorStatusArrayForComments containsObject:@"GRAY"])
    {
        commentsIconImage=[UIImage imageNamed:@"in-active-comment"];
    }
    else
    {
        LoginModel *loginModel=[[LoginModel alloc]init];
        NSMutableArray *requiredUdfArray=[loginModel getRequiredOnlyUDFsforModuleName:TIMESHEET_CELL_UDF];
        if ([requiredUdfArray count]!=0)
        {
            commentsIconImage=[UIImage imageNamed:@"active-comment"];
        }
        else
        {
            if (comments!=nil && ![comments isEqualToString:@""]&& ![comments isKindOfClass:[NSNull class]]&&![comments isEqualToString:NULL_STRING])
            {
                commentsIconImage=[UIImage imageNamed:@"active-comment"];
            }
            else
            {
                commentsIconImage=[UIImage imageNamed:@"in-active-comment"];

            }

        }

    }

    float xcommentsOrArrowImgImage=extendedcell._submit.frame.origin.x+extendedcell._submit.frame.size.width-(commentsIconImage.size.width/2)+7;
    [extendedcell.commentsIconImageView setFrame:CGRectMake(xcommentsOrArrowImgImage, 17, commentsIconImage.size.width,commentsIconImage.size.height)];
    [extendedcell.commentsIconImageView setImage:commentsIconImage];

    [self.timesheetEntryObjectArray replaceObjectAtIndex:section withObject:tsTempEntryObject];


}


-(void) deleteMutiInOutEntryforRow:(NSInteger)row forSection:(NSInteger)section withDelegate:(id)delegate
{
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        if(section<self.timesheetEntryObjectArray.count)
        {
            TimesheetEntryObject *deleteEntryObject=(TimesheetEntryObject *)[self.timesheetEntryObjectArray objectAtIndex:section];
            TimesheetMainPageController *ctrl=(TimesheetMainPageController *)controllerDelegate;
            if (ctrl.pageControl.currentPage<ctrl.timesheetDataArray.count)
            {
                NSMutableArray *entryDataArray=[ctrl.timesheetDataArray objectAtIndex:ctrl.pageControl.currentPage];
                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[entryDataArray objectAtIndex:section];
                if (![tsEntryObject isTimeoffSickRowPresent])
                {
                    [entryDataArray removeObjectIdenticalTo:deleteEntryObject];
                    [[deleteEntryObject timePunchesArray] removeObjectAtIndex:row];
                    if ([[deleteEntryObject timePunchesArray] count]!=0)
                    {
                        [entryDataArray insertObject:deleteEntryObject atIndex:section];
                    }
                }
                [ctrl.timesheetDataArray replaceObjectAtIndex:ctrl.pageControl.currentPage withObject:entryDataArray];
                [ctrl setHasUserChangedAnyValue:YES];
                [self calculateAndUpdateTotalHoursValueForFooter];
                [ctrl reloadViewWithRefreshedDataAfterSave];
            }

        }

    }
}

-(NSMutableArray *)getUniqueSuggestionsArrayFromObjects
{
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *ctrl=(TimesheetMainPageController *)controllerDelegate;
        if(ctrl.tsEntryDataArray.count > ctrl.pageControl.currentPage) {
        NSString *formattedDate=[NSString stringWithFormat:@"%@",[[ctrl.tsEntryDataArray objectAtIndex:ctrl.pageControl.currentPage] entryDate]];

        NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
        [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        myDateFormatter.dateFormat = @"EEEE, dd MMM yyyy";

        NSLocale *locale=[NSLocale currentLocale];
        [myDateFormatter setLocale:locale];
        NSDate *currentDate=[myDateFormatter dateFromString:[NSString stringWithFormat:@"%@",formattedDate]];

        NSMutableArray *activeCellObjectsArray=[NSMutableArray array];
            if (ctrl.pageControl.currentPage<ctrl.timesheetDataArray.count)
            {
                NSMutableArray *currentTimesheetEntryObjectArray=[ctrl.timesheetDataArray objectAtIndex:ctrl.pageControl.currentPage];
                for (int j=0; j<[currentTimesheetEntryObjectArray count]; j++)
                {
                    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[currentTimesheetEntryObjectArray objectAtIndex:j];
                    BOOL isTimeoffSickRow=[tsEntryObject isTimeoffSickRowPresent];
                    NSDate *timeEntryDate=[tsEntryObject timeEntryDate];
                    if (!isTimeoffSickRow)
                    {
                        id programName=nil;
                        id programUri=nil;
                        id clientName=nil;
                        id clientUri=nil;
                        id projectName=nil;
                        id projectUri=nil;
                        id activityName=nil;
                        id activityUri=nil;
                        id billingName=nil;
                        id billingUri=nil;
                        id taskName=nil;
                        id taskUri=nil;
                        id breakName=nil;
                        id breakUri=nil;
                        //MOBI-746
                        NSString *timeEntryProgramName=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryProgramName]];
                        if (timeEntryProgramName==nil||[timeEntryProgramName isKindOfClass:[NSNull class]]||[timeEntryProgramName isEqualToString:@""]||[timeEntryProgramName isEqualToString:NULL_STRING]||[timeEntryProgramName isEqualToString:NULL_OBJECT_STRING])
                        {
                            programName=[NSNull null];
                        }
                        else
                        {
                            programName=timeEntryProgramName;
                        }
                        NSString *timeEntryProgramUri=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryProgramUri]];
                        if (timeEntryProgramUri==nil||[timeEntryProgramUri isKindOfClass:[NSNull class]]||[timeEntryProgramUri isEqualToString:@""]||[timeEntryProgramUri isEqualToString:NULL_STRING]||[timeEntryProgramUri isEqualToString:NULL_OBJECT_STRING])
                        {
                            programUri=[NSNull null];
                        }
                        else
                        {
                            programUri=timeEntryProgramUri;
                        }

                        NSString *timeEntryClientName=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryClientName]];
                        if (timeEntryClientName==nil||[timeEntryClientName isKindOfClass:[NSNull class]]||[timeEntryClientName isEqualToString:@""]||[timeEntryClientName isEqualToString:NULL_STRING]||[timeEntryClientName isEqualToString:NULL_OBJECT_STRING])
                        {
                            clientName=[NSNull null];
                        }
                        else
                        {
                            clientName=timeEntryClientName;
                        }
                        NSString *timeEntryClientUri=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryClientUri]];
                        if (timeEntryClientUri==nil||[timeEntryClientUri isKindOfClass:[NSNull class]]||[timeEntryClientUri isEqualToString:@""]||[timeEntryClientUri isEqualToString:NULL_STRING]||[timeEntryClientUri isEqualToString:NULL_OBJECT_STRING])
                        {
                            clientUri=[NSNull null];
                        }
                        else
                        {
                            clientUri=timeEntryClientUri;
                        }

                        NSString *timeEntryProjectName=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryProjectName]];
                        if (timeEntryProjectName==nil||[timeEntryProjectName isKindOfClass:[NSNull class]]||[timeEntryProjectName isEqualToString:@""]||[timeEntryProjectName isEqualToString:NULL_STRING]||[timeEntryProjectName isEqualToString:NULL_OBJECT_STRING])
                        {
                            projectName=[NSNull null];
                        }
                        else
                        {
                            projectName=timeEntryProjectName;
                        }
                        NSString *timeEntryProjectUri=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryProjectUri]];
                        if (timeEntryProjectUri==nil||[timeEntryProjectUri isKindOfClass:[NSNull class]]||[timeEntryProjectUri isEqualToString:@""]||[timeEntryProjectUri isEqualToString:NULL_STRING]||[timeEntryProjectUri isEqualToString:NULL_OBJECT_STRING])
                        {
                            projectUri=[NSNull null];
                        }
                        else
                        {
                            projectUri=timeEntryProjectUri;
                        }
                        NSString *timeEntryActivityName=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryActivityName]];
                        if (timeEntryActivityName==nil||[timeEntryActivityName isKindOfClass:[NSNull class]]||[timeEntryActivityName isEqualToString:@""]||[timeEntryActivityName isEqualToString:NULL_STRING]||[timeEntryActivityName isEqualToString:NULL_OBJECT_STRING])
                        {
                            activityName=[NSNull null];
                        }
                        else
                        {
                            activityName=timeEntryActivityName;
                        }
                        NSString *timeEntryActivityUri=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryActivityUri]];
                        if (timeEntryActivityUri==nil||[timeEntryActivityUri isKindOfClass:[NSNull class]]||[timeEntryActivityUri isEqualToString:@""]||[timeEntryActivityUri isEqualToString:NULL_STRING]||[timeEntryActivityUri isEqualToString:NULL_OBJECT_STRING])
                        {
                            activityUri=[NSNull null];
                        }
                        else
                        {
                            activityUri=timeEntryActivityUri;
                        }
                        NSString *timeEntryBillingName=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryBillingName]];
                        if (timeEntryBillingName==nil||[timeEntryBillingName isKindOfClass:[NSNull class]]||[timeEntryBillingName isEqualToString:@""]||[timeEntryBillingName isEqualToString:NULL_STRING]||[timeEntryBillingName isEqualToString:NULL_OBJECT_STRING])
                        {
                            billingName=[NSNull null];
                        }
                        else
                        {
                            billingName=timeEntryBillingName;
                        }
                        NSString *timeEntryBillingUri=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryBillingUri]];
                        if (timeEntryBillingUri==nil||[timeEntryBillingUri isKindOfClass:[NSNull class]]||[timeEntryBillingUri isEqualToString:@""]||[timeEntryBillingUri isEqualToString:NULL_STRING]||[timeEntryBillingUri isEqualToString:NULL_OBJECT_STRING])
                        {
                            billingUri=[NSNull null];
                        }
                        else
                        {
                            billingUri=timeEntryBillingUri;
                        }
                        NSString *timeEntryTaskName=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryTaskName]];
                        if (timeEntryTaskName==nil||[timeEntryTaskName isKindOfClass:[NSNull class]]||[timeEntryTaskName isEqualToString:@""]||[timeEntryTaskName isEqualToString:NULL_STRING]||[timeEntryTaskName isEqualToString:NULL_OBJECT_STRING])
                        {
                            taskName=[NSNull null];
                        }
                        else
                        {
                            taskName=timeEntryTaskName;
                        }
                        NSString *timeEntryTaskUri=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryTaskUri]];
                        if (timeEntryTaskUri==nil||[timeEntryTaskUri isKindOfClass:[NSNull class]]||[timeEntryTaskUri isEqualToString:@""]||[timeEntryTaskUri isEqualToString:NULL_STRING]||[timeEntryTaskUri isEqualToString:NULL_OBJECT_STRING])
                        {
                            taskUri=[NSNull null];
                        }
                        else
                        {
                            taskUri=timeEntryTaskUri;
                        }
                        NSString *timeEntryBreakUri=[NSString stringWithFormat:@"%@",[tsEntryObject breakUri]];
                        if (timeEntryBreakUri==nil||[timeEntryBreakUri isKindOfClass:[NSNull class]]||[timeEntryBreakUri isEqualToString:@""]||[timeEntryBreakUri isEqualToString:NULL_STRING]||[timeEntryBreakUri isEqualToString:NULL_OBJECT_STRING])
                        {
                            breakUri=[NSNull null];
                        }
                        else
                        {
                            breakUri=timeEntryBreakUri;
                        }
                        NSString *timeEntryBreakName=[NSString stringWithFormat:@"%@",[tsEntryObject breakName]];
                        if (timeEntryBreakName==nil||[timeEntryBreakName isKindOfClass:[NSNull class]]||[timeEntryBreakName isEqualToString:@""]||[timeEntryBreakName isEqualToString:NULL_STRING]||[timeEntryBreakName isEqualToString:NULL_OBJECT_STRING])
                        {
                            breakName=[NSNull null];
                        }
                        else
                        {
                            breakName=timeEntryBreakName;
                        }


                        NSMutableDictionary *infoDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                       programName,@"programName",//MOBI-746
                                                       programUri,@"programUri",//MOBI-746
                                                       clientName,@"clientName",
                                                       clientUri,@"clientUri",
                                                       projectName,@"projectName",
                                                       projectUri,@"projectUri",
                                                       activityName,@"activityName",
                                                       activityUri,@"activityUri",
                                                       billingName,@"billingName",
                                                       billingUri,@"billingUri",
                                                       taskName,@"taskName",
                                                       taskUri,@"taskUri",
                                                       breakName,@"breakName",
                                                       breakUri,@"breakUri",
                                                       nil];
                        
                        if ([timeEntryDate compare:currentDate]==NSOrderedSame)
                        {
                            if (![activeCellObjectsArray containsObject:infoDict])
                            {
                                [activeCellObjectsArray addObject:infoDict];
                            }
                            
                        }
                    }
                }

            }

        NSMutableArray *distinctProjectUriArray=[NSMutableArray array];
        for (int i=0; i<[ctrl.timesheetDataArray count]; i++)
        {
            NSMutableArray *tempTimesheetEntryObjectArray=[ctrl.timesheetDataArray objectAtIndex:i];
            for (int j=0; j<[tempTimesheetEntryObjectArray count]; j++)
            {
                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[tempTimesheetEntryObjectArray objectAtIndex:j];
                BOOL isTimeoffSickRow=[tsEntryObject isTimeoffSickRowPresent];
                NSDate *timeEntryDate=[tsEntryObject timeEntryDate];
                if (!isTimeoffSickRow)
                {
                    id programName=nil;
                    id programUri=nil;
                    id clientName=nil;
                    id clientUri=nil;
                    id projectName=nil;
                    id projectUri=nil;
                    id activityName=nil;
                    id activityUri=nil;
                    id billingName=nil;
                    id billingUri=nil;
                    id taskName=nil;
                    id taskUri=nil;
                    id breakName=nil;
                    id breakUri=nil;
                    NSString *timeEntryProgramName=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryProgramName]];
                    if (timeEntryProgramName==nil||[timeEntryProgramName isKindOfClass:[NSNull class]]||[timeEntryProgramName isEqualToString:@""]||[timeEntryProgramName isEqualToString:NULL_STRING]||[timeEntryProgramName isEqualToString:NULL_OBJECT_STRING])
                    {
                        programName=[NSNull null];
                    }
                    else
                    {
                        programName=timeEntryProgramName;
                    }
                    NSString *timeEntryProgramUri=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryProgramUri]];
                    if (timeEntryProgramUri==nil||[timeEntryProgramUri isKindOfClass:[NSNull class]]||[timeEntryProgramUri isEqualToString:@""]||[timeEntryProgramUri isEqualToString:NULL_STRING]||[timeEntryProgramUri isEqualToString:NULL_OBJECT_STRING])
                    {
                        programUri=[NSNull null];
                    }
                    else
                    {
                        programUri=timeEntryProgramUri;
                    }

                    NSString *timeEntryClientName=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryClientName]];
                    if (timeEntryClientName==nil||[timeEntryClientName isKindOfClass:[NSNull class]]||[timeEntryClientName isEqualToString:@""]||[timeEntryClientName isEqualToString:NULL_STRING]||[timeEntryClientName isEqualToString:NULL_OBJECT_STRING])
                    {
                        clientName=[NSNull null];
                    }
                    else
                    {
                        clientName=timeEntryClientName;
                    }
                    NSString *timeEntryClientUri=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryClientUri]];
                    if (timeEntryClientUri==nil||[timeEntryClientUri isKindOfClass:[NSNull class]]||[timeEntryClientUri isEqualToString:@""]||[timeEntryClientUri isEqualToString:NULL_STRING]||[timeEntryClientUri isEqualToString:NULL_OBJECT_STRING])
                    {
                        clientUri=[NSNull null];
                    }
                    else
                    {
                        clientUri=timeEntryClientUri;
                    }

                    NSString *timeEntryProjectName=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryProjectName]];
                    if (timeEntryProjectName==nil||[timeEntryProjectName isKindOfClass:[NSNull class]]||[timeEntryProjectName isEqualToString:@""]||[timeEntryProjectName isEqualToString:NULL_STRING]||[timeEntryProjectName isEqualToString:NULL_OBJECT_STRING])
                    {
                        projectName=[NSNull null];
                    }
                    else
                    {
                        projectName=timeEntryProjectName;
                    }
                    NSString *timeEntryProjectUri=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryProjectUri]];
                    if (timeEntryProjectUri==nil||[timeEntryProjectUri isKindOfClass:[NSNull class]]||[timeEntryProjectUri isEqualToString:@""]||[timeEntryProjectUri isEqualToString:NULL_STRING]||[timeEntryProjectUri isEqualToString:NULL_OBJECT_STRING])
                    {
                        projectUri=[NSNull null];
                    }
                    else
                    {
                        projectUri=timeEntryProjectUri;
                    }
                    NSString *timeEntryActivityName=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryActivityName]];
                    if (timeEntryActivityName==nil||[timeEntryActivityName isKindOfClass:[NSNull class]]||[timeEntryActivityName isEqualToString:@""]||[timeEntryActivityName isEqualToString:NULL_STRING]||[timeEntryActivityName isEqualToString:NULL_OBJECT_STRING])
                    {
                        activityName=[NSNull null];
                    }
                    else
                    {
                        activityName=timeEntryActivityName;
                    }
                    NSString *timeEntryActivityUri=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryActivityUri]];
                    if (timeEntryActivityUri==nil||[timeEntryActivityUri isKindOfClass:[NSNull class]]||[timeEntryActivityUri isEqualToString:@""]||[timeEntryActivityUri isEqualToString:NULL_STRING]||[timeEntryActivityUri isEqualToString:NULL_OBJECT_STRING])
                    {
                        activityUri=[NSNull null];
                    }
                    else
                    {
                        activityUri=timeEntryActivityUri;
                    }
                    NSString *timeEntryBillingName=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryBillingName]];
                    if (timeEntryBillingName==nil||[timeEntryBillingName isKindOfClass:[NSNull class]]||[timeEntryBillingName isEqualToString:@""]||[timeEntryBillingName isEqualToString:NULL_STRING]||[timeEntryBillingName isEqualToString:NULL_OBJECT_STRING])
                    {
                        billingName=[NSNull null];
                    }
                    else
                    {
                        billingName=timeEntryBillingName;
                    }
                    NSString *timeEntryBillingUri=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryBillingUri]];
                    if (timeEntryBillingUri==nil||[timeEntryBillingUri isKindOfClass:[NSNull class]]||[timeEntryBillingUri isEqualToString:@""]||[timeEntryBillingUri isEqualToString:NULL_STRING]||[timeEntryBillingUri isEqualToString:NULL_OBJECT_STRING])
                    {
                        billingUri=[NSNull null];
                    }
                    else
                    {
                        billingUri=timeEntryBillingUri;
                    }
                    NSString *timeEntryTaskName=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryTaskName]];
                    if (timeEntryTaskName==nil||[timeEntryTaskName isKindOfClass:[NSNull class]]||[timeEntryTaskName isEqualToString:@""]||[timeEntryTaskName isEqualToString:NULL_STRING]||[timeEntryTaskName isEqualToString:NULL_OBJECT_STRING])
                    {
                        taskName=[NSNull null];
                    }
                    else
                    {
                        taskName=timeEntryTaskName;
                    }
                    NSString *timeEntryTaskUri=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryTaskUri]];
                    if (timeEntryTaskUri==nil||[timeEntryTaskUri isKindOfClass:[NSNull class]]||[timeEntryTaskUri isEqualToString:@""]||[timeEntryTaskUri isEqualToString:NULL_STRING]||[timeEntryTaskUri isEqualToString:NULL_OBJECT_STRING])
                    {
                        taskUri=[NSNull null];
                    }
                    else
                    {
                        taskUri=timeEntryTaskUri;
                    }
                    NSString *timeEntryBreakUri=[NSString stringWithFormat:@"%@",[tsEntryObject breakUri]];
                    if (timeEntryBreakUri==nil||[timeEntryBreakUri isKindOfClass:[NSNull class]]||[timeEntryBreakUri isEqualToString:@""]||[timeEntryBreakUri isEqualToString:NULL_STRING]||[timeEntryBreakUri isEqualToString:NULL_OBJECT_STRING])
                    {
                        breakUri=[NSNull null];
                    }
                    else
                    {
                        breakUri=timeEntryBreakUri;
                    }
                    NSString *timeEntryBreakName=[NSString stringWithFormat:@"%@",[tsEntryObject breakName]];
                    if (timeEntryBreakName==nil||[timeEntryBreakName isKindOfClass:[NSNull class]]||[timeEntryBreakName isEqualToString:@""]||[timeEntryBreakName isEqualToString:NULL_STRING]||[timeEntryBreakName isEqualToString:NULL_OBJECT_STRING])
                    {
                        breakName=[NSNull null];
                    }
                    else
                    {
                        breakName=timeEntryBreakName;
                    }


                    NSMutableDictionary *infoDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                   programName,@"programName",//MOBI-746
                                                   programUri,@"programUri",//MOBI-746
                                                   clientName,@"clientName",
                                                   clientUri,@"clientUri",
                                                   projectName,@"projectName",
                                                   projectUri,@"projectUri",
                                                   activityName,@"activityName",
                                                   activityUri,@"activityUri",
                                                   billingName,@"billingName",
                                                   billingUri,@"billingUri",
                                                   taskName,@"taskName",
                                                   taskUri,@"taskUri",
                                                   breakName,@"breakName",
                                                   breakUri,@"breakUri",
                                                   nil];

                    if ([timeEntryDate compare:currentDate]!=NSOrderedSame)
                    {


                        if (![activeCellObjectsArray containsObject:infoDict])
                        {
                            if (![distinctProjectUriArray containsObject:infoDict])
                            {


                               {
                                    [distinctProjectUriArray addObject:infoDict];
                               }

                            }

                        }
                    }

                }
            }

        }
        return distinctProjectUriArray;
        }
    }

    return nil;
}

-(NSMutableArray *)createUdfs
{
    int decimalPlace=0;
    LoginModel *loginModel=[[LoginModel alloc]init];
    NSMutableArray *udfArray=[loginModel getEnabledOnlyUDFsforModuleName:TIMESHEET_CELL_UDF];


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

            if ([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[multiDayTimesheetStatus isEqualToString:APPROVED_STATUS] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] ||
                [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED] ) {
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
            if ([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[multiDayTimesheetStatus isEqualToString:APPROVED_STATUS] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] ||
                [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED]) {
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

            if ([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[multiDayTimesheetStatus isEqualToString:APPROVED_STATUS] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] ||
                [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED]) {
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
                        if ([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[multiDayTimesheetStatus isEqualToString:APPROVED_STATUS] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] ||
                            [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED]) {
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
                    if ([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[multiDayTimesheetStatus isEqualToString:APPROVED_STATUS] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] ||
                        [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED]) {
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
            if ([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[multiDayTimesheetStatus isEqualToString:APPROVED_STATUS] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] ||
                [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED]) {
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
                        if (([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[multiDayTimesheetStatus isEqualToString:APPROVED_STATUS ] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] ||
                             [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED])) {
                            [udfDetailDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
                        }
                        else
                            [udfDetailDict setObject:[dictInfo objectForKey: @"defaultValue" ] forKey:@"defaultValue"];


                    }

                }
                else
                {
                    if (([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[multiDayTimesheetStatus isEqualToString:APPROVED_STATUS ] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] ||
                         [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED])) {
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
            if (([multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[multiDayTimesheetStatus isEqualToString:APPROVED_STATUS ] || [multiDayTimesheetStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] ||
                 [multiDayTimesheetStatus isEqualToString:TIMESHEET_SUBMITTED])) {
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



-(BOOL)checkOverlapForPageForExtendedInOut
{
    BOOL isAlertViewShownAlready=NO;
    if (multiInOutTimesheetType==EXTENDED_IN_OUT_TIMESHEET_TYPE && !isOverlapEntryAllowed)
    {
        if ([multiDayTimesheetStatus isEqualToString:NOT_SUBMITTED_STATUS ]||[multiDayTimesheetStatus isEqualToString:REJECTED_STATUS ])
        {

            self.isOverlap=NO;
            self.overlapFromInTime=NO;
            self.overlapFromOutTime=NO;
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            [dateFormat setTimeZone:timeZone];


            NSLocale *locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
            [dateFormat setLocale:locale];


            [dateFormat setDateFormat:@"hh:mm a"];

            if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
            {

                TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;

                BOOL previousPageAvailable=NO;
                if (tsMainPageCtrl.pageControl.currentPage!=0)
                {
                    previousPageAvailable=YES;
                }

                NSMutableArray *previousDayDataArray=nil;
                if (previousPageAvailable)
                {
                    if (tsMainPageCtrl.pageControl.currentPage-1<tsMainPageCtrl.timesheetDataArray.count)
                    {
                        previousDayDataArray=[tsMainPageCtrl.timesheetDataArray objectAtIndex:tsMainPageCtrl.pageControl.currentPage-1];
                    }

                }

                if (tsMainPageCtrl.pageControl.currentPage<tsMainPageCtrl.timesheetDataArray.count)
                {
                    NSMutableArray *currentDayDataArray=[tsMainPageCtrl.timesheetDataArray objectAtIndex:tsMainPageCtrl.pageControl.currentPage];

                    BOOL nextPageAvailable=NO;
                    if (tsMainPageCtrl.pageControl.currentPage+1!=tsMainPageCtrl.viewControllers.count)
                    {
                        nextPageAvailable=YES;
                    }

                    NSMutableArray *nextDayDataArray=nil;
                    if (nextPageAvailable)
                    {
                        if (tsMainPageCtrl.pageControl.currentPage+1<tsMainPageCtrl.timesheetDataArray.count)
                        {
                            nextDayDataArray=[tsMainPageCtrl.timesheetDataArray objectAtIndex:tsMainPageCtrl.pageControl.currentPage+1];
                        }

                    }

                    NSMutableArray *previousDayCrossOverEntriesArray=[NSMutableArray array];
                    for (int i=0; i<[previousDayDataArray count]; i++)
                    {
                        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[previousDayDataArray objectAtIndex:i];
                        NSMutableArray *timePunchesArray=[tsEntryObject timePunchesArray];
                        for (int j=0; j<[timePunchesArray count]; j++)
                        {

                            NSString *inTimeString=[[timePunchesArray objectAtIndex:j] objectForKey:@"in_time"];
                            NSString *outTimeString=[[timePunchesArray objectAtIndex:j] objectForKey:@"out_time"];
                            if (inTimeString!=nil && ![inTimeString isKindOfClass:[NSNull class]] && ![inTimeString isEqualToString:@""] &&outTimeString!=nil && ![outTimeString isKindOfClass:[NSNull class]]&& ![outTimeString isEqualToString:@""])
                            {
                                NSMutableDictionary *inoutDict=[timePunchesArray objectAtIndex:j];
                                BOOL isMidCrossOverForEntry=[Util checkIsMidNightCrossOver:inoutDict];
                                if (isMidCrossOverForEntry)
                                {
                                    [previousDayCrossOverEntriesArray addObject:[timePunchesArray objectAtIndex:j]];
                                }
                            }
                        }

                    }
                    NSSortDescriptor *sortTimeInDescriptor = [[NSSortDescriptor alloc] initWithKey:@"in_time" ascending:TRUE];
                    [previousDayCrossOverEntriesArray sortUsingDescriptors:[NSArray arrayWithObject:sortTimeInDescriptor]];


                    NSMutableArray *allCurrentPunchesArray=[NSMutableArray array];
                    NSMutableArray *allCurrentValidPunchesArray=[NSMutableArray array];
                    for (int i=0; i<[currentDayDataArray count]; i++)
                    {
                        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[currentDayDataArray objectAtIndex:i];
                        NSMutableArray *timePunchesArray=[tsEntryObject timePunchesArray];
                        for (int k=0; k<[timePunchesArray count]; k++)
                        {
                            NSMutableDictionary *timePunchDict=[NSMutableDictionary dictionaryWithDictionary:[timePunchesArray objectAtIndex:k]];
                            [timePunchDict setObject:[NSString stringWithFormat:@"%d",k] forKey:@"Row"];
                            [timePunchDict setObject:[NSString stringWithFormat:@"%d",i] forKey:@"Section"];
                            [timePunchesArray replaceObjectAtIndex:k withObject:timePunchDict];
                        }
                        [allCurrentPunchesArray addObjectsFromArray:timePunchesArray];
                    }
                    [allCurrentPunchesArray sortUsingDescriptors:[NSArray arrayWithObject:sortTimeInDescriptor]];
                    [allCurrentValidPunchesArray addObjectsFromArray:allCurrentPunchesArray];

                    for (int b=0; b<[allCurrentPunchesArray count]; b++)
                    {

                        NSMutableDictionary *timePunchDict=[NSMutableDictionary dictionaryWithDictionary:[allCurrentPunchesArray objectAtIndex:b]];
                        int row=[[timePunchDict objectForKey:@"Row"] intValue];
                        int section=[[timePunchDict objectForKey:@"Section"] intValue];
                        if (row==rowBeingEdited-1 && sectionBeingEdited==section)
                        {
                            [allCurrentValidPunchesArray removeObjectAtIndex:b];
                        }

                    }

                    [allCurrentValidPunchesArray sortUsingDescriptors:[NSArray arrayWithObject:sortTimeInDescriptor]];
                    NSMutableArray *currentValidPunchesArray=[NSMutableArray array];
                    for (int g=0; g<[allCurrentValidPunchesArray count]; g++)
                    {
                        NSMutableDictionary *timePunchDict=[NSMutableDictionary dictionaryWithDictionary:[allCurrentValidPunchesArray objectAtIndex:g]];
                        NSString *inTimeString=[timePunchDict objectForKey:@"in_time"];
                        NSString *outTimeString=[timePunchDict objectForKey:@"out_time"];

                        if (inTimeString!=nil && ![inTimeString isKindOfClass:[NSNull class]] && ![inTimeString isEqualToString:@""] &&outTimeString!=nil && ![outTimeString isKindOfClass:[NSNull class]]&&![outTimeString isEqualToString:@""])
                        {
                            [currentValidPunchesArray addObject:[allCurrentValidPunchesArray objectAtIndex:g]];
                        }

                    }
                    [currentValidPunchesArray sortUsingDescriptors:[NSArray arrayWithObject:sortTimeInDescriptor]];
                    NSMutableArray *allNextPunchesArray=[NSMutableArray array];
                    for (int i=0; i<[nextDayDataArray count]; i++)
                    {
                        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[nextDayDataArray objectAtIndex:i];
                        NSMutableArray *timePunchesArray=[tsEntryObject timePunchesArray];
                        for (int k=0; k<[timePunchesArray count]; k++)
                        {
                            NSMutableDictionary *timePunchDict=[NSMutableDictionary dictionaryWithDictionary:[timePunchesArray objectAtIndex:k]];
                            [timePunchDict setObject:[NSString stringWithFormat:@"%d",k] forKey:@"Row"];
                            [timePunchDict setObject:[NSString stringWithFormat:@"%d",i] forKey:@"Section"];
                            [timePunchesArray replaceObjectAtIndex:k withObject:timePunchDict];
                        }
                        [allNextPunchesArray addObjectsFromArray:timePunchesArray];
                    }
                    [allNextPunchesArray sortUsingDescriptors:[NSArray arrayWithObject:sortTimeInDescriptor]];

                    //########################## OVERLAP LOGIC #########################//


                    //checks for previous page midnight crossovers entries affecting overlap validations in current page and if this fails ie no overlap goes into checking overlap on current page

                    if ([previousDayCrossOverEntriesArray count]!=0)
                    {
                        for (int j=0; j<[allCurrentPunchesArray count]; j++)
                        {

                            NSString *inTimeString=[[allCurrentPunchesArray objectAtIndex:j] objectForKey:@"in_time"];
                            NSString *outTimeString=[[allCurrentPunchesArray objectAtIndex:j] objectForKey:@"out_time"];
                            BOOL isValidEntry=[Util isBothInAndOutEntryPresent:[allCurrentPunchesArray objectAtIndex:j]];
                            if (isValidEntry)
                            {
                                NSDate *currentInDate=[dateFormat dateFromString:inTimeString];
                                NSDate *currentOutDate=[dateFormat dateFromString:outTimeString];
                                for (int m=0; m<[previousDayCrossOverEntriesArray count]; m++)
                                {
                                    NSString *tempInTimeString=@"12:00 am";
                                    NSString *tempOutTimeString=[[previousDayCrossOverEntriesArray objectAtIndex:m] objectForKey:@"out_time"];

                                    NSDate *currentBeginDate=[dateFormat dateFromString:tempInTimeString];
                                    NSDate *currentEndDate=[dateFormat dateFromString:tempOutTimeString];
                                    NSMutableDictionary *inoutDict=[allCurrentPunchesArray objectAtIndex:j];
                                    BOOL isMidCrossOverForEntry=[Util checkIsMidNightCrossOver:inoutDict];
                                    if (!isMidCrossOverForEntry)
                                    {
                                        BOOL isInTimeOverlap=[self isInTimeCompare:YES isOutTimeCompare:NO inDate:currentInDate outDate:currentOutDate betweenBeginDate:currentBeginDate endDate:currentEndDate];

                                        if (isInTimeOverlap)
                                        {

                                            self.isOverlap=YES;
                                            self.overlapRow=rowBeingEdited-1;
                                            self.overlapSection=sectionBeingEdited;

                                            if (isOverlapOnReverseLogic)
                                            {
                                                if (editTextFieldTag==1111)
                                                {
                                                    self.overlapFromInTime=YES;
                                                    NSLog(@"isInTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);
                                                }
                                                else
                                                {
                                                    self.overlapFromOutTime=YES;
                                                    NSLog(@"isOutTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);
                                                }
                                            }
                                            else
                                            {
                                                self.overlapFromInTime=YES;
                                                NSLog(@"isInTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);
                                            }




                                        }

                                        BOOL isOutTimeOverlap=[self isInTimeCompare:NO isOutTimeCompare:YES inDate:currentInDate outDate:currentOutDate betweenBeginDate:currentBeginDate endDate:currentEndDate];
                                        if (isOutTimeOverlap)
                                        {
                                            self.isOverlap=YES;
                                            self.overlapRow=rowBeingEdited-1;
                                            self.overlapSection=sectionBeingEdited;
                                            if (isOverlapOnReverseLogic)
                                            {
                                                if (editTextFieldTag==1111)
                                                {
                                                    self.overlapFromInTime=YES;
                                                    NSLog(@"isInTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);
                                                }
                                                else
                                                {
                                                    self.overlapFromOutTime=YES;
                                                    NSLog(@"isOutTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);
                                                }
                                            }
                                            else
                                            {
                                                self.overlapFromOutTime=YES;
                                                NSLog(@"isOutTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);

                                            }





                                        }

                                        if (isOverlap)
                                        {
                                            NSLog(@"OVERLAP FROM PREVIOUS PAGE ENTRY ON CURRENT PAGE");
                                            break;
                                        }

                                    }
                                    else
                                    {
                                        BOOL isInTimeOverlap=[self isInTimeCompare:YES isOutTimeCompare:NO inDate:currentInDate outDate:currentOutDate betweenBeginDate:currentBeginDate endDate:currentEndDate];

                                        if (isInTimeOverlap)
                                        {

                                            self.isOverlap=YES;
                                            self.overlapRow=rowBeingEdited-1;
                                            self.overlapSection=sectionBeingEdited;
                                            if (isOverlapOnReverseLogic)
                                            {
                                                if (editTextFieldTag==1111)
                                                {
                                                    self.overlapFromInTime=YES;
                                                    NSLog(@"isInTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);
                                                }
                                                else
                                                {
                                                    self.overlapFromOutTime=YES;
                                                    NSLog(@"isOutTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);
                                                }
                                            }
                                            else
                                            {
                                                self.overlapFromInTime=YES;
                                                NSLog(@"isInTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);
                                            }





                                        }

                                        if (isOverlap)
                                        {
                                            NSLog(@"OVERLAP FROM PREVIOUS PAGE ENTRY ON CURRENT PAGE");
                                            break;
                                        }

                                    }


                                }

                            }
                        }
                    }

                    TimesheetEntryObject *editedEntryObject=(TimesheetEntryObject *)[currentDayDataArray objectAtIndex:sectionBeingEdited];
                    NSMutableDictionary *inoutDict=[[editedEntryObject timePunchesArray] objectAtIndex:rowBeingEdited-1];
                    NSString *inTimeString=[inoutDict objectForKey:@"in_time"];
                    NSString *outTimeString=[inoutDict objectForKey:@"out_time"];
                    BOOL isValidEntry=[Util isBothInAndOutEntryPresent:inoutDict];
                    if (isValidEntry)
                    {
                        BOOL isMidCrossOverForEntry=[Util checkIsMidNightCrossOver:inoutDict];

                        //checks for entrire current page overlap validations and if this fails ie no overlap on current page goes into checking overlap on next page

                        for (int y=0; y<[currentValidPunchesArray count]; y++)
                        {

                            NSMutableDictionary *infoDict=[currentValidPunchesArray objectAtIndex:y];
                            NSString *otherInTimeString=[infoDict objectForKey:@"in_time"];
                            NSString *otherOutTimeString=[infoDict objectForKey:@"out_time"];
                            NSMutableDictionary *tempDict=[NSMutableDictionary dictionary];
                            [tempDict setObject:inTimeString forKey:@"in_time"];
                            [tempDict setObject:outTimeString forKey:@"out_time"];
                            BOOL isMidCrossOver=[Util checkIsMidNightCrossOver:tempDict];
                            if (isMidCrossOver)
                            {
                                //Fix for MOBI-104//JUHI
                                // outTimeString=@"11:59 pm";
                            }
                            NSDate *currentInDate=[dateFormat dateFromString:inTimeString];
                            NSDate *currentOutDate=[dateFormat dateFromString:outTimeString];
                            BOOL isMidCrossOverForEntry=[Util checkIsMidNightCrossOver:infoDict];
                            if (!isMidCrossOverForEntry)
                            {
                                NSDate *currentBeginDate=[dateFormat dateFromString:otherInTimeString];
                                NSDate *currentEndDate=[dateFormat dateFromString:otherOutTimeString];

                                BOOL isInTimeOverlap=[self isInTimeCompare:YES isOutTimeCompare:NO inDate:currentInDate outDate:currentOutDate betweenBeginDate:currentBeginDate endDate:currentEndDate];

                                if (isInTimeOverlap)
                                {

                                    self.isOverlap=YES;
                                    self.overlapRow=rowBeingEdited-1;
                                    self.overlapSection=sectionBeingEdited;
                                    if (isOverlapOnReverseLogic)
                                    {
                                        if (editTextFieldTag==1111)
                                        {
                                            self.overlapFromInTime=YES;
                                            NSLog(@"isInTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);
                                        }
                                        else
                                        {
                                            self.overlapFromOutTime=YES;
                                            NSLog(@"isOutTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);
                                        }
                                    }
                                    else
                                    {
                                        self.overlapFromInTime=YES;
                                        NSLog(@"isInTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);

                                    }



                                }

                                BOOL isOutTimeOverlap=[self isInTimeCompare:NO isOutTimeCompare:YES inDate:currentInDate outDate:currentOutDate betweenBeginDate:currentBeginDate endDate:currentEndDate];
                                if (isOutTimeOverlap)
                                {
                                    self.isOverlap=YES;
                                    self.overlapRow=rowBeingEdited-1;
                                    self.overlapSection=sectionBeingEdited;
                                    if (isOverlapOnReverseLogic)
                                    {
                                        if (editTextFieldTag==1111)
                                        {
                                            self.overlapFromInTime=YES;
                                            NSLog(@"isInTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);
                                        }
                                        else
                                        {
                                            self.overlapFromOutTime=YES;
                                            NSLog(@"isOutTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);
                                        }
                                    }
                                    else
                                    {
                                        self.overlapFromOutTime=YES;
                                        NSLog(@"isOutTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);
                                    }



                                }

                                if (isOverlap)
                                {
                                    NSLog(@"OVERLAP FROM CURRENT PAGE ENTRY ON CURRENT PAGE");
                                    break;
                                }

                            }
                            else
                            {
                                NSMutableDictionary *inoutDict=[[editedEntryObject timePunchesArray] objectAtIndex:rowBeingEdited-1];
                                if ([Util checkIsMidNightCrossOver:inoutDict])
                                {
                                    outTimeString=@"11:59 pm";
                                    currentOutDate=[dateFormat dateFromString:outTimeString];
                                }
                                otherOutTimeString=@"11:59 pm";
                                NSDate *currentBeginDate=[dateFormat dateFromString:otherInTimeString];
                                NSDate *currentEndDate=[dateFormat dateFromString:otherOutTimeString];
                                BOOL isInTimeOverlap=[self isInTimeCompare:YES isOutTimeCompare:NO inDate:currentInDate outDate:currentOutDate betweenBeginDate:currentBeginDate endDate:currentEndDate];

                                if (isInTimeOverlap)
                                {

                                    self.isOverlap=YES;
                                    self.overlapRow=rowBeingEdited-1;
                                    self.overlapSection=sectionBeingEdited;
                                    if (isOverlapOnReverseLogic)
                                    {
                                        if (editTextFieldTag==1111)
                                        {
                                            self.overlapFromInTime=YES;
                                            NSLog(@"isInTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);
                                        }
                                        else
                                        {
                                            self.overlapFromOutTime=YES;
                                            NSLog(@"isOutTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);
                                        }
                                    }
                                    else
                                    {
                                        self.overlapFromInTime=YES;
                                        NSLog(@"isInTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);
                                    }



                                }

                                BOOL isOutTimeOverlap=[self isInTimeCompare:NO isOutTimeCompare:YES inDate:currentInDate outDate:currentOutDate betweenBeginDate:currentBeginDate endDate:currentEndDate];
                                if (isOutTimeOverlap)
                                {
                                    self.isOverlap=YES;
                                    self.overlapRow=rowBeingEdited-1;
                                    self.overlapSection=sectionBeingEdited;
                                    if (isOverlapOnReverseLogic)
                                    {
                                        if (editTextFieldTag==1111)
                                        {
                                            self.overlapFromInTime=YES;
                                            NSLog(@"isInTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);
                                        }
                                        else
                                        {
                                            self.overlapFromOutTime=YES;
                                            NSLog(@"isOutTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);
                                        }
                                    }
                                    else
                                    {
                                        self.overlapFromOutTime=YES;
                                        NSLog(@"isOutTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);
                                    }



                                }

                                if (isOverlap)
                                {
                                    NSLog(@"OVERLAP FROM CURRENT PAGE ENTRY ON CURRENT PAGE");
                                    break;
                                }


                            }


                        }


                        //checks for entrire current page overlap validations and if this fails ie no overlap on current page goes into checking overlap on next page
                        if (isMidCrossOverForEntry)
                        {//Fix for MOBI-104//JUHI
                            //inTimeString=@"12:00 am";
                            NSDate *currentInDate=[dateFormat dateFromString:inTimeString];
                            NSDate *currentOutDate=[dateFormat dateFromString:outTimeString];
                            for (int j=0; j<[allNextPunchesArray count]; j++)
                            {

                                NSString *otherInTimeString=[[allNextPunchesArray objectAtIndex:j] objectForKey:@"in_time"];
                                NSString *otherOutTimeString=[[allNextPunchesArray objectAtIndex:j] objectForKey:@"out_time"];
                                BOOL isValidEntry=[Util isBothInAndOutEntryPresent:[allNextPunchesArray objectAtIndex:j]];
                                if (isValidEntry)
                                {
                                    NSMutableDictionary *inoutDict=[allNextPunchesArray objectAtIndex:j];
                                    BOOL isMidCrossOverForEntry=[Util checkIsMidNightCrossOver:inoutDict];
                                    NSDate *currentBeginDate=[dateFormat dateFromString:otherInTimeString];
                                    NSDate *currentEndDate=[dateFormat dateFromString:otherOutTimeString];
                                    if (!isMidCrossOverForEntry)
                                    {

                                        BOOL isInTimeOverlap=[self isInTimeCompare:YES isOutTimeCompare:NO inDate:currentInDate outDate:currentOutDate betweenBeginDate:currentBeginDate endDate:currentEndDate];

                                        if (isInTimeOverlap)
                                        {

                                            self.isOverlap=YES;
                                            self.overlapRow=rowBeingEdited-1;
                                            self.overlapSection=sectionBeingEdited;
                                            if (isOverlapOnReverseLogic)
                                            {
                                                if (editTextFieldTag==1111)
                                                {
                                                    self.overlapFromInTime=YES;
                                                    NSLog(@"isInTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);
                                                }
                                                else
                                                {
                                                    self.overlapFromOutTime=YES;
                                                    NSLog(@"isOutTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);
                                                }
                                            }
                                            else
                                            {
                                                self.overlapFromInTime=YES;
                                                NSLog(@"isOutTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);

                                            }




                                        }

                                        BOOL isOutTimeOverlap=[self isInTimeCompare:NO isOutTimeCompare:YES inDate:currentInDate outDate:currentOutDate betweenBeginDate:currentBeginDate endDate:currentEndDate];
                                        if (isOutTimeOverlap)
                                        {
                                            
                                            self.isOverlap=YES;
                                            self.overlapRow=rowBeingEdited-1;
                                            self.overlapSection=sectionBeingEdited;
                                            if (isOverlapOnReverseLogic)
                                            {
                                                if (editTextFieldTag==1111)
                                                {
                                                    self.overlapFromInTime=YES;
                                                    NSLog(@"isInTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);
                                                }
                                                else
                                                {
                                                    self.overlapFromOutTime=YES;
                                                    NSLog(@"isOutTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);
                                                }
                                            }
                                            else
                                            {
                                                self.overlapFromOutTime=YES;
                                                NSLog(@"isOutTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);
                                            }
                                            
                                            
                                            
                                            
                                        }
                                        
                                        if (isOverlap)
                                        {
                                            NSLog(@"OVERLAP FROM CURRENT PAGE ENTRY ON NEXT PAGE");
                                            break;
                                        }
                                        
                                    }
                                    else
                                    {
                                        NSDate *currentEndDate=[dateFormat dateFromString:@"11:59 pm"];
                                        BOOL isOutTimeOverlap=[self isInTimeCompare:NO isOutTimeCompare:YES inDate:currentInDate outDate:currentOutDate betweenBeginDate:currentBeginDate endDate:currentEndDate];
                                        
                                        if (isOutTimeOverlap)
                                        {
                                            
                                            self.isOverlap=YES;
                                            self.overlapRow=rowBeingEdited-1;
                                            self.overlapSection=sectionBeingEdited;
                                            if (isOverlapOnReverseLogic)
                                            {
                                                if (editTextFieldTag==1111)
                                                {
                                                    self.overlapFromInTime=YES;
                                                    NSLog(@"isInTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);
                                                }
                                                else
                                                {
                                                    self.overlapFromOutTime=YES;
                                                    NSLog(@"isOutTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);
                                                }
                                            }
                                            else
                                            {
                                                self.overlapFromOutTime=YES;
                                                NSLog(@"isOutTimeOverlap Row:%d Section:%d",overlapRow,overlapSection);
                                            }
                                            
                                            
                                            
                                            
                                        }
                                        if (isOverlap)
                                        {
                                            NSLog(@"OVERLAP FROM CURRENT PAGE ENTRY ON NEXT PAGE");
                                            break;
                                        }
                                        
                                    }
                                    
                                    
                                }
                            }
                        }
                        
                    }
                }

            }

        }
    }


    if (isOverlap)
    {
        if (!isAlertViewShownAlready)
        {

            [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                           otherButtonTitle:nil
                                                   delegate:self
                                                    message:nil
                                                      title:RPLocalizedString(Overlap_Extended_Msg, @"")
                                                        tag:OVERLAP_ON_EDIT_ALERT_TAG];

        }




    }
    return isOverlap;

}

-(void)checkOverlapForPageForExtendedInOutOnLoadForPage:(NSString *)currentPageString
{
    int currentPage=[currentPageString intValue];
    BOOL isAlertViewShownAlready=NO;
    if (multiInOutTimesheetType==EXTENDED_IN_OUT_TIMESHEET_TYPE)
    {
        if ([multiDayTimesheetStatus isEqualToString:NOT_SUBMITTED_STATUS ]||[multiDayTimesheetStatus isEqualToString:REJECTED_STATUS ])
        {
            self.isOverlap=NO;
            self.overlapFromInTime=NO;
            self.overlapFromOutTime=NO;
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            [dateFormat setTimeZone:timeZone];


            NSLocale *locale=[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
            [dateFormat setLocale:locale];
            [dateFormat setDateFormat:@"hh:mm a"];

            if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
            {

                TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;

                BOOL previousPageAvailable=NO;
                if (currentPage!=0)
                {
                    previousPageAvailable=YES;
                }

                NSMutableArray *previousDayDataArray=nil;
                if (previousPageAvailable)
                {
                    if (currentPage-1<tsMainPageCtrl.timesheetDataArray.count)
                    {
                        previousDayDataArray=[tsMainPageCtrl.timesheetDataArray objectAtIndex:currentPage-1];
                    }

                }

                if (currentPage<tsMainPageCtrl.timesheetDataArray.count)
                {
                    NSMutableArray *currentDayDataArray=[tsMainPageCtrl.timesheetDataArray objectAtIndex:currentPage];

                    BOOL nextPageAvailable=NO;
                    if (currentPage+1!=tsMainPageCtrl.viewControllers.count)
                    {
                        nextPageAvailable=YES;
                    }

                    NSMutableArray *nextDayDataArray=nil;
                    if (nextPageAvailable)
                    {
                        nextDayDataArray=[tsMainPageCtrl.timesheetDataArray objectAtIndex:currentPage+1];
                    }
                    NSSortDescriptor *sortTimeInDescriptor = [[NSSortDescriptor alloc] initWithKey:@"in_time" ascending:TRUE];
                    NSMutableArray *previousDayCrossOverEntriesArray=[NSMutableArray array];
                    for (int i=0; i<[previousDayDataArray count]; i++)
                    {
                        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[previousDayDataArray objectAtIndex:i];
                        NSMutableArray *timePunchesArray=[tsEntryObject timePunchesArray];
                        for (int j=0; j<[timePunchesArray count]; j++)
                        {

                            NSString *inTimeString=[[timePunchesArray objectAtIndex:j] objectForKey:@"in_time"];
                            NSString *outTimeString=[[timePunchesArray objectAtIndex:j] objectForKey:@"out_time"];
                            if (inTimeString!=nil && ![inTimeString isKindOfClass:[NSNull class]] && ![inTimeString isEqualToString:@""] &&outTimeString!=nil && ![outTimeString isKindOfClass:[NSNull class]]&& ![outTimeString isEqualToString:@""])
                            {
                                NSMutableDictionary *inoutDict=[timePunchesArray objectAtIndex:j];
                                BOOL isMidCrossOverForEntry=[Util checkIsMidNightCrossOver:inoutDict];
                                if (isMidCrossOverForEntry)
                                {
                                    [previousDayCrossOverEntriesArray addObject:[timePunchesArray objectAtIndex:j]];
                                }
                            }
                        }

                    }
                    [previousDayCrossOverEntriesArray sortUsingDescriptors:[NSArray arrayWithObject:sortTimeInDescriptor]];


                    NSMutableArray *allCurrentPunchesArray=[NSMutableArray array];
                    for (int i=0; i<[currentDayDataArray count]; i++)
                    {
                        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[currentDayDataArray objectAtIndex:i];
                        NSMutableArray *timePunchesArray=[tsEntryObject timePunchesArray];
                        for (int k=0; k<[timePunchesArray count]; k++)
                        {
                            NSMutableDictionary *timePunchDict=[NSMutableDictionary dictionaryWithDictionary:[timePunchesArray objectAtIndex:k]];
                            [timePunchDict setObject:[NSString stringWithFormat:@"%d",k] forKey:@"Row"];
                            [timePunchDict setObject:[NSString stringWithFormat:@"%d",i] forKey:@"Section"];
                            [timePunchesArray replaceObjectAtIndex:k withObject:timePunchDict];
                        }
                        [allCurrentPunchesArray addObjectsFromArray:timePunchesArray];
                    }
                    [allCurrentPunchesArray sortUsingDescriptors:[NSArray arrayWithObject:sortTimeInDescriptor]];

                    NSMutableArray *allNextPunchesArray=[NSMutableArray array];
                    for (int i=0; i<[nextDayDataArray count]; i++)
                    {
                        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[nextDayDataArray objectAtIndex:i];
                        NSMutableArray *timePunchesArray=[tsEntryObject timePunchesArray];
                        for (int k=0; k<[timePunchesArray count]; k++)
                        {
                            NSMutableDictionary *timePunchDict=[NSMutableDictionary dictionaryWithDictionary:[timePunchesArray objectAtIndex:k]];
                            [timePunchDict setObject:[NSString stringWithFormat:@"%d",k] forKey:@"Row"];
                            [timePunchDict setObject:[NSString stringWithFormat:@"%d",i] forKey:@"Section"];
                            [timePunchesArray replaceObjectAtIndex:k withObject:timePunchDict];
                        }
                        [allNextPunchesArray addObjectsFromArray:timePunchesArray];
                    }
                    [allNextPunchesArray sortUsingDescriptors:[NSArray arrayWithObject:sortTimeInDescriptor]];

                    //########################## OVERLAP LOGIC #########################//

                    //checks for previous page midnight crossovers entries affecting overlap validations in current page and if this fails ie no overlap goes into checking overlap on current page
                    if ([previousDayCrossOverEntriesArray count]!=0)
                    {
                        for (int j=0; j<[allCurrentPunchesArray count]; j++)
                        {

                            NSString *inTimeString=[[allCurrentPunchesArray objectAtIndex:j] objectForKey:@"in_time"];
                            NSString *outTimeString=[[allCurrentPunchesArray objectAtIndex:j] objectForKey:@"out_time"];
                            BOOL isValidEntry=[Util isBothInAndOutEntryPresent:[allCurrentPunchesArray objectAtIndex:j]];
                            if (isValidEntry)
                            {

                                NSDate *currentInDate=[dateFormat dateFromString:inTimeString];
                                NSDate *currentOutDate=[dateFormat dateFromString:outTimeString];
                                for (int m=0; m<[previousDayCrossOverEntriesArray count]; m++)
                                {
                                    NSString *tempInTimeString=@"12:00 am";
                                    NSString *tempOutTimeString=[[previousDayCrossOverEntriesArray objectAtIndex:m] objectForKey:@"out_time"];

                                    NSDate *currentBeginDate=[dateFormat dateFromString:tempInTimeString];
                                    NSDate *currentEndDate=[dateFormat dateFromString:tempOutTimeString];
                                    NSMutableDictionary *inoutDict=[allCurrentPunchesArray objectAtIndex:j];
                                    BOOL isMidCrossOverForEntry=[Util checkIsMidNightCrossOver:inoutDict];
                                    if (!isMidCrossOverForEntry)
                                    {
                                        BOOL isInTimeOverlap=[self isInTimeCompareForLoad:YES isOutTimeCompare:NO inDate:currentInDate outDate:currentOutDate betweenBeginDate:currentBeginDate endDate:currentEndDate];

                                        if (isInTimeOverlap)
                                        {
                                            self.isOverlap=YES;
                                        }

                                        BOOL isOutTimeOverlap=[self isInTimeCompareForLoad:NO isOutTimeCompare:YES inDate:currentInDate outDate:currentOutDate betweenBeginDate:currentBeginDate endDate:currentEndDate];
                                        if (isOutTimeOverlap)
                                        {
                                            self.isOverlap=YES;

                                        }

                                        if (isOverlap)
                                        {
                                            NSLog(@"OVERLAP FROM PREVIOUS PAGE ENTRY ON CURRENT PAGE");
                                            break;
                                        }

                                    }
                                    else
                                    {
                                        BOOL isInTimeOverlap=[self isInTimeCompareForLoad:YES isOutTimeCompare:NO inDate:currentInDate outDate:currentOutDate betweenBeginDate:currentBeginDate endDate:currentEndDate];

                                        if (isInTimeOverlap)
                                        {

                                            self.isOverlap=YES;

                                        }

                                        if (isOverlap)
                                        {
                                            NSLog(@"OVERLAP FROM PREVIOUS PAGE ENTRY ON CURRENT PAGE");
                                            break;
                                        }

                                    }


                                }

                            }
                        }
                    }

                    NSMutableArray *currentValidPunchesArray=[NSMutableArray array];
                    [currentValidPunchesArray addObjectsFromArray:allCurrentPunchesArray];
                    for (int g=0; g<[allCurrentPunchesArray count]; g++)
                    {
                        NSMutableDictionary *timePunchDict=[NSMutableDictionary dictionaryWithDictionary:[allCurrentPunchesArray objectAtIndex:g]];
                        BOOL isValidEntry=[Util isBothInAndOutEntryPresent:timePunchDict];
                        if (!isValidEntry)
                        {
                            [currentValidPunchesArray removeObjectIdenticalTo:[allCurrentPunchesArray objectAtIndex:g]];
                        }
                    }
                    for (int j=0; j<[allCurrentPunchesArray count]; j++)
                    {
                        NSMutableDictionary *inoutDict=[allCurrentPunchesArray objectAtIndex:j];
                        NSString *inTimeString=[inoutDict objectForKey:@"in_time"];
                        NSString *outTimeString=[inoutDict objectForKey:@"out_time"];
                        BOOL isValidEntry=[Util isBothInAndOutEntryPresent:inoutDict];
                        if (isValidEntry)
                        {
                            BOOL isMidCrossOverForEntry=[Util checkIsMidNightCrossOver:inoutDict];

                            //checks for entrire current page overlap validations and if this fails ie no overlap on current page goes into checking overlap on next page

                            if ([currentValidPunchesArray count]>1)
                            {
                                for (int y=0; y<[currentValidPunchesArray count]; y++)
                                {

                                    NSMutableDictionary *infoDict=[currentValidPunchesArray objectAtIndex:y];
                                    NSString *otherInTimeString=[infoDict objectForKey:@"in_time"];
                                    NSString *otherOutTimeString=[infoDict objectForKey:@"out_time"];
                                    NSDate *currentInDate=[dateFormat dateFromString:inTimeString];
                                    NSDate *currentOutDate=[dateFormat dateFromString:outTimeString];
                                    BOOL isMidCrossOverForEntry=[Util checkIsMidNightCrossOver:infoDict];
                                    if (!isMidCrossOverForEntry)
                                    {

                                        if (![otherInTimeString isEqualToString:inTimeString]&&![otherOutTimeString isEqualToString:outTimeString])
                                        {
                                            NSDate *currentBeginDate=[dateFormat dateFromString:otherInTimeString];
                                            NSDate *currentEndDate=[dateFormat dateFromString:otherOutTimeString];
                                            BOOL isInTimeOverlap=[self isInTimeCompareForLoad:YES isOutTimeCompare:NO inDate:currentInDate outDate:currentOutDate betweenBeginDate:currentBeginDate endDate:currentEndDate];
                                            if (isInTimeOverlap)
                                            {
                                                self.isOverlap=YES;


                                            }

                                            BOOL isOutTimeOverlap=[self isInTimeCompareForLoad:NO isOutTimeCompare:YES inDate:currentInDate outDate:currentOutDate betweenBeginDate:currentBeginDate endDate:currentEndDate];
                                            if (isOutTimeOverlap)
                                            {
                                                self.isOverlap=YES;


                                            }
                                            if (isOverlap)
                                            {
                                                NSLog(@"OVERLAP FROM CURRENT PAGE ENTRY ON CURRENT PAGE");
                                                break;
                                            }

                                        }

                                    }
                                    else
                                    {

                                        otherOutTimeString=@"11:59 pm";
                                        NSDate *currentBeginDate=[dateFormat dateFromString:otherInTimeString];
                                        NSDate *currentEndDate=[dateFormat dateFromString:otherOutTimeString];
                                        BOOL isInTimeOverlap=[self isInTimeCompareForLoad:YES isOutTimeCompare:NO inDate:currentInDate outDate:currentOutDate betweenBeginDate:currentBeginDate endDate:currentEndDate];

                                        if (isInTimeOverlap)
                                        {

                                            self.isOverlap=YES;


                                        }

                                        BOOL isOutTimeOverlap=[self isInTimeCompareForLoad:NO isOutTimeCompare:YES inDate:currentInDate outDate:currentOutDate betweenBeginDate:currentBeginDate endDate:currentEndDate];
                                        if (isOutTimeOverlap)
                                        {
                                            self.isOverlap=YES;


                                        }

                                        if (isOverlap)
                                        {
                                            NSLog(@"OVERLAP FROM CURRENT PAGE ENTRY ON CURRENT PAGE");
                                            break;
                                        }


                                    }


                                }

                            }


                            //checks for entrire current page overlap validations and if this fails ie no overlap on current page goes into checking overlap on next page

                            if (isMidCrossOverForEntry)
                            {
                                inTimeString=@"12:00 am";
                                NSDate *currentInDate=[dateFormat dateFromString:inTimeString];
                                NSDate *currentOutDate=[dateFormat dateFromString:outTimeString];
                                for (int j=0; j<[allNextPunchesArray count]; j++)
                                {

                                    NSString *otherInTimeString=[[allNextPunchesArray objectAtIndex:j] objectForKey:@"in_time"];
                                    NSString *otherOutTimeString=[[allNextPunchesArray objectAtIndex:j] objectForKey:@"out_time"];
                                    BOOL isValidEntry=[Util isBothInAndOutEntryPresent:[allNextPunchesArray objectAtIndex:j]];
                                    if (isValidEntry)
                                    {
                                        NSMutableDictionary *inoutDict=[allNextPunchesArray objectAtIndex:j];
                                        BOOL isMidCrossOverForEntry=[Util checkIsMidNightCrossOver:inoutDict];
                                        NSDate *currentBeginDate=[dateFormat dateFromString:otherInTimeString];
                                        NSDate *currentEndDate=[dateFormat dateFromString:otherOutTimeString];
                                        if (!isMidCrossOverForEntry)
                                        {
                                            
                                            BOOL isInTimeOverlap=[self isInTimeCompareForLoad:YES isOutTimeCompare:NO inDate:currentInDate outDate:currentOutDate betweenBeginDate:currentBeginDate endDate:currentEndDate];
                                            
                                            if (isInTimeOverlap)
                                            {
                                                
                                                self.isOverlap=YES;
                                                
                                            }
                                            
                                            BOOL isOutTimeOverlap=[self isInTimeCompareForLoad:NO isOutTimeCompare:YES inDate:currentInDate outDate:currentOutDate betweenBeginDate:currentBeginDate endDate:currentEndDate];
                                            if (isOutTimeOverlap)
                                            {
                                                
                                                self.isOverlap=YES;
                                                
                                            }
                                            
                                            if (isOverlap)
                                            {
                                                NSLog(@"OVERLAP FROM CURRENT PAGE ENTRY ON NEXT PAGE");
                                                break;
                                            }
                                            
                                        }
                                        else
                                        {
                                            NSDate *currentEndDate=[dateFormat dateFromString:@"11:59 pm"];
                                            BOOL isOutTimeOverlap=[self isInTimeCompareForLoad:NO isOutTimeCompare:YES inDate:currentInDate outDate:currentOutDate betweenBeginDate:currentBeginDate endDate:currentEndDate];
                                            
                                            if (isOutTimeOverlap)
                                            {
                                                
                                                self.isOverlap=YES;
                                                
                                            }
                                            if (isOverlap)
                                            {
                                                NSLog(@"OVERLAP FROM CURRENT PAGE ENTRY ON NEXT PAGE");
                                                break;
                                            }
                                            
                                        }
                                        
                                        
                                    }
                                }
                            }
                            
                        }
                    }
                }

            }

        }
    }


    if (isOverlap)
    {
        if (!isAlertViewShownAlready)
        {
            [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                           otherButtonTitle:nil
                                                   delegate:self
                                                    message:nil
                                                      title:RPLocalizedString(Overlap_Extended_Load_Msg, @"")
                                                        tag:OVERLAP_ON_LOAD_ALERT_TAG];

        }


    }

}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView tag]==OVERLAP_ON_EDIT_ALERT_TAG && buttonIndex==0)
    {
        NSLog(@"OVERLAP OK :: ROW:%d SECTION%d",self.overlapRow,self.overlapSection);
        NSIndexPath* cellIndexPath = [NSIndexPath indexPathForRow:self.overlapRow+1 inSection:self.overlapSection];
        NSMutableArray *inoutObjArray=[inoutTsObjectsArray objectAtIndex:self.overlapSection];
        InOutTimesheetEntry *tmpObj=(InOutTimesheetEntry *)[inoutObjArray objectAtIndex:self.overlapRow];
        if(overlapFromInTime && overlapFromOutTime)
        {
            [tmpObj setStartTime:-1];
            [tmpObj setEndTime:-1];
            [tmpObj setIsMidnightCrossover:NO];
            [tmpObj setHours:@"0.00"];
            [tmpObj setCrossoverHours:@""];
        }
        else if (overlapFromInTime)
        {
            [tmpObj setStartTime:-1];
            [tmpObj setIsMidnightCrossover:NO];
            [tmpObj setHours:@"0.00"];
            [tmpObj setCrossoverHours:@""];
        }
        else if (overlapFromOutTime)
        {
            [tmpObj setEndTime:-1];
            [tmpObj setIsMidnightCrossover:NO];
            [tmpObj setHours:@"0.00"];
            [tmpObj setCrossoverHours:@""];
        }

        [inoutObjArray replaceObjectAtIndex:self.overlapRow withObject:tmpObj];
        [inoutTsObjectsArray replaceObjectAtIndex:self.overlapSection withObject:inoutObjArray];


        if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
        {
            TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;
            if (tsMainPageCtrl.pageControl.currentPage<tsMainPageCtrl.timesheetDataArray.count)
            {
                NSMutableArray *array=[tsMainPageCtrl.timesheetDataArray objectAtIndex:tsMainPageCtrl.pageControl.currentPage];
                if(array.count>self.overlapSection)
                {
                    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[array objectAtIndex:self.overlapSection];
                    NSMutableArray *timePunchesArray=[tsEntryObject timePunchesArray];
                    NSMutableDictionary *timePunchDict=[NSMutableDictionary dictionaryWithDictionary:[timePunchesArray objectAtIndex:self.overlapRow]];
                    if(overlapFromInTime && overlapFromOutTime)
                    {
                        [timePunchDict setObject:@"" forKey:@"in_time"];
                        [timePunchDict setObject:@"" forKey:@"out_time"];
                    }
                    else if (overlapFromInTime)
                    {
                        [timePunchDict setObject:@"" forKey:@"in_time"];
                    }
                    else if (overlapFromOutTime)
                    {
                        [timePunchDict setObject:@"" forKey:@"out_time"];
                    }


                    [timePunchesArray replaceObjectAtIndex:self.overlapRow withObject:timePunchDict];
                    [tsEntryObject setTimePunchesArray:timePunchesArray];
                    [array replaceObjectAtIndex:self.overlapSection withObject:tsEntryObject];
                    [tsMainPageCtrl.timesheetDataArray replaceObjectAtIndex:tsMainPageCtrl.pageControl.currentPage withObject:array];
                }
            }

        }
        [self calculateAndUpdateTotalHoursValueForFooter];
        [self.multiDayTimeEntryTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:cellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        ExtendedInOutCell* nextCell = (ExtendedInOutCell*)[self.multiDayTimeEntryTableView cellForRowAtIndexPath:cellIndexPath];
        if(nextCell)
        {
            if(overlapFromInTime && overlapFromOutTime)
            {
                [nextCell setInTimeFocus];
            }
            else if (overlapFromInTime)
            {
                [nextCell setInTimeFocus];
            }
            else if (overlapFromOutTime)
            {
                [nextCell setOutTimeFocus];
            }



        }

    }
}


- (BOOL)isInTimeCompare:(BOOL)isInTimeCompare isOutTimeCompare:(BOOL)isOutTimeCompare inDate:(NSDate *)inCompareDate outDate:(NSDate *)outCompareDate betweenBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate
{
    self.isOverlapOnReverseLogic=NO;
    BOOL isOverLapEntry=NO;
    NSDate *compareDate=nil;
    NSDate *revereseCompareDate=nil;
    if (isInTimeCompare)
    {
        compareDate=inCompareDate;
        revereseCompareDate=beginDate;
    }
    else
    {
        compareDate=outCompareDate;
        revereseCompareDate=endDate;
    }

    if (([inCompareDate compare:beginDate] == NSOrderedSame ) && ([outCompareDate compare:endDate] == NSOrderedSame))
    {
        isOverLapEntry=YES;
    }
    else if (([compareDate compare:beginDate] == NSOrderedDescending ) && ([compareDate compare:endDate] == NSOrderedAscending))
    {
        isOverLapEntry=YES;
    }
    else if (([revereseCompareDate compare:inCompareDate] == NSOrderedDescending ) && ([revereseCompareDate compare:outCompareDate] == NSOrderedAscending))
    {
        isOverLapEntry=YES;
        self.isOverlapOnReverseLogic=YES;
    }//Fix for MOBI-104//JUHI
    else if ([revereseCompareDate compare:compareDate] == NSOrderedSame && !isInTimeCompare)
    {
        isOverLapEntry=YES;
        self.isOverlapOnReverseLogic=YES;
    }

    //https://gist.github.com/mmackh/5978268
    return isOverLapEntry;
}
- (BOOL)isInTimeCompareForLoad:(BOOL)isInTimeCompare isOutTimeCompare:(BOOL)isOutTimeCompare inDate:(NSDate *)inCompareDate outDate:(NSDate *)outCompareDate betweenBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate
{

    BOOL isOverLapEntry=NO;
    NSDate *compareDate=nil;
    NSDate *revereseCompareDate=nil;
    if (isInTimeCompare)
    {
        compareDate=inCompareDate;
        revereseCompareDate=beginDate;
    }
    else
    {
        compareDate=outCompareDate;
        revereseCompareDate=endDate;
    }

    if (([inCompareDate compare:beginDate] == NSOrderedSame ) && ([outCompareDate compare:endDate] == NSOrderedSame))
    {
        isOverLapEntry=YES;
    }
    else if (([compareDate compare:beginDate] == NSOrderedDescending ) && ([compareDate compare:endDate] == NSOrderedAscending))
    {
        isOverLapEntry=YES;
    }
    else if (([revereseCompareDate compare:inCompareDate] == NSOrderedDescending ) && ([revereseCompareDate compare:outCompareDate] == NSOrderedAscending))
    {
        isOverLapEntry=YES;

    }
    else if ([inCompareDate compare:beginDate] == NSOrderedSame)
     {
         if (([endDate compare:inCompareDate] == NSOrderedDescending ) && ([endDate compare:outCompareDate] == NSOrderedAscending))
         {
             isOverLapEntry=YES;
         }
     }
     else if ([outCompareDate compare:endDate] == NSOrderedSame)
     {
         if (([beginDate compare:inCompareDate] == NSOrderedDescending ) && ([beginDate compare:outCompareDate] == NSOrderedAscending))
         {
             isOverLapEntry=YES;
         }
     }
     else if ([beginDate compare:endDate]==NSOrderedSame)
     {
         if (([beginDate compare:inCompareDate] == NSOrderedDescending ) && ([beginDate compare:outCompareDate] == NSOrderedAscending))
         {
             isOverLapEntry=YES;
         }

     }


    //https://gist.github.com/mmackh/5978268
    return isOverLapEntry;
}

-(void) deleteEntryforRow:(NSInteger)row withDelegate:(id)delegate
{
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {

        TimesheetMainPageController *ctrl=(TimesheetMainPageController *)controllerDelegate;
        if (ctrl.pageControl.currentPage<ctrl.timesheetDataArray.count)
        {
            NSMutableArray *tsEntryObjectsArray=[NSMutableArray arrayWithArray:[ctrl.timesheetDataArray objectAtIndex:ctrl.pageControl.currentPage]];
            [tsEntryObjectsArray removeObjectAtIndex:row];
            [ctrl.timesheetDataArray replaceObjectAtIndex:ctrl.pageControl.currentPage withObject:tsEntryObjectsArray];
            [ctrl setHasUserChangedAnyValue:YES];
            [self calculateAndUpdateTotalHoursValueForFooter];
            [ctrl reloadViewWithRefreshedDataAfterSave];
        }

    }
}


-(void)updateComments:(NSString *)commentsStr andUdfArray:(NSMutableArray *)entryUdfArray forRow:(NSInteger)row
{

    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;

        tsMainPageCtrl.hasUserChangedAnyValue=YES;
        [self changeParentViewLeftBarbutton];

        if (tsMainPageCtrl.pageControl.currentPage<tsMainPageCtrl.timesheetDataArray.count)
        {
            NSMutableArray *tsEntryObjectsArray=[NSMutableArray arrayWithArray:[tsMainPageCtrl.timesheetDataArray objectAtIndex:tsMainPageCtrl.pageControl.currentPage]];
            TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[tsEntryObjectsArray objectAtIndex:row];

            NSString *clientName=tsEntryObject.timeEntryClientName;
            NSString *clientUri=tsEntryObject.timeEntryClientUri;
            NSString *projectName=tsEntryObject.timeEntryProjectName;
            NSString *projectUri=tsEntryObject.timeEntryProjectUri;
            NSString *taskName=tsEntryObject.timeEntryTaskName;
            NSString *taskUri=tsEntryObject.timeEntryTaskUri;
            NSString *activityName=tsEntryObject.timeEntryActivityName;
            NSString *activityUri=tsEntryObject.timeEntryActivityUri;
            NSString *timeOffName=tsEntryObject.timeEntryTimeOffName;
            NSString *timeOffUri=tsEntryObject.timeEntryTimeOffUri;
            NSString *billingName=tsEntryObject.timeEntryBillingName;
            NSString *billingUri=tsEntryObject.timeEntryBillingUri;
            NSString *hoursInHourFormat=tsEntryObject.timeEntryHoursInHourFormat;
            NSString *hoursInDecimalFormat=tsEntryObject.timeEntryHoursInDecimalFormat;
            //NSMutableArray *udfArray=tsEntryObject.timeEntryUdfArray;
            NSMutableDictionary *multiInoutEntry=tsEntryObject.multiDayInOutEntry;
            NSString *punchUri=tsEntryObject.timePunchUri;
            NSString *allocationUri=tsEntryObject.timeAllocationUri;
            NSDate *entryDate=tsEntryObject.timeEntryDate;
            NSString *entryType=tsEntryObject.entryType;
            BOOL isTimeoffSickRowPresent=tsEntryObject.isTimeoffSickRowPresent;
            NSString *timesheetUri=tsEntryObject.timesheetUri;
            NSString *rowUri=tsEntryObject.rowUri;
            BOOL isRowEditable=tsEntryObject.isRowEditable;
            NSString *programName=tsEntryObject.timeEntryProgramName;
            NSString *programUri=tsEntryObject.timeEntryProgramUri;
            BOOL hasTimeEntry = tsEntryObject.hasTimeEntryValue;
            TimesheetEntryObject *tsTempEntryObject=[[TimesheetEntryObject alloc]init];
            //MOBI-746
            [tsTempEntryObject setTimeEntryProgramUri:programUri];
            [tsTempEntryObject setTimeEntryProgramName:programName];
            [tsTempEntryObject setTimeEntryClientName:clientName];
            [tsTempEntryObject setTimeEntryClientUri:clientUri];
            [tsTempEntryObject setTimeEntryProjectName:projectName];
            [tsTempEntryObject setTimeEntryProjectUri:projectUri];
            [tsTempEntryObject setTimeEntryTaskName:taskName];
            [tsTempEntryObject setTimeEntryTaskUri:taskUri];
            [tsTempEntryObject setTimeEntryActivityName:activityName];
            [tsTempEntryObject setTimeEntryActivityUri:activityUri];
            [tsTempEntryObject setTimeEntryTimeOffName:timeOffName];
            [tsTempEntryObject setTimeEntryTimeOffUri:timeOffUri];
            [tsTempEntryObject setTimeEntryBillingName:billingName];
            [tsTempEntryObject setTimeEntryBillingUri:billingUri];
            [tsTempEntryObject setTimeEntryHoursInDecimalFormat:hoursInDecimalFormat];
            [tsTempEntryObject setTimeEntryHoursInHourFormat:hoursInHourFormat];
            [tsTempEntryObject setTimeEntryComments:[NSString stringWithFormat:@"%@",commentsStr]];
            [tsTempEntryObject setTimeEntryUdfArray:entryUdfArray];
            [tsTempEntryObject setMultiDayInOutEntry:multiInoutEntry];
            [tsTempEntryObject setTimePunchUri:punchUri];
            [tsTempEntryObject setTimeAllocationUri:allocationUri];
            [tsTempEntryObject setEntryType:entryType];
            [tsTempEntryObject setTimeEntryDate:entryDate];
            [tsTempEntryObject setIsTimeoffSickRowPresent:isTimeoffSickRowPresent];
            [tsTempEntryObject setTimesheetUri:timesheetUri];
            [tsTempEntryObject setRowUri:rowUri];
            [tsTempEntryObject setIsRowEditable:isRowEditable];
            [tsTempEntryObject setHasTimeEntryValue:hasTimeEntry];

            [self.timesheetEntryObjectArray replaceObjectAtIndex:row withObject:tsTempEntryObject];
            
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:row];
            [self.multiDayTimeEntryTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }

    }



}

-(BOOL)checkIfBothProjectAndClientIsNull:(NSString *)timeEntryClientName projectName:(NSString *)timeEntryProjectName
{
    if (timeEntryClientName==nil || [timeEntryClientName isKindOfClass:[NSNull class]]||[timeEntryClientName isEqualToString:@""]||[timeEntryClientName isEqualToString:NULL_STRING])
    {
        timeEntryClientName=@"";
    }
    if (timeEntryProjectName==nil || [timeEntryProjectName isKindOfClass:[NSNull class]]||[timeEntryProjectName isEqualToString:@""]||[timeEntryProjectName isEqualToString:NULL_STRING])
    {
        timeEntryProjectName=@"";
    }

    BOOL clientNull=NO;
    BOOL projectNull=NO;
    if (timeEntryClientName==nil || [timeEntryClientName isKindOfClass:[NSNull class]]||[timeEntryClientName isEqualToString:@""]||[timeEntryClientName isEqualToString:NULL_STRING])
    {
        clientNull=YES;
    }
    if (timeEntryProjectName==nil || [timeEntryProjectName isKindOfClass:[NSNull class]]||[timeEntryProjectName isEqualToString:@""]||[timeEntryProjectName isEqualToString:NULL_STRING])
    {
        projectNull=YES;
    }

    if (clientNull && projectNull)
    {
        return YES;
    }

    return NO;

}

-(NSString *)getTheAttributedTextForEntryObject:(TimesheetEntryObject *)tsEntryObject
{
    BOOL isProjectAccess=NO;
    BOOL isClientAccess=NO;
    BOOL isActivityAccess=NO;
    BOOL isBillingAccess=NO;
    UIViewController *controllerViewCtrl=(UIViewController *)controllerDelegate;

    if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
        ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
        TimesheetMainPageController *controllerViewCtrl=(TimesheetMainPageController *)controllerDelegate;
        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)[controllerViewCtrl parentDelegate];
        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            if ([self.timesheetEntryObjectArray count]>0)
            {
                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:0];
                NSString *sheetIdentity=[tsEntryObject timesheetUri];
                if (sheetIdentity!=nil && ![sheetIdentity isKindOfClass:[NSNull class]])
                {

                    isProjectAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:sheetIdentity];
                    isClientAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetClientAccess" forSheetUri:sheetIdentity];
                    isActivityAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:sheetIdentity];
                    isBillingAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:sheetIdentity];

                }

            }
            self.timesheetFormat=[approvalModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:YES];

        }
        else
        {
            if ([self.timesheetEntryObjectArray count]>0)
            {
                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:0];
                NSString *sheetIdentity=[tsEntryObject timesheetUri];
                if (sheetIdentity!=nil && ![sheetIdentity isKindOfClass:[NSNull class]])
                {

                    isProjectAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:sheetIdentity];
                    isClientAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetClientAccess" forSheetUri:sheetIdentity];
                    isActivityAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:sheetIdentity];
                    isBillingAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:sheetIdentity];

                }

            }
            self.timesheetFormat=[approvalModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:NO];

        }



    }
    //User context Flow for timesheets
    else if([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
       
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        isProjectAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetURI];
        isClientAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetClientAccess" forSheetUri:timesheetURI];
        isActivityAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetURI];
        isBillingAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:timesheetURI];

         self.timesheetFormat=[timesheetModel getTimesheetFormatforTimesheetUri:timesheetURI];

    }

    if (self.isGen4UserTimesheet) {
        SupportDataModel *supportModel=[[SupportDataModel alloc]init];
        NSDictionary *dict=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
        if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
        {
            if([self.timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
            {
                isProjectAccess=[[dict objectForKey:@"allowProjectsTasksForExtInOutGen4"] boolValue];
                isActivityAccess=[[dict objectForKey:@"allowActivitiesForExtInOutGen4"] boolValue];
                isClientAccess=[[dict objectForKey:@"allowClientsForExtInOutGen4"] boolValue];
                isBillingAccess=[[dict objectForKey:@"allowBillingForExtInOutGen4"] boolValue];
                //            isProgramAccess=[[dict objectForKey:@"allowProgramsForExtInOutGen4"] boolValue];
            }
        }


    }

    NSMutableArray *array=[NSMutableArray array];
    NSString *tsActivityName=[tsEntryObject timeEntryActivityName];

    //DE18721 Ullas M L
    if (isActivityAccess)
    {
        if (tsActivityName!=nil && ![tsActivityName isKindOfClass:[NSNull class]]&& ![tsActivityName isEqualToString:@""])
        {
            NSMutableDictionary *activityDict=[NSMutableDictionary dictionaryWithObject:tsActivityName forKey:@"ACTIVITY"];
            [array addObject:activityDict];

        }
    }


    float labelWidth=280;
    int sizeExceedingCount=0;
    NSMutableArray *arrayFinal=[NSMutableArray array];
    NSString *tempCompStr=@"";
    NSString *tempCompStrrr=@"";


    for (int i=0; i<[array count]; i++)
    {
        //NSArray *allKeys=[[array objectAtIndex:i] allKeys];
        NSArray *allValues=[[array objectAtIndex:i] allValues];
        //NSString *key=(NSString *)[allKeys objectAtIndex:0];
        NSString *str=(NSString *)[allValues objectAtIndex:0];
        tempCompStrrr=[tempCompStrrr stringByAppendingString:[NSString stringWithFormat:@" %@ |",str]];
        tempCompStr=[tempCompStr stringByAppendingString:[NSString stringWithFormat:@" %@ | +%d",str,sizeExceedingCount]];
        CGSize stringSize = [tempCompStr sizeWithAttributes:
                             @{NSFontAttributeName:
                                   [UIFont systemFontOfSize:RepliconFontSize_12]}];
        tempCompStr=tempCompStrrr;
        CGFloat width = stringSize.width;
        if (!isBillingAccess)
        {
            if (width<labelWidth)
            {
                //do nothing
            }
            else
            {
                str=[Util stringByTruncatingToWidth:labelWidth withFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12] ForString:str addQuotes:YES];
            }

            [arrayFinal addObject:str];
        }
        else
        {
            if (width<labelWidth)
            {
                [arrayFinal addObject:str];
            }
            else
            {
                sizeExceedingCount++;
            }
        }

    }

    NSString *tempfinalString=@"";
    NSString *finalString=@"";
    for (int i=0; i<[arrayFinal count]; i++)
    {
        NSString *str=[arrayFinal objectAtIndex:i];
        if (i==[arrayFinal count]-1)
        {
            if (sizeExceedingCount!=0)
            {
                tempfinalString=[tempfinalString stringByAppendingString:[NSString stringWithFormat:@" %@ | +%d",str,sizeExceedingCount]];

                CGSize stringSize = [tempfinalString sizeWithAttributes:
                                     @{NSFontAttributeName:
                                           [UIFont systemFontOfSize:RepliconFontSize_12]}];
                CGFloat width = stringSize.width;
                if (width<labelWidth)
                {
                    finalString=[finalString stringByAppendingString:[NSString stringWithFormat:@" %@ | +%d",str,sizeExceedingCount]];
                }
                else
                {
                    finalString=[NSString stringWithFormat:@" %@ +%d",finalString,sizeExceedingCount+1];

                }

            }
            else
            {
                tempfinalString=[finalString stringByAppendingString:str];
                finalString=[finalString stringByAppendingString:str];

            }

        }
        else
        {
            tempfinalString=[finalString stringByAppendingString:[NSString stringWithFormat:@" %@ | ",str]];
            finalString=[finalString stringByAppendingString:[NSString stringWithFormat:@"%@ | ",str]];


        }

    }

    return finalString;
}

-(NSString *)getTheAttributedTextForSuggestionObject:(NSMutableDictionary *)suggestionObj
{
//TODO:Commenting below line because variable is unused,uncomment when using
//    NSString *billingName=[suggestionObj objectForKey:@"billingName"];
    NSString *activityName=[suggestionObj objectForKey:@"activityName"];
    BOOL isProjectAccess=NO;
    BOOL isClientAccess=NO;
    BOOL isActivityAccess=NO;
    BOOL isBillingAccess=NO;
    UIViewController *controllerViewCtrl=(UIViewController *)controllerDelegate;
    if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
         ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
        TimesheetMainPageController *controllerViewCtrl=(TimesheetMainPageController *)controllerDelegate;
        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)[controllerViewCtrl parentDelegate];
        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            if ([self.timesheetEntryObjectArray count]>0)
            {
                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:0];
                NSString *sheetIdentity=[tsEntryObject timesheetUri];
                if (sheetIdentity!=nil && ![sheetIdentity isKindOfClass:[NSNull class]])
                {

                    isProjectAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:sheetIdentity];
                    isClientAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetClientAccess" forSheetUri:sheetIdentity];
                    isActivityAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:sheetIdentity];
                    isBillingAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:sheetIdentity];

                }

            }
            self.timesheetFormat=[approvalModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:YES];

        }
        else
        {
            if ([self.timesheetEntryObjectArray count]>0)
            {
                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:0];
                NSString *sheetIdentity=[tsEntryObject timesheetUri];
                if (sheetIdentity!=nil && ![sheetIdentity isKindOfClass:[NSNull class]])
                {

                    isProjectAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:sheetIdentity];
                    isClientAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetClientAccess" forSheetUri:sheetIdentity];
                    isActivityAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:sheetIdentity];
                    isBillingAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:sheetIdentity];

                }

            }
            self.timesheetFormat=[approvalModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:NO];

        }



    }
    //User context Flow for timesheets
    else if([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        isProjectAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetURI];
        isClientAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetClientAccess" forSheetUri:timesheetURI];
        isActivityAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetURI];
        isBillingAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:timesheetURI];

        self.timesheetFormat=[timesheetModel getTimesheetFormatforTimesheetUri:timesheetURI];

    }

    if (self.isGen4UserTimesheet) {
        SupportDataModel *supportModel=[[SupportDataModel alloc]init];
        NSDictionary *dict=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
        if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
        {
            if([self.timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
            {
                isProjectAccess=[[dict objectForKey:@"allowProjectsTasksForExtInOutGen4"] boolValue];
                isActivityAccess=[[dict objectForKey:@"allowActivitiesForExtInOutGen4"] boolValue];
                isClientAccess=[[dict objectForKey:@"allowClientsForExtInOutGen4"] boolValue];
                isBillingAccess=[[dict objectForKey:@"allowBillingForExtInOutGen4"] boolValue];
                //            isProgramAccess=[[dict objectForKey:@"allowProgramsForExtInOutGen4"] boolValue];
            }
        }


    }

    NSMutableArray *array=[NSMutableArray array];
    NSString *tsActivityName=activityName;

    //DE18721 Ullas M L
    if (isActivityAccess)
    {
        if (tsActivityName!=nil && ![tsActivityName isKindOfClass:[NSNull class]]&& ![tsActivityName isEqualToString:@""])
        {
            NSMutableDictionary *activityDict=[NSMutableDictionary dictionaryWithObject:tsActivityName forKey:@"ACTIVITY"];
            [array addObject:activityDict];

        }
    }




    float labelWidth=280;
    int sizeExceedingCount=0;
    NSMutableArray *arrayFinal=[NSMutableArray array];
    NSString *tempCompStr=@"";
    NSString *tempCompStrrr=@"";

    for (int i=0; i<[array count]; i++)
    {
        NSArray *allKeys=[[array objectAtIndex:i] allKeys];
        NSArray *allValues=[[array objectAtIndex:i] allValues];
        NSString *key=(NSString *)[allKeys objectAtIndex:0];
        NSString *str=(NSString *)[allValues objectAtIndex:0];
        NSString *valueStr = str;
        if([key isEqualToString:@"ACTIVITY"])
        {
            if(valueStr.length>30)
            {
                valueStr = [NSString stringWithFormat:@"%@...",[str substringToIndex:25]];
            }
        }
        tempCompStrrr=[tempCompStrrr stringByAppendingString:[NSString stringWithFormat:@" %@ |",valueStr]];
        tempCompStr=[tempCompStr stringByAppendingString:[NSString stringWithFormat:@" %@ | +%d",valueStr,sizeExceedingCount]];

        CGSize stringSize = [tempCompStr sizeWithAttributes:
                             @{NSFontAttributeName:
                                   [UIFont systemFontOfSize:RepliconFontSize_12]}];
        tempCompStr=tempCompStrrr;
        CGFloat width = stringSize.width;
        if (!isBillingAccess)
        {
            if (width<labelWidth)
            {
                //do nothing
            }
            else
            {
                valueStr=[Util stringByTruncatingToWidth:labelWidth withFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12] ForString:valueStr addQuotes:YES];
            }

            [arrayFinal addObject:valueStr];
        }
        else
        {
            if (width<labelWidth)
            {
                [arrayFinal addObject:valueStr];
            }
            else
            {
                sizeExceedingCount++;
            }
        }

    }
    NSString *tempfinalString=@"";
    NSString *finalString=@"";
    for (int i=0; i<[arrayFinal count]; i++)
    {
        NSString *str=(NSString *)[arrayFinal objectAtIndex:i];
        if (i==[arrayFinal count]-1)
        {
            if (sizeExceedingCount!=0)
            {
                tempfinalString=[tempfinalString stringByAppendingString:[NSString stringWithFormat:@" %@ | +%d",str,sizeExceedingCount]];
                CGSize stringSize = [tempfinalString sizeWithAttributes:
                                     @{NSFontAttributeName:
                                           [UIFont systemFontOfSize:RepliconFontSize_12]}];
                CGFloat width = stringSize.width;
                if (width<labelWidth)
                {
                    finalString=[finalString stringByAppendingString:[NSString stringWithFormat:@" %@ | +%d",str,sizeExceedingCount]];
                }
                else
                {
                    finalString=[NSString stringWithFormat:@" %@ +%d",finalString,sizeExceedingCount+1];

                }

            }
            else
            {
                tempfinalString=[finalString stringByAppendingString:str];
                finalString=[finalString stringByAppendingString:str];

            }

        }
        else
        {
            tempfinalString=[finalString stringByAppendingString:[NSString stringWithFormat:@" %@ | ",str]];
            finalString=[finalString stringByAppendingString:[NSString stringWithFormat:@"%@ | ",str]];


        }

    }

    return finalString;
}



-(float)getHeightForString:(NSString *)string fontSize:(int)fontSize forWidth:(float)width
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
    CGSize mainSize  = [attributedString boundingRectWithSize:CGSizeMake(width, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    if (mainSize.width==0 && mainSize.height ==0)
    {
        mainSize=CGSizeMake(0,0);
    }

    NSString *fontName=nil;
    if (fontSize==RepliconFontSize_16)
    {
        fontName=RepliconFontFamilyRegular;
    }
    else
    {
        fontName=RepliconFontFamilyLight;
    }

    CGSize maxSize = CGSizeMake(width, MAXFLOAT);
    CGRect labelRect = [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:fontName size:fontSize]} context:nil];
    return labelRect.size.height;

    return mainSize.height;
}


-(NSMutableDictionary *)getSuggestionHeightDictForObject:(NSMutableDictionary *)suggestionObj
{

//    NSString *activityName=[suggestionObj objectForKey:@"activityName"];
    NSString *programName=[suggestionObj objectForKey:@"programName"];//MOBI-746
    NSString *projectName=[suggestionObj objectForKey:@"projectName"];
    NSString *taskName=[suggestionObj objectForKey:@"taskName"];
    NSString *timeoffName=[suggestionObj objectForKey:@"timeOffTypeName"];
    NSString *timeoffUri=[suggestionObj objectForKey:@"timeOffUri"];
    NSString *breakName=[suggestionObj objectForKey:@"breakName"];
    NSString *breakUri=[suggestionObj objectForKey:@"breakUri"];
    NSString *clientName=[suggestionObj objectForKey:@"clientName"];

    BOOL isProjectAccess=NO;
    BOOL isClientAccess=NO;
    BOOL isActivityAccess=NO;
    BOOL isBillingAccess=NO;
    BOOL isProgramAccess=NO;
    UIViewController *controllerViewCtrl=(UIViewController *)controllerDelegate;

    if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
        ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
        TimesheetMainPageController *controllerViewCtrl=(TimesheetMainPageController *)controllerDelegate;
        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)[controllerViewCtrl parentDelegate];
        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            if ([self.timesheetEntryObjectArray count]>0)
            {
                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:0];
                NSString *sheetIdentity=[tsEntryObject timesheetUri];
                if (sheetIdentity!=nil && ![sheetIdentity isKindOfClass:[NSNull class]])
                {

                    isProjectAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:sheetIdentity];
                    isClientAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetClientAccess" forSheetUri:sheetIdentity];
                    isActivityAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:sheetIdentity];
                    isBillingAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:sheetIdentity];

                }

            }
            self.timesheetFormat=[approvalModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:YES];

        }
        else
        {
            if ([self.timesheetEntryObjectArray count]>0)
            {
                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:0];
                NSString *sheetIdentity=[tsEntryObject timesheetUri];
                if (sheetIdentity!=nil && ![sheetIdentity isKindOfClass:[NSNull class]])
                {
                    ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
                    isProjectAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:sheetIdentity];
                    isClientAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetClientAccess" forSheetUri:sheetIdentity];
                    isActivityAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:sheetIdentity];
                    isBillingAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:sheetIdentity];

                }

            }
            self.timesheetFormat=[approvalModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:NO];

        }



    }
    //User context Flow for timesheets
    else if([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        isProjectAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetURI];
        isClientAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetClientAccess" forSheetUri:timesheetURI];
        isActivityAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetURI];
        isBillingAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:timesheetURI];
        isProgramAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProgramAccess" forSheetUri:timesheetURI];

        self.timesheetFormat=[timesheetModel getTimesheetFormatforTimesheetUri:timesheetURI];
    }

    if (self.isGen4UserTimesheet) {
        SupportDataModel *supportModel=[[SupportDataModel alloc]init];
        NSDictionary *dict=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
        if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
        {
            if([self.timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
            {
                isProjectAccess=[[dict objectForKey:@"allowProjectsTasksForExtInOutGen4"] boolValue];
                isActivityAccess=[[dict objectForKey:@"allowActivitiesForExtInOutGen4"] boolValue];
                isClientAccess=[[dict objectForKey:@"allowClientsForExtInOutGen4"] boolValue];
                isBillingAccess=[[dict objectForKey:@"allowBillingForExtInOutGen4"] boolValue];
                isProgramAccess=[[dict objectForKey:@"allowProgramsForExtInOutGen4"] boolValue];
            }
        }


    }

    float cellHeight=0.0;
    float verticalOffset=10.0;
    float upperLabelHeight=0.0;
    float middleLabelHeight=0.0;
    float lowerLabelHeight=0.0;
    float billingRateLabelHeight=0.0;
    NSString *upperStr=@"";
    NSString *middleStr=@"";
    NSString *lowerStr=@"";
    BOOL isUpperLabelTextWrap=NO;
    BOOL isMiddleLabelTextWrap=NO;
    BOOL isLowerLabelTextWrap=NO;
    
    NSMutableDictionary *heightDict=[NSMutableDictionary dictionary];
    BOOL isTimeoffSickRow=NO;
    if (timeoffUri!=nil && ![timeoffUri isKindOfClass:[NSNull class]] && ![timeoffUri isEqualToString:@""])
    {
        isTimeoffSickRow=YES;
    }
    BOOL isBreakPresent=NO;
    if (breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]] && ![breakUri isEqualToString:@""])
    {
        isBreakPresent=YES;
    }
    if (isTimeoffSickRow||isBreakPresent)
    {
        if (isBreakPresent)
        {
            middleStr=breakName;
            middleLabelHeight=[self getHeightForString:breakName fontSize:RepliconFontSize_16 forWidth:LABEL_WIDTH];
            [heightDict setObject:@"SINGLE" forKey:LINE];
        }
        else
        {
            NSString *timeEntryTimeOffName=timeoffName;
            middleStr=timeEntryTimeOffName;
            middleLabelHeight=[self getHeightForString:timeEntryTimeOffName fontSize:RepliconFontSize_16 forWidth:LABEL_WIDTH_FOR_TIMEOFF];
            [heightDict setObject:@"SINGLE" forKey:LINE];

        }

    }
    else
    {

        NSString *timeEntryTaskName=taskName;
        NSString *timeEntryClientName=clientName;
        if (isProgramAccess) {
            timeEntryClientName=programName;
        }
        NSString *timeEntryProjectName=projectName;
        if (timeEntryTaskName==nil || [timeEntryTaskName isKindOfClass:[NSNull class]]||[timeEntryTaskName isEqualToString:@""])
        {

            if (isProjectAccess)
            {

                BOOL isBothClientAndProjectNull=[self checkIfBothProjectAndClientIsNull:timeEntryClientName projectName:timeEntryProjectName];

                if (isBothClientAndProjectNull)
                {

                    //No task client and project.Only third row consiting of activity/udf's or billing

                    NSString *attributeText=[self getTheAttributedTextForSuggestionObject:suggestionObj];
                    isMiddleLabelTextWrap=YES;
                    middleStr=attributeText;
                    middleLabelHeight=[self getHeightForString:attributeText fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                    [heightDict setObject:@"SINGLE" forKey:LINE];

                }
                else
                {

                    NSString *attributeText=[self getTheAttributedTextForSuggestionObject:suggestionObj];
                    if (attributeText==nil ||[attributeText isKindOfClass:[NSNull class]]||[attributeText isEqualToString:@""])
                    {

                        //No task No activity/udf's or billing Only project/client

                        if (timeEntryClientName==nil || [timeEntryClientName isKindOfClass:[NSNull class]]||[timeEntryClientName isEqualToString:@""]||[timeEntryClientName isEqualToString:NULL_STRING])
                        {
                            middleStr=[NSString stringWithFormat:@"%@",timeEntryProjectName];
                        }
                        else
                        {
                            middleStr=[NSString stringWithFormat:@"%@ for %@",timeEntryProjectName,timeEntryClientName];
                        }
                        middleLabelHeight=[self getHeightForString:middleStr fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                        [heightDict setObject:@"SINGLE" forKey:LINE];

                    }
                    else
                    {
                        //No task project/client and activity/udf's or billing


                        if (timeEntryClientName==nil || [timeEntryClientName isKindOfClass:[NSNull class]]||[timeEntryClientName isEqualToString:@""]||[timeEntryClientName isEqualToString:NULL_STRING])
                        {
                            upperStr=[NSString stringWithFormat:@"%@",timeEntryProjectName];
                        }
                        else
                        {
                            upperStr=[NSString stringWithFormat:@"%@ for %@",timeEntryProjectName,timeEntryClientName];
                        }
                        lowerStr=attributeText;
                        isLowerLabelTextWrap=YES;
                        upperLabelHeight=[self getHeightForString:upperStr fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                        lowerLabelHeight=[self getHeightForString:lowerStr fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                        [heightDict setObject:@"DOUBLE" forKey:LINE];

                    }

                }

            }
            else
            {
                NSString *attributeText=[self getTheAttributedTextForSuggestionObject:suggestionObj];
                middleStr=attributeText;
                middleLabelHeight=[self getHeightForString:attributeText fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                [heightDict setObject:@"SINGLE" forKey:LINE];
                isMiddleLabelTextWrap=YES;

            }


        }
        else
        {
            upperStr=timeEntryTaskName;
            NSString *attributeText=[self getTheAttributedTextForSuggestionObject:suggestionObj];
            if (attributeText==nil ||[attributeText isKindOfClass:[NSNull class]]||[attributeText isEqualToString:@""])
            {

                if (timeEntryClientName==nil || [timeEntryClientName isKindOfClass:[NSNull class]]||[timeEntryClientName isEqualToString:@""]||[timeEntryClientName isEqualToString:NULL_STRING])
                {
                    lowerStr=[NSString stringWithFormat:@"in %@",timeEntryProjectName];
                }
                else
                {
                    lowerStr=[NSString stringWithFormat:@"in %@ for %@",timeEntryProjectName,timeEntryClientName];
                }
                upperLabelHeight=[self getHeightForString:upperStr fontSize:RepliconFontSize_16 forWidth:LABEL_WIDTH];
                lowerLabelHeight=[self getHeightForString:lowerStr fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                [heightDict setObject:@"DOUBLE" forKey:LINE];


            }
            else
            {



                if (timeEntryClientName==nil || [timeEntryClientName isKindOfClass:[NSNull class]]||[timeEntryClientName isEqualToString:@""]||[timeEntryClientName isEqualToString:NULL_STRING])
                {
                    middleStr=[NSString stringWithFormat:@"in %@",timeEntryProjectName];
                }
                else
                {
                    middleStr=[NSString stringWithFormat:@"in %@ for %@",timeEntryProjectName,timeEntryClientName];
                }
                lowerStr=[self getTheAttributedTextForSuggestionObject:suggestionObj];
                upperLabelHeight=[self getHeightForString:upperStr fontSize:RepliconFontSize_16 forWidth:LABEL_WIDTH];
                middleLabelHeight=[self getHeightForString:middleStr fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                lowerLabelHeight=[self getHeightForString:lowerStr fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                [heightDict setObject:@"TRIPLE" forKey:LINE];

            }

        }


    }

    float numberOfLabels=0;
    NSString *line=[heightDict objectForKey:LINE];
    if ([line isEqualToString:@"SINGLE"])
    {
        numberOfLabels=1;
    }
    else if ([line isEqualToString:@"DOUBLE"])
    {
        numberOfLabels=2;
    }
    else if ([line isEqualToString:@"TRIPLE"])
    {
        numberOfLabels=3;
    }

    NSString *tsBillingName=[suggestionObj objectForKey:@"billingName"];
    NSString *tmpBillingValue=@"";
    if (tsBillingName!=nil && ![tsBillingName isKindOfClass:[NSNull class]]&& ![tsBillingName isEqualToString:@""])
    {
        tmpBillingValue=[NSString stringWithFormat:@"%@: %@",RPLocalizedString(@"Billing Rate", @""),tsBillingName];
    }
    else
    {
        tmpBillingValue=[NSString stringWithFormat:@"%@: %@",RPLocalizedString(@"Billing Rate", @""),NON_BILLABLE];
    }
    if (!isBillingAccess)
    {
        tmpBillingValue=@"";
    }
    
    billingRateLabelHeight = [self getHeightForString:tmpBillingValue fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];

    cellHeight=upperLabelHeight+middleLabelHeight+lowerLabelHeight+billingRateLabelHeight +2*verticalOffset+numberOfLabels*5;
    //cellHeight=upperLabelHeight+middleLabelHeight+lowerLabelHeight+2*verticalOffset+numberOfLabels*5;
    if (cellHeight<EachDayTimeEntry_Cell_Row_Height_55)
    {
        cellHeight=EachDayTimeEntry_Cell_Row_Height_55;
    }

    [heightDict setObject:[NSString stringWithFormat:@"%f",upperLabelHeight] forKey:UPPER_LABEL_HEIGHT];
    [heightDict setObject:[NSString stringWithFormat:@"%f",middleLabelHeight] forKey:MIDDLE_LABEL_HEIGHT];
    [heightDict setObject:[NSString stringWithFormat:@"%f",lowerLabelHeight] forKey:LOWER_LABEL_HEIGHT];
    [heightDict setObject:[NSString stringWithFormat:@"%@",upperStr] forKey:UPPER_LABEL_STRING];
    [heightDict setObject:[NSString stringWithFormat:@"%@",middleStr] forKey:MIDDLE_LABEL_STRING];
    [heightDict setObject:[NSString stringWithFormat:@"%@",lowerStr] forKey:LOWER_LABEL_STRING];
    [heightDict setObject:[NSString stringWithFormat:@"%d",isUpperLabelTextWrap] forKey:UPPER_LABEL_TEXT_WRAP];
    [heightDict setObject:[NSString stringWithFormat:@"%d",isMiddleLabelTextWrap] forKey:MIDDLE_LABEL_TEXT_WRAP];
    [heightDict setObject:[NSString stringWithFormat:@"%d",isLowerLabelTextWrap] forKey:LOWER_LABEL_TEXT_WRAP];
    [heightDict setObject:[NSString stringWithFormat:@"%f",cellHeight] forKey:CELL_HEIGHT_KEY];
    [heightDict setObject:tmpBillingValue forKey:BILLING_RATE];
    return heightDict;

}


-(void)changeViewToNextDayView:(NSInteger)sectionIndex rowIndex:(NSInteger)rowIndex withValue:(NSMutableDictionary *)dictForNextDay controllerIndex:(NSInteger)controllerIndex
{
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:sectionIndex];
        TimesheetMainPageController *ctrl=(TimesheetMainPageController *)controllerDelegate;
        if (controllerIndex<ctrl.timesheetDataArray.count)
        {
            NSMutableArray *nextPageEntryObjectArray=[ctrl.timesheetDataArray objectAtIndex:controllerIndex];
            BOOL isPresent=[self checkIfThisObjectExistsOnNextPage:tsEntryObject nextPageEntryObjectArray:nextPageEntryObjectArray];
            isPresent=NO;//Ullas gen4changes
            if (!isPresent)
            {

                NSString *clientName=tsEntryObject.timeEntryClientName;
                NSString *clientUri=tsEntryObject.timeEntryClientUri;
                NSString *projectName=tsEntryObject.timeEntryProjectName;
                NSString *projectUri=tsEntryObject.timeEntryProjectUri;
                NSString *taskName=tsEntryObject.timeEntryTaskName;
                NSString *taskUri=tsEntryObject.timeEntryTaskUri;
                NSString *activityName=tsEntryObject.timeEntryActivityName;
                NSString *activityUri=tsEntryObject.timeEntryActivityUri;
                NSString *timeOffName=tsEntryObject.timeEntryTimeOffName;
                NSString *timeOffUri=tsEntryObject.timeEntryTimeOffUri;
                NSString *billingName=tsEntryObject.timeEntryBillingName;
                NSString *billingUri=tsEntryObject.timeEntryBillingUri;
                NSString *hoursInHourFormat=tsEntryObject.timeEntryHoursInHourFormat;
                NSString *comments=tsEntryObject.timeEntryComments;
                NSMutableArray *udfArray=tsEntryObject.timeEntryUdfArray;
                NSString *punchUri=tsEntryObject.timePunchUri;
                NSString *allocationUri=tsEntryObject.timeAllocationUri;
                NSString *entryType=tsEntryObject.entryType;
                NSDate *entryDate=tsEntryObject.timeEntryDate;
                BOOL isTimeoffSickRowPresent=tsEntryObject.isTimeoffSickRowPresent;
                NSString *timesheetUri=tsEntryObject.timesheetUri;
                //Implentation for US8956//JUHI
                NSString *breakName=tsEntryObject.breakName;
                NSString *breakUri=tsEntryObject.breakUri;
                NSString *programName=tsEntryObject.timeEntryProgramName;
                NSString *programUri=tsEntryObject.timeEntryProgramUri;
                NSString *rowUri=tsEntryObject.rowUri;

                NSDate *newEntryDate = [entryDate dateByAddingTimeInterval:60*60*24];
                TimesheetEntryObject *tsTempEntryObject=[[TimesheetEntryObject alloc] init];
                //MOBI-746
                [tsTempEntryObject setTimeEntryProgramUri:programUri];
                [tsTempEntryObject setTimeEntryProgramName:programName];
                [tsTempEntryObject setTimeEntryClientName:clientName];
                [tsTempEntryObject setTimeEntryClientUri:clientUri];
                [tsTempEntryObject setTimeEntryProjectName:projectName];
                [tsTempEntryObject setTimeEntryProjectUri:projectUri];
                [tsTempEntryObject setTimeEntryTaskName:taskName];
                [tsTempEntryObject setTimeEntryTaskUri:taskUri];
                [tsTempEntryObject setTimeEntryActivityName:activityName];
                [tsTempEntryObject setTimeEntryActivityUri:activityUri];
                [tsTempEntryObject setTimeEntryTimeOffName:timeOffName];
                [tsTempEntryObject setTimeEntryTimeOffUri:timeOffUri];
                [tsTempEntryObject setTimeEntryBillingName:billingName];
                [tsTempEntryObject setTimeEntryBillingUri:billingUri];
                [tsTempEntryObject setTimeEntryHoursInHourFormat:hoursInHourFormat];
                [tsTempEntryObject setTimeEntryComments:comments];
                [tsTempEntryObject setTimeEntryUdfArray:udfArray];
                [tsTempEntryObject setMultiDayInOutEntry:dictForNextDay];
                [tsTempEntryObject setTimePunchUri:punchUri];
                [tsTempEntryObject setTimeAllocationUri:allocationUri];
                [tsTempEntryObject setTimeEntryDate:newEntryDate];
                [tsTempEntryObject setIsTimeoffSickRowPresent:isTimeoffSickRowPresent];
                [tsTempEntryObject setEntryType:entryType];
                [tsTempEntryObject setTimesheetUri:timesheetUri];
                //Implentation for US8956//JUHI
                [tsTempEntryObject setBreakName:breakName];
                [tsTempEntryObject setBreakUri:breakUri];
                [tsTempEntryObject setRowUri:rowUri];
                NSString *outTime=[dictForNextDay objectForKey:@"out_time"];
                NSString *inTime=[dictForNextDay objectForKey:@"in_time"];
                NSMutableDictionary *punchDict=[NSMutableDictionary dictionary];
                [punchDict setObject:@"" forKey:@"comments"];
                [punchDict setObject:[NSMutableArray array] forKey:@"udfArray"];
                [punchDict setObject:outTime forKey:@"out_time"];
                [punchDict setObject:inTime forKey:@"in_time"];
                [punchDict setObject:[Util getRandomGUID] forKey:@"clientID"];

                NSMutableArray *punchArray=[NSMutableArray arrayWithObject:punchDict];
                [tsTempEntryObject setTimePunchesArray:punchArray];

                NSMutableArray *entryObjectArray=[NSMutableArray array];
                [entryObjectArray addObjectsFromArray:nextPageEntryObjectArray];//Ullas gen4changes
                BOOL hasObject = (entryObjectArray != nil && ![entryObjectArray isKindOfClass:[NSNull class]]);
                NSInteger emptyRowIndex = 0;
                BOOL hasEmptyRow =  false;
                if (hasObject) {
                    for (NSInteger index = [entryObjectArray count]-1; index >= 0; index--) {
                        TimesheetEntryObject *timeEntryObject = entryObjectArray[index];
                        NSDictionary *timeEntry = [timeEntryObject multiDayInOutEntry];
                        NSString *inTime = timeEntry[@"in_time"];
                        NSString *outTime = timeEntry[@"out_time"];
                        BOOL hasInTime = (inTime != nil && ![inTime isKindOfClass:[NSNull class]] && ![inTime isEqualToString:@""]);
                        BOOL hasOutTime = (outTime != nil && ![outTime isKindOfClass:[NSNull class]] && ![outTime isEqualToString:@""]);
                        BOOL isTimeOffRow = ([[timeEntryObject entryType] isEqualToString:Time_Off_Key]);
                        if (!hasInTime && !hasOutTime && !isTimeOffRow) {
                            emptyRowIndex = index;
                            hasEmptyRow = true;
                        }
                    }
                }
                if (hasEmptyRow)
                {
                    [entryObjectArray replaceObjectAtIndex:emptyRowIndex withObject:tsTempEntryObject];
                    TimesheetEntryObject *timeEntryObject = nextPageEntryObjectArray[emptyRowIndex];
                    [entryObjectArray addObject:timeEntryObject];
                }
                else
                    [entryObjectArray addObject:tsTempEntryObject];
                [ctrl.timesheetDataArray replaceObjectAtIndex:controllerIndex withObject:entryObjectArray];
            }
            else
            {
                NSLog(@"Present");
                //Fix for MOBI-104//JUHI
                if (rowIndex<=[nextPageEntryObjectArray count])
                {
                    TimesheetEntryObject *tempEntryObject=(TimesheetEntryObject *)[nextPageEntryObjectArray objectAtIndex:rowIndex];
                    NSString *clientName=tempEntryObject.timeEntryClientName;
                    NSString *clientUri=tempEntryObject.timeEntryClientUri;
                    NSString *projectName=tempEntryObject.timeEntryProjectName;
                    NSString *projectUri=tempEntryObject.timeEntryProjectUri;
                    NSString *taskName=tempEntryObject.timeEntryTaskName;
                    NSString *taskUri=tempEntryObject.timeEntryTaskUri;
                    NSString *activityName=tempEntryObject.timeEntryActivityName;
                    NSString *activityUri=tempEntryObject.timeEntryActivityUri;
                    NSString *timeOffName=tempEntryObject.timeEntryTimeOffName;
                    NSString *timeOffUri=tempEntryObject.timeEntryTimeOffUri;
                    NSString *billingName=tempEntryObject.timeEntryBillingName;
                    NSString *billingUri=tempEntryObject.timeEntryBillingUri;
                    NSString *hoursInHourFormat=tempEntryObject.timeEntryHoursInHourFormat;
                    NSString *comments=tempEntryObject.timeEntryComments;
                    NSMutableArray *udfArray=tempEntryObject.timeEntryUdfArray;
                    NSString *punchUri=tempEntryObject.timePunchUri;
                    NSString *allocationUri=tempEntryObject.timeAllocationUri;
                    NSString *entryType=tempEntryObject.entryType;
                    NSDate *entryDate=tempEntryObject.timeEntryDate;
                    BOOL isTimeoffSickRowPresent=tempEntryObject.isTimeoffSickRowPresent;
                    NSString *timesheetUri=tempEntryObject.timesheetUri;
                    NSString *breakName=tempEntryObject.breakName;
                    NSString *breakUri=tempEntryObject.breakUri;
                    NSString *programName=tsEntryObject.timeEntryProgramName;
                    NSString *programUri=tsEntryObject.timeEntryProgramUri;
                    NSString *rowUri=tsEntryObject.rowUri;

                    TimesheetEntryObject *tsTempEntryObject=[[TimesheetEntryObject alloc] init];
                    //MOBI-746
                    [tsTempEntryObject setTimeEntryProgramUri:programUri];
                    [tsTempEntryObject setTimeEntryProgramName:programName];
                    [tsTempEntryObject setTimeEntryClientName:clientName];
                    [tsTempEntryObject setTimeEntryClientUri:clientUri];
                    [tsTempEntryObject setTimeEntryProjectName:projectName];
                    [tsTempEntryObject setTimeEntryProjectUri:projectUri];
                    [tsTempEntryObject setTimeEntryTaskName:taskName];
                    [tsTempEntryObject setTimeEntryTaskUri:taskUri];
                    [tsTempEntryObject setTimeEntryActivityName:activityName];
                    [tsTempEntryObject setTimeEntryActivityUri:activityUri];
                    [tsTempEntryObject setTimeEntryTimeOffName:timeOffName];
                    [tsTempEntryObject setTimeEntryTimeOffUri:timeOffUri];
                    [tsTempEntryObject setTimeEntryBillingName:billingName];
                    [tsTempEntryObject setTimeEntryBillingUri:billingUri];
                    [tsTempEntryObject setTimeEntryHoursInHourFormat:hoursInHourFormat];
                    [tsTempEntryObject setTimeEntryComments:comments];
                    [tsTempEntryObject setTimeEntryUdfArray:udfArray];
                    [tsTempEntryObject setMultiDayInOutEntry:dictForNextDay];
                    [tsTempEntryObject setTimePunchUri:punchUri];
                    [tsTempEntryObject setTimeAllocationUri:allocationUri];
                    [tsTempEntryObject setTimeEntryDate:entryDate];
                    [tsTempEntryObject setIsTimeoffSickRowPresent:isTimeoffSickRowPresent];
                    [tsTempEntryObject setEntryType:entryType];
                    [tsTempEntryObject setTimesheetUri:timesheetUri];
                    [tsTempEntryObject setBreakName:breakName];
                    [tsTempEntryObject setBreakUri:breakUri];
                    [tsTempEntryObject setRowUri:rowUri];

                    NSMutableArray *punchArray=[NSMutableArray arrayWithArray:tempEntryObject.timePunchesArray];
                    NSString *outTime=[dictForNextDay objectForKey:@"out_time"];
                    NSString *inTime=[dictForNextDay objectForKey:@"in_time"];
                    NSMutableDictionary *punchDict=[NSMutableDictionary dictionary];
                    [punchDict setObject:@"" forKey:@"comments"];
                    [punchDict setObject:[NSMutableArray array] forKey:@"udfArray"];
                    [punchDict setObject:outTime forKey:@"out_time"];
                    [punchDict setObject:inTime forKey:@"in_time"];
                    [punchArray addObject:punchDict];
                    [tsTempEntryObject setTimePunchesArray:punchArray];
                    [nextPageEntryObjectArray replaceObjectAtIndex:rowIndex withObject:tsTempEntryObject];
                    [ctrl.timesheetDataArray replaceObjectAtIndex:controllerIndex withObject:nextPageEntryObjectArray];
                }
                else{
                    TimesheetEntryObject *tempEntryObject=(TimesheetEntryObject *)[nextPageEntryObjectArray objectAtIndex:sectionIndex];
                    NSString *clientName=tempEntryObject.timeEntryClientName;
                    NSString *clientUri=tempEntryObject.timeEntryClientUri;
                    NSString *projectName=tempEntryObject.timeEntryProjectName;
                    NSString *projectUri=tempEntryObject.timeEntryProjectUri;
                    NSString *taskName=tempEntryObject.timeEntryTaskName;
                    NSString *taskUri=tempEntryObject.timeEntryTaskUri;
                    NSString *activityName=tempEntryObject.timeEntryActivityName;
                    NSString *activityUri=tempEntryObject.timeEntryActivityUri;
                    NSString *timeOffName=tempEntryObject.timeEntryTimeOffName;
                    NSString *timeOffUri=tempEntryObject.timeEntryTimeOffUri;
                    NSString *billingName=tempEntryObject.timeEntryBillingName;
                    NSString *billingUri=tempEntryObject.timeEntryBillingUri;
                    NSString *hoursInHourFormat=tempEntryObject.timeEntryHoursInHourFormat;
                    NSString *comments=tempEntryObject.timeEntryComments;
                    NSMutableArray *udfArray=tempEntryObject.timeEntryUdfArray;
                    NSString *punchUri=tempEntryObject.timePunchUri;
                    NSString *allocationUri=tempEntryObject.timeAllocationUri;
                    NSString *entryType=tempEntryObject.entryType;
                    NSDate *entryDate=tempEntryObject.timeEntryDate;
                    BOOL isTimeoffSickRowPresent=tempEntryObject.isTimeoffSickRowPresent;
                    NSString *timesheetUri=tempEntryObject.timesheetUri;
                    //Implentation for US8956//JUHI
                    NSString *breakName=tempEntryObject.breakName;
                    NSString *breakUri=tempEntryObject.breakUri;
                    NSString *programName=tsEntryObject.timeEntryProgramName;
                    NSString *programUri=tsEntryObject.timeEntryProgramUri;
                    NSString *rowUri=tsEntryObject.rowUri;


                    TimesheetEntryObject *tsTempEntryObject=[[TimesheetEntryObject alloc] init];
                    //MOBI-746
                    [tsTempEntryObject setTimeEntryProgramUri:programUri];
                    [tsTempEntryObject setTimeEntryProgramName:programName];
                    [tsTempEntryObject setTimeEntryClientName:clientName];
                    [tsTempEntryObject setTimeEntryClientUri:clientUri];
                    [tsTempEntryObject setTimeEntryProjectName:projectName];
                    [tsTempEntryObject setTimeEntryProjectUri:projectUri];
                    [tsTempEntryObject setTimeEntryTaskName:taskName];
                    [tsTempEntryObject setTimeEntryTaskUri:taskUri];
                    [tsTempEntryObject setTimeEntryActivityName:activityName];
                    [tsTempEntryObject setTimeEntryActivityUri:activityUri];
                    [tsTempEntryObject setTimeEntryTimeOffName:timeOffName];
                    [tsTempEntryObject setTimeEntryTimeOffUri:timeOffUri];
                    [tsTempEntryObject setTimeEntryBillingName:billingName];
                    [tsTempEntryObject setTimeEntryBillingUri:billingUri];
                    [tsTempEntryObject setTimeEntryHoursInHourFormat:hoursInHourFormat];
                    [tsTempEntryObject setTimeEntryComments:comments];
                    [tsTempEntryObject setTimeEntryUdfArray:udfArray];
                    [tsTempEntryObject setMultiDayInOutEntry:dictForNextDay];
                    [tsTempEntryObject setTimePunchUri:punchUri];
                    [tsTempEntryObject setTimeAllocationUri:allocationUri];
                    [tsTempEntryObject setTimeEntryDate:entryDate];
                    [tsTempEntryObject setIsTimeoffSickRowPresent:isTimeoffSickRowPresent];
                    [tsTempEntryObject setEntryType:entryType];
                    [tsTempEntryObject setTimesheetUri:timesheetUri];
                    //Implentation for US8956//JUHI
                    [tsTempEntryObject setBreakName:breakName];
                    [tsTempEntryObject setBreakUri:breakUri];
                    [tsTempEntryObject setRowUri:rowUri];

                    NSMutableArray *punchArray=[NSMutableArray arrayWithArray:tempEntryObject.timePunchesArray];
                    if (multiInOutTimesheetType==EXTENDED_IN_OUT_TIMESHEET_TYPE)
                    {
                        NSMutableArray *tmpArray=[inoutTsObjectsArray objectAtIndex:sectionIndex];
                        [tmpArray replaceObjectAtIndex:rowIndex withObject:[self createInOutTimesheetobjectArrayForMultiInoutDictionaryObject:dictForNextDay]];
                        [self.inoutTsObjectsArray replaceObjectAtIndex:sectionIndex withObject:tmpArray];

                    }
                    NSString *outTime=[dictForNextDay objectForKey:@"out_time"];
                    NSString *inTime=[dictForNextDay objectForKey:@"in_time"];
                    NSMutableDictionary *punchDict=[NSMutableDictionary dictionary];
                    NSString *rowCount=[[punchArray objectAtIndex:[punchArray count]-1] objectForKey:@"Row"];
                    int row=[rowCount intValue];
                    [punchDict setObject:[NSString stringWithFormat:@"%d",row+1] forKey:@"Row"];
                    [punchDict setObject:[NSString stringWithFormat:@"%ld",(long)sectionIndex] forKey:@"Section"];
                    [punchDict setObject:@"" forKey:@"comments"];
                    [punchDict setObject:[NSMutableArray array] forKey:@"udfArray"];
                    [punchDict setObject:outTime forKey:@"out_time"];
                    [punchDict setObject:inTime forKey:@"in_time"];
                    [punchArray addObject:punchDict];
                    [tsTempEntryObject setTimePunchesArray:punchArray];
                    
                    [nextPageEntryObjectArray replaceObjectAtIndex:sectionIndex withObject:tsTempEntryObject];
                    
                    [ctrl.timesheetDataArray replaceObjectAtIndex:controllerIndex withObject:nextPageEntryObjectArray];
                }
            }

            [self performSelector:@selector(hidekeyboard) withObject:nil afterDelay:1];

            NSInteger selectedPage = ctrl.currentlySelectedPage;
            if ( selectedPage == controllerIndex-1 || selectedPage == controllerIndex) {
                [ctrl loadNextPageOnCrossoverSplit:controllerIndex];
            }
            else{
                [ctrl createNextviewController:controllerIndex];
            }
        }

    }

}

-(BOOL)checkIfThisObjectExistsOnNextPage:(TimesheetEntryObject *)currentObj nextPageEntryObjectArray:(NSMutableArray *)nextPageEntryObjArray
{
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        if ([nextPageEntryObjArray count]==0)
        {
            return NO;
        }
        TimesheetMainPageController *ctrl=(TimesheetMainPageController *)controllerDelegate;
        NSString *formattedDate=[NSString stringWithFormat:@"%@",[[ctrl.tsEntryDataArray objectAtIndex:ctrl.pageControl.currentPage] entryDate]];

        NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
        [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        myDateFormatter.dateFormat = @"EEEE, dd MMM yyyy";

        NSLocale *locale=[NSLocale currentLocale];
        [myDateFormatter setLocale:locale];
        NSDate *currentDate=[myDateFormatter dateFromString:[NSString stringWithFormat:@"%@",formattedDate]];

        NSMutableArray *activeCellObjectsArray=[NSMutableArray array];
        if (ctrl.pageControl.currentPage<ctrl.timesheetDataArray.count)
        {
            NSMutableArray *currentTimesheetEntryObjectArray=[ctrl.timesheetDataArray objectAtIndex:ctrl.pageControl.currentPage];
            for (int j=0; j<[currentTimesheetEntryObjectArray count]; j++)
            {
                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[currentTimesheetEntryObjectArray objectAtIndex:j];
                BOOL isTimeoffSickRow=[tsEntryObject isTimeoffSickRowPresent];
                NSDate *timeEntryDate=[tsEntryObject timeEntryDate];
                if (!isTimeoffSickRow)
                {
                    id clientName=nil;
                    id clientUri=nil;
                    id projectName=nil;
                    id projectUri=nil;
                    id activityName=nil;
                    id activityUri=nil;
                    id billingName=nil;
                    id billingUri=nil;
                    id taskName=nil;
                    id taskUri=nil;
                    id breakName=nil;
                    id breakUri=nil;
                    NSString *timeEntryClientName=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryClientName]];
                    if (timeEntryClientName==nil||[timeEntryClientName isKindOfClass:[NSNull class]]||[timeEntryClientName isEqualToString:@""]||[timeEntryClientName isEqualToString:NULL_STRING]||[timeEntryClientName isEqualToString:NULL_OBJECT_STRING])
                    {
                        clientName=[NSNull null];
                    }
                    else
                    {
                        clientName=timeEntryClientName;
                    }
                    NSString *timeEntryClientUri=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryClientUri]];
                    if (timeEntryClientUri==nil||[timeEntryClientUri isKindOfClass:[NSNull class]]||[timeEntryClientUri isEqualToString:@""]||[timeEntryClientUri isEqualToString:NULL_STRING]||[timeEntryClientUri isEqualToString:NULL_OBJECT_STRING])
                    {
                        clientUri=[NSNull null];
                    }
                    else
                    {
                        clientUri=timeEntryClientUri;
                    }

                    NSString *timeEntryProjectName=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryProjectName]];
                    if (timeEntryProjectName==nil||[timeEntryProjectName isKindOfClass:[NSNull class]]||[timeEntryProjectName isEqualToString:@""]||[timeEntryProjectName isEqualToString:NULL_STRING]||[timeEntryProjectName isEqualToString:NULL_OBJECT_STRING])
                    {
                        projectName=[NSNull null];
                    }
                    else
                    {
                        projectName=timeEntryProjectName;
                    }
                    NSString *timeEntryProjectUri=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryProjectUri]];
                    if (timeEntryProjectUri==nil||[timeEntryProjectUri isKindOfClass:[NSNull class]]||[timeEntryProjectUri isEqualToString:@""]||[timeEntryProjectUri isEqualToString:NULL_STRING]||[timeEntryProjectUri isEqualToString:NULL_OBJECT_STRING])
                    {
                        projectUri=[NSNull null];
                    }
                    else
                    {
                        projectUri=timeEntryProjectUri;
                    }
                    NSString *timeEntryActivityName=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryActivityName]];
                    if (timeEntryActivityName==nil||[timeEntryActivityName isKindOfClass:[NSNull class]]||[timeEntryActivityName isEqualToString:@""]||[timeEntryActivityName isEqualToString:NULL_STRING]||[timeEntryActivityName isEqualToString:NULL_OBJECT_STRING])
                    {
                        activityName=[NSNull null];
                    }
                    else
                    {
                        activityName=timeEntryActivityName;
                    }
                    NSString *timeEntryActivityUri=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryActivityUri]];
                    if (timeEntryActivityUri==nil||[timeEntryActivityUri isKindOfClass:[NSNull class]]||[timeEntryActivityUri isEqualToString:@""]||[timeEntryActivityUri isEqualToString:NULL_STRING]||[timeEntryActivityUri isEqualToString:NULL_OBJECT_STRING])
                    {
                        activityUri=[NSNull null];
                    }
                    else
                    {
                        activityUri=timeEntryActivityUri;
                    }
                    NSString *timeEntryBillingName=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryBillingName]];
                    if (timeEntryBillingName==nil||[timeEntryBillingName isKindOfClass:[NSNull class]]||[timeEntryBillingName isEqualToString:@""]||[timeEntryBillingName isEqualToString:NULL_STRING]||[timeEntryBillingName isEqualToString:NULL_OBJECT_STRING])
                    {
                        billingName=[NSNull null];
                    }
                    else
                    {
                        billingName=timeEntryBillingName;
                    }
                    NSString *timeEntryBillingUri=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryBillingUri]];
                    if (timeEntryBillingUri==nil||[timeEntryBillingUri isKindOfClass:[NSNull class]]||[timeEntryBillingUri isEqualToString:@""]||[timeEntryBillingUri isEqualToString:NULL_STRING]||[timeEntryBillingUri isEqualToString:NULL_OBJECT_STRING])
                    {
                        billingUri=[NSNull null];
                    }
                    else
                    {
                        billingUri=timeEntryBillingUri;
                    }
                    NSString *timeEntryTaskName=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryTaskName]];
                    if (timeEntryTaskName==nil||[timeEntryTaskName isKindOfClass:[NSNull class]]||[timeEntryTaskName isEqualToString:@""]||[timeEntryTaskName isEqualToString:NULL_STRING]||[timeEntryTaskName isEqualToString:NULL_OBJECT_STRING])
                    {
                        taskName=[NSNull null];
                    }
                    else
                    {
                        taskName=timeEntryTaskName;
                    }
                    NSString *timeEntryTaskUri=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryTaskUri]];
                    if (timeEntryTaskUri==nil||[timeEntryTaskUri isKindOfClass:[NSNull class]]||[timeEntryTaskUri isEqualToString:@""]||[timeEntryTaskUri isEqualToString:NULL_STRING]||[timeEntryTaskUri isEqualToString:NULL_OBJECT_STRING])
                    {
                        taskUri=[NSNull null];
                    }
                    else
                    {
                        taskUri=timeEntryTaskUri;
                    }
                    NSString *timeEntryBreakUri=[NSString stringWithFormat:@"%@",[tsEntryObject breakUri]];
                    if (timeEntryBreakUri==nil||[timeEntryBreakUri isKindOfClass:[NSNull class]]||[timeEntryBreakUri isEqualToString:@""]||[timeEntryBreakUri isEqualToString:NULL_STRING]||[timeEntryBreakUri isEqualToString:NULL_OBJECT_STRING])
                    {
                        breakUri=[NSNull null];
                    }
                    else
                    {
                        breakUri=timeEntryBreakUri;
                    }
                    NSString *timeEntryBreakName=[NSString stringWithFormat:@"%@",[tsEntryObject breakName]];
                    if (timeEntryBreakName==nil||[timeEntryBreakName isKindOfClass:[NSNull class]]||[timeEntryBreakName isEqualToString:@""]||[timeEntryBreakName isEqualToString:NULL_STRING]||[timeEntryBreakName isEqualToString:NULL_OBJECT_STRING])
                    {
                        breakName=[NSNull null];
                    }
                    else
                    {
                        breakName=timeEntryBreakName;
                    }


                    NSMutableDictionary *infoDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                   clientName,@"clientName",
                                                   clientUri,@"clientUri",
                                                   projectName,@"projectName",
                                                   projectUri,@"projectUri",
                                                   activityName,@"activityName",
                                                   activityUri,@"activityUri",
                                                   billingName,@"billingName",
                                                   billingUri,@"billingUri",
                                                   taskName,@"taskName",
                                                   taskUri,@"taskUri",
                                                   breakName,@"breakName",
                                                   breakUri,@"breakUri",
                                                   nil];
                    
                    if ([timeEntryDate compare:currentDate]==NSOrderedSame)
                    {
                        if (![activeCellObjectsArray containsObject:infoDict])
                        {
                            [activeCellObjectsArray addObject:infoDict];
                        }
                        
                    }
                }
            }

        }

        for (int i=0; i<[ctrl.timesheetDataArray count]; i++)
        {
            NSMutableArray *tempTimesheetEntryObjectArray=[ctrl.timesheetDataArray objectAtIndex:i];
            for (int j=0; j<[tempTimesheetEntryObjectArray count]; j++)
            {
                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[tempTimesheetEntryObjectArray objectAtIndex:j];
                BOOL isTimeoffSickRow=[tsEntryObject isTimeoffSickRowPresent];
                NSDate *timeEntryDate=[tsEntryObject timeEntryDate];
                if (!isTimeoffSickRow)
                {
                    id clientName=nil;
                    id clientUri=nil;
                    id projectName=nil;
                    id projectUri=nil;
                    id activityName=nil;
                    id activityUri=nil;
                    id billingName=nil;
                    id billingUri=nil;
                    id taskName=nil;
                    id taskUri=nil;
                    id breakName=nil;
                    id breakUri=nil;

                    NSString *timeEntryClientName=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryClientName]];
                    if (timeEntryClientName==nil||[timeEntryClientName isKindOfClass:[NSNull class]]||[timeEntryClientName isEqualToString:@""]||[timeEntryClientName isEqualToString:NULL_STRING]||[timeEntryClientName isEqualToString:NULL_OBJECT_STRING])
                    {
                        clientName=[NSNull null];
                    }
                    else
                    {
                        clientName=timeEntryClientName;
                    }
                    NSString *timeEntryClientUri=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryClientUri]];
                    if (timeEntryClientUri==nil||[timeEntryClientUri isKindOfClass:[NSNull class]]||[timeEntryClientUri isEqualToString:@""]||[timeEntryClientUri isEqualToString:NULL_STRING]||[timeEntryClientUri isEqualToString:NULL_OBJECT_STRING])
                    {
                        clientUri=[NSNull null];
                    }
                    else
                    {
                        clientUri=timeEntryClientUri;
                    }

                    NSString *timeEntryProjectName=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryProjectName]];
                    if (timeEntryProjectName==nil||[timeEntryProjectName isKindOfClass:[NSNull class]]||[timeEntryProjectName isEqualToString:@""]||[timeEntryProjectName isEqualToString:NULL_STRING]||[timeEntryProjectName isEqualToString:NULL_OBJECT_STRING])
                    {
                        projectName=[NSNull null];
                    }
                    else
                    {
                        projectName=timeEntryProjectName;
                    }
                    NSString *timeEntryProjectUri=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryProjectUri]];
                    if (timeEntryProjectUri==nil||[timeEntryProjectUri isKindOfClass:[NSNull class]]||[timeEntryProjectUri isEqualToString:@""]||[timeEntryProjectUri isEqualToString:NULL_STRING]||[timeEntryProjectUri isEqualToString:NULL_OBJECT_STRING])
                    {
                        projectUri=[NSNull null];
                    }
                    else
                    {
                        projectUri=timeEntryProjectUri;
                    }
                    NSString *timeEntryActivityName=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryActivityName]];
                    if (timeEntryActivityName==nil||[timeEntryActivityName isKindOfClass:[NSNull class]]||[timeEntryActivityName isEqualToString:@""]||[timeEntryActivityName isEqualToString:NULL_STRING]||[timeEntryActivityName isEqualToString:NULL_OBJECT_STRING])
                    {
                        activityName=[NSNull null];
                    }
                    else
                    {
                        activityName=timeEntryActivityName;
                    }
                    NSString *timeEntryActivityUri=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryActivityUri]];
                    if (timeEntryActivityUri==nil||[timeEntryActivityUri isKindOfClass:[NSNull class]]||[timeEntryActivityUri isEqualToString:@""]||[timeEntryActivityUri isEqualToString:NULL_STRING]||[timeEntryActivityUri isEqualToString:NULL_OBJECT_STRING])
                    {
                        activityUri=[NSNull null];
                    }
                    else
                    {
                        activityUri=timeEntryActivityUri;
                    }
                    NSString *timeEntryBillingName=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryBillingName]];
                    if (timeEntryBillingName==nil||[timeEntryBillingName isKindOfClass:[NSNull class]]||[timeEntryBillingName isEqualToString:@""]||[timeEntryBillingName isEqualToString:NULL_STRING]||[timeEntryBillingName isEqualToString:NULL_OBJECT_STRING])
                    {
                        billingName=[NSNull null];
                    }
                    else
                    {
                        billingName=timeEntryBillingName;
                    }
                    NSString *timeEntryBillingUri=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryBillingUri]];
                    if (timeEntryBillingUri==nil||[timeEntryBillingUri isKindOfClass:[NSNull class]]||[timeEntryBillingUri isEqualToString:@""]||[timeEntryBillingUri isEqualToString:NULL_STRING]||[timeEntryBillingUri isEqualToString:NULL_OBJECT_STRING])
                    {
                        billingUri=[NSNull null];
                    }
                    else
                    {
                        billingUri=timeEntryBillingUri;
                    }
                    NSString *timeEntryTaskName=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryTaskName]];
                    if (timeEntryTaskName==nil||[timeEntryTaskName isKindOfClass:[NSNull class]]||[timeEntryTaskName isEqualToString:@""]||[timeEntryTaskName isEqualToString:NULL_STRING]||[timeEntryTaskName isEqualToString:NULL_OBJECT_STRING])
                    {
                        taskName=[NSNull null];
                    }
                    else
                    {
                        taskName=timeEntryTaskName;
                    }
                    NSString *timeEntryTaskUri=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryTaskUri]];
                    if (timeEntryTaskUri==nil||[timeEntryTaskUri isKindOfClass:[NSNull class]]||[timeEntryTaskUri isEqualToString:@""]||[timeEntryTaskUri isEqualToString:NULL_STRING]||[timeEntryTaskUri isEqualToString:NULL_OBJECT_STRING])
                    {
                        taskUri=[NSNull null];
                    }
                    else
                    {
                        taskUri=timeEntryTaskUri;
                    }
                    NSString *timeEntryBreakUri=[NSString stringWithFormat:@"%@",[tsEntryObject breakUri]];
                    if (timeEntryBreakUri==nil||[timeEntryBreakUri isKindOfClass:[NSNull class]]||[timeEntryBreakUri isEqualToString:@""]||[timeEntryBreakUri isEqualToString:NULL_STRING]||[timeEntryBreakUri isEqualToString:NULL_OBJECT_STRING])
                    {
                        breakUri=[NSNull null];
                    }
                    else
                    {
                        breakUri=timeEntryBreakUri;
                    }
                    NSString *timeEntryBreakName=[NSString stringWithFormat:@"%@",[tsEntryObject breakName]];
                    if (timeEntryBreakName==nil||[timeEntryBreakName isKindOfClass:[NSNull class]]||[timeEntryBreakName isEqualToString:@""]||[timeEntryBreakName isEqualToString:NULL_STRING]||[timeEntryBreakName isEqualToString:NULL_OBJECT_STRING])
                    {
                        breakName=[NSNull null];
                    }
                    else
                    {
                        breakName=timeEntryBreakName;
                    }


                    NSMutableDictionary *infoDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                   clientName,@"clientName",
                                                   clientUri,@"clientUri",
                                                   projectName,@"projectName",
                                                   projectUri,@"projectUri",
                                                   activityName,@"activityName",
                                                   activityUri,@"activityUri",
                                                   billingName,@"billingName",
                                                   billingUri,@"billingUri",
                                                   taskName,@"taskName",
                                                   taskUri,@"taskUri",
                                                   breakName,@"breakName",
                                                   breakUri,@"breakUri",
                                                   nil];

                    if ([timeEntryDate compare:currentDate]!=NSOrderedSame)
                    {


                        if ([activeCellObjectsArray containsObject:infoDict])
                        {

                            return YES;
                        }
                    }

                }
            }

        }

    }
    return NO;
}

-(void)updateExtendedInOutTimeEntryForSplitOnIndex:(NSInteger)rowIndex forSection:(NSInteger)sectionIndex withValue:(NSMutableDictionary *)multiInoutEntry
{
    //NSLog(@"SAVE--->  In::%@  Out::%@",[multiInoutEntry objectForKey:@"in_time"],[multiInoutEntry objectForKey:@"out_time"]);
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;
        tsMainPageCtrl.hasUserChangedAnyValue=YES;
        [self changeParentViewLeftBarbutton];
    }
    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:sectionIndex];
    NSString *clientName=tsEntryObject.timeEntryClientName;
    NSString *clientUri=tsEntryObject.timeEntryClientUri;
    NSString *projectName=tsEntryObject.timeEntryProjectName;
    NSString *projectUri=tsEntryObject.timeEntryProjectUri;
    NSString *taskName=tsEntryObject.timeEntryTaskName;
    NSString *taskUri=tsEntryObject.timeEntryTaskUri;
    NSString *activityName=tsEntryObject.timeEntryActivityName;
    NSString *activityUri=tsEntryObject.timeEntryActivityUri;
    NSString *timeOffName=tsEntryObject.timeEntryTimeOffName;
    NSString *timeOffUri=tsEntryObject.timeEntryTimeOffUri;
    NSString *billingName=tsEntryObject.timeEntryBillingName;
    NSString *billingUri=tsEntryObject.timeEntryBillingUri;
    NSString *hoursInHourFormat=tsEntryObject.timeEntryHoursInHourFormat;
    NSString *comments=tsEntryObject.timeEntryComments;
    NSMutableArray *udfArray=tsEntryObject.timeEntryUdfArray;
    NSString *punchUri=tsEntryObject.timePunchUri;
    NSString *allocationUri=tsEntryObject.timeAllocationUri;
    NSString *entryType=tsEntryObject.entryType;
    NSDate *entryDate=tsEntryObject.timeEntryDate;
    BOOL isTimeoffSickRowPresent=tsEntryObject.isTimeoffSickRowPresent;
    NSString *timesheetUri=tsEntryObject.timesheetUri;
    //Implentation for US8956//JUHI
    NSString *breakName=tsEntryObject.breakName;
    NSString *breakUri=tsEntryObject.breakUri;
    NSString *programName=tsEntryObject.timeEntryProgramName;
    NSString *programUri=tsEntryObject.timeEntryProgramUri;
    NSString *rowUri=tsEntryObject.rowUri;

    TimesheetEntryObject *tsTempEntryObject=[[TimesheetEntryObject alloc] init];
    //MOBI-746
    [tsTempEntryObject setTimeEntryProgramUri:programUri];
    [tsTempEntryObject setTimeEntryProgramName:programName];
    [tsTempEntryObject setTimeEntryClientName:clientName];
    [tsTempEntryObject setTimeEntryClientUri:clientUri];
    [tsTempEntryObject setTimeEntryProjectName:projectName];
    [tsTempEntryObject setTimeEntryProjectUri:projectUri];
    [tsTempEntryObject setTimeEntryTaskName:taskName];
    [tsTempEntryObject setTimeEntryTaskUri:taskUri];
    [tsTempEntryObject setTimeEntryActivityName:activityName];
    [tsTempEntryObject setTimeEntryActivityUri:activityUri];
    [tsTempEntryObject setTimeEntryTimeOffName:timeOffName];
    [tsTempEntryObject setTimeEntryTimeOffUri:timeOffUri];
    [tsTempEntryObject setTimeEntryBillingName:billingName];
    [tsTempEntryObject setTimeEntryBillingUri:billingUri];
    [tsTempEntryObject setTimeEntryHoursInHourFormat:hoursInHourFormat];
    [tsTempEntryObject setTimeEntryComments:comments];
    [tsTempEntryObject setTimeEntryUdfArray:udfArray];
    [tsTempEntryObject setMultiDayInOutEntry:multiInoutEntry];
    [tsTempEntryObject setTimePunchUri:punchUri];
    [tsTempEntryObject setTimeAllocationUri:allocationUri];
    [tsTempEntryObject setTimeEntryDate:entryDate];
    [tsTempEntryObject setIsTimeoffSickRowPresent:isTimeoffSickRowPresent];
    [tsTempEntryObject setEntryType:entryType];
    [tsTempEntryObject setTimesheetUri:timesheetUri];
    //Implentation for US8956//JUHI
    [tsTempEntryObject setBreakName:breakName];
    [tsTempEntryObject setBreakUri:breakUri];
    [tsTempEntryObject setRowUri:rowUri];

    NSMutableArray *punchArray=[NSMutableArray arrayWithArray:tsEntryObject.timePunchesArray];
    if (multiInOutTimesheetType==EXTENDED_IN_OUT_TIMESHEET_TYPE)
    {
        NSMutableArray *tmpArray=[inoutTsObjectsArray objectAtIndex:sectionIndex];
        [tmpArray replaceObjectAtIndex:rowIndex withObject:[self createInOutTimesheetobjectArrayForMultiInoutDictionaryObject:multiInoutEntry]];
        [self.inoutTsObjectsArray replaceObjectAtIndex:sectionIndex withObject:tmpArray];

    }
    NSMutableArray *tmpUdfArray=[[punchArray objectAtIndex:rowIndex] objectForKey:@"udfArray"];
    NSString *commentsSave=[[punchArray objectAtIndex:rowIndex] objectForKey:@"comments"];
    if (tmpUdfArray!=nil && [tmpUdfArray count]!=0)
    {
        [multiInoutEntry setObject:tmpUdfArray forKey:@"udfArray"];
    }
    if (commentsSave==nil ||[commentsSave isKindOfClass:[NSNull class]] || [commentsSave isEqualToString:@""]|| [commentsSave isEqualToString:NULL_STRING])
    {
        [multiInoutEntry setObject:@"" forKey:@"comments"];
    }
    else
    {
        [multiInoutEntry setObject:commentsSave forKey:@"comments"];
    }
    NSString *clientPunchID=[[punchArray objectAtIndex:rowIndex] objectForKey:@"clientID"];
    if (clientPunchID==nil ||[clientPunchID isKindOfClass:[NSNull class]]||[clientPunchID isEqualToString:@""])
    {
        [multiInoutEntry setObject:@"" forKey:@"clientID"];
    }
    else{
        [multiInoutEntry setObject:clientPunchID forKey:@"clientID"];
    }

    [punchArray replaceObjectAtIndex:rowIndex withObject:multiInoutEntry];
    [tsTempEntryObject setTimePunchesArray:punchArray];
    NSMutableDictionary *returnDict=[self returnTotalCalculatedHoursForObject:tsEntryObject];
    [tsTempEntryObject setTimeEntryHoursInDecimalFormat:@"WithRoundoff"];
    [tsTempEntryObject setTimeEntryHoursInDecimalFormatWithOutRoundOff:[returnDict objectForKey:@"WithoutRoundoff"]];
    [self.timesheetEntryObjectArray replaceObjectAtIndex:sectionIndex withObject:tsTempEntryObject];
}


-(void)gen4TimeEntrySaveResponseReceived:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BLANK_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SAVE_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
    NSDictionary *theData = [notification userInfo];
    NSString *receivedClientID=[theData objectForKey:@"clientId"];
    NSString *receivedPunchID=[theData objectForKey:@"timeEntryUri"];
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;
        if (tsMainPageCtrl.pageControl.currentPage<tsMainPageCtrl.timesheetDataArray.count)
        {
            NSMutableArray *array=[tsMainPageCtrl.timesheetDataArray objectAtIndex:tsMainPageCtrl.pageControl.currentPage];
            for (int i=0; i<[array count]; i++)
            {
                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[array objectAtIndex:i];
                NSString *clientID=[[[tsEntryObject timePunchesArray] objectAtIndex:0] objectForKey:@"clientID"];

                if ([clientID isEqualToString:receivedClientID])
                {
                    NSMutableDictionary *tmpDict=[NSMutableDictionary dictionaryWithDictionary:[[tsEntryObject timePunchesArray] objectAtIndex:0]];
                    if (receivedPunchID!=nil && ![receivedPunchID isKindOfClass:[NSNull class]])
                    {
                        [tmpDict setObject:receivedPunchID forKey:@"timePunchesUri"];
                    }

                    [[tsEntryObject timePunchesArray] replaceObjectAtIndex:0 withObject:[NSMutableDictionary dictionaryWithDictionary:tmpDict]];
                    [array replaceObjectAtIndex:i withObject:tsEntryObject];
                    break;
                }
            }
            [tsMainPageCtrl.timesheetDataArray replaceObjectAtIndex:tsMainPageCtrl.pageControl.currentPage withObject:array];
        }


        if (tsMainPageCtrl.parentDelegate!=nil && [tsMainPageCtrl.parentDelegate isKindOfClass:[WidgetTSViewController class]])
        {
            WidgetTSViewController *ctrlll=(WidgetTSViewController *)tsMainPageCtrl.parentDelegate;
            [ctrlll.widgetTableView reloadData];

        }


    }
}

-(void)gen4TimeEntryDeleteResponseReceived:(NSDictionary *)dict
{
    NSDictionary *theData = dict;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DELETE_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
    int section=[[theData objectForKey:@"section"] intValue];
    int row=[[theData objectForKey:@"row"] intValue];
    TimesheetEntryObject *deleteEntryObject=(TimesheetEntryObject *)[self.timesheetEntryObjectArray objectAtIndex:section];
    TimesheetMainPageController *ctrl=(TimesheetMainPageController *)controllerDelegate;
    if (ctrl.pageControl.currentPage<ctrl.timesheetDataArray.count)
    {
        NSMutableArray *entryDataArray=[ctrl.timesheetDataArray objectAtIndex:ctrl.pageControl.currentPage];
        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[entryDataArray objectAtIndex:section];
        NSDate *todayDate=nil;
        if (![tsEntryObject isTimeoffSickRowPresent])
        {
            todayDate=[deleteEntryObject timeEntryDate];
            [entryDataArray removeObjectIdenticalTo:deleteEntryObject];
            [[deleteEntryObject timePunchesArray] removeObjectAtIndex:row];
            if ([[deleteEntryObject timePunchesArray] count]!=0)
            {
                [entryDataArray insertObject:deleteEntryObject atIndex:section];
            }


        }
        [ctrl.timesheetDataArray replaceObjectAtIndex:ctrl.pageControl.currentPage withObject:entryDataArray];
        BOOL isEmptyRowPresentOnTheDay=NO;
        for (int k=0; k<[entryDataArray count]; k++)
        {
            TimesheetEntryObject *tobject=(TimesheetEntryObject *)[entryDataArray objectAtIndex:k];
            BOOL isBreakEntry=NO;
            NSString *breakUri=[tobject breakUri];
            if (breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]]&& ![breakUri isEqualToString:@""]) {
                isBreakEntry=YES;
            }

            if (!isBreakEntry && [[tobject timePunchesArray] count]>0)
            {
                BOOL isInTimeEmpty=NO;
                BOOL isOutTimeEmpty=NO;
                NSString *in_time=[[[tobject timePunchesArray] objectAtIndex:0] objectForKey:@"in_time"];
                NSString *out_time=[[[tobject timePunchesArray] objectAtIndex:0] objectForKey:@"out_time"];
                if (in_time==nil||[in_time isKindOfClass:[NSNull class]]||[in_time isEqualToString:@""])
                {
                    isInTimeEmpty=YES;
                }
                if (out_time==nil||[out_time isKindOfClass:[NSNull class]]||[out_time isEqualToString:@""])
                {
                    isOutTimeEmpty=YES;
                }
                if (isOutTimeEmpty && isInTimeEmpty)
                {
                    isEmptyRowPresentOnTheDay=YES;
                }
            }

        }
        if (!isEmptyRowPresentOnTheDay)
        {
            BOOL isSimpleInOutGen4Timesheet=YES;
            if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
            {
                if([self.timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])            {
                    BOOL isExtInOutWidgetProjectAccess=NO;
                    BOOL isExtInOutWidgetActivityAccess=NO;
                    SupportDataModel *supportModel=[[SupportDataModel alloc]init];
                    NSDictionary *dict=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];

                    isExtInOutWidgetProjectAccess=[[dict objectForKey:@"allowProjectsTasksForExtInOutGen4"] boolValue];
                    isExtInOutWidgetActivityAccess=[[dict objectForKey:@"allowActivitiesForExtInOutGen4"] boolValue];
                    if (isExtInOutWidgetProjectAccess || isExtInOutWidgetActivityAccess)
                    {
                        isSimpleInOutGen4Timesheet=NO;
                    }
                }
            }


            if (isSimpleInOutGen4Timesheet)
            {
                [ctrl createBlankEntryForGen4:ctrl.pageControl.currentPage andDate:todayDate];
            }

        }
        [ctrl setHasUserChangedAnyValue:YES];
        [self calculateAndUpdateTotalHoursValueForFooter];
        [ctrl reloadViewWithRefreshedDataAfterSave];
        [self checkGen4ServerPunchIdForAllTimeEntries];
        if (ctrl.parentDelegate!=nil && [ctrl.parentDelegate isKindOfClass:[WidgetTSViewController class]])
        {
            WidgetTSViewController *ctrlll=(WidgetTSViewController *)ctrl.parentDelegate;
            [ctrlll.widgetTableView reloadData];
            
        }
    }

}

-(void)gen4BreakEntrySaveResponseReceived:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDIT_BREAK_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
    NSDictionary *theData = [notification userInfo];
    NSString *receivedClientID=[theData objectForKey:@"clientId"];
    NSString *receivedPunchID=[theData objectForKey:@"timeEntryUri"];
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;
        if (tsMainPageCtrl.pageControl.currentPage<tsMainPageCtrl.timesheetDataArray.count)
        {
            NSMutableArray *array=[tsMainPageCtrl.timesheetDataArray objectAtIndex:tsMainPageCtrl.pageControl.currentPage];
            for (int i=0; i<[array count]; i++)
            {
                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[array objectAtIndex:i];
                NSUInteger count=[[tsEntryObject timePunchesArray] count];
                for (int k=0; k<count; k++)
                {

                    NSString *clientID=[[[tsEntryObject timePunchesArray] objectAtIndex:k] objectForKey:@"clientID"];
                    if ([clientID isEqualToString:receivedClientID])
                    {
                        NSMutableDictionary *tmpDict=[NSMutableDictionary dictionaryWithDictionary:[[tsEntryObject timePunchesArray] objectAtIndex:k]];
                        if (receivedPunchID!=nil && ![receivedPunchID isKindOfClass:[NSNull class]])
                        {
                            [tmpDict setObject:receivedPunchID forKey:@"timePunchesUri"];
                        }

                        [[tsEntryObject timePunchesArray] replaceObjectAtIndex:k withObject:[NSMutableDictionary dictionaryWithDictionary:tmpDict]];
                        [array replaceObjectAtIndex:i withObject:tsEntryObject];
                        break;
                    }
                }
            }
            [tsMainPageCtrl.timesheetDataArray replaceObjectAtIndex:tsMainPageCtrl.pageControl.currentPage withObject:array];
            if (tsMainPageCtrl.parentDelegate!=nil && [tsMainPageCtrl.parentDelegate isKindOfClass:[WidgetTSViewController class]])
            {
                WidgetTSViewController *ctrlll=(WidgetTSViewController *)tsMainPageCtrl.parentDelegate;
                [ctrlll.widgetTableView reloadData];
                
            }
        }


    }

}
-(void)sendRequestToEditBreakEntryForTimeEntryObj:(TimesheetEntryObject *)tsEntryObj
{

    if ([tsEntryObj.timePunchesArray count]>0)
    {
        NSMutableDictionary *timeDict=[tsEntryObj.timePunchesArray objectAtIndex:0];
        NSString *clientID=[timeDict objectForKey:@"clientID"];
        NSString *timePunchesUri=[timeDict objectForKey:@"timePunchesUri"];
        NSString *entryUri = timePunchesUri != nil  && timePunchesUri != (id)[NSNull null] && ![timePunchesUri isEqualToString:@""] ? timePunchesUri : clientID;
        NSString *entryUriColumnName = timePunchesUri != nil  && timePunchesUri != (id)[NSNull null] && ![timePunchesUri isEqualToString:@""]  ? @"timePunchesUri" : @"clientPunchId";
        [[NSNotificationCenter defaultCenter] removeObserver:self name:EDIT_BREAK_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gen4BreakEntrySaveResponseReceived:) name:EDIT_BREAK_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
        [[RepliconServiceManager timesheetService] sendRequestToSaveBreakTimeEntryForGen4:self withBreakUri:tsEntryObj.breakUri isBlankTimeEntrySave:NO withTimeEntryUri:timePunchesUri withStartDate:tsEntryObj.timeEntryDate forTimeSheetUri:tsEntryObj.timesheetUri withTimeDict:timeDict withClientID:entryUri withBreakName:tsEntryObj.breakName timesheetFormat:self.timesheetFormat andColumnNameForEntryUri:entryUriColumnName];
        [self updateUserChangedFlag];
    }

}

-(void)updateDropDownFieldWithFieldName:(NSString*)fieldName andFieldURI:(NSString*)fieldUri
{

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




#pragma mark - Memory Management
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateUserChangedFlag
{
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *timesheetMainPageController=(TimesheetMainPageController *)controllerDelegate;
        timesheetMainPageController.hasUserChangedAnyValue=YES;
        [self changeParentViewLeftBarbutton];
    }
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

- (void) dealloc
{
    self.multiDayTimeEntryTableView.delegate = nil;
    self.multiDayTimeEntryTableView.dataSource = nil;
}

-(void)hidekeyboard
{
    UITextField *textField = self.lastUsedTextField;
    if (textField!=nil &&![textField isKindOfClass:[NSNull class]])
    {
        [textField resignFirstResponder];

    }

}


#pragma  mark - helper method

- (TimesheetEntryObject *)getSelectedTimesheetEntryObject {
    NSInteger index = (multiInOutTimesheetType == EXTENDED_IN_OUT_TIMESHEET_TYPE) ? self.selectedIndexPath.section : self.selectedIndexPath.row;
    return [self getTimesheetEntryObjectAtIndex:index];
}

- (TimesheetEntryObject *)getTimesheetEntryObjectAtIndex:(NSInteger)index {
    if (timesheetEntryObjectArray.count > index)
       return [timesheetEntryObjectArray objectAtIndex:index];
    
    return nil;
}

@end
