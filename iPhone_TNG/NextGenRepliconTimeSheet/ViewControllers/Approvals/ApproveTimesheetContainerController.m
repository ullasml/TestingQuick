#import "ApproveTimesheetContainerController.h"
#import "Timesheet.h"
#import "TimesheetRepository.h"
#import "ChildControllerHelper.h"
#import <Blindside/BSInjector.h>
#import "TimesheetDetailsController.h"
#import <KSDeferred/KSDeferred.h>
#import "ApprovalsScrollViewController.h"
#import "LegacyTimesheetApprovalInfo.h"
#import "ApprovalsModel.h"
#import "ApprovalsService.h"
#import "SpinnerDelegate.h"
#import "AstroAwareTimesheet.h"
#import "WrongConfigurationMessageViewController.h"
#import "TimesheetPeriod.h"
#import "OEFTypesRepository.h"
#import "UserPermissionsStorage.h"

@interface ApproveTimesheetContainerController ()

@property (nonatomic) TimesheetRepository *timesheetRepository;
@property (nonatomic) WidgetTimesheetRepository *widgetTimesheetRepository;
@property (nonatomic) ChildControllerHelper *childControllerHelper;
@property (nonatomic) id<Timesheet> userlessTimesheet;
@property (nonatomic) LegacyTimesheetApprovalInfo *legacyTimesheetApprovalInfo;
@property (nonatomic) ApprovalsModel *approvalsModel;
@property (nonatomic) ApprovalsService *approvalsService;
@property (nonatomic) NSNotificationCenter *notificationCenter;
@property (nonatomic, copy) NSString *astroTitle;
@property (nonatomic, copy) NSString *userUri;
@property (nonatomic, weak) id<ApproveTimesheetContainerControllerDelegate> delegate;
@property (nonatomic, weak) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic) OEFTypesRepository *oefTypesRepository;
@property (nonatomic) AppConfig *appConfig;
@property (nonatomic, weak) id<BSInjector> injector;

@end


static NSString * const AstroPunchWidgetPolicyURI = @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry";

@implementation ApproveTimesheetContainerController

- (instancetype)initWithTimesheetRepository:(TimesheetRepository *)timesheetRepository
                  widgetTimesheetRepository:(WidgetTimesheetRepository *)widgetTimesheetRepository
                      childControllerHelper:(ChildControllerHelper *)childControllerHelper
                         notificationCenter:(NSNotificationCenter *)notificationCenter
                           approvalsService:(ApprovalsService *)approvalsService
                            spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                             approvalsModel:(ApprovalsModel *)approvalsModel
                         oefTypesRepository:(OEFTypesRepository *)oefTypesRepository
                                  appConfig:(AppConfig *)appConfig {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.widgetTimesheetRepository = widgetTimesheetRepository;
        self.timesheetRepository = timesheetRepository;
        self.childControllerHelper = childControllerHelper;
        self.notificationCenter = notificationCenter;
        self.approvalsService = approvalsService;
        self.spinnerDelegate = spinnerDelegate;
        self.approvalsModel = approvalsModel;
        self.oefTypesRepository = oefTypesRepository;
        self.appConfig = appConfig;
    }
    return self;
}

- (void)setupWithLegacyTimesheetApprovalInfo:(LegacyTimesheetApprovalInfo *)legacyTimesheetApprovalInfo
                                   timesheet:(id<Timesheet>)timesheet
                                    delegate:(id<ApproveTimesheetContainerControllerDelegate>)delegate
                                        title:(NSString *)title andUserUri:(NSString *)userUri
{
    self.legacyTimesheetApprovalInfo = legacyTimesheetApprovalInfo;
    self.userlessTimesheet = timesheet;
    self.delegate = delegate;
    self.astroTitle = title;
    self.userUri = userUri;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;

    self.view.backgroundColor = [UIColor whiteColor];

    [self.spinnerDelegate showTransparentLoadingOverlay];
    
    [self.oefTypesRepository fetchOEFTypesWithUserURI:self.userUri];
    
    BOOL isWidgetPlatformSupported = self.appConfig.getTimesheetWidgetPlatform;
    if (isWidgetPlatformSupported) {
        KSPromise *widgetCapabilitiesPromise = [self.timesheetRepository fetchTimesheetCapabilitiesWithURI:self.userlessTimesheet.uri];
        [widgetCapabilitiesPromise then:^id(NSNumber* isWidgetPlatformSupportedValue) {
            BOOL isWidgetPlatformSupported = [isWidgetPlatformSupportedValue boolValue];
            if (isWidgetPlatformSupported) {
                KSPromise *widgetTimesheetPromise = [self.widgetTimesheetRepository fetchWidgetTimesheetForTimesheetWithUri:self.userlessTimesheet.uri];
                [widgetTimesheetPromise then:^id(WidgetTimesheet* widgetTimesheet) {
                    [self.spinnerDelegate hideTransparentLoadingOverlay];
                    WidgetTimesheetDetailsController * timesheetDetailsController = [self.injector getInstance:[WidgetTimesheetDetailsController class]];
                    self.title = self.astroTitle;

                    if (self.legacyTimesheetApprovalInfo.isFromPendingApprovals)
                    {
                        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(@"Approve", nil)
                                                                                                  style:UIBarButtonItemStyleDone
                                                                                                 target:self
                                                                                                 action:@selector(didTapApproveButton:)];
                    }
                    else if (self.legacyTimesheetApprovalInfo.isFromPreviousApprovals)
                    {
                        self.navigationItem.rightBarButtonItem = nil;
                    }
                    [timesheetDetailsController setupWithWidgetTimesheet:widgetTimesheet delegate:nil hasBreakAccess:widgetTimesheet.approvalTimePunchCapabilities.hasBreakAccess isSupervisorContext:YES userUri:self.userUri];
                    [self.childControllerHelper addChildController:timesheetDetailsController
                                                toParentController:self
                                                   inContainerView:self.view];
                    
                    return nil;
                } error:^id(NSError *error) {
                    [self.spinnerDelegate hideTransparentLoadingOverlay];
                    return error;
                }];
            }
            else{
                [self setUpAstroOrNonAstroFlow];
            }
            return nil;
        } error:^id(NSError *error) {
            [self.spinnerDelegate hideTransparentLoadingOverlay];
            return error;
        }];
    }
    else{
        [self setUpAstroOrNonAstroFlow];
    }
}


#pragma mark - Actions

- (void)didTapApproveButton:(id)sender
{
    [self.delegate approveTimesheetContainerController:self didApproveTimesheet:self.userlessTimesheet];
}

#pragma mark - Private

- (UIViewController *)setupAstroTimesheetDetailsController:(BOOL)hasPayRollSummary hasBreakAccess:(BOOL)hasBreakAccess timesheet:(id <Timesheet>)timesheet
{
    self.title = self.astroTitle;
    [self.spinnerDelegate hideTransparentLoadingOverlay];
    TimesheetDetailsController *timesheetDetailsController = [self.injector getInstance:[TimesheetDetailsController class]];
    [timesheetDetailsController setupWithSpinnerOperationsCounter:nil
                                                         delegate:self
                                                        timesheet:timesheet
                                                hasPayrollSummary:hasPayRollSummary
                                                   hasBreakAccess:hasBreakAccess
                                                           cursor:nil
                                                          userURI:self.userUri
                                                            title:nil];


    if (self.legacyTimesheetApprovalInfo.isFromPendingApprovals)
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(@"Approve", nil)
                                                                                  style:UIBarButtonItemStyleDone
                                                                                 target:self
                                                                                 action:@selector(didTapApproveButton:)];
    }
    else if (self.legacyTimesheetApprovalInfo.isFromPreviousApprovals)
    {
        self.navigationItem.rightBarButtonItem = nil;
    }


    return timesheetDetailsController;
}


- (UIViewController *)setupLegacyApprovalsScrollViewController
{
    ApprovalsScrollViewController *scrollViewController = [self.injector getInstance:[ApprovalsScrollViewController class]];
    self.title = RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle);
    NSInteger indexCount = self.legacyTimesheetApprovalInfo.indexCount;
    NSArray *allPendingTSArray = self.legacyTimesheetApprovalInfo.allApprovalsTSArray;
    NSArray *dbTimesheetArray = self.legacyTimesheetApprovalInfo.dbTimesheetArray;
    BOOL isWidgetTimesheet = self.legacyTimesheetApprovalInfo.isWidgetTimesheet;
    NSInteger countOfUsers = self.legacyTimesheetApprovalInfo.countOfUsers;
    id delegate = self.legacyTimesheetApprovalInfo.delegate;

    [scrollViewController setIndexCount:indexCount];
    [scrollViewController setListOfPendingItemsArray:allPendingTSArray];
    scrollViewController.currentViewIndex = 0;
    scrollViewController.sheetStatus = WAITING_FOR_APRROVAL_STATUS;
    if (scrollViewController.listOfPendingItemsArray.count>0)
    {
        NSDictionary *selectedTimesheetDict=scrollViewController.listOfPendingItemsArray[indexCount];
        scrollViewController.sheetStatus = selectedTimesheetDict[@"approvalStatus"];
    }
    scrollViewController.delegate = delegate;
    scrollViewController.isGen4User = isWidgetTimesheet;

    if (indexCount == 0)
    {
        scrollViewController.hasPreviousTimeSheets = FALSE;
    }
    else
    {
        if (self.legacyTimesheetApprovalInfo.isFromPreviousApprovals)
        {
           scrollViewController.hasPreviousTimeSheets = FALSE;
        }
        else
        {
           scrollViewController.hasPreviousTimeSheets = TRUE;
        }

    }

    if (indexCount == countOfUsers - 1 || countOfUsers == 0)
    {
        scrollViewController.hasNextTimeSheets = FALSE;
    }
    else
    {
        scrollViewController.hasNextTimeSheets = TRUE;
    }

    [scrollViewController setHidesBottomBarWhenPushed:NO];
    [self.notificationCenter removeObserver:scrollViewController
                                       name:APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION
                                     object:nil];
    [self.notificationCenter addObserver:scrollViewController
                                selector:@selector(viewAllEntriesScreen:)
                                    name:APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION
                                  object:nil];

    if ([dbTimesheetArray count]==0 )
    {
        NSString *timesheetURI = self.userlessTimesheet.uri;
//        if (isWidgetTimesheet)
//        {
            [self.approvalsModel deleteAllTimeentriesForTimesheetUri:timesheetURI isPending:YES];
            [self.approvalsModel deleteAllTimesheetDaySummaryForTimesheetUri:timesheetURI isPending:YES];
//        }

    
       [self.approvalsService fetchPendingTimeSheetSummaryDataForTimesheet:timesheetURI
                                                               withDelegate:delegate];
    }
    else
    {
        [self.notificationCenter postNotificationName:APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION
                                               object:nil
                                             userInfo:nil];
    }

    return scrollViewController;
}

- (BOOL)isPunchWidgetUser:(NSDictionary *)widgetTimesheetCapabilities
{

    if ([widgetTimesheetCapabilities isEqual:(id)[NSNull null]])
    {

        return NO;
    }
    else
    {
        for (NSDictionary *nextCapability in widgetTimesheetCapabilities) {

            NSString *policyKeyUri = nextCapability[@"policyKeyUri"];
            if ([policyKeyUri isEqualToString:AstroPunchWidgetPolicyURI])
            {
                NSDictionary * policy = nextCapability[@"policyValue"];
                BOOL policyBool = [policy[@"bool"] boolValue];
                if (policyBool)
                {
                    return YES;
                }
            }

        }
    }

    
    return NO;
    
}

-(BOOL)canResubmitForApprovalDetails:(NSDictionary *)approvalDetails
{

    if (approvalDetails!=nil && approvalDetails!=(id)[NSNull null])
    {
        NSArray *approvalDetailsDataArr = approvalDetails[@"history"];

        for (NSDictionary *approvalDetailsDataDict in approvalDetailsDataArr)
        {
            if ([approvalDetailsDataDict[@"action"][@"uri"] isEqualToString:@"urn:replicon:approval-action:submit"])
            {
                return YES;
            }
        }
    }


    return NO;
}

-(void)approvalsTimesheetReopenAction
{
    ApprovalActionsViewController *approvalActionsViewController = (ApprovalActionsViewController *)[self setupLegacyApprovalActionsViewControllerWithAction:@"Reopen"];

    [self.navigationController pushViewController:approvalActionsViewController animated:YES];
}

-(void)approvalsTimesheetSubmitAction
{
    ApprovalActionsViewController *approvalActionsViewController = (ApprovalActionsViewController *)[self setupLegacyApprovalActionsViewControllerWithAction:@"Submit"];

    [self.navigationController pushViewController:approvalActionsViewController animated:YES];
}


- (UIViewController *)setupLegacyApprovalActionsViewControllerWithAction:(NSString *)actionType
{
    ApprovalActionsViewController *approvalActionsViewController = [self.injector getInstance:[ApprovalActionsViewController class]];

    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale=[NSLocale currentLocale];;
    [myDateFormatter setLocale:locale];
    [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    myDateFormatter.dateFormat = @"MMM dd";
    NSString *sheet=[NSString stringWithFormat:@" %@ - %@",[myDateFormatter stringFromDate:self.userlessTimesheet.period.startDate],[myDateFormatter stringFromDate:self.userlessTimesheet.period.endDate]];

    [approvalActionsViewController setUpWithSheetUri:self.userlessTimesheet.uri selectedSheet:sheet allowBlankComments:YES actionType:actionType delegate:self];


    return approvalActionsViewController;
}

-(void)displayUserActionsButtons:(AstroAwareTimesheet *)timesheet
{
    NSDictionary *permittedApprovalActions = timesheet.timesheetDictionary[@"d"][@"permittedApprovalActions"];

    BOOL canReopen = [permittedApprovalActions[@"canReopen"]boolValue];
    BOOL canSubmit = [permittedApprovalActions[@"canSubmit"]boolValue];


    if (canReopen)
    {
        UIBarButtonItem *reopenApprovalAction = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString(Reopen_Button_title, @"")
                                                                                 style: UIBarButtonItemStylePlain
                                                                                target: self
                                                                                action: @selector(approvalsTimesheetReopenAction)];
        self.navigationItem.rightBarButtonItem = reopenApprovalAction;
    }

    else if (canSubmit)
    {

        BOOL canResubmit=[self canResubmitForApprovalDetails:timesheet.timesheetDictionary[@"d"][@"approvalDetails"]];
        NSString *buttonTitle = canResubmit ? RPLocalizedString(Resubmit_Button_title, @"") : RPLocalizedString(Submit_Button_title, @"");

        UIBarButtonItem *submitApprovalAction = [[UIBarButtonItem alloc] initWithTitle:buttonTitle
                                                                                 style: UIBarButtonItemStylePlain
                                                                                target: self
                                                                                action: @selector(approvalsTimesheetSubmitAction)];
        self.navigationItem.rightBarButtonItem = submitApprovalAction;
    }

    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

#pragma mark - TimesheetDetailsControllerDelegate
- (KSPromise*)timesheetDetailsControllerRequestsLatestPunches:(TimesheetDetailsController *)timesheetDetailsController
{
    KSDeferred *deferred =  [KSDeferred defer];
    KSPromise *timesheetInfoPromise = [self.timesheetRepository fetchTimesheetInfoForTimsheetUri:self.userlessTimesheet.uri];
    [timesheetInfoPromise then:^id(id <Timesheet> timesheetInfo) {
        [deferred resolveWithValue:timesheetInfo];
        return nil;
    } error:^id(NSError *error) {
        [deferred rejectWithError:error];
        return nil;
    }];
    return deferred.promise;
}

#pragma mark - Private

-(void)setUpAstroOrNonAstroFlow
{
    KSPromise *userTimesheetPromise = [self.timesheetRepository fetchTimesheetWithURI:self.userlessTimesheet.uri];
    [userTimesheetPromise then:^id(AstroAwareTimesheet *userTimesheet) {
        
        CLS_LOG(@"Response Received (fetchTimesheetWithURI:)::::: %@",userTimesheet.timesheetDictionary);
        if (userTimesheet.astroUserType == TimesheetAstroUserTypeAstro) {
            NSDictionary *timePunchCapabilities =userTimesheet.timesheetDictionary[@"d"][@"capabilities"][@"timePunchCapabilities"];
            BOOL hasProjectAccess = [timePunchCapabilities[@"hasProjectAccess"] boolValue];
            BOOL hasClientAccess = [timePunchCapabilities[@"hasClientAccess"] boolValue];
            BOOL hasActivityAccess = [timePunchCapabilities[@"hasActivityAccess"] boolValue];
            BOOL hasBreakAccess = [timePunchCapabilities[@"hasBreakAccess"] boolValue];
            BOOL wrongConfigurationUser = (hasProjectAccess && hasClientAccess && hasActivityAccess);
            if (wrongConfigurationUser)
            {
                UIViewController *nextViewController = [self.injector getInstance:[WrongConfigurationMessageViewController class]];
                [self.childControllerHelper addChildController:nextViewController toParentController:self inContainerView:self.view];
                [self.spinnerDelegate hideTransparentLoadingOverlay];
            }
            else{
                KSPromise *timesheetInfoPromise = [self.timesheetRepository fetchTimesheetInfoForTimsheetUri:self.userlessTimesheet.uri];
                [timesheetInfoPromise then:^id(id <Timesheet> timesheet) {
                    UIViewController *nextViewController = [self setupAstroTimesheetDetailsController:userTimesheet.hasPayrollSummary hasBreakAccess:hasBreakAccess timesheet:timesheet];
                    [self.childControllerHelper addChildController:nextViewController toParentController:self inContainerView:self.view];
                    return nil;
                } error:^id(NSError *error) {
                    return nil;
                }];
            }
        }
        else {
            
            NSString *moduleName = nil;
            if (self.legacyTimesheetApprovalInfo.isFromPendingApprovals)
            {
                moduleName = APPROVALS_PENDING_TIMESHEETS_MODULE;
            }
            else if (self.legacyTimesheetApprovalInfo.isFromPreviousApprovals)
            {
                moduleName = APPROVALS_PREVIOUS_TIMESHEETS_MODULE;
            }
            
            TeamTimeModel *timeModel = [[TeamTimeModel alloc]init];
            if (userTimesheet.timesheetDictionary) {
                NSDictionary *capabilities = userTimesheet.timesheetDictionary[@"d"][@"capabilities"];
                if (capabilities !=nil && capabilities != (id)[NSNull null]) {
                    NSMutableDictionary *timePunchCapabilities = capabilities[@"timePunchCapabilities"];
                    [timeModel saveTeamTimeUserCapabilitiesFromApiToDB:timePunchCapabilities forUserUri:self.userUri];
                }
            }
            
            [self.approvalsService handleApprovalsTimeSheetSummaryDataForTimesheet:@{@"response":userTimesheet.timesheetDictionary} module:moduleName];
            
            NSArray *dbTimesheetArray=nil;
            if (self.legacyTimesheetApprovalInfo.isFromPendingApprovals)
            {
                dbTimesheetArray = [self.approvalsModel getAllPendingTimesheetDaySummaryFromDBForTimesheet:userTimesheet.uri];
            }
            else if (self.legacyTimesheetApprovalInfo.isFromPreviousApprovals)
            {
                dbTimesheetArray = [self.approvalsModel getAllPreviousTimesheetDaySummaryFromDBForTimesheet:userTimesheet.uri];
            }
            
            if (dbTimesheetArray!=nil && ![dbTimesheetArray isKindOfClass:[NSNull class]])
            {
                [self.legacyTimesheetApprovalInfo setDatabaseTimesheetArray:dbTimesheetArray];
            }
            
            UIViewController *nextViewController = [self setupLegacyApprovalsScrollViewController];
            BOOL isPunchWidgetUser = [self isPunchWidgetUser:userTimesheet.timesheetDictionary[@"d"][@"capabilities"][@"widgetTimesheetCapabilities"]];
            
            if (isPunchWidgetUser)
            {
                [self displayUserActionsButtons:userTimesheet];
            }
            [self.childControllerHelper addChildController:nextViewController toParentController:self inContainerView:self.view];
        }
        
        
        return nil;
    } error:^id(NSError *error) {
        [self.spinnerDelegate hideTransparentLoadingOverlay];
        return nil;
    }];
}

@end
