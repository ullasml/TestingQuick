#import <Cedar/Cedar.h>
#import "ClientStorage.h"
#import "SQLiteTableStore.h"
#import "SQLiteDatabaseConnection.h"
#import "QueryStringBuilder.h"
#import "ClientType.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ClientStorageSpec)

describe(@"ClientStorage", ^{
    __block ClientStorage *subject;
    __block NSUserDefaults *userDefaults;
    __block DoorKeeper *doorKeeper;
    __block SQLiteTableStore<CedarDouble> *sqlLiteStore;
    __block id<UserSession> userSession;

    beforeEach(^{

        sqlLiteStore = (id)[[SQLiteTableStore alloc] initWithSqliteDatabaseConnection:[[SQLiteDatabaseConnection alloc] init]
                                                                   queryStringBuilder:[[QueryStringBuilder alloc] init]
                                                                         databaseName:@"Test"
                                                                            tableName:@"user_client_types"];
        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
        doorKeeper = nice_fake_for([DoorKeeper class]);
        userDefaults = nice_fake_for([NSUserDefaults class]);


        subject = [[ClientStorage alloc]initWithSqliteStore:sqlLiteStore
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
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedClientPageNumber").and_return(@4);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
                lastDownloadedPageNumber should equal(@4);
            });

            it(@"should return correctly stored last Downloaded PageNumber For User if Supervisor last Downloaded PageNumber is diffrent", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedClientPageNumber").and_return(@4);
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedClientPageNumber").and_return(@2);
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
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedClientPageNumber").and_return(@4);
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
                userDefaults stub_method(@selector(setObject:forKey:)).with(@1, @"LastDownloadedClientPageNumber");
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedClientPageNumber").and_return(@1);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
                lastDownloadedPageNumber should equal(@1);
            });

            it(@"should update last Downloaded PageNumber value correctly ", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedClientPageNumber").and_return(@4);
                userDefaults stub_method(@selector(setObject:forKey:)).with(@5, @"LastDownloadedClientPageNumber");
                [subject updatePageNumber];
                userDefaults stub_method(@selector(objectForKey:)).again().with(@"LastDownloadedClientPageNumber").and_return(@5);

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
                userDefaults stub_method(@selector(setObject:forKey:)).with(@1, @"SupervisorLastDownloadedClientPageNumber");
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedClientPageNumber").and_return(@1);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
                lastDownloadedPageNumber should equal(@1);
            });

            it(@"should update last Downloaded PageNumber value correctly ", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedClientPageNumber").and_return(@4);
                userDefaults stub_method(@selector(setObject:forKey:)).with(@5, @"SupervisorLastDownloadedClientPageNumber");
                [subject updatePageNumber];
                userDefaults stub_method(@selector(objectForKey:)).again().with(@"SupervisorLastDownloadedClientPageNumber").and_return(@5);

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
                userDefaults should have_received(@selector(removeObjectForKey:)).with(@"LastDownloadedClientPageNumber");
            });
        });

        context(@"supervisor context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"supervisor:user_uri");
            });
            it(@"should reset the last Downloaded PageNumber", ^{
                [subject resetPageNumber];
                userDefaults should have_received(@selector(removeObjectForKey:)).with(@"SupervisorLastDownloadedClientPageNumber");
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
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedFilteredClientPageNumber").and_return(@4);
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
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedFilteredClientPageNumber").and_return(@4);
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
                userDefaults stub_method(@selector(setObject:forKey:)).with(@1, @"LastDownloadedFilteredClientPageNumber");
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedFilteredClientPageNumber").and_return(@1);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
                lastDownloadedPageNumber should equal(@1);
            });

            it(@"should update last Downloaded PageNumber value correctly ", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedFilteredClientPageNumber").and_return(@4);
                userDefaults stub_method(@selector(setObject:forKey:)).with(@5, @"LastDownloadedFilteredClientPageNumber");
                [subject updatePageNumber];
                userDefaults stub_method(@selector(objectForKey:)).again().with(@"LastDownloadedFilteredClientPageNumber").and_return(@5);

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
                userDefaults stub_method(@selector(setObject:forKey:)).with(@1, @"SupervisorLastDownloadedFilteredClientPageNumber");
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedFilteredClientPageNumber").and_return(@1);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
                lastDownloadedPageNumber should equal(@1);
            });

            it(@"should update last Downloaded PageNumber value correctly ", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedFilteredClientPageNumber").and_return(@4);
                userDefaults stub_method(@selector(setObject:forKey:)).with(@5, @"SupervisorLastDownloadedFilteredClientPageNumber");
                [subject updatePageNumber];
                userDefaults stub_method(@selector(objectForKey:)).again().with(@"SupervisorLastDownloadedFilteredClientPageNumber").and_return(@5);

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
                userDefaults should have_received(@selector(removeObjectForKey:)).with(@"LastDownloadedFilteredClientPageNumber");
            });
        });

        context(@"supervisor context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"supervisor:user_uri");
            });
            it(@"should reset the last Downloaded PageNumber", ^{
                [subject resetPageNumberForFilteredSearch];
                userDefaults should have_received(@selector(removeObjectForKey:)).with(@"SupervisorLastDownloadedFilteredClientPageNumber");
            });
        });


    });

    describe(@"-storeClients", ^{

        __block ClientType *client;
        context(@"When inserting a fresh client in DB", ^{
            beforeEach(^{
                client = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];
                sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).and_return(nil);
                [subject storeClients:@[client]];
            });

            it(@"should insert the row into database", ^{
                sqlLiteStore should have_received(@selector(insertRow:)).with(@{@"name": @"ClientNameA",
                                                                                @"uri": @"ClientUriA",
                                                                                @"user_uri":@"some:user_uri"
                                                                                });
            });

            it(@"should return the newly inserted record", ^{
                [subject getAllClients] should equal(@[client]);
            });
        });

        context(@"When updating a already stored client in DB", ^{

            beforeEach(^{
                ClientType *storedClient = [[ClientType alloc] initWithName:@"StoredClient" uri:@"ClientUriA"];

                [subject storeClients:@[storedClient]];

                sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).with(@{@"uri": @"ClientUriA"}).and_return(@{
                                                                                                                      @"name": @"StoredClient",
                                                                                                                      @"uri": @"ClientUriA",
                                                                                                                      @"user_uri":@"some:user_uri"
                                                                                                                      });

                client = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];

                [subject storeClients:@[client]];
            });

            it(@"should insert the row into database", ^{
                sqlLiteStore should have_received(@selector(updateRow:whereClause:)).with(@{@"name": @"ClientNameA",
                                                                                @"uri": @"ClientUriA",
                                                                                @"user_uri":@"some:user_uri"
                                                                                },@{@"uri": @"ClientUriA", @"user_uri": @"some:user_uri"});
            });

            it(@"should return the newly updated record", ^{
                [subject getAllClients] should equal(@[client]);
            });

        });

    });

    describe(@"-getAllClients", ^{

        it(@"should return all Client Types", ^{

            ClientType *clientA = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];
            ClientType *clientB = [[ClientType alloc] initWithName:@"ClientNameB" uri:@"ClientUriB"];
            ClientType *clientC = [[ClientType alloc] initWithName:@"ClientNameC" uri:@"ClientUriC"];
            [subject storeClients:@[clientA,clientB,clientC]];

            [subject getAllClients] should equal(@[clientA,clientB,clientC]);
        });

        it(@"should return older Client Types along with recent Client Types", ^{
            ClientType *clientA = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];
            ClientType *clientB = [[ClientType alloc] initWithName:@"ClientNameB" uri:@"ClientUriB"];
            ClientType *clientC = [[ClientType alloc] initWithName:@"ClientNameC" uri:@"ClientUriC"];

            [subject storeClients:@[clientA,clientB,clientC]];


            ClientType *recentClientA = [[ClientType alloc] initWithName:@"RecentClientNameA" uri:@"RecentClientUriA"];
            ClientType *recentClientB = [[ClientType alloc] initWithName:@"RecentClientNameB" uri:@"RecentClientUriB"];

            [subject storeClients:@[recentClientA,recentClientB]];

            [subject getAllClients] should equal(@[clientA,clientB,clientC,recentClientA,recentClientB]);
        });
    });

    describe(@"-getClientsWithMatchingText", ^{

        __block ClientType *clientA;
        __block ClientType *clientB;
        __block ClientType *clientC;
        __block ClientType *clientD;
        __block ClientType *clientE;
        __block ClientType *clientF;
        beforeEach(^{
            clientA = [[ClientType alloc] initWithName:@"Client0" uri:@"ClientUriA"];
            clientB = [[ClientType alloc] initWithName:@"Client1" uri:@"ClientUriB"];
            clientC = [[ClientType alloc] initWithName:@"Client2" uri:@"ClientUriC"];
            clientD = [[ClientType alloc] initWithName:@"Client3" uri:@"ClientUriA"];
            clientE = [[ClientType alloc] initWithName:@"Client4" uri:@"ClientUriB"];
            clientF = [[ClientType alloc] initWithName:@"Client5" uri:@"ClientUriC"];
            [subject storeClients:@[clientA,clientB,clientC,clientD,clientE,clientF]];


        });

        it(@"should return all Client Types matching the text", ^{
            [subject getClientsWithMatchingText:@"client"] should equal(@[clientD,clientE,clientF]);
        });

        it(@"should ask sqlite store for the Client info", ^{
            [subject getClientsWithMatchingText:@"a"];
            sqlLiteStore should have_received(@selector(readAllRowsFromColumn:where:pattern:)).with(@"name",@{@"user_uri": @"some:user_uri"},@"a");
        });

    });

    describe(@"-deleteAllClients", ^{
        beforeEach(^{
            ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
            [subject storeClients:@[client]];
        });

        context(@"user context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"some:user_uri");
                [subject deleteAllClients];
            });
            it(@"should remove all Client types", ^{
                [subject getAllClients] should be_empty;
                sqlLiteStore should have_received(@selector(deleteAllRows));
            });
        });
        context(@"supervisor context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"supervisor:user_uri");
                [subject deleteAllClients];
            });
            it(@"should remove all Client types", ^{
                [subject getAllClients] should be_empty;
                sqlLiteStore should have_received(@selector(deleteRowWithStringArgs:)).with(@"user_uri != 'supervisor:user_uri'");
            });
        });


    });

    describe(@"As a <DoorKeeperObserver>", ^{
        beforeEach(^{
            ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
            [subject storeClients:@[client]];

            [subject setUpWithUserUri:@"user:uri:new"];

            [subject doorKeeperDidLogOut:nil];
        });

        it(@"should remove all Client types", ^{
            [subject getAllClients] should be_empty;
        });
    });

    describe(@"-getClientInfoForUri:", ^{
        __block ClientType *expectedClient;
        __block ClientType *client;

        beforeEach(^{
            client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
            [subject storeClients:@[client]];
            [sqlLiteStore reset_sent_messages];
            expectedClient = [subject getClientInfoForUri:@"client-uri"];
        });

        it(@"should ask sqlite store for the client info", ^{
            sqlLiteStore should have_received(@selector(readAllRowsWithArgs:)).with(@{@"user_uri": @"some:user_uri",
                                                                                      @"uri":@"client-uri"});
        });

        it(@"should return the stored client correctly ", ^{
            expectedClient should equal(client);
        });
    });
});

SPEC_END
