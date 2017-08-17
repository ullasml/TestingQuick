
#import <Foundation/Foundation.h>
@class ErrorBannerViewController;

@interface ErrorBannerViewParentPresenterHelper : NSObject

@property (nonatomic, readonly) ErrorBannerViewController *errorBannerViewController;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithErrorBannerViewController:(ErrorBannerViewController *)errorBannerViewController NS_DESIGNATED_INITIALIZER;

- (void)setTableViewInsetWithErrorBannerPresentation:(UITableView*)tableView;
- (void)setScrollViewInsetWithErrorBannerPresentation:(UIScrollView*)scrollView;

@end
