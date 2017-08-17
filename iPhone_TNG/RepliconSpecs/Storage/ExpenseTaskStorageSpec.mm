#import <Cedar/Cedar.h>
#import "ExpenseTaskStorage.h"
#import "TaskStorage.h"
#import "SQLiteTableStore.h"
#import "SQLiteDatabaseConnection.h"
#import "QueryStringBuilder.h"
#import "TaskType.h"
#import "Period.h"
#import "ClientType.h"
#import "UserPermissionsStorage.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ExpenseTaskStorageSpec)

describe(@"ExpenseTaskStorage", ^{
    __block ExpenseTaskStorage *subject;
    __block NSUserDefaults *userDefaults;
    __block DoorKeeper *doorKeeper;
    __block SQLiteTableStore<CedarDouble> *sqlLiteStore;
    __block id<UserSession> userSession;
    __block UserPermissionsStorage *userPermissionsStorage;
    
    beforeEach(^{
        
        sqlLiteStore = (id)[[SQLiteTableStore alloc] initWithSqliteDatabaseConnection:[[SQLiteDatabaseConnection alloc] init]
                                                                   queryStringBuilder:[[QueryStringBuilder alloc] init]
                                                                         databaseName:@"Test"
                                                                            tableName:@"expense_task_types"];
        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
        doorKeeper = nice_fake_for([DoorKeeper class]);
        userDefaults = nice_fake_for([NSUserDefaults class]);
        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        
        subject = [[ExpenseTaskStorage alloc]initWithSqliteStore:sqlLiteStore
                                             userDefaults:userDefaults
                                              userSession:userSession
                                               doorKeeper:doorKeeper userPermissionsStorage:userPermissionsStorage];
        
        spy_on(sqlLiteStore);
        
    });
    
    
    describe(@"-lastDownloadedPageNumber", ^{
        
        it(@"should return 1 if there was no last Downloaded PageNumber", ^{
            NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
            lastDownloadedPageNumber should equal(@1);
        });
        
        it(@"should return correctly stored last Downloaded PageNumber", ^{
            userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedExpenseTaskPageNumber").and_return(@4);
            NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
            lastDownloadedPageNumber should equal(@4);
        });
    });
    
    describe(@"-updatePageNumber", ^{
        
        it(@"should update last Downloaded PageNumber value with 1", ^{
            [subject updatePageNumber];
            userDefaults stub_method(@selector(setObject:forKey:)).with(@1, @"LastDownloadedExpenseTaskPageNumber");
            userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedExpenseTaskPageNumber").and_return(@1);
            NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
            lastDownloadedPageNumber should equal(@1);
        });
        
        it(@"should update last Downloaded PageNumber value correctly ", ^{
            userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedExpenseTaskPageNumber").and_return(@4);
            userDefaults stub_method(@selector(setObject:forKey:)).with(@5, @"LastDownloadedExpenseTaskPageNumber");
            [subject updatePageNumber];
            userDefaults stub_method(@selector(objectForKey:)).again().with(@"LastDownloadedExpenseTaskPageNumber").and_return(@5);
            
            NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
            lastDownloadedPageNumber should equal(@5);
        });
    });
    
    describe(@"-resetPageNumber", ^{
        
        it(@"should reset the last Downloaded PageNumber", ^{
            [subject resetPageNumber];
            userDefaults should have_received(@selector(removeObjectForKey:)).with(@"LastDownloadedExpenseTaskPageNumber");
        });
    });
    
    describe(@"-getLastPageNumberForFilteredSearch", ^{
        
        it(@"should return 1 if there was no last Downloaded PageNumber", ^{
            NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
            lastDownloadedPageNumber should equal(@1);
        });
        
        it(@"should return correctly stored last Downloaded PageNumber", ^{
            userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedFilteredExpenseTaskPageNumber").and_return(@4);
            NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
            lastDownloadedPageNumber should equal(@4);
        });
    });
    
    describe(@"-updatePageNumberForFilteredSearch", ^{
        
        it(@"should update last Downloaded PageNumber value with 1", ^{
            [subject updatePageNumberForFilteredSearch];
            userDefaults stub_method(@selector(setObject:forKey:)).with(@1, @"LastDownloadedFilteredExpenseTaskPageNumber");
            userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedFilteredExpenseTaskPageNumber").and_return(@1);
            NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
            lastDownloadedPageNumber should equal(@1);
        });
        
        it(@"should update last Downloaded PageNumber value correctly ", ^{
            userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedFilteredExpenseTaskPageNumber").and_return(@4);
            userDefaults stub_method(@selector(setObject:forKey:)).with(@5, @"LastDownloadedFilteredExpenseTaskPageNumber");
            [subject updatePageNumber];
            userDefaults stub_method(@selector(objectForKey:)).again().with(@"LastDownloadedFilteredExpenseTaskPageNumber").and_return(@5);
            
            NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
            lastDownloadedPageNumber should equal(@5);
        });
    });
    
    describe(@"-resetPageNumberForFilteredSearch", ^{
        
        it(@"should reset the last Downloaded PageNumber", ^{
            [subject resetPageNumberForFilteredSearch];
            userDefaults should have_received(@selector(removeObjectForKey:)).with(@"LastDownloadedFilteredExpenseTaskPageNumber");
        });
    });
    
    describe(@"-storeClients", ^{
        
        __block TaskType *task;
        __block TaskType *noneTask;
        context(@"When inserting a fresh client in DB", ^{
            beforeEach(^{
                task = [[TaskType alloc] initWithProjectUri:@"project-uri" taskPeriod:nil name:@"task-name" uri:@"task-uri"];
                noneTask = [[TaskType alloc] initWithProjectUri:@"project-uri" taskPeriod:nil name:RPLocalizedString(@"None", @"") uri:nil];
                
                sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).with(@{@"uri": @"stored-task-uri"}).and_return(nil);
                [subject storeTasks:@[task]];
            });
            
            it(@"should insert the row into database", ^{
                sqlLiteStore should have_received(@selector(insertRow:)).with(@{
                                                                                @"uri":@"task-uri",
                                                                                @"name":@"task-name",
                                                                                @"project_uri":@"project-uri",
                                                                                @"user_uri":@"user:uri"
                                                                                });
            });
            
            it(@"should return the newly inserted record", ^{
                [subject getAllTasksForProjectUri:@"project-uri"] should equal(@[noneTask,task]);
            });
        });
        
        context(@"When updating a already stored client in DB", ^{
            
            beforeEach(^{
                TaskType *storedTask = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                                 taskPeriod:nil
                                                                       name:@"stored-task-name"
                                                                        uri:@"task-uri"];
                noneTask = [[TaskType alloc] initWithProjectUri:@"project-uri" taskPeriod:nil name:RPLocalizedString(@"None", @"") uri:nil];
                
                [subject storeTasks:@[storedTask]];
                
                sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).with(@{@"uri": @"task-uri"}).and_return(@{
                                                                                                                    @"name": @"StoredClient",
                                                                                                                    @"uri": @"ClientUriA",
                                                                                                                    @"user_uri":@"user:uri"
                                                                                                                    });
                
                task = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                 taskPeriod:nil
                                                       name:@"new-task-name"
                                                        uri:@"task-uri"];
                
                
                [subject storeTasks:@[task]];
            });
            
            it(@"should update the row in database", ^{
                sqlLiteStore should have_received(@selector(updateRow:whereClause:)).with(@{
                                                                                @"uri":@"task-uri",
                                                                                @"name":@"new-task-name",
                                                                                @"project_uri":@"project-uri",
                                                                                @"user_uri":@"user:uri"
                                                                                },nil);
            });
            
            it(@"should return the newly updated record", ^{
                [subject getAllTasksForProjectUri:@"project-uri"] should equal(@[noneTask,task]);
            });
            
        });
        
    });
    
    describe(@"-getAllTasks", ^{
        
        it(@"should return all Task Types sorted ascending", ^{

            TaskType *noneTask = [[TaskType alloc] initWithProjectUri:@"project-uri" taskPeriod:nil name:RPLocalizedString(@"None", @"") uri:nil];

            TaskType *taskA = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                        taskPeriod:nil
                                                              name:@"CTaskA"
                                                               uri:@"uriA"];
            TaskType *taskB = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                        taskPeriod:nil
                                                              name:@"ATaskB"
                                                               uri:@"uriB"];
            TaskType *taskC = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                        taskPeriod:nil
                                                              name:@"BTaskC"
                                                               uri:@"uriC"];
            [subject storeTasks:@[taskA,taskB,taskC]];
            
            [subject getAllTasksForProjectUri:@"project-uri"] should equal(@[noneTask,taskB,taskC,taskA]);
        });
        
        it(@"should return older Task Types along with recent Task Types sorted ascending", ^{

            TaskType *noneTask = [[TaskType alloc] initWithProjectUri:@"project-uri" taskPeriod:nil name:RPLocalizedString(@"None", @"") uri:nil];

            TaskType *taskA = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                        taskPeriod:nil
                                                              name:@"CTaskA"
                                                               uri:@"uriA"];
            
            TaskType *taskB = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                        taskPeriod:nil
                                                              name:@"ATaskB"
                                                               uri:@"uriB"];
            
            
            TaskType *taskC = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                        taskPeriod:nil
                                                              name:@"BTaskC"
                                                               uri:@"uriC"];
            
            
            [subject storeTasks:@[taskA,taskB,taskC]];
            
            
            TaskType *recentTaskA = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                              taskPeriod:nil
                                                                    name:@"DTaskD"
                                                                     uri:@"uriD"];
            
            TaskType *recentTaskB = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                              taskPeriod:nil
                                                                    name:@"ETaskE"
                                                                     uri:@"uriE"];
            
            [subject storeTasks:@[recentTaskA,recentTaskB]];
            
            [subject getAllTasksForProjectUri:@"project-uri"] should equal(@[noneTask,taskB,taskC,taskA,recentTaskA,recentTaskB]);
        });
    });
    
    describe(@"-getTasksWithMatchingText:projectUri:", ^{
        
        it(@"should return all Task Types matching the text sorted ascending", ^{

            TaskType *noneTaskA = [[TaskType alloc] initWithProjectUri:@"project-uri" taskPeriod:nil name:RPLocalizedString(@"None", @"") uri:nil];

            TaskType *noneTaskB = [[TaskType alloc] initWithProjectUri:@"new-project-uri" taskPeriod:nil name:RPLocalizedString(@"None", @"") uri:nil];

            TaskType *taskA = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                        taskPeriod:nil
                                                              name:@"Apple"
                                                               uri:@"uriA"];
            
            TaskType *taskB = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                        taskPeriod:nil
                                                              name:@"Orange"
                                                               uri:@"uriB"];
            
            
            TaskType *taskC = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                        taskPeriod:nil
                                                              name:@"Pineapple"
                                                               uri:@"uriC"];
            
            TaskType *taskD = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                        taskPeriod:nil
                                                              name:@"Grape"
                                                               uri:@"uriD"];
            
            TaskType *taskE = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                        taskPeriod:nil
                                                              name:@"Kiwi"
                                                               uri:@"uriE"];
            
            
            TaskType *taskF = [[TaskType alloc] initWithProjectUri:@"new-project-uri"
                                                        taskPeriod:nil
                                                              name:@"Strawberry"
                                                               uri:@"uriF"];
            [subject storeTasks:@[taskA,taskB,taskC,taskD,taskE,taskF]];
            
            [subject getTasksWithMatchingText:@"apple" projectUri:@"project-uri"] should equal(@[noneTaskA,taskA,taskC]);
            [subject getTasksWithMatchingText:@"berry" projectUri:@"project-uri"] should be_nil;
            [subject getTasksWithMatchingText:@"berry" projectUri:@"new-project-uri"] should equal(@[noneTaskB,taskF]);
            
        });
    });
    
    describe(@"-deleteAllTasksForProjectWithUri", ^{
        
        __block TaskType *taskA;
        __block TaskType *taskB;
        __block TaskType *taskC;
        beforeEach(^{
            taskA = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                              taskPeriod:nil
                                                    name:@"taskname"
                                                     uri:@"taskuri"];
            
            taskB = [[TaskType alloc] initWithProjectUri:@"some-project-uri"
                                              taskPeriod:nil
                                                    name:@"Strawberry"
                                                     uri:@"uriF"];
            
            taskC = [[TaskType alloc] initWithProjectUri:@"another-project-uri"
                                              taskPeriod:nil
                                                    name:@"Strawberry"
                                                     uri:@"uriF"];
        });
        beforeEach(^{
            [subject storeTasks:@[taskA,taskB,taskC]];
            [subject deleteAllTasksForProjectWithUri:@"project-uri"];
            
        });
        
        it(@"should remove all Task types", ^{
            [subject getAllTasksForProjectUri:@"project-uri"] should be_nil;
            sqlLiteStore should have_received(@selector(deleteRowWithArgs:)).with(@{@"project_uri": @"project-uri"});
        });
    });
    
    describe(@"As a <DoorKeeperObserver>", ^{
        beforeEach(^{
            TaskType *taskX = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                        taskPeriod:nil
                                                              name:@"Strawberry"
                                                               uri:@"uriF"];
            
            TaskType *taskF = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                        taskPeriod:nil
                                                              name:@"Strawberry"
                                                               uri:@"uriF"];
            [subject storeTasks:@[taskX,taskF]];
            
            userSession stub_method(@selector(currentUserURI)).again().and_return(@"user:uri:new");
            
            [subject doorKeeperDidLogOut:nil];
        });
        
        it(@"should remove all Client types", ^{
            [subject getAllTasksForProjectUri:nil] should be_nil;
        });
    });
    
    describe(@"-getTaskInfoForUri:", ^{
        __block TaskType *expectedTask;
        __block TaskType *task;
        
        beforeEach(^{
            task = [[TaskType alloc]initWithProjectUri:@"project-uri"
                                            taskPeriod:nil
                                                  name:@"task-name"
                                                   uri:@"task-uri"];
            [subject storeTasks:@[task]];
            
            [sqlLiteStore reset_sent_messages];
            expectedTask = [subject getTaskInfoForUri:@"task-uri"];
        });
        
        it(@"should ask sqlite store for the client info", ^{
            sqlLiteStore should have_received(@selector(readAllRowsInAscendingWithArgs:orderedBy:)).with(@{@"user_uri": @"user:uri",
                                                                                      @"uri":@"task-uri"},@"name");
        });
        
        it(@"should return the stored client correctly ", ^{
            expectedTask should equal(task);
        });
    });
});

SPEC_END
