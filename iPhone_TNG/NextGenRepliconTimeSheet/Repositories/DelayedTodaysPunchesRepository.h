#import "PunchesForDateFetcher.h"


@class PunchRepository;
@class KSPromise;


@interface DelayedTodaysPunchesRepository : NSObject <PunchesForDateFetcher>

@property (nonatomic, readonly) KSPromise *serverDidFinishPunchPromise;
@property (nonatomic, readonly) PunchRepository *punchRepository;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithPunchRepository:(PunchRepository *)punchRepository;

- (void)setupWithServerDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise;

@end
