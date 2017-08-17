#import <Cedar/Cedar.h>
#import "ViolationsStorage.h"
#import "SQLiteTableStore.h"
#import "SQLiteDatabaseConnection.h"
#import "QueryStringBuilder.h"
#import "Violation.h"
#import "RemotePunch.h"
#import "Enum.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ViolationsStorageSpec)

describe(@"ViolationsStorage", ^{
    __block ViolationsStorage *subject;
    __block DoorKeeper *doorKeeper;
    __block SQLiteTableStore<CedarDouble> *sqlLiteStore;

    beforeEach(^{
        sqlLiteStore = (id)[[SQLiteTableStore alloc] initWithSqliteDatabaseConnection:[[SQLiteDatabaseConnection alloc] init]
                                                                   queryStringBuilder:[[QueryStringBuilder alloc] init]
                                                                         databaseName:@"Test"
                                                                            tableName:@"violations"];
        doorKeeper = nice_fake_for([DoorKeeper class]);
        subject = [[ViolationsStorage alloc] initWithSqliteStore:sqlLiteStore
                                                      doorKeeper:doorKeeper];
        spy_on(sqlLiteStore);
    });


    describe(@"storePunchViolations", ^{
        __block RemotePunch *remotePunch1;
        __block Violation *Violation1;

        beforeEach(^{
            Violation1 =  nice_fake_for([Violation class]);
            
            Violation1 stub_method(@selector(title)).and_return(@"sometext");

            remotePunch1 =  nice_fake_for([RemotePunch class]);
            
            remotePunch1 stub_method(@selector(uri)).and_return(@"punch:uri:1");
            
            remotePunch1 stub_method(@selector(violations)).and_return(@[Violation1]);
            
            [subject storePunchViolations:@[remotePunch1]];
        });
        
        it(@"should store recore in db", ^{
            sqlLiteStore should have_received(@selector(insertRow:)).with(@{@"uri" : @"punch:uri:1",  @"displayText" : @"sometext"});
        });
    });

    describe(@"getPunchViolations", ^{
        __block RemotePunch *remotePunch;
        __block Violation *Violation1;
        __block Violation *Violation2;
        
        beforeEach(^{
            Violation1 =  nice_fake_for([Violation class]);
            Violation2 =  nice_fake_for([Violation class]);
            
            Violation1 stub_method(@selector(title)).and_return(@"sometext");
            Violation2 stub_method(@selector(title)).and_return(@"sometext");
            
            remotePunch =  nice_fake_for([RemotePunch class]);
            
            remotePunch stub_method(@selector(uri)).and_return(@"punch:uri:1");
            
            remotePunch stub_method(@selector(violations)).and_return(@[Violation1, Violation2]);
            
            [subject storePunchViolations:@[remotePunch]];
        });
        
        it(@"should return correct numer of violations", ^{
            [subject getPunchViolations:@"punch:uri:1"].count should equal(2);
        });
    });

    
    describe(@"deleteAllRows", ^{
        beforeEach(^{
            [subject deleteAllRows];
        });
        
        it(@"should remove all violations", ^{
            sqlLiteStore should have_received(@selector(deleteAllRows));
        });
    });

    describe(@"As a <DoorKeeperObserver>", ^{
        beforeEach(^{
            [subject doorKeeperDidLogOut:nil];
        });

        it(@"should remove all violations", ^{
            sqlLiteStore should have_received(@selector(deleteAllRows));
        });
    });

});

SPEC_END

