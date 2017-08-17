#import <Cedar/Cedar.h>
#import "TimeoffService.h"
#import "SpinnerDelegate.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(TimeoffServiceSpec)

describe(@"TimeoffService", ^{
    __block TimeoffService *subject;
    __block NSDictionary *successfulResponse;
    __block NSDictionary *unSuccessfulResponse;

    beforeEach(^{
        id<SpinnerDelegate> spinnerDelegate = nice_fake_for(@protocol(SpinnerDelegate));
        subject = [[TimeoffService alloc] initWithSpinnerDelegate:spinnerDelegate];
    });

    describe(@"when the service is initialized", ^{
        it(@"should set the did fetch time off boolean to false", ^{
            subject.didSuccessfullyFetchTimeoff should be_falsy;
        });
    });

    describe(@"when fetching all of the booked time off", ^{
        beforeEach(^{
            successfulResponse = @{
                                   @"refDict": @{
                                           @"refID": @54
                                           }
                                   };
        });

        beforeEach(^{
            subject.didSuccessfullyFetchTimeoff = YES;
            [subject fetchTimeoffData:nil isPullToRefresh:NO];
        });

        it(@"should set the did fetch flag to false", ^{
            subject.didSuccessfullyFetchTimeoff should be_falsy;
        });

        describe(@"when the request succeeds", ^{
            beforeEach(^{
                [subject serverDidRespondWithResponse:successfulResponse];
            });

            it(@"should set the fetch flag to true", ^{
                subject.didSuccessfullyFetchTimeoff should be_truthy;
            });

            describe(@"when a subsequent request fails", ^{
                beforeEach(^{
                    [subject serverDidRespondWithResponse:unSuccessfulResponse];
                });

                it(@"should not change the fetch timesheets flag", ^{
                    subject.didSuccessfullyFetchTimeoff should be_truthy;
                });
            });
        });

        describe(@"when the request returns an error", ^{
            beforeEach(^{
                [subject serverDidRespondWithResponse:unSuccessfulResponse];
            });

            it(@"should not change fetch flag", ^{
                subject.didSuccessfullyFetchTimeoff should be_falsy;
            });
        });

        describe(@"when the request returns no json", ^{
            beforeEach(^{
                [subject serverDidRespondWithResponse:nil];
            });

            it(@"should not change the fetch flag", ^{
                subject.didSuccessfullyFetchTimeoff should be_falsy;
            });

        });
    });

    describe(@"when fetching a delta of time off", ^{
        beforeEach(^{
            successfulResponse = @{
                                   @"refDict": @{
                                           @"refID": @56
                                           }
                                   };
        });

        beforeEach(^{
            subject.didSuccessfullyFetchTimeoff = YES;
        });

        beforeEach(^{
            [subject fetchTimeoffData:nil isPullToRefresh:YES];
        });

        it(@"should set the fetch flag to false", ^{
            subject.didSuccessfullyFetchTimeoff should be_falsy;
        });

        describe(@"when the request succeeds", ^{
            beforeEach(^{
                [subject serverDidRespondWithResponse:successfulResponse];
            });

            it(@"should set the fetch flag to true", ^{
                subject.didSuccessfullyFetchTimeoff should be_truthy;
            });
        });

        describe(@"when the request fails", ^{
            beforeEach(^{
                [subject serverDidRespondWithResponse:unSuccessfulResponse];
            });

            it(@"should set the fetch flag to false", ^{
                subject.didSuccessfullyFetchTimeoff should be_falsy;
            });
        });
    });
});

SPEC_END
