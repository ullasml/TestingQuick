#import "WorkHoursDeferred.h"


@implementation WorkHoursPromise

- (KSPromise *)then:(workHoursPromiseValueCallback)fulfilledCallback
              error:(promiseErrorCallback)errorCallback {
    return [super then:fulfilledCallback error:errorCallback];
}

@end


@implementation WorkHoursDeferred

- (void)resolveWithValue:(id<WorkHours>)workHours
{
    [super resolveWithValue:workHours];
}

- (WorkHoursPromise *)promise
{
    return (WorkHoursPromise *)[super promise];
}

@end
