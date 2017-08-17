#import "UIRefreshControl+Spec.h"

@implementation UIRefreshControl (Spec)

- (void)pullToRefresh {
    if (!self.isEnabled) {
        [[NSException exceptionWithName:@"Untappable" reason:@"Can't tap a disabled control" userInfo:nil] raise];
    }
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
