#import <Cedar/Cedar.h>
#import <KSDeferred/KSDeferred.h>
#import <Blindside/Blindside.h>
#import "AppConfigRepository.h"
#import "PersistedSettingsStorage.h"
#import "ReachabilityMonitor.h"
#import "NetworkClient.h"
#import "ModuleProvider.h"
#import "RepliconKitConstants.h"
#import "ModuleProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(AppConfigRepositorySpec)

describe(@"AppConfigRepository", ^{
    __block AppConfigRepository *subject;
    __block NSURLRequest *expectedRequest;
    __block KSDeferred *deferred;
    __block KSPromise *promise;
    __block PersistedSettingsStorage *persistedSettingsStorage;
    __block NetworkClient* client;
    __block id<BSBinder, BSInjector> injector;
    __block ReachabilityMonitor *reachabilityMonitor;
    __block NSMutableURLRequest *request;
    
    beforeEach(^{
        injector = [ModuleProvider injector];
    });
    
    beforeEach(^{
        client = nice_fake_for([NetworkClient class]);
        [injector bind:[NetworkClient class] toInstance:client];
        persistedSettingsStorage = nice_fake_for([PersistedSettingsStorage class]);
        [injector bind:[PersistedSettingsStorage class] toInstance:persistedSettingsStorage];
        reachabilityMonitor = nice_fake_for([ReachabilityMonitor class]);
        [injector bind:[ReachabilityMonitor class] toInstance:reachabilityMonitor];
        subject = [injector getInstance:[AppConfigRepository class]];
    });
    
    beforeEach(^{
        deferred = [[KSDeferred alloc] init];
        expectedRequest = [[NSURLRequest alloc] init];
        
        client stub_method(@selector(promiseWithRequest:))
        .and_do_block(^KSPromise *(NSURLRequest *receivedRequest){
            expectedRequest = receivedRequest;
            return deferred.promise;
        });
    });
    
    describe(@"when network is not there", ^{
        beforeEach(^{
            reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(NO);
            [subject appConfigForRequest:request];
        });
        
        it(@"Should not trigger request", ^{
            client should_not have_received(@selector(promiseWithRequest:));
        });
    });
    
    describe(@"when the request succeeds", ^{
        beforeEach(^{
            reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
            promise =  [client promiseWithRequest:nil];
        });
        
        __block NSDictionary *dataDict = nil;
        context(@"when company name is configured ", ^{
            beforeEach(^{
                dataDict = @{
                    kNodeBackend: @0,
                    };
                
                [deferred resolveWithValue:dataDict];
                
                [subject appConfigForRequest:request];
            });
            
            it(@"should return expected value", ^{
                promise.value should equal(dataDict);
            });
            
            it(@"Should save Data Dict", ^{
                persistedSettingsStorage should have_received(@selector(storeAppConfigDictionary:)).with(dataDict);
            });
        });
        
        context(@"when company name is not  configured ", ^{
            beforeEach(^{
                dataDict = @{
                             kSource: @"no-data",
                             };
                
                [deferred resolveWithValue:dataDict];
                
                [subject appConfigForRequest:request];
            });
            
            it(@"should return expected value", ^{
                promise.value should equal(dataDict);
            });
            
            it(@"Should save nil value", ^{
                persistedSettingsStorage should have_received(@selector(storeAppConfigDictionary:)).with(dataDict);
            });
        });
    });
    
    describe(@"when the request fails", ^{
        beforeEach(^{
            reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
            promise =  [client promiseWithRequest:nil];
        });
        __block NSError *error;
        beforeEach(^{
            error = nice_fake_for([NSError class]);
            [deferred rejectWithError:error];
            [subject appConfigForRequest:request];
        });
        
        it(@"should return an error", ^{
            promise.rejected should be_truthy;
            promise.error should be_same_instance_as(error);
        });
    });
});

SPEC_END
