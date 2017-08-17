#import <Cedar/Cedar.h>
#import "ExpenseService.h"
#import "SpinnerDelegate.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ExpenseServiceSpec)

describe(@"ExpenseServiceSpec", ^{
    __block ExpenseService *subject;
    __block NSDictionary *successfulResponse;
    __block NSDictionary *unSuccessfulResponse;

    beforeEach(^{
        id<SpinnerDelegate> fakeSpinnerDelegate = nice_fake_for(@protocol(SpinnerDelegate));
        subject = [[ExpenseService alloc] initWithSpinnerDelegate:fakeSpinnerDelegate];
    });

    beforeEach(^{
        unSuccessfulResponse = @{
                                 @"response": @{
                                         @"error": @{}
                                         }
                                 };

    });

    describe(@"when the service is initialized", ^{
        it(@"should set the fetch flag to false", ^{
            subject.didSuccessfullyFetchExpenses should be_falsy;
        });
    });

    describe(@"when fetching all of the expenses", ^{
        beforeEach(^{
            successfulResponse = @{
                                   @"refDict": @{
                                           @"refID": @27
                                           }
                                   };
        });

        beforeEach(^{
            subject.didSuccessfullyFetchExpenses = YES;
            [subject fetchExpenseSheetData:nil];
        });

        it(@"should set the fetch flag to false", ^{
            subject.didSuccessfullyFetchExpenses should be_falsy;
        });

        describe(@"when the request succeeds", ^{
            beforeEach(^{
                [subject serverDidRespondWithResponse:successfulResponse];
            });

            it(@"should set the fetch flag to true", ^{
                subject.didSuccessfullyFetchExpenses should be_truthy;
            });

            describe(@"when a subsequent request fails", ^{
                beforeEach(^{
                    [subject serverDidRespondWithResponse:unSuccessfulResponse];
                });

                it(@"should not change the fetch flag", ^{
                    subject.didSuccessfullyFetchExpenses should be_truthy;
                });
            });
        });

        describe(@"when the request returns an error", ^{
            beforeEach(^{
                [subject serverDidRespondWithResponse:unSuccessfulResponse];
            });

            it(@"should not change the fetch flag", ^{
                subject.didSuccessfullyFetchExpenses should be_falsy;
            });
        });

        describe(@"when the request returns no json", ^{
            beforeEach(^{
                [subject serverDidRespondWithResponse:nil];
            });

            it(@"should not change the fetch flag", ^{
                subject.didSuccessfullyFetchExpenses should be_falsy;
            });

        });
    });

    describe(@"when fetching a delta of expenses", ^{
        beforeEach(^{
            successfulResponse = @{
                                   @"refDict": @{
                                           @"refID": @88
                                           }
                                   };
        });

        beforeEach(^{
            subject.didSuccessfullyFetchExpenses = YES;
        });

        beforeEach(^{
            [subject fetchExpenseSheetUpdateData:nil];
        });

        it(@"should set the fetch flag to false", ^{
            subject.didSuccessfullyFetchExpenses should be_falsy;
        });

        describe(@"when the request succeeds", ^{
            beforeEach(^{
                [subject serverDidRespondWithResponse:successfulResponse];
            });
            
            it(@"should set the fetch flag to true", ^{
                subject.didSuccessfullyFetchExpenses should be_truthy;
            });
        });

        describe(@"when the request fails", ^{
            beforeEach(^{
                [subject serverDidRespondWithResponse:unSuccessfulResponse];
            });

            it(@"should set the fetch flag to false", ^{
                subject.didSuccessfullyFetchExpenses should be_falsy;
            });
        });
    });
});

SPEC_END
