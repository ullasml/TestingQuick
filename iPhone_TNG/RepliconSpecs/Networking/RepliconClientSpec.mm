#import <MacTypes.h>
#import <Cedar/Cedar.h>
#import "RepliconClient.h"
#import "RequestPromiseClient.h"
#import <KSDeferred/KSDeferred.h>
#import "RepliconSpecHelper.h"
#import "ServerErrorSerializer.h"
#import "HttpErrorSerializer.h"
#import "ErrorReporter.h"
#import "Constants.h"
#import "ApplicationFlowControl.h"
#import "ErrorPresenter.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(RepliconClientSpec)

describe(@"RepliconClient", ^{
    __block RepliconClient *subject;
    __block id<RequestPromiseClient> requestPromiseClient;
    __block ServerErrorSerializer *errorDeserializer;
    __block HttpErrorSerializer *httpErrorHandler;
    __block ErrorReporter *errorReporter;
    __block ApplicationFlowControl *flowControl;
    __block ErrorPresenter *errorPresenter;


    beforeEach(^{
        errorPresenter = nice_fake_for([ErrorPresenter class]);
        flowControl = nice_fake_for([ApplicationFlowControl class]);
        errorReporter = nice_fake_for([ErrorReporter class]);
        httpErrorHandler = nice_fake_for([HttpErrorSerializer class]);
        requestPromiseClient = nice_fake_for(@protocol(RequestPromiseClient));
        errorDeserializer = nice_fake_for([ServerErrorSerializer class]);
        subject = [[RepliconClient alloc] initWithClient:requestPromiseClient
                                   serverErrorSerializer:errorDeserializer
                                     httpErrorSerializer:httpErrorHandler
                                             flowControl:flowControl
                                          errorPresenter:errorPresenter
                                           errorReporter:errorReporter];
    });

    describe(@"making a request to replicon servers", ^{
        __block NSURLRequest *request;
        __block KSPromise *promise;
        __block KSDeferred *deferred;
        beforeEach(^{
            request = nice_fake_for([NSURLRequest class]);

            deferred = [[KSDeferred alloc] init];
            requestPromiseClient stub_method(@selector(promiseWithRequest:)).and_return(deferred.promise);

            promise = [subject promiseWithRequest:request];
        });

        it(@"should pass the request to its request promise client", ^{
            requestPromiseClient should have_received(@selector(promiseWithRequest:)).with(request);
        });

        it(@"should not handle HTTP error", ^{
            httpErrorHandler should_not have_received(@selector(serializeHTTPError:));
        });



        context(@"when the request resolves with an error dictionary passed into its success callback", ^{

            describe(@"When error needs to be logged for error domains", ^{

                context(@"When <InvalidTimesheetFormatErrorDomain>", ^{
                    __block NSError *error;
                    beforeEach(^{
                        error = nice_fake_for([NSError class]);
                        error stub_method(@selector(domain)).and_return(InvalidTimesheetFormatErrorDomain);
                        errorDeserializer stub_method(@selector(deserialize:isFromRequestMadeWhilePendingQueueSync:request:)).and_return(error);
                        NSDictionary *errorDictionary = [[NSDictionary alloc] init];
                        [deferred resolveWithValue:errorDictionary];
                    });

                    it(@"should report error to customer support", ^{
                        errorReporter should have_received(@selector(reportToCustomerSupportWithError:)).with(error);
                    });

                    it(@"should perform flow control", ^{
                        flowControl should have_received(@selector(performFlowControlForError:)).with(error);
                    });

                    it(@"should present alert for error", ^{
                        errorPresenter should have_received(@selector(presentAlertViewForError:)).with(error);
                    });

                    it(@"should reject the returned promise with the error passed in", ^{
                        promise.fulfilled should be_falsy;
                        promise.error should be_same_instance_as(error);
                    });
                });

                context(@"When <OperationTimeoutErrorDomain>", ^{
                    __block NSError *error;
                    beforeEach(^{
                        error = nice_fake_for([NSError class]);
                        error stub_method(@selector(domain)).and_return(OperationTimeoutErrorDomain);
                        errorDeserializer stub_method(@selector(deserialize:isFromRequestMadeWhilePendingQueueSync:request:)).and_return(error);
                        NSDictionary *errorDictionary = [[NSDictionary alloc] init];
                        [deferred resolveWithValue:errorDictionary];
                    });

                    it(@"should report error to customer support", ^{
                        errorReporter should have_received(@selector(reportToCustomerSupportWithError:)).with(error);
                    });

                    it(@"should perform flow control", ^{
                        flowControl should have_received(@selector(performFlowControlForError:)).with(error);
                    });

                    it(@"should present alert for error", ^{
                        errorPresenter should have_received(@selector(presentAlertViewForError:)).with(error);
                    });

                    it(@"should reject the returned promise with the error passed in", ^{
                        promise.fulfilled should be_falsy;
                        promise.error should be_same_instance_as(error);
                    });
                });

                context(@"When <UriErrorDomain>", ^{
                    __block NSError *error;
                    beforeEach(^{
                        error = nice_fake_for([NSError class]);
                        error stub_method(@selector(domain)).and_return(UriErrorDomain);
                        errorDeserializer stub_method(@selector(deserialize:isFromRequestMadeWhilePendingQueueSync:request:)).and_return(error);
                        NSDictionary *errorDictionary = [[NSDictionary alloc] init];
                        [deferred resolveWithValue:errorDictionary];
                    });

                    it(@"should report error to customer support", ^{
                        errorReporter should have_received(@selector(reportToCustomerSupportWithError:)).with(error);
                    });

                    it(@"should perform flow control", ^{
                        flowControl should have_received(@selector(performFlowControlForError:)).with(error);
                    });

                    it(@"should present alert for error", ^{
                        errorPresenter should have_received(@selector(presentAlertViewForError:)).with(error);
                    });

                    it(@"should reject the returned promise with the error passed in", ^{
                        promise.fulfilled should be_falsy;
                        promise.error should be_same_instance_as(error);
                    });
                });

                context(@"When <UnknownErrorDomain>", ^{
                    __block NSError *error;
                    beforeEach(^{
                        error = nice_fake_for([NSError class]);
                        error stub_method(@selector(domain)).and_return(UnknownErrorDomain);
                        errorDeserializer stub_method(@selector(deserialize:isFromRequestMadeWhilePendingQueueSync:request:)).and_return(error);
                        NSDictionary *errorDictionary = [[NSDictionary alloc] init];
                        [deferred resolveWithValue:errorDictionary];
                    });

                    it(@"should report error to customer support", ^{
                        errorReporter should have_received(@selector(reportToCustomerSupportWithError:)).with(error);
                    });

                    it(@"should perform flow control", ^{
                        flowControl should have_received(@selector(performFlowControlForError:)).with(error);
                    });

                    it(@"should present alert for error", ^{
                        errorPresenter should have_received(@selector(presentAlertViewForError:)).with(error);
                    });

                    it(@"should reject the returned promise with the error passed in", ^{
                        promise.fulfilled should be_falsy;
                        promise.error should be_same_instance_as(error);
                    });
                });

                context(@"When <NoAuthErrorDomain>", ^{
                    __block NSError *error;
                    beforeEach(^{
                        error = nice_fake_for([NSError class]);
                        error stub_method(@selector(domain)).and_return(NoAuthErrorDomain);
                        errorDeserializer stub_method(@selector(deserialize:isFromRequestMadeWhilePendingQueueSync:request:)).and_return(error);
                        NSDictionary *errorDictionary = [[NSDictionary alloc] init];
                        [deferred resolveWithValue:errorDictionary];
                    });


                    it(@"should report error to customer support", ^{
                        errorReporter should have_received(@selector(reportToCustomerSupportWithError:)).with(error);
                    });

                    it(@"should perform flow control", ^{
                        flowControl should have_received(@selector(performFlowControlForError:)).with(error);
                    });

                    it(@"should present alert for error", ^{
                        errorPresenter should have_received(@selector(presentAlertViewForError:)).with(error);
                    });

                    it(@"should reject the returned promise with the error passed in", ^{
                        promise.fulfilled should be_falsy;
                        promise.error should be_same_instance_as(error);
                    });
                });

                context(@"When <RandomErrorDomain>", ^{
                    __block NSError *error;
                    beforeEach(^{
                        error = nice_fake_for([NSError class]);
                        error stub_method(@selector(domain)).and_return(RandomErrorDomain);
                        errorDeserializer stub_method(@selector(deserialize:isFromRequestMadeWhilePendingQueueSync:request:)).and_return(error);
                        NSDictionary *errorDictionary = [[NSDictionary alloc] init];
                        [deferred resolveWithValue:errorDictionary];
                    });
                    it(@"should report error to customer support", ^{
                        errorReporter should have_received(@selector(reportToCustomerSupportWithError:)).with(error);
                    });

                    it(@"should perform flow control", ^{
                        flowControl should have_received(@selector(performFlowControlForError:)).with(error);
                    });

                    it(@"should present alert for error", ^{
                        errorPresenter should have_received(@selector(presentAlertViewForError:)).with(error);
                    });

                    it(@"should reject the returned promise with the error passed in", ^{
                        promise.fulfilled should be_falsy;
                        promise.error should be_same_instance_as(error);
                    });
                });

                context(@"When <AuthorizationErrorDomain>", ^{
                    __block NSError *error;
                    beforeEach(^{
                        error = nice_fake_for([NSError class]);
                        error stub_method(@selector(domain)).and_return(AuthorizationErrorDomain);
                        errorDeserializer stub_method(@selector(deserialize:isFromRequestMadeWhilePendingQueueSync:request:)).and_return(error);
                        NSDictionary *errorDictionary = [[NSDictionary alloc] init];
                        [deferred resolveWithValue:errorDictionary];
                    });

                    it(@"should report error to customer support", ^{
                        errorReporter should have_received(@selector(reportToCustomerSupportWithError:)).with(error);
                    });

                    it(@"should perform flow control", ^{
                        flowControl should have_received(@selector(performFlowControlForError:)).with(error);
                    });

                    it(@"should present alert for error", ^{
                        errorPresenter should have_received(@selector(presentAlertViewForError:)).with(error);
                    });

                    it(@"should reject the returned promise with the error passed in", ^{
                        promise.fulfilled should be_falsy;
                        promise.error should be_same_instance_as(error);
                    });
                });

            });

            describe(@"When error need not be logged", ^{

                __block NSError *error;
                beforeEach(^{
                    error = nice_fake_for([NSError class]);
                  errorDeserializer stub_method(@selector(deserialize:isFromRequestMadeWhilePendingQueueSync:request:)).and_return(error);
                    NSDictionary *errorDictionary = [[NSDictionary alloc] init];
                    [deferred resolveWithValue:errorDictionary];
                });

                it(@"should not report error to customer support", ^{
                    errorReporter should_not have_received(@selector(reportToCustomerSupportWithError:));
                });

                it(@"should perform flow control", ^{
                    flowControl should have_received(@selector(performFlowControlForError:)).with(error);
                });

                it(@"should present alert for error", ^{
                    errorPresenter should have_received(@selector(presentAlertViewForError:)).with(error);
                });


                it(@"should reject the returned promise with the error passed in", ^{
                    promise.fulfilled should be_falsy;
                    promise.error should be_same_instance_as(error);
                });
            });

        });

        context(@"when the request resolves with a non-error dictionary passed into its success callback", ^{

            beforeEach(^{
                errorDeserializer stub_method(@selector(deserialize:isFromRequestMadeWhilePendingQueueSync:request:)).and_return(nil);
                NSDictionary *sucessDictionary = [[NSDictionary alloc] init];
                [deferred resolveWithValue:sucessDictionary];
            });

            it(@"should resolve the returned promise", ^{
                promise.fulfilled should be_truthy;
            });

            it(@"should resolve the returned promise with the dictionary passed in", ^{
                promise.value should equal(@{});
            });
        });

        context(@"When the request fails", ^{

            __block NSError *expectedError;
            beforeEach(^{
                expectedError = nice_fake_for([NSError class]);

            });

            context(@"When error domain is RepliconHTTPNonJsonResponseErrorDomain", ^{

                beforeEach(^{
                    expectedError stub_method(@selector(domain)).and_return(RepliconHTTPNonJsonResponseErrorDomain);
                    httpErrorHandler stub_method(@selector(serializeHTTPError:)).and_return(expectedError);
                });

                it(@"should reject with Error", ^{
                    NSError *error;
                    error = nice_fake_for([NSError class]);
                    [deferred rejectWithError:error];
                    httpErrorHandler should have_received(@selector(serializeHTTPError:)).with(error);
                    errorReporter should_not have_received(@selector(reportToCustomerSupportWithError:));
                    errorPresenter should have_received(@selector(presentAlertViewForError:)).with(expectedError);
                    errorReporter should have_received(@selector(checkForServerMaintenanaceWithError:));

                    promise.fulfilled should be_falsy;
                    promise.rejected should be_truthy;
                    promise.error should equal(expectedError);
                });
            });
            
            context(@"When error domain is RepliconServiceUnAvailabilityResponseErrorDomain", ^{
                
                beforeEach(^{
                    expectedError stub_method(@selector(domain)).and_return(RepliconServiceUnAvailabilityResponseErrorDomain);
                    httpErrorHandler stub_method(@selector(serializeHTTPError:)).and_return(expectedError);
                });
                
                it(@"should reject with Error", ^{
                    NSError *error;
                    error = nice_fake_for([NSError class]);
                    [deferred rejectWithError:error];
                    httpErrorHandler should have_received(@selector(serializeHTTPError:)).with(error);
                    errorReporter should_not have_received(@selector(reportToCustomerSupportWithError:));
                    errorPresenter should have_received(@selector(presentAlertViewForError:)).with(expectedError);
                    errorReporter should have_received(@selector(checkForServerMaintenanaceWithError:));
                    
                    promise.fulfilled should be_falsy;
                    promise.rejected should be_truthy;
                    promise.error should equal(expectedError);
                });
            });


            context(@"When error domain is not RepliconHTTPNonJsonResponseErrorDomain ", ^{
                beforeEach(^{
                    expectedError stub_method(@selector(domain)).and_return(RepliconHTTPRequestErrorDomain);
                    httpErrorHandler stub_method(@selector(serializeHTTPError:)).and_return(expectedError);
                });

                it(@"should reject with Error", ^{
                    NSError *error;
                    error = nice_fake_for([NSError class]);
                    [deferred rejectWithError:error];
                    httpErrorHandler should have_received(@selector(serializeHTTPError:)).with(error);
                    errorReporter should have_received(@selector(reportToCustomerSupportWithError:)).with(expectedError);
                    errorPresenter should have_received(@selector(presentAlertViewForError:)).with(expectedError);
                    errorReporter should_not have_received(@selector(checkForServerMaintenanaceWithError:));
                    promise.fulfilled should be_falsy;
                    promise.rejected should be_truthy;
                    promise.error should equal(expectedError);
                });

            });

        });

        
    });

    describe(@"making a pending sync request to replicon servers", ^{
        __block NSURLRequest *request;
        __block KSPromise *promise;
        __block KSDeferred *deferred;
        beforeEach(^{
            request = nice_fake_for([NSURLRequest class]);

            NSDictionary *header = [[NSDictionary alloc]initWithObjectsAndKeys:
                                    RequestMadeWhilePendingQueueSyncHeaderValue,
                                    RequestMadeWhilePendingQueueSyncHeaderKey,
                                    nil];

            request stub_method(@selector(allHTTPHeaderFields)).and_return(header);

            deferred = [[KSDeferred alloc] init];
            requestPromiseClient stub_method(@selector(promiseWithRequest:)).and_return(deferred.promise);

            promise = [subject promiseWithRequest:request];
        });

        it(@"should pass the request to its request promise client", ^{
            requestPromiseClient should have_received(@selector(promiseWithRequest:)).with(request);
        });

        it(@"should not handle HTTP error", ^{
            httpErrorHandler should_not have_received(@selector(serializeHTTPError:));
        });

        context(@"when the request resolves with an error dictionary passed into its success callback", ^{

            describe(@"When error needs to be logged for error domains", ^{

                context(@"When <RepliconNoAlertErrorDomain>", ^{
                    __block NSError *error;
                    beforeEach(^{
                        error = nice_fake_for([NSError class]);
                        error stub_method(@selector(domain)).and_return(RepliconNoAlertErrorDomain);
                        error stub_method(@selector(localizedDescription)).and_return(@"fake error has occured");
                        errorDeserializer stub_method(@selector(deserialize:isFromRequestMadeWhilePendingQueueSync:request:)).and_return(error);
                        NSDictionary *errorDictionary = [[NSDictionary alloc] init];
                        [deferred resolveWithValue:errorDictionary];
                    });

                    it(@"should not report error to customer support", ^{
                        errorReporter should_not have_received(@selector(reportToCustomerSupportWithError:)).with(error);
                    });

                    it(@"should perform flow control", ^{
                        flowControl should have_received(@selector(performFlowControlForError:)).with(error);
                    });

                    it(@"should present alert for error", ^{
                        errorPresenter should have_received(@selector(presentAlertViewForError:)).with(error);
                    });

                    it(@"should reject the returned promise with the error passed in", ^{
                        promise.fulfilled should be_truthy;
                        promise.error should be_nil;
                    });

                    it(@"should resolve the returned promise with the dictionary passed in", ^{
                        promise.value should equal(@{@"error": @"fake error has occured"});
                    });
                });

            });


            
        });

    });

    describe(@"punch request to replicon servers", ^{
        __block NSURLRequest *request;
        __block KSPromise *promise;
        __block KSDeferred *deferred;
        beforeEach(^{
            request = nice_fake_for([NSURLRequest class]);

            NSDictionary *header = [[NSDictionary alloc]initWithObjectsAndKeys:
                                    @"some-value",
                                    PunchRequestIdentifierHeader,
                                    nil];

            request stub_method(@selector(allHTTPHeaderFields)).and_return(header);

            deferred = [[KSDeferred alloc] init];
            requestPromiseClient stub_method(@selector(promiseWithRequest:)).and_return(deferred.promise);

            promise = [subject promiseWithRequest:request];
        });

        it(@"should pass the request to its request promise client", ^{
            requestPromiseClient should have_received(@selector(promiseWithRequest:)).with(request);
        });

        it(@"should not handle HTTP error", ^{
            httpErrorHandler should_not have_received(@selector(serializeHTTPError:));
        });

        context(@"when the request resolves with an error dictionary passed into its success callback", ^{

            describe(@"When error needs to be logged for error domains", ^{

                context(@"When <RepliconNoAlertErrorDomain>", ^{
                    __block NSError *error;
                    beforeEach(^{
                        error = nice_fake_for([NSError class]);
                        error stub_method(@selector(domain)).and_return(RepliconNoAlertErrorDomain);
                        error stub_method(@selector(localizedDescription)).and_return(@"fake error has occured");
                        error stub_method(@selector(userInfo)).and_return(@{NSLocalizedDescriptionKey: @"fake error has occured",@"ErroredPunches":@"fake error node"});
                        errorDeserializer stub_method(@selector(deserialize:isFromRequestMadeWhilePendingQueueSync:request:)).and_return(error);
                        NSDictionary *errorDictionary = [[NSDictionary alloc] init];
                        [deferred resolveWithValue:errorDictionary];
                    });

                    it(@"should not report error to customer support", ^{
                        errorReporter should_not have_received(@selector(reportToCustomerSupportWithError:)).with(error);
                    });

                    it(@"should perform flow control", ^{
                        flowControl should have_received(@selector(performFlowControlForError:)).with(error);
                    });

                    it(@"should present alert for error", ^{
                        errorPresenter should have_received(@selector(presentAlertViewForError:)).with(error);
                    });

                    it(@"should reject the returned promise with the error passed in", ^{
                        promise.fulfilled should be_truthy;
                        promise.error should be_nil;
                    });

                    it(@"should resolve the returned promise with the dictionary passed in", ^{
                        promise.value should equal(@{@"d": @{@"errors": @[@{@"displayText": @"fake error has occured"}],@"erroredPunches":@"fake error node"}});
                    });
                });
                
            });
            
            
            
        });

        context(@"when the request resolves with an error dictionary with no node for errored punches", ^{

            __block NSError *error;
            beforeEach(^{
                error = nice_fake_for([NSError class]);
                error stub_method(@selector(domain)).and_return(RepliconNoAlertErrorDomain);
                error stub_method(@selector(localizedDescription)).and_return(@"fake error has occured");
                error stub_method(@selector(userInfo)).and_return(@{});
                errorDeserializer stub_method(@selector(deserialize:isFromRequestMadeWhilePendingQueueSync:request:)).and_return(error);
                NSDictionary *errorDictionary = [[NSDictionary alloc] init];
                [deferred resolveWithValue:errorDictionary];
            });

            it(@"should not report error to customer support", ^{
                errorReporter should_not have_received(@selector(reportToCustomerSupportWithError:)).with(error);
            });

            it(@"should perform flow control", ^{
                flowControl should have_received(@selector(performFlowControlForError:)).with(error);
            });

            it(@"should present alert for error", ^{
                errorPresenter should have_received(@selector(presentAlertViewForError:)).with(error);
            });

            it(@"should reject the returned promise with the error passed in", ^{
                promise.fulfilled should be_falsy;
                promise.error should be_same_instance_as(error);
            });

            it(@"promise value should be nil", ^{
                promise.value should be_nil;
            });
        });

    });
});

SPEC_END
