#import <Cedar/Cedar.h>
#import "ProjectStorage.h"
#import "SQLiteTableStore.h"
#import "SQLiteDatabaseConnection.h"
#import "QueryStringBuilder.h"
#import "ProjectType.h"
#import "Period.h"
#import "ClientType.h"
#import "Constants.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ProjectStorageSpec)

describe(@"ProjectStorage", ^{
    __block ProjectStorage *subject;
    __block NSUserDefaults *userDefaults;
    __block DoorKeeper *doorKeeper;
    __block SQLiteTableStore<CedarDouble> *sqlLiteStore;
    __block id<UserSession> userSession;

    beforeEach(^{

        sqlLiteStore = (id)[[SQLiteTableStore alloc] initWithSqliteDatabaseConnection:[[SQLiteDatabaseConnection alloc] init]
                                                                   queryStringBuilder:[[QueryStringBuilder alloc] init]
                                                                         databaseName:@"Test"
                                                                            tableName:@"user_project_types"];
        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
        doorKeeper = nice_fake_for([DoorKeeper class]);
        userDefaults = nice_fake_for([NSUserDefaults class]);


        subject = [[ProjectStorage alloc] initWithUserPermissionsStorage:NULL
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
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedProjectPageNumber").and_return(@4);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
                lastDownloadedPageNumber should equal(@4);
            });

            it(@"should return correctly stored last Downloaded PageNumber For User if Supervisor last Downloaded PageNumber is diffrent", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedProjectPageNumber").and_return(@4);
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedProjectPageNumber").and_return(@2);
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
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedProjectPageNumber").and_return(@4);
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
                userDefaults stub_method(@selector(setObject:forKey:)).with(@1, @"LastDownloadedProjectPageNumber");
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedProjectPageNumber").and_return(@1);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
                lastDownloadedPageNumber should equal(@1);
            });

            it(@"should update last Downloaded PageNumber value correctly ", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedProjectPageNumber").and_return(@4);
                userDefaults stub_method(@selector(setObject:forKey:)).with(@5, @"LastDownloadedProjectPageNumber");
                [subject updatePageNumber];
                userDefaults stub_method(@selector(objectForKey:)).again().with(@"LastDownloadedProjectPageNumber").and_return(@5);

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
                userDefaults stub_method(@selector(setObject:forKey:)).with(@1, @"SupervisorLastDownloadedProjectPageNumber");
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedProjectPageNumber").and_return(@1);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
                lastDownloadedPageNumber should equal(@1);
            });

            it(@"should update last Downloaded PageNumber value correctly ", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedProjectPageNumber").and_return(@4);
                userDefaults stub_method(@selector(setObject:forKey:)).with(@5, @"SupervisorLastDownloadedProjectPageNumber");
                [subject updatePageNumber];
                userDefaults stub_method(@selector(objectForKey:)).again().with(@"SupervisorLastDownloadedProjectPageNumber").and_return(@5);

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
                userDefaults should have_received(@selector(removeObjectForKey:)).with(@"LastDownloadedProjectPageNumber");
            });
        });

        context(@"supervisor context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"supervisor:user_uri");
            });
            it(@"should reset the last Downloaded PageNumber", ^{
                [subject resetPageNumber];
                userDefaults should have_received(@selector(removeObjectForKey:)).with(@"SupervisorLastDownloadedProjectPageNumber");
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
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedFilteredProjectPageNumber").and_return(@4);
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
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedFilteredProjectPageNumber").and_return(@4);
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
                userDefaults stub_method(@selector(setObject:forKey:)).with(@1, @"LastDownloadedFilteredProjectPageNumber");
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedFilteredProjectPageNumber").and_return(@1);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
                lastDownloadedPageNumber should equal(@1);
            });

            it(@"should update last Downloaded PageNumber value correctly ", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedFilteredProjectPageNumber").and_return(@4);
                userDefaults stub_method(@selector(setObject:forKey:)).with(@5, @"LastDownloadedFilteredProjectPageNumber");
                [subject updatePageNumber];
                userDefaults stub_method(@selector(objectForKey:)).again().with(@"LastDownloadedFilteredProjectPageNumber").and_return(@5);

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
                userDefaults stub_method(@selector(setObject:forKey:)).with(@1, @"SupervisorLastDownloadedFilteredProjectPageNumber");
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedFilteredProjectPageNumber").and_return(@1);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
                lastDownloadedPageNumber should equal(@1);
            });

            it(@"should update last Downloaded PageNumber value correctly ", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedFilteredProjectPageNumber").and_return(@4);
                userDefaults stub_method(@selector(setObject:forKey:)).with(@5, @"SupervisorLastDownloadedFilteredProjectPageNumber");
                [subject updatePageNumber];
                userDefaults stub_method(@selector(objectForKey:)).again().with(@"SupervisorLastDownloadedFilteredProjectPageNumber").and_return(@5);

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
                userDefaults should have_received(@selector(removeObjectForKey:)).with(@"LastDownloadedFilteredProjectPageNumber");
            });
        });

        context(@"supervisor context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"supervisor:user_uri");
            });
            it(@"should reset the last Downloaded PageNumber", ^{
                [subject resetPageNumberForFilteredSearch];
                userDefaults should have_received(@selector(removeObjectForKey:)).with(@"SupervisorLastDownloadedFilteredProjectPageNumber");
            });
        });

    });

    describe(@"-storeClients", ^{

        __block ProjectType *project;
        context(@"When inserting a fresh client in DB", ^{
            beforeEach(^{
                Period *period = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                                              endDate:[NSDate dateWithTimeIntervalSince1970:2]];
                ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                 isTimeAllocationAllowed:NO
                                                                                           projectPeriod:period
                                                                                              clientType:client
                                                                                                    name:@"project-name"
                                                                                                     uri:@"project-uri"];

                sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).with(@{@"uri": @"stored-project-uri"}).and_return(nil);
                [subject storeProjects:@[project]];
            });

            it(@"should insert the row into database", ^{
                sqlLiteStore should have_received(@selector(insertRow:)).with(@{
                                                                                @"uri":@"project-uri",
                                                                                @"name":@"project-name",
                                                                                @"client_uri":@"client-uri",
                                                                                @"client_name":@"client-name",
                                                                                @"start_date":[NSDate dateWithTimeIntervalSince1970:1],
                                                                                @"end_date":[NSDate dateWithTimeIntervalSince1970:2],
                                                                                @"hasTasksAvailableForTimeAllocation":@(NO),
                                                                                @"isTimeAllocationAllowed":@(NO),
                                                                                @"user_uri":@"some:user_uri"
                                                                                });
            });

            it(@"should return the newly inserted record", ^{
                [subject getAllProjectsForClientUri:@"client-uri"] should equal(@[project]);
            });
        });

        context(@"When updating a already stored client in DB", ^{

            beforeEach(^{
                Period *storedPeriod = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                                              endDate:[NSDate dateWithTimeIntervalSince1970:2]];
                ClientType *storedClient = [[ClientType alloc]initWithName:@"clientA" uri:@"clientUriA"];
                ProjectType *storedProject = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                                 isTimeAllocationAllowed:NO
                                                                                           projectPeriod:storedPeriod
                                                                                              clientType:storedClient
                                                                                                    name:@"stored-project-name"
                                                                                                     uri:@"project-uri"];

                [subject storeProjects:@[storedProject]];

                sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).with(@{@"uri": @"project-uri"}).and_return(@{
                                                                                                                      @"name": @"StoredClient",
                                                                                                                      @"uri": @"ClientUriA",
                                                                                                                      @"user_uri":@"some:user_uri"
                                                                                                                      });

                Period *period = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                                        endDate:[NSDate dateWithTimeIntervalSince1970:2]];
                ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                              isTimeAllocationAllowed:NO
                                                                        projectPeriod:period
                                                                           clientType:client
                                                                                 name:@"new-project-name"
                                                                                  uri:@"project-uri"];


                [subject storeProjects:@[project]];
            });

            it(@"should update the row in database", ^{
                sqlLiteStore should have_received(@selector(updateRow:whereClause:)).with(@{
                                                                                @"uri":@"project-uri",
                                                                                @"name":@"new-project-name",
                                                                                @"client_uri":@"client-uri",
                                                                                @"client_name":@"client-name",
                                                                                @"start_date":[NSDate dateWithTimeIntervalSince1970:1],
                                                                                @"end_date":[NSDate dateWithTimeIntervalSince1970:2],
                                                                                @"hasTasksAvailableForTimeAllocation":@(NO),
                                                                                @"isTimeAllocationAllowed":@(NO),
                                                                                @"user_uri":@"some:user_uri"
                                                                                },@{@"uri":@"project-uri", @"user_uri":@"some:user_uri"});
            });

            it(@"should return the newly updated record", ^{
                [subject getAllProjectsForClientUri:@"client-uri"] should equal(@[project]);
            });

        });

    });

    describe(@"-getAllProjectsForClientUri", ^{

        it(@"should return all Project Types", ^{

            Period *periodA = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                                     endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            ClientType *clientA = [[ClientType alloc]initWithName:@"clientA" uri:@"client-uri"];
            ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:periodA
                                                                                     clientType:clientA
                                                                                           name:@"ProjectA"
                                                                                            uri:@"uriA"];
            Period *periodB = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                                     endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            ClientType *clientB = [[ClientType alloc]initWithName:@"clientB" uri:@"client-uri"];
            ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:periodB
                                                                                     clientType:clientB
                                                                                           name:@"ProjectB"
                                                                                            uri:@"uriB"];
            Period *periodC = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                                     endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            ClientType *clientC = [[ClientType alloc]initWithName:@"clientC" uri:@"client-uri"];
            ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:periodC
                                                                                     clientType:clientC
                                                                                           name:@"ProjectC"
                                                                                            uri:@"uriC"];
            [subject storeProjects:@[projectA,projectB,projectC]];

            [subject getAllProjectsForClientUri:@"client-uri"] should equal(@[projectA,projectB,projectC]);
        });

        it(@"should return older Project Types along with recent Project Types", ^{
            Period *periodA = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                                     endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            ClientType *clientA = [[ClientType alloc]initWithName:@"clientA" uri:@"client-uri"];
            ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:periodA
                                                                                     clientType:clientA
                                                                                           name:@"ProjectA"
                                                                                            uri:@"uriA"];

            Period *periodB = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                                     endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            ClientType *clientB = [[ClientType alloc]initWithName:@"clientB" uri:@"client-uri"];
            ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:periodB
                                                                                     clientType:clientB
                                                                                           name:@"ProjectB"
                                                                                            uri:@"uriB"];


            Period *periodC = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                                     endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            ClientType *clientC = [[ClientType alloc]initWithName:@"clientC" uri:@"client-uri"];
            ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:periodC
                                                                                     clientType:clientC
                                                                                           name:@"ProjectC"
                                                                                            uri:@"uriC"];


            [subject storeProjects:@[projectA,projectB,projectC]];


            Period *periodD = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                                     endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            ClientType *clientD = [[ClientType alloc]initWithName:@"clientD" uri:@"client-uri"];
            ProjectType *recentProjectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                              isTimeAllocationAllowed:NO
                                                                                        projectPeriod:periodD
                                                                                           clientType:clientD
                                                                                                 name:@"ProjectD"
                                                                                                  uri:@"uriD"];

            Period *periodE = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                                     endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            ClientType *clientE = [[ClientType alloc]initWithName:@"clientE" uri:@"some-client-uri"];
            ProjectType *recentProjectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                              isTimeAllocationAllowed:NO
                                                                                        projectPeriod:periodE
                                                                                           clientType:clientE
                                                                                                 name:@"ProjectE"
                                                                                                  uri:@"uriE"];

            [subject storeProjects:@[recentProjectA,recentProjectB]];

            [subject getAllProjectsForClientUri:@"client-uri"] should equal(@[projectA,projectB,projectC,recentProjectA]);
        });
        
        it(@"should return all Project Types when null behaviour filter is applied and type is Any client", ^{
            
            Period *periodA = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            ClientType *clientA = [[ClientType alloc]initWithName:@"clientA" uri:@"client-uri"];
            ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:periodA
                                                                                     clientType:clientA
                                                                                           name:@"ProjectA"
                                                                                            uri:@"uriA"];
            Period *periodB = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            ClientType *clientB = [[ClientType alloc]initWithName:@"clientB" uri:@"client-uri"];
            ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:periodB
                                                                                     clientType:clientB
                                                                                           name:@"ProjectB"
                                                                                            uri:@"uriB"];
            Period *periodC = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            ClientType *clientC = [[ClientType alloc]initWithName:@"clientC" uri:@"client-uri"];
            ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:periodC
                                                                                     clientType:clientC
                                                                                           name:@"ProjectC"
                                                                                            uri:@"uriC"];
            
            Period *periodD = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            ClientType *clientD = [[ClientType alloc]initWithName:@"<null>" uri:@"<null>"];
            ProjectType *projectD = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:periodD
                                                                                     clientType:clientD
                                                                                           name:@"ProjectD"
                                                                                            uri:@"uriD"];
            [subject storeProjects:@[projectA, projectB, projectC, projectD]];
            
            [subject getAllProjectsForClientUri:ClientTypeAnyClientUri] should equal(@[projectA,projectB,projectC, projectD]);
        });
        
        it(@"should return all Project Types when null behaviour filter is applied and type is No client", ^{
            
            Period *periodA = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            ClientType *clientA = [[ClientType alloc]initWithName:@"clientA" uri:@"client-uri"];
            ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:periodA
                                                                                     clientType:clientA
                                                                                           name:@"ProjectA"
                                                                                            uri:@"uriA"];
            Period *periodB = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            ClientType *clientB = [[ClientType alloc]initWithName:@"clientB" uri:@"client-uri"];
            ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:periodB
                                                                                     clientType:clientB
                                                                                           name:@"ProjectB"
                                                                                            uri:@"uriB"];
            Period *periodC = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            ClientType *clientC = [[ClientType alloc]initWithName:@"clientC" uri:@"client-uri"];
            ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:periodC
                                                                                     clientType:clientC
                                                                                           name:@"ProjectC"
                                                                                            uri:@"uriC"];
            
            Period *periodD = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            ClientType *clientD = [[ClientType alloc]initWithName:@"<null>" uri:@"<null>"];
            ProjectType *projectD = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:periodD
                                                                                     clientType:clientD
                                                                                           name:@"ProjectD"
                                                                                            uri:@"uriD"];
            [subject storeProjects:@[projectA, projectB, projectC, projectD]];
            
            [subject getAllProjectsForClientUri:ClientTypeNoClientUri] should equal(@[projectD]);
        });
    });

    describe(@"-getProjectsWithMatchingText:clientUri:", ^{

        __block ProjectType *projectA;
        __block ProjectType *projectB;
        __block ProjectType *projectC;
        __block ProjectType *projectD;
        __block ProjectType *projectE;
        __block ProjectType *projectF;
        __block ProjectType *projectG;
        __block ProjectType *projectH;
        
        beforeEach(^{
            Period *periodA = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            ClientType *clientA = [[ClientType alloc]initWithName:@"clientA" uri:@"clientUriA"];
            projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:periodA
                                                                                     clientType:clientA
                                                                                           name:@"Apple"
                                                                                            uri:@"uriA"];

            Period *periodB = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            ClientType *clientB = [[ClientType alloc]initWithName:@"clientB" uri:@"clientUriB"];
            projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:periodB
                                                                                     clientType:clientB
                                                                                           name:@"Orange"
                                                                                            uri:@"uriB"];


            Period *periodC = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            ClientType *clientC = [[ClientType alloc]initWithName:@"clientC" uri:@"clientUriC"];
            projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:periodC
                                                                                     clientType:clientC
                                                                                           name:@"Pineapple"
                                                                                            uri:@"uriC"];

            Period *periodD = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            ClientType *clientD = [[ClientType alloc]initWithName:@"clientD" uri:@"clientUriD"];
            projectD = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:periodD
                                                                                     clientType:clientD
                                                                                           name:@"Grape"
                                                                                            uri:@"uriD"];

            Period *periodE = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            ClientType *clientE = [[ClientType alloc]initWithName:@"clientE" uri:@"clientUriE"];
            projectE = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:periodE
                                                                                     clientType:clientE
                                                                                           name:@"Kiwi"
                                                                                            uri:@"uriE"];


            Period *periodF = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            ClientType *clientF = [[ClientType alloc]initWithName:@"clientF" uri:@"clientUriF"];
            projectF = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:periodF
                                                                                     clientType:clientF
                                                                                           name:@"Strawberry"
                                                                                            uri:@"uriF"];

            Period *periodG = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            ClientType *clientG = [[ClientType alloc]initWithName:@"clientG" uri:@"clientUriG"];
            projectG = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                           isTimeAllocationAllowed:NO
                                                                     projectPeriod:periodG
                                                                        clientType:clientG
                                                                              name:@"Testapple"
                                                                               uri:@"uriC"];
            
            Period *periodH = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            
            ClientType *clientH = [[ClientType alloc]initWithName:NULL_STRING uri:NULL_STRING];
            
            projectH = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                           isTimeAllocationAllowed:NO
                                                                     projectPeriod:periodH
                                                                        clientType:clientH
                                                                              name:@"TestappleH"
                                                                               uri:@"uriH"];
            
        });
        it(@"should return all Project Types matching the text", ^{

            [subject storeProjects:@[projectA,projectB,projectC,projectD,projectE,projectF,projectG]];
            [subject getProjectsWithMatchingText:@"apple" clientUri:nil] should equal(@[projectA,projectG]);
        });

        it(@"should return all Project Types matching the text and client uri", ^{

            [subject storeProjects:@[projectA,projectB,projectC,projectD,projectE,projectF,projectG]];

            [subject getProjectsWithMatchingText:@"apple" clientUri:@"clientUriF"] should be_nil;
            [subject getProjectsWithMatchingText:@"berry" clientUri:@"clientUriF"] should equal(@[projectF]);
        });

        it(@"should ask sqlite store for the Project info when client is nil", ^{
            [subject storeProjects:@[projectA,projectB,projectC,projectD,projectE,projectF,projectG]];
            [subject getProjectsWithMatchingText:@"apple" clientUri:nil];
            sqlLiteStore should have_received(@selector(readAllRowsFromColumn:where:pattern:)).with(@"name",@{@"user_uri": @"some:user_uri"},@"apple");
        });

        it(@"should ask sqlite store for the Project info when client is not nil", ^{
            [subject storeProjects:@[projectA,projectB,projectC,projectD,projectE,projectF,projectG]];
            [subject getProjectsWithMatchingText:@"apple" clientUri:@"clientUriF"];
            sqlLiteStore should have_received(@selector(readAllRowsFromColumn:where:pattern:)).with(@"name",@{@"client_uri": @"clientUriF", @"user_uri": @"some:user_uri"},@"apple");
        });
        
        it(@"Should return Projects With client null behaviour uri and type is no client", ^{
            [subject storeProjects:@[projectA,projectB,projectC,projectD,projectE,projectF,projectG, projectH]];
            [subject getProjectsWithMatchingText:@"apple" clientUri:ClientTypeNoClientUri] should equal(@[projectH]);
            
        });
        
        it(@"Should return Projects With client null behaviour uri and type is Any client", ^{
            [subject storeProjects:@[projectA,projectB,projectC,projectD,projectE,projectF,projectG, projectH]];
            [subject getProjectsWithMatchingText:@"apple" clientUri:ClientTypeAnyClientUri] should equal(@[projectA, projectG, projectH]);
            
        });
        
    });

    describe(@"-deleteAllProjectsForClientUri", ^{

        context(@"deleting projects with empty client uri ", ^{

            context(@"user context", ^{

                beforeEach(^{
                    userSession stub_method(@selector(currentUserURI)).again().and_return(@"some:user_uri");
                    Period *period = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                              endDate:[NSDate dateWithTimeIntervalSince1970:2]];
                    ClientType *client = [[ClientType alloc]initWithName:nil uri:nil];
                    ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                               isTimeAllocationAllowed:NO
                                                                                         projectPeriod:period
                                                                                            clientType:client
                                                                                                  name:@"projectname"
                                                                                                   uri:@"projecturi"];;
                    [subject storeProjects:@[project]];
                    [subject deleteAllProjectsForClientUri:nil];
                });

                it(@"should remove all Project types", ^{
                    [subject getAllProjectsForClientUri:nil] should be_nil;
                    sqlLiteStore should have_received(@selector(deleteAllRows));
                });
            });
            context(@"supervisor context", ^{

                beforeEach(^{
                    userSession stub_method(@selector(currentUserURI)).again().and_return(@"supervisor:user_uri");
                    Period *period = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                              endDate:[NSDate dateWithTimeIntervalSince1970:2]];
                    ClientType *client = [[ClientType alloc]initWithName:nil uri:nil];
                    ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                               isTimeAllocationAllowed:NO
                                                                                         projectPeriod:period
                                                                                            clientType:client
                                                                                                  name:@"projectname"
                                                                                                   uri:@"projecturi"];;
                    [subject storeProjects:@[project]];
                    [subject deleteAllProjectsForClientUri:nil];
                });

                it(@"should remove all Project types", ^{
                    [subject getAllProjectsForClientUri:nil] should be_nil;
                    sqlLiteStore should have_received(@selector(deleteRowWithStringArgs:)).with(@"user_uri != 'supervisor:user_uri'");
                });
            });


        });

        context(@"deleting projects with client uri ", ^{

            __block ProjectType *projectA;
            __block ProjectType *projectB;

            beforeEach(^{
                Period *periodA = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                           endDate:[NSDate dateWithTimeIntervalSince1970:2]];
                ClientType *clientA = [[ClientType alloc]initWithName:@"client-name"
                                                                  uri:@"client-uri"];
                projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                               isTimeAllocationAllowed:NO
                                                                         projectPeriod:periodA
                                                                            clientType:clientA
                                                                                  name:@"projectname"
                                                                                   uri:@"projecturi"];

                Period *periodB = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                          endDate:[NSDate dateWithTimeIntervalSince1970:2]];
                ClientType *clientB = [[ClientType alloc]initWithName:@"new-client-name"
                                                                 uri:@"new-client-uri"];
                projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:periodB
                                                                                        clientType:clientB
                                                                                              name:@"projectname"
                                                                                               uri:@"projecturi"];;
                [subject storeProjects:@[projectA,projectB]];

            });

            context(@"user context", ^{

                beforeEach(^{
                    userSession stub_method(@selector(currentUserURI)).again().and_return(@"some:user_uri");
                    [subject deleteAllProjectsForClientUri:@"client-uri"];
                });

                it(@"should not delete projects with different clients", ^{
                    [subject getAllProjectsForClientUri:@"new-client-uri"] should equal(@[projectB]);
                });

                it(@"should return only project for client uri passed", ^{
                    [subject getAllProjectsForClientUri:nil] should equal(@[projectB]);

                });

                it(@"should delete only projects relating to client passed", ^{
                    sqlLiteStore should have_received(@selector(deleteRowWithArgs:)).with(@{@"client_uri": @"client-uri"});
                });
            });
            context(@"supervisor context", ^{

                beforeEach(^{
                    userSession stub_method(@selector(currentUserURI)).again().and_return(@"supervisor:user_uri");
                    [subject deleteAllProjectsForClientUri:@"client-uri"];
                });

                it(@"should not delete projects with different clients", ^{
                    [subject getAllProjectsForClientUri:@"new-client-uri"] should equal(@[projectB]);
                });

                it(@"should return only project for client uri passed", ^{
                    [subject getAllProjectsForClientUri:nil] should equal(@[projectB]);

                });

                it(@"should delete only projects relating to client passed", ^{
                    sqlLiteStore should have_received(@selector(deleteRowWithStringArgs:)).with(@"client_uri = 'client-uri' AND user_uri != 'supervisor:user_uri'");
                });
            });
        });
        
        context(@"deleting projects with client null behaviour Uri and type is Any client ", ^{
            
            __block ProjectType *projectA;
            __block ProjectType *projectB;
            
            beforeEach(^{
                Period *periodA = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                           endDate:[NSDate dateWithTimeIntervalSince1970:2]];
                ClientType *clientA = [[ClientType alloc]initWithName:@"client-name"
                                                                  uri:ClientTypeAnyClientUri];
                projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                               isTimeAllocationAllowed:NO
                                                                         projectPeriod:periodA
                                                                            clientType:clientA
                                                                                  name:@"projectname"
                                                                                   uri:@"projecturi"];
                
                Period *periodB = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                           endDate:[NSDate dateWithTimeIntervalSince1970:2]];
                ClientType *clientB = [[ClientType alloc]initWithName:@"new-client-name"
                                                                  uri:@"new-client-uri"];
                projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                               isTimeAllocationAllowed:NO
                                                                         projectPeriod:periodB
                                                                            clientType:clientB
                                                                                  name:@"projectname"
                                                                                   uri:@"projecturi"];;
                [subject storeProjects:@[projectA,projectB]];
                
            });
            
            context(@"user context", ^{
                
                beforeEach(^{
                    userSession stub_method(@selector(currentUserURI)).again().and_return(@"some:user_uri");
                    [subject deleteAllProjectsForClientUri:ClientTypeAnyClientUri];
                });
                
                it(@"should not delete projects with different clients", ^{
                    [subject getAllProjectsForClientUri:ClientTypeAnyClientUri] should equal(nil);
                });
                
                it(@"should return only project for client uri passed", ^{
                    [subject getAllProjectsForClientUri:nil] should equal(nil);
                    
                });
                
                it(@"should delete only projects relating to client passed", ^{
                    sqlLiteStore should have_received(@selector(deleteAllRows));
                });
            });
            context(@"supervisor context", ^{
                
                beforeEach(^{
                    userSession stub_method(@selector(currentUserURI)).again().and_return(@"supervisor:user_uri");
                    [subject deleteAllProjectsForClientUri:ClientTypeAnyClientUri];
                });
                
                it(@"should not delete projects with different clients", ^{
                    [subject getAllProjectsForClientUri:ClientTypeAnyClientUri] should equal(nil);
                });
                
                it(@"should return only project for client uri passed", ^{
                    [subject getAllProjectsForClientUri:nil] should equal(nil);
                    
                });
                
                it(@"should delete only projects relating to client passed", ^{
                    sqlLiteStore should have_received(@selector(deleteRowWithStringArgs:)).with(@"user_uri != 'supervisor:user_uri'");
                });
            });
        });
        
        context(@"deleting projects with client null behaviour Uri and type is No client ", ^{
            
            __block ProjectType *projectA;
            __block ProjectType *projectB;
            
            beforeEach(^{
                Period *periodA = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                           endDate:[NSDate dateWithTimeIntervalSince1970:2]];
                ClientType *clientA = [[ClientType alloc]initWithName:@"client-name"
                                                                  uri:ClientTypeNoClientUri];
                projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                               isTimeAllocationAllowed:NO
                                                                         projectPeriod:periodA
                                                                            clientType:clientA
                                                                                  name:@"projectname"
                                                                                   uri:@"projecturi"];
                
                Period *periodB = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                           endDate:[NSDate dateWithTimeIntervalSince1970:2]];
                ClientType *clientB = [[ClientType alloc]initWithName:@"new-client-name"
                                                                  uri:@"new-client-uri"];
                projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                               isTimeAllocationAllowed:NO
                                                                         projectPeriod:periodB
                                                                            clientType:clientB
                                                                                  name:@"projectname"
                                                                                   uri:@"projecturi"];;
                [subject storeProjects:@[projectA,projectB]];
                
            });
            
            context(@"user context", ^{
                
                beforeEach(^{
                    userSession stub_method(@selector(currentUserURI)).again().and_return(@"some:user_uri");
                    [subject deleteAllProjectsForClientUri:ClientTypeNoClientUri];
                });
                
                it(@"should not delete projects with different clients", ^{
                    [subject getAllProjectsForClientUri:@"new-client-uri"] should equal(@[projectB]);
                });
                
                it(@"should return only project for client uri passed", ^{
                    [subject getAllProjectsForClientUri:nil] should equal(@[projectB]);
                    
                });
                
                it(@"should return only project for client uri passed", ^{
                    [subject getAllProjectsForClientUri:ClientTypeNoClientUri] should equal(nil);
                    
                });
                
                it(@"should delete only projects relating to client passed", ^{
                    sqlLiteStore should have_received(@selector(deleteRowWithArgs:)).with(@{@"client_uri": @"<null>"});
                });
            });
            context(@"supervisor context", ^{
                
                beforeEach(^{
                    userSession stub_method(@selector(currentUserURI)).again().and_return(@"supervisor:user_uri");
                    [subject deleteAllProjectsForClientUri:ClientTypeNoClientUri];
                });
                
                it(@"should not delete projects with different clients", ^{
                    [subject getAllProjectsForClientUri:@"new-client-uri"] should equal(@[projectB]);
                });
                
                it(@"should return only project for client uri passed", ^{
                    [subject getAllProjectsForClientUri:nil] should equal(@[projectB]);
                    
                });
                
                it(@"should return only project for client uri passed", ^{
                    [subject getAllProjectsForClientUri:ClientTypeNoClientUri] should equal(nil);
                    
                });
                
                it(@"should delete only projects relating to client passed", ^{
                    sqlLiteStore should have_received(@selector(deleteRowWithStringArgs:)).with(@"client_uri = '<null>' AND user_uri != 'supervisor:user_uri'");
                });
            });
        });
    });

    describe(@"As a <DoorKeeperObserver>", ^{
        beforeEach(^{
            Period *periodF = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                                     endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            ClientType *clientF = [[ClientType alloc]initWithName:@"clientF" uri:@"clientUriF"];
            ProjectType *projectF = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:periodF
                                                                                     clientType:clientF
                                                                                           name:@"Strawberry"
                                                                                            uri:@"uriF"];
            [subject storeProjects:@[projectF]];

            [subject setUpWithUserUri:@"user:uri:new"];

            [subject doorKeeperDidLogOut:nil];
        });

        it(@"should remove all Client types", ^{
            [subject getAllProjectsForClientUri:nil] should be_nil;
        });
    });

    describe(@"-getProjectInfoForUri:", ^{
        __block ProjectType *expectedProject;
        __block ProjectType *project;

        beforeEach(^{
            Period *periodF = [[Period alloc]initWithStartDate:[NSDate dateWithTimeIntervalSince1970:1]
                                                       endDate:[NSDate dateWithTimeIntervalSince1970:2]];
            ClientType *clientF = [[ClientType alloc]initWithName:@"clientF" uri:@"clientUriF"];
            project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                        isTimeAllocationAllowed:NO
                                                                                  projectPeriod:periodF
                                                                                     clientType:clientF
                                                                                           name:@"Strawberry"
                                                                                            uri:@"project-uri"];
            [subject storeProjects:@[project]];

            [sqlLiteStore reset_sent_messages];
            expectedProject = [subject getProjectInfoForUri:@"project-uri"];
        });

        it(@"should ask sqlite store for the client info", ^{
            sqlLiteStore should have_received(@selector(readAllRowsWithArgs:)).with(@{@"user_uri": @"some:user_uri",
                                                                                      @"uri":@"project-uri"});
        });

        it(@"should return the stored client correctly ", ^{
            expectedProject should equal(project);
        });
    });

});

SPEC_END
