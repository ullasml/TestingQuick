
#import <UIKit/UIKit.h>
#import "PunchOutDelegate.h"
#import "TimesheetDayTimeLineController.h"
#import "TimesheetButtonController.h"
#import "ViolationsButtonController.h"
#import "ViolationsSummaryController.h"
#import "DayTimeSummaryController.h"


@class LocalPunch;
@class ButtonStylist;
@class TimerProvider;
@class DurationCalculator;
@class DurationStringPresenter;
@class AddressControllerPresenter;
@class LastPunchLabelTextPresenter;
@class TimesheetButtonControllerPresenter;
@class TimesheetDetailsControllerProvider;
@class DayTimeSummaryControllerProvider;
@class ChildControllerHelper;
@class KSPromise;
@class ChildControllerHelper;
@class ViolationRepository;
@class DateProvider;
@protocol ProjectOnBreakControllerDelegate;
@protocol Punch;
@protocol Theme;
@protocol UserSession;
@class WorkHoursStorage;


@interface ProjectOnBreakController : UIViewController <TimesheetDayTimeLineControllerDelegate, TimesheetButtonControllerDelegate, ViolationsButtonControllerDelegate, ViolationsSummaryControllerDelegate,DayTimeSummaryUpdateDelegate>

@property (nonatomic, readonly) id<Theme> theme;
@property (nonatomic, readonly) TimerProvider *timerProvider;
@property (nonatomic, readonly) LocalPunch *punch;
@property (nonatomic, readonly) id<ProjectOnBreakControllerDelegate> delegate;
@property (nonatomic, readonly) ButtonStylist *buttonStylist;
@property (nonatomic, readonly) TimesheetButtonControllerPresenter *timesheetButtonControllerPresenter;
@property (nonatomic, readonly) LastPunchLabelTextPresenter *lastPunchLabelTextPresenter;
@property (nonatomic, readonly) AddressControllerPresenter *addressControllerPresenter;
@property (nonatomic, readonly) DayTimeSummaryControllerProvider *dayTimeSummaryControllerProvider;
@property (nonatomic, readonly) ChildControllerHelper *childControllerHelper;
@property (nonatomic, readonly) ViolationRepository *violationRepository;
@property (nonatomic, readonly) DurationStringPresenter *durationStringPresenter;
@property (nonatomic, readonly) DurationCalculator *durationCalculator;
@property (nonatomic, readonly) KSPromise *serverDidFinishPunchPromise;
@property (nonatomic, readonly) DateProvider *dateProvider;
@property (nonatomic, readonly) WorkHoursStorage *workHoursStorage;
@property (nonatomic, readonly) id<UserSession> userSession;
@property (nonatomic, readonly) NSTimer *timer;
@property (nonatomic, readonly) NSUserDefaults *defaults;


@property (nonatomic, readonly, weak)  UILabel *punchAttributesLabel;
@property (nonatomic, readonly, weak)  UIButton *punchOutButton;
@property (nonatomic, readonly, weak)  UIButton *resumeWorkButton;
@property (nonatomic, readonly, weak)  UIView *addressLabelContainer;
@property (nonatomic, readonly, weak)  UILabel *punchDurationTimerLabel;
@property (nonatomic, readonly, weak)  UIView *timeLineCardContainerView;
@property (nonatomic, readonly, weak)  UIView *workHoursContainerView;
@property (nonatomic, readonly, weak)  UIView *timesheetButtonContainerView;
@property (nonatomic, readonly, weak)  UIView *violationsButtonContainerView;
@property (nonatomic, readonly, weak)  UIView *cardContainerView;
@property (nonatomic, readonly, weak)  UIScrollView *scrollView;
@property (nonatomic, readonly, weak)  UIView *containerView;


@property (nonatomic, readonly, weak)  NSLayoutConstraint *widthConstraint;
@property (nonatomic, readonly, weak)  NSLayoutConstraint *timeLineHeightConstraint;
@property (nonatomic, readonly, weak)  NSLayoutConstraint *violationsButtonHeightConstraint;
@property (nonatomic, readonly, weak)  NSLayoutConstraint *workHoursContainerHeight;



+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

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
                                                     theme:(id <Theme>)theme;

- (void)setupWithAddressControllerPresenter:(AddressControllerPresenter *)addressControllerPresenter
                serverDidFinishPunchPromise:(KSPromise *)serverDidFinishPromise
                                   delegate:(id<ProjectOnBreakControllerDelegate>)delegate
                                      punch:(id<Punch>)punch
                             punchesPromise:(KSPromise *)punchesPromise;

- (void) updatePunchDurationLabel;

@end


@protocol ProjectOnBreakControllerDelegate <PunchOutDelegate>

- (void)projectonBreakControllerDidResumeWork:(ProjectOnBreakController *)onBreakController;

@end
