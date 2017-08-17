#import <UIKit/UIKit.h>
#import "LoginModel.h"
#import "ApprovalsService.h"
#import "SpinnerDelegate.h"
#import <repliconkit/ReachabilityMonitor.h>
#import "Theme.h"

@interface ApprovalsCountViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UIBarButtonItem	*leftButton;
    NSMutableArray *approvalsPermissionArray;
    
}
@property (nonatomic,strong) UIBarButtonItem *leftButton;
@property (nonatomic,strong) UITableView *approvalsTableView;
@property (nonatomic,strong) NSMutableArray *approvalsPermissionArray;
@property (nonatomic, readonly) LoginModel *loginModel;
@property (nonatomic, readonly) NSNotificationCenter *notificationCenter;
@property (nonatomic, readonly) ApprovalsService *approvalsService;
@property (nonatomic, readonly) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic, readonly) ApprovalsModel *approvalsModel;
@property (nonatomic, readonly) NSArray *userDetailsArray;
@property (nonatomic, readonly) ReachabilityMonitor *reachabilityMonitor;
@property (nonatomic, readonly) id<Theme> theme;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithNotificationCenter:(NSNotificationCenter *)notificationCenter
                           spinnerDelegate:(id<SpinnerDelegate>)spinnerDelegate
                          approvalsService:(ApprovalsService *)approvalsService
                            approvalsModel:(ApprovalsModel *)approvalsModel
                                loginModel:(LoginModel *)loginModel
                       reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor theme:(id<Theme>)theme;
@end
