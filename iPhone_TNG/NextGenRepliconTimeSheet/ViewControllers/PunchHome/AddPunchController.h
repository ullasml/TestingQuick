#import <UIKit/UIKit.h>
#import "PunchAssemblyWorkflow.h"
#import "PunchOverviewController.h"
#import "PunchAttributeController.h"
#import <repliconkit/ReachabilityMonitor.h>

@class PunchImagePickerControllerProvider;
@class DefaultTableViewCellStylist;
@class ChildControllerHelper;
@class SegmentedControlStylist;
@class UserPermissionsStorage;
@class AllowAccessAlertHelper;
@class ImageNormalizer;
@class BreakTypeRepository;
@class PunchRepository;
@class PunchClock;
@class OEFTypeStorage;

@protocol Theme;
@protocol UserSession;
@protocol SpinnerDelegate;
@class GUIDProvider;
@class ManualPunch;
@class DaySummaryDateTimeProvider;


@interface AddPunchController : UIViewController <UITableViewDataSource, UITableViewDelegate, PunchAssemblyWorkflowDelegate, UIImagePickerControllerDelegate,PunchAttributeControllerDelegate>

@property (weak, nonatomic, readonly) NSLayoutConstraint *punchAttributeContainerViewHeightConstraint;
@property (weak, nonatomic, readonly) UIView *punchAttributeContainerView;
@property (weak, nonatomic, readonly) UISegmentedControl *punchTypeSegmentedControl;
@property (weak, nonatomic, readonly) UITableView *punchDetailsTableView;
@property (weak, nonatomic, readonly) UIDatePicker *datePicker;
@property (weak, nonatomic, readonly) UIView *segmentToTableSeparatorView;
@property (weak, nonatomic, readonly) UIToolbar *toolBar;
@property (weak, nonatomic, readonly) UIBarButtonItem *doneButtonOnToolBar;

@property (nonatomic, readonly) PunchImagePickerControllerProvider *punchImagePickerControllerProvider;
@property (nonatomic, readonly) DaySummaryDateTimeProvider *daySummaryDateTimeProvider;
@property (nonatomic, readonly) ReporteePermissionsStorage *reporteePermissionsStorage;
@property (nonatomic, readonly) DefaultTableViewCellStylist *tableViewCellStylist;
@property (nonatomic, readonly) PunchAttributeController *punchAttributeController;
@property (nonatomic, readonly) SegmentedControlStylist *segmentedControlStylist;
@property (nonatomic, readonly) UserPermissionsStorage *punchRulesStorage;
@property (nonatomic, readonly) BreakTypeRepository *breakTypeRepository;
@property (nonatomic, readonly) ReachabilityMonitor *reachabilityMonitor;
@property (nonatomic, readonly) ChildControllerHelper *childControllerHelper;
@property (nonatomic, readonly) AllowAccessAlertHelper *allowAccessAlertHelper;
@property (nonatomic, readonly) PunchRepository *punchRepository;
@property (nonatomic, readonly) ImageNormalizer *imageNormalizer;
@property (nonatomic, readonly) PunchClock *punchClock;
@property (nonatomic, readonly) NSDateFormatter *dateFormatter;
@property (nonatomic, readonly) id<UserSession>userSession;
@property (nonatomic, readonly) GUIDProvider *guidProvider;
@property (nonatomic, readonly) OEFTypeStorage *oefTypesStotage;
@property (weak, nonatomic,readonly)  UIScrollView *scrollView;
@property (nonatomic, readonly) NSNotificationCenter *notificationCenter;
@property (nonatomic, readonly) ManualPunch *punch;

@property (nonatomic, readonly) id<Theme> theme;

@property (nonatomic, weak, readonly) id<SpinnerDelegate> spinnerDelegate;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithPunchImagePickerControllerProvider:(PunchImagePickerControllerProvider *)punchImagePickerControllerProvider
                                reporteePermissionsStorage:(ReporteePermissionsStorage *)reporteePermissionsStorage
                                daySummaryDateTimeProvider:(DaySummaryDateTimeProvider *)daySummaryDateTimeProvider
                                   segmentedControlStylist:(SegmentedControlStylist *)segmentedControlStylist
                                    allowAccessAlertHelper:(AllowAccessAlertHelper *)allowAccessAlertHelper
                                     childControllerHelper:(ChildControllerHelper *)childControllerHelper
                                      tableViewCellStylist:(DefaultTableViewCellStylist *)tableViewCellStylist
                                       breakTypeRepository:(BreakTypeRepository *)breakTypeRepository
                                       reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                                        notificationCenter:(NSNotificationCenter *)notificationCenter
                                         punchRulesStorage:(UserPermissionsStorage *)punchRulesStorage
                                           imageNormalizer:(ImageNormalizer *)imageNormalizer
                                           punchRepository:(PunchRepository *)punchRepository
                                           spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                                           oefTypesStorage:(OEFTypeStorage *)oefTypesStorage
                                             dateFormatter:(NSDateFormatter *)dateFormatter
                                               userSession:(id <UserSession>)userSession
                                              guidProvider:(GUIDProvider *)guidProvider
                                                punchClock:(PunchClock *)punchClock
                                                     theme:(id <Theme>)theme;

- (void)setupWithPunchChangeObserverDelegate:(id<PunchChangeObserverDelegate>)punchChangeObserverDelegate
                                     userURI:(NSString *)userURI
                                        date:(NSDate *)date;
-(void)reloadWithNewPunchAttributes:(id<Punch>)punch;

@end
