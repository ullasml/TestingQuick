#import <Cedar/Cedar.h>
#import "AstroClientPermissionStorage.h"
#import "SQLiteTableStore.h"
#import "SQLiteDatabaseConnection.h"
#import "QueryStringBuilder.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(AstroClientPermissionStorageSpec)

describe(@"AstroClientPermissionStorage", ^{
    __block AstroClientPermissionStorage *subject;
    __block DoorKeeper *doorKeeper;
    __block SQLiteTableStore<CedarDouble> *sqlLiteStore;
    __block id<UserSession> userSession;

    beforeEach(^{
        sqlLiteStore = (id)[[SQLiteTableStore alloc] initWithSqliteDatabaseConnection:[[SQLiteDatabaseConnection alloc] init]
                                                                   queryStringBuilder:[[QueryStringBuilder alloc] init]
                                                                         databaseName:@"Test"
                                                                            tableName:@"astro_client_access_storage"];
        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
        doorKeeper = nice_fake_for([DoorKeeper class]);
        subject = [[AstroClientPermissionStorage alloc] initWithSqliteStore:sqlLiteStore userSession:userSession doorKeeper:doorKeeper];
        
        spy_on(sqlLiteStore);
    });
    
    describe(@"-persistUserHasClientPermission:superVisorHasClientPermission:", ^{
        
        context(@"when the user doesn't exist - user flow", ^{
            beforeEach(^{
                sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).and_return(nil);
                [subject persistUserHasClientPermission:@YES];
                
                sqlLiteStore should have_received(@selector(readLastRowWithArgs:));
            });
            
            it(@"should have called insertRow", ^{
                sqlLiteStore should have_received(@selector(insertRow:)).with(@{@"has_client_permission": @YES,
                                                                                @"user_uri": @"user:uri"
                                                                                 });
            });
            
            it(@"should return empty resultSet for readLastRow", ^{
                NSDictionary *resultSet = [subject.sqliteStore readLastRowWithArgs:@{@"user_uri": @"user:uri"}];
                resultSet should be_nil;
            });
            
            it(@"should persist the client permission through its sqlite manager", ^{
                id<UserSession> userSession = nice_fake_for(@protocol(UserSession));
                userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
                sqlLiteStore should have_received(@selector(readLastRowWithArgs:)).with(@{@"user_uri": @"user:uri"});
            });
            
            it(@"should allow reading the client permission but /*returns nothing as we are stubbing */", ^{
                subject.userHasClientPermission should be_falsy;
                
            });
        });
        
        context(@"when the user doesn't exist - user flow", ^{
            beforeEach(^{
                [subject setUpWithUserUri:@"user:uri1"];
                sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).and_return(nil);
                [subject persistUserHasClientPermission:@YES];
                
                sqlLiteStore should have_received(@selector(readLastRowWithArgs:));
            });
            
            it(@"should have called insertRow", ^{
                sqlLiteStore should have_received(@selector(insertRow:)).with(@{@"has_client_permission": @YES,
                                                                                @"user_uri": @"user:uri1"
                                                                                });
            });
            
            it(@"should return empty resultSet for readLastRow", ^{
                NSDictionary *resultSet = [subject.sqliteStore readLastRowWithArgs:@{@"user_uri": @"user:uri"}];
                resultSet should be_nil;
            });
            
            it(@"should persist the client permission through its sqlite manager", ^{
                sqlLiteStore should have_received(@selector(readLastRowWithArgs:)).with(@{@"user_uri": @"user:uri1"});
            });
            
            it(@"should allow reading the client permission but /*returns nothing as we are stubbing */", ^{
                subject.userHasClientPermission should be_falsy;
                
            });
        });
        
        context(@"when the user already exist", ^{
            __block NSDictionary *expectedResultSet;
            beforeEach(^{
                expectedResultSet = @{
                                      @"has_client_permission" :@1,
                                      @"user_uri": @"user:uri"
                                      };
                
                sqlLiteStore stub_method(@selector(readLastRowWithArgs:))
                .with(@{@"user_uri" : @"user:uri"})
                .and_return(expectedResultSet);
                
                [subject persistUserHasClientPermission:@YES];
                
                sqlLiteStore should have_received(@selector(readLastRowWithArgs:));
            });
            
            it(@"should have called updateRow", ^{
                sqlLiteStore should have_received(@selector(updateRow:whereClause:)).with(expectedResultSet,nil);
            });
            
            it(@"should not return empty resultSet for readLastRow", ^{
                NSDictionary *resultSet = [subject.sqliteStore readLastRowWithArgs:@{@"user_uri" : @"user:uri"}];
                resultSet should_not be_nil;
            });
            
            it(@"should persist the client permission through its sqlite manager", ^{
                id<UserSession> userSession = nice_fake_for(@protocol(UserSession));
                userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
                sqlLiteStore should have_received(@selector(readLastRowWithArgs:)).with(@{@"user_uri" : @"user:uri"});
            });
            
            it(@"should allow reading the client permission", ^{
                subject.userHasClientPermission should be_truthy;
            });
            
        });
        
    });
    
    describe(@"As a <DoorKeeperObserver>", ^{
        beforeEach(^{
            [subject setUpWithUserUri:@"user:uri1"];
            [subject persistUserHasClientPermission:@YES];

            NSNumber  *userHasClientPermission = [NSNumber numberWithInt:1];
            [subject persistUserHasClientPermission:userHasClientPermission];
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
