#import <Cedar/Cedar.h>
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

SPEC_BEGIN(TaskStorageSpec)

describe(@"TaskStorage", ^{
    __block TaskStorage *subject;
    __block NSUserDefaults *userDefaults;
    __block DoorKeeper *doorKeeper;
    __block SQLiteTableStore<CedarDouble> *sqlLiteStore;
    __block id<UserSession> userSession;
    __block UserPermissionsStorage *userPermissionsStorage;

    beforeEach(^{

        sqlLiteStore = (id)[[SQLiteTableStore alloc] initWithSqliteDatabaseConnection:[[SQLiteDatabaseConnection alloc] init]
                                                                   queryStringBuilder:[[QueryStringBuilder alloc] init]
                                                                         databaseName:@"Test"
                                                                            tableName:@"user_task_types"];
        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
        doorKeeper = nice_fake_for([DoorKeeper class]);
        userDefaults = nice_fake_for([NSUserDefaults class]);
        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);

        subject = [[TaskStorage alloc] initWithUserPermissionsStorage:userPermissionsStorage
                                                          sqliteStore:sqlLiteStore
                                                         userDefaults:userDefaults
                                                          userSession:userSession
                                                           doorKeeper:doorKeeper];

        spy_on(sqlLiteStore);

        [subject setUpWithUserUri:@"some:user_uri"];

    });


    describe(@"-lastDownloadedPageNumber", ^{
        context(@"user context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"some:user_uri");
            });
            it(@"should return 1 if there was no last Downloaded PageNumber", ^{
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
                lastDownloadedPageNumber should equal(@1);
            });

            it(@"should return correctly stored last Downloaded PageNumber", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedTaskPageNumber").and_return(@4);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
                lastDownloadedPageNumber should equal(@4);
            });

            it(@"should return correctly stored last Downloaded PageNumber For User if Supervisor last Downloaded PageNumber is diffrent", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedTaskPageNumber").and_return(@4);
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedTaskPageNumber").and_return(@2);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
                lastDownloadedPageNumber should equal(@2);
            });
        });

        context(@"supervisor context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"supervisor:user_uri");
            });
            it(@"should return 1 if there was no last Downloaded PageNumber", ^{
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
                lastDownloadedPageNumber should equal(@1);
            });

            it(@"should return correctly stored last Downloaded PageNumber", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedTaskPageNumber").and_return(@4);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
                lastDownloadedPageNumber should equal(@4);
            });
        });

    });

    describe(@"-updatePageNumber", ^{
        context(@"user context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"some:user_uri");
            });
            it(@"should update last Downloaded PageNumber value with 1", ^{
                [subject updatePageNumber];
                userDefaults stub_method(@selector(setObject:forKey:)).with(@1, @"LastDownloadedTaskPageNumber");
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedTaskPageNumber").and_return(@1);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
                lastDownloadedPageNumber should equal(@1);
            });

            it(@"should update last Downloaded PageNumber value correctly ", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedTaskPageNumber").and_return(@4);
                userDefaults stub_method(@selector(setObject:forKey:)).with(@5, @"LastDownloadedTaskPageNumber");
                [subject updatePageNumber];
                userDefaults stub_method(@selector(objectForKey:)).again().with(@"LastDownloadedTaskPageNumber").and_return(@5);

                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
                lastDownloadedPageNumber should equal(@5);
            });
        });

        context(@"supervisor context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"supervisor:user_uri");
            });
            it(@"should update last Downloaded PageNumber value with 1", ^{
                [subject updatePageNumber];
                userDefaults stub_method(@selector(setObject:forKey:)).with(@1, @"SupervisorLastDownloadedTaskPageNumber");
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedTaskPageNumber").and_return(@1);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
                lastDownloadedPageNumber should equal(@1);
            });

            it(@"should update last Downloaded PageNumber value correctly ", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedTaskPageNumber").and_return(@4);
                userDefaults stub_method(@selector(setObject:forKey:)).with(@5, @"SupervisorLastDownloadedTaskPageNumber");
                [subject updatePageNumber];
                userDefaults stub_method(@selector(objectForKey:)).again().with(@"SupervisorLastDownloadedTaskPageNumber").and_return(@5);

                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
                lastDownloadedPageNumber should equal(@5);
            });
        });


    });

    describe(@"-resetPageNumber", ^{
        context(@"user context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"some:user_uri");
            });
            it(@"should reset the last Downloaded PageNumber", ^{
                [subject resetPageNumber];
                userDefaults should have_received(@selector(removeObjectForKey:)).with(@"LastDownloadedTaskPageNumber");
            });
        });

        context(@"supervisor context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"supervisor:user_uri");
            });
            it(@"should reset the last Downloaded PageNumber", ^{
                [subject resetPageNumber];
                userDefaults should have_received(@selector(removeObjectForKey:)).with(@"SupervisorLastDownloadedTaskPageNumber");
            });
        });

    });

    describe(@"-getLastPageNumberForFilteredSearch", ^{
        context(@"user context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"some:user_uri");
            });
            it(@"should return 1 if there was no last Downloaded PageNumber", ^{
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
                lastDownloadedPageNumber should equal(@1);
            });

            it(@"should return correctly stored last Downloaded PageNumber", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedFilteredTaskPageNumber").and_return(@4);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
                lastDownloadedPageNumber should equal(@4);
            });
        });

        context(@"supervisor context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"supervisor:user_uri");
            });
            it(@"should return 1 if there was no last Downloaded PageNumber", ^{
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
                lastDownloadedPageNumber should equal(@1);
            });

            it(@"should return correctly stored last Downloaded PageNumber", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedFilteredTaskPageNumber").and_return(@4);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
                lastDownloadedPageNumber should equal(@4);
            });
        });

    });

    describe(@"-updatePageNumberForFilteredSearch", ^{
        context(@"user context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"some:user_uri");
            });
            it(@"should update last Downloaded PageNumber value with 1", ^{
                [subject updatePageNumberForFilteredSearch];
                userDefaults stub_method(@selector(setObject:forKey:)).with(@1, @"LastDownloadedFilteredTaskPageNumber");
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedFilteredTaskPageNumber").and_return(@1);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
                lastDownloadedPageNumber should equal(@1);
            });

            it(@"should update last Downloaded PageNumber value correctly ", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedFilteredTaskPageNumber").and_return(@4);
                userDefaults stub_method(@selector(setObject:forKey:)).with(@5, @"LastDownloadedFilteredTaskPageNumber");
                [subject updatePageNumber];
                userDefaults stub_method(@selector(objectForKey:)).again().with(@"LastDownloadedFilteredTaskPageNumber").and_return(@5);

                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
                lastDownloadedPageNumber should equal(@5);
            });
        });

        context(@"supervisor context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"supervisor:user_uri");
            });
            it(@"should update last Downloaded PageNumber value with 1", ^{
                [subject updatePageNumberForFilteredSearch];
                userDefaults stub_method(@selector(setObject:forKey:)).with(@1, @"SupervisorLastDownloadedFilteredTaskPageNumber");
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedFilteredTaskPageNumber").and_return(@1);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
                lastDownloadedPageNumber should equal(@1);
            });

            it(@"should update last Downloaded PageNumber value correctly ", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedFilteredTaskPageNumber").and_return(@4);
                userDefaults stub_method(@selector(setObject:forKey:)).with(@5, @"SupervisorLastDownloadedFilteredTaskPageNumber");
                [subject updatePageNumber];
                userDefaults stub_method(@selector(objectForKey:)).again().with(@"SupervisorLastDownloadedFilteredTaskPageNumber").and_return(@5);

                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
                lastDownloadedPageNumber should equal(@5);
            });
        });

    });

    describe(@"-resetPageNumberForFilteredSearch", ^{
        context(@"user context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"some:user_uri");
            });
            it(@"should reset the last Downloaded PageNumber", ^{
                [subject resetPageNumberForFilteredSearch];
                userDefaults should have_received(@selector(removeObjectForKey:)).with(@"LastDownloadedFilteredTaskPageNumber");
            });
        });

        context(@"supervisor context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"supervisor:user_uri");
            });
            it(@"should reset the last Downloaded PageNumber", ^{
                [subject resetPageNumberForFilteredSearch];
                userDefaults should have_received(@selector(removeObjectForKey:)).with(@"SupervisorLastDownloadedFilteredTaskPageNumber");
            });
        });

    });

    describe(@"-storeClients", ^{

        __block TaskType *task;
        __block TaskType *noneTask;

        context(@"When inserting a fresh client in DB", ^{
            beforeEach(^{
                Period *period = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                          endDate:[NSDate dateWithTimeIntervalSince1970:2]];
                task = [[TaskType alloc] initWithProjectUri:@"project-uri-A" taskPeriod:period name:@"task-name" uri:@"task-uri"];

                Period *nonePeriod = [[Period alloc]initWithStartDate:nil endDate:nil];
                noneTask = [[TaskType alloc] initWithProjectUri:@"project-uri-A"
                                                     taskPeriod:nonePeriod
                                                           name:@"None"
                                                            uri:nil];

                sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).with(@{@"uri": @"stored-task-uri"}).and_return(nil);
                [subject storeTasks:@[task]];
            });

            it(@"should insert the row into database", ^{
                sqlLiteStore should have_received(@selector(insertRow:)).with(@{
                                                                                @"uri":@"task-uri",
                                                                                @"name":@"task-name",
                                                                                @"project_uri":@"project-uri-A",
                                                                                @"start_date":[NSDate dateWithTimeIntervalSince1970:1],
                                                                                @"end_date":[NSDate dateWithTimeIntervalSince1970:2],
                                                                                @"user_uri":@"some:user_uri"
                                                                                });
            });

            it(@"should return the newly inserted record", ^{
                [subject getAllTasksForProjectUri:@"project-uri-A"] should equal(@[noneTask,task]);
            });
        });

        context(@"When updating a already stored client in DB", ^{

            beforeEach(^{
                Period *storedPeriod = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                                endDate:[NSDate dateWithTimeIntervalSince1970:2]];
                TaskType *storedTask = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                                 taskPeriod:storedPeriod
                                                                       name:@"stored-task-name"
                                                                        uri:@"task-uri"];

                [subject storeTasks:@[storedTask]];

                sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).with(@{@"uri": @"task-uri"}).and_return(@{
                                                                                                                    @"name": @"StoredClient",
                                                                                                                    @"uri": @"ClientUriA",
                                                                                                                    @"user_uri":@"some:user_uri"
                                                                                                                    });

                Period *period = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                          endDate:[NSDate dateWithTimeIntervalSince1970:2]];
                task = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                 taskPeriod:period
                                                       name:@"new-task-name"
                                                        uri:@"task-uri"];

                Period *nonePeriod = [[Period alloc]initWithStartDate:nil endDate:nil];
                noneTask = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                     taskPeriod:nonePeriod
                                                           name:@"None"
                                                            uri:nil];


                [subject storeTasks:@[task]];
            });

            it(@"should update the row in database", ^{
                sqlLiteStore should have_received(@selector(updateRow:whereClause:)).with(@{
                                                                                @"uri":@"task-uri",
                                                                                @"name":@"new-task-name",
                                                                                @"project_uri":@"project-uri",
                                                                                @"start_date":[NSDate dateWithTimeIntervalSince1970:1],
                                                                                @"end_date":[NSDate dateWithTimeIntervalSince1970:2],
                                                                                @"user_uri":@"some:user_uri"
                                                                                },@{@"uri": @"task-uri", @"user_uri": @"some:user_uri"});
            });

            it(@"should return the newly updated record", ^{
                [subject getAllTasksForProjectUri:@"project-uri"] should equal(@[noneTask,task]);
            });

        });

    });

    describe(@"-getAllTasks", ^{

        it(@"should return all Task Types", ^{

            Period *periodA = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            TaskType *taskA = [[TaskType alloc] initWithProjectUri:@"project-uri-A"
                                                        taskPeriod:periodA
                                                              name:@"TaskA"
                                                               uri:@"uriA"];
            Period *periodB = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            TaskType *taskB = [[TaskType alloc] initWithProjectUri:@"project-uri-B"
                                                        taskPeriod:periodB
                                                              name:@"TaskB"
                                                               uri:@"uriB"];
            Period *periodC = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            TaskType *taskC = [[TaskType alloc] initWithProjectUri:@"project-uri-C"
                                                        taskPeriod:periodC
                                                              name:@"TaskC"
                                                               uri:@"uriC"];
            [subject storeTasks:@[taskA,taskB,taskC]];

            Period *nonePeriod = [[Period alloc]initWithStartDate:nil endDate:nil];
            TaskType *noneTask = [[TaskType alloc] initWithProjectUri:@"project-uri-A"
                                                 taskPeriod:nonePeriod
                                                       name:@"None"
                                                        uri:nil];

            [subject getAllTasksForProjectUri:@"project-uri-A"] should equal(@[noneTask,taskA]);
        });

        it(@"should return older Task Types along with recent Task Types", ^{
            Period *periodA = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            TaskType *taskA = [[TaskType alloc] initWithProjectUri:@"project-uri-A"
                                                        taskPeriod:periodA
                                                              name:@"TaskA"
                                                               uri:@"uriA"];

            Period *periodB = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            TaskType *taskB = [[TaskType alloc] initWithProjectUri:@"project-uri-B"
                                                        taskPeriod:periodB
                                                              name:@"TaskB"
                                                               uri:@"uriB"];


            Period *periodC = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            TaskType *taskC = [[TaskType alloc] initWithProjectUri:@"project-uri-C"
                                                        taskPeriod:periodC
                                                              name:@"TaskC"
                                                               uri:@"uriC"];


            [subject storeTasks:@[taskA,taskB,taskC]];


            Period *periodD = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            TaskType *recentTaskA = [[TaskType alloc] initWithProjectUri:@"project-uri-D"
                                                              taskPeriod:periodD
                                                                    name:@"TaskD"
                                                                     uri:@"uriD"];

            Period *periodE = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            TaskType *recentTaskB = [[TaskType alloc] initWithProjectUri:@"project-uri-E"
                                                              taskPeriod:periodE
                                                                    name:@"TaskE"
                                                                     uri:@"uriE"];

            [subject storeTasks:@[recentTaskA,recentTaskB]];

            Period *nonePeriod = [[Period alloc]initWithStartDate:nil endDate:nil];
            TaskType *noneTask = [[TaskType alloc] initWithProjectUri:@"project-uri-A"
                                                 taskPeriod:nonePeriod
                                                       name:@"None"
                                                        uri:nil];

            [subject getAllTasksForProjectUri:@"project-uri-A"] should equal(@[noneTask,taskA]);
        });
    });

   describe(@"-getTasksWithMatchingText:projectUri:", ^{

        __block TaskType *taskA;
        __block TaskType *taskB;
        __block TaskType *taskC;
        __block TaskType *taskD;
        __block TaskType *taskE;
        __block TaskType *taskF;
       __block TaskType *taskG;

        beforeEach(^{
            Period *periodA = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            taskA = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                        taskPeriod:periodA
                                                              name:@"Apple"
                                                               uri:@"uriA"];

            Period *periodB = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            taskB = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                        taskPeriod:periodB
                                                              name:@"Orange"
                                                               uri:@"uriB"];


            Period *periodC = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            taskC = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                        taskPeriod:periodC
                                                              name:@"Pineapple"
                                                               uri:@"uriC"];

            Period *periodD = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            taskD = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                        taskPeriod:periodD
                                                              name:@"Grape"
                                                               uri:@"uriD"];

            Period *periodE = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            taskE = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                        taskPeriod:periodE
                                                              name:@"Kiwi"
                                                               uri:@"uriE"];


            Period *periodF = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            taskF = [[TaskType alloc] initWithProjectUri:@"new-project-uri"
                                                        taskPeriod:periodF
                                                              name:@"Strawberry"
                                                               uri:@"uriF"];

            Period *periodG = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            taskG = [[TaskType alloc] initWithProjectUri:@"new-project-uri"
                                              taskPeriod:periodG
                                                    name:@"Testberry"
                                                     uri:@"uriF"];
        });

        it(@"should return all Task Types matching the text", ^{


            [subject storeTasks:@[taskA,taskB,taskC,taskD,taskE,taskF,taskG]];

            Period *nonePeriod = [[Period alloc]initWithStartDate:nil endDate:nil];
            TaskType *noneTask = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                           taskPeriod:nonePeriod
                                                                 name:@"None"
                                                                  uri:nil];

            TaskType *noneTaskB = [[TaskType alloc] initWithProjectUri:@"new-project-uri"
                                                           taskPeriod:nonePeriod
                                                                 name:@"None"
                                                                  uri:nil];

            [subject getTasksWithMatchingText:@"apple" projectUri:@"project-uri"] should equal(@[noneTask,taskA,taskC]);
            [subject getTasksWithMatchingText:@"berry" projectUri:@"project-uri"] should be_nil;
            [subject getTasksWithMatchingText:@"berry" projectUri:@"new-project-uri"] should equal(@[noneTaskB,taskG]);

        });


        it(@"should ask sqlite store for the Task info when Project is not nil", ^{
            [subject storeTasks:@[taskA,taskB,taskC,taskD,taskE,taskF,taskG]];
            [subject getTasksWithMatchingText:@"berry" projectUri:@"project-uri"];
            sqlLiteStore should have_received(@selector(readAllRowsFromColumn:where:pattern:)).with(@"name",@{@"project_uri": @"project-uri", @"user_uri": @"some:user_uri"},@"berry");
        });
    });

    describe(@"-deleteAllTasksForProjectWithUri", ^{

        __block TaskType *taskA;
        __block TaskType *taskB;
        __block TaskType *taskC;
        beforeEach(^{
            Period *periodA = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            taskA = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                              taskPeriod:periodA
                                                    name:@"taskname"
                                                     uri:@"taskuri"];
            Period *periodB = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            taskB = [[TaskType alloc] initWithProjectUri:@"some-project-uri"
                                              taskPeriod:periodB
                                                    name:@"Strawberry"
                                                     uri:@"uriF"];

            Period *periodC = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            taskC = [[TaskType alloc] initWithProjectUri:@"another-project-uri"
                                              taskPeriod:periodC
                                                    name:@"Strawberry"
                                                     uri:@"uriF"];
        });

        context(@"user context", ^{

            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"some:user_uri");
                [subject storeTasks:@[taskA,taskB,taskC]];
                [subject deleteAllTasksForProjectWithUri:@"project-uri"];

            });

            it(@"should remove all Task types", ^{
                [subject getAllTasksForProjectUri:@"project-uri"] should be_nil;
                sqlLiteStore should have_received(@selector(deleteRowWithArgs:)).with(@{@"project_uri": @"project-uri"});
            });
        });

        context(@"supervisor context", ^{

            beforeEach(^{
                 userSession stub_method(@selector(currentUserURI)).again().and_return(@"supervisor:user_uri");
                [subject storeTasks:@[taskA,taskB,taskC]];
                [subject deleteAllTasksForProjectWithUri:@"project-uri"];

            });

            it(@"should remove all Task types", ^{
                [subject getAllTasksForProjectUri:@"project-uri"] should be_nil;
                sqlLiteStore should have_received(@selector(deleteRowWithStringArgs:)).with(@"project_uri = 'project-uri' AND user_uri != 'supervisor:user_uri'");
            });
        });


    });

    describe(@"As a <DoorKeeperObserver>", ^{
        beforeEach(^{
            Period *periodX = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            TaskType *taskX = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                        taskPeriod:periodX
                                                              name:@"Strawberry"
                                                               uri:@"uriF"];

            Period *periodF = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            TaskType *taskF = [[TaskType alloc] initWithProjectUri:@"project-uri"
                                                        taskPeriod:periodF
                                                              name:@"Strawberry"
                                                               uri:@"uriF"];
            [subject storeTasks:@[taskX,taskF]];
            
            [subject setUpWithUserUri:@"user:uri:new"];
            
            [subject doorKeeperDidLogOut:nil];
        });
        
        it(@"should remove all Client types", ^{
            [subject getAllTasksForProjectUri:nil] should be_nil;
        });
    });

});

SPEC_END
