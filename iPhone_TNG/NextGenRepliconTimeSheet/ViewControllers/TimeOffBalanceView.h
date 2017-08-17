#import <UIKit/UIKit.h>
@class TimeOffBalanceView;
@class ErrorBannerViewParentPresenterHelper;

@protocol TimeOffBalancesViewDelegate <NSObject>
@optional
- (void)listOfTimeOffBalanceView:(TimeOffBalanceView *)listOfTimeOffBalanceView refreshAction:(id)sender;

@end

@interface TimeOffBalanceView : UIView

@property (nonatomic,assign) id<TimeOffBalancesViewDelegate> timeOffBalanceViewDelegate;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame errorBannerViewParentPresenterHelper:(ErrorBannerViewParentPresenterHelper*)errorBannerViewParentPresenterHelper NS_DESIGNATED_INITIALIZER;


- (void)setUpTimeOffBalceArray:(NSMutableArray *)availableArr :(NSMutableArray *)usedArr :(NSMutableArray *)trackedArr :(NSMutableArray *)sectionsArr;
- (void)refreshTableViewAfterPulltoRefresh;
- (void)refreshTableViewWithContentOffsetReset:(BOOL)isContentOffsetReset;
- (void)stopAnimatingIndicator;
@end
