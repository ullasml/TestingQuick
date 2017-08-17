#import <Cedar/Cedar.h>
#import "TimeLineAndRecentPunchRepository.h"
#import <KSDeferred/KSDeferred.h>
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "PunchRepository.h"
#import "DelayedTodaysPunchesRepository.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TimeLineAndRecentPunchRepositorySpec)

describe(@"TimeLineAndRecentPunchRepository", ^{
    __block TimeLineAndRecentPunchRepository *subject;
    __block KSDeferred *serverDidFinishPunchDeferred;
    __block id <BSInjector,BSBinder> injector;
    __block PunchRepository *punchRepository;
    __block DelayedTodaysPunchesRepository *delayedTodaysPunchesFetcher;

    beforeEach(^{
        injector = [InjectorProvider injector];
        serverDidFinishPunchDeferred = nice_fake_for([KSDeferred class]);
        punchRepository = nice_fake_for([PunchRepository class]);
        [injector bind:[PunchRepository class] toInstance:punchRepository];

        delayedTodaysPunchesFetcher = nice_fake_for([DelayedTodaysPunchesRepository class]);
        [injector bind:[DelayedTodaysPunchesRepository class] toInstance:delayedTodaysPunchesFetcher];

        subject = [injector getInstance:[TimeLineAndRecentPunchRepository class]];
    });

    describe(@"punchesPromiseWithServerDidFinishPunchPromise:timeLinePunchFlow:userUri:date:", ^{
        context(@"when set up without a server did finish punch promise", ^{
            __block NSDate *date;
            __block NSString *userURI;

            context(@"for cardcontroller context", ^{
                beforeEach(^{
                    date = nice_fake_for([NSDate class]);
                    userURI = @"my-special-user-uri";

                    [subject punchesPromiseWithServerDidFinishPunchPromise:nil timeLinePunchFlow:CardTimeLinePunchFlowContext userUri:userURI date:date];
                });

                it(@"should ask the punch repository for the most recent punch", ^{
                    punchRepository should have_received(@selector(punchesForDateAndMostRecentLastTwoPunch:)).with(date);
                });
            });

            context(@"for daycontroller context", ^{
                beforeEach(^{
                    date = nice_fake_for([NSDate class]);
                    userURI = @"my-special-user-uri";

                    [subject punchesPromiseWithServerDidFinishPunchPromise:nil timeLinePunchFlow:DayControllerTimeLinePunchFlowContext userUri:userURI date:date];
                });

                it(@"should ask the punch repository for the most recent punch", ^{
                    punchRepository should have_received(@selector(punchesForDate:userURI:)).with(date,userURI);
                });
            });



        });

        context(@"when set up with a server did finish punch promise", ^{
            __block NSDate *date;
            __block NSString *userURI;
            __block KSDeferred *punchesWithServerDidFinishPunchDeferred;

            context(@"for cardcontroller context", ^{
                beforeEach(^{
                    date = nice_fake_for([NSDate class]);
                    userURI = @"my-special-user-uri";
                    punchesWithServerDidFinishPunchDeferred = [[KSDeferred alloc] init];
                    [subject punchesPromiseWithServerDidFinishPunchPromise:punchesWithServerDidFinishPunchDeferred.promise timeLinePunchFlow:CardTimeLinePunchFlowContext userUri:userURI date:date];
                });

                it(@"should ask the punch repository for the most recent punch", ^{
                    delayedTodaysPunchesFetcher should have_received(@selector(punchesForDateAndMostRecentLastTwoPunch:)).with(date);
                });
            });

            context(@"for daycontroller context", ^{
                beforeEach(^{
                    date = nice_fake_for([NSDate class]);
                    userURI = @"my-special-user-uri";
                    punchesWithServerDidFinishPunchDeferred = [[KSDeferred alloc] init];
                    [subject punchesPromiseWithServerDidFinishPunchPromise:punchesWithServerDidFinishPunchDeferred.promise timeLinePunchFlow:DayControllerTimeLinePunchFlowContext userUri:userURI date:date];
                });

                it(@"should ask the punch repository for the most recent punch", ^{
                    delayedTodaysPunchesFetcher should have_received(@selector(punchesForDate:userURI:)).with(date,userURI);
                });
            });
            
            
            
        });
    });
});

SPEC_END
