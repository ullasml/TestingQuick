#import <Foundation/Foundation.h>

@protocol SpinnerDelegate <NSObject>

- (void) showTransparentLoadingOverlay;
- (void) hideTransparentLoadingOverlay;

@end