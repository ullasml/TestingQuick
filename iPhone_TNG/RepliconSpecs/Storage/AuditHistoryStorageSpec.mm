#import <Cedar/Cedar.h>
#import "AuditHistoryStorage.h"
#import "DoorKeeper.h"
#import "SQLiteTableStore.h"
#import "SQLiteDatabaseConnection.h"
#import "QueryStringBuilder.h"
#import "UserSession.h"
#import "AuditHistory.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(AuditHistoryStorageSpec)

describe(@"AuditHistoryStorage", ^{
    __block AuditHistoryStorage *subject;
    __block DoorKeeper *doorKeeper;
    __block SQLiteTableStore *sqlLiteStore;
    
    beforeEach(^{
        id<UserSession> userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
        doorKeeper = nice_fake_for([DoorKeeper class]);
        sqlLiteStore = [[SQLiteTableStore alloc] initWithSqliteDatabaseConnection:[[SQLiteDatabaseConnection alloc] init]
                                                               queryStringBuilder:[[QueryStringBuilder alloc] init]
                                                                     databaseName:@"Test"
                                                                        tableName:@"audit_history_data"];
        subject = [[AuditHistoryStorage alloc] initWithSqliteStore:sqlLiteStore
                                                     doorKeeper:doorKeeper];
        
        [subject setUpWithUserUri:@"some-user-uri"];
    });
    
    describe(@"-storePunchLogs", ^{
        __block AuditHistory *expectedAuditHistory;
        beforeEach(^{
            
            expectedAuditHistory = [[AuditHistory alloc] initWithHistory:@[@"some-audit-log-a",
                                                                            @"some-audit-log-b"]
                                                                     uri:@"some-uri"];
            [subject storePunchLogs:@[@{@"records":@[@{@"displayText":@"some-audit-log-a"},
                                                      @{@"displayText":@"some-audit-log-b"}],
                                        @"uri":@"some-uri"}]];
        });
        
        it(@"should return the stored audit logs", ^{
            [subject getPunchLogs:@[@"some-uri"]] should equal(@[expectedAuditHistory]);
        });
    });
    
    describe(@"-deleteAllRows", ^{
        __block AuditHistory *expectedAuditHistory;
        beforeEach(^{
            
            expectedAuditHistory = [[AuditHistory alloc] initWithHistory:@[@"some-audit-log-a",
                                                                           @"some-audit-log-b"]
                                                                     uri:@"some-uri"];
            [subject storePunchLogs:@[@{@"records":@[@{@"displayText":@"some-audit-log-a"},
                                                     @{@"displayText":@"some-audit-log-b"}],
                                        @"uri":@"some-uri"}]];
        });
        
        it(@"should delete all the stored audit logs", ^{
            [subject deleteAllRows];
            [subject getPunchLogs:@[@"some-uri"]] should be_nil;
        });
    });
    
    /*describe(@"-removeAllBreakTypes", ^{
        beforeEach(^{
            BreakType *breakType = [[BreakType alloc] initWithName:@"BreakName" uri:@"BreakUri"];
            [subject storeBreakTypes:@[breakType] forUser:@"some-user:uri"];
            [subject removeAllBreakTypes];
        });
        
        it(@"should remove all break types", ^{
            [subject allBreakTypesForUser:@"some-user:uri"] should be_empty;
        });
        
        it(@"should remove all Break Types from persistent storage when the user uri is the same", ^{
            id<UserSession> sameUserSession = nice_fake_for(@protocol(UserSession));
            sameUserSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
            BreakTypeStorage *otherBreakStorage = [[BreakTypeStorage alloc] initWithSqliteStore:sqlLiteStore
                                                                                     doorKeeper:nil
                                                                                    userSession:sameUserSession];
            [otherBreakStorage allBreakTypesForUser:@"some-user:uri"] should be_empty;
        });
        
        it(@"should remove all Break Types from persistent storage when the user uri is the same", ^{
            id<UserSession> otherUserSession = nice_fake_for(@protocol(UserSession));
            otherUserSession stub_method(@selector(currentUserURI)).and_return(@"other:user:uri");
            BreakTypeStorage *otherBreakStorage = [[BreakTypeStorage alloc] initWithSqliteStore:sqlLiteStore
                                                                                     doorKeeper:nil
                                                                                    userSession:otherUserSession];
            BreakType *breakType = [[BreakType alloc] initWithName:@"Other Break" uri:@"other:break"];
            [otherBreakStorage storeBreakTypes:@[breakType] forUser:@"some-user:uri"];
            [otherBreakStorage allBreakTypesForUser:@"some-user:uri"] should equal(@[breakType]);
            
            [subject removeAllBreakTypes];
            [otherBreakStorage allBreakTypesForUser:@"some-user:uri"] should equal(@[]);
        });
    });
    
    describe(@"as a <DoorKeeperLogOutObserver>", ^{
        beforeEach(^{
            BreakType *breakType = [[BreakType alloc] initWithName:@"BreakName" uri:@"BreakUri"];
            [subject storeBreakTypes:@[breakType] forUser:@"some-user:uri"];
            [subject removeAllBreakTypes];
        });
        
        it(@"should add itself as an observer on the door keeper", ^{
            doorKeeper should have_received(@selector(addLogOutObserver:)).with(subject);
        });
        
        it(@"should remove all Break Types from memory", ^{
            [subject allBreakTypesForUser:@"some-user:uri"] should be_empty;
        });
        
        it(@"should remove all Break Types from persistent storage", ^{
            id<UserSession> sameUserSession = nice_fake_for(@protocol(UserSession));
            sameUserSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
            BreakTypeStorage *otherBreakStorage = [[BreakTypeStorage alloc] initWithSqliteStore:sqlLiteStore doorKeeper:nil userSession:sameUserSession];
            [otherBreakStorage allBreakTypesForUser:@"some-user:uri"] should be_empty;
        });
    });*/
});

SPEC_END
