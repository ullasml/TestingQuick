//
//  ApprovalsScrollViewController.m
//  Replicon
//
//  Created by Dipta Rakshit on 2/8/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "G2ApprovalsScrollViewController.h"
#import "G2Constants.h"
#import "G2ViewUtil.h"
#import "RepliconAppDelegate.h"
#import "G2ApprovalsNavigationController.h"

@implementation G2ApprovalsScrollViewController

@synthesize numberOfViews;
@synthesize addDescriptionViewController;
@synthesize  mainScrollView;
@synthesize currentViewIndex;
@synthesize listOfItemsArr;
@synthesize hasPreviousTimeSheets;
@synthesize hasNextTimeSheets;
@synthesize  indexCount;
@synthesize allPendingTimesheetsArr;
@synthesize timeSheetobject;
@synthesize permissionSet;
@synthesize preferenceSet;

enum  {
	PREVIOUS_BUTTON_TAG,
	NEXT_BUTTON_TAG,
	
};

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]
	 removeObserver:self name:ALL_PENDING_APPROVAL_TIMESHEETS_ENTRIES_SERVED_NOTIFICATION object:nil];
    
    
    //DE5784
    [[NSNotificationCenter defaultCenter]removeObserver:self name:APPROVAL_TIMESHEET_DELETED_NOT_WAITINGFORAPPROVAL object:nil];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    [self.view setBackgroundColor:G2RepliconStandardBackgroundColor];
    
    
    
    [self refreshScrollView];
    
    
        
    
    
    

   

    
    
    [G2ViewUtil setToolbarLabel: self withText: RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle)];
}


-(void)refreshScrollView
{
    if (self.mainScrollView) {
        [self.mainScrollView    removeFromSuperview];
        self.mainScrollView=nil;
    }
    

    
    UIScrollView *tempmainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.mainScrollView=tempmainScrollView;
    
    self.mainScrollView.pagingEnabled = YES;
    [self.view addSubview:self.mainScrollView];
    
    for (int i = 0; i < numberOfViews; i++) {
        G2ApprovalsUsersListOfTimeEntriesViewController *approvalsListOftimeEntriesCtrl=[[G2ApprovalsUsersListOfTimeEntriesViewController alloc]init];
        if ([listOfItemsArr count]>0) 
        {
            NSDictionary *dict=[self.listOfItemsArr objectAtIndex:i];
            
            approvalsListOftimeEntriesCtrl.timeSheetObj=[dict objectForKey:@"TIMESHEETOBJ"];
            
            approvalsListOftimeEntriesCtrl.permissionsObj=[dict objectForKey:@"PERMISSIONOBJ"];
            approvalsListOftimeEntriesCtrl.preferencesObj=[dict objectForKey:@"PREFERENCEOBJ"];
            
            approvalsListOftimeEntriesCtrl.currentViewTag=self.indexCount;
           
            [approvalsListOftimeEntriesCtrl setCurrentNumberOfView:self.indexCount+1 ];//US4637//Juhi
            [approvalsListOftimeEntriesCtrl setTotalNumberOfView:[self.allPendingTimesheetsArr count]];//US4637//Juhi
           
            approvalsListOftimeEntriesCtrl.delegate=self;
          
            
           
        }
        

        CGFloat yOrigin = i * self.view.frame.size.width;
        UIView *timeEntryListView = approvalsListOftimeEntriesCtrl.view;
        timeEntryListView.frame=CGRectMake(yOrigin, 0, self.view.frame.size.width, self.view.frame.size.height);
        [self.mainScrollView addSubview:timeEntryListView];

        
    }
    
    self.mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width * numberOfViews, self.view.frame.size.height);
    
    CGPoint point=CGPointMake(self.view.frame.size.width *currentViewIndex, 0 );
    self.mainScrollView.contentOffset=point;

}

-(void)readjustScrollViewWithIndex:(NSInteger)index
{
    [self.allPendingTimesheetsArr removeObjectAtIndex:index];
    self.indexCount=index;
    
    if ([self.allPendingTimesheetsArr count]>0) {
        
        if (index==[self.allPendingTimesheetsArr count]) {
            self.indexCount=index-1;
        }
        
       else if ([self.allPendingTimesheetsArr count]==1) {
            self.indexCount=0;
        }
       

        [self updateTabBarItemBadge];

        
        [self fetchPendingTimeEntries];
    }
    else
    {
          [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
        RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
        if(!appDelegate.isLockedTimeSheet)
        {
           // [[[UIApplication sharedApplication]delegate]performSelector:@selector(flipToHomeViewController)]; 
            [self.navigationController popViewControllerAnimated:TRUE];
            
        }
        else
        {
            [self.navigationController popViewControllerAnimated:TRUE];
        }
      
      
       
    }
    
     
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:YES];
    
}

-(void)viewDidAppear:(BOOL)animated{
	[super viewWillAppear:YES];
    [self performSelector:@selector(delayNextScreenAnimation) withObject:nil afterDelay:0.2];
    
}


-(void)delayNextScreenAnimation
{

     [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];

}




- (void)handleApproverCommentsForSelectedUser:(G2ApprovalsUsersListOfTimeEntriesViewController *)approvalsUsersListOfTimeEntriesViewController
{
    G2AddDescriptionViewController *tempaddDescriptionViewController = [[G2AddDescriptionViewController alloc] init];
    self.addDescriptionViewController=tempaddDescriptionViewController;
    
    [addDescriptionViewController setViewTitle:RPLocalizedString(TimeEntryComments,@"")];
    [addDescriptionViewController setTimeEntryParentController:self];
    
    G2ApprovalTablesFooterView *approvalTablesfooterView=nil;
   
    for (int i = 0; i < [[approvalsUsersListOfTimeEntriesViewController.timeEntriesTableView.tableFooterView subviews] count]; i++ ) 
    {
        if( [[[approvalsUsersListOfTimeEntriesViewController.timeEntriesTableView.tableFooterView subviews] objectAtIndex:i] isKindOfClass:[G2ApprovalTablesFooterView class] ] )
        {
            approvalTablesfooterView = (G2ApprovalTablesFooterView *)[[approvalsUsersListOfTimeEntriesViewController.timeEntriesTableView.tableFooterView subviews] objectAtIndex:i];
            break;
        }
    }
    if (approvalTablesfooterView) {
        [addDescriptionViewController setDescTextString: approvalTablesfooterView.commentsTextView.text];
    }
    
    [addDescriptionViewController setFromTimeEntryComments:NO];
    [addDescriptionViewController setFromTimeEntryUDF:NO];
    [addDescriptionViewController setDescControlDelegate:approvalsUsersListOfTimeEntriesViewController];
    [self.navigationController pushViewController:addDescriptionViewController animated:YES];
    
}


- (void)handlePreviousNextButtonFromApprovalsListforViewTag:(NSInteger)currentViewtag forbuttonTag:(NSInteger)buttonTag
{
    
[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:LoadingMessage];
    
    if (buttonTag==PREVIOUS_BUTTON_TAG) 
    {
        DLog(@"PREVIOUS BUTTON CLICKED");
       
            self.indexCount=currentViewtag-1;
            
        
        
    }
    else if (buttonTag==NEXT_BUTTON_TAG) 
    {
        DLog(@"NEXT BUTTON CLICKED");
        
         self.indexCount=currentViewtag+1;

    }

    [self fetchPendingTimeEntries];    


   
}



-(void)fetchPendingTimeEntries
{
    NSMutableDictionary *userDict=[self.allPendingTimesheetsArr objectAtIndex: self.indexCount];
    
    G2ApprovalsModel *approvalModel=[[G2ApprovalsModel alloc]init];
    
    BOOL approvalSupportDataCanRun = [G2Util shallExecuteQuery:APPROVALS_SUPPORT_DATA_SERVICE_SECTION];
    
    if (approvalSupportDataCanRun==YES)
    {
        /*******Delete support data ie UDF preferences permissions*********/
        [approvalModel deleteAllRowsForApprovalUserDefinedFieldsTable];
        [approvalModel deleteAllRowsForApprovalUserPermissionsTable];
        [approvalModel deleteAllRowsForApprovalPreferencesTable];
    }

    NSMutableArray *userPermissionsArr=[approvalModel getUserPermissionsForUserID:[userDict objectForKey:@"user_identity"]];
    NSMutableArray *userPreferencesArr=[approvalModel getAllUserPreferencesForUserID:[userDict objectForKey:@"user_identity"]];
    NSArray *allUDFDetailsArray=[approvalModel getAllUdfDetails];
    
   
    
    BOOL userDataPresent=NO;
    if ((userPermissionsArr==nil || [userPermissionsArr count]==0)|| (userPreferencesArr==nil && [userPreferencesArr count]==0)||allUDFDetailsArray==nil)
    {
        userDataPresent=NO;
    }
    else
    {
        userDataPresent=YES;
    }

    
    
    NSMutableArray *timeEntriesArr=[approvalModel getTimeEntriesForSheetFromDB:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"identity"]] ];
    NSMutableArray *timeOffEntriesArr=[approvalModel getTimeOffsForSheetFromDB:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"identity"]] ];
    NSMutableArray *bookedTimeOffEntriesArr=[approvalModel getBookedTimeOffEntryForSheetWithOnlySheetIdentity:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"identity"]]   ];
   
    
    if ((([timeEntriesArr count]>0 && timeEntriesArr!=nil) || ([timeOffEntriesArr count]>0  && timeOffEntriesArr!=nil) ||  ([bookedTimeOffEntriesArr count]>0  && bookedTimeOffEntriesArr!=nil))&& userDataPresent==YES)
    {
        [self viewAllTimeEntriesScreen];
    }
    
    else 
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ALL_PENDING_APPROVAL_TIMESHEETS_ENTRIES_SERVED_NOTIFICATION object:nil];
        
         //DE5784
        [[NSNotificationCenter defaultCenter]removeObserver:self name:APPROVAL_TIMESHEET_DELETED_NOT_WAITINGFORAPPROVAL object:nil];
       
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(approvalTimesheetDeletedNotWaitingForApprovals) name:APPROVAL_TIMESHEET_DELETED_NOT_WAITINGFORAPPROVAL object:nil]; //DE5784
        
        [[NSNotificationCenter defaultCenter] 
         addObserver:self selector:@selector(viewAllTimeEntriesScreen) name:ALL_PENDING_APPROVAL_TIMESHEETS_ENTRIES_SERVED_NOTIFICATION object:nil];
        
        [[G2RepliconServiceManager approvalsService] fetchPendingApprovalsTimeSheetEntriesDataForSheetIdentityWithUserpermissionsAndPreferencesAndUdf:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"identity"]] andUserIdentity:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"user_identity"]] withDelegate: self];
        
//        [[RepliconServiceManager approvalsService] fetchPendingApprovalsTimeSheetEntriesDataForSheetIdentity:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"identity"]] andDelegate: self];
    }

}

//DE5784
-(void)approvalTimesheetDeletedNotWaitingForApprovals{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:APPROVAL_TIMESHEET_DELETED_NOT_WAITINGFORAPPROVAL object:nil];
    G2ApprovalsModel *approvalsModel = [[G2ApprovalsModel alloc] init]; 
    NSMutableDictionary *userDict=[self.allPendingTimesheetsArr objectAtIndex:self.indexCount];
    [approvalsModel deleteRowsForApprovalTimesheetsTableForSheetIdentity:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"identity"]]];
    
}

-(void)viewAllTimeEntriesScreen
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALL_PENDING_APPROVAL_TIMESHEETS_ENTRIES_SERVED_NOTIFICATION object:nil];
    
    
    
    NSUInteger count=[self.allPendingTimesheetsArr count];
    
    
    if (count>0) {
        
        
        NSInteger indexCountPostition=self.indexCount;
        

        NSMutableDictionary *userDict=[self.allPendingTimesheetsArr objectAtIndex:indexCountPostition];
        
        [self displayAllTimeSheetsBySheetID: userDict];
        
        
        
        [self  setIndexCount:indexCountPostition];
        [self setListOfItemsArr:[NSMutableArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:self.timeSheetobject,@"TIMESHEETOBJ",self.permissionSet,@"PERMISSIONOBJ",self.preferenceSet,@"PREFERENCEOBJ", nil]] ];
        
       
        
        
        
        
        if (indexCountPostition==0) {
            self.hasPreviousTimeSheets=FALSE;
        }
        else 
        {
            
            self.hasPreviousTimeSheets=TRUE;  
            
        }
        
        
        if (indexCountPostition==count-1 || count==0) {
            self.hasNextTimeSheets=FALSE;  
        }
        else 
        {
            self.hasNextTimeSheets=TRUE;  
        }
        
        [self refreshScrollView];
        
    }
 
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
}


-(void)displayAllTimeSheetsBySheetID:(NSDictionary *)sheetDict{
	

    

	G2ApprovalsModel *approvalsModel = [[G2ApprovalsModel alloc] init]; 
	
	
	
	
	NSMutableArray *userPermissions = [approvalsModel getAllEnabledUserPermissionsByUserID:[sheetDict objectForKey:@"user_identity"]];
	[[NSUserDefaults standardUserDefaults] setObject:userPermissions forKey:[NSString stringWithFormat: @"ApprovalsUserPermissionSet%@",[sheetDict objectForKey:@"user_identity"]]];
	[[NSUserDefaults standardUserDefaults] synchronize];
	BOOL againstProjects    = [self checkForPermissionExistence:@"ProjectTimesheet" :[sheetDict objectForKey:@"user_identity"]];
	BOOL notagainstProjects = [self checkForPermissionExistence:@"NonProjectTimesheet" :[sheetDict objectForKey:@"user_identity"]];
	BOOL unsubmitAllowed	   = [self checkForPermissionExistence:@"UnsubmitTimesheet" :[sheetDict objectForKey:@"user_identity"]];
	BOOL billingTimesheet   = [self checkForPermissionExistence:@"BillingTimesheet" :[sheetDict objectForKey:@"user_identity"]];
	BOOL allowComments	   = [self checkForPermissionExistence:@"AllowBlankResubmitComment" :[sheetDict objectForKey:@"user_identity"]];
    BOOL both=FALSE;
	if (againstProjects && notagainstProjects) {
		both = YES;
	}
	
	//TODO: Need to check for 'Activities Enabled' permission:DONE
	
    G2SupportDataModel *supportDataModel = [[G2SupportDataModel alloc] init];
	NSMutableArray *userPreferences = [supportDataModel getAllUserPreferences];
	[[NSUserDefaults standardUserDefaults] setObject:userPreferences forKey:[NSString stringWithFormat: @"ApprovalsUserPreferenceSettings%@",[sheetDict objectForKey:@"user_identity"]]];
	[[NSUserDefaults standardUserDefaults] synchronize];
	BOOL activitiesEnabled = [self userPreferenceSettings:@"ActivitiesEnabled" andUID:[sheetDict objectForKey:@"user_identity"]];
	BOOL useBillingInfo    = [self userPreferenceSettings:@"UseBillingInformation" andUID:[sheetDict objectForKey:@"user_identity"]];
    
	
	
    
//    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSString *hourFormat=nil;
    //    if (!appDelegate.isLockedTimeSheet) 
    //    {
    //        //TODO: Get User Preference for Time Format:DONE
    //        hourFormat = @"Decimal";
    //    }
    //    else
    //    {
    //        SupportDataModel *supportDataModel=[[SupportDataModel alloc]init];
    //        hourFormat = [supportDataModel getUserHourFormat];
    //
    //    }
    
    hourFormat = @"Decimal";
    
    G2Preferences *tempPreferenceObj=[[G2Preferences alloc]init];
    self.preferenceSet=tempPreferenceObj;
   
    
    G2PermissionSet *tempPermissionSet=[[G2PermissionSet alloc]init];
    self.permissionSet=tempPermissionSet;
    
    
	
	NSMutableArray *formatsArray = [supportDataModel getUserTimeSheetFormats];
   
	if (formatsArray != nil && [formatsArray count]> 0) {
		for (NSDictionary *formatDict in formatsArray) {
			if ([[formatDict objectForKey:@"preferenceName"] isEqualToString:@"Timesheet.DateFormat"]) {
				//self.dateformat = [formatDict objectForKey:@"preferenceValue"];
                [self.preferenceSet setDateformat:[formatDict objectForKey:@"preferenceValue"]];
			}
		}
	}
	//Create Preferences Object
	
	[self.preferenceSet setHourFormat:hourFormat];
	[self.preferenceSet setActivitiesEnabled:activitiesEnabled];
	[self.preferenceSet setUseBillingInfo:useBillingInfo];
	
	//Create Permission Object
	[self.permissionSet setProjectTimesheet:againstProjects];
	[self.permissionSet setNonProjectTimesheet:notagainstProjects];
	[self.permissionSet setUnsubmitTimeSheet:unsubmitAllowed];
	[self.permissionSet setBothAgainstAndNotAgainstProject:both];
	[self.permissionSet setAllowBlankResubmitComment:allowComments];
	[self.permissionSet setBillingTimesheet:billingTimesheet];
	
    
    
    G2TimeSheetObject *temptimesheetObj   = [[G2TimeSheetObject alloc] init];
    self.timeSheetobject=temptimesheetObj;
    
    
    self.timeSheetobject.userID=[sheetDict objectForKey:@"user_identity"];
    self.timeSheetobject.userFirstName=[sheetDict objectForKey:@"user_fname"];
    self.timeSheetobject.userLasttName=[sheetDict objectForKey:@"user_lname"];
    
    self.timeSheetobject.identity			= [sheetDict objectForKey:@"identity"];
    self.timeSheetobject.status				= [sheetDict objectForKey:@"approvalStatus"];
    self.timeSheetobject.approversRemaining = [[sheetDict objectForKey:@"approversRemaining"] boolValue];
    
    NSDate *startdate	= [G2Util convertStringToDate:[sheetDict objectForKey:@"startDate"]];
    NSDate *enddate		= [G2Util convertStringToDate:[sheetDict objectForKey:@"endDate"]];
    NSDate *duedate		= [G2Util convertStringToDate:[sheetDict objectForKey:@"dueDate"]];
    NSDate *effectivedate		= [G2Util convertStringToDate:[sheetDict objectForKey:@"effectiveDate"]];
    
    self.timeSheetobject.startDate  = startdate;
    self.timeSheetobject.endDate    = enddate;
    self.timeSheetobject.dueDate    = duedate ;
    self.timeSheetobject.effectiveDate    = effectivedate ;
    
    NSString *timeEntrytotalHrs                  = [approvalsModel getSheetTotalTimeHoursForSheetFromDB:[self.timeSheetobject identity] withFormat:hourFormat];
    
    NSDictionary *sheetDateRangeDict       = [approvalsModel getTimeSheetPeriodforSheetId:self.timeSheetobject.identity];
    
    NSString *sheetstartDate = @"";
    NSString *sheetEndDate   = @"";
    NSString *timeOffEntryTotalHrs = @"";
    
    if (sheetDateRangeDict != nil && [sheetDateRangeDict count] != 0) {
        sheetstartDate = [sheetDateRangeDict objectForKey:@"startDate"];
        sheetEndDate   = [sheetDateRangeDict objectForKey:@"endDate"];
        timeOffEntryTotalHrs = [approvalsModel getTotalBookedTimeOffHoursForSheetWith:sheetstartDate 
                                                                              endDate:sheetEndDate withFormat:hourFormat];
    }
    
    
    //    if (!appDelegate.isLockedTimeSheet) {
    //        timesheetObj.totalHrs   =[NSString stringWithFormat:@"%0.2f",[timeEntrytotalHrs floatValue]+[timeOffEntryTotalHrs floatValue]];
    //    }
    //    else
    //    {
    //        if ([hourFormat isEqualToString:@"Decimal"]) {
    //            timesheetObj.totalHrs   =[NSString stringWithFormat:@"%0.2f",[timeEntrytotalHrs floatValue]+[timeOffEntryTotalHrs floatValue]];
    //        }
    //        else
    //        {
    //           
    //            timesheetObj.totalHrs   =  [Util mergeTwoHourFormat:timeEntrytotalHrs andHour2:timeOffEntryTotalHrs];
    //        }
    //    }
    
    self.timeSheetobject.totalHrs   =[NSString stringWithFormat:@"%0.2f",[timeEntrytotalHrs floatValue]+[timeOffEntryTotalHrs floatValue]];
    
    
    //			if ( againstProjects == YES || both == YES) {
    //				NSMutableArray *_projects = [approvalsModel getEntryProjectNamesForSheetFromDB:[timesheetObj identity]];
    //				if (_projects!= nil && [_projects count] >0) {
    //					NSMutableArray *projNameList = [NSMutableArray array];
    //					for (int i=0; i<[_projects count]; i++) {
    //						[projNameList addObject: [[_projects objectAtIndex: i]objectForKey: @"projectName"]];
    //						//[timesheetObj.projects addObject:[[_projects objectAtIndex:i]objectForKey:@"projectName"]];
    //					}
    //					[timesheetObj setProjects: projNameList];
    //				}
    //			}
    //            else if (notagainstProjects == YES) {
    //				if (activitiesEnabled) {
    //					NSMutableArray *_activities = [approvalsModel getEntryActivitiesForSheetFromDB:[timesheetObj identity]];
    //					if (_activities!= nil && [_activities count] >0) {
    //						NSMutableArray *activitiesNameList = [NSMutableArray array];
    //						for (int i=0; i<[_activities count]; i++) {
    //							//[timesheetObj.activities addObject:[[_activities objectAtIndex:i]objectForKey:@"activityName"]];
    //							[activitiesNameList addObject: [[_activities objectAtIndex: i]objectForKey: @"activityName"]];
    //						}
    //						[timesheetObj setActivities: activitiesNameList];
    //					}
    //					
    //
    //				}	
    //			}
    
    
    
    
    BOOL isClassicTimesheet= [approvalsModel checkUserPermissionWithPermissionName:@"ClassicTimesheet" andUserId:[sheetDict objectForKey:@"user_identity"]];
    BOOL isInOutTimesheet= [approvalsModel checkUserPermissionWithPermissionName:@"InOutTimesheet" andUserId:[sheetDict objectForKey:@"user_identity"]];
     BOOL isNewInOut = [approvalsModel checkUserPermissionWithPermissionName:@"NewInOutTimesheet" andUserId:[sheetDict objectForKey:@"user_identity"]];
    //------------------------- US4434 Ullas M L---------------------------
        
    BOOL lockedinout = [approvalsModel checkUserPermissionWithPermissionName:@"LockedInOutTimesheet" andUserId:[sheetDict objectForKey:@"user_identity"]];
    int countPermissions=0;
    if (isClassicTimesheet) 
    {
        countPermissions++;
    }
    if (isInOutTimesheet) 
    {
        countPermissions++;
    }
    if (isNewInOut) 
    {
        countPermissions++;
    }
    if (lockedinout) 
    {
        countPermissions++;
    }

    if (countPermissions>1) 
    {
        
        if (lockedinout) 
        {
            self.timeSheetobject.timeSheetType=APPROVAL_TIMESHEET_TYPE_LOCKEDINOUT;
        }
        else
        {
            NSMutableArray *checkUserPreferencesArr=[approvalsModel getAllUserPreferencesForUserID:[NSString stringWithFormat:@"%@", [sheetDict objectForKey:@"user_identity"]]];
            
            for (int arrCount=0; arrCount<[checkUserPreferencesArr count]; arrCount++) {
                DLog(@"%d",arrCount);
                NSDictionary *eachPreferenceDict=[checkUserPreferencesArr objectAtIndex:arrCount];
                if ([[eachPreferenceDict objectForKey:@"preferenceName"] isEqualToString:@"Timesheet.Format"]) 
                {
                    
                    if ([[eachPreferenceDict objectForKey:@"preferenceValue"] isEqualToString:InOut_Type_TimeSheet]) 
                    {
                        self.timeSheetobject.timeSheetType=APPROVAL_TIMESHEET_TYPE_INOUT;
                    }
                    else if ([[eachPreferenceDict objectForKey:@"preferenceValue"] isEqualToString:New_InOut_Type_TimeSheet])
                    {
                        self.timeSheetobject.timeSheetType=APPROVAL_TIMESHEET_TYPE_INOUT;
                    }
                    else
                    {
                        self.timeSheetobject.timeSheetType=APPROVAL_TIMESHEET_TYPE_STANDARD;
                    }
                     break;
                }

               
            }
        }
        //---------------------------------------------------------------------
    } 
    else
    {
        if (isClassicTimesheet && isInOutTimesheet) {
            
            NSMutableArray *checkUserPreferencesArr=[approvalsModel getAllUserPreferencesForUserID:[NSString stringWithFormat:@"%@", [sheetDict objectForKey:@"user_identity"]]];
            
            for (int arrCount=0; arrCount<[checkUserPreferencesArr count]; arrCount++) {
                NSDictionary *eachPreferenceDict=[checkUserPreferencesArr objectAtIndex:arrCount];
                if ([[eachPreferenceDict objectForKey:@"preferenceName"] isEqualToString:@"Timesheet.Format"]) 
                {
                    if ([[eachPreferenceDict objectForKey:@"preferenceValue"] isEqualToString:Classic2_Type_TimeSheet]) 
                    {
                        self.timeSheetobject.timeSheetType=APPROVAL_TIMESHEET_TYPE_STANDARD;
                    }
                    else if ([[eachPreferenceDict objectForKey:@"preferenceValue"] isEqualToString:InOut_Type_TimeSheet]) 
                    {
                        self.timeSheetobject.timeSheetType=APPROVAL_TIMESHEET_TYPE_INOUT;
                    }
                    break;
                }
                
                
                
            }
        }
        else if (isClassicTimesheet) 
        {
            self.timeSheetobject.timeSheetType=APPROVAL_TIMESHEET_TYPE_STANDARD;
        }
        else if (isInOutTimesheet) 
        {
            self.timeSheetobject.timeSheetType=APPROVAL_TIMESHEET_TYPE_INOUT;
        }
        else if (isNewInOut) 
        {
            self.timeSheetobject.timeSheetType=APPROVAL_TIMESHEET_TYPE_INOUT;
        }
        else
        {
            self.timeSheetobject.timeSheetType=APPROVAL_TIMESHEET_TYPE_LOCKEDINOUT;
        }

    }
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    appDelegate.userType=self.timeSheetobject.timeSheetType;
	
}

- (void)pushToTomeEntryViewController:(id)timeEntryViewController
{
    
    [self.navigationController pushViewController:timeEntryViewController animated:YES];
}

-(BOOL)checkForPermissionExistence:(NSString *)_permission :(NSString *)userID{
	NSMutableArray *permissionlist = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat: @"ApprovalsUserPermissionSet%@",userID]];
	if (_permission != nil) {
		for (int i=0; i<[permissionlist count]; i++) {
			if ([permissionlist containsObject:_permission]) {
				return YES;
			}
		}
	}
	return NO;
}

-(BOOL)userPreferenceSettings:(NSString *)_preference andUID:(NSString *)userID
{
	NSMutableArray *preferences = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat: @"ApprovalsUserPreferenceSettings%@",userID]];
	if (_preference != nil) {
		for (int i=0; i<[preferences count]; i++) {
			if ([preferences containsObject:_preference]) {
				return YES;
			}
		}
	}
	return NO;
	
}


/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 }
 */


-(void)updateTabBarItemBadge
{
    
    for (int i=0; i<[self.tabBarController.viewControllers count]; i++)
    {
        if ([[self.tabBarController.viewControllers objectAtIndex:i] isKindOfClass:[G2ApprovalsNavigationController class]]) 
        {
            
            G2ApprovalsNavigationController *navCtrl=(G2ApprovalsNavigationController *)[self.tabBarController.viewControllers objectAtIndex:i];
            NSUInteger count=[self.allPendingTimesheetsArr count];
            
            int badgeValue=[[[NSUserDefaults standardUserDefaults] objectForKey:@"NumberOfTimesheetsPendingApproval"] intValue];
            
            if (count>0)
            {
                if (count>badgeValue)
                {
                    navCtrl.tabBarItem.badgeValue=[NSString stringWithFormat:@"%lu", (unsigned long)count];
                    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%lu", (unsigned long)count] forKey:@"NumberOfTimesheetsPendingApproval"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                else
                {
                     navCtrl.tabBarItem.badgeValue=[NSString stringWithFormat:@"%d", badgeValue];
                }
            }
            
            else
            {
                navCtrl.tabBarItem.badgeValue=nil; 
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", 0] forKey:@"NumberOfTimesheetsPendingApproval"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }                   
            
            
            break;
        }
    }
    
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return NO;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.addDescriptionViewController=nil;
    self.mainScrollView=nil;
}



@end
