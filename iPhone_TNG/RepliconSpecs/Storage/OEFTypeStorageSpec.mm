#import <Cedar/Cedar.h>
#import "OEFTypeStorage.h"
#import "SQLiteTableStore.h"
#import "SQLiteDatabaseConnection.h"
#import "QueryStringBuilder.h"
#import "OEFType.h"
#import "Constants.h"
#import "PunchActionTypes.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(OEFTypeStorageSpec)

describe(@"OEFTypeStorage", ^{
    __block OEFTypeStorage *subject;
    __block DoorKeeper *doorKeeper;
    __block SQLiteTableStore<CedarDouble> *sqlLiteStore;
    __block id<UserSession> userSession;

    beforeEach(^{

        sqlLiteStore = (id)[[SQLiteTableStore alloc] initWithSqliteDatabaseConnection:[[SQLiteDatabaseConnection alloc] init]
                                                                   queryStringBuilder:[[QueryStringBuilder alloc] init]
                                                                         databaseName:@"Test"
                                                                            tableName:@"user_oef_types"];
        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
        doorKeeper = nice_fake_for([DoorKeeper class]);


        subject = [[OEFTypeStorage alloc] initWithUserPermissionsStorage:NULL sqliteStore:sqlLiteStore userSession:userSession doorKeeper:doorKeeper punchActionTypeDeserializer:nil];

        spy_on(sqlLiteStore);

        [subject setUpWithUserUri:@"some:user_uri"];
        
    });
    
    context(@"setUp method to set userUri with nil", ^{
        beforeEach(^{
            [subject setUpWithUserUri:nil];
        });
        it(@"user uri should be read from current session", ^{
            subject.userSession.currentUserURI should equal(@"user:uri");
        });
    });
    
    
    describe(@"-storeOEFs", ^{

        __block OEFType *oefType;
        context(@"When inserting a fresh oefType in DB", ^{
            beforeEach(^{
                oefType = [[OEFType alloc] initWithUri:@"oef-uri" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name" punchActionType:@"PunchIn" numericValue:nil textValue:@"oef-text-value" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).with(@{@"uri": @"stored-oef-uri"}).and_return(nil);
                [subject storeOEFTypes:@[oefType]];
            });

            it(@"should delete all rows", ^{
                sqlLiteStore should have_received(@selector(deleteRowWithArgs:)).with(@{@"user_uri": @"some:user_uri"});
            });

            it(@"should insert the row into database", ^{
                sqlLiteStore should have_received(@selector(insertRow:)).with(@{
                                                                                @"uri":@"oef-uri",
                                                                                @"user_uri":@"some:user_uri",
                                                                                @"definitionTypeUri":@"urn:replicon:object-extension-definition-type:object-extension-type-text",
                                                                                @"name":@"oef-text-name",
                                                                                @"punchActionType":@"PunchIn",
                                                                                @"collectAtTimeOfPunch":@YES,
                                                                                @"numericValue":[NSNull null],
                                                                                @"textValue":@"oef-text-value",
                                                                                @"dropdownOptionUri":[NSNull null],
                                                                                @"dropdownOptionValue":[NSNull null]
                                                                                });
            });

            it(@"should return the newly inserted record", ^{
                [subject getOEFTypeForUri:@"oef-uri"] should equal(oefType);
            });
        });



        context(@"When oef types are not available", ^{
            beforeEach(^{
                [subject storeOEFTypes:@[]];
            });

            it(@"should insert the row into database", ^{
                sqlLiteStore should have_received(@selector(deleteRowWithArgs:)).with(@{@"user_uri": @"some:user_uri"});
            });

            it(@"should return the newly inserted record", ^{
                [subject getAllOEFS] should equal(@[]);
            });
        });
        
    });

    describe(@"As a <DoorKeeperObserver>", ^{
        beforeEach(^{

            OEFType *oefType = [[OEFType alloc] initWithUri:@"oef-uri" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name" punchActionType:@"PunchIn" numericValue:nil textValue:@"oef-text-value" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

           [subject storeOEFTypes:@[oefType]];

            [subject setUpWithUserUri:@"user:uri:new"];

            [subject doorKeeperDidLogOut:nil];
        });

        it(@"should remove all Client types", ^{
            [subject getAllOEFS] should be_empty;
        });
    });

    describe(@"-getOEFTypeForUri:", ^{
        __block OEFType *expectedOEFType;
        __block OEFType *oefype;

        beforeEach(^{
            oefype = [[OEFType alloc] initWithUri:@"oef-uri" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name" punchActionType:@"PunchIn" numericValue:nil textValue:@"oef-text-value" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];;
            [subject storeOEFTypes:@[oefype]];
            [sqlLiteStore reset_sent_messages];
            expectedOEFType = [subject getOEFTypeForUri:@"oef-uri"];
        });

        it(@"should ask sqlite store for the oef type info", ^{
            sqlLiteStore should have_received(@selector(readAllRowsWithArgs:)).with(@{@"user_uri": @"some:user_uri",
                                                                                      @"uri":@"oef-uri"});
        });

        it(@"should return the stored oef type correctly ", ^{
            expectedOEFType should equal(oefype);
        });
    });

    describe(@"-getAllOEFSForCollectAtTimeOfPunch:", ^{
        __block OEFType *oeftype1;
        __block OEFType *oeftype2;
        __block OEFType *oeftype3;
        __block OEFType *oeftype4;
        __block OEFType *oeftype5;
        __block OEFType *oeftype6;
        __block OEFType *oeftype7;
        __block OEFType *oeftype8;
        __block NSArray *expectedOEFTypesArray;

        beforeEach(^{
            oeftype1 = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name1" punchActionType:@"PunchIn" numericValue:nil textValue:@"oef-text-value-1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            oeftype2 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name2" punchActionType:@"PunchIn" numericValue:nil textValue:@"oef-text-value-2" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            oeftype3 = [[OEFType alloc] initWithUri:@"oef-uri-3" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name3" punchActionType:@"PunchOut" numericValue:nil textValue:@"oef-text-value-3" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            oeftype4 = [[OEFType alloc] initWithUri:@"oef-uri-4" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name3" punchActionType:@"PunchOut" numericValue:nil textValue:@"oef-text-value-4" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            [subject storeOEFTypes:@[oeftype1,oeftype2,oeftype3]];
            oeftype5 = [[OEFType alloc] initWithUri:@"oef-uri-5" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name1" punchActionType:@"StartBreak" numericValue:nil textValue:@"oef-text-value-5" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            oeftype6 = [[OEFType alloc] initWithUri:@"oef-uri-6" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name2" punchActionType:@"StartBreak" numericValue:nil textValue:@"oef-text-value-6" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            oeftype7 = [[OEFType alloc] initWithUri:@"oef-uri-7" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name3" punchActionType:@"Transfer" numericValue:nil textValue:@"oef-text-value-7" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            oeftype8 = [[OEFType alloc] initWithUri:@"oef-uri-8" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name3" punchActionType:@"Transfer" numericValue:nil textValue:@"oef-text-value-8" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            [subject storeOEFTypes:@[oeftype1,oeftype2,oeftype3,oeftype4,oeftype5,oeftype6,oeftype7,oeftype8]];


        });

        context(@"Punch In", ^{
            beforeEach(^{
                expectedOEFTypesArray = [subject getAllOEFSForCollectAtTimeOfPunch:PunchActionTypePunchIn];
            });

            it(@"should ask sqlite store for the oef type info", ^{
                sqlLiteStore should have_received(@selector(readAllRowsWithArgs:)).with(@{@"user_uri": @"some:user_uri", @"collectAtTimeOfPunch" : [NSNumber numberWithBool:YES], @"punchActionType" : @"PunchIn"});
            });

            it(@"should return the stored oef type correctly ", ^{
                expectedOEFTypesArray should equal(@[oeftype1]);
            });
        });

        context(@"Punch Out", ^{
            beforeEach(^{
                expectedOEFTypesArray = [subject getAllOEFSForCollectAtTimeOfPunch:PunchActionTypePunchOut];
            });

            it(@"should ask sqlite store for the oef type info", ^{
                sqlLiteStore should have_received(@selector(readAllRowsWithArgs:)).with(@{@"user_uri": @"some:user_uri", @"collectAtTimeOfPunch" : [NSNumber numberWithBool:YES], @"punchActionType" : @"PunchOut"});
            });

            it(@"should return the stored oef type correctly ", ^{
                expectedOEFTypesArray should equal(@[oeftype3]);
            });
        });

        context(@"Start Break", ^{
            beforeEach(^{
                expectedOEFTypesArray = [subject getAllOEFSForCollectAtTimeOfPunch:PunchActionTypeStartBreak];
            });

            it(@"should ask sqlite store for the oef type info", ^{
                sqlLiteStore should have_received(@selector(readAllRowsWithArgs:)).with(@{@"user_uri": @"some:user_uri", @"collectAtTimeOfPunch" : [NSNumber numberWithBool:YES], @"punchActionType" : @"StartBreak"});
            });

            it(@"should return the stored oef type correctly ", ^{
                expectedOEFTypesArray should equal(@[oeftype5]);
            });
        });

        context(@"Transfer", ^{
            beforeEach(^{
                expectedOEFTypesArray = [subject getAllOEFSForCollectAtTimeOfPunch:PunchActionTypeTransfer];
            });

            it(@"should ask sqlite store for the oef type info", ^{
                sqlLiteStore should have_received(@selector(readAllRowsWithArgs:)).with(@{@"user_uri": @"some:user_uri", @"collectAtTimeOfPunch" : [NSNumber numberWithBool:YES], @"punchActionType" : @"Transfer"});
            });

            it(@"should return the stored oef type correctly ", ^{
                expectedOEFTypesArray should equal(@[oeftype7]);
            });
        });
        


    });

    describe(@"-getAllOEFSForCollectAtTimeOfPunch:", ^{
        __block OEFType *oeftype1;
        __block OEFType *oeftype2;
        __block OEFType *oeftype3;
        __block OEFType *oeftype4;
        __block OEFType *oeftype5;

        __block NSArray *expectedOEFTypesArray;

        beforeEach(^{
            oeftype1 = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name1" punchActionType:@"PunchIn" numericValue:nil textValue:@"oef-text-value-1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            oeftype2 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name2" punchActionType:@"PunchIn" numericValue:nil textValue:@"oef-text-value-2" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            oeftype3 = [[OEFType alloc] initWithUri:@"oef-uri-9" definitionTypeUri:OEF_NUMERIC_DEFINITION_TYPE_URI name:@"oef-text-name3" punchActionType:@"PunchIn" numericValue:@"123" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            [subject storeOEFTypes:@[oeftype1,oeftype2,oeftype3]];

            oeftype4 = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name1" punchActionType:@"PunchIn" numericValue:nil textValue:@"new-oef-text-value-1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            oeftype5 = [[OEFType alloc] initWithUri:@"oef-uri-9" definitionTypeUri:OEF_NUMERIC_DEFINITION_TYPE_URI name:@"oef-text-name3" punchActionType:@"PunchIn" numericValue:@"new-123" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

        });

        context(@"Punch In", ^{
            beforeEach(^{
                expectedOEFTypesArray = [subject getUnionOEFArrayFromPunchCardOEF:@[oeftype4,oeftype5] andPunchActionType:PunchActionTypePunchIn];
            });

            it(@"should ask sqlite store for the oef type info", ^{
                sqlLiteStore should have_received(@selector(readAllRowsWithArgs:)).with(@{@"user_uri": @"some:user_uri", @"punchActionType" : @"PunchIn"});
            });

            it(@"should return the stored oef type correctly ", ^{
                expectedOEFTypesArray should equal(@[oeftype4,oeftype2,oeftype5]);
            });
        });

        
    });
    
    describe(@"-getAllOEFSForPunchActionType:", ^{
       
        __block OEFType *oeftype1;
        __block OEFType *oeftype2;
        __block OEFType *oeftype3;
        __block OEFType *oeftype4;
        __block OEFType *oeftype5;
        
        __block NSArray *expectedOEFTypesArray;
        
        beforeEach(^{
            oeftype1 = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name1" punchActionType:@"PunchIn" numericValue:nil textValue:@"oef-text-value-1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            oeftype2 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name2" punchActionType:@"PunchIn" numericValue:nil textValue:@"oef-text-value-2" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            oeftype3 = [[OEFType alloc] initWithUri:@"oef-uri-9" definitionTypeUri:OEF_NUMERIC_DEFINITION_TYPE_URI name:@"oef-text-name3" punchActionType:@"PunchOut" numericValue:@"123" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            oeftype4 = [[OEFType alloc] initWithUri:@"oef-uri-8" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name1" punchActionType:@"Transfer" numericValue:nil textValue:@"new-oef-text-value-1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            oeftype5 = [[OEFType alloc] initWithUri:@"oef-uri-7" definitionTypeUri:OEF_NUMERIC_DEFINITION_TYPE_URI name:@"oef-text-name3" punchActionType:@"StartBreak" numericValue:@"new-123" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            
            [subject storeOEFTypes:@[oeftype1, oeftype2, oeftype3, oeftype4, oeftype5]];
            
        });
        
        context(@"Get all OEFs of type Punch In", ^{
            beforeEach(^{
                expectedOEFTypesArray = [subject getAllOEFSForPunchActionType:PunchActionTypePunchIn];
            });
            
            it(@"should ask sqlite store for the oef type info", ^{
                sqlLiteStore should have_received(@selector(readAllRowsWithArgs:)).with(@{@"user_uri": @"some:user_uri", @"punchActionType" : @"PunchIn"});
            });
            
            it(@"should return the stored oef type correctly ", ^{
                expectedOEFTypesArray should equal(@[oeftype1,oeftype2]);
            });
        });
        
        context(@"Get all OEFs of type Punch Out", ^{
            beforeEach(^{
                expectedOEFTypesArray = [subject getAllOEFSForPunchActionType:PunchActionTypePunchOut];
            });
            
            it(@"should ask sqlite store for the oef type info", ^{
                sqlLiteStore should have_received(@selector(readAllRowsWithArgs:)).with(@{@"user_uri": @"some:user_uri", @"punchActionType" : @"PunchOut"});
            });
            
            it(@"should return the stored oef type correctly ", ^{
                expectedOEFTypesArray should equal(@[oeftype3]);
            });
        });
        
        context(@"Get all OEFs of type Transfer", ^{
            beforeEach(^{
                expectedOEFTypesArray = [subject getAllOEFSForPunchActionType:PunchActionTypeTransfer];
            });
            
            it(@"should ask sqlite store for the oef type info", ^{
                sqlLiteStore should have_received(@selector(readAllRowsWithArgs:)).with(@{@"user_uri": @"some:user_uri", @"punchActionType" : @"Transfer"});
            });
            
            it(@"should return the stored oef type correctly ", ^{
                expectedOEFTypesArray should equal(@[oeftype4]);
            });
        });
        
        context(@"Get all OEFs of type Start Break", ^{
            beforeEach(^{
                expectedOEFTypesArray = [subject getAllOEFSForPunchActionType:PunchActionTypeStartBreak];
            });
            
            it(@"should ask sqlite store for the oef type info", ^{
                sqlLiteStore should have_received(@selector(readAllRowsWithArgs:)).with(@{@"user_uri": @"some:user_uri", @"punchActionType" : @"StartBreak"});
            });
            
            it(@"should return the stored oef type correctly ", ^{
                expectedOEFTypesArray should equal(@[oeftype5]);
            });
        });
        
        describe(@"When getAllOEFSForPunchActionType returns no Value", ^{
            
             __block NSArray *expectedOEFTypesArray;
            __block OEFType *oeftype1;
            
            beforeEach(^{
                
                oeftype1 = [[OEFType alloc] initWithUri:@"oef-uri-9" definitionTypeUri:OEF_NUMERIC_DEFINITION_TYPE_URI name:@"oef-text-name3" punchActionType:@"PunchOut" numericValue:@"123" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                
                [subject storeOEFTypes:@[oeftype1]];
                
                expectedOEFTypesArray = [subject getAllOEFSForPunchActionType:PunchActionTypePunchIn];
            });
            
            it(@"should return nil", ^{
                expectedOEFTypesArray should equal(@[]);
            });
            
        });
        
    });

});

SPEC_END
