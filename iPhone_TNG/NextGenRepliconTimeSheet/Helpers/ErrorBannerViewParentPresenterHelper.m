
#import "ErrorBannerViewParentPresenterHelper.h"
#import "ErrorBannerViewController.h"
#import "Constants.h"

@interface ErrorBannerViewParentPresenterHelper ()

@property(nonatomic) ErrorBannerViewController *errorBannerViewController;

@end


@implementation ErrorBannerViewParentPresenterHelper

- (instancetype)initWithErrorBannerViewController:(ErrorBannerViewController *)errorBannerViewController
{
    self = [super init];
    if (self)
    {
        self.errorBannerViewController = errorBannerViewController;
    }
    return self;
}

- (void)setTableViewInsetWithErrorBannerPresentation:(UITableView*)tableView
{
    tableView.contentInset = UIEdgeInsetsMake(0, 0, [self errorBannerHeight], 0);
}

- (void)setScrollViewInsetWithErrorBannerPresentation:(UIScrollView*)scrollView
{
    scrollView.contentInset = UIEdgeInsetsMake(0, 0, [self errorBannerHeight], 0);
}

#pragma - Private

-(NSInteger)errorBannerHeight
{
    return [self.errorBannerViewController.view isHidden] ? 0 : errorBannerHeight;
}

@end
