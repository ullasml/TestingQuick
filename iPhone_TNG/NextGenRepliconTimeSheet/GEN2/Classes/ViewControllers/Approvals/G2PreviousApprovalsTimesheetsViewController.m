//
//  PreviousApprovalsTimesheetsViewController.m
//  Replicon
//
//  Created by Dipta Rakshit on 2/7/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "G2PreviousApprovalsTimesheetsViewController.h"
#import "G2Constants.h"
#import "G2ViewUtil.h"
#import "G2ApprovalsScrollViewController.h"
#import "G2TimeSheetObject.h"
#import "G2PermissionSet.h"
#import "G2Preferences.h"

@implementation G2PreviousApprovalsTimesheetsViewController
@synthesize  prevApprovalsTimesheetsTableView;
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
        [self.prevApprovalsTimesheetsTableView.tableFooterView  setHidden:TRUE];
        
    }
    
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    [self.view setBackgroundColor:G2RepliconStandardBackgroundColor];
    
    if (prevApprovalsTimesheetsTableView==nil) {
		UITableView *tempprevApprovalsTimesheetsTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-95) style:UITableViewStylePlain];
		self.prevApprovalsTimesheetsTableView=tempprevApprovalsTimesheetsTableView;
        
	}
	prevApprovalsTimesheetsTableView.delegate=self;
	prevApprovalsTimesheetsTableView.dataSource=self;
	[self.view addSubview:prevApprovalsTimesheetsTableView];
	UIView *bckView = [UIView new];
	[bckView setBackgroundColor:G2RepliconStandardBackgroundColor];
	[prevApprovalsTimesheetsTableView setBackgroundView:bckView];
	
    
    [G2ViewUtil setToolbarLabel: self withText: RPLocalizedString(PREVIOUS_APPROVALS, PREVIOUS_APPROVALS)];
    
    
 	UIView *tempfooterView=[[UIView alloc]initWithFrame:CGRectMake(0.0, 50.0, self.prevApprovalsTimesheetsTableView.frame.size.width, 150.0)];
    self.footerView=tempfooterView;
    
	[footerView setBackgroundColor:RepliconStandardClearColor];
    self.moreButton=[UIButton buttonWithType:UIButtonTypeCustom];
	[ self.moreButton setBackgroundColor:[UIColor clearColor]];
	UIImage *moreButtonImage=[G2Util thumbnailImage:G2MoreButtonIMage];
	
	[ self.moreButton setFrame:CGRectMake(footerView.frame.size.width/2-45, 30, 70,moreButtonImage.size.height+10 )];
	[ self.moreButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
	[ self.moreButton setTitleColor:RepliconStandardBlackColor forState:UIControlStateNormal];
	[ self.moreButton setTitle:MoreText forState:UIControlStateNormal];
	[ self.moreButton addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
	[ self.moreButton setHidden: NO];
	
	UIImageView *tempimageView = [[UIImageView alloc]init];
	[tempimageView setImage:moreButtonImage];
	[tempimageView setFrame:CGRectMake(footerView.frame.size.width/2+10,35, moreButtonImage.size.width, moreButtonImage.size.height)];
	[tempimageView setBackgroundColor:[UIColor clearColor]]; 
	[imageView setHidden: NO];
	[footerView addSubview:self.moreButton];
	[footerView addSubview:tempimageView];
    self.imageView=tempimageView;
    
	[self.prevApprovalsTimesheetsTableView setTableFooterView:footerView];    
    NSMutableArray *templistOfUsersArr=[[NSMutableArray alloc]init];
    self.listOfUsersArr=templistOfUsersArr;
    
    
    NSMutableArray *firstSectionArr=[[NSMutableArray alloc]init];
    
    NSMutableDictionary *userDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Sarah Connor",@"Name",@"41.0",@"TotalTime",[NSNumber numberWithBool:FALSE],@"IsSelected",@"Dec 10,2011",@"DueDate", nil];
    [firstSectionArr addObject:userDict];
    userDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Sally Fields",@"Name",@"32.0",@"TotalTime",[NSNumber numberWithBool:FALSE],@"IsSelected",@"Dec 10,2011",@"DueDate", nil];
    [firstSectionArr addObject:userDict];
    userDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Juan Torres",@"Name",@"20.0",@"TotalTime",[NSNumber numberWithBool:FALSE],@"IsSelected",@"Dec 10,2011",@"DueDate", nil];
    [firstSectionArr addObject:userDict];
    
    
    NSMutableArray *secondSectionArr=[[NSMutableArray alloc]init];
    
    userDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Dipta Rakshit",@"Name",@"38.0",@"TotalTime",[NSNumber numberWithBool:FALSE],@"IsSelected",@"Dec 11,2011",@"DueDate", nil];
    [secondSectionArr addObject:userDict];
    userDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Phill Tuffnell",@"Name",@"45.0",@"TotalTime",[NSNumber numberWithBool:FALSE],@"IsSelected",@"Dec 11,2011",@"DueDate", nil];
    [secondSectionArr addObject:userDict];
    userDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"Gary Jones",@"Name",@"49.0",@"TotalTime",[NSNumber numberWithBool:FALSE],@"IsSelected",@"Dec 11,2011",@"DueDate", nil];
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
    rightStr   = [userDict objectForKey:@"TotalTime"];  
    
    
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
            headerTitle=REJECT_CONTENTBAR_TEXT;
            break;
        case 1:
            headerTitle=APPROVE_CONTENTBAR_TEXT;
            break;
            
        default:
            break;
    }
    
	return headerTitle;
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
	
    G2ApprovalsScrollViewController *tempscrollViewController =[[G2ApprovalsScrollViewController alloc]init];
    self.scrollViewController=tempscrollViewController;
    
    
    NSInteger count=0;
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
        
        NSMutableArray *templistOfItemsArr=[NSMutableArray array];
        for (int j=0; j<count; j++) {
            G2TimeSheetObject *timeSheetObject = [[G2TimeSheetObject alloc]init];
            timeSheetObject.startDate=[NSDate date];
            timeSheetObject.endDate=[NSDate date];
            timeSheetObject.dueDate=[NSDate date];
            if (j<3) {
                timeSheetObject.status=REJECTED_STATUS;
            }
            else
            {
                 timeSheetObject.status=APPROVED_STATUS;
            }
            timeSheetObject.projects=[NSMutableArray arrayWithObjects:@"All assignment Project to all", nil];
            timeSheetObject.totalHrs=@"16.08";
            
            
            G2PermissionSet *permissionsetObj=[[G2PermissionSet alloc]init];
            permissionsetObj.unsubmitTimeSheet=YES;
            permissionsetObj.billingTimesheet=YES;
            permissionsetObj.projectTimesheet=YES;
            permissionsetObj.nonProjectTimesheet=YES;
            permissionsetObj.bothAgainstAndNotAgainstProject=YES;
            
            G2Preferences *preferenceSet=[[G2Preferences alloc]init];
            preferenceSet.hourFormat=@"Decimal";
            preferenceSet. activitiesEnabled=YES;
            preferenceSet.useBillingInfo=YES;
            preferenceSet.dateformat=@"%b %#d, %Y";
            
            
            NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:timeSheetObject,@"TIMESHEETOBJ",permissionsetObj,@"PERMISSIONOBJ",preferenceSet,@"PREFERENCEOBJ", nil];
            
            [templistOfItemsArr addObject:dict];
            
            
        }
        
        [self.scrollViewController setListOfItemsArr:templistOfItemsArr];
        
        [self.navigationController pushViewController:self.scrollViewController animated:YES];
        self.selectedIndexPath=indexPath;
        
        
        
        
    }
    
    
    [self.prevApprovalsTimesheetsTableView deselectRowAtIndexPath:indexPath animated:YES]; 
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
    self.prevApprovalsTimesheetsTableView =nil;
    self.sectionHeaderlabel=nil;
    self.sectionHeader=nil;
}



@end
