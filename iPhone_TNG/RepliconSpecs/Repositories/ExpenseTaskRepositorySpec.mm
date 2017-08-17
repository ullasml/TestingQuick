#import <Cedar/Cedar.h>
#import "ExpenseTaskRepository.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import <KSDeferred/KSDeferred.h>
#import "RequestPromiseClient.h"
#import "InjectorKeys.h"
#import "ExpenseTaskRequestProvider.h"
#import "ExpenseTaskStorage.h"
#import "ExpenseTaskDeserializer.h"
#import "TaskType.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ExpenseTaskRepositorySpec)

sharedExamplesFor(@"sharedContextForFetchAllTasksForProjectUri", ^(NSDictionary *sharedContext) {
    __block KSPromise *promise;
    __block NSArray *expectedTasksArray;
    __block ExpenseTaskRepository *subject;
    __block id <RequestPromiseClient> jsonProject;
    __block ExpenseTaskRequestProvider *taskRequestProvider;
    __block ExpenseTaskStorage *taskStorage;
    __block id <UserSession> userSession;
    __block ExpenseTaskDeserializer *taskDeserializer;
    __block NSString *uri;

    beforeEach(^{
        uri                     = sharedContext[@"uri"];
        taskRequestProvider     = sharedContext[@"taskRequestProvider"];
        taskStorage             = sharedContext[@"taskStorage"];
        userSession             = sharedContext[@"userSession"];
        taskDeserializer        = sharedContext[@"taskDeserializer"];
        jsonProject             = sharedContext[@"jsonProject"];
        subject                 = sharedContext[@"subject"];

    });

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

            itShouldBehaveLike(@"sharedContextForFetchFreshProjectsForClientUri",  ^(NSMutableDictionary *sharedContext) {
                sharedContext[@"uri"] = @"project-uri";
                sharedContext[@"taskRequestProvider"] =  taskRequestProvider ;
                sharedContext[@"taskStorage"] =  taskStorage ;
                sharedContext[@"userSession"] =  userSession ;
                sharedContext[@"taskDeserializer"] =  taskDeserializer ;
                sharedContext[@"jsonProject"] =  jsonProject ;
                sharedContext[@"subject"] =  subject ;
                
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

            itShouldBehaveLike(@"sharedContextForFetchFreshProjectsForClientUri",  ^(NSMutableDictionary *sharedContext) {
               sharedContext[@"uri"] = @"project-uri";
               sharedContext[@"taskRequestProvider"] =  taskRequestProvider ;
               sharedContext[@"taskStorage"] =  taskStorage ;
               sharedContext[@"userSession"] =  userSession ;
               sharedContext[@"taskDeserializer"] =  taskDeserializer ;
               sharedContext[@"jsonProject"] =  jsonProject ;
               sharedContext[@"subject"] =  subject ;

            });

        });
    });

});

describe(@"ExpenseTaskRepository", ^{
    
    describe(@"ExpenseTaskRepository without fake instances", ^{
        __block ExpenseTaskRepository *subject;
        __block id <BSInjector,BSBinder> injector;
        
        beforeEach(^{
            injector = [InjectorProvider injector];
            subject = [injector getInstance:[ExpenseTaskRepository class]];
        });
        
        context(@"initial projects fetch", ^{
            beforeEach(^{
                spy_on(subject.taskStorage);
                spy_on(subject.requestProvider);
                [subject setUpWithExpenseSheetUri:@"Expense-Uri"];
                [subject fetchTasksMatchingText:@"task1" projectUri:@"project-Uri"];
            });
            
            it(@"should call requestForProjectsForExpenseSheetURI", ^{
                subject.requestProvider should have_received(@selector(requestForTasksForExpenseSheetURI:projectUri:searchText:page:)).with(@"Expense-Uri",@"project-Uri",@"task1",@1);
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
                [subject setUpWithExpenseSheetUri:@"Expense-Uri"];
                [subject.taskStorage.userDefaults setObject:[NSNumber numberWithInteger:1] forKey:@"LastDownloadedFilteredExpenseTaskPageNumber"];
                [subject.taskStorage updatePageNumberForFilteredSearch];
                [subject fetchMoreTasksMatchingText:@"task1" projectUri:@"project-Uri"];
            });
            
            it(@"should call requestForTasksForExpenseSheetURI", ^{
                subject.requestProvider should have_received(@selector(requestForTasksForExpenseSheetURI:projectUri:searchText:page:)).with(@"Expense-Uri",@"project-Uri",@"task1",@2);
            });
            
            afterEach(^{
                stop_spying_on(subject.taskStorage);
                stop_spying_on(subject.requestProvider);
            });
        });
    });
    
    describe(@"ExpenseTaskRepository with fake instances", ^{
        __block ExpenseTaskRepository *subject;
        
        __block id <BSInjector,BSBinder> injector;
        __block id <RequestPromiseClient> jsonProject;
        __block ExpenseTaskRequestProvider *taskRequestProvider;
        __block ExpenseTaskStorage *taskStorage;
        __block id <UserSession> userSession;
        __block ExpenseTaskDeserializer *taskDeserializer;
        
        
        beforeEach(^{
            injector = [InjectorProvider injector];
            taskDeserializer = nice_fake_for([ExpenseTaskDeserializer class]);
            userSession = nice_fake_for(@protocol(UserSession));
            userSession stub_method(@selector(currentUserURI)).and_return(@"Expense-Uri");
            jsonProject = nice_fake_for(@protocol(RequestPromiseClient));
            
            
            taskStorage = nice_fake_for([ExpenseTaskStorage class]);
            taskRequestProvider = nice_fake_for([ExpenseTaskRequestProvider class]);
            
            [injector bind:InjectorKeyRepliconClientForeground toInstance:jsonProject];
            [injector bind:[ExpenseTaskRequestProvider class] toInstance:taskRequestProvider];
            [injector bind:[ExpenseTaskStorage class] toInstance:taskStorage];
            [injector bind:@protocol(UserSession) toInstance:userSession];
            [injector bind:[ExpenseTaskDeserializer class] toInstance:taskDeserializer];
            
            
            subject = [injector getInstance:[ExpenseTaskRepository class]];
            [subject setUpWithExpenseSheetUri:@"Expense-Uri"];
        });
        
        describe(@"-fetchFreshTasksForProjectUri:", ^{
            __block KSPromise *promise;
            __block NSURLRequest *request;
            __block KSDeferred *tasksDeferred;
            
            context(@"searching tasks without project uri", ^{
                beforeEach(^{
                    tasksDeferred = [[KSDeferred alloc]init];
                    request = nice_fake_for([NSURLRequest class]);
                    taskRequestProvider stub_method(@selector(requestForTasksForExpenseSheetURI:projectUri:searchText:page:)).with(@"Expense-Uri",@"project-uri",nil,@1).and_return(request);
                    jsonProject stub_method(@selector(promiseWithRequest:)).and_return(tasksDeferred.promise);
                    taskStorage stub_method(@selector(getAllTasksForProjectUri:)).with(@"project-uri").and_return(@[@1, @2, @3]);
                    
                    promise = [subject fetchFreshTasksForProjectUri:@"project-uri"];
                    
                });
                
                it(@"should send the correctly configured request to server", ^{
                    taskRequestProvider should have_received(@selector(requestForTasksForExpenseSheetURI:projectUri:searchText:page:)).with(@"Expense-Uri",@"project-uri",nil,@1);
                    jsonProject should have_received(@selector(promiseWithRequest:)).with(request);
                });
                
                context(@"when the request is successful", ^{
                    __block NSDictionary *responseDictionary;
                    beforeEach(^{
                        responseDictionary = nice_fake_for([NSDictionary class]);
                        taskDeserializer stub_method(@selector(deserialize:forProjectWithUri:)).with(responseDictionary,@"project-uri").and_return(@[@1, @2, @3]);
                        [tasksDeferred resolveWithValue:responseDictionary];
                    });
                    
                    it(@"should reset the page number", ^{
                        taskStorage should have_received(@selector(resetPageNumber));
                        taskStorage should have_received(@selector(resetPageNumberForFilteredSearch));
                    });
                    
                    it(@"should delete all the cached data", ^{
                        taskStorage should have_received(@selector(deleteAllTasksForProjectWithUri:)).with(@"project-uri");
                    });
                    
                    it(@"should send the response dictionary to the project deserializer", ^{
                        taskDeserializer should have_received(@selector(deserialize:forProjectWithUri:)).with(responseDictionary,@"project-uri");
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
                    taskRequestProvider stub_method(@selector(requestForTasksForExpenseSheetURI:projectUri:searchText:page:)).with(@"Expense-Uri",@"project-uri",nil,@1).and_return(request);
                    jsonProject stub_method(@selector(promiseWithRequest:)).and_return(tasksDeferred.promise);
                    taskStorage stub_method(@selector(getAllTasksForProjectUri:)).with(@"project-uri").and_return(@[@1, @2, @3]);
                    
                    promise = [subject fetchFreshTasksForProjectUri:@"project-uri"];
                    
                });
                
                it(@"should send the correctly configured request to server", ^{
                    taskRequestProvider should have_received(@selector(requestForTasksForExpenseSheetURI:projectUri:searchText:page:)).with(@"Expense-Uri",@"project-uri",nil,@1);
                    jsonProject should have_received(@selector(promiseWithRequest:)).with(request);
                });
                
                context(@"when the request is successful", ^{
                    __block NSDictionary *responseDictionary;
                    beforeEach(^{
                        responseDictionary = nice_fake_for([NSDictionary class]);
                        taskDeserializer stub_method(@selector(deserialize:forProjectWithUri:)).with(responseDictionary,@"project-uri").and_return(@[@1, @2, @3]);
                        [tasksDeferred resolveWithValue:responseDictionary];
                    });
                    
                    it(@"should reset the page number", ^{
                        taskStorage should have_received(@selector(resetPageNumber));
                        taskStorage should have_received(@selector(resetPageNumberForFilteredSearch));
                    });
                    
                    it(@"should delete all the cached data", ^{
                        taskStorage should have_received(@selector(deleteAllTasksForProjectWithUri:)).with(@"project-uri");
                    });
                    
                    it(@"should send the response dictionary to the project deserializer", ^{
                        taskDeserializer should have_received(@selector(deserialize:forProjectWithUri:)).with(responseDictionary,@"project-uri");
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
        
        describe(@"fetchCachedTasksMatchingText:projectUri:", ^{
            
            __block KSPromise *promise;
            __block NSArray *expectedTasksArray;
            
            beforeEach(^{
                TaskType *projectA = nice_fake_for([TaskType class]);
                TaskType *projectB = nice_fake_for([TaskType class]);
                TaskType *projectC = nice_fake_for([TaskType class]);
                TaskType *noneProject = nice_fake_for([TaskType class]);
                
                expectedTasksArray = @[noneProject,projectA,projectB,projectC];
                taskStorage stub_method(@selector(getAllTasksForProjectUri:)).and_return(@[noneProject,@"some-project"]);
                taskStorage stub_method(@selector(getTasksWithMatchingText:projectUri:)).with(@"some-matching-text",@"project-uri").and_return(expectedTasksArray);
                promise = [subject fetchCachedTasksMatchingText:@"some-matching-text" projectUri:@"project-uri"];
                
                
            });
            
            it(@"should resolve the promise correctly", ^{
                promise.value should equal(@{@"tasks":expectedTasksArray,@"downloadCount":@2});
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
                        taskRequestProvider stub_method(@selector(requestForTasksForExpenseSheetURI:projectUri:searchText:page:)).with(@"Expense-Uri",@"project-uri",nil,@3).and_return(request);
                        jsonProject stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                        promise = [subject fetchTasksMatchingText:nil projectUri:@"project-uri"];
                    });
                    
                    it(@"should ask for the page number", ^{
                        taskStorage should have_received(@selector(getLastPageNumber));
                    });
                    
                    it(@"should get the request from project request provider", ^{
                        taskRequestProvider should have_received(@selector(requestForTasksForExpenseSheetURI:projectUri:searchText:page:)).with(@"Expense-Uri",@"project-uri",nil,@3);
                    });
                    
                    it(@"should send the request to server", ^{
                        jsonProject should have_received(@selector(promiseWithRequest:)).with(request);
                    });
                    
                    it(@"expense task storage should have received resetPageNumberForFilteredSearch", ^{
                        taskStorage should have_received(@selector(resetPageNumberForFilteredSearch));
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
                        taskRequestProvider stub_method(@selector(requestForTasksForExpenseSheetURI:projectUri:searchText:page:)).with(@"Expense-Uri",@"project-uri",@"some-search-text",@3).and_return(request);
                        jsonProject stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                        promise = [subject fetchTasksMatchingText:@"some-search-text" projectUri:@"project-uri"];
                    });
                    
                    it(@"should ask for the page number", ^{
                        taskStorage should have_received(@selector(getLastPageNumberForFilteredSearch));
                    });
                    
                    it(@"should get the request from project request provider", ^{
                        taskRequestProvider should have_received(@selector(requestForTasksForExpenseSheetURI:projectUri:searchText:page:)).with(@"Expense-Uri",@"project-uri",@"some-search-text",@3);
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
                        taskRequestProvider stub_method(@selector(requestForTasksForExpenseSheetURI:projectUri:searchText:page:)).with(@"Expense-Uri",@"project-uri",nil,@3).and_return(request);
                        jsonProject stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                        promise = [subject fetchMoreTasksMatchingText:nil projectUri:@"project-uri"];
                    });
                    
                    it(@"should ask for the page number", ^{
                        taskStorage should have_received(@selector(getLastPageNumber));
                    });
                    
                    it(@"should get the request from project request provider", ^{
                        taskRequestProvider should have_received(@selector(requestForTasksForExpenseSheetURI:projectUri:searchText:page:)).with(@"Expense-Uri",@"project-uri",nil,@3);
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
                        taskRequestProvider stub_method(@selector(requestForTasksForExpenseSheetURI:projectUri:searchText:page:)).with(@"Expense-Uri",@"project-uri",@"some-search-text",@3).and_return(request);
                        jsonProject stub_method(@selector(promiseWithRequest:)).with(request).and_return(deferred.promise);
                        promise = [subject fetchMoreTasksMatchingText:@"some-search-text" projectUri:@"project-uri"];
                    });
                    
                    it(@"should ask for the page number", ^{
                        taskStorage should have_received(@selector(getLastPageNumberForFilteredSearch));
                    });
                    
                    it(@"should get the request from project request provider", ^{
                        taskRequestProvider should have_received(@selector(requestForTasksForExpenseSheetURI:projectUri:searchText:page:)).with(@"Expense-Uri",@"project-uri",@"some-search-text",@3);
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
});



SPEC_END
