#import <Cedar/Cedar.h>
#import "DelayedTodaysPunchesRepository.h"
#import <KSDeferred/KSDeferred.h>
#import "PunchRepository.h"
#import "TimeLinePunchesSummary.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(DelayedTodaysPunchesRepositorySpec)

describe(@"DelayedTodaysPunchesRepository", ^{
    __block DelayedTodaysPunchesRepository *subject;
    __block PunchRepository *punchRepository;
    __block KSDeferred *serverDidFinishPunchDeferred;
    __block KSDeferred *todaysPunchesDeferred;

    beforeEach(^{
        serverDidFinishPunchDeferred = [[KSDeferred alloc] init];
        todaysPunchesDeferred = [[KSDeferred alloc] init];

        punchRepository = fake_for([PunchRepository class]);
        punchRepository stub_method(@selector(punchesForDate:userURI:)).and_return(todaysPunchesDeferred.promise);
        punchRepository stub_method(@selector(punchesForDateAndMostRecentLastTwoPunch:)).and_return(todaysPunchesDeferred.promise);

        subject = [[DelayedTodaysPunchesRepository alloc] initWithPunchRepository:punchRepository];
        [subject setupWithServerDidFinishPunchPromise:serverDidFinishPunchDeferred.promise];
    });

    describe(NSStringFromProtocol(@protocol(PunchesForDateFetcher)), ^{

        describe(NSStringFromSelector(@selector(punchesForDate:userURI:)), ^{
            __block KSPromise *todaysPunchesPromise;
            __block NSDate *expectedDate;
            __block NSString *expectedUserURI;

            beforeEach(^{
                expectedDate = nice_fake_for([NSDate class]);
                expectedUserURI = @"some-great-user-uri";
                todaysPunchesPromise = [subject punchesForDate:expectedDate userURI:expectedUserURI];
            });

            context(@"when the server did finish punch promise has not resolved", ^{
                it(@"should not try to fetch the punches", ^{
                    punchRepository should_not have_received(@selector(punchesForDate:userURI:)).with(expectedDate, expectedUserURI);
                });
            });

            context(@"when the server did finish punch promise has resolved", ^{
                beforeEach(^{
                    [serverDidFinishPunchDeferred resolveWithValue:(id)[NSNull null]];
                });

                it(@"should try to fetch the punches from the punch repository", ^{
                    punchRepository should have_received(@selector(punchesForDate:userURI:)).with(expectedDate, expectedUserURI);
                });

                context(@"when the punch repository fetch succeeds", ^{
                    __block NSArray *todaysPunches;
                    beforeEach(^{
                        todaysPunches = nice_fake_for([NSArray class]);
                        [todaysPunchesDeferred resolveWithValue:todaysPunches];
                    });

                    it(@"should resolve the todaysPunchesPromise", ^{
                        todaysPunchesPromise.value should be_same_instance_as(todaysPunches);
                    });
                });

                context(@"when the punch repository fetch fails", ^{
                    __block NSError *error;
                    beforeEach(^{
                        error = nice_fake_for([NSError class]);
                        [todaysPunchesDeferred rejectWithError:error];
                    });

                    it(@"should resolve the todaysPunchesPromise", ^{
                        todaysPunchesPromise.error should be_same_instance_as(error);
                    });
                });
            });
        });
    });

    describe(NSStringFromProtocol(@protocol(PunchesForDateFetcher)), ^{
        describe(NSStringFromSelector(@selector(punchesForDateAndMostRecentLastTwoPunch:)), ^{
            __block KSPromise *todaysPunchesPromise;
            __block NSDate *expectedDate;

            beforeEach(^{
                expectedDate = nice_fake_for([NSDate class]);
                todaysPunchesPromise = [subject punchesForDateAndMostRecentLastTwoPunch:expectedDate];
            });

            context(@"when the server did finish punch promise has not resolved", ^{
                it(@"should not try to fetch the punches", ^{
                    punchRepository should_not have_received(@selector(punchesForDateAndMostRecentLastTwoPunch:)).with(expectedDate);
                });
            });

            context(@"when the server did finish punch promise has resolved", ^{
                beforeEach(^{
                    TimeLinePunchesSummary *timeLinePunchesSummary = nice_fake_for([TimeLinePunchesSummary class]);
                    timeLinePunchesSummary stub_method(@selector(timeLinePunches)).and_return(@[]);
                    timeLinePunchesSummary stub_method(@selector(allPunches)).and_return(@[]);
                    [serverDidFinishPunchDeferred resolveWithValue:timeLinePunchesSummary];
                });

                it(@"should try to fetch the punches from the punch repository", ^{
                    punchRepository should have_received(@selector(punchesForDateAndMostRecentLastTwoPunch:)).with(expectedDate);
                });

                context(@"when the punch repository fetch succeeds", ^{
                    __block NSArray *todaysPunches;
                    beforeEach(^{
                        todaysPunches = nice_fake_for([NSArray class]);
                        [todaysPunchesDeferred resolveWithValue:todaysPunches];
                    });

                    it(@"should resolve the todaysPunchesPromise", ^{
                        todaysPunchesPromise.value should be_same_instance_as(todaysPunches);
                    });
                });

                context(@"when the punch repository fetch fails", ^{
                    __block NSError *error;
                    beforeEach(^{
                        error = nice_fake_for([NSError class]);
                        [todaysPunchesDeferred rejectWithError:error];
                    });

                    it(@"should resolve the todaysPunchesPromise", ^{
                        todaysPunchesPromise.error should be_same_instance_as(error);
                    });
                });
            });
        });
    });

});

SPEC_END
