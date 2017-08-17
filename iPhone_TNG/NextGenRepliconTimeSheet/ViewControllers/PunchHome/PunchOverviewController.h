#import <UIKit/UIKit.h>
#import "ViolationsButtonController.h"
#import "DeletePunchButtonController.h"
#import "ViolationsSummaryController.h"
#import "AuditTrailController.h"
#import "PunchAttributeController.h"
#import "PunchDetailsController.h"
#import "Enum.h"
#import "RemotePunch.h"

@protocol Theme;
@protocol SpinnerDelegate;
@class RemotePunch;
@class PunchPresenter;
@class PunchRepository;
@class ViolationRepository;
@class ChildControllerHelper;
@class PunchDetailsController;
@class BreakTypeRepository;
@class UserPermissionsStorage;
@class CalculatePunchTotalService;
@class PunchDetailsControllerProvider;
@protocol Theme;
@protocol SpinnerDelegate;
@protocol PunchChangeObserverDelegate;
@class ReachabilityMonitor;

@interface PunchOverviewController : UIViewController <AuditTrailControllerDelegate, ViolationsButtonControllerDelegate, DeletePunchButtonControllerDelegate, UIActionSheetDelegate, ViolationsSummaryControllerDelegate, PunchDetailsControllerDelegate,PunchAttributeControllerDelegate>

@property (nonatomic, readonly) id<Theme> theme;
@property (nonatomic, readonly, weak) id<SpinnerDelegate> spinnerDelegate;

@property (nonatomic, readonly) RemotePunch *punch;
@property (nonatomic, readonly) ChildControllerHelper *childControllerHelper;
@property (nonatomic, readonly) ViolationRepository *violationRepository;
@property (nonatomic, readonly) UserPermissionsStorage *punchRulesStorage;
@property (nonatomic, readonly) PunchRepository *punchRepository;
@property (nonatomic, readonly) BreakTypeRepository *breakTypeRepository;
@property (nonatomic, readonly) FlowType flowType;


@property (nonatomic, weak, readonly) UIToolbar *toolBar;
@property (nonatomic, weak, readonly) UIBarButtonItem *doneButtonOnToolBar;
@property (nonatomic, weak, readonly) UIDatePicker *datePicker;
@property (nonatomic, weak, readonly) UIView *punchDetailsContainerView;
@property (nonatomic, weak, readonly) UIView *violationsButtonContainerView;
@property (nonatomic, weak, readonly) UIView *deletePunchButtonContainerView;
@property (nonatomic, weak, readonly) UIView *auditTrailContainerView;
@property (nonatomic, weak, readonly) UIView *punchAttributeContainerView;


@property (nonatomic, weak, readonly) NSLayoutConstraint *auditTrailContainerViewHeightConstraint;
@property (nonatomic, weak, readonly) NSLayoutConstraint *violationsButtonHeightConstraint;
@property (nonatomic, weak, readonly) NSLayoutConstraint *punchDetailsContainerViewHeightConstraint;
@property (nonatomic, weak, readonly) NSLayoutConstraint *punchAttributeContainerViewHeightConstraint;

@property (weak, nonatomic,readonly)  UIScrollView *scrollView;
@property (nonatomic,readonly) NSNotificationCenter *notificationCenter;

@property (nonatomic,readonly) ReachabilityMonitor *reachabilityMonitor;

@property (weak, nonatomic,readonly)  UIView *containerView;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithChildControllerHelper:(ChildControllerHelper *)childControllerHelper violationRepository:(ViolationRepository *)violationRepository breakTypeRepository:(BreakTypeRepository *)breakTypeRepository punchRulesStorage:(UserPermissionsStorage *)punchRulesStorage punchRepository:(PunchRepository *)punchRepository spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate theme:(id <Theme>)theme notificationCenter:(NSNotificationCenter *)notificationCenter reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor;

- (void)setupWithPunchChangeObserverDelegate:(id<PunchChangeObserverDelegate>)punchChangeObserverDelegate
                                       punch:(RemotePunch *)punch
                                    flowType:(FlowType)flowType
                                     userUri:(NSString *)userUri;

@end

@protocol PunchChangeObserverDelegate<NSObject>

- (KSPromise *)punchOverviewEditControllerDidUpdatePunch;

@end
