#import <Foundation/Foundation.h>
#import <KSDeferred/KSDeferred.h>
#import "WorkHours.h"


typedef id(^workHoursPromiseValueCallback)(id<WorkHours> workHours);


@interface WorkHoursPromise : KSPromise

- (KSPromise *)then:(workHoursPromiseValueCallback)fulfilledCallback error:(promiseErrorCallback)errorCallback;

@end


@interface WorkHoursDeferred : KSDeferred

- (void)resolveWithValue:(id<WorkHours>)workHours;

- (WorkHoursPromise *)promise;

@end

