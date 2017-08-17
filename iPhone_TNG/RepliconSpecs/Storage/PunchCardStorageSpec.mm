#import <Cedar/Cedar.h>
#import "PunchCardStorage.h"
#import "SQLiteTableStore.h"
#import "SQLiteDatabaseConnection.h"
#import "QueryStringBuilder.h"
#import "ClientType.h"
#import "ProjectType.h"
#import "PunchCardObject.h"
#import "TaskType.h"
#import "ClientStorage.h"
#import "TaskStorage.h"
#import "ProjectStorage.h"
#import "DateProvider.h"
#import "InjectorProvider.h"
#import "Punch.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PunchCardStorageSpec)

describe(@"PunchCardStorage", ^{
    __block PunchCardStorage *subject;
    __block ClientStorage *clientStorage;
    __block ProjectStorage *projectStorage;
    __block TaskStorage *taskStorage;
    __block NSUserDefaults *userDefaults;
    __block DoorKeeper *doorKeeper;
    __block SQLiteTableStore<CedarDouble> *sqlLiteStore;
    __block id<UserSession> userSession;
    __block DateProvider *dateProvider;
    __block id <BSBinder,BSInjector> injector;

    beforeEach(^{

        injector = [InjectorProvider injector];
        sqlLiteStore = (id)[[SQLiteTableStore alloc] initWithSqliteDatabaseConnection:[[SQLiteDatabaseConnection alloc] init]
                                                                   queryStringBuilder:[[QueryStringBuilder alloc] init]
                                                                         databaseName:@"Test"
                                                                            tableName:@"punch_cards_user"];
        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
        doorKeeper = nice_fake_for([DoorKeeper class]);
        userDefaults = nice_fake_for([NSUserDefaults class]);

        clientStorage = nice_fake_for([ClientStorage class]);
        projectStorage = nice_fake_for([ProjectStorage class]);
        taskStorage = nice_fake_for([TaskStorage class]);
        dateProvider = nice_fake_for([DateProvider class]);

        subject = [[PunchCardStorage alloc] initWithSqliteStore:sqlLiteStore
                                                   dateProvider:dateProvider
                                                    userSession:userSession
                                                     doorKeeper:doorKeeper];
        spy_on(subject);
        spy_on(sqlLiteStore);


    });

    context(@"-storePunchCard when don't have duplicate entries", ^{
        __block PunchCardObject *punchCardObjectA;
        __block PunchCardObject *punchCardObjectB;
        __block NSDate *expectedDateA;
        __block NSDate *expectedDateB;


        beforeEach(^{

            ClientType *clientA = [[ClientType alloc]initWithName:@"client-name-A" uri:@"client-uri-A"];

            ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:nil
                                                                                     clientType:clientA
                                                                                           name:@"project-name-A"
                                                                                            uri:@"project-uri-A"];

            TaskType *taskA = [[TaskType alloc]initWithProjectUri:@"project-uri-A"
                                                       taskPeriod:nil
                                                             name:@"task-name-A"
                                                              uri:@"task-uri-A"];;

            punchCardObjectA = [[PunchCardObject alloc]
                                                 initWithClientType:clientA
                                                        projectType:projectA
                                                      oefTypesArray:nil
                                                          breakType:NULL
                                                           taskType:taskA
                                                           activity:NULL
                                                                uri:@"card-uri-A"];


            ClientType *clientB = [[ClientType alloc]initWithName:@"client-name-B" uri:@"client-uri-B"];

            ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:nil
                                                                                     clientType:clientB
                                                                                           name:@"project-name-B"
                                                                                            uri:@"project-uri-B"];

            TaskType *taskB = [[TaskType alloc]initWithProjectUri:@"project-uri-B"
                                                       taskPeriod:nil
                                                             name:@"task-name-B"
                                                              uri:@"task-uri-B"];;

            punchCardObjectA = [[PunchCardObject alloc]
                                                 initWithClientType:clientA
                                                        projectType:projectA
                                                      oefTypesArray:nil
                                                          breakType:NULL
                                                           taskType:taskA
                                                           activity:NULL
                                                                uri:@"card-uri-A"];
            punchCardObjectA.isValidPunchCard = YES;

            punchCardObjectB = [[PunchCardObject alloc]
                                                 initWithClientType:clientB
                                                        projectType:projectB
                                                      oefTypesArray:nil
                                                          breakType:NULL
                                                           taskType:taskB
                                                           activity:NULL
                                                                uri:@"card-uri-B"];
            punchCardObjectB.isValidPunchCard = YES;

            expectedDateA = [NSDate dateWithTimeIntervalSinceReferenceDate:0];

                                dateProvider stub_method(@selector(date)).and_return(expectedDateA);
            [subject storePunchCard:punchCardObjectA];

            expectedDateB = [NSDate dateWithTimeIntervalSinceReferenceDate:1];
            dateProvider stub_method(@selector(date)).again().and_return(expectedDateB);
            [subject storePunchCard:punchCardObjectB];

        });

        it(@"should insert row into sqliteStore correctly", ^{

            NSDictionary *expectedDictionary = @{@"client_uri": @"client-uri-A",
                                                 @"project_uri": @"project-uri-A",
                                                 @"task_uri": @"task-uri-A",
                                                 @"client_name": @"client-name-A",
                                                 @"project_name": @"project-name-A",
                                                 @"task_name": @"task-name-A",
                                                 @"uri":@"card-uri-A",
                                                 @"user_uri":@"user:uri",
                                                 @"date":expectedDateA,
                                                 @"hasTasksAvailableForTimeAllocation":@1,
                                                 @"is_valid_punch_card":@1

                                                 };

            sqlLiteStore should have_received(@selector(insertRow:)).with(expectedDictionary);
        });

        it(@"should insert row into sqliteStore correctly", ^{

            NSDictionary *expectedDictionary = @{@"client_uri": @"client-uri-B",
                                                 @"project_uri": @"project-uri-B",
                                                 @"task_uri": @"task-uri-B",
                                                 @"client_name": @"client-name-B",
                                                 @"project_name": @"project-name-B",
                                                 @"task_name": @"task-name-B",
                                                 @"uri":@"card-uri-B",
                                                 @"user_uri":@"user:uri",
                                                 @"date":expectedDateB,
                                                 @"hasTasksAvailableForTimeAllocation":@1,
                                                 @"is_valid_punch_card":@1
                                                 };

            sqlLiteStore should have_received(@selector(insertRow:)).with(expectedDictionary);
        });

        it(@"should return the all inserted record", ^{
            [subject getPunchCards] should equal(@[punchCardObjectB,punchCardObjectA]);
        });
    });
    
    context(@"-storePunchCard when useruri set to punchcardObject", ^{
        __block PunchCardObject *punchCardObjectA;
        __block NSDate *expectedDateA;
        
        
        beforeEach(^{
            
            ClientType *clientA = [[ClientType alloc]initWithName:@"client-name-A" uri:@"client-uri-A"];
            
            ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:nil
                                                                                     clientType:clientA
                                                                                           name:@"project-name-A"
                                                                                            uri:@"project-uri-A"];
            
            TaskType *taskA = [[TaskType alloc]initWithProjectUri:@"project-uri-A"
                                                       taskPeriod:nil
                                                             name:@"task-name-A"
                                                              uri:@"task-uri-A"];;
            
            punchCardObjectA = [[PunchCardObject alloc]
                                initWithClientType:clientA
                                projectType:projectA
                                oefTypesArray:nil
                                breakType:NULL
                                taskType:taskA
                                activity:NULL
                                uri:@"card-uri-A"];

            punchCardObjectA.userUri = @"my-special-user-uri-A";
            

            punchCardObjectA.isValidPunchCard = YES;

            
            expectedDateA = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
            
            dateProvider stub_method(@selector(date)).and_return(expectedDateA);
            [subject storePunchCard:punchCardObjectA];
            
        });
        
        it(@"should insert row into sqliteStore correctly", ^{
            
            NSDictionary *expectedDictionary = @{@"client_uri": @"client-uri-A",
                                                 @"project_uri": @"project-uri-A",
                                                 @"task_uri": @"task-uri-A",
                                                 @"client_name": @"client-name-A",
                                                 @"project_name": @"project-name-A",
                                                 @"task_name": @"task-name-A",
                                                 @"uri":@"card-uri-A",
                                                 @"user_uri":@"my-special-user-uri-A",
                                                 @"date":expectedDateA,
                                                 @"hasTasksAvailableForTimeAllocation":@1,
                                                 @"is_valid_punch_card":@1
                                                 };
            
            sqlLiteStore should have_received(@selector(insertRow:)).with(expectedDictionary);
        });

    });
    
    context(@"-storePunchCard when useruri is empty and set to punchcardObject", ^{
        __block PunchCardObject *punchCardObjectA;
        __block NSDate *expectedDateA;
        
        
        beforeEach(^{
            
            ClientType *clientA = [[ClientType alloc]initWithName:@"client-name-A" uri:@"client-uri-A"];
            
            ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:nil
                                                                                     clientType:clientA
                                                                                           name:@"project-name-A"
                                                                                            uri:@"project-uri-A"];
            
            TaskType *taskA = [[TaskType alloc]initWithProjectUri:@"project-uri-A"
                                                       taskPeriod:nil
                                                             name:@"task-name-A"
                                                              uri:@"task-uri-A"];;
            
            punchCardObjectA = [[PunchCardObject alloc]
                                initWithClientType:clientA
                                projectType:projectA
                                oefTypesArray:nil
                                breakType:NULL
                                taskType:taskA
                                activity:NULL
                                uri:@"card-uri-A"];
            

            punchCardObjectA.userUri = @"";
            punchCardObjectA.isValidPunchCard = YES;

            expectedDateA = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
            
            dateProvider stub_method(@selector(date)).and_return(expectedDateA);
            [subject storePunchCard:punchCardObjectA];
            
        });
        
        it(@"should insert row into sqliteStore correctly", ^{
            
            NSDictionary *expectedDictionary = @{@"client_uri": @"client-uri-A",
                                                 @"project_uri": @"project-uri-A",
                                                 @"task_uri": @"task-uri-A",
                                                 @"client_name": @"client-name-A",
                                                 @"project_name": @"project-name-A",
                                                 @"task_name": @"task-name-A",
                                                 @"uri":@"card-uri-A",
                                                 @"user_uri":@"user:uri",
                                                 @"date":expectedDateA,
                                                 @"hasTasksAvailableForTimeAllocation":@1,
                                                 @"is_valid_punch_card":@1
                                                 };
            
            sqlLiteStore should have_received(@selector(insertRow:)).with(expectedDictionary);
        });
        
    });
    
    context(@"-storePunchCard when trying to add duplicate entries", ^{
        __block PunchCardObject *punchCardObjectA;
        __block PunchCardObject *punchCardObjectB;
        __block NSDate *expectedDateA;
        __block NSDate *expectedDateB;
        
        beforeEach(^{
            ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
            
            
            TaskType *task = [[TaskType alloc]initWithProjectUri:@"project-uri"
                                                       taskPeriod:nil
                                                             name:@"task-name"
                                                              uri:@"task-uri"];;

            ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:nil
                                                                                     clientType:client
                                                                                           name:@"project-name"
                                                                                            uri:@"project-uri"];
            
            punchCardObjectA = [[PunchCardObject alloc]
                                                 initWithClientType:client
                                                        projectType:project
                                                      oefTypesArray:nil
                                                          breakType:nil
                                                           taskType:task
                                                           activity:nil
                                                                uri:@"card-uri-A"];
            punchCardObjectA.isValidPunchCard = YES;

            punchCardObjectB = [[PunchCardObject alloc]
                                                 initWithClientType:client
                                                        projectType:project
                                                      oefTypesArray:nil
                                                          breakType:nil
                                                           taskType:task
                                                           activity:nil
                                                                uri:@"card-uri-B"];

            punchCardObjectB.isValidPunchCard = YES;
            
            
            expectedDateA = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
            dateProvider stub_method(@selector(date)).and_return(expectedDateA);
            [subject storePunchCard:punchCardObjectA];
            
            expectedDateB = [NSDate dateWithTimeIntervalSinceReferenceDate:1];
            dateProvider stub_method(@selector(date)).again().and_return(expectedDateB);
            [subject storePunchCard:punchCardObjectB];
            
        });

        it(@"should insert row into sqliteStore correctly", ^{

            NSDictionary *expectedDictionary = @{@"client_uri": @"client-uri",
                                                 @"project_uri": @"project-uri",
                                                 @"task_uri": @"task-uri",
                                                 @"client_name": @"client-name",
                                                 @"project_name": @"project-name",
                                                 @"task_name": @"task-name",
                                                 @"uri":@"card-uri-A",
                                                 @"user_uri":@"user:uri",
                                                 @"date":expectedDateA,
                                                 @"hasTasksAvailableForTimeAllocation":@0,
                                                 @"is_valid_punch_card":@1
                                                 };

            sqlLiteStore should have_received(@selector(insertRow:)).with(expectedDictionary);
        });

        it(@"should insert row into sqliteStore correctly", ^{

            NSDictionary *expectedDictionary = @{@"client_uri": @"client-uri",
                                                 @"project_uri": @"project-uri",
                                                 @"task_uri": @"task-uri",
                                                 @"client_name": @"client-name",
                                                 @"project_name": @"project-name",
                                                 @"task_name": @"task-name",
                                                 @"uri":@"card-uri-B",
                                                 @"user_uri":@"user:uri",
                                                 @"date":expectedDateB,
                                                 @"hasTasksAvailableForTimeAllocation":@0,
                                                 @"is_valid_punch_card":@1
                                                 };

            sqlLiteStore should have_received(@selector(insertRow:)).with(expectedDictionary);
        });
        
        it(@"should return the newly inserted record", ^{
            [subject getPunchCards] should equal(@[punchCardObjectB]);
        });
    });

    describe(@"-storePunchCard when trying to add blank entries", ^{
        __block PunchCardObject *punchCardObject;
        __block NSDate *expectedDate;
        
        beforeEach(^{
            
            
            punchCardObject = [[PunchCardObject alloc]
                                initWithClientType:nil
                                projectType:nil
                                oefTypesArray:nil
                                breakType:nil
                                taskType:nil
                                activity:nil
                                uri:@"card-uri"];
            
            
            expectedDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
            dateProvider stub_method(@selector(date)).and_return(expectedDate);
            [subject storePunchCard:punchCardObject];
        });
        
        it(@"should not insert row into sqliteStore", ^{
            
            NSDictionary *expectedDictionary = @{@"client_uri": @"",
                                                 @"project_uri": @"",
                                                 @"task_uri": @"",
                                                 @"client_name": @"",
                                                 @"project_name": @"",
                                                 @"task_name": @"",
                                                 @"uri":@"card-uri-A",
                                                 @"user_uri":@"user:uri",
                                                 @"date":expectedDate,
                                                 @"hasTasksAvailableForTimeAllocation":@0,
                                                 @"is_valid_punch_card":@1
                                                 };
            
            sqlLiteStore should_not have_received(@selector(insertRow:)).with(expectedDictionary);
        });
        
        it(@"should not return any entry", ^{
            [subject getPunchCards] should equal(@[]);
        });
    });

    describe(@"-storePunchCard when punch card is invalid", ^{
        __block PunchCardObject *punchCardObject;
        __block NSDate *expectedDate;

        beforeEach(^{


            ClientType *clientA = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];

            ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:nil
                                                                                     clientType:clientA
                                                                                           name:@"project-name"
                                                                                            uri:@"project-uri"];

            TaskType *taskA = [[TaskType alloc]initWithProjectUri:@"project-uri"
                                                       taskPeriod:nil
                                                             name:@"task-name"
                                                              uri:@"task-uri"];;

            punchCardObject = [[PunchCardObject alloc]
                                initWithClientType:clientA
                                projectType:projectA
                                oefTypesArray:nil
                                breakType:NULL
                                taskType:taskA
                                activity:NULL
                                uri:@"card-uri-A"];

            punchCardObject.isValidPunchCard = NO;


            expectedDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
            dateProvider stub_method(@selector(date)).and_return(expectedDate);
            [subject storePunchCard:punchCardObject];
        });

        it(@"should not insert row into sqliteStore", ^{

            NSDictionary *expectedDictionary = @{@"client_uri": @"client-uri",
                                                 @"project_uri": @"project-uri",
                                                 @"task_uri": @"task-uri",
                                                 @"client_name": @"client-name",
                                                 @"project_name": @"project-name",
                                                 @"task_name": @"task-name",
                                                 @"uri":@"card-uri-A",
                                                 @"user_uri":@"user:uri",
                                                 @"date":expectedDate,
                                                 @"hasTasksAvailableForTimeAllocation":@1,
                                                 @"is_valid_punch_card":@0
                                                 };

            sqlLiteStore should have_received(@selector(insertRow:)).with(expectedDictionary);
        });

        it(@"should not return any entry", ^{
            PunchCardObject *punchcard = [[subject getPunchCards] objectAtIndex:0];
            punchcard.isValidPunchCard should be_falsy;
        });
    });

    describe(@"-deletePunchCard", ^{
        __block PunchCardObject *punchCardObjectA;
         __block PunchCardObject *punchCardObjectB;
        
        context(@"-Test when tasktype is nil", ^{
            
            beforeEach(^{
                NSDate *expectedDateA = [NSDate dateWithTimeIntervalSince1970:0];
                dateProvider stub_method(@selector(date)).and_return(expectedDateA);
                ClientType *client = [[ClientType alloc]initWithName:@"client-name"
                                                                 uri:@"client-uri"];
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"project-name"
                                                                                               uri:@"project-uri"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"project-uri"
                                                          taskPeriod:nil
                                                                name:@"task-name"
                                                                 uri:@"task-uri"];

                punchCardObjectA = [[PunchCardObject alloc]
                                                initWithClientType:client
                                                       projectType:project
                                                     oefTypesArray:nil
                                                         breakType:NULL
                                                          taskType:task
                                                          activity:NULL
                                                               uri:@"card-uri-A"];
                punchCardObjectB = [[PunchCardObject alloc]
                                                initWithClientType:client
                                                       projectType:project
                                                     oefTypesArray:nil
                                                         breakType:NULL
                                                          taskType:task
                                                          activity:NULL
                                                               uri:@"card-uri-B"];

                
                [subject storePunchCard:punchCardObjectA];
                [subject storePunchCard:punchCardObjectB];
                [subject deletePunchCard:punchCardObjectA];
            });
            
            it(@"should remove all punch cards", ^{
                [subject getPunchCards] should equal(@[punchCardObjectB]);
            });
            
        });
        
        context(@"-Test when project type is nil", ^{
            
            beforeEach(^{
                NSDate *expectedDateA = [NSDate dateWithTimeIntervalSince1970:0];
                dateProvider stub_method(@selector(date)).and_return(expectedDateA);
                ClientType *clientA = [[ClientType alloc]initWithName:@"client-name-A"
                                                                  uri:@"client-uri-A"];
                ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                            isTimeAllocationAllowed:NO
                                                                                      projectPeriod:nil
                                                                                         clientType:clientA
                                                                                               name:@"project-name-A"
                                                                                                uri:@"project-uri-A"];
                TaskType *taskA = [[TaskType alloc]initWithProjectUri:@"project-uri-A"
                                                           taskPeriod:nil
                                                                 name:@"task-name-A"
                                                                  uri:@"task-uri-A"];

                ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                            isTimeAllocationAllowed:NO
                                                                                      projectPeriod:nil
                                                                                         clientType:nil
                                                                                               name:@"project-name-B"
                                                                                                uri:@"project-uri-B"];
                TaskType *taskB = [[TaskType alloc]initWithProjectUri:@"project-uri-B"
                                                           taskPeriod:nil
                                                                 name:@"task-name-B"
                                                                  uri:@"task-uri-B"];

                punchCardObjectA = [[PunchCardObject alloc] initWithClientType:clientA projectType:projectA oefTypesArray:nil breakType:nil taskType:taskA activity:nil uri:@"card-uri-A"];
                punchCardObjectB = [[PunchCardObject alloc] initWithClientType:nil projectType:projectB oefTypesArray:nil breakType:nil taskType:taskB activity:nil uri:@"card-uri-B"];


                
                [subject storePunchCard:punchCardObjectA];
                [subject storePunchCard:punchCardObjectB];
                [subject deletePunchCard:punchCardObjectA];
            });
            
            it(@"should remove all punch cards", ^{
                [subject getPunchCards] should equal(@[punchCardObjectB]);
            });
            
        });
        
        context(@"-Test when client type is nil", ^{
            
            beforeEach(^{
                NSDate *expectedDateA = [NSDate dateWithTimeIntervalSince1970:0];
                dateProvider stub_method(@selector(date)).and_return(expectedDateA);
                ClientType *clientA = [[ClientType alloc]initWithName:@"client-name-A"
                                                                 uri:@"client-uri-A"];
                ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:clientA
                                                                                              name:@"project-name-A"
                                                                                               uri:@"project-uri-A"];
                TaskType *taskA = [[TaskType alloc]initWithProjectUri:@"project-uri-A"
                                                          taskPeriod:nil
                                                                name:@"task-name-A"
                                                                 uri:@"task-uri-A"];

                ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:nil
                                                                                              name:@"project-name-B"
                                                                                               uri:@"project-uri-B"];
                TaskType *taskB = [[TaskType alloc]initWithProjectUri:@"project-uri-B"
                                                          taskPeriod:nil
                                                                name:@"task-name-B"
                                                                 uri:@"task-uri-B"];

                punchCardObjectA = [[PunchCardObject alloc] initWithClientType:clientA projectType:projectA oefTypesArray:nil breakType:nil taskType:taskA activity:nil uri:@"card-uri-A"];
                punchCardObjectB = [[PunchCardObject alloc] initWithClientType:nil projectType:projectB oefTypesArray:nil breakType:nil taskType:taskB activity:nil uri:@"card-uri-B"];

                
                [subject storePunchCard:punchCardObjectA];
                [subject storePunchCard:punchCardObjectB];
                [subject deletePunchCard:punchCardObjectA];
            });
            
            it(@"should remove all punch cards", ^{
                [subject getPunchCards] should equal(@[punchCardObjectB]);
            });
            
        });
        
    });

    context(@"-getPunchCardsExcludingPunch", ^{
        __block PunchCardObject *punchCardObjectA;
        __block PunchCardObject *punchCardObjectB;

        __block id <Punch> punch;
        __block NSDate *expectedDateA;
        __block NSDate *expectedDateB;

        beforeEach(^{
            punch = nice_fake_for(@protocol(Punch));

            ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:nil
                                                                                     clientType:nil
                                                                                           name:@"project-name-A"
                                                                                            uri:@"project-uri-A"];

            TaskType *taskA = [[TaskType alloc]initWithProjectUri:@"project-uri-A"
                                                       taskPeriod:nil
                                                             name:@"task-name-A"
                                                              uri:@"task-uri-A"];

            punchCardObjectA = [[PunchCardObject alloc]
                                                 initWithClientType:nil
                                                        projectType:projectA
                                                      oefTypesArray:nil
                                                          breakType:NULL
                                                           taskType:taskA
                                                           activity:NULL
                                                                uri:@"card-uri-A"];


            ClientType *clientB = [[ClientType alloc]initWithName:@"client-name-B" uri:@"client-uri-B"];

            ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:nil
                                                                                     clientType:clientB
                                                                                           name:@"project-name-B"
                                                                                            uri:@"project-uri-B"];

            TaskType *taskB = [[TaskType alloc]initWithProjectUri:@"project-uri-B"
                                                       taskPeriod:nil
                                                             name:@"task-name-B"
                                                              uri:@"task-uri-B"];;

            punchCardObjectA = [[PunchCardObject alloc]
                                                 initWithClientType:nil
                                                        projectType:projectA
                                                      oefTypesArray:nil
                                                          breakType:NULL
                                                           taskType:taskA
                                                           activity:NULL
                                                                uri:@"card-uri-A"];
            punchCardObjectA.isValidPunchCard = YES;

            punchCardObjectB = [[PunchCardObject alloc]
                                                 initWithClientType:clientB
                                                        projectType:projectB
                                                      oefTypesArray:nil
                                                          breakType:NULL
                                                           taskType:taskB
                                                           activity:NULL
                                                                uri:@"card-uri-B"];

            punchCardObjectB.isValidPunchCard = YES;


            punch stub_method(@selector(client)).and_return(nil);
            punch stub_method(@selector(project)).and_return(projectA);
            punch stub_method(@selector(task)).and_return(taskA);


            expectedDateA = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
            dateProvider stub_method(@selector(date)).and_return(expectedDateA);
            [subject storePunchCard:punchCardObjectA];

            expectedDateB = [NSDate dateWithTimeIntervalSinceReferenceDate:1];
            dateProvider stub_method(@selector(date)).again().and_return(expectedDateB);
            [subject storePunchCard:punchCardObjectB];

        });

        it(@"should insert row into sqliteStore correctly", ^{

            NSDictionary *expectedDictionary = @{@"client_uri": @"",
                                                 @"project_uri": @"project-uri-A",
                                                 @"task_uri": @"task-uri-A",
                                                 @"client_name": @"",
                                                 @"project_name": @"project-name-A",
                                                 @"task_name": @"task-name-A",
                                                 @"uri":@"card-uri-A",
                                                 @"user_uri":@"user:uri",
                                                 @"date":expectedDateA,
                                                 @"hasTasksAvailableForTimeAllocation":@0,
                                                 @"is_valid_punch_card":@1
                                                 };

            sqlLiteStore should have_received(@selector(insertRow:)).with(expectedDictionary);
        });

        it(@"should insert row into sqliteStore correctly", ^{

            NSDictionary *expectedDictionary = @{@"client_uri": @"client-uri-B",
                                                 @"project_uri": @"project-uri-B",
                                                 @"task_uri": @"task-uri-B",
                                                 @"client_name": @"client-name-B",
                                                 @"project_name": @"project-name-B",
                                                 @"task_name": @"task-name-B",
                                                 @"uri":@"card-uri-B",
                                                 @"user_uri":@"user:uri",
                                                 @"date":expectedDateB,
                                                 @"hasTasksAvailableForTimeAllocation":@1,
                                                 @"is_valid_punch_card":@1
                                                 };

            sqlLiteStore should have_received(@selector(insertRow:)).with(expectedDictionary);
        });


        it(@"should return the all inserted record except the most recent punch card", ^{
            [subject getPunchCardsExcludingPunch:punch] should equal(@[punchCardObjectB]);
        });
    });
    
});

SPEC_END
