//
//  ApprovalsUsersListOfTimeEntriesViewController.m
//  Replicon
//
//  Created by Dipta Rakshit on 2/7/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "G2ApprovalsUsersListOfTimeEntriesViewController.h"
#import "G2ApprovalsScrollViewController.h"
#import "RepliconAppDelegate.h"


@implementation G2ApprovalsUsersListOfTimeEntriesViewController
@synthesize timeEntriesTableView,innerTopToolbarLabel;
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
@synthesize  approvalsModel;
@synthesize currentViewTag;
@synthesize  footerView;
@synthesize  sectionHeader;
@synthesize customFooterView;
@synthesize isInOutFlag,isLockedTimeSheet;
@synthesize delegate;
@synthesize mealHeaderLabel;
@synthesize customView;
@synthesize showMealCustomView;
@synthesize  totalNumberOfView;//US4637//Juhi
@synthesize currentNumberOfView;//US4637//Juhi
@synthesize isShortenRows;

enum  {
	APPROVE_BUTTON_TAG_G2,
	REJECT_BUTTON_TAG_G2,
    COMMENTS_TEXTVIEW_TAG_G2,
    REOPEN_BUTTON_TAG_G2,
};


#define DEFAULT_ISONAME @"en"

NSString *approvals_DefaultISOStr=nil;

int approvalTappedSectionIndex=-1;
int approvalTappedRowIndex=-1;

#pragma mark -
#pragma mark init

- (id) init
{
	self = [super init];
	if (self != nil) {
		if(timeEntryObjectsDictionary==nil){
            NSMutableDictionary *temptimeEntryObjectsDictionary=[[NSMutableDictionary alloc]init];
			self.timeEntryObjectsDictionary=temptimeEntryObjectsDictionary;
            
		}
		if (approvalsModel == nil) {
            G2ApprovalsModel *tempapprovalsModel=[[G2ApprovalsModel alloc] init];
			self.approvalsModel = tempapprovalsModel;
           
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


-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]
	 removeObserver:self name:APPROVAL_TIMESHEETS_APPROVAL_REJECT_DONE_NOTIFICATION object:nil];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	[self.view setBackgroundColor:G2RepliconStandardBackgroundColor];

	
    approvals_DefaultISOStr=DEFAULT_ISONAME;
    
    NSMutableDictionary *tempCountRowsDict=[[NSMutableDictionary alloc]init];
    self.countRowsDict=tempCountRowsDict;
   
    
    
    
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)	{
		
#ifdef PHASE1_US2152
        [G2Util showOfflineAlert];
        return;
#endif
	}
	

    self.isShortenRows=FALSE;
    G2ApprovalsModel *approvalModel = [[G2ApprovalsModel alloc] init];
    BOOL isTimesheetDisplayActivities = [approvalModel checkUserPermissionWithPermissionName:@"TimesheetDisplayActivities" andUserId:self.timeSheetObj.userID];
    BOOL isTimesheetActivityRequired = [approvalModel checkUserPermissionWithPermissionName:@"TimesheetActivityRequired" andUserId:self.timeSheetObj.userID];
    BOOL isNotagainstProjects = [approvalModel checkUserPermissionWithPermissionName:@"NonProjectTimesheet" andUserId:self.timeSheetObj.userID];
    BOOL isAgainstProjects = [approvalModel checkUserPermissionWithPermissionName:@"ProjectTimesheet" andUserId:self.timeSheetObj.userID];
    
    
   
    
    BOOL isBoth=FALSE;
    
    if (isNotagainstProjects && isAgainstProjects)
    {
        isBoth=TRUE;
    }
    
    if (isTimesheetDisplayActivities || isTimesheetActivityRequired) 
    {
        isTimesheetDisplayActivities=TRUE;
    }
    if (!isTimesheetDisplayActivities && isNotagainstProjects && !isBoth) 
    {
        self.isShortenRows=TRUE;
    } 
    else if (isAgainstProjects && !isNotagainstProjects)
    {
        self.isShortenRows=FALSE;
    }
    else if (!isBoth && !isTimesheetDisplayActivities)
    {
        self.isShortenRows=TRUE;
    }
    

   


    if ([self.timeSheetObj.timeSheetType isEqualToString:APPROVAL_TIMESHEET_TYPE_INOUT] || [self.timeSheetObj.timeSheetType isEqualToString:APPROVAL_TIMESHEET_TYPE_LOCKEDINOUT]) 
    {
        self.isInOutFlag=TRUE;
        self.isLockedTimeSheet=FALSE;
    }
    else
    {
        self.isInOutFlag=FALSE;
        self.isLockedTimeSheet=FALSE;
    }
	
	NSDate   *startDt					 = [self.timeSheetObj startDate];
	NSString *convertedStartDt			 = [G2Util convertPickerDateToStringShortStyle:startDt];
	NSDate   *endDt						 = [self.timeSheetObj endDate];
	NSString *convertedEndDt			 = [G2Util convertPickerDateToStringShortStyle:endDt];
	NSArray  *startDateComponents        = [convertedStartDt componentsSeparatedByString:@","];
	NSString *trimmedStartDt			 = [startDateComponents objectAtIndex:0];
	
	NSArray  *endDateComponents          = [convertedEndDt componentsSeparatedByString:@","];
	NSString *trimmedEndDt			     = [endDateComponents objectAtIndex:0];
    NSString *sheetStatus=nil;
    
    if (self.timeSheetObj)
    {
       sheetStatus				 = [[NSString alloc]initWithString: [self.timeSheetObj status]];
        NSString *selSheet				 = [NSString stringWithFormat:@"%@ - %@",trimmedStartDt,
                                            trimmedEndDt];
        
        //Set TimeSheetObject
        [self setSelectedSheet:selSheet];
        [self setSheetApprovalStatus:sheetStatus];
        [self createTimeEntryObject:self.timeSheetObj 
                        permissions:self.permissionsObj
                        preferences:self.preferencesObj];
    	
		[self setIsEntriesAvailable:YES];
        
        
        
        

    }
    
    
    
    
    
    
//    [self createTimeEntryObject:timeSheetObj permissions:permissionsObj preferences:preferencesObj];
//	[timeEntriesTableView reloadData];
	
	if (isEntriesAvailable == NO){
        [footerView setHidden:YES];
		
		return;
		
	}else {
		UITableView *temptimeEntriesTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-95) style:UITableViewStylePlain];
        self.timeEntriesTableView=temptimeEntriesTableView;
        
		[timeEntriesTableView setDelegate:self];
		[timeEntriesTableView setDataSource:self];
		UIView *bckView = [UIView new];
		[bckView setBackgroundColor:G2RepliconStandardBackgroundColor];
		[timeEntriesTableView setBackgroundView:bckView];
		[self.view addSubview:timeEntriesTableView];
		

		[self createTimeEntryFooterView:sheetStatus];
         
        if ([timeSheetObj.status isEqualToString:APPROVED_STATUS] || [timeSheetObj.status isEqualToString:REJECTED_STATUS])
        {
            [self setDescription:@"Sally completed her project flying num under deadline."];
        }
	}
    
    G2ApprovalTablesHeaderView *headerView=[[G2ApprovalTablesHeaderView alloc]initWithFrame:CGRectMake(0, 0, 360.0, 55.0 ):sheetStatus];
    G2ApprovalsScrollViewController *scrollCtrl=(G2ApprovalsScrollViewController *)delegate;
    if (!scrollCtrl.hasPreviousTimeSheets) {
        headerView.previousButton.hidden=TRUE;
    }
    if (!scrollCtrl.hasNextTimeSheets) {
        headerView.nextButton.hidden=TRUE;
    }
//    headerView.timesheetStatus=sheetStatus;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    headerView.durationLbl.text=  [NSString stringWithFormat:@"%@ - %@", [dateFormatter stringFromDate:self.timeSheetObj.startDate],[dateFormatter stringFromDate:self.timeSheetObj.endDate]];
    headerView.countLbl.textColor =[UIColor blackColor];
    headerView.countLbl.text=[NSString stringWithFormat:@"%li of %lu",(long)currentNumberOfView,(unsigned long)totalNumberOfView];//US4637//Juhi
    
    
    headerView.userNameLbl.text=[NSString stringWithFormat:@"%@ %@",self.timeSheetObj.userFirstName,self.timeSheetObj.userLasttName];
    self.timeEntriesTableView.tableHeaderView = headerView;
    headerView.delegate=self;
   
    
    

	
}

-(void)viewWillAppearFromApprovalsTimeEntry
{
    
    if (isEntriesAvailable == NO){
        [footerView setHidden:YES];
		
		return;
		
	}
	
    [self performSelector:@selector(highlightTheCellWhichWasSelected) withObject:nil afterDelay:0];
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
                    NSMutableArray * timeEntryArr;
                    id timeEntryObj;
                    BOOL flag=FALSE;
                    timeEntryArr    = [timeEntryObjectsDictionary objectForKey:keyValue];
                    for (int j=0; j<[timeEntryArr count]; j++) {
                        timeEntryObj    = [timeEntryArr objectAtIndex:j];
                        if ([(NSString *)[timeEntryObj identity] isEqualToString:selectedEntriesIdentity  ]) {
                            approvalTappedRowIndex=j;
                            flag=TRUE;
                            break;
                        }
                    }
                    if (!flag) {
                        approvalTappedRowIndex=-1;
                    }
                    
                    if ([[countRowsDict objectForKey:[NSString stringWithFormat:@"%d",i]]intValue]==0)
                    {
                        approvalTappedSectionIndex=0;
                    }
                    else
                        approvalTappedSectionIndex=i;
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
        
        
        
        if (approvalTappedSectionIndex==section) {
            
            NSString *keyValue = [keyArray objectAtIndex:section];
            NSMutableArray * timeEntryArr;
            id timeEntryObj;
            BOOL flag=FALSE;
            timeEntryArr    = [timeEntryObjectsDictionary objectForKey:keyValue];
            for (int i=0; i<[timeEntryArr count]; i++) {
                timeEntryObj    = [timeEntryArr objectAtIndex:i];
                if ([(NSString *)[timeEntryObj identity] isEqualToString:selectedEntriesIdentity  ]) {
                    section=approvalTappedSectionIndex;
                    self.rowTapped= [NSIndexPath indexPathForRow:i inSection:approvalTappedSectionIndex];
                    
                    flag=TRUE;
                    break;
                }
            }
            if (!flag) {
                section=approvalTappedSectionIndex;
                if (approvalTappedRowIndex<0) {
                    self.rowTapped= [NSIndexPath indexPathForRow:0 inSection:approvalTappedSectionIndex];
                    
                }
                else
                {
                    self.rowTapped= [NSIndexPath indexPathForRow:approvalTappedRowIndex inSection:approvalTappedSectionIndex];
                    
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
//    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
	//DLog(@"\n titleForHeaderInSection:: ListOfTimeEntriesViewController::keyArray %@ =============>\n",keyArray);
	if ([keyArray count]>0) {
		NSString *headerTitle = [self getFormattedEntryDateString:[keyArray objectAtIndex:section]];
		NSString *hourFormat  = [preferencesObj hourFormat];
		NSString *timeEntryHoursStr    = [approvalsModel getTotalHoursforEntryWithDate:[keyArray objectAtIndex:section]  withformat:hourFormat withSheetIdentity:self.timeSheetObj.identity];
        
          
		NSString *totalHeaderString = nil;
        
        
		if (timeEntryHoursStr == nil) {
			NSString *bookedEntryHourStr   = [approvalsModel getTotalHoursforBookedEntryWithDate:[keyArray objectAtIndex:section]  withformat:hourFormat withSheetIdentity:self.timeSheetObj.identity ];
			if (bookedEntryHourStr != nil) {
                

//                if (!appDelegate.isLockedTimeSheet) 
//                {
//                    totalHeaderString = [NSString stringWithFormat:@"%@//%@",headerTitle,bookedEntryHourStr];
//                }
//                else
//                {
//                    if ([hourFormat isEqualToString:@"Decimal"]) {
//                        totalHeaderString = [NSString stringWithFormat:@"%@//%@",headerTitle,bookedEntryHourStr];
//                    }
//                    else
//                    {
//                        totalHeaderString = [NSString stringWithFormat:@"%@//%@",headerTitle,[NSString stringWithFormat:@"%@",bookedEntryHourStr]];
//                    }
//                }
                totalHeaderString = [NSString stringWithFormat:@"%@//%@",headerTitle,bookedEntryHourStr];
				
			}else {
				totalHeaderString = [NSString stringWithFormat:@"%@",headerTitle];
			}
		}else {
			NSString *bookedEntryHourStr   = [approvalsModel getTotalHoursforBookedEntryWithDate:[keyArray objectAtIndex:section] withformat:hourFormat withSheetIdentity:self.timeSheetObj.identity];
            
            
																					  
			if (bookedEntryHourStr != nil) 
            {
				
//                if (!appDelegate.isLockedTimeSheet) 
//                {
//                    NSString *totalhrs = [NSString stringWithFormat:@"%0.02f",[timeEntryHoursStr floatValue]+[bookedEntryHourStr floatValue]];
//                    totalHeaderString = [NSString stringWithFormat:@"%@//%@",headerTitle,totalhrs];
//                }
//                else
//                {
//                    if ([hourFormat isEqualToString:@"Decimal"]) {
//                        NSString *totalhrs = [NSString stringWithFormat:@"%0.02f",[timeEntryHoursStr floatValue]+[bookedEntryHourStr floatValue]];
//                        totalHeaderString = [NSString stringWithFormat:@"%@//%@",headerTitle,totalhrs];
//                    }
//                    else
//                    {
//                        totalHeaderString = [NSString stringWithFormat:@"%@//%@",headerTitle,[Util mergeTwoHourFormat:timeEntryHoursStr andHour2:bookedEntryHourStr]];
//                    }
//                }
                NSString *totalhrs = [NSString stringWithFormat:@"%0.02f",[timeEntryHoursStr floatValue]+[bookedEntryHourStr floatValue]];
                totalHeaderString = [NSString stringWithFormat:@"%@//%@",headerTitle,totalhrs];
				
			}
            
            else {
//                if (!appDelegate.isLockedTimeSheet) 
//                {
//                    totalHeaderString = [NSString stringWithFormat:@"%@//%@",headerTitle,timeEntryHoursStr];
//                }
//                else
//                {
//                    if ([hourFormat isEqualToString:@"Decimal"]) {
//                        totalHeaderString = [NSString stringWithFormat:@"%@//%@",headerTitle,timeEntryHoursStr];
//                    }
//                    else
//                    {
//                        totalHeaderString = [NSString stringWithFormat:@"%@//%@",headerTitle,[NSString stringWithFormat:@"%@",timeEntryHoursStr]];
//                    }
//                }
                totalHeaderString = [NSString stringWithFormat:@"%@//%@",headerTitle,timeEntryHoursStr];
				
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
                                                                             20.0)];
    self.sectionHeaderlabel=tempsectionHeaderlabel;
    
    
	sectionHeaderlabel.backgroundColor=[UIColor clearColor];
	sectionHeaderlabel.text=headerTitle;
	
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
	;
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
        self.mealHeaderLabel.numberOfLines=3.0;
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
    
    NSArray *mealViolationsArr=[approvalsModel getAllMealViolationsbyDate:[keyArray objectAtIndex:value] forISOName:approvals_DefaultISOStr forSheetidentity:[timeSheetObj identity]];
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
		
		
		UIImage *rowBackground       = [G2Util thumbnailImage:cellBackgroundImageView];
		
		((UIImageView *)cell.backgroundView).image = rowBackground;
    }
    
    [cell setCommonCellDelegate:self];
    
	NSInteger i=indexPath.row;
	
	NSString *clientProject=@"";
	NSString *client =@"";
	NSString *project= @"";
	NSString *noofhrs= @"";
   
	NSString *comments= @"";
	NSString *task=@"";
	NSString *type=@"";
	NSString *status =@"";
	NSString *sectionDate = [keyArray objectAtIndex:indexPath.section];
	NSMutableArray *entries = [timeEntryObjectsDictionary objectForKey:sectionDate];
	
	UIColor			*statusColor = nil;
	UIColor			*upperrighttextcolor = nil;
	BOOL			imgflag = NO;
	
	
	
	id timeEntryObject = [entries objectAtIndex:i];
	if ([timeEntryObject isKindOfClass:[G2TimeSheetEntryObject class]]) 
    {
		timeEntryObject = (G2TimeSheetEntryObject *)timeEntryObject;
		client   = [timeEntryObject clientName];
		project  = [timeEntryObject projectName];
		noofhrs  = [timeEntryObject numberOfHours];
        NSArray *compArr=[noofhrs componentsSeparatedByString:@":"];
        if ([compArr count] >1) 
        {
            NSString *totalMinsStr=[compArr objectAtIndex:1];
            if (![totalMinsStr isKindOfClass:[NSNull class]]) 
            {
                if ([totalMinsStr length]==1) 
                {
                    totalMinsStr=[@"0" stringByAppendingString:totalMinsStr];
                }
            }
            
            noofhrs=[[[compArr objectAtIndex:0] stringByAppendingString:@":"] stringByAppendingString:totalMinsStr];
        }
       
		task     = [[timeEntryObject taskObj] taskName];
        
		
		if (client == nil || [client isKindOfClass:[NSNull class]]) {
			
		}
		if (project == nil || [project isKindOfClass:[NSNull class]]) {
			project = @"None";
		}
		clientProject = [NSString stringWithFormat:@"%@",project];
        
		if ([clientProject isEqualToString:@"None"] && (Both || againstProjects)) {
			clientProject = @"No project";
		}
		else if([clientProject isEqualToString:@"None"]){
            G2ApprovalsModel *approvalModel = [[G2ApprovalsModel alloc] init];
            BOOL isTimesheetDisplayActivities = [approvalModel checkUserPermissionWithPermissionName:@"TimesheetDisplayActivities" andUserId:self.timeSheetObj.userID];
            BOOL isTimesheetActivityRequired = [approvalModel checkUserPermissionWithPermissionName:@"TimesheetActivityRequired" andUserId:self.timeSheetObj.userID];
            
            if (isTimesheetDisplayActivities || isTimesheetActivityRequired) 
            {
//                SupportDataModel *supportdtModel= [[SupportDataModel alloc] init];
//                NSMutableArray *activitiesArr=[supportdtModel getUserActivitiesFromDatabase];
//
//                if ([activitiesArr count]==1)
//                {
//                    if ( [[[activitiesArr objectAtIndex:0] objectForKey:@"name" ] isEqualToString:@"None" ])
//                    {
//                        clientProject = @"";
//                    }
//                }
                
               if ([timeEntryObject activityName] != nil && ![[timeEntryObject activityName] isKindOfClass:[NSNull class]]) {
                    clientProject = [timeEntryObject activityName];
                    if([clientProject isEqualToString:@"None"])
                    {
                        clientProject = @"No activity";
                    }
                }
                else
                {
                    clientProject = @"No activity";
                }
            }
            else
            {
                clientProject = @"";
            }
			
		}
        
		
        
        NSString *inoutTimeStr=nil;
        
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
                noofhrs=@"In progress";
                inoutTimeStr=[NSString stringWithFormat:@"%@ - ?",inTimeToBeUsed];
            }
            else if (!hasInTime && hasOutTime)
            {
                noofhrs=@"In progress";
                inoutTimeStr=[NSString stringWithFormat:@"? - %@",outTimeToBeUsed];
            }
            else
            {
                inoutTimeStr=@"";
            }            
        }
        else if(isLockedTimeSheet)
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
                    noofhrs=@"In progress";
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
            if (![totalMinsStr isKindOfClass:[NSNull class]]) 
            {
                if ([totalMinsStr length]==1) 
                {
                    totalMinsStr=[@"0" stringByAppendingString:totalMinsStr];
                }
            }
           
            noofhrs=[[[compArr objectAtIndex:0] stringByAppendingString:@":"] stringByAppendingString:totalMinsStr];
        }
        
		comments       = [timeEntryObject comments];
        
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

		
		upperrighttextcolor = RepliconStandardBlackColor;//US4468 Ullas M L
		[cell createCellLayoutWithParams:type upperlefttextcolor:upperrighttextcolor upperrightstr:noofhrs lowerleftstr:comments lowerlefttextcolor:RepliconStandardBlackColor lowerrightstr:lowerRightString statuscolor:statusColor 
						   imageViewflag:imgflag hairlinerequired:NO];//US4468 Ullas M L
		
		//[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];//US4468 Ullas M L
	}
    else {
		
		type	       = [timeEntryObject typeName];
		noofhrs        = [timeEntryObject numberOfHours];
        NSArray *compArr=[noofhrs componentsSeparatedByString:@":"];
        if ([compArr count] >1) 
        {
            NSString *totalMinsStr=[compArr objectAtIndex:1];
            if (![totalMinsStr isKindOfClass:[NSNull class]]) 
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
		
		
		NSString *bookedTimeOffApprovalStatus = @"";
		if (status != nil) {
			bookedTimeOffApprovalStatus = [NSString stringWithFormat:@"Booking-%@",status];
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
	tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
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
	
	
	if ([sheetApprovalStatus isEqualToString:APPROVED_STATUS]  
		|| [sheetApprovalStatus isEqualToString:G2WAITING_FOR_APRROVAL_STATUS]) {
		//TODO: Push the Controller to View the Entry:DONE
		
		timeEntryArr    = [timeEntryObjectsDictionary objectForKey:keyValue];
		timeEntryObj    = [timeEntryArr objectAtIndex:indexPath.row]; 
		
		if ([timeEntryObj isKindOfClass:[G2TimeSheetEntryObject class]]) {
			[self highlightTappedRowBackground:indexPath];
			self.rowTapped=indexPath;
            approvalTappedSectionIndex=-1;
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
			G2TimeEntryViewController *addNewTimeEntryViewController = [[G2TimeEntryViewController alloc] 
                                                                      initWithEntryDetails:timeEntryObj sheetId:nil screenMode:VIEW_TIME_ENTRY 
                                                                      permissionsObj:permissionsObj preferencesObj:preferencesObj:self.isInOutFlag:self.isLockedTimeSheet:self];
			
			[addNewTimeEntryViewController setSheetStatus:sheetApprovalStatus];
			self.timeEntryViewController=addNewTimeEntryViewController;
            [addNewTimeEntryViewController setHidesBottomBarWhenPushed:YES];//DE3486
            if ([delegate respondsToSelector:@selector(pushToTomeEntryViewController:)])
                [delegate pushToTomeEntryViewController:self.timeEntryViewController];
//			[self.navigationController pushViewController:self.timeEntryViewController animated:YES];
			
			
		}
        //US4468 Ullas M L
        else if ([timeEntryObj isKindOfClass:[G2TimeOffEntryObject class]])
        {
            
                [self highlightTappedRowBackground:indexPath];
                self.rowTapped=indexPath;
                approvalTappedSectionIndex=-1;
                selectedEntriesIdentity=(NSString *)[timeEntryObj identity];
                G2TimeEntryViewController *tmpTimeEntryViewController = [[G2TimeEntryViewController alloc] 
                                                                             initWithEntryDetails:timeEntryObj sheetId:nil screenMode:VIEW_ADHOC_TIMEOFF 
                                                                             permissionsObj:permissionsObj preferencesObj:preferencesObj:self.isInOutFlag:self.isLockedTimeSheet:self];
                
                [tmpTimeEntryViewController setSheetStatus:sheetApprovalStatus];
                self.timeEntryViewController=tmpTimeEntryViewController;
                [timeEntryViewController setHidesBottomBarWhenPushed:YES];//DE3486
                if ([delegate respondsToSelector:@selector(pushToTomeEntryViewController:)])
                    [delegate pushToTomeEntryViewController:self.timeEntryViewController];
            
            
            
            		
        }
        
        /*else if ([timeEntryObj isKindOfClass:[BookedTimeOffEntry class]]) {
		  //TODO: Handle the case when entry is other than TimeSheetEntryObject
		  }*/
	}
    else if ([sheetApprovalStatus isEqualToString:REJECTED_STATUS]
			  ||[sheetApprovalStatus isEqualToString:NOT_SUBMITTED_STATUS] ){
		//TODO:Push the Controller to Edit the entry:DONE
		//TODO: Pass the Date String as key for timeEntryObjectsDictionary
		
		timeEntryArr    = [timeEntryObjectsDictionary objectForKey:keyValue];
		timeEntryObj    = [timeEntryArr objectAtIndex:indexPath.row]; 
        
		if ([timeEntryObj isKindOfClass:[G2TimeSheetEntryObject class]]) {
			[self highlightTappedRowBackground:indexPath];
			self.rowTapped=indexPath;
            approvalTappedSectionIndex=-1;
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
			G2TimeEntryViewController *addNewTimeEntryController = [[G2TimeEntryViewController alloc] 
                                                                  initWithEntryDetails:timeEntryObj sheetId:nil screenMode:VIEW_TIME_ENTRY 
                                                                  permissionsObj:permissionsObj preferencesObj:preferencesObj:self.isInOutFlag:self.isLockedTimeSheet:self]; 
            
			[addNewTimeEntryController setSelectedSheetIdentity:[timeSheetObj identity]];
            self.timeEntryViewController=addNewTimeEntryController;
			[addNewTimeEntryController setHidesBottomBarWhenPushed:YES];
            if ([delegate respondsToSelector:@selector(pushToTomeEntryViewController:)])
                [delegate pushToTomeEntryViewController:self.timeEntryViewController];
//			[self.navigationController pushViewController:addNewTimeEntryController animated:YES];
			
			
		}/*else if ([timeEntryObj isKindOfClass:[BookedTimeOffEntry class]]) {
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
	sheetApprovalStatus					  = [timeSheetObj status];
	
	againstProjects						  = [permissionsObj projectTimesheet];
	notAgainstProjects					  = [permissionsObj nonProjectTimesheet];
	Both								  = [permissionsObj bothAgainstAndNotAgainstProject];
	allowBlankComments					  = [permissionsObj allowBlankResubmitComment];
	unsubmitAllowed						  = [permissionsObj unsubmitTimeSheet];
	
	NSString *hourFormat				  = [preferencesObj hourFormat];
	
	activitiesEnabled					  = [preferencesObj activitiesEnabled];
	
	NSMutableArray *entriesArray				 = [approvalsModel getTimeEntriesForSheetFromDB:sheetIdentity];
	NSMutableArray *timeoffentriesArray			 = [approvalsModel getTimeOffsForSheetFromDB:sheetIdentity];
	//NSMutableArray *bookedtimeOffentriesArray    = [timesheetModel getBookedTimeOffsForSheetId:sheetIdentity];
	NSMutableArray *distinctEntryDates			 = [approvalsModel getDistinctEntryDatesForSheet:sheetIdentity];
	NSString *totalHrsString					 = [approvalsModel getSheetTotalTimeHoursForSheetFromDB:sheetIdentity withFormat:hourFormat];
	NSString *bookedTimeOffHrs					 = @"0:00";
	NSDictionary *sheetDateRangeDict             = [approvalsModel getTimeSheetPeriodforSheetId:sheetIdentity];
	
	NSString *sheetstartDate = @"";
	NSString *sheetEndDate   = @"";
	
	if (sheetDateRangeDict != nil && [sheetDateRangeDict count] != 0) {
		sheetstartDate = [sheetDateRangeDict objectForKey:@"startDate"];
		sheetEndDate   = [sheetDateRangeDict objectForKey:@"endDate"];
        bookedTimeOffHrs=@"0:00";
	}
	NSMutableArray *distinctTimeOffEntryDates    = [approvalsModel getBookedTimeOffforTimeSheetPeriod:sheetstartDate _endDate:sheetEndDate andSheetIdentity:sheetIdentity];
	//NSMutableArray *distinctTimeOffEntryDates1	 = [timesheetModel getBookedTimeOffDistinctDatesForSheet:sheetIdentity];
    
//	RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    
	
	
    
    
//    if (!appDelegate.isLockedTimeSheet) 
//    {
//        NSString *totalhrs = [NSString stringWithFormat:@"%f",[totalHrsString floatValue]+[bookedTimeOffHrs floatValue]];
//        if (totalhrs != nil && ![totalhrs isKindOfClass:[NSNull class]]) 
//        {
//            self.totalHours = totalhrs;
//            self.totalHours = [NSString stringWithFormat:@"%0.2f",[totalhrs floatValue]];
//            [timeSheetObj setTotalHrs:totalhrs];
//        }
//        
//    }
//    else
//    {
//        if ([hourFormat isEqualToString:@"Decimal"]) {
//            NSString *totalhrs = [NSString stringWithFormat:@"%f",[totalHrsString floatValue]+[bookedTimeOffHrs floatValue]];
//            if (totalhrs != nil && ![totalhrs isKindOfClass:[NSNull class]]) 
//            {
//                self.totalHours = totalhrs;
//                self.totalHours = [NSString stringWithFormat:@"%0.2f",[totalhrs floatValue]];
//                [timeSheetObj setTotalHrs:totalhrs];
//            }
//        }
//        else
//        {
//            self.totalHours = [Util mergeTwoHourFormat:totalHrsString andHour2:bookedTimeOffHrs];
//            [timeSheetObj setTotalHrs:totalHours];
//        }
//    }
    NSString *totalhrs = [NSString stringWithFormat:@"%f",[totalHrsString floatValue]+[bookedTimeOffHrs floatValue]];
    if (totalhrs != nil && ![totalhrs isKindOfClass:[NSNull class]]) 
    {
        self.totalHours = totalhrs;
        self.totalHours = [NSString stringWithFormat:@"%0.2f",[totalhrs floatValue]];
        [timeSheetObj setTotalHrs:totalhrs];
    }

	
	if (timeEntryObjectsDictionary != nil && [timeEntryObjectsDictionary count]> 0) {
        
        //		timeEntryObjectsDictionary = nil;
        [timeEntryObjectsDictionary removeAllObjects];
        //		timeEntryObjectsDictionary = [[NSMutableDictionary dictionary] retain];
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
                if (([timeEntryDict objectForKey:@"time_in"]!=nil && ![[timeEntryDict objectForKey:@"time_in"] isKindOfClass:[NSNull class]]) || ([timeEntryDict objectForKey:@"time_out"]!=nil && ![[timeEntryDict objectForKey:@"time_out"] isKindOfClass:[NSNull class]]) || ([timeEntryDict objectForKey:@"durationHourFormat"] !=nil && ![[timeEntryDict objectForKey:@"durationHourFormat"] isKindOfClass:[NSNull class]] && ![[timeEntryDict objectForKey:@"durationHourFormat"] isEqualToString:@"0:0"] )  || ([timeEntryDict objectForKey:@"comments"]!=nil && ![[timeEntryDict objectForKey:@"comments"] isKindOfClass:[NSNull class]] && ![[timeEntryDict objectForKey:@"comments"] isEqualToString:@""] ) ) 
                {

                
                    //TODO: Create TimeEntry Object:DONE
                    G2TimeSheetEntryObject *timeSheetEntryObject=[[G2TimeSheetEntryObject alloc]init];
                    NSString *identity   = [timeEntryDict objectForKey:@"identity"];
                    NSString *stringDate = [timeEntryDict objectForKey:@"entryDate"];
                    NSString *sheetId    = [timeEntryDict objectForKey:@"sheetIdentity"];
                    NSString *entrytype  = [timeEntryDict objectForKey:@"entryType"];
                    NSString *uid  = [timeSheetObj userID];
                    NSDate   *entrydate  = [G2Util convertStringToDate:stringDate];
                    
                    [timeSheetEntryObject			setIdentity:identity];
                    [timeSheetEntryObject			setEntryDate:entrydate];
                    [timeSheetEntryObject			setSheetId:sheetId];
                    [timeSheetEntryObject			setEntryType:entrytype];
                    [timeSheetEntryObject.taskObj	setEntryId:identity];
                    [timeSheetEntryObject setUserID:uid];
                    NSString *taskname		  =nil;
                    NSString *taskidentity   =nil;
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
                        
                        taskname		  = [timeEntryDict objectForKey:@"taskName"];
                        taskidentity	  = [timeEntryDict objectForKey:@"taskIdentity"];
                        
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
                    //                RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
                    //                if (!appDelegate.isLockedTimeSheet) 
                    //                {
                    //                    NSString *noOfHours = [NSString stringWithFormat:@"%0.02f",[[timeEntryDict objectForKey:@"durationDecimalFormat"]floatValue]];
                    //					[timeSheetEntryObject setNumberOfHours:noOfHours];
                    //                }
                    //                else
                    //                {
                    //                    if([hourFormat isEqualToString:@"Decimal"])
                    //                    {
                    //                        NSString *noOfHours = [NSString stringWithFormat:@"%0.02f",[[timeEntryDict objectForKey:@"durationDecimalFormat"]floatValue]];
                    //                        [timeSheetEntryObject setNumberOfHours:noOfHours];
                    //                    }
                    //                    else
                    //                    {
                    //                        
                    //                        [timeSheetEntryObject setNumberOfHours:[timeEntryDict objectForKey:@"durationHourFormat"]];
                    //                    }
                    //                }
                    
                    NSString *noOfHours = [NSString stringWithFormat:@"%0.02f",[[timeEntryDict objectForKey:@"durationDecimalFormat"]floatValue]];
                    [timeSheetEntryObject setNumberOfHours:noOfHours];
                    
                    
                    [timeSheetEntryObject setInTime:[timeEntryDict objectForKey:@"time_in"]];
                    [timeSheetEntryObject setOutTime:[timeEntryDict objectForKey:@"time_out"]];
                    
                    NSMutableArray *totalTimeEntries = [timeEntryObjectsDictionary objectForKey:stringDate];
                    
                    [timeSheetEntryObject setActivityName:[timeEntryDict objectForKey:@"activityName"]];
                    [timeSheetEntryObject setActivityIdentity:[timeEntryDict objectForKey:@"activityIdentity"]];
                    
                    [totalTimeEntries addObject:timeSheetEntryObject];
                    
                }	
            }
        }
                

		
		//DLog(@"Total Time Entries %@",timeEntryObjectsDictionary);
		if (timeoffentriesArray != nil && [timeoffentriesArray count]>0) {
			for ( NSDictionary *timeOffDict in timeoffentriesArray ) {
				
                if ( ([timeOffDict objectForKey:@"durationHourFormat"] !=nil && ![[timeOffDict objectForKey:@"durationHourFormat"] isKindOfClass:[NSNull class]] && ![[timeOffDict objectForKey:@"durationHourFormat"] isEqualToString:@"0:0"] )  || ([timeOffDict objectForKey:@"comments"]!=nil && ![[timeOffDict objectForKey:@"comments"] isKindOfClass:[NSNull class]] && ![[timeOffDict objectForKey:@"comments"] isEqualToString:@""] ) ) 
                {
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
                    NSString *uid  = [timeSheetObj userID];
                    
                    [timeOffEntryObject setIdentity:identity];
                    [timeOffEntryObject setTimeOffDate:entrydate];
                    [timeOffEntryObject setSheetId:sheetId];
                    [timeOffEntryObject setEntryType:entrytype];
                    [timeOffEntryObject setComments:comments];
                    [timeOffEntryObject setTimeOffCodeType:timeOffCodeType];
                    [timeOffEntryObject setTypeIdentity:timeOffCodeIdentity];
                    [timeOffEntryObject setUserID:uid];
                    
                    //				RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
                    //                if (!appDelegate.isLockedTimeSheet) 
                    //                {
                    //                    NSString *noOfHours = [NSString stringWithFormat:@"%0.02f",[[timeOffDict objectForKey:@"durationDecimalFormat"]floatValue]];
                    //					[timeOffEntryObject setNumberOfHours:noOfHours];
                    //                }
                    //                else
                    //                {
                    //                    if([hourFormat isEqualToString:@"Decimal"])
                    //                    {
                    //                        NSString *noOfHours = [NSString stringWithFormat:@"%0.02f",[[timeOffDict objectForKey:@"durationDecimalFormat"]floatValue]];
                    //                        [timeOffEntryObject setNumberOfHours:noOfHours];
                    //                    }
                    //                    else
                    //                    {
                    //                        
                    //                        [timeOffEntryObject setNumberOfHours:[timeOffDict objectForKey:@"durationHourFormat"]];
                    //                    }
                    //                }
                    NSString *noOfHours = [NSString stringWithFormat:@"%0.02f",[[timeOffDict objectForKey:@"durationDecimalFormat"]floatValue]];
                    [timeOffEntryObject setNumberOfHours:noOfHours];
                    
                    
                    NSMutableArray *totalTimeOffEntries = [timeEntryObjectsDictionary objectForKey:stringDate];
                    [totalTimeOffEntries addObject:timeOffEntryObject];
                    

                }
                
                
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
				
//                RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
//                if (!appDelegate.isLockedTimeSheet) 
//                {
//                    NSString *noOfHours = [NSString stringWithFormat:@"%0.02f",[[bookedTimeOffDict objectForKey:@"decimalDuration"]floatValue]];
//                    [bookedTimeOffEntryObject setNumberOfHours:noOfHours];
//                }
//                else
//                {
//                    if([hourFormat isEqualToString:@"Decimal"])
//                    {
//                        NSString *noOfHours = [NSString stringWithFormat:@"%0.02f",[[bookedTimeOffDict objectForKey:@"decimalDuration"]floatValue]];
//                        [bookedTimeOffEntryObject setNumberOfHours:noOfHours];
//                    }
//                    else
//                    {
//                        
//                        [bookedTimeOffEntryObject setNumberOfHours:[bookedTimeOffDict objectForKey:@"hourDuration"]];
//                    }
//                }
                NSString *noOfHours = [NSString stringWithFormat:@"%0.02f",[[bookedTimeOffDict objectForKey:@"decimalDuration"]floatValue]];
                [bookedTimeOffEntryObject setNumberOfHours:noOfHours];
				
				
				NSMutableArray *totalBookedTimeOffEntries = [timeEntryObjectsDictionary objectForKey:entryDateString];
				[totalBookedTimeOffEntries addObject:bookedTimeOffEntryObject];
				
			}
		}
	}
	//DLog(@"Total Time Entries %@",timeEntryObjectsDictionary);
	[keysArray sortUsingSelector:@selector(compare:)];
	
    //NSArray *reversekeyarray = [[keysArray reverseObjectEnumerator] allObjects];
    NSArray *reversekeyarray = [[keysArray objectEnumerator] allObjects];
    
	//DLog(@"Key Array %@",reversekeyarray);
	self.keyArray =[NSMutableArray arrayWithArray:reversekeyarray];
}

-(NSString *)getFormattedEntryDateString:(NSString *)_stringdate{
	NSDate *date = nil;
	if (_stringdate != nil) {
		date				= [G2Util convertStringToDate:_stringdate];
		NSString *formattedDateStr = @"";
		formattedDateStr = [G2Util getFormattedRegionalDateString:date];
		
		return formattedDateStr;
	}
	return nil;
}



#pragma mark footerView
#pragma mark footerButtonsView

-(void)createTimeEntryFooterView:(NSString *)sheetStatus {
	
	
		G2EntriesTableFooterView *entriesTableFooterView = [[G2EntriesTableFooterView alloc]initWithFrame:
                                                        CGRectMake(0.0, 0.0, self.timeEntriesTableView.frame.size.width, 100)];
        [entriesTableFooterView setEventHandler:self];
		if (unsubmitAllowed && ![timeSheetObj approversRemaining]) {
			[entriesTableFooterView setUnsubmitAllowed:unsubmitAllowed];
		}
	
   
    
//    if (isLockedTimeSheet) 
//    {
//        if ([[preferencesObj hourFormat] isEqualToString:@"Decimal"]) {
//            [entriesTableFooterView addTotalLabelView:totalHours];
//        }
//        else
//        {
//            [entriesTableFooterView addTotalLabelView:[NSString stringWithFormat:@"%@",totalHours]];
//        }
//    }
//    else
//    {
//        [entriesTableFooterView addTotalLabelView:totalHours];
//    }
    
            
	
    G2ApprovalTablesFooterView *approvalTablesfooterView=[[G2ApprovalTablesFooterView alloc]initWithFrame:CGRectMake(0, 0, 360.0, 205.0 ) andStatus:sheetStatus];
   
    approvalTablesfooterView.delegate=self;
    [approvalTablesfooterView hideMoreButton];
	
    
    UIView *finalFooterView=[[UIView alloc]initWithFrame:CGRectMake(0, 0.0, 320.0, 245.0)];
    self.customFooterView=finalFooterView;
    
    //DE5784    
   
    NSArray *timeEntryArray=[approvalsModel getTimeSheetInfoForSheetIdentity:timeSheetObj.identity];
    if ((timeEntryArray!=nil && (![[[timeEntryArray objectAtIndex:0] objectForKey:@"approvalStatus"] isEqualToString:G2WAITING_FOR_APRROVAL_STATUS] && ![[[timeEntryArray objectAtIndex:0] objectForKey:@"approvalStatus"] isEqualToString:APPROVED_STATUS]))|| timeEntryArray == NULL)
    {
        float total=[timeSheetObj.totalHrs floatValue];
        
        if (total>0)
        {
            total=0;
            self.totalHours=[NSString stringWithFormat:@"%0.2f",total];
            [timeSheetObj setTotalHrs:[NSString stringWithFormat:@"%0.2f",total]];
        }
    }
    
    [entriesTableFooterView addTotalLabelView:totalHours];

    
   
    [finalFooterView addSubview:entriesTableFooterView];
     //US4637//Juhi
    UIView *submittedView=[[UIView alloc] initWithFrame:CGRectMake(10, 45, 300, 40)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    UILabel *submittedLbl=[[UILabel alloc] init];
    [submittedLbl setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];
    [submittedLbl setBackgroundColor:[UIColor clearColor]];
    [submittedLbl setTextAlignment:NSTextAlignmentLeft];
    submittedLbl.frame=CGRectMake(0.0,
                                  0.0,
                                  250.0,
                                  16.0);
    
    if ([sheetStatus isEqualToString:APPROVED_STATUS]) {
        submittedLbl.text=[NSString stringWithFormat:@"Approved: %@",[dateFormatter stringFromDate:self.timeSheetObj.effectiveDate]];
        [submittedLbl setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_13]];
        submittedLbl.textColor=[UIColor colorWithRed:0/255.0 green:100/255.0 blue:0/255.0 alpha:1.0];
    }
    else if ([sheetStatus isEqualToString:REJECTED_STATUS]) {
        submittedLbl.text=[NSString stringWithFormat:@"Rejected: %@",[dateFormatter stringFromDate:self.timeSheetObj.effectiveDate]];
        [submittedLbl setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_13]];
        submittedLbl.textColor=[UIColor redColor];
    }
    else {
        submittedLbl.text=[NSString stringWithFormat:@"Submitted: %@",[dateFormatter stringFromDate:self.timeSheetObj.effectiveDate]];
        [submittedLbl setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
        submittedLbl.textColor=RepliconStandardBlackColor;
    }
    
    [submittedView addSubview:submittedLbl];
    [customFooterView addSubview:submittedView];
    
    CGRect frame=approvalTablesfooterView.frame;
     frame.origin.y=50.0;//US4637//Juhi
    approvalTablesfooterView.frame=frame;
    [finalFooterView addSubview:approvalTablesfooterView];
    
 	finalFooterView.frame=CGRectMake(0.0, 0.0, 320.0,approvalTablesfooterView.frame.origin.y+approvalTablesfooterView.frame.size.height);
    //DE5784 
     if ((timeEntryArray!=nil && (![[[timeEntryArray objectAtIndex:0] objectForKey:@"approvalStatus"] isEqualToString:G2WAITING_FOR_APRROVAL_STATUS] && ![[[timeEntryArray objectAtIndex:0] objectForKey:@"approvalStatus"] isEqualToString:APPROVED_STATUS]))|| timeEntryArray == NULL)
    {   
        UIView *tempView=[[UIView alloc]init];
        tempView.backgroundColor=G2RepliconStandardBackgroundColor;
        tempView.alpha=1;

        
        frame=finalFooterView.frame;
        frame.size.height=frame.size.height+100;
        tempView.frame=frame;
        [tempView setUserInteractionEnabled:NO];
        [finalFooterView addSubview:tempView];
        [finalFooterView bringSubviewToFront:tempView];
        [finalFooterView setUserInteractionEnabled:NO];
        
        UILabel *errorMessageLabel=[[UILabel alloc]initWithFrame:CGRectMake(50, 100, 220, 80)];
        errorMessageLabel.text=RPLocalizedString(G2APPROVAL_TIMESHEET_NOT_WAITINGFORAPPROVAL, G2APPROVAL_TIMESHEET_NOT_WAITINGFORAPPROVAL);
       
        errorMessageLabel.backgroundColor=[UIColor clearColor];
        errorMessageLabel.numberOfLines=2;
        errorMessageLabel.textAlignment=NSTextAlignmentCenter;
        errorMessageLabel.font=[UIFont fontWithName:RepliconFontFamily size:16];
        
        [tempView addSubview:errorMessageLabel];        
        
        
    }
	[self.timeEntriesTableView setTableFooterView:finalFooterView];
    
}

#pragma mark Button 
#pragma mark ButtonActions




#pragma mark -
#pragma mark AlertView Methods





#pragma mark -
#pragma mark EntriesFooterButtonsProtocol


-(void)highlightTappedRowBackground:(NSIndexPath*)indexPath{
	
	G2CustomTableViewCell *cellObj = [self getTappedRowAtIndexPath:indexPath];
	if (cellObj == nil) {
		return;
	}
	//DLog(@"%i %i",indexPath.row,indexPath.section);
	//UIImage *selectionBackground = [Util thumbnailImage:cellBackgroundImageView_select];
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
	
	[[cellObj upperLeft] setTextColor:RepliconStandardBlackColor];
	[[cellObj upperRight] setTextColor:RepliconStandardBlackColor];
	[[cellObj lowerLeft] setTextColor:RepliconStandardBlackColor];
	[[cellObj lowerRight] setTextColor:RepliconStandardBlackColor];
	
	//[cellObj setSelected:NO];
}
-(void)highlightTheCellWhichWasSelected{
	[self highlightTappedRowBackground:self.rowTapped];
    
    
}
-(G2CustomTableViewCell*)getTappedRowAtIndexPath:(NSIndexPath*)indexPath{
	G2CustomTableViewCell *rowCell = (G2CustomTableViewCell *)[self.timeEntriesTableView cellForRowAtIndexPath: indexPath]; 
	return rowCell;
}



- (void)handleButtonClickForFooterView:(NSInteger)senderTag
{
    
    if (senderTag==APPROVE_BUTTON_TAG_G2)
    {
        DLog(@"APPROVE BUTTON CLICKED");
        UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ %@ %@'s %@" ,RPLocalizedString(APPROVAL_TIMESHEET_APPROVE_CONFIRM_MSG1,@""),self.timeSheetObj.userFirstName,self.timeSheetObj.userLasttName,RPLocalizedString(APPROVAL_TIMESHEET_APPROVE_CONFIRM_MSG2,@"") ]
                                                                  delegate:self cancelButtonTitle:RPLocalizedString(NO_BTN_TITLE, @"NO") otherButtonTitles:RPLocalizedString(YES_BTN_TITLE,@""),nil];
        [confirmAlertView setDelegate:self];
        [confirmAlertView setTag:1];
        
        [confirmAlertView show];
       
    }
    else if (senderTag==REJECT_BUTTON_TAG_G2)
    {
        DLog(@"REJECT BUTTON CLICKED");
        DLog(@"APPROVE BUTTON CLICKED");
        UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@ %@ %@'s %@" ,RPLocalizedString(APPROVAL_TIMESHEET_REJECT_CONFIRM_MSG1,@""),self.timeSheetObj.userFirstName,self.timeSheetObj.userLasttName,RPLocalizedString(APPROVAL_TIMESHEET_REJECT_CONFIRM_MSG2,@"") ]
                                                                  delegate:self cancelButtonTitle:RPLocalizedString(NO_BTN_TITLE, @"NO") otherButtonTitles:RPLocalizedString(YES_BTN_TITLE,@""),nil];
        [confirmAlertView setDelegate:self];
        [confirmAlertView setTag:2];
        
        [confirmAlertView show];
        
    }
    else if (senderTag==COMMENTS_TEXTVIEW_TAG_G2) 
    {
        DLog(@"COMMENTS CLICKED");
        
        if ([delegate respondsToSelector:@selector(handleApproverCommentsForSelectedUser:)])
            [delegate handleApproverCommentsForSelectedUser:self];
    }
    else
    {
        DLog(@"REOPEN CLICKED");
    }

}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag==1) {
        if (buttonIndex==1) {
            
           
            [[NSNotificationCenter defaultCenter]
             removeObserver:self name:APPROVAL_TIMESHEETS_APPROVAL_REJECT_DONE_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] addObserver: self 
                                                     selector: @selector(readjustScrollView) 
                                                         name: APPROVAL_TIMESHEETS_APPROVAL_REJECT_DONE_NOTIFICATION
                                                       object: nil]; 
            
            
            UIView *finalFooterview=(UIView *)self.timeEntriesTableView.tableFooterView;
            NSString *comments=nil;
            for (int i = 0; i < [[finalFooterview subviews] count]; i++ ) {
                
                if ([ [[finalFooterview subviews]objectAtIndex:i] isKindOfClass:[G2ApprovalTablesFooterView class]]) {
                    G2ApprovalTablesFooterView *appFooterView=(G2ApprovalTablesFooterView *)[[finalFooterview subviews]objectAtIndex:i];
                    comments=appFooterView.commentsTextView.text;
                    break;
                }
                

            }

            
    
            if (comments==nil) {
                comments=@"";
            }
            
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:ApprovingMessage];
            NSString *sheetId=self.timeSheetObj.identity;
            [[G2RepliconServiceManager approvalsService] approveTimesheetWithComments:[NSArray arrayWithObject:sheetId] comments:comments];
        }
    }
    
    else if (alertView.tag==2) {
        if (buttonIndex==1) {
            
            G2PermissionsModel *permissionModel=[[G2PermissionsModel alloc]init];
            BOOL isApproverAllowBlankRejectComment= [permissionModel getStatusForGivenPermissions:@"ApproverAllowBlankRejectComment"];
            
            
            
            UIView *finalFooterview=(UIView *)self.timeEntriesTableView.tableFooterView;
            NSString *comments=nil;
            for (int i = 0; i < [[finalFooterview subviews] count]; i++ ) {
                
                if ([ [[finalFooterview subviews]objectAtIndex:i] isKindOfClass:[G2ApprovalTablesFooterView class]]) {
                    G2ApprovalTablesFooterView *appFooterView=(G2ApprovalTablesFooterView *)[[finalFooterview subviews]objectAtIndex:i];
                    comments=appFooterView.commentsTextView.text;
                    break;
                }
                
                
            }
            
            
            
            if (comments==nil) {
                comments=@"";
            }
            
            if (!isApproverAllowBlankRejectComment) {
                if (comments==nil || [[comments stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@"" ]) {
                    UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:nil message: RPLocalizedString(APPROVAL_TIMESHEET_REJECTION_VALIDATION,@"")
                                                                              delegate:self cancelButtonTitle:RPLocalizedString(OK_BTN_TITLE, @"OK") otherButtonTitles:nil];
                    [confirmAlertView setDelegate:self];
                    [confirmAlertView setTag:9999];
                    
                    [confirmAlertView show];
                    
                    
                    return;
                }
                
            }


            
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RejectingMessage];
            [[NSNotificationCenter defaultCenter]
             removeObserver:self name:APPROVAL_TIMESHEETS_APPROVAL_REJECT_DONE_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] addObserver: self 
                                                     selector: @selector(readjustScrollView) 
                                                         name: APPROVAL_TIMESHEETS_APPROVAL_REJECT_DONE_NOTIFICATION
                                                       object: nil]; 
            
            
                      
            
            NSString *sheetId=self.timeSheetObj.identity;
            [[G2RepliconServiceManager approvalsService] rejectTimesheetWithComments:[NSArray arrayWithObject:sheetId] comments:comments];
        }
    }
    
}


-(void)readjustScrollView
{
    
    [[NSNotificationCenter defaultCenter]
	 removeObserver:self name:APPROVAL_TIMESHEETS_APPROVAL_REJECT_DONE_NOTIFICATION object:nil];
    
    if ([delegate respondsToSelector:@selector(readjustScrollViewWithIndex:)])
        [delegate readjustScrollViewWithIndex:self.currentViewTag];
    
 
   
}

- (void)handleButtonClickForHeaderView:(NSInteger)senderTag
{

    if ([delegate respondsToSelector:@selector(handlePreviousNextButtonFromApprovalsListforViewTag:forbuttonTag:)])
        [delegate handlePreviousNextButtonFromApprovalsListforViewTag:currentViewTag forbuttonTag:senderTag];
   
}


-(void)animateCellWhichIsSelected
{
    
}

- (void)setDescription:(NSString *)description
{
    
    G2ApprovalTablesFooterView *approvalTablesfooterView=nil;
  
    
    for (int i = 0; i < [[self.timeEntriesTableView.tableFooterView subviews] count]; i++ ) 
    {
        if( [[[self.timeEntriesTableView.tableFooterView subviews] objectAtIndex:i] isKindOfClass:[G2ApprovalTablesFooterView class] ] )
        {
            approvalTablesfooterView = (G2ApprovalTablesFooterView *)[[self.timeEntriesTableView.tableFooterView subviews] objectAtIndex:i];
        }

    }
    if (approvalTablesfooterView) {
        
        
               
        
        if ([timeSheetObj.status isEqualToString:APPROVED_STATUS] || [timeSheetObj.status isEqualToString:REJECTED_STATUS])
        {
            
            
            approvalTablesfooterView.commentsTextLbl.text=description;
            
            // Let's make an NSAttributedString first
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:description];
            //Add LineBreakMode
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:RepliconFontSize_14]} range:NSMakeRange(0, attributedString.length)];
            
            //Now let's make the Bounding Rect
            CGSize size = [attributedString boundingRectWithSize:CGSizeMake(290.0, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            
            if (size.width==0 && size.height ==0) 
            {
                size=CGSizeMake(11.0, 18.0);
            }
            CGRect frame=approvalTablesfooterView.commentsTextLbl.frame;
            frame.size.height=size.height +15;
            
            [approvalTablesfooterView.commentsTextLbl setFrame:frame];
            frame=approvalTablesfooterView.reopenButton.frame;
            
            frame.origin.y=size.height +95.0;
            
            [approvalTablesfooterView.reopenButton setFrame:frame];
            
            frame=approvalTablesfooterView.frame;
            frame.size.height=60.0+size.height +15+110.0+20.0;
            approvalTablesfooterView.frame=frame;
            
            for (int i = 0; i < [[ self.customFooterView subviews] count]; i++ ) 
            {
                if( [[[self.customFooterView subviews] objectAtIndex:i] isKindOfClass:[G2ApprovalTablesFooterView class] ] )
                {
                    float height=approvalTablesfooterView.frame.size.height-205.0;
                    [[[self.customFooterView subviews] objectAtIndex:i] removeFromSuperview];
                    [ self.customFooterView addSubview:approvalTablesfooterView];
                    self.customFooterView.frame= CGRectMake(0, 0.0, 320.0, 215.0+height);
                    [self.timeEntriesTableView setTableFooterView:self.customFooterView];
                    break;
                }
                
            }
            

        }
        else
        {
            
            approvalTablesfooterView.commentsTextView.text=description;
           
            
            // Let's make an NSAttributedString first
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:description];
            //Add LineBreakMode
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            // Add Font
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:RepliconFontSize_14]} range:NSMakeRange(0, attributedString.length)];
            
            //Now let's make the Bounding Rect
            CGSize size = [attributedString boundingRectWithSize:CGSizeMake(290.0, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            
            if (size.width==0 && size.height ==0) 
            {
                size=CGSizeMake(11.0, 18.0);
            }
            CGRect frame=approvalTablesfooterView.commentsTextView.frame;
            frame.size.height=size.height +15;
            if (frame.size.height<44.0) {
                frame.size.height=44.0;
            }

            [approvalTablesfooterView.commentsTextView setFrame:frame];
            
            float yOrigin=frame.origin.y+frame.size.height+30.0;
            
            frame=approvalTablesfooterView.approveButton.frame;
            
            frame.origin.y=yOrigin;
            
            [approvalTablesfooterView.approveButton setFrame:frame];
            frame=approvalTablesfooterView.rejectButton.frame;
            
            frame.origin.y=yOrigin;
            [approvalTablesfooterView.rejectButton setFrame:frame];
            
            float finalHeight=frame.origin.y+frame.size.height+30.0;
            
            frame=approvalTablesfooterView.frame;
            frame.size.height=finalHeight;

//            float orgY=33.0;
//            frame.origin.y=orgY;

            approvalTablesfooterView.frame=frame;
            
            for (int i = 0; i < [[ self.customFooterView subviews] count]; i++ ) 
            {
                if( [[[self.customFooterView subviews] objectAtIndex:i] isKindOfClass:[G2ApprovalTablesFooterView class] ] )
                {
                   
                    [[[self.customFooterView subviews] objectAtIndex:i] removeFromSuperview];
                    [ self.customFooterView addSubview:approvalTablesfooterView];
                    self.customFooterView.frame= CGRectMake(0, 0.0, 320.0, approvalTablesfooterView.frame.origin.y+approvalTablesfooterView.frame.size.height);
                    [self.timeEntriesTableView setTableFooterView:self.customFooterView];
                    break;
                }
                
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
