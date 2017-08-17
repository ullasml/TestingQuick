#import <UIKit/UIKit.h>

#import "ApprovalsPendingCustomCell.h"
#import "ApprovalsScrollViewController.h"
#import "ApprovalCommentsController.h"
#import "ApprovalsPendingTimeOffTableViewHeader.h"

@class LoginModel;
@protocol Theme;

@interface ApprovalsPendingExpenseViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, approvalSelectedUserDelegate, UITextViewDelegate, ApprovalsPendingTimeOffTableViewHeaderDelegate, ApprovalCommentsControllerDelegate>
{

    UITableView *approvalpendingTSTableView;
    ApprovalsPendingCustomCell *cell;
    UILabel *sectionHeaderlabel;
    UIImageView *sectionHeader;
    NSIndexPath *selectedIndexPath;
    ApprovalsScrollViewController *scrollViewController;

    NSMutableArray *expenseSheetsArray;

    UIBarButtonItem *leftButton;
    NSMutableArray *selectedSheetsIDsArr;
    UILabel *msgLabel;

    UITextView *commentsTextView;
    NSIndexPath *selectedUserIndexpath;
}


@property (nonatomic, assign) NSUInteger totalRowsCount;
@property (nonatomic, strong) UILabel *msgLabel;
@property (nonatomic, strong) NSMutableArray *selectedSheetsIDsArr;
@property (nonatomic, strong) UIBarButtonItem *leftButton;
@property (nonatomic, strong) NSMutableArray *expenseSheetsArray;
@property (nonatomic, strong) UITableView *approvalpendingTSTableView;
@property (nonatomic, strong) UILabel *sectionHeaderlabel;
@property (nonatomic, strong) UIImageView *sectionHeader;
@property (nonatomic, strong) NSMutableArray *listOfUsersArr;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UITextView *commentsTextView;
@property (nonatomic, strong) ApprovalsScrollViewController *scrollViewController;
@property (nonatomic, strong) NSIndexPath *selectedUserIndexpath;
@property (nonatomic, readonly) NSNotificationCenter *notificationCenter;
@property (nonatomic, readonly) LoginModel *loginModel;
@property (nonatomic, readonly) ApprovalsService *approvalsService;
@property (nonatomic, readonly) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic, readonly) ApprovalsModel *approvalsModel;
@property (nonatomic, readonly) LoginService *loginService;
@property(nonatomic,assign)BOOL isFromDeepLink;

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
                              loginService:(LoginService *)loginService;

- (void)refreshAction;
- (void)refreshActionForUriNotFoundError;
- (void)handlePendingApprovalsDataReceivedAction;

@end
