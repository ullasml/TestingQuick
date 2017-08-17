#import <UIKit/UIKit.h>
#import "TimesheetDetailsController.h"
#import <Blindside/BSInjector.h>
#import <repliconkit/AppConfig.h>


@class ChildControllerHelper;
@class TimesheetRepository;
@protocol SpinnerDelegate;
@class TimesheetForUserWithWorkHours;
@class ApprovalsService;
@class ApprovalsModel;
@class OEFTypesRepository;
@class UserPermissionsStorage;

@interface TimesheetContainerController : UIViewController <TimesheetDetailsControllerDelegate,CommentViewControllerDelegate,WidgetTimesheetDetailsControllerDelegate>

@property (nonatomic, readonly) ChildControllerHelper *childControllerHelper;
@property (nonatomic, weak, readonly) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic, readonly) TimesheetRepository *timesheetRepository;
@property (nonatomic, readonly) OEFTypesRepository *oefTypesRepository;
@property (nonatomic, readonly) WidgetTimesheetRepository *widgetTimesheetRepository;
@property (nonatomic, readonly) TimesheetForUserWithWorkHours *timesheet;
@property (nonatomic, readonly) id<BSInjector> injector;
@property (nonatomic, readonly) ApprovalsModel *approvalsModel;
@property (nonatomic, readonly) ApprovalsService *approvalsService;
@property (nonatomic, readonly) NSNotificationCenter *notificationCenter;
@property (nonatomic, readonly) UIActivityIndicatorView *spinnerViewForActionButtonFlow;
@property (nonatomic, readonly) TimePeriodSummary *timePeriodSummary;
@property (nonatomic, readonly) AppConfig *appConfig;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithChildControllerHelper:(ChildControllerHelper *)childControllerHelper
                    widgetTimesheetRepository:(WidgetTimesheetRepository *)widgetTimesheetRepository
                          timesheetRepository:(TimesheetRepository *)timesheetRepository
                           notificationCenter:(NSNotificationCenter *)notificationCenter
                           oefTypesRepository:(OEFTypesRepository *)oefTypesRepository
                             approvalsService:(ApprovalsService *)approvalsService
                              spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                               approvalsModel:(ApprovalsModel *)approvalsModel
                                    appConfig:(AppConfig *)appConfig;

- (void)setupWithTimesheet:(TimesheetForUserWithWorkHours *)timesheet;
@end
