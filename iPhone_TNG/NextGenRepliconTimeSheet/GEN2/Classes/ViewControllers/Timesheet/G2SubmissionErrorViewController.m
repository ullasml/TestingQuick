//
//  SubmissionErrorViewController.m
//  ResubmitTimesheet
//
//  Created by Sridhar on 29/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2SubmissionErrorViewController.h"
#import "RepliconAppDelegate.h"

@implementation G2SubmissionErrorViewController
@synthesize submissionTableView;
@synthesize topToolbarLabel;
@synthesize innerTopToolbarLabel;
@synthesize errorSheet;
@synthesize backButton;
@synthesize submissionErrorsDict;
@synthesize tableHeader;
@synthesize warningImage;
@synthesize warningLabel;
@synthesize uniquekeyArray;
@synthesize sectionHeaderlabel;
@synthesize entryKey;
@synthesize parentController;
@synthesize sectionHeader;

#pragma mark -
#pragma mark Initialization

//- (id) init


- (id) initWithPermissionSet:(G2PermissionSet *)_permissionSet :(G2Preferences *)_preferences
{
	self = [super init];
	if (self != nil) {
		//Set Preferences
		preferencesObj = _preferences;
		
		//Set Permissions
		permissionsObj = _permissionSet;
		
		if (uniquekeyArray == nil) {
			uniquekeyArray = [NSMutableArray array];
		}
		if (submissionErrorsDict == nil) {
			submissionErrorsDict = [NSMutableDictionary dictionary];
		}
	}
	return self;
}

#pragma mark -
#pragma mark View lifecycle Methods

-(void)loadView{
	[super loadView];
	//Add TableView
	if(submissionTableView== nil){
		submissionTableView =[[UITableView alloc]initWithFrame:FullScreenFrame 
														 style:UITableViewStylePlain];
	}
	[submissionTableView setDelegate:self];
	[submissionTableView setDataSource:self];
	[submissionTableView setBackgroundColor:G2RepliconStandardBackgroundColor];
    submissionTableView.backgroundView=nil;
	[self.view addSubview:submissionTableView];
	
	//Add TableHeader
	if (tableHeader == nil) {
		tableHeader=[[G2CustomTableHeaderView alloc] initWithFrame:CGRectMake(0.0, 
																			0.0, 
																			self.submissionTableView.frame.size.width, 
																			70.0)];
		
	}
	[tableHeader addSubmissionErrorHeaderView];
	[tableHeader setBackgroundColor:RepliconStandardWhiteColor];
	
	//Add table Header to Tableview
	[self.submissionTableView setTableHeaderView:tableHeader];
	
	//Add topTitleView
	if (topTitleView == nil) {
		topTitleView = [[G2NavigationTitleView alloc]initWithFrame:TopTitleViewFrame];
	}
	
	[topTitleView addTopToolBarLabel];
	[topTitleView setTopToolbarlabelFrame:TopToolbarlabelFrame];
	[topTitleView setTopToolbarlabelFont:[UIFont boldSystemFontOfSize:14]];
	[topTitleView setTopToolbarlabelText:RPLocalizedString(TimeEntryNavTitle,TimeEntryNavTitle)];
	
	[topTitleView addInnerTopToolBarLabel];
	[topTitleView setInnerTopToolbarlabelFrame:InnerTopToolbarlabelFrame];
	[topTitleView setInnerTopToolbarlabelFont:[UIFont boldSystemFontOfSize:14]];
	[topTitleView setInnerTopToolbarlabelText:errorSheet];
	
	
	self.navigationItem.titleView = topTitleView;
	
	backButton = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(BACK,BACK) style:UIBarButtonItemStylePlain 
												 target:self action:@selector (submissionErrorBackAction)];
	
	[self.navigationItem setLeftBarButtonItem:backButton];
}

/*- (void)viewDidLoad {
 [super viewDidLoad];
 // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
 // self.navigationItem.rightBarButtonItem = self.editButtonItem;
 }
 */
/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */
/*
 - (void)viewDidAppear:(BOOL)animated {
 [super viewDidAppear:animated];
 }
 */
/*
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:animated];
 }
 */
/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

#pragma mark -
#pragma mark SubmissionErrorController Methods
-(void)entriesMissingFields:(NSMutableDictionary *)missingfields{
	DLog(@"entriesMissingFields::SubmissionErrorViewController %@",missingfields);
	NSArray *arr=nil;
	if (missingfields != nil && [missingfields count]>0) {
		DLog(@"All keys %@",[missingfields allKeys]);
		arr = [missingfields allKeys];
		self.submissionErrorsDict = missingfields;
	}
	NSMutableArray *sortedArray      = [NSMutableArray array];
    if (arr!=nil) {
        for (int i=0; i<[arr count]; i++) {
            //[convertedArray addObject:[Util convertStringToDate:[arr objectAtIndex:i]]];
            [sortedArray addObject:[arr objectAtIndex:i]];
        }
    }
	
	[sortedArray sortUsingSelector:@selector(compare:)];
	NSMutableArray *resultantArray = [NSMutableArray array];
	
	int k =0;
	for (NSUInteger i=[sortedArray count]-1; i ==0; i--) {
		[resultantArray insertObject:[sortedArray objectAtIndex:i] atIndex:k];
		if (k<[sortedArray count]) {
			k++;
		}
	}
	self.uniquekeyArray =resultantArray ;	
}

/*-(NSString *)getFormattedHeaderTitleString:(NSString *)_stringdate{
	DLog(@"_stringdate ::getFormattedEntryDateString %@",_stringdate);
	NSDate *date = nil;
	if (_stringdate != nil) {
		//Convert to NSdate: //May 23, 2011
		date =[Util convertStringToDate:_stringdate];
		DLog(@"Date %@",date);
		NSNumber *month     = [Util getDateValuesFromDate:date :@"month"];
		NSNumber *day       = [Util getDateValuesFromDate:date :@"day"];
		NSString *monthName	= [Util getMonthNameForMonthId:[month intValue]];
		NSString *weekDay   = [Util getWeekDayForGivenDate:date];
		
		NSString *formattedString = [NSString stringWithFormat:@"%@,%@ %@",weekDay,monthName,day];
		DLog(@"formattedString::: %@",formattedString);
		return formattedString;
	}
	
	return nil;
}*/
-(NSString *)getFormattedHeaderTitleString:(NSString *)_stringdate{
	NSDate *date = nil;
	if (_stringdate != nil) {
		date				= [G2Util convertStringToDate1:_stringdate];
		NSString *formattedDateStr = @"";
		formattedDateStr = [G2Util getFormattedRegionalDateString:date];
		//DLog(@"Formatted Date %@",formattedDateStr);
		return formattedDateStr;
	}
	return nil;
}
-(NSMutableString *)getMissingFieldsString:(NSMutableArray *)missingfields{
	NSMutableString *missingfield = [NSMutableString string];
	if ([missingfields count]>0) {
		for (int i=0; i<[missingfields count]; i++) {
			if (![[missingfields objectAtIndex:i]isEqualToString: @""]) {
				[missingfield appendString:[NSString stringWithFormat:@"%@",[missingfields objectAtIndex:i]]];
			}	
			if (!(i+1 ==[missingfields count])) {
				[missingfield appendString:@","];
			}
		}
		return missingfield;
	}
	return nil;
}
-(NSString *)getAvailableFieldsString:(NSMutableArray *)availablefields{
	//NSString *availableStr= @"";
	NSMutableString *availableStr = [NSMutableString string];
	if (availablefields != nil && [availablefields count]>0) {
		//availableStr = [NSString stringWithFormat:@"%@ %@",[availablefields objectAtIndex:0],[availablefields objectAtIndex:1]];
		for (int i = 0; i<[availablefields count]; i++) {
			[availableStr appendString:[availablefields objectAtIndex:i]];
		}
	}
	return availableStr;
}

#pragma mark -
#pragma mark Button Action Methods
-(void)submissionErrorBackAction{
	//TODO:BackAction
	//currently popping to time entry controller
	[self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	DLog(@"\n numberOfSectionsInTableView::SubmissionErrorViewController \n");
	DLog(@"Key Array %@",uniquekeyArray);
	return [uniquekeyArray count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	DLog(@"\n numberOfRowsInSection::SubmissionErrorViewController \n");
	if ([submissionErrorsDict count]>0) {
		return [(NSMutableArray *)[submissionErrorsDict objectForKey:[uniquekeyArray objectAtIndex:section]]count];
	}
	return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	//return 90.0;
	return Each_Cell_Row_Height_80;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	
	DLog(@"\n viewForHeaderInSection::SubmissionErrorViewController \n");
	NSString *sectionTitle=[self tableView:tableView titleForHeaderInSection:section];
	if(sectionTitle==nil){
		return nil;
	}
	sectionHeaderlabel=[[UILabel alloc]initWithFrame:CGRectMake(10.0,
																0.0, 
																self.submissionTableView.frame.size.width, 
																25.0)];
	sectionHeaderlabel.backgroundColor=[UIColor clearColor];
	sectionHeaderlabel.text=sectionTitle;
	UIView *tempsectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0.0,
															 0.0,
															 self.submissionTableView.frame.size.width,
															 25.0)];
	[tempsectionHeader setBackgroundColor:[UIColor clearColor]];
    self.sectionHeader=tempsectionHeader;
	
	[sectionHeaderlabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_18]];
	[sectionHeaderlabel setTextColor:RepliconStandardWhiteColor];
	[sectionHeaderlabel setTextAlignment:NSTextAlignmentLeft];
	[sectionHeader addSubview:sectionHeaderlabel];	
	
	
	return self.sectionHeader;
	//return nil;
	
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	DLog(@"\n cellForRowAtIndexPath::SubmissionErrorViewController \n");
    static NSString *CellIdentifier = @"Cell";
    
    cell =(G2SubmissionErrorCellView *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //if (cell == nil) {
	cell = [[G2SubmissionErrorCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    //}
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	NSString *sectionDate				= [uniquekeyArray objectAtIndex:indexPath.section];
	NSMutableArray *timeEntryArray		= [submissionErrorsDict objectForKey:sectionDate];
	G2TimeSheetEntryObject *timeEntryObj	= [timeEntryArray objectAtIndex:indexPath.row];
	NSMutableArray *missingFields		= [timeEntryObj missingFields];
	NSMutableArray *availableFields		= [timeEntryObj availableFields];
	NSMutableString *missingfieldlist	= nil;		//[NSMutableString string];		//fixed memory leaks
	DLog(@"availableFields array %@",availableFields);
	DLog(@"availableFields array count %lu",(unsigned long)[availableFields count]);
	NSString *availablefields			= [self getAvailableFieldsString:availableFields];
	missingfieldlist					= [self getMissingFieldsString:missingFields];
	//DLog(@"missing String  %@",missingfieldlist);
	//DLog(@"available String  %@",availablefields);
	
    [cell setSubmissionErrorFields:availablefields missingfield:missingfieldlist];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	
	DLog(@"\n titleForHeaderInSection ::SubmissionErrorViewController \n");
	if ([uniquekeyArray count]>0) {
		NSString *headerTitle = [self getFormattedHeaderTitleString:[uniquekeyArray objectAtIndex:section]];
		return headerTitle;
	}
	return nil;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	
	 */
	
	//TODO: Push the controller to AddNewTimeEntryViewController for Editing case
	
	//id timeEntryObj = [submissionErrorsDict objectForKey:[keys objectAtIndex:indexPath.section]];
	entryKey = [uniquekeyArray objectAtIndex:indexPath.section];
	//DLog(@"key ::  SubmissionErrorViewController %@",entryKey);
	//DLog(@"[submissionErrorsDict objectForKey:key] count %d",[[submissionErrorsDict objectForKey:entryKey] count]);
	//DLog(@"submissionErrorsDict %@",submissionErrorsDict);
	NSMutableArray *timeEntries = [submissionErrorsDict objectForKey:entryKey];
	//DLog(@"timeEntries ::  SubmissionErrorViewController %@",timeEntries);
	
	id timeEntryObj;
	//DLog(@"Time Entries Object AtIndex zero %@",[timeEntries objectAtIndex:0]);
	if ([timeEntries count]>0) {
		timeEntryObj = [timeEntries objectAtIndex:0];
		if ([timeEntryObj isKindOfClass:[G2TimeSheetEntryObject class]]) {
			
			DLog(@"Client Name ::  SubmissionErrorViewController %@",[timeEntryObj clientName]);
			DLog(@"Project Name :: SubmissionErrorViewController %@",[timeEntryObj projectName]);
			DLog(@"Date :: SubmissionErrorViewController         %@",[Util convertPickerDateToString:[timeEntryObj entryDate]]);
			DLog(@"Time	:: SubmissionErrorViewController	  %@",[timeEntryObj numberOfHours]);
			DLog(@"taskName:: SubmissionErrorViewController	  %@",[timeEntryObj taskName]);
			DLog(@"comments:: SubmissionErrorViewController	  %@",[timeEntryObj comments]);
			
			NSMutableString *clientProjectName = [NSMutableString string];
			if ([timeEntryObj clientName] != nil && ![[timeEntryObj clientName] isKindOfClass:[NSNull class]]
				&& ![[timeEntryObj clientName] isEqualToString:@""]) {
				[clientProjectName appendString:[timeEntryObj clientName]];
			}
			if ([timeEntryObj projectName] != nil && ![[timeEntryObj projectName] isKindOfClass:[NSNull class]]
				&& ![[timeEntryObj projectName] isEqualToString:@""]) {
				if ([timeEntryObj clientName] != nil && ![[timeEntryObj clientName] isKindOfClass:[NSNull class]]
					&& ![[timeEntryObj clientName] isEqualToString:@""]){
					DLog(@"Client is present for this user");
					[clientProjectName appendString:[NSString stringWithFormat:@"/%@",[timeEntryObj projectName]]];
				}else {
					[clientProjectName appendString:[NSString stringWithFormat:@"%@",[timeEntryObj projectName]]];
				}
			}
			if ([clientProjectName isEqualToString:@""]) {
				[clientProjectName appendString:@""];
			}
            
            
			RepliconAppDelegate *appDelegate= (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
			G2TimeEntryViewController *addNewTimeEntryViewController = [[G2TimeEntryViewController alloc] 
												initWithEntryDetails:timeEntryObj sheetId:nil screenMode:EDIT_TIME_ENTRY 
												permissionsObj:permissionsObj preferencesObj:preferencesObj:appDelegate.isInOutTimesheet:appDelegate.isLockedTimeSheet:self];
			
			[addNewTimeEntryViewController setSubmissionErrorDelegate:self];
			
			[self.navigationController pushViewController:addNewTimeEntryViewController animated:YES];
			
		}else {
			//TODO: Handle the case when the time entry is of TimeOff type's
		}
		
		
		
	}else {
		//No entries
	}
	
}
-(void)resetSubmissionErrorDetails{
	DLog(@"resetErrorDetails:::SubmissionErrorViewController");
	if (submissionErrorsDict != nil && [submissionErrorsDict count]>=1) {
		[submissionErrorsDict removeObjectForKey:entryKey];
		for (int i=0; i<[uniquekeyArray count]; i++) {
			if ([[uniquekeyArray objectAtIndex:i] isEqualToString:entryKey]) {
				[uniquekeyArray removeObjectAtIndex:i];
				if ([submissionErrorsDict count]==0) {
					//[self.navigationController popToRootViewControllerAnimated:YES];
					[self.navigationController popToViewController:parentController animated:YES];
				}
			}
		}
		[submissionTableView reloadData];
		[self.navigationController popViewControllerAnimated:YES];
	}	
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */
/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source.
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	self.warningLabel=nil;
	self.warningImage=nil;
    self.submissionTableView=nil;
	self.topToolbarLabel=nil;
	self.tableHeader=nil;
	self.innerTopToolbarLabel=nil;
    self.sectionHeaderlabel=nil;
    self.sectionHeaderlabel=nil;
    self.sectionHeader=nil;
}





@end

