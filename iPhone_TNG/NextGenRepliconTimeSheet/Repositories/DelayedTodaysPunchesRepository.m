#import "DelayedTodaysPunchesRepository.h"
#import "PunchRepository.h"
#import <KSDeferred/KSPromise.h>


@interface DelayedTodaysPunchesRepository ()

@property (nonatomic) KSPromise *serverDidFinishPunchPromise;
@property (nonatomic) PunchRepository *punchRepository;

@end


@implementation DelayedTodaysPunchesRepository

- (instancetype)initWithPunchRepository:(PunchRepository *)punchRepository {
    self = [super init];
    if (self) {
        self.punchRepository = punchRepository;
    }
    return self;
}


- (void)setupWithServerDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise
{
    self.serverDidFinishPunchPromise = serverDidFinishPunchPromise;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - <TodaysPunchesFetcher>

- (KSPromise *)punchesForDate:(NSDate *)date userURI:(NSString *)userURI
{
    return [self.serverDidFinishPunchPromise then:^id(NSArray *punches) {
        return [self.punchRepository punchesForDate:date userURI:userURI];
    } error:nil];
}

- (KSPromise *)punchesForDateAndMostRecentLastTwoPunch:(NSDate *)date
{
    return [self.serverDidFinishPunchPromise then:^id(NSArray *punches) {
        return [self.punchRepository punchesForDateAndMostRecentLastTwoPunch:date];
    } error:nil];
}

@end
