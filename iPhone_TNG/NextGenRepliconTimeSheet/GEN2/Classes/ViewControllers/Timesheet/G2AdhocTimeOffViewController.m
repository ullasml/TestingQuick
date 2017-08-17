    //
//  AdhocTimeOffViewController.m
//  Replicon
//
//  Created by Hepciba on 4/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2AdhocTimeOffViewController.h"
#import "RepliconAppDelegate.h"
#import "G2LockedTimeSheetCellView.h"
#import "G2ApprovalsUsersListOfTimeEntriesViewController.h"
#import "G2ResubmitTimesheetViewController.h"//US4754

@implementation G2AdhocTimeOffViewController

@synthesize tnewTimeEntryTableView;
@synthesize tableHeader;
@synthesize firstSectionfieldsArr;
@synthesize secondSectionfieldsArray;
@synthesize sheetStatus;
@synthesize  rowDtls;
@synthesize screenMode;
@synthesize timeOffEntryObject;
@synthesize permissionsObj;
@synthesize preferencesObj;
@synthesize submissionErrorDelegate;
@synthesize isEntriesAvailable;
@synthesize selectedIndexPath;
@synthesize lastUsedTextField;
@synthesize selectedSheetIdentity;
@synthesize addDescriptionViewController;
@synthesize  customPickerView;
@synthesize supportDataModel,timesheetModel;
@synthesize footerView;
@synthesize isFromSave;
@synthesize mainScrollView;
@synthesize disabledDropDownOptionsName;
@synthesize isInOutFlag;
@synthesize  hackIndexPathForInOut;
@synthesize isNotMatching;
@synthesize isFromDoneClicked;
@synthesize isMovingToNextScreen; 
@synthesize isLockedTimeSheet;
@synthesize customParentDelegate;
@synthesize isComment;
@synthesize  timeOffTypesArray;
@synthesize disabledTimeOffTypeName;
//US4275//Juhi
@synthesize commentsTextView;
@synthesize deletButton;
@synthesize selectedSheet;
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

- (id)initWithEntryDetails :(G2TimeOffEntryObject *)entryObj sheetId:(NSString *)_sheetIdentity 
				screenMode :(NSInteger)_screenMode permissionsObj:(id)_permissionObj preferencesObj:(id)_preferencesObj InOutFlag:(BOOL) InOutFlag LockedTimeSheet:(BOOL) LockedTimeSheet delegate:(id)delegate
{
    self = [super init];
	if (self != nil) {
		
		if (entryObj != nil) {
			[self setTimeOffEntryObject:entryObj];
		}
		else {
			[self setTimeOffEntryObject:[G2TimeOffEntryObject createObjectWithDefaultValues]];
		}
		
		if (_sheetIdentity != nil) {
			[timeOffEntryObject setSheetId:_sheetIdentity];
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
    
	
	isFromSave=FALSE;
    
	[self hideCustomPickerView];
    [self.view setUserInteractionEnabled:TRUE];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    countUDF=0;
    
   
    self.isComment=FALSE;
	[self buildFirstSectionFieldsArray];
	[self buildSecondSectionFieldsArray];
	
    //	int extraHeightForLockedInOut=0;
	if (tnewTimeEntryTableView == nil) {
        
        
        

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
        UITableView *tempnewTimeEntryTableView = [[UITableView alloc] initWithFrame:  CGRectMake(0.0,10.0,self.view.frame.size.width,self.view.frame.size.height+(countFrame*44.0)+44.0) 
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
    
    DLog(@"scrollView.contentSize before reset %f",scrollView.contentSize.height);
    //    scrollView.contentSize= CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+(countFrame*60.0));
    [scrollView addSubview:tnewTimeEntryTableView];
    
    self.mainScrollView=scrollView;
    [self.view addSubview:self.mainScrollView];
    
    
    [self.tnewTimeEntryTableView setScrollEnabled:FALSE];
	
	[self.view setBackgroundColor:NewExpenseSheetBackgroundColor];
	
	NSString *toolbarTitleText = @"";
	if (screenMode == EDIT_ADHOC_TIMEOFF) {
		toolbarTitleText = RPLocalizedString( EditTimeOffTitle, EditTimeEntryTitle);
	}else if(screenMode == VIEW_ADHOC_TIMEOFF) {
		toolbarTitleText = RPLocalizedString(ViewTimeOffTitle, TimeEntryTopTitle);
	}else if(screenMode == ADD_ADHOC_TIMEOFF) {
		toolbarTitleText = RPLocalizedString(AddTimeOffTitle, AddNewTimeEntryTitle);
	}
	[G2ViewUtil setToolbarLabel: self withText: toolbarTitleText];
    
	[self setNavigationButtonsForScreenMode:screenMode];
	
	[self createFooterView];
    
    
    if ([self screenMode]!=ADD_ADHOC_TIMEOFF) 
    {
        [self updateComments:self.commentsTextView.text];
    }
    else {
        
        [self updateComments:@""];
    }
    
}




 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 

#pragma mark Table DataSource methods

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor whiteColor]];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    
    if ([self.secondSectionfieldsArray count]==0)
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
		
            return [firstSectionfieldsArr count];
        
        
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
	        return ROW_HEIGHT;
    
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
    

        CellIdentifier = @"Cell";
        cell =(G2TimeEntryCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[G2TimeEntryCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
    
	
	
	UIColor	 *textColor   = NewRepliconStandardBlueColor;//US4065//Juhi
	
	id fieldType = nil;
	id fieldName = nil;
	id fieldValue = nil;
	NSInteger tagValue;
	
	if (screenMode == VIEW_ADHOC_TIMEOFF) {
		//Disable User interaction while viewing an entry
		[cell setUserInteractionEnabled:NO];
		//textColor = RepliconStandardBlackColor;//DE1799
		textColor = [UIColor grayColor];
	}else if (screenMode == EDIT_ADHOC_TIMEOFF) {
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
    
	if (fieldValue == nil) {
		fieldValue = [self.rowDtls defaultValue];
	}
	
	if ([fieldName isEqualToString:TimeFieldName] ) {
		tagValue = TIME_TAG;
	}
    else if ([fieldName isEqualToString:HoursFieldName]) {
		tagValue = HOUR_TAG;
	}
    else {
		tagValue = indexPath.row;
	}
    
    if ([fieldName isEqualToString:TimeInFieldName] || [fieldName isEqualToString:TimeOutFieldName]) {
        if ([cell isKindOfClass:[G2TimeEntryCellView class]]) 
        {
            [(G2TimeEntryCellView *)cell layoutCell:tagValue withType:fieldType withfieldName:fieldName withFieldValue:[self.rowDtls defaultValue] withTextColor:textColor];
        }
        
	}
	else{
        if ([cell isKindOfClass:[G2TimeEntryCellView class]]) 
        {
            [(G2TimeEntryCellView *)cell layoutCell:tagValue withType:fieldType withfieldName:fieldName withFieldValue:fieldValue withTextColor:textColor];
        }
    }
	
    if ([cell isKindOfClass:[G2TimeEntryCellView class]]) 
    {
        [(G2TimeEntryCellView *)cell setTextFieldDelegate:self];
    }

	
	
	
	
	
	//[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];//DE3566//Juhi
	
    if ([cell isKindOfClass:[G2TimeEntryCellView class]]) 
    {
        [[(G2TimeEntryCellView *)cell fieldButton] addTarget:self action:@selector(cellButtonAction:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
	
	
	
	if ([fieldName isEqualToString:Task] && [fieldValue isEqualToString:NoTaskString]) {
		if ([cell isKindOfClass:[G2TimeEntryCellView class]]) 
        {
            [[(G2TimeEntryCellView *)cell fieldButton]  setTitle:RPLocalizedString(NoTaskString, NoTaskString) forState:UIControlStateNormal];
            [(G2TimeEntryCellView *)cell setUserInteractionEnabled:NO];
            [[(G2TimeEntryCellView *)cell fieldButton] setEnabled:NO];
            [[(G2TimeEntryCellView *)cell fieldName]setTextColor:RepliconStandardGrayColor];
            [[(G2TimeEntryCellView *)cell fieldButton] setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
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
    
        
    
    
    
    G2EntryCellDetails *timeOffTypeDetails = [[G2EntryCellDetails alloc] initWithDefaultValue:RPLocalizedString(SelectString, @"")];
    [timeOffTypeDetails setFieldName:TimeOffTypeFieldName];
    [timeOffTypeDetails setFieldType:DATA_PICKER];
    [self setTimeOffTypeDataDetails:timeOffTypeDetails];
    int selectedIndex = [self getSelectedTimeOffTypeRowIndex];
    if ([timeOffEntryObject timeOffCodeType]!=nil && ![[timeOffEntryObject timeOffCodeType] isKindOfClass:[NSNull class]])
    {
        if (selectedIndex==-1) 
        {
            [timeOffTypeDetails setDefaultValue:[timeOffEntryObject timeOffCodeType]];
            disabledTimeOffTypeName=[timeOffEntryObject timeOffCodeType];
        }
        
                
        else if( [timeOffTypesArray count]  >selectedIndex ) {
            [timeOffTypeDetails setDefaultValue:[[timeOffTypesArray objectAtIndex:selectedIndex] objectForKey:@"name"]];
        }
    }
    //US4589//Juhi
    else
    {
        
        if ([self.timeOffTypesArray count]==1) {
            NSDictionary *dict=[self.timeOffTypesArray objectAtIndex:0];
            [timeOffTypeDetails setDefaultValue:[dict objectForKey:@"name"]];
            [self.timeOffEntryObject setTimeOffCodeType:[dict objectForKey:@"name"]];
            [self.timeOffEntryObject setTypeIdentity:[dict objectForKey:@"identity"]];
        } 
    }
    
   
    
    [timeOffTypeDetails setComponentSelectedIndexArray:
     [NSMutableArray arrayWithObject:[NSNumber numberWithInt:selectedIndex]]];
    if ([self.timeOffTypesArray count]>0) {
         [firstSectionfieldsArr addObject:timeOffTypeDetails];
        
        
    }
    
    timeOffTypeDetails = nil;
    
    
	
    
}



-(void)buildSecondSectionFieldsArray {
	
    
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
    
    
    [self buildUDFwithUDFArray:udfsArray];
}


-(void)buildUDFwithUDFArray:(NSArray *)udfsArray
{
    
    if (udfsArray != nil && [udfsArray count] > 0) {
        //From the api we get all the UDFs. We need to filter UDFs based on whether it is applicable to the user.
        
        for (int i=0;  i < [udfsArray count];  i++) {
            NSDictionary *udfDict = [udfsArray objectAtIndex: i];
            NSString *convertedModuleName=nil;
            if ([[udfDict objectForKey:@"moduleName"] isEqualToString:@"TimeOffs" ]) 
            {
                convertedModuleName=@"TimeOff";
            }
            NSString *moduleNameStr=[NSString stringWithFormat:@"%@UDF%d",convertedModuleName,[[udfDict objectForKey:@"fieldIndex"]intValue]+1];
            
            BOOL hasPermissionForUDF=FALSE;
            if ([customParentDelegate isKindOfClass:[G2ApprovalsUsersListOfTimeEntriesViewController class]])
            {
                G2ApprovalsModel *approvalsModel = [[G2ApprovalsModel alloc] init];
                hasPermissionForUDF=[approvalsModel checkUserPermissionWithPermissionName:moduleNameStr andUserId:timeOffEntryObject.userID];
                
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
                    
                    
                    if( [self screenMode] == VIEW_ADHOC_TIMEOFF )
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
                            //if( [self screenMode] != EDIT_ADHOC_TIMEOFF  && [self screenMode] != VIEW_ADHOC_TIMEOFF  )
                            //{
                            [dictInfo setObject:[udfDict objectForKey:@"numericDefaultValue"] forKey:@"defaultValue"];
                            //}
                            
                        }
                        
                    } 
                    
                }
                else if ([[udfDict objectForKey:@"udfType"] isEqualToString:@"Text"])
                {
                    [dictInfo setObject:MOVE_TO_NEXT_SCREEN forKey:@"fieldType"];
                    
                    
                    if( [self screenMode] == VIEW_ADHOC_TIMEOFF )
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
                                //if( [self screenMode] != EDIT_ADHOC_TIMEOFF  && [self screenMode] != VIEW_ADHOC_TIMEOFF )
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
                    
                    
                    if( [self screenMode] == VIEW_ADHOC_TIMEOFF )
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
                                //if( [self screenMode] != EDIT_ADHOC_TIMEOFF && [self screenMode] != VIEW_ADHOC_TIMEOFF   )
                                //{
                                [dictInfo setObject:[G2Util convertPickerDateToString:[NSDate date]] forKey:@"defaultValue"];
                                //}
                                
                            }else
                            {
                                if ([udfDict objectForKey:@"dateDefaultValue"]!=nil && !([[udfDict objectForKey:@"dateDefaultValue"] isKindOfClass:[NSNull class]]))
                                { 
                                    //DE4949 Ullas M L
                                    //if( [self screenMode] != EDIT_ADHOC_TIMEOFF && [self screenMode] != VIEW_ADHOC_TIMEOFF  )
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
                                    //if( [self screenMode] != EDIT_ADHOC_TIMEOFF && [self screenMode] != VIEW_ADHOC_TIMEOFF  )
                                    //{
                                    [dictInfo setObject:dateDefaultValueFormatted forKey:@"defaultValue"];
                                    // }
                                    
                                }
                                else
                                {
                                    //DE4949 Ullas M L
                                    // if( [self screenMode] != EDIT_ADHOC_TIMEOFF && [self screenMode] != VIEW_ADHOC_TIMEOFF  )
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
                    
                    
                    if( [self screenMode] == VIEW_ADHOC_TIMEOFF )
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
                                //if( [self screenMode] != EDIT_ADHOC_TIMEOFF && [self screenMode] != VIEW_ADHOC_TIMEOFF  )
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
                if ([[udfDict objectForKey:@"moduleName"] isEqualToString: TimeOffs_SheetLevel] ) {
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
                    
                    selUDFDataDict=[approvalsModel getSelectedUdfsForEntry:[timeOffEntryObject identity] andType:[udfDict objectForKey:@"moduleName"] andUDFName:[dictInfo objectForKey: @"fieldName" ]];
                    
                   
                }
                else 
                {
                    selUDFDataDict=[timesheetModel getSelectedUdfsForEntry:[timeOffEntryObject identity] andType:[udfDict objectForKey:@"moduleName"] andUDFName:[dictInfo objectForKey: @"fieldName" ]];
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
                            if( ([self screenMode] != EDIT_ADHOC_TIMEOFF && [self screenMode] != VIEW_ADHOC_TIMEOFF) || (selUDFDataDict!=nil && dateToBeUsed!=nil)  )
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
                
                if ([self screenMode]==EDIT_ADHOC_TIMEOFF) 
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


-(int)getSelectedTimeOffTypeRowIndex {
	int selectedIndex =-1;
	NSString *selectedtimeoffTypeName  = [timeOffEntryObject timeOffCodeType];
    if (selectedtimeoffTypeName!=nil && ![selectedtimeoffTypeName isKindOfClass:[NSNull class]]) {
        for (int i=0; i<[timeOffTypesArray count]; ++i) {
            NSRange range = [[[timeOffTypesArray objectAtIndex:i] objectForKey:@"name"] rangeOfString: selectedtimeoffTypeName];
            if(range.length > 0){
                //DLog(@"Range Length %d",range.length);
                selectedIndex = i;
                break;
            }
        }
    }
	
  
	
	return selectedIndex;
}	


-(void)setTimeOffTypeDataDetails:(G2EntryCellDetails *)timeoffTypeDetails {
    
    self.timeOffTypesArray = [supportDataModel getValidTimeOffCodesFromDatabaseForTimeOff];
    NSMutableArray *timeOffTypeListArr=[[NSMutableArray alloc] init];
    for (NSDictionary *dict in timeOffTypesArray) {
        [timeOffTypeListArr addObject:[dict objectForKey:@"name"]];
    }
    [timeoffTypeDetails setDataSourceArray:[NSMutableArray arrayWithObject:
                                         timeOffTypeListArr]];
    
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
	
	if ([fieldType isEqualToString: DATE_PICKER]) {
		[self datePickerAction :selectedCell senderObj: sender]; 
	}
    else if ([fieldType isEqualToString: TIME_PICKER]) {
		[self timePickerAction :selectedCell senderObj: sender]; 
	}
	else if ([fieldType isEqualToString: DATA_PICKER]) {
		[self dataPickerAction :selectedCell senderObj: sender];
	}	
	else if ([fieldType isEqualToString: NUMERIC_KEY_PAD]) {
		[self numericKeyPadAction :selectedCell senderObj: sender];
	}
	else if ([fieldType isEqualToString: MOVE_TO_NEXT_SCREEN]) {isMovingToNextScreen=YES;
		[self moveToNextScreenAction :selectedCell senderObj: sender];
        
	}
	else if ([fieldType isEqualToString: CHECK_MARK]) {
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
		G2CustomPickerView *tempcustomPickerView= [[G2CustomPickerView alloc] initWithFrame:
                                                 CGRectMake(0, 160, 320, 320)];
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
                
               
                    [self.customPickerView.pickerView selectRow:selectedRow inComponent: i animated:YES];
                
				
			}
		}
		
	}
}

-(void)updateFieldAtIndex:(NSIndexPath*)indexPath WithSelectedValues:(NSString *)selectedValue{
	//DLog(@"\nupdateFieldAtIndex::AddeNewTimeEntryViewController");
	G2TimeEntryCellView *cell = (G2TimeEntryCellView *)[self.tnewTimeEntryTableView cellForRowAtIndexPath:indexPath];
	G2EntryCellDetails *detailsObj = (G2EntryCellDetails *)[cell detailsObj];
	
	[detailsObj setFieldValue:selectedValue];
	[cell.fieldButton setTitle:selectedValue forState:UIControlStateNormal];
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
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        if (selectedIndex!=nil) 
        {
            
            
            if (selectedIndex.section == TIME) {
                [self.mainScrollView setFrame:CGRectMake(0, 0, self.view.frame.size.width,
                                                         161.0)];
                
                float height=161.0;
                height=height+([firstSectionfieldsArr count]*ROW_HEIGHT)+([secondSectionfieldsArray count]*ROW_HEIGHT+self.footerView.frame.size.height-150);
                if( [self screenMode] == EDIT_ADHOC_TIMEOFF )
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
                    
                        if (selectedIndex.row==0) {
                            [self.mainScrollView setContentOffset:CGPointMake(0.0,selectedIndex.row*ROW_HEIGHT) animated:YES];
                        }
                        else
                        {
                            [self.mainScrollView setContentOffset:CGPointMake(0.0,(selectedIndex.row*ROW_HEIGHT)-ROW_HEIGHT) animated:YES];
                        }
                    
                    
                    
                }
            }
            
            
            
            else if(selectedIndex.section == PROJECT_INFO){
                //DE5011 Ullas M L
                [self.mainScrollView setFrame:CGRectMake(0, 0, self.view.frame.size.width,
                                                         400.0)];
                
                
                
                float height=380.0;
                height=height+([firstSectionfieldsArr count]*ROW_HEIGHT)+([secondSectionfieldsArray count]*ROW_HEIGHT+self.footerView.frame.size.height-150);
                
                
                
                    if( [self screenMode] == EDIT_ADHOC_TIMEOFF )
                    {
                        height=height+110.0;
                        
                    }
                    else
                    {
                        height=height+35.0;
                    }
                    
                    
                               
                
                
                self.mainScrollView.contentSize=CGSizeMake(self.view.frame.size.width,height);
                
                
                if (![fieldType isEqualToString:MOVE_TO_NEXT_SCREEN]) 
                {
                   [self.mainScrollView setContentOffset:CGPointMake(0.0,(([firstSectionfieldsArr count]*ROW_HEIGHT)+(selectedIndex.row*ROW_HEIGHT))) animated:YES];
                        
                    
                }
                
                
            }                  
            
            
        }
        
        else if (selectedIndex==nil) {
            [self.mainScrollView setFrame:CGRectMake(0,0.0,self.view.frame.size.width,self.view.frame.size.height)];
            
            CGRect rect=self.tnewTimeEntryTableView.frame;
            rect.origin.y=10.0;//US4065//Juhi
            self.tnewTimeEntryTableView.frame=rect;
            CGSize size=self.mainScrollView.contentSize;
            int buttonSpaceHeight=40.0;//US4065//Juhi
            
           
                
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

            
            int spaceHeader=0.0;
            
            if([secondSectionfieldsArray count]==0)
            {
                spaceHeader=51.0;
            }
            else 
            {
                spaceHeader=48.0+48.0;
            }

            
                size.height=([secondSectionfieldsArray  count]*44)+([firstSectionfieldsArr  count]*44)+35.0+spaceHeader+commentsTextView.frame.size.height+buttonSpaceHeight   ;//US4275//Juhi
                
            
            //DE5011 Ullas M L
            if (isFromDoneClicked) {
                //size.height=size.height-40;
                self.mainScrollView.contentSize=size;
                isFromDoneClicked=NO;
            }
            G2TimeEntryCellView *selectedCell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:selectedIndexPath];
            
            NSString *fieldType = [[selectedCell detailsObj] fieldType];
            
            
            if ([fieldType isEqualToString: MOVE_TO_NEXT_SCREEN]) {
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
            [dateFormatter setDateFormat:@"MMMM d yyyy"];
            dateStr=[dateFormatter stringFromDate:fieldValue];
        }
        
        
        [dateFormatter setDateFormat:@"MMMM d yyyy"];
        fieldValue = [dateFormatter dateFromString:dateStr];
        if (fieldValue==nil) {
            [dateFormatter setDateFormat:@"d MMMM yyyy"];
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
    
    if ([detailsObj fieldValue] == RPLocalizedString(SelectString, @"") || [[detailsObj fieldValue] isKindOfClass:[NSNull class]] || [detailsObj fieldValue]==nil ) {
		[self updatePickedDateAtIndexPath:selectedIndexPath :fieldValue];
	}
    
    
	
}

-(void)setValueForDropDownNavigation
{
     G2TimeEntryCellView *cell = (G2TimeEntryCellView *)[self.tnewTimeEntryTableView cellForRowAtIndexPath:selectedIndexPath];
       if ([cell.fieldButton.titleLabel.text isEqualToString:disabledTimeOffTypeName] || [cell.fieldButton.titleLabel.text isEqualToString:RPLocalizedString(NONE_STRING, @"")] ||  [cell.fieldButton.titleLabel.text isEqualToString:self.disabledTimeOffTypeName]  ||  [cell.fieldButton.titleLabel.text isEqualToString:RPLocalizedString(SelectString, @"") ] ||[cell.fieldButton.titleLabel.text isEqualToString:RPLocalizedString(NONE_STRING, @"")]|| [cell.fieldButton.titleLabel.text isEqualToString:self.disabledDropDownOptionsName]) {
        [self updatePickerSelectedValueAtIndexPath:selectedIndexPath :0 :0];
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
	//id fieldValue = [detailsObj fieldValue] == nil ? [detailsObj defaultValue] : [detailsObj fieldValue];
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
		
       
        
		[self.customPickerView setDataSourceArray:nil];
		[self.customPickerView setDataSourceArray:dataArray];
	}
	[self.customPickerView setDateIndexPath:nil];
	[self.customPickerView setOtherPickerIndexPath:selectedIndexPath];
    
	
	if ([detailsObj defaultValue] == RPLocalizedString(SelectString, @"") && [detailsObj fieldValue] == nil) {
		[self handleUpdatesForToolbarActions:selectedIndexPath];
	}
    [self setValueForDropDownNavigation];
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
	
	if (selectedIndexPath.section == PROJECT_INFO && [fieldName isEqualToString:Task]) {
		
		
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

#pragma mark Custom picker delegates

-(void)updatePickedDateAtIndexPath:(NSIndexPath *)dateIndexPath : (NSDate *) selectedDate {
	
	G2TimeEntryCellView *cell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:dateIndexPath];
	G2EntryCellDetails *detailsObj = (G2EntryCellDetails *)[cell detailsObj];
	
	if (dateIndexPath.section == TIME) {
		
        if ([[detailsObj fieldName] isEqualToString: DateFieldName]) 
        {
            [detailsObj setFieldValue:selectedDate];
            [timeOffEntryObject setTimeOffDate:selectedDate];
            [self updateFieldValueForCell:cell withSelectedValue:[G2Util convertPickerDateToString:selectedDate]];
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


-(void)updatePickerSelectedValueAtIndexPath:(NSIndexPath *)otherPickerIndexPath :(int) row :(int)component{
	
	
	G2TimeEntryCellView *cell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:otherPickerIndexPath];
	G2EntryCellDetails *detailsObj = (G2EntryCellDetails *)[cell detailsObj];
//	NSString *fieldName = [detailsObj fieldName];
	NSMutableArray *datasourceArray = [detailsObj dataSourceArray];
	

    
    if ([[detailsObj fieldType] isEqualToString:DATA_PICKER]) {
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
            ///THIS IS FOR TIME OFF TYPE
            else if ([[datasourceArray objectAtIndex:0] isKindOfClass:[NSArray class]]) 
            {
                NSArray *dropDownArray= [datasourceArray objectAtIndex:0];
                [detailsObj setFieldValue:[dropDownArray objectAtIndex:row]];
                
                [firstSectionfieldsArr replaceObjectAtIndex:otherPickerIndexPath.row withObject:detailsObj];
                
                [[detailsObj componentSelectedIndexArray] removeLastObject];
                [[detailsObj componentSelectedIndexArray] addObject:[NSNumber numberWithInt:row]];
                
                [self.timeOffEntryObject setTimeOffCodeType:[dropDownArray objectAtIndex:row]];
                NSDictionary *timeOffCodeDict=[self.timeOffTypesArray objectAtIndex:row];
                [self.timeOffEntryObject setTypeIdentity:[timeOffCodeDict objectForKey:@"identity"]];
                
                [self updateFieldAtIndex:otherPickerIndexPath WithSelectedValues:[dropDownArray objectAtIndex:row]];
                
                
            }

            
            
        }
	}
}

-(void)showCustomPickerIfApplicable:(UITextField *)textField {
	
	//[self tableViewCellUntapped:selectedIndexPath];
	
	NSIndexPath *indexFromField = nil;
	
	if ([textField tag] == TIME_TAG) {
		indexFromField = [NSIndexPath indexPathForRow:1 inSection:TIME];
	}
    else if ([textField tag] == HOUR_TAG) {
		indexFromField = [NSIndexPath indexPathForRow:3 inSection:TIME];
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

                [timeOffEntryObject  setNumberOfHours:[cell.textField text]];
                [detailsObj setFieldValue:[cell.textField text]];
            
            
            
            
            if (self.isNotMatching) {
                if ([cell.textField tag] == HOUR_TAG)
                {
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
        
}

#pragma mark Toolbar Handling Methods

- (void)nextClickAction:(id )button :(NSIndexPath *)currentIndexPath{
	[self tableViewCellUntapped:currentIndexPath  animated:NO];
    //[self setValueForActivitiesonNavigation];
	[self handleUpdatesForToolbarActions :currentIndexPath];
	
	NSIndexPath *nextIndexPath = [self getNextEnabledIndexPath :currentIndexPath];
	
	if (nextIndexPath != nil) {
		[self handleButtonClicks:nextIndexPath :nil];
	}	
}

- (void)previousClickAction:(id )button :(NSIndexPath *)currentIndexPath {
	
	[self tableViewCellUntapped:currentIndexPath  animated:NO];
    //[self setValueForActivitiesonNavigation];
	[self handleUpdatesForToolbarActions :currentIndexPath];
	
	NSIndexPath *previousIndexPath = [self getPreviousEnabledIndexPath :currentIndexPath];
	
	if (previousIndexPath != nil) {
		[self handleButtonClicks:previousIndexPath :nil];
	}
}

- (void)doneClickAction:(id)button :(NSIndexPath *)currentIndexPath {
	isFromDoneClicked=YES;
	[self tableViewCellUntapped:selectedIndexPath  animated:NO];
    if (!isFromSave) {
        [self setValueForDropDownNavigation];
    }
    else
    {
        isFromSave=FALSE;
    }
    [self resetTableViewUsingSelectedIndex:nil];//US4065//Juhi
    
    //    [self handleUpdatesForToolbarActions :currentIndexPath];
    
}



-(void)changeOfSegmentControlState:(NSIndexPath *)indexpath{
	//DLog(@"\nchangeOfSegmentControlState::AddeNewTimeEntryViewController");
	
	if (indexpath.section == TIME) {
		
		if (indexpath.row==0) {
			[self.customPickerView changeSegmentControlButtonsStatus:NO :YES];
		}else {
			[self.customPickerView changeSegmentControlButtonsStatus:YES :YES];
		}
	}	else if (indexpath.section==PROJECT_INFO) {
		if (indexpath.row == [secondSectionfieldsArray count]-1) {
			[self.customPickerView changeSegmentControlButtonsStatus:YES :YES];
		}else {
			 [self.customPickerView changeSegmentControlButtonsStatus:YES :YES];
            
		}
	}
	
}

-(void)handleUpdatesForToolbarActions :(NSIndexPath *)currentIndexPath {
    
	G2TimeEntryCellView *cell = (G2TimeEntryCellView *)[tnewTimeEntryTableView cellForRowAtIndexPath:currentIndexPath];
	G2EntryCellDetails *detailsObj = (G2EntryCellDetails *)[cell detailsObj];
	NSString *fieldType = [detailsObj fieldType];
//	NSString *fieldName = [detailsObj fieldName];
	if (currentIndexPath.section == TIME) {
		
		if ([fieldType isEqualToString: NUMERIC_KEY_PAD]) {
            

                [timeOffEntryObject setNumberOfHours:[cell.textField text]];
            
            
			
			[cell.textField resignFirstResponder];
		}
	}
	else if (currentIndexPath.section == PROJECT_INFO) 
    {
		
		if ([fieldType isEqualToString: DATA_PICKER]) {
		}
		else if ([fieldType isEqualToString: NUMERIC_KEY_PAD]) {
		}
	}
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


#pragma mark Save Entry Methods

-(void)cancelAction:(id)sender{
	
	[self tableViewCellUntapped:selectedIndexPath  animated:NO];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	if ([sender tag] == EDIT_ADHOC_TIMEOFF) {
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
    isFromSave=TRUE;
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
	
    
    if ([timeOffEntryObject timeOffCodeType]==nil && ![[timeOffEntryObject timeOffCodeType] isKindOfClass:[NSNull class]]) 
    {
        [G2Util errorAlert:nil errorMessage:VALIDATION_TIMEOFF_TYPE_REQUIRED];
        return;
    }
    
	if ([sender tag] == EDIT_ADHOC_TIMEOFF) {
		//DLog(@"Editing ::AddNewTimeEntryViewController");
		if ([Reachability isNetworkAvailable]== YES) {

            [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(SavingMessage, "")];
			[self sendOnlineRequestToEditTimeEntry];
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
				[self handleAddTimeEntryWithSheetIdentity];
			}
			else {
				//DLog(@"sheetID is nil fetch new sheet");
				[self handleAddTimeOffEntryWithoutSheetIdentity];
			}
			
		}
	}
}

-(void)buildUDFDictionary
{
    
    NSUInteger loopCount=[self.secondSectionfieldsArray count]- countUDF;
    
    for (NSUInteger i=loopCount; i<[self.secondSectionfieldsArray count]; i++) {
        G2EntryCellDetails *cellDetails=[self.secondSectionfieldsArray objectAtIndex:i];
        if ([cellDetails udfModule]!=nil || ![[cellDetails udfModule] isKindOfClass:[NSNull class] ]) 
        {
            if ([[cellDetails udfModule] isEqualToString:@"TimeOffs"]) {
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
    
    
    
    if ([udfType isEqualToString:@"UDF" ]) 
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
		[timeOffEntryObject setIsModified:YES];
		[timesheetModel saveTimeOffEntryForSheetWithObject :timeOffEntryObject editStatus:OFFLINE_CREATE_STATUS];
		[timesheetModel updateSheetModifyStatus:[timeOffEntryObject sheetId] status:YES];
		[self showListOfTimeEntries];
	}
	
}

/*
 * This method handles actions related to adding an entry without sheetId
 */

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


-(void)sendOnlineRequestToEditTimeEntry{
	//DLog(@"sendOnlineRequestToEditTimeEntry::AddNewTimeEntryViewController");
	
    
    
        [[G2RepliconServiceManager timesheetService] sendRequestToEditTheTimeOffEntryDetailsWithUserData:timeOffEntryObject];
    
	
	
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self selector:@selector(popToTimeEntriesContentsPage) 
	 name:TIMEOFF_ENTRY_EDITED_NOTIFICATION object:nil];
}

-(void)popToTimeEntriesContentsPage{
	
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:TIMEOFF_ENTRY_EDITED_NOTIFICATION object:nil];
	NSString *status = @"";
	[timesheetModel updateEditedTimeOffEntry:timeOffEntryObject andStatus:status];
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
	 removeObserver:self name:FETCH_TIMEOFF_FOR_ENTRY_DATE object:nil];
	G2PermissionsModel *permission=[[G2PermissionsModel alloc]init];
    BOOL reopenPermission=[permission checkUserPermissionWithPermissionName:@"ReopenTimesheet"];//US4660//Juhi
	NSString *fetchedSheetId = ((NSNotification *)notificationObject).object;
	//update the entry object with fetched sheetId
	//DLog(@"fetchedSheetId %@",fetchedSheetId);
	if (fetchedSheetId != nil && ![fetchedSheetId isKindOfClass:[NSNull class]]) {
		
		NSMutableArray *sheetDetails = [timesheetModel getTimeSheetInfoForSheetIdentity:fetchedSheetId];
		if (sheetDetails != nil && [sheetDetails count] > 0) {
			
			[timeOffEntryObject setSheetId:fetchedSheetId];
            //US4660//Juhi
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
				[self saveTimeEntryForSheet];
				[self setSelectedSheetIdentity:[NSString stringWithFormat:@"%@",[timeOffEntryObject sheetId]]];
				[timeOffEntryObject setSheetId:nil];
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
                    [timeOffEntryObject setSheetId:nil];
                }
            }
			else {
				[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
                
                [G2Util errorAlert:@"" errorMessage:[NSString stringWithFormat:@"%@ \n %@",RPLocalizedString(UNSUBMIT_ADD_TITLE,""),RPLocalizedString(SELECT_ANOTHER_DATE_MESSAGE,"")]];//DE4050//Juhi
				[timeOffEntryObject setSheetId:nil];
			}
			
			
		}
	}

}

-(void)saveTimeEntryForSheet {
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

-(void)fetchTimeSheetAfterSave {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_ENTRY_SAVED_NOTIFICATION object:nil];
    
	[[G2RepliconServiceManager timesheetService] 
	 sendRequestToFetchTimesheetByIdWithEntries:selectedSheetIdentity];
	[[NSNotificationCenter defaultCenter] 
	 addObserver:self selector:@selector(showListOfTimeEntries) name:FETCH_TIMESHEET_BY_IDENTITY object:nil];
}
-(void)showListOfTimeEntries {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:FETCH_TIMESHEET_BY_IDENTITY object:nil];
	if (isEntriesAvailable) {
		[self.navigationController dismissViewControllerAnimated:YES completion:nil];
	}else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"NEW_DIRECT_ENTRY_SAVED" object:nil];
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
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
    
    if (screenMode==EDIT_ADHOC_TIMEOFF) {
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
    [timeOffEntryObject setComments:commentsEntered];
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
    if (screenMode == VIEW_ADHOC_TIMEOFF) 
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
        if (frame.size.height>ROW_HEIGHT)
        {
            
            self.commentsTextView.frame = frame;
        }
        
        
        if ([self screenMode] == EDIT_ADHOC_TIMEOFF) {
            
           
                
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
	
	NSUInteger currentSection = currentIndexPath.section;
	NSUInteger currentRow = currentIndexPath.row;
	
	if (currentSection == TIME) {
		
		for (NSUInteger i=currentRow; i < [firstSectionfieldsArr count] -1 ; i++) {
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
		
		for (NSUInteger i=currentRow; i < [secondSectionfieldsArray count] -1 ; i++) {
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
	
	NSUInteger currentSection = currentIndexPath.section;
	NSUInteger currentRow = currentIndexPath.row;
	
	if (currentSection == PROJECT_INFO) {
		
		for (NSUInteger i=currentRow; i > 0 ; i--) {
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
		
		for (NSUInteger i= currentRow ; i > 0 ; i--) {
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
	if ([self screenMode] == VIEW_ADHOC_TIMEOFF) {
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
	
    
    
    NSString *commentString= [timeOffEntryObject comments];
    
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
        
        
        if ([self screenMode] == EDIT_ADHOC_TIMEOFF) {
            
           
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
        frame.size.height=expectedLabelSize.height +15+100;
        [self.footerView setFrame:frame];
        
        frame=tnewTimeEntryTableView.frame;
        frame.size.height=(frame.size.height-44)+self.commentsTextView.frame.size.height;;
        [self.tnewTimeEntryTableView setFrame:frame];
        
        
        
        
        // Setting ScrollView
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
    [self.tnewTimeEntryTableView setTableFooterView:footerView];
}

-(void)setNavigationButtonsForScreenMode:(NSInteger )mode{
	if (mode == VIEW_ADHOC_TIMEOFF){
        //		UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(BACK,@"") 
        //																	   style:UIBarButtonItemStyleBordered 
        //																	  target:self action:@selector(backButtonAction:)];
        //		[self.navigationItem setLeftBarButtonItem:backButton];
        
		
	}else{
		//1.Add Cancel Button
		UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                      target:self action:@selector(cancelAction:)];
		if (mode == EDIT_ADHOC_TIMEOFF) {
			[cancelButton setTag:EDIT_ADHOC_TIMEOFF];
		}else {
			[cancelButton setTag:ADD_ADHOC_TIMEOFF];
		}
		[self.navigationItem setLeftBarButtonItem:cancelButton animated:NO];
		
		
		//2.Add Save Button
        /*		UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
         target:self action:@selector(saveAction:)]; */
		UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(G2SAVE_BTN_TITLE,G2SAVE_BTN_TITLE) style:UIBarButtonItemStylePlain 
																	  target:self action:@selector(saveAction:)];
		if (mode == EDIT_ADHOC_TIMEOFF) {
			
			[saveButton setTag:EDIT_ADHOC_TIMEOFF];
		}else {
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
	NSString * message = DELETE_TIMEOFF_MSG;
	[self confirmAlert:RPLocalizedString(DELETE,@"Delete") confirmMessage:RPLocalizedString(message,message) title:nil];
}

//dismiss the view controller after delete
-(void)handleDeleteAction {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:TIMEOFF_ENTRY_DELETE_NOTIFICATION object:nil];
    if ([customParentDelegate respondsToSelector:@selector(viewWillAppearFromApprovalsTimeEntry)])
    {
        [(G2ApprovalsUsersListOfTimeEntriesViewController *)customParentDelegate viewWillAppearFromApprovalsTimeEntry];
    }
	[self.navigationController popViewControllerAnimated:YES];
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)]; 
}

#pragma mark AlertView Methods

-(void) confirmAlert :(NSString *)_buttonTitle confirmMessage:(NSString*) message title :(NSString *)header {
	
	UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:header message:message
															  delegate:self cancelButtonTitle:RPLocalizedString(CANCEL_BTN_TITLE, @"Cancel") otherButtonTitles:_buttonTitle,nil];
	if ([_buttonTitle isEqualToString:RPLocalizedString(DELETE,@"Delete")]) {
		[confirmAlertView setTag:DELETE_TAG];
	}
    //US4660//Juhi
    if ([_buttonTitle isEqualToString:RPLocalizedString(REOPEN,@"Reopen")]) {
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
		NSString *sheetIdentity = [timeOffEntryObject sheetId];
		[[G2RepliconServiceManager timesheetService] unsubmitTimesheetWithIdentity:sheetIdentity];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveTimeEntryForSheet) 
													 name:TIMESHEET_SUBMIT_SUCCESS_NOTIFICATION object:nil];
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:UnSubmittingMessage];
		[self setSelectedSheetIdentity:sheetIdentity];
	}
    //US4660//Juhi
    else if (buttonIndex > 0 && [alertView tag] == REOPEN_TAG) {
		NSString *sheetIdentity = [timeOffEntryObject sheetId];
		//US4754
        //TODO: show the Reopen view to get Reopen comments 
        
        G2ResubmitTimesheetViewController *resubmitViewController = [[G2ResubmitTimesheetViewController alloc] init];
        
        [resubmitViewController setSheetIdentity:sheetIdentity];
        [resubmitViewController setSelectedSheet:self.selectedSheet];
        [resubmitViewController setAllowBlankComments:YES];
        [resubmitViewController setActionType:@"ReopenTimesheetEntry"];
        [resubmitViewController setDelegate:self];
        [resubmitViewController setIsSaveEntry:YES];
        [self.navigationController pushViewController:resubmitViewController animated:YES];
        
       

	}

	else if (buttonIndex > 0 && [alertView tag] == DELETE_TAG) {
		if ([[NetworkMonitor sharedInstance] networkAvailable]) {
			[[G2RepliconServiceManager timesheetService] 
			 sendRequestToDeleteTimeOffEntry:[timeOffEntryObject identity] sheetIdentity:[timeOffEntryObject sheetId]];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeleteAction) 
														 name:TIMEOFF_ENTRY_DELETE_NOTIFICATION object:nil];
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
    
    if (screenMode!=VIEW_ADHOC_TIMEOFF) {
        
        [self performSelector:@selector(moveToNextScreenFromCommentsTextViewClicked) withObject:nil afterDelay:0.1];
        //[self moveToNextScreenFromCommentsTextViewClicked];
    }
    
    
    return NO;
}
#pragma mark Other methods

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.addDescriptionViewController=nil;
    self.rowDtls=nil;
    self.tnewTimeEntryTableView=nil;
    self.tableHeader=nil;
    
    self.customPickerView=nil;
    self.footerView=nil;
    self.mainScrollView=nil;
    self.commentsTextView=nil;
}





@end
