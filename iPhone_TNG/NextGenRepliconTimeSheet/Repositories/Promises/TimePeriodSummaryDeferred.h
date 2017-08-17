#import <Foundation/Foundation.h>
#import "WorkHoursDeferred.h"


@class TimePeriodSummary;

typedef id(^timePeriodSummaryPromiseValueCallback)(TimePeriodSummary *timePeriodSummary);

@interface TimePeriodSummaryPromise : WorkHoursPromise

- (KSPromise *)then:(timePeriodSummaryPromiseValueCallback)fulfilledCallback error:(promiseErrorCallback)errorCallback;

@end


@interface TimePeriodSummaryDeferred : WorkHoursDeferred

- (void)resolveWithValue:(TimePeriodSummary *)timePeriodSummary;

- (TimePeriodSummaryPromise *)promise;

@end

