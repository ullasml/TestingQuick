#import <Cedar/Cedar.h>
#import "PunchOEFStorage.h"
#import "Constants.h"
#import "SQLiteDatabaseConnection.h"
#import "SQLiteTableStore.h"
#import "QueryStringBuilder.h"
#import "OEFType.h"
#import "Punch.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PunchOEFStorageSpec)

describe(@"PunchOEFStorage", ^{
    __block PunchOEFStorage *subject;
    __block SQLiteTableStore<CedarDouble> *sqlLiteStore;
    __block id <Punch> punch;
    beforeEach(^{
        sqlLiteStore = (id)[[SQLiteTableStore alloc] initWithSqliteDatabaseConnection:[[SQLiteDatabaseConnection alloc] init]
                                                                   queryStringBuilder:[[QueryStringBuilder alloc] init]
                                                                         databaseName:@"Test"
                                                                            tableName:@"time_punch_oef_value"];

        punch = nice_fake_for(@protocol(Punch));

        punch stub_method(@selector(requestID)).and_return(@"punch_client_id-uri");

        subject = [[PunchOEFStorage alloc] initWithSqliteStore:sqlLiteStore];

        spy_on(sqlLiteStore);
    });

    describe(@"-storePunchOEFArray", ^{

        __block OEFType *oefType;
        context(@"When inserting punch OEF's", ^{
            beforeEach(^{
                oefType = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name" punchActionType:@"PunchIn" numericValue:nil textValue:@"oef-text-value" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).with(@{@"punch_client_id": @"punch_client_id-uri", @"oef_uri": @"oef-uri-1"}).and_return(nil);

                [subject storePunchOEFArray:@[oefType] forPunch:punch];
            });


            it(@"should insert the row into database", ^{
                sqlLiteStore should have_received(@selector(insertRow:)).with(@{
                                                                                @"punch_client_id":@"punch_client_id-uri",
                                                                                @"oef_uri":@"oef-uri-1",
                                                                                @"oef_definitionTypeUri":@"urn:replicon:object-extension-definition-type:object-extension-type-text",
                                                                                @"oef_name":@"oef-text-name",
                                                                                @"numericValue":[NSNull null],
                                                                                @"textValue":@"oef-text-value",
                                                                                @"dropdownOptionUri":[NSNull null],
                                                                                @"dropdownOptionValue":[NSNull null],
                                                                                @"punchActionType":@"PunchIn",
                                                                                @"collectAtTimeOfPunch":@(YES),
                                                                                @"collectAtTimeOfPunch":@(NO),
                                                                                @"disabled":@(NO)

                                                                                });
            });

            it(@"should return the newly inserted record", ^{
                [subject getPunchOEFTypesForRequestID:@"punch_client_id-uri"] should equal(@[oefType]);
            });
        });

        context(@"When oef types are not available", ^{
            beforeEach(^{
                [subject storePunchOEFArray:@[] forPunch:punch];
            });

            it(@"should return the newly inserted record", ^{
                [subject getPunchOEFTypesForRequestID:@"punch_client_id-uri"] should equal(@[]);
            });
        });

        context(@"When updating a already stored Punch OEF type in DB", ^{

            beforeEach(^{
               OEFType *oldOEFType = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name" punchActionType:@"PunchIn" numericValue:nil textValue:@"oef-text-value" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                 [subject storePunchOEFArray:@[oldOEFType] forPunch:punch];

                sqlLiteStore stub_method(@selector(readLastRowWithArgs:)).with(@{@"punch_client_id": @"punch_client_id-uri", @"oef_uri": @"oef-uri-1"}).and_return(@{
                                                                                                                                                                     @"punch_client_id":@"punch_client_id-uri",
                                                                                                                                                                     @"oef_uri":@"oef-uri-1",
                                                                                                                                                                     @"oef_definitionTypeUri":@"urn:replicon:object-extension-definition-type:object-extension-type-text",
                                                                                                                                                                     @"oef_name":@"oef-text-name",
                                                                                                                                                                     @"numericValue":[NSNull null],
                                                                                                                                                                     @"textValue":@"oef-text-value",
                                                                                                                                                                     @"dropdownOptionUri":[NSNull null],
                                                                                                                                                                     @"dropdownOptionValue":[NSNull null],
                                                                                                                                                                     @"punchActionType":@"PunchIn",
                                                                                                                                                                     @"collectAtTimeOfPunch":@(YES),
                                                                                                                                                                     @"disabled":@(NO)
                                                                                                                                                                     
                                                                                                                                                                     
                                                                                                                                                                     });



                

               oefType = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name" punchActionType:@"PunchIn" numericValue:nil textValue:@"oef-text-value-updated" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                [subject storePunchOEFArray:@[oefType] forPunch:punch];
            });

            it(@"should update the row into database", ^{
                sqlLiteStore should have_received(@selector(updateRow:whereClause:)).with(@{
                                                                                            @"punch_client_id":@"punch_client_id-uri",
                                                                                            @"oef_uri":@"oef-uri-1",
                                                                                            @"oef_definitionTypeUri":@"urn:replicon:object-extension-definition-type:object-extension-type-text",
                                                                                            @"oef_name":@"oef-text-name",
                                                                                            @"numericValue":[NSNull null],
                                                                                            @"textValue":@"oef-text-value-updated",
                                                                                            @"dropdownOptionUri":[NSNull null],
                                                                                            @"dropdownOptionValue":[NSNull null],
                                                                                            @"punchActionType":@"PunchIn",
                                                                                            @"collectAtTimeOfPunch":@(YES),
                                                                             @"disabled":@(NO)


                                                                                            },@{@"punch_client_id": @"punch_client_id-uri", @"oef_uri": @"oef-uri-1"});
            });

            it(@"should return the newly updated record", ^{
                [subject getPunchOEFTypesForRequestID:@"punch_client_id-uri"] should equal(@[oefType]);
            });

        });


    });

    describe(@"-deletePunchOEFWithRequestID:", ^{
        context(@"when deleting a  punch", ^{
            __block OEFType *oefType1;
            __block OEFType *oefType2;
            beforeEach(^{

                oefType1 = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name" punchActionType:@"PunchIn" numericValue:nil textValue:@"oef-text-value" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:OEF_NUMERIC_DEFINITION_TYPE_URI name:@"oef-text-numeric" punchActionType:@"PunchIn" numericValue:@"123" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                [subject storePunchOEFArray:@[oefType1,oefType2] forPunch:punch];
                [subject deletePunchOEFWithRequestID:@"punch_client_id-uri"];
            });

            it(@"should delete the remote punch", ^{
                [[subject getPunchOEFTypesForRequestID:@"punch_client_id-uri"] count] should equal(0);
            });
        });
    });

    describe(@"-deleteAllRows", ^{

        __block OEFType *oefType1;
        __block OEFType *oefType2;
        beforeEach(^{

            oefType1 = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name" punchActionType:@"PunchIn" numericValue:nil textValue:@"oef-text-value" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            oefType2 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:OEF_NUMERIC_DEFINITION_TYPE_URI name:@"oef-text-numeric" punchActionType:@"PunchIn" numericValue:@"123" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            [subject storePunchOEFArray:@[oefType1,oefType2] forPunch:punch];
            [subject deleteAllPunchOEF];
        });

        it(@"should delete all punch oefs", ^{
            [[subject getPunchOEFTypesForRequestID:@"punch_client_id-uri"] count] should equal(0);
        });

    });

});

SPEC_END
