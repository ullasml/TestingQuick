//
//  RootTabBarController.m
//  Replicon
//
//  Created by Devi Malladi on 3/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2RootTabBarController.h"
#import"G2Constants.h"



#import "RepliconAppDelegate.h"

@interface G2RootTabBarController()
-(void) selectTimeSheetTabbar;
@end


@implementation G2RootTabBarController
@synthesize  moreViewController;
@synthesize moreNavController;
@synthesize listOfExpenseSheetsViewController;
@synthesize listOfExpenseSheetsNavController;
@synthesize approvalsNavController;
@synthesize approvalsMainViewController;
@synthesize listOfTimeSheetsViewController;
@synthesize listOfTimeSheetsNavController;
@synthesize punchClockViewCtrl;
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

- (id) init
{
	self = [super init];
	if (self != nil) {
        
        
        RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
        
		
		G2ListOfExpenseSheetsViewController *templistOfExpenseSheetsViewController = [[G2ListOfExpenseSheetsViewController alloc] init];
        self.listOfExpenseSheetsViewController=templistOfExpenseSheetsViewController;
        
		[listOfExpenseSheetsViewController setTitle:RPLocalizedString( ExpenseTabbarTitle,ExpenseTabbarTitle)];
		G2ExpensesNavigationController *templistOfExpenseSheetsNavController=[[G2ExpensesNavigationController alloc]initWithRootViewController:listOfExpenseSheetsViewController];
        self.listOfExpenseSheetsNavController=templistOfExpenseSheetsNavController;
        
        if (appDelegate.isLockedTimeSheet) {
            [listOfExpenseSheetsNavController.tabBarItem setImage:[G2Util thumbnailImage:LockedExpenseTabbarImageUp]];
        }
        else
        {
            [listOfExpenseSheetsNavController.tabBarItem setImage:[G2Util thumbnailImage:ExpenseTabbarImageUp]];
        }
		
		//[listOfExpenseSheetsNavController.navigationBar setTintColor:RepliconStandardNavBarTintColor];
		
		
		
      
		if (appDelegate.hasApprovalPermissions) {
          
             G2ApprovalsMainViewController *tempapprovalsMainViewController = [[G2ApprovalsMainViewController alloc] init];
            self.approvalsMainViewController=tempapprovalsMainViewController;
            
            G2ApprovalsNavigationController *tempapprovalsNavController=[[G2ApprovalsNavigationController alloc]initWithRootViewController:approvalsMainViewController];
            self.approvalsNavController=tempapprovalsNavController;
           
             [approvalsNavController.tabBarItem setTitle:RPLocalizedString( ApprovalsTabbarTitle,ApprovalsTabbarTitle)];
            [approvalsNavController.tabBarItem setImage:[G2Util thumbnailImage:G2ApprovalsImageUp]];           
           // [approvalsNavController.navigationBar setTintColor:RepliconStandardNavBarTintColor];
            
            
            int badgeValue=[[[NSUserDefaults standardUserDefaults] objectForKey:@"NumberOfTimesheetsPendingApproval"] intValue];
            if (badgeValue>0) 
            {
                approvalsNavController.tabBarItem.badgeValue=[NSString stringWithFormat:@"%d", badgeValue];
            }
            else
            {
                approvalsNavController.tabBarItem.badgeValue=nil;
            }
            
            

        }
		

        
        
        G2MoreViewController *tempMoreViewCtrl = [[G2MoreViewController alloc] init];
        [tempMoreViewCtrl setTitle:RPLocalizedString( MoreTabbarTitle,MoreTabbarTitle)];
        self.moreViewController=tempMoreViewCtrl;
        
        G2SettingsNavigationController *tempMoreNavController=[[G2SettingsNavigationController alloc]initWithRootViewController:self.moreViewController];
        self.moreNavController=tempMoreNavController;
       
        if (appDelegate.isLockedTimeSheet) {
            [self.moreViewController.tabBarItem setImage:[G2Util thumbnailImage:G2LockedMoreTabbarImageUp]];
        }
        else
        {
            [self.moreViewController.tabBarItem setImage:[G2Util thumbnailImage:G2MoreTabbarImageUp]];
        }

		
		
		G2ListOfTimeSheetsViewController *templistOfTimeSheetsViewController=[[G2ListOfTimeSheetsViewController alloc]init];
		self.listOfTimeSheetsViewController=templistOfTimeSheetsViewController;
        
		
		G2TimesheetNavigationController *templistOfTimeSheetsNavController=[[G2TimesheetNavigationController alloc]initWithRootViewController:listOfTimeSheetsViewController];
		self.listOfTimeSheetsNavController=templistOfTimeSheetsNavController;
        
        
		[listOfTimeSheetsNavController.tabBarItem setTitle:RPLocalizedString( TimeSheetsTabbarTitle,TimeSheetsTabbarTitle)];
        
        if (appDelegate.isLockedTimeSheet) {
           [listOfTimeSheetsNavController.tabBarItem setImage:[G2Util thumbnailImage:G2LockedTimeSheetTabbarImageUp]];
        }
        else
        {
            [listOfTimeSheetsNavController.tabBarItem setImage:[G2Util thumbnailImage:G2TimeSheetTabbarImageUp]];
        }
		
		
		
		[self setDelegate:self];
		
		
		NSMutableArray *listOfTabs = [NSMutableArray array];
		
		NSArray *modulesArray = [[NSUserDefaults standardUserDefaults] objectForKey: @"TabBarModulesArray"];
		for (NSString *module in modulesArray) {
            
           
            
            if ([module isEqualToString: @"PunchClock_Module"]) {
                if (appDelegate.appDelegatePunchCtrl)
                {
                    
                    appDelegate.appDelegatePunchCtrl=nil;
                }
                 G2PunchClockViewController *temppunchClockViewCtrl=[[G2PunchClockViewController alloc] initWithNibName:@"G2PunchClockViewController" bundle:nil];
                self.punchClockViewCtrl=temppunchClockViewCtrl;
                appDelegate.appDelegatePunchCtrl=self.punchClockViewCtrl;
                
                [self.punchClockViewCtrl setTitle:RPLocalizedString( PunchClockTabbarTitle,PunchClockTabbarTitle)];
                [self.punchClockViewCtrl.tabBarItem setImage:[G2Util thumbnailImage:PUNCHCLOCK_TABBAR_IMAGE]];
				[listOfTabs addObject: self.punchClockViewCtrl];

			}
            
			if ([module isEqualToString: @"Timesheets_Module"]) {
				[listOfTabs addObject: listOfTimeSheetsNavController];
			}
			if ([module isEqualToString: @"Expenses_Module"]) {
				[listOfTabs addObject: listOfExpenseSheetsNavController];
			}
            if ([module isEqualToString: @"Approvals_Module"]) {
				[listOfTabs addObject: approvalsNavController];
			}
			if ([module isEqualToString: @"More_Settings"]) {
				[listOfTabs addObject: moreNavController];
			}
		}
		[self setViewControllers: listOfTabs];
		
		
		
		[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SelectedTab" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(tabChangeNotification:) name:@"SelectedTab" object:nil];

	}
	return self;
}

-(void)tabChangeNotification:(NSNotification *)_notify{
	[self setSelectedIndex:[[_notify object]intValue]];	
}

/*-(BOOL)userPreferenceSettings:(NSString *)_preference{
	NSMutableArray *preferences = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserPreferenceSettings"];
	if (_preference != nil) {
		if ([preferences containsObject:_preference]) {
			return YES;
		}
	}
	return NO;
}*/
#pragma mark -
#pragma mark UITabbar Delegates
#pragma mark -
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
	RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    appDelegate.selectedTab=tabBarController.selectedIndex;

    
    
    
    for (int i=0; i<[self.viewControllers count]; i++) 
    {
        if ([[self.viewControllers objectAtIndex:i] isKindOfClass:[G2ApprovalsNavigationController class] ]) {
            G2ApprovalsNavigationController *approvalNavCtrl=[self.viewControllers objectAtIndex:i];
            int badgeValue=[[[NSUserDefaults standardUserDefaults] objectForKey:@"NumberOfTimesheetsPendingApproval"] intValue];
            if (badgeValue>0) 
            {
                 approvalNavCtrl.tabBarItem.badgeValue=[NSString stringWithFormat:@"%d", badgeValue];
            }
            else
            {
                approvalNavCtrl.tabBarItem.badgeValue=nil;
            }
             
            
            
        }
    }
	
    
	if ([[tabBarController selectedViewController] isKindOfClass: [UINavigationController class]]) {
		UINavigationController *selectedNavController = (UINavigationController *)[tabBarController selectedViewController];
        
    if([selectedNavController isKindOfClass:[G2SettingsNavigationController class]]){
			DLog(@"root tabbar controller---------SettingsNavigationController");
            [selectedNavController popToRootViewControllerAnimated:NO];
    }  
    if([selectedNavController isKindOfClass:[G2TimesheetNavigationController class]]){
			DLog(@"root tabbar controller---------TimesheetNavigationController");
            [selectedNavController popToRootViewControllerAnimated:NO];
    } 
    if([selectedNavController isKindOfClass:[G2ExpensesNavigationController class]]){
			DLog(@"root tabbar controller---------ExpensesNavigationController");
            [selectedNavController popToRootViewControllerAnimated:NO];
    }     
        
        
    if ([[selectedNavController visibleViewController] isKindOfClass: [G2ListOfTimeSheetsViewController class]]||[[selectedNavController visibleViewController] isKindOfClass: [G2ListOfTimeEntriesViewController class]]) {
            
           
            
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"allTimesheetRequestsServed" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver: self 
                                                     selector: @selector(selectTimeSheetTabbar) 
                                                         name: @"allTimesheetRequestsServed"
                                                       object: nil];
           
			[[G2RepliconServiceManager timesheetService] fetchTimeSheetData: nil];
		}//DE1848: Exp List Page: Expenses not downloaded if first access from tab bar 
		else if([[selectedNavController visibleViewController] isKindOfClass: [G2ListOfExpenseSheetsViewController class]]||[[selectedNavController visibleViewController] isKindOfClass: [G2ListOfExpenseEntriesViewController class]])	{
			//ExpensesModel *_esModel = [[ExpensesModel alloc] init];
			//NSArray *_expenseSheets = [_esModel getExpenseSheetsFromDataBase];
//			if ((_expenseSheets == nil || [_expenseSheets count] == 0) && [NetworkMonitor isNetworkAvailableForListener:self] == YES) {
            
    [NSThread detachNewThreadSelector: @selector(showProgression) toTarget:self withObject:nil];
					
				[[G2RepliconServiceManager expensesService] fetchExpenseSheetData];
		//	}
			
		}else if([[selectedNavController visibleViewController] isKindOfClass:[G2MoreViewController class]]){
			DLog(@"root tabbar controller---------more view controller");
		} 
        else if([[selectedNavController visibleViewController] isKindOfClass:[G2ApprovalsMainViewController class]]){
			DLog(@"root tabbar controller---------ApprovalsMainViewController");
            
		} 
        
        else if([selectedNavController isKindOfClass:[G2ApprovalsNavigationController class]]){
			DLog(@"root tabbar controller---------ApprovalsNavigationController");
            [selectedNavController popToRootViewControllerAnimated:NO];
		} 
        else {
			//Add when new tabs added
            
            if (appDelegate.isLockedTimeSheet) {
                
                
                
                
                [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];

                [[self navigationController] popToRootViewControllerAnimated:YES];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:@"allTimesheetRequestsServed" object:nil];
                [[NSNotificationCenter defaultCenter] addObserver: self 
                                                         selector: @selector(selectTimeSheetTabbar) 
                                                             name: @"allTimesheetRequestsServed"
                                                           object: nil];

                
                if (appDelegate.selectedTab==1) {
                    [[G2RepliconServiceManager timesheetService] fetchTimeSheetData: nil];
                }
                else if (appDelegate.selectedTab==2) {
                    [[G2RepliconServiceManager expensesService] fetchExpenseSheetData];
                }
            }
		}	
	}
}
-(void) selectTimeSheetTabbar	{
	[[[UIApplication sharedApplication] delegate] performSelector: @selector(stopProgression)];
    [self.listOfTimeSheetsViewController viewWillAppear:FALSE];
	[[NSNotificationCenter defaultCenter] removeObserver: self name: @"allTimesheetRequestsServed" object: nil];

	
	NSArray *modulesArray = [[NSUserDefaults standardUserDefaults] objectForKey: @"TabBarModulesArray"];
	int timesheetTabIndex=0;
	for (int i=0; i < [modulesArray count]; ++i) {
		if ([[modulesArray objectAtIndex: i] isEqualToString: @"Timesheets_Module"]) {
			timesheetTabIndex = i;
		}
	}
	if ([self checkforenabledandrequiredudfs]) {
//		NSString *_msg = @"Custom timesheet fields (UDFs) are currently not supported in the Replicon Mobile app.  Please log in to Replicon through a browser to enter time.";
         NSString *_msg =  RPLocalizedString(@"Custom timesheet level (UDFs) are currently not supported in the Replicon Mobile app.  Please log in to Replicon through a browser to enter time.","");//US4337//Juhi
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message: _msg
														   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView setDelegate:self];
		[alertView show];	
		
        [[[UIApplication sharedApplication]delegate] performSelector:@selector(launchHomeViewController)];
	}
    else
    {
        [[[UIApplication sharedApplication] delegate] performSelector: @selector(flipToTabbarController:) 
                                                           withObject: [NSNumber numberWithInt: timesheetTabIndex]];
    }
		
}

-(BOOL)checkforenabledandrequiredudfs{
	//DLog(@"checkforenabledandrequiredudfs");
	G2PermissionsModel *permissionsModel   = [[G2PermissionsModel alloc] init];
	NSMutableArray *enabledPermissionSet = [permissionsModel getEnabledUserPermissions];
	
	NSDictionary *cellUdfDict = nil;
	NSDictionary *rowUdfDict = nil;
	NSDictionary *entireUdfDict = nil;
	NSMutableArray *udfpermissions = [NSMutableArray array];
	NSMutableArray *permissionSet  = [NSMutableArray array];
	G2TimesheetModel    *timesheetModel = [[G2TimesheetModel alloc]init];
	NSMutableArray *requiredUdfsArray = [timesheetModel getEnabledAndRequiredTimeSheetLevelUDFs];
	
	
	for (NSDictionary *permissionDict in enabledPermissionSet) {
		NSString * permission = [permissionDict objectForKey:@"permissionName"];
		NSString *shortString = nil;
        if (![permission isKindOfClass:[NSNull class] ])
        {
            if ([permission length]-4 > 0) {
                NSRange stringRange = {0, MIN([permission length], [permission length]-4)};
                stringRange = [permission rangeOfComposedCharacterSequencesForRange:stringRange];
                shortString = [permission substringWithRange:stringRange];
                //DLog(@"Short String:HomeViewController %@",shortString);
            }
        }
		
		[udfpermissions addObject:shortString];
	}
	if ([udfpermissions containsObject:TimesheetEntry_CellLevel]) {
		cellUdfDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:TimesheetEntry_CellLevel];
	}
	if ([udfpermissions containsObject:TaskTimesheet_RowLevel]) {
		rowUdfDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:TaskTimesheet_RowLevel];
	}
	if ([udfpermissions containsObject:ReportPeriod_SheetLevel]) {
		entireUdfDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:ReportPeriod_SheetLevel];
	}
	if (cellUdfDict != nil) {
		[permissionSet addObject:cellUdfDict];
	}
	if (rowUdfDict != nil) {
		[permissionSet addObject:rowUdfDict];
	}
	if (entireUdfDict != nil) {
		[permissionSet addObject:entireUdfDict];
	}
	if (permissionSet != nil && [permissionSet count]>0) {//System Level
		if (requiredUdfsArray != nil && [requiredUdfsArray count]) {//User Level
			//User Level
            BOOL isUdfExistFlag=NO;
//            if (cellUdfDict != nil && !isUdfExistFlag) {
//                NSMutableArray *fieldIndexArr=[timesheetModel getEnabledAndRequiredTimeSheetLevelUDFsFieldIndexes:TimesheetEntry_CellLevel];
//                for (int x=0; x<[fieldIndexArr count]; x++) {
//                    NSMutableDictionary *tempDict=[fieldIndexArr objectAtIndex:x];
//                    int fieldIndexOffset=[[tempDict objectForKey:@"fieldIndex"] intValue]+1;
//                    if ([permissionsModel checkUserPermissionWithPermissionName:[NSString stringWithFormat:@"%@UDF%d",TimesheetEntry_CellLevel,fieldIndexOffset]]) {
//                        isUdfExistFlag=YES;
//                        break;
//                    }
//                }
//            }
//            if (rowUdfDict != nil && !isUdfExistFlag) {
//                NSMutableArray *fieldIndexArr=[timesheetModel getEnabledAndRequiredTimeSheetLevelUDFsFieldIndexes:TaskTimesheet_RowLevel];
//                for (int x=0; x<[fieldIndexArr count]; x++) {
//                    NSMutableDictionary *tempDict=[fieldIndexArr objectAtIndex:x];
//                    int fieldIndexOffset=[[tempDict objectForKey:@"fieldIndex"] intValue]+1;
//                    if ([permissionsModel checkUserPermissionWithPermissionName:[NSString stringWithFormat:@"%@UDF%d",TaskTimesheet_RowLevel,fieldIndexOffset]]) {
//                        isUdfExistFlag=YES;
//                        break;
//                    }
//                }
//            }
            if (entireUdfDict != nil && !isUdfExistFlag) {
                NSMutableArray *fieldIndexArr=[timesheetModel getEnabledAndRequiredTimeSheetLevelUDFsFieldIndexes:ReportPeriod_SheetLevel];
                for (int x=0; x<[fieldIndexArr count]; x++) {
                    NSMutableDictionary *tempDict=[fieldIndexArr objectAtIndex:x];
                    int fieldIndexOffset=[[tempDict objectForKey:@"fieldIndex"] intValue]+1;
                    if ([permissionsModel checkUserPermissionWithPermissionName:[NSString stringWithFormat:@"%@UDF%d",ReportPeriod_SheetLevel,fieldIndexOffset]]) {
                        isUdfExistFlag=YES;
                        break;
                    }
                }
            }
            
            
            return isUdfExistFlag;
            
            
			
            
		}else {
            
			return NO;
		}
	}else {
        
		return NO;
	}
    
  
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	//DLog(@"Button Index %d",buttonIndex);
//	[[[UIApplication sharedApplication]delegate] performSelector:@selector(launchHomeViewController)];
	
}

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
#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    DLog(@"RootTabBarController DID RECIEVE didReceiveMemoryWarning: %@", [self view].superview);
    // Release any cached data, images, etc. that aren't in use.
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate.thumbnailCache removeAllObjects];
}

-(void)viewWillDisappear:(BOOL)animated
{
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"allTimesheetRequestsServed" object:nil];
    if (!appDelegate.isLockedTimeSheet)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SelectedTab" object:nil];
    }
    
    
}

-(void)showProgression
{
    @autoreleasepool {
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
    }
    
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
//    self.moreNavController = nil;
    self.moreViewController  = nil;
    self.listOfExpenseSheetsViewController = nil;
    self.listOfExpenseSheetsNavController = nil;
    self.approvalsNavController = nil;
    self.approvalsMainViewController = nil;
    self.listOfTimeSheetsViewController = nil;
    self.listOfTimeSheetsNavController = nil;
    self.punchClockViewCtrl = nil;
}







@end
