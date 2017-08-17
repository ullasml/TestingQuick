#import "TimeSummaryFetcher.h"
#import "TimeSummaryRepository.h"


@protocol KSPromise;


@interface DelayedTimeSummaryFetcher : NSObject <TimeSummaryFetcher>

@property (nonatomic, readonly) KSPromise *serverDidFinishPunchPromise;
@property (nonatomic, readonly) TimeSummaryRepository *timeSummaryRepository;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithServerDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise
                              timeSummaryRepository:(TimeSummaryRepository *)timeSummaryRepository;


@end
