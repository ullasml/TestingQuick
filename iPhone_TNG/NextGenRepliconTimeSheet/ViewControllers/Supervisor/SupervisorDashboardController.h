#import <UIKit/UIKit.h>
#import "ViolationsSummaryController.h"
#import "TimesheetButtonController.h"
#import "SupervisorInboxController.h"
#import "PreviousApprovalsButtonViewController.h"


@class TimesheetButtonControllerPresenter;
@class ChildControllerHelper;
@class DateProvider;
@protocol Theme;
@class SupervisorDashboardSummaryRepository;
@class OvertimeSummaryControllerProvider;
@class UserPermissionsStorage;
@class ErrorBannerViewParentPresenterHelper;

@interface SupervisorDashboardController : UIViewController <TimesheetButtonControllerDelegate, SupervisorInboxControllerDelegate,PreviousApprovalsButtonControllerDelegate>

@property (weak, nonatomic, readonly) UIView        *previousApprovalsButtonContainerView;
@property (weak, nonatomic, readonly) UIView        *timesheetButtonContainerView;
@property (weak, nonatomic, readonly) UIView        *teamStatusContainerView;
@property (weak, nonatomic, readonly) UIView        *trendChartContainerView;
@property (weak, nonatomic, readonly) UIView        *inboxContainerView;
@property (weak, nonatomic, readonly) UIScrollView  *subViewsContainerScrollview;

@property (weak, nonatomic, readonly) NSLayoutConstraint *teamStatusContainerHeightConstraint;
@property (weak, nonatomic, readonly) NSLayoutConstraint *trendChartContainerHeightConstraint;
@property (weak, nonatomic, readonly) IBOutlet NSLayoutConstraint *viewTeamTimesheetContainerHeightConstraint;

@property (nonatomic, readonly) SupervisorDashboardSummaryRepository *supervisorDashboardSummaryRepository;
@property (nonatomic, readonly) ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper;
@property (nonatomic, readonly) TimesheetButtonControllerPresenter *timesheetButtonControllerPresenter;
@property (nonatomic, readonly) OvertimeSummaryControllerProvider *overtimeSummaryControllerProvider;
@property (nonatomic, readonly) UserPermissionsStorage *userPermissionsStorage;
@property (nonatomic, readonly) ChildControllerHelper *childControllerHelper;
@property (nonatomic, readonly) NSDateFormatter *dateFormatter;
@property (nonatomic, readonly) DateProvider *dateProvider;
@property (nonatomic, readonly) id<Theme> theme;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithSupervisorDashboardSummaryRepository:(SupervisorDashboardSummaryRepository *)supervisorDashboardSummaryRepository
                        errorBannerViewParentPresenterHelper:(ErrorBannerViewParentPresenterHelper *)errorBannerViewParentPresenterHelper
                          timesheetButtonControllerPresenter:(TimesheetButtonControllerPresenter *)timesheetButtonControllerPresenter
                           overtimeSummaryControllerProvider:(OvertimeSummaryControllerProvider *)overtimeSummaryControllerProvider
                                       childControllerHelper:(ChildControllerHelper *)childControllerHelper
                                      userPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                                               dateFormatter:(NSDateFormatter *)dateFormatter
                                                dateProvider:(DateProvider *)dateProvider
                                                       theme:(id<Theme>)theme NS_DESIGNATED_INITIALIZER;
- (void)selectApprovalsForModule:(NSString *)module;

@end
