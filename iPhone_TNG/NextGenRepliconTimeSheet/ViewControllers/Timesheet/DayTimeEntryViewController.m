//
//  DayTimeEntryViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 09/01/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import "DayTimeEntryViewController.h"
#import "Constants.h"
#import "CurrentTimeSheetsCellView.h"
#import "DayTimeEntryCustomCell.h"
#import "TimesheetEntryObject.h"
#import "Util.h"
#import "AppDelegate.h"
#import "TimeEntryViewController.h"
#import "TimesheetMainPageController.h"
#import "LoginModel.h"
#import "ApprovalsScrollViewController.h"
#import "EditEntryViewController.h"
#import "BookedTimeOffEntry.h"
#import "TimeOffObject.h"
#import "TimeOffDetailsViewController.h"
#import "ApprovalsNavigationController.h"
#import "SupervisorDashboardNavigationController.h"
#import "OEFObject.h"
#import "UIView+Additions.h"
#import <Blindside/Blindside.h>

#define Total_Hours_Footer_Height 28
#define Extra_Padding_Cell 35
#define Done_Toolbar_Height 44
#define CONTENT_IMAGEVIEW_TAG 9999
#define LEFT_PADDING 10
#define TOTAL_VALUE_LABEL_WIDTH 90
#define LABEL_WIDTH (SCREEN_WIDTH-100-2*LEFT_PADDING)

@interface DayTimeEntryViewController()
@property(nonatomic)TimesheetModel *timesheetModel;
@property(nonatomic)UIAlertView *syncInProgressAlertView;
@property (nonatomic) NSInteger selectedIndex;
@end

@implementation DayTimeEntryViewController
@synthesize timeEntryTableView;
@synthesize timesheetDataArray;
@synthesize currentIndexpath;
@synthesize datePicker;
@synthesize toolbar;
@synthesize selectedIndexPath;
@synthesize isTextFieldClicked;
@synthesize lastUsedTextView;
@synthesize timesheetEntryObjectArray;
@synthesize standardTimesheetStatus;
@synthesize isUDFieldClicked;
@synthesize controllerDelegate;
@synthesize isProjectAccess,isClientAccess;
@synthesize isActivityAccess;
@synthesize selectedDropdownUdfIndex;
@synthesize selectedTextUdfIndex;
@synthesize isBillingAccess;
@synthesize totallabelView;
@synthesize totalLabelHoursLbl;
@synthesize currentPageDate;
@synthesize cellHeightsArray;
@synthesize isProgramAccess;
@synthesize approvalsDelegate;
@synthesize allowNegativeTimeEntry;
#pragma mark -
#pragma mark View lifeCycle Methods

- (void)loadView
{
	[super loadView];

    self.view = [[UIView alloc] init];

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    [self.view setBackgroundColor:[Util colorWithHex:@"#f8f8f8" alpha:1]];

    self.timeEntryTableView = [[UITableView alloc] init];
    [self.timeEntryTableView setAccessibilityLabel:@"uia_standard_timesheet_entry_table_identifier"];
    self.timeEntryTableView.delegate = self;
    self.timeEntryTableView.dataSource = self;
     [self.timeEntryTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview: self.timeEntryTableView];

	UIView *bckView = [UIView new];
    [bckView setFrame:CGRectMake(0,0 ,screenRect.size.width,screenRect.size.height)];
	[bckView setBackgroundColor:RepliconStandardWhiteColor];
	[ self.timeEntryTableView setBackgroundView:bckView];


    float totalCalculatedHours=0;
    for (int i=0; i<[self.timesheetEntryObjectArray count]; i++)
    {
        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:i];
        float timeEntryHours=[[tsEntryObject timeEntryHoursInDecimalFormat] newFloatValue];
        totalCalculatedHours=totalCalculatedHours+timeEntryHours;
    }
    NSString *totalHoursString=[NSString stringWithFormat:@"%f",totalCalculatedHours];

    self.totallabelView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, Total_Hours_Footer_Height)];
    [self.totallabelView setBackgroundColor:[Util colorWithHex:@"#EEEEEE" alpha:1.0f]];
    
    UILabel *totalLabel=[[UILabel alloc]initWithFrame:CGRectMake(LEFT_PADDING, 4,LABEL_WIDTH-LEFT_PADDING ,20.0)];
	[totalLabel setText:[NSString stringWithFormat:@"%@",RPLocalizedString(TotalString, TotalString) ]];//UI Changes//JUHI
	[totalLabel setTextColor:[UIColor blackColor]];
    [totalLabel setBackgroundColor: [UIColor clearColor]];
	[totalLabel setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];
	[totallabelView addSubview:totalLabel];


	UILabel *totalValueLabel=[[UILabel alloc]initWithFrame:CGRectMake(totalLabel.right+LEFT_PADDING, 4, TOTAL_VALUE_LABEL_WIDTH, 20.0)];
	[totalValueLabel setText:[Util getRoundedValueFromDecimalPlaces:[totalHoursString newDoubleValue]withDecimalPlaces:2]];
	[totalValueLabel setTextColor: [UIColor blackColor]];
    [totalValueLabel setBackgroundColor: [UIColor clearColor]];
	[totalValueLabel setTextAlignment: NSTextAlignmentRight];
	[totalValueLabel setFont:[UIFont fontWithName:RepliconFontFamilySemiBold size:RepliconFontSize_17]];
    self.totalLabelHoursLbl=totalValueLabel;
	[totallabelView addSubview:totalValueLabel];

    [self.view addSubview:totallabelView];

    UIImage *separatorImage = [Util thumbnailImage:Cell_HairLine_Image];
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,0, SCREEN_WIDTH,1)];
    [lineImageView setImage:separatorImage];
    [self.timeEntryTableView setTableFooterView:lineImageView];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    for (UIGestureRecognizer *recognizer in self.timeEntryTableView.tableHeaderView.gestureRecognizers)
    {
        [self.timeEntryTableView.tableHeaderView removeGestureRecognizer:recognizer];
    }
    [self.timeEntryTableView.tableHeaderView addGestureRecognizer:tap];
    self.cellHeightsArray=[NSMutableArray array];
    

}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createToolBar];
    UIViewController *controllerViewCtrl=(UIViewController *)controllerDelegate;
    self.timesheetModel = [[TimesheetModel alloc]init];
      AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    //Approval context Flow for timesheets
    if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [appDelegate.rootTabBarController.selectedViewController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]] || [appDelegate.rootTabBarController.selectedViewController isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
        TimesheetMainPageController *controllerViewCtrl=(TimesheetMainPageController *)controllerDelegate;
        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)[controllerViewCtrl parentDelegate];
        
        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            
            if (self.sheetIdentity!=nil && ![self.sheetIdentity isKindOfClass:[NSNull class]])
            {
                
                SupportDataModel *supportDataModel=[[SupportDataModel alloc]init];
                NSDictionary *permittedApprovalAcionsDict=[supportDataModel getTimesheetPermittedApprovalActionsDataToDBWithUri:self.sheetIdentity];
                
                
                
                ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
                
                self.timesheetFormat=[approvalModel getTimesheetFormatforTimesheetUri:self.sheetIdentity andIsPending:TRUE];

                if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
                {
                    if([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                    {
                        self.isProjectAccess=[[permittedApprovalAcionsDict objectForKey:@"allowProjectsTasksForStandardGen4"] boolValue];
                        self.isClientAccess=[[permittedApprovalAcionsDict objectForKey:@"allowClientsForStandardGen4"] boolValue];
                        self.isActivityAccess=[[permittedApprovalAcionsDict objectForKey:@"allowActivitiesForStandardGen4"] boolValue];
                        self.isBillingAccess=[[permittedApprovalAcionsDict objectForKey:@"allowBillingForStandardGen4"] boolValue];
                        self.isProgramAccess=[[permittedApprovalAcionsDict objectForKey:@"allowProgramsForStandardGen4"] boolValue];
                    }
                    else if([self.timesheetFormat isEqualToString:STANDARD_TIMESHEET])
                    {
                        self.isProjectAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:self.sheetIdentity];
                        self.isClientAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetClientAccess" forSheetUri:self.sheetIdentity];
                        self.isActivityAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:self.sheetIdentity];
                        self.isBillingAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:self.sheetIdentity];
                        self.isProgramAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProgramAccess" forSheetUri:self.sheetIdentity];
                    }
                }

                
                
                
            }
            
            

        }
        else
        {
            
           
            if (self.sheetIdentity!=nil && ![self.sheetIdentity isKindOfClass:[NSNull class]])
            {
                
                SupportDataModel *supportDataModel=[[SupportDataModel alloc]init];
                NSDictionary *permittedApprovalAcionsDict=[supportDataModel getTimesheetPermittedApprovalActionsDataToDBWithUri:self.sheetIdentity];
               
                
                
                ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
                
                self.timesheetFormat=[approvalModel getTimesheetFormatforTimesheetUri:self.sheetIdentity andIsPending:FALSE];

                if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
                {
                    if([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                    {
                        self.isProjectAccess=[[permittedApprovalAcionsDict objectForKey:@"allowProjectsTasksForStandardGen4"] boolValue];
                        self.isClientAccess=[[permittedApprovalAcionsDict objectForKey:@"allowClientsForStandardGen4"] boolValue];
                        self.isActivityAccess=[[permittedApprovalAcionsDict objectForKey:@"allowActivitiesForStandardGen4"] boolValue];
                        self.isBillingAccess=[[permittedApprovalAcionsDict objectForKey:@"allowBillingForStandardGen4"] boolValue];
                        self.isProgramAccess=[[permittedApprovalAcionsDict objectForKey:@"allowProgramsForStandardGen4"] boolValue];
                    }
                    else if([self.timesheetFormat isEqualToString:STANDARD_TIMESHEET])
                    {
                        self.isProjectAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:self.sheetIdentity];
                        self.isClientAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetClientAccess" forSheetUri:self.sheetIdentity];
                        self.isActivityAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:self.sheetIdentity];
                        self.isBillingAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:self.sheetIdentity];
                        self.isProgramAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProgramAccess" forSheetUri:self.sheetIdentity];
                    }
                }
                
            }
            
            

        }



    }
    //User context Flow for timesheets
    else if([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        
       
        if (self.sheetIdentity!=nil && ![self.sheetIdentity isKindOfClass:[NSNull class]])
        {
            
            SupportDataModel *supportDataModel=[[SupportDataModel alloc]init];
            NSDictionary *permittedApprovalAcionsDict=[supportDataModel getTimesheetPermittedApprovalActionsDataToDBWithUri:self.sheetIdentity];
            
            
            
            
            self.timesheetFormat=[self.timesheetModel getTimesheetFormatforTimesheetUri:self.sheetIdentity];
            
            if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
            {
                if([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                {
                    self.isProjectAccess=[[permittedApprovalAcionsDict objectForKey:@"allowProjectsTasksForStandardGen4"] boolValue];
                    self.isClientAccess=[[permittedApprovalAcionsDict objectForKey:@"allowClientsForStandardGen4"] boolValue];
                    self.isActivityAccess=[[permittedApprovalAcionsDict objectForKey:@"allowActivitiesForStandardGen4"] boolValue];
                    self.isBillingAccess=[[permittedApprovalAcionsDict objectForKey:@"allowBillingForStandardGen4"] boolValue];
                    self.isProgramAccess=[[permittedApprovalAcionsDict objectForKey:@"allowProgramsForStandardGen4"] boolValue];
                    self.allowNegativeTimeEntry =[[permittedApprovalAcionsDict objectForKey:@"allowNegativeTimeEntry"] boolValue];
                }
                else if([self.timesheetFormat isEqualToString:STANDARD_TIMESHEET])
                {
                    self.isProjectAccess=[self.timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:self.sheetIdentity];
                    self.isClientAccess=[self.timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetClientAccess" forSheetUri:self.sheetIdentity];
                    self.isActivityAccess=[self.timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:self.sheetIdentity];
                    self.isBillingAccess=[self.timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:self.sheetIdentity];
                    self.isProgramAccess=[self.timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProgramAccess" forSheetUri:self.sheetIdentity];
                }
            }
            

        }
        
        

    }

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
        DayTimeEntryCustomCell *cell = (DayTimeEntryCustomCell *)[timeEntryTableView cellForRowAtIndexPath:currentIndexpath];
        [cell doneClicked];
        [self doneAction:NO withSender:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.timeEntryTableView.frame = CGRectMake(0, Total_Hours_Footer_Height, CGRectGetWidth([[UIScreen mainScreen] bounds]), [self heightForTableView] - Total_Hours_Footer_Height - 50.0f);

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

#pragma mark
#pragma mark  Properties

- (void)setLastUsedTextField:(id)lastUsedTextField {
    _lastUsedTextField = lastUsedTextField;
    if ([_lastUsedTextField isKindOfClass:[UITextField class]]) {
        [self.toolbar setHidden:NO];
        UITextField *textFiled = _lastUsedTextField;
        [textFiled setInputAccessoryView:self.toolbar];
    }
}

#pragma mark
#pragma mark  UITableView Delegates

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:RepliconStandardBackgroundColor];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self calculateHeights];
    return [[[cellHeightsArray objectAtIndex:[indexPath row]]objectForKey:CELL_HEIGHT_KEY]floatValue];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [timesheetEntryObjectArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"TimeSheetCellIdentifier";

    DayTimeEntryCustomCell *cell = (DayTimeEntryCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
    {
        cell = [[DayTimeEntryCustomCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }


    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }

    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:indexPath.row];
    BOOL isEditState=YES;
    if ([standardTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
        [standardTimesheetStatus isEqualToString:APPROVED_STATUS ]||
        [tsEntryObject.entryType isEqualToString:Time_Off_Key]||![tsEntryObject isRowEditable])
    {
        isEditState=NO;
    }

    NSString *timeEntryComments=[tsEntryObject timeEntryComments];
    BOOL commentsImageReq=NO;
    if (timeEntryComments!=nil && [timeEntryComments length]!=0&& ![timeEntryComments isEqualToString:@""])
    {
        commentsImageReq=YES;
    }
    
    
    BOOL isTimeoffSickRow=[tsEntryObject isTimeoffSickRowPresent];
    BOOL isTimeoffRow=NO;
    float height=0;
    if ([cellHeightsArray count]>0)
    {
        height=[[[cellHeightsArray objectAtIndex:indexPath.row] objectForKey:CELL_HEIGHT_KEY] newFloatValue];
    }

    if (isTimeoffSickRow) {

        if([tsEntryObject.entryType isEqualToString:Time_Off_Key]) {
            isTimeoffRow=YES;
            CGRect contentViewFrame=cell.contentView.frame;
            contentViewFrame.size.height=height;
            UIImageView *contentImageView=[[UIImageView alloc]initWithFrame:(CGRect){CGPointZero,{SCREEN_WIDTH,height}}];
            contentImageView.backgroundColor=[UIColor clearColor];
            contentImageView.tag=CONTENT_IMAGEVIEW_TAG;
            [cell.contentView addSubview:contentImageView];
            [contentImageView setImage:[UIImage imageNamed:@"holiday_background"]];
        }
    }


    UIViewController *controllerViewCtrl=(UIViewController *)controllerDelegate;
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    //Approval context Flow for timesheets
    if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [appDelegate.rootTabBarController.selectedViewController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]] || [appDelegate.rootTabBarController.selectedViewController isKindOfClass:[SupervisorDashboardNavigationController class]])
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

    NSMutableDictionary *heightDict=nil;
    if ([cellHeightsArray count]>0)
    {
        heightDict=[cellHeightsArray objectAtIndex:indexPath.row];
    }
    
    BOOL hasCommentsAccess=YES;

    if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
    {
        if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
        {
            SupportDataModel *supportDataModel=[[SupportDataModel alloc]init];
            NSDictionary *permittedApprovalAcionsDict=[supportDataModel getTimesheetPermittedApprovalActionsDataToDBWithUri:self.sheetIdentity];
            hasCommentsAccess=[[permittedApprovalAcionsDict objectForKey:@"allowCommentsForStandardGen4"]boolValue];
        }
    }

    
    [cell createCellLayoutWithParams:tsEntryObject isProjectAccess:self.isProjectAccess isClientAccess:self.isClientAccess isActivityAccess:self.isActivityAccess isBillingAccess:self.isBillingAccess isTimeoffSickRow:isTimeoffSickRow  upperrightstr:[tsEntryObject timeEntryHoursInDecimalFormat] commentsStr:[tsEntryObject timeEntryComments] commentsImageRequired:commentsImageReq tag:indexPath.row lastUsedTextField:nil  udfArray:[tsEntryObject timeEntryUdfArray] isTimeoff:isTimeoffRow withEditState:isEditState withDelegate:self heightDict:heightDict timeSheetFormat:self.timesheetFormat hasCommentsAccess:hasCommentsAccess hasNegativeTimeEntry:self.allowNegativeTimeEntry];




    [cell setDelegate:self];
    float yOffset=0.0;
    if (!isTimeoffSickRow)
    {
        NSString *timeEntryTaskName=[tsEntryObject timeEntryTaskName];

        if (timeEntryTaskName==nil || [timeEntryTaskName isKindOfClass:[NSNull class]]||[timeEntryTaskName isEqualToString:@""])
        {
            yOffset=EachDayTimeEntry_Cell_Row_Height_50;
        }
        else
        {

            NSString *timeEntryBillingName=[tsEntryObject timeEntryBillingName];
            BOOL isBillingPresent=YES;
            if (timeEntryBillingName==nil || [timeEntryBillingName isKindOfClass:[NSNull class]]||[timeEntryBillingName isEqualToString:@""])
            {
                isBillingPresent=NO;
            }
            NSString *timeEntryActivityName=[tsEntryObject timeEntryActivityName];
            BOOL isActivityPresent=YES;
            if (timeEntryActivityName==nil || [timeEntryActivityName isKindOfClass:[NSNull class]]||[timeEntryActivityName isEqualToString:@""])
            {
                isActivityPresent=NO;
            }
            BOOL isUdfPresent=[self isUdfPresent:tsEntryObject];
            if (isBillingPresent || isActivityPresent || isUdfPresent)
            {
                yOffset=EachDayTimeEntry_Cell_Row_Height_67;
            }
            else
            {
                yOffset=EachDayTimeEntry_Cell_Row_Height_50;
            }

        }



    }
    else
    {
        yOffset=EachDayTimeEntry_Cell_Row_Height_55;
    }



    if ([tsEntryObject.entryType isEqualToString:Time_Off_Key]||
        [standardTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
        [standardTimesheetStatus isEqualToString:APPROVED_STATUS ]||isEditState==NO)
    {
        [cell.upperRight setUserInteractionEnabled:NO];
        //[cell.customTableView setUserInteractionEnabled:NO];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    else
    {
        [cell.upperRight setUserInteractionEnabled:YES];
        //[cell.customTableView setUserInteractionEnabled:YES];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }

    [cell setBackgroundColor:[UIColor whiteColor]];
    [cell.contentView setBackgroundColor:[UIColor whiteColor]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    TimesheetModel *timesheetModel = [[TimesheetModel alloc]init];
    if (![timesheetModel isTimesheetContainsInflightSaveOperation:_sheetIdentity])
    {
        [self handleTapAndResetDayScroll];
        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[self.timesheetEntryObjectArray objectAtIndex:indexPath.row];
        self.selectedIndex = indexPath.row;

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

               /* TimeOffObject *bookedTimeOffObject=[[TimeOffObject alloc] init];
                bookedTimeOffObject.typeName=[tsEntryObject timeEntryTimeOffName];
                bookedTimeOffObject.typeIdentity=[tsEntryObject timeEntryTimeOffUri];

                bookedTimeOffObject.sheetId=[tsEntryObject rowUri];

                BOOL status=NO;;
                TimeOffDetailsViewController *bookedTimeOffEntryController= [[TimeOffDetailsViewController alloc]initWithEntryDetails:bookedTimeOffObject sheetId:[bookedTimeOffObject sheetId] screenMode:EDIT_BOOKTIMEOFF];

                bookedTimeOffEntryController.isStatusView=status;
                bookedTimeOffEntryController.parentDelegate=controllerDelegate;
                bookedTimeOffEntryController.approvalDelegate = self.approvalsDelegate;
                [bookedTimeOffEntryController setSheetIdString:[bookedTimeOffObject sheetId]];
                bookedTimeOffEntryController.navigationFlow = TIMESHEET_PERIOD_NAVIGATION;
                bookedTimeOffEntryController.timesheetURI=[tsEntryObject timesheetUri];
                
                if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
                {
                    TimesheetMainPageController *cntrl=(TimesheetMainPageController*)controllerDelegate;
                    bookedTimeOffEntryController.userUri=cntrl.userUri;
                }
                if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
                {
                    TimesheetMainPageController *cntrl=(TimesheetMainPageController*)controllerDelegate;
                    bookedTimeOffEntryController.startDateTimesheetString=(NSString *)[[cntrl.tsEntryDataArray objectAtIndex:0] entryDate];
                    bookedTimeOffEntryController.endDateTimesheetString=(NSString *)[[cntrl.tsEntryDataArray objectAtIndex:[cntrl.tsEntryDataArray count]-1]entryDate];

                    if ([[cntrl.tsEntryDataArray objectAtIndex:0]userID]!=nil&&![[[cntrl.tsEntryDataArray objectAtIndex:0]userID] isKindOfClass:[NSNull class]]) {
                        cntrl.userUri=[[cntrl.tsEntryDataArray objectAtIndex:0]userID];
                    }

                    if ([controllerDelegate hasUserChangedAnyValue])
                    {
                        [cntrl backAndSaveAction:nil];
                    }

                    [[NSNotificationCenter defaultCenter] removeObserver:self name:PULL_TO_REFRESH_TIMEOFFS_RECEIVED_NOTIFICATION object:nil];
                    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appDelegate performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                    [[NSNotificationCenter defaultCenter] addObserver:bookedTimeOffEntryController selector:@selector(TimeOffDetailsResponse)
                                                                 name:PULL_TO_REFRESH_TIMEOFFS_RECEIVED_NOTIFICATION
                                                               object:nil];
                    [[RepliconServiceManager timesheetService]fetchTimeoffData:nil];

                }
                [self.navigationController pushViewController:bookedTimeOffEntryController animated:YES];*/
                if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
                {
                    [[NSNotificationCenter defaultCenter] removeObserver:self name:PULL_TO_REFRESH_TIMEOFFS_RECEIVED_NOTIFICATION object:nil];
                    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
                    [appDelegate performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeoffDetailsReponse)
                                                                 name:PULL_TO_REFRESH_TIMEOFFS_RECEIVED_NOTIFICATION
                                                               object:nil];
                    [[RepliconServiceManager timesheetService]fetchTimeoffData:nil];
                }
                
                /*
                 [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_ENTRY_RECEIVED_NOTIFICATION object:nil];
                 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TimeOffDetailsReceived) name:TIMEOFF_ENTRY_RECEIVED_NOTIFICATION object:nil];

                 AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                [[RepliconServiceManager timesheetService]fetchTimeoffEntryDataForBookedTimeoff:self.sheetIdString withTimeSheetUri:self.timesheetURI];*/


            }



        }
        else{
            EditEntryViewController *dayEntryEditVC=[[EditEntryViewController alloc]init];
            dayEntryEditVC.sheetApprovalStatus=standardTimesheetStatus;
            dayEntryEditVC.tsEntryObject= [tsEntryObject copy];
            dayEntryEditVC.isProjectAccess=self.isProjectAccess;
            dayEntryEditVC.isActivityAccess=self.isActivityAccess;
            dayEntryEditVC.isBillingAccess=self.isBillingAccess;
            dayEntryEditVC.commentsControlDelegate=self;
            dayEntryEditVC.timesheetFormat=self.timesheetFormat;
            LoginModel *loginModel=[[LoginModel alloc]init];

            NSMutableArray *udfArray=[loginModel getEnabledOnlyUDFsforModuleName:TIMESHEET_ROW_UDF];
            if ([udfArray count]>0)
            {
                dayEntryEditVC.isRowUdf=TRUE;
            }
            else
                dayEntryEditVC.isRowUdf=FALSE;

            BOOL isEditState=YES;
            BOOL projectNotEditable=NO;
            if (![tsEntryObject isRowEditable])
            {
                projectNotEditable=YES;
            }
            if ([standardTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
                [standardTimesheetStatus isEqualToString:APPROVED_STATUS ]||projectNotEditable||[[tsEntryObject entryType] isEqualToString:Time_Off_Key])
            {
                isEditState=NO;
            }
            UIViewController *controllerViewCtrl=(UIViewController *)controllerDelegate;
            //Approval context Flow for timesheets
            AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
            //Approval context Flow for timesheets
            if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [appDelegate.rootTabBarController.selectedViewController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]] || [appDelegate.rootTabBarController.selectedViewController isKindOfClass:[SupervisorDashboardNavigationController class]])
            {
                TimesheetMainPageController *controllerViewCtrl=(TimesheetMainPageController *)controllerDelegate;
                ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)[controllerViewCtrl parentDelegate];
                dayEntryEditVC.approvalsModuleName=scrolllView.approvalsModuleName;
            }
            dayEntryEditVC.isEditState=isEditState;
            dayEntryEditVC.currentPageDate=self.currentPageDate;
            dayEntryEditVC.row=indexPath.row;
            [self.navigationController pushViewController:dayEntryEditVC animated:YES];
        }
        
        [self.timeEntryTableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    else
    {
        [self showINProgressAlertView];
    }

}

-(void)timeoffDetailsReponse{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PULL_TO_REFRESH_TIMEOFFS_RECEIVED_NOTIFICATION object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_ENTRY_RECEIVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeOffLoadDetails) name:TIMEOFF_ENTRY_RECEIVED_NOTIFICATION object:nil];
    
    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[self.timesheetEntryObjectArray objectAtIndex:self.selectedIndex];
    
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
    [[RepliconServiceManager timesheetService]fetchTimeoffEntryDataForBookedTimeoff:tsEntryObject.rowUri withTimeSheetUri:[tsEntryObject timesheetUri]];
}

-(void)timeOffLoadDetails{
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_ENTRY_RECEIVED_NOTIFICATION object:nil];
    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[self.timesheetEntryObjectArray objectAtIndex:self.selectedIndex];
    TimeoffModel *timeoffModel=[[TimeoffModel alloc]init];
    BOOL isMultiDayTimeOff=[timeoffModel isMultiDayTimeOff:tsEntryObject.rowUri];
    if(isMultiDayTimeOff){
        
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        MultiDayTimeOffViewController *multiDayTimeOffViewController = [appDelegate.injector getInstance:InjectorKeyMultiDayTimeOffViewController];
        [multiDayTimeOffViewController setupWithModelType:TimeOffModelTypeTimeOff screenMode:EDIT_BOOKTIMEOFF navigationFlow:TIMESHEET_PERIOD_NAVIGATION delegate:controllerDelegate timeOffUri:tsEntryObject.rowUri timeSheetURI:[tsEntryObject timesheetUri] date:nil];
        [self.navigationController pushViewController:multiDayTimeOffViewController animated:YES];
    }
    else{
        TimeOffObject *bookedTimeOffObject=[[TimeOffObject alloc] init];
        bookedTimeOffObject.typeName=[tsEntryObject timeEntryTimeOffName];
        bookedTimeOffObject.typeIdentity=[tsEntryObject timeEntryTimeOffUri];
        bookedTimeOffObject.sheetId=[tsEntryObject rowUri];
        BOOL status=NO;;
        TimeOffDetailsViewController *bookedTimeOffEntryController= [[TimeOffDetailsViewController alloc]initWithEntryDetails:bookedTimeOffObject sheetId:[bookedTimeOffObject sheetId] screenMode:EDIT_BOOKTIMEOFF];
        
        bookedTimeOffEntryController.isStatusView=status;
        bookedTimeOffEntryController.parentDelegate=controllerDelegate;
        bookedTimeOffEntryController.approvalDelegate = self.approvalsDelegate;
        [bookedTimeOffEntryController setSheetIdString:[bookedTimeOffObject sheetId]];
        bookedTimeOffEntryController.navigationFlow = TIMESHEET_PERIOD_NAVIGATION;
        bookedTimeOffEntryController.timesheetURI=[tsEntryObject timesheetUri];
        if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
        {
            TimesheetMainPageController *cntrl=(TimesheetMainPageController*)controllerDelegate;
            bookedTimeOffEntryController.userUri=cntrl.userUri;
        }
        [bookedTimeOffEntryController TimeOffDetailsReceived];
        [self.navigationController pushViewController:bookedTimeOffEntryController animated:YES];
    }
}



#pragma mark
#pragma mark  Other methods

- (void)calculateHeights {
    [cellHeightsArray removeAllObjects];
    for (TimesheetEntryObject *tsEntryObject in timesheetEntryObjectArray)
    {
        float cellHeight=0.0;
        float verticalOffset=10.0;
        float upperLabelHeight=0.0;
        float middleLabelHeight=0.0;
        float lowerLabelHeight=0.0;
        float billingRateHeight=0.0;
        NSString *upperStr=@"";
        NSString *middleStr=@"";
        NSString *lowerStr=@"";
        BOOL isUpperLabelTextWrap=NO;
        BOOL isMiddleLabelTextWrap=NO;
        BOOL isLowerLabelTextWrap=NO;
        NSMutableDictionary *heightDict=[NSMutableDictionary dictionary];
        BOOL isTimeoffSickRow=[tsEntryObject isTimeoffSickRowPresent];
        if (isTimeoffSickRow)
        {
            
            NSString *timeEntryTimeOffName=[tsEntryObject timeEntryTimeOffName];
            middleStr=timeEntryTimeOffName;
            middleLabelHeight=[self getHeightForString:timeEntryTimeOffName fontSize:RepliconFontSize_16 forWidth:LABEL_WIDTH];
            [heightDict setObject:@"SINGLE" forKey:LINE];
        }
        else
        {
            
            NSString *timeEntryTaskName=[tsEntryObject timeEntryTaskName];
            NSString *timeEntryClientName=[tsEntryObject timeEntryClientName];
            if (isProgramAccess) {
                timeEntryClientName=[tsEntryObject timeEntryProgramName];
            }
            NSString *timeEntryProjectName=[tsEntryObject timeEntryProjectName];
            if (timeEntryTaskName==nil || [timeEntryTaskName isKindOfClass:[NSNull class]]||[timeEntryTaskName isEqualToString:@""])
            {
                
                if (self.isProjectAccess)
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
        
        NSString *tsBillingName = [tsEntryObject timeEntryBillingName];
         NSString *tmpBillingValue=@"";
        if (IsNotEmptyString(tsBillingName))
         {
             tmpBillingValue=[NSString stringWithFormat:@"%@: %@",RPLocalizedString(@"Billing Rate", @""),tsBillingName];
         }
         else
         {
             tmpBillingValue=[NSString stringWithFormat:@"%@: %@",RPLocalizedString(@"Billing Rate", @""),NON_BILLABLE];
         }
        billingRateHeight = [self getHeightForString:tmpBillingValue fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
         if (!isBillingAccess)
         {
             billingRateHeight=0;
             tmpBillingValue=@"";
         }
        
        
        cellHeight=upperLabelHeight+middleLabelHeight+lowerLabelHeight+billingRateHeight+2*verticalOffset+numberOfLabels*5;
        if (cellHeight<EachDayTimeEntry_Cell_Row_Height_55)
        {
            cellHeight=EachDayTimeEntry_Cell_Row_Height_55;
        }
        
        [heightDict setObject:[NSString stringWithFormat:@"%f",upperLabelHeight] forKey:UPPER_LABEL_HEIGHT];
        [heightDict setObject:[NSString stringWithFormat:@"%f",middleLabelHeight] forKey:MIDDLE_LABEL_HEIGHT];
        [heightDict setObject:[NSString stringWithFormat:@"%f",lowerLabelHeight] forKey:LOWER_LABEL_HEIGHT];
        [heightDict setObject:[NSString stringWithFormat:@"%f",billingRateHeight] forKey:BILLING_LABEL_HEIGHT];
        [heightDict setObject:[NSString stringWithFormat:@"%@",upperStr] forKey:UPPER_LABEL_STRING];
        [heightDict setObject:[NSString stringWithFormat:@"%@",middleStr] forKey:MIDDLE_LABEL_STRING];
        [heightDict setObject:[NSString stringWithFormat:@"%@",lowerStr] forKey:LOWER_LABEL_STRING];
        [heightDict setObject:[NSString stringWithFormat:@"%d",isUpperLabelTextWrap] forKey:UPPER_LABEL_TEXT_WRAP];
        [heightDict setObject:[NSString stringWithFormat:@"%d",isMiddleLabelTextWrap] forKey:MIDDLE_LABEL_TEXT_WRAP];
        [heightDict setObject:[NSString stringWithFormat:@"%d",isLowerLabelTextWrap] forKey:LOWER_LABEL_TEXT_WRAP];
        [heightDict setObject:[NSString stringWithFormat:@"%f",cellHeight] forKey:CELL_HEIGHT_KEY];
        [heightDict setObject:tmpBillingValue forKey:BILLING_RATE];
        
        [cellHeightsArray addObject:heightDict];
        
    }
}


- (void)resetTableSize:(BOOL)isResetTable {
    CGFloat inset = isResetTable ? 168.0f + Done_Toolbar_Height : 0.0f;
    self.timeEntryTableView.contentInset = UIEdgeInsetsMake(0, 0, inset, 0);
}
//JUHI
-(void)createToolBar
{
    if (toolbar == nil)
    {
        self.toolbar = [UIToolbar new];
        [self.toolbar sizeToFit];
        self.toolbar.barTintColor = [Util colorWithHex:@"#EEEEEE" alpha:1.0f];
        self.toolbar.translucent = NO;
        self.toolbar.accessibilityLabel = @"standard_timesheet_toolbar_label";

        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(@"Done", @"")
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(doneAction: withSender:)];
        doneButton.accessibilityLabel = @"standard_timesheet_done_button_label";
        doneButton.tintColor = [UIColor blackColor];

        UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                     target:nil
                                                                                     action:nil];

        self.toolbar.items = [NSArray arrayWithObjects:spaceButton, doneButton, nil];
    }
}
-(void)doneAction:(BOOL)shouldTextColorChangeToWhite withSender:(id)sender
{

    [self.toolbar setHidden:YES];
    [timeEntryTableView setScrollEnabled:YES];
    self.isTextFieldClicked=NO;
    self.isUDFieldClicked=NO;
    [self resetTableSize:NO];

    if (lastUsedTextView)
    {
        [lastUsedTextView resignFirstResponder];
    }
    if (self.lastUsedTextField)
    {
        [self.lastUsedTextField resignFirstResponder];
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
//    appdelegate.rootTabBarController.tabBar.hidden=FALSE;
    [self calculateAndUpdateTotalHoursValueForFooter];
    if (self.currentIndexpath!=nil && sender!=nil)
    {
        [self.timeEntryTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.currentIndexpath] withRowAnimation:UITableViewRowAnimationNone];
    }


}


-(void)doneAction:(BOOL)shouldTextColorChangeToWhite sender:(id)sender
{



    [self.toolbar setHidden:YES];
    [self.timeEntryTableView setScrollEnabled:YES];
    if (sender!=nil)
    {
        self.isTextFieldClicked=NO;
        self.isUDFieldClicked=NO;
        [self resetTableSize:NO];

    }

    if (lastUsedTextView)
    {
        [lastUsedTextView resignFirstResponder];
    }
    if (self.lastUsedTextField)
    {
        [self.lastUsedTextField resignFirstResponder];
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

}


-(void)calculateAndUpdateTotalHoursValueForFooter
{
    float totalCalculatedHours=0;
    TimesheetMainPageController *ctr=(TimesheetMainPageController *)controllerDelegate;
    NSMutableArray *timesheetEntryObjectArr=[[ctr timesheetDataArray] objectAtIndex:ctr.pageControl.currentPage];
    for (int i=0; i<[timesheetEntryObjectArr count]; i++)
    {
        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArr objectAtIndex:i];

        float timeEntryHours=[[tsEntryObject timeEntryHoursInDecimalFormat] newFloatValue];
        totalCalculatedHours=totalCalculatedHours+timeEntryHours;
    }
    [self.timeEntryTableView setTableFooterView:nil];

    NSString *totalHoursString=[NSString stringWithFormat:@"%f",totalCalculatedHours];
    [self.totalLabelHoursLbl setText:[Util getRoundedValueFromDecimalPlaces:[totalHoursString newDoubleValue]withDecimalPlaces:2]];

	UIImage *separatorImage = [Util thumbnailImage:Cell_HairLine_Image];
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,0, self.view.width,1)];
    [lineImageView setImage:separatorImage];
    [self.timeEntryTableView setTableFooterView:lineImageView];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    for (UIGestureRecognizer *recognizer in self.timeEntryTableView.tableHeaderView.gestureRecognizers)
    {
        [self.timeEntryTableView.tableHeaderView removeGestureRecognizer:recognizer];
    }
    [self.timeEntryTableView.tableHeaderView addGestureRecognizer:tap];


    BOOL hoursPresent=NO;
    
    if(self.timesheetFormat!=nil && self.timesheetFormat!=(id)[NSNull null])
    {
        if([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
        {
            if ([totalHoursString newFloatValue]>0 ||[totalHoursString newFloatValue]< 0)
            {
                hoursPresent=YES;
            }
        }
        else
        {
            if ([totalHoursString newFloatValue]>0.0f || [totalHoursString newFloatValue]<0.0f)
            {
                hoursPresent=YES;
            }
        }
    }
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;
        [tsMainPageCtrl checkAndupdateCurrentButtonFilledStatus:hoursPresent andPageSelected:tsMainPageCtrl.pageControl.currentPage];
    }


}




-(void)changeParentViewLeftBarbutton
{
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;
        UIBarButtonItem *tempLeftButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(SAVE_STRING,@"")
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:tsMainPageCtrl action:@selector(backAndSaveAction:)];

        [tempLeftButtonOuterBtn setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:RepliconFontFamilyRegular size:17.0f]}
                                              forState:UIControlStateNormal];
        [tempLeftButtonOuterBtn setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:RepliconFontFamilyRegular size:17.0f]}
                                              forState:UIControlStateHighlighted];

        [tempLeftButtonOuterBtn setAccessibilityLabel:@"save_time_dist_btn"];
        [tsMainPageCtrl.navigationItem setLeftBarButtonItem:tempLeftButtonOuterBtn animated:NO];


    }


}
-(void)handleTapAndResetDayScroll
{
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;
        [tsMainPageCtrl resetDayScrollViewPosition];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{

    [self handleTapAndResetDayScroll];
}
-(void) didTapOnTableView:(UIGestureRecognizer*) recognizer
{
    [self handleTapAndResetDayScroll];
}

-(BOOL)isUdfPresent:(TimesheetEntryObject *)tsEntryObject
{
    NSUInteger numberOfUDF=0;

    if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
    {
        if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
        {
            numberOfUDF=[[tsEntryObject timeEntryCellOEFArray] count];
        }
        else
        {
            numberOfUDF=[[tsEntryObject timeEntryUdfArray] count];
        }

    }


    BOOL isUdfPresent=NO;
    for (int i=0; i<numberOfUDF; i++)
    {
        if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
        {
            if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
            {
                OEFObject *oefObject=[[tsEntryObject timeEntryCellOEFArray]  objectAtIndex:i];
                NSString *oefValue=nil;
                if (oefObject.oefNumericValue!=nil && ![oefObject.oefNumericValue isKindOfClass:[NSNull class]])
                {
                    oefValue=[oefObject oefNumericValue];
                }
                else if (oefObject.oefTextValue!=nil && ![oefObject.oefTextValue isKindOfClass:[NSNull class]])
                {
                    oefValue=[oefObject oefTextValue];
                }
                else if (oefObject.oefDropdownOptionValue!=nil && ![oefObject.oefDropdownOptionValue isKindOfClass:[NSNull class]])
                {
                    oefValue=[oefObject oefDropdownOptionValue];
                }

                if (oefValue!=nil && ![oefValue isEqualToString:RPLocalizedString(ADD_STRING, @"")] &&
                    ![oefValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]&&
                    ![oefValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
                {
                    isUdfPresent=YES;
                }
            }
            else
            {
                EntryCellDetails *cellDetails=[[tsEntryObject timeEntryUdfArray] objectAtIndex:i];
                NSString *udfValue=[cellDetails fieldValue];
                NSString *udfsystemDefaultValue=[cellDetails systemDefaultValue];
                if (udfValue!=nil && ![udfValue isEqualToString:RPLocalizedString(ADD_STRING, @"")] &&
                    ![udfValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]&&
                    ![udfValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
                {
                    isUdfPresent=YES;
                }
                else
                {
                    if (udfsystemDefaultValue!=nil && ![udfsystemDefaultValue isKindOfClass:[NSNull class]]&&
                        ![udfsystemDefaultValue isEqualToString:@""]&&
                        ![udfsystemDefaultValue isEqualToString:NULL_STRING]&&
                        ![udfsystemDefaultValue isEqualToString:NULL_OBJECT_STRING])
                    {
                        isUdfPresent=YES;
                    }
                }
            }
        }



    }

    return isUdfPresent;
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

//UPDATE: if This method is only for truncating the text we can remove this method, beacause label will automatically truncates the text

-(NSString *)getTheAttributedTextForEntryObject:(TimesheetEntryObject *)tsEntryObject
{

    NSUInteger numberOfUDF=0;
    if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
    {
        if([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
        {
            numberOfUDF=[[tsEntryObject timeEntryRowOEFArray] count];
        }
        else
        {
            numberOfUDF=[[tsEntryObject timeEntryRowUdfArray] count];
        }
    }


    NSMutableArray *array=[NSMutableArray array];
    NSString *tsActivityName=[tsEntryObject timeEntryActivityName];

    if (isActivityAccess)
    {
        if (tsActivityName!=nil && ![tsActivityName isKindOfClass:[NSNull class]]&& ![tsActivityName isEqualToString:@""])
        {
            NSMutableDictionary *activityDict=[NSMutableDictionary dictionaryWithObject:tsActivityName forKey:@"ACTIVITY"];
            [array addObject:activityDict];

        }
    }

    for (int i=0; i<numberOfUDF; i++)
    {

         NSString *udfValue=nil;

        if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
        {
            if([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
            {
                OEFObject *oefObject=[[tsEntryObject timeEntryRowOEFArray] objectAtIndex:i];
                if (oefObject.oefNumericValue!=nil && ![oefObject.oefNumericValue isKindOfClass:[NSNull class]])
                {
                    udfValue=[oefObject oefNumericValue];
                }
                else if (oefObject.oefTextValue!=nil && ![oefObject.oefTextValue isKindOfClass:[NSNull class]])
                {
                    udfValue=[oefObject oefTextValue];
                }
                else if (oefObject.oefDropdownOptionValue!=nil && ![oefObject.oefDropdownOptionValue isKindOfClass:[NSNull class]])
                {
                    udfValue=[oefObject oefDropdownOptionValue];
                }

                if (udfValue!=nil && ![udfValue isEqualToString:RPLocalizedString(ADD_STRING, @"")] &&
                    ![udfValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]&&
                    ![udfValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
                {
                    NSMutableDictionary *udfDict=[NSMutableDictionary dictionaryWithObject:udfValue forKey:@"UDF"];
                    [array addObject:udfDict];
                }
            }
            else
            {
                EntryCellDetails *cellDetails=[[tsEntryObject timeEntryRowUdfArray] objectAtIndex:i];
                if ([[cellDetails fieldValue] isKindOfClass:[NSDate class]])
                {
                    udfValue= [Util convertDateToString:[cellDetails fieldValue]];
                }
                else
                    udfValue=[cellDetails fieldValue];
                NSString *udfsystemDefaultValue=[cellDetails systemDefaultValue];
                if (udfValue!=nil && ![udfValue isEqualToString:RPLocalizedString(ADD_STRING, @"")] &&
                    ![udfValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]&&
                    ![udfValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
                {
                    NSMutableDictionary *udfDict=[NSMutableDictionary dictionaryWithObject:udfValue forKey:@"UDF"];
                    [array addObject:udfDict];
                }
                else
                {
                    if (udfsystemDefaultValue!=nil && ![udfsystemDefaultValue isKindOfClass:[NSNull class]]&&
                        ![udfsystemDefaultValue isEqualToString:@""]&&
                        ![udfsystemDefaultValue isEqualToString:NULL_STRING]&&
                        ![udfsystemDefaultValue isEqualToString:NULL_OBJECT_STRING])
                    {
                        NSMutableDictionary *udfDict=[NSMutableDictionary dictionaryWithObject:udfsystemDefaultValue forKey:@"UDF"];
                        [array addObject:udfDict];
                    }
                }
            }
        }



    }



    float labelWidth=LABEL_WIDTH;
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
                [arrayFinal addObject:valueStr];
            }
            else
            {
                if ([key isEqualToString:@"ACTIVITY"])
                {
                    valueStr=[Util stringByTruncatingToWidth:labelWidth withFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12] ForString:valueStr addQuotes:YES];
                    [arrayFinal addObject:valueStr];
                }
                else
                {
                    sizeExceedingCount++;
                }

            }


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
                tempfinalString=[tempfinalString stringByAppendingString:[NSString stringWithFormat:@"%@ | +%d",str,sizeExceedingCount]];
                CGSize stringSize = [tempfinalString sizeWithAttributes:
                                     @{NSFontAttributeName:
                                           [UIFont systemFontOfSize:RepliconFontSize_12]}];
                CGFloat width = stringSize.width;
                if (width<labelWidth)
                {
                    finalString=[finalString stringByAppendingString:[NSString stringWithFormat:@"%@ | +%d",str,sizeExceedingCount]];
                }
                else
                {
                    finalString=[NSString stringWithFormat:@"%@ +%d",finalString,sizeExceedingCount+1];

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
            tempfinalString=[finalString stringByAppendingString:[NSString stringWithFormat:@"%@ | ",str]];
            finalString=[finalString stringByAppendingString:[NSString stringWithFormat:@"%@ | ",str]];


        }

    }
    //Implementation forMobi-181//JUHI
    if ([finalString isEqualToString:@""])
    {
        finalString=RPLocalizedString(NO_SELECTION, @"");
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
    CGSize mainSize = [attributedString boundingRectWithSize:CGSizeMake(width, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

    if (mainSize.width==0 && mainSize.height ==0)
    {
        mainSize=CGSizeMake(0,0);
    }

    float version= [[UIDevice currentDevice].systemVersion newFloatValue];
    if (version>=7.0)
    {
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
    }

    return mainSize.height;
}



-(void) deleteEntryforRow:(NSInteger)row withDelegate:(id)delegate
{
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {

        TimesheetMainPageController *ctrl=(TimesheetMainPageController *)controllerDelegate;
        NSUInteger count=[ctrl.timesheetDataArray count];
        for (int i=0; i<count; i++)
        {
            NSMutableArray *tsEntryObjectsArray=[NSMutableArray arrayWithArray:[ctrl.timesheetDataArray objectAtIndex:i]];
            TimesheetEntryObject *tsEntryObj = [tsEntryObjectsArray objectAtIndex:row];
            if([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET] && !tsEntryObj.hasTimeEntryValue){
                [self.timesheetModel deleteEmptyTimeEntryValue:tsEntryObj withTimesheetFormat:self.timesheetFormat];
            }

            [tsEntryObjectsArray removeObjectAtIndex:row];
            [ctrl.timesheetDataArray replaceObjectAtIndex:i withObject:tsEntryObjectsArray];
        }
        [ctrl setHasUserChangedAnyValue:YES];
        [self calculateAndUpdateTotalHoursValueForDeleteAction];
        [ctrl reloadViewWithRefreshedDataAfterSave];
    }
}

-(void)showINProgressAlertView
{

    self.syncInProgressAlertView = [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                   otherButtonTitle:nil
                                           delegate:self
                                            message:RPLocalizedString(saveInProgressText, @"")
                                              title:RPLocalizedString(saveInProgressTitle, @"")
                                                tag:LONG_MIN];
}

#pragma mark
#pragma mark  Update methods
-(void)updateTimeEntryHoursForIndex:(NSInteger)index withValue:(NSString *)value isDoneClicked:(BOOL)isDoneClicked
{
    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:index];
    NSString *clientName=tsEntryObject.timeEntryClientName;
    NSString *clientUri=tsEntryObject.timeEntryClientUri;
    //MOBI-746
    NSString *programName=tsEntryObject.timeEntryProgramName;
    NSString *programUri=tsEntryObject.timeEntryProgramUri;
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

    NSMutableDictionary *multiInoutEntry=tsEntryObject.multiDayInOutEntry;
    NSString *punchUri=tsEntryObject.timePunchUri;
    NSString *allocationUri=tsEntryObject.timeAllocationUri;
    NSString *entryType=tsEntryObject.entryType;
    NSDate *entryDate=tsEntryObject.timeEntryDate;
    BOOL isTimeoffSickRowPresent=tsEntryObject.isTimeoffSickRowPresent;
    NSString *timesheetUri=tsEntryObject.timesheetUri;
    NSString *rowUri=tsEntryObject.rowUri;
    BOOL isRowEditable=tsEntryObject.isRowEditable;
    BOOL isNewlyAddedAdhocRow=tsEntryObject.isNewlyAddedAdhocRow;
    NSString *rowNumber=tsEntryObject.rownumber;
    BOOL isRowTimeEntered = tsEntryObject.hasTimeEntryValue;
    if (value!=nil && ![value isKindOfClass:[NSNull class]])
    {
        if (self.timesheetFormat!=nil && self.timesheetFormat!=(id)[NSNull null])
        {
            if(![value isEqualToString:@""] && [self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
            {
                isRowTimeEntered = YES;
            }
            else
            {
                isRowTimeEntered = NO;
            }
        }
        value=[Util getRoundedValueFromDecimalPlaces:[value newDoubleValue] withDecimalPlaces:2];
    }

    if (isDoneClicked)
    {
        if ([value isEqualToString:@""]||[value isKindOfClass:[NSNull class]]) {
            
            
            if (self.timesheetFormat!=nil && self.timesheetFormat!=(id)[NSNull null])
            {
                if(![self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                {
                    value=[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]];
                }
            }
            
        }
        DayTimeEntryCustomCell *cell = (DayTimeEntryCustomCell *)[self.timeEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [cell.upperRight setText:value];

    }
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        BOOL hasTimeEntryValue = NO;

        hasTimeEntryValue = tsEntryObject.hasTimeEntryValue;

        if (self.timesheetFormat!=nil && self.timesheetFormat!=(id)[NSNull null])
        {
            if([self.timesheetFormat isEqualToString:STANDARD_TIMESHEET])
            {
                // MI-1962 GEN3 STANDARD TIMESHEET WILL ALWAYS HAVE THIS FLAG AS YES
                hasTimeEntryValue = YES;
            }
        }

        TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;
        if (![value isEqualToString:[tsEntryObject timeEntryHoursInDecimalFormat]] || !hasTimeEntryValue)
        {
            tsMainPageCtrl.hasUserChangedAnyValue=YES;
            [self changeParentViewLeftBarbutton];
        }

    }
    TimesheetEntryObject *tsTempEntryObject=[[TimesheetEntryObject alloc] init];
    //MOBI-746
    [tsTempEntryObject setTimeEntryProgramName:programName];
    [tsTempEntryObject setTimeEntryProgramUri:programUri];
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
    [tsTempEntryObject setTimeEntryHoursInHourFormat:hoursInHourFormat];
    [tsTempEntryObject setTimeEntryComments:comments];

    [tsTempEntryObject setMultiDayInOutEntry:multiInoutEntry];
    [tsTempEntryObject setTimePunchUri:punchUri];
    [tsTempEntryObject setTimeAllocationUri:allocationUri];
    [tsTempEntryObject setEntryType:entryType];
    [tsTempEntryObject setTimeEntryDate:entryDate];
    [tsTempEntryObject setIsTimeoffSickRowPresent:isTimeoffSickRowPresent];
    [tsTempEntryObject setTimesheetUri:timesheetUri];
    [tsTempEntryObject setRowUri:rowUri];
    [tsTempEntryObject setIsRowEditable:isRowEditable];
    [tsTempEntryObject setIsNewlyAddedAdhocRow:isNewlyAddedAdhocRow];
    [tsTempEntryObject setHasTimeEntryValue:isRowTimeEntered];
    if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
    {
        if([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
        {
            [tsTempEntryObject setTimeEntryCellOEFArray:tsEntryObject.timeEntryCellOEFArray];
            [tsTempEntryObject setTimeEntryRowOEFArray:tsEntryObject.timeEntryRowOEFArray];
            if (isRowTimeEntered) {
                [self.timesheetModel updateEmptyTimeEntryValueWithEnteredTime:tsTempEntryObject timesheetFormat:self.timesheetFormat];
            }
        }
        else
        {
            [tsTempEntryObject setTimeEntryUdfArray:tsEntryObject.timeEntryUdfArray];
            [tsTempEntryObject setTimeEntryRowUdfArray:tsEntryObject.timeEntryRowUdfArray];
        }
    }

    [tsTempEntryObject setRownumber:rowNumber];
    [self.timesheetEntryObjectArray replaceObjectAtIndex:index withObject:tsTempEntryObject];
    [self calculateAndUpdateTotalHoursValueForFooter];

}
-(void)updateProjectName:(NSString *)_projectName withProjectUri:(NSString *)_projectUri withTaskName:(NSString *)_taskName
             withTaskUri:(NSString *)_taskUri withActivityName:(NSString *)_activityName withActivityUri:(NSString *)_activityUri withBillingName:(NSString *)_billingName withBillingUri:(NSString *)_billingUri
{
    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:currentIndexpath.row];
    NSString *clientName=tsEntryObject.timeEntryClientName;
    NSString *clientUri=tsEntryObject.timeEntryClientUri;
    //MOBI-746
    NSString *programName=tsEntryObject.timeEntryProgramName;
    NSString *programUri=tsEntryObject.timeEntryProgramUri;
    NSString *comments=tsEntryObject.timeEntryComments;
    NSString *timeOffName=tsEntryObject.timeEntryTimeOffName;
    NSString *timeOffUri=tsEntryObject.timeEntryTimeOffUri;
    NSString *hoursInHourFormat=tsEntryObject.timeEntryHoursInHourFormat;
    NSString *hoursInDecimalFormat=tsEntryObject.timeEntryHoursInDecimalFormat;

    NSMutableDictionary *multiInoutEntry=tsEntryObject.multiDayInOutEntry;
    NSString *punchUri=tsEntryObject.timePunchUri;
    NSString *allocationUri=tsEntryObject.timeAllocationUri;
    NSDate *entryDate=tsEntryObject.timeEntryDate;
    NSString *entryType=tsEntryObject.entryType;
    BOOL isTimeoffSickRowPresent=tsEntryObject.isTimeoffSickRowPresent;
    NSString *timesheetUri=tsEntryObject.timesheetUri;
    NSString *rowUri=tsEntryObject.rowUri;
    BOOL isRowEditable=tsEntryObject.isRowEditable;
    NSString *rowNumber=tsEntryObject.rownumber;
    BOOL hasTimeEntry = tsEntryObject.hasTimeEntryValue;
    TimesheetEntryObject *tsTempEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:currentIndexpath.row];
    //MOBI-746
    [tsTempEntryObject setTimeEntryProgramName:programName];
    [tsTempEntryObject setTimeEntryProgramUri:programUri];
    [tsTempEntryObject setTimeEntryClientName:clientName];
    [tsTempEntryObject setTimeEntryClientUri:clientUri];
    [tsTempEntryObject setTimeEntryProjectName:_projectName];
    [tsTempEntryObject setTimeEntryProjectUri:_projectUri];
    [tsTempEntryObject setTimeEntryTaskName:_taskName];
    [tsTempEntryObject setTimeEntryTaskUri:_taskUri];
    [tsTempEntryObject setTimeEntryBillingName:_billingName];
    [tsTempEntryObject setTimeEntryBillingUri:_billingUri];
    [tsTempEntryObject setTimeEntryActivityName:_activityName];
    [tsTempEntryObject setTimeEntryActivityUri:_activityUri];
    [tsTempEntryObject setTimeEntryTimeOffName:timeOffName];
    [tsTempEntryObject setTimeEntryTimeOffUri:timeOffUri];
    [tsTempEntryObject setTimeEntryHoursInDecimalFormat:hoursInDecimalFormat];
    [tsTempEntryObject setTimeEntryHoursInHourFormat:hoursInHourFormat];
    [tsTempEntryObject setTimeEntryComments:comments];

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
    if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
    {
        if([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
        {
            [tsTempEntryObject setTimeEntryCellOEFArray:tsEntryObject.timeEntryCellOEFArray];
            [tsTempEntryObject setTimeEntryRowOEFArray:tsEntryObject.timeEntryRowOEFArray];
        }
        else
        {
            [tsTempEntryObject setTimeEntryUdfArray:tsEntryObject.timeEntryUdfArray];
            [tsTempEntryObject setTimeEntryRowUdfArray:tsEntryObject.timeEntryRowUdfArray];
        }
    }

    [tsTempEntryObject setRownumber:rowNumber];
    [self.timesheetEntryObjectArray replaceObjectAtIndex:currentIndexpath.row withObject:tsTempEntryObject];
    DayTimeEntryCustomCell *cell = (DayTimeEntryCustomCell *)[self.timeEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:currentIndexpath.row inSection:0]];
    [cell.upperLeft setText:_projectName];
    [cell.lowerLeft setText:_taskName];
}
-(void)updateComments:(NSString *)commentsStr andUdfArray:(NSMutableArray *)entryUdfArray forRow:(NSInteger)row
{
    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArray objectAtIndex:row];
    if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;

        tsMainPageCtrl.hasUserChangedAnyValue=YES;
        [self changeParentViewLeftBarbutton];


        NSString *clientName=tsEntryObject.timeEntryClientName;
        NSString *clientUri=tsEntryObject.timeEntryClientUri;
        //MOBI-746
        NSString *programName=tsEntryObject.timeEntryProgramName;
        NSString *programUri=tsEntryObject.timeEntryProgramUri;
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
        NSString *rowNumber=tsEntryObject.rownumber;
        BOOL hasTimeEntered = tsEntryObject.hasTimeEntryValue;
        TimesheetEntryObject *tsTempEntryObject=[[TimesheetEntryObject alloc]init];
        //MOBI-746
        [tsTempEntryObject setTimeEntryProgramName:programName];
        [tsTempEntryObject setTimeEntryProgramUri:programUri];
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

        [tsTempEntryObject setMultiDayInOutEntry:multiInoutEntry];
        [tsTempEntryObject setTimePunchUri:punchUri];
        [tsTempEntryObject setTimeAllocationUri:allocationUri];
        [tsTempEntryObject setEntryType:entryType];
        [tsTempEntryObject setTimeEntryDate:entryDate];
        [tsTempEntryObject setIsTimeoffSickRowPresent:isTimeoffSickRowPresent];
        [tsTempEntryObject setTimesheetUri:timesheetUri];
        [tsTempEntryObject setRowUri:rowUri];
        [tsTempEntryObject setIsRowEditable:isRowEditable];
        [tsTempEntryObject setHasTimeEntryValue:hasTimeEntered];
        if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
        {
            if([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
            {
                [tsTempEntryObject setTimeEntryCellOEFArray:entryUdfArray];
                [tsTempEntryObject setTimeEntryRowOEFArray:tsEntryObject.timeEntryRowOEFArray];
            }
            else
            {
                [tsTempEntryObject setTimeEntryUdfArray:entryUdfArray];
                [tsTempEntryObject setTimeEntryRowUdfArray:tsEntryObject.timeEntryRowUdfArray];
            }
        }


        [tsTempEntryObject setRownumber:rowNumber];
        if ([entryType isEqualToString:Adhoc_Time_OffKey])
        {
            [self.timesheetEntryObjectArray replaceObjectAtIndex:row withObject:tsTempEntryObject];
            if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
            {
                [controllerDelegate updateAdhocTimeoffUdfValuesAcrossEntireTimesheet:currentIndexpath.row withUdfArray:entryUdfArray];
            }

        }
        else
        {
            [self.timesheetEntryObjectArray replaceObjectAtIndex:row withObject:tsTempEntryObject];
        }

        [cellHeightsArray removeAllObjects];
        [self.timeEntryTableView reloadData];

    }



}

-(void)calculateAndUpdateTotalHoursValueForDeleteAction
{
    
    TimesheetMainPageController *ctr=(TimesheetMainPageController *)controllerDelegate;
    
    for (int k=0; k<ctr.pageControl.numberOfPages; k++)
    {
        float totalCalculatedHours=0;
        NSMutableArray *timesheetEntryObjectArr=[[ctr timesheetDataArray] objectAtIndex:k];
        for (int i=0; i<[timesheetEntryObjectArr count]; i++)
        {
            TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[timesheetEntryObjectArr objectAtIndex:i];
            
            float timeEntryHours=[[tsEntryObject timeEntryHoursInDecimalFormat] newFloatValue];
            totalCalculatedHours=totalCalculatedHours+timeEntryHours;
        }
        NSString *totalHoursString=[NSString stringWithFormat:@"%f",totalCalculatedHours];
        BOOL hoursPresent=NO;
        if ([totalHoursString newFloatValue]>0.0f)
        {
            hoursPresent=YES;
        }
        if ([controllerDelegate isKindOfClass:[TimesheetMainPageController class]])
        {
            TimesheetMainPageController *tsMainPageCtrl=(TimesheetMainPageController *)controllerDelegate;
            [tsMainPageCtrl checkAndupdateCurrentButtonFilledStatus:hoursPresent andPageSelected:(NSInteger) k];
        }

    }
    
    
    
}

#pragma mark
#pragma mark  Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

-(void)dealloc
{
    self.timeEntryTableView.delegate = nil;
    self.timeEntryTableView.dataSource = nil;
}
@end
