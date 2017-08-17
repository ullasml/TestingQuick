#import <UIKit/UIKit.h>
#import "PunchOutDelegate.h"
#import "TimesheetDayTimeLineController.h"
#import "TimesheetButtonController.h"
#import "ViolationsButtonController.h"
#import "ViolationsSummaryController.h"
#import "DayTimeSummaryController.h"


@class LocalPunch;
@class BreakType;
@class KSPromise;
@class DateProvider;
@class ButtonStylist;
@class TimerProvider;
@class UserPermissionsStorage;
@class ViolationRepository;
@class DurationCalculator;
@class BreakTypeRepository;
@class ChildControllerHelper;
@class DurationStringPresenter;
@class AddressControllerPresenter;
@class DayTimeSummaryControllerProvider;
@class LastPunchLabelTextPresenter;
@class TimesheetButtonControllerPresenter;
@class TimesheetDetailsControllerProvider;
@protocol Theme;
@protocol Punch;
@protocol ProjectPunchOutControllerDelegate;
@protocol UserSession;
@class WorkHoursStorage;
@class OEFTypeStorage;


@interface ProjectPunchOutController : UIViewController <TimesheetDayTimeLineControllerDelegate, TimesheetButtonControllerDelegate, ViolationsButtonControllerDelegate, ViolationsSummaryControllerDelegate, DayTimeSummaryUpdateDelegate>

@property (nonatomic, readonly) TimesheetButtonControllerPresenter *timesheetButtonControllerPresenter;
@property (nonatomic, readonly) LastPunchLabelTextPresenter *lastPunchLabelTextPresenter;
@property (nonatomic, readonly) DayTimeSummaryControllerProvider *dayTimeSummaryControllerProvider;
@property (nonatomic, readonly) DurationStringPresenter *durationStringPresenter;
@property (nonatomic, readonly) ChildControllerHelper *childControllerHelper;
@property (nonatomic, readonly) BreakTypeRepository *breakTypeRepository;
@property (nonatomic, readonly) ViolationRepository *violationRepository;
@property (nonatomic, readonly) DurationCalculator *durationCalculator;
@property (nonatomic, readonly) UserPermissionsStorage *punchRulesStorage;
@property (nonatomic, readonly) KSPromise *serverDidFinishPunchPromise;
@property (nonatomic, readonly) WorkHoursStorage *workHoursStorage;
@property (nonatomic, readonly) OEFTypeStorage *oefTypeStorage;
@property (nonatomic, readonly) ButtonStylist *buttonStylist;
@property (nonatomic, readonly) TimerProvider *timerProvider;
@property (nonatomic, readonly) id<UserSession> userSession;
@property (nonatomic, readonly) DateProvider *dateProvider;
@property (nonatomic, readonly) NSUserDefaults *defaults;
@property (nonatomic, readonly) id<Theme> theme;
@property (nonatomic, readonly) NSTimer *timer;
@property (nonatomic, readonly) LocalPunch *punch;


@property (nonatomic, readonly) AddressControllerPresenter *addressControllerPresenter;
@property (weak, nonatomic, readonly) id<ProjectPunchOutControllerDelegate> delegate;

@property (weak, nonatomic, readonly) UIButton *punchOutButton;
@property (weak, nonatomic, readonly) UIButton *breakButton;
@property (weak, nonatomic, readonly) UIButton *transferButton;
@property (weak, nonatomic, readonly) UILabel *punchDurationTimerLabel;
@property (weak, nonatomic, readonly) UIView *addressLabelContainer;
@property (weak, nonatomic, readonly) UIView *workHoursContainerView;
@property (weak, nonatomic, readonly) UIView *timeLineCardContainerView;
@property (weak, nonatomic, readonly) UIView *timesheetButtonContainerView;
@property (weak, nonatomic, readonly) UIView *violationsButtonContainerView;
@property (weak, nonatomic, readonly) UIView *cardContainerView;
@property (weak, nonatomic, readonly) UILabel *punchAttributesLabel;


@property (weak, nonatomic, readonly) NSLayoutConstraint *breakButtonToPunchInLabelVerticalConstraint;
@property (weak, nonatomic, readonly) NSLayoutConstraint *clockOutButtonToPunchInLabelVerticalConstraint;
@property (weak, nonatomic, readonly) NSLayoutConstraint *timeLineHeightConstraint;
@property (weak, nonatomic, readonly) NSLayoutConstraint *violationsButtonHeightConstraint;
@property (weak, nonatomic, readonly) NSLayoutConstraint *workHoursContainerHeight;

@property (nonatomic, readonly, weak)  UIScrollView *scrollView;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;

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
                                                     theme:(id <Theme>)theme;

- (void)setupWithAddressControllerPresenter:(AddressControllerPresenter *)addressControllerPresenter
                serverDidFinishPunchPromise:(KSPromise *)serverDidFinishPromise
                                   delegate:(id<ProjectPunchOutControllerDelegate>)delegate
                                      punch:(id<Punch>)punch
                             punchesPromise:(KSPromise *)punchesPromise
;


- (void)updatePunchDurationLabel;

@end


@protocol ProjectPunchOutControllerDelegate <PunchOutDelegate>

- (void)projectPunchOutControllerDidTakeBreakWithDate:(NSDate *)breakDate
                                            breakType:(BreakType *)breakType;
- (void)projectPunchOutControllerDidTakeBreak;
- (void)projectPunchOutControllerDidTransfer:(ProjectPunchOutController*)projectPunchOutController;


@end
