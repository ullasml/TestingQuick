#import <Cedar/Cedar.h>
#import "BreakTypeStorage.h"
#import "DoorKeeper.h"
#import "BreakType.h"
#import "SQLiteTableStore.h"
#import "SQLiteDatabaseConnection.h"
#import "QueryStringBuilder.h"
#import "UserSession.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(BreakTypeStorageSpec)

describe(@"BreakTypeStorage", ^{
    __block BreakTypeStorage *subject;
    __block DoorKeeper *doorKeeper;
    __block SQLiteTableStore *sqlLiteStore;

    beforeEach(^{
        id<UserSession> userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
        doorKeeper = nice_fake_for([DoorKeeper class]);
        sqlLiteStore = [[SQLiteTableStore alloc] initWithSqliteDatabaseConnection:[[SQLiteDatabaseConnection alloc] init]
                                                               queryStringBuilder:[[QueryStringBuilder alloc] init]
                                                                     databaseName:@"Test"
                                                                        tableName:@"user_break_types"];
        subject = [[BreakTypeStorage alloc] initWithSqliteStore:sqlLiteStore
                                                     doorKeeper:doorKeeper
                                                    userSession:userSession];
    });

    describe(@"-allBreakTypes", ^{
        it(@"should return all Break Types", ^{

            BreakType *breakTypeA = [[BreakType alloc] initWithName:@"BreakNameA" uri:@"BreakUriA"];
            BreakType *breakTypeB = [[BreakType alloc] initWithName:@"BreakNameB" uri:@"BreakUriB"];
            BreakType *breakTypeC = [[BreakType alloc] initWithName:@"BreakNameC" uri:@"BreakUriC"];
            [subject storeBreakTypes:@[breakTypeA,breakTypeB,breakTypeC] forUser:@"some-user:uri"];

            [subject allBreakTypesForUser:@"some-user:uri"] should equal(@[breakTypeA,breakTypeB,breakTypeC]);
        });

        it(@"should return only recent Break Types", ^{
            BreakType *oldBreakTypeA = [[BreakType alloc] initWithName:@"BreakNameA" uri:@"BreakUriA"];
            BreakType *oldBreakTypeB = [[BreakType alloc] initWithName:@"BreakNameB" uri:@"BreakUriB"];

            [subject storeBreakTypes:@[oldBreakTypeA,oldBreakTypeB] forUser:@"some-user:uri"];


            BreakType *recentbreakTypeA = [[BreakType alloc] initWithName:@"BreakNameA" uri:@"BreakUriA"];
            BreakType *recentbreakTypeB = [[BreakType alloc] initWithName:@"BreakNameB" uri:@"BreakUriB"];

            [subject storeBreakTypes:@[recentbreakTypeA,recentbreakTypeB] forUser:@"some-user:uri"];

            [subject allBreakTypesForUser:@"some-user:uri"] should equal(@[recentbreakTypeA,recentbreakTypeB]);
        });
    });

    describe(@"-removeAllBreakTypes", ^{
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
    });
});

SPEC_END
