    //
//  TaskViewController.m
//  Replicon
//
//  Created by Hepciba on 4/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2TaskViewController.h"
#import "G2ViewUtil.h"
#import "G2TimeEntryViewController.h"
#import "RepliconAppDelegate.h"

@implementation G2TaskViewController
@synthesize taskTable;
@synthesize taskArr;
@synthesize clientProjectTaskDelegate;
@synthesize parentTaskIdentity;
@synthesize projectIdentity;
@synthesize subTaskMode;
@synthesize selectedTaskEntityId;
@synthesize parentEntityId;
@synthesize parentTaskController;
@synthesize  previousSelectedIndexPath;
@synthesize supportDataModel;
@synthesize subTaskViewController;

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

-(id)init {
	self = [super init];
	if (self) {
		
		if (supportDataModel == nil) {
            G2SupportDataModel *tempSupportDataModel=[[G2SupportDataModel alloc] init];
			self.supportDataModel = tempSupportDataModel;
           
		}
	}
	return self;
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	[self.view setBackgroundColor:NewExpenseSheetBackgroundColor];
	if (taskTable==nil) {
		//taskTable=[[UITableView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width,150.0) style:UITableViewStylePlain];
		UITableView *temptaskTable=[[UITableView alloc]initWithFrame:TaskTableFrame style:UITableViewStylePlain];
        self.taskTable=temptaskTable;
       
	}
	
	[taskTable setDelegate:self];
	[taskTable setDataSource:self];
	[taskTable setScrollEnabled:YES];
	[self.taskTable setBackgroundColor:NewExpenseSheetBackgroundColor];
    self.taskTable.backgroundView=nil;
	[self.view addSubview:taskTable];
	
	//Adding footer view to enable long scrolling the tasks.
	UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
	[taskTable setTableFooterView:footerView];
	

	//UIBarButtonItem *leftButton = nil;
	if (!subTaskMode) {
		//leftButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
		//[self.navigationItem setLeftBarButtonItem:leftButton animated:NO];
		
		//modifying for DE2524
		[self.navigationItem setHidesBackButton:YES];
	}
	
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
	[self.navigationItem setRightBarButtonItem:rightButton animated:NO];
	[rightButton setEnabled:YES];
	
	//[self.navigationItem setTitle:RPLocalizedString(@"Task",@"")];
	
	[G2ViewUtil setToolbarLabel: self withText: RPLocalizedString(TaskViewTitle, TaskViewTitle)];
	
}

- (void)viewWillDisappear:(BOOL)animated {
	/*
	if (previousSelectedIndexPath != nil && [previousSelectedIndexPath isKindOfClass:[NSIndexPath class]]) {
		[(TaskViewCell *)[taskTable cellForRowAtIndexPath:previousSelectedIndexPath] deselectTaskRadioButton];
		//previousSelectedIndexPath = nil;
	}*/
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[taskTable reloadData];
	
	//commented below block to hide note for first time users.
	/*
	NSNumber *taskFirsTimeViewed = [[NSUserDefaults standardUserDefaults] objectForKey:TASK_FIRST_TIME_VIEWED];
	if (taskFirsTimeViewed == nil) {
	
		TaskSelectionMessageView *messageView = [[TaskSelectionMessageView alloc]initWithFrame:
												 CGRectMake(15, 250, 290, 130)];
		NSString *titleString = [NSString stringWithFormat:@"%@\n   %@",
								 @"Tap task name to select the task.",@"Tap arrow to view sub-tasks."];
		[messageView showTransparentAlert:titleString message:TASK_VIEW_MESSAGE];
		[self.view addSubview:messageView];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:TASK_FIRST_TIME_VIEWED];
	}
	 */
}

-(void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if (previousSelectedIndexPath !=nil) {
		[self performSelector:@selector(animateCellWhichIsSelected)];
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (taskArr != nil && [taskArr count] > 0) {
		return [taskArr count];
	}
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
	cell = (G2TaskViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	cell = [[G2TaskViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
	
	NSString *fieldName = [[taskArr objectAtIndex:indexPath.row] objectForKey:@"name"];
	BOOL addFolder = [[[taskArr objectAtIndex:indexPath.row] objectForKey:@"childTasksExists"] boolValue];
	BOOL closedStatus = [[[taskArr objectAtIndex:indexPath.row] objectForKey:@"closedStatus"] boolValue];
	BOOL timeEntryAllowed = [[[taskArr objectAtIndex:indexPath.row] objectForKey:@"timeEntryAllowed"] boolValue];
	BOOL assignedToUser = [[[taskArr objectAtIndex:indexPath.row] objectForKey:@"assignedToUser"] boolValue];
	
    [cell addFieldsForTaskViewController:indexPath.row text:fieldName isAddFolder:addFolder isShowNoTasksText:NO isTimeEntryAllowed:timeEntryAllowed isassignedToUser:assignedToUser];
    
    
	
	
	if (addFolder) {
		
		[cell.navigationButton addTarget:self action:@selector(hanldleTaskNavigation:) 
						forControlEvents: UIControlEventTouchUpInside];
		[cell.disclosureButton addTarget:self action:@selector(hanldleTaskNavigation:) 
						forControlEvents: UIControlEventTouchUpInside];
	}
	else {
		//[cell setAccessoryType:UITableViewCellAccessoryNone];
	}

	if (closedStatus || !timeEntryAllowed || !assignedToUser) {
		
		[cell.fieldName setTextColor:[UIColor grayColor]];
		[cell.radioButton setHidden:YES];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		//[cell setUserInteractionEnabled:NO];
		[cell.fieldName setTextColor:[UIColor grayColor]];
		[cell.fieldName setUserInteractionEnabled:NO];//US4065//Juhi
		[cell addSelectRestrictButton];
	}
	else {
        //US4065//Juhi
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        [cell.fieldName setUserInteractionEnabled:YES];
		[cell setUserInteractionEnabled:YES];
	}
		
	   NSString *fieldNameId = [[taskArr objectAtIndex:indexPath.row] objectForKey:@"identity"];
	   NSString *fieldParentId = [[taskArr objectAtIndex:indexPath.row] objectForKey:@"parentTaskIdentity"];   
	if (parentEntityId != nil) {
		if([selectedTaskEntityId isEqualToString:fieldNameId] && [parentEntityId isEqualToString:fieldParentId]) {
			[cell selectTaskRadioButton];
			self.previousSelectedIndexPath = indexPath;
			
		}
	} else {
		if([selectedTaskEntityId isEqualToString:fieldNameId]) {
			[cell selectTaskRadioButton];
			if (previousSelectedIndexPath == nil) {
				self.previousSelectedIndexPath = indexPath;
				
			}
		}
	}

	//[cell.fieldButton addTarget:self action:@selector(handleButtonClicks:) forControlEvents:UIControlEventTouchUpInside];
	[cell.radioButton addTarget:self action:@selector(handleButtonClicks:) forControlEvents:UIControlEventTouchUpInside];
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return nil;
}

#pragma mark -
#pragma mark Table view delegateMethods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	G2TaskViewCell *taskCell = (G2TaskViewCell *)[taskTable cellForRowAtIndexPath:indexPath];
	
	if ([taskCell.fieldName isUserInteractionEnabled]) {
		NSDictionary *fieldDetails = [taskArr objectAtIndex:indexPath.row];
        BOOL childsExists = [[fieldDetails objectForKey:@"childTasksExists"] boolValue];
        if (childsExists) {
            [self hanldleTaskNavigation:indexPath];
        }
        else
        {
            [self handleButtonClicks:indexPath];
        }
	}
	else {
		[self unHighlightTableRow:indexPath];
	}
    
    
}



#pragma mark general Methods

-(void)hanldleTaskNavigation:(id)sender {
	
	if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)	{
		
		#ifdef PHASE1_US2152
			[G2Util showOfflineAlert];
			return;
		#endif
	}
	
	NSInteger selectedRow=0 ;
	if (sender != nil && [sender isKindOfClass:[NSIndexPath class]]) {
		NSIndexPath *indexPath = (NSIndexPath *)sender;
		selectedRow = indexPath.row;
	}
	else if (sender != nil && [sender isKindOfClass:[UIButton class]]) {
		selectedRow = [sender tag];
	}
	NSIndexPath *selectedRowIndexPath = [NSIndexPath indexPathForRow:selectedRow inSection:0];
	
	
	if (previousSelectedIndexPath != nil) {
		[(G2TaskViewCell *)[taskTable cellForRowAtIndexPath:previousSelectedIndexPath] deselectTaskRadioButton];
		[self unHighlightTableRow:previousSelectedIndexPath];
	}
	
	self.previousSelectedIndexPath = selectedRowIndexPath;
	
	
	[self highlightTableRow:selectedRowIndexPath];
	
	NSDictionary *fieldDetails = [taskArr objectAtIndex:selectedRowIndexPath.row];
	BOOL childsExists = [[fieldDetails objectForKey:@"childTasksExists"] boolValue];
	
	NSString *selectedTaskIdentity = [fieldDetails objectForKey:@"identity"];
	if (childsExists) {
        //DE11732//JUHI
		//check if there are any child tasks for task in db.
//		NSMutableArray *subTasksArray = [supportDataModel getTasksForProjectWithParentTask:
//																		  projectIdentity : selectedTaskIdentity];
//		if (subTasksArray != nil) {
//			
//			//if (subTaskViewController == nil) {
//				TaskViewController *tempsubTaskViewController =[[TaskViewController alloc]init];
//            self.subTaskViewController=tempsubTaskViewController;
//
//			//}
//			[subTaskViewController setSubTaskMode:YES];
//			[subTaskViewController setTaskArr:subTasksArray];
//			[subTaskViewController setProjectIdentity:projectIdentity];
//			[subTaskViewController setSelectedTaskEntityId:selectedTaskEntityId];
//			[subTaskViewController setParentEntityId:parentEntityId];
//			[subTaskViewController setClientProjectTaskDelegate:clientProjectTaskDelegate];
//			[self.navigationController pushViewController:subTaskViewController animated:YES];
//
//		}
//		else if ([[NetworkMonitor sharedInstance] networkAvailable]) {
			[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
			[[G2RepliconServiceManager timesheetService] sendRequestToFetchSubTasksForParentTask: selectedTaskIdentity : projectIdentity];
			[[NSNotificationCenter defaultCenter]
			 addObserver:self selector:@selector(showSubTasks) name:SUB_TASKS_RECEIVED_NOTIFICATION object:nil];
//		}//DE11732//JUHI
	}
}

-(void)showSubTasks {
	
	NSDictionary *fieldDetails = [taskArr objectAtIndex:previousSelectedIndexPath.row];
	NSString *selectedTaskIdentity = [fieldDetails objectForKey:@"identity"];
	NSMutableArray *subTasksArray = [supportDataModel getTasksForProjectWithParentTask:
																	  projectIdentity :selectedTaskIdentity];
	if (subTasksArray != nil) {
		
		//if (subTaskViewController == nil) {
			G2TaskViewController *tempsubTaskViewController=[[G2TaskViewController alloc]init];
        self.subTaskViewController=tempsubTaskViewController;
       
		//}
		[subTaskViewController setSubTaskMode:YES];
		[subTaskViewController setParentTaskController:self];
		[subTaskViewController setTaskArr:subTasksArray];
		[subTaskViewController setProjectIdentity:projectIdentity];
		[subTaskViewController setSelectedTaskEntityId:selectedTaskEntityId];
		[subTaskViewController setParentEntityId:parentEntityId];
		[subTaskViewController setClientProjectTaskDelegate:clientProjectTaskDelegate];
		[self.navigationController pushViewController:subTaskViewController animated:NO];//DE11732//JUHI
	}
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:SUB_TASKS_RECEIVED_NOTIFICATION object:nil];//DE11732//JUHI

	//[self unHighlightTableRow:previousSelectedIndexPath];
	
}

-(void)handleButtonClicks:(id)sender {
	
	NSIndexPath *selectedRowIndexPath = nil;
	
	if (sender != nil && [sender isKindOfClass:[NSIndexPath class]]) {
		selectedRowIndexPath = (NSIndexPath *)sender;
	}
	else if (sender != nil && [sender isKindOfClass:[UIButton class]]) {
		NSInteger selectedRow = [sender tag];
		selectedRowIndexPath = [NSIndexPath indexPathForRow:selectedRow inSection:0];
	}
	 
	//get previous selectedRow and remove checkmark 
	if (previousSelectedIndexPath != nil) {
		[self unHighlightTableRow:previousSelectedIndexPath];
		
		BOOL taskSelected = [(G2TaskViewCell *)[taskTable cellForRowAtIndexPath:previousSelectedIndexPath] taskSelected];
		if (previousSelectedIndexPath.row == selectedRowIndexPath.row && taskSelected) {
			[(G2TaskViewCell *)[taskTable cellForRowAtIndexPath:previousSelectedIndexPath] deselectTaskRadioButton]; 
		}
		else if (previousSelectedIndexPath.row == selectedRowIndexPath.row && !taskSelected) {
			[(G2TaskViewCell *)[taskTable cellForRowAtIndexPath:previousSelectedIndexPath] selectTaskRadioButton];
		}
		else {
			
			[(G2TaskViewCell *)[taskTable cellForRowAtIndexPath:previousSelectedIndexPath] deselectTaskRadioButton]; 
			
			self.previousSelectedIndexPath = selectedRowIndexPath;
			[(G2TaskViewCell *)[taskTable cellForRowAtIndexPath:previousSelectedIndexPath] selectTaskRadioButton];
		}
	}
	else if(previousSelectedIndexPath == nil){
		self.previousSelectedIndexPath = selectedRowIndexPath;
		[(G2TaskViewCell *)[taskTable cellForRowAtIndexPath:previousSelectedIndexPath] selectTaskRadioButton];
	}
	
	[self animateCellWhichIsSelected];
	[self doneAction:nil];
}

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
#pragma mark -
#pragma mark ButtonMethods
-(void)cancelAction:(id)sender{
	[self returnToTimeEntryScreen];
}
-(void)doneAction:(id)sender{
	//update  task name if selected.
	if (previousSelectedIndexPath != nil && clientProjectTaskDelegate != nil) {
		if (![(G2TaskViewCell *)[taskTable cellForRowAtIndexPath:previousSelectedIndexPath]taskSelected]) {
		
			[clientProjectTaskDelegate performSelector:@selector(resetTaskSelection)];
		}
		else {
			NSString *taskName = [[taskArr objectAtIndex:previousSelectedIndexPath.row] objectForKey:@"name"];
			NSString *identity = [[taskArr objectAtIndex:previousSelectedIndexPath.row] objectForKey:@"identity"];
			NSString *parentId = [[taskArr objectAtIndex:previousSelectedIndexPath.row] objectForKey:@"parentTaskIdentity"];
			NSMutableDictionary *idDict = [NSMutableDictionary dictionary];
			
			if (parentId != nil && ![parentId isKindOfClass:[NSNull class]]
				&& ![parentId isEqualToString:NULL_STRING]) {
				[idDict setObject:parentId forKey:@"parentTaskIdentity"];
			}else {
				[idDict setObject:@"" forKey:@"parentTaskIdentity"];
			}
			[idDict setObject:identity forKey:@"identity"];
			
			
			[clientProjectTaskDelegate performSelector:@selector(updateSelectedTask::) withObject:taskName withObject:idDict];
		}

		[self performSelector:@selector(returnToTimeEntryScreen) withObject:nil afterDelay:0.1];
	}
}
				 
-(void)returnToTimeEntryScreen {
	
    if ([clientProjectTaskDelegate isKindOfClass:[G2TimeEntryViewController class]]) 
    {
        G2TimeEntryViewController *timeEntryCtrl=(G2TimeEntryViewController *)clientProjectTaskDelegate;
        timeEntryCtrl.isFromDoneClicked=YES;
    }
    
	[self.navigationController popToViewController:clientProjectTaskDelegate animated:YES];
	[clientProjectTaskDelegate performSelector:@selector(animateCellWhichIsSelected)];
}

-(void)animateCellWhichIsSelected
{
	[self highlightTableRow:previousSelectedIndexPath];
	//[self performSelector:@selector(unHighlightTableRow:) withObject:previousSelectedIndexPath afterDelay:0.3];	//DE2949 FadeOut is slow
    [self performSelector:@selector(unHighlightTableRow:) withObject:previousSelectedIndexPath afterDelay:0.0];	
}

-(void)highlightTableRow:(NSIndexPath *)_indexPath {
	
	[taskTable selectRowAtIndexPath:_indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
	
	G2TaskViewCell *tableCell  = (G2TaskViewCell *)[taskTable cellForRowAtIndexPath:_indexPath];
	if (tableCell.fieldName !=nil) {
		[tableCell.fieldName setTextColor:iosStandaredWhiteColor];
	}
	//[self performSelector:@selector(unHighlightTableRow:) withObject:_indexPath afterDelay:0.3];
}
-(void)unHighlightTableRow:(NSIndexPath *)_indexPath {
	
	[taskTable deselectRowAtIndexPath:_indexPath animated:YES];
	
	G2TaskViewCell *tableCell  = (G2TaskViewCell *)[taskTable cellForRowAtIndexPath:_indexPath];
	if (tableCell.fieldName !=nil) {
		BOOL closedStatus = [[[taskArr objectAtIndex:_indexPath.row] objectForKey:@"closedStatus"] boolValue];
		BOOL timeEntryAllowed = [[[taskArr objectAtIndex:_indexPath.row] objectForKey:@"timeEntryAllowed"] boolValue];
        BOOL assignedToUser = [[[taskArr objectAtIndex:_indexPath.row] objectForKey:@"assignedToUser"] boolValue];
		if (closedStatus || !timeEntryAllowed || !assignedToUser) {
			[tableCell.fieldName setTextColor:RepliconStandardGrayColor];
		}
		else {
			[tableCell.fieldName setTextColor:RepliconStandardBlackColor];
		}
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.taskTable=nil;
    self.subTaskViewController=nil;
}





@end
