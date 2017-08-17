#import <Cedar/Cedar.h>
#import "ErrorDetailsStorage.h"
#import "SQLiteTableStore.h"
#import "SQLiteDatabaseConnection.h"
#import "QueryStringBuilder.h"
#import "ErrorDetails.h"
#import "UserPermissionsStorage.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;
SPEC_BEGIN(ErrorDetailsStorageSpec)

describe(@"ErrorDetailsStorage", ^{
    __block ErrorDetailsStorage *subject;
    __block NSUserDefaults *userDefaults;
    __block DoorKeeper *doorKeeper;
    __block SQLiteTableStore<CedarDouble> *sqlLiteStore;
    __block id<UserSession> userSession;
    __block UserPermissionsStorage *userPermissionsStorage;

    beforeEach(^{

        sqlLiteStore = (id)[[SQLiteTableStore alloc] initWithSqliteDatabaseConnection:[[SQLiteDatabaseConnection alloc] init]
                                                                   queryStringBuilder:[[QueryStringBuilder alloc] init]
                                                                         databaseName:@"Test"
                                                                            tableName:@"error_details"];

        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
        doorKeeper = nice_fake_for([DoorKeeper class]);
        userDefaults = nice_fake_for([NSUserDefaults class]);


        subject = [[ErrorDetailsStorage alloc] initWithUserPermissionsStorage:userPermissionsStorage
                                                              sqliteStore:sqlLiteStore
                                                             userDefaults:userDefaults
                                                              userSession:userSession
                                                               doorKeeper:doorKeeper];

        spy_on(sqlLiteStore);


    });




    describe(@"-storeErrorDetails", ^{

        __block ErrorDetails *errorDetails;
        context(@"When inserting a fresh ErrorDetails in DB", ^{
            beforeEach(^{
                errorDetails = [[ErrorDetails alloc] initWithUri:@"my-uri" errorMessage:@"custom" errorDate:@"2016-12-04 10:34:00 +0000" moduleName:@"my-module"];
                sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).and_return(nil);
                [subject storeErrorDetails:@[errorDetails]];
            });

            it(@"should insert the row into database", ^{
                sqlLiteStore should have_received(@selector(insertRow:)).with(@{@"uri": @"my-uri",
                                                                                @"error_msg": @"custom",
                                                                                @"date":@"2016-12-04 10:34:00 +0000",
                                                                                @"module":@"my-module"
                                                                                });
            });

            it(@"should return the newly inserted record", ^{
                [subject getAllErrorDetailsForModuleName:@"my-module"] should equal(@[errorDetails]);
            });
        });

        context(@"When updating a already stored ErrorDetails in DB", ^{

            beforeEach(^{
                ErrorDetails *storedErrorDetails = [[ErrorDetails alloc] initWithUri:@"my-uri" errorMessage:@"custom" errorDate:@"2016-12-04 10:34:00 +0000" moduleName:@"my-module"];

                [subject storeErrorDetails:@[storedErrorDetails]];

                sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).with(@{@"uri": @"my-uri"}).and_return(@{@"uri": @"my-uri",
                                                                                                                        @"error_msg": @"custom",
                                                                                                                        @"date":@"2016-12-04 10:34:00 +0000",
                                                                                                                        @"module":@"my-module"
                                                                                                                        });

                errorDetails = [[ErrorDetails alloc] initWithUri:@"my-uri" errorMessage:@"custom another msg" errorDate:@"2016-12-04 10:34:00 +0000" moduleName:@"my-module"];

                [subject storeErrorDetails:@[errorDetails]];
            });

            it(@"should update the row into database", ^{
                sqlLiteStore should have_received(@selector(updateRow:whereClause:)).with(@{@"uri": @"my-uri",
                                                                                            @"error_msg": @"custom another msg",
                                                                                            @"date":@"2016-12-04 10:34:00 +0000",
                                                                                            @"module":@"my-module"
                                                                                            },@{@"uri": @"my-uri"});
            });

            it(@"should return the newly updated record", ^{
                [subject getAllErrorDetailsForModuleName:@"my-module"] should equal(@[errorDetails]);
            });

        });

    });

  describe(@"-deleteAllErrorDetails", ^{

        beforeEach(^{
             ErrorDetails *storedErrorDetails = [[ErrorDetails alloc] initWithUri:@"my-uri" errorMessage:@"custom" errorDate:@"2016-12-04 10:34:00 +0000" moduleName:@"my-module"];
            [subject storeErrorDetails:@[storedErrorDetails]];
            [subject deleteAllErrorDetails];

        });

      it(@"should remove all ErrorDetails", ^{
          [subject getAllErrorDetailsForModuleName:@"my-module"] should be_nil;
          sqlLiteStore should have_received(@selector(deleteAllRows));
      });

    });

    describe(@"-deleteErrorDetails:", ^{

        beforeEach(^{
            ErrorDetails *storedErrorDetails1 = [[ErrorDetails alloc] initWithUri:@"my-uri" errorMessage:@"custom" errorDate:@"2016-12-04 10:34:00 +0000" moduleName:@"my-module"];
            ErrorDetails *storedErrorDetails2 = [[ErrorDetails alloc] initWithUri:@"my-uri-again" errorMessage:@"custom" errorDate:@"2016-12-04 10:34:00 +0000" moduleName:@"my-module"];
            [subject storeErrorDetails:@[storedErrorDetails1,storedErrorDetails2]];
            [subject deleteErrorDetails:@"my-uri"];

        });

        it(@"should remove ErrorDetails", ^{
            [subject getAllErrorDetailsForModuleName:@"my-module"].count should equal(1);
            sqlLiteStore should have_received(@selector(deleteRowWithArgs:)).with(@{@"uri" : @"my-uri"});
        });
        
    });

  describe(@"As a <DoorKeeperObserver>", ^{
        beforeEach(^{
            ErrorDetails *storedErrorDetails = [[ErrorDetails alloc] initWithUri:@"my-uri" errorMessage:@"custom" errorDate:@"2016-12-04 10:34:00 +0000" moduleName:@"my-module"];
            [subject storeErrorDetails:@[storedErrorDetails]];

            [subject doorKeeperDidLogOut:nil];
        });

        it(@"should remove all ErrorDetails types", ^{
            [subject getAllErrorDetailsForModuleName:@"my-module"] should be_nil;
        });
    });

   describe(@"-getAllErrorDetailsForModuleName:", ^{
        __block ErrorDetails *expectedErrorDetails;
        __block ErrorDetails *errorDetails;
        
        beforeEach(^{
            errorDetails = [[ErrorDetails alloc] initWithUri:@"my-uri" errorMessage:@"custom" errorDate:@"2016-12-04 10:34:00 +0000" moduleName:@"my-module"];
            [subject storeErrorDetails:@[errorDetails]];
            [sqlLiteStore reset_sent_messages];
            expectedErrorDetails = [subject getAllErrorDetailsForModuleName:@"my-module"][0];
        });
        
        it(@"should ask sqlite store for the ErrorDetails info", ^{
            sqlLiteStore should have_received(@selector(readAllRowsWithArgs:orderedBy:)).with(@{@"module": @"my-module"},@"date");
        });
        
        it(@"should return the stored ErrorDetails correctly ", ^{
            expectedErrorDetails should equal(errorDetails);
        });
    });
});

SPEC_END
