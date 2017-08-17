
#import <Cedar/Cedar.h>
#import "ActivityRepository.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import <KSDeferred/KSDeferred.h>
#import "RequestPromiseClient.h"
#import "InjectorKeys.h"
#import "Activity.h"
#import "ActivityStorage.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ActivityRepositorySpec)

sharedExamplesFor(@"sharedContextForFetchFreshClients", ^(NSDictionary *sharedContext) {
    __block KSPromise *promise;
    __block NSURLRequest *request;
    __block KSDeferred *clientsDeferred;
    __block ActivityRepository *subject;
    __block id <RequestPromiseClient> jsonCient;
    __block ActivityRequestProvider *activityRequestProvider;
    __block ActivityStorage *activityStorage;
    __block id <UserSession> userSession;
    __block ActivityDeserializer *activityDeserializer;

    beforeEach(^{

        subject = sharedContext[@"subject"];
        jsonCient = sharedContext[@"jsonClient"];
        activityRequestProvider = sharedContext[@"activityRequestProvider"];
        activityStorage = sharedContext[@"activityStorage"];
        userSession = sharedContext[@"userSession"];
        activityDeserializer = sharedContext[@"activityDeserializer"];

    });

    beforeEach(^{
        clientsDeferred = [[KSDeferred alloc]init];
        request = nice_fake_for([NSURLRequest class]);
        activityRequestProvider stub_method(@selector(requestForActivitiesForUserWithURI:searchText:page:)).with(@"User-Uri",nil,@1).and_return(request);
        jsonCient stub_method(@selector(promiseWithRequest:)).and_return(clientsDeferred.promise);
        activityStorage stub_method(@selector(getAllActivities)).and_return(@[@1, @2, @3]);

        promise = [subject fetchFreshActivities];

    });

    it(@"should send the correctly configured request to server", ^{
        activityRequestProvider should have_received(@selector(requestForActivitiesForUserWithURI:searchText:page:)).with(@"User-Uri",nil,@1);
        jsonCient should have_received(@selector(promiseWithRequest:)).with(request);
    });

    context(@"when the request is successful", ^{
        __block NSDictionary *responseDictionary;
        beforeEach(^{
            responseDictionary = nice_fake_for([NSDictionary class]);
            activityDeserializer stub_method(@selector(deserialize:)).and_return(@[@1, @2, @3]);
            [clientsDeferred resolveWithValue:responseDictionary];
        });

        it(@"should reset the page number", ^{
            activityStorage should have_received(@selector(resetPageNumber));
            activityStorage should have_received(@selector(resetPageNumberForFilteredSearch));
        });

        it(@"should delete all the cached data", ^{
            activityStorage should have_received(@selector(deleteAllActivities));
        });

        it(@"should send the response dictionary to the client deserializer", ^{
            activityDeserializer should have_received(@selector(deserialize:)).with(responseDictionary);
        });
        it(@"should persist the client types in the client storage cache", ^{
            activityStorage should have_received(@selector(storeActivities:)).with(@[@1, @2, @3]);
        });
        it(@"should persist the client types in the client storage cache", ^{
            activityStorage should have_received(@selector(updatePageNumber));
        });
        it(@"should resolve the promise with the deserialized objects", ^{
            promise.value should equal(@{@"activities":@[@1, @2, @3],@"downloadCount":@3});
        });
    });


    context(@"when the request is failed", ^{
        __block NSError *error;
        beforeEach(^{
            error = nice_fake_for([NSError class]);
            [clientsDeferred rejectWithError:error];
        });

        it(@"should resolve the promise with the deserialized objects", ^{
            promise.error should equal(error);
        });
    });
});

describe(@"ActivityRepository", ^{
    __block ActivityRepository *subject;
    __block id <BSInjector,BSBinder> injector;
    __block id <RequestPromiseClient> client;
    __block ActivityRequestProvider *activityRequestProvider;
    __block ActivityStorage *activityStorage;
    __block id <UserSession> userSession;
    __block ActivityDeserializer *activityDeserializer;


    beforeEach(^{
        injector = [InjectorProvider injector];
        activityDeserializer = nice_fake_for([ActivityDeserializer class]);
        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"Some:User-Uri");

        client = nice_fake_for(@protocol(RequestPromiseClient));


        activityStorage = nice_fake_for([ActivityStorage class]);
        activityRequestProvider = nice_fake_for([ActivityRequestProvider class]);

        [injector bind:InjectorKeyRepliconClientForeground toInstance:client];
        [injector bind:[ActivityRequestProvider class] toInstance:activityRequestProvider];
        [injector bind:[ActivityStorage class] toInstance:activityStorage];
        [injector bind:@protocol(UserSession) toInstance:userSession];
        [injector bind:[ActivityDeserializer class] toInstance:activityDeserializer];


        subject = [injector getInstance:[ActivityRepository class]];

        [subject setUpWithUserUri:@"User-Uri"];

    });

    it(@"storage should have correctly set up the user uri", ^{
        activityStorage should have_received(@selector(setUpWithUserUri:)).and_with(@"User-Uri");
    });

    describe(@"fetchAllClients", ^{

        __block KSPromise *promise;
        __block NSArray *expectedClientsArray;
        context(@"When cached clients are present", ^{
            beforeEach(^{
                Activity *clientA = nice_fake_for([Activity class]);
                Activity *clientB = nice_fake_for([Activity class]);
                Activity *clientC = nice_fake_for([Activity class]);

                expectedClientsArray = @[clientA,clientB,clientC];
                activityStorage stub_method(@selector(getAllActivities)).and_return(expectedClientsArray);
                promise = [subject fetchAllActivities];
            });

            it(@"should resolve the promise correctly", ^{
                promise.value should equal(@{@"activities":expectedClientsArray,@"downloadCount":@3});
            });
        });

        context(@"When cached clients are absent", ^{

            beforeEach(^{
                [subject fetchAllActivities];
            });

            itShouldBehaveLike(@"sharedContextForFetchFreshClients",  ^(NSMutableDictionary *sharedContext) {
                sharedContext[@"activityRequestProvider"] = activityRequestProvider;
                sharedContext[@"activityStorage"] = activityStorage;
                sharedContext[@"activityDeserializer"] = activityDeserializer;
                sharedContext[@"userSession"] = userSession;
                sharedContext[@"jsonClient"] = client;
                sharedContext[@"subject"] = subject;

            });

        });
    });

    describe(@"fetchCachedClientsMatchingText:", ^{

        __block KSPromise *promise;
        __block NSArray *expectedClientsArray;

        beforeEach(^{
            Activity *clientA = nice_fake_for([Activity class]);
            Activity *clientB = nice_fake_for([Activity class]);
            Activity *clientC = nice_fake_for([Activity class]);

            expectedClientsArray = @[clientA,clientB,clientC];
            activityStorage stub_method(@selector(getAllActivities)).and_return(@[@"some-client"]);
            activityStorage stub_method(@selector(getActivitiesWithMatchingText:)).with(@"some-matching-text").and_return(expectedClientsArray);
            promise = [subject fetchCachedActivitiesMatchingText:@"some-matching-text"];


        });

        it(@"should resolve the promise correctly", ^{
            promise.value should equal(@{@"activities":expectedClientsArray,@"downloadCount":@1});
        });

    });


    describe(@"fetchClientsMatchingText:", ^{

        context(@"When searching client with empty text", ^{
            __block NSURLRequest *request;
            __block KSDeferred *deferred;
            __block KSPromise *promise;
            beforeEach(^{
                deferred = [[KSDeferred alloc]init];
                request = nice_fake_for([NSURLRequest class]);
                activityStorage stub_method(@selector(getLastPageNumber)).and_return(@3);
                activityRequestProvider stub_method(@selector(requestForActivitiesForUserWithURI:searchText:page:)).with(@"User-Uri",nil,@3).and_return(request);
                client stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                promise = [subject fetchActivitiesMatchingText:nil];
            });

            it(@"should ask for the page number", ^{
                activityStorage should have_received(@selector(getLastPageNumber));
            });

            it(@"should get the request from client request provider", ^{
                activityRequestProvider should have_received(@selector(requestForActivitiesForUserWithURI:searchText:page:)).with(@"User-Uri",nil,@3);
            });

            it(@"should send the request to server", ^{
                client should have_received(@selector(promiseWithRequest:)).with(request);
            });

            context(@"When request succeeds", ^{

                __block NSDictionary *jsonDictionary ;
                __block NSArray *expectedClientsArray;
                __block NSArray *filteredClients;
                beforeEach(^{
                    jsonDictionary = nice_fake_for([NSDictionary class]);
                    Activity *clientA = nice_fake_for([Activity class]);
                    Activity *clientB = nice_fake_for([Activity class]);
                    Activity *clientC = nice_fake_for([Activity class]);
                    Activity *clientD = nice_fake_for([Activity class]);
                    Activity *clientE = nice_fake_for([Activity class]);
                    Activity *clientF = nice_fake_for([Activity class]);

                    filteredClients = @[clientD,clientE,clientF];

                    activityStorage stub_method(@selector(getActivitiesWithMatchingText:)).with(nil).and_return(filteredClients);
                    expectedClientsArray = @[clientA,clientB,clientC];
                    activityDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedClientsArray);
                    [deferred resolveWithValue:jsonDictionary];
                });

                it(@"should ask the client deserializer to deserialize the clients", ^{
                    activityDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                });

                it(@"should store the deserialized clients into the storage", ^{
                    activityStorage should have_received(@selector(storeActivities:)).with(expectedClientsArray);
                });

                it(@"should update the last stored page number", ^{
                    activityStorage should have_received(@selector(updatePageNumber));
                });

                it(@"should ask the client storage to get clients with matching text", ^{
                    activityStorage should have_received(@selector(getActivitiesWithMatchingText:)).with(nil);
                });

                it(@"should resolve the promise correctly", ^{
                    promise.value should equal(@{@"activities":filteredClients,@"downloadCount":@3});
                });
            });

            context(@"When request fails", ^{

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

        context(@"When searching client with text", ^{
            __block NSURLRequest *request;
            __block KSDeferred *deferred;
            __block KSPromise *promise;
            beforeEach(^{
                deferred = [[KSDeferred alloc]init];
                request = nice_fake_for([NSURLRequest class]);
                activityStorage stub_method(@selector(getLastPageNumberForFilteredSearch)).and_return(@3);
                activityRequestProvider stub_method(@selector(requestForActivitiesForUserWithURI:searchText:page:)).with(@"User-Uri",@"some-search-text",@3).and_return(request);
                client stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                promise = [subject fetchActivitiesMatchingText:@"some-search-text"];
            });

            it(@"should ask for the page number", ^{
                activityStorage should have_received(@selector(getLastPageNumberForFilteredSearch));
            });

            it(@"should get the request from client request provider", ^{
                activityRequestProvider should have_received(@selector(requestForActivitiesForUserWithURI:searchText:page:)).with(@"User-Uri",@"some-search-text",@3);
            });

            it(@"should send the request to server", ^{
                client should have_received(@selector(promiseWithRequest:)).with(request);
            });

            context(@"When request succeeds", ^{

                __block NSDictionary *jsonDictionary ;
                __block NSArray *expectedClientsArray;
                __block NSArray *filteredClients;
                beforeEach(^{
                    jsonDictionary = nice_fake_for([NSDictionary class]);
                    Activity *clientA = nice_fake_for([Activity class]);
                    Activity *clientB = nice_fake_for([Activity class]);
                    Activity *clientC = nice_fake_for([Activity class]);
                    Activity *clientD = nice_fake_for([Activity class]);
                    Activity *clientE = nice_fake_for([Activity class]);
                    Activity *clientF = nice_fake_for([Activity class]);

                    filteredClients = @[clientD,clientE,clientF];

                    activityStorage stub_method(@selector(getActivitiesWithMatchingText:)).with(@"some-search-text").and_return(filteredClients);
                    expectedClientsArray = @[clientA,clientB,clientC];
                    activityDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedClientsArray);
                    [deferred resolveWithValue:jsonDictionary];
                });

                it(@"should ask the client deserializer to deserialize the clients", ^{
                    activityDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                });

                it(@"should store the deserialized clients into the storage", ^{
                    activityStorage should have_received(@selector(storeActivities:)).with(expectedClientsArray);
                });

                it(@"should update the last stored page number", ^{
                    activityStorage should have_received(@selector(updatePageNumberForFilteredSearch));
                });

                it(@"should ask the client storage to get clients with matching text", ^{
                    activityStorage should have_received(@selector(getActivitiesWithMatchingText:)).with(@"some-search-text");
                });

                it(@"should resolve the promise correctly", ^{
                    promise.value should equal(@{@"activities":filteredClients,@"downloadCount":@3});
                });
            });

            context(@"When request fails", ^{

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

    describe(@"fetchMoreClientsMatchingText:", ^{

        context(@"When searching more client with empty text", ^{
            __block NSURLRequest *request;
            __block KSDeferred *deferred;
            __block KSPromise *promise;
            beforeEach(^{
                deferred = [[KSDeferred alloc]init];
                request = nice_fake_for([NSURLRequest class]);
                activityStorage stub_method(@selector(getLastPageNumber)).and_return(@3);
                activityRequestProvider stub_method(@selector(requestForActivitiesForUserWithURI:searchText:page:)).with(@"User-Uri",nil,@3).and_return(request);
                client stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                promise = [subject fetchMoreActivitiesMatchingText:nil];
            });

            it(@"should ask for the page number", ^{
                activityStorage should have_received(@selector(getLastPageNumber));
            });

            it(@"should get the request from client request provider", ^{
                activityRequestProvider should have_received(@selector(requestForActivitiesForUserWithURI:searchText:page:)).with(@"User-Uri",nil,@3);
            });

            it(@"should send the request to server", ^{
                client should have_received(@selector(promiseWithRequest:)).with(request);
            });

            context(@"When request succeeds", ^{

                __block NSDictionary *jsonDictionary ;
                __block NSArray *expectedClientsArray;
                __block NSArray *filteredClients;
                beforeEach(^{
                    jsonDictionary = nice_fake_for([NSDictionary class]);
                    Activity *clientA = nice_fake_for([Activity class]);
                    Activity *clientB = nice_fake_for([Activity class]);
                    Activity *clientC = nice_fake_for([Activity class]);
                    Activity *clientD = nice_fake_for([Activity class]);
                    Activity *clientE = nice_fake_for([Activity class]);
                    Activity *clientF = nice_fake_for([Activity class]);

                    filteredClients = @[clientD,clientE,clientF];

                    activityStorage stub_method(@selector(getActivitiesWithMatchingText:)).with(nil).and_return(filteredClients);
                    expectedClientsArray = @[clientA,clientB,clientC];
                    activityDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedClientsArray);

                    activityStorage stub_method(@selector(getAllActivities)).and_return(expectedClientsArray);
                    [deferred resolveWithValue:jsonDictionary];
                });

                it(@"should ask the client deserializer to deserialize the clients", ^{
                    activityDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                });

                it(@"should store the deserialized clients into the storage", ^{
                    activityStorage should have_received(@selector(storeActivities:)).with(expectedClientsArray);
                });

                it(@"should update the last stored page number", ^{
                    activityStorage should have_received(@selector(updatePageNumber));
                });

                it(@"should ask the client storage to get clients with matching text", ^{
                    activityStorage should have_received(@selector(getActivitiesWithMatchingText:)).with(nil);
                });

                it(@"should resolve the promise correctly", ^{
                    promise.value should equal(@{@"activities":filteredClients,@"downloadCount":@3});
                });
            });

            context(@"When request fails", ^{

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

        context(@"When searching more client with text", ^{
            __block NSURLRequest *request;
            __block KSDeferred *deferred;
            __block KSPromise *promise;
            beforeEach(^{
                deferred = [[KSDeferred alloc]init];
                request = nice_fake_for([NSURLRequest class]);
                activityStorage stub_method(@selector(getLastPageNumberForFilteredSearch)).and_return(@3);
                activityRequestProvider stub_method(@selector(requestForActivitiesForUserWithURI:searchText:page:)).with(@"User-Uri",@"some-search-text",@3).and_return(request);
                client stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                promise = [subject fetchMoreActivitiesMatchingText:@"some-search-text"];
            });

            it(@"should ask for the page number", ^{
                activityStorage should have_received(@selector(getLastPageNumberForFilteredSearch));
            });

            it(@"should get the request from client request provider", ^{
                activityRequestProvider should have_received(@selector(requestForActivitiesForUserWithURI:searchText:page:)).with(@"User-Uri",@"some-search-text",@3);
            });

            it(@"should send the request to server", ^{
                client should have_received(@selector(promiseWithRequest:)).with(request);
            });

            context(@"When request succeeds", ^{

                __block NSDictionary *jsonDictionary ;
                __block NSArray *expectedClientsArray;
                __block NSArray *filteredClients;
                beforeEach(^{
                    jsonDictionary = nice_fake_for([NSDictionary class]);
                    Activity *clientA = nice_fake_for([Activity class]);
                    Activity *clientB = nice_fake_for([Activity class]);
                    Activity *clientC = nice_fake_for([Activity class]);
                    Activity *clientD = nice_fake_for([Activity class]);
                    Activity *clientE = nice_fake_for([Activity class]);
                    Activity *clientF = nice_fake_for([Activity class]);

                    filteredClients = @[clientD,clientE,clientF];

                    activityStorage stub_method(@selector(getActivitiesWithMatchingText:)).with(@"some-search-text").and_return(filteredClients);
                    expectedClientsArray = @[clientA,clientB,clientC];
                    activityDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedClientsArray);
                    activityStorage stub_method(@selector(getAllActivities)).and_return(expectedClientsArray);
                    [deferred resolveWithValue:jsonDictionary];
                });

                it(@"should ask the client deserializer to deserialize the clients", ^{
                    activityDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                });

                it(@"should store the deserialized clients into the storage", ^{
                    activityStorage should have_received(@selector(storeActivities:)).with(expectedClientsArray);
                });

                it(@"should update the last stored page number", ^{
                    activityStorage should have_received(@selector(updatePageNumberForFilteredSearch));
                });
                
                it(@"should ask the client storage to get clients with matching text", ^{
                    activityStorage should have_received(@selector(getActivitiesWithMatchingText:)).with(@"some-search-text");
                });
                
                it(@"should resolve the promise correctly", ^{
                    promise.value should equal(@{@"activities":filteredClients,@"downloadCount":@3});
                });
            });
            
            context(@"When request fails", ^{
                
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

