#import <Cedar/Cedar.h>
#import "JSONClient.h"
#import <KSDeferred/KSDeferred.h>
#import "RequestDictionaryBuilder.h"
#import "TimesheetDeserializer.h"
#import "RequestPromiseClient.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "RepliconClient.h"
#import "HomeFlowRequestProvider.h"
#import "InjectorKeys.h"
#import "IndexCursor.h"
#import "HomeSummaryRepository.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(HomeSummaryRepositorySpec)

describe(@"HomeSummaryRepository", ^{
    __block HomeSummaryRepository   *subject;
    __block id<RequestPromiseClient> client;
    __block KSDeferred              *jsonClientDeferred;
    __block NSURLRequest            *request;
    __block HomeFlowRequestProvider *homeFlowRequestProvider;
    __block id<BSBinder, BSInjector> injector;
    
    beforeEach(^{
        injector = [InjectorProvider injector];
    });
    
    
    beforeEach(^{
        client = nice_fake_for(@protocol(RequestPromiseClient));
        homeFlowRequestProvider = nice_fake_for([HomeFlowRequestProvider class]);
        
        
    });
    
    beforeEach(^{
        jsonClientDeferred = [[KSDeferred alloc] init];
        
        client stub_method(@selector(promiseWithRequest:))
        .and_do_block(^KSPromise *(NSURLRequest *receivedRequest){
            request = receivedRequest;
            return jsonClientDeferred.promise;
        });
        
        
    });
    
    beforeEach(^{
        [injector bind:InjectorKeyRepliconClientForeground toInstance:client];
        [injector bind:[HomeFlowRequestProvider class] toInstance:homeFlowRequestProvider];
    });
    
    beforeEach(^{
        subject = [injector getInstance:[HomeSummaryRepository class]];
    });
    
    it(@"should correctly set the dependancies", ^{
        subject.homeFlowRequestProvider should be_same_instance_as(homeFlowRequestProvider);
        subject.client should be_same_instance_as(client);
    });
    
    describe(@"-getHomeSummary", ^{
        __block KSPromise *promise;
        __block NSURLRequest *expectedRequest;
        __block KSDeferred *deferred;
        
        beforeEach(^{
            deferred = [[KSDeferred alloc] init];
            expectedRequest = [[NSURLRequest alloc] init];
            homeFlowRequestProvider stub_method(@selector(requestForHomeFlowService))
            .and_return(expectedRequest);
            client stub_method(@selector(promiseWithRequest:))
            .with(expectedRequest)
            .and_return(deferred.promise);
            promise = [subject getHomeSummary];
        });
        
        context(@"when the request suceeds", ^{
            beforeEach(^{
                [deferred resolveWithValue:@123];
            });
            
            it(@"should deserialize the response", ^{
                promise.value should equal(@123);
            });
        });
        
        context(@"when the request fails", ^{
            __block NSError *error;
            beforeEach(^{
                error = nice_fake_for([NSError class]);
                [deferred rejectWithError:error];
            });
            
            it(@"should return an error", ^{
                promise.rejected should be_truthy;
                promise.error should be_same_instance_as(error);
            });
        });
        
    });

});

SPEC_END
