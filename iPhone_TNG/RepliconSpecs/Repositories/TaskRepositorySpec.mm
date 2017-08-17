#import <Cedar/Cedar.h>
#import "TaskRepository.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import <KSDeferred/KSDeferred.h>
#import "RequestPromiseClient.h"
#import "InjectorKeys.h"
#import "TaskRequestProvider.h"
#import "TaskStorage.h"
#import "TaskDeserializer.h"
#import "TaskType.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TaskRepositorySpec)

sharedExamplesFor(@"sharedContextForFetchAllTasksForProjectUri", ^(NSDictionary *sharedContext) {
    __block KSPromise *promise;
    __block NSURLRequest *request;
    __block KSDeferred *tasksDeferred;
    __block NSString *uri;
    __block TaskRequestProvider *taskRequestProvider;
    __block TaskRepository *subject;
    __block TaskStorage *taskStorage;
    __block id <RequestPromiseClient> jsonProject;
    __block TaskDeserializer *taskDeserializer;


    beforeEach(^{
        uri = sharedContext[@"uri"];
        taskRequestProvider =  sharedContext[@"taskRequestProvider"];
        subject = sharedContext[@"subject"];
        taskStorage = sharedContext[@"taskStorage"];
        jsonProject = sharedContext[@"jsonProject"];
        taskDeserializer = sharedContext[@"taskDeserializer"];
    });

    context(@"searching tasks without project uri", ^{
        beforeEach(^{
            tasksDeferred = [[KSDeferred alloc]init];
            request = nice_fake_for([NSURLRequest class]);
            taskRequestProvider stub_method(@selector(requestForTasksForUserWithURI:projectUri:searchText:page:)).with(@"User-Uri",uri,nil,@1).and_return(request);
            jsonProject stub_method(@selector(promiseWithRequest:)).and_return(tasksDeferred.promise);
            taskStorage stub_method(@selector(getAllTasksForProjectUri:)).with(uri).and_return(@[@1, @2, @3]);

            promise = [subject fetchFreshTasksForProjectUri:uri];

        });

        it(@"should send the correctly configured request to server", ^{
            taskRequestProvider should have_received(@selector(requestForTasksForUserWithURI:projectUri:searchText:page:)).with(@"User-Uri",uri,nil,@1);
            jsonProject should have_received(@selector(promiseWithRequest:)).with(request);
        });

        context(@"when the request is successful", ^{
            __block NSDictionary *responseDictionary;
            beforeEach(^{
                responseDictionary = nice_fake_for([NSDictionary class]);
                taskDeserializer stub_method(@selector(deserialize:forProjectWithUri:)).with(responseDictionary,uri).and_return(@[@1, @2, @3]);
                [tasksDeferred resolveWithValue:responseDictionary];
            });

            it(@"should reset the page number", ^{
                taskStorage should have_received(@selector(resetPageNumber));
                taskStorage should have_received(@selector(resetPageNumberForFilteredSearch));
            });

            it(@"should delete all the cached data", ^{
                taskStorage should have_received(@selector(deleteAllTasksForProjectWithUri:)).with(uri);
            });

            it(@"should send the response dictionary to the project deserializer", ^{
                taskDeserializer should have_received(@selector(deserialize:forProjectWithUri:)).with(responseDictionary,uri);
            });
            it(@"should persist the project types in the project storage cache", ^{
                taskStorage should have_received(@selector(storeTasks:)).with(@[@1, @2, @3]);
            });
            it(@"should persist the project types in the project storage cache", ^{
                taskStorage should have_received(@selector(updatePageNumber));
            });
            it(@"should resolve the promise with the deserialized objects", ^{
                promise.value should equal(@{@"tasks":@[@1, @2, @3],@"downloadCount":@3});
            });
        });

        context(@"when the request is failed", ^{
            __block NSError *error;
            beforeEach(^{
                error = nice_fake_for([NSError class]);
                [tasksDeferred rejectWithError:error];
            });

            it(@"should resolve the promise with the deserialized objects", ^{
                promise.error should equal(error);
            });
        });
    });

    context(@"searching tasks with project uri", ^{
        beforeEach(^{
            tasksDeferred = [[KSDeferred alloc]init];
            request = nice_fake_for([NSURLRequest class]);
            taskRequestProvider stub_method(@selector(requestForTasksForUserWithURI:projectUri:searchText:page:)).with(@"User-Uri",uri,nil,@1).and_return(request);
            jsonProject stub_method(@selector(promiseWithRequest:)).and_return(tasksDeferred.promise);
            taskStorage stub_method(@selector(getAllTasksForProjectUri:)).with(uri).and_return(@[@1, @2, @3]);

            promise = [subject fetchFreshTasksForProjectUri:uri];

        });

        it(@"should send the correctly configured request to server", ^{
            taskRequestProvider should have_received(@selector(requestForTasksForUserWithURI:projectUri:searchText:page:)).with(@"User-Uri",uri,nil,@1);
            jsonProject should have_received(@selector(promiseWithRequest:)).with(request);
        });

        context(@"when the request is successful", ^{
            __block NSDictionary *responseDictionary;
            beforeEach(^{
                responseDictionary = nice_fake_for([NSDictionary class]);
                taskDeserializer stub_method(@selector(deserialize:forProjectWithUri:)).with(responseDictionary,uri).and_return(@[@1, @2, @3]);
                [tasksDeferred resolveWithValue:responseDictionary];
            });

            it(@"should reset the page number", ^{
                taskStorage should have_received(@selector(resetPageNumber));
                taskStorage should have_received(@selector(resetPageNumberForFilteredSearch));
            });

            it(@"should delete all the cached data", ^{
                taskStorage should have_received(@selector(deleteAllTasksForProjectWithUri:)).with(uri);
            });

            it(@"should send the response dictionary to the project deserializer", ^{
                taskDeserializer should have_received(@selector(deserialize:forProjectWithUri:)).with(responseDictionary,uri);
            });
            it(@"should persist the project types in the project storage cache", ^{
                taskStorage should have_received(@selector(storeTasks:)).with(@[@1, @2, @3]);
            });
            it(@"should persist the project types in the project storage cache", ^{
                taskStorage should have_received(@selector(updatePageNumber));
            });
            it(@"should resolve the promise with the deserialized objects", ^{
                promise.value should equal(@{@"tasks":@[@1, @2, @3],@"downloadCount":@3});
            });
        });

        context(@"when the request is failed", ^{
            __block NSError *error;
            beforeEach(^{
                error = nice_fake_for([NSError class]);
                [tasksDeferred rejectWithError:error];
            });

            it(@"should resolve the promise with the deserialized objects", ^{
                promise.error should equal(error);
            });
        });
    });

});

describe(@"TaskRepository", ^{
    describe(@"TaskRepository without fake instances", ^{
        __block TaskRepository *subject;
        __block id <BSInjector,BSBinder> injector;
        __block id<UserSession> userSession;
        beforeEach(^{
            injector = [InjectorProvider injector];
            userSession = nice_fake_for(@protocol(UserSession));
            userSession stub_method(@selector(currentUserURI)).and_return(@"User-Uri");
            [injector bind:@protocol(UserSession) toInstance:userSession];

            subject = [injector getInstance:[TaskRepository class]];
        });
        
        context(@"initial projects fetch", ^{
            beforeEach(^{
                spy_on(subject.taskStorage);
                spy_on(subject.requestProvider);
                [subject setUpWithUserUri:@"User-Uri"];
                [subject fetchTasksMatchingText:@"task1" projectUri:@"project-Uri"];
            });
            
            it(@"should call requestForProjectsForExpenseSheetURI", ^{
                subject.requestProvider should have_received(@selector(requestForTasksForUserWithURI:projectUri:searchText:page:)).with(@"User-Uri",@"project-Uri",@"task1",@1);
            });
            
            afterEach(^{
                stop_spying_on(subject.taskStorage);
                stop_spying_on(subject.requestProvider);
            });
        });
        
        context(@"fetch more projects", ^{
            beforeEach(^{
                spy_on(subject.taskStorage);
                spy_on(subject.requestProvider);
                [subject setUpWithUserUri:@"User-Uri"];
                [subject.taskStorage.userDefaults setObject:[NSNumber numberWithInteger:1] forKey:@"LastDownloadedFilteredTaskPageNumber"];
                [subject.taskStorage updatePageNumberForFilteredSearch];
                [subject fetchMoreTasksMatchingText:@"task1" projectUri:@"project-Uri"];
            });
            
            it(@"should call requestForTasksForExpenseSheetURI", ^{
                subject.requestProvider should have_received(@selector(requestForTasksForUserWithURI:projectUri:searchText:page:)).with(@"User-Uri",@"project-Uri",@"task1",@2);
            });
            
            afterEach(^{
                stop_spying_on(subject.taskStorage);
                stop_spying_on(subject.requestProvider);
            });
        });
    });

});

describe(@"TaskRepository", ^{
    __block TaskRepository *subject;
    __block id <BSInjector,BSBinder> injector;
    __block id <RequestPromiseClient> jsonProject;
    __block TaskRequestProvider *taskRequestProvider;
    __block TaskStorage *taskStorage;
    __block id <UserSession> userSession;
    __block TaskDeserializer *taskDeserializer;


    beforeEach(^{
        injector = [InjectorProvider injector];
        taskDeserializer = nice_fake_for([TaskDeserializer class]);
        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"Some:User-Uri");
        jsonProject = nice_fake_for(@protocol(RequestPromiseClient));


        taskStorage = nice_fake_for([TaskStorage class]);
        taskRequestProvider = nice_fake_for([TaskRequestProvider class]);

        [injector bind:InjectorKeyRepliconClientForeground toInstance:jsonProject];
        [injector bind:[TaskRequestProvider class] toInstance:taskRequestProvider];
        [injector bind:[TaskStorage class] toInstance:taskStorage];
        [injector bind:@protocol(UserSession) toInstance:userSession];
        [injector bind:[TaskDeserializer class] toInstance:taskDeserializer];


        subject = [injector getInstance:[TaskRepository class]];

        [subject setUpWithUserUri:@"User-Uri"];

    });

    it(@"storage should have correctly set up the user uri", ^{
        taskStorage should have_received(@selector(setUpWithUserUri:)).and_with(@"User-Uri");
    });

    describe(@"fetchAllTasksForProjectUri:", ^{

        __block KSPromise *promise;
        __block NSArray *expectedTasksArray;

        context(@"searching tasks without project uri", ^{

            context(@"When cached tasks are present", ^{
                beforeEach(^{
                    TaskType *projectA = nice_fake_for([TaskType class]);
                    TaskType *projectB = nice_fake_for([TaskType class]);
                    TaskType *projectC = nice_fake_for([TaskType class]);

                    expectedTasksArray = @[projectA,projectB,projectC];
                    taskStorage stub_method(@selector(getAllTasksForProjectUri:)).with(nil).and_return(expectedTasksArray);
                    promise = [subject fetchAllTasksForProjectUri:nil];
                });

                it(@"should resolve the promise correctly", ^{
                    promise.value should equal(@{@"tasks":expectedTasksArray,@"downloadCount":@3});
                });
            });

            context(@"When cached tasks are absent", ^{

                beforeEach(^{
                    [subject fetchAllTasksForProjectUri:nil];
                });

                itShouldBehaveLike(@"sharedContextForFetchAllTasksForProjectUri",  ^(NSMutableDictionary *sharedContext) {
                    sharedContext[@"uri"] = nil;
                    sharedContext[@"taskRequestProvider"] = taskRequestProvider;
                    sharedContext[@"subject"] = subject;
                    sharedContext[@"taskStorage"] = taskStorage;
                    sharedContext[@"jsonProject"] = jsonProject;
                    sharedContext[@"taskDeserializer"] = taskDeserializer;
                });

            });

        });

        context(@"searching tasks with project uri", ^{

            context(@"When cached tasks are present", ^{
                beforeEach(^{
                    TaskType *projectA = nice_fake_for([TaskType class]);
                    TaskType *projectB = nice_fake_for([TaskType class]);
                    TaskType *projectC = nice_fake_for([TaskType class]);

                    expectedTasksArray = @[projectA,projectB,projectC];
                    taskStorage stub_method(@selector(getAllTasksForProjectUri:)).with(@"project-uri").and_return(expectedTasksArray);
                    promise = [subject fetchAllTasksForProjectUri:@"project-uri"];
                });

                it(@"should resolve the promise correctly", ^{
                    promise.value should equal(@{@"tasks":expectedTasksArray,@"downloadCount":@3});
                });
            });

            context(@"When cached tasks are absent", ^{

                beforeEach(^{
                    [subject fetchAllTasksForProjectUri:@"project-uri"];
                });

                itShouldBehaveLike(@"sharedContextForFetchAllTasksForProjectUri",  ^(NSMutableDictionary *sharedContext) {
                    sharedContext[@"uri"] = @"project-uri";
                    sharedContext[@"taskRequestProvider"] = taskRequestProvider;
                    sharedContext[@"subject"] = subject;
                    sharedContext[@"taskStorage"] = taskStorage;
                    sharedContext[@"jsonProject"] = jsonProject;
                    sharedContext[@"taskDeserializer"] = taskDeserializer;
                });

            });
        });

    });

    describe(@"fetchCachedTasksMatchingText:projectUri:", ^{

        __block KSPromise *promise;
        __block NSArray *expectedTasksArray;

        beforeEach(^{
            TaskType *projectA = nice_fake_for([TaskType class]);
            TaskType *projectB = nice_fake_for([TaskType class]);
            TaskType *projectC = nice_fake_for([TaskType class]);

            expectedTasksArray = @[projectA,projectB,projectC];
            taskStorage stub_method(@selector(getAllTasksForProjectUri:)).and_return(@[@"some-project"]);
            taskStorage stub_method(@selector(getTasksWithMatchingText:projectUri:)).with(@"some-matching-text",@"project-uri").and_return(expectedTasksArray);
            promise = [subject fetchCachedTasksMatchingText:@"some-matching-text" projectUri:@"project-uri"];


        });

        it(@"should resolve the promise correctly", ^{
            promise.value should equal(@{@"tasks":expectedTasksArray,@"downloadCount":@1});
        });

    });

    describe(@"fetchTasksMatchingText:projectUri:", ^{

        context(@"searching tasks with project uri", ^{

            context(@"When searching task with empty text", ^{
                __block NSURLRequest *request;
                __block KSDeferred *deferred;
                __block KSPromise *promise;
                beforeEach(^{
                    deferred = [[KSDeferred alloc]init];
                    request = nice_fake_for([NSURLRequest class]);
                    taskStorage stub_method(@selector(getLastPageNumber)).and_return(@3);
                    taskRequestProvider stub_method(@selector(requestForTasksForUserWithURI:projectUri:searchText:page:)).with(@"User-Uri",@"project-uri",nil,@3).and_return(request);
                    jsonProject stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                    promise = [subject fetchTasksMatchingText:nil projectUri:@"project-uri"];
                });

                it(@"client storage should have received resetSearchPage number", ^{
                    taskStorage should have_received(@selector(resetPageNumberForFilteredSearch));
                });
                
                it(@"should ask for the page number", ^{
                    taskStorage should have_received(@selector(getLastPageNumber));
                });

                it(@"should get the request from project request provider", ^{
                    taskRequestProvider should have_received(@selector(requestForTasksForUserWithURI:projectUri:searchText:page:)).with(@"User-Uri",@"project-uri",nil,@3);
                });

                it(@"should send the request to server", ^{
                    jsonProject should have_received(@selector(promiseWithRequest:)).with(request);
                });

                context(@"When request succeeds", ^{

                    __block NSDictionary *jsonDictionary ;
                    __block NSArray *expectedTasksArray;
                    __block NSArray *filteredTasks;
                    beforeEach(^{
                        jsonDictionary = nice_fake_for([NSDictionary class]);
                        TaskType *projectA = nice_fake_for([TaskType class]);
                        TaskType *projectB = nice_fake_for([TaskType class]);
                        TaskType *projectC = nice_fake_for([TaskType class]);
                        TaskType *projectD = nice_fake_for([TaskType class]);
                        TaskType *projectE = nice_fake_for([TaskType class]);
                        TaskType *projectF = nice_fake_for([TaskType class]);

                        filteredTasks = @[projectD,projectE,projectF];

                        taskStorage stub_method(@selector(getTasksWithMatchingText:projectUri:)).with(nil,@"project-uri").and_return(filteredTasks);
                        expectedTasksArray = @[projectA,projectB,projectC];
                        taskDeserializer stub_method(@selector(deserialize:forProjectWithUri:)).with(jsonDictionary,@"project-uri").and_return(expectedTasksArray);
                        [deferred resolveWithValue:jsonDictionary];
                    });

                    it(@"should ask the project deserializer to deserialize the tasks", ^{
                        taskDeserializer should have_received(@selector(deserialize:forProjectWithUri:)).with(jsonDictionary,@"project-uri");
                    });

                    it(@"should store the deserialized tasks into the storage", ^{
                        taskStorage should have_received(@selector(storeTasks:)).with(expectedTasksArray);
                    });

                    it(@"should update the last stored page number", ^{
                        taskStorage should have_received(@selector(updatePageNumber));
                    });

                    it(@"should ask the project storage to get tasks with matching text", ^{
                        taskStorage should have_received(@selector(getTasksWithMatchingText:projectUri:)).with(nil,@"project-uri");
                    });

                    it(@"should resolve the promise correctly", ^{
                        promise.value should equal(@{@"tasks":filteredTasks,@"downloadCount":@3});
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

            context(@"When searching task with text", ^{
                __block NSURLRequest *request;
                __block KSDeferred *deferred;
                __block KSPromise *promise;
                beforeEach(^{
                    deferred = [[KSDeferred alloc]init];
                    request = nice_fake_for([NSURLRequest class]);
                    taskStorage stub_method(@selector(getLastPageNumberForFilteredSearch)).and_return(@3);
                    taskRequestProvider stub_method(@selector(requestForTasksForUserWithURI:projectUri:searchText:page:)).with(@"User-Uri",@"project-uri",@"some-search-text",@3).and_return(request);
                    jsonProject stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                    promise = [subject fetchTasksMatchingText:@"some-search-text" projectUri:@"project-uri"];
                });

                it(@"should ask for the page number", ^{
                    taskStorage should have_received(@selector(getLastPageNumberForFilteredSearch));
                });

                it(@"should get the request from project request provider", ^{
                    taskRequestProvider should have_received(@selector(requestForTasksForUserWithURI:projectUri:searchText:page:)).with(@"User-Uri",@"project-uri",@"some-search-text",@3);
                });

                it(@"should send the request to server", ^{
                    jsonProject should have_received(@selector(promiseWithRequest:)).with(request);
                });

                context(@"When request succeeds", ^{

                    __block NSDictionary *jsonDictionary ;
                    __block NSArray *expectedTasksArray;
                    __block NSArray *filteredTasks;
                    beforeEach(^{
                        jsonDictionary = nice_fake_for([NSDictionary class]);
                        TaskType *projectA = nice_fake_for([TaskType class]);
                        TaskType *projectB = nice_fake_for([TaskType class]);
                        TaskType *projectC = nice_fake_for([TaskType class]);
                        TaskType *projectD = nice_fake_for([TaskType class]);
                        TaskType *projectE = nice_fake_for([TaskType class]);
                        TaskType *projectF = nice_fake_for([TaskType class]);

                        filteredTasks = @[projectD,projectE,projectF];

                        taskStorage stub_method(@selector(getTasksWithMatchingText:projectUri:)).with(@"some-search-text",@"project-uri").and_return(filteredTasks);
                        expectedTasksArray = @[projectA,projectB,projectC];
                        taskDeserializer stub_method(@selector(deserialize:forProjectWithUri:)).with(jsonDictionary,@"project-uri").and_return(expectedTasksArray);
                        [deferred resolveWithValue:jsonDictionary];
                    });

                    it(@"should ask the project deserializer to deserialize the tasks", ^{
                        taskDeserializer should have_received(@selector(deserialize:forProjectWithUri:)).with(jsonDictionary,@"project-uri");
                    });

                    it(@"should store the deserialized tasks into the storage", ^{
                        taskStorage should have_received(@selector(storeTasks:)).with(expectedTasksArray);
                    });

                    it(@"should update the last stored page number", ^{
                        taskStorage should have_received(@selector(updatePageNumberForFilteredSearch));
                    });

                    it(@"should ask the project storage to get tasks with matching text", ^{
                        taskStorage should have_received(@selector(getTasksWithMatchingText:projectUri:)).with(@"some-search-text",@"project-uri");
                    });

                    it(@"should resolve the promise correctly", ^{
                        promise.value should equal(@{@"tasks":filteredTasks,@"downloadCount":@3});
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

    describe(@"fetchMoreTasksMatchingText:projectUri:", ^{

        context(@"searching tasks with project uri", ^{

            context(@"When searching more tasks with empty text", ^{
                __block NSURLRequest *request;
                __block KSDeferred *deferred;
                __block KSPromise *promise;
                beforeEach(^{
                    deferred = [[KSDeferred alloc]init];
                    request = nice_fake_for([NSURLRequest class]);
                    taskStorage stub_method(@selector(getLastPageNumber)).and_return(@3);
                    taskRequestProvider stub_method(@selector(requestForTasksForUserWithURI:projectUri:searchText:page:)).with(@"User-Uri",@"project-uri",nil,@3).and_return(request);
                    jsonProject stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                    promise = [subject fetchMoreTasksMatchingText:nil projectUri:@"project-uri"];
                });

                it(@"should ask for the page number", ^{
                    taskStorage should have_received(@selector(getLastPageNumber));
                });

                it(@"should get the request from project request provider", ^{
                    taskRequestProvider should have_received(@selector(requestForTasksForUserWithURI:projectUri:searchText:page:)).with(@"User-Uri",@"project-uri",nil,@3);
                });

                it(@"should send the request to server", ^{
                    jsonProject should have_received(@selector(promiseWithRequest:)).with(request);
                });

                context(@"When request succeeds", ^{

                    __block NSDictionary *jsonDictionary ;
                    __block NSArray *expectedTasksArray;
                    __block NSArray *filteredTasks;
                    beforeEach(^{
                        jsonDictionary = nice_fake_for([NSDictionary class]);
                        TaskType *projectA = nice_fake_for([TaskType class]);
                        TaskType *projectB = nice_fake_for([TaskType class]);
                        TaskType *projectC = nice_fake_for([TaskType class]);
                        TaskType *projectD = nice_fake_for([TaskType class]);
                        TaskType *projectE = nice_fake_for([TaskType class]);
                        TaskType *projectF = nice_fake_for([TaskType class]);

                        filteredTasks = @[projectD,projectE,projectF];

                        taskStorage stub_method(@selector(getTasksWithMatchingText:projectUri:)).with(nil,@"project-uri").and_return(filteredTasks);
                        expectedTasksArray = @[projectA,projectB,projectC];
                        taskDeserializer stub_method(@selector(deserialize:forProjectWithUri:)).with(jsonDictionary,@"project-uri").and_return(expectedTasksArray);

                        taskStorage stub_method(@selector(getAllTasksForProjectUri:)).with(@"project-uri").and_return(expectedTasksArray);
                        [deferred resolveWithValue:jsonDictionary];
                    });

                    it(@"should ask the project deserializer to deserialize the tasks", ^{
                        taskDeserializer should have_received(@selector(deserialize:forProjectWithUri:)).with(jsonDictionary,@"project-uri");
                    });

                    it(@"should store the deserialized tasks into the storage", ^{
                        taskStorage should have_received(@selector(storeTasks:)).with(expectedTasksArray);
                    });

                    it(@"should update the last stored page number", ^{
                        taskStorage should have_received(@selector(updatePageNumber));
                    });

                    it(@"should ask the project storage to get tasks with matching text", ^{
                        taskStorage should have_received(@selector(getTasksWithMatchingText:projectUri:)).with(nil,@"project-uri");
                    });

                    it(@"should resolve the promise correctly", ^{
                        promise.value should equal(@{@"tasks":filteredTasks,@"downloadCount":@3});
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

            context(@"When searching more tasks with text", ^{
                __block NSURLRequest *request;
                __block KSDeferred *deferred;
                __block KSPromise *promise;
                beforeEach(^{
                    deferred = [[KSDeferred alloc]init];
                    request = nice_fake_for([NSURLRequest class]);
                    taskStorage stub_method(@selector(getLastPageNumberForFilteredSearch)).and_return(@3);
                    taskRequestProvider stub_method(@selector(requestForTasksForUserWithURI:projectUri:searchText:page:)).with(@"User-Uri",@"project-uri",@"some-search-text",@3).and_return(request);
                    jsonProject stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                    promise = [subject fetchMoreTasksMatchingText:@"some-search-text" projectUri:@"project-uri"];
                });

                it(@"should ask for the page number", ^{
                    taskStorage should have_received(@selector(getLastPageNumberForFilteredSearch));
                });

                it(@"should get the request from project request provider", ^{
                    taskRequestProvider should have_received(@selector(requestForTasksForUserWithURI:projectUri:searchText:page:)).with(@"User-Uri",@"project-uri",@"some-search-text",@3);
                });

                it(@"should send the request to server", ^{
                    jsonProject should have_received(@selector(promiseWithRequest:)).with(request);
                });

                context(@"When request succeeds", ^{

                    __block NSDictionary *jsonDictionary ;
                    __block NSArray *expectedTasksArray;
                    __block NSArray *filteredTasks;
                    beforeEach(^{
                        jsonDictionary = nice_fake_for([NSDictionary class]);
                        TaskType *taskA = nice_fake_for([TaskType class]);
                        TaskType *taskB = nice_fake_for([TaskType class]);
                        TaskType *taskC = nice_fake_for([TaskType class]);
                        TaskType *taskD = nice_fake_for([TaskType class]);
                        TaskType *taskE = nice_fake_for([TaskType class]);
                        TaskType *taskF = nice_fake_for([TaskType class]);

                        filteredTasks = @[taskD,taskE,taskF];

                        taskStorage stub_method(@selector(getTasksWithMatchingText:projectUri:)).with(@"some-search-text",@"project-uri").and_return(filteredTasks);
                        expectedTasksArray = @[taskA,taskB,taskC];
                        taskDeserializer stub_method(@selector(deserialize:forProjectWithUri:)).with(jsonDictionary,@"project-uri").and_return(expectedTasksArray);
                        taskStorage stub_method(@selector(getAllTasksForProjectUri:)).with(@"project-uri").and_return(expectedTasksArray);
                        [deferred resolveWithValue:jsonDictionary];
                    });
                    
                    it(@"should ask the project deserializer to deserialize the tasks", ^{
                        taskDeserializer should have_received(@selector(deserialize:forProjectWithUri:)).with(jsonDictionary,@"project-uri");
                    });
                    
                    it(@"should store the deserialized tasks into the storage", ^{
                        taskStorage should have_received(@selector(storeTasks:)).with(expectedTasksArray);
                    });
                    
                    it(@"should update the last stored page number", ^{
                        taskStorage should have_received(@selector(updatePageNumberForFilteredSearch));
                    });
                    
                    it(@"should ask the project storage to get tasks with matching text", ^{
                        taskStorage should have_received(@selector(getTasksWithMatchingText:projectUri:)).with(@"some-search-text",@"project-uri");
                    });
                    
                    it(@"should resolve the promise correctly", ^{
                        promise.value should equal(@{@"tasks":filteredTasks,@"downloadCount":@3});
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
