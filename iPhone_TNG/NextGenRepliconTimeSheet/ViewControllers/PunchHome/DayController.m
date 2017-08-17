 #import <MacTypes.h>
#import "DayController.h"
#import "DayTimeSummary.h"
#import "ChildControllerHelper.h"
#import <Blindside/BSInjector.h>
#import "TimesheetBreakdownController.h"
#import "Theme.h"
#import "PunchOverviewController.h"
#import "UserSession.h"
#import "DelayedTodaysPunchesRepository.h"
#import "PunchRepository.h"
#import "TimeLineAndRecentPunchRepository.h"
#import "TimesheetDaySummary.h"
#import "TimesheetDayTimeLineController.h"
#import "DayTimeSummaryController.h"
#import "WorkHoursDeferred.h"
#import "DayTimeSummaryTitlePresenter.h"


 @interface DayController ()


@property (weak, nonatomic) IBOutlet UIView *workHoursContainerView;
@property (weak, nonatomic) IBOutlet UIView *timeLineContainerView;
@property (weak, nonatomic) IBOutlet UIView *topBorderLineView;
@property (weak, nonatomic) IBOutlet UIView *bottomBorderLineView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLineHeightConstraint;

@property (nonatomic) ChildControllerHelper *childControllerHelper;
@property (nonatomic) TimesheetBreakdownController *timesheetBreakdownController;
@property (nonatomic) DayTimeSummaryController *dayTimeSummaryController;
@property (nonatomic) id<Theme> theme;
@property (nonatomic,weak) id<PunchChangeObserverDelegate> punchChangeObserverDelegate;
@property (nonatomic) TimesheetDaySummary *timesheetDaySummary;
@property (nonatomic, copy) NSString *userURI;
@property (nonatomic) NSDate *date;
@property (nonatomic) id<UserSession>userSession;
@property (nonatomic, weak) id<BSInjector> injector;
@property (nonatomic) TimesheetDayTimeLineController *timeLineController;
@property (nonatomic) DayTimeSummaryTitlePresenter *dayTimeSummaryTitlePresenter;
@property (nonatomic) BOOL hasBreakAccess;
@property (nonatomic,weak) id <DayControllerDelegate> delegate;
@property (nonatomic) DayTimeSummaryCellPresenter *dayTimeSummaryCellPresenter;

@end


@implementation DayController

- (instancetype)initWithDayTimeSummaryTitlePresenter:(DayTimeSummaryTitlePresenter *)dayTimeSummaryTitlePresenter
                         dayTimeSummaryCellPresenter:(DayTimeSummaryCellPresenter *)dayTimeSummaryCellPresenter
                               childControllerHelper:(ChildControllerHelper *)childControllerHelper
                                         userSession:(id <UserSession>)userSession
                                               theme:(id <Theme>)theme {
   self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.dayTimeSummaryTitlePresenter = dayTimeSummaryTitlePresenter;
        self.dayTimeSummaryCellPresenter = dayTimeSummaryCellPresenter;
        self.childControllerHelper = childControllerHelper;
        self.userSession = userSession;
        self.theme = theme;
    }
    return self;
}

- (void)setupWithPunchChangeObserverDelegate:(id <PunchChangeObserverDelegate>)punchChangeObserverDelegate
                         timesheetDaySummary:(TimesheetDaySummary *)timesheetDaySummary
                              hasBreakAccess:(BOOL)hasBreakAccess
                                    delegate:(id <DayControllerDelegate>) delegate
                                     userURI:(NSString *)userURI
                                        date:(NSDate *)date {
    self.punchChangeObserverDelegate = punchChangeObserverDelegate;
    self.timesheetDaySummary = timesheetDaySummary;
    self.hasBreakAccess = hasBreakAccess;
    self.userURI = userURI;
    self.date = date;
    self.delegate = delegate;
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

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.attributedText = [self.dayTimeSummaryTitlePresenter dateStringForDayTimeSummary:self.timesheetDaySummary];
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
    self.navigationController.navigationBar.topItem.title = RPLocalizedString(@"Back", nil);

    self.view.backgroundColor = [self.theme dayControllerBackgroundColor];
    self.topBorderLineView.backgroundColor = [self.theme dayControllerBorderColor];
    self.bottomBorderLineView.backgroundColor = [self.theme dayControllerBorderColor];
    self.workHoursContainerView.backgroundColor = [self.theme cardContainerBackgroundColor];
    
    WorkHoursDeferred *workHoursDeferred = [self.injector getInstance:[WorkHoursDeferred class]];
    [workHoursDeferred resolveWithValue:self.timesheetDaySummary];
    self.dayTimeSummaryController = [self.injector getInstance:[DayTimeSummaryController class]];
    [self.dayTimeSummaryController setupWithDelegate:nil
                                placeHolderWorkHours:nil
                                    workHoursPromise:[workHoursDeferred promise]
                                      hasBreakAccess:self.hasBreakAccess
                                      isScheduledDay:self.timesheetDaySummary.isScheduledDay
                           todaysDateContainerHeight:0.0];
    
    [self.childControllerHelper addChildController:self.dayTimeSummaryController
                                toParentController:self
                                   inContainerView:self.workHoursContainerView];


    id <PunchChangeObserverDelegate> delegate = (self.delegate != nil) ? self : self.punchChangeObserverDelegate;
    FlowType flowType = [self getUserFlowType];
    self.timeLineController = [self.injector getInstance:[TimesheetDayTimeLineController class]];
    [self.timeLineController setupWithPunchChangeObserverDelegate:delegate
                                      serverDidFinishPunchPromise:nil
                                                         delegate:self
                                                          userURI:self.userURI
                                                         flowType:flowType
                                                          punches:self.timesheetDaySummary.punchesForDay
                                                timeLinePunchFlow:DayControllerTimeLinePunchFlowContext];
    [self.childControllerHelper addChildController:self.timeLineController
                                toParentController:self
                                   inContainerView:self.timeLineContainerView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.widthConstraint.constant = CGRectGetWidth([[UIScreen mainScreen] bounds]);

}

- (void) updateWithDayTimeSummaries:(TimesheetDaySummary *)dayTimeSummary
{
    self.timesheetDaySummary = dayTimeSummary;
    WorkHoursDeferred *workHoursDeferred = [self.injector getInstance:[WorkHoursDeferred class]];
    [workHoursDeferred resolveWithValue:dayTimeSummary];
    DayTimeSummaryController *dayTimeSummaryController = [self.injector getInstance:[DayTimeSummaryController class]];
    [dayTimeSummaryController setupWithDelegate:nil
                           placeHolderWorkHours:nil
                               workHoursPromise:[workHoursDeferred promise]
                                 hasBreakAccess:self.hasBreakAccess
                                 isScheduledDay:self.timesheetDaySummary.isScheduledDay
                      todaysDateContainerHeight:0.0];
    
    [self.childControllerHelper replaceOldChildController:self.dayTimeSummaryController
                                   withNewChildController:dayTimeSummaryController
                                       onParentController:self
                                          onContainerView:self.workHoursContainerView];
    self.dayTimeSummaryController = dayTimeSummaryController;
    
    id <PunchChangeObserverDelegate> delegate = (self.delegate != nil) ? self : self.punchChangeObserverDelegate;

    FlowType flowType = [self getUserFlowType];
    TimesheetDayTimeLineController *timeLineController = [self.injector getInstance:[TimesheetDayTimeLineController class]];
    [timeLineController setupWithPunchChangeObserverDelegate:delegate
                                 serverDidFinishPunchPromise:nil
                                                    delegate:self
                                                     userURI:self.userURI
                                                    flowType:flowType
                                                     punches:dayTimeSummary.punchesForDay
                                           timeLinePunchFlow:DayControllerTimeLinePunchFlowContext];
    [self.childControllerHelper replaceOldChildController:self.timeLineController
                                   withNewChildController:timeLineController
                                       onParentController:self
                                          onContainerView:self.timeLineContainerView];
    self.timeLineController = timeLineController;
}

#pragma mark - <TimesheetDayTimeLineControllerDelegate>

- (void)timesheetDayTimeLineController:(TimesheetDayTimeLineController *)timeLineController didUpdateHeight:(CGFloat)height
{
    self.timeLineHeightConstraint.constant = height;
}

- (NSDate *)timesheetDayTimeLineControllerDidRequestDate:(TimesheetDayTimeLineController *)timeLineController
{
    return self.date;
}

#pragma mark - <PunchChangeObserverDelegate>

- (KSPromise *)punchOverviewEditControllerDidUpdatePunch{
    KSDeferred *deferred = [[KSDeferred alloc]init];
    KSPromise *punchesPromise = [self.delegate needsTimePunchesPromiseWhenUserEditOrAddOrDeletePunchForDayController:self];
    [punchesPromise then:^id(TimesheetInfo *timesheetInfo) {
        NSArray *dayTimeSummaries = timesheetInfo.timePeriodSummary.dayTimeSummaries;
        for (TimesheetDaySummary *summary in dayTimeSummaries) {
            NSDate *date = [self.dayTimeSummaryCellPresenter dateForDayTimeSummary:summary];
            if ([date compare:self.date] == NSOrderedSame) {
                [self updateWithDayTimeSummaries:summary];
                break;
            }
        }
        [deferred resolveWithValue:nil];
        return nil;
    } error:^id(NSError *error) {
        [deferred rejectWithError:nil];
        return error;
    }];
    return deferred.promise;
}

#pragma mark - Private

-(FlowType )getUserFlowType
{
    BOOL isSameUser = [self.userSession.currentUserURI isEqualToString:self.userURI];
    return isSameUser ? UserFlowContext : SupervisorFlowContext;
}

@end
