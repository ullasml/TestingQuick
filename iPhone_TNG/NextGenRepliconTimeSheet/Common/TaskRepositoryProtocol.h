

#import <Foundation/Foundation.h>

@class KSPromise;
@protocol TaskRepositoryProtocol

-(KSPromise *)fetchCachedTasksMatchingText:(NSString *)text projectUri:(NSString *)projectUri;

-(KSPromise *)fetchTasksMatchingText:(NSString *)text projectUri:(NSString *)projectUri;

-(KSPromise *)fetchMoreTasksMatchingText:(NSString *)text projectUri:(NSString *)projectUri;

-(KSPromise *)fetchAllTasksForProjectUri:(NSString *)projectUri;

-(KSPromise *)fetchFreshTasksForProjectUri:(NSString *)projectUri;

@end

