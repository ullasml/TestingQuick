
#import <Cedar/Cedar.h>
#import "OEFDropdownStorage.h"
#import "SQLiteTableStore.h"
#import "SQLiteDatabaseConnection.h"
#import "QueryStringBuilder.h"
#import "OEFDropDownType.h"
#import "UserPermissionsStorage.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(OEFDropdownStorageSpec)

describe(@"OEFDropdownStorage", ^{
    __block OEFDropdownStorage *subject;
    __block NSUserDefaults *userDefaults;
    __block DoorKeeper *doorKeeper;
    __block SQLiteTableStore<CedarDouble> *sqlLiteStore;
    __block id<UserSession> userSession;
    __block UserPermissionsStorage *userPermissionsStorage;

    beforeEach(^{

        sqlLiteStore = (id)[[SQLiteTableStore alloc] initWithSqliteDatabaseConnection:[[SQLiteDatabaseConnection alloc] init]
                                                                   queryStringBuilder:[[QueryStringBuilder alloc] init]
                                                                         databaseName:@"Test"
                                                                            tableName:@"user_oef_dropdown_types"];

        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
        doorKeeper = nice_fake_for([DoorKeeper class]);
        userDefaults = nice_fake_for([NSUserDefaults class]);


        subject = [[OEFDropdownStorage alloc] initWithUserPermissionsStorage:userPermissionsStorage
                                                              sqliteStore:sqlLiteStore
                                                             userDefaults:userDefaults
                                                              userSession:userSession
                                                               doorKeeper:doorKeeper];

        userPermissionsStorage stub_method(@selector(isActivitySelectionRequired)).and_return(YES);

        spy_on(sqlLiteStore);

        [subject setUpWithDropDownOEFUri:@"some:dropdownoef:uri" userUri:@"some:user_uri"];

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
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedOEFDropDownOptionsPageNumber").and_return(@4);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
                lastDownloadedPageNumber should equal(@4);
            });

            it(@"should return correctly stored last Downloaded PageNumber For User if Supervisor last Downloaded PageNumber is diffrent", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedOEFDropDownOptionsPageNumber").and_return(@4);
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedOEFDropDownOptionsPageNumber").and_return(@2);
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
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedOEFDropDownOptionsPageNumber").and_return(@4);
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
                userDefaults stub_method(@selector(setObject:forKey:)).with(@1, @"LastDownloadedOEFDropDownOptionsPageNumber");
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedOEFDropDownOptionsPageNumber").and_return(@1);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
                lastDownloadedPageNumber should equal(@1);
            });

            it(@"should update last Downloaded PageNumber value correctly ", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedOEFDropDownOptionsPageNumber").and_return(@4);
                userDefaults stub_method(@selector(setObject:forKey:)).with(@5, @"LastDownloadedOEFDropDownOptionsPageNumber");
                [subject updatePageNumber];
                userDefaults stub_method(@selector(objectForKey:)).again().with(@"LastDownloadedOEFDropDownOptionsPageNumber").and_return(@5);

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
                userDefaults stub_method(@selector(setObject:forKey:)).with(@1, @"SupervisorLastDownloadedOEFDropDownOptionsPageNumber");
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedOEFDropDownOptionsPageNumber").and_return(@1);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumber];
                lastDownloadedPageNumber should equal(@1);
            });

            it(@"should update last Downloaded PageNumber value correctly ", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedOEFDropDownOptionsPageNumber").and_return(@4);
                userDefaults stub_method(@selector(setObject:forKey:)).with(@5, @"SupervisorLastDownloadedOEFDropDownOptionsPageNumber");
                [subject updatePageNumber];
                userDefaults stub_method(@selector(objectForKey:)).again().with(@"SupervisorLastDownloadedOEFDropDownOptionsPageNumber").and_return(@5);

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
                userDefaults should have_received(@selector(removeObjectForKey:)).with(@"LastDownloadedOEFDropDownOptionsPageNumber");
            });
        });

        context(@"supervisor context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"supervisor:user_uri");
            });
            it(@"should reset the last Downloaded PageNumber", ^{
                [subject resetPageNumber];
                userDefaults should have_received(@selector(removeObjectForKey:)).with(@"SupervisorLastDownloadedOEFDropDownOptionsPageNumber");
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
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedFilteredOEFDropDownOptionsPageNumber").and_return(@4);
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
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedFilteredOEFDropDownOptionsPageNumber").and_return(@4);
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
                userDefaults stub_method(@selector(setObject:forKey:)).with(@1, @"LastDownloadedFilteredOEFDropDownOptionsPageNumber");
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedFilteredOEFDropDownOptionsPageNumber").and_return(@1);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
                lastDownloadedPageNumber should equal(@1);
            });

            it(@"should update last Downloaded PageNumber value correctly ", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"LastDownloadedFilteredOEFDropDownOptionsPageNumber").and_return(@4);
                userDefaults stub_method(@selector(setObject:forKey:)).with(@5, @"LastDownloadedFilteredOEFDropDownOptionsPageNumber");
                [subject updatePageNumber];
                userDefaults stub_method(@selector(objectForKey:)).again().with(@"LastDownloadedFilteredOEFDropDownOptionsPageNumber").and_return(@5);

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
                userDefaults stub_method(@selector(setObject:forKey:)).with(@1, @"SupervisorLastDownloadedFilteredOEFDropDownOptionsPageNumber");
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedFilteredOEFDropDownOptionsPageNumber").and_return(@1);
                NSNumber *lastDownloadedPageNumber = [subject getLastPageNumberForFilteredSearch];
                lastDownloadedPageNumber should equal(@1);
            });

            it(@"should update last Downloaded PageNumber value correctly ", ^{
                userDefaults stub_method(@selector(objectForKey:)).with(@"SupervisorLastDownloadedFilteredOEFDropDownOptionsPageNumber").and_return(@4);
                userDefaults stub_method(@selector(setObject:forKey:)).with(@5, @"SupervisorLastDownloadedFilteredOEFDropDownOptionsPageNumber");
                [subject updatePageNumber];
                userDefaults stub_method(@selector(objectForKey:)).again().with(@"SupervisorLastDownloadedFilteredOEFDropDownOptionsPageNumber").and_return(@5);

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
                userDefaults should have_received(@selector(removeObjectForKey:)).with(@"LastDownloadedFilteredOEFDropDownOptionsPageNumber");
            });
        });

        context(@"supervisor context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"supervisor:user_uri");
            });
            it(@"should reset the last Downloaded PageNumber", ^{
                [subject resetPageNumberForFilteredSearch];
                userDefaults should have_received(@selector(removeObjectForKey:)).with(@"SupervisorLastDownloadedFilteredOEFDropDownOptionsPageNumber");
            });
        });

    });

    describe(@"-storeOEFDropDownType", ^{

        __block OEFDropDownType *oefDropDownType;
        __block OEFDropDownType *none;
        context(@"When inserting a fresh OEFDropDownType in DB", ^{
            beforeEach(^{
                none = [[OEFDropDownType alloc] initWithName:RPLocalizedString(@"None", nil) uri:nil];
                oefDropDownType = [[OEFDropDownType alloc] initWithName:@"OEFDropDownNameA" uri:@"OEFDropDownUriA"];
                sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).and_return(nil);
                [subject storeOEFDropDownOptions:@[oefDropDownType]];
            });

            it(@"should insert the row into database", ^{
                sqlLiteStore should have_received(@selector(insertRow:)).with(@{@"name": @"OEFDropDownNameA",
                                                                                @"uri": @"OEFDropDownUriA",
                                                                                @"oef_uri":@"some:dropdownoef:uri"
                                                                                });
            });

            it(@"should return the newly inserted record", ^{
                [subject getAllOEFDropDownOptions] should equal(@[none,oefDropDownType]);
            });
        });

        context(@"When updating a already stored OEFDropDownType in DB", ^{

            beforeEach(^{
                 none = [[OEFDropDownType alloc] initWithName:RPLocalizedString(@"None", nil) uri:nil];
                OEFDropDownType *storedOEFDropDownType = [[OEFDropDownType alloc] initWithName:@"StoredOEFDropDownType" uri:@"OEFDropDownTypeUriA"];

                [subject storeOEFDropDownOptions:@[storedOEFDropDownType]];

                sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).with(@{@"uri": @"OEFDropDownTypeUriA"}).and_return(@{
                                                                                                                      @"name": @"StoredOEFDropDownType",
                                                                                                                      @"uri": @"OEFDropDownTypeUriA",
                                                                                                                       @"oef_uri":@"some:dropdownoef:uri"
                                                                                                                      });

                oefDropDownType = [[OEFDropDownType alloc] initWithName:@"OEFDropDownNameA" uri:@"OEFDropDownTypeUriA"];

                [subject storeOEFDropDownOptions:@[oefDropDownType]];
            });

            it(@"should insert the row into database", ^{
                sqlLiteStore should have_received(@selector(updateRow:whereClause:)).with(@{@"name": @"OEFDropDownNameA",
                                                                                @"uri": @"OEFDropDownTypeUriA",
                                                                                @"oef_uri":@"some:dropdownoef:uri",
                                                                                @"name":@"OEFDropDownNameA"
                                                                                 },@{@"uri": @"OEFDropDownTypeUriA"});
            });

            it(@"should return the newly updated record", ^{
                [subject getAllOEFDropDownOptions] should equal(@[none,oefDropDownType]);
            });

        });

    });

    describe(@"-getAllOEFDropDownOptions", ^{

        it(@"should return all OEFDropDownType", ^{

            OEFDropDownType *none = [[OEFDropDownType alloc] initWithName:RPLocalizedString(@"None", nil) uri:nil];
            OEFDropDownType *oefDropDownTypeA = [[OEFDropDownType alloc] initWithName:@"OEFDropDownTypeNameA" uri:@"OEFDropDownTypeUriA"];
            OEFDropDownType *oefDropDownTypeB = [[OEFDropDownType alloc] initWithName:@"OEFDropDownTypeNameB" uri:@"OEFDropDownTypeUriB"];
            OEFDropDownType *oefDropDownTypeC = [[OEFDropDownType alloc] initWithName:@"OEFDropDownTypeNameC" uri:@"OEFDropDownTypeUriC"];
            [subject storeOEFDropDownOptions:@[oefDropDownTypeA,oefDropDownTypeB,oefDropDownTypeC]];

            [subject getAllOEFDropDownOptions] should equal(@[none,oefDropDownTypeA,oefDropDownTypeB,oefDropDownTypeC]);
        });

        it(@"should return older OEFDropDownType Types along with recent OEFDropDownType Types", ^{
            OEFDropDownType *none = [[OEFDropDownType alloc] initWithName:RPLocalizedString(@"None", nil) uri:nil];
            OEFDropDownType *oefDropDownTypeA = [[OEFDropDownType alloc] initWithName:@"OEFDropDownTypeNameA" uri:@"OEFDropDownTypeUriA"];
            OEFDropDownType *oefDropDownTypeB = [[OEFDropDownType alloc] initWithName:@"OEFDropDownTypeNameB" uri:@"OEFDropDownTypeUriB"];
            OEFDropDownType *oefDropDownTypeC = [[OEFDropDownType alloc] initWithName:@"OEFDropDownTypeNameC" uri:@"OEFDropDownTypeUriC"];

            [subject storeOEFDropDownOptions:@[oefDropDownTypeA,oefDropDownTypeB,oefDropDownTypeC]];


            OEFDropDownType *recentOEFDropDownTypeA = [[OEFDropDownType alloc] initWithName:@"RecentOEFDropDownTypeNameA" uri:@"RecentOEFDropDownTypeUriA"];
            OEFDropDownType *recentOEFDropDownTypeB = [[OEFDropDownType alloc] initWithName:@"RecentOEFDropDownTypeNameB" uri:@"RecentOEFDropDownTypeUriB"];

            [subject storeOEFDropDownOptions:@[recentOEFDropDownTypeA,recentOEFDropDownTypeB]];

            [subject getAllOEFDropDownOptions] should equal(@[none,oefDropDownTypeA,oefDropDownTypeB,oefDropDownTypeC,recentOEFDropDownTypeA,recentOEFDropDownTypeB]);
        });
    });

    describe(@"-getOEFDropDownOptionsWithMatchingText:", ^{

         __block OEFDropDownType *oefDropDownTypeA;
         __block OEFDropDownType *oefDropDownTypeB;
         __block OEFDropDownType *oefDropDownTypeC;
         __block OEFDropDownType *oefDropDownTypeD;
         __block OEFDropDownType *oefDropDownTypeE;
         __block OEFDropDownType *oefDropDownTypeF;
        __block OEFDropDownType *none;
        beforeEach(^{
            none = [[OEFDropDownType alloc] initWithName:RPLocalizedString(@"None", nil) uri:nil];
            oefDropDownTypeA = [[OEFDropDownType alloc] initWithName:@"Apple" uri:@"OEFDropDownTypeUriA"];
            oefDropDownTypeB = [[OEFDropDownType alloc] initWithName:@"Amogh" uri:@"OEFDropDownTypeUriB"];
            oefDropDownTypeC = [[OEFDropDownType alloc] initWithName:@"Anand" uri:@"OEFDropDownTypeUriC"];
            oefDropDownTypeD = [[OEFDropDownType alloc] initWithName:@"OEFDropDownType0" uri:@"OEFDropDownTypeUriA"];
            oefDropDownTypeE = [[OEFDropDownType alloc] initWithName:@"OEFDropDownType1" uri:@"OEFDropDownTypeUriB"];
            oefDropDownTypeF = [[OEFDropDownType alloc] initWithName:@"OEFDropDownType2" uri:@"OEFDropDownTypeUriC"];
            [subject storeOEFDropDownOptions:@[oefDropDownTypeA,oefDropDownTypeB,oefDropDownTypeC,oefDropDownTypeD,oefDropDownTypeE,oefDropDownTypeF]];
        });

        it(@"should return all OEFDropDownType matching the text", ^{
            [subject getOEFDropDownOptionsWithMatchingText:@"oef"] should equal(@[none,oefDropDownTypeD,oefDropDownTypeE,oefDropDownTypeF]);
        });

        it(@"should return null OEFDropDownType matching the text", ^{
            [subject getOEFDropDownOptionsWithMatchingText:@"a"] should be_nil;
        });

        it(@"should ask sqlite store for the OEFDropDownType info", ^{
            [subject getOEFDropDownOptionsWithMatchingText:@"oef"];
            sqlLiteStore should have_received(@selector(readAllRowsFromColumn:where:pattern:)).with(@"name",@{@"oef_uri": @"some:dropdownoef:uri"},@"oef");
        });
    });

    describe(@"-deleteAllOEFDropDownOptions", ^{

        beforeEach(^{
            OEFDropDownType *oefDropDownType = [[OEFDropDownType alloc]initWithName:@"OEFDropDownType-name" uri:@"OEFDropDownType-uri"];
            [subject storeOEFDropDownOptions:@[oefDropDownType]];

        });

        context(@"user context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"some:user_uri");
                [subject deleteAllOEFDropDownOptions];
            });
            it(@"should remove all OEFDropDownType types", ^{
                [subject getAllOEFDropDownOptions] should be_nil;
                sqlLiteStore should have_received(@selector(deleteAllRows));
           });
        });
        context(@"supervisor context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"supervisor:user_uri");
                [subject deleteAllOEFDropDownOptions];
            });
            it(@"should remove all OEFDropDownType", ^{
                [subject getAllOEFDropDownOptions] should be_nil;
                sqlLiteStore should have_received(@selector(deleteAllRows));
            });
        });




    });

    describe(@"-deleteAllOEFDropDownOptions", ^{
        __block OEFDropDownType *oefDropDownType;
        __block OEFDropDownType *none;
        beforeEach(^{
            none = [[OEFDropDownType alloc] initWithName:RPLocalizedString(@"None", nil) uri:nil];
            oefDropDownType = [[OEFDropDownType alloc]initWithName:@"OEFDropDownType-name" uri:@"OEFDropDownType-uri"];
            [subject storeOEFDropDownOptions:@[oefDropDownType]];
            [subject setUpWithDropDownOEFUri:@"some:new:dropdownoef:uri" userUri:@"some:user_uri"];
            [subject storeOEFDropDownOptions:@[oefDropDownType]];

        });

        context(@"user context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"some:user_uri");
                [subject deleteAllOEFDropDownOptionsForOEFUri:@"some:dropdownoef:uri"];
            });
            it(@"should remove all OEFDropDownType types", ^{
                [subject getAllOEFDropDownOptions] should equal(@[none,oefDropDownType]);
                sqlLiteStore should have_received(@selector(deleteRowWithArgs:)).with(@{@"oef_uri":@"some:dropdownoef:uri"});
            });
        });
        context(@"supervisor context", ^{
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).again().and_return(@"supervisor:user_uri");
                [subject deleteAllOEFDropDownOptionsForOEFUri:@"some:dropdownoef:uri"];
            });
            it(@"should remove all OEFDropDownType", ^{
                [subject getAllOEFDropDownOptions] should equal(@[none,oefDropDownType]);
                sqlLiteStore should have_received(@selector(deleteRowWithArgs:)).with(@{@"oef_uri":@"some:dropdownoef:uri"});
            });
        });
        
        
        
        
    });

    describe(@"As a <DoorKeeperObserver>", ^{
        beforeEach(^{
            OEFDropDownType *oefDropDownType = [[OEFDropDownType alloc]initWithName:@"OEFDropDownType-name" uri:@"OEFDropDownType-uri"];
            [subject storeOEFDropDownOptions:@[oefDropDownType]];

            [subject setUpWithDropDownOEFUri:@"oef:dropdown:uri:new" userUri:@"some:new:user:uri"];

            [subject doorKeeperDidLogOut:nil];
        });

        it(@"should remove all OEFDropDownType", ^{
            [subject getAllOEFDropDownOptions] should be_nil;
        });
    });

    describe(@"-getActivityInfoForUri:", ^{
        __block OEFDropDownType *expectedOEFDropDownType;
        __block OEFDropDownType *oefDropDownType;

        beforeEach(^{
            oefDropDownType = [[OEFDropDownType alloc]initWithName:@"OEFDropDownType-name" uri:@"OEFDropDownType-uri"];
            [subject storeOEFDropDownOptions:@[oefDropDownType]];
            [sqlLiteStore reset_sent_messages];
            expectedOEFDropDownType = [subject getOEFDropDownOptionsInfoForUri:@"OEFDropDownType-uri"];
        });
        
        it(@"should ask sqlite store for the OEFDropDownType info", ^{
            sqlLiteStore should have_received(@selector(readAllRowsWithArgs:)).with(@{@"oef_uri": @"some:dropdownoef:uri",
                                                                                      @"uri":@"OEFDropDownType-uri"});
        });
        
        it(@"should return the stored Activity correctly ", ^{
            expectedOEFDropDownType should equal(oefDropDownType);
        });
    });
});

SPEC_END

