#import "TimesheetDetailsSeriesController.h"
#import "TimesheetRepository.h"
#import "TimesheetDetailsController.h"
#import <Blindside/BSInjector.h>
#import "ChildControllerHelper.h"
#import <KSDeferred/KSPromise.h>
#import <KSDeferred/KSDeferred.h>
#import "UserSession.h"
#import "UserPermissionsStorage.h"
#import "TimesheetDetailsSeriesController+RightBarButtonAction.h"
#import "TimeSummaryRepository.h"
#import "TimesheetPeriod.h"
#import "TimePeriodSummary.h"
#import "UIViewController+NavigationBar.h"
#import "DateProvider.h"
#import "TimesheetInfo.h"
#import "IndexCursor.h"
#import "TimesheetActionRequestBodyProvider.h"

@interface TimesheetDetailsSeriesController ()

@property (nonatomic) TimesheetActionRequestBodyProvider *timesheetActionRequestBodyProvider;
@property (nonatomic) UserPermissionsStorage *userPermissionsStorage;
@property (nonatomic) ChildControllerHelper *childControllerHelper;
@property (nonatomic) TimesheetRepository *timesheetRepository;
@property (nonatomic) id<UserSession> userSession;
@property (nonatomic) KSPromise *timesheetPromise;
@property (nonatomic) id<BSInjector> injector;
@property (nonatomic) UIActivityIndicatorView *spinnerView;
@property (nonatomic) TimesheetInfo *timesheetInfo;
@property (nonatomic) NSString *timeSheetUri;
@property (nonatomic) TimeSummaryRepository *timeSummaryRepository;
@property (nonatomic) TimePeriodSummary *timePeriodSummary;
@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic, weak) id<SpinnerDelegate> spinnerDelegate;

@end


@implementation TimesheetDetailsSeriesController


- (instancetype)initWithTimesheetActionRequestBodyProvider:(TimesheetActionRequestBodyProvider *)timesheetActionRequestBodyProvider
                                    userPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                                     childControllerHelper:(ChildControllerHelper *)childControllerHelper
                                     timeSummaryRepository:(TimeSummaryRepository *)timeSummaryRepository
                                       timesheetRepository:(TimesheetRepository *)timesheetRepository
                                           spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                                               userSession:(id <UserSession>)userSession
                                              dateProvider:(DateProvider *)dateProvider {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.timesheetActionRequestBodyProvider = timesheetActionRequestBodyProvider;
        self.timeSummaryRepository = timeSummaryRepository;
        self.userPermissionsStorage = userPermissionsStorage;
        self.childControllerHelper = childControllerHelper;
        self.timesheetRepository = timesheetRepository;
        self.spinnerDelegate = spinnerDelegate;
        self.dateProvider = dateProvider;
        self.userSession = userSession;
    }
    return self;
}

#pragma mark - Dealloc

- (void)dealloc
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setUpRightBarButtonViewWithActivityIndicator];
    
    TimesheetDetailsController *timesheetDetailsController = [self.injector getInstance:[TimesheetDetailsController class]];
    [self.childControllerHelper addChildController:timesheetDetailsController
                                toParentController:self
                                   inContainerView:self.view];
    
    [self setupNavigationBarWithTitle:RPLocalizedString(@"My Timesheet", nil) backButtonTitle:RPLocalizedString(@"Back", nil)];
    self.timesheetPromise = [self.timesheetRepository fetchTimesheetInfoForDate:self.dateProvider.date];
    [self.timesheetPromise then:^id(TimesheetInfo *timesheetInfo) {
        self.timesheetInfo = timesheetInfo;
        IndexCursor *indexCursor = [self.injector getInstance:[IndexCursor class]];
        [indexCursor setUpWithCurrentTimesheet:timesheetInfo olderTimesheet:nil];
        [self refreshTimesheetDetailsControllerWithTimesheet:timesheetInfo cursor:indexCursor];
        return nil;
    } error:^id(NSError *error) {
        self.spinnerView.hidden = true;
        return nil;
    }];
}

- (void)displayNewTimesheetDetailsController
{
    TimesheetPeriod *period = self.timesheetInfo.period;
    [self fetchTimesheetInfoFromDate:period.startDate];
}

#pragma mark - <SpinnerOperationsCounterDelegate>

- (void)spinnerOperationsCounterShouldShowSpinner:(SpinnerOperationsCounter *)spinnerOperationsCounter
{
    self.spinnerView.hidden = NO;
}

- (void)spinnerOperationsCounterShouldHideSpinner:(SpinnerOperationsCounter *)spinnerOperationsCounter
{
    self.spinnerView.hidden = YES;
}

#pragma mark <TimesheetDetailsControllerDelegate>

- (void)timesheetDetailsControllerRequestsPreviousTimesheet:(TimesheetDetailsController *) timesheetDetailsController
{
    [self setUpRightBarButtonViewWithActivityIndicator];
    NSDate *startDate = [self.timesheetInfo.period.startDate dateByAddingDays:-1];
    [self addDummyController];
    [self fetchTimesheetInfoFromDate:startDate];
}

- (void)timesheetDetailsControllerRequestsNextTimesheet:(TimesheetDetailsController *)timesheetDetailsController
{
    [self setUpRightBarButtonViewWithActivityIndicator];
    NSDate *startDate = [self.timesheetInfo.period.endDate dateByAddingDays:1];
    [self addDummyController];
    [self fetchTimesheetInfoFromDate:startDate];
}

- (void)timeSheetDetailsControllerDidCompleteRequestForTimeSheetSummary:(TimePeriodSummary *)timePeriodSummary
{
    [self displayUserActionsButtons:timePeriodSummary];
}

- (KSPromise*)timesheetDetailsControllerRequestsLatestPunches:(TimesheetDetailsController *)timesheetDetailsController
{
    TimesheetPeriod *period = self.timesheetInfo.period;
    KSDeferred *deferred =  [KSDeferred defer];
    KSPromise *timesheetPromise = [self.timesheetRepository fetchTimesheetInfoForDate:period.startDate];
    [timesheetPromise then:^id(TimesheetInfo *timesheetInfo) {
        self.timesheetInfo = timesheetInfo;
        [deferred resolveWithValue:timesheetInfo];
        return nil;
    } error:^id(NSError *error) {
        self.spinnerView.hidden = true;
        [deferred rejectWithError:error];
        return nil;
    }];
    return deferred.promise;
}

#pragma mark - Private

- (void)setUpRightBarButtonViewWithActivityIndicator
{
    self.spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.spinnerView startAnimating];
    self.spinnerView.hidden = YES;
    [self.spinnerView setAccessibilityLabel:@"uia_view_timesheet_spinner_identifier"];
    [self showSpinnerView:self.spinnerView];
}

-(void)fetchTimesheetInfoFromDate:(NSDate*)date
{
    [self.timesheetPromise cancel];
    self.timesheetPromise = [self.timesheetRepository fetchTimesheetInfoForDate:date];
    [self.timesheetPromise then:^id(TimesheetInfo *timesheetInfo) {
        self.timesheetInfo = timesheetInfo;
        IndexCursor *indexCursor = [self.injector getInstance:[IndexCursor class]];
        [indexCursor setUpWithCurrentTimesheet:timesheetInfo olderTimesheet:nil];
        [self refreshTimesheetDetailsControllerWithTimesheet:timesheetInfo cursor:indexCursor];
        return nil;
    } error:^id(NSError *error) {
        self.spinnerView.hidden = true;
        IndexCursor *indexCursor = [self.injector getInstance:[IndexCursor class]];
        [indexCursor setUpWithCurrentTimesheet:nil olderTimesheet:self.timesheetInfo];
        [self refreshTimesheetDetailsControllerWithTimesheet:self.timesheetInfo cursor:indexCursor];
        return nil;
    }];
}

- (void)refreshTimesheetDetailsControllerWithTimesheet:(id <Timesheet>)timesheet cursor:(IndexCursor *)cursor
{
    SpinnerOperationsCounter *spinnerOperationsCounter = [self.injector getInstance:[SpinnerOperationsCounter class]];
    [spinnerOperationsCounter setupWithDelegate:self];
    TimesheetDetailsController *timesheetDetailsController = [self.injector getInstance:[TimesheetDetailsController class]];
    BOOL hasBreakAccess =  [self.userPermissionsStorage breaksRequired];
    [timesheetDetailsController setupWithSpinnerOperationsCounter:spinnerOperationsCounter
                                                         delegate:self
                                                        timesheet:timesheet
                                                hasPayrollSummary:NO
                                                   hasBreakAccess:hasBreakAccess
                                                           cursor:cursor
                                                          userURI:self.userSession.currentUserURI
                                                            title:nil];
    [self.childControllerHelper replaceOldChildController:self.childViewControllers.firstObject
                                   withNewChildController:timesheetDetailsController
                                       onParentController:self
                                          onContainerView:self.view];
    timesheetDetailsController.scrollView.contentInset = UIEdgeInsetsMake([self.topLayoutGuide length], 0, 0, 0);
}

-(void)addDummyController
{
    TimesheetDetailsController *timesheetDetailsController = [self.injector getInstance:[TimesheetDetailsController class]];
    [self.childControllerHelper replaceOldChildController:self.childViewControllers.firstObject
                                   withNewChildController:timesheetDetailsController
                                       onParentController:self
                                          onContainerView:self.view];
    timesheetDetailsController.scrollView.contentInset = UIEdgeInsetsMake([self.topLayoutGuide length], 0, 0, 0);
}

@end
