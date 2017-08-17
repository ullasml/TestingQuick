//
//  LoginPreferencesViewController.m
//  Replicon
//
//  Created by Manoj  on 17/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2LoginPreferencesViewController.h"
#import "G2MoreViewController.h"

@implementation G2LoginPreferencesViewController
@synthesize loginPreferencesTable;
@synthesize previousSelectedRow;
@synthesize moreViewControllerObject;

- (id) init
{
	self = [super init];
	if (self != nil) {
       
		[self.view setBackgroundColor:[UIColor colorWithRed:204/250.0 green:204/250.0  blue:204/250.0  alpha:1.0]];
		UITableView *temploginPreferencesTable=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , self.view.frame.size.height-45) style:UITableViewStyleGrouped];
        self.loginPreferencesTable=temploginPreferencesTable;
        
		loginPreferencesTable.delegate=self;
		loginPreferencesTable.dataSource=self;
		[loginPreferencesTable setBackgroundColor:G2RepliconStandardBackgroundColor];
        loginPreferencesTable.backgroundView=nil;
		[self.view addSubview:loginPreferencesTable];
	}
	return self;
}

-(void)viewWillAppear:(BOOL)animated
{
		//	self.title = RPLocalizedString(@"Remember Password",@"");
	[G2ViewUtil setToolbarLabel:self withText:RPLocalizedString(@"Remember Password",@"Remember Password")];
	[self.navigationController.navigationBar setHidden:NO];
	//[self.navigationController.navigationBar setTintColor:[Util getNavbarTintColor]];
}

#pragma mark -
#pragma mark Table view data source

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor whiteColor]];
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	if (section == 0) {
		return 80;
	}
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	if (section ==0) {
		UILabel	*expenseLabel= [[UILabel alloc] initWithFrame:CGRectMake(10.0,
																		 5.0,
																		 300.0,
																		 25.0)];
		
		[expenseLabel setBackgroundColor:[UIColor clearColor]];
		[expenseLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16]];
		[expenseLabel setTextColor:RepliconStandardBlackColor];
		[expenseLabel setText:RPLocalizedString(@"Choose how long to save the password",@"")];
		
		UILabel	*descExpHeaderLabel= [[UILabel alloc] initWithFrame:CGRectMake(10.0,
																			   35.0,
																			   300.0,
																			   40.0)];
		[descExpHeaderLabel setNumberOfLines:2];
		[descExpHeaderLabel setText:RPLocalizedString(@"If the password is saved, you will be automatically logged in.",@"")];
		[descExpHeaderLabel setBackgroundColor:[UIColor clearColor]];
		[descExpHeaderLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
		UIView *expenseHeader = [UIView new];
		[expenseHeader addSubview:expenseLabel];
		[expenseHeader addSubview:descExpHeaderLabel];
		
        return expenseHeader;
	} 
	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
		//return 50;
	return 44;//US4065//Juhi
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 6;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	G2MoreCellView *cell;
	static NSString *CellIdentifier = @"Cell";
	cell  = (G2MoreCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[G2MoreCellView  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];	
		[cell setAccessoryType:UITableViewCellAccessoryNone];
	}
	[cell createPreferencesLable];
	[cell.preferenceLable setFrame:CGRectMake(10, 8, 170, 30)];
	NSArray *remPwdArray = [NSArray arrayWithObjects:@"Never",@"1 day",@"1 week",@"2 weeks",@"1 month",@"Always",nil];
	for (int i = 0; i < [remPwdArray count]; i++) {
		if (indexPath.row == i) {
			[cell.preferenceLable setText:RPLocalizedString([remPwdArray objectAtIndex:i],@"")];
		}
	}
	
	if ([indexPath isEqual:previousSelectedRow]) {
		[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
		[[cell preferenceLable] setTextColor:NewRepliconStandardBlueColor];//US4065//Juhi
	}
	return cell;
}
                                                                                
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	G2MoreCellView *cell = (G2MoreCellView*)[tableView cellForRowAtIndexPath:indexPath];
	G2MoreCellView *previousSelectedCell = (G2MoreCellView*)[tableView cellForRowAtIndexPath:previousSelectedRow];
	[cell setCellViewState:YES];
	if (![cell isEqual:previousSelectedCell]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		previousSelectedCell.accessoryType = UITableViewCellAccessoryNone;
		[[previousSelectedCell preferenceLable] setTextColor:[UIColor blackColor]];
		self.previousSelectedRow = indexPath;
        
	}
	[moreViewControllerObject performSelector:@selector(updateRememberPwdInLoginTable:) withObject:[NSNumber numberWithInteger:indexPath.row]];
	[self performSelector:@selector(tableViewCellUntapped:) withObject:indexPath afterDelay:0.1];
	[self performSelector:@selector(popViewController) withObject:nil afterDelay:0.11];
}

-(void)resetToNever {
	G2MoreCellView *previousSelectedCell = (G2MoreCellView*)[loginPreferencesTable cellForRowAtIndexPath:previousSelectedRow];
	if (previousSelectedRow.row != 0) {
		previousSelectedCell.accessoryType = UITableViewCellAccessoryNone;
		[[previousSelectedCell preferenceLable] setTextColor:[UIColor blackColor]];
		G2MoreCellView *neverCell = (G2MoreCellView*)[loginPreferencesTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
		neverCell.accessoryType = UITableViewCellAccessoryCheckmark;
		[[neverCell preferenceLable] setTextColor:NewRepliconStandardBlueColor];//US4065//Juhi
	}
}

-(void)popViewController {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)tableViewCellUntapped:(NSIndexPath*)indexPath {
	G2MoreCellView *cell = (G2MoreCellView*)[loginPreferencesTable cellForRowAtIndexPath:indexPath];
	[cell.preferenceLable setTextColor:NewRepliconStandardBlueColor];//US4065//Juhi
	//[cell setBackgroundColor:iosStandaredWhiteColor];
	[loginPreferencesTable deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
	[self.navigationController.navigationBar setHidden:YES];
	[moreViewControllerObject performSelector:@selector(animateCellWhichIsSelected) withObject:nil];
}

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

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.loginPreferencesTable=nil;
}





@end
