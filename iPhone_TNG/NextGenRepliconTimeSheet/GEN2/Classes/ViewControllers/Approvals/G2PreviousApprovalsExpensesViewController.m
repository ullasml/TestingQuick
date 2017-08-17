//
//  PreviousApprovalsExpensesViewController.m
//  Replicon
//
//  Created by Dipta Rakshit on 2/15/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "G2PreviousApprovalsExpensesViewController.h"
#import "G2Constants.h"
#import "G2ViewUtil.h"
#import "G2ApprovalsExpensesScrollViewController.h"
#import "G2TimeSheetObject.h"
#import "G2PermissionSet.h"
#import "G2Preferences.h"

@implementation G2PreviousApprovalsExpensesViewController

@synthesize  prevApprovalsExpensesTableView;
@synthesize sectionHeaderlabel;
@synthesize  sectionHeader;
@synthesize listOfUsersArr;
@synthesize  selectedIndexPath;
@synthesize scrollViewController;
@synthesize  footerView;
@synthesize  moreButton;
@synthesize  imageView;
@synthesize  pendingApprovalsListOfItemsDict;



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
        [self.prevApprovalsExpensesTableView.tableFooterView  setHidden:TRUE];
        
    }
    
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    [self.view setBackgroundColor:G2RepliconStandardBackgroundColor];
    
    if (prevApprovalsExpensesTableView==nil) {
		UITableView *tempprevApprovalsTimesheetsTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-95) style:UITableViewStylePlain];
		self.prevApprovalsExpensesTableView=tempprevApprovalsTimesheetsTableView;
        
	}
	prevApprovalsExpensesTableView.delegate=self;
	prevApprovalsExpensesTableView.dataSource=self;
	[self.view addSubview:prevApprovalsExpensesTableView];
	UIView *bckView = [UIView new];
	[bckView setBackgroundColor:G2RepliconStandardBackgroundColor];
	[prevApprovalsExpensesTableView setBackgroundView:bckView];
	
    
    [G2ViewUtil setToolbarLabel: self withText: RPLocalizedString(PREVIOUS_APPROVALS, PREVIOUS_APPROVALS)];
    
    
 	UIView *tempfooterView=[[UIView alloc]initWithFrame:CGRectMake(0.0, 50.0, self.prevApprovalsExpensesTableView.frame.size.width, 250.0)];
    self.footerView=tempfooterView;
   
	[footerView setBackgroundColor:RepliconStandardClearColor];
    self.moreButton=[UIButton buttonWithType:UIButtonTypeCustom];
	[ self.moreButton setBackgroundColor:[UIColor clearColor]];
	UIImage *moreButtonImage=[G2Util thumbnailImage:G2MoreButtonIMage];
	
	[ self.moreButton setFrame:CGRectMake(footerView.frame.size.width/2-45, 15, 70,moreButtonImage.size.height+10 )];
	[ self.moreButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
	[ self.moreButton setTitleColor:RepliconStandardBlackColor forState:UIControlStateNormal];
	[ self.moreButton setTitle:MoreText forState:UIControlStateNormal];
	[ self.moreButton addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
	[ self.moreButton setHidden: NO];
	
	UIImageView *tempimageView = [[UIImageView alloc]init];
	[tempimageView setImage:moreButtonImage];
	[tempimageView setFrame:CGRectMake(footerView.frame.size.width/2+10,20, moreButtonImage.size.width, moreButtonImage.size.height)];
	[tempimageView setBackgroundColor:[UIColor clearColor]]; 
	[imageView setHidden: NO];
	[footerView addSubview:self.moreButton];
	[footerView addSubview:tempimageView];
    self.imageView=tempimageView;
    
	[self.prevApprovalsExpensesTableView setTableFooterView:footerView];    
    NSMutableArray *templistOfUsersArr=[[NSMutableArray alloc]init];
    self.listOfUsersArr=templistOfUsersArr;
    
    
    NSMutableArray *firstSectionArr=[[NSMutableArray alloc]init];
    
    NSMutableDictionary *userDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Sarah Connor",@"Name",@"USD$212.0",@"TotalExpense",[NSNumber numberWithBool:FALSE],@"IsSelected",@"Dec 10,2011",@"DueDate", nil];
    [firstSectionArr addObject:userDict];
    userDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Sally Fields",@"Name",@"USD$412.0",@"TotalExpense",[NSNumber numberWithBool:FALSE],@"IsSelected",@"Dec 10,2011",@"DueDate", nil];
    [firstSectionArr addObject:userDict];
    userDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Juan Torres",@"Name",@"USD$2000.0",@"TotalExpense",[NSNumber numberWithBool:FALSE],@"IsSelected",@"Dec 10,2011",@"DueDate", nil];
    [firstSectionArr addObject:userDict];
    
    
    NSMutableArray *secondSectionArr=[[NSMutableArray alloc]init];
    
    userDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Dipta Rakshit",@"Name",@"USD$2124.0",@"TotalExpense",[NSNumber numberWithBool:FALSE],@"IsSelected",@"Dec 11,2011",@"DueDate", nil];
    [secondSectionArr addObject:userDict];
    userDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Phill Tuffnell",@"Name",@"USD$1234.0",@"TotalExpense",[NSNumber numberWithBool:FALSE],@"IsSelected",@"Dec 11,2011",@"DueDate", nil];
    [secondSectionArr addObject:userDict];
    userDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Gary Jones",@"Name",@"USD$49.0",@"TotalExpense",[NSNumber numberWithBool:FALSE],@"IsSelected",@"Dec 11,2011",@"DueDate", nil];
    [secondSectionArr addObject:userDict];
    
    [self.listOfUsersArr addObject:firstSectionArr];
    
    [self.listOfUsersArr addObject:secondSectionArr];
   
    
}

#pragma mark -
#pragma mark - UITableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.listOfUsersArr count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 49.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSMutableArray *sectionedUsersArr=[self.listOfUsersArr objectAtIndex:section];
    return [sectionedUsersArr count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	static NSString *CellIdentifier = @"PreviousApprovalsCellIdentifier";
	
	cell = (G2ApprovalsCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        cell = [[G2ApprovalsCustomCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		
        cell.backgroundView          = [[UIImageView alloc] init];
        
        
        UIImage *rowBackground       = [G2Util thumbnailImage:cellBackgroundImageView];
        ((UIImageView *)cell.backgroundView).image = rowBackground;
        
        
	}
	NSString		*leftStr =@"";
	NSString		*rightStr = @"";
	
    NSMutableArray *sectionedUsersArr=[self.listOfUsersArr objectAtIndex:indexPath.section];
    
    NSMutableDictionary *userDict=[sectionedUsersArr objectAtIndex:indexPath.row];
    leftStr   = [userDict objectForKey:@"Name"]; 
    rightStr   = [userDict objectForKey:@"TotalExpense"];  
    
    
    [cell setCommonCellDelegate:self];
    
    
    
    [cell createCellLayoutWithParams:leftStr rightstr:rightStr hairlinerequired:NO];     
    
    
	[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
	return cell;
	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section    // fixed font style. use custom view (UILabel) if you want something different
{
    NSString *headerTitle=@"";
    switch (section) {
        case 0:
            headerTitle=REJECT_CONTENTBAR_EXPENSES_TEXT;
            break;
        case 1:
            headerTitle=APPROVE_CONTENTBAR_EXPENSES_TEXT;
            break;
            
        default:
            break;
    }
    
	return headerTitle;
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
    
    switch (section) {
        case 0:
            [sectionHeader setImage:[G2Util thumbnailImage:TimeSheets_ContentsPage_Gray_Header]];
            break;
        case 1:
            [sectionHeader setImage:[G2Util thumbnailImage:G2TimeSheets_ContentsPage_Header]];
            break;
            
        default:
            break;
    }
    
	
	[sectionHeader setBackgroundColor:[UIColor clearColor]];
	[sectionHeader addSubview:sectionHeaderlabel];	
	
	
	
	return sectionHeader;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    [self.prevApprovalsExpensesTableView deselectRowAtIndexPath:indexPath animated:YES]; 
	/*
    ApprovalsExpensesScrollViewController *tempscrollViewController =[[ApprovalsExpensesScrollViewController alloc]init];
    self.scrollViewController=tempscrollViewController;
    
    
    int count=0;
    for (int i=0; i<[self.listOfUsersArr count]; i++) {
        NSMutableArray *sectionedUsersArr=[self.listOfUsersArr objectAtIndex:i];
        count=count+[sectionedUsersArr count];
    }
    
    if (count>0) {
        [self.scrollViewController setNumberOfViews:count];
        
        int indexCount=0;
        
        for (int i=0; i<[self.listOfUsersArr count]; i++) {
            NSMutableArray *sectionedUsersArr=[self.listOfUsersArr objectAtIndex:i];
            if (indexPath.section==i) 
            {
                if (indexPath.section==0) {
                    indexCount=indexCount+indexPath.row;
                }
                else
                {
                    indexCount=indexCount+indexPath.row+1;
                }
                
                break;
            }
            else
            {
                indexCount=indexCount+[sectionedUsersArr count]-1;
            }
            
        }
        self.scrollViewController.currentViewIndex=indexCount;
        [scrollViewController setHidesBottomBarWhenPushed:YES];
        
        
        NSMutableArray *templistOfExpenseSheets=[NSMutableArray array];
        NSMutableArray *mainlistOfItemsArr=[NSMutableArray array];
        for (int i=0; i<count; i++) 
        {
            NSMutableArray *templistOfItemsArr=[NSMutableArray array];
            for (int j=0; j<2; j++) {
                NSDictionary  *entriesDict=[NSDictionary  dictionaryWithObjectsAndKeys:@"Single",@"allocationMethodId",[NSNumber numberWithBool:TRUE],@"billClient",@"2",@"clientIdentity",@"Advantage Technologies",@"clientName",@"USD$",@"currencyType",@"",@"description",@"",@"editStatus",@"February 8, 2012",@"entryDate",@"1.2345",@"expenseRate",@"No",@"expenseReceipt",@"18",@"expenseTypeIdentity",@"Rated EC - Calc Tax",@"expenseTypeName",@"Mile",@"expenseUnitLable",@"437",@"expense_sheet_identity",@"$Net * 0.05",@"formula1",@"$Net * 0.06",@"formula2",@"",@"formula3",@"",@"formula4",@"",@"formula5",@"796",@"id",@"796",@"identity",[NSNumber numberWithBool:FALSE],@"isModified",[NSNumber numberWithBool:TRUE],@"isRated",@"4.11",@"netAmount",@"3",@"noOfUnits",@"",@"paymentMethodId",@"",@"paymentMethodName",@"35",@"projectIdentity",@"All assignment Project to all",@"projectName",[NSNumber numberWithBool:TRUE],@"requestReimbursement",@"0.19",@"taxAmount1",@"0.22",@"taxAmount2",@"",@"taxAmount3",@"",@"taxAmount4",@"",@"taxAmount5",@"3",@"taxCode1",@"4",@"taxCode2",@"",@"taxCode3",@"",@"taxCode4",@"",@"taxCode5",@"RatedWithTaxes",@"type", nil  ];  
                [templistOfItemsArr addObject:entriesDict];  
                
                
            }
            [mainlistOfItemsArr addObject:templistOfItemsArr];
        }
        
        
        for (int j=0; j<count; j++) 
        {
            NSDictionary *_expenseSheet = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],@"id",@"",@"editStatus",[NSNumber numberWithBool:FALSE],@"approversRemaining",[NSNumber numberWithBool:FALSE],@"isModified",@"437",@"identity",[NSNull null],@"submittedOn",@"ullas expense sheet",@"description",@"CAD$",@"reimburseCurrency",@"February 8, 2012",@"expenseDate",@"70.05",@"totalReimbursement",@"February 14, 2012",@"savedOnUtc",@"February 14, 2012",@"savedOn",@"000437",@"trackingNumber",APPROVED_STATUS,@"status", nil];
            [templistOfExpenseSheets addObject:_expenseSheet];
        }
        
        
        
        
        [self.scrollViewController setListOfItemsArr:mainlistOfItemsArr];
        [self.scrollViewController setListOfSheetsArr:templistOfExpenseSheets];
        
        
        
        
        
        
        
        [self.navigationController pushViewController:self.scrollViewController animated:YES];
        self.selectedIndexPath=indexPath;
        
        
        
        
    }
    
    
    [self.prevApprovalsExpensesTableView deselectRowAtIndexPath:indexPath animated:YES]; 
    
    */
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
}


-(void)moreAction:(id)sender
{
    
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
    self.prevApprovalsExpensesTableView =nil;
    self.sectionHeaderlabel=nil;
    self.sectionHeader=nil;
}



@end
