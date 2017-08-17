#import "SpinnerOperationsCounter.h"


@interface SpinnerOperationsCounter ()

@property (nonatomic, weak) id<SpinnerOperationsCounterDelegate> delegate;

@property (nonatomic) NSUInteger operationsCounter;

@end


@implementation SpinnerOperationsCounter

- (void)setupWithDelegate:(id<SpinnerOperationsCounterDelegate>)delegate
{
    self.delegate = delegate;
}

- (void)increment
{
    self.operationsCounter++;
    if(self.operationsCounter == 1)
    {
        [self.delegate spinnerOperationsCounterShouldShowSpinner:self];
    }
}

- (void)decrement
{
    if(self.operationsCounter > 0) {
        self.operationsCounter--;

        if(self.operationsCounter == 0)
        {
            [self.delegate spinnerOperationsCounterShouldHideSpinner:self];
        }
    }
}


@end
