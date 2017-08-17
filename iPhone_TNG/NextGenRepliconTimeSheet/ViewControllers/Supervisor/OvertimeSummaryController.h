#import <UIKit/UIKit.h>

@class KSPromise;
@class OvertimeSummaryTablePresenter;
@class TeamTableStylist;


@interface OvertimeSummaryController : UIViewController <UITableViewDataSource, UITableViewDelegate>

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithOvertimeSummaryPromise:(KSPromise *)overtimeSummaryPromise
                 overtimeSummaryTablePresenter:(OvertimeSummaryTablePresenter *)overtimeSummaryTablePresenter
                              teamTableStylist:(TeamTableStylist *)teamTableStylist;


@property (weak, nonatomic, readonly) UITableView *overtimeTableView;
@property (nonatomic, readonly) KSPromise *supervisorDashboardSummaryPromise;
@property (nonatomic, readonly) OvertimeSummaryTablePresenter *overtimeSummaryTablePresenter;

@end
