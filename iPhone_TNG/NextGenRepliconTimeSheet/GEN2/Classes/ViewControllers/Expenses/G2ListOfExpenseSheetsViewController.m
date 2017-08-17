//
//  ListOfExpenseSheetsViewController.m
//  Replicon
//
//  Created by Rohini on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2ListOfExpenseSheetsViewController.h"
#import "G2PermissionsModel.h"
#import "G2ViewUtil.h"
#import "RepliconAppDelegate.h"


@implementation G2ListOfExpenseSheetsViewController
@synthesize expenseSheetTableView,showedExpensesCount;
@synthesize tappedIndexPath;
@synthesize  navcontroller;
@synthesize  footerViewExpenses;
@synthesize imageView;

- (id) init{
	self = [super init];
	if (self != nil) {
		if (expensesModel==nil) {
			expensesModel=[[G2ExpensesModel alloc]init];
		}
		showedExpensesCount = [[[NSUserDefaults standardUserDefaults]objectForKey:@"lastDownloadedSheetsCount"] intValue];
//        if(![[NSUserDefaults standardUserDefaults]boolForKey:@"updateRecentTimeSheetsDone"])
//        {
//            [expensesModel updateRecentProjectsColumn];
//            [[NSUserDefaults standardUserDefaults]setBool:TRUE forKey:@"updateRecentTimeSheetsDone"];
//        }
            
         
		if (showedExpensesCount == 0) {
			showedExpensesCount = [(NSMutableArray *)[[NSUserDefaults standardUserDefaults]objectForKey:@"expenseSheetsArray"] count];
		}
		[self.view setBackgroundColor: G2RepliconStandardBackgroundColor];
		
		[self registerForNotification];
	}
	return self;
}


#pragma mark -

-(void)viewWillAppear:(BOOL)animated{
    
    NSArray *_expenseSheetsArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"expenseSheetsArray"];
    
    showedExpensesCount = [[[NSUserDefaults standardUserDefaults]objectForKey:@"lastDownloadedSheetsCount"] intValue];
    if (showedExpensesCount == 0) {
        showedExpensesCount = [_expenseSheetsArray count];
        if (showedExpensesCount == 0)
        {
            _expenseSheetsArray=[expensesModel getExpenseSheetsFromDataBase];
            showedExpensesCount=[_expenseSheetsArray count];
            [[NSUserDefaults standardUserDefaults] setObject: _expenseSheetsArray forKey: @"expenseSheetsArray"];
             [[NSUserDefaults standardUserDefaults]  synchronize]; 
        }
    }
    
	self.title = RPLocalizedString(ExpenseTabbarTitle,ExpenseTabbarTitle) ;
	//ravi - not required
	
	
	
	//ravi - While showing the expensesheets we don't require expense entries
	//NSArray *expenseEntriesArray=nil;
	//expenseEntriesArray= [standardUserDefaults objectForKey:@"expenseEntriesArray"];
    
	[self.view setBackgroundColor:G2RepliconStandardBackgroundColor];
	
	 RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if (!appDelegate.isLockedTimeSheet) 
    {
        UIImage *homeButtonImage1=[G2Util thumbnailImage:G2HomeTransparentButtonImage];
        UIBarButtonItem	*leftButton = [[UIBarButtonItem alloc]initWithImage:homeButtonImage1 style:UIBarButtonItemStylePlain
                                                                     target:self action:@selector(goBack:)];
        [self.navigationItem setLeftBarButtonItem:leftButton animated:NO];
       
    }
	
	
		
	[G2ViewUtil setToolbarLabel: self withText: RPLocalizedString(ExpenseTabbarTitle,ExpenseTabbarTitle)];
	
	UIBarButtonItem *addButtonIos=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addExpenseSheetAction:)];
	[self.navigationItem setRightBarButtonItem:addButtonIos];
	
	
	if ([_expenseSheetsArray count]!=0) {
        expenseSheetTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , self.view.frame.size.height) style:UITableViewStylePlain];
		[expenseSheetTableView setDelegate:self];
		[expenseSheetTableView setDataSource:self];
        self.expenseSheetTableView.separatorColor = [UIColor clearColor];
		[self.view addSubview:expenseSheetTableView]; 
		
		
		UIView *bckView = [UIView new];
		[bckView setBackgroundColor:G2RepliconStandardBackgroundColor];
		[expenseSheetTableView setBackgroundView:bckView];
		
		UIView *tempfooterViewExpenses = [[UIView alloc] initWithFrame:CGRectMake(0.0,
																	  50,
																	//  self.expenseSheetTableView.frame.size.width,
																	  self.view.frame.size.width,
																	  250.0)];
        self.footerViewExpenses=tempfooterViewExpenses;
       
		[footerViewExpenses setBackgroundColor:[UIColor clearColor]];
		
		moreButton =[UIButton buttonWithType:UIButtonTypeCustom];
		[moreButton setBackgroundColor:[UIColor clearColor]];
		UIImage *moreImage = [G2Util thumbnailImage:G2MoreButtonIMage];
        
       
        
        // Let's make an NSAttributedString first
         NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:RPLocalizedString(MoreText,@"")];
        //Add LineBreakMode
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineBreakMode:NSLineBreakByClipping];
        [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        // Add Font
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]} range:NSMakeRange(0, attributedString.length)];
        
        //Now let's make the Bounding Rect
        CGSize expectedLabelSize = [attributedString boundingRectWithSize:CGSizeMake(280, moreImage.size.height+10) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        float totalSize=expectedLabelSize.width+10+moreImage.size.width+1.0;
        int xOrigin=(320.0-totalSize)/2;
        [moreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
        [ moreButton setFrame:CGRectMake(xOrigin, 30, expectedLabelSize.width+10.0,moreImage.size.height+10 )];
        
		
		[moreButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
		[moreButton setTitleColor:RepliconStandardBlackColor forState:UIControlStateNormal];
		[moreButton setTitle:RPLocalizedString(MoreText,@"") forState:UIControlStateNormal];
		[moreButton addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
		//[moreButton setImage:moreImage forState:UIControlStateNormal];
		[moreButton setHidden:YES];
		UIImageView *tempimageView = [[UIImageView alloc]init];
		[tempimageView setImage:moreImage];
		[tempimageView setFrame:CGRectMake(moreButton.frame.origin.x+expectedLabelSize.width+10.0+1.0,35, moreImage.size.width, moreImage.size.height)];
		[tempimageView setBackgroundColor:[UIColor clearColor]]; 
		//[moreButton addSubview:imageView];
		[tempimageView setHidden:YES];
		[footerViewExpenses addSubview:moreButton];
		[footerViewExpenses addSubview:tempimageView];
		self.imageView=tempimageView;
        
        footerViewExpenses.frame=CGRectMake(0.0, 0.0, self.view.frame.size.width, moreImage.size.height+10+60.0);
		[self.expenseSheetTableView setTableFooterView:footerViewExpenses];		
		[self showHideMoreButton];
		
	}else {
		[footerViewExpenses setHidden:YES];
		if (expenseSheetTableView != nil) {
			[expenseSheetTableView reloadData];
		}
	}
	if (self.tappedIndexPath != nil &&  self.tappedIndexPath.row > 1)
    {
        if (_expenseSheetsArray != nil && [_expenseSheetsArray count]!= 0)
        {
            if ([_expenseSheetsArray count]>self.tappedIndexPath.row)
            {
                 [[self expenseSheetTableView] scrollToRowAtIndexPath:self.tappedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
            }
        }
        
    
    }
		
	//[self.navigationController.navigationBar setTintColor:RepliconStandardNavBarTintColor];
	[self performSelector:@selector(highlightTheCellWhichWasSelected) withObject:nil afterDelay:0];
	//[self performSelector:@selector(deSelectCellWhichWasHighLighted) withObject:nil afterDelay:0.5];//DE2949 FadeOut is slow
    [self performSelector:@selector(deSelectCellWhichWasHighLighted) withObject:nil afterDelay:0.0];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"allRequestsServed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
											 selector: @selector(viewWillAppear:) 
												 name: @"allRequestsServed"
											   object: FALSE];
 
 
}



-(void)registerForNotification{
	[[NSNotificationCenter defaultCenter] addObserver: self 
											 selector: @selector(gotoAllExpenseSheet) 
												 name: @"ExpenseSheetEnableNotification"
											   object: nil];

	//This notification is raised when a new expense sheet is added. However in this function there is handling for ExpenseEntriesViewController.
	//Why is ExpenseEntriesViewcontroller required at this point?
	/*[[NSNotificationCenter defaultCenter] addObserver: self 
											 selector: @selector(gotoExpenseSheetFirstEntry:) 
												 name: @"ExpenseEntriesEnableNotification"
											   object: nil];	*/
}


-(void)gotoExpenseSheetFirstEntry:(NSNotification*)notif
{
	/*[[NSNotificationCenter defaultCenter] removeObserver:self name:@"ExpenseSheetEnableNotification" object:nil];
	NSMutableArray *_expenseSheetsArray=(NSMutableArray*)[notif object];*/
	NSMutableArray *_expenseSheetsArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"expenseSheetsArray"] ;
    [[NSUserDefaults standardUserDefaults] synchronize];
	int ind=0;
	NSDictionary *_expenseSheet = [_expenseSheetsArray objectAtIndex: ind];
	
	expenseEntryViewController= [[G2ListOfExpenseEntriesViewController alloc]init];
	[expenseEntryViewController setSelectedExpenseSheetIndex:[NSNumber numberWithInt:ind]];
	
	
	
	[expenseEntryViewController setTotalReimbursement:[NSString stringWithFormat:@"%@ %0.02lf",[_expenseSheet objectForKey:@"reimburseCurrency"],
													   [[_expenseSheet objectForKey:@"totalReimbursement"] doubleValue]]];
	[expenseEntryViewController setDelegateObj:self];
	[expenseEntryViewController setExpenseSheetTitle:[_expenseSheet objectForKey:@"description"]];
	[expenseEntryViewController setExpenseSheetTrackingNo:[_expenseSheet objectForKey:@"trackingNumber"]];
	[expenseEntryViewController setSelectedSheetId:[_expenseSheet objectForKey:@"identity"]];
	[expenseEntryViewController setExpenseSheetStatus:[_expenseSheet objectForKey:@"status"]];
	
	NSArray *entriesArr = [expensesModel getEntriesforSelected:ind WithExpenseSheetArr:_expenseSheetsArray];
	
	ProjectPermissionType permType = [G2PermissionsModel getProjectPermissionType];
	NSArray *projectArray = [expensesModel getExpenseProjectsFromDatabase];
	
	
	

	
	if ([entriesArr count]!=0) {
		[expenseEntryViewController setIsEntriesAvailable:YES];
		[expenseEntryViewController setExpenseEntriesArray:(NSMutableArray*)entriesArr];
		[self.navigationController pushViewController:expenseEntryViewController animated:YES];
	}else {
		[expenseEntryViewController setIsEntriesAvailable:NO];
		
		if (permType == PermType_ProjectSpecific)
		{
			
			if ([projectArray count] == 0) {
//				[self.navigationController pushViewController:expenseEntryViewController animated:YES];
//				[Util errorAlert:RPLocalizedString(ErrorTitle,@"") errorMessage:RPLocalizedString( @"You cannot enter expenses because you do not have any projects assigned.",@"")];
//				return;
			}
			
		}
		
		NSString *projTempId = nil;
		if (projectArray != nil &&[projectArray count] == 1) {
				projTempId = [[projectArray objectAtIndex:0] objectForKey:@"identity"];
			
		}else {
			projTempId = @"null";
		}
		NSMutableArray *expenseTypeArr = [expensesModel getExpenseTypesWithTaxCodesForSelectedProjectId: projTempId];
		if (expenseTypeArr != nil && [expenseTypeArr count] == 0) {
//			[self.navigationController pushViewController:expenseEntryViewController animated:YES];
//			[Util errorAlert:RPLocalizedString(ErrorTitle,@"") errorMessage:RPLocalizedString( @"There are no available Expense Types.",@"")];
//			return;
		}
		
		[self showAddNewExpenseEntryPageByDefault:_expenseSheet];
	}
	

}


- (void) gotoAllExpenseSheet{
	[self.expenseSheetTableView reloadData];
	//[self newSheetIsAdded];
	[self showHideMoreButton];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"ExpenseSheetEnableNotification" object:nil];
}
-(void)newSheetIsAdded
{
		NSIndexPath *newIndex = [NSIndexPath indexPathForRow:0 inSection:0];
		[self setTappedIndexPath:newIndex];
}
-(void)sheetDeletedFromByUser
{
	if (self.tappedIndexPath.row > 0) {
	NSIndexPath *delIndex = [NSIndexPath indexPathForRow:(self.tappedIndexPath.row-1) inSection:0];
	[self setTappedIndexPath:delIndex];
	}
}
-(void)gotoExpenseSheetEntries{
	
	NSArray *_expenseSheetsArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"expenseSheetsArray"];
	
	[self.expenseSheetTableView reloadData];
	
	//int ind = [_expenseSheetsArray count]-1;//changes done to sort sheets.........
	
	int ind=0;
	if (expenseEntryViewController ==nil) {
		expenseEntryViewController= [[G2ListOfExpenseEntriesViewController alloc]init];
	}
	[expenseEntryViewController setSelectedExpenseSheetIndex:[NSNumber numberWithInt:ind]];
	NSArray *entriesArr = [expensesModel getEntriesforSelected:ind WithExpenseSheetArr:_expenseSheetsArray];
	
	if ([entriesArr count]!=0) {
		[expenseEntryViewController setIsEntriesAvailable:YES];
		
		[expenseEntryViewController setExpenseEntriesArray:(NSMutableArray*)entriesArr];
	}else {
		[expenseEntryViewController setIsEntriesAvailable:NO];
	}
	
	NSDictionary *_expenseSheet = [_expenseSheetsArray objectAtIndex:ind];
	[expenseEntryViewController setTotalReimbursement:[NSString stringWithFormat:@"%@ %@",[_expenseSheet objectForKey:@"reimburseCurrency"],
																[G2Util formatDoubleAsStringWithDecimalPlaces:[[_expenseSheet objectForKey:@"totalReimbursement"] doubleValue]]]];
	[expenseEntryViewController setDelegateObj:self];
	[expenseEntryViewController setExpenseSheetTitle:[_expenseSheet objectForKey:@"description"]];
	[expenseEntryViewController setExpenseSheetTrackingNo:[_expenseSheet objectForKey:@"trackingNumber"]];
	[expenseEntryViewController setSelectedSheetId:[_expenseSheet objectForKey:@"identity"]];
	[expenseEntryViewController setExpenseSheetStatus:[_expenseSheet objectForKey:@"status"]];

	
	[self.navigationController pushViewController:expenseEntryViewController animated:YES];
}

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(@"Back", @"Back") 
																	style:UIBarButtonItemStylePlain
																   target:nil
																   action:nil]; 
	self.navigationItem.backBarButtonItem = backButton;
	
	
}

-(void)viewDidAppear:(BOOL)animated
{
   
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

#pragma mark -
#pragma mark networkdelegaete


- (void) networkActivated {
	[self showAndHideMoreButton];
	
}

-(void)showAndHideMoreButton{
}
#pragma mark -
#pragma mark - actionMethods

-(void)showHideMoreButton{
	
	if ([NetworkMonitor isNetworkAvailableForListener:self] == YES){
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"nextRecentResponseCount"]intValue]==[[[G2AppProperties getInstance]getAppPropertyFor:@"NextRecentExpenseSheetsCount"]intValue]){ 
			[moreButton setHidden:NO];
			[imageView setHidden:NO];
            [self.expenseSheetTableView setTableFooterView:footerViewExpenses];
			[self setShowedExpensesCount:(showedExpensesCount - (5 - [[[NSUserDefaults standardUserDefaults] objectForKey:@"nextRecentResponseCount"]intValue]))];
	    }else {
			[moreButton setHidden:YES];
			[imageView setHidden:YES];
          [self hideEmptySeparators];	
			
		}
    }else if ([NetworkMonitor isNetworkAvailableForListener:self] == NO){
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"nextRecentResponseCount"]intValue]==[[[G2AppProperties getInstance]getAppPropertyFor:@"NextRecentExpenseSheetsCount"]intValue]){ 
		[moreButton setHidden:NO];
		[imageView setHidden:NO];
		}
		
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:showedExpensesCount] forKey:@"lastDownloadedSheetsCount"];
     [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)hideEmptySeparators
{
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor clearColor];
    [self.expenseSheetTableView setTableFooterView:v];
   
}

-(void)moreAction:(id)sender {
	
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
		#ifdef PHASE1_US2152
			[G2Util showOfflineAlert];
			return;
		#endif
	}
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
	[[G2RepliconServiceManager expensesService]sendRequestToFetchNextRecentExpenseSheets:[[[ NSUserDefaults standardUserDefaults] objectForKey:@"QueryHandler"]objectForKey:@"Identity"]
																		//withStartIndex:[NSNumber numberWithInt:[[[ NSUserDefaults standardUserDefaults]objectForKey:@"expenseSheetsArray"]count]]
	 withStartIndex:[NSNumber numberWithInteger:showedExpensesCount]
																		withLimitCount:[[G2AppProperties getInstance]getAppPropertyFor:@"NextRecentExpenseSheetsCount"]
																		  withDelegate:self];
	showedExpensesCount = showedExpensesCount + 5;
	
}

-(void)goBack:(id)sender{
	[[[UIApplication sharedApplication]delegate]performSelector:@selector(flipToHomeViewController)]; 
}

-(void)addExpenseSheetAction:(id)sender{
	
	#ifdef PHASE1_US2152
		if ([NetworkMonitor isNetworkAvailableForListener:self] == NO){
				[G2Util showOfflineAlert];
				return;
			}
	#endif
	
	ProjectPermissionType permType = [G2PermissionsModel getProjectPermissionType];
	
	if (permType == PermType_ProjectSpecific) {
		
		NSMutableArray *expSheetsArray = [expensesModel getExpenseSheetsFromDataBase];
		if (expSheetsArray!=nil &&  [expSheetsArray count]>0) 
		{
			[expSheetsArray removeAllObjects];
		}else {
			
			NSArray *projetsArray = [expensesModel getExpenseProjectsFromDatabase];
			if ([projetsArray count] == 0) {
//				[Util errorAlert:RPLocalizedString(ErrorTitle,@"") errorMessage:RPLocalizedString(@"You cannot enter expenses because you do not have any projects assigned.",@"")];
//				return;
			}
		}
	}
	
	G2NewExpenseSheetViewController *newExpenseSheetViewController = [[G2NewExpenseSheetViewController alloc]init];
	[newExpenseSheetViewController setTnewExpenseSheetDelegate:self];
	UINavigationController *tempnavcontroller = [[UINavigationController alloc]initWithRootViewController:newExpenseSheetViewController];
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
    
	self.navcontroller=tempnavcontroller;
    
	
	[self presentViewController:navcontroller animated:YES completion:nil];
	
	
}



-(void)reloadExpenseSheets{
	[expenseSheetTableView reloadData];
	[self showHideMoreButton];
}

#pragma mark -
#pragma mark - UITableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	//return Each_Cell_Row_Height_80;
	
	return Each_Cell_Row_Height_58;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
	NSArray *_expenseSheetsArray = [standardUserDefaults objectForKey:@"expenseSheetsArray"];
	
	if (_expenseSheetsArray != nil && [_expenseSheetsArray count]!= 0){
		return [_expenseSheetsArray count];
	}
	return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *CellIdentifier = @"Cell";
	
	G2CustomTableViewCell *cell  = (G2CustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	
	if (cell == nil) {
		cell = [[G2CustomTableViewCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //[cell setSelectionStyle:UITableViewCellSelectionStyleNone];	
		cell.backgroundView          = [[UIImageView alloc] init];
		//cell.selectedBackgroundView  = [[UIImageView alloc] init];
		
		UIImage *rowBackground       = [G2Util thumbnailImage:cellBackgroundImageView];

		
		((UIImageView *)cell.backgroundView).image = rowBackground;
	//	((UIImageView *)cell.selectedBackgroundView).image = selectionBackground;
		
	}	
	NSInteger ind =  indexPath.row;
	
	NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
	NSArray *_expenseSheetsArray = [standardUserDefaults objectForKey:@"expenseSheetsArray"];
	
	if ([_expenseSheetsArray count] > 0) {
		NSString *titleDetails        = @"";
		NSString *date                = @"";
	//	NSString *trackingNo          = @"";	//fixed memory leak
		NSString *cost		          = @"";
		NSString *statusText          = @"";
		UIColor	 *statusColor         = nil;
		UIColor	 *upperrighttextcolor = nil;
		BOOL	imgflag				  = NO;
		
	//	NSString *currencySecondStr   = nil;	//fixed memory leak
		NSDictionary *_expenseSheet   = [_expenseSheetsArray objectAtIndex:ind];
		
		titleDetails				  = [_expenseSheet objectForKey:@"description"];
		date						  = [_expenseSheet objectForKey:@"expenseDate"];
		if ([_expenseSheet objectForKey:@"editStatus"] !=nil && 
			!([[_expenseSheet objectForKey:@"editStatus"] isEqualToString:@"create"])){
		//	trackingNo = [_expenseSheet objectForKey:@"trackingNumber"];		//fixed memory leak
		}
		
		NSMutableArray *sortedCurrenciesArray=[expensesModel getEntryAmountsForExpenseSheet:[_expenseSheet objectForKey:@"identity"] forDescOrder:NO];
		NSUInteger i=[sortedCurrenciesArray count]-1;
		NSDictionary *_amountInfo = [sortedCurrenciesArray objectAtIndex:i];
		//[cell addCostLable];
		//[cell.cosetLable setTag:indexPath.row+1000];
		//[cell.secondCostLabel setTag:indexPath.row+2000];
		if ([sortedCurrenciesArray count]!=0) {
				NSString *currencyStr=nil;
				NSNumber *highestAmount=[NSNumber numberWithDouble:[[_amountInfo objectForKey:@"sum(netAmount)"]doubleValue]];
				NSString *formattedAmountString = [G2Util formatDoubleAsStringWithDecimalPlaces:[highestAmount doubleValue]];
				
				currencyStr        = [NSString stringWithFormat:@"%@ %@",[_amountInfo objectForKey:@"currencyType"]
								 ,formattedAmountString];
			
				cost   = currencyStr;
				if ([sortedCurrenciesArray count] > 1) 
				{
					NSMutableString *totalStr  = [NSMutableString stringWithFormat:@"%@",currencyStr];
					[totalStr appendString:@"..."];
					 cost = totalStr;
				}
						
		}else {
			cost = @"";
		//	currencySecondStr = @"";						//fixed memory leak
		}
		
		if ([[_expenseSheet objectForKey:@"status"]isEqualToString:NOT_SUBMITTED_STATUS]) {
			  statusText     = RPLocalizedString(NOT_SUBMITTED_STATUS, @"");
			  statusColor    = NotSubmittedTextColor;			
		} else if ([[_expenseSheet objectForKey:@"status"]isEqualToString:G2WAITING_FOR_APRROVAL_STATUS]) {
			statusText		 = RPLocalizedString(G2WAITING_FOR_APRROVAL_STATUS,@"Waiting for Approval status message");
			statusColor		 = WaitingTextColor;
		}else if ([[_expenseSheet objectForKey:@"status"]isEqualToString:REJECTED_STATUS]) {
			statusText		 = RPLocalizedString(REJECTED_STATUS,@"Rejected status message");
			statusColor		 = RejectedTextColor;
		}else if ([[_expenseSheet objectForKey:@"status"]isEqualToString:APPROVED_STATUS]) {
			statusText		 = RPLocalizedString(APPROVED_STATUS,@"Approved status message");
			statusColor		 = ApprovedTextColor;
		}
		[cell createCellLayoutWithParams:titleDetails upperlefttextcolor:upperrighttextcolor upperrightstr:cost lowerleftstr:date lowerlefttextcolor:RepliconStandardBlackColor lowerrightstr:statusText statuscolor:statusColor 
						   imageViewflag:imgflag hairlinerequired:YES];
		[[cell upperRight]setFrame:CGRectMake(130, 8.0, 180, 20)];
		[[cell lowerRight]setFrame:CGRectMake(130.0,35.0,180.0,14.0)]; 
		
	}
	[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
	return cell;
}

-(void)updateCellBackgroundWhenSelected:(NSIndexPath*)indexPath
{
	id cellObj = [self getCellForIndexPath:indexPath];
	if (cellObj == nil) {
		return;
	}
	
	[expenseSheetTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	
	[[cellObj upperLeft] setTextColor:iosStandaredWhiteColor];
	[[cellObj upperRight] setTextColor:iosStandaredWhiteColor];
	[[cellObj lowerLeft] setTextColor:iosStandaredWhiteColor];
	[[cellObj lowerRight] setTextColor:iosStandaredWhiteColor];
}

-(void)deSelectCellWhichWasHighLighted
{
	id cellObj = [self getCellForIndexPath:self.tappedIndexPath];
	if (cellObj == nil) {
		return;
	}
	
	[[cellObj upperLeft] setTextColor:RepliconStandardBlackColor];
	[[cellObj upperRight] setTextColor:RepliconStandardBlackColor];
	[[cellObj lowerLeft] setTextColor:RepliconStandardBlackColor];
	if ([[cellObj lowerRight].text isEqualToString:RPLocalizedString(NOT_SUBMITTED_STATUS, NOT_SUBMITTED_STATUS) ]) {
		[[cellObj lowerRight] setTextColor:NotSubmittedTextColor];
	}
	if ([[cellObj lowerRight].text isEqualToString:RPLocalizedString(APPROVED_STATUS,APPROVED_STATUS)]) {
		[[cellObj lowerRight] setTextColor:ApprovedTextColor];
	}
	if ([[cellObj lowerRight].text isEqualToString:RPLocalizedString(REJECTED_STATUS,REJECTED_STATUS)]) {
		[[cellObj lowerRight] setTextColor:RejectedTextColor];
	}
	if ([[cellObj lowerRight].text isEqualToString:RPLocalizedString(G2WAITING_FOR_APRROVAL_STATUS,G2WAITING_FOR_APRROVAL_STATUS)]) {
		[[cellObj lowerRight] setTextColor:WaitingTextColor];
	}
	
	[expenseSheetTableView deselectRowAtIndexPath:self.tappedIndexPath animated:YES];
}

-(void)highlightTheCellWhichWasSelected
{
	[self updateCellBackgroundWhenSelected:self.tappedIndexPath];
}
-(G2CustomTableViewCell*)getCellForIndexPath:(NSIndexPath*)indexPath
{
	G2CustomTableViewCell *cellAtIndex = (G2CustomTableViewCell *)[self.expenseSheetTableView cellForRowAtIndexPath: indexPath]; 
	return cellAtIndex;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)	{
		
		#ifdef PHASE1_US2152
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
			[G2Util showOfflineAlert];
			return;
		#endif
	}
	
//	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	[self setTappedIndexPath:indexPath];
	[self updateCellBackgroundWhenSelected:indexPath];
	
	NSInteger ind = indexPath.row;
	
	expenseEntryViewController = [[G2ListOfExpenseEntriesViewController alloc]init];
	[expenseEntryViewController setDelegateObj:self];
	[expenseEntryViewController setSelectedExpenseSheetIndex:[NSNumber numberWithInteger:ind]];
	
	NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
	NSArray *_expenseSheetsArray = [standardUserDefaults objectForKey:@"expenseSheetsArray"];
	NSArray *entriesArr = [expensesModel getEntriesforSelected: ind WithExpenseSheetArr: _expenseSheetsArray];
	NSDictionary *_expenseSheet = [_expenseSheetsArray objectAtIndex: ind];
	
	
	NSString *sheetName = [_expenseSheet objectForKey:@"description"];
	NSString *sheetTrackingNumber = [_expenseSheet objectForKey:@"trackingNumber"];
	NSString *sheetIdentity = [_expenseSheet objectForKey:@"identity"];
	NSString *sheetStatus = [_expenseSheet objectForKey:@"status"];
	BOOL	approversRemaining = [[_expenseSheet objectForKey:@"approversRemaining"] boolValue];
	
	[expenseEntryViewController setExpenseSheetTitle:sheetName];
	[expenseEntryViewController setExpenseSheetTrackingNo:sheetTrackingNumber];
	[expenseEntryViewController setSelectedSheetId:sheetIdentity];
	[expenseEntryViewController setExpenseSheetStatus:sheetStatus];
	[expenseEntryViewController setApproversRemaining:approversRemaining];
	
	NSString *_formattedAmountString = [G2Util formatDoubleAsStringWithDecimalPlaces:[[_expenseSheet objectForKey:@"totalReimbursement"] doubleValue]];
	NSString *_currencyStr=	[NSString stringWithFormat:@"%@ %@",[_expenseSheet objectForKey:@"reimburseCurrency"],_formattedAmountString];
	
	[expenseEntryViewController setTotalReimbursement: _currencyStr];
	
	
	
	ProjectPermissionType permType = [G2PermissionsModel getProjectPermissionType];
	NSArray *projectArray = [expensesModel getExpenseProjectsFromDatabase];
	
	
	
		if (_expenseSheet == nil) {
		DLog(@"Error: No expensesheet at index: %ld", (long)ind);
		return;
	}
	
	
	
	
		
	if ([entriesArr count]!=0) {
		[expenseEntryViewController setIsEntriesAvailable:YES];
		[expenseEntryViewController setExpenseEntriesArray:(NSMutableArray*)entriesArr];
		[self.navigationController pushViewController:expenseEntryViewController animated:YES];
	}else {
		[expenseEntryViewController setIsEntriesAvailable:NO];
		if ([sheetStatus isEqualToString:APPROVED_STATUS] || [sheetStatus isEqualToString:G2WAITING_FOR_APRROVAL_STATUS]) {
			[self.navigationController pushViewController:expenseEntryViewController animated:YES];
		}else {
			
			if (permType == PermType_ProjectSpecific)
			{
				if ([projectArray count] == 0) {
//					if (expenseEntryViewController !=nil)
//						[self.navigationController pushViewController:expenseEntryViewController animated:YES];
//						[Util errorAlert:RPLocalizedString(ErrorTitle,@"") errorMessage:RPLocalizedString( @"You cannot enter expenses because you do not have any projects assigned.",@"")];
//					return;
				}
				
			}
			
			
			NSString *projTempId = nil;
			if (projectArray != nil &&[projectArray count] == 1) {
				projTempId = [[projectArray objectAtIndex:0] objectForKey:@"identity"];
				
			}else {
				projTempId = @"null";
			}
			NSMutableArray *expenseTypeArr = [expensesModel getExpenseTypesWithTaxCodesForSelectedProjectId: projTempId];
			if (expenseTypeArr != nil && [expenseTypeArr count] == 0) {
//				[self.navigationController pushViewController:expenseEntryViewController animated:YES];
//				[Util errorAlert:RPLocalizedString(ErrorTitle,@"") errorMessage:RPLocalizedString( @"There are no available Expense Types.",@"")];
//				return;
			}
			
			[self showAddNewExpenseEntryPageByDefault:_expenseSheet];
			}
			//else {
//				[self.navigationController pushViewController:expenseEntryViewController animated:YES];
//			}

		//}
	}
	
	if ([[[self navigationController] viewControllers]containsObject:expenseEntryViewController]) {
		
	}
	
			
}

-(void)showAddNewExpenseEntryPageByDefault:(NSDictionary*)sheetContentsDict
{
	NSString *sheetName = [sheetContentsDict objectForKey:@"description"];
	NSString *sheetIdentity = [sheetContentsDict objectForKey:@"identity"];
	NSString *sheetStatus = [sheetContentsDict objectForKey:@"status"];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newEntrySavedResponse) name:@"NEW_ENTRY_SAVED" object:nil];
	addNewExpenseEntryViewController = [[G2AddNewExpenseViewController alloc]
										initWithTitle: sheetName sheetID:sheetIdentity];
	//[addNewExpenseEntryViewController setExpenseSheetID: sheetIdentity];
	[addNewExpenseEntryViewController setExpesneSheetStatus:sheetStatus];
	[addNewExpenseEntryViewController setIsEntriesAvailable:NO];
	[addNewExpenseEntryViewController setHidesBottomBarWhenPushed:YES];
    DLog(@"%@",self.navigationController.viewControllers);
     DLog(@"%@",self.navcontroller.viewControllers);
	[self.navigationController pushViewController:addNewExpenseEntryViewController animated:YES];
}

-(void)newEntrySavedResponse
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"NEW_ENTRY_SAVED" object:nil];
	NSMutableArray *arrayOfViewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
	[arrayOfViewControllers removeObjectIdenticalTo:addNewExpenseEntryViewController];
	[self.navigationController setViewControllers:arrayOfViewControllers];
	if (expenseEntryViewController !=nil) {
			//[arrayOfViewControllers addObject:expenseEntryViewController];
		if ([arrayOfViewControllers containsObject:expenseEntryViewController]) {
			[arrayOfViewControllers removeObjectIdenticalTo:expenseEntryViewController];
			[self.navigationController setViewControllers:arrayOfViewControllers];
			[self.navigationController pushViewController:expenseEntryViewController animated:NO];
		}else {
			[self.navigationController pushViewController:expenseEntryViewController animated:NO];
		}
	}

		/*if ([arrayOfViewControllers containsObject:listOfExpenseEntriesViewController2]) {
			[arrayOfViewControllers removeObjectIdenticalTo:listOfExpenseEntriesViewController2];
		}
		
	}else if (listOfExpenseEntriesViewController2 !=nil)	//[arrayOfViewControllers addObject:listOfExpenseEntriesViewController2];
		if ([arrayOfViewControllers containsObject:expenseEntryViewController]) {
			[arrayOfViewControllers removeObjectIdenticalTo:expenseEntryViewController];
		}
		if ([arrayOfViewControllers containsObject:listOfExpenseEntriesViewController2]) {
			[arrayOfViewControllers removeObjectIdenticalTo:listOfExpenseEntriesViewController2];
			[self.navigationController setViewControllers:arrayOfViewControllers];
			[self.navigationController pushViewController:listOfExpenseEntriesViewController2 animated:NO];
	}else {
		[self.navigationController pushViewController:listOfExpenseEntriesViewController2 animated:NO];
	}*/


	
}

#pragma mark -
#pragma mark ServerProtocolMethods
#pragma mark -

- (void) serverDidRespondWithResponse:(id) response {
	
	if (response!=nil) {
		NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
		if ([status isEqualToString:@"OK"]) {
			
			if ([[[response objectForKey:@"refDict"]objectForKey:@"refID"] intValue] == FetchNextRecentExpenseSheets_26) {
				
				NSArray *responseArray=[[response objectForKey:@"response"]objectForKey:@"Value"];
				[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
				if (responseArray!=nil && [responseArray count]==0) {
					[moreButton setHidden:YES];
					[imageView setHidden:YES];
                     [self hideEmptySeparators];		
					NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
					[standardUserDefaults setObject:[NSNumber numberWithUnsignedInteger:[responseArray count]] forKey:@"nextRecentResponseCount"];
                    [standardUserDefaults synchronize];
				}
				if (responseArray!=nil && [responseArray count]!=0) {
					[self handleNextRecentExpenseSheetsResponse:responseArray];
				}
			}
		}else {
			NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
			[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
			
			[self handleQueryHandlerException:message];
		}
	}
}

- (void) serverDidFailWithError:(NSError *) error{
	DLog(@"Critical Error: Server response error: %@", error);
    [self showErrorAlert:error];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==SAML_SESSION_TIMEOUT_TAG)
    {
        [[[UIApplication sharedApplication]delegate] performSelector:@selector(launchWebViewController)];
    }
}

-(void)showErrorAlert:(NSError *) error
{
    RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    if ([appdelegate.errorMessageForLogging isEqualToString:SESSION_EXPIRED]) {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
        {
            UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:nil message:RPLocalizedString(SESSION_EXPIRED, SESSION_EXPIRED)
                                                                      delegate:self cancelButtonTitle:RPLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
            [confirmAlertView setDelegate:self];
            [confirmAlertView setTag:SAML_SESSION_TIMEOUT_TAG];
            [confirmAlertView show];
           
        }
        else 
        {
            [G2Util errorAlert:AUTOLOGGING_ERROR_TITLE errorMessage:RPLocalizedString(SESSION_EXPIRED, SESSION_EXPIRED) ];
        }
        
    }
    else  if ([appdelegate.errorMessageForLogging isEqualToString:G2PASSWORD_EXPIRED]) {
        [G2Util errorAlert:AUTOLOGGING_ERROR_TITLE errorMessage:RPLocalizedString(G2PASSWORD_EXPIRED, G2PASSWORD_EXPIRED) ];
        [[[UIApplication sharedApplication]delegate] performSelector:@selector(reloaDLogin)];
    }
    
}


-(void)handleQueryHandlerException:(NSString*)exceptionMessage
{
	NSString *queryString = @"QueryHandle";
	NSMutableString *requiredString=[NSMutableString stringWithFormat:@"%@",exceptionMessage];
	if ([requiredString rangeOfString:queryString].location == NSNotFound) {
		DLog(@" Query Handle NOT FOUND");
		[G2Util errorAlert:RPLocalizedString(ErrorTitle,@"") errorMessage:exceptionMessage];
	} else {
		[[G2RepliconServiceManager expensesService]sendRequestToGetMostRecentExpenseSheets: 
		[[G2AppProperties getInstance]getAppPropertyFor:@"NextRecentExpenseSheetsCount"]:
		 [NSNumber numberWithInteger:showedExpensesCount] WithDelegate:[G2RepliconServiceManager expensesService]];
	}
}

-(void)handleNextRecentExpenseSheetsResponse:(id)response{
	
	
	[expensesModel insertExpenseSheetsInToDataBase:response];
	[expensesModel insertExpenseEntriesInToDataBase:response];
    [expensesModel insertUdfsforEntryIntoDatabase:response];//DE8266 Ullas M L
	NSUserDefaults *standardUserDefaults=[NSUserDefaults standardUserDefaults];
	[standardUserDefaults setObject:[NSNumber numberWithUnsignedInteger:[(NSMutableArray *)response count]] forKey:@"nextRecentResponseCount"];
	[standardUserDefaults setObject:[expensesModel getExpenseSheetsFromDataBase] forKey:@"expenseSheetsArray"];
	[standardUserDefaults synchronize];
	//ravi - ExpenseEntries are not required here. This function sets the expenseSheets into userdefaults
	//[standardUserDefaults setObject:[expensesModel getExpenseEntriesFromDatabase] forKey:@"expenseEntriesArray"];
	//NSArray *_expenseSheetsArray = [standardUserDefaults objectForKey:@"expenseSheetsArray"];
	
	//expenseEntriesArray= [standardUserDefaults objectForKey:@"expenseEntriesArray"];
	
	[self.expenseSheetTableView reloadData];
	[self showHideMoreButton];
    
    ProjectPermissionType projPermissionType = [G2PermissionsModel getProjectPermissionType];
	if (projPermissionType == PermType_Both || projPermissionType == PermType_ProjectSpecific)
	{
        
        
        ProjectPermissionType projPermissionType = [G2PermissionsModel getProjectPermissionType];
        if (projPermissionType == PermType_Both || projPermissionType == PermType_ProjectSpecific)
        {
            NSMutableArray *projectIdsArr=[NSMutableArray array];
            for (int i=0; i<[(NSMutableArray *)response count]; i++) {
                NSDictionary *_expense = [response objectAtIndex:i];
                NSArray *_expEntries = [[_expense objectForKey:@"Relationships"]objectForKey:@"Entries"];
                for (int j=0; j<[_expEntries count]; j++) {
                    
                    NSDictionary *_entry = [_expEntries objectAtIndex: j];
                    id projectsDict = [[_entry objectForKey:@"Relationships"]objectForKey:@"Project"];
                    if([projectsDict isKindOfClass:[NSDictionary class]])
                    {
                        NSString *projectIdentity=[projectsDict objectForKey:@"Identity"];
                        [projectIdsArr addObject:projectIdentity];
                    }
                }
            }
            if (projectIdsArr!=nil)
            {
                if ([projectIdsArr count]>0)
                {
                    [[G2RepliconServiceManager expensesService] sendRequestTogetExpenseProjectsWithProjectRelatedClients:[G2RepliconServiceManager expensesService] withProjectIds:projectIdsArr];
                    // totalRequestsSent++;
                }
            }
            
        }
        
        
        
	}
	
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.expenseSheetTableView=nil;
    self.footerViewExpenses=nil;
    self.imageView=nil;
}





@end
