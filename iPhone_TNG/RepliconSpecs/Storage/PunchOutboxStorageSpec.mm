#import <Cedar/Cedar.h>
#import <CoreLocation/CoreLocation.h>
#import "PunchOutboxStorage.h"
#import "LocalPunch.h"
#import "Constants.h"
#import "BreakType.h"
#import "SQLiteDatabaseConnection.h"
#import "QueryStringBuilder.h"
#import "SQLiteTableStore.h"
#import "UserSession.h"
#import "OfflineLocalPunch.h"
#import "OEFType.h"
#import "DateProvider.h"
#import <Blindside/BSInjector.h>
#import <Blindside/BSBinder.h>
#import "InjectorProvider.h"
#import "Enum.h"
#import "PunchActionTypes.h"
#import "PunchOEFStorage.h"
#import "LocalSQLPunchDeserializer.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(PunchOutboxStorageSpec)

describe(@"PunchOutboxStorage", ^{
    __block PunchOutboxStorage *subject;
    __block SQLiteTableStore <CedarDouble>*sqlLiteStore;
    __block DateProvider *dateProvider;
    __block id<BSInjector, BSBinder> injector;
    __block NSDate *date;
    __block PunchOEFStorage *punchOEFStorage;
    __block LocalSQLPunchDeserializer *localSQLPunchDeserializer;

    beforeEach(^{
        injector = [InjectorProvider injector];
        date = [NSDate dateWithTimeIntervalSince1970:0];
        dateProvider = fake_for([DateProvider class]);
        dateProvider stub_method(@selector(date)).and_return(date);
        [injector bind:[DateProvider class] toInstance:dateProvider];

        localSQLPunchDeserializer =  [injector getInstance:[LocalSQLPunchDeserializer class]];
        
        id<UserSession> userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");

        sqlLiteStore = (id)[[SQLiteTableStore alloc] initWithSqliteDatabaseConnection:[[SQLiteDatabaseConnection alloc] init]
                                                                   queryStringBuilder:[[QueryStringBuilder alloc] init]
                                                                         databaseName:@"Test"
                                                                            tableName:@"time_punch"];

        punchOEFStorage = nice_fake_for([PunchOEFStorage class]);

        subject = [[PunchOutboxStorage alloc] initWithLocalSQLPunchDeserializer:localSQLPunchDeserializer
                                                                    sqliteStore:sqlLiteStore userSession:userSession
                                                                   dateProvider:dateProvider
                                                                punchOEFStorage:punchOEFStorage];
        spy_on(sqlLiteStore);
    });

    describe(@"storing and fetching punches", ^{
        __block LocalPunch *punchA;
        __block LocalPunch *punchB;
        __block LocalPunch *punchC;
        __block LocalPunch *punchD;
        __block LocalPunch *otherUsersPunch;

        beforeEach(^{
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(51.5010, 0.1416);
            CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:-1 horizontalAccuracy:34.4 verticalAccuracy:-1 timestamp:[NSDate date]];

            punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:location project:nil requestID:@"ABCD1231" activity:nil client:nil oefTypes:nil address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSince1970:0]];

            punchB = [[LocalPunch alloc] initWithPunchSyncStatus:PendingSyncStatus actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:nil location:location project:nil requestID:@"ABCD1232" activity:nil client:nil oefTypes:nil address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSince1970:1]];

            BreakType *breakType = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break"];
            punchC = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:NULL breakType:breakType location:nil project:nil requestID:@"ABCD1233" activity:nil client:nil oefTypes:nil address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSince1970:2]];

            punchD = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeTransfer lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"ABCD1234" activity:nil client:nil oefTypes:nil address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSince1970:3]];

            otherUsersPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"ABCD1235" activity:nil client:nil oefTypes:nil address:nil userURI:@"other:user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSince1970:4]];

            [subject storeLocalPunch:punchA];
            [subject storeLocalPunch:punchB];
            [subject storeLocalPunch:punchC];
            [subject storeLocalPunch:punchD];
            [subject storeLocalPunch:otherUsersPunch];
        });

        it(@"should store punches", ^{
            [subject allPunches] should equal(@[punchA, punchB, punchC, punchD]);
        });
        
        it(@"should return punches with status UnsubmittedSyncStatus", ^{
            [[subject allPunches] count] should equal(4);
        });

        it(@"should return a offline local punch when storing an offline local punch", ^{
            OfflineLocalPunch *offlineLocalPunch = [[OfflineLocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"ABCD1237" activity:nil client:nil oefTypes:nil address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSince1970:1234]];
            [subject storeLocalPunch:offlineLocalPunch];

            LocalPunch *punch = [[subject allPunches] lastObject];
            punch should be_instance_of([OfflineLocalPunch class]);
        });

        it(@"should persist punches (UnsubmittedSyncStatus and pending)", ^{
            id<UserSession> userSession = nice_fake_for(@protocol(UserSession));
            userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");

            PunchOutboxStorage *otherPunchStorage = [[PunchOutboxStorage alloc] initWithLocalSQLPunchDeserializer:localSQLPunchDeserializer
                                                                                                      sqliteStore:sqlLiteStore
                                                                                                      userSession:userSession
                                                                                                     dateProvider:NULL
                                                                                                  punchOEFStorage:NULL];

            [otherPunchStorage allPunches] should equal(@[punchA, punchB, punchC, punchD]);
        });

        it(@"should return all punches that belong to the user (UnsubmittedSyncStatus and pending)", ^{
            [subject allPunches] should equal(@[punchA, punchB, punchC, punchD]);
        });

        it(@"should not store OEF's", ^{
            punchOEFStorage should_not have_received(@selector(storePunchOEFArray:forPunch:));
        });
    });

    describe(@"storing and fetching punches with OEFs", ^{
        __block LocalPunch *punchA;
        __block LocalPunch *punchB;
        __block LocalPunch *punchC;
        __block LocalPunch *punchD;
        __block LocalPunch *otherUsersPunch;
        __block LocalPunch *otherPunch;
        __block OEFType *oefType1;
        __block OEFType *oefType2;
        __block OEFType *oefType3;

        beforeEach(^{
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(51.5010, 0.1416);
            CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:-1 horizontalAccuracy:34.4 verticalAccuracy:-1 timestamp:[NSDate date]];

            oefType1 = [[OEFType alloc]                                                                                               initWithUri:@
                    "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"dipta number" punchActionType:@"PunchOut" numericValue:@"123" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];


            oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"dipta text" punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

            oefType3 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:a6996497-e0c4-4d7c-bddf-8e828df8d623" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"generic oef - prompt" punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

            punchOEFStorage stub_method(@selector(getPunchOEFTypesForRequestID:)).with(@"ABCD1234").and_return(@[oefType1,oefType2]);
            punchOEFStorage stub_method(@selector(getPunchOEFTypesForRequestID:)).with(@"ABCD1235").and_return(@[oefType2]);
            punchOEFStorage stub_method(@selector(getPunchOEFTypesForRequestID:)).with(@"ABCD1236").and_return(@[oefType1,oefType2,oefType3]);
            punchOEFStorage stub_method(@selector(getPunchOEFTypesForRequestID:)).with(@"ABCD1237").and_return(nil);
            punchOEFStorage stub_method(@selector(getPunchOEFTypesForRequestID:)).with(@"ABCD12348").and_return(@[oefType2,oefType3]);

            punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:location project:nil requestID:@"ABCD1234" activity:nil client:nil oefTypes:@[oefType1, oefType2] address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSince1970:0]];

            punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:nil location:location project:nil requestID:@"ABCD1235" activity:nil client:nil oefTypes:@[oefType2] address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSince1970:1]];

            BreakType *breakType = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break"];
            punchC = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:NULL breakType:breakType location:nil project:nil requestID:@"ABCD1236" activity:nil client:nil oefTypes:@[oefType1, oefType2, oefType3] address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSince1970:2]];

            punchD = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeTransfer lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"ABCD1237" activity:nil client:nil oefTypes:nil address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSince1970:3]];

            otherUsersPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"ABCD12348" activity:nil client:nil oefTypes:@[oefType2, oefType3] address:nil userURI:@"other:user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSince1970:4]];
            
            otherPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(RemotePunchStatus) actionType:PunchActionTypeStartBreak lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:@[oefType2, oefType3] address:nil userURI:@"other:user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSince1970:4]];


            [subject storeLocalPunch:punchA];
            [subject storeLocalPunch:punchB];
            [subject storeLocalPunch:punchC];
            [subject storeLocalPunch:punchD];
            [subject storeLocalPunch:otherUsersPunch];
            [subject storeLocalPunch:otherPunch];
        });

        it(@"should store punches", ^{
            [subject allPunches] should equal(@[punchA, punchB, punchC, punchD]);
        });
        
        it(@"should return punches with status UnsubmittedSyncStatus", ^{
            [[subject allPunches] count] should equal(4);
        });

        it(@"should return a offline local punch when storing an offline local punch", ^{
            OfflineLocalPunch *offlineLocalPunch = [[OfflineLocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"ABCD123489" activity:nil client:nil oefTypes:@[oefType1, oefType2, oefType3] address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSince1970:1234]];
            [subject storeLocalPunch:offlineLocalPunch];

            LocalPunch *punch = [[subject allPunches] lastObject];
            punch should be_instance_of([OfflineLocalPunch class]);
        });

        it(@"should persist punches", ^{
            id<UserSession> userSession = nice_fake_for(@protocol(UserSession));
            userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");

            PunchOutboxStorage *otherPunchStorage = [[PunchOutboxStorage alloc] initWithLocalSQLPunchDeserializer:localSQLPunchDeserializer
                                                                                                      sqliteStore:sqlLiteStore
                                                                                                      userSession:userSession
                                                                                                     dateProvider:NULL
                                                                                                  punchOEFStorage:punchOEFStorage];

            [otherPunchStorage allPunches][0] should equal(punchA);
            [otherPunchStorage allPunches][1] should equal(punchB);
            [otherPunchStorage allPunches][2] should equal(punchC);
            [otherPunchStorage allPunches][3] should equal(punchD);

            [otherPunchStorage allPunches] should equal(@[punchA, punchB, punchC, punchD]);
        });
        
        it(@"should return all punches that belong to the user", ^{
            [subject allPunches] should equal(@[punchA, punchB, punchC, punchD]);
        });

        it(@"should store all OEFS", ^{
            punchOEFStorage should have_received(@selector(storePunchOEFArray:forPunch:)).with(@[oefType1,oefType2],punchA);
            punchOEFStorage should have_received(@selector(storePunchOEFArray:forPunch:)).with(@[oefType2],punchB);
            punchOEFStorage should have_received(@selector(storePunchOEFArray:forPunch:)).with(@[oefType1,oefType2,oefType3],punchC);
            punchOEFStorage should_not have_received(@selector(storePunchOEFArray:forPunch:)).with(nil,punchD);
             punchOEFStorage should have_received(@selector(storePunchOEFArray:forPunch:)).with(@[oefType2,oefType3],otherUsersPunch);
            punchOEFStorage should_not have_received(@selector(storePunchOEFArray:forPunch:)).with(nil,otherPunch);
        });
    });

    describe(@"deletePunch:", ^{
        __block LocalPunch *punchA;
        __block LocalPunch *punchB;
        __block LocalPunch *punchC;
        
        beforeEach(^{
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(51.5010, 0.1416);
            CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:-1 horizontalAccuracy:34.4 verticalAccuracy:-1 timestamp:[NSDate date]];
            
            
            
            punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:location project:nil requestID:@"ABCD1234" activity:nil client:nil oefTypes:nil address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSince1970:0]];
            
            punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:nil location:location project:nil requestID:@"ABCD1235" activity:nil client:nil oefTypes:nil address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSince1970:1]];
            
            BreakType *breakType = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break"];
            punchC = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:NULL breakType:breakType location:nil project:nil requestID:@"ABCD1236" activity:nil client:nil oefTypes:nil address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSince1970:2]];
            
            
            
            [subject storeLocalPunch:punchA];
            [subject storeLocalPunch:punchB];
            [subject storeLocalPunch:punchC];
        });
        
        it(@"should delete the specific punch", ^{
            [sqlLiteStore reset_sent_messages];
            [subject deletePunch:punchA];
            
            NSDictionary *whereArgs = @{@"user_uri": @"user:uri", @"request_id":punchA.requestID};
            
            sqlLiteStore should have_received(@selector(deleteRowWithArgs:)).with(whereArgs);
            
            [subject allPunches] should_not contain(punchA);
            
            [[subject allPunches] count] should equal(2);
        });
        
    });
    
    describe(@"updateSyncStatusToPendingAndSave:", ^{
        __block LocalPunch *punchA;
        __block LocalPunch *punchB;
        __block LocalPunch *punchC;
        
        beforeEach(^{
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(51.5010, 0.1416);
            CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:-1 horizontalAccuracy:34.4 verticalAccuracy:-1 timestamp:[NSDate date]];
            
            
            
            punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:location project:nil requestID:@"ABCD1234" activity:nil client:nil oefTypes:nil address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSince1970:0]];
            
            punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:nil location:location project:nil requestID:@"ABCD1235" activity:nil client:nil oefTypes:nil address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSince1970:1]];
            
            BreakType *breakType = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break"];
            punchC = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:NULL breakType:breakType location:nil project:nil requestID:@"ABCD1236" activity:nil client:nil oefTypes:nil address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSince1970:2]];
            
            
            
            [subject storeLocalPunch:punchA];
            [subject storeLocalPunch:punchB];
            [subject storeLocalPunch:punchC];
        });
        
        it(@"should change sync status to Pending", ^{
            [sqlLiteStore reset_sent_messages];
            [subject updateSyncStatusToPendingAndSave:punchA];
            
            NSDictionary *updatedRowDictionary = @{@"punchSyncStatus":@(PendingSyncStatus), @"lastSyncTime":date, @"offline":@1};

            NSDictionary *whereArgs = @{@"user_uri": @"user:uri", @"request_id":punchA.requestID};
            
            sqlLiteStore should have_received(@selector(updateRow:whereClause:)).with(updatedRowDictionary, whereArgs);
            
            [[subject allPunches] count] should equal(3);
        });
        
    });
    
    describe(@"unSubmittedAndPendingSyncPunches", ^{
        __block LocalPunch *punchA;
        __block LocalPunch *punchB;
        __block LocalPunch *punchC;
        __block LocalPunch *punchD;
        __block LocalPunch *punchE;
        
        beforeEach(^{
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(51.5010, 0.1416);
            CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:-1 horizontalAccuracy:34.4 verticalAccuracy:-1 timestamp:[NSDate date]];
            
            
            
            punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:nil breakType:nil location:location project:nil requestID:@"ABCD1234" activity:nil client:nil oefTypes:nil address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSince1970:1474969441]];//Tue, 27 Sep 2016 09:44:01 GMT
            
            punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(PendingSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:[NSDate dateWithTimeIntervalSince1970:1474967000] breakType:nil location:location project:nil requestID:@"ABCD1235" activity:nil client:nil oefTypes:nil address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSince1970:1474967000]];//Tue, 27 Sep 2016 09:03:20 GMT
            
            BreakType *breakType = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break"];
            punchC = [[LocalPunch alloc] initWithPunchSyncStatus:(PendingSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:[NSDate dateWithTimeIntervalSince1970:1474968000] breakType:breakType location:nil project:nil requestID:@"ABCD1236" activity:nil client:nil oefTypes:nil address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSince1970:1474968000]];//Tue, 27 Sep 2016 09:20:00 GMT
            
            punchD = [[LocalPunch alloc] initWithPunchSyncStatus:(PendingSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:[NSDate dateWithTimeIntervalSince1970:1474969253] breakType:breakType location:nil project:nil requestID:@"ABCD1237" activity:nil client:nil oefTypes:nil address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSince1970:1474969253]];//Tue, 27 Sep 2016 09:20:00 GMT

            punchE = [[LocalPunch alloc] initWithPunchSyncStatus:(PendingSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:nil breakType:breakType location:nil project:nil requestID:@"ABCD1237" activity:nil client:nil oefTypes:nil address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSince1970:1481540194]]; //12/12/2016 10:56:34



            [subject storeLocalPunch:punchA];
            [subject storeLocalPunch:punchB];
            [subject storeLocalPunch:punchC];
            [subject storeLocalPunch:punchD];
            [subject storeLocalPunch:punchE];
        });

        it(@"should return all unsubmitted and pending punches(>5 mins and null)", ^{
            [sqlLiteStore reset_sent_messages];

            date = [NSDate dateWithTimeIntervalSince1970:1474969253];//Tue, 27 Sep 2016 09:40:53 GMT
            dateProvider stub_method(@selector(date)).and_return(date).again();

            NSArray *punches =  [subject unSubmittedAndPendingSyncPunches];
            
            [punches count] should equal(4);
        });

       
        
    });
    
});

SPEC_END
