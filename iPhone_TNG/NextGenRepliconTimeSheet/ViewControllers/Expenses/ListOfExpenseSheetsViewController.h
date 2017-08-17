#import <UIKit/UIKit.h>
#import "ListOfExpenseSheetsCustomCell.h"
#import "SpinnerDelegate.h"


@class ExpenseModel;
@class ExpenseService;
@class DefaultTableViewCellStylist;
@class SearchTextFieldStylist;

@interface ListOfExpenseSheetsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

{
    UITableView	*expenseSheetsTableView;
    NSMutableArray *expenseSheetsArray;
    UIBarButtonItem	*leftButton;
    ListOfExpenseSheetsCustomCell *cell;
    UIBarButtonItem *rightBarButton;
    UINavigationController *navcontroller;
    NSMutableArray *tempSheetsDBArray;
    UILabel *msgLabel;
    BOOL isCalledFromMenu;
    CGPoint currentContentOffset;
    BOOL isDeltaUpdate;
}

@property (nonatomic, assign) BOOL isCalledFromMenu;
@property (nonatomic) UILabel *msgLabel;
@property (nonatomic) UITableView *expenseSheetsTableView;
@property (nonatomic) NSMutableArray *expenseSheetsArray;
@property (nonatomic) UIBarButtonItem *leftButton;
@property (nonatomic) UIBarButtonItem *rightBarButton;
@property (nonatomic) UINavigationController *navcontroller;
@property (nonatomic) NSMutableArray *tempSheetsDBArray;
@property (nonatomic, assign) BOOL isDeltaUpdate;
@property (nonatomic, readonly) ExpenseService *expenseService;
@property (nonatomic, readonly) ExpenseModel *expenseModel;
@property (nonatomic, weak, readonly) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic, readonly) NSNotificationCenter *notificationCenter;
@property (nonatomic, readonly) NSUserDefaults *userDefaults;
@property (nonatomic, readonly) DefaultTableViewCellStylist *defaultTableViewCellStylist;
@property (nonatomic, readonly) SearchTextFieldStylist *searchTextFieldStylist;


-(void)gotoExpenseSheetEntry:(NSString*)expenseSheeturi;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary  UNAVAILABLE_ATTRIBUTE;

- (id)initWithDefaultTableViewCellStylist:(DefaultTableViewCellStylist *)defaultTableViewCellStylist
                   searchTextFieldStylist:(SearchTextFieldStylist *)searchTextFieldStylist
                       notificationCenter:(NSNotificationCenter *)notificationCenter
                          spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                           expenseService:(ExpenseService *)expenseService
                             expenseModel:(ExpenseModel *)expenseModel
                             userDefaults:(NSUserDefaults *)userDefaults NS_DESIGNATED_INITIALIZER;

-(void)showMessageLabel;
-(void)viewWillAppear:(BOOL)animated;
-(void)refreshAction;
-(void)refreshActionForUriNotFoundError;
-(void)addExpenseSheetAction:(id)sender;
@end
