#import <Cedar/Cedar.h>
#import "SpinnerOperationsCounter.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(SpinnerOperationsCounterSpec)

describe(@"SpinnerOperationsCounter", ^{
    __block SpinnerOperationsCounter *subject;
    beforeEach(^{
        subject = [[SpinnerOperationsCounter alloc] init];
    });

    __block id<SpinnerOperationsCounterDelegate> delegate;
    beforeEach(^{
        delegate = nice_fake_for(@protocol(SpinnerOperationsCounterDelegate));

        [subject setupWithDelegate:delegate];
    });


    describe(@"with an initial increment", ^{
        beforeEach(^{
            [subject increment];
        });

        it(@"should notify the delegate to show a spinner", ^{
            delegate should have_received(@selector(spinnerOperationsCounterShouldShowSpinner:)).with(subject);
        });

        context(@"with a subsequent increment", ^{
            beforeEach(^{
                [(id<CedarDouble>)delegate reset_sent_messages];

                [subject increment];
            });

            it(@"should not notify the delegate to show a spinner again", ^{
                delegate should_not have_received(@selector(spinnerOperationsCounterShouldShowSpinner:)).with(subject);
            });

            describe(@"with a subsequent decrement", ^{
                beforeEach(^{
                    [subject decrement];
                });

                it(@"should not notify the delegate", ^{
                    delegate should_not have_received(@selector(spinnerOperationsCounterShouldShowSpinner:)).with(subject);
                    delegate should_not have_received(@selector(spinnerOperationsCounterShouldHideSpinner:)).with(subject);
                });

                describe(@"with a subsequent decrement", ^{
                    beforeEach(^{
                        [subject decrement];
                    });

                    it(@"should notify the delegate to hide its spinner", ^{
                        delegate should have_received(@selector(spinnerOperationsCounterShouldHideSpinner:)).with(subject);
                    });

                    describe(@"with a subsequent decrement", ^{
                        beforeEach(^{
                            [(id<CedarDouble>)delegate reset_sent_messages];

                            [subject decrement];
                        });

                        it(@"should not notify the delegate", ^{
                            delegate should_not have_received(@selector(spinnerOperationsCounterShouldShowSpinner:)).with(subject);
                            delegate should_not have_received(@selector(spinnerOperationsCounterShouldHideSpinner:)).with(subject);
                        });

                        describe(@"with a subsequent increment", ^{
                            beforeEach(^{
                                [subject increment];
                            });

                            it(@"should notify the delegate to show a spinner", ^{
                                delegate should have_received(@selector(spinnerOperationsCounterShouldShowSpinner:)).with(subject);
                            });
                        });
                    });
                });
            });
        });
    });

    context(@"when the delegate has been released", ^{
        it(@"should not explode", ^{
            __weak id<SpinnerOperationsCounterDelegate> releasedDelegate;
            @autoreleasepool {
                releasedDelegate = nice_fake_for(@protocol(SpinnerOperationsCounterDelegate));
                [subject setupWithDelegate:releasedDelegate];
            }

            ^ { [subject increment]; } should_not raise_exception;
        });
    });
});

SPEC_END
