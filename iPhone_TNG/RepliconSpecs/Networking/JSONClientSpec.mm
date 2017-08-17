#import <Cedar/Cedar.h>
#import "JSONClient.h"
#import "URLSessionClient.h"
#import <KSDeferred/KSDeferred.h>
#import "PSHKFakeOperationQueue.h"
#import "Constants.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(JSONClientSpec)

describe(@"JSONClient", ^{
    __block JSONClient *subject;
    __block URLSessionClient *client;
    __block PSHKFakeOperationQueue *queue;
    __block id <UserSession> userSession;


    beforeEach(^{
        client = nice_fake_for([URLSessionClient class]);
        userSession = nice_fake_for(@protocol(UserSession));
        queue = [[PSHKFakeOperationQueue alloc] init];
        queue.runSynchronously = NO;
        subject = [[JSONClient alloc] initWithURLSessionClient:client userSession:userSession queue:queue];
    });

    describe(@"making a request and getting a promise back", ^{
        __block NSURLRequest *request;
        __block KSDeferred *deferred;
        __block KSPromise *promise;
        beforeEach(^{
            deferred = [[KSDeferred alloc] init];
            request = nice_fake_for([NSURLRequest class]);
            request stub_method(@selector(URL)).and_return([NSURL URLWithString:@"my-special-URL"]);

            client stub_method(@selector(promiseWithRequest:)).and_return(deferred.promise);
            promise = [subject promiseWithRequest:request];
        });

        it(@"should send the request to the client", ^{
            client should have_received(@selector(promiseWithRequest:)).with(request);
        });

        context(@"when the request returns NSData when session is valid", ^{
            __block NSData *data;

            beforeEach(^{
                userSession stub_method(@selector(validUserSession)).and_return(YES);
            });

            context(@"When valid json data", ^{
                beforeEach(^{
                    data = [NSJSONSerialization dataWithJSONObject:@{@"hello": @"world"} options:0 error:nil];
                    [deferred resolveWithValue:data];
                });

                context(@"when the next operation on the queue runs", ^{
                    beforeEach(^{
                        [queue runNextOperation];
                    });

                    it(@"should deserialize the JSON data and resolve the promise with it", ^{
                        promise.value should equal(@{@"hello": @"world"});
                    });
                });
            });

            context(@"When not valid json data", ^{
                beforeEach(^{
                    [deferred resolveWithValue:[NSData data]];
                });

                context(@"when the next operation on the queue runs", ^{
                    beforeEach(^{
                        [queue runNextOperation];
                    });

                    it(@"should deserialize the JSON data and resolve the promise with it", ^{
                        promise.error should_not be_nil;
                        promise.error.domain should equal(RepliconHTTPNonJsonResponseErrorDomain);
                    });
                });
            });

        });

        context(@"when the request returns NSData when session is not valid", ^{
            __block NSData *data;

            beforeEach(^{
                userSession stub_method(@selector(validUserSession)).and_return(NO);

            });

            context(@"When valid json data", ^{
                beforeEach(^{
                    data = [NSJSONSerialization dataWithJSONObject:@{@"hello": @"world"} options:0 error:nil];
                    [deferred resolveWithValue:data];
                });

                context(@"when the next operation on the queue runs", ^{
                    beforeEach(^{
                        [queue runNextOperation];
                    });

                    it(@"should reject the promise with an error", ^{
                        promise.error should_not be_nil;
                        promise.error.domain should equal(InvalidUserSessionRequestDomain);

                    });
                });
            });

            context(@"When not valid json data", ^{
                beforeEach(^{
                    [deferred resolveWithValue:[NSData data]];
                });

                context(@"when the next operation on the queue runs", ^{
                    beforeEach(^{
                        [queue runNextOperation];
                    });

                    it(@"should reject the promise with an error", ^{
                        promise.error should_not be_nil;
                        promise.error.domain should equal(InvalidUserSessionRequestDomain);

                    });
                });
            });

        });

        context(@"when the request fails with an error", ^{
            __block NSError *error;

            beforeEach(^{
                error = nice_fake_for([NSError class]);
                [deferred rejectWithError:error];
            });

            context(@"when the next operation on the queue runs", ^{
                beforeEach(^{
                    [queue runNextOperation];
                });

                it(@"should resolve the promise with an error", ^{
                    promise.error should be_same_instance_as(error);
                });
            });
        });
    });

    describe(@"making a request and getting a promise back while session is invalid( As in case of Forgot Password)", ^{
        __block NSURLRequest *request;
        __block KSDeferred *deferred;
        __block KSPromise *promise;
        beforeEach(^{
            deferred = [[KSDeferred alloc] init];
            request = nice_fake_for([NSURLRequest class]);


            NSDictionary *header = [[NSDictionary alloc]initWithObjectsAndKeys:
                                    RequestMadeWhileInvalidUserSessionHeaderValue,
                                    RequestMadeWhileInvalidUserSessionHeaderKey,
                                    nil];

            request stub_method(@selector(allHTTPHeaderFields)).and_return(header);
            request stub_method(@selector(URL)).and_return([NSURL URLWithString:@"my-special-URL"]);

            client stub_method(@selector(promiseWithRequest:)).and_return(deferred.promise);
            promise = [subject promiseWithRequest:request];
        });

        it(@"should send the request to the client", ^{
            client should have_received(@selector(promiseWithRequest:)).with(request);
        });


        context(@"when the request returns NSData when session is not valid", ^{
            __block NSData *data;

            beforeEach(^{
                userSession stub_method(@selector(validUserSession)).and_return(NO);

            });

            context(@"When valid json data", ^{
                beforeEach(^{
                    data = [NSJSONSerialization dataWithJSONObject:@{@"hello": @"world"} options:0 error:nil];
                    [deferred resolveWithValue:data];
                });

                context(@"when the next operation on the queue runs", ^{
                    beforeEach(^{
                        [queue runNextOperation];
                    });

                    it(@"should deserialize the JSON data and resolve the promise with it", ^{
                        promise.value should equal(@{@"hello": @"world"});
                    });
                });
            });

            context(@"When not valid json data", ^{
                beforeEach(^{
                    [deferred resolveWithValue:[NSData data]];
                });

                context(@"when the next operation on the queue runs", ^{
                    beforeEach(^{
                        [queue runNextOperation];
                    });

                    it(@"should reject the promise with an error", ^{
                        promise.error should_not be_nil;
                        promise.error.domain should equal(InvalidUserSessionRequestDomain);

                    });
                });
            });

        });

    });
    
    describe(@"making a request and getting a promise back while session is invalid for AppConfig request with headerfields", ^{
        __block NSURLRequest *request;
        __block KSDeferred *deferred;
        __block KSPromise *promise;
        beforeEach(^{
            deferred = [[KSDeferred alloc] init];
            request = nice_fake_for([NSURLRequest class]);
            
            NSDictionary *header = [[NSDictionary alloc]initWithObjectsAndKeys:
                                    RequestMadeWhileInvalidUserSessionHeaderValue,
                                    RequestMadeWhileInvalidUserSessionHeaderKey,
                                    nil];
            
            request stub_method(@selector(allHTTPHeaderFields)).and_return(header);
            request stub_method(@selector(URL)).and_return([NSURL URLWithString:@"http://my-special-URL/app-config"]);
            
            client stub_method(@selector(promiseWithRequest:)).and_return(deferred.promise);
            promise = [subject promiseWithRequest:request];
        });
        
        it(@"should send the request to the client", ^{
            client should have_received(@selector(promiseWithRequest:)).with(request);
        });
        
        
        context(@"when the request returns NSData when session is not valid", ^{
            __block NSData *data;
            
            beforeEach(^{
                userSession stub_method(@selector(validUserSession)).and_return(NO);
                
            });
            
            context(@"When valid json data", ^{
                __block NSDictionary *dataDict = @{@"hello": @"world"};
                beforeEach(^{
                    data = [NSJSONSerialization dataWithJSONObject:dataDict options:0 error:nil];
                    [deferred resolveWithValue:data];
                });
                
                context(@"when the next operation on the queue runs", ^{
                    beforeEach(^{
                        [queue runNextOperation];
                    });
                    
                    it(@"should deserialize the JSON data and resolve the promise with it", ^{
                        promise.value should equal(dataDict);
                    });
                });
            });
        });
        
    });
    
    describe(@"making a request and getting a promise back while session is invalid for AppConfig request with no headerfields ", ^{
        __block NSURLRequest *request;
        __block KSDeferred *deferred;
        __block KSPromise *promise;
        beforeEach(^{
            deferred = [[KSDeferred alloc] init];
            request = nice_fake_for([NSURLRequest class]);
            request stub_method(@selector(URL)).and_return([NSURL URLWithString:@"http://my-special-URL/app-config"]);
            
            client stub_method(@selector(promiseWithRequest:)).and_return(deferred.promise);
            promise = [subject promiseWithRequest:request];
        });
        
        it(@"should send the request to the client", ^{
            client should have_received(@selector(promiseWithRequest:)).with(request);
        });
        
        
        context(@"when the request returns NSData when session is not valid", ^{
            __block NSData *data;
            
            beforeEach(^{
                userSession stub_method(@selector(validUserSession)).and_return(NO);
                
            });
            
            context(@"When valid json data", ^{
                __block NSDictionary *dataDict = @{@"source": @"globale",@"node_backend":@1};
                beforeEach(^{
                    data = [NSJSONSerialization dataWithJSONObject:dataDict options:0 error:nil];
                    [deferred resolveWithValue:data];
                });
                
                context(@"when the next operation on the queue runs", ^{
                    beforeEach(^{
                        [queue runNextOperation];
                    });
                    
                    it(@"should deserialize the JSON data and resolve the promise with it", ^{
                        promise.value should equal(dataDict);
                    });
                });
            });
        });
        
    });
    
    describe(@"making a request and getting a promise back while session is invalid for other than AppConfig request with headerfields", ^{
        __block NSURLRequest *request;
        __block KSDeferred *deferred;
        __block KSPromise *promise;
        beforeEach(^{
            deferred = [[KSDeferred alloc] init];
            request = nice_fake_for([NSURLRequest class]);
            
            NSDictionary *header = [[NSDictionary alloc]initWithObjectsAndKeys:
                                    RequestMadeWhileInvalidUserSessionHeaderValue,
                                    RequestMadeWhileInvalidUserSessionHeaderKey,
                                    nil];
            
            request stub_method(@selector(allHTTPHeaderFields)).and_return(header);
            request stub_method(@selector(URL)).and_return([NSURL URLWithString:@"my-special-URL"]);
            
            client stub_method(@selector(promiseWithRequest:)).and_return(deferred.promise);
            promise = [subject promiseWithRequest:request];
        });
        
        it(@"should send the request to the client", ^{
            client should have_received(@selector(promiseWithRequest:)).with(request);
        });
        
        
        context(@"when the request returns NSData when session is not valid", ^{
            __block NSData *data;
            
            beforeEach(^{
                userSession stub_method(@selector(validUserSession)).and_return(NO);
                
            });
            
            context(@"When valid json data", ^{
                __block NSDictionary *dataDict = @{@"source": @"globale",@"node_backend":@1};
                beforeEach(^{
                    data = [NSJSONSerialization dataWithJSONObject:dataDict options:0 error:nil];
                    [deferred resolveWithValue:data];
                });
                
                context(@"when the next operation on the queue runs", ^{
                    beforeEach(^{
                        [queue runNextOperation];
                    });
                    
                    it(@"should deserialize the JSON data and resolve the promise with it", ^{
                        promise.value should equal(dataDict);
                    });
                });
            });
        });
        
    });
    
    describe(@"making a request and getting a promise back while session is invalid for other than AppConfig request with no headerfields", ^{
        __block NSURLRequest *request;
        __block KSDeferred *deferred;
        __block KSPromise *promise;
        beforeEach(^{
            deferred = [[KSDeferred alloc] init];
            request = nice_fake_for([NSURLRequest class]);
            
            request stub_method(@selector(URL)).and_return([NSURL URLWithString:@"my-special-URL"]);
            
            client stub_method(@selector(promiseWithRequest:)).and_return(deferred.promise);
            promise = [subject promiseWithRequest:request];
        });
        
        it(@"should send the request to the client", ^{
            client should have_received(@selector(promiseWithRequest:)).with(request);
        });
        
        
        context(@"when the request returns NSData when session is not valid", ^{
            __block NSData *data;
            
            beforeEach(^{
                userSession stub_method(@selector(validUserSession)).and_return(NO);
                
            });
            
            context(@"When valid json data", ^{
                __block NSDictionary *dataDict = @{@"hello": @"world"};
                beforeEach(^{
                    data = [NSJSONSerialization dataWithJSONObject:dataDict options:0 error:nil];
                    [deferred resolveWithValue:data];
                });
                
                context(@"when the next operation on the queue runs", ^{
                    beforeEach(^{
                        [queue runNextOperation];
                    });
                    
                    it(@"should reject the promise with an error", ^{
                        promise.error should_not be_nil;
                        promise.error.domain should equal(InvalidUserSessionRequestDomain);
                    });
                });
            });
        });
        
    });
    
});

SPEC_END
