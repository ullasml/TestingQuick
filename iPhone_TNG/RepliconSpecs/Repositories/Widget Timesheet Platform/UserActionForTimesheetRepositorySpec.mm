#import <Cedar/Cedar.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(UserActionForTimesheetRepositorySpec)

describe(@"UserActionForTimesheetRepository", ^{
    __block UserActionForTimesheetRepository *subject;
    __block UserActionForTimesheetRequestProvider *userActionForTimesheetRequestProvider;
    __block id <RequestPromiseClient> client;
    __block NSURLRequest *request;
    __block KSDeferred *deferred;
    __block KSPromise *receivedPromise;

    beforeEach(^{
        deferred = [[KSDeferred alloc]init];
        request = [[NSURLRequest alloc]init];
        userActionForTimesheetRequestProvider = nice_fake_for([UserActionForTimesheetRequestProvider class]);
        client = nice_fake_for(@protocol(RequestPromiseClient));
        subject = [[UserActionForTimesheetRepository alloc]initWithUserActionForTimesheetRequestProvider:userActionForTimesheetRequestProvider client:client];
    });
    
    context(@"RightBarButtonActionTypeSubmit", ^{
        beforeEach(^{
            client stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
             userActionForTimesheetRequestProvider stub_method(@selector(requestForUserTimesheetAction:timesheetUri:comments:)).with(RightBarButtonActionTypeSubmit,@"timesheet-uri",@"some-comments").and_return(request);
            receivedPromise = [subject userActionOnTimesheetWithType:RightBarButtonActionTypeSubmit 
                                                        timesheetUri:@"timesheet-uri" 
                                                            comments:@"some-comments"];

        });   
        
        it(@"should ask UserActionForTimesheetRequestProvider for a correct request", ^{
            userActionForTimesheetRequestProvider should have_received(@selector(requestForUserTimesheetAction:timesheetUri:comments:)).with(RightBarButtonActionTypeSubmit,@"timesheet-uri",@"some-comments");
        });
        
        it(@"should send the request using the client", ^{
            client should have_received(@selector(promiseWithRequest:)).with(request);
        });
        
        context(@"When the promise succeeds", ^{
            beforeEach(^{
                [deferred resolveWithValue:@"some-value"];
            });
            
            it(@"should resolve the promise correctly", ^{
                receivedPromise.value should equal(@"some-value");
            });
        });
        
        context(@"When the promise fails", ^{
            __block NSError *error;
            beforeEach(^{
                error = [[NSError alloc]initWithDomain:@"some-error" code:0 userInfo:nil];
                [deferred rejectWithError:error];
            });
            
            it(@"should reject a promise with proper error", ^{
                receivedPromise.error should equal(error);
            });
        });
    });
    
    context(@"RightBarButtonActionTypeReOpen", ^{

        
        beforeEach(^{
            client stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
            userActionForTimesheetRequestProvider stub_method(@selector(requestForUserTimesheetAction:timesheetUri:comments:)).with(RightBarButtonActionTypeReOpen,@"timesheet-uri",@"some-comments").and_return(request);
            receivedPromise = [subject userActionOnTimesheetWithType:RightBarButtonActionTypeReOpen 
                                                        timesheetUri:@"timesheet-uri" 
                                                            comments:@"some-comments"];
            
        }); 
        
        it(@"should ask UserActionForTimesheetRequestProvider for a correct request", ^{
            userActionForTimesheetRequestProvider should have_received(@selector(requestForUserTimesheetAction:timesheetUri:comments:)).with(RightBarButtonActionTypeReOpen,@"timesheet-uri",@"some-comments");
        });
        
        it(@"should send the request using the client", ^{
            client should have_received(@selector(promiseWithRequest:)).with(request);
        });
        
        context(@"When the promise succeeds", ^{
            beforeEach(^{
                [deferred resolveWithValue:@"some-value"];
            });
            
            it(@"should resolve the promise correctly", ^{
                receivedPromise.value should equal(@"some-value");
            });
        });
        
        context(@"When the promise fails", ^{
            __block NSError *error;
            beforeEach(^{
                error = [[NSError alloc]initWithDomain:@"some-error" code:0 userInfo:nil];
                [deferred rejectWithError:error];
            });
            
            it(@"should reject a promise with proper error", ^{
                receivedPromise.error should equal(error);
            });
        });

    });
    
    context(@"RightBarButtonActionTypeReSubmit", ^{
        
        beforeEach(^{
            client stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
            userActionForTimesheetRequestProvider stub_method(@selector(requestForUserTimesheetAction:timesheetUri:comments:)).with(RightBarButtonActionTypeReSubmit,@"timesheet-uri",@"some-comments").and_return(request);
            receivedPromise = [subject userActionOnTimesheetWithType:RightBarButtonActionTypeReSubmit 
                                                        timesheetUri:@"timesheet-uri" 
                                                            comments:@"some-comments"];            
        });
        
        it(@"should ask UserActionForTimesheetRequestProvider for a correct request", ^{
            userActionForTimesheetRequestProvider should have_received(@selector(requestForUserTimesheetAction:timesheetUri:comments:)).with(RightBarButtonActionTypeReSubmit,@"timesheet-uri",@"some-comments");
        });
        
        it(@"should send the request using the client", ^{
            client should have_received(@selector(promiseWithRequest:)).with(request);
        });
        
        context(@"When the promise succeeds", ^{
            beforeEach(^{
                [deferred resolveWithValue:@"some-value"];
            });
            
            it(@"should resolve the promise correctly", ^{
                receivedPromise.value should equal(@"some-value");
            });
        });
        
        context(@"When the promise fails", ^{
            __block NSError *error;
            beforeEach(^{
                error = [[NSError alloc]initWithDomain:@"some-error" code:0 userInfo:nil];
                [deferred rejectWithError:error];
            });
            
            it(@"should reject a promise with proper error", ^{
                receivedPromise.error should equal(error);
            });
        });

    });
    
});

SPEC_END
