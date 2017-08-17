#import <UIKit/UIKit.h>
#import "SpinnerOperationsCounter.h"
#import "TimesheetDetailsController.h"
#import "CommentViewController.h"
#import <Blindside/BSInjector.h>


@class IndexCursor;
@class TimesheetRepository;
@class ChildControllerHelper;
@class UserPermissionsStorage;
@protocol UserSession;
@class TimeSummaryRepository;
@class DateProvider;
@class TimesheetInfo;
@class TimesheetActionRequestBodyProvider;
@protocol SpinnerDelegate;


@interface TimesheetDetailsSeriesController : UIViewController<SpinnerOperationsCounterDelegate, TimesheetDetailsControllerDelegate, CommentViewControllerDelegate>

@property (nonatomic, readonly) TimesheetActionRequestBodyProvider *timesheetActionRequestBodyProvider;
@property (nonatomic, readonly) UserPermissionsStorage *userPermissionsStorage;
@property (nonatomic, readonly) ChildControllerHelper *childControllerHelper;
@property (nonatomic, readonly) TimesheetRepository *timesheetRepository;
@property (nonatomic, readonly) TimeSummaryRepository *timeSummaryRepository;
@property (nonatomic, readonly) id<UserSession> userSession;
@property (nonatomic, readonly) UIActivityIndicatorView *spinnerView;
@property (nonatomic, readonly) DateProvider *dateProvider;
@property (nonatomic, readonly) TimesheetInfo *timesheetInfo;
@property (nonatomic, readonly) id<BSInjector> injector;
@property (nonatomic, readonly) KSPromise *timesheetPromise;
@property (nonatomic, readonly, weak) id<SpinnerDelegate> spinnerDelegate;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTimesheetActionRequestBodyProvider:(TimesheetActionRequestBodyProvider *)timesheetActionRequestBodyProvider
                                    userPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                                     childControllerHelper:(ChildControllerHelper *)childControllerHelper
                                     timeSummaryRepository:(TimeSummaryRepository *)timeSummaryRepository
                                       timesheetRepository:(TimesheetRepository *)timesheetRepository
                                           spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                                               userSession:(id <UserSession>)userSession
                                              dateProvider:(DateProvider *)dateProvider;

- (void)displayNewTimesheetDetailsController;
@end
