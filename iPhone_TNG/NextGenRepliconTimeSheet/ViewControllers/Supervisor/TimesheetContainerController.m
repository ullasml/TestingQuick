#import "TimesheetContainerController.h"
#import "TimesheetDetailsController.h"
#import "ChildControllerHelper.h"
#import "AstroAwareTimesheet.h"
#import "TimesheetRepository.h"
#import "SpinnerDelegate.h"
#import <Blindside/Blindside.h>
#import <KSDeferred/KSPromise.h>
#import "UnavailableFormatTimesheetController.h"
#import "TimesheetContainerController+RightBarButtonAction.h"
#import <KSDeferred/KSDeferred.h>
#import "TimesheetForUserWithWorkHours.h"
#import "ApprovalsService.h"
#import "ApprovalsModel.h"
#import "ApprovalsScrollViewController.h"
#import "WrongConfigurationMessageViewController.h"
#import "TimesheetPeriod.h"
#import "OEFTypesRepository.h"
#import "UIViewController+NavigationBar.h"
#import "TimesheetRepository.h"
#import "Timesheet.h"
#import "TimesheetInfo.h"
#import "UserPermissionsStorage.h"
#import <repliconkit/AppConfig.h>

@interface TimesheetContainerController ()

@property (nonatomic) ChildControllerHelper *childControllerHelper;
@property (nonatomic, weak) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic) TimesheetRepository *timesheetRepository;
@property (nonatomic) OEFTypesRepository *oefTypesRepository;
@property (nonatomic) WidgetTimesheetRepository *widgetTimesheetRepository;
@property (nonatomic) TimesheetForUserWithWorkHours *timesheet;
@property (nonatomic) UIActivityIndicatorView *spinnerView;
@property (nonatomic) UIActivityIndicatorView *spinnerViewForActionButtonFlow;
@property (nonatomic) id<BSInjector> injector;
@property (nonatomic) ApprovalsModel *approvalsModel;
@property (nonatomic) ApprovalsService *approvalsService;
@property (nonatomic) NSNotificationCenter *notificationCenter;
@property (nonatomic) AstroAwareTimesheet *astroAwareTimesheet;
@property (nonatomic) AppConfig *appConfig;

@end

static NSString * const AstroPunchWidgetPolicyURI = @"urn:replicon:policy:timesheet:widget-timesheet:time-pair-punch-entry";

@implementation TimesheetContainerController

- (instancetype)initWithChildControllerHelper:(ChildControllerHelper *)childControllerHelper
                    widgetTimesheetRepository:(WidgetTimesheetRepository *)widgetTimesheetRepository
                          timesheetRepository:(TimesheetRepository *)timesheetRepository
                           notificationCenter:(NSNotificationCenter *)notificationCenter
                           oefTypesRepository:(OEFTypesRepository *)oefTypesRepository
                             approvalsService:(ApprovalsService *)approvalsService
                              spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                               approvalsModel:(ApprovalsModel *)approvalsModel
                                    appConfig:(AppConfig *)appConfig {
    self = [super init];
    if (self)
    {
        self.childControllerHelper = childControllerHelper;
        self.widgetTimesheetRepository = widgetTimesheetRepository;
        self.timesheetRepository = timesheetRepository;
        self.notificationCenter = notificationCenter;
        self.oefTypesRepository = oefTypesRepository;
        self.approvalsService = approvalsService;
        self.spinnerDelegate = spinnerDelegate;
        self.approvalsModel = approvalsModel;
        self.appConfig = appConfig;
    }

    return self;
}


- (void)setupWithTimesheet:(TimesheetForUserWithWorkHours *)timesheet
{
    self.timesheet = timesheet;
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

    [self manageRightBarButtonView];
    
    self.title=self.timesheet.userName;

    [self setupNavigationBarWithTitle:self.timesheet.userName backButtonTitle:RPLocalizedString(@"Back", @"Back")];
    
    [self.oefTypesRepository fetchOEFTypesWithUserURI:self.timesheet.userURI];
    
    BOOL isTimesheetWidgetPlatformFlag = self.appConfig.getTimesheetWidgetPlatform;
    if (isTimesheetWidgetPlatformFlag) {
        KSPromise *widgetCapabilitiesPromise = [self.timesheetRepository fetchTimesheetCapabilitiesWithURI:self.timesheet.uri];
        [widgetCapabilitiesPromise then:^id(NSNumber* isWidgetPlatformSupportedValue) {
            BOOL isWidgetPlatformSupported = [isWidgetPlatformSupportedValue boolValue];
            if (isWidgetPlatformSupported) {
                KSPromise *widgetTimesheetPromise = [self.widgetTimesheetRepository fetchWidgetTimesheetForTimesheetWithUri:self.timesheet.uri];
                [widgetTimesheetPromise then:^id(WidgetTimesheet* widgetTimesheet) {
                    [self.spinnerDelegate hideTransparentLoadingOverlay];
                    WidgetTimesheetDetailsController * timesheetDetailsController = [self.injector getInstance:[WidgetTimesheetDetailsController class]];
                    [timesheetDetailsController setupWithWidgetTimesheet:widgetTimesheet delegate:self hasBreakAccess:widgetTimesheet.approvalTimePunchCapabilities.hasBreakAccess isSupervisorContext:YES userUri:self.timesheet.userURI];
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

- (void)createSpinnerView {
    self.spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.spinnerView startAnimating];
    self.spinnerView.hidden = YES;
    [self.spinnerView setAccessibilityLabel:@"uia_view_timesheet_spinner_identifier"];
}

- (void)createRightBarActionSpinnerView {
    self.spinnerViewForActionButtonFlow = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.spinnerViewForActionButtonFlow startAnimating];
    self.spinnerViewForActionButtonFlow.hidden = YES;
    [self.spinnerViewForActionButtonFlow setAccessibilityLabel:@"uia_view_timesheet_spinner_right_barbutton_identifier"];
}

- (void)manageRightBarButtonView {
    [self createSpinnerView];
    [self showSpinnerView:self.spinnerView];
    [self createRightBarActionSpinnerView];
}


- (UIViewController *)setupLegacyApprovalsScrollViewController
{
    ApprovalsScrollViewController *scrollViewController = [self.injector getInstance:[ApprovalsScrollViewController class]];
    self.title = RPLocalizedString(TimeSheetsTabbarTitle, TimeSheetsTabbarTitle);
    NSArray *dbTimesheetArray = [self.approvalsModel getAllPreviousTimesheetDaySummaryFromDBForTimesheet:self.timesheet.uri];
    NSArray *dbTimesheetInfoArray = [self.approvalsModel getTimeSheetInfoSheetIdentityForPrevious:self.timesheet.uri];
    BOOL isWidgetTimesheet = NO;
    if ([dbTimesheetInfoArray count] > 0)
    {
        NSString *timesheetFormat = [[dbTimesheetInfoArray objectAtIndex:0] objectForKey:@"timesheetFormat"];
        if (timesheetFormat != nil && ![timesheetFormat isKindOfClass:[NSNull class]] && ([timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET]))
        {
            isWidgetTimesheet = YES;
        }
    }
    [scrollViewController setIndexCount:0];
    scrollViewController.listOfPendingItemsArray=[self.approvalsModel getPreviousApprovalDataForTimesheetSheetURI:self.timesheet.uri];
    scrollViewController.currentViewIndex = 0;
    scrollViewController.sheetStatus = WAITING_FOR_APRROVAL_STATUS;
    if (scrollViewController.listOfPendingItemsArray.count>0)
    {
        NSDictionary *selectedTimesheetDict=scrollViewController.listOfPendingItemsArray[0];
        scrollViewController.sheetStatus = selectedTimesheetDict[@"approvalStatus"];
    }
    scrollViewController.delegate = self;
    scrollViewController.isGen4User = isWidgetTimesheet;
    scrollViewController.hasPreviousTimeSheets = FALSE;
    scrollViewController.hasNextTimeSheets = FALSE;


    [scrollViewController setHidesBottomBarWhenPushed:NO];
    [self.notificationCenter removeObserver:scrollViewController
                                       name:APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION
                                     object:nil];
    [self.notificationCenter addObserver:scrollViewController
                                selector:@selector(viewAllEntriesScreen:)
                                    name:APPROVALS_TIMESHEET_SUMMARY_RECEIVED_NOTIFICATION
                                  object:nil];

    if ([dbTimesheetArray count] == 0)
    {
        [self.spinnerDelegate showTransparentLoadingOverlay];
        NSString *timesheetURI = self.timesheet.uri;
            [self.approvalsModel deleteAllTimeentriesForTimesheetUri:timesheetURI isPending:NO];
            [self.approvalsModel deleteAllTimesheetDaySummaryForTimesheetUri:timesheetURI isPending:NO];
        [self.approvalsService fetchPendingTimeSheetSummaryDataForTimesheet:timesheetURI
                                                               withDelegate:self];
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


-(void)displayUserActionsButtonsForNonAstroFlow:(AstroAwareTimesheet *)timesheet
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
                                                                                action: @selector(approvalsTimesheetSubmitAction:)];
        self.navigationItem.rightBarButtonItem = submitApprovalAction;
    }

    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

-(KSPromise*)timesheetInfoPromise
{
    KSDeferred *deferred =  [KSDeferred defer];
    KSPromise *timesheetInfoPromise = [self.timesheetRepository fetchTimesheetInfoForTimsheetUri:self.astroAwareTimesheet.uri];
    [timesheetInfoPromise then:^id(id <Timesheet> timesheetInfo) {
        [deferred resolveWithValue:timesheetInfo];
        return nil;
    } error:^id(NSError *error) {
        self.spinnerView.hidden = true;
        [deferred rejectWithError:error];
        return nil;
    }];
    return deferred.promise;
}

- (BOOL)isValidWidgetCombination {
    
    BOOL isValidWidgetCombination = TRUE;
    BOOL isStandardWidget=NO;
    BOOL isInOutWidget=NO;
    BOOL isExtInOutWidget=NO;
    BOOL timePunchWidget = NO;
    NSMutableArray *enabledWidgetsUriArray = [self.approvalsModel getAllPreviousEnabledWidgetsUriDetailsFromDBForTimesheetUri:self.timesheet.uri];
    for(NSDictionary *enabledWidgetDict in enabledWidgetsUriArray)
    {
        NSString *widgetUri=enabledWidgetDict[@"widgetUri"];
        if ([widgetUri isEqualToString:STANDARD_WIDGET_URI])
        {
            isStandardWidget=YES;
        }
        else if ([widgetUri isEqualToString:INOUT_WIDGET_URI])
        {
            isInOutWidget=YES;
        }
        else if ([widgetUri isEqualToString:EXT_INOUT_WIDGET_URI])
        {
            isExtInOutWidget=YES;
        }
        else if ([widgetUri isEqualToString:PUNCH_WIDGET_URI])
        {
            timePunchWidget=YES;
        }
    }
    
    if ([enabledWidgetsUriArray count] == 0)
    {
        isValidWidgetCombination = FALSE;
    }
    else if([enabledWidgetsUriArray count] == 1 && timePunchWidget)
    {
        isValidWidgetCombination = FALSE;
    }
    
    else if ((isStandardWidget && isExtInOutWidget) || (isInOutWidget && isExtInOutWidget))
    {
        isValidWidgetCombination = FALSE;
    }
    
    return isValidWidgetCombination;
}


#pragma mark - TimesheetDetailsControllerDelegate

- (void)timeSheetDetailsControllerDidCompleteRequestForTimeSheetSummary:(TimePeriodSummary *)timePeriodSummary
{
    [self displayUserActionsButtons:timePeriodSummary];
}

#pragma mark - WidgetTimesheetDetailsControllerDelegate

-(void)widgetTimesheetDetailsController:(WidgetTimesheetDetailsController *)controller actionButton:(UIBarButtonItem *)actionButton
{
    self.navigationItem.rightBarButtonItem = actionButton;
}

- (KSPromise*)timesheetDetailsControllerRequestsLatestPunches:(TimesheetDetailsController *)timesheetDetailsController
{
    return [self timesheetInfoPromise];
}


#pragma mark - Private

-(void)setUpAstroOrNonAstroFlow
{
    KSPromise *timesheetPromise = [self.timesheetRepository fetchTimesheetWithURI:self.timesheet.uri];
    
    [timesheetPromise then:^id(AstroAwareTimesheet *timesheet) {
        [self.spinnerDelegate hideTransparentLoadingOverlay];
        UIViewController *childViewController;
        self.astroAwareTimesheet = timesheet;
        
        if([timesheet astroUserType] == TimesheetAstroUserTypeAstro)
        {
            NSDictionary *timePunchCapabilities =timesheet.timesheetDictionary[@"d"][@"capabilities"][@"timePunchCapabilities"];
            BOOL hasProjectAccess = [timePunchCapabilities[@"hasProjectAccess"] boolValue];
            BOOL hasClientAccess = [timePunchCapabilities[@"hasClientAccess"] boolValue];
            BOOL hasActivityAccess = [timePunchCapabilities[@"hasActivityAccess"] boolValue];
            BOOL wrongConfigurationUser = (hasProjectAccess && hasClientAccess && hasActivityAccess);
            if (wrongConfigurationUser)
            {
                childViewController = [self.injector getInstance:[WrongConfigurationMessageViewController class]];
                [self.childControllerHelper addChildController:childViewController toParentController:self inContainerView:self.view];
            }
            else
            {
                KSPromise *timesheetPromise = [self.timesheetRepository fetchTimesheetInfoForTimsheetUri:self.timesheet.uri];
                [timesheetPromise then:^id(TimesheetInfo *timesheetInfo) {
                    TimesheetDetailsController * timesheetDetailsController = [self.injector getInstance:[TimesheetDetailsController class]];
                    NSDictionary *timePunchCapabilities =self.astroAwareTimesheet.timesheetDictionary[@"d"][@"capabilities"][@"timePunchCapabilities"];
                    BOOL hasBreakAccess = [timePunchCapabilities[@"hasBreakAccess"] boolValue];
                    [timesheetDetailsController setupWithSpinnerOperationsCounter:nil
                                                                         delegate:self
                                                                        timesheet:timesheetInfo
                                                                hasPayrollSummary:self.astroAwareTimesheet.hasPayrollSummary
                                                                   hasBreakAccess:hasBreakAccess
                                                                           cursor:nil
                                                                          userURI:self.timesheet.userURI
                                                                            title:self.timesheet.userName];
                    [self.childControllerHelper addChildController:timesheetDetailsController
                                                toParentController:self
                                                   inContainerView:self.view];
                    
                    return nil;
                } error:^id(NSError *error) {
                    return nil;
                }];
            }
        }
        else
        {
            [self.approvalsModel resetAndSaveTeamTimesheets:timesheet.timesheetDictionary andTimesheetForUserWithWorkHours:self.timesheet];
            
            TeamTimeModel *timeModel = [[TeamTimeModel alloc]init];
            if (timesheet.timesheetDictionary) {
                NSDictionary *capabilities = timesheet.timesheetDictionary[@"d"][@"capabilities"];
                if (capabilities !=nil && capabilities != (id)[NSNull null]) {
                    NSMutableDictionary *timePunchCapabilities = capabilities[@"timePunchCapabilities"];
                    [timeModel saveTeamTimeUserCapabilitiesFromApiToDB:timePunchCapabilities forUserUri:self.timesheet.userURI];
                }
            }
            
            [self.approvalsService handleApprovalsTimeSheetSummaryDataForTimesheet:@{@"response":timesheet.timesheetDictionary} module:APPROVALS_PREVIOUS_TIMESHEETS_MODULE];
            
            childViewController = [self setupLegacyApprovalsScrollViewController];
            BOOL isPunchWidgetUser = [self isPunchWidgetUser:timesheet.timesheetDictionary[@"d"][@"capabilities"][@"widgetTimesheetCapabilities"]];
            BOOL isValidWidget = [self isValidWidgetCombination];
            
            if (isPunchWidgetUser && isValidWidget)
            {
                [self displayUserActionsButtonsForNonAstroFlow:timesheet];
            }
            else{
                self.navigationItem.rightBarButtonItem = nil;
            }
            [self.childControllerHelper addChildController:childViewController toParentController:self inContainerView:self.view];
        }
        
        return timesheet;
    } error:^id(NSError *error) {
        [self.spinnerDelegate hideTransparentLoadingOverlay];
        
        return error;
    }];
}

@end
