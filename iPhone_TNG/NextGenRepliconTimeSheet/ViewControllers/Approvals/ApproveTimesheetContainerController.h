#import <UIKit/UIKit.h>
#import "AstroAwareTimesheet.h"
#import "TimesheetDetailsController.h"
#import <repliconkit/AppConfig.h>


@class ApprovalsModel;
@class ApprovalsService;
@class TimesheetRepository;
@class ChildControllerHelper;
@class LegacyTimesheetApprovalInfo;
@protocol SpinnerDelegate;
@protocol Timesheet;
@protocol ApproveTimesheetContainerControllerDelegate;
@class OEFTypesRepository;


@interface ApproveTimesheetContainerController : UIViewController <TimesheetDetailsControllerDelegate>

@property (nonatomic, readonly) TimesheetRepository *timesheetRepository;
@property (nonatomic, readonly) WidgetTimesheetRepository *widgetTimesheetRepository;
@property (nonatomic, readonly) ChildControllerHelper *childControllerHelper;
@property (nonatomic, readonly) id<Timesheet> userlessTimesheet;
@property (nonatomic, readonly) LegacyTimesheetApprovalInfo *legacyTimesheetApprovalInfo;
@property (nonatomic, readonly) ApprovalsModel *approvalsModel;
@property (nonatomic, readonly) ApprovalsService *approvalsService;
@property (nonatomic, readonly) NSNotificationCenter *notificationCenter;
@property (nonatomic, copy, readonly) NSString *astroTitle;
@property (nonatomic, weak, readonly) id<ApproveTimesheetContainerControllerDelegate> delegate;
@property (nonatomic, weak, readonly) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic, readonly) OEFTypesRepository *oefTypesRepository;
@property (nonatomic, readonly) AppConfig *appConfig;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTimesheetRepository:(TimesheetRepository *)timesheetRepository
                  widgetTimesheetRepository:(WidgetTimesheetRepository *)widgetTimesheetRepository
                      childControllerHelper:(ChildControllerHelper *)childControllerHelper
                         notificationCenter:(NSNotificationCenter *)notificationCenter
                           approvalsService:(ApprovalsService *)approvalsService
                            spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                             approvalsModel:(ApprovalsModel *)approvalsModel
                         oefTypesRepository:(OEFTypesRepository *)oefTypesRepository
                                  appConfig:(AppConfig *)appConfig;

- (void)setupWithLegacyTimesheetApprovalInfo:(LegacyTimesheetApprovalInfo *)legacyTimesheetApprovalInfo
                                   timesheet:(id<Timesheet>)timesheet
                                    delegate:(id<ApproveTimesheetContainerControllerDelegate>)delegate
                                       title:(NSString *)title andUserUri:(NSString *)userUri;



@end


@protocol ApproveTimesheetContainerControllerDelegate <NSObject>

- (void)approveTimesheetContainerController:(ApproveTimesheetContainerController *)approveTimesheetContainerController
                        didApproveTimesheet:(id<Timesheet>)timesheet;

@end
