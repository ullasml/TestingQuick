#import <UIKit/UIKit.h>
#import "OfflineBanner.h"

@protocol OfflineBannerPresenter<NSObject>
- (OfflineBanner *)offlineBanner;
@end
