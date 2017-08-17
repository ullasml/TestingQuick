#import <UIKit/UIKit.h>

#import "ApprovalsPendingCustomCell.h"
#import "ApprovalsScrollViewController.h"
#import "ApprovalCommentsController.h"
#import "ApprovalsPendingTimeOffTableViewHeader.h"

@class ApproveRejectHeaderStylist;
@class ErrorBannerViewParentPresenterHelper;


@interface ApprovalsPendingTimeOffViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, approvalSelectedUserDelegate, UITextViewDelegate, ApprovalCommentsControllerDelegate, ApprovalsPendingTimeOffTableViewHeaderDelegate> {

    UITableView *approvalpendingTSTableView;
    ApprovalsPendingCustomCell *cell;
    UILabel *sectionHeaderlabel;
    UIImageView *sectionHeader;
    NSIndexPath *selectedIndexPath;
    ApprovalsScrollViewController *scrollViewController;

    NSMutableArray *timeOffsArray;

    UIBarButtonItem *leftButton;
    NSMutableArray *selectedSheetsIDsArr;
    UILabel *msgLabel;
    UIView *footerView;
    UITextView *commentsTextView;
    NSIndexPath *selectedUserIndexpath;
    UIButton *footerBtn;//Implemented As Per US8194
}

@property (nonatomic, strong) UILabel                       *msgLabel;
@property (nonatomic, strong) NSMutableArray                *selectedSheetsIDsArr;
@property (nonatomic, strong) UIBarButtonItem               *leftButton;
@property (nonatomic, strong) NSMutableArray                *timeOffsArray;
@property (nonatomic, strong) UITableView                   *approvalpendingTSTableView;
@property (nonatomic, strong) UILabel                       *sectionHeaderlabel;
@property (nonatomic, strong) UIImageView                   *sectionHeader;
@property (nonatomic, strong) NSMutableArray                *listOfUsersArr;
@property (nonatomic, strong) NSIndexPath                   *selectedIndexPath;
@property (nonatomic, strong) UIView                        *footerView;
@property (nonatomic, strong) UITextView                    *commentsTextView;
@property (nonatomic, strong) ApprovalsScrollViewController *scrollViewController;
@property (nonatomic, strong) UIButton                      *checkOrClearAllBtn;
@property (nonatomic, strong) NSIndexPath                   *selectedUserIndexpath;
@property (nonatomic, strong) UIButton                      *footerBtn;
//Implemented As Per US8194
@property (nonatomic, readonly) NSNotificationCenter                 *notificationCenter;
@property (nonatomic, readonly) ApprovalsModel                       *approvalsModel;
@property (nonatomic, readonly) ApproveRejectHeaderStylist           *tableviewHeaderStylist;
@property (nonatomic, readonly) LoginModel                           *loginModel;
@property (nonatomic, readonly) ApprovalsService                     *approvalsService;
@property (nonatomic, weak, readonly) id<SpinnerDelegate>            spinnerDelegate;
@property (nonatomic, readonly) LoginService                         *loginService;
@property (nonatomic, readonly) ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper;
@property(nonatomic,assign)BOOL isFromDeepLink;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil
                         bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithErrorBannerViewParentPresenterHelper:(ErrorBannerViewParentPresenterHelper *)errorBannerViewParentPresenterHelper
                                      tableviewHeaderStylist:(ApproveRejectHeaderStylist *)tableviewHeaderStylist
                                          notificationCenter:(NSNotificationCenter *)notificationCenter
                                            approvalsService:(ApprovalsService *)approvalsService
                                             spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                                              approvalsModel:(ApprovalsModel *)approvalsModel
                                                loginService:(LoginService *)loginService
                                                  loginModel:(LoginModel *)loginModel;

- (void)handlePendingApprovalsDataReceivedAction;

//Implemented As Per US8194
- (void)addfooter:(id)sender;
- (void)refreshAction;
- (void)refreshActionForUriNotFoundError;
@end
