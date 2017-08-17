#import "ProjectPunchInController.h"
#import "Theme.h"

#import "TimesheetButtonControllerPresenter.h"
#import "TimesheetDetailsController.h"
#import <Blindside/BSInjector.h>

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
#import "PunchCardController.h"
#import "PunchCardObject.h"
#import "PunchCardStorage.h"
#import "OEFType.h"
#import "OEFTypeStorage.h"
#import "PunchRepository.h"
#import "UserPermissionsStorage.h"
#import "TimeLinePunchesSummary.h"


@interface ProjectPunchInController ()

@property (nonatomic) TimesheetButtonControllerPresenter *timesheetButtonControllerPresenter;
@property (nonatomic) DayTimeSummaryControllerProvider *dayTimeSummaryControllerProvider;
@property (nonatomic) ChildControllerHelper *childControllerHelper;
@property (nonatomic) ViolationRepository *violationRepository;
@property (nonatomic) PunchCardStorage *punchCardStorage;
@property (nonatomic) DayTimeSummaryController *dayTimeSummaryController;
@property (nonatomic) WorkHoursStorage *workHoursStorage;
@property (nonatomic) id<UserSession> userSession;
@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) NSUserDefaults *defaults;
@property (nonatomic) id<Theme> theme;

@property (weak, nonatomic) id<ProjectPunchInControllerDelegate> delegate;
@property (nonatomic) KSPromise *serverDidFinishPunchPromise;
@property (nonatomic) KSPromise *punchesPromise;

@property (weak, nonatomic) id<BSInjector> injector;

@property (weak, nonatomic) IBOutlet UIView *workHoursContainerView;
@property (weak, nonatomic) IBOutlet UIView *timeLineCardContainerView;
@property (weak, nonatomic) IBOutlet UIView *timesheetButtonContainerView;
@property (weak, nonatomic) IBOutlet UIView *violationsButtonContainerView;
@property (weak, nonatomic) IBOutlet UIView *cardContainerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLineHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *violationsButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *punchCardHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *workHoursContainerHeight;

@property (nonatomic,assign) BOOL keyboardVisible;
@property (nonatomic) NSNotificationCenter *notificationCenter;
@property (nonatomic) PunchCardObject *punchCardObject;
@property (nonatomic) OEFTypeStorage *oefTypeStorage;

@property (weak, nonatomic) IBOutlet UIButton *punchInButton;
@property (nonatomic) UserPermissionsStorage *userPermissionsStorage;

@end


@implementation ProjectPunchInController

- (instancetype)initWithTimesheetButtonControllerPresenter:(TimesheetButtonControllerPresenter *)timesheetButtonControllerPresenter
                          dayTimeSummaryControllerProvider:(DayTimeSummaryControllerProvider *)dayTimeSummaryControllerProvider
                                     childControllerHelper:(ChildControllerHelper *)childControllerHelper
                                       violationRepository:(ViolationRepository *)violationRepository
                                          workHoursStorage:(WorkHoursStorage *)workHoursStorage
                                          punchCardStorage:(PunchCardStorage *)punchCardStorage
                                              dateProvider:(DateProvider *)dateProvider
                                               userSession:(id <UserSession>)userSession
                                                     theme:(id <Theme>)theme
                                        notificationCenter:(NSNotificationCenter *)notificationCenter
                                            oefTypeStorage:(OEFTypeStorage *)oefTypeStorage
                                    userPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                                                  defaults:(NSUserDefaults *)defaults {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.timesheetButtonControllerPresenter = timesheetButtonControllerPresenter;
        self.dayTimeSummaryControllerProvider = dayTimeSummaryControllerProvider;
        self.childControllerHelper = childControllerHelper;
        self.violationRepository = violationRepository;
        self.workHoursStorage = workHoursStorage;
        self.punchCardStorage = punchCardStorage;
        self.dateProvider = dateProvider;
        self.userSession = userSession;
        self.theme = theme;
        self.notificationCenter = notificationCenter;
        self.oefTypeStorage = oefTypeStorage;
        self.userPermissionsStorage = userPermissionsStorage;
        self.defaults = defaults;
    }
    return self;
}

- (void)setupWithServerDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise
                                    delegate:(id<ProjectPunchInControllerDelegate>)delegate
                             punchCardObject:(PunchCardObject *)punchCardObject
                              punchesPromise:(KSPromise *)punchesPromise
{
    self.serverDidFinishPunchPromise = serverDidFinishPunchPromise;
    self.punchesPromise = punchesPromise;
    self.punchCardObject = punchCardObject;
    self.delegate = delegate;

}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - UIViewController

- (PunchCardObject *)returnEmptyCPTPunchCardIfInvalid:(PunchCardObject *)punchCard {
    PunchCardObject *card = punchCard;
    if(!card.isValidPunchCard) {
        PunchCardObject *emptyPunchCard = [[PunchCardObject alloc] initWithClientType:nil projectType:nil oefTypesArray:punchCard.oefTypesArray breakType:punchCard.breakType taskType:nil activity:nil uri:punchCard.uri];

        card = emptyPunchCard;
    }
    return card;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.punchInButton.backgroundColor = [self.theme punchInColor];
    self.punchInButton.layer.borderColor = [self.theme punchInButtonBorderColor];
    self.punchInButton.layer.borderWidth = [self.theme punchInButtonBorderWidth];
    self.punchInButton.titleLabel.font = [self.theme punchInButtonTitleFont];
    
    self.punchInButton.layer.cornerRadius = CGRectGetWidth(self.punchInButton.bounds) / 2.0f;
    [self.punchInButton setTitle:RPLocalizedString(@"Clock In", @"Clock In") forState:UIControlStateNormal];
    [self.punchInButton setTitleColor:[self.theme punchInButtonTitleColor] forState:UIControlStateNormal];
    
    self.workHoursContainerView.backgroundColor = [self.theme childControllerDefaultBackgroundColor];
    self.violationsButtonContainerView.backgroundColor = [self.theme childControllerDefaultBackgroundColor];
    self.cardContainerView.backgroundColor = [self.theme childControllerDefaultBackgroundColor];

    PunchCardController *punchCardController = [self.injector getInstance:[PunchCardController class]];
    NSArray *punchCards = [self.punchCardStorage getPunchCards];
    NSArray *oefTypesArray = [self.oefTypeStorage getAllOEFSForCollectAtTimeOfPunch:PunchActionTypePunchIn];

    BOOL hasActivityAccess = [self.userPermissionsStorage hasActivityAccess];
    BOOL hasProjectAccess = [self.userPermissionsStorage  hasProjectAccess];

    if (oefTypesArray.count>0 || (hasActivityAccess || hasProjectAccess))
    {
        [self.punchInButton removeFromSuperview];

        PunchCardObject *punchCard = self.punchCardObject != nil ? [self getUpdatedPunchCardObject] : [self returnEmptyCPTPunchCardIfInvalid:[punchCards firstObject]];
        
        [punchCardController setUpWithPunchCardObject:punchCard punchCardType:FilledClientProjectTaskPunchCard delegate:self oefTypesArray:oefTypesArray];
        [self.childControllerHelper addChildController:punchCardController
                                    toParentController:self
                                       inContainerView:self.cardContainerView];
    }

    else
    {
        [self.cardContainerView removeFromSuperview];
    }

    self.workHoursContainerHeight.constant = 109.0;

    
    NSInteger totalViolationMessagesCount = [[self.defaults objectForKey:@"totalViolationMessagesCount"] integerValue];
    
    ViolationsButtonController *violationsButtonController = [self.injector getInstance:[ViolationsButtonController class]];
    BOOL showViolations = totalViolationMessagesCount>0 ? YES : NO;
    [violationsButtonController setupWithDelegate:self showViolations:showViolations];
    [self.childControllerHelper addChildController:violationsButtonController
                                toParentController:self
                                   inContainerView:self.violationsButtonContainerView];

    id <WorkHours> workHours = [self.workHoursStorage getCombinedWorkHoursSummary];
    self.dayTimeSummaryController = [self.dayTimeSummaryControllerProvider provideInstanceWithPromise:self.serverDidFinishPunchPromise
                                                                                 placeholderWorkHours:workHours
                                                                                             delegate:self];
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

    [self.scrollView setContentOffset:CGPointZero animated:YES];

    CGFloat width = CGRectGetWidth(self.view.bounds);
    self.widthConstraint.constant = width;

    // Register for the events

    [self.notificationCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [self.notificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    //Initially the keyboard is hidden
    self.keyboardVisible = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.notificationCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [self.notificationCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (IBAction)didTapToPunch:(id)sender
{
    PunchCardObject *cardObject = [[PunchCardObject alloc]
                                   initWithClientType:nil
                                   projectType:nil
                                   oefTypesArray:nil
                                   breakType:nil
                                   taskType:nil
                                   activity:nil
                                   uri:nil];
    __weak id this = self;
   [self punchCardController:this didIntendToPunchWithObject:cardObject];
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

#pragma mark - <PunchCardControllerDelegate>

- (void)punchCardController:(PunchCardController *)punchCardController didUpdatePunchCardWithObject:(PunchCardObject *)punchCardObject
{
    [self.delegate projectPunchInController:self didUpdatePunchCardWithObject:punchCardObject];
}
- (void)punchCardController:(PunchCardController *)punchCardController didIntendToPunchWithObject:(PunchCardObject *)punchCardObject
{
    BOOL hasActivityAccess = [self.userPermissionsStorage hasActivityAccess];
    BOOL hasProjectAccess = [self.userPermissionsStorage  hasProjectAccess];

    ClientType *client = nil;
    ProjectType *project = nil;
    TaskType *task = nil;
    Activity *activity = nil;

    if (hasProjectAccess)
    {
        BOOL isClientPresent = IsValidClient(punchCardObject.clientType);
        client = isClientPresent ? [punchCardObject.clientType copy] : nil;

        BOOL isProjectPresent = [self isValidString:punchCardObject.projectType.uri];
        project = isProjectPresent ? [punchCardObject.projectType copy] : nil;

        BOOL isTaskPresent = [self isValidString:punchCardObject.taskType.uri];
        task = isTaskPresent ? [punchCardObject.taskType copy] : nil;
    }

    if (hasActivityAccess)
    {
        BOOL isActivityPresent = [self isValidString:punchCardObject.activity.uri];
        activity = isActivityPresent ? [punchCardObject.activity copy] : nil;
    }




    NSArray *oefTypesArray = [self.oefTypeStorage getUnionOEFArrayFromPunchCardOEF:punchCardObject.oefTypesArray andPunchActionType:PunchActionTypePunchIn];

    PunchCardObject *cardObject = [[PunchCardObject alloc]
                                   initWithClientType:client
                                   projectType:project
                                   oefTypesArray:oefTypesArray
                                   breakType:nil
                                   taskType:task
                                   activity:activity
                                   uri:nil];
    [self.delegate projectPunchInController:self didIntendToPunchWithObject:cardObject];
}

- (void)punchCardController:(PunchCardController *)punchCardController didUpdateHeight:(CGFloat)height;
{
    self.punchCardHeightConstraint.constant = height;

}

- (void)punchCardController:(PunchCardController *)punchCardController didScrolltoSubview:(id)subview
{
    UITextView *textView = (UITextView *)subview;
    CGRect rc = [subview bounds];
    rc = [subview convertRect:rc toView:self.scrollView];
    float yPosition = (rc.origin.y - 200) + textView.contentSize.height;
    if (yPosition<0.0)
    {
        yPosition = 0.0;
    }
    [self.scrollView setContentOffset:CGPointMake(0, yPosition) animated:NO];

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


-(BOOL)isValidString:(NSString *)value
{
    if (value != nil && value != (id) [NSNull null] && value.length > 0 && ![value isEqualToString:NULL_STRING]) {
        return YES;
    }
    return NO;
}


- (PunchCardObject *)getUpdatedPunchCardObject {
    PunchCardObject *punchCardObj = self.punchCardObject;
    
    ClientType *localClientType = [[ClientType alloc] initWithName:nil uri:nil];
    ClientType *client = IsValidClient(punchCardObj.clientType) ? punchCardObj.clientType : localClientType;
    
    ProjectType *project = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:punchCardObj.projectType.hasTasksAvailableForTimeAllocation isTimeAllocationAllowed:punchCardObj.projectType.isTimeAllocationAllowed projectPeriod:punchCardObj.projectType.projectPeriod clientType:client name:punchCardObj.projectType.name uri:punchCardObj.projectType.uri];
    
    punchCardObj = [[PunchCardObject alloc] initWithClientType:client
                                                   projectType:project
                                                 oefTypesArray:punchCardObj.oefTypesArray
                                                     breakType:punchCardObj.breakType
                                                      taskType:punchCardObj.taskType
                                                      activity:punchCardObj.activity
                                                           uri:punchCardObj.uri];
    return punchCardObj;
    
}

#pragma mark - ViewController Memory Warning

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - <keyboard helper>


-(void) keyboardWillShow: (NSNotification *)notif {

    // If keyboard is visible, return
    if (self.keyboardVisible) {
        //Keyboard is already visible. Ignore notification
        return;
    }

    // Get the size of the keyboard.
    NSDictionary* info = [notif userInfo];
    NSValue* aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;

    // Resize the scroll view to make room for the keyboard
    CGRect viewFrame = self.scrollView.frame;
    viewFrame.size.height = (viewFrame.size.height - keyboardSize.height) + 48.0;
    self.scrollView.frame = viewFrame;


    // Keyboard is now visible
    self.keyboardVisible = YES;
}

-(void) keyboardWillHide: (NSNotification *)notif {
    // Is the keyboard already shown
    if (!self.keyboardVisible) {
        //Keyboard is already hidden. Ignore notification
        return;
    }

    // Reset the frame scroll view to its original value
    self.scrollView.frame = self.view.frame;


    // Keyboard is no longer visible
    self.keyboardVisible = NO;
    
}

@end
