#import <Cedar/Cedar.h>
#import "ProjectRepository.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import <KSDeferred/KSDeferred.h>
#import "RequestPromiseClient.h"
#import "InjectorKeys.h"
#import "ProjectRequestProvider.h"
#import "ProjectStorage.h"
#import "ProjectDeserializer.h"
#import "ProjectType.h"
#import "Constants.h"
#import "UserPermissionsStorage.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ProjectRepositorySpec)

sharedExamplesFor(@"sharedContextForTimesheetsFetchFreshProjectsForClientUri", ^(NSDictionary *sharedContext) {
    __block KSPromise *promise;
    __block NSURLRequest *request;
    __block KSDeferred *clientsDeferred;
    __block ProjectRepository *subject;
    __block id <RequestPromiseClient> jsonClient;
    __block ProjectRequestProvider *projectRequestProvider;
    __block ProjectStorage *projectStorage;
    __block ProjectDeserializer *projectDeserializer;
    __block NSString *uri;

    
    beforeEach(^{
        
        uri                        = sharedContext[@"uri"];
        projectRequestProvider     = sharedContext[@"projectRequestProvider"];
        projectStorage             = sharedContext[@"projectStorage"];
        projectDeserializer        = sharedContext[@"projectDeserializer"];
        jsonClient                 = sharedContext[@"jsonClient"];
        subject                    = sharedContext[@"subject"];

    });


    context(@"searching projects without client uri", ^{
        beforeEach(^{
            clientsDeferred = [[KSDeferred alloc]init];
            request = nice_fake_for([NSURLRequest class]);
            projectRequestProvider stub_method(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",nil,nil,@1).and_return(request);
            jsonClient stub_method(@selector(promiseWithRequest:)).and_return(clientsDeferred.promise);
            projectStorage stub_method(@selector(getAllProjectsForClientUri:)).with(nil).and_return(@[@1, @2, @3]);

            promise = [subject fetchFreshProjectsForClientUri:nil];

        });

        it(@"should send the correctly configured request to server", ^{
            projectRequestProvider should have_received(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",nil,nil,@1);
            jsonClient should have_received(@selector(promiseWithRequest:)).with(request);
        });

        context(@"when the request is successful", ^{
            __block NSDictionary *responseDictionary;
            beforeEach(^{
                responseDictionary = nice_fake_for([NSDictionary class]);
                projectDeserializer stub_method(@selector(deserialize:)).and_return(@[@1, @2, @3]);
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
                projectDeserializer should have_received(@selector(deserialize:)).with(responseDictionary);
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
            projectRequestProvider stub_method(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",uri,nil,@1).and_return(request);
            jsonClient stub_method(@selector(promiseWithRequest:)).and_return(clientsDeferred.promise);
            projectStorage stub_method(@selector(getAllProjectsForClientUri:)).with(uri).and_return(@[@1, @2, @3]);

            promise = [subject fetchFreshProjectsForClientUri:uri];

        });

        it(@"should send the correctly configured request to server", ^{
            projectRequestProvider should have_received(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",uri,nil,@1);
            jsonClient should have_received(@selector(promiseWithRequest:)).with(request);
        });

        context(@"when the request is successful", ^{
            __block NSDictionary *responseDictionary;
            beforeEach(^{
                responseDictionary = nice_fake_for([NSDictionary class]);
                projectDeserializer stub_method(@selector(deserialize:)).and_return(@[@1, @2, @3]);
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
                projectDeserializer should have_received(@selector(deserialize:)).with(responseDictionary);
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

describe(@"ProjectRepository", ^{
    
    describe(@"ProjectRepository without fake instances", ^{
        __block ProjectRepository *subject;
        __block id <BSInjector,BSBinder> injector;
        __block id<UserSession> userSession;
        beforeEach(^{
            injector = [InjectorProvider injector];
            
            userSession = nice_fake_for(@protocol(UserSession));
            userSession stub_method(@selector(currentUserURI)).and_return(@"User-Uri");
            [injector bind:@protocol(UserSession) toInstance:userSession];
            
            subject = [injector getInstance:[ProjectRepository class]];
        });
        context(@"initial projects fetch", ^{
            beforeEach(^{
                spy_on(subject.projectStorage);
                spy_on(subject.requestProvider);
                [subject setUpWithUserUri:@"User-Uri"];
                [subject fetchProjectsMatchingText:@"proj" clientUri:@"client-Uri"];
            });
            
            it(@"should call requestForProjectsForExpenseSheetURI", ^{
                subject.requestProvider should have_received(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",@"client-Uri",@"proj",@1);
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
                [subject setUpWithUserUri:@"User-Uri"];
                [subject.projectStorage.userDefaults setObject:[NSNumber numberWithInteger:1] forKey:@"LastDownloadedFilteredProjectPageNumber"];
                [subject.projectStorage updatePageNumberForFilteredSearch];
                [subject fetchMoreProjectsMatchingText:@"proj" clientUri:@"client-Uri"];
            });
            
            it(@"should call ", ^{
                subject.requestProvider should have_received(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",@"client-Uri",@"proj",@2);
            });
            afterEach(^{
                stop_spying_on(subject.projectStorage);
                stop_spying_on(subject.requestProvider);
            });
        });

    });
    
    describe(@"ProjectRepository with fake instnaces", ^{
        __block ProjectRepository *subject;
        __block id <BSInjector,BSBinder> injector;
        __block id <RequestPromiseClient> jsonClient;
        __block ProjectRequestProvider *projectRequestProvider;
        __block ProjectStorage *projectStorage;
        __block id <UserSession> userSession;
        __block ProjectDeserializer *projectDeserializer;
        
        
        beforeEach(^{
            injector = [InjectorProvider injector];
            projectDeserializer = nice_fake_for([ProjectDeserializer class]);
            userSession = nice_fake_for(@protocol(UserSession));
            userSession stub_method(@selector(currentUserURI)).and_return(@"Some:User-Uri");
            jsonClient = nice_fake_for(@protocol(RequestPromiseClient));
            
            
            projectStorage = nice_fake_for([ProjectStorage class]);
            projectRequestProvider = nice_fake_for([ProjectRequestProvider class]);
            
            [injector bind:InjectorKeyRepliconClientForeground toInstance:jsonClient];
            [injector bind:[ProjectRequestProvider class] toInstance:projectRequestProvider];
            [injector bind:[ProjectStorage class] toInstance:projectStorage];
            [injector bind:@protocol(UserSession) toInstance:userSession];
            [injector bind:[ProjectDeserializer class] toInstance:projectDeserializer];
            
            
            subject = [injector getInstance:[ProjectRepository class]];
            
            [subject setUpWithUserUri:@"User-Uri"];
            
        });
        
        it(@"storage should have correctly set up the user uri", ^{
            projectStorage should have_received(@selector(setUpWithUserUri:)).and_with(@"User-Uri");
        });
        
        describe(@"fetchAllProjectsForClientUri:", ^{
            context(@"searching projects without client uri", ^{
                
                context(@"When cached projects are absent", ^{
                    
                    beforeEach(^{
                        [subject fetchAllProjectsForClientUri:nil];
                    });
                    
                    itShouldBehaveLike(@"sharedContextForTimesheetsFetchFreshProjectsForClientUri",  ^(NSMutableDictionary *sharedContext) {
                        sharedContext[@"uri"] = nil;
                        sharedContext[@"projectRequestProvider"] = projectRequestProvider;
                        sharedContext[@"projectStorage"] = projectStorage;
                        sharedContext[@"projectDeserializer"] = projectDeserializer;
                        sharedContext[@"jsonClient"] = jsonClient;
                        sharedContext[@"subject"] = subject;
                        
                    });
                    
                });
                
            });
            
            context(@"searching projects with client uri", ^{
                
                context(@"When cached projects are absent", ^{
                    
                    beforeEach(^{
                        [subject fetchAllProjectsForClientUri:@"client-uri"];
                    });
                    
                    itShouldBehaveLike(@"sharedContextForTimesheetsFetchFreshProjectsForClientUri",  ^(NSMutableDictionary *sharedContext) {
                        sharedContext[@"uri"] = @"client-uri";;
                        sharedContext[@"projectRequestProvider"] = projectRequestProvider;
                        sharedContext[@"projectStorage"] = projectStorage;
                        sharedContext[@"projectDeserializer"] = projectDeserializer;
                        sharedContext[@"jsonClient"] = jsonClient;
                        sharedContext[@"subject"] = subject;
                        
                    });
                    
                });
            });
            
            context(@"searching projects with client null behaviour uri and type is Any client", ^{
                
                context(@"When cached projects are absent", ^{
                    
                    beforeEach(^{
                        [subject fetchAllProjectsForClientUri:ClientTypeAnyClientUri];
                    });
                    
                    itShouldBehaveLike(@"sharedContextForTimesheetsFetchFreshProjectsForClientUri",  ^(NSMutableDictionary *sharedContext) {
                        sharedContext[@"uri"] = @"client-uri";;
                        sharedContext[@"projectRequestProvider"] = projectRequestProvider;
                        sharedContext[@"projectStorage"] = projectStorage;
                        sharedContext[@"projectDeserializer"] = projectDeserializer;
                        sharedContext[@"jsonClient"] = jsonClient;
                        sharedContext[@"subject"] = subject;
                        
                    });
                    
                });
            });
            
            context(@"searching projects with client null behaviour uri and type is No client", ^{
                
                context(@"When cached projects are absent", ^{
                    
                    beforeEach(^{
                        [subject fetchAllProjectsForClientUri:ClientTypeNoClientUri];
                    });
                    
                    itShouldBehaveLike(@"sharedContextForTimesheetsFetchFreshProjectsForClientUri",  ^(NSMutableDictionary *sharedContext) {
                        sharedContext[@"uri"] = @"client-uri";;
                        sharedContext[@"projectRequestProvider"] = projectRequestProvider;
                        sharedContext[@"projectStorage"] = projectStorage;
                        sharedContext[@"projectDeserializer"] = projectDeserializer;
                        sharedContext[@"jsonClient"] = jsonClient;
                        sharedContext[@"subject"] = subject;
                        
                    });
                    
                });
            });
            
        });
        
        describe(@"fetchCachedProjectsMatchingText:clientUri:", ^{
            
            __block KSPromise *promise;
            __block NSArray *expectedProjectsArray;
            
            context(@"Search for project when client uri is available", ^{
                
                beforeEach(^{
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
            
            context(@"Search for project when client uri is null behaviour and type is Any client", ^{
                
                beforeEach(^{
                    ProjectType *clientA = nice_fake_for([ProjectType class]);
                    ProjectType *clientB = nice_fake_for([ProjectType class]);
                    ProjectType *clientC = nice_fake_for([ProjectType class]);
                    
                    expectedProjectsArray = @[clientA,clientB,clientC];
                    projectStorage stub_method(@selector(getAllProjectsForClientUri:)).and_return(@[@"some-client"]);
                    projectStorage stub_method(@selector(getProjectsWithMatchingText:clientUri:)).with(@"some-matching-text", ClientTypeAnyClientUri).and_return(expectedProjectsArray);
                    promise = [subject fetchCachedProjectsMatchingText:@"some-matching-text" clientUri:ClientTypeAnyClientUri];
                });
                
                it(@"should resolve the promise correctly", ^{
                    promise.value should equal(@{@"projects":expectedProjectsArray,@"downloadCount":@1});
                });
                
            });
            
            context(@"Search for project when client uri is null behaviour and type is No client", ^{
                
                beforeEach(^{
                    ProjectType *clientA = nice_fake_for([ProjectType class]);
                    ProjectType *clientB = nice_fake_for([ProjectType class]);
                    ProjectType *clientC = nice_fake_for([ProjectType class]);
                    
                    expectedProjectsArray = @[clientA,clientB,clientC];
                    projectStorage stub_method(@selector(getAllProjectsForClientUri:)).and_return(@[@"some-client"]);
                    projectStorage stub_method(@selector(getProjectsWithMatchingText:clientUri:)).with(@"some-matching-text", ClientTypeNoClientUri).and_return(expectedProjectsArray);
                    promise = [subject fetchCachedProjectsMatchingText:@"some-matching-text" clientUri:ClientTypeNoClientUri];
                });
                
                it(@"should resolve the promise correctly", ^{
                    promise.value should equal(@{@"projects":expectedProjectsArray,@"downloadCount":@1});
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
                        projectRequestProvider stub_method(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",nil,nil,@3).and_return(request);
                        jsonClient stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                        promise = [subject fetchProjectsMatchingText:nil clientUri:nil];
                    });
                    
                    it(@"client storage should have received resetSearchPage number", ^{
                        projectStorage should have_received(@selector(resetPageNumberForFilteredSearch));
                    });
                    
                    it(@"should ask for the page number", ^{
                        projectStorage should have_received(@selector(getLastPageNumber));
                    });
                    
                    it(@"should get the request from client request provider", ^{
                        projectRequestProvider should have_received(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",nil,nil,@3);
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
                            projectDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedProjectsArray);
                            [deferred resolveWithValue:jsonDictionary];
                        });
                        
                        it(@"should ask the client deserializer to deserialize the clients", ^{
                            projectDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
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
                        projectRequestProvider stub_method(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",nil,@"some-search-text",@3).and_return(request);
                        jsonClient stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                        promise = [subject fetchProjectsMatchingText:@"some-search-text" clientUri:nil];
                    });
                    
                    it(@"should ask for the page number", ^{
                        projectStorage should have_received(@selector(getLastPageNumberForFilteredSearch));
                    });
                    
                    it(@"should get the request from client request provider", ^{
                        projectRequestProvider should have_received(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",nil,@"some-search-text",@3);
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
                            projectDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedProjectsArray);
                            [deferred resolveWithValue:jsonDictionary];
                        });
                        
                        it(@"should ask the client deserializer to deserialize the clients", ^{
                            projectDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
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
                        projectRequestProvider stub_method(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",nil,nil,@3).and_return(request);
                        jsonClient stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                        promise = [subject fetchProjectsMatchingText:nil clientUri:nil];
                    });
                    
                    it(@"should ask for the page number", ^{
                        projectStorage should have_received(@selector(getLastPageNumber));
                    });
                    
                    it(@"should get the request from client request provider", ^{
                        projectRequestProvider should have_received(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",nil,nil,@3);
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
                            projectDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedProjectsArray);
                            [deferred resolveWithValue:jsonDictionary];
                        });
                        
                        it(@"should ask the client deserializer to deserialize the clients", ^{
                            projectDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
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
                        projectRequestProvider stub_method(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",@"client-uri",@"some-search-text",@3).and_return(request);
                        jsonClient stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                        promise = [subject fetchProjectsMatchingText:@"some-search-text" clientUri:@"client-uri"];
                    });
                    
                    it(@"should ask for the page number", ^{
                        projectStorage should have_received(@selector(getLastPageNumberForFilteredSearch));
                    });
                    
                    it(@"should get the request from client request provider", ^{
                        projectRequestProvider should have_received(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",@"client-uri",@"some-search-text",@3);
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
                            projectDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedProjectsArray);
                            [deferred resolveWithValue:jsonDictionary];
                        });
                        
                        it(@"should ask the client deserializer to deserialize the clients", ^{
                            projectDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
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
                
                context(@"When searching client with null behaviour uri and type is Any client", ^{
                    __block NSURLRequest *request;
                    __block KSDeferred *deferred;
                    __block KSPromise *promise;
                    beforeEach(^{
                        deferred = [[KSDeferred alloc]init];
                        request = nice_fake_for([NSURLRequest class]);
                        projectStorage stub_method(@selector(getLastPageNumberForFilteredSearch)).and_return(@3);
                        projectRequestProvider stub_method(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",ClientTypeAnyClientUri,@"some-search-text",@3).and_return(request);
                        jsonClient stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                        promise = [subject fetchProjectsMatchingText:@"some-search-text" clientUri:ClientTypeAnyClientUri];
                    });
                    
                    it(@"should ask for the page number", ^{
                        projectStorage should have_received(@selector(getLastPageNumberForFilteredSearch));
                    });
                    
                    it(@"should get the request from client request provider", ^{
                        projectRequestProvider should have_received(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",ClientTypeAnyClientUri,@"some-search-text",@3);
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
                            
                            projectStorage stub_method(@selector(getProjectsWithMatchingText:clientUri:)).with(@"some-search-text", ClientTypeAnyClientUri).and_return(filteredProjects);
                            expectedProjectsArray = @[clientA,clientB,clientC];
                            projectDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedProjectsArray);
                            [deferred resolveWithValue:jsonDictionary];
                        });
                        
                        it(@"should ask the client deserializer to deserialize the clients", ^{
                            projectDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                        });
                        
                        it(@"should store the deserialized clients into the storage", ^{
                            projectStorage should have_received(@selector(storeProjects:)).with(expectedProjectsArray);
                        });
                        
                        it(@"should update the last stored page number", ^{
                            projectStorage should have_received(@selector(updatePageNumberForFilteredSearch));
                        });
                        
                        it(@"should ask the client storage to get clients with matching text", ^{
                            projectStorage should have_received(@selector(getProjectsWithMatchingText:clientUri:)).with(@"some-search-text", ClientTypeAnyClientUri);
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
                
                context(@"When searching client with null behaviour uri and type is No client", ^{
                    __block NSURLRequest *request;
                    __block KSDeferred *deferred;
                    __block KSPromise *promise;
                    beforeEach(^{
                        deferred = [[KSDeferred alloc]init];
                        request = nice_fake_for([NSURLRequest class]);
                        projectStorage stub_method(@selector(getLastPageNumberForFilteredSearch)).and_return(@3);
                        projectRequestProvider stub_method(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",ClientTypeNoClientUri,@"some-search-text",@3).and_return(request);
                        jsonClient stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                        promise = [subject fetchProjectsMatchingText:@"some-search-text" clientUri:ClientTypeNoClientUri];
                    });
                    
                    it(@"should ask for the page number", ^{
                        projectStorage should have_received(@selector(getLastPageNumberForFilteredSearch));
                    });
                    
                    it(@"should get the request from client request provider", ^{
                        projectRequestProvider should have_received(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",ClientTypeNoClientUri,@"some-search-text",@3);
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
                            
                            projectStorage stub_method(@selector(getProjectsWithMatchingText:clientUri:)).with(@"some-search-text", ClientTypeNoClientUri).and_return(filteredProjects);
                            expectedProjectsArray = @[clientA,clientB,clientC];
                            projectDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedProjectsArray);
                            [deferred resolveWithValue:jsonDictionary];
                        });
                        
                        it(@"should ask the client deserializer to deserialize the clients", ^{
                            projectDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                        });
                        
                        it(@"should store the deserialized clients into the storage", ^{
                            projectStorage should have_received(@selector(storeProjects:)).with(expectedProjectsArray);
                        });
                        
                        it(@"should update the last stored page number", ^{
                            projectStorage should have_received(@selector(updatePageNumberForFilteredSearch));
                        });
                        
                        it(@"should ask the client storage to get clients with matching text", ^{
                            projectStorage should have_received(@selector(getProjectsWithMatchingText:clientUri:)).with(@"some-search-text", ClientTypeNoClientUri);
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
                        projectRequestProvider stub_method(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",nil,nil,@3).and_return(request);
                        jsonClient stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                        promise = [subject fetchMoreProjectsMatchingText:nil clientUri:nil];
                    });
                    
                    it(@"should ask for the page number", ^{
                        projectStorage should have_received(@selector(getLastPageNumber));
                    });
                    
                    it(@"should get the request from client request provider", ^{
                        projectRequestProvider should have_received(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",nil,nil,@3);
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
                            projectDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedProjectsArray);
                            
                            projectStorage stub_method(@selector(getAllProjectsForClientUri:)).with(nil).and_return(expectedProjectsArray);
                            [deferred resolveWithValue:jsonDictionary];
                        });
                        
                        it(@"should ask the client deserializer to deserialize the clients", ^{
                            projectDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
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
                        projectRequestProvider stub_method(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",nil,@"some-search-text",@3).and_return(request);
                        jsonClient stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                        promise = [subject fetchMoreProjectsMatchingText:@"some-search-text" clientUri:nil];
                    });
                    
                    it(@"should ask for the page number", ^{
                        projectStorage should have_received(@selector(getLastPageNumberForFilteredSearch));
                    });
                    
                    it(@"should get the request from client request provider", ^{
                        projectRequestProvider should have_received(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",nil,@"some-search-text",@3);
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
                            projectDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedProjectsArray);
                            projectStorage stub_method(@selector(getAllProjectsForClientUri:)).with(nil).and_return(expectedProjectsArray);
                            [deferred resolveWithValue:jsonDictionary];
                        });
                        
                        it(@"should ask the client deserializer to deserialize the clients", ^{
                            projectDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
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
                
                context(@"When searching more client with null behaviour uri and Type is Any client", ^{
                    __block NSURLRequest *request;
                    __block KSDeferred *deferred;
                    __block KSPromise *promise;
                    beforeEach(^{
                        deferred = [[KSDeferred alloc]init];
                        request = nice_fake_for([NSURLRequest class]);
                        projectStorage stub_method(@selector(getLastPageNumberForFilteredSearch)).and_return(@3);
                        projectRequestProvider stub_method(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",ClientTypeAnyClientUri,@"some-search-text",@3).and_return(request);
                        jsonClient stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                        promise = [subject fetchMoreProjectsMatchingText:@"some-search-text" clientUri:ClientTypeAnyClientUri];
                    });
                    
                    it(@"should ask for the page number", ^{
                        projectStorage should have_received(@selector(getLastPageNumberForFilteredSearch));
                    });
                    
                    it(@"should get the request from client request provider", ^{
                        projectRequestProvider should have_received(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",ClientTypeAnyClientUri,@"some-search-text",@3);
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
                            
                            projectStorage stub_method(@selector(getProjectsWithMatchingText:clientUri:)).with(@"some-search-text", ClientTypeAnyClientUri).and_return(filteredProjects);
                            expectedProjectsArray = @[clientA,clientB,clientC];
                            projectDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedProjectsArray);
                            projectStorage stub_method(@selector(getAllProjectsForClientUri:)).with(ClientTypeAnyClientUri).and_return(expectedProjectsArray);
                            [deferred resolveWithValue:jsonDictionary];
                        });
                        
                        it(@"should ask the client deserializer to deserialize the clients", ^{
                            projectDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                        });
                        
                        it(@"should store the deserialized clients into the storage", ^{
                            projectStorage should have_received(@selector(storeProjects:)).with(expectedProjectsArray);
                        });
                        
                        it(@"should update the last stored page number", ^{
                            projectStorage should have_received(@selector(updatePageNumberForFilteredSearch));
                        });
                        
                        it(@"should ask the client storage to get clients with matching text", ^{
                            projectStorage should have_received(@selector(getProjectsWithMatchingText:clientUri:)).with(@"some-search-text", ClientTypeAnyClientUri);
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
                
                context(@"When searching more client with null behaviour uri and Type is No client", ^{
                    __block NSURLRequest *request;
                    __block KSDeferred *deferred;
                    __block KSPromise *promise;
                    beforeEach(^{
                        deferred = [[KSDeferred alloc]init];
                        request = nice_fake_for([NSURLRequest class]);
                        projectStorage stub_method(@selector(getLastPageNumberForFilteredSearch)).and_return(@3);
                        projectRequestProvider stub_method(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",ClientTypeNoClientUri,@"some-search-text",@3).and_return(request);
                        jsonClient stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                        promise = [subject fetchMoreProjectsMatchingText:@"some-search-text" clientUri:ClientTypeNoClientUri];
                    });
                    
                    it(@"should ask for the page number", ^{
                        projectStorage should have_received(@selector(getLastPageNumberForFilteredSearch));
                    });
                    
                    it(@"should get the request from client request provider", ^{
                        projectRequestProvider should have_received(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri", ClientTypeNoClientUri,@"some-search-text",@3);
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
                            
                            projectStorage stub_method(@selector(getProjectsWithMatchingText:clientUri:)).with(@"some-search-text", ClientTypeNoClientUri).and_return(filteredProjects);
                            expectedProjectsArray = @[clientA,clientB,clientC];
                            projectDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedProjectsArray);
                            projectStorage stub_method(@selector(getAllProjectsForClientUri:)).with(ClientTypeNoClientUri).and_return(expectedProjectsArray);
                            [deferred resolveWithValue:jsonDictionary];
                        });
                        
                        it(@"should ask the client deserializer to deserialize the clients", ^{
                            projectDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
                        });
                        
                        it(@"should store the deserialized clients into the storage", ^{
                            projectStorage should have_received(@selector(storeProjects:)).with(expectedProjectsArray);
                        });
                        
                        it(@"should update the last stored page number", ^{
                            projectStorage should have_received(@selector(updatePageNumberForFilteredSearch));
                        });
                        
                        it(@"should ask the client storage to get clients with matching text", ^{
                            projectStorage should have_received(@selector(getProjectsWithMatchingText:clientUri:)).with(@"some-search-text",ClientTypeNoClientUri);
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
                        projectRequestProvider stub_method(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",@"client-uri",nil,@3).and_return(request);
                        jsonClient stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                        promise = [subject fetchMoreProjectsMatchingText:nil clientUri:@"client-uri"];
                    });
                    
                    it(@"should ask for the page number", ^{
                        projectStorage should have_received(@selector(getLastPageNumber));
                    });
                    
                    it(@"should get the request from client request provider", ^{
                        projectRequestProvider should have_received(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",@"client-uri",nil,@3);
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
                            projectDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedProjectsArray);
                            
                            projectStorage stub_method(@selector(getAllProjectsForClientUri:)).with(@"client-uri").and_return(expectedProjectsArray);
                            [deferred resolveWithValue:jsonDictionary];
                        });
                        
                        it(@"should ask the client deserializer to deserialize the clients", ^{
                            projectDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
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
                        projectRequestProvider stub_method(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",@"client-uri",@"some-search-text",@3).and_return(request);
                        jsonClient stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                        promise = [subject fetchMoreProjectsMatchingText:@"some-search-text" clientUri:@"client-uri"];
                    });
                    
                    it(@"should ask for the page number", ^{
                        projectStorage should have_received(@selector(getLastPageNumberForFilteredSearch));
                    });
                    
                    it(@"should get the request from client request provider", ^{
                        projectRequestProvider should have_received(@selector(requestForProjectsForUserWithURI:clientUri:searchText:page:)).with(@"User-Uri",@"client-uri",@"some-search-text",@3);
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
                            projectDeserializer stub_method(@selector(deserialize:)).with(jsonDictionary).and_return(expectedProjectsArray);
                            projectStorage stub_method(@selector(getAllProjectsForClientUri:)).with(@"client-uri").and_return(expectedProjectsArray);
                            [deferred resolveWithValue:jsonDictionary];
                        });
                        
                        it(@"should ask the client deserializer to deserialize the clients", ^{
                            projectDeserializer should have_received(@selector(deserialize:)).with(jsonDictionary);
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
