//
//  EditEntryViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 26/01/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "EditEntryViewController.h"
#import "Constants.h"
#import "Util.h"
#import "InOutProjectHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "DayTimeEntryViewController.h"
#import "EntryCellDetails.h"
#import "TimesheetUdfView.h"
#import "AddDescriptionViewController.h"
#import <CoreText/CoreText.h>
#import "InOutEntryDetailsCustomCell.h"
#import "AppDelegate.h"
#import "TimeEntryViewController.h"
#import "MultiDayInOutViewController.h"
#import "TimesheetNavigationController.h"
#import "ExpensesNavigationController.h"
#import "BookedTimeOffNavigationController.h"
#import "AttendanceNavigationController.h"
#import "PunchHistoryNavigationController.h"
#import "ShiftsNavigationController.h"
#import "ApprovalsNavigationController.h"
#import "SupervisorDashboardNavigationController.h"
#import "TeamTimeNavigationController.h"
#import "SupportDataModel.h"
#import "OEFObject.h"
#import "UIView+Additions.h"

#define HEADER_LABEL_HEIGHT 26
#define LABEL_PADDING 10
#define PROJECT_HEADER_LABEL_HEIGHT 50
#define HOURS_LABEL_WIDTH 50
#define TIME_VIEW_HEIGHT 45
#define Each_Cell_Row_Height_44 44
#define COMMENTS_LABEL_HEIGHT 40

#define resetTableSpaceHeight 220
#define resetTableSpaceHeight_Other_UDF 180
#define resetTableSpaceHeight_Date_UDF 220
#define LABEL_WIDTH (SCREEN_WIDTH - (3*LABEL_PADDING) - HOURS_LABEL_WIDTH)

@interface EditEntryViewController ()

@property(nonatomic)UIButton *commentsPlaceholderButton;

@end

@implementation EditEntryViewController

@synthesize currentPageDate;
@synthesize tsEntryObject;
@synthesize isProjectAccess;
@synthesize isActivityAccess;
@synthesize row;
@synthesize section;
@synthesize hours;
@synthesize inoutEntryTableView;
@synthesize sheetApprovalStatus;
@synthesize commentsControlDelegate;
@synthesize lastUsedTextField;
@synthesize selectedUdfCell;
@synthesize datePicker;
@synthesize cancelButton;
@synthesize previousDateUdfValue;
@synthesize doneButton;
@synthesize spaceButton;
@synthesize pickerClearButton;
@synthesize toolbar;
@synthesize commentsTextView;
@synthesize tableFooterView;
@synthesize tableHeaderView;
@synthesize isEditState;
@synthesize isTextViewBecomeFirstResponder;
@synthesize userFieldArray;
@synthesize isBreakAccess;//ImplementationForExtendedInOutDeleteBreak_US9103//JUHI
@synthesize isBillingAccess;
@synthesize attributedString;
@synthesize approvalsModuleName;
@synthesize isRowUdf;//Implementation forMobi-181//JUHI

#pragma mark - View methods
- (void)loadView
{
	[super loadView];
    [self.view setBackgroundColor:RepliconStandardWhiteColor];
	//[self.navigationController.navigationBar setTintColor:RepliconStandardNavBarTintColor];
    if (isBreakAccess)
    {
        [Util setToolbarLabel: self withText:RPLocalizedString(BREAK_ENTRY_DETAILS_STRING, @"")];
    }
    else
        [Util setToolbarLabel: self withText:RPLocalizedString(ENTRY_DETAILS_STRING, @"")];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UITableView *tableView=[[UITableView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    self.inoutEntryTableView=tableView;
    
    [self.inoutEntryTableView setDelegate:self];
    [self.inoutEntryTableView setDataSource:self];
    [self.inoutEntryTableView setBackgroundColor:[Util colorWithHex:@"#f8f8f8" alpha:1]];
    [self.inoutEntryTableView setSeparatorColor:[Util colorWithHex:@"#D6D6D6" alpha:1]];
    [self.view addSubview:self.inoutEntryTableView];
    //ImplementationForExtendedInOutDeleteBreak_US9103//JUHI
    if (isEditState && !isBreakAccess && ![[tsEntryObject entryType] isEqualToString:Time_Off_Key])
    {
        UIBarButtonItem *tempRightButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(Save_Button_Title, @"") style:UIBarButtonItemStylePlain target:self action:@selector(saveAction:)];
        [self navigationItem].rightBarButtonItem=tempRightButtonOuterBtn;
        [tempRightButtonOuterBtn setAccessibilityLabel: @"uia_day_entry_editview_save_btn_identifier"];
    }
    
    [self.inoutEntryTableView setAccessibilityIdentifier: @"uia_timesheet_day_entry_view_details_table_identifier"];

    UIBarButtonItem *tempLeftButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(Cancel_Button_Title, @"") style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    [[self navigationItem ] setLeftBarButtonItem:tempLeftButtonOuterBtn animated:NO];
    
    [tempLeftButtonOuterBtn setAccessibilityLabel: @"uia_timesheet_day_entry_view_details_cancel_btn_identifier"];
    
    self.tableFooterView=[self getTableFooter];
    self.tableHeaderView=[self getTableHeader];
    [self.inoutEntryTableView setTableFooterView:self.tableFooterView];
    [self.inoutEntryTableView setTableHeaderView:self.tableHeaderView];

    if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
    {
        self.oefFieldArray=[NSMutableArray arrayWithArray:[tsEntryObject timeEntryCellOEFArray]] ;
    }
    else
    {
        self.userFieldArray = [[NSMutableArray alloc] init];
        self.userFieldArray= [tsEntryObject timeEntryUdfArray] ;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(self.datePicker != nil && ![self.datePicker isHidden]){
        [self pickerCancel:nil];
    }
}

-(void)becomeFirstResponderAction
{
    if (isEditState && [tsEntryObject isRowEditable])
    {
        self.isTextViewBecomeFirstResponder=YES;
        [self.commentsTextView becomeFirstResponder];
        [self.commentsPlaceholderButton setHidden:YES];
        CGPoint point=[self.inoutEntryTableView convertPoint:CGPointMake(self.inoutEntryTableView.tableFooterView.bounds.origin.x, self.inoutEntryTableView.tableFooterView.bounds.origin.y) fromView:self.inoutEntryTableView.tableFooterView];
        [self.inoutEntryTableView setContentOffset:point];
    }
    
}
-(UIView *)initialiseView:(NSMutableDictionary *)dataDict
{
    UIView *returnView=[UIView new];
    UIView *separatorView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
    [separatorView setBackgroundColor:[Util colorWithHex:@"#d6d6d6" alpha:1.0]];
    [returnView addSubview:separatorView];
    [returnView bringSubviewToFront:separatorView];
    [returnView setBackgroundColor:[Util colorWithHex:@"#f2f2f2" alpha:1]];
    
    BOOL isSingleLine=NO;
    BOOL isTwoLine=NO;
    BOOL isThreeLine=NO;
    NSString *line=[dataDict objectForKey:LINE];
    NSString *upperStr=[dataDict objectForKey:UPPER_LABEL_STRING];
    NSString *middleStr=[dataDict objectForKey:MIDDLE_LABEL_STRING];
    NSString *lowerStr=[dataDict objectForKey:LOWER_LABEL_STRING];
    NSString *billingRate = [dataDict objectForKey:BILLING_RATE];
    
    float upperLblHeight=[[dataDict objectForKey:UPPER_LABEL_HEIGHT] newFloatValue];
    float middleLblHeight=[[dataDict objectForKey:MIDDLE_LABEL_HEIGHT] newFloatValue];
    float lowerLblHeight=[[dataDict objectForKey:LOWER_LABEL_HEIGHT] newFloatValue];
    float height=[[dataDict objectForKey:CELL_HEIGHT_KEY] newFloatValue];
    float billingHeight = [[dataDict objectForKey:BILLING_LABEL_HEIGHT] newFloatValue];
    //BOOL isUpperLabelTextWrap=[[heightDict objectForKey:UPPER_LABEL_TEXT_WRAP] boolValue];
//TODO:Commenting below line because variable is unused,uncomment when using
//    BOOL isMiddleLabelTextWrap=[[dataDict objectForKey:MIDDLE_LABEL_TEXT_WRAP] boolValue];
    BOOL isLowerLabelTextWrap=[[dataDict objectForKey:LOWER_LABEL_TEXT_WRAP] boolValue];
    
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
    
    
    if (isSingleLine)
    {
        
        
        UILabel *middleLeft = [[UILabel alloc] init];
        middleLeft.frame=CGRectMake(10.0, 10.0, LABEL_WIDTH, middleLblHeight);
        [middleLeft setTextColor:[Util colorWithHex:@"#505151" alpha:1]];
        [middleLeft setBackgroundColor:[UIColor clearColor]];
        [middleLeft setTextAlignment:NSTextAlignmentLeft];
        [middleLeft setHighlightedTextColor:[UIColor whiteColor]];
        [returnView addSubview:middleLeft];
        [middleLeft setText:middleStr];
        
        if ([tsEntryObject isTimeoffSickRowPresent])
        {
            middleLeft.frame=CGRectMake(10.0, 0.0, LABEL_WIDTH, height);
            [middleLeft setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
            [middleLeft setNumberOfLines:100];
        }
        else
        {
            [middleLeft setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
            middleLeft.frame=CGRectMake(10.0,5.0, LABEL_WIDTH, EachDayTimeEntry_Cell_Row_Height_44);
            [middleLeft setNumberOfLines:1];
        
        }
        
        float billingRateLower=middleLeft.frame.origin.y+middleLeft.frame.size.height;
        UILabel *billingRateLabel = [[UILabel alloc] init];
        billingRateLabel.frame=CGRectMake(10.0, billingRateLower+5, LABEL_WIDTH, billingHeight);
        [billingRateLabel setTextColor:[Util colorWithHex:@"#505151" alpha:1]];
        [billingRateLabel setBackgroundColor:[UIColor clearColor]];
        [billingRateLabel setTextAlignment:NSTextAlignmentLeft];
        [billingRateLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
        [billingRateLabel setText:billingRate];
        
        if (isLowerLabelTextWrap)
        {
            [billingRateLabel setNumberOfLines:1];
        }
        else
        {
            [billingRateLabel setNumberOfLines:100];
        }
        [billingRateLabel setHighlightedTextColor:[UIColor whiteColor]];
        [returnView addSubview:billingRateLabel];

        
        
        
    }
    else if (isTwoLine)
    {
        
        
        BOOL isTaskPresent=YES;
        NSString *timeEntryTaskName=[tsEntryObject timeEntryTaskName];
        if (timeEntryTaskName==nil || [timeEntryTaskName isKindOfClass:[NSNull class]]||[timeEntryTaskName isEqualToString:@""])
        {
            isTaskPresent=NO;
        }
        
        UILabel *upperLeft = [[UILabel alloc] init];
        upperLeft.frame=CGRectMake(10, 5, LABEL_WIDTH, upperLblHeight);
        [upperLeft setTextColor:[Util colorWithHex:@"#505151" alpha:1]];
        [upperLeft setBackgroundColor:[UIColor clearColor]];
        [upperLeft setTextAlignment:NSTextAlignmentLeft];
        
        if (isTaskPresent)
        {
            [upperLeft setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
        }
        else
        {
            [upperLeft setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
        }
        
        [upperLeft setText:upperStr];
        [upperLeft setNumberOfLines:100];
        [upperLeft setHighlightedTextColor:[UIColor whiteColor]];
        [returnView addSubview:upperLeft];
        
        float billingRateLower=upperLeft.frame.origin.y+upperLeft.frame.size.height;
        UILabel *billingRateLabel = [[UILabel alloc] init];
        billingRateLabel.frame=CGRectMake(10.0, billingRateLower+5, LABEL_WIDTH, billingHeight);
        [billingRateLabel setTextColor:[Util colorWithHex:@"#505151" alpha:1]];
        [billingRateLabel setBackgroundColor:[UIColor clearColor]];
        [billingRateLabel setTextAlignment:NSTextAlignmentLeft];
        [billingRateLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
        [billingRateLabel setText:billingRate];

        [billingRateLabel setHighlightedTextColor:[UIColor whiteColor]];
        [returnView addSubview:billingRateLabel];
        
        float activityPositionValue = billingRateLabel.frame.origin.y + billingRateLabel.frame.size.height+3;
        UILabel *activityOEFLabel = [[UILabel alloc] init];
        activityOEFLabel.frame=CGRectMake(10.0, activityPositionValue, LABEL_WIDTH, lowerLblHeight);
        [activityOEFLabel setTextColor:[Util colorWithHex:@"#505151" alpha:1]];
        [activityOEFLabel setBackgroundColor:[UIColor clearColor]];
        [activityOEFLabel setTextAlignment:NSTextAlignmentLeft];
        [activityOEFLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
        [activityOEFLabel setText:lowerStr];
        [activityOEFLabel setNumberOfLines:1];
        [activityOEFLabel setHighlightedTextColor:[UIColor whiteColor]];
        [returnView addSubview:activityOEFLabel];
        
        
    }
    else if (isThreeLine)
    {
        
        UILabel *upperLeft = [[UILabel alloc] init];
        upperLeft.frame=CGRectMake(10, 5, LABEL_WIDTH, upperLblHeight);
        [upperLeft setTextColor:[Util colorWithHex:@"#505151" alpha:1]];
        [upperLeft setBackgroundColor:[UIColor clearColor]];
        [upperLeft setTextAlignment:NSTextAlignmentLeft];
        [upperLeft setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
        [upperLeft setText:upperStr];
        [upperLeft setNumberOfLines:100];
        [upperLeft setHighlightedTextColor:[UIColor whiteColor]];
        [returnView addSubview:upperLeft];
        
        float ymiddle=upperLeft.frame.origin.y+upperLeft.frame.size.height+5;
        UILabel *middleLeft = [[UILabel alloc] init];
        middleLeft.frame=CGRectMake(10.0, ymiddle, LABEL_WIDTH, middleLblHeight);
        [middleLeft setTextColor:[Util colorWithHex:@"#505151" alpha:1]];
        [middleLeft setBackgroundColor:[UIColor clearColor]];
        [middleLeft setTextAlignment:NSTextAlignmentLeft];
        [middleLeft setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
        [middleLeft setText:middleStr];
        [middleLeft setNumberOfLines:100];
        [middleLeft setHighlightedTextColor:[UIColor whiteColor]];
        [returnView addSubview:middleLeft];
        
        float billinfRatelower=middleLeft.frame.origin.y+middleLeft.frame.size.height;
        UILabel *billingRateLabel = [[UILabel alloc] init];
        billingRateLabel.frame=CGRectMake(10.0, billinfRatelower+5, LABEL_WIDTH, billingHeight);
        [billingRateLabel setTextColor:[Util colorWithHex:@"#505151" alpha:1]];
        [billingRateLabel setBackgroundColor:[UIColor clearColor]];
        [billingRateLabel setTextAlignment:NSTextAlignmentLeft];
        [billingRateLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
        [billingRateLabel setText:billingRate];
        [billingRateLabel setNumberOfLines:1];
        [billingRateLabel setHighlightedTextColor:[UIColor whiteColor]];
        [returnView addSubview:billingRateLabel];
        
        float activityPositionValue = billingRateLabel.frame.origin.y + billingRateLabel.frame.size.height+3;
        UILabel *activityOEFLabel = [[UILabel alloc] init];
        activityOEFLabel.frame=CGRectMake(10.0, activityPositionValue, LABEL_WIDTH, lowerLblHeight);
        [activityOEFLabel setTextColor:[Util colorWithHex:@"#505151" alpha:1]];
        [activityOEFLabel setBackgroundColor:[UIColor clearColor]];
        [activityOEFLabel setTextAlignment:NSTextAlignmentLeft];
        [activityOEFLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
        [activityOEFLabel setText:lowerStr];
        [activityOEFLabel setNumberOfLines:1];
        [activityOEFLabel setHighlightedTextColor:[UIColor whiteColor]];
        [returnView addSubview:activityOEFLabel];
    }
    
    


    BOOL isTimeoffRow=NO;
    NSString *timeEntryTimeOffName=[tsEntryObject timeEntryTimeOffName];
    if (timeEntryTimeOffName!=nil && ![timeEntryTimeOffName isKindOfClass:[NSNull class]]&&![timeEntryTimeOffName isEqualToString:@""])
    {
        isTimeoffRow=YES;
    }
    

    float w_hoursLabel=HOURS_LABEL_WIDTH;
    UILabel *hoursLabel = [[UILabel alloc] init];
    hoursLabel.frame=CGRectMake(LABEL_PADDING+LABEL_WIDTH, 0.0, w_hoursLabel, height);
    [hoursLabel setTextColor:[Util colorWithHex:@"#505151" alpha:1]];
    [hoursLabel setBackgroundColor:[UIColor clearColor]];
    [hoursLabel setTextAlignment:NSTextAlignmentRight];
    [hoursLabel setNumberOfLines:1];
    [hoursLabel setHighlightedTextColor:[UIColor whiteColor]];
    [hoursLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
    [hoursLabel setText:[tsEntryObject timeEntryHoursInDecimalFormat]];
    [returnView addSubview:hoursLabel];
    [returnView setBackgroundColor:[UIColor greenColor]];
    
    if ([[tsEntryObject entryType] isEqualToString:Time_Off_Key])
    {
        hoursLabel.frame=CGRectMake(LABEL_WIDTH+(3*LABEL_PADDING), 0.0, w_hoursLabel, height);
    }
    else
    {
        if (([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
            [sheetApprovalStatus isEqualToString:APPROVED_STATUS ]) && [[tsEntryObject entryType] isEqualToString:Adhoc_Time_OffKey])
        {
            
        }
        else
        {
            UIImage *commentsOrArrowImg=[UIImage imageNamed:Disclosure_Box];
            UIImageView *commentsOrArrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(LABEL_WIDTH+LABEL_PADDING+5+w_hoursLabel, (height/2)-(commentsOrArrowImg.size.height/2), commentsOrArrowImg.size.width,commentsOrArrowImg.size.height)];
            [commentsOrArrowImageView setImage:commentsOrArrowImg];
            [returnView addSubview:commentsOrArrowImageView];
        }
       
    }
    

    return returnView;
    
    
    
    
}
-(void)editEntryButtonClicked
{
    //Implementation for US9371//JUHI
    if (commentsControlDelegate!=nil && [commentsControlDelegate isKindOfClass:[DayTimeEntryViewController class]])
    {
            DayTimeEntryViewController *ctrl=(DayTimeEntryViewController *)commentsControlDelegate;
            //MOBI-746
            NSString *programName=tsEntryObject.timeEntryProgramName;
            NSString *programUri=tsEntryObject.timeEntryProgramUri;
            NSString *projectName=tsEntryObject.timeEntryProjectName;
            NSString *projectUri=tsEntryObject.timeEntryProjectUri;
            NSString *clientName=tsEntryObject.timeEntryClientName;
            NSString *clientUri=tsEntryObject.timeEntryClientUri;
            NSString *taskName=tsEntryObject.timeEntryTaskName;
            NSString *taskUri=tsEntryObject.timeEntryTaskUri;
            NSString *activityName=tsEntryObject.timeEntryActivityName;
            NSString *activityUri=tsEntryObject.timeEntryActivityUri;
            NSString *billingName=tsEntryObject.timeEntryBillingName;
            NSString *billingUri=tsEntryObject.timeEntryBillingUri;
            NSString *timesheetUri=tsEntryObject.timesheetUri;
            NSString *rowUri=tsEntryObject.rowUri;
            NSString *timeoffName=[tsEntryObject timeEntryTimeOffName];
            NSString *timeoffUri=[tsEntryObject timeEntryTimeOffUri];

            NSString *rowNumber=[tsEntryObject rownumber];
        
            TimeEntryViewController *timeEntryVC=[[TimeEntryViewController alloc] init];
            timeEntryVC.delegate=ctrl.controllerDelegate;
            timeEntryVC.isEditBreak=FALSE;
        if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
        {
            NSMutableArray *rowoefArray=[tsEntryObject timeEntryRowOEFArray];
            timeEntryVC.editEntryRowUdfArray=rowoefArray;
        }
        else
        {
            NSMutableArray *rowudfArray=[tsEntryObject timeEntryRowUdfArray];
            timeEntryVC.editEntryRowUdfArray=rowudfArray;
        }

            TimesheetObject *timesheetObject=[[TimesheetObject alloc] init];
        
        
            [timesheetObject setRowNumber:rowNumber];
        
            if (projectUri == nil || [projectUri isKindOfClass:[NSNull class]]||[projectUri isEqualToString:@""])
            {
                projectUri=nil;
            }
            else
            {
                [timesheetObject setProjectName:projectName];
                [timesheetObject setProjectIdentity: projectUri];
            }
            //MOBI-746
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
            
            UIViewController *controllerViewCtrl=(UIViewController *)commentsControlDelegate;
            if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
            {
                timeEntryVC.screenViewMode=VIEW_PROJECT_ENTRY;
                timeEntryVC.approvalsModuleName=approvalsModuleName;
            }
            else
            {
                timeEntryVC.approvalsModuleName=nil;
                if ([tsEntryObject isRowEditable])
                {
                    if ([sheetApprovalStatus isEqualToString:NOT_SUBMITTED_STATUS]||[sheetApprovalStatus isEqualToString:REJECTED_STATUS])
                    {
                        timeEntryVC.screenViewMode=EDIT_PROJECT_ENTRY;
                    }
                    else
                    {
                        timeEntryVC.screenViewMode=VIEW_PROJECT_ENTRY;
                    }
                }
                else
                {
                    timeEntryVC.screenViewMode=VIEW_PROJECT_ENTRY;
                }
                
                
            }
            timeEntryVC.timesheetDataArray=ctrl.timesheetDataArray;
            timeEntryVC.timesheetStatus=sheetApprovalStatus;
            timeEntryVC.rowUriBeingEdited=rowUri;
            timeEntryVC.timesheetURI=timesheetUri;
            timeEntryVC.indexBeingEdited=row;
            timeEntryVC.controllerDelegate=self;
            timeEntryVC.isMultiDayInOutTimesheetUser=NO;
            if (timeoffUri!=nil&&![timeoffUri isKindOfClass:[NSNull class]]&&![timeoffUri isEqualToString:@""]&& ([sheetApprovalStatus isEqualToString:NOT_SUBMITTED_STATUS]||[sheetApprovalStatus isEqualToString:REJECTED_STATUS])) {
                timeEntryVC.isEditBreak=FALSE;
                timeEntryVC.selectedTimeoffString=timeoffName;
                timeEntryVC.screenMode=EDIT_Timeoff_ENTRY;
            }//Implementation for US9371//JUHI
            if ((([sheetApprovalStatus isEqualToString:NOT_SUBMITTED_STATUS]&& ![[tsEntryObject entryType] isEqualToString:Time_Off_Key])||([sheetApprovalStatus isEqualToString:REJECTED_STATUS]&& ![[tsEntryObject entryType] isEqualToString:Time_Off_Key])) || (([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS]||[sheetApprovalStatus isEqualToString:APPROVED_STATUS])&& (![[tsEntryObject entryType] isEqualToString:Adhoc_Time_OffKey]&& ![[tsEntryObject entryType] isEqualToString:Time_Off_Key]))) {
                [self.navigationController pushViewController:timeEntryVC animated:YES];

            }
            
        }
      if (isEditState)
       {
           if (commentsControlDelegate!=nil && [commentsControlDelegate isKindOfClass:[MultiDayInOutViewController class]])
           {
            MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)commentsControlDelegate;
               //MOBI-746
               NSString *programName=tsEntryObject.timeEntryProgramName;
               NSString *programUri=tsEntryObject.timeEntryProgramUri;
            NSString *projectName=tsEntryObject.timeEntryProjectName;
            NSString *projectUri=tsEntryObject.timeEntryProjectUri;
            NSString *clientName=tsEntryObject.timeEntryClientName;
            NSString *clientUri=tsEntryObject.timeEntryClientUri;
            NSString *taskName=tsEntryObject.timeEntryTaskName;
            NSString *taskUri=tsEntryObject.timeEntryTaskUri;
            NSString *activityName=tsEntryObject.timeEntryActivityName;
            NSString *activityUri=tsEntryObject.timeEntryActivityUri;
            NSString *billingName=tsEntryObject.timeEntryBillingName;
            NSString *billingUri=tsEntryObject.timeEntryBillingUri;
            NSString *timesheetUri=tsEntryObject.timesheetUri;
            NSString *rowUri=tsEntryObject.rowUri;
            NSString *timeoffName=[tsEntryObject timeEntryTimeOffName];
            NSString *timeoffUri=[tsEntryObject timeEntryTimeOffUri];
            NSString *rowNumber=[tsEntryObject rownumber];
            
            TimeEntryViewController *timeEntryVC=[[TimeEntryViewController alloc] init];
            timeEntryVC.delegate=ctrl.controllerDelegate;
            timeEntryVC.isEditBreak=FALSE;
            
            TimesheetObject *timesheetObject=[[TimesheetObject alloc] init];
               
            [timesheetObject setRowNumber:rowNumber];
               
            if (projectUri == nil || [projectUri isKindOfClass:[NSNull class]]||[projectUri isEqualToString:@""])
            {
                projectUri=nil;
            }
            else
            {
                [timesheetObject setProjectName:projectName];
                [timesheetObject setProjectIdentity: projectUri];
            }
               //MOBI-746
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
            
            UIViewController *controllerViewCtrl=(UIViewController *)commentsControlDelegate;
            if ([controllerViewCtrl.navigationController isKindOfClass:[ApprovalsNavigationController class]] || [controllerViewCtrl.navigationController isKindOfClass:[SupervisorDashboardNavigationController class]])
            {
                timeEntryVC.screenViewMode=VIEW_PROJECT_ENTRY;
            }
            else
            {
                timeEntryVC.approvalsModuleName=nil;
                if ([tsEntryObject isRowEditable]||[tsEntryObject isTimeoffSickRowPresent])
                {
                    if ([sheetApprovalStatus isEqualToString:NOT_SUBMITTED_STATUS]||[sheetApprovalStatus isEqualToString:REJECTED_STATUS])
                    {
                        timeEntryVC.screenViewMode=EDIT_PROJECT_ENTRY;
                    }
                    else
                    {
                        timeEntryVC.screenViewMode=VIEW_PROJECT_ENTRY;
                    }
                }
                else
                {
                    timeEntryVC.screenViewMode=VIEW_PROJECT_ENTRY;
                }
                
                
            }
            timeEntryVC.timesheetDataArray=ctrl.timesheetDataArray;
            timeEntryVC.timesheetStatus=sheetApprovalStatus;
            timeEntryVC.rowUriBeingEdited=rowUri;
            timeEntryVC.timesheetURI=timesheetUri;
            timeEntryVC.indexBeingEdited=section;
            timeEntryVC.controllerDelegate=self;
            timeEntryVC.isMultiDayInOutTimesheetUser=YES;
            if (timeoffUri!=nil&&![timeoffUri isKindOfClass:[NSNull class]]&&![timeoffUri isEqualToString:@""]&& ([sheetApprovalStatus isEqualToString:NOT_SUBMITTED_STATUS]||[sheetApprovalStatus isEqualToString:REJECTED_STATUS])) {
                timeEntryVC.isEditBreak=FALSE;
                timeEntryVC.selectedTimeoffString=timeoffName;
                timeEntryVC.screenMode=EDIT_Timeoff_ENTRY;
            }
            [self.navigationController pushViewController:timeEntryVC animated:YES];
        }
    }
    
    
   
}

-(void)reloadViewAfterEntryEdited
{
    self.tableHeaderView=[self getTableHeader];
    [self.inoutEntryTableView setTableHeaderView:self.tableHeaderView];
    
    
}
-(NSMutableAttributedString *)getTheAttributedTextForFontSize:(float)fontSize
{
    
    NSMutableArray *array=[NSMutableArray array];
    NSString *tsBillingName = [tsEntryObject timeEntryBillingName];
    NSString *tsActivityName=[tsEntryObject timeEntryActivityName];
    
    NSString *tmpBillingValue=@"";
    if (IsNotEmptyString(tsBillingName))
    {
        
        tmpBillingValue=BILLABLE;
    }
    else
    {
        tmpBillingValue=NON_BILLABLE;
    }
    
    if (isBillingAccess)
    {
        NSMutableDictionary *billingDict=[NSMutableDictionary dictionaryWithObject:tmpBillingValue forKey:@"BILLING"];
        [array addObject:billingDict];
    }
    else
    {
        tmpBillingValue=@"";
    }
    //DE18721 Ullas M L
    if (isActivityAccess)
    {
        if (tsActivityName!=nil && ![tsActivityName isKindOfClass:[NSNull class]]&& ![tsActivityName isEqualToString:@""])
        {
            NSMutableDictionary *activityDict=[NSMutableDictionary dictionaryWithObject:tsActivityName forKey:@"ACTIVITY"];
            [array addObject:activityDict];
            
        }
    }

    if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
    {
        for (int i=0; i<[self.oefFieldArray count]; i++)
        {
            OEFObject *oefObject=[self.oefFieldArray  objectAtIndex:i];
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
                NSMutableDictionary *oefDict=[NSMutableDictionary dictionaryWithObject:oefValue forKey:@"UDF"];
                [array addObject:oefDict];
            }

        }
    }
    else
    {
        for (int i=0; i<[self.userFieldArray count]; i++)
        {
            EntryCellDetails *cellDetails=[[tsEntryObject timeEntryUdfArray] objectAtIndex:i];
            NSString *udfValue=[cellDetails fieldValue];
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
    

    
    
    
    
    NSString *stringTobeReturned=[self getCalculatedStringForValues:array forFontSize:fontSize];
    NSMutableAttributedString *tmpattributedString = [[NSMutableAttributedString alloc]  initWithString:stringTobeReturned];
    if ([tmpBillingValue isEqualToString:NON_BILLABLE])
    {
        
        //DE18817 Ullas M L
        NSString *ver = [[UIDevice currentDevice] systemVersion];
        float ver_float = [ver newFloatValue];
        if (ver_float < 6.0)
        {
            [tmpattributedString addAttribute:(NSString*)kCTForegroundColorAttributeName
                                        value:(id)[[UIColor redColor] CGColor]
                                        range:NSMakeRange(0,[tmpBillingValue length])];
        }
        else
        {
            [tmpattributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,[tmpBillingValue length])];
        }
        
    }
    else
    {
        //DE18817 Ullas M L
        NSString *ver = [[UIDevice currentDevice] systemVersion];
        float ver_float = [ver newFloatValue];
        if (ver_float < 6.0)
        {
            [tmpattributedString addAttribute:(NSString*)kCTForegroundColorAttributeName
                                        value:(id)[Util colorWithHex:@"#505151" alpha:1]
                                        range:NSMakeRange(0,[tmpBillingValue length])];
        }
        else
        {
            [tmpattributedString addAttribute:NSForegroundColorAttributeName value:[Util colorWithHex:@"#505151" alpha:1] range:NSMakeRange(0,[tmpBillingValue length])];
        }
        
        
        
    }
    
    
    return tmpattributedString;
}

-(NSString *)getCalculatedStringForValues:(NSMutableArray *)valuesArray forFontSize:(float)repliconFontSize
{
    float labelWidth=LABEL_WIDTH;
    int sizeExceedingCount=0;
    NSMutableArray *arrayFinal=[NSMutableArray array];
    NSString *tempCompStr=@"";
    NSString *tempCompStrrr=@"";
    
    for (int i=0; i<[valuesArray count]; i++)
    {
        //NSArray *allKeys=[[array objectAtIndex:i] allKeys];
        NSArray *allValues=[[valuesArray objectAtIndex:i] allValues];
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
                str=[Util stringByTruncatingToWidth:labelWidth withFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12] ForString:str addQuotes:YES];
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
        
        NSString *str=(NSString *)[arrayFinal objectAtIndex:i];
        
        if (i==[arrayFinal count]-1)
        {
            if (sizeExceedingCount!=0)
            {
                tempfinalString=[tempfinalString stringByAppendingString:[NSString stringWithFormat:@" %@ | +%d",str,sizeExceedingCount]];
                CGSize stringSize = [tempfinalString sizeWithAttributes:
                                     @{NSFontAttributeName:
                                           [UIFont systemFontOfSize:9]}];
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

-(UIView *)getTableFooter
{
    float yOffsetForButtonFromTextView=30;
    float textViewHeight=0;
    CGRect screenRect =[[UIScreen mainScreen] bounds];
    float aspectRatio=(screenRect.size.height/screenRect.size.width);
    
    textViewHeight=aspectRatio*95;
    UIImage *normalImg = [Util thumbnailImage:DeleteTimesheetButtonImage];
    UIImage *highlightedImg = [Util thumbnailImage:DeleteTimesheetPressedButtonImage];
    float footerHeight=0.0;
    if (isEditState)
    {
        footerHeight=textViewHeight+2*yOffsetForButtonFromTextView+normalImg.size.height+40+COMMENTS_LABEL_HEIGHT;
    }
    else
    {
        footerHeight=textViewHeight+50+COMMENTS_LABEL_HEIGHT;
    }
    //ImplementationForExtendedInOutDeleteBreak_US9103//JUHI
    UIView *tempfooterView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, footerHeight)];
    if (!isBreakAccess)
    {
        
        UIView *lineViewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, 1)];
        lineViewTop.backgroundColor = [Util colorWithHex:@"#D6D6D6" alpha:1];
        [tempfooterView addSubview:lineViewTop];
        
        BOOL hasCommentsAccess=YES;
        
        if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
        {
            SupportDataModel *supportDataModel=[[SupportDataModel alloc]init];
            NSDictionary *permittedApprovalAcionsDict=[supportDataModel getTimesheetPermittedApprovalActionsDataToDBWithUri:[tsEntryObject timesheetUri]];
            hasCommentsAccess=[[permittedApprovalAcionsDict objectForKey:@"allowCommentsForStandardGen4"]boolValue];
        }
        
        UILabel *hourLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0,self.view.frame.size.width, COMMENTS_LABEL_HEIGHT)];
        hourLabel.backgroundColor = [UIColor clearColor];
        hourLabel.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14];
        hourLabel.textAlignment = NSTextAlignmentLeft;
        hourLabel.userInteractionEnabled=NO;
        hourLabel.text=RPLocalizedString(Comments, @"");
        hourLabel.textColor=RepliconStandardGrayColor;
        
        if (hasCommentsAccess)
        {
            [tempfooterView addSubview:hourLabel];
            [tempfooterView bringSubviewToFront:hourLabel];
        }
        

        if (hasCommentsAccess)
        {
            self.commentsPlaceholderButton =[UIButton buttonWithType:UIButtonTypeCustom];
            [self.commentsPlaceholderButton setFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height)];
            [self.commentsPlaceholderButton addTarget:self action:@selector(becomeFirstResponderAction) forControlEvents:UIControlEventTouchUpInside];
            self.commentsPlaceholderButton.contentHorizontalAlignment= UIControlContentHorizontalAlignmentCenter;
            //commentsPlaceholderButton.backgroundColor=[UIColor redColor];
            [tempfooterView addSubview:self.commentsPlaceholderButton];
            
            NSString *comments=[tsEntryObject timeEntryComments];
            UITextView *descTextView = [[UITextView alloc] initWithFrame:CGRectMake(5, COMMENTS_LABEL_HEIGHT-10, self.view.frame.size.width, textViewHeight)];
            descTextView.textColor = RepliconStandardBlackColor;
            descTextView.scrollEnabled = YES;
            [descTextView setShowsVerticalScrollIndicator:YES];
            [descTextView setShowsHorizontalScrollIndicator:NO];
            [descTextView setAutocorrectionType: UITextAutocorrectionTypeYes];
            [descTextView setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
            descTextView.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15];
            descTextView.delegate = self;
            descTextView.backgroundColor = [UIColor clearColor];
            //descTextView.returnKeyType = UIReturnKeyDone;
            descTextView.keyboardType = UIKeyboardTypeASCIICapable;
            descTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            [descTextView setBackgroundColor:[Util colorWithHex:@"#f8f8f8" alpha:1]];
            self.commentsTextView=descTextView;
            [descTextView setText:comments];
            [tempfooterView addSubview: descTextView];
            [tempfooterView sendSubviewToBack: descTextView];
            
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, COMMENTS_LABEL_HEIGHT+textViewHeight,self.view.frame.size.width, 1)];
            if (isBreakAccess)
            {
                lineView.frame=CGRectMake(0, COMMENTS_LABEL_HEIGHT,self.view.frame.size.width, 1);
            }
            lineView.backgroundColor = [Util colorWithHex:@"#D6D6D6" alpha:1];
            [tempfooterView addSubview:lineView];
        
        }

        
        
    }
    BOOL isTimeEntry=NO;
    if (![[tsEntryObject entryType] isEqualToString:Adhoc_Time_OffKey]&& ![[tsEntryObject entryType] isEqualToString:Time_Off_Key])
    {
        isTimeEntry=YES;
    }
    
    
    if (isEditState && isTimeEntry==NO && ![[tsEntryObject entryType] isEqualToString:Time_Off_Key])
    {
        UIButton *deleteButton =[UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setFrame:CGRectMake((SCREEN_WIDTH-normalImg.size.width)/2, COMMENTS_LABEL_HEIGHT+textViewHeight+yOffsetForButtonFromTextView, normalImg.size.width,  normalImg.size.height)];
        [deleteButton setBackgroundImage:normalImg forState:UIControlStateNormal];
        [deleteButton setBackgroundImage:highlightedImg forState:UIControlStateHighlighted];
        if (isBreakAccess)
        {
            [deleteButton setFrame:CGRectMake((SCREEN_WIDTH-normalImg.size.width)/2, COMMENTS_LABEL_HEIGHT+1, normalImg.size.width,  normalImg.size.height)];
            [deleteButton setTitle:RPLocalizedString(DELETE_BREAKENTRY_STRING,@"") forState:UIControlStateNormal];
        }
        else
            [deleteButton setTitle:RPLocalizedString(DELETE_ENTRY_STRING,@"") forState:UIControlStateNormal];
        [deleteButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16]];
        [deleteButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
        deleteButton.contentHorizontalAlignment= UIControlContentHorizontalAlignmentCenter;
        [tempfooterView addSubview:deleteButton];
        
    }
    
    
    if (!isEditState ||[[tsEntryObject entryType] isEqualToString:Time_Off_Key])
    {
        [self.commentsTextView setEditable:NO];
    }
    return tempfooterView;
    
}
-(UIView *)getTableHeader
{
    UIView *headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, HEADER_LABEL_HEIGHT)];
    CGRect frame=CGRectMake(0, 0, SCREEN_WIDTH, HEADER_LABEL_HEIGHT);
    UIView *headerBackgroundView=[[UIView alloc]initWithFrame:frame];
    [headerBackgroundView setBackgroundColor:[Util colorWithHex:@"#eeeeee" alpha:1]];
    [headerView addSubview:headerBackgroundView];
    
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"EEEE, MMM dd, yyy"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString *string=[formatter stringFromDate:currentPageDate];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectInset(frame, LABEL_PADDING, 0)];
    headerLabel.backgroundColor = [Util colorWithHex:@"#eeeeee" alpha:1];
    headerLabel.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12];
    headerLabel.textAlignment = NSTextAlignmentLeft;
    headerLabel.text=[NSString stringWithFormat:@"%@ %@", RPLocalizedString(ON_TEXT, ON_TEXT),string];
    [headerView addSubview:headerLabel];
    
    
    UIView *separatorView=[[UIView alloc]initWithFrame:CGRectMake(0, HEADER_LABEL_HEIGHT, SCREEN_WIDTH, 1)];
    [separatorView setBackgroundColor:[Util colorWithHex:@"#D6D6D6" alpha:1]];
    [headerView addSubview:separatorView];
    
    
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
        NSString *timeEntryProjectName=[tsEntryObject timeEntryProjectName];
        if (timeEntryTaskName==nil || [timeEntryTaskName isKindOfClass:[NSNull class]]||[timeEntryTaskName isEqualToString:@""])
        {
            
            if (self.isProjectAccess)
            {
                
                BOOL isBothClientAndProjectNull=[self checkIfBothProjectAndClientIsNull:timeEntryClientName projectName:timeEntryProjectName];
                
                if (isBothClientAndProjectNull)
                {
                    
                    //No task client and project.Only third row consiting of activity/udf's or billing
                    
                    NSString *attributeText=[self getTheAttributedTextForEntryObject];
                    isMiddleLabelTextWrap=YES;
                    middleStr=attributeText;
                    middleLabelHeight=[self getHeightForString:attributeText fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                    [heightDict setObject:@"SINGLE" forKey:LINE];
                    
                }
                else
                {
                    
                    NSString *attributeText=[self getTheAttributedTextForEntryObject];
                    
                        
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
            else
            {
                
                NSString *attributeText=[self getTheAttributedTextForEntryObject];
                middleStr=attributeText;
                middleLabelHeight=[self getHeightForString:middleStr fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                [heightDict setObject:@"SINGLE" forKey:LINE];
                isMiddleLabelTextWrap=YES;
                
                
            }
            
            
        }
        else
        {
            upperStr=timeEntryTaskName;
            NSString *attributeText=[self getTheAttributedTextForEntryObject];
            if (attributeText==nil ||[attributeText isKindOfClass:[NSNull class]]||[attributeText isEqualToString:@""])
            {
                
                if (timeEntryClientName==nil || [timeEntryClientName isKindOfClass:[NSNull class]]||[timeEntryClientName isEqualToString:@""]||[timeEntryClientName isEqualToString:NULL_STRING])
                {
                    middleStr=[NSString stringWithFormat:@"in %@",timeEntryProjectName];
                }
                else
                {
                    middleStr=[NSString stringWithFormat:@"in %@ for %@",timeEntryProjectName,timeEntryClientName];
                }
                middleLabelHeight=[self getHeightForString:middleStr fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                upperLabelHeight=[self getHeightForString:upperStr fontSize:RepliconFontSize_16 forWidth:LABEL_WIDTH];
                lowerLabelHeight=[self getHeightForString:lowerStr fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                [heightDict setObject:@"TRIPLE" forKey:LINE];
                
                
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
                lowerStr=[self getTheAttributedTextForEntryObject];
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
    
    if (cellHeight<EachDayTimeEntry_Cell_Row_Height_55)
    {
        cellHeight=EachDayTimeEntry_Cell_Row_Height_55;
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
    billingRateLabelHeight = [self getHeightForString:tmpBillingValue fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
     if (!isBillingAccess)
     {
         billingRateLabelHeight = 0.0;
         tmpBillingValue=@"";
     }
    
    cellHeight=upperLabelHeight+middleLabelHeight+lowerLabelHeight+ billingRateLabelHeight +2*verticalOffset+numberOfLabels*5;

    
    [heightDict setObject:[NSString stringWithFormat:@"%f",upperLabelHeight] forKey:UPPER_LABEL_HEIGHT];
    [heightDict setObject:[NSString stringWithFormat:@"%f",middleLabelHeight] forKey:MIDDLE_LABEL_HEIGHT];
    [heightDict setObject:[NSString stringWithFormat:@"%f",lowerLabelHeight] forKey:LOWER_LABEL_HEIGHT];
    [heightDict setObject:[NSString stringWithFormat:@"%f",billingRateLabelHeight] forKey:BILLING_LABEL_HEIGHT];
    [heightDict setObject:[NSString stringWithFormat:@"%@",upperStr] forKey:UPPER_LABEL_STRING];
    [heightDict setObject:[NSString stringWithFormat:@"%@",middleStr] forKey:MIDDLE_LABEL_STRING];
    [heightDict setObject:[NSString stringWithFormat:@"%@",lowerStr] forKey:LOWER_LABEL_STRING];
    [heightDict setObject:[NSString stringWithFormat:@"%d",isUpperLabelTextWrap] forKey:UPPER_LABEL_TEXT_WRAP];
    [heightDict setObject:[NSString stringWithFormat:@"%d",isMiddleLabelTextWrap] forKey:MIDDLE_LABEL_TEXT_WRAP];
    [heightDict setObject:[NSString stringWithFormat:@"%d",isLowerLabelTextWrap] forKey:LOWER_LABEL_TEXT_WRAP];
    [heightDict setObject:[NSString stringWithFormat:@"%f",cellHeight] forKey:CELL_HEIGHT_KEY];
    [heightDict setObject:tmpBillingValue forKey:BILLING_RATE];
    
    UIView *tmpHeaderView=[[UIView alloc]initWithFrame:CGRectMake(0, HEADER_LABEL_HEIGHT, SCREEN_WIDTH, cellHeight)];
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, HEADER_LABEL_HEIGHT, SCREEN_WIDTH, cellHeight)];
    view=[self initialiseView:heightDict];
    [tmpHeaderView addSubview:view];
    [headerView addSubview:tmpHeaderView];
    
    UIView *separatorViewBottom=[[UIView alloc]initWithFrame:CGRectMake(0, HEADER_LABEL_HEIGHT+cellHeight, SCREEN_WIDTH, 1)];
    [separatorViewBottom setBackgroundColor:[Util colorWithHex:@"#D6D6D6" alpha:1]];
    [headerView addSubview:separatorViewBottom];

    
    
    UIButton *dummyButton=[UIButton buttonWithType:UIButtonTypeCustom];
    [dummyButton setBackgroundColor:[UIColor clearColor]];
    [dummyButton addTarget:self action:@selector(editEntryButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [dummyButton setFrame:CGRectMake(0,HEADER_LABEL_HEIGHT, SCREEN_WIDTH,cellHeight)];
    [dummyButton setAccessibilityIdentifier:@"uia_timesheet_entry_details_cell_btn_identifier"];
    
    if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
        [sheetApprovalStatus isEqualToString:APPROVED_STATUS ]||isEditState==NO||[[tsEntryObject entryType] isEqualToString:Time_Off_Key])
    {
        [dummyButton setUserInteractionEnabled:YES];
    }
    [headerView addSubview:dummyButton];
    

    UIImage *pointedImage = [Util thumbnailImage:POINTED_IMAGE];
    UIView *separatorHeaderView=[[UIView alloc]initWithFrame:CGRectMake(0, HEADER_LABEL_HEIGHT+cellHeight, SCREEN_WIDTH, pointedImage.size.height)];
    [separatorHeaderView setBackgroundColor:[Util colorWithHex:@"#d6d6d6" alpha:1.0]];
    [headerView addSubview:separatorHeaderView];
    [headerView bringSubviewToFront:separatorHeaderView];
    
    
    UIImageView *pointedView=[[UIImageView alloc]initWithFrame:CGRectMake(self.view.width-HOURS_LABEL_WIDTH-LABEL_PADDING, HEADER_LABEL_HEIGHT+cellHeight, pointedImage.size.width, pointedImage.size.height)];
    [pointedView setImage:pointedImage];
    [headerView addSubview:pointedView];
    
    [headerView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, HEADER_LABEL_HEIGHT+cellHeight+separatorHeaderView.frame.size.height)];
    
    return headerView;
    
}

-(void)resetTableSize:(BOOL)isResetTable isFromUdf:(BOOL)isFromUdf isDateUdf:(BOOL)isDateUdf
{
    if (isResetTable)
    {
        if (isFromUdf)
        {
            CGRect frame= self.inoutEntryTableView.frame;
            
            
            if (isDateUdf)
            {
                frame.size.height=frame.size.height-resetTableSpaceHeight_Date_UDF;
            }
            else
            {
                frame.size.height=frame.size.height-resetTableSpaceHeight_Other_UDF;
                
            }
            
            [self.inoutEntryTableView setFrame:frame];
        }
        else
        {
            CGRect frame= self.inoutEntryTableView.frame;
            CGRect screenRect =[[UIScreen mainScreen] bounds];
            float aspectRatio=(screenRect.size.height/screenRect.size.width);
            float movementDistanceoffSet=0.0;
            if (aspectRatio<1.7)
            {
                movementDistanceoffSet=86;
            }
            else
            {
                movementDistanceoffSet=140;
            }
            frame.size.height=frame.size.height-movementDistanceoffSet;
            [self.inoutEntryTableView setFrame:frame];
            
            if (!isTextViewBecomeFirstResponder)
            {
                [self.inoutEntryTableView scrollRectToVisible:[self.inoutEntryTableView convertRect:self.inoutEntryTableView.tableFooterView.bounds fromView:self.inoutEntryTableView.tableFooterView] animated:YES];
            }
            
            
            
        }
        
        
        
    }
    else
    {
        [self.inoutEntryTableView setFrame:CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height)];
        [self.inoutEntryTableView scrollRectToVisible:CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height) animated:NO];
        
    }
    
}

-(float)getHeightForString:(NSString *)string fontSize:(int)fontSize forWidth:(float)width
{
    
    // Let's make an NSAttributedString first
    NSMutableAttributedString *attributedString1 = [[NSMutableAttributedString alloc] initWithString:string];
    //Add LineBreakMode
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [attributedString1 setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString1.length)];
    // Add Font
    [attributedString1 setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} range:NSMakeRange(0, attributedString1.length)];
    
    //Now let's make the Bounding Rect
    CGSize mainSize = [attributedString1 boundingRectWithSize:CGSizeMake(width, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
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
            fontName=RepliconFontFamilyBold;
        }
        else
        {
            fontName=RepliconFontFamily;
        }
        CGSize maxSize = CGSizeMake(width, MAXFLOAT);
        CGRect labelRect = [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:fontName size:fontSize]} context:nil];
        return labelRect.size.height;
    }
    return mainSize.height;
}

//UPDATE: if This method is only for truncating the text we can remove this method, beacause label will automatically truncates the text
-(NSString *)getTheAttributedTextForEntryObject
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

    
    if (numberOfUDF==0)
    {
        self.userFieldArray=[tsEntryObject timeEntryUdfArray];
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
    
    //Implementation forMobi-181//JUHI
    if(!isBillingAccess&&!isActivityAccess && isRowUdf && (commentsControlDelegate!=nil && [commentsControlDelegate isKindOfClass:[DayTimeEntryViewController class]]))
    {

        if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
        {
            for (int i=0; i<[self.oefFieldArray count]; i++)
            {
                OEFObject *oefObject=[self.oefFieldArray  objectAtIndex:i];
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
                    NSMutableDictionary *oefDict=[NSMutableDictionary dictionaryWithObject:oefValue forKey:@"UDF"];
                    [array addObject:oefDict];
                }
                
            }
            for (int i=0; i<numberOfUDF; i++)
            {
                NSString *udfValue=nil;
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
            }
        }
        else
        {
            [self constructRowUDFArray:array];

        }

    }
    if (commentsControlDelegate!=nil && [commentsControlDelegate isKindOfClass:[DayTimeEntryViewController class]])
    {
        if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
        {
            for (int i=0; i<[self.oefFieldArray count]; i++)
            {
                OEFObject *oefObject=[self.oefFieldArray  objectAtIndex:i];
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
                    NSMutableDictionary *oefDict=[NSMutableDictionary dictionaryWithObject:oefValue forKey:@"UDF"];
                    [array addObject:oefDict];
                }
                
            }
            
            for (int i=0; i<numberOfUDF; i++)
            {
                NSString *udfValue=nil;
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
            }


        }
        else
        {
            [self constructRowUDFArray:array];

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
    if ([finalString isEqualToString:@""] && (commentsControlDelegate!=nil && [commentsControlDelegate isKindOfClass:[DayTimeEntryViewController class]]))
    {
        //fix forMobi-192//JUHI
        if (!isProjectAccess&&!isBillingAccess && !isActivityAccess && isRowUdf)
        {
            finalString=RPLocalizedString(NO_SELECTION, @"");
            
        }
            
        
    }
    return finalString;
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

#pragma mark UITextView Delegates

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self doneClicked];
    self.lastUsedTextField =nil;
    [self resetTableSize:YES isFromUdf:NO isDateUdf:NO];
    self.isTextViewBecomeFirstResponder=NO;
    UIBarButtonItem *tempRightButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(Done_Button_Title, @"") style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonAction:)];
    [self navigationItem].rightBarButtonItem=tempRightButtonOuterBtn;
    
    [self.inoutEntryTableView setScrollEnabled:NO];
	return YES;
}

- (BOOL) textView: (UITextView*) textView shouldChangeTextInRange: (NSRange) range replacementText: (NSString*) text
{
    /*if ([text isEqualToString:@"\n"]) {
     [self resetTableSize:NO isFromUdf:NO isDateUdf:NO];
     [textView resignFirstResponder];
     
     return NO;
     }*/
    return YES;
}

-(void)doneButtonAction:(id)sender
{
    [self.inoutEntryTableView setScrollEnabled:YES];
    [self resetTableSize:NO isFromUdf:NO isDateUdf:NO];
    [self.commentsTextView resignFirstResponder];
    [self.commentsPlaceholderButton setHidden:NO];
    [self.commentsTextView setContentOffset:CGPointZero animated:NO];
    
    UIBarButtonItem *tempRightButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(Save_Button_Title, @"") style:UIBarButtonItemStylePlain target:self action:@selector(saveAction:)];
    [self navigationItem].rightBarButtonItem=tempRightButtonOuterBtn;
    
    
}

#pragma mark - Tableview methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return Each_Cell_Row_Height_44;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{//ImplementationForExtendedInOutDeleteBreak_US9103//JUHI
    if (!isBreakAccess)
    {
        if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
        {
           return [self.oefFieldArray count];
        }
        else
        {
           return [self.userFieldArray count];
        }

    }
	return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"TimeSheetCellIdentifier";
	InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil)
    {
        cell = [[InOutEntryDetailsCustomCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.contentView.backgroundColor = [Util colorWithHex:@"#f8f8f8" alpha:1];
        
	}

    NSString *fieldType=nil;
    NSString *fieldName=nil;
    NSString *fieldValue=nil;
    EntryCellDetails *udfDetails=nil;
    OEFObject *oefObject=nil;

    if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
    {
        oefObject=[self.oefFieldArray objectAtIndex:indexPath.row];
        fieldName=[oefObject oefName];
        if (oefObject.oefNumericValue!=nil && ![oefObject.oefNumericValue isKindOfClass:[NSNull class]])
        {
            fieldValue=[oefObject oefNumericValue];
        }
        else if (oefObject.oefTextValue!=nil && ![oefObject.oefTextValue isKindOfClass:[NSNull class]])
        {
            fieldValue=[oefObject oefTextValue];
        }
        else if (oefObject.oefDropdownOptionValue!=nil && ![oefObject.oefDropdownOptionValue isKindOfClass:[NSNull class]])
        {
            fieldValue=[oefObject oefDropdownOptionValue];
        }

        fieldType=[oefObject oefDefinitionTypeUri];


    }
    else
    {
        udfDetails=[self.userFieldArray objectAtIndex:indexPath.row];
        fieldName=[udfDetails fieldName];
        fieldValue=[udfDetails fieldValue];
        fieldType=[udfDetails fieldType];
    }
    

    
    [cell createCellLayoutWithParamsWithFieldName:fieldName withFieldValue:fieldValue isEditState:isEditState];
    cell.udfType=fieldType;
    if ([fieldType isEqualToString:UDFType_DATE])
    {
        if ([fieldValue isKindOfClass:[NSString class]] &&[fieldValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])
        {
            [cell.fieldButton setText:RPLocalizedString(NONE_STRING, @"")];
        }
        else
        {
            if ([fieldValue isKindOfClass:[NSString class]]&&[fieldValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
            {
                [cell.fieldButton setText:fieldValue];
            }
            else
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                
                NSLocale *locale=[NSLocale currentLocale];
                [dateFormatter setLocale:locale];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                [dateFormatter setDateFormat:@"MMM d, yyyy"];
                NSDate *date=[dateFormatter dateFromString:fieldValue];
                [dateFormatter setDateFormat:@"MMMM d, yyyy"];
                [cell.fieldButton setText: [dateFormatter stringFromDate:date]];
                
                
            }
        }
        
        cell.fieldButton.hidden=NO;
        cell.fieldValue.hidden=YES;
        if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
            [sheetApprovalStatus isEqualToString:APPROVED_STATUS ])
        {
            cell.contentView.userInteractionEnabled=NO;
        }
        else
        {
            cell.contentView.userInteractionEnabled=YES;
        }
        
    }
    else if([fieldType isEqualToString:UDFType_NUMERIC] || [fieldType isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI])
    {
        [cell.fieldButton setText:[NSString stringWithFormat:@"%@",fieldValue]];

        if (fieldValue==nil)
        {
            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[sheetApprovalStatus isEqualToString:APPROVED_STATUS ])
            {
                cell.fieldButton.text=RPLocalizedString(NONE_STRING, @"");
            }
            else
            {
                cell.fieldButton.text=RPLocalizedString(ADD, @"");
            }


        }

        cell.fieldValue.text=[NSString stringWithFormat:@"%@",fieldValue];
        cell.fieldButton.hidden=NO;
        cell.fieldValue.hidden=YES;
        cell.fieldValue.keyboardType = UIKeyboardTypeNumberPad;
         if (![self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
        {
            cell.decimalPoints=[udfDetails decimalPoints];
        }
        else
        {
            cell.decimalPoints=2.0;
        }

        if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
            [sheetApprovalStatus isEqualToString:APPROVED_STATUS ])
        {
            cell.contentView.userInteractionEnabled=NO;
        }
        else
        {
            cell.contentView.userInteractionEnabled=YES;
        }
        
    }
    else if ([fieldType isEqualToString:UDFType_DROPDOWN] || [fieldType isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI])
    {
        [cell.fieldButton setText:fieldValue];
        if (fieldValue==nil)
        {
            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[sheetApprovalStatus isEqualToString:APPROVED_STATUS ])
            {
                cell.fieldButton.text=RPLocalizedString(NONE_STRING, @"");
            }
            else
            {
                cell.fieldButton.text=RPLocalizedString(SELECT_STRING, @"");
            }

            
        }
        cell.fieldButton.hidden=NO;
        cell.fieldValue.hidden=YES;
        if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
            [sheetApprovalStatus isEqualToString:APPROVED_STATUS ])
        {
            cell.contentView.userInteractionEnabled=NO;
        }
        else
        {
            cell.contentView.userInteractionEnabled=YES;
        }
        
    }
    
    else if([fieldType isEqualToString:UDFType_TEXT] || [fieldType isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI])
    {
        cell.fieldButton.text=fieldValue;
        if (fieldValue==nil)
        {
            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[sheetApprovalStatus isEqualToString:APPROVED_STATUS ])
            {
                cell.fieldButton.text=RPLocalizedString(NONE_STRING, @"");
            }
            else
            {
                cell.fieldButton.text=RPLocalizedString(ADD, @"");
            }

            
        }

        cell.fieldButton.hidden=NO;
        cell.fieldValue.hidden=YES;
        if (([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[sheetApprovalStatus isEqualToString:APPROVED_STATUS ])&&([cell.fieldButton.text isEqualToString:RPLocalizedString(ADD, @"")]||[cell.fieldButton.text isEqualToString:RPLocalizedString(NONE_STRING, @"")]))
        {
            cell.contentView.userInteractionEnabled=NO;
        }
        else
        {
            cell.contentView.userInteractionEnabled=YES;
        }
        
    }
    cell.isNonEditable=NO;
    if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
        [sheetApprovalStatus isEqualToString:APPROVED_STATUS ]||isEditState==NO||[[tsEntryObject entryType] isEqualToString:Time_Off_Key])
    {
        cell.contentView.userInteractionEnabled=NO;
        cell.fieldButton.userInteractionEnabled=NO;
        cell.fieldValue.userInteractionEnabled=NO;
        cell.isNonEditable=YES;
        
        if(([fieldType isEqualToString:UDFType_TEXT] || [fieldType isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI]) && ((![cell.fieldButton.text isEqualToString:RPLocalizedString(ADD, @"")]) &&
                                                        (![cell.fieldButton.text isEqualToString:RPLocalizedString(NONE_STRING, @"")])))
        {
           isEditState=YES;
           cell.contentView.userInteractionEnabled=YES;
           cell.isNonEditable=NO;
        }
        
    }
    
    [cell setDelegate:self];
    [cell.contentView setTag:indexPath.row];
    if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
    {
        [cell setTotalCount:[self.oefFieldArray count]];
    }
    else
    {
        [cell setTotalCount:[self.userFieldArray count]];
    }

    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
	return cell;
	
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Save/Cancel methods

- (void)saveAction:(id)sender
{
    [self doneClicked];
    [lastUsedTextField resignFirstResponder];
    [self.commentsTextView resignFirstResponder];
    [self.commentsPlaceholderButton setHidden:NO];
    [self.commentsTextView setContentOffset:CGPointZero animated:NO];
    
    if (commentsControlDelegate!=nil && [commentsControlDelegate isKindOfClass:[DayTimeEntryViewController class]])
    {
        DayTimeEntryViewController *ctrl=(DayTimeEntryViewController *)commentsControlDelegate;
        if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
        {
            [ctrl updateComments:self.commentsTextView.text andUdfArray:self.oefFieldArray forRow:row];
        }
        else
        {
           [ctrl updateComments:self.commentsTextView.text andUdfArray:[self.userFieldArray copy] forRow:row];
        }

    }
    else if (commentsControlDelegate!=nil && [commentsControlDelegate isKindOfClass:[MultiDayInOutViewController class]])
    {
        MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)commentsControlDelegate;
        if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
        {
            [ctrl updateComments:self.commentsTextView.text andUdfArray:self.oefFieldArray forRow:section];
        }
        else
        {
            [ctrl updateComments:self.commentsTextView.text andUdfArray:self.userFieldArray forRow:section];
        }

    }
    
    [self.navigationController popViewControllerAnimated:YES];
    [datePicker removeFromSuperview];
    datePicker=nil;
}

- (void)cancelAction:(id)sender
{
    [self doneClicked];
    [lastUsedTextField resignFirstResponder];
    [self.commentsTextView resignFirstResponder];
    [self.commentsPlaceholderButton setHidden:NO];
    [self.commentsTextView setContentOffset:CGPointZero animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
    [datePicker removeFromSuperview];
    datePicker=nil;
}
- (void)deleteAction:(id)sender
{
    [self.commentsTextView resignFirstResponder];
    [self.lastUsedTextField resignFirstResponder];
    [self.commentsPlaceholderButton setHidden:NO];
    [self.commentsTextView setContentOffset:CGPointZero animated:NO];
    [self doneClicked];
    InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[self. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedUdfCell inSection:0]];
    [cell.fieldValue resignFirstResponder];
    if (commentsControlDelegate!=nil && [commentsControlDelegate isKindOfClass:[DayTimeEntryViewController class]])
    {
        DayTimeEntryViewController *ctrl=(DayTimeEntryViewController *)commentsControlDelegate;
        [ctrl deleteEntryforRow:row withDelegate:self];
    }
    else if (commentsControlDelegate!=nil && [commentsControlDelegate isKindOfClass:[MultiDayInOutViewController class]])
    {
        MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)commentsControlDelegate;
        [ctrl deleteEntryforRow:section withDelegate:self];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
    [datePicker removeFromSuperview];
    datePicker=nil;
}

-(void) handleUdfCellClick:(NSInteger)indexPath withType:(NSString*)typeStr
{
    
    InOutEntryDetailsCustomCell *previouscell = (InOutEntryDetailsCustomCell *)[self. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedUdfCell inSection:0]];
    [previouscell setSelected:NO animated:NO];
    
    self.selectedUdfCell=indexPath;
    [lastUsedTextField resignFirstResponder];
    [self.commentsTextView resignFirstResponder];
    [self.commentsPlaceholderButton setHidden:NO];
    [self.commentsTextView setContentOffset:CGPointZero animated:NO];
    
    if ([typeStr isEqualToString:UDFType_DATE])
    {
        
        InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[self. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath inSection:0]];
        [cell setSelected:YES animated:NO];
        [cell.fieldValue resignFirstResponder];
        [self resetTableSize:YES isFromUdf:YES isDateUdf:YES];
        [self datePickerAction];
        [self.inoutEntryTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        
    }
    if ([typeStr isEqualToString:UDFType_DROPDOWN] || [typeStr isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI])
    {
        [self resetTableSize:NO isFromUdf:NO isDateUdf:NO];
        [self doneClicked];
        [self dataAction:indexPath];
        [self.inoutEntryTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    if ([typeStr isEqualToString:UDFType_NUMERIC] || [typeStr isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI])
    {
        [lastUsedTextField becomeFirstResponder];
        self.datePicker.hidden=YES;
        self.toolbar.hidden=YES;
        InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[self. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath inSection:0]];
        cell.fieldButton.hidden=YES;
        [cell setSelected:YES animated:NO];
        [cell.fieldValue setAccessibilityIdentifier:@"uia_cell_level_numeric_udf_value_identifier"];
    }
    if ([typeStr isEqualToString:UDFType_TEXT] || [typeStr isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI])
    {
        [self resetTableSize:NO isFromUdf:NO isDateUdf:NO];
        [self doneClicked];
        [self textUdfAction:indexPath];
        [self.inoutEntryTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    
    
}

#pragma mark - Date Udf methods

-(void)datePickerAction
{
    
    InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[self. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedUdfCell inSection:0]];
    id fieldValue=nil;
    
    if ([cell fieldButton].text!=nil)
    {
        fieldValue =[cell fieldButton].text;
    }
    
    NSString *dateStr=fieldValue;
    self.previousDateUdfValue=dateStr;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIDatePicker *tempdatePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    self.datePicker=tempdatePicker;
    CGFloat datePickerYPosition = screenRect.size.height-(tempdatePicker.size.height+self.tabBarController.tabBar.height+self.navigationController.navigationBar.height);
    self.datePicker.frame=CGRectMake(0,datePickerYPosition, self.view.frame.size.width, tempdatePicker.size.height);
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.timeZone=[NSTimeZone timeZoneForSecondsFromGMT:0];
    self.datePicker.hidden = NO;
    
    [self.datePicker setAccessibilityIdentifier:@"uia_cell_level_date_udf_picker_identifier"];
    
    if ([fieldValue isKindOfClass:[NSString class]])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        NSLocale *locale=[NSLocale currentLocale];
        [dateFormatter setLocale:locale];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        if ([dateStr isEqualToString:RPLocalizedString(SELECT_STRING, @"")]) {
            self.datePicker.date = [NSDate date];
            
        }
        else{
            [dateFormatter setDateFormat:@"MMMM d, yyyy"];//DE10538//JUHI
            fieldValue = [dateFormatter dateFromString:dateStr];
            self.datePicker.date = fieldValue;
        }
        
    }
    
    [self.datePicker addTarget:self
                        action:@selector(updateFieldWithPickerChange:)
              forControlEvents:UIControlEventValueChanged];
    if ([[cell fieldButton].text isEqualToString:RPLocalizedString(SELECT_STRING, @"")] || [[cell fieldButton].text isKindOfClass:[NSNull class]] || [cell fieldButton].text==nil )
    {
        [self updateFieldWithPickerChange:self.datePicker];
    }
    [self.view addSubview:self.datePicker];
    
    CGFloat toolbarHeight = 50;
    UIToolbar *temptoolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, self.datePicker.y-toolbarHeight, self.view.frame.size.width, toolbarHeight)];
    self.toolbar=temptoolbar;
    self.toolbar.barStyle = UIBarStyleBlackOpaque;
    //Implementation for US8771 HandleDateUDFEmptyValue//JUHI
    
    UIBarButtonItem *tempDoneButton = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString(Done, @"") style: UIBarButtonItemStylePlain target: self action: @selector(doneClicked)];
    self.doneButton=tempDoneButton;
    
    [self.doneButton setAccessibilityIdentifier:@"uia_cell_level_date_picker_done_btn_identifier"];
    
    UIBarButtonItem *tmpCancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                     target:self
                                                                                     action:@selector(pickerCancel:)];
    self.cancelButton=tmpCancelButton;
    
    
    UIBarButtonItem *tmpSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:nil
                                                                                    action:nil];
	self.spaceButton=tmpSpaceButton;
    
    
    //Implementation for US8771 HandleDateUDFEmptyValue//JUHI
    UIBarButtonItem *tmpClearButton = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString(@"Clear", @"") style: UIBarButtonItemStylePlain target: self action: @selector(pickerClear:)];
    self.pickerClearButton=tmpClearButton;
    
    self.doneButton.tintColor=RepliconStandardWhiteColor;
    self.cancelButton.tintColor=RepliconStandardWhiteColor;
    self.pickerClearButton.tintColor=RepliconStandardWhiteColor;

    NSArray *toolArray = [NSArray arrayWithObjects:cancelButton,pickerClearButton,spaceButton,doneButton,nil];
    [toolbar setItems:toolArray];
    [self.view addSubview: self.toolbar];
    
    
}

- (void)updateFieldWithPickerChange:(id)sender
{
    if (self.userFieldArray.count>0)
    {
        InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[self. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedUdfCell inSection:0]];

        NSString *selectedDateString=nil;
        if ([sender isKindOfClass:[NSString class]])
            selectedDateString=sender;
        else
            selectedDateString=[Util convertDateToString:[sender date]];

        [[cell fieldButton] setText:selectedDateString];

        EntryCellDetails *udfDetails=[self.userFieldArray objectAtIndex:selectedUdfCell];
        NSString *udfType=[udfDetails fieldType];
        NSString *udfName=[udfDetails fieldName];
        NSString *udfUri=[udfDetails udfIdentity];
        NSString *dropdownOptionUri=[udfDetails dropdownOptionUri];
        NSString *udfSystemDefaultValue=[NSString stringWithFormat:@"%@",[udfDetails systemDefaultValue]];
        NSString *udfDefaultValue=[udfDetails defaultValue];
        NSString *udfIdentity=[udfDetails udfIdentity];
        NSString *udfModule=[udfDetails udfModule];

        EntryCellDetails *newCellDetails=[[EntryCellDetails alloc]initWithDefaultValue:udfDefaultValue ];
        [newCellDetails setSystemDefaultValue:udfSystemDefaultValue];
        [newCellDetails setFieldName:udfName];
        [newCellDetails setUdfIdentity:udfUri];
        [newCellDetails setDropdownOptionUri:dropdownOptionUri];
        [newCellDetails setUdfIdentity:udfIdentity];
        [newCellDetails setUdfModule:udfModule];
        [newCellDetails setFieldType:udfType];

        if ([sender isKindOfClass:[NSString class]])
        {
            if ([selectedDateString isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
                [newCellDetails setFieldValue: selectedDateString];
            else{
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

                NSLocale *locale=[NSLocale currentLocale];
                [dateFormatter setLocale:locale];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                [dateFormatter setDateFormat:@"MMM d, yyyy"];
                [newCellDetails setFieldValue: [dateFormatter stringFromDate:[dateFormatter dateFromString:selectedDateString]]];
            }
        }
        else
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

            NSLocale *locale=[NSLocale currentLocale];
            [dateFormatter setLocale:locale];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [dateFormatter setDateFormat:@"MMM d, yyyy"];
            [newCellDetails setFieldValue: [dateFormatter stringFromDate:[dateFormatter dateFromString:selectedDateString]]];
        }
        [self.userFieldArray replaceObjectAtIndex:selectedUdfCell withObject:newCellDetails];
        [self reloadViewAfterEntryEdited];
    }
}

-(void)pickerCancel:(id)sender
{
    InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[self. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedUdfCell inSection:0]];
    [cell setSelected:NO animated:NO];
    [self resetTableSize:NO isFromUdf:NO isDateUdf:NO];
    self.datePicker.hidden=YES;
    self.toolbar.hidden=YES;
    NSArray *toolArray = [NSArray arrayWithObjects:spaceButton, doneButton,nil];
    [toolbar setItems:toolArray];
    [self updateFieldWithPickerChange:self.previousDateUdfValue];
    
}
-(void)pickerClear:(id)sender
{
    InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[self. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedUdfCell inSection:0]];
    [cell setSelected:NO animated:NO];
    [self resetTableSize:NO isFromUdf:NO isDateUdf:NO];
    self.datePicker.hidden=YES;
    self.toolbar.hidden=YES;
    NSArray *toolArray = [NSArray arrayWithObjects:spaceButton, doneButton,nil];
    [toolbar setItems:toolArray];
    [self updateFieldWithPickerChange:RPLocalizedString(SELECT_STRING, @"")];
    
}

-(void)doneClicked
{
    InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[self. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedUdfCell inSection:0]];
    [cell setSelected:NO animated:NO];
    
    [self resetTableSize:NO isFromUdf:NO isDateUdf:NO];
    self.datePicker.hidden=YES;
    self.toolbar.hidden=YES;
    
}

#pragma mark - Dropdown Udf methods


-(void)dataAction: (NSInteger)selectedCell
{
    InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[self. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedUdfCell inSection:0]];
    [cell.fieldValue resignFirstResponder];
    
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        return;
    }
    
    DropDownViewController *dropDownViewCtrl=[[DropDownViewController alloc]init];
    dropDownViewCtrl.entryDelegate=self;
    if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
    {
        OEFObject *oefObject=[self.oefFieldArray objectAtIndex:selectedCell];
        dropDownViewCtrl.dropDownUri=[oefObject oefUri];
        dropDownViewCtrl.isGen4Timesheet=YES;
        dropDownViewCtrl.selectedDropDownString=[oefObject oefDropdownOptionValue];
        dropDownViewCtrl.dropDownName=[oefObject oefName];
    }
    else
    {
        EntryCellDetails *udfDetails=[self.userFieldArray objectAtIndex:selectedCell];
        dropDownViewCtrl.dropDownUri=[udfDetails udfIdentity];
    }

    [self.navigationController pushViewController:dropDownViewCtrl animated:YES];
    
}

-(void)updateDropDownFieldWithFieldName:(NSString*)fieldName andFieldURI:(NSString*)fieldUri
{
    InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[self. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedUdfCell inSection:0]];

    EntryCellDetails *newCellDetails=nil;
    OEFObject *oefObject=nil;
    if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
    {
        oefObject=[self.oefFieldArray objectAtIndex:selectedUdfCell];
    }
    else
    {
        EntryCellDetails *udfDetails=[self.userFieldArray objectAtIndex:selectedUdfCell];
        NSString *udfType=[udfDetails fieldType];
        NSString *udfName=[udfDetails fieldName];
        NSString *udfUri=[udfDetails udfIdentity];
        NSString *dropdownOptionUri=[udfDetails dropdownOptionUri];
        NSString *udfSystemDefaultValue=[NSString stringWithFormat:@"%@",[udfDetails systemDefaultValue]];
        NSString *udfDefaultValue=[udfDetails defaultValue];
        NSString *udfIdentity=[udfDetails udfIdentity];
        NSString *udfModule=[udfDetails udfModule];

        newCellDetails=[[EntryCellDetails alloc]initWithDefaultValue:udfDefaultValue ];
        [newCellDetails setSystemDefaultValue:udfSystemDefaultValue];
        [newCellDetails setFieldName:udfName];
        [newCellDetails setUdfIdentity:udfUri];
        [newCellDetails setDropdownOptionUri:dropdownOptionUri];
        [newCellDetails setUdfIdentity:udfIdentity];
        [newCellDetails setUdfModule:udfModule];
        [newCellDetails setFieldType:udfType];
    }
    

    if (fieldName!=nil && ![fieldName isKindOfClass:[NSNull class]])
    {
        //Implemetation For MOBI-300//JUHI
        if ([fieldName isEqualToString:RPLocalizedString(NONE_STRING, NONE_STRING)]&& (fieldUri==nil || [fieldUri isKindOfClass:[NSNull class]]))
        {
            fieldName=RPLocalizedString(SELECT_STRING, @"");
            if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
            {
                [oefObject setOefDropdownOptionUri:fieldUri];
            }
            else
            {
                [newCellDetails setDropdownOptionUri:fieldUri];
            }

        }
        [cell.fieldButton setText:fieldName];
       if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
        {
            [oefObject setOefDropdownOptionValue:fieldName];
        }
        else
        {
            [newCellDetails setFieldValue:fieldName];
        }

    }
    if (fieldUri!=nil && ![fieldUri isKindOfClass:[NSNull class]])
    {
        if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
        {
            [oefObject setOefDropdownOptionUri:fieldUri];
        }
        else
        {
            [newCellDetails setDropdownOptionUri:fieldUri];
        }

    }

    if (![self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
    {
        [self.userFieldArray replaceObjectAtIndex:selectedUdfCell withObject:newCellDetails];
    }

    [self reloadViewAfterEntryEdited];
}

#pragma mark - Text Udf methods

-(void)textUdfAction:(NSInteger)selectedCell
{
    
    InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[self. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedCell inSection:0]];
    [cell.fieldValue resignFirstResponder];
    AddDescriptionViewController *addDescriptionViewCtrl=[[AddDescriptionViewController alloc]init];
    
    addDescriptionViewCtrl.fromTextUdf =YES;
    if ([[cell fieldButton].text isEqualToString:RPLocalizedString(ADD, @"")]||[[cell fieldButton].text isEqualToString:RPLocalizedString(NONE_STRING, @"")])
    {
        [addDescriptionViewCtrl setDescTextString:@""];
    }
    else
        [addDescriptionViewCtrl setDescTextString:[cell fieldButton].text];
    
    [addDescriptionViewCtrl setViewTitle:[cell fieldName].text ];
    addDescriptionViewCtrl.descControlDelegate=self;
    
    if (([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||([sheetApprovalStatus isEqualToString:APPROVED_STATUS ])))
    {
        [addDescriptionViewCtrl setIsNonEditable:YES];
    }
    else
        [addDescriptionViewCtrl setIsNonEditable:NO];
    
    
    [self.navigationController pushViewController:addDescriptionViewCtrl animated:YES];
    
    
}
-(void)updateTextUdf:(NSString*)udfTextValue
{
    InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[self. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedUdfCell inSection:0]];
    
    EntryCellDetails *newCellDetails=nil;
    OEFObject *oefObject=nil;
    if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
    {
        oefObject=[self.oefFieldArray objectAtIndex:selectedUdfCell];
    }
    else
    {
        EntryCellDetails *udfDetails=[self.userFieldArray objectAtIndex:selectedUdfCell];
        NSString *udfType=[udfDetails fieldType];
        NSString *udfName=[udfDetails fieldName];
        NSString *udfUri=[udfDetails udfIdentity];
        NSString *dropdownOptionUri=[udfDetails dropdownOptionUri];
        NSString *udfSystemDefaultValue=[NSString stringWithFormat:@"%@",[udfDetails systemDefaultValue]];
        NSString *udfDefaultValue=[udfDetails defaultValue];
        NSString *udfIdentity=[udfDetails udfIdentity];
        NSString *udfModule=[udfDetails udfModule];

        newCellDetails=[[EntryCellDetails alloc]initWithDefaultValue:udfDefaultValue ];
        [newCellDetails setSystemDefaultValue:udfSystemDefaultValue];
        [newCellDetails setFieldName:udfName];
        [newCellDetails setUdfIdentity:udfUri];
        [newCellDetails setDropdownOptionUri:dropdownOptionUri];
        [newCellDetails setUdfIdentity:udfIdentity];
        [newCellDetails setUdfModule:udfModule];
        [newCellDetails setFieldType:udfType];
    }



    NSString *udfTextStr=nil;

    if (udfTextValue!=nil && ![udfTextValue isKindOfClass:[NSNull class]])
    {
        if ([udfTextValue isEqualToString:@""])
        {
            udfTextStr=RPLocalizedString(ADD, @"");
        }
        else
            udfTextStr=udfTextValue;
    }
    else
        udfTextStr=RPLocalizedString(ADD, @"");

    [cell.fieldButton setText:udfTextStr];
    if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
    {
        [oefObject setOefTextValue:udfTextStr];
    }
    else
    {
        [newCellDetails setFieldValue:udfTextStr];
        [self.userFieldArray replaceObjectAtIndex:selectedUdfCell withObject:newCellDetails];
    }

    [self reloadViewAfterEntryEdited];
    
}
#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    self.inoutEntryTableView=nil;
    self.lastUsedTextField=nil;
    self.datePicker=nil;
    self.cancelButton=nil;
    self.doneButton=nil;
    self.spaceButton=nil;
    self.pickerClearButton=nil;
    self.toolbar=nil;
    self.commentsTextView=nil;
    self.tableFooterView=nil;
    self.tableHeaderView=nil;
    
}

-(void)dealloc
{
    self.inoutEntryTableView.delegate = nil;
    self.inoutEntryTableView.dataSource = nil;
}

#pragma mark - UDF Helper Methods

- (void)constructRowUDFArray:(NSMutableArray *)array
{
    NSMutableArray *udfarray=[tsEntryObject timeEntryRowUdfArray];
    
    for (int i=0; i<[udfarray count]; i++)
    {
        EntryCellDetails *cellDetails=[[tsEntryObject timeEntryRowUdfArray] objectAtIndex:i];
        NSString *udfValue=nil;
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
            NSMutableDictionary *rowudfDict=[NSMutableDictionary dictionaryWithObject:udfValue forKey:@"UDF"];
            [array addObject:rowudfDict];
        }
        else
        {
            if (udfsystemDefaultValue!=nil && ![udfsystemDefaultValue isKindOfClass:[NSNull class]]&&
                ![udfsystemDefaultValue isEqualToString:@""]&&
                ![udfsystemDefaultValue isEqualToString:NULL_STRING]&&
                ![udfsystemDefaultValue isEqualToString:NULL_OBJECT_STRING])
            {
                NSMutableDictionary *rowudfDict=[NSMutableDictionary dictionaryWithObject:udfsystemDefaultValue forKey:@"UDF"];
                [array addObject:rowudfDict];
            }
        }
        
    }
}


@end
