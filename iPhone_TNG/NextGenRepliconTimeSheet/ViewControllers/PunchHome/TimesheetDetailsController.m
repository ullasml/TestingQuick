#import <Foundation/Foundation.h>
#import "TimesheetDetailsController.h"
#import "Timesheet.h"
#import "Theme.h"
#import "ChildControllerHelper.h"
#import <Blindside/Blindside.h>
#import "TimeSummaryRepository.h"
#import "DayController.h"
#import "TimePeriodSummaryDeferred.h"
#import "DayTimeSummary.h"
#import "TimePeriodSummary.h"

#import "ViolationRepository.h"
#import "AllViolationSections.h"
#import "GrossPayController.h"
#import "SpinnerOperationsCounter.h"
#import "Cursor.h"
#import "UserPermissionsStorage.h"
#import "UserSession.h"
#import "InjectorKeys.h"
#import "TimesheetInfo.h"
#import "TimesheetInfoAndPermissionsRepository.h"
#import "TimesheetAdditionalInfo.h"
#import "IndexCursor.h"
#import "AuditHistoryStorage.h"
#import "TimesheetDaySummary.h"
#import "HeaderButtonViewController.h"
#import "DayTimeSummaryController.h"

@interface TimesheetDetailsController ()

@property (weak, nonatomic) IBOutlet UIView *timesheetSummaryContainerView;
@property (weak, nonatomic) IBOutlet UIView *grossPayContainerView;
@property (weak, nonatomic) IBOutlet UIView *workHoursContainerView;
@property (weak, nonatomic) IBOutlet UIView *separatorLineView;
@property (weak, nonatomic) IBOutlet UIView *timesheetBreakdownContainerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *violationsButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *grossPayContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *p;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timesheetSummaryHeightConstraint;


@property (nonatomic) ChildControllerHelper *childControllerHelper;
@property (nonatomic) TimeSummaryRepository *timeSummaryRepository;
@property (nonatomic) ViolationRepository *violationRepository;
@property (nonatomic) id <Timesheet> timesheet;
@property (nonatomic) id<Theme> theme;
@property (nonatomic) GrossPayTimeHomeViewController *grossPayTimeHomeViewController;
@property (nonatomic) DayTimeSummaryController *dayTimeSummaryController;
@property (nonatomic) TimesheetBreakdownController *timesheetBreakdownController;
@property (nonatomic) TimesheetSummaryController *timesheetSummaryController;
@property (nonatomic) GrossPayController *grossPayController;
@property (nonatomic) DayController *dayController;
@property (nonatomic) IndexCursor *cursor;
@property (nonatomic, weak) id<TimesheetDetailsControllerDelegate> delegate;
@property (nonatomic) PunchOverviewEditController *punchOverviewEditController;
@property (nonatomic) SpinnerOperationsCounter *spinnerOperationsCounter;
@property (nonatomic) KSPromise *timesheetExtrasPromise;
@property (nonatomic) WorkHoursPromise *timeSummaryPromise;
@property (nonatomic, copy) NSString *userURI;
@property (nonatomic) UserPermissionsStorage *punchRulesStorage;
@property (nonatomic) BOOL hasPayRollSummary;
@property (nonatomic) BOOL hasBreakAccess;
@property (nonatomic) TimesheetAdditionalInfo *timesheetAdditionalInfo;
@property (nonatomic) TimesheetInfoAndPermissionsRepository *timesheetInfoAndPermissionsRepository;
@property (nonatomic) NSInteger selectdDayIndex;
@property (nonatomic) AuditHistoryStorage *auditHistoryStorage;
@property (nonatomic, weak) id<BSInjector> injector;

@end


@implementation TimesheetDetailsController


- (instancetype)initWithTimesheetInfoAndPermissionsRepository:(TimesheetInfoAndPermissionsRepository *)timesheetInfoAndPermissionsRepository
                                        childControllerHelper:(ChildControllerHelper *)childControllerHelper
                                        timeSummaryRepository:(TimeSummaryRepository *)timeSummaryRepository
                                          violationRepository:(ViolationRepository *)violationRepository
                                          auditHistoryStorage:(AuditHistoryStorage *)auditHistoryStorage
                                            punchRulesStorage:(UserPermissionsStorage *)punchRulesStorage
                                                        theme:(id <Theme>)theme {
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.timesheetInfoAndPermissionsRepository =  timesheetInfoAndPermissionsRepository;
        self.childControllerHelper = childControllerHelper;
        self.timeSummaryRepository = timeSummaryRepository;
        self.violationRepository = violationRepository;
        self.auditHistoryStorage = auditHistoryStorage;
        self.punchRulesStorage = punchRulesStorage;
        self.theme = theme;
    }
    return self;
}

- (void)setupWithSpinnerOperationsCounter:(SpinnerOperationsCounter *)spinnerOperationsCounter
                                 delegate:(id <TimesheetDetailsControllerDelegate>)delegate
                                timesheet:(id<Timesheet> )timesheet
                        hasPayrollSummary:(BOOL)hasPayrollSummary
                           hasBreakAccess:(BOOL)hasBreakAccess
                                   cursor:(IndexCursor *)cursor
                                  userURI:(NSString *)userURI
                                    title:(NSString *)title {
    self.spinnerOperationsCounter = spinnerOperationsCounter;
    self.cursor = cursor;
    self.hasPayRollSummary = hasPayrollSummary;
    self.timesheet = timesheet;
    self.hasBreakAccess = hasBreakAccess;
    self.delegate = delegate;
    self.userURI = userURI;
    self.title = title;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.grossPayContainerHeightConstraint.constant = 0.f;
    
    self.view.backgroundColor = [self.theme timesheetDetailsBackgroundColor];
    
    self.separatorLineView.backgroundColor = [self.theme timesheetDetailsBorderColor];
    self.timesheetSummaryContainerView.backgroundColor = [self.theme cardContainerBackgroundColor];
    self.workHoursContainerView.backgroundColor = [self.theme cardContainerBackgroundColor];
    self.timesheetBreakdownContainerView.backgroundColor = [self.theme cardContainerBackgroundColor];
    
    if (self.timesheet != nil) {
        [self.scrollView setAccessibilityIdentifier:@"uia_timesheet_breakdown_scrollview_identifier"];
        
        TimePeriodSummary *timePeriodSummary = self.timesheet.timePeriodSummary;
        [self.auditHistoryStorage deleteAllRows];
        
        //FIXME
        //Work Around: As Autolayout is not giving correct view width in ViewDidLoad, getting width from screen bounds
        CGRect frame = self.timesheetSummaryContainerView.frame;
        frame.size.width = [[UIScreen mainScreen] bounds].size.width;
        self.timesheetSummaryContainerView.frame = frame;
        
        self.timesheetSummaryController = [self.injector getInstance:[TimesheetSummaryController class]];
        [self.timesheetSummaryController setupWithDelegate:self
                                               cursor:self.cursor
                                            timesheet:self.timesheet];
        [self.childControllerHelper addChildController:self.timesheetSummaryController
                                    toParentController:self
                                       inContainerView:self.timesheetSummaryContainerView];
        
        WorkHoursDeferred *workHoursDeferred = [self.injector getInstance:[WorkHoursDeferred class]];
        [workHoursDeferred resolveWithValue:timePeriodSummary];
        
        self.dayTimeSummaryController = [self.injector getInstance:[DayTimeSummaryController class]];
        [self.dayTimeSummaryController setupWithDelegate:nil
                                    placeHolderWorkHours:nil
                                        workHoursPromise:[workHoursDeferred promise]
                                          hasBreakAccess:[self showBreakHours]
                                          isScheduledDay:YES
                               todaysDateContainerHeight:0.0];
        
        [self.childControllerHelper addChildController:self.dayTimeSummaryController
                                    toParentController:self
                                       inContainerView:self.workHoursContainerView];
        
        self.timesheetBreakdownController = [self.injector getInstance:[TimesheetBreakdownController class]];
        [self.timesheetBreakdownController setupWithDayTimeSummaries:timePeriodSummary.dayTimeSummaries
                                                            delegate:self];
        
        [self.childControllerHelper addChildController:self.timesheetBreakdownController
                                    toParentController:self
                                       inContainerView:self.timesheetBreakdownContainerView];
        
        self.timesheetExtrasPromise = [self.timesheetInfoAndPermissionsRepository fetchTimesheetInfoForTimsheetUri:self.timesheet.uri
                                                                                                           userUri:self.userURI];
        [self.timesheetExtrasPromise  then:^id(TimesheetAdditionalInfo *timesheetAdditionalInfo) {
            self.timesheetAdditionalInfo = timesheetAdditionalInfo;
            self.timesheet = [self fetchUpdatedTimesheetInfoUsingTimesheetAdditionalInfo:timesheetAdditionalInfo];
            TimePeriodSummary *periodSummary = self.timesheet.timePeriodSummary;
            
            if ([self.delegate conformsToProtocol:@protocol(TimesheetDetailsControllerDelegate)] && [self.delegate respondsToSelector:@selector(timeSheetDetailsControllerDidCompleteRequestForTimeSheetSummary:)]) {
                [self.delegate timeSheetDetailsControllerDidCompleteRequestForTimeSheetSummary:periodSummary];
            }
            
            BOOL canViewPayDetailsWiget = [self canViewPayDetailsWiget:periodSummary];
            if (periodSummary.totalPay && canViewPayDetailsWiget && periodSummary.actualsByPayCode.count > 0)
            {
                GrossPayTimeHomeViewController *grossPayTimeHomeViewController = [self.injector getInstance:[GrossPayTimeHomeViewController class]];
                [grossPayTimeHomeViewController setupWithGrossSummary:periodSummary delegate:self];
                [self.childControllerHelper addChildController:grossPayTimeHomeViewController
                                            toParentController:self
                                               inContainerView:self.grossPayContainerView];
                self.grossPayTimeHomeViewController = grossPayTimeHomeViewController;
                CGFloat heightForPayCodes = [self calculateHeightForPayWidgetLegends:periodSummary.actualsByPayCode.count
                                                                       PayPermission:periodSummary.payAmountDetailsPermission];
                
                self.grossPayContainerHeightConstraint.constant = 330.f + heightForPayCodes;
            }
            
            [self.view layoutIfNeeded];
            return nil;
        } error:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.widthConstraint.constant = CGRectGetWidth(self.view.bounds);
    if(self.topLayoutGuide.length == 0){
        self.scrollView.contentInset = UIEdgeInsetsZero;
    }
}


#pragma mark - <TimesheetSummaryControllerDelegate>

- (void)timesheetSummaryControllerDidTapPreviousButton:(TimesheetSummaryController *)timesheetSummaryController
{
    [self.timesheetExtrasPromise  cancel];
    [self.delegate timesheetDetailsControllerRequestsPreviousTimesheet:self];
}

- (void)timesheetSummaryControllerDidTapNextButton:(TimesheetSummaryController *)timesheetSummaryController
{
    [self.timesheetExtrasPromise  cancel];
    [self.delegate timesheetDetailsControllerRequestsNextTimesheet:self];
}

- (void)timesheetSummaryControllerDidTapissuesButton:(TimesheetSummaryController *)timesheetSummaryController
{
    ViolationsSummaryController *violationsSummaryController = [self.injector getInstance:[ViolationsSummaryController class]];
    
    AllViolationSections *allViolationSections = self.timesheetAdditionalInfo.allViolationSections;
    KSDeferred *deferred = [self.injector getInstance:[KSDeferred class]];
    [deferred resolveWithValue:allViolationSections];    
    [violationsSummaryController setupWithViolationSectionsPromise:deferred.promise
                                                          delegate:self];
    
    [self.navigationController pushViewController:violationsSummaryController animated:YES];
}

- (void)timesheetSummaryControllerUpdateViewHeight:(TimesheetSummaryController *)timesheetSummaryController height:(CGFloat)height
{
    self.timesheetSummaryHeightConstraint.constant = height;
}

#pragma mark - <TimesheetBreakdownControllerDelegate>

- (void)timeSheetBreakdownController:(TimesheetBreakdownController *)timeSheetBreakdownController didSelectDayWithDate:(NSDate *)date dayTimeSummaries:(NSArray *)dayTimeSummaries indexPath:(NSIndexPath *)indexPath {
    self.selectdDayIndex = indexPath.row;
    DayController *dayController = [self.injector getInstance:[DayController class]];
    [dayController setupWithPunchChangeObserverDelegate:self
                                    timesheetDaySummary:dayTimeSummaries[indexPath.row]
                                         hasBreakAccess:[self showBreakHours]
                                               delegate:nil 
                                                userURI:self.userURI
                                                   date:date];
    
    self.dayController = dayController;
    [self.navigationController pushViewController:dayController animated:YES];
}

- (void)timeSheetBreakdownController:(TimesheetBreakdownController *)timeSheetBreakdownController didUpdateHeight:(CGFloat) height
{
    self.timesheetBreakDownContainerHeightConstraint.constant = height;
}

#pragma mark - <ViolationsSummaryControllerDelegate>

- (KSPromise *)violationsSummaryControllerDidRequestViolationSectionsPromise:(ViolationsSummaryController *)violationsSummaryController
{
    return [self updatedViolationSectionsPromise];
}

- (KSPromise *)violationsButtonControllerDidRequestUpdatedViolationSectionsPromise:(ViolationsButtonController *)violationsButtonController
{
    return [self allViolationSectionsPromise];
}

- (KSPromise *)allViolationSectionsPromise
{
    AllViolationSections *allViolationSections = self.timesheetAdditionalInfo.allViolationSections;
    KSDeferred *deferred = [[KSDeferred alloc] init];
    [deferred resolveWithValue:allViolationSections];
    return  deferred.promise;
}

#pragma mark - <PunchChangeObserverDelegate>

- (KSPromise *)punchOverviewEditControllerDidUpdatePunch
{
    KSDeferred *overviewDeferred = [[KSDeferred alloc]init];
    KSPromise *timesheetInfoPromise =  [self.delegate timesheetDetailsControllerRequestsLatestPunches:self];
    [timesheetInfoPromise then:^id(TimesheetInfo *timesheetInfo) {
        self.timesheet = timesheetInfo;
        [self.auditHistoryStorage deleteAllRows];
        
        TimesheetSummaryController *timesheetSummaryController = [self.injector getInstance:[TimesheetSummaryController class]];
        [timesheetSummaryController setupWithDelegate:self
                                                    cursor:self.cursor
                                                 timesheet:self.timesheet];
        [self.childControllerHelper replaceOldChildController:self.timesheetSummaryController
                                       withNewChildController:timesheetSummaryController
                                           onParentController:self
                                              onContainerView:self.timesheetSummaryContainerView];
        self.timesheetSummaryController = timesheetSummaryController;

        DayTimeSummaryController *dayTimeSummaryController = [self.injector getInstance:[DayTimeSummaryController class]];
        KSDeferred *workHoursDeferred = [[KSDeferred alloc] init];
        [workHoursDeferred resolveWithValue:timesheetInfo.timePeriodSummary];
        [dayTimeSummaryController setupWithDelegate:nil
                               placeHolderWorkHours:nil
                                   workHoursPromise:workHoursDeferred.promise
                                     hasBreakAccess:[self showBreakHours]
                                     isScheduledDay:YES
                          todaysDateContainerHeight:0.0];
        
        [self.childControllerHelper replaceOldChildController:self.dayTimeSummaryController
                                       withNewChildController:dayTimeSummaryController
                                           onParentController:self
                                              onContainerView:self.workHoursContainerView];
        self.dayTimeSummaryController = dayTimeSummaryController;

        
        KSPromise *timesheetAdditionalInfoPromise = [self updatedViolationSectionsPromise];
        [timesheetAdditionalInfoPromise then:^id(id value) {
            [self.spinnerOperationsCounter decrement];
            self.timesheet = [self fetchUpdatedTimesheetInfoUsingTimesheetAdditionalInfo:self.timesheetAdditionalInfo];
            TimePeriodSummary *periodSummary = self.timesheet.timePeriodSummary;
            TimesheetDaySummary *timesheetDaySummary = periodSummary.dayTimeSummaries[self.selectdDayIndex];
            
            if ([self.delegate conformsToProtocol:@protocol(TimesheetDetailsControllerDelegate)] && [self.delegate respondsToSelector:@selector(timeSheetDetailsControllerDidCompleteRequestForTimeSheetSummary:)]) {
                [self.delegate timeSheetDetailsControllerDidCompleteRequestForTimeSheetSummary:periodSummary];
            }

            TimesheetBreakdownController *timesheetBreakdownController = [self.injector getInstance:[TimesheetBreakdownController class]];
            [timesheetBreakdownController setupWithDayTimeSummaries:periodSummary.dayTimeSummaries
                                                                delegate:self];

            [self.childControllerHelper replaceOldChildController:self.timesheetBreakdownController
                                           withNewChildController:timesheetBreakdownController
                                               onParentController:self
                                                  onContainerView:self.timesheetBreakdownContainerView];
            
            self.timesheetBreakdownController = timesheetBreakdownController;
            
            [self.dayController updateWithDayTimeSummaries:timesheetDaySummary];
            
            BOOL canViewPayDetailsWiget = [self canViewPayDetailsWiget:periodSummary];
            if (periodSummary.totalPay && canViewPayDetailsWiget && periodSummary.actualsByPayCode.count > 0)
            {
                GrossPayTimeHomeViewController *grossPayTimeHomeViewController = [self.injector getInstance:[GrossPayTimeHomeViewController class]];
                [grossPayTimeHomeViewController setupWithGrossSummary:periodSummary delegate:self];
                
                if (self.grossPayTimeHomeViewController) {
                    [self.childControllerHelper replaceOldChildController:self.grossPayTimeHomeViewController
                                                   withNewChildController:grossPayTimeHomeViewController
                                                       onParentController:self
                                                          onContainerView:self.grossPayContainerView];
                }
                else{
                    [self.childControllerHelper addChildController:grossPayTimeHomeViewController
                                                toParentController:self
                                                   inContainerView:self.grossPayContainerView];
                }
                self.grossPayTimeHomeViewController = grossPayTimeHomeViewController;
                [self.grossPayContainerView setHidden:NO];
                CGFloat heightForPayCodes = [self calculateHeightForPayWidgetLegends:periodSummary.actualsByPayCode.count PayPermission:periodSummary.payAmountDetailsPermission];
                self.grossPayContainerHeightConstraint.constant = 330.f + heightForPayCodes;
            }
            else
            {
                self.grossPayContainerHeightConstraint.constant = 0.0f;
                [self.grossPayContainerView setHidden:YES];
                [self.view setNeedsLayout];
            }
            
            [overviewDeferred resolveWithValue:value];
            [self.view layoutIfNeeded];
            return value;
        } error:^id(NSError *error) {
            [self.spinnerOperationsCounter decrement];
            [overviewDeferred rejectWithError:error];
            return error;
        }];
        
        return nil;
    } error:^id(NSError *error) {
        [self.spinnerOperationsCounter decrement];
        [overviewDeferred rejectWithError:error];
        return nil;
    }];
    return overviewDeferred.promise;
    
}

#pragma mark <GrossPayTimeHomeControllerDelegate>

-(void)grossPayTimeHomeControllerIntendsToUpdateHeight:(CGFloat)height
                                             viewItems:(ViewItemsAction)action
{
    if(action==More)
    {
        self.grossPayContainerHeightConstraint.constant = 360.f + height;
    }
    else
    {
        self.grossPayContainerHeightConstraint.constant = 330.f + height;
    }
}

#pragma mark - Private

- (KSPromise *)updatedViolationSectionsPromise
{
    KSPromise *timesheetInfoPromise = [self.timesheetInfoAndPermissionsRepository fetchTimesheetInfoForTimsheetUri:self.timesheet.uri
                                                                                                           userUri:self.userURI];
    [self.spinnerOperationsCounter increment];
    return [timesheetInfoPromise then:^id(TimesheetAdditionalInfo *timesheetAdditionalInfo) {
        [self.spinnerOperationsCounter decrement];
        self.timesheetAdditionalInfo = timesheetAdditionalInfo;
        AllViolationSections *allViolationSections = self.timesheetAdditionalInfo.allViolationSections;
        return allViolationSections;
    } error:^id(NSError *error) {
        [self.spinnerOperationsCounter decrement];
        return error;
    }];
}

- (BOOL)showBreakHours
{
    if ([self.punchRulesStorage.userSession.currentUserURI isEqualToString:self.userURI])
    {
        return self.punchRulesStorage.breaksRequired;
    }
    else
    {
        return self.hasBreakAccess;
    }
}


-(CGFloat )calculateHeightForPayWidgetLegends:(NSUInteger)count PayPermission:(BOOL)payPermission
{
    CGFloat heightForViewMore = 0.0f;
    if(payPermission)
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

-(TimesheetInfo *)fetchUpdatedTimesheetInfoUsingTimesheetAdditionalInfo:(TimesheetAdditionalInfo*)timesheetAdditionalInfo
{
    TimePeriodSummary *timePeriodSummary = self.timesheet.timePeriodSummary;
    TimePeriodSummary *updatedTimePeriodSummary = [[TimePeriodSummary alloc]
                                                                      initWithRegularTimeComponents:timePeriodSummary
                                                                              .regularTimeComponents
                                                                                breakTimeComponents:timePeriodSummary
                                                                                        .breakTimeComponents
                                                                          timesheetPermittedActions:timesheetAdditionalInfo
                                                                                  .timesheetPermittedActions
                                                                                 overtimeComponents:timePeriodSummary
                                                                                         .overtimeComponents
                                                                               payDetailsPermission:timesheetAdditionalInfo
                                                                                       .payDetailsPermission
                                                                                   dayTimeSummaries:timePeriodSummary
                                                                                           .dayTimeSummaries
                                                                                           totalPay:timePeriodSummary
                                                                                                   .totalPay
                                                                                         totalHours:timePeriodSummary
                                                                                                 .totalHours
                                                                                   actualsByPayCode:timePeriodSummary
                                                                                           .actualsByPayCode
                                                                               actualsByPayDuration:timePeriodSummary
                                                                                       .actualsByPayDuration
                                                                                payAmountPermission:timesheetAdditionalInfo
                                                                                        .payAmountDetailsPermission
                                                                              scriptCalculationDate:timesheetAdditionalInfo
                                                                                      .scriptCalculationDateValue
                                                                                  timeOffComponents:timePeriodSummary
                                                                                          .timeOffComponents
                                                                                     isScheduledDay:timePeriodSummary.isScheduledDay];
    
    TimesheetInfo *info = [[TimesheetInfo alloc] initWithTimeSheetApprovalStatus:self.timesheet.approvalStatus
                                                     nonActionedValidationsCount:self.timesheet.nonActionedValidationsCount
                                                               timePeriodSummary:updatedTimePeriodSummary
                                                                     issuesCount:self.timesheet.issuesCount
                                                                          period:self.timesheet.period
                                                                             uri:self.timesheet.uri];
    return info;
}

-(BOOL)canViewPayDetailsWiget:(TimePeriodSummary *)timePeriodSummary
{
    if ([self.punchRulesStorage.userSession.currentUserURI isEqualToString:self.userURI])
    {
        return timePeriodSummary.payDetailsPermission;
    }
    else
    {
        return self.hasPayRollSummary && self.punchRulesStorage.canViewPayDetails;
    }
}



@end
