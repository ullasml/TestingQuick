#import "UIViewController+NavigationAndTabAwareness.h"

@implementation UIViewController (NavigationAndTabAwareness)

- (CGRect)contentViewFrame
{
    CGFloat statusBarHeight = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
    CGFloat navBarHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
    CGFloat tabBarHeight = CGRectGetHeight(self.tabBarController.tabBar.frame);
    CGFloat topPadding = statusBarHeight + navBarHeight;
    CGFloat bottomPadding = tabBarHeight;
    CGFloat topAndBottomPadding = (topPadding + bottomPadding);

    CGFloat height = CGRectGetHeight([[UIScreen mainScreen] bounds]) - topAndBottomPadding;

    return CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]), height);
}

@end
