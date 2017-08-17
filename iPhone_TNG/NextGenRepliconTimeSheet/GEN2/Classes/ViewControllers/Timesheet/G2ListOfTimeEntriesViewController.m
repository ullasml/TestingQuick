

//
//  ListOfTimeEntriesViewController.m
//  Replicon
//
//  Created by Hepciba on 4/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2ListOfTimeEntriesViewController.h"
#import "RepliconAppDelegate.h"


@implementation G2ListOfTimeEntriesViewController

@synthesize innerTopToolbarLabel;
@synthesize topToolbarlabel;
@synthesize selectedSheet;
@synthesize timeEntryObjectsDictionary;
@synthesize descriptionLabel;
@synthesize isEntriesAvailable;
@synthesize sectionHeaderlabel;
@synthesize	againstProjects;
@synthesize	notAgainstProjects;
@synthesize	Both;
@synthesize keyArray;
@synthesize activitiesEnabled;
@synthesize totalHours;
@synthesize sheetApprovalStatus;
@synthesize allowBlankComments;
@synthesize missingRequiredFields;
@synthesize sheetIdentity;
@synthesize rowTapped;
@synthesize sectionHeadertotalhourslabel;
@synthesize  countRowsDict;
@synthesize  selectedEntriesIdentity;
@synthesize  timeEntryViewController;
@synthesize  timeSheetObj;
@synthesize  preferencesObj;
@synthesize  permissionsObj;
@synthesize  navcontroller;
@synthesize  projectsArr;
@synthesize  clientsArr;
@synthesize  timesheetModel;
@synthesize  resubmitViewController;
@synthesize  footerView;
@synthesize  sectionHeader;
@synthesize customFooterView;
@synthesize isInOutFlag,isLockedTimeSheet;
@synthesize progressView;

@synthesize mealHeaderLabel;
@synthesize customView;
@synthesize showMealCustomView;
@synthesize isShortenRows;
@synthesize isUnsubmitClicked;
int tappedSectionIndex=-1;
int tappedRowIndex=-1;


#define DEFAULT_ISONAME @"en"

NSString *defaultISOStr=nil;

#pragma mark -
#pragma mark init

- (id) init
{
	self = [super init];
    self = [super initWithNibName:@"G2ListOfTimeEntriesViewController" bundle:nil];
	if (self != nil) {
		if(timeEntryObjectsDictionary==nil){
            NSMutableDictionary *temptimeEntryObjectsDictionary=[[NSMutableDictionary alloc]init];
			self.timeEntryObjectsDictionary=temptimeEntryObjectsDictionary;
            
		}
		if (timesheetModel == nil) {
            G2TimesheetModel *temptimesheetModel=[[G2TimesheetModel alloc] init];
			self.timesheetModel = temptimesheetModel;
           
		}
		
		if (keyArray == nil) {
			//keyArray = [[NSMutableArray array] retain];
            NSMutableArray *tempkeyArray=[[NSMutableArray alloc]init];
			self.keyArray = tempkeyArray;
            
		}
		if (missingRequiredFields == nil) {
			NSMutableDictionary *tempmissingRequiredFields = [[NSMutableDictionary alloc]init];
            self.missingRequiredFields=tempmissingRequiredFields;
           
		}
		
		/*if (setOfPermissions == nil) {
		 setOfPermissions = [[NSMutableDictionary dictionary] retain];
		 }*/
		
		self.projectsArr=[NSMutableArray arrayWithObjects:@"Cisco",@"Newco",nil] ;
		self.clientsArr=[NSMutableArray arrayWithObjects:@"WebEx UI",@"iphone App",nil];
	}
	return self;
}

#pragma mark -
#pragma mark View Based Methods

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	[self.view setBackgroundColor:G2RepliconStandardBackgroundColor];
	//[self.navigationController.navigationItem setHidesBackButton:YES];//time_sheets_icon_clock_white.png
	
	
	/*UIBarButtonItem *leftButton= [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(TimeEntryBackButtonTitle,@"") style:UIBarButtonItemStylePlain 
	 target:self action:@selector(goToTimeSheets:)];
	 
	 UIBarButtonItem *leftButton= [[UIBarButtonItem alloc] initWithImage:[Util thumbnailImage:TimeSheets_Clock_Icon] style:UIBarButtonItemStylePlain
	 target:self action:@selector(goToTimeSheets:)];
	 
	 
	 [self.navigationItem setLeftBarButtonItem:leftButton animated:NO];
	 //[self.navigationItem.leftBarButtonItem setWidth:200.0];
	*/
	
	//1.Add Top title View
	if (topTitleView == nil) {
		topTitleView = [[G2NavigationTitleView alloc]initWithFrame:EntriesTopTitleViewFrame];
		//topTitleView = [[NavigationTitleView alloc]initWithFrame:CGRectMake(-55.0, 0.0, 280.0,40.0)];
	}
	
	[topTitleView addTopToolBarLabel];
	[topTitleView setTopToolbarlabelFrame:EntriesTopToolbarlabelFrame];
	//[topTitleView setTopToolbarlabelFrame:CGRectMake(-55.0, 0.0, 280.0,20.0)];
	[topTitleView setTopToolbarlabelFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_12]];
	[topTitleView setTopToolbarlabelText:RPLocalizedString(TimeEntryNavTitle,TimeEntryNavTitle)];
	
	[topTitleView.topToolbarlabel setHidden:YES];
	[topTitleView addInnerTopToolBarLabel];
	//[topTitleView setInnerTopToolbarlabelFrame:EntriesInnerTopToolbarlabelFrame];
	[topTitleView setInnerTopToolbarlabelFrame:CGRectMake(-55.0, 0.0, 280.0,40.0)];
	[topTitleView.topToolbarlabel setBackgroundColor:[UIColor yellowColor]];
	[topTitleView setInnerTopToolbarlabelFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_14]];
	[topTitleView setInnerTopToolbarlabelText:selectedSheet];
	
	
	//[topTitleView setBackgroundColor:[UIColor whiteColor]];
	//self.navigationItem.titleView = topTitleView;
	//self.title = selectedSheet;
	[G2ViewUtil setToolbarLabel:self withText:selectedSheet];
	//self.navigationController.navigationBar.backItem.title = RPLocalizedString(BACK,BACK);
	//[self.navigationController.navigationBar setTintColor:RepliconStandardNavBarTintColor];
    
    NSMutableDictionary *tempCountRowsDict=[[NSMutableDictionary alloc]init];
    self.countRowsDict=tempCountRowsDict;
   
    
    G2PermissionsModel *permissionsModel=[[G2PermissionsModel alloc] init];
    BOOL isInOut = [permissionsModel checkUserPermissionWithPermissionName:@"InOutTimesheet"];
    BOOL isClassicTimesheet = [permissionsModel checkUserPermissionWithPermissionName:@"ClassicTimesheet"];
    BOOL isNewInOut = [permissionsModel checkUserPermissionWithPermissionName:@"NewInOutTimesheet"];
    
    NSString *timeSheetType=nil;
    G2SupportDataModel *supportDataModel=[[G2SupportDataModel alloc] init];
    NSMutableArray *timeSheetPreferences = [supportDataModel getUserTimeSheetFormats];
   
    if (timeSheetPreferences != nil && [timeSheetPreferences count]> 0) {
        for (NSDictionary *preferenceDict in timeSheetPreferences) {
            if ([[preferenceDict objectForKey:@"preferenceName"] isEqualToString:@"Timesheet.Format"]) {
                timeSheetType=[preferenceDict objectForKey:@"preferenceValue"];
                break;
            }
        }
    }
    //------------------------- US4434 Ullas M L---------------------------
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (!appDelegate.isLockedTimeSheet)
    {
        if (appDelegate.isMultipleTimesheetFormatsAssigned) {
            if ([timeSheetType isEqualToString:New_InOut_Type_TimeSheet]) {
                isInOutFlag=TRUE;
            }
            else if ([timeSheetType isEqualToString:InOut_Type_TimeSheet]) {
                isInOutFlag=TRUE;
            }
            else
            {   isInOutFlag=FALSE;
                
            }

        }
                
    
    else
    {
        if (isInOut  ) 
        {
            if (isClassicTimesheet) 
            {
                if ([timeSheetType isEqualToString:InOut_Type_TimeSheet]) {
                    DLog(@"-----IN OUT TIMESHEETS ENABLED-----");
                    isInOutFlag=TRUE;
                }
            }
            else
            {
                if ([timeSheetType isEqualToString:InOut_Type_TimeSheet]) {
                    DLog(@"-----IN OUT TIMESHEETS ENABLED-----");
                    isInOutFlag=TRUE;
                }
                
            }
        }
        
        if (isNewInOut  ) 
        {
            isInOutFlag=TRUE;
        }
 
    }
    }
if (progressView == nil) {
		UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320.0, 480.0)];
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [indicatorView setFrame:CGRectMake(135, 125, 50, 50)];
        [indicatorView setHidesWhenStopped:YES];
        [indicatorView startAnimating];
        [tempView addSubview:indicatorView];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0f) {
             indicatorView.color=[UIColor blackColor];
        }
    
        tempView.backgroundColor=[UIColor whiteColor];
        tempView.alpha=0.5;
        self.progressView=tempView;
    
	}
   
   
	
    defaultISOStr=DEFAULT_ISONAME;

    
    self.isShortenRows=FALSE;
  
    BOOL isTimesheetDisplayActivities = [permissionsModel checkUserPermissionWithPermissionName:@"TimesheetDisplayActivities"];
    BOOL isTimesheetActivityRequired = [permissionsModel checkUserPermissionWithPermissionName:@"TimesheetActivityRequired"];
    BOOL isNotagainstProjects = [permissionsModel checkUserPermissionWithPermissionName:@"NonProjectTimesheet"];
    BOOL isAgainstProjects    = [self checkForPermissionExistence:@"ProjectTimesheet"];
    
    BOOL both=FALSE;
    if (isNotagainstProjects && isAgainstProjects)
    {
        both=TRUE;
    }
    
    if (isTimesheetDisplayActivities || isTimesheetActivityRequired) 
    {
        isTimesheetDisplayActivities=TRUE;
    }
    
    if (!isTimesheetDisplayActivities && isNotagainstProjects && !both) 
    {
        self.isShortenRows=TRUE;
    } 
    else if (isAgainstProjects && !isNotagainstProjects)
    {
        self.isShortenRows=FALSE;
    }
   else if (!both && !isTimesheetDisplayActivities)
    {
         self.isShortenRows=TRUE;
    }
    

    else if (isTimesheetDisplayActivities && !both)
    {
        G2SupportDataModel *supportdtModel= [[G2SupportDataModel alloc] init];
        NSMutableArray *activitiesArr=[supportdtModel getUserActivitiesFromDatabase];
        
        
        if ([activitiesArr count]==1)
        {
            if ( [[[activitiesArr objectAtIndex:0] objectForKey:@"name" ] isEqualToString:@"None" ])
            {
                self.isShortenRows=TRUE;
            }
        }
        
        else if ([activitiesArr count]<=0) 
        {
            self.isShortenRows=TRUE;
        }
        
    }     

    self.isUnsubmitClicked=NO;
    
}


-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:YES];
	
	[self createAddBarButton];//US4805
	
	[self createTimeEntryObject:timeSheetObj permissions:permissionsObj preferences:preferencesObj];
	[self.timeEntriesTableView reloadData];
	if (isEntriesAvailable == NO){

        self.timeEntriesTableView.hidden = YES;
		[footerView setHidden:YES];
		return;
		
	}else {
        UIView *bckView = [UIView new];
        [bckView setBackgroundColor:G2RepliconStandardBackgroundColor];
        [self.timeEntriesTableView setBackgroundView:bckView];
		[self createTimeEntryFooterView];
		//[self getApprovalHistoryForSheetAndShowFooterView];
		
	}
	[self performSelector:@selector(highlightTheCellWhichWasSelected) withObject:nil afterDelay:0];
	//[self performSelector:@selector(deSelectTappedRow) withObject:nil afterDelay:0.5];//DE2949 FadeOut is slow
    [self performSelector:@selector(deSelectTappedRow) withObject:nil afterDelay:0.0];
	
    
}

#pragma mark -
#pragma mark Methods
-(void)addTotalHourslable{
	
	UILabel *totalLabel=[[UILabel alloc]initWithFrame:G2EntriesTotalLabelFrame];
	[totalLabel setText:RPLocalizedString(G2TotalString,@"")];
	[totalLabel setTextColor:RepliconStandardTotalColor];
	
	[totalLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_12]];
	[totallabelView addSubview:totalLabel];
	
	UILabel *totalHoursLabel=[[UILabel alloc]initWithFrame:G2EntriesTotalHoursLabelFrame];
	//[totalHoursLabel setText:@"18:00"];//totalHours
	[totalHoursLabel setText:totalHours];
	[totalHoursLabel setTextColor:RepliconStandardTotalColor];
	[totalHoursLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_12]];
	[totallabelView addSubview:totalHoursLabel];
	
	
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	//TODO: Return no. of section's based on number of Headers in the timeEntryObjectDictionary:DONE
	if ([timeEntryObjectsDictionary count]>0) {
        
        for (int i=0;i<[[timeEntryObjectsDictionary allKeys] count];i++) 
        {

            if ([[countRowsDict allKeys]count]>0) {
                if([(NSMutableArray *)[timeEntryObjectsDictionary objectForKey:[keyArray objectAtIndex:i]]count] > [[countRowsDict objectForKey:[NSString stringWithFormat:@"%d",i]]intValue]  )
                {
                    NSString *keyValue = [keyArray objectAtIndex:i];
                    id timeEntryArr;
                    id timeEntryObj;
                    BOOL flag=FALSE;
                    timeEntryArr    = [timeEntryObjectsDictionary objectForKey:keyValue];
                    for (int j=0; j<[(NSMutableArray *)timeEntryArr count]; j++) {
                        timeEntryObj    = [timeEntryArr objectAtIndex:j];
                        if (![(NSString *)[timeEntryObj identity]  isKindOfClass:[NSNull class]]) 
                        {
                            if ([(NSString *)[timeEntryObj identity] isEqualToString:selectedEntriesIdentity  ]) {
                                tappedRowIndex=j;
                                flag=TRUE;
                                break;
                            }
                        }
                       
                    }
                    if (!flag) {
                        tappedRowIndex=-1;
                    }
                    //DE4049
                    if ([[countRowsDict objectForKey:[NSString stringWithFormat:@"%d",i]]intValue]==0)
                    {
                        tappedSectionIndex=0;
                    }
                    else
                        tappedSectionIndex=i;
                }
            }
        
          
        }
        
        for (int i=0;i<[[timeEntryObjectsDictionary allKeys] count];i++) 
        {
             [countRowsDict setObject:[NSNumber numberWithUnsignedInteger: [(NSMutableArray *)[timeEntryObjectsDictionary objectForKey:[keyArray objectAtIndex:i]]count]] forKey:[NSString stringWithFormat:@"%d",i]];
 
        }
        
		return [[timeEntryObjectsDictionary allKeys] count];
	}
	return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//DLog(@"\n numberOfRowsInSection ::ListOfTimeEntriesViewController==============>\n");
    
       
	if ([timeEntryObjectsDictionary count]>0) {
        

            
            if (tappedSectionIndex==section) {

                NSString *keyValue = [keyArray objectAtIndex:section];
                id timeEntryArr;
                id timeEntryObj;
                BOOL flag=FALSE;
                timeEntryArr    = [timeEntryObjectsDictionary objectForKey:keyValue];
                for (int i=0; i<[(NSMutableArray *)timeEntryArr count]; i++) {
                    timeEntryObj    = [timeEntryArr objectAtIndex:i];
                    
                    if ([timeEntryObj identity]!=nil && ![(NSString *)[timeEntryObj identity] isKindOfClass:[NSNull class]])
                    {
                        if ([(NSString *)[timeEntryObj identity] isEqualToString:selectedEntriesIdentity  ]) {
                            section=tappedSectionIndex;
                            self.rowTapped= [NSIndexPath indexPathForRow:i inSection:tappedSectionIndex];
                            //[self.rowTapped retain];
                            flag=TRUE;
                            break;
                        }
                    }
                    
                   
                }
                if (!flag) {
                    section=tappedSectionIndex;
                    if (tappedRowIndex<0) {
                         self.rowTapped= [NSIndexPath indexPathForRow:0 inSection:tappedSectionIndex];
                         //[self.rowTapped retain];
                    }
                    else
                    {
                        self.rowTapped= [NSIndexPath indexPathForRow:tappedRowIndex inSection:tappedSectionIndex];
                         //[self.rowTapped retain];
                    }
                    
                    

                }
                
                
            }

                 
		return [(NSMutableArray *)[timeEntryObjectsDictionary objectForKey:[keyArray objectAtIndex:section]]count];
	}
	return 0;
	
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	//return Each_Cell_Row_Height_80;
    
    if ( self.isShortenRows) 
    {
        return Each_Cell_Row_Height_44;
    }   
    else
    {
        return Each_Cell_Row_Height_58;
    }
    
	
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section    // fixed font style. use custom view (UILabel) if you want something different
{
	//DLog(@"\n titleForHeaderInSection:: ListOfTimeEntriesViewController::keyArray %@ =============>\n",keyArray);
	if ([keyArray count]>0) {
		NSString *headerTitle = [self getFormattedEntryDateString:[keyArray objectAtIndex:section]];
        
		NSString *hourFormat  = [preferencesObj hourFormat];
		NSString *timeEntryHoursStr    = [timesheetModel getTotalHoursforEntryWithDate:[keyArray objectAtIndex:section] 
																   withformat:hourFormat];
		NSString *totalHeaderString = nil;
        RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];

		if (timeEntryHoursStr == nil) {
			NSString *bookedEntryHourStr   = [timesheetModel getTotalHoursforBookedEntryWithDate:[keyArray objectAtIndex:section] 
																					  withformat:hourFormat];
			if (bookedEntryHourStr != nil) {
                if (!appDelegate.isLockedTimeSheet) 
                {
                    totalHeaderString = [NSString stringWithFormat:@"%@//%@",headerTitle,bookedEntryHourStr];
                }
                else
                {
                    if ([hourFormat isEqualToString:@"Decimal"]) {
                        totalHeaderString = [NSString stringWithFormat:@"%@//%@",headerTitle,bookedEntryHourStr];
                    }
                    else
                    {
                        totalHeaderString = [NSString stringWithFormat:@"%@//%@",headerTitle,[NSString stringWithFormat:@"%@",bookedEntryHourStr]];
                    }
                }
				
			}else {
				totalHeaderString = [NSString stringWithFormat:@"%@",headerTitle];
			}
		}else {
			NSString *bookedEntryHourStr   = [timesheetModel getTotalHoursforBookedEntryWithDate:[keyArray objectAtIndex:section] 
																					  withformat:hourFormat];
			if (bookedEntryHourStr != nil) 
            {
				
                if (!appDelegate.isLockedTimeSheet) 
                {
                    NSString *totalhrs = [NSString stringWithFormat:@"%0.02f",[timeEntryHoursStr floatValue]+[bookedEntryHourStr floatValue]];
                    totalHeaderString = [NSString stringWithFormat:@"%@//%@",headerTitle,totalhrs];
                }
                else
                {
                    if ([hourFormat isEqualToString:@"Decimal"]) {
                        NSString *totalhrs = [NSString stringWithFormat:@"%0.02f",[timeEntryHoursStr floatValue]+[bookedEntryHourStr floatValue]];
                        totalHeaderString = [NSString stringWithFormat:@"%@//%@",headerTitle,totalhrs];
                    }
                    else
                    {
                         totalHeaderString = [NSString stringWithFormat:@"%@//%@",headerTitle,[G2Util mergeTwoHourFormat:timeEntryHoursStr andHour2:bookedEntryHourStr]];
                    }
                }
				
			}
            
            else {
                if (!appDelegate.isLockedTimeSheet) 
                {
                   totalHeaderString = [NSString stringWithFormat:@"%@//%@",headerTitle,timeEntryHoursStr];
                }
                else
                {
                    if ([hourFormat isEqualToString:@"Decimal"]) {
                        totalHeaderString = [NSString stringWithFormat:@"%@//%@",headerTitle,timeEntryHoursStr];
                    }
                    else
                    {
                        totalHeaderString = [NSString stringWithFormat:@"%@//%@",headerTitle,[NSString stringWithFormat:@"%@",timeEntryHoursStr]];
                    }
                }

				
			}
		}
		return totalHeaderString;
	}
	return nil;
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
	//DLog(@"\n titleForHeaderInSection :: ListOfTimeEntriesViewController============>\n");
	return nil;
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section   // custom view for header. will be adjusted to default or specified header height
{
	//DLog(@"\n viewForHeaderInSection::ListOfTimeEntriesViewController============>\n");
	NSString *sectionTitle=[self tableView:tableView titleForHeaderInSection:section];
	
	NSArray *headerComponents = nil;
	if(sectionTitle==nil){
		return nil;
	}else {
		headerComponents = [sectionTitle componentsSeparatedByString:@"//"];
	}
    NSString *headerTitle = @"";
	NSString *hourString  = @"";
    
    if ([headerComponents count]>=2) {
        headerTitle = [headerComponents objectAtIndex:0];
        hourString  = [headerComponents objectAtIndex:1];
    }
	
	

	UILabel *tempsectionHeaderlabel=[[UILabel alloc]initWithFrame:CGRectMake(10.0,
																0.0, 
																240.0, 
																20.0)];//US4065//Juhi
    self.sectionHeaderlabel=tempsectionHeaderlabel;
   
    
	sectionHeaderlabel.backgroundColor=[UIColor clearColor];
	sectionHeaderlabel.text=headerTitle;
	//sectionHeaderlabel.text=@"Wednesday,September 30";
	[sectionHeaderlabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]];
	[sectionHeaderlabel setTextColor:[UIColor whiteColor]];//RepliconTimeEntryHeaderTextColor
	[sectionHeaderlabel setTextAlignment:NSTextAlignmentLeft];
	
	
	UILabel *tempsectionHeadertotalhourslabel=[[UILabel alloc]initWithFrame:CGRectMake(245.0,
																0.0, 
																65.0, 
																20.0)];
    self.sectionHeadertotalhourslabel=tempsectionHeadertotalhourslabel;
    
	sectionHeadertotalhourslabel.backgroundColor=[UIColor clearColor];
	sectionHeadertotalhourslabel.text=hourString;
	//sectionHeadertotalhourslabel.text=@"1245.689";
	[sectionHeadertotalhourslabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]];
	[sectionHeadertotalhourslabel setTextColor:[UIColor whiteColor]];//RepliconTimeEntryHeaderTextColor
	[sectionHeadertotalhourslabel setTextAlignment:NSTextAlignmentRight];
	
	UIImageView *tempsectionHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,
																  0.0,
																  320.0,
																  25.0)];
    self.sectionHeader=tempsectionHeader;
   
	[sectionHeader setImage:[G2Util thumbnailImage:G2TimeSheets_ContentsPage_Header]];
	[sectionHeader setBackgroundColor:[UIColor clearColor]];
	[sectionHeader addSubview:sectionHeaderlabel];	
	[sectionHeader addSubview:sectionHeadertotalhourslabel];
	
	//MealBreakUI
    
    NSString *mealBreaksStr =[self checkMealFlag:section];
    
    if (mealBreaksStr!=nil) 
    {
        showMealCustomView=TRUE;
    }
	else
    {
        showMealCustomView=FALSE;
    }
    
    
    
    if (showMealCustomView) {
        UIImage *lineImage = [G2Util thumbnailImage:G2TimeSheets_ContentsPage_Header];
        
        
        
        
       
        // Let's make an NSAttributedString first
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:mealBreaksStr];
        //Add LineBreakMode
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        // Add Font
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:RepliconFontSize_12]} range:NSMakeRange(0, attributedString.length)];
        
        //Now let's make the Bounding Rect
        CGSize expectedMealBreaksStrLabelSize = [attributedString boundingRectWithSize:CGSizeMake(300, 60) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(10, 20, 320, expectedMealBreaksStrLabelSize.height)];
        self.customView=tempView;
       
        
        
        UILabel *tempMealHeaderLabel=[[UILabel alloc]initWithFrame:CGRectMake(10.0,lineImage.size.height+6.5,300.0,expectedMealBreaksStrLabelSize.height)];
        self.mealHeaderLabel=tempMealHeaderLabel;
      
        [self.mealHeaderLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
        [self.mealHeaderLabel setText:mealBreaksStr];
        [self.mealHeaderLabel setTextColor:[UIColor blackColor]];
        [self.mealHeaderLabel setBackgroundColor:[UIColor clearColor]];
        [self.mealHeaderLabel setAdjustsFontSizeToFitWidth:FALSE];
        self.mealHeaderLabel.numberOfLines=3;
        [self.customView addSubview:self.mealHeaderLabel];
        [self.customView addSubview:sectionHeader];
       
        [self.customView setBackgroundColor:[UIColor colorWithRed:254/255.0 green:236/255.0 blue:162/255.0 alpha:1]];
        return self.customView;
    }
    else
    {

	   return sectionHeader;
    }
    
    return nil;
}


-(NSString *)checkMealFlag:(NSInteger)value
{
    
     NSArray *mealViolationsArr=[timesheetModel getAllMealViolationsbyDate:[keyArray objectAtIndex:value] forISOName:defaultISOStr forSheetidentity:[timeSheetObj identity]];
    NSString *text=nil;
    if ([mealViolationsArr count]>0) 
    {
        
        for (int i=0; i<[mealViolationsArr count]; i++)
        {
            NSDictionary *mealViolationDict=[mealViolationsArr objectAtIndex:i];
            
            if (text==nil) 
            {
                 text  = [NSString stringWithFormat:@"%@",[[mealViolationDict objectForKey:@"text"]  substringToIndex:[[mealViolationDict objectForKey:@"text"] length ]-1] ];
            }
            else 
            {
                text  = [NSString stringWithFormat:@"%@; %@",text,[[mealViolationDict objectForKey:@"text"]  substringToIndex:[[mealViolationDict objectForKey:@"text"] length ]-1]];
            }
           
            
        }
         
    }
    
    return text;
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    UIImage *lineImage = [G2Util thumbnailImage:G2TimeSheets_ContentsPage_Header];
     NSString *mealBreaksStr =[self checkMealFlag:section];
    if (mealBreaksStr!=nil) 
    {
        showMealCustomView=TRUE;
    }
	else
    {
        showMealCustomView=FALSE;
    }

    if (showMealCustomView) 
    {
//        @"Rest break from 01:30 PM to 01:35 PM was too short; Meal break from 03:05 PM to 03:10 PM was too short; Meal break from 07:10 PM to 07:20 PM was too short";
        
       
        
        // Let's make an NSAttributedString first
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:mealBreaksStr];
        //Add LineBreakMode
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        // Add Font
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:RepliconFontSize_12]} range:NSMakeRange(0, attributedString.length)];
        
        //Now let's make the Bounding Rect
        CGSize expectedMealBreaksStrLabelSize = [attributedString boundingRectWithSize:CGSizeMake(300, 60) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        return lineImage.size.height+expectedMealBreaksStrLabelSize.height+10.0;
    }
        
        
    else
        return lineImage.size.height;
    
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
	UIImage *lineImage = [G2Util thumbnailImage:G2Cell_HairLine_Image];
	//DLog(@"lineImage.size.height %d",lineImage.size.height);
	UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(tableView.frame.origin.x,
																			   tableView.frame.origin.y, 
																			   tableView.frame.size.width,
																			   lineImage.size.height)];
	
	[lineImageView setImage:lineImage];
    
	return lineImageView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
	UIImage *lineImage = [G2Util thumbnailImage:G2Cell_HairLine_Image];
		return lineImage.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//DLog(@"\n cellForRowAtIndexPath::ListOfTimeEntriesController============> \n");
    static NSString *CellIdentifier = @"Cell";
	
	cell = (G2CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[G2CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		
		cell.backgroundView          = [[UIImageView alloc] init];
		//cell.selectedBackgroundView  = [[UIImageView alloc] init];
		
		UIImage *rowBackground       = [G2Util thumbnailImage:cellBackgroundImageView];

		((UIImageView *)cell.backgroundView).image = rowBackground;
    }
    
    [cell setCommonCellDelegate:self];
    
	NSInteger i=indexPath.row;
	
	NSString *clientProject=@"";
	NSString *client =@"";
	NSString *project= @"";
	NSString *noofhrs= @"";
//	NSString *activity= @"";		//fixed memory leak
	NSString *comments= @"";
	NSString *task=@"";
	NSString *type=@"";
	NSString *status =@"";
	NSString *sectionDate = [keyArray objectAtIndex:indexPath.section];
	NSMutableArray *entries = [timeEntryObjectsDictionary objectForKey:sectionDate];
	//NSString *entryType = @"";
	UIColor			*statusColor = nil;
	UIColor			*upperrighttextcolor = nil;
	BOOL			imgflag = NO;
	
	
	
	id timeEntryObject = [entries objectAtIndex:i];
	if ([timeEntryObject isKindOfClass:[G2TimeSheetEntryObject class]]) {
		timeEntryObject = (G2TimeSheetEntryObject *)timeEntryObject;
		client   = [timeEntryObject clientName];
		project  = [timeEntryObject projectName];
		noofhrs  = [timeEntryObject numberOfHours];
        NSArray *compArr=[noofhrs componentsSeparatedByString:@":"];
        if ([compArr count] >1) 
        {
            NSString *totalMinsStr=[compArr objectAtIndex:1];
            if (![totalMinsStr isKindOfClass:[NSNull class] ]) 
            {
                if ([totalMinsStr length]==1) 
                {
                    totalMinsStr=[@"0" stringByAppendingString:totalMinsStr];
                }
            }
            
            noofhrs=[[[compArr objectAtIndex:0] stringByAppendingString:@":"] stringByAppendingString:totalMinsStr];
        }
	//	activity = [timeEntryObject activityName];		//fixed memory leak
		//task     = [timeEntryObject taskName];
		task     = [[timeEntryObject taskObj] taskName];
	//	comments = [timeEntryObject comments];			//fixed memory leak
		//entryType = @"TimeEntry";
		
		if (client == nil || [client isKindOfClass:[NSNull class]]) {
			//client = @"None";			//fixed memory leak
		}
		if (project == nil || [project isKindOfClass:[NSNull class]]) {
			project = @"None";
		}
		clientProject = [NSString stringWithFormat:@"%@",project];
				
		if ([clientProject isEqualToString:@"None"] && (Both || againstProjects)) {
			clientProject =RPLocalizedString(@"No project", @"No project") ;
		}
		else if([clientProject isEqualToString:@"None"]){
            G2PermissionsModel *permissionsModel = [[G2PermissionsModel alloc] init];
            BOOL isTimesheetDisplayActivities = [permissionsModel checkUserPermissionWithPermissionName:@"TimesheetDisplayActivities"];
            BOOL isTimesheetActivityRequired = [permissionsModel checkUserPermissionWithPermissionName:@"TimesheetActivityRequired"];
            
            if (isTimesheetDisplayActivities || isTimesheetActivityRequired) 
            {
                 G2SupportDataModel *supportdtModel= [[G2SupportDataModel alloc] init];
                NSMutableArray *activitiesArr=[supportdtModel getUserActivitiesFromDatabase];
               
                if ([activitiesArr count]==1)
                {
                    if ( [[[activitiesArr objectAtIndex:0] objectForKey:@"name" ] isEqualToString:@"None" ])
                    {
                        clientProject = @"";
                    }
                }
                
               else if ([timeEntryObject activityName] != nil && ![[timeEntryObject activityName] isKindOfClass:[NSNull class]]) {
                    clientProject = [timeEntryObject activityName];
                    if([clientProject isEqualToString:@"None"])
                    {
                         clientProject = RPLocalizedString(@"No activity", @"No activity") ;
                    }
                }
                else
                {
                    clientProject = RPLocalizedString(@"No activity", @"No activity");
                }
            }
            else
            {
                clientProject = @"";
            }
			
		}

		/*[cell createCellLayoutWithParams:clientProject upperlefttextcolor:upperrighttextcolor 
						   upperrightstr:noofhrs lowerleftstr:task 
						   lowerrightstr:@"" statuscolor:statusColor 
						   imageViewflag:imgflag hairlinerequired :NO];*/
       
        NSString *inoutTimeStr=nil;
        RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
        if (isInOutFlag ) {
            NSString *inTimeToBeUsed = [timeEntryObject inTime];
            BOOL hasInTime=FALSE;
            BOOL hasOutTime=FALSE;
            if (inTimeToBeUsed!=nil && [inTimeToBeUsed isKindOfClass:[NSString class]]) {
                hasInTime=TRUE;
                
                 inTimeToBeUsed=[G2Util convertMidnightTimeFormat:[timeEntryObject inTime]];
                
            }
            
            NSString *outTimeToBeUsed = [timeEntryObject outTime];
            
            if (outTimeToBeUsed!=nil && [outTimeToBeUsed isKindOfClass:[NSString class]]) {
                hasOutTime=TRUE;
                
               outTimeToBeUsed=[G2Util convertMidnightTimeFormat:[timeEntryObject outTime]];
                
               

            }
            
            if (hasInTime && hasOutTime) {
                inoutTimeStr=[NSString stringWithFormat:@"%@ - %@",inTimeToBeUsed,outTimeToBeUsed];
            }
            else if (hasInTime && !hasOutTime)
            {
                noofhrs=RPLocalizedString(@"In progress", @"In progress") ;
                inoutTimeStr=[NSString stringWithFormat:@"%@ - ?",inTimeToBeUsed];
            }
            else if (!hasInTime && hasOutTime)
            {
                noofhrs=RPLocalizedString(@"In progress", @"In progress") ;
                inoutTimeStr=[NSString stringWithFormat:@"? - %@",outTimeToBeUsed];
            }
            else
            {
                inoutTimeStr=@"";
            }            
        }
        else if(appDelegate.isLockedTimeSheet)
        {
            
            NSString *inTimeToBeUsed = [timeEntryObject inTime];
            BOOL hasInTime=FALSE;
            BOOL hasOutTime=FALSE;
            if (inTimeToBeUsed!=nil && [inTimeToBeUsed isKindOfClass:[NSString class]]) {
                hasInTime=TRUE;
                
                
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AM_PM"]) {
                    inTimeToBeUsed=[G2Util convertMidnightTimeFormat:[timeEntryObject inTime]];
                }
                else
                {
                    inTimeToBeUsed=[G2Util convert12HourTimeStringTo24HourTimeString:[timeEntryObject inTime]];
                }
               
              
            }
            
            NSString *outTimeToBeUsed = [timeEntryObject outTime];
            
            if (outTimeToBeUsed!=nil && [outTimeToBeUsed isKindOfClass:[NSString class]]) {
                hasOutTime=TRUE;
                
                
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AM_PM"]) {
                         outTimeToBeUsed=[G2Util convertMidnightTimeFormat:[timeEntryObject outTime]];
                }
                else
                {
                        outTimeToBeUsed=[G2Util convert12HourTimeStringTo24HourTimeString:[timeEntryObject outTime]];
                }
                
                
                
                
            }
             imgflag=FALSE;
            if (hasInTime) {
                if (hasOutTime) {
                     inoutTimeStr=[NSString stringWithFormat:@"%@ - %@",inTimeToBeUsed,outTimeToBeUsed];
                }
                else
                {
                    imgflag=TRUE;
                    inoutTimeStr=[NSString stringWithFormat:@"%@ -     ",inTimeToBeUsed];
                      noofhrs=RPLocalizedString(@"In progress", @"In progress") ;
                }
               
            }
            else
            {
                inoutTimeStr=@"";
            }
            
            
        }
        else
        {
            inoutTimeStr=@"";
        }
        
        
        

        if (self.isShortenRows)
        {
                clientProject=inoutTimeStr;
                inoutTimeStr=nil;
                task=nil;
            
        }

        
        
		[cell createCellLayoutWithParams:clientProject upperlefttextcolor:upperrighttextcolor 
						   upperrightstr:noofhrs lowerleftstr:task lowerlefttextcolor:RepliconStandardBlackColor
						   lowerrightstr:inoutTimeStr statuscolor:statusColor 
						   imageViewflag:imgflag hairlinerequired:NO];
		
		[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
		
	}
    else if ([timeEntryObject isKindOfClass:[G2TimeOffEntryObject class]]) {
		type	       = [timeEntryObject timeOffCodeType];
		noofhrs        = [timeEntryObject numberOfHours];
        NSArray *compArr=[noofhrs componentsSeparatedByString:@":"];
        if ([compArr count] >1) 
        {
            NSString *totalMinsStr=[compArr objectAtIndex:1];
            if (![totalMinsStr isKindOfClass:[NSNull class] ]) 
            {
                if ([totalMinsStr length]==1) 
                {
                    totalMinsStr=[@"0" stringByAppendingString:totalMinsStr];
                }
            }
           
            noofhrs=[[[compArr objectAtIndex:0] stringByAppendingString:@":"] stringByAppendingString:totalMinsStr];
        }

		comments       = [timeEntryObject comments];
		//entryType	   = @"AdhocTimeOffEntry";
		//upperrighttextcolor = RepliconStandardGrayColor;
        
        
                
        NSString *lowerRightString=nil;
        
        if (self.isShortenRows)
        {
            comments=nil;
            lowerRightString=nil;
        }
        else
        {
            lowerRightString=@"";
        }
        
		[cell createCellLayoutWithParams:type upperlefttextcolor:upperrighttextcolor upperrightstr:noofhrs lowerleftstr:comments lowerlefttextcolor:RepliconStandardBlackColor lowerrightstr:lowerRightString statuscolor:statusColor 
						   imageViewflag:imgflag hairlinerequired:NO];
		
		//[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
	}
    else {
		
		type	       = [timeEntryObject typeName];
		noofhrs        = [timeEntryObject numberOfHours];
        NSArray *compArr=[noofhrs componentsSeparatedByString:@":"];
        if ([compArr count] >1) 
        {
            NSString *totalMinsStr=[compArr objectAtIndex:1];
            if (![totalMinsStr isKindOfClass:[NSNull class] ]) 
            {
                if ([totalMinsStr length]==1) 
                {
                    totalMinsStr=[@"0" stringByAppendingString:totalMinsStr];
                }
            }
            
            noofhrs=[[[compArr objectAtIndex:0] stringByAppendingString:@":"] stringByAppendingString:totalMinsStr];
        }

		comments       = [timeEntryObject comments];
		status         = [timeEntryObject approvalStatus];
		//entryType	   = @"BookedTimeOffEntry";
		
		NSString *bookedTimeOffApprovalStatus = @"";
		if (status != nil) {
			bookedTimeOffApprovalStatus = [NSString stringWithFormat:@"%@-%@",RPLocalizedString(@"Booking", @"Booking") ,RPLocalizedString(status, status) ];
		}
		statusColor         = RepliconStandardGrayColor;
		upperrighttextcolor = RepliconStandardGrayColor;
        
                
        
        if (self.isShortenRows)
        {
            comments=nil;
            bookedTimeOffApprovalStatus=nil;
        }
       

        
        
		[cell createCellLayoutWithParams:type upperlefttextcolor:upperrighttextcolor upperrightstr:noofhrs lowerleftstr:comments lowerlefttextcolor:RepliconStandardGrayColor lowerrightstr:bookedTimeOffApprovalStatus statuscolor:statusColor 
						   imageViewflag:imgflag hairlinerequired:NO];
		
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		[[cell  lowerLeft]  setFrame:CGRectMake(12.0, 35.0, 113.0, 14.0)];
		[[cell lowerRight] setFrame:CGRectMake(125.0, 35.0, 183.0, 14.0)];

        
        
	}
	
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
	return cell;
}

#pragma mark -
#pragma mark Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)	{
		
#ifdef PHASE1_US2152
		[G2Util showOfflineAlert];
		return;
#endif
	}
//	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	id timeEntryArr;
	id timeEntryObj;

	NSString *keyValue = [keyArray objectAtIndex:indexPath.section];
	
	
    
	if ([self.sheetApprovalStatus isEqualToString:APPROVED_STATUS]  
		|| [self.sheetApprovalStatus isEqualToString:G2WAITING_FOR_APRROVAL_STATUS]) {
		//TODO: Push the Controller to View the Entry:DONE
		
		timeEntryArr    = [timeEntryObjectsDictionary objectForKey:keyValue];
		timeEntryObj    = [timeEntryArr objectAtIndex:indexPath.row]; 
		
		if ([timeEntryObj isKindOfClass:[G2TimeSheetEntryObject class]]) {
			[self highlightTappedRowBackground:indexPath];
			self.rowTapped=indexPath;
            tappedSectionIndex=-1;
            selectedEntriesIdentity=(NSString *)[timeEntryObj identity];
#ifdef DEV_DEBUG
			DLog(@"(timeEntryObj isKindOfClass:: TimeSheetEntryObject)::::While Viewing Entry");
			DLog(@"Client Name  %@",[timeEntryObj clientName]);
			DLog(@"Project Name %@",[timeEntryObj projectName]);
			DLog(@"Date         %@",[Util convertPickerDateToString:[timeEntryObj entryDate]]);
			DLog(@"Time		 %@",[timeEntryObj numberOfHours]);
			DLog(@"taskName	 %@",[[timeEntryObj taskObj] taskName]);
			DLog(@"comments	 %@",[timeEntryObj comments]);
#endif			
            RepliconAppDelegate *appDelegate= (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
            self.isLockedTimeSheet=appDelegate.isLockedTimeSheet;

			G2TimeEntryViewController *addNewTimeEntryViewController = [[G2TimeEntryViewController alloc] 
												initWithEntryDetails:timeEntryObj sheetId:nil screenMode:VIEW_TIME_ENTRY 
												permissionsObj:permissionsObj preferencesObj:preferencesObj:isInOutFlag:isLockedTimeSheet:self];
			
			[addNewTimeEntryViewController setSheetStatus:sheetApprovalStatus];
			self.timeEntryViewController=addNewTimeEntryViewController;
            [addNewTimeEntryViewController setHidesBottomBarWhenPushed:YES];//DE3486
			[self.navigationController pushViewController:self.timeEntryViewController animated:YES];
			
			
		}

        else if ([timeEntryObj isKindOfClass:[G2TimeOffEntryObject class]]) 
        {
            
			[self highlightTappedRowBackground:indexPath];
			self.rowTapped=indexPath;
            tappedSectionIndex=-1;
            selectedEntriesIdentity=(NSString *)[timeEntryObj identity];
	
            RepliconAppDelegate *appDelegate= (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
            self.isLockedTimeSheet=appDelegate.isLockedTimeSheet;
            
    
            
			G2TimeEntryViewController *addNewTimeEntryViewController = [[G2TimeEntryViewController alloc] 
                                                                      initWithEntryDetails:timeEntryObj sheetId:nil screenMode:VIEW_ADHOC_TIMEOFF
                                                                      permissionsObj:permissionsObj preferencesObj:preferencesObj:isInOutFlag:isLockedTimeSheet:self];
			

			
			[addNewTimeEntryViewController setSheetStatus:sheetApprovalStatus];
			self.timeEntryViewController=addNewTimeEntryViewController;
            [addNewTimeEntryViewController setHidesBottomBarWhenPushed:YES];
            [addNewTimeEntryViewController setIsTimeOffEntry:TRUE];
			[self.navigationController pushViewController:self.timeEntryViewController animated:YES];
			

			
		}

             /*else if ([timeEntryObj isKindOfClass:[BookedTimeOffEntry class]]) {
		  //TODO: Handle the case when entry is other than TimeSheetEntryObject
		  }*/
	}else if ([self.sheetApprovalStatus isEqualToString:REJECTED_STATUS]
			  ||[self.sheetApprovalStatus isEqualToString:NOT_SUBMITTED_STATUS] ){
		//TODO:Push the Controller to Edit the entry:DONE
		//TODO: Pass the Date String as key for timeEntryObjectsDictionary
		
		timeEntryArr    = [timeEntryObjectsDictionary objectForKey:keyValue];
		timeEntryObj    = [timeEntryArr objectAtIndex:indexPath.row]; 
        
		if ([timeEntryObj isKindOfClass:[G2TimeSheetEntryObject class]]) {
			[self highlightTappedRowBackground:indexPath];
			self.rowTapped=indexPath;
            tappedSectionIndex=-1;
            selectedEntriesIdentity=(NSString *)[timeEntryObj identity];
#ifdef DEV_DEBUG
			DLog(@"(timeEntryObj isKindOfClass:: TimeSheetEntryObject)::::While Editing Entry");
			DLog(@"Client Name  %@",[timeEntryObj clientName]);
			DLog(@"Project Name %@",[timeEntryObj projectName]);
			DLog(@"Date		 %@",[Util convertPickerDateToString:[timeEntryObj entryDate]]);
			DLog(@"Time		 %@",[timeEntryObj numberOfHours]);
			DLog(@"taskName	 %@",[[timeEntryObj taskObj] taskName]);
			DLog(@"comments	 %@",[timeEntryObj comments]);
#endif				
			NSMutableString *clientProjectName = [NSMutableString string];
			if ([timeEntryObj clientName] != nil && ![[timeEntryObj clientName] isKindOfClass:[NSNull class]]
				&& ![[timeEntryObj clientName] isEqualToString:@""]) {
				[clientProjectName appendString:[timeEntryObj clientName]];
			}
			if ([timeEntryObj projectName] != nil && ![[timeEntryObj projectName] isKindOfClass:[NSNull class]]
				&& ![[timeEntryObj projectName] isEqualToString:@""]) {
				if ([timeEntryObj clientName] != nil && ![[timeEntryObj clientName] isKindOfClass:[NSNull class]]
					&& ![[timeEntryObj clientName] isEqualToString:@""]){
					
					[clientProjectName appendString:[NSString stringWithFormat:@"/%@",[timeEntryObj projectName]]];
				}else {
					[clientProjectName appendString:[NSString stringWithFormat:@"%@",[timeEntryObj projectName]]];
				}
			}
			if ([clientProjectName isEqualToString:@""]) {
				[clientProjectName appendString:@""];
			}
            RepliconAppDelegate *appDelegate= (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
            self.isLockedTimeSheet=appDelegate.isLockedTimeSheet;
			G2TimeEntryViewController *addNewTimeEntryController = [[G2TimeEntryViewController alloc] 
													initWithEntryDetails:timeEntryObj sheetId:nil screenMode:EDIT_TIME_ENTRY 
                                                                  permissionsObj:permissionsObj preferencesObj:preferencesObj:isInOutFlag:isLockedTimeSheet:self]; 
			[addNewTimeEntryController setSelectedSheetIdentity:[timeSheetObj identity]];
			[addNewTimeEntryController setHidesBottomBarWhenPushed:YES];	
            
			[self.navigationController pushViewController:addNewTimeEntryController animated:YES];
           
			
			
		}

        else if ([timeEntryObj isKindOfClass:[G2TimeOffEntryObject class]])
        {
            G2TimeOffEntryObject *addHocTimeOffObject=(G2TimeOffEntryObject *)timeEntryObj;
            
            if ((G2TimeOffEntryObject *)addHocTimeOffObject.numberOfAlternativeHours)
            {
                addHocTimeOffObject.numberOfHours= addHocTimeOffObject.numberOfAlternativeHours;      
            } 
            
			[self highlightTappedRowBackground:indexPath];
			self.rowTapped=indexPath;
                        tappedSectionIndex=-1;
                        selectedEntriesIdentity=(NSString *)[addHocTimeOffObject identity];
		

                        RepliconAppDelegate *appDelegate= (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
                        self.isLockedTimeSheet=appDelegate.isLockedTimeSheet;
			G2TimeEntryViewController *addNewTimeEntryController = [[G2TimeEntryViewController alloc] 
                                                                  initWithEntryDetails:addHocTimeOffObject sheetId:nil screenMode:EDIT_ADHOC_TIMEOFF 
                                                                  permissionsObj:permissionsObj preferencesObj:preferencesObj:isInOutFlag:isLockedTimeSheet:self]; 
			[addNewTimeEntryController setSelectedSheetIdentity:[timeSheetObj identity]];
			[addNewTimeEntryController setHidesBottomBarWhenPushed:YES];	
            [addNewTimeEntryController setIsTimeOffEntry:TRUE];
			[self.navigationController pushViewController:addNewTimeEntryController animated:YES];
            
			
			
            
            
            
            
        }
                /*else if ([timeEntryObj isKindOfClass:[BookedTimeOffEntry class]]) {
		  //TODO: Handle the case when entry is other than TimeSheetEntryObject .i.e - TimeOff
		  }*/
		
	}	
}

#pragma mark -
#pragma mark TimeEntry Methods

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

-(void)createTimeEntryObject:(G2TimeSheetObject*)timesheetobject 
				 permissions:(G2PermissionSet *)permissionsObject
				 preferences:(G2Preferences *)preferenceSetObject{
	
	self.timeSheetObj						  = timesheetobject;
	self.permissionsObj						  = permissionsObject;
	self.preferencesObj						  = preferenceSetObject;
	
	self.totalHours						      = [timeSheetObj totalHrs];
	sheetIdentity						  = [timeSheetObj identity];
	self.sheetApprovalStatus					  = [timeSheetObj status];
	
	againstProjects						  = [permissionsObj projectTimesheet];
	notAgainstProjects					  = [permissionsObj nonProjectTimesheet];
	Both								  = [permissionsObj bothAgainstAndNotAgainstProject];
	allowBlankComments					  = [permissionsObj allowBlankResubmitComment];
	unsubmitAllowed						  = [permissionsObj unsubmitTimeSheet];
	
	NSString *hourFormat				  = [preferencesObj hourFormat];
	
	activitiesEnabled					  = [preferencesObj activitiesEnabled];
	
	NSMutableArray *entriesArray				 = [timesheetModel getTimeEntriesForSheetFromDB:sheetIdentity];
	NSMutableArray *timeoffentriesArray			 = [timesheetModel getTimeOffsForSheetFromDB:sheetIdentity];
	//NSMutableArray *bookedtimeOffentriesArray    = [timesheetModel getBookedTimeOffsForSheetId:sheetIdentity];
	NSMutableArray *distinctEntryDates			 = [timesheetModel getDistinctEntryDatesForSheet:sheetIdentity];
	NSString *totalHrsString					 = [timesheetModel getSheetTotalTimeHoursForSheetFromDB:sheetIdentity withFormat:hourFormat];
	NSString *bookedTimeOffHrs					 = @"";
	NSDictionary *sheetDateRangeDict             = [timesheetModel getTimeSheetPeriodforSheetId:sheetIdentity];
	
	NSString *sheetstartDate = @"";
	NSString *sheetEndDate   = @"";
	
	if (sheetDateRangeDict != nil && [sheetDateRangeDict count] != 0) {
		sheetstartDate = [sheetDateRangeDict objectForKey:@"startDate"];
		sheetEndDate   = [sheetDateRangeDict objectForKey:@"endDate"];
		bookedTimeOffHrs = [timesheetModel getTotalBookedTimeOffHoursForSheetWith:sheetstartDate 
																		  endDate:sheetEndDate withFormat:hourFormat];
	}
	NSMutableArray *distinctTimeOffEntryDates    = [timesheetModel getBookedTimeOffforTimeSheetPeriod:sheetstartDate _endDate:sheetEndDate];
	//NSMutableArray *distinctTimeOffEntryDates1	 = [timesheetModel getBookedTimeOffDistinctDatesForSheet:sheetIdentity];
    
	RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    
	
	
	    
    
    if (!appDelegate.isLockedTimeSheet) 
    {
       // NSString *totalhrs = [NSString stringWithFormat:@"%f",[totalHrsString floatValue]+[bookedTimeOffHrs floatValue]];
         NSString *totalhrs = [NSString stringWithFormat:@"%f",[totalHrsString floatValue]];
        if (totalhrs != nil && ![totalhrs isKindOfClass:[NSNull class]]) 
        {
            self.totalHours = totalhrs;
            self.totalHours = [NSString stringWithFormat:@"%0.2f",[totalhrs floatValue]];
             [timeSheetObj setTotalHrs:totalhrs];
        }
       
    }
    else
    {
        if ([hourFormat isEqualToString:@"Decimal"]) {
//            NSString *totalhrs = [NSString stringWithFormat:@"%f",[totalHrsString floatValue]+[bookedTimeOffHrs floatValue]];
            NSString *totalhrs = [NSString stringWithFormat:@"%f",[totalHrsString floatValue]];
            if (totalhrs != nil && ![totalhrs isKindOfClass:[NSNull class]])
            {
                self.totalHours = totalhrs;
                self.totalHours = [NSString stringWithFormat:@"%0.2f",[totalhrs floatValue]];
                [timeSheetObj setTotalHrs:totalhrs];
            }
        }
        else
        {
            //self.totalHours = [Util mergeTwoHourFormat:totalHrsString andHour2:bookedTimeOffHrs];
             self.totalHours = totalHrsString;
            [timeSheetObj setTotalHrs:totalHours];
        }
    }
	
	
	if (timeEntryObjectsDictionary != nil && [timeEntryObjectsDictionary count]> 0) {

        [timeEntryObjectsDictionary removeAllObjects];

	}
	
	if (keyArray != nil && [keyArray count] > 0) {
		
		[self.keyArray removeAllObjects];;
	}
	
	NSMutableArray *keysArray = [NSMutableArray array];
	if ((distinctEntryDates != nil && [distinctEntryDates count]>0)||
		(distinctTimeOffEntryDates != nil && [distinctTimeOffEntryDates count]>0)) {
		isEntriesAvailable = YES;
		for (NSDictionary *dateDict in distinctEntryDates) {
			[keysArray addObject:[dateDict objectForKey:@"entrydate"]];
			NSMutableArray *entriesHoldingArray = [NSMutableArray array];
			[timeEntryObjectsDictionary setObject:entriesHoldingArray forKey:[dateDict objectForKey:@"entrydate"]];
		}
		if (distinctTimeOffEntryDates != nil && [distinctTimeOffEntryDates count]>0) {
			for (NSDictionary *dateDict in distinctTimeOffEntryDates) {
				if (![keysArray containsObject:[dateDict objectForKey:@"entryDate"]]) {
					[keysArray addObject:[dateDict objectForKey:@"entryDate"]];
					NSMutableArray *entriesHoldingArray = [NSMutableArray array];
					[timeEntryObjectsDictionary setObject:entriesHoldingArray forKey:[dateDict objectForKey:@"entryDate"]];
				}
			}
		}
		
		if (entriesArray != nil && [entriesArray count]>0) {
			for (NSDictionary *timeEntryDict in entriesArray ) {
				
				//TODO: Create TimeEntry Object:DONE
				G2TimeSheetEntryObject *timeSheetEntryObject=[[G2TimeSheetEntryObject alloc]init];
				NSString *identity   = [timeEntryDict objectForKey:@"identity"];
				NSString *stringDate = [timeEntryDict objectForKey:@"entryDate"];
				NSString *sheetId    = [timeEntryDict objectForKey:@"sheetIdentity"];
				NSString *entrytype  = [timeEntryDict objectForKey:@"entryType"];
				NSDate   *entrydate  = [G2Util convertStringToDate:stringDate];
				
				[timeSheetEntryObject			setIdentity:identity];
				[timeSheetEntryObject			setEntryDate:entrydate];
				[timeSheetEntryObject			setSheetId:sheetId];
				[timeSheetEntryObject			setEntryType:entrytype];
				[timeSheetEntryObject.taskObj	setEntryId:identity];
				
				if (againstProjects || Both) {
					NSString *clientname		= [timeEntryDict objectForKey:@"clientName"];
					NSString *clientidentity	= [timeEntryDict objectForKey:@"clientIdentity"];
					NSString *projectname		= [timeEntryDict objectForKey:@"projectName"];
					NSString *projectidentity	= [timeEntryDict objectForKey:@"projectIdentity"];
					if (clientname != nil && ![clientname isKindOfClass:[NSNull class]]
						&&![clientname isEqualToString:@""]) {
						[timeSheetEntryObject setClientName:clientname];
						[timeSheetEntryObject setClientIdentity:clientidentity];
					}
					if (projectname != nil && ![projectname isKindOfClass:[NSNull class]]
						&&![projectname isEqualToString:@""]) {
						[timeSheetEntryObject setProjectName:projectname];
						[timeSheetEntryObject setProjectIdentity:projectidentity];
					}
					
				}else if (notAgainstProjects) {
					if (activitiesEnabled) {
						NSString *activityname		= [timeEntryDict objectForKey:@"activityName"];
						NSString *activityidentity	= [timeEntryDict objectForKey:@"activityIdentity"];
						
						if (activityname != nil && ![activityname isKindOfClass:[NSNull class]]) {
							[timeSheetEntryObject setActivityName:activityname];
						}
						if (activityidentity != nil && ![activityidentity isKindOfClass:[NSNull class]]) {
							[timeSheetEntryObject setActivityIdentity:activityidentity];	
						}
						
					}
				}
				NSString *taskname		  = [timeEntryDict objectForKey:@"taskName"];
				NSString *taskidentity	  = [timeEntryDict objectForKey:@"taskIdentity"];
				NSString *comments		  = [timeEntryDict objectForKey:@"comments"];
				NSString *billingname     = [timeEntryDict objectForKey:@"billingName"];
				NSString *billingidentity = [timeEntryDict objectForKey:@"billingIdentity"];
                
				if (taskname != nil && ![taskname isKindOfClass:[NSNull class]]
					&&![taskname isEqualToString:@""]) {
					//[timeSheetEntryObject setTaskName:taskname];
					[timeSheetEntryObject.taskObj setTaskName:taskname];
				}
				if (taskidentity != nil && ![taskidentity isKindOfClass:[NSNull class]]
					&&![taskidentity isEqualToString:@""]) {
					//[timeSheetEntryObject setTaskIdentity:taskidentity];
					[timeSheetEntryObject.taskObj setTaskIdentity:taskidentity];
				}
				if (comments != nil && ![comments isKindOfClass:[NSNull class]]) {
					[timeSheetEntryObject setComments:comments];
				}
				if (billingname != nil && ![billingname isKindOfClass:[NSNull class]]) {
					[timeSheetEntryObject setBillingName:billingname];
				}
				if (billingidentity != nil && ![billingidentity isKindOfClass:[NSNull class]]) {
					[timeSheetEntryObject setBillingIdentity:billingidentity];
				}
				//commented below check for release 1 as decimal is for release1.
				//[timeFormat isEqualToString:@"Decimal"]
				//if (YES) {
                RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
                if (!appDelegate.isLockedTimeSheet) 
                {
                    NSString *noOfHours = [NSString stringWithFormat:@"%0.02f",[[timeEntryDict objectForKey:@"durationDecimalFormat"]floatValue]];
					[timeSheetEntryObject setNumberOfHours:noOfHours];
                }
                else
                {
                    if([hourFormat isEqualToString:@"Decimal"])
                    {
                        NSString *noOfHours = [NSString stringWithFormat:@"%0.02f",[[timeEntryDict objectForKey:@"durationDecimalFormat"]floatValue]];
                        [timeSheetEntryObject setNumberOfHours:noOfHours];
                    }
                    else
                    {
                        
                        [timeSheetEntryObject setNumberOfHours:[timeEntryDict objectForKey:@"durationHourFormat"]];
                    }
                }
                
                
                [timeSheetEntryObject setInTime:[timeEntryDict objectForKey:@"time_in"]];
                [timeSheetEntryObject setOutTime:[timeEntryDict objectForKey:@"time_out"]];
                
				NSMutableArray *totalTimeEntries = [timeEntryObjectsDictionary objectForKey:stringDate];
                
                [timeSheetEntryObject setActivityName:[timeEntryDict objectForKey:@"activityName"]];
                [timeSheetEntryObject setActivityIdentity:[timeEntryDict objectForKey:@"activityIdentity"]];
                
				[totalTimeEntries addObject:timeSheetEntryObject];
				
			}	
		}
		
		//DLog(@"Total Time Entries %@",timeEntryObjectsDictionary);
		if (timeoffentriesArray != nil && [timeoffentriesArray count]>0) {
			for ( NSDictionary *timeOffDict in timeoffentriesArray ) {
				
				//TODO: Create TimeOffEntry Object:DONE
				G2TimeOffEntryObject *timeOffEntryObject=[[G2TimeOffEntryObject alloc]init];
				NSString *identity			  = [timeOffDict objectForKey:@"identity"];
				NSString *stringDate		  = [timeOffDict objectForKey:@"entryDate"];
				NSString *sheetId			  = [timeOffDict objectForKey:@"sheetIdentity"];
				NSString *entrytype			  = [timeOffDict objectForKey:@"entryType"];
				NSDate   *entrydate			  = [G2Util convertStringToDate:stringDate];
				NSString *comments			  = [timeOffDict objectForKey:@"comments"];
				NSString *timeOffCodeType	  = [timeOffDict objectForKey:@"timeOffTypeName"];
				NSString *timeOffCodeIdentity = [timeOffDict objectForKey:@"timeOffIdentity"];
				
				[timeOffEntryObject setIdentity:identity];
				[timeOffEntryObject setTimeOffDate:entrydate];
				[timeOffEntryObject setSheetId:sheetId];
				[timeOffEntryObject setEntryType:entrytype];
				[timeOffEntryObject setComments:comments];
				[timeOffEntryObject setTimeOffCodeType:timeOffCodeType];
				[timeOffEntryObject setTypeIdentity:timeOffCodeIdentity];
				
				RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
                if (!appDelegate.isLockedTimeSheet) 
                {
                    NSString *noOfHours = [NSString stringWithFormat:@"%0.02f",[[timeOffDict objectForKey:@"durationDecimalFormat"]floatValue]];
					[timeOffEntryObject setNumberOfHours:noOfHours];
                }
                else
                {
                    if([hourFormat isEqualToString:@"Decimal"])
                    {
                        NSString *noOfHours = [NSString stringWithFormat:@"%0.02f",[[timeOffDict objectForKey:@"durationDecimalFormat"]floatValue]];
                        [timeOffEntryObject setNumberOfHours:noOfHours];
                    }
                    else
                    {
                       
                        [timeOffEntryObject setNumberOfHours:[timeOffDict objectForKey:@"durationHourFormat"]];
                        NSString *noOfHours = [NSString stringWithFormat:@"%0.02f",[[timeOffDict objectForKey:@"durationDecimalFormat"]floatValue]];
                        [timeOffEntryObject setNumberOfAlternativeHours:noOfHours];
                    }
                }

               
				NSMutableArray *totalTimeOffEntries = [timeEntryObjectsDictionary objectForKey:stringDate];
				[totalTimeOffEntries addObject:timeOffEntryObject];
				
			}	
		}
		//DLog(@"Total Time Entries %@",timeEntryObjectsDictionary);
		//if (bookedtimeOffentriesArray != nil && [bookedtimeOffentriesArray count]>0) {
			//for (NSDictionary *bookedTimeOffDict in bookedtimeOffentriesArray) {
			if (distinctTimeOffEntryDates != nil && [distinctTimeOffEntryDates count]>0) {
				for (NSDictionary *bookedTimeOffDict in distinctTimeOffEntryDates) {
				//TODO: Create BookedTimeOff Entry Object
				G2BookedTimeOffEntry *bookedTimeOffEntryObject = [[G2BookedTimeOffEntry alloc] init];
				NSString *identity				  = [bookedTimeOffDict objectForKey:@"identity"];
				NSString *sheetId				  = [bookedTimeOffDict objectForKey:@"sheetIdentity"];
				NSString *entrytype				  = [bookedTimeOffDict objectForKey:@"entryType"];
				NSString *entryDateString	      = [bookedTimeOffDict objectForKey:@"entryDate"];
				NSDate   *bookedEntryDate	      = [G2Util convertStringToDate:entryDateString];
				NSString *comments				  = [bookedTimeOffDict objectForKey:@"comments"];
				NSString *timeOffTypeName		  = [bookedTimeOffDict objectForKey:@"typeName"];
				NSString *timeOffTypeIdentity	  = [bookedTimeOffDict objectForKey:@"typeIdentity"];
				NSString *approvalStatus		  = [bookedTimeOffDict objectForKey:@"approvalStatus"];
				
				[bookedTimeOffEntryObject setIdentity:identity];
				[bookedTimeOffEntryObject setSheetId:sheetId];
				[bookedTimeOffEntryObject setEntryType:entrytype];
				[bookedTimeOffEntryObject setComments:comments];
				[bookedTimeOffEntryObject setTypeName:timeOffTypeName];
				[bookedTimeOffEntryObject setTypeIdentity:timeOffTypeIdentity];
				[bookedTimeOffEntryObject setEntryDate:bookedEntryDate];
				[bookedTimeOffEntryObject setApprovalStatus:approvalStatus];
				
                    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
                    if (!appDelegate.isLockedTimeSheet) 
                    {
                        NSString *noOfHours = [NSString stringWithFormat:@"%0.02f",[[bookedTimeOffDict objectForKey:@"decimalDuration"]floatValue]];
                        [bookedTimeOffEntryObject setNumberOfHours:noOfHours];
                    }
                    else
                    {
                        if([hourFormat isEqualToString:@"Decimal"])
                        {
                            NSString *noOfHours = [NSString stringWithFormat:@"%0.02f",[[bookedTimeOffDict objectForKey:@"decimalDuration"]floatValue]];
                            [bookedTimeOffEntryObject setNumberOfHours:noOfHours];
                        }
                        else
                        {
                           
                            [bookedTimeOffEntryObject setNumberOfHours:[bookedTimeOffDict objectForKey:@"hourDuration"]];
                        }
                    }

				
				
				NSMutableArray *totalBookedTimeOffEntries = [timeEntryObjectsDictionary objectForKey:entryDateString];
				[totalBookedTimeOffEntries addObject:bookedTimeOffEntryObject];
				
			}
		}
	}
	//DLog(@"Total Time Entries %@",timeEntryObjectsDictionary);
	[keysArray sortUsingSelector:@selector(compare:)];
	
   NSArray *reversekeyarray = [[keysArray reverseObjectEnumerator] allObjects];

	//DLog(@"Key Array %@",reversekeyarray);
	self.keyArray =[NSMutableArray arrayWithArray:reversekeyarray];
}

-(NSString *)getFormattedEntryDateString:(NSString *)_stringdate{
	NSDate *date = nil;
	if (_stringdate != nil) {
		date				= [G2Util convertStringToDate:_stringdate];
		NSString *formattedDateStr = @"";
		formattedDateStr = [G2Util getFormattedRegionalDateString:date];
		//DLog(@"Formatted Date %@",formattedDateStr);
		return formattedDateStr;
	}
	return nil;
}
-(void)validateRequiredFields{
	
	for (int i =0;i<[keyArray count];i++) {
		NSMutableArray *entries     = [timeEntryObjectsDictionary objectForKey:[keyArray objectAtIndex:i]];
		for (int j=0; j<[entries count]; j++) {
			id entryObj = [entries objectAtIndex:j];
			if ([entryObj isKindOfClass:[G2TimeSheetEntryObject class]]) {
				NSMutableArray *errorFieldsEntry = [NSMutableArray array];
				//NSMutableArray *errorfields = [entryObj errorFields];
				NSMutableArray *errorfields = [NSMutableArray array];
				NSMutableArray *availablefields = [NSMutableArray array];	
				
				if (againstProjects || Both) {
					if ([entryObj clientName]== nil || [[entryObj clientName]isEqualToString:@""]) {
						[errorfields addObject:TimeEntryClient];
					}else {
						[availablefields addObject:[entryObj clientName]];
					}
					if ([entryObj projectName]== nil || [[entryObj clientName]isEqualToString:@""]) {
						[errorfields addObject:TimeEntryProject];
					}else {
						[availablefields addObject:[entryObj projectName]];
					}
				}
				/*if (notAgainstProjects) {
				 if (activitiesEnabled) {
				 if ([entryObj activityName] == nil || [[entryObj activityName] isEqualToString:@""]) {
				 [errorfields addObject:TimeEntryActivity];
				 }
				 }
				 }*///Commented because, Activity has been dropped off for current release
				
				if (!allowBlankComments) {
					if ([entryObj comments] == nil || [[entryObj comments]isEqualToString:@""]) {
						[errorfields addObject:TimeEntryComments];
					}
				}
				//DLog(@"ERROR FIELDS ArrayCount %d",[errorfields count]);
				if ([errorfields count]>0) {
					[entryObj setMissingFields:errorfields];
					if ([availablefields count]>0) {
						[entryObj setAvailableFields:availablefields];
					}
					[errorFieldsEntry addObject:entryObj];
					[missingRequiredFields setObject:errorFieldsEntry forKey:[keyArray objectAtIndex:i]];
				}
			}
		}
	}	
}
//TODO: UDF's validation :DONE
-(BOOL)validateSheetLevelUDFs {
	NSMutableArray *requiredUdfsArray = [timesheetModel getEnabledAndRequiredTimeSheetLevelUDFs];
	NSMutableArray *requiredDefaultUDFsArray = [NSMutableArray array];
	for (NSDictionary *udfDict in requiredUdfsArray) {
		id defaultValue = nil;
		NSString *udfIdentity = [udfDict objectForKey:@"identity"];
		id udfType			  = [udfDict objectForKey:@"udfType"];
		if ([udfType isEqualToString:@"Text"]) {
			defaultValue = [udfDict objectForKey:@"textDefaultValue"];
		}
		else if ([udfType isEqualToString:@"Numeric"]) {
			defaultValue = [udfDict objectForKey:@"numericDefaultValue"];
		}
		else if ([udfType isEqualToString:@"Date"]) {
			defaultValue = [udfDict objectForKey:@"dateDefaultValue"];
			if ([udfDict objectForKey:@"isDateDefaultValueToday"] != nil) {
				defaultValue = [udfDict objectForKey:@"isDateDefaultValueToday"];
			}
		}
		else if ([udfType isEqualToString:@"DropDown"]) {
			defaultValue = [timesheetModel getDefaultOptionForDropDownUDF:udfIdentity];
		}
		
		if (defaultValue == nil && [[udfDict objectForKey:@"required"] intValue] == 1) {
			[requiredDefaultUDFsArray addObject:[udfDict objectForKey:@"name"]];
		}
		
	}
	
	NSMutableArray *sheetUDFsArray = [timesheetModel getUDFsforTimesheetEntry:sheetIdentity :
									  TIMESHEET_SHEET_LEVEL_UDF_KEY];
	for (NSDictionary *sheetUdf in sheetUDFsArray) {
		if ([requiredDefaultUDFsArray containsObject:[sheetUdf objectForKey:@"udf_name"]]
			&& ([sheetUdf objectForKey:@"udfValue"] == nil ||
				[[sheetUdf objectForKey:@"udfValue"] isKindOfClass:[NSNull class]]
				|| [[sheetUdf objectForKey:@"udfValue"] isEqualToString:@""]) ) {
				[self showRequiredSheetUDFAlert:[sheetUdf objectForKey:@"udf_name"]];
				return NO;
			}
	}
	return YES;
}

-(void)showRequiredSheetUDFAlert: (NSString *)udfName {
	NSString *errorHeader = [NSString stringWithFormat:@"\"%@\" %@",udfName,RPLocalizedString(SHEET_UDF_ERROR_HEADER,"")];
//	[Util errorAlert:RPLocalizedString(errorHeader,@"") errorMessage:NSLocalizedString (TIMESHHET_UDF_ERROR_MESSAGE,@"")];
    [G2Util errorAlert:@"" errorMessage:[NSString stringWithFormat:@"%@ /n %@",errorHeader,RPLocalizedString(TIMESHHET_UDF_ERROR_MESSAGE,@"")]];//DE1231//Juhi
}
-(void)popToListOfTimeSheets{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_SUBMIT_SUCCESS_NOTIFICATION object:nil];
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
    //US4805
    if (self.isUnsubmitClicked)
    {
        NSMutableArray *timesheetArray=[timesheetModel getTimesheetsForSheetFromDB:sheetIdentity];
       
        self.sheetApprovalStatus = [[timesheetArray objectAtIndex:0] objectForKey:@"approvalStatus"];
        timeSheetObj.approversRemaining=[[[timesheetArray objectAtIndex:0] objectForKey:@"approversRemaining"]boolValue];
        timeSheetObj.status=self.sheetApprovalStatus;
        [self createAddBarButton];//US4805
               
        if ([[[timesheetArray objectAtIndex:0] objectForKey:@"disclaimerAccepted"] isEqualToString:@"[Null]"]) {
            timeSheetObj.disclaimerAccepted=nil;
        }
        
        customFooterView=nil;
        [self.timeEntriesTableView reloadData];
        [self createTimeEntryFooterView];
       
    }
    else {
         [self.navigationController popViewControllerAnimated:YES];
    }
	
}
#pragma mark footerView
#pragma mark footerButtonsView

-(void)createTimeEntryFooterView {
	RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    G2PermissionsModel *permission=[[G2PermissionsModel alloc]init];
    BOOL reopenPermission=[permission checkUserPermissionWithPermissionName:@"ReopenTimesheet"];//US4660//Juhi

    if ( appDelegate.isAttestationPermissionTimesheets) 
    {
        if (customFooterView == nil) {
            G2EntriesTableFooterView *tempcustomFooterView = [[G2EntriesTableFooterView alloc]initWithFrame:
                                                            CGRectMake(0.0, 0.0, self.timeEntriesTableView.frame.size.width, 140) forSheetStatus:sheetApprovalStatus andDisclaimerAcceptedDate:self.timeSheetObj.disclaimerAccepted];
            self.customFooterView  =tempcustomFooterView;
            
            [customFooterView setEventHandler:self];
            if (unsubmitAllowed && ![timeSheetObj approversRemaining]) //US4660//Juhi
            {
                [customFooterView setUnsubmitAllowed:unsubmitAllowed];
            }
            else if(!unsubmitAllowed && ![timeSheetObj approversRemaining] && reopenPermission)
                [customFooterView setUnsubmitAllowed:YES];
        }

        if (appDelegate.isLockedTimeSheet) 
        {
            if ([[preferencesObj hourFormat] isEqualToString:@"Decimal"]) {
                [customFooterView addTotalLabelView:totalHours];
            }
            else
            {
                [customFooterView addTotalLabelView:[NSString stringWithFormat:@"%@",totalHours]];
            }
        }
        else
        {
            [customFooterView addTotalLabelView:totalHours];
        }
        
       
        NSMutableArray *unsubmittedSheets = [[NSUserDefaults standardUserDefaults] objectForKey:UNSUBMITTED_TIME_SHEETS];
        if (unsubmittedSheets != nil && [unsubmittedSheets containsObject:sheetIdentity]) {
            [customFooterView populateFooterView: sheetApprovalStatus :YES :reopenPermission :[timeSheetObj approversRemaining]];//US4660//Juhi
        }
        else {
            [customFooterView populateFooterView: sheetApprovalStatus :NO :reopenPermission :[timeSheetObj approversRemaining]];//US4660//Juhi
        }
        
        UIView *buttonView=self.customFooterView.footerButtonsView;
        BOOL isButtonFound=FALSE;
        for (id subView in buttonView.subviews)
        {
            if ([subView isKindOfClass:[UIButton class]]) 
            {
                UIButton *btn=(UIButton *)subView;
                float extraHeight=btn.frame.origin.y+btn.frame.size.height+30.0;
                CGRect frame=self.customFooterView.frame;
                float currentHeight=frame.size.height;
                if (extraHeight>currentHeight) {
                    currentHeight=extraHeight;
                    frame.size.height=currentHeight+30.0;
                    ///The button shouldn't be radio button
                    if (frame.size.height!=365.0)
                    {
                        self.customFooterView.frame=frame;
                        isButtonFound=TRUE;
                    }
                    
                }
            }
        }
        
        
        if(!isButtonFound)
        {
            int countLabel=0;
            int countLabelValidation=0;
            if ( appDelegate.isAcceptanceOfDisclaimerRequired) 
            {
                countLabelValidation=2;
            }
            else
            {
                countLabelValidation=1;
            }
            
            for (id subView in buttonView.subviews)
            {
                if ([subView isKindOfClass:[UILabel class]]) 
                {
                    if (countLabel==countLabelValidation) 
                    {
                        UILabel *label=(UILabel *)subView;
                        float extraHeight=label.frame.origin.y+label.frame.size.height+30.0;
                        CGRect frame=self.customFooterView.frame;
                        float currentHeight=frame.size.height;
                        if (extraHeight>currentHeight) {
                            currentHeight=extraHeight;
                            frame.size.height=currentHeight+30.0;
                            self.customFooterView.frame=frame;
                            
                        }
                        
                    }
                    countLabel++;
                }
            }
            
        }
        
        [self.timeEntriesTableView setTableFooterView:customFooterView];

    }
    
    else
    {
        //DE5750//Juhi
        float footerHeight=0.0;
        
        if ([sheetApprovalStatus isEqualToString:APPROVED_STATUS]) 
        {
            //US4660//Juhi
            if (reopenPermission) {
                footerHeight=140;
            }
            else
                footerHeight=35;
        }
        else if ([sheetApprovalStatus isEqualToString:G2WAITING_FOR_APRROVAL_STATUS])
        {
            if (unsubmitAllowed && ![timeSheetObj approversRemaining]) //US4660//Juhi
            {
                footerHeight=140;
            }
            else if(!unsubmitAllowed && ![timeSheetObj approversRemaining] && reopenPermission)
                footerHeight=140;
            //US4660//Juhi        
            else if(reopenPermission && [timeSheetObj approversRemaining])
                footerHeight=140;
            else
                footerHeight=35;
        } 

        else
            footerHeight=140;
        
        if (customFooterView == nil) {
            G2EntriesTableFooterView *tempcustomFooterView = [[G2EntriesTableFooterView alloc]initWithFrame:
                                                            CGRectMake(0.0, 0.0, self.timeEntriesTableView.frame.size.width, footerHeight)];
            self.customFooterView  =tempcustomFooterView;
           
            [customFooterView setEventHandler:self];
           if (unsubmitAllowed && ![timeSheetObj approversRemaining]) //US4660//Juhi
           {
                [customFooterView setUnsubmitAllowed:unsubmitAllowed];
            }
           else if(!unsubmitAllowed && ![timeSheetObj approversRemaining] && reopenPermission)
               [customFooterView setUnsubmitAllowed:YES];
        }
        RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
        
        if (appDelegate.isLockedTimeSheet) 
        {
            if ([[preferencesObj hourFormat] isEqualToString:@"Decimal"]) {
                [customFooterView addTotalLabelView:totalHours];
            }
            else
            {
                [customFooterView addTotalLabelView:[NSString stringWithFormat:@"%@",totalHours]];
            }
        }
        else
        {
            [customFooterView addTotalLabelView:totalHours];
        }
        
        NSMutableArray *unsubmittedSheets = [[NSUserDefaults standardUserDefaults] objectForKey:UNSUBMITTED_TIME_SHEETS];
        if (unsubmittedSheets != nil && [unsubmittedSheets containsObject:sheetIdentity]) {
            [customFooterView populateFooterView: sheetApprovalStatus :YES :reopenPermission :[timeSheetObj approversRemaining]];//US4660//Juhi
        }
        else {
            [customFooterView populateFooterView: sheetApprovalStatus :NO :reopenPermission :[timeSheetObj approversRemaining]];//US4660//Juhi
        }
        
        
        [self.timeEntriesTableView setTableFooterView:customFooterView];
    }
   
}

#pragma mark Button 
#pragma mark ButtonActions

-(void)addTimeEntryAction:(id)sender{
    
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
-(void)goToTimeSheets:(id)sender{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark AlertView Methods

-(void) confirmAlert :(NSString *)_buttonTitle confirmMessage:(NSString*) message {
	
	UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:nil message:message
															  delegate:self cancelButtonTitle:RPLocalizedString(CANCEL_BTN_TITLE, @"Cancel") otherButtonTitles:_buttonTitle,nil];
	[confirmAlertView setDelegate:self];
	[confirmAlertView setTag:0];
	if ([_buttonTitle isEqualToString: RPLocalizedString(SUBMIT,@"")]
		||[_buttonTitle isEqualToString: RPLocalizedString(RESUBMIT,@"")]) {
		[confirmAlertView setTag:1];
	}else if ([_buttonTitle isEqualToString: RPLocalizedString(DELETE,@"")]) {
		[confirmAlertView setTag:2];
	}else if ([_buttonTitle isEqualToString: RPLocalizedString(UNSUBMIT,@"")]) {
		[confirmAlertView setTag:3];
	}
//    //US4660//Juhi
//    else if([_buttonTitle isEqualToString: RPLocalizedString(REOPEN,@"")]){
//        [confirmAlertView setTag:4];
//    }
	[confirmAlertView show];
	
	
	
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex ==1&&alertView.tag==1) { 
		//commented below validation for required fields as per DE2221
		//[self validateRequiredFields];
		if (![self validateSheetLevelUDFs]) {
			return;
		}
		if (missingRequiredFields != nil && [missingRequiredFields count]>0) {
			//TODO: Push Controller to Submission Error View Controller to display the errors:DONE
			G2SubmissionErrorViewController *submissionErrorViewController = [[G2SubmissionErrorViewController alloc] 
																			initWithPermissionSet:permissionsObj :preferencesObj];
			[submissionErrorViewController setErrorSheet:selectedSheet];
			[submissionErrorViewController entriesMissingFields:missingRequiredFields];
			[submissionErrorViewController setParentController:self];
			[self.navigationController pushViewController:submissionErrorViewController animated:YES];
			
			
		}else {
			//TODO: Send Request to Submit the Time Sheet:DONE
			//TODO: Handle request & pop the view controller:DONE
			[[G2RepliconServiceManager timesheetService] submitTimesheetWithComments:sheetIdentity 
																		  comments:@""];
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:SubmittingMessage];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToListOfTimeSheets) 
														 name:TIMESHEET_SUBMIT_SUCCESS_NOTIFICATION object:nil];
		}
	}
	if (buttonIndex ==1 &&alertView.tag==2) {        
	}
	if (buttonIndex ==1 &&alertView.tag==3) {
        self.isUnsubmitClicked=YES;
		[[G2RepliconServiceManager timesheetService] unsubmitTimesheetWithIdentity:sheetIdentity];
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:UnSubmittingMessage];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToListOfTimeSheets) 
													 name:TIMESHEET_SUBMIT_SUCCESS_NOTIFICATION object:nil];
	}
//    //US4660//Juhi
//    if (buttonIndex==1 && alertView.tag==4) {
//        
//        [[RepliconServiceManager timesheetService] reopenTimesheetWithIdentity:sheetIdentity];
//        [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:ReopeningMessage];
//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popToListOfTimeSheets) 
//													 name:TIMESHEET_SUBMIT_SUCCESS_NOTIFICATION object:nil];
//    }

    if (alertView.tag==9999) 
    {
         RepliconAppDelegate *appDelegate= (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
        // FOR TIME ENTRY
        if (buttonIndex==1)
        {
            
            if (appDelegate.isLockedTimeSheet)
            {
                appDelegate.selectedTab=0;
                [[[UIApplication sharedApplication] delegate] performSelector: @selector(flipToTabbarController:) 
                                                                   withObject:[NSNumber numberWithInt:0]];
            }
            
            else 
            {
                [self addNewTimeEntryActionFromAlert];
            }
            
            
        }
        else if (buttonIndex==2)
        {
           
            G2TimeEntryViewController *timeEntryViewCtrl = [[G2TimeEntryViewController alloc] 
                                                                      initWithEntryDetails:nil sheetId:nil screenMode:ADD_ADHOC_TIMEOFF 
                                                                      permissionsObj:permissionsObj preferencesObj:preferencesObj:appDelegate.isInOutTimesheet:appDelegate.isLockedTimeSheet:self];
            
            
            [timeEntryViewCtrl setIsEntriesAvailable:YES];
            [timeEntryViewCtrl setSelectedSheetIdentity:[timeSheetObj identity]];
            [timeEntryViewCtrl setSheetStatus:[timeSheetObj status]];
            UINavigationController *tempnavcontroller = [[UINavigationController alloc]initWithRootViewController:timeEntryViewCtrl];
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
    tappedRowIndex=-1;
    G2SupportDataModel *supportdataModel= [[G2SupportDataModel alloc] init];
    //Fix for DE3600//Juhi
    againstProjects    = [self checkForPermissionExistence:@"ProjectTimesheet"];
//    BOOL notagainstProjects = [self checkForPermissionExistence:@"NonProjectTimesheet"];
    BOOL timesheetRequired   = [self checkForPermissionExistence:@"TimesheetActivityRequired"];
//    int userProjectsCount = [supportdataModel getUserProjectsCount];
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
            G2TimeEntryViewController *addNewTimeEntryViewController = [[G2TimeEntryViewController alloc] 
                                                                      initWithEntryDetails:nil sheetId:nil screenMode:ADD_TIME_ENTRY 
                                                                      permissionsObj:permissionsObj preferencesObj:preferencesObj:appDelegate.isInOutTimesheet:appDelegate.isLockedTimeSheet:self];
            [addNewTimeEntryViewController setIsEntriesAvailable:YES];
            [addNewTimeEntryViewController setSelectedSheetIdentity:[timeSheetObj identity]];
            [addNewTimeEntryViewController setSheetStatus:[timeSheetObj status]];
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
    //	if (userProjectsCount > 0) {
    //		TimeEntryViewController *addNewTimeEntryViewController = [[TimeEntryViewController alloc] 
    //												initWithEntryDetails:nil sheetId:nil screenMode:ADD_TIME_ENTRY 
    //												permissionsObj:permissionsObj preferencesObj:preferencesObj];
    //		[addNewTimeEntryViewController setIsEntriesAvailable:YES];
    //		[addNewTimeEntryViewController setSelectedSheetIdentity:[timeSheetObj identity]];
    //		[addNewTimeEntryViewController setSheetStatus:[timeSheetObj status]];
    //		
    //		UINavigationController *navcontroller = [[UINavigationController alloc]initWithRootViewController:addNewTimeEntryViewController];
    //		[navcontroller.navigationBar setTintColor:RepliconStandardNavBarTintColor];
    //		[self presentViewController:navcontroller animated:YES completion:nil];
    //		
        //	}
    else {
        RepliconAppDelegate *appDelegate= (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
        G2TimeEntryViewController *addNewTimeEntryViewController = [[G2TimeEntryViewController alloc] 
                                                                  initWithEntryDetails:nil sheetId:nil screenMode:ADD_TIME_ENTRY 
                                                                  permissionsObj:permissionsObj preferencesObj:preferencesObj:appDelegate.isInOutTimesheet:appDelegate.isLockedTimeSheet:self];
        [addNewTimeEntryViewController setIsEntriesAvailable:YES];
        [addNewTimeEntryViewController setSelectedSheetIdentity:[timeSheetObj identity]];
        [addNewTimeEntryViewController setSheetStatus:[timeSheetObj status]];
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

- (void)alertViewCancel:(UIAlertView *)alertView{
}

#pragma mark -
#pragma mark EntriesFooterButtonsProtocol

-(void) handleSubmitAction {
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
		//[Util errorAlert:RPLocalizedString(NoInternetConnectivity,@"") errorMessage:NSLocalizedString (YouCannotSubmitTimesheetWhileOffline,@"")];
		//ravi - DE2983			
#ifdef PHASE1_US2152
		[G2Util showOfflineAlert];
		return;
#endif			
	}
	
	NSMutableArray *unsubmittedSheets = [[NSUserDefaults standardUserDefaults]
										 objectForKey:UNSUBMITTED_TIME_SHEETS];
	BOOL resubmit = [unsubmittedSheets containsObject:sheetIdentity];
	if (sheetApprovalStatus != nil && 
		([sheetApprovalStatus isEqualToString:REJECTED_STATUS] || resubmit)) {
		//TODO: show the Resubmit view to get resubmit comments 
		
        G2ResubmitTimesheetViewController *tempresubmitViewController = [[G2ResubmitTimesheetViewController alloc] init];
        self.resubmitViewController=tempresubmitViewController;
       
		
		[self.resubmitViewController setSheetIdentity:sheetIdentity];
		[self.resubmitViewController setSelectedSheet:selectedSheet];
		[self.resubmitViewController setAllowBlankComments:allowBlankComments];
        [self.resubmitViewController setActionType:@"ResubmitTimesheetEntry"];//US2669//Juhi//US4754
        [self.resubmitViewController setIsSaveEntry:NO ];
		[self.navigationController pushViewController:self.resubmitViewController animated:YES];
	}
	else {
		NSString * message = [NSString stringWithFormat:@"%@ ''%@'' %@?",RPLocalizedString(@"Submit", @"Submit"),selectedSheet,RPLocalizedString(@"timesheet for approval", @"timesheet for approval")];
		[self confirmAlert:RPLocalizedString(@"Submit", @"Submit")  confirmMessage:message];
	}
}

-(void) handleUnsubmitAction {
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
		//[Util errorAlert:RPLocalizedString(NoInternetConnectivity,@"") errorMessage:NSLocalizedString (YouCannotUnSubmitTimesheetWhileOffline,@"")];
		//ravi - DE2983			
#ifdef PHASE1_US2152
		[G2Util showOfflineAlert];
		return;
#endif			
	}
	else {
		NSString * message = [NSString stringWithFormat:@"%@ ''%@'' %@?",RPLocalizedString(@"Unsubmit", @"Unsubmit"),selectedSheet,RPLocalizedString(@"timesheet", @"timesheet")];
		[self confirmAlert:RPLocalizedString(@"Unsubmit", @"Unsubmit")  confirmMessage:message];
	}
	
}
-(void)handleResubmitAction{
}

//US4660//Juhi
-(void)handleReopenAction{
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
		//[Util errorAlert:RPLocalizedString(NoInternetConnectivity,@"") errorMessage:NSLocalizedString (YouCannotUnSubmitTimesheetWhileOffline,@"")];
		//ravi - DE2983			
#ifdef PHASE1_US2152
		[G2Util showOfflineAlert];
		return;
#endif			
	}
	else {
		//US4754
        if (sheetApprovalStatus != nil) {
            //TODO: show the Reopen view to get reopen comments 
            
            G2ResubmitTimesheetViewController *tempresubmitViewController = [[G2ResubmitTimesheetViewController alloc] init];
            self.resubmitViewController=tempresubmitViewController;
           
            
            [self.resubmitViewController setSheetIdentity:sheetIdentity];
            [self.resubmitViewController setSelectedSheet:selectedSheet];
            [self.resubmitViewController setAllowBlankComments:YES];
            [self.resubmitViewController setActionType:@"ReopenTimesheetEntry"];
            [self.resubmitViewController setIsSaveEntry:NO];
            [self.resubmitViewController setDelegate:self];//US4805
            [self.navigationController pushViewController:self.resubmitViewController animated:YES];
        }
	}
}

#pragma mark -
#pragma mark Approval history

-(void)approvalHistoryReceivedFromApi: (id)notificationObject {
	id approvalDetails = ((NSNotification *)notificationObject).object;
	[customFooterView populateFooterViewWithApprovalHistory:approvalDetails];
	[self.timeEntriesTableView setTableFooterView:customFooterView];
	
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
}
-(void)getApprovalHistoryForSheetAndShowFooterView {
	if (customFooterView == nil) {
		G2EntriesTableFooterView *tempcustomFooterView = [[G2EntriesTableFooterView alloc]initWithFrame:
							CGRectMake(0.0, 0.0, self.timeEntriesTableView.frame.size.width, 450)];
        self.customFooterView=tempcustomFooterView;
       
		[customFooterView setEventHandler:self];
        RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
        
        if (appDelegate.isLockedTimeSheet) 
        {
            if ([[preferencesObj hourFormat] isEqualToString:@"Decimal"]) {
                [customFooterView addTotalLabelView:totalHours];
            }
            else
            {
//                [customFooterView addTotalLabelView:[Util convertDecimalTimeToHourFormat:[NSString stringWithFormat:@"%@",totalHours]]];
                 [customFooterView addTotalLabelView:totalHours];
            }
        }
        else
        {
            [customFooterView addTotalLabelView:totalHours];
        }

		
		[customFooterView setUnsubmitAllowed:unsubmitAllowed];
	}
	
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
		[customFooterView populateFooterView: sheetApprovalStatus :NO :NO :[timeSheetObj approversRemaining]];//US4660//Juhi
		//[customFooterView populateFooterView: sheetApprovalStatus :NO :NO :NO];
		[self.timeEntriesTableView setTableFooterView:customFooterView];
	}else {
		[self.timeEntriesTableView setTableFooterView:customFooterView];
		[[G2RepliconServiceManager timesheetService] getApprovalHistoryFromApiForSheet:sheetIdentity];
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(approvalHistoryReceivedFromApi:) 
													 name:APPROVAL_HISTORY_NOTIFICATION object:nil];
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
	}
}

-(void)highlightTappedRowBackground:(NSIndexPath*)indexPath{
	
	G2CustomTableViewCell *cellObj = [self getTappedRowAtIndexPath:indexPath];
	if (cellObj == nil) {
		return;
	}


	//((UIImageView *)cellObj.selectedBackgroundView).image = selectionBackground;	
	[self.timeEntriesTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    //fixed leaks here
	
	[[cellObj upperLeft] setTextColor:iosStandaredWhiteColor];
	[[cellObj upperRight] setTextColor:iosStandaredWhiteColor];
	[[cellObj lowerLeft] setTextColor:iosStandaredWhiteColor];
	[[cellObj lowerRight] setTextColor:iosStandaredWhiteColor];
	//[cellObj setSelected:YES];
}

-(void)deSelectTappedRow{
	id cellObj = [self getTappedRowAtIndexPath:self.rowTapped];
	if (cellObj == nil) {
		return;
	}
	[self.timeEntriesTableView deselectRowAtIndexPath:self.rowTapped animated:YES];
	
    
    
    
    NSIndexPath *indexPath = [(UITableView *)self.timeEntriesTableView indexPathForCell: cellObj];
    NSString *sectionDate = [keyArray objectAtIndex:indexPath.section];
	NSMutableArray *entries = [timeEntryObjectsDictionary objectForKey:sectionDate];
    id timeEntryObject = [entries objectAtIndex:indexPath.row];
	if ([timeEntryObject isKindOfClass:[G2BookedTimeOffEntry class]]) 
    {
        [[cellObj upperLeft] setTextColor:RepliconStandardGrayColor];
        [[cellObj upperRight] setTextColor:RepliconStandardGrayColor];
        [[cellObj lowerLeft] setTextColor:RepliconStandardGrayColor];
        [[cellObj lowerRight] setTextColor:RepliconStandardGrayColor];
    }
    else
    {
        [[cellObj upperLeft] setTextColor:RepliconStandardBlackColor];
        [[cellObj upperRight] setTextColor:RepliconStandardBlackColor];
        [[cellObj lowerLeft] setTextColor:RepliconStandardBlackColor];
        [[cellObj lowerRight] setTextColor:RepliconStandardBlackColor];
    }
    
	
	//[cellObj setSelected:NO];
}
-(void)highlightTheCellWhichWasSelected{
	//[self highlightTappedRowBackground:self.rowTapped];//US4878 Ullas M L
}
-(G2CustomTableViewCell*)getTappedRowAtIndexPath:(NSIndexPath*)indexPath{
	G2CustomTableViewCell *rowCell = (G2CustomTableViewCell *)[self.timeEntriesTableView cellForRowAtIndexPath: indexPath]; 
	return rowCell;
}

-(void) updatedDisclaimerActionWithSelection:(BOOL)selectionStatus
{
   
    
        if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)	{
		

		[G2Util showOfflineAlert];
        
        [self revertRadioButton];
		return;

	}
    
//    DLog(@"---CURRENT UTC DATE = %@",currentUTCDate);
    [self.view addSubview:self.progressView];
    [self.view bringSubviewToFront:self.progressView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(disclaimerRequestServer) 
                                                 name:TIMESHEET_DISCLAIMER_UPDATED_SUCCESS_NOTIFICATION object:nil];
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    appDelegate.isUpdatingDisclaimerAcceptanceDate=TRUE;
    if (selectionStatus) 
    {
        [[G2RepliconServiceManager timesheetService] sendRequestToUpdateDisclaimerAcceptanceDate:self.sheetIdentity disclaimerAcceptanceDate:[NSDate date]];
    }
    else 
    {
        [[G2RepliconServiceManager timesheetService] sendRequestToUpdateDisclaimerAcceptanceDate:self.sheetIdentity disclaimerAcceptanceDate:nil];

    }
    
}



-(void)disclaimerRequestServer
{
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
     appDelegate.isUpdatingDisclaimerAcceptanceDate=FALSE;
     [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_DISCLAIMER_UPDATED_SUCCESS_NOTIFICATION object:nil];
    [self.progressView removeFromSuperview];
    
    
}


-(void)revertRadioButton {
	
    UIImage *currentRadioButtonImage= [self.customFooterView.radioButton imageForState:UIControlStateNormal];
//    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (currentRadioButtonImage == [G2Util thumbnailImage:G2CheckBoxSelectedImage]) {
        UIImage *deselectedRadioImage = [G2Util thumbnailImage:G2CheckBoxDeselectedImage];
        if (self.customFooterView.radioButton != nil) {
            [self.customFooterView.radioButton setImage:deselectedRadioImage forState:UIControlStateNormal];
            [self.customFooterView.radioButton setImage:deselectedRadioImage forState:UIControlStateHighlighted];
//            self.customFooterView.disclaimerTitleLabel.text=[NSString stringWithFormat:@"Accept %@",appDelegate.attestationTitleTimesheets];
            [self.customFooterView setDisclaimerSelected:NO];
        }
    }
    else
    {
        UIImage *selectedRadioImage = [G2Util thumbnailImage:G2CheckBoxSelectedImage];
        if (self.customFooterView.radioButton != nil) {
            [self.customFooterView.radioButton setImage:selectedRadioImage forState:UIControlStateNormal];
            [self.customFooterView.radioButton setImage:selectedRadioImage forState:UIControlStateHighlighted];
//            self.customFooterView.disclaimerTitleLabel.text=[NSString stringWithFormat:@"%@ Accepted",appDelegate.attestationTitleTimesheets];
            [self.customFooterView setDisclaimerSelected:YES];
        }
    }
    
    
}
//US4805
-(void)createAddBarButton{
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if (!appDelegate.isLockedTimeSheet) 
    {
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                   target:self
                                                                                   action:@selector(addTimeEntryAction:)];
        
        
        if (![sheetApprovalStatus isEqualToString:G2WAITING_FOR_APRROVAL_STATUS]
            && ![sheetApprovalStatus isEqualToString:APPROVED_STATUS]) {
            [self.navigationItem setRightBarButtonItem:addButton animated:NO];
        }
    
        
    }
    else 
    {
        if (appDelegate.isTimeOffEnabled) 
        {
            
            UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                       target:self
                                                                                       action:@selector(addTimeEntryAction:)];
            
            if (![sheetApprovalStatus isEqualToString:G2WAITING_FOR_APRROVAL_STATUS]
                && ![sheetApprovalStatus isEqualToString:APPROVED_STATUS]) {
                [self.navigationItem setRightBarButtonItem:addButton animated:NO];
            }
        
        }
    }

}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.resubmitViewController=nil;
    self.topToolbarlabel=nil;
    self.innerTopToolbarLabel=nil;
    self.timeEntriesTableView=nil;
    self.footerView=nil;
    self.descriptionLabel=nil;
    self.sectionHeader=nil;
    self.sectionHeaderlabel=nil;
    self.sectionHeadertotalhourslabel=nil;
    self.customFooterView=nil;
    self.mealHeaderLabel=nil;
    self.customView=nil;
}




@end
