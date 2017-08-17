#import <Cedar/Cedar.h>
#import "ExpenseClientStorage.h"
#import "SQLiteTableStore.h"
#import "SQLiteDatabaseConnection.h"
#import "QueryStringBuilder.h"
#import "ClientType.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ExpenseClientStorageSpec)

describe(@"ExpenseClientStorage", ^{
    __block ExpenseClientStorage *subject;

    __block NSUserDefaults *userDefaults;
    __block DoorKeeper *doorKeeper;
    __block SQLiteTableStore<CedarDouble> *sqlLiteStore;
    __block id<UserSession> userSession;
    
    beforeEach(^{
        
        sqlLiteStore = (id)[[SQLiteTableStore alloc] initWithSqliteDatabaseConnection:[[SQLiteDatabaseConnection alloc] init]
                                                                   queryStringBuilder:[[QueryStringBuilder alloc] init]
                                                                         databaseName:@"Test"
                                                                            tableName:@"expense_client_types"];
        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
        doorKeeper = nice_fake_for([DoorKeeper class]);
        userDefaults = nice_fake_for([NSUserDefaults class]);
        
        
        subject = [[ExpenseClientStorage alloc]initWithSqliteStore:sqlLiteStore
                                                      userDefaults:userDefaults
                                                       userSession:userSession
                                                        doorKeeper:doorKeeper];
        
        spy_on(sqlLiteStore);
        
    });
    
    
    describe(@"-lastDownloadedPageNumber", ^{
        
        it(@"should return 1 if there was no last Downloaded PageNumber", ^{
            NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
            lastDownloadedPageNumber should equal(@1);
        });
        
        it(@"should return correctly stored last Downloaded PageNumber", ^{
            userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedExpenseClientPageNumber").and_return(@4);
            NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
            lastDownloadedPageNumber should equal(@4);
        });
    });
    
    describe(@"-updatePageNumber", ^{
        
        it(@"should update last Downloaded PageNumber value with 1", ^{
            [subject updatePageNumber];
            userDefaults stub_method(@selector(setObject:forKey:)).with(@1, @"LastDownloadedExpenseClientPageNumber");
            userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedExpenseClientPageNumber").and_return(@1);
            NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
            lastDownloadedPageNumber should equal(@1);
        });
        
        it(@"should update last Downloaded PageNumber value correctly ", ^{
            userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedExpenseClientPageNumber").and_return(@4);
            userDefaults stub_method(@selector(setObject:forKey:)).with(@5, @"LastDownloadedExpenseClientPageNumber");
            [subject updatePageNumber];
            userDefaults stub_method(@selector(objectForKey:)).again().with(@"LastDownloadedExpenseClientPageNumber").and_return(@5);
            
            NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
            lastDownloadedPageNumber should equal(@5);
        });
    });
    
    describe(@"-resetPageNumber", ^{
        
        it(@"should reset the last Downloaded PageNumber", ^{
            [subject resetPageNumber];
            userDefaults should have_received(@selector(removeObjectForKey:)).with(@"LastDownloadedExpenseClientPageNumber");
        });
    });
    
    describe(@"-getLastPageNumberForFilteredSearch", ^{
        
        it(@"should return 1 if there was no last Downloaded PageNumber", ^{
            NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
            lastDownloadedPageNumber should equal(@1);
        });
        
        it(@"should return correctly stored last Downloaded PageNumber", ^{
            userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedFilteredExpenseClientPageNumber").and_return(@4);
            NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
            lastDownloadedPageNumber should equal(@4);
        });
    });
    
    describe(@"-updatePageNumberForFilteredSearch", ^{
        
        it(@"should update last Downloaded PageNumber value with 1", ^{
            [subject updatePageNumberForFilteredSearch];
            userDefaults stub_method(@selector(setObject:forKey:)).with(@1, @"LastDownloadedFilteredExpenseClientPageNumber");
            userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedFilteredExpenseClientPageNumber").and_return(@1);
            NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
            lastDownloadedPageNumber should equal(@1);
        });
        
        it(@"should update last Downloaded PageNumber value correctly ", ^{
            userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedFilteredExpenseClientPageNumber").and_return(@4);
            userDefaults stub_method(@selector(setObject:forKey:)).with(@5, @"LastDownloadedFilteredExpenseClientPageNumber");
            [subject updatePageNumber];
            userDefaults stub_method(@selector(objectForKey:)).again().with(@"LastDownloadedFilteredExpenseClientPageNumber").and_return(@5);
            
            NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
            lastDownloadedPageNumber should equal(@5);
        });
    });
    
    describe(@"-resetPageNumberForFilteredSearch", ^{
        
        it(@"should reset the last Downloaded PageNumber", ^{
            [subject resetPageNumberForFilteredSearch];
            userDefaults should have_received(@selector(removeObjectForKey:)).with(@"LastDownloadedFilteredExpenseClientPageNumber");
        });
    });
    
    describe(@"-storeClients", ^{
        
        __block ClientType *client;
        __block ClientType *noneClient;
        context(@"When inserting a fresh client in DB", ^{
            beforeEach(^{
                client = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];
                noneClient = [[ClientType alloc] initWithName:RPLocalizedString(@"None", @"") uri:nil];
                sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).and_return(nil);
                [subject storeClients:@[client]];
            });
            
            it(@"should insert the row into database", ^{
                sqlLiteStore should have_received(@selector(insertRow:)).with(@{@"name": @"ClientNameA",
                                                                                @"uri": @"ClientUriA",
                                                                                @"user_uri":@"user:uri"
                                                                                });
            });
            
            it(@"should return the newly inserted record", ^{
                [subject getAllClients] should equal(@[noneClient,client]);
            });
        });
        
        context(@"When updating a already stored client in DB", ^{
            
            beforeEach(^{
                ClientType *storedClient = [[ClientType alloc] initWithName:@"StoredClient" uri:@"ClientUriA"];
                noneClient = [[ClientType alloc] initWithName:RPLocalizedString(@"None", @"") uri:nil];
                [subject storeClients:@[storedClient]];
                
                sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).with(@{@"uri": @"ClientUriA"}).and_return(@{
                                                                                                                      @"name": @"StoredClient",
                                                                                                                      @"uri": @"ClientUriA",
                                                                                                                      @"user_uri":@"user:uri"
                                                                                                                      });
                
                client = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];
                
                [subject storeClients:@[client]];
            });
            
            it(@"should insert the row into database", ^{
                sqlLiteStore should have_received(@selector(updateRow:whereClause:)).with(@{@"name": @"ClientNameA",
                                                                                @"uri": @"ClientUriA",
                                                                                @"user_uri":@"user:uri"
                                                                                },nil);
            });
            
            it(@"should return the newly updated record", ^{
                NSArray *clientsArr = [subject getAllClients];
                NSArray *arr = @[noneClient,client];

                clientsArr should equal(arr);
            });
            
        });
        
    });
    
    describe(@"-getAllClients", ^{
        __block ClientType *noneClient;
        beforeEach(^{
            noneClient = [[ClientType alloc] initWithName:RPLocalizedString(@"None", @"") uri:nil];
        });
        
        it(@"should return all Client Types", ^{
            
            ClientType *clientA = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];
            ClientType *clientB = [[ClientType alloc] initWithName:@"ClientNameB" uri:@"ClientUriB"];
            ClientType *clientC = [[ClientType alloc] initWithName:@"ClientNameC" uri:@"ClientUriC"];
            [subject storeClients:@[clientA,clientB,clientC]];
            
            [subject getAllClients] should equal(@[noneClient,clientA,clientB,clientC]);
        });
        
        it(@"should return older Client Types along with recent Client Types", ^{
            ClientType *clientA = [[ClientType alloc] initWithName:@"ClientNameA" uri:@"ClientUriA"];
            ClientType *clientB = [[ClientType alloc] initWithName:@"ClientNameB" uri:@"ClientUriB"];
            ClientType *clientC = [[ClientType alloc] initWithName:@"ClientNameC" uri:@"ClientUriC"];
            
            [subject storeClients:@[clientA,clientB,clientC]];
            
            
            ClientType *recentClientA = [[ClientType alloc] initWithName:@"RecentClientNameA" uri:@"RecentClientUriA"];
            ClientType *recentClientB = [[ClientType alloc] initWithName:@"RecentClientNameB" uri:@"RecentClientUriB"];
            
            [subject storeClients:@[recentClientA,recentClientB]];
            
            [subject getAllClients] should equal(@[noneClient,clientA,clientB,clientC,recentClientA,recentClientB]);
        });
    });
    
    describe(@"-getClientsWithMatchingText", ^{
        
        it(@"should return all Client Types matching the text", ^{

            ClientType *noneClient = [[ClientType alloc] initWithName:RPLocalizedString(@"None", @"") uri:nil];
            ClientType *clientA = [[ClientType alloc] initWithName:@"Apple" uri:@"ClientUriA"];
            ClientType *clientB = [[ClientType alloc] initWithName:@"Amogh" uri:@"ClientUriB"];
            ClientType *clientC = [[ClientType alloc] initWithName:@"Anand" uri:@"ClientUriC"];
            ClientType *clientD = [[ClientType alloc] initWithName:@"Client0" uri:@"ClientUriA"];
            ClientType *clientE = [[ClientType alloc] initWithName:@"Client1" uri:@"ClientUriB"];
            ClientType *clientF = [[ClientType alloc] initWithName:@"Client2" uri:@"ClientUriC"];
            [subject storeClients:@[clientA,clientB,clientC,clientD,clientE,clientF]];
            
            [subject getClientsWithMatchingText:@"a"] should equal(@[noneClient,clientA,clientB,clientC]);
        });
    });
    
    describe(@"-deleteAllClients", ^{
        beforeEach(^{
            ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
            [subject storeClients:@[client]];
            [subject deleteAllClients];
        });
        
        it(@"should remove all Client types and the first element will be none client type", ^{
            NSArray *clientsArr = [subject getAllClients];
            clientsArr.count  should equal(1);
            ClientType *clientType = clientsArr.firstObject;
            clientType.name should equal(RPLocalizedString(@"None", @""));
            clientType.uri should be_nil;
            sqlLiteStore should have_received(@selector(deleteAllRows));
        });
    });
    
    describe(@"As a <DoorKeeperObserver>", ^{
        beforeEach(^{
            ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
            [subject storeClients:@[client]];
            
            userSession stub_method(@selector(currentUserURI)).again().and_return(@"user:uri:new");
            
            [subject doorKeeperDidLogOut:nil];
        });
        
        it(@"should remove all Client types and the first element will be none client type", ^{
            NSArray *clientsArr = [subject getAllClients];
            clientsArr.count  should equal(1);
            ClientType *clientType = clientsArr.firstObject;
            clientType.name should equal(RPLocalizedString(@"None", @""));
            clientType.uri should be_nil;

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
            sqlLiteStore should have_received(@selector(readAllRowsWithArgs:)).with(@{@"user_uri": @"user:uri",
                                                                                      @"uri":@"client-uri"});
        });
        
        it(@"should return the stored client correctly ", ^{
            expectedClient should equal(client);
        });
    });
});

SPEC_END
