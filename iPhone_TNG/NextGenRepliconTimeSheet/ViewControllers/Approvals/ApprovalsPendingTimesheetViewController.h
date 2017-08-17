#import <UIKit/UIKit.h>
#import "ApprovalsPendingCustomCell.h"
#import "ApprovalsScrollViewController.h"
#import "ApprovalsPendingTimeOffTableViewHeader.h"
#import "ApprovalCommentsController.h"
#import "ApproveTimesheetContainerController.h"


@class UserPermissionsStorage;
@class MinimalTimesheetDeserializer;
@protocol UserSession;
@class ReachabilityMonitor;
@class ErrorBannerViewParentPresenterHelper;


@interface ApprovalsPendingTimesheetViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, approvalSelectedUserDelegate, UITextViewDelegate,ApprovalsPendingTimeOffTableViewHeaderDelegate,ApprovalCommentsControllerDelegate, ApproveTimesheetContainerControllerDelegate>
{
    ApprovalsPendingCustomCell *cell;
    UILabel *sectionHeaderlabel;
    UIImageView *sectionHeader;
    NSIndexPath *selectedIndexPath;
    ApprovalsScrollViewController *scrollViewController;
    UIBarButtonItem *leftButton;
    NSMutableArray *selectedSheetsIDsArr;
    UILabel *msgLabel;
    UITextView *commentsTextView;
    id __weak delegate;
}


@property (nonatomic, strong) ApprovalsScrollViewController     *scrollViewController;
@property (nonatomic, strong) UITableView                       *approvalpendingTSTableView;
@property (nonatomic, strong) NSMutableArray                    *selectedSheetsIDsArr;
@property (nonatomic, strong) NSIndexPath                       *selectedUserIndexpath;
@property (nonatomic, strong) NSIndexPath                       *selectedIndexPath;
@property (nonatomic, strong) NSMutableArray                    *listOfUsersArr;
@property (nonatomic, strong) UITextView                        *commentsTextView;
@property (nonatomic, strong) UIBarButtonItem                   *leftButton;
@property (nonatomic, strong) UILabel                           *sectionHeaderlabel;
@property (nonatomic, strong) UIImageView                       *sectionHeader;
@property (nonatomic, assign) NSUInteger                        totalRowsCount;
@property (nonatomic, strong) UILabel                           *msgLabel;
@property (nonatomic, weak)   id                                delegate;

@property (nonatomic, readonly) MinimalTimesheetDeserializer         *minimalTimesheetDeserializer;
@property (nonatomic, readonly) UserPermissionsStorage               *userPermissionsStorage;
@property (nonatomic, weak, readonly) id<SpinnerDelegate>            spinnerDelegate;
@property (nonatomic, readonly) NSNotificationCenter                 *notificationCenter;
@property (nonatomic, readonly) ApprovalsService                     *approvalsService;
@property (nonatomic, readonly) ReachabilityMonitor                  *reachabilityMonitor;
@property (nonatomic, readonly) ApprovalsModel                       *approvalsModel;
@property (nonatomic, readonly) id<UserSession>                      userSession;
@property (nonatomic, readonly) LoginModel                           *loginModel;
@property (nonatomic, readonly) LoginService                         *loginService;
@property (nonatomic, readonly) ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper;
@property(nonatomic,assign)BOOL isFromDeepLink;


+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary NS_UNAVAILABLE;

- (instancetype)initWithErrorBannerViewParentPresenterHelper:(ErrorBannerViewParentPresenterHelper *)errorBannerViewParentPresenterHelper
                                minimalTimesheetDeserializer:(MinimalTimesheetDeserializer *)minimalTimesheetDeserializer
                                      userPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                                         reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                                          notificationCenter:(NSNotificationCenter *)notificationCenter
                                            approvalsService:(ApprovalsService *)approvalsService
                                             spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                                              approvalsModel:(ApprovalsModel *)approvalsModel
                                                 userSession:(id <UserSession>)userSession
                                                  loginModel:(LoginModel *)loginModel
                                                loginService:(LoginService *)loginService;
- (void)refreshAction;
- (void)refreshActionForUriNotFoundError;
- (void)handlePendingApprovalsDataReceivedAction;
- (UITableView *)setupTableView;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@end
