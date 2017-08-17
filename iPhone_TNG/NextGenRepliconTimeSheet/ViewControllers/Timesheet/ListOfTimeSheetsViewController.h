#import <UIKit/UIKit.h>
#import "SpinnerDelegate.h"
#import "ErrorBannerViewController.h"


@class TimesheetModel;
@class TimesheetService;
@class ListOfTimeSheetsCustomCell;
@class ErrorDetailsDeserializer;
@class ErrorDetailsStorage;
@class ErrorBannerViewParentPresenterHelper;

@interface ListOfTimeSheetsViewController : UIViewController <ErrorBannerMonitorObserver>
 
@property (nonatomic, readonly) BOOL isCalledFromMenu;
@property (nonatomic, readonly) UILabel *msgLabel;
@property (nonatomic, readonly) UITableView *timeSheetsTableView;
@property (nonatomic, readonly) UIBarButtonItem *leftButton;
@property (nonatomic, readonly) NSMutableArray *timeSheetsArray;
@property (nonatomic) BOOL isDeltaUpdate;

@property (nonatomic, readonly) TimesheetService *timesheetService;
@property (nonatomic, readonly) TimesheetModel *timesheetModel;
@property (nonatomic, weak, readonly) id <SpinnerDelegate> spinnerDelegate;
@property (nonatomic, readonly) NSNotificationCenter *notificationCenter;
@property (nonatomic, readonly) NSUserDefaults *userdefaults;
@property (nonatomic, readonly) ErrorBannerViewController *errorBannerViewController;
@property (nonatomic, readonly) ErrorDetailsDeserializer *errorDetailsDeserializer;
@property (nonatomic, readonly) ErrorDetailsStorage *errorDetailsStorage;
@property (nonatomic, readonly) ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper;
@property (nonatomic, readonly) BOOL isFromDeepLink;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithErrorBannerViewParentPresenterHelper:(ErrorBannerViewParentPresenterHelper *)errorBannerViewParentPresenterHelper
                                   errorBannerViewController:(ErrorBannerViewController *)errorBannerViewController
                                    errorDetailsDeserializer:(ErrorDetailsDeserializer *)errorDetailsDeserializer
                                          notificationCenter:(NSNotificationCenter *)notificationCenter
                                         errorDetailsStorage:(ErrorDetailsStorage *)errorDetailsStorage
                                             spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                                            timesheetService:(TimesheetService *)timesheetService
                                              timeSheetModel:(TimesheetModel *)timesheetModel
                                                userdefaults:(NSUserDefaults *)userdefaults;

- (void)refreshActionForUriNotFoundError;
- (void)launchCurrentTimeSheet;
@end
