#import <Cedar/Cedar.h>
#import "ExpenseProjectRepository.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import <KSDeferred/KSDeferred.h>
#import "RequestPromiseClient.h"
#import "InjectorKeys.h"
#import "ExpenseProjectRequestProvider.h"
#import "ExpenseProjectStorage.h"
#import "ExpenseProjectDeserializer.h"
#import "ProjectType.h"
#import "UserPermissionsStorage.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ExpenseProjectRepositorySpec)


sharedExamplesFor(@"sharedContextForFetchFreshProjectsForClientUri", ^(NSDictionary *sharedContext) {
    __block KSPromise *promise;
    __block NSURLRequest *request;
    __block KSDeferred *clientsDeferred;

    __block ExpenseProjectRepository *subject;
    __block id <RequestPromiseClient> jsonClient;
    __block ExpenseProjectRequestProvider *clientRequestProvider;
    __block ExpenseProjectStorage *projectStorage;
    __block id <UserSession> userSession;
    __block ExpenseProjectDeserializer *clientDeserializer;
    __block UserPermissionsStorage *userPermissionsStorage;
    __block NSString *uri;

    beforeEach(^{
        uri                     = sharedContext[@"uri"];
        clientRequestProvider   = sharedContext[@"clientRequestProvider"];
        projectStorage          = sharedContext[@"projectStorage"];
        userSession             = sharedContext[@"userSession"];
        clientDeserializer      = sharedContext[@"clientDeserializer"];
        userPermissionsStorage  = sharedContext[@"userPermissionsStorage"];
        jsonClient              = sharedContext[@"jsonClient"];
        subject                 = sharedContext[@"subject"];

    });

    context(@"searching projects without client uri", ^{
        beforeEach(^{
            clientsDeferred = [[KSDeferred alloc]init];
            request = nice_fake_for([NSURLRequest class]);
            clientRequestProvider stub_method(@selector(requestForProjectsForExpenseSheetURI:clientUri:searchText:page:)).with(@"Expense-Uri",nil,nil,@1).and_return(request);
            jsonClient stub_method(@selector(promiseWithRequest:)).and_return(clientsDeferred.promise);
            projectStorage stub_method(@selector(getAllProjectsForClientUri:)).with(nil).and_return(@[@1, @2, @3]);

            promise = [subject fetchFreshProjectsForClientUri:nil];

        });

        it(@"should send the correctly configured request to server", ^{
            clientRequestProvider should have_received(@selector(requestForProjectsForExpenseSheetURI:clientUri:searchText:page:)).with(@"Expense-Uri",nil,nil,@1);
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
                projectStorage should have_received(@selector(resetPageNumber));
                projectStorage should have_received(@selector(resetPageNumberForFilteredSearch));
            });

            it(@"should delete all the cached data", ^{
                projectStorage should have_received(@selector(deleteAllProjectsForClientUri:)).with(nil);
            });

            it(@"should send the response dictionary to the client deserializer", ^{
                clientDeserializer should have_received(@selector(deserialize:)).with(responseDictionary);
            });
            it(@"should persist the client types in the client storage cache", ^{
                projectStorage should have_received(@selector(storeProjects:)).with(@[@1, @2, @3]);
            });
            it(@"should persist the client types in the client storage cache", ^{
                projectStorage should have_received(@selector(updatePageNumber));
            });
            it(@"should resolve the promise with the deserialized objects", ^{
                promise.value should equal(@{@"projects":@[@1, @2, @3],@"downloadCount":@3});
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

    context(@"searching projects with client uri", ^{
        beforeEach(^{
            clientsDeferred = [[KSDeferred alloc]init];
            request = nice_fake_for([NSURLRequest class]);
            clientRequestProvider stub_method(@selector(requestForProjectsForExpenseSheetURI:clientUri:searchText:page:)).with(@"Expense-Uri",uri,nil,@1).and_return(request);
            jsonClient stub_method(@selector(promiseWithRequest:)).and_return(clientsDeferred.promise);
            projectStorage stub_method(@selector(getAllProjectsForClientUri:)).with(uri).and_return(@[@1, @2, @3]);

            promise = [subject fetchFreshProjectsForClientUri:uri];

        });

        it(@"should send the correctly configured request to server", ^{
            clientRequestProvider should have_received(@selector(requestForProjectsForExpenseSheetURI:clientUri:searchText:page:)).with(@"Expense-Uri",uri,nil,@1);
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
                projectStorage should have_received(@selector(resetPageNumber));
                projectStorage should have_received(@selector(resetPageNumberForFilteredSearch));
            });

            it(@"should delete all the cached data", ^{
                projectStorage should have_received(@selector(deleteAllProjectsForClientUri:)).with(uri);
            });

            it(@"should send the response dictionary to the client deserializer", ^{
                clientDeserializer should have_received(@selector(deserialize:)).with(responseDictionary);
            });
            it(@"should persist the client types in the client storage cache", ^{
                projectStorage should have_received(@selector(storeProjects:)).with(@[@1, @2, @3]);
            });
            it(@"should persist the client types in the client storage cache", ^{
                projectStorage should have_received(@selector(updatePageNumber));
            });
            it(@"should resolve the promise with the deserialized objects", ^{
                promise.value should equal(@{@"projects":@[@1, @2, @3],@"downloadCount":@3});
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

});

describe(@"ExpenseProjectRepository", ^{
    
    describe(@"ExpenseProjectRepository without fake instances", ^{
        __block ExpenseProjectRepository *subject;
        __block id <BSInjector,BSBinder> injector;
        
        beforeEach(^{
            injector = [InjectorProvider injector];
            subject = [injector getInstance:[ExpenseProjectRepository class]];
        });
        context(@"initial projects fetch", ^{
            beforeEach(^{
                spy_on(subject.projectStorage);
                spy_on(subject.requestProvider);
                [subject setUpWithExpenseSheetUri:@"Expense-Uri"];
                [subject fetchProjectsMatchingText:@"proj" clientUri:@"client-Uri"];
            });
            
            it(@"should call requestForProjectsForExpenseSheetURI", ^{
                subject.requestProvider should have_received(@selector(requestForProjectsForExpenseSheetURI:clientUri:searchText:page:)).with(@"Expense-Uri",@"client-Uri",@"proj",@1);
            });
            
            afterEach(^{
                stop_spying_on(subject.projectStorage);
                stop_spying_on(subject.requestProvider);
            });
        });
        
        context(@"fetch more projects", ^{
            beforeEach(^{
                spy_on(subject.projectStorage);
                spy_on(subject.requestProvider);
                [subject setUpWithExpenseSheetUri:@"Expense-Uri"];
                [subject.projectStorage.userDefaults setObject:[NSNumber numberWithInteger:1] forKey:@"LastDownloadedFilteredExpenseProjectPageNumber"];
                [subject.projectStorage updatePageNumberForFilteredSearch];
                [subject fetchMoreProjectsMatchingText:@"proj" clientUri:@"client-Uri"];
            });
            
            it(@"should call ", ^{
                subject.requestProvider should have_received(@selector(requestForProjectsForExpenseSheetURI:clientUri:searchText:page:)).with(@"Expense-Uri",@"client-Uri",@"proj",@2);
            });
            afterEach(^{
                stop_spying_on(subject.projectStorage);
                stop_spying_on(subject.requestProvider);
            });
        });
    });
    
    describe(@"ExpenseProjectRepository with fake instances", ^{
        __block ExpenseProjectRepository *subject;
        
        __block id <BSInjector,BSBinder> injector;
        __block id <RequestPromiseClient> jsonClient;
        __block ExpenseProjectRequestProvider *clientRequestProvider;
        __block ExpenseProjectStorage *projectStorage;
        __block id <UserSession> userSession;
        __block ExpenseProjectDeserializer *clientDeserializer;
        __block UserPermissionsStorage *userPermissionsStorage;
        
        
        beforeEach(^{
            injector = [InjectorProvider injector];
            clientDeserializer = nice_fake_for([ExpenseProjectDeserializer class]);
            userSession = nice_fake_for(@protocol(UserSession));
            jsonClient = nice_fake_for(@protocol(RequestPromiseClient));
            
            
            projectStorage = nice_fake_for([ExpenseProjectStorage class]);
            clientRequestProvider = nice_fake_for([ExpenseProjectRequestProvider class]);
            
            userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
            
            [injector bind:InjectorKeyRepliconClientForeground toInstance:jsonClient];
            [injector bind:[ExpenseProjectRequestProvider class] toInstance:clientRequestProvider];
            [injector bind:[ExpenseProjectStorage class] toInstance:projectStorage];
            [injector bind:@protocol(UserSession) toInstance:userSession];
            [injector bind:[ExpenseProjectDeserializer class] toInstance:clientDeserializer];
            [injector bind:[UserPermissionsStorage class] toInstance:userPermissionsStorage];
            
            
            subject = [injector getInstance:[ExpenseProjectRepository class]];
            [subject setUpWithExpenseSheetUri:@"Expense-Uri"];
        });
        
        
        describe(@"fetchAllProjectsForClientUri:", ^{
            
            __block KSPromise *promise;
            __block NSArray *expectedProjectsArray;
            
            context(@"searching projects without client uri", ^{
                
                context(@"When cached projects are present", ^{
                    beforeEach(^{
                        ProjectType *clientA = nice_fake_for([ProjectType class]);
                        ProjectType *clientB = nice_fake_for([ProjectType class]);
                        ProjectType *clientC = nice_fake_for([ProjectType class]);
                        
                        expectedProjectsArray = @[clientA,clientB,clientC];
                        projectStorage stub_method(@selector(getAllProjectsForClientUri:)).with(nil).and_return(expectedProjectsArray);
                        promise = [subject fetchAllProjectsForClientUri:nil];
                    });
                    
                    it(@"should resolve the promise correctly", ^{
                        promise.value should equal(@{@"projects":expectedProjectsArray,@"downloadCount":@3});
                    });
                });
                
                context(@"When cached projects are absent", ^{
                    
                    beforeEach(^{
                        [subject fetchAllProjectsForClientUri:nil];
                    });
                    
                    itShouldBehaveLike(@"sharedContextForFetchFreshProjectsForClientUri",  ^(NSMutableDictionary *sharedContext) {
                        sharedContext[@"uri"] = nil;
                        sharedContext[@"clientRequestProvider"] = clientRequestProvider;
                        sharedContext[@"projectStorage"] = projectStorage;
                        sharedContext[@"userSession"] = userSession;
                        sharedContext[@"clientDeserializer"] = clientDeserializer;
                        sharedContext[@"userPermissionsStorage"] = userPermissionsStorage;
                        sharedContext[@"jsonClient"] = jsonClient;
                        sharedContext[@"subject"] = subject;
                        
                    });
                    
                });
                
            });
            
            context(@"searching projects with client uri", ^{
                
                context(@"When cached projects are present", ^{
                    
                    context(@"when the project is mandatory", ^{
                        beforeEach(^{
                            userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(YES);
                            ProjectType *clientA = nice_fake_for([ProjectType class]);
                            ProjectType *clientB = nice_fake_for([ProjectType class]);
                            ProjectType *clientC = nice_fake_for([ProjectType class]);
                            
                            expectedProjectsArray = @[clientA,clientB,clientC];
                            projectStorage stub_method(@selector(getAllProjectsForClientUri:)).with(@"client-uri").and_return(expectedProjectsArray);
                            promise = [subject fetchAllProjectsForClientUri:@"client-uri"];
                        });
                        
                        it(@"should resolve the promise correctly", ^{
                            promise.value should equal(@{@"projects":expectedProjectsArray,@"downloadCount":@3});
                        });
                        
                    });
                    
                    context(@"when the project is optional", ^{
                        beforeEach(^{
                            userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(NO);
                            ProjectType *clientA = nice_fake_for([ProjectType class]);
                            ProjectType *clientB = nice_fake_for([ProjectType class]);
                            ProjectType *clientC = nice_fake_for([ProjectType class]);
                            ProjectType *noneClient = nice_fake_for([ProjectType class]);
                            
                            expectedProjectsArray = @[noneClient,clientA,clientB,clientC];
                            projectStorage stub_method(@selector(getAllProjectsForClientUri:)).with(@"client-uri").and_return(expectedProjectsArray);
                            promise = [subject fetchAllProjectsForClientUri:@"client-uri"];
                        });
                        
                        it(@"should resolve the promise correctly", ^{
                            promise.value should equal(@{@"projects":expectedProjectsArray,@"downloadCount":@4});
                        });
                        
                    });
                    
                });
                
                context(@"When cached projects are absent", ^{
                    
                    beforeEach(^{
                        [subject fetchAllProjectsForClientUri:@"client-uri"];
                    });
                    
                    itShouldBehaveLike(@"sharedContextForFetchFreshProjectsForClientUri",  ^(NSMutableDictionary *sharedContext) {
                        sharedContext[@"uri"] = @"client-uri";
                        sharedContext[@"clientRequestProvider"] = clientRequestProvider;
                        sharedContext[@"projectStorage"] = projectStorage;
                        sharedContext[@"userSession"] = userSession;
                        sharedContext[@"clientDeserializer"] = clientDeserializer;
                        sharedContext[@"userPermissionsStorage"] = userPermissionsStorage;
                        sharedContext[@"jsonClient"] = jsonClient;
                        sharedContext[@"subject"] = subject;
                        
                    });
                    
                });
            });
            
        });
        
        describe(@"fetchCachedProjectsMatchingText:clientUri:", ^{
            
            __block KSPromise *promise;
            __block NSArray *expectedProjectsArray;
            
            context(@"when the project is mandatory", ^{
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(YES);
                    ProjectType *clientA = nice_fake_for([ProjectType class]);
                    ProjectType *clientB = nice_fake_for([ProjectType class]);
                    ProjectType *clientC = nice_fake_for([ProjectType class]);
                    
                    expectedProjectsArray = @[clientA,clientB,clientC];
                    projectStorage stub_method(@selector(getAllProjectsForClientUri:)).and_return(@[@"some-client"]);
                    projectStorage stub_method(@selector(getProjectsWithMatchingText:clientUri:)).with(@"some-matching-text",@"client-uri").and_return(expectedProjectsArray);
                    promise = [subject fetchCachedProjectsMatchingText:@"some-matching-text" clientUri:@"client-uri"];
                });
                
                it(@"should resolve the promise correctly", ^{
                    promise.value should equal(@{@"projects":expectedProjectsArray,@"downloadCount":@1});
                });
                
            });
            
            context(@"when the project is optional", ^{
                beforeEach(^{
                    userPermissionsStorage stub_method(@selector(isExpensesProjectMandatory)).and_return(NO);
                    ProjectType *clientA = nice_fake_for([ProjectType class]);
                    ProjectType *clientB = nice_fake_for([ProjectType class]);
                    ProjectType *clientC = nice_fake_for([ProjectType class]);
                    ProjectType *noneClient = nice_fake_for([ProjectType class]);
                    
                    expectedProjectsArray = @[noneClient,clientA,clientB,clientC];
                    projectStorage stub_method(@selector(getAllProjectsForClientUri:)).and_return(@[noneClient,@"some-client"]);
                    projectStorage stub_method(@selector(getProjectsWithMatchingText:clientUri:)).with(@"some-matching-text",@"client-uri").and_return(expectedProjectsArray);
                    promise = [subject fetchCachedProjectsMatchingText:@"some-matching-text" clientUri:@"client-uri"];
                });
                
                it(@"should resolve the promise correctly", ^{
                    promise.value should equal(@{@"projects":expectedProjectsArray,@"downloadCount":@2});
                });
                
            });
            
        });
        
        describe(@"fetchProjectsMatchingText:clientUri:", ^{
            
            context(@"searching projects without client uri", ^{
                
                context(@"When searching client with empty text", ^{
                    __block NSURLRequest *request;
                    __block KSDeferred *deferred;
                    __block KSPromise *promise;
                    beforeEach(^{
                        deferred = [[KSDeferred alloc]init];
                        request = nice_fake_for([NSURLRequest class]);
                        projectStorage stub_method(@selector(getLastPageNumber)).and_return(@3);
                        clientRequestProvider stub_method(@selector(requestForProjectsForExpenseSheetURI:clientUri:searchText:page:)).with(@"Expense-Uri",nil,nil,@3).and_return(request);
                        jsonClient stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                        promise = [subject fetchProjectsMatchingText:nil clientUri:nil];
                    });
                    
                    it(@"should ask for the page number", ^{
                        projectStorage should have_received(@selector(getLastPageNumber));
                    });
                    
                    it(@"should get the request from client request provider", ^{
                        clientRequestProvider should have_received(@selector(requestForProjectsForExpenseSheetURI:clientUri:searchText:page:)).with(@"Expense-Uri",nil,nil,@3);
                    });
                    
                    it(@"should send the request to server", ^{
                        jsonClient should have_received(@selector(promiseWithRequest:)).with(request);
                    });
                    
                    it(@"expense project storage should have received resetPageNumberForFilteredSearch", ^{
                        projectStorage should have_received(@selector(resetPageNumberForFilteredSearch));
                    });
                    
                    context(@"When request succeeds", ^{
                        
                        __block NSDictionary *jsonDictionary ;
                        __block NSArray *expectedProjectsArray;
                        __block NSArray *filteredProjects;
                        beforeEach(^{
                            jsonDictionary = nice_fake_for([NSDictionary class]);
                            ProjectType *clientA = nice_fake_for([ProjectType class]);
                            ProjectType *clientB = nice_fake_for([ProjectType class]);
                            ProjectType *clientC = nice_fake_for([ProjectType class]);
                            ProjectType *clientD = nice_fake_for([ProjectType class]);
                            ProjectType *clientE = nice_fake_for([ProjectType class]);
                            ProjectType *clientF = nice_fake_for([ProjectType class]);
                            
                            filteredProjects = @[clientD,clientE,clientF];
                            
                            projectStorage stub_method(@selector(getProjectsWithMatchingText:clientUri:)).with(nil,nil).and_return(filteredProjects);
                            expectedProjectsArray = @[clientA,clientB,clientC];
                            clientDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedProjectsArray);
                            [deferred resolveWithValue:jsonDictionary];
                        });
                        
                        it(@"should ask the client deserializer to deserialize the clients", ^{
                            clientDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                        });
                        
                        it(@"should store the deserialized clients into the storage", ^{
                            projectStorage should have_received(@selector(storeProjects:)).with(expectedProjectsArray);
                        });
                        
                        it(@"should update the last stored page number", ^{
                            projectStorage should have_received(@selector(updatePageNumber));
                        });
                        
                        it(@"should ask the client storage to get clients with matching text", ^{
                            projectStorage should have_received(@selector(getProjectsWithMatchingText:clientUri:)).with(nil,nil);
                        });
                        
                        it(@"should resolve the promise correctly", ^{
                            promise.value should equal(@{@"projects":filteredProjects,@"downloadCount":@3});
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
                        projectStorage stub_method(@selector(getLastPageNumberForFilteredSearch)).and_return(@3);
                        clientRequestProvider stub_method(@selector(requestForProjectsForExpenseSheetURI:clientUri:searchText:page:)).with(@"Expense-Uri",nil,@"some-search-text",@3).and_return(request);
                        jsonClient stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                        promise = [subject fetchProjectsMatchingText:@"some-search-text" clientUri:nil];
                    });
                    
                    it(@"should ask for the page number", ^{
                        projectStorage should have_received(@selector(getLastPageNumberForFilteredSearch));
                    });
                    
                    it(@"should get the request from client request provider", ^{
                        clientRequestProvider should have_received(@selector(requestForProjectsForExpenseSheetURI:clientUri:searchText:page:)).with(@"Expense-Uri",nil,@"some-search-text",@3);
                    });
                    
                    it(@"should send the request to server", ^{
                        jsonClient should have_received(@selector(promiseWithRequest:)).with(request);
                    });
                    
                    context(@"When request succeeds", ^{
                        
                        __block NSDictionary *jsonDictionary ;
                        __block NSArray *expectedProjectsArray;
                        __block NSArray *filteredProjects;
                        beforeEach(^{
                            jsonDictionary = nice_fake_for([NSDictionary class]);
                            ProjectType *clientA = nice_fake_for([ProjectType class]);
                            ProjectType *clientB = nice_fake_for([ProjectType class]);
                            ProjectType *clientC = nice_fake_for([ProjectType class]);
                            ProjectType *clientD = nice_fake_for([ProjectType class]);
                            ProjectType *clientE = nice_fake_for([ProjectType class]);
                            ProjectType *clientF = nice_fake_for([ProjectType class]);
                            
                            filteredProjects = @[clientD,clientE,clientF];
                            
                            projectStorage stub_method(@selector(getProjectsWithMatchingText:clientUri:)).with(@"some-search-text",nil).and_return(filteredProjects);
                            expectedProjectsArray = @[clientA,clientB,clientC];
                            clientDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedProjectsArray);
                            [deferred resolveWithValue:jsonDictionary];
                        });
                        
                        it(@"should ask the client deserializer to deserialize the clients", ^{
                            clientDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                        });
                        
                        it(@"should store the deserialized clients into the storage", ^{
                            projectStorage should have_received(@selector(storeProjects:)).with(expectedProjectsArray);
                        });
                        
                        it(@"should update the last stored page number", ^{
                            projectStorage should have_received(@selector(updatePageNumberForFilteredSearch));
                        });
                        
                        it(@"should ask the client storage to get clients with matching text", ^{
                            projectStorage should have_received(@selector(getProjectsWithMatchingText:clientUri:)).with(@"some-search-text",nil);
                        });
                        
                        it(@"should resolve the promise correctly", ^{
                            promise.value should equal(@{@"projects":filteredProjects,@"downloadCount":@3});
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
            context(@"searching projects with client uri", ^{
                
                context(@"When searching client with empty text", ^{
                    __block NSURLRequest *request;
                    __block KSDeferred *deferred;
                    __block KSPromise *promise;
                    beforeEach(^{
                        deferred = [[KSDeferred alloc]init];
                        request = nice_fake_for([NSURLRequest class]);
                        projectStorage stub_method(@selector(getLastPageNumber)).and_return(@3);
                        clientRequestProvider stub_method(@selector(requestForProjectsForExpenseSheetURI:clientUri:searchText:page:)).with(@"Expense-Uri",nil,nil,@3).and_return(request);
                        jsonClient stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                        promise = [subject fetchProjectsMatchingText:nil clientUri:nil];
                    });
                    
                    it(@"should ask for the page number", ^{
                        projectStorage should have_received(@selector(getLastPageNumber));
                    });
                    
                    it(@"should get the request from client request provider", ^{
                        clientRequestProvider should have_received(@selector(requestForProjectsForExpenseSheetURI:clientUri:searchText:page:)).with(@"Expense-Uri",nil,nil,@3);
                    });
                    
                    it(@"should send the request to server", ^{
                        jsonClient should have_received(@selector(promiseWithRequest:)).with(request);
                    });
                    
                    context(@"When request succeeds", ^{
                        
                        __block NSDictionary *jsonDictionary ;
                        __block NSArray *expectedProjectsArray;
                        __block NSArray *filteredProjects;
                        beforeEach(^{
                            jsonDictionary = nice_fake_for([NSDictionary class]);
                            ProjectType *clientA = nice_fake_for([ProjectType class]);
                            ProjectType *clientB = nice_fake_for([ProjectType class]);
                            ProjectType *clientC = nice_fake_for([ProjectType class]);
                            ProjectType *clientD = nice_fake_for([ProjectType class]);
                            ProjectType *clientE = nice_fake_for([ProjectType class]);
                            ProjectType *clientF = nice_fake_for([ProjectType class]);
                            
                            filteredProjects = @[clientD,clientE,clientF];
                            
                            projectStorage stub_method(@selector(getProjectsWithMatchingText:clientUri:)).with(nil,nil).and_return(filteredProjects);
                            expectedProjectsArray = @[clientA,clientB,clientC];
                            clientDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedProjectsArray);
                            [deferred resolveWithValue:jsonDictionary];
                        });
                        
                        it(@"should ask the client deserializer to deserialize the clients", ^{
                            clientDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                        });
                        
                        it(@"should store the deserialized clients into the storage", ^{
                            projectStorage should have_received(@selector(storeProjects:)).with(expectedProjectsArray);
                        });
                        
                        it(@"should update the last stored page number", ^{
                            projectStorage should have_received(@selector(updatePageNumber));
                        });
                        
                        it(@"should ask the client storage to get clients with matching text", ^{
                            projectStorage should have_received(@selector(getProjectsWithMatchingText:clientUri:)).with(nil,nil);
                        });
                        
                        it(@"should resolve the promise correctly", ^{
                            promise.value should equal(@{@"projects":filteredProjects,@"downloadCount":@3});
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
                        projectStorage stub_method(@selector(getLastPageNumberForFilteredSearch)).and_return(@3);
                        clientRequestProvider stub_method(@selector(requestForProjectsForExpenseSheetURI:clientUri:searchText:page:)).with(@"Expense-Uri",@"client-uri",@"some-search-text",@3).and_return(request);
                        jsonClient stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                        promise = [subject fetchProjectsMatchingText:@"some-search-text" clientUri:@"client-uri"];
                    });
                    
                    it(@"should ask for the page number", ^{
                        projectStorage should have_received(@selector(getLastPageNumberForFilteredSearch));
                    });
                    
                    it(@"should get the request from client request provider", ^{
                        clientRequestProvider should have_received(@selector(requestForProjectsForExpenseSheetURI:clientUri:searchText:page:)).with(@"Expense-Uri",@"client-uri",@"some-search-text",@3);
                    });
                    
                    it(@"should send the request to server", ^{
                        jsonClient should have_received(@selector(promiseWithRequest:)).with(request);
                    });
                    
                    context(@"When request succeeds", ^{
                        
                        __block NSDictionary *jsonDictionary ;
                        __block NSArray *expectedProjectsArray;
                        __block NSArray *filteredProjects;
                        beforeEach(^{
                            jsonDictionary = nice_fake_for([NSDictionary class]);
                            ProjectType *clientA = nice_fake_for([ProjectType class]);
                            ProjectType *clientB = nice_fake_for([ProjectType class]);
                            ProjectType *clientC = nice_fake_for([ProjectType class]);
                            ProjectType *clientD = nice_fake_for([ProjectType class]);
                            ProjectType *clientE = nice_fake_for([ProjectType class]);
                            ProjectType *clientF = nice_fake_for([ProjectType class]);
                            
                            filteredProjects = @[clientD,clientE,clientF];
                            
                            projectStorage stub_method(@selector(getProjectsWithMatchingText:clientUri:)).with(@"some-search-text",@"client-uri").and_return(filteredProjects);
                            expectedProjectsArray = @[clientA,clientB,clientC];
                            clientDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedProjectsArray);
                            [deferred resolveWithValue:jsonDictionary];
                        });
                        
                        it(@"should ask the client deserializer to deserialize the clients", ^{
                            clientDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                        });
                        
                        it(@"should store the deserialized clients into the storage", ^{
                            projectStorage should have_received(@selector(storeProjects:)).with(expectedProjectsArray);
                        });
                        
                        it(@"should update the last stored page number", ^{
                            projectStorage should have_received(@selector(updatePageNumberForFilteredSearch));
                        });
                        
                        it(@"should ask the client storage to get clients with matching text", ^{
                            projectStorage should have_received(@selector(getProjectsWithMatchingText:clientUri:)).with(@"some-search-text",@"client-uri");
                        });
                        
                        it(@"should resolve the promise correctly", ^{
                            promise.value should equal(@{@"projects":filteredProjects,@"downloadCount":@3});
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
        
        describe(@"fetchMoreProjectsMatchingText:clientUri:", ^{
            
            context(@"searching projects without client uri", ^{
                
                context(@"When searching more client with empty text", ^{
                    __block NSURLRequest *request;
                    __block KSDeferred *deferred;
                    __block KSPromise *promise;
                    beforeEach(^{
                        deferred = [[KSDeferred alloc]init];
                        request = nice_fake_for([NSURLRequest class]);
                        projectStorage stub_method(@selector(getLastPageNumber)).and_return(@3);
                        clientRequestProvider stub_method(@selector(requestForProjectsForExpenseSheetURI:clientUri:searchText:page:)).with(@"Expense-Uri",nil,nil,@3).and_return(request);
                        jsonClient stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                        promise = [subject fetchMoreProjectsMatchingText:nil clientUri:nil];
                    });
                    
                    it(@"should ask for the page number", ^{
                        projectStorage should have_received(@selector(getLastPageNumber));
                    });
                    
                    it(@"should get the request from client request provider", ^{
                        clientRequestProvider should have_received(@selector(requestForProjectsForExpenseSheetURI:clientUri:searchText:page:)).with(@"Expense-Uri",nil,nil,@3);
                    });
                    
                    it(@"should send the request to server", ^{
                        jsonClient should have_received(@selector(promiseWithRequest:)).with(request);
                    });
                    
                    context(@"When request succeeds", ^{
                        
                        __block NSDictionary *jsonDictionary ;
                        __block NSArray *expectedProjectsArray;
                        __block NSArray *filteredProjects;
                        beforeEach(^{
                            jsonDictionary = nice_fake_for([NSDictionary class]);
                            ProjectType *clientA = nice_fake_for([ProjectType class]);
                            ProjectType *clientB = nice_fake_for([ProjectType class]);
                            ProjectType *clientC = nice_fake_for([ProjectType class]);
                            ProjectType *clientD = nice_fake_for([ProjectType class]);
                            ProjectType *clientE = nice_fake_for([ProjectType class]);
                            ProjectType *clientF = nice_fake_for([ProjectType class]);
                            
                            filteredProjects = @[clientD,clientE,clientF];
                            
                            projectStorage stub_method(@selector(getProjectsWithMatchingText:clientUri:)).with(nil,nil).and_return(filteredProjects);
                            expectedProjectsArray = @[clientA,clientB,clientC];
                            clientDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedProjectsArray);
                            
                            projectStorage stub_method(@selector(getAllProjectsForClientUri:)).with(nil).and_return(expectedProjectsArray);
                            [deferred resolveWithValue:jsonDictionary];
                        });
                        
                        it(@"should ask the client deserializer to deserialize the clients", ^{
                            clientDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                        });
                        
                        it(@"should store the deserialized clients into the storage", ^{
                            projectStorage should have_received(@selector(storeProjects:)).with(expectedProjectsArray);
                        });
                        
                        it(@"should update the last stored page number", ^{
                            projectStorage should have_received(@selector(updatePageNumber));
                        });
                        
                        it(@"should ask the client storage to get clients with matching text", ^{
                            projectStorage should have_received(@selector(getProjectsWithMatchingText:clientUri:)).with(nil,nil);
                        });
                        
                        it(@"should resolve the promise correctly", ^{
                            promise.value should equal(@{@"projects":filteredProjects,@"downloadCount":@3});
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
                        projectStorage stub_method(@selector(getLastPageNumberForFilteredSearch)).and_return(@3);
                        clientRequestProvider stub_method(@selector(requestForProjectsForExpenseSheetURI:clientUri:searchText:page:)).with(@"Expense-Uri",nil,@"some-search-text",@3).and_return(request);
                        jsonClient stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                        promise = [subject fetchMoreProjectsMatchingText:@"some-search-text" clientUri:nil];
                    });
                    
                    it(@"should ask for the page number", ^{
                        projectStorage should have_received(@selector(getLastPageNumberForFilteredSearch));
                    });
                    
                    it(@"should get the request from client request provider", ^{
                        clientRequestProvider should have_received(@selector(requestForProjectsForExpenseSheetURI:clientUri:searchText:page:)).with(@"Expense-Uri",nil,@"some-search-text",@3);
                    });
                    
                    it(@"should send the request to server", ^{
                        jsonClient should have_received(@selector(promiseWithRequest:)).with(request);
                    });
                    
                    context(@"When request succeeds", ^{
                        
                        __block NSDictionary *jsonDictionary ;
                        __block NSArray *expectedProjectsArray;
                        __block NSArray *filteredProjects;
                        beforeEach(^{
                            jsonDictionary = nice_fake_for([NSDictionary class]);
                            ProjectType *clientA = nice_fake_for([ProjectType class]);
                            ProjectType *clientB = nice_fake_for([ProjectType class]);
                            ProjectType *clientC = nice_fake_for([ProjectType class]);
                            ProjectType *clientD = nice_fake_for([ProjectType class]);
                            ProjectType *clientE = nice_fake_for([ProjectType class]);
                            ProjectType *clientF = nice_fake_for([ProjectType class]);
                            
                            filteredProjects = @[clientD,clientE,clientF];
                            
                            projectStorage stub_method(@selector(getProjectsWithMatchingText:clientUri:)).with(@"some-search-text",nil).and_return(filteredProjects);
                            expectedProjectsArray = @[clientA,clientB,clientC];
                            clientDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedProjectsArray);
                            projectStorage stub_method(@selector(getAllProjectsForClientUri:)).with(nil).and_return(expectedProjectsArray);
                            [deferred resolveWithValue:jsonDictionary];
                        });
                        
                        it(@"should ask the client deserializer to deserialize the clients", ^{
                            clientDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                        });
                        
                        it(@"should store the deserialized clients into the storage", ^{
                            projectStorage should have_received(@selector(storeProjects:)).with(expectedProjectsArray);
                        });
                        
                        it(@"should update the last stored page number", ^{
                            projectStorage should have_received(@selector(updatePageNumberForFilteredSearch));
                        });
                        
                        it(@"should ask the client storage to get clients with matching text", ^{
                            projectStorage should have_received(@selector(getProjectsWithMatchingText:clientUri:)).with(@"some-search-text",nil);
                        });
                        
                        it(@"should resolve the promise correctly", ^{
                            promise.value should equal(@{@"projects":filteredProjects,@"downloadCount":@3});
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
            
            context(@"searching projects with client uri", ^{
                
                context(@"When searching more client with empty text", ^{
                    __block NSURLRequest *request;
                    __block KSDeferred *deferred;
                    __block KSPromise *promise;
                    beforeEach(^{
                        deferred = [[KSDeferred alloc]init];
                        request = nice_fake_for([NSURLRequest class]);
                        projectStorage stub_method(@selector(getLastPageNumber)).and_return(@3);
                        clientRequestProvider stub_method(@selector(requestForProjectsForExpenseSheetURI:clientUri:searchText:page:)).with(@"Expense-Uri",@"client-uri",nil,@3).and_return(request);
                        jsonClient stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                        promise = [subject fetchMoreProjectsMatchingText:nil clientUri:@"client-uri"];
                    });
                    
                    it(@"should ask for the page number", ^{
                        projectStorage should have_received(@selector(getLastPageNumber));
                    });
                    
                    it(@"should get the request from client request provider", ^{
                        clientRequestProvider should have_received(@selector(requestForProjectsForExpenseSheetURI:clientUri:searchText:page:)).with(@"Expense-Uri",@"client-uri",nil,@3);
                    });
                    
                    it(@"should send the request to server", ^{
                        jsonClient should have_received(@selector(promiseWithRequest:)).with(request);
                    });
                    
                    context(@"When request succeeds", ^{
                        
                        __block NSDictionary *jsonDictionary ;
                        __block NSArray *expectedProjectsArray;
                        __block NSArray *filteredProjects;
                        beforeEach(^{
                            jsonDictionary = nice_fake_for([NSDictionary class]);
                            ProjectType *clientA = nice_fake_for([ProjectType class]);
                            ProjectType *clientB = nice_fake_for([ProjectType class]);
                            ProjectType *clientC = nice_fake_for([ProjectType class]);
                            ProjectType *clientD = nice_fake_for([ProjectType class]);
                            ProjectType *clientE = nice_fake_for([ProjectType class]);
                            ProjectType *clientF = nice_fake_for([ProjectType class]);
                            
                            filteredProjects = @[clientD,clientE,clientF];
                            
                            projectStorage stub_method(@selector(getProjectsWithMatchingText:clientUri:)).with(nil,@"client-uri").and_return(filteredProjects);
                            expectedProjectsArray = @[clientA,clientB,clientC];
                            clientDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedProjectsArray);
                            
                            projectStorage stub_method(@selector(getAllProjectsForClientUri:)).with(@"client-uri").and_return(expectedProjectsArray);
                            [deferred resolveWithValue:jsonDictionary];
                        });
                        
                        it(@"should ask the client deserializer to deserialize the clients", ^{
                            clientDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                        });
                        
                        it(@"should store the deserialized clients into the storage", ^{
                            projectStorage should have_received(@selector(storeProjects:)).with(expectedProjectsArray);
                        });
                        
                        it(@"should update the last stored page number", ^{
                            projectStorage should have_received(@selector(updatePageNumber));
                        });
                        
                        it(@"should ask the client storage to get clients with matching text", ^{
                            projectStorage should have_received(@selector(getProjectsWithMatchingText:clientUri:)).with(nil,@"client-uri");
                        });
                        
                        it(@"should resolve the promise correctly", ^{
                            promise.value should equal(@{@"projects":filteredProjects,@"downloadCount":@3});
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
                        projectStorage stub_method(@selector(getLastPageNumberForFilteredSearch)).and_return(@3);
                        clientRequestProvider stub_method(@selector(requestForProjectsForExpenseSheetURI:clientUri:searchText:page:)).with(@"Expense-Uri",@"client-uri",@"some-search-text",@3).and_return(request);
                        jsonClient stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                        promise = [subject fetchMoreProjectsMatchingText:@"some-search-text" clientUri:@"client-uri"];
                    });
                    
                    it(@"should ask for the page number", ^{
                        projectStorage should have_received(@selector(getLastPageNumberForFilteredSearch));
                    });
                    
                    it(@"should get the request from client request provider", ^{
                        clientRequestProvider should have_received(@selector(requestForProjectsForExpenseSheetURI:clientUri:searchText:page:)).with(@"Expense-Uri",@"client-uri",@"some-search-text",@3);
                    });
                    
                    it(@"should send the request to server", ^{
                        jsonClient should have_received(@selector(promiseWithRequest:)).with(request);
                    });
                    
                    context(@"When request succeeds", ^{
                        
                        __block NSDictionary *jsonDictionary ;
                        __block NSArray *expectedProjectsArray;
                        __block NSArray *filteredProjects;
                        beforeEach(^{
                            jsonDictionary = nice_fake_for([NSDictionary class]);
                            ProjectType *clientA = nice_fake_for([ProjectType class]);
                            ProjectType *clientB = nice_fake_for([ProjectType class]);
                            ProjectType *clientC = nice_fake_for([ProjectType class]);
                            ProjectType *clientD = nice_fake_for([ProjectType class]);
                            ProjectType *clientE = nice_fake_for([ProjectType class]);
                            ProjectType *clientF = nice_fake_for([ProjectType class]);
                            
                            filteredProjects = @[clientD,clientE,clientF];
                            
                            projectStorage stub_method(@selector(getProjectsWithMatchingText:clientUri:)).with(@"some-search-text",@"client-uri").and_return(filteredProjects);
                            expectedProjectsArray = @[clientA,clientB,clientC];
                            clientDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedProjectsArray);
                            projectStorage stub_method(@selector(getAllProjectsForClientUri:)).with(@"client-uri").and_return(expectedProjectsArray);
                            [deferred resolveWithValue:jsonDictionary];
                        });
                        
                        it(@"should ask the client deserializer to deserialize the clients", ^{
                            clientDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                        });
                        
                        it(@"should store the deserialized clients into the storage", ^{
                            projectStorage should have_received(@selector(storeProjects:)).with(expectedProjectsArray);
                        });
                        
                        it(@"should update the last stored page number", ^{
                            projectStorage should have_received(@selector(updatePageNumberForFilteredSearch));
                        });
                        
                        it(@"should ask the client storage to get clients with matching text", ^{
                            projectStorage should have_received(@selector(getProjectsWithMatchingText:clientUri:)).with(@"some-search-text",@"client-uri");
                        });
                        
                        it(@"should resolve the promise correctly", ^{
                            promise.value should equal(@{@"projects":filteredProjects,@"downloadCount":@3});
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
});



SPEC_END
