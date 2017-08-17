//
//  ApprovalsExpensesScrollViewController.m
//  Replicon
//
//  Created by Dipta Rakshit on 2/14/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "G2ApprovalsExpensesScrollViewController.h"
#import "G2Constants.h"
#import "G2ViewUtil.h"
#import "G2ApprovalTablesFooterView.h"
#import "G2Util.h"

@implementation G2ApprovalsExpensesScrollViewController
@synthesize numberOfViews;
@synthesize addDescriptionViewController;
@synthesize  mainScrollView;
@synthesize currentViewIndex;
@synthesize listOfItemsArr,listOfSheetsArr;

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




// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    [self.view setBackgroundColor:G2RepliconStandardBackgroundColor];
    
    UIScrollView *tempmainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.mainScrollView=tempmainScrollView;
    
    self.mainScrollView.pagingEnabled = YES;
    
    
    for (int i = 0; i < numberOfViews; i++) {
        G2ApprovalsUsersListOfExpenseEntriesViewController *approvalsListOfexpenseEntriesCtrl=[[G2ApprovalsUsersListOfExpenseEntriesViewController alloc]init];
        NSDictionary *_expenseSheet=[self.listOfSheetsArr objectAtIndex:i];
//        
       
        

        
        
        NSString *sheetName = [_expenseSheet objectForKey:@"description"];
        NSString *sheetTrackingNumber = [_expenseSheet objectForKey:@"trackingNumber"];
        NSString *sheetIdentity = [_expenseSheet objectForKey:@"identity"];
        NSString *sheetStatus = [_expenseSheet objectForKey:@"status"];
        BOOL	approversRemaining = [[_expenseSheet objectForKey:@"approversRemaining"] boolValue];
        
        [approvalsListOfexpenseEntriesCtrl setExpenseSheetTitle:sheetName];
        [approvalsListOfexpenseEntriesCtrl setExpenseSheetTrackingNo:sheetTrackingNumber];
        [approvalsListOfexpenseEntriesCtrl setSelectedSheetId:sheetIdentity];
        [approvalsListOfexpenseEntriesCtrl setExpenseSheetStatus:sheetStatus];
        [approvalsListOfexpenseEntriesCtrl setApproversRemaining:approversRemaining];
        

        NSString *_formattedAmountString = [G2Util formatDoubleAsStringWithDecimalPlaces:[[_expenseSheet objectForKey:@"totalReimbursement"] doubleValue]];
        NSString *_currencyStr=	[NSString stringWithFormat:@"%@ %@",[_expenseSheet objectForKey:@"reimburseCurrency"],_formattedAmountString];
        [approvalsListOfexpenseEntriesCtrl setTotalReimbursement: _currencyStr];
        
        
        
 //       ProjectPermissionType permType = PermType_Both;
//        NSArray *projectArray = [expensesModel getExpenseProjectsFromDatabase];
        NSMutableArray *projectArray = [NSMutableArray array];
        
        for (int i=0; i<31; i++) {
            NSDictionary *projectDict=[NSDictionary dictionaryWithObjectsAndKeys:@"None",@"allocationMethodId",@"AllowNonBillable",@"billingStatus",[NSNull null],@"clientIdentity",[NSNull null],@"closedStatus",[NSNull null],@"code",[NSNull null],@"expenseEntryEndDate",[NSNull null],@"expenseEntryStartDate",[NSNumber numberWithBool:TRUE],@"expensesAllowed",[NSNumber numberWithBool:FALSE],@"hasTasks",@"1",@"id",[NSNull null],@"identity",@"None",@"name",[NSNull null],@"rootTaskIdentity",[NSNumber numberWithBool:TRUE],@"timeEntryAllowed", nil];
            [projectArray addObject:projectDict];
        }
        

		
        if ([[self.listOfItemsArr objectAtIndex:i ] count]!=0) {
            [approvalsListOfexpenseEntriesCtrl setIsEntriesAvailable:YES];
            [approvalsListOfexpenseEntriesCtrl setExpenseEntriesArray:(NSMutableArray*)[self.listOfItemsArr objectAtIndex:i ] ];
//            [self.navigationController pushViewController:expenseEntryViewController animated:YES];
        }
 //       else {}
//        
        approvalsListOfexpenseEntriesCtrl.currentViewTag=i;
        approvalsListOfexpenseEntriesCtrl.delegate=self;
        CGFloat yOrigin = i * self.view.frame.size.width;
        UIView *expenseEntryListView = approvalsListOfexpenseEntriesCtrl.view;
        expenseEntryListView.frame=CGRectMake(yOrigin, 0, self.view.frame.size.width, self.view.frame.size.height);

        [self.mainScrollView addSubview:expenseEntryListView];
       
    }  //
    
    self.mainScrollView.contentSize = CGSizeMake(self.view.frame.size.width * numberOfViews, self.view.frame.size.height);
    
    [self.view addSubview:self.mainScrollView];
    
    
    
    CGPoint point=CGPointMake(self.view.frame.size.width *currentViewIndex, 0 );
    self.mainScrollView.contentOffset=point;
    
    
    
    [G2ViewUtil setToolbarLabel: self withText: RPLocalizedString(EXPENSE_SHEETS_TITLE, EXPENSE_SHEETS_TITLE)];
}

-(void)viewWillAppear:(BOOL)animated{
	[super viewWillAppear:YES];
    
}


- (void)handleApproverCommentsForSelectedUser:(G2ApprovalsUsersListOfExpenseEntriesViewController *)approvalsUsersListOfExpenseEntriesViewController
{
    G2AddDescriptionViewController *tempaddDescriptionViewController = [[G2AddDescriptionViewController alloc] init];
    self.addDescriptionViewController=tempaddDescriptionViewController;
    
    [addDescriptionViewController setViewTitle:RPLocalizedString(TimeEntryComments,@"")];
    [addDescriptionViewController setTimeEntryParentController:self];
    
    G2ApprovalTablesFooterView *approvalTablesfooterView=nil;
    
    for (int i = 0; i < [[approvalsUsersListOfExpenseEntriesViewController.expenseEntriesTableView.tableFooterView subviews] count]; i++ ) 
    {
        if( [[[approvalsUsersListOfExpenseEntriesViewController.expenseEntriesTableView.tableFooterView subviews] objectAtIndex:i] isKindOfClass:[G2ApprovalTablesFooterView class] ] )
        {
            approvalTablesfooterView = (G2ApprovalTablesFooterView *)[[approvalsUsersListOfExpenseEntriesViewController.expenseEntriesTableView.tableFooterView subviews] objectAtIndex:i];
            break;
        }
    }
    if (approvalTablesfooterView) {
        [addDescriptionViewController setDescTextString: approvalTablesfooterView.commentsTextView.text];
    }
    
    [addDescriptionViewController setFromTimeEntryComments:NO];
    [addDescriptionViewController setFromTimeEntryUDF:NO];
    [addDescriptionViewController setDescControlDelegate:approvalsUsersListOfExpenseEntriesViewController];
    [self.navigationController pushViewController:addDescriptionViewController animated:YES];
   
}


- (void)handlePreviousNextButtonFromApprovalsListforViewTag:(NSInteger)currentViewtag forbuttonTag:(NSInteger)buttonTag
{
    
    CGPoint point=CGPointZero;
    
    if (buttonTag==PREVIOUS_BUTTON_TAG) 
    {
        DLog(@"PREVIOUS BUTTON CLICKED");
        if (currentViewtag>0) 
        {
            point=CGPointMake(self.mainScrollView.contentOffset.x- self.view.frame.size.width, 0 );
        }
        
    }
    else if (buttonTag==NEXT_BUTTON_TAG) 
    {
        DLog(@"NEXT BUßßTTON CLICKED");
        
        if (currentViewtag<numberOfViews) 
        {
            point=CGPointMake(self.view.frame.size.width *(currentViewtag+1), 0 );
        }
    }
    
    
    [UIScrollView beginAnimations:@"scrollAnimation" context:nil];
    
    [UIScrollView setAnimationDuration:0.5];
    
    //This makes the scrollView scroll to the desired position  
    self.mainScrollView.contentOffset = point; 
    
    [UIScrollView commitAnimations];
    
    
    
}

- (void)pushToEditExpenseEntryViewController:(id)editExpenseEntryViewController
{
    
    [self.navigationController pushViewController:editExpenseEntryViewController animated:YES];
}

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 }
 */



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return NO;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    
}



@end
