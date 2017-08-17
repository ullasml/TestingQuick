#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TeamStatusTableSection) {
    TeamStatusTableSectionClockedIn = 0,
    TeamStatusTableSectionOnBreak,
    TeamStatusTableSectionNotIn
};


@class KSPromise;
@class TeamStatusTablePresenter;
@class TeamTableStylist;
@class ErrorBannerViewParentPresenterHelper;

@interface TeamStatusSummaryController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readonly) KSPromise                             *teamStatusSummaryPromise;
@property (weak, nonatomic, readonly) UITableView                     *teamTableView;
@property (nonatomic, readonly) TeamStatusTablePresenter              *teamStatusTablePresenter;
@property (nonatomic, readonly) TeamTableStylist                      *teamTableStylist;
@property (nonatomic, readonly) TeamStatusTableSection                initiallyDisplayedSection;
@property (nonatomic, readonly) ErrorBannerViewParentPresenterHelper  *errorBannerViewParentPresenterHelper;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithErrorBannerViewParentPresenterHelper:(ErrorBannerViewParentPresenterHelper *)errorBannerViewParentPresenterHelper
                              teamStatusSummaryCellPresenter:(TeamStatusTablePresenter *)teamStatusSummaryCellPresenter
                                   initiallyDisplayedSection:(TeamStatusTableSection)initiallyDisplayedSection
                                    teamStatusSummaryPromise:(KSPromise *)teamStatusSummaryPromise
                                            teamTableStylist:(TeamTableStylist *)teamTableStylist;

@end
