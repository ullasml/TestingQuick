#import <Cedar/Cedar.h>
#import "ClientRepository.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import <KSDeferred/KSDeferred.h>
#import "RequestPromiseClient.h"
#import "InjectorKeys.h"
#import "ClientRequestProvider.h"
#import "ClientStorage.h"
#import "ClientDeserializer.h"
#import "ClientType.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ClientRepositorySpec)

sharedExamplesFor(@"sharedContextForFetchFreshClients", ^(NSDictionary *sharedContext) {
    __block KSPromise *promise;
    __block NSURLRequest *request;
    __block KSDeferred *clientsDeferred;
    __block ClientRepository *subject;
    __block id <RequestPromiseClient> jsonClient;
    __block ClientRequestProvider *clientRequestProvider;
    __block ClientStorage *clientStorage;
    __block ClientDeserializer *clientDeserializer;

    beforeEach(^{
        clientDeserializer         = sharedContext[@"clientDeserializer"];
        clientStorage              = sharedContext[@"clientStorage"];
        clientRequestProvider      = sharedContext[@"clientRequestProvider"];
        jsonClient                 = sharedContext[@"jsonClient"];
        subject                    = sharedContext[@"subject"];

    });

    beforeEach(^{
        clientsDeferred = [[KSDeferred alloc]init];
        request = nice_fake_for([NSURLRequest class]);
        clientRequestProvider stub_method(@selector(requestForClientsForUserWithURI:searchText:page:)).with(@"User-Uri",nil,@1).and_return(request);
        jsonClient stub_method(@selector(promiseWithRequest:)).and_return(clientsDeferred.promise);
        clientStorage stub_method(@selector(getAllClients)).and_return(@[@1, @2, @3]);

        promise = [subject fetchFreshClients];

    });

    it(@"should send the correctly configured request to server", ^{
        clientRequestProvider should have_received(@selector(requestForClientsForUserWithURI:searchText:page:)).with(@"User-Uri",nil,@1);
        jsonClient should have_received(@selector(promiseWithRequest:)).with(request);
    });

    context(@"when the request is successful", ^{
        __block NSDictionary *responseDictionary;
        beforeEach(^{
            responseDictionary = nice_fake_for([NSDictionary class]);
            clientDeserializer stub_method(@selector(deserialize:)).and_return(@[@1, @2, @3]);
            [clientsDeferred resolveWithValue:responseDictionary];
        });

        it(@"should reset the page number", ^{
            clientStorage should have_received(@selector(resetPageNumber));
            clientStorage should have_received(@selector(resetPageNumberForFilteredSearch));
        });

        it(@"should delete all the cached data", ^{
            clientStorage should have_received(@selector(deleteAllClients));
        });

        it(@"should send the response dictionary to the client deserializer", ^{
            clientDeserializer should have_received(@selector(deserialize:)).with(responseDictionary);
        });
        it(@"should persist the client types in the client storage cache", ^{
            clientStorage should have_received(@selector(storeClients:)).with(@[@1, @2, @3]);
        });
        it(@"should persist the client types in the client storage cache", ^{
            clientStorage should have_received(@selector(updatePageNumber));
        });
        it(@"should resolve the promise with the deserialized objects", ^{
            promise.value should equal(@{@"clients":@[@1, @2, @3],@"downloadCount":@3});
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

describe(@"ClientRepository", ^{
    
    describe(@"ClientRepository without fake instances", ^{
        __block ClientRepository *subject;
        __block id <BSInjector,BSBinder> injector;
        __block id<UserSession> userSession;
        beforeEach(^{
            injector = [InjectorProvider injector];
            userSession = nice_fake_for(@protocol(UserSession));
            userSession stub_method(@selector(currentUserURI)).and_return(@"User-Uri");
            [injector bind:@protocol(UserSession) toInstance:userSession];

            subject = [injector getInstance:[ClientRepository class]];
        });
        context(@"initial clients fetch", ^{
            beforeEach(^{
                spy_on(subject.clientStorage);
                spy_on(subject.requestProvider);
                [subject setUpWithUserUri:@"User-Uri"];
                [subject fetchClientsMatchingText:@"client"];
            });
            
            it(@"request provider should have received requestForClientsForUserWithURI  with page count 1", ^{
                subject.requestProvider should have_received(@selector(requestForClientsForUserWithURI:searchText:page:)).with(@"User-Uri",@"client",@1);
            });
            
            afterEach(^{
                stop_spying_on(subject.clientStorage);
                stop_spying_on(subject.requestProvider);
            });
        });
        
        context(@"more fetch clients", ^{
            beforeEach(^{
                spy_on(subject.clientStorage);
                spy_on(subject.requestProvider);
                [subject setUpWithUserUri:@"User-Uri"];
                [subject.clientStorage.userDefaults setObject:[NSNumber numberWithInteger:1] forKey:@"LastDownloadedFilteredClientPageNumber"];
                [subject.clientStorage updatePageNumberForFilteredSearch];
                [subject fetchMoreClientsMatchingText:@"client"];
            });
            
            it(@"request provider should have received requestForClientsForUserWithURI  with page count 2", ^{
                subject.requestProvider should have_received(@selector(requestForClientsForUserWithURI:searchText:page:)).with(@"User-Uri",@"client",@2);
            });
            
            afterEach(^{
                stop_spying_on(subject.clientStorage);
                stop_spying_on(subject.requestProvider);
            });
            
        });
    });
    
    describe(@"ClientRepository with fake instances", ^{
        __block ClientRepository *subject;
        __block id <BSInjector,BSBinder> injector;
        __block id <RequestPromiseClient> client;
        __block ClientRequestProvider *clientRequestProvider;
        __block ClientStorage *clientStorage;
        __block id <UserSession> userSession;
        __block ClientDeserializer *clientDeserializer;
        
        
        beforeEach(^{
            injector = [InjectorProvider injector];
            clientDeserializer = nice_fake_for([ClientDeserializer class]);
            userSession = nice_fake_for(@protocol(UserSession));
            userSession stub_method(@selector(currentUserURI)).and_return(@"Some:User-Uri");
            client = nice_fake_for(@protocol(RequestPromiseClient));
            
            
            clientStorage = nice_fake_for([ClientStorage class]);
            clientRequestProvider = nice_fake_for([ClientRequestProvider class]);
            
            [injector bind:InjectorKeyRepliconClientForeground toInstance:client];
            [injector bind:[ClientRequestProvider class] toInstance:clientRequestProvider];
            [injector bind:[ClientStorage class] toInstance:clientStorage];
            [injector bind:@protocol(UserSession) toInstance:userSession];
            [injector bind:[ClientDeserializer class] toInstance:clientDeserializer];
            
            
            subject = [injector getInstance:[ClientRepository class]];
            
            [subject setUpWithUserUri:@"User-Uri"];
            
        });
        
        it(@"storage should have correctly set up the user uri", ^{
            clientStorage should have_received(@selector(setUpWithUserUri:)).and_with(@"User-Uri");
        });
        
        describe(@"fetchAllClients", ^{
            
            __block KSPromise *promise;
            __block NSArray *expectedClientsArray;
            context(@"When cached clients are present", ^{
                beforeEach(^{
                    ClientType *clientA = nice_fake_for([ClientType class]);
                    ClientType *clientB = nice_fake_for([ClientType class]);
                    ClientType *clientC = nice_fake_for([ClientType class]);
                    
                    expectedClientsArray = @[clientA,clientB,clientC];
                    clientStorage stub_method(@selector(getAllClients)).and_return(expectedClientsArray);
                    promise = [subject fetchAllClients];
                });
                
                it(@"should resolve the promise correctly", ^{
                    promise.value should equal(@{@"clients":expectedClientsArray,@"downloadCount":@3});
                });
            });
            
            context(@"When cached clients are absent", ^{
                
                beforeEach(^{
                    [subject fetchAllClients];
                });
                
                itShouldBehaveLike(@"sharedContextForFetchFreshClients",  ^(NSMutableDictionary *sharedContext) {
                    sharedContext[@"clientDeserializer"] = clientDeserializer;
                    sharedContext[@"clientStorage"] = clientStorage;
                    sharedContext[@"clientRequestProvider"] = clientRequestProvider;
                    sharedContext[@"jsonClient"] = client;
                    sharedContext[@"subject"] = subject;
                });
                
            });
        });
        
        describe(@"fetchCachedClientsMatchingText:", ^{
            
            __block KSPromise *promise;
            __block NSArray *expectedClientsArray;
            
            beforeEach(^{
                ClientType *clientA = nice_fake_for([ClientType class]);
                ClientType *clientB = nice_fake_for([ClientType class]);
                ClientType *clientC = nice_fake_for([ClientType class]);
                
                expectedClientsArray = @[clientA,clientB,clientC];
                clientStorage stub_method(@selector(getAllClients)).and_return(@[@"some-client"]);
                clientStorage stub_method(@selector(getClientsWithMatchingText:)).with(@"some-matching-text").and_return(expectedClientsArray);
                promise = [subject fetchCachedClientsMatchingText:@"some-matching-text"];
                
                
            });
            
            it(@"should resolve the promise correctly", ^{
                promise.value should equal(@{@"clients":expectedClientsArray,@"downloadCount":@1});
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
                    clientStorage stub_method(@selector(getLastPageNumber)).and_return(@3);
                    clientRequestProvider stub_method(@selector(requestForClientsForUserWithURI:searchText:page:)).with(@"User-Uri",nil,@3).and_return(request);
                    client stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                    promise = [subject fetchClientsMatchingText:nil];
                });
                
                it(@"client storage should have received resetSearchPage number", ^{
                    clientStorage should have_received(@selector(resetPageNumberForFilteredSearch));
                });
                
                it(@"should ask for the page number", ^{
                    clientStorage should have_received(@selector(getLastPageNumber));
                });
                
                it(@"should get the request from client request provider", ^{
                    clientRequestProvider should have_received(@selector(requestForClientsForUserWithURI:searchText:page:)).with(@"User-Uri",nil,@3);
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
                        ClientType *clientA = nice_fake_for([ClientType class]);
                        ClientType *clientB = nice_fake_for([ClientType class]);
                        ClientType *clientC = nice_fake_for([ClientType class]);
                        ClientType *clientD = nice_fake_for([ClientType class]);
                        ClientType *clientE = nice_fake_for([ClientType class]);
                        ClientType *clientF = nice_fake_for([ClientType class]);
                        
                        filteredClients = @[clientD,clientE,clientF];
                        
                        clientStorage stub_method(@selector(getClientsWithMatchingText:)).with(nil).and_return(filteredClients);
                        expectedClientsArray = @[clientA,clientB,clientC];
                        clientDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedClientsArray);
                        [deferred resolveWithValue:jsonDictionary];
                    });
                    
                    it(@"should ask the client deserializer to deserialize the clients", ^{
                        clientDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                    });
                    
                    it(@"should store the deserialized clients into the storage", ^{
                        clientStorage should have_received(@selector(storeClients:)).with(expectedClientsArray);
                    });
                    
                    it(@"should update the last stored page number", ^{
                        clientStorage should have_received(@selector(updatePageNumber));
                    });
                    
                    it(@"should ask the client storage to get clients with matching text", ^{
                        clientStorage should have_received(@selector(getClientsWithMatchingText:)).with(nil);
                    });
                    
                    it(@"should resolve the promise correctly", ^{
                        promise.value should equal(@{@"clients":filteredClients,@"downloadCount":@3});
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
                    clientStorage stub_method(@selector(getLastPageNumberForFilteredSearch)).and_return(@3);
                    clientRequestProvider stub_method(@selector(requestForClientsForUserWithURI:searchText:page:)).with(@"User-Uri",@"some-search-text",@3).and_return(request);
                    client stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                    promise = [subject fetchClientsMatchingText:@"some-search-text"];
                });
                
                it(@"should ask for the page number", ^{
                    clientStorage should have_received(@selector(getLastPageNumberForFilteredSearch));
                });
                
                it(@"should get the request from client request provider", ^{
                    clientRequestProvider should have_received(@selector(requestForClientsForUserWithURI:searchText:page:)).with(@"User-Uri",@"some-search-text",@3);
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
                        ClientType *clientA = nice_fake_for([ClientType class]);
                        ClientType *clientB = nice_fake_for([ClientType class]);
                        ClientType *clientC = nice_fake_for([ClientType class]);
                        ClientType *clientD = nice_fake_for([ClientType class]);
                        ClientType *clientE = nice_fake_for([ClientType class]);
                        ClientType *clientF = nice_fake_for([ClientType class]);
                        
                        filteredClients = @[clientD,clientE,clientF];
                        
                        clientStorage stub_method(@selector(getClientsWithMatchingText:)).with(@"some-search-text").and_return(filteredClients);
                        expectedClientsArray = @[clientA,clientB,clientC];
                        clientDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedClientsArray);
                        [deferred resolveWithValue:jsonDictionary];
                    });
                    
                    it(@"should ask the client deserializer to deserialize the clients", ^{
                        clientDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                    });
                    
                    it(@"should store the deserialized clients into the storage", ^{
                        clientStorage should have_received(@selector(storeClients:)).with(expectedClientsArray);
                    });
                    
                    it(@"should update the last stored page number", ^{
                        clientStorage should have_received(@selector(updatePageNumberForFilteredSearch));
                    });
                    
                    it(@"should ask the client storage to get clients with matching text", ^{
                        clientStorage should have_received(@selector(getClientsWithMatchingText:)).with(@"some-search-text");
                    });
                    
                    it(@"should resolve the promise correctly", ^{
                        promise.value should equal(@{@"clients":filteredClients,@"downloadCount":@3});
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
                    clientStorage stub_method(@selector(getLastPageNumber)).and_return(@3);
                    clientRequestProvider stub_method(@selector(requestForClientsForUserWithURI:searchText:page:)).with(@"User-Uri",nil,@3).and_return(request);
                    client stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                    promise = [subject fetchMoreClientsMatchingText:nil];
                });
                
                it(@"should ask for the page number", ^{
                    clientStorage should have_received(@selector(getLastPageNumber));
                });
                
                it(@"should get the request from client request provider", ^{
                    clientRequestProvider should have_received(@selector(requestForClientsForUserWithURI:searchText:page:)).with(@"User-Uri",nil,@3);
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
                        ClientType *clientA = nice_fake_for([ClientType class]);
                        ClientType *clientB = nice_fake_for([ClientType class]);
                        ClientType *clientC = nice_fake_for([ClientType class]);
                        ClientType *clientD = nice_fake_for([ClientType class]);
                        ClientType *clientE = nice_fake_for([ClientType class]);
                        ClientType *clientF = nice_fake_for([ClientType class]);
                        
                        filteredClients = @[clientD,clientE,clientF];
                        
                        clientStorage stub_method(@selector(getClientsWithMatchingText:)).with(nil).and_return(filteredClients);
                        expectedClientsArray = @[clientA,clientB,clientC];
                        clientDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedClientsArray);
                        
                        clientStorage stub_method(@selector(getAllClients)).and_return(expectedClientsArray);
                        [deferred resolveWithValue:jsonDictionary];
                    });
                    
                    it(@"should ask the client deserializer to deserialize the clients", ^{
                        clientDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                    });
                    
                    it(@"should store the deserialized clients into the storage", ^{
                        clientStorage should have_received(@selector(storeClients:)).with(expectedClientsArray);
                    });
                    
                    it(@"should update the last stored page number", ^{
                        clientStorage should have_received(@selector(updatePageNumber));
                    });
                    
                    it(@"should ask the client storage to get clients with matching text", ^{
                        clientStorage should have_received(@selector(getClientsWithMatchingText:)).with(nil);
                    });
                    
                    it(@"should resolve the promise correctly", ^{
                        promise.value should equal(@{@"clients":filteredClients,@"downloadCount":@3});
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
                    clientStorage stub_method(@selector(getLastPageNumberForFilteredSearch)).and_return(@3);
                    clientRequestProvider stub_method(@selector(requestForClientsForUserWithURI:searchText:page:)).with(@"User-Uri",@"some-search-text",@3).and_return(request);
                    client stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                    promise = [subject fetchMoreClientsMatchingText:@"some-search-text"];
                });
                
                it(@"should ask for the page number", ^{
                    clientStorage should have_received(@selector(getLastPageNumberForFilteredSearch));
                });
                
                it(@"should get the request from client request provider", ^{
                    clientRequestProvider should have_received(@selector(requestForClientsForUserWithURI:searchText:page:)).with(@"User-Uri",@"some-search-text",@3);
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
                        ClientType *clientA = nice_fake_for([ClientType class]);
                        ClientType *clientB = nice_fake_for([ClientType class]);
                        ClientType *clientC = nice_fake_for([ClientType class]);
                        ClientType *clientD = nice_fake_for([ClientType class]);
                        ClientType *clientE = nice_fake_for([ClientType class]);
                        ClientType *clientF = nice_fake_for([ClientType class]);
                        
                        filteredClients = @[clientD,clientE,clientF];
                        
                        clientStorage stub_method(@selector(getClientsWithMatchingText:)).with(@"some-search-text").and_return(filteredClients);
                        expectedClientsArray = @[clientA,clientB,clientC];
                        clientDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedClientsArray);
                        clientStorage stub_method(@selector(getAllClients)).and_return(expectedClientsArray);
                        [deferred resolveWithValue:jsonDictionary];
                    });
                    
                    it(@"should ask the client deserializer to deserialize the clients", ^{
                        clientDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                    });
                    
                    it(@"should store the deserialized clients into the storage", ^{
                        clientStorage should have_received(@selector(storeClients:)).with(expectedClientsArray);
                    });
                    
                    it(@"should update the last stored page number", ^{
                        clientStorage should have_received(@selector(updatePageNumberForFilteredSearch));
                    });
                    
                    it(@"should ask the client storage to get clients with matching text", ^{
                        clientStorage should have_received(@selector(getClientsWithMatchingText:)).with(@"some-search-text");
                    });
                    
                    it(@"should resolve the promise correctly", ^{
                        promise.value should equal(@{@"clients":filteredClients,@"downloadCount":@3});
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
});



SPEC_END
