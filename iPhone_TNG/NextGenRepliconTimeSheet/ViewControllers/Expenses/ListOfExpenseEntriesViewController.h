#import <UIKit/UIKit.h>
#import "ListOfExpenseEntriesCustomCell.h"
#import "ApprovalTablesHeaderView.h"
#import "ApprovalTablesFooterView.h"

@class DefaultTableViewCellStylist;
@protocol SpinnerDelegate;
@class SearchTextFieldStylist;

@interface ListOfExpenseEntriesViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,approvalTablesHeaderViewDelegate,approvalTablesFooterViewDelegate>

{
    UITableView	*expenseEntriesTableView;
    NSMutableArray *expenseEntriesArray;
    NSString *expenseSheetTitle;
    NSString *expenseSheetStatus;
    NSString *expenseSheetURI;
    NSString *totalIncurredAmountString;
    NSString *reimburseAmountString;
    ListOfExpenseEntriesCustomCell *cell;
    UIView      *footerView;
    UIButton *deleteButton;
    NSString *actionType;
    UILabel *messageLabel;
    BOOL isFirstTimeLoad;
    BOOL isCalledFromTabBar;
    id __weak parentDelegate;
    NSString *userName;
    NSString *sheetPeriod;
    NSString *approverComments;
    NSString *approvalsModuleName;
    //Implementation as per US9172//JUHI
    UIButton* radioButton;
    UILabel *disclaimerTitleLabel;
    BOOL disclaimerSelected;
    float heightofDisclaimerText;

}
@property (nonatomic,assign)BOOL isFirstTimeLoad,isCalledFromTabBar;
@property (nonatomic,strong)NSString *actionType;
@property (nonatomic,strong)UITableView *expenseEntriesTableView;
@property (nonatomic,strong)NSMutableArray *expenseEntriesArray;
@property (nonatomic,strong)NSString *expenseSheetTitle;
@property (nonatomic,strong)NSString *expenseSheetStatus;
@property (nonatomic,strong)NSString *expenseSheetURI;
@property (nonatomic,strong)UIView *footerView;
@property (nonatomic,strong)NSString *totalIncurredAmountString;
@property (nonatomic,strong)NSString *reimburseAmountString;
@property (nonatomic,strong)UILabel *messageLabel;
@property (nonatomic,strong)UIButton *deleteButton;
@property (nonatomic,weak)id parentDelegate;
@property (nonatomic,strong)NSString *userName;
@property (nonatomic,strong)NSString *sheetPeriod;
@property (nonatomic,strong)NSString *approverComments;
@property (nonatomic,assign)NSInteger currentViewTag;
@property (nonatomic,assign)NSInteger currentNumberOfView;
@property (nonatomic,assign)NSUInteger totalNumberOfView;
@property (nonatomic,strong)NSString *approvalsModuleName;
//Implementation as per US9172//JUHI
@property(nonatomic,assign)BOOL disclaimerSelected;
@property(nonatomic,strong)UILabel *disclaimerTitleLabel;
@property(nonatomic,strong)UIButton* radioButton;
//Implementation For EXP-151//JUHI
@property(nonatomic,strong)NSString *reimbursementCurrencyName;
@property(nonatomic,strong)NSString *reimbursementCurrencyURI;
@property (nonatomic, weak, readonly) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic, readonly) DefaultTableViewCellStylist *defaultTableViewCellStylist;
@property (nonatomic, readonly) SearchTextFieldStylist *searchTextFieldStylist;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary  UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithDefaultTableViewCellStylist:(DefaultTableViewCellStylist *)defaultTableViewCellStylist
                             searchTextFieldStylist:(SearchTextFieldStylist *)searchTextFieldStylist
                                    spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate;

-(void)popToListOfExpenseSheets;
-(BOOL)canResubmitExpenseSheetForURI:(NSString *)sheetUri;
-(void)addDeleteButtonWithMessage;
-(void)addDeleteButtonToViewwithPosition:(float)position andParentView:(UIView*)viewToAdd;
-(void)displayAllExpenseEntries:(BOOL)showEmptyPlaceHolder;
-(void)createFooter;
-(void)createTableHeader;
-(void)resetViewForApprovalsCommentsAction:(BOOL)isReset andComments:(NSString *)approverCommentsStr forParentView:(ApprovalTablesFooterView *)approvalTablesFooterView;
-(void)showMessageLabel;
-(void)RecievedData;
@end
