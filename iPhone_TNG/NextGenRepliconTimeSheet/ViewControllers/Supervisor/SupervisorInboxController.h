#import <UIKit/UIKit.h>
#import "ViolationsSummaryController.h"


@class ViolationsSummaryControllerProvider;
@class OvertimeSummaryControllerProvider;
@class SupervisorInboxController;
@class ApprovalsRepository;
@class KSPromise;
@class SupervisorDashboardSummaryRepository;
@class UserPermissionsStorage;
@class GATracker;
@class LoginService;

@protocol SupervisorInboxControllerDelegate

- (void)supervisorInboxController:(SupervisorInboxController *)supervisorInboxController shouldUpdateHeight:(CGFloat)height;

@end


@interface SupervisorInboxController : UIViewController <UITableViewDataSource, UITableViewDelegate, ViolationsSummaryControllerDelegate>

@property (nonatomic, readonly) ViolationsSummaryControllerProvider *violationsSummaryControllerProvider;
@property (nonatomic, readonly) OvertimeSummaryControllerProvider *overtimeSummaryControllerProvider;
@property (nonatomic, readonly) SupervisorDashboardSummaryRepository *dashboardSummaryRepository;
@property (nonatomic, readonly) ApprovalsRepository *approvalsRepository;
@property (nonatomic, readonly) NSNotificationCenter *notificationCenter;
@property (nonatomic, readonly) UserPermissionsStorage *userPermissionsStorage;
@property (nonatomic, readonly) id<Theme> theme;

@property (weak, nonatomic, readonly) UILabel *headerLabel;
@property (weak, nonatomic, readonly) UIView *separatorView;
@property (weak, nonatomic, readonly) UITableView *tableView;

@property (weak, nonatomic) id <SupervisorInboxControllerDelegate> delegate;

@property (nonatomic, readonly) GATracker *tracker;
@property (nonatomic, readonly) LoginService *loginService;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithViolationsSummaryControllerProvider:(ViolationsSummaryControllerProvider *)violationsSummaryControllerProvider
                          overtimeSummaryControllerProvider:(OvertimeSummaryControllerProvider *)overtimeSummaryControllerProvider
                                 dashboardSummaryRepository:(SupervisorDashboardSummaryRepository *)dashboardSummaryRepository
                                     userPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                                        approvalsRepository:(ApprovalsRepository *)approvalsRepository
                                         notificationCenter:(NSNotificationCenter *)notificationCenter
                                                      theme:(id<Theme>)theme
                                                      tracker:(GATracker *)tracker
                                                 loginService:(LoginService *)loginService NS_DESIGNATED_INITIALIZER;
- (void)updateWithDashboardSummaryPromise:(KSPromise *)dashboardSummaryPromise;

@end
