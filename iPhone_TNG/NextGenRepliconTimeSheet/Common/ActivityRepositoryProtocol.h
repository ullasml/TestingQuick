

#import <Foundation/Foundation.h>

@class KSPromise;
@protocol ActivityRepositoryProtocol

- (KSPromise *)fetchAllActivities;

- (KSPromise *)fetchFreshActivities;

- (KSPromise *)fetchMoreActivitiesMatchingText:(NSString *)text;

- (KSPromise *)fetchActivitiesMatchingText:(NSString *)text;

- (KSPromise *)fetchCachedActivitiesMatchingText:(NSString *)text;

@end

