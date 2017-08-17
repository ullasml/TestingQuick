#import <MacTypes.h>
#import <Cedar/Cedar.h>
#import "BreakTypeRepository.h"
#import "JSONClient.h"
#import "BreakTypeDeserializer.h"
#import <KSDeferred/KSDeferred.h>
#import "RepliconSpecHelper.h"
#import "BreakTypeStorage.h"
#import <repliconkit/ReachabilityMonitor.h>


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(BreakTypeRepositorySpec)

describe(@"BreakTypeRepository", ^{
    __block JSONClient *jsonClient;
    __block NSUserDefaults *userDefaults;
    __block BreakTypeDeserializer *breakTypeDeserializer;
    __block KSDeferred *deferred;
    __block NSURLRequest *request;
    __block BreakTypeRepository *subject;
    __block BreakTypeStorage *breakTypeStorage;
    __block ReachabilityMonitor *reachabilityMonitor;


    beforeEach(^{
        deferred = [[KSDeferred alloc] init];
        jsonClient = nice_fake_for([JSONClient class]);
        jsonClient stub_method(@selector(promiseWithRequest:))
        .and_do_block(^KSPromise *(NSURLRequest *receivedRequest){
            request = receivedRequest;
            return deferred.promise;
        });

        breakTypeStorage = nice_fake_for([BreakTypeStorage class]);
        userDefaults = nice_fake_for([NSUserDefaults class]);
        breakTypeDeserializer = nice_fake_for([BreakTypeDeserializer class]);

        userDefaults stub_method(@selector(objectForKey:))
            .with(@"UserUri")
            .and_return(@"some:user:uri");
        userDefaults stub_method(@selector(objectForKey:))
            .with(@"serviceEndpointRootUrl")
            .and_return(@"https://na2.replicon.com/repliconmobile/services/");

        reachabilityMonitor = nice_fake_for([ReachabilityMonitor class]);

        subject = [[BreakTypeRepository alloc] initWithJSONClientBreakTypeDeserializer:breakTypeDeserializer
                                                                      breakTypeStorage:breakTypeStorage
                                                                   reachabilityMonitor:reachabilityMonitor
                                                                          userDefaults:userDefaults
                                                                            jsonClient:jsonClient];
    });

    describe(@"fetching break types", ^{
        context(@"When the network is reachable", ^{
            __block KSPromise *promise;
            beforeEach(^{
                reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(YES);
                promise = [subject fetchBreakTypesForUser:@"some-user:uri"];
            });

            it(@"should send a request to the json client", ^{
                jsonClient should have_received(@selector(promiseWithRequest:));
            });

            it(@"should configure the outgoing request url correctly", ^{
                request.URL.absoluteString should equal(@"https://na2.replicon.com/repliconmobile/services/TimePunchService1.svc/GetPageOfBreakTypesAvailableForUserFilteredByTextSearch");
            });

            it(@"should configure the outgoing request http method correctly", ^{
                request.HTTPMethod should equal(@"POST");
            });

            it(@"should configure the outgoing request http body correctly", ^{
                NSDictionary *bodyDictionary = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                                               options:0
                                                                                 error:nil];
                bodyDictionary should equal(@{@"page": @"1",
                                              @"pageSize": @"100",
                                              @"userUri": @"some-user:uri",
                                              @"textSearch": [NSNull null]
                                              });
            });

            context(@"when the request is successful", ^{
                __block NSDictionary *responseDictionary;
                beforeEach(^{
                    responseDictionary = nice_fake_for([NSDictionary class]);
                    breakTypeDeserializer stub_method(@selector(deserialize:)).and_return(@[@1, @2, @3]);
                    [deferred resolveWithValue:responseDictionary];
                });

                it(@"should send the response dictionary to the break deserializer", ^{
                    breakTypeDeserializer should have_received(@selector(deserialize:)).with(responseDictionary);
                });
                it(@"should persist the break types in the break storage cache", ^{
                    breakTypeStorage should have_received(@selector(storeBreakTypes:forUser:)).with(@[@1, @2, @3],@"some-user:uri");
                });

                it(@"should resolve the promise with the deserialized objects", ^{
                    promise.value should equal(@[@1, @2, @3]);
                });
            });

            context(@"when the request is failed", ^{
                __block NSError *error;
                beforeEach(^{
                    error = nice_fake_for([NSError class]);
                    [deferred rejectWithError:error];
                });

                it(@"should resolve the promise with the deserialized objects", ^{
                    promise.error should equal(error);
                });
            });

        });
        context(@"When the network is not reachable", ^{

            beforeEach(^{
                reachabilityMonitor stub_method(@selector(isNetworkReachable)).and_return(NO);
            });
            context(@"When there is Break types list in the cache", ^{

                beforeEach(^{
                    breakTypeStorage stub_method(@selector(allBreakTypesForUser:)).with(@"some-user:uri").and_return(@[@1, @2]);
                    [subject fetchBreakTypesForUser:@"some-user:uri"];
                });
                it(@"should not sent the request to fetch the Break type list", ^{
                    jsonClient should_not have_received(@selector(promiseWithRequest:));
                });

            });
            context(@"When there is No Break types list in the cache", ^{
                __block KSPromise *promise;
                beforeEach(^{
                    breakTypeStorage stub_method(@selector(allBreakTypesForUser:)).with(@"some-user:uri").and_return(nil);
                    promise = [subject fetchBreakTypesForUser:@"some-user:uri"];
                });

                it(@"should send a request to the json client", ^{
                    jsonClient should have_received(@selector(promiseWithRequest:));
                });

                it(@"should configure the outgoing request url correctly", ^{
                    request.URL.absoluteString should equal(@"https://na2.replicon.com/repliconmobile/services/TimePunchService1.svc/GetPageOfBreakTypesAvailableForUserFilteredByTextSearch");
                });

                it(@"should configure the outgoing request http method correctly", ^{
                    request.HTTPMethod should equal(@"POST");
                });

                it(@"should configure the outgoing request http body correctly", ^{
                    NSDictionary *bodyDictionary = [NSJSONSerialization JSONObjectWithData:request.HTTPBody
                                                                                   options:0
                                                                                     error:nil];
                    bodyDictionary should equal(@{@"page": @"1",
                                                  @"pageSize": @"100",
                                                  @"userUri": @"some-user:uri",
                                                  @"textSearch": [NSNull null]
                                                  });
                });

                context(@"when the request is successful", ^{
                    __block NSDictionary *responseDictionary;
                    beforeEach(^{
                        responseDictionary = nice_fake_for([NSDictionary class]);
                        breakTypeDeserializer stub_method(@selector(deserialize:)).and_return(@[@1, @2, @3]);
                        [deferred resolveWithValue:responseDictionary];
                    });

                    it(@"should send the response dictionary to the break deserializer", ^{
                        breakTypeDeserializer should have_received(@selector(deserialize:)).with(responseDictionary);
                    });
                    it(@"should persist the break types in the break storage cache", ^{
                        breakTypeStorage should have_received(@selector(storeBreakTypes:forUser:)).with(@[@1, @2, @3],@"some-user:uri");
                    });
                    
                    it(@"should resolve the promise with the deserialized objects", ^{
                        promise.value should equal(@[@1, @2, @3]);
                    });
                });


                context(@"when the request is failed", ^{
                    __block NSError *error;
                    beforeEach(^{
                        error = nice_fake_for([NSError class]);
                        [deferred rejectWithError:error];
                    });

                    it(@"should resolve the promise with the deserialized objects", ^{
                        promise.error should equal(error);
                    });
                });
                

            });
        });
    });
});

SPEC_END
