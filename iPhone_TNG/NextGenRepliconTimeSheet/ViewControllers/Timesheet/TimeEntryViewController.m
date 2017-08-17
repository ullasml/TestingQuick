//
//  TimeEntryViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 08/01/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import "TimeEntryViewController.h"
#import "Constants.h"
#import "Util.h"
#import "LoginModel.h"
#import "CurrentTimeSheetsCellView.h"
#import "CurrentTimesheetViewController.h"
#import "AppDelegate.h"
#import "SelectClientOrProjectViewController.h"
#import "SearchViewController.h"
#import "ApprovalsScrollViewController.h"
#import "UISegmentedControlExtension.h"
#import "SVPullToRefresh.h"
#import "EditEntryViewController.h"
#import "CameraCaptureViewController.h"
#import "AttendanceViewController.h"
#import "PunchEntryViewController.h"
#import "NSString+Double_Float.h"
#import "AttendanceNavigationController.h"
#import "ApprovalsNavigationController.h"
#import "SupervisorDashboardNavigationController.h"
#import "OEFObject.h"
#import "UIView+Additions.h"

@interface TimeEntryViewController ()
@property (nonatomic) NSInteger rowTextFieldFocusIndex;

@end


@implementation TimeEntryViewController
@synthesize timeEntryTableView;
@synthesize timeEntryArray;
@synthesize timesheetObject;
@synthesize screenMode;
@synthesize delegate;
@synthesize footerView;
@synthesize selectedIndexPath;
@synthesize lastUsedTextField;
@synthesize datePicker;
@synthesize toolbar;
@synthesize isTimeAllowedPermission;
@synthesize timesheetURI;
@synthesize timesheetStatus;
@synthesize isMultiDayInOutTimesheetUser;
@synthesize timesheetDataArray;
@synthesize isProjectAccess,isClientAccess,isProgramAccess;//MOBI-746
@synthesize isActivityAccess;
@synthesize isBillingAccess;
@synthesize activitySelectionRequired;
@synthesize isDisclaimerRequired;
@synthesize approvalsModuleName;
@synthesize screenViewMode;
@synthesize rowUriBeingEdited;
@synthesize isEntryDetailsChanged;
@synthesize isExtendedInOutTimesheet;
@synthesize currentPageDate;
//Implentation for US8956//JUHI
@synthesize segmentedCtrl;
@synthesize isEditBreak;
@synthesize breakEntryArray;
@synthesize searchBar;
@synthesize searchTimer;
@synthesize selectedBreakString;
@synthesize searchIconImageView;
@synthesize indexBeingEdited;
//Implemented as per US9109//JUHI
@synthesize _hasTimesheetTimeoffAccess;
@synthesize availableTimeOffTypeCount;
@synthesize adHocOptionList;
@synthesize selectedTimeoffString;
@synthesize controllerDelegate;
//Implementation for US9371//JUHI
@synthesize doneButton;
@synthesize spaceButton;
@synthesize cancelButton;
@synthesize previousDateUdfValue;
@synthesize pickerClearButton;
@synthesize editEntryRowUdfArray;
@synthesize isRowUdf;//Implementation forMobi-181//JUHI
@synthesize noPrjectActivityMsgLabel;
@synthesize addRowButton;
@synthesize isFromLockedInOut,isFromAttendance,isFromPlayButton,isStartNewTask;
@synthesize isUsingAuditImages;
@synthesize punchMapViewController;
@synthesize isCurrentPunchID;
@synthesize cellIdentiferstr;//Fix for defect MOBI-456//JUHI
@synthesize isGen4UserTimesheet;


#define DELETE_TIME_ENTRY_ALERT_TAG 4321
#define HEADER_LABEL_HEIGHT 26
#define Each_Cell_Row_Height_44 44
#define Project_Cell_Row_Height 120
#define OffSetFor4 60
#define OffSetFor5 150
#define spaceHeight 480
#define heightSpace 35
#define datePicker_Y 210
#define toolbar_Y 324
#define HeightOFMsgLabel 80
//Implentation for US8956//JUHI
#define kTagFirst 1
#define kTagSecond 2
#define kTagThird 3//Implemented as per US9109//JUHI
#define TimeEntry_Tag 0
#define Break_Tag 1
#define Timeoff_Tag 2//Implemented as per US9109//JUHI
#define SEARCH_POLL 0.2
#pragma mark
#pragma mark  view lifecycle methods


#define ADD_Picker_Height 216
#define EDIT_Picker_Height 170
#define spaceForOffSet 358

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:RepliconStandardWhiteColor];
    self.navigationType = (UINavigationController*)self.tabBarController.selectedViewController;

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;


    if (![self.navigationType isKindOfClass:[AttendanceNavigationController class]])
    {
        //WE dont support breaks for simple in out
        if (!self.isExtendedInOutTimesheet && self.isMultiDayInOutTimesheetUser)
        {
            self.isEditBreak=FALSE;
        }
    }
    
   
    //Approval context Flow for timesheets
    if ([self.navigationType isKindOfClass:[ApprovalsNavigationController class]] || [self.navigationType isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
        ApprovalsModel *approvalModel=[[ApprovalsModel alloc]init];
        

        if ([self.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            
            
            self.timesheetFormat=[approvalModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:YES];
            
            if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
            {
                if([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                {
                    SupportDataModel *supportDataModel=[[SupportDataModel alloc]init];
                    NSDictionary *permittedApprovalAcionsDict=[supportDataModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
                    self.isProjectAccess=[[permittedApprovalAcionsDict objectForKey:@"allowProjectsTasksForStandardGen4"] boolValue];
                    self.isClientAccess=[[permittedApprovalAcionsDict objectForKey:@"allowClientsForStandardGen4"] boolValue];
                    self.isActivityAccess=[[permittedApprovalAcionsDict objectForKey:@"allowActivitiesForStandardGen4"] boolValue];
                    self.isBillingAccess=[[permittedApprovalAcionsDict objectForKey:@"allowBillingForStandardGen4"] boolValue];
                    self.isProgramAccess=[[permittedApprovalAcionsDict objectForKey:@"allowProgramsForStandardGen4"] boolValue];

                }
                else if([self.timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                {
                    SupportDataModel *supportDataModel=[[SupportDataModel alloc]init];
                    NSDictionary *permittedApprovalAcionsDict=[supportDataModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
                    self.isProjectAccess=[[permittedApprovalAcionsDict objectForKey:@"allowProjectsTasksForExtInOutGen4"] boolValue];
                    self.isClientAccess=[[permittedApprovalAcionsDict objectForKey:@"allowClientsForExtInOutGen4"] boolValue];
                    self.isActivityAccess=[[permittedApprovalAcionsDict objectForKey:@"allowActivitiesForExtInOutGen4"] boolValue];
                    self.isBillingAccess=[[permittedApprovalAcionsDict objectForKey:@"allowBillingForExtInOutGen4"] boolValue];
                    self.isProgramAccess=[[permittedApprovalAcionsDict objectForKey:@"allowProgramsForExtInOutGen4"] boolValue];
                    
                }
                else
                {
                    self.isProjectAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetObject.timesheetURI];
                    self.isClientAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetClientAccess" forSheetUri:timesheetObject.timesheetURI];
                    self.isActivityAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetObject.timesheetURI];
                    self.isBillingAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:timesheetObject.timesheetURI];
                    self.isProgramAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProgramAccess" forSheetUri:timesheetObject.timesheetURI];//MOBI-746
                }
            }

            else
            {
                
                self.isProjectAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetObject.timesheetURI];
                self.isClientAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetClientAccess" forSheetUri:timesheetObject.timesheetURI];
                self.isActivityAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetObject.timesheetURI];
                self.isBillingAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:timesheetObject.timesheetURI];
                self.isProgramAccess=[approvalModel getPendingTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProgramAccess" forSheetUri:timesheetObject.timesheetURI];//MOBI-746
            }
            
            
        }
        else
        {
          
          self.timesheetFormat=[approvalModel getTimesheetFormatforTimesheetUri:timesheetURI andIsPending:NO];

            if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
            {
                if([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                {
                    SupportDataModel *supportDataModel=[[SupportDataModel alloc]init];
                    NSDictionary *permittedApprovalAcionsDict=[supportDataModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
                    self.isProjectAccess=[[permittedApprovalAcionsDict objectForKey:@"allowProjectsTasksForStandardGen4"] boolValue];
                    self.isClientAccess=[[permittedApprovalAcionsDict objectForKey:@"allowClientsForStandardGen4"] boolValue];
                    self.isActivityAccess=[[permittedApprovalAcionsDict objectForKey:@"allowActivitiesForStandardGen4"] boolValue];
                    self.isBillingAccess=[[permittedApprovalAcionsDict objectForKey:@"allowBillingForStandardGen4"] boolValue];
                    self.isProgramAccess=[[permittedApprovalAcionsDict objectForKey:@"allowProgramsForStandardGen4"] boolValue];

                }
                else if([self.timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                {
                    SupportDataModel *supportDataModel=[[SupportDataModel alloc]init];
                    NSDictionary *permittedApprovalAcionsDict=[supportDataModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
                    self.isProjectAccess=[[permittedApprovalAcionsDict objectForKey:@"allowProjectsTasksForExtInOutGen4"] boolValue];
                    self.isClientAccess=[[permittedApprovalAcionsDict objectForKey:@"allowClientsForExtInOutGen4"] boolValue];
                    self.isActivityAccess=[[permittedApprovalAcionsDict objectForKey:@"allowActivitiesForExtInOutGen4"] boolValue];
                    self.isBillingAccess=[[permittedApprovalAcionsDict objectForKey:@"allowBillingForExtInOutGen4"] boolValue];
                    self.isProgramAccess=[[permittedApprovalAcionsDict objectForKey:@"allowProgramsForExtInOutGen4"] boolValue];
                    
                }
                else{
                    self.isProjectAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetObject.timesheetURI];
                    self.isClientAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetClientAccess" forSheetUri:timesheetObject.timesheetURI];
                    self.isActivityAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetObject.timesheetURI];
                    self.isBillingAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:timesheetObject.timesheetURI];
                    self.isProgramAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProgramAccess" forSheetUri:timesheetObject.timesheetURI];//MOBI-746
                }
            }
            else
            {
                self.isProjectAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetObject.timesheetURI];
                self.isClientAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetClientAccess" forSheetUri:timesheetObject.timesheetURI];
                self.isActivityAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetObject.timesheetURI];
                self.isBillingAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:timesheetObject.timesheetURI];
                self.isProgramAccess=[approvalModel getPreviousTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProgramAccess" forSheetUri:timesheetObject.timesheetURI];//MOBI-746
            }
            
            
        }


    }
    else if ([self.navigationType isKindOfClass:[AttendanceNavigationController class]])
    {
        LoginModel *loginModel=[[LoginModel alloc]init];
        self.isProjectAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchProjectAccess"];
        self.isClientAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchClientAccess"];
        self.isActivityAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchActivityAccess"];
        self.isBillingAccess =[loginModel getStatusForGivenPermissions:@"hasTimepunchBillingAccess"];
        self.activitySelectionRequired=[loginModel getStatusForGivenPermissions:@"timepunchActivitySelectionRequired"];
        self.isUsingAuditImages=[loginModel getStatusForGivenPermissions:@"timepunchAuditImageRequired"];
    }
    //User context Flow for timesheets
    else
    {
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        
         self.timesheetFormat=[timesheetModel getTimesheetFormatforTimesheetUri:timesheetURI];

        if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
        {
            if([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
            {
                SupportDataModel *supportDataModel=[[SupportDataModel alloc]init];
                NSDictionary *permittedApprovalAcionsDict=[supportDataModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
                self.isProjectAccess=[[permittedApprovalAcionsDict objectForKey:@"allowProjectsTasksForStandardGen4"] boolValue];
                self.isClientAccess=[[permittedApprovalAcionsDict objectForKey:@"allowClientsForStandardGen4"] boolValue];
                self.isActivityAccess=[[permittedApprovalAcionsDict objectForKey:@"allowActivitiesForStandardGen4"] boolValue];
                self.isBillingAccess=[[permittedApprovalAcionsDict objectForKey:@"allowBillingForStandardGen4"] boolValue];
                self.isProgramAccess=[[permittedApprovalAcionsDict objectForKey:@"allowProgramsForStandardGen4"] boolValue];

            }
            else if([self.timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
            {
                SupportDataModel *supportDataModel=[[SupportDataModel alloc]init];
                NSDictionary *permittedApprovalAcionsDict=[supportDataModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
                self.isProjectAccess=[[permittedApprovalAcionsDict objectForKey:@"allowProjectsTasksForExtInOutGen4"] boolValue];
                self.isClientAccess=[[permittedApprovalAcionsDict objectForKey:@"allowClientsForExtInOutGen4"] boolValue];
                self.isActivityAccess=[[permittedApprovalAcionsDict objectForKey:@"allowActivitiesForExtInOutGen4"] boolValue];
                self.isBillingAccess=[[permittedApprovalAcionsDict objectForKey:@"allowBillingForExtInOutGen4"] boolValue];
                self.isProgramAccess=[[permittedApprovalAcionsDict objectForKey:@"allowProgramsForExtInOutGen4"] boolValue];
                
            }

            else{
                LoginModel *loginModel=[[LoginModel alloc]init];
                TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                self.isProjectAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetURI];
                self.isClientAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetClientAccess" forSheetUri:timesheetURI];
                self.isActivityAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetURI];
                self.isBillingAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:timesheetURI];

                self.activitySelectionRequired=[loginModel getStatusForGivenPermissions:@"timesheetActivitySelectionRequired"];
                if([delegate isKindOfClass:[TimesheetMainPageController class]])
                {
                    self.isProgramAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProgramAccess" forSheetUri:timesheetURI];
                }

            }
        }
        else
        {
            LoginModel *loginModel=[[LoginModel alloc]init];
            TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
            self.isProjectAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetURI];
            self.isClientAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetClientAccess" forSheetUri:timesheetURI];
            self.isActivityAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetURI];
            self.isBillingAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetBillingAccess" forSheetUri:timesheetURI];
           
            self.activitySelectionRequired=[loginModel getStatusForGivenPermissions:@"timesheetActivitySelectionRequired"];
            if([delegate isKindOfClass:[TimesheetMainPageController class]])
            {
                 self.isProgramAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProgramAccess" forSheetUri:timesheetURI];
            }
        }
        
        



    }
    //Implementation forMobi-181//JUHI
    if (!isMultiDayInOutTimesheetUser)
    {
        if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
        {
            if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
            {
                if ([editEntryRowUdfArray count]>0)
                {
                    self.isRowUdf=TRUE;
                }
                else
                {
                    if ([delegate isKindOfClass:[TimesheetMainPageController class]])
                    {
                        TimesheetMainPageController *ctrl=(TimesheetMainPageController *)delegate;
                        editEntryRowUdfArray=[ctrl constructCellOEFObjectForTimeSheetUri:self.timesheetURI andtimesheetFormat:self.timesheetFormat andOEFLevel:TIMESHEET_ROW_OEF andTimePunchUri:@""];
                        if ([editEntryRowUdfArray count]>0)
                        {
                            self.isRowUdf=TRUE;
                        }
                        
                    }
                    
                }
                
            }
        }

        else
        {
            LoginModel *loginModel=[[LoginModel alloc]init];
            NSMutableArray *udfArray=[loginModel getEnabledOnlyUDFsforModuleName:TIMESHEET_ROW_UDF];
            if ([udfArray count]>0)
            {
                self.isRowUdf=TRUE;
            }
            else
                self.isRowUdf=FALSE;

            
        }
        
        
    }
    

    if ([delegate isKindOfClass:[AttendanceViewController class]]) {
        if (isEditBreak)
        {
            self.isProjectAccess=NO;
            self.isClientAccess=NO;
            self.isActivityAccess=NO;
            self.isBillingAccess=NO;
        }
    }
    //Implemented as per US9109
    NSArray *items =nil;

    //Implementation as per US9109//JUHI
    //Implementation forMobi-181//JUHI
    if (isEditBreak ||(_hasTimesheetTimeoffAccess && availableTimeOffTypeCount>0))
    {
        float xOffset=10.0f;
        float yOffset=8.0f;
        float wSegment=self.view.frame.size.width-2*xOffset;
        float hSegment=34.0f;//Implementation as per US9109//JUHI
        if (_hasTimesheetTimeoffAccess && availableTimeOffTypeCount>0)
        {//Implementation forMobi-181//JUHI
            if (isEditBreak)
            {
                items = [[NSArray alloc] initWithObjects:
                         RPLocalizedString(ADD_TIME, @""),
                         RPLocalizedString(ADD_BREAK, @""),RPLocalizedString(TimeoffLabelText, @""),  nil];
            }

            else
                items = [[NSArray alloc] initWithObjects:
                         RPLocalizedString(ADD_TIME, @""),
                         RPLocalizedString(TimeoffLabelText, @""),  nil];
        }
        else{
            items = [[NSArray alloc] initWithObjects:
                     RPLocalizedString(ADD_TIME, @""),
                     RPLocalizedString(ADD_BREAK, @""),  nil];
        }
        UISegmentedControl *tempSegmentCtrl = [[UISegmentedControl alloc] initWithItems:items];

        self.segmentedCtrl=tempSegmentCtrl;
        [self.segmentedCtrl setAccessibilityIdentifier:@"uia_time_entry_segment_control_identifier"];


//        [self.segmentedCtrl setSegmentedControlStyle:UISegmentedControlStyleBar];
        [self.segmentedCtrl setFrame:CGRectMake(xOffset, yOffset, wSegment, hSegment)];
        [self.segmentedCtrl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
        //Implementation as per US9109//JUHI
        if (_hasTimesheetTimeoffAccess && availableTimeOffTypeCount>0&&isEditBreak )//Implementation forMobi-181//JUHI
        {
            [self.segmentedCtrl setTag:kTagFirst forSegmentAtIndex:0];
            [self.segmentedCtrl setTag:kTagSecond forSegmentAtIndex:1];
            [self.segmentedCtrl setTag:kTagThird forSegmentAtIndex:2];
            //Fix for ios7//JUHI
            float version=[[UIDevice currentDevice].systemVersion newFloatValue];
            if (version>=7.0)
            {
                [self.segmentedCtrl setTintColor:[Util colorWithHex:@"#107ebe" alpha:1]];




                [self.segmentedCtrl setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:12],NSForegroundColorAttributeName:[UIColor blackColor]}
                                                  forState:UIControlStateNormal];

                [self.segmentedCtrl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}
                                                  forState:UIControlStateSelected];

                [self.segmentedCtrl setBackgroundColor:[UIColor clearColor]];
                [self changeUISegmentFont:self.segmentedCtrl];
                [self setTextColorsForSegmentedControl:self.segmentedCtrl];
            }
            else{
                [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagFirst];
                [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagSecond];
                [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagThird];
                [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#b6c1c8" alpha:1]];
            }


        }
        else
        {
            [self.segmentedCtrl setTag:kTagFirst forSegmentAtIndex:0];
            [self.segmentedCtrl setTag:kTagSecond forSegmentAtIndex:1];
            //Fix for ios7//JUHI
            float version=[[UIDevice currentDevice].systemVersion newFloatValue];
            if (version>=7.0)
            {
                [self.segmentedCtrl setTintColor:[Util colorWithHex:@"#107ebe" alpha:1]];

                [self.segmentedCtrl setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:12],NSForegroundColorAttributeName:[UIColor blackColor]}
                                                  forState:UIControlStateNormal];

                [self.segmentedCtrl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}
                                                  forState:UIControlStateSelected];

                [self.segmentedCtrl setBackgroundColor:[UIColor clearColor]];
                [self changeUISegmentFont:self.segmentedCtrl];
                [self setTextColorsForSegmentedControl:self.segmentedCtrl];
            }
            else{
                [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagFirst];
                [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagFirst];
                [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagSecond];
                [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#b6c1c8" alpha:1]];
            }

        }


        UIView *segmentSectionView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 113)];
        //Fix for ios7//JUHI
        float version=[[UIDevice currentDevice].systemVersion newFloatValue];
        if (version>=7.0)
        {
            [segmentSectionView setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1]];
        }
        else{
            [segmentSectionView setBackgroundColor:[Util colorWithHex:@"#b6c1c8" alpha:1]];
        }

        UIImage *separtorImage=[Util thumbnailImage:TOP_SEPARATOR];
        UIImageView *separatorView=[[UIImageView alloc]initWithFrame:CGRectMake(0,separtorImage.size.height, self.view.frame.size.width, separtorImage.size.height)];
        [separatorView setImage:separtorImage];
        [self.view addSubview:separatorView];

        [segmentSectionView addSubview:self.segmentedCtrl];
        [self.view addSubview:segmentSectionView];

    }

    //Implentation for US8956//JUHI
    float y=0.0;
    float height=self.view.frame.size.height-68;
    if (isEditBreak||(_hasTimesheetTimeoffAccess && availableTimeOffTypeCount>0))
    {
        y=50;
        height=self.view.frame.size.height-50;
    }//Implementation as per US9109//JUHI
    else if (self.screenMode==EDIT_BREAK_ENTRY||self.screenMode==EDIT_Timeoff_ENTRY|| !isProjectAccess||!isActivityAccess)
    {
        y=50;
        height=self.view.frame.size.height-68;
    }//Implementation as per US9109//JUHI
    if (isProjectAccess || isActivityAccess ||isRowUdf || isEditBreak || self.screenMode==EDIT_BREAK_ENTRY||self.screenMode==EDIT_Timeoff_ENTRY ||(_hasTimesheetTimeoffAccess && availableTimeOffTypeCount>0))//Implementation forMobi-181//JUHI
    {
        //Implementation forMobi-181//JUHI
        if ((self.screenMode!=EDIT_BREAK_ENTRY||self.screenMode!=EDIT_Timeoff_ENTRY )&& (isProjectAccess||isActivityAccess||isRowUdf)) {
            [self createTimeEntry];
            if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
            {
                if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                {
                    [self.timeEntryArray addObjectsFromArray:self.editEntryRowUdfArray];
                }
            }

        }


        UITableView *temptableView=[[UITableView alloc]initWithFrame:CGRectMake(0,y ,self.view.frame.size.width, height) style:UITableViewStylePlain];
        self.timeEntryTableView=temptableView;
        self.timeEntryTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.timeEntryTableView setBackgroundColor:RepliconStandardBackgroundColor];
        self.timeEntryTableView.delegate=self;
        self.timeEntryTableView.dataSource=self;
        [self.timeEntryTableView setAccessibilityLabel:@"uia_time_entry_table_identifier"];
        [self.view addSubview: self.timeEntryTableView];

    }
    else
    {
        UILabel *msgLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, HeightOFMsgLabel)];
        msgLabel.text=RPLocalizedString(NO_PROJECTS_NO_ACTIVITY_ENTRY_PLACEHOLDER, NO_PROJECTS_NO_ACTIVITY_ENTRY_PLACEHOLDER);
        msgLabel.backgroundColor=[UIColor clearColor];
        msgLabel.numberOfLines=2;
        msgLabel.textAlignment=NSTextAlignmentCenter;
        msgLabel.font=[UIFont fontWithName:RepliconFontFamily size:16];

        [self.view addSubview:msgLabel];

        if (![self.navigationType isKindOfClass:[AttendanceNavigationController class]])
        {
            UIImage *saveBtnImg =[Util thumbnailImage:SubmitTimesheetButtonImage] ;
            UIImage *savePressedBtnImg =[Util thumbnailImage:SubmitTimesheetPressedButtonImage] ;
            UIButton *saveButton =[UIButton buttonWithType:UIButtonTypeCustom];
            float x = (SCREEN_WIDTH - saveBtnImg.size.width)/2.0;
            [saveButton setFrame:CGRectMake(x,230.0, saveBtnImg.size.width, saveBtnImg.size.height)];
            [saveButton setBackgroundImage:saveBtnImg forState:UIControlStateNormal];
            [saveButton setBackgroundImage:savePressedBtnImg forState:UIControlStateHighlighted];
            [saveButton setTitle:RPLocalizedString(SAVE_BTN_NO_PROJECTS_NO_ACTIVITY, @"")  forState:UIControlStateNormal];
            [saveButton addTarget:self action:@selector(saveAction:) forControlEvents:UIControlEventTouchUpInside];
            [saveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            //        saveButton.titleEdgeInsets = UIEdgeInsetsMake(-2.0, 0, 0, 0);
            //saveButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
            if (self.screenViewMode !=EDIT_PROJECT_ENTRY && self.screenViewMode !=VIEW_PROJECT_ENTRY) {
                [self.view addSubview:saveButton];
            }
            else if (self.screenViewMode==EDIT_PROJECT_ENTRY)
            {
                UIImage *normalImg = [Util thumbnailImage:DeleteTimesheetButtonImage];
                UIImage *highlightedImg = [Util thumbnailImage:DeleteTimesheetPressedButtonImage];
                UIButton *deleteButton =[UIButton buttonWithType:UIButtonTypeCustom];
                float x = (SCREEN_WIDTH-normalImg.size.width)/2.0;
                [deleteButton setFrame:CGRectMake(x,230.0, saveBtnImg.size.width, saveBtnImg.size.height)];
                [deleteButton setBackgroundImage:normalImg forState:UIControlStateNormal];
                [deleteButton setBackgroundImage:highlightedImg forState:UIControlStateHighlighted];
                [deleteButton setTitle:RPLocalizedString(DELETE_ENTRY_STRING,@"") forState:UIControlStateNormal];
                [deleteButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16]];
                [deleteButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
                deleteButton.contentHorizontalAlignment= UIControlContentHorizontalAlignmentCenter;
                [self.view addSubview:deleteButton];
            }

        }





    }

    //Implentation for US8956//JUHI
    //Implementation as per US9109//JUHI
    if ((isEditBreak ||(_hasTimesheetTimeoffAccess && availableTimeOffTypeCount>0))&&self.screenMode!=EDIT_BREAK_ENTRY && self.screenMode!=EDIT_Timeoff_ENTRY){

        if (![self.navigationType isKindOfClass:[AttendanceNavigationController class]])
        {
            if (!self.isExtendedInOutTimesheet && self.isMultiDayInOutTimesheetUser)
            {
                self.segmentedCtrl.selectedSegmentIndex=1;
            }
            else
            {
                self.segmentedCtrl.selectedSegmentIndex=TimeEntry_Tag;
            }
        }
        else
        {
            self.segmentedCtrl.selectedSegmentIndex=TimeEntry_Tag;
        }


        [self changeUISegmentFont:self.segmentedCtrl];
        [self setTextColorsForSegmentedControl:self.segmentedCtrl];
    }
    [self createTableHeader];

    if (controllerDelegate!=nil && [controllerDelegate isKindOfClass:[EditEntryViewController class]])
    {
        [self createFooter];
        [self createHeader];
    }

    self.view.backgroundColor = [UIColor whiteColor];
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
        if([view isKindOfClass:[DecimalPointButton class]] || [view isKindOfClass:[MinusButton class]] || [view isKindOfClass:[DoneButton class]] || [view isKindOfClass:[SeparatorView class]]){
            CGRect buttonFrame = view.frame;
            buttonFrame.size.height = keyboardFrame.size.height/4;
            buttonFrame.origin.y = SCREEN_HEIGHT - buttonFrame.size.height;
            [UIView animateWithDuration:0.2f animations:^{
                view.frame = buttonFrame;
            }];
        }
    }
}


-(void)viewWillDisappear:(BOOL)animated
{
    [self doneClicked];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [self deregisterKeyboardNotification];
}//Implentation for US8956//JUHI

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
        if (self.screenMode==EDIT_BREAK_ENTRY|| ((!isProjectAccess||!isActivityAccess|| !_hasTimesheetTimeoffAccess)&& isEditBreak))
        {
            // THIS IS MOVED OUT OF SCOPE FOR CURRENT REQUIREMENT
//            if (isGen4UserTimesheet)
//            {
//                [self setupBreakData];
//            }
//            else
//            {
                [self createBreakEntry];
//            }
            
            [self createTableHeader];
            [self.timeEntryTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            [self.timeEntryTableView reloadData];
        }//Implementation as per US9109//JUHI
        else if (self.screenMode==EDIT_Timeoff_ENTRY|| ((!isProjectAccess||!isActivityAccess ||!isEditBreak)&& _hasTimesheetTimeoffAccess)){
            [self createTimeoff];
            [self createTableHeader];
            [self.timeEntryTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
            [self.timeEntryTableView reloadData];
        }
}
-(void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:TRUE];


        if (self.screenViewMode ==ADD_PROJECT_ENTRY||self.screenViewMode ==EDIT_PROJECT_ENTRY)
        {
            BOOL isTakeImagePermission=TRUE;
//            BOOL isLocationPermission=TRUE;
            if (![delegate isKindOfClass:[AttendanceViewController class]])
            {
                isTakeImagePermission=FALSE;
            }
            //Implentation for US8956//JUHI
            if (((isProjectAccess || isActivityAccess || isRowUdf)&& self.screenMode!=EDIT_BREAK_ENTRY)||((!isProjectAccess||!isActivityAccess)&& !isEditBreak && _hasTimesheetTimeoffAccess)||((!isProjectAccess||!isActivityAccess)&& isEditBreak))//Implementation forMobi-181//JUHI
            {
                if (self.screenViewMode ==ADD_PROJECT_ENTRY)
                {
                    if (!isTakeImagePermission)
                    {
                        UIBarButtonItem *tempRightButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(Save_Button_Title, @"") style:UIBarButtonItemStylePlain target:self action:@selector(saveAction:)];
                        [tempRightButtonOuterBtn setAccessibilityLabel:@"time_entry_save_btn"];
                        [self navigationItem].rightBarButtonItem=tempRightButtonOuterBtn;
                    }
                    else
                    {
                        UIBarButtonItem *tempRightButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(Continue_Button_Title, @"") style:UIBarButtonItemStylePlain target:self action:@selector(continueAction:)];
                        [self navigationItem].rightBarButtonItem=tempRightButtonOuterBtn;
                    }


                }//Implementation forMobi-181//JUHI
                else if (self.screenViewMode ==EDIT_PROJECT_ENTRY &&(isProjectAccess || isActivityAccess || isRowUdf) && self.screenMode!=EDIT_BREAK_ENTRY && self.screenMode!=EDIT_Timeoff_ENTRY)
                {
                    UIBarButtonItem *tempRightButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(Save_Button_Title, @"") style:UIBarButtonItemStylePlain target:self action:@selector(editAction:)];
                    [self navigationItem].rightBarButtonItem=tempRightButtonOuterBtn;


                }

            }//Implementation forMobi-181//JUHI
            if (self.screenViewMode ==ADD_PROJECT_ENTRY)
            {//Implementation for US8902//JUHI
                if (isGen4UserTimesheet)
                {
                    if (isProjectAccess || isActivityAccess)
                    {
                        [Util setToolbarLabel:self withText:RPLocalizedString(ADD_TIME_ENTRY_TITLE, @"") ];
                    }
                    else
                    {
                         [Util setToolbarLabel:self withText:RPLocalizedString(ADD_BREAK_ENTRY, @"") ];
                    }

                }
                else
                {
                    if(isEditBreak){
                        [Util setToolbarLabel:self withText:RPLocalizedString(CHOOSE_BREAK, @"") ];
                    }else{
                        [Util setToolbarLabel:self withText:RPLocalizedString(ADD_TIME_ENTRY_TITLE, @"") ];
                    }
                }

                if (!isProjectAccess&&!isActivityAccess&&isRowUdf)
                {
                    isEntryDetailsChanged=YES;
                }


            }
            else if (self.screenViewMode ==ADD_PROJECT_ENTRY &&(!isProjectAccess||!isActivityAccess)&& !isEditBreak && _hasTimesheetTimeoffAccess)
                [Util setToolbarLabel:self withText:RPLocalizedString(ADD_TimeOff_ENTRY_TITLE, @"") ];
            else if (self.screenViewMode ==ADD_PROJECT_ENTRY &&(!isProjectAccess||!isActivityAccess)&& isEditBreak)
                [Util setToolbarLabel:self withText:RPLocalizedString(ADD_BREAK_ENTRY_TITLE, @"") ];
            //Implentation for US8956//JUHI
            else if (self.screenMode==EDIT_BREAK_ENTRY)
            {
                [Util setToolbarLabel:self withText:RPLocalizedString(EDIT_BREAK_ENTRY_TITLE, @"") ];
            }//Implementation as per US9109//JUHI
            else if (self.screenMode==EDIT_Timeoff_ENTRY) {
                [Util setToolbarLabel:self withText:RPLocalizedString(EDIT_TimeOff_ENTRY_TITLE, @"") ];
            }
            else
            {//Implementation for US8902//JUHI
                if (self.screenViewMode ==ADD_PROJECT_ENTRY )
                {
                    [Util setToolbarLabel:self withText:RPLocalizedString(ADD_TIME_ENTRY_TITLE, @"") ];
                }
                else
                {
                    [Util setToolbarLabel:self withText:RPLocalizedString(EDIT_TIME_ENTRY_TITLE, @"") ];
                }
                if (!isProjectAccess&&!isActivityAccess&&isRowUdf)
                {
                    isEntryDetailsChanged=YES;
                }
            }
            UIBarButtonItem *tempLeftButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(Cancel_Button_Title, Cancel_Button_Title) style:UIBarButtonItemStylePlain
                                                                                     target:self action:@selector(backAction:)];


            [[self navigationItem ] setLeftBarButtonItem:tempLeftButtonOuterBtn animated:NO];

            [tempLeftButtonOuterBtn setAccessibilityIdentifier:@"uia_time_entry_view_back_btn_identifier"];



        }
        else
        {
            //            UIBarButtonItem *tempLeftButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(BACK, BACK)
            //                                                                                      style:UIBarButtonItemStylePlain
            //                                                                                     target:self action:@selector(backAction:)];

            //Implementation for US8902//JUHI
            [Util setToolbarLabel:self withText:RPLocalizedString(VIEW_TIME_ENTRY_TITLE, @"") ];

        }

        if (isEntryDetailsChanged||isFromPlayButton)
        {
            [[self navigationItem].rightBarButtonItem setEnabled:TRUE];
        }
        else
        {
            [[self navigationItem].rightBarButtonItem setEnabled:FALSE];
        }
       if (isGen4UserTimesheet)
        {
            if (!isActivityAccess && !isProjectAccess)
            {
                [[self navigationItem].rightBarButtonItem setEnabled:FALSE];
            }
            else
            {
                 [[self navigationItem].rightBarButtonItem setEnabled:TRUE];
            }

            if (!isEntryDetailsChanged)
            {
                [[self navigationItem].rightBarButtonItem setEnabled:FALSE];
            }

        }
    
    if ([delegate isKindOfClass:[AttendanceViewController class]]) {
        if (isEditBreak)
        {
            [[self navigationItem].rightBarButtonItem setEnabled:FALSE];
        }
    }





}
-(void)createTimeEntry
{


    timeEntryArray=[[NSMutableArray alloc]init];


    if (isProjectAccess)
    {
        EntryCellDetails *projectDetails=[[EntryCellDetails alloc]initWithDefaultValue:RPLocalizedString(SELECT_STRING, @"") ];
        [projectDetails setFieldName:RPLocalizedString(Project, @"")];
        [projectDetails setFieldType:MOVE_TO_NEXT_SCREEN];
        if (timesheetObject.projectIdentity == nil || [timesheetObject.projectIdentity isKindOfClass:[NSNull class]])
        {
            if ([delegate isKindOfClass:[DayTimeEntryViewController class]]||[delegate isKindOfClass:[TimesheetMainPageController class]])
            {
                [timesheetObject setProjectName: RPLocalizedString(NONE_STRING, @"")];
                [projectDetails setDefaultValue:RPLocalizedString(NONE_STRING, @"")];
            }
            else
            {
                [timesheetObject setProjectName: RPLocalizedString(SELECT_STRING, @"")];
            }


            [timesheetObject setProjectIdentity: @"null"];
        }
        else{
            [projectDetails setFieldValue:[timesheetObject projectName]];
        }
        [timeEntryArray addObject:projectDetails];


        EntryCellDetails *taskDetails=[[EntryCellDetails alloc]initWithDefaultValue:RPLocalizedString(SELECT_STRING, @"") ];
        [taskDetails setFieldName:RPLocalizedString(Task, @"")];
        [taskDetails setFieldType:MOVE_TO_NEXT_SCREEN];
        if (timesheetObject.taskIdentity == nil || [timesheetObject.taskIdentity isKindOfClass:[NSNull class]])
        {
            if ([delegate isKindOfClass:[DayTimeEntryViewController class]]||[delegate isKindOfClass:[TimesheetMainPageController class]])
            {
                [timesheetObject setTaskName: RPLocalizedString(NONE_STRING, @"")];
                [taskDetails setDefaultValue:RPLocalizedString(NONE_STRING, @"")];
            }
            else
            {
                [timesheetObject setTaskName: RPLocalizedString(SELECT_STRING, @"")];
            }

            [timesheetObject setTaskIdentity: @"null"];
        }
        else{
            [taskDetails setFieldValue:[timesheetObject taskName]];
        }
        [timeEntryArray addObject:taskDetails];

    }
    if (isBillingAccess && isProjectAccess)
    {
        EntryCellDetails *billingDetails=[[EntryCellDetails alloc]initWithDefaultValue:RPLocalizedString(SELECT_STRING, @"") ];
        [billingDetails setFieldName:RPLocalizedString(Billing, @"")];
        [billingDetails setFieldType:MOVE_TO_NEXT_SCREEN];
        if (timesheetObject.billingIdentity == nil || [timesheetObject.billingIdentity isKindOfClass:[NSNull class]])
        {
            if ([delegate isKindOfClass:[DayTimeEntryViewController class]]||[delegate isKindOfClass:[TimesheetMainPageController class]])
            {
                [timesheetObject setBillingName: RPLocalizedString(NOT_BILLABLE, @"")];
                [billingDetails setDefaultValue:RPLocalizedString(NOT_BILLABLE, @"")];
            }
            else
            {
                [timesheetObject setBillingName: RPLocalizedString(SELECT_STRING, @"")];
            }

            [timesheetObject setBillingIdentity:@"null"];
        }
        else{
            [billingDetails setFieldValue:[timesheetObject billingName]];
        }

        [timeEntryArray addObject:billingDetails];
        //billingIndex=[timeEntryArray count];
        billingIndex=2;


    }
    if (isActivityAccess)
    {
        EntryCellDetails *activityDetails=[[EntryCellDetails alloc]initWithDefaultValue:RPLocalizedString(SELECT_STRING, @"") ];

        [activityDetails setFieldName:RPLocalizedString(Activity_Type, @"")];
        [activityDetails setFieldType:MOVE_TO_NEXT_SCREEN];
        if (timesheetObject.activityIdentity == nil || [timesheetObject.activityIdentity isKindOfClass:[NSNull class]])
        {
            if ([delegate isKindOfClass:[DayTimeEntryViewController class]]||[delegate isKindOfClass:[TimesheetMainPageController class]])
            {
                [timesheetObject setActivityName: RPLocalizedString(NONE_STRING, @"")];
                [activityDetails setDefaultValue:RPLocalizedString(NONE_STRING, @"")];
            }
            else
            {
                if (!self.activitySelectionRequired)
                {
                    [timesheetObject setActivityName: RPLocalizedString(NONE_STRING, @"")];
                    [activityDetails setDefaultValue:RPLocalizedString(NONE_STRING, @"")];
                }
                else
                {
                    [timesheetObject setActivityName: RPLocalizedString(SELECT_STRING, @"")];
                }


            }

            [timesheetObject setActivityIdentity:@"null"];
        }
        else{
            [activityDetails setFieldValue:[timesheetObject activityName]];
        }
        [timeEntryArray addObject:activityDetails];


    }//Implementation for US9371//JUHI
    if ( !isMultiDayInOutTimesheetUser)
    {
        if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
        {
            if (![self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
            {
                udfIndexCount=[timeEntryArray count];
                //Implementation forMobi-181//JUHI
                if(([timeEntryArray count]>0 ||isRowUdf) && [editEntryRowUdfArray count]==0)
                    [self createRowUdfs];
                else {
                    for (int i=0; i<[editEntryRowUdfArray count]; i++)
                    {
                        EntryCellDetails *udfDetails=(EntryCellDetails *)[editEntryRowUdfArray objectAtIndex:i];
                        NSString *udfType=[udfDetails fieldType];
                        NSString *udfName=[udfDetails fieldName];
                        NSString *udfUri=[udfDetails udfIdentity];
                        NSString *dropdownOptionUri=[udfDetails dropdownOptionUri];
                        NSString *udfSystemDefaultValue=[NSString stringWithFormat:@"%@",[udfDetails systemDefaultValue]];
                        NSString *udfDefaultValue=[udfDetails defaultValue];
                        NSString *udfIdentity=[udfDetails udfIdentity];
                        NSString *udfModule=[udfDetails udfModule];
                        NSString *filedValue=[udfDetails fieldValue];
                        int decimal=[udfDetails decimalPoints];

                        EntryCellDetails *newCellDetails=[[EntryCellDetails alloc]initWithDefaultValue:udfDefaultValue ];
                        [newCellDetails setSystemDefaultValue:udfSystemDefaultValue];
                        [newCellDetails setFieldName:udfName];
                        [newCellDetails setUdfIdentity:udfUri];
                        [newCellDetails setDropdownOptionUri:dropdownOptionUri];
                        [newCellDetails setUdfIdentity:udfIdentity];
                        [newCellDetails setUdfModule:udfModule];
                        [newCellDetails setFieldType:udfType];
                        [newCellDetails setFieldValue:filedValue];
                        [newCellDetails setDecimalPoints:decimal];

                        //[timeEntryArray addObject:[editEntryRowUdfArray objectAtIndex:i]];
                        [timeEntryArray addObject:newCellDetails];
                    }
                }
            }

        }
        
    }

}

-(void)createHeader
{
    if ([delegate isKindOfClass:[TimesheetMainPageController class]])
    {

        TimesheetMainPageController *ctrl=(TimesheetMainPageController *)delegate;
        NSString *labelHeader=@"";
        if (ctrl.tsEntryDataArray.count>0)
        {
            NSString *formattedStartDate=[NSString stringWithFormat:@"%@",[[ctrl.tsEntryDataArray objectAtIndex:0] entryDate]];
            NSString *formattedEndDate=[NSString stringWithFormat:@"%@",[[ctrl.tsEntryDataArray objectAtIndex:[ctrl.tsEntryDataArray count]-1] entryDate]];
            NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
            [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            myDateFormatter.dateFormat = @"EEEE, dd MMM yyyy";

            NSLocale *locale=[NSLocale currentLocale];
            [myDateFormatter setLocale:locale];
            NSDate *startdate=[myDateFormatter dateFromString:[NSString stringWithFormat:@"%@",formattedStartDate]];
            NSDate *enddate=[myDateFormatter dateFromString:[NSString stringWithFormat:@"%@",formattedEndDate]];

            NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"EEE, MMM dd,yyy"];
            [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];//MOBI-1066
            NSString *startString=[formatter stringFromDate:startdate];
            NSString *endstring=[formatter stringFromDate:enddate];
            [formatter setDateFormat:@"yyy"];
            int startYear=[[formatter stringFromDate:startdate] intValue];
            int endYear=[[formatter stringFromDate:enddate] intValue];

            if (startYear==endYear)
            {
                [formatter setDateFormat:@"EEE, MMM dd"];
                NSString *startString=[formatter stringFromDate:startdate];
                NSString *endstring=[formatter stringFromDate:enddate];
                [formatter setDateFormat:@"yyy"];
                labelHeader=[NSString stringWithFormat:@"%@ %@ to %@, %d",RPLocalizedString(@"For", @""),startString,endstring,startYear];
            }
            else
            {
                labelHeader=[NSString stringWithFormat:@"%@ %@ to %@",RPLocalizedString(@"For", @""),startString,endstring];
            }

        }



        UIView *headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, HEADER_LABEL_HEIGHT)];
        CGRect frame=CGRectMake(0, 0, SCREEN_WIDTH, HEADER_LABEL_HEIGHT);
        UIView *headerBackgroundView=[[UIView alloc]initWithFrame:frame];
        [headerBackgroundView setBackgroundColor:[Util colorWithHex:@"#eeeeee" alpha:1]];
        [headerView addSubview:headerBackgroundView];


        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectInset(frame, 10, 0)];
        headerLabel.backgroundColor = [Util colorWithHex:@"#eeeeee" alpha:1];
        headerLabel.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12];
        headerLabel.textAlignment = NSTextAlignmentLeft;
        headerLabel.text=labelHeader;
        [headerView addSubview:headerLabel];

        [self.timeEntryTableView setTableHeaderView:headerView];

    }

}
-(void)createFooter
{

    if ([timesheetStatus isEqualToString:NOT_SUBMITTED_STATUS]||[timesheetStatus isEqualToString:REJECTED_STATUS])
    {

        if (selectedTimeoffString==nil)
        {
            float footerHeight = 210;
            UIView *tempfooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                              0.0,
                                                                              self.timeEntryTableView.frame.size.width,
                                                                              footerHeight)];
            self.footerView=tempfooterView;


            [footerView setBackgroundColor:RepliconStandardBackgroundColor];

            UIImage *normalImg = [Util thumbnailImage:DeleteTimesheetButtonImage];
            UIImage *highlightedImg = [Util thumbnailImage:DeleteTimesheetPressedButtonImage];

            UIButton *deleteButton =[UIButton buttonWithType:UIButtonTypeCustom];
            float x = (SCREEN_WIDTH-normalImg.size.width)/2.0;
            [deleteButton setFrame:CGRectMake(x, 30, normalImg.size.width,  normalImg.size.height)];
            [deleteButton setBackgroundImage:normalImg forState:UIControlStateNormal];
            [deleteButton setBackgroundImage:highlightedImg forState:UIControlStateHighlighted];
            [deleteButton setTitle:RPLocalizedString(DELETE_ENTRY_STRING,@"") forState:UIControlStateNormal];
            [deleteButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16]];
            [deleteButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
            deleteButton.contentHorizontalAlignment= UIControlContentHorizontalAlignmentCenter;
            [tempfooterView addSubview:deleteButton];

            [self.timeEntryTableView setTableFooterView:footerView];
        }


    }

    else
    {
        float footerHeight = 60;
        UIView *tempfooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                          0.0,
                                                                          self.timeEntryTableView.frame.size.width,
                                                                          footerHeight)];
        self.footerView=tempfooterView;
        [self.timeEntryTableView setTableFooterView:footerView];
    }
}

-(void)deleteAction:(id)sender
{
    [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"Yes", @"Yes")
                                   otherButtonTitle:RPLocalizedString(@"No", @"No")
                                           delegate:self
                                            message:RPLocalizedString(DELETE_TIMESHEET_VALIDATION_MSG,@"")
                                              title:nil
                                                tag:DELETE_TIME_ENTRY_ALERT_TAG];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (buttonIndex == 0 && alertView.tag==DELETE_TIME_ENTRY_ALERT_TAG)
    {
        if (controllerDelegate!=nil && [controllerDelegate isKindOfClass:[EditEntryViewController class]])
        {
            [self.navigationController popViewControllerAnimated:NO];
            [controllerDelegate deleteAction:nil];

        }
    }//MOBI-849
    else if (alertView.tag==001)
    {
        // DO NOTHING
    }
}
-(void)backAction:(id)sender
{
    CLS_LOG(@"-----Cancel button clicked on TimeEntryViewController-----");
    [self navigationItem].leftBarButtonItem=nil ;
    if (isEditBreak)
    {
        if (isFromLockedInOut)
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"USING_BREAK"];
        }
        if (isFromAttendance)
        {

        }
        [[NSUserDefaults standardUserDefaults]synchronize];
    }

    if ([delegate isKindOfClass:[TimesheetMainPageController class]])
    {
        [self navigationItem].leftBarButtonItem=nil ;
        [delegate navigationTitle];
        if (self.screenViewMode==EDIT_PROJECT_ENTRY)
        {
            [self.navigationController popViewControllerAnimated:YES ];
        }
        else
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }

    }
    else
    {

        [self.navigationController popViewControllerAnimated:TRUE];

    }

    if([delegate isKindOfClass:[AttendanceViewController class]])
    {
        [delegate showLastPunchDataView];
    }


    [datePicker removeFromSuperview];
    datePicker=nil;
}
-(void)doneAction:(id)sender
{
    if ([delegate isKindOfClass:[DayTimeEntryViewController class]])
    {
        NSString *projectName=[timesheetObject projectName];
        NSString *projectUri=[timesheetObject projectIdentity];
        NSString *taskName=[timesheetObject taskName];
        NSString *taskUri=[timesheetObject taskIdentity];
        NSString *activityName=[timesheetObject activityName];
        NSString *activityUri=[timesheetObject activityIdentity];
        NSString *billingName=[timesheetObject billingName];
        NSString *billingUri=[timesheetObject billingIdentity];

        if (projectUri==nil || [projectUri isEqualToString:@"null"]||[projectUri isKindOfClass:[NSNull class]])
        {
            projectUri=@"";
            projectName=@"";
        }
        if (taskUri==nil || [taskUri isEqualToString:@"null"]||[taskUri isKindOfClass:[NSNull class]])
        {
            taskUri=@"";
            taskName=@"";
        }
        if (activityUri==nil || [activityUri isEqualToString:@"null"]||[activityUri isKindOfClass:[NSNull class]])
        {
            activityUri=@"";
            activityName=@"";
        }
        if (billingUri==nil || [billingUri isEqualToString:@"null"]||[billingUri isKindOfClass:[NSNull class]])
        {
            billingUri=@"";
            billingName=@"";
        }
        [delegate updateProjectName:projectName withProjectUri:projectUri withTaskName:taskName withTaskUri:taskUri withActivityName:activityName withActivityUri:activityUri withBillingName:billingName withBillingUri:billingUri];
    }
    [self.navigationController popViewControllerAnimated:YES];
    [datePicker removeFromSuperview];
    datePicker=nil;
}

-(void)saveAction:(id)sender
{
    CLS_LOG(@"-----Save button clicked on TimeEntryViewController-----");
    if ([delegate isKindOfClass:[TimesheetMainPageController class]])
    {
        if ([timesheetStatus isEqualToString:NOT_SUBMITTED_STATUS]||[timesheetStatus isEqualToString:REJECTED_STATUS])
        {
//            NSString *rowUri=[Util getRandomGUID];
            NSMutableArray *udfArray=nil;
            NSMutableArray *rowUdfArray=nil;
            if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
            {
                if (![self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                {
                    rowUdfArray=[self getRowUdfsDetails];//Implementation for US9371//JUHI
                    NSMutableArray *tempCustomFieldArray=[self createUdfs];
                    udfArray=[NSMutableArray array];
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
                    
                }
            }
            TimesheetModel *tsModel=[[TimesheetModel alloc]init];
            NSString *projectName=[self.timesheetObject projectName];
            NSString *projectUri=[self.timesheetObject projectIdentity];
            NSString *taskName=[self.timesheetObject taskName];
            NSString *taskUri=[self.timesheetObject taskIdentity];
            NSString *activityName=[self.timesheetObject activityName];
            NSString *activityUri=[self.timesheetObject activityIdentity];
            NSString *billingName=[self.timesheetObject billingName];
            NSString *billingUri=[self.timesheetObject billingIdentity];
            NSString *breakName=[self.timesheetObject breakName];
            NSString *breakUri=[self.timesheetObject breakUri];
            NSString *clientName=nil;
            NSString *clientUri=nil;
            NSString *programName=nil;
            NSString *programUri=nil;
            NSString *rowNumber=[self.timesheetObject rowNumber];
            
            
            if (isClientAccess)
            {
                clientName=[self.timesheetObject clientName];
                clientUri=[self.timesheetObject clientIdentity];
            }
            if (isProgramAccess) {
                programName=[self.timesheetObject programName];
                programUri=[self.timesheetObject programIdentity];

            }

            //Implemented as per US9109//JUHI
            NSString *timeoffName=[self.timesheetObject TimeOffName];
            NSString *timeOffUri=[self.timesheetObject TimeOffIdentity];
            if (programUri==nil || [programUri isEqualToString:@"null"]||[programUri isKindOfClass:[NSNull class]])
            {
                programUri=@"";
                programName=@"";
            }
            if (clientUri==nil || [clientUri isEqualToString:@"null"]||[clientUri isKindOfClass:[NSNull class]])
            {
                clientUri=@"";
                clientName=@"";
            }
            if (projectUri==nil || [projectUri isEqualToString:@"null"]||[projectUri isKindOfClass:[NSNull class]]||[projectUri isEqualToString:NULL_STRING] || self.segmentedCtrl.selectedSegmentIndex==Break_Tag )
            {
                projectUri=@"";
                projectName=@"";
            }
            if (taskUri==nil || [taskUri isEqualToString:@"null"]||[taskUri isKindOfClass:[NSNull class]]||[taskUri isEqualToString:NULL_STRING]||self.segmentedCtrl.selectedSegmentIndex==Break_Tag )
            {
                taskUri=@"";
                taskName=@"";
            }
            if (activityUri==nil || [activityUri isEqualToString:@"null"]||[activityUri isKindOfClass:[NSNull class]]||[activityUri isEqualToString:NULL_STRING]||self.segmentedCtrl.selectedSegmentIndex==Break_Tag )
            {
                activityUri=@"";
                activityName=@"";
            }
            if (billingUri==nil || [billingUri isEqualToString:@"null"]||[billingUri isKindOfClass:[NSNull class]]||[billingUri isEqualToString:NULL_STRING]||self.segmentedCtrl.selectedSegmentIndex==Break_Tag )
            {
                billingUri=@"";
                billingName=@"";
            }
             if (breakUri==nil || [breakUri isEqualToString:@"null"]||[breakUri isKindOfClass:[NSNull class]]||[breakUri isEqualToString:NULL_STRING]||(self.segmentedCtrl.selectedSegmentIndex==TimeEntry_Tag && (isProjectAccess || isActivityAccess))||(self.segmentedCtrl.selectedSegmentIndex==Break_Tag && !isEditBreak && (isProjectAccess || isActivityAccess))||(self.segmentedCtrl.selectedSegmentIndex==Break_Tag && isEditBreak && (!isProjectAccess && !isActivityAccess && (timeOffUri!=nil && ![timeOffUri isEqualToString:@"null"] && ![timeOffUri isKindOfClass:[NSNull class]]))))
            {
                breakUri=@"";
                breakName=@"";
            } //Implemented as per US9109//JUHI
            if (timeOffUri==nil || [timeOffUri isEqualToString:@"null"]||[timeOffUri isKindOfClass:[NSNull class]]||[timeOffUri isEqualToString:NULL_STRING]||(self.segmentedCtrl.selectedSegmentIndex==TimeEntry_Tag) || (self.segmentedCtrl.selectedSegmentIndex==Break_Tag && isEditBreak))
            {

                timeOffUri=@"";
                timeoffName=@"";
            }

            id tempclientName=nil;
            if ([clientName isEqualToString:@""])
            {
                tempclientName=[NSNull null];
            }
            else
            {
                tempclientName=clientName;
            }

            id tempclientUri=nil;
            if ([clientUri isEqualToString:@""])
            {
                tempclientUri=[NSNull null];
            }
            else
            {
                tempclientUri=clientUri;
            }
            id tempprojectName=nil;
            if ([projectName isEqualToString:@""])
            {
                tempprojectName=[NSNull null];
            }
            else
            {
                tempprojectName=projectName;
            }
            id tempprojectUri=nil;
            if ([projectUri isEqualToString:@""])
            {
                tempprojectUri=[NSNull null];
            }
            else
            {
                tempprojectUri=projectUri;
            }
            id tempactivityName=nil;
            if ([activityName isEqualToString:@""])
            {
                tempactivityName=[NSNull null];
            }
            else
            {
                tempactivityName=activityName;
            }
            id tempactivityUri=nil;
            if ([activityUri isEqualToString:@""])
            {
                tempactivityUri=[NSNull null];
            }
            else
            {
                tempactivityUri=activityUri;
            }
            id tempbillingName=nil;
            if ([billingName isEqualToString:@""])
            {
                tempbillingName=[NSNull null];
            }
            else
            {
                tempbillingName=billingName;
            }
            id tempbillingUri=nil;
            if ([billingUri isEqualToString:@""])
            {
                tempbillingUri=[NSNull null];
            }
            else
            {
                tempbillingUri=billingUri;
            }
            id temptaskName=nil;
            if ([taskName isEqualToString:@""])
            {
                temptaskName=[NSNull null];
            }
            else
            {
                temptaskName=taskName;
            }
            id temptaskUri=nil;
            if ([taskUri isEqualToString:@""])
            {
                temptaskUri=[NSNull null];
            }
            else
            {
                temptaskUri=taskUri;
            }
            id tempbreakName=nil;
            if ([breakName isEqualToString:@""])
            {
                tempbreakName=[NSNull null];
            }
            else
            {
                tempbreakName=breakName;
            }
            id tempbreakUri=nil;
            if ([breakUri isEqualToString:@""])
            {
                tempbreakUri=[NSNull null];
            }
            else
            {
                tempbreakUri=breakUri;
            }
            //Implemented as per US9109//JUHI
            id tempTimeoffUri=nil;
            if ([timeOffUri isEqualToString:@""])
            {
                tempTimeoffUri=[NSNull null];
            }
            else
            {
                tempTimeoffUri=timeOffUri;
            }
            id tempTimeoffName=nil;
            if ([timeoffName isEqualToString:@""])
            {
                tempTimeoffName=[NSNull null];
            }
            else
            {
                tempTimeoffName=timeoffName;
            }
            NSMutableDictionary *infoDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           tempclientName,@"clientName",
                                           tempclientUri,@"clientUri",
                                           tempprojectName,@"projectName",
                                           tempprojectUri,@"projectUri",
                                           tempactivityName,@"activityName",
                                           tempactivityUri,@"activityUri",
                                           tempbillingName,@"billingName",
                                           tempbillingUri,@"billingUri",
                                           temptaskName,@"taskName",
                                           temptaskUri,@"taskUri",
                                           tempbreakName,@"breakName",
                                           tempbreakUri,@"breakUri",
                                           tempTimeoffName,@"timeoffTypeName",
                                           tempTimeoffUri,@"timeoffTypeUri",
                                           nil];

            NSMutableDictionary *dict=[self getActiveCellsOnPresentDate];
            NSMutableArray *activeCellsArray=[dict objectForKey:@"activeCellObjectsArray"];
            NSMutableArray *indexArray=[dict objectForKey:@"indexOfactiveCellsArray"];
            BOOL isEntryAlreadyPresent=NO;
            if ([activeCellsArray containsObject:infoDict])
            {
                isEntryAlreadyPresent=NO;
            }


            if([delegate isKindOfClass:[TimesheetMainPageController class]])
            {
                TimesheetMainPageController *ctrl=(TimesheetMainPageController *)delegate;
                if (isMultiDayInOutTimesheetUser)
                {
                     if (isGen4UserTimesheet) {
                        [self.segmentedCtrl setSelectedSegmentIndex:Break_Tag];
                    }
                    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
                    [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                    myDateFormatter.dateFormat = @"EEEE, dd MMM yyyy";

                    NSLocale *locale=[NSLocale currentLocale];
                    [myDateFormatter setLocale:locale];
                    [myDateFormatter setDateFormat:@"EEEE, dd MMM yyyy"];
                    NSDate *todayDate=[myDateFormatter dateFromString:[myDateFormatter stringFromDate:[NSDate date]]];

                    if (ctrl.pageControl.currentPage<ctrl.timesheetDataArray.count)
                    {
                        NSMutableArray *tmpArray=[ctrl.timesheetDataArray objectAtIndex:ctrl.pageControl.currentPage];
                        NSArray *expArr = [tsModel getProjectDetailsFromDBForProjectUri:projectUri andModuleName:TIMESHEET_MODULE_NAME];
                        BOOL isRowEditable=NO;
                        if ([expArr count]!=0)
                        {
                            NSMutableDictionary *dict=[expArr objectAtIndex:0];
                            if ([dict objectForKey:@"startDate"]!=nil && ![[dict objectForKey:@"startDate"] isKindOfClass:[NSNull class]] && [dict objectForKey:@"endDate"]!=nil && ![[dict objectForKey:@"endDate"] isKindOfClass:[NSNull class]])
                            {
                                NSDate *endDateAllowed=[Util convertTimestampFromDBToDate:[dict objectForKey:@"endDate"]];
                                NSDate *startDateAllowed=[Util convertTimestampFromDBToDate:[dict objectForKey:@"startDate"]];
                                isRowEditable=[Util date:todayDate isBetweenDate:startDateAllowed andDate:endDateAllowed];
                            }
                            else
                            {
                                isRowEditable=YES;
                            }
                        }

                        NSArray *taskArr = [tsModel getTaskDetailsFromDBForTaskUri:taskUri andModuleName:TIMESHEET_MODULE_NAME];
                        if ([taskArr count]!=0)
                        {
                            NSMutableDictionary *dict=[taskArr objectAtIndex:0];
                            if ([dict objectForKey:@"startDate"]!=nil && ![[dict objectForKey:@"startDate"] isKindOfClass:[NSNull class]] && [dict objectForKey:@"endDate"]!=nil && ![[dict objectForKey:@"endDate"] isKindOfClass:[NSNull class]])
                            {
                                NSDate *endDateAllowed=[Util convertTimestampFromDBToDate:[dict objectForKey:@"endDate"]];
                                NSDate *startDateAllowed=[Util convertTimestampFromDBToDate:[dict objectForKey:@"startDate"]];
                                isRowEditable=[Util date:todayDate isBetweenDate:startDateAllowed andDate:endDateAllowed];
                            }
                            else
                            {
                                isRowEditable=YES;
                            }
                        }
                        if (self.segmentedCtrl.selectedSegmentIndex==TimeEntry_Tag) {
                            isRowEditable=YES;
                        }

                        if([delegate isKindOfClass:[TimesheetMainPageController class]])
                        {
                            TimesheetMainPageController *ctrl=(TimesheetMainPageController *)delegate;
                            NSMutableArray *entryObjectArray=[ctrl.timesheetDataArray objectAtIndex:ctrl.pageControl.currentPage];
                            if ([entryObjectArray count]>0)
                            {
                                TimesheetEntryObject *entryObject=(TimesheetEntryObject *)[entryObjectArray objectAtIndex:0];
                                todayDate=[entryObject timeEntryDate];
                            }
                            else
                            {
                                todayDate=self.currentPageDate;
                            }

                        }

                        //Implemented as per US9109//JUHI
                        NSMutableDictionary *multiDayInOutEntry=[NSMutableDictionary dictionary];
                        TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc] init];
                        if (timeOffUri==nil || [timeOffUri isEqualToString:@"null"]||[timeOffUri isKindOfClass:[NSNull class]]||[timeOffUri isEqualToString:NULL_STRING]||(self.segmentedCtrl.selectedSegmentIndex==TimeEntry_Tag) || (self.segmentedCtrl.selectedSegmentIndex==Break_Tag && isEditBreak))
                        {
                            //MOBI-746
                            [tsEntryObject setTimeEntryProgramName:programName];
                            [tsEntryObject setTimeEntryProgramUri:programUri];
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
                            [tsEntryObject setTimeEntryHoursInDecimalFormat:@""];
                            [tsEntryObject setTimeAllocationUri:@""];
                            [tsEntryObject setTimePunchUri:@""];
                            [tsEntryObject setTimeEntryHoursInHourFormat:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]];
                            [tsEntryObject setTimeEntryHoursInDecimalFormat:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]];
                            [tsEntryObject setTimeEntryComments:@""];
                            [tsEntryObject setBreakUri:breakUri];
                            [tsEntryObject setBreakName:breakName];
                            [tsEntryObject setRownumber:rowNumber];

                            [multiDayInOutEntry setObject:@"" forKey:@"in_time"];
                            [multiDayInOutEntry setObject:@"" forKey:@"out_time"];
                            [multiDayInOutEntry setObject:@"" forKey:@"comments"];
                            if (isGen4UserTimesheet)
                            {
                                if (![sender isKindOfClass:[UIBarButtonItem class]])
                                {
                                    NSDictionary *theData = sender;
                                    NSString *receivedClientID=[theData objectForKey:@"clientId"];
                                    NSString *receivedPunchID=[theData objectForKey:@"timeEntryUri"];
                                    if (receivedPunchID!=nil && ![receivedPunchID isKindOfClass:[NSNull class]])
                                    {
                                        [multiDayInOutEntry setObject:receivedPunchID forKey:@"timePunchesUri"];
                                    }

                                    if (receivedClientID!=nil && ![receivedClientID isKindOfClass:[NSNull class]])
                                    {
                                        [multiDayInOutEntry setObject:receivedClientID forKey:@"clientID"];
                                    }
                                }


                            }
                            if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
                            {
                                if (![self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                                {
                                    [multiDayInOutEntry setObject:udfArray forKey:@"udfArray"];
                                    [tsEntryObject setTimeEntryUdfArray:udfArray];
                                }
                                else if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                                {
                                    if([delegate isKindOfClass:[TimesheetMainPageController class]])
                                    {
                                        TimesheetMainPageController *ctrl=(TimesheetMainPageController *)delegate;
                                        if ([tsEntryObject.timeEntryCellOEFArray count]==0)
                                        {
                                            [tsEntryObject setTimeEntryCellOEFArray:[ctrl constructCellOEFObjectForTimeSheetUri:self.timesheetURI andtimesheetFormat:GEN4_STANDARD_TIMESHEET andOEFLevel:TIMESHEET_CELL_OEF andTimePunchUri:@""]];
                                        }


                                    }
                                }
                            }


                            [tsEntryObject setMultiDayInOutEntry:multiDayInOutEntry];
                            [tsEntryObject setTimePunchesArray:[NSMutableArray arrayWithObject:multiDayInOutEntry]];

                            [tsEntryObject setTimesheetUri:[timesheetObject timesheetURI]];
                            [tsEntryObject setTimesheetUri:self.timesheetURI];
                            [tsEntryObject setTimeAllocationUri:@""];
                            [tsEntryObject setTimePunchUri:@""];
                            [tsEntryObject setTimeEntryHoursInHourFormat:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]];
                            [tsEntryObject setTimeEntryHoursInDecimalFormat:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]];
                            [tsEntryObject setTimeEntryComments:@""];
                            //                        [tsEntryObject setRowUri:rowUri];
                            [tsEntryObject setIsNewlyAddedAdhocRow:YES];
                            [tsEntryObject setIsRowEditable:isRowEditable];

                        }
                        else{
                            //Insert Empty Adhoc Timeoff Entr

                            NSString *rowUri=[Util getRandomGUID];
                            //MOBI-746
                            [tsEntryObject setTimeEntryProgramName:nil];
                            [tsEntryObject setTimeEntryProgramUri:nil];
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
                            [tsEntryObject setTimeEntryTimeOffName:timeoffName];
                            [tsEntryObject setTimeEntryTimeOffUri:timeOffUri];
                            [tsEntryObject setTimeEntryDate:todayDate];
                            [tsEntryObject setMultiDayInOutEntry:nil];
                            if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
                            {
                                if (![self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                                {
                                    [tsEntryObject setTimeEntryUdfArray:udfArray];
                                }
                                else if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                                {
                                    if([delegate isKindOfClass:[TimesheetMainPageController class]])
                                    {
                                        TimesheetMainPageController *ctrl=(TimesheetMainPageController *)delegate;
                                        if ([tsEntryObject.timeEntryCellOEFArray count]==0)
                                        {
                                            [tsEntryObject setTimeEntryCellOEFArray:[ctrl constructCellOEFObjectForTimeSheetUri:self.timesheetURI andtimesheetFormat:GEN4_STANDARD_TIMESHEET andOEFLevel:TIMESHEET_CELL_OEF andTimePunchUri:@""]];
                                        }


                                    }
                                }
                            }


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
                        }


                        if (isEntryAlreadyPresent)
                        {
                            int index=[[NSString stringWithFormat:@"%@",[indexArray objectAtIndex:[activeCellsArray indexOfObject:infoDict]]] intValue];
                            TimesheetEntryObject *entryObj=(TimesheetEntryObject *)[tmpArray objectAtIndex:index];
                            NSMutableArray *punchesArray=[entryObj timePunchesArray];
                            [punchesArray addObject:multiDayInOutEntry];
                            [entryObj setTimePunchesArray:punchesArray];
                            [tmpArray replaceObjectAtIndex:index withObject:entryObj];
                            ctrl.indexPathForFirstResponder=[NSIndexPath indexPathForRow:[punchesArray count] inSection:index];
                        }
                        else
                        {

                            //Implemented as per US9109//JUHI
                            if (timeOffUri==nil || [timeOffUri isEqualToString:@"null"]||[timeOffUri isKindOfClass:[NSNull class]]||[timeOffUri isEqualToString:NULL_STRING]||((isProjectAccess || isActivityAccess)&&self.segmentedCtrl.selectedSegmentIndex==TimeEntry_Tag) || (self.segmentedCtrl.selectedSegmentIndex==Break_Tag && isEditBreak && (isProjectAccess || isActivityAccess))||(self.segmentedCtrl.selectedSegmentIndex==TimeEntry_Tag && isEditBreak && (!isProjectAccess && !isActivityAccess)))
                            {
                                [tmpArray addObject:tsEntryObject];
                                ctrl.indexPathForFirstResponder=[NSIndexPath indexPathForRow:1 inSection:[tmpArray count]-1];
                            }
                            else
                            {
                                //MOBI-539 Ullas M L
                                BOOL isTimeoffPresent=NO;
                                int numberOfTimeoff=0;
                                BOOL isFirstRowEmpty = false;
                                for (int n=0; n<[tmpArray count]; n++) {
                                    TimesheetEntryObject *entryObj=(TimesheetEntryObject *)[tmpArray objectAtIndex:n];
                                    if ([[entryObj entryType] isEqualToString:Time_Off_Key])
                                    {
                                        numberOfTimeoff=numberOfTimeoff+1;
                                    }
                                }
                                if ([tmpArray count]!=0)
                                {
                                    isFirstRowEmpty = [self isEmptyRow:tmpArray[0]];
                                    TimesheetEntryObject *entryObj=(TimesheetEntryObject *)[tmpArray objectAtIndex:0];
                                    if ([[entryObj entryType] isEqualToString:Time_Off_Key])
                                        isTimeoffPresent=YES;
                                    tmpArray = [self addEntryBeforeEmptyRowWithTimeEntryObject:tsEntryObject objectsArray:tmpArray numberOfTimeOff:numberOfTimeoff];
                                }
                                else
                                {
                                    self.rowTextFieldFocusIndex = 0;
                                    [tmpArray addObject:tsEntryObject];
                                }
                                if (isFirstRowEmpty) {
                                    self.rowTextFieldFocusIndex = 0;
                                }
                                else if (self.rowTextFieldFocusIndex == 0) {
                                    self.rowTextFieldFocusIndex = [tmpArray count] -1;
                                }
                                if (isGen4UserTimesheet)
                                {
                                    ctrl.indexPathForFirstResponder=[NSIndexPath indexPathForRow:1 inSection:self.rowTextFieldFocusIndex];
                                }
                                
                            }
                        }
                        [ctrl.timesheetDataArray replaceObjectAtIndex:ctrl.pageControl.currentPage withObject:tmpArray];
                    }
                }
                else
                {
                     NSString *rowUri=[Util getRandomGUID];
                    NSUInteger count=[ctrl.timesheetDataArray count];
                    for (int k=0; k<count; k++)
                    {
                        NSMutableArray *tmpArray=[ctrl.timesheetDataArray objectAtIndex:k];
                        NSDate *todayDate=nil;
                        if ([tmpArray count]!=0)
                        {
                            TimesheetEntryObject *entryObj=(TimesheetEntryObject *)[tmpArray objectAtIndex:0];
                            todayDate=[entryObj timeEntryDate];

                        }
                        else
                        {
                            if (ctrl.tsEntryDataArray.count>0)
                            {
                                NSString *formattedDate=[NSString stringWithFormat:@"%@",[[ctrl.tsEntryDataArray objectAtIndex:k] entryDate]];

                                NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
                                [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                                myDateFormatter.dateFormat = @"EEEE, dd MMM yyyy";

                                NSLocale *locale=[NSLocale currentLocale];
                                [myDateFormatter setLocale:locale];
                                todayDate=[myDateFormatter dateFromString:[NSString stringWithFormat:@"%@",formattedDate]];
                            }



                        }
                        NSArray *expArr = [tsModel getProjectDetailsFromDBForProjectUri:projectUri andModuleName:TIMESHEET_MODULE_NAME];
                        BOOL isRowEditable=NO;
                        if ([expArr count]!=0)
                        {
                            NSMutableDictionary *dict=[expArr objectAtIndex:0];
                            if ([dict objectForKey:@"startDate"]!=nil && ![[dict objectForKey:@"startDate"] isKindOfClass:[NSNull class]] && [dict objectForKey:@"endDate"]!=nil && ![[dict objectForKey:@"endDate"] isKindOfClass:[NSNull class]])
                            {
                                NSDate *endDateAllowed=[Util convertTimestampFromDBToDate:[dict objectForKey:@"endDate"]];
                                NSDate *startDateAllowed=[Util convertTimestampFromDBToDate:[dict objectForKey:@"startDate"]];
                                isRowEditable=[Util date:todayDate isBetweenDate:startDateAllowed andDate:endDateAllowed];
                            }
                            else
                            {
                                isRowEditable=YES;
                            }
                        }
                        NSArray *taskArr = [tsModel getTaskDetailsFromDBForTaskUri:taskUri andModuleName:TIMESHEET_MODULE_NAME];
                        if ([taskArr count]!=0)
                        {
                            NSMutableDictionary *dict=[taskArr objectAtIndex:0];
                            if ([dict objectForKey:@"startDate"]!=nil && ![[dict objectForKey:@"startDate"] isKindOfClass:[NSNull class]] && [dict objectForKey:@"endDate"]!=nil && ![[dict objectForKey:@"endDate"] isKindOfClass:[NSNull class]])
                            {
                                NSDate *endDateAllowed=[Util convertTimestampFromDBToDate:[dict objectForKey:@"endDate"]];
                                NSDate *startDateAllowed=[Util convertTimestampFromDBToDate:[dict objectForKey:@"startDate"]];
                                isRowEditable=[Util date:todayDate isBetweenDate:startDateAllowed andDate:endDateAllowed];
                            }
                            else
                            {
                                isRowEditable=YES;
                            }
                        }
                        NSArray *activityArr = [tsModel getActivityDetailsFromDBForActivityUri:activityUri andModuleName:TIMESHEET_MODULE_NAME];
                        if ([activityArr count]!=0)
                        {
                            isRowEditable=YES;
                        }//Implementation forMobi-181//JUHI
                        if(isRowUdf||self.segmentedCtrl.selectedSegmentIndex==TimeEntry_Tag)
                            isRowEditable=YES;
                        TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc] init];
                        //Implemented as per US9109//JUHI
                        if (timeOffUri==nil || [timeOffUri isEqualToString:@"null"]||[timeOffUri isKindOfClass:[NSNull class]]||[timeOffUri isEqualToString:NULL_STRING]||self.segmentedCtrl.selectedSegmentIndex==TimeEntry_Tag || (self.segmentedCtrl.selectedSegmentIndex==Break_Tag && isEditBreak))//Implementation forMobi-181//JUHI
                        {
                            //MOBI-746
                            [tsEntryObject setTimeEntryProgramName:programName];
                            [tsEntryObject setTimeEntryProgramUri:programUri];
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
                            [tsEntryObject setTimeEntryHoursInDecimalFormat:@""];
                            [tsEntryObject setTimeAllocationUri:@""];
                            [tsEntryObject setTimePunchUri:@""];
                            if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
                            {
                                if (![self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                                {
                                    [tsEntryObject setTimeEntryHoursInHourFormat:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]];
                                    [tsEntryObject setTimeEntryHoursInDecimalFormat:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]];
                                }
                            }
                            [tsEntryObject setTimeEntryComments:@""];
                            [tsEntryObject setBreakUri:@""];
                            [tsEntryObject setBreakName:@""];
                            [tsEntryObject setMultiDayInOutEntry:nil];
                            if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
                            {
                                if (![self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                                {
                                    [tsEntryObject setTimeEntryUdfArray:udfArray];
                                    [tsEntryObject setTimeEntryRowUdfArray:rowUdfArray];                            }
                                else if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                                {
                                    if([delegate isKindOfClass:[TimesheetMainPageController class]])
                                    {
                                        TimesheetMainPageController *ctrl=(TimesheetMainPageController *)delegate;
                                        if ([tsEntryObject.timeEntryCellOEFArray count]==0)
                                        {
                                            [tsEntryObject setTimeEntryCellOEFArray:[ctrl constructCellOEFObjectForTimeSheetUri:self.timesheetURI andtimesheetFormat:GEN4_STANDARD_TIMESHEET andOEFLevel:TIMESHEET_CELL_OEF andTimePunchUri:rowUri]];
                                        }

                                        if ([editEntryRowUdfArray count]==0)
                                        {
                                            editEntryRowUdfArray=[ctrl constructCellOEFObjectForTimeSheetUri:self.timesheetURI andtimesheetFormat:GEN4_STANDARD_TIMESHEET andOEFLevel:TIMESHEET_ROW_OEF andTimePunchUri:rowUri];
                                        }
                                        [tsEntryObject setTimeEntryRowOEFArray:editEntryRowUdfArray];
                                        
                                        
                                        
                                    }
                                    
                                    
                                }
                            }

                            
                            [tsEntryObject setTimesheetUri:[timesheetObject timesheetURI]];
                            [tsEntryObject setTimesheetUri:self.timesheetURI];
                            [tsEntryObject setRowUri:rowUri];
                            [tsEntryObject setIsNewlyAddedAdhocRow:YES];
                            [tsEntryObject setIsNewlyAddedAdhocRow:YES];
                            [tsEntryObject setIsRowEditable:isRowEditable];
                            [tsEntryObject setTimeEntryDate:todayDate];
                            
                            [tsEntryObject setRownumber:rowNumber];

                        }
                        else{
                            //Insert Empty Adhoc Timeoff Entr

                            //MOBI-746
                            [tsEntryObject setTimeEntryProgramName:nil];
                            [tsEntryObject setTimeEntryProgramUri:nil];
                            [tsEntryObject setTimeEntryClientName:@""];
                            [tsEntryObject setTimeEntryClientUri:@""];
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
                            [tsEntryObject setTimeEntryTimeOffName:timeoffName];
                            [tsEntryObject setTimeEntryTimeOffUri:timeOffUri];
                            [tsEntryObject setTimeEntryDate:todayDate];
                            [tsEntryObject setMultiDayInOutEntry:nil];
                            if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
                            {
                                if (![self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                                {
                                    [tsEntryObject setTimeEntryUdfArray:udfArray];

                                }
                                else if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                                {
                                    if([delegate isKindOfClass:[TimesheetMainPageController class]])
                                    {
                                        TimesheetMainPageController *ctrl=(TimesheetMainPageController *)delegate;
                                        if ([tsEntryObject.timeEntryCellOEFArray count]==0)
                                        {
                                            [tsEntryObject setTimeEntryCellOEFArray:[ctrl constructCellOEFObjectForTimeSheetUri:self.timesheetURI andtimesheetFormat:GEN4_STANDARD_TIMESHEET andOEFLevel:TIMESHEET_CELL_OEF andTimePunchUri:@""]];
                                        }

                                        
                                    }
                                    
                                    
                                }
                            }

                            
                            [tsEntryObject setTimesheetUri:timesheetURI];
                            [tsEntryObject setTimeAllocationUri:@""];
                            [tsEntryObject setTimePunchUri:@""];
                            [tsEntryObject setTimeEntryHoursInHourFormat:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]];
                            [tsEntryObject setTimeEntryHoursInDecimalFormat:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]];
                            [tsEntryObject setTimeEntryComments:@""];
//                            [tsEntryObject setRowUri:rowUri];
                            [tsEntryObject setIsNewlyAddedAdhocRow:YES];
                            [tsEntryObject setEntryType:Adhoc_Time_OffKey];
                            [tsEntryObject setIsRowEditable:YES];
                            [tsEntryObject setBreakUri:@""];
                            [tsEntryObject setBreakName:@""];
                        }
                        //Implemented as per US9109//JUHI
                        if (timeOffUri==nil || [timeOffUri isEqualToString:@"null"]||[timeOffUri isKindOfClass:[NSNull class]]||[timeOffUri isEqualToString:NULL_STRING]||(self.segmentedCtrl.selectedSegmentIndex==TimeEntry_Tag) || (self.segmentedCtrl.selectedSegmentIndex==Break_Tag && isEditBreak))
                        {
                            [tmpArray addObject:tsEntryObject];

                        }
                        else
                        {
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


                        }


                        [ctrl.timesheetDataArray replaceObjectAtIndex:k withObject:tmpArray];

                    }

                }

            }
            [self receivedDataForAdhocSave];

        }


    }

    
    else if ([delegate isKindOfClass:[AttendanceViewController class]])
    {
        NSString *projectName=[self.timesheetObject projectName];
        NSString *projectUri=[self.timesheetObject projectIdentity];
        NSString *taskName=[self.timesheetObject taskName];
        NSString *taskUri=[self.timesheetObject taskIdentity];
        NSString *activityName=[self.timesheetObject activityName];
        NSString *activityUri=[self.timesheetObject activityIdentity];
        NSString *billingName=[self.timesheetObject billingName];
        NSString *billingUri=[self.timesheetObject billingIdentity];
        NSString *breakName=[self.timesheetObject breakName];
        NSString *breakUri=[self.timesheetObject breakUri];
        NSString *clientName=nil;
        NSString *clientUri=nil;
        NSString *rowNumber=[self.timesheetObject rowNumber];
        
        if (isClientAccess)
        {
            clientName=[self.timesheetObject clientName];
            clientUri=[self.timesheetObject clientIdentity];
        }
        if (clientUri==nil || [clientUri isEqualToString:@"null"]||[clientUri isKindOfClass:[NSNull class]])
        {
            clientUri=@"";
            clientName=@"";
        }
        if (projectUri==nil || [projectUri isEqualToString:@"null"]||[projectUri isKindOfClass:[NSNull class]]||[projectUri isEqualToString:NULL_STRING] || self.segmentedCtrl.selectedSegmentIndex==Break_Tag )
        {
            projectUri=@"";
            projectName=@"";
        }
        if (taskUri==nil || [taskUri isEqualToString:@"null"]||[taskUri isKindOfClass:[NSNull class]]||[taskUri isEqualToString:NULL_STRING]||self.segmentedCtrl.selectedSegmentIndex==Break_Tag )
        {
            taskUri=@"";
            taskName=@"";
        }
        if (activityUri==nil || [activityUri isEqualToString:@"null"]||[activityUri isKindOfClass:[NSNull class]]||[activityUri isEqualToString:NULL_STRING]||self.segmentedCtrl.selectedSegmentIndex==Break_Tag )
        {
            activityUri=@"";
            activityName=@"";
        }
        if (billingUri==nil || [billingUri isEqualToString:@"null"]||[billingUri isKindOfClass:[NSNull class]]||[billingUri isEqualToString:NULL_STRING]||self.segmentedCtrl.selectedSegmentIndex==Break_Tag )
        {
            billingUri=@"";
            billingName=@"";
        }
        if (breakUri==nil || [breakUri isEqualToString:@"null"]||[breakUri isKindOfClass:[NSNull class]]||[breakUri isEqualToString:NULL_STRING]||(self.segmentedCtrl.selectedSegmentIndex==TimeEntry_Tag && (isProjectAccess || isActivityAccess))||(self.segmentedCtrl.selectedSegmentIndex==Break_Tag && !isEditBreak && (isProjectAccess || isActivityAccess))||(self.segmentedCtrl.selectedSegmentIndex==Break_Tag && isEditBreak && (!isProjectAccess && !isActivityAccess)))
        {
            breakUri=@"";
            breakName=@"";
        }


        TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc]init];
        [tsEntryObject setTimeEntryClientName:clientName];
        [tsEntryObject setTimeEntryClientUri:clientUri];
        [tsEntryObject setTimeEntryProjectName:projectName];
        [tsEntryObject setTimeEntryProjectUri:projectUri];
        [tsEntryObject setTimeEntryTaskName:taskName];
        [tsEntryObject setTimeEntryTaskUri:taskUri];
        [tsEntryObject setTimeEntryBillingName:billingName];
        [tsEntryObject setTimeEntryBillingUri:billingUri];
        [tsEntryObject setTimeEntryActivityName:activityName];
        [tsEntryObject setTimeEntryActivityUri:activityUri];
        [tsEntryObject setBreakName:breakName];
        [tsEntryObject setBreakUri:breakUri];
        [tsEntryObject setRownumber:rowNumber];
        AttendanceViewController *ctrl=(AttendanceViewController *)delegate;

        [ctrl setTsEntryObject:tsEntryObject];

        NSMutableDictionary *dict=[NSMutableDictionary dictionary];
        [dict setObject:clientName forKey:@"clientName"];
        [dict setObject:clientUri forKey:@"clientUri"];
        [dict setObject:projectName forKey:@"projectName"];
        [dict setObject:projectUri forKey:@"projectUri"];
        [dict setObject:taskName forKey:@"taskName"];
        [dict setObject:taskUri forKey:@"taskUri"];
        [dict setObject:billingName forKey:@"billingName"];
        [dict setObject:billingUri forKey:@"billingUri"];
        [dict setObject:activityName forKey:@"activityName"];
        [dict setObject:activityUri forKey:@"activityUri"];
        [dict setObject:breakName forKey:@"breakName"];
        [dict setObject:breakUri forKey:@"breakUri"];
        [ctrl sendPunchForData:dict actionType:PUNCH_IN_ACTION];
        [self.navigationController popViewControllerAnimated:YES ];

    }
    else if ([delegate isKindOfClass:[PunchEntryViewController class]])
    {
        PunchEntryViewController *ctrl=(PunchEntryViewController *)delegate;
        NSString *breakName=[self.timesheetObject breakName];
        NSString *breakUri=[self.timesheetObject breakUri];
        [ctrl updateBreakUri:breakUri andBreakName:breakName];
        [self.navigationController popViewControllerAnimated:YES ];

    }


}

-(void)continueAction:(id)sender
{
    CLS_LOG(@"----- Continue Action after selecting a Entry----");
    NSString *projectName=[self.timesheetObject projectName];
    NSString *projectUri=[self.timesheetObject projectIdentity];
    NSString *taskName=[self.timesheetObject taskName];
    NSString *taskUri=[self.timesheetObject taskIdentity];
    NSString *activityName=[self.timesheetObject activityName];
    NSString *activityUri=[self.timesheetObject activityIdentity];
    NSString *billingName=[self.timesheetObject billingName];
    NSString *billingUri=[self.timesheetObject billingIdentity];
    NSString *breakName=[self.timesheetObject breakName];
    NSString *breakUri=[self.timesheetObject breakUri];
    NSString *clientName=nil;
    NSString *clientUri=nil;
    if (isClientAccess)
    {
        clientName=[self.timesheetObject clientName];
        clientUri=[self.timesheetObject clientIdentity];
    }
    if (clientUri==nil || [clientUri isEqualToString:@"null"]||[clientUri isKindOfClass:[NSNull class]])
    {
        clientUri=@"";
        clientName=@"";
    }
    if (projectUri==nil || [projectUri isEqualToString:@"null"]||[projectUri isKindOfClass:[NSNull class]]||[projectUri isEqualToString:NULL_STRING] || self.segmentedCtrl.selectedSegmentIndex==Break_Tag )
    {
        projectUri=@"";
        projectName=@"";
    }
    if (taskUri==nil || [taskUri isEqualToString:@"null"]||[taskUri isKindOfClass:[NSNull class]]||[taskUri isEqualToString:NULL_STRING]||self.segmentedCtrl.selectedSegmentIndex==Break_Tag )
    {
        taskUri=@"";
        taskName=@"";
    }
    if (activityUri==nil || [activityUri isEqualToString:@"null"]||[activityUri isKindOfClass:[NSNull class]]||[activityUri isEqualToString:NULL_STRING]||self.segmentedCtrl.selectedSegmentIndex==Break_Tag )
    {
        activityUri=@"";
        activityName=@"";
    }
    if (billingUri==nil || [billingUri isEqualToString:@"null"]||[billingUri isKindOfClass:[NSNull class]]||[billingUri isEqualToString:NULL_STRING]||self.segmentedCtrl.selectedSegmentIndex==Break_Tag )
    {
        billingUri=@"";
        billingName=@"";
    }
    if (breakUri==nil || [breakUri isEqualToString:@"null"]||[breakUri isKindOfClass:[NSNull class]]||[breakUri isEqualToString:NULL_STRING]||(self.segmentedCtrl.selectedSegmentIndex==TimeEntry_Tag && (isProjectAccess || isActivityAccess))||(self.segmentedCtrl.selectedSegmentIndex==Break_Tag && !isEditBreak && (isProjectAccess || isActivityAccess))||(self.segmentedCtrl.selectedSegmentIndex==Break_Tag && isEditBreak && (!isProjectAccess && !isActivityAccess)))
    {
        breakUri=@"";
        breakName=@"";
    }
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    [dict setObject:clientName forKey:@"clientName"];
    [dict setObject:clientUri forKey:@"clientUri"];
    [dict setObject:projectName forKey:@"projectName"];
    [dict setObject:projectUri forKey:@"projectUri"];
    [dict setObject:taskName forKey:@"taskName"];
    [dict setObject:taskUri forKey:@"taskUri"];
    [dict setObject:billingName forKey:@"billingName"];
    [dict setObject:billingUri forKey:@"billingUri"];
    [dict setObject:activityName forKey:@"activityName"];
    [dict setObject:activityUri forKey:@"activityUri"];
    [dict setObject:breakName forKey:@"breakName"];
    [dict setObject:breakUri forKey:@"breakUri"];
    //Fix for MOBI-849//JUHI

    BOOL isCameraPermission=TRUE;

    DeviceType deviceType = [self getDeviceType];
    if (deviceType == OnDevice)
    {
        NSArray *devices = [AVCaptureDevice devices];
        AVCaptureDevice *frontCamera;
        AVCaptureDevice *backCamera;

        for (AVCaptureDevice *device in devices) {

//            NSLog(@"Device name: %@", [device localizedName]);

            if ([device hasMediaType:AVMediaTypeVideo]) {

                if ([device position] == AVCaptureDevicePositionBack) {
                    NSLog(@"Device position : back");
                    backCamera = device;
                }
                else {
                    NSLog(@"Device position : front");
                    frontCamera = device;
                }
            }
        }
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        if (!input)
        {
            isCameraPermission=FALSE;
        }

    }
    else

    {
        isCameraPermission=TRUE;
    }

    if (!isCameraPermission && isUsingAuditImages)
    {
        [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                       otherButtonTitle:nil
                                               delegate:self
                                                message:RPLocalizedString(CameraDisableMsg, @"")
                                                  title:@""
                                                    tag:001];


    }
    else{
        if (isUsingAuditImages && isCameraPermission)
        {
            CameraCaptureViewController *cameraViewCtrl=[[CameraCaptureViewController alloc]init];
            cameraViewCtrl._parentdelegate=self;
            cameraViewCtrl.projectInfoDict=dict;
            if (isEditBreak)
            {
                cameraViewCtrl.isUsingBreak=YES;
            }
            cameraViewCtrl.isPunchIn=YES;
            AttendanceViewController *ctrl=(AttendanceViewController *)delegate;
            cameraViewCtrl._delegate=ctrl;
            cameraViewCtrl.hidesBottomBarWhenPushed = YES ;
            
            [ctrl.navigationController pushViewController:cameraViewCtrl animated:FALSE];
        }

        else
        {

            if (![NetworkMonitor isNetworkAvailableForListener:self])
            {
                [Util showOfflineAlert];

            }
            else
            {

                self.punchMapViewController=[[PunchMapViewController alloc]init];
                self.punchMapViewController.isClockIn=YES;
                if (!isProjectAccess && !isActivityAccess && !isBillingAccess && self.screenMode!=EDIT_BREAK_ENTRY)
                {
                    self.punchMapViewController.delegate=delegate;
                }
                else
                {
                    self.punchMapViewController.delegate=self;
                }

                self.punchMapViewController.punchTime=[Util getCurrentTime:YES];
                self.punchMapViewController.punchTimeAmPm=[Util getCurrentTime:NO];
                self.punchMapViewController._parentDelegate=delegate;



                if ([delegate isKindOfClass:[AttendanceViewController class]])
                {
                    AttendanceViewController *attCtrl=(AttendanceViewController *)delegate;
                    punchMapViewController.locationDict=attCtrl.locationDict;
                    attCtrl.punchMapViewController=self.punchMapViewController;
                }






                punchMapViewController.projectInfoDict=dict;
                //        CGRect frame=punchMapViewController.view.frame;
                //        frame.origin.y=frame.origin.y+50;
                //        punchMapViewController.view.frame=frame;
                //AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];


                if (!isProjectAccess && !isActivityAccess && !isBillingAccess && self.screenMode!=EDIT_BREAK_ENTRY)
                {
                    //attCtrl.punchMapViewController=self.punchMapViewController;
                    //[appDelegate.window addSubview:attCtrl.punchMapViewController.view];
                    [punchMapViewController checkForLocation];
                }

                else
                {
                    //attCtrl.punchMapViewController=self.punchMapViewController;
                    //[appDelegate.window addSubview:punchMapViewController.view];
                    [punchMapViewController checkForLocation];
                }
            }


        }
    }



}
-(void)editAction:(id)sender
{
    if (!self.isEntryDetailsChanged)
    {
        [self.navigationController popViewControllerAnimated:TRUE];
        [datePicker removeFromSuperview];
        datePicker=nil;
    }
    else
    {
        if([delegate isKindOfClass:[TimesheetMainPageController class]])
        {
            TimesheetMainPageController *ctrl=(TimesheetMainPageController *)delegate;
            if (isMultiDayInOutTimesheetUser)
            {
                if (ctrl.pageControl.currentPage<ctrl.timesheetDataArray.count)
                {
                    NSMutableArray *entryObjectArray=[ctrl.timesheetDataArray objectAtIndex:ctrl.pageControl.currentPage];
                    if (indexBeingEdited<entryObjectArray.count)
                    {
                        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[entryObjectArray objectAtIndex:indexBeingEdited];

                        NSString *clientName=[self.timesheetObject clientName];
                        NSString *clientUri=[self.timesheetObject clientIdentity];
                        NSString *projectName=[self.timesheetObject projectName];
                        NSString *projectUri=[self.timesheetObject projectIdentity];
                        NSString *taskName=[self.timesheetObject taskName];
                        NSString *taskUri=[self.timesheetObject taskIdentity];
                        NSString *activityName=[self.timesheetObject activityName];
                        NSString *activityUri=[self.timesheetObject activityIdentity];
                        NSString *billingName=[self.timesheetObject billingName];
                        NSString *billingUri=[self.timesheetObject billingIdentity];
                        NSString *breakName=[self.timesheetObject breakName];
                        NSString *breakUri=[self.timesheetObject breakUri];
                        //Implementation as per US9109//JUHI
                        NSString *timeoffName=[self.timesheetObject TimeOffName];
                        NSString *timeoffUri=[self.timesheetObject TimeOffIdentity];
                        NSString *rowNumber=[self.timesheetObject rowNumber];
                        if (clientUri==nil || [clientUri isEqualToString:@"null"]||[clientUri isKindOfClass:[NSNull class]])
                        {
                            clientUri=@"";
                            clientName=@"";
                        }
                        if (projectUri==nil || [projectUri isEqualToString:@"null"]||[projectUri isKindOfClass:[NSNull class]])
                        {
                            projectUri=@"";
                            projectName=@"";
                        }
                        if (taskUri==nil || [taskUri isEqualToString:@"null"]||[taskUri isKindOfClass:[NSNull class]])
                        {
                            taskUri=@"";
                            taskName=@"";
                        }
                        if (activityUri==nil || [activityUri isEqualToString:@"null"]||[activityUri isKindOfClass:[NSNull class]])
                        {
                            activityUri=@"";
                            activityName=@"";
                        }
                        if (billingUri==nil || [billingUri isEqualToString:@"null"]||[billingUri isKindOfClass:[NSNull class]])
                        {
                            billingUri=@"";
                            billingName=@"";
                        }
                        if (breakUri==nil || [breakUri isEqualToString:@"null"]||[breakUri isKindOfClass:[NSNull class]]||[breakUri isEqualToString:NULL_STRING])
                        {
                            breakUri=@"";
                            breakName=@"";
                        }//Implementation as per US9109//JUHI
                        if (timeoffUri==nil || [timeoffUri isEqualToString:@"null"]||[timeoffUri isKindOfClass:[NSNull class]]||[timeoffUri isEqualToString:NULL_STRING])
                        {
                            timeoffUri=@"";
                            timeoffName=@"";
                        }
                        [tsEntryObject setTimeEntryClientName:clientName];
                        [tsEntryObject setTimeEntryClientUri:clientUri];
                        [tsEntryObject setTimeEntryActivityName:activityName];
                        [tsEntryObject setTimeEntryActivityUri:activityUri];
                        [tsEntryObject setTimeEntryBillingName:billingName];
                        [tsEntryObject setTimeEntryBillingUri:billingUri];
                        [tsEntryObject setTimeEntryProjectName:projectName];
                        [tsEntryObject setTimeEntryProjectUri:projectUri];
                        [tsEntryObject setTimeEntryTaskName:taskName];
                        [tsEntryObject setTimeEntryTaskUri:taskUri];
                        [tsEntryObject setRownumber:rowNumber];
                        //Implementation as per US9109//JUHI
                        if (timeoffUri!=nil && ![timeoffUri isEqualToString:@"null"]&&![timeoffUri isKindOfClass:[NSNull class]]&&![timeoffUri isEqualToString:NULL_STRING]&&![timeoffUri isEqualToString:@""])
                        {
                            [tsEntryObject setTimeEntryTimeOffName:timeoffName];
                            [tsEntryObject setTimeEntryTimeOffUri:timeoffUri];
                            [tsEntryObject setIsTimeoffSickRowPresent:YES];
                        }
                        else{
                            [tsEntryObject setTimeEntryTimeOffName:@""];
                            [tsEntryObject setTimeEntryTimeOffUri:@""];
                            [tsEntryObject setIsTimeoffSickRowPresent:NO];
                        }


                        if (isMultiDayInOutTimesheetUser)
                        {
                            [tsEntryObject setBreakName:breakName];
                            [tsEntryObject setBreakUri:breakUri];
                        }
                        else
                        {
                            [tsEntryObject setBreakName:@""];
                            [tsEntryObject setBreakUri:@""];
                        }


                        if ([timesheetStatus isEqualToString:NOT_SUBMITTED_STATUS]||[timesheetStatus isEqualToString:REJECTED_STATUS])
                        {
                            NSMutableArray *tmpArray=[ctrl.timesheetDataArray objectAtIndex:ctrl.pageControl.currentPage];
                            [tmpArray replaceObjectAtIndex:indexBeingEdited withObject:tsEntryObject];
                            [ctrl.timesheetDataArray replaceObjectAtIndex:ctrl.pageControl.currentPage withObject:tmpArray];
                            [self receivedDataForAdhocSave];
                            if (controllerDelegate!=nil && [controllerDelegate isKindOfClass:[EditEntryViewController class]])
                            {
                                [controllerDelegate reloadViewAfterEntryEdited];
                            }
                            else if (controllerDelegate!=nil && [controllerDelegate isKindOfClass:[MultiDayInOutViewController class]])
                            {
                                //                        if(isGen4UserTimesheet)
                                //                        {
                                //                          [controllerDelegate sendRequestToEditBreakEntryForTimeEntryObj:tsEntryObject];
                                //                        }
                                
                            }
                        }
                    }

                }
            }
            else
            {
                TimesheetEntryObject *tsTempEntryObject=nil;
                for (int i=0; i<[ctrl.timesheetDataArray count]; i++)
                {
                    NSMutableArray *entryObjectArray=[ctrl.timesheetDataArray objectAtIndex:i];
                    if (indexBeingEdited<entryObjectArray.count)
                    {
                        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[entryObjectArray objectAtIndex:indexBeingEdited];
                        NSMutableArray *rowUdfArray=nil;
                        if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
                        {
                            if (![self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                            {
                                rowUdfArray=[self getRowUdfsDetails];//Implementation for US9371//JUHI
                            }

                        }

                        NSString *projectName=[self.timesheetObject projectName];
                        NSString *projectUri=[self.timesheetObject projectIdentity];
                        NSString *taskName=[self.timesheetObject taskName];
                        NSString *taskUri=[self.timesheetObject taskIdentity];
                        NSString *activityName=[self.timesheetObject activityName];
                        NSString *activityUri=[self.timesheetObject activityIdentity];
                        NSString *billingName=[self.timesheetObject billingName];
                        NSString *billingUri=[self.timesheetObject billingIdentity];
                        NSString *breakName=[self.timesheetObject breakName];
                        NSString *breakUri=[self.timesheetObject breakUri];
                        NSString *clientName=[self.timesheetObject clientName];
                        NSString *clientUri=[self.timesheetObject clientIdentity];
                        //Implementation as per US9109//JUHI
                        NSString *timeoffName=[self.timesheetObject TimeOffName];
                        NSString *timeoffUri=[self.timesheetObject TimeOffIdentity];
                        NSString *rowNumber=[self.timesheetObject rowNumber];


                        if (clientUri==nil || [clientUri isEqualToString:@"null"]||[clientUri isKindOfClass:[NSNull class]])
                        {
                            clientUri=@"";
                            clientName=@"";
                        }
                        if (projectUri==nil || [projectUri isEqualToString:@"null"]||[projectUri isKindOfClass:[NSNull class]])
                        {
                            projectUri=@"";
                            projectName=@"";
                        }
                        if (taskUri==nil || [taskUri isEqualToString:@"null"]||[taskUri isKindOfClass:[NSNull class]])
                        {
                            taskUri=@"";
                            taskName=@"";
                        }
                        if (activityUri==nil || [activityUri isEqualToString:@"null"]||[activityUri isKindOfClass:[NSNull class]])
                        {
                            activityUri=@"";
                            activityName=@"";
                        }
                        if (billingUri==nil || [billingUri isEqualToString:@"null"]||[billingUri isKindOfClass:[NSNull class]])
                        {
                            billingUri=@"";
                            billingName=@"";
                        }
                        if (breakUri==nil || [breakUri isEqualToString:@"null"]||[breakUri isKindOfClass:[NSNull class]]||[breakUri isEqualToString:NULL_STRING])
                        {
                            breakUri=@"";
                            breakName=@"";
                        }//Implementation as per US9109//JUHI
                        if (timeoffUri==nil || [timeoffUri isEqualToString:@"null"]||[timeoffUri isKindOfClass:[NSNull class]]||[timeoffUri isEqualToString:NULL_STRING])
                        {
                            timeoffUri=@"";
                            timeoffName=@"";
                        }
                        [tsEntryObject setTimeEntryClientName:clientName];
                        [tsEntryObject setTimeEntryClientUri:clientUri];
                        [tsEntryObject setTimeEntryActivityName:activityName];
                        [tsEntryObject setTimeEntryActivityUri:activityUri];
                        [tsEntryObject setTimeEntryBillingName:billingName];
                        [tsEntryObject setTimeEntryBillingUri:billingUri];
                        [tsEntryObject setTimeEntryProjectName:projectName];
                        [tsEntryObject setTimeEntryProjectUri:projectUri];
                        [tsEntryObject setTimeEntryTaskName:taskName];
                        [tsEntryObject setTimeEntryTaskUri:taskUri];
                        [tsEntryObject setRownumber:rowNumber];

                        if (isMultiDayInOutTimesheetUser)
                        {
                            [tsEntryObject setBreakName:breakName];
                            [tsEntryObject setBreakUri:breakUri];
                        }
                        else
                        {
                            [tsEntryObject setBreakName:@""];
                            [tsEntryObject setBreakUri:@""];
                        }
                        //Implementation as per US9109//JUHI
                        if (timeoffUri!=nil && ![timeoffUri isEqualToString:@"null"]&&![timeoffUri isKindOfClass:[NSNull class]]&&![timeoffUri isEqualToString:NULL_STRING]&&![timeoffUri isEqualToString:@""])
                        {
                            [tsEntryObject setTimeEntryTimeOffName:timeoffName];
                            [tsEntryObject setTimeEntryTimeOffUri:timeoffUri];
                            [tsEntryObject setIsTimeoffSickRowPresent:YES];
                        }
                        else{
                            [tsEntryObject setTimeEntryTimeOffName:@""];
                            [tsEntryObject setTimeEntryTimeOffUri:@""];
                            [tsEntryObject setIsTimeoffSickRowPresent:NO];
                        }
                        if ([tsEntryObject isTimeoffSickRowPresent]==NO)
                        {
                            if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
                            {
                                if (![self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                                {
                                    [tsEntryObject setTimeEntryRowUdfArray:rowUdfArray];
                                }
                                else if ([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                                {
                                    if ([editEntryRowUdfArray count]==0)
                                    {
                                        editEntryRowUdfArray=[ctrl constructCellOEFObjectForTimeSheetUri:self.timesheetURI andtimesheetFormat:GEN4_STANDARD_TIMESHEET andOEFLevel:TIMESHEET_ROW_OEF andTimePunchUri:@""];
                                    }
                                    [tsEntryObject setTimeEntryRowOEFArray:editEntryRowUdfArray];
                                }
                            }


                        }

                        if (i==ctrl.pageControl.currentPage)
                        {
                            [tsTempEntryObject setTimeEntryHoursInDecimalFormat:[tsEntryObject timeEntryHoursInDecimalFormat]];
                            tsTempEntryObject=tsEntryObject;
                        }
                        
                        if ([timesheetStatus isEqualToString:NOT_SUBMITTED_STATUS]||[timesheetStatus isEqualToString:REJECTED_STATUS])
                        {
                            NSMutableArray *tmpArray=[ctrl.timesheetDataArray objectAtIndex:i];
                            [tmpArray replaceObjectAtIndex:indexBeingEdited withObject:tsEntryObject];
                            [ctrl.timesheetDataArray replaceObjectAtIndex:i withObject:tmpArray];
                            
                        }
                    }
                }
                [self receivedDataForAdhocSave];
                if (controllerDelegate!=nil && [controllerDelegate isKindOfClass:[EditEntryViewController class]])
                {
                    EditEntryViewController *ctrl=(EditEntryViewController *)controllerDelegate;
                    ctrl.tsEntryObject=tsTempEntryObject;
                    [controllerDelegate reloadViewAfterEntryEdited];
                }

            }

        }
        else if ([delegate isKindOfClass:[PunchEntryViewController class]]){

            NSString *breakName=[self.timesheetObject breakName];
            NSString *breakUri=[self.timesheetObject breakUri];
            [delegate updateBreakUri:breakUri andBreakName:breakName];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }



}

-(int)checkIfEntryAlreadyExistsForTimesheetEntryObject
{
    int returnIndex=12345;
    NSString *newProjectUri=[self.timesheetObject projectIdentity];
    NSString *newTaskUri=[self.timesheetObject taskIdentity];
    NSString *newActivityUri=[self.timesheetObject activityIdentity];
    NSString *newBillingUri=[self.timesheetObject billingIdentity];
    NSString *newBreakUri=[self.timesheetObject breakUri];
    NSString *newTimeoffUri=[self.timesheetObject TimeOffIdentity];//Implementation as per US9109//JUHI
    if (newProjectUri==nil ||[newProjectUri isKindOfClass:[NSNull class]]||[newProjectUri isEqualToString:NULL_STRING]|| [newProjectUri isEqualToString:@"null"])
    {
        newProjectUri=@"";

    }
    if (newTaskUri==nil ||[newTaskUri isKindOfClass:[NSNull class]]||[newTaskUri isEqualToString:NULL_STRING]|| [newTaskUri isEqualToString:@"null"])
    {
        newTaskUri=@"";

    }
    if (newActivityUri==nil ||[newActivityUri isKindOfClass:[NSNull class]]||[newActivityUri isEqualToString:NULL_STRING]|| [newActivityUri isEqualToString:@"null"])
    {
        newActivityUri=@"";
    }
    if (newBillingUri==nil ||[newBillingUri isKindOfClass:[NSNull class]]||[newBillingUri isEqualToString:NULL_STRING]|| [newBillingUri isEqualToString:@"null"])
    {
        newBillingUri=@"";

    }
    if (newBreakUri==nil ||[newBreakUri isKindOfClass:[NSNull class]]||[newBreakUri isEqualToString:NULL_STRING]|| [newBreakUri isEqualToString:@"null"])
    {
        newBreakUri=@"";

    }//Implementation as per US9109//JUHI
    if (newTimeoffUri==nil ||[newTimeoffUri isKindOfClass:[NSNull class]]||[newTimeoffUri isEqualToString:NULL_STRING]|| [newTimeoffUri isEqualToString:@"null"])
    {
        newTimeoffUri=@"";

    }
    if([delegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *ctrl=(TimesheetMainPageController *)delegate;
        if (ctrl.pageControl.currentPage<ctrl.timesheetDataArray.count)
        {
            NSMutableArray *entryObjectArray=[ctrl.timesheetDataArray objectAtIndex:ctrl.pageControl.currentPage];

            for (int k=0; k<[entryObjectArray count]; k++)
            {
                TimesheetEntryObject *obj=(TimesheetEntryObject *)[entryObjectArray objectAtIndex:k];
                NSString *oldProjectUri=[obj timeEntryProjectUri];
                NSString *oldTaskUri=[obj timeEntryTaskUri];
                NSString *oldActivityUri=[obj timeEntryActivityUri];
                NSString *oldBillingUri=[obj timeEntryBillingUri];
                NSString *oldBreakUri=[obj breakUri];
                NSString *oldTimeoffUri=[obj timeEntryTimeOffUri];//Implementation as per US9109//JUHI
                if (oldProjectUri==nil ||[oldProjectUri isKindOfClass:[NSNull class]]||[oldProjectUri isEqualToString:NULL_STRING]|| [oldProjectUri isEqualToString:@"null"])
                {
                    oldProjectUri=@"";

                }
                if (oldTaskUri==nil ||[oldTaskUri isKindOfClass:[NSNull class]]||[oldTaskUri isEqualToString:NULL_STRING]|| [oldTaskUri isEqualToString:@"null"])
                {
                    oldTaskUri=@"";

                }
                if (oldActivityUri==nil ||[oldActivityUri isKindOfClass:[NSNull class]]||[oldActivityUri isEqualToString:NULL_STRING]|| [oldActivityUri isEqualToString:@"null"])
                {
                    oldActivityUri=@"";
                }
                if (oldBillingUri==nil||[oldBillingUri isKindOfClass:[NSNull class]] ||[oldBillingUri isEqualToString:NULL_STRING]|| [oldBillingUri isEqualToString:@"null"])
                {
                    oldBillingUri=@"";

                }
                if (oldBreakUri==nil ||[oldBreakUri isKindOfClass:[NSNull class]]||[oldBreakUri isEqualToString:NULL_STRING]|| [oldBreakUri isEqualToString:@"null"])
                {
                    oldBreakUri=@"";

                }
                //Implementation as per US9109//JUHI
                if (oldTimeoffUri==nil ||[oldTimeoffUri isKindOfClass:[NSNull class]]||[oldTimeoffUri isEqualToString:NULL_STRING]|| [oldBreakUri isEqualToString:@"null"])
                {
                    oldTimeoffUri=@"";

                }


                if ([oldProjectUri isEqualToString:newProjectUri] &&
                    [oldActivityUri isEqualToString:newActivityUri] &&
                    [oldTaskUri isEqualToString:newTaskUri] &&
                    [oldBillingUri isEqualToString:newBillingUri] &&
                    [oldBreakUri isEqualToString:newBreakUri] )//ullas && [oldTimeoffUri isEqualToString:newTimeoffUri]
                {
                    //ullas
                    if ([oldProjectUri isEqualToString:@""] &&
                        [oldActivityUri isEqualToString:@""] &&
                        [oldTaskUri isEqualToString:@""] &&
                        [oldBillingUri isEqualToString:@""] &&
                        [oldBreakUri isEqualToString:@""])
                    {
                        
                    }
                    else
                    {
                        returnIndex=k;
                        break;
                        
                        
                    }
                }
                
            }
        }


    }
    return returnIndex;
}


#pragma mark
#pragma mark  UITableView Delegates

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:RepliconStandardBackgroundColor];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //Implementation as per US9109//JUHI
    if (self.isProjectAccess || self.isActivityAccess || isRowUdf|| self.isBillingAccess ||self.screenMode==EDIT_BREAK_ENTRY||self.screenMode==EDIT_Timeoff_ENTRY|| ((!isProjectAccess||!isActivityAccess|| !_hasTimesheetTimeoffAccess)&& isEditBreak)|| ((!isProjectAccess||!isActivityAccess ||!isEditBreak)&& _hasTimesheetTimeoffAccess))//Implementation forMobi-181//JUHI
    {
        return 1;
    }

    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //Implentation for US8956//JUHI
    if (self.segmentedCtrl.selectedSegmentIndex==Break_Tag ||self.screenMode==EDIT_BREAK_ENTRY ||self.segmentedCtrl.selectedSegmentIndex==Timeoff_Tag||self.screenMode==EDIT_Timeoff_ENTRY|| ((!isProjectAccess&&!isActivityAccess&& !_hasTimesheetTimeoffAccess)&& isEditBreak)|| ((!isProjectAccess&&!isActivityAccess &&!isEditBreak)&& _hasTimesheetTimeoffAccess)){//Implementation as per US9109//JUHI
        return Each_Cell_Row_Height_44;
    }
    else if (self.segmentedCtrl.selectedSegmentIndex==TimeEntry_Tag||(!isEditBreak && self.screenMode!=EDIT_BREAK_ENTRY))
    {
        if (isProjectAccess && indexPath.row==0)
        {
            NSString *clientName=self.timesheetObject.clientName;
            if (self.isProgramAccess) {
                clientName=self.timesheetObject.programName;
            }
            NSString *projectName=self.timesheetObject.projectName;
            NSString *taskName=self.timesheetObject.taskName;
            NSString *clientHeader=RPLocalizedString(Client, @"");
            NSString *projectHeader=RPLocalizedString(Project, @"");
            NSString *taskHeader=RPLocalizedString(Task, @"");
            if (self.isClientAccess||self.isProgramAccess)
            {
                if (clientName==nil || [clientName isKindOfClass:[NSNull class]] || [clientName isEqualToString:@""])
                {
                    clientName=RPLocalizedString(NONE_STRING, NONE_STRING);
                }
            }
            if (projectName==nil || [projectName isKindOfClass:[NSNull class]] || [projectName isEqualToString:@""])
            {
                projectName=RPLocalizedString(NONE_STRING, NONE_STRING);
            }
            if (taskName==nil || [taskName isKindOfClass:[NSNull class]] || [taskName isEqualToString:@""])
            {
                taskName=RPLocalizedString(NONE_STRING, NONE_STRING);
            }

            float height=0.0;
            float heightForClient=0.0;
            float heightForProject=0.0;
            float heightForTask=0.0;
            if (clientName && (self.isClientAccess||self.isProgramAccess))
            {
                float heightHeader=0.0;
                float heightValue=0.0;


                // Let's make an NSAttributedString first
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:clientName];
                //Add LineBreakMode
                NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
                [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
                [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
                // Add Font
                [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]} range:NSMakeRange(0, attributedString.length)];

                //Now let's make the Bounding Rect
                CGSize mainSize  = [attributedString boundingRectWithSize:CGSizeMake((SCREEN_WIDTH-24)/2, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

                if (mainSize.width==0 && mainSize.height ==0)
                {
                    mainSize=CGSizeMake(11.0, 18.0);
                }

                heightValue=mainSize.height+20.0;



                // Let's make an NSAttributedString first
               attributedString = [[NSMutableAttributedString alloc] initWithString:clientHeader];
                //Add LineBreakMode
                paragraphStyle = [NSMutableParagraphStyle new];
                [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
                [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
                // Add Font
                [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]} range:NSMakeRange(0, attributedString.length)];

                //Now let's make the Bounding Rect
                CGSize mainSizeHeader  = [attributedString boundingRectWithSize:CGSizeMake((SCREEN_WIDTH-24)/2, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

                if (mainSizeHeader.width==0 && mainSizeHeader.height ==0)
                {
                    mainSizeHeader=CGSizeMake(11.0, 18.0);
                }

                heightHeader=mainSizeHeader.height+20.0;

                if (heightHeader>heightValue)
                {
                    heightForClient=heightHeader;
                }
                else
                {
                    heightForClient=heightValue;
                }
            }
            if (projectName)
            {
                float heightHeader=0.0;
                float heightValue=0.0;


                // Let's make an NSAttributedString first
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:projectName];
                //Add LineBreakMode
                NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
                [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
                [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
                // Add Font
                [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]} range:NSMakeRange(0, attributedString.length)];

                //Now let's make the Bounding Rect
                CGSize mainSize  = [attributedString boundingRectWithSize:CGSizeMake((SCREEN_WIDTH-24)/2, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

                if (mainSize.width==0 && mainSize.height ==0)
                {
                    mainSize=CGSizeMake(11.0, 18.0);
                }

                heightValue=mainSize.height+20.0;




                // Let's make an NSAttributedString first
                attributedString = [[NSMutableAttributedString alloc] initWithString:projectHeader];
                //Add LineBreakMode
                paragraphStyle = [NSMutableParagraphStyle new];
                [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
                [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
                // Add Font
                [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]} range:NSMakeRange(0, attributedString.length)];

                //Now let's make the Bounding Rect
                CGSize mainSizeHeader  = [attributedString boundingRectWithSize:CGSizeMake((SCREEN_WIDTH-24)/2, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

                if (mainSizeHeader.width==0 && mainSizeHeader.height ==0)
                {
                    mainSizeHeader=CGSizeMake(11.0, 18.0);
                }
                heightHeader=mainSizeHeader.height+20.0;
                if (heightHeader>heightValue)
                {
                    heightForProject=heightHeader;
                }
                else
                {
                    heightForProject=heightValue;
                }
            }
            if (taskName)
            {
                float heightHeader=0.0;
                float heightValue=0.0;



                // Let's make an NSAttributedString first
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:taskName];
                //Add LineBreakMode
                NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
                [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
                [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
                // Add Font
                [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]} range:NSMakeRange(0, attributedString.length)];

                //Now let's make the Bounding Rect
                CGSize mainSize  = [attributedString boundingRectWithSize:CGSizeMake((SCREEN_WIDTH-24)/2, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

                if (mainSize.width==0 && mainSize.height ==0)
                {
                    mainSize=CGSizeMake(11.0, 18.0);
                }

                heightValue=mainSize.height+20.0;



                // Let's make an NSAttributedString first
                attributedString = [[NSMutableAttributedString alloc] initWithString:taskHeader];
                //Add LineBreakMode
                paragraphStyle = [NSMutableParagraphStyle new];
                [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
                [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
                // Add Font
                [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]} range:NSMakeRange(0, attributedString.length)];

                //Now let's make the Bounding Rect
                CGSize mainSizeHeader  = [attributedString boundingRectWithSize:CGSizeMake((SCREEN_WIDTH-24)/2, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;


                if (mainSizeHeader.width==0 && mainSizeHeader.height ==0)
                {
                    mainSizeHeader=CGSizeMake(11.0, 18.0);
                }
                heightHeader=mainSizeHeader.height+20.0;
                if (heightHeader>heightValue)
                {
                    heightForTask=heightHeader;
                }
                else
                {
                    heightForTask=heightValue;
                }

            }

            height=heightForClient+heightForProject+heightForTask;
            rowHeight=height+23;
            return height+23.0;
        }

        return Each_Cell_Row_Height_44;
    }
    return Each_Cell_Row_Height_44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //Implentation for US8956//JUHI

    if ((self.segmentedCtrl.selectedSegmentIndex==Break_Tag && !isEditBreak)||self.segmentedCtrl.selectedSegmentIndex==Timeoff_Tag ||self.screenMode==EDIT_Timeoff_ENTRY){
        return [adHocOptionList count];
    }

    //Implemented as per US9109//JUHI
    else if ((self.segmentedCtrl.selectedSegmentIndex==Break_Tag && isEditBreak) || self.screenMode==EDIT_BREAK_ENTRY)//Implementation forMobi-181//JUHI
    {
        return [breakEntryArray count];

    }    else if (self.segmentedCtrl.selectedSegmentIndex==TimeEntry_Tag||(!isEditBreak && self.screenMode!=EDIT_BREAK_ENTRY))
    {
        if (isProjectAccess)
        {
            return [timeEntryArray count]-1;
        }
        return [timeEntryArray count];
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier;
    NSString *fieldType=nil;
    CellIdentifier = cellIdentiferstr;//Fix for defect MOBI-456//JUHI
    UITableViewCell *cell = (CurrentTimeSheetsCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CurrentTimeSheetsCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

    }
    //Implemented as per US9109//JUHI
    if((self.segmentedCtrl.selectedSegmentIndex==Break_Tag && !isEditBreak) || self.segmentedCtrl.selectedSegmentIndex==Timeoff_Tag ||self.screenMode==EDIT_Timeoff_ENTRY)//Implementation forMobi-181//JUHI
    {

        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        NSMutableDictionary *dataDict=[adHocOptionList objectAtIndex:indexPath.row];
        if ([cell isKindOfClass:[CurrentTimeSheetsCellView class]])
        {
            for (UIView *view in cell.contentView.subviews)
            {
                [view removeFromSuperview];
            }
            [(CurrentTimeSheetsCellView *)cell setDelegate:self];
            [(CurrentTimeSheetsCellView *)cell setRowHeight:Each_Cell_Row_Height_44];
            [(CurrentTimeSheetsCellView *)cell setFieldValue:nil];
            [[(CurrentTimeSheetsCellView *)cell fieldValue ]removeFromSuperview];
            [(CurrentTimeSheetsCellView *)cell setDetailObj:nil];
            [cell setUserInteractionEnabled:TRUE];
            [cell.contentView setUserInteractionEnabled:TRUE];
            [(CurrentTimeSheetsCellView *)cell createCellWithLeftString:[dataDict objectForKey:@"timeoffTypeName"]
                                                     andLeftStringColor:nil
                                                         andRightString:nil
                                                    andRightStringColor:nil
                                                            hasComments:NO
                                                             hasTimeoff:NO
                                                                withTag:indexPath.row];

            if (self.screenMode==EDIT_Timeoff_ENTRY)
            {
                if ([[dataDict objectForKey:@"timeoffTypeName"] isEqualToString:self.selectedTimeoffString ])
                {
                    cell.accessoryType=UITableViewCellAccessoryCheckmark;
                    self.selectedIndexPath=indexPath;
                }
                else
                    cell.accessoryType=UITableViewCellAccessoryNone;
            }
            else
                cell.accessoryType=UITableViewCellAccessoryNone;

        }

    }//Implementation forMobi-181//JUHI
    else if((self.segmentedCtrl.selectedSegmentIndex==Break_Tag && isEditBreak) || self.screenMode==EDIT_BREAK_ENTRY)
    {

        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        NSMutableDictionary *dataDict=[breakEntryArray objectAtIndex:indexPath.row];
        if ([cell isKindOfClass:[CurrentTimeSheetsCellView class]])
        {
            for (UIView *view in cell.contentView.subviews)
            {
                [view removeFromSuperview];
            }
            [(CurrentTimeSheetsCellView *)cell setDelegate:self];
            [(CurrentTimeSheetsCellView *)cell setRowHeight:Each_Cell_Row_Height_44];
            [(CurrentTimeSheetsCellView *)cell setDetailObj:nil];
            [(CurrentTimeSheetsCellView *)cell setFieldValue:nil];
            [[(CurrentTimeSheetsCellView *)cell fieldValue ]removeFromSuperview];
            [cell setUserInteractionEnabled:TRUE];
            [cell.contentView setUserInteractionEnabled:TRUE];
            [(CurrentTimeSheetsCellView *)cell createCellWithLeftString:[dataDict objectForKey:@"breakName"]
                                                     andLeftStringColor:nil
                                                         andRightString:nil
                                                    andRightStringColor:nil
                                                            hasComments:NO
                                                             hasTimeoff:NO
                                                                withTag:indexPath.row];

            if (self.screenMode==EDIT_BREAK_ENTRY)
            {
                if ([[dataDict objectForKey:@"breakName"] isEqualToString:self.selectedBreakString ])
                {
                    cell.accessoryType=UITableViewCellAccessoryCheckmark;
                    self.selectedIndexPath=indexPath;
                }
                else
                    cell.accessoryType=UITableViewCellAccessoryNone;
            }
            else
                cell.accessoryType=UITableViewCellAccessoryNone;

        }
    }
	else if (self.segmentedCtrl.selectedSegmentIndex==TimeEntry_Tag||(!isEditBreak && self.screenMode!=EDIT_BREAK_ENTRY))
    {


        NSString *fieldName=nil;
        id fieldValue=nil;
        EntryCellDetails *rowdetails=nil;
        OEFObject *oefObject=nil;

        if (isProjectAccess && indexPath.row>0)
        {
            if ([[timeEntryArray objectAtIndex:indexPath.row+1] isKindOfClass:[EntryCellDetails class]])
            {
              rowdetails = (EntryCellDetails *)[timeEntryArray objectAtIndex:indexPath.row+1];
            }
            else if ([[timeEntryArray objectAtIndex:indexPath.row+1] isKindOfClass:[OEFObject class]])
            {
                oefObject = (OEFObject *)[timeEntryArray objectAtIndex:indexPath.row+1];
            }
        }
        else
        {
            if ([[timeEntryArray objectAtIndex:indexPath.row] isKindOfClass:[EntryCellDetails class]])
            {
                rowdetails = (EntryCellDetails *)[timeEntryArray objectAtIndex:indexPath.row];
            }
            else if ([[timeEntryArray objectAtIndex:indexPath.row] isKindOfClass:[OEFObject class]])
            {
                oefObject = (OEFObject *)[timeEntryArray objectAtIndex:indexPath.row];
            }
        }

        if (oefObject)
        {
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


            if (fieldValue == nil)
            {
                if([fieldType isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI])
                {
                    if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[timesheetStatus isEqualToString:APPROVED_STATUS ])
                    {
                        fieldValue=RPLocalizedString(NONE_STRING, @"");
                    }
                    else
                    {
                        fieldValue=RPLocalizedString(ADD, @"");
                    }
                }
                else if([fieldType isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI])
                {
                    if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[timesheetStatus isEqualToString:APPROVED_STATUS ])
                    {
                        fieldValue=RPLocalizedString(NONE_STRING, @"");
                    }
                    else
                    {
                        fieldValue=RPLocalizedString(SELECT_STRING, @"");
                    }
                }
                else if([fieldType isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI])
                {
                    if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[timesheetStatus isEqualToString:APPROVED_STATUS ])
                    {
                        fieldValue=RPLocalizedString(NONE_STRING, @"");
                    }
                    else
                    {
                        fieldValue=RPLocalizedString(ADD, @"");
                    }
                }

            }

            [(CurrentTimeSheetsCellView *)cell setDecimalPoints:2.0];
            [(CurrentTimeSheetsCellView *)cell setDelegate:self];
            [(CurrentTimeSheetsCellView *)cell setFieldType:fieldType];
            [(CurrentTimeSheetsCellView *)cell setDetailObj:oefObject];

        }
        else if(rowdetails)
        {
            fieldName =  [rowdetails fieldName];
            fieldValue = [rowdetails fieldValue];
            fieldType=[rowdetails fieldType];
            if (fieldValue == nil) {
                fieldValue = [rowdetails defaultValue];
            }
            else{
                if ([fieldValue isKindOfClass:[NSDate class]])
                {
                    fieldValue= [Util convertDateToString:fieldValue];
                }
            }
            if (rowdetails.decimalPoints!=0)
            {
                [(CurrentTimeSheetsCellView *)cell setDecimalPoints:rowdetails.decimalPoints];
            }
            [(CurrentTimeSheetsCellView *)cell setDelegate:self];
            [(CurrentTimeSheetsCellView *)cell setFieldType:fieldType];
            [(CurrentTimeSheetsCellView *)cell setDetailObj:rowdetails];
        }



        if (isProjectAccess && indexPath.row==0)
        {
            [(CurrentTimeSheetsCellView *)cell setRowHeight:rowHeight];
            for (UIView *view in cell.contentView.subviews)
            {
                [view removeFromSuperview];
            }

            EntryCellDetails *taskDtls = (EntryCellDetails *)[timeEntryArray objectAtIndex:1];
            NSString *taskValue = [taskDtls fieldValue];
            if (taskValue == nil) {
                taskValue = [taskDtls defaultValue];
            }

            NSString *clientValue=RPLocalizedString(SELECT_STRING, SELECT_STRING);
            if ([delegate isKindOfClass:[DayTimeEntryViewController class]])
            {
                clientValue=RPLocalizedString(NONE_STRING, NONE_STRING);
            }
            //MOBI-746
            if (isProgramAccess) {
                if (self.timesheetObject.programIdentity!=nil && ![self.timesheetObject.programIdentity isKindOfClass:[NSNull class]])
                {
                    clientValue=self.timesheetObject.programName;
                }
                else if (self.timesheetObject.projectIdentity!=nil && ![self.timesheetObject.projectIdentity isKindOfClass:[NSNull class]] && ![self.timesheetObject.projectIdentity isEqualToString:@"null"])
                {
                    clientValue=RPLocalizedString(NONE_STRING, NONE_STRING);
                }
            }
            else
            {
                if (self.timesheetObject.clientIdentity!=nil && ![self.timesheetObject.clientIdentity isKindOfClass:[NSNull class]])
                {
                    clientValue=self.timesheetObject.clientName;
                }
                else if (self.timesheetObject.projectIdentity!=nil && ![self.timesheetObject.projectIdentity isKindOfClass:[NSNull class]] && ![self.timesheetObject.projectIdentity isEqualToString:@"null"])
                {
                    clientValue=RPLocalizedString(NONE_STRING, NONE_STRING);
                }
            }

            [(CurrentTimeSheetsCellView *)cell createCellWithClientValue:clientValue andProjectValue:fieldValue andTaskValue:taskValue andHasClientAccess:self.isClientAccess andHasProgramAccess:self.isProgramAccess withTag:indexPath.row];
        }
        else
        {
            [(CurrentTimeSheetsCellView *)cell setRowHeight:Each_Cell_Row_Height_44];
            if ([cell isKindOfClass:[CurrentTimeSheetsCellView class]])
            {
                for (UIView *view in cell.contentView.subviews)
                {
                    [view removeFromSuperview];
                }
                [(CurrentTimeSheetsCellView *)cell createCellWithLeftString:fieldName
                                                         andLeftStringColor:nil
                                                             andRightString:fieldValue
                                                        andRightStringColor:nil
                                                                hasComments:NO
                                                                 hasTimeoff:NO
                                                                    withTag:indexPath.row];

            }

            //Implementation for US8902//JUHI
            if ([fieldName isEqualToString:RPLocalizedString(Task, @"") ]||[fieldName isEqualToString:RPLocalizedString(Billing, @"") ])
            {

                if ([delegate isKindOfClass:[DayTimeEntryViewController class]])
                {
                    [(CurrentTimeSheetsCellView *)cell setUserInteractionEnabled:YES];
                    [[(CurrentTimeSheetsCellView *)cell rightLb]setTextColor:RepliconStandardBlackColor];
                }
                else if (self.timesheetObject.projectIdentity==nil || [self.timesheetObject.projectIdentity isKindOfClass:[NSNull class]] || [self.timesheetObject.projectIdentity isEqualToString:@"null"]||[self.timesheetObject.projectIdentity isEqualToString:NULL_STRING])//IMPLEMENTED FOR US8388_TimesheetsDefaultingTheBillingRate
                {
                    [(CurrentTimeSheetsCellView *)cell setUserInteractionEnabled:NO];
                    [[(CurrentTimeSheetsCellView *)cell rightLb]setTextColor:RepliconStandardGrayColor];
                }
                else
                {
                    [(CurrentTimeSheetsCellView *)cell setUserInteractionEnabled:YES];
                    [[(CurrentTimeSheetsCellView *)cell rightLb]setTextColor:RepliconStandardBlackColor];
                }

            }
            if ([fieldType isEqualToString:UDFType_NUMERIC]||[fieldType isEqualToString:NUMERIC_UDF_TYPE]||[fieldType isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI])
            {
                [(CurrentTimeSheetsCellView *)cell setFieldType:fieldType];
                [[(CurrentTimeSheetsCellView *)cell rightLb] setHidden:YES];
                [[(CurrentTimeSheetsCellView *)cell fieldValue] setHidden:NO];
            }
            else{
                [[(CurrentTimeSheetsCellView *)cell rightLb] setHidden:NO];
                [[(CurrentTimeSheetsCellView *)cell fieldValue] setHidden:YES];
            }
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        cell.accessoryType=UITableViewCellAccessoryNone;
    }

    if (self.screenViewMode==VIEW_PROJECT_ENTRY)
    {
        [cell setUserInteractionEnabled:FALSE];
        if([fieldType isEqualToString:UDFType_TEXT] || [fieldType isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI])
        {
            [cell setUserInteractionEnabled:TRUE];
        }
    }

	return cell;

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([delegate isKindOfClass:[AttendanceViewController class]]) {
        if (isEditBreak)
        {
            [[self navigationItem].rightBarButtonItem setEnabled:TRUE];
        }
    }
    [self handleButtonClick:indexPath];
}

#pragma mark
#pragma mark  other methods

-(void)handleButtonClick:(NSIndexPath*)selectedIndex{
    //Implentation for US8956//JUHI
    if (self.segmentedCtrl.selectedSegmentIndex==Break_Tag || self.screenMode==EDIT_BREAK_ENTRY || self.segmentedCtrl.selectedSegmentIndex==Timeoff_Tag ||self.screenMode==EDIT_Timeoff_ENTRY)//Implementation as per US9109//JUHI
    {
        if (selectedIndexPath!=selectedIndex)
        {
            CurrentTimeSheetsCellView *previousSelectedCell = (CurrentTimeSheetsCellView *)[timeEntryTableView cellForRowAtIndexPath:selectedIndexPath];
            previousSelectedCell.accessoryType=UITableViewCellAccessoryNone;
        }
    }
    else
        [self doneClicked];
    NSString *fieldType = nil;

    [self setSelectedIndexPath:selectedIndex];
    [lastUsedTextField resignFirstResponder];

    CurrentTimeSheetsCellView *selectedCell = (CurrentTimeSheetsCellView *)[timeEntryTableView cellForRowAtIndexPath:selectedIndexPath];

    if ([selectedCell detailObj]!=nil)
    {
        if ([[selectedCell detailObj]isKindOfClass:[EntryCellDetails class]])
        {
            fieldType = [[selectedCell detailObj] fieldType];
        }
        else if ([[selectedCell detailObj]isKindOfClass:[OEFObject class]])
        {
            fieldType = [[selectedCell detailObj] oefDefinitionTypeUri];
        }
    }

    if ([fieldType isEqualToString:UDFType_DROPDOWN] || [fieldType isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI])
    {
        [self dataActionForSelectedCell:selectedCell];
    }
    else if ([fieldType isEqualToString:UDFType_NUMERIC] || [fieldType isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI]){

        [self TextAndNumericActionForSelectedCell:selectedCell];
    }
    else if ([fieldType isEqualToString:UDFType_TEXT] || [fieldType isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI]){
        [self textUdfAction:selectedCell];
    }
    else if ([fieldType isEqualToString:UDFType_DATE]){
        [self resetTableSize:YES];
        [self dateActionForSelectedCell:selectedCell];
        [timeEntryTableView selectRowAtIndexPath:selectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    else{
        [self moveToNextScreenActionForSelectedCell:selectedCell];
    }
}

-(void)showCustomPickerIfApplicable:(UITextField *)textField {

	//[self tableViewCellUntapped:selectedIndexPath];

	NSIndexPath *indexFromField = nil;

    indexFromField = [NSIndexPath indexPathForRow:textField.tag inSection:0];

	if (indexFromField != selectedIndexPath) {
		[timeEntryTableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
	}

	[self setSelectedIndexPath:indexFromField];
	[timeEntryTableView selectRowAtIndexPath:selectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
}
//Implementation for US9371//JUHI
-(void)dataActionForSelectedCell:(CurrentTimeSheetsCellView*)selectedCell{

    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        return;
    }

    DropDownViewController *dropDownViewCtrl=[[DropDownViewController alloc]init];
    dropDownViewCtrl.entryDelegate=self;
    if ([[selectedCell detailObj]isKindOfClass:[OEFObject class]])
    {
        OEFObject *oefObject=(OEFObject*)[selectedCell detailObj];
        dropDownViewCtrl.dropDownUri=[oefObject oefUri];
        dropDownViewCtrl.isGen4Timesheet=YES;
        dropDownViewCtrl.selectedDropDownString=[oefObject oefDropdownOptionValue];
        dropDownViewCtrl.dropDownName=[oefObject oefName];
    }
    else if ([[selectedCell detailObj]isKindOfClass:[EntryCellDetails class]])
    {
        EntryCellDetails *udfDetails=(EntryCellDetails*)[selectedCell detailObj];
        dropDownViewCtrl.dropDownUri=[udfDetails udfIdentity];
    }


    [self.navigationController pushViewController:dropDownViewCtrl animated:YES];


}
-(void)textUdfAction:(CurrentTimeSheetsCellView*)selectedCell{

    NSString *fieldValue=nil;
    NSString *fieldName=nil;

    if ([[selectedCell detailObj]isKindOfClass:[EntryCellDetails class]])
    {
        EntryCellDetails *dtlsObject = (EntryCellDetails *)[selectedCell detailObj];
        fieldValue=[dtlsObject fieldValue];
        fieldName=[dtlsObject fieldName];

    }
    else if ([[selectedCell detailObj]isKindOfClass:[OEFObject class]])
    {
        OEFObject *oefObject = (OEFObject *)[selectedCell detailObj];
        fieldValue=[oefObject oefTextValue];
        fieldName=[oefObject oefName];
    }



    AddDescriptionViewController *addDescriptionViewCtrl=[[AddDescriptionViewController alloc]init];

    addDescriptionViewCtrl.fromTextUdf =YES;
    if (fieldValue!=nil && ![fieldValue isKindOfClass:[NSNull class]]) {
        if ([fieldValue isEqualToString:RPLocalizedString(ADD, @"")]||[fieldValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])
        {
            [addDescriptionViewCtrl setDescTextString:@""];
        }
        else
            [addDescriptionViewCtrl setDescTextString:fieldValue];
    }
   else
   {
       [addDescriptionViewCtrl setDescTextString:fieldValue];
   }

    [addDescriptionViewCtrl setViewTitle:fieldName];
    addDescriptionViewCtrl.descControlDelegate=self;

    if (([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||([timesheetStatus isEqualToString:APPROVED_STATUS ])))
    {
        [addDescriptionViewCtrl setIsNonEditable:YES];
    }
    else
        [addDescriptionViewCtrl setIsNonEditable:NO];
    [self.navigationController pushViewController:addDescriptionViewCtrl animated:YES];

}
-(void)updateTextUdf:(NSString*)udfTextValue
{
    [self.timeEntryTableView scrollToRowAtIndexPath:selectedIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    CurrentTimeSheetsCellView *selectedCell = (CurrentTimeSheetsCellView *)[timeEntryTableView cellForRowAtIndexPath:selectedIndexPath];

     NSString *fieldValue=nil;

    if ([[selectedCell detailObj]isKindOfClass:[EntryCellDetails class]])
    {
        EntryCellDetails *dtlsObject = (EntryCellDetails *)[selectedCell detailObj];
        fieldValue=[dtlsObject fieldValue];

    }
    else if ([[selectedCell detailObj]isKindOfClass:[OEFObject class]])
    {
        OEFObject *oefObject = (OEFObject *)[selectedCell detailObj];
        fieldValue=[oefObject oefNumericValue];

    }




    //Implementation forMobi-181//JUHI
    if (![udfTextValue isEqualToString:fieldValue] && (self.screenViewMode==EDIT_PROJECT_ENTRY || (!isProjectAccess && !isActivityAccess && isRowUdf)))
    {
        self.isEntryDetailsChanged=YES;
        [[self navigationItem].rightBarButtonItem setEnabled:TRUE];
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

    if ([[selectedCell detailObj]isKindOfClass:[EntryCellDetails class]])
    {
        EntryCellDetails *dtlsObject = (EntryCellDetails *)[selectedCell detailObj];
        [dtlsObject setFieldValue:udfTextStr];

        if(dtlsObject !=nil && (![dtlsObject isKindOfClass:[NSNull class]]))
        {
            if (isProjectAccess)
            {
                [self.timeEntryArray replaceObjectAtIndex:selectedIndexPath.row+1 withObject:dtlsObject];
            }
            else
                [self.timeEntryArray replaceObjectAtIndex:selectedIndexPath.row withObject:dtlsObject];
        }

    }
    else if ([[selectedCell detailObj]isKindOfClass:[OEFObject class]])
    {
        OEFObject *oefObject = (OEFObject *)[selectedCell detailObj];
        [oefObject setOefTextValue:udfTextStr];
        
    }



    [self.timeEntryTableView beginUpdates];
    [self.timeEntryTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:selectedIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    [self.timeEntryTableView endUpdates];

}
-(void)updateDropDownFieldWithFieldName:(NSString*)fieldName andFieldURI:(NSString*)fieldUri{
    CurrentTimeSheetsCellView *selectedCell = (CurrentTimeSheetsCellView *)[timeEntryTableView cellForRowAtIndexPath:selectedIndexPath];
    NSString *fieldValue=nil;
    if (fieldName!=nil && ![fieldName isKindOfClass:[NSNull class]]&&[fieldName isEqualToString:RPLocalizedString(NONE_STRING, NONE_STRING)]&& (fieldUri==nil || [fieldUri isKindOfClass:[NSNull class]]))
    {
        fieldName=RPLocalizedString(SELECT_STRING, @"");

    }

    if ([[selectedCell detailObj]isKindOfClass:[OEFObject class]])
    {
        OEFObject *oefObject=(OEFObject*)[selectedCell detailObj];
        fieldValue=oefObject.oefDropdownOptionValue;
        if ([fieldName isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
        {
            [oefObject setOefDropdownOptionUri:fieldUri];
        }
    }
    else if ([[selectedCell detailObj]isKindOfClass:[EntryCellDetails class]])
    {
        EntryCellDetails *udfDetails=(EntryCellDetails*)[selectedCell detailObj];
        fieldValue=udfDetails.fieldValue;
        if ([fieldName isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
        {
            [udfDetails setDropdownOptionUri:fieldUri];
        }
    }



    //Implementation forMobi-181//JUHI
    if (![fieldName isEqualToString:fieldValue]&& (self.screenViewMode==EDIT_PROJECT_ENTRY || (!isProjectAccess && !isActivityAccess && isRowUdf)))
    {
        self.isEntryDetailsChanged=YES;
        [[self navigationItem].rightBarButtonItem setEnabled:TRUE];
    }


    if ([[selectedCell detailObj]isKindOfClass:[OEFObject class]])
    {
        OEFObject *oefObject=(OEFObject*)[selectedCell detailObj];
        if (fieldName!=nil && ![fieldName isKindOfClass:[NSNull class]])
        {
            [oefObject setOefDropdownOptionValue:fieldName];


        }
        if (fieldUri!=nil && ![fieldUri isKindOfClass:[NSNull class]])
        {
            [oefObject setOefDropdownOptionUri:fieldUri];
            
        }
    }
    else if ([[selectedCell detailObj]isKindOfClass:[EntryCellDetails class]])
    {
        EntryCellDetails *udfDetails=(EntryCellDetails*)[selectedCell detailObj];
        if (fieldName!=nil && ![fieldName isKindOfClass:[NSNull class]])
        {
            [udfDetails setFieldValue:fieldName];


        }
        if (fieldUri!=nil && ![fieldUri isKindOfClass:[NSNull class]])
        {
            [udfDetails setDropdownOptionUri:fieldUri];

        }

        if (isProjectAccess)
        {
            [self.timeEntryArray replaceObjectAtIndex:selectedIndexPath.row+1 withObject:udfDetails];
        }
        else
            [self.timeEntryArray replaceObjectAtIndex:selectedIndexPath.row withObject:udfDetails];
    }




    [self.timeEntryTableView beginUpdates];
    [self.timeEntryTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:selectedIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    [self.timeEntryTableView endUpdates];

}
-(void)dateActionForSelectedCell:(CurrentTimeSheetsCellView*)selectedCell{
    EntryCellDetails *detailObj=(EntryCellDetails*)[selectedCell detailObj];

    id fieldValue = [detailObj fieldValue]==nil||[[detailObj fieldValue]isKindOfClass:[NSNull class]]?[detailObj defaultValue]:[detailObj fieldValue];
    if ([fieldValue isKindOfClass:[NSDate class]])
    {
        fieldValue=[Util convertDateToString:fieldValue];
    }
    CGSize pickerSize = [Util getDatePickerViewFrame];
    
    NSString *dateStr=fieldValue;
    self.previousDateUdfValue=dateStr;
    
    AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
   
    BOOL isTabBarHidden =  NO;
    if (self.screenViewMode ==ADD_PROJECT_ENTRY)
    {
        isTabBarHidden =  YES;
    }
    
    float datePickerYPosition = [Util datePickerYPosition:isTabBarHidden];

    datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, datePickerYPosition, pickerSize.width, pickerSize.height)];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.hidden = NO;
    datePicker.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];

    [self.datePicker setAccessibilityIdentifier:@"uia_row_level_date_udf_picker_identifier"];

    if ([fieldValue isKindOfClass:[NSString class]])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

        NSLocale *locale=[NSLocale currentLocale];
        [dateFormatter setLocale:locale];
        if ([dateStr isEqualToString:RPLocalizedString(SELECT_STRING, @"")]||[dateStr isEqualToString:[detailObj defaultValue]]) {
            self.datePicker.date = [NSDate date];

        }
        else{
            [dateFormatter setDateFormat:@"MMMM d, yyyy"];
            fieldValue = [dateFormatter dateFromString:dateStr];
            self.datePicker.date = fieldValue;
        }

    }

    [self.datePicker addTarget:self
                        action:@selector(updateFieldWithPickerChange:)
              forControlEvents:UIControlEventValueChanged];
    //Fix for defect MOBI-450//JUHI
    if ([[detailObj fieldValue] isKindOfClass:[NSString class]])
    {
        if ([[detailObj fieldValue] isEqualToString:RPLocalizedString(SELECT_STRING, @"")] || [[detailObj fieldValue] isKindOfClass:[NSNull class]] || [detailObj fieldValue]==nil )
        {
            [self updateFieldWithPickerChange:self.datePicker];
        }
    }

    //[self.view addSubview:self.datePicker];
    //    appDelegate.rootTabBarController.tabBar.hidden=TRUE;
    [appDelegate.window addSubview:self.datePicker];

    float toolBarYPosition = self.view.frame.size.height - pickerSize.height - 50;

    UIToolbar *temptoolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, toolBarYPosition, pickerSize.width, 50)];
    self.toolbar=temptoolbar;
    self.toolbar.barStyle = UIBarStyleBlackOpaque;
    //Implementation for US8771 HandleDateUDFEmptyValue//JUHI
    UIBarButtonItem *tempDoneButton = [[UIBarButtonItem alloc] initWithTitle: @"Done" style: UIBarButtonItemStylePlain target: self action: @selector(doneClicked)];
    self.doneButton=tempDoneButton;

    [self.toolbar setAccessibilityIdentifier:@"uia_row_level_toolbar_identifier"];
    [self.doneButton setAccessibilityLabel:@"uia_row_level_date_picker_done_btn_identifier"];

    
    UIBarButtonItem *tmpCancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                     target:self
                                                                                     action:@selector(pickerCancel:)];
    self.cancelButton=tmpCancelButton;


    UIBarButtonItem *tmpSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:nil
                                                                                    action:nil];
	self.spaceButton=tmpSpaceButton;



    //Implementation for US8771 HandleDateUDFEmptyValue//JUHI
    UIBarButtonItem *tmpClearButton = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString(@"Clear", @"Clear") style: UIBarButtonItemStylePlain target: self action: @selector(pickerClear:)];
    self.pickerClearButton=tmpClearButton;

    //Fix for ios7//JUHI
	float version= [[UIDevice currentDevice].systemVersion newFloatValue];

    if (version<7.0)
    {
        [toolbar setTintColor:[UIColor clearColor]];
    }
    else

    {
        self.doneButton.tintColor=RepliconStandardWhiteColor;
        self.cancelButton.tintColor=RepliconStandardWhiteColor;
        self.pickerClearButton.tintColor=RepliconStandardWhiteColor;
        UIImage *backgroundImage = [Util thumbnailImage:TOOLBAR_IMAGE];
        [toolbar setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
        [toolbar setTintColor:[Util colorWithHex:@"#dddddd" alpha:1]];
        [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    }
    NSArray *toolArray = [NSArray arrayWithObjects:cancelButton,pickerClearButton,spaceButton,doneButton,nil];
    [toolbar setItems:toolArray];

    [self.view addSubview: self.toolbar];

}
-(void)moveToNextScreenActionForSelectedCell:(CurrentTimeSheetsCellView*)selectedCell
{
    //Implentation for US8956//JUHI
    if ((self.segmentedCtrl.selectedSegmentIndex==Break_Tag && isEditBreak && (isProjectAccess|| isActivityAccess)) || self.screenMode==EDIT_BREAK_ENTRY|| ((!isProjectAccess&&!isActivityAccess&& !_hasTimesheetTimeoffAccess)&& isEditBreak)||(self.segmentedCtrl.selectedSegmentIndex==TimeEntry_Tag && !isProjectAccess && !isActivityAccess)){

        if (self.screenMode==EDIT_Timeoff_ENTRY||((!isProjectAccess&&!isActivityAccess &&!isEditBreak)&& _hasTimesheetTimeoffAccess))
        {
            NSDictionary *dataDict=[adHocOptionList objectAtIndex:selectedIndexPath.row];
            [timesheetObject setTimeOffIdentity:[dataDict objectForKey:@"timeoffTypeUri"]];
            [timesheetObject setTimeOffName:[dataDict objectForKey:@"timeoffTypeName"]];
            selectedCell.accessoryType=UITableViewCellAccessoryCheckmark;
            isEntryDetailsChanged=YES;
            [[self navigationItem].rightBarButtonItem setEnabled:TRUE];
            if (self.screenMode==EDIT_Timeoff_ENTRY)
            {
                [self editAction:nil];
            }

        }
        else{
            NSDictionary *dataDict=[breakEntryArray objectAtIndex:selectedIndexPath.row];
            [timesheetObject setBreakName:[dataDict objectForKey:@"breakName"]];
            [timesheetObject setBreakUri:[dataDict objectForKey:@"breakUri"]];
            selectedCell.accessoryType=UITableViewCellAccessoryCheckmark;
            self.selectedBreakString = [dataDict objectForKey:@"breakName"];
            isEntryDetailsChanged=YES;
            [[self navigationItem].rightBarButtonItem setEnabled:TRUE];
            if (self.screenMode==EDIT_BREAK_ENTRY)
            {

                if (isGen4UserTimesheet)
                {

                    if (isEditBreak)
                    {
                        UIBarButtonItem *tempRightButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(Save_Button_Title, @"") style:UIBarButtonItemStylePlain target:self action:@selector(sendAddGen4BreakInfoRequest)];
                        [self navigationItem].rightBarButtonItem=tempRightButtonOuterBtn;
                    }
                    else
                    {
                        UIBarButtonItem *tempRightButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(Save_Button_Title, @"") style:UIBarButtonItemStylePlain target:self action:@selector(sendEditGen4BreakInfoRequest)];
                        [self navigationItem].rightBarButtonItem=tempRightButtonOuterBtn;
                    }
                }
                else
                {
                    BOOL isTakeImagePermission=TRUE;
                    if (![delegate isKindOfClass:[AttendanceViewController class]])
                    {
                        isTakeImagePermission=FALSE;
                    }
                    if (isTakeImagePermission)
                    {
                        UIBarButtonItem *tempRightButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(Continue_Button_Title, @"") style:UIBarButtonItemStylePlain target:self action:@selector(continueAction:)];
                        [self navigationItem].rightBarButtonItem=tempRightButtonOuterBtn;
                    }
                    else
                    {
                        UIBarButtonItem *tempRightButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(Save_Button_Title, @"") style:UIBarButtonItemStylePlain target:self action:@selector(saveAction:)];
                        [self navigationItem].rightBarButtonItem=tempRightButtonOuterBtn;
                    }

                }


            }
            else
            {
                [[self navigationItem].rightBarButtonItem setEnabled:TRUE];
            }
        }

    }  //Implemented as per US9109//JUHI
    else if ((self.segmentedCtrl.selectedSegmentIndex==Break_Tag && !isEditBreak&& (isProjectAccess|| isActivityAccess))||self.segmentedCtrl.selectedSegmentIndex==Timeoff_Tag ||self.screenMode==EDIT_Timeoff_ENTRY|| ((!isProjectAccess&&!isActivityAccess &&!isEditBreak)&& _hasTimesheetTimeoffAccess)||(self.segmentedCtrl.selectedSegmentIndex==Break_Tag && isEditBreak&& (!isProjectAccess&&!isActivityAccess))){
        NSDictionary *dataDict=[adHocOptionList objectAtIndex:selectedIndexPath.row];
        [timesheetObject setTimeOffIdentity:[dataDict objectForKey:@"timeoffTypeUri"]];
        [timesheetObject setTimeOffName:[dataDict objectForKey:@"timeoffTypeName"]];
        selectedCell.accessoryType=UITableViewCellAccessoryCheckmark;
        isEntryDetailsChanged=YES;
        [[self navigationItem].rightBarButtonItem setEnabled:TRUE];
        if (self.screenMode==EDIT_Timeoff_ENTRY)
        {
            [self editAction:nil];
        }
    }

    else if (self.segmentedCtrl.selectedSegmentIndex==TimeEntry_Tag||(!isEditBreak && self.screenMode!=EDIT_BREAK_ENTRY))
    {
        NSString *fieldValue=nil;
        NSString *fieldName=nil;
        if ([[selectedCell detailObj]isKindOfClass:[EntryCellDetails class]])
        {
            EntryCellDetails *dtlsObject = (EntryCellDetails *)[selectedCell detailObj];
            fieldValue=[dtlsObject fieldValue];
            fieldName=[dtlsObject fieldName];
        }
        else if ([[selectedCell detailObj]isKindOfClass:[OEFObject class]])
        {
            OEFObject *oefObject = (OEFObject *)[selectedCell detailObj];
            fieldValue=[oefObject oefTextValue];
            fieldName=[oefObject oefName];
        }


        if ([fieldName isEqualToString:RPLocalizedString(Project, @"")])
        {
            if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
            {
                [Util showOfflineAlert];

            }
            else
            {
                SelectClientOrProjectViewController *searchView=[[SelectClientOrProjectViewController alloc]init];
                searchView.delegate=delegate;
                searchView.viewDelegate=self;
                searchView.isFromLockedInOut=isFromLockedInOut;
                searchView.isFromAttendance=isFromAttendance;
                TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                [timesheetModel deleteAllClientsInfoFromDBForModuleName:@"Timesheet"];
                [timesheetModel deleteAllProjectsInfoFromDBForModuleName:@"Timesheet"];


                NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
                [defaults setObject:[NSNumber numberWithInt:0] forKey:@"totalClientCount"];
                [defaults setObject:[NSNumber numberWithInt:0] forKey:@"totalProjectCount"];
                [defaults synchronize];

                if ([delegate isKindOfClass:[TimesheetMainPageController class]])
                {
                    searchView.selectedTimesheetUri=self.timesheetURI;
                }
                else
                {
                    NSString *timesheetUri=timesheetObject.timesheetURI;
                    searchView.selectedTimesheetUri=timesheetUri;
                }

                searchView.searchProjectString=timesheetObject.projectName;

                [searchView setHidesBottomBarWhenPushed:FALSE];

                if((self.timesheetObject.clientIdentity==nil || [self.timesheetObject.clientIdentity isKindOfClass:[NSNull class]] || !self.isClientAccess))
                {
                    searchView.isPreFilledSearchString=YES;

                    [self.navigationController pushViewController:searchView animated:YES];
                }
                else
                {

                    searchView.isPreFilledSearchString=YES;
                    if((self.timesheetObject.clientIdentity==nil || [self.timesheetObject.clientIdentity isKindOfClass:[NSNull class]] || !self.isClientAccess))
                    {
                        searchView.isPreFilledSearchString=NO;
                    }
                    searchView.selectedClientName=timesheetObject.clientName;
                    searchView.selectedClientUri=timesheetObject.clientIdentity;

                    [self.navigationController pushViewController:searchView animated:NO];
                }




            }

        }
        else if ([fieldName isEqualToString:RPLocalizedString(Task, @"")])
        {
            if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
            {
                [Util showOfflineAlert];

            }
            else
            {
                SelectProjectOrTaskViewController *selectVC=[[SelectProjectOrTaskViewController alloc]init];
                selectVC.delegate=delegate;
                selectVC.entryDelegate=self;
                selectVC.isFromLockedInOut=isFromLockedInOut;
                selectVC.isFromAttendance=isFromAttendance;
                NSString *name=@"";

                selectVC.selectedItem=RPLocalizedString(Project, @"");
                name=self.timesheetObject.projectName;
                selectVC.isTaskPermission=YES;
                selectVC.isTimeAllowedPermission=self.isTimeAllowedPermission;
                selectVC.selectedClientUri=self.timesheetObject.clientIdentity;
                selectVC.selectedProjectUri=self.timesheetObject.projectIdentity;
                selectVC.client=self.timesheetObject.clientName;
                NSString *timesheetUri=@"";
                if ([delegate isKindOfClass:[TimesheetMainPageController class]])
                {
                    timesheetUri=self.timesheetURI;
                }
                else
                {
                    timesheetUri=timesheetObject.timesheetURI;
                }

                [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                [[NSNotificationCenter defaultCenter] removeObserver:selectVC name:PROJECTS_OR_TASKS_RECEIVED_NOTIFICATION object:nil];

                [[NSNotificationCenter defaultCenter] addObserver:selectVC selector:@selector(refreshViewAfterDataRecieved:)
                                                             name:PROJECTS_OR_TASKS_RECEIVED_NOTIFICATION
                                                           object:nil];
                selectVC.selectedTimesheetUri=timesheetUri;
                selectVC.isFromTaskRowSelection=TRUE;

                if (isFromAttendance)
                {
                    [[RepliconServiceManager attendanceService]fetchTasksBasedOnProjectsWithSearchText:@"" withProjectUri:selectVC.selectedProjectUri andDelegate:self];
                }

                else
                {
                    [[RepliconServiceManager timesheetService]fetchTasksBasedOnProjectsForTimesheetUri:timesheetUri withSearchText:@"" withProjectUri:selectVC.selectedProjectUri andDelegate:self];
                }


                selectVC.selectedValue=name;
                [self.navigationController pushViewController:selectVC animated:YES];


            }
        }


        else if ([fieldName isEqualToString:RPLocalizedString(Billing, @"")]||[fieldName isEqualToString:RPLocalizedString(Activity_Type, @"")])
        {

            if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
            {
                [Util showOfflineAlert];

            }
            else
            {


                SearchViewController *searchViewCtrl=[[SearchViewController alloc]init];

                searchViewCtrl.delegate=delegate;
                searchViewCtrl.isFromLockedInOut=isFromLockedInOut;
                searchViewCtrl.isFromAttendance=isFromAttendance;
                searchViewCtrl.selectedProject=timesheetObject.projectName;
                searchViewCtrl.entryDelegate=self;
                if ([delegate isKindOfClass:[TimesheetMainPageController class]])
                {
                    searchViewCtrl.selectedTimesheetUri=self.timesheetURI;
                }
                else
                {
                    searchViewCtrl.selectedTimesheetUri=timesheetObject.timesheetURI;
                }
                searchViewCtrl.selectedProjectUri=timesheetObject.projectIdentity;
                searchViewCtrl.selectedTaskUri=timesheetObject.taskIdentity;

                if ([fieldName isEqualToString:RPLocalizedString(Billing, @"")])
                {
                    searchViewCtrl.screenMode=BILLING_SCREEN;
                    searchViewCtrl.selectedItem=RPLocalizedString(ADD_BILLING, @"");
                    searchViewCtrl.searchProjectString=timesheetObject.billingName;
                    searchViewCtrl.isPreFilledSearchString=YES;


                }
                if ([fieldName isEqualToString:RPLocalizedString(Activity_Type, @"")])
                {
                    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                    //Implementation for US8849//JUHI
                    NSMutableArray *activityDetail=[timesheetModel getActivityDetailsFromDBForActivityUri:timesheetObject.activityIdentity];

                    if ([activityDetail count]>0)
                    {
                        searchViewCtrl.selectedActivityName=[[activityDetail objectAtIndex:0] objectForKey:@"activity_Name"];

                    }
                    else
                        searchViewCtrl.selectedActivityName=timesheetObject.activityName;


                    searchViewCtrl.screenMode=ACTIVITY_SCREEN;
                    searchViewCtrl.selectedItem=RPLocalizedString(ADD_ACTIVITY, @"");
                    searchViewCtrl.searchProjectString=timesheetObject.activityName;
                    searchViewCtrl.isPreFilledSearchString=YES;
                }
                [self.navigationController pushViewController:searchViewCtrl animated:YES];

            }


        }
    }
}
-(void)TextAndNumericActionForSelectedCell:(CurrentTimeSheetsCellView*)selectedCell{

    self.lastUsedTextField=[selectedCell fieldValue];
    [lastUsedTextField becomeFirstResponder];
}
-(void)resetTableSize:(BOOL)isResetTable
{
    if (isResetTable)
    {
        //Implementation for US9371//JUHI
        CGRect frame= CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height);

        if (self.screenViewMode ==ADD_PROJECT_ENTRY)
        {
           frame.size.height=frame.size.height-ADD_Picker_Height;
        }
        else
        {
            frame.size.height=frame.size.height-EDIT_Picker_Height;
        }
        CurrentTimeSheetsCellView * theCell = (CurrentTimeSheetsCellView *)[timeEntryTableView cellForRowAtIndexPath:selectedIndexPath];
        if ([[theCell detailObj]isKindOfClass:[EntryCellDetails class]])
        {
            NSString *fieldType = [[theCell detailObj] fieldType];
            if ([fieldType isEqualToString:UDFType_DATE])
            {
               frame.size.height=self.view.frame.size.height-ADD_Picker_Height;
            }
        }


        CGPoint tableViewCenter = [timeEntryTableView contentOffset];
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        float offset=0.0;
        offset=screenRect.size.height-spaceForOffSet;
        tableViewCenter.y += timeEntryTableView.frame.size.height/2;
        [timeEntryTableView setContentOffset:CGPointMake(0,theCell.center.y-offset) animated:NO];
        [self.timeEntryTableView setFrame:frame];


    }
    else
    {
        CGRect screenRect =[[UIScreen mainScreen] bounds];
        float aspectRatio=(screenRect.size.height/screenRect.size.width);
        //Implentation for US8956//JUHI
        float y=0.0;
        float height=screenRect.size.height-([UIApplication sharedApplication].statusBarFrame.size.height+self.navigationController.navigationBar.height+self.tabBarController.tabBar.height);
//        if (aspectRatio<1.7 && self.screenViewMode==ADD_PROJECT_ENTRY)
//        {
//            height=height-40;
//        }
        if ((isEditBreak ||(_hasTimesheetTimeoffAccess && availableTimeOffTypeCount>0)))
        {
            y=50;
            if (self.segmentedCtrl.selectedSegmentIndex==Break_Tag||self.segmentedCtrl.selectedSegmentIndex==Timeoff_Tag||((!isProjectAccess&&!isActivityAccess)&& self.segmentedCtrl.selectedSegmentIndex==TimeEntry_Tag))
            {
                if ((isEditBreak &&!isProjectAccess && !isActivityAccess &&!_hasTimesheetTimeoffAccess)||((!isProjectAccess && !isActivityAccess && !isEditBreak)&& _hasTimesheetTimeoffAccess)) {
                    y=44;
                }
                else{
                    y=100;
                }
            }
            else
            {
                y=44;
                if (aspectRatio<1.7 && self.screenViewMode==ADD_PROJECT_ENTRY)
                {
                    height=height-40;
                }

            }
        }//Implementation as per US9109//JUHI
        else if (self.screenMode==EDIT_BREAK_ENTRY||self.screenMode==EDIT_Timeoff_ENTRY|| ((!isProjectAccess||!isActivityAccess|| !_hasTimesheetTimeoffAccess)&& isEditBreak)|| ((!isProjectAccess||!isActivityAccess ||!isEditBreak)&& _hasTimesheetTimeoffAccess))
        {
            y=44;
        }
        [self.timeEntryTableView setFrame:CGRectMake(0,y,self.view.width, height-y)];
        [timeEntryTableView setContentOffset:CGPointMake(0,0) animated:NO];

    }

}
-(void)doneClicked{
    self.datePicker.hidden=YES;
    self.toolbar.hidden=YES;
    [self resetTableSize:NO];
    [timeEntryTableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
}
- (void)updateFieldWithPickerChange:(id)sender{

    CurrentTimeSheetsCellView *selectedCell = (CurrentTimeSheetsCellView *)[timeEntryTableView cellForRowAtIndexPath:selectedIndexPath];

    if (selectedCell==nil || [selectedCell isKindOfClass:[NSNull class]])
    {
        selectedCell = (CurrentTimeSheetsCellView *)[self tableView:timeEntryTableView cellForRowAtIndexPath:selectedIndexPath];

    }



    EntryCellDetails *detailsObj = (EntryCellDetails *)[selectedCell detailObj];


    NSString *selectedDateString=nil;
    if ([sender isKindOfClass:[NSString class]])
    {
        selectedDateString=sender;
    }
    else
        selectedDateString=[Util convertDateToString:[sender date]];
    //Implementation forMobi-181//JUHI
    if (![selectedDateString isEqualToString:previousDateUdfValue]&& (self.screenViewMode==EDIT_PROJECT_ENTRY || (!isProjectAccess && !isActivityAccess && isRowUdf)))
    {
        self.isEntryDetailsChanged=YES;
        [[self navigationItem].rightBarButtonItem setEnabled:TRUE];
    }

    //Implementation for US8771 HandleDateUDFEmptyValue//JUHI
    if ([sender isKindOfClass:[NSString class]])
    {
        if ([selectedDateString isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
        {
            [detailsObj setFieldValue:selectedDateString];

        }
        else{
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

            NSLocale *locale=[NSLocale currentLocale];
            [dateFormatter setLocale:locale];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [dateFormatter setDateFormat:@"MMMM d, yyyy"];
            [detailsObj setFieldValue:[dateFormatter dateFromString:selectedDateString]];

        }
    }
    else{

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

        NSLocale *locale=[NSLocale currentLocale];
        [dateFormatter setLocale:locale];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter setDateFormat:@"MMM d, yyyy"];
        [detailsObj setFieldValue: [dateFormatter stringFromDate:[dateFormatter dateFromString:selectedDateString]]];

    }

    if (isProjectAccess)
    {
        [self.timeEntryArray replaceObjectAtIndex:selectedIndexPath.row+1 withObject:detailsObj];
    }
    else
        [self.timeEntryArray replaceObjectAtIndex:selectedIndexPath.row withObject:detailsObj];


    [self.timeEntryTableView beginUpdates];
    [self.timeEntryTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:selectedIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    [self.timeEntryTableView endUpdates];



}
-(void)updateUDFNumber:(NSString *)UdfNumberEntered forIndex:(NSInteger)index{
    CurrentTimeSheetsCellView *cell = (CurrentTimeSheetsCellView *)[self.timeEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];

    int decimals = 2.0;
    if ([[cell detailObj]isKindOfClass:[EntryCellDetails class]])
    {
        EntryCellDetails *dtlsObject = (EntryCellDetails *)[cell detailObj];
        decimals = [dtlsObject decimalPoints];
        if (![UdfNumberEntered isEqualToString:dtlsObject.fieldValue]&& (self.screenViewMode==EDIT_PROJECT_ENTRY || (!isProjectAccess && !isActivityAccess && isRowUdf)))
        {
            self.isEntryDetailsChanged=YES;
            [[self navigationItem].rightBarButtonItem setEnabled:TRUE];
        }
    }
    else if ([[cell detailObj]isKindOfClass:[OEFObject class]])
    {
        OEFObject *oefObject = (OEFObject *)[cell detailObj];

        if (![UdfNumberEntered isEqualToString:oefObject.oefNumericValue]&& (self.screenViewMode==EDIT_PROJECT_ENTRY || (!isProjectAccess && !isActivityAccess && isRowUdf)))
        {
            self.isEntryDetailsChanged=YES;
            [[self navigationItem].rightBarButtonItem setEnabled:TRUE];
        }
    }




    if ([UdfNumberEntered isEqualToString:ADD_STRING])
    {
        [cell.fieldValue setText: UdfNumberEntered];
    }
    else{

        NSString *tempValue =	[Util getRoundedValueFromDecimalPlaces:[UdfNumberEntered newDoubleValue] withDecimalPlaces:decimals];
        tempValue = [Util removeCommasFromNsnumberFormaters:tempValue];
        if (tempValue == nil)
        {
            tempValue = [cell.fieldValue text];

        }else {
            [cell.fieldValue setText: tempValue];
        }
        if (tempValue!=nil) {
            //do nothing here
        }
    }

    if ([[cell detailObj]isKindOfClass:[EntryCellDetails class]])
    {
        EntryCellDetails *dtlsObject = (EntryCellDetails *)[cell detailObj];
        [dtlsObject setFieldValue:[cell.fieldValue text]];

        if (isProjectAccess)
        {
            [self.timeEntryArray replaceObjectAtIndex:index+1 withObject:dtlsObject];
        }
        else
            [self.timeEntryArray replaceObjectAtIndex:index withObject:dtlsObject];
    }
    else if ([[cell detailObj]isKindOfClass:[OEFObject class]])
    {
        OEFObject *oefObject = (OEFObject *)[cell detailObj];
        [oefObject setOefNumericValue:[cell.fieldValue text]];
    }




}

-(void)updateFieldWithClient:(NSString*)client clientUri:(NSString*)clientUri project:(NSString *)projectname projectUri:(NSString *)projectUri task:(NSString*)taskName andTaskUri:(NSString*)taskUri taskPermission:(BOOL)hasTaskPermission timeAllowedPermission:(BOOL)hasTimeAllowedPermission
{

    NSString *prevclientUri=[self.timesheetObject clientIdentity];
    NSString *prevprojectUri=[self.timesheetObject projectIdentity];
    NSString *prevtaskUri=[self.timesheetObject taskIdentity];


    if (![clientUri isEqualToString:prevclientUri]||
        ![projectUri isEqualToString:prevprojectUri]||
        ![taskUri isEqualToString:prevtaskUri]
        )
    {
        self.isEntryDetailsChanged=YES;
        [[self navigationItem].rightBarButtonItem setEnabled:TRUE];
    }

    if  (client!=nil && ![client isKindOfClass:[NSNull class]] && ![client isEqualToString:@""]) {
        //MOBI-746
        if (isProgramAccess)
        {
            [timesheetObject setProgramIdentity:clientUri];
            [timesheetObject setProgramName:client];
        }
        else
        {
            [timesheetObject setClientName:client];
            [timesheetObject setClientIdentity:clientUri];
        }

    }
    else
    {
        [timesheetObject setProgramIdentity:nil];
        [timesheetObject setProgramName:nil];
        [timesheetObject setClientName:nil];
        [timesheetObject setClientIdentity:nil];
        client=RPLocalizedString(NONE_STRING, @"");
    }


    if  (projectname!=nil && ![projectname isKindOfClass:[NSNull class]]) {
        [timesheetObject setProjectName:projectname];
        [timesheetObject setProjectIdentity:projectUri];
    }
    CurrentTimeSheetsCellView *selectedCell = (CurrentTimeSheetsCellView *)[timeEntryTableView cellForRowAtIndexPath:selectedIndexPath];
    EntryCellDetails *detailsObj = (EntryCellDetails *)[selectedCell detailObj];


    if ([[detailsObj fieldName] isEqualToString:RPLocalizedString(Project, @"")]){
        [detailsObj setFieldValue:projectname];
        UILabel *clientValueLbl=(UILabel *) [selectedCell viewWithTag:1];
        clientValueLbl.text=client;
        UILabel *projectValueLbl=(UILabel *) [selectedCell viewWithTag:3];
        projectValueLbl.text=projectname;
        UILabel *taskValueLbl=(UILabel *) [selectedCell viewWithTag:5];


        EntryCellDetails *taskdetailsObj = (EntryCellDetails *)[self.timeEntryArray objectAtIndex:1];


        if (taskName!=nil && ![taskName isKindOfClass:[NSNull class]])
        {
            [taskdetailsObj setFieldValue:taskName];
            [timesheetObject setTaskName:taskName];
            [timesheetObject setTaskIdentity:taskUri];
            [taskValueLbl setText:taskName];

        }
        else
        {
            [taskdetailsObj setFieldValue:RPLocalizedString(NONE_STRING, @"")];
            [timesheetObject setTaskName:nil];
            [timesheetObject setTaskIdentity:nil];
            [taskValueLbl setText:RPLocalizedString(NONE_STRING, @"")];
        }




        if (isBillingAccess)
        {
            NSIndexPath *billingPath=[NSIndexPath indexPathForRow:billingIndex-1 inSection:0];
            CurrentTimeSheetsCellView *billingselectedCell = (CurrentTimeSheetsCellView *)[timeEntryTableView cellForRowAtIndexPath:billingPath];
            if (projectUri!=nil && ![projectUri isKindOfClass:[NSNull class]] && ![projectUri isEqualToString:NULL_STRING])
            {
                [billingselectedCell setUserInteractionEnabled:YES];
                [[billingselectedCell rightLb]setTextColor:RepliconStandardBlackColor];
            }
            else
            {
                [billingselectedCell setUserInteractionEnabled:NO];
                [[billingselectedCell rightLb]setTextColor:RepliconStandardGrayColor];
            }//IMPLEMENTED FOR US8388_TimesheetsDefaultingTheBillingRate
            if (self.isEntryDetailsChanged)
            {
                EntryCellDetails *billingDetailsObj=(EntryCellDetails *)[timeEntryArray objectAtIndex:billingPath.row+1];
                [timesheetObject setBillingName:nil];
                [timesheetObject setBillingIdentity:nil];
                [billingDetailsObj setFieldValue:RPLocalizedString(NOT_BILLABLE, NOT_BILLABLE)];
                [[billingselectedCell rightLb]setText:[billingDetailsObj fieldValue]];

            }
        }

    }

    self.isTimeAllowedPermission=hasTimeAllowedPermission;
    NSIndexPath *tmpIndexpath=[NSIndexPath indexPathForRow:0 inSection:0];
    [self.timeEntryTableView beginUpdates];
    [self.timeEntryTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:tmpIndexpath,nil] withRowAnimation:UITableViewRowAnimationFade];

    [self.timeEntryTableView endUpdates];




}
-(void)updateFieldWithFieldName:(NSString*)fieldName andFieldURI:(NSString*)fieldUri{
    if (self.screenViewMode==ADD_PROJECT_ENTRY)
    {
        self.isEntryDetailsChanged=YES;
        [[self navigationItem].rightBarButtonItem setEnabled:TRUE];
    }
    EntryCellDetails *detailsObj =nil;
    if (isProjectAccess)
    {
        detailsObj = (EntryCellDetails *)[timeEntryArray objectAtIndex:selectedIndexPath.row+1];
    }
    else
    {
        detailsObj = (EntryCellDetails *)[timeEntryArray objectAtIndex:selectedIndexPath.row];
    }
    NSString *prevactivityIdentity=[self.timesheetObject activityIdentity];
    NSString *prevbillingIdentity=[self.timesheetObject billingIdentity];
    NSString *tmpfieldUri=fieldUri;

    if (tmpfieldUri==nil || [tmpfieldUri isEqualToString:@"null"]||[tmpfieldUri isKindOfClass:[NSNull class]])
    {
        tmpfieldUri=nil;

    }
    else if ([tmpfieldUri isEqualToString:NULL_STRING])
    {
        tmpfieldUri=@"null";
    }

    if (fieldName!=nil && ![fieldName isKindOfClass:[NSNull class]])
    {
        [detailsObj setFieldValue:fieldName];
        // [selectedCell.rightLb setText:fieldName];
    }
    else
    {
        [detailsObj setFieldValue:RPLocalizedString(SELECT_STRING, @"")];
        // [selectedCell.rightLb setText:RPLocalizedString(SELECT_STRING, @"")];
    }
    if ([[detailsObj fieldName] isEqualToString:RPLocalizedString(Billing, @"")] && (fieldName!=nil && ![fieldName isKindOfClass:[NSNull class]]) )
    {
        if (![tmpfieldUri isEqualToString:prevbillingIdentity])
        {
            self.isEntryDetailsChanged=YES;
            [[self navigationItem].rightBarButtonItem setEnabled:TRUE];
        }
        if (![fieldName isEqualToString:RPLocalizedString(NOT_BILLABLE, NOT_BILLABLE)])
        {
            [timesheetObject setBillingName:fieldName];
            [timesheetObject setBillingIdentity:fieldUri];
        }
        else
        {
            [timesheetObject setBillingName:nil];
            [timesheetObject setBillingIdentity:nil];
        }

    }
    if ([[detailsObj fieldName] isEqualToString:RPLocalizedString(Activity_Type, @"")] && (fieldName!=nil && ![fieldName isKindOfClass:[NSNull class]]) )
    {
        if (prevactivityIdentity==nil)
        {
            prevactivityIdentity=@"null";
        }
        if (![tmpfieldUri isEqualToString:prevactivityIdentity])
        {
            self.isEntryDetailsChanged=YES;
            [[self navigationItem].rightBarButtonItem setEnabled:TRUE];
        }
        if (![fieldName isEqualToString:RPLocalizedString(NONE_STRING, NONE_STRING)])
        {
            [timesheetObject setActivityName:fieldName];
            [timesheetObject setActivityIdentity:fieldUri];
        }
        else
        {
            [timesheetObject setActivityName:nil];
            [timesheetObject setActivityIdentity:nil];
        }


    }


    [self.timeEntryTableView beginUpdates];
    [self.timeEntryTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:selectedIndexPath, nil] withRowAnimation:UITableViewRowAnimationFade];
    [self.timeEntryTableView endUpdates];
}


-(void)receivedDataForAdhocSave
{

    if (self.screenViewMode==EDIT_PROJECT_ENTRY||self.screenViewMode==ADD_PROJECT_ENTRY)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_SUMMARY_RECIEVED_NOTIFICATION object:nil];
        [self navigationItem].leftBarButtonItem=nil ;
        if([delegate isKindOfClass:[TimesheetMainPageController class]])
        {
            [delegate navigationTitle];
            [delegate setHasUserChangedAnyValue:YES];
            [delegate reloadViewWithRefreshedDataAfterSave];
        }

        if (self.screenViewMode==EDIT_PROJECT_ENTRY)
        {
            if([delegate isKindOfClass:[TimesheetMainPageController class]])
            {
                TimesheetMainPageController *vc = (TimesheetMainPageController*)delegate;
                [self.navigationController popToViewController:vc animated:YES];
            }
            else
            {
                [self.navigationController popViewControllerAnimated:YES ];
            }
        }
        else
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }


    }
    else
    {
        [self navigationItem].leftBarButtonItem=nil ;
        [self.navigationController popViewControllerAnimated:TRUE];

    }

    [datePicker removeFromSuperview];
    datePicker=nil;
}

-(NSMutableArray *)getArrayOfTimeEntryObjectsFromAllTheEntries
{
    NSMutableArray *arrayOfTimeEntriesObjectsForSave=[NSMutableArray array];




    for (int i=0; i<[self.timesheetDataArray count]; i++)
    {
        NSMutableArray *tsEntryObjectsArray=[self.timesheetDataArray objectAtIndex:i];
        for (int k=0; k<[tsEntryObjectsArray count]; k++)
        {
            [arrayOfTimeEntriesObjectsForSave addObject:[tsEntryObjectsArray objectAtIndex:k]];
        }
    }
    return arrayOfTimeEntriesObjectsForSave;





}
//Implentation for US8956//JUHI
-(void)createBreakEntry{
    if (selectedIndexPath!=nil)
    {
        CurrentTimeSheetsCellView *previousSelectedCell = (CurrentTimeSheetsCellView *)[timeEntryTableView cellForRowAtIndexPath:selectedIndexPath];
        previousSelectedCell.accessoryType=UITableViewCellAccessoryNone;
    }
    [breakEntryArray removeAllObjects];


    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"SearchString"];
    [defaults synchronize];
    [defaults setObject:@"" forKey:@"SearchString"];
    [defaults synchronize];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:BREAK_RECEIVED_NOTIFICATION object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewAfterDataRecieved:)
                                                 name:BREAK_RECEIVED_NOTIFICATION
                                               object:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
    if (isFromAttendance)
    {
        [[RepliconServiceManager attendanceService]fetchBreakWithSearchText:@"" andDelegate:self];
    }
    else
    {
        [[RepliconServiceManager timesheetService]fetchBreakForTimesheetUri:self.timesheetURI withSearchText:@"" andDelegate:self];
    }
    if (self.screenMode==EDIT_BREAK_ENTRY)
    {
        [self.timeEntryTableView reloadData];
    }

}
//Implentation for US9109//JUHI
-(void)createTimeoff{
    if (selectedIndexPath!=nil)
    {
        CurrentTimeSheetsCellView *previousSelectedCell = (CurrentTimeSheetsCellView *)[timeEntryTableView cellForRowAtIndexPath:selectedIndexPath];
        previousSelectedCell.accessoryType=UITableViewCellAccessoryNone;
    }
    [adHocOptionList removeAllObjects];


    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"SearchString"];
    [defaults synchronize];
    [defaults setObject:@"" forKey:@"SearchString"];
    [defaults synchronize];

    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_TYPES_RECIEVED_NOTIFICATION object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createAdHocOptionList)
                                                 name:TIMEOFF_TYPES_RECIEVED_NOTIFICATION
                                               object:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];


    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"NextAdHocDownloadPageNo"];
    [[NSUserDefaults standardUserDefaults] synchronize];


    SQLiteDB *myDB = [SQLiteDB getInstance];
    [myDB deleteFromTable:@"TimeoffTypes" inDatabase:@""];

    [[RepliconServiceManager timesheetService]fetchEnabledTimeoffTypesDataForTimesheetForTimesheetUri:self.timesheetURI withSearchText:@"" andDelegate:self];
    if (self.screenMode==EDIT_Timeoff_ENTRY) {
        [self.timeEntryTableView reloadData];
    }

}
-(void)createAdHocOptionList{

    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_TYPES_RECIEVED_NOTIFICATION object:nil];
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;


    [self setupTimeoffData];
    [self checkToShowMoreButton];



}
- (void)setupTimeoffData
{
    [adHocOptionList removeAllObjects];


    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
    self.adHocOptionList=[timesheetModel getAllTimeOffTypesFromDB];


    [self.timeEntryTableView reloadData];



}
- (void)refreshViewAfterDataRecieved:(NSNotification *)notificationObject
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BREAK_RECEIVED_NOTIFICATION object:nil];

    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    [self.timeEntryTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self setupBreakData];
    [self checkToShowMoreButton];

    //[self.mainTableView setBottomContentInsetValue:0.0];
}
-(void)setupBreakData
{
    [breakEntryArray removeAllObjects];

    breakEntryArray=[[NSMutableArray alloc]init];
    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
    self.breakEntryArray=[timesheetModel getAllBreakDetailsFromDB];

    [self.timeEntryTableView reloadData];

}

-(void)setupBreakDataWithText:(NSString *)searchText
{
    [breakEntryArray removeAllObjects];
    
    breakEntryArray=[[NSMutableArray alloc]init];
    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
    self.breakEntryArray=[timesheetModel getAllBreakDetailsFromDBWithSearchText:searchText];
    
    [self.timeEntryTableView reloadData];
    
}


-(void)createTableHeader{
    self.searchIconImageView.hidden=YES;
    self.searchBar.hidden=YES;
    self.searchBar=nil;
    self.noPrjectActivityMsgLabel.hidden=YES;
    self.noPrjectActivityMsgLabel=nil;
    self.addRowButton.hidden=YES;
    self.addRowButton=nil;
    float y=0.0;
    
    float height=SCREEN_HEIGHT-([UIApplication sharedApplication].statusBarFrame.size.height+self.navigationController.navigationBar.height+self.tabBarController.tabBar.height);

    //Implementation as per US9109//JUHI
    if ((isEditBreak ||(_hasTimesheetTimeoffAccess && availableTimeOffTypeCount>0))&&self.screenMode!=EDIT_BREAK_ENTRY && self.screenMode!=EDIT_Timeoff_ENTRY)
    {
        y=50;
        if (self.segmentedCtrl.selectedSegmentIndex==Break_Tag||self.segmentedCtrl.selectedSegmentIndex==Timeoff_Tag)
        {//Implementation forMobi-181//JUHI


            if (![self.navigationType isKindOfClass:[AttendanceNavigationController class]])
            {
                if (!self.isExtendedInOutTimesheet && self.isMultiDayInOutTimesheetUser)
                {
                    y=44;
                }
                else
                {
                    y=100;
                }
            }
            else
            {
                y=100;
            }
        }
        else{
            y=44;
        }

    }//Implementation as per US9109//JUHI
    else if (self.screenMode==EDIT_BREAK_ENTRY ||self.screenMode==EDIT_Timeoff_ENTRY)//Implementation forMobi-181//JUHI
    {
        y=44;
    }
    timeEntryTableView.frame=CGRectMake(0,y ,self.view.frame.size.width, height-y);
    //Implementation as per US9109//JUHI
    if (self.segmentedCtrl.selectedSegmentIndex==Break_Tag|| self.screenMode==EDIT_BREAK_ENTRY || self.segmentedCtrl.selectedSegmentIndex==Timeoff_Tag ||self.screenMode==EDIT_Timeoff_ENTRY)//Implementation forMobi-181//JUHI
    {

        [self.timeEntryTableView setTableHeaderView:nil];
        float yorigin=55;
        //Implementation forMobi-181//JUHI
        if (self.screenMode==EDIT_BREAK_ENTRY||self.screenMode==EDIT_Timeoff_ENTRY)//Implementation as per US9109//JUHI
        {
            yorigin=0;
        }
        if (searchBar)
        {
            searchBar=nil;
        }

        if (![self.navigationType isKindOfClass:[AttendanceNavigationController class]])
        {
            if (!self.isExtendedInOutTimesheet && self.isMultiDayInOutTimesheetUser)
            {
                yorigin=0;
            }

        }




        UITextField *tempsearchBar=[[UITextField alloc]initWithFrame:CGRectMake(0, yorigin, self.view.frame.size.width, 44)];
        self.searchBar=tempsearchBar;
        self.searchBar.clearButtonMode=YES;

        [self.view addSubview:self.searchBar];

        float xPadding=10.0;
        float paddingFromSearchIconToPlaceholder=10.0;
        UIImage *searchIconImage=[Util thumbnailImage:SEARCH_ICON_IMAGE];
        UIImageView *tempsearchIconImageView=[[UIImageView alloc]initWithFrame:CGRectMake(xPadding,yorigin+14, searchIconImage.size.width, searchIconImage.size.height)];
        self.searchIconImageView=tempsearchIconImageView;
        [searchIconImageView setImage:searchIconImage];
        [searchIconImageView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:searchIconImageView];


        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, xPadding+searchIconImage.size.width+paddingFromSearchIconToPlaceholder, 20)];
        searchBar.leftView = paddingView;
        searchBar.leftViewMode = UITextFieldViewModeAlways;
        //Implementation as per US9109//JUHI
        if (isEditBreak && (_hasTimesheetTimeoffAccess && availableTimeOffTypeCount>0) && (isProjectAccess||isActivityAccess||isRowUdf))//Implementation forMobi-181//JUHI
        {
            if (self.segmentedCtrl.selectedSegmentIndex==Break_Tag|| self.screenMode==EDIT_BREAK_ENTRY)
            {
                searchBar.placeholder=RPLocalizedString(SEARCHBAR_BREAK_PLACEHOLDER,@"");
            }
            else if (self.segmentedCtrl.selectedSegmentIndex==Timeoff_Tag||self.segmentedCtrl.selectedSegmentIndex==EDIT_Timeoff_ENTRY)
                searchBar.placeholder=RPLocalizedString(SEARCHBAR_TimeOff_PLACEHOLDER,@"");
        }
        else if (!isEditBreak && (_hasTimesheetTimeoffAccess && availableTimeOffTypeCount>0)){
            if (self.segmentedCtrl.selectedSegmentIndex==Break_Tag||self.segmentedCtrl.selectedSegmentIndex==EDIT_Timeoff_ENTRY)
                searchBar.placeholder=RPLocalizedString(SEARCHBAR_TimeOff_PLACEHOLDER,@"");

        }
        else{
            if (isEditBreak ||self.screenMode==EDIT_BREAK_ENTRY)
            {
                searchBar.placeholder=RPLocalizedString(SEARCHBAR_BREAK_PLACEHOLDER,@"");
            }
            else
                searchBar.placeholder=RPLocalizedString(SEARCHBAR_TimeOff_PLACEHOLDER,@"");
        }
        [searchBar setBackgroundColor:[UIColor whiteColor]];
        //Implementation as per US9109//JUHI
        if (self.screenMode==EDIT_BREAK_ENTRY||self.screenMode==EDIT_Timeoff_ENTRY)
        {
            UIImage *totalLineImage=[Util thumbnailImage:Cell_HairLine_Image];

            UIImageView *lineImageviewR=[[UIImageView alloc]initWithImage:totalLineImage];
            lineImageviewR.frame=CGRectMake(0.0,43,
                                            self.view.width,
                                            totalLineImage.size.height);


            [lineImageviewR setBackgroundColor:[UIColor clearColor]];
            [lineImageviewR setUserInteractionEnabled:NO];
            [self.view  addSubview:lineImageviewR];


        }

        searchBar.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        searchBar.contentHorizontalAlignment = UIControlContentVerticalAlignmentCenter;
        [searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
        [searchBar setDelegate:self];
        [searchBar setReturnKeyType:UIReturnKeyDone];
        [searchBar setEnablesReturnKeyAutomatically:NO];
        [searchBar setClearsOnBeginEditing:YES];


    }
    else if ((self.segmentedCtrl.selectedSegmentIndex==TimeEntry_Tag)||(!isEditBreak && self.screenMode!=EDIT_BREAK_ENTRY))
    {
        self.searchIconImageView.hidden=YES;
        self.searchBar.hidden=YES;
        self.searchBar=nil;
        //Implementation forMobi-181//JUHI
        if (isProjectAccess || isActivityAccess ||isRowUdf)
        {
            UIView *statusView= [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];


            UILabel *statusLb= [[UILabel alloc]initWithFrame:CGRectMake(12, 3, statusView.frame.size.width, 20)];
            if (isProjectAccess)
            {
                //Implementation for US8902//JUHI
                statusLb.text=[NSString stringWithFormat:@"%@ ",RPLocalizedString(PROJECT_SELECTION, @"") ];
            }
            else if (isActivityAccess&&!isProjectAccess) {//Implementation for US8902//JUHI
                statusLb.text=[NSString stringWithFormat:@"%@ ",RPLocalizedString(ACTIVITY_SELECTION, @"")];
            }
            statusView.backgroundColor=RepliconStandardBlackColor;
            statusLb.textColor=RepliconStandardWhiteColor;
            statusLb.textAlignment=NSTextAlignmentLeft;
            [statusLb setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];
            [statusLb setBackgroundColor:[UIColor clearColor]];
            if (isProjectAccess || isActivityAccess) {
                [statusView addSubview:statusLb];
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 29, self.view.frame.size.width, 1)];
                lineView.backgroundColor = [UIColor grayColor];
                [statusView addSubview:lineView];
            }
        }
        else
        {
            UILabel *msgLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 120, self.view.frame.size.width, HeightOFMsgLabel)];
            msgLabel.text=RPLocalizedString(NO_PROJECTS_NO_ACTIVITY_ENTRY_PLACEHOLDER, NO_PROJECTS_NO_ACTIVITY_ENTRY_PLACEHOLDER);
            msgLabel.backgroundColor=[UIColor clearColor];
            msgLabel.numberOfLines=2;
            msgLabel.textAlignment=NSTextAlignmentCenter;
            msgLabel.font=[UIFont fontWithName:RepliconFontFamily size:16];
            msgLabel.hidden=NO;;
            self.noPrjectActivityMsgLabel=msgLabel;
            [self.view addSubview:noPrjectActivityMsgLabel];

            if (![self.navigationType isKindOfClass:[AttendanceNavigationController class]])
            {
                UIImage *saveBtnImg =[Util thumbnailImage:SubmitTimesheetButtonImage] ;
                UIImage *savePressedBtnImg =[Util thumbnailImage:SubmitTimesheetPressedButtonImage] ;
                float x = (SCREEN_WIDTH - saveBtnImg.size.width)/2.0;
                addRowButton =[UIButton buttonWithType:UIButtonTypeCustom];
                [addRowButton setFrame:CGRectMake(x,230.0, saveBtnImg.size.width, saveBtnImg.size.height)];
                [addRowButton setBackgroundImage:saveBtnImg forState:UIControlStateNormal];
                [addRowButton setBackgroundImage:savePressedBtnImg forState:UIControlStateHighlighted];
                [addRowButton setTitle:RPLocalizedString(SAVE_BTN_NO_PROJECTS_NO_ACTIVITY, @"")  forState:UIControlStateNormal];
                [addRowButton addTarget:self action:@selector(saveAction:) forControlEvents:UIControlEventTouchUpInside];
                [addRowButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                addRowButton.hidden=NO;
                //        saveButton.titleEdgeInsets = UIEdgeInsetsMake(-2.0, 0, 0, 0);
                addRowButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                if (self.screenViewMode !=EDIT_PROJECT_ENTRY && self.screenViewMode !=VIEW_PROJECT_ENTRY) {
                    [self.view addSubview:addRowButton];
                }

            }




        }
    }


    [self configureTableForPullToRefresh];
}

-(void)configureTableForPullToRefresh
{//Implementation as per US9109//JUHI
    if (self.segmentedCtrl.selectedSegmentIndex==Break_Tag || self.screenMode==EDIT_BREAK_ENTRY || self.segmentedCtrl.selectedSegmentIndex==Timeoff_Tag||self.screenMode==EDIT_Timeoff_ENTRY || (!isProjectAccess && !isActivityAccess && !isRowUdf))//Implementation forMobi-181//JUHI
    {
        TimeEntryViewController *weakSelf = self;


        //setup pull to refresh widget
        [self.timeEntryTableView addPullToRefreshWithActionHandler:^{

            int64_t delayInSeconds = 0.0;
            [weakSelf.timeEntryTableView.pullToRefreshView startAnimating];
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                           {

                               [weakSelf refreshAction];


                           });
        }];

        // setup infinite scrolling
        [self.timeEntryTableView addInfiniteScrollingWithActionHandler:^{


            [weakSelf.timeEntryTableView setBottomContentInsetValue: 0.0];

            int64_t delayInSeconds = 0.0;
            if (weakSelf.segmentedCtrl.selectedSegmentIndex==Break_Tag)
            {
                [weakSelf.timeEntryTableView.infiniteScrollingView startAnimating];
            }

            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                           {

                               [weakSelf moreAction];



                           });
        }];

    }
    else{
        self.timeEntryTableView.showsPullToRefresh=FALSE;
        self.timeEntryTableView.showsInfiniteScrolling=FALSE;
    }
}
-(void)refreshAction
{
    if(![NetworkMonitor isNetworkAvailableForListener: self])
    {
        [self.view setUserInteractionEnabled:YES];
        TimeEntryViewController *weakSelf = self;
        [weakSelf.timeEntryTableView.pullToRefreshView stopAnimating];
        [Util showOfflineAlert];
        return;
    }
    
    if ([delegate isKindOfClass:[AttendanceViewController class]]) {
        if (isEditBreak)
        {
            [[self navigationItem].rightBarButtonItem setEnabled:FALSE];
            self.selectedBreakString=nil;
        }
    }
    
    selectedIndexPath=nil;
    //Implemented as per US9109//JUHI
    if ( (isEditBreak && self.segmentedCtrl.selectedSegmentIndex==Break_Tag)||(isEditBreak && self.segmentedCtrl.selectedSegmentIndex==TimeEntry_Tag && !isProjectAccess && !isActivityAccess && !isRowUdf)|| self.screenMode==EDIT_BREAK_ENTRY)//Implementation forMobi-181//JUHI
    {

        [[NSNotificationCenter defaultCenter] removeObserver:self name:BREAK_RECEIVED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewAfterPullToRefreshAction:) name:BREAK_RECEIVED_NOTIFICATION object:nil];
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;
        
        if (isFromAttendance)
        {
            [[RepliconServiceManager attendanceService]fetchBreakWithSearchText:searchBar.text andDelegate:self];
        }
        else
        {
            [[RepliconServiceManager timesheetService]fetchBreakForTimesheetUri:self.timesheetURI withSearchText:searchBar.text andDelegate:self];
        }


    }
    else{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_TYPES_RECIEVED_NOTIFICATION object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewAfterPullToRefreshAction:)
                                                     name:TIMEOFF_TYPES_RECIEVED_NOTIFICATION
                                                   object:nil];
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"NextAdHocDownloadPageNo"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        SQLiteDB *myDB = [SQLiteDB getInstance];
        [myDB deleteFromTable:@"TimeoffTypes" inDatabase:@""];

        [[RepliconServiceManager timesheetService]fetchEnabledTimeoffTypesDataForTimesheetForTimesheetUri:self.timesheetURI withSearchText:searchBar.text  andDelegate:self];
    }


}
-(void)refreshViewAfterPullToRefreshAction:(NSNotification *)notificationObject
{
    [self.view setUserInteractionEnabled:YES];


    if ([self.searchTimer isValid])
    {
        [self.searchTimer invalidate];

    }

    TimeEntryViewController *weakSelf = self;
    [weakSelf.timeEntryTableView.pullToRefreshView stopAnimating];
    if (self.segmentedCtrl.selectedSegmentIndex==Break_Tag||self.segmentedCtrl.selectedSegmentIndex==Timeoff_Tag||(isEditBreak && self.segmentedCtrl.selectedSegmentIndex==TimeEntry_Tag && !isProjectAccess && !isActivityAccess && !isRowUdf))//Implementation forMobi-181//JUHI
    {
        self.timeEntryTableView.showsInfiniteScrolling=TRUE;
    }
    else
        self.timeEntryTableView.showsInfiniteScrolling=FALSE;

    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    NSDictionary *theData = [notificationObject userInfo];
    NSNumber *n = [theData objectForKey:@"isErrorOccured"];
    BOOL isErrorOccured = [n boolValue];
    if (isErrorOccured)
    {

    }
    else
    {  //Implemented as per US9109//JUHI
        if ( (isEditBreak && self.segmentedCtrl.selectedSegmentIndex==Break_Tag)||(isEditBreak && self.segmentedCtrl.selectedSegmentIndex==TimeEntry_Tag && !isProjectAccess && !isActivityAccess && !isRowUdf)|| self.screenMode==EDIT_BREAK_ENTRY)//Implementation forMobi-181//JUHI
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:BREAK_RECEIVED_NOTIFICATION object:nil];
            [self setupBreakData];

        }
        else{
            [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_TYPES_RECIEVED_NOTIFICATION object:nil];
            [self setupTimeoffData];

        }
        [self checkToShowMoreButton];

    }

    [self.timeEntryTableView setBottomContentInsetValue:0.0];

}
-(void)moreAction
{
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        [self performSelector:@selector(refreshTableViewOnConnectionError) withObject:nil afterDelay:0.2];
    }

    //Implemented as per US9109//JUHI
    if ( (isEditBreak && self.segmentedCtrl.selectedSegmentIndex==Break_Tag)||(isEditBreak && self.segmentedCtrl.selectedSegmentIndex==TimeEntry_Tag && !isProjectAccess && !isActivityAccess && !isRowUdf)|| self.screenMode==EDIT_BREAK_ENTRY)//Implementation forMobi-181//JUHI
    {

        [[NSNotificationCenter defaultCenter] removeObserver:self name:BREAK_RECEIVED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewAfterMoreAction:) name:BREAK_RECEIVED_NOTIFICATION object:nil];
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;

        if (isFromAttendance)
        {
            [[RepliconServiceManager attendanceService]fetchNextBreakWithSearchText:searchBar.text andDelegate:self];
        }
        else
        {
            [[RepliconServiceManager timesheetService]fetchNextBreakForTimesheetUri:self.timesheetURI withSearchText:searchBar.text andDelegate:self];
        }
    }
    else{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_TYPES_RECIEVED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewAfterMoreAction:) name:TIMEOFF_TYPES_RECIEVED_NOTIFICATION object:nil];
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;

        [[RepliconServiceManager timesheetService]fetchEnabledTimeoffTypesDataForTimesheetForTimesheetUri:self.timesheetURI withSearchText:searchBar.text andDelegate:self];
    }



}
-(void)refreshTableViewOnConnectionError
{
    TimeEntryViewController *weakSelf = self;
    [weakSelf.timeEntryTableView.infiniteScrollingView stopAnimating];

    self.timeEntryTableView.showsInfiniteScrolling=FALSE;
    self.timeEntryTableView.showsInfiniteScrolling=TRUE;

}
-(void)refreshViewAfterMoreAction:(NSNotification *)notificationObject
{



    [self.view setUserInteractionEnabled:YES];
    TimeEntryViewController *weakSelf = self;
    [weakSelf.timeEntryTableView.infiniteScrollingView stopAnimating];

    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;

    NSDictionary *theData = [notificationObject userInfo];
    NSNumber *n = [theData objectForKey:@"isErrorOccured"];


    BOOL isErrorOccured = [n boolValue];

    if (isErrorOccured)
    {
        self.timeEntryTableView.showsInfiniteScrolling=FALSE;
    }
    else
    {

        //Implemented as per US9109//JUHI
        if ( (isEditBreak && self.segmentedCtrl.selectedSegmentIndex==Break_Tag)||(isEditBreak && self.segmentedCtrl.selectedSegmentIndex==TimeEntry_Tag && !isProjectAccess && !isActivityAccess && !isRowUdf)|| self.screenMode==EDIT_BREAK_ENTRY)//Implementation forMobi-181//JUHI
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:BREAK_RECEIVED_NOTIFICATION object:nil];
            [self setupBreakData];

        }
        else{
            [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_TYPES_RECIEVED_NOTIFICATION object:nil];
            [self setupTimeoffData];

        }
        [self checkToShowMoreButton];

    }

    // [self.timeEntryTableView setBottomContentInsetValue:0.0];
}
-(void)checkToShowMoreButton
{  //Implemented as per US9109//JUHI
    if ( (isEditBreak && self.segmentedCtrl.selectedSegmentIndex==Break_Tag)||(isEditBreak && self.segmentedCtrl.selectedSegmentIndex==TimeEntry_Tag && !isProjectAccess && !isActivityAccess && !isRowUdf)|| self.screenMode==EDIT_BREAK_ENTRY)//Implementation forMobi-181//JUHI
    {
        NSNumber *count=nil ;
        NSNumber *fetchCount=nil;


        count =	[[NSUserDefaults standardUserDefaults]objectForKey:@"breakDataDownloadCount"];
        fetchCount  =    [[AppProperties getInstance] getAppPropertyFor:@"breakDownloadCount"];

        if (([count intValue]<[fetchCount intValue]))
        {
            self.timeEntryTableView.showsInfiniteScrolling=FALSE;
        }
        else
        {
            self.timeEntryTableView.showsInfiniteScrolling=TRUE;
        }

        if ([self.breakEntryArray count]==0)
        {
            self.timeEntryTableView.showsPullToRefresh=TRUE;
            self.timeEntryTableView.showsInfiniteScrolling=FALSE;
        }
        else
        {
            self.timeEntryTableView.showsPullToRefresh=TRUE;
        }
    }
    else if(_hasTimesheetTimeoffAccess && availableTimeOffTypeCount>0){


        NSNumber *count=nil ;
        NSNumber *fetchCount=nil;

        count =	[[NSUserDefaults standardUserDefaults]objectForKey:@"adHocOptionDataDownloadCount"];
        fetchCount  =    [[AppProperties getInstance] getAppPropertyFor:@"adHocOptionDataDownloadCount"];
        if (([count intValue]<[fetchCount intValue]))
        {
            self.timeEntryTableView.showsInfiniteScrolling=FALSE;
        }
        else
        {
            self.timeEntryTableView.showsInfiniteScrolling=TRUE;
        }

        if ([self.adHocOptionList count]==0)
        {
            self.timeEntryTableView.showsPullToRefresh=TRUE;
            self.timeEntryTableView.showsInfiniteScrolling=FALSE;
        }
        else
        {
            self.timeEntryTableView.showsPullToRefresh=TRUE;
        }



    }
    else{
        self.timeEntryTableView.showsPullToRefresh=FALSE;
        self.timeEntryTableView.showsInfiniteScrolling=FALSE;
    }

}

-(NSMutableArray*)addEntryBeforeEmptyRowWithTimeEntryObject:(TimesheetEntryObject*)timesheetEntryObject objectsArray:(NSMutableArray*)objectsArray numberOfTimeOff:(int)numberOfTimeOff
{
    NSMutableArray *sortedArray = [NSMutableArray array];
    BOOL hasObject = (objectsArray != nil && ![objectsArray isKindOfClass:[NSNull class]]);
    NSInteger emptyRowIndex = 0;
    BOOL hasEmptyRow =  false;
    if (hasObject) {
        for (NSInteger index = [objectsArray count]-1; index >= 0; index--) {
            TimesheetEntryObject *timeEntryObject = objectsArray[index];
            BOOL isEmptyRow = [self isEmptyRow:timeEntryObject];
            if (isEmptyRow) {
                emptyRowIndex = index;
                hasEmptyRow = true;
            }
        }
    }
    self.rowTextFieldFocusIndex = emptyRowIndex;
    TimesheetEntryObject *firstEntryObject = objectsArray.lastObject;
    NSString *entryType = [firstEntryObject entryType];
    
    if (entryType != nil && ![entryType isKindOfClass:[NSNull class]]) {
        BOOL isFirstTimeEntryEmpty = [objectsArray count]>=2 && [[firstEntryObject entryType] isEqualToString:Time_Entry_Key];
        if (isFirstTimeEntryEmpty) {
            NSUInteger arrayCount = [objectsArray count];
            [objectsArray insertObject:timesheetEntryObject atIndex:arrayCount-1];
            sortedArray = objectsArray;
            return sortedArray;
        }
    }
    
    if (hasEmptyRow)
    {
        TimesheetEntryObject *emptyEntryObject = objectsArray[emptyRowIndex];
        [objectsArray replaceObjectAtIndex:emptyRowIndex withObject:timesheetEntryObject];
        [objectsArray addObject:emptyEntryObject];
    }
    else
        [objectsArray addObject:timesheetEntryObject];
    sortedArray = objectsArray;
    return sortedArray;
}

-(BOOL)isEmptyRow:(TimesheetEntryObject*)timesheetEntryObject
{
    NSDictionary *timeEntry = [timesheetEntryObject multiDayInOutEntry];
    NSString *inTime = timeEntry[@"in_time"];
    NSString *outTime = timeEntry[@"out_time"];
    BOOL hasInTime = (inTime != nil && ![inTime isKindOfClass:[NSNull class]] && ![inTime isEqualToString:@""]);
    BOOL hasOutTime = (outTime != nil && ![outTime isKindOfClass:[NSNull class]] && ![outTime isEqualToString:@""]);
    BOOL isTimeOffRow = ([[timesheetEntryObject entryType] isEqualToString:Time_Off_Key]);
    return (!hasInTime && !hasOutTime && !isTimeOffRow);
}

#pragma mark -
#pragma mark Segment Delegates

-(void) changeUISegmentFont:(UIView*) myView
{
    // Getting the label subview of the passed view
    if ([myView isKindOfClass:[UILabel class]])
    {
        UILabel* label = (UILabel*)myView;
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_12]];       // Set the font size you want to change to
        [label sizeToFit];
        CGRect frame=label.frame;
        frame.size.width=label.frame.size.width+100;
        label.frame=frame;

        NSString *string=label.text;
        if ([string hasPrefix:RPLocalizedString(ADD_TIME,@"")])
        {
            [label setText:[NSString stringWithFormat:@"%@",RPLocalizedString(ADD_TIME,@"")]];
        }
        else if([string hasPrefix:RPLocalizedString(ADD_BREAK,@"")])
        {
            [label setText:[NSString stringWithFormat:@"%@",RPLocalizedString(ADD_BREAK,@"")]];
        }
        else if([string hasPrefix:RPLocalizedString(TimeoffLabelText,@"")])
        {
            [label setText:[NSString stringWithFormat:@"%@",RPLocalizedString(TimeoffLabelText,@"")]];
        }
    }

    NSArray* subViewArray = [myView subviews];                  // Getting the subview array
    NSEnumerator* iterator = [subViewArray objectEnumerator];   // For enumeration
    UIView* subView;
    // Iterating through the subviews of the view passed
    while (subView = [iterator nextObject])
    {
        [self changeUISegmentFont:subView]; // Recursion

    }

}
/************************************************************************************************************
 @Function Name   : segmentChanged
 @Purpose         : To handle segment selected
 @param           : (id)sender
 @return          : nil
 *************************************************************************************************************/

-(void)segmentChanged:(id)sender
{
    UISegmentedControl *segmentCtrl=(UISegmentedControl *)sender;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEXT_RECENT_CLIENTS_OR_PROJECTS_RECEIVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BREAK_RECEIVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_TYPES_RECIEVED_NOTIFICATION object:nil];
    selectedIndexPath=nil;
    [searchBar resignFirstResponder];
    switch (segmentCtrl.selectedSegmentIndex)
    {
        case 0:

            CLS_LOG(@"-----TimeEntry segment selected-----");
            //Implementation forMobi-181//JUHI
            //            if (isProjectAccess||isActivityAccess||isRowUdf)
            //            {
            searchIconImageView.hidden=YES;
            self.searchBar.hidden=YES;
            self.segmentedCtrl.selectedSegmentIndex=TimeEntry_Tag;
            if (self.screenViewMode ==ADD_PROJECT_ENTRY)
            {//Implementation for US8902//JUHI
                [Util setToolbarLabel:self withText:RPLocalizedString(ADD_TIME_ENTRY_TITLE, @"") ];
            }
            else
            {//Implementation for US8902//JUHI
                [Util setToolbarLabel:self withText:RPLocalizedString(EDIT_TIME_ENTRY_TITLE, @"") ];
            }//Fix for defect MOBI-456//JUHI
            cellIdentiferstr=@"TimeEntryCell";
            //            }
            break;
            //Implementation forMobi-181//JUHI
        case 1:
            CLS_LOG(@"-----Break segment selected-----");
            //Implemented as per US9109//JUHI
            if (isEditBreak)//Implementation forMobi-181//JUHI
            {
                self.segmentedCtrl.selectedSegmentIndex=Break_Tag;
                if (self.screenViewMode ==ADD_PROJECT_ENTRY)
                {//Implementation for US8902//JUHI
                    [Util setToolbarLabel:self withText:RPLocalizedString(ADD_BREAK_ENTRY_TITLE, @"") ];
                }
                else
                {//Implementation for US8902//JUHI
                    [Util setToolbarLabel:self withText:RPLocalizedString(EDIT_BREAK_ENTRY_TITLE, @"") ];
                }
                cellIdentiferstr=@"BreakEntryCell";//Fix for defect MOBI-456//JUHI
                [self createBreakEntry];

            }
            else if(_hasTimesheetTimeoffAccess && availableTimeOffTypeCount>0)
            {
                self.segmentedCtrl.selectedSegmentIndex=Break_Tag;
                if (self.screenViewMode ==ADD_PROJECT_ENTRY)
                {
                    [Util setToolbarLabel:self withText:RPLocalizedString(ADD_TimeOff_ENTRY_TITLE, @"") ];
                }
                else
                {
                    [Util setToolbarLabel:self withText:RPLocalizedString(EDIT_TimeOff_ENTRY_TITLE, @"") ];
                }
                cellIdentiferstr=@"TimeoffEntryCell";//Fix for defect MOBI-456//JUHI
                [self createTimeoff];
            }

            break;
        case 2:  //Implemented as per US9109//JUHI
            CLS_LOG(@"-----Timeoff segment selected-----");

            self.segmentedCtrl.selectedSegmentIndex=Timeoff_Tag;
            if (self.screenViewMode ==ADD_PROJECT_ENTRY)
            {
                [Util setToolbarLabel:self withText:RPLocalizedString(ADD_TimeOff_ENTRY_TITLE, @"") ];
            }
            else
            {
                [Util setToolbarLabel:self withText:RPLocalizedString(EDIT_TimeOff_ENTRY_TITLE, @"") ];
            }
            cellIdentiferstr=@"TimeoffEntryCell";//Fix for defect MOBI-456//JUHI
            [self createTimeoff];
            break;

        default:
            break;
    }
    [self createTableHeader];
    [self.timeEntryTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self setTextColorsForSegmentedControl:(UISegmentedControl*)sender];
    [self changeUISegmentFont:self.segmentedCtrl];
    [self.timeEntryTableView reloadData];
}

/************************************************************************************************************
 @Function Name   : setTextColorsForSegmentedControl
 @Purpose         : To set text color changes in the segment control
 @param           : (UISegmentedControl*)segmented
 @return          : nil
 *************************************************************************************************************/

-(void)setTextColorsForSegmentedControl:(UISegmentedControl*)segmented
{

    //Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion newFloatValue];
    switch (segmented.selectedSegmentIndex) {
        case 0:
            //Implemented as per US9109//JUHI
            if (isEditBreak && (_hasTimesheetTimeoffAccess && availableTimeOffTypeCount>0) )
            {


                //Fix for ios7//JUHI
                if (version<7.0)
                {
                    [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagFirst];
                    [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagSecond];
                    [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagThird];
                    [segmented setShadowColor:[UIColor blackColor] forTag:kTagFirst];
                    [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagSecond];
                    [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagThird];


                    [segmented setTextColor:[Util colorWithHex:@"#ffffff" alpha:1] forTag:kTagFirst];
                    [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagSecond];
                    [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagThird];
                }
                else{
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#107ebe" alpha:1] forTag:kTagFirst];
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagSecond];
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagThird];

                }



            }
            else
            {
                //Fix for ios7//JUHI
                if (version<7.0)
                {
                    [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagFirst];
                    [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagSecond];
                    [segmented setShadowColor:[UIColor blackColor] forTag:kTagFirst];
                    [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagSecond];


                    [segmented setTextColor:[Util colorWithHex:@"#ffffff" alpha:1] forTag:kTagFirst];
                    [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagSecond];
                }
                else{
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#107ebe" alpha:1] forTag:kTagFirst];
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagSecond];


                }

            }


            break;
        case 1:
            //Implemented as per US9109//JUHI
            if (isEditBreak && (_hasTimesheetTimeoffAccess && availableTimeOffTypeCount>0) )
            {
                //Fix for ios7//JUHI
                if (version<7.0)
                {
                    [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagSecond];
                    [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagFirst];
                    [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagThird];
                    [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagFirst];
                    [segmented setShadowColor:[UIColor blackColor] forTag:kTagSecond];
                    [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagThird];
                    [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagFirst];
                    [segmented setTextColor:[Util colorWithHex:@"#ffffff" alpha:1] forTag:kTagSecond];
                    [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagThird];
                }
                else{
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagFirst];
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#107ebe" alpha:1] forTag:kTagSecond];
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagThird];

                }

            }
            else
            {
                //Fix for ios7//JUHI
                if (version<7.0)
                {
                    [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagSecond];
                    [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagFirst];
                    [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagFirst];
                    [segmented setShadowColor:[UIColor blackColor] forTag:kTagSecond];
                    [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagFirst];
                    [segmented setTextColor:[Util colorWithHex:@"#ffffff" alpha:1] forTag:kTagSecond];
                }
                else{
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagFirst];
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#107ebe" alpha:1] forTag:kTagSecond];

                }

            }



            break;
        case 2:
            //Fix for ios7//JUHI
            if (version<7.0)
            {
                [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagThird];
                [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagFirst];
                [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagSecond];
                [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagFirst];
                [segmented setShadowColor:[UIColor blackColor] forTag:kTagThird];
                [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagSecond];
                [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagFirst];
                [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagSecond];
                [segmented setTextColor:[Util colorWithHex:@"#ffffff" alpha:1] forTag:kTagThird];
            }
            else{
                [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagFirst];
                [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagSecond];
                [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#107ebe" alpha:1] forTag:kTagThird];

            }



            break;

        default:
            //Fix for ios7//JUHI
            if (version<7.0)
            {
                [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagFirst];
                [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagSecond];
                // [segmented setShadowColor:[UIColor blackColor] forTag:kTagFirst];
                [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagSecond];

                [segmented setTextColor:[Util colorWithHex:@"#ffffff" alpha:1] forTag:kTagFirst];
                [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagSecond];
            }
            else{
                [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#107ebe" alpha:1] forTag:kTagFirst];
                [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagSecond];

            }


            break;
    }




}
#pragma mark -
#pragma mark Search Delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.timeEntryTableView.scrollEnabled = YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.timeEntryTableView.scrollEnabled = YES;

    if ([self.searchTimer isValid])
    {
        [self.searchTimer invalidate];

    }
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:textField.text forKey:@"SearchString"];
    [defaults synchronize];

    self.searchTimer=  [NSTimer scheduledTimerWithTimeInterval:SEARCH_POLL
                                                        target:self
                                                      selector:@selector(fetchDataWithSearchText)
                                                      userInfo:nil
                                                       repeats:NO];

    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    [searchBar resignFirstResponder];
    self.timeEntryTableView.scrollEnabled = YES;
    if ([self.searchTimer isValid])
    {
        [self.searchTimer invalidate];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    textField.text=@"";
    self.timeEntryTableView.scrollEnabled = YES;

    if ([self.searchTimer isValid])
    {
        [self.searchTimer invalidate];

    }
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:textField.text forKey:@"SearchString"];
    [defaults synchronize];

    self.searchTimer=  [NSTimer scheduledTimerWithTimeInterval:SEARCH_POLL
                                                        target:self
                                                      selector:@selector(fetchDataWithSearchText)
                                                      userInfo:nil
                                                       repeats:NO];

    return YES;
}

- (void)fetchDataWithSearchText
{

    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
    }
    else
    {//Implementation as per US9109//JUHI
        if ((self.segmentedCtrl.selectedSegmentIndex==Break_Tag && isEditBreak) || self.screenMode==EDIT_BREAK_ENTRY)
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:BREAK_RECEIVED_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewAfterDataRecieved:) name:BREAK_RECEIVED_NOTIFICATION object:nil];
            UIApplication* app = [UIApplication sharedApplication];
            app.networkActivityIndicatorVisible = YES;

            if (isFromAttendance)
            {
                [[RepliconServiceManager attendanceService]fetchBreakWithSearchText:searchBar.text andDelegate:self];
            }
            else
            {
                [[RepliconServiceManager timesheetService]fetchBreakForTimesheetUri:self.timesheetURI withSearchText:searchBar.text andDelegate:self];
            }
        }

        else{
            [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_TYPES_RECIEVED_NOTIFICATION object:nil];

            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createAdHocOptionList)
                                                         name:TIMEOFF_TYPES_RECIEVED_NOTIFICATION
                                                       object:nil];
            UIApplication* app = [UIApplication sharedApplication];
            app.networkActivityIndicatorVisible = YES;

            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"NextAdHocDownloadPageNo"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            SQLiteDB *myDB = [SQLiteDB getInstance];
            [myDB deleteFromTable:@"TimeoffTypes" inDatabase:@""];

            [[RepliconServiceManager timesheetService]fetchEnabledTimeoffTypesDataForTimesheetForTimesheetUri:self.timesheetURI withSearchText:searchBar.text andDelegate:self];
        }


    }

    [self.searchTimer invalidate];
}

-(NSMutableArray *)createUdfs
{
    
    NSMutableArray *customFieldArray=[NSMutableArray array];
    if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
    {
        if (![self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
        {
            int decimalPlace=0;
            LoginModel *loginModel=[[LoginModel alloc]init];
            //Implemented as per US9109//JUHI
            NSMutableArray *udfArray=nil;
            if (timesheetObject.TimeOffIdentity!=nil && ![timesheetObject.TimeOffIdentity isKindOfClass:[NSNull class]] &&![timesheetObject.TimeOffIdentity isEqualToString:@""])
            {
                udfArray =[loginModel getEnabledOnlyUDFsforModuleName:TIMEOFF_UDF];
            }
            else
                udfArray=[loginModel getEnabledOnlyUDFsforModuleName:TIMESHEET_CELL_UDF];





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

                    if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS] ) {
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
                    if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS] ) {
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

                    if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS] ) {
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
                                if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS] ) {
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
                            if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS] ) {
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
                    if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS] ) {
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
                                if (([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[timesheetStatus isEqualToString:APPROVED_STATUS ])) {
                                    [udfDetailDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
                                }
                                else
                                    [udfDetailDict setObject:[dictInfo objectForKey: @"defaultValue" ] forKey:@"defaultValue"];


                            }

                        }
                        else
                        {
                            if (([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[timesheetStatus isEqualToString:APPROVED_STATUS ])) {
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
                    if (([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[timesheetStatus isEqualToString:APPROVED_STATUS ])) {
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
        }
    }

    
    return customFieldArray;
    
    
}

-(NSMutableDictionary *)getActiveCellsOnPresentDate
{
    if ([delegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *ctrl=(TimesheetMainPageController *)delegate;
        if (ctrl.tsEntryDataArray.count>ctrl.pageControl.currentPage)
        {
            NSDate *currentDate = nil;
            if (ctrl.tsEntryDataArray.count>0)
            {
                NSString *formattedDate=[NSString stringWithFormat:@"%@",[[ctrl.tsEntryDataArray objectAtIndex:ctrl.pageControl.currentPage] entryDate]];
                NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
                [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                myDateFormatter.dateFormat = @"EEEE, dd MMM yyyy";

                NSLocale *locale=[NSLocale currentLocale];
                [myDateFormatter setLocale:locale];
                currentDate=[myDateFormatter dateFromString:[NSString stringWithFormat:@"%@",formattedDate]];
            }



        NSMutableArray *activeCellObjectsArray=[NSMutableArray array];
        NSMutableArray *indexOfactiveCellsArray=[NSMutableArray array];
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
                        id timeoffTypeName=nil;
                        id timeoffTypeUri=nil;

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
                        NSString *timeEntryTimeOffName=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryTimeOffName]];
                        if (timeEntryTimeOffName==nil||[timeEntryTimeOffName isKindOfClass:[NSNull class]]||[timeEntryTimeOffName isEqualToString:@""]||[timeEntryTimeOffName isEqualToString:NULL_STRING]||[timeEntryTimeOffName isEqualToString:NULL_OBJECT_STRING])
                        {
                            timeoffTypeName=[NSNull null];
                        }
                        else
                        {
                            timeoffTypeName=timeEntryTimeOffName;
                        }
                        NSString *timeEntryTimeOffUri=[NSString stringWithFormat:@"%@",[tsEntryObject timeEntryTimeOffUri]];
                        if (timeEntryTimeOffUri==nil||[timeEntryTimeOffUri isKindOfClass:[NSNull class]]||[timeEntryTimeOffUri isEqualToString:@""]||[timeEntryTimeOffUri isEqualToString:NULL_STRING]||[timeEntryTimeOffUri isEqualToString:NULL_OBJECT_STRING])
                        {
                            timeoffTypeUri=[NSNull null];
                        }
                        else
                        {
                            timeoffTypeUri=timeEntryTimeOffUri;
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
                                                       timeoffTypeName,@"timeoffTypeName",
                                                       timeoffTypeUri,@"timeoffTypeUri",
                                                       nil];
                        
                        if (currentDate)
                        {
                            if ([timeEntryDate compare:currentDate]==NSOrderedSame)
                            {
                                if (![activeCellObjectsArray containsObject:infoDict])
                                {
                                    [activeCellObjectsArray addObject:infoDict];
                                    [indexOfactiveCellsArray addObject:[NSString stringWithFormat:@"%d",j]];
                                }
                                
                            }
                        }
                        
                    }
                }
            }


        return [NSMutableDictionary dictionaryWithObjectsAndKeys:activeCellObjectsArray,@"activeCellObjectsArray",indexOfactiveCellsArray,@"indexOfactiveCellsArray", nil];
    }
}
    return nil;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

    [searchBar resignFirstResponder];
}

//Implementation for US9371//JUHI
-(void)createRowUdfs
{
    if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
    {
        if (![self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
        {
            int decimalPlace=0;
            LoginModel *loginModel=[[LoginModel alloc]init];
            NSMutableArray *udfArray=[loginModel getEnabledOnlyUDFsforModuleName:TIMESHEET_ROW_UDF];

            for (int i=0; i<[udfArray count]; i++)
            {
                NSDictionary *udfDict = [udfArray objectAtIndex: i];
                NSMutableDictionary *dictInfo = [NSMutableDictionary dictionary];
                [dictInfo setObject:[udfDict objectForKey:@"name"] forKey:@"fieldName"];
                [dictInfo setObject:[udfDict objectForKey:@"uri"] forKey:@"identity"];

                if ([[udfDict objectForKey:@"udfType"] isEqualToString: NUMERIC_UDF_TYPE])
                {
                    [dictInfo setObject:UDFType_NUMERIC forKey:@"fieldType"];

                    if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS]) {
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
                    [dictInfo setObject:UDFType_TEXT forKey:@"fieldType"];
                    if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS] ) {
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
                    [dictInfo setObject: UDFType_DATE forKey: @"fieldType"];

                    if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS] ) {
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


                        }
                        else
                        {
                            if ([udfDict objectForKey:@"dateDefaultValue"]!=nil && !([[udfDict objectForKey:@"dateDefaultValue"] isKindOfClass:[NSNull class]]))
                            {
                                [dictInfo setObject:[Util convertTimestampFromDBToDate:[[udfDict objectForKey:@"dateDefaultValue"] stringValue]] forKey:@"defaultValue"];

                            }
                            else
                            {
                                if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS] ) {
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
                            if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS]) {
                                [dictInfo setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
                            }
                            else
                                [dictInfo setObject:RPLocalizedString(SELECT_STRING, @"") forKey:@"defaultValue"];
                        }
                    }
                }
                else if ([[udfDict objectForKey:@"udfType"] isEqualToString:DROPDOWN_UDF_TYPE])
                {
                    [dictInfo setObject:UDFType_DROPDOWN forKey:@"fieldType"];
                    if ([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS] ||[timesheetStatus isEqualToString:APPROVED_STATUS]) {
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
                if ([self.navigationType isKindOfClass:[ApprovalsNavigationController class]] || [self.navigationType isKindOfClass:[SupervisorDashboardNavigationController class]])
                {
                    ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
                    ApprovalsScrollViewController *scrolllView=(ApprovalsScrollViewController*)delegate;
                    if ([scrolllView.approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
                    {
                        selectedudfArray=[approvalsModel getPendingTimesheetSheetCustomFieldsForSheetURI:timesheetURI moduleName:TIMESHEET_ROW_UDF andUdfURI:[dictInfo objectForKey: @"identity"]];
                    }
                    else
                    {
                        selectedudfArray=[approvalsModel getPreviousTimesheetSheetCustomFieldsForSheetURI:timesheetURI moduleName:TIMESHEET_ROW_UDF andUdfURI:[dictInfo objectForKey: @"identity"]];


                    }



                }
                //User context Flow for Timesheets
                else if([delegate isKindOfClass:[DayTimeEntryViewController class]])
                {
                    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
                    selectedudfArray=[timesheetModel getTimesheetSheetCustomFieldsForSheetURI:timesheetURI moduleName:TIMESHEET_ROW_UDF andUdfURI:[dictInfo objectForKey: @"identity"]];

                }


                if ([selectedudfArray count]>0)
                {
                    NSMutableDictionary *selUDFDataDict=[selectedudfArray objectAtIndex:0];

                    EntryCellDetails *udfDetails = [[EntryCellDetails alloc] initWithDefaultValue:[dictInfo objectForKey: @"defaultValue"]];
                    [udfDetails setUdfIdentity:[dictInfo objectForKey:@"identity"]];
                    [udfDetails setFieldName:[dictInfo objectForKey: @"fieldName" ]];
                    [udfDetails setFieldType:[dictInfo objectForKey: @"fieldType" ]];
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
                                    [udfDetails setFieldValue:dateToBeUsed];
                                    [udfDetails setDefaultValue:dateToBeUsed];

                                }
                                else{
                                    if ([[selUDFDataDict objectForKey:@"entry_type"] isEqualToString:NUMERIC_UDF_TYPE])
                                    {
                                        [udfDetails setFieldValue:[Util getRoundedValueFromDecimalPlaces:[udfvaleFormDb newDoubleValue] withDecimalPlaces:decimalPlace]];
                                        [udfDetails setDefaultValue:[Util getRoundedValueFromDecimalPlaces:[udfvaleFormDb newDoubleValue] withDecimalPlaces:decimalPlace]];

                                    }
                                    else{
                                        [udfDetails setFieldValue:udfvaleFormDb];
                                        [udfDetails setDefaultValue:udfvaleFormDb];
                                    }
                                    if ([dictInfo objectForKey: @"defaultDecimalValue" ]!=nil)
                                    {
                                        [udfDetails setDecimalPoints:[[dictInfo objectForKey: @"defaultDecimalValue"]intValue]];

                                    }
                                    if ([dictInfo objectForKey: @"defaultMinValue" ]!=nil)
                                    {
                                        [udfDetails setMinValue:[dictInfo objectForKey: @"defaultMinValue" ]];

                                    }
                                    if ([dictInfo objectForKey: @"defaultMaxValue" ]!=nil)
                                    {
                                        [udfDetails setMaxValue:[dictInfo objectForKey: @"defaultMaxValue" ]];

                                    }

                                    if ([[selUDFDataDict objectForKey:@"entry_type"] isEqualToString:DROPDOWN_UDF_TYPE])
                                    {
                                        [udfDetails setDropdownOptionUri:[selUDFDataDict objectForKey: @"dropDownOptionURI" ]];


                                    }

                                }

                            }
                            else
                            {
                                if (([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[timesheetStatus isEqualToString:APPROVED_STATUS ])) {
                                    [udfDetails setFieldValue:RPLocalizedString(NONE_STRING, @"")];
                                    [udfDetails setDefaultValue:RPLocalizedString(NONE_STRING, @"")];

                                }
                                else{
                                    [udfDetails setFieldValue:[dictInfo objectForKey: @"defaultValue" ]];
                                    [udfDetails setDefaultValue:[dictInfo objectForKey: @"defaultValue" ]];
                                }



                            }

                        }
                        else
                        {
                            if (([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[timesheetStatus isEqualToString:APPROVED_STATUS ])) {
                                [udfDetails setFieldValue:RPLocalizedString(NONE_STRING, @"")];
                                [udfDetails setDefaultValue:RPLocalizedString(NONE_STRING, @"")];
                            }
                            else{
                                [udfDetails setFieldValue:[dictInfo objectForKey: @"defaultValue" ]];
                                [udfDetails setDefaultValue:[dictInfo objectForKey: @"defaultValue" ]];
                            }


                        }




                        [timeEntryArray addObject:udfDetails];

                    }
                }
                else{
                    EntryCellDetails *udfDetails = [[EntryCellDetails alloc] initWithDefaultValue:[dictInfo objectForKey: @"defaultValue"]];
                    [udfDetails setFieldName:[dictInfo objectForKey: @"fieldName" ]];
                    [udfDetails setFieldType:[dictInfo objectForKey: @"fieldType" ]];
                    [udfDetails setUdfIdentity:[dictInfo objectForKey:@"identity"]];
                    if (([timesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[timesheetStatus isEqualToString:APPROVED_STATUS ]))
                    {
                        [udfDetails setFieldValue:RPLocalizedString(NONE_STRING, @"")];
                        [udfDetails setDefaultValue:RPLocalizedString(NONE_STRING, @"")];

                    }
                    else
                    {
                        [udfDetails setFieldValue:[dictInfo objectForKey: @"defaultValue" ]];
                        [udfDetails setDefaultValue:[dictInfo objectForKey: @"defaultValue" ]];
                        
                    }
                    
                    if ([dictInfo objectForKey: @"defaultDecimalValue" ]!=nil)
                    {
                        [udfDetails setDecimalPoints:[[dictInfo objectForKey: @"defaultDecimalValue"]intValue]];
                        
                    }
                    if ([dictInfo objectForKey: @"defaultMinValue" ]!=nil)
                    {
                        [udfDetails setMinValue:[dictInfo objectForKey: @"defaultMinValue" ]];
                        
                    }
                    if ([dictInfo objectForKey: @"defaultMaxValue" ]!=nil)
                    {
                        [udfDetails setMaxValue:[dictInfo objectForKey: @"defaultMaxValue" ]];
                        
                    }
                    if ([dictInfo objectForKey: @"dropDownOptionUri" ]!=nil)
                    {
                        [udfDetails setDropdownOptionUri:[dictInfo objectForKey: @"dropDownOptionUri" ]];
                        
                    }
                    [timeEntryArray addObject:udfDetails];
                    
                    
                }
                
            }
        }
    }

    

}
-(void)pickerCancel:(id)sender
{
    self.datePicker.hidden=YES;
    self.toolbar.hidden=YES;
    [self resetTableSize:NO];
    [timeEntryTableView deselectRowAtIndexPath:selectedIndexPath animated:YES];

    NSArray *toolArray = [NSArray arrayWithObjects:spaceButton, doneButton,nil];
    [toolbar setItems:toolArray];
    [self updateFieldWithPickerChange:self.previousDateUdfValue];

}
-(void)pickerClear:(id)sender
{
    self.datePicker.hidden=YES;
    self.toolbar.hidden=YES;
    [self resetTableSize:NO];
    [timeEntryTableView deselectRowAtIndexPath:selectedIndexPath animated:YES];

    NSArray *toolArray = [NSArray arrayWithObjects:spaceButton, doneButton,nil];
    [toolbar setItems:toolArray];
    [self updateFieldWithPickerChange:RPLocalizedString(SELECT_STRING, @"")];

}
-(NSMutableArray*)getRowUdfsDetails
{

    NSMutableArray *rowUdfArray=[NSMutableArray array];
    if (!isMultiDayInOutTimesheetUser)
    {
        if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
        {
            if (![self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
            {
                for (NSUInteger i=udfIndexCount; i<[timeEntryArray count]; i++)
                {
                    [rowUdfArray addObject:[timeEntryArray objectAtIndex:i]];
                }
            }
        }


    }
    return rowUdfArray;
}

-(void)dismissCameraView
{
    // [locationManager stopUpdatingLocation];
    self.view.backgroundColor=[UIColor clearColor];
    //[self.punchMapViewController.view removeFromSuperview];
    if([delegate isKindOfClass:[AttendanceViewController class]])
    {
        AttendanceViewController *vc = (AttendanceViewController*)delegate;
        [self.navigationController popToViewController:vc animated:YES];
        [delegate  addActiVityIndicator];
    }
    else
        [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)gen4BreakEntrySaveResponseReceived:(NSNotification *)notification
{
    NSDictionary *responseInfo=notification.userInfo;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SAVE_BREAK_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
    [self saveAction:responseInfo];
}
-(void)gen4BreakEntryEditResponseReceived:(NSNotification *)notification
{
//    NSDictionary *responseInfo=notification.userInfo;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SAVE_BREAK_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];

    if([delegate isKindOfClass:[TimesheetMainPageController class]])
    {
        TimesheetMainPageController *ctrl=(TimesheetMainPageController *)delegate;
        NSDictionary *theData = [notification userInfo];
        NSString *receivedClientID=[theData objectForKey:@"clientId"];
        NSString *receivedPunchID=[theData objectForKey:@"timeEntryUri"];
        if (ctrl.pageControl.currentPage<ctrl.timesheetDataArray.count)
        {
            NSMutableArray *entryObjectArray=[ctrl.timesheetDataArray objectAtIndex:ctrl.pageControl.currentPage];

            if (indexBeingEdited<entryObjectArray.count)
            {
                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[entryObjectArray objectAtIndex:indexBeingEdited];
                NSString *clientID=@"";
                if ([[tsEntryObject timePunchesArray] count]>0  && [[tsEntryObject timePunchesArray] count]>indexBeingEdited)
                {
                    clientID=[[[tsEntryObject timePunchesArray] objectAtIndex:indexBeingEdited] objectForKey:@"clientID"];
                    if ([clientID isEqualToString:receivedClientID])
                    {
                        NSMutableDictionary *tmpDict=[NSMutableDictionary dictionaryWithDictionary:[[tsEntryObject timePunchesArray] objectAtIndex:0]];
                        if (receivedPunchID!=nil && ![receivedPunchID isKindOfClass:[NSNull class]])
                        {
                            [tmpDict setObject:receivedPunchID forKey:@"timePunchesUri"];
                        }

                        [[tsEntryObject timePunchesArray] replaceObjectAtIndex:0 withObject:[NSMutableDictionary dictionaryWithDictionary:tmpDict]];
                        [entryObjectArray replaceObjectAtIndex:indexBeingEdited withObject:tsEntryObject];

                    }
                }

            }

            TimesheetModel *tsModel=[[TimesheetModel alloc]init];
            [tsModel updateEditedValueForGen4BreakWithEntryUri:receivedPunchID sheetUri:timesheetURI withBreakName:[timesheetObject breakName] withBreakUri:[timesheetObject breakUri]];
            if([controllerDelegate isKindOfClass:[MultiDayInOutViewController class]])
            {
                MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)controllerDelegate;
                ctrl.timesheetEntryObjectArray=entryObjectArray;
            }
            
            [ctrl.timesheetDataArray replaceObjectAtIndex:ctrl.pageControl.currentPage withObject:entryObjectArray];
        }



    }

    [self editAction:nil];
}



-(void)sendAddGen4BreakInfoRequest
{
        [[self navigationItem].rightBarButtonItem setEnabled:FALSE];
        if([delegate isKindOfClass:[TimesheetMainPageController class]])
        {
            TimesheetMainPageController *ctrl=(TimesheetMainPageController *)delegate;

            if (isMultiDayInOutTimesheetUser)
            {
                if (ctrl.pageControl.currentPage<ctrl.timesheetDataArray.count)
                {
                    NSMutableArray *entryObjectArray=[ctrl.timesheetDataArray objectAtIndex:ctrl.pageControl.currentPage];
                    NSDate *todayDate=nil;
                    if ([entryObjectArray count]>0)
                    {
                        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[entryObjectArray objectAtIndex:indexBeingEdited];
                        todayDate=[tsEntryObject timeEntryDate];
                    }
                    else
                    {
                        todayDate=self.currentPageDate;
                    }

                    [[NSNotificationCenter defaultCenter] removeObserver:self name:SAVE_BREAK_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gen4BreakEntrySaveResponseReceived:) name:SAVE_BREAK_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
                    [[RepliconServiceManager timesheetService] sendRequestToSaveBreakTimeEntryForGen4:self withBreakUri:[self.timesheetObject breakUri] isBlankTimeEntrySave:YES withTimeEntryUri:nil withStartDate:todayDate forTimeSheetUri:timesheetURI withTimeDict:nil withClientID:[Util getRandomGUID] withBreakName:[self.timesheetObject breakName] timesheetFormat:self.timesheetFormat andColumnNameForEntryUri:@"clientPunchId"];
                    if ([delegate isKindOfClass:[TimesheetMainPageController class]])
                    {
                        TimesheetMainPageController *timesheetMainPageController=(TimesheetMainPageController *)delegate;
                        [timesheetMainPageController.multiDayInOutViewController updateUserChangedFlag];
                    }
                }

            }
        }


}
-(void)sendEditGen4BreakInfoRequest
{
        [[self navigationItem].rightBarButtonItem setEnabled:FALSE];
        if([delegate isKindOfClass:[TimesheetMainPageController class]])
        {
            TimesheetMainPageController *ctrl=(TimesheetMainPageController *)delegate;
            NSString *timepunchEntryUri=nil;
            NSMutableDictionary *timeDict=nil;
            if (isMultiDayInOutTimesheetUser)
            {
                if (ctrl.pageControl.currentPage<ctrl.timesheetDataArray.count)
                {
                    NSMutableArray *entryObjectArray=[ctrl.timesheetDataArray objectAtIndex:ctrl.pageControl.currentPage];
                    NSDate *todayDate=nil;
                    if ([entryObjectArray count]>0)
                    {
                        if (indexBeingEdited<entryObjectArray.count)
                        {
                            TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[entryObjectArray objectAtIndex:indexBeingEdited];
                            todayDate=[tsEntryObject timeEntryDate];
                            if ([tsEntryObject.timePunchesArray count]>0)
                            {
                                timeDict=[tsEntryObject.timePunchesArray objectAtIndex:0];
                                timepunchEntryUri=[timeDict objectForKey:@"timePunchesUri"];
                            }
                        }


                    }
                    else
                    {
                        todayDate=self.currentPageDate;
                    }

                    NSString *clientPunchID=[timeDict objectForKey:@"clientID"];
                    NSString *timePunchesUri=[timeDict objectForKey:@"timePunchesUri"];

                    NSString *entryUri = timePunchesUri != nil  && timePunchesUri != (id)[NSNull null] && ![timePunchesUri isEqualToString:@""] ? timePunchesUri : clientPunchID;
                    NSString *entryUriColumnName = timePunchesUri != nil  && timePunchesUri != (id)[NSNull null] && ![timePunchesUri isEqualToString:@""]  ? @"timePunchesUri" : @"clientPunchId";

                    [[NSNotificationCenter defaultCenter] removeObserver:self name:SAVE_BREAK_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gen4BreakEntryEditResponseReceived:) name:SAVE_BREAK_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
                    [[RepliconServiceManager timesheetService] sendRequestToSaveBreakTimeEntryForGen4:self withBreakUri:[self.timesheetObject breakUri] isBlankTimeEntrySave:NO withTimeEntryUri:timepunchEntryUri withStartDate:todayDate forTimeSheetUri:timesheetURI withTimeDict:timeDict withClientID:entryUri withBreakName:[self.timesheetObject breakName] timesheetFormat:self.timesheetFormat andColumnNameForEntryUri:entryUriColumnName];

                    if ([delegate isKindOfClass:[TimesheetMainPageController class]])
                    {
                        TimesheetMainPageController *timesheetMainPageController=(TimesheetMainPageController *)delegate;
                        [timesheetMainPageController.multiDayInOutViewController updateUserChangedFlag];
                    }
                }

            }
        }



}

#pragma mark NetworkMonitor

-(void) networkActivated {


}

#pragma mark memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    self.timeEntryTableView.delegate = nil;
    self.timeEntryTableView.dataSource = nil;
}

-(DeviceType)getDeviceType
{
    if (TARGET_IPHONE_SIMULATOR)
        return OnSimulator;
    else
        return OnDevice;
}

@end
