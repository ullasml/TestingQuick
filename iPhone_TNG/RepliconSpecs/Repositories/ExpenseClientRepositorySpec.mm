#import <Cedar/Cedar.h>
#import "ExpenseClientRepository.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import <KSDeferred/KSDeferred.h>
#import "RequestPromiseClient.h"
#import "InjectorKeys.h"
#import "ExpenseClientRequestProvider.h"
#import "ExpenseClientStorage.h"
#import "ExpenseClientDeserializer.h"
#import "ClientType.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;



SPEC_BEGIN(ExpenseClientRepositorySpec)

sharedExamplesFor(@"sharedContextForExpenseFetchFreshClients", ^(NSDictionary *sharedContext) {

    __block KSPromise *promise;
    __block NSURLRequest *request;
    __block KSDeferred *clientsDeferred;
    __block ExpenseClientRepository *subject;
    __block id <RequestPromiseClient> jsonClient;
    __block ExpenseClientRequestProvider *expenseClientRequestProvider;
    __block ExpenseClientStorage *expenseClientStorage;
    __block ExpenseClientDeserializer *expenseClientDeserializer;

    beforeEach(^{
        expenseClientDeserializer         = sharedContext[@"expenseClientDeserializer"];
        expenseClientStorage              = sharedContext[@"expenseClientStorage"];
        expenseClientRequestProvider      = sharedContext[@"expenseClientRequestProvider"];
        jsonClient                        = sharedContext[@"jsonClient"];
        subject                           = sharedContext[@"subject"];

    });

    beforeEach(^{
        clientsDeferred = [[KSDeferred alloc]init];
        request = nice_fake_for([NSURLRequest class]);
        expenseClientRequestProvider stub_method(@selector(requestForClientsForExpenseSheetURI:searchText:page:)).with(@"Expense-Uri",nil,@1).and_return(request);
        jsonClient stub_method(@selector(promiseWithRequest:)).and_return(clientsDeferred.promise);
        expenseClientStorage stub_method(@selector(getAllClients)).and_return(@[@1, @2, @3]);

        promise = [subject fetchFreshClients];

    });

    it(@"should send the correctly configured request to server", ^{
        expenseClientRequestProvider should have_received(@selector(requestForClientsForExpenseSheetURI:searchText:page:)).with(@"Expense-Uri",nil,@1);
        jsonClient should have_received(@selector(promiseWithRequest:)).with(request);
    });

    context(@"when the request is successful", ^{
        __block NSDictionary *responseDictionary;
        beforeEach(^{
            responseDictionary = nice_fake_for([NSDictionary class]);
            expenseClientDeserializer stub_method(@selector(deserialize:)).and_return(@[@1, @2, @3]);
            [clientsDeferred resolveWithValue:responseDictionary];
        });

        it(@"should reset the page number", ^{
            expenseClientStorage should have_received(@selector(resetPageNumber));
            expenseClientStorage should have_received(@selector(resetPageNumberForFilteredSearch));
        });

        it(@"should delete all the cached data", ^{
            expenseClientStorage should have_received(@selector(deleteAllClients));
        });

        it(@"should send the response dictionary to the client deserializer", ^{
            expenseClientDeserializer should have_received(@selector(deserialize:)).with(responseDictionary);
        });
        it(@"should persist the client types in the client storage cache", ^{
            expenseClientStorage should have_received(@selector(storeClients:)).with(@[@1, @2, @3]);
        });
        it(@"should persist the client types in the client storage cache", ^{
            expenseClientStorage should have_received(@selector(updatePageNumber));
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

describe(@"ExpenseClientRepository", ^{
    
    describe(@"ExpenseClientRepository without fake instances", ^{
        __block ExpenseClientRepository *subject;
        __block id <BSInjector,BSBinder> injector;
        beforeEach(^{
            injector = [InjectorProvider injector];
            subject = [injector getInstance:[ExpenseClientRepository class]];
        });
        context(@"initial clients fetch", ^{
            beforeEach(^{
                spy_on(subject.clientStorage);
                spy_on(subject.requestProvider);
                [subject setUpWithExpenseSheetUri:@"Expense-Uri"];
                [subject fetchClientsMatchingText:@"aa"];
            });
            
            it(@"request provider should have received requestForClientsForUserWithURI with page count 1", ^{
                subject.requestProvider should have_received(@selector(requestForClientsForExpenseSheetURI:searchText:page:)).with(@"Expense-Uri",@"aa",@1);
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
                [subject setUpWithExpenseSheetUri:@"Expense-Uri"];
                [subject.clientStorage.userDefaults setObject:[NSNumber numberWithInteger:1] forKey:@"LastDownloadedFilteredExpenseClientPageNumber"];
                [subject.clientStorage updatePageNumberForFilteredSearch];
                [subject fetchMoreClientsMatchingText:@"aa"];
            });
            
            it(@"request provider should have received requestForClientsForUserWithURI  with page count 2", ^{
                subject.requestProvider should have_received(@selector(requestForClientsForExpenseSheetURI:searchText:page:)).with(@"Expense-Uri",@"aa",@2);
            });
            
            afterEach(^{
                stop_spying_on(subject.clientStorage);
                stop_spying_on(subject.requestProvider);
            });
            
        });
        
        
        
    });
    
    
    describe(@"ExpenseClientRepository with fake instances", ^{
        
        
        __block ExpenseClientRepository *subject;
        
        __block id <BSInjector,BSBinder> injector;
        __block id <RequestPromiseClient> jsonClient;
        __block ExpenseClientRequestProvider *expenseClientRequestProvider;
        __block ExpenseClientStorage *expenseClientStorage;
        __block id <UserSession> userSession;
        __block ExpenseClientDeserializer *expenseClientDeserializer;
        
        
        beforeEach(^{
            injector = [InjectorProvider injector];
            expenseClientDeserializer = nice_fake_for([ExpenseClientDeserializer class]);
            userSession = nice_fake_for(@protocol(UserSession));
            userSession stub_method(@selector(currentUserURI)).and_return(@"User-Uri");
            jsonClient = nice_fake_for(@protocol(RequestPromiseClient));
            
            
            expenseClientStorage = nice_fake_for([ExpenseClientStorage class]);
            expenseClientRequestProvider = nice_fake_for([ExpenseClientRequestProvider class]);
            
            [injector bind:InjectorKeyRepliconClientForeground toInstance:jsonClient];
            [injector bind:[ExpenseClientRequestProvider class] toInstance:expenseClientRequestProvider];
            [injector bind:[ExpenseClientStorage class] toInstance:expenseClientStorage];
            [injector bind:@protocol(UserSession) toInstance:userSession];
            [injector bind:[ExpenseClientDeserializer class] toInstance:expenseClientDeserializer];
            
            
            subject = [injector getInstance:[ExpenseClientRepository class]];
            [subject setUpWithExpenseSheetUri:@"Expense-Uri"];
            
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
                    expenseClientStorage stub_method(@selector(getAllClients)).and_return(expectedClientsArray);
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
                
                itShouldBehaveLike(@"sharedContextForExpenseFetchFreshClients",  ^(NSMutableDictionary *sharedContext) {
                    sharedContext[@"expenseClientDeserializer"] = expenseClientDeserializer;
                    sharedContext[@"expenseClientStorage"] = expenseClientStorage;
                    sharedContext[@"expenseClientRequestProvider"] = expenseClientRequestProvider;
                    sharedContext[@"jsonClient"] = jsonClient;
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
                ClientType *noneClient = nice_fake_for([ClientType class]);
                
                expectedClientsArray = @[noneClient,clientA,clientB,clientC];
                expenseClientStorage stub_method(@selector(getAllClients)).and_return(@[noneClient,@"some-client"]);
                expenseClientStorage stub_method(@selector(getClientsWithMatchingText:)).with(@"some-matching-text").and_return(expectedClientsArray);
                promise = [subject fetchCachedClientsMatchingText:@"some-matching-text"];
                
                
            });
            
            it(@"should resolve the promise correctly", ^{
                promise.value should equal(@{@"clients":expectedClientsArray,@"downloadCount":@2});
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
                    expenseClientStorage stub_method(@selector(getLastPageNumber)).and_return(@3);
                    expenseClientRequestProvider stub_method(@selector(requestForClientsForExpenseSheetURI:searchText:page:)).with(@"Expense-Uri",nil,@3).and_return(request);
                    jsonClient stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                    promise = [subject fetchClientsMatchingText:nil];
                });
                
                it(@"should ask for the page number", ^{
                    expenseClientStorage should have_received(@selector(getLastPageNumber));
                });
                
                it(@"should get the request from client request provider", ^{
                    expenseClientRequestProvider should have_received(@selector(requestForClientsForExpenseSheetURI:searchText:page:)).with(@"Expense-Uri",nil,@3);
                });
                
                it(@"should send the request to server", ^{
                    jsonClient should have_received(@selector(promiseWithRequest:)).with(request);
                });
                
                it(@"expense client storage should have received resetPageNumberForFilteredSearch", ^{
                    expenseClientStorage should have_received(@selector(resetPageNumberForFilteredSearch));
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
                        
                        expenseClientStorage stub_method(@selector(getClientsWithMatchingText:)).with(nil).and_return(filteredClients);
                        expectedClientsArray = @[clientA,clientB,clientC];
                        expenseClientDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedClientsArray);
                        [deferred resolveWithValue:jsonDictionary];
                    });
                    
                    it(@"should ask the client deserializer to deserialize the clients", ^{
                        expenseClientDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                    });
                    
                    it(@"should store the deserialized clients into the storage", ^{
                        expenseClientStorage should have_received(@selector(storeClients:)).with(expectedClientsArray);
                    });
                    
                    it(@"should update the last stored page number", ^{
                        expenseClientStorage should have_received(@selector(updatePageNumber));
                    });
                    
                    it(@"should ask the client storage to get clients with matching text", ^{
                        expenseClientStorage should have_received(@selector(getClientsWithMatchingText:)).with(nil);
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
                    expenseClientStorage stub_method(@selector(getLastPageNumberForFilteredSearch)).and_return(@3);
                    expenseClientRequestProvider stub_method(@selector(requestForClientsForExpenseSheetURI:searchText:page:)).with(@"Expense-Uri",@"some-search-text",@3).and_return(request);
                    jsonClient stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                    promise = [subject fetchClientsMatchingText:@"some-search-text"];
                });
                
                it(@"should ask for the page number", ^{
                    expenseClientStorage should have_received(@selector(getLastPageNumberForFilteredSearch));
                });
                
                it(@"should get the request from client request provider", ^{
                    expenseClientRequestProvider should have_received(@selector(requestForClientsForExpenseSheetURI:searchText:page:)).with(@"Expense-Uri",@"some-search-text",@3);
                });
                
                it(@"should send the request to server", ^{
                    jsonClient should have_received(@selector(promiseWithRequest:)).with(request);
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
                        
                        expenseClientStorage stub_method(@selector(getClientsWithMatchingText:)).with(@"some-search-text").and_return(filteredClients);
                        expectedClientsArray = @[clientA,clientB,clientC];
                        expenseClientDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedClientsArray);
                        [deferred resolveWithValue:jsonDictionary];
                    });
                    
                    it(@"should ask the client deserializer to deserialize the clients", ^{
                        expenseClientDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                    });
                    
                    it(@"should store the deserialized clients into the storage", ^{
                        expenseClientStorage should have_received(@selector(storeClients:)).with(expectedClientsArray);
                    });
                    
                    it(@"should update the last stored page number", ^{
                        expenseClientStorage should have_received(@selector(updatePageNumberForFilteredSearch));
                    });
                    
                    it(@"should ask the client storage to get clients with matching text", ^{
                        expenseClientStorage should have_received(@selector(getClientsWithMatchingText:)).with(@"some-search-text");
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
                    expenseClientStorage stub_method(@selector(getLastPageNumber)).and_return(@3);
                    expenseClientRequestProvider stub_method(@selector(requestForClientsForExpenseSheetURI:searchText:page:)).with(@"Expense-Uri",nil,@3).and_return(request);
                    jsonClient stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                    promise = [subject fetchMoreClientsMatchingText:nil];
                });
                
                it(@"should ask for the page number", ^{
                    expenseClientStorage should have_received(@selector(getLastPageNumber));
                });
                
                it(@"should get the request from client request provider", ^{
                    expenseClientRequestProvider should have_received(@selector(requestForClientsForExpenseSheetURI:searchText:page:)).with(@"Expense-Uri",nil,@3);
                });
                
                it(@"should send the request to server", ^{
                    jsonClient should have_received(@selector(promiseWithRequest:)).with(request);
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
                        
                        expenseClientStorage stub_method(@selector(getClientsWithMatchingText:)).with(nil).and_return(filteredClients);
                        expectedClientsArray = @[clientA,clientB,clientC];
                        expenseClientDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedClientsArray);
                        
                        expenseClientStorage stub_method(@selector(getAllClients)).and_return(expectedClientsArray);
                        [deferred resolveWithValue:jsonDictionary];
                    });
                    
                    it(@"should ask the client deserializer to deserialize the clients", ^{
                        expenseClientDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                    });
                    
                    it(@"should store the deserialized clients into the storage", ^{
                        expenseClientStorage should have_received(@selector(storeClients:)).with(expectedClientsArray);
                    });
                    
                    it(@"should update the last stored page number", ^{
                        expenseClientStorage should have_received(@selector(updatePageNumber));
                    });
                    
                    it(@"should ask the client storage to get clients with matching text", ^{
                        expenseClientStorage should have_received(@selector(getClientsWithMatchingText:)).with(nil);
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
                    expenseClientStorage stub_method(@selector(getLastPageNumberForFilteredSearch)).and_return(@3);
                    expenseClientRequestProvider stub_method(@selector(requestForClientsForExpenseSheetURI:searchText:page:)).with(@"Expense-Uri",@"some-search-text",@3).and_return(request);
                    jsonClient stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                    promise = [subject fetchMoreClientsMatchingText:@"some-search-text"];
                });
                
                it(@"should ask for the page number", ^{
                    expenseClientStorage should have_received(@selector(getLastPageNumberForFilteredSearch));
                });
                
                it(@"should get the request from client request provider", ^{
                    expenseClientRequestProvider should have_received(@selector(requestForClientsForExpenseSheetURI:searchText:page:)).with(@"Expense-Uri",@"some-search-text",@3);
                });
                
                it(@"should send the request to server", ^{
                    jsonClient should have_received(@selector(promiseWithRequest:)).with(request);
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
                        
                        expenseClientStorage stub_method(@selector(getClientsWithMatchingText:)).with(@"some-search-text").and_return(filteredClients);
                        expectedClientsArray = @[clientA,clientB,clientC];
                        expenseClientDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedClientsArray);
                        expenseClientStorage stub_method(@selector(getAllClients)).and_return(expectedClientsArray);
                        [deferred resolveWithValue:jsonDictionary];
                    });
                    
                    it(@"should ask the client deserializer to deserialize the clients", ^{
                        expenseClientDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                    });
                    
                    it(@"should store the deserialized clients into the storage", ^{
                        expenseClientStorage should have_received(@selector(storeClients:)).with(expectedClientsArray);
                    });
                    
                    it(@"should update the last stored page number", ^{
                        expenseClientStorage should have_received(@selector(updatePageNumberForFilteredSearch));
                    });
                    
                    it(@"should ask the client storage to get clients with matching text", ^{
                        expenseClientStorage should have_received(@selector(getClientsWithMatchingText:)).with(@"some-search-text");
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
