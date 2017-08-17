//
//  OverDueTimesheetsViewController.m
//  Replicon
//
//  Created by Dipta Rakshit on 2/9/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "G2OverDueTimesheetsViewController.h"
#import "G2Constants.h"
#import "G2ViewUtil.h"
#import "G2Util.h"

@implementation G2OverDueTimesheetsViewController
@synthesize  approvalOverdueTSTableView;
@synthesize sectionHeaderlabel;
@synthesize  sectionHeader;
@synthesize listOfUsersArr;
@synthesize  selectedIndexPath;
@synthesize customFooterView;;


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
        [self.approvalOverdueTSTableView.tableFooterView  setHidden:TRUE];
        
    }
    
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    [self.view setBackgroundColor:G2RepliconStandardBackgroundColor];
    
    if (approvalOverdueTSTableView==nil) {
		UITableView *tempapprovalOverdueTSTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-95) style:UITableViewStylePlain];
		self.approvalOverdueTSTableView=tempapprovalOverdueTSTableView;
        
	}
	approvalOverdueTSTableView.delegate=self;
	approvalOverdueTSTableView.dataSource=self;
	[self.view addSubview:approvalOverdueTSTableView];
	UIView *bckView = [UIView new];
	[bckView setBackgroundColor:G2RepliconStandardBackgroundColor];
	[approvalOverdueTSTableView setBackgroundView:bckView];
	
    
    [G2ViewUtil setToolbarLabel: self withText: RPLocalizedString(OVERDUE_TIMESHEETS, OVERDUE_TIMESHEETS)];
    
    
    UIButton *footerBtn =[UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *normalImg = [G2Util thumbnailImage:REMINDER_UNPRESSED_IMG];
    UIImage *highlightedImg = [G2Util thumbnailImage:REMINDER_PRESSED_IMG];
    [footerBtn setBackgroundImage:normalImg forState:UIControlStateNormal];
    [footerBtn setBackgroundImage:highlightedImg forState:UIControlStateHighlighted];
    [footerBtn setTitle:RPLocalizedString(SEND_REMINDER_TEXT, SEND_REMINDER_TEXT) forState:UIControlStateNormal];
    [footerBtn setFrame:CGRectMake(20.0, 25.0, normalImg.size.width, normalImg.size.height)];
    [footerBtn addTarget:self action:@selector(handleButtonClicks:) forControlEvents:UIControlEventTouchUpInside];
    footerBtn.titleEdgeInsets = UIEdgeInsetsMake(-5.0, 0, 0, 0);
    UIView *tempcustomFooterView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320.0, normalImg.size.height+60.0)];
     self.customFooterView=tempcustomFooterView;
    
    [customFooterView  addSubview:footerBtn];
    self.approvalOverdueTSTableView.tableFooterView = customFooterView;
 
    
    
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
    rightStr   = [userDict objectForKey:@"TotalTime"];  
    
    
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
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
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
	

}


/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 }
 */

-(void)handleButtonClicks:(id)sender
{
    
    if ([MFMailComposeViewController canSendMail] == NO) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"This device is not configured for sending mail" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
		[alert show];
		
		return;
	}
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;   
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    [picker setSubject:[G2EMAIL_SUBJECT  stringByAppendingString:version]];                  
    [picker setToRecipients:[NSArray arrayWithObject:RECIPENT_ADDRESS]]; 
    [self presentViewController:picker animated:YES completion:nil];
   

}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{ 
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
            
        default:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email" message:@"Sending Failed - Unknown Error :-("
                                                           delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
           
        }
            
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
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
    self.approvalOverdueTSTableView =nil;
    self.sectionHeaderlabel=nil;
    self.sectionHeader=nil;
}



@end
