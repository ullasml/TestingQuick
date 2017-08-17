//
//  ApprovalsUsersListOfExpenseEntriesViewController.m
//  Replicon
//
//  Created by Dipta Rakshit on 2/14/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "G2ApprovalsUsersListOfExpenseEntriesViewController.h"
#import "G2PermissionsModel.h"
#import "G2ViewUtil.h"
#import "RepliconAppDelegate.h"
#import "G2ApprovalsExpensesScrollViewController.h"


@interface G2ApprovalsUsersListOfExpenseEntriesViewController()
typedef enum {
    
        APPROVE_BUTTON_TAG_G2,
        REJECT_BUTTON_TAG_G2,
        COMMENTS_TEXTVIEW_TAG_G2,
   

} ExpenseSheetActionType;




@end

@implementation G2ApprovalsUsersListOfExpenseEntriesViewController

@synthesize expenseEntriesArray;
@synthesize expenseEntriesTableView;
@synthesize delegateObj;
@synthesize expenseSheetStatus;
@synthesize newEntryAddedToSheet;
@synthesize unsubmittedApproveArray;
@synthesize expenseSheetTrackingNo;
@synthesize expenseSheetTitle;
@synthesize selectedSheetId;
@synthesize totalReimbursement;
@synthesize afterDeletingLineItem;
@synthesize editedLineItemLoading;
@synthesize isEntriesAvailable;
@synthesize selectedExpenseSheetIndex;
@synthesize expenseEntriesArr;
@synthesize approversRemaining;
@synthesize tappedIndex;
@synthesize  deleteButton;
@synthesize deleteUnderlineLabel;
@synthesize  messageLabel;
@synthesize  amountLable,totalFooterLable;
@synthesize  footerView,footerButtonsView,totalAmountView;
@synthesize  submitButton;
@synthesize editExpenseEntryViewController;
@synthesize totalAmountsArray;
@synthesize currencyDetailsArray;
@synthesize backUpArr;
@synthesize expensesModel;
@synthesize permissionsModel;
@synthesize supportDataModel;
@synthesize delegate;
@synthesize allowBlankComments;
@synthesize currentViewTag;


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization.
 }
 return self;
 }
 */

- (UIImage *)newImageFromResource:(NSString *)filename
{
    NSString *imageFile = [[NSString alloc] initWithFormat:@"%@/%@",
                           [[NSBundle mainBundle] resourcePath], filename];
    UIImage *image = nil;
    image = [[UIImage alloc] initWithContentsOfFile:imageFile];
	
   
    return image;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		totalCurrencyPerType=0.0;
		[NetworkMonitor sharedInstance];
		
		if (expensesModel == nil) {
			G2ExpensesModel *tempexpensesModel = [[G2ExpensesModel alloc] init];
            self.expensesModel=tempexpensesModel;
            
		}
		if (supportDataModel==nil) {
			G2SupportDataModel *tempsupportDataModel = [[G2SupportDataModel alloc] init];
            self.supportDataModel=tempsupportDataModel;
            
		}
        if (permissionsModel==nil) {
			G2PermissionsModel *temppermissionsModel =[[G2PermissionsModel alloc]init];
            self.permissionsModel=temppermissionsModel;
            
		}
        if (backUpArr==nil) {
            NSMutableArray *tempbackUpArr =[[NSMutableArray alloc]init];
            self.backUpArr=tempbackUpArr;
            self.backUpArr=tempbackUpArr;
            
        }
        
		
		
		
		//showResumbitButton=NO;
		
	}
	return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    

	
}
//DE3395
-(void)highlightTheCellWhichWasSelected{
	[self updateCellBackgroundWhenSelected:self.tappedIndex];
}


-(void)loadView
{
	[super loadView];
    
    
 //   self.totalAmountsArray=[expensesModel fetchSumOfAmountsForEachCurrencyTypeWithSheetId:selectedSheetId];
	
    self.totalAmountsArray=[NSMutableArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"USD$",@"currencyType",@"52.39",@"sum(netAmount)", nil], nil];
    
	[self.view setBackgroundColor:G2RepliconStandardBackgroundColor];
	
	
   
	
    //    if ([expenseSheetStatus isEqualToString:NOT_SUBMITTED_STATUS]||[expenseSheetStatus isEqualToString:REJECTED_STATUS]) {
    //        UIBarButtonItem *addButtonIos=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)];
    //        [self.navigationItem setRightBarButtonItem:addButtonIos];
    //
    //    }
	
	
	if (isEntriesAvailable) {
		if (expenseEntriesTableView ==nil) {
			expenseEntriesTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , self.view.frame.size.height+145) style:UITableViewStylePlain];
		}
		[expenseEntriesTableView setDelegate:self];
		[expenseEntriesTableView setDataSource:self];
		
		UIView *bckView = [UIView new];
		[bckView setBackgroundColor:G2RepliconStandardBackgroundColor];
		[expenseEntriesTableView setBackgroundView:bckView];
		[self.view addSubview:expenseEntriesTableView];
		
		
		if ([expenseEntriesArray count]>0) {
			[self createFooterView];
			[self addReimburseLable];
		}
		for (int x=0; x<[totalAmountsArray count]; x++) {
			[self addTotalLable:x];
		}
		
	} else {
		
		if (footerView !=nil) {
			[footerView setHidden:YES];
		}
		[expenseEntriesTableView removeFromSuperview];
		
	}
    
    //DE2949 FadeOut is slow
    //DE3395
    [self performSelector:@selector(highlightTheCellWhichWasSelected) withObject:nil afterDelay:0];
    [self performSelector:@selector(deSelectCellWhichWasHighLighted) withObject:nil afterDelay:0.0];
    
    
    G2ApprovalTablesHeaderView *headerView=[[G2ApprovalTablesHeaderView alloc]initWithFrame:CGRectMake(0, 0, 360.0, 55.0 ):expenseSheetStatus];
    G2ApprovalsExpensesScrollViewController *scrollCtrl=(G2ApprovalsExpensesScrollViewController *)delegate;
    if (self.currentViewTag==0) {
        headerView.previousButton.hidden=TRUE;
    }
    if (self.currentViewTag==scrollCtrl.numberOfViews-1) {
        headerView.nextButton.hidden=TRUE;
    }
    //    headerView.timesheetStatus=sheetStatus;
    self.expenseEntriesTableView.tableHeaderView = headerView;
    headerView.delegate=self;
   
    
	if ([expenseEntriesArray count]>0) {
		//self.currencyDetailsArray = [expensesModel getCurrenciesInfoForExpenseSheetID:selectedSheetId];
         self.currencyDetailsArray=[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"USD$",@"currencyType",@"4.11",@"netAmount", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"USD$",@"currencyType",@"48.28",@"netAmount", nil], nil];
	}
	//[self sendRequestToGetApproversStatus];
}


-(void)sendRequestToGetApproversStatus
{
	
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:LoadingMessage];
	[[G2RepliconServiceManager expensesService] sendRequestToGetRemainingApproversForSubmittedExpenseSheetWithId:selectedSheetId delegate:self];
}



/*-(void)reloadEntries{	
	NSMutableArray *entriesArr=[expensesModel getEntriesForExpenseSheet:selectedSheetId];
	NSMutableArray *expenseSheetsArray=[expensesModel getSelectedExpenseSheetInfoFromDb:selectedSheetId];
	
	if ([entriesArr count]>0) {
		isEntriesAvailable = YES;
        if ([self.expenseEntriesArray retainCount]>0) {
 
            expenseEntriesArray=nil;
        }
		self.expenseEntriesArray = [entriesArr retain];
        
		//currencyDetailsArray = [[expensesModel getCurrenciesInfoForExpenseSheetID:selectedSheetId] retain];
        //self.currencyDetailsArray = [expensesModel getCurrenciesInfoForExpenseSheetID:selectedSheetId] ;
         self.currencyDetailsArray=[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"USD$",@"currencyType",@"4.11",@"netAmount", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"USD$",@"currencyType",@"48.28",@"netAmount", nil], nil];
        
		if (expenseSheetsArray!=nil && [expenseSheetsArray count] >0) {
			NSString *formattedTotalReimbursementString = [Util formatDoubleAsStringWithDecimalPlaces:[[[expenseSheetsArray objectAtIndex:0] objectForKey:@"totalReimbursement"]doubleValue]];
			
			[self setTotalReimbursement:[NSString stringWithFormat:@"%@ %@",[[expenseSheetsArray objectAtIndex:0] objectForKey:@"reimburseCurrency"],
										 formattedTotalReimbursementString]];	
		}
        
		
		[self.expenseEntriesTableView reloadData];
		[self performSelector:@selector(updateCellBackgroundWhenSelected:) withObject:self.tappedIndex];
		//[self performSelector:@selector(deSelectCellWhichWasHighLighted) withObject:nil afterDelay:0.5];//DE2949 FadeOut is slow
        [self performSelector:@selector(deSelectCellWhichWasHighLighted) withObject:nil afterDelay:0.0];
	}else {
        NSMutableArray *tempexpenseEntriesArray=[[NSMutableArray alloc]init];
		self.expenseEntriesArray = tempexpenseEntriesArray;
 
		isEntriesAvailable = NO;
		[self.expenseEntriesTableView reloadData];	
	}
} */

-(void)createFooterView {
    
	UIView *temptotalAmountView=[[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                         0.0,
                                                                         self.expenseEntriesTableView.frame.size.width,
                                                                         30+[totalAmountsArray count]*20)];
    self.totalAmountView=temptotalAmountView;
    
    
	
	
	submittedDetailsView.sheetStatus=expenseSheetStatus;
	submittedDetailsView = [[G2SubmittedDetailsView alloc]initWithFrame:CGRectMake(100,submitButton.frame.size.height+45,320,250)];
	submittedDetailsView.submitViewDelegate=self;
	submittedDetailsView.sheetId=selectedSheetId;
	[submittedDetailsView setBackgroundColor:[UIColor whiteColor]];
    
	//float footerHeight = self.expenseEntriesTableView.frame.size.height -(100- ([expenseEntriesArray count] * 5));
	float footerHeight = [totalAmountsArray count] *30 + 350;
	UIView *tempfooterButtonsView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                             totalAmountView.frame.size.height - 100,
                                                                             // self.expenseEntriesTableView.frame.size.width,
                                                                             self.view.frame.size.width,
                                                                             100)];
    self.footerButtonsView=tempfooterButtonsView;
   
	UIView *tempfooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                      footerButtonsView.frame.size.height,
                                                                      320,
                                                                      footerHeight )];
    self.footerView=tempfooterView;
   
	
    G2ApprovalTablesFooterView *approvalTablesfooterView=[[G2ApprovalTablesFooterView alloc]initWithFrame:CGRectMake(0,20.0, 360.0, 205.0 ) andStatus:expenseSheetStatus];
    
    approvalTablesfooterView.delegate=self;
    
	
    approvalTablesfooterView.frame=CGRectMake(0,50.0 , 360.0, 250.0 );
    
    
    [self.footerView addSubview:approvalTablesfooterView];
    
    
    
 	
	
	
	
	
    [footerView setBackgroundColor:G2RepliconStandardBackgroundColor];
    [footerButtonsView setBackgroundColor:G2RepliconStandardBackgroundColor];
    [self.expenseEntriesTableView setTableFooterView:self.footerView];    

}





-(void)addReimburseLable
{
	
	UILabel *reimbursementFooterLable = [[UILabel alloc] initWithFrame:CGRectMake(13.0,
																				  [totalAmountsArray count]*20,
																				  160,
																				  30.0)];
	
	[reimbursementFooterLable setBackgroundColor:[UIColor clearColor]];
	//[reimbursementFooterLable setTextColor:RepliconStandardBlackColor];
	[reimbursementFooterLable setTextColor:RepliconTimeEntryHeaderTextColor];
	[reimbursementFooterLable setText:RPLocalizedString(ReimburseText,@"")];
	//[reimbursementFooterLable setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
	[reimbursementFooterLable setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]];
	[reimbursementFooterLable setTextAlignment:NSTextAlignmentLeft];
	[reimbursementFooterLable setNumberOfLines:2];
	[totalAmountView addSubview:reimbursementFooterLable];
	
	UILabel *reimburseAmountLable = [[UILabel alloc] initWithFrame:CGRectMake(130.0,
																			  [totalAmountsArray count]*20,
																			  180,
																			  30.0)];
	[reimburseAmountLable setBackgroundColor:[UIColor clearColor]];
	//[reimburseAmountLable setTextColor:RepliconStandardBlackColor];
	[reimburseAmountLable setTextColor:RepliconTimeEntryHeaderTextColor];
	//[reimburseAmountLable setFont:[UIFont boldSystemFontOfSize:16]];
	//[reimburseAmountLable setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_14]];
	[reimburseAmountLable setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]];
	[reimburseAmountLable setTextAlignment:NSTextAlignmentRight];
	[reimburseAmountLable setNumberOfLines:1];
	[reimburseAmountLable setText:totalReimbursement];
	[totalAmountView addSubview:reimburseAmountLable];
	[totalAmountView setBackgroundColor:G2RepliconStandardBackgroundColor];
	
	[footerView addSubview:totalAmountView];
	//Handling Leaks
	
	
}

-(void)addTotalLable:(int)x
{
	
	//int count=[currencyDetailsArray count]-x-1;
	UILabel *temptotalFooterLable = [[UILabel alloc] initWithFrame:CGRectMake(13.0,
                                                                              x*20.0,
                                                                              80,
                                                                              30.0)];
    self.totalFooterLable=temptotalFooterLable;
   
	
	[totalFooterLable setBackgroundColor:[UIColor clearColor]];
	//[totalFooterLable setTextColor:RepliconStandardBlackColor];
	[totalFooterLable setTextColor:RepliconTimeEntryHeaderTextColor];
	[totalFooterLable setText:RPLocalizedString(TotalText,@"")];
	[totalFooterLable setTextAlignment: NSTextAlignmentRight];
	//[totalFooterLable setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
	[totalFooterLable setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]];
	[totalFooterLable setTextAlignment:NSTextAlignmentLeft];
	[totalFooterLable setNumberOfLines:1];
	[totalAmountView addSubview:totalFooterLable];
	
	UILabel *tempamountLable = [[UILabel alloc] initWithFrame:CGRectMake(130.0,
                                                                         x*20,
                                                                         180,
                                                                         30.0)];
    self.amountLable=tempamountLable;
    
	
	[amountLable setBackgroundColor:[UIColor clearColor]];
	//[amountLable setTextColor:RepliconStandardBlackColor];
	[amountLable setTextColor:RepliconTimeEntryHeaderTextColor];
	//[amountLable setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_14]];
	[amountLable setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]];
	[amountLable setTextAlignment:NSTextAlignmentRight];
	[amountLable setNumberOfLines:1];
	NSString *formattedAmountString  = [G2Util formatDoubleAsStringWithDecimalPlaces:[[[totalAmountsArray objectAtIndex:x]objectForKey:@"sum(netAmount)"] doubleValue]];
	
	[amountLable setTextAlignment: NSTextAlignmentRight];
	[amountLable setText:[NSString stringWithFormat:@"%@ %@",[[totalAmountsArray objectAtIndex:x]objectForKey:@"currencyType"],
						  formattedAmountString]];
	
	[totalAmountView addSubview:amountLable];
	[totalAmountView setBackgroundColor:[UIColor whiteColor]];
	[footerView addSubview:totalAmountView];
	
}


#pragma mark -
#pragma mark Action methods

-(void)goBack:(id)sender{
	
	if (delegateObj!=nil) {
		[self.navigationController popToViewController:delegateObj animated:YES];
	}
	
}






/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */
#pragma mark -
#pragma mark UITableView delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 1;	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	//return Each_Cell_Row_Height_80;
	return Each_Cell_Row_Height_58;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if ([expenseEntriesArray count] !=0) {
		return [expenseEntriesArray count];
	} 
	
	return 0;
}

/*- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
 UIImage *lineImage = [Util thumbnailImage:G2Cell_HairLine_Image];
 //DLog(@"lineImage.size.height %d",lineImage.size.height);
 UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(tableView.frame.origin.x,
 tableView.frame.origin.y, 
 tableView.frame.size.width,
 lineImage.size.height)];
 
 [lineImageView setImage:lineImage];
 return lineImageView;
 }
 - (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
 UIImage *lineImage = [Util thumbnailImage:G2Cell_HairLine_Image];
 return lineImage.size.height;
 }*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"Cell";
	
	G2CustomTableViewCell *cell  = (G2CustomTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[G2CustomTableViewCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		//[cell setSelectionStyle:UITableViewCellSelectionStyleNone];	
		cell.backgroundView          = [[UIImageView alloc] init];
		
		
		UIImage *rowBackground       = [G2Util thumbnailImage:cellBackgroundImageView];
		//UIImage *selectionBackground = [Util thumbnailImage:cellBackgroundImageView_select];
		
		((UIImageView *)cell.backgroundView).image = rowBackground;
		//((UIImageView *)cell.selectedBackgroundView).image = selectionBackground;
	}
	NSInteger currencycount=0;
	NSString *currencyValue=nil;
	
	NSInteger ind=[expenseEntriesArray count]- indexPath.row-1;
	if ([currencyDetailsArray count]>0) {
		currencycount=[currencyDetailsArray count]-indexPath.row-1;
		currencyValue = [[currencyDetailsArray objectAtIndex:ind]objectForKey:@"netAmount"];
		
	}
	
	//[cell createExpenseEntriesfields];
	if ([expenseEntriesArray count] > 0) {
        //	NSString *titleDetails      = @"";		//fixed memory leak
		NSString *clientProject     = @"";
		NSString *cost			    = @"";
		NSString *date			    = @"";
		NSString *showRecieptImage  = nil;
		BOOL imgflag				= NO;
		UIColor	 *statusColor       = nil;
		UIColor	 *upperrighttextcolor = nil;
		
		id description = [[expenseEntriesArray objectAtIndex:ind] objectForKey:@"description"];
		if ([description isKindOfClass:[NSNull class]]) {
		}else if ([description isEqualToString:@"null"]) {
            //	titleDetails = RPLocalizedString(NONE_STRING,@"");		//fixed memory leak
		}else {
            //	titleDetails = RPLocalizedString(description,@"");		//fixed memory leak
		}
		
		if ([[[expenseEntriesArray objectAtIndex:ind] objectForKey:@"expenseTypeName"]isKindOfClass:[NSNull class]]) {
			clientProject = RPLocalizedString(NONE_STRING,@"");
		}else if ([[[expenseEntriesArray objectAtIndex:ind] objectForKey:@"expenseTypeName"] isEqualToString:@"null"]) {
			clientProject = RPLocalizedString(NONE_STRING,@"");
		}else {
			clientProject = RPLocalizedString([[expenseEntriesArray objectAtIndex:ind] objectForKey:@"expenseTypeName"],@"");
		}
		
		showRecieptImage  = [[expenseEntriesArray objectAtIndex:ind] objectForKey:@"expenseReceipt"];
		if (showRecieptImage!=nil && [showRecieptImage isEqualToString:@"Yes"]) {
			imgflag = YES;
			
		}
        
        
		NSString *formattedAmountString = [G2Util formatDoubleAsStringWithDecimalPlaces:[currencyValue doubleValue]];
		if (currencyDetailsArray!=nil && [currencyDetailsArray count]>0) {
			cost = [NSString stringWithFormat:@"%@ %@",[[currencyDetailsArray objectAtIndex:currencycount]objectForKey:@"currencyType"],formattedAmountString];			
		}
		date = [G2Util getDeviceRegionalDateString:[[expenseEntriesArray objectAtIndex:ind] objectForKey:@"entryDate"]];
		
		[cell createCellLayoutWithParams:clientProject upperlefttextcolor:upperrighttextcolor 
						   upperrightstr:cost lowerleftstr:date lowerlefttextcolor:RepliconStandardBlackColor lowerrightstr:@"" 
							 statuscolor:statusColor imageViewflag:imgflag hairlinerequired:YES];
		if (imgflag) {
			[cell addReceiptImage];
			UIImage *receiptImage=[G2Util thumbnailImage:Receipt_Camera_Image];
			[cell.lowerRightImageView setImage:receiptImage];
			[[cell lowerRightImageView] setHidden:NO];
		}else {
			if ([cell lowerRightImageView]!=nil) {
				[[cell lowerRightImageView] setHidden:YES];
				[[cell lowerRightImageView] removeFromSuperview];
			}
		}
		
		[[cell upperLeft]setFrame:CGRectMake(13, 3, 180, 30)];
		[[cell upperRight]setFrame:CGRectMake(130, 3, 180, 30)];
		
	}
	[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
	return cell;
	
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)	{
		
#ifdef PHASE1_US2152
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [G2Util showOfflineAlert];
        return;
#endif
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//Get Info for the selected Expense entry to Edit
    
    
    
    
    
    [self.backUpArr removeAllObjects];    
    
	
	if ([expenseEntriesArray count]>0) {
		for (int i=0; i<[expenseEntriesArray count]; i++) {
			[backUpArr insertObject:[expenseEntriesArray objectAtIndex:[expenseEntriesArray count]-i-1] atIndex:i];
		}
		
		NSDictionary *dict=[NSDictionary dictionaryWithDictionary:[backUpArr objectAtIndex:indexPath.row]];
        DLog(@"%@",dict);
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"SELECTED_EXPENSE_ENTRY"]) 
        {
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SELECTED_EXPENSE_ENTRY"];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:dict
                                                  forKey:@"SELECTED_EXPENSE_ENTRY"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
		//DLog(@"**********Expense entry before Editing**********\n %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"SELECTED_EXPENSE_ENTRY"]);
		
	}
	[self updateCellBackgroundWhenSelected:indexPath];
	
	[self setTappedIndex:indexPath];
	//Handling Leaks
	//Try editing an expense entry
	G2ApprovalsEditExpenseEntryViewController *tempeditExpenseEntryViewController = [[G2ApprovalsEditExpenseEntryViewController alloc]init];
    self.editExpenseEntryViewController=tempeditExpenseEntryViewController;
   
	//[editExpenseEntryViewController.topToolbarLabel setText:[[backUpArr objectAtIndex:indexPath.row]objectForKey:@"description"]];
//	BOOL cannotEdit = YES;
    BOOL cannotEdit = NO;
	if ([expenseSheetStatus isEqualToString:NOT_SUBMITTED_STATUS] ||[expenseSheetStatus isEqualToString:REJECTED_STATUS]) {
		cannotEdit= NO;
	}
	[editExpenseEntryViewController setCanNotEdit:cannotEdit];
	[editExpenseEntryViewController setExpenseSheetStatus:expenseSheetStatus];
	[editExpenseEntryViewController setHidesBottomBarWhenPushed:YES];
	[editExpenseEntryViewController setEditControllerDelegate:self];
//	[self.navigationController pushViewController:editExpenseEntryViewController animated:YES];
        if ([delegate respondsToSelector:@selector(pushToEditExpenseEntryViewController:)])
        [delegate pushToEditExpenseEntryViewController:editExpenseEntryViewController];
	
	if ([[[backUpArr objectAtIndex:indexPath.row] objectForKey:@"expenseReceipt"] isEqualToString:@"Yes"]) {
		//[editExpenseEntryViewController getReceiptImage];
	}
	
	
}

-(void)updateCellBackgroundWhenSelected:(NSIndexPath*)indexPath
{
	id cellObj = [self getCellForIndexPath:indexPath];
	if (cellObj == nil) {
		return;
	}
	
	[expenseEntriesTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	
	[[cellObj upperLeft] setTextColor:iosStandaredWhiteColor];
	[[cellObj upperRight] setTextColor:iosStandaredWhiteColor];
	[[cellObj lowerLeft] setTextColor:iosStandaredWhiteColor];
	[[cellObj lowerRight] setTextColor:iosStandaredWhiteColor];
}

-(void)deSelectCellWhichWasHighLighted
{
	id cellObj = [self getCellForIndexPath:self.tappedIndex];
	if (cellObj == nil) {
		return;
	}
	[[cellObj upperLeft] setTextColor:RepliconStandardBlackColor];
	[[cellObj upperRight] setTextColor:RepliconStandardBlackColor];
	[[cellObj lowerLeft] setTextColor:RepliconStandardBlackColor];
	[[cellObj lowerRight] setTextColor:RepliconStandardBlackColor];
	[expenseEntriesTableView deselectRowAtIndexPath:self.tappedIndex animated:YES];
}

-(G2CustomTableViewCell*)getCellForIndexPath:(NSIndexPath*)indexPath
{
    G2CustomTableViewCell *cellAtIndex = (G2CustomTableViewCell *)[self.expenseEntriesTableView cellForRowAtIndexPath: indexPath]; 
    return cellAtIndex;
}
-(void)newEntryIsAddedToSheet
{
	NSIndexPath *newIndex = [NSIndexPath indexPathForRow:0 inSection:0];
	[self setTappedIndex:newIndex];
}

- (void)handleButtonClickForFooterView:(NSInteger)senderTag
{
    
    if (senderTag==APPROVE_BUTTON_TAG_G2)
    {
        DLog(@"APPROVE BUTTON CLICKED");
    }
    else if (senderTag==REJECT_BUTTON_TAG_G2)
    {
        DLog(@"REJECT BUTTON CLICKED");
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
    
    for (int i = 0; i < [[self.expenseEntriesTableView.tableFooterView subviews] count]; i++ ) 
    {
        if( [[[self.expenseEntriesTableView.tableFooterView subviews] objectAtIndex:i] isKindOfClass:[G2ApprovalTablesFooterView class] ] )
        {
            approvalTablesfooterView = (G2ApprovalTablesFooterView *)[[self.expenseEntriesTableView.tableFooterView subviews] objectAtIndex:i];
        }
    }
    if (approvalTablesfooterView) {
        
        if ([expenseSheetStatus isEqualToString:APPROVED_STATUS] || [expenseSheetStatus isEqualToString:REJECTED_STATUS])
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
            
            for (int i = 0; i < [[ self.footerView subviews] count]; i++ ) 
            {
                if( [[[self.footerView subviews] objectAtIndex:i] isKindOfClass:[G2ApprovalTablesFooterView class] ] )
                {
                    float height=approvalTablesfooterView.frame.size.height-205.0;
                    [[[self.footerView subviews] objectAtIndex:i] removeFromSuperview];
                    [ self.footerView addSubview:approvalTablesfooterView];
                    self.footerView.frame= CGRectMake(0, 0.0, 320.0, 215.0+height+250.0);
                    [self.expenseEntriesTableView setTableFooterView:self.footerView];
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
            
            [approvalTablesfooterView.commentsTextView setFrame:frame];
            frame=approvalTablesfooterView.approveButton.frame;
            
            frame.origin.y=size.height +95.0;
            
            [approvalTablesfooterView.approveButton setFrame:frame];
            frame=approvalTablesfooterView.rejectButton.frame;
            
            frame.origin.y=size.height +95.0;
            [approvalTablesfooterView.rejectButton setFrame:frame];
            frame=approvalTablesfooterView.frame;
            frame.size.height=60.0+size.height +15+110.0+20.0;
            approvalTablesfooterView.frame=frame;
            
            for (int i = 0; i < [[ self.footerView subviews] count]; i++ ) 
            {
                if( [[[self.footerView subviews] objectAtIndex:i] isKindOfClass:[G2ApprovalTablesFooterView class] ] )
                {
                    float height=approvalTablesfooterView.frame.size.height-205.0;
                    [[[self.footerView subviews] objectAtIndex:i] removeFromSuperview];
                    [ self.footerView addSubview:approvalTablesfooterView];
                    self.footerView.frame= CGRectMake(0, 0.0, 320.0, 215.0+height+250.0);
                    [self.expenseEntriesTableView setTableFooterView:self.footerView];
                    break;
                }
                
            }
            
        }
        
        
        
    }
    
    
    
    
}


#pragma mark -
#pragma mark Service protocols

- (void) serverDidRespondWithResponse:(id) response {}

- (void) serverDidFailWithError:(NSError *) error {}

-(void)showErrorAlert:(NSError *) error
{}


- (void) networkActivated {
	
	
	
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
	//[delegateObj performSelector:@selector(highlightTheCellWhichWasSelected) withObject:nil afterDelay:1];
    //	[delegateObj performSelector:@selector(deSelectCellWhichWasHighLighted) withObject:nil afterDelay:2];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.expenseEntriesTableView=nil;
    self.deleteButton=nil;
    self.deleteUnderlineLabel=nil;
    self.messageLabel=nil;
    self.amountLable=nil;
    self.totalFooterLable=nil;
    self.footerView=nil;
    self.footerButtonsView=nil;
    self.totalAmountView=nil;
}





@end
