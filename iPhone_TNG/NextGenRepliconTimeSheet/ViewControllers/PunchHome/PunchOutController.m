#import <MacTypes.h>
#import "PunchOutController.h"
#import <KSDeferred/KSDeferred.h>
#import <Blindside/BSInjector.h>
#import "InjectorKeys.h"
#import "LocalPunch.h"
#import "TimerProvider.h"
#import "DateProvider.h"
#import "Theme.h"
#import "DayTimeSummaryControllerProvider.h"
#import "DayTimeSummaryController.h"
#import "BreakTypeRepository.h"
#import "BreakType.h"
#import "ButtonStylist.h"
#import "LastPunchLabelTextPresenter.h"
#import "AddressControllerPresenter.h"
#import "DurationStringPresenter.h"
#import "DurationCalculator.h"
#import "UserPermissionsStorage.h"
#import "TimesheetButtonControllerPresenter.h"
#import "TimesheetDetailsController.h"
#import "ChildControllerHelper.h"
#import "ViolationsSummaryController.h"
#import "ViolationEmployee.h"
#import "ViolationRepository.h"
#import "AllViolationSections.h"
#import "TimesheetDetailsSeriesController.h"
#import "UserSession.h"
#import "WorkHoursStorage.h"
#import "WorkHours.h"
#import "DayTimeSummary.h"
#import "AppDelegate.h"
#import "PunchRepository.h"
#import "DelayedTodaysPunchesRepository.h"
#import "TimeLinePunchesSummary.h"
#import "DayTimeSummaryControllerProvider.h"


@interface PunchOutController () <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIButton *punchOutButton;
@property (weak, nonatomic) IBOutlet UIButton *breakButton;
@property (weak, nonatomic) IBOutlet UILabel *punchDurationTimerLabel;
@property (weak, nonatomic) IBOutlet UIView *addressLabelContainer;
@property (weak, nonatomic) IBOutlet UIView *timeLineCardContainerView;
@property (weak, nonatomic) IBOutlet UIView *timesheetButtonContainerView;
@property (weak, nonatomic) IBOutlet UIView *violationsButtonContainerView;
@property (weak, nonatomic) IBOutlet UILabel *punchStateLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@property (weak, nonatomic) id<BSInjector> injector;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *breakButtonToPunchInLabelVerticalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *clockOutButtonToPunchInLabelVerticalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLineHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *violationsButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentWidth;
@property (weak, nonatomic) IBOutlet UIView *workHoursContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *workHoursContainerHeight;

@property (nonatomic) TimesheetButtonControllerPresenter *timesheetButtonControllerPresenter;
@property (nonatomic) LastPunchLabelTextPresenter *lastPunchLabelTextPresenter;
@property (nonatomic) DayTimeSummaryControllerProvider *dayTimeSummaryControllerProvider;
@property (nonatomic) AddressControllerPresenter *addressControllerPresenter;
@property (nonatomic) DurationStringPresenter *durationStringPresenter;
@property (nonatomic, weak) id<PunchOutControllerDelegate> delegate;
@property (nonatomic) ChildControllerHelper *childControllerHelper;
@property (nonatomic) BreakTypeRepository *breakTypeRepository;
@property (nonatomic) ViolationRepository *violationRepository;
@property (nonatomic) DurationCalculator *durationCalculator;
@property (nonatomic) KSPromise *serverDidFinishPunchPromise;
@property (nonatomic) UserPermissionsStorage *punchRulesStorage;
@property (nonatomic) WorkHoursStorage *workHoursStorage;
@property (nonatomic) ButtonStylist *buttonStylist;
@property (nonatomic) TimerProvider *timerProvider;
@property (nonatomic) id<UserSession> userSession;
@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) LocalPunch *punch;
@property (nonatomic) id<Theme> theme;
@property (nonatomic) KSPromise *punchesPromise;
@property (nonatomic) NSUserDefaults *defaults;

@property (nonatomic) DayTimeSummaryController *dayTimeSummaryController;
@property (nonatomic) NSArray *breakTypeList;
@property (nonatomic) BreakType *breakType;
@property (nonatomic) NSDate *breakDate;
@property (nonatomic) NSTimer *timer;


@end


@implementation PunchOutController

- (instancetype)initWithTimesheetButtonControllerPresenter:(TimesheetButtonControllerPresenter *)timesheetButtonControllerPresenter
                               lastPunchLabelTextPresenter:(LastPunchLabelTextPresenter *)lastPunchLabelTextPresenter
                          dayTimeSummaryControllerProvider:(DayTimeSummaryControllerProvider *)dayTimeSummaryControllerProvider
                                   durationStringPresenter:(DurationStringPresenter *)durationStringPresenter
                                     childControllerHelper:(ChildControllerHelper *)childControllerHelper
                                       breakTypeRepository:(BreakTypeRepository *)breakTypeRepository
                                        durationCalculator:(DurationCalculator *)durationCalculator
                                       violationRepository:(ViolationRepository *)violationRepository
                                         punchRulesStorage:(UserPermissionsStorage *)punchRulesStorage
                                          workHoursStorage:(WorkHoursStorage *)workHoursStorage
                                             buttonStylist:(ButtonStylist *)buttonStylist
                                             timerProvider:(TimerProvider *)timerProvider
                                              dateProvider:(DateProvider *)dateProvider
                                               userSession:(id <UserSession>)userSession
                                                  defaults:(NSUserDefaults *)defaults
                                                     theme:(id <Theme>)theme {
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.timesheetButtonControllerPresenter = timesheetButtonControllerPresenter;
        self.lastPunchLabelTextPresenter = lastPunchLabelTextPresenter;
        self.dayTimeSummaryControllerProvider = dayTimeSummaryControllerProvider;
        self.durationStringPresenter = durationStringPresenter;
        self.childControllerHelper = childControllerHelper;
        self.breakTypeRepository = breakTypeRepository;
        self.violationRepository = violationRepository;
        self.workHoursStorage = workHoursStorage;
        self.durationCalculator = durationCalculator;
        self.punchRulesStorage = punchRulesStorage;
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
                                   delegate:(id<PunchOutControllerDelegate>)delegate
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

    [self.addressControllerPresenter presentAddress:self.punch.address
                    ifNeededInAddressLabelContainer:self.addressLabelContainer
                                 onParentController:self
                                    backgroundColor:nil];

    if (![self.punchRulesStorage breaksRequired])
    {
        [self.breakButton removeFromSuperview];
    }

    self.punchStateLabel.text = RPLocalizedString(@"Clocked In", @"Clocked In");
    [self.punchStateLabel setTextColor:[self.theme punchedSinceLabelTextColor]];
    [self.punchStateLabel setFont:[self.theme punchedSinceLabelFont]];

    NSString *punchOutTitle = RPLocalizedString(@"Clock Out", nil);
    UIColor *punchOutTitleColor = [self.theme destructiveButtonTitleColor];
    UIColor *punchOutBackgroundColor = [self.theme punchOutButtonBackgroundColor];
    UIColor *punchOutBorderColor = [self.theme punchOutButtonBorderColor];
    [self.buttonStylist styleButton:self.punchOutButton
                              title:punchOutTitle
                         titleColor:punchOutTitleColor
                    backgroundColor:punchOutBackgroundColor
                        borderColor:punchOutBorderColor];

    self.punchDurationTimerLabel.backgroundColor = [self.theme timesheetWorkHoursNewBigFontColor];

    NSString *takeABreakTitle = RPLocalizedString(@"Take a Break", nil);
    UIColor *takeABreakTitleColor = [self.theme takeBreakButtonTitleColor];
    UIColor *takeBreakButtonBackgroundColor = [self.theme takeBreakButtonBackgroundColor];
    UIColor *takeBreakBorderColor = [self.theme takeBreakButtonBorderColor];
    self.violationsButtonContainerView.backgroundColor = [self.theme childControllerDefaultBackgroundColor];

    [self.buttonStylist styleButton:self.breakButton
                              title:takeABreakTitle
                         titleColor:takeABreakTitleColor
                    backgroundColor:takeBreakButtonBackgroundColor
                        borderColor:takeBreakBorderColor];



    self.workHoursContainerView.backgroundColor = [self.theme childControllerDefaultBackgroundColor];

    self.workHoursContainerHeight.constant = 109.0;

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
    [self.childControllerHelper addChildController:self.dayTimeSummaryController
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
    [self.breakButton setAccessibilityIdentifier:@"start_break_btn"];
    [self.punchStateLabel setAccessibilityIdentifier:@"punch_state_lbl"];
    [self.punchOutButton setAccessibilityIdentifier:@"punch_out_btn"];
    [self.scrollView setAccessibilityIdentifier:@"uia_punch_astro_flow_scroll_view"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.contentWidth.constant = CGRectGetWidth(self.view.bounds);
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


#pragma mark - <UIActionSheetDelegate>

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.cancelButtonIndex == buttonIndex)
    {
        self.breakButton.enabled = YES;
    }
    else
    {
        BreakType *breakType = self.breakTypeList[buttonIndex - 1];
        [self.delegate punchOutControllerDidTakeBreakWithDate:self.breakDate breakType:breakType];
    }
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


#pragma mark - <ViolationsButtonControllerDelegate>

- (void)violationsButtonController:(ViolationsButtonController *)violationsButtonController didSignalIntentToViewViolationSections:(AllViolationSections *)allViolationSections
{
    ViolationsSummaryController *violationsSummaryController = [self.injector getInstance:[ViolationsSummaryController class]];
    KSDeferred *deferred = [[KSDeferred alloc] init];
    [deferred resolveWithValue:allViolationSections];

    [violationsSummaryController setupWithViolationSectionsPromise:deferred.promise delegate:self];

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



- (void)updatePunchDurationLabel
{
    if (self.navigationController != nil && self.navigationController != (id)[NSNull null]) {
        NSDateComponents *durationComponents = [self.durationCalculator timeSinceStartDate:self.punch.date];
        
        self.punchDurationTimerLabel.attributedText = [self.durationStringPresenter durationStringWithHours:durationComponents.hour
                                                                                                    minutes:durationComponents.minute
                                                                                                    seconds:durationComponents.second];
        self.punchDurationTimerLabel.font = [self.theme durationLabelLittleTimeUnitBigFont];
        
        [self.dayTimeSummaryController updateRegularHoursLabelWithOffset:durationComponents];
    }
    else{
        [self invalidateTimer];
    }

}

- (IBAction)didTapBreakButton:(id)sender
{
    self.breakDate = [self.dateProvider date];

    self.breakButton.enabled = NO;
    KSPromise *promise = [self.breakTypeRepository fetchBreakTypesForUser:self.userSession.currentUserURI];

    [promise then:^id(NSArray *breakTypeList) {
        self.breakButton.enabled = YES;
        self.breakTypeList = breakTypeList;

        NSString *breakTitle = RPLocalizedString(@"Select Break Type", nil);
        NSString *cancelTitle = RPLocalizedString(@"Cancel", nil);
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:breakTitle
                                                                 delegate:self
                                                        cancelButtonTitle:cancelTitle
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
        for (BreakType *breakType in breakTypeList)
        {
            [actionSheet addButtonWithTitle:breakType.name];
        }
        
        AppDelegate *appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
        [actionSheet showInView:appDelegate.window];
        return nil;

    } error:^id(NSError *error) {
        self.breakButton.enabled = YES;

        [UIAlertView showAlertViewWithCancelButtonTitle:nil
                                       otherButtonTitle:RPLocalizedString(@"OK", @"OK")
                                               delegate:self
                                                message:RPLocalizedString(@"Replicon app was unable to retrieve the break type list.  Please try again later.", nil)
                                                  title:nil
                                                    tag:LONG_MIN];
        return nil;
    }];
}

- (IBAction)didTapPunchOutButton:(id)sender
{
    [self.delegate controllerDidPunchOut:self];
}

-(void)invalidateTimer
{
    [self.timer invalidate];
    self.timer =  nil;
}

@end
