

#import "UIViewController+NavigationBar.h"

@implementation UIViewController (NavigationBar)

- (void)setupNavigationBarWithTitle:(NSString *)title backButtonTitle:(NSString *)backButtonTitle
{

    self.title = title;
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                initWithTitle:backButtonTitle
                                style:UIBarButtonItemStylePlain
                                target:self
                                action:nil];
    self.navigationController.navigationBar.topItem.backBarButtonItem = btnBack;
}

@end
