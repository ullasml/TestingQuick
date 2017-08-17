#import <Cedar/Cedar.h>
#import "FailedPunchStorage.h"
#import "SQLiteTableStore.h"
#import "UserSession.h"
#import "SQLiteDatabaseConnection.h"
#import "QueryStringBuilder.h"
#import "LocalPunch.h"
#import "LocalSQLPunchDeserializer.h"
#import "LocalSQLPunchSerializer.h"
#import "BreakType.h"
#import "ClientType.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "Activity.h"
#import "OEFType.h"
#import "RemotePunch.h"
#import "Enum.h"
#import "PunchActionTypes.h"
#import "PunchOEFStorage.h"
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import <Blindside/BSBinder.h>
#import <Blindside/BSInjector.h>


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FailedPunchStorageSpec)

describe(@"FailedPunchStorage", ^{
    __block FailedPunchStorage *subject;
    __block SQLiteTableStore <CedarDouble>*sqliteTableStore;
    __block LocalSQLPunchSerializer <CedarDouble>*localSQLPunchSerializer;
    __block id<UserSession> userSession;
    __block PunchOEFStorage *punchOEFStorage;
    __block id<BSBinder, BSInjector> injector;
    
    beforeEach(^{
        injector = [InjectorProvider injector];

        userSession = fake_for(@protocol(UserSession));

        sqliteTableStore = (id)[[SQLiteTableStore alloc] initWithSqliteDatabaseConnection:[[SQLiteDatabaseConnection alloc] init]
                                                                   queryStringBuilder:[[QueryStringBuilder alloc] init]
                                                                         databaseName:@"Test"
                                                                            tableName:@"time_punch"];

        localSQLPunchSerializer = (id)[injector getInstance:[LocalSQLPunchSerializer class]];
         punchOEFStorage = nice_fake_for([PunchOEFStorage class]);

        subject = [[FailedPunchStorage alloc] initWithLocalSQLPunchSerializer:localSQLPunchSerializer
                                                             sqliteTableStore:sqliteTableStore
                                                                  userSession:userSession
                                                              punchOEFStorage:punchOEFStorage];
        spy_on(localSQLPunchSerializer);
        spy_on(sqliteTableStore);
    });

    describe(@"storing punches", ^{
        context(@"when the user is logged in (punch into project)", ^{
            __block LocalPunch *punch;
            __block NSArray *oefTypesArray;
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");

                NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:0];

                ClientType *clientType = nice_fake_for([ClientType class]);
                clientType stub_method(@selector(name)).and_return(@"client-type-A");
                clientType stub_method(@selector(uri)).and_return(@"client-uri-A");

                ProjectType *projectType = nice_fake_for([ProjectType class]);
                projectType stub_method(@selector(name)).and_return(@"project-type-A");
                projectType stub_method(@selector(uri)).and_return(@"project-uri-A");

                TaskType *taskType = nice_fake_for([TaskType class]);
                taskType stub_method(@selector(name)).and_return(@"task-type-A");
                taskType stub_method(@selector(uri)).and_return(@"task-uri-A");


                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"some text" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.05" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                oefTypesArray = @[oefType1, oefType2];


                CLLocation *location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(52.850837,  -3.058877)
                                                                      altitude:5
                                                            horizontalAccuracy:10
                                                              verticalAccuracy:20
                                                                     timestamp:date];

                UIImage *image = [UIImage imageNamed:@"icon_tabBar_approvals"];

                punch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:location project:projectType requestID:NULL activity:nil client:clientType oefTypes:oefTypesArray address:@"100 Big Street" userURI:@"user:uri" image:image task:taskType date:date];

                [subject storePunch:punch];
            });

            it(@"should store the punch", ^{
                NSDictionary *punchDictionary = [localSQLPunchSerializer serializePunchForStorage:punch];
                
                localSQLPunchSerializer should have_received(@selector(serializePunchForStorage:)).with(punch);

                sqliteTableStore should have_received(@selector(insertRow:)).with(punchDictionary);
            });

            it(@"should store all OEFS", ^{

                punchOEFStorage should have_received(@selector(storePunchOEFArray:forPunch:)).with(oefTypesArray,punch);
            });
        });
        
        context(@"when the user is logged in (punch into activity)", ^{
            __block LocalPunch *punch;
            __block NSArray *oefTypesArray;
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
                
                NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
                
                Activity *activityType = nice_fake_for([Activity class]);
                activityType stub_method(@selector(name)).and_return(@"activity-type-A");
                activityType stub_method(@selector(uri)).and_return(@"activity-type-A");
                
                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"some text" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.05" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                oefTypesArray = @[oefType1, oefType2];
                
                
                CLLocation *location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(52.850837,  -3.058877)
                                                                      altitude:5
                                                            horizontalAccuracy:10
                                                              verticalAccuracy:20
                                                                     timestamp:date];
                
                UIImage *image = [UIImage imageNamed:@"icon_tabBar_approvals"];
                
                punch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:location project:nil requestID:NULL activity:activityType client:nil oefTypes:oefTypesArray address:@"100 Big Street" userURI:@"user:uri" image:image task:nil date:date];
                
                
                
                
                [subject storePunch:punch];
            });
            
            it(@"should store the punch", ^{
                NSDictionary *punchDictionary = [localSQLPunchSerializer serializePunchForStorage:punch];
                
                localSQLPunchSerializer should have_received(@selector(serializePunchForStorage:)).with(punch);
                
                sqliteTableStore should have_received(@selector(insertRow:)).with(punchDictionary);
            });

            it(@"should store all OEFS", ^{

                punchOEFStorage should have_received(@selector(storePunchOEFArray:forPunch:)).with(oefTypesArray,punch);
            });
        });
        
        context(@"when the user is logged in (break punch)", ^{
            __block LocalPunch *punch;
            __block NSArray *oefTypesArray;
            beforeEach(^{
                userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
                
                NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
                
                BreakType *breakType = [[BreakType alloc] initWithName:@"My Special Break Type A" uri:@"my-special-break-type-uri-A"];
                
                
                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"some text" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.05" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                oefTypesArray = @[oefType1, oefType2];
                
                
                CLLocation *location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(52.850837,  -3.058877)
                                                                      altitude:5
                                                            horizontalAccuracy:10
                                                              verticalAccuracy:20
                                                                     timestamp:date];
                
                UIImage *image = [UIImage imageNamed:@"icon_tabBar_approvals"];
                
                
                punch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:NULL breakType:breakType location:location project:nil requestID:NULL activity:nil client:nil oefTypes:oefTypesArray address:@"100 Big Street" userURI:@"user:uri" image:image task:nil date:date];
                
                [subject storePunch:punch];
            });
            
            it(@"should store the punch", ^{
                NSDictionary *punchDictionary = [localSQLPunchSerializer serializePunchForStorage:punch];
                
                localSQLPunchSerializer should have_received(@selector(serializePunchForStorage:)).with(punch);
                
                sqliteTableStore should have_received(@selector(insertRow:)).with(punchDictionary);
            });

            it(@"should store all OEFS", ^{

                punchOEFStorage should have_received(@selector(storePunchOEFArray:forPunch:)).with(oefTypesArray,punch);
            });
            
        });
    });
    
    describe(@"updateSyncStatusToUnsubmittedAndSaveWithPunch:", ^{
        __block LocalPunch *newPunch;
        beforeEach(^{
            userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
            newPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"ABCD1234" activity:nil client:nil oefTypes:nil address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:1]];
            
            [subject updateSyncStatusToUnsubmittedAndSaveWithPunch:newPunch];
            
        });
        
        it(@"should update punch status to UnsubmittedSyncStatus and offline status to true", ^{

            NSDictionary *updatedRowDictionary = @{@"punchSyncStatus":@(UnsubmittedSyncStatus), @"lastSyncTime":[NSNull null], @"offline":@1};
            
            NSDictionary *whereArgs = @{@"user_uri": @"user:uri", @"request_id":newPunch.requestID};
            
            sqliteTableStore should have_received(@selector(updateRow:whereClause:)).with(updatedRowDictionary, whereArgs);
        });
    });

    describe(@"updateStatusOfRemotePunchToUnsubmitted:", ^{
        __block RemotePunch *remotePunch;
        beforeEach(^{
            userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
            remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                nonActionedValidations:0
                                                   previousPunchStatus:Ticking
                                                       nextPunchStatus:Ticking
                                                         sourceOfPunch:UnknownSourceOfPunch
                                                            actionType:PunchActionTypePunchIn
                                                         oefTypesArray:nil
                                                          lastSyncTime:NULL
                                                               project:NULL
                                                           auditHstory:nil
                                                             breakType:nil
                                                              location:nil
                                                            violations:nil
                                                             requestID:@"ABCD1234"
                                                              activity:NULL
                                                              duration:nil
                                                                client:NULL
                                                               address:nil
                                                               userURI:@"user:uri"
                                                              imageURL:nil
                                                                  date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]
                                                                  task:NULL
                                                                   uri:@"punch:uri"
                                                  isTimeEntryAvailable:NO
                                                      syncedWithServer:NO
                                                        isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            
            [subject updateStatusOfRemotePunchToUnsubmitted:remotePunch];
            
        });
        
        it(@"should update punch status to UnsubmittedSyncStatus and offline status to true", ^{
            
            NSDictionary *updatedRowDictionary = @{@"punchSyncStatus":@(UnsubmittedSyncStatus), @"offline":@1};
            
            NSDictionary *whereArgs = @{@"user_uri": @"user:uri", @"request_id":remotePunch.requestID};
            
            sqliteTableStore should have_received(@selector(updateRow:whereClause:)).with(updatedRowDictionary, whereArgs);
        });
    });

});

SPEC_END
