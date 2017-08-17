#import <UIKit/UIKit.h>
#import "ApprovalsScrollViewController.h"
#import "ApprovalsPendingCustomCell.h"

@class ErrorBannerViewParentPresenterHelper;

@interface ApprovalsTimeOffHistoryViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,approvalSelectedUserDelegate>
{
    UITableView *approvalHistoryTableView;
    ApprovalsPendingCustomCell *cell;
    NSMutableArray *historyArr;
    UILabel *msgLabel;
    NSIndexPath *selectedIndexPath;
    ApprovalsScrollViewController *scrollViewController;
    
}
@property (nonatomic,strong) UITableView                *approvalHistoryTableView;
@property (nonatomic,strong) ApprovalsPendingCustomCell *cell;
@property (nonatomic,strong) NSMutableArray             *historyArr;
@property (nonatomic,strong) UILabel                    *msgLabel;
@property (nonatomic,strong) NSIndexPath                *selectedIndexPath;

@property (nonatomic,strong)    ApprovalsScrollViewController        *scrollViewController;
@property (nonatomic, readonly) LoginModel                           *loginModel;
@property (nonatomic, readonly) NSNotificationCenter                 *notificationCenter;
@property (nonatomic, readonly) ApprovalsService                     *approvalsService;
@property (nonatomic, readonly) id<SpinnerDelegate>                  spinnerDelegate;
@property (nonatomic, readonly) ApprovalsModel                       *approvalsModel;
@property (nonatomic, readonly) ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithErrorBannerViewParentPresenterHelper:(ErrorBannerViewParentPresenterHelper *)errorBannerViewParentPresenterHelper
                                          notificationCenter:(NSNotificationCenter *)notificationCenter
                                             spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                                            approvalsService:(ApprovalsService *)approvalsService
                                              approvalsModel:(ApprovalsModel *)approvalsModel
                                                  loginModel:(LoginModel *)loginModel;

-(void)showMessageLabel;
-(void)refreshAction;
-(void)refreshActionForUriNotFoundError;
@end