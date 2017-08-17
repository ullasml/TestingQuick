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
@protocol OnBreakControllerDelegate;
@protocol Punch;
@protocol Theme;
@protocol UserSession;
@class WorkHoursStorage;


@interface OnBreakController : UIViewController <TimesheetDayTimeLineControllerDelegate, TimesheetButtonControllerDelegate, ViolationsButtonControllerDelegate, ViolationsSummaryControllerDelegate,DayTimeSummaryUpdateDelegate>

@property (nonatomic, readonly) id<Theme> theme;
@property (nonatomic, readonly) TimerProvider *timerProvider;
@property (nonatomic, readonly) LocalPunch *punch;
@property (nonatomic, readonly) id<OnBreakControllerDelegate> delegate;
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


@property (nonatomic, weak, readonly) UIButton *punchOutButton;
@property (nonatomic, weak, readonly) UILabel *breakStartedLabel;
@property (nonatomic, weak, readonly) UIView *addressLabelContainer;
@property (nonatomic, weak, readonly) UILabel *punchDurationTimerLabel;
@property (nonatomic, weak, readonly) UIButton *resumeWorkButton;
@property (nonatomic, weak, readonly) UIScrollView *scrollView;

@property (nonatomic, weak, readonly) UIView *containerView;
@property (nonatomic, weak, readonly) UIView *timeLineCardContainerView;
@property (nonatomic, weak, readonly) UIView *workHoursContainerView;
@property (nonatomic, weak, readonly) UIView *timesheetButtonContainerView;
@property (nonatomic, weak, readonly) UIView *violationsButtonContainerView;

@property (nonatomic, weak, readonly) NSLayoutConstraint *timeLineHeightConstraint;
@property (nonatomic, weak, readonly) NSLayoutConstraint *violationsButtonHeightConstraint;
@property (nonatomic, weak, readonly) NSLayoutConstraint *workHoursContainerHeight;

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
                                   delegate:(id<OnBreakControllerDelegate>)delegate
                                      punch:(id<Punch>)punch
                             punchesPromise:(KSPromise *)punchesPromise;

- (void) updatePunchDurationLabel;

@end


@protocol OnBreakControllerDelegate <PunchOutDelegate>

- (void)onBreakControllerDidResumeWork:(OnBreakController *)onBreakController;

@end
