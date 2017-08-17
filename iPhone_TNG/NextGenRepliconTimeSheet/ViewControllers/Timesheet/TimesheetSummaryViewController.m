//
//  TimesheetSummaryViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 21/12/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "TimesheetSummaryViewController.h"
#import "Constants.h"
#import "TimesheetObject.h"
#import "Util.h"
#import "CurrentTimeSheetsCellView.h"
#import "TimesheetModel.h"
#import "LoginModel.h"
#import "TimeEntryViewController.h"
#import "AppDelegate.h"
#import "CurrentTimesheetViewController.h"
#import "TimesheetApprovalHistoryObject.h"
#import "ApprovalsScrollViewController.h"
#import "TimesheetNavigationController.h"
#import "ExpensesNavigationController.h"
#import "BookedTimeOffNavigationController.h"
#import "AttendanceNavigationController.h"
#import "PunchHistoryNavigationController.h"
#import "ShiftsNavigationController.h"
#import "ApprovalsNavigationController.h"
#import "TeamTimeNavigationController.h"
#import "SupervisorDashboardNavigationController.h"

@implementation TimesheetSummaryViewController
@synthesize timesheetSummaryTableView;
@synthesize footerView;
@synthesize projectArray;
@synthesize payrollArray;
@synthesize billingArray;
@synthesize totalHours;
@synthesize approvalArray;
@synthesize sheetIdentity;
@synthesize sectionArray;
@synthesize activityArray;
@synthesize navcontroller;
@synthesize delegate;

#define Each_Cell_Row_Height_44 44
#define spaceHeight 320
#define Count 25

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:NO];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    [self createFooter];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:RepliconStandardBackgroundColor];
	//[self.navigationController.navigationBar setTintColor:RepliconStandardNavBarTintColor];
    
    UIViewController *controllerViewCtrl=(UIViewController *)delegate;
    //Approval context Flow for Timesheets
    if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
        
        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)delegate;
        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            if (sheetIdentity!=nil && ![sheetIdentity isKindOfClass:[NSNull class]])
            {
                ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
                isProjectAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:sheetIdentity];
                isActivityAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:sheetIdentity];
                
            }
        }
        else
        {
            if (sheetIdentity!=nil && ![sheetIdentity isKindOfClass:[NSNull class]])
            {
                ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
                isProjectAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:sheetIdentity];
                isActivityAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:sheetIdentity];
                
            }
        }
        

    }
    //users context Flow for Timesheets
    else if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
    {
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        isProjectAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:sheetIdentity];
    
        isActivityAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:sheetIdentity];

        

        
    }
    
    if (isProjectAccess)
        [self createProjectList];
    else if (!isProjectAccess && isActivityAccess)
    {
        [self createActivityList] ;
    }
    [self createPayrollList];
    [self createBillingList];
    [self createApprovalList];
    
    [Util setToolbarLabel:self withText:RPLocalizedString(TIMESHEETSUMMARY_TITLE, TIMESHEETSUMMARY_TITLE)  ];
    
        sectionArray=[[NSMutableArray alloc]init];
    if ([projectArray count]!=0)
    {
        [self.sectionArray addObject:projectArray];
    }
    if ([activityArray count]!=0)
    {
        [self.sectionArray addObject:activityArray];
    }
    if ([payrollArray count]!=0)
    {
        [self.sectionArray addObject:payrollArray];
    }
    if ([billingArray count]!=0)
    {
        [self.sectionArray addObject:billingArray];
    }
    
    if ([projectArray count]==0 && [activityArray count]==0 && [payrollArray count]==0 && [billingArray count]==0 && [self.approvalArray count]==0)
    {
        
    }
    else
    {
        self.timesheetSummaryTableView=[[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
        self.timesheetSummaryTableView.frame=CGRectMake(0,0 ,self.view.frame.size.width,[self heightForTableView]);
        self.timesheetSummaryTableView.delegate=self;
        self.timesheetSummaryTableView.dataSource=self;
        [self.view addSubview: self.timesheetSummaryTableView];
        
        UIView *bckView = [UIView new];
        [bckView setBackgroundColor:RepliconStandardBackgroundColor];
        [ self.timesheetSummaryTableView setBackgroundView:bckView];
    }
    
    
	
   
 //   [self createFooter];
    
    UIBarButtonItem *tempButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(DAY_BTN_TITLE, DAY_BTN_TITLE)  style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(dayAction:)];
    [self.navigationItem setRightBarButtonItem:tempButtonOuterBtn animated:NO];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
}

-(void)createProjectList{
   
    projectArray=[[NSMutableArray alloc]init];
    NSMutableArray *arrayFromDB=nil;
    UIViewController *controllerViewCtrl=(UIViewController *)delegate;
    //Approval context Flow for Timesheets
    if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
        
        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)delegate;
        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
            arrayFromDB=[approvalModel getAllPendingTimesheetProjectSummaryFromDBForTimesheet:sheetIdentity];
            
        }
        else
        {
            ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
            arrayFromDB=[approvalModel getAllPreviousTimesheetProjectSummaryFromDBForTimesheet:sheetIdentity];
           
        }
        
        
    }
    //users context Flow for Timesheets
    else if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
    {
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        arrayFromDB=[timesheetModel getAllTimesheetProjectSummaryFromDBForTimesheet:sheetIdentity];
        
    }
    
    
    if ([arrayFromDB count]>0 && arrayFromDB!=nil)
    {
        for (int i=0; i<[arrayFromDB count]; i++)
        {
            NSDictionary *dataDic=[arrayFromDB objectAtIndex:i];
            TimesheetObject *timesheetObj=[[TimesheetObject alloc]init];
            [timesheetObj setTimesheetURI:[dataDic objectForKey:@"timesheetUri"]];
            [timesheetObj setProjectIdentity:[dataDic objectForKey:@"projectUri"]];
            [timesheetObj setProjectName:[dataDic objectForKey:@"projectName"]];
            [timesheetObj setNumberOfHours:[Util getRoundedValueFromDecimalPlaces: [[dataDic objectForKey:@"projectDurationDecimal"]newDoubleValue] withDecimalPlaces:2]];
            
            [self.projectArray addObject:timesheetObj];
            
            
            
        }
    }
    
}
-(void)createActivityList
{
    NSMutableArray *tempActivityArray=[[NSMutableArray alloc]init];
    self.activityArray=tempActivityArray;
    

    NSMutableArray *arrayFromDB=nil;
    UIViewController *controllerViewCtrl=(UIViewController *)delegate;
    //Approval context Flow for Timesheets
    if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
        
        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)delegate;
        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
            arrayFromDB=[approvalModel getAllPendingTimesheetActivitySummaryFromDBForTimesheet:sheetIdentity];
            
        }
        else
        {
            ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
            arrayFromDB=[approvalModel getAllPreviousTimesheetActivitySummaryFromDBForTimesheet:sheetIdentity];
           
        }
        
    }
    //users context Flow for Timesheets
    else if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
    {
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        arrayFromDB=[timesheetModel getAllTimesheetActivitySummaryFromDBForTimesheet:sheetIdentity];
       
        
    }
    
    if ([arrayFromDB count]>0 && arrayFromDB!=nil)
    {
        for (int i=0; i<[arrayFromDB count]; i++)
        {
            NSDictionary *dataDic=[arrayFromDB objectAtIndex:i];
            TimesheetObject *timesheetObj=[[TimesheetObject alloc]init];
            [timesheetObj setTimesheetURI:[dataDic objectForKey:@"timesheetUri"]];
            [timesheetObj setActivityIdentity:[dataDic objectForKey:@"activityUri"]];
            [timesheetObj setActivityName:[dataDic objectForKey:@"activityName"]];
            [timesheetObj setNumberOfHours:[Util getRoundedValueFromDecimalPlaces: [[dataDic objectForKey:@"activityDurationDecimal"]newDoubleValue]withDecimalPlaces:2 ]];
            
            [self.activityArray addObject:timesheetObj];
            
            
            
        }
    }
    
}
-(void)createPayrollList{
    
    NSMutableArray *tempPayrollArray=[[NSMutableArray alloc]init];
    self.payrollArray=tempPayrollArray;
    
    
    NSMutableArray *arrayFromDB=nil;
    UIViewController *controllerViewCtrl=(UIViewController *)delegate;
    //Approval context Flow for Timesheets
    if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
        
        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)delegate;
        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
            arrayFromDB=[approvalModel getAllPendingTimesheetPayrollSummaryFromDBForTimesheet:sheetIdentity];
            
        }
        else
        {
            ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
            arrayFromDB=[approvalModel getAllPreviousTimesheetPayrollSummaryFromDBForTimesheet:sheetIdentity];
            
        }
        
        
    }
    //users context Flow for Timesheets
    else if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
    {
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        arrayFromDB=[timesheetModel getAllTimesheetPayrollSummaryFromDBForTimesheet:sheetIdentity];
        
        
    }

    if ([arrayFromDB count]>0 && arrayFromDB!=nil)
    {
        for (int i=0; i<[arrayFromDB count]; i++)
        {
            NSDictionary *dataDic=[arrayFromDB objectAtIndex:i];
            TimesheetObject *timesheetObj=[[TimesheetObject alloc]init];
            [timesheetObj setTimesheetURI:[dataDic objectForKey:@"timesheetUri"]];
            [timesheetObj setPayrollIdentity:[dataDic objectForKey:@"payrollUri"]];
            [timesheetObj setPayrollName:[dataDic objectForKey:@"payrollName"]];
            [timesheetObj setNumberOfHours:[Util getRoundedValueFromDecimalPlaces: [[dataDic objectForKey:@"payrollDurationDecimal"]newDoubleValue] withDecimalPlaces:2]];
            
            [self.payrollArray addObject:timesheetObj];
            
            
            
        }

    }
    
}
-(void)createBillingList
{
    NSMutableArray *tempBillingArray=[[NSMutableArray alloc]init];
    self.billingArray=tempBillingArray;
   
   
    NSMutableArray *arrayFromDB=nil;
    UIViewController *controllerViewCtrl=(UIViewController *)delegate;
    //Approval context Flow for Timesheets
    if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
        
        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)delegate;
        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
            arrayFromDB=[approvalModel getAllPendingTimesheetBillingSummaryFromDBForTimesheet:sheetIdentity];
            
        }
        else
        {
            ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
            arrayFromDB=[approvalModel getAllPreviousTimesheetBillingSummaryFromDBForTimesheet:sheetIdentity];
           
        }
        
    }
    //users context Flow for Timesheets
    else if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
    {
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        arrayFromDB=[timesheetModel getAllTimesheetBillingSummaryFromDBForTimesheet:sheetIdentity];
        
    }
    
    if ([arrayFromDB count]>0 && arrayFromDB!=nil)
    {
        for (int i=0; i<[arrayFromDB count]; i++)
        {
            NSDictionary *dataDic=[arrayFromDB objectAtIndex:i];
            TimesheetObject *timesheetObj=[[TimesheetObject alloc]init];
            [timesheetObj setTimesheetURI:[dataDic objectForKey:@"timesheetUri"]];
            [timesheetObj setBillingIdentity:[dataDic objectForKey:@"billingUri"]];
            [timesheetObj setBillingName:[dataDic objectForKey:@"billingName"]];
            [timesheetObj setNumberOfHours:[Util getRoundedValueFromDecimalPlaces: [[dataDic objectForKey:@"billingDurationDecimal"] doubleValue ]withDecimalPlaces:2 ]];
            
            [self.billingArray addObject:timesheetObj];
            
            
            
        }
    }
    
}
-(void)createApprovalList{
    
    NSMutableArray *tempApprovalArray=[[NSMutableArray alloc]init];
    self.approvalArray=tempApprovalArray;
    
    
    NSMutableArray *arrayFromDB=nil;
    UIViewController *controllerViewCtrl=(UIViewController *)delegate;
    //Approval context Flow for Timesheets
    if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
        
        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)delegate;
        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
            arrayFromDB=[approvalModel getAllPendingTimesheetApprovalFromDBForTimesheet:sheetIdentity];
            
        }
        else
        {
            ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
            arrayFromDB=[approvalModel getAllPreviousTimesheetApprovalFromDBForTimesheet:sheetIdentity];
            
        }
        
    }
    //users context Flow for Timesheets
    else if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
    {
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        arrayFromDB=[timesheetModel getAllTimesheetApprovalFromDBForTimesheet:sheetIdentity];
        
    }
    
    if ([arrayFromDB count]>0 && arrayFromDB!=nil)
    {
        for (int i=0; i<[arrayFromDB count]; i++)
        {
            NSDictionary *dataDic=[arrayFromDB objectAtIndex:i];
            TimesheetApprovalHistoryObject *timesheetObj=[[TimesheetApprovalHistoryObject alloc]init];
            [timesheetObj setApprovalTimesheetURI:[dataDic objectForKey:@"timesheetUri"]];
            [timesheetObj setApprovalActionStatus:[dataDic objectForKey:@"actionStatus"]];
            NSDate *entryDate=[Util convertTimestampFromDBToDate:[[dataDic objectForKey:@"actionDate"] stringValue]];
            NSDate *entryDateInLocalTime=[Util convertUTCToLocalDate:entryDate];
            [timesheetObj setApprovalActionDate:entryDateInLocalTime ];
            
            [approvalArray addObject:timesheetObj];
            
            
            
        }
    }
    
}
#pragma mark -
#pragma mark - UITableView Delegates
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section==0)
    {
        if (isProjectAccess)
        {
            if ([projectArray count]>0)
            {
                if (indexPath.row==[self.projectArray count])
                {
                    [cell setBackgroundColor:TimesheetTotalHoursBackgroundColor];
                }
                else
                    [cell setBackgroundColor:RepliconStandardBackgroundColor];
            }
            else
                [cell setBackgroundColor:RepliconStandardBackgroundColor];
        }
        else if (isActivityAccess && !isProjectAccess)
        {
            if ([activityArray count]>0) {
                if (indexPath.row==[self.activityArray count])
                {
                    [cell setBackgroundColor:TimesheetTotalHoursBackgroundColor];
                }
                else
                    [cell setBackgroundColor:RepliconStandardBackgroundColor];
            }
            else
                [cell setBackgroundColor:RepliconStandardBackgroundColor];
            
        }
        else if([payrollArray count]>0)
        {
            if (indexPath.row==[self.payrollArray count])
            {
                [cell setBackgroundColor:TimesheetTotalHoursBackgroundColor];
                
            }
            else
                [cell setBackgroundColor:RepliconStandardBackgroundColor];
        }
        else if ([billingArray count]>0){
            if (indexPath.row==[self.billingArray count])
            {
                [cell setBackgroundColor:TimesheetTotalHoursBackgroundColor];
                
            }
            else
                [cell setBackgroundColor:RepliconStandardBackgroundColor];
        }
    }
    if (indexPath.section==1)
    {
        if([payrollArray count]>0 && (isProjectAccess ||(!isProjectAccess && isActivityAccess)))
        {
            if (indexPath.row==[self.payrollArray count])
            {
                [cell setBackgroundColor:TimesheetTotalHoursBackgroundColor];
                
            }
            else
                [cell setBackgroundColor:RepliconStandardBackgroundColor];
        }
        else if ([billingArray count]>0)
        {
            if (indexPath.row==[self.billingArray count])
            {
                [cell setBackgroundColor:TimesheetTotalHoursBackgroundColor];
                
            }
            else
                [cell setBackgroundColor:RepliconStandardBackgroundColor];
        }
    }
    
    if (indexPath.section==2 && [billingArray count]>0)
    {
        if (indexPath.row==[self.billingArray count])
        {
            [cell setBackgroundColor:TimesheetTotalHoursBackgroundColor];
            
        }
        else
            [cell setBackgroundColor:RepliconStandardBackgroundColor];
    }
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    
    if (isProjectAccess)
    {
        if ([projectArray count]==0)
        {
            isProjectAccess=FALSE;
        }
    }
    
    if (isActivityAccess)
    {
        if ([activityArray count]==0)
        {
            isActivityAccess=FALSE;
        }
    }
    
    if ((isProjectAccess || (!isProjectAccess && isActivityAccess)) && [payrollArray count]>0 && [billingArray count]>0)
    {
        return 3;
        
    }
    else if((isProjectAccess || (!isProjectAccess && isActivityAccess)) && [payrollArray count]>0 && [billingArray count]==0)
    {
        return 2;
        
    }
    else if ((isProjectAccess || (!isProjectAccess && isActivityAccess)) && [payrollArray count]==0 && [billingArray count]>0)
    {
        return 2;
    }
    else if ((isProjectAccess || (!isProjectAccess && isActivityAccess)) && [payrollArray count]==0 && [billingArray count]==0){
        return 1;
    }
    else if ((!isProjectAccess ||  !isActivityAccess) && [payrollArray count]>0 && [billingArray count]>0){
        return 2;
    }
    else if ((!isProjectAccess || !isActivityAccess) && [payrollArray count]>0 && [billingArray count]==0){
        return 1;
    }
    else if ((!isProjectAccess || !isActivityAccess) && [payrollArray count]==0 && [billingArray count]>0){
        return 1;
    }

    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return Each_Cell_Row_Height_44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
     if (section==0)
    {
        if (isProjectAccess)
        {
            if ([projectArray count]>0) {
                //REMOVING THE "ADD A PROJECT" ROW
                //return [self.projectArray count]+2;
                return [self.projectArray count]+1;
            }
            else
                return 1;

        }
        else if (isActivityAccess && !isProjectAccess )
        {
            if ([activityArray count]>0)
            {
                //REMOVING THE "ADD AN ACTIVITY" ROW
                 //return [self.activityArray count]+2;
                return [self.activityArray count]+1;
                
            }
           else
               return 1;
        }
        else if([payrollArray count]>0)
        {
            return [self.payrollArray count]+1;
        }
        else if ([billingArray count]>0)
            return [self.billingArray count]+1;
    }
    if (section==1)
    {
        if([payrollArray count]>0 && (isActivityAccess || isProjectAccess))
        {
            return [self.payrollArray count]+1;
        }
        else if ([billingArray count]>0)
            return [self.billingArray count]+1;
    }

    if (section==2 && [billingArray count]>0)
    {
        return [self.billingArray count]+1;
    }


	return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    [headerView setBackgroundColor:RepliconStandardBlackColor];
    
	UILabel	*headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0,0.0,SCREEN_WIDTH-24,30.0)];
	
	[headerLabel setBackgroundColor:[UIColor clearColor]];
	[headerLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];
	[headerLabel setTextColor:RepliconStandardWhiteColor];
	
    if (section==0)
    {
        if (isProjectAccess)
        {
            [headerLabel setText:RPLocalizedString(PROJECT_INFOs, PROJECT_INFOs) ];

        }
        else if ((isActivityAccess && !isProjectAccess)){
            
            [headerLabel setText:RPLocalizedString(ACTIVITY_INFO,ACTIVITY_INFO)];
            
        }
        else if([payrollArray count]>0)
        {
            [headerLabel setText:RPLocalizedString(PAYROLL_INFO,PAYROLL_INFO)];
        }
        else if ([billingArray count]>0)
            [headerLabel setText:RPLocalizedString(BILLING_INFO,BILLING_INFO)];
    }
    if (section==1)
    {
        if([payrollArray count]>0 && (isActivityAccess || isProjectAccess))
        {
            [headerLabel setText:RPLocalizedString(PAYROLL_INFO,PAYROLL_INFO)];
        }
        else if ([billingArray count]>0)
            [headerLabel setText:RPLocalizedString(BILLING_INFO,BILLING_INFO)];
    }
    
    if (section==2 && [billingArray count]>0)
    {
        [headerLabel setText:RPLocalizedString(BILLING_INFO,BILLING_INFO)];
    }

    [headerView addSubview:headerLabel];
   
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell=nil;
    
    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
   
    // This is for Adding a Project
    if (isProjectAccess && indexPath.section==0 && ([projectArray count]>0 && indexPath.row==[self.projectArray count]+1))
    {
        NSString *CellIdentifier = @"AddProjectCell";
            
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.textLabel.text = [NSString stringWithFormat:@"%@",RPLocalizedString(ADD_PROJECT_TEXT, ADD_PROJECT_TEXT) ];
                cell.imageView.image=[Util thumbnailImage:AddProjectIcon];
                
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
            cell.contentView.backgroundColor=[Util colorWithHex:@"#f8f8f8" alpha:1];
            return cell;
        
    }
    else if (isProjectAccess && indexPath.section==0 &&([projectArray count]==0 && indexPath.row==0))
    {
        NSString *CellIdentifier = @"AddProjectCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.text = [NSString stringWithFormat:@"%@",RPLocalizedString(ADD_PROJECT_TEXT, ADD_PROJECT_TEXT)];
            cell.imageView.image=[Util thumbnailImage:AddProjectIcon];
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        cell.contentView.backgroundColor=[Util colorWithHex:@"#f8f8f8" alpha:1];
        return cell;
    }
    else if ((!isProjectAccess && isActivityAccess) && indexPath.section==0 && ([activityArray count]>0 && indexPath.row==[self.activityArray count]+1) ){
        
         NSString *CellIdentifier = @"AddActivityCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
       
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.textLabel.text = [NSString stringWithFormat:@"%@",RPLocalizedString(ADD_ACTIVITY_TEXT,ADD_ACTIVITY_TEXT)];
                cell.imageView.image=[Util thumbnailImage:AddProjectIcon];
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        cell.contentView.backgroundColor=[Util colorWithHex:@"#f8f8f8" alpha:1];
        return cell;
     
    }
    else if ((!isProjectAccess && isActivityAccess) && indexPath.section==0 &&([activityArray count]==0 && indexPath.row==0)){
         NSString *CellIdentifier = @"AddActivityCell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.textLabel.text = [NSString stringWithFormat:@"%@",RPLocalizedString(ADD_ACTIVITY_TEXT,ADD_ACTIVITY_TEXT)];
            cell.imageView.image=[Util thumbnailImage:AddProjectIcon];
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        cell.contentView.backgroundColor=[Util colorWithHex:@"#f8f8f8" alpha:1];
        return cell;
        
    }
    else
    {
        static NSString *CellIdentifier;
        CellIdentifier = @"Cell";
       cell = (CurrentTimeSheetsCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[CurrentTimeSheetsCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            
        }
        for (UIView *view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }

        id timeSheetOb;
        
        NSString *name=nil;
        NSString *numberOfHr=nil;
        
        if (indexPath.section==0)
        {
            if (isProjectAccess && [projectArray count]>0)
            {
                if (indexPath.row==[self.projectArray count])
                {
                    name=RPLocalizedString(TotalString, TotalString);
                    
                    [cell.contentView setBackgroundColor:[UIColor clearColor]];
                    
                    timeSheetOb= [self.projectArray objectAtIndex:indexPath.row-1];
                    UIViewController *controllerViewCtrl=(UIViewController *)delegate;
                    //Approval context Flow for Timesheets
                    if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
                    {
                        
                        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)delegate;
                        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                        {
                            ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
                            numberOfHr=[approvalModel getPendingTotalProjectSummaryHours:[timeSheetOb timesheetURI] withFormat:@"DECIMAL"];
                            
                        }
                        else
                        {
                            ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
                            numberOfHr=[approvalModel getPreviousTotalProjectSummaryHours:[timeSheetOb timesheetURI] withFormat:@"DECIMAL"];
                           
                        }
                        
                    }
                    //users context Flow for Timesheets
                    else if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
                    {
                        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                        numberOfHr=[timesheetModel getTotalProjectSummaryHours:[timeSheetOb timesheetURI] withFormat:@"DECIMAL"];
                        
                    }

                    
                }
                else{
                    timeSheetOb= [self.projectArray objectAtIndex:indexPath.row];
                    if ([timeSheetOb isKindOfClass:[TimesheetObject class]]){
                        name=[timeSheetOb projectName];
                        numberOfHr=[timeSheetOb numberOfHours];
                    }
                }
                    
            }
            else if((isActivityAccess && !isProjectAccess) &&[activityArray count]>0 ){
                if (indexPath.row==[self.activityArray count])
                {
                    name=RPLocalizedString(TotalString, TotalString) ;
                     timeSheetOb= [self.activityArray objectAtIndex:indexPath.row-1];
                    [cell.contentView setBackgroundColor:[UIColor clearColor]];
                    UIViewController *controllerViewCtrl=(UIViewController *)delegate;
                    //Approval context Flow for Timesheets
                    if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
                    {
                        
                        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)delegate;
                        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                        {
                            ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
                            numberOfHr=[approvalModel getPendingTotalActivitySummaryHours:[timeSheetOb timesheetURI] withFormat:@"DECIMAL"];
                           
                        }
                        else
                        {
                            ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
                            numberOfHr=[approvalModel getPreviousTotalActivitySummaryHours:[timeSheetOb timesheetURI] withFormat:@"DECIMAL"];
                           
                        }
                        
                    }
                    //users context Flow for Timesheets
                    else if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
                    {
                        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                        numberOfHr=[timesheetModel getTotalActivitySummaryHours:[timeSheetOb timesheetURI] withFormat:@"DECIMAL"];
                       
                    }
                    
                }
                else{
                    timeSheetOb= [self.activityArray objectAtIndex:indexPath.row];
                    if ([timeSheetOb isKindOfClass:[TimesheetObject class]]){
                        name=[timeSheetOb activityName];
                        numberOfHr=[timeSheetOb numberOfHours];
                    }
                }
            }
            else if([payrollArray count]>0)
            {
                if (indexPath.row==[self.payrollArray count])
                {
                    [cell.contentView setBackgroundColor:[UIColor clearColor]];
                    [cell setBackgroundColor:RepliconStandardBackgroundColor];
                    name=RPLocalizedString(TotalString, TotalString);
                    timeSheetOb= [self.payrollArray objectAtIndex:indexPath.row-1];
                    UIViewController *controllerViewCtrl=(UIViewController *)delegate;
                    //Approval context Flow for Timesheets
                    if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
                    {
                        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)delegate;
                        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                        {
                            ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
                            numberOfHr=[approvalModel getPendingTotalPayrollSummaryHours:[timeSheetOb timesheetURI] withFormat:@"DECIMAL"];
                            
                        }
                        else
                        {
                            ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
                            numberOfHr=[approvalModel getPreviousTotalPayrollSummaryHours:[timeSheetOb timesheetURI] withFormat:@"DECIMAL"];
                           
                        }
                        
                    }
                    //users context Flow for Timesheets
                    else if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
                    {
                        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                        numberOfHr=[timesheetModel getTotalPayrollSummaryHours:[timeSheetOb timesheetURI] withFormat:@"DECIMAL"];
                       
                    }
                    
                }
                else{
                    timeSheetOb= [self.payrollArray objectAtIndex:indexPath.row];
                    if ([timeSheetOb isKindOfClass:[TimesheetObject class]]){
                        name=[timeSheetOb payrollName];
                        numberOfHr=[timeSheetOb numberOfHours];
                    }
                }
                
            }
            else if ([billingArray count]>0){
                if (indexPath.row==[self.billingArray count])
                {
                    [cell.contentView setBackgroundColor:[UIColor clearColor]];
                    [cell setBackgroundColor:RepliconStandardBackgroundColor];
                    name=RPLocalizedString(TotalString, TotalString);
                    timeSheetOb= [self.billingArray objectAtIndex:indexPath.row-1];
                    UIViewController *controllerViewCtrl=(UIViewController *)delegate;
                    //Approval context Flow for Timesheets
                    if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
                    {
                        
                        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)delegate;
                        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                        {
                            ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
                            numberOfHr=[approvalModel getPendingTotalBillingSummaryHours:[timeSheetOb timesheetURI] withFormat:@"DECIMAL"];
                            
                        }
                        else
                        {
                            ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
                            numberOfHr=[approvalModel getPreviousTotalBillingSummaryHours:[timeSheetOb timesheetURI] withFormat:@"DECIMAL"];
                            
                        }
                        
                    }
                    //users context Flow for Timesheets
                    else if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
                    {
                        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                        numberOfHr=[timesheetModel getTotalBillingSummaryHours:[timeSheetOb timesheetURI] withFormat:@"DECIMAL"];
                       
                    }
                }
                
                else{
                    timeSheetOb= [self.billingArray objectAtIndex:indexPath.row];
                    if ([timeSheetOb isKindOfClass:[TimesheetObject class]]){
                        name=[timeSheetOb billingName];
                        numberOfHr=[timeSheetOb numberOfHours];
                    }
                }
            }
        }
        if (indexPath.section==1)
        {
            if([payrollArray count]>0 && (isActivityAccess || isProjectAccess) )
            {
                if (indexPath.row==[self.payrollArray count])
                {
                    [cell.contentView setBackgroundColor:[UIColor clearColor]];
                    [cell setBackgroundColor:RepliconStandardBackgroundColor];
                    name=RPLocalizedString(TotalString, TotalString);
                    timeSheetOb= [self.payrollArray objectAtIndex:indexPath.row-1];
                    UIViewController *controllerViewCtrl=(UIViewController *)delegate;
                    //Approval context Flow for Timesheets
                    if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
                    {
                        
                        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)delegate;
                        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                        {
                            ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
                            numberOfHr=[approvalModel getPendingTotalPayrollSummaryHours:[timeSheetOb timesheetURI] withFormat:@"DECIMAL"];
                            
                        }
                        else
                        {
                            ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
                            numberOfHr=[approvalModel getPreviousTotalPayrollSummaryHours:[timeSheetOb timesheetURI] withFormat:@"DECIMAL"];
                           
                        }
                        
                    }
                    //users context Flow for Timesheets
                    else if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
                    {
                        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                        numberOfHr=[timesheetModel getTotalPayrollSummaryHours:[timeSheetOb timesheetURI] withFormat:@"DECIMAL"];
                        
                    }
                    
                }
                else{
                    timeSheetOb= [self.payrollArray objectAtIndex:indexPath.row];
                    if ([timeSheetOb isKindOfClass:[TimesheetObject class]]){
                        name=[timeSheetOb payrollName];
                        numberOfHr=[timeSheetOb numberOfHours];
                    }
                }
            }
            else if ([billingArray count]>0)
            {
                if (indexPath.row==[self.billingArray count])
                {
                    [cell.contentView setBackgroundColor:[UIColor clearColor]];
                    [cell setBackgroundColor:RepliconStandardBackgroundColor];
                    name=RPLocalizedString(TotalString, TotalString);
                    timeSheetOb= [self.billingArray objectAtIndex:indexPath.row-1];
                    UIViewController *controllerViewCtrl=(UIViewController *)delegate;
                    //Approval context Flow for Timesheets
                    if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
                    {
                        
                        ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)delegate;
                        if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                        {
                            ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
                            numberOfHr=[approvalModel getPendingTotalBillingSummaryHours:[timeSheetOb timesheetURI] withFormat:@"DECIMAL"];
                           
                        }
                        else
                        {
                            ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
                            numberOfHr=[approvalModel getPreviousTotalBillingSummaryHours:[timeSheetOb timesheetURI] withFormat:@"DECIMAL"];
                            
                        }
                        
                    }
                    //users context Flow for Timesheets
                    else if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
                    {
                        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                        numberOfHr=[timesheetModel getTotalBillingSummaryHours:[timeSheetOb timesheetURI] withFormat:@"DECIMAL"];
                        
                    }
                    
                }
                else{
                    timeSheetOb= [self.billingArray objectAtIndex:indexPath.row];
                    if ([timeSheetOb isKindOfClass:[TimesheetObject class]]){
                        name=[timeSheetOb billingName];
                        numberOfHr=[timeSheetOb numberOfHours];
                    }
                }
            }
        }
        
        if (indexPath.section==2)
        {
            if (indexPath.row==[self.billingArray count])
            {
                [cell.contentView setBackgroundColor:[UIColor clearColor]];
                [cell setBackgroundColor:RepliconStandardBackgroundColor];
                name=RPLocalizedString(TotalString, TotalString);
                timeSheetOb= [self.billingArray objectAtIndex:indexPath.row-1];
                UIViewController *controllerViewCtrl=(UIViewController *)delegate;
                //Approval context Flow for Timesheets
                if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
                {
                    
                    ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)delegate;
                    if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                    {
                        ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
                        numberOfHr=[approvalModel getPendingTotalBillingSummaryHours:[timeSheetOb timesheetURI] withFormat:@"DECIMAL"];
                        
                    }
                    else
                    {
                        ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
                        numberOfHr=[approvalModel getPreviousTotalBillingSummaryHours:[timeSheetOb timesheetURI] withFormat:@"DECIMAL"];
                       
                    }
                    
                }
                //users context Flow for Timesheets
                else if ([delegate isKindOfClass:[CurrentTimesheetViewController class]])
                {
                    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                    numberOfHr=[timesheetModel getTotalBillingSummaryHours:[timeSheetOb timesheetURI] withFormat:@"DECIMAL"];
                   
                }
                
            }
            else{
                timeSheetOb= [self.billingArray objectAtIndex:indexPath.row];
                if ([timeSheetOb isKindOfClass:[TimesheetObject class]]){
                    name=[timeSheetOb billingName];
                    numberOfHr=[timeSheetOb numberOfHours];
                }
            }
        }
        
        
        [(CurrentTimeSheetsCellView *)cell setDelegate:self];
 [(CurrentTimeSheetsCellView *)cell setFieldType:nil];
        [(CurrentTimeSheetsCellView *)cell createCellWithLeftString:name
                                                 andLeftStringColor:nil
                                                     andRightString:numberOfHr
                                                andRightStringColor:nil
                                                        hasComments:NO
                                                         hasTimeoff:NO
                                                            withTag:indexPath.row];
        
        
        if (indexPath.section==0)
        {
            if (isProjectAccess)
            {
                if ([projectArray count]>0)
                {
                    if (indexPath.row==[self.projectArray count])
                    {
                        [cell setBackgroundColor:RepliconStandardBackgroundColor];
                        [[(CurrentTimeSheetsCellView *)cell leftLb] setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];
                        [[(CurrentTimeSheetsCellView *)cell rightLb] setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]];
                        [[(CurrentTimeSheetsCellView *)cell leftLb] setTextColor:[UIColor blackColor]];
                        [[(CurrentTimeSheetsCellView *)cell rightLb] setTextColor:[UIColor blackColor]];
                    }

                }
            }
            else if (isActivityAccess && !isProjectAccess){
                if ([activityArray count]>0)
                {
                    if (indexPath.row==[self.activityArray count])
                    {
                        [cell setBackgroundColor:RepliconStandardBackgroundColor];
                        [[(CurrentTimeSheetsCellView *)cell leftLb] setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];
                        [[(CurrentTimeSheetsCellView *)cell rightLb] setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]];
                        [[(CurrentTimeSheetsCellView *)cell leftLb] setTextColor:[UIColor blackColor]];
                        [[(CurrentTimeSheetsCellView *)cell rightLb] setTextColor:[UIColor blackColor]];
                    }
                    
                }

            }
            else if([payrollArray count]>0)
            {
                if (indexPath.row==[self.payrollArray count])
                {
                    [cell setBackgroundColor:RepliconStandardBackgroundColor];
                    [[(CurrentTimeSheetsCellView *)cell leftLb] setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];
                    [[(CurrentTimeSheetsCellView *)cell rightLb] setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]];
                    [[(CurrentTimeSheetsCellView *)cell leftLb] setTextColor:[UIColor blackColor]];
                    [[(CurrentTimeSheetsCellView *)cell rightLb] setTextColor:[UIColor blackColor]];
                }
                    
            }
            else if ([billingArray count]>0){
                if (indexPath.row==[self.billingArray count])
                {
                    [cell setBackgroundColor:RepliconStandardBackgroundColor];
                    [[(CurrentTimeSheetsCellView *)cell leftLb] setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16]];
                    [[(CurrentTimeSheetsCellView *)cell rightLb] setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
                    [[(CurrentTimeSheetsCellView *)cell leftLb] setTextColor:[UIColor blackColor]];
                    [[(CurrentTimeSheetsCellView *)cell rightLb] setTextColor:[UIColor blackColor]];
                }
            }
        }
        if (indexPath.section==1)
        {
           if([payrollArray count]>0 && (isActivityAccess || isProjectAccess))
            {
                if (indexPath.row==[self.payrollArray count])
                {
                    [cell setBackgroundColor:RepliconStandardBackgroundColor];
                    [[(CurrentTimeSheetsCellView *)cell leftLb] setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];
                    [[(CurrentTimeSheetsCellView *)cell rightLb] setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]];
                    [[(CurrentTimeSheetsCellView *)cell leftLb] setTextColor:[UIColor blackColor]];
                    [[(CurrentTimeSheetsCellView *)cell rightLb] setTextColor:[UIColor blackColor]];
                }
            }
            else if ([billingArray count]>0)
            {
                if (indexPath.row==[self.billingArray count])
                {
                    [cell setBackgroundColor:RepliconStandardBackgroundColor];
                    [[(CurrentTimeSheetsCellView *)cell leftLb] setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16]];
                    [[(CurrentTimeSheetsCellView *)cell rightLb] setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
                    [[(CurrentTimeSheetsCellView *)cell leftLb] setTextColor:[UIColor blackColor]];
                    [[(CurrentTimeSheetsCellView *)cell rightLb] setTextColor:[UIColor blackColor]];
                }
            }
        }
        if (indexPath.section==2)
        {
            if (indexPath.row==[self.billingArray count])
            {
                [cell setBackgroundColor:RepliconStandardBackgroundColor];
                [[(CurrentTimeSheetsCellView *)cell leftLb] setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16]];
                [[(CurrentTimeSheetsCellView *)cell rightLb] setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
                [[(CurrentTimeSheetsCellView *)cell leftLb] setTextColor:[UIColor blackColor]];
                [[(CurrentTimeSheetsCellView *)cell rightLb] setTextColor:[UIColor blackColor]];
            }
        }

    }
       
    //cell.contentView.backgroundColor=[Util colorWithHex:@"#f8f8f8" alpha:1];
    [[(CurrentTimeSheetsCellView *)cell activityView] setHidden:YES];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    
    //LOWER IMAGE VIEW
    UIImage *lowerImage = [Util thumbnailImage:Cell_HairLine_Image];
	UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, Each_Cell_Row_Height_44-lowerImage.size.height, SCREEN_WIDTH,lowerImage.size.height)];
    [lineImageView setImage:lowerImage];
    [cell.contentView bringSubviewToFront:lineImageView];
	[cell.contentView addSubview:lineImageView];
   
    
	return cell;
	
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     if (indexPath.section==0)
    {
        if (isProjectAccess){
            
            if(([projectArray count]>0 && indexPath.row==[self.projectArray count]+1)||([self.projectArray count]==0 && indexPath.row==0))
            {
                [self moveToTimeEntryScreen];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }

        }        
        
       else if (!isProjectAccess && isActivityAccess)
        {
            if(([activityArray count]>0 && indexPath.row==[self.activityArray count]+1)||([activityArray count]==0 && indexPath.row==0))
            {
                [self moveToTimeEntryScreen];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
            
        }
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
/*    
 //COMMENTED OUT SINCE DELETE OF ROWS NOT SUPPORTED IN PHASE 1
 
 if (indexPath.section==0)
    {
        if (isProjectAccess||isActivityAccess)
        {
            if ([self.projectArray count]==0)
            {
                return NO;
            }
            else
            {
                if (indexPath.row==[self.projectArray count]||indexPath.row==[self.projectArray count]+1)
                    return NO;
                else
                    return YES;
            }
            
        }
        else
        {
            return NO;
        }
    }
 
 */
    return NO;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        CurrentTimeSheetsCellView *cell = (CurrentTimeSheetsCellView *)[tableView cellForRowAtIndexPath:indexPath];
        [cell.activityView setHidden:NO];
        [cell.activityView startAnimating];
        [self.view setUserInteractionEnabled:NO];
        [self performSelector:@selector(stopActivityForDeleteAction:) withObject:indexPath afterDelay:2];
    }
}
-(void)createFooter{
    
    float footerHeight = 410;
    UIView *tempfooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                      0.0,
                                                                      self.timesheetSummaryTableView.frame.size.width,
                                                                      footerHeight)];
    self.footerView=tempfooterView;
    
	
	[footerView setBackgroundColor:RepliconStandardBackgroundColor];
    if([approvalArray count]>0){
        UIImage *totalLineImage=[Util thumbnailImage:Cell_HairLine_Image];
        
        UIView *approvalView=[[UIView alloc]initWithFrame:CGRectMake(0.0, 0, self.timesheetSummaryTableView.frame.size.width, 32)];
        
        [approvalView setBackgroundColor:RepliconStandardBlackColor];
        
        
        UILabel *approvalLb=[[UILabel alloc]initWithFrame:CGRectMake(12.0, 0.0,SCREEN_WIDTH-24 ,30.0)];
        [approvalLb setBackgroundColor:[UIColor clearColor]];
        [approvalLb setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];
        [approvalLb setTextColor:RepliconStandardWhiteColor];
        [approvalLb setText:RPLocalizedString(APPROVAL_INFO, APPROVAL_INFO) ];
        
        [approvalView addSubview:approvalLb];
        
        [self.footerView addSubview:approvalView];
        
        UIImageView *totalLineImageview=[[UIImageView alloc]initWithImage:totalLineImage];
        totalLineImageview.frame=CGRectMake(0.0,
                                            32,
                                            SCREEN_WIDTH,
                                            totalLineImage.size.height);
        
        
        [totalLineImageview setBackgroundColor:[UIColor clearColor]];
        [totalLineImageview setUserInteractionEnabled:NO];
        [self.footerView addSubview:totalLineImageview];
        
        
       
        
       
        float y=32+totalLineImage.size.height;
        for (int i=0; i<[approvalArray count]; i++)
        {
            TimesheetApprovalHistoryObject *timesheetObj=[approvalArray objectAtIndex:i];
            UIView *approvalDetailView = [[UIView alloc]initWithFrame:CGRectMake(0, y, self.view.frame.size.width, 70 )];
            [approvalDetailView setBackgroundColor:[UIColor clearColor]];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
           
            NSLocale *locale=[NSLocale currentLocale];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [dateFormatter setLocale:locale];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
            [timeFormat setDateFormat:@"hh:mm a"];
            [timeFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [timeFormat setLocale:locale];
            UILabel *submittedLb=[[UILabel alloc] initWithFrame:CGRectMake(12, 8,self.view.frame.size.width-24, 20)];
            [submittedLb setBackgroundColor:[UIColor clearColor]];
            [submittedLb setTextColor:RepliconStandardBlackColor];
            [submittedLb setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_13]];
            [submittedLb setTextAlignment:NSTextAlignmentLeft];
            //Fix for defect DE15577//JUHI
             NSString *statusStr=nil;
            
             if ([timesheetObj.approvalActionStatus isEqualToString:@"Submit"])
             {
                 statusStr=RPLocalizedString(@"Submitted", @"") ;//Implementation for US8902//JUHI
             }
            else if ([timesheetObj.approvalActionStatus isEqualToString:@"Reject"])
            {
                statusStr=RPLocalizedString(@"Rejected", @"");//Implementation for US8902//JUHI
            }
             else if ([timesheetObj.approvalActionStatus isEqualToString:@"Approve"])
             {
                 statusStr=RPLocalizedString(@"Approved", @"");//Implementation for US8902//JUHI
             }//implemented as per US8709//JUHI
             else if ([timesheetObj.approvalActionStatus isEqualToString:@"Reopen"])
             {
                 statusStr=RPLocalizedString(@"Reopened", @"");//Implementation for US8902//JUHI
             }
             else{
                 statusStr=timesheetObj.approvalActionStatus;
             }
             
             [submittedLb setText:[NSString stringWithFormat:@"%@: %@; %@",statusStr,[dateFormatter stringFromDate:timesheetObj.approvalActionDate],[timeFormat stringFromDate:timesheetObj.approvalActionDate]]];
            [approvalDetailView addSubview:submittedLb];
            
            y=y+25;
            [self.footerView addSubview:approvalDetailView];
            
        }
        
        
   
    }
    NSUInteger buttonHeight=0;
    
    buttonHeight=([self.approvalArray count]*Count);
    
    
    CGRect frame=self.footerView.frame;
    frame.size.height=self.footerView.frame.size.height+buttonHeight-spaceHeight;
    [self.footerView setFrame:frame];
    
    [self.timesheetSummaryTableView setTableFooterView:footerView];
    
}
-(void)backAction:(id)sender{
 [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)dayAction:(id)sender{
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    [UIView beginAnimations:@"View Flip" context:nil];
    [UIView setAnimationDuration:0.80];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft
                           forView:appDelegate.window cache:NO];
    
    [self.navigationController popViewControllerAnimated:YES];
    [UIView commitAnimations];
    
}
-(void)moveToTimeEntryScreen{
    
    TimeEntryViewController *addNewTimeEntryViewController=[[TimeEntryViewController alloc]init];
    TimesheetObject *tsObject=[[TimesheetObject alloc] init];
    if ([projectArray count]!=0)
    {
        [tsObject setTimesheetURI:[[projectArray objectAtIndex:0] timesheetURI]];
    }
    else if([billingArray count]!=0)
    {
        [tsObject setTimesheetURI:[[billingArray objectAtIndex:0] timesheetURI]];
        
    }
    else if ([payrollArray count]!=0)
    {
        [tsObject setTimesheetURI:[[payrollArray objectAtIndex:0] timesheetURI]];
    }
    else
    {
        [tsObject setTimesheetURI:self.sheetIdentity];
    }
    
    addNewTimeEntryViewController.timesheetObject=tsObject;
    addNewTimeEntryViewController.screenMode=ADD_TIMESHEET;
    addNewTimeEntryViewController.delegate=delegate;
   
    UINavigationController *tempnavcontroller = [[UINavigationController alloc]initWithRootViewController:addNewTimeEntryViewController];
    //Fix for ios7//JUHI
    float version= [[UIDevice currentDevice].systemVersion newFloatValue];
    
    if (version>=7.0)
    {
        UIImage *navigationbarImage=[Util thumbnailImage:NAVIGATION_BAR_IMAGE];
        [tempnavcontroller.navigationBar setBackgroundImage:[navigationbarImage resizableImageWithCapInsets:UIEdgeInsetsMake(3, 3, 4, 3) resizingMode:UIImageResizingModeStretch] forBarMetrics:UIBarMetricsDefault];
        [tempnavcontroller.navigationBar setTranslucent:NO];
        tempnavcontroller.navigationBar.tintColor=[UIColor whiteColor];
        if ([tempnavcontroller respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            tempnavcontroller.interactivePopGestureRecognizer.enabled = NO;
        }
    }
    else
    {
        tempnavcontroller.navigationBar.tintColor=RepliconStandardNavBarTintColor;
    }
    
    [self presentViewController:tempnavcontroller animated:YES completion:nil];
    //self.navcontroller=tempnavcontroller;
   
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)stopActivityForDeleteAction:(NSIndexPath *)indexPath
{
    CurrentTimeSheetsCellView *cell = (CurrentTimeSheetsCellView *)[self.timesheetSummaryTableView cellForRowAtIndexPath:indexPath];
    [cell.activityView setHidden:YES];
    [cell.activityView stopAnimating];
    [self.view setUserInteractionEnabled:YES];
    [self.projectArray removeObjectAtIndex:indexPath.row];
    if ([self.projectArray count]==0)
    {
       // [self.sectionArray removeObjectAtIndex:0];
        //[self.timesheetSummaryTableView beginUpdates];
        //[self.timesheetSummaryTableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
        //[self.timesheetSummaryTableView endUpdates];
        [self.timesheetSummaryTableView reloadData];
    }
    
    if ([self.projectArray count]!=0)
    {
        [self.timesheetSummaryTableView beginUpdates];
        [self.timesheetSummaryTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.timesheetSummaryTableView endUpdates];
    }
    
}


#pragma mark NetworkMonitor

-(void) networkActivated {
	
    
}


#pragma mark - NSObject

-(void)dealloc
{
    self.timesheetSummaryTableView.delegate = nil;
    self.timesheetSummaryTableView.dataSource = nil;
}


- (CGFloat)heightForTableView
{
     static CGFloat paddingForLastCellBottomSeparatorFudgeFactor = 10.0f;
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    CGFloat statusBarHeight = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
    UINavigationController *navigationController = (UINavigationController *)appDelegate.rootTabBarController.selectedViewController;
    CGFloat navigationBarHeight = CGRectGetHeight(navigationController.navigationBar.frame);
    CGFloat tabBarHeight = CGRectGetHeight(appDelegate.rootTabBarController.tabBar.frame);
    return CGRectGetHeight([[UIScreen mainScreen] bounds]) - (statusBarHeight+navigationBarHeight+tabBarHeight+paddingForLastCellBottomSeparatorFudgeFactor);
}
@end
