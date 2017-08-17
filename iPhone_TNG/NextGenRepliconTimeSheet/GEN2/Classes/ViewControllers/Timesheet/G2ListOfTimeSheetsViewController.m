//
//  ListOfTimeSheetsViewController.m
//  Replicon
//
//  Created by Hepciba on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2ListOfTimeSheetsViewController.h"
#import "G2ViewUtil.h"
#import "RepliconAppDelegate.h"

@implementation G2ListOfTimeSheetsViewController
@synthesize timeSheetsTableView;
@synthesize leftButton;
@synthesize footerView;
@synthesize imageView;
@synthesize timeSheetsArray;
//@synthesize timesheetModel;
@synthesize againstProjects;
@synthesize both;
@synthesize notagainstProjects;
@synthesize activitiesEnabled;
@synthesize hourFormat;
@synthesize allowComments;
@synthesize unsubmitAllowed;
@synthesize billingTimesheet;
@synthesize useBillingInfo;
@synthesize rowTapped;
@synthesize dateformat;
@synthesize  rowIndex;
@synthesize  timeEntriesViewController;
@synthesize  navcontroller;
@synthesize  moreButton;
@synthesize  addNewTimeEntryViewController;
@synthesize permissionsetObj,preferenceSet;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id) init
{
	self = [super init];
	if (self != nil) {
		if (timeSheetsArray == nil) {
			NSMutableArray *temptimeSheetsArray = [[NSMutableArray alloc] init];
            self.timeSheetsArray=temptimeSheetsArray;
           
		}
		
//		if (timesheetModel == nil) {
//			timesheetModel = [[TimesheetModel alloc] init];
//		}
//		if (permissionsModel == nil) {
//			permissionsModel = [[PermissionsModel alloc]init];
//		}
//		if (supportDataModel == nil) {
//			supportDataModel = [[SupportDataModel alloc] init];
//		}
		if (permissionsetObj == nil) {
			G2PermissionSet *temppermissionsetObj = [[G2PermissionSet alloc] init];
            self.permissionsetObj=temppermissionsetObj;
            
		}
		if (preferenceSet == nil) {
			G2Preferences *temppreferenceSet = [[G2Preferences alloc] init];
            self.preferenceSet=temppreferenceSet;
            
		}
	}
	return self;
}
#pragma mark -
#pragma mark View lifeCycle Methods
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView { 
	[super loadView];
	[self.view setBackgroundColor:G2RepliconStandardBackgroundColor];
	
	//1.Add TimeSheetsTableView
	if (timeSheetsTableView==nil) {
		UITableView *temptimeSheetsTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-93.0) style:UITableViewStylePlain];
		self.timeSheetsTableView=temptimeSheetsTableView;
        self.timeSheetsTableView.separatorColor = [UIColor clearColor];
        
	}
	timeSheetsTableView.delegate=self;
	timeSheetsTableView.dataSource=self;
	[self.view addSubview:timeSheetsTableView];
	UIView *bckView = [UIView new];
	[bckView setBackgroundColor:G2RepliconStandardBackgroundColor];
	[timeSheetsTableView setBackgroundView:bckView];
	
	
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];

    
     if (!appDelegate.isLockedTimeSheet) 
     {
    
         UIImage *homeButtonImage=[G2Util thumbnailImage:G2HomeTransparentButtonImage];
         UIButton *homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
         [homeButton setFrame:CGRectMake(0.0, 0.0, homeButtonImage.size.width, homeButtonImage.size.height)];
         [homeButton setImage:homeButtonImage forState:UIControlStateNormal];
         [homeButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
         
         UIBarButtonItem *templeftButton = [[UIBarButtonItem alloc]initWithCustomView:homeButton];
         self.leftButton=templeftButton;
         [self.navigationItem setLeftBarButtonItem:self.leftButton animated:NO];
        
         
         UIImage *homeButtonImage1=[G2Util thumbnailImage:G2HomeTransparentButtonImage];
         //UIButton *homeButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
         //[homeButton1 setFrame:CGRectMake(0.0, 0.0, homeButtonImage1.size.width, homeButtonImage1.size.height)];
         //[homeButton1 setImage:homeButtonImage1 forState:UIControlStateNormal];
         //[homeButton1 addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
         UIBarButtonItem *templeftButton1 = [[UIBarButtonItem alloc]initWithImage:homeButtonImage1 style:UIBarButtonItemStylePlain
                                                                           target:self action:@selector(goBack:)];
         self.leftButton=templeftButton1;
         [self.navigationItem setLeftBarButtonItem: self.leftButton animated:NO];
         
         
         UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                    target:self
                                                                                    action:@selector(addTimeEntryAction:)];
         [self.navigationItem setRightBarButtonItem:addButton animated:NO];
        
        
     }
    //FOR LOCKED IN OUT USER
     else 
     {
         if (appDelegate.isTimeOffEnabled) 
         {
             
             UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                        target:self
                                                                                        action:@selector(addTimeEntryAction:)];
             [self.navigationItem setRightBarButtonItem:addButton animated:NO];
             
         }
     }
    
    
    
	
	
	
	//2.Add Footer View
	UIView *tempfooterView=[[UIView alloc]initWithFrame:CGRectMake(0.0, 50.0, self.timeSheetsTableView.frame.size.width, 250.0)];
    self.footerView=tempfooterView;
   
	[footerView setBackgroundColor:RepliconStandardClearColor];
	 self.moreButton=[UIButton buttonWithType:UIButtonTypeCustom];
	[ self.moreButton setBackgroundColor:[UIColor clearColor]];
	UIImage *moreButtonImage=[G2Util thumbnailImage:G2MoreButtonIMage];
	
    // Let's make an NSAttributedString first
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:RPLocalizedString(MoreText,@"")];
    //Add LineBreakMode
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setLineBreakMode:NSLineBreakByClipping];
    [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
    // Add Font
    [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]} range:NSMakeRange(0, attributedString.length)];
    
    //Now let's make the Bounding Rect
    CGSize expectedLabelSize = [attributedString boundingRectWithSize:CGSizeMake(280, moreButtonImage.size.height+10) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    float totalSize=expectedLabelSize.width+10+moreButtonImage.size.width+1.0;
    int xOrigin=(320.0-totalSize)/2;
    [self.moreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
	[ self.moreButton setFrame:CGRectMake(xOrigin, 30, expectedLabelSize.width+10.0,moreButtonImage.size.height+10 )];
	[ self.moreButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
	[ self.moreButton setTitleColor:RepliconStandardBlackColor forState:UIControlStateNormal];
	[ self.moreButton setTitle:RPLocalizedString(MoreText,@"") forState:UIControlStateNormal];
	[ self.moreButton addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
	[ self.moreButton setHidden: NO];
	
	UIImageView *tempimageView = [[UIImageView alloc]init];
	[tempimageView setImage:moreButtonImage];
	[tempimageView setFrame:CGRectMake(self.moreButton.frame.origin.x+expectedLabelSize.width+10.0+1.0,35, moreButtonImage.size.width, moreButtonImage.size.height)];
	[tempimageView setBackgroundColor:[UIColor clearColor]]; 
	[imageView setHidden: NO];
	[footerView addSubview:self.moreButton];
	[footerView addSubview:tempimageView];
    footerView.frame=CGRectMake(0.0, 0.0, self.timeSheetsTableView.frame.size.width, moreButtonImage.size.height+10+60.0);
   
    self.imageView=tempimageView;
   
    
	[self.timeSheetsTableView setTableFooterView:footerView];
	
    
	
	[G2ViewUtil setToolbarLabel: self withText: RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle)];
	//[self.navigationController.navigationBar setTintColor:RepliconStandardNavBarTintColor];
    
        
}

-(void)viewWillAppear:(BOOL)animated{
	//[self parseAllTimeSheetsResponse:nil];
	[super viewWillAppear:YES];
	//[self displayAllTimeSheets];
	
	//if ([timeSheetsArray count]>0) {
	//	[moreButton setHidden:NO];
	//	[imageView setHidden:NO];
	//}
	[self performSelector: @selector(hideMoreButton:) withObject:nil];
	//[self.timeSheetsTableView reloadData];
	[self performSelector:@selector(highlightTheCellWhichWasSelected) withObject:nil afterDelay:0];
	//[self performSelector:@selector(deSelectTappedRow) withObject:nil afterDelay:0.5];//DE2949 FadeOut is slow
    [self performSelector:@selector(deSelectTappedRow) withObject:nil afterDelay:0.0];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];
}


#pragma mark -
#pragma mark - UITableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return Each_Cell_Row_Height_58;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [timeSheetsArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	static NSString *CellIdentifier = @"TimeSheetCellIdentifier";
	
	cell = (G2CustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
	cell = [[G2CustomTableViewCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		
	cell.backgroundView          = [[UIImageView alloc] init];
	//cell.selectedBackgroundView  = [[UIImageView alloc] init];
	
	UIImage *rowBackground       = [G2Util thumbnailImage:cellBackgroundImageView];
	((UIImageView *)cell.backgroundView).image = rowBackground;
	
	
	}
	NSString		*dueStatus =@"";
	NSString		*date = @"";
	NSDate			*dueDate=nil;
	NSString		*statusString=@"";
	NSString		*totalhrs = @"";
//	NSMutableString *clientProjectTaskString = [NSMutableString string];
	UIColor			*statusColor = nil;
	UIColor			*upperrighttextcolor = nil;
	BOOL			Imgflag = NO;
	if ([timeSheetsArray count]>0) {
		NSInteger i =  indexPath.row;
		self.rowIndex = indexPath;
		
		NSString *startDt = [G2Util convertPickerDateToStringShortStyle:[[timeSheetsArray objectAtIndex:i]startDate]];
		NSString *endDt = [G2Util convertPickerDateToStringShortStyle:[[timeSheetsArray objectAtIndex:i]endDate]];
		date = [NSString stringWithFormat:@"%@ - %@",startDt,endDt];
        
        
        G2TimeSheetObject *timeSheetObject=[timeSheetsArray objectAtIndex:i];
        
		if ([[timeSheetObject status]isEqualToString:NOT_SUBMITTED_STATUS]) {
			NSDate *currentDate= [NSDate date];
			dueDate = [[timeSheetsArray objectAtIndex:i]dueDate];
			if([[dueDate earlierDate:currentDate] isEqualToDate:dueDate]){
				statusColor= RejectedTextColor;
			}else{
				statusColor= NotSubmittedTextColor;
			}
			dueStatus = [NSString stringWithString:RPLocalizedString(@"DUE", @"DUE")];
			NSString *dueDt = [G2Util convertPickerDateToStringShortStyle:[[timeSheetsArray objectAtIndex:i]dueDate]];
			statusString =[NSString stringWithFormat:@"%@ %@",dueStatus,dueDt];
		}else if ([[timeSheetObject status]isEqualToString:G2WAITING_FOR_APRROVAL_STATUS]) {
			statusColor= WaitingTextColor;
			statusString =RPLocalizedString(G2WAITING_FOR_APRROVAL_STATUS,@"Waiting for Approval status message");
		}else if ([[timeSheetObject status]isEqualToString:REJECTED_STATUS]) {
			statusColor= RejectedTextColor;
			statusString =RPLocalizedString(REJECTED_STATUS,@"Rejected status message");
		}else if ([[timeSheetObject status]isEqualToString:APPROVED_STATUS]) {
			statusColor= ApprovedTextColor;
			statusString =RPLocalizedString(APPROVED_STATUS,@"Approved status message");
		}
//		if ( againstProjects == YES || both == YES) {
//			clientProjectTaskString = [self getProjectActivityList:[[timeSheetsArray objectAtIndex:i]projects]];
//		}else if (notagainstProjects == YES) {
//			clientProjectTaskString = [self getProjectActivityList:[[timeSheetsArray objectAtIndex:i]activities]];
//		}
		totalhrs = [[timeSheetsArray objectAtIndex:i]totalHrs];
		
		[cell createCellLayoutWithParams:date upperlefttextcolor:upperrighttextcolor 
						   upperrightstr:totalhrs lowerleftstr:@""  lowerlefttextcolor:RepliconStandardBlackColor lowerrightstr:statusString statuscolor:statusColor 
						   imageViewflag:Imgflag hairlinerequired:YES];
		[[cell upperLeft] setFrame:CGRectMake(12.0, 12.0, 210.0, 20.0)];
		[[cell upperRight]setFrame:CGRectMake(210.0, 12.0, 98.0, 20.0)];
		[[cell lowerRight] setFrame:CGRectMake(160.0, 35.0, 148.0, 14.0)];
	
	}
	[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
	return cell;
	
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)	{
		
		#ifdef PHASE1_US2152
			[G2Util showOfflineAlert];
			return;
		#endif
	}
	
	[self highlightTappedRowBackground:indexPath];
	[self setRowTapped:indexPath];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	G2ListOfTimeEntriesViewController *temptimeEntriesViewController =[[G2ListOfTimeEntriesViewController alloc]init];
    self.timeEntriesViewController=temptimeEntriesViewController;
   
	G2TimeSheetObject *timeSheetObject = [timeSheetsArray objectAtIndex:indexPath.row];
	
	NSDate   *startDt					 = [timeSheetObject startDate];
	NSString *convertedStartDt			 = [G2Util convertPickerDateToStringShortStyle:startDt];
	NSDate   *endDt						 = [timeSheetObject endDate];
	NSString *convertedEndDt			 = [G2Util convertPickerDateToStringShortStyle:endDt];
	NSArray  *startDateComponents        = [convertedStartDt componentsSeparatedByString:@","];
	NSString *trimmedStartDt			 = [startDateComponents objectAtIndex:0];
	
	NSArray  *endDateComponents          = [convertedEndDt componentsSeparatedByString:@","];
	NSString *trimmedEndDt			     = [endDateComponents objectAtIndex:0];
	
	NSString *sheetStatus				 = [[NSString alloc]initWithString: [timeSheetObject status]];
	NSString *selectedSheet				 = [NSString stringWithFormat:@"%@ - %@",trimmedStartDt,
								   trimmedEndDt];
	
	//Set TimeSheetObject
	[self.timeEntriesViewController setSelectedSheet:selectedSheet];
	[self.timeEntriesViewController setSheetApprovalStatus:sheetStatus];
	[self.timeEntriesViewController createTimeEntryObject:timeSheetObject 
											   permissions:permissionsetObj
											   preferences:preferenceSet];

	if ([self.timeEntriesViewController isEntriesAvailable]) {
		[self.navigationController pushViewController:self.timeEntriesViewController animated:YES];
		
	}
	else {
		[self.timeEntriesViewController setIsEntriesAvailable:NO];
		if ([sheetStatus isEqualToString:APPROVED_STATUS] || [sheetStatus isEqualToString:G2WAITING_FOR_APRROVAL_STATUS]) {
			[self.navigationController pushViewController:self.timeEntriesViewController animated:YES];
		}else {
			[self showAddNewTimeEntryPageByDefault:timeSheetObject :selectedSheet];
		}
	}

	
}

#pragma mark -
#pragma mark Timesheet Methods


  
	

-(void) showAddNewTimeEntryPageByDefault:(G2TimeSheetObject *)timeSheetObject :(NSString *)selectedSheet {
	
	G2SupportDataModel *supportdataModel = [[G2SupportDataModel alloc] init];
//	int userProjectsCount = [supportdataModel getUserProjectsCount];
     NSMutableArray *userActivities=[supportdataModel getUserActivitiesFromDatabase];
	
    //Fix for DE3600//Juhi
    againstProjects    = [self checkForPermissionExistence:@"ProjectTimesheet"];
    notagainstProjects = [self checkForPermissionExistence:@"NonProjectTimesheet"];
    BOOL timesheetRequired   = [self checkForPermissionExistence:@"TimesheetActivityRequired"];
    
//    if (againstProjects && !notagainstProjects && !(userProjectsCount > 0)){
//
//        [Util errorAlert:@"" errorMessage:RPLocalizedString(YouCannotEnterTimeBecauseNoProjectsAreAssignedToYou,@"")];//DE1231//Juhi
//        [self deSelectTappedRow];
//		return;
//    }
//    else if(timesheetRequired)
    if(timesheetRequired)
    {
        
        if ([userActivities count]==0  ) 
        {

            [G2Util errorAlert:@"" errorMessage:RPLocalizedString(YouCannotEnterTimeBecauseNoActivitiesAreAssignedToYou,@"")];//DE1231//Juhi
            return;
            
        }
        else
        {
            RepliconAppDelegate *appDelegate= (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
            G2TimeEntryViewController *tempaddNewTimeEntryViewController = [[G2TimeEntryViewController alloc] initWithEntryDetails:nil sheetId:[timeSheetObject identity] screenMode:ADD_TIME_ENTRY permissionsObj:permissionsetObj preferencesObj:preferenceSet:appDelegate.isInOutTimesheet:appDelegate.isLockedTimeSheet:self];
            self.addNewTimeEntryViewController=tempaddNewTimeEntryViewController;
            [addNewTimeEntryViewController setSelectedSheetIdentity:[timeSheetObject identity]];
            [addNewTimeEntryViewController setSheetStatus:[timeSheetObject status]];
            [addNewTimeEntryViewController setIsEntriesAvailable:NO];
            [addNewTimeEntryViewController setHidesBottomBarWhenPushed:YES];
            //[self.navigationController.navigationBar setTintColor:RepliconStandardNavBarTintColor];
            [self.navigationController pushViewController:addNewTimeEntryViewController animated:YES];
            
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newEntrySavedResponse) name:@"NEW_DIRECT_ENTRY_SAVED" object:nil];
        }
    }

    
	//TODO: If User projects Count > 0 then allow the user to enter time else no:DONE
//	if (userProjectsCount > 0) {
		/*
		addNewTimeEntryViewController = [[AddNewTimeEntryViewController alloc] init];
		[addNewTimeEntryViewController setSelectedTimeSheet:selectedSheet];
		[addNewTimeEntryViewController setSheetStatus:[timeSheetObject status]];
		[addNewTimeEntryViewController setSelectedSheetIdentity:[timeSheetObject identity]];
		[addNewTimeEntryViewController setIsEntriesAvailable:NO];
		[addNewTimeEntryViewController addTableHeader];
		[addNewTimeEntryViewController setScreenMode:ADD_TIME_ENTRY];
		[addNewTimeEntryViewController viewAddEditEachTimeEntryDetails:nil 
													 withpermissionSet:permissionsetObj 
													   withpreferences:preferenceSet];
		
		[addNewTimeEntryViewController setHidesBottomBarWhenPushed:YES];
		[self.navigationController.navigationBar setTintColor:RepliconStandardNavBarTintColor];
		[self.navigationController pushViewController:addNewTimeEntryViewController animated:YES];
		*/
//          }
            else
            {
                RepliconAppDelegate *appDelegate= (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
		G2TimeEntryViewController *tempaddNewTimeEntryViewController = [[G2TimeEntryViewController alloc] initWithEntryDetails:nil sheetId:[timeSheetObject identity] screenMode:ADD_TIME_ENTRY permissionsObj:permissionsetObj preferencesObj:preferenceSet:appDelegate.isInOutTimesheet:appDelegate.isLockedTimeSheet:self];
                self.addNewTimeEntryViewController=tempaddNewTimeEntryViewController;
		[addNewTimeEntryViewController setSelectedSheetIdentity:[timeSheetObject identity]];
		[addNewTimeEntryViewController setSheetStatus:[timeSheetObject status]];
		[addNewTimeEntryViewController setIsEntriesAvailable:NO];
		[addNewTimeEntryViewController setHidesBottomBarWhenPushed:YES];
		//[self.navigationController.navigationBar setTintColor:RepliconStandardNavBarTintColor];
		[self.navigationController pushViewController:addNewTimeEntryViewController animated:YES];
		
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newEntrySavedResponse) name:@"NEW_DIRECT_ENTRY_SAVED" object:nil];
	}
}
		
		
		
		
	



-(void)newEntrySavedResponse {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"NEW_ENTRY_SAVED" object:nil];
	NSMutableArray *arrayOfViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
	[arrayOfViewControllers removeObjectIdenticalTo:addNewTimeEntryViewController];
	[self.navigationController setViewControllers:arrayOfViewControllers];
	if (self.timeEntriesViewController !=nil) {
		//[arrayOfViewControllers addObject:expenseEntryViewController];
		if ([arrayOfViewControllers containsObject:self.timeEntriesViewController]) {
			[arrayOfViewControllers removeObjectIdenticalTo:self.timeEntriesViewController];
			[self.navigationController setViewControllers:arrayOfViewControllers];
			[self.navigationController pushViewController:self.timeEntriesViewController animated:NO];
		}else {
			[self.navigationController pushViewController:self.timeEntriesViewController animated:NO];
		}
	}
}

-(NSMutableString *)getProjectActivityList:(NSMutableArray *)_list{
	
	NSMutableString *list = [NSMutableString string];
	for (int i=0; i<[_list count]; i++) {
		if (![[_list objectAtIndex:i]isEqualToString: @""]) {
			[list appendString:[NSString stringWithFormat:@"%@",[_list objectAtIndex:i]]];
		}	
		if (!(i+1 ==[_list count])) {
			[list appendString:@","];
		}
	}
    if (![list isKindOfClass:[NSNull class] ]) 
    {
        if ([list length]>0) {
            return list;
        }
    }
	
	return nil;
}
#pragma mark -
#pragma mark Button ActionMethods



    
-(void)addTimeEntryAction:(id)sender
{

    RepliconAppDelegate *appDelegate= (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if (appDelegate.isLockedTimeSheet) {
        if (appDelegate.isTimeOffEnabled)
        {
            UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:nil message:nil
                                                                      delegate:self cancelButtonTitle:RPLocalizedString(CANCEL_BTN_TITLE, CANCEL_BTN_TITLE) otherButtonTitles:RPLocalizedString(NEW_TIME_ENTRY_TEXT, NEW_TIME_ENTRY_TEXT),RPLocalizedString(ADHOC_TIME_OFF_TEXT, ADHOC_TIME_OFF_TEXT),nil];
            
            [confirmAlertView setDelegate:self];
            [confirmAlertView setTag:9999];
            [confirmAlertView show];
            
        }
        
        
        else 
        {
            [self addNewTimeEntryActionFromAlert];
        }

    }
    
	else
    {
         [self addNewTimeEntryActionFromAlert];
    }
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==9999) 
    {
          RepliconAppDelegate *appDelegate= (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
        // FOR TIME ENTRY
        if (buttonIndex==1)
        {
            if (appDelegate.isLockedTimeSheet)
            {
                appDelegate.selectedTab=0;
                //[[RepliconServiceManager lockedInOutTimesheetService]  setIsFromNewPopUpForTimeOff:TRUE];
                [[[UIApplication sharedApplication] delegate] performSelector: @selector(flipToTabbarController:) 
                                                                   withObject:[NSNumber numberWithInt:0]];
            }
            
            else 
            {
                 [self addNewTimeEntryActionFromAlert];
            }
            
           
        }
        // FOR AD HOC TIME OFF
        else if (buttonIndex==2)
        {
            
          
            G2TimeEntryViewController *timeEntryViewController = [[G2TimeEntryViewController alloc] 
                                                                      initWithEntryDetails:nil sheetId:nil screenMode:ADD_ADHOC_TIMEOFF 
                                                                      permissionsObj:permissionsetObj preferencesObj:preferenceSet:appDelegate.isInOutTimesheet:appDelegate.isLockedTimeSheet:self];
            
            
            [timeEntryViewController setIsEntriesAvailable:YES];
            UINavigationController *tempnavcontroller = [[UINavigationController alloc]initWithRootViewController:timeEntryViewController];
            [tempnavcontroller.navigationBar setTintColor:RepliconStandardNavBarTintColor];
            [self presentViewController:tempnavcontroller animated:YES completion:nil];
            self.navcontroller=tempnavcontroller;
            
           
            
        }
    }
    
}


-(void)addNewTimeEntryActionFromAlert
{
    
    
    
    if (![NetworkMonitor isNetworkAvailableForListener:self]) {
#ifdef PHASE1_US2152
        [G2Util showOfflineAlert];
        return;
#endif
    }
    
    //Fix for DE3600//Juhi
    againstProjects    = [self checkForPermissionExistence:@"ProjectTimesheet"];
    notagainstProjects = [self checkForPermissionExistence:@"NonProjectTimesheet"];
    BOOL timesheetRequired   = [self checkForPermissionExistence:@"TimesheetActivityRequired"];
    
    G2SupportDataModel *supportdataModel = [[G2SupportDataModel alloc] init];
//    int userProjectsCount = [supportdataModel getUserProjectsCount];
    
    //DLog(@"Projects Count:::::%d",userProjectsCount);
    NSMutableArray *userActivities=[supportdataModel getUserActivitiesFromDatabase];
    
    
    
    //TODO: If User projects Count > 0 then allow the user to enter time else no:DONE
    //Fix for DE3600//Juhi
//    if (againstProjects && !notagainstProjects && !(userProjectsCount > 0)){
//        
//        [Util errorAlert:@"" errorMessage:RPLocalizedString(YouCannotEnterTimeBecauseNoProjectsAreAssignedToYou,@"")];//DE1231//Juhi
//        return;
//    }
//    
//    else if(timesheetRequired)
    if(timesheetRequired)
    {
        
        if ([userActivities count]==0  ) 
        {
            
            [G2Util errorAlert:@"" errorMessage:RPLocalizedString(YouCannotEnterTimeBecauseNoActivitiesAreAssignedToYou,@"")];//DE1231//Juhi
            return;
            
        }
        else
        {
            RepliconAppDelegate *appDelegate= (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
            G2TimeEntryViewController *tempaddNewTimeEntryViewController = [[G2TimeEntryViewController alloc] initWithEntryDetails:nil sheetId:nil screenMode:ADD_TIME_ENTRY permissionsObj:permissionsetObj preferencesObj:preferenceSet:appDelegate.isInOutTimesheet:appDelegate.isLockedTimeSheet:self];
            self.addNewTimeEntryViewController =tempaddNewTimeEntryViewController;
            [addNewTimeEntryViewController setIsEntriesAvailable:YES];
            UINavigationController *tempnavcontroller = [[UINavigationController alloc]initWithRootViewController:addNewTimeEntryViewController];
            //Fix for ios7//JUHI
            float version=[[UIDevice currentDevice].systemVersion floatValue];
            if (version>=7.0)
            {
                tempnavcontroller.navigationBar.translucent = FALSE;
                tempnavcontroller.navigationBar.barTintColor=RepliconStandardNavBarTintColor;
                tempnavcontroller.navigationBar.tintColor=RepliconStandardWhiteColor;
            }
            else
                tempnavcontroller.navigationBar.tintColor=RepliconStandardNavBarTintColor;

           
            [self presentViewController:tempnavcontroller animated:YES completion:nil];
            self.navcontroller=tempnavcontroller;
                    }
    }
    
    else {
        RepliconAppDelegate *appDelegate= (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
        G2TimeEntryViewController *tempaddNewTimeEntryViewController = [[G2TimeEntryViewController alloc] initWithEntryDetails:nil sheetId:nil screenMode:ADD_TIME_ENTRY permissionsObj:permissionsetObj 
                                                                                                            preferencesObj:preferenceSet:appDelegate.isInOutTimesheet:appDelegate.isLockedTimeSheet:self];
        self.addNewTimeEntryViewController =tempaddNewTimeEntryViewController;
        [addNewTimeEntryViewController setIsEntriesAvailable:YES];
        UINavigationController *tempnavcontroller = [[UINavigationController alloc]initWithRootViewController:addNewTimeEntryViewController];
        //Fix for ios7//JUHI
        float version=[[UIDevice currentDevice].systemVersion floatValue];
        if (version>=7.0)
        {
            tempnavcontroller.navigationBar.translucent = FALSE;
            tempnavcontroller.navigationBar.barTintColor=RepliconStandardNavBarTintColor;
            tempnavcontroller.navigationBar.tintColor=RepliconStandardWhiteColor;
        }
        else
            tempnavcontroller.navigationBar.tintColor=RepliconStandardNavBarTintColor;

        
        [self presentViewController:tempnavcontroller animated:YES completion:nil];
        self.navcontroller=tempnavcontroller;
       
        
        
    }	
    
    
}


    
	
	
		
		
	
		



-(void)moreAction:(id)sender{

	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
		#ifdef PHASE1_US2152
			[G2Util showOfflineAlert];
			return;
		#endif
	}
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
	int lastSheetIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:TIMESHEET_FETCH_START_INDEX] 
						  intValue];
	int nextSheetStartIndex = lastSheetIndex + 1;
	NSString *queryHandleIdentity = [[[ NSUserDefaults standardUserDefaults] objectForKey:@"TimeSheetQueryHandler"]objectForKey:@"Identity"];
	if (queryHandleIdentity != nil && ![queryHandleIdentity isKindOfClass:[NSNull class]]) {
		[[G2RepliconServiceManager timesheetService]sendRequestToFetchNextRecentTimeSheets:queryHandleIdentity
						withStartIndex:[NSNumber numberWithInt:nextSheetStartIndex] 
						countLimit:[[G2AppProperties getInstance]getAppPropertyFor:@"NextRecentTimeSheetsCount"]];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideMoreButton:) 
													 name:NEXT_RECENT_TIMESHEETS_RECEIVED_NOTIFICATION object:nil];
	}
	
}
-(void)hideMoreButton:(id)flag{
    if (flag) {
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NEXT_RECENT_TIMESHEETS_RECEIVED_NOTIFICATION object:nil];
    }

	NSNumber *timeSheetsCount =	[[NSUserDefaults standardUserDefaults]objectForKey:@"NumberOfTimeSheets"];
	NSNumber *fetchCount  =    [[G2AppProperties getInstance]getAppPropertyFor:@"NextRecentTimeSheetsCount"];

	DLog(@" Fetch Count %d",[fetchCount intValue]);
	DLog(@" TimeSheets Count %d",[timeSheetsCount intValue]);

	if (([timeSheetsCount intValue]<[fetchCount intValue])) {//[fetchCount intValue]
		[self.moreButton setHidden:YES];
		[imageView setHidden:YES];
        [self hideEmptySeparators];
	}
    else
    {
        [self.moreButton setHidden:NO];
        [imageView setHidden:NO];
        [self.timeSheetsTableView setTableFooterView:footerView];
    }
	[self displayAllTimeSheets];
	[self.timeSheetsTableView reloadData];
}


- (void)hideEmptySeparators
{
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor clearColor];
    [self.timeSheetsTableView setTableFooterView:v];
   
}

-(void)goBack:(id)sender{
	[[[UIApplication sharedApplication]delegate]performSelector:@selector(flipToHomeViewController)]; 
}

#pragma mark -
#pragma mark TimeSheets Methods
-(BOOL)checkForPermissionExistence:(NSString *)_permission{
	NSMutableArray *permissionlist = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserPermissionSet"];
	if (_permission != nil) {
		for (int i=0; i<[permissionlist count]; i++) {
			if ([permissionlist containsObject:_permission]) {
				return YES;
			}
		}
	}
	return NO;
}
-(BOOL)userPreferenceSettings:(NSString *)_preference{
	NSMutableArray *preferences = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserPreferenceSettings"];
	if (_preference != nil) {
		for (int i=0; i<[preferences count]; i++) {
			if ([preferences containsObject:_preference]) {
				return YES;
			}
		}
	}
	return NO;
	
}
-(void)displayAllTimeSheets{
	
	//Fetch Time Sheets from DB
	if ([timeSheetsArray count] > 0) {
		[timeSheetsArray removeAllObjects];
	}
	G2TimesheetModel *timesheetModel = [[G2TimesheetModel alloc] init]; 
	NSMutableArray *dbTimesheetsArray = [timesheetModel getTimesheetsFromDB];
	
	
	//TODO: Get Permissions for 'Against/Both', 'Without requiring a Project': DONE
	G2PermissionsModel *permissionsModel = [[G2PermissionsModel alloc] init];
	
	NSMutableArray *userPermissions = [permissionsModel getAllEnabledUserPermissions];
	[[NSUserDefaults standardUserDefaults] setObject:userPermissions forKey:@"UserPermissionSet"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	againstProjects    = [self checkForPermissionExistence:@"ProjectTimesheet"];
	notagainstProjects = [self checkForPermissionExistence:@"NonProjectTimesheet"];
	unsubmitAllowed	   = [self checkForPermissionExistence:@"UnsubmitTimesheet"];
	billingTimesheet   = [self checkForPermissionExistence:@"BillingTimesheet"];
	allowComments	   = [self checkForPermissionExistence:@"AllowBlankResubmitComment"];
    BOOL reopenTimesheet=[self checkForPermissionExistence:@"ReopenTimesheet"];
	if (againstProjects && notagainstProjects) {
		both = YES;
	}
	
	//TODO: Need to check for 'Activities Enabled' permission:DONE
	G2SupportDataModel *supportDataModel = [[G2SupportDataModel alloc] init];
	NSMutableArray *userPreferences = [supportDataModel getAllUserPreferences];
	[[NSUserDefaults standardUserDefaults] setObject:userPreferences forKey:@"UserPreferenceSettings"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	activitiesEnabled = [self userPreferenceSettings:@"ActivitiesEnabled"];
	useBillingInfo    = [self userPreferenceSettings:@"UseBillingInformation"];
	
    
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if (!appDelegate.isLockedTimeSheet) 
    {
        //TODO: Get User Preference for Time Format:DONE
        hourFormat = @"Decimal";
    }
    else
    {
        hourFormat = [supportDataModel getUserHourFormat];
    }
    

	/*
	NSMutableArray *formatsArray = [supportDataModel getUserTimeSheetFormats];
	if (formatsArray != nil && [formatsArray count]> 0) {
		for (NSDictionary *formatDict in formatsArray) {
			if ([[formatDict objectForKey:@"preferenceName"] isEqualToString:@"Timesheet.HourFormat"]) {
				timeFormat = [[formatDict objectForKey:@"preferenceValue"] retain];
			}
		}
	}*/
	
	NSMutableArray *formatsArray = [supportDataModel getUserTimeSheetFormats];
	if (formatsArray != nil && [formatsArray count]> 0) {
		for (NSDictionary *formatDict in formatsArray) {
			if ([[formatDict objectForKey:@"preferenceName"] isEqualToString:@"Timesheet.DateFormat"]) {
				self.dateformat = [formatDict objectForKey:@"preferenceValue"];
			}
		}
	}
	//Create Preferences Object
	[preferenceSet setDateformat:[self dateformat]];
	[preferenceSet setHourFormat:hourFormat];
	[preferenceSet setActivitiesEnabled:activitiesEnabled];
	[preferenceSet setUseBillingInfo:useBillingInfo];
	
	//Create Permission Object
	[permissionsetObj setProjectTimesheet:againstProjects];
	[permissionsetObj setNonProjectTimesheet:notagainstProjects];
	[permissionsetObj setUnsubmitTimeSheet:unsubmitAllowed];
	[permissionsetObj setBothAgainstAndNotAgainstProject:both];
	[permissionsetObj setAllowBlankResubmitComment:allowComments];
	[permissionsetObj setBillingTimesheet:billingTimesheet];
    [permissionsetObj setReopenTimesheet:reopenTimesheet];
	
	if(dbTimesheetsArray != nil && [dbTimesheetsArray count] > 0) {
		for (NSDictionary *timesheetDict in dbTimesheetsArray) {
			G2TimeSheetObject *timesheetObj   = [[G2TimeSheetObject alloc] init];
			timesheetObj.identity			= [timesheetDict objectForKey:@"identity"];
			timesheetObj.status				= [timesheetDict objectForKey:@"approvalStatus"];
			timesheetObj.approversRemaining = [[timesheetDict objectForKey:@"approversRemaining"] boolValue];
			NSDate *startdate	= [G2Util convertStringToDate:[timesheetDict objectForKey:@"startDate"]];
			NSDate *enddate		= [G2Util convertStringToDate:[timesheetDict objectForKey:@"endDate"]];
			NSDate *duedate		= [G2Util convertStringToDate:[timesheetDict objectForKey:@"dueDate"]];
            if ([timesheetDict objectForKey:@"disclaimerAccepted"] !=nil && ![[timesheetDict objectForKey:@"disclaimerAccepted"] isKindOfClass:[NSNull class] ]) {
                NSDate *disclaimerAccepted	= [G2Util convertStringToDate:[timesheetDict objectForKey:@"disclaimerAccepted"]];
                 timesheetObj.disclaimerAccepted    = disclaimerAccepted ;
            }
            
			
			timesheetObj.startDate  = startdate;
			timesheetObj.endDate    = enddate;
			timesheetObj.dueDate    = duedate ;
           
			
			NSString *timeEntrytotalHrs                  = [timesheetModel getSheetTotalTimeHoursForSheetFromDB:[timesheetObj identity] withFormat:hourFormat];
			
            timesheetObj.totalHrs   =timeEntrytotalHrs;
            

            
            
            
			if ( againstProjects == YES || both == YES) {
				NSMutableArray *_projects = [timesheetModel getEntryProjectNamesForSheetFromDB:[timesheetObj identity]];
				if (_projects!= nil && [_projects count] >0) {
					NSMutableArray *projNameList = [NSMutableArray array];
					for (int i=0; i<[_projects count]; i++) {
						[projNameList addObject: [[_projects objectAtIndex: i]objectForKey: @"projectName"]];
						//[timesheetObj.projects addObject:[[_projects objectAtIndex:i]objectForKey:@"projectName"]];
					}
					[timesheetObj setProjects: projNameList];
				}
			}else if (notagainstProjects == YES) {
				if (activitiesEnabled) {
					NSMutableArray *_activities = [timesheetModel getEntryActivitiesForSheetFromDB:[timesheetObj identity]];
					if (_activities!= nil && [_activities count] >0) {
						NSMutableArray *activitiesNameList = [NSMutableArray array];
						for (int i=0; i<[_activities count]; i++) {
							//[timesheetObj.activities addObject:[[_activities objectAtIndex:i]objectForKey:@"activityName"]];
							[activitiesNameList addObject: [[_activities objectAtIndex: i]objectForKey: @"activityName"]];
						}
						[timesheetObj setActivities: activitiesNameList];
					}
					

				}	
			}
            if (appDelegate.isLockedTimeSheet) {
                if ([timesheetObj.totalHrs isEqualToString:@"0.00"] || [timesheetObj.totalHrs isEqualToString:@"0:00"] ) {
                    NSCalendar* calendar = [NSCalendar currentCalendar];
                    NSDate* now = [NSDate date];
                    NSUInteger differenceInDays =
                    [calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitEra forDate:startdate] -
                    [calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitEra forDate:now];
                    if (differenceInDays<=0 ) {
                        G2TimesheetModel *timesheetModel = [[G2TimesheetModel alloc] init]; 
                        NSMutableArray *entriesArr=[timesheetModel getTimeEntriesForSheetFromDB:[timesheetObj identity]];
                        if ([entriesArr count]>0) 
                        {
                            [timeSheetsArray addObject:timesheetObj];
                        }
                    
                    }
                }
                else
                {
                    [timeSheetsArray addObject:timesheetObj];
                }
            }
            else
            {
                [timeSheetsArray addObject:timesheetObj];
            }
            
			
			
		}
	}

}
-(void)highlightTappedRowBackground:(NSIndexPath*)indexPath{
	
	G2CustomTableViewCell *cellObj = [self getTappedRowAtIndexPath:indexPath];
	if (cellObj == nil) {
		return;
	}
	
	
	[timeSheetsTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
	
	[[cellObj upperLeft] setTextColor:iosStandaredWhiteColor];
	[[cellObj upperRight] setTextColor:iosStandaredWhiteColor];
	[[cellObj lowerLeft] setTextColor:iosStandaredWhiteColor];
	//[[cellObj lowerRight] setTextColor:iosStandaredWhiteColor];
	//[cellObj setSelected:YES];
}

-(void)deSelectTappedRow{
	id cellObj = [self getTappedRowAtIndexPath:rowTapped];
	if (cellObj == nil) {
		return;
	}
	[[cellObj upperLeft] setTextColor:RepliconStandardBlackColor];
	[[cellObj upperRight] setTextColor:RepliconStandardBlackColor];
	[[cellObj lowerLeft] setTextColor:RepliconStandardBlackColor];
	//[[cellObj lowerRight] setTextColor:RepliconStandardBlackColor];
	[self.timeSheetsTableView deselectRowAtIndexPath:rowTapped animated:YES];
	//[cellObj setSelected:NO];
}
-(void)highlightTheCellWhichWasSelected{
	[self highlightTappedRowBackground:rowTapped];
}
-(G2CustomTableViewCell*)getTappedRowAtIndexPath:(NSIndexPath*)indexPath{
	G2CustomTableViewCell *rowCell = (G2CustomTableViewCell *)[self.timeSheetsTableView cellForRowAtIndexPath: indexPath]; 
	return rowCell;
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */
#pragma mark -
#pragma mark Memory Based Methods
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.footerView=nil;
//    self.timeSheetsTableView=nil;
    self.timeEntriesViewController=nil;
    self.imageView=nil;
//    self.moreButton=nil;
    self.leftButton=nil;
}




@end
