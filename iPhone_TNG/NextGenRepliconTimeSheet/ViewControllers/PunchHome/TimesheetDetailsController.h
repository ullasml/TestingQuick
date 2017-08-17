#import <UIKit/UIKit.h>
#import "TimesheetBreakdownController.h"
#import "ViolationsSummaryController.h"
#import "TimesheetSummaryController.h"
#import "PunchOverviewController.h"
#import "GrossPayTimeHomeViewController.h"

@class TimesheetDetailsController;
@class WorkHoursController;
@class GrossPayController;
@class TimesheetDetailsPresenter;
@class SpinnerOperationsCounter;
@class ChildControllerHelper;
@class TimeSummaryRepository;
@class ViolationRepository;
@class WorkHoursPromise;
@class KSPromise;
@class KSDeferred;
@class UserPermissionsStorage;
@protocol Cursor;
@protocol Theme;
@protocol PayWidgetPermissionProvider;
@class GrossPayTimeHomeViewController;
@class TimePeriodSummary;
@class TimesheetInfo;
@class TimesheetInfoAndPermissionsRepository;
@class IndexCursor;
@class AuditHistoryStorage;


@protocol TimesheetDetailsControllerDelegate <NSObject>

@optional
- (KSPromise*)timesheetDetailsControllerRequestsLatestPunches:(TimesheetDetailsController *)timesheetDetailsController;
- (void)timesheetDetailsControllerRequestsPreviousTimesheet:(TimesheetDetailsController *)timesheetDetailsController;
- (void)timesheetDetailsControllerRequestsNextTimesheet:(TimesheetDetailsController *)timesheetDetailsController;
- (void)timeSheetDetailsControllerDidCompleteRequestForTimeSheetSummary:(TimePeriodSummary *)timePeriodSummary;

@end

@interface TimesheetDetailsController : UIViewController <TimesheetBreakdownControllerDelegate, TimesheetSummaryControllerDelegate, ViolationsSummaryControllerDelegate, PunchChangeObserverDelegate, GrossPayTimeHomeControllerDelegate>

@property (nonatomic, readonly) id<Theme> theme;
@property (nonatomic, readonly) id<PayWidgetPermissionProvider> payWidgetPermissionProvider;
@property (nonatomic, readonly) id<Timesheet> timesheet;
@property (weak, nonatomic, readonly) UIView *timesheetSummaryContainerView;
@property (weak, nonatomic, readonly) UIView *grossPayContainerView;
@property (weak, nonatomic, readonly) UIView *workHoursContainerView;
@property (weak, nonatomic, readonly) UIView *separatorLineView;
@property (weak, nonatomic, readonly) UIView *timesheetBreakdownContainerView;
@property (weak, nonatomic, readonly) UIScrollView *scrollView;
@property (weak, nonatomic, readonly) NSLayoutConstraint *violationsButtonHeightConstraint;
@property (weak, nonatomic, readonly) NSLayoutConstraint *timesheetBreakDownContainerHeightConstraint;
@property (weak, nonatomic, readonly) NSLayoutConstraint *grossPayContainerHeightConstraint;
@property (weak, nonatomic, readonly) IBOutlet NSLayoutConstraint *timesheetSummaryHeightConstraint;



@property (nonatomic, readonly) ChildControllerHelper *childControllerHelper;
@property (nonatomic, readonly) TimeSummaryRepository *timeSummaryRepository;
@property (nonatomic, weak, readonly) id<TimesheetDetailsControllerDelegate> delegate;
@property (nonatomic, readonly) SpinnerOperationsCounter *spinnerOperationsCounter;
@property (nonatomic, copy, readonly) NSString *userURI;
@property (nonatomic, readonly) id<Cursor> cursor;
@property (nonatomic, readonly) UserPermissionsStorage *punchRulesStorage;
@property (nonatomic, readonly) BOOL hasPayRollSummary;
@property (nonatomic, readonly) TimesheetInfoAndPermissionsRepository *timesheetInfoAndPermissionsRepository;
@property (nonatomic, readonly) AuditHistoryStorage *auditHistoryStorage;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTimesheetInfoAndPermissionsRepository:(TimesheetInfoAndPermissionsRepository *)timesheetInfoAndPermissionsRepository
                                        childControllerHelper:(ChildControllerHelper *)childControllerHelper
                                        timeSummaryRepository:(TimeSummaryRepository *)timeSummaryRepository
                                          violationRepository:(ViolationRepository *)violationRepository
                                          auditHistoryStorage:(AuditHistoryStorage *)auditHistoryStorage
                                            punchRulesStorage:(UserPermissionsStorage *)punchRulesStorage
                                                        theme:(id <Theme>)theme NS_DESIGNATED_INITIALIZER;

- (void)setupWithSpinnerOperationsCounter:(SpinnerOperationsCounter *)spinnerOperationsCounter
                                 delegate:(id <TimesheetDetailsControllerDelegate>)delegate
                                timesheet:(id<Timesheet> )timesheet
                        hasPayrollSummary:(BOOL)hasPayrollSummary
                           hasBreakAccess:(BOOL)hasBreakAccess
                                   cursor:(IndexCursor *)cursor
                                  userURI:(NSString *)userURI
                                    title:(NSString *)title;
@end
