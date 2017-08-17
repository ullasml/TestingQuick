#import "ProjectPunchOutController.h"
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
#import "ClientType.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "Punch.h"
#import "Activity.h"
#import "PunchPresenter.h"
#import "OEFTypeStorage.h"
#import "DelayedTodaysPunchesRepository.h"
#import "PunchRepository.h"
#import "TimeLinePunchesSummary.h"
#import "DayTimeSummaryController.h"


@interface ProjectPunchOutController () <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIButton *punchOutButton;
@property (weak, nonatomic) IBOutlet UIButton *breakButton;
@property (weak, nonatomic) IBOutlet UIButton *transferButton;
@property (weak, nonatomic) IBOutlet UIView *addressLabelContainer;
@property (weak, nonatomic) IBOutlet UIView *timeLineCardContainerView;
@property (weak, nonatomic) IBOutlet UIView *timesheetButtonContainerView;
@property (weak, nonatomic) IBOutlet UIView *violationsButtonContainerView;
@property (weak, nonatomic) IBOutlet UIView *cardContainerView;
@property (weak, nonatomic) IBOutlet UILabel *punchDurationTimerLabel;
@property (weak, nonatomic) IBOutlet UILabel *punchAttributesLabel;

@property (weak, nonatomic) id<BSInjector> injector;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *breakButtonToPunchInLabelVerticalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *clockOutButtonToPunchInLabelVerticalConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLineHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *violationsButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *workHoursContainerHeight;

@property (weak, nonatomic) IBOutlet UIView *workHoursContainerView;

@property (nonatomic) TimesheetButtonControllerPresenter *timesheetButtonControllerPresenter;
@property (nonatomic) LastPunchLabelTextPresenter *lastPunchLabelTextPresenter;
@property (nonatomic) DayTimeSummaryControllerProvider *dayTimeSummaryControllerProvider;
@property (nonatomic) AddressControllerPresenter *addressControllerPresenter;
@property (nonatomic) DurationStringPresenter *durationStringPresenter;
@property (nonatomic, weak) id <ProjectPunchOutControllerDelegate> delegate;
@property (nonatomic) ChildControllerHelper *childControllerHelper;
@property (nonatomic) BreakTypeRepository *breakTypeRepository;
@property (nonatomic) ViolationRepository *violationRepository;
@property (nonatomic) DurationCalculator *durationCalculator;
@property (nonatomic) KSPromise *serverDidFinishPunchPromise;
@property (nonatomic) UserPermissionsStorage *punchRulesStorage;
@property (nonatomic) WorkHoursStorage *workHoursStorage;
@property (nonatomic) OEFTypeStorage *oefTypeStorage;
@property (nonatomic) ButtonStylist *buttonStylist;
@property (nonatomic) TimerProvider *timerProvider;
@property (nonatomic) id<UserSession> userSession;
@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) NSUserDefaults *defaults;
@property (nonatomic) LocalPunch *punch;
@property (nonatomic) id<Theme> theme;
@property (nonatomic) KSPromise *punchesPromise;

@property (nonatomic) DayTimeSummaryController *dayTimeSummaryController;
@property (nonatomic) NSArray *breakTypeList;
@property (nonatomic) BreakType *breakType;
@property (nonatomic) NSDate *breakDate;
@property (nonatomic) NSTimer *timer;

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@end


@implementation ProjectPunchOutController

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
                                            oefTypeStorage:(OEFTypeStorage *)oefTypeStorage
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
        self.oefTypeStorage = oefTypeStorage;
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
                                   delegate:(id<ProjectPunchOutControllerDelegate>)delegate
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

- (void)viewDidLoad {
    [super viewDidLoad];

    self.punchAttributesLabel.numberOfLines = 0;
    PunchPresenter *presenter = [self.injector getInstance:[PunchPresenter class]];
    NSAttributedString *punchAttributes = [presenter descriptionLabelForTimelineCellTextWithPunch:self.punch
                                                                                      regularFont:[self.theme punchAttributeRegularFont]
                                                                                        lightFont:[self.theme punchAttributeLightFont]
                                                                                        textColor:[self.theme punchAttributeLabelColor]
                                                                                         forWidth:CGRectGetWidth(self.punchAttributesLabel.bounds)];
    self.punchAttributesLabel.attributedText = punchAttributes;


    UserPermissionsStorage *userPermissionsStorage = [self.injector getInstance:[UserPermissionsStorage class]];
    if ([userPermissionsStorage hasActivityAccess] && self.punch.oefTypesArray.count == 0)
    {
        self.punchAttributesLabel.textAlignment = NSTextAlignmentCenter;
    }
    else
    {
        self.punchAttributesLabel.textAlignment = NSTextAlignmentLeft;
    }

    

    if (![self.punchRulesStorage breaksRequired])
    {
        [self.breakButton removeFromSuperview];
    }
    
    self.view.backgroundColor = [self.theme childControllerDefaultBackgroundColor];
    NSString *punchOutTitle = RPLocalizedString(@"Clock Out", nil);
    UIColor *punchOutTitleColor = [self.theme destructiveButtonTitleColor];
    UIColor *punchOutBackgroundColor = [self.theme punchOutButtonBackgroundColor];
    UIColor *punchOutBorderColor = [self.theme punchOutButtonBorderColor];
    [self.buttonStylist styleButton:self.punchOutButton
                              title:punchOutTitle
                         titleColor:punchOutTitleColor
                    backgroundColor:punchOutBackgroundColor
                        borderColor:punchOutBorderColor];

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


    NSString *transferButtonTitle = RPLocalizedString(@"Transfer", nil);
    UIColor *transferTitleColor = [self.theme transferButtonTitleColor];
    UIColor *transferBackgroundColor = [self.theme transferButtonBackgroundColor];
    [self.buttonStylist styleButton:self.transferButton
                              title:transferButtonTitle
                         titleColor:transferTitleColor
                    backgroundColor:transferBackgroundColor
                        borderColor:nil];
    
    BOOL hasActivityAccess = [self.punchRulesStorage hasActivityAccess];
    BOOL hasProjectAccess = [self.punchRulesStorage hasProjectAccess];
    BOOL shouldShowTransferbutton= (hasActivityAccess || hasProjectAccess);
    
    self.transferButton.layer.borderWidth = self.punchOutButton.layer.borderWidth = 0.0f;
    
    if (!shouldShowTransferbutton) {
        [self.transferButton removeFromSuperview];
    }

    UIColor *addressContainerBackgroundColor = [UIColor clearColor];
    [self.addressControllerPresenter presentAddress:self.punch.address
                    ifNeededInAddressLabelContainer:self.addressLabelContainer
                                 onParentController:self
                                    backgroundColor:addressContainerBackgroundColor];
    

    self.workHoursContainerView.backgroundColor = [self.theme childControllerDefaultBackgroundColor];

    self.workHoursContainerHeight.constant = 109.0;

    
    NSInteger totalViolationMessagesCount = [[self.defaults objectForKey:@"totalViolationMessagesCount"] integerValue];
    
    ViolationsButtonController *violationsButtonController = [self.injector getInstance:[ViolationsButtonController class]];
    BOOL showViolations = totalViolationMessagesCount>0 ? YES : NO;
    [violationsButtonController setupWithDelegate:self showViolations:showViolations];
    [self.childControllerHelper addChildController:violationsButtonController
                                toParentController:self
                                   inContainerView:self.violationsButtonContainerView];

    id <WorkHours> workHours = nil;
    if ([self.punch isKindOfClass:[RemotePunch class]]) {
        workHours = [self.workHoursStorage getWorkHoursSummary];
    }
    else{
        workHours = [self.workHoursStorage getCombinedWorkHoursSummary];
    }
    
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
        [self.delegate projectPunchOutControllerDidTakeBreakWithDate:self.breakDate breakType:breakType];
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
        NSAttributedString *durationTimerLabelText = [self.durationStringPresenter durationStringWithHours:durationComponents.hour
                                                                                                   minutes:durationComponents.minute
                                                                                                   seconds:durationComponents.second];
        self.punchDurationTimerLabel.attributedText = durationTimerLabelText;
        self.punchDurationTimerLabel.backgroundColor = [self.theme timesheetWorkHoursNewBigFontColor];
        self.punchDurationTimerLabel.font = [self.theme durationLabelLittleTimeUnitBigFont];
        
        [self.dayTimeSummaryController updateRegularHoursLabelWithOffset:durationComponents];
        
    }
    else{
        [self invalidateTimer];
    }
}

- (IBAction)didTapBreakButton:(id)sender
{
    if ([self isOEFEnabled:PunchActionTypeStartBreak]) {
        [self.delegate projectPunchOutControllerDidTakeBreak];
    }
    else{
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
}

- (IBAction)didTapPunchOutButton:(id)sender
{
    [self.delegate controllerDidPunchOut:self];
}

- (IBAction)didTapTransferButton:(id)sender
{
    [self.delegate projectPunchOutControllerDidTransfer:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(BOOL)anyValidPunchAttributes
{
    return ( [self validString:self.punch.client.name] ||
            [self validString:self.punch.project.name] ||
            [self validString:self.punch.task.name]||
            [self validString:self.punch.activity.name]);
}

- (BOOL)validString:(NSString *)value
{
    return (value!=nil && ![value isKindOfClass:[NSNull class]] && value.length > 0);
}

-(NSString *)stringForPunchAttribute:(PunchAttribute)attribute
{
    NSString *noneString = RPLocalizedString(@"None", nil);
    if ([self anyValidPunchAttributes])
    {
        if (attribute == ClientAttribute)
        {
            if([self validString:self.punch.client.name])
            {
                return self.punch.client.name;
            }
            else
            {
                return noneString;
            }
        }
        else if (attribute == ProjectAttribute)
        {
            if([self validString:self.punch.project.name])
            {
                return self.punch.project.name;
            }
            else
            {
                return noneString;
            }
        }
        else if (attribute == TaskAttribute)
        {
            if([self validString:self.punch.task.name])
            {
                return self.punch.task.name;
            }
            else
            {
                return noneString;
            }
        }
        else
        {
            if([self validString:self.punch.activity.name])
            {
                return self.punch.activity.name;
            }
            else
            {
                return noneString;
            }
        }

    }
    else
    {
        NSString *attributeName;
        if (attribute == ClientAttribute)
        {
            attributeName = RPLocalizedString(@"Client", nil);
        }
        else if (attribute == ProjectAttribute)
        {
            attributeName = RPLocalizedString(@"Project", nil);
        }
        else if (attribute == TaskAttribute)
        {
            attributeName = RPLocalizedString(@"Task", nil);
        }
        else
        {
            attributeName = RPLocalizedString(@"Activity", nil);
        }
        return [NSString stringWithFormat:@"%@:%@",attributeName,RPLocalizedString(@"None", nil)];
    }
    
}

-(BOOL)isOEFEnabled:(PunchActionType)punchActionType
{
    NSArray *oefTypes =  [self.oefTypeStorage getAllOEFSForCollectAtTimeOfPunch:punchActionType];
    return [oefTypes count]> 0;
}

-(void)invalidateTimer
{

    [self.timer invalidate];
    self.timer =  nil;
}

@end
