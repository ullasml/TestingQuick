#import "ApprovalsCountViewController.h"
#import "Util.h"
#import "Constants.h"
#import "LoginModel.h"
#import "ApprovalsPendingTimesheetViewController.h"
#import "ApprovalsTimesheetHistoryViewController.h"
#import "ApprovalsModel.h"
#import "ApprovalsPendingExpenseViewController.h"
#import "ApprovalsExpenseHistoryViewController.h"
#import "ApprovalsPendingTimeOffViewController.h"
#import "ApprovalsTimeOffHistoryViewController.h"
#import "ACSimpleKeychain.h"
#import "ApproveRejectHeaderStylist.h"
#import "DefaultTheme.h"
#import "SpinnerDelegate.h"
#import "UserPermissionsStorage.h"
#import "ApprovalsModel.h"
#import "MinimalTimesheetDeserializer.h"
#import "ApprovalsService.h"
#import "UserSession.h"
#import "PersistentUserSession.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "InboxCell.h"
#import "EventTracker.h"


#define Each_Cell_Row_Height_44 44

@interface ApprovalsCountViewController ()

@property (nonatomic) NSNotificationCenter *notificationCenter;
@property (nonatomic) ApprovalsService *approvalsService;
@property (nonatomic) LoginModel *loginModel;
@property (nonatomic) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic) id<BSInjector> injector;
@property (nonatomic) ApprovalsModel *approvalsModel;
@property (nonatomic) NSArray *userDetailsArray;
@property (nonatomic) ReachabilityMonitor *reachabilityMonitor;
@property (nonatomic) id<Theme> theme;

@end

@implementation ApprovalsCountViewController
@synthesize leftButton;
@synthesize approvalsPermissionArray;

#pragma mark -
#pragma mark - view intialisation


- (instancetype)initWithNotificationCenter:(NSNotificationCenter *)notificationCenter
                           spinnerDelegate:(id<SpinnerDelegate>)spinnerDelegate
                          approvalsService:(ApprovalsService *)approvalsService
                            approvalsModel:(ApprovalsModel *)approvalsModel
                                loginModel:(LoginModel *)loginModel
                          reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                                     theme:(id<Theme>)theme;
{
    self = [super init];
    if (self)
    {
        self.notificationCenter = notificationCenter;
        self.approvalsService = approvalsService;
        self.loginModel = loginModel;
        self.spinnerDelegate = spinnerDelegate;
        self.approvalsModel = approvalsModel;
        self.reachabilityMonitor = reachabilityMonitor;
        self.theme = theme;
    }
    return self;
}

-(void)dealloc
{
    self.approvalsTableView.delegate = nil;
    self.approvalsTableView.dataSource = nil;
}

- (void)loadView
{
    [super loadView];
    [self.view setBackgroundColor:RepliconStandardBackgroundColor];


    self.userDetailsArray=[self.loginModel getAllUserDetailsInfoFromDb];

    self.approvalsTableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.approvalsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.approvalsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"InboxCell"];
    NSString *inboxCellIdentifier = NSStringFromClass([InboxCell class]);
    UINib *inboxCellNib = [UINib nibWithNibName:inboxCellIdentifier bundle:[NSBundle mainBundle]];
    [self.approvalsTableView registerNib:inboxCellNib forCellReuseIdentifier:inboxCellIdentifier];
	self.approvalsTableView.delegate=self;
	self.approvalsTableView.dataSource=self;
    self.approvalsTableView.scrollEnabled=YES;
    self.approvalsTableView.rowHeight = Each_Cell_Row_Height_44;
	[self.view addSubview:self.approvalsTableView];

    self.approvalsPermissionArray=[NSMutableArray array];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];


    [self handleApprovalsCountsDataReceivedAction];
}

-(void)handleApprovalsCountsDataReceivedAction
{

    [approvalsPermissionArray removeAllObjects];
     if ([self.userDetailsArray count]!=0)
     {
         NSDictionary *userDict=[self.userDetailsArray objectAtIndex:0];
         BOOL isTimeOffApprover=[[userDict objectForKey:@"isTimeOffApprover"] boolValue];
         BOOL isTimesheetApprover=[[userDict objectForKey:@"isTimesheetApprover"] boolValue];
         BOOL isExpenseApprover=[[userDict objectForKey:@"isExpenseApprover"] boolValue];

         if (isTimesheetApprover)
         {
             [approvalsPermissionArray addObject:RPLocalizedString(TimeSheetLabelText, @"")];
         }
         if (isExpenseApprover)
         {
             [approvalsPermissionArray addObject:RPLocalizedString(ExpenseLabelText, @"")];
         }
         if (isTimeOffApprover)
         {
             [approvalsPermissionArray addObject:RPLocalizedString(TimeoffLabelText, @"")];
         }
     }
    [self.approvalsTableView reloadData];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = RPLocalizedString(PREVIOUS_APPROVALS_TITLE_MSG, @"");

}
#pragma mark -
#pragma mark - UITableView Delegates



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [approvalsPermissionArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return Each_Cell_Row_Height_44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InboxCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([InboxCell class]) forIndexPath:indexPath];
    cell.label.font = [self.theme cardContainerHeaderFont];


    NSString *sectionTitle = [approvalsPermissionArray objectAtIndex:indexPath.section];

    if ([sectionTitle isEqualToString:RPLocalizedString(TimeSheetLabelText, @"")])
    {
        cell.label.text=RPLocalizedString(PREVIOUS_TIMESHEETS_APPROVALS, @"") ;
    }

    else if ([sectionTitle isEqualToString:RPLocalizedString(ExpenseLabelText, @"")])
    {

        cell.label.text=RPLocalizedString(PREVIOUS_EXPENSE_APPROVALS, @"") ;

    }
    else if ([sectionTitle isEqualToString:RPLocalizedString(TimeoffLabelText, @"")])
    {

        cell.label.text=RPLocalizedString(PREVIOUS_TIMEOFFS_APPROVALS, @"") ;

    }


    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	return cell;

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    if ([self.reachabilityMonitor isNetworkReachable] == NO)
    {
        [Util showOfflineAlert];
        return;
    }
    CLS_LOG(@"-----Row selected on ApprovalsCountViewController -----");
    NSString *sectionTitle = [approvalsPermissionArray objectAtIndex:indexPath.section];

    if ([sectionTitle isEqualToString:RPLocalizedString(TimeSheetLabelText, @"")])
    {

        NSMutableArray *previousTimesheets=[self.approvalsModel getAllPreviousTimesheetsOfApprovalFromDB];

        ApprovalsTimesheetHistoryViewController *approvalHistoryViewCtrl=[self.injector getInstance:[ApprovalsTimesheetHistoryViewController class]];
        [self.notificationCenter removeObserver: approvalHistoryViewCtrl name: PENDING_APPROVALS_TIMESHEET_NOTIFICATION object: nil];
        [self.notificationCenter addObserver: approvalHistoryViewCtrl
                                                 selector: @selector(handlePreviousApprovalsDataReceivedAction)
                                                     name: PENDING_APPROVALS_TIMESHEET_NOTIFICATION
                                                   object: nil];
        [self.navigationController pushViewController:approvalHistoryViewCtrl animated:YES];

        if ([previousTimesheets count]==0)
        {
            [self.spinnerDelegate showTransparentLoadingOverlay];
            [self.approvalsService fetchSummaryOfPreviousTimeSheetApprovalsForUser:self];

        }
        else
            [self.notificationCenter postNotificationName:PENDING_APPROVALS_TIMESHEET_NOTIFICATION object:nil];


        NSString *flurryEvent= [NSString stringWithFormat:@"Timesheet Previous Approval Clicked"];
        if (Util.isRelease)
        {
            NSString *companyName=nil;
            // MOBI-471
            ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
            if ([keychain allCredentialsForService:@"repliconUserCredentials" limit:99] != nil && ![[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] isKindOfClass:[NSNull class]]) {
                NSDictionary *credentials = [[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] objectAtIndex:0];
                if (credentials != nil && ![credentials isKindOfClass:[NSNull class]]) {
                    companyName = [credentials valueForKey:ACKeychainCompanyName];
                }
            }

            [EventTracker.sharedInstance log:flurryEvent withParameters:[NSDictionary dictionaryWithObjectsAndKeys:companyName,@"CName", nil]];

        }

        [self.approvalsTableView deselectRowAtIndexPath:indexPath animated:NO];
 
    }
    else if ([sectionTitle isEqualToString:RPLocalizedString(ExpenseLabelText, @"")])
    {


        NSMutableArray *previousExpensesheets=[self.approvalsModel getAllPreviousExpensesheetsOfApprovalFromDB];

        ApprovalsExpenseHistoryViewController *approvalHistoryViewCtrl=[self.injector getInstance:[ApprovalsExpenseHistoryViewController class]];
        [self.notificationCenter removeObserver: approvalHistoryViewCtrl name: PENDING_APPROVALS_EXPENSE_NOTIFICATION object: nil];
        [self.notificationCenter addObserver: approvalHistoryViewCtrl
                                                 selector: @selector(handlePreviousApprovalsDataReceivedAction)
                                                     name: PENDING_APPROVALS_EXPENSE_NOTIFICATION
                                                   object: nil];
        [self.navigationController pushViewController:approvalHistoryViewCtrl animated:YES];

        if ([previousExpensesheets count]==0)
        {
            [self.spinnerDelegate showTransparentLoadingOverlay];
            [self.approvalsService fetchSummaryOfPreviousExpenseApprovalsForUser:self];

        }
        else
            [self.notificationCenter postNotificationName:PENDING_APPROVALS_EXPENSE_NOTIFICATION object:nil];



        NSString *flurryEvent= [NSString stringWithFormat:@"Expense Previous Approval Clicked"];
        if (Util.isRelease)
        {
            NSString *companyName=nil;
            // MOBI-471
            ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
            if ([keychain allCredentialsForService:@"repliconUserCredentials" limit:99] != nil && ![[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] isKindOfClass:[NSNull class]]) {
                NSDictionary *credentials = [[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] objectAtIndex:0];
                if (credentials != nil && ![credentials isKindOfClass:[NSNull class]]) {
                    companyName = [credentials valueForKey:ACKeychainCompanyName];
                }
            }
            
            [EventTracker.sharedInstance log:flurryEvent withParameters:[NSDictionary dictionaryWithObjectsAndKeys:companyName,@"CName", nil]];
        }

        [self.approvalsTableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    else if ([sectionTitle isEqualToString:RPLocalizedString(TimeoffLabelText, @"")])
    {

        NSMutableArray *previousTimeOffs=[self.approvalsModel getAllPreviousTimeOffsOfApprovalFromDB];

        ApprovalsTimeOffHistoryViewController *approvalHistoryViewCtrl=[self.injector getInstance:[ApprovalsTimeOffHistoryViewController class]];
        [self.notificationCenter removeObserver: approvalHistoryViewCtrl name: PENDING_APPROVALS_TIMEOFF_NOTIFICATION object: nil];
        [self.notificationCenter addObserver: approvalHistoryViewCtrl
                                                 selector: @selector(handlePreviousApprovalsDataReceivedAction)
                                                     name: PENDING_APPROVALS_TIMEOFF_NOTIFICATION
                                                   object: nil];
        [self.navigationController pushViewController:approvalHistoryViewCtrl animated:YES];

        if ([previousTimeOffs count]==0)
        {
            [self.spinnerDelegate showTransparentLoadingOverlay];
            [self.approvalsService fetchSummaryOfPreviousTimeOffsApprovalsForUser:self];

        }
        else
            [self.notificationCenter postNotificationName:PENDING_APPROVALS_TIMEOFF_NOTIFICATION object:nil];






        NSString *flurryEvent= [NSString stringWithFormat:@"TimeOff Previous Approval Clicked"];
        if (Util.isRelease)
        {
            NSString *companyName=nil;
            // MOBI-471
            ACSimpleKeychain *keychain = [ACSimpleKeychain defaultKeychain];
            if ([keychain allCredentialsForService:@"repliconUserCredentials" limit:99] != nil && ![[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] isKindOfClass:[NSNull class]]) {
                NSDictionary *credentials = [[keychain allCredentialsForService:@"repliconUserCredentials" limit:99] objectAtIndex:0];
                if (credentials != nil && ![credentials isKindOfClass:[NSNull class]]) {
                    companyName = [credentials valueForKey:ACKeychainCompanyName];
                }
            }

            [EventTracker.sharedInstance log:flurryEvent withParameters:[NSDictionary dictionaryWithObjectsAndKeys:companyName,@"CName", nil]];
        }

        [self.approvalsTableView deselectRowAtIndexPath:indexPath animated:NO];
    }

}
#pragma mark -
#pragma mark - Other methods

-(void)goBack:(id)sender
{
	[[[UIApplication sharedApplication]delegate]performSelector:@selector(flipToHomeViewController)];
}




#pragma mark -
#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.approvalsTableView=nil;
    self.leftButton=nil;
}




@end
