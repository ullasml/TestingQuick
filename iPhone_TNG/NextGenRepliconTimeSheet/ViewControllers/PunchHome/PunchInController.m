#import <MacTypes.h>
#import "PunchInController.h"
#import "Theme.h"
#import "TimesheetButtonControllerPresenter.h"
#import "TimesheetDetailsController.h"
#import <Blindside/BSInjector.h>
#import "DayTimeSummaryController.h"
#import "DayTimeSummaryControllerProvider.h"
#import "ChildControllerHelper.h"
#import <KSDeferred/KSPromise.h>
#import "ViolationsButtonController.h"
#import "ViolationsSummaryController.h"
#import "SupervisorDashboardSummary.h"
#import "ViolationEmployee.h"
#import <KSDeferred/KSDeferred.h>
#import "InjectorKeys.h"
#import "ViolationRepository.h"
#import "DateProvider.h"
#import "TimesheetDetailsSeriesController.h"
#import "UserSession.h"
#import "WorkHoursStorage.h"
#import "DayTimeSummary.h"
#import "DelayedTodaysPunchesRepository.h"
#import "PunchRepository.h"
#import "TimeLinePunchesSummary.h"


@interface PunchInController ()

@property (weak, nonatomic) IBOutlet UIButton *punchInButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *workHoursContainerView;
@property (weak, nonatomic) IBOutlet UIView *timeLineCardContainerView;
@property (weak, nonatomic) IBOutlet UIView *timesheetButtonContainerView;
@property (weak, nonatomic) IBOutlet UIView *violationsButtonContainerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLineHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *violationsButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *workHoursContainerHeight;

@property (nonatomic) TimesheetButtonControllerPresenter *timesheetButtonControllerPresenter;
@property (nonatomic) DayTimeSummaryControllerProvider *dayTimeSummaryControllerProvider;
@property (nonatomic) ChildControllerHelper *childControllerHelper;
@property (nonatomic) ViolationRepository *violationRepository;
@property (nonatomic) WorkHoursStorage *workHoursStorage;
@property (nonatomic) id<UserSession> userSession;
@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) NSUserDefaults *defaults;
@property (nonatomic) id<Theme> theme;

@property (weak, nonatomic) id<PunchInControllerDelegate> delegate;
@property (nonatomic) KSPromise *serverDidFinishPunchPromise;
@property (nonatomic) KSPromise *punchesPromise;

@property (weak, nonatomic) id<BSInjector> injector;

@end


@implementation PunchInController

- (instancetype)initWithTimesheetButtonControllerPresenter:(TimesheetButtonControllerPresenter *)timesheetButtonControllerPresenter
                          dayTimeSummaryControllerProvider:(DayTimeSummaryControllerProvider *)dayTimeSummaryControllerProvider
                                     childControllerHelper:(ChildControllerHelper *)childControllerHelper
                                       violationRepository:(ViolationRepository *)violationRepository
                                          workHoursStorage:(WorkHoursStorage *)workHoursStorage
                                              dateProvider:(DateProvider *)dateProvider
                                               userSession:(id <UserSession>)userSession
                                                  defaults:(NSUserDefaults *)defaults
                                                     theme:(id <Theme>)theme {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.timesheetButtonControllerPresenter = timesheetButtonControllerPresenter;
        self.dayTimeSummaryControllerProvider = dayTimeSummaryControllerProvider;
        self.childControllerHelper = childControllerHelper;
        self.violationRepository = violationRepository;
        self.workHoursStorage = workHoursStorage;
        self.dateProvider = dateProvider;
        self.userSession = userSession;
        self.defaults = defaults;
        self.theme = theme;
    }
    return self;
}

- (void)setupWithServerDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise
                                    delegate:(id<PunchInControllerDelegate>)delegate
                              punchesPromise:(KSPromise *)punchesPromise
{
    self.serverDidFinishPunchPromise = serverDidFinishPunchPromise;
    self.delegate = delegate;
    self.punchesPromise = punchesPromise;
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

    self.punchInButton.backgroundColor = [self.theme punchInColor];
    self.punchInButton.layer.borderColor = [self.theme punchInButtonBorderColor];
    self.punchInButton.layer.borderWidth = [self.theme punchInButtonBorderWidth];
    self.punchInButton.titleLabel.font = [self.theme punchInButtonTitleFont];
    [self.punchInButton setTitle:RPLocalizedString(@"Clock In", @"Clock In") forState:UIControlStateNormal];
    [self.punchInButton setTitleColor:[self.theme punchInButtonTitleColor] forState:UIControlStateNormal];

    self.workHoursContainerView.backgroundColor = [self.theme childControllerDefaultBackgroundColor];
    self.violationsButtonContainerView.backgroundColor = [self.theme childControllerDefaultBackgroundColor];

    self.workHoursContainerHeight.constant = 109.0;

    NSInteger totalViolationMessagesCount = [[self.defaults objectForKey:@"totalViolationMessagesCount"] integerValue];
    
    ViolationsButtonController *violationsButtonController = [self.injector getInstance:[ViolationsButtonController class]];
    BOOL showViolations = totalViolationMessagesCount>0 ? YES : NO;
    [violationsButtonController setupWithDelegate:self showViolations:showViolations];
    [self.childControllerHelper addChildController:violationsButtonController
                                toParentController:self
                                   inContainerView:self.violationsButtonContainerView];


    id <WorkHours> workHours = [self.workHoursStorage getCombinedWorkHoursSummary];
    DayTimeSummaryController *dayTimeSummaryController = [self.dayTimeSummaryControllerProvider provideInstanceWithPromise:self.serverDidFinishPunchPromise
                                                                                                      placeholderWorkHours:workHours
                                                                                                                  delegate:self];
    [self.childControllerHelper addChildController:dayTimeSummaryController
                                toParentController:self
                                   inContainerView:self.workHoursContainerView];

    NSMutableArray *punches = nil;
    if (self.punchesPromise != nil) {
        [self.punchesPromise then:^id(TimeLinePunchesSummary *timeLinePunchesSummary) {
            NSMutableArray *punches = [timeLinePunchesSummary.timeLinePunches mutableCopy];
            [self addTimelineController:punches];
            return nil;
        } error:^id(NSError *error)
         {
             [self addTimelineController:punches];
             return nil;
         }];
    }
    else{
        [self addTimelineController:punches];
    }

    [self.timesheetButtonControllerPresenter presentTimesheetButtonControllerInContainer:self.timesheetButtonContainerView
                                                                      onParentController:self
                                                                                delegate:self];
    
    [self.punchInButton setAccessibilityIdentifier:@"punch_in_btn"];
    [self.scrollView setAccessibilityIdentifier:@"uia_punch_astro_flow_scroll_view"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    CGFloat width = CGRectGetWidth(self.view.bounds);
    self.widthConstraint.constant = width;
    [self.view layoutIfNeeded];
    self.punchInButton.layer.cornerRadius = CGRectGetWidth(self.punchInButton.bounds) / 2.0f;

}

#pragma mark - <TimesheetButtonControllerDelegate>

- (void)timesheetButtonControllerWillNavigateToTimesheetDetailScreen:(TimesheetButtonController *)timesheetButtonController
{
    TimesheetDetailsSeriesController *timesheetDetailsSeriesController = [self.injector getInstance:[TimesheetDetailsSeriesController class]];
    [self.navigationController pushViewController:timesheetDetailsSeriesController animated:YES];
}

- (void) timesheetButtonControllerWillNavigateToWidgetTimesheetDetailScreen:(TimesheetButtonController *) timesheetButtonController
{
    WidgetTimesheetDetailsSeriesController *timesheetDetailsSeriesController = [self.injector getInstance:[WidgetTimesheetDetailsSeriesController class]];
    [self.navigationController pushViewController:timesheetDetailsSeriesController animated:YES];
}

#pragma mark - <TimesheetDayTimeLineControllerDelegate>

- (void)timesheetDayTimeLineController:(TimesheetDayTimeLineController *)timesheetDayTimeLineController didUpdateHeight:(CGFloat) height
{
    self.timeLineHeightConstraint.constant = height;
}

- (NSDate *)timesheetDayTimeLineControllerDidRequestDate:(TimesheetDayTimeLineController *)timesheetDayTimeLineController
{
    return [self.dateProvider date];
}

#pragma mark - <ViolationsButtonControllerDelegate>

- (void)violationsButtonController:(ViolationsButtonController *)violationsButtonController didSignalIntentToViewViolationSections:(AllViolationSections *)allViolationSections
{
    ViolationsSummaryController *violationsSummaryController = [self.injector getInstance:[ViolationsSummaryController class]];
    KSDeferred *deferred = [[KSDeferred alloc] init];
    [deferred resolveWithValue:allViolationSections];
    [violationsSummaryController setupWithViolationSectionsPromise:deferred.promise
                                                          delegate:self];
    [self.navigationController pushViewController:violationsSummaryController animated:YES];
}

- (KSPromise *)violationsButtonControllerDidRequestUpdatedViolationSectionsPromise:(ViolationsButtonController *)violationsButtonController
{
    return [self.violationRepository fetchAllViolationSectionsForToday];
}

- (void)violationsButtonController:(ViolationsButtonController *)violationsButtonController
                   didUpdateHeight:(CGFloat)height
{
    self.violationsButtonHeightConstraint.constant = height;
}

#pragma mark - <ViolationsSummaryControllerDelegate>

- (KSPromise *)violationsSummaryControllerDidRequestViolationSectionsPromise:(ViolationsSummaryController *)violationsSummaryController
{
    return [self.violationRepository fetchAllViolationSectionsForToday];
}

#pragma mark - <WorkHoursUpdateDelegate>

-(void)dayTimeSummaryController:(DayTimeSummaryController *)dayTimeSummaryController
             didUpdateWorkHours:(id <WorkHours>)workhours
{
    [self.workHoursStorage saveWorkHoursSummary:workhours];
}

#pragma mark - Private

-(void)addTimelineController:(NSMutableArray*)punches
{
    TimesheetDayTimeLineController *timeLineController = [self.injector getInstance:[TimesheetDayTimeLineController class]];
    [timeLineController setupWithPunchChangeObserverDelegate:nil
                                 serverDidFinishPunchPromise:self.serverDidFinishPunchPromise
                                                    delegate:self
                                                     userURI:self.userSession.currentUserURI
                                                    flowType:UserFlowContext
                                                     punches:punches
                                           timeLinePunchFlow:CardTimeLinePunchFlowContext];
    [self.childControllerHelper addChildController:timeLineController
                                toParentController:self
                                   inContainerView:self.timeLineCardContainerView];
}


- (IBAction)didTapPunchInButton:(id)sender
{
    [self.delegate punchInControllerDidPunchIn:self];
}

@end
