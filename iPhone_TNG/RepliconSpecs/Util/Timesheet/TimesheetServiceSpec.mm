#import <Cedar/Cedar.h>
#import "TimesheetService.h"
#import "SpinnerDelegate.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(TimesheetServiceSpec)

describe(@"TimesheetService", ^{
    __block TimesheetService *subject;
    __block NSDictionary *unsuccessfulResponse;
    __block id<SpinnerDelegate> fakeSpinnerDelegate;

    beforeEach(^{
        unsuccessfulResponse = @{
                                 @"response": @{
                                         @"error": @{}
                                         }
                                 };

        fakeSpinnerDelegate = nice_fake_for(@protocol(SpinnerDelegate));
        subject = [[TimesheetService alloc] initWithSpinnerDelegate:fakeSpinnerDelegate];
    });

    describe(@"when first initialized", ^{
        describe(@"the fetch flag", ^{
            it(@"should return false", ^{
                subject.didSuccessfullyFetchTimesheets should be_falsy;
            });
        });
    });

    describe(@"when fetching all of the timesheets", ^{
        __block NSDictionary *successfulAllResponse;

        beforeEach(^{
            successfulAllResponse = @{
                                      @"refDict": @{
                                              @"refID": @93
                                              }
                                      };
        });

        beforeEach(^{
            subject.didSuccessfullyFetchTimesheets = YES;
            [subject fetchTimeSheetData:nil];
        });

        it(@"should set the fetch flag to false", ^{
            subject.didSuccessfullyFetchTimesheets should be_falsy;
        });


        describe(@"when the request succeeds", ^{
            beforeEach(^{
                [subject serverDidRespondWithResponse:successfulAllResponse];
            });

            it(@"should set the fetch flag to true", ^{
                subject.didSuccessfullyFetchTimesheets should be_truthy;
            });

            describe(@"when a subsequent request fails", ^{
                beforeEach(^{
                    [subject serverDidRespondWithResponse:unsuccessfulResponse];
                });

                it(@"should not change the fetch flag", ^{
                    subject.didSuccessfullyFetchTimesheets should be_truthy;
                });
            });
        });

        describe(@"when the request returns an error", ^{
            beforeEach(^{
                [subject serverDidRespondWithResponse:unsuccessfulResponse];
            });

            it(@"should not change the fetch flag", ^{
                subject.didSuccessfullyFetchTimesheets should be_falsy;
            });
        });

        describe(@"when the request returns no json", ^{
            beforeEach(^{
                [subject serverDidRespondWithResponse:nil];
            });

            it(@"should not change the fetch flag", ^{
                subject.didSuccessfullyFetchTimesheets should be_falsy;
            });
        });
    });

    describe(@"when fetching a delta of the timesheets", ^{
        __block NSDictionary *successfulDeltaResponse;

        beforeEach(^{
            successfulDeltaResponse = @{
                                      @"refDict": @{
                                              @"refID": @87
                                              }
                                      };

        });

        

        describe(@"when the request succeeds", ^{
            beforeEach(^{
                [subject serverDidRespondWithResponse:successfulDeltaResponse];
            });

            it(@"should set the fetch flag to true", ^{
                subject.didSuccessfullyFetchTimesheets should be_truthy;
            });

            describe(@"when a subsequent request fails", ^{
                beforeEach(^{
                    [subject serverDidRespondWithResponse:unsuccessfulResponse];
                });

                it(@"should not change the fetch flag", ^{
                    subject.didSuccessfullyFetchTimesheets should be_truthy;
                });
            });
        });

        describe(@"when the request fails", ^{
            beforeEach(^{
                [subject serverDidRespondWithResponse:unsuccessfulResponse];
            });

            it(@"should not change the fetch flag", ^{
                subject.didSuccessfullyFetchTimesheets should be_falsy;
            });
        });
    });
});

SPEC_END
