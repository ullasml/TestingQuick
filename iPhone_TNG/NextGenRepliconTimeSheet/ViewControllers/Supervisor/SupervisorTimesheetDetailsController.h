#import <UIKit/UIKit.h>
#import "GoldenAndNonGoldenTimesheetsController.h"
#import "SupervisorTimesheetSummaryController.h"
#import "GrossPayTimeHomeViewController.h"

@protocol Theme;
@protocol SupervisorTimesheetDetailsControllerDelegate;
@class ChildControllerHelper;
@class TimesheetPeriodCursor;
@class UserPermissionsStorage;


@interface SupervisorTimesheetDetailsController : UIViewController <SupervisorTimesheetSummaryControllerDelegate, TimesheetUserControllerDelegate,GrossPayTimeHomeControllerDelegate>

@property (weak, nonatomic, readonly) UIScrollView *scrollView;
@property (weak, nonatomic, readonly) UIView *scrollableContentView;
@property (weak, nonatomic, readonly) UIView *grossPayContainerView;
@property (weak, nonatomic, readonly) UIView *summaryCardContainerView;
@property (weak, nonatomic, readonly) UIView *workHoursContainerView;
@property (weak, nonatomic, readonly) UIView *goldenTimesheetContainerView;
@property (weak, nonatomic, readonly) UIView *nongoldenTimesheetContainerView;
@property (weak, nonatomic, readonly) UIView *violationsButtonContainerView;
@property (weak, nonatomic, readonly) UIView *timesheetSummaryContainerView;

@property (weak, nonatomic, readonly) NSLayoutConstraint *goldenTimesheetContainerHeightConstraint;
@property (weak, nonatomic, readonly) NSLayoutConstraint *nongoldenTimesheetContainerHeightConstraint;
@property (weak, nonatomic, readonly) NSLayoutConstraint *violationsButtonHeightConstraint;
@property (weak, nonatomic, readonly) NSLayoutConstraint *grossPayContainerHeightConstraint;
@property (nonatomic, readonly) GoldenAndNonGoldenTimesheetsController *goldenTimesheetUserController;
@property (nonatomic, readonly) GoldenAndNonGoldenTimesheetsController *nongoldenTimesheetUserController;
@property (nonatomic, readonly) ChildControllerHelper *childControllerHelper;
@property (nonatomic, readonly) id<Theme> theme;
@property (nonatomic, readonly) UserPermissionsStorage* punchRulesStorage;
@property (nonatomic, readonly) TimesheetPeriodCursor *cursor;
@property (nonatomic, assign, readonly) TimesheetUserType selectedTimesheetUserType;
@property (nonatomic, readonly) NSIndexPath *selectedIndexPath;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithChildControllerHelper:(ChildControllerHelper *)childControllerHelper
                                        theme:(id<Theme>)theme
                            punchRulesStorage:(UserPermissionsStorage*)punchRulesStorage;

- (void)setupWithTeamTimesheetSummaryPromise:(KSPromise *)teamTimesheetSummaryPromise
                                    delegate:(id<SupervisorTimesheetDetailsControllerDelegate>)delegate;

-(void)refreshSelectedGoldenAndNonGoldenTimesheetsControllerAfterApprovalActions;

@end


@protocol SupervisorTimesheetDetailsControllerDelegate

- (void)supervisorTimesheetDetailsController:(SupervisorTimesheetDetailsController *)supervisorTimesheetDetailsController
         requestsPreviousTimesheetWithCursor:(TimesheetPeriodCursor *)timesheetPeriodCursor;

- (void)supervisorTimesheetDetailsController:(SupervisorTimesheetDetailsController *)supervisorTimesheetDetailsController
             requestsNextTimesheetWithCursor:(TimesheetPeriodCursor *)timesheetPeriodCursor;

@end

