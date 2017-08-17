//
//  TimeEntryViewController.m
//  Replicon
//
//  Created by vijaysai on 8/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2TimeEntryViewController.h"
#import "RepliconAppDelegate.h"
#import "G2LockedTimeSheetCellView.h"
#import "G2ApprovalsUsersListOfTimeEntriesViewController.h"

@implementation G2TimeEntryViewController

@synthesize tnewTimeEntryTableView;
@synthesize tableHeader;
@synthesize firstSectionfieldsArr;
@synthesize secondSectionfieldsArray;
@synthesize activitiesArray;
@synthesize billingArray;
@synthesize clientsArray;
@synthesize sheetStatus;
@synthesize  rowDtls;
@synthesize screenMode;
@synthesize timeSheetEntryObject;
@synthesize timeOffEntryObject;
@synthesize permissionsObj;
@synthesize preferencesObj;
@synthesize submissionErrorDelegate;
@synthesize isEntriesAvailable;
@synthesize selectedIndexPath;
@synthesize lastUsedTextField;
@synthesize selectedSheetIdentity;
@synthesize  progressIndicator;
@synthesize addDescriptionViewController;
@synthesize  taskViewController;
@synthesize  customPickerView;
@synthesize supportDataModel,timesheetModel;
@synthesize footerView;
@synthesize  disabledActivityName;
@synthesize isFromSave;
@synthesize disabledBillingOptionsName;
@synthesize mainScrollView;
@synthesize disabledDropDownOptionsName;
@synthesize hasClient;
@synthesize isInOutFlag;
@synthesize  hackIndexPathForInOut;
@synthesize isNotMatching;
@synthesize isFromDoneClicked;
@synthesize isMovingToNextScreen; 
@synthesize isLockedTimeSheet;
@synthesize customParentDelegate;
@synthesize isComment;
//US4275//Juhi
@synthesize commentsTextView;
@synthesize deletButton;
@synthesize mutilpleJsonRequestArrayForNewInOut;
@synthesize isTimeOffEntry;
@synthesize timeTypesArray;
@synthesize disabledTimeOffTypeName;
@synthesize selectedSheet;
@synthesize isTimeOffEnabledForTimeEntry;
@synthesize isTimeFieldValueBreak,isFromCancel;
@synthesize isCommentsTextFieldClicked;
@synthesize dataListViewCtrl;

#define DATE_TAG 2000
#define MOVE_NEXT_TAG 3000
#define BILLING_TAG 4000
#define ACTIVITY_TAG 5000
#define TIME_TAG 9999
#define HOUR_TAG 8888
#define DELETE_TAG 11111
#define REOPEN_TAG 22222//US4660//Juhi
#define UNSUBMIT_TAG 33333
#define EXTRA_SPACING_LOCKED_IN_OUT 90.0
#define ROW_HEIGHT 44.0

//Overridden Initializer to make settings.

- (id)initWithEntryDetails :(id )entryObj sheetId:(NSString *)_sheetIdentity 
				screenMode :(NSInteger)_screenMode permissionsObj:(id)_permissionObj preferencesObj:(id)_preferencesObj :(BOOL) InOutFlag :(BOOL) LockedTimeSheet :(id)delegate
{
    self = [super init];
	if (self != nil) {
		
		if (entryObj != nil) {
            if ([entryObj isKindOfClass:[G2TimeSheetEntryObject class]])
            {
                [self setTimeSheetEntryObject:entryObj];
            }
			else if ([entryObj isKindOfClass:[G2TimeOffEntryObject class]])
            {
                [self setTimeOffEntryObject:entryObj];
            }
		}
		else {
            
            if (LockedTimeSheet)
            {
                if (_screenMode==ADD_TIME_ENTRY) 
                {
                    [self setTimeSheetEntryObject:[G2TimeSheetEntryObject createObjectWithDefaultValues]];
                }
                else if (_screenMode==ADD_ADHOC_TIMEOFF) 
                {
                    [self setTimeOffEntryObject:[G2TimeOffEntryObject createObjectWithDefaultValues]];
                }
                else
                {
                    [self setTimeSheetEntryObject:[G2TimeSheetEntryObject createObjectWithDefaultValues]];
                    [self setTimeOffEntryObject:[G2TimeOffEntryObject createObjectWithDefaultValues]];
                }
            }
            else
            {
                [self setTimeSheetEntryObject:[G2TimeSheetEntryObject createObjectWithDefaultValues]];
                [self setTimeOffEntryObject:[G2TimeOffEntryObject createObjectWithDefaultValues]];
            }
            
		}
		
		if (_sheetIdentity != nil) {
            if (entryObj != nil) 
            {
                if ([entryObj isKindOfClass:[G2TimeSheetEntryObject class]])
                {
                    [timeSheetEntryObject setSheetId:_sheetIdentity];
                }
                else if ([entryObj isKindOfClass:[G2TimeOffEntryObject class]])
                {
                    [timeOffEntryObject setSheetId:_sheetIdentity];
                }
            }
            
		}
		
		if (_permissionObj != nil) {
			[self setPermissionsObj:_permissionObj];
		}
		if (_preferencesObj != nil) {
			[self setPreferencesObj:_preferencesObj];
		}
		
		[self setScreenMode:_screenMode];
		
		
		if (supportDataModel == nil) {
			G2SupportDataModel *tempsupportDataModel = [[G2SupportDataModel alloc] init];
            self.supportDataModel=tempsupportDataModel;
            
		}
		if (timesheetModel == nil) {
			G2TimesheetModel *temptimesheetModel = [[G2TimesheetModel alloc] init];
            self.timesheetModel=temptimesheetModel;
            
		}
        appDelegate= (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
        self.isLockedTimeSheet=LockedTimeSheet;
        self.isInOutFlag=InOutFlag;
        self.customParentDelegate=delegate;
	}
	
	return self;
}



// Implement loadView to create a view hierarchy programmatically, without using a nib.

- (void)loadView {
	
	[super loadView];
        
}

-(void)viewWillDisappear:(BOOL)animated
{
    if ([customParentDelegate respondsToSelector:@selector(viewWillAppearFromApprovalsTimeEntry)])
        [(G2ApprovalsUsersListOfTimeEntriesViewController *)customParentDelegate viewWillAppearFromApprovalsTimeEntry];
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    //DE5011 Ullas M L
    
    if (isMovingToNextScreen) {
        isMovingToNextScreen=NO;
        CGSize size=self.mainScrollView.contentSize;
        int buttonSpaceHeight=30.0;
        int spaceForHeader=0.0;
        if(isLockedTimeSheet)
        {
            if ([self screenMode]==ADD_ADHOC_TIMEOFF || [self screenMode]==EDIT_ADHOC_TIMEOFF || [self screenMode]==VIEW_ADHOC_TIMEOFF)
            {
                if( [self screenMode] == EDIT_ADHOC_TIMEOFF )
                {
                    buttonSpaceHeight=90.0;
                }
                int spaceHeader=0.0;
                
                if([secondSectionfieldsArray count]==0)
                {
                    spaceHeader=48.0+48.0+48.0;
                }
                else 
                {
                    spaceHeader=48.0+48.0+48.0;
                }
                
                
                size.height=([secondSectionfieldsArray  count]*44)+([firstSectionfieldsArr  count]*44)+35.0+spaceHeader+buttonSpaceHeight  ;
                
                [self.mainScrollView setContentSize:size];
            }

            else
            {
                if ([secondSectionfieldsArray  count]==0) 
                {
                    spaceForHeader=53.0;
                }
                else
                {
                    spaceForHeader=48.0+48.0;
                }     
                size.height= ([secondSectionfieldsArray  count]*44)+90.0+35.0+spaceForHeader+44.0+buttonSpaceHeight   ;
                [self.mainScrollView setContentSize:size];
            }
            
            
        }
        else 
        {
            
            if( [self screenMode] == EDIT_TIME_ENTRY || [self screenMode] == EDIT_ADHOC_TIMEOFF)
            {
                buttonSpaceHeight=90.0;
            }
            if ([secondSectionfieldsArray  count]==0) 
            {
                spaceForHeader=48.0+48.0;
            }
            else
            {
                spaceForHeader=48.0+48.0+48.0;
            }    
            
            if( [self screenMode] == EDIT_TIME_ENTRY)
            {
                 size.height=([secondSectionfieldsArray  count]*44)+([firstSectionfieldsArr  count]*44)+35.0+48.0+spaceForHeader+buttonSpaceHeight  ;
            }
            // OR EDIT_ADHOC_TIMEOFF
            else
            {
                 size.height=([secondSectionfieldsArray  count]*44)+([firstSectionfieldsArr  count]*44)+35.0+spaceForHeader+buttonSpaceHeight  ;
            }
            [self.mainScrollView setContentSize:size];
        }
        
        
    }
    
	
	isFromSave=FALSE;
    
	[self hideCustomPickerView];
    if ([self.progressIndicator isAnimating]) {
        [self.progressIndicator stopAnimating];
    }
    [self.view setUserInteractionEnabled:TRUE];
    
    self.isCommentsTextFieldClicked=FALSE;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    countUDF=0;
    hasClient=TRUE;
    self.isComment=FALSE;
    
     if( [self screenMode] == EDIT_TIME_ENTRY || [self screenMode] == ADD_TIME_ENTRY || [self screenMode] == VIEW_TIME_ENTRY )
     {
         [self buildFirstSectionFieldsArray];
         [self buildSecondSectionFieldsArray];
     }
     else
     {
         [self buildFirstSectionFieldsArrayForTimeOff];
         [self buildSecondSectionFieldsArrayForTimeOff];
     }
	
	
    //	int extraHeightForLockedInOut=0;
	if (tnewTimeEntryTableView == nil) {
        
        int inOutHeight=0.0;
        if (isInOutFlag) {
            inOutHeight=80.0;
        }
        if(isLockedTimeSheet)
        {
            inOutHeight=EXTRA_SPACING_LOCKED_IN_OUT;
            //            extraHeightForLockedInOut=EXTRA_SPACING_LOCKED_IN_OUT;
        }
        if (countUDF<=1) {
            countFrame=3;
        }
        else
        {   countFrame=countUDF;
            countFrame++;
            countFrame++;
        }
        //US4065//Juhi
        //		UITableView *tempnewTimeEntryTableView = [[UITableView alloc] initWithFrame:  CGRectMake(10.0,0.0,self.view.frame.size.width-20.0,self.view.frame.size.height+inOutHeight+(countFrame*40.0)+20.0) 
        //                                                                              style:UITableViewStyleGrouped];
        UITableView *tempnewTimeEntryTableView = [[UITableView alloc] initWithFrame:  CGRectMake(0.0,10.0,self.view.frame.size.width,self.view.frame.size.height+inOutHeight+(countFrame*44.0)+44.0) 
                                                                              style:UITableViewStyleGrouped];        
        self.tnewTimeEntryTableView=tempnewTimeEntryTableView;
        
	}
    self.tnewTimeEntryTableView.delegate=self;
    self.tnewTimeEntryTableView.dataSource=self;
	[ self.tnewTimeEntryTableView setShowsVerticalScrollIndicator:NO];
	[self.tnewTimeEntryTableView setBackgroundColor:NewExpenseSheetBackgroundColor];
    self.tnewTimeEntryTableView.backgroundView=nil;
    [self.tnewTimeEntryTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];//DE5655 Ullas M L
    UIScrollView *scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [scrollView setBackgroundColor:[UIColor clearColor]];
    
    
    
    int buttonSpaceHeight=70.0;//US4065//Juhi
    int spaceForHeader=0.0;
    if(isLockedTimeSheet)
    {
        if ([self screenMode]==ADD_ADHOC_TIMEOFF || [self screenMode]==EDIT_ADHOC_TIMEOFF || [self screenMode]==VIEW_ADHOC_TIMEOFF)
        {
            if( [self screenMode] == EDIT_ADHOC_TIMEOFF )
            {
                if ([secondSectionfieldsArray count]==0)
                {
                    buttonSpaceHeight=151.0;
                }
                else
                {
                    buttonSpaceHeight=145.0;
                }
            }
            
            int spaceHeader=0.0;
            
            if([secondSectionfieldsArray count]==0)
            {
                spaceHeader=48.0+48.0+48.0;
            }
            else 
            {
                spaceHeader=48.0+48.0+48.0;
            }
            
            
            scrollView.contentSize= CGSizeMake(self.view.frame.size.width, ([secondSectionfieldsArray  count]*44)+([firstSectionfieldsArr  count]*44)+35.0+spaceHeader+buttonSpaceHeight  );//US4065//Juhi
        }
        else
        {
            if ([secondSectionfieldsArray  count]==0) 
            {
                spaceForHeader=53.0;
            }
            else
            {
                spaceForHeader=48.0+48.0;
            }    
            
            scrollView.contentSize= CGSizeMake(self.view.frame.size.width, ([secondSectionfieldsArray  count]*44)+EXTRA_SPACING_LOCKED_IN_OUT+35.0+spaceForHeader+44.0+30.0+44.0  );//US4065//Juhi
        }
        
        
        
    }
    else 
    {
        
        if( [self screenMode] == EDIT_TIME_ENTRY || [self screenMode] == EDIT_ADHOC_TIMEOFF)
        {
            buttonSpaceHeight=145.0;//US4065//Juhi
        }
        if ([secondSectionfieldsArray  count]==0) 
        {
            spaceForHeader=48.0+48.0;
        }
        else
        {
            spaceForHeader=48.0+48.0+48.0;
        }    
        
        scrollView.contentSize= CGSizeMake(self.view.frame.size.width, ([secondSectionfieldsArray  count]*44)+([firstSectionfieldsArr  count]*44)+35.0+spaceForHeader+buttonSpaceHeight  );//US4065//Juhi
    }
    DLog(@"scrollView.contentSize before reset %f",scrollView.contentSize.height);
    //    scrollView.contentSize= CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+(countFrame*60.0));
    [scrollView addSubview:tnewTimeEntryTableView];
    
    self.mainScrollView=scrollView;
    [self.view addSubview:self.mainScrollView];
    
	
    
    [self.tnewTimeEntryTableView setScrollEnabled:FALSE];
	
	[self.view setBackgroundColor:NewExpenseSheetBackgroundColor];
	
	[self setTitleForScreenMode:screenMode];
    
	[self setNavigationButtonsForScreenMode:screenMode];
	
	[self createFooterView];
    
    
    if ([self screenMode]!=ADD_TIME_ENTRY || [self screenMode]!=ADD_ADHOC_TIMEOFF) 
    {
        [self updateComments:self.commentsTextView.text];
    }
    else {
        
        [self updateComments:@""];
    }
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 20.0f, 20.0f)];
    [indicator setCenter:CGPointMake(160.0f, 188.0f)];
    [indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    self.progressIndicator=indicator;
   
    [self.view addSubview:self.progressIndicator];
    [self.view bringSubviewToFront:self.progressIndicator];
    
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    
    if (version>=7.0)
    {
        self.navigationController.navigationBar.translucent = FALSE;
        self.navigationController.navigationBar.barTintColor=RepliconStandardNavBarTintColor;
        self.navigationController.navigationBar.tintColor=RepliconStandardWhiteColor;
    }
    else
        self.navigationController.navigationBar.tintColor=RepliconStandardNavBarTintColor;
    
}

-(void)setTitleForScreenMode:(NSInteger)mode
{
    NSString *toolbarTitleText = @"";
	if (mode == EDIT_TIME_ENTRY) {
		toolbarTitleText = RPLocalizedString( EditTimeEntryTitle, EditTimeEntryTitle);
	}else if(mode == VIEW_TIME_ENTRY) {
		toolbarTitleText = RPLocalizedString(TimeEntryTopTitle, TimeEntryTopTitle);
	}else if(mode == ADD_TIME_ENTRY) {
		toolbarTitleText = RPLocalizedString( AddNewTimeEntryTitle, AddNewTimeEntryTitle);
	}
   else if (mode == EDIT_ADHOC_TIMEOFF) {
		toolbarTitleText = RPLocalizedString( EditTimeOffTitle, EditTimeEntryTitle);
	}else if(mode == VIEW_ADHOC_TIMEOFF) {
		toolbarTitleText = RPLocalizedString(ViewTimeOffTitle, TimeEntryTopTitle);
	}else if(mode == ADD_ADHOC_TIMEOFF) {
		toolbarTitleText = RPLocalizedString( AddTimeOffTitle, AddNewTimeEntryTitle);
	}
	[G2ViewUtil setToolbarLabel: self withText: toolbarTitleText];
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

#pragma mark Table DataSource methods

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor whiteColor]];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if([secondSectionfieldsArray count]==0)
    {
        return 1;
    }
    else 
    {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		//DLog(@"firstSectionfieldsArr %d",[firstSectionfieldsArr count]);
		if (isLockedTimeSheet && [self screenMode]!=ADD_ADHOC_TIMEOFF && [self screenMode]!=EDIT_ADHOC_TIMEOFF && [self screenMode]!=VIEW_ADHOC_TIMEOFF) {
            return 1.0;
        }
        else
        {
            return [firstSectionfieldsArr count];
        }
        
	}else if (section == 1) {
		//DLog(@"secondSectionfieldsArray %d",[secondSectionfieldsArray count]);
		return [secondSectionfieldsArray count];
	}else if (section == 2) {
		return 1;
	}
	return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	//US4065//Juhi
    return 30;    //return 35;
}
//US4275//Juhi
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    UIImage *lineImage = [G2Util thumbnailImage:G2Cell_HairLine_Image];
    return lineImage.size.height+10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (isLockedTimeSheet && [self screenMode]!=ADD_ADHOC_TIMEOFF && [self screenMode]!=EDIT_ADHOC_TIMEOFF && [self screenMode]!=VIEW_ADHOC_TIMEOFF)
    {
        if(indexPath.section==TIME)
        {
            return EXTRA_SPACING_LOCKED_IN_OUT;
        }
        else
        {
            return ROW_HEIGHT;
        }
    }
    
    else
    {
        return ROW_HEIGHT;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	
	//TODO: Customize Header
	G2CustomTableSectionHeaderView *tableSectionHeaderView = [[G2CustomTableSectionHeaderView alloc] 
															initWithFrame:CGRectMake(0, 0, 300, 40)];
	if (section == 0 && [firstSectionfieldsArr count] > 0) {
		
		[tableSectionHeaderView setViewProperties:TimeHeaderImage 
												 :G2TimeEntryTimeLabelFrame
												 :RPLocalizedString(TimeHeaderTitle,@"")];
	} 
    else if (section ==1 && [secondSectionfieldsArray count] > 0) {
		
		[tableSectionHeaderView setViewProperties:DetailsInfoHeaderImage 
												 :TimeEntryProjectInfoLabelFrame
												 :RPLocalizedString(TimeEntryProjectInfo,@"")];
        
	}
	
	return tableSectionHeaderView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier;
    
    UITableViewCell *cell;
    
    if (isLockedTimeSheet && indexPath.section==TIME && [self screenMode]!=ADD_ADHOC_TIMEOFF && [self screenMode]!=EDIT_ADHOC_TIMEOFF && [self screenMode]!=VIEW_ADHOC_TIMEOFF) {
        CellIdentifier = @"lockedCellIdentifier";
        
        cell =(G2LockedTimeSheetCellView *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell==nil) {
            DLog(@"Cell Created");
            NSArray *nibObjects=[[NSBundle mainBundle] loadNibNamed:@"G2LockedTimeSheetCellView" owner:nil options:nil];
            
            for (int i=0; i<[nibObjects count]; i++) {
                id currentObject=[nibObjects objectAtIndex:i];
                if([currentObject isKindOfClass:[G2LockedTimeSheetCellView class]])
                {
                    cell=(G2LockedTimeSheetCellView *)currentObject;
                    G2LockedTimeSheetCellView *cellTemp=(G2LockedTimeSheetCellView *)currentObject;
                    cellTemp.locationHeaderLbl.text=RPLocalizedString(@"Location", @"Location");
                }
            }
        }
        
        
    }
    else
    {
        CellIdentifier = @"Cell";
        cell =(G2TimeEntryCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[G2TimeEntryCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
    }
	
    if ([cell isKindOfClass:[G2TimeEntryCellView class]]) 
    {
         [cell setUserInteractionEnabled:YES];
    }
    
   
	
	UIColor	 *textColor   = NewRepliconStandardBlueColor;//US4065//Juhi
	
	id fieldType = nil;
	id fieldName = nil;
	id fieldValue = nil;
	NSInteger tagValue;
	
	if (screenMode == VIEW_TIME_ENTRY || screenMode == VIEW_ADHOC_TIMEOFF ) {
		//Disable User interaction while viewing an entry
		[cell setUserInteractionEnabled:NO];
		//textColor = RepliconStandardBlackColor;//DE1799
		textColor = [UIColor grayColor];
	}else if (screenMode == EDIT_TIME_ENTRY) {
		//TODO: Editing Entry
	} else {
		//TODO: Adding Entry
	}
	if(indexPath.row < [firstSectionfieldsArr count] && indexPath.section == TIME){
		self.rowDtls = (G2EntryCellDetails *)[firstSectionfieldsArr objectAtIndex:indexPath.row];
	}	
	else if(indexPath.row < [secondSectionfieldsArray count] && indexPath.section == PROJECT_INFO){
		self.rowDtls = (G2EntryCellDetails *)[secondSectionfieldsArray objectAtIndex:indexPath.row];
	}
	
    
    if ([cell isKindOfClass:[G2TimeEntryCellView class]]) {
        [(G2TimeEntryCellView *)cell setDetailsObj:self.rowDtls];
    }
	
	
	
	fieldType =  [self.rowDtls fieldType];
	fieldName =  [self.rowDtls fieldName];
	fieldValue = [self.rowDtls fieldValue];
    DLog(@"%@",fieldName);
    DLog(@"%@",fieldValue);
	if (fieldValue == nil) {
		fieldValue = [self.rowDtls defaultValue];
	}
	//DE8142
	if ([fieldName isEqualToString:TimeFieldName] && indexPath.section==TIME)
    {
		tagValue = TIME_TAG;
	}
    //DE8142
    else if ([fieldName isEqualToString:HoursFieldName] && indexPath.section==TIME) {
		tagValue = HOUR_TAG;
	}
    else {
		tagValue = indexPath.row;
	}
    //DE8142
    if (([fieldName isEqualToString:TimeInFieldName] && indexPath.section==TIME) || ([fieldName isEqualToString:TimeOutFieldName] && indexPath.section==TIME)) {
        if ([cell isKindOfClass:[G2TimeEntryCellView class]]) 
        {
            for (UIView *view in cell.contentView.subviews)
            {
                [view removeFromSuperview];
            }
            [(G2TimeEntryCellView *)cell layoutCell:tagValue withType:fieldType withfieldName:fieldName withFieldValue:[self.rowDtls defaultValue] withTextColor:textColor];
        }
        
	}
	else{
        if ([cell isKindOfClass:[G2TimeEntryCellView class]]) 
        {
            for (UIView *view in cell.contentView.subviews)
            {
                [view removeFromSuperview];
            }
            [(G2TimeEntryCellView *)cell layoutCell:tagValue withType:fieldType withfieldName:fieldName withFieldValue:fieldValue withTextColor:textColor];
        }
    }
	
    if ([cell isKindOfClass:[G2TimeEntryCellView class]]) 
    {
        [(G2TimeEntryCellView *)cell setTextFieldDelegate:self];
    }
	else if ([cell isKindOfClass:[G2LockedTimeSheetCellView class]]) 
    {
        //Fix for ios7//JUHI
        float version=[[UIDevice currentDevice].systemVersion floatValue];
        
        if ([[timeSheetEntryObject entryDate] isKindOfClass:[NSDate class]] ) {
            [[(G2LockedTimeSheetCellView *)cell dateLbl] setText:[G2Util convertPickerDateToString:(NSDate *)[timeSheetEntryObject entryDate]]];
        }
        if ([[timeSheetEntryObject numberOfHours] isKindOfClass:[NSString class]] )
        {//Fix for ios7//JUHI
            if (version>=7.0)
            {
                CGRect frame=[(G2LockedTimeSheetCellView *)cell hoursLbl].frame;
                frame.origin.x=215;
                [(G2LockedTimeSheetCellView *)cell hoursLbl].frame=frame;
            }
            
            NSArray *compArr=[[timeSheetEntryObject numberOfHours] componentsSeparatedByString:@":"];
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
                
                [timeSheetEntryObject setNumberOfHours:[[[compArr objectAtIndex:0] stringByAppendingString:@":"] stringByAppendingString:totalMinsStr]];
            }
            
            if ([timeSheetEntryObject outTime]==nil || [[timeSheetEntryObject outTime] isKindOfClass:[NSNull class]]) {
                [[(G2LockedTimeSheetCellView *)cell hoursLbl] setText:RPLocalizedString(@"In progress", @"In progress")];
            }
            else
            {
                [[(G2LockedTimeSheetCellView *)cell hoursLbl] setText:[timeSheetEntryObject numberOfHours]];
            }
            
            
        }
        if ([[timeSheetEntryObject inTime] isKindOfClass:[NSString class]] && [[timeSheetEntryObject outTime] isKindOfClass:[NSString class]] ) {
            //Fix for ios7//JUHI
            if (version>=7.0)
            {
                CGRect frame=[(G2LockedTimeSheetCellView *)cell timeInOutLbl].frame;
                frame.origin.x=170;
                [(G2LockedTimeSheetCellView *)cell timeInOutLbl].frame=frame;
            }
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AM_PM"]) {
                [[(G2LockedTimeSheetCellView *)cell timeInOutLbl] setText:[NSString stringWithFormat:@"%@ - %@",[G2Util convertMidnightTimeFormat:[timeSheetEntryObject inTime]],[G2Util convertMidnightTimeFormat:[timeSheetEntryObject outTime]]]];
            }
            else
            {
                [[(G2LockedTimeSheetCellView *)cell timeInOutLbl] setText:[NSString stringWithFormat:@"%@ - %@",[G2Util convert12HourTimeStringTo24HourTimeString:[timeSheetEntryObject inTime]],[G2Util convert12HourTimeStringTo24HourTimeString:[timeSheetEntryObject outTime]]]];
                
            }
            [[(G2LockedTimeSheetCellView *)cell clockImageView] setHidden:TRUE  ];
            
        }
        else  if ([[timeSheetEntryObject inTime] isKindOfClass:[NSString class]] && ([[timeSheetEntryObject outTime] isKindOfClass:[NSNull  class]] || [timeSheetEntryObject outTime] ==nil   )) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"AM_PM"]) {
                [[(G2LockedTimeSheetCellView *)cell timeInOutLbl] setText:[NSString stringWithFormat:@"%@ - ",[G2Util convertMidnightTimeFormat:[timeSheetEntryObject inTime]]]];
            }
            else
            {
                [[(G2LockedTimeSheetCellView *)cell timeInOutLbl] setText:[NSString stringWithFormat:@"%@ - ",[G2Util convert12HourTimeStringTo24HourTimeString:[timeSheetEntryObject inTime]]]];
            }
            
            [[(G2LockedTimeSheetCellView *)cell clockImageView] setHidden:FALSE];
            CGRect frame=[(G2LockedTimeSheetCellView *)cell timeInOutLbl].frame;
            frame.size.width= frame.size.width-20.0;
            [(G2LockedTimeSheetCellView *)cell timeInOutLbl].frame=frame;
            //Fix for ios7//JUHI
            if (version>=7.0)
            {
                CGRect frame=[(G2LockedTimeSheetCellView *)cell clockImageView].frame;
                frame.origin.x=275;
                [(G2LockedTimeSheetCellView *)cell clockImageView].frame=frame;
                frame=[(G2LockedTimeSheetCellView *)cell timeInOutLbl].frame;
                frame.origin.x=170;
                [(G2LockedTimeSheetCellView *)cell timeInOutLbl].frame=frame;
            }
        }
        //Fix for ios7//JUHI
        if (version>=7.0)
        {
            CGRect frame=[(G2LockedTimeSheetCellView *)cell locationValueLbl].frame;
            frame.origin.x=155;
            [(G2LockedTimeSheetCellView *)cell locationValueLbl].frame=frame;
            
        }
        if (appDelegate.isLocationServiceEnabled ) {
            [[(G2LockedTimeSheetCellView *)cell locationValueLbl] setText:RPLocalizedString(LOCATION_SERVICES_ENABLED,"") ];
            
        }
        else
        {
            [[(G2LockedTimeSheetCellView *)cell locationValueLbl] setText:RPLocalizedString(LOCATION_SERVICES_DISABLED, "")  ];
        }
    }
	
	
	//Vijay : change frame for Project, Task & Billing to increase readability - DE2801.
    //DE8142
	if (indexPath.section == PROJECT_INFO && (([fieldName isEqualToString:ClientProject] && indexPath.row<udfsStartIndexNo)|| ([fieldName isEqualToString:Task] && indexPath.row<udfsStartIndexNo)|| ([fieldName isEqualToString:Billing] && indexPath.row<udfsStartIndexNo) || ([fieldName isEqualToString:CLIENT] && indexPath.row<udfsStartIndexNo))) {
		
		if ([cell isKindOfClass:[G2TimeEntryCellView class]]) 
        {
            //Fix for ios7//JUHI
            float version=[[UIDevice currentDevice].systemVersion floatValue];
            
            if (version>=7.0)
            {
                [[(G2TimeEntryCellView *)cell fieldButton] setFrame:CGRectMake(127.0, 8.0, 178.0, 30.0)];
                
            }
            else
                [[(G2TimeEntryCellView *)cell fieldButton] setFrame:CGRectMake(112.0, 8.0, 178.0, 30.0)];//US4065//Juhi
        }
        
	}
	
	
	//[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];//DE3566//Juhi
	
    if ([cell isKindOfClass:[G2TimeEntryCellView class]]) 
    {
        [[(G2TimeEntryCellView *)cell fieldButton] addTarget:self action:@selector(cellButtonAction:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
	
    //DE8142
	if (([fieldName isEqualToString:Task]&& indexPath.row<udfsStartIndexNo)&& [fieldValue isEqualToString:NoTaskString]) {
		if ([cell isKindOfClass:[G2TimeEntryCellView class]]) 
        {
            [[(G2TimeEntryCellView *)cell fieldButton]  setTitle:RPLocalizedString(NoTaskString, NoTaskString) forState:UIControlStateNormal];
            [(G2TimeEntryCellView *)cell setUserInteractionEnabled:NO];
            [[(G2TimeEntryCellView *)cell fieldButton] setEnabled:NO];
            [[(G2TimeEntryCellView *)cell fieldName]setTextColor:RepliconStandardGrayColor];
            [[(G2TimeEntryCellView *)cell fieldButton] setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
	}
    //DE8142
    if (([fieldName isEqualToString:TypeFieldName] && indexPath.section==0) && [fieldValue isEqualToString:WORK_VAUE]) {
        if ([self screenMode]==EDIT_TIME_ENTRY || [self screenMode]==VIEW_TIME_ENTRY)
        {
            if ([cell isKindOfClass:[G2TimeEntryCellView class]]) 
            {
                [[(G2TimeEntryCellView *)cell fieldButton]  setTitle:RPLocalizedString(WORK_VAUE, WORK_VAUE) forState:UIControlStateNormal];
                [(G2TimeEntryCellView *)cell setUserInteractionEnabled:NO];
                [[(G2TimeEntryCellView *)cell fieldButton] setEnabled:NO];
                [[(G2TimeEntryCellView *)cell fieldName]setTextColor:RepliconStandardGrayColor];
                [[(G2TimeEntryCellView *)cell fieldButton] setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            }
        }
		
	}
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return nil;
}

#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.hackIndexPathForInOut=indexPath;
    
	[self handleButtonClicks: indexPath :nil];
}

#pragma mark General Methods

-(void)buildFirstSectionFieldsArray {
	
    
	if (firstSectionfieldsArr == nil) {
		[self setFirstSectionfieldsArr:[NSMutableArray array]];
	}
    else
    {
        [self.firstSectionfieldsArr removeAllObjects];
    }
	
    if ([customParentDelegate isKindOfClass:[G2ApprovalsUsersListOfTimeEntriesViewController class]])
    {
        G2ApprovalsModel *approvalModel = [[G2ApprovalsModel alloc] init];
        
        BOOL isEnterTimeAgainstTimeOff = [approvalModel checkUserPermissionWithPermissionName:@"TimeoffTimesheet" andUserId:self.timeSheetEntryObject.userID];
       
        
        NSArray *timeOffsArray=[supportDataModel getValidTimeOffCodesFromDatabaseForTimeOff];
        
        
        if (isEnterTimeAgainstTimeOff && [timeOffsArray count]>0)
        {
            self.isTimeOffEnabledForTimeEntry=TRUE;
            
            G2EntryCellDetails *typeFieldDetails = [[G2EntryCellDetails alloc] initWithDefaultValue:SelectString];
            
            if(screenMode == ADD_TIME_ENTRY || [self screenMode]==EDIT_TIME_ENTRY || [self screenMode]==VIEW_TIME_ENTRY) 
            {
                typeFieldDetails.defaultValue= RPLocalizedString( WORK_VAUE, @"");
                typeFieldDetails.fieldValue= RPLocalizedString( WORK_VAUE, @"");
            }
            
            
            [typeFieldDetails setFieldName:TypeFieldName];
            [typeFieldDetails setFieldType:DATA_PICKER];
            [typeFieldDetails setDataSourceArray:[NSMutableArray arrayWithObjects:@"", nil]];
            self.timeTypesArray = [supportDataModel getValidTimeOffCodesFromDatabaseForTimeOff];
            NSMutableArray *timeTypeListArr=[[NSMutableArray alloc] init];
            [timeTypeListArr addObject:WORK_VAUE];
            for (NSDictionary *dict in timeTypesArray) {
                [timeTypeListArr addObject:[dict objectForKey:@"name"]];
            }
            [typeFieldDetails setDataSourceArray:[NSMutableArray arrayWithObject:
                                                  timeTypeListArr]];
            
            [firstSectionfieldsArr addObject:typeFieldDetails];
           
        }

       
        
    }
    else
    {
        self.isTimeOffEnabledForTimeEntry=appDelegate.isTimeOffEnabled;
        if ( self.isTimeOffEnabledForTimeEntry)
        {
            G2EntryCellDetails *typeFieldDetails = [[G2EntryCellDetails alloc] initWithDefaultValue:SelectString];
            
            if(screenMode == ADD_TIME_ENTRY || [self screenMode]==EDIT_TIME_ENTRY || [self screenMode]==VIEW_TIME_ENTRY) 
            {
                typeFieldDetails.defaultValue= RPLocalizedString( WORK_VAUE, @"");
                typeFieldDetails.fieldValue= RPLocalizedString( WORK_VAUE, @"");
            }
            
            
            [typeFieldDetails setFieldName:TypeFieldName];
            [typeFieldDetails setFieldType:DATA_PICKER];
            int selectedIndex = [self getSelectedTimeOffTypeRowIndex];
            
            if (timeSheetEntryObject!=nil)
            {
                if ([timeOffEntryObject timeOffCodeType]!=nil && ![[timeOffEntryObject timeOffCodeType] isKindOfClass:[NSNull class]])
                {
                   
                        [typeFieldDetails setDefaultValue:RPLocalizedString( WORK_VAUE, @"")];
                    
                }

            }
            else
            {
                if ([timeOffEntryObject timeOffCodeType]!=nil && ![[timeOffEntryObject timeOffCodeType] isKindOfClass:[NSNull class]])
                {
                    if (selectedIndex==-1) 
                    {
                        [typeFieldDetails setDefaultValue:[timeOffEntryObject timeOffCodeType]];
                        disabledTimeOffTypeName=[timeOffEntryObject timeOffCodeType];
                    }
                    
                    
                    else if( [self.timeTypesArray count]  >selectedIndex ) {
                        [typeFieldDetails setDefaultValue:[[timeTypesArray objectAtIndex:selectedIndex] objectForKey:@"name"]];
                    }
                }

            }
            
            
        
            self.timeTypesArray = [supportDataModel getValidTimeOffCodesFromDatabaseForTimeOff];
            NSMutableArray *timeTypeListArr=[[NSMutableArray alloc] init];
            [timeTypeListArr addObject:WORK_VAUE];
            for (NSDictionary *dict in timeTypesArray) {
                [timeTypeListArr addObject:[dict objectForKey:@"name"]];
            }
            [typeFieldDetails setDataSourceArray:[NSMutableArray arrayWithObject:
                                                  timeTypeListArr]];
            [typeFieldDetails setComponentSelectedIndexArray:
             [NSMutableArray arrayWithObject:[NSNumber numberWithInt:selectedIndex]]];
            [firstSectionfieldsArr addObject:typeFieldDetails];
            
        }
    }
    


    
	G2EntryCellDetails *dateFieldDetails = [[G2EntryCellDetails alloc] initWithDefaultValue:[NSDate date]];
	
	[dateFieldDetails setFieldName:DateFieldName];
	[dateFieldDetails setFieldType:DATE_PICKER];
    
    NSDate *entryDate     = [timeSheetEntryObject entryDate];
    
    if (entryDate != nil) {
        [dateFieldDetails setFieldValue:entryDate];
    }
    
    [firstSectionfieldsArr addObject:dateFieldDetails];
   
    
    
    
    
    
    if (isInOutFlag  ) 
    {
        [self buildInOutTimeSheetsFieldsArray];
    }
    
    if (isLockedTimeSheet) {
        [self buildInOutTimeSheetsFieldsArray];
    }
    
    if(!isInOutFlag && !isLockedTimeSheet)
    {
        G2EntryCellDetails *timeFieldDetails = [[G2EntryCellDetails alloc] initWithDefaultValue:@"0.00"];
        [timeFieldDetails setFieldName:TimeFieldName];
        [timeFieldDetails setFieldType:NUMERIC_KEY_PAD];
        
        
        NSString *numberOfhrs = [timeSheetEntryObject numberOfHours];
        
        
        if (numberOfhrs != nil) {
            [timeFieldDetails setFieldValue:numberOfhrs];
        }
        
        
        [firstSectionfieldsArr addObject:timeFieldDetails];
        
        
    }
    
    
    
	
    
}

-(void)buildFirstSectionFieldsArrayForTimeOff {
	
    
	if (firstSectionfieldsArr == nil) {
		[self setFirstSectionfieldsArr:[NSMutableArray array]];
	}
    else
    {
        [self.firstSectionfieldsArr removeAllObjects];
    }
	
    
    G2EntryCellDetails *typeFieldDetails = [[G2EntryCellDetails alloc] initWithDefaultValue:SelectString];
    

	[typeFieldDetails setFieldName:TypeFieldName];
	[typeFieldDetails setFieldType:DATA_PICKER];
    
    self.timeTypesArray = [supportDataModel getValidTimeOffCodesFromDatabaseForTimeOff];
    
    NSMutableArray *timeOffTypeListArr=[[NSMutableArray alloc] init];
    for (NSDictionary *dict in self.timeTypesArray) {
        [timeOffTypeListArr addObject:[dict objectForKey:@"name"]];
    }
    [typeFieldDetails setDataSourceArray:[NSMutableArray arrayWithObject:
                                            timeOffTypeListArr]];
    
    
    int selectedIndex = [self getSelectedTimeOffTypeRowIndex];
    if ([timeOffEntryObject timeOffCodeType]!=nil && ![[timeOffEntryObject timeOffCodeType] isKindOfClass:[NSNull class]])
    {
        if (selectedIndex==-1) 
        {
            [typeFieldDetails setDefaultValue:[timeOffEntryObject timeOffCodeType]];
            disabledTimeOffTypeName=[timeOffEntryObject timeOffCodeType];
        }
        
        
        else if( [self.timeTypesArray count]  >selectedIndex ) {
            [typeFieldDetails setDefaultValue:[[timeTypesArray objectAtIndex:selectedIndex] objectForKey:@"name"]];
        }
    }
    //US4589//Juhi
    else
    {
        
        if ([self.timeTypesArray count]==1) {
            NSDictionary *dict=[self.timeTypesArray objectAtIndex:0];
            [typeFieldDetails setDefaultValue:[dict objectForKey:@"name"]];
            [self.timeOffEntryObject setTimeOffCodeType:[dict objectForKey:@"name"]];
            [self.timeOffEntryObject setTypeIdentity:[dict objectForKey:@"identity"]];
        } 
    }
    
    
    
    [typeFieldDetails setComponentSelectedIndexArray:
     [NSMutableArray arrayWithObject:[NSNumber numberWithInt:selectedIndex]]];
    if ([self.timeTypesArray count]>0) {
        [firstSectionfieldsArr addObject:typeFieldDetails];
        
        
    }

   
       typeFieldDetails = nil;

    
    
    
	G2EntryCellDetails *dateFieldDetails = [[G2EntryCellDetails alloc] initWithDefaultValue:[NSDate date]];
	
	[dateFieldDetails setFieldName:DateFieldName];
	[dateFieldDetails setFieldType:DATE_PICKER];
    
    NSDate *entryDate     = [timeOffEntryObject timeOffDate];
    
    if (entryDate != nil) {
        [dateFieldDetails setFieldValue:entryDate];
    }
    
    [firstSectionfieldsArr addObject:dateFieldDetails];
    
    
    
    
    
    
    
    
    G2EntryCellDetails *timeFieldDetails = [[G2EntryCellDetails alloc] initWithDefaultValue:@"0.00"];
    [timeFieldDetails setFieldName:TimeFieldName];
    [timeFieldDetails setFieldType:NUMERIC_KEY_PAD];
    
    
    NSString *numberOfhrs = [timeOffEntryObject numberOfHours];
    
    if (numberOfhrs != nil)
    {
        NSArray *minutesArr=[numberOfhrs componentsSeparatedByString:@":"];
        if ([minutesArr count]==2)
        {
            NSString *minutesStr=[minutesArr objectAtIndex:1];
            if ([minutesStr length]==1) 
            {
                numberOfhrs=[NSString stringWithFormat:@"%@0",numberOfhrs];
            }
            
        }
        [timeFieldDetails setFieldValue:numberOfhrs];
    }
    
    
    [firstSectionfieldsArr addObject:timeFieldDetails];
   
    

}

-(void)buildInOutTimeSheetsFieldsArray 
{
    
    
    G2EntryCellDetails *timeInFieldDetails = [[G2EntryCellDetails alloc] initWithDefaultValue:[NSDate date]];
	
	[timeInFieldDetails setFieldName:TimeInFieldName];
	[timeInFieldDetails setFieldType:TIME_PICKER];
    
    
    NSString *inTimeToBeUsed = [timeSheetEntryObject inTime];
    
    if (inTimeToBeUsed!=nil && [inTimeToBeUsed isKindOfClass:[NSString class]]) {
        if ([[inTimeToBeUsed substringToIndex:1 ] isEqualToString:@"0"]) {
            inTimeToBeUsed=[NSString stringWithFormat:@"12%@",[inTimeToBeUsed substringWithRange:NSMakeRange(1, [inTimeToBeUsed length]-1) ]];
        }
    }
    
    if (inTimeToBeUsed==nil || [inTimeToBeUsed  isKindOfClass:[NSNull class] ]) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormat setLocale:locale];
        [dateFormat setDateFormat:@"h:mm a"];
        inTimeToBeUsed = [dateFormat stringFromDate:[NSDate date]]; 
       
        
        [timeInFieldDetails setDefaultValue:RPLocalizedString(TIME_IN_OUT_DEFAULT_SELECT, @"")];
    }
    
    else
    {
        [timeInFieldDetails setDefaultValue:inTimeToBeUsed];
    }
    
    [timeInFieldDetails setFieldValue:inTimeToBeUsed];
    //    [timeInFieldDetails setDefaultValue:inTimeToBeUsed];
    
    
    
    
    [firstSectionfieldsArr addObject:timeInFieldDetails];
   
    
    
    G2EntryCellDetails *timeOutFieldDetails = [[G2EntryCellDetails alloc] initWithDefaultValue:[NSDate date]];
	
	[timeOutFieldDetails setFieldName:TimeOutFieldName];
	[timeOutFieldDetails setFieldType:TIME_PICKER];
    
    NSString *outTimeToBeUsed = [timeSheetEntryObject outTime];
    
    if (outTimeToBeUsed!=nil && [outTimeToBeUsed isKindOfClass:[NSString class]]) {
        if ([[outTimeToBeUsed substringToIndex:1 ] isEqualToString:@"0"]) {
            outTimeToBeUsed=[NSString stringWithFormat:@"12%@",[outTimeToBeUsed substringWithRange:NSMakeRange(1, [outTimeToBeUsed length]-1) ]];
        }
    }
    
    
    if (outTimeToBeUsed==nil || [outTimeToBeUsed  isKindOfClass:[NSNull class] ]) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormat setLocale:locale];
        [dateFormat setDateFormat:@"h:mm a"];
        outTimeToBeUsed = [dateFormat stringFromDate:[NSDate date]]; 
        
        [timeOutFieldDetails setDefaultValue:RPLocalizedString(TIME_IN_OUT_DEFAULT_SELECT, @"") ];
    }
    
    else
    {
        [timeOutFieldDetails setDefaultValue:outTimeToBeUsed];
    }
    
    
    [timeOutFieldDetails setFieldValue:outTimeToBeUsed];
    //    [timeOutFieldDetails setDefaultValue:inTimeToBeUsed];
    
    
    
    [firstSectionfieldsArr addObject:timeOutFieldDetails];
    
    
    G2EntryCellDetails *hoursFieldDetails = [[G2EntryCellDetails alloc] initWithDefaultValue:@"0.00"];
    [hoursFieldDetails setFieldName:HoursFieldName];
    [hoursFieldDetails setFieldType:NUMERIC_KEY_PAD];
    
    
    NSString *numberOfhrs = [timeSheetEntryObject numberOfHours];
    
    
    if (numberOfhrs != nil) {
        [hoursFieldDetails setFieldValue:numberOfhrs];
    }
    
    
    [firstSectionfieldsArr addObject:hoursFieldDetails];
   
    
}

-(void)buildSecondSectionFieldsArray {
	
    
	if (secondSectionfieldsArray == nil) {
		[self setSecondSectionfieldsArray:[NSMutableArray array]];
	}
    else
    {
        [self.secondSectionfieldsArray removeAllObjects];
    }
	
	BOOL againstProjects = [permissionsObj projectTimesheet];
	BOOL bothPermission = [permissionsObj bothAgainstAndNotAgainstProject];
	BOOL allowBilling = [permissionsObj billingTimesheet];
	BOOL useBillingInfo = [preferencesObj useBillingInfo];
	
	if (againstProjects || bothPermission) {
        
        NSString *clientDefaultValue = bothPermission?RPLocalizedString(NONE_STRING, @"") :RPLocalizedString(NONE_STRING, @"") ;
        if( [self screenMode] == VIEW_TIME_ENTRY )
        {
            clientDefaultValue=RPLocalizedString(NONE_STRING, @"");
        }
		G2EntryCellDetails *clientDetails = [[G2EntryCellDetails alloc] initWithDefaultValue:clientDefaultValue];
		[clientDetails setFieldName:CLIENT];
		[clientDetails setFieldType:MOVE_TO_NEXT_SCREEN];
        
        if (timeSheetEntryObject.clientIdentity == nil || [timeSheetEntryObject.clientIdentity isKindOfClass:[NSNull class]])
        {
            [timeSheetEntryObject setClientName: clientDefaultValue];
            [timeSheetEntryObject setClientIdentity: @"null"];
        }
        
        
        
        
		NSString *projDefaultValue = bothPermission?RPLocalizedString(NONE_STRING, @"") :RPLocalizedString(SelectString, @"") ;
        if( [self screenMode] == VIEW_TIME_ENTRY )
        {
            projDefaultValue=RPLocalizedString(NONE_STRING, @"");
        }
		G2EntryCellDetails *projectDetails = [[G2EntryCellDetails alloc] initWithDefaultValue:projDefaultValue];
		[projectDetails setFieldName:ClientProject];
		[projectDetails setFieldType:MOVE_TO_NEXT_SCREEN];
        
        if (timeSheetEntryObject.projectIdentity == nil || [timeSheetEntryObject.projectIdentity isKindOfClass:[NSNull class]])
        {
            [timeSheetEntryObject setProjectName: projDefaultValue];
            [timeSheetEntryObject setProjectIdentity: @"null"];
        }
        
        
		G2EntryCellDetails *taskDetails = [[G2EntryCellDetails alloc] initWithDefaultValue:NoTaskString];
		[taskDetails setFieldName:Task];
		[taskDetails setFieldType:MOVE_TO_NEXT_SCREEN];
		
        [self setClientDataDetails:clientDetails];
		[self setProjectDataDetails:projectDetails];
        
		
		[self setTaskDetails:taskDetails];
		
        [secondSectionfieldsArray addObject:clientDetails];
		[secondSectionfieldsArray addObject:projectDetails];
		[secondSectionfieldsArray addObject:taskDetails];
		
		 taskDetails = nil;
		 projectDetails = nil;
        clientDetails = nil;
        NSString *billingName=nil;
		if (allowBilling && useBillingInfo) {
			
			G2EntryCellDetails *billingDetails = [[G2EntryCellDetails alloc] initWithDefaultValue:NONBILLIABLE];//DE10367
			[billingDetails setFieldName:Billing];
			[billingDetails setFieldType:DATA_PICKER];
			[billingDetails setDataSourceArray:[NSMutableArray arrayWithObject:
												[self getBillingOptionsDataSourceArray:FALSE]]];
			
            billingName =[timeSheetEntryObject billingName] ;
			if (billingName != nil) {
				if (![billingName isEqualToString:@"Non-Billable"] &&
					![billingName isEqualToString:@"Non Billable"]) {
					NSString *billing = [NSString stringWithFormat:@"Billable (%@)",billingName];
					[billingDetails setFieldValue:billing];
				}else {
					[billingDetails setFieldValue:billingName];
				}
				int selectedIndex = [self getSelectedBillingRowIndex];
				[billingDetails setComponentSelectedIndexArray:
				 [NSMutableArray arrayWithObject:[NSNumber numberWithInt:selectedIndex]]];
			}
			else {
				[billingDetails setComponentSelectedIndexArray:
				 [NSMutableArray arrayWithObject:[NSNumber numberWithInt:0]]];
			}
            
			
			[secondSectionfieldsArray addObject:billingDetails];
			billingDetails = nil;
		}
        //DE5092//Juhi
        if (![billingName isEqualToString:@"Non-Billable"] &&
            ![billingName isEqualToString:@"Non Billable"]) {
            NSString *billingIdentity = [G2SupportDataModel getBillingTypeByProjRoleName: billingName];
            
            if (billingIdentity == nil)
            {
                NSMutableArray *tempBillingArray=[self getBillingOptionsDataSourceArray:TRUE];
                if (tempBillingArray==nil && [self screenMode]==EDIT_TIME_ENTRY)
                {
                    if (![NetworkMonitor isNetworkAvailableForListener:self]) {
                        
                        [G2Util showOfflineAlert];
                        return;
                        
                    }
                    else
                    {
                        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userBillingOptionsFinishedDownloadingForEditing)
                                                                     name:TIMESHEETS_USERBILLINGOPTIONS_FINSIHED_DOWNLOADING_EDITING object:nil];
                        [[G2RepliconServiceManager timesheetService]sendRequestToGetAllBillingOptionsByClientID:[timeSheetEntryObject clientIdentity]];
                        
                    }
                }

            }
            
            [timeSheetEntryObject setBillingIdentity:billingIdentity];
        }
        
        
        NSNumber *roleId = [supportDataModel getProjectRoleIdForBilling:[timeSheetEntryObject billingIdentity] :[timeSheetEntryObject projectIdentity]];
		if (roleId != nil && ![roleId isKindOfClass:[NSNull class]]) {
			//DO NOTHING HERE
		}
        else
        {
            roleId=[supportDataModel get_role_billing_identity:[timeSheetEntryObject billingIdentity] ];
            if (roleId && ![roleId isKindOfClass:[NSNull class]]) {
                self.disabledBillingOptionsName= [NSString stringWithFormat:@"Billable (%@)",[timeSheetEntryObject billingName]];
            }
        }
        
        
	}
    
    //FOR APPROVALS
    if ([customParentDelegate isKindOfClass:[G2ApprovalsUsersListOfTimeEntriesViewController class]])
    {
        G2ApprovalsModel *approvalModel = [[G2ApprovalsModel alloc] init];
        BOOL isTimesheetDisplayActivities = [approvalModel checkUserPermissionWithPermissionName:@"TimesheetDisplayActivities" andUserId:self.timeSheetEntryObject.userID];
        BOOL isTimesheetActivityRequired = [approvalModel checkUserPermissionWithPermissionName:@"TimesheetActivityRequired" andUserId:self.timeSheetEntryObject.userID];
       
        if (isTimesheetDisplayActivities || isTimesheetActivityRequired) {
            
            G2EntryCellDetails *activityDetails = [[G2EntryCellDetails alloc] initWithDefaultValue:RPLocalizedString(ACTIVITIES_DEFAULT_NONE, @"")];
            [activityDetails setFieldName:TimeEntryActivity];
            [activityDetails setFieldType:DATA_PICKER];
            [self setActivityDataDetails:activityDetails];
            
            if ([timeSheetEntryObject activityName]!=nil && ![[timeSheetEntryObject activityName] isKindOfClass:[NSNull class]])
            {
                
                [activityDetails setDefaultValue:[timeSheetEntryObject activityName]];
            }
            
            [secondSectionfieldsArray addObject:activityDetails];
            activityDetails = nil;
        }
        
        
    }
    
    //FOR TIMESHEETS
    else
    {
        G2PermissionsModel *permissionsModel = [[G2PermissionsModel alloc] init];
        BOOL isTimesheetDisplayActivities = [permissionsModel checkUserPermissionWithPermissionName:@"TimesheetDisplayActivities"];
        BOOL isTimesheetActivityRequired = [permissionsModel checkUserPermissionWithPermissionName:@"TimesheetActivityRequired"];
        
        if (isTimesheetDisplayActivities || isTimesheetActivityRequired) {
            
            G2EntryCellDetails *activityDetails = [[G2EntryCellDetails alloc] initWithDefaultValue:RPLocalizedString(ACTIVITIES_DEFAULT_NONE, @"")];
            [activityDetails setFieldName:TimeEntryActivity];
            [activityDetails setFieldType:DATA_PICKER];
            [self setActivityDataDetails:activityDetails];
            int selectedIndex = [self getSelectedActivityRowIndex];
            if ([timeSheetEntryObject activityName]!=nil && ![[timeSheetEntryObject activityName] isKindOfClass:[NSNull class]])
            {
                if (selectedIndex==-1) 
                {
                    [activityDetails setDefaultValue:[timeSheetEntryObject activityName]];
                    disabledActivityName=[timeSheetEntryObject activityName];
                }
                
                else if (selectedIndex==0 && [timeSheetEntryObject activityName]!=nil && ![[timeSheetEntryObject activityName] isKindOfClass:[NSNull class]] &&  [timeSheetEntryObject activityIdentity]==nil && [[timeSheetEntryObject activityName] isEqualToString:RPLocalizedString(ACTIVITIES_DEFAULT_NONE, @"")] && isTimesheetActivityRequired ) 
                {
                    [activityDetails setDefaultValue:RPLocalizedString(ACTIVITIES_DEFAULT_SELECT, @"") ];
                    disabledActivityName=RPLocalizedString(ACTIVITIES_DEFAULT_SELECT, @"");
                    if( [self screenMode] == VIEW_TIME_ENTRY )
                    {
                        [activityDetails setDefaultValue:RPLocalizedString(NONE_STRING, @"")];
                    }
                }
                
                else if( [activitiesArray count]  >selectedIndex ) {
                    [activityDetails setDefaultValue:[[activitiesArray objectAtIndex:selectedIndex] objectForKey:@"name"]];
                }
                //            if (selectedIndex==0) {
                //                //This will overide the current selection with default seection for first value
                //                NSDictionary *activityDict=[self.activitiesArray objectAtIndex:0];
                //                [timeSheetEntryObject setActivityName:[activityDict objectForKey:@"name"]];
                //                [timeSheetEntryObject setActivityIdentity:[activityDict objectForKey:@"identity"]];
                //            }
            }
            else
            {
                if (!isTimesheetActivityRequired)
                {
                    [activityDetails setDefaultValue:RPLocalizedString(NONE_STRING, @"")];
                }
            }
            
            [activityDetails setComponentSelectedIndexArray:
             [NSMutableArray arrayWithObject:[NSNumber numberWithInt:selectedIndex]]];
            if ([self.activitiesArray count]>0) {
                if ([self.activitiesArray count]==1) {
                    if ([[[self.activitiesArray objectAtIndex:0] objectForKey:@"name" ] isEqualToString:RPLocalizedString(NONE_STRING, @"") ] ) {
                        //DO NOTHING
                    }
                    else
                    {
                        [secondSectionfieldsArray addObject:activityDetails];
                    }
                }
                else
                {
                    [secondSectionfieldsArray addObject:activityDetails];
                }
                
            }
            
           activityDetails = nil;
        }
        
    }
    
    //Handle UDFs
    
    NSArray *udfsArray =nil;
    //FOR APPROVALS
    if ([customParentDelegate isKindOfClass:[G2ApprovalsUsersListOfTimeEntriesViewController class]])
    {
        G2ApprovalsModel *approvalsModel=[[G2ApprovalsModel alloc]init];

        if (timeSheetEntryObject!=nil)
        {
            udfsArray = [approvalsModel getEnabledOnlyTimeSheetLevelUDFsForCellAndRow];
        }
        else
        {
            udfsArray = [approvalsModel getEnabledOnlyTimeOffsUDFsForCellAndRow];
        }

    
    }
    //FOR TIMESHEETS
    else
    {
        if (timeSheetEntryObject!=nil)
        {
             udfsArray = [timesheetModel getEnabledOnlyTimeSheetLevelUDFsForCellAndRow];
        }
        else
        {
            udfsArray = [timesheetModel getEnabledOnlyTimeOffsUDFsForCellAndRow];
        }
        
    }
    
    udfsStartIndexNo=[secondSectionfieldsArray count];//DE8142
    
    [self buildUDFwithUDFArray:udfsArray];
}

-(void)buildSecondSectionFieldsArrayForTimeOff{
	
    
	if (secondSectionfieldsArray == nil) {
		[self setSecondSectionfieldsArray:[NSMutableArray array]];
	}
    else
    {
        [self.secondSectionfieldsArray removeAllObjects];
    }
	
    
    
    //Handle UDFs
    
    NSArray *udfsArray =nil;
    //FOR APPROVALS
    if ([customParentDelegate isKindOfClass:[G2ApprovalsUsersListOfTimeEntriesViewController class]])
    {
        G2ApprovalsModel *approvalsModel=[[G2ApprovalsModel alloc]init];
        udfsArray = [approvalsModel getEnabledOnlyTimeOffsUDFsForCellAndRow];
       
    }
    //FOR TIMESHEETS
    else
    {
        udfsArray = [timesheetModel getEnabledOnlyTimeOffsUDFsForCellAndRow];
        
    }
    
     udfsStartIndexNo=0;//DE8142
    [self buildUDFwithUDFArray:udfsArray];
}


-(void)buildUDFwithUDFArray:(NSArray *)udfsArray
{
    countUDF=0;
    if (udfsArray != nil && [udfsArray count] > 0) {
        //From the api we get all the UDFs. We need to filter UDFs based on whether it is applicable to the user.
        
        for (int i=0;  i < [udfsArray count];  i++) {
            NSDictionary *udfDict = [udfsArray objectAtIndex: i];
            NSString *moduleNameStr=nil;
            if ([[udfDict objectForKey:@"moduleName"] isEqualToString:@"TimeOffs" ]) 
            {
                 NSString *convertedModuleName=@"TimeOff";
                moduleNameStr=[NSString stringWithFormat:@"%@UDF%d",convertedModuleName,[[udfDict objectForKey:@"fieldIndex"]intValue]+1];
            }
           else
           {
               moduleNameStr=[NSString stringWithFormat:@"%@UDF%d",[udfDict objectForKey:@"moduleName"],[[udfDict objectForKey:@"fieldIndex"]intValue]+1];
           }
           
            
            BOOL hasPermissionForUDF=FALSE;
            if ([customParentDelegate isKindOfClass:[G2ApprovalsUsersListOfTimeEntriesViewController class]])
            {
                G2ApprovalsModel *approvalsModel = [[G2ApprovalsModel alloc] init];
                if (timeSheetEntryObject!=nil)
                {
                    hasPermissionForUDF=[approvalsModel checkUserPermissionWithPermissionName:moduleNameStr andUserId:timeSheetEntryObject.userID];
                }
                else
                {
                    hasPermissionForUDF=[approvalsModel checkUserPermissionWithPermissionName:moduleNameStr andUserId:timeOffEntryObject.userID];
                }
            
            }
            else 
            {
                G2PermissionsModel *permissionsModel = [[G2PermissionsModel alloc] init];
                hasPermissionForUDF=[permissionsModel checkUserPermissionWithPermissionName: moduleNameStr];
               
            }
            
            
            if ( hasPermissionForUDF) 
            {
                
                NSMutableDictionary *dictInfo = [NSMutableDictionary dictionary];
                [dictInfo setObject:[udfDict objectForKey:@"name"] forKey:@"fieldName"];
                [dictInfo setObject:[udfDict objectForKey:@"identity"] forKey:@"identity"];
                
                //DLog(@"%@ %@",
                //[udfDict objectForKey:@"name"],[udfDict objectForKey:@"identity"]);
                
                if ([[udfDict objectForKey:@"udfType"] isEqualToString: @"Numeric"]) 
                {
                    
                    [dictInfo setObject:NUMERIC_KEY_PAD forKey:@"fieldType"];
                    
                    
                    if( [self screenMode] == VIEW_TIME_ENTRY || screenMode == VIEW_ADHOC_TIMEOFF)
                    {
                        [dictInfo setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
                    }
                    else 
                    {
                        [dictInfo setObject:RPLocalizedString(@"Add", @"") forKey:@"defaultValue"];
                        if ([udfDict objectForKey:@"numericDecimalPlaces"]!=nil && !([[udfDict objectForKey:@"numericDecimalPlaces"] isKindOfClass:[NSNull class]])) 
                            [dictInfo setObject:[udfDict objectForKey:@"numericDecimalPlaces"] forKey:@"defaultDecimalValue"];
                        
                        if ([udfDict objectForKey:@"numericMinValue"]!=nil && !([[udfDict objectForKey:@"numericMinValue"] isKindOfClass:[NSNull class]])) {
                            [dictInfo setObject:[udfDict objectForKey:@"numericMinValue"] forKey:@"defaultMinValue"];
                        }
                        if ([udfDict objectForKey:@"numericMaxValue"]!=nil && !([[udfDict objectForKey:@"numericMaxValue"] isKindOfClass:[NSNull class]])) {
                            [dictInfo setObject:[udfDict objectForKey:@"numericMaxValue"] forKey:@"defaultMaxValue"];
                        }
                        
                        if ([udfDict objectForKey:@"numericDefaultValue"]!=nil && !([[udfDict objectForKey:@"numericDefaultValue"] isKindOfClass:[NSNull class]])) 
                        {
                            //DE4949 Ullas M L
                            //if( [self screenMode] != EDIT_TIME_ENTRY  && [self screenMode] != VIEW_TIME_ENTRY  )
                            //{
                            [dictInfo setObject:[udfDict objectForKey:@"numericDefaultValue"] forKey:@"defaultValue"];
                            //}
                            
                        }
                        
                    } 
                    
                }
                else if ([[udfDict objectForKey:@"udfType"] isEqualToString:@"Text"])
                {
                    [dictInfo setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
                    
                    
                    if( [self screenMode] == VIEW_TIME_ENTRY || screenMode == VIEW_ADHOC_TIMEOFF)
                    {
                        [dictInfo setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
                    }
                    else 
                    {
                        [dictInfo setObject:RPLocalizedString(@"Add", @"") forKey:@"defaultValue"];
                        if ([[udfDict objectForKey:@"textDefaultValue"] isEqualToString:@"null"]) {
                            [dictInfo setObject:RPLocalizedString(@"Add", @"") forKey:@"defaultValue"];
                            
                        }else {
                            if ([udfDict objectForKey:@"textDefaultValue"]!=nil &&![[udfDict objectForKey:@"textDefaultValue"] isEqualToString:@""] ) 
                                //DE4949 Ullas M L
                                //if( [self screenMode] != EDIT_TIME_ENTRY  && [self screenMode] != VIEW_TIME_ENTRY )
                                //{
                                [dictInfo setObject:[udfDict objectForKey:@"textDefaultValue"] forKey:@"defaultValue"];
                            //}
                            
                        }
                        if ([udfDict objectForKey:@"textMaxValue"]!=nil && !([[udfDict objectForKey:@"textMaxValue"] isKindOfClass:[NSNull class]])) 
                            [dictInfo setObject:[udfDict objectForKey:@"textMaxValue"] forKey:@"defaultMaxValue"];
                    }
                    
                    
                    
                } 
                else if ([[udfDict objectForKey:@"udfType"] isEqualToString:@"Date"])
                {
                    [dictInfo setObject: DATE_PICKER forKey: @"fieldType"];
                    
                    
                    if( [self screenMode] == VIEW_TIME_ENTRY || screenMode == VIEW_ADHOC_TIMEOFF)
                    {
                        [dictInfo setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
                    }
                    else 
                    {
                        [dictInfo setObject:RPLocalizedString(SelectString, @"") forKey:@"defaultValue"];
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
                                //DE4949 Ullas M L
                                //if( [self screenMode] != EDIT_TIME_ENTRY && [self screenMode] != VIEW_TIME_ENTRY   )
                                //{
                                [dictInfo setObject:[G2Util convertPickerDateToString:[NSDate date]] forKey:@"defaultValue"];
                                //}
                                
                            }else
                            {
                                if ([udfDict objectForKey:@"dateDefaultValue"]!=nil && !([[udfDict objectForKey:@"dateDefaultValue"] isKindOfClass:[NSNull class]]))
                                { 
                                    //DE4949 Ullas M L
                                    //if( [self screenMode] != EDIT_TIME_ENTRY && [self screenMode] != VIEW_TIME_ENTRY  )
                                    //{
                                    [dictInfo setObject:[udfDict objectForKey:@"dateDefaultValue"] forKey:@"defaultValue"];
                                    //}
                                    
                                    
                                }
                                else
                                {
                                    [dictInfo setObject:RPLocalizedString(SelectString, @"") forKey:@"defaultValue"];
                                }
                            }
                        }
                        else {
                            if ([udfDict objectForKey:@"dateDefaultValue"]!=nil && !([[udfDict objectForKey:@"dateDefaultValue"] isKindOfClass:[NSNull class]]))
                            { 
                                
                                //DE3200: Default date formatting was missing
                                NSString *dateStr = [udfDict objectForKey:@"dateDefaultValue"];
                                NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                                NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                                [dateFormat setLocale:locale];
                                [dateFormat setDateFormat:@"MMMM dd, yyyy"];
                                
                                NSDate *dateToBeUsed = [dateFormat dateFromString:dateStr]; 
                                
                                if (dateToBeUsed==nil) {
                                    [dateFormat setDateFormat:@"d MMMM yyyy"];
                                    dateToBeUsed = [dateFormat dateFromString:dateStr];
                                    //                                if (dateToBeUsed==nil)
                                    //                                {
                                    //                                    [dateFormat setDateFormat:@"d MMMM, yyyy"];
                                    //                                    dateToBeUsed = [dateFormat dateFromString:dateStr];
                                    //                                }
                                }
                                
                                
                                
                                NSString *dateDefaultValueFormatted = [G2Util convertPickerDateToString:dateToBeUsed];
                                
                                if(dateDefaultValueFormatted != nil)
                                {
                                    //DE4949 Ullas M L
                                    //if( [self screenMode] != EDIT_TIME_ENTRY && [self screenMode] != VIEW_TIME_ENTRY  )
                                    //{
                                    [dictInfo setObject:dateDefaultValueFormatted forKey:@"defaultValue"];
                                    // }
                                    
                                }
                                else
                                {
                                    //DE4949 Ullas M L
                                    // if( [self screenMode] != EDIT_TIME_ENTRY && [self screenMode] != VIEW_TIME_ENTRY  )
                                    //{
                                    [dictInfo setObject:[udfDict objectForKey:@"dateDefaultValue"] forKey:@"defaultValue"];
                                    // }
                                    
                                }
                                
                                //DE3200: Converted date as been added into dictionary instead of the default date value
                                //[dictInfo setObject:[udfDict objectForKey:@"dateDefaultValue"] forKey:@"defaultValue"];
                            }
                            else 
                            {
                                [dictInfo setObject:RPLocalizedString(SelectString, @"") forKey:@"defaultValue"];
                            }
                            
                            
                        }
                    }
                    
                    
                }
                else if ([[udfDict objectForKey:@"udfType"] isEqualToString:@"DropDown"])
                {
                    
                    [dictInfo setObject:DATA_PICKER forKey:@"fieldType"];
                    
                    
                    if( [self screenMode] == VIEW_TIME_ENTRY || screenMode == VIEW_ADHOC_TIMEOFF)
                    {
                        [dictInfo setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
                    }
                    else 
                    {
                        [dictInfo setObject:RPLocalizedString(SelectString, @"") forKey:@"defaultValue"];
                        NSMutableArray *dataSource=nil;
                        if ([customParentDelegate isKindOfClass:[G2ApprovalsUsersListOfTimeEntriesViewController class]])
                        {
                            G2ApprovalsModel *approvalsModel = [[G2ApprovalsModel alloc] init];
                            dataSource= [approvalsModel getDropDownOptionsForUDFIdentityForApprovals:[udfDict objectForKey:@"identity"]];
                           
                        }
                        else
                        {
                            dataSource= [supportDataModel getDropDownOptionsForUDFIdentity:[udfDict objectForKey:@"identity"]];
                        }
                        
                        
                        
                        for (int i=0; i<[dataSource count]; i++) {
                            //[dataSource objectAtIndex:i];
                            NSMutableDictionary *dict =[NSMutableDictionary dictionary];
                            
                            //DLog(@"%@",[dataSource objectAtIndex:i]);
                            
                            if ([[dataSource objectAtIndex:i] objectForKey:@"value"]!=nil) 
                            {
                                [dict setObject:[[dataSource objectAtIndex:i] objectForKey:@"value"] forKey:@"name"];
                            }
                            if ([[dataSource objectAtIndex:i] objectForKey:@"defaultOption"]!=nil) 
                            {
                                //DE4949 Ullas M L
                                //if( [self screenMode] != EDIT_TIME_ENTRY && [self screenMode] != VIEW_TIME_ENTRY  )
                                //{
                                [dict setObject:[[dataSource objectAtIndex:i] objectForKey:@"defaultOption"] forKey:@"defaultValue"];
                                // }
                                
                            }
                            if ([[dataSource objectAtIndex:i] objectForKey:@"identity"]!=nil) 
                            {
                                [dict setObject:[[dataSource objectAtIndex:i] objectForKey:@"identity"] forKey:@"identity"];
                            }
                            
                            [dataSource replaceObjectAtIndex:i withObject:dict];
                            
                            if ([[dict objectForKey:@"defaultValue"]intValue]==1) 
                            {
                                [dictInfo setObject:[[dataSource objectAtIndex:i] objectForKey:@"name"] forKey:@"defaultValue"];
                                [dictInfo setObject:[NSNumber numberWithInt:i] forKey:@"selectedIndex"];
                                [dictInfo setObject:[[dataSource objectAtIndex:i]objectForKey:@"name"] forKey:@"selectedDataSource"];
                            }
                            
                        }
                        if (dataSource!=nil && [dataSource count]>0) {
                            [dictInfo setObject:dataSource forKey:@"dataSourceArray"];
                            
                        }
                        
                    }
                    
                    
                }
                
                G2EntryCellDetails *udfDetails = [[G2EntryCellDetails alloc] initWithDefaultValue:[dictInfo objectForKey: @"defaultValue"]];
                
                [udfDetails setFieldName:[dictInfo objectForKey: @"fieldName" ]];
                [udfDetails setFieldType:[dictInfo objectForKey: @"fieldType" ]];
                [udfDetails setDecimalPoints:[[dictInfo objectForKey: @"defaultDecimalValue"]intValue]];
                if ([[udfDict objectForKey:@"moduleName"] isEqualToString: TaskTimesheet_RowLevel]|| [[udfDict objectForKey:@"moduleName"] isEqualToString: TimesheetEntry_CellLevel] || [[udfDict objectForKey:@"moduleName"] isEqualToString: @"TimeOffs"]) {
                    [udfDetails setUdfModule:[udfDict objectForKey:@"moduleName"]];
                }
                
                if ([[dictInfo objectForKey: @"fieldType" ] isEqualToString:MOVE_TO_NEXT_SCREEN ]) {
                    [udfDetails setFieldValue:[dictInfo objectForKey: @"defaultValue" ]];
                }
                if ([dictInfo objectForKey: @"dataSourceArray"]!=nil && [(NSMutableArray *)[dictInfo objectForKey: @"dataSourceArray"] count]>0) {
                    [udfDetails setDataSourceArray:[NSMutableArray arrayWithObject:
                                                    [dictInfo objectForKey: @"dataSourceArray"]]];
                    
                }
                
                NSMutableDictionary *selUDFDataDict=nil;
                if ([customParentDelegate isKindOfClass:[G2ApprovalsUsersListOfTimeEntriesViewController class]])
                {
                    G2ApprovalsModel *approvalsModel=[[G2ApprovalsModel alloc]init];
                    
                    if (timeSheetEntryObject!=nil)
                    {
                         selUDFDataDict=[approvalsModel getSelectedUdfsForEntry:[timeSheetEntryObject identity] andType:[udfDict objectForKey:@"moduleName"] andUDFName:[dictInfo objectForKey: @"fieldName" ]];
                    }
                    
                    else
                    {
                        selUDFDataDict=[approvalsModel getSelectedUdfsForEntry:[timeOffEntryObject identity] andType:[udfDict objectForKey:@"moduleName"] andUDFName:[dictInfo objectForKey: @"fieldName" ]];
                    }
                    
                
                }
                else 
                {
                    if (timeSheetEntryObject!=nil)
                    {
                        selUDFDataDict=[timesheetModel getSelectedUdfsForEntry:[timeSheetEntryObject identity] andType:[udfDict objectForKey:@"moduleName"]andUDFName:[dictInfo objectForKey: @"fieldName" ]];
                    }
                    else
                    {
                         selUDFDataDict=[timesheetModel getSelectedUdfsForEntry:[timeOffEntryObject identity] andType:[udfDict objectForKey:@"moduleName"] andUDFName:[dictInfo objectForKey: @"fieldName" ]];
                    }
                    
                }
                
                
                
                
                
                int selectedIndex =0;
                
                
                
                if ([[udfDetails fieldType]  isEqualToString:DATE_PICKER ]) 
                {
                    NSString *dateStr = [selUDFDataDict objectForKey: @"udfValue"] ;
                    if (dateStr==nil || [dateStr isKindOfClass:[NSNull class]]) {
                        dateStr=[dictInfo objectForKey:@"defaultValue"];
                    }
                    if (dateStr!=nil && ![dateStr isKindOfClass:[NSNull class]]) {
                        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                        [dateFormat setLocale:locale];
                        [dateFormat setDateFormat:@"yyyy-MM-dd"];
                        NSDate *setDate=[dateFormat dateFromString:dateStr];
                        if (!setDate) {
                            [dateFormat setDateFormat:@"MMMM dd, yyyy"];
                            setDate=[dateFormat dateFromString:dateStr];
                            
                            if (setDate==nil) {
                                [dateFormat setDateFormat:@"d MMMM yyyy"];
                                setDate = [dateFormat dateFromString:dateStr];
                                if (setDate==nil)
                                {
                                    [dateFormat setDateFormat:@"d MMMM, yyyy"];
                                    setDate = [dateFormat dateFromString:dateStr];
                                    
                                }
                            }
                            
                        }
                        [dateFormat setDateFormat:@"MMMM dd, yyyy"];
                        dateStr=[dateFormat stringFromDate:setDate];
                        NSDate *dateToBeUsed = [dateFormat dateFromString:dateStr]; 
                        
                        if(dateToBeUsed)
                        {
                            if( ([self screenMode] != EDIT_TIME_ENTRY && [self screenMode] != VIEW_TIME_ENTRY) || ([self screenMode] != EDIT_ADHOC_TIMEOFF && [self screenMode] != VIEW_ADHOC_TIMEOFF) || (selUDFDataDict!=nil && dateToBeUsed!=nil)  )
                            {
                                [udfDetails setFieldValue:dateToBeUsed];
                                [udfDetails setDefaultValue:dateToBeUsed];
                            }
                            
                            
                            
                        }
                        
                        
                        
                    }
                    
                    //                        selectedIndex = [self getSelectedUDFDropDownRowIndex:[selUDFDataDict objectForKey: @"udfValue" ] andUdfOptionArr:[dictInfo objectForKey: @"dataSourceArray"]];
                    
                }
                else
                {
                    
                    if ([selUDFDataDict objectForKey: @"udfValue" ]!=nil && ![[selUDFDataDict objectForKey: @"udfValue" ] isKindOfClass:[NSNull class]] && ![[selUDFDataDict objectForKey: @"udfValue" ] isEqualToString:@"" ]  ) {
                        
                        
                        
                        [udfDetails setFieldValue:[selUDFDataDict objectForKey: @"udfValue" ]];
                        [udfDetails setDefaultValue:[selUDFDataDict objectForKey: @"udfValue" ]];
                    }
                    else
                    {
                        if ([[dictInfo objectForKey:@"selectedIndex"]intValue]>0 ) {
                            selectedIndex=[[dictInfo objectForKey:@"selectedIndex"]intValue];
                        }
                    }
                    
                    if ([[udfDetails fieldType] isEqualToString:DATA_PICKER  ]) {
                        
                        if (![[selUDFDataDict objectForKey: @"udfValue" ] isKindOfClass:[NSNull class]] && [selUDFDataDict objectForKey: @"udfValue" ]!=nil) {
                            selectedIndex = [self getSelectedUDFDropDownRowIndex:[selUDFDataDict objectForKey: @"udfValue" ] andUdfOptionArr:[dictInfo objectForKey: @"dataSourceArray"]];
                            
                            if (selectedIndex==-1) {
                                self.disabledDropDownOptionsName=[selUDFDataDict objectForKey: @"udfValue" ];
                                selectedIndex=0;
                            }
                        }
                        
                        
                    }
                    
                }
                
                
                
                
                if(!selUDFDataDict)
                {
                    if ([[udfDetails fieldType] isEqualToString:DATA_PICKER  ]) {
                        selectedIndex = [self getSelectedUDFDropDownRowIndex:[dictInfo objectForKey: @"defaultValue" ] andUdfOptionArr:[dictInfo objectForKey: @"dataSourceArray"]];
                        if (selectedIndex==-1) {
                            self.disabledDropDownOptionsName=[selUDFDataDict objectForKey: @"udfValue" ];
                            selectedIndex=0;
                        }
                    }
                    
                    
                }
                
                
                [udfDetails setComponentSelectedIndexArray:
                 [NSMutableArray arrayWithObject:[NSNumber numberWithInt:selectedIndex]]];
                
                if ([self screenMode]==EDIT_TIME_ENTRY || [self screenMode]==EDIT_ADHOC_TIMEOFF) 
                {
                    NSString *udfvaleFormDb=[selUDFDataDict objectForKey: @"udfValue"];
                    if (udfvaleFormDb==nil ||  [udfvaleFormDb isKindOfClass:[NSNull class]]) 
                    {
                        
                        
                        if ([udfDetails.fieldType  isEqualToString:DATA_PICKER] ||  [udfDetails.fieldType  isEqualToString:DATE_PICKER]) 
                        {
                            udfDetails.fieldValue=RPLocalizedString(SelectString, @"");
                        }
                        else 
                        {
                            udfDetails.fieldValue=RPLocalizedString(@"Add", @"");
                        }
                    }
                    
                    else
                    {
                        if ([udfvaleFormDb isEqualToString:@""]) 
                        {
                            if ([udfDetails.fieldType  isEqualToString:DATA_PICKER] ||  [udfDetails.fieldType  isEqualToString:DATE_PICKER]) 
                            {
                                udfDetails.fieldValue=RPLocalizedString(SelectString, @"");
                            }
                            else 
                            {
                                udfDetails.fieldValue=RPLocalizedString(@"Add", @"");
                            }
                            
                        }
                    }
                }
                
               
                [secondSectionfieldsArray addObject:udfDetails];
        
                countUDF++;
            }	
        }
    }	
}

-(void)setProjectDataDetails:(G2EntryCellDetails *)projectDetails {
	
	
	NSString *projectName = [timeSheetEntryObject projectName];
	
		
	if (projectName != nil && ![projectName isKindOfClass:[NSNull class]]) {
		
		NSString *clientId = [timeSheetEntryObject clientIdentity];
		clientId = clientId == nil ?NO_CLIENT_ID : clientId;
		
		
		[projectDetails setFieldValue:projectName];
		
		NSMutableArray *projects = [supportDataModel getProjectsForClientWithClientId:clientId];
		if (projects != nil && [projects count] > 0) {
			
			//[projectDetails setDataSourceArray:[NSMutableArray arrayWithObjects:projects,nil]];
			
			
			NSUInteger projectIndex = 0;
			if ([[[projects objectAtIndex:0]objectForKey:@"name"] isEqualToString:projectName]) {
				
				projectIndex = [G2Util getIndex:projects forObj:projectName];
				
				NSString *projectId = [timeSheetEntryObject projectIdentity];
				NSString *clientAllocationId = [supportDataModel getClientAllocationId:clientId projectIdentity:projectId];
                NSString *projectBillingStatus = [supportDataModel getProjectBillableStatus:
                                                  projectId];
                timeSheetEntryObject.projectBillableStatus=projectBillingStatus;
				if (clientAllocationId != nil) {
					[timeSheetEntryObject setClientAllocationId:clientAllocationId];
				}
			}
			else {
				[timeSheetEntryObject setProjectRemoved:YES];
			}
            
			NSMutableArray *indicesArray = [NSMutableArray array];
			[indicesArray addObject:[NSNumber numberWithUnsignedInteger:projectIndex]];
			[projectDetails setComponentSelectedIndexArray:indicesArray];
			
			
			return;
		}
		else {
			[timeSheetEntryObject setProjectRemoved:YES];
		}
        
		
	}
	
	//handle project details when selected project is removed or for new entry.
//	[self handleProjectDetailsWhenProjectRemoved:projectDetails];
}

-(void)setClientDataDetails:(G2EntryCellDetails *)clientDetails {
	
	NSString *clientName = [timeSheetEntryObject clientName];

	
	self.clientsArray = [supportDataModel getAllClientsForTimesheets];
    
    if ([clientsArray count]==0) {
        hasClient=FALSE;
    }
    else if ([clientsArray count]==1) {
        if([[[clientsArray objectAtIndex:0]objectForKey:@"name"]  isEqualToString:RPLocalizedString(NONE_STRING, NONE_STRING) ])
        {
            hasClient=FALSE;
        }
    }
    
	
	if (clientName != nil && ![clientName isKindOfClass:[NSNull class]]) {
		
//		NSString *clientId = [timeSheetEntryObject clientIdentity];
//		clientId = clientId == nil ?NO_CLIENT_ID : clientId;
		clientName = clientName == nil?RPLocalizedString(NONE_STRING, NONE_STRING) : clientName;
		
		[clientDetails setFieldValue:clientName];
		
		
		if ( clientsArray != nil && [clientsArray count] >0) {
			
			//[clientDetails setDataSourceArray:[NSMutableArray arrayWithObjects:clientsArray,nil]];
			
			NSUInteger clientIndex = 0;
            

            clientIndex  = [G2Util getIndex:clientsArray forObj:clientName];
                   
           
						            
			NSMutableArray *indicesArray = [NSMutableArray array];
			[indicesArray addObject:[NSNumber numberWithUnsignedInteger:clientIndex]];
			[clientDetails setComponentSelectedIndexArray:indicesArray];
			
			
			return;
		}
		        
		
	}
	
	
}

-(void)setActivityDataDetails:(G2EntryCellDetails *)activityDetails {
    
    self.activitiesArray = [supportDataModel getUserActivitiesFromDatabase];
    NSMutableArray *activiyListArr=[[NSMutableArray alloc] init];
    for (NSDictionary *dict in activitiesArray) {
        [activiyListArr addObject:[dict objectForKey:@"name"]];
    }
    [activityDetails setDataSourceArray:[NSMutableArray arrayWithObject:
                                         activiyListArr]];
    
}

- (void) cellButtonAction: (id) sender withEvent: (UIEvent *) event{
	UITouch * touch = [[event allTouches] anyObject];
	CGPoint location = [touch locationInView: tnewTimeEntryTableView];
	NSIndexPath * indexPath = [tnewTimeEntryTableView indexPathForRowAtPoint: location];
	//DLog(@"indexPathPressed Button %d %d",indexPath.row,indexPath.section);
	[self handleButtonClicks:indexPath :sender];
}

-(void)handleButtonClicks:(NSIndexPath*)selectedButtonIndex :(id)sender
{
    //US5053 Ullas M L
    if (![sender isKindOfClass:[UISegmentedControl class]]) 
    {
        int timeRow=0;
        int timeSection=0;
        if (self.screenMode==ADD_ADHOC_TIMEOFF ||self.screenMode==ADD_TIME_ENTRY) 
        {
            if (isLockedTimeSheet)
            {
                timeRow=2;
            }
            else
            {
                if (isTimeOffEnabledForTimeEntry) 
                    timeRow=2;
                else 
                    timeRow=1;
            }
           
        }
        else if (self.screenMode==EDIT_TIME_ENTRY ||self.screenMode==EDIT_ADHOC_TIMEOFF) 
        {
            timeRow=2;
        }

        
        if ((selectedIndexPath.row==timeRow && selectedIndexPath.section==timeSection)&& (selectedButtonIndex.row!=timeRow || selectedButtonIndex.section!=timeSection)){
            
            [self validateTimeEntryFieldValueInCell];
            if (self.isTimeFieldValueBreak) 
            {
                self.isTimeFieldValueBreak=NO;
                return;
            }
        }

    }
        
	[self tableViewCellUntapped:selectedIndexPath animated:NO];
	[self resignAnyKeyPads:selectedIndexPath];
	
	[self tableCellTappedAtIndex:selectedButtonIndex];
    
	NSString *fieldType = nil;
	[self setSelectedIndexPath:selectedButtonIndex];
	//US4275//Juhi
	if (selectedButtonIndex!=nil)
    {
        [self initializeCustomPickerView];
    }
	
	G2TimeEntryCellView *selectedCell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:selectedIndexPath];
	
	fieldType = [[selectedCell detailsObj] fieldType];
	
	if ([fieldType isEqualToString:DATE_PICKER]) {
		[self datePickerAction :selectedCell senderObj: sender]; 
	}
    else if ([fieldType isEqualToString:TIME_PICKER] ) {
		[self timePickerAction :selectedCell senderObj: sender]; 
	}
	else if ([fieldType isEqualToString:DATA_PICKER]) {
        
        if ([(NSString *)[[selectedCell detailsObj] fieldName] isEqualToString:Billing] && selectedIndexPath.row<udfsStartIndexNo)
        {
            NSMutableArray *tempBillingArray=[self getBillingOptionsDataSourceArray:TRUE];
            if (tempBillingArray==nil)
            {
                if (![NetworkMonitor isNetworkAvailableForListener:self]) {
                    
                    [G2Util showOfflineAlert];
                    return;
                    
                }
                else
                {
                    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userBillingOptionsFinishedDownloading)
                                                                 name:TIMESHEETS_USERBILLINGOPTIONS_FINSIHED_DOWNLOADING object:nil];
                    [[G2RepliconServiceManager timesheetService]sendRequestToGetAllBillingOptionsByClientID:[timeSheetEntryObject clientIdentity]];
                    return;
                }
            }
            else
            {
                [self dataPickerAction :selectedCell senderObj: sender];
            }
        }
        else
        {
            [self dataPickerAction :selectedCell senderObj: sender];
        }
        
		
	}	
	else if ([fieldType isEqualToString:NUMERIC_KEY_PAD]) {
		[self numericKeyPadAction :selectedCell senderObj: sender];
	}
	else if ([fieldType isEqualToString:MOVE_TO_NEXT_SCREEN]) {isMovingToNextScreen=YES;
		[self moveToNextScreenAction :selectedCell senderObj: sender];
        
	}
	else if ([fieldType isEqualToString:CHECK_MARK]) {
		//handle if needed in future.
	}
	else {
		DLog(@"Unknown field Type");
        isFromDoneClicked=YES;
        
        
        
        
        [self moveToNextScreenFromCommentsTextViewClicked];
	}
    
	if (![fieldType isEqualToString:MOVE_TO_NEXT_SCREEN]) {
		
		[customPickerView showHideViewsByFieldType:fieldType];
		[self resetTableViewUsingSelectedIndex:selectedIndexPath];
		[self changeOfSegmentControlState:selectedIndexPath];
	}
}

-(void)initializeCustomPickerView {

	if (customPickerView == nil) {
        //JUHI
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        
		G2CustomPickerView *tempcustomPickerView= [[G2CustomPickerView alloc] initWithFrame:
                                                 CGRectMake(0, screenRect.size.height-320, 320, 320)];
        self.customPickerView = tempcustomPickerView;
        
        
		[self.customPickerView setDelegate:self];
		[self.customPickerView initializePickers];
		[self.customPickerView setToolbarRequired:YES];
		[self.view addSubview:self.customPickerView];
        
	}
}

-(void)selectDataPickerRowBasedOnValues {
	
	G2TimeEntryCellView *cell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:selectedIndexPath];
	G2EntryCellDetails *detailsObj = (G2EntryCellDetails *)[cell detailsObj];
	
	if (detailsObj != nil && ![detailsObj isKindOfClass:[NSNull class]]) {
		
		NSMutableArray *selectedIndicesArray = [detailsObj componentSelectedIndexArray];
		
		if (selectedIndicesArray != nil && [selectedIndicesArray count] >0) {
            
			for (int i=0; i <[selectedIndicesArray count]; i++) {
				
				int selectedRow = [[selectedIndicesArray objectAtIndex:i] intValue];
                //DE8142
                if ([[detailsObj fieldName] isEqualToString:ClientProject ] && selectedIndexPath.row<udfsStartIndexNo) {
                    if (hasClient) {
                        [self.customPickerView.pickerView selectRow:selectedRow inComponent: i animated:YES];
                    }
                    else
                    {
                        if (i==1) {
                            [self.customPickerView.pickerView selectRow:selectedRow inComponent: 0 animated:YES];
                            break;
                        }
                        
                    }
                }
                else
                {
                    if (selectedRow<0)
                    {
                        selectedRow=0;
                    }
                    [self.customPickerView.pickerView selectRow:selectedRow inComponent: i animated:YES];
                }
				
			}
		}
		
	}
}

-(void)buildFirstSectionFieldsArrayForTimeOffForAnimation:(BOOL)isAnimation {
	
    
    [self.tnewTimeEntryTableView beginUpdates];
    NSMutableArray *indexArray = [NSMutableArray array];
    
    if(isInOutFlag )
    {
        do {
             NSIndexPath *path = [NSIndexPath indexPathForRow:[self.firstSectionfieldsArr count]-1 inSection:0];
            [indexArray addObject:path];
            [self.firstSectionfieldsArr removeLastObject];
            
        } 
        while ([self.firstSectionfieldsArr count]>2);
        
        
    }
    
    else
    {
        NSIndexPath *path = [NSIndexPath indexPathForRow:[self.firstSectionfieldsArr count]-1 inSection:0];
        [indexArray addObject:path];
        [self.firstSectionfieldsArr removeLastObject];
        
        
    }
    
    G2EntryCellDetails *timeFieldDetails = [[G2EntryCellDetails alloc] initWithDefaultValue:@"0.00"];
    [timeFieldDetails setFieldName:TimeFieldName];
    [timeFieldDetails setFieldType:NUMERIC_KEY_PAD];
    [firstSectionfieldsArr addObject:timeFieldDetails];
   
   
    
    if (isInOutFlag) 
    {
        [self.tnewTimeEntryTableView deleteRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationLeft];
        [self.tnewTimeEntryTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.firstSectionfieldsArr count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    }
    else
    {
        [self.tnewTimeEntryTableView deleteRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
        [self.tnewTimeEntryTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.firstSectionfieldsArr count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    [self.tnewTimeEntryTableView endUpdates];
    
    
	
    
}

-(void)buildSecondSectionFieldsArrayForTimeOffForAnimation:(BOOL)isAnimation
{
    [self.tnewTimeEntryTableView beginUpdates];
    NSMutableArray *deleteIndexArray = [NSMutableArray array];
    NSMutableArray *insertIndexArray = [NSMutableArray array];

              
    for (int i=0; i<[self.secondSectionfieldsArray count]; i++)
    {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:1];
        [deleteIndexArray addObject:path];
        
    }   
     
    [self.secondSectionfieldsArray removeAllObjects];
    [self buildSecondSectionFieldsArrayForTimeOff];
    
    for (int i=0; i<[self.secondSectionfieldsArray count]; i++)
    {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:1];
        [insertIndexArray addObject:path];
    }
    
    
    
   
         [self.tnewTimeEntryTableView deleteRowsAtIndexPaths:deleteIndexArray withRowAnimation:UITableViewRowAnimationLeft];
        [self.tnewTimeEntryTableView insertRowsAtIndexPaths:insertIndexArray withRowAnimation:UITableViewRowAnimationRight];
    
    if ([self.secondSectionfieldsArray count]==0 && self.tnewTimeEntryTableView.numberOfSections==2)
    {
        NSMutableIndexSet *sectionsToDelete = [NSMutableIndexSet indexSet];
        [sectionsToDelete addIndex:1];
        [self.tnewTimeEntryTableView deleteSections:sectionsToDelete withRowAnimation:UITableViewRowAnimationTop];
    }
    else if ([self.secondSectionfieldsArray count]>0 && self.tnewTimeEntryTableView.numberOfSections==1)
    {
        NSMutableIndexSet *sectionsToAdd = [NSMutableIndexSet indexSet];
        [sectionsToAdd addIndex:1];
        [self.tnewTimeEntryTableView insertSections:sectionsToAdd withRowAnimation:UITableViewRowAnimationTop];
    }
    
    [self.tnewTimeEntryTableView endUpdates];
}

-(void)buildFirstSectionFieldsArrayForAnimation:(BOOL)isAnimation
{
    

    [self.tnewTimeEntryTableView beginUpdates];
    NSMutableArray *indexArray = [NSMutableArray array];
    
    if(isInOutFlag )
    {
            [self.tnewTimeEntryTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.firstSectionfieldsArr count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
            [self.firstSectionfieldsArr removeObjectAtIndex:[self.firstSectionfieldsArr count]-1];
            
        G2EntryCellDetails *timeInFieldDetails = [[G2EntryCellDetails alloc] initWithDefaultValue:[NSDate date]];
        
        [timeInFieldDetails setFieldName:TimeInFieldName];
        [timeInFieldDetails setFieldType:TIME_PICKER];
        [timeInFieldDetails setDefaultValue:RPLocalizedString(TIME_IN_OUT_DEFAULT_SELECT, @"")];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormat setLocale:locale];
        [dateFormat setDateFormat:@"h:mm a"];
       
        [timeInFieldDetails setFieldValue:[dateFormat stringFromDate:[NSDate date]]];
        [firstSectionfieldsArr addObject:timeInFieldDetails];
        
        
        
        G2EntryCellDetails *timeOutFieldDetails = [[G2EntryCellDetails alloc] initWithDefaultValue:[NSDate date]];
        
        [timeOutFieldDetails setFieldName:TimeOutFieldName];
        [timeOutFieldDetails setFieldType:TIME_PICKER];
        [timeOutFieldDetails setDefaultValue:RPLocalizedString(TIME_IN_OUT_DEFAULT_SELECT, @"") ];

         [timeOutFieldDetails setFieldValue:[dateFormat stringFromDate:[NSDate date]]];

        [firstSectionfieldsArr addObject:timeOutFieldDetails];
 
        
        G2EntryCellDetails *hoursFieldDetails = [[G2EntryCellDetails alloc] initWithDefaultValue:@"0.00"];
        [hoursFieldDetails setFieldName:HoursFieldName];
        [hoursFieldDetails setFieldType:NUMERIC_KEY_PAD];
        [hoursFieldDetails setFieldValue:@"0.00"];
            [firstSectionfieldsArr addObject:hoursFieldDetails];
        

        
        int count=1;
        
        do {
            NSIndexPath *path = [NSIndexPath indexPathForRow:[self.firstSectionfieldsArr count]-count inSection:0];
            [indexArray addObject:path];
            count++;
            
        } 
        while (count<=3);

        [self.tnewTimeEntryTableView insertRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationRight];
    }
    
      
    else
    {
        [self.tnewTimeEntryTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.firstSectionfieldsArr count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        [self.firstSectionfieldsArr removeObjectAtIndex:[self.firstSectionfieldsArr count]-1];
        
        G2EntryCellDetails *timeFieldDetails = [[G2EntryCellDetails alloc] initWithDefaultValue:@"0.00"];
        [timeFieldDetails setFieldName:TimeFieldName];
        [timeFieldDetails setFieldType:NUMERIC_KEY_PAD];
        [firstSectionfieldsArr addObject:timeFieldDetails];
       
        NSIndexPath *path = [NSIndexPath indexPathForRow:[self.firstSectionfieldsArr count]-1 inSection:0];
        [indexArray addObject:path];

        [self.tnewTimeEntryTableView insertRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
    }

    
    [self.tnewTimeEntryTableView endUpdates];
    

}

-(void)buildSecondSectionFieldsArrayForAnimation:(BOOL)isAnimation
{
    [self.tnewTimeEntryTableView beginUpdates];
    NSMutableArray *deleteIndexArray = [NSMutableArray array];
    NSMutableArray *insertIndexArray = [NSMutableArray array];
    
    
    for (int i=0; i<[self.secondSectionfieldsArray count]; i++)
    {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:1];
        [deleteIndexArray addObject:path];
        
    }   
    
    [self.secondSectionfieldsArray removeAllObjects];
    [self buildSecondSectionFieldsArray];
    
    for (int i=0; i<[self.secondSectionfieldsArray count]; i++)
    {
        NSIndexPath *path = [NSIndexPath indexPathForRow:i inSection:1];
        [insertIndexArray addObject:path];
    }
    
    
    
    
    [self.tnewTimeEntryTableView deleteRowsAtIndexPaths:deleteIndexArray withRowAnimation:UITableViewRowAnimationLeft];
    [self.tnewTimeEntryTableView insertRowsAtIndexPaths:insertIndexArray withRowAnimation:UITableViewRowAnimationRight];
    
    if ([self.secondSectionfieldsArray count]>0 && self.tnewTimeEntryTableView.numberOfSections==1)
    {
        NSMutableIndexSet *sectionsToAdd = [NSMutableIndexSet indexSet];
        [sectionsToAdd addIndex:1];
        [self.tnewTimeEntryTableView insertSections:sectionsToAdd withRowAnimation:UITableViewRowAnimationBottom];
    }
    else if ([self.secondSectionfieldsArray count]==0 && self.tnewTimeEntryTableView.numberOfSections==2)
    {
        NSMutableIndexSet *sectionsToDelete = [NSMutableIndexSet indexSet];
        [sectionsToDelete addIndex:1];
        [self.tnewTimeEntryTableView deleteSections:sectionsToDelete withRowAnimation:UITableViewRowAnimationTop];
    }
    
    [self.tnewTimeEntryTableView endUpdates];
    
    
}


-(void)updateFieldAtIndex:(NSIndexPath*)indexPath WithSelectedValues:(NSString *)selectedValue{
	//DLog(@"\nupdateFieldAtIndex::AddeNewTimeEntryViewController");
	G2TimeEntryCellView *cell = (G2TimeEntryCellView *)[self.tnewTimeEntryTableView cellForRowAtIndexPath:indexPath];
	G2EntryCellDetails *detailsObj = (G2EntryCellDetails *)[cell detailsObj];
	
	[detailsObj setFieldValue:selectedValue];
	[cell.fieldButton setTitle:selectedValue forState:UIControlStateNormal];
    //TYPE ROW
    
    if (indexPath.row==0 && indexPath.section==0 && !isLockedTimeSheet)
    {
        
        //NOT WORK
        if (![selectedValue isEqualToString:WORK_VAUE])
        {
            if (!self.isTimeOffEntry)
            {
               
                if (self.timeOffEntryObject==nil)
                {
                   
                    [self setTimeOffEntryObject:[G2TimeOffEntryObject createObjectWithDefaultValues]];

                }
                
                if (self.timeSheetEntryObject.entryDate!=nil)
                {
                    [self.timeOffEntryObject setTimeOffDate:self.timeSheetEntryObject.entryDate];
                }
                if (self.timeSheetEntryObject.comments!=nil)
                {
                    [self.timeOffEntryObject setComments:self.timeSheetEntryObject.comments];
                }
                
               
                
                 self.timeSheetEntryObject=nil;
                self.isTimeOffEntry=TRUE;
                [self buildFirstSectionFieldsArrayForTimeOffForAnimation:TRUE];
                [self buildSecondSectionFieldsArrayForTimeOffForAnimation:TRUE];
                [self recalculateScrollViewContentSize];
                if (screenMode == ADD_TIME_ENTRY)
                {
                    screenMode = ADD_ADHOC_TIMEOFF;
                } 
                else if (screenMode == EDIT_TIME_ENTRY)
                {
                    screenMode = EDIT_ADHOC_TIMEOFF;
                }    
                else if (screenMode == VIEW_TIME_ENTRY)
                {
                    screenMode = VIEW_ADHOC_TIMEOFF;
                }    
                [self setTitleForScreenMode:screenMode];
                
            }
           
        }
        else
        {
            if (self.isTimeOffEntry)
            {
                 
                if (self.timeSheetEntryObject==nil)
                {
                    [self setTimeSheetEntryObject:[G2TimeSheetEntryObject createObjectWithDefaultValues]];
                                       
                }
                if (self.timeOffEntryObject.timeOffDate!=nil)
                {
                    [self.timeSheetEntryObject setEntryDate:self.timeOffEntryObject.timeOffDate];
                }
                if (self.timeOffEntryObject.comments!=nil)
                {
                    [self.timeSheetEntryObject setComments:self.timeOffEntryObject.comments];
                }
               

                self.timeOffEntryObject=nil;
                self.isTimeOffEntry=FALSE;
                [self buildFirstSectionFieldsArrayForAnimation:TRUE];
                [self buildSecondSectionFieldsArrayForAnimation:TRUE];
                [self recalculateScrollViewContentSize];
                if (screenMode == ADD_ADHOC_TIMEOFF)
                {
                    screenMode = ADD_TIME_ENTRY;
                } 
                else if (screenMode == EDIT_ADHOC_TIMEOFF)
                {
                    screenMode = EDIT_TIME_ENTRY;
                }    
                else if (screenMode == VIEW_ADHOC_TIMEOFF)
                {
                    screenMode = VIEW_TIME_ENTRY;
                }    
                [self setTitleForScreenMode:screenMode];
               
            }
           
        }
    }
   
   
}

-(void)recalculateScrollViewContentSize
{
    //JUHI
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    //JUHI
    [self.mainScrollView setFrame:CGRectMake(0, 0, self.view.frame.size.width,
                                             screenRect.size.height-320)];
    
    //JUHI
    float height=screenRect.size.height-320;
    if ([secondSectionfieldsArray count]==0)
    {
        height=125.0;
    }
    height=height+([firstSectionfieldsArr count]*ROW_HEIGHT)+([secondSectionfieldsArray count]*ROW_HEIGHT+self.footerView.frame.size.height-150);
    if( [self screenMode] == EDIT_TIME_ENTRY || [self screenMode]==EDIT_ADHOC_TIMEOFF)
    {
        height=height+90.0;
    }
    else
    {
        height=height+10.0;
    }
    
    self.mainScrollView.contentSize=CGSizeMake(self.view.frame.size.width,height);
}

-(void)updateFieldValueForCell:(G2TimeEntryCellView *)entryCell withSelectedValue:(id)value {
	
	if (entryCell != nil && value != nil) {
        
		[entryCell.fieldButton setTitle:value forState:UIControlStateNormal];
	}
}

-(void)resetTableViewUsingSelectedIndex:(NSIndexPath*)selectedIndex{
    
    if(!self.isComment)
        
    {
		
        G2TimeEntryCellView *innerCell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:selectedIndex];
        G2EntryCellDetails *innerDetailsObj = (G2EntryCellDetails *)[innerCell detailsObj];
        NSString *fieldType= [innerDetailsObj fieldType];
        int extraHeightForLockedInOut=0;
        if(isLockedTimeSheet)
        {
            extraHeightForLockedInOut=EXTRA_SPACING_LOCKED_IN_OUT;
        }
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        if (selectedIndex!=nil) 
        {
             CGRect screenRect = [[UIScreen mainScreen] bounds];
            
            if (selectedIndex.section == TIME) {
                //JUHI
                [self.mainScrollView setFrame:CGRectMake(0, 0, self.view.frame.size.width,
                                                         screenRect.size.height-320)];
                
                //JUHI
                float height=screenRect.size.height-320;
                if ([secondSectionfieldsArray count]==0) 
                {
                    height=125.0;
                }
                height=height+([firstSectionfieldsArr count]*ROW_HEIGHT)+([secondSectionfieldsArray count]*ROW_HEIGHT+self.footerView.frame.size.height-150);
                if( [self screenMode] == EDIT_TIME_ENTRY || [self screenMode]==EDIT_ADHOC_TIMEOFF )
                {
                    height=height+90.0;
                }
                else
                {
                    height=height+10.0;
                }
                
                
                self.mainScrollView.contentSize=CGSizeMake(self.view.frame.size.width,height);
                
                if (![fieldType isEqualToString:MOVE_TO_NEXT_SCREEN]) 
                {
                    if(isLockedTimeSheet)
                    {
                        if( [self screenMode]==EDIT_ADHOC_TIMEOFF || [self screenMode]==ADD_ADHOC_TIMEOFF)
                        {
                            [self.mainScrollView setContentOffset:CGPointMake(0.0,selectedIndex.row*ROW_HEIGHT) animated:YES];
                        }
                        else
                        {
                            [self.mainScrollView setContentOffset:CGPointMake(0.0,(selectedIndex.row*ROW_HEIGHT)-ROW_HEIGHT) animated:YES];
                        }
                        
                    }
                    else
                    {
                        if (selectedIndex.row==0) {
                            
                            [self.mainScrollView setContentOffset:CGPointMake(0.0,selectedIndex.row*ROW_HEIGHT) animated:YES];
                            
                        }
                        else
                        {
                            [self.mainScrollView setContentOffset:CGPointMake(0.0,(selectedIndex.row*ROW_HEIGHT)-ROW_HEIGHT) animated:YES];
                        }
                    }
                    
                    
                }
            }
            
            
            
            else if(selectedIndex.section == PROJECT_INFO){
                //DE5011 Ullas M L
                [self.mainScrollView setFrame:CGRectMake(0, 0, self.view.frame.size.width,
                                                         400.0)];
                
                
                
                float height=380.0;
                height=height+([firstSectionfieldsArr count]*ROW_HEIGHT)+([secondSectionfieldsArray count]*ROW_HEIGHT+self.footerView.frame.size.height-150);
                
                
                if (isLockedTimeSheet) {
                    if( [self screenMode]==EDIT_ADHOC_TIMEOFF )
                    {
                        height=height+110.0;
                    }
                    else if( [self screenMode]==ADD_ADHOC_TIMEOFF )
                    {
                        height=height+40.0;
                    }
                    else
                    {
                         height=height-90.0;
                    }
                   
                    
                }
                else {
                    if( [self screenMode] == EDIT_TIME_ENTRY || [self screenMode]==EDIT_ADHOC_TIMEOFF)
                    {
                        height=height+110.0;
                        
                    }
                    else
                    {
                        height=height+35.0;
                    }
                    
                    
                }                  
                
                
                self.mainScrollView.contentSize=CGSizeMake(self.view.frame.size.width,height);
                
                
                if (![fieldType isEqualToString:MOVE_TO_NEXT_SCREEN]) 
                {
                    if (isLockedTimeSheet) 
                    {
                        if( [self screenMode]==EDIT_ADHOC_TIMEOFF ||[self screenMode]==ADD_ADHOC_TIMEOFF )
                        {
                            [self.mainScrollView setContentOffset:CGPointMake(0.0,(([firstSectionfieldsArr count]*ROW_HEIGHT)+(selectedIndex.row*ROW_HEIGHT))) animated:YES];
                        }
                        else
                        {
                             [self.mainScrollView setContentOffset:CGPointMake(0.0,(extraHeightForLockedInOut+(selectedIndex.row*ROW_HEIGHT))) animated:YES]; 
                        }
                         
                        
                        
                    }
                    else
                    { 
                        [self.mainScrollView setContentOffset:CGPointMake(0.0,(([firstSectionfieldsArr count]*ROW_HEIGHT)+(selectedIndex.row*ROW_HEIGHT))) animated:YES];
                        
                    }
                }
                
                
            }
            //Fix for ios7//JUHI
            float version=[[UIDevice currentDevice].systemVersion floatValue];
            if (version>=7.0)
            {
                [self.mainScrollView setFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height-318)];
            }
            
            
            
        }
        
        else if (selectedIndex==nil) {
            [self.mainScrollView setFrame:CGRectMake(0,0.0,self.view.frame.size.width,self.view.frame.size.height)];
            
            CGRect rect=self.tnewTimeEntryTableView.frame;
            rect.origin.y=10.0;//US4065//Juhi
            self.tnewTimeEntryTableView.frame=rect;
            CGSize size=self.mainScrollView.contentSize;
            int buttonSpaceHeight=40.0;//US4065//Juhi
            int spaceForHeader=0.0;
            
            if( [self screenMode] == EDIT_TIME_ENTRY ||[self screenMode] == ADD_TIME_ENTRY  ||[self screenMode] == VIEW_TIME_ENTRY)
            {
                if ([secondSectionfieldsArray  count]==0) 
                {
                    spaceForHeader=53.0;
                }
                else
                {
                    spaceForHeader=48.0+35.0;
                }    
            }
            else 
            {
                if([secondSectionfieldsArray count]==0)
                {
                    spaceForHeader=51.0;
                }
                else 
                {
                    if ([self screenMode] == EDIT_ADHOC_TIMEOFF)
                    {
                         spaceForHeader=48.0+48.0;
                    }
                    else
                    {
                        spaceForHeader=48.0+35.0;
                    }  
                }
            }
            
            if(isLockedTimeSheet)
            {
                if( [self screenMode] == EDIT_ADHOC_TIMEOFF )
                {
                    if ([secondSectionfieldsArray count]==0)
                    {
                        buttonSpaceHeight=107.0;
                    }
                    else
                    {
                        buttonSpaceHeight=100.0;
                    }
                }
                
                if ([self screenMode]== ADD_ADHOC_TIMEOFF || [self screenMode]== EDIT_ADHOC_TIMEOFF)
                {
                    size.height=([secondSectionfieldsArray  count]*44)+([firstSectionfieldsArr  count]*44)+35.0+spaceForHeader+commentsTextView.frame.size.height+buttonSpaceHeight   ;//US4275//Juhi
                }
                else
                {
                    size.height= ([secondSectionfieldsArray  count]*44)+EXTRA_SPACING_LOCKED_IN_OUT+35.0+spaceForHeader+commentsTextView.frame.size.height+buttonSpaceHeight   ;//US4275//Juhi
                }
                
                
            }
            else 
            {
                
                if( [self screenMode] == EDIT_TIME_ENTRY )
                {
                    buttonSpaceHeight=114;//US4065//Juhi
                    
                }
               else if( [self screenMode] == EDIT_ADHOC_TIMEOFF )
                {
                    if ([secondSectionfieldsArray count]==0)
                    {
                        buttonSpaceHeight=107.0;
                    }
                    else
                    {
                        buttonSpaceHeight=100.0;
                    }
                }
                size.height=([secondSectionfieldsArray  count]*44)+([firstSectionfieldsArr  count]*44)+35.0+spaceForHeader+commentsTextView.frame.size.height+buttonSpaceHeight   ;//US4275//Juhi
                
            }
            //DE5011 Ullas M L
            if (isFromDoneClicked) {
                //size.height=size.height-40;
                self.mainScrollView.contentSize=size;
                isFromDoneClicked=NO;
            }
            G2TimeEntryCellView *selectedCell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:selectedIndexPath];
            
            NSString *fieldType = [[selectedCell detailsObj] fieldType];
            
            
            if ([fieldType isEqualToString:MOVE_TO_NEXT_SCREEN]) {
                //self.mainScrollView.contentSize=size; //DE5011 Ullas M L
                
            }
            
            
            
        }
        
        [UIView commitAnimations];
    }
    else
    {
        self.isComment=FALSE;
        
    }
    
    
    
}

#pragma mark fieldType Action Methods

-(void)datePickerAction: (G2TimeEntryCellView *)selectedCell senderObj:(id)sender {
	
	//Date needs to be handled for two Scenarios - entryDate and UDF date.
	G2EntryCellDetails *detailsObj = (G2EntryCellDetails *)[selectedCell detailsObj];
    BOOL isEmptyDate=FALSE;
    if ([[detailsObj defaultValue] isKindOfClass:[NSString class]]) {
        if ([[detailsObj defaultValue] isEqualToString:RPLocalizedString(SelectString, @"") ]) {
            isEmptyDate=TRUE;
        }
    }
	
	NSMutableArray *dataArray = [NSMutableArray array];
	//id fieldValue = [detailsObj fieldValue] == nil ? [detailsObj defaultValue] : [detailsObj fieldValue];
    //DE6502//Juhi
    id fieldValue = [detailsObj fieldValue] == nil ||[[detailsObj fieldValue]isKindOfClass:[NSNull class]] ? [detailsObj defaultValue] : [detailsObj fieldValue];
    
    NSString *dateStr=fieldValue;
    if([fieldValue isKindOfClass:[NSString class]])
    {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setLocale:locale];//DE4949 Ullas M L
        if ([dateStr isEqualToString:RPLocalizedString(SelectString, @"")]||[dateStr isEqualToString:[detailsObj defaultValue]]) {
            fieldValue=[NSDate date];
            [dateFormatter setDateFormat:@"MMMM d, yyyy"];//DE10538//JUHI
            dateStr=[dateFormatter stringFromDate:fieldValue];
        }
        
        
        [dateFormatter setDateFormat:@"MMMM d, yyyy"];//DE10538//JUHI
        fieldValue = [dateFormatter dateFromString:dateStr];
        if (fieldValue==nil) {
            [dateFormatter setDateFormat:@"d MMMM, yyyy"];//DE10538//JUHI
            fieldValue = [dateFormatter dateFromString:dateStr];
            if (fieldValue==nil)
            {
                [dateFormatter setDateFormat:@"d MMMM, yyyy"];
                fieldValue = [dateFormatter dateFromString:dateStr];
            }
        }
        
        
    }
    
    if (isEmptyDate) {
        [detailsObj setDefaultValue:fieldValue];
        [detailsObj setFieldValue:fieldValue];
        [selectedCell.fieldButton setTitle:dateStr forState:UIControlStateNormal];
    }
	[dataArray addObject:fieldValue];
	
	[self.customPickerView setDataSourceArray:dataArray];
	[self.customPickerView setDateIndexPath:selectedIndexPath];
	[self.customPickerView setOtherPickerIndexPath:selectedIndexPath];
    [self resetTableViewUsingSelectedIndex:nil];
    
   if ([detailsObj fieldValue] == RPLocalizedString(SelectString, @"") || [[detailsObj fieldValue] isKindOfClass:[NSNull class]] || [detailsObj fieldValue]==nil ) 
   {
		[self updatePickedDateAtIndexPath:selectedIndexPath :fieldValue];
	}
	
}

-(void)timePickerAction: (G2TimeEntryCellView *)selectedCell senderObj:(id)sender {
	
    
	G2EntryCellDetails *detailsObj = (G2EntryCellDetails *)[selectedCell detailsObj];
    //    BOOL isEmptyDate=FALSE;
    //    if ([[detailsObj defaultValue] isKindOfClass:[NSString class]]) {
    //        if ([[detailsObj defaultValue] isEqualToString:@"Select" ]) {
    //            isEmptyDate=TRUE;
    //        }
    //    }
	
	NSMutableArray *dataArray = [NSMutableArray array];
//	id fieldValue = [detailsObj fieldValue] == nil ? [detailsObj defaultValue] : [detailsObj fieldValue];
    //DE6502//Juhi
    id fieldValue = [detailsObj fieldValue] == nil ||[[detailsObj fieldValue]isKindOfClass:[NSNull class]] ? [detailsObj defaultValue] : [detailsObj fieldValue];
    
    NSString *dateStr=nil;
    
    if([fieldValue isKindOfClass:[NSDate class]])
    {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormat setLocale:locale];
        [dateFormat setDateFormat:@"h:mm a"];
        dateStr = [dateFormat stringFromDate:[NSDate date]]; 
       
        
    }
    
    
    else if([fieldValue isKindOfClass:[NSString class]])
    {
        dateStr=fieldValue;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormatter setLocale:locale];
        //        if ([dateStr isEqualToString:@"Select"]) {
        //            fieldValue=[NSDate date];
        //            [dateFormatter setDateFormat:@"MMMM d yyyy"];
        //            dateStr=[dateFormatter stringFromDate:fieldValue];
        //        }
        
        
        [dateFormatter setDateFormat:@"h:mm a"];
        fieldValue = [dateFormatter dateFromString:dateStr];
        
        
    }
    
    //    if (isEmptyDate) {
    //        [detailsObj setDefaultValue:fieldValue];
    //        [detailsObj setFieldValue:fieldValue];
    //        [selectedCell.fieldButton setTitle:dateStr forState:UIControlStateNormal];
    //    }
    
    [selectedCell.fieldButton setTitle:dateStr forState:UIControlStateNormal];
	[detailsObj setFieldValue:dateStr];
    //DE8142
    if ([[detailsObj fieldName] isEqualToString:TimeInFieldName] && selectedIndexPath.section==TIME) {
        [timeSheetEntryObject setInTime:dateStr];
        
        if([timeSheetEntryObject outTime]!=nil && ![[timeSheetEntryObject outTime] isKindOfClass:[NSNull class]])
        {
            NSIndexPath *indexFromField = [NSIndexPath indexPathForRow:[self.firstSectionfieldsArr count]-1 inSection:TIME];
            G2TimeEntryCellView *innerCell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:indexFromField];
            NSString *hrsStr=[G2Util getNumberOfHours:[timeSheetEntryObject inTime] andDate2:[timeSheetEntryObject outTime]];
            [timeSheetEntryObject setNumberOfHours:hrsStr];
            [timeSheetEntryObject setNumberOfHoursInDouble:[G2Util getDoubleNumberOfHours:[timeSheetEntryObject inTime] andDate2:[timeSheetEntryObject outTime]]];
            G2EntryCellDetails *innerDetailsObj = (G2EntryCellDetails *)[innerCell detailsObj];
            [innerDetailsObj setFieldValue:hrsStr];
            [innerCell.textField setText:hrsStr];
        }
        else if([timeSheetEntryObject numberOfHours]!=nil && ![[timeSheetEntryObject numberOfHours] isKindOfClass:[NSNull class]] && ![[timeSheetEntryObject numberOfHours] isEqualToString:@"0.00"] )
        {
            NSIndexPath *indexFromField = [NSIndexPath indexPathForRow:[self.firstSectionfieldsArr count]-2 inSection:TIME];
            G2TimeEntryCellView *innerCell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:indexFromField];
            if (![timeSheetEntryObject numberOfHoursInDouble]) {
                [timeSheetEntryObject setNumberOfHoursInDouble:[[timeSheetEntryObject numberOfHours] doubleValue]];
            }
            NSString *timeStr=[G2Util getOutTime:[timeSheetEntryObject inTime] noOfHrs:[timeSheetEntryObject numberOfHoursInDouble]];
            [timeSheetEntryObject setOutTime:timeStr];
            G2EntryCellDetails *innerDetailsObj = (G2EntryCellDetails *)[innerCell detailsObj];
            [innerDetailsObj setFieldValue:timeStr];
            [self updateFieldValueForCell:innerCell withSelectedValue:timeStr];
        }
        
    }
    //DE8142
    else if ([[detailsObj fieldName] isEqualToString:TimeOutFieldName]&& selectedIndexPath.section==TIME) {
        [timeSheetEntryObject setOutTime:dateStr];
        if([timeSheetEntryObject inTime]!=nil && ![[timeSheetEntryObject inTime] isKindOfClass:[NSNull class]])
        {
            NSIndexPath *indexFromField = [NSIndexPath indexPathForRow:[self.firstSectionfieldsArr count]-1 inSection:TIME];
            G2TimeEntryCellView *innerCell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:indexFromField];
            NSString *hrsStr=[G2Util getNumberOfHours:[timeSheetEntryObject inTime] andDate2:[timeSheetEntryObject outTime]];
            [timeSheetEntryObject setNumberOfHours:hrsStr];
            [timeSheetEntryObject setNumberOfHoursInDouble:[G2Util getDoubleNumberOfHours:[timeSheetEntryObject inTime] andDate2:[timeSheetEntryObject outTime]]];
            G2EntryCellDetails *innerDetailsObj = (G2EntryCellDetails *)[innerCell detailsObj];
            [innerDetailsObj setFieldValue:hrsStr];
            [innerCell.textField setText:hrsStr];
        }
        else if([timeSheetEntryObject numberOfHours]!=nil && ![[timeSheetEntryObject numberOfHours] isKindOfClass:[NSNull class]] && ![[timeSheetEntryObject numberOfHours] isEqualToString:@"0.00"] )
        {
            NSIndexPath *indexFromField = [NSIndexPath indexPathForRow:[self.firstSectionfieldsArr count]-3 inSection:TIME];
            G2TimeEntryCellView *innerCell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:indexFromField];
            if (![timeSheetEntryObject numberOfHoursInDouble]) {
                [timeSheetEntryObject setNumberOfHoursInDouble:[[timeSheetEntryObject numberOfHours] doubleValue]];
            }
            NSString *timeStr=[G2Util getInTime:[timeSheetEntryObject outTime] noOfHrs:[timeSheetEntryObject numberOfHoursInDouble]];
            [timeSheetEntryObject setInTime:timeStr];
            G2EntryCellDetails *innerDetailsObj = (G2EntryCellDetails *)[innerCell detailsObj];
            [innerDetailsObj setFieldValue:timeStr];
            [self updateFieldValueForCell:innerCell withSelectedValue:timeStr];
        }
        
    }
    
    [dataArray addObject:fieldValue];
	
	[self.customPickerView setDataSourceArray:dataArray];
	[self.customPickerView setDateIndexPath:selectedIndexPath];
	[self.customPickerView setOtherPickerIndexPath:selectedIndexPath];
	
    
    
}

-(void)dataPickerAction: (G2TimeEntryCellView *)selectedCell senderObj:(id)sender {
	
	G2EntryCellDetails *detailsObj = (G2EntryCellDetails *)[selectedCell detailsObj];
	
	NSMutableArray *dataArray = nil;
	NSMutableArray *dataSourceArray = [detailsObj dataSourceArray]; 
 	
	if (dataSourceArray != nil && [dataSourceArray isKindOfClass:[NSMutableArray class]]) {
		
		dataArray = [NSMutableArray array];
		for (NSMutableArray *componentDataArray in dataSourceArray) {
			[dataArray addObject:componentDataArray];
		}
		//DE8142
        if ([[detailsObj fieldName] isEqualToString:ClientProject ] && selectedIndexPath.row<udfsStartIndexNo) {
            if (!hasClient && [dataArray count]==2) {
                [dataArray removeObjectAtIndex:0];
            }
        }
        
		[self.customPickerView setDataSourceArray:nil];
		[self.customPickerView setDataSourceArray:dataArray];
	}
	[self.customPickerView setDateIndexPath:nil];
	[self.customPickerView setOtherPickerIndexPath:selectedIndexPath];
    
	
	if ([detailsObj defaultValue] == RPLocalizedString(SelectString, @"") && [detailsObj fieldValue] == nil) {
		[self handleUpdatesForToolbarActions:selectedIndexPath];
	}
        
       
    [self setValueForActivitiesonNavigation];
}


-(void)numericKeyPadAction: (G2TimeEntryCellView *)selectedCell senderObj:(id)sender {
	
	[selectedCell.textField becomeFirstResponder];
	[self.customPickerView setOtherPickerIndexPath:selectedIndexPath];
}

-(void)moveToNextScreenAction: (G2TimeEntryCellView *)selectedCell senderObj:(id)sender {
	[self hideCustomPickerView];
	[self.customPickerView setOtherPickerIndexPath:selectedIndexPath];
	
	NSString *fieldName = [(G2EntryCellDetails *)[selectedCell detailsObj] fieldName];
    NSString *fieldType= [(G2EntryCellDetails *)[selectedCell detailsObj] fieldType];
	//DE8142
	if (selectedIndexPath.section == PROJECT_INFO && [fieldName isEqualToString:Task] && selectedIndexPath.row<udfsStartIndexNo) {
		
		[self fetchTasksForSelectedProject];
	}
	
    else if (selectedIndexPath.section == PROJECT_INFO && [fieldName isEqualToString:ClientProject] && selectedIndexPath.row<udfsStartIndexNo) {
		
        NSArray *allProjects=[supportDataModel getProjectsForClientWithClientId:[timeSheetEntryObject clientIdentity]];
        
        if (allProjects==nil || [allProjects count]==0)
        {
            [self fetchAllProjectsFormDatabaseOrAPI];
        }
        else if([allProjects count]==1)
        {
            if ([[[allProjects objectAtIndex:0] objectForKey:@"name"] isEqualToString:RPLocalizedString(NONE_STRING,@"")])
            {
                [self fetchAllProjectsFormDatabaseOrAPI];
            }
            else
            {
                G2DataListViewController *tempdataListViewCtrl=[[G2DataListViewController alloc]init];
                self.dataListViewCtrl=tempdataListViewCtrl;
                
                
                [self showAllProjectswithMoreButton:[NSNumber numberWithBool:TRUE]];
                
            }
        }
        else
        {
            G2DataListViewController *tempdataListViewCtrl=[[G2DataListViewController alloc]init];
            self.dataListViewCtrl=tempdataListViewCtrl;
            
            
            [self showAllProjectswithMoreButton:[NSNumber numberWithBool:TRUE]];
        }
        
        [self.navigationController pushViewController:self.dataListViewCtrl animated:YES];
        
	}
    
    else if (selectedIndexPath.section == PROJECT_INFO && [fieldName isEqualToString:CLIENT] && selectedIndexPath.row<udfsStartIndexNo) {
		
        NSArray *allClients=[supportDataModel getAllClientsForTimesheets];
        if (allClients==nil || [allClients count]==0)
        {
            [self fetchAllClientsFormDatabaseOrAPI];
        }
        else if([allClients count]==1)
        {
            if ([[[allClients objectAtIndex:0] objectForKey:@"name"] isEqualToString:RPLocalizedString(NONE_STRING,@"")])
            {
                [self fetchAllClientsFormDatabaseOrAPI];
            }
            else
            {
                G2DataListViewController *tempdataListViewCtrl=[[G2DataListViewController alloc]init];
                self.dataListViewCtrl=tempdataListViewCtrl;
                
                
                [self showAllClients];

            }
        }
        else
        {
            G2DataListViewController *tempdataListViewCtrl=[[G2DataListViewController alloc]init];
            self.dataListViewCtrl=tempdataListViewCtrl;
           
            
            [self showAllClients];
        }
        
        [self.navigationController pushViewController:self.dataListViewCtrl animated:YES];
       
	}
    
    ////// IF all of above conditions fail , it should be a TEXT UDF
    else if (selectedIndexPath.section == PROJECT_INFO  && [fieldType isEqualToString:MOVE_TO_NEXT_SCREEN] ) {
		G2AddDescriptionViewController *tempaddDescriptionViewController = [[G2AddDescriptionViewController alloc] init];
        self.addDescriptionViewController=tempaddDescriptionViewController;
		NSString *textStr = [(G2EntryCellDetails *)[selectedCell detailsObj] fieldValue];
        if (textStr!=nil && [textStr isKindOfClass:[NSNull class]]) {
            textStr=@"";
        }
        else if([textStr isEqualToString:@"null"])
        {
            textStr=@"";
        }
        //	[addDescriptionViewController setTitle:RPLocalizedString(TimeEntryComments,@"")];
		[addDescriptionViewController setViewTitle:[(G2EntryCellDetails *)[selectedCell detailsObj] fieldName]];
		[addDescriptionViewController setTimeEntryParentController:self];
		[addDescriptionViewController setDescTextString:textStr];
		[addDescriptionViewController setFromTimeEntryUDF:YES];
        [addDescriptionViewController setFromTimeEntryComments:NO];
		[addDescriptionViewController setDescControlDelegate:self];
        isFromDoneClicked=YES;
		[self.navigationController pushViewController:addDescriptionViewController animated:YES];
		
	}
    else
    {
        [self moveToNextScreenFromCommentsTextViewClicked];
    }
}

-(void)moveToNextScreenFromCommentsTextViewClicked
{
    if ([self screenMode]!=VIEW_TIME_ENTRY && [self screenMode]!=VIEW_ADHOC_TIMEOFF) 
    {
        G2AddDescriptionViewController *tempaddDescriptionViewController = [[G2AddDescriptionViewController alloc] init];
        self.addDescriptionViewController=tempaddDescriptionViewController;
        NSString *commentsText = [commentsTextView text];
        if ([commentsTextView text]==nil) {
            [addDescriptionViewController setDescTextString:@""];
        }
        else
        {
            [addDescriptionViewController setDescTextString:[commentsTextView text]];
        }
        
        //	[addDescriptionViewController setTitle:RPLocalizedString(TimeEntryComments,@"")];
        [addDescriptionViewController setViewTitle:RPLocalizedString(TimeEntryComments,@"")];
        [addDescriptionViewController setTimeEntryParentController:self];
        [addDescriptionViewController setDescTextString:commentsText];
        [addDescriptionViewController setFromTimeEntryComments:YES];
        [addDescriptionViewController setFromTimeEntryUDF:NO];
        [addDescriptionViewController setDescControlDelegate:self];
        [self.navigationController pushViewController:addDescriptionViewController animated:YES];
        
    }
    
   
    
    
}

#pragma mark Custom picker delegates

-(void)updatePickedDateAtIndexPath:(NSIndexPath *)dateIndexPath : (NSDate *) selectedDate {
	
	G2TimeEntryCellView *cell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:dateIndexPath];
	G2EntryCellDetails *detailsObj = (G2EntryCellDetails *)[cell detailsObj];
	
	if (dateIndexPath.section == TIME) {
		
        if ([[detailsObj fieldName] isEqualToString: DateFieldName]) 
        {
            [detailsObj setFieldValue:selectedDate];
            if (timeSheetEntryObject!=nil)
            {
                [timeSheetEntryObject setEntryDate:selectedDate];
            }
            if (timeOffEntryObject!=nil)
            {
                [timeOffEntryObject setTimeOffDate:selectedDate];
            }
            [self updateFieldValueForCell:cell withSelectedValue:[G2Util convertPickerDateToString:selectedDate]];
        }
        
        else if ([[detailsObj fieldName] isEqualToString: TimeInFieldName]) {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [dateFormat setLocale:locale];
            [dateFormat setDateFormat:@"h:mm a"];
            NSString *inTimeToBeUsed = [dateFormat stringFromDate:selectedDate]; 
            
            [detailsObj setFieldValue:inTimeToBeUsed];
            [timeSheetEntryObject setInTime:inTimeToBeUsed];
            [self updateFieldValueForCell:cell withSelectedValue:inTimeToBeUsed];
            
            if([timeSheetEntryObject outTime]!=nil && ![[timeSheetEntryObject outTime] isKindOfClass:[NSNull class]])
            {
                NSIndexPath *indexFromField = [NSIndexPath indexPathForRow:[self.firstSectionfieldsArr count]-1 inSection:TIME];
                G2TimeEntryCellView *innerCell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:indexFromField];
                NSString *hrsStr=[G2Util getNumberOfHours:[timeSheetEntryObject inTime] andDate2:[timeSheetEntryObject outTime]];
                [timeSheetEntryObject setNumberOfHours:hrsStr];
                [timeSheetEntryObject setNumberOfHoursInDouble:[G2Util getDoubleNumberOfHours:[timeSheetEntryObject inTime] andDate2:[timeSheetEntryObject outTime]]];
                G2EntryCellDetails *innerDetailsObj = (G2EntryCellDetails *)[innerCell detailsObj];
                [innerDetailsObj setFieldValue:hrsStr];
                [innerCell.textField setText:hrsStr];
            }
            else if([timeSheetEntryObject numberOfHours]!=nil && ![[timeSheetEntryObject numberOfHours] isKindOfClass:[NSNull class]] && ![[timeSheetEntryObject numberOfHours] isEqualToString:@"0.00"] )
            {
                NSIndexPath *indexFromField = [NSIndexPath indexPathForRow:[self.firstSectionfieldsArr count]-2 inSection:TIME];
                G2TimeEntryCellView *innerCell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:indexFromField];
                NSString *timeStr=[G2Util getOutTime:[timeSheetEntryObject inTime] noOfHrs:[timeSheetEntryObject numberOfHoursInDouble]];
                [timeSheetEntryObject setOutTime:timeStr];
                G2EntryCellDetails *innerDetailsObj = (G2EntryCellDetails *)[innerCell detailsObj];
                [innerDetailsObj setFieldValue:timeStr];
                [self updateFieldValueForCell:innerCell withSelectedValue:timeStr];
            }
        }
        else  if ([[detailsObj fieldName] isEqualToString: TimeOutFieldName]) {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [dateFormat setLocale:locale];
            [dateFormat setDateFormat:@"h:mm a"];
            NSString *outTimeToBeUsed = [dateFormat stringFromDate:selectedDate]; 
          
            [detailsObj setFieldValue:outTimeToBeUsed];
            [timeSheetEntryObject setOutTime:outTimeToBeUsed];
            [self updateFieldValueForCell:cell withSelectedValue:outTimeToBeUsed];
            
            if([timeSheetEntryObject inTime]!=nil && ![[timeSheetEntryObject inTime] isKindOfClass:[NSNull class]])
            {
                NSIndexPath *indexFromField = [NSIndexPath indexPathForRow:[self.firstSectionfieldsArr count]-1 inSection:TIME];
                G2TimeEntryCellView *innerCell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:indexFromField];
                NSString *hrsStr=[G2Util getNumberOfHours:[timeSheetEntryObject inTime] andDate2:[timeSheetEntryObject outTime]];
                [timeSheetEntryObject setNumberOfHours:hrsStr];
                [timeSheetEntryObject setNumberOfHoursInDouble:[G2Util getDoubleNumberOfHours:[timeSheetEntryObject inTime] andDate2:[timeSheetEntryObject outTime]]];
                G2EntryCellDetails *innerDetailsObj = (G2EntryCellDetails *)[innerCell detailsObj];
                [innerDetailsObj setFieldValue:hrsStr];
                [innerCell.textField setText:hrsStr];
            }
            else if([timeSheetEntryObject numberOfHours]!=nil && ![[timeSheetEntryObject numberOfHours] isKindOfClass:[NSNull class]] && ![[timeSheetEntryObject numberOfHours] isEqualToString:@"0.00"])
            {
                NSIndexPath *indexFromField = [NSIndexPath indexPathForRow:[self.firstSectionfieldsArr count]-3 inSection:TIME];
                G2TimeEntryCellView *innerCell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:indexFromField];
                NSString *timeStr=[G2Util getInTime:[timeSheetEntryObject outTime] noOfHrs:[timeSheetEntryObject numberOfHoursInDouble]];
                [timeSheetEntryObject setInTime:timeStr];
                G2EntryCellDetails *innerDetailsObj = (G2EntryCellDetails *)[innerCell detailsObj];
                [innerDetailsObj setFieldValue:timeStr];
                [self updateFieldValueForCell:innerCell withSelectedValue:timeStr];
            }
        } 
		
	}
	else if (dateIndexPath.section == PROJECT_INFO) {
		
        [detailsObj setFieldValue:selectedDate];
		//set date in timesheetEntryObject
        //DLog(@"%d",dateIndexPath.row);
		[secondSectionfieldsArray replaceObjectAtIndex:dateIndexPath.row withObject:detailsObj];
        [self updateFieldValueForCell:cell withSelectedValue:[G2Util convertPickerDateToString:selectedDate]];
	}
	
	
}

/*-(NSMutableArray *)getDependantComponentData: (NSIndexPath *)selectedIndexPathObj :(id)selectedValue :(NSInteger)component {
	//fetch fieldName for the component.
	
	TimeEntryCellView *cell = (TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:selectedIndexPathObj];
	EntryCellDetails *detailsObj = (EntryCellDetails *)[cell detailsObj];
	NSString *fieldName = [detailsObj fieldName];
	//DE8142
	if(selectedIndexPathObj.section == PROJECT_INFO && ([fieldName isEqualToString:ClientProject] && selectedIndexPathObj.row<udfsStartIndexNo )) {
		
		NSString *clientName = (NSString *)selectedValue;
		NSString *clientId = [supportDataModel getClientIdentityForClientName:clientName];
		
		[timeSheetEntryObject setClientName:clientName];
		[timeSheetEntryObject setClientIdentity:clientId];
        
		int selectedRowIndex = [Util getIndex:clientsArray forObj:clientName];
		[[detailsObj componentSelectedIndexArray] replaceObjectAtIndex:0 withObject:
         [NSNumber numberWithInt:selectedRowIndex]];
		
		NSMutableArray *projectsArr = [supportDataModel getProjectsForClientWithClientId:clientId];
		if (projectsArr != nil) {
			NSMutableArray *dataSource = [detailsObj dataSourceArray];
			if (dataSource != nil && [dataSource count] > 1) {
				[dataSource replaceObjectAtIndex:1 withObject:projectsArr];
			}
		}
		
		return projectsArr;
	}
	
    
	return nil;
}*/

-(void)updatePickerSelectedValueAtIndexPath:(NSIndexPath *)otherPickerIndexPath :(int) row :(int)component{
	//DLog(@"updatePickerSelectedValueAtIndexPath::ClientProjectTaskViewCOntroller");
	
	G2TimeEntryCellView *cell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:otherPickerIndexPath];
	G2EntryCellDetails *detailsObj = (G2EntryCellDetails *)[cell detailsObj];
	NSString *fieldName = [detailsObj fieldName];
	NSMutableArray *datasourceArray = [detailsObj dataSourceArray];
	//DE8142
/*	if ([fieldName isEqualToString:ClientProject] && otherPickerIndexPath.row<udfsStartIndexNo) {
		if (datasourceArray != nil && [datasourceArray count]>0) {
			NSMutableArray *projectsArr = nil;
            if (hasClient) {
                projectsArr = [datasourceArray objectAtIndex:component];
            }
            else
            {
                projectsArr = [datasourceArray objectAtIndex:1];
            }
			
			[self handleProjectSelection:projectsArr indexPath:otherPickerIndexPath row: row];
			
			//update the picker selected Row details
			int clientRow = [Util getIndex:clientsArray forObj:[timeSheetEntryObject clientName]];
			
			[[detailsObj componentSelectedIndexArray] removeAllObjects];
			[[detailsObj componentSelectedIndexArray] addObject:[NSNumber numberWithInt:clientRow]];
			[[detailsObj componentSelectedIndexArray] addObject:[NSNumber numberWithInt:row]];
		}
	}//DE8142 */
    if ([fieldName isEqualToString:TimeEntryActivity]&& otherPickerIndexPath.row<udfsStartIndexNo) {
        if (datasourceArray != nil && [datasourceArray count] > 0) {
            
            NSDictionary *activityDict=[self.activitiesArray objectAtIndex:row];
            [timeSheetEntryObject setActivityName:[activityDict objectForKey:@"name"]];
            [timeSheetEntryObject setActivityIdentity:[activityDict objectForKey:@"identity"]];
            
            
            [[detailsObj componentSelectedIndexArray] removeLastObject];
            [[detailsObj componentSelectedIndexArray] addObject:[NSNumber numberWithInt:row]];
            
            [self updateFieldAtIndex:otherPickerIndexPath WithSelectedValues:[activityDict objectForKey:@"name"]];
        }
	}//DE8142
	else if ([fieldName isEqualToString:Billing]&& otherPickerIndexPath.row<udfsStartIndexNo) {
		
		if (datasourceArray != nil && [datasourceArray count] > 0) {
			NSString *selectedValue = [[datasourceArray objectAtIndex:component] objectAtIndex:row];
			NSString *billingName = [self getSelectedBillingName:selectedValue];
			[timeSheetEntryObject setBillingName:billingName];
			NSString *billingIdentity = [self getBillingIdentityFromSelectedBillingName:selectedValue];
			[timeSheetEntryObject setBillingIdentity:billingIdentity];
			NSNumber *projectRoleId = [self getBillingRoleIdentity:billingIdentity];
			if (projectRoleId != nil && ![projectRoleId isKindOfClass:[NSNull class]]) {
				[timeSheetEntryObject setProjectRoleId:projectRoleId];
			}
			else {
				[timeSheetEntryObject setProjectRoleId:nil];
			}
			
			[[detailsObj componentSelectedIndexArray] removeLastObject];
			[[detailsObj componentSelectedIndexArray] addObject:[NSNumber numberWithInt:row]];
			
			[self updateFieldAtIndex:otherPickerIndexPath WithSelectedValues:selectedValue];
		}
	}
    ///THIS IS FOR TIME OFF TYPE
    //DE8142
    else if ([fieldName isEqualToString:TypeFieldName]&& otherPickerIndexPath.section==0) 
    {
        NSArray *dropDownArray= [datasourceArray objectAtIndex:0];
        [detailsObj setFieldValue:[dropDownArray objectAtIndex:row]];
        
         [self updateFieldAtIndex:otherPickerIndexPath WithSelectedValues:[dropDownArray objectAtIndex:row]];
        
        [firstSectionfieldsArr replaceObjectAtIndex:otherPickerIndexPath.row withObject:detailsObj];
        
        [[detailsObj componentSelectedIndexArray] removeLastObject];
        [[detailsObj componentSelectedIndexArray] addObject:[NSNumber numberWithInt:row]];
        
        
        
       
        if (![[dropDownArray objectAtIndex:row] isEqualToString:WORK_VAUE])
        {
             [self.timeOffEntryObject setTimeOffCodeType:[dropDownArray objectAtIndex:row]];
            NSDictionary *timeOffCodeDict=nil;
           if ([[dropDownArray objectAtIndex:0] isEqualToString:WORK_VAUE]) 
           {
                timeOffCodeDict=[self.timeTypesArray objectAtIndex:row-1];
           }
           else
           {
                timeOffCodeDict=[self.timeTypesArray objectAtIndex:row];
           } 
            [self.timeOffEntryObject setTypeIdentity:[timeOffCodeDict objectForKey:@"identity"]];


        }
        else
        {
             [self.timeSheetEntryObject setTimeCodeType:[dropDownArray objectAtIndex:row]];
            [self.timeSheetEntryObject setTypeIdentity:nil];
           
        }
               
       
        
    }
    ////// IF all of above conditions fail , it should be a dropdown UDF
    else if ([[detailsObj fieldType] isEqualToString:DATA_PICKER]) {
        if (datasourceArray != nil && [datasourceArray count] > 0) {
            
            if ([[[datasourceArray objectAtIndex:component] objectAtIndex:row] isKindOfClass:[NSMutableDictionary class]]) 
            {
                NSDictionary *dropDownDict= [[datasourceArray objectAtIndex:component] objectAtIndex:row];
                [detailsObj setFieldValue:[dropDownDict objectForKey:@"name"]];
                //set date in timesheetEntryObject
                //DLog(@"%d",otherPickerIndexPath.row);
                [secondSectionfieldsArray replaceObjectAtIndex:otherPickerIndexPath.row withObject:detailsObj];
                
                [[detailsObj componentSelectedIndexArray] removeLastObject];
                [[detailsObj componentSelectedIndexArray] addObject:[NSNumber numberWithInt:row]];
                
                [self updateFieldAtIndex:otherPickerIndexPath WithSelectedValues:[dropDownDict objectForKey:@"name"]];
                
                
            }
            
            
            
        }
	}
    
    
   
}

-(void)showCustomPickerIfApplicable:(UITextField *)textField {
	
	//[self tableViewCellUntapped:selectedIndexPath];
	
	NSIndexPath *indexFromField = nil;
	
	if ([textField tag] == TIME_TAG) {
		indexFromField = [NSIndexPath indexPathForRow:[self.firstSectionfieldsArr count]-1 inSection:TIME];
	}
    else if ([textField tag] == HOUR_TAG) {
		indexFromField = [NSIndexPath indexPathForRow:[self.firstSectionfieldsArr count]-1 inSection:TIME];
	}
    
	else {
		indexFromField = [NSIndexPath indexPathForRow:[textField tag] inSection:PROJECT_INFO];
	}
	
	if (indexFromField != selectedIndexPath) {
		[self tableViewCellUntapped:selectedIndexPath animated:NO];
	}
	
	[self setSelectedIndexPath:indexFromField];
	[self tableCellTappedAtIndex:selectedIndexPath];
	
	if (customPickerView == nil) {
		[self initializeCustomPickerView];
	}
	[self.customPickerView setOtherPickerIndexPath:selectedIndexPath];
	[self.customPickerView showHideViewsByFieldType:NUMERIC_KEY_PAD];
	[self setLastUsedTextField:textField];
}

-(void)resignAnyKeyPads:(NSIndexPath *)indexPath {
	
    
	[self tableViewCellUntapped:indexPath  animated:NO];
	
	if (lastUsedTextField != nil) {
		[lastUsedTextField resignFirstResponder];
	}
	G2TimeEntryCellView *cell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:indexPath];
	G2EntryCellDetails *detailsObj = (G2EntryCellDetails *)[cell detailsObj];
	
    
	if ([[detailsObj fieldType] isEqualToString: NUMERIC_KEY_PAD]) {
        
        
		if (indexPath.section == TIME && ([cell.textField tag] == TIME_TAG || [cell.textField tag] == HOUR_TAG)  ) {
            self.isNotMatching=FALSE;
            if (isInOutFlag) 
            {
                
                //                TimeEntryCellView *hackcell =nil;
                G2EntryCellDetails *hackdetailsObj =nil;
                
                //                if (!self.hackIndexPathForInOut) {
                //hackcell=cell;
                hackdetailsObj=detailsObj;
                //                }
                //                else
                //                {
                //                    hackcell= (TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:self.hackIndexPathForInOut];
                //                    hackdetailsObj=  (EntryCellDetails *)[hackcell detailsObj];
                //                }
                //                
                
                if (timeSheetEntryObject!=nil)
                {
                    
                    if ([[hackdetailsObj fieldValue] isKindOfClass:[NSString class]])  {
                        if (![[hackdetailsObj fieldValue] isEqualToString:[timeSheetEntryObject numberOfHours]]  && [[hackdetailsObj fieldValue] isEqualToString: NUMERIC_KEY_PAD]&& [[[hackdetailsObj fieldValue] componentsSeparatedByString:@":"] count]==1 )
                        {
                            [timeSheetEntryObject setNumberOfHours:[cell.textField text]];
                            [timeSheetEntryObject setNumberOfHoursInDouble:[[cell.textField text] doubleValue]];
                            [detailsObj setFieldValue:[cell.textField text]];
                            self.isNotMatching=TRUE;
                        }
                    }

                }
                else
                {
                            [timeOffEntryObject setNumberOfHours:[cell.textField text]];
                            //[timeOffEntryObject setNumberOfHoursInDouble:[[cell.textField text] doubleValue]];
                            [detailsObj setFieldValue:[cell.textField text]];
                       

                }
                              
            }
            else
            {
                if (timeSheetEntryObject!=nil)
                {
                    [timeSheetEntryObject setNumberOfHours:[cell.textField text]];
                }
                else
                {
                    [timeOffEntryObject setNumberOfHours:[cell.textField text]];
                }
                
                [detailsObj setFieldValue:[cell.textField text]];
            }
            
            
            
            if (self.isNotMatching) {
                if ([cell.textField tag] == HOUR_TAG) {
                    if([timeSheetEntryObject inTime]!=nil && ![[timeSheetEntryObject inTime] isKindOfClass:[NSNull class]])
                    {
                        NSIndexPath *indexFromField = [NSIndexPath indexPathForRow:[self.firstSectionfieldsArr count]-2 inSection:TIME];
                        G2TimeEntryCellView *innerCell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:indexFromField];
                        NSString *timeStr=[G2Util getOutTime:[timeSheetEntryObject inTime] noOfHrs:[timeSheetEntryObject numberOfHoursInDouble]];
                        [timeSheetEntryObject setOutTime:timeStr];
                        G2EntryCellDetails *innerDetailsObj = (G2EntryCellDetails *)[innerCell detailsObj];
                        [innerDetailsObj setFieldValue:timeStr];
                        [self updateFieldValueForCell:innerCell withSelectedValue:timeStr];
                    }
                    else if([timeSheetEntryObject outTime]!=nil && ![[timeSheetEntryObject outTime] isKindOfClass:[NSNull class]])
                    {
                        NSIndexPath *indexFromField = [NSIndexPath indexPathForRow:[self.firstSectionfieldsArr count]-3 inSection:TIME];
                        G2TimeEntryCellView *innerCell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:indexFromField];
                        NSString *timeStr=[G2Util getInTime:[timeSheetEntryObject outTime] noOfHrs:[timeSheetEntryObject numberOfHoursInDouble]];
                        [timeSheetEntryObject setInTime:timeStr];
                        G2EntryCellDetails *innerDetailsObj = (G2EntryCellDetails *)[innerCell detailsObj];
                        [innerDetailsObj setFieldValue:timeStr];
                        [self updateFieldValueForCell:innerCell withSelectedValue:timeStr];
                    }
                    else
                    {
                        //IF ONLY HOURS FIELD IS POPULATED
                        
                        NSIndexPath *timeOutIndexFromField = [NSIndexPath indexPathForRow:[self.firstSectionfieldsArr count]-2 inSection:TIME];
                        G2TimeEntryCellView *timeOutCell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:timeOutIndexFromField];
                        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                        [dateFormat setLocale:locale];
                        [dateFormat setDateFormat:@"h:mm a"];
                        NSString *outTimeToBeUsed = [dateFormat stringFromDate:[NSDate date]]; 
                        
                        [timeSheetEntryObject setOutTime:outTimeToBeUsed];
                        G2EntryCellDetails *timeOutDetailsObj = (G2EntryCellDetails *)[timeOutCell detailsObj];
                        [timeOutDetailsObj setFieldValue:outTimeToBeUsed];
                        [self updateFieldValueForCell:timeOutCell withSelectedValue:outTimeToBeUsed];
                        if([timeSheetEntryObject outTime]!=nil && ![[timeSheetEntryObject outTime] isKindOfClass:[NSNull class]])
                        {
                            NSIndexPath *timeInIndexFromField = [NSIndexPath indexPathForRow:[self.firstSectionfieldsArr count]-3 inSection:TIME];
                            G2TimeEntryCellView *timeinCell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:timeInIndexFromField];
                            NSString *timeStr=[G2Util getInTime:[timeSheetEntryObject outTime] noOfHrs:[timeSheetEntryObject numberOfHoursInDouble]];
                            [timeSheetEntryObject setInTime:timeStr];
                            G2EntryCellDetails *timeInDetailsObj = (G2EntryCellDetails *)[timeinCell detailsObj];
                            [timeInDetailsObj setFieldValue:timeStr];
                            [self updateFieldValueForCell:timeinCell withSelectedValue:timeStr];
                        }
                        
                        
                        
                        
                    }
                    
                }
            }
            
            
		}
		else if (indexPath.section == PROJECT_INFO) {
			//handle for Numeric UDFs. 
            
            
            int decimals = [detailsObj decimalPoints];
            NSString *tempValue =	[G2Util formatDecimalPlacesForNumericKeyBoard:[[cell.textField text] doubleValue] withDecimalPlaces:decimals];
            tempValue = [G2Util removeCommasFromNsnumberFormaters:tempValue];
            if (tempValue == nil) {
                tempValue = [cell.textField text];
                
            }else {
                [cell.textField setTextColor:NewRepliconStandardBlueColor];//US4065//Juhi
                [cell.textField setText: tempValue];
            }
            if (tempValue!=nil) {
                //do nothing here
            }
            [detailsObj setFieldValue:[cell.textField text]];
            
            [secondSectionfieldsArray replaceObjectAtIndex:indexPath.row withObject:detailsObj];
		}
	}
	if(indexPath!=nil)
        [self resetTableViewUsingSelectedIndex:nil];
    //	[self.mainScrollView setFrame:CGRectMake(0.0,0.0,self.view.frame.size.width,self.view.frame.size.height) ];
    //    
    //    CGRect rect=self.tnewTimeEntryTableView.frame;
    //    rect.origin.y=10.0;
    //self.tnewTimeEntryTableView.frame=rect;
    //    CGSize size=self.mainScrollView.contentSize;
    //    int extraHeightForLockedInOut=0;
    //    if(isLockedTimeSheet)
    //    {
    //       
    //        extraHeightForLockedInOut=EXTRA_SPACING_LOCKED_IN_OUT;
    //    }
    //
    //    size.height=self.view.frame.size.height+(countFrame*60.0)+extraHeightForLockedInOut;
    //    self.mainScrollView.contentSize=size;;
    
    //     int buttonSpaceHeight=0.0;
    //    if(isLockedTimeSheet)
    //    {
    //        self.mainScrollView.contentSize= CGSizeMake(self.view.frame.size.width, ([secondSectionfieldsArray  count]*44)+90.0+35.0+48.0+48.0+44.0+buttonSpaceHeight);
    //    }
    //    else 
    //    {
    //       
    //        if( [self screenMode] == EDIT_TIME_ENTRY )
    //        {
    //            buttonSpaceHeight=90.0;
    //        }
    //        self.mainScrollView.contentSize= CGSizeMake(self.view.frame.size.width, ([secondSectionfieldsArray  count]*48)+([firstSectionfieldsArr  count]*48)+35.0+48.0+48.0+48.0+buttonSpaceHeight  );
    //    }
    
}

#pragma mark Toolbar Handling Methods

- (void)nextClickAction:(id )button :(NSIndexPath *)currentIndexPath{
    //-----US5053 Ullas M L-----
    int timeRow=0;
    int timeSection=0;
    if (self.screenMode==ADD_ADHOC_TIMEOFF ||self.screenMode==ADD_TIME_ENTRY) 
    {
        if (isLockedTimeSheet)
        {
            timeRow=2;
        }
        else
        {
            if (isTimeOffEnabledForTimeEntry ) 
                timeRow=2;
            else 
                timeRow=1;

        }
        
            }
    else if (self.screenMode==EDIT_TIME_ENTRY ||self.screenMode==EDIT_ADHOC_TIMEOFF) 
    {
        timeRow=2;
    }
    
    
    
    
    if (currentIndexPath.row==timeRow && currentIndexPath.section==timeSection)
    {
       [self validateTimeEntryFieldValueInCell];
    }

    if (self.isTimeFieldValueBreak) {
        self.isTimeFieldValueBreak=NO;
        return;
    }
    //----------
	[self tableViewCellUntapped:currentIndexPath  animated:NO];
    //[self setValueForActivitiesonNavigation];
	[self handleUpdatesForToolbarActions :currentIndexPath];
	
	NSIndexPath *nextIndexPath = [self getNextEnabledIndexPath :currentIndexPath];
	
	if (nextIndexPath != nil) {
		[self handleButtonClicks:nextIndexPath :button];
	}
	
}

- (void)previousClickAction:(id )button :(NSIndexPath *)currentIndexPath {
	//-----US5053 Ullas M L-----
    
    int timeRow=0;
    int timeSection=0;
    if (self.screenMode==ADD_ADHOC_TIMEOFF ||self.screenMode==ADD_TIME_ENTRY) 
    {
        if (isLockedTimeSheet)
        {
            timeRow=2;
        }
        else
        {
            if (isTimeOffEnabledForTimeEntry) 
                timeRow=2;
            else 
                timeRow=1;
        }
        
    }
    else if (self.screenMode==EDIT_TIME_ENTRY ||self.screenMode==EDIT_ADHOC_TIMEOFF) 
    {
        timeRow=2;
    }
    
    
    
    if (currentIndexPath.row==timeRow && currentIndexPath.section==timeSection)
    {
        [self validateTimeEntryFieldValueInCell];
    }

    if (self.isTimeFieldValueBreak) {
        self.isTimeFieldValueBreak=NO;
        return;
    }
    //----------
	[self tableViewCellUntapped:currentIndexPath  animated:NO];
    //[self setValueForActivitiesonNavigation];
	[self handleUpdatesForToolbarActions :currentIndexPath];
	
	NSIndexPath *previousIndexPath = [self getPreviousEnabledIndexPath :currentIndexPath];
	
	if (previousIndexPath != nil) {
		[self handleButtonClicks:previousIndexPath :button];
	}
    
}

- (void)doneClickAction:(id)button :(NSIndexPath *)currentIndexPath {

    
	isFromDoneClicked=YES;
	[self tableViewCellUntapped:selectedIndexPath  animated:NO];
    //DE8514
   
    if (isInOutFlag)
        [self validateInTimeOutTime];
    
    if (!isFromSave) {
        [self setValueForActivitiesonNavigation];
    }
    else
    {
        isFromSave=FALSE;
    }
    [self resetTableViewUsingSelectedIndex:nil];//US4065//Juhi
    
    selectedIndexPath=nil;
    
    //    [self handleUpdatesForToolbarActions :currentIndexPath];
    
    
}
//DE8514
-(void)validateInTimeOutTime{
    NSIndexPath *timeOutIndexFromField = [NSIndexPath indexPathForRow:[self.firstSectionfieldsArr count]-2 inSection:TIME];
    G2TimeEntryCellView *timeOutCell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:timeOutIndexFromField];
    
    NSIndexPath *timeInIndexFromField = [NSIndexPath indexPathForRow:[self.firstSectionfieldsArr count]-3 inSection:TIME];
    G2TimeEntryCellView *timeinCell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:timeInIndexFromField];
    G2TimeEntryCellView *hrcell =(G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.firstSectionfieldsArr count]-1 inSection:TIME]];
    G2EntryCellDetails *hrDetailsObj=(G2EntryCellDetails *)[hrcell detailsObj];
    BOOL valuechange=FALSE;
    G2EntryCellDetails *hackdetailsObj =nil;
    G2EntryCellDetails *timeOutDetailsObj = (G2EntryCellDetails *)[timeOutCell detailsObj];
    G2EntryCellDetails *timeInDetailsObj = (G2EntryCellDetails *)[timeinCell detailsObj];
    hackdetailsObj=hrDetailsObj;
    if (timeSheetEntryObject!=nil)
    {
        
        if ([[hackdetailsObj fieldValue] isKindOfClass:[NSString class]])  {
            if (![[hackdetailsObj fieldValue] isEqualToString:[timeSheetEntryObject numberOfHours]]  &&[[hackdetailsObj fieldType] isEqualToString: NUMERIC_KEY_PAD]&& [[[hackdetailsObj fieldValue] componentsSeparatedByString:@":"] count]==1 )
            {
                [timeSheetEntryObject setNumberOfHours:[hrcell.textField text]];
                [timeSheetEntryObject setNumberOfHoursInDouble:[[hrcell.textField text] doubleValue]];
                [hrDetailsObj setFieldValue:[hrcell.textField text]];
                valuechange=TRUE;
            }
        }
        
    }
    if (valuechange) 
    {
        if ([timeSheetEntryObject inTime]!=nil && ![[timeSheetEntryObject inTime] isKindOfClass:[NSNull class]]) {
            NSString *timeStr=[G2Util getOutTime:[timeSheetEntryObject inTime] noOfHrs:[timeSheetEntryObject numberOfHoursInDouble]];
            [timeSheetEntryObject setOutTime:timeStr];
            [timeOutDetailsObj setFieldValue:timeStr];
            [self updateFieldValueForCell:timeOutCell withSelectedValue:timeStr];
        }
        else if ([timeSheetEntryObject outTime]!=nil && ![[timeSheetEntryObject outTime] isKindOfClass:[NSNull class]] ) 
        {
            NSString *timeStr=[G2Util getInTime:[timeSheetEntryObject outTime] noOfHrs:[timeSheetEntryObject numberOfHoursInDouble]];
            [timeSheetEntryObject setInTime:timeStr];
            [timeInDetailsObj setFieldValue:timeStr];
            [self updateFieldValueForCell:timeinCell withSelectedValue:timeStr];
            
        }
        else if (([timeSheetEntryObject inTime]==nil || [[timeSheetEntryObject inTime] isKindOfClass:[NSNull class]])&&([timeSheetEntryObject outTime]==nil || [[timeSheetEntryObject outTime] isKindOfClass:[NSNull class]]) ) 
        {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [dateFormat setLocale:locale];
            [dateFormat setDateFormat:@"h:mm a"];
            NSString *outTimeToBeUsed = [dateFormat stringFromDate:[NSDate date]]; 
            
            [timeSheetEntryObject setOutTime:outTimeToBeUsed];
            [timeOutDetailsObj setFieldValue:outTimeToBeUsed];
            [self updateFieldValueForCell:timeOutCell withSelectedValue:outTimeToBeUsed];
            NSString *timeStr=[G2Util getInTime:[timeSheetEntryObject outTime] noOfHrs:[timeSheetEntryObject numberOfHoursInDouble]];
            [timeSheetEntryObject setInTime:timeStr];
            [timeInDetailsObj setFieldValue:timeStr];
            [self updateFieldValueForCell:timeinCell withSelectedValue:timeStr];
            
        }
    }
    
}

-(void)setValueForActivitiesonNavigation
{
    
    //    PermissionsModel *permissionsModel = [[PermissionsModel alloc] init];
    //    BOOL isTimesheetActivityRequired = [permissionsModel checkUserPermissionWithPermissionName:@"TimesheetActivityRequired"];
    
    //    if (isTimesheetActivityRequired) {
    G2TimeEntryCellView *cell = (G2TimeEntryCellView *)[self.tnewTimeEntryTableView cellForRowAtIndexPath:selectedIndexPath];
    //if ([cell.fieldButton.titleLabel.text isEqualToString:ACTIVITIES_DEFAULT]) {
    //    DLog(@"%@",self.disabledBillingOptionsName);
    if ([cell.fieldButton.titleLabel.text isEqualToString:disabledActivityName] || [cell.fieldButton.titleLabel.text isEqualToString:RPLocalizedString(ACTIVITIES_DEFAULT_NONE, @"")] ||  [cell.fieldButton.titleLabel.text isEqualToString:self.disabledBillingOptionsName]  ||  [cell.fieldButton.titleLabel.text isEqualToString:RPLocalizedString(SelectString, @"") ] ||[cell.fieldButton.titleLabel.text isEqualToString:RPLocalizedString(NONE_STRING, @"")]|| [cell.fieldButton.titleLabel.text isEqualToString:self.disabledDropDownOptionsName] || [cell.fieldButton.titleLabel.text isEqualToString:self.disabledTimeOffTypeName]) {
        [self updatePickerSelectedValueAtIndexPath:selectedIndexPath :0 :0];
    }
    
    //    }
    
}

-(void)changeOfSegmentControlState:(NSIndexPath *)indexpath{
	//DLog(@"\nchangeOfSegmentControlState::AddeNewTimeEntryViewController");
	if (selectedIndexPath.row==0 && selectedIndexPath.section==PROJECT_INFO) {
        [self handleUpdatesForToolbarActions :selectedIndexPath];//DE2737 Ullas M L
    }
	if (indexpath.section == TIME) {
		
        if ( self.isTimeOffEnabledForTimeEntry && [self screenMode]==EDIT_TIME_ENTRY && indexpath.row==1 )
        {
            [self.customPickerView changeSegmentControlButtonsStatus:NO :YES];
        }
        
		else if (indexpath.row==0) {
			[self.customPickerView changeSegmentControlButtonsStatus:NO :YES];
		}else {
			[self.customPickerView changeSegmentControlButtonsStatus:YES :YES];
		}
	}	else if (indexpath.section==PROJECT_INFO) {
		if (indexpath.row == [secondSectionfieldsArray count]-1) {
			[self.customPickerView changeSegmentControlButtonsStatus:YES :YES];
		}else {
			if(isLockedTimeSheet)
            {
                if (indexpath.row==0) 
                {
                    [self.customPickerView changeSegmentControlButtonsStatus:NO :YES];
                }
                else
                {
                    [self.customPickerView changeSegmentControlButtonsStatus:YES :YES];
                }
                
            }
            else
            {
                [self.customPickerView changeSegmentControlButtonsStatus:YES :YES];
            }
		}
	}
	
}

-(void)handleUpdatesForToolbarActions :(NSIndexPath *)currentIndexPath {
    
	G2TimeEntryCellView *cell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:currentIndexPath];
	G2EntryCellDetails *detailsObj = (G2EntryCellDetails *)[cell detailsObj];
	NSString *fieldType = [detailsObj fieldType];
	//NSString *fieldName = [detailsObj fieldName];
	if (currentIndexPath.section == TIME) {
		
		if ([fieldType isEqualToString: NUMERIC_KEY_PAD]) {
            
            if (isInOutFlag) {
               
                    if (timeSheetEntryObject!=nil)
                    {
                         if ([[detailsObj fieldValue]  isKindOfClass:[NSString class]]) 
                         {
                             if (![[detailsObj fieldValue] isEqualToString:[timeSheetEntryObject numberOfHours]]) {
                                 [timeSheetEntryObject setNumberOfHours:[cell.textField text]];
                                 [timeSheetEntryObject setNumberOfHoursInDouble:[[cell.textField text] doubleValue]];
                             } 
                         }
                             
                        
                    }
                    else 
                    {
                       
                            [timeOffEntryObject setNumberOfHours:[cell.textField text]];
                            //[timeSheetEntryObject setNumberOfHoursInDouble:[[cell.textField text] doubleValue]];
                        
                    }
                
                
            }
            else
            {
                if (timeSheetEntryObject!=nil)
                {
                     [timeSheetEntryObject setNumberOfHours:[cell.textField text]];
                }
                else
                {
                     [timeOffEntryObject setNumberOfHours:[cell.textField text]];
                }
               
            }
            
			
			[cell.textField resignFirstResponder];
		}
	}
/*	else if (currentIndexPath.section == PROJECT_INFO) {
		//DE8142
		if (([fieldName isEqualToString:ClientProject] && currentIndexPath.row<udfsStartIndexNo ) && 
			([detailsObj fieldValue] == nil || [timeSheetEntryObject projectRemoved])) {
            
            NSMutableArray *dataSourceArray = [detailsObj dataSourceArray];
            if (dataSourceArray != nil && [dataSourceArray count] > 1) {
                
                NSMutableArray *selectedIndicesArray = [detailsObj componentSelectedIndexArray];
                NSMutableArray *projectsArr = [dataSourceArray objectAtIndex:1];
                NSString *selectedClient = [[clientsArray objectAtIndex:[[selectedIndicesArray objectAtIndex:0] intValue]]objectForKey:@"name"];
                int projSelectedIndex = [[selectedIndicesArray objectAtIndex:1] intValue];
                [timeSheetEntryObject setClientName:selectedClient];
                [timeSheetEntryObject setClientIdentity:[supportDataModel getClientIdentityForClientName:selectedClient]];
                //update the picker selected Row details
                int clientRow = [Util getIndex:clientsArray forObj:[timeSheetEntryObject clientName]];
                
                [[detailsObj componentSelectedIndexArray] removeAllObjects];
                [[detailsObj componentSelectedIndexArray] addObject:[NSNumber numberWithInt:clientRow]];
                [[detailsObj componentSelectedIndexArray] addObject:[NSNumber numberWithInt:projSelectedIndex]];
                
                [self handleProjectSelection:projectsArr indexPath:currentIndexPath row: projSelectedIndex];
            }
        }
		else if (fieldType == DATA_PICKER) {
		}
		else if ([fieldType isEqualToString: NUMERIC_KEY_PAD]) {
		}
	}*/
}

#pragma mark Project Related Methods

/*
-(void)handleProjectDetailsWhenProjectRemoved :(EntryCellDetails *)projectDetails {
	
	if (clientsArray != nil && [clientsArray count] > 0) {
		NSString *clientId = [supportDataModel getClientIdentityForClientName:[[clientsArray objectAtIndex:0]objectForKey:@"name"]];
		NSMutableArray *projects = [supportDataModel getProjectsForClientWithClientId:clientId];
		
		if (projects != nil) {
			[projectDetails setDataSourceArray:[NSMutableArray arrayWithObjects:projects,nil]];
			[projectDetails setComponentSelectedIndexArray:[NSMutableArray arrayWithObjects:
															[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],
															nil]];
			
			NSString *projectId = [supportDataModel getProjectIdentityWithProjectName:[[projects objectAtIndex:0]objectForKey:@"name"]];
			NSString *clientAllocationId = [supportDataModel getClientAllocationId:clientId projectIdentity:projectId];
			if (clientAllocationId != nil) {
				[timeSheetEntryObject setClientAllocationId:clientAllocationId];
			}
		}
	}
	else {
		[projectDetails setDataSourceArray:[NSMutableArray array]];
	}
}
 
 */

-(void)handleProjectSelection:(NSMutableArray *)projectsArr indexPath :(NSIndexPath *)otherPickerIndexPath row:(int) _row {
	
	
	NSString *selectedProjectName = [[projectsArr objectAtIndex:_row]objectForKey:@"name"];
	NSString *projectId = selectedProjectName == RPLocalizedString(NONE_STRING, NONE_STRING) ? @"null" : nil;
	//fetch projectId for projectName;
	if ([selectedProjectName isEqualToString:RPLocalizedString(NONE_STRING, NONE_STRING)]) {
		[timeSheetEntryObject setProjectName: RPLocalizedString(NONE_STRING, NONE_STRING)];
		[timeSheetEntryObject setProjectIdentity: nil];
	}
	if (![selectedProjectName isEqualToString:RPLocalizedString(NONE_STRING, NONE_STRING)]) {
		projectId = [supportDataModel getProjectIdentityWithProjectName:selectedProjectName];
		[timeSheetEntryObject setProjectName:selectedProjectName];
		[timeSheetEntryObject setProjectIdentity:projectId];
	}			
	NSString *clientName = [timeSheetEntryObject clientName];
	NSString *clientIdentity = [timeSheetEntryObject clientIdentity];
	//NSString *selectedname = nil;
	
	if (clientName == nil && selectedProjectName != nil) {
		clientName = [[clientsArray objectAtIndex:0]objectForKey:@"name"];
		clientIdentity = [supportDataModel getClientIdentityForClientName:clientName];
		[timeSheetEntryObject setClientName:clientName];
		[timeSheetEntryObject setClientIdentity:clientIdentity];
	}
	
	NSString *clientAllocationId = [supportDataModel getClientAllocationId:clientIdentity projectIdentity:projectId];
	if (clientAllocationId != nil) {
		[timeSheetEntryObject setClientAllocationId:clientAllocationId];
	}
	
	
	[timeSheetEntryObject setProjectRemoved:NO];
	[self updateFieldAtIndex:otherPickerIndexPath WithSelectedValues:selectedProjectName];
	
	[self resetTaskSelection];
}

#pragma mark Billing Related Methods


-(void)updateBillingFieldForSelectedProjectTask {
	
	if ([permissionsObj billingTimesheet] && [preferencesObj useBillingInfo]) {
		
		[self getBillingOptionsDataSourceArray:FALSE];
		NSMutableArray *dataSourceArray = [NSMutableArray arrayWithObject:billingArray];
		
		NSIndexPath *index = [NSIndexPath indexPathForRow:3 inSection:PROJECT_INFO];
		G2TimeEntryCellView  *cell = (G2TimeEntryCellView *)[self.tnewTimeEntryTableView cellForRowAtIndexPath:index];
		G2EntryCellDetails *detailsObj = (G2EntryCellDetails *)[cell detailsObj];
		
		NSString *billingName = [detailsObj fieldValue];
		int selectedBillingRow = 0;
		if (billingName != nil && [billingArray containsObject:billingName]) {
			
			selectedBillingRow =  [self getSelectedBillingRowIndex];
		}
		else {
			billingName = [billingArray objectAtIndex:0];
			[timeSheetEntryObject setBillingName:[self getSelectedBillingName:billingName]];
		}
        
		[detailsObj setFieldValue:billingName];
		[detailsObj setDataSourceArray:dataSourceArray];
		
		[cell.fieldButton setTitle:billingName forState:UIControlStateNormal];
        
		
		
		NSString *billingIdentity = [self getBillingIdentityFromSelectedBillingName:billingName]; 	
		[timeSheetEntryObject setBillingIdentity:billingIdentity];
		
		NSNumber *projectRoleId = [self getBillingRoleIdentity:billingIdentity];
		if (projectRoleId != nil && ![projectRoleId isKindOfClass:[NSNull class]]) {
			[timeSheetEntryObject setProjectRoleId:projectRoleId];
		}
		else {
			[timeSheetEntryObject setProjectRoleId:nil];
		}
		
		[[detailsObj componentSelectedIndexArray] removeAllObjects];
		[[detailsObj componentSelectedIndexArray] addObject:[NSNumber numberWithInt:selectedBillingRow]];
	}
}

-(NSMutableArray *)getBillingOptionsDataSourceArray:(BOOL)isDownloadDataFromAPI {
	
	billingArray = [NSMutableArray array];
	
	NSString *selectedProject = [timeSheetEntryObject projectName];
	if (selectedProject == nil || (selectedProject != nil && [selectedProject isEqualToString: RPLocalizedString(NONE_STRING, NONE_STRING)])) {
		//DLog(@"project name not nil");
		[billingArray addObject:@"Non Billable"];
		[timeSheetEntryObject setBillingName:@"Non Billable"];
		[timeSheetEntryObject setBillingIdentity:@"NonBillable"];
	}
	else {
		//handle Tasks selection.
		//NSString *taskIdentity = [timeSheetEntryObject taskIdentity];
		NSString *taskIdentity = [timeSheetEntryObject.taskObj taskIdentity];
		if (taskIdentity != nil && ![taskIdentity isKindOfClass:[NSNull class]]) {
			//DLog(@"task Identity  %@",taskIdentity);
			//get Billing option for selected task.
			NSString *taskBilling = [supportDataModel getTaskBillableStatus:taskIdentity];
			//DLog(@"taskBilling status  %@",taskBilling);
			billingArray = [self getBillingArrayForBillingStatus: taskBilling :[timeSheetEntryObject projectIdentity]];
			if ([billingArray count] == 0) {
				[billingArray addObject:@"Non Billable"];
			}
            
            if (isDownloadDataFromAPI)
            {
                if ([billingArray count] == 1)
                {
                    if([[billingArray objectAtIndex:0]isEqualToString:@"Non Billable"])
                    {
                        return nil;
                    }
                }
            }
            
			//[billingArray retain];
			
		}
		else if (selectedProject != nil && ![selectedProject isEqualToString: RPLocalizedString(NONE_STRING, NONE_STRING)]) {
			NSString *projectBillingStatus = [supportDataModel getProjectBillableStatus:
											  [timeSheetEntryObject projectIdentity]];
			
			billingArray = [self getBillingArrayForBillingStatus: projectBillingStatus :[timeSheetEntryObject projectIdentity]];
			if ([billingArray count] == 0) {
				[billingArray addObject:@"Non Billable"];
			}
            if (isDownloadDataFromAPI)
            {
                if ([billingArray count] == 1)
                {
                    if([[billingArray objectAtIndex:0]isEqualToString:@"Non Billable"])
                    {
                        return nil;
                    }
                    
                }
            }
            
            
			//[billingArray retain];
		}
		else {
			//DLog(@"taskIdentity is nil");
			[billingArray addObject:@"Non Billable"];
			[timeSheetEntryObject setBillingName:@"Non Billable"];
			[timeSheetEntryObject setBillingIdentity:@"NonBillable"];
		}
		
	}
	
	//}
	
	return billingArray;
}


-(NSMutableArray *)getBillingArrayForBillingStatus :(NSString *)billingStatus :(NSString *)projectIdentity {
	
	NSMutableArray *billingOptionsArray = [NSMutableArray array];
	
	if (billingStatus != nil && ![billingStatus isKindOfClass:[NSNull class]]) {
		if ([billingStatus isEqualToString:TASK_NON_BILLABLE]) {
			[billingOptionsArray addObject:@"Non Billable"];
			return billingOptionsArray;
		}
		else if ([billingStatus isEqualToString:TASK_BILLABLE_BOTH]) {
			[billingOptionsArray addObject:@"Non Billable"];
		}
		//DLog(@"billingArray options1 %@",billingArray);
		//get Project Billing Rates for user and add to billingArray.
		NSMutableArray *billingRatesArray = [supportDataModel getBillingRatesForProject:projectIdentity];
		if (billingRatesArray != nil && [billingRatesArray count] > 0) {
			for (NSDictionary *billingRate in billingRatesArray) {
				NSString *billingRateName = [billingRate objectForKey:@"projectRoleName"];
				if (billingRateName != nil && ![billingRateName isEqualToString:BILLING_NONBILLABLE]) {
					[billingOptionsArray addObject:[NSString stringWithFormat:@"Billable (%@)",billingRateName]];
				}/*else {
				  [billingArray addObject:@"Non Billable"];
				  }*///DE2155
			}
		}
	}else {
		[billingOptionsArray addObject:@"Non Billable"];
	}
	
	return billingOptionsArray;
}

-(NSString *)getBillingIdentityFromSelectedBillingName:(NSString *)selectedValue {
	//DLog(@"selected billing %@",selectedValue);
	NSString *billingIdentity = nil;
	if ([selectedValue isEqualToString:@"Non Billable"]) {
		//DLog(@"billing is nonbillable");
		billingIdentity = @"NonBillable";
		return billingIdentity;
	}
	else {
		NSArray *components = [selectedValue componentsSeparatedByString:@"("];
		//	DLog(@"split components %@",components);
		NSString *selectedValue = @"";
		if ([components count] > 1) {
			//NSArray *rolecomponentArray = [[components objectAtIndex:1] componentsSeparatedByString:@")"];//DE3475
			//selectedValue = [rolecomponentArray objectAtIndex:0];//DE3475
            for (int i=1; i < [components count]; i++) {//DE3475
                if(i > 1){
                    selectedValue = [selectedValue stringByAppendingFormat:@"%@", @"("];
                    selectedValue =  [selectedValue stringByAppendingString:[components objectAtIndex:i]];
                }else{
                    selectedValue =  [selectedValue stringByAppendingString:[components objectAtIndex:i]];
                }
            }
            if (![selectedValue isKindOfClass:[NSNull class] ])
            {
                selectedValue = [selectedValue substringToIndex:[selectedValue length] - 1];
            }
            
            
		}
		else {
			selectedValue = [components objectAtIndex:0];
		}
		billingIdentity = [G2SupportDataModel getBillingTypeByProjRoleName: selectedValue];
		
		return billingIdentity;
	}
	
}

-(NSNumber *)getBillingRoleIdentity:(NSString *)billingIdentity {
	//	DLog(@"getBillingRoleIdentity :%@",billingIdentity);
	NSString *projectIdentity = [timeSheetEntryObject projectIdentity];
	NSString *billingName = [timeSheetEntryObject billingName];
	if (billingIdentity != nil &&  ![billingIdentity isKindOfClass:[NSNull class]]
		&& projectIdentity != nil && ![projectIdentity isKindOfClass:[NSNull class]]) {
		
		//	DLog(@"billing identity not null & project not nil");
		if (![billingIdentity isEqualToString:BILLING_BILLABLE] &&
			![billingIdentity isEqualToString:BILLING_NONBILLABLE] &&
			![billingIdentity isEqualToString:BILLING_PROJECT_RATE] &&
			![billingIdentity isEqualToString:BILLING_USER_RATE] &&
			![billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]) {
			//	DLog(@"billing idenity is rolerate");
			NSNumber *projectRoleId = [supportDataModel getProjectRoleIdForBilling:billingName : projectIdentity];
			//	DLog(@"projectRoleId %@",projectRoleId);
			if (projectRoleId != nil && ![projectRoleId isKindOfClass:[NSNull class]] ) {
				return projectRoleId;
			}
		}
		else if ([billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]) {
			//	DLog(@"biling is department");
			NSNumber *projectDeptId = [supportDataModel getDepartmentIdForBilling: billingName  : projectIdentity];
			//	DLog(@"projectdept id", projectDeptId);
			if (projectDeptId != nil && ![projectDeptId isKindOfClass:[NSNull class]] ) {
				return projectDeptId;
			}
		}
	}
	return nil;
}

-(NSString *)getSelectedBillingName:(NSString *)_selectedBillingName{
	if ([_selectedBillingName isEqualToString:@"Non Billable"]) {
		return _selectedBillingName;
	}else {
		NSArray *components = [_selectedBillingName componentsSeparatedByString:@"("];
		NSString *billingName = @"";
		if ([components count] > 1) {
			//NSArray *componentArray = [[components objectAtIndex:1] componentsSeparatedByString:@")"];//DE3475
			//billingName = [componentArray objectAtIndex:0];//DE3475
            for (int i=1; i < [components count]; i++) {//DE3475
                if(i > 1){
                    billingName = [billingName stringByAppendingFormat:@"%@", @"("];
                    billingName =  [billingName stringByAppendingString:[components objectAtIndex:i]];
                }else{
                    billingName =  [billingName stringByAppendingString:[components objectAtIndex:i]];
                }
            }
            if (![billingName isKindOfClass:[NSNull class] ])
            {
                billingName = [billingName substringToIndex:[billingName length] - 1];
            }
            
            
		}
		else {
			billingName = [components objectAtIndex:0];
		}
		return billingName;
	}
	
}

-(int)getSelectedBillingRowIndex {
	int selectedIndex = 0;
	NSString *selectedbilling  = [timeSheetEntryObject billingName];
    NSString *billingName = @"";
	for (int i=0; i<[billingArray count]; ++i) {//DE3475
        if ([[billingArray objectAtIndex: i] isEqualToString:@"Non Billable"]) {
            billingName =  @"Non Billable";
        }else {
            NSArray *components = [[billingArray objectAtIndex: i] componentsSeparatedByString:@"("];
            if ([components count] > 1) {
                for (int i=1; i < [components count]; i++) {
                    if(i > 1){
                        billingName = [billingName stringByAppendingFormat:@"%@", @"("];
                        billingName =  [billingName stringByAppendingString:[components objectAtIndex:i]];
                    }else{
                        billingName =  [billingName stringByAppendingString:[components objectAtIndex:i]];
                    }
                }
                if (![billingName isKindOfClass:[NSNull class] ])
                {
                    billingName = [billingName substringToIndex:[billingName length] - 1];
                }
                
            }
            else {
                billingName = [components objectAtIndex:0];
            }
        }
        if([billingName isEqualToString: selectedbilling]){
            selectedIndex = i;
			break;
        }
        billingName = @"";
		/*NSRange range = [[billingArray objectAtIndex: i] rangeOfString: selectedbilling];//DE3475
         if(range.length > 0){
         //DLog(@"Range Length %d",range.length);
         selectedIndex = i;
         break;
         }*/
	}
	
	return selectedIndex;
}	

-(int)getSelectedActivityRowIndex {
	int selectedIndex = 0;
	NSString *selectedActivityname  = [timeSheetEntryObject activityName];
    if (selectedActivityname!=nil && ![selectedActivityname isKindOfClass:[NSNull class]]) {
        for (int i=0; i<[activitiesArray count]; ++i) {
            NSRange range = [[[activitiesArray objectAtIndex:i] objectForKey:@"name"] rangeOfString: selectedActivityname];
            if(range.length > 0){
                //DLog(@"Range Length %d",range.length);
                selectedIndex = i;
                break;
            }
        }
    }
	
    if (selectedIndex==0 && selectedActivityname!=nil && ![selectedActivityname isKindOfClass:[NSNull class]] &&  [timeSheetEntryObject activityIdentity]!=nil) {
        selectedIndex=-1;
    }
	
	return selectedIndex;
}	

-(int)getSelectedTimeOffTypeRowIndex {
	int selectedIndex =-1;
	NSString *selectedtimeoffTypeName  = [timeOffEntryObject timeOffCodeType];
    if (selectedtimeoffTypeName!=nil && ![selectedtimeoffTypeName isKindOfClass:[NSNull class]]) {
        for (int i=0; i<[self.timeTypesArray count]; ++i) {
            NSRange range = [[[self.timeTypesArray objectAtIndex:i] objectForKey:@"name"] rangeOfString: selectedtimeoffTypeName];
            if(range.length > 0){
                //DLog(@"Range Length %d",range.length);
                selectedIndex = i;
                break;
            }
        }
    }
	
    
	
	return selectedIndex;
}	

-(int)getSelectedUDFDropDownRowIndex:(NSString *)selectedUDFText andUdfOptionArr:(NSMutableArray *)udfOptionsArray {
	int selectedIndex = -1;
    if (selectedUDFText!=nil && ![selectedUDFText isKindOfClass:[NSNull class]]) {
        for (int i=0; i<[udfOptionsArray count]; ++i) {
            NSRange range = [[[udfOptionsArray objectAtIndex:i] objectForKey:@"value"] rangeOfString: selectedUDFText];
            if(range.length > 0){
                //DLog(@"Range Length %d",range.length);
                selectedIndex = i;
                break;
            }
            range=[[[udfOptionsArray objectAtIndex:i] objectForKey:@"name"] rangeOfString: selectedUDFText];
            if(range.length > 0){
                //DLog(@"Range Length %d",range.length);
                selectedIndex = i;
                break;
            }
        }
    }
    
	
	return selectedIndex;
}	

#pragma mark Task related Methods

-(void)setTaskDetails:(G2EntryCellDetails *)taskDetails {
	
	NSString *taskName = [timeSheetEntryObject.taskObj taskName];
	if(taskName != nil) {
		[taskDetails setFieldValue:taskName];
	}
	else {
		NSString *clientName = [timeSheetEntryObject clientName];
		NSString *clientIdentity = [timeSheetEntryObject clientIdentity];
		NSString *projectName = [timeSheetEntryObject projectName];
		NSString *projectId = [timeSheetEntryObject projectIdentity];
		
		if (projectId != nil && projectName != nil) {
			
			clientIdentity = clientName == nil?NO_CLIENT_ID : clientIdentity;
			BOOL hasTasks = [supportDataModel checkProjectHasTasksForSelection:projectId client:clientIdentity];
			if (hasTasks) {
				[taskDetails setFieldValue:RPLocalizedString(SelectString, @"")];
			}
		}
	}
    
}

-(void)resetTaskSelection {
	
	//reset Task Values
	NSString *clientName = [timeSheetEntryObject clientName];
	NSString *clientIdentity = [timeSheetEntryObject clientIdentity];
	NSString *projectName = [timeSheetEntryObject projectName];
	NSString *projectId = [timeSheetEntryObject projectIdentity];
	
	clientIdentity = clientName == RPLocalizedString(NONE_STRING, @"") ?@"null" : clientIdentity;
	projectId = projectName == RPLocalizedString(NONE_STRING, @"")?@"null":projectId;
	if (![supportDataModel checkProjectHasTasksForSelection:projectId client:clientIdentity]) {
		[self disableTaskSelection];
	}
	else {
		[self enableTaskSelection];
	}
	[timeSheetEntryObject.taskObj setTaskName:nil];
	[timeSheetEntryObject.taskObj setTaskIdentity:nil];
	[timeSheetEntryObject.taskObj setParentTaskId:nil];
	
	[self updateBillingFieldForSelectedProjectTask];
}

-(void)fetchTasksForSelectedProject {
	
	NSString *projectIdentity = [timeSheetEntryObject projectIdentity];
	NSString *projectName = [timeSheetEntryObject projectName];
	if (projectIdentity != nil && ![projectIdentity isKindOfClass:[NSNull class]]
		&& ![projectName isEqualToString:RPLocalizedString(NONE_STRING, @"")]) {
		
		if ([[NetworkMonitor sharedInstance]networkAvailable]) {
			[[G2RepliconServiceManager timesheetService] sendRequestToFetchTasksForProject:timeSheetEntryObject];
            //[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:LoadingMessage];
            if (![self.progressIndicator isAnimating]) {
                [self.progressIndicator startAnimating];
            }
            [self.view setUserInteractionEnabled:FALSE];
			[[NSNotificationCenter defaultCenter] 
			 addObserver:self selector:@selector(showTasksForProject) name:TASKS_RECEIVED_NOTIFICATION object:nil];
		}
		else {
#ifdef PHASE1_US2152
            [G2Util showOfflineAlert];
            return;
#endif
			
			//[self showTasksForProject];
		}
		
		
	}
}

-(void)showTasksForProject {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:TASKS_RECEIVED_NOTIFICATION object:nil];
	
	NSMutableArray *tasksForProjects = [supportDataModel getTasksForProjectWithParentTask:
										[timeSheetEntryObject projectIdentity]: nil];
	
	if (tasksForProjects == nil) {
		//NSString *status = @"Alert";//Fix for DE1231//Juhi
		NSString *value = RPLocalizedString(NO_TASKS_MESSAGE,@"");
        //		[Util errorAlert:status errorMessage:value];
        [G2Util errorAlert:@"" errorMessage:value];//Fix for DE1231//Juhi
		[self tableViewCellUntapped:selectedIndexPath animated:YES];
	}
	else if (tasksForProjects != nil && [tasksForProjects count] > 0) {
		
        
		G2TaskViewController *temptaskViewController=[[G2TaskViewController alloc]init];
        self.taskViewController=temptaskViewController;
        
		
		[self.taskViewController setTaskArr:tasksForProjects];
		[self.taskViewController.taskTable reloadData];
		[self.taskViewController setSubTaskMode:NO];
		[self.taskViewController setProjectIdentity:[timeSheetEntryObject projectIdentity]];
		[self.taskViewController setClientProjectTaskDelegate:self];
		
		NSString *taskId = [timeSheetEntryObject.taskObj taskIdentity];
		
		[self.taskViewController setSelectedTaskEntityId:taskId];
        //         self.taskViewController=temptaskViewController;
		[self.navigationController pushViewController:self.taskViewController animated:YES];
		
        //        temptaskViewController=nil;
	}
	//[[[UIApplication sharedApplication]delegate] performSelector:@selector(stopProgression)];
    if ([self.progressIndicator isAnimating]) {
        [self.progressIndicator stopAnimating];
    }
    [self.view setUserInteractionEnabled:TRUE];
}

/*
 *This method updates the task selected from taskviewControllers to entryobject and table row.
 */
//-(void)updateSelectedTask : (NSString *)taskName : (NSString *)taskIdentity {
-(void)updateSelectedTask : (NSString *)taskName : (NSMutableDictionary *)taskDict {
	
	//DLog(@"updateSelectedTask :: %@ :: %@",taskName, taskDict);
	if (taskName != nil && taskDict != nil && ![taskName isKindOfClass:[NSNull class]] &&
		![taskDict isKindOfClass:[NSNull class]]) {
		
		NSString *taskIdentity = [taskDict objectForKey:@"identity"];
		NSString *parentIdentity = [taskDict objectForKey:@"parentTaskIdentity"];
        
		[timeSheetEntryObject.taskObj setTaskName:taskName];
		[timeSheetEntryObject.taskObj setTaskIdentity:taskIdentity];
		[timeSheetEntryObject.taskObj setParentTaskId:parentIdentity];
        
        
        
        
        NSString *projectBillingStatus = [supportDataModel getProjectTaskBillableStatus:
                                          taskIdentity];
        timeSheetEntryObject.projectBillableStatus=projectBillingStatus;
        
        NSString *billingIdentity = [G2SupportDataModel getBillingTypeByProjRoleName:timeSheetEntryObject.billingName];
        
        
        
        if (billingIdentity==nil) {
            billingIdentity=BILLING_NONBILLABLE;
        }
        
        
        [timeSheetEntryObject setBillingIdentity:billingIdentity];
        
		[self updateFieldAtIndex:selectedIndexPath WithSelectedValues:taskName];
		
		[self updateBillingFieldForSelectedProjectTask];
	}
}

-(void)enableTaskSelection {
	
	NSIndexPath *taskIndexPath  = [NSIndexPath indexPathForRow:2 inSection:PROJECT_INFO];
	
	G2TimeEntryCellView *entryCell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:taskIndexPath];
	G2EntryCellDetails *detailsObj = (G2EntryCellDetails *)[entryCell detailsObj];
	NSString *fieldName = [detailsObj fieldName];
	if ([fieldName isEqualToString:Task]) {
		
		[entryCell.fieldButton setTitle:RPLocalizedString(SelectString, @"") forState:UIControlStateNormal];
		[entryCell setUserInteractionEnabled:YES];
		[entryCell.fieldButton setEnabled:YES];
		[entryCell.fieldName setTextColor:RepliconStandardBlackColor];
		[entryCell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//US4065//Juhi
	}
}

-(void)disableTaskSelection {
	
	NSIndexPath *taskIndexPath = [NSIndexPath indexPathForRow:2 inSection:PROJECT_INFO];
	
	G2TimeEntryCellView *entryCell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:taskIndexPath];
	G2EntryCellDetails *detailsObj = (G2EntryCellDetails *)[entryCell detailsObj];
	NSString *fieldName = [detailsObj fieldName];
	if ([fieldName isEqualToString:Task]) {
		
		[entryCell.fieldButton setTitle:RPLocalizedString(NoTaskString, NoTaskString) forState:UIControlStateNormal];
		[entryCell setUserInteractionEnabled:NO];
		[entryCell.fieldButton setEnabled:NO];
		[entryCell.fieldName setTextColor:RepliconStandardGrayColor];
		[entryCell.fieldButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
		
		[timeSheetEntryObject.taskObj setTaskName:nil];
		[timeSheetEntryObject.taskObj setTaskIdentity:nil];
		[timeSheetEntryObject.taskObj setParentTaskId:nil];
	}
}



#pragma mark Save Entry Methods

-(void)cancelAction:(id)sender{
	self.isFromCancel=YES;
	[self tableViewCellUntapped:selectedIndexPath  animated:NO];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	if ([sender tag] == EDIT_TIME_ENTRY || [sender tag] == EDIT_ADHOC_TIMEOFF) {
        if ([customParentDelegate respondsToSelector:@selector(viewWillAppearFromApprovalsTimeEntry)])
        {
            [(G2ApprovalsUsersListOfTimeEntriesViewController *)customParentDelegate viewWillAppearFromApprovalsTimeEntry];
        }
		[self.navigationController popViewControllerAnimated:YES];
	}else {
		if (isEntriesAvailable) 
			[self dismissViewControllerAnimated:YES completion:nil];
		else {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_DIRECT_ENTRY_SAVED" object:nil];
		}
		//[self dismissViewControllerAnimated:YES completion:nil];
	}
}
-(void)saveAction:(id)sender{
    
    BOOL againstProjects = [permissionsObj projectTimesheet];
	BOOL bothPermission = [permissionsObj bothAgainstAndNotAgainstProject];
    if (againstProjects || bothPermission)
    {
        
        
        NSString *clientIdentity=[timeSheetEntryObject clientIdentity];
        NSString *projectIdentity=[timeSheetEntryObject projectIdentity];
        
        if (clientIdentity!=nil && ![clientIdentity isKindOfClass:[NSNull class]] && ![clientIdentity isEqualToString:@"null"] && ![clientIdentity isEqualToString:NULL_STRING])
        {
            if (projectIdentity==nil && [projectIdentity isKindOfClass:[NSNull class]] && [projectIdentity isEqualToString:NO_CLIENT_ID] && [projectIdentity isEqualToString:NULL_STRING] )
            {
                
                [G2Util errorAlert:@"" errorMessage:RPLocalizedString(CLIENT_VALIDATION_NO_PROJECT_SELECTED, CLIENT_VALIDATION_NO_PROJECT_SELECTED)];
                return;
            }
            else if ([projectIdentity isEqualToString:NO_CLIENT_ID] )
            {
                
                [G2Util errorAlert:@"" errorMessage:RPLocalizedString(CLIENT_VALIDATION_NO_PROJECT_SELECTED, CLIENT_VALIDATION_NO_PROJECT_SELECTED)];
                return;
            }
        }
        
    }
    
    
    isFromSave=TRUE;
    //-----US5053 Ullas M L-----
    int timeRow=0;
    int timeSection=0;
    if (self.screenMode==ADD_ADHOC_TIMEOFF ||self.screenMode==ADD_TIME_ENTRY) 
    {
        if (isLockedTimeSheet)
        {
            timeRow=2;
        }
        else
        {
            if (isTimeOffEnabledForTimeEntry) 
                timeRow=2;
            else 
                timeRow=1;
        }
        
    }
    else if (self.screenMode==EDIT_TIME_ENTRY ||self.screenMode==EDIT_ADHOC_TIMEOFF) 
    {
        timeRow=2;
    }
    
    if (selectedIndexPath.row==timeRow && selectedIndexPath.section==timeSection)
    {
        [self validateTimeEntryFieldValueInCell];
    }
    
    if (self.isTimeFieldValueBreak) {
        self.isTimeFieldValueBreak=NO;
        return;
    }
    //----------
	if (customPickerView != nil) {
		[self.customPickerView doneClickAction:sender];
	}
	
	[self tableViewCellUntapped:selectedIndexPath  animated:NO];
	if (![NetworkMonitor isNetworkAvailableForListener:self]) {
#ifdef PHASE1_US2152
		[G2Util showOfflineAlert];
		return;
#endif
	}
    [self buildUDFDictionary];
    
    //FOR TIME ENTRY
    if (timeSheetEntryObject!=nil)
    {
        if ([sender tag] == EDIT_TIME_ENTRY) {
            //DLog(@"Editing ::AddNewTimeEntryViewController");
            if ([Reachability isNetworkAvailable]== YES) {
                NSString *billingIdentity = [self getBillingIdentityFromSelectedBillingName:[timeSheetEntryObject billingIdentity]];
                if (billingIdentity != nil && (
                                               [billingIdentity isEqualToString:BILLING_ROLE_RATE] ||
                                               [billingIdentity isEqualToString:BILLING_DEPARTMENT_RATE]) && 
                    [timeSheetEntryObject projectRoleId] == nil) {
                    [timeSheetEntryObject setBillingIdentity:billingIdentity];
                    NSNumber *projectRoleId = [self getBillingRoleIdentity:billingIdentity];
                    if (projectRoleId != nil && ![projectRoleId isKindOfClass:[NSNull class]]) {
                        [timeSheetEntryObject setProjectRoleId:projectRoleId];
                    }
                    else {
                        [timeSheetEntryObject setProjectRoleId:nil];
                    }
                }
                
                [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(SavingMessage, "")];
                [self sendOnlineRequestToEditTimeEntry];
            }else {
                NSString *offlineStatus = @"edit";
                if (timeSheetEntryObject != nil && ![timeSheetEntryObject isKindOfClass:[NSNull class]]) {
                    [timesheetModel updateEditedTimeEntry:timeSheetEntryObject andStatus:offlineStatus];
                    [timesheetModel updateSheetModifyStatus:[timeSheetEntryObject sheetId] status:YES];
                    [self popToTimeEntriesContentsPage];
                }
            }
        }
        else {
            //check if TimeEntryobject details and save the details from object.
            if (timeSheetEntryObject != nil && ![timeSheetEntryObject isKindOfClass:[NSNull class]]) {
                //DLog(@"TimesheetEntry obj not nil");
                //Two types of Save is possible. One without sheetId and from an existing sheet
                NSString *sheetIdentity = [timeSheetEntryObject sheetId];
                if (sheetIdentity != nil && ![sheetIdentity isKindOfClass:[NSNull class]]
                    &&(sheetStatus != nil && [sheetStatus isEqualToString: NOT_SUBMITTED_STATUS])) {
                    //DLog(@"sheetId not nil");
                    //DLog(@"sheet Status %@",sheetStatus);
                    [self handleAddTimeEntryWithSheetIdentity];
                }
                else {
                    //DLog(@"sheetID is nil fetch new sheet");
                    [self handleAddTimeEntryWithoutSheetIdentity];
                }
                
            }
        }

    }
    
    //FOR AD HOC TIME OFF
    else
    {
        if ([timeOffEntryObject timeOffCodeType]==nil && ![[timeOffEntryObject timeOffCodeType] isKindOfClass:[NSNull class]]) 
        {
            [G2Util errorAlert:nil errorMessage:VALIDATION_TIMEOFF_TYPE_REQUIRED];
            return;
        }
        
        if ([sender tag] == EDIT_ADHOC_TIMEOFF) {
            //DLog(@"Editing ::AddNewTimeEntryViewController");
            if ([Reachability isNetworkAvailable]== YES) {
                
                [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(SavingMessage, "")];
                [self sendOnlineRequestToEditTimeOffEntry];
            }else {
                NSString *offlineStatus = @"edit";
                if (timeOffEntryObject != nil && ![timeOffEntryObject isKindOfClass:[NSNull class]]) {
                    [timesheetModel updateEditedTimeOffEntry:timeOffEntryObject andStatus:offlineStatus];
                    [timesheetModel updateSheetModifyStatus:[timeOffEntryObject sheetId] status:YES];
                    [self popToTimeEntriesContentsPage];
                }
            }
        }
        else {
            
            if (timeOffEntryObject != nil && ![timeOffEntryObject isKindOfClass:[NSNull class]]) {
                
                //Two types of Save is possible. One without sheetId and from an existing sheet
                NSString *sheetIdentity = [timeOffEntryObject sheetId];
                DLog(@"%@",sheetIdentity);
                if (sheetIdentity != nil && ![sheetIdentity isKindOfClass:[NSNull class]]
                    &&(sheetStatus != nil && [sheetStatus isEqualToString: NOT_SUBMITTED_STATUS])) {
                    //DLog(@"sheetId not nil");
                    //DLog(@"sheet Status %@",sheetStatus);
                    [self handleAddTimeOffEntryWithSheetIdentity];
                }
                else {
                    //DLog(@"sheetID is nil fetch new sheet");
                    [self handleAddTimeOffEntryWithoutSheetIdentity];
                }
                
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TIMESHEETS_USERBILLINGOPTIONS_FINSIHED_DOWNLOADING_EDITING object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userBillingOptionsFinishedDownloadingForEditing)
                                                 name:TIMESHEETS_USERBILLINGOPTIONS_FINSIHED_DOWNLOADING_EDITING object:nil];
    [[G2RepliconServiceManager timesheetService]sendRequestToGetAllBillingOptionsByClientID:[timeSheetEntryObject clientIdentity]];

}

-(void)buildUDFDictionary
{
    
    NSUInteger loopCount=[self.secondSectionfieldsArray count]- countUDF;
    
    for (NSUInteger i=loopCount; i<[self.secondSectionfieldsArray count]; i++) {
        G2EntryCellDetails *cellDetails=[self.secondSectionfieldsArray objectAtIndex:i];
        if ([cellDetails udfModule]!=nil || ![[cellDetails udfModule] isKindOfClass:[NSNull class] ]) 
        {
            if ([[cellDetails udfModule] isEqualToString:TaskTimesheet_RowLevel]) {
                NSDictionary *udfDateDict=nil;
                if ([[cellDetails fieldValue] isKindOfClass:[NSDate class]]) {
                    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                    unsigned reqFields = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond;
                    NSDateComponents *comps=[calendar components:reqFields fromDate:[cellDetails fieldValue]];
                    udfDateDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInteger:[comps year]],@"Year",
                                   [NSNumber numberWithInteger:[comps month]],@"Month",
                                   [NSNumber numberWithInteger:[comps day]],@"Day",
                                   @"Date", @"__type",
                                   nil];
                    
                    [self validateUDFDateFormat:udfDateDict andCell:cellDetails andUDFType:@"RowUDF"];
                }
                
                else  if(([cellDetails fieldValue]!=nil && ![[cellDetails fieldValue] isKindOfClass:[NSNull class]] ))
                {
                    if ([[cellDetails fieldValue] isEqualToString:RPLocalizedString(SelectString, @"")] || [[cellDetails fieldValue] isEqualToString:RPLocalizedString(@"Add", @"")]) {
                        //[cellDetails setFieldValue:@"null" ];
                        [cellDetails setFieldValue:[NSNull null] ];
                           [self createUDFDict:nil andCell:cellDetails andUDFType:@"RowUDF"];
                    } 
                    else
                    {
                        [self validateUDFDateFormat:udfDateDict andCell:cellDetails andUDFType:@"RowUDF"];
                    }
                    
                }
                
                
                
            }
            
            else if ([[cellDetails udfModule] isEqualToString:TimesheetEntry_CellLevel]) {
                NSDictionary *udfDateDict=nil;
                if ([[cellDetails fieldValue] isKindOfClass:[NSDate class]]) {
                    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                    unsigned reqFields = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond;
                    NSDateComponents *comps=[calendar components:reqFields fromDate:[cellDetails fieldValue]];
                    udfDateDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInteger:[comps year]],@"Year",
                                   [NSNumber numberWithInteger:[comps month]],@"Month",
                                   [NSNumber numberWithInteger:[comps day]],@"Day",
                                   @"Date", @"__type",
                                   nil];
                   
                    [self validateUDFDateFormat:udfDateDict andCell:cellDetails andUDFType:@"HourUDF"];
                }
                else  if(([cellDetails fieldValue]!=nil && ![[cellDetails fieldValue] isKindOfClass:[NSNull class]] ))
                {
                    if ([[cellDetails fieldValue] isEqualToString:RPLocalizedString(SelectString, @"")] || [[cellDetails fieldValue] isEqualToString:RPLocalizedString(@"Add", @"")]) {
                        //[cellDetails setFieldValue:@"null" ];
                        [cellDetails setFieldValue:[NSNull null] ];
                        [self createUDFDict:nil andCell:cellDetails andUDFType:@"HourUDF"];
                    }
                    else 
                    {
                        [self validateUDFDateFormat:udfDateDict andCell:cellDetails andUDFType:@"HourUDF"];
                    }
                }
                
                
            }
            
            else if ([[cellDetails udfModule] isEqualToString:@"TimeOffs"]) {
                NSDictionary *udfDateDict=nil;
                if ([[cellDetails fieldValue] isKindOfClass:[NSDate class]]) {
                    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                    unsigned reqFields = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond;
                    NSDateComponents *comps=[calendar components:reqFields fromDate:[cellDetails fieldValue]];
                    udfDateDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInteger:[comps year]],@"Year",
                                   [NSNumber numberWithInteger:[comps month]],@"Month",
                                   [NSNumber numberWithInteger:[comps day]],@"Day",
                                   @"Date", @"__type",
                                   nil];
                    
                    [self validateUDFDateFormat:udfDateDict andCell:cellDetails andUDFType:@"UDF"];
                }
                
                else  if(([cellDetails fieldValue]!=nil && ![[cellDetails fieldValue] isKindOfClass:[NSNull class]] ))
                {
                    if ([[cellDetails fieldValue] isEqualToString:RPLocalizedString(SelectString, @"")] || [[cellDetails fieldValue] isEqualToString:RPLocalizedString(@"Add", @"")]) {
                        //[cellDetails setFieldValue:@"null" ];
                        [cellDetails setFieldValue:[NSNull null] ];
                        [self createUDFDict:nil andCell:cellDetails andUDFType:@"UDF"];
                    } 
                    else
                    {
                        [self validateUDFDateFormat:udfDateDict andCell:cellDetails andUDFType:@"UDF"];
                    }
                    
                }
                
                
            }
        }
    }
    
}

-(void)validateUDFDateFormat:(NSDictionary *)udfDateDict andCell:(G2EntryCellDetails *)cellDetails andUDFType:(NSString *)udfType
{
    if (udfDateDict==nil && [[cellDetails fieldType] isEqualToString:DATE_PICKER  ] ) {
        
        if ([[cellDetails defaultValue] isKindOfClass:[NSString class]]) 
        {
            NSString *dateStr = [cellDetails defaultValue];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [dateFormat setLocale:locale];
            [dateFormat setDateFormat:@"MMMM dd, yyyy"];
            
            NSDate *dateToBeUsed = [dateFormat dateFromString:dateStr]; 
            if (dateToBeUsed==nil) {
                [dateFormat setDateFormat:@"d MMMM yyyy"];
                dateToBeUsed = [dateFormat dateFromString:dateStr];
                //                if (dateToBeUsed==nil)
                //                {
                //                    [dateFormat setDateFormat:@"d MMMM, yyyy"];
                //                    dateToBeUsed = [dateFormat dateFromString:dateStr];
                //                }
            }
            
           
            
            if (dateToBeUsed!=nil)
            {
                NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                unsigned reqFields = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond;
                NSDateComponents *comps=[calendar components:reqFields fromDate:dateToBeUsed];
                udfDateDict = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithInteger:[comps year]],@"Year",
                               [NSNumber numberWithInteger:[comps month]],@"Month",
                               [NSNumber numberWithInteger:[comps day]],@"Day",
                               @"Date", @"__type",
                               nil];
              
            }
            
        }
        else if ([[cellDetails defaultValue] isKindOfClass:[NSDate class]]) 
        {
            NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            unsigned reqFields = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond;
            NSDateComponents *comps=[calendar components:reqFields fromDate:[cellDetails defaultValue]];
            udfDateDict = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithInteger:[comps year]],@"Year",
                           [NSNumber numberWithInteger:[comps month]],@"Month",
                           [NSNumber numberWithInteger:[comps day]],@"Day",
                           @"Date", @"__type",
                           nil];
           
            
        }
        
    }
    
    [self createUDFDict:udfDateDict andCell:cellDetails andUDFType:udfType];


}


-(void)createUDFDict:(NSDictionary *)udfDateDict andCell:(G2EntryCellDetails *)cellDetails andUDFType:(NSString *)udfType
{
    NSDictionary *cell_row_UDFDict=nil;
    if (udfDateDict!=nil) {
        cell_row_UDFDict=[NSDictionary dictionaryWithObjectsAndKeys:udfDateDict,[cellDetails fieldName] ,nil];
    }
    else
    {  
        if ([cellDetails fieldValue]!=nil ) {
            cell_row_UDFDict=[NSDictionary dictionaryWithObjectsAndKeys:[cellDetails fieldValue],[cellDetails fieldName] ,nil];
        }
        else
        {
            if ([cellDetails defaultValue]!=nil  ) 
            {
                if ([[cellDetails defaultValue] isKindOfClass:[NSString class]]) {
                    if(![[cellDetails defaultValue] isEqualToString:RPLocalizedString(SelectString, @"")] &&  ![[cellDetails defaultValue] isEqualToString:RPLocalizedString(@"Add", @"")])
                    {
                        cell_row_UDFDict=[NSDictionary dictionaryWithObjectsAndKeys:[cellDetails defaultValue],[cellDetails fieldName] ,nil];
                    }
                    else
                    {
                        cell_row_UDFDict=[NSDictionary dictionaryWithObjectsAndKeys:[NSNull null],[cellDetails fieldName] ,nil];
                    }
                }
                else if([[cellDetails defaultValue] isKindOfClass:[NSNumber class]] )
                {
                    int decimals = [cellDetails decimalPoints];
                    NSString *tempValue =	[G2Util formatDecimalPlacesForNumericKeyBoard:[[cellDetails defaultValue] doubleValue] withDecimalPlaces:decimals];
                    tempValue = [G2Util removeCommasFromNsnumberFormaters:tempValue];
                    cell_row_UDFDict=[NSDictionary dictionaryWithObjectsAndKeys:tempValue,[cellDetails fieldName] ,nil];
                }
                
                else
                {
                    cell_row_UDFDict=[NSDictionary dictionaryWithObjectsAndKeys:[NSNull null],[cellDetails fieldName] ,nil];
                }
                
            }
            else
            {
                cell_row_UDFDict=[NSDictionary dictionaryWithObjectsAndKeys:[NSNull null],[cellDetails fieldName] ,nil];
            }
            
        }
        
    }
    
    
    
    if ([udfType isEqualToString:@"RowUDF" ]) 
    {
        if ([timeSheetEntryObject rowUDFArray]==nil) {
            [timeSheetEntryObject setRowUDFArray:[NSMutableArray arrayWithObject:cell_row_UDFDict]];
        }
        else
        {
            [[timeSheetEntryObject rowUDFArray] addObject:cell_row_UDFDict];
        }
    }
    else  if ([udfType isEqualToString:@"HourUDF" ])
    {
        
        if ([timeSheetEntryObject cellUDFArray]==nil) {
            [timeSheetEntryObject setCellUDFArray:[NSMutableArray arrayWithObject:cell_row_UDFDict]];
        }
        else
        {
            [[timeSheetEntryObject cellUDFArray] addObject:cell_row_UDFDict];
        }
        
    }
    else if ([udfType isEqualToString:@"UDF" ]) 
    {
        if ([timeOffEntryObject udfArray]==nil) {
            [timeOffEntryObject setUdfArray:[NSMutableArray arrayWithObject:cell_row_UDFDict]];
        }
        else
        {
            [[timeOffEntryObject udfArray] addObject:cell_row_UDFDict];
        }
    }

}


/*
 * This method handles actions related to adding an entry with sheetId
 */
-(void)handleAddTimeEntryWithSheetIdentity {
	
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
	if ([[NetworkMonitor sharedInstance]networkAvailable]) {
		[self saveTimeEntryForSheet];
	}
	else {
		[timeSheetEntryObject setIsModified:YES];
		[timesheetModel saveTimeEntryForSheetWithObject :timeSheetEntryObject editStatus:OFFLINE_CREATE_STATUS];
		[timesheetModel updateSheetModifyStatus:[timeSheetEntryObject sheetId] status:YES];
		[self showListOfTimeEntries];
	}
	
}

-(void)handleAddTimeOffEntryWithSheetIdentity {
	
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
	if ([[NetworkMonitor sharedInstance]networkAvailable]) {
		[self saveTimeOffEntryForSheet];
	}
	else {
		[timeOffEntryObject setIsModified:YES];
		[timesheetModel saveTimeOffEntryForSheetWithObject :timeOffEntryObject editStatus:OFFLINE_CREATE_STATUS];
		[timesheetModel updateSheetModifyStatus:[timeOffEntryObject sheetId] status:YES];
		[self showListOfTimeEntries];
	}
	
}


/*
 * This method handles actions related to adding an entry without sheetId
 */
-(void)handleAddTimeEntryWithoutSheetIdentity {
	//fetch sheet from api and add entry to the sheet with selected entry date.
	NSDate *selectedEntryDate = [timeSheetEntryObject entryDate];
	if (selectedEntryDate != nil && [selectedEntryDate isKindOfClass:[NSDate class]]) {
		//DLog(@"EntryDate not nil");
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(SavingMessage, "")];
		if ([[NetworkMonitor sharedInstance] networkAvailable]) {
			[[G2RepliconServiceManager timesheetService] 
			 getTimesheetFromApiAndAddTimeEntry:timeSheetEntryObject];
			[[NSNotificationCenter defaultCenter] 
			 addObserver:self selector:@selector(saveEntryForFetchedSheet:) name:FETCH_TIMESHEET_FOR_ENTRY_DATE object:nil];
		}
		else {
			[timeSheetEntryObject setIsModified:YES];
			//check if any timesheet exists in db with date range and act.
			NSMutableArray *entryTimesheetArray = [timesheetModel getTimeSheetForEntryDate:selectedEntryDate];
			if (entryTimesheetArray != nil && [entryTimesheetArray count] > 0) {
				NSDictionary *entryTimesheet = [entryTimesheetArray objectAtIndex:0];
				NSString *sheetId = [entryTimesheet objectForKey:@"identity"];
				[timeSheetEntryObject setSheetId:sheetId];	
				[timesheetModel updateSheetModifyStatus:sheetId status:YES];
			}
			[timesheetModel saveTimeEntryForSheetWithObject :timeSheetEntryObject editStatus:OFFLINE_CREATE_STATUS];
			[self showListOfTimeEntries];
			
		}
		
	}
}

-(void)handleAddTimeOffEntryWithoutSheetIdentity {
	NSDate *selectedEntryDate = [timeOffEntryObject timeOffDate];
	if (selectedEntryDate != nil && [selectedEntryDate isKindOfClass:[NSDate class]]) {
		//DLog(@"EntryDate not nil");
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(SavingMessage, "")];
		if ([[NetworkMonitor sharedInstance] networkAvailable]) {
			[[G2RepliconServiceManager timesheetService] 
			 getTimeOffFromApiAndAddTimeEntry:timeOffEntryObject];
			[[NSNotificationCenter defaultCenter] 
			 addObserver:self selector:@selector(saveEntryForFetchedSheet:) name:FETCH_TIMEOFF_FOR_ENTRY_DATE object:nil];
		}
		else {
			[timeOffEntryObject setIsModified:YES];
			//check if any timesheet exists in db with date range and act.
			NSMutableArray *entryTimesheetArray = [timesheetModel getTimeSheetForEntryDate:selectedEntryDate];
			if (entryTimesheetArray != nil && [entryTimesheetArray count] > 0) {
				NSDictionary *entryTimesheet = [entryTimesheetArray objectAtIndex:0];
				NSString *sheetId = [entryTimesheet objectForKey:@"identity"];
				[timeOffEntryObject setSheetId:sheetId];	
				[timesheetModel updateSheetModifyStatus:sheetId status:YES];
			}
			[timesheetModel saveTimeOffEntryForSheetWithObject :timeOffEntryObject editStatus:OFFLINE_CREATE_STATUS];
            
			[self showListOfTimeEntries];
			
		}
		
	}
}

-(BOOL)checkIsMidNightCrossOver:(G2TimeSheetEntryObject *)timeSheetEntryObj
{
    BOOL isMidNightCrossOver=NO;
    
    NSIndexPath *noOfHrsIndexPath = [NSIndexPath indexPathForRow:[self.firstSectionfieldsArr count]-1 inSection:0];
	G2TimeEntryCellView *cell = (G2TimeEntryCellView *)[self.tnewTimeEntryTableView cellForRowAtIndexPath:noOfHrsIndexPath];
    NSString *strNumberOfHours=cell.textField.text;
    NSInteger hrs=[strNumberOfHours integerValue];
    //DLog(@"%d",hrs);
    
    if ([timeSheetEntryObj inTime]==nil || [[timeSheetEntryObj inTime] isKindOfClass:[NSNull class]] ) 
    {
        return NO;
    }
    
    if ([timeSheetEntryObj outTime]==nil || [[timeSheetEntryObj outTime] isKindOfClass:[NSNull class]] ) 
    {
        return NO;
    }
    
    NSDate *inTimeDate = [self convertStringToDesiredDateTimeFormat:[timeSheetEntryObj inTime]];
    NSDate *outTimeDate = [self convertStringToDesiredDateTimeFormat:[timeSheetEntryObj outTime]];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *inTimeComponents =
    [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:inTimeDate];
    NSInteger inTimeHours = [inTimeComponents hour];
    NSInteger inTimeMinutes = [inTimeComponents minute];
    //DLog(@"%d %d ",inTimeHours,inTimeMinutes);
    
    NSDateComponents *outTimeComponents =
    [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:outTimeDate]; 
    
    NSInteger outTimeHours = [outTimeComponents hour];
    NSInteger outTimeMinutes = [outTimeComponents minute];
    //DLog(@"%d %d ",outTimeHours,outTimeMinutes);
    
    
    if (inTimeHours >=0 && inTimeHours<=11 && inTimeMinutes <=59 && outTimeHours >=0 && outTimeHours<=11 && outTimeMinutes<=59)
    {
        if (hrs>=12) {
            
            isMidNightCrossOver=YES;
        }
        else
        {
            
            isMidNightCrossOver=NO;
        }
    }
    
    else if (inTimeHours >=12&& inTimeHours<=23 && inTimeMinutes <=59 && outTimeHours >=12 && outTimeHours<=23 && outTimeMinutes<=59)
    {
        if (hrs>=12) {
            
            isMidNightCrossOver=YES;
        }
        else
        {
            isMidNightCrossOver=NO;
        }
    }
    
    else if (inTimeHours >=12 && inTimeHours<=23 && inTimeMinutes <=59 && outTimeHours >=0 && outTimeHours<=11 && outTimeMinutes<=59)
    {
        
        isMidNightCrossOver=YES;
    }

    return isMidNightCrossOver;
}

-(void)sendOnlineRequestToEditTimeEntry{
	//DLog(@"sendOnlineRequestToEditTimeEntry::AddNewTimeEntryViewController");
	if (![[timeSheetEntryObject billingIdentity] isEqualToString: BILLING_NONBILLABLE] && [timeSheetEntryObject projectIdentity] != nil) {
		NSNumber *roleId = [supportDataModel getProjectRoleIdForBilling:[timeSheetEntryObject billingIdentity] :[timeSheetEntryObject projectIdentity]];
		if (roleId != nil && ![roleId isKindOfClass:[NSNull class]]) {
			[timeSheetEntryObject setProjectRoleId:roleId];
		}
        else
        {
            roleId=[supportDataModel get_role_billing_identity:[timeSheetEntryObject billingIdentity] ];
            if (roleId && ![roleId isKindOfClass:[NSNull class]]) {
                [timeSheetEntryObject setProjectRoleId:roleId];
            }
            else
            {
                roleId=[supportDataModel get_role_billing_identityForBillingName:[timeSheetEntryObject billingName] forProjectIdentity:[timeSheetEntryObject projectIdentity] ];
                if (roleId && ![roleId isKindOfClass:[NSNull class]]) {
                    [timeSheetEntryObject setProjectRoleId:roleId];
                }
            }
        }
	}
    RepliconAppDelegate *aAppDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    
        //US4513 Ullas M L
       if (aAppDelegate.isNewInOutTimesheetUser)
       {
           BOOL isMidNightCrossOver=NO;
           isMidNightCrossOver=[self checkIsMidNightCrossOver:timeSheetEntryObject];
           NSMutableArray *tempMutilpleJsonRequestArrayForNewInOut=[[NSMutableArray alloc]init];
           self.mutilpleJsonRequestArrayForNewInOut=tempMutilpleJsonRequestArrayForNewInOut;
           
            if (isMidNightCrossOver) 
            {
                
                
                for (int i=0; i<2; i++) {
                    
                    G2TimeSheetEntryObject *entryObject=[[G2TimeSheetEntryObject alloc]init];
                    
                    entryObject.activityArray=timeSheetEntryObject.activityArray;
                    entryObject.activityIdentity=timeSheetEntryObject.activityIdentity;
                    entryObject.activityName=timeSheetEntryObject.activityName;
                    entryObject.availableFields=timeSheetEntryObject.availableFields;
                    entryObject.billingDefaultValue=timeSheetEntryObject.billingDefaultValue;
                    entryObject.billingIdentity=timeSheetEntryObject.billingIdentity;
                    entryObject.billingName=timeSheetEntryObject.billingName;
                    entryObject.cellUDFArray=timeSheetEntryObject.cellUDFArray;
                    entryObject.clientAllocationId=timeSheetEntryObject.clientAllocationId;
                    entryObject.clientArray=timeSheetEntryObject.clientArray;
                    entryObject.clientIdentity=timeSheetEntryObject.clientIdentity;
                    entryObject.clientName=timeSheetEntryObject.clientName;
                    entryObject.clientProjectTask=timeSheetEntryObject.clientProjectTask;
                    entryObject.comments=timeSheetEntryObject.comments;
                    entryObject.dateDefaultValue=timeSheetEntryObject.dateDefaultValue;
                    entryObject.identity=timeSheetEntryObject.identity;
                    entryObject.projectRoleId=timeSheetEntryObject.projectRoleId;
                    entryObject.projectRemoved=timeSheetEntryObject.projectRemoved;
                    entryObject.projectName=timeSheetEntryObject.projectName;
                    entryObject.projectIdentity=timeSheetEntryObject.projectIdentity;
                    entryObject.projectArray=timeSheetEntryObject.projectArray;
                    entryObject.rowUDFArray=timeSheetEntryObject.rowUDFArray;
                    entryObject.sheetId=timeSheetEntryObject.sheetId;
                    entryObject.timeDefaultValue=timeSheetEntryObject.timeDefaultValue;
                    entryObject.taskObj=timeSheetEntryObject.taskObj;
                    entryObject.userID=timeSheetEntryObject.userID;

                    if (i==0) 
                    {    
                                                
                        entryObject.entryDate=timeSheetEntryObject.entryDate;
                        entryObject.inTime=timeSheetEntryObject.inTime;
                        [entryObject setOutTime:@"11:59 PM"];
                        [self.mutilpleJsonRequestArrayForNewInOut addObject:entryObject];
                       
                        
                    }
                    else 
                    {
                                                
                        NSDate *selectedEntryDate = [timeSheetEntryObject entryDate];
                        NSDate *nextEntryDate= [NSDate dateWithTimeInterval:(24*60*60) sinceDate:selectedEntryDate];
                        entryObject.outTime=timeSheetEntryObject.outTime;
                        [entryObject setEntryDate:nextEntryDate];
                        [entryObject setInTime:@"12:00 AM"];
                        [self.mutilpleJsonRequestArrayForNewInOut addObject:entryObject];
                       
                    }
                }
                
                [[G2RepliconServiceManager timesheetService] sendRequestToEditTheTimeEntryDetailsWithUserDataForNewInOutTimesheets:self.mutilpleJsonRequestArrayForNewInOut];
                [[NSNotificationCenter defaultCenter] 
                 addObserver:self selector:@selector(fetchTimeSheetAfterEdit) 
                 name:TIME_ENTRY_EDITED_NOTIFICATION object:nil];
                return;
                
            }
            else
            {   
                [self.mutilpleJsonRequestArrayForNewInOut addObject:timeSheetEntryObject];
                [[G2RepliconServiceManager timesheetService] sendRequestToEditTheTimeEntryDetailsWithUserDataForNewInOutTimesheets:self.mutilpleJsonRequestArrayForNewInOut];
                [[NSNotificationCenter defaultCenter] 
                 addObserver:self selector:@selector(fetchTimeSheetAfterEdit) 
                 name:TIME_ENTRY_EDITED_NOTIFICATION object:nil];
                return;
            }
    }
       else
       {
           if (!isInOutFlag && !isLockedTimeSheet)  {
               [[G2RepliconServiceManager timesheetService] sendRequestToEditTheTimeEntryDetailsWithUserData:timeSheetEntryObject];
           }
           
           else
           {
               [[G2RepliconServiceManager timesheetService] sendRequestToEditTheTimeEntryDetailsWithUserDataForInOutTimesheets:timeSheetEntryObject];
               
           }
       }

        
        
    
	//[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
	
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self selector:@selector(fetchTimeSheetAfterEdit) 
	 name:TIME_ENTRY_EDITED_NOTIFICATION object:nil];
}

-(void)sendOnlineRequestToEditTimeOffEntry{
	//DLog(@"sendOnlineRequestToEditTimeEntry::AddNewTimeEntryViewController");
	
    
    
    [[G2RepliconServiceManager timesheetService] sendRequestToEditTheTimeOffEntryDetailsWithUserData:timeOffEntryObject];
    
	
	
//	[[NSNotificationCenter defaultCenter] 
//	 addObserver:self selector:@selector(popToTimeEntriesContentsPage) 
//	 name:TIMEOFF_ENTRY_EDITED_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter]
	 addObserver:self selector:@selector(fetchTimeSheetAfterEdit)
	 name:TIMEOFF_ENTRY_EDITED_NOTIFICATION object:nil];

}

-(void)fetchTimeSheetAfterEdit{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:TIME_ENTRY_EDITED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
													name:TIMEOFF_ENTRY_EDITED_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIME_ENTRY_DELETE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_ENTRY_DELETE_NOTIFICATION object:nil];
    
    //	NSString *status = @"";
    //	[timesheetModel updateEditedTimeEntry:timeSheetEntryObject andStatus:status];
    //	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
    
    [[G2RepliconServiceManager timesheetService] 
	 sendRequestToFetchTimesheetByIdWithEntries:selectedSheetIdentity];
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self selector:@selector(showListOfTimeEntries) name:FETCH_TIMESHEET_BY_IDENTITY object:nil];
    
	if (submissionErrorDelegate != nil) {
		//	DLog(@"Submission Error Delegate != nil");
		[submissionErrorDelegate performSelector:@selector(resetSubmissionErrorDetails)];
	}
    //	[self.navigationController popViewControllerAnimated:YES];
}

-(void)popToTimeEntriesContentsPage{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:TIME_ENTRY_EDITED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
													name:TIMEOFF_ENTRY_EDITED_NOTIFICATION object:nil];
	NSString *status = @"";
    if (timeSheetEntryObject!=nil) {
        [timesheetModel updateEditedTimeEntry:timeSheetEntryObject andStatus:status];
    }
	else
    {
        [timesheetModel updateEditedTimeOffEntry:timeOffEntryObject andStatus:status];
    }
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
	if (submissionErrorDelegate != nil) {
		//	DLog(@"Submission Error Delegate != nil");
		[submissionErrorDelegate performSelector:@selector(resetSubmissionErrorDetails)];
	}
	[self.navigationController popViewControllerAnimated:YES];
}
-(void)saveEntryForFetchedSheet:(id)notificationObject {
	//DLog(@"saveEntryForFetchedSheet: notificationObject");
	[[NSNotificationCenter defaultCenter]
	 removeObserver:self name:FETCH_TIMESHEET_FOR_ENTRY_DATE object:nil];
    [[NSNotificationCenter defaultCenter]
	 removeObserver:self name:FETCH_TIMEOFF_FOR_ENTRY_DATE object:nil];
    
         self.selectedSheet=nil;
    G2PermissionsModel *permission=[[G2PermissionsModel alloc]init];
    BOOL reopenPermission=[permission checkUserPermissionWithPermissionName:@"ReopenTimesheet"];//US4660//Juhi


	
    
	NSString *fetchedSheetId = ((NSNotification *)notificationObject).object;
	//update the entry object with fetched sheetId
	//DLog(@"fetchedSheetId %@",fetchedSheetId);
	if (fetchedSheetId != nil && ![fetchedSheetId isKindOfClass:[NSNull class]]) {
		
		NSMutableArray *sheetDetails = [timesheetModel getTimeSheetInfoForSheetIdentity:fetchedSheetId];
       
		if (sheetDetails != nil && [sheetDetails count] > 0) {
			
            BOOL isApprovalRemaining=[[[sheetDetails objectAtIndex:0] objectForKey:@"approversRemaining"] boolValue];
            //US4754
            NSDate   *startDt =[G2Util convertStringToDate:[[sheetDetails objectAtIndex:0] objectForKey:@"startDate"] ] ;
            NSString *convertedStartDt= [G2Util convertPickerDateToStringShortStyle:startDt];
            NSDate   *endDt=[G2Util convertStringToDate:[[sheetDetails objectAtIndex:0] objectForKey:@"endDate"] ];
            NSString *convertedEndDt = [G2Util convertPickerDateToStringShortStyle:endDt];
            NSArray  *startDateComponents = [convertedStartDt componentsSeparatedByString:@","];
            NSString *trimmedStartDt= [startDateComponents objectAtIndex:0];
            
            NSArray  *endDateComponents=[convertedEndDt componentsSeparatedByString:@","];
            NSString *trimmedEndDt=[endDateComponents objectAtIndex:0];
            ;
            self.selectedSheet=[NSString stringWithFormat:@"%@ - %@",trimmedStartDt,
                                trimmedEndDt];
            NSString *approvalStatus = [[sheetDetails objectAtIndex:0] objectForKey:@"approvalStatus"];
            
            if (timeSheetEntryObject!=nil)
            {
//US4660//Juhi
			   [timeSheetEntryObject setSheetId:fetchedSheetId];
            }
			else
            {
                [timeOffEntryObject setSheetId:fetchedSheetId];
            }
            
			
			if (approvalStatus != nil && [approvalStatus isEqualToString:G2WAITING_FOR_APRROVAL_STATUS]) {
				[self setSheetStatus:G2WAITING_FOR_APRROVAL_STATUS];
				[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
				if ([permissionsObj unsubmitTimeSheet]&& !isApprovalRemaining) {
                    [self confirmAlert:RPLocalizedString(@"Unsubmit",@"Unsubmit") confirmMessage:RPLocalizedString(UNSUBMIT_ADD_MESSAGE,"") title:nil];
                }
                else if (![permissionsObj unsubmitTimeSheet] && !isApprovalRemaining && reopenPermission) 
                {
                    [self confirmAlert:RPLocalizedString(@"Unsubmit",@"Unsubmit") confirmMessage:RPLocalizedString(UNSUBMIT_ADD_MESSAGE,"") title:nil];
                }
                else if(reopenPermission && isApprovalRemaining)
                {
                    [self confirmAlert:RPLocalizedString(@"Reopen",@"Reopen") confirmMessage:RPLocalizedString(REOPEN_ADD_MESSAGE,"") title:nil];
                }
				else
                    [G2Util errorAlert:@"" errorMessage:[NSString stringWithFormat:@"%@ \n %@",RPLocalizedString(UNSUBMIT_ADD_TITLE,""),RPLocalizedString(SELECT_ANOTHER_DATE_MESSAGE,"")]];
			}
			else if([approvalStatus isEqualToString:NOT_SUBMITTED_STATUS] ||
					[approvalStatus isEqualToString:REJECTED_STATUS]) {
				[self setSheetStatus:approvalStatus];
                
                if (timeSheetEntryObject!=nil) 
                {
                    [self saveTimeEntryForSheet];
                    [self setSelectedSheetIdentity:[NSString stringWithFormat:@"%@",[timeSheetEntryObject sheetId]]];
                    [timeSheetEntryObject setSheetId:nil];
                }
                else
                {
                    [self saveTimeOffEntryForSheet];
                    [self setSelectedSheetIdentity:[NSString stringWithFormat:@"%@",[timeOffEntryObject sheetId]]];
                    [timeOffEntryObject setSheetId:nil];
                }
                
				
			}
               else if([approvalStatus isEqualToString:APPROVED_STATUS])
            {
                [self setSheetStatus:approvalStatus];
                [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
                 if(reopenPermission)
                {
                    [self confirmAlert:RPLocalizedString(@"Reopen",@"Reopen") confirmMessage:RPLocalizedString(REOPEN_ADD_MESSAGE,"") title:nil];
                }
                else{
                    [G2Util errorAlert:@"" errorMessage:[NSString stringWithFormat:@"%@ \n %@",RPLocalizedString(UNSUBMIT_ADD_TITLE,""),RPLocalizedString(SELECT_ANOTHER_DATE_MESSAGE,"")]];
                     [timeSheetEntryObject setSheetId:nil];
                 }
            }
			else {
				[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
                //				[Util errorAlert:UNSUBMIT_ADD_TITLE errorMessage:SELECT_ANOTHER_DATE_MESSAGE];
                //                [Util errorAlert:@"" errorMessage:[NSString stringWithFormat:@"%@ /n %@",UNSUBMIT_ADD_TITLE,SELECT_ANOTHER_DATE_MESSAGE]];//DE1231//Juhi
                [G2Util errorAlert:@"" errorMessage:[NSString stringWithFormat:@"%@ \n %@",RPLocalizedString(UNSUBMIT_ADD_TITLE,""),RPLocalizedString(SELECT_ANOTHER_DATE_MESSAGE,"")]];//DE4050//Juhi
                if (timeSheetEntryObject!=nil) 
                {
                    [timeSheetEntryObject setSheetId:nil];
                }
                else
                {
                    [timeOffEntryObject setSheetId:nil];
                }
				
			}
			
			
		}
	}

}

-(void)saveTimeEntryForSheet {
	[self setSheetStatus:NOT_SUBMITTED_STATUS];
	//DLog(@"sending request to save entry");
	[[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_SUBMIT_SUCCESS_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:TIME_ENTRY_SAVED_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:FETCH_TIMESHEET_BY_IDENTITY object:nil];
    
    //US4513 Ullas M L
    RepliconAppDelegate *aAppDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    if (aAppDelegate.isNewInOutTimesheetUser)
    {
        BOOL isMidNightCrossOver=NO;
        isMidNightCrossOver=[self checkIsMidNightCrossOver:timeSheetEntryObject];
        NSDate *inTimeDate = [self convertStringToDesiredDateTimeFormat:[timeSheetEntryObject inTime]];
        NSDate *outTimeDate = [self convertStringToDesiredDateTimeFormat:[timeSheetEntryObject outTime]];
        NSMutableArray *tempMutilpleJsonRequestArrayForNewInOut=[[NSMutableArray alloc]init];
        self.mutilpleJsonRequestArrayForNewInOut=tempMutilpleJsonRequestArrayForNewInOut;
        
        //[self.mutilpleJsonRequestArrayForNewInOut removeAllObjects];
        if (inTimeDate!=nil && outTimeDate!=nil) {
            if (isMidNightCrossOver) 
            {
                for (int i=0; i<2; i++) {
                    
                    G2TimeSheetEntryObject *entryObject=[[G2TimeSheetEntryObject alloc]init];
                    entryObject.activityArray=timeSheetEntryObject.activityArray;
                    entryObject.activityIdentity=timeSheetEntryObject.activityIdentity;
                    entryObject.activityName=timeSheetEntryObject.activityName;
                    entryObject.availableFields=timeSheetEntryObject.availableFields;
                    entryObject.billingDefaultValue=timeSheetEntryObject.billingDefaultValue;
                    entryObject.billingIdentity=timeSheetEntryObject.billingIdentity;
                    entryObject.billingName=timeSheetEntryObject.billingName;
                    entryObject.cellUDFArray=timeSheetEntryObject.cellUDFArray;
                    entryObject.clientAllocationId=timeSheetEntryObject.clientAllocationId;
                    entryObject.clientArray=timeSheetEntryObject.clientArray;
                    entryObject.clientIdentity=timeSheetEntryObject.clientIdentity;
                    entryObject.clientName=timeSheetEntryObject.clientName;
                    entryObject.clientProjectTask=timeSheetEntryObject.clientProjectTask;
                    entryObject.comments=timeSheetEntryObject.comments;
                    entryObject.dateDefaultValue=timeSheetEntryObject.dateDefaultValue;
                    entryObject.identity=timeSheetEntryObject.identity;
                    entryObject.projectRoleId=timeSheetEntryObject.projectRoleId;
                    entryObject.projectRemoved=timeSheetEntryObject.projectRemoved;
                    entryObject.projectName=timeSheetEntryObject.projectName;
                    entryObject.projectIdentity=timeSheetEntryObject.projectIdentity;
                    entryObject.projectArray=timeSheetEntryObject.projectArray;
                    entryObject.rowUDFArray=timeSheetEntryObject.rowUDFArray;
                    entryObject.sheetId=timeSheetEntryObject.sheetId;
                    entryObject.timeDefaultValue=timeSheetEntryObject.timeDefaultValue;
                    entryObject.taskObj=timeSheetEntryObject.taskObj;
                    entryObject.userID=timeSheetEntryObject.userID;
                    entryObject.entryDate=timeSheetEntryObject.entryDate;
                    
                    if (i==0) 
                    {
                        
                        entryObject.inTime=timeSheetEntryObject.inTime;
                        [entryObject setOutTime:@"11:59 PM"];
                        [self.mutilpleJsonRequestArrayForNewInOut insertObject:entryObject atIndex:i];
                       
                        
                    }
                    else {
                        
                        NSDate *selectedEntryDate = [entryObject entryDate];
                        NSDate *nextEntryDate= [NSDate dateWithTimeInterval:(24*60*60) sinceDate:selectedEntryDate];
                        entryObject.outTime=timeSheetEntryObject.outTime;
                        [entryObject setEntryDate:nextEntryDate];
                        [entryObject setInTime:@"12:00 AM"];
                        [self.mutilpleJsonRequestArrayForNewInOut insertObject:entryObject atIndex:i];
                        
                    }
                    
                }

                
            }
            else
            { 
                
                [self.mutilpleJsonRequestArrayForNewInOut addObject:timeSheetEntryObject];
                
            }
            
            [[G2RepliconServiceManager timesheetService] sendRequestToAddNewTimeEntryWithObjectForNewInOutTimesheets:self.mutilpleJsonRequestArrayForNewInOut];
        }
        else
        { 
            
            [self.mutilpleJsonRequestArrayForNewInOut addObject:timeSheetEntryObject];
            [[G2RepliconServiceManager timesheetService] sendRequestToAddNewTimeEntryWithObjectForNewInOutTimesheets:self.mutilpleJsonRequestArrayForNewInOut];
        } 
        
        
    }
    else
    {
        if (!isInOutFlag) {
            DLog(@"ADDED FOR PUNCH CLOCK");
            [[G2RepliconServiceManager timesheetService] sendRequestToAddNewTimeEntryWithObject:timeSheetEntryObject];
        }
        
        
        
        else
        {
            [[G2RepliconServiceManager timesheetService] sendRequestToAddNewTimeEntryWithObjectForInOutTimesheets:timeSheetEntryObject];
            
        }
        
    }
    

	[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(SavingMessage, "")];
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self selector:@selector(fetchTimeSheetAfterSave) name:TIME_ENTRY_SAVED_NOTIFICATION object:nil];
}

-(void)saveTimeOffEntryForSheet {
	[self setSheetStatus:NOT_SUBMITTED_STATUS];
	//DLog(@"sending request to save entry");
	[[NSNotificationCenter defaultCenter] removeObserver:self name:TIMESHEET_SUBMIT_SUCCESS_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_ENTRY_SAVED_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:FETCH_TIMESHEET_BY_IDENTITY object:nil];
    
    
    [[G2RepliconServiceManager timesheetService] sendRequestToAddNewTimeOffWithObject:timeOffEntryObject];
    
	
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(SavingMessage, "")];
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self selector:@selector(fetchTimeSheetAfterSave) name:TIMEOFF_ENTRY_SAVED_NOTIFICATION object:nil];
}

//US4513 Ullas M L
-(NSDate *) convertStringToDesiredDateTimeFormat: (NSString *)dateStr {
	
    if (dateStr!=nil && ![dateStr isKindOfClass:[NSNull class]]) 
    {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [dateFormat setLocale:locale];
        [dateFormat setDateFormat:@"hh:mm a"];
        
        NSDate *date = [dateFormat dateFromString:dateStr ];
       
        
        return date;
    }   
    
    return nil;
}   


-(void)fetchTimeSheetAfterSave {
	//DLog(@"fetchTimeSheetAfterSave:: Added Entry Sheet Identity:%@",[timeSheetEntryObject sheetId]);
	[[NSNotificationCenter defaultCenter] removeObserver:self name:TIME_ENTRY_SAVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_ENTRY_SAVED_NOTIFICATION object:nil];
    
	[[G2RepliconServiceManager timesheetService] 
	 sendRequestToFetchTimesheetByIdWithEntries:selectedSheetIdentity];
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self selector:@selector(showListOfTimeEntries) name:FETCH_TIMESHEET_BY_IDENTITY object:nil];
}
-(void)showListOfTimeEntries {
    
	[[NSNotificationCenter defaultCenter] removeObserver:self name:FETCH_TIMESHEET_BY_IDENTITY object:nil];
    
    if (screenMode==EDIT_TIME_ENTRY || screenMode == EDIT_ADHOC_TIMEOFF) {
        [self.navigationController popViewControllerAnimated:YES];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
    }
    
    else 
    {
        if (isEntriesAvailable) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_DIRECT_ENTRY_SAVED" object:nil];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];

    }
	//DLog(@"showListOfTimeEntries");
}


-(void)backButtonAction:(id)sender{
	//DLog(@"backButtonAction ::AddNewTimeEntryViewController");
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Miscellaneous Methods

-(void)updateComments:(NSString *)commentsEntered{
	//DLog(@"updateComments ::: AddNewTimeEntryViewController:::Comments entered = %@",commentsEntered);
	
	//US4275//Juhi
    self.isComment=FALSE;
    self.isFromDoneClicked=TRUE;
    
    
    float deletebuttonHeight=100;
    
    // Let's make an NSAttributedString first
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:commentsEntered];
    //Add LineBreakMode
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
    // Add Font
    [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:RepliconFontSize_15]} range:NSMakeRange(0, attributedString.length)];
    
    //Now let's make the Bounding Rect
    CGSize size = [attributedString boundingRectWithSize:CGSizeMake(290.0, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    if (size.width==0 && size.height ==0) 
    {
        size=CGSizeMake(11.0, 18.0);
    }
    CGRect frame=self.commentsTextView.frame;
    frame.size.height = size.height+26;
    CGRect commentFrame=CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    
    CGRect deleteBtnFrame=CGRectZero;
    
    if (screenMode==EDIT_TIME_ENTRY || screenMode==EDIT_ADHOC_TIMEOFF) {
        deleteBtnFrame=deletButton.frame;
        deleteBtnFrame.origin.y=size.height+85;
        
        deletebuttonHeight=140;
        
    }
    
    
    
    CGRect  footerFrame=footerView.frame;
    
    footerFrame.size.height=commentFrame.size.height+deletebuttonHeight+2000;
    
    
    
    CGRect   tableFrame=tnewTimeEntryTableView.frame;
    tableFrame.size.height=(tableFrame.size.height-ROW_HEIGHT)+commentFrame.size.height;
    [self.tnewTimeEntryTableView setFrame:tableFrame];
    
    
    
    
    
    
    [self.tnewTimeEntryTableView setTableFooterView:nil];
    if (timeSheetEntryObject!=nil)
    {
         [timeSheetEntryObject setComments:commentsEntered];
    }
    else
    {
         [timeOffEntryObject setComments:commentsEntered];
    }
    [self.customPickerView setHidden:YES]; 
    
    
    //    self.mainScrollView.contentOffset=CGPointMake(0,commentsTextView.contentSize.height);
    
    
    
    [self.commentsTextView removeFromSuperview];
    [self.deletButton removeFromSuperview];
    [self.footerView removeFromSuperview];
    
    
    //US4275//Juhi
	
	
	UIView *tempfooterView = [[UIView alloc] initWithFrame:footerFrame];
    
    footerView=nil;
    self.footerView=tempfooterView;
   
	//[footerView setBackgroundColor:[UIColor greenColor]];
	[footerView setBackgroundColor:G2RepliconStandardBackgroundColor];
	
    
    UILabel *Commentlabel=[[UILabel alloc] init];
    Commentlabel.text=RPLocalizedString(Comments, @" ") ;
    Commentlabel.textColor=RepliconStandardBlackColor;
    [Commentlabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
    [Commentlabel setBackgroundColor:[UIColor clearColor]];
    Commentlabel.frame=CGRectMake(10.0,
                                  0,
                                  340.0,
                                  30.0);
    [self.footerView addSubview:Commentlabel];
    
    
    
    UITextView *temptextField=[[UITextView alloc]initWithFrame:CGRectMake(10.0,
                                                                          30,
                                                                          301.0,
                                                                          ROW_HEIGHT)];
   
    commentsTextView=nil;
    self.commentsTextView=temptextField;
   
    
    
    self.commentsTextView.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.commentsTextView.returnKeyType = UIReturnKeyDefault;
    self.commentsTextView.keyboardType = UIKeyboardTypeDefault;
    self.commentsTextView.textAlignment = NSTextAlignmentLeft;
    self.commentsTextView.textColor = RepliconStandardBlackColor;
    [self.commentsTextView setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];
    // For the border and rounded corners
    [[self.commentsTextView layer] setBorderColor:[[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:0.7] CGColor]];
    [[self.commentsTextView layer] setBorderWidth:1.0];
    [[self.commentsTextView layer] setCornerRadius:9];
    [self.commentsTextView setClipsToBounds: YES];
    [self.commentsTextView setScrollEnabled:FALSE];
    [self.commentsTextView setDelegate:self];
    if (screenMode == VIEW_TIME_ENTRY || screenMode == VIEW_ADHOC_TIMEOFF) 
    {
		self.commentsTextView.textColor = [UIColor grayColor];
    }
    
    [self.footerView addSubview:self.commentsTextView];
    
    NSString *commentString= commentsEntered;
    
    if (commentString!=nil ) {
        self.commentsTextView.text=[NSString stringWithString:commentString];
        // Setting Frame
        CGRect frame = commentsTextView.frame;
        
       
        
        // Let's make an NSAttributedString first
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:commentsEntered];
        //Add LineBreakMode
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        // Add Font
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:RepliconFontSize_15]} range:NSMakeRange(0, attributedString.length)];
        
        //Now let's make the Bounding Rect
        CGSize expectedLabelSize = [attributedString boundingRectWithSize:CGSizeMake(290.0, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        
        if (expectedLabelSize.width==0 && expectedLabelSize.height ==0) 
        {
            expectedLabelSize=CGSizeMake(11.0, 18.0);
        }
        frame.size.height = expectedLabelSize.height+22;
        if (frame.size.height>ROW_HEIGHT)
        {
            
            self.commentsTextView.frame = frame;
        }
        
        
        if ([self screenMode] == EDIT_TIME_ENTRY ) {
            
            if (!isLockedTimeSheet)                
            {
                
                deletButton =[UIButton buttonWithType:UIButtonTypeCustom];
                UIImage *img = [G2Util thumbnailImage:DeleteExpenseButton];
                UIImage *imgSel = [G2Util thumbnailImage:DeleteExpenseButtonSelected];
                [deletButton setBackgroundImage:img forState:UIControlStateNormal];
                [deletButton setBackgroundImage:imgSel forState:UIControlStateHighlighted];
                //[deletButton setFrame:CGRectMake(45.0, 35, img.size.width, img.size.height)];
                //[deletButton setTitle:RPLocalizedString(@"Delete Expense",@"") forState:UIControlStateNormal];
                [deletButton setTitle:RPLocalizedString(DELETE,@"Delete") forState:UIControlStateNormal];
                [deletButton setFrame:deleteBtnFrame];//US4065//Juhi
                deletButton.titleEdgeInsets = UIEdgeInsetsMake(-5.0, 0, 0, 0);
                [deletButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
                deletButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                [footerView addSubview:deletButton];
            }
            
            
        }
        else  if ([self screenMode] == EDIT_ADHOC_TIMEOFF ) {
            
           
                deletButton =[UIButton buttonWithType:UIButtonTypeCustom];
                UIImage *img = [G2Util thumbnailImage:DeleteExpenseButton];
                UIImage *imgSel = [G2Util thumbnailImage:DeleteExpenseButtonSelected];
                [deletButton setBackgroundImage:img forState:UIControlStateNormal];
                [deletButton setBackgroundImage:imgSel forState:UIControlStateHighlighted];
                //[deletButton setFrame:CGRectMake(45.0, 35, img.size.width, img.size.height)];
                //[deletButton setTitle:RPLocalizedString(@"Delete Expense",@"") forState:UIControlStateNormal];
                [deletButton setTitle:RPLocalizedString(DELETE,@"Delete") forState:UIControlStateNormal];
                [deletButton setFrame:deleteBtnFrame];//US4065//Juhi
                deletButton.titleEdgeInsets = UIEdgeInsetsMake(-5.0, 0, 0, 0);
                [deletButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
                deletButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                [footerView addSubview:deletButton];
            
            
            
        }

        
        frame=footerView.frame;
        frame.size.height=expectedLabelSize.height +15+140;
        [self.footerView setFrame:frame];
        
        frame=tnewTimeEntryTableView.frame;
        frame.size.height=(frame.size.height-ROW_HEIGHT)+self.commentsTextView.frame.size.height;;
        [self.tnewTimeEntryTableView setFrame:frame];
        
	}
    [self.tnewTimeEntryTableView setTableFooterView:footerView];
    
    
    
    int buttonSpaceHeight=70;
    int spaceForHeader=0.0;
    if ([secondSectionfieldsArray  count]==0) 
    {
            spaceForHeader=53.0;
    }
    else
    {
        spaceForHeader=48.0+48.0;
    }   
    if(isLockedTimeSheet)
    {
        
        if ([self screenMode]==ADD_ADHOC_TIMEOFF || [self screenMode]==EDIT_ADHOC_TIMEOFF || [self screenMode]==VIEW_ADHOC_TIMEOFF)
        {
            int buttonSpaceHeight=70;
            
            if( [self screenMode] == EDIT_ADHOC_TIMEOFF )
            {
                if ([secondSectionfieldsArray count]==0)
                {
                    buttonSpaceHeight=151.0;
                }
                else
                {
                    buttonSpaceHeight=145.0;
                }
            }
            int spaceHeader=0.0;
            
            if([secondSectionfieldsArray count]==0)
            {
                spaceHeader=51.0;
            }
            else 
            {
                spaceHeader=48.0+48.0;
            }
            
            
            self.mainScrollView.contentSize= CGSizeMake(self.view.frame.size.width, ([secondSectionfieldsArray  count]*ROW_HEIGHT)+([firstSectionfieldsArr  count]*ROW_HEIGHT)+35.0+spaceHeader+commentsTextView.frame.size.height+buttonSpaceHeight  );//US4065//Juhi
        }
        
        else
        {
             self.mainScrollView.contentSize= CGSizeMake(self.view.frame.size.width, ([secondSectionfieldsArray  count]*ROW_HEIGHT)+EXTRA_SPACING_LOCKED_IN_OUT+35.0+spaceForHeader+commentsTextView.frame.size.height+30.0+ROW_HEIGHT  );//US4065//Juhi
        }
        
       
    }
    else 
    {
        
        if( [self screenMode] == EDIT_TIME_ENTRY || [self screenMode] == EDIT_ADHOC_TIMEOFF)
        {
            buttonSpaceHeight=145.0;//US4065//Juhi
        }
        self.mainScrollView.contentSize= CGSizeMake(self.view.frame.size.width, ([secondSectionfieldsArray  count]*ROW_HEIGHT)+([firstSectionfieldsArr  count]*ROW_HEIGHT)+35.0+spaceForHeader+commentsTextView.frame.size.height+buttonSpaceHeight  );//US4065//Juhi
    }
    
    DLog(@"contentsize :%f",mainScrollView.contentSize.height);
    
    
}

-(void)updateUDFText:(NSString *)udfTextEntered
{
	G2TimeEntryCellView  *cell = (G2TimeEntryCellView *)[self.tnewTimeEntryTableView cellForRowAtIndexPath:selectedIndexPath];
    G2EntryCellDetails *dtlsObject = (G2EntryCellDetails *)[cell detailsObj];
	[cell.fieldButton setTitle:udfTextEntered forState:UIControlStateNormal];
	[dtlsObject setFieldValue:udfTextEntered];
	[customPickerView setHidden:YES];
    if (dtlsObject) {
        [secondSectionfieldsArray replaceObjectAtIndex:selectedIndexPath.row withObject:dtlsObject];
    }
    
}
-(NSIndexPath *)getNextEnabledIndexPath :(NSIndexPath *)currentIndexPath {
	
	NSInteger currentSection = currentIndexPath.section;
	NSInteger currentRow = currentIndexPath.row;
	
	if (currentSection == TIME) {
		
		for (NSInteger i=currentRow; i < [firstSectionfieldsArr count] -1 ; i++) {
			NSIndexPath *nextIndex = [NSIndexPath indexPathForRow:i+1 inSection:currentSection];
			G2TimeEntryCellView *cell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:nextIndex];
			if ([cell isUserInteractionEnabled]) {
				return nextIndex;
			}
		}
		
		NSUInteger projectInfoSectionCount = [secondSectionfieldsArray count];
		
		for (int i=0; i < projectInfoSectionCount -1 ; i++) {
			NSIndexPath *nextIndex = [NSIndexPath indexPathForRow:i inSection:PROJECT_INFO];
			G2TimeEntryCellView *cell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:nextIndex];
			if ([cell isUserInteractionEnabled]) {
				return nextIndex;
			}
		}
        
        ///FOR ONLY ACTIVITIES
        if (projectInfoSectionCount==1) {
            NSIndexPath *nextIndex = [NSIndexPath indexPathForRow:0 inSection:PROJECT_INFO];
            G2TimeEntryCellView *cell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:nextIndex];
            if ([cell isUserInteractionEnabled]) {
                return nextIndex;
            }
        }
        
        
	}
	else if (currentSection == PROJECT_INFO) {
		
		for (NSInteger i=currentRow; i < [secondSectionfieldsArray count] -1 ; i++) {
			NSIndexPath *nextIndex = [NSIndexPath indexPathForRow:i+1 inSection:PROJECT_INFO];
			G2TimeEntryCellView *cell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:nextIndex];
			if ([cell isUserInteractionEnabled]) {
				return nextIndex;
			}
		}
	}
	
	return [NSIndexPath indexPathForRow:0 inSection:COMMENTS];
}

-(NSIndexPath *)getPreviousEnabledIndexPath :(NSIndexPath *)currentIndexPath {
	
	NSInteger currentSection = currentIndexPath.section;
	NSInteger currentRow = currentIndexPath.row;
	
	if (currentSection == PROJECT_INFO) {
		
		for (NSInteger i=currentRow; i > 0 ; i--) {
			NSIndexPath *previousIndex = [NSIndexPath indexPathForRow:i-1 inSection:currentSection];
			G2TimeEntryCellView *cell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:previousIndex];
			if ([cell isUserInteractionEnabled]) {
				return previousIndex;
			}
		}
		
		for (NSUInteger i=[firstSectionfieldsArr count] -1 ; i > 0 ; i--) {
			NSIndexPath *previousIndex = [NSIndexPath indexPathForRow:i inSection:TIME];
			G2TimeEntryCellView *cell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:previousIndex];
			if ([cell isUserInteractionEnabled]) {
				return previousIndex;
			}
		}
	}
	else if (currentSection == TIME) {
		
		for (NSInteger i= currentRow ; i > 0 ; i--) {
			NSIndexPath *previousIndex = [NSIndexPath indexPathForRow:i-1 inSection:TIME];
			G2TimeEntryCellView *cell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:previousIndex];
			if ([cell isUserInteractionEnabled]) {
				return previousIndex;
			}
		}
	}
	return nil;
}

-(void)deselectRowAtIndexPath:(NSIndexPath*)indexPath
{
	[self tableViewCellUntapped:indexPath animated:YES];
}

-(void)animateCellWhichIsSelected
{
	//[self performSelector:@selector(deselectRowAtIndexPath:) withObject:selectedIndexPath afterDelay:0.3]; DE2949 Fade out is too slow
	//[self performSelector:@selector(deselectRowAtIndexPath:) withObject:selectedIndexPath afterDelay:0.0];
    [self resetTableViewUsingSelectedIndex:nil];
    [self performSelector:@selector(deselectRowAtIndexPath:) withObject:selectedIndexPath afterDelay:0.15];//DE3566//Juhi
}

-(void)tableCellTappedAtIndex:(NSIndexPath*)indexPath
{
	[tnewTimeEntryTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
	G2TimeEntryCellView *entryCell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:indexPath];
	[entryCell setBackgroundColor:RepliconStandardBlueColor];//DE3566//Juhi
	if (entryCell.fieldName !=nil) {
		[entryCell.fieldName setTextColor:iosStandaredWhiteColor];
	}
	if (entryCell.fieldButton !=nil) {
		[entryCell.fieldButton setTitleColor:iosStandaredWhiteColor forState:UIControlStateNormal];
	}
	if (entryCell.textField !=nil) {
		[entryCell.textField setTextColor:iosStandaredWhiteColor];
	}
    
    
    [self resetTableViewUsingSelectedIndex:indexPath];
    
}


-(void)tableViewCellUntapped:(NSIndexPath*)indexPath animated:(BOOL)_animated
{
	[tnewTimeEntryTableView deselectRowAtIndexPath:indexPath animated:_animated];
	
	G2TimeEntryCellView *entryCell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:indexPath];
	[entryCell.fieldName setTextColor:RepliconStandardBlackColor];
	[entryCell.fieldButton setTitleColor:NewRepliconStandardBlueColor forState:UIControlStateNormal];//us4065//Juhi
	[entryCell.textField setTextColor:NewRepliconStandardBlueColor];//US4065//Juhi
	[entryCell setBackgroundColor:iosStandaredWhiteColor];
    
	
}

-(void)hideCustomPickerView {
	
	if (customPickerView != nil) {
		[self.customPickerView setHidden:YES];
		[self resetTableViewUsingSelectedIndex:nil];
	}
}

-(void)createFooterView{
    //US4275//Juhi
	float footerHeight = 100;
	if ([self screenMode] == VIEW_TIME_ENTRY || screenMode == VIEW_ADHOC_TIMEOFF) {
		footerHeight = 50;
	}
	
	UIView *tempfooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                      0.0,
                                                                      self.tnewTimeEntryTableView.frame.size.width,
                                                                      footerHeight)];
    self.footerView=tempfooterView;
    
	//[footerView setBackgroundColor:[UIColor redColor]];
	[footerView setBackgroundColor:G2RepliconStandardBackgroundColor];
	[self.tnewTimeEntryTableView setTableFooterView:footerView];
	
	
    UILabel *Commentlabel=[[UILabel alloc] init];
    Commentlabel.text=RPLocalizedString(Comments, @" ") ;
    Commentlabel.textColor=RepliconStandardBlackColor;
    [Commentlabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
    [Commentlabel setBackgroundColor:[UIColor clearColor]];
    Commentlabel.frame=CGRectMake(10.0,
                                  0,
                                  340.0,
                                  30.0);
    [self.footerView addSubview:Commentlabel];
   
    
    if (self.commentsTextView==nil) {
        UITextView *temptextField=[[UITextView alloc]initWithFrame:CGRectMake(10.0,
                                                                              30,
                                                                              301.0,
                                                                              44.0)];
        self.commentsTextView=temptextField;
       
    }
    
    self.commentsTextView.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.commentsTextView.returnKeyType = UIReturnKeyDefault;
    self.commentsTextView.keyboardType = UIKeyboardTypeDefault;
    self.commentsTextView.textAlignment = NSTextAlignmentLeft;
    self.commentsTextView.textColor = RepliconStandardBlackColor;
    [self.commentsTextView setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];
    // For the border and rounded corners
    [[self.commentsTextView layer] setBorderColor:[[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:0.7] CGColor]];
    [[self.commentsTextView layer] setBorderWidth:1.0];
    [[self.commentsTextView layer] setCornerRadius:9];
    [self.commentsTextView setClipsToBounds: YES];
    [self.commentsTextView setScrollEnabled:FALSE];
    [self.commentsTextView setDelegate:self];
    [self.footerView addSubview:self.commentsTextView];
	
    NSString *commentString= nil;
     if (timeSheetEntryObject!=nil)
     {
         commentString= [timeSheetEntryObject comments];
     }
    else
    {
         commentString= [timeOffEntryObject comments];
    }
    
    if (commentString!=nil ) {
        self.commentsTextView.text=[NSString stringWithString:commentString];
        // Setting Frame
        CGRect frame = commentsTextView.frame;
        
        
        
        // Let's make an NSAttributedString first
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:commentString];
        //Add LineBreakMode
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        // Add Font
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:RepliconFontSize_15]} range:NSMakeRange(0, attributedString.length)];
        
        //Now let's make the Bounding Rect
        CGSize expectedLabelSize = [attributedString boundingRectWithSize:CGSizeMake(290.0, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        
        if (expectedLabelSize.width==0 && expectedLabelSize.height ==0) 
        {
            expectedLabelSize=CGSizeMake(11.0, 18.0);
        }
        frame.size.height = expectedLabelSize.height+22;
        if (frame.size.height>44)
        {
            
            self.commentsTextView.frame = frame;
        }
        
        
        if ([self screenMode] == EDIT_TIME_ENTRY ) {
            
            if (!isLockedTimeSheet) {
                deletButton =[UIButton buttonWithType:UIButtonTypeCustom];
                UIImage *img = [G2Util thumbnailImage:DeleteExpenseButton];
                UIImage *imgSel = [G2Util thumbnailImage:DeleteExpenseButtonSelected];
                [deletButton setBackgroundImage:img forState:UIControlStateNormal];
                [deletButton setBackgroundImage:imgSel forState:UIControlStateHighlighted];
                //[deletButton setFrame:CGRectMake(45.0, 35, img.size.width, img.size.height)];
                //[deletButton setTitle:RPLocalizedString(@"Delete Expense",@"") forState:UIControlStateNormal];
                [deletButton setTitle:RPLocalizedString(DELETE,@"Delete") forState:UIControlStateNormal];
                [deletButton setFrame:CGRectMake(40,commentsTextView.frame.origin.y+commentsTextView.frame.size.height+30, img.size.width, img.size.height)];//US4065//Juhi
                deletButton.titleEdgeInsets = UIEdgeInsetsMake(-5.0, 0, 0, 0);
                [deletButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
                deletButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                [footerView addSubview:deletButton];
            }
            
            
        }
        
        else if ([self screenMode] == EDIT_ADHOC_TIMEOFF ) {
            
            
                deletButton =[UIButton buttonWithType:UIButtonTypeCustom];
                UIImage *img = [G2Util thumbnailImage:DeleteExpenseButton];
                UIImage *imgSel = [G2Util thumbnailImage:DeleteExpenseButtonSelected];
                [deletButton setBackgroundImage:img forState:UIControlStateNormal];
                [deletButton setBackgroundImage:imgSel forState:UIControlStateHighlighted];
                //[deletButton setFrame:CGRectMake(45.0, 35, img.size.width, img.size.height)];
                //[deletButton setTitle:RPLocalizedString(@"Delete Expense",@"") forState:UIControlStateNormal];
                [deletButton setTitle:RPLocalizedString(DELETE,@"Delete") forState:UIControlStateNormal];
                [deletButton setFrame:CGRectMake(40,commentsTextView.frame.origin.y+commentsTextView.frame.size.height+30, img.size.width, img.size.height)];//US4065//Juhi
                deletButton.titleEdgeInsets = UIEdgeInsetsMake(-5.0, 0, 0, 0);
                [deletButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
                deletButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                [footerView addSubview:deletButton];
            
            
            
        }

        
        frame=footerView.frame;
        frame.size.height=expectedLabelSize.height +15+140;
        [self.footerView setFrame:frame];
        
        frame=tnewTimeEntryTableView.frame;
        frame.size.height=(frame.size.height-44)+self.commentsTextView.frame.size.height;;
        [self.tnewTimeEntryTableView setFrame:frame];
        
        
        
        
        // Setting ScrollView
        int buttonSpaceHeight=70;
        int spaceForHeader=0.0;
        if ([secondSectionfieldsArray  count]==0) 
        {
                spaceForHeader=53.0;
        }
        else
        {
            spaceForHeader=48.0+48.0;
        }   
        if(isLockedTimeSheet)
        {
            
           if ([self screenMode]==ADD_ADHOC_TIMEOFF || [self screenMode]==EDIT_ADHOC_TIMEOFF || [self screenMode]==VIEW_ADHOC_TIMEOFF)
            {
                int buttonSpaceHeight=70;
                
                if( [self screenMode] == EDIT_ADHOC_TIMEOFF )
                {
                    if ([secondSectionfieldsArray count]==0)
                    {
                        buttonSpaceHeight=151.0;
                    }
                    else
                    {
                        buttonSpaceHeight=145.0;
                    }
                }
                
                int spaceHeader=0.0;
                
                if([secondSectionfieldsArray count]==0)
                {
                    spaceHeader=51.0;
                }
                else 
                {
                    spaceHeader=48.0+48.0;
                }
                self.mainScrollView.contentSize= CGSizeMake(self.view.frame.size.width, ([secondSectionfieldsArray  count]*44)+([firstSectionfieldsArr  count]*44)+35.0+spaceHeader+commentsTextView.frame.size.height+buttonSpaceHeight  );//US4065//Juhi
            }
            else
            {
                self.mainScrollView.contentSize= CGSizeMake(self.view.frame.size.width, ([secondSectionfieldsArray  count]*44)+EXTRA_SPACING_LOCKED_IN_OUT+35.0+spaceForHeader+commentsTextView.frame.size.height+30.0+44.0  );//US4065//Juhi
            }
            
        }
        else 
        {
            
            if( [self screenMode] == EDIT_TIME_ENTRY || [self screenMode] == EDIT_ADHOC_TIMEOFF)
            {
                buttonSpaceHeight=145.0;//US4065//Juhi
            }
            self.mainScrollView.contentSize= CGSizeMake(self.view.frame.size.width, ([secondSectionfieldsArray  count]*44)+([firstSectionfieldsArr  count]*44)+35.0+spaceForHeader+commentsTextView.frame.size.height+buttonSpaceHeight  );//US4065//Juhi
        }
		
		
	}	
    [self.tnewTimeEntryTableView setTableFooterView:footerView];
}

-(void)setNavigationButtonsForScreenMode:(NSInteger )mode{
	if (mode == VIEW_TIME_ENTRY || screenMode == VIEW_ADHOC_TIMEOFF){
//		UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(BACK,@"") 
//																	   style:UIBarButtonItemStyleBordered 
//																	  target:self action:@selector(backButtonAction:)];
//		[self.navigationItem setLeftBarButtonItem:backButton];

		
	}else{
		//1.Add Cancel Button
		UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                      target:self action:@selector(cancelAction:)];
		if (mode == EDIT_TIME_ENTRY) {
			[cancelButton setTag:EDIT_TIME_ENTRY];
		}
        else if (mode == ADD_TIME_ENTRY || mode == VIEW_TIME_ENTRY) 
        {
			[cancelButton setTag:ADD_TIME_ENTRY];
		}
        else if (mode == EDIT_ADHOC_TIMEOFF) {
        [cancelButton setTag:EDIT_ADHOC_TIMEOFF];
        }
       else if (mode == ADD_ADHOC_TIMEOFF || mode == VIEW_ADHOC_TIMEOFF)
       {
        [cancelButton setTag:ADD_ADHOC_TIMEOFF];
        }
		[self.navigationItem setLeftBarButtonItem:cancelButton animated:NO];
		
		
		//2.Add Save Button
        /*		UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
         target:self action:@selector(saveAction:)]; */
		UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(G2SAVE_BTN_TITLE,G2SAVE_BTN_TITLE) style:UIBarButtonItemStylePlain 
																	  target:self action:@selector(saveAction:)];
		
        
        if (mode == EDIT_TIME_ENTRY) {
			[saveButton setTag:EDIT_TIME_ENTRY];
		}
        else if (mode == ADD_TIME_ENTRY || mode == VIEW_TIME_ENTRY) 
        {
			[saveButton setTag:ADD_TIME_ENTRY];
		}
        else if (mode == EDIT_ADHOC_TIMEOFF) {
            [saveButton setTag:EDIT_ADHOC_TIMEOFF];
        }
        else if (mode == ADD_ADHOC_TIMEOFF || mode == VIEW_ADHOC_TIMEOFF)
        {
            [saveButton setTag:ADD_ADHOC_TIMEOFF];
        }

        [self.navigationItem setRightBarButtonItem:saveButton animated:NO];
		
	}
	
}

-(void)deleteAction:(id)sender{
	
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)	{
		
#ifdef PHASE1_US2152
		[G2Util showOfflineAlert];
		return;
#endif
	}
	NSString * message = @"Permanently Delete Time Entry?";
	[self confirmAlert:RPLocalizedString(DELETE,@"Delete") confirmMessage:RPLocalizedString(message,message) title:nil];
}

//dismiss the view controller after delete
-(void)handleDeleteAction {
	
/*	[[NSNotificationCenter defaultCenter] removeObserver:self name:TIME_ENTRY_DELETE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_ENTRY_DELETE_NOTIFICATION object:nil];
    if ([customParentDelegate respondsToSelector:@selector(viewWillAppearFromApprovalsTimeEntry)])
    {
        [(ApprovalsUsersListOfTimeEntriesViewController *)customParentDelegate viewWillAppearFromApprovalsTimeEntry];
    }
	[self.navigationController popViewControllerAnimated:YES];
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)]; 
 */
}

#pragma mark AlertView Methods

-(void) confirmAlert :(NSString *)_buttonTitle confirmMessage:(NSString*) message title :(NSString *)header {
	
	UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:header message:message
															  delegate:self cancelButtonTitle:RPLocalizedString(CANCEL_BTN_TITLE, @"Cancel") otherButtonTitles:_buttonTitle,nil];
	if ([_buttonTitle isEqualToString:RPLocalizedString(DELETE,@"Delete")]) {
		[confirmAlertView setTag:DELETE_TAG];
	}
    //US4660//Juhi
        if ([_buttonTitle isEqualToString:RPLocalizedString(REOPEN,@"Reopen")]) 
    {
        [confirmAlertView setTag:REOPEN_TAG];
    }
    if ([_buttonTitle isEqualToString:RPLocalizedString(UNSUBMIT, @"Unsubmit")]) 
    {
        [confirmAlertView setTag:UNSUBMIT_TAG];
    }
	[confirmAlertView setDelegate:self];
	[confirmAlertView show];
	
	
	
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //US4660//Juhi
	if (buttonIndex > 0 && [alertView tag]== UNSUBMIT_TAG) {
        NSString *sheetIdentity =nil;
		if (timeSheetEntryObject!=nil)
        {
            sheetIdentity = [timeSheetEntryObject sheetId];
        }
		else
        {
            sheetIdentity = [timeOffEntryObject sheetId];
        }
		[[G2RepliconServiceManager timesheetService] unsubmitTimesheetWithIdentity:sheetIdentity];
        if (timeSheetEntryObject!=nil)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveTimeEntryForSheet) 
                                                         name:TIMESHEET_SUBMIT_SUCCESS_NOTIFICATION object:nil];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveTimeOffEntryForSheet) 
                                                         name:TIMESHEET_SUBMIT_SUCCESS_NOTIFICATION object:nil];
        }
		
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:UnSubmittingMessage];
		[self setSelectedSheetIdentity:sheetIdentity];
	}
   
           //US4660//Juhi
    else if(buttonIndex>0 && [alertView tag]== REOPEN_TAG){
		//US4754
        NSString *sheetIdentity =nil;
        if (timeSheetEntryObject!=nil)
        {
            sheetIdentity = [timeSheetEntryObject sheetId];
        }
		else
        {
            sheetIdentity = [timeOffEntryObject sheetId];
        }
        //TODO: show the Reopen view to get Reopen comments 
        
        G2ResubmitTimesheetViewController *resubmitViewController = [[G2ResubmitTimesheetViewController alloc] init];
        
        [resubmitViewController setSheetIdentity:sheetIdentity];
        [resubmitViewController setSelectedSheet:selectedSheet];
        [resubmitViewController setAllowBlankComments:YES];
        [resubmitViewController setActionType:@"ReopenTimesheetEntry"];
        [resubmitViewController setDelegate:self];
        [resubmitViewController setIsSaveEntry:YES];
        [self.navigationController pushViewController:resubmitViewController animated:YES];
        
        
    }
	else if (buttonIndex > 0 && [alertView tag] == DELETE_TAG) {
		if ([[NetworkMonitor sharedInstance] networkAvailable]) {
            if (timeSheetEntryObject!=nil)
            {
                [[G2RepliconServiceManager timesheetService] 
                 sendRequestToDeleteTimeEntry:[timeSheetEntryObject identity] sheetIdentity:[timeSheetEntryObject sheetId]];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchTimeSheetAfterEdit) 
                                                             name:TIME_ENTRY_DELETE_NOTIFICATION object:nil];
            }
            else{
                [[G2RepliconServiceManager timesheetService] 
                 sendRequestToDeleteTimeOffEntry:[timeOffEntryObject identity] sheetIdentity:[timeOffEntryObject sheetId]];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchTimeSheetAfterEdit)
                                                             name:TIMEOFF_ENTRY_DELETE_NOTIFICATION object:nil];
            }
			
			
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:DeletingMessage];
		}
	}
	
}

- (void)alertViewCancel:(UIAlertView *)alertView{
}

#pragma TextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    //[textView becomeFirstResponder];
    //US5053 Ullas M L
    if (lastUsedTextField.tag==TIME_TAG || lastUsedTextField.tag==HOUR_TAG) {
        [self validateTimeEntryFieldValueInCell];
        if (self.isTimeFieldValueBreak) 
        {
            self.isTimeFieldValueBreak=NO;
            return NO;
        }

    }
    
    
    if (screenMode!=VIEW_TIME_ENTRY || screenMode != VIEW_ADHOC_TIMEOFF )
    {
        if (!self.isCommentsTextFieldClicked)
        {
            [self performSelector:@selector(moveToNextScreenFromCommentsTextViewClicked) withObject:nil afterDelay:0.1];
            //[self moveToNextScreenFromCommentsTextViewClicked];
            self.isCommentsTextFieldClicked=TRUE;
        }
        else
        {
             self.isCommentsTextFieldClicked=FALSE;
        }
        
    }
    
    
    return NO;
}
#pragma mark Other methods
//US5053 Ullas M L
-(void)validateTimeEntryFieldValueInCell
{
    
    BOOL shouldCalculateLogicEnabled=NO;
    if (self.screenMode==ADD_ADHOC_TIMEOFF ||self.screenMode==EDIT_ADHOC_TIMEOFF) 
    {
        shouldCalculateLogicEnabled=YES;
    }
    else if (self.screenMode==ADD_TIME_ENTRY ||self.screenMode==EDIT_TIME_ENTRY) 
    {
        if(!self.isInOutFlag && !self.isLockedTimeSheet )
        {
           shouldCalculateLogicEnabled=YES; 
        }
        
    }

    if (shouldCalculateLogicEnabled) 
    {
        
        NSIndexPath *path = [NSIndexPath indexPathForRow:[firstSectionfieldsArr count] -1 inSection:0];
        G2TimeEntryCellView *cell = (G2TimeEntryCellView *)[self.tnewTimeEntryTableView cellForRowAtIndexPath:path];
        NSString *timeText=[cell.textField text];
        
        if (timeText!=nil) 
        {
            
            NSUInteger indexOfMinus;
            
            NSRange rangeForMinus = [timeText rangeOfString:@"-"];
            
            
            if (rangeForMinus.location != NSNotFound)
            {
                rangeForMinus=[timeText rangeOfString:@"-" options:NSBackwardsSearch];
                indexOfMinus=rangeForMinus.location;
                
                
                NSDecimalNumber *decNumRounded = [NSDecimalNumber decimalNumberWithString:timeText];
                NSDecimalNumber *zeroDecimalNumber=[NSDecimalNumber decimalNumberWithString:@"0"];
                if (indexOfMinus!=0 || [decNumRounded compare:zeroDecimalNumber]==NSOrderedSame) 
                {
                    self.isTimeFieldValueBreak=YES;
                    [G2Util errorAlert:@"" errorMessage:RPLocalizedString(INVALID_NEGATIVE_NUMBER_ERROR, @"") ];
                    return;
                }
                
            }

        }

    }
}

-(void)showAllProjectswithMoreButton:(id)object
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TIMESHEETSPROJECTS_FINSIHED_DOWNLOADING object:nil];
    
    BOOL isShowMoreButton=FALSE;
    if ([object isKindOfClass:[NSNotification class]])
    {
         isShowMoreButton = (BOOL)((NSNotification *)object).object;
    }
    else
    {
        isShowMoreButton = [object boolValue];
    }
   
    [self.dataListViewCtrl setSelectedRowIdentity: [timeSheetEntryObject projectIdentity] ];
    [self.dataListViewCtrl setParentDelegate:self];
    [self.dataListViewCtrl setTitleStr:RPLocalizedString(CHOOSE_PROJECT, CHOOSE_PROJECT)];
    NSMutableArray *recentProjectsArray=[supportDataModel getRecentProjectsForClientWithClientId: [timeSheetEntryObject clientIdentity]];
    if([recentProjectsArray count]>0)
    {
        [self.dataListViewCtrl setRecentProjectsArr:recentProjectsArray];
    }
    else
    {
        [self.dataListViewCtrl setRecentProjectsArr:nil];
    }
    
    
	
     NSMutableArray *projectsArr = [supportDataModel getProjectsForClientWithClientId:[timeSheetEntryObject clientIdentity]];
	
                
    
    [self.dataListViewCtrl setListOfItems:projectsArr];
    [self.dataListViewCtrl setAllProjectsArr:projectsArr];
    self.dataListViewCtrl.isShowMoreButton=isShowMoreButton;
    
    if (isShowMoreButton)
    {
        [self.dataListViewCtrl.mainTableView setTableFooterView:self.dataListViewCtrl.footerView];
    }
    
    [self.dataListViewCtrl.mainTableView reloadData];
    

    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay)];
    
}


-(void)showAllClients
{
   
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TIMESHEETSCLIENTS_FINSIHED_DOWNLOADING object:nil];
    
    [self.dataListViewCtrl setSelectedRowIdentity: [timeSheetEntryObject clientIdentity] ];
    [self.dataListViewCtrl setParentDelegate:self];
    [self.dataListViewCtrl setTitleStr:RPLocalizedString(CHOOSE_CLIENT, CHOOSE_CLIENT)];
    
    self.clientsArray = [supportDataModel getAllClientsForTimesheets];
    
    [self.dataListViewCtrl setListOfItems:self.clientsArray];
       
    [self.dataListViewCtrl.mainTableView reloadData];
   
     [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay)];
}

-(void)fetchAllClientsFormDatabaseOrAPI
{
    if (![NetworkMonitor isNetworkAvailableForListener:self]) {
        
        [G2Util showOfflineAlert];
        return;
        
    }
    else
    {
        [[G2RepliconServiceManager timesheetService] sendRequestToGetAllClients];
        
        //                        [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
        
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
        
        G2DataListViewController *tempdataListViewCtrl=[[G2DataListViewController alloc]init];
        self.dataListViewCtrl=tempdataListViewCtrl;
       
        
        [self.dataListViewCtrl setTitleStr:RPLocalizedString(CHOOSE_CLIENT, CHOOSE_CLIENT)];
        
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:TIMESHEETSCLIENTS_FINSIHED_DOWNLOADING object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAllClients)
                                                     name:TIMESHEETSCLIENTS_FINSIHED_DOWNLOADING object:nil];
    }

}

-(void)fetchAllProjectsFormDatabaseOrAPI
{
    if (![NetworkMonitor isNetworkAvailableForListener:self]) {
        
        [G2Util showOfflineAlert];
        return;
        
    }
    else
    {
        [[G2RepliconServiceManager timesheetService] sendRequestToGetAllProjectsByClientID:[timeSheetEntryObject clientIdentity]];
        
        //                        [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
        
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
        
        G2DataListViewController *tempdataListViewCtrl=[[G2DataListViewController alloc]init];
        self.dataListViewCtrl=tempdataListViewCtrl;
       
        
        [self.dataListViewCtrl setTitleStr:RPLocalizedString(CHOOSE_PROJECT, CHOOSE_PROJECT)];
        
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:TIMESHEETSPROJECTS_FINSIHED_DOWNLOADING object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAllProjectswithMoreButton:)
                                                     name:TIMESHEETSPROJECTS_FINSIHED_DOWNLOADING object:nil];
    }
    
}

- (void)userBillingOptionsFinishedDownloading
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TIMESHEETS_USERBILLINGOPTIONS_FINSIHED_DOWNLOADING object:nil];
    G2EntryCellDetails *billingDetails = (G2EntryCellDetails *)[secondSectionfieldsArray objectAtIndex:3];
    [billingDetails setDataSourceArray:[NSMutableArray arrayWithObject:
                                        [self getBillingOptionsDataSourceArray:FALSE]]];
    
    if ([timeSheetEntryObject billingName] != nil) {
        
        int selectedIndex = [self getSelectedBillingRowIndex];
        [billingDetails setComponentSelectedIndexArray:
         [NSMutableArray arrayWithObject:[NSNumber numberWithInt:selectedIndex]]];
    }
    else {
        [billingDetails setComponentSelectedIndexArray:
         [NSMutableArray arrayWithObject:[NSNumber numberWithInt:0]]];
    }
    
    G2TimeEntryCellView *selectedCell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:selectedIndexPath];
    
    [self dataPickerAction :selectedCell senderObj: nil];
    
    if (![[billingDetails fieldType] isEqualToString:MOVE_TO_NEXT_SCREEN]) {
		
		[customPickerView showHideViewsByFieldType:[billingDetails fieldType]];
		[self resetTableViewUsingSelectedIndex:selectedIndexPath];
		[self changeOfSegmentControlState:selectedIndexPath];
        [self updatePickerSelectedValueAtIndexPath:selectedIndexPath :0 :0];
	}
    
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
}

- (void)userBillingOptionsFinishedDownloadingForEditing
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:TIMESHEETS_USERBILLINGOPTIONS_FINSIHED_DOWNLOADING_EDITING object:nil];
    BOOL allowBilling = [permissionsObj billingTimesheet];
	BOOL useBillingInfo = [preferencesObj useBillingInfo];
     NSString *billingName=nil;
    if (allowBilling && useBillingInfo)
    {
        G2EntryCellDetails *billingDetails = (G2EntryCellDetails *)[secondSectionfieldsArray objectAtIndex:3];
        [billingDetails setDataSourceArray:[NSMutableArray arrayWithObject:
                                            [self getBillingOptionsDataSourceArray:FALSE]]];
        
       
        
        
        
        
        billingName =[timeSheetEntryObject billingName] ;
        if (billingName != nil) {
            if (![billingName isEqualToString:@"Non-Billable"] &&
                ![billingName isEqualToString:@"Non Billable"]) {
                NSString *billing = [NSString stringWithFormat:@"Billable (%@)",billingName];
                [billingDetails setFieldValue:billing];
            }else {
                [billingDetails setFieldValue:billingName];
            }
            int selectedIndex = [self getSelectedBillingRowIndex];
            [billingDetails setComponentSelectedIndexArray:
             [NSMutableArray arrayWithObject:[NSNumber numberWithInt:selectedIndex]]];
        }
        else {
            [billingDetails setComponentSelectedIndexArray:
             [NSMutableArray arrayWithObject:[NSNumber numberWithInt:0]]];
        }
        
        
        [secondSectionfieldsArray addObject:billingDetails];
        billingDetails = nil;
    }
    
    
    
    //DE5092//Juhi
    if (![billingName isEqualToString:@"Non-Billable"] &&
        ![billingName isEqualToString:@"Non Billable"]) {
        NSString *billingIdentity = [G2SupportDataModel getBillingTypeByProjRoleName: billingName];
        
        [timeSheetEntryObject setBillingIdentity:billingIdentity];
    }
    
    
    NSNumber *roleId = [supportDataModel getProjectRoleIdForBilling:[timeSheetEntryObject billingIdentity] :[timeSheetEntryObject projectIdentity]];
    if (roleId != nil && ![roleId isKindOfClass:[NSNull class]]) {
        //DO NOTHING HERE
    }
    else
    {
        roleId=[supportDataModel get_role_billing_identity:[timeSheetEntryObject billingIdentity] ];
        if (roleId && ![roleId isKindOfClass:[NSNull class]]) {
            self.disabledBillingOptionsName= [NSString stringWithFormat:@"Billable (%@)",[timeSheetEntryObject billingName]];
        }
    }
    
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
}
//DE8906//JUHI
-(void)updateUDFNumber:(NSString *)UdfNumberEntered{
    G2TimeEntryCellView  *cell = (G2TimeEntryCellView *)[self.tnewTimeEntryTableView cellForRowAtIndexPath:selectedIndexPath];
    G2EntryCellDetails *dtlsObject = (G2EntryCellDetails *)[cell detailsObj];
    int decimals = [dtlsObject decimalPoints];
    NSString *tempValue =	[G2Util formatDecimalPlacesForNumericKeyBoard:[[cell.textField text] doubleValue] withDecimalPlaces:decimals];
    tempValue = [G2Util removeCommasFromNsnumberFormaters:tempValue];
    if (tempValue == nil) {
        tempValue = [cell.textField text];
        
    }else {
        [cell.textField setTextColor:NewRepliconStandardBlueColor];//US4065//Juhi
        [cell.textField setText: tempValue];
    }
    if (tempValue!=nil) {
        //do nothing here
    }
    [dtlsObject setFieldValue:[cell.textField text]];
    
    [secondSectionfieldsArray replaceObjectAtIndex:selectedIndexPath.row withObject:dtlsObject];
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
    self.taskViewController=nil;
    self.addDescriptionViewController=nil;
    self.rowDtls=nil;
    self.tnewTimeEntryTableView=nil;
    self.tableHeader=nil;
    self.progressIndicator=nil;
    self.customPickerView=nil;
    self.footerView=nil;
    self.mainScrollView=nil;
    self.commentsTextView=nil;
}




@end
