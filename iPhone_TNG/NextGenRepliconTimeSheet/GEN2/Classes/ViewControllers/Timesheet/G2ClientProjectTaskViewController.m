//
//  ClientProjectTaskViewController.m
//  Replicon
//
//  Created by Hepciba on 4/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2ClientProjectTaskViewController.h"
#import "G2ViewUtil.h"
#import "RepliconAppDelegate.h"

@implementation G2ClientProjectTaskViewController

@synthesize clientProjectTaskTable;
@synthesize pickerBackgroundView;
@synthesize	customPicker;
@synthesize clientsArr;
@synthesize projectsArr;
@synthesize selectedName;
@synthesize tnewTimeEntryDelegate;
@synthesize  selectedIndex;
@synthesize  taskViewController;
@synthesize  headerView;
@synthesize  keyboardToolbar;

@synthesize firstSectionfieldArr;
//static float keyBoardHeight=320.0;
static BOOL doneClicked = NO;

- (id) initWithTimeEntryObject:(G2TimeSheetEntryObject *)entryObject 
			   withPermissions:(G2PermissionSet *)_permissions andPreferences:(G2Preferences *)_preferences
{
	self = [super init];
	if (self != nil) {
		
		if (entryObject != nil) {
			[self populateClientProjectDetails:entryObject];
		}
		  
		if (firstSectionfieldArr == nil) {
			firstSectionfieldArr = [NSMutableArray array];
		}
//		if (clientsArr==nil) {
//			clientsArr=[[NSMutableArray alloc]init];
//		}
//		if (projectsArr==nil) {
//			projectsArr=[[NSMutableArray alloc]init];
//		}
		if (supportDataModel == nil) {
			supportDataModel = [[G2SupportDataModel alloc] init];
		}
		if (selectedName == nil) {
			selectedName = [NSMutableString string];
		}
		[self setFirstSectionFields:_permissions];
	}
	return self;
}

-(void)populateClientProjectDetails:(G2TimeSheetEntryObject *)entryObject {
	
	timeEntryObject = [G2TimeSheetEntryObject createObjectWithDefaultValues];
	[timeEntryObject setClientName:[entryObject clientName]];
	[timeEntryObject setProjectName:[entryObject projectName]];
	[timeEntryObject setClientIdentity:[entryObject clientIdentity]];
	[timeEntryObject setProjectIdentity:[entryObject projectIdentity]];
	[timeEntryObject.taskObj setTaskName:[entryObject.taskObj taskName]];
	[timeEntryObject.taskObj setTaskIdentity:[entryObject.taskObj taskIdentity]];
	[timeEntryObject.taskObj setParentTaskId:[entryObject.taskObj parentTaskId]];
}

-(void)setFirstSectionFields:(G2PermissionSet *)permissions{
	NSMutableArray *datasourceArray = [NSMutableArray array];
	clientsArr = [supportDataModel getAllClientNames];
		//if ([clientsArr  containsObject:NONE_STRING]) {
//			[clientsArr removeObject:NONE_STRING];
//			[clientsArr insertObject:NONE_STRING atIndex:0];
//		}
	if (clientsArr != nil && [clientsArr count] > 0) {
		NSString *firstClientId = [supportDataModel getClientIdentityForClientName:[clientsArr objectAtIndex:0]];
		projectsArr = [supportDataModel getProjectsForClientWithClientId:firstClientId];
	}
	
	
	if (clientsArr != nil && [clientsArr count]>0) {
		[datasourceArray addObject:clientsArr];
	}
	if (projectsArr != nil && [projectsArr count]>0) {
		[datasourceArray addObject:projectsArr];
	}
	NSMutableString *selectedClientProject = [NSMutableString string];
	NSString *clientName  = [timeEntryObject clientName];
	NSString *projectName = [timeEntryObject projectName];
	
	if (clientName != nil && ![clientName isEqualToString:@""]) {
		//[selectedClientProject appendString:clientName];
	}
	if (projectName != nil && ![projectName isEqualToString:@""]) {
		[selectedClientProject appendString:[NSString stringWithFormat:@"%@",projectName]];
	}
	//TODO:Check permission for both/Against projects:DONE
	
	BOOL againstProjects		= [permissions projectTimesheet];
	BOOL both					= [permissions bothAgainstAndNotAgainstProject];

	if ([selectedClientProject isEqualToString:@""] ) {
		if (both) {
			[selectedClientProject appendString:NONE_STRING];
		}else if(againstProjects){
			[selectedClientProject appendString:SelectString];
		}
	}
	
	//DLog(@"setFirstSectionFields :::Selected Name11====> %@",selectedName);
	
	NSMutableDictionary *clientProjectRow = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											 RPLocalizedString(ClientProject,@""),@"fieldName",
											 selectedClientProject,@"fieldValue",
											 DATA_PICKER,@"fieldType",
											 datasourceArray,@"datasourceArray",nil];
	[firstSectionfieldArr addObject:clientProjectRow];
	
	//NSString *taskName  = [timeEntryObject taskName];
	NSString *taskName        = [timeEntryObject.taskObj taskName];
	NSString *projectIdentity = [timeEntryObject projectIdentity];
	NSString *clientIdentity  = [timeEntryObject clientIdentity];
	clientIdentity = [clientIdentity isEqualToString:@""]? NO_CLIENT_ID:clientIdentity;
	if (taskName == nil || [taskName isKindOfClass:[NSNull class]]) {
		if ( projectName != nil && ![projectName isEqualToString:@""]){
			BOOL taskExists = [supportDataModel checkProjectHasTasksForSelection:projectIdentity client:clientIdentity];
			if(taskExists){
				taskName = SelectString;	
			}else {
				taskName = NoTaskString;
			}
		}else {
			taskName = NoTaskString;
		}
	}
	//DLog(@"setFirstSectionFields :::Task Name====> %@",taskName);
	
	NSMutableDictionary *taskRow = [NSMutableDictionary dictionaryWithObjectsAndKeys:
									RPLocalizedString(Task,@""),@"fieldName",
									taskName,@"fieldValue",
									MOVE_TO_NEXT_SCREEN,@"fieldType",nil];
	
	[firstSectionfieldArr addObject:taskRow];
	
	
}
#pragma mark -
#pragma mark View LifeCycle Methods
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	
	if (clientProjectTaskTable==nil) {
		clientProjectTaskTable=[[UITableView alloc]initWithFrame:ClientProjectTaskTableFrame style:UITableViewStyleGrouped];
		
	}
	clientProjectTaskTable.delegate=self;
	clientProjectTaskTable.dataSource=self;
	[clientProjectTaskTable setScrollEnabled:NO];
	//[clientProjectTaskTable setBackgroundColor:[UIColor clearColor]];
	
	
	[clientProjectTaskTable setBackgroundColor:[UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0]];
    clientProjectTaskTable.backgroundView=nil;
	[self.view setBackgroundColor:[UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0]];
	
	if (headerView == nil) {
		headerView = [[UIView alloc] initWithFrame:CGRectMake(15.0,
															  100.0,
															  clientProjectTaskTable.frame.size.width,
															  30.0)];
	}
	UILabel	*headerlabel=[[UILabel alloc]initWithFrame:CGRectMake(15.0, 0.0, self.view.frame.size.width,30.0)];
	
	[headerlabel setBackgroundColor:RepliconStandardClearColor];
	[headerlabel setText:RPLocalizedString(MSG_SELECT_PROJ, MSG_SELECT_PROJ)];
	headerlabel.textColor = RepliconStandardTextColor;
	[headerlabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
	[headerlabel setTextAlignment:NSTextAlignmentLeft];
	[headerlabel setNumberOfLines:1];
	[headerView addSubview:headerlabel];
	
	[headerView setBackgroundColor:[UIColor clearColor]];
	[self.clientProjectTaskTable setTableHeaderView:headerView];
	[self.view addSubview:clientProjectTaskTable];
	
	UIBarButtonItem *leftButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
	[self.navigationItem setLeftBarButtonItem:leftButton1 animated:NO];
	
	rightButton1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
	[rightButton1 setEnabled:NO];
	[self.navigationItem setRightBarButtonItem:rightButton1 animated:NO];
	

	[G2ViewUtil setToolbarLabel: self withText: RPLocalizedString( ClientProjectTask, ClientProjectTask)];

}

-(void)viewWillAppear:(BOOL)animated {
	//[self setFirstSectionFields];
	//[clientProjectTaskTable reloadData];
}
/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DLog(@"\nInside::tableView cellForRowAtIndexPath\n");
    static NSString *CellIdentifier = @"Cell";
	cell = (G2TimeEntryCellView*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        cell = [[G2TimeEntryCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
	//cell.clientProjectTaskDelegate = self;
	NSString *fieldName  = @"";
	NSString *fieldValue = @"";
	NSNumber *tagNumber=nil;
    int tag=[tagNumber intValue];
	[cell newTimeEntryFields:indexPath.row];
	
	if (indexPath.section==0) {
		if (indexPath.row==0) {
			tag = CLIENT_PROJECT;
		}
		else if (indexPath.row==1) {	
			tag = TASK;
		}
		fieldName  = [[firstSectionfieldArr objectAtIndex:indexPath.row] objectForKey:@"fieldName"];
		fieldValue = [[firstSectionfieldArr objectAtIndex:indexPath.row] objectForKey:@"fieldValue"];
		//fieldValue = selectedName;
	}
	[cell clientProjectCellLayout:fieldName fieldVal:fieldValue withTag:tag];
	[cell.fieldButton addTarget:self action:@selector(cellButtonAction:withEvent:) forControlEvents:UIControlEventTouchUpInside];
	
	//Disable task field if no clientProject is selected
	if ([fieldName isEqualToString:@"Task"] && 
		[fieldValue isEqualToString:NoTaskString]) {
		//DLog(@"Field is Task && ProjectClient is 'Select'");
			[[firstSectionfieldArr objectAtIndex:indexPath.row] setObject:NoTaskString forKey:@"fieldValue"];
			[cell.fieldButton setTitle:RPLocalizedString(NoTaskString, NoTaskString)  forState:UIControlStateNormal];
			[cell setUserInteractionEnabled:NO];
			[cell.fieldButton setEnabled:NO];
			[cell.fieldName setTextColor:RepliconStandardGrayColor];
			[cell.fieldButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
			//[timeEntryObject setTaskName:nil];
			//[timeEntryObject setTaskIdentity:nil];
	}
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return nil;
}

#pragma mark -
#pragma mark NavigationBarButton Actions
-(void)cancelAction:(id)sender
{
	if (!doneClicked) {
		//Remove Task details or client/project details if selected any
		//if ([timeEntryObject taskName] != nil || [timeEntryObject taskIdentity] != nil) {
		if ([timeEntryObject.taskObj taskName] != nil || [timeEntryObject.taskObj taskIdentity] != nil) {
			[timeEntryObject.taskObj setTaskName:nil];
			[timeEntryObject.taskObj setTaskIdentity:nil];
		}
		
		if ([timeEntryObject clientName] != nil || [timeEntryObject clientIdentity] != nil) {
			[timeEntryObject setClientName:nil];
			[timeEntryObject setClientIdentity:nil];
		}
		
		if ([timeEntryObject projectName] != nil || [timeEntryObject projectIdentity] != nil) {
			[timeEntryObject setProjectName:nil];
			[timeEntryObject setProjectIdentity:nil];
		}
	}
	
	
	[self.navigationController popViewControllerAnimated:YES];
	[tnewTimeEntryDelegate performSelector:@selector(animateCellWhichIsSelected)];
}

-(void)doneAction:(id)sender{
	doneClicked = YES;
	NSString *clientName  = [timeEntryObject clientName];
	NSString *projectName = [timeEntryObject projectName];
	NSString *taskName    = [timeEntryObject.taskObj taskName];
	//TODO: Get Task Name
	//taskName= @"";
	NSMutableString *clientProjectTask = [NSMutableString string];
	if (clientName != nil && ![clientName isKindOfClass:[NSNull class]]
		&& ![clientName isEqualToString:@""]) {
		//[clientProjectTask appendString:clientName];
	}
	if (projectName != nil && ![projectName isKindOfClass:[NSNull class]]
		&& ![projectName isEqualToString:@""] && ![projectName isEqualToString:@"null"]) {
		[clientProjectTask appendString:[NSString stringWithFormat:@"%@",projectName]];
	}
	if (taskName != nil && ![taskName isKindOfClass:[NSNull class]]
		&& ![taskName isEqualToString:@""]) {
		
		[clientProjectTask appendString:[NSString stringWithFormat:@"/%@",taskName]];
	}
	
	
	//DLog(@"Task Name :::ClientProjectTaskViewController %@",taskName);
	//DLog(@"clientProjectTask:::ClientProjectTaskViewController %@",clientProjectTask);
	//NSString *clientProjectTask = [NSString stringWithFormat:@"%@/%@/%@",clientName,projectName,taskName];
	if (tnewTimeEntryDelegate != nil) {
		DLog(@"doneAction::CLientProjectTaskViewController");
		[tnewTimeEntryDelegate performSelector:@selector(updateSelectedClientProject:) withObject:timeEntryObject];
		[tnewTimeEntryDelegate performSelector:@selector(updateClientProjectTaskField:) withObject:clientProjectTask];
	}
	[self.navigationController popViewControllerAnimated:YES];
	[tnewTimeEntryDelegate performSelector:@selector(animateCellWhichIsSelected)];
}
#pragma mark -
#pragma mark Button Actions

-(void)deselectRowAtIndexPath:(NSIndexPath*)indexPath
{
	//ExpenseEntryCellView *cell = (ExpenseEntryCellView *)[newExpenseEntryTable cellForRowAtIndexPath:currentIndexPath];
	//	[cell setBackgroundColor:[UIColor whiteColor]];
	[self tableViewCellUntapped:indexPath];
	[clientProjectTaskTable deselectRowAtIndexPath:indexPath animated:YES];	
}

-(void)animateCellWhichIsSelected
{
	//[self deselectRowAtIndexPath:currentIndexPath];
	G2TimeEntryCellView *entryCell = (G2TimeEntryCellView *)[clientProjectTaskTable cellForRowAtIndexPath:selectedIndex];
	[entryCell setBackgroundColor:iosStandaredBlueColor];
	//[self performSelector:@selector(deselectRowAtIndexPath:) withObject:selectedIndex afterDelay:0.50];	DE2949 - General: Fade out is too slow
    [self performSelector:@selector(deselectRowAtIndexPath:) withObject:selectedIndex afterDelay:0.0];
}

-(void)tableCellTappedAtIndex:(NSIndexPath*)indexPath
{
	G2TimeEntryCellView *entryCell = (G2TimeEntryCellView *)[clientProjectTaskTable cellForRowAtIndexPath:indexPath];
	[entryCell setBackgroundColor:iosStandaredBlueColor];
	if (entryCell.fieldName !=nil) {
		[entryCell.fieldName setTextColor:iosStandaredWhiteColor];
	}
	if (entryCell.fieldButton !=nil) {
		[entryCell.fieldButton setTitleColor:iosStandaredWhiteColor forState:UIControlStateNormal];
	}
	if (entryCell.textField !=nil) {
		[entryCell.textField setTextColor:iosStandaredWhiteColor];
	}
	
	
	//[self handleButtonClicks: indexPath];
}


-(void)tableViewCellUntapped:(NSIndexPath*)indexPath
{
	G2TimeEntryCellView *entryCell = (G2TimeEntryCellView *)[clientProjectTaskTable cellForRowAtIndexPath:indexPath];
	[entryCell.fieldName setTextColor:RepliconStandardBlackColor];
	[entryCell.fieldButton setTitleColor:FieldButtonColor forState:UIControlStateNormal];
	[entryCell.textField setTextColor:FieldButtonColor];
	[entryCell setBackgroundColor:iosStandaredWhiteColor];
	
	//[entryCell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	//[self handleButtonClicks: indexPath];
	
}



- (void)pickerDoneAction:(id)sender{
	//[pickerBackgroundView setHidden:YES];
	//[self resetTableViewUsingSelectedIndex:nil];
}

- (void) cellButtonAction: (id) sender withEvent: (UIEvent *) event{
	//DLog(@"\ncellButtonAction\n");
	[rightButton1 setEnabled:YES];
	UITouch * touch = [[event allTouches] anyObject];
	CGPoint location = [touch locationInView: clientProjectTaskTable];
	NSIndexPath * indexPath = [clientProjectTaskTable indexPathForRowAtPoint: location];
	//DLog(@"indexPathPressed Button %d %d",indexPath.row,indexPath.section);
	[self handleButtonClicks:indexPath];
}

-(void)handleButtonClicks:(NSIndexPath*)selectedButtonIndex
{
	
	if (selectedIndex != nil && selectedIndex.row == CLIENT_PROJECT) {
		[customPickerView doneClickAction:nil];
	}
	
	[self tableViewCellUntapped:selectedIndex];
	[self tableCellTappedAtIndex:selectedButtonIndex];
	//DLog(@"handleButtonClicks ");        
	NSMutableArray *dataArray = nil;
	NSString *fieldType;
	self.selectedIndex=selectedButtonIndex;
	cell = (G2TimeEntryCellView *)[self.clientProjectTaskTable cellForRowAtIndexPath:selectedIndex];
	
	if (customPickerView == nil) {
		customPickerView = [[G2CustomPickerView alloc] initWithFrame:
							CGRectMake(0, 160, 320, 320)];
		[customPickerView setDelegate:self];
		[customPickerView setToolbarRequired:YES];
		[self.view addSubview:customPickerView];
	}
	
	if ( selectedIndex.row <[firstSectionfieldArr count]&& selectedIndex.row == CLIENT_PROJECT) {
		
		fieldType = [[firstSectionfieldArr objectAtIndex:selectedIndex.row]objectForKey:@"fieldType"];
		if ([fieldType isEqualToString:DATA_PICKER]) {
			//DLog(@"handleButtonClicks DATA_PICKER");
			
			dataArray = [[firstSectionfieldArr objectAtIndex:selectedIndex.row]objectForKey:@"datasourceArray"];
			//DLog(@"handleButtonClicks:::DataSource Array %@",dataArray);
			[customPickerView setDataSourceArray:dataArray];
			[customPickerView setDateIndexPath:selectedIndex];
			[customPickerView setOtherPickerIndexPath:selectedIndex];
		}
		[customPickerView showHideViewsByFieldType:fieldType];
		[customPickerView showHideSegmentControl:YES];
		[self reloadDatapickerforSelectedClientProject];
	}
	if ( selectedIndex.row <[firstSectionfieldArr count]&& selectedIndex.row == TASK) {
		if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)	{
			
			#ifdef PHASE1_US2152
				[G2Util showOfflineAlert];
				return;
			#endif
		}
		
		fieldType = [[firstSectionfieldArr objectAtIndex:selectedIndex.row]objectForKey:@"fieldType"];
		if ([fieldType isEqualToString:MOVE_TO_NEXT_SCREEN]) {
			
			[self fetchTasksForSelectedProject];
			
		}
	}
}

-(void)updatePickerSelectedValueAtIndexPath:(NSIndexPath *)otherPickerIndexPath :(int) 
									   row :(int)component{
	//DLog(@"updatePickerSelectedValueAtIndexPath::ClientProjectTaskViewCOntroller");
	
	NSMutableDictionary *fieldDetails = [firstSectionfieldArr objectAtIndex:otherPickerIndexPath.row];
	NSString *fieldName = [fieldDetails objectForKey:@"fieldName"];
	NSMutableArray *datasourceArray = [fieldDetails objectForKey:@"datasourceArray"];
	if ([fieldName isEqualToString:RPLocalizedString(ClientProject,@"")]) {
		if (datasourceArray != nil && [datasourceArray count]>0) {
			projectsArr = [datasourceArray objectAtIndex:component];
			
			NSString *selectedProjectName = [projectsArr objectAtIndex:row];
			NSString *projectId = [selectedProjectName isEqualToString:NONE_STRING] ? @"null" : nil;
			//fetch projectId for projectName;
			if ([selectedProjectName isEqualToString:NONE_STRING]) {
				[timeEntryObject setProjectName: @"None"];
				[timeEntryObject setProjectIdentity: nil];
			}
			if (![selectedProjectName isEqualToString:NONE_STRING]) {
				projectId = [supportDataModel getProjectIdentityWithProjectName:selectedProjectName];
		//		[fieldDetails setObject:selectedProjectName forKey:@"selectedProjectName"];
		//		[fieldDetails setObject:projectId forKey:@"selectedProjectIdentity"];
				[timeEntryObject setProjectName:selectedProjectName];
				[timeEntryObject setProjectIdentity:projectId];
			}			
			NSString *clientName = [timeEntryObject clientName];
			NSString *clientIdentity = [timeEntryObject clientIdentity];
			//NSString *selectedname = nil;
			
			if (clientName == nil && selectedProjectName != nil) {
				clientName = [clientsArr objectAtIndex:0];
				clientIdentity = [supportDataModel getClientIdentityForClientName:clientName];
				[timeEntryObject setClientName:clientName];
				[timeEntryObject setClientIdentity:clientIdentity];
			}
			
			/*
			if (clientIdentity != nil && ![clientIdentity isKindOfClass:[NSNull class]]) {
				if (clientName != nil && [clientName isEqualToString: NONE_STRING] && 
					[clientName isEqualToString:selectedProjectName]) {
					selectedname = [NSString stringWithString: NONE_STRING];
				} else {
					selectedname = [NSString stringWithFormat:@"%@",clientName,selectedProjectName];
				}
			}
			else if (clientName == nil && selectedProjectName != nil) {
				clientName = [clientsArr objectAtIndex:0];
				clientIdentity = [supportDataModel getClientIdentityForClientName:clientName];
				[timeEntryObject setClientName:clientName];
				[timeEntryObject setClientIdentity:clientIdentity];
				if ([selectedProjectName isEqualToString: NONE_STRING]) {
					selectedname = [NSString stringWithFormat:@"%@",NONE_STRING];
				} else	{
					selectedname = [NSString stringWithFormat:@"%@/%@",NONE_STRING,selectedProjectName];
				}
			}
			else {
				if ([selectedProjectName isEqualToString: NONE_STRING]) {
					selectedname = [NSString stringWithFormat:@"%@",NONE_STRING];
				} else	{
					selectedname = [NSString stringWithFormat:@"%@/%@",NONE_STRING,selectedProjectName];
				}
			}
			 */
			
			[fieldDetails setObject:selectedProjectName forKey:@"fieldValue"];
			[self updateFieldAtIndexWithSelectedValue:otherPickerIndexPath :selectedProjectName];
			//reset Task Values
			clientIdentity = [clientName  isEqualToString: NONE_STRING] ?@"null" : clientIdentity;
			if (![supportDataModel checkProjectHasTasksForSelection:projectId client:clientIdentity]) {
				[self disableTaskSelection];
			}
			else {
				[self enableTaskSelection];
			}
			[timeEntryObject.taskObj setTaskName:nil];
			[timeEntryObject.taskObj setTaskIdentity:nil];
			[timeEntryObject.taskObj setParentTaskId:nil];
		}
		
	}
	//refresh Cell to update value
	//NSArray *indexPathsArray = [NSArray arrayWithObject:otherPickerIndexPath];
	//[clientProjectTaskTable reloadRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationNone];
}

-(NSMutableArray *)getDependantComponentData: (NSIndexPath *)selectedIndexPathObj :(id)selectedValue :(NSInteger)component {
	DLog(@"getDependantComponentData ");
	//fetch fieldName for the component.
	NSMutableDictionary *fieldDetails = [firstSectionfieldArr objectAtIndex:selectedIndexPathObj.row];
	NSString *fieldName = [fieldDetails objectForKey:@"fieldName"];
	
	
	//update selected data into TimesheetEntryObj based on fieldName
	if ([fieldName isEqualToString:RPLocalizedString(ClientProject,@"")]) {
		NSString *selectedClientName = (NSString *)selectedValue;
		//fetch clientIdentity for clientName.
		NSString *clientId = [supportDataModel getClientIdentityForClientName:selectedClientName];
	//	[fieldDetails setObject:clientId forKey:@"selectedClientIdentity"];
	//	[fieldDetails setObject:selectedClientName forKey:@"selectedClientName"];
		[timeEntryObject setClientName:selectedClientName];
		[timeEntryObject setClientIdentity:clientId];
		
		projectsArr = [supportDataModel getProjectsForClientWithClientId:clientId];
		if (projectsArr != nil) {
			NSMutableArray *dataSource = [fieldDetails objectForKey:@"datasourceArray"];
			if (dataSource != nil && [dataSource count] > 1) {
				[dataSource replaceObjectAtIndex:1 withObject:projectsArr];
			}
		}
		return projectsArr;
	}
	
	return nil;
}

-(void)updatePickerValuesAtZeroIndex :(NSMutableArray *)zeroIndexValuesArray :(NSIndexPath *)otherIndexPath {
	
	[self tableViewCellUntapped:otherIndexPath];
	
	if (zeroIndexValuesArray != nil && [zeroIndexValuesArray count] > 0 && otherIndexPath != nil) {
		
		NSString *selectedClientName = [timeEntryObject clientName];
		NSString *selectedProjectName = [timeEntryObject projectName];
		if (selectedClientName == nil && selectedProjectName == nil) {
			
			NSMutableDictionary *fieldDetails = [firstSectionfieldArr objectAtIndex:otherIndexPath.row];
			NSString *fieldName = [fieldDetails objectForKey:@"fieldName"];
			if ([fieldName isEqualToString:RPLocalizedString(ClientProject,@"")]) {
				
				NSString *selectedClientName = [zeroIndexValuesArray objectAtIndex:0];
				//fetch clientIdentity for clientName.
				NSString *clientId = [supportDataModel getClientIdentityForClientName:selectedClientName];
				
				[timeEntryObject setClientName:selectedClientName];
				[timeEntryObject setClientIdentity:clientId];
			//	[fieldDetails setObject:selectedClientName forKey:@"selectedClientName"];
			//	[fieldDetails setObject:clientId forKey:@"selectedClientIdentity"];
				projectsArr = [supportDataModel getProjectsForClientWithClientId:clientId];
				NSString *selectedProjectName = [projectsArr objectAtIndex:otherIndexPath.row];
				//fetch projectId for projectName;
				NSString *projectId = [supportDataModel getProjectIdentityWithProjectName:selectedProjectName];
				[timeEntryObject setProjectName:selectedProjectName];
				if (projectId != nil && ![projectId isEqualToString:NO_CLIENT_ID]) {
					[timeEntryObject setProjectIdentity:projectId];
				}
				
				
			//	[fieldDetails setObject:selectedProjectName forKey:@"selectedProjectName"];
			//	[fieldDetails setObject:projectId forKey:@"selectedProjectIdentity"];
				
				//NSString *clientName = [timeEntryObject clientName];
				NSString *selectedname = [NSString stringWithFormat:@"%@",selectedProjectName];
				[fieldDetails setObject:selectedname forKey:@"fieldValue"];
				
				//refresh Cell to update value
				//NSArray *indexPathsArray = [NSArray arrayWithObject:otherIndexPath];
				//[clientProjectTaskTable reloadRowsAtIndexPaths:indexPathsArray withRowAnimation:UITableViewRowAnimationNone];
				[self updateFieldAtIndexWithSelectedValue:otherIndexPath :selectedname];
				
				if ([supportDataModel checkProjectHasTasksForSelection:projectId client:clientId]) {
					[self enableTaskSelection];
				}
				else {
					[self disableTaskSelection];
				}
				[timeEntryObject.taskObj setTaskName:nil];
				[timeEntryObject.taskObj setTaskIdentity:nil];
				[timeEntryObject.taskObj setParentTaskId:nil];
			}
		}
	}
}
-(void)reloadDatapickerforSelectedClientProject{
	NSUInteger clientIndex = 0;
	NSUInteger projectIndex = 0;
	
		NSString *selectedClient  = [timeEntryObject clientName];
	    NSString *selectedProject = [timeEntryObject projectName];
		//NSString *clientId = [timeEntryObject clientIdentity];
	    projectsArr =[self getDependantComponentData:selectedIndex :selectedClient :0];
		clientIndex  = [G2Util getIndex:clientsArr forObj:selectedClient];
		projectIndex = [G2Util getIndex:projectsArr forObj:selectedProject];	
	[customPickerView updateDataSourceArray:projectsArr component:0];
	[customPickerView.pickerView reloadAllComponents];
	if ([clientsArr count] > 0 && [projectsArr count] > 0) {
		[customPickerView.pickerView selectRow:clientIndex inComponent:0 animated: NO];
		[customPickerView.pickerView selectRow:projectIndex inComponent:1 animated: NO];
	}
	
	
}


-(void)updateFieldAtIndexWithSelectedValue :(NSIndexPath *)selectedIndexPath :(id)selectedValue {
	
	G2TimeEntryCellView *entryCell = (G2TimeEntryCellView *)[clientProjectTaskTable cellForRowAtIndexPath:selectedIndexPath];
	[entryCell.fieldButton setTitle:selectedValue forState:UIControlStateNormal];
	
	
}

#pragma mark Task Methods

-(void)fetchTasksForSelectedProject {
	
	NSString *projectIdentity = [timeEntryObject projectIdentity];
	NSString *projectName = [timeEntryObject projectName];
	if (projectIdentity != nil && ![projectIdentity isKindOfClass:[NSNull class]]
		&& ![projectName isEqualToString:@"None"]) {
		
		if ([[NetworkMonitor sharedInstance]networkAvailable]) {
			[[G2RepliconServiceManager timesheetService] sendRequestToFetchTasksForProject:timeEntryObject];
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
			[[NSNotificationCenter defaultCenter] 
			 addObserver:self selector:@selector(showTasksForProject) name:TASKS_RECEIVED_NOTIFICATION object:nil];
		}
		else {
			//check if any tasks for project in db.
			[self showTasksForProject];
		}

		
	}
}

-(void)showTasksForProject {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:TASKS_RECEIVED_NOTIFICATION object:nil];
	
	NSMutableArray *tasksForProjects = [supportDataModel getTasksForProjectWithParentTask:
										[timeEntryObject projectIdentity]: nil];
	
	if (tasksForProjects == nil) {
//		NSString *status = @"Alert";//Fix for DE1231//Juhi
		NSString *value = RPLocalizedString(NO_TASKS_MESSAGE,@"");
//		[Util errorAlert:status errorMessage:value];
        [G2Util errorAlert:@"" errorMessage:value];//Fix for DE1231//Juhi
	}
	else if (tasksForProjects != nil && [tasksForProjects count] > 0) {
		
		taskViewController=[[G2TaskViewController alloc]init];
		
		[taskViewController setTaskArr:tasksForProjects];
		[taskViewController.taskTable reloadData];
		[taskViewController setSubTaskMode:NO];
		[taskViewController setProjectIdentity:[timeEntryObject projectIdentity]];
		[taskViewController setClientProjectTaskDelegate:self];
		
		NSString *taskId = [timeEntryObject.taskObj taskIdentity];
		//NSString *parentId = [timeEntryObject.taskObj parentTaskId];
		
		[taskViewController setSelectedTaskEntityId:taskId];
		//[taskViewController setParentEntityId:parentId];
		[self.navigationController pushViewController:taskViewController animated:YES];
	}
	[[[UIApplication sharedApplication]delegate] performSelector:@selector(stopProgression)];
}

/*
 *This method updates the task selected from taskviewControllers to entryobject and table row.
 */
//-(void)updateSelectedTask : (NSString *)taskName : (NSString *)taskIdentity {
-(void)updateSelectedTask : (NSString *)taskName : (NSMutableDictionary *)taskDict {
	
	//DLog(@"updateSelectedTask :: %@ :: %@",taskName, taskDict);
	if (taskName != nil && taskDict != nil && ![taskName isKindOfClass:[NSNull class]] &&
		![taskDict isKindOfClass:[NSNull class]]) {
		//DLog(@"selected index :: %@",selectedIndex);
		if (selectedIndex.row == TASK) {
			//DLog(@"row equal to task :: %d",selectedIndex.row);
			NSMutableDictionary *fieldDetails = [firstSectionfieldArr objectAtIndex:selectedIndex.row];
			[fieldDetails setObject:taskName forKey:@"fieldValue"];
			//[timeEntryObject setTaskName:taskName];
			//[timeEntryObject setTaskIdentity:taskIdentity];
			NSString *taskIdentity = [taskDict objectForKey:@"identity"];
			NSString *parentIdentity = [taskDict objectForKey:@"parentTaskIdentity"];
			
			[timeEntryObject.taskObj setTaskName:taskName];
			[timeEntryObject.taskObj setTaskIdentity:taskIdentity];
			[timeEntryObject.taskObj setParentTaskId:parentIdentity];
			
			[self updateFieldAtIndexWithSelectedValue:selectedIndex :taskName];
			//selectedName = taskName;
			//DLog(@"taskName %@",taskName);
			//[selectedName setString:taskName];
			//NSArray *indexPathsArray = [NSArray arrayWithObject:selectedIndex];
			//[clientProjectTaskTable reloadRowsAtIndexPaths:
			// indexPathsArray withRowAnimation:UITableViewRowAnimationNone];
		}
	}
}

/*
 * This method is used to reset task selection on project change.
 */

-(void)enableTaskSelection {
	NSIndexPath *taskIndexPath  = [NSIndexPath indexPathForRow:1 inSection:0];
	G2TimeEntryCellView *entryCell = (G2TimeEntryCellView *)[clientProjectTaskTable cellForRowAtIndexPath:taskIndexPath];
	NSMutableDictionary *fieldDetails = [firstSectionfieldArr objectAtIndex:taskIndexPath.row];
	NSString *fieldName = [fieldDetails objectForKey:@"fieldName"];
	if ([fieldName isEqualToString:RPLocalizedString(Task,@"")]) {
		//if ([timeEntryObject.taskObj taskName] != nil && ![[timeEntryObject.taskObj taskName] isEqualToString:@""]) {
		//	[fieldDetails setObject:[timeEntryObject.taskObj taskName] forKey:@"fieldValue"];
		//	[entryCell.fieldButton setTitle:[timeEntryObject.taskObj taskName] forState:UIControlStateNormal];
		//}
		//else {
			[fieldDetails setObject:SelectString forKey:@"fieldValue"];
			[entryCell.fieldButton setTitle:RPLocalizedString(SelectString, SelectString)  forState:UIControlStateNormal];
		//}
		[entryCell setUserInteractionEnabled:YES];
		[entryCell.fieldButton setEnabled:YES];
		[entryCell.fieldName setTextColor:RepliconStandardBlackColor];
		[entryCell.fieldButton setTitleColor:FieldButtonColor forState:UIControlStateNormal];
		//[timeEntryObject setTaskName:nil];
		//[timeEntryObject setTaskIdentity:nil];
	}
}

-(void)disableTaskSelection {
	
	NSIndexPath *taskIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
	
	G2TimeEntryCellView *entryCell = (G2TimeEntryCellView *)[clientProjectTaskTable cellForRowAtIndexPath:taskIndexPath];
	NSMutableDictionary *fieldDetails = [firstSectionfieldArr objectAtIndex:taskIndexPath.row];
	NSString *fieldName = [fieldDetails objectForKey:@"fieldName"];
	if ([fieldName isEqualToString:RPLocalizedString(Task,@"")]) {
		//if ([timeEntryObject.taskObj taskName] != nil && ![[timeEntryObject.taskObj taskName] isEqualToString:@""]) {
		//	[fieldDetails setObject:[timeEntryObject.taskObj taskName] forKey:@"fieldValue"];
		//	[entryCell.fieldButton setTitle:[timeEntryObject.taskObj taskName] forState:UIControlStateNormal];
		//}
		//else {
			[fieldDetails setObject:NoTaskString forKey:@"fieldValue"];
			[entryCell.fieldButton setTitle:RPLocalizedString(NoTaskString, NoTaskString)  forState:UIControlStateNormal];
		//}

		[entryCell setUserInteractionEnabled:NO];
		[entryCell.fieldButton setEnabled:NO];
		[entryCell.fieldName setTextColor:RepliconStandardGrayColor];
		[entryCell.fieldButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
		
		[timeEntryObject.taskObj setTaskName:nil];
		[timeEntryObject.taskObj setTaskIdentity:nil];
		[timeEntryObject.taskObj setParentTaskId:nil];
	}
}

#pragma mark -
#pragma mark Table view delegateMethods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//if (indexPath.row == CLIENT_PROJECT) {
		[rightButton1 setEnabled:YES];
		[self handleButtonClicks:indexPath];
	//}
}

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
    self.clientProjectTaskTable=nil;
    self.customPicker=nil;
    self.taskViewController=nil;
    self.headerView=nil;
    self.keyboardToolbar=nil;
}





@end
