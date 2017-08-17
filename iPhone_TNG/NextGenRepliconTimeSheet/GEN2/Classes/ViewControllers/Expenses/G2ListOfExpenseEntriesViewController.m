//
//  ListOfExpenseEntriesViewController.m
//  Replicon
//
//  Created by Hemabindu on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2ListOfExpenseEntriesViewController.h"
#import "G2PermissionsModel.h"
#import "G2ViewUtil.h"
#import "RepliconAppDelegate.h"

@interface G2ListOfExpenseEntriesViewController()
typedef enum {
	EXPSHEET_ACTION_SUBMIT,
	EXPSHEET_ACTION_UNSUBMIT,
	EXPSHEET_ACTION_DELETE,
	EXPSHEET_ACTION_RESUBMIT
} ExpenseSheetActionType;

- (void)confirmAlert: (NSString *)_buttonTitle forAction: (ExpenseSheetActionType)actionType confirmMessage: (NSString*) message;
- (void)submitAction: (id)sender;
- (void)resubmitAction: (id)sender;
- (void)unSubmitAction: (id)sender;
- (void)deleteAction: (id)sender;


@end

@implementation G2ListOfExpenseEntriesViewController

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

@synthesize totalAmountsArray;
@synthesize currencyDetailsArray;
@synthesize backUpArr;
@synthesize expensesModel;
@synthesize permissionsModel;
@synthesize supportDataModel;
//@synthesize submitButton;
//US2669//Juhi
@synthesize allowBlankComments;
@synthesize resubmitViewController;
@synthesize ret;
@synthesize submittedDetailsView;

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

        //        if (expenseEntriesArray==nil) {
        //            NSMutableArray *tempexpenseEntriesArray=[[NSMutableArray alloc]init];
        //            self.expenseEntriesArray=tempexpenseEntriesArray;
        //
        //        }
        //        
        
        
        [self registerForNotification];	
        //showResumbitButton=NO;
	}
	return self;
}



-(void)viewWillAppear:(BOOL)animated
{
    RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    appdelegate.isUserPressedCancel=NO;//US4234 Ullas M L

	self.totalAmountsArray=[expensesModel fetchSumOfAmountsForEachCurrencyTypeWithSheetId:selectedSheetId];
	
	[self.view setBackgroundColor:G2RepliconStandardBackgroundColor];
	
	
	//[self.navigationController.navigationBar setTintColor:RepliconStandardNavBarTintColor];
	
	[G2ViewUtil setToolbarLabel:self withText: expenseSheetTitle];
	
	
if ([expenseSheetStatus isEqualToString:NOT_SUBMITTED_STATUS]||[expenseSheetStatus isEqualToString:REJECTED_STATUS]) {
	UIBarButtonItem *addButtonIos=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)];
	[self.navigationItem setRightBarButtonItem:addButtonIos];
	
}
	
	
	if (isEntriesAvailable) {
		if (expenseEntriesTableView ==nil) {
			expenseEntriesTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , self.view.frame.size.height) style:UITableViewStylePlain];
		}
		[expenseEntriesTableView setDelegate:self];
		[expenseEntriesTableView setDataSource:self];
		 self.expenseEntriesTableView.separatorColor = [UIColor blackColor];
        
		UIView *bckView = [UIView new];
		[bckView setBackgroundColor:G2RepliconStandardBackgroundColor];
		[expenseEntriesTableView setBackgroundView:bckView];
		[self.view addSubview:expenseEntriesTableView];
		
		
		if ([self.expenseEntriesArray count]>0) {
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
		[self addDeleteButtonWithMessage];
	}
    
    //DE2949 FadeOut is slow
    //DE3395
    [self performSelector:@selector(highlightTheCellWhichWasSelected) withObject:nil afterDelay:0];
    [self performSelector:@selector(deSelectCellWhichWasHighLighted) withObject:nil afterDelay:0.0];

}
//DE3395
-(void)highlightTheCellWhichWasSelected{
	[self updateCellBackgroundWhenSelected:self.tappedIndex];
}


-(void)loadView
{
	[super loadView];
	if ([self.expenseEntriesArray count]>0) {
		self.currencyDetailsArray = [expensesModel getCurrenciesInfoForExpenseSheetID:selectedSheetId];
	}
	//[self sendRequestToGetApproversStatus];
}

-(void)addDeleteButtonWithMessage
{
	if (messageLabel == nil) 
    {
		UILabel *tempmessageLabel = [[UILabel alloc] init];
        self.messageLabel=tempmessageLabel;
       
    }
	self.messageLabel.frame=CGRectMake(40, (self.view.frame.size.height/3)-10, self.view.frame.size.width, 30);
        [self.messageLabel setText:RPLocalizedString(G2NoSheetsAvailable, "") ];
 
	[messageLabel setTextColor:RepliconStandardBlackColor];
	[messageLabel  setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_14]];
	[messageLabel setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:messageLabel];
	[self addDeleteButtonToView:messageLabel.frame.origin.y+25 view:self.view];
	[deleteButton setFrame:CGRectMake(60,deleteButton.frame.origin.y, 190, 30)];
	[deleteUnderlineLabel setFrame:CGRectMake(133,deleteUnderlineLabel.frame.origin.y,44,2)];//27 difference in...
	
}
-(void)sendRequestToGetApproversStatus
{
	
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
	[[G2RepliconServiceManager expensesService] sendRequestToGetRemainingApproversForSubmittedExpenseSheetWithId:selectedSheetId delegate:self];
}
-(void)registerForNotification{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unSubmitAction:) 
												 name:@"UnsubmitExpenseSheetNotification"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadEntries) 
												 name:@"ExpenseEntriesNotification"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goBackToSheets) name:@"GoBackToSheets" object:nil];
}

-(void)goBackToSheets
{
	[self.navigationController popViewControllerAnimated:YES];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"GoBackToSheets" object:nil];
}
-(void)reloadEntries{	
	NSMutableArray *entriesArr=[expensesModel getEntriesForExpenseSheet:selectedSheetId];
	NSMutableArray *expenseSheetsArray=[expensesModel getSelectedExpenseSheetInfoFromDb:selectedSheetId];
	
	if ([entriesArr count]>0) {
		isEntriesAvailable = YES;
  


       
        self.expenseEntriesArray = entriesArr ;
        
		//currencyDetailsArray = [[expensesModel getCurrenciesInfoForExpenseSheetID:selectedSheetId] retain];
        self.currencyDetailsArray = [expensesModel getCurrenciesInfoForExpenseSheetID:selectedSheetId] ;

		if (expenseSheetsArray!=nil && [expenseSheetsArray count] >0) {
			NSString *formattedTotalReimbursementString = [G2Util formatDoubleAsStringWithDecimalPlaces:[[[expenseSheetsArray objectAtIndex:0] objectForKey:@"totalReimbursement"]doubleValue]];
			
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
}

-(void)createFooterView {
	UIView *temptotalAmountView=[[UIView alloc] initWithFrame:CGRectMake(0.0,
															 0.0,
															 self.expenseEntriesTableView.frame.size.width,
															 30+[totalAmountsArray count]*20)];
    self.totalAmountView=temptotalAmountView;
    

	submitButton =[UIButton buttonWithType:UIButtonTypeCustom];
	
	[submitButton setHidden:YES];
	UIImage *img = [G2Util thumbnailImage:submitButtonImage];
	UIImage * img1 = [G2Util thumbnailImage:submitButtonImageSelected];
	
	[submitButton setBackgroundImage:img forState:UIControlStateNormal];
	[submitButton setBackgroundImage:img1 forState:UIControlStateHighlighted];
	
	[submitButton setFrame:CGRectMake(40.0, totalAmountView.frame.size.height+30.0, img.size.width, img.size.height)];
    submitButton.titleEdgeInsets = UIEdgeInsetsMake(-5.0, 0, 0, 0);
	[submitButton setTag:0];
	//submitButton.center = self.view.center;
	
	submittedDetailsView.sheetStatus=expenseSheetStatus;
	G2SubmittedDetailsView *tempsubmittedDetailsView = [[G2SubmittedDetailsView alloc]initWithFrame:CGRectMake(100,submitButton.frame.size.height+45,320,250)];
    self.submittedDetailsView=tempsubmittedDetailsView;
    
	submittedDetailsView.submitViewDelegate=self;
	submittedDetailsView.sheetId=selectedSheetId;
	[submittedDetailsView setBackgroundColor:[UIColor whiteColor]];
		
	//float footerHeight = self.expenseEntriesTableView.frame.size.height -(100- ([expenseEntriesArray count] * 5));
//	float footerHeight = [totalAmountsArray count] *30 + 350;
    
	UIView *tempfooterButtonsView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
																 totalAmountView.frame.size.height +totalAmountView.frame.origin.y,
																// self.expenseEntriesTableView.frame.size.width,
																 self.view.frame.size.width,
																  submitButton.frame.origin.y+submitButton.frame.size.height+30)];
    self.footerButtonsView=tempfooterButtonsView;
    
    
    
    //DE5750//Juhi
    float footerHeight = 0.0;
    if ([expenseSheetStatus isEqualToString: APPROVED_STATUS]) {
        
        footerHeight=totalAmountView.frame.size.height+7.0;
    }
    else if([expenseSheetStatus isEqualToString: G2WAITING_FOR_APRROVAL_STATUS])
    {
        if (![permissionsModel checkUserPermissionWithPermissionName:@"UnsubmitExpense"])
        {
            footerHeight=totalAmountView.frame.size.height+7.0;
        }
        else
        {
           footerHeight=totalAmountView.frame.size.height+30.0+submitButton.frame.size.height+25.0; 
        }
            
    }
    else
    {
        footerHeight=totalAmountView.frame.size.height+30.0+submitButton.frame.size.height+20.0+37.0+20.0;
    }

    UIView *tempfooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                                      totalAmountView.frame.size.height +totalAmountView.frame.origin.y,
                                                                      320,
                                                                      footerHeight )];
    self.footerView=tempfooterView;
    

	
	NSMutableArray *unsubmittedSheets = [[NSUserDefaults standardUserDefaults] objectForKey:UNSUBMITTED_EXPENSE_SHEETS];
	BOOL sheetUnsubmitted = [unsubmittedSheets containsObject:selectedSheetId];
	
	if ([expenseSheetStatus isEqualToString: NOT_SUBMITTED_STATUS]) {
		if (!sheetUnsubmitted) {
			[submitButton setTitle:RPLocalizedString(SUBMIT, SUBMIT) forState: UIControlStateNormal];
			[submitButton addTarget:self action:@selector(submitAction:) forControlEvents: UIControlEventTouchUpInside];
			[submitButton setHidden:NO];
		}
		else {
			[submitButton setTitle:RPLocalizedString(RESUBMIT, RESUBMIT) forState: UIControlStateNormal];
			[submitButton addTarget:self action:@selector(resubmitAction:) forControlEvents: UIControlEventTouchUpInside];
			[submitButton setHidden:NO];
		}

		
	} else if ([expenseSheetStatus isEqualToString:REJECTED_STATUS])	{
		[submitButton setTitle:RPLocalizedString(RESUBMIT, RESUBMIT) forState: UIControlStateNormal];	
		[submitButton addTarget:self action:@selector(resubmitAction:) forControlEvents: UIControlEventTouchUpInside];			
		[submitButton setHidden:NO];
	} else if ([expenseSheetStatus isEqualToString: G2WAITING_FOR_APRROVAL_STATUS] && !approversRemaining)	{
		[submitButton setTitle:RPLocalizedString(UNSUBMIT, UNSUBMIT) forState: UIControlStateNormal];	
		[submitButton addTarget:self action:@selector(unSubmitAction:) forControlEvents: UIControlEventTouchUpInside];
			if ([permissionsModel checkUserPermissionWithPermissionName:@"UnsubmitExpense"])
					[submitButton setHidden:NO];
	} 

	
	
	if ([expenseSheetStatus isEqualToString:NOT_SUBMITTED_STATUS] || [expenseSheetStatus isEqualToString:REJECTED_STATUS]) {
		float submitButtonHeight = submitButton.frame.origin.y+submitButton.frame.size.height;
        
		[self addDeleteButtonToView:submitButtonHeight view:footerView];
	}
	
	
		[footerView setBackgroundColor:G2RepliconStandardBackgroundColor];
		 [footerButtonsView setBackgroundColor:G2RepliconStandardBackgroundColor];
	if (![expenseSheetStatus isEqualToString: APPROVED_STATUS])
		 [footerView addSubview:submitButton];
		 [self.expenseEntriesTableView setTableFooterView:footerView];
		
}

-(void)addDeleteButtonToView:(float)position view:(UIView*)viewToAdd
{
	if (deleteButton == nil)
    {
       UIButton  *tempdeleteButton =[[UIButton alloc]init];
        self.deleteButton=tempdeleteButton;
       
    }
	self.deleteButton.frame=CGRectMake(70,position+20, 190, 30);	
	[deleteButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
	[deleteButton setTitle:RPLocalizedString( DELETE,@"Delete") forState:UIControlStateNormal];
	[deleteButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_15]];
	[deleteButton setTitleColor:RepliconTimeEntryHeaderTextColor forState:UIControlStateNormal]; 
	[deleteButton setBackgroundColor:[UIColor clearColor]];
	[viewToAdd addSubview:deleteButton];
	
	if (deleteUnderlineLabel == nil)
    {
		UILabel *tempdeleteUnderlineLabel = [[UILabel alloc]init];
        self.deleteUnderlineLabel=tempdeleteUnderlineLabel;
        
    }
    self.deleteUnderlineLabel.frame=CGRectMake(143,position+45,44,2);
    //27 difference in...
		[deleteUnderlineLabel setBackgroundColor:RepliconTimeEntryHeaderTextColor];
		[viewToAdd addSubview:deleteUnderlineLabel];
}



/*-(void)addUnsubmitButtonForWaitingSheets
{
	UIButton *unsubmitButton=nil;
	unsubmitButton =[[UIButton alloc]initWithFrame:CGRectMake(50,100, 240, 30)];
	[unsubmitButton addTarget:self action:@selector(unSubmitAction:) forControlEvents:UIControlEventTouchUpInside];
	[unsubmitButton setTitleColor:FreeTrailLabelTextColor forState:UIControlStateNormal]; 
	[unsubmitButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
	[unsubmitButton setBackgroundColor:[UIColor clearColor]];
	[unsubmitButton setUserInteractionEnabled:YES];
	[unsubmitButton setTitle:RPLocalizedString( @"Unsubmit This Expense Sheet",@"") forState:UIControlStateNormal];
	unsubmitButton.titleLabel.font =[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_14];
	
	[footerView addSubview:unsubmitButton];
	UILabel *underlineLabel=nil;
	underlineLabel = [[UILabel alloc]initWithFrame:CGRectMake(20,22,200,2)];
	[underlineLabel setText:@"_"];
	[underlineLabel setTextAlignment:NSTextAlignmentLeft];
	[underlineLabel setBackgroundColor:FreeTrailLabelTextColor];
	[unsubmitButton addSubview:underlineLabel];
	//[self addSubview:underlineLabel];//commentd for removing approvers temperorily .........
	
}*/


-(void)addReimburseLable
{
	
	UILabel *reimbursementFooterLable = [[UILabel alloc] initWithFrame:CGRectMake(10.0,
																				  [totalAmountsArray count]*20,
																				  160,
																				  30.0)];//US4065//Juhi
	
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
  
    //US4065//Juhi
    UIImage *totalLineImage=[G2Util thumbnailImage:G2Cell_HairLine_Image];
    UIImageView *totalLineImageview=[[UIImageView alloc]initWithImage:totalLineImage];
    totalLineImageview.frame=CGRectMake(0.0,
                                        [totalAmountsArray count]*20+30,
                                        totalLineImage.size.width,
                                        totalLineImage.size.height);
    
    
    [totalLineImageview setBackgroundColor:[UIColor clearColor]];
    [totalLineImageview setUserInteractionEnabled:NO];
    [totalAmountView addSubview:totalLineImageview];
    
    
	//Handling Leaks
	
}

-(void)addTotalLable:(int)x
{
	
	//int count=[currencyDetailsArray count]-x-1;
	UILabel *temptotalFooterLable = [[UILabel alloc] initWithFrame:CGRectMake(10.0,
																 x*20.0,
																 80,
																 30.0)];//US4065//Juhi
    self.totalFooterLable=temptotalFooterLable;
    
	
	[totalFooterLable setBackgroundColor:[UIColor clearColor]];
	//[totalFooterLable setTextColor:RepliconStandardBlackColor];
	[totalFooterLable setTextColor:RepliconTimeEntryHeaderTextColor];
	[totalFooterLable setText:RPLocalizedString(G2TotalString,@"")];
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

-(void)addAction:(id)sender{
	
#ifdef PHASE1_US2152
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO){
		[G2Util showOfflineAlert];
		return;
	}
#endif
	
	ProjectPermissionType permType = [G2PermissionsModel getProjectPermissionType];
	NSArray *projectArray = [expensesModel getExpenseProjectsFromDatabase];
	if (permType == PermType_ProjectSpecific)
	{
		if ([projectArray count] == 0) {

//            [Util errorAlert:@""errorMessage:RPLocalizedString( @"You cannot enter expenses because you do not have any projects assigned.",@"")];//Fix for DE1231//Juhi
//			return;
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
//		[Util errorAlert:RPLocalizedString(ErrorTitle,@"") errorMessage:RPLocalizedString( @"There are no available Expense Types.",@"")];
//		return;
	}
	
	G2AddNewExpenseViewController *addNewExpenseEntryViewController = [[G2AddNewExpenseViewController alloc]
																	 initWithTitle: expenseSheetTitle sheetID:selectedSheetId];
	//[addNewExpenseEntryViewController.topToolbarLabel setText:expenseSheetTitle];
	//[addNewExpenseEntryViewController setExpenseSheetID: selectedSheetId];
	[addNewExpenseEntryViewController setExpesneSheetStatus:expenseSheetStatus];
	[addNewExpenseEntryViewController setIsEntriesAvailable:YES];
	[addNewExpenseEntryViewController setTnewEntryDelegate:self];
	
	UINavigationController *navcontroller = [[UINavigationController alloc]initWithRootViewController:addNewExpenseEntryViewController];
    //Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    if (version>=7.0)
    {
        navcontroller.navigationBar.translucent = FALSE;
        navcontroller.navigationBar.barTintColor=RepliconStandardNavBarTintColor;
        navcontroller.navigationBar.tintColor=RepliconStandardWhiteColor;
    }
    else
        navcontroller.navigationBar.tintColor=RepliconStandardNavBarTintColor;
	
	[self presentViewController:navcontroller animated:YES completion:nil];
	
	
	
}


-(void)addLineItemToTable
{
	
	isEntriesAvailable=YES;
	newEntryAddedToSheet=YES;
	
}

-(void)editLineItemToTable
{
	isEntriesAvailable=YES;
	editedLineItemLoading=YES;
}



#pragma mark -
#pragma mark Action Methods
- (void) deleteAction:(id)sender{
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
		//[Util confirmAlert:RPLocalizedString(NoInternetConnectivity, NoInternetConnectivity) errorMessage:RPLocalizedString(@"You cannot delete expenses while offline.",@"")];
//ravi - DE2983			
#ifdef PHASE1_US2152
			[G2Util showOfflineAlert];
			return;
#endif			
		//return;
	}
	NSString * message = [NSString stringWithFormat:@"%@ ''%@''?", RPLocalizedString(@"Permanently delete", @"Permanently delete"),expenseSheetTitle];
	[self confirmAlert:RPLocalizedString(DELETE, DELETE) forAction: EXPSHEET_ACTION_DELETE confirmMessage:message];
}

- (void) submitAction:(id)sender {
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
		//[Util confirmAlert:RPLocalizedString(NoInternetConnectivity, NoInternetConnectivity) errorMessage:NSLocalizedString (@"You cannot submit expenses while offline.",@"")];
		//ravi - DE2983			
#ifdef PHASE1_US2152
		[G2Util showOfflineAlert];
		return;
#endif			
	}
	NSString * message = [NSString stringWithFormat:@"%@ ''%@'' %@?",RPLocalizedString(@"Submit", @"Submit"),expenseSheetTitle,RPLocalizedString(@"for approval", @"for approval")];
	[self confirmAlert: RPLocalizedString(SUBMIT, SUBMIT) forAction: EXPSHEET_ACTION_SUBMIT confirmMessage:message];	
}

- (void) resubmitAction:(id)sender {
	
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
		//[Util confirmAlert:RPLocalizedString(NoInternetConnectivity, NoInternetConnectivity) errorMessage:NSLocalizedString (@"You cannot resubmit expenses while offline.",@"")];
		//ravi - DE2983			
#ifdef PHASE1_US2152
		[G2Util showOfflineAlert];
		return;
#endif			
	}
    //US2669//Juhi
    //	NSString * message = [NSString stringWithFormat:@"Resubmit ''%@'' for approval?",expenseSheetTitle];
    //	[self confirmAlert:RPLocalizedString(RESUBMIT, RESUBMIT) forAction: EXPSHEET_ACTION_RESUBMIT confirmMessage:message];	
    if (resubmitViewController == nil) {
        G2ResubmitTimesheetViewController *tempresubmitViewController = [[G2ResubmitTimesheetViewController alloc] init];
        self.resubmitViewController=tempresubmitViewController;
        
    }
    allowBlankComments=[permissionsModel checkUserPermissionWithPermissionName:@"AllowBlankResubmitExpenseComment"];
    [self.resubmitViewController setSheetIdentity:selectedSheetId];
    [self.resubmitViewController setSelectedSheet:expenseSheetTitle];
    [self.resubmitViewController setAllowBlankComments:allowBlankComments];
    [self.resubmitViewController setActionType:@"ResubmitExpenseEntry"];//US4754
    [self.resubmitViewController setIsSaveEntry:NO];
    [self.resubmitViewController setDelegate:self];
    [self.navigationController pushViewController:self.resubmitViewController animated:YES];
}


-(void)unSubmitAction:(id)sender{
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
		//[Util confirmAlert:RPLocalizedString(NoInternetConnectivity, NoInternetConnectivity) errorMessage:NSLocalizedString (@"You cannot resubmit expenses while offline.",@"")];
		//ravi - DE2983			
#ifdef PHASE1_US2152
		[G2Util showOfflineAlert];
		return;
#endif			
	}
	NSString * message = [NSString stringWithFormat:@"%@ ''%@''?",RPLocalizedString(@"Unsubmit", @"Unsubmit"),expenseSheetTitle];
	[self confirmAlert: RPLocalizedString(UNSUBMIT, UNSUBMIT) forAction: EXPSHEET_ACTION_UNSUBMIT confirmMessage:message];
	
}

-(void) confirmAlert :(NSString *)_buttonTitle forAction: (ExpenseSheetActionType)actionType confirmMessage:(NSString*) message {
	
	
	UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:nil message:message
															  delegate:self cancelButtonTitle:RPLocalizedString(CANCEL_BTN_TITLE, @"Cancel") otherButtonTitles:_buttonTitle,nil];
	[confirmAlertView setDelegate:self];
	[confirmAlertView setTag:0];
    //US2669//Juhi
    //	if (actionType == EXPSHEET_ACTION_SUBMIT || actionType == EXPSHEET_ACTION_RESUBMIT)
    if (actionType == EXPSHEET_ACTION_SUBMIT)
    {

		[confirmAlertView setTag:1];
	}else if (actionType == EXPSHEET_ACTION_DELETE) {
		[confirmAlertView setTag:2];
	}
	else if (actionType == EXPSHEET_ACTION_UNSUBMIT) {
		[confirmAlertView setTag:3];
	}
	[confirmAlertView show];
	
	
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	
	//[[NSNotificationCenter defaultCenter] removeObserver:self name:@"UnsubmitExpenseSheetNotification" object:nil];
	
    if (alertView.tag==SAML_SESSION_TIMEOUT_TAG)
    {
        [[[UIApplication sharedApplication]delegate] performSelector:@selector(launchWebViewController)];
    }
	
	if (buttonIndex ==0&&alertView.tag==1) {	
		
	}
	if (buttonIndex ==1&&alertView.tag==1) {	
        //US2669//Juhi
//		[[RepliconServiceManager  expensesService]sendRequestToSubmitExpenseSheetWithID:selectedSheetId withDelegate:self];
        [[G2RepliconServiceManager  expensesService]sendRequestToSubmitExpenseSheetWithID:selectedSheetId comments:@"" withDelegate:self];
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(SubmittingMessage, "") ];
	}
	if (buttonIndex ==1&&alertView.tag==2) {	
		[[G2RepliconServiceManager expensesService]sendRequestToDeleteExpenseSheetWithIdentity:selectedSheetId WithDelegate:self];
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(DeletingMessage, "")];
	}
	if (buttonIndex ==1&&alertView.tag==3) {
		[[G2RepliconServiceManager expensesService]sendRequestToUnsubmitExpenseSheetWithID:selectedSheetId withDelegate:self];
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(UnSubmittingMessage, "")];
	}
	
	
}

- (void)alertViewCancel:(UIAlertView *)alertView{

}

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */


 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
     if (backUpArr==nil) {
         NSMutableArray *tempbackUpArr =[[NSMutableArray alloc]init];
         //HANDLE MEMORY LEAK
         //            self.backUpArr=[tempbackUpArr retain];
         self.backUpArr=tempbackUpArr;
         
     }
 }
 

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
	
	if ([self.expenseEntriesArray count] !=0) {
		return [self.expenseEntriesArray count];
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
		//cell.selectedBackgroundView  = [[UIImageView alloc] init];
		
		UIImage *rowBackground       = [G2Util thumbnailImage:cellBackgroundImageView];

		
		((UIImageView *)cell.backgroundView).image = rowBackground;
		//((UIImageView *)cell.selectedBackgroundView).image = selectionBackground;
	}
	NSUInteger currencycount=0;
	NSString *currencyValue=nil;
	
	NSUInteger ind=[self.expenseEntriesArray count]- indexPath.row-1;
	if ([currencyDetailsArray count]>0) {
		currencycount=[currencyDetailsArray count]-indexPath.row-1;
		currencyValue = [[currencyDetailsArray objectAtIndex:ind]objectForKey:@"netAmount"];
		
	}
	
	//[cell createExpenseEntriesfields];
	if ([self.expenseEntriesArray count] > 0) {
	//	NSString *titleDetails      = @"";		//fixed memory leak
		NSString *clientProject     = @"";
		NSString *cost			    = @"";
		NSString *date			    = @"";
		NSString *showRecieptImage  = nil;
		BOOL imgflag				= NO;
		UIColor	 *statusColor       = nil;
		UIColor	 *upperrighttextcolor = nil;
		
		id description = [[self.expenseEntriesArray objectAtIndex:ind] objectForKey:@"description"];
		if ([description isKindOfClass:[NSNull class]]) {
		}else if ([description isEqualToString:@"null"]) {
		//	titleDetails = RPLocalizedString(NONE_STRING,@"");		//fixed memory leak
		}else {
		//	titleDetails = RPLocalizedString(description,@"");		//fixed memory leak
		}
		
		if ([[[self.expenseEntriesArray objectAtIndex:ind] objectForKey:@"expenseTypeName"]isKindOfClass:[NSNull class]]) {
			clientProject = RPLocalizedString(NONE_STRING,@"");
		}else if ([[[self.expenseEntriesArray objectAtIndex:ind] objectForKey:@"expenseTypeName"] isEqualToString:@"null"]) {
			clientProject = RPLocalizedString(NONE_STRING,@"");
		}else {
			clientProject = RPLocalizedString([[self.expenseEntriesArray objectAtIndex:ind] objectForKey:@"expenseTypeName"],@"");
		}
		
		showRecieptImage  = [[self.expenseEntriesArray objectAtIndex:ind] objectForKey:@"expenseReceipt"];
		if (showRecieptImage!=nil && [showRecieptImage isEqualToString:@"Yes"]) {
			imgflag = YES;
			
		}


		NSString *formattedAmountString = [G2Util formatDoubleAsStringWithDecimalPlaces:[currencyValue doubleValue]];
		if (currencyDetailsArray!=nil && [currencyDetailsArray count]>0) {
			cost = [NSString stringWithFormat:@"%@ %@",[[currencyDetailsArray objectAtIndex:currencycount]objectForKey:@"currencyType"],formattedAmountString];			
		}
		//date = [Util getDeviceRegionalDateString:[[self.expenseEntriesArray objectAtIndex:ind] objectForKey:@"entryDate"]];
        date =[[self.expenseEntriesArray objectAtIndex:ind] objectForKey:@"entryDate"];
		
		[cell createCellLayoutWithParams:clientProject upperlefttextcolor:upperrighttextcolor 
						   upperrightstr:cost lowerleftstr:date lowerlefttextcolor:RepliconStandardBlackColor lowerrightstr:@"" 
							 statuscolor:statusColor imageViewflag:imgflag hairlinerequired:NO];
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
		
//		[[cell upperLeft]setFrame:CGRectMake(13, 3, 180, 30)];
//		[[cell upperRight]setFrame:CGRectMake(130, 3, 180, 30)];
		
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
//DE5255   
    self.expenseEntriesArray=[expensesModel getEntriesForExpenseSheet:selectedSheetId];
	if ([self.expenseEntriesArray count]>0) {
        
         
        
		for (int i=0; i<[self.expenseEntriesArray count]; i++) 
        {
            
            NSDictionary *expenseDict=[NSDictionary dictionaryWithDictionary:[self.expenseEntriesArray objectAtIndex:[self.expenseEntriesArray count]-i-1]] ;
//                      NSMutableDictionary * tempret = [[NSMutableDictionary alloc]
//                                         initWithCapacity:[expenseDict count]];
//            self.ret=tempret;
//
//           
//            
//            for (id key in [expenseDict allKeys])
//            {
//               
//                [self.ret setValue:[expenseDict objectForKey:key] forKey:key];
//                
//            }
            
           

            
			[self.backUpArr addObject:expenseDict];
            
		}
//DE5255       
		NSDictionary *dict=[NSDictionary dictionaryWithDictionary:[self.backUpArr objectAtIndex:indexPath.row]];
       
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
	G2EditExpenseEntryViewController *editExpenseEntryViewController = [[G2EditExpenseEntryViewController alloc]init];
   
	//[editExpenseEntryViewController.topToolbarLabel setText:[[backUpArr objectAtIndex:indexPath.row]objectForKey:@"description"]];
	BOOL cannotEdit = YES;
	if ([expenseSheetStatus isEqualToString:NOT_SUBMITTED_STATUS] ||[expenseSheetStatus isEqualToString:REJECTED_STATUS]) {
		cannotEdit= NO;
	}
    else
    {
        CGSize size=editExpenseEntryViewController.mainScrollView.contentSize;
        size.height=size.height-60.0;
        editExpenseEntryViewController.mainScrollView.contentSize=size;
    }

    [editExpenseEntryViewController setCanNotEdit:cannotEdit];
	[editExpenseEntryViewController setExpenseSheetStatus:expenseSheetStatus];
	[editExpenseEntryViewController setHidesBottomBarWhenPushed:YES];
	[editExpenseEntryViewController setEditControllerDelegate:self];
	[self.navigationController pushViewController:editExpenseEntryViewController animated:YES];
   
	
//	if ([[[backUpArr objectAtIndex:indexPath.row] objectForKey:@"expenseReceipt"] isEqualToString:@"Yes"]) {
//		//[editExpenseEntryViewController getReceiptImage];
//	}
	
	//Handling Leaks 
	

     
     
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

#pragma mark -
#pragma mark Service protocols

- (void) serverDidRespondWithResponse:(id) response {
	//DLog(@"serverDidRespondWithResponse ::ListOfExpenseEntriesViewController %@",response);
	if ([[[response objectForKey:@"response"]objectForKey:@"Status"]isEqualToString:@"OK"]) {
		if ([[[response objectForKey:@"refDict"]objectForKey:@"refID"] intValue] == Submit_ServiceID_11) {
		
			
			NSArray *statusResArray=[[response objectForKey:@"response"]objectForKey:@"Value"];
			
			if (statusResArray!=nil){
				[[G2RepliconServiceManager expensesService]sendRequestToGetExpenseById:[[statusResArray objectAtIndex:0]objectForKey:@"Identity"] withDelegate:self];
			}	
		}else if ([[[response objectForKey:@"refDict"]objectForKey:@"refID"] intValue] == ExpenseById_ServiceID_12) {
			
			NSArray *expenseByIDArray=[[response objectForKey:@"response"]objectForKey:@"Value"];
			if (expenseByIDArray!=nil && [expenseByIDArray count]!=0) {
				[expensesModel updateExpenseSheetsById:[[expenseByIDArray objectAtIndex:0]objectForKey:@"Identity"] response:expenseByIDArray];
				[[NSUserDefaults standardUserDefaults]setObject:[expensesModel getExpenseSheetsFromDataBase] forKey:@"expenseSheetsArray"];
                [[NSUserDefaults standardUserDefaults] synchronize];
				[[NSNotificationCenter defaultCenter]postNotificationName:@"ExpenseSheetEnableNotification" object:nil userInfo:nil];
				[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
				[self.navigationController popViewControllerAnimated:YES];
			}
			
		}else if ([[[response objectForKey:@"refDict"]objectForKey:@"refID"] intValue] == Unsubmit_ServiceID_10) {
			
			NSArray *unSubmitArray=[[response objectForKey:@"response"]objectForKey:@"Value"];
			if (unSubmitArray!=nil && [unSubmitArray count]!=0) {
				
				[[NSUserDefaults standardUserDefaults] setObject:@"UnsubmittedSheet" forKey:selectedSheetId];
				[[NSUserDefaults standardUserDefaults] synchronize];
				[[G2RepliconServiceManager expensesService]sendRequestToGetExpenseById:[[unSubmitArray objectAtIndex:0]objectForKey:@"Identity"] withDelegate:self];
				
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:UnSubmittingMessage];
			}
			
		}else if ([[[response objectForKey:@"refDict"]objectForKey:@"refID"] intValue] == DeleteExpenseSheet_ServiceID_24) {
			
			//delete from Database
			[expensesModel deleteExpenseSheetFromDB:selectedSheetId];
			NSMutableArray *totalSheets = [expensesModel getExpenseSheetsFromDataBase];
			if (totalSheets != nil && [totalSheets count] > 0) {
				[[NSUserDefaults standardUserDefaults]setObject:totalSheets forKey:@"expenseSheetsArray"];
                [[NSUserDefaults standardUserDefaults] synchronize];
			}else {
				[[NSUserDefaults standardUserDefaults]setObject:[NSMutableArray array] forKey:@"expenseSheetsArray"];
                [[NSUserDefaults standardUserDefaults] synchronize];
			}

			[delegateObj performSelector:@selector(sheetDeletedFromByUser)];
			[[NSNotificationCenter defaultCenter]postNotificationName:@"ExpenseSheetEnableNotification" object:nil userInfo:nil];
			[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
			[self.navigationController popViewControllerAnimated:YES];
			
		}else if ([[[response objectForKey:@"refDict"]objectForKey:@"refID"] intValue] == ApprovalsDetailsOnUnsubmit_30) {
			NSArray *responseArray=[[response objectForKey:@"response"]objectForKey:@"Value"];
			if (responseArray!=nil && [responseArray count]!=0) {
				self.unsubmittedApproveArray=[expensesModel insertApprovalsDetailsIntoDbForUnsubmittedSheet:responseArray];
				[submittedDetailsView.statusDescLabel setText:[[unsubmittedApproveArray objectAtIndex:0]objectForKey:@"status" ]];
				
				//Used to update sheet status 
				NSString *status=[[unsubmittedApproveArray objectAtIndex:0]objectForKey:@"status" ];
				if (status!=nil && [status isEqualToString:@"Open"]) {
					status = @"Not Submitted";
				}else if (status!=nil && [status isEqualToString:@"Waiting"]) {
					status = @"Waiting For Approval";
				}else if (status!=nil && [status isEqualToString:@"Rejected"]) {
					status = @"Rejected";
				}else if (status!=nil && [status isEqualToString:@"Approved"]) {
					status = @"Approved";
				}else if (status!=nil && [status isEqualToString:@"SystemApproved"]){
					status = @"Approved";
				}else if(status!=nil && [status isEqualToString:@"SystemRejected"]){
					status = @"Rejected";
				}else{
					status=@"Not Submitted";
				}
				
				
				[expensesModel updateExpenseSheetStatus:status:selectedSheetId];
				[[NSUserDefaults standardUserDefaults]setObject:[expensesModel getExpenseSheetsFromDataBase] forKey:@"expenseSheetsArray"];
                [[NSUserDefaults standardUserDefaults] synchronize];
				[[NSNotificationCenter defaultCenter]postNotificationName:@"ExpenseSheetEnableNotification" object:nil userInfo:nil];
				//..............
				NSMutableString *approverName=[NSMutableString stringWithString:[[unsubmittedApproveArray objectAtIndex:1]objectForKey:@"firstName"]];
				for (int i=2; i<[unsubmittedApproveArray count]; i++) {
                    if (![approverName isKindOfClass:[NSNull class] ]) 
                    {
                        if ([approverName isEqualToString:[NSString stringWithFormat:@"%@",[[unsubmittedApproveArray objectAtIndex:i]objectForKey:@"firstName"]]]) {
                            [approverName replaceOccurrencesOfString:approverName withString:[[unsubmittedApproveArray objectAtIndex:i]objectForKey:@"firstName"]
                                                             options:0 range:NSMakeRange(0, [approverName length])];
                        }else {
                            [approverName appendString:[NSString stringWithFormat:@",%@",[[unsubmittedApproveArray objectAtIndex:i]objectForKey:@"firstName"]]];
                        }

                    }
										
					
					[submittedDetailsView.approversDescLabel setText:approverName];
				}
			}
			if ([[[unsubmittedApproveArray objectAtIndex:0] objectForKey:@"status"] isEqualToString:NOT_SUBMITTED_STATUS]) {
				[submittedDetailsView.historyDescLabel setText:@""];
				[submittedDetailsView.submittedDescLabel setHidden:YES];
				[submittedDetailsView.submittedLabel setHidden:YES];
				[deleteButton setHidden:NO];
				[deleteUnderlineLabel setHidden:NO];
				[deleteButton setFrame:CGRectMake(60,submittedDetailsView.frame.size.height-50, 200, 30)];
				[deleteButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
			}else if ([ expenseSheetStatus isEqualToString:APPROVED_STATUS] || [ expenseSheetStatus isEqualToString:G2WAITING_FOR_APRROVAL_STATUS] || [ expenseSheetStatus isEqualToString:REJECTED_STATUS]) {
				
				[deleteButton setHidden:YES];
				[deleteUnderlineLabel setHidden:YES];
				for (NSUInteger i=[unsubmittedApproveArray count]-1; i>=1; i--) {
					[submittedDetailsView addHistoryDescriptionLableWithMultiPleValues:105+(([unsubmittedApproveArray count]-1)-i)*60];					
					[submittedDetailsView.approverNameLabel setText:[[unsubmittedApproveArray objectAtIndex:i]objectForKey:@"firstName"]];
					[submittedDetailsView.approverActionLabel setText:[[unsubmittedApproveArray objectAtIndex:i]objectForKey:@"approverAction"]];
					[submittedDetailsView.approverdTimeLabel  setText:[[unsubmittedApproveArray objectAtIndex:i]objectForKey:@"effectiveDate"]];
					[submittedDetailsView.historyDescLabel setText:submittedDetailsView.approverNameLabel.text];
					[submittedDetailsView.historyDescLabel setText:[NSString stringWithFormat:@"%@\n%@\n%@\n%@\n",submittedDetailsView.approverNameLabel.text,
																	submittedDetailsView.approverActionLabel.text,submittedDetailsView.approverdTimeLabel.text,submittedDetailsView.underlineLabelHistory.text]];
					if ([[[unsubmittedApproveArray objectAtIndex:i]objectForKey:@"approverAction"] isEqualToString:APPROVED_STATUS]) {
						UIImage *_img=[G2Util thumbnailImage:G2Check_ON_Image];
						UIImageView	*checkMarkImage=[[UIImageView alloc]initWithFrame:CGRectMake(90, 0, _img.size.width,_img.size.height)];
						UIView *approvedView=[[UIView alloc] initWithFrame:CGRectMake(submittedDetailsView.approverActionLabel.frame.origin.x, submittedDetailsView.approverActionLabel.frame.origin.x,
																					  submittedDetailsView.approverActionLabel.frame.size.width,submittedDetailsView.approverActionLabel.frame.size.height)];
						[approvedView addSubview:submittedDetailsView.approverActionLabel];
						[approvedView addSubview:checkMarkImage];
						[submittedDetailsView.approverActionLabel addSubview:approvedView];
						//Handling Leaks
						
						
					}
				}
				
				if ([ expenseSheetStatus isEqualToString:APPROVED_STATUS] || [ expenseSheetStatus isEqualToString:REJECTED_STATUS])
				{
					[submittedDetailsView addCommentsInHistory];
					[submittedDetailsView.commentsTextView setFrame:CGRectMake(110,[unsubmittedApproveArray count]*60+105,200,20)];
					[submittedDetailsView addSubview:submittedDetailsView.commentsTextView];
					for (NSUInteger i=[unsubmittedApproveArray count]-1; i>=1; i--) {
                        if (![[[unsubmittedApproveArray objectAtIndex:i]objectForKey:@"comments"] isKindOfClass:[NSNull class] ]) 
                        {
                            if ([[[unsubmittedApproveArray objectAtIndex:i]objectForKey:@"comments"] length]>0 ) {
                                [submittedDetailsView.commentsTextView setText:[NSString stringWithFormat:@"Comments:%@\n",[[unsubmittedApproveArray objectAtIndex:i]objectForKey:@"comments"]]];
                            }else {
                                [submittedDetailsView.commentsTextView setText:[NSString stringWithFormat:@"Comments:%@\n",@""]];
                            }
                        }
						
						
					}
				}
				[submittedDetailsView.submittedLabel setFrame:CGRectMake(110,105+[unsubmittedApproveArray count]*60+submittedDetailsView.commentsTextView.contentSize.height+20,80,20)];
				[submittedDetailsView.submittedDescLabel setFrame:CGRectMake(110,105+[unsubmittedApproveArray count]*60+submittedDetailsView.commentsTextView.contentSize.height+40,200,20)];
				[submittedDetailsView.submittedDescLabel setText:[[unsubmittedApproveArray objectAtIndex:0]objectForKey:@"submittedOn" ]];
				[submittedDetailsView setFrame:CGRectMake(0,totalAmountView.frame.size.height,320,submittedDetailsView.commentsTextView.contentSize.height+[unsubmittedApproveArray count]*60+350)];
				if (![ expenseSheetStatus isEqualToString:G2WAITING_FOR_APRROVAL_STATUS]) {
					[deleteButton setFrame:CGRectMake(60,[unsubmittedApproveArray count]*60+submittedDetailsView.commentsTextView.contentSize.height+195, 200, 30)];
					[deleteUnderlineLabel setFrame:CGRectMake(86,[unsubmittedApproveArray count]*60+submittedDetailsView.commentsTextView.contentSize.height+220, 148, 2)];
					[deleteButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
					[deleteButton setBackgroundColor:[UIColor clearColor]];
					[submittedDetailsView addSubview:deleteUnderlineLabel];
					[submittedDetailsView addSubview:deleteButton];
					[footerButtonsView setBackgroundColor:[UIColor clearColor]];
				}
				
				if ([ expenseSheetStatus isEqualToString:G2WAITING_FOR_APRROVAL_STATUS]) {
					if ([permissionsModel checkUserPermissionWithPermissionName:@"UnsubmitExpense"]==YES) {
						//[[RepliconServiceManager expensesService] sendRequestToGetRemainingApproversForSubmittedExpenseSheetWithId:selectedSheetId delegate:self];
						//[submittedDetailsView addUnsubmitLink];
						for (NSUInteger i=[unsubmittedApproveArray count]-1; i>=1; i--) {
							if ([[[unsubmittedApproveArray objectAtIndex:i]objectForKey:@"approverAction"] isEqualToString:APPROVED_STATUS]) {
								[submittedDetailsView.unsubmitButton setHidden:YES];
							}else {
								[submittedDetailsView.unsubmitButton setHidden:NO];
								
							}
						}
						
						[deleteButton setHidden:YES];
						[deleteUnderlineLabel setHidden:YES];
						
						[submittedDetailsView.unsubmitButton setFrame:CGRectMake(50,[unsubmittedApproveArray count]*60+185, 220, 30)];
						[submittedDetailsView.underlineLabel setFrame:CGRectMake(59,[unsubmittedApproveArray count]*60+210, 203, 2)];
						[submittedDetailsView addSubview:submittedDetailsView.underlineLabel];
						[submittedDetailsView addSubview:submittedDetailsView.unsubmitButton];
					}else {
						[deleteButton setHidden:YES];
						[deleteUnderlineLabel setHidden:YES];//unsubmit  permission not there but still he can not delete sheet
					}
					
				}
				
				if ([ expenseSheetStatus isEqualToString:REJECTED_STATUS]) {
					[footerButtonsView setFrame:CGRectMake(0.0,
														   totalAmountView.frame.size.height,self.view.frame.size.width,totalAmountView.frame.size.height+100+submittedDetailsView.frame.size.height+200)];	
					[deleteButton setHidden:NO];
					[deleteUnderlineLabel setHidden:NO];
				}
				
				
				
				
				//[footerButtonsView setFrame:CGRectMake(0,0,320,totalAmountView.frame.size.height+submittedDetailsView.frame.size.height+600)];
				//					[footerButtonsView setBackgroundColor:[UIColor yellowColor]];
				
				
				[footerView setFrame:CGRectMake(0,0,320,totalAmountView.frame.size.height+submittedDetailsView.frame.size.height+200)];
				[self.expenseEntriesTableView setTableFooterView:footerView];
				[footerView setBackgroundColor:[UIColor clearColor]];
				//[deleteButton setHidden:YES];
				//[deleteUnderlineLabel setHidden:YES];
				
			}
			
			
			
			if ([[[unsubmittedApproveArray objectAtIndex:0] objectForKey:@"status"] isEqualToString:NOT_SUBMITTED_STATUS]) {
				[[submittedDetailsView statusDescLabel] setTextColor:[UIColor blackColor]];
				
			} else if ([[[unsubmittedApproveArray objectAtIndex:0] objectForKey:@"status"]isEqualToString:@"Waiting"]) {
				[[submittedDetailsView statusDescLabel] setTextColor:WaitingTextColor];
			}else if ([[[unsubmittedApproveArray objectAtIndex:0] objectForKey:@"status"]isEqualToString:REJECTED_STATUS]) {
				[[submittedDetailsView statusDescLabel] setTextColor:RejectedTextColor];
				
			}else if ([[[unsubmittedApproveArray objectAtIndex:0] objectForKey:@"status"]isEqualToString:APPROVED_STATUS]) {
				[[submittedDetailsView statusDescLabel] setTextColor:ApprovedTextColor];
			}else{
				[[submittedDetailsView statusDescLabel] setTextColor:WaitingTextColor];
			}
			
			
			[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
			
		}
		
		
	}else if ([[[response objectForKey:@"refDict"]objectForKey:@"refID"] intValue] == ApprovalsDetailsForSubmittedSheet_31) {
		
		
	}
	else {
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
		[G2Util confirmAlert:[[response objectForKey:@"response"]objectForKey:@"Status"] errorMessage:[[response objectForKey:@"response"]objectForKey:@"Message"]];
	}
	
	
	
	
}

- (void) serverDidFailWithError:(NSError *) error {
	

	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
	
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO) {
		[G2Util showOfflineAlert];
		return;
	}
	
    [self showErrorAlert:error];
    
	return;
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
    else
    {
        [G2Util errorAlert:RPLocalizedString( @"Connection failed",@"") errorMessage:[error localizedDescription]];
    }
}


- (void) networkActivated {

	
	
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    DLog(@"didReceiveMemoryWarning from ListOfExpenseEntriesViewController");
    // Release any cached data, images, etc. that aren't in use.
//    [self handleScreenBlank];
}

-(void)handleScreenBlank
{
    
    if (delegateObj) {
        
        [self.navigationController popToViewController:delegateObj animated:FALSE];
    }
    //DE5480
    
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
    self.backUpArr=nil;
}





@end
