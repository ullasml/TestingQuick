#import <UIKit/UIKit.h>
#import "TimesheetDayTimeLineController.h"
#import "TimesheetButtonController.h"
#import "ViolationsButtonController.h"
#import "ViolationsSummaryController.h"
#import "DayTimeSummaryController.h"
#import "PunchCardController.h"

@class TimesheetButtonControllerPresenter;
@class TimesheetDetailsControllerProvider;
@class DayTimeSummaryControllerProvider;
@class ChildControllerHelper;
@class ViolationRepository;
@class DurationCalculator;
@class WorkHoursStorage;
@class DateProvider;
@class KSPromise;

@protocol ProjectPunchInControllerDelegate;
@protocol UserSession;
@protocol Theme;
@class PunchCardStorage;
@class OEFTypeStorage;
@class UserPermissionsStorage;


@interface ProjectPunchInController : UIViewController <TimesheetDayTimeLineControllerDelegate, TimesheetButtonControllerDelegate, ViolationsButtonControllerDelegate, ViolationsSummaryControllerDelegate, DayTimeSummaryUpdateDelegate,PunchCardControllerDelegate,UIScrollViewDelegate>

@property (nonatomic, readonly) TimesheetButtonControllerPresenter *timesheetButtonControllerPresenter;
@property (nonatomic, readonly) DayTimeSummaryControllerProvider *dayTimeSummaryControllerProvider;
@property (nonatomic, readonly) ChildControllerHelper *childControllerHelper;
@property (nonatomic, readonly) ViolationRepository *violationRepository;
@property (nonatomic, readonly) WorkHoursStorage *workHoursStorage;
@property (nonatomic, readonly) PunchCardStorage *punchCardStorage;
@property (nonatomic, readonly) OEFTypeStorage *oefTypeStorage;
@property (nonatomic, readonly) DurationCalculator *durationCalculator;
@property (nonatomic, readonly) id<UserSession> userSession;
@property (nonatomic, readonly) DateProvider *dateProvider;
@property (nonatomic, readonly) NSUserDefaults *defaults;
@property (nonatomic, readonly) id<Theme> theme;

@property (weak, nonatomic, readonly) id<ProjectPunchInControllerDelegate>delegate;
@property (nonatomic, readonly) KSPromise *serverDidFinishPunchPromise;

@property (weak, nonatomic,readonly)  UIView *workHoursContainerView;
@property (weak, nonatomic,readonly)  UIView *timeLineCardContainerView;
@property (weak, nonatomic,readonly)  UIView *timesheetButtonContainerView;
@property (weak, nonatomic,readonly)  UIView *violationsButtonContainerView;
@property (weak, nonatomic,readonly)  UIView *cardContainerView;
@property (weak, nonatomic,readonly)  UIScrollView *scrollView;
@property (weak, nonatomic,readonly)  UIView *containerView;
@property (weak, nonatomic, readonly) UIButton *punchInButton;

@property (weak, nonatomic,readonly)  NSLayoutConstraint *widthConstraint;
@property (weak, nonatomic,readonly)  NSLayoutConstraint *timeLineHeightConstraint;
@property (weak, nonatomic,readonly)  NSLayoutConstraint *violationsButtonHeightConstraint;
@property (weak, nonatomic,readonly)  NSLayoutConstraint *punchCardHeightConstraint;
@property (weak, nonatomic,readonly)  NSLayoutConstraint *workHoursContainerHeight;

@property (nonatomic,readonly) NSNotificationCenter *notificationCenter;

@property (nonatomic,readonly) UserPermissionsStorage *userPermissionsStorage;



+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;

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
                                                  defaults:(NSUserDefaults *)defaults;

- (void)setupWithServerDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise
                                    delegate:(id<ProjectPunchInControllerDelegate>)delegate
                             punchCardObject:(PunchCardObject *)punchCardObject
                              punchesPromise:(KSPromise *)punchesPromise;

@end


@protocol ProjectPunchInControllerDelegate <NSObject>

- (void)projectPunchInController:(ProjectPunchInController *)punchCardController
      didIntendToPunchWithObject:(PunchCardObject *)punchCardObject;

- (void)projectPunchInController:(ProjectPunchInController *)punchCardController
      didUpdatePunchCardWithObject:(PunchCardObject *)punchCardObject;

@end
