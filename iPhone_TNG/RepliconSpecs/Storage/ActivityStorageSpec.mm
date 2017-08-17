
#import <Cedar/Cedar.h>
#import "ActivityStorage.h"
#import "SQLiteTableStore.h"
#import "SQLiteDatabaseConnection.h"
#import "QueryStringBuilder.h"
#import "Activity.h"
#import "UserPermissionsStorage.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ActivityStorageSpec)

describe(@"ActivityStorage", ^{
    __block ActivityStorage *subject;
    __block NSUserDefaults *userDefaults;
    __block DoorKeeper *doorKeeper;
    __block SQLiteTableStore<CedarDouble> *sqlLiteStore;
    __block id<UserSession> userSession;
    __block UserPermissionsStorage *userPermissionsStorage;

    beforeEach(^{

        sqlLiteStore = (id)[[SQLiteTableStore alloc] initWithSqliteDatabaseConnection:[[SQLiteDatabaseConnection alloc] init]
                                                                   queryStringBuilder:[[QueryStringBuilder alloc] init]
                                                                         databaseName:@"Test"
                                                                            tableName:@"user_Activity_types"];

        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
        doorKeeper = nice_fake_for([DoorKeeper class]);
        userDefaults = nice_fake_for([NSUserDefaults class]);


        subject = [[ActivityStorage alloc] initWithUserPermissionsStorage:userPermissionsStorage
                                                              sqliteStore:sqlLiteStore
                                                             userDefaults:userDefaults
                                                              userSession:userSession
                                                               doorKeeper:doorKeeper];

        userPermissionsStorage stub_method(@selector(isActivitySelectionRequired)).and_return(YES);

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
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedActivityPageNumber").and_return(@4);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
                lastDownloadedPageNumber should equal(@4);
            });

            it(@"should return correctly stored last Downloaded PageNumber For User if Supervisor last Downloaded PageNumber is diffrent", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedActivityPageNumber").and_return(@4);
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedActivityPageNumber").and_return(@2);
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
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedActivityPageNumber").and_return(@4);
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
                userDefaults stub_method(@selector(setObject:forKey:)).with(@1, @"LastDownloadedActivityPageNumber");
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedActivityPageNumber").and_return(@1);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
                lastDownloadedPageNumber should equal(@1);
            });

            it(@"should update last Downloaded PageNumber value correctly ", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedActivityPageNumber").and_return(@4);
                userDefaults stub_method(@selector(setObject:forKey:)).with(@5, @"LastDownloadedActivityPageNumber");
                [subject updatePageNumber];
                userDefaults stub_method(@selector(objectForKey:)).again().with(@"LastDownloadedActivityPageNumber").and_return(@5);

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
                userDefaults stub_method(@selector(setObject:forKey:)).with(@1, @"SupervisorLastDownloadedActivityPageNumber");
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedActivityPageNumber").and_return(@1);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
                lastDownloadedPageNumber should equal(@1);
            });

            it(@"should update last Downloaded PageNumber value correctly ", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedActivityPageNumber").and_return(@4);
                userDefaults stub_method(@selector(setObject:forKey:)).with(@5, @"SupervisorLastDownloadedActivityPageNumber");
                [subject updatePageNumber];
                userDefaults stub_method(@selector(objectForKey:)).again().with(@"SupervisorLastDownloadedActivityPageNumber").and_return(@5);

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
                userDefaults should have_received(@selector(removeObjectForKey:)).with(@"LastDownloadedActivityPageNumber");
            });
        });

        context(@"supervisor context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"supervisor:user_uri");
            });
            it(@"should reset the last Downloaded PageNumber", ^{
                [subject resetPageNumber];
                userDefaults should have_received(@selector(removeObjectForKey:)).with(@"SupervisorLastDownloadedActivityPageNumber");
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
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedFilteredActivityPageNumber").and_return(@4);
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
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedFilteredActivityPageNumber").and_return(@4);
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
                userDefaults stub_method(@selector(setObject:forKey:)).with(@1, @"LastDownloadedFilteredActivityPageNumber");
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedFilteredActivityPageNumber").and_return(@1);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
                lastDownloadedPageNumber should equal(@1);
            });

            it(@"should update last Downloaded PageNumber value correctly ", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedFilteredActivityPageNumber").and_return(@4);
                userDefaults stub_method(@selector(setObject:forKey:)).with(@5, @"LastDownloadedFilteredActivityPageNumber");
                [subject updatePageNumber];
                userDefaults stub_method(@selector(objectForKey:)).again().with(@"LastDownloadedFilteredActivityPageNumber").and_return(@5);

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
                userDefaults stub_method(@selector(setObject:forKey:)).with(@1, @"SupervisorLastDownloadedFilteredActivityPageNumber");
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedFilteredActivityPageNumber").and_return(@1);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
                lastDownloadedPageNumber should equal(@1);
            });

            it(@"should update last Downloaded PageNumber value correctly ", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedFilteredActivityPageNumber").and_return(@4);
                userDefaults stub_method(@selector(setObject:forKey:)).with(@5, @"SupervisorLastDownloadedFilteredActivityPageNumber");
                [subject updatePageNumber];
                userDefaults stub_method(@selector(objectForKey:)).again().with(@"SupervisorLastDownloadedFilteredActivityPageNumber").and_return(@5);

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
                userDefaults should have_received(@selector(removeObjectForKey:)).with(@"LastDownloadedFilteredActivityPageNumber");
            });
        });

        context(@"supervisor context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"supervisor:user_uri");
            });
            it(@"should reset the last Downloaded PageNumber", ^{
                [subject resetPageNumberForFilteredSearch];
                userDefaults should have_received(@selector(removeObjectForKey:)).with(@"SupervisorLastDownloadedFilteredActivityPageNumber");
            });
        });

    });

    describe(@"-storeActivities", ^{

        __block Activity *activity;
        context(@"When inserting a fresh Activity in DB", ^{
            beforeEach(^{
                activity = [[Activity alloc] initWithName:@"ActivityNameA" uri:@"ActivityUriA"];
                sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).and_return(nil);
                [subject storeActivities:@[activity]];
            });

            it(@"should insert the row into database", ^{
                sqlLiteStore should have_received(@selector(insertRow:)).with(@{@"name": @"ActivityNameA",
                                                                                @"uri": @"ActivityUriA",
                                                                                @"user_uri":@"some:user_uri"
                                                                                });
            });

            it(@"should return the newly inserted record", ^{
                [subject getAllActivities] should equal(@[activity]);
            });
        });

        context(@"When updating a already stored Activity in DB", ^{

            beforeEach(^{
                Activity *storedActivity = [[Activity alloc] initWithName:@"StoredActivity" uri:@"ActivityUriA"];

                [subject storeActivities:@[storedActivity]];

                sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).with(@{@"uri": @"ActivityUriA"}).and_return(@{
                                                                                                                      @"name": @"StoredActivity",
                                                                                                                      @"uri": @"ActivityUriA",
                                                                                                                      @"user_uri":@"some:user_uri"
                                                                                                                      });

                activity = [[Activity alloc] initWithName:@"ActivityNameA" uri:@"ActivityUriA"];

                [subject storeActivities:@[activity]];
            });

            it(@"should insert the row into database", ^{
                sqlLiteStore should have_received(@selector(updateRow:whereClause:)).with(@{@"name": @"ActivityNameA",
                                                                                @"uri": @"ActivityUriA",
                                                                                @"user_uri":@"some:user_uri"
                                                                                 },@{@"uri": @"ActivityUriA", @"user_uri": @"some:user_uri"});
            });

            it(@"should return the newly updated record", ^{
                [subject getAllActivities] should equal(@[activity]);
            });

        });

    });

    describe(@"-getAllActivities", ^{

        it(@"should return all Activity Types", ^{

            Activity *ActivityA = [[Activity alloc] initWithName:@"ActivityNameA" uri:@"ActivityUriA"];
            Activity *ActivityB = [[Activity alloc] initWithName:@"ActivityNameB" uri:@"ActivityUriB"];
            Activity *ActivityC = [[Activity alloc] initWithName:@"ActivityNameC" uri:@"ActivityUriC"];
            [subject storeActivities:@[ActivityA,ActivityB,ActivityC]];

            [subject getAllActivities] should equal(@[ActivityA,ActivityB,ActivityC]);
        });

        context(@"When activity selection is not required", ^{

            beforeEach(^{
                userPermissionsStorage stub_method(@selector(isActivitySelectionRequired)).again().and_return(NO);
            });
            it(@"should return all Activity Types, along with the none activity", ^{

                Activity *none = [[Activity alloc] initWithName:RPLocalizedString(@"None", nil) uri:nil];
                Activity *ActivityA = [[Activity alloc] initWithName:@"ActivityNameA" uri:@"ActivityUriA"];
                Activity *ActivityB = [[Activity alloc] initWithName:@"ActivityNameB" uri:@"ActivityUriB"];
                Activity *ActivityC = [[Activity alloc] initWithName:@"ActivityNameC" uri:@"ActivityUriC"];
                [subject storeActivities:@[ActivityA,ActivityB,ActivityC]];

                [subject getAllActivities] should equal(@[none,ActivityA,ActivityB,ActivityC]);
            });
        });

        it(@"should return older Activity Types along with recent Activity Types", ^{
            Activity *ActivityA = [[Activity alloc] initWithName:@"ActivityNameA" uri:@"ActivityUriA"];
            Activity *ActivityB = [[Activity alloc] initWithName:@"ActivityNameB" uri:@"ActivityUriB"];
            Activity *ActivityC = [[Activity alloc] initWithName:@"ActivityNameC" uri:@"ActivityUriC"];

            [subject storeActivities:@[ActivityA,ActivityB,ActivityC]];


            Activity *recentActivityA = [[Activity alloc] initWithName:@"RecentActivityNameA" uri:@"RecentActivityUriA"];
            Activity *recentActivityB = [[Activity alloc] initWithName:@"RecentActivityNameB" uri:@"RecentActivityUriB"];

            [subject storeActivities:@[recentActivityA,recentActivityB]];

            [subject getAllActivities] should equal(@[ActivityA,ActivityB,ActivityC,recentActivityA,recentActivityB]);
        });
    });

    describe(@"-getActivitysWithMatchingText", ^{

         __block Activity *ActivityA;
         __block Activity *ActivityB;
         __block Activity *ActivityC;
         __block Activity *ActivityD;
         __block Activity *ActivityE;
         __block Activity *ActivityF;
        beforeEach(^{
            ActivityA = [[Activity alloc] initWithName:@"Apple" uri:@"ActivityUriA"];
            ActivityB = [[Activity alloc] initWithName:@"Amogh" uri:@"ActivityUriB"];
            ActivityC = [[Activity alloc] initWithName:@"Anand" uri:@"ActivityUriC"];
            ActivityD = [[Activity alloc] initWithName:@"Activity0" uri:@"ActivityUriA"];
            ActivityE = [[Activity alloc] initWithName:@"Activity1" uri:@"ActivityUriB"];
            ActivityF = [[Activity alloc] initWithName:@"Activity2" uri:@"ActivityUriC"];
            [subject storeActivities:@[ActivityA,ActivityB,ActivityC,ActivityD,ActivityE,ActivityF]];
        });

        it(@"should return all Activity Types matching the text", ^{
            [subject getActivitiesWithMatchingText:@"a"] should equal(@[ActivityD,ActivityE,ActivityF]);
        });

        it(@"should ask sqlite store for the Activity info", ^{
            [subject getActivitiesWithMatchingText:@"a"];
            sqlLiteStore should have_received(@selector(readAllRowsFromColumn:where:pattern:)).with(@"name",@{@"user_uri": @"some:user_uri"},@"a");
        });
    });

    describe(@"-deleteAllActivitys", ^{

        beforeEach(^{
            Activity *activity = [[Activity alloc]initWithName:@"Activity-name" uri:@"Activity-uri"];
            [subject storeActivities:@[activity]];

        });

        context(@"user context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"some:user_uri");
                [subject deleteAllActivities];
            });
            it(@"should remove all Activity types", ^{
                [subject getAllActivities] should be_nil;
                sqlLiteStore should have_received(@selector(deleteAllRows));
           });
        });
        context(@"supervisor context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"supervisor:user_uri");
                [subject deleteAllActivities];
            });
            it(@"should remove all Activity types", ^{
                [subject getAllActivities] should be_nil;
                sqlLiteStore should have_received(@selector(deleteRowWithStringArgs:)).with(@"user_uri != 'supervisor:user_uri'");
            });
        });




    });

    describe(@"As a <DoorKeeperObserver>", ^{
        beforeEach(^{
            Activity *activity = [[Activity alloc]initWithName:@"Activity-name" uri:@"Activity-uri"];
            [subject storeActivities:@[activity]];

            [subject setUpWithUserUri:@"user:uri:new"];

            [subject doorKeeperDidLogOut:nil];
        });

        it(@"should remove all Activity types", ^{
            [subject getAllActivities] should be_nil;
        });
    });

    describe(@"-getActivityInfoForUri:", ^{
        __block Activity *expectedActivity;
        __block Activity *activity;

        beforeEach(^{
            activity = [[Activity alloc]initWithName:@"Activity-name" uri:@"Activity-uri"];
            [subject storeActivities:@[activity]];
            [sqlLiteStore reset_sent_messages];
            expectedActivity = [subject getActivityInfoForUri:@"Activity-uri"];
        });
        
        it(@"should ask sqlite store for the Activity info", ^{
            sqlLiteStore should have_received(@selector(readAllRowsWithArgs:)).with(@{@"user_uri": @"some:user_uri",
                                                                                      @"uri":@"Activity-uri"});
        });
        
        it(@"should return the stored Activity correctly ", ^{
            expectedActivity should equal(activity);
        });
    });
});

SPEC_END

