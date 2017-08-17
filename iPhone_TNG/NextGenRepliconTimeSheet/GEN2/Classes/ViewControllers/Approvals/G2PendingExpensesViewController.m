//
//  PendingExpensesViewController.m
//  Replicon
//
//  Created by Dipta Rakshit on 2/14/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "G2PendingExpensesViewController.h"
#import "G2Constants.h"
#import "G2ViewUtil.h"

@implementation G2PendingExpensesViewController

@synthesize  approvalpendingTSTableView;
@synthesize sectionHeaderlabel;
@synthesize  sectionHeader;
@synthesize listOfUsersArr;
@synthesize  selectedIndexPath;
@synthesize scrollViewController;
@synthesize addDescriptionViewController;

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
        
    }
    
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    [self.view setBackgroundColor:G2RepliconStandardBackgroundColor];
    
    if (approvalpendingTSTableView==nil) {
		UITableView *tempapprovalpendingTSTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-95) style:UITableViewStylePlain];
		self.approvalpendingTSTableView=tempapprovalpendingTSTableView;
        
	}
	approvalpendingTSTableView.delegate=self;
	approvalpendingTSTableView.dataSource=self;
	[self.view addSubview:approvalpendingTSTableView];
	UIView *bckView = [UIView new];
	[bckView setBackgroundColor:G2RepliconStandardBackgroundColor];
	[approvalpendingTSTableView setBackgroundView:bckView];
	
    
    [G2ViewUtil setToolbarLabel: self withText: RPLocalizedString(PENDING_EXPENSES, PENDING_EXPENSES)];
    
    
    G2ApprovalTablesFooterView *footerView=[[G2ApprovalTablesFooterView alloc]init];
    
    self.approvalpendingTSTableView.tableFooterView = footerView;
    footerView.delegate=self;
    
    
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
    leftStr   = [userDict objectForKey:@"Name"]; 
    rightStr   = [userDict objectForKey:@"TotalExpense"];  
    
    
    //[cell setCommonCellDelegate:self];
    
    [cell setDelegate:self];
    
//    [cell createCellLayoutWithParams:leftStr rightstr:rightStr hairlinerequired:NO radioButtonTag:indexPath.row];   
    
        [cell createCellLayoutWithParams:leftStr rightstr:rightStr hairlinerequired:NO radioButtonTag:indexPath.row overTimerequired:NO mealrequired:NO timeOffrequired:NO regularRequired:NO overTimeStr:@"" mealStr:@"" timeOffStr:@"" regularStr:@""];
    
    UIImage *radioButtonImage=nil;
    if ([[userDict objectForKey:@"IsSelected"]boolValue]) 
    {
        radioButtonImage = [G2Util thumbnailImage:G2CheckBoxSelectedImage];
    }
    else
    {
        radioButtonImage = [G2Util thumbnailImage:G2CheckBoxDeselectedImage];
    }
    
    
    [cell.radioButton setImage:radioButtonImage forState:UIControlStateNormal];
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
	return cell;
	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section    // fixed font style. use custom view (UILabel) if you want something different
{
    NSMutableArray *sectionedUsersArr=[self.listOfUsersArr objectAtIndex:section];
    
    NSMutableDictionary *userDict=[sectionedUsersArr objectAtIndex:0];
    
    NSString *headerTitle=[userDict objectForKey:@"DueDate"];
    
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



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
    G2ApprovalsExpensesScrollViewController *tempscrollViewController =[[G2ApprovalsExpensesScrollViewController alloc]init];
    self.scrollViewController=tempscrollViewController;
    
    
    NSUInteger count=0;
    for (int i=0; i<[self.listOfUsersArr count]; i++) {
        NSMutableArray *sectionedUsersArr=[self.listOfUsersArr objectAtIndex:i];
        count=count+[sectionedUsersArr count];
    }
    
    if (count>0) {
        [self.scrollViewController setNumberOfViews:count];
        
        NSInteger indexCount=0;
        
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
            NSDictionary *_expenseSheet = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],@"id",@"",@"editStatus",[NSNumber numberWithBool:FALSE],@"approversRemaining",[NSNumber numberWithBool:FALSE],@"isModified",@"437",@"identity",[NSNull null],@"submittedOn",@"ullas expense sheet",@"description",@"CAD$",@"reimburseCurrency",@"February 8, 2012",@"expenseDate",@"70.05",@"totalReimbursement",@"February 14, 2012",@"savedOnUtc",@"February 14, 2012",@"savedOn",@"000437",@"trackingNumber",G2WAITING_FOR_APRROVAL_STATUS,@"status", nil];
            [templistOfExpenseSheets addObject:_expenseSheet];
        }
        
        

        
        [self.scrollViewController setListOfItemsArr:mainlistOfItemsArr];
        [self.scrollViewController setListOfSheetsArr:templistOfExpenseSheets];
        
               
        
        
        

        
        [self.navigationController pushViewController:self.scrollViewController animated:YES];
        self.selectedIndexPath=indexPath;
        
        
        
        
    }
    
    
    [self.approvalpendingTSTableView deselectRowAtIndexPath:indexPath animated:YES]; 
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
    
    [footerView.commentsTextView setFrame:frame];
    frame=footerView.approveButton.frame;
    
    frame.origin.y=size.height +95.0;
    
    [footerView.approveButton setFrame:frame];
    frame=footerView.rejectButton.frame;
    
    frame.origin.y=size.height +95.0;
    [footerView.rejectButton setFrame:frame];
    frame=footerView.frame;
    frame.size.height=60.0+size.height +15+110.0+20.0;
    footerView.frame=frame;
    self.approvalpendingTSTableView.tableFooterView = footerView;
    
    
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
}



@end
