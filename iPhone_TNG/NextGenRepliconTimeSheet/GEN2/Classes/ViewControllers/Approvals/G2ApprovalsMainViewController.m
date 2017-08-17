//
//  ApprovalsMainViewController.m
//  Replicon
//
//  Created by Dipta Rakshit on 2/7/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "G2ApprovalsMainViewController.h"
#import "G2Constants.h"
#import "RepliconAppDelegate.h"
#import "G2PendingTimesheetsViewController.h"
#import "G2OverDueTimesheetsViewController.h"
#import "G2PreviousApprovalsTimesheetsViewController.h"
#import "G2PendingExpensesViewController.h"
#import "G2PreviousApprovalsExpensesViewController.h"

@implementation G2ApprovalsMainViewController
@synthesize  approvalsMainTableView;
@synthesize  leftButton;
@synthesize  timeSheetlistOfItemsArr,expensesSheetlistOfItemsArr,previousApprovalsTimesheetsViewController;
@synthesize sectionHeaderlabel;
@synthesize  sectionHeader;
@synthesize pendingTimesheetsViewController;
@synthesize overdueTimesheetsViewController;
@synthesize selectedIndexPath;
@synthesize pendingExpensesViewController;
@synthesize previousApprovalsExpensesViewController;
@synthesize isNotFirstTimeFlag;

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
	
    [G2ViewUtil setToolbarLabel: self withText: RPLocalizedString(PENDING_TIMESHEETS, PENDING_TIMESHEETS)];
    
 /*
    [self.view setBackgroundColor:G2RepliconStandardBackgroundColor];
	
	if (approvalsMainTableView==nil) {
		UITableView *temptimeSheetsTableView=[[UITableView alloc]initWithFrame:FullScreenFrame style:UITableViewStylePlain];
		self.approvalsMainTableView=temptimeSheetsTableView;
  
	}
	approvalsMainTableView.delegate=self;
	approvalsMainTableView.dataSource=self;
	[self.view addSubview:approvalsMainTableView];

 */   
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
    
 /*  
    
    NSMutableArray *temptimeSheetlistOfItemsArr=[[NSMutableArray alloc]init];
    self.timeSheetlistOfItemsArr=temptimeSheetlistOfItemsArr;
  
    
    NSMutableArray *tempexpensesSheetlistOfItemsArr=[[NSMutableArray alloc]init];
    self.expensesSheetlistOfItemsArr=tempexpensesSheetlistOfItemsArr;
  

    
    //READ THIS DATA FROM DB
    
    [self.timeSheetlistOfItemsArr addObject:[NSDictionary dictionaryWithObject:@"3" forKey:@"PendingApprovals"]];
    [self.timeSheetlistOfItemsArr addObject:[NSDictionary dictionaryWithObject:@"3" forKey:@"OverDueTimesheets"]];
    [self.timeSheetlistOfItemsArr addObject:[NSDictionary dictionaryWithObject:@"3" forKey:@"PreviousApprovals"]];
    
    
    [self.expensesSheetlistOfItemsArr addObject:[NSDictionary dictionaryWithObject:@"5" forKey:@"PendingApprovals"]];
    [self.expensesSheetlistOfItemsArr addObject:[NSDictionary dictionaryWithObject:@"3" forKey:@"PreviousApprovals"]];
    
    */
    
    

}

- (void)viewWillDisappear:(BOOL)animated
{
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    appDelegate.isInApprovalsMainPage=FALSE;
    isNotFirstTimeFlag=FALSE;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
     RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    appDelegate.isInApprovalsMainPage=TRUE;
    if (!isNotFirstTimeFlag)
    {
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:LoadingMessage];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:APPROVAL_TIMESHEETS_RECEIVED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver: self 
                                                 selector: @selector(moveToPendingTimesheetsViewController) 
                                                     name: APPROVAL_TIMESHEETS_RECEIVED_NOTIFICATION
                                                   object: nil]; 
        isNotFirstTimeFlag=TRUE;
    }
    
   
    
    [[G2RepliconServiceManager approvalsService] fetchPendingApprovalsTimeSheetData: self];
    
    /*
    [self.approvalsMainTableView deselectRowAtIndexPath:selectedIndexPath animated:YES]; 
  */
}

#pragma mark -
#pragma mark - UITableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //return 1;
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    int numberofRows=0;
	switch (section) {
        case 0:
            numberofRows=3;
            break;
        case 1:
            numberofRows=2;
            break;   
        default:
            break;
    }
    return numberofRows;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	static NSString *CellIdentifier = @"ApprovalsMainCellIdentifier";
	
	cell = (G2ApprovalsCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        cell = [[G2ApprovalsCustomCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		
        cell.backgroundView          = [[UIImageView alloc] init];
        
        
        UIImage *rowBackground       = [G2Util thumbnailImage:cellBackgroundImageView];
        ((UIImageView *)cell.backgroundView).image = rowBackground;
        
        
	}
	NSString		*leftStr =@"";
	NSString		*rightStr = @"";
	
    switch (indexPath.section) {
        case 0:
            if (indexPath.row==0) {
                leftStr=PENDING_APPROVALS;
                rightStr=[[timeSheetlistOfItemsArr objectAtIndex:indexPath.row] objectForKey:@"PendingApprovals" ];
            }
            else if (indexPath.row==1) {
                leftStr=OVERDUE_TIMESHEETS;
                rightStr=[[timeSheetlistOfItemsArr objectAtIndex:indexPath.row] objectForKey:@"OverDueTimesheets" ];
            }
            else if (indexPath.row==2) {
                leftStr=PREVIOUS_APPROVALS;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            break;
        case 1:
            if (indexPath.row==0) {
                leftStr=PENDING_APPROVALS;
                rightStr=[[expensesSheetlistOfItemsArr objectAtIndex:indexPath.row] objectForKey:@"PendingApprovals" ];
            }
            else if (indexPath.row==1) {
                leftStr=PREVIOUS_APPROVALS;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }

            break;    
        default:
            break;
    }
    		
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
            headerTitle=@"Timesheets";
            break;
        case 1:
            headerTitle=@"Expenses";
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
    
	[sectionHeader setImage:[G2Util thumbnailImage:G2TimeSheets_ContentsPage_Header]];
	[sectionHeader setBackgroundColor:[UIColor clearColor]];
	[sectionHeader addSubview:sectionHeaderlabel];	
	
	
	
	return sectionHeader;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	


    
    switch (indexPath.section) {
        case 0:
            if (indexPath.row==0) {
               
                if ([[[timeSheetlistOfItemsArr objectAtIndex:indexPath.row] objectForKey:@"PendingApprovals" ]intValue]>0) 
                {
                    [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:LoadingMessage];
                     [[NSNotificationCenter defaultCenter] removeObserver:self name:APPROVAL_TIMESHEETS_RECEIVED_NOTIFICATION object:nil];
                    [[NSNotificationCenter defaultCenter] addObserver: self 
                                                             selector: @selector(moveToPendingTimesheetsViewController) 
                                                                 name: APPROVAL_TIMESHEETS_RECEIVED_NOTIFICATION
                                                               object: nil]; 
                    
                    [[G2RepliconServiceManager approvalsService] fetchPendingApprovalsTimeSheetData: self];
                    
                    
                                       
                }
                else 
                {
                    [self.approvalsMainTableView deselectRowAtIndexPath:indexPath animated:YES]; 
                }
            }
            else if (indexPath.row==1) 
            {
                if ([[[timeSheetlistOfItemsArr objectAtIndex:indexPath.row] objectForKey:@"OverDueTimesheets" ]intValue]>0) 
                {
                    G2OverDueTimesheetsViewController *tempoverdueTimesheetsViewController =[[G2OverDueTimesheetsViewController alloc]init];
                    self.overdueTimesheetsViewController=tempoverdueTimesheetsViewController;
                    
                    
                    [self.navigationController pushViewController:self.overdueTimesheetsViewController animated:YES];
                    
                }
                else 
                {
                    [self.approvalsMainTableView deselectRowAtIndexPath:indexPath animated:YES]; 
                }

                
            }
            else if (indexPath.row==2) 
            {
                if ([[[timeSheetlistOfItemsArr objectAtIndex:indexPath.row] objectForKey:@"PreviousApprovals" ]intValue]>0) 
                {
                    G2PreviousApprovalsTimesheetsViewController *temppreviousApprovalsTimesheetsViewController =[[G2PreviousApprovalsTimesheetsViewController alloc]init];
                    self.previousApprovalsTimesheetsViewController=temppreviousApprovalsTimesheetsViewController;
                    
                    
                    [self.navigationController pushViewController:self.previousApprovalsTimesheetsViewController animated:YES];
                    
                }
                else 
                {
                    [self.approvalsMainTableView deselectRowAtIndexPath:indexPath animated:YES]; 
                }
                
                
            }

            break;
        case 1:
            if (indexPath.row==0) {
                
                if ([[[expensesSheetlistOfItemsArr objectAtIndex:indexPath.row] objectForKey:@"PendingApprovals" ]intValue]>0) 
                {
                    G2PendingExpensesViewController *temppendingExpensesViewController =[[G2PendingExpensesViewController alloc]init];
                    self.pendingExpensesViewController=temppendingExpensesViewController;
                    
                    
                    [self.navigationController pushViewController:self.pendingExpensesViewController animated:YES];
                    
                }
                else 
                {
                    [self.approvalsMainTableView deselectRowAtIndexPath:indexPath animated:YES]; 
                }
            }
            else if (indexPath.row==1) 
            {
                if ([[[expensesSheetlistOfItemsArr objectAtIndex:indexPath.row] objectForKey:@"PreviousApprovals" ]intValue]>0) 
                {
                    G2PreviousApprovalsExpensesViewController *temppreviousApprovalsExpensesViewController =[[G2PreviousApprovalsExpensesViewController alloc]init];
                    self.previousApprovalsExpensesViewController=temppreviousApprovalsExpensesViewController;
                    
                    
                    [self.navigationController pushViewController:self.previousApprovalsExpensesViewController animated:YES];
                    
                }
                else 
                {
                    [self.approvalsMainTableView deselectRowAtIndexPath:indexPath animated:YES]; 
                }              
            }

            break;    
        default:
            break;
    }
   
    self.selectedIndexPath=indexPath;
}

-(void)moveToPendingTimesheetsViewController
{
    
    [[NSNotificationCenter defaultCenter]
	 removeObserver:self name:APPROVAL_TIMESHEETS_RECEIVED_NOTIFICATION object:nil];  
    G2PendingTimesheetsViewController *temppendingTimesheetsViewController =[[G2PendingTimesheetsViewController alloc]init];
    self.pendingTimesheetsViewController=temppendingTimesheetsViewController;
    
     
    
    
    
    
//    NSMutableArray *firstSectionArr=[[NSMutableArray alloc]init];
//    
//    NSMutableDictionary *userDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Sarah Connor",@"Name",@"41.0",@"TotalTime",[NSNumber numberWithBool:FALSE],@"IsSelected",@"Dec 10,2011",@"DueDate", nil];
//    [firstSectionArr addObject:userDict];
//    userDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Sally Fields",@"Name",@"32.0",@"TotalTime",[NSNumber numberWithBool:FALSE],@"IsSelected",@"Dec 10,2011",@"DueDate", nil];
//    [firstSectionArr addObject:userDict];
//    userDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Juan Torres",@"Name",@"20.0",@"TotalTime",[NSNumber numberWithBool:FALSE],@"IsSelected",@"Dec 10,2011",@"DueDate", nil];
//    [firstSectionArr addObject:userDict];
//    
//    
//    NSMutableArray *secondSectionArr=[[NSMutableArray alloc]init];
//    
//    userDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Dipta Rakshit",@"Name",@"38.0",@"TotalTime",[NSNumber numberWithBool:FALSE],@"IsSelected",@"Dec 11,2011",@"DueDate", nil];
//    [secondSectionArr addObject:userDict];
//    userDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Phill Tuffnell",@"Name",@"45.0",@"TotalTime",[NSNumber numberWithBool:FALSE],@"IsSelected",@"Dec 11,2011",@"DueDate", nil];
//    [secondSectionArr addObject:userDict];
//    userDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Gary Jones",@"Name",@"49.0",@"TotalTime",[NSNumber numberWithBool:FALSE],@"IsSelected",@"Dec 11,2011",@"DueDate", nil];
//    [secondSectionArr addObject:userDict];
//    
//    [self.listOfUsersArr addObject:firstSectionArr];

//    [self.listOfUsersArr addObject:secondSectionArr];

    
    G2ApprovalsModel *approvalsModel=[[G2ApprovalsModel alloc]init];
    NSMutableArray *pendingTimesheetsArr=[approvalsModel getAllTimeSheetsGroupedByDueDates];
    self.pendingTimesheetsViewController.listOfUsersArr=pendingTimesheetsArr;
    
    
    [self performSelector:@selector(pushView) withObject:nil afterDelay:1];
    
    

}

-(void)pushView
{
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
    [self.navigationController pushViewController:self.pendingTimesheetsViewController animated:NO];
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


-(void)goBack:(id)sender{
	[[[UIApplication sharedApplication]delegate]performSelector:@selector(flipToHomeViewController)]; 
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.approvalsMainTableView =nil;
    self.leftButton=nil;
    self.sectionHeaderlabel=nil;
    self.sectionHeader=nil;
}



@end
