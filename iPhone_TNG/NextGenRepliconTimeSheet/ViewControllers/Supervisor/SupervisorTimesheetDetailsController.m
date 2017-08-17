#import "SupervisorTimesheetDetailsController.h"
#import "Theme.h"
#import "ChildControllerHelper.h"
#import "DayTimeSummaryController.h"
#import "WorkHoursDeferred.h"
#import "TeamTimesheetSummary.h"
#import "TeamWorkHoursSummary.h"
#import <Blindside/Blindside.h>
#import "GrossPayController.h"
#import "GoldenAndNonGoldenTimesheetsController.h"
#import "InjectorKeys.h"
#import <KSDeferred/KSDeferred.h>
#import "TeamTimesheetSummaryDeserializer.h"
#import "CurrencyValueDeserializer.h"
#import "AllViolationSections.h"
#import "SupervisorTimesheetSummaryController.h"
#import "TimesheetPeriodCursor.h"
#import "UserPermissionsStorage.h"


@interface SupervisorTimesheetDetailsController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *scrollableContentView;
@property (weak, nonatomic) IBOutlet UIView *grossPayContainerView;
@property (weak, nonatomic) IBOutlet UIView *summaryCardContainerView;
@property (weak, nonatomic) IBOutlet UIView *workHoursContainerView;
@property (weak, nonatomic) IBOutlet UIView *goldenTimesheetContainerView;
@property (weak, nonatomic) IBOutlet UIView *nongoldenTimesheetContainerView;
@property (weak, nonatomic) IBOutlet UIView *violationsButtonContainerView;
@property (weak, nonatomic) IBOutlet UIView *timesheetSummaryContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *summaryCardWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *grossPayContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *goldenTimesheetContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nongoldenTimesheetContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *violationsButtonHeightConstraint;

@property (nonatomic) GoldenAndNonGoldenTimesheetsController *goldenTimesheetUserController;
@property (nonatomic) GoldenAndNonGoldenTimesheetsController *nongoldenTimesheetUserController;
@property (nonatomic) TimesheetPeriodCursor *cursor;
@property (nonatomic) ChildControllerHelper *childControllerHelper;
@property (nonatomic) id<Theme> theme;
@property (nonatomic) UserPermissionsStorage* punchRulesStorage;
@property (nonatomic) KSPromise *teamTimesheetSummaryPromise;
@property (nonatomic, weak) id<SupervisorTimesheetDetailsControllerDelegate> delegate;
@property (nonatomic, weak) id<BSInjector> injector;
@property (nonatomic, assign) TimesheetUserType selectedTimesheetUserType;
@property (nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation SupervisorTimesheetDetailsController


- (instancetype)initWithChildControllerHelper:(ChildControllerHelper *)childControllerHelper
                                        theme:(id<Theme>)theme
                            punchRulesStorage:(UserPermissionsStorage*)punchRulesStorage
{
    self = [super init];
    if (self)
    {
        self.childControllerHelper = childControllerHelper;
        self.theme = theme;
        self.punchRulesStorage = punchRulesStorage;
    }
    return self;
}

- (void)setupWithTeamTimesheetSummaryPromise:(KSPromise *)teamTimesheetSummaryPromise delegate:(id<SupervisorTimesheetDetailsControllerDelegate>)delegate
{
    self.teamTimesheetSummaryPromise = teamTimesheetSummaryPromise;
    self.delegate = delegate;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.grossPayContainerHeightConstraint.constant = 0;
    self.violationsButtonHeightConstraint.constant = 0;
    self.view.backgroundColor = [self.theme supervisorTimesheetDetailsControllerBackGroundColor];
    self.scrollableContentView.backgroundColor = [self.theme supervisorTimesheetDetailsControllerBackGroundColor];
    self.summaryCardContainerView.backgroundColor = [self.theme supervisorTimesheetDetailsControllerSummaryCardBackGroundColor];
    self.workHoursContainerView.backgroundColor = [self.theme supervisorTimesheetDetailsControllerSummaryCardBackGroundColor];
    self.summaryCardContainerView.layer.cornerRadius = 5.0f;
    self.violationsButtonContainerView.backgroundColor = [self.theme cardContainerBackgroundColor];
    self.scrollView.accessibilityLabel = @"supervisor_timesheet_scrollview";
    
    
    SupervisorTimesheetSummaryController *supervisorTimesheetSummaryController = [self.injector getInstance:[SupervisorTimesheetSummaryController class]];
    [supervisorTimesheetSummaryController setupWithDelegate:self timeSummaryPromise:self.teamTimesheetSummaryPromise];
    [self.childControllerHelper addChildController:supervisorTimesheetSummaryController
                                toParentController:self
                                   inContainerView:self.timesheetSummaryContainerView];
    supervisorTimesheetSummaryController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    WorkHoursDeferred *workHoursDeferred = [self.injector getInstance:[WorkHoursDeferred class]];
    DayTimeSummaryController *dayTimeSummaryController = [self.injector getInstance:[DayTimeSummaryController class]];
    [dayTimeSummaryController setupWithDelegate:nil placeHolderWorkHours:nil workHoursPromise:[workHoursDeferred promise] hasBreakAccess:YES isScheduledDay:YES todaysDateContainerHeight:0.0];
    [self.childControllerHelper addChildController:dayTimeSummaryController
                                toParentController:self
                                   inContainerView:self.workHoursContainerView];
    
    
    KSDeferred *goldenTimesheetsDeferred = [self.injector getInstance:InjectorKeyGoldenTimesheetDeferred];
    self.goldenTimesheetUserController = [self.injector getInstance:InjectorKeyGoldenTimesheetUserController];
    [self.goldenTimesheetUserController setupWithTimesheetUsersPromise:goldenTimesheetsDeferred.promise delegate:self];
    [self.childControllerHelper addChildController:self.goldenTimesheetUserController
                                toParentController:self
                                   inContainerView:self.goldenTimesheetContainerView];
    
    KSDeferred *nongoldenTimesheetsDeferred = [self.injector getInstance:InjectorKeyNonGoldenTimesheetDeferred];
    self.nongoldenTimesheetUserController = [self.injector getInstance:InjectorKeyNongoldenTimesheetUserController];
    [self.nongoldenTimesheetUserController setupWithTimesheetUsersPromise:nongoldenTimesheetsDeferred.promise delegate:self];
    [self.childControllerHelper addChildController:self.nongoldenTimesheetUserController
                                toParentController:self
                                   inContainerView:self.nongoldenTimesheetContainerView];

    [self.teamTimesheetSummaryPromise then:^id(TeamTimesheetSummary *teamTimesheetSummary) {
        
        [workHoursDeferred resolveWithValue:teamTimesheetSummary.teamWorkHoursSummary];
        [goldenTimesheetsDeferred resolveWithValue:teamTimesheetSummary.goldenTimesheets];
        [nongoldenTimesheetsDeferred resolveWithValue:teamTimesheetSummary.nongoldenTimesheets];
        
        self.cursor = [[TimesheetPeriodCursor alloc] initWithCurrentPeriod:teamTimesheetSummary.currentPeriod
                                                            previousPeriod:teamTimesheetSummary.previousPeriod
                                                                 nextPeriod:teamTimesheetSummary.nextPeriod];
        
        BOOL payWidgetPermissionsAvailable = (teamTimesheetSummary.payAmountDetailsPermission || teamTimesheetSummary.payHoursDetailsPermission) && [self.punchRulesStorage canViewPayDetails];
        BOOL shouldShowPayWidget = (teamTimesheetSummary.totalPay && teamTimesheetSummary.actualsByPayCode.count > 0);
        if(shouldShowPayWidget && payWidgetPermissionsAvailable)
        {
            GrossPayTimeHomeViewController *grossPayTimeHomeViewController = [self.injector getInstance:[GrossPayTimeHomeViewController class]];
            [grossPayTimeHomeViewController setupWithGrossSummary:teamTimesheetSummary delegate:self];
            [self.childControllerHelper addChildController:grossPayTimeHomeViewController
                                        toParentController:self
                                           inContainerView:self.grossPayContainerView];
            
            CGFloat heightForPayCodes = [self calculateHeightForPayWidgetLegends:teamTimesheetSummary.actualsByPayCode.count
                                                                   PayPermission:teamTimesheetSummary.payAmountDetailsPermission
                                                                 HoursPermission:teamTimesheetSummary.payHoursDetailsPermission];
            
            self.grossPayContainerHeightConstraint.constant = 320.f + heightForPayCodes;
        }

        return teamTimesheetSummary;
    } error:^id(NSError *error) {
        [workHoursDeferred rejectWithError:error];
        [goldenTimesheetsDeferred rejectWithError:error];
        [nongoldenTimesheetsDeferred rejectWithError:error];
        return error;
    }];

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.summaryCardWidthConstraint.constant = CGRectGetWidth(self.view.bounds);
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private

-(void)refreshSelectedGoldenAndNonGoldenTimesheetsControllerAfterApprovalActions
{
    if (self.selectedTimesheetUserType == TimesheetUserTypeGolden) {
        [self.goldenTimesheetUserController tableView:nil didSelectRowAtIndexPath:self.selectedIndexPath];

    } else {
        [self.nongoldenTimesheetUserController tableView:nil didSelectRowAtIndexPath:self.selectedIndexPath];

    }

}


-(CGFloat )calculateHeightForPayWidgetLegends:(NSUInteger)count PayPermission:(BOOL)payPermission HoursPermission:(BOOL)hoursPermission
{
    CGFloat heightForViewMore = 0.0f;
    if(payPermission && hoursPermission)
    {
        heightForViewMore = 25.0f;
    }
    if(count>4)
    {
        return 100.0f + heightForViewMore;
    }
    
    CGFloat heightForLegends =[Util calculateHeightForPayWidgetLegends:count];
    return heightForViewMore + heightForLegends;


}

#pragma mark - <TimesheetUserControllerDelegate>

- (void)timesheetUserController:(GoldenAndNonGoldenTimesheetsController *)timesheetUserController
                didUpdateHeight:(CGFloat)height
{
    if (timesheetUserController == self.goldenTimesheetUserController) {
        self.goldenTimesheetContainerHeightConstraint.constant = height;
    }
    else if (timesheetUserController == self.nongoldenTimesheetUserController) {
        self.nongoldenTimesheetContainerHeightConstraint.constant = height;
    }
}


- (void)timesheetUserController:(GoldenAndNonGoldenTimesheetsController *)timesheetUserController
              timesheetUserType:(TimesheetUserType)timesheetUserType selectedIndex:(NSIndexPath *)indexPath
{

    self.selectedTimesheetUserType = timesheetUserType;
    self.selectedIndexPath = indexPath;
}

#pragma mark - <TimesheetSummaryControllerDelegate>

- (void)timesheetSummaryControllerDidTapPreviousButton:(SupervisorTimesheetSummaryController *)supervisorTimesheetSummaryController
{
    [self.delegate supervisorTimesheetDetailsController:self requestsPreviousTimesheetWithCursor:self.cursor];
}

- (void)timesheetSummaryControllerDidTapNextButton:(SupervisorTimesheetSummaryController *)supervisorTimesheetSummaryController
{
    [self.delegate supervisorTimesheetDetailsController:self requestsNextTimesheetWithCursor:self.cursor];
}

#pragma mark <GrossPayTimeHomeControllerDelegate>

-(void)grossPayTimeHomeControllerIntendsToUpdateHeight:(CGFloat)height
                                             viewItems:(ViewItemsAction)action
{
    if(action==More)
    {
        self.grossPayContainerHeightConstraint.constant = 330.f + height;
    }
    else
    {
        self.grossPayContainerHeightConstraint.constant = 320.0f + height;
    }
}

@end
