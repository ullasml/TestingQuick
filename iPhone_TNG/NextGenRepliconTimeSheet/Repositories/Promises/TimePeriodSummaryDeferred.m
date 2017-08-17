#import "TimePeriodSummaryDeferred.h"
#import "TimePeriodSummary.h"


@implementation TimePeriodSummaryPromise

- (KSPromise *)then:(timePeriodSummaryPromiseValueCallback)fulfilledCallback
              error:(promiseErrorCallback)errorCallback {
    return [super then:fulfilledCallback error:errorCallback];
}

@end


@implementation TimePeriodSummaryDeferred

- (void)resolveWithValue:(TimePeriodSummary *)timePeriodSummary
{
    [super resolveWithValue:timePeriodSummary];
}

- (TimePeriodSummaryPromise *)promise
{
    return (TimePeriodSummaryPromise *)[super promise];
}

@end
