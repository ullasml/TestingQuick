#import <Foundation/Foundation.h>


@class SpinnerOperationsCounter;


@protocol SpinnerOperationsCounterDelegate

- (void)spinnerOperationsCounterShouldShowSpinner:(SpinnerOperationsCounter *)spinnerOperationsCounter;
- (void)spinnerOperationsCounterShouldHideSpinner:(SpinnerOperationsCounter *)spinnerOperationsCounter;

@end


@interface SpinnerOperationsCounter : NSObject

- (void)setupWithDelegate:(id<SpinnerOperationsCounterDelegate>)delegate;

- (void)increment;
- (void)decrement;

@end
