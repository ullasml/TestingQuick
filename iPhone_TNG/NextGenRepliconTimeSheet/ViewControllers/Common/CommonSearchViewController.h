#import <UIKit/UIKit.h>

@class DefaultTableViewCellStylist;
@class SearchTextFieldStylist;
@protocol SpinnerDelegate;
@class RepliconServiceProvider;
@class ReachabilityMonitor;

@interface CommonSearchViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{


}
@property (nonatomic) id delegate;
@property (nonatomic) UITableView *listTableView;
@property (nonatomic) NSMutableDictionary *dataDict;
@property (nonatomic) NSMutableArray *listDataArray;
@property (nonatomic) UITextField *searchTextField;
@property (nonatomic) NSTimer *searchTimer;
@property (nonatomic) BOOL isTextFieldFirstResponder;
@property (nonatomic) NSInteger screenMode;
@property (nonatomic) NSIndexPath *selectedIndexpath;
@property (nonatomic) NSString *selectedName;
@property (nonatomic) NSString *sheetStatus;
@property (nonatomic, readonly) ReachabilityMonitor *reachabilityMonitor;
@property (nonatomic, assign, readonly) BOOL shouldMoveScrollPositionToBottom;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary  UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithDefaultTableViewCellStylist:(DefaultTableViewCellStylist *)defaultTableViewCellStylist
                            repliconServiceProvider:(RepliconServiceProvider *)repliconServiceProvider
                             searchTextFieldStylist:(SearchTextFieldStylist *)searchTextFieldStylist
                                reachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                                    spinnerDelegate:(id<SpinnerDelegate>)spinnerDelegate;

- (void)moreAction;
- (void)createListData;
- (void)refreshViewAfterMoreAction:(NSNotification *)notificationObject;
- (BOOL)isMoreDataAvailable;
@end

