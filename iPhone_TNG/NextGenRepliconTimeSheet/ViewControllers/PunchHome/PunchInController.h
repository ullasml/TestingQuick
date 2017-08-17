#import <UIKit/UIKit.h>
#import "TimesheetDayTimeLineController.h"
#import "TimesheetButtonController.h"
#import "ViolationsButtonController.h"
#import "ViolationsSummaryController.h"
#import "DayTimeSummaryController.h"


@protocol Theme;
@protocol PunchInControllerDelegate;
@class TimesheetButtonControllerPresenter;
@class TimesheetDetailsControllerProvider;
@class DayTimeSummaryControllerProvider;
@class ChildControllerHelper;
@class KSPromise;
@class ViolationRepository;
@class DateProvider;
@protocol UserSession;
@class WorkHoursStorage;
@class DurationCalculator;


@interface PunchInController : UIViewController <TimesheetDayTimeLineControllerDelegate, TimesheetButtonControllerDelegate, ViolationsButtonControllerDelegate, ViolationsSummaryControllerDelegate, DayTimeSummaryUpdateDelegate>

@property (nonatomic, readonly) TimesheetButtonControllerPresenter *timesheetButtonControllerPresenter;
@property (nonatomic, readonly) DayTimeSummaryControllerProvider *dayTimeSummaryControllerProvider;
@property (nonatomic, readonly) ChildControllerHelper *childControllerHelper;
@property (nonatomic, readonly) ViolationRepository *violationRepository;
@property (nonatomic, readonly) WorkHoursStorage *workHoursStorage;
@property (nonatomic, readonly) DurationCalculator *durationCalculator;
@property (nonatomic, readonly) id<UserSession> userSession;
@property (nonatomic, readonly) DateProvider *dateProvider;
@property (nonatomic, readonly) NSUserDefaults *defaults;
@property (nonatomic, readonly) id<Theme> theme;

@property (weak, nonatomic, readonly) id<PunchInControllerDelegate>delegate;
@property (nonatomic, readonly) KSPromise *serverDidFinishPunchPromise;

@property (weak, nonatomic, readonly) UIButton *punchInButton;
@property (weak, nonatomic, readonly) UIScrollView *scrollView;
@property (weak, nonatomic, readonly) UIView *containerView;
@property (weak, nonatomic, readonly) UIView *workHoursContainerView;
@property (weak, nonatomic, readonly) UIView *timeLineCardContainerView;
@property (weak, nonatomic, readonly) UIView *timesheetButtonContainerView;
@property (weak, nonatomic, readonly) UIView *violationsButtonContainerView;

@property (weak, nonatomic, readonly) NSLayoutConstraint *timeLineHeightConstraint;
@property (weak, nonatomic, readonly) NSLayoutConstraint *violationsButtonHeightConstraint;



+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTimesheetButtonControllerPresenter:(TimesheetButtonControllerPresenter *)timesheetButtonControllerPresenter
                          dayTimeSummaryControllerProvider:(DayTimeSummaryControllerProvider *)dayTimeSummaryControllerProvider
                                     childControllerHelper:(ChildControllerHelper *)childControllerHelper
                                       violationRepository:(ViolationRepository *)violationRepository
                                          workHoursStorage:(WorkHoursStorage *)workHoursStorage
                                              dateProvider:(DateProvider *)dateProvider
                                               userSession:(id <UserSession>)userSession
                                                  defaults:(NSUserDefaults *)defaults
                                                     theme:(id <Theme>)theme;

- (void)setupWithServerDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise
                                    delegate:(id<PunchInControllerDelegate>)delegate
                              punchesPromise:(KSPromise *)punchesPromise;

@end


@protocol PunchInControllerDelegate <NSObject>

- (void)punchInControllerDidPunchIn:(PunchInController *)punchInController;

@end
