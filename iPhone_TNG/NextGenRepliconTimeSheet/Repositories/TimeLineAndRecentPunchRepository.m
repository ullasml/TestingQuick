#import "TimeLineAndRecentPunchRepository.h"
#import <KSDeferred/KSDeferred.h>
#import "Enum.h"
#import "DelayedTodaysPunchesRepository.h"
#import <Blindside/BSInjector.h>
#import "PunchRepository.h"

@interface TimeLineAndRecentPunchRepository ()

@property (nonatomic, weak) id<BSInjector> injector;

@end


@implementation TimeLineAndRecentPunchRepository

-(KSPromise *)punchesPromiseWithServerDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise
                                          timeLinePunchFlow:(TimeLinePunchFlow)timeLinePunchFlow
                                                    userUri:(NSString *)userUri
                                                       date:(NSDate *)date
{

    if (serverDidFinishPunchPromise) {
        DelayedTodaysPunchesRepository *punchesFetcher = [self.injector getInstance:[DelayedTodaysPunchesRepository class]];
        [punchesFetcher setupWithServerDidFinishPunchPromise:serverDidFinishPunchPromise];
        return [self promiseForflowType:timeLinePunchFlow userUri:userUri date:date punchesFetcher:punchesFetcher];
    }
    else {
        PunchRepository *punchesFetcher = [self.injector getInstance:[PunchRepository class]];
        return [self promiseForflowType:timeLinePunchFlow userUri:userUri date:date punchesFetcher:punchesFetcher];
    }

}

#pragma <Private>
-(KSPromise *)promiseForflowType:(TimeLinePunchFlow)timeLinePunchFlow
                      userUri:(NSString *)userUri
                         date:(NSDate *)date
                  punchesFetcher:(id <PunchesForDateFetcher>)punchesFetcher{
    if (timeLinePunchFlow == CardTimeLinePunchFlowContext)
    {
        return [punchesFetcher punchesForDateAndMostRecentLastTwoPunch:date];
    }
    else
    {
        return [punchesFetcher punchesForDate:date userURI:userUri];
    }
}


@end
