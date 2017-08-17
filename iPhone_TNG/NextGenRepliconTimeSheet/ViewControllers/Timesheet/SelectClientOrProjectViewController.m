#import "SelectClientOrProjectViewController.h"
#import "Util.h"
#import "Constants.h"
#import "UISegmentedControlExtension.h"
#import "AppDelegate.h"
#import "SelectProjectOrTaskViewController.h"
#import "TimeEntryViewController.h"
#import "TimesheetMainPageController.h"
#import "TimesheetModel.h"
#import "SVPullToRefresh.h"
#import "ProjectObject.h"
#import "ClientObject.h"
#import "ProgramObject.h"
#import "ExpenseEntryViewController.h"
#import "ExpenseModel.h"
#import "LoginModel.h"
#define kTagFirst 1
#define kTagSecond 2
#define searchBar_Height 44
#define segment_view_section_height 60
#define toolbar_height 40
#define Yoffset 35
#define program_Tag 2
#define client_Tag 1
#define project_Tag 0
#define SEARCH_POLL 0.2
#define NORMAL_SEGMENT_COLOR @"#257abd"
#define SELECTED_SEGMENT_COLOR @"#14466e"
#define TABLEVIEW_HORIZONTAL_PADDING 8.0f

@implementation SelectClientOrProjectViewController
@synthesize segmentedCtrl;
@synthesize searchTextField;
@synthesize mainTableView;
@synthesize listOfItems;
@synthesize delegate;
@synthesize arrayOfCharacters;
@synthesize objectsForCharacters;
@synthesize viewDelegate;
@synthesize searchTimer;
@synthesize selectedTimesheetUri;
@synthesize selectedExpensesheetURI;
@synthesize searchProjectString;
@synthesize isPreFilledSearchString;
@synthesize selectedClientUri;
@synthesize selectedClientName;
@synthesize isTextFieldFirstResponder;
@synthesize isFromAttendance,isProgramAccess;


UIEdgeInsets currentInsets;


#pragma mark -
#pragma mark View Initialisation
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        if (arrayOfCharacters==nil) {
            NSMutableArray *tempArrayOfCharacters=[[NSMutableArray alloc] init];
            self.arrayOfCharacters=tempArrayOfCharacters;

        }
        if (objectsForCharacters==nil) {
            NSMutableDictionary *tempObjectForCharacters=[[NSMutableDictionary alloc] init];
            self.objectsForCharacters=tempObjectForCharacters;

        }

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    if ([viewDelegate isKindOfClass:[TimeEntryViewController class]])
    {
        if (!isFromAttendance)
        {
            TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
            
            NSString *timesheetFormat=[timesheetModel getTimesheetFormatforTimesheetUri:self.selectedTimesheetUri];
            if (timesheetFormat!=nil && ![timesheetFormat isKindOfClass:[NSNull class]])
            {
                if([timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                {
                    SupportDataModel *supportDataModel=[[SupportDataModel alloc]init];
                    NSDictionary *permittedApprovalAcionsDict=[supportDataModel getTimesheetPermittedApprovalActionsDataToDBWithUri:self.selectedTimesheetUri];
                    self.isProgramAccess=[[permittedApprovalAcionsDict objectForKey:@"allowProgramsForStandardGen4"] boolValue];

                }
                else if([timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
                {
                    SupportDataModel *supportDataModel=[[SupportDataModel alloc]init];
                    NSDictionary *permittedApprovalAcionsDict=[supportDataModel getTimesheetPermittedApprovalActionsDataToDBWithUri:self.selectedTimesheetUri];
                    self.isProgramAccess=[[permittedApprovalAcionsDict objectForKey:@"allowProgramsForExtInOutGen4"] boolValue];

                }
                else
                {
                    self.isProgramAccess=[timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProgramAccess" forSheetUri:self.selectedTimesheetUri];
                }
            }


        }
        
    }
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self initializeView];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:TRUE];

    self.isPreFilledSearchString=YES;
    self.searchProjectString=nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:TRUE];

    if (!isPreFilledSearchString)
    {
        self.isPreFilledSearchString=YES;

        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"SearchString"];
        [defaults synchronize];
        [defaults setObject:searchProjectString forKey:@"SearchString"];
        [defaults synchronize];
        if ([searchProjectString isEqualToString:RPLocalizedString(NONE_STRING, @"")])
        {
            searchProjectString=@"";
        }


        SelectProjectOrTaskViewController *selectVC=[[SelectProjectOrTaskViewController alloc]init];
        selectVC.delegate=delegate;
        selectVC .entryDelegate=viewDelegate;

        selectVC.isFromAttendance=isFromAttendance;
        NSString *name=@"";

        selectVC.selectedItem=RPLocalizedString(Client, @"");
        name=self.selectedClientName;
        selectVC.isTaskPermission=TRUE;
        selectVC.isTimeAllowedPermission=FALSE;
        selectVC.selectedClientUri=self.selectedClientUri;



        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:selectVC name:PROJECTS_OR_TASKS_RECEIVED_NOTIFICATION object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:selectVC selector:@selector(refreshViewAfterDataRecieved:)
                                                     name:PROJECTS_OR_TASKS_RECEIVED_NOTIFICATION
                                                   object:nil];
        NSString *timesheetUri=self.selectedTimesheetUri;
        NSString *expenseSheetUri=self.selectedExpensesheetURI;
        if ([viewDelegate isKindOfClass:[TimeEntryViewController class]])
        {
            selectVC.selectedTimesheetUri=timesheetUri;

            if (isFromAttendance)
            {
                [[RepliconServiceManager attendanceService]fetchProjectsBasedOnclientsWithSearchText:searchProjectString withClientUri:selectVC.selectedClientUri andDelegate:self];
            }
            else
            {
                if (isFromAttendance)
                {
                    [[RepliconServiceManager attendanceService]fetchProjectsBasedOnclientsWithSearchText:searchProjectString withClientUri:selectVC.selectedClientUri andDelegate:self];
                }
                else
                {
                    [[RepliconServiceManager timesheetService]fetchProjectsBasedOnclientsForTimesheetUri:timesheetUri withSearchText:searchProjectString withClientUri:selectVC.selectedClientUri andDelegate:self];
                }

            }


        }
        else if ([viewDelegate isKindOfClass:[ExpenseEntryViewController class]])
        {
            selectVC.selectedExpenseUri=expenseSheetUri;

            [[RepliconServiceManager expenseService]fetchProjectsBasedOnclientsForExpenseSheetUri:expenseSheetUri withSearchText:searchProjectString withClientUri:selectVC.selectedClientUri andDelegate:self];

        }

        selectVC.selectedValue=name;

        selectVC.searchProjectString=searchProjectString;
        selectVC.isPreFilledSearchString=YES;

        [self.navigationController pushViewController:selectVC animated:NO];


        self.isPreFilledSearchString=YES;
        self.searchProjectString=nil;

    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];


    if (self.isPreFilledSearchString)
    {
        //Implementation for US8902//JUHI
        if (searchProjectString!=nil && ![searchProjectString isKindOfClass:[NSNull class]] && ![searchProjectString isEqualToString:@"null"] &&
            ![searchProjectString isEqualToString:RPLocalizedString(SELECT_STRING, @"") ] && ![searchProjectString isEqualToString:RPLocalizedString(NONE_STRING, @"") ])
        {
            self.searchTextField.text=searchProjectString;
        }
        else
        {
            searchProjectString = nil;
            self.searchTextField.text=@"";
        }
        self.isTextFieldFirstResponder=NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CLIENTS_PROJECTS_SUMMARY_RECIEVED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(summaryReceived) name:CLIENTS_PROJECTS_SUMMARY_RECIEVED_NOTIFICATION object:nil];

        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults setObject:self.searchTextField.text forKey:@"SearchString"];
        [defaults synchronize];
        [self.mainTableView setBottomContentInsetValue:0.0];

        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
        if ([viewDelegate isKindOfClass:[TimeEntryViewController class]])
        {
            if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
            {
                [Util showOfflineAlert];
                return;
            }
            if (isFromAttendance)
            {
                [[RepliconServiceManager attendanceService]fetchFirstClientsAndProjectsWithClientSearchText:selectedClientName withProjectSearchText:searchProjectString  andDelegate:self];
            }
            else
            {
                if (isFromAttendance)
                {
                    [[RepliconServiceManager attendanceService]fetchFirstClientsAndProjectsWithClientSearchText:selectedClientName withProjectSearchText:searchProjectString andDelegate:self];
                }
                else
                {
                    NSString *timesheetUri=self.selectedTimesheetUri;
                    //MOBI-746
                    if (isProgramAccess)
                    {
                        [[RepliconServiceManager timesheetService]fetchFirstProgramsAndProjectsForTimesheetUri:timesheetUri withProgramSearchText:selectedClientName withProjectSearchText:searchProjectString andDelegate:self];
                    }
                    else
                    {
                        [[RepliconServiceManager timesheetService]fetchFirstClientsAndProjectsForTimesheetUri:timesheetUri withClientSearchText:selectedClientName withProjectSearchText:searchProjectString andDelegate:self];
                    }
                }

            }
        }
        else if ([viewDelegate isKindOfClass:[ExpenseEntryViewController class]])
        {
            if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
            {
                [Util showOfflineAlert];
                return;
            }

            [[RepliconServiceManager expenseService]fetchFirstClientsAndProjectsForExpenseSheetUri:self.selectedExpensesheetURI withClientSearchText:selectedClientName withProjectSearchText:searchProjectString andDelegate:self];
        }
    }
}

-(void)initializeView
{

    UITextField *tempsearchBarTextField=[[UITextField alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, searchBar_Height)];
    self.searchTextField=tempsearchBarTextField;

    self.searchTextField.clearButtonMode=YES;
    [self.view addSubview:self.searchTextField];

    float xPadding=10.0;
    float paddingFromSearchIconToPlaceholder=10.0;
    UIImage *searchIconImage=[UIImage imageNamed:@"icon_search_magnifying_glass"];
    UIImageView *searchIconImageView=[[UIImageView alloc]initWithFrame:CGRectMake(xPadding, 16, searchIconImage.size.width, searchIconImage.size.height)];
    [searchIconImageView setImage:searchIconImage];
    [searchIconImageView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:searchIconImageView];

    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, xPadding+searchIconImage.size.width+paddingFromSearchIconToPlaceholder, 20)];
    searchTextField.leftView = paddingView;
    searchTextField.leftViewMode = UITextFieldViewModeAlways;


    [searchTextField setAccessibilityLabel:@"search_textfield_clients_projects_tasks"];

    [searchTextField setBackgroundColor:[UIColor clearColor]];
    searchTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    searchTextField.contentHorizontalAlignment = UIControlContentVerticalAlignmentCenter;
    searchTextField.placeholder = RPLocalizedString(SEARCHBAR_PLACEHOLDER_PROJECT, @"");
    [searchTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [searchTextField setDelegate:self];
    [searchTextField setReturnKeyType:UIReturnKeyDone];
    [searchTextField setEnablesReturnKeyAutomatically:NO];

    [searchTextField setFont:[UIFont fontWithName:RepliconFontFamilyLight size:16.0]];

    float xOffset=5.0f;
    float yOffset=8.0f;
    float wSegment=self.view.frame.size.width-2*xOffset;
    float hSegment=34.0f;

    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    int totalClientCount=[[defaults objectForKey:@"totalClientCount"] intValue];
    int totalProjectCount=[[defaults objectForKey:@"totalProjectCount"] intValue];
    int totalProgramCount=[[defaults objectForKey:@"totalProgramCount"] intValue];

    NSString *clientString=[NSString stringWithFormat:@"%@ (%d)",RPLocalizedString(CLIENTS_STRING,@""),totalClientCount];
    NSString *programString=[NSString stringWithFormat:@"%@ (%d)",RPLocalizedString(PROGRAMS_STRING,@""),totalProgramCount];
    NSString *projectString=[NSString stringWithFormat:@"%@ (%d)",RPLocalizedString(PROJECTS_STRING,@""),totalProjectCount];

    NSString *segmentString=nil;
    if (isProgramAccess) {
        segmentString=programString;
    }
    else{
        segmentString=clientString;
    }

    self.segmentedCtrl = [[UISegmentedControl alloc] initWithItems:@[projectString, segmentString]];

    [self.segmentedCtrl setBackgroundColor:[UIColor clearColor]];
    [self.segmentedCtrl setFrame:CGRectMake(xOffset, yOffset, wSegment, hSegment)];
    [self.segmentedCtrl setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:RepliconFontFamilyLight size:14.0f]} forState:UIControlStateNormal];
    [self.segmentedCtrl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    [self.segmentedCtrl setTag:kTagFirst forSegmentAtIndex:0];
    [self.segmentedCtrl setTag:kTagSecond forSegmentAtIndex:1];
    [self.segmentedCtrl setWidth:100.0 forSegmentAtIndex:0];
    [self.segmentedCtrl setWidth:100.0 forSegmentAtIndex:1];
    [self.segmentedCtrl setTintColor:[Util colorWithHex:@"#007AC9" alpha:1.0f]];
    [self.segmentedCtrl sizeToFit];
    [self.segmentedCtrl setAccessibilityLabel:@"segment_clients_projects"];


    if ([viewDelegate isKindOfClass:[TimeEntryViewController class]])
    {
        TimeEntryViewController *timeEntryViewController=(TimeEntryViewController *)viewDelegate;
        if (timeEntryViewController.isClientAccess||timeEntryViewController.isProgramAccess)//MOBI-746
        {
            self.navigationItem.titleView = self.segmentedCtrl;
        }
        else
        {
            [Util setToolbarLabel:self withText:RPLocalizedString(ADD_PROJECT, @"") ];
        }
    }
    else  if ([viewDelegate isKindOfClass:[ExpenseEntryViewController class]])
    {
        ExpenseEntryViewController *expenseEntryViewController=(ExpenseEntryViewController *)viewDelegate;
        if (expenseEntryViewController.isClientAllowed)
        {
            self.navigationItem.titleView = self.segmentedCtrl;
        }
        else
        {
            [Util setToolbarLabel:self withText:RPLocalizedString(ADD_PROJECT, @"") ];
        }
    }



    NSMutableArray *tmpArray=[[NSMutableArray alloc]init];
    self.listOfItems=tmpArray;


    //Fix for ios7//JUHI
    int height=24;
    UITableView *tempmainTableView=[[UITableView alloc]initWithFrame:CGRectMake(0,searchBar_Height+1 , self.view.frame.size.width ,self.view.frame.size.height-searchBar_Height-2*toolbar_height-10+height) style:UITableViewStylePlain];

    self.mainTableView=tempmainTableView;
    self.mainTableView.separatorColor=[Util colorWithHex:@"#cccccc" alpha:1];

    if ([self.mainTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        self.mainTableView.layoutMargins = UIEdgeInsetsZero;
    }
    if ([self.mainTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        self.mainTableView.separatorInset = UIEdgeInsetsZero;
    }

    [self.mainTableView setAccessibilityLabel:@"select_client_tbl_view"];
    self.mainTableView.delegate=self;
    self.mainTableView.dataSource=self;
    [self.view addSubview:mainTableView];
    self.segmentedCtrl.selectedSegmentIndex=project_Tag;
    [self setupIndexData:project_Tag];
    [self changeUISegmentFont:self.segmentedCtrl];

    [self configureTableForPullToRefresh];

    [self.mainTableView setBottomContentInsetValue:0.0];
}
#pragma mark -
#pragma mark Textfield Delegates

-(void) changeUISegmentFont:(UIView*) myView
{
    // Getting the label subview of the passed view
    if ([myView isKindOfClass:[UILabel class]])
    {
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        int totalClientCount=[[defaults objectForKey:@"totalClientCount"] intValue];
        int totalProjectCount=[[defaults objectForKey:@"totalProjectCount"] intValue];
        int totalProgramCount=[[defaults objectForKey:@"totalProgramCount"] intValue];
        UILabel* label = (UILabel*)myView;
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont boldSystemFontOfSize:12]];       // Set the font size you want to change to
        [label sizeToFit];
        CGRect frame=label.frame;
        frame.size.width=label.frame.size.width+100;
        label.frame=frame;

        NSString *string=label.text;
        if ([string hasPrefix:RPLocalizedString(PROJECTS_STRING,@"")])
        {
            [self.segmentedCtrl setTitle:[NSString stringWithFormat:@"%@ (%d)",RPLocalizedString(PROJECTS_STRING,@""),totalProjectCount] forSegmentAtIndex:0];//DE19605 Ullas M L

        }
        else if([string hasPrefix:RPLocalizedString(CLIENTS_STRING,@"")])
        {
            [self.segmentedCtrl setTitle:[NSString stringWithFormat:@"%@ (%d)",RPLocalizedString(CLIENTS_STRING,@""),totalClientCount] forSegmentAtIndex:1];//DE19605 Ullas M L

        }
        //MOBI-746
        else if([string hasPrefix:RPLocalizedString(PROGRAMS_STRING,@"")])
        {
            [self.segmentedCtrl setTitle:[NSString stringWithFormat:@"%@ (%d)",RPLocalizedString(PROGRAMS_STRING,@""),totalProgramCount] forSegmentAtIndex:1];//DE19605 Ullas M L
        }
    }



    NSArray* subViewArray = [myView subviews];                  // Getting the subview array
    NSEnumerator* iterator = [subViewArray objectEnumerator];   // For enumeration
    UIView* subView;
    // Iterating through the subviews of the view passed
    while (subView = [iterator nextObject])
    {
        [self changeUISegmentFont:subView]; // Recursion

    }

}
/************************************************************************************************************
 @Function Name   : segmentChanged
 @Purpose         : To handle segment selected
 @param           : (id)sender
 @return          : nil
 *************************************************************************************************************/

-(void)segmentChanged:(id)sender
{
    UISegmentedControl *segmentCtrl=(UISegmentedControl *)sender;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEXT_RECENT_CLIENTS_OR_PROJECTS_RECEIVED_NOTIFICATION object:nil];
    SelectClientOrProjectViewController *weakSelf = self;
    [weakSelf.mainTableView.infiniteScrollingView stopAnimating];
    switch (segmentCtrl.selectedSegmentIndex)
    {
        case 0:
            CLS_LOG(@"-----Project segment selected on SelectClientOrProjectViewController -----");
            [self setupIndexData:project_Tag];
            self.searchTextField.placeholder=RPLocalizedString(SEARCHBAR_PLACEHOLDER_PROJECT, @"");
            self.segmentedCtrl.selectedSegmentIndex=project_Tag;
            if (searchProjectString!=nil && ![searchProjectString isKindOfClass:[NSNull class]] && ![searchProjectString isEqualToString:@"null"] &&
                ![searchProjectString isEqualToString:RPLocalizedString(SELECT_STRING, @"") ] && ![searchProjectString isEqualToString:RPLocalizedString(NONE_STRING, @"") ])
            {
                self.searchTextField.text=searchProjectString;
            }
            else
            {
                self.searchTextField.text=@"";
            }
            break;
        case 1:
            CLS_LOG(@"-----Client segment selected on SelectClientOrProjectViewController -----");
            if (isProgramAccess)//MOBI-746
            {
                self.searchTextField.placeholder=RPLocalizedString(SEARCHBAR_PLACEHOLDER_PROGRAM, @"");
                [self setupIndexData:program_Tag];
            }
            else
            {
                self.searchTextField.placeholder=RPLocalizedString(SEARCHBAR_PLACEHOLDER_CLIENT, @"");
                [self setupIndexData:client_Tag];
            }

            if (selectedClientName!=nil && ![selectedClientName isKindOfClass:[NSNull class]] && ![selectedClientName isEqualToString:@"null"] &&
                ![selectedClientName isEqualToString:RPLocalizedString(SELECT_STRING, @"") ] && ![selectedClientName isEqualToString:RPLocalizedString(NONE_STRING, @"") ])
            {
                self.searchTextField.text=selectedClientName;
            }
            else
            {
                self.searchTextField.text=@"";
            }

            self.segmentedCtrl.selectedSegmentIndex=client_Tag;
            break;
    }
    [self.mainTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    [self changeUISegmentFont:self.segmentedCtrl];
    [self checkToShowMoreButton];
    [self.mainTableView setBottomContentInsetValue:0.0];
}

#pragma mark -
#pragma mark Search Delegates

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{

    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.mainTableView.scrollEnabled = YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    textField.text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *textStr=[textField text];
    if (textStr==nil || [textStr isEqualToString:@""]||[textStr isKindOfClass:[NSNull class]])
    {
        self.isTextFieldFirstResponder=FALSE;
    }
    else
    {
        self.isTextFieldFirstResponder=TRUE;
    }
    if ([self.searchTimer isValid])
    {
        [self.searchTimer invalidate];

    }
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:self.searchTextField.text forKey:@"SearchString"];
    [defaults synchronize];

    self.searchTimer=  [NSTimer scheduledTimerWithTimeInterval:SEARCH_POLL
                                                        target:self
                                                      selector:@selector(fetchClientsOrProjectsWithSearchText)
                                                      userInfo:nil
                                                       repeats:NO];

    //self.mainTableView.scrollEnabled = NO;
    self.mainTableView.scrollEnabled = YES;
    return NO;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    textField.text=@"";
    self.isTextFieldFirstResponder=FALSE;
    if ([self.searchTimer isValid])
    {
        [self.searchTimer invalidate];

    }
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:self.searchTextField.text forKey:@"SearchString"];
    [defaults synchronize];

    self.searchTimer=  [NSTimer scheduledTimerWithTimeInterval:SEARCH_POLL
                                                        target:self
                                                      selector:@selector(fetchClientsOrProjectsWithSearchText)
                                                      userInfo:nil
                                                       repeats:NO];

    //self.mainTableView.scrollEnabled = NO;
    self.mainTableView.scrollEnabled = YES;
    return YES;
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar
{
    [searchTextField resignFirstResponder];
    if ([self.searchTimer isValid])
    {
        [self.searchTimer invalidate];

    }
    self.mainTableView.scrollEnabled = YES;
    //[self fetchClientsOrProjectsWithSearchText];

}

- (void)fetchClientsOrProjectsWithSearchText
{
    NSString *timesheetUri=self.selectedTimesheetUri;
    NSString *expenseSheetUri=self.selectedExpensesheetURI;
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CLIENTS_PROJECTS_SUMMARY_RECIEVED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(summaryReceived) name:CLIENTS_PROJECTS_SUMMARY_RECIEVED_NOTIFICATION object:nil];
        UIApplication* app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;
        if ( self.segmentedCtrl.selectedSegmentIndex==client_Tag)
        {
            if ([viewDelegate isKindOfClass:[TimeEntryViewController class]])
            {
                if (isFromAttendance)
                {
                    [[RepliconServiceManager attendanceService]fetchFirstClientsAndProjectsWithClientSearchText:searchTextField.text withProjectSearchText:searchTextField.text andDelegate:self];
                }
                else
                {
                    NSString *timesheetUri=self.selectedTimesheetUri;
                    //MOBI-746
                    if (isProgramAccess)
                    {
                        [[RepliconServiceManager timesheetService]fetchFirstProgramsAndProjectsForTimesheetUri:timesheetUri withProgramSearchText:searchTextField.text withProjectSearchText:searchTextField.text andDelegate:self];
                    }
                    else
                    {
                        [[RepliconServiceManager timesheetService]fetchFirstClientsAndProjectsForTimesheetUri:timesheetUri withClientSearchText:searchTextField.text withProjectSearchText:searchTextField.text andDelegate:self];
                    }
                }

            }
            else if ([viewDelegate isKindOfClass:[ExpenseEntryViewController class]])
            {
                [[RepliconServiceManager expenseService]fetchFirstClientsAndProjectsForExpenseSheetUri:expenseSheetUri withClientSearchText:searchTextField.text withProjectSearchText:searchTextField.text andDelegate:self];
            }


        }
        else
        {
            if ([viewDelegate isKindOfClass:[TimeEntryViewController class]])
            {
                if (isFromAttendance)
                {
                    [[RepliconServiceManager attendanceService]fetchFirstClientsAndProjectsWithClientSearchText:searchTextField.text withProjectSearchText:searchTextField.text andDelegate:self];
                }
                else
                {
                    //MOBI-746
                    if (isProgramAccess)
                    {
                        [[RepliconServiceManager timesheetService]fetchFirstProgramsAndProjectsForTimesheetUri:timesheetUri withProgramSearchText:searchTextField.text withProjectSearchText:searchTextField.text andDelegate:self];
                    }
                    else
                    {
                        [[RepliconServiceManager timesheetService]fetchFirstClientsAndProjectsForTimesheetUri:timesheetUri withClientSearchText:searchTextField.text withProjectSearchText:searchTextField.text andDelegate:self];
                    }

                }

            }
            else if ([viewDelegate isKindOfClass:[ExpenseEntryViewController class]])
            {
                [[RepliconServiceManager expenseService]fetchFirstClientsAndProjectsForExpenseSheetUri:expenseSheetUri withClientSearchText:searchTextField.text withProjectSearchText:searchTextField.text andDelegate:self];
            }

        }


    }



    [self.searchTimer invalidate];
}

#pragma mark -
#pragma mark TableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count= [self.arrayOfCharacters count];
    if (count<1)
    {
        return 1;
    }

    return [self.arrayOfCharacters count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count= [self.arrayOfCharacters count];
    if (count<1)
    {
        return 1;
    }
    return [(NSMutableArray *)[self.objectsForCharacters objectForKey:[self.arrayOfCharacters objectAtIndex:section]] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *name=@"";
    NSString *lowername=@"";

    NSUInteger count= [self.arrayOfCharacters count];

    if (count>0)
    {
        if ( self.segmentedCtrl.selectedSegmentIndex==client_Tag)
        {
            if (isProgramAccess) {
                ProgramObject *tmpClientObject=[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];

                NSString *clientName=[tmpClientObject programName];
                name=[NSString stringWithFormat:@"%@",clientName];//Implementation for US8849//JUHI
            }
            else
            {
                ClientObject *tmpClientObject=[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];

                NSString *clientName=[tmpClientObject clientName];
                name=[NSString stringWithFormat:@"%@",clientName];//Implementation for US8849//JUHI
            }

        }
        else
        {
            ProjectObject *tmpProjectObject=[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];

            NSString *projectName=[tmpProjectObject projectName];
            if ([viewDelegate isKindOfClass:[TimeEntryViewController class]])
            {
                TimeEntryViewController *timeEntryViewController=(TimeEntryViewController *)viewDelegate;
                if (timeEntryViewController.isClientAccess||timeEntryViewController.isProgramAccess)
                {
                    NSString *clientName=[tmpProjectObject clientName];
                    name=[NSString stringWithFormat:@"%@\n",projectName];//Implementation for US8849//JUHI
                    lowername = [NSString stringWithFormat:@"%@",clientName];
                    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
                        lowername = [NSString stringWithFormat:@"\n%@",clientName];
                    }
                }
                else
                {
                    name=[NSString stringWithFormat:@"%@",projectName];
                }
            }
            else  if ([viewDelegate isKindOfClass:[ExpenseEntryViewController class]])
            {
                ExpenseEntryViewController *expenseEntryViewController=(ExpenseEntryViewController *)viewDelegate;
                if (expenseEntryViewController.isClientAllowed)
                {
                    NSString *clientName=[tmpProjectObject clientName];
                    name=[NSString stringWithFormat:@"%@\n",projectName];//Implementation for US8849//JUHI
                    lowername = [NSString stringWithFormat:@"%@",clientName];
                    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
                        lowername = [NSString stringWithFormat:@"\n%@",clientName];
                    }
                }
                else
                {
                    name=[NSString stringWithFormat:@"%@",projectName];
                }
            }


        }

    }
    else
    {
        name=RPLocalizedString(NO_RESULTS_FOUND, NO_RESULTS_FOUND);
    }


    CGFloat heightLabel = [self getHeight:name withWidth:CGRectGetWidth(self.view.bounds) - Yoffset withFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];

    CGFloat heightLowerLabel = [self getHeight:lowername withWidth:CGRectGetWidth(self.view.bounds) - Yoffset withFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_14]];

    
    return  heightLabel+heightLowerLabel+20.0;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *CellIdentifier = @"Cell";
    cell  = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil)
    {
        cell = [[UITableViewCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    NSString *name=@"";
    NSString *lowername=@"";

    NSUInteger count= [self.arrayOfCharacters count];

    if (count>0)
    {
        if ( self.segmentedCtrl.selectedSegmentIndex==client_Tag)
        {
            if (isProgramAccess)
            {
                ProgramObject *tmpClientObject=[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];

                NSString *clientName=[tmpClientObject programName];
                name=[NSString stringWithFormat:@"%@",clientName];//Implementation for US8849//JUHI
            }
            else
            {
                ClientObject *tmpClientObject=[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];

                NSString *clientName=[tmpClientObject clientName];
                name=[NSString stringWithFormat:@"%@",clientName];//Implementation for US8849//JUHI
            }

        }
        else
        {
            ProjectObject *tmpProjectObject=[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];

            NSString *projectName=[tmpProjectObject projectName];
            name=[NSString stringWithFormat:@"%@",projectName];
            if ([viewDelegate isKindOfClass:[TimeEntryViewController class]])
            {
                TimeEntryViewController *timeEntryViewController=(TimeEntryViewController *)viewDelegate;
                if (timeEntryViewController.isClientAccess||timeEntryViewController.isProgramAccess)
                {


                    //Implementation for US8849//JUHI
                    NSString *clientName=[tmpProjectObject clientName];

                    lowername=[NSString stringWithFormat:@"%@",clientName];
                }
                else
                {

                    lowername=nil;
                }
            }
            else  if ([viewDelegate isKindOfClass:[ExpenseEntryViewController class]])
            {
                ExpenseEntryViewController *expenseEntryViewController=(ExpenseEntryViewController *)viewDelegate;
                if (expenseEntryViewController.isClientAllowed)
                {


                    //Implementation for US8849//JUHI
                    NSString *clientName=[tmpProjectObject clientName];

                    lowername=[NSString stringWithFormat:@"%@",clientName];
                }
                else
                {
                    lowername=nil;
                }
            }


        }

    }

    else
    {
        name=RPLocalizedString(NO_RESULTS_FOUND, NO_RESULTS_FOUND);
    }

    CGSize size =CGSizeMake(0, 0);
    if (name)
    {




        // Let's make an NSAttributedString first
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:name];
        //Add LineBreakMode
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        // Add Font
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]} range:NSMakeRange(0, attributedString.length)];

        //Now let's make the Bounding Rect
        //MOBI-802
        size  = [attributedString boundingRectWithSize:CGSizeMake([self widthOfTableViewContent], 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

        if (size.width==0 && size.height ==0)
        {
            size=CGSizeMake(11.0, 18.0);
        }
    }

    CGFloat maxWidth = CGRectGetWidth(self.view.bounds) - Yoffset;
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, maxWidth, 0)];
    if (count<1)
    {
        label.textAlignment=NSTextAlignmentCenter;
    }
    label.font = [UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16];
    label.numberOfLines=100;
    label.text=name;
    [Util resizeLabel:label withWidth:maxWidth];

    [cell.contentView addSubview:label];


    UILabel *lowerlabel=[[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(label.frame)+label.frame.origin.y+10.0, maxWidth, 0)];
    if (count<1)
    {
        lowerlabel.textAlignment=NSTextAlignmentCenter;
    }
    lowerlabel.font = [UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_14];
    lowerlabel.numberOfLines=100;
    lowerlabel.text=lowername;
    if(lowername!=nil)
    {
       [Util resizeLabel:lowerlabel withWidth:maxWidth];
    }

    [cell.contentView addSubview:lowerlabel];

    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSUInteger count= [self.arrayOfCharacters count];
    self.isTextFieldFirstResponder=NO;
    if (count>0)
    {
        if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
        {
            [Util showOfflineAlert];

        }
        else
        {
            NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
            [defaults removeObjectForKey:@"SearchString"];
            [defaults synchronize];
            [defaults setObject:@"" forKey:@"SearchString"];
            [defaults synchronize];

            SelectProjectOrTaskViewController *selectVC=[[SelectProjectOrTaskViewController alloc]init];
            selectVC.delegate=delegate;
            selectVC .entryDelegate=viewDelegate;

            selectVC.isFromAttendance=isFromAttendance;
            NSString *name=@"";
            //Implementation for US8849//JUHI
            if (self.segmentedCtrl.selectedSegmentIndex==client_Tag)
            {
                id obj=[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
                if ([obj isKindOfClass:[ClientObject class]])
                {
                    selectVC.selectedItem=RPLocalizedString(Client, @"");
                    selectVC.selectedMode=CLIENT_MODE;//DE20024//JUHI
                    name=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] clientName];
                    selectVC.selectedClientUri=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] clientUri];
                }
                else
                {
                    selectVC.selectedItem=RPLocalizedString(Program, @"");
                    selectVC.selectedMode=PROGRAM_MODE;//DE20024//JUHI
                    name=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] programName];
                    selectVC.selectedClientUri=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] programUri];
                }


                //Implementation for US8849//JUHI
                selectVC.isTaskPermission=TRUE;
                selectVC.isTimeAllowedPermission=FALSE;


                [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                [[NSNotificationCenter defaultCenter] removeObserver:selectVC name:PROJECTS_OR_TASKS_RECEIVED_NOTIFICATION object:nil];

                [[NSNotificationCenter defaultCenter] addObserver:selectVC selector:@selector(refreshViewAfterDataRecieved:)
                                                             name:PROJECTS_OR_TASKS_RECEIVED_NOTIFICATION
                                                           object:nil];
                NSString *timesheetUri=self.selectedTimesheetUri;
                NSString *expenseSheetUri=self.selectedExpensesheetURI;
                CLS_LOG(@"-----Client row selected on SelectClientOrProjectViewController -----");
                if ([viewDelegate isKindOfClass:[TimeEntryViewController class]])
                {
                    selectVC.selectedTimesheetUri=timesheetUri;
                    if (isFromAttendance)
                    {
                        [[RepliconServiceManager attendanceService]fetchProjectsBasedOnclientsWithSearchText:@"" withClientUri:selectVC.selectedClientUri andDelegate:self];
                    }
                    else
                    {
                        //MOBI-746
                        if (isProgramAccess)
                        {
                            [[RepliconServiceManager timesheetService]fetchProjectsBasedOnProgramsForTimesheetUri:timesheetUri withSearchText:@"" withProgramUri:selectVC.selectedClientUri andDelegate:self];
                        }
                        else
                        {
                            [[RepliconServiceManager timesheetService]fetchProjectsBasedOnclientsForTimesheetUri:timesheetUri withSearchText:@"" withClientUri:selectVC.selectedClientUri andDelegate:self];
                        }

                    }

                }
                else if ([viewDelegate isKindOfClass:[ExpenseEntryViewController class]])
                {
                    selectVC.selectedExpenseUri=expenseSheetUri;
                    [[RepliconServiceManager expenseService]fetchProjectsBasedOnclientsForExpenseSheetUri:expenseSheetUri withSearchText:@"" withClientUri:selectVC.selectedClientUri andDelegate:self];
                }


            }
            else
            {
                selectVC.selectedItem=RPLocalizedString(Project, @"");
                selectVC.selectedMode=PROJECT_MODE;//DE20024//JUHI
                name=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] projectName];
                //Implementation for US8849//JUHI
                selectVC.isTaskPermission=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] hasTasksAvailableForTimeAllocation];
                selectVC.isTimeAllowedPermission=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] isTimeAllocationAllowed];
                selectVC.selectedClientUri=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] clientUri];
                selectVC.selectedProjectUri=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] projectUri];
                selectVC.client=[[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] clientName];
                CLS_LOG(@"-----Project row selected on SelectClientOrProjectViewController -----");
                if ([viewDelegate isKindOfClass:[TimeEntryViewController class]])
                {

                    ProjectObject *obj=(ProjectObject *)[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];

                    if ([obj projectUri]==nil || [[obj projectUri] isKindOfClass:[NSNull class]] || [[obj projectUri] isEqualToString:NULL_STRING ])
                    {
                        if ([viewDelegate conformsToProtocol:@protocol(UpdateEntryProjectAndTaskFieldProtocol)])
                        {
                            [viewDelegate updateFieldWithClient:[obj clientName] clientUri:[obj clientUri] project:[obj projectName] projectUri:[obj projectUri] task:@"" andTaskUri:@"" taskPermission: NO timeAllowedPermission:NO];
                        }
                    }
                    else
                    {

                        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
                        [[NSNotificationCenter defaultCenter] removeObserver:selectVC name:PROJECTS_OR_TASKS_RECEIVED_NOTIFICATION object:nil];

                        [[NSNotificationCenter defaultCenter] addObserver:selectVC selector:@selector(refreshViewAfterDataRecieved:)
                                                                     name:PROJECTS_OR_TASKS_RECEIVED_NOTIFICATION
                                                                   object:nil];

                        NSString *timesheetUri=self.selectedTimesheetUri;
                        selectVC.selectedTimesheetUri=timesheetUri;
                        if (isFromAttendance)
                        {
                            [[RepliconServiceManager attendanceService]fetchTasksBasedOnProjectsWithSearchText:@"" withProjectUri:selectVC.selectedProjectUri andDelegate:self];
                        }
                        else
                        {
                            [[RepliconServiceManager timesheetService]fetchTasksBasedOnProjectsForTimesheetUri:timesheetUri withSearchText:@"" withProjectUri:selectVC.selectedProjectUri andDelegate:self];
                        }


                    }


                }
                else if ([viewDelegate isKindOfClass:[ExpenseEntryViewController class]])
                {

                    ProjectObject *obj=(ProjectObject *)[[self.objectsForCharacters objectForKey:[arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
                    if ([viewDelegate conformsToProtocol:@protocol(UpdateEntryProjectAndTaskFieldProtocol)])
                    {
                        [viewDelegate updateFieldWithClient:[obj clientName] clientUri:[obj clientUri] project:[obj projectName] projectUri:[obj projectUri] task:@"" andTaskUri:@"" taskPermission: NO timeAllowedPermission:NO];
                    }

                    [self.navigationController popViewControllerAnimated:YES];

                    return;
                }



            }


            selectVC.selectedValue=name;
            //Implementation for US8849//JUHI
            selectVC.searchProjectString=nil;
            selectVC.isPreFilledSearchString=NO;

            [self.navigationController pushViewController:selectVC animated:YES];
            [self.mainTableView deselectRowAtIndexPath:indexPath animated:YES];



        }
    }




}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{

    if ([arrayOfCharacters count] == 0)
    {
        return @"";
    }
    if (self.isTextFieldFirstResponder)
    {
        return @"";
    }
    else
    {
        return [NSString stringWithFormat:@"%@", [arrayOfCharacters objectAtIndex:section]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.isTextFieldFirstResponder || self.arrayOfCharacters.count == 0) {
        return 0.0f;
    }

    return CGRectGetHeight([[self tableView:tableView viewForHeaderInSection:section] bounds]);
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, 18)];
    [label setFont:[UIFont fontWithName:RepliconFontFamilyLight size:16.0f]];
    [label setText:[self tableView:tableView titleForHeaderInSection:section]];
    [view addSubview:label];
    [view setBackgroundColor:TimesheetTotalHoursBackgroundColor];
    [view sizeToFit];
    return view;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [arrayOfCharacters indexOfObject:title] ;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchTextField resignFirstResponder];
}

#pragma mark -
#pragma mark Other Methods
/************************************************************************************************************
 @Function Name   : configureTableForPullToRefresh
 @Purpose         : To extend tableview to add pull to refresh and infinite scrolling view
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)configureTableForPullToRefresh
{
    SelectClientOrProjectViewController *weakSelf = self;


    //setup pull to refresh widget
    [self.mainTableView addPullToRefreshWithActionHandler:^{
        [weakSelf.view setUserInteractionEnabled:NO];
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           [weakSelf.mainTableView.pullToRefreshView startAnimating];
                           [weakSelf refreshAction];
                       });
    }];

    // setup infinite scrolling
    [self.mainTableView addInfiniteScrollingWithActionHandler:^{

        [weakSelf.view setUserInteractionEnabled:YES];
        int64_t delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           if ([weakSelf.arrayOfCharacters count]>0) {
                               [weakSelf.mainTableView setBottomContentInsetValue: 60.0];
                               NSUInteger sectionCount=[weakSelf.arrayOfCharacters count];
                               NSUInteger rowCount=[(NSMutableArray *)[weakSelf.objectsForCharacters objectForKey:[weakSelf.arrayOfCharacters objectAtIndex:sectionCount-1]] count];
                               NSIndexPath* ipath = [NSIndexPath indexPathForRow: rowCount-1 inSection: sectionCount-1];
                               [weakSelf.mainTableView scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionBottom animated: YES];
                               [weakSelf.mainTableView.infiniteScrollingView startAnimating];
                               [weakSelf moreAction];
                           }
                           else
                               [weakSelf.mainTableView.infiniteScrollingView stopAnimating];
                       });
    }];

}

/************************************************************************************************************
 @Function Name   : moreAction
 @Purpose         : To fetch more records of timesheet when tableview is scrolled to bottom
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)moreAction
{
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {


        [Util showOfflineAlert];
        [self performSelector:@selector(refreshTableViewOnConnectionError) withObject:nil afterDelay:0.2];

    }
    else
    {
        NSString *timesheetUri=self.selectedTimesheetUri;
        NSString *expenseSheetUri=self.selectedExpensesheetURI;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NEXT_RECENT_CLIENTS_OR_PROJECTS_RECEIVED_NOTIFICATION object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewAfterMoreAction:)
                                                     name:NEXT_RECENT_CLIENTS_OR_PROJECTS_RECEIVED_NOTIFICATION
                                                   object:nil];



        if ( self.segmentedCtrl.selectedSegmentIndex==client_Tag)
        {
            if ([viewDelegate isKindOfClass:[TimeEntryViewController class]])
            {
                if (isFromAttendance)
                {
                    [[RepliconServiceManager attendanceService]fetchNextClientsWithSearchText:searchTextField.text andDelegate:self];
                }

                else
                {
                    //MOBI-746
                    if (isProgramAccess)
                    {
                        [[RepliconServiceManager timesheetService]fetchNextProgramsForTimesheetUri:timesheetUri withSearchText:searchTextField.text andDelegate:self];
                    }
                    else
                    {
                        [[RepliconServiceManager timesheetService]fetchNextClientsForTimesheetUri:timesheetUri withSearchText:searchTextField.text andDelegate:self];
                    }

                }

            }
            else if ([viewDelegate isKindOfClass:[ExpenseEntryViewController class]])
            {
                [[RepliconServiceManager expenseService]fetchNextClientsForExpenseSheetUri:expenseSheetUri withSearchText:searchTextField.text andDelegate:self];
            }

        }
        else
        {
            if ([viewDelegate isKindOfClass:[TimeEntryViewController class]])
            {
                if (isFromAttendance)
                {
                    [[RepliconServiceManager attendanceService]fetchNextProjectsWithSearchText:searchTextField.text withClientUri:nil andDelegate:self];
                }
                else
                {
                    [[RepliconServiceManager timesheetService]fetchNextProjectsForTimesheetUri:timesheetUri withSearchText:searchTextField.text withClientUri:nil andDelegate:self];
                }

            }
            else if ([viewDelegate isKindOfClass:[ExpenseEntryViewController class]])
            {
                [[RepliconServiceManager expenseService]fetchNextProjectsForExpenseSheetUri:expenseSheetUri withSearchText:searchTextField.text withClientUri:nil andDelegate:self];
            }

        }


    }




}

/************************************************************************************************************
 @Function Name   : refreshAction
 @Purpose         : To fetch modified records of timesheet when tableview is pulled to refresh
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)refreshAction
{
    if(![NetworkMonitor isNetworkAvailableForListener: self])
    {
        [self.view setUserInteractionEnabled:YES];
        SelectClientOrProjectViewController *weakSelf = self;
        [weakSelf.mainTableView.pullToRefreshView stopAnimating];
        [Util showOfflineAlert];
        return;
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self name:CLIENTS_PROJECTS_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewAfterPullToRefreshAction:) name:CLIENTS_PROJECTS_SUMMARY_RECIEVED_NOTIFICATION object:nil];

    NSString *timesheetUri=self.selectedTimesheetUri;
//TODO:Commenting below line because variable is unused,uncomment when using
//    NSString *expenseSheetUri=self.selectedExpensesheetURI;
    if ( self.segmentedCtrl.selectedSegmentIndex==client_Tag)
    {
        if ([viewDelegate isKindOfClass:[TimeEntryViewController class]])
        {
            if (isFromAttendance)
            {
                [[RepliconServiceManager attendanceService]fetchFirstClientsWithSearchText:searchTextField.text andDelegate:self];
            }
            else
            {
                //MOBI-746
                if (isProgramAccess)
                {
                    [[RepliconServiceManager timesheetService]fetchFirstProgramsForTimesheetUri:timesheetUri withSearchText:searchTextField.text andDelegate:self];
                }
                else
                {
                    [[RepliconServiceManager timesheetService]fetchFirstClientsForTimesheetUri:timesheetUri withSearchText:searchTextField.text andDelegate:self];
                }

            }

        }
    }
    else
    {
        if ([viewDelegate isKindOfClass:[TimeEntryViewController class]])
        {
            if (isFromAttendance)
            {
                [[RepliconServiceManager attendanceService]fetchFirstProjectsWithSearchText:searchTextField.text withClientUri:nil andDelegate:self];
            }
            else
            {
                [[RepliconServiceManager timesheetService]fetchFirstProjectsForTimesheetUri:timesheetUri withSearchText:searchTextField.text withClientUri:nil andDelegate:self];
            }

        }
    }

}
/************************************************************************************************************
 @Function Name   : checkToShowMoreButton
 @Purpose         : To check to enable more action or not everytime view appears
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)checkToShowMoreButton
{
    NSNumber *count=nil;
    if (self.segmentedCtrl.selectedSegmentIndex==client_Tag)
    {
        //MOBI-746
        if (isProgramAccess)
            count =	[[NSUserDefaults standardUserDefaults]objectForKey:@"programsDownloadCount"];
        else
            count =	[[NSUserDefaults standardUserDefaults]objectForKey:@"clientsDownloadCount"];

    }
    else
    {
        count =	[[NSUserDefaults standardUserDefaults]objectForKey:@"projectssDownloadCount"];
    }
    NSNumber *fetchCount  =    [[AppProperties getInstance] getAppPropertyFor:@"clientsOrprojectOrtasksDownloadCount"];

    if (([count intValue]<[fetchCount intValue]))
    {
        self.mainTableView.showsInfiniteScrolling=FALSE;
    }
    else
    {
        self.mainTableView.showsInfiniteScrolling=TRUE;
    }

    if ([self.listOfItems count]==0)
    {
        self.mainTableView.showsPullToRefresh=TRUE;
        self.mainTableView.showsInfiniteScrolling=FALSE;
    }
    else
    {
        self.mainTableView.showsPullToRefresh=TRUE;
    }



}

/************************************************************************************************************
 @Function Name   : refreshTableViewOnConnectionError
 @Purpose         : To refresh tableview on connection error
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)refreshTableViewOnConnectionError
{
    SelectClientOrProjectViewController *weakSelf = self;
    [weakSelf.mainTableView.infiniteScrollingView stopAnimating];

    self.mainTableView.showsInfiniteScrolling=FALSE;
    self.mainTableView.showsInfiniteScrolling=TRUE;

}
/************************************************************************************************************
 @Function Name   : cancelAction
 @Purpose         : To cancel present view and to pop to root view
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)cancelAction:(id)sender
{


    if ([viewDelegate isKindOfClass:[TimeEntryViewController class]])
    {

        if ([delegate isKindOfClass:[TimesheetMainPageController class]])
        {
            [self.navigationController popViewControllerAnimated:YES];  //DE19919 Ullas M L

        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }



    }
    else if ([viewDelegate isKindOfClass:[ExpenseEntryViewController class]])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }



}
/************************************************************************************************************
 @Function Name   : summaryReceived
 @Purpose         : To refresh view with fresh first time data of clients and projects
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)summaryReceived
{
    [self.view setUserInteractionEnabled:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CLIENTS_PROJECTS_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    self.mainTableView.scrollEnabled = YES;
    /*[ovController.view removeFromSuperview];

     ovController = nil;*/
    [self.mainTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = NO;
    SelectClientOrProjectViewController *weakSelf = self;
    [weakSelf.mainTableView.pullToRefreshView stopAnimating];
    self.mainTableView.showsInfiniteScrolling=TRUE;

    [self changeUISegmentFont:self.segmentedCtrl];
    if (self.segmentedCtrl.selectedSegmentIndex==client_Tag)
    {
        if (isProgramAccess)//MOBI-746
            [self setupIndexData:program_Tag];
        else
            [self setupIndexData:client_Tag];

    }
    else
    {
        [self setupIndexData:project_Tag];
    }
    [self checkToShowMoreButton];
    [self.mainTableView setBottomContentInsetValue:0.0];

    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
}

/************************************************************************************************************
 @Function Name   : refreshViewAfterMoreAction
 @Purpose         : To refresh view with more data of clients or projects
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)refreshViewAfterMoreAction:(NSNotification *)notificationObject
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEXT_RECENT_CLIENTS_OR_PROJECTS_RECEIVED_NOTIFICATION object:nil];
    [self.view setUserInteractionEnabled:YES];
    SelectClientOrProjectViewController *weakSelf = self;
    [weakSelf.mainTableView.infiniteScrollingView stopAnimating];
    self.mainTableView.scrollEnabled = YES;
    /*[ovController.view removeFromSuperview];

     ovController = nil;*/

    NSDictionary *theData = [notificationObject userInfo];
    NSNumber *n = [theData objectForKey:@"isErrorOccured"];
    NSNumber *temp = [theData objectForKey:@"isClientMoreAction"];

    BOOL isErrorOccured = [n boolValue];
    BOOL isClientMoreAction=[temp boolValue];
    if (isErrorOccured)
    {
        self.mainTableView.showsInfiniteScrolling=FALSE;
    }
    else
    {

        if (isClientMoreAction)
        {
            self.segmentedCtrl.selectedSegmentIndex=client_Tag;
            //MOBI-746
            if (isProgramAccess)
                [self setupIndexData:program_Tag];
            else
                [self setupIndexData:client_Tag];
        }
        else
        {
            self.segmentedCtrl.selectedSegmentIndex=project_Tag;
            [self setupIndexData:project_Tag];
        }
        [self changeUISegmentFont:self.segmentedCtrl];
        [self checkToShowMoreButton];
    }



    [self.mainTableView setBottomContentInsetValue:0.0];


}
-(void)refreshViewAfterPullToRefreshAction:(NSNotification *)notificationObject
{
    [self.view setUserInteractionEnabled:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CLIENTS_PROJECTS_SUMMARY_RECIEVED_NOTIFICATION object:nil];
    SelectClientOrProjectViewController *weakSelf = self;
    [weakSelf.mainTableView.pullToRefreshView stopAnimating];
    self.mainTableView.showsInfiniteScrolling=TRUE;

    NSDictionary *theData = [notificationObject userInfo];
    NSNumber *n = [theData objectForKey:@"isErrorOccured"];
    BOOL isErrorOccured = [n boolValue];
    if (isErrorOccured)
    {

    }
    else
    {
        [self changeUISegmentFont:self.segmentedCtrl];
        if (self.segmentedCtrl.selectedSegmentIndex==client_Tag)
        {
            //MOBI-746
            if (isProgramAccess)
                [self setupIndexData:program_Tag];
            else
                [self setupIndexData:client_Tag];


        }
        else
        {
            [self setupIndexData:project_Tag];
        }
        [self checkToShowMoreButton];

    }

    [self.mainTableView setBottomContentInsetValue:0.0];
}
- (void) doneSearching_Clicked:(id)sender
{
    [searchTextField resignFirstResponder];
    self.mainTableView.scrollEnabled = YES;
    /*[ovController.view removeFromSuperview];

     ovController = nil;*/
}

- (void)setupIndexData:(int)tag
{
    [listOfItems removeAllObjects];
    [arrayOfCharacters removeAllObjects];
    [objectsForCharacters removeAllObjects];
    ExpenseModel *expensesModel=[[ExpenseModel alloc]init];
    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
    NSString *key=@"";
    if (tag==client_Tag)
    {
        key=@"clientName";
        if ([viewDelegate isKindOfClass:[TimeEntryViewController class]])
        {
            self.listOfItems=[timesheetModel getAllClientsDetailsFromDBForModule:@"Timesheet"];
        }
        else if ([viewDelegate isKindOfClass:[ExpenseEntryViewController class]])
        {
            self.listOfItems=[expensesModel getAllClientsDetailsFromDBForModule:@"Expense"];
        }


    }
    else if (tag==program_Tag)
    {
        key=@"programName";
        if ([viewDelegate isKindOfClass:[TimeEntryViewController class]])
        {
            self.listOfItems=[timesheetModel getAllProgramsDetailsFromDBForModule:@"Timesheet"];
        }

    }
    else
    {
        key=@"projectName";
        if ([viewDelegate isKindOfClass:[TimeEntryViewController class]])
        {
            self.listOfItems=[timesheetModel getAllProjectsDetailsFromDBForModule:@"Timesheet"];
        }
        else if ([viewDelegate isKindOfClass:[ExpenseEntryViewController class]])
        {
            self.listOfItems=[expensesModel getAllProjectsDetailsFromDBForModule:@"Expense"];
        }


    }
    if (!isTextFieldFirstResponder)
    {
        NSSortDescriptor * brandDescriptor =[[NSSortDescriptor alloc] initWithKey:key ascending:YES comparator:^(id firstDocumentName, id secondDocumentName)
                                             {
                                                 static NSStringCompareOptions comparisonOptions =
                                                 NSCaseInsensitiveSearch | NSNumericSearch |
                                                 NSWidthInsensitiveSearch | NSForcedOrderingSearch;
                                                 return [firstDocumentName compare:secondDocumentName options:comparisonOptions];
                                             }];
        NSMutableArray *sortDescriptors = [NSMutableArray arrayWithObject:brandDescriptor];

        NSArray *array = [listOfItems sortedArrayUsingDescriptors:sortDescriptors];
        self.listOfItems=[NSMutableArray arrayWithArray:array];
    }


    [self setupIndexDataBasedOnSectionAlphabets:tag];

}

- (void)setupIndexDataBasedOnSectionAlphabets:(int)tag
{



    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    NSMutableArray *arrayOfNames = [[NSMutableArray alloc] init];
    NSString *numbericSection    = @"#";
    NSString *firstLetter;
    NSString *name;

    for (NSDictionary *item in self.listOfItems)
    {
        NSDictionary *listOfitemDict=item;
        NSArray *allKeys=[listOfitemDict allKeys];
        ClientObject *clientObject=[[ClientObject alloc]init];
        ProjectObject *projectObject=[[ProjectObject alloc]init];
        ProgramObject *programObject=[[ProgramObject alloc]init];
        for (NSString *tmpKey in allKeys)
        {
            if (tag==client_Tag)
            {
                if ([tmpKey isEqualToString:@"clientName"])
                {
                    clientObject.clientName=[listOfitemDict objectForKey:tmpKey];
                }
                else if ([tmpKey isEqualToString:@"clientUri"])
                {
                    clientObject.clientUri=[listOfitemDict objectForKey:tmpKey];
                }
                //Implementation for US8849//JUHI
            }
            else if (tag==program_Tag)
            {
                if ([tmpKey isEqualToString:@"programName"])
                {
                    programObject.programName=[listOfitemDict objectForKey:tmpKey];
                }
                else if ([tmpKey isEqualToString:@"programUri"])
                {
                    programObject.programUri=[listOfitemDict objectForKey:tmpKey];
                }
                //Implementation for US8849//JUHI
            }
            else
            {
                //Implementation for US8849//JUHI
                if ([tmpKey isEqualToString:@"projectName"])
                {
                    projectObject.projectName=[listOfitemDict objectForKey:tmpKey];
                }
                else if ([tmpKey isEqualToString:@"projectUri"])
                {
                    projectObject.projectUri=[listOfitemDict objectForKey:tmpKey];
                }
                else if ([tmpKey isEqualToString:@"clientName"])
                {
                    projectObject.clientName=[listOfitemDict objectForKey:tmpKey];
                }
                else if ([tmpKey isEqualToString:@"programName"]&& isProgramAccess)
                {
                    projectObject.clientName=[listOfitemDict objectForKey:tmpKey];
                }
                else if ([tmpKey isEqualToString:@"clientUri"])
                {
                    projectObject.clientUri=[listOfitemDict objectForKey:tmpKey];
                }
                else if ([tmpKey isEqualToString:@"programUri"]&& isProgramAccess)
                {
                    projectObject.clientUri=[listOfitemDict objectForKey:tmpKey];
                }

                else if ([tmpKey isEqualToString:@"isTimeAllocationAllowed"])
                {
                    NSString *tmpStr=[listOfitemDict objectForKey:tmpKey];
                    if (tmpStr!=nil &&![tmpStr isKindOfClass:[NSNull class]])
                    {
                        projectObject.isTimeAllocationAllowed=[[listOfitemDict objectForKey:tmpKey] boolValue];
                    }

                }
                else if ([tmpKey isEqualToString:@"hasTasksAvailableForTimeAllocation"])
                {
                    NSString *tmpStr=[listOfitemDict objectForKey:tmpKey];
                    if (tmpStr!=nil &&![tmpStr isKindOfClass:[NSNull class]])
                    {
                        projectObject.hasTasksAvailableForTimeAllocation=[[listOfitemDict objectForKey:tmpKey] boolValue];
                    }

                }

            }


        }
        NSString *key=@"";
        if (tag==client_Tag)
        {
            key=@"clientName";
        }
        else if (tag==program_Tag)
        {
            key=@"programName";
        }
        else
        {
            key=@"projectName";
        }
        name=[[listOfitemDict objectForKey:key] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        firstLetter = [[name substringToIndex:1] uppercaseString];

        NSData *data = [firstLetter dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *newStrfirstLetter = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];


        NSString *accepatable=[NSString stringWithFormat:@"%@",ACCEPTABLE_CHARACTERS_SECTION_TABLEVIEW];

        if ([formatter numberFromString:newStrfirstLetter] == nil && [accepatable rangeOfString:newStrfirstLetter].location != NSNotFound ) {
            
            /**
             * If the letter doesn't exist in the dictionary go ahead and add it the
             * dictionary.
             *
             * ::IMPORTANT::
             * You HAVE to removeAllObjects from the arrayOfNames or you will have an N + 1
             * problem.  Let's say that start with the A's, well once you hit the
             * B's then in your table you will the A's and B's for the B's section.  Once
             * you hit the C's you will all the A's, B's, and C's, etc.
             */
            if (![self.objectsForCharacters objectForKey:newStrfirstLetter]) {
                
                [arrayOfNames removeAllObjects];
                
                [arrayOfCharacters addObject:newStrfirstLetter];
            }
            if (tag==client_Tag)
            {
                [arrayOfNames addObject:clientObject];
            }
            else if (tag==program_Tag)
            {
                [arrayOfNames addObject:programObject];
            }
            else
            {
                [arrayOfNames addObject:projectObject];
            }
            
            
            
            /**
             * Need to autorelease the copy to preven potential leak.  Even though the
             * arrayOfNames is released below it still has a retain count of +1
             */
            [self.objectsForCharacters setObject:[arrayOfNames copy] forKey:newStrfirstLetter];
            
            
        }
        else {
            
            if (![self.objectsForCharacters objectForKey:numbericSection]) {
                
                [arrayOfNames removeAllObjects];
                
                [arrayOfCharacters addObject:numbericSection];
            }
            
            if (tag==client_Tag)
            {
                [arrayOfNames addObject:clientObject];
            }
            else if (tag==program_Tag)
            {
                [arrayOfNames addObject:programObject];
            }
            else
            {
                [arrayOfNames addObject:projectObject];
            }
            
            [self.objectsForCharacters setObject:[arrayOfNames copy] forKey:numbericSection];
        }
        
    }
    
    
    
    [self.mainTableView reloadData];
}


- (CGFloat)getHeight:(NSString *)string withWidth:(CGFloat)width withFont:(UIFont *)font
{
    if (string!=nil)
    {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];

        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];

        NSDictionary *attributes = @{NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName :font};
        [attributedString setAttributes:attributes range:NSMakeRange(0, attributedString.length)];

        return CGRectGetHeight([attributedString boundingRectWithSize:CGSizeMake(width, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil]);
    }

    return 0.0;

}

#pragma mark Memory Management

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.segmentedCtrl=nil;
    self.searchTextField=nil;
    self.mainTableView=nil;
}

#pragma mark - Private

- (CGFloat)widthOfTableViewContent
{
    return CGRectGetWidth([[UIScreen mainScreen] bounds]) - TABLEVIEW_HORIZONTAL_PADDING - TABLEVIEW_HORIZONTAL_PADDING;
}


-(void)dealloc
{
    self.mainTableView.delegate = nil;
    self.mainTableView.dataSource = nil;
}


@end
