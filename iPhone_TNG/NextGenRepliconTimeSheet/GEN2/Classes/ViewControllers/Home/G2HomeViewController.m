//
//  RepliconExpensesSheet.m
//  RepliconHomee
//
//  Created by Hemabindu  on 1/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2HomeViewController.h"
#import"G2Constants.h"
#import "G2TransitionPageViewController.h"
#import "RepliconAppDelegate.h"
#import "G2PermissionsModel.h"

typedef enum ModuleTag {
    PunchClock_Tag = 9999,
	Timesheet_Tag = 1001,
	Expenses_Tag = 1002,
	More_Tag = 1003,
    Approvals_Tag = 1005,
	Timesheet_Disabled_Tag = 1004
} ModuleTag;

@interface G2HomeViewController()
//-(void) identifySupportedModules;
@end

@implementation G2HomeViewController

@synthesize timeSheetButton;
@synthesize timeOffButton;
@synthesize expensesButton;
@synthesize tnewTimeEntryButton;
@synthesize moreButton;
@synthesize expenseEnter;
@synthesize tnewTimeEntryNavController;
@synthesize udfexists,allUdfExistsFlag;
@synthesize  punchClockViewCtrl;
@synthesize  isLockedTimeSheet;
@synthesize badgeButton;
@synthesize isNotFirstTimeLoad;


- (id) init
{
	self = [super init];
	if (self != nil) {
		
		[NetworkMonitor sharedInstance];
		//permissionsModel =[[PermissionsModel alloc]init];
		
		if (permissionsetObj == nil) {
			permissionsetObj = [[G2PermissionSet alloc] init];
		}
		if (preferenceSet == nil) {
			preferenceSet = [[G2Preferences alloc] init];
		}
		if (timeSheetType == nil ) {
			timeSheetType = [[NSMutableString alloc] init];
		}
		
		if (timesheetModel ==  nil) {
			timesheetModel = [[G2TimesheetModel alloc] init];
		}
		[self setUdfexists:NO];
        [self setAllUdfExistsFlag:NO];
		//if (permissionSet ==  nil) {
        //			permissionSet = [[NSMutableArray array] retain];
        //		}
        
        isFromTabBar=FALSE;
	}
	return self;	
}
- (void)viewWillDisappear:(BOOL)animated
{
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];

     appDelegate.isAtHomeViewController=FALSE;
    [[NSNotificationCenter defaultCenter] removeObserver: self name: APPROVAL_TIMESHEETS_DOWNLOADING_TIMESHEETS_COUNT_NOTIFICATION object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: @"allTimesheetRequestsServed" object: nil];
}
-(void)viewWillAppear:(BOOL)animated{
	//DLog(@"View Will Appear");
    
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    G2PermissionsModel *permissionsModel=[[G2PermissionsModel alloc]init];
    BOOL isApprovalMenu=FALSE;
    if (appDelegate.hasTimesheetLicenses)
    {
        isApprovalMenu=[permissionsModel checkUserPermissionWithPermissionName:@"ApprovalMenu"];
    }
    else
    {
        isApprovalMenu=FALSE;
    }
    
    if (!isNotFirstTimeLoad) 
    {
        if (isApprovalMenu) 
        {
            int countApprovalAction=[[[NSUserDefaults standardUserDefaults] objectForKey:@"NumberOfTimesheetsWithPreviousApprovalAction" ]intValue] ;
            int badgeValue=[[[NSUserDefaults standardUserDefaults] objectForKey:@"NumberOfTimesheetsPendingApproval"] intValue];
            if (countApprovalAction>0  ||  badgeValue>0)
            {
                appDelegate.hasApprovalPermissions=TRUE;
            }
            else 
            {
                appDelegate.hasApprovalPermissions=FALSE;
            }
        }
        else 
        {
            appDelegate.hasApprovalPermissions=FALSE;
        }
    }
    
   //appDelegate.hasApprovalPermissions=TRUE;
   

      appDelegate.isAtHomeViewController=TRUE;
     [self   refreshViewFromViewWillAppear:animated];
    
    if ( appDelegate.hasApprovalPermissions) 
    {
        if (!isNotFirstTimeLoad) 
        {
           
            isNotFirstTimeLoad=TRUE;
        }
        else
        {
             
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:LoadingMessage];
            [[NSNotificationCenter defaultCenter] removeObserver: self name: APPROVAL_TIMESHEETS_DOWNLOADING_TIMESHEETS_COUNT_NOTIFICATION object: nil];
            [[NSNotificationCenter defaultCenter] addObserver: self 
                                                     selector: @selector(handleDownloadingApprovalsCount) 
                                                         name: APPROVAL_TIMESHEETS_DOWNLOADING_TIMESHEETS_COUNT_NOTIFICATION
                                                       object: nil];	
            [[G2RepliconServiceManager approvalsService] sendRequestToLoadUser];
        }
    }
    else
    {
        
         isNotFirstTimeLoad=TRUE;
        
    }
    
   
}

-(void)handleDownloadingApprovalsCount
{
    
     [[NSNotificationCenter defaultCenter] removeObserver: self name: APPROVAL_TIMESHEETS_DOWNLOADING_TIMESHEETS_COUNT_NOTIFICATION object: nil];
    int badgeValue=[[[NSUserDefaults standardUserDefaults] objectForKey:@"NumberOfTimesheetsPendingApproval"] intValue];
    [self addBadgeButtonWithNumbers:badgeValue xorigin: xORIGIN yorigin:yORIGIN];
    
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
   
}

-(void)refreshViewFromViewWillAppear:(BOOL)animated
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"] !=nil ){
        [[NSUserDefaults standardUserDefaults] setBool:TRUE   forKey:@"isConnectStagingServer"];
        [[NSUserDefaults standardUserDefaults] synchronize]; 
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:FALSE   forKey:@"isConnectStagingServer"];
        [[NSUserDefaults standardUserDefaults] synchronize]; 
    }
    
	G2PermissionsModel *permissionsModel =[[G2PermissionsModel alloc]init];
	G2SupportDataModel *supportDataModel = [[G2SupportDataModel alloc] init];
	[self checkforenabledSheetLeveludfs];
	NSMutableArray *userPreferences = [supportDataModel getAllUserPreferences];
	[[NSUserDefaults standardUserDefaults] setObject:userPreferences forKey:@"UserPreferenceSettings"];
    [[NSUserDefaults standardUserDefaults] synchronize]; 
	UIImageView *backGroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height+60)];
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f)
    {
        [backGroundImageView setImage:[G2Util thumbnailImage:HomeBackgroundImage568h]];  //BackgroundImage
    } else
    {
        [backGroundImageView setImage:[G2Util thumbnailImage:G2HomeBackgroundImage]];  //BackgroundImage
    }
	
	[self.view addSubview:backGroundImageView];
	
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    
	BOOL _useTimesheet = [permissionsModel checkUserPermissionWithPermissionName:@"UseTimesheet"];
	BOOL _projectExpense = [permissionsModel checkUserPermissionWithPermissionName:@"ProjectExpense"];
	BOOL _nonProjectExpense = [permissionsModel checkUserPermissionWithPermissionName:@"NonProjectExpense"];
	BOOL showTimesheetTab = YES;
    BOOL lockedinout = [permissionsModel checkUserPermissionWithPermissionName:@"LockedInOutTimesheet"];
    BOOL mobileLockedInOutTimesheet   = [permissionsModel checkUserPermissionWithPermissionName:@"MobileLockedInOutTimesheet"];
	NSMutableArray		*modulesOrderArray = [NSMutableArray array];
	isLockedTimeSheet=FALSE;
    isFromTabBar=FALSE;
	if(_useTimesheet)
	{
		
		if (lockedinout)
        {
            appDelegate.isMultipleTimesheetFormatsAssigned=FALSE;
            [self checkforenabledudfs];
            BOOL notagainstProjects = [permissionsModel checkUserPermissionWithPermissionName:@"NonProjectTimesheet"];
            BOOL allowBlankComments = [permissionsModel checkUserPermissionWithPermissionName:@"AllowBlankTimesheetComments"];
            BOOL activityRequired   = [permissionsModel checkUserPermissionWithPermissionName:@"TimesheetActivityRequired"];
            RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
            
            if (!mobileLockedInOutTimesheet) {
                showTimesheetTab = NO;
                appDelegate.isLockedTimeSheet=FALSE;
            }
            
            else if (allUdfExistsFlag || !notagainstProjects || !allowBlankComments || activityRequired) {
                showTimesheetTab = NO;
                appDelegate.isLockedTimeSheet=FALSE;
            }
            
            else  if (!allUdfExistsFlag && notagainstProjects && allowBlankComments && !activityRequired) 
            {
                isLockedTimeSheet=TRUE;
                
                appDelegate.isLockedTimeSheet=TRUE;
                [modulesOrderArray addObject:@"PunchClock_Module"];
            }
			appDelegate.isAcceptanceOfDisclaimerRequired=FALSE;
		} 
        else
        {
		//------------------------- US4434 Ullas M L---------------------------
            appDelegate.isMultipleTimesheetFormatsAssigned=FALSE;
            int permissionsCount=0;
            NSArray *permissionArray=[[NSArray alloc]initWithObjects:@"InOutTimesheet",
                                      @"ClassicTimesheet",
                                      @"NewInOutTimesheet",
                                      @"NewTimesheet", nil];
            for (int i=0; i<[permissionArray count]; i++) {
                BOOL isPermissionEnabled=[permissionsModel checkUserPermissionWithPermissionName:[permissionArray objectAtIndex:i]];
                if (isPermissionEnabled) {
                    permissionsCount++;
                }
            }
           
            
            if (permissionsCount>1) 
            {
                appDelegate.isMultipleTimesheetFormatsAssigned=TRUE;
            }
            //---------------------------------------------------------------------       
			NSMutableArray *timeSheetPreferences = [supportDataModel getUserTimeSheetFormats];
			if (timeSheetPreferences != nil && [timeSheetPreferences count]> 0) {
				for (NSDictionary *preferenceDict in timeSheetPreferences) {
					if ([[preferenceDict objectForKey:@"preferenceName"] isEqualToString:@"Timesheet.Format"]) {
						[timeSheetType setString: [preferenceDict objectForKey:@"preferenceValue"]];
						break;
					}
				}
                
                
                //------------------------- US4434 Ullas M L---------------------------
    
                if (appDelegate.isMultipleTimesheetFormatsAssigned)

                {
                   if ([timeSheetType isEqualToString:New_InOut_Type_TimeSheet]) {
                        appDelegate.isInOutTimesheet=TRUE;
                        appDelegate.isLockedTimeSheet=FALSE;
                        appDelegate.isNewInOutTimesheetUser=TRUE;
                    }
                    else if ([timeSheetType isEqualToString:InOut_Type_TimeSheet]) {
                        appDelegate.isInOutTimesheet=TRUE;
                        appDelegate.isLockedTimeSheet=FALSE;
                        appDelegate.isNewInOutTimesheetUser=FALSE;
                    }
                    else
                    {
                         appDelegate.isInOutTimesheet=FALSE;
                        appDelegate.isLockedTimeSheet=FALSE;
                        appDelegate.isNewInOutTimesheetUser=FALSE;
                    }

                }//---------------------------------------------------------------------
                else
                {   
                    BOOL isInOut = [permissionsModel checkUserPermissionWithPermissionName:@"InOutTimesheet"];
                    BOOL isClassicTimesheet = [permissionsModel checkUserPermissionWithPermissionName:@"ClassicTimesheet"];
                    BOOL isNewInOut = [permissionsModel checkUserPermissionWithPermissionName:@"NewInOutTimesheet"];
                    if (isInOut  ) 
                    {
                        if (isClassicTimesheet) 
                        {
                            if ([timeSheetType isEqualToString:InOut_Type_TimeSheet]) {
                                DLog(@"-----IN OUT TIMESHEETS ENABLED-----");
                                appDelegate.isInOutTimesheet=TRUE;
                                appDelegate.isLockedTimeSheet=FALSE;
                            }
                        }
                        else
                        {
                            if ([timeSheetType isEqualToString:InOut_Type_TimeSheet]) {
                                DLog(@"-----IN OUT TIMESHEETS ENABLED-----");
                                appDelegate.isInOutTimesheet=TRUE;
                                appDelegate.isLockedTimeSheet=FALSE;
                            }
                            
                        }
                        
                   
                }
                if (isNewInOut  ) 
                {
                    appDelegate.isInOutTimesheet=TRUE;
                    appDelegate.isNewInOutTimesheetUser=TRUE;
                }
                
			}

			if ([timeSheetType isEqualToString:Classic_Type_TimeSheet] || 
				[timeSheetType isEqualToString:Classic2_Type_TimeSheet] || [timeSheetType isEqualToString:InOut_Type_TimeSheet] || [timeSheetType isEqualToString:New_InOut_Type_TimeSheet])
            {
				showTimesheetTab = YES;
                
                if ([timeSheetType isEqualToString:Classic_Type_TimeSheet] ||  [timeSheetType isEqualToString:InOut_Type_TimeSheet]  ) 
                {
                    appDelegate.isAcceptanceOfDisclaimerRequired=FALSE;
                }
                
			} else 
            {
				showTimesheetTab = NO;
			}
		}
		
		
	}
        
        if (showTimesheetTab) {
			BOOL activitiesEnabled = [self userPreferenceSettings:@"ActivitiesEnabled"];
            BOOL timesheetactivityselection = [permissionsModel checkUserPermissionWithPermissionName:@"TimesheetActivityRequired"];
            if (activitiesEnabled && timesheetactivityselection ) {
                //showTimesheetTab = NO;
                showTimesheetTab = YES;
            }		
		}
	}
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    float aspectRatio=screenBounds.size.height/screenBounds.size.width;
	if (showTimesheetTab && !lockedinout) {
		//if (newTimeEntryButton==nil) {
        tnewTimeEntryButton =[UIButton buttonWithType:UIButtonTypeCustom];
		//}
		UIImage *timeEntryImage;
		//if ([supportedModules objectForKey: @"Timesheets_Module"] != nil) {
		timeEntryImage = [G2Util thumbnailImage:NewTimeEntryButtonImage];
		[tnewTimeEntryButton setBackgroundImage:timeEntryImage forState:UIControlStateNormal];
		[tnewTimeEntryButton setBackgroundImage:[G2Util thumbnailImage:submitButtonImageSelected] forState:UIControlStateHighlighted];
		[tnewTimeEntryButton addTarget:self action:@selector(showNewTimeEntry) forControlEvents:UIControlEventTouchUpInside];//US4591//Juhi
		[tnewTimeEntryButton setTitle:RPLocalizedString(New_Time_Entry,@"") forState:UIControlStateNormal];
		[tnewTimeEntryButton setFrame:CGRectMake(40.5,aspectRatio*240, timeEntryImage.size.width, timeEntryImage.size.height)];
        tnewTimeEntryButton.titleEdgeInsets = UIEdgeInsetsMake(-5.0, 0, 0, 0);
		if (_useTimesheet) {
			[self.view addSubview:tnewTimeEntryButton];
		}
	}
	NSString *timeSheetImage;
	int _timesheettag;
	if (showTimesheetTab) {
		timeSheetImage = TimeSheetButtonImage;
		_timesheettag = Timesheet_Tag;
	}else {
		timeSheetImage = TimeSheetButtonImage_Disabled;
		_timesheettag  = Timesheet_Disabled_Tag;
	}
    
	if (_useTimesheet && (_projectExpense || _nonProjectExpense)) {
		//[self customButtonWithModuleName:TimeSheetLabelText imageName:timeSheetImage xdimension:35 ydimension:100 tag: Timesheet_Tag];
		[self customButtonWithModuleName:TimeSheetLabelText imageName:timeSheetImage xdimension:40 ydimension:aspectRatio*66.66 tag: _timesheettag];
		[self customButtonWithModuleName:ExpenseLabelText imageName:ExpenseButtonImage xdimension:205 ydimension:aspectRatio*66.66 tag: Expenses_Tag];
        
        if (appDelegate.hasApprovalPermissions) {
            [self customButtonWithModuleName:ApprovalsLabelText imageName:ApprovalsButtonImage xdimension:40 ydimension:aspectRatio*156.66 tag: Approvals_Tag];
            int badgeValue=[[[NSUserDefaults standardUserDefaults] objectForKey:@"NumberOfTimesheetsPendingApproval"] intValue];
            [self addBadgeButtonWithNumbers:badgeValue xorigin:40 yorigin:aspectRatio*156.66];
            xORIGIN=40.0;
            yORIGIN=aspectRatio*156.66;
            [self customButtonWithModuleName:MoreLabelText imageName:MoreButtonImage xdimension:205 ydimension:aspectRatio*156.66 tag: More_Tag];
        }
        else
        {
            [self customButtonWithModuleName:MoreLabelText imageName:MoreButtonImage xdimension:125 ydimension:aspectRatio*156.66 tag: More_Tag];
        }
		
		
		
		if (showTimesheetTab) {
			//if (!udfexists) {
            [modulesOrderArray addObject:@"Timesheets_Module"];
			//}
			
			[modulesOrderArray addObject:@"Expenses_Module"];
            RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
            if (appDelegate.hasApprovalPermissions) {
                [modulesOrderArray addObject:@"Approvals_Module"];
            }
			[modulesOrderArray addObject:@"More_Settings"];			
		} else {
			[modulesOrderArray addObject:@"Expenses_Module"];
            RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
            if (appDelegate.hasApprovalPermissions) {
                [modulesOrderArray addObject:@"Approvals_Module"];
            }
			[modulesOrderArray addObject:@"More_Settings"];
		}
	} 
    else if (!_useTimesheet && (_projectExpense || _nonProjectExpense)) {
		[self customButtonWithModuleName:ExpenseLabelText imageName:ExpenseButtonImage xdimension:40 ydimension:aspectRatio*66.66 tag: Expenses_Tag];
        RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
        if (appDelegate.hasApprovalPermissions) {
            [self customButtonWithModuleName:ApprovalsLabelText imageName:ApprovalsButtonImage xdimension:205 ydimension:aspectRatio*66.66 tag: Approvals_Tag];
            int badgeValue=[[[NSUserDefaults standardUserDefaults] objectForKey:@"NumberOfTimesheetsPendingApproval"] intValue];
            [self addBadgeButtonWithNumbers:badgeValue xorigin:205 yorigin:aspectRatio*66.66];
            xORIGIN=205.0;
            yORIGIN=aspectRatio*66.66;

            [self customButtonWithModuleName:MoreLabelText imageName:MoreButtonImage xdimension:125 ydimension:aspectRatio*156.66 tag: More_Tag];
        }
        else
        {
            [self customButtonWithModuleName:MoreLabelText imageName:MoreButtonImage xdimension:205 ydimension:aspectRatio*66.66 tag: More_Tag];//Expense&TimeOff
        }
        
        
		[modulesOrderArray addObject:@"Expenses_Module"];
        if (appDelegate.hasApprovalPermissions) {
            [modulesOrderArray addObject:@"Approvals_Module"];
        }
		[modulesOrderArray addObject:@"More_Settings"];
		
	} 
    else if (_useTimesheet && !(_projectExpense || _nonProjectExpense)) {
		//[self customButtonWithModuleName:TimeSheetLabelText imageName:timeSheetImage xdimension:35 ydimension:100 tag: Timesheet_Tag];
		[self customButtonWithModuleName:TimeSheetLabelText imageName:timeSheetImage xdimension:40 ydimension:aspectRatio*66.66 tag: _timesheettag];
        RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
        if (appDelegate.hasApprovalPermissions) {
            [self customButtonWithModuleName:ApprovalsLabelText imageName:ApprovalsButtonImage xdimension:205 ydimension:aspectRatio*66.66 tag: Approvals_Tag];
            int badgeValue=[[[NSUserDefaults standardUserDefaults] objectForKey:@"NumberOfTimesheetsPendingApproval"] intValue];
            [self addBadgeButtonWithNumbers:badgeValue xorigin:205 yorigin:aspectRatio*66.66];
            xORIGIN=205.0;
            yORIGIN=aspectRatio*66.66;

            [self customButtonWithModuleName:MoreLabelText imageName:MoreButtonImage xdimension:125 ydimension:aspectRatio*156.66 tag: More_Tag];
        }
        else
        {
            [self customButtonWithModuleName:MoreLabelText imageName:MoreButtonImage xdimension:205 ydimension:aspectRatio*66.66 tag: More_Tag];//TimeOff&Expense&&More
        }
        
		
		if (showTimesheetTab) {			
			//if (!udfexists) {
            [modulesOrderArray addObject:@"Timesheets_Module"];
			//}	
		}
		else {
			DLog(@"Error: No permissions available");
		}
        if (appDelegate.hasApprovalPermissions) {
            [modulesOrderArray addObject:@"Approvals_Module"];
        }
		[modulesOrderArray addObject:@"More_Settings"];
	}
    else if (!_useTimesheet && !(_projectExpense || _nonProjectExpense)) {
		
        if (appDelegate.hasApprovalPermissions) {
            [self customButtonWithModuleName:ApprovalsLabelText imageName:ApprovalsButtonImage xdimension:40.0 ydimension:aspectRatio*66.66 tag: Approvals_Tag];
            int badgeValue=[[[NSUserDefaults standardUserDefaults] objectForKey:@"NumberOfTimesheetsPendingApproval"] intValue];
            [self addBadgeButtonWithNumbers:badgeValue xorigin:40.0 yorigin:aspectRatio*66.66];
            xORIGIN=40.0;
            yORIGIN=aspectRatio*66.66;
            
            [self customButtonWithModuleName:MoreLabelText imageName:MoreButtonImage xdimension:205 ydimension:aspectRatio*66.66 tag: More_Tag];
        }
        else
        {
            [self customButtonWithModuleName:MoreLabelText imageName:MoreButtonImage xdimension:40.0 ydimension:aspectRatio*66.66 tag: More_Tag];//TimeOff&Expense&&More
        }
        
		
        if (appDelegate.hasApprovalPermissions) {
            [modulesOrderArray addObject:@"Approvals_Module"];
        }
		[modulesOrderArray addObject:@"More_Settings"];
	}
	[[NSUserDefaults standardUserDefaults] setObject:modulesOrderArray forKey:@"TabBarModulesArray"];
    [[NSUserDefaults standardUserDefaults] synchronize]; 
	[self.navigationController.navigationBar setHidden:YES];
	
	if (_projectExpense == YES && _nonProjectExpense == YES) {
		expenseEnter = BOTH;
		projPermissionType = PermType_Both;
	}else if (_projectExpense == NO && _nonProjectExpense == YES) {		
		expenseEnter = NON_PROJECT_SPECIFIC;
		projPermissionType = PermType_NonProjectSpecific;
	}else if (_projectExpense == YES && _nonProjectExpense == NO) {
		expenseEnter = PROJECT_SPECIFIC;
		projPermissionType = PermType_ProjectSpecific;
	}
	
	NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
	[standardUserDefaults setObject:expenseEnter forKey:@"expenseEnter"];
    [standardUserDefaults synchronize]; 
	projPermissionType = [G2PermissionsModel getProjectPermissionType];
    
    
    if (isLockedTimeSheet) {
        //        if (!punchClockViewCtrl) {
        //            PunchClockViewController *temppunchClockViewCtrl=[[PunchClockViewController alloc] initWithNibName:@"PunchClockViewController" bundle:nil];
        //            self.punchClockViewCtrl=temppunchClockViewCtrl;
        //
        //        }
        //        
        //        [ self.view addSubview:self.punchClockViewCtrl.view];
        
/*        if (!animated) {
            [self timeEntryActionForPunchDetails];
        }
        else
        {
 */
            isFromTabBar=TRUE;
            [[[UIApplication sharedApplication] delegate] performSelector: @selector(flipToTabbarController:) 
                                                                   withObject:[NSNumber numberWithInt:0]];
 /*       } */
        
        
    }
    
    
    
    
	
	
}

-(void)checkforenabledSheetLeveludfs{
	G2PermissionsModel *permissionsModel   = [[G2PermissionsModel alloc] init];
	NSMutableArray *enabledPermissionSet = [permissionsModel getEnabledUserPermissions];
	
	NSDictionary *cellUdfDict = nil;
	NSDictionary *rowUdfDict = nil;
	NSDictionary *entireUdfDict = nil;
	NSMutableArray *udfpermissions = [NSMutableArray array];
	NSMutableArray *permissionSet  = [NSMutableArray array];
	NSMutableArray *requiredUdfsArray = [timesheetModel getEnabledAndRequiredTimeSheetLevelUDFs];
	
	for (NSDictionary *permissionDict in enabledPermissionSet) {
		NSString *permission = [permissionDict objectForKey:@"permissionName"];
		NSString *shortString = nil;
        if (![permission isKindOfClass:[NSNull class] ]) 
        {
            if ([permission length]-4 > 0) {
                NSRange stringRange = {0, MIN([permission length], [permission length]-4)};
                stringRange = [permission rangeOfComposedCharacterSequencesForRange:stringRange];
                shortString = [permission substringWithRange:stringRange];
                //DLog(@"Short String:HomeViewController %@",shortString);
            }
        }
		
		[udfpermissions addObject:shortString];
	}
    
    
	if ([udfpermissions containsObject:TimesheetEntry_CellLevel]) {
		cellUdfDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:TimesheetEntry_CellLevel];
	}
	if ([udfpermissions containsObject:TaskTimesheet_RowLevel]) {
		rowUdfDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:TaskTimesheet_RowLevel];
	}
	if ([udfpermissions containsObject:ReportPeriod_SheetLevel]) {
		entireUdfDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:ReportPeriod_SheetLevel];
	}
	if (cellUdfDict != nil) {
		[permissionSet addObject:cellUdfDict];
	}
	if (rowUdfDict != nil) {
		[permissionSet addObject:rowUdfDict];
	}
	if (entireUdfDict != nil) {
		[permissionSet addObject:entireUdfDict];
	}
	if (permissionSet != nil && [permissionSet count]>0) {//System Level
		if (requiredUdfsArray != nil && [requiredUdfsArray count]) {//User Level
            BOOL isUdfExistFlag=NO;
            if (entireUdfDict != nil && !isUdfExistFlag) {
                NSMutableArray *fieldIndexArr=[timesheetModel getEnabledAndRequiredTimeSheetLevelUDFsFieldIndexes:ReportPeriod_SheetLevel];
                for (int x=0; x<[fieldIndexArr count]; x++) {
                    NSMutableDictionary *tempDict=[fieldIndexArr objectAtIndex:x];
                    int fieldIndexOffset=[[tempDict objectForKey:@"fieldIndex"] intValue]+1;
                    if ([permissionsModel checkUserPermissionWithPermissionName:[NSString stringWithFormat:@"%@UDF%d",ReportPeriod_SheetLevel,fieldIndexOffset]]) {
                        isUdfExistFlag=YES;
                        break;
                    }
                }
            }
            
            
            [self setUdfexists:isUdfExistFlag];
            
            
			
		}else {
			[self setUdfexists:NO];
		}
	}else {
		[self setUdfexists:NO];
	}

}


-(void)checkforenabledudfs{
	G2PermissionsModel *permissionsModel   = [[G2PermissionsModel alloc] init];
	NSMutableArray *enabledPermissionSet = [permissionsModel getEnabledUserPermissions];
	
	NSDictionary *cellUdfDict = nil;
	NSDictionary *rowUdfDict = nil;
	NSDictionary *entireUdfDict = nil;
	NSMutableArray *udfpermissions = [NSMutableArray array];
	NSMutableArray *permissionSet  = [NSMutableArray array];
	NSMutableArray *requiredUdfsArray = [timesheetModel getEnabledAndRequiredTimeSheetLevelUDFs];
	
	for (NSDictionary *permissionDict in enabledPermissionSet) {
		NSString * permission = [permissionDict objectForKey:@"permissionName"];
		NSString *shortString = nil;
        if (![permission isKindOfClass:[NSNull class] ]) 
        {
            if ([permission length]-4 > 0) {
                NSRange stringRange = {0, MIN([permission length], [permission length]-4)};
                stringRange = [permission rangeOfComposedCharacterSequencesForRange:stringRange];
                shortString = [permission substringWithRange:stringRange];
                //DLog(@"Short String:HomeViewController %@",shortString);
            }
        }
		
		[udfpermissions addObject:shortString];
	}
    
    
	if ([udfpermissions containsObject:TimesheetEntry_CellLevel]) {
		cellUdfDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:TimesheetEntry_CellLevel];
	}
	if ([udfpermissions containsObject:TaskTimesheet_RowLevel]) {
		rowUdfDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:TaskTimesheet_RowLevel];
	}
	if ([udfpermissions containsObject:ReportPeriod_SheetLevel]) {
		entireUdfDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:ReportPeriod_SheetLevel];
	}
	if (cellUdfDict != nil) {
		[permissionSet addObject:cellUdfDict];
	}
	if (rowUdfDict != nil) {
		[permissionSet addObject:rowUdfDict];
	}
	if (entireUdfDict != nil) {
		[permissionSet addObject:entireUdfDict];
	}
	if (permissionSet != nil && [permissionSet count]>0) {//System Level
		if (requiredUdfsArray != nil && [requiredUdfsArray count]) {//User Level
            BOOL isUdfExistFlag=NO;
            if (cellUdfDict != nil && !isUdfExistFlag) {
                NSMutableArray *fieldIndexArr=[timesheetModel getEnabledAndRequiredTimeSheetLevelUDFsFieldIndexes:TimesheetEntry_CellLevel];
                for (int x=0; x<[fieldIndexArr count]; x++) {
                    NSMutableDictionary *tempDict=[fieldIndexArr objectAtIndex:x];
                    int fieldIndexOffset=[[tempDict objectForKey:@"fieldIndex"] intValue]+1;
                    if ([permissionsModel checkUserPermissionWithPermissionName:[NSString stringWithFormat:@"%@UDF%d",TimesheetEntry_CellLevel,fieldIndexOffset]]) {
                        isUdfExistFlag=YES;
                        break;
                    }
                }
            }
            if (rowUdfDict != nil && !isUdfExistFlag) {
                NSMutableArray *fieldIndexArr=[timesheetModel getEnabledAndRequiredTimeSheetLevelUDFsFieldIndexes:TaskTimesheet_RowLevel];
                for (int x=0; x<[fieldIndexArr count]; x++) {
                    NSMutableDictionary *tempDict=[fieldIndexArr objectAtIndex:x];
                    int fieldIndexOffset=[[tempDict objectForKey:@"fieldIndex"] intValue]+1;
                    if ([permissionsModel checkUserPermissionWithPermissionName:[NSString stringWithFormat:@"%@UDF%d",TaskTimesheet_RowLevel,fieldIndexOffset]]) {
                        isUdfExistFlag=YES;
                        break;
                    }
                }
            }
            if (entireUdfDict != nil && !isUdfExistFlag) {
                NSMutableArray *fieldIndexArr=[timesheetModel getEnabledAndRequiredTimeSheetLevelUDFsFieldIndexes:ReportPeriod_SheetLevel];
                for (int x=0; x<[fieldIndexArr count]; x++) {
                    NSMutableDictionary *tempDict=[fieldIndexArr objectAtIndex:x];
                    int fieldIndexOffset=[[tempDict objectForKey:@"fieldIndex"] intValue]+1;
                    if ([permissionsModel checkUserPermissionWithPermissionName:[NSString stringWithFormat:@"%@UDF%d",ReportPeriod_SheetLevel,fieldIndexOffset]]) {
                        isUdfExistFlag=YES;
                        break;
                    }
                }
            }
            
            
            [self setAllUdfExistsFlag:isUdfExistFlag];
            
            
			
		}else {
			[self setAllUdfExistsFlag:NO];
		}
	}else {
		[self setAllUdfExistsFlag:NO];
	}

}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */
//DE3518 Ullas M L
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag==123) 
    {
        NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"ISOName"];
        NSMutableArray *apiLanguageArray=[NSMutableArray array];
        for (id item in [str componentsSeparatedByString:@"-"])
            [apiLanguageArray addObject:item];
        
        RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
        NSArray *languages = nil;
        languages = [NSArray arrayWithObject:[apiLanguageArray objectAtIndex:0]];
        [[NSUserDefaults standardUserDefaults] setObject:languages forKey:@"AppleLanguages"];
        [[NSUserDefaults standardUserDefaults] setObject:languages forKey:@"SetAppLanguage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if (buttonIndex==1) 
        {
            appDelegate.isUserPressedClosedLater=NO;
           [apiLanguageArray objectAtIndex:5];//force crashing the app
        }
        if (buttonIndex==0) 
        {
            appDelegate.isUserPressedClosedLater=YES;
        }
    }
    
    else if (alertView.tag==999) 
    {
        // FOR TIME ENTRY
        if (buttonIndex==1)
        {
              [self newTimeEntryAction];//US4591//Juhi
        
        }
        //AD HOC
        else if (buttonIndex==2)
        {
            //US4591//Juhi
            actionType = ActionType_NewTimeOffEntry;
            if ([[NetworkMonitor sharedInstance] networkAvailable] == YES) {
//            G2TimesheetModel *_tsModel = [[G2TimesheetModel alloc] init];
            //NSArray *_timeOffUds = [_tsModel getEnabledOnlyTimeOffsUDFsForCellAndRow];
            BOOL supportDataCanRun = [G2Util shallExecuteQuery:TIMEOFF_SUPPORT_DATA_SERVICE_SECTION];
            if (supportDataCanRun)
            {
                [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
                [[NSNotificationCenter defaultCenter] removeObserver: self name: @"allTimesheetRequestsServed" object: nil];
                [[NSNotificationCenter defaultCenter] addObserver: self 
                                                         selector: @selector(handleProcessCompleteActions) 
                                                             name: @"allTimesheetRequestsServed"
                                                           object: nil];
                
//                [[RepliconServiceManager timesheetService] fetchTimeOffUDFs];
            }
            else
            {
                [self addNewAdHocTimeOffFromAlert];
            }
           
            
            }
            else {
                //[self showNewTimeEntry];
#ifdef PHASE1_US2152
                [G2Util showOfflineAlert];
                return;
#endif
            }
        }
    }
}
//US4591//Juhi
-(void)addNewAdHocTimeOffFromAlert{
    [[G2RepliconServiceManager timesheetService] setIsNewTimeOffPopUp:YES]; //DE6520//Juhi
    RepliconAppDelegate *appDelegate= (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    G2TimeEntryViewController *timeEntryViewController = [[G2TimeEntryViewController alloc] 
                                                              initWithEntryDetails:nil sheetId:nil screenMode:ADD_ADHOC_TIMEOFF 
                                                              permissionsObj:permissionsetObj preferencesObj:preferenceSet:appDelegate.isInOutTimesheet:appDelegate.isLockedTimeSheet:self];
    
    
    [timeEntryViewController setIsEntriesAvailable:YES];
    tnewTimeEntryNavController = [[UINavigationController alloc]initWithRootViewController:timeEntryViewController];
    [tnewTimeEntryNavController.navigationBar setTintColor:RepliconStandardNavBarTintColor];
    [self.navigationController presentViewController:tnewTimeEntryNavController animated:YES completion:nil];
    
   

}
-(void)addNewTimeEntryActionFromAlert
{
    DLog(@"Show New Time Entry:::HomeViewController");
    if (udfexists) {
        //	
        NSString *_msg = RPLocalizedString(NoUDFSupportMessage,NoUDFSupportMessage);
        [G2Util errorAlert: @"" errorMessage:_msg ];
        return;
    }
    //[[NSNotificationCenter defaultCenter] removeObserver:self name: TIMESHEETS_RECEIVED_NOTIFICATION object:nil];	
    [[NSNotificationCenter defaultCenter] removeObserver: self 
                                                    name: BOOKED_TIME_OFF_ENTRY_RECEIVED_NOTIFICATION 
                                                  object:nil];
    
    
    //TODO: Get Permissions for 'Against/Both', 'Without requiring a Project': DONE
    G2PermissionsModel *permissionsModel = [[G2PermissionsModel alloc] init];
    NSMutableArray *userPermissions = [permissionsModel getAllEnabledUserPermissions];
   
    permissionsModel = nil;
    [[NSUserDefaults standardUserDefaults] setObject:userPermissions forKey:@"UserPermissionSet"];
    [[NSUserDefaults standardUserDefaults] synchronize]; 
    BOOL againstProjects    = [self checkForPermissionExistence:@"ProjectTimesheet"];
    BOOL notagainstProjects = [self checkForPermissionExistence:@"NonProjectTimesheet"];
    BOOL unsubmitAllowed	= [self checkForPermissionExistence:@"UnsubmitTimesheet"];
    BOOL billingTimesheet   = [self checkForPermissionExistence:@"BillingTimesheet"];
    //    BOOL displayTimesheet   = [self checkForPermissionExistence:@"TimesheetDisplayActivities"];
    BOOL timesheetRequired   = [self checkForPermissionExistence:@"TimesheetActivityRequired"];
    
    //TODO: Need to check for 'Activities Enabled' permission:DONE
    G2SupportDataModel *supportDataModel = [[G2SupportDataModel alloc] init];
    
    NSMutableArray *userActivities=[supportDataModel getUserActivitiesFromDatabase];
//    int projectsCount = [supportDataModel getUserProjectsCount];
   
//    if (againstProjects && !notagainstProjects && !(projectsCount > 0)) {
//
//        [Util errorAlert:@"" errorMessage:RPLocalizedString(YouCannotEnterTimeBecauseNoProjectsAreAssignedToYou,@"")];//DE1231//Juhi
//        return;
//    }
//    else if(timesheetRequired)
    if(timesheetRequired)    
    {
        
        if ([userActivities count]==0  ) 
        {
            
            [G2Util errorAlert:@"" errorMessage:RPLocalizedString(YouCannotEnterTimeBecauseNoActivitiesAreAssignedToYou,@"")];//DE1231//Juhi
            return;
            
           
        }
    }
    //	NSMutableArray *userPreferences = [supportDataModel getAllUserPreferences];
    //	[[NSUserDefaults standardUserDefaults] setObject:userPreferences forKey:@"UserPreferenceSettings"];
    
    BOOL activitiesEnabled = [self userPreferenceSettings:@"ActivitiesEnabled"];
    BOOL allowComments	  = [self userPreferenceSettings:@"AllowBlankResubmitComment"];
    BOOL useBillingInfo    = [self userPreferenceSettings:@"UseBillingInformation"];
    
    BOOL both = NO;
    if (againstProjects && notagainstProjects) {
        both = YES;
    }
    
    //TODO: Get User Preference for Time Format:DONE
    NSString *timeFormat  = @"";
    G2SupportDataModel *supportDataModel1 = [[G2SupportDataModel alloc] init];
    NSMutableArray *formatsArray = [supportDataModel1 getUserTimeSheetFormats];
    
    if (formatsArray != nil && [formatsArray count]> 0) {
        for (NSDictionary *formatDict in formatsArray) {
            if ([[formatDict objectForKey:@"preferenceName"] isEqualToString:@"Timesheet.HourFormat"]) {
                timeFormat = [formatDict objectForKey:@"preferenceValue"];
            }
        }
    }
    //timeFormat = [[supportDataModel getUserTimeFormat] retain];
    
    
    //Create Preferences Object
    [preferenceSet setTimeSheetType:timeSheetType];
    [preferenceSet setHourFormat:timeFormat];
    [preferenceSet setActivitiesEnabled:activitiesEnabled];
    [preferenceSet setUseBillingInfo:useBillingInfo];
    
    //Create Permission Object
    [permissionsetObj setProjectTimesheet:againstProjects];
    [permissionsetObj setNonProjectTimesheet:notagainstProjects];
    [permissionsetObj setUnsubmitTimeSheet:unsubmitAllowed];
    [permissionsetObj setBothAgainstAndNotAgainstProject:both];
    [permissionsetObj setAllowBlankResubmitComment:allowComments];
    [permissionsetObj setBillingTimesheet:billingTimesheet];
    /*
     AddNewTimeEntryViewController *addNewTimeEntryViewController = [[AddNewTimeEntryViewController alloc] init];
     [addNewTimeEntryViewController addTableHeader];
     [addNewTimeEntryViewController setScreenMode:ADD_TIME_ENTRY];
     [addNewTimeEntryViewController setIsEntriesAvailable:YES];
     [addNewTimeEntryViewController viewAddEditEachTimeEntryDetails:nil 
     withpermissionSet:permissionsetObj 
     withpreferences:preferenceSet];
     */
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    G2TimeEntryViewController *addNewTimeEntryViewController = [[G2TimeEntryViewController alloc] 
                                                              initWithEntryDetails:nil sheetId:nil screenMode:ADD_TIME_ENTRY 
                                                              permissionsObj:permissionsetObj preferencesObj:preferenceSet:appDelegate.isInOutTimesheet:appDelegate.isLockedTimeSheet:self];
    [addNewTimeEntryViewController setIsEntriesAvailable:YES];
    tnewTimeEntryNavController = [[UINavigationController alloc] initWithRootViewController:addNewTimeEntryViewController];
    //Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    if (version>=7.0)
    {
        tnewTimeEntryNavController.navigationBar.translucent = FALSE;
        tnewTimeEntryNavController.navigationBar.barTintColor=RepliconStandardNavBarTintColor;
        tnewTimeEntryNavController.navigationBar.tintColor=RepliconStandardWhiteColor;
    }
    else
        tnewTimeEntryNavController.navigationBar.tintColor=RepliconStandardNavBarTintColor;
    
    
    [self.navigationController presentViewController:tnewTimeEntryNavController animated:YES completion:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
    
   
    
   
    
    
}

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
     [super viewDidLoad];
     
      RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate]; 
     G2SupportDataModel *supportDatamodel=[[G2SupportDataModel alloc]init];
     //     NSArray *disclaimerArray=[supportDatamodel getDisclaimerPreferencesforType:@"Timesheet" foriSOName:[[NSUserDefaults standardUserDefaults] objectForKey:@"ISOName"]];
     NSArray *disclaimerArray=[supportDatamodel getDisclaimerPreferencesforType:@"Timesheet" foriSOName:@"en"];
     
     G2PermissionsModel *permissionsModel=[[G2PermissionsModel alloc]init];
     
      BOOL showDisclaimerPermission=[permissionsModel checkUserPermissionWithPermissionName:@"ShowTimesheetDisclaimer"];
     
   
     
     if ([disclaimerArray count]>0) 
     {
         NSDictionary *disclaimerDict=[disclaimerArray objectAtIndex:0];
         appDelegate.attestationTitleTimesheets=[disclaimerDict objectForKey:@"disclaimerTitle"];
         appDelegate.attestationDescTimesheets=[disclaimerDict objectForKey:@"disclaimerDescription"];
     }
     
     
     
     if (appDelegate.attestationDescTimesheets!=nil && ![appDelegate.attestationDescTimesheets isKindOfClass:[NSNull class] ] && ![[appDelegate.attestationDescTimesheets stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]  ] isEqualToString:@"" ] && ![appDelegate.attestationDescTimesheets isEqualToString:@"<null>"] && showDisclaimerPermission)
     {
         appDelegate.isAttestationPermissionTimesheets=TRUE;
         if (appDelegate.attestationTitleTimesheets==nil || [appDelegate.attestationTitleTimesheets isKindOfClass:[NSNull class] ]  || [[appDelegate.attestationTitleTimesheets stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]  ] isEqualToString:@"" ] || [appDelegate.attestationTitleTimesheets isEqualToString:@"<null>" ] ) 
         {
             appDelegate.attestationTitleTimesheets=@"Disclaimer";
         }
     }
     
     else if (appDelegate.attestationTitleTimesheets!=nil && ![appDelegate.attestationTitleTimesheets isKindOfClass:[NSNull class] ] && ![[appDelegate.attestationTitleTimesheets stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]  ] isEqualToString:@"" ] && ![appDelegate.attestationTitleTimesheets isEqualToString:@"<null>" ] && showDisclaimerPermission) 
     {
         appDelegate.isAttestationPermissionTimesheets=TRUE;
         
     }
     
     
     else
     {
         appDelegate.isAttestationPermissionTimesheets=FALSE;
     }
   
     
     appDelegate.isAcceptanceOfDisclaimerRequired=[permissionsModel checkUserPermissionWithPermissionName:@"RequireDisclaimerAcceptance"];
     
     
     
     BOOL isEnterTimeAgainstTimeOff = [permissionsModel checkUserPermissionWithPermissionName:@"TimeoffTimesheet"];
     
     
     G2SupportDataModel *supportDataModel=[[G2SupportDataModel alloc]init];
     NSArray *timeOffsArray=[supportDataModel getValidTimeOffCodesFromDatabaseForTimeOff];
    
     
     if (isEnterTimeAgainstTimeOff && [timeOffsArray count]>0)
     {
         appDelegate.isTimeOffEnabled=TRUE;
     }
     
     
     appDelegate.isPopUpForSAMLAuthentication=FALSE;

     
    
     //US3518 Ullas M L
     
     NSString *str = [[NSUserDefaults standardUserDefaults] objectForKey:@"ISOName"];
     NSString *languageName=[[NSUserDefaults standardUserDefaults] objectForKey:@"LanguageName"];
     NSMutableArray *languageArray=[NSMutableArray array];
     for (id item in [languageName componentsSeparatedByString:@"("])
         [languageArray addObject:item];
     NSMutableArray *apiLanguageArray=[NSMutableArray array];
     for (id item in [str componentsSeparatedByString:@"-"])
         [apiLanguageArray addObject:item];
     
     NSString *APILanguage=[apiLanguageArray objectAtIndex:0];
     NSArray *deviceLanguageArray=[[NSUserDefaults standardUserDefaults]objectForKey:@"AppleLanguages"];
     NSString *deviceLanguage=[deviceLanguageArray objectAtIndex:0];
     
     NSString *path = [[NSBundle mainBundle] pathForResource:APILanguage ofType:@"lproj"];
     BOOL doesLocalisationFileExist = [[NSFileManager defaultManager] fileExistsAtPath:path];
     
     //if Device labguage anf API language doesnot match and localisation file for API language exist pop alert
     BOOL isFirstTimeLogin;
     NSString *languageToBeCompared=@"";
     NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
     if ([prefs boolForKey:@"boolvalue"]) 
     {
         
         isFirstTimeLogin=FALSE;
         NSArray *array=[[NSUserDefaults standardUserDefaults] objectForKey:@"SetAppLanguage" ];
         languageToBeCompared=[array objectAtIndex:0];
         
     }
     else
     {
         
         isFirstTimeLogin=TRUE;
         languageToBeCompared=deviceLanguage;
         if (![deviceLanguage isEqualToString:@"en"]) {
             NSString *path = [[NSBundle mainBundle] pathForResource:deviceLanguage ofType:@"lproj"];
             BOOL checkPoint = [[NSFileManager defaultManager] fileExistsAtPath:path];
             if (!checkPoint) {
                 return;
             }
         }
         
         NSArray *deviceLanguageArray=[[NSUserDefaults standardUserDefaults]objectForKey:@"AppleLanguages"];
         NSArray *languages = nil;
         languages = [NSArray arrayWithObject:[deviceLanguageArray objectAtIndex:0]];
         [[NSUserDefaults standardUserDefaults] setObject:languages forKey:@"SetAppLanguage"];
         [[NSUserDefaults standardUserDefaults] synchronize];

     }
     if (prefs) 
     {
         [prefs setBool:isFirstTimeLogin forKey:@"boolvalue"];
         [prefs synchronize];
     }
     
     if ([APILanguage isEqualToString:@"en"]) {
         doesLocalisationFileExist=YES;
     }
     
       
     if (![languageToBeCompared isEqualToString:APILanguage]&& doesLocalisationFileExist && !appDelegate.isUserPressedClosedLater) 
     {
         NSString *strMessage1=RPLocalizedString(LANGUAGE_SET_MSG1, @"");
         NSString *strMessage2=RPLocalizedString(LANGUAGE_SET_MSG2,@"");
         
         NSString *message=[NSString stringWithFormat:@"%@ \"%@.\" %@",strMessage1,languageName,strMessage2];        
         UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:nil message:RPLocalizedString(message, @"") 
                                                                   delegate:self cancelButtonTitle:RPLocalizedString(LANGUAGE_SET_BUTTON1_TITLE, @"")otherButtonTitles:RPLocalizedString(LANGUAGE_SET_BUTTON2_TITLE, @""),nil];
         [confirmAlertView setDelegate:self];
         [confirmAlertView setTag:123];
         [confirmAlertView show];
         
     }
     
    
    
     
 }
 

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

-(void)customButtonWithModuleName:(NSString *)_name imageName:(NSString *)_imgName xdimension:(int)x ydimension:(int)y tag:(int)_tag{
	
	UIButton *customButton =[UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *normalImg = [G2Util thumbnailImage:_imgName];
	UIImage *selectedImg = nil;
	
	if (_tag == Timesheet_Tag) {
		
		selectedImg = [G2Util thumbnailImage:G2TimeSheetsSelectedImage];
	}else if (_tag == Expenses_Tag) {
		selectedImg = [G2Util thumbnailImage:G2ExpenseSheetsSelectedImage];
	}else if(_tag == Approvals_Tag) {
		selectedImg = [G2Util thumbnailImage:G2ApprovalsSelectedImage];
	}else if(_tag == More_Tag) {
		selectedImg = [G2Util thumbnailImage:G2MoreSelectedImage];
	}else if (_tag == Timesheet_Disabled_Tag) {
		selectedImg = [G2Util thumbnailImage:TimeSheetButtonImage_Selected];
	}
    
	
	UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(-11, normalImg.size.height, 100, 20)];
	[titleLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
	[titleLabel setTextAlignment:NSTextAlignmentCenter];
	
	
	[titleLabel setText: RPLocalizedString(_name, _name)];
	//selectedImg = [Util thumbnailImage: _imgName];
	
	[customButton setFrame:CGRectMake(x,y, normalImg.size.width, normalImg.size.height)];
	[customButton setImage:normalImg forState:UIControlStateNormal];
	[customButton setImage:selectedImg forState:UIControlStateHighlighted];
	
	
    //	[customButton addTarget:self action:@selector(customButtonAction:) forControlEvents:UIControlEventTouchDown];
	[customButton addTarget:self action:@selector(customButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[customButton addTarget:self action:@selector(customButtonActionRemoveBackground:) forControlEvents:UIControlEventTouchUpInside];
	[customButton setTag:_tag];
	
	//--	
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	
	[titleLabel setTextColor:[UIColor blackColor]];
	[customButton addSubview:titleLabel];
	
	[self.view addSubview:customButton];
	
	
	
}


#pragma mark -
#pragma mark ButtonActions
#pragma mark -

- (void)customButtonAction:(id)sender{

	NSArray *modulesArray = [[NSUserDefaults standardUserDefaults] objectForKey: @"TabBarModulesArray"];
	int expensesTabIndex=0;
	int timesheetTabIndex=0;
    int approvalsTabIndex=0;
	int moreTabIndex=0;
	
	for (int i=0; i < [modulesArray count]; ++i) {
		if ([[modulesArray objectAtIndex: i] isEqualToString: @"Timesheets_Module"]) {
			timesheetTabIndex = i;
		}
		if ([[modulesArray objectAtIndex: i] isEqualToString: @"Expenses_Module"]) {
			expensesTabIndex = i;
		}
        if ([[modulesArray objectAtIndex: i] isEqualToString: @"Approvals_Module"]) {
			approvalsTabIndex = i;
		}
		if ([[modulesArray objectAtIndex: i] isEqualToString: @"More_Settings"]) {
			moreTabIndex = i;
		}
	}
	int selectedTabIndex=0;
	if ([sender tag] == Timesheet_Tag || 
		[sender tag] == Timesheet_Disabled_Tag) {
		selectedTabIndex = timesheetTabIndex;
		[self timeSheetAction];
	}
	else if ([sender tag] == Expenses_Tag) {
		selectedTabIndex = expensesTabIndex;
		[self expensesAction: selectedTabIndex];
	}
    else if ([sender tag] == Approvals_Tag) {
		selectedTabIndex = approvalsTabIndex;
		[self approvalsAction];
	}
	else if ([sender tag] == More_Tag) {
		selectedTabIndex = moreTabIndex;
		[self moreAction];
	}
    else {
		selectedTabIndex = 0;
	}
	[[NSNotificationCenter defaultCenter]postNotificationName:@"SelectedTab" object: [NSNumber numberWithInt: selectedTabIndex]];
}

- (void)customButtonActionRemoveBackground:(id)sender {
	
	//[sender setImage:nil forState:UIControlStateNormal];
}

- (void)newTimeEntryAction 
{

    
    
    actionType = ActionType_NewTimeEntry;
    //fetch all timesheet data
    if ([[NetworkMonitor sharedInstance] networkAvailable] == YES) {
        G2TimesheetModel *_tsModel = [[G2TimesheetModel alloc] init];
//        G2SupportDataModel *supportDataModel = [[G2SupportDataModel alloc] init];
        NSArray *_timeSheets = [_tsModel getTimesheetsFromDB];
        BOOL supportDataCanRun = [G2Util shallExecuteQuery:TIMESHEET_SUPPORT_DATA_SERVICE_SECTION];
        BOOL sheetDataCanRun = [G2Util shallExecuteQuery:TIMESHEET_DATA_SERVICE_SECTION];
        if ((_timeSheets == nil || [_timeSheets count] == 0 || supportDataCanRun || sheetDataCanRun) && [NetworkMonitor isNetworkAvailableForListener:self] == YES) 
        {
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
            [[NSNotificationCenter defaultCenter] removeObserver: self name: @"allTimesheetRequestsServed" object: nil];
            [[NSNotificationCenter defaultCenter] addObserver: self 
                                                     selector: @selector(handleProcessCompleteActions) 
                                                         name: @"allTimesheetRequestsServed"
                                                       object: nil];	
            [[G2RepliconServiceManager timesheetService] fetchTimeSheetData: self];
        } 
        //DE6752
 /*       else if(([[supportDataModel getAllClientNames] count] == 1 && ([[supportDataModel getAllClientNames]  containsObject:NONE_STRING])) ||[[supportDataModel getAllClientNames] count] == 0 ){//FIX FOR DE3601
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
            [[NSNotificationCenter defaultCenter] removeObserver: self name: @"allTimesheetRequestsServed" object: nil];
            [[NSNotificationCenter defaultCenter] addObserver: self 
                                                     selector: @selector(handleProcessCompleteActions) 
                                                         name: @"allTimesheetRequestsServed"
                                                       object: nil];	
            [[RepliconServiceManager timesheetService] fetchClientsAndProject];
        } */
        else {
            [self addNewTimeEntryActionFromAlert];//US4591//Juhi;
        }
        
    }
    else {
        //[self showNewTimeEntry];
#ifdef PHASE1_US2152
        [G2Util showOfflineAlert];
        return;
#endif
    }
    
    
	
	
}





- (void)timeEntryActionForPunchDetails {
    
	
/*
    if ( [NetworkMonitor isNetworkAvailableForListener:self] == YES) 
        
    {
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
         [[NSNotificationCenter defaultCenter] removeObserver: self name: @"allTimesheetRequestsServed" object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self 
                                                 selector: @selector(handleProcessCompleteActions) 
                                                     name: @"allTimesheetRequestsServed"
                                                   object: nil];	
        [[RepliconServiceManager timesheetService]fetchTimeSheetUSerDataForDate: self andDate:nil];
		
	}
	else 
    {
		
		[Util showOfflineAlert];
		return;
        
	}
 
 */
}


-(void) handleProcessCompleteActions{
	DLog(@"handleProcessCompleteActions ::HomeViewController ");
	
	
    G2PermissionsModel *permissionsModel =[[G2PermissionsModel alloc]init];
    BOOL lockedinout = [permissionsModel checkUserPermissionWithPermissionName:@"LockedInOutTimesheet"];
    
    if (!lockedinout) {
        [self checkforenabledSheetLeveludfs];
        DLog(@"UDF exists %d",udfexists);
        switch (actionType) {
            case ActionType_NewTimeEntry:
            {
                [[NSNotificationCenter defaultCenter] removeObserver: self name: @"allTimesheetRequestsServed" object: nil];
                if (udfexists) {
                    //				NSString *_msg = @"Custom timesheet fields (UDFs) are currently not supported in the Replicon Mobile app.  Please log in to Replicon through a browser to enter time.";
                    NSString *_msg = RPLocalizedString(@"Custom timesheet level (UDFs) are currently not supported in the Replicon Mobile app.  Please log in to Replicon through a browser to enter time.","");//US4337//Juhi
                    [G2Util errorAlert: @"" errorMessage: _msg];
                    [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
                    return;
                }
                [self addNewTimeEntryActionFromAlert];
            }
               
                break;
            case ActionType_NewTimeOffEntry:
            {
                [[NSNotificationCenter defaultCenter] removeObserver: self name: @"allTimesheetRequestsServed" object: nil];
                [self addNewAdHocTimeOffFromAlert] ;
            }
               
                 break;

            case ActionType_TimesheetList:
            {
                [[NSNotificationCenter defaultCenter] removeObserver: self name: @"allTimesheetRequestsServed" object: nil];
                NSMutableArray *modulesArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"TabBarModulesArray"];
                NSUInteger tabIndex = [modulesArray indexOfObject:@"Timesheets_Module"];
                DLog(@"Tab Index %lu",(unsigned long)tabIndex);
                if (udfexists) {
                    //				NSString *_msg = @"Custom timesheet fields (UDFs) are currently not supported in the Replicon Mobile app.  Please log in to Replicon through a browser to enter time.";
                    NSString *_msg = RPLocalizedString(@"Custom timesheet level (UDFs) are currently not supported in the Replicon Mobile app.  Please log in to Replicon through a browser to enter time.","");//US4337//Juhi
                    [G2Util errorAlert: @"" errorMessage:_msg ];
                    [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
                    return;
                }
                [[[UIApplication sharedApplication] delegate] performSelector: @selector(flipToTabbarController:)
                                                                   withObject:[NSNumber numberWithUnsignedInteger:tabIndex]];
            }
                break;
            default:
                break;
        }	
        
    }
    else
    {
        if (!isFromTabBar) {
            [self viewWillAppear:YES];
        }
        
    }
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
}

-(void)showNewTimeEntry 
{
    RepliconAppDelegate *appDelegate= (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if (appDelegate.isLockedTimeSheet)
    {
        if (appDelegate.isTimeOffEnabled)
        {
            
            UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:nil message:nil
                                                                      delegate:self cancelButtonTitle:RPLocalizedString(CANCEL_BTN_TITLE, CANCEL_BTN_TITLE) otherButtonTitles:RPLocalizedString(NEW_TIME_ENTRY_TEXT, NEW_TIME_ENTRY_TEXT),RPLocalizedString(ADHOC_TIME_OFF_TEXT, ADHOC_TIME_OFF_TEXT),nil];
            
            [confirmAlertView setDelegate:self];
            [confirmAlertView setTag:999];
            [confirmAlertView show];
            
            
        }
        else 
        {
            [self newTimeEntryAction];//US4591//Juhi
        }
        

    }
    
    else
    {
        [self newTimeEntryAction];
    }
    
}

-(BOOL)checkForPermissionExistence:(NSString *)_permission{
	NSMutableArray *permissionlist = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserPermissionSet"];
	if (_permission != nil) {
		if ([permissionlist containsObject:_permission]) {
			return YES;
		}
	}
	return NO;
}
-(BOOL)userPreferenceSettings:(NSString *)_preference{
	NSMutableArray *preferences = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserPreferenceSettings"];
	if (_preference != nil) {
		if ([preferences containsObject:_preference]) {
			return YES;
		}
	}
	return NO;
}

- (void)timeOffAction {
	
}

- (void)expensesAction: (int)tabIndex {
	
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)	{
		
#ifdef PHASE1_US2152
		[G2Util showOfflineAlert];
		return;
#else
        NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
        
        G2ExpensesModel *expensesModel = [[G2ExpensesModel alloc] init];
        NSArray *_expenseSheets = [expensesModel getExpenseSheetsFromDataBase];
        
        
        if(_expenseSheets != nil && [_expenseSheets count] > 0)	{
            [standardUserDefaults setObject: _expenseSheets forKey:@"expenseSheetsArray"];
            [standardUserDefaults synchronize];
            
            //ravi - Expense entries should be fetched only when the user clicks on an expense sheet
            //NSDictionary *supportedModules = [[NSUserDefaults standardUserDefaults] objectForKey: @"SupportedModules"];
            //NSNumber *tabIndex = [supportedModules objectForKey: @"Expenses_Module"];
            [[[UIApplication sharedApplication] delegate] performSelector: @selector(flipToTabbarController:)
                                                               withObject: [NSNumber numberWithInt: tabIndex]];
        }    
#endif
		
	}
    else
    {
         [NSThread detachNewThreadSelector: @selector(showProgression) toTarget:self withObject:nil];
       
		[[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool: FALSE]  forKey: @"isManualSync"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		//DE2100: Login: Show transition page when downloading/processing, instead of just spinner on top of current page
		//[TransitionPageViewController startProcessForType: ProcessType_ExpenseSheets withData: nil withDelegate: nil];
		
		//ravi DE1848 Exp List Page: Expenses not downloaded if first access from tab bar
		[[G2RepliconServiceManager expensesService] fetchExpenseSheetData];
	}
}

-(void)showProgression
{
    @autoreleasepool {
       [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
    }
    
}

- (void)approvalsAction {
	//MoreViewController *moreController=[[MoreViewController alloc]init];
	//[self.navigationController pushViewController:moreController animated:YES];
	
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:LoadingMessage];
	NSArray *modulesArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"TabBarModulesArray"];
	NSUInteger tabIndex = [modulesArray indexOfObject:@"Approvals_Module"];
	[[[UIApplication sharedApplication] delegate] performSelector: @selector(flipToTabbarController:) 
													   withObject:[NSNumber numberWithUnsignedInteger:tabIndex]];
}

- (void)moreAction {
	//MoreViewController *moreController=[[MoreViewController alloc]init];
	//[self.navigationController pushViewController:moreController animated:YES];
	
	NSArray *modulesArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"TabBarModulesArray"];
	NSUInteger tabIndex = [modulesArray indexOfObject:@"More_Settings"];
	[[[UIApplication sharedApplication] delegate] performSelector: @selector(flipToTabbarController:) 
													   withObject:[NSNumber numberWithUnsignedInteger:tabIndex]];
}

- (void)timeSheetAction{
	
	actionType = ActionType_TimesheetList;
	BOOL activitiesEnabled = [self userPreferenceSettings:@"ActivitiesEnabled"];
	G2PermissionsModel *permissionsModel = [[G2PermissionsModel alloc] init];
	BOOL lockedinout = [permissionsModel checkUserPermissionWithPermissionName:@"LockedInOutTimesheet"];
    //BOOL inOut = [permissionsModel checkUserPermissionWithPermissionName:@"InOutTimesheet"];
    BOOL mobileLockedInOutTimesheet   = [permissionsModel checkUserPermissionWithPermissionName:@"MobileLockedInOutTimesheet"];
	NSString *msg = nil;
	@try {
		if ([NetworkMonitor isNetworkAvailableForListener:self] == YES) {
			
            if (lockedinout && !isLockedTimeSheet)
            {
                 RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
                if (!mobileLockedInOutTimesheet) {
                     msg=RPLocalizedString(@"You do not have permission to use the mobile Locked In/Out timesheet.  Please contact your Replicon administrator to have this permission enabled.","");//US4337//Juhi
                    appDelegate.isLockedTimeSheet=FALSE;
                }
                else
                {
                     msg=RPLocalizedString(@"The Replicon Mobile app does not support Locked In/Out timesheets with required fields.  Please enter time in Replicon through a browser.","");//US4337//Juhi
                     appDelegate.isLockedTimeSheet=FALSE;
                }
               
            }
            
            if(msg == nil){
                activitiesEnabled = [self userPreferenceSettings:@"ActivitiesEnabled"];
                BOOL timesheetactivityselection = [permissionsModel checkUserPermissionWithPermissionName:@"TimesheetActivityRequired"];
                
                if (activitiesEnabled && timesheetactivityselection ) {
                    //msg = @"Activities are currently not supported in the Replicon Mobile app.  Please log in to Replicon through a browser to enter time.";
                }		
            }				
			if(msg != nil){
                //Show alert...
				[G2Util errorAlert: @"" errorMessage: msg];
				return;
			}
			
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
             [[NSNotificationCenter defaultCenter] removeObserver: self name: @"allTimesheetRequestsServed" object: nil];
			[[NSNotificationCenter defaultCenter] addObserver: self 
													 selector: @selector(handleProcessCompleteActions) 
														 name: @"allTimesheetRequestsServed"
													   object: nil];
			[[G2RepliconServiceManager timesheetService] fetchTimeSheetData:nil];
			
		}else {
			//Calling the below method to show Timesheets in offline mode.
#ifdef PHASE1_US2152
			[G2Util showOfflineAlert];
			return;
#endif
			[self handleProcessCompleteActions];
			//[[RepliconServiceManager timesheetService] showListOfTimesheets];
		}		
	}
	@finally {
		 permissionsModel = nil;
	}
}
-(void)showListOfExpensesheets {
	NSArray *modulesArray = [[NSUserDefaults standardUserDefaults] objectForKey: @"TabBarModulesArray"];
	//NSNumber *tabIndex = [supportedModules objectForKey: @"Expenses_Module"];
	int expensesTabIndex = -1;
	
	for (int i=0; i < [modulesArray count]; ++i) {
		if ([[modulesArray objectAtIndex: i] isEqualToString: @"Expenses_Module"]) {
			expensesTabIndex = i;
		}
	}
	if (expensesTabIndex == -1) {
		DLog(@"Error: Expenses Tab Index cannot be -1");
		return;
	}
	
	[[[UIApplication sharedApplication]delegate]performSelector:@selector(flipToTabbarController:) 
													 withObject: [NSNumber numberWithInt: expensesTabIndex]];
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
}

#pragma mark -
#pragma mark ServerProtocolMethods
#pragma mark -

//Supoorting Data

/*-(void)handleSystemPreferencesResponse:(id) response {
 [supportDataModel insertSystemPreferencesToDatabase:response];
 //Get Enabled Fields
 [[NSUserDefaults standardUserDefaults] setObject:[supportDataModel getEnabledSystemPreferences] forKey:@"EnabledSystemPreferences"];
 
 }
 
 -(void)handleBaseCurrenciesResponse:(id) response {
 
 [supportDataModel insertBaseCurrencyToDatabase:response];
 
 
 }*/


#pragma mark -
#pragma mark NetworkMonitor related
- (void) networkActivated {
	
	[self expensesButton];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    self.timeSheetButton=nil;
    self.timeOffButton=nil;
    self.expensesButton=nil;
    self.moreButton=nil;
    self.tnewTimeEntryButton=nil;
    
}


-(void)addBadgeButtonWithNumbers:(int)numberOfPendingTS xorigin:(float)xorigin yorigin:(float)yorigin
{
    [self.badgeButton removeFromSuperview];
    
    if (numberOfPendingTS>0) {
        UIButton *customBadgeButton =[UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *normalImg =nil;
        if (numberOfPendingTS<10) {
            normalImg = [G2Util thumbnailImage:G2badge_single];
            [customBadgeButton setFrame:CGRectMake(xorigin+50.0, yorigin+5.0,normalImg.size.width, normalImg.size.height)];
             customBadgeButton.titleEdgeInsets = UIEdgeInsetsMake(-4.25, 0, 0.0, 0);
        }
        else if (numberOfPendingTS<100) {
            normalImg = [G2Util thumbnailImage:badge_double];
            [customBadgeButton setFrame:CGRectMake(xorigin+45.0, yorigin+5.0,normalImg.size.width, normalImg.size.height)];
           customBadgeButton.titleEdgeInsets = UIEdgeInsetsMake(-4.25, 2, 0, 0);
        }
        else
        {
            normalImg = [G2Util thumbnailImage:badge_triple];
            [customBadgeButton setFrame:CGRectMake(xorigin+40.0, yorigin+5.0,normalImg.size.width, normalImg.size.height)];
             customBadgeButton.titleEdgeInsets = UIEdgeInsetsMake(-4.25, 2, 0, 0);
        }

        
        
        
        [customBadgeButton setBackgroundImage:normalImg forState:UIControlStateNormal];
        [customBadgeButton setBackgroundImage:normalImg forState:UIControlStateHighlighted];
        [customBadgeButton setTitle:[NSString stringWithFormat:@"%d",numberOfPendingTS] forState:UIControlStateNormal];
        [customBadgeButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]];
        self.badgeButton=customBadgeButton;
        [self.view addSubview:self.badgeButton];
    }
}



@end


