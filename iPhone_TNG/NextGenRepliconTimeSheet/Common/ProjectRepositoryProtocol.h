

#import <Foundation/Foundation.h>


@class KSPromise;

@protocol ProjectRepositoryProtocol

-(KSPromise *)fetchCachedProjectsMatchingText:(NSString *)text clientUri:(NSString *)clientUri;

-(KSPromise *)fetchProjectsMatchingText:(NSString *)text clientUri:(NSString *)clientUri;

-(KSPromise *)fetchMoreProjectsMatchingText:(NSString *)text clientUri:(NSString *)clientUri;

-(KSPromise *)fetchAllProjectsForClientUri:(NSString *)clientUri;

-(KSPromise *)fetchFreshProjectsForClientUri:(NSString *)clientUri;

@end

