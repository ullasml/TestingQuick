#import <Cedar/Cedar.h>
#import "DelayedTimeSummaryFetcher.h"
#import <KSDeferred/KSDeferred.h>
#import "TimeSummaryRepository.h"
#import "TimePeriodSummary.h"
#import "WorkHoursDeferred.h"
#import "TimesheetForDateRange.h"
#import "TimePeriodSummaryDeferred.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(DelayedTimeSummaryFetcherSpec)

describe(@"DelayedTimeSummaryFetcher", ^{
    __block DelayedTimeSummaryFetcher *subject;
    __block TimeSummaryRepository *timeSummaryRepository;
    __block KSDeferred *serverDidFinishPunchDeferred;

    beforeEach(^{
        serverDidFinishPunchDeferred = [[KSDeferred alloc] init];

        timeSummaryRepository = nice_fake_for([TimeSummaryRepository class]);

        subject = [[DelayedTimeSummaryFetcher alloc] initWithServerDidFinishPunchPromise:serverDidFinishPunchDeferred.promise
                                                                   timeSummaryRepository:timeSummaryRepository];
    });

    describe(NSStringFromProtocol(@protocol(TimeSummaryFetcher)), ^{
        describe(NSStringFromSelector(@selector(timeSummaryForToday)), ^{
            __block WorkHoursDeferred *workHoursDeferred;
            __block WorkHoursPromise *workHoursPromise;

            beforeEach(^{
                workHoursDeferred = [WorkHoursDeferred defer];

                timeSummaryRepository stub_method(@selector(timeSummaryForToday)).and_return([workHoursDeferred promise]);

                workHoursPromise = [subject timeSummaryForToday];
            });

            context(@"when the server did finish punch promise has not resolved", ^{
                it(@"should not try to fetch the time summary", ^{
                    timeSummaryRepository should_not have_received(@selector(timeSummaryForToday));
                });
            });

            context(@"when the server did finish punch promise has resolved", ^{
                beforeEach(^{
                    [serverDidFinishPunchDeferred resolveWithValue:(id)[NSNull null]];
                });

                it(@"should try to fetch the time summary", ^{
                    timeSummaryRepository should have_received(@selector(timeSummaryForToday));
                });

                context(@"when the time summary repository fetch succeeds", ^{
                    __block id<WorkHours> workHours;

                    beforeEach(^{
                        workHours = fake_for(@protocol(WorkHours));
                        [workHoursDeferred resolveWithValue:workHours];
                    });

                    it(@"should resolve the workHoursPromise", ^{
                        workHoursPromise.value should be_same_instance_as(workHours);
                    });
                });

                context(@"when the time summary repository fetch fails", ^{
                    __block NSError *error;

                    beforeEach(^{
                        error = fake_for([NSError class]);
                        [workHoursDeferred rejectWithError:error];
                    });

                    it(@"should resolve the workHoursPromise", ^{
                        workHoursPromise.error should be_same_instance_as(error);
                    });
                });
            });
        });

        describe(NSStringFromSelector(@selector(timeSummaryForTimesheet:)), ^{
            __block TimesheetForDateRange *timesheet;
            __block TimePeriodSummaryDeferred *timePeriodSummaryDeferred;
            __block TimePeriodSummaryPromise *timePeriodSummaryPromise;

            beforeEach(^{
                timePeriodSummaryDeferred = [TimePeriodSummaryDeferred defer];
                timeSummaryRepository stub_method(@selector(timeSummaryForTimesheet:)).
                    and_return([timePeriodSummaryDeferred promise]);

                timesheet = fake_for([TimesheetForDateRange class]);
                timePeriodSummaryPromise = [subject timeSummaryForTimesheet:timesheet];
            });

            context(@"when the server did finish punch promise has not resolved", ^{
                it(@"should not try to fetch the time summary", ^{
                    timeSummaryRepository should_not have_received(@selector(timeSummaryForTimesheet:));
                });
            });

            context(@"when the server did finish punch promise has resolved", ^{
                beforeEach(^{
                    [serverDidFinishPunchDeferred resolveWithValue:(id)[NSNull null]];
                });

                it(@"should try to fetch the time summary", ^{
                    timeSummaryRepository should have_received(@selector(timeSummaryForTimesheet:)).with(timesheet);
                });

                context(@"when the time summary repository fetch succeeds", ^{
                    __block TimePeriodSummary *timePeriodSummary;

                    beforeEach(^{
                        timePeriodSummary = fake_for([TimePeriodSummary class]);
                        [timePeriodSummaryDeferred resolveWithValue:timePeriodSummary];
                    });

                    it(@"should resolve the workHoursPromise", ^{
                        timePeriodSummaryPromise.value should be_same_instance_as(timePeriodSummary);
                    });
                });

                context(@"when the time summary repository fetch fails", ^{
                    __block NSError *error;

                    beforeEach(^{
                        error = fake_for([NSError class]);
                        [timePeriodSummaryDeferred rejectWithError:error];
                    });

                    it(@"should resolve the workHoursPromise", ^{
                        timePeriodSummaryPromise.error should be_same_instance_as(error);
                    });
                });
            });
        });
    });
});

SPEC_END
