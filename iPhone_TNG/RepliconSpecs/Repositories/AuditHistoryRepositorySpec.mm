#import <Cedar/Cedar.h>
#import "AuditHistoryRepository.h"
#import "InjectorKeys.h"
#import "InjectorProvider.h"
#import <Blindside/BSBinder.h>
#import <Blindside/BSInjector.h>
#import "InjectorKeys.h"
#import "RequestPromiseClient.h"
#import "RequestDictionaryBuilder.h"
#import "AuditHistoryStorage.h"
#import "AuditHistoryDeserializer.h"
#import <KSDeferred/KSDeferred.h>



using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(AuditHistoryRepositorySpec)

describe(@"AuditHistoryRepository", ^{
    __block AuditHistoryRepository *subject;
    __block NSUserDefaults *userDefaults;
    __block AuditHistoryDeserializer *auditHistoryDeserializer;
    __block AuditHistoryStorage *auditHistoryStorage;
    __block id<RequestPromiseClient> client;
    __block id<BSBinder, BSInjector> injector;
    __block NSURLRequest *request;
    __block KSDeferred *deferred;



    beforeEach(^{
        injector = [InjectorProvider injector];
        deferred = [[KSDeferred alloc]init];
        client = nice_fake_for(@protocol(RequestPromiseClient));
        [injector bind:InjectorKeyRepliconClientForeground toInstance:client];
        
        auditHistoryStorage = nice_fake_for([AuditHistoryStorage class]);
        userDefaults = nice_fake_for([NSUserDefaults class]);
        auditHistoryDeserializer = nice_fake_for([AuditHistoryDeserializer class]);

        [injector bind:InjectorKeyStandardUserDefaults toInstance:userDefaults];
        [injector bind:[AuditHistoryDeserializer class] toInstance:auditHistoryDeserializer];
        [injector bind:[AuditHistoryStorage class] toInstance:auditHistoryStorage];
        
        userDefaults stub_method(@selector(objectForKey:))
        .with(@"serviceEndpointRootUrl")
        .and_return(@"https://na2.replicon.com/repliconmobile/services/");
        
        client stub_method(@selector(promiseWithRequest:))
        .and_do_block(^KSPromise *(NSURLRequest *receivedRequest){
            request = receivedRequest;
            return deferred.promise;
        });

    });
    
    context(@"when there are no punch logs", ^{
        __block NSDictionary *requestDictionary;
        __block KSPromise *recievedPromise;
        beforeEach(^{
            requestDictionary = [[NSDictionary alloc]init];
            auditHistoryStorage stub_method(@selector(getPunchLogs:)).and_return(nil);
            subject = [injector getInstance:[AuditHistoryRepository class]];
            auditHistoryDeserializer stub_method(@selector(deserialize:)).with(@[@"some-array-value-a",@"some-array-value-b"]).and_return(@[@"some-punchlog-a"]);
            recievedPromise = [subject fetchPunchLogs:@[@"uri-a",@"uri-b"]];
        });
        
        it(@"should configure the outgoing request url correctly", ^{
            request.URL.absoluteString should equal(@"https://na2.replicon.com/repliconmobile/services/timepunch/audit");
        });
        
        it(@"should configure the outgoing request http method correctly", ^{
            request.HTTPMethod should equal(@"POST");
        });
        
        it(@"should configure the outgoing request http body correctly", ^{
            NSDictionary *bodyDictionary = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                                           options:0
                                                                             error:nil];
            bodyDictionary should equal(@{@"timePunchUris": @[@"uri-a",@"uri-b"],
                                          @"limit": [NSNull null]
                                          });
        });
        
        context(@"when the request succeeds", ^{
            beforeEach(^{
                [deferred resolveWithValue:@[@"some-array-value-a",@"some-array-value-b"]];
            });
            
            it(@"should request auditHistoryDeserializer to deserialize and return the punch logs", ^{
                auditHistoryDeserializer should have_received(@selector(deserialize:)).with(@[@"some-array-value-a",@"some-array-value-b"]);
            });
            
            it(@"should request the auditHistoryStorage to store the punch logs", ^{
                auditHistoryStorage should have_received(@selector(storePunchLogs:)).with(@[@"some-array-value-a",@"some-array-value-b"]);
            });
            
            it(@"should resolve the promise with an correct value", ^{
                recievedPromise.value should equal(@[@"some-punchlog-a"]);
            });
        });
        
        context(@"when the request fails", ^{
            __block NSError *error;
            beforeEach(^{
                error = nice_fake_for([NSError class]);
                [deferred rejectWithError:error];
            });
            
            it(@"should reject the promise with an correct error", ^{
                recievedPromise.error should equal(error);
            });
        });

    });
    
    context(@"when there are punch logs, but there is no editing of a punch", ^{
        __block KSPromise *recievedPromise;
        beforeEach(^{
            auditHistoryStorage stub_method(@selector(getPunchLogs:)).with(@[@"uri-a",@"uri-a",@"uri-a"]).and_return(@[@"some-punchlog-a",@"some-punchlog-a",@"some-punchlog-a"]);
            subject = [injector getInstance:[AuditHistoryRepository class]];
            recievedPromise = [subject fetchPunchLogs:@[@"uri-a",@"uri-a",@"uri-a"]];
        });
        
        it(@"should resolve the promise with an correct value", ^{
            recievedPromise.value should equal(@[@"some-punchlog-a",@"some-punchlog-a",@"some-punchlog-a"]);
        });

    });
    
    context(@"when there are punch logs, but there is editing of a punch", ^{
        __block NSDictionary *requestDictionary;
        __block KSPromise *recievedPromise;
        beforeEach(^{
            requestDictionary = [[NSDictionary alloc]init];
            auditHistoryStorage stub_method(@selector(getPunchLogs:)).and_return(@[@"some-punchlog-a"]);
            subject = [injector getInstance:[AuditHistoryRepository class]];
            auditHistoryDeserializer stub_method(@selector(deserialize:)).with(@[@"some-array-value-a",@"some-array-value-b"]).and_return(@[@"some-punchlog-a"]);
            recievedPromise = [subject fetchPunchLogs:@[@"uri-a",@"uri-b"]];
        });
        
        it(@"should configure the outgoing request url correctly", ^{
            request.URL.absoluteString should equal(@"https://na2.replicon.com/repliconmobile/services/timepunch/audit");
        });
        
        it(@"should configure the outgoing request http method correctly", ^{
            request.HTTPMethod should equal(@"POST");
        });
        
        it(@"should configure the outgoing request http body correctly", ^{
            NSDictionary *bodyDictionary = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                                           options:0
                                                                             error:nil];
            bodyDictionary should equal(@{@"timePunchUris": @[@"uri-a",@"uri-b"],
                                          @"limit": [NSNull null]
                                          });
        });
        
        context(@"when the request succeeds", ^{
            beforeEach(^{
                [deferred resolveWithValue:@[@"some-array-value-a",@"some-array-value-b"]];
            });
            
            it(@"should request auditHistoryDeserializer to deserialize and return the punch logs", ^{
                auditHistoryDeserializer should have_received(@selector(deserialize:)).with(@[@"some-array-value-a",@"some-array-value-b"]);
            });
            
            it(@"should request the auditHistoryStorage to store the punch logs", ^{
                auditHistoryStorage should have_received(@selector(storePunchLogs:)).with(@[@"some-array-value-a",@"some-array-value-b"]);
            });
            
            it(@"should resolve the promise with an correct value", ^{
                recievedPromise.value should equal(@[@"some-punchlog-a"]);
            });
        });
        
        context(@"when the request fails", ^{
            __block NSError *error;
            beforeEach(^{
                error = nice_fake_for([NSError class]);
                [deferred rejectWithError:error];
            });
            
            it(@"should reject the promise with an correct error", ^{
                recievedPromise.error should equal(error);
            });
        });

    });
});

SPEC_END
