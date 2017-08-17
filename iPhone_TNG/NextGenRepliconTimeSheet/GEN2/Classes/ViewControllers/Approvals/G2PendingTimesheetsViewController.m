//
//  PendingTimesheetsViewController.m
//  Replicon
//
//  Created by Dipta Rakshit on 2/7/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "G2PendingTimesheetsViewController.h"
#import "G2Constants.h"
#import "G2ViewUtil.h"
#import "RepliconAppDelegate.h"
#import "G2ApprovalsNavigationController.h"


@implementation G2PendingTimesheetsViewController
@synthesize  approvalpendingTSTableView;
@synthesize sectionHeaderlabel;
@synthesize  sectionHeader;
@synthesize listOfUsersArr;
@synthesize  selectedIndexPath;
@synthesize scrollViewController;
@synthesize addDescriptionViewController;
@synthesize  timeSheetsArray;
@synthesize leftButton;
@synthesize selectedSheetsIDsArr;
@synthesize isnotFirstTimeLoad;
@synthesize  msgLabel;
@synthesize isApproveRejectBtnClicked;
@synthesize totalRowsCount;
@synthesize isFromCommentsScreen;
@synthesize topToolbarLabel;

enum  {
	APPROVE_BUTTON_TAG_G2,
	REJECT_BUTTON_TAG_G2,
	COMMENTS_TEXTVIEW_TAG_G2,
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
    if ([self.listOfUsersArr count]==0) {
        [self.approvalpendingTSTableView.tableFooterView  setHidden:TRUE];
        
        if (!isnotFirstTimeLoad)
        {
            [self showMessageLabel];
        }
        
        
        
    }
    
    if (isnotFirstTimeLoad) {
        [self refreshTableView];
    }
    else
    {
        [self updateTabBarItemBadge]; 
    }
    
    if (!isnotFirstTimeLoad) {
        isnotFirstTimeLoad=TRUE;
    }
    
    [checkOrClearAllBtn setHidden:NO];
    [self.navigationController.navigationBar addSubview:self.topToolbarLabel]; 
    [self.navigationController.navigationBar addSubview:checkOrClearAllBtn];
    [self showOrHideMoreButton];
    
}

-(void)showOrHideMoreButton
{
    
    
    int recentTimesheetsCount=[[[NSUserDefaults standardUserDefaults] objectForKey:APPROVAL_RECENT_DOWNLOADED_TIMESHEETS_COUNT] intValue];
    
    if (recentTimesheetsCount!=[[[G2AppProperties getInstance]getAppPropertyFor:@"NextRecentApprovalsPendingSheetsCount"] intValue])
    {
        
        NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
        int badgeValue=[[standardUserDefaults objectForKey:@"NumberOfTimesheetsPendingApproval"]intValue];
        [standardUserDefaults setObject:[NSNumber numberWithInt:badgeValue] forKey:APPROVAL_LAST_DOWNLOADED_TIMESHEETS_COUNT];
        [standardUserDefaults synchronize];
        
        G2ApprovalTablesFooterView *footerView=(G2ApprovalTablesFooterView *)self.approvalpendingTSTableView.tableFooterView;
        [footerView hideMoreButton];
        self.approvalpendingTSTableView.tableFooterView = footerView;
    }
    else
    {
        G2ApprovalTablesFooterView *footerView=(G2ApprovalTablesFooterView *)self.approvalpendingTSTableView.tableFooterView;
        [footerView showMoreButton];
        self.approvalpendingTSTableView.tableFooterView = footerView;
        
    }
}
-(void)nextMostRecentTimesheetsReceived
{
    [[NSNotificationCenter defaultCenter]
	 removeObserver:self name:APPROVAL_TIMESHEETS_RECEIVED_NOTIFICATION object:nil];
    [self showOrHideMoreButton];
    G2ApprovalsModel *approvalsModel=[[G2ApprovalsModel alloc]init];
    NSMutableArray *pendingTimesheetsArr=[approvalsModel getAllTimeSheetsGroupedByDueDates];
    self.listOfUsersArr=pendingTimesheetsArr;
    
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
    [self refreshTableView];
}

-(void)showMessageLabel
{
    checkOrClearAllBtn.enabled=FALSE;
    UIImage *pressedImage=[G2Util thumbnailImage:G2CHECK_ALL_PRESSED_IMAGE];
    [checkOrClearAllBtn setTag:CHECK_ALL_BUTTON_TAG];
    [checkOrClearAllBtn setImage:pressedImage forState:UIControlStateNormal];
    
    [self.msgLabel removeFromSuperview];
    UILabel *tempMsgLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 120, 320, 80)];
    tempMsgLabel.text=RPLocalizedString(APPROVAL_NO_TIMESHEETS_PENDING_VALIDATION, APPROVAL_NO_TIMESHEETS_PENDING_VALIDATION);
    self.msgLabel=tempMsgLabel;
    self.msgLabel.backgroundColor=[UIColor clearColor];
    self.msgLabel.numberOfLines=2;
    self.msgLabel.textAlignment=NSTextAlignmentCenter;
    self.msgLabel.font=[UIFont fontWithName:RepliconFontFamily size:16];
    
    [self.view addSubview:self.msgLabel];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]
	 removeObserver:self name:ALL_PENDING_APPROVAL_TIMESHEETS_ENTRIES_SERVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]
	 removeObserver:self name:APPROVAL_TIMESHEETS_APPROVAL_REJECT_DONE_NOTIFICATION object:nil];
    
    //DE5784
    [[NSNotificationCenter defaultCenter]removeObserver:self name:APPROVAL_TIMESHEET_DELETED_NOT_WAITINGFORAPPROVAL object:nil]; 
    [self.topToolbarLabel removeFromSuperview]; 
    [checkOrClearAllBtn setHidden:YES];
}
//DE5908 Ullas M L
-(void)intialiseTableViewWithFooter
{
    self.totalRowsCount=0;
    //Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    CGRect frame;
    if (version>=7.0)
    {
        frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
    }
    else{
        frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-95);
    }
    UITableView *tempapprovalpendingTSTableView=[[UITableView alloc]initWithFrame:frame style:UITableViewStylePlain];
    self.approvalpendingTSTableView=tempapprovalpendingTSTableView;
    
	
	approvalpendingTSTableView.delegate=self;
	approvalpendingTSTableView.dataSource=self;
    approvalpendingTSTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
	[self.view addSubview:approvalpendingTSTableView];
	UIView *bckView = [UIView new];
	[bckView setBackgroundColor:G2RepliconStandardBackgroundColor];
	[approvalpendingTSTableView setBackgroundView:bckView];
	
    
    G2ApprovalTablesFooterView *footerView=[[G2ApprovalTablesFooterView alloc]init];
    self.approvalpendingTSTableView.tableFooterView = footerView;
    footerView.delegate=self;
    [footerView showMoreButton];
    
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
    
    [self.view setBackgroundColor:G2RepliconStandardBackgroundColor];
    
    [self intialiseTableViewWithFooter];//DE5908 Ullas M L
    
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
        
        UIBarButtonItem *templeftButton1 = [[UIBarButtonItem alloc]initWithImage:homeButtonImage1 style:UIBarButtonItemStylePlain
                                                                          target:self action:@selector(goBack:)];
        self.leftButton=templeftButton1;
        [self.navigationItem setLeftBarButtonItem: self.leftButton animated:NO];
       
        
    }
    
    //    [ViewUtil setToolbarLabel: self withText: RPLocalizedString(PENDING_TIMESHEETS, PENDING_TIMESHEETS)];
    
    UILabel *temptopToolbarLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 11, 170,20)];
    self.topToolbarLabel=temptopToolbarLabel;
    
    [self.topToolbarLabel setNumberOfLines:0];
    [self.topToolbarLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [self.topToolbarLabel setFont:[UIFont boldSystemFontOfSize: RepliconFontSize_16]];
    [self.topToolbarLabel setTextAlignment:NSTextAlignmentCenter];
    [self.topToolbarLabel setBackgroundColor:[UIColor clearColor]];
    [self.topToolbarLabel setTextColor:[UIColor whiteColor]];
    [self.topToolbarLabel setTextAlignment: NSTextAlignmentCenter];
    [self.topToolbarLabel setShadowColor:[UIColor blackColor]];//US4065//Juhi
    [self.topToolbarLabel setShadowOffset:CGSizeMake(0, -1)];//emboss effect (0,1)
    
    [self.topToolbarLabel setText: RPLocalizedString(PENDING_TIMESHEETS, PENDING_TIMESHEETS)];
    
    
    
    if (appDelegate.isLockedTimeSheet) 
    {
        self.navigationItem.hidesBackButton = TRUE;;
    }
    
    
    NSMutableArray *tempselectedSheetsIDsArr=[[NSMutableArray alloc]init];
    self.selectedSheetsIDsArr=tempselectedSheetsIDsArr;
   
    
    
    
    UIImage *unPressedImage=[G2Util thumbnailImage:G2CHECK_ALL_UNPRESSED_IMAGE];
    UIImage *pressedImage=[G2Util thumbnailImage:G2CHECK_ALL_PRESSED_IMAGE];
    UIButton *tempcheckClearBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    checkOrClearAllBtn=tempcheckClearBtn;
    checkOrClearAllBtn.frame=CGRectMake(252,7, unPressedImage.size.width, unPressedImage.size.height);
    [checkOrClearAllBtn setTag:CHECK_ALL_BUTTON_TAG];
    [checkOrClearAllBtn setImage:unPressedImage forState:UIControlStateNormal];
    [checkOrClearAllBtn setImage:pressedImage forState:UIControlStateHighlighted];
    [checkOrClearAllBtn addTarget:self action:@selector(clearORSelectAll:) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect frame= self.navigationItem.titleView.frame;
    frame.origin.x= frame.origin.x+5.0;
    self.navigationItem.titleView.frame=frame;
    
}




#pragma mark -
#pragma mark - UITableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    self.totalRowsCount=0;
    return [self.listOfUsersArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 59.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSMutableArray *sectionedUsersArr=[self.listOfUsersArr objectAtIndex:section];
    self.totalRowsCount=self.totalRowsCount+[sectionedUsersArr count];
    return [sectionedUsersArr count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	static NSString *CellIdentifier = @"PendingApprovalsCellIdentifier";
	
	cell = (G2ApprovalsCheckBoxCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        cell = [[G2ApprovalsCheckBoxCustomCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		
        cell.backgroundView          = [[UIImageView alloc] init];
        
        
        UIImage *rowBackground       = [G2Util thumbnailImage:cellBackgroundImageView];
        ((UIImageView *)cell.backgroundView).image = rowBackground;
        
        
	}
	NSString		*leftStr =@"";
	NSString		*rightStr = @"";
	
    NSMutableArray *sectionedUsersArr=[self.listOfUsersArr objectAtIndex:indexPath.section];
    
    NSMutableDictionary *userDict=[sectionedUsersArr objectAtIndex:indexPath.row];
    leftStr   = [NSString stringWithFormat:@"%@ %@", [userDict objectForKey:@"user_fname"] ,[userDict objectForKey:@"user_lname"]]; 
    rightStr   = [userDict objectForKey:@"TotalTime"];  
    
    
    //[cell setCommonCellDelegate:self];
    
    [cell setDelegate:self];
    
    BOOL mealReq=FALSE;
    BOOL timeOffReq=FALSE;
    BOOL overTimeReq=FALSE;
    BOOL regularReq=FALSE;
    
    NSString *overTime=@"";
    NSString *meal=@"";
    NSString *timeOff=@"";
    NSString *regular=@"";
    
    
    if ([userDict objectForKey:@"timesheetMealBreakPenaltiesCount"]!=nil && ![[userDict objectForKey:@"timesheetMealBreakPenaltiesCount"] isKindOfClass:[NSNull class]] && [[userDict objectForKey:@"timesheetMealBreakPenaltiesCount"]floatValue]!=0 ) 
    {
        mealReq=TRUE;
        meal=[NSString stringWithFormat:@"%@ %@.00",RPLocalizedString(Meal, @""),[userDict objectForKey:@"timesheetMealBreakPenaltiesCount"]];
    }
    if ([userDict objectForKey:@"TotalTimeOff"]!=nil && ![[userDict objectForKey:@"TotalTimeOff"] isKindOfClass:[NSNull class]] && [[userDict objectForKey:@"TotalTimeOff"]floatValue]!=0 ) 
    {
        timeOffReq=TRUE; 
        timeOff=[NSString stringWithFormat:@"%@ %@",RPLocalizedString(Off, @""), [userDict objectForKey:@"TotalTimeOff"]];
    }
    if ([userDict objectForKey:@"TotalOverTime"]!=nil && ![[userDict objectForKey:@"TotalOverTime"] isKindOfClass:[NSNull class]] && [[userDict objectForKey:@"TotalOverTime"]floatValue]!=0 ) 
    {
        overTimeReq=TRUE;
        overTime=[NSString stringWithFormat:@"%@ %@",RPLocalizedString(OT, @""), [userDict objectForKey:@"TotalOverTime"]];
    }
    if ([userDict objectForKey:@"TotalRegularTime"]!=nil && ![[userDict objectForKey:@"TotalRegularTime"] isKindOfClass:[NSNull class]] && [[userDict objectForKey:@"TotalRegularTime"]floatValue]!=0 ) 
    {
        regularReq=TRUE;
        regular=[NSString stringWithFormat:@"%@ %@",RPLocalizedString(Reg, @""),[userDict objectForKey:@"TotalRegularTime"]];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    
    
    //    [cell createCellLayoutWithParams:leftStr rightstr:rightStr hairlinerequired:NO radioButtonTag:indexPath.row];   
    [cell createCellLayoutWithParams:leftStr rightstr:rightStr hairlinerequired:NO radioButtonTag:indexPath.row overTimerequired:overTimeReq mealrequired:mealReq timeOffrequired:timeOffReq regularRequired:regularReq overTimeStr:overTime mealStr:meal timeOffStr:timeOff regularStr:regular]; 
    
    UIImage *radioButtonImage=nil;
    if ([self.selectedSheetsIDsArr containsObject:[userDict objectForKey:@"identity"]]) 
    {
        radioButtonImage = [G2Util thumbnailImage:ApproverCheckBoxSelectedImage];
    }
    else
    {
        radioButtonImage = [G2Util thumbnailImage:ApproverCheckBoxDeselectedImage];
    }
    
    [cell.radioButton setImage:radioButtonImage forState:UIControlStateNormal];
    [cell.radioButton setImage:radioButtonImage forState:UIControlStateHighlighted];
    
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
	return cell;
	
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section    // fixed font style. use custom view (UILabel) if you want something different
{
    NSMutableArray *sectionedUsersArr=[self.listOfUsersArr objectAtIndex:section];
    
    NSMutableDictionary *userDict=[sectionedUsersArr objectAtIndex:0];
    
    NSString *headerTitle=[userDict objectForKey:@"approval_dueDate"];
    
    
    
    
	return [NSString stringWithFormat:@"Due: %@", headerTitle];
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section   // custom view for header. will be adjusted to default or specified header height
{
	//DLog(@"\n viewForHeaderInSection::ListOfTimeEntriesViewController============>\n");
	NSString *sectionTitle=[self tableView:tableView titleForHeaderInSection:section];
    
	UILabel *tempsectionHeaderlabel=[[UILabel alloc]initWithFrame:CGRectMake(12.0,
                                                                             0.0, 
                                                                             240.0, 
                                                                             20.0)];
    self.sectionHeaderlabel=tempsectionHeaderlabel;
    
    
	sectionHeaderlabel.backgroundColor=[UIColor clearColor];
	sectionHeaderlabel.text=sectionTitle;
	[sectionHeaderlabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]];
	[sectionHeaderlabel setTextColor:[UIColor whiteColor]];//RepliconTimeEntryHeaderTextColor
	[sectionHeaderlabel setTextAlignment:NSTextAlignmentLeft];
	
	
	
	UIImageView *tempsectionHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,
                                                                                   0.0,
                                                                                   320.0,
                                                                                   25.0)];
    self.sectionHeader=tempsectionHeader;
    
	[sectionHeader setImage:[G2Util thumbnailImage:G2TimeSheets_ContentsPage_Header]];
	[sectionHeader setBackgroundColor:[UIColor clearColor]];
	[sectionHeader addSubview:sectionHeaderlabel];	
	
	
	
	return sectionHeader;
}

-(void)viewAllTimeEntriesScreen
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ALL_PENDING_APPROVAL_TIMESHEETS_ENTRIES_SERVED_NOTIFICATION object:nil];
    
    NSMutableArray *sectionedUsersArr=[self.listOfUsersArr objectAtIndex:selectedIndexPath.section];
    NSMutableDictionary *userDict=[sectionedUsersArr objectAtIndex:selectedIndexPath.row];
    [self displayAllTimeSheetsBySheetID: userDict];
    
    NSUInteger count=0;
    NSMutableArray *allPendingTSArray=[NSMutableArray array];
    for (int i=0; i<[self.listOfUsersArr count]; i++) {
        NSMutableArray *sectionedUsersArr=[self.listOfUsersArr objectAtIndex:i];
        count=count+[sectionedUsersArr count];
        for (int j=0; j<[sectionedUsersArr count]; j++)
        {
            [allPendingTSArray addObject:[sectionedUsersArr objectAtIndex:j]];
        }
        
    }
    
    if (count>0) {
        
        
        NSInteger indexCount=0;
        
        for (int i=0; i<[self.listOfUsersArr count]; i++) {
            NSMutableArray *sectionedUsersArr=[self.listOfUsersArr objectAtIndex:i];
            if (self.selectedIndexPath.section==i) 
            {
                
                indexCount=indexCount+self.selectedIndexPath.row+1;
                
                
                break;
            }
            else
            {
                indexCount=indexCount+[sectionedUsersArr count];
            }
            
        }
        indexCount=indexCount-1;
        if (indexCount<0) {
            indexCount=0;
        }
        
        
        NSMutableArray *templistOfItemsArr=[NSMutableArray array];
        
        
        //        for (int j=0; j<[self.listOfUsersArr count]; j++) 
        //        {
        //NSMutableArray *sectionedUsersArr=[self.listOfUsersArr objectAtIndex:selectedIndexPath.section];
        
        //            for (int k=0; k<[sectionedUsersArr count]; k++) 
        //            {
        //NSMutableDictionary *userDict=[sectionedUsersArr objectAtIndex:selectedIndexPath.row];
        //[self displayAllTimeSheetsBySheetID: userDict];
        if ([self.timeSheetsArray count]>0) 
        {
            NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:[self.timeSheetsArray objectAtIndex:0],@"TIMESHEETOBJ",permissionsetObj,@"PERMISSIONOBJ",preferenceSet,@"PREFERENCEOBJ", nil];
            [templistOfItemsArr addObject:dict];
        }
        
        permissionsetObj=nil;
       
        preferenceSet=nil;
        [self.timeSheetsArray   removeAllObjects];
        
        
        //            }
        //        }
        
        
        G2ApprovalsScrollViewController *tempscrollViewController =[[G2ApprovalsScrollViewController alloc]init];
        self.scrollViewController=tempscrollViewController;
        
        [self.scrollViewController setNumberOfViews:1];
        [self.scrollViewController setIndexCount:indexCount];
        [self.scrollViewController setListOfItemsArr:templistOfItemsArr];
        [self.scrollViewController setAllPendingTimesheetsArr:allPendingTSArray];
        self.scrollViewController.currentViewIndex=0;
        
        
        
        if (indexCount==0) {
            self.scrollViewController.hasPreviousTimeSheets=FALSE;
        }
        else 
        {
            
            self.scrollViewController.hasPreviousTimeSheets=TRUE;  
            
        }
        
        
        if (indexCount==count-1 || count==0) {
            self.scrollViewController.hasNextTimeSheets=FALSE;  
        }
        else 
        {
            self.scrollViewController.hasNextTimeSheets=TRUE;  
        }
        
        [scrollViewController setHidesBottomBarWhenPushed:NO];
        
        [self.navigationController pushViewController:self.scrollViewController animated:YES];
        [selectedSheetsIDsArr removeAllObjects];
        G2ApprovalTablesFooterView *footerView=(G2ApprovalTablesFooterView *)self.approvalpendingTSTableView.tableFooterView;
        footerView.commentsTextView.text=@"";
        [self setDescription:@""];
        
    }
    
    //    [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
    [self.approvalpendingTSTableView deselectRowAtIndexPath:self.selectedIndexPath animated:YES]; 
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self performSelector:@selector(delayNextScreenAnimation:) withObject:indexPath afterDelay:0.1];
    
}


-(void)delayNextScreenAnimation:(NSIndexPath *)indexPath
{
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:LoadingMessage];
    self.selectedIndexPath=indexPath;
    G2ApprovalsModel *approvalsModel = [[G2ApprovalsModel alloc] init]; 
    //NSArray *entriesArr=[approvalsModel getTimeEntriesFromDB];
    
    BOOL approvalSupportDataCanRun = [G2Util shallExecuteQuery:APPROVALS_SUPPORT_DATA_SERVICE_SECTION];
    
    if (approvalSupportDataCanRun==YES)
    {
        /*******Delete support data ie UDF preferences permissions*********/
        [approvalsModel deleteAllRowsForApprovalUserDefinedFieldsTable];
        [approvalsModel deleteAllRowsForApprovalUserPermissionsTable];
        [approvalsModel deleteAllRowsForApprovalPreferencesTable];
    }

    
    
    NSMutableArray *sectionedUsersArr=[self.listOfUsersArr objectAtIndex:indexPath.section];
    NSMutableDictionary *userDict=[sectionedUsersArr objectAtIndex:indexPath.row];
   // [self displayAllTimeSheetsBySheetID: userDict];
    
    NSMutableArray *timeEntriesArr=[approvalsModel getTimeEntriesForSheetFromDB:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"identity"]] ];
    NSMutableArray *timeOffEntriesArr=[approvalsModel getTimeOffsForSheetFromDB:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"identity"]] ];
    NSMutableArray *bookedTimeOffEntriesArr=[approvalsModel getBookedTimeOffEntryForSheetWithOnlySheetIdentity:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"identity"]]   ];
    
    NSMutableArray *userPermissionsArr=[approvalsModel getUserPermissionsForUserID:[userDict objectForKey:@"user_identity"]];
    NSMutableArray *userPreferencesArr=[approvalsModel getAllUserPreferencesForUserID:[userDict objectForKey:@"user_identity"]];
    NSArray *allUDFDetailsArray=[approvalsModel getAllUdfDetails];
    
    
    
    BOOL userDataPresent=NO;
    if ((userPermissionsArr==nil || [userPermissionsArr count]==0)|| (userPreferencesArr==nil && [userPreferencesArr count]==0)||allUDFDetailsArray==nil)
    {
        userDataPresent=NO;
    }
    else
    {
        userDataPresent=YES;
    }
        
    if ((([timeEntriesArr count]>0 && timeEntriesArr!=nil) || ([timeOffEntriesArr count]>0  && timeOffEntriesArr!=nil) ||  ([bookedTimeOffEntriesArr count]>0  && bookedTimeOffEntriesArr!=nil))&& userDataPresent==YES)
    {
        
        [self viewAllTimeEntriesScreen];
    }
    else
    {
        
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ALL_PENDING_APPROVAL_TIMESHEETS_ENTRIES_SERVED_NOTIFICATION object:nil];
        
        //DE5784
        [[NSNotificationCenter defaultCenter]removeObserver:self name:APPROVAL_TIMESHEET_DELETED_NOT_WAITINGFORAPPROVAL object:nil]; 
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(approvalTimesheetDeletedNotWaitingForApproval) name:APPROVAL_TIMESHEET_DELETED_NOT_WAITINGFORAPPROVAL object:nil];
        
        [[NSNotificationCenter defaultCenter] 
         addObserver:self selector:@selector(viewAllTimeEntriesScreen) name:ALL_PENDING_APPROVAL_TIMESHEETS_ENTRIES_SERVED_NOTIFICATION object:nil];
        
        [[G2RepliconServiceManager approvalsService] fetchPendingApprovalsTimeSheetEntriesDataForSheetIdentityWithUserpermissionsAndPreferencesAndUdf:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"identity"]] andUserIdentity:[NSString stringWithFormat:@"%@",[userDict objectForKey:@"user_identity"]] withDelegate: self];
    }
    
    
}
//DE5784
-(void)approvalTimesheetDeletedNotWaitingForApproval{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:APPROVAL_TIMESHEET_DELETED_NOT_WAITINGFORAPPROVAL object:nil];
    G2ApprovalsModel *approvalsModel = [[G2ApprovalsModel alloc] init]; 
    [approvalsModel deleteRowsForApprovalTimesheetsTableForSheetIdentity:[NSString stringWithFormat:@"%@",[[[self.listOfUsersArr objectAtIndex:selectedIndexPath.section] objectAtIndex:selectedIndexPath.row] objectForKey:@"identity"]]];
   
}
/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 }
 */

- (void)handleButtonClickforSelectedUser:(NSIndexPath *)indexPath isSelected:(BOOL)isSelected 
{
    DLog(@"User selection = %d",isSelected);
    
    NSMutableArray *sectionedUsersArr=[self.listOfUsersArr objectAtIndex:indexPath.section];
    NSMutableDictionary *userDict=[sectionedUsersArr objectAtIndex:indexPath.row];
    [userDict setObject:[NSNumber numberWithBool:isSelected] forKey:@"IsSelected"];
    [sectionedUsersArr replaceObjectAtIndex:indexPath.row withObject:userDict];
    [self.listOfUsersArr replaceObjectAtIndex:indexPath.section withObject:sectionedUsersArr];
    
    if (isSelected) {
        [self.selectedSheetsIDsArr addObject:[userDict objectForKey:@"identity"]];
    }
    else
    {
        [self.selectedSheetsIDsArr removeObject:[userDict objectForKey:@"identity"]];
    }
    
    if ([self.selectedSheetsIDsArr count]== self.totalRowsCount)
    {
        
        checkOrClearAllBtn.enabled=TRUE;
        UIImage *unPressedImage=[G2Util thumbnailImage:G2CLEAR_ALL_UNPRESSED_IMAGE];
        UIImage *pressedImage=[G2Util thumbnailImage:G2CLEAR_ALL_PRESSED_IMAGE];
        [checkOrClearAllBtn setTag:CLEAR_ALL_BUTTON_TAG];
        [checkOrClearAllBtn setImage:unPressedImage forState:UIControlStateNormal];
        [checkOrClearAllBtn setImage:pressedImage forState:UIControlStateHighlighted];
    }
    else if ([self.selectedSheetsIDsArr count]< self.totalRowsCount)
    {
        
        checkOrClearAllBtn.enabled=TRUE;
        UIImage *unPressedImage=[G2Util thumbnailImage:G2CHECK_ALL_UNPRESSED_IMAGE];
        UIImage *pressedImage=[G2Util thumbnailImage:G2CHECK_ALL_PRESSED_IMAGE];
        [checkOrClearAllBtn setTag:CHECK_ALL_BUTTON_TAG];
        [checkOrClearAllBtn setImage:unPressedImage forState:UIControlStateNormal];
        [checkOrClearAllBtn setImage:pressedImage forState:UIControlStateHighlighted];
    }
    else if ([self.selectedSheetsIDsArr count]==0)
    {
        
        checkOrClearAllBtn.enabled=FALSE;
        UIImage *unPressedImage=[G2Util thumbnailImage:G2CHECK_ALL_UNPRESSED_IMAGE];
        UIImage *pressedImage=[G2Util thumbnailImage:G2CHECK_ALL_PRESSED_IMAGE];
        [checkOrClearAllBtn setTag:CHECK_ALL_BUTTON_TAG];
        [checkOrClearAllBtn setImage:unPressedImage forState:UIControlStateNormal];
        [checkOrClearAllBtn setImage:pressedImage forState:UIControlStateHighlighted];
    }
    
}


- (void)handleButtonClickForFooterView:(NSInteger)senderTag
{
    
    if ([self.selectedSheetsIDsArr count]==0 && senderTag!=COMMENTS_TEXTVIEW_TAG_G2) 
    {
        
        UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:nil message: RPLocalizedString(APPROVAL_TIMESHEET_VALIDATION_MSG,@"")
                                                                  delegate:self cancelButtonTitle:RPLocalizedString(OK_BTN_TITLE, @"OK") otherButtonTitles:nil];
        
        [confirmAlertView setDelegate:self];
        [confirmAlertView setTag:0];
        
        [confirmAlertView show];
       
        
        return;
    }
    
    if (senderTag==APPROVE_BUTTON_TAG_G2)
    {
        DLog(@"APPROVE BUTTON CLICKED");
        
        UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat: RPLocalizedString(APPROVAL_TIMESHEET_APPROVE_CONFIRM_MSG,@""),[self.selectedSheetsIDsArr count] ]
                                                                  delegate:self cancelButtonTitle:RPLocalizedString(NO_BTN_TITLE, @"NO") otherButtonTitles:RPLocalizedString(YES_BTN_TITLE,@""),nil];
        [confirmAlertView setDelegate:self];
        [confirmAlertView setTag:1];
        
        [confirmAlertView show];
        
        
    }
    else if (senderTag==REJECT_BUTTON_TAG_G2)
    {
        DLog(@"REJECT BUTTON CLICKED");
        
        UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat: RPLocalizedString(APPROVAL_TIMESHEET_REJECT_CONFIRM_MSG,@""),[self.selectedSheetsIDsArr count] ]
                                                                  delegate:self cancelButtonTitle:RPLocalizedString(NO_BTN_TITLE, @"NO") otherButtonTitles:RPLocalizedString(YES_BTN_TITLE,@""),nil];
        [confirmAlertView setDelegate:self];
        [confirmAlertView setTag:2];
        
        [confirmAlertView show];
       
    }
    else
    {
        DLog(@"COMMENTS CLICKED");
        
        G2AddDescriptionViewController *tempaddDescriptionViewController = [[G2AddDescriptionViewController alloc] init];
        self.addDescriptionViewController=tempaddDescriptionViewController;
        
		[addDescriptionViewController setViewTitle:RPLocalizedString(TimeEntryComments,@"")];
		[addDescriptionViewController setTimeEntryParentController:self];
        
        G2ApprovalTablesFooterView *footerView=(G2ApprovalTablesFooterView *)self.approvalpendingTSTableView.tableFooterView;
		[addDescriptionViewController setDescTextString: footerView.commentsTextView.text];
		[addDescriptionViewController setFromTimeEntryComments:NO];
        [addDescriptionViewController setFromTimeEntryUDF:NO];
		[addDescriptionViewController setDescControlDelegate:self];
		[self.navigationController pushViewController:addDescriptionViewController animated:YES];
		
        
    }
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag==1) {
        if (buttonIndex==1) {
            isApproveRejectBtnClicked=YES;
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:LoadingMessage];
            [[NSNotificationCenter defaultCenter]
             removeObserver:self name:APPROVAL_TIMESHEETS_APPROVAL_REJECT_DONE_NOTIFICATION object:nil];
            [[NSNotificationCenter defaultCenter] addObserver: self 
                                                     selector: @selector(approve_reject_Completed) 
                                                         name: APPROVAL_TIMESHEETS_APPROVAL_REJECT_DONE_NOTIFICATION
                                                       object: nil]; 
            
            
            G2ApprovalTablesFooterView *footerview=(G2ApprovalTablesFooterView *)self.approvalpendingTSTableView.tableFooterView;
            NSString *comments=footerview.commentsTextView.text;
            if (comments==nil) {
                comments=@"";
            }
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:ApprovingMessage];
            
            [[G2RepliconServiceManager approvalsService] approveTimesheetWithComments:selectedSheetsIDsArr comments:comments];
        }
    }
    
    else if (alertView.tag==2) {
        if (buttonIndex==1) {
            isApproveRejectBtnClicked=YES;
            G2PermissionsModel *permissionModel=[[G2PermissionsModel alloc]init];
            BOOL isApproverAllowBlankRejectComment= [permissionModel getStatusForGivenPermissions:@"ApproverAllowBlankRejectComment"];
            
            
            G2ApprovalTablesFooterView *footerview=(G2ApprovalTablesFooterView *)self.approvalpendingTSTableView.tableFooterView;
            NSString *comments=footerview.commentsTextView.text;
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
                                                     selector: @selector(approve_reject_Completed) 
                                                         name: APPROVAL_TIMESHEETS_APPROVAL_REJECT_DONE_NOTIFICATION
                                                       object: nil]; 
            
            
            
            
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RejectingMessage];
            
            
            
            [[G2RepliconServiceManager approvalsService] rejectTimesheetWithComments:selectedSheetsIDsArr comments:comments];
            
            
            
        }
    }
    else if (alertView.tag==9999)//DE6896 Ullas M L
    {
        if (buttonIndex==0) {
            
            if (isApproveRejectBtnClicked) {
                isApproveRejectBtnClicked=NO;
            }
            
        }
    }
    
}

-(void)approve_reject_Completed
{
    [[NSNotificationCenter defaultCenter]
	 removeObserver:self name:APPROVAL_TIMESHEETS_APPROVAL_REJECT_DONE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter]
	 removeObserver:self name:APPROVAL_TIMESHEETS_APPROVAL_REJECT_DONE_NOTIFICATION object:nil];
    
    G2ApprovalTablesFooterView *footerView=(G2ApprovalTablesFooterView *)self.approvalpendingTSTableView.tableFooterView;
    footerView.commentsTextView.text=@"";
    
    
    [self refreshTableView];
    [self setDescription:@""];
    
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
    [self.selectedSheetsIDsArr removeAllObjects];
}

-(void)refreshTableView
{
    
    
    if(self.isFromCommentsScreen)
    {
        self.isFromCommentsScreen=NO; 
    }
    else 
    {
        G2ApprovalsModel *approvalsModel=[[G2ApprovalsModel alloc]init];
        NSMutableArray *pendingTimesheetsArr=[approvalsModel getAllTimeSheetsGroupedByDueDates];
       
        self.listOfUsersArr=pendingTimesheetsArr;
        
        checkOrClearAllBtn.enabled=TRUE;
        UIImage *unPressedImage=[G2Util thumbnailImage:G2CHECK_ALL_UNPRESSED_IMAGE];
        UIImage *pressedImage=[G2Util thumbnailImage:G2CHECK_ALL_PRESSED_IMAGE];
        [checkOrClearAllBtn setTag:CHECK_ALL_BUTTON_TAG];
        [checkOrClearAllBtn setImage:unPressedImage forState:UIControlStateNormal];
        [checkOrClearAllBtn setImage:pressedImage forState:UIControlStateHighlighted];
        
        
    }
    
    
    
    //DE5908 Ullas M L
    if (isApproveRejectBtnClicked) {
        isApproveRejectBtnClicked=NO;
        [self.approvalpendingTSTableView removeFromSuperview];
        [self intialiseTableViewWithFooter];
        [self.approvalpendingTSTableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        
    }
    self.totalRowsCount=0;
    [self.approvalpendingTSTableView reloadData];
    
    if ([ self.listOfUsersArr count]==0)
    {
        RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
        if(!appDelegate.isLockedTimeSheet)
        {
            
            [self updateTabBarItemBadge];
            // [[[UIApplication sharedApplication]delegate]performSelector:@selector(flipToHomeViewController)];
        }
        else
        {
            [self updateTabBarItemBadge];
        }
        
        
    }
    else
    {
        [self updateTabBarItemBadge];
    }
    
    if ([self.listOfUsersArr count]==0) {
        self.approvalpendingTSTableView.tableFooterView=nil;
        [self showMessageLabel];
    }
    
}


-(void)animateCellWhichIsSelected
{
    
}

- (void)setDescription:(NSString *)description
{
    
    G2ApprovalTablesFooterView *footerView=(G2ApprovalTablesFooterView *)self.approvalpendingTSTableView.tableFooterView;
    footerView.commentsTextView.text=description;
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
    CGRect frame=footerView.commentsTextView.frame;
    
    frame.size.height=size.height +15;
    
    if (frame.size.height<44.0) {
        frame.size.height=44.0;
    }
    
    [footerView.commentsTextView setFrame:frame];
    
    float yOrigin=frame.origin.y+frame.size.height+30.0;
    
    frame=footerView.approveButton.frame;
    
    frame.origin.y=yOrigin;
    
    [footerView.approveButton setFrame:frame];
    frame=footerView.rejectButton.frame;
    
    frame.origin.y=yOrigin;
    [footerView.rejectButton setFrame:frame];
    
    float finalHeight=frame.origin.y+frame.size.height+30.0;
    
    frame=footerView.frame;
    frame.size.height=finalHeight;
    footerView.frame=frame;
    self.approvalpendingTSTableView.tableFooterView = footerView;
    
    
}
-(void)displayAllTimeSheetsBySheetID:(NSDictionary *)sheetDict{
	
    if (timeSheetsArray == nil) {
        NSMutableArray *temptimeSheetsArray = [[NSMutableArray alloc] init];
        self.timeSheetsArray=temptimeSheetsArray;
        
    }
    
    
    if (permissionsetObj == nil) {
        permissionsetObj = [[G2PermissionSet alloc] init];
    }
    if (preferenceSet == nil) {
        preferenceSet = [[G2Preferences alloc] init];
    }
    
	//Fetch Time Sheets from DB
	if ([timeSheetsArray count] > 0) {
		[timeSheetsArray removeAllObjects];
	}
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
    
	
	
    
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
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
    
	
	NSMutableArray *formatsArray = [supportDataModel getUserTimeSheetFormats];
   
	if (formatsArray != nil && [formatsArray count]> 0) {
		for (NSDictionary *formatDict in formatsArray) {
			if ([[formatDict objectForKey:@"preferenceName"] isEqualToString:@"Timesheet.DateFormat"]) {
				//self.dateformat = [formatDict objectForKey:@"preferenceValue"];
                [preferenceSet setDateformat:[formatDict objectForKey:@"preferenceValue"]];
			}
		}
	}
	//Create Preferences Object
	
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
	
    
    
    G2TimeSheetObject *timesheetObj   = [[G2TimeSheetObject alloc] init];
    
    timesheetObj.userID=[sheetDict objectForKey:@"user_identity"];
    timesheetObj.userFirstName=[sheetDict objectForKey:@"user_fname"];
    timesheetObj.userLasttName=[sheetDict objectForKey:@"user_lname"];
    
    timesheetObj.identity			= [sheetDict objectForKey:@"identity"];
    timesheetObj.status				= [sheetDict objectForKey:@"approvalStatus"];
    timesheetObj.approversRemaining = [[sheetDict objectForKey:@"approversRemaining"] boolValue];
    
    NSDate *startdate	= [G2Util convertStringToDate:[sheetDict objectForKey:@"startDate"]];
    NSDate *enddate		= [G2Util convertStringToDate:[sheetDict objectForKey:@"endDate"]];
    NSDate *duedate		= [G2Util convertStringToDate:[sheetDict objectForKey:@"dueDate"]];
    NSDate *effectivedate		= [G2Util convertStringToDate:[sheetDict objectForKey:@"effectiveDate"]];
    
    timesheetObj.startDate  = startdate;
    timesheetObj.endDate    = enddate;
    timesheetObj.dueDate    = duedate ;
    timesheetObj.effectiveDate    = effectivedate ;
    
    NSString *timeEntrytotalHrs                  = [approvalsModel getSheetTotalTimeHoursForSheetFromDB:[timesheetObj identity] withFormat:hourFormat];
    
    
    timesheetObj.totalHrs   =timeEntrytotalHrs;
    
    
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
    BOOL isNewInOut = [approvalsModel checkUserPermissionWithPermissionName:@"NewInOutTimesheet"andUserId:[sheetDict objectForKey:@"user_identity"]];
    
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
            timesheetObj.timeSheetType=APPROVAL_TIMESHEET_TYPE_LOCKEDINOUT;
        }
        else
        {
            NSMutableArray *checkUserPreferencesArr=[approvalsModel getAllUserPreferencesForUserID:[NSString stringWithFormat:@"%@", [sheetDict objectForKey:@"user_identity"]]];
            
            for (int arrCount=0; arrCount<[checkUserPreferencesArr count]; arrCount++) 
            {
                NSDictionary *eachPreferenceDict=[checkUserPreferencesArr objectAtIndex:arrCount];
                if ([[eachPreferenceDict objectForKey:@"preferenceName"] isEqualToString:@"Timesheet.Format"]) 
                {
                    if ([[eachPreferenceDict objectForKey:@"preferenceValue"] isEqualToString:InOut_Type_TimeSheet]) 
                    {
                        timesheetObj.timeSheetType=APPROVAL_TIMESHEET_TYPE_INOUT;
                    }
                    else if ([[eachPreferenceDict objectForKey:@"preferenceValue"] isEqualToString:New_InOut_Type_TimeSheet])
                    {
                        timesheetObj.timeSheetType=APPROVAL_TIMESHEET_TYPE_INOUT;
                    }
                    
                    else
                    {
                        timesheetObj.timeSheetType=APPROVAL_TIMESHEET_TYPE_STANDARD;
                    }
                    break;  
                }
                
                
            }//---------------------------------------------------------------------
            
        }
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
                        timesheetObj.timeSheetType=APPROVAL_TIMESHEET_TYPE_STANDARD;
                    }
                    else if ([[eachPreferenceDict objectForKey:@"preferenceValue"] isEqualToString:InOut_Type_TimeSheet]) 
                    {
                        timesheetObj.timeSheetType=APPROVAL_TIMESHEET_TYPE_INOUT;
                    }
                    break;
                }
                
                
                
            }
        }
        else if (isClassicTimesheet) 
        {
            timesheetObj.timeSheetType=APPROVAL_TIMESHEET_TYPE_STANDARD;
        }
        else if (isInOutTimesheet) 
        {
            timesheetObj.timeSheetType=APPROVAL_TIMESHEET_TYPE_INOUT;
        }
        else if (isNewInOut) 
        {
            timesheetObj.timeSheetType=APPROVAL_TIMESHEET_TYPE_INOUT;
        }
        else
        {
            timesheetObj.timeSheetType=APPROVAL_TIMESHEET_TYPE_LOCKEDINOUT;
        }
        
    }
    
    appDelegate.userType=timesheetObj.timeSheetType; 
    
    
    
    if (appDelegate.isLockedTimeSheet) {
        if ([timesheetObj.totalHrs isEqualToString:@"0.00"] || [timesheetObj.totalHrs isEqualToString:@"0:00"] ) {
            NSCalendar* calendar = [NSCalendar currentCalendar];
            NSDate* now = [NSDate date];
            NSUInteger differenceInDays =
            [calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitEra forDate:startdate] -
            [calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitEra forDate:now];
            if (differenceInDays<=0 ) {
//                G2TimesheetModel *timesheetModel = [[G2TimesheetModel alloc] init]; 
                //                NSMutableArray *entriesArr=[timesheetModel getTimeEntriesForSheetFromDB:[timesheetObj identity]];
                if (timesheetObj) 
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


-(void)goBack:(id)sender
{
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    if(!appDelegate.isLockedTimeSheet)
    {
         [[NSNotificationCenter defaultCenter] removeObserver:self name:APPROVAL_TIMESHEETS_RECEIVED_NOTIFICATION object:nil];
        [[[UIApplication sharedApplication]delegate]performSelector:@selector(flipToHomeViewController)]; 
        
    }
    
    
}


-(void)updateTabBarItemBadge
{
    
    
    
    
    
    //    if ([self.listOfUsersArr count]>0) 
    //    {
    
    for (int i=0; i<[self.tabBarController.viewControllers count]; i++)
    {
        if ([[self.tabBarController.viewControllers objectAtIndex:i] isKindOfClass:[G2ApprovalsNavigationController class]]) 
        {
            
            G2ApprovalsNavigationController *navCtrl=(G2ApprovalsNavigationController *)[self.tabBarController.viewControllers objectAtIndex:i];
            NSUInteger count=0;
            for (int j=0; j<[self.listOfUsersArr count]; j++) 
            {
                count=count+[(NSMutableArray *)[self.listOfUsersArr objectAtIndex:j]count];
            }//                if (count>0) {
            
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
    }//    }
    
    
    
}

-(void)clearORSelectAll:(id)sender
{
    UIButton *button=(UIButton *)sender;
    if (button.tag==CHECK_ALL_BUTTON_TAG) 
    {
        UIImage *unPressedImage=[G2Util thumbnailImage:G2CLEAR_ALL_UNPRESSED_IMAGE];
        UIImage *pressedImage=[G2Util thumbnailImage:G2CLEAR_ALL_PRESSED_IMAGE]; 
        [button setTag:CLEAR_ALL_BUTTON_TAG];
        [button setImage:unPressedImage forState:UIControlStateNormal];
        [button setImage:pressedImage forState:UIControlStateHighlighted];
        [self.selectedSheetsIDsArr removeAllObjects];
        for (int i=0; i<[self.listOfUsersArr count]; i++) 
        {
            
            NSMutableArray *sectionedUsersArr=[self.listOfUsersArr objectAtIndex:i];
            for (int i=0; i<[sectionedUsersArr count]; i++) 
            {
                NSMutableDictionary *userDict=[sectionedUsersArr objectAtIndex:i];

//                if ([[userDict objectForKey:@"IsSelected"]intValue]!=1) 
//                {
                    [userDict setObject:[NSNumber numberWithBool:YES] forKey:@"IsSelected"];
                    [sectionedUsersArr replaceObjectAtIndex:i withObject:userDict];
                   
                    [self.selectedSheetsIDsArr addObject:[userDict objectForKey:@"identity"]];
                }
//            }
            [self.listOfUsersArr replaceObjectAtIndex:i withObject:sectionedUsersArr];
        }
        
    }
    else if (button.tag==CLEAR_ALL_BUTTON_TAG) 
    {
        UIImage *unPressedImage=[G2Util thumbnailImage:G2CHECK_ALL_UNPRESSED_IMAGE];
        UIImage *pressedImage=[G2Util thumbnailImage:G2CHECK_ALL_PRESSED_IMAGE];
        [button setTag:CHECK_ALL_BUTTON_TAG];
        [button setImage:unPressedImage forState:UIControlStateNormal];
        [button setImage:pressedImage forState:UIControlStateHighlighted];
        
        for (int i=0; i<[self.listOfUsersArr count]; i++) 
        {
            
            NSMutableArray *sectionedUsersArr=[self.listOfUsersArr objectAtIndex:i];
            for (int i=0; i<[sectionedUsersArr count]; i++) 
            {
                NSMutableDictionary *userDict=[sectionedUsersArr objectAtIndex:i];
                if ([[userDict objectForKey:@"IsSelected"]intValue]!=0) 
                {
                    [userDict setObject:[NSNumber numberWithBool:NO] forKey:@"IsSelected"];
                    [sectionedUsersArr replaceObjectAtIndex:i withObject:userDict];
                    [self.selectedSheetsIDsArr removeObject:[userDict objectForKey:@"identity"]];
                }
            }
            [self.listOfUsersArr replaceObjectAtIndex:i withObject:sectionedUsersArr];
        }
        
    }
    
    self.totalRowsCount=0;
    [self.approvalpendingTSTableView reloadData];
   
}
- (void)moreButtonClickForFooterView:(NSInteger)senderTag
{
    
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {

        [G2Util showOfflineAlert];
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:APPROVAL_TIMESHEETS_RECEIVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(nextMostRecentTimesheetsReceived)
                                                 name: APPROVAL_TIMESHEETS_RECEIVED_NOTIFICATION
                                               object: nil];
    
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
    int lastSheetIndex = [[[NSUserDefaults standardUserDefaults] objectForKey:APPROVAL_TIMESHEET_FETCH_START_INDEX]
						  intValue];
    
    int badgeValue=[[[NSUserDefaults standardUserDefaults] objectForKey:@"NumberOfTimesheetsPendingApproval"] intValue];
    
    if (lastSheetIndex>=badgeValue)
    {
        lastSheetIndex=badgeValue;
    }
   
	//int nextSheetStartIndex = lastSheetIndex;
    NSDictionary *dict=[[NSUserDefaults standardUserDefaults]objectForKey:APPROVAL_QUERY_HANDLE];
    NSString *queryHandler=[dict objectForKey:@"Identity"];
    [[G2RepliconServiceManager approvalsService] sendRequestToFetchNextRecentPendingTimesheetsWithStartIndex:[NSNumber numberWithInt:lastSheetIndex] withLimitCount:[[G2AppProperties getInstance]getAppPropertyFor:@"NextRecentApprovalsPendingSheetsCount"] withQueryHandler:queryHandler withDelegate:self];
    
        
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
    self.approvalpendingTSTableView =nil;
    self.sectionHeaderlabel=nil;
    self.sectionHeader=nil;
    self.msgLabel=nil;
    self.leftButton=nil;
    self.sectionHeaderlabel=nil;
    self.sectionHeader=nil;
    self.scrollViewController=nil;
    self.addDescriptionViewController=nil;
    self.topToolbarLabel=nil;
}



@end
