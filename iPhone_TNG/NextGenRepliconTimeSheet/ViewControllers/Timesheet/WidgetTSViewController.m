//
//  WidgetTSViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 24/08/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "WidgetTSViewController.h"
#import "ApprovalsScrollViewController.h"
#import "TimesheetValidationViewController.h"
#import "WidgetNoticeCell.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "NSString+Double_Float.h"
#import "NSNumber+Double_Float.h"
#import "TimesheetSyncOperationManager.h"
#import "ResponseHandler.h"
#import "ListOfTimeSheetsViewController.h"
#import "EntryCellDetails.h"
#import "WidgetAttestationCell.h"
#import "PayrollSummaryWidgetCell.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "InjectorKeys.h"
#import "ErrorBannerViewParentPresenterHelper.h"
#import <repliconkit/repliconkit.h>
#import "UIView+Additions.h"

@interface WidgetTSViewController ()

@property (nonatomic, assign) BOOL isAttestationSelected;
@property (nonatomic, assign) BOOL hasAttestationPermission;
@property (nonatomic) NSTimer *refreshButtonCheckTimer;
@end

#define ERRORS_AND_WARNINGS_WIDGET @"ERRORS_AND_WARNINGS_WIDGET"
#define TIMESHEET_STATUS_WIDGET @"TIMESHEET_STATUS_WIDGET"
#define IN_OUT_TIMESHEET_WIDGET @"IN_OUT_TIMESHEET_WIDGET"
#define EXT_IN_OUT_TIMESHEET_WIDGET @"EXT_IN_OUT_TIMESHEET_WIDGET"
#define STANDARD_TIMESHEET_WIDGET @"STANDARD_TIMESHEET_WIDGET"
#define TIME_PUNCHES_WIDGET @"TIME_PUNCHES_WIDGET"
#define TIME_SHEET_WIDGET @"TIME_SHEET_WIDGET"
#define TIME_ENTRIES_WIDGET @"SUBMIT_BUTTON_WIDGET"
#define EXPENSES_WIDGET @"SUBMIT_BUTTON_WIDGET"
#define TIME_OFF_WIDGET @"TIME_OFF_WIDGET"
#define SHEET_UDF_WIDGET @"SHEET_UDF_WIDGET"
#define CHANGE_HISTORY_WIDGET @"CHANGE_HISTORY_WIDGET"
#define ADD_COMMENTS_APPROVE_REJECT_WIDGET @"ADD_COMMENTS_APPROVE_REJECT_WIDGET"
#define ATTESTATION_WIDGET @"ATTESTATION_WIDGET"
#define SUBMIT_BUTTON_WIDGET @"SUBMIT_BUTTON_WIDGET"
#define PAYROLL_SUMMARY_WIDGET @"PAYROLL_SUMMARY_WIDGET"
#define DAILY_FIELD_WIDGET @"DAILY_FIELD_WIDGET"


#define PADDING_FOR_EACH_WIDGET 20
#define TIMESHEET_STATUS_WIDGET_HEIGHT 34
#define CHANGE_HISTORY_WIDGET_HEIGHT 44
#define IN_OUT_WIDGET_LOADED_HEIGHT 110
#define IN_OUT_WIDGET_LOADED_WITHOUT_BREAK_HEIGHT 80
#define IN_OUT_WIDGET_NOT_LOADED_HEIGHT 50

#define IN_OUT_WIDGET_LOADED_HEIGHT_WITH_BREAK_AND_TIMEOFF 140
#define IN_OUT_WIDGET_LOADED_HEIGHT_WITH_BREAK_OR_TIMEOFF 110
#define IN_OUT_WIDGET_LOADED_HEIGHT_WITHOUT_BREAK_AND_TIMEOFF 80

#define APPROVE_REJECT_COMMENTS_LOADED_WIDGET_HEIGHT 44
#define APPROVE_REJECT_COMMENTS_NOT_LOADED_WIDGET_HEIGHT 220
#define buttonSpace 30
#define HeightOfNoTOMsgLabel 80
#define Each_Cell_Row_Height_44 44
#define ResetHeightios4 115-64.0
#define ResetHeightios5 170-64.0



@implementation WidgetTSViewController
@synthesize timesheetMainPageController;
@synthesize userWidgetsArray;
@synthesize selectedSheet;
@synthesize sheetApprovalStatus;
@synthesize sheetIdentity;
@synthesize dueDate;
@synthesize widgetTableView;
@synthesize timesheetModel;
@synthesize timesheetStartDate;
@synthesize timesheetEndDate;
@synthesize approvalsModuleName;
@synthesize parentDelegate;
@synthesize activityView;
@synthesize footerView;
@synthesize actionType;
@synthesize isCurrentTimesheetPeriod;
@synthesize userName;
@synthesize sheetPeriod;
@synthesize currentNumberOfView;
@synthesize totalNumberOfView;
@synthesize currentViewTag;
@synthesize userUri;
@synthesize approvalsModel;
@synthesize errorAndWarningsArray;
@synthesize approverComments;
@synthesize customFieldArray;
@synthesize isBreakPermissionEnabled;
@synthesize hasBreakAccessForPunch;




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:RepliconStandardBackgroundColor];
    [Util setToolbarLabel: self withText: selectedSheet];

    self.approvalsModel=[[ApprovalsModel alloc]init];
    self.timesheetModel=[[TimesheetModel alloc]init];
    [self refreshView];
    
     /* THIS IS MOVED OUT OF SCOPE FOR CURRENT REQUIREMENT
    
    if (![parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
    {
        [self callServiceWithName:TIMESHEET_SUMMARY_BACKGROUND_FETCH_SERVICE];
    }
    
    */
}


-(void)refreshView
{
    NSMutableArray *enabledWidgetsUriArray=[NSMutableArray array];
    if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
    {
        enabledWidgetsUriArray=[timesheetModel getAllEnabledWidgetsUriDetailsFromDBForTimesheetUri:sheetIdentity];
    }
    else
    {
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            enabledWidgetsUriArray=[approvalsModel getAllPendingEnabledWidgetsUriDetailsFromDBForTimesheetUri:sheetIdentity];
        }
        else
        {
            enabledWidgetsUriArray=[approvalsModel getAllPreviousEnabledWidgetsUriDetailsFromDBForTimesheetUri:sheetIdentity];
        }
    }

    BOOL isStandardWidget=NO;
    BOOL isInOutWidget=NO;
    BOOL isExtInOutWidget=NO;
    BOOL timePunchWidget = NO;
    
    for(NSDictionary *enabledWidgetDict in enabledWidgetsUriArray)
    {
        NSString *widgetUri=enabledWidgetDict[@"widgetUri"];
        if ([widgetUri isEqualToString:STANDARD_WIDGET_URI])
        {
            isStandardWidget=YES;
        }
        else if ([widgetUri isEqualToString:INOUT_WIDGET_URI])
        {
            isInOutWidget=YES;
        }
        else if ([widgetUri isEqualToString:EXT_INOUT_WIDGET_URI])
        {
            isExtInOutWidget=YES;
        }
        else if ([widgetUri isEqualToString:PUNCH_WIDGET_URI])
        {
            timePunchWidget=YES;
        }
    }
    
    
    if ([enabledWidgetsUriArray count] == 0)
    {
        [self showTimesheetFormatNotSupported:TIMESHEET_FORMAT_NOT_SUPPORTED_IN_MOBILE];
        
    }
    else if([enabledWidgetsUriArray count] == 1 && timePunchWidget)
    {
        [self validateWidgets];
    }
    
    else if ((isStandardWidget && isExtInOutWidget) || (isInOutWidget && isExtInOutWidget))
    {
        (timePunchWidget) ? [self validateWidgets] : [self showTimesheetFormatNotSupported:TIMESHEET_FORMAT_NOT_SUPPORTED_IN_MOBILE];
    }
    else
    {
        if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
        {
            SupportDataModel *supportDataModel=[[SupportDataModel alloc]init];
            NSDictionary *permittedApprovalAcionsDict=[supportDataModel getTimesheetPermittedApprovalActionsDataToDBWithUri:sheetIdentity];
            NSString *timesheetFormat=[self.timesheetModel getTimesheetFormatforTimesheetUri:sheetIdentity];

            if(timesheetFormat!=nil && ![timesheetFormat isKindOfClass:[NSNull class]])
            {
                if([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET])
                {

                    self.isBreakPermissionEnabled=[[permittedApprovalAcionsDict objectForKey:@"allowBreakForInOutGen4"] boolValue];
                }
                else if([timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                {

                    self.isBreakPermissionEnabled=[[permittedApprovalAcionsDict objectForKey:@"allowBreakForExtInOutGen4"] boolValue];
                }
                else if([timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                {
                    self.isBreakPermissionEnabled=[[permittedApprovalAcionsDict objectForKey:@"allowBreakForStandardGen4"] boolValue];
                    
                }
            }


            
            BOOL hasBreakAccessForPunchWidgetLevel=[[permittedApprovalAcionsDict objectForKey:@"allowBreakForPunchInGen4"] boolValue];
            self.isTimeoffPermissionEnabled=[[permittedApprovalAcionsDict objectForKey:@"allowTimeoffForGen4"] boolValue];
            NSMutableArray *userDetailsArr=[supportDataModel getUserDetailsFromDatabase];
            if (userDetailsArr!=nil && ![userDetailsArr isKindOfClass:[NSNull class]])
            {
                NSDictionary *userDetailsDict=[userDetailsArr objectAtIndex:0];
                
                BOOL hasTimeoffBookingAccessSystemLevel = [[userDetailsDict objectForKey:@"hasTimeoffBookingAccess"]boolValue];
                BOOL hasBreakAccessPunchLevel = [[userDetailsDict objectForKey:@"hasTimepunchBreakAccess"]boolValue];
                if (hasBreakAccessPunchLevel||hasBreakAccessForPunchWidgetLevel) {
                    self.hasBreakAccessForPunch=YES;
                }
                if (!hasTimeoffBookingAccessSystemLevel)
                {
                    self.isTimeoffPermissionEnabled=NO;
                }
                
            }
        }
        else
        {
            
            SupportDataModel *supportDataModel=[[SupportDataModel alloc]init];
            NSDictionary *permittedApprovalAcionsDict=[supportDataModel getTimesheetPermittedApprovalActionsDataToDBWithUri:sheetIdentity];
            NSString *timesheetFormat=nil;
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                timesheetFormat=[self.approvalsModel getTimesheetFormatforTimesheetUri:sheetIdentity andIsPending:TRUE];
            }
            else
            {
                timesheetFormat=[self.approvalsModel getTimesheetFormatforTimesheetUri:sheetIdentity andIsPending:FALSE];
            }
           
            if([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET])
            {
                
                self.isBreakPermissionEnabled=[[permittedApprovalAcionsDict objectForKey:@"allowBreakForInOutGen4"] boolValue];
            }
            else if([timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
            {

                self.isBreakPermissionEnabled=[[permittedApprovalAcionsDict objectForKey:@"allowBreakForExtInOutGen4"] boolValue];
            }
            else if([timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
            {
                self.isBreakPermissionEnabled=[[permittedApprovalAcionsDict objectForKey:@"allowBreakForStandardGen4"] boolValue];
                
            }
            
            self.hasBreakAccessForPunch=[[permittedApprovalAcionsDict objectForKey:@"allowBreakForPunchInGen4"] boolValue];
            self.isTimeoffPermissionEnabled=[[permittedApprovalAcionsDict objectForKey:@"allowTimeoffForGen4"] boolValue];
            
           
        }
        
        
        
        self.userWidgetsArray=[self getWidgetArray];
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        self.widgetTableView=[[UITableView alloc]initWithFrame:CGRectMake(0,0 ,self.view.frame.size.width,[self heightForTableView]) style:UITableViewStylePlain];
        
        self.widgetTableView.separatorColor=[UIColor clearColor];//[Util colorWithHex:@"#cccccc" alpha:1];
        self.widgetTableView.delegate=self;
        self.widgetTableView.dataSource=self;
        [self.widgetTableView setAccessibilityLabel:@"widget_ts_entry_tableview"];
        [self.view addSubview: self.widgetTableView];
        
        UIView *bckView = [[UIView alloc]initWithFrame:CGRectMake(0,0 ,screenRect.size.width,screenRect.size.height)];
        [bckView setBackgroundColor:RepliconStandardBackgroundColor];
        [ self.widgetTableView setBackgroundView:bckView];
        [[RepliconServiceManager approvalsService] setWidgetTimesheetDelegate:self];
        [[RepliconServiceManager timesheetService] setWidgetTimesheetDelegate:self];
        
        [self createTableHeader];
        [self createTableFooter];
        
    }

}

-(void)validateWidgets {
    BOOL canViewTeamOrSelfTimePunch = [self canViewTeamOrSelfTimePunch];
    if(!canViewTeamOrSelfTimePunch){
        [self showTimesheetFormatNotSupported:TIMESHEET_PUNCH_POLICY_NOT_ASSIGNED];
    }
    else{
        [self showTimesheetFormatNotSupported:TIMESHEET_FORMAT_NOT_SUPPORTED_IN_MOBILE];
    }
}

-(void)showTimesheetFormatNotSupported:(NSString *)message
{
    UILabel *msgLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 150, self.view.frame.size.width, 150)];
    msgLabel.text = RPLocalizedString(message, @"");
    msgLabel.backgroundColor = [UIColor clearColor];
    msgLabel.textAlignment = NSTextAlignmentCenter;
    msgLabel.lineBreakMode = NSLineBreakByWordWrapping;
    msgLabel.numberOfLines = 2;
    msgLabel.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14];
    [self.view addSubview:msgLabel];
}

- (BOOL)canViewTeamOrSelfTimePunch {
    SupportDataModel *supportDataModel = [[SupportDataModel alloc] init];
    NSMutableArray *userDetailsArr=[supportDataModel getUserDetailsFromDatabase];
    BOOL canViewTimePunch=FALSE;
    BOOL canViewTeamTimePunch=FALSE;
    if ([userDetailsArr count]>0)
    {
        canViewTimePunch=[[[userDetailsArr objectAtIndex:0] objectForKey:@"canViewTimePunch"] boolValue];
        canViewTeamTimePunch=[[[userDetailsArr objectAtIndex:0] objectForKey:@"canViewTeamTimePunch"] boolValue];
    }
    
    return [parentDelegate isKindOfClass:[ApprovalsScrollViewController class]] ? canViewTeamTimePunch : canViewTimePunch;
}

-(NSMutableArray *)getWidgetArray
{
    NSMutableArray *userWidgetArray=[NSMutableArray array];
    NSMutableArray *enabledWidgetsUriArray=[NSMutableArray array];
    if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
    {
        enabledWidgetsUriArray=[timesheetModel getAllEnabledWidgetsUriDetailsFromDBForTimesheetUri:sheetIdentity];
    }
    else
    {
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            enabledWidgetsUriArray=[approvalsModel getAllPendingEnabledWidgetsUriDetailsFromDBForTimesheetUri:sheetIdentity];
        }
        else
        {
            enabledWidgetsUriArray=[approvalsModel getAllPreviousEnabledWidgetsUriDetailsFromDBForTimesheetUri:sheetIdentity];
        }
    }
    BOOL timesheetStatusWidget=YES;
    if (timesheetStatusWidget)
    {
        [userWidgetArray addObject:TIMESHEET_STATUS_WIDGET];
    }
    
    NSMutableArray *arrayFromDB=nil;
    if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
    {
        
        arrayFromDB=[timesheetModel getAllTimesheetApprovalFromDBForTimesheet:sheetIdentity];
    }
    else if([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
    {
        ApprovalsModel *apprvalModel=[[ApprovalsModel alloc]init];
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            arrayFromDB=[apprvalModel getAllPendingTimesheetApprovalFromDBForTimesheet:sheetIdentity];
            
        }
        else
        {
            arrayFromDB=[apprvalModel getAllPreviousTimesheetApprovalFromDBForTimesheet:sheetIdentity];
        }
        
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"widgetUri == %@", APPROVAL_HISTORY_WIDGET_URI];
    NSArray *filtered  = [enabledWidgetsUriArray filteredArrayUsingPredicate:predicate];
    if(filtered.count >0){
        if ([arrayFromDB count]>0)
        {
            [userWidgetArray addObject:CHANGE_HISTORY_WIDGET];
        }
    }
        
    BOOL addCommentsApproveRejectWidget=NO;
    for (int j=0; j<[enabledWidgetsUriArray count]; j++)
    {
        NSString *widgetUri=[[enabledWidgetsUriArray objectAtIndex:j] objectForKey:@"widgetUri"];
        if ([widgetUri isEqualToString:PUNCH_WIDGET_URI])
        {
            BOOL canViewTeamOrSelfTimePunch = [self canViewTeamOrSelfTimePunch];
            if(canViewTeamOrSelfTimePunch){
                [userWidgetArray addObject:TIME_PUNCHES_WIDGET];
            }
        }
        else if ([widgetUri isEqualToString:INOUT_WIDGET_URI])
        {
            [userWidgetArray addObject:IN_OUT_TIMESHEET_WIDGET];
            
        }
        else if ([widgetUri isEqualToString:EXT_INOUT_WIDGET_URI])
        {
            [userWidgetArray addObject:EXT_IN_OUT_TIMESHEET_WIDGET];

        }
        else if ([widgetUri isEqualToString:PAYSUMMARY_WIDGET_URI])
        {
            NSArray *paycodes;
            if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
            {
                if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                    paycodes=[approvalsModel getAllPaycodesIsPending:YES forTimesheetUri:sheetIdentity];
                else
                    paycodes=[approvalsModel getAllPaycodesIsPending:NO forTimesheetUri:sheetIdentity];

                SupportDataModel *supportDataModel = [[SupportDataModel alloc] init];
                NSMutableArray *userDetailsArr=[supportDataModel getUserDetailsFromDatabase];
                BOOL canViewTeamPayDetails =NO;
                if (userDetailsArr!=nil && ![userDetailsArr isKindOfClass:[NSNull class]])
                {

                    canViewTeamPayDetails = [[[userDetailsArr objectAtIndex:0] objectForKey:@"canViewTeamPayDetails"]boolValue];
                    
                }
                if (canViewTeamPayDetails)
                    [userWidgetArray addObject:PAYROLL_SUMMARY_WIDGET];
            }
            else
            {
                paycodes = [timesheetModel getAllPaycodesforTimesheetUri:sheetIdentity];

                SupportDataModel *supportDataModel=[[SupportDataModel alloc]init];
                NSDictionary *permittedApprovalAcionsDict=[supportDataModel getTimesheetPermittedApprovalActionsDataToDBWithUri:sheetIdentity];
                BOOL canOwnerViewPayrollSummary=FALSE;

                BOOL isDictAvailable = (permittedApprovalAcionsDict != nil && ![permittedApprovalAcionsDict isKindOfClass:[NSNull class]]);
                if (isDictAvailable) {
                    id canOwnerViewPayrollSummaryValue = permittedApprovalAcionsDict[@"canOwnerViewPayrollSummary"];
                    BOOL isValuePresent = (canOwnerViewPayrollSummaryValue != nil && ![canOwnerViewPayrollSummaryValue isKindOfClass:[NSNull class]]);
                    if (isValuePresent) {
                        canOwnerViewPayrollSummary = [[permittedApprovalAcionsDict objectForKey:@"canOwnerViewPayrollSummary"] boolValue];
                    }
                }
                if (canOwnerViewPayrollSummary)
                    [userWidgetArray addObject:PAYROLL_SUMMARY_WIDGET];
            }

        }
        else if ([widgetUri isEqualToString:NOTICE_WIDGET_URI])
        {
            NSMutableDictionary *disclaimerDict=nil;
            if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
            {
                if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                {
                    disclaimerDict=[approvalsModel getDisclaimerDetailsFromDBForTimesheetUri:sheetIdentity isPending:YES];
                }
                else
                {
                    disclaimerDict=[approvalsModel getDisclaimerDetailsFromDBForTimesheetUri:sheetIdentity isPending:NO];
                }
            }
            else
            {
                disclaimerDict=[timesheetModel getDisclaimerDetailsFromDBForTimesheetUri:sheetIdentity];
            }
            if (([disclaimerDict objectForKey:@"title"]==nil||[[disclaimerDict objectForKey:@"title"] isKindOfClass:[NSNull class]]) && ([disclaimerDict objectForKey:@"description"]==nil||[[disclaimerDict objectForKey:@"description"] isKindOfClass:[NSNull class]]))
            {
                
            }
            else
            {
                [userWidgetArray addObject:NOTICE_WIDGET_URI];
            }
            
        }
        
        else if ([widgetUri isEqualToString:ATTESTATION_WIDGET_URI])
        {
            NSMutableDictionary *attestationDict=nil;
            if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
            {
                if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                {
                    attestationDict=[approvalsModel getAttestationDetailsFromDBForTimesheetUri:sheetIdentity isPending:YES];
                }
                else
                {
                    attestationDict=[approvalsModel getAttestationDetailsFromDBForTimesheetUri:sheetIdentity isPending:NO];
                }
            }
            else
            {
                attestationDict=[timesheetModel getAttestationDetailsFromDBForTimesheetUri:sheetIdentity];
            }
            if (([attestationDict objectForKey:@"title"]==nil||[[attestationDict objectForKey:@"title"] isKindOfClass:[NSNull class]]) && ([attestationDict objectForKey:@"description"]==nil||[[attestationDict objectForKey:@"description"] isKindOfClass:[NSNull class]]))
            {
                
            }
            else
            {
                [userWidgetArray addObject:ATTESTATION_WIDGET_URI];
            }
            
        }
        
        else if ([widgetUri isEqualToString:STANDARD_WIDGET_URI])
        {
            [userWidgetArray addObject:STANDARD_TIMESHEET_WIDGET];
            
        }

        else if ([widgetUri isEqualToString:DAILY_FIELDS_WIDGET_URI])
        {
            [userWidgetArray addObject:DAILY_FIELD_WIDGET];

        }

        
        
    }
    if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
    {
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            addCommentsApproveRejectWidget=YES;
        }
        
    }
    if (addCommentsApproveRejectWidget)
    {
        [userWidgetArray addObject:ADD_COMMENTS_APPROVE_REJECT_WIDGET];
    }
    
    
    
    return userWidgetArray;
}

-(void)viewDidAppear:(BOOL)animated
{

  //  [self viewDidAppear:animated];

    [self shouldShowRefreshButton];

//   [self.widgetTableView reloadData];
    //Check For Error Banner View
    [self setTableViewInset];

    BOOL hasPendingOperationsOnTimesheet = NO;
    NSMutableArray *pendingOperations = [self.timesheetModel getPendingOperationsArr:sheetIdentity];
    if (pendingOperations.count>0)
    {
        if ([pendingOperations containsObject:TIMESHEET_SUBMIT_OPERATION] || [pendingOperations containsObject:TIMESHEET_RESUBMIT_OPERATION])
        {
            hasPendingOperationsOnTimesheet = YES;
        }

    }

    if (hasPendingOperationsOnTimesheet)
    {
        UIView *tempfooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                          0.0,
                                                                          self.view.frame.size.width,
                                                                          20.0)];
        self.footerView=tempfooterView;
        [footerView setBackgroundColor:[Util colorWithHex:@"#DADADA" alpha:1]];
        [self.widgetTableView setTableFooterView:self.footerView];
    }
    else
    {
        if (self.widgetTableView.tableFooterView.frame.size.height == 20.0)
        {
            [self createTableFooter];
        }
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataReceived:) name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [self checkForDeeplinkAndNavigate];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.widgetTableView setContentOffset:CGPointZero animated:YES];
    [self.widgetTableView reloadData];

}



-(void)shouldShowRefreshButton
{
    if ([self.refreshButtonCheckTimer isValid])
    {
        [self.refreshButtonCheckTimer invalidate];
    }
    NSString *timesheetFormat=[self.timesheetModel getTimesheetFormatforTimesheetUri:sheetIdentity];
    if (timesheetFormat!=nil &&![timesheetFormat isKindOfClass:[NSNull class]])
    {
        if (![self.timesheetModel checkIfTimeEntriesModifiedOrDeleted:sheetIdentity timesheetFormat:timesheetFormat])
        {
            UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                              target:self action:@selector(refreshClicked:)];
            [self.navigationItem setRightBarButtonItem: refreshButton animated:YES];
        }
        else
        {
            self.navigationItem.rightBarButtonItem = nil;
            self.refreshButtonCheckTimer= [NSTimer scheduledTimerWithTimeInterval: 0.5
                                                                           target: self
                                                                         selector:@selector(shouldShowRefreshButton)
                                                                         userInfo: nil repeats:NO];
        }
    }
    else
    {
        UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]
                                          initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                          target:self action:@selector(refreshClicked:)];
        [self.navigationItem setRightBarButtonItem: refreshButton animated:YES];
    }
}

-(void)setTableViewInset
{
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper = [appDelegate.injector getInstance:[ErrorBannerViewParentPresenterHelper class]];
    [errorBannerViewParentPresenterHelper setTableViewInsetWithErrorBannerPresentation:self.widgetTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Service Requests Method
-(void)callServiceWithName:(ServiceName1)_serviceName
{
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        return;
    }
    
    if (_serviceName==TIMESHEET_SUMMARY_BACKGROUND_FETCH_SERVICE)
    {
       
        AFHTTPRequestOperation *operation = [[RepliconServiceManager timesheetRequest]fetchTimeSheetSummaryDataForTimesheet:sheetIdentity isFreshDataDownload:NO];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received for URL::::: %@ ",operation.request.URL] forLogLevel:LoggerCocoaLumberjack];

            CLS_LOG(@"Response Received for URL::::: %@ ",operation.request.URL);

            [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received ::::: %@",operation.responseString] forLogLevel:LoggerCocoaLumberjack];

            CLS_LOG(@"Response Received ::::: %@",operation.responseString);

            NSDictionary *errorDict = [responseObject objectForKey:@"error"];
            if (errorDict == nil) {
                
                //Case2:Cache response present. Merge data and optionally present UI
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self compareAfterReceivedBackgroundTimesheetSummaryData:responseObject];
                });
                
            }
            else
            {
                
            }
            
        }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Failed ::::: %@ ",[error description]] forLogLevel:LoggerCocoaLumberjack];

             CLS_LOG(@"Response Failed ::::: %@ ",[error description]);

             [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received ::::: %@",operation.responseString] forLogLevel:LoggerCocoaLumberjack];

             CLS_LOG(@"Response Received ::::: %@ ",operation.responseString);
         }];
        [operation start];
    }

    
    
}



#pragma mark - UITableView Delegates
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
    float padding=PADDING_FOR_EACH_WIDGET;
    if (indexPath.row==[self.userWidgetsArray count]-1)
    {
        padding=0;
    }
    
    NSString *widgetType=[self.userWidgetsArray objectAtIndex:indexPath.row];
    if ([widgetType isEqualToString:TIMESHEET_STATUS_WIDGET])
    {
        return TIMESHEET_STATUS_WIDGET_HEIGHT+padding;
    }
    if ([widgetType isEqualToString:CHANGE_HISTORY_WIDGET])
    {
        return CHANGE_HISTORY_WIDGET_HEIGHT+padding;
    }
    else if ([widgetType isEqualToString:IN_OUT_TIMESHEET_WIDGET] || [widgetType isEqualToString:EXT_IN_OUT_TIMESHEET_WIDGET])
    {
        
        BOOL shouldBreakBeShown=NO;
        BOOL shouldTimeoffBeShown=NO;
        float regularHours=0;
        float breakHours=0;
        float timeoffHours=0;
        NSMutableDictionary *hoursDict=nil;
        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                hoursDict=[approvalsModel getWidgetSummaryForTimesheetUri:sheetIdentity isPending:YES];
            }
            else
            {
                hoursDict=[approvalsModel getWidgetSummaryForTimesheetUri:sheetIdentity isPending:NO];
            }
        }
        else
        {
            hoursDict=[timesheetModel getWidgetSummaryForTimesheetUri:sheetIdentity];
        }
        
        if (hoursDict!=nil && ![hoursDict isKindOfClass:[NSNull class]])
        {
            regularHours=[[hoursDict objectForKey:@"totalInOutWorkHours"] newFloatValue];
            if([hoursDict objectForKey:@"totalInOutBreakHours"] != nil && [hoursDict objectForKey:@"totalInOutBreakHours"] != (id)[NSNull null]) {
               breakHours=[[hoursDict objectForKey:@"totalInOutBreakHours"] newFloatValue];
            }
            
            if([hoursDict objectForKey:@"totalInOutTimeOffHours"] != nil && [hoursDict objectForKey:@"totalInOutTimeOffHours"] != (id)[NSNull null]) {
                timeoffHours=[[hoursDict objectForKey:@"totalInOutTimeOffHours"] newFloatValue];
            }
        }
        
        if (breakHours>0)
        {
            shouldBreakBeShown=YES;
        }
        else
        {
            if (self.isBreakPermissionEnabled)
            {
                if([hoursDict objectForKey:@"totalInOutBreakHours"] != nil && [hoursDict objectForKey:@"totalInOutBreakHours"] != (id)[NSNull null]) {
                    shouldBreakBeShown=YES;
                }
            }
            else
            {
                shouldBreakBeShown=NO;
            }
        }
        if (timeoffHours>0)
        {
            shouldTimeoffBeShown=YES;
        }
        else
        {
            if (self.isTimeoffPermissionEnabled)
            {
                if([hoursDict objectForKey:@"totalInOutTimeOffHours"] != nil && [hoursDict objectForKey:@"totalInOutTimeOffHours"] != (id)[NSNull null]) {
                    shouldTimeoffBeShown=YES;
                }
            }
            else
            {
                shouldTimeoffBeShown=NO;
            }
        }
        
        if (shouldTimeoffBeShown && shouldBreakBeShown)
        {
            return IN_OUT_WIDGET_LOADED_HEIGHT_WITH_BREAK_AND_TIMEOFF+padding;
        }
        else if (shouldTimeoffBeShown||shouldBreakBeShown)
        {
            return IN_OUT_WIDGET_LOADED_HEIGHT_WITH_BREAK_OR_TIMEOFF+padding;
        }
        return IN_OUT_WIDGET_LOADED_HEIGHT_WITHOUT_BREAK_AND_TIMEOFF+padding;
    }
    else if ([widgetType isEqualToString:TIME_PUNCHES_WIDGET])
    {
        
        BOOL shouldBreakBeShown=NO;
        BOOL shouldTimeoffBeShown=NO;
        float regularHours=0;
        float breakHours=0;
        float timeoffHours=0;
        NSMutableDictionary *hoursDict=nil;
        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                hoursDict=[approvalsModel getWidgetSummaryForTimesheetUri:sheetIdentity isPending:YES];
            }
            else
            {
                hoursDict=[approvalsModel getWidgetSummaryForTimesheetUri:sheetIdentity isPending:NO];
            }
        }
        else
        {
            hoursDict=[timesheetModel getWidgetSummaryForTimesheetUri:sheetIdentity];
        }
        
        if (hoursDict!=nil && ![hoursDict isKindOfClass:[NSNull class]])
        {
            regularHours=[[hoursDict objectForKey:@"totalTimePunchWorkHours"] newFloatValue];
            breakHours=[[hoursDict objectForKey:@"totalTimePunchBreakHours"] newFloatValue];
            timeoffHours=[[hoursDict objectForKey:@"totalTimePunchTimeOffHours"] newFloatValue];
        }
        
        if (breakHours>0)
        {
            shouldBreakBeShown=YES;
        }
        else
        {
            if (self.hasBreakAccessForPunch)
            {
                shouldBreakBeShown=YES;
            }
            else
            {
                shouldBreakBeShown=NO;
            }
        }
        if (timeoffHours>0)
        {
            shouldTimeoffBeShown=YES;
        }
        else
        {
            if (self.isTimeoffPermissionEnabled)
            {
                shouldTimeoffBeShown=YES;
            }
            else
            {
                shouldTimeoffBeShown=NO;
            }
        }

        if (shouldTimeoffBeShown && shouldBreakBeShown)
        {
            return IN_OUT_WIDGET_LOADED_HEIGHT_WITH_BREAK_AND_TIMEOFF+padding;
        }
        else if (shouldTimeoffBeShown||shouldBreakBeShown)
        {
            return IN_OUT_WIDGET_LOADED_HEIGHT_WITH_BREAK_OR_TIMEOFF+padding;
        }
        return IN_OUT_WIDGET_LOADED_HEIGHT_WITHOUT_BREAK_AND_TIMEOFF+padding;
        
    }
    else if ([widgetType isEqualToString:ADD_COMMENTS_APPROVE_REJECT_WIDGET])
    {
        /*if (self.approverComments==nil||[self.approverComments isKindOfClass:[NSNull class]]||[self.approverComments isEqualToString:@""])
        {
            return APPROVE_REJECT_COMMENTS_NOT_LOADED_WIDGET_HEIGHT;
        }
        else
        {
            if (self.approverComments)
            {
                CGSize size =CGSizeMake(0, 0);
                if (self.approverComments)
                {
                    
                    
                    // Let's make an NSAttributedString first
                    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.approverComments];
                    //Add LineBreakMode
                    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
                    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
                    [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
                    // Add Font
                    [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:RepliconFontSize_14]} range:NSMakeRange(0, attributedString.length)];
                    
                    //Now let's make the Bounding Rect
                    size  = [attributedString boundingRectWithSize:CGSizeMake(265.0, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
                    
                    if (size.width==0 && size.height ==0)
                    {
                        size=CGSizeMake(11.0, 18.0);
                    }
                    
                }
                float height=size.height+45;
                return height+APPROVE_REJECT_COMMENTS_NOT_LOADED_WIDGET_HEIGHT;
            }
            
        }*/
        return APPROVE_REJECT_COMMENTS_NOT_LOADED_WIDGET_HEIGHT;
    }
    else if ([widgetType isEqualToString:NOTICE_WIDGET_URI])
    {
        float yPadding=15;
        NSMutableDictionary *disclaimerDict=nil;
        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                disclaimerDict=[approvalsModel getDisclaimerDetailsFromDBForTimesheetUri:sheetIdentity isPending:YES];
            }
            else
            {
                disclaimerDict=[approvalsModel getDisclaimerDetailsFromDBForTimesheetUri:sheetIdentity isPending:NO];
            }
        }
        else
        {
            disclaimerDict=[timesheetModel getDisclaimerDetailsFromDBForTimesheetUri:sheetIdentity];
        }
        
        NSString *title=[disclaimerDict objectForKey:@"title"];
        NSString *description=[disclaimerDict objectForKey:@"description"];
        int height=0;
        if (title==nil||[title isKindOfClass:[NSNull class]]||[title isEqualToString:@""])
        {
            height=0;
        }
        else
        {
            CGSize size =CGSizeMake(0, 0);
            
            // Let's make an NSAttributedString first
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
            //Add LineBreakMode
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]} range:NSMakeRange(0, attributedString.length)];
            
            //Now let's make the Bounding Rect
            size = [attributedString boundingRectWithSize:CGSizeMake(290.0, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            
            
            if (size.width==0 && size.height ==0)
            {
                size=CGSizeMake(11.0, 18.0);
            }
            height=size.height+10;
            
        }
        
        int descriptionHeight=0;
        if (description==nil||[description isKindOfClass:[NSNull class]]||[description isEqualToString:@""])
        {
            descriptionHeight=0;
        }
        else
        {
            CGSize size =CGSizeMake(0, 0);
            
            // Let's make an NSAttributedString first
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:description];
            //Add LineBreakMode
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:RepliconFontSize_14]} range:NSMakeRange(0, attributedString.length)];
            
            //Now let's make the Bounding Rect
            size = [attributedString boundingRectWithSize:CGSizeMake(280.0, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            
            
            if (size.width==0 && size.height ==0)
            {
                size=CGSizeMake(11.0, 18.0);
            }
            descriptionHeight=size.height;
            
        }
        
        if (height>0 && descriptionHeight>0)
        {
            return yPadding+height+yPadding+yPadding+descriptionHeight+padding+20;
        }
        if (height==0 && descriptionHeight>0)
        {
            return yPadding+descriptionHeight+padding+20;
        }
        if (height>0 && descriptionHeight==0)
        {
             return yPadding+height+yPadding+20;
        }
        
        
    }
    else if ([widgetType isEqualToString:ATTESTATION_WIDGET_URI])
    {
        float yPadding=15;
        NSMutableDictionary *attestationDict=nil;
        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                attestationDict=[approvalsModel getAttestationDetailsFromDBForTimesheetUri:sheetIdentity isPending:YES];
            }
            else
            {
                attestationDict=[approvalsModel getAttestationDetailsFromDBForTimesheetUri:sheetIdentity isPending:NO];
            }
        }
        else
        {
            attestationDict=[timesheetModel getAttestationDetailsFromDBForTimesheetUri:sheetIdentity];
        }
        
        NSString *title=[attestationDict objectForKey:@"title"];
        NSString *description=[attestationDict objectForKey:@"description"];
        int height=0;
        if (title==nil||[title isKindOfClass:[NSNull class]]||[title isEqualToString:@""])
        {
            height=0;
        }
        else
        {
            CGSize size =CGSizeMake(0, 0);
            
            // Let's make an NSAttributedString first
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
            //Add LineBreakMode
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]} range:NSMakeRange(0, attributedString.length)];
            
            //Now let's make the Bounding Rect
            size = [attributedString boundingRectWithSize:CGSizeMake(290.0, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            
            
            if (size.width==0 && size.height ==0)
            {
                size=CGSizeMake(11.0, 18.0);
            }
            height=size.height+10;
            
        }
        
        int descriptionHeight=0;
        if (description==nil||[description isKindOfClass:[NSNull class]]||[description isEqualToString:@""])
        {
            descriptionHeight=0;
        }
        else
        {
            CGSize size =CGSizeMake(0, 0);
            
            // Let's make an NSAttributedString first
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:description];
            //Add LineBreakMode
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:RepliconFontSize_14]} range:NSMakeRange(0, attributedString.length)];
            
            //Now let's make the Bounding Rect
            size = [attributedString boundingRectWithSize:CGSizeMake(280.0, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            
            
            if (size.width==0 && size.height ==0)
            {
                size=CGSizeMake(11.0, 18.0);
            }
            descriptionHeight=size.height;
            
        }
        
        UIImage *radioDeselectedImage = [Util thumbnailImage:CheckBoxDeselectedImage];
        
        if (height>0 && descriptionHeight>0)
        {
            return yPadding+height+yPadding+yPadding+descriptionHeight+padding+20+5+radioDeselectedImage.size.height+10;
        }
        if (height==0 && descriptionHeight>0)
        {
            return yPadding+descriptionHeight+padding+20+5+radioDeselectedImage.size.height+10;
        }
        if (height>0 && descriptionHeight==0)
        {
            return yPadding+height+yPadding+20+5+radioDeselectedImage.size.height+10;
            
        }

        
    }
    else if ([widgetType isEqualToString:STANDARD_TIMESHEET_WIDGET])
    {
        
        BOOL shouldBreakBeShown=NO;
        BOOL shouldTimeoffBeShown=NO;
        float regularHours=0;
        float breakHours=0;
        float timeoffHours=0;
        NSMutableDictionary *hoursDict=nil;
        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                hoursDict=[approvalsModel getWidgetSummaryForTimesheetUri:sheetIdentity isPending:YES];
            }
            else
            {
                hoursDict=[approvalsModel getWidgetSummaryForTimesheetUri:sheetIdentity isPending:NO];
            }
        }
        else
        {
            hoursDict=[timesheetModel getWidgetSummaryForTimesheetUri:sheetIdentity];
        }
        
        if (hoursDict!=nil && ![hoursDict isKindOfClass:[NSNull class]])
        {
            if([hoursDict objectForKey:@"totalInOutBreakHours"] != nil && [hoursDict objectForKey:@"totalInOutBreakHours"] != (id)[NSNull null]) {
                breakHours=[[hoursDict objectForKey:@"totalInOutBreakHours"] newFloatValue];
            }
            
            if([hoursDict objectForKey:@"totalInOutTimeOffHours"] != nil && [hoursDict objectForKey:@"totalInOutTimeOffHours"] != (id)[NSNull null]) {
                timeoffHours=[[hoursDict objectForKey:@"totalInOutTimeOffHours"] newFloatValue];
            }
            regularHours=[[hoursDict objectForKey:@"totalInOutWorkHours"] newFloatValue];
            
            
        }
        
        if (breakHours>0)
        {
            shouldBreakBeShown=YES;
        }
        else
        {
            if (self.isBreakPermissionEnabled)
            {
                if([hoursDict objectForKey:@"totalInOutBreakHours"] != nil && [hoursDict objectForKey:@"totalInOutBreakHours"] != (id)[NSNull null]) {
                    shouldBreakBeShown=YES;
                }
            }
            else
            {
                shouldBreakBeShown=NO;
            }
        }
        if (timeoffHours>0)
        {
           shouldTimeoffBeShown=YES;
        }
        else
        {
        if (self.isTimeoffPermissionEnabled)
        {
            if([hoursDict objectForKey:@"totalInOutTimeOffHours"] != nil && [hoursDict objectForKey:@"totalInOutTimeOffHours"] != (id)[NSNull null]) {
                shouldTimeoffBeShown=YES;
            }
        }
        else
        {
            shouldTimeoffBeShown=NO;
        }
        }
        
        if (shouldTimeoffBeShown && shouldBreakBeShown)
        {
            return IN_OUT_WIDGET_LOADED_HEIGHT_WITH_BREAK_AND_TIMEOFF+padding;
        }
        else if (shouldTimeoffBeShown||shouldBreakBeShown)
        {
            return IN_OUT_WIDGET_LOADED_HEIGHT_WITH_BREAK_OR_TIMEOFF+padding;
        }
        return IN_OUT_WIDGET_LOADED_HEIGHT_WITHOUT_BREAK_AND_TIMEOFF+padding;
    }
    else if([widgetType isEqualToString:PAYROLL_SUMMARY_WIDGET])
    {
        float yOffset = 8.0;
        float labelHeight = 20.0;
        NSArray *paycodes;
        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                paycodes=[approvalsModel getAllPaycodesIsPending:YES forTimesheetUri:sheetIdentity];
            else
                paycodes=[approvalsModel getAllPaycodesIsPending:NO forTimesheetUri:sheetIdentity];
        }
        else
        {
            paycodes = [timesheetModel getAllPaycodesforTimesheetUri:sheetIdentity];

        }

        BOOL zeroHoursScenario = NO;
        if (paycodes.count ==1) {
            NSString *paycode = paycodes.firstObject[@"paycodename"];
            if ([paycode isKindOfClass:[NSNull class]] || paycode.length ==0) {
                zeroHoursScenario = YES;
            }
        }
        if (paycodes.count==0 || zeroHoursScenario) {
            return labelHeight +( 2 * yOffset)+labelHeight + (2 *yOffset)+yOffset+padding;
        }
        return paycodes.count * (labelHeight +( 2 * yOffset))+ (labelHeight + 2 *yOffset) *2+yOffset+padding + 15.0;
    }
    else if ([widgetType isEqualToString:DAILY_FIELD_WIDGET])
    {
        NSString *dailyFieldsWidgetTitle = RPLocalizedString(DEFAULT_DAILY_FIELDS_TITLE, DEFAULT_DAILY_FIELDS_TITLE);
        NSMutableArray *enabledWidgetsUriArray=nil;

        if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
        {
            enabledWidgetsUriArray=[timesheetModel getAllEnabledWidgetsUriDetailsFromDBForTimesheetUri:sheetIdentity];
        }
        else
        {
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                enabledWidgetsUriArray=[approvalsModel getAllPendingEnabledWidgetsUriDetailsFromDBForTimesheetUri:sheetIdentity];
            }
            else
            {
                enabledWidgetsUriArray=[approvalsModel getAllPreviousEnabledWidgetsUriDetailsFromDBForTimesheetUri:sheetIdentity];
            }
        }

        for (int j=0; j<[enabledWidgetsUriArray count]; j++)
        {
            NSString *widgetUri=[[enabledWidgetsUriArray objectAtIndex:j] objectForKey:@"widgetUri"];
            if ([widgetUri isEqualToString:DAILY_FIELDS_WIDGET_URI])
            {
                NSString *widgetTitle=[[enabledWidgetsUriArray objectAtIndex:j] objectForKey:@"widgetTitle"];
                if (widgetTitle!=nil && ![widgetTitle isKindOfClass:[NSNull class]])
                {
                    dailyFieldsWidgetTitle = widgetTitle;
                }
                break;
            }
        }

        float height=0;
        if (dailyFieldsWidgetTitle==nil||[dailyFieldsWidgetTitle isKindOfClass:[NSNull class]]||[dailyFieldsWidgetTitle isEqualToString:@""])
        {
            height=0;
        }
        else
        {
            CGSize size =CGSizeMake(0, 0);

            // Let's make an NSAttributedString first
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:dailyFieldsWidgetTitle];
            //Add LineBreakMode
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]} range:NSMakeRange(0, attributedString.length)];

            //Now let's make the Bounding Rect
            size = [attributedString boundingRectWithSize:CGSizeMake(280.0, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;


            if (size.width==0 && size.height ==0)
            {
                size=CGSizeMake(11.0, 18.0);
            }
            height=size.height+10;

        }

        return height+padding+24.0;
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.userWidgetsArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *widgetType=[self.userWidgetsArray objectAtIndex:indexPath.row];
    NSString *CellIdentifier=widgetType;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ([widgetType isEqualToString:TIMESHEET_STATUS_WIDGET])
    {
        UITableViewCell *tcell = (UITableViewCell*)cell;
        if (tcell == nil)
        {
            tcell = [[UITableViewCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            tcell.contentView.backgroundColor =[Util colorWithHex:@"#DADADA" alpha:1] ;
            
        }
        UILabel *statusLb= [[UILabel alloc]initWithFrame:CGRectMake(10, 7, SCREEN_WIDTH, 20)];
        NSString *statusStr=nil;
        NSString *colorStr=nil;
        
        
        NSMutableArray *arrayFromDB=nil;
        if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
        {
            
            arrayFromDB=[timesheetModel getAllTimesheetApprovalFromDBForTimesheet:sheetIdentity];
        }
        else if([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            ApprovalsModel *apprvalModel=[[ApprovalsModel alloc]init];
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                arrayFromDB=[apprvalModel getAllPendingTimesheetApprovalFromDBForTimesheet:sheetIdentity];
                
            }
            else
            {
                arrayFromDB=[apprvalModel getAllPreviousTimesheetApprovalFromDBForTimesheet:sheetIdentity];
            }
            
        }
        
        BOOL canEditTimesheet=[timesheetModel getTimeSheetEditStatusForSheetFromDB:sheetIdentity];
        
        if (!canEditTimesheet||[self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_TIMESHEETS_MODULE])
        {
            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] || [sheetApprovalStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION] || [sheetApprovalStatus isEqualToString:TIMESHEET_SUBMITTED])
            {
                statusStr=RPLocalizedString(WAITING_FOR_APRROVAL_STATUS, @"");
                statusLb.text=[NSString stringWithFormat:@"%@",statusStr];
                colorStr=@"#FCC58D";
                statusLb.textColor=[Util colorWithHex:@"#333333" alpha:1];
                
            }
            else if ([sheetApprovalStatus isEqualToString:APPROVED_STATUS]) {
                statusStr=RPLocalizedString(APPROVED_STATUS,APPROVED_STATUS);
                statusLb.text=[NSString stringWithFormat:@"%@",statusStr];
                colorStr=@"#86BC3B";
                statusLb.textColor=[Util colorWithHex:@"#333333" alpha:1];
                
            }
            else if ([sheetApprovalStatus isEqualToString:REJECTED_STATUS]){
                statusStr=RPLocalizedString(REJECTED_STATUS,@"");
                statusLb.text=[NSString stringWithFormat:@"%@",statusStr];
                colorStr=@"#F4694B";
                statusLb.textColor=[Util colorWithHex:@"#FFFFFF" alpha:1];
                
                
            }
            else{
                
                if([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
                {
                    isCurrentTimesheetPeriod=NO;
                }
                if (isCurrentTimesheetPeriod)
                {
                    statusStr=[NSString stringWithFormat:@"%@ - %@ %@",RPLocalizedString(CURRENT_TIMESHEET, @""),RPLocalizedString(@"Due", @"Due"),dueDate];
                    statusLb.text=[NSString stringWithFormat:@"%@",statusStr];
                    colorStr=@"#DADADA";
                    statusLb.textColor=[Util colorWithHex:@"#333333" alpha:1];
                }
                else
                {
                    statusStr=RPLocalizedString(NOT_SUBMITTED_STATUS, @"");
                    statusLb.text=[NSString stringWithFormat:@"%@",statusStr];
                    colorStr=@"#DADADA";
                    statusLb.textColor=[Util colorWithHex:@"#333333" alpha:1];
                }
                
            }
        }
        else{
            if ([self.sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ] || [self.sheetApprovalStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION ] || [self.sheetApprovalStatus isEqualToString:TIMESHEET_SUBMITTED ])
            {
                statusStr=RPLocalizedString(WAITING_FOR_APRROVAL_STATUS, @"");
                statusLb.text=[NSString stringWithFormat:@"%@",statusStr];
                colorStr=@"#FCC58D";
                statusLb.textColor=[Util colorWithHex:@"#333333" alpha:1];
                
            }
            else if ([self.sheetApprovalStatus isEqualToString:APPROVED_STATUS ]) {
                statusStr=RPLocalizedString(APPROVED_STATUS,APPROVED_STATUS);
                statusLb.text=[NSString stringWithFormat:@"%@",statusStr];
                colorStr=@"#86BC3B";
                statusLb.textColor=[Util colorWithHex:@"#333333" alpha:1];
                
            }
            else if ([self.sheetApprovalStatus isEqualToString:REJECTED_STATUS ]){
                statusStr=RPLocalizedString(REJECTED_STATUS,@"");
                statusLb.text=[NSString stringWithFormat:@"%@",statusStr];
                colorStr=@"#F4694B";
                statusLb.textColor=[Util colorWithHex:@"#FFFFFF" alpha:1];
                
                
            }
            else if ([self.sheetApprovalStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION]){
                statusStr=TIMESHEET_PENDING_SUBMISSION;
                statusLb.text=[NSString stringWithFormat:@"%@",statusStr];
                colorStr=@"#DADADA";
                statusLb.textColor=[Util colorWithHex:@"#333333" alpha:1];
                
                
            }
             else if ([self.sheetApprovalStatus isEqualToString:TIMESHEET_SUBMITTED]){
                statusStr=TIMESHEET_SUBMITTED;
                statusLb.text=[NSString stringWithFormat:@"%@",statusStr];
                colorStr=@"#DADADA";
                statusLb.textColor=[Util colorWithHex:@"#333333" alpha:1];
                
                
            }
            else if ([self.sheetApprovalStatus isEqualToString:TIMESHEET_CONFLICTED]){
                statusStr=TIMESHEET_CONFLICTED;
                statusLb.text=[NSString stringWithFormat:@"%@",statusStr];
                colorStr=@"#DADADA";
                statusLb.textColor=[Util colorWithHex:@"#333333" alpha:1];
                
                
            }
            else{
                
                if([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
                {
                    isCurrentTimesheetPeriod=NO;
                }
                
                if (isCurrentTimesheetPeriod)
                {
                    statusStr=[NSString stringWithFormat:@"%@ - %@ %@",RPLocalizedString(CURRENT_TIMESHEET, @""),RPLocalizedString(@"Due", @"Due"),dueDate];
                    statusLb.text=[NSString stringWithFormat:@"%@",statusStr];
                    colorStr=@"#DADADA";
                    statusLb.textColor=[Util colorWithHex:@"#333333" alpha:1];
                }
                else
                {
                    statusStr=RPLocalizedString(NOT_SUBMITTED_STATUS, @"");
                    statusLb.text=[NSString stringWithFormat:@"%@",statusStr];
                    colorStr=@"#DADADA";
                    statusLb.textColor=[Util colorWithHex:@"#333333" alpha:1];
                }
                
                
            }
        }
        
        [tcell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        UIView *statusView= [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, TIMESHEET_STATUS_WIDGET_HEIGHT)];
        statusLb.textColor=RepliconStandardBlackColor;
        statusLb.textAlignment=NSTextAlignmentLeft;
        [statusLb setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
        [statusLb setBackgroundColor:[UIColor clearColor]];
        [statusLb setText:statusStr];
        [statusView addSubview:statusLb];
        if (isCurrentTimesheetPeriod)
        {
            if ([statusStr isEqualToString:RPLocalizedString(NOT_SUBMITTED_STATUS, @"")]||
                [statusStr isEqualToString:RPLocalizedString(APPROVED_STATUS, @"")]||
                [statusStr isEqualToString:RPLocalizedString(WAITING_FOR_APRROVAL_STATUS, @"")]||
                [statusStr isEqualToString:RPLocalizedString(REJECTED_STATUS, @"")]||
                [statusStr isEqualToString:TIMESHEET_PENDING_SUBMISSION]||
                [statusStr isEqualToString:TIMESHEET_SUBMITTED]||
                [statusStr isEqualToString:TIMESHEET_CONFLICTED])



            {
                [statusView setBackgroundColor:[Util colorWithHex:colorStr alpha:1]];
            }
            else
            {
                [statusView setBackgroundColor:[UIColor lightGrayColor]];
            }
            
        }
        else
        {
            if ([statusStr isEqualToString:RPLocalizedString(NOT_SUBMITTED_STATUS, @"")])
            {
                [statusView setBackgroundColor:[UIColor lightGrayColor]];
            }
            else
            {
                [statusView setBackgroundColor:[Util colorWithHex:colorStr alpha:1]];
            }
        }
        
        [tcell.contentView addSubview:statusView];
        return tcell;

    }
    if ([widgetType isEqualToString:CHANGE_HISTORY_WIDGET])
    {
        ApproverHistoryCustomCell *tcell = (ApproverHistoryCustomCell*)cell;
        if (tcell == nil)
        {
            tcell = [[ApproverHistoryCustomCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            tcell.contentView.backgroundColor = [Util colorWithHex:@"#f8f8f8" alpha:1];
            
        }
        
        [tcell createCellLayoutInoutWidgetTitle:RPLocalizedString(APPROVER_HISTORY_WIDGET_TITLE, @"") andPaddingY:CHANGE_HISTORY_WIDGET_HEIGHT andPaddingH:PADDING_FOR_EACH_WIDGET andTotalHeightForTitleLable:20.0];
        return tcell;
        
    }
    if ([widgetType isEqualToString:IN_OUT_TIMESHEET_WIDGET] || [widgetType isEqualToString:EXT_IN_OUT_TIMESHEET_WIDGET])
    {
        InoutWidgetCustomCell *tcell = (InoutWidgetCustomCell*)cell;
        if (tcell == nil)
        {
            tcell = [[InoutWidgetCustomCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            tcell.contentView.backgroundColor = [Util colorWithHex:@"#f8f8f8" alpha:1];
            
        }
       
        
        NSString *regularHours=[NSString stringWithFormat:@"%.2f",[@"0.00" newFloatValue]];
        NSString *breakHours=[NSString stringWithFormat:@"%.2f",[@"0.00" newFloatValue]];
        NSString *timeoffHours=[NSString stringWithFormat:@"%.2f",[@"0.00" newFloatValue]];
        
        BOOL shouldBreakBeShown=NO;
        BOOL shouldTimeoffBeShown=NO;
        NSMutableDictionary *hoursDict=nil;
        
        
        
        SupportDataModel *supportDataModel=[[SupportDataModel alloc]init];
        NSDictionary *permittedApprovalAcionsDict=[supportDataModel getTimesheetPermittedApprovalActionsDataToDBWithUri:sheetIdentity];


        if ([widgetType isEqualToString:IN_OUT_TIMESHEET_WIDGET])
        {
            self.isBreakPermissionEnabled=[[permittedApprovalAcionsDict objectForKey:@"allowBreakForInOutGen4"] boolValue];

        }
        if ([widgetType isEqualToString:EXT_IN_OUT_TIMESHEET_WIDGET])
        {
            self.isBreakPermissionEnabled=[[permittedApprovalAcionsDict objectForKey:@"allowBreakForExtInOutGen4"] boolValue];

        }

         self.isTimeoffPermissionEnabled=[[permittedApprovalAcionsDict objectForKey:@"allowTimeoffForGen4"] boolValue];
        
        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                hoursDict=[approvalsModel getWidgetSummaryForTimesheetUri:sheetIdentity isPending:YES];
            }
            else
            {
                hoursDict=[approvalsModel getWidgetSummaryForTimesheetUri:sheetIdentity isPending:NO];
            }
        }
        else
        {
            hoursDict=[timesheetModel getWidgetSummaryForTimesheetUri:sheetIdentity];
            
        }
        
        if (hoursDict!=nil && ![hoursDict isKindOfClass:[NSNull class]])
        {
            regularHours=[NSString stringWithFormat:@"%.2f",[[hoursDict objectForKey:@"totalInOutWorkHours"] newFloatValue]];
            
            if([hoursDict objectForKey:@"totalInOutBreakHours"] != nil && [hoursDict objectForKey:@"totalInOutBreakHours"] != (id)[NSNull null]) {
                breakHours=[NSString stringWithFormat:@"%.2f",[[hoursDict objectForKey:@"totalInOutBreakHours"] newFloatValue]];
            }
            if([hoursDict objectForKey:@"totalInOutTimeOffHours"] != nil && [hoursDict objectForKey:@"totalInOutTimeOffHours"] != (id)[NSNull null]) {
                timeoffHours=[NSString stringWithFormat:@"%.2f",[[hoursDict objectForKey:@"totalInOutTimeOffHours"] newFloatValue]];
            }
            
            if ([[Util detectDecimalMark] isEqualToString:@","])
            {
                regularHours=[regularHours stringByReplacingOccurrencesOfString:@"." withString:@","];
                breakHours=[breakHours stringByReplacingOccurrencesOfString:@"." withString:@","];
                timeoffHours=[timeoffHours stringByReplacingOccurrencesOfString:@"." withString:@","];
            }
            
        }
        
        if ([breakHours floatValue]>0)
        {
            shouldBreakBeShown=YES;
        }
        else
        {
            if (self.isBreakPermissionEnabled)
            {
                if([hoursDict objectForKey:@"totalInOutBreakHours"] != nil && [hoursDict objectForKey:@"totalInOutBreakHours"] != (id)[NSNull null]) {
                    shouldBreakBeShown=YES;
                }
            }
            else
            {
                shouldBreakBeShown=NO;
            }
        }
        
        if ([timeoffHours floatValue]>0)
        {
            shouldTimeoffBeShown=YES;
        }
        else
        {
            if (self.isTimeoffPermissionEnabled)
            {
                if([hoursDict objectForKey:@"totalInOutTimeOffHours"] != nil && [hoursDict objectForKey:@"totalInOutTimeOffHours"] != (id)[NSNull null]) {
                    shouldTimeoffBeShown=YES;
                }
            }
            else
            {
                shouldTimeoffBeShown=NO;
            }
        }
        float yPadding=IN_OUT_WIDGET_NOT_LOADED_HEIGHT;
        if (shouldTimeoffBeShown && shouldBreakBeShown)
        {
            yPadding=IN_OUT_WIDGET_LOADED_HEIGHT_WITH_BREAK_AND_TIMEOFF;
        }
        else if (shouldTimeoffBeShown||shouldBreakBeShown)
        {
            yPadding=IN_OUT_WIDGET_LOADED_HEIGHT_WITH_BREAK_OR_TIMEOFF;
        }
        else
        {
            yPadding=IN_OUT_WIDGET_LOADED_HEIGHT_WITHOUT_BREAK_AND_TIMEOFF;
        }
        float padding=PADDING_FOR_EACH_WIDGET;
        if (indexPath.row==[self.userWidgetsArray count]-1)
        {
            padding=0;
        }

       NSString*widgetTitle=@"";
       if ([widgetType isEqualToString:IN_OUT_TIMESHEET_WIDGET])
       {
         widgetTitle=RPLocalizedString(IN_OUT_TIMESHEET_WIDGET_TITLE, @"");
       }
       if ([widgetType isEqualToString:EXT_IN_OUT_TIMESHEET_WIDGET])
       {
          widgetTitle=RPLocalizedString(EXT_IN_OUT_TIMESHEET_WIDGET_TITLE, @"");
       }

        [tcell createCellLayoutInoutWidgetTitle:widgetTitle regularHours:regularHours breakHours:breakHours timeoffHours:timeoffHours isLoadedWidget:YES andPaddingY:yPadding andPaddingH:padding shouldBreakBeShown:shouldBreakBeShown shouldTimeoffBeShown:shouldTimeoffBeShown isPunchWidget:NO];
        return tcell;
    }

    if ([widgetType isEqualToString:TIME_PUNCHES_WIDGET])
    {
        InoutWidgetCustomCell *tcell = (InoutWidgetCustomCell*)cell;
        if (tcell == nil)
        {
            tcell = [[InoutWidgetCustomCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            tcell.contentView.backgroundColor =[Util colorWithHex:@"#f8f8f8" alpha:1];
            
        }
        BOOL isWidgetLoaded=NO;
        BOOL shouldBreakBeShown=NO;
        BOOL shouldTimeoffBeShown=NO;
        NSString *regularHours=[NSString stringWithFormat:@"%.2f",[@"0.00" newFloatValue]];
        NSString *breakHours=[NSString stringWithFormat:@"%.2f",[@"0.00" newFloatValue]];
        NSString *timeoffHours=[NSString stringWithFormat:@"%.2f",[@"0.00" newFloatValue]];
        isWidgetLoaded=YES;
        tcell.userInteractionEnabled = YES;
        NSMutableDictionary *hoursDict=nil;
        
        SupportDataModel *supportDataModel=[[SupportDataModel alloc]init];
        NSDictionary *permittedApprovalAcionsDict=[supportDataModel getTimesheetPermittedApprovalActionsDataToDBWithUri:sheetIdentity];
        
        
        self.isTimeoffPermissionEnabled=[[permittedApprovalAcionsDict objectForKey:@"allowTimeoffForGen4"] boolValue];
         self.hasBreakAccessForPunch=[[permittedApprovalAcionsDict objectForKey:@"allowBreakForPunchInGen4"] boolValue];
        
        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                hoursDict=[approvalsModel getWidgetSummaryForTimesheetUri:sheetIdentity isPending:YES];
            }
            else
            {
                hoursDict=[approvalsModel getWidgetSummaryForTimesheetUri:sheetIdentity isPending:NO];
            }
        }
        else
        {
            hoursDict=[timesheetModel getWidgetSummaryForTimesheetUri:sheetIdentity];
        }
        if (hoursDict!=nil && ![hoursDict isKindOfClass:[NSNull class]])
        {
            regularHours=[NSString stringWithFormat:@"%.2f",[[hoursDict objectForKey:@"totalTimePunchWorkHours"] newFloatValue]];
            breakHours=[NSString stringWithFormat:@"%.2f",[[hoursDict objectForKey:@"totalTimePunchBreakHours"] newFloatValue]];
            timeoffHours=[NSString stringWithFormat:@"%.2f",[[hoursDict objectForKey:@"totalTimePunchTimeOffHours"] newFloatValue]];
            
            if ([[Util detectDecimalMark] isEqualToString:@","])
            {
                regularHours=[regularHours stringByReplacingOccurrencesOfString:@"." withString:@","];
                breakHours=[breakHours stringByReplacingOccurrencesOfString:@"." withString:@","];
                timeoffHours=[timeoffHours stringByReplacingOccurrencesOfString:@"." withString:@","];
            }
            
        }
        
        if ([breakHours floatValue]>0)
        {
            shouldBreakBeShown=YES;
        }
        else
        {
            if (self.hasBreakAccessForPunch)
            {
                shouldBreakBeShown=YES;
            }
            else
            {
                shouldBreakBeShown=NO;
            }
        }

        if ([timeoffHours floatValue]>0)
        {
            shouldTimeoffBeShown=YES;
        }
        else
        {
            if (self.isTimeoffPermissionEnabled)
            {
                shouldTimeoffBeShown=YES;
            }
            else
            {
                shouldTimeoffBeShown=NO;
            }
        }
        float yPadding=IN_OUT_WIDGET_NOT_LOADED_HEIGHT;
        if (shouldTimeoffBeShown && shouldBreakBeShown)
        {
            yPadding=IN_OUT_WIDGET_LOADED_HEIGHT_WITH_BREAK_AND_TIMEOFF;
        }
        else if (shouldTimeoffBeShown||shouldBreakBeShown)
        {
            yPadding=IN_OUT_WIDGET_LOADED_HEIGHT_WITH_BREAK_OR_TIMEOFF;
        }
        else
        {
            yPadding=IN_OUT_WIDGET_LOADED_HEIGHT_WITHOUT_BREAK_AND_TIMEOFF;
        }
        float padding=PADDING_FOR_EACH_WIDGET;
        if (indexPath.row==[self.userWidgetsArray count]-1)
        {
            padding=0;
        }
        [tcell createCellLayoutInoutWidgetTitle:RPLocalizedString(PUNCH_TIMESHEET_WIDGET_TITLE, @"") regularHours:regularHours breakHours:breakHours timeoffHours:timeoffHours isLoadedWidget:isWidgetLoaded andPaddingY:yPadding andPaddingH:padding shouldBreakBeShown:shouldBreakBeShown shouldTimeoffBeShown:shouldTimeoffBeShown isPunchWidget:YES];
        return tcell;
        
    }

    if ([widgetType isEqualToString:ADD_COMMENTS_APPROVE_REJECT_WIDGET])
    {
        ApproveRejectCommentsCell *tcell = (ApproveRejectCommentsCell*)cell;
        if (tcell == nil)
        {
            tcell = [[ApproveRejectCommentsCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            tcell.contentView.backgroundColor = [UIColor lightGrayColor];
            
        }
        int height=0;
        /*if (self.approverComments==nil||[self.approverComments isKindOfClass:[NSNull class]]||[self.approverComments isEqualToString:@""])
        {
            height=0;
        }
        else
        {
            CGSize size =CGSizeMake(0, 0);
            if (self.approverComments)
            {
                
                
                // Let's make an NSAttributedString first
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.approverComments];
                //Add LineBreakMode
                NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
                [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
                [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
                // Add Font
                [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:RepliconFontSize_14]} range:NSMakeRange(0, attributedString.length)];
                
                //Now let's make the Bounding Rect
                size  = [attributedString boundingRectWithSize:CGSizeMake(265.0, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
                
                if (size.width==0 && size.height ==0)
                {
                    size=CGSizeMake(11.0, 18.0);
                }
                
            }
            height=size.height+30;

        }*/
        [tcell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [tcell setDelegate:self];
        [tcell createCellLayoutWidgetTitle:RPLocalizedString(ADD_COMMENT_WIDGET_TITLE, @"") andComments:nil andVariableTextHeight:height];
        return tcell;
        
    }
    
    if ([widgetType isEqualToString:NOTICE_WIDGET_URI])
    {
        WidgetNoticeCell *tcell = (WidgetNoticeCell*)cell;
        if (tcell == nil)
        {
            tcell = [[WidgetNoticeCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            tcell.contentView.backgroundColor = [Util colorWithHex:@"#f8f8f8" alpha:1];
            
        }
        NSMutableDictionary *disclaimerDict=nil;
        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                disclaimerDict=[approvalsModel getDisclaimerDetailsFromDBForTimesheetUri:sheetIdentity isPending:YES];
            }
            else
            {
                disclaimerDict=[approvalsModel getDisclaimerDetailsFromDBForTimesheetUri:sheetIdentity isPending:NO];
            }
        }
        else
        {
            disclaimerDict=[timesheetModel getDisclaimerDetailsFromDBForTimesheetUri:sheetIdentity];
        }
        
        NSString *title=[disclaimerDict objectForKey:@"title"];
        NSString *description=[disclaimerDict objectForKey:@"description"];
        int height=0;
        if (title==nil||[title isKindOfClass:[NSNull class]]||[title isEqualToString:@""])
        {
            height=0;
        }
        else
        {
            CGSize size =CGSizeMake(0, 0);
            
            // Let's make an NSAttributedString first
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
            //Add LineBreakMode
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]} range:NSMakeRange(0, attributedString.length)];
            
            //Now let's make the Bounding Rect
            size = [attributedString boundingRectWithSize:CGSizeMake(290.0, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            
           
            if (size.width==0 && size.height ==0)
            {
                size=CGSizeMake(11.0, 18.0);
            }
            height=size.height+10;
            
        }
        
        int descriptionHeight=0;
        if (description==nil||[description isKindOfClass:[NSNull class]]||[description isEqualToString:@""])
        {
            descriptionHeight=0;
        }
        else
        {
            CGSize size =CGSizeMake(0, 0);
            
            // Let's make an NSAttributedString first
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:description];
            //Add LineBreakMode
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:RepliconFontSize_14]} range:NSMakeRange(0, attributedString.length)];
            
            //Now let's make the Bounding Rect
            size = [attributedString boundingRectWithSize:CGSizeMake(280.0, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            
           
            if (size.width==0 && size.height ==0)
            {
                size=CGSizeMake(11.0, 18.0);
            }
            descriptionHeight=size.height;
            
        }

        
        BOOL showPaddingSepartor=YES;
        if (indexPath.row==[self.userWidgetsArray count]-1)
        {
            showPaddingSepartor=NO;
        }
        [tcell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [tcell setDelegate:self];
        [tcell createCellLayoutWidgetTitle:title andDescription:description andTitleTextHeight:height anddescriptionTextHeight:descriptionHeight showPadding:showPaddingSepartor];
        return tcell;

    }
    
    if ([widgetType isEqualToString:ATTESTATION_WIDGET_URI])
    {
        WidgetAttestationCell *tcell = (WidgetAttestationCell*)cell;
        if (tcell == nil)
        {
            tcell = [[WidgetAttestationCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            tcell.contentView.backgroundColor = [Util colorWithHex:@"#f8f8f8" alpha:1];
            
        }
        [tcell setWidgetAttestationCellDelegate:self];
        NSMutableDictionary *attestationDict=nil;
        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                attestationDict=[approvalsModel getAttestationDetailsFromDBForTimesheetUri:sheetIdentity isPending:YES];
            }
            else
            {
                attestationDict=[approvalsModel getAttestationDetailsFromDBForTimesheetUri:sheetIdentity isPending:NO];
            }
        }
        else
        {
            attestationDict=[timesheetModel getAttestationDetailsFromDBForTimesheetUri:sheetIdentity];
        }
        
        NSString *title=[attestationDict objectForKey:@"title"];
        NSString *description=[attestationDict objectForKey:@"description"];
        int height=0;
        if (title==nil||[title isKindOfClass:[NSNull class]]||[title isEqualToString:@""])
        {
            height=0;
        }
        else
        {
            CGSize size =CGSizeMake(0, 0);
            
            // Let's make an NSAttributedString first
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
            //Add LineBreakMode
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]} range:NSMakeRange(0, attributedString.length)];
            
            //Now let's make the Bounding Rect
            size = [attributedString boundingRectWithSize:CGSizeMake(290.0, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            
            
            if (size.width==0 && size.height ==0)
            {
                size=CGSizeMake(11.0, 18.0);
            }
            height=size.height+10;
            
        }
        
        int descriptionHeight=0;
        if (description==nil||[description isKindOfClass:[NSNull class]]||[description isEqualToString:@""])
        {
            descriptionHeight=0;
        }
        else
        {
            CGSize size =CGSizeMake(0, 0);
            
            // Let's make an NSAttributedString first
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:description];
            //Add LineBreakMode
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:RepliconFontSize_14]} range:NSMakeRange(0, attributedString.length)];
            
            //Now let's make the Bounding Rect
            size = [attributedString boundingRectWithSize:CGSizeMake(280.0, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            
            
            if (size.width==0 && size.height ==0)
            {
                size=CGSizeMake(11.0, 18.0);
            }
            descriptionHeight=size.height;
            
        }
        
        
        BOOL showPaddingSepartor=YES;
        if (indexPath.row==[self.userWidgetsArray count]-1)
        {
            showPaddingSepartor=NO;
        }
        [tcell setSelectionStyle:UITableViewCellSelectionStyleNone];

        NSString *sheetStatus=self.sheetApprovalStatus;

        if ([self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_TIMESHEETS_MODULE])
        {
            sheetStatus=WAITING_FOR_APRROVAL_STATUS;
        }

        if (self.sheetApprovalStatus!=nil && ![self.sheetApprovalStatus isKindOfClass:[NSNull class]])
        {
            if ([self.sheetApprovalStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION])
            {
                sheetStatus = RPLocalizedString(WAITING_FOR_APRROVAL_STATUS, @"");
            }
            else if ([self.sheetApprovalStatus isEqualToString:TIMESHEET_SUBMITTED])
            {
                sheetStatus = RPLocalizedString(WAITING_FOR_APRROVAL_STATUS, @"");
            }

        }

        BOOL attestationStatus = NO;

        if ([attestationDict objectForKey:@"attestationStatus"]!=nil && ![[attestationDict objectForKey:@"attestationStatus"] isKindOfClass:[NSNull class]])
        {
            attestationStatus = [[attestationDict objectForKey:@"attestationStatus"]boolValue];
        }

        [tcell createCellLayoutWidgetAttestation:title andDescription:description andTitleTextHeight:height anddescriptionTextHeight:descriptionHeight showPadding:showPaddingSepartor andAttestationStatus:attestationStatus andTimeSheetStatus:sheetStatus];
        
        if (attestationStatus)
        {
            self.isAttestationSelected=YES;
        }
        else
        {
            self.isAttestationSelected=NO;
        }
        
        self.hasAttestationPermission=YES;
        
        return tcell;
        
    }
    
    if ([widgetType isEqualToString:STANDARD_TIMESHEET_WIDGET])
    {
        InoutWidgetCustomCell *tcell = (InoutWidgetCustomCell*)cell;
        if (tcell == nil)
        {
            tcell = [[InoutWidgetCustomCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            tcell.contentView.backgroundColor = [Util colorWithHex:@"#f8f8f8" alpha:1];
            
        }
        
        
        NSString *regularHours=[NSString stringWithFormat:@"%.2f",[@"0.00" newFloatValue]];
        NSString *breakHours=[NSString stringWithFormat:@"%.2f",[@"0.00" newFloatValue]];
        NSString *timeoffHours=[NSString stringWithFormat:@"%.2f",[@"0.00" newFloatValue]];
        
        BOOL shouldBreakBeShown=NO;
        BOOL shouldTimeoffBeShown=NO;
        NSMutableDictionary *hoursDict=nil;
        
        SupportDataModel *supportDataModel=[[SupportDataModel alloc]init];
        NSDictionary *permittedApprovalAcionsDict=[supportDataModel getTimesheetPermittedApprovalActionsDataToDBWithUri:sheetIdentity];
        
        self.isBreakPermissionEnabled=[[permittedApprovalAcionsDict objectForKey:@"allowBreakForStandardGen4"] boolValue];
        self.isTimeoffPermissionEnabled=[[permittedApprovalAcionsDict objectForKey:@"allowTimeoffForGen4"] boolValue];
        
        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                hoursDict=[approvalsModel getWidgetSummaryForTimesheetUri:sheetIdentity isPending:YES];
            }
            else
            {
                hoursDict=[approvalsModel getWidgetSummaryForTimesheetUri:sheetIdentity isPending:NO];
            }
        }
        else
        {
            hoursDict=[timesheetModel getWidgetSummaryForTimesheetUri:sheetIdentity];
        }
        
        if (hoursDict!=nil && ![hoursDict isKindOfClass:[NSNull class]])
        {
            if([hoursDict objectForKey:@"totalInOutBreakHours"] != nil && [hoursDict objectForKey:@"totalInOutBreakHours"] != (id)[NSNull null]) {
                breakHours=[NSString stringWithFormat:@"%.2f",[[hoursDict objectForKey:@"totalInOutBreakHours"] newFloatValue]];
            }
            regularHours=[NSString stringWithFormat:@"%.2f",[[hoursDict objectForKey:@"totalStandardWorkHours"] newFloatValue]];
            timeoffHours=[NSString stringWithFormat:@"%.2f",[[hoursDict objectForKey:@"totalStandardTimeOffHours"] newFloatValue]];
            if ([[Util detectDecimalMark] isEqualToString:@","])
            {
                regularHours=[regularHours stringByReplacingOccurrencesOfString:@"." withString:@","];
                breakHours=[breakHours stringByReplacingOccurrencesOfString:@"." withString:@","];
                timeoffHours=[timeoffHours stringByReplacingOccurrencesOfString:@"." withString:@","];
            }
            
        }
        
        //BREAKS NOT SHOWN FOR STANDARD TIMESHEET WIDGET
        
//        if ([breakHours floatValue]>0)
//        {
//            shouldBreakBeShown=YES;
//        }
//        else
//        {
//            if (self.isBreakPermissionEnabled)
//            {
//                shouldBreakBeShown=YES;
//            }
//            else
//            {
//                shouldBreakBeShown=NO;
//            }
//        }
        
        if ([timeoffHours floatValue]>0)
        {
            shouldTimeoffBeShown=YES;
        }
        else
        {
            if (self.isTimeoffPermissionEnabled)
            {
                if([hoursDict objectForKey:@"totalInOutTimeOffHours"] != nil && [hoursDict objectForKey:@"totalInOutTimeOffHours"] != (id)[NSNull null]) {
                    shouldTimeoffBeShown=YES;
                }
            }
            else
            {
                shouldTimeoffBeShown=NO;
            }
        }
        float yPadding=IN_OUT_WIDGET_NOT_LOADED_HEIGHT;
        if (shouldTimeoffBeShown && shouldBreakBeShown)
        {
            yPadding=IN_OUT_WIDGET_LOADED_HEIGHT_WITH_BREAK_AND_TIMEOFF;
        }
        else if (shouldTimeoffBeShown||shouldBreakBeShown)
        {
            yPadding=IN_OUT_WIDGET_LOADED_HEIGHT_WITH_BREAK_OR_TIMEOFF;
        }
        else
        {
            yPadding=IN_OUT_WIDGET_LOADED_HEIGHT_WITHOUT_BREAK_AND_TIMEOFF;
        }
        float padding=PADDING_FOR_EACH_WIDGET;
        if (indexPath.row==[self.userWidgetsArray count]-1)
        {
            padding=0;
        }
        [tcell createCellLayoutInoutWidgetTitle:RPLocalizedString(STANDARD_TIMESHEET_WIDGET_TITLE, @"") regularHours:regularHours breakHours:breakHours timeoffHours:timeoffHours isLoadedWidget:YES andPaddingY:yPadding andPaddingH:padding shouldBreakBeShown:shouldBreakBeShown shouldTimeoffBeShown:shouldTimeoffBeShown isPunchWidget:NO];
        return tcell;
    }

    if ([widgetType isEqualToString:PAYROLL_SUMMARY_WIDGET]) {
        PayrollSummaryWidgetCell *tcell = (PayrollSummaryWidgetCell*)cell;
        if (tcell == nil)
        {
            tcell = [[PayrollSummaryWidgetCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            tcell.contentView.backgroundColor = [Util colorWithHex:@"#f8f8f8" alpha:1];

        }
        NSArray *paycodes;
        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                paycodes=[approvalsModel getAllPaycodesIsPending:YES forTimesheetUri:sheetIdentity];
            }
            else
            {
                paycodes=[approvalsModel getAllPaycodesIsPending:NO forTimesheetUri:sheetIdentity];
            }
        }
        else
        {
            paycodes = [timesheetModel getAllPaycodesforTimesheetUri:sheetIdentity];

        }
        [tcell setSelectionStyle:UITableViewCellSelectionStyleNone];

        float padding=PADDING_FOR_EACH_WIDGET;
        if (indexPath.row==[self.userWidgetsArray count]-1)
        {
            padding=0;
        }
        [tcell createPayrollSummaryWidgetCellWithTitle:RPLocalizedString(@"Payroll Summary", nil) paycodes:paycodes  yOffset:8 labelHeight:20 hPadding:padding];
        return tcell;
    }

    if ([widgetType isEqualToString:DAILY_FIELD_WIDGET])
    {
        ApproverHistoryCustomCell *tcell = (ApproverHistoryCustomCell*)cell;
        if (tcell == nil)
        {
            tcell = [[ApproverHistoryCustomCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            tcell.contentView.backgroundColor = [Util colorWithHex:@"#f8f8f8" alpha:1];

        }

        NSString *dailyFieldsWidgetTitle = RPLocalizedString(DEFAULT_DAILY_FIELDS_TITLE, DEFAULT_DAILY_FIELDS_TITLE);
        NSMutableArray *enabledWidgetsUriArray=nil;

        if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
        {
            enabledWidgetsUriArray=[timesheetModel getAllEnabledWidgetsUriDetailsFromDBForTimesheetUri:sheetIdentity];
        }
        else
        {
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                enabledWidgetsUriArray=[approvalsModel getAllPendingEnabledWidgetsUriDetailsFromDBForTimesheetUri:sheetIdentity];
            }
            else
            {
                enabledWidgetsUriArray=[approvalsModel getAllPreviousEnabledWidgetsUriDetailsFromDBForTimesheetUri:sheetIdentity];
            }
        }

        for (int j=0; j<[enabledWidgetsUriArray count]; j++)
        {
            NSString *widgetUri=[[enabledWidgetsUriArray objectAtIndex:j] objectForKey:@"widgetUri"];
            if ([widgetUri isEqualToString:DAILY_FIELDS_WIDGET_URI])
            {
                NSString *widgetTitle=[[enabledWidgetsUriArray objectAtIndex:j] objectForKey:@"widgetTitle"];
                if (widgetTitle!=nil && ![widgetTitle isKindOfClass:[NSNull class]])
                {
                    dailyFieldsWidgetTitle = widgetTitle;
                }
                break;
            }
        }

        float height=0;
        if (dailyFieldsWidgetTitle==nil||[dailyFieldsWidgetTitle isKindOfClass:[NSNull class]]||[dailyFieldsWidgetTitle isEqualToString:@""])
        {
            height=0;
        }
        else
        {
            CGSize size =CGSizeMake(0, 0);

            // Let's make an NSAttributedString first
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:dailyFieldsWidgetTitle];
            //Add LineBreakMode
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]} range:NSMakeRange(0, attributedString.length)];

            //Now let's make the Bounding Rect
            size = [attributedString boundingRectWithSize:CGSizeMake(280.0, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;


            if (size.width==0 && size.height ==0)
            {
                size=CGSizeMake(11.0, 18.0);
            }
            height=size.height+10;
            
        }

        [tcell createCellLayoutInoutWidgetTitle:dailyFieldsWidgetTitle andPaddingY:height+PADDING_FOR_EACH_WIDGET andPaddingH:PADDING_FOR_EACH_WIDGET andTotalHeightForTitleLable:height];
        return tcell;

    }

	return nil;
	
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];

    if ([self.refreshButtonCheckTimer isValid])
    {
        [self.refreshButtonCheckTimer invalidate];
    }

    [self.widgetTableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *widget=[self.userWidgetsArray objectAtIndex:indexPath.row];
    if ([widget isEqualToString:CHANGE_HISTORY_WIDGET])
    {
        ApproverCommentViewController *approverCommentCtrl=[[ApproverCommentViewController alloc]init];
        approverCommentCtrl.sheetIdentity=sheetIdentity;
        approverCommentCtrl.viewType=@"Timesheet";
        if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
        {
            approverCommentCtrl.delegate=self;
        }
        else
        {
            approverCommentCtrl.delegate=parentDelegate;
            approverCommentCtrl.approvalsModuleName=self.approvalsModuleName ;
        }
        
        NSMutableArray *arrayFromDB=nil;
        if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
        {
            
            arrayFromDB=[timesheetModel getAllTimesheetApprovalFromDBForTimesheet:sheetIdentity];
        }
        else if([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            ApprovalsModel *apprvalModel=[[ApprovalsModel alloc]init];
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                arrayFromDB=[apprvalModel getAllPendingTimesheetApprovalFromDBForTimesheet:sheetIdentity];
                
            }
            else
            {
                arrayFromDB=[apprvalModel getAllPreviousTimesheetApprovalFromDBForTimesheet:sheetIdentity];
            }
            
        }
        
        if ([arrayFromDB count]>0)
        {
            if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
            {
                [self.navigationController pushViewController:approverCommentCtrl animated:YES];
            }
            else if([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
            {
                [parentDelegate pushToViewController:approverCommentCtrl];
            }
            
        }
        
    }
    else if ([widget isEqualToString:ADD_COMMENTS_APPROVE_REJECT_WIDGET])
    {
        AddDescriptionViewController *addDescriptionViewController  = [[AddDescriptionViewController alloc]init];
        addDescriptionViewController.fromExpenseDescription =YES;
        [addDescriptionViewController setDescTextString:self.approverComments];
        [addDescriptionViewController setViewTitle:RPLocalizedString(ADD_COMMENT_WIDGET_TITLE, @"")];
        addDescriptionViewController.descControlDelegate=self;
        BOOL canEdit=YES;
        if (canEdit)
        {
            [addDescriptionViewController setIsNonEditable:NO];
        }
        else
        {
            [addDescriptionViewController setIsNonEditable:YES];
        }
        
        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            ApprovalsScrollViewController *scrl=(ApprovalsScrollViewController *)parentDelegate;
            [scrl pushToViewController:addDescriptionViewController];
        }
        else
        {
            [self.navigationController pushViewController:addDescriptionViewController animated:YES];
        }
        
    }
    else if ([widget isEqualToString:IN_OUT_TIMESHEET_WIDGET])
    {
        
        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            NSString *updateWhereStr=[NSString stringWithFormat:@"timesheetUri='%@'",sheetIdentity];
            NSString *tableName=@"";
            NSArray *arrayDict=nil;
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                
                arrayDict=[self.approvalsModel getTimeSheetInfoSheetIdentityForPending:sheetIdentity];
                tableName=@"PendingApprovalTimesheets";
                
            }
            else
            {
                arrayDict=[self.approvalsModel getTimeSheetInfoSheetIdentityForPrevious:sheetIdentity];
                tableName=@"PreviousApprovalTimesheets";
            }
            if ([arrayDict count]>0)
            {
                SQLiteDB *myDB = [SQLiteDB getInstance];
                NSMutableDictionary *updateDataDict=[NSMutableDictionary dictionaryWithDictionary:[arrayDict objectAtIndex:0]];
                [updateDataDict removeObjectForKey:@"timesheetFormat"];
                [updateDataDict setObject:GEN4_INOUT_TIMESHEET forKey:@"timesheetFormat"];
                [myDB updateTable:tableName data:updateDataDict where:updateWhereStr intoDatabase:@""];

                if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                {
                    [self.approvalsModel updateApprovalTimeentriesFormatForTimesheetWithUri:sheetIdentity withFormat:GEN4_INOUT_TIMESHEET fromFormat:EXT_IN_OUT_TIMESHEET_WIDGET andIsPending:YES];
                }
                else
                {
                    [self.approvalsModel updateApprovalTimeentriesFormatForTimesheetWithUri:sheetIdentity withFormat:GEN4_INOUT_TIMESHEET fromFormat:EXT_IN_OUT_TIMESHEET_WIDGET andIsPending:NO];

                }
                
            }
        }
        else
        {
            NSString *updateWhereStr=[NSString stringWithFormat:@"timesheetUri='%@'",sheetIdentity];
            NSArray *arrayDict=[self.timesheetModel getTimeSheetInfoSheetIdentity:sheetIdentity];
            
            if ([arrayDict count]>0)
            {
                SQLiteDB *myDB = [SQLiteDB getInstance];
                NSMutableDictionary *updateDataDict=[NSMutableDictionary dictionaryWithDictionary:[arrayDict objectAtIndex:0]];
                [updateDataDict removeObjectForKey:@"timesheetFormat"];
                [updateDataDict setObject:GEN4_INOUT_TIMESHEET forKey:@"timesheetFormat"];
                [myDB updateTable: @"timesheets" data:updateDataDict where:updateWhereStr intoDatabase:@""];
                
                [self.timesheetModel updateTimeentriesFormatForTimesheetWithUri:sheetIdentity withFormat:GEN4_INOUT_TIMESHEET fromFormat:EXT_IN_OUT_TIMESHEET_WIDGET];
                
            }
        }
        
        
        
        TimesheetMainPageController *tmpTimesheetMainPageController=[[TimesheetMainPageController alloc]init];
        self.timesheetMainPageController=tmpTimesheetMainPageController;
        self.timesheetMainPageController.timesheetURI=sheetIdentity;
        self.timesheetMainPageController.parentDelegate=parentDelegate;
        self.timesheetMainPageController.trackTimeEntryChangeDelegate=self;
        BOOL isExtendedInOut=YES;
        BOOL isMultiDayInOutTimesheetUser=YES;

        self.timesheetMainPageController.timesheetURI=sheetIdentity;
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_TIMESHEETS_MODULE] || [self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            self.timesheetMainPageController.timesheetStatus=APPROVED_STATUS;
        }
        else
        {
            self.timesheetMainPageController.timesheetStatus=self.sheetApprovalStatus;
        }
        if (isExtendedInOut)
        {
            self.timesheetMainPageController.multiDayInOutType=EXTENDED_IN_OUT_TIMESHEET_TYPE;
        }
        else
        {
            self.timesheetMainPageController.multiDayInOutType=NOT_EXTENDED_IN_OUT_TIMESHEET_TYPE;
        }
        
        self.timesheetMainPageController.isDisclaimerRequired=NO;
        self.timesheetMainPageController.isMultiDayInOutTimesheetUser=isMultiDayInOutTimesheetUser;
        self.timesheetMainPageController.sheetLevelUdfArray=nil;
        self.timesheetMainPageController.hasUserChangedAnyValue=NO;
        self.timesheetMainPageController.timesheetStartDate=timesheetStartDate;
        self.timesheetMainPageController.timesheetEndDate=timesheetEndDate;
        self.timesheetMainPageController.userUri=userUri;
        NSArray *dbTimesheetSummaryArray=nil;
        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            [[NSNotificationCenter defaultCenter] removeObserver:tmpTimesheetMainPageController name:APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:tmpTimesheetMainPageController selector:@selector(recievedTimesheetSummaryData:) name:APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION object:nil];
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                dbTimesheetSummaryArray = [approvalsModel getAllPendingTimesheetDaySummaryFromDBForTimesheet:sheetIdentity];
                
            }
            else
            {
                dbTimesheetSummaryArray = [approvalsModel getAllPreviousTimesheetDaySummaryFromDBForTimesheet:sheetIdentity];
            }
        }
        else
        {
            [[NSNotificationCenter defaultCenter] removeObserver:tmpTimesheetMainPageController name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:tmpTimesheetMainPageController selector:@selector(recievedTimesheetSummaryData:) name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
            dbTimesheetSummaryArray = [timesheetModel getAllTimesheetDaySummaryFromDBForTimesheet:sheetIdentity];
        }


        if(self.isCurrentTimesheetPeriod)
        {
            int count = 0;
            for (NSDictionary *timesheetSummaryDict in dbTimesheetSummaryArray)
            {
                NSDate *tsEntryDate =[Util convertTimestampFromDBToDate:timesheetSummaryDict[@"timesheetEntryDate"]];
                NSDate *todayDate = [Util convertUTCToLocalDate:[NSDate date]];

                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                [dateFormat setDateFormat:@"dd/MM/yyyy"];
                NSLocale *locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
                [dateFormat setLocale:locale];
                 [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

                NSString *todayDateStr = [dateFormat stringFromDate:todayDate];
                todayDateStr=[todayDateStr stringByAppendingString:@" 00:00:00"];
                [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
                NSDate * currentDate = [dateFormat dateFromString:todayDateStr];

                NSCalendar *cal = [NSCalendar currentCalendar];
                [cal setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

                NSDateComponents *tsEntryDateComponents = [cal components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:tsEntryDate];
                NSDateComponents *todayDateComponents = [cal components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:currentDate];
                if (tsEntryDateComponents.day == todayDateComponents.day)
                {
                    self.timesheetMainPageController.pageControl.currentPage=count;
                    self.timesheetMainPageController.currentlySelectedPage=count;
                    break;
                }

                count++;
            }
        }

        else
        {
            self.timesheetMainPageController.pageControl.currentPage=0;
            self.timesheetMainPageController.currentlySelectedPage=0;
        }

        
        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"isDataCache"]];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"isDataCache"]];
        }

        if([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            [parentDelegate pushToViewController:self.timesheetMainPageController];
        }
        else
        {
            [self.navigationController pushViewController:self.timesheetMainPageController animated:YES];
        }
        
    }

    else if ([widget isEqualToString:EXT_IN_OUT_TIMESHEET_WIDGET])
    {

        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            NSString *updateWhereStr=[NSString stringWithFormat:@"timesheetUri='%@'",sheetIdentity];
            NSString *tableName=@"";
            NSArray *arrayDict=nil;
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {

                arrayDict=[self.approvalsModel getTimeSheetInfoSheetIdentityForPending:sheetIdentity];
                tableName=@"PendingApprovalTimesheets";

            }
            else
            {
                arrayDict=[self.approvalsModel getTimeSheetInfoSheetIdentityForPrevious:sheetIdentity];
                tableName=@"PreviousApprovalTimesheets";
            }
            if ([arrayDict count]>0)
            {
                SQLiteDB *myDB = [SQLiteDB getInstance];
                NSMutableDictionary *updateDataDict=[NSMutableDictionary dictionaryWithDictionary:[arrayDict objectAtIndex:0]];
                [updateDataDict removeObjectForKey:@"timesheetFormat"];
                [updateDataDict setObject:GEN4_EXT_INOUT_TIMESHEET forKey:@"timesheetFormat"];
                [myDB updateTable:tableName data:updateDataDict where:updateWhereStr intoDatabase:@""];

                if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                {
                    [self.approvalsModel updateApprovalTimeentriesFormatForTimesheetWithUri:sheetIdentity withFormat:GEN4_EXT_INOUT_TIMESHEET fromFormat:GEN4_INOUT_TIMESHEET andIsPending:YES];
                }
                else
                {
                    [self.approvalsModel updateApprovalTimeentriesFormatForTimesheetWithUri:sheetIdentity withFormat:GEN4_EXT_INOUT_TIMESHEET fromFormat:GEN4_INOUT_TIMESHEET andIsPending:NO];

                }

            }
        }
        else
        {
            NSString *updateWhereStr=[NSString stringWithFormat:@"timesheetUri='%@'",sheetIdentity];
            NSArray *arrayDict=[self.timesheetModel getTimeSheetInfoSheetIdentity:sheetIdentity];

            if ([arrayDict count]>0)
            {
                SQLiteDB *myDB = [SQLiteDB getInstance];
                NSMutableDictionary *updateDataDict=[NSMutableDictionary dictionaryWithDictionary:[arrayDict objectAtIndex:0]];
                [updateDataDict removeObjectForKey:@"timesheetFormat"];
                [updateDataDict setObject:GEN4_EXT_INOUT_TIMESHEET forKey:@"timesheetFormat"];
                [myDB updateTable: @"timesheets" data:updateDataDict where:updateWhereStr intoDatabase:@""];

                 [self.timesheetModel updateTimeentriesFormatForTimesheetWithUri:sheetIdentity withFormat:GEN4_EXT_INOUT_TIMESHEET fromFormat:GEN4_INOUT_TIMESHEET];


            }
        }



        TimesheetMainPageController *tmpTimesheetMainPageController=[[TimesheetMainPageController alloc]init];
        self.timesheetMainPageController=tmpTimesheetMainPageController;
        self.timesheetMainPageController.timesheetURI=sheetIdentity;
        self.timesheetMainPageController.parentDelegate=parentDelegate;
        self.timesheetMainPageController.trackTimeEntryChangeDelegate=self;
        BOOL isExtendedInOut=YES;
        BOOL isMultiDayInOutTimesheetUser=YES;

        //self.timesheetMainPageController.tsEntryDataArray=currentTimesheetArray;
        self.timesheetMainPageController.pageControl.currentPage=0;
        self.timesheetMainPageController.currentlySelectedPage=0;
        self.timesheetMainPageController.timesheetURI=sheetIdentity;
       if ([self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_TIMESHEETS_MODULE] || [self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            self.timesheetMainPageController.timesheetStatus=APPROVED_STATUS;
        }
        else
        {
            self.timesheetMainPageController.timesheetStatus=self.sheetApprovalStatus;
        }
        if (isExtendedInOut)
        {
            self.timesheetMainPageController.multiDayInOutType=EXTENDED_IN_OUT_TIMESHEET_TYPE;
        }
        else
        {
            self.timesheetMainPageController.multiDayInOutType=NOT_EXTENDED_IN_OUT_TIMESHEET_TYPE;
        }

        self.timesheetMainPageController.isDisclaimerRequired=NO;
        self.timesheetMainPageController.isMultiDayInOutTimesheetUser=isMultiDayInOutTimesheetUser;
        self.timesheetMainPageController.sheetLevelUdfArray=nil;
        self.timesheetMainPageController.hasUserChangedAnyValue=NO;
        self.timesheetMainPageController.timesheetStartDate=timesheetStartDate;
        self.timesheetMainPageController.timesheetEndDate=timesheetEndDate;
        self.timesheetMainPageController.userUri=userUri;
        NSArray *dbTimesheetSummaryArray=nil;
        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            [[NSNotificationCenter defaultCenter] removeObserver:tmpTimesheetMainPageController name:APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:tmpTimesheetMainPageController selector:@selector(recievedTimesheetSummaryData:) name:APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION object:nil];
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                dbTimesheetSummaryArray = [approvalsModel getAllPendingTimesheetDaySummaryFromDBForTimesheet:sheetIdentity];

            }
            else
            {
                dbTimesheetSummaryArray = [approvalsModel getAllPreviousTimesheetDaySummaryFromDBForTimesheet:sheetIdentity];
            }
        }
        else
        {
            [[NSNotificationCenter defaultCenter] removeObserver:tmpTimesheetMainPageController name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:tmpTimesheetMainPageController selector:@selector(recievedTimesheetSummaryData:) name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
            dbTimesheetSummaryArray = [timesheetModel getAllTimesheetDaySummaryFromDBForTimesheet:sheetIdentity];
        }


        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"isDataCache"]];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"isDataCache"]];
        }

        if([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            [parentDelegate pushToViewController:self.timesheetMainPageController];
        }
        else
        {
            [self.navigationController pushViewController:self.timesheetMainPageController animated:YES];
        }

    }

    else if ([widget isEqualToString:TIME_PUNCHES_WIDGET])
    {
        
        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            NSString *updateWhereStr=[NSString stringWithFormat:@"timesheetUri='%@'",sheetIdentity];
            NSString *tableName=@"";
            NSArray *arrayDict=nil;
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                
                arrayDict=[self.approvalsModel getTimeSheetInfoSheetIdentityForPending:sheetIdentity];
                tableName=@"PendingApprovalTimesheets";
                
            }
            else
            {
                arrayDict=[self.approvalsModel getTimeSheetInfoSheetIdentityForPrevious:sheetIdentity];
                tableName=@"PreviousApprovalTimesheets";
            }
            if ([arrayDict count]>0)
            {
                SQLiteDB *myDB = [SQLiteDB getInstance];
                NSMutableDictionary *updateDataDict=[NSMutableDictionary dictionaryWithDictionary:[arrayDict objectAtIndex:0]];
                [updateDataDict removeObjectForKey:@"timesheetFormat"];
                [updateDataDict setObject:GEN4_PUNCH_WIDGET_TIMESHEET forKey:@"timesheetFormat"];
                [myDB updateTable:tableName data:updateDataDict where:updateWhereStr intoDatabase:@""];
                
                
            }
        }
        else
        {
            NSString *updateWhereStr=[NSString stringWithFormat:@"timesheetUri='%@'",sheetIdentity];
            NSArray *arrayDict=[self.timesheetModel getTimeSheetInfoSheetIdentity:sheetIdentity];
            
            if ([arrayDict count]>0)
            {
                SQLiteDB *myDB = [SQLiteDB getInstance];
                NSMutableDictionary *updateDataDict=[NSMutableDictionary dictionaryWithDictionary:[arrayDict objectAtIndex:0]];
                [updateDataDict removeObjectForKey:@"timesheetFormat"];
                [updateDataDict setObject:GEN4_PUNCH_WIDGET_TIMESHEET forKey:@"timesheetFormat"];
                [myDB updateTable: @"timesheets" data:updateDataDict where:updateWhereStr intoDatabase:@""];
                
                
                
            }
        }

        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];

        TeamTimeViewController *teamVC=[appDelegate.injector getInstance:[TeamTimeViewController class]];
        
        
        teamVC.trackTimeEntryChangeDelegate=self;
        teamVC.timesheetStartDate=self.timesheetStartDate;
        teamVC.timesheetEndDate=self.timesheetEndDate;
        teamVC.sheetIdentity=self.sheetIdentity;
        teamVC.sheetApprovalStatus = sheetApprovalStatus;
        SupportDataModel *supportDataModel = [[SupportDataModel alloc] init];
        NSMutableArray *userDetailsArr=[supportDataModel getUserDetailsFromDatabase];
        BOOL isEditPermission=NO;
        if (userDetailsArr!=nil && ![userDetailsArr isKindOfClass:[NSNull class]])
        {
            
            isEditPermission = [[[userDetailsArr objectAtIndex:0] objectForKey:@"canEditTimePunch"]boolValue];
            
        }
        if ([sheetApprovalStatus isEqualToString:NOT_SUBMITTED_STATUS]||
            [sheetApprovalStatus isEqualToString:REJECTED_STATUS])
            
        {
            if (isEditPermission)
            {
                teamVC.isEditable=TRUE;
            }
            else
            {
                teamVC.isEditable=FALSE;
            }
            
        }
        else
        {
            teamVC.isEditable=FALSE;
        }
        if([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            ApprovalsScrollViewController *ctrl=(ApprovalsScrollViewController *)parentDelegate;
            teamVC.approvalsModuleName=self.approvalsModuleName;
            NSMutableDictionary *userDict=[ctrl.listOfPendingItemsArray objectAtIndex: ctrl.indexCount];
            teamVC.approvalsModuleUserUri=[userDict objectForKey:@"userUri"];
            teamVC.isEditable=FALSE;
            [parentDelegate pushToViewController:teamVC];
        }
        else
        {
            [self.navigationController pushViewController:teamVC animated:NO];
        }
        
        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
            {
                [Util showOfflineAlert];
                return;
            }
            BOOL isPending=NO;
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                isPending=YES;
                
            }
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:teamVC name:GEN4_PUNCH_TIMESHEET_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:teamVC selector:@selector(receivedPunchesForTimesheet) name:GEN4_PUNCH_TIMESHEET_NOTIFICATION object:nil];
            
            PunchHistoryModel *punchHistoryModel=[[PunchHistoryModel alloc]init];
            NSMutableArray *punchesArr=[punchHistoryModel getAllPunchesFromDBIsFromWidgetTimesheet:YES approvalsModule:self.approvalsModuleName];
            if ([punchesArr count]>0)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:GEN4_PUNCH_TIMESHEET_NOTIFICATION object:nil];
            }
            else
            {
                [[RepliconServiceManager approvalsService]sendRequestToGetPunchHistoryForTimesheetWithTimesheetUri:sheetIdentity delegate:self isPending:isPending];
            }

            
           
        }
        else
        {
            if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
            {
                [Util showOfflineAlert];
                return;
            }
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:teamVC name:GEN4_PUNCH_TIMESHEET_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:teamVC selector:@selector(receivedPunchesForTimesheet) name:GEN4_PUNCH_TIMESHEET_NOTIFICATION object:nil];
            
            PunchHistoryModel *punchHistoryModel=[[PunchHistoryModel alloc]init];
            NSMutableArray *punchesArr=[punchHistoryModel getAllPunchesFromDBIsFromWidgetTimesheet:YES approvalsModule:nil];
            if ([punchesArr count]>0)
            {
                 [[NSNotificationCenter defaultCenter] postNotificationName:GEN4_PUNCH_TIMESHEET_NOTIFICATION object:nil];
            }
            else
            {
                 [[RepliconServiceManager timesheetService]sendRequestToGetPunchHistoryForTimesheetWithTimesheetUri:sheetIdentity delegate:self];
            }
            
           
        }
        


    }
    
    else if ([widget isEqualToString:STANDARD_TIMESHEET_WIDGET])
    {
        
        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            NSString *updateWhereStr=[NSString stringWithFormat:@"timesheetUri='%@'",sheetIdentity];
            NSString *tableName=@"";
            NSArray *arrayDict=nil;
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                
                arrayDict=[self.approvalsModel getTimeSheetInfoSheetIdentityForPending:sheetIdentity];
                tableName=@"PendingApprovalTimesheets";
                
            }
            else
            {
                arrayDict=[self.approvalsModel getTimeSheetInfoSheetIdentityForPrevious:sheetIdentity];
                tableName=@"PreviousApprovalTimesheets";
            }
            if ([arrayDict count]>0)
            {
                SQLiteDB *myDB = [SQLiteDB getInstance];
                NSMutableDictionary *updateDataDict=[NSMutableDictionary dictionaryWithDictionary:[arrayDict objectAtIndex:0]];
                [updateDataDict removeObjectForKey:@"timesheetFormat"];
                [updateDataDict setObject:GEN4_STANDARD_TIMESHEET forKey:@"timesheetFormat"];
                [myDB updateTable:tableName data:updateDataDict where:updateWhereStr intoDatabase:@""];
                
                
            }
        }
        else
        {
            NSString *updateWhereStr=[NSString stringWithFormat:@"timesheetUri='%@'",sheetIdentity];
            NSArray *arrayDict=[self.timesheetModel getTimeSheetInfoSheetIdentity:sheetIdentity];
            
            if ([arrayDict count]>0)
            {
                SQLiteDB *myDB = [SQLiteDB getInstance];
                NSMutableDictionary *updateDataDict=[NSMutableDictionary dictionaryWithDictionary:[arrayDict objectAtIndex:0]];
                [updateDataDict removeObjectForKey:@"timesheetFormat"];
                [updateDataDict setObject:GEN4_STANDARD_TIMESHEET forKey:@"timesheetFormat"];
                [myDB updateTable: @"timesheets" data:updateDataDict where:updateWhereStr intoDatabase:@""];
                
                
                
            }
        }
        
        
       
        
        TimesheetMainPageController *tmpTimesheetMainPageController=[[TimesheetMainPageController alloc]init];
        self.timesheetMainPageController=tmpTimesheetMainPageController;
        self.timesheetMainPageController.timesheetURI=sheetIdentity;
        self.timesheetMainPageController.parentDelegate=parentDelegate;
        self.timesheetMainPageController.trackTimeEntryChangeDelegate=self;
        BOOL isExtendedInOut=NO;
        BOOL isMultiDayInOutTimesheetUser=NO;
        
        //self.timesheetMainPageController.tsEntryDataArray=currentTimesheetArray;
        self.timesheetMainPageController.pageControl.currentPage=0;
        self.timesheetMainPageController.currentlySelectedPage=0;
        self.timesheetMainPageController.timesheetURI=sheetIdentity;
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_TIMESHEETS_MODULE] || [self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            self.timesheetMainPageController.timesheetStatus=APPROVED_STATUS;
        }
        else
        {
            self.timesheetMainPageController.timesheetStatus=self.sheetApprovalStatus;
        }
        if (isExtendedInOut)
        {
            self.timesheetMainPageController.multiDayInOutType=EXTENDED_IN_OUT_TIMESHEET_TYPE;
        }
        else
        {
            self.timesheetMainPageController.multiDayInOutType=NOT_EXTENDED_IN_OUT_TIMESHEET_TYPE;
        }
        
        self.timesheetMainPageController.isDisclaimerRequired=NO;
        self.timesheetMainPageController.isMultiDayInOutTimesheetUser=isMultiDayInOutTimesheetUser;
        self.timesheetMainPageController.sheetLevelUdfArray=nil;
        self.timesheetMainPageController.hasUserChangedAnyValue=NO;
        self.timesheetMainPageController.timesheetStartDate=timesheetStartDate;
        self.timesheetMainPageController.timesheetEndDate=timesheetEndDate;
        self.timesheetMainPageController.userUri=userUri;
        NSArray *dbTimesheetSummaryArray=nil;
        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            [[NSNotificationCenter defaultCenter] removeObserver:tmpTimesheetMainPageController name:APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:tmpTimesheetMainPageController selector:@selector(recievedTimesheetSummaryData:) name:APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION object:nil];
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                dbTimesheetSummaryArray = [approvalsModel getAllPendingTimesheetDaySummaryFromDBForTimesheet:sheetIdentity];
                
            }
            else
            {
                dbTimesheetSummaryArray = [approvalsModel getAllPreviousTimesheetDaySummaryFromDBForTimesheet:sheetIdentity];
            }
        }
        else
        {
            [[NSNotificationCenter defaultCenter] removeObserver:tmpTimesheetMainPageController name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:tmpTimesheetMainPageController selector:@selector(recievedTimesheetSummaryData:) name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
            dbTimesheetSummaryArray = [timesheetModel getAllTimesheetDaySummaryFromDBForTimesheet:sheetIdentity];
        }
        
        
        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"isDataCache"]];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"isDataCache"]];
        }
        
        if([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            [parentDelegate pushToViewController:self.timesheetMainPageController];
        }
        else
        {
            [self.navigationController pushViewController:self.timesheetMainPageController animated:YES];
        }
        
        
    }

    else if ([widget isEqualToString:DAILY_FIELD_WIDGET])
    {

        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            NSString *updateWhereStr=[NSString stringWithFormat:@"timesheetUri='%@'",sheetIdentity];
            NSString *tableName=@"";
            NSArray *arrayDict=nil;
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {

                arrayDict=[self.approvalsModel getTimeSheetInfoSheetIdentityForPending:sheetIdentity];
                tableName=@"PendingApprovalTimesheets";

            }
            else
            {
                arrayDict=[self.approvalsModel getTimeSheetInfoSheetIdentityForPrevious:sheetIdentity];
                tableName=@"PreviousApprovalTimesheets";
            }
            if ([arrayDict count]>0)
            {
                SQLiteDB *myDB = [SQLiteDB getInstance];
                NSMutableDictionary *updateDataDict=[NSMutableDictionary dictionaryWithDictionary:[arrayDict objectAtIndex:0]];
                [updateDataDict removeObjectForKey:@"timesheetFormat"];
                [updateDataDict setObject:GEN4_DAILY_WIDGET_TIMESHEET forKey:@"timesheetFormat"];
                [myDB updateTable:tableName data:updateDataDict where:updateWhereStr intoDatabase:@""];


            }
        }
        else
        {
            NSString *updateWhereStr=[NSString stringWithFormat:@"timesheetUri='%@'",sheetIdentity];
            NSArray *arrayDict=[self.timesheetModel getTimeSheetInfoSheetIdentity:sheetIdentity];

            if ([arrayDict count]>0)
            {
                SQLiteDB *myDB = [SQLiteDB getInstance];
                NSMutableDictionary *updateDataDict=[NSMutableDictionary dictionaryWithDictionary:[arrayDict objectAtIndex:0]];
                [updateDataDict removeObjectForKey:@"timesheetFormat"];
                [updateDataDict setObject:GEN4_DAILY_WIDGET_TIMESHEET forKey:@"timesheetFormat"];
                [myDB updateTable: @"timesheets" data:updateDataDict where:updateWhereStr intoDatabase:@""];



            }
        }

        TimesheetMainPageController *tmpTimesheetMainPageController=[[TimesheetMainPageController alloc]init];
        self.timesheetMainPageController=tmpTimesheetMainPageController;
        self.timesheetMainPageController.timesheetURI=sheetIdentity;
        self.timesheetMainPageController.parentDelegate=parentDelegate;
        self.timesheetMainPageController.trackTimeEntryChangeDelegate=self;
        BOOL isExtendedInOut=NO;
        BOOL isMultiDayInOutTimesheetUser=NO;

        //self.timesheetMainPageController.tsEntryDataArray=currentTimesheetArray;
        self.timesheetMainPageController.pageControl.currentPage=0;
        self.timesheetMainPageController.currentlySelectedPage=0;
        self.timesheetMainPageController.timesheetURI=sheetIdentity;
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_TIMESHEETS_MODULE] || [self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            self.timesheetMainPageController.timesheetStatus=APPROVED_STATUS;
        }
        else
        {
            self.timesheetMainPageController.timesheetStatus=self.sheetApprovalStatus;
        }
        if (isExtendedInOut)
        {
            self.timesheetMainPageController.multiDayInOutType=EXTENDED_IN_OUT_TIMESHEET_TYPE;
        }
        else
        {
            self.timesheetMainPageController.multiDayInOutType=NOT_EXTENDED_IN_OUT_TIMESHEET_TYPE;
        }

        self.timesheetMainPageController.isDisclaimerRequired=NO;
        self.timesheetMainPageController.isMultiDayInOutTimesheetUser=isMultiDayInOutTimesheetUser;
        self.timesheetMainPageController.sheetLevelUdfArray=nil;
        self.timesheetMainPageController.hasUserChangedAnyValue=NO;
        self.timesheetMainPageController.timesheetStartDate=timesheetStartDate;
        self.timesheetMainPageController.timesheetEndDate=timesheetEndDate;
        self.timesheetMainPageController.userUri=userUri;
        NSArray *dbTimesheetSummaryArray=nil;
        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            [[NSNotificationCenter defaultCenter] removeObserver:tmpTimesheetMainPageController name:APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:tmpTimesheetMainPageController selector:@selector(recievedTimesheetSummaryData:) name:APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION object:nil];
            if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                dbTimesheetSummaryArray = [approvalsModel getAllPendingTimesheetDaySummaryFromDBForTimesheet:sheetIdentity];

            }
            else
            {
                dbTimesheetSummaryArray = [approvalsModel getAllPreviousTimesheetDaySummaryFromDBForTimesheet:sheetIdentity];
            }
        }
        else
        {
            [[NSNotificationCenter defaultCenter] removeObserver:tmpTimesheetMainPageController name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:tmpTimesheetMainPageController selector:@selector(recievedTimesheetSummaryData:) name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
            dbTimesheetSummaryArray = [timesheetModel getAllTimesheetDaySummaryFromDBForTimesheet:sheetIdentity];
        }


        if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"isDataCache"]];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"isDataCache"]];
        }

        if([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            [parentDelegate pushToViewController:self.timesheetMainPageController];
        }
        else
        {
            [self.navigationController pushViewController:self.timesheetMainPageController animated:YES];
        }

    }
    
}


#pragma mark Approval headerview Action
- (void)handleButtonClickForHeaderView:(NSInteger)senderTag
{
    
    if ([parentDelegate respondsToSelector:@selector(handlePreviousNextButtonFromApprovalsListforViewTag:forbuttonTag:)])
    {
        [parentDelegate handlePreviousNextButtonFromApprovalsListforViewTag:currentViewTag forbuttonTag:senderTag];
    }
    
    
}
#pragma mark Approval footerrview Action
- (void)handleButtonClickForFooterView:(NSInteger)senderTag
{
    if ([parentDelegate respondsToSelector:@selector(handleApproveOrRejectActionWithApproverComments:andSenderTag:)])
    {
        [parentDelegate handleApproveOrRejectActionWithApproverComments:self.approverComments andSenderTag:senderTag];
    }
    
}
-(void)resetViewForApprovalsCommentsAction:(BOOL)isReset andComments:(NSString *)approverCommentsStr
{
    self.approverComments=approverCommentsStr;
    if(isReset){
        widgetTableView.scrollEnabled=NO;
        CGRect frame=self.widgetTableView.frame;
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        float aspectRatio=(screenRect.size.height/screenRect.size.width);
        float heightDueToUdf=[customFieldArray count]*Each_Cell_Row_Height_44;
        
        if (aspectRatio<1.7)
        {
            
            self.widgetTableView.contentOffset=CGPointMake(0.0,339+heightofDisclaimerText+heightDueToUdf);
            if (heightofDisclaimerText>0)
            {
                // frame.origin.y=-140;
                frame.origin.y=-204;
            }
            else
                frame.origin.y=-ResetHeightios4;
            
        }
        else
        {
            self.widgetTableView.contentOffset=CGPointMake(0.0,591+heightDueToUdf+heightofDisclaimerText);
            frame.origin.y=-ResetHeightios5;
        }
        
        
        [self.widgetTableView setFrame:frame];
    }
    else{
        widgetTableView.scrollEnabled=YES;
        CGRect frame=self.widgetTableView.frame;
        frame.origin.y=0;
        [self.widgetTableView setFrame:frame];
    }
    
}
#pragma mark Others
-(BOOL)canResubmitTimeSheetForURI:(NSString *)sheetUri
{
    TimesheetModel *timeSheetModel=[[TimesheetModel alloc]init];
    NSArray *approvalDetailsDataArr=[timeSheetModel getAllTimesheetApprovalFromDBForTimesheet:sheetUri];
    
    for (NSDictionary *approvalDetailsDataDict in approvalDetailsDataArr)
    {
        if ([[approvalDetailsDataDict objectForKey:@"actionUri"] isEqualToString:@"urn:replicon:approval-action:submit"])
        {
            return YES;
        }
    }
    
    return NO;
}

/************************************************************************************************************
 @Function Name   : createTableHeader
 @Purpose         : To extend tableview to configure its header
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)createTableHeader
{
    
    //Do Alterations Here for the errors and warnings Widget
     UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    BOOL isErrorsPresent=NO;
    NSMutableArray *errorArray = [NSMutableArray array];
    NSMutableArray *warningArray = [NSMutableArray array];
    NSMutableArray *informationArray = [NSMutableArray array];
    
    for (int index= 0; index<[errorAndWarningsArray count]; index++) {
        if ([errorAndWarningsArray[index] isKindOfClass:[NSDictionary class]])
        {
            if ([errorAndWarningsArray[index][@"severity"] isEqualToString:GEN4_TIMESHEET_ERROR_URI])
            {
                //            if([(NSMutableArray *)[[errorAndWarningsArray objectAtIndex:index] objectForKey:@"keyValues"] count]>0)
                //            {
                [errorArray addObject:[errorAndWarningsArray objectAtIndex:index]];
                //            }
                
            }
            else if ([errorAndWarningsArray[index][@"severity"] isEqualToString:GEN4_TIMESHEET_WARNING_URI])
            {
                //            if([(NSMutableArray *)[[errorAndWarningsArray objectAtIndex:index] objectForKey:@"keyValues"] count]>0)
                [warningArray addObject:[errorAndWarningsArray objectAtIndex:index]];
            }
            else{
                //            if([(NSMutableArray *)[[errorAndWarningsArray objectAtIndex:index] objectForKey:@"keyValues"] count]>0)
                [informationArray addObject:[errorAndWarningsArray objectAtIndex:index]];
            }
        }
    }
    
    
    if ([errorArray count]>0 || [warningArray count]>0 || [informationArray count]>0) {
       
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 43.5, SCREEN_WIDTH, 0.5)];
        [view setBackgroundColor:[UIColor clearColor]]; //your background color...
        UIButton *validationButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        [validationButton setBackgroundColor:[UIColor clearColor]];
        [validationButton addTarget:self action:@selector(goToValidationDataView) forControlEvents:UIControlEventTouchUpInside];
        UILabel *validationCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH, 44)];
        [validationButton setBackgroundColor:[UIColor clearColor]];
        validationCountLabel.textAlignment = NSTextAlignmentLeft;
        [validationCountLabel setFont:[UIFont fontWithName:@"Helvetica Neue Medium" size:RepliconFontSize_15]];
        [validationCountLabel setTextColor:[UIColor whiteColor]];
        validationCountLabel.userInteractionEnabled = NO;
        UIImage *arrowDarkImage = [UIImage imageNamed:@"icon_chevronWhite.png"];
        UIImage *arrowGrayImage = [UIImage imageNamed:@"icon_chevronDark.png"];
        
        UIImageView *arrowImageview= [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-20-arrowDarkImage.size.width, 17, arrowDarkImage.size.width, arrowDarkImage.size.height)];
        
        [arrowImageview setImage:arrowDarkImage];
        
        NSString *countString = @"";
        
        if ([errorArray count]>0) {
            [view setBackgroundColor:[Util colorWithHex:@"#F26A51" alpha:1.0]];
            [bottomView setBackgroundColor:[Util colorWithHex:@"#8E1600" alpha:1.0]];
            if ([errorArray count]>1)
            {
                countString = [countString stringByAppendingString:[NSString stringWithFormat:@"%lu %@",(unsigned long)[errorArray count],RPLocalizedString(ERROR_TEXT, @"")]];

            }
            else
            {
                countString = [countString stringByAppendingString:[NSString stringWithFormat:@"%lu %@",(unsigned long)[errorArray count],RPLocalizedString(ERROR_LABEL_TEXT, @"")]];

            }
        }
        if([warningArray count]>0)
        {
            if ([errorArray count] == 0) {
                [view setBackgroundColor:[Util colorWithHex:@"#FFD200" alpha:1.0]];
                [bottomView setBackgroundColor:[Util colorWithHex:@"#A58700" alpha:1.0]];
                [validationCountLabel setTextColor:[UIColor blackColor]];
                if ([warningArray count]>1)
                {
                    countString = [countString stringByAppendingString:[NSString stringWithFormat:@"%lu %@",(unsigned long)[warningArray count],RPLocalizedString(WARNING_TEXT, @"")]];
                }
                else
                {
                    countString = [countString stringByAppendingString:[NSString stringWithFormat:@"%lu %@",(unsigned long)[warningArray count],RPLocalizedString(WARNING_LABEL_TEXT, @"")]];
                }
                
                [arrowImageview setImage:arrowGrayImage];
            }
            else
            {
                if ([warningArray count]>1)
                {
                    countString = [countString stringByAppendingString:[NSString stringWithFormat:@", %lu %@",(unsigned long)[warningArray count],RPLocalizedString(WARNING_TEXT, @"")]];
                }
                else
                {
                    countString = [countString stringByAppendingString:[NSString stringWithFormat:@", %lu %@",(unsigned long)[warningArray count],RPLocalizedString(WARNING_LABEL_TEXT, @"")]];
                }
                
            }
        }
        if([informationArray count]>0){
            if ([warningArray count] == 0 && [errorArray count] == 0) {
                [view setBackgroundColor:[Util colorWithHex:@"#6891BE" alpha:1.0]];
                [bottomView setBackgroundColor:[Util colorWithHex:@"#35485E" alpha:1.0]];
                countString = [countString stringByAppendingString:[NSString stringWithFormat:@"%lu %@",(unsigned long)[informationArray count],RPLocalizedString(INFORMATION_TEXT, @"")]];
            }
            else
            {
                countString = [countString stringByAppendingString:[NSString stringWithFormat:@", %lu %@",(unsigned long)[informationArray count],RPLocalizedString(INFORMATION_TEXT, @"")]];
            }
        }
        
        [errorAndWarningsArray removeAllObjects];


        
        [errorAndWarningsArray addObject:errorArray];
        [errorAndWarningsArray addObject:warningArray];
        [errorAndWarningsArray addObject:informationArray];
        
        
        [validationButton addSubview:validationCountLabel];
        [validationButton addSubview:arrowImageview];
        [validationButton addSubview:bottomView];
        [validationCountLabel setText:countString];
        [view addSubview:validationButton];
        isErrorsPresent=YES;
        
    }
    else{
        isErrorsPresent=NO;
        
    }
    
    

    if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
    {
        if (isErrorsPresent)
        {
            self.widgetTableView.tableHeaderView = view;
        }
        else
        {
            self.widgetTableView.tableHeaderView = nil;
        }
    }
    else
    {
        //Do Alterations Here for the errors and warnings Widget
        id tmp=nil;
        float height=55;
        if (isErrorsPresent)
        {
            tmp=view;
            height=55+46;
        }
        ApprovalTablesHeaderView *headerView=[[ApprovalTablesHeaderView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, height ) withStatus:sheetApprovalStatus userName:self.userName dateString:self.sheetPeriod labelText:nil withApprovalModuleName:self.approvalsModuleName isWidgetTimesheet:YES withErrorsAndWarningView:tmp];
        ApprovalsScrollViewController *scrollCtrl=(ApprovalsScrollViewController *)parentDelegate;
        if (!scrollCtrl.hasPreviousTimeSheets) {
            headerView.previousButton.hidden=TRUE;
        }
        if (!scrollCtrl.hasNextTimeSheets) {
            headerView.nextButton.hidden=TRUE;
        }
        self.widgetTableView.tableHeaderView = headerView;
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            headerView.countLbl.text=[NSString stringWithFormat:@"%li of %lu",(long)currentNumberOfView,(unsigned long)totalNumberOfView];
        }
        else
        {
            headerView.countLbl.text=@"";
        }
        
        headerView.delegate=self;
        
    }
    
    
}

/************************************************************************************************************
 @Function Name   : createFooter
 @Purpose         : To extend tableview to configure its footer
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)createTableFooter
{
    if (![parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
    {
        UIImage *totalLineImage=[Util thumbnailImage:Cell_HairLine_Image];
        self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                             0.0,
                                                                   totalLineImage.size.width,
                                                                   totalLineImage.size.height)];
        UIImageView *totalLineImageview=[[UIImageView alloc]initWithImage:totalLineImage];
        totalLineImageview.frame=CGRectMake(0.0,
                                            0,
                                            SCREEN_WIDTH,
                                            totalLineImage.size.height);
        
        [totalLineImageview setBackgroundColor:[UIColor clearColor]];
        [totalLineImageview setUserInteractionEnabled:NO];
        [self.footerView addSubview:totalLineImageview];
        [self.widgetTableView setTableFooterView:footerView];
    }
    else
    {
        UIImage *submitBtnImg =[Util thumbnailImage:SubmitTimesheetButtonImage] ;
        UIImage *normalImg = [Util thumbnailImage:LoginButtonImage];
        UIImage *highlightedImg = [Util thumbnailImage:LoginButtonSelectedImage];
        float yOffset=30;
        float footerHeight = yOffset+submitBtnImg.size.height+yOffset;

        UIView *tempfooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                          0.0,
                                                                          self.view.frame.size.width,
                                                                          footerHeight)];
        self.footerView=tempfooterView;
        [footerView setBackgroundColor:[Util colorWithHex:@"#DADADA" alpha:1]];
        
        UIImage *totalLineImage=[Util thumbnailImage:Cell_HairLine_Image];
        UIImageView *totalLineImageview=[[UIImageView alloc]initWithImage:totalLineImage];
        totalLineImageview.frame=CGRectMake(0.0,
                                            footerHeight,
                                            SCREEN_WIDTH,
                                            totalLineImage.size.height);
        
        [totalLineImageview setBackgroundColor:[UIColor clearColor]];
        [totalLineImageview setUserInteractionEnabled:NO];
        [self.footerView addSubview:totalLineImageview];
        
        SupportDataModel *supportDataModel=[[SupportDataModel alloc]init];
        NSDictionary *permittedApprovalAcionsDict=[supportDataModel getTimesheetPermittedApprovalActionsDataToDBWithUri:sheetIdentity];
        
        BOOL canSubmit=FALSE;
        BOOL canUnsubmit=FALSE;
        BOOL canReopen=FALSE;
        BOOL canOfflineSubmit=FALSE;
        BOOL canOfflineReSubmit=FALSE;


        BOOL hasPendingOperationsOnTimesheet = NO;
        NSMutableArray *pendingOperations = [self.timesheetModel getPendingOperationsArr:sheetIdentity];
        if (pendingOperations.count>0)
        {
            if ([pendingOperations containsObject:TIMESHEET_SUBMIT_OPERATION] || [pendingOperations containsObject:TIMESHEET_RESUBMIT_OPERATION])
            {
                hasPendingOperationsOnTimesheet = YES;
            }

        }

        if (permittedApprovalAcionsDict!=nil &&  ![permittedApprovalAcionsDict isKindOfClass:[NSNull class]])
        {
            if([permittedApprovalAcionsDict objectForKey:@"canSubmit"]!=nil && ![[permittedApprovalAcionsDict objectForKey:@"canSubmit"] isKindOfClass:[NSNull class]])
            {
                canSubmit=[[permittedApprovalAcionsDict objectForKey:@"canSubmit"]boolValue];
            }
            if([permittedApprovalAcionsDict objectForKey:@"canUnsubmit"]!=nil && ![[permittedApprovalAcionsDict objectForKey:@"canUnsubmit"] isKindOfClass:[NSNull class]])
            {
                canUnsubmit=[[permittedApprovalAcionsDict objectForKey:@"canUnsubmit"]boolValue];
            }
            if([permittedApprovalAcionsDict objectForKey:@"canReopen"]!=nil && ![[permittedApprovalAcionsDict objectForKey:@"canReopen"] isKindOfClass:[NSNull class]])
            {
                canReopen=[[permittedApprovalAcionsDict objectForKey:@"canReopen"]boolValue];
            }
            BOOL isGen4Timesheet=NO;
            NSArray *timesheetInfoArray=[timesheetModel getTimeSheetInfoSheetIdentity:sheetIdentity];
            if ([timesheetInfoArray count]>0)
            {
                NSString *tsFormat=[[timesheetInfoArray objectAtIndex:0] objectForKey:@"timesheetFormat"];
                 if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
                {
                    if([tsFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [tsFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET] ||  [tsFormat isEqualToString:GEN4_STANDARD_TIMESHEET] ||  [tsFormat isEqualToString:GEN4_PUNCH_WIDGET_TIMESHEET] ||  [tsFormat isEqualToString:GEN4_DAILY_WIDGET_TIMESHEET])
                    {
                        isGen4Timesheet=YES;
                    }
                }
            }
            if (isGen4Timesheet)
            {
                if ([sheetApprovalStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION ]||[sheetApprovalStatus isEqualToString:TIMESHEET_SUBMITTED ])
                {
                    canReopen=YES;
                    canSubmit=NO;
                    canUnsubmit=NO;
                }
                else
                {
                    NSArray *timesheetsArr = [self.timesheetModel getTimeSheetInfoSheetIdentity:self.sheetIdentity];
                    if ([timesheetsArr count]>0)
                    {
                        NSString *operationData=[[timesheetsArr objectAtIndex:0]objectForKey:@"operations"];
                        NSMutableArray *operationArr=nil;
                        if (operationData ==nil || [operationData isKindOfClass:[NSNull class]])
                        {
                            operationArr=[NSMutableArray array];
                        }
                        else
                        {
                            operationArr=[NSMutableArray arrayWithArray:[operationData componentsSeparatedByString:@"|"]];
                        }
                        NSString *operationName=@"";
                        if ([operationArr count]>0)
                        {
                            operationName=[operationArr lastObject];
                        }
                        if ([operationName isEqualToString:TIMESHEET_REOPEN_OPERATION])
                        {
                            
                            NSMutableArray *arrayFromDB=[self.timesheetModel getAllTimesheetApprovalFromDBForTimesheet:self.sheetIdentity];
                            
                            if ([arrayFromDB count]>0 && arrayFromDB!=nil)
                            {
                                NSString *status=[[arrayFromDB lastObject]objectForKey:@"actionUri"];
                                if ([status isEqualToString:Submit_Action_URI])
                                {
                                    canReopen=NO;
                                    canSubmit=NO;
                                    canUnsubmit=NO;
                                    canOfflineSubmit=NO;
                                    canOfflineReSubmit=YES;
                                }
                            }
                            else
                            {
                                canReopen=NO;
                                canSubmit=NO;
                                canUnsubmit=NO;
                                canOfflineSubmit=YES;
                                canOfflineReSubmit=NO;
                            }
                        }
                    }
                }
            }
        }
        if ((canSubmit||canUnsubmit||canReopen|| canOfflineReSubmit || canOfflineSubmit))
        {
            UIButton *submitButton =[UIButton buttonWithType:UIButtonTypeCustom];
            [submitButton setFrame:CGRectMake((SCREEN_WIDTH-submitBtnImg.size.width)/2,yOffset, submitBtnImg.size.width, submitBtnImg.size.height)];
            [submitButton setBackgroundImage:normalImg forState:UIControlStateNormal];
            [submitButton setBackgroundImage:highlightedImg forState:UIControlStateHighlighted];
            [submitButton setAccessibilityLabel:@"widget_timesheet_submit_btn"];

            if(canSubmit)
            {
                BOOL canResubmit=[self canResubmitTimeSheetForURI:self.sheetIdentity];
                if (canResubmit)
                {
                    [submitButton setTitle:RPLocalizedString(Resubmit_Button_title, @"")  forState:UIControlStateNormal];
                    [submitButton addTarget:self action:@selector(reSubmitAction:) forControlEvents:UIControlEventTouchUpInside];
                    self.actionType=@"Re-Submit";
                }
                else
                {
                    [submitButton setTitle:RPLocalizedString(Submit_Button_title, @"")  forState:UIControlStateNormal];
                    [submitButton addTarget:self action:@selector(submitAction:) forControlEvents:UIControlEventTouchUpInside];
                    self.actionType=@"Submit";
                }
            }
            else if((canUnsubmit || canReopen) && !hasPendingOperationsOnTimesheet)
            {
                [submitButton setTitle:RPLocalizedString(Reopen_Button_title, @"")  forState:UIControlStateNormal];
                [submitButton addTarget:self action:@selector(unSubmitAction:) forControlEvents:UIControlEventTouchUpInside];
                self.actionType=@"Unsubmit";
            }
            else if(canOfflineSubmit)
            {
                [submitButton setTitle:RPLocalizedString(Submit_Button_title, @"")  forState:UIControlStateNormal];
                [submitButton addTarget:self action:@selector(submitAction:) forControlEvents:UIControlEventTouchUpInside];
                self.actionType=@"Submit";
            }
            else if(canOfflineReSubmit)
            {
                [submitButton setTitle:RPLocalizedString(Resubmit_Button_title, @"")  forState:UIControlStateNormal];
                [submitButton addTarget:self action:@selector(reSubmitAction:) forControlEvents:UIControlEventTouchUpInside];
                self.actionType=@"Re-Submit";
            }
            [submitButton setTitleColor:RepliconStandardWhiteColor forState:UIControlStateNormal];
            submitButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            [footerView addSubview:submitButton];
        }
        BOOL shoulShowFooterView = (canSubmit||((canUnsubmit||canReopen) && !hasPendingOperationsOnTimesheet)|| canOfflineReSubmit || canOfflineSubmit);
        if (shoulShowFooterView)
            [self.widgetTableView setTableFooterView:footerView];
    }
}


-(void)submitAction:(id)sender
{
    CLS_LOG(@"-----Submit button clicked on WidgetTSViewController-----");
    
//     [self.timesheetModel updateTimesheetWithOperationName:TIMESHEET_SUBMIT_OPERATION andTimesheetURI:self.sheetIdentity];
//    
//    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//    [appDelegate startTimesheetSync];

    if ([self.userWidgetsArray containsObject:ATTESTATION_WIDGET_URI])
    {
        if (self.isAttestationSelected)
        {
            [self submitActionCompletion];
        }
        else
        {
            [Util errorAlert:@"" errorMessage:RPLocalizedString(ATTESTATION_NOT_SELECTED_ALERT_MSG, @"")];
        }

    }
    else
    {
        [self submitActionCompletion];
    }

}

-(void)submitActionCompletion
{
    NSString *timesheetFormat=[self.timesheetModel getTimesheetFormatforTimesheetUri:sheetIdentity];
    if (timesheetFormat!=nil &&![timesheetFormat isKindOfClass:[NSNull class]])
    {

        NSMutableArray *enableWidgetsArr=[timesheetModel getAllEnabledWidgetsUriDetailsFromDBForTimesheetUri:sheetIdentity];
        for (NSDictionary *enableWidgetDict in enableWidgetsArr)
        {
            NSString *widgetUri = enableWidgetDict[@"widgetUri"];
            if ([widgetUri isEqualToString:INOUT_WIDGET_URI])
            {
                timesheetFormat=GEN4_INOUT_TIMESHEET;
                break;

            }
        }

        if([[NetworkMonitor sharedInstance] networkAvailable] == NO||[timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET])
        {
            [self.timesheetModel updateTimesheetWithOperationName:TIMESHEET_SUBMIT_OPERATION andTimesheetURI:sheetIdentity];
            [self.timesheetModel updateAttestationStatusForTimesheetIdentity:sheetIdentity withStatus:YES];

            SQLiteDB *myDB = [SQLiteDB getInstance];
            NSMutableDictionary *dataDict=[NSMutableDictionary dictionary];
            [dataDict setObject:TIMESHEET_PENDING_SUBMISSION forKey:@"approvalStatus" ];
            [dataDict setObject:sheetApprovalStatus forKey:@"lastKnownApprovalStatus"];
            [dataDict setObject:[NSNumber numberWithInt:0]  forKey:@"canEditTimesheet" ];
            [myDB updateTable:@"Timesheets" data:dataDict where:[NSString stringWithFormat:@"timesheetUri='%@'",sheetIdentity] intoDatabase:@""];

            AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
            [[appDelegate.injector getInstance:[BaseSyncOperationManager class]] startSync];
            [self.navigationController popViewControllerAnimated:YES];
        }

        else
        {
            [self syncPendingQueueForTimesheetWithUri:self.sheetIdentity];
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
            [self callServiceWithName:WIDGET_TIMESHEET_SUBMIT_SERVICE andTimeSheetURI:self.sheetIdentity];
        }

    }




}

-(void)unSubmitAction:(id)sender
{
    
     CLS_LOG(@"-----Reopen button clicked on WidgetTSViewController-----");
    
    
   
//    [self.timesheetModel updateTimesheetWithOperationName:TIMESHEET_REOPEN_OPERATION andTimesheetURI:self.sheetIdentity];
    
//    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//    [appDelegate startTimesheetSync];
    
    if ([[NetworkMonitor sharedInstance] networkAvailable] == NO)
    {
        
        [Util showOfflineAlert];
    }
    else
    {

        [self syncPendingQueueForTimesheetWithUri:self.sheetIdentity];
        
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
        [self callServiceWithName:WIDGET_TIMESHEET_REOPEN_SERVICE andTimeSheetURI:self.sheetIdentity];
        
    }
    
    
    
}


-(void)reSubmitAction:(id)sender
{
    CLS_LOG(@"-----Resubmit button clicked on CurrentTimesheetViewController-----");


    if ([self.userWidgetsArray containsObject:ATTESTATION_WIDGET_URI])
    {
        if (self.isAttestationSelected)
        {
            [self reSubmitActionCompletion];
        }
        else
        {
            [Util errorAlert:@"" errorMessage:RPLocalizedString(ATTESTATION_NOT_SELECTED_ALERT_MSG, @"")];
        }

    }
    else
    {
        [self reSubmitActionCompletion];
    }
    
}

-(void)reSubmitActionCompletion
{
    NSMutableArray *arrayOfEntriesForSave=[self getArrayOfTimeEntryObjectsFromAllTheEntriesFromDB];
    ApprovalActionsViewController *approvalActionsViewController = [[ApprovalActionsViewController alloc] init];
    [approvalActionsViewController setIsDisclaimerRequired:NO];
    [approvalActionsViewController setSheetIdentity:self.sheetIdentity];
    [approvalActionsViewController setSelectedSheet:self.selectedSheet];
    [approvalActionsViewController setAllowBlankComments:YES];
    [approvalActionsViewController setActionType:@"Re-Submit"];
    [approvalActionsViewController setDelegate:self];
    [approvalActionsViewController setIsMultiDayInOutTimesheetUser:YES];
    [approvalActionsViewController setTimesheetLevelUdfArray:nil];
    [approvalActionsViewController setArrayOfEntriesForSave:arrayOfEntriesForSave];
    [approvalActionsViewController setIsExtendedInoutUser:NO];
    [approvalActionsViewController setHasAttestationWidgetPermission:self.hasAttestationPermission];
    [approvalActionsViewController setIsAttestationSelected:self.isAttestationSelected];
    [self.navigationController pushViewController:approvalActionsViewController animated:YES];
}

-(NSMutableArray *)getArrayOfTimeEntryObjectsFromAllTheEntriesFromDB
{
    
    NSMutableArray *timeEntriesArray=nil;
    BOOL isExtendedInOut=NO;
    BOOL isMultiDayInOutTimesheetUser=YES;
    if (isExtendedInOut)
    {
        timeEntriesArray=[timesheetModel getAllExtendedTimeEntriesForSheetFromDB:sheetIdentity];
    }
    else
    {
        timeEntriesArray=[timesheetModel getAllTimeEntriesForSheetFromDB:sheetIdentity];
    }
    NSMutableArray *arrayOfTimeEntriesObjectsForSave=[NSMutableArray array];
    
    for (int i=0; i<[timeEntriesArray count]; i++)
    {
        
        NSMutableDictionary *dict=dict=[timeEntriesArray objectAtIndex:i];
        NSString *timesheetEntryDate=[dict objectForKey:@"timesheetEntryDate"];
        NSString *timePunchesUri=[dict objectForKey:@"timePunchesUri"];
        NSString *timeAllocationUri=[dict objectForKey:@"timeAllocationUri"];
        NSString *activityName=[dict objectForKey:@"activityName"];
        NSString *activityUri=[dict objectForKey:@"activityUri"];
        NSString *billingName=[dict objectForKey:@"billingName"];
        NSString *billingUri=[dict objectForKey:@"billingUri"];
        NSString *projectName=[dict objectForKey:@"projectName"];
        NSString *projectUri=[dict objectForKey:@"projectUri"];
        NSString *taskName=[dict objectForKey:@"taskName"];
        NSString *taskUri=[dict objectForKey:@"taskUri"];
        NSString *timeoffName=[dict objectForKey:@"timeOffTypeName"];
        NSString *timeoffUri=[dict objectForKey:@"timeOffUri"];
        NSString *entryType=[dict objectForKey:@"entryType"];
        NSString *comments=[dict objectForKey:@"comments"];
        NSString *durationDecimalFormat=[dict objectForKey:@"durationDecimalFormat"];
        NSString *durationHourFormat=[dict objectForKey:@"durationHourFormat"];
        NSString *time_in=[dict objectForKey:@"time_in"];
        NSString *time_out=[dict objectForKey:@"time_out"];
        NSString *rowUri=[dict objectForKey:@"rowUri"];
        NSMutableArray *timePunchesArr=nil;
        //Implentation for US8956//JUHI
        NSString *breakName=[dict objectForKey:@"breakName"];
        NSString *breakUri=[dict objectForKey:@"breakUri"];
        NSString *rowNumber=[dict objectForKey:@"rowNumber"];
        
        if (isExtendedInOut)
        {
            NSString *key=nil;
           
            BOOL isProjectAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:sheetIdentity];
            BOOL isActivityAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:sheetIdentity];
            
            
            if (isProjectAccess)
            {
                key=projectUri;
                
            }
            else if (isActivityAccess)
            {
                key=activityUri;
                
            }
            timePunchesArr=[dict objectForKey:key];
        }
        
        
        
        if (isMultiDayInOutTimesheetUser)
        {
            TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc] init];
            NSMutableDictionary *multiDayInOutDict=[NSMutableDictionary dictionary];
            
            if (time_in!=nil && ![time_in isKindOfClass:[NSNull class]])
            {
                [multiDayInOutDict setObject:[time_in lowercaseString] forKey:@"in_time"];
            }
            else
            {
                [multiDayInOutDict setObject:@"" forKey:@"in_time"];
            }
            
            if (time_out!=nil && ![time_out isKindOfClass:[NSNull class]])
            {
                [multiDayInOutDict setObject:[time_out lowercaseString] forKey:@"out_time"];
            }
            else
            {
                [multiDayInOutDict setObject:@"" forKey:@"out_time"];
            }
            
            NSDate *tmpDate = [Util convertTimestampFromDBToDate:timesheetEntryDate];
            NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
            myDateFormatter.dateFormat = @"EEEE, dd MMM yyyy";
            
            NSLocale *locale=[NSLocale currentLocale];
            [myDateFormatter setLocale:locale];
            [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [myDateFormatter setDateFormat:@"EEEE, dd MMM yyyy"];
            NSDate *todayDate=[myDateFormatter dateFromString:[myDateFormatter stringFromDate:tmpDate]];
            
            
            NSMutableArray *tempUDF=nil;
            
            if (timeoffName!=nil && (![timeoffName isKindOfClass:[NSNull class]] && ![timeoffName isEqualToString:@""]))
            {
                if ([entryType isEqualToString:Time_Off_Key])
                {
                    [tsEntryObject setEntryType:Time_Off_Key];
                }
                else
                {
                    [tsEntryObject setEntryType:Adhoc_Time_OffKey];
                }
                tempUDF=[self getUDFArrayForModuleName:TIMEOFF_UDF andEntryDate:todayDate andEntryType:entryType andRowUri:timeAllocationUri];
                [tsEntryObject setIsTimeoffSickRowPresent:YES];
                [tsEntryObject setTimeAllocationUri:timeAllocationUri];
                [tsEntryObject setTimeEntryHoursInDecimalFormat:[Util getRoundedValueFromDecimalPlaces: [[dict objectForKey:@"durationDecimalFormat"] newDoubleValue ]withDecimalPlaces:2 ]];
            }
            else
            {
                tempUDF=[self getUDFArrayForModuleName:TIMESHEET_CELL_UDF andEntryDate:todayDate andEntryType:entryType andRowUri:timePunchesUri];
                
                [tsEntryObject setEntryType:Time_Entry_Key];
                [tsEntryObject setIsTimeoffSickRowPresent:NO];
                [tsEntryObject setTimePunchUri:timePunchesUri];
                [tsEntryObject setTimeEntryHoursInDecimalFormat:[Util getNumberOfHoursForInTime:time_in outTime:time_out]];
            }
            
            
            NSMutableArray *udfArray=[[NSMutableArray alloc]init];
            for (int i=0; i<[tempUDF count]; i++)
            {
                NSDictionary *udfDict = [tempUDF objectAtIndex: i];
                NSString *udfType=[udfDict objectForKey:@"type"];
                NSString *udfName=[udfDict objectForKey:@"name"];
                NSString *udfUri=[udfDict objectForKey:@"uri"];
                
                if ([udfType isEqualToString:TEXT_UDF_TYPE])
                {
                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                    NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
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
                    int defaultDecimalValue=[udfDict objectForKey:@"defaultDecimalValue"] ? [[udfDict objectForKey:@"defaultDecimalValue"] intValue] : 0;
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
                    if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])
                    {
                        defaultValue=RPLocalizedString(NONE_STRING, @"");
                    }
                    else{
                        NSDate *date=(NSDate *)[udfDict objectForKey:@"defaultValue"];
                        defaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:date]];
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
                    
                    
                    ;
                }
                else if([udfType isEqualToString:DROPDOWN_UDF_TYPE])
                {
                    //NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                    NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                    NSString *dropDownOptionUri=[udfDict objectForKey:@"dropDownOptionUri"];
                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                    [udfDetails setFieldName:udfName];
                    [udfDetails setFieldType:UDFType_DROPDOWN];
                    [udfDetails setFieldValue:defaultValue];
                    [udfDetails setUdfIdentity:udfUri];
                    [udfDetails setDropdownOptionUri:dropDownOptionUri];
                    [udfDetails setSystemDefaultValue:dropDownOptionUri];
                    [udfArray addObject:udfDetails];
                    
                }
                
                
                
                
            }
            
            if (isExtendedInOut)
            {
                for (int j=0; j<[timePunchesArr count]; j++)
                {
                    NSString *timePunchesUri=[[timePunchesArr objectAtIndex:j] objectForKey:@"timePunchesUri"];
                    NSMutableArray *tempCellUDF=[self getUDFArrayForModuleName:TIMESHEET_CELL_UDF andEntryDate:todayDate andEntryType:entryType andRowUri:timePunchesUri];
                    
                    NSMutableArray *udfCellArray=[[NSMutableArray alloc]init];
                    for (int i=0; i<[tempCellUDF count]; i++)
                    {
                        NSDictionary *udfDict = [tempCellUDF objectAtIndex: i];
                        NSString *udfType=[udfDict objectForKey:@"type"];
                        NSString *udfName=[udfDict objectForKey:@"name"];
                        NSString *udfUri=[udfDict objectForKey:@"uri"];
                        
                        if ([udfType isEqualToString:TEXT_UDF_TYPE])
                        {
                            NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                            NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                            EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                            [udfDetails setFieldName:udfName];
                            [udfDetails setFieldType:UDFType_TEXT];
                            [udfDetails setFieldValue:defaultValue];
                            [udfDetails setUdfIdentity:udfUri];
                            [udfDetails setSystemDefaultValue:systemDefaultValue];
                            [udfCellArray addObject:udfDetails];
                            
                            
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
                            int defaultDecimalValue=[udfDict objectForKey:@"defaultDecimalValue"] ? [[udfDict objectForKey:@"defaultDecimalValue"] intValue] : 0;
                            EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                            [udfDetails setFieldName:udfName];
                            [udfDetails setFieldType:UDFType_NUMERIC];
                            [udfDetails setFieldValue:defaultValue];
                            [udfDetails setUdfIdentity:udfUri];
                            [udfDetails setDecimalPoints:defaultDecimalValue];
                            [udfDetails setSystemDefaultValue:systemDefaultValue];
                            [udfCellArray addObject:udfDetails];
                            
                            
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
                                NSDate *date=(NSDate *)[udfDict objectForKey:@"defaultValue"];
                                defaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:date]];
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
                            [udfCellArray addObject:udfDetails];
                            
                            
                        }
                        else if([udfType isEqualToString:DROPDOWN_UDF_TYPE])
                        {
                            //NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                            NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                            NSString *dropDownOptionUri=[udfDict objectForKey:@"dropDownOptionUri"];
                            EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                            [udfDetails setFieldName:udfName];
                            [udfDetails setFieldType:UDFType_DROPDOWN];
                            [udfDetails setFieldValue:defaultValue];
                            [udfDetails setUdfIdentity:udfUri];
                            [udfDetails setDropdownOptionUri:dropDownOptionUri];
                            [udfDetails setSystemDefaultValue:dropDownOptionUri];
                            [udfCellArray addObject:udfDetails];
                            
                        }
                        
                        
                        
                        
                    }
                    
                    [[timePunchesArr objectAtIndex:j] setObject:udfCellArray forKey:@"udfArray"];
                    
                }
                [tsEntryObject setTimePunchesArray:timePunchesArr];
            }
            [tsEntryObject setTimeEntryDate:todayDate];
            [tsEntryObject setTimeEntryActivityName:activityName];
            [tsEntryObject setTimeEntryActivityUri:activityUri];
            [tsEntryObject setTimeEntryBillingName:billingName];
            [tsEntryObject setTimeEntryBillingUri:billingUri];
            [tsEntryObject setTimeEntryProjectName:projectName];
            [tsEntryObject setTimeEntryProjectUri:projectUri];
            [tsEntryObject setTimeEntryTaskName:taskName];
            [tsEntryObject setTimeEntryTaskUri:taskUri];
            [tsEntryObject setTimeEntryTimeOffName:timeoffName];
            [tsEntryObject setTimeEntryTimeOffUri:timeoffUri];
            [tsEntryObject setTimeEntryComments:comments];
            [tsEntryObject setTimeEntryHoursInHourFormat:durationHourFormat];
            [tsEntryObject setMultiDayInOutEntry:multiDayInOutDict];
            [tsEntryObject setTimeEntryUdfArray:udfArray];
            [tsEntryObject setTimesheetUri:sheetIdentity];
            //Implentation for US8956//JUHI
            [tsEntryObject setBreakName:breakName];
            [tsEntryObject setBreakUri:breakUri];
            [tsEntryObject setRownumber:rowNumber];
            [arrayOfTimeEntriesObjectsForSave addObject:tsEntryObject];
            
            
        }
        else
        {
            TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc] init];
            NSDate *tmpDate = [Util convertTimestampFromDBToDate:timesheetEntryDate];
            NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
            myDateFormatter.dateFormat = @"EEEE, dd MMM yyyy";
            
            NSLocale *locale=[NSLocale currentLocale];
            [myDateFormatter setLocale:locale];
            [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [myDateFormatter setDateFormat:@"EEEE, dd MMM yyyy"];
            NSDate *todayDate=[myDateFormatter dateFromString:[myDateFormatter stringFromDate:tmpDate]];
            
            
            NSMutableDictionary *multiDayInOutDict=[NSMutableDictionary dictionary];
            
            
            NSMutableArray *tempUDF=nil;
            NSMutableArray *tempRowCustomFieldArray=nil;//Implementation for US9371//JUHI
            if (timeoffName!=nil && (![timeoffName isKindOfClass:[NSNull class]] && ![timeoffName isEqualToString:@""]))
            {
                if ([entryType isEqualToString:Time_Off_Key])
                {
                    [tsEntryObject setEntryType:Time_Off_Key];
                }
                else
                {
                    [tsEntryObject setEntryType:Adhoc_Time_OffKey];
                }
                tempUDF=[self getUDFArrayForModuleName:TIMEOFF_UDF andEntryDate:todayDate andEntryType:entryType andRowUri:rowUri];
                [tsEntryObject setIsTimeoffSickRowPresent:YES];
                [tsEntryObject setTimeEntryTimeOffName:timeoffName];
                [tsEntryObject setTimeEntryTimeOffUri:timeoffUri];
                [tsEntryObject setTimeEntryProjectName:@""];
                [tsEntryObject setTimeEntryProjectUri:@""];
            }
            else
            {
                if ([entryType isEqualToString:Time_Entry_Key])
                {
                    tempUDF=[self getUDFArrayForModuleName:TIMESHEET_CELL_UDF andEntryDate:todayDate andEntryType:entryType andRowUri:rowUri];
                    tempRowCustomFieldArray=[self getUDFArrayForModuleName:TIMESHEET_ROW_UDF andEntryDate:todayDate andEntryType:entryType andRowUri:rowUri];//Implementation for US9371//JUHI
                    [tsEntryObject setIsTimeoffSickRowPresent:NO];
                    [tsEntryObject setTimeEntryTimeOffName:@""];
                    [tsEntryObject setTimeEntryTimeOffUri:@""];
                    [tsEntryObject setTimeEntryProjectName:projectName];
                    [tsEntryObject setTimeEntryProjectUri:projectUri];
                }
            }
            
            
            
            
            
            
            
            NSMutableArray *udfArray=[[NSMutableArray alloc]init];
            for (int i=0; i<[tempUDF count]; i++)
            {
                NSDictionary *udfDict = [tempUDF objectAtIndex: i];
                NSString *udfType=[udfDict objectForKey:@"type"];
                NSString *udfName=[udfDict objectForKey:@"name"];
                NSString *udfUri=[udfDict objectForKey:@"uri"];
                
                if ([udfType isEqualToString:TEXT_UDF_TYPE])
                {
                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                    NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
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
                    int defaultDecimalValue=[udfDict objectForKey:@"defaultDecimalValue"] ? [[udfDict objectForKey:@"defaultDecimalValue"] intValue] : 0;
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
                    if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])
                    {
                        defaultValue=RPLocalizedString(NONE_STRING, @"");
                    }
                    else{
                        NSDate *date=(NSDate *)[udfDict objectForKey:@"defaultValue"];
                        defaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:date]];
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
                    
                    
                    ;
                }
                else if([udfType isEqualToString:DROPDOWN_UDF_TYPE])
                {
                    //NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                    NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                    NSString *dropDownOptionUri=[udfDict objectForKey:@"dropDownOptionUri"];
                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                    [udfDetails setFieldName:udfName];
                    [udfDetails setFieldType:UDFType_DROPDOWN];
                    [udfDetails setFieldValue:defaultValue];
                    [udfDetails setUdfIdentity:udfUri];
                    [udfDetails setDropdownOptionUri:dropDownOptionUri];
                    [udfDetails setSystemDefaultValue:dropDownOptionUri];
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
                    if (([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])||([tempDefaultValue isKindOfClass:[NSString class]]&& [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]))
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
                    //NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                    NSString *dropDownOptionUri=[udfDict objectForKey:@"dropDownOptionUri"];
                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                    [udfDetails setFieldName:udfName];
                    [udfDetails setFieldType:UDFType_DROPDOWN];
                    [udfDetails setFieldValue:defaultValue];
                    [udfDetails setUdfIdentity:udfUri];
                    [udfDetails setDropdownOptionUri:dropDownOptionUri];
                    [udfDetails setSystemDefaultValue:dropDownOptionUri];
                    [rowUdfArray addObject:udfDetails];
                    
                }
                
                
                
                
            }
            
            
            if (timeoffName!=nil && timeoffUri !=nil && ![timeoffUri isKindOfClass:[NSNull class]] &&![timeoffName isKindOfClass:[NSNull class]] && ![timeoffName isEqualToString:@""]&& ![timeoffUri isEqualToString:@""])
            {
                if ([entryType isEqualToString:Time_Off_Key])
                {
                    [tsEntryObject setEntryType:Time_Off_Key];
                }
                else
                {
                    [tsEntryObject setEntryType:Adhoc_Time_OffKey];
                }
                
                [tsEntryObject setIsTimeoffSickRowPresent:YES];
                [tsEntryObject setTimeEntryTimeOffName:timeoffName];
                [tsEntryObject setTimeEntryTimeOffUri:timeoffUri];
                [tsEntryObject setTimeEntryProjectName:@""];
                [tsEntryObject setTimeEntryProjectUri:@""];
            }
            else
            {
                [tsEntryObject setIsTimeoffSickRowPresent:NO];
                [tsEntryObject setTimeEntryTimeOffName:@""];
                [tsEntryObject setTimeEntryTimeOffUri:@""];
                [tsEntryObject setTimeEntryProjectName:projectName];
                [tsEntryObject setTimeEntryProjectUri:projectUri];
            }
            [tsEntryObject setTimeEntryComments:comments];
            [tsEntryObject setTimeEntryUdfArray:udfArray];
            [tsEntryObject setTimeEntryDate:todayDate];
            [tsEntryObject setMultiDayInOutEntry:multiDayInOutDict];
            [tsEntryObject setTimeAllocationUri:@""];
            [tsEntryObject setTimePunchUri:@""];
            [tsEntryObject setTimeEntryHoursInHourFormat:@""];
            [tsEntryObject setTimeEntryHoursInDecimalFormat:[Util getRoundedValueFromDecimalPlaces: [durationDecimalFormat newDoubleValue ]withDecimalPlaces:2 ]];
            [tsEntryObject setTimeEntryActivityName:activityName];
            [tsEntryObject setTimeEntryActivityUri:activityUri];
            [tsEntryObject setTimeEntryBillingName:billingName];
            [tsEntryObject setTimeEntryBillingUri:billingUri];
            [tsEntryObject setTimeEntryTaskName:taskName];
            [tsEntryObject setTimeEntryTaskUri:taskUri];
            [tsEntryObject setTimesheetUri:sheetIdentity];
            [tsEntryObject setRowUri:rowUri];
            [tsEntryObject setTimeEntryRowUdfArray:rowUdfArray];//Implementation for US9371//JUHI
            [tsEntryObject setRownumber:rowNumber];
            [arrayOfTimeEntriesObjectsForSave addObject:tsEntryObject];
            
        }
        
    }
    
    
    return arrayOfTimeEntriesObjectsForSave;
}
-(NSMutableArray *)getUDFArrayForModuleName:(NSString *)moduleName andEntryDate:(NSDate *)entryDate andEntryType:(NSString *)entryType andRowUri:(NSString *)rowUri
{
    NSMutableArray *customUserFieldArray=[NSMutableArray array];
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
            
            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[sheetApprovalStatus isEqualToString:APPROVED_STATUS] || [sheetApprovalStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION ] ||[sheetApprovalStatus isEqualToString:TIMESHEET_SUBMITTED ]) {
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
            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[sheetApprovalStatus isEqualToString:APPROVED_STATUS] || [sheetApprovalStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION ] ||[sheetApprovalStatus isEqualToString:TIMESHEET_SUBMITTED ]) {
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
            
            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[sheetApprovalStatus isEqualToString:APPROVED_STATUS] || [sheetApprovalStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION ] ||[sheetApprovalStatus isEqualToString:TIMESHEET_SUBMITTED ]) {
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
                        if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[sheetApprovalStatus isEqualToString:APPROVED_STATUS] || [sheetApprovalStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION ] ||[sheetApprovalStatus isEqualToString:TIMESHEET_SUBMITTED ]) {
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
                    if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[sheetApprovalStatus isEqualToString:APPROVED_STATUS] || [sheetApprovalStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION ] ||[sheetApprovalStatus isEqualToString:TIMESHEET_SUBMITTED ]) {
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
            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[sheetApprovalStatus isEqualToString:APPROVED_STATUS] || [sheetApprovalStatus isEqualToString:TIMESHEET_PENDING_SUBMISSION ] ||[sheetApprovalStatus isEqualToString:TIMESHEET_SUBMITTED ]) {
                [dictInfo setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
            }
            else
                [dictInfo setObject:RPLocalizedString(SELECT_STRING, @"") forKey:@"defaultValue"];
            if ([udfDict objectForKey:@"textDefaultValue"]!=nil &&![[udfDict objectForKey:@"textDefaultValue"]isKindOfClass:[NSNull class]])
            {
                if (![[udfDict objectForKey:@"textDefaultValue"] isEqualToString:@""])
                {
                    [dictInfo setObject:[udfDict objectForKey:@"textDefaultValue"] forKey:@"systemDefaultValue"];
                    [dictInfo setObject:[udfDict objectForKey:@"textDefaultValue"] forKey:@"defaultValue"];
                    [dictInfo setObject:[udfDict objectForKey:@"dropDownOptionDefaultURI"] forKey:@"dropDownOptionUri"];
                    
                }
            }
        }
        NSString *entryDateTimestamp=[NSString stringWithFormat:@"%f",[Util convertDateToTimestamp:entryDate]];
        
        
        //Implementation for US9371//JUHI
        NSArray *selectedudfArray=nil;
        if ([moduleName isEqualToString:TIMESHEET_ROW_UDF])
        {
            selectedudfArray=[timesheetModel getTimesheetSheetCustomFieldsForSheetURI:sheetIdentity moduleName:moduleName andUdfURI:[dictInfo objectForKey: @"identity"]andRowUri:rowUri];
        }
        else
            selectedudfArray=[timesheetModel getTimesheetSheetUdfInfoForSheetURI:sheetIdentity moduleName:moduleName andUdfURI:[dictInfo objectForKey: @"identity"] entryDate:entryDateTimestamp andRowUri:rowUri];
        
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
                        
                        [udfDetailDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
                        
                        
                    }
                    
                }
                else
                {
                    
                    [udfDetailDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
                    
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
                
                [customUserFieldArray addObject:udfDetailDict];
                
            }
        }
        else{
            NSMutableDictionary *udfDetailDict=[[NSMutableDictionary alloc]init];
            
            [udfDetailDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
            
            
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
            [customUserFieldArray addObject:udfDetailDict];
            
            
        }
        
    }
    return customUserFieldArray;
}



-(void)popToListOfTimeSheetsFromActionType:(NSString *)buttonActionType
{
    
    [self.navigationController popToRootViewControllerAnimated:TRUE];

    
}





-(void)goToValidationDataView
{
    TimesheetValidationViewController *obj_TimesheetValidationViewController = [[TimesheetValidationViewController alloc] init];
    obj_TimesheetValidationViewController.dataArray = errorAndWarningsArray;
    obj_TimesheetValidationViewController.selectedSheet = selectedSheet;
    if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
    {
        ApprovalsScrollViewController *scrl=(ApprovalsScrollViewController *)parentDelegate;
        [scrl pushToViewController:obj_TimesheetValidationViewController];
    }
    else
    {
        [self.navigationController pushViewController:obj_TimesheetValidationViewController animated:YES];
    }
    
    
}

-(void)handleErrorsAndWarningsHeaderAction:(NSInteger)senderTag
{
    [self goToValidationDataView];
}

-(void)showMessageLabel
{
    self.widgetTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    BOOL isExtendedInOut=NO;
    UILabel *msgLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, HeightOfNoTOMsgLabel)];
    //Implemetation for ExtendedInOut
    if (isExtendedInOut)
    {
        msgLabel.frame=CGRectMake(12, 110, self.view.frame.size.width-15, 120);
        if ([parentDelegate isKindOfClass:[ListOfTimeSheetsViewController class]])
        {
            msgLabel.text=RPLocalizedString(EXTENDED_INOUT_ERRORMSG, @"");
        }
        else if([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
        {
            msgLabel.text=RPLocalizedString(EXTENDED_INOUT_APPROVAL_PENDING_PREVIOUS_MSG, @"");
        }
        msgLabel.numberOfLines=10;
    }
    else{
        msgLabel.text=RPLocalizedString(APPROVAL_TIMESHEET_NOT_WAITINGFORAPPROVAL, @"");
        msgLabel.numberOfLines=2;
    }
    msgLabel.backgroundColor=[UIColor clearColor];
    
    msgLabel.textAlignment=NSTextAlignmentCenter;
    msgLabel.font=[UIFont fontWithName:RepliconFontFamily size:16];
    [self.view addSubview:msgLabel];
    
    
}

-(void)setDescription:(NSString *)_description
{
    self.approverComments=_description;
}
-(void)refreshClicked:(id)sender
{
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        return;
        
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDataReceived:) name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
    [[RepliconServiceManager timesheetService]fetchTimeSheetSummaryDataForTimesheet:sheetIdentity withDelegate:self];
}

-(void)refreshDataReceived:(NSNotification *)notification
{
    self.sheetApprovalStatus=[self.timesheetModel getTimesheetApprovalStatusForTimesheetIdentity:sheetIdentity];
    id validationDict=[[notification userInfo] objectForKey:@"widgetTimesheetValidationResult"];
    if (validationDict!=nil && ![validationDict isKindOfClass:[NSNull class]])
    {
        self.errorAndWarningsArray=[[[notification userInfo] objectForKey:@"widgetTimesheetValidationResult"] objectForKey:@"validationMessages"];
    }
    //[timesheetModel deleteTimeEntriesFromDBForForTimesheetIdentity:sheetIdentity];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [self.widgetTableView removeFromSuperview];
    [self refreshView];
    [self sendValidationCheckRequestOnlyOnChange];
}

-(void)sendValidationCheckRequestOnlyOnChange
{
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        //[Util showOfflineAlert];
        return;
        
    }
    [self addActiVityIndicator];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GEN4_TIMESHEET_VALIDATION_DATA_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(validationDataReceived:) name:GEN4_TIMESHEET_VALIDATION_DATA_NOTIFICATION object:nil];
    [[RepliconServiceManager timesheetService]sendRequestToGetValidationDataForTimesheet:sheetIdentity];
}
-(void)validationDataReceived:(NSNotification *)notification
{
    [self removeActiVityIndicator];
    id validationDict=[[[notification userInfo] objectForKey:@"response"] objectForKey:@"d"];
    if (validationDict!=nil && ![validationDict isKindOfClass:[NSNull class]])
    {
        self.errorAndWarningsArray=[validationDict objectForKey:@"validationMessages"];
    }
    else
    {
        self.errorAndWarningsArray=[NSMutableArray array];
    }
    [self createTableHeader];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GEN4_TIMESHEET_VALIDATION_DATA_NOTIFICATION object:nil];

}

-(void)addActiVityIndicator
{
    
    if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
    {
        ApprovalsScrollViewController *scrollViewCtrl=(ApprovalsScrollViewController *)parentDelegate;
        [scrollViewCtrl addActiVityIndicator];
    }
    else
    {
        [self.activityView removeFromSuperview];
        self.activityView=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self.activityView setFrame:CGRectMake(0, 0, 30, 30)];
        [self.activityView setBackgroundColor:[UIColor clearColor]];
        UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:self.activityView];
        self.navigationItem.rightBarButtonItem = item;
        [self.activityView startAnimating];
    }
    
    
}

-(void)removeActiVityIndicator
{
    if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
    {
        ApprovalsScrollViewController *scrollViewCtrl=(ApprovalsScrollViewController *)parentDelegate;
        [scrollViewCtrl removeActiVityIndicator];
        
    }
    else
    {
        [self.activityView removeFromSuperview];
        [self shouldShowRefreshButton];
        [self.activityView stopAnimating];
        
    }
}

-(void)serviceFailureWithServiceID:(int)serviceID
{
    NSLog(@"Failed SERVICE ID:%d",serviceID);
    if (serviceID==GetGen4TimesheetValidationData_Service_ID_137)
    {
        [self removeActiVityIndicator];
    }
}

-(void)compareAfterReceivedBackgroundTimesheetSummaryData:(id)responseObj
{
    
    NSMutableDictionary *widgetTimesheetResponse=[responseObj objectForKey:@"d"];
    if (widgetTimesheetResponse!=nil && ![widgetTimesheetResponse isKindOfClass:[NSNull class]])
    {
        NSMutableDictionary *responseDict=[NSMutableDictionary dictionaryWithDictionary:widgetTimesheetResponse];
        NSMutableDictionary *validationResultDict=[NSMutableDictionary dictionaryWithDictionary:[responseDict objectForKey:@"widgetTimesheetValidationResult"]];
        
        
        if (validationResultDict!=nil && ![validationResultDict isKindOfClass:[NSNull class]])
        {
            self.errorAndWarningsArray=[[[responseDict objectForKey:@"widgetTimesheetValidationResult"] objectForKey:@"validationMessages"]mutableCopy];
        }
        
        [validationResultDict removeObjectForKey:@"validationTime"];
        [responseDict setObject:validationResultDict forKey:@"widgetTimesheetValidationResult"];
        
        
        [responseDict removeObjectForKey:@"permittedApprovalActions"];
        
        
        SQLiteDB *myDB = [SQLiteDB getInstance];
        NSMutableArray* returnedArr=[myDB executeQueryToConvertUnicodeValues:[NSString stringWithFormat:@"SELECT CachedData from TimesheetSummaryCachedData Where timesheetUri='%@'",sheetIdentity]];
        BOOL isDataChanged=NO;
        if ([returnedArr count]>0)
        {
            NSDictionary *dict=[returnedArr objectAtIndex:0];
            id value=[dict objectForKey:@"CachedData"];
            NSDictionary* cachedObjectDict = [NSKeyedUnarchiver unarchiveObjectWithData:value];
            if (![cachedObjectDict isEqualToDictionary:responseDict]) {
                
                isDataChanged=YES;

                [UIAlertView showAlertViewWithCancelButtonTitle:nil
                                               otherButtonTitle:RPLocalizedString(@"OK", @"OK")
                                                       delegate:self
                                                        message:RPLocalizedString( @"New data is available.Please refresh your timesheet",@"")
                                                          title:@""
                                                            tag:1010];
            }
            
        }
        
        [myDB insertTimesheetSummaryDictionary:widgetTimesheetResponse withURI:sheetIdentity];
        if (isDataChanged)
        {
            [[RepliconServiceManager timesheetService] handleTimesheetsSummaryFetchData:[NSMutableDictionary dictionaryWithObject:responseObj forKey:@"response"] isFromSave:NO];
            
            if (self.timesheetMainPageController)
            {
                [self.timesheetMainPageController recievedTimesheetSummaryData:nil];
            }
            
           
            
            
        }
        
       
        
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0 && alertView.tag==1010)
    {
        self.sheetApprovalStatus=[self.timesheetModel getTimesheetApprovalStatusForTimesheetIdentity:sheetIdentity];
        [self.widgetTableView removeFromSuperview];
        [self refreshView];
    }
}


-(void)callServiceWithName:(ServiceName)_serviceName andTimeSheetURI:(NSString *)timeSheetURI
{
   
    
    if (_serviceName==WIDGET_TIMESHEET_SUBMIT_SERVICE)
    {
        
        AFHTTPRequestOperation *operation = [[RepliconServiceManager timesheetRequest]sendRequestToSubmitWidgetTimesheetWithTimesheetURI:timeSheetURI comments:@"" hasAttestationPermission:self.hasAttestationPermission andAttestationStatus:self.isAttestationSelected];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received for URL::::: %@ ",operation.request.URL] forLogLevel:LoggerCocoaLumberjack];

            CLS_LOG(@"Response Received for URL::::: %@ ",operation.request.URL);

            [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received ::::: %@",operation.responseString] forLogLevel:LoggerCocoaLumberjack];

            CLS_LOG(@"Response Received ::::: %@",operation.responseString);
            NSDictionary *errorDict = [responseObject objectForKey:@"error"];
            if (errorDict == nil) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                    [[RepliconServiceManager timesheetService] handleTimesheetsSummaryFetchData:[NSMutableDictionary dictionaryWithObject:responseObject forKey:@"response"] isFromSave:YES];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_TIMEENTRIES_DB_DATA object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"isDataCache"]];
                    
                     [self popToListOfTimeSheetsFromActionType:@"Submit"];
                    
                     [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                    
                });
            }
            else
            {
                // server response error
                BOOL showExceptionMessage= [[ResponseHandler sharedResponseHandler] checkForExceptions:errorDict serviceURL:[[AppProperties getInstance] getServiceURLFor:@"Gen4SubmitTimesheetData"]];
                if (!showExceptionMessage)
                {
                    [[ResponseHandler sharedResponseHandler] handleServerResponseError:errorDict serviceURL:[[AppProperties getInstance] getServiceURLFor:@"Gen4SubmitTimesheetData"]];
                }
                [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Failed ::::: %@ ",[error description]] forLogLevel:LoggerCocoaLumberjack];

             CLS_LOG(@"Response Failed ::::: %@ ",[error description]);

             [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received ::::: %@",operation.responseString] forLogLevel:LoggerCocoaLumberjack];

             CLS_LOG(@"Response Received ::::: %@ ",operation.responseString);

             NSDictionary *errorDict = [[operation responseObject] objectForKey:@"error"];
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
    else if (_serviceName==WIDGET_TIMESHEET_REOPEN_SERVICE)
    {
        AFHTTPRequestOperation *operation = [[RepliconServiceManager timesheetRequest]sendRequestToReopenWidgetTimesheetWithTimesheetURI:timeSheetURI comments:nil];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received for URL::::: %@ ",operation.request.URL] forLogLevel:LoggerCocoaLumberjack];

            CLS_LOG(@"Response Received for URL::::: %@ ",operation.request.URL);

            [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received ::::: %@",operation.responseString] forLogLevel:LoggerCocoaLumberjack];

            CLS_LOG(@"Response Received ::::: %@",operation.responseString);

            NSDictionary *errorDict = [responseObject objectForKey:@"error"];
            if (errorDict == nil) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                    [[RepliconServiceManager timesheetService] handleTimesheetsSummaryFetchData:[NSMutableDictionary dictionaryWithObject:responseObject forKey:@"response"] isFromSave:NO];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:REFRESH_TIMEENTRIES_DB_DATA object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"isDataCache"]];
                    
                    [self popToListOfTimeSheetsFromActionType:@"Unsubmit"];
                    
                      [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                    
                });
            }
            else
            {
                // server response error
                BOOL showExceptionMessage= [[ResponseHandler sharedResponseHandler] checkForExceptions:errorDict serviceURL:[[AppProperties getInstance] getServiceURLFor:@"Gen4UnSubmitTimesheetData"]];
                if (!showExceptionMessage)
                {
                    [[ResponseHandler sharedResponseHandler] handleServerResponseError:errorDict serviceURL:[[AppProperties getInstance] getServiceURLFor:@"Gen4UnSubmitTimesheetData"]];
                }
                 [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Failed ::::: %@ ",[error description]] forLogLevel:LoggerCocoaLumberjack];

             CLS_LOG(@"Response Failed ::::: %@ ",[error description]);

             [LogUtil logLoggingInfo:[NSString stringWithFormat:@"Response Received ::::: %@",operation.responseString] forLogLevel:LoggerCocoaLumberjack];

             CLS_LOG(@"Response Received ::::: %@ ",operation.responseString);

             NSDictionary *errorDict = [[operation responseObject] objectForKey:@"error"];
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
    
}

-(void)dealloc
{
    self.widgetTableView.delegate = nil;
    self.widgetTableView.dataSource = nil;
}

- (CGFloat)heightForTableView
{
    static CGFloat paddingForLastCellBottomSeparatorFudgeFactor = 2.0f;
    
     CGFloat paddingForTabBarFactor = 0.0f;
    
    if ([parentDelegate isKindOfClass:[ApprovalsScrollViewController class]])
    {
        if ([self.approvalsModuleName isEqualToString:APPROVALS_PREVIOUS_TIMESHEETS_MODULE])
        {
            paddingForTabBarFactor = -100.0f;
        }
        
    }
    
    
    return CGRectGetHeight([[UIScreen mainScreen] bounds]) -
    (CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) +
     CGRectGetHeight(self.navigationController.navigationBar.frame) +
     CGRectGetHeight(self.tabBarController.tabBar.frame)) +
    paddingForLastCellBottomSeparatorFudgeFactor + paddingForTabBarFactor;
}

- (void)widgetAttestationCell:(WidgetAttestationCell *)widgetAttestationCell isAttestationAccepted:(BOOL)isAttestationAccepted
{
    self.isAttestationSelected=isAttestationAccepted;
}

-(void)syncPendingQueueForTimesheetWithUri:(NSString *)timesheetUri
{
    TimesheetModel *tsModel=[[TimesheetModel alloc]init];
    NSArray *enabledWidgetsUriArray=enabledWidgetsUriArray=[tsModel getAllSupportedAndNotSupportedWidgetsForTimesheetUri:self.sheetIdentity];

    NSString *tsFormat=@"";

    for (NSDictionary *enabledWidgetsDict in enabledWidgetsUriArray)
    {


        if ([enabledWidgetsDict[@"widgetUri"] isEqualToString:STANDARD_WIDGET_URI])
        {
            tsFormat=GEN4_STANDARD_TIMESHEET;
        }
        else if ([enabledWidgetsDict[@"widgetUri"] isEqualToString:INOUT_WIDGET_URI])
        {
            tsFormat=GEN4_INOUT_TIMESHEET;
            break;
        }
        else if ([enabledWidgetsDict[@"widgetUri"] isEqualToString:EXT_INOUT_WIDGET_URI])
        {
            tsFormat=GEN4_EXT_INOUT_TIMESHEET;
        }
        else if ([enabledWidgetsDict[@"widgetUri"] isEqualToString:PUNCH_WIDGET_URI])
        {
            tsFormat=GEN4_PUNCH_WIDGET_TIMESHEET;
        }
    }

    if([tsFormat isEqualToString:GEN4_INOUT_TIMESHEET])
    {
        AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        [[appDelegate.injector getInstance:[BaseSyncOperationManager class]] startSync];
    }
}

- (void)checkForDeeplinkAndNavigate{
    if(self.isFromDeepLink){
        for (NSString *widget in @[IN_OUT_TIMESHEET_WIDGET,
                                   EXT_IN_OUT_TIMESHEET_WIDGET,
                                   STANDARD_TIMESHEET_WIDGET,
                                   TIME_PUNCHES_WIDGET]){
            NSUInteger index = [self.userWidgetsArray indexOfObject:widget];
            if(index != NSNotFound){
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self.widgetTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                    [self tableView:self.widgetTableView didSelectRowAtIndexPath:indexPath];
                });
                break;
            }
        }
        self.isFromDeepLink = NO;
    }
}

@end
