#import "ProjectOnBreakController.h"
#import <KSDeferred/KSDeferred.h>
#import "Theme.h"
#import "ButtonStylist.h"
#import <Blindside/BSInjector.h>
#import "LastPunchLabelTextPresenter.h"
#import "LocalPunch.h"
#import "BreakType.h"
#import "TimerProvider.h"
#import "AddressControllerPresenter.h"
#import "DurationStringPresenter.h"
#import "DurationCalculator.h"
#import "Util.h"
#import "TimesheetButtonControllerPresenter.h"
#import "TimesheetDetailsController.h"
#import "DayTimeSummaryControllerProvider.h"
#import "ChildControllerHelper.h"
#import <KSDeferred/KSPromise.h>
#import "DayTimeSummaryController.h"
#import "ViolationsSummaryController.h"
#import "InjectorKeys.h"
#import "ViolationEmployee.h"
#import "ViolationRepository.h"
#import "DateProvider.h"
#import "TimesheetDetailsSeriesController.h"
#import "UserSession.h"
#import "WorkHoursStorage.h"
#import "WorkHours.h"
#import "DayTimeSummary.h"
#import "UserPermissionsStorage.h"
#import "PunchPresenter.h"
#import "DelayedTodaysPunchesRepository.h"
#import "PunchRepository.h"
#import "TimeLinePunchesSummary.h"


@interface ProjectOnBreakController ()


@property (nonatomic) TimesheetButtonControllerPresenter *timesheetButtonControllerPresenter;
@property (nonatomic) LastPunchLabelTextPresenter *lastPunchLabelTextPresenter;
@property (nonatomic) DayTimeSummaryControllerProvider *dayTimeSummaryControllerProvider;
@property (nonatomic) DurationStringPresenter *durationStringPresenter;
@property (nonatomic) ChildControllerHelper *childControllerHelper;
@property (nonatomic) ViolationRepository *violationRepository;
@property (nonatomic) DayTimeSummaryController *dayTimeSummaryController;
@property (nonatomic) DurationCalculator *durationCalculator;
@property (nonatomic) ButtonStylist *buttonStylist;
@property (nonatomic) TimerProvider *timerProvider;
@property (nonatomic) id<UserSession> userSession;
@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) NSUserDefaults *defaults;
@property (nonatomic) id<Theme> theme;

@property (nonatomic) AddressControllerPresenter *addressControllerPresenter;
@property (nonatomic) id <ProjectOnBreakControllerDelegate> delegate;
@property (nonatomic) KSPromise *serverDidFinishPunchPromise;
@property (nonatomic) LocalPunch *punch;
@property (nonatomic) WorkHoursStorage *workHoursStorage;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) KSPromise *punchesPromise;


@property (weak, nonatomic) id<BSInjector> injector;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *workHoursContainerHeight;
@property (nonatomic, weak) IBOutlet UILabel *punchAttributesLabel;
@property (nonatomic, weak) IBOutlet UIButton *punchOutButton;
@property (nonatomic, weak) IBOutlet UIButton *resumeWorkButton;
@property (nonatomic, weak) IBOutlet UIView *addressLabelContainer;
@property (nonatomic, weak) IBOutlet UILabel *punchDurationTimerLabel;
@property (nonatomic, weak) IBOutlet UIView *timeLineCardContainerView;
@property (nonatomic, weak) IBOutlet UIView *workHoursContainerView;
@property (nonatomic, weak) IBOutlet UIView *timesheetButtonContainerView;
@property (nonatomic, weak) IBOutlet UIView *violationsButtonContainerView;
@property (nonatomic, weak) IBOutlet UIView *cardContainerView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *containerView;


@property (nonatomic, weak) IBOutlet NSLayoutConstraint *widthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *timeLineHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *violationsButtonHeightConstraint;
@end


@implementation ProjectOnBreakController

- (instancetype)initWithTimesheetButtonControllerPresenter:(TimesheetButtonControllerPresenter *)timesheetButtonControllerPresenter
                               lastPunchLabelTextPresenter:(LastPunchLabelTextPresenter *)lastPunchLabelTextPresenter
                          dayTimeSummaryControllerProvider:(DayTimeSummaryControllerProvider *)dayTimeSummaryControllerProvider
                                   durationStringPresenter:(DurationStringPresenter *)durationStringPresenter
                                     childControllerHelper:(ChildControllerHelper *)childControllerHelper
                                       violationRepository:(ViolationRepository *)violationRepository
                                        durationCalculator:(DurationCalculator *)durationCalculator
                                          workHoursStorage:(WorkHoursStorage *)workHoursStorage
                                             buttonStylist:(ButtonStylist *)buttonStylist
                                             timerProvider:(TimerProvider *)timerProvider
                                              dateProvider:(DateProvider *)dateProvider
                                               userSession:(id <UserSession>)userSession
                                                  defaults:(NSUserDefaults *)defaults
                                                     theme:(id <Theme>)theme {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.timesheetButtonControllerPresenter = timesheetButtonControllerPresenter;
        self.lastPunchLabelTextPresenter = lastPunchLabelTextPresenter;
        self.dayTimeSummaryControllerProvider = dayTimeSummaryControllerProvider;
        self.durationStringPresenter = durationStringPresenter;
        self.workHoursStorage = workHoursStorage;
        self.childControllerHelper = childControllerHelper;
        self.violationRepository = violationRepository;
        self.durationCalculator = durationCalculator;
        self.buttonStylist = buttonStylist;
        self.timerProvider = timerProvider;
        self.dateProvider = dateProvider;
        self.userSession = userSession;
        self.defaults = defaults;
        self.theme = theme;
    }

    return self;
}

- (void)setupWithAddressControllerPresenter:(AddressControllerPresenter *)addressControllerPresenter
                serverDidFinishPunchPromise:(KSPromise *)serverDidFinishPromise
                                   delegate:(id<ProjectOnBreakControllerDelegate>)delegate
                                      punch:(id<Punch>)punch
                             punchesPromise:(KSPromise *)punchesPromise
{
    self.addressControllerPresenter = addressControllerPresenter;
    self.serverDidFinishPunchPromise = serverDidFinishPromise;
    self.delegate = delegate;
    self.punch = punch;
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

    UserPermissionsStorage *userPermissionsStorage = [self.injector getInstance:[UserPermissionsStorage class]];
    if ([userPermissionsStorage hasActivityAccess])
    {
        [self.resumeWorkButton setUserInteractionEnabled:YES];
    }
    self.view.backgroundColor = [self.theme childControllerDefaultBackgroundColor];
    self.workHoursContainerView.backgroundColor = [self.theme childControllerDefaultBackgroundColor];
    self.violationsButtonContainerView.backgroundColor = [self.theme childControllerDefaultBackgroundColor];

    self.punchAttributesLabel.numberOfLines = 0;
    PunchPresenter *presenter = [self.injector getInstance:[PunchPresenter class]];
    NSAttributedString *punchAttributes = [presenter descriptionLabelForTimelineCellTextWithPunch:self.punch
                                                                                      regularFont:[self.theme punchAttributeRegularFont]
                                                                                        lightFont:[self.theme punchAttributeLightFont]
                                                                                        textColor:[self.theme punchAttributeLabelColor]
                                                                                         forWidth:CGRectGetWidth(self.punchAttributesLabel.bounds)];
    self.punchAttributesLabel.attributedText = punchAttributes;

    if ([userPermissionsStorage hasActivityAccess] && self.punch.oefTypesArray.count == 0)
    {
        self.punchAttributesLabel.textAlignment = NSTextAlignmentCenter;
    }
    else
    {
        self.punchAttributesLabel.textAlignment = NSTextAlignmentLeft;
    }

    self.punchDurationTimerLabel.font = [self.theme durationLabelLittleTimeUnitBigFont];

    UIColor *punchOutButtonBackgroundColor = [self.theme onBreakClockOutButtonBackgroundColor];
    NSString *punchOutButtonTitle = RPLocalizedString(@"Clock Out", nil);
    UIColor *punchOutButtonTitleColor = [self.theme onBreakClockOutButtonTitleColor];
    [self.buttonStylist styleButton:self.punchOutButton
                              title:punchOutButtonTitle
                         titleColor:punchOutButtonTitleColor
                    backgroundColor:punchOutButtonBackgroundColor
                        borderColor:nil];


    NSString *resumeWorkButtonTitle = RPLocalizedString(@"Resume Work", nil);
    UIColor *resumeWorkTitleColor = [self.theme resumeWorkButtonTitleColor];
    UIColor *resumeWorkBackgroundColor = [self.theme resumeWorkButtonBackgroundColor];
    [self.buttonStylist styleButton:self.resumeWorkButton
                              title:resumeWorkButtonTitle
                         titleColor:resumeWorkTitleColor
                    backgroundColor:resumeWorkBackgroundColor
                        borderColor:nil];
    self.resumeWorkButton.layer.borderWidth = self.punchOutButton.layer.borderWidth = 0.0f;

    self.punchDurationTimerLabel.backgroundColor = [self.theme timesheetBreakHoursNewBigFontColor];

    [self.addressControllerPresenter presentAddress:self.punch.address
                    ifNeededInAddressLabelContainer:self.addressLabelContainer
                                 onParentController:self
                                    backgroundColor:nil];

    NSInteger totalViolationMessagesCount = [[self.defaults objectForKey:@"totalViolationMessagesCount"] integerValue];
    
    ViolationsButtonController *violationsButtonController = [self.injector getInstance:[ViolationsButtonController class]];
    BOOL showViolations = totalViolationMessagesCount>0 ? YES : NO;
    [violationsButtonController setupWithDelegate:self showViolations:showViolations];
    [self.childControllerHelper addChildController:violationsButtonController
                                toParentController:self
                                   inContainerView:self.violationsButtonContainerView];

    id <WorkHours> workHours = [self.workHoursStorage getWorkHoursSummary];
    self.dayTimeSummaryController = [self.dayTimeSummaryControllerProvider provideInstanceWithPromise:self.serverDidFinishPunchPromise
                                                                                 placeholderWorkHours:workHours
                                                                                             delegate:self];
    [self updatePunchDurationLabel];
    [self.childControllerHelper addChildController:self.dayTimeSummaryController toParentController:self inContainerView:self.workHoursContainerView];
    self.workHoursContainerHeight.constant = 109.0;
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    CGFloat width = CGRectGetWidth(self.view.bounds);
    self.widthConstraint.constant = width;
    
    [self invalidateTimer];

    if (![self.timer isValid]) {
        self.timer = [self.timerProvider scheduledTimerWithTimeInterval:1 target:self selector:@selector(updatePunchDurationLabel) userInfo:@{} repeats:YES];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self invalidateTimer];
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

#pragma mark - <ViolationsSummaryControllerDelegate>

- (KSPromise *)violationsSummaryControllerDidRequestViolationSectionsPromise:(ViolationsSummaryController *)violationsSummaryController
{
    return [self.violationRepository fetchAllViolationSectionsForToday];
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

#pragma mark - <TimesheetButtonControllerDelegate>

- (void)timesheetButtonControllerWillNavigateToTimesheetDetailScreen:(TimesheetButtonController *)timesheetButtonController {
    TimesheetDetailsSeriesController *timesheetDetailsSeriesController = [self.injector getInstance:[TimesheetDetailsSeriesController class]];
    [self.navigationController pushViewController:timesheetDetailsSeriesController animated:YES];

}

- (void) timesheetButtonControllerWillNavigateToWidgetTimesheetDetailScreen:(TimesheetButtonController *) timesheetButtonController
{
    WidgetTimesheetDetailsSeriesController *timesheetDetailsSeriesController = [self.injector getInstance:[WidgetTimesheetDetailsSeriesController class]];
    [self.navigationController pushViewController:timesheetDetailsSeriesController animated:YES];
}

#pragma mark - <DayTimeSummaryControllerDelegate>

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


- (IBAction)didTapClockOutButton:(id)sender
{
    [self.delegate controllerDidPunchOut:self];
}

- (IBAction)didTapResumeWorkButton:(id)sender
{
    [self.delegate projectonBreakControllerDidResumeWork:self];
}

- (void) updatePunchDurationLabel
{
    if (self.navigationController != nil && self.navigationController != (id)[NSNull null]) {
        NSDateComponents *durationComponents = [self.durationCalculator timeSinceStartDate:self.punch.date];
        
        self.punchDurationTimerLabel.attributedText = [self.durationStringPresenter durationStringWithHours:durationComponents.hour
                                                                                                    minutes:durationComponents.minute
                                                                                                    seconds:durationComponents.second];
        self.punchDurationTimerLabel.font = [self.theme durationLabelLittleTimeUnitBigFont];
        [self.dayTimeSummaryController updateBreakHoursLabelWithOffset:durationComponents];
    }
    else{
        [self invalidateTimer];
    }
}

-(void)invalidateTimer
{
    [self.timer invalidate];
    self.timer =  nil;
}


@end
