#import <Cedar/Cedar.h>
#import "SQLiteTableStore.h"
#import "SQLiteDatabaseConnection.h"
#import "QueryStringBuilder.h"
#import "DefaultActivityStorage.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(DefaultActivityStorageSpec)

describe(@"DefaultActivityStorage", ^{
    __block DefaultActivityStorage *subject;

    __block DoorKeeper *doorKeeper;
    __block SQLiteTableStore<CedarDouble> *sqlLiteStore;
    __block id<UserSession> userSession;
    
    beforeEach(^{
        sqlLiteStore = (id)[[SQLiteTableStore alloc] initWithSqliteDatabaseConnection:[[SQLiteDatabaseConnection alloc] init]
                                                                   queryStringBuilder:[[QueryStringBuilder alloc] init]
                                                                         databaseName:@"Test"
                                                                            tableName:@"default_activity_table"];
        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
        doorKeeper = nice_fake_for([DoorKeeper class]);
        subject = [[DefaultActivityStorage alloc] initWithSqliteStore:sqlLiteStore userSession:userSession doorKeeper:doorKeeper];
        
        spy_on(sqlLiteStore);
    });
    
    describe(@"-persistDefaultActivityName:defaultActivityUri:", ^{
        
        context(@"when the user doesn't exist - user flow", ^{
            beforeEach(^{
                sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).and_return(nil);
                [subject persistDefaultActivityName:@"default-activity" defaultActivityUri:@"default-uri"];
                
                sqlLiteStore should have_received(@selector(readLastRowWithArgs:));
            });
            
            it(@"should have called insertRow", ^{
                sqlLiteStore should have_received(@selector(insertRow:)).with(@{@"default_activity_name": @"default-activity",
                                                                                @"default_activity_uri": @"default-uri",
                                                                                @"user_uri": @"user:uri"
                                                                                });
            });
            
            it(@"should return empty resultSet for readLastRow", ^{
                NSDictionary *resultSet = [subject.sqliteStore readLastRowWithArgs:@{@"user_uri": @"user:uri"}];
                resultSet should be_nil;
            });
            
            it(@"should persist the default activity details through its sqlite manager", ^{
                id<UserSession> userSession = nice_fake_for(@protocol(UserSession));
                userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
                sqlLiteStore should have_received(@selector(readLastRowWithArgs:)).with(@{@"user_uri": @"user:uri"});
            });
            
            it(@"should allow reading the default activity but /*returns nothing as we are stubbing */", ^{
                [subject defaultActivityDetails] should be_nil;
                
            });
        });
        
        context(@"when the user already exist", ^{
            __block NSDictionary *expectedResultSet;
            beforeEach(^{
                expectedResultSet = @{@"default_activity_name": @"default-activity",
                                      @"default_activity_uri": @"default-uri",
                                      @"user_uri": @"user:uri"
                                      };
                
                sqlLiteStore stub_method(@selector(readLastRowWithArgs:))
                .with(@{@"user_uri" : @"user:uri"})
                .and_return(expectedResultSet);
                
                [subject persistDefaultActivityName:@"default-activity" defaultActivityUri:@"default-uri"];
                
                sqlLiteStore should have_received(@selector(readLastRowWithArgs:));
            });
            
            it(@"should have called updateRow", ^{
                sqlLiteStore should have_received(@selector(updateRow:whereClause:)).with(expectedResultSet,nil);
            });
            
            it(@"should not return empty resultSet for readLastRow", ^{
                NSDictionary *resultSet = [subject.sqliteStore readLastRowWithArgs:@{@"user_uri" : @"user:uri"}];
                resultSet should_not be_nil;
            });
            
            it(@"should persist the default activity through its sqlite manager", ^{
                id<UserSession> userSession = nice_fake_for(@protocol(UserSession));
                userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
                sqlLiteStore should have_received(@selector(readLastRowWithArgs:)).with(@{@"user_uri" : @"user:uri"});
            });
            
            it(@"should allow reading the default activity", ^{
                NSDictionary *detailsDict = @{@"default_activity_name": @"default-activity",
                                              @"default_activity_uri": @"default-uri",
                                              @"user_uri": @"user:uri"
                                              };
                [subject defaultActivityDetails] should equal(detailsDict);
            });
            
        });
        
    });
    
    describe(@"As a <DoorKeeperObserver>", ^{
        beforeEach(^{
            [subject setUpWithUserUri:@"user:uri1"];
            [subject persistDefaultActivityName:@"default-activity1" defaultActivityUri:@"default-uri1"];
            
            [subject persistDefaultActivityName:@"default-activity" defaultActivityUri:@"default-uri"];
            userSession stub_method(@selector(currentUserURI)).again().and_return(@"user:uri:new");
            
            [subject doorKeeperDidLogOut:nil];
        });
        
        it(@"should remove all permissions", ^{
            NSDictionary *resultSet = [subject.sqliteStore readLastRowWithArgs:@{@"user_uri" : @"user:uri"}];
            resultSet should be_nil;
            NSDictionary *resultSet1 = [subject.sqliteStore readLastRowWithArgs:@{@"user_uri" : @"user:uri1"}];
            resultSet1 should be_nil;
            
        });
    });

});

SPEC_END
