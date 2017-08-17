#import <Cedar/Cedar.h>
#import "TimeLinePunchesStorage.h"
#import "SQLiteTableStore.h"
#import "SQLiteDatabaseConnection.h"
#import "QueryStringBuilder.h"
#import "LocalPunch.h"
#import "RemotePunch.h"
#import "Enum.h"
#import "PunchActionTypes.h"
#import "PunchOEFStorage.h"
#import "OEFType.h"
#import "DateProvider.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "ClientType.h"
#import "RemoteSQLPunchSerializer.h"
#import <Blindside/BSInjector.h>
#import <Blindside/BSBinder.h>
#import "InjectorProvider.h"
#import "LocalSQLPunchDeserializer.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TimeLinePunchesStorageSpec)

describe(@"TimeLinePunchesStorage", ^{
   __block TimeLinePunchesStorage *subject;

    __block DoorKeeper *doorKeeper;
    __block SQLiteTableStore<CedarDouble> *sqlLiteStore;
    __block id<UserSession> userSession;
    __block PunchOEFStorage *punchOEFStorage;
    __block DateProvider *dateProvider;
    __block RemoteSQLPunchSerializer *remoteSQLPunchSerializer;
    __block LocalSQLPunchDeserializer *localSQLPunchDeserializer;
    __block id<BSInjector, BSBinder> injector;
    beforeEach(^{
        
        injector = [InjectorProvider injector];
        sqlLiteStore = (id)[[SQLiteTableStore alloc] initWithSqliteDatabaseConnection:[[SQLiteDatabaseConnection alloc] init]
                                                                   queryStringBuilder:[[QueryStringBuilder alloc] init]
                                                                         databaseName:@"Test"
                                                                            tableName:@"time_punch"];
        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
        doorKeeper = nice_fake_for([DoorKeeper class]);

        punchOEFStorage = nice_fake_for([PunchOEFStorage class]);
        
        remoteSQLPunchSerializer = [injector getInstance:[RemoteSQLPunchSerializer class]];
        localSQLPunchDeserializer = [injector getInstance:[LocalSQLPunchDeserializer class]];

        NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:1477134600];
        dateProvider = fake_for([DateProvider class]);
        dateProvider stub_method(@selector(date)).and_return(date);


        subject = [[TimeLinePunchesStorage alloc] initWithRemoteSQLPunchSerializer:remoteSQLPunchSerializer
                                                         localSQLPunchDeserializer:localSQLPunchDeserializer
                                                                       sqliteStore:sqlLiteStore
                                                                       userSession:userSession
                                                                        doorKeeper:doorKeeper
                                                                   punchOEFStorage:punchOEFStorage
                                                                      dateProvider:dateProvider
                                                                     dateFormatter:nil];
        spy_on(sqlLiteStore);
        
    });
    
    it(@"should add itself as an observer on the door keeper", ^{
        doorKeeper should have_received(@selector(addLogOutObserver:)).with(subject);
    });
    
    
    describe(@"-storePunch:", ^{
        context(@"when storing a remote punch", ^{
            __block id<Punch> remotePunchA;
            __block id<Punch> remotePunchB;
            __block id<Punch> remotePunchC;
            __block id<Punch> remotePunchD;
            beforeEach(^{
                remotePunchA = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                                  requestID:@"ABCD123"
                                                                   activity:NULL
                                                                   duration:nil
                                                                     client:NULL
                                                                    address:nil
                                                                    userURI:@"user:uri"
                                                                   imageURL:nil
                                                                       date:[NSDate dateWithTimeIntervalSinceReferenceDate:1]
                                                                       task:NULL
                                                                        uri:@"punch:uri:1"
                                                       isTimeEntryAvailable:NO
                                                           syncedWithServer:NO
                                                             isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                remotePunchB = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                                        uri:@"punch:uri:special"
                                                       isTimeEntryAvailable:NO
                                                           syncedWithServer:NO
                                                             isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                remotePunchC = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                                  requestID:@"ABCD12345"
                                                                   activity:NULL
                                                                   duration:nil
                                                                     client:NULL
                                                                    address:nil
                                                                    userURI:@"user:uri"
                                                                   imageURL:nil
                                                                       date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]
                                                                       task:NULL
                                                                        uri:@"punch:uri:special"
                                                       isTimeEntryAvailable:NO
                                                           syncedWithServer:NO
                                                             isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];



                remotePunchD = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                                  requestID:@"ABCD123456"
                                                                   activity:NULL
                                                                   duration:nil
                                                                     client:NULL
                                                                    address:nil
                                                                    userURI:@"user:uri"
                                                                   imageURL:nil
                                                                       date:[NSDate dateWithTimeIntervalSinceReferenceDate:3]
                                                                       task:NULL
                                                                        uri:@"punch:uri:2"
                                                       isTimeEntryAvailable:NO
                                                           syncedWithServer:NO
                                                             isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];



                [subject deleteAllPreviousPunches:nil];
                [subject storeRemotePunch:remotePunchA];
                [subject storeRemotePunch:remotePunchB];
                [subject storeRemotePunch:remotePunchC];
                [subject storeRemotePunch:remotePunchD];
            });

            it(@"when storing a punch should store only the most recent punch", ^{
                [[subject recentPunches] count] should equal(3);
            });

            it(@"should store the the punch", ^{
                id<Punch> mostRecentPunch = [subject mostRecentPunch];
                mostRecentPunch should equal(remotePunchD);
            });


            it(@"should not store OEF's", ^{
                punchOEFStorage should_not have_received(@selector(storePunchOEFArray:forPunch:));
            });
            
            it(@"should return recent two punches", ^{
                [[subject recentTwoPunches] count] should equal(2);
            });

            it(@"should delete and insert if punch values are equal for all attributes except punch uri", ^{
                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                                              requestID:@"ABCD1234567"
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:NULL
                                                                                address:nil
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSinceReferenceDate:4]
                                                                                   task:NULL
                                                                                    uri:@"punch:uri:2"
                                                                   isTimeEntryAvailable:NO
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];



                [subject storeRemotePunch:remotePunch];

                [[subject recentPunches] count] should equal(3);

                [subject recentPunches][2] should equal(remotePunch);
            });

        });

        context(@"when storing a remote punch with OEF's", ^{
            __block id<Punch> remotePunchA;
            __block id<Punch> remotePunchB;
            __block id<Punch> remotePunchC;
            __block OEFType *oefType1;
            __block OEFType *oefType2;
            beforeEach(^{
                oefType1 = [[OEFType alloc] initWithUri:@"oef-uri-1" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name1" punchActionType:@"PunchIn" numericValue:nil textValue:@"oef-text-value-1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:@"oef-uri-2" definitionTypeUri:OEF_TEXT_DEFINITION_TYPE_URI name:@"oef-text-name2" punchActionType:@"PunchIn" numericValue:nil textValue:@"oef-text-value-2" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];


                punchOEFStorage stub_method(@selector(getPunchOEFTypesForRequestID:)).with(@"ABCD123").and_return(@[oefType1,oefType2]);
                 punchOEFStorage stub_method(@selector(getPunchOEFTypesForRequestID:)).with(@"ABCD12345").and_return(@[oefType1]);

                remotePunchA = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                     nonActionedValidations:0
                                                        previousPunchStatus:Ticking
                                                            nextPunchStatus:Ticking
                                                              sourceOfPunch:UnknownSourceOfPunch
                                                                 actionType:PunchActionTypePunchIn
                                                              oefTypesArray:@[oefType1, oefType2]
                                                               lastSyncTime:NULL
                                                                    project:NULL
                                                                auditHstory:nil
                                                                  breakType:nil
                                                                   location:nil
                                                                 violations:nil
                                                                  requestID:@"ABCD123"
                                                                   activity:NULL
                                                                   duration:nil
                                                                     client:NULL
                                                                    address:nil
                                                                    userURI:@"user:uri"
                                                                   imageURL:nil
                                                                       date:[NSDate dateWithTimeIntervalSinceReferenceDate:1]
                                                                       task:NULL
                                                                        uri:@"punch:uri:special"
                                                       isTimeEntryAvailable:NO
                                                           syncedWithServer:NO
                                                             isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                remotePunchB = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                     nonActionedValidations:0
                                                        previousPunchStatus:Ticking
                                                            nextPunchStatus:Ticking
                                                              sourceOfPunch:UnknownSourceOfPunch
                                                                 actionType:PunchActionTypePunchIn
                                                              oefTypesArray:@[oefType1]
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
                                                                        uri:@"punch:uri:special"
                                                       isTimeEntryAvailable:NO
                                                           syncedWithServer:NO
                                                             isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];


                remotePunchC = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                     nonActionedValidations:0
                                                        previousPunchStatus:Ticking
                                                            nextPunchStatus:Ticking
                                                              sourceOfPunch:UnknownSourceOfPunch
                                                                 actionType:PunchActionTypePunchIn
                                                              oefTypesArray:@[oefType1]
                                                               lastSyncTime:NULL
                                                                    project:NULL
                                                                auditHstory:nil
                                                                  breakType:nil
                                                                   location:nil
                                                                 violations:nil
                                                                  requestID:@"ABCD12345"
                                                                   activity:NULL
                                                                   duration:nil
                                                                     client:NULL
                                                                    address:nil
                                                                    userURI:@"user:uri"
                                                                   imageURL:nil
                                                                       date:[NSDate dateWithTimeIntervalSinceReferenceDate:2]
                                                                       task:NULL
                                                                        uri:@"punch:uri"
                                                       isTimeEntryAvailable:NO
                                                           syncedWithServer:NO
                                                             isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                [subject deleteAllPreviousPunches:nil];
                [subject storeRemotePunch:remotePunchA];
                [subject storeRemotePunch:remotePunchB];
                [subject storeRemotePunch:remotePunchC];
            });

            it(@"when storing a punch should store only the most recent punch", ^{
                [[subject recentPunches] count] should equal(2);
            });

            it(@"should store the the punch", ^{
                id<Punch> mostRecentPunch = [subject mostRecentPunch];
                mostRecentPunch should equal(remotePunchC);
            });


            it(@"should store all OEFS", ^{
                punchOEFStorage should have_received(@selector(storePunchOEFArray:forPunch:)).with(@[oefType1,oefType2],remotePunchA);
                punchOEFStorage should have_received(@selector(storePunchOEFArray:forPunch:)).with(@[oefType1],remotePunchB);
            });
        });


    });

    
    describe(@"-deleteRemotePunch:", ^{
        context(@"when deleting a remote punch", ^{
            __block id<Punch> remotePunch;
            beforeEach(^{
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
                                                                      date:[NSDate dateWithTimeIntervalSinceReferenceDate:1]
                                                                      task:NULL
                                                                       uri:@"punch:uri"
                                                      isTimeEntryAvailable:NO
                                                          syncedWithServer:NO
                                                            isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                [subject deleteAllPreviousPunches:nil];
                [subject storeRemotePunch:remotePunch];
                [subject deleteOldRemotePunch:remotePunch];
            });
            
            it(@"should delete the remote punch", ^{
                [[subject recentPunches] count] should equal(0);
            });

        });

    });

    describe(@"updateSyncStatusToRemoteAndSaveWithPunch:", ^{
        __block LocalPunch *newPunch;
        beforeEach(^{
            newPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"ABCD1234" activity:nil client:nil oefTypes:nil address:nil userURI:@"user:uri" image:nil task:nil date:[NSDate dateWithTimeIntervalSinceReferenceDate:1]];
            
            [subject updateSyncStatusToRemoteAndSaveWithPunch:newPunch withRemoteUri:nil];
        });
        
        it(@"should update the SyncStatus", ^{
            NSDictionary *whereArgs = @{@"user_uri": @"user:uri", @"request_id":newPunch.requestID};
            NSDictionary *updatedRowDictionary = @{@"punchSyncStatus":@(RemotePunchStatus), @"lastSyncTime":[NSNull null], @"offline":@0};
            
            sqlLiteStore should have_received(@selector(updateRow:whereClause:)).with(updatedRowDictionary, whereArgs);
        });
    });
    
    
    describe(@"as a <DoorKeeperLogOutObserver>", ^{
        __block id<Punch> remotePunchA;
        __block id<Punch> remotePunchB;
        beforeEach(^{
            remotePunchA = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                              requestID:@"ABCD123"
                                                               activity:NULL
                                                               duration:nil
                                                                 client:NULL
                                                                address:nil
                                                                userURI:@"user:uri"
                                                               imageURL:nil
                                                                   date:[NSDate dateWithTimeIntervalSinceReferenceDate:1]
                                                                   task:NULL
                                                                    uri:@"punch:uri"
                                                   isTimeEntryAvailable:NO
                                                       syncedWithServer:NO
                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            
            remotePunchB = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
            [subject storeRemotePunch:remotePunchA];
            [subject storeRemotePunch:remotePunchB];
            [subject doorKeeperDidLogOut:nil];
        });
        
        it(@"should remove all punches from table", ^{
            [subject mostRecentPunch] should be_nil;
        });

        it(@"should remove all punches oefs from table", ^{
           punchOEFStorage should have_received(@selector(deleteAllPunchOEF));
        });
    });

    describe(@"allRemotePunchesForDay:userUri:", ^{
        __block id<Punch> remotePunchA;
        __block id<Punch> remotePunchB;
        __block id<Punch> remotePunchC;

        context(@"For punches synced with server", ^{
            context(@"For PST timeZone", ^{
                beforeEach(^{

                    NSDateFormatter *longDateFormatter = [[NSDateFormatter alloc] init];
                    longDateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"PST"];
                    longDateFormatter.dateFormat = @"MMM d, YYYY";

                    subject = [[TimeLinePunchesStorage alloc] initWithRemoteSQLPunchSerializer:remoteSQLPunchSerializer
                                                                     localSQLPunchDeserializer:localSQLPunchDeserializer
                                                                                   sqliteStore:sqlLiteStore
                                                                                   userSession:userSession
                                                                                    doorKeeper:doorKeeper
                                                                               punchOEFStorage:punchOEFStorage
                                                                                  dateProvider:dateProvider
                                                                                 dateFormatter:longDateFormatter];

                    remotePunchA = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                                      requestID:@"ABCD123"
                                                                       activity:NULL
                                                                       duration:nil
                                                                         client:NULL
                                                                        address:nil
                                                                        userURI:@"user:uri"
                                                                       imageURL:nil
                                                                           date:[NSDate dateWithTimeIntervalSince1970:1477098600]
                                                                           task:NULL
                                                                            uri:@"punch:uri"
                                                           isTimeEntryAvailable:NO
                                                               syncedWithServer:YES
                                                                 isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                    remotePunchB = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                                      requestID:@"ABCD12345"
                                                                       activity:NULL
                                                                       duration:nil
                                                                         client:NULL
                                                                        address:nil
                                                                        userURI:@"user:uri"
                                                                       imageURL:nil
                                                                           date:[NSDate dateWithTimeIntervalSince1970:1477228200]
                                                                           task:NULL
                                                                            uri:@"punch:uri"
                                                           isTimeEntryAvailable:NO
                                                               syncedWithServer:YES
                                                                 isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                    remotePunchC = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                                      requestID:@"ABCD123456"
                                                                       activity:NULL
                                                                       duration:nil
                                                                         client:NULL
                                                                        address:nil
                                                                        userURI:@"user:uri"
                                                                       imageURL:nil
                                                                           date:[NSDate dateWithTimeIntervalSince1970:1477141800]
                                                                           task:NULL
                                                                            uri:@"punch:uri"
                                                           isTimeEntryAvailable:NO
                                                               syncedWithServer:YES
                                                                 isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                    [subject deleteAllPreviousPunches:nil];
                    [subject storeRemotePunch:remotePunchA];
                    [subject storeRemotePunch:remotePunchB];
                    [subject storeRemotePunch:remotePunchC];
                });

                it(@"todays punches should return correctly", ^{
                    NSArray *todaysPunches = [subject allRemotePunchesForDay:[NSDate dateWithTimeIntervalSince1970:1477141800] userUri:@"user:uri"];
                    todaysPunches.count should equal(1);
                });
            });

            context(@"for local punch", ^{
                __block NSDictionary *punchDictionary;
                
                beforeEach(^{
                    NSDateFormatter *longDateFormatter = [[NSDateFormatter alloc] init];
                    longDateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"PST"];
                    longDateFormatter.dateFormat = @"MMM d, YYYY";
                    
                    subject = [[TimeLinePunchesStorage alloc] initWithRemoteSQLPunchSerializer:remoteSQLPunchSerializer
                                                                     localSQLPunchDeserializer:localSQLPunchDeserializer
                                                                                   sqliteStore:sqlLiteStore
                                                                                   userSession:userSession
                                                                                    doorKeeper:doorKeeper
                                                                               punchOEFStorage:punchOEFStorage
                                                                                  dateProvider:dateProvider
                                                                                 dateFormatter:longDateFormatter];
                    
                    punchDictionary = @{@"action_type":@"urn:replicon:time-punch-action:in",
                                              @"date" : @"1970-01-01 00:00:00 +0000",
                                      @"lastSyncTime" : @"2017-03-10 11:01:23 + 0000",
                                           @"offline" : @0,
                                   @"punchSyncStatus" : @0,
                                          @"user_uri" : @"some-user"};
                    
                    NSArray *localPunchArray = [NSArray arrayWithObject:punchDictionary];
                    sqlLiteStore stub_method(@selector(readAllRowsWithArgs:)).and_return(localPunchArray);
                });
                
                it(@"punch count for current day should be zero", ^{
                    NSArray *todaysPunches = [subject allRemotePunchesForDay:[NSDate dateWithTimeIntervalSinceReferenceDate:1477141800] userUri:@"user:uri"];
                    todaysPunches.count should equal(0);
                });
            });
            
            context(@"For IST timeZone", ^{
                beforeEach(^{

                    NSDateFormatter *longDateFormatter = [[NSDateFormatter alloc] init];
                    longDateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"IST"];
                    longDateFormatter.dateFormat = @"MMM d, YYYY";

                    subject = [[TimeLinePunchesStorage alloc] initWithRemoteSQLPunchSerializer:remoteSQLPunchSerializer
                                                                     localSQLPunchDeserializer:localSQLPunchDeserializer
                                                                                   sqliteStore:sqlLiteStore
                                                                                   userSession:userSession
                                                                                    doorKeeper:doorKeeper
                                                                               punchOEFStorage:punchOEFStorage
                                                                                  dateProvider:dateProvider
                                                                                 dateFormatter:longDateFormatter];

                    remotePunchA = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                                      requestID:@"ABCD123"
                                                                       activity:NULL
                                                                       duration:nil
                                                                         client:NULL
                                                                        address:nil
                                                                        userURI:@"user:uri"
                                                                       imageURL:nil
                                                                           date:[NSDate dateWithTimeIntervalSinceReferenceDate:1477098600]
                                                                           task:NULL
                                                                            uri:@"punch:uri"
                                                           isTimeEntryAvailable:NO
                                                               syncedWithServer:YES
                                                                 isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                    remotePunchB = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                                      requestID:@"ABCD12345"
                                                                       activity:NULL
                                                                       duration:nil
                                                                         client:NULL
                                                                        address:nil
                                                                        userURI:@"user:uri"
                                                                       imageURL:nil
                                                                           date:[NSDate dateWithTimeIntervalSinceReferenceDate:1477228200]
                                                                           task:NULL
                                                                            uri:@"punch:uri"
                                                           isTimeEntryAvailable:NO
                                                               syncedWithServer:YES
                                                                 isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                    remotePunchC = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                                      requestID:@"ABCD123456"
                                                                       activity:NULL
                                                                       duration:nil
                                                                         client:NULL
                                                                        address:nil
                                                                        userURI:@"user:uri"
                                                                       imageURL:nil
                                                                           date:[NSDate dateWithTimeIntervalSinceReferenceDate:1477141800]
                                                                           task:NULL
                                                                            uri:@"punch:uri"
                                                           isTimeEntryAvailable:NO
                                                               syncedWithServer:YES
                                                                 isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                    [subject deleteAllPreviousPunches:nil];
                    [subject storeRemotePunch:remotePunchA];
                    [subject storeRemotePunch:remotePunchB];
                    [subject storeRemotePunch:remotePunchC];
                });
                
                it(@"todays punches should return correctly", ^{
                    NSArray *todaysPunches = [subject allRemotePunchesForDay:[NSDate dateWithTimeIntervalSinceReferenceDate:1477141859] userUri:@"user:uri"];
                    todaysPunches.count should equal(1);
                });
            });

            });

        context(@"For punches not synced with server", ^{
            context(@"For PST timeZone", ^{
                beforeEach(^{

                    NSDateFormatter *longDateFormatter = [[NSDateFormatter alloc] init];
                    longDateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"PST"];
                    longDateFormatter.dateFormat = @"MMM d, YYYY";

                    subject = [[TimeLinePunchesStorage alloc] initWithRemoteSQLPunchSerializer:remoteSQLPunchSerializer
                                                                     localSQLPunchDeserializer:localSQLPunchDeserializer
                                                                                   sqliteStore:sqlLiteStore
                                                                                   userSession:userSession
                                                                                    doorKeeper:doorKeeper
                                                                               punchOEFStorage:punchOEFStorage
                                                                                  dateProvider:dateProvider
                                                                                 dateFormatter:longDateFormatter];

                    remotePunchA = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                                      requestID:@"ABCD123"
                                                                       activity:NULL
                                                                       duration:nil
                                                                         client:NULL
                                                                        address:nil
                                                                        userURI:@"user:uri"
                                                                       imageURL:nil
                                                                           date:[NSDate dateWithTimeIntervalSinceReferenceDate:1477098600]
                                                                           task:NULL
                                                                            uri:@"punch:uri"
                                                           isTimeEntryAvailable:NO
                                                               syncedWithServer:NO
                                                                 isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                    remotePunchB = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                                      requestID:@"ABCD12345"
                                                                       activity:NULL
                                                                       duration:nil
                                                                         client:NULL
                                                                        address:nil
                                                                        userURI:@"user:uri"
                                                                       imageURL:nil
                                                                           date:[NSDate dateWithTimeIntervalSinceReferenceDate:1477228200]
                                                                           task:NULL
                                                                            uri:@"punch:uri"
                                                           isTimeEntryAvailable:NO
                                                               syncedWithServer:NO
                                                                 isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                    remotePunchC = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                                      requestID:@"ABCD123456"
                                                                       activity:NULL
                                                                       duration:nil
                                                                         client:NULL
                                                                        address:nil
                                                                        userURI:@"user:uri"
                                                                       imageURL:nil
                                                                           date:[NSDate dateWithTimeIntervalSinceReferenceDate:1477141800]
                                                                           task:NULL
                                                                            uri:@"punch:uri"
                                                           isTimeEntryAvailable:NO
                                                               syncedWithServer:NO
                                                                 isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                    [subject deleteAllPreviousPunches:nil];
                    [subject storeRemotePunch:remotePunchA];
                    [subject storeRemotePunch:remotePunchB];
                    [subject storeRemotePunch:remotePunchC];
                });

                it(@"todays punches should return correctly", ^{
                    NSArray *todaysPunches = [subject allRemotePunchesForDay:[NSDate dateWithTimeIntervalSinceReferenceDate:1477141800] userUri:@"user:uri"];
                    todaysPunches.count should equal(0);
                });
            });

            context(@"For IST timeZone", ^{
                beforeEach(^{

                    NSDateFormatter *longDateFormatter = [[NSDateFormatter alloc] init];
                    longDateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"IST"];
                    longDateFormatter.dateFormat = @"MMM d, YYYY";

                    subject = [[TimeLinePunchesStorage alloc] initWithRemoteSQLPunchSerializer:remoteSQLPunchSerializer
                                                                     localSQLPunchDeserializer:localSQLPunchDeserializer
                                                                                   sqliteStore:sqlLiteStore
                                                                                   userSession:userSession
                                                                                    doorKeeper:doorKeeper
                                                                               punchOEFStorage:punchOEFStorage
                                                                                  dateProvider:dateProvider
                                                                                 dateFormatter:longDateFormatter];

                    remotePunchA = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                                      requestID:@"ABCD123"
                                                                       activity:NULL
                                                                       duration:nil
                                                                         client:NULL
                                                                        address:nil
                                                                        userURI:@"user:uri"
                                                                       imageURL:nil
                                                                           date:[NSDate dateWithTimeIntervalSinceReferenceDate:1477098600]
                                                                           task:NULL
                                                                            uri:@"punch:uri"
                                                           isTimeEntryAvailable:NO
                                                               syncedWithServer:NO
                                                                 isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                    remotePunchB = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                                      requestID:@"ABCD12345"
                                                                       activity:NULL
                                                                       duration:nil
                                                                         client:NULL
                                                                        address:nil
                                                                        userURI:@"user:uri"
                                                                       imageURL:nil
                                                                           date:[NSDate dateWithTimeIntervalSinceReferenceDate:1477228200]
                                                                           task:NULL
                                                                            uri:@"punch:uri"
                                                           isTimeEntryAvailable:NO
                                                               syncedWithServer:NO
                                                                 isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                    remotePunchC = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                                      requestID:@"ABCD123456"
                                                                       activity:NULL
                                                                       duration:nil
                                                                         client:NULL
                                                                        address:nil
                                                                        userURI:@"user:uri"
                                                                       imageURL:nil
                                                                           date:[NSDate dateWithTimeIntervalSinceReferenceDate:1477141800]
                                                                           task:NULL
                                                                            uri:@"punch:uri"
                                                           isTimeEntryAvailable:NO
                                                               syncedWithServer:NO
                                                                 isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                    [subject deleteAllPreviousPunches:nil];
                    [subject storeRemotePunch:remotePunchA];
                    [subject storeRemotePunch:remotePunchB];
                    [subject storeRemotePunch:remotePunchC];
                });
                
                it(@"todays punches should return correctly", ^{
                    NSArray *todaysPunches = [subject allRemotePunchesForDay:[NSDate dateWithTimeIntervalSinceReferenceDate:1477141859] userUri:@"user:uri"];
                    todaysPunches.count should equal(0);
                });
            });

        });

    });

    describe(@"-recentPunchesForUserUri:", ^{
        context(@"when storing a remote punch", ^{
            __block id<Punch> remotePunchA;
            __block id<Punch> remotePunchB;
            __block id<Punch> remotePunchC;
            beforeEach(^{
                remotePunchA = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                                  requestID:@"ABCD123"
                                                                   activity:NULL
                                                                   duration:nil
                                                                     client:NULL
                                                                    address:nil
                                                                    userURI:@"user:uri"
                                                                   imageURL:nil
                                                                       date:[NSDate dateWithTimeIntervalSinceReferenceDate:1]
                                                                       task:NULL
                                                                        uri:@"punch:uri:1"
                                                       isTimeEntryAvailable:NO
                                                           syncedWithServer:NO
                                                             isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                remotePunchB = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                                        uri:@"punch:uri:2"
                                                       isTimeEntryAvailable:NO
                                                           syncedWithServer:NO
                                                             isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                remotePunchC = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                                  requestID:@"ABCD12345"
                                                                   activity:NULL
                                                                   duration:nil
                                                                     client:NULL
                                                                    address:nil
                                                                    userURI:@"user:uri:special"
                                                                   imageURL:nil
                                                                       date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]
                                                                       task:NULL
                                                                        uri:@"punch:uri:3"
                                                       isTimeEntryAvailable:NO
                                                           syncedWithServer:NO
                                                             isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];



                [subject deleteAllPreviousPunches:nil];
                [subject storeRemotePunch:remotePunchA];
                [subject storeRemotePunch:remotePunchB];
                [subject storeRemotePunch:remotePunchC];

            });

            it(@"when storing a punch should store only the most recent punch", ^{
                [[subject recentPunchesForUserUri:@"user:uri"] count] should equal(2);
            });


        });

    });

    describe(@"-recentPunchesForUserUri:", ^{
        context(@"when storing a remote punch", ^{
            __block id<Punch> remotePunchA;
            __block id<Punch> remotePunchB;
            __block id<Punch> remotePunchC;
            beforeEach(^{
                remotePunchA = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                                  requestID:@"ABCD123"
                                                                   activity:NULL
                                                                   duration:nil
                                                                     client:NULL
                                                                    address:nil
                                                                    userURI:@"user:uri"
                                                                   imageURL:nil
                                                                       date:[NSDate dateWithTimeIntervalSinceReferenceDate:1]
                                                                       task:NULL
                                                                        uri:@"punch:uri:1"
                                                       isTimeEntryAvailable:NO
                                                           syncedWithServer:NO
                                                             isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                remotePunchB = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                                        uri:@"punch:uri:2"
                                                       isTimeEntryAvailable:NO
                                                           syncedWithServer:NO
                                                             isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                remotePunchC = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                                  requestID:@"ABCD123"
                                                                   activity:NULL
                                                                   duration:nil
                                                                     client:NULL
                                                                    address:nil
                                                                    userURI:@"user:uri:special"
                                                                   imageURL:nil
                                                                       date:[NSDate dateWithTimeIntervalSinceReferenceDate:1]
                                                                       task:NULL
                                                                        uri:@"punch:uri:3"
                                                       isTimeEntryAvailable:NO
                                                           syncedWithServer:NO
                                                             isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];



                [subject deleteAllPreviousPunches:nil];
                [subject storeRemotePunch:remotePunchA];
                [subject storeRemotePunch:remotePunchB];
                [subject storeRemotePunch:remotePunchC];

            });

            it(@"when storing a punch should store only the most recent punch", ^{
                [subject mostRecentPunchForUserUri:@"user:uri"] should equal(remotePunchA);
            });
            
            
        });
        
    });

    describe(@"-allPunches", ^{
        __block id<Punch> localPunchNonCurrentUserA;
        __block id<Punch> localPunchNonCurrentUserB;
        __block id<Punch> localPunchNonCurrentUserC;
        __block NSArray *expectedArray;
        beforeEach(^{
            localPunchNonCurrentUserA = [[RemotePunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus
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
                                                                           requestID:@"ABCD123456"
                                                                            activity:NULL
                                                                            duration:nil
                                                                              client:NULL
                                                                             address:nil
                                                                             userURI:@"some-user:uri"
                                                                            imageURL:nil
                                                                                date:[NSDate dateWithTimeIntervalSince1970:26390]
                                                                                task:NULL
                                                                                 uri:@"punch:uri:2"
                                                                isTimeEntryAvailable:NO
                                                                    syncedWithServer:NO
                                                                      isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            localPunchNonCurrentUserB = [[RemotePunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                              nonActionedValidations:0
                                                                 previousPunchStatus:Ticking
                                                                     nextPunchStatus:Ticking
                                                                       sourceOfPunch:UnknownSourceOfPunch
                                                                          actionType:PunchActionTypePunchOut
                                                                       oefTypesArray:nil
                                                                        lastSyncTime:NULL
                                                                             project:NULL
                                                                         auditHstory:nil
                                                                           breakType:nil
                                                                            location:nil
                                                                          violations:nil
                                                                           requestID:@"ABCD1234567"
                                                                            activity:NULL
                                                                            duration:nil
                                                                              client:NULL
                                                                             address:nil
                                                                             userURI:@"some-user:uri"
                                                                            imageURL:nil
                                                                                date:[NSDate dateWithTimeIntervalSince1970:36399]
                                                                                task:NULL
                                                                                 uri:@"punch:uri:3"
                                                                isTimeEntryAvailable:NO
                                                                    syncedWithServer:NO
                                                                      isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            localPunchNonCurrentUserC = [[RemotePunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                              nonActionedValidations:0
                                                                 previousPunchStatus:Ticking
                                                                     nextPunchStatus:Ticking
                                                                       sourceOfPunch:UnknownSourceOfPunch
                                                                          actionType:PunchActionTypeTransfer
                                                                       oefTypesArray:nil
                                                                        lastSyncTime:NULL
                                                                             project:NULL
                                                                         auditHstory:nil
                                                                           breakType:nil
                                                                            location:nil
                                                                          violations:nil
                                                                           requestID:@"ABCD12345678"
                                                                            activity:NULL
                                                                            duration:nil
                                                                              client:NULL
                                                                             address:nil
                                                                             userURI:@"some-user:uri"
                                                                            imageURL:nil
                                                                                date:[NSDate dateWithTimeIntervalSince1970:46380]
                                                                                task:NULL
                                                                                 uri:@"punch:uri:4"
                                                                isTimeEntryAvailable:NO
                                                                    syncedWithServer:NO
                                                                      isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            [subject storeRemotePunch:localPunchNonCurrentUserA];
            [subject storeRemotePunch:localPunchNonCurrentUserB];
            [subject storeRemotePunch:localPunchNonCurrentUserC];



        });

        it(@"should return all elements", ^{
            expectedArray = [subject allPunches];
            [expectedArray count] should equal(3);
        });
    });

    describe(@"-deleteAllPreviousPunches:userUri:", ^{

        context(@"When deleting previous unsynched or pending punches", ^{
            __block id<Punch> localPunchNonCurrentUserA;
            __block id<Punch> localPunchNonCurrentUserB;
            __block id<Punch> localPunchNonCurrentUserC;
            __block id<Punch> localPunchCurrentUserD;
            __block id<Punch> localPunchCurrentUserE;
            beforeEach(^{
                localPunchNonCurrentUserA = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                                               requestID:@"ABCD123456"
                                                                                activity:NULL
                                                                                duration:nil
                                                                                  client:NULL
                                                                                 address:nil
                                                                                 userURI:@"some-user:uri"
                                                                                imageURL:nil
                                                                                    date:[NSDate dateWithTimeIntervalSince1970:26390]
                                                                                    task:NULL
                                                                                     uri:@"punch:uri:2"
                                                                    isTimeEntryAvailable:NO
                                                                        syncedWithServer:NO
                                                                          isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                localPunchNonCurrentUserB = [[RemotePunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                                  nonActionedValidations:0
                                                                     previousPunchStatus:Ticking
                                                                         nextPunchStatus:Ticking
                                                                           sourceOfPunch:UnknownSourceOfPunch
                                                                              actionType:PunchActionTypePunchOut
                                                                           oefTypesArray:nil
                                                                            lastSyncTime:NULL
                                                                                 project:NULL
                                                                             auditHstory:nil
                                                                               breakType:nil
                                                                                location:nil
                                                                              violations:nil
                                                                               requestID:@"ABCD1234567"
                                                                                activity:NULL
                                                                                duration:nil
                                                                                  client:NULL
                                                                                 address:nil
                                                                                 userURI:@"some-user:uri"
                                                                                imageURL:nil
                                                                                    date:[NSDate dateWithTimeIntervalSince1970:36399]
                                                                                    task:NULL
                                                                                     uri:@"punch:uri:3"
                                                                    isTimeEntryAvailable:NO
                                                                        syncedWithServer:NO
                                                                          isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                localPunchNonCurrentUserC = [[RemotePunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                                  nonActionedValidations:0
                                                                     previousPunchStatus:Ticking
                                                                         nextPunchStatus:Ticking
                                                                           sourceOfPunch:UnknownSourceOfPunch
                                                                              actionType:PunchActionTypeTransfer
                                                                           oefTypesArray:nil
                                                                            lastSyncTime:NULL
                                                                                 project:NULL
                                                                             auditHstory:nil
                                                                               breakType:nil
                                                                                location:nil
                                                                              violations:nil
                                                                               requestID:@"ABCD12345678"
                                                                                activity:NULL
                                                                                duration:nil
                                                                                  client:NULL
                                                                                 address:nil
                                                                                 userURI:@"some-user:uri"
                                                                                imageURL:nil
                                                                                    date:[NSDate dateWithTimeIntervalSince1970:46380]
                                                                                    task:NULL
                                                                                     uri:@"punch:uri:4"
                                                                    isTimeEntryAvailable:NO
                                                                        syncedWithServer:NO
                                                                          isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                localPunchCurrentUserD = [[RemotePunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus
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
                                                                            requestID:@"ABCD123456789"
                                                                             activity:NULL
                                                                             duration:nil
                                                                               client:NULL
                                                                              address:nil
                                                                              userURI:@"user:uri"
                                                                             imageURL:nil
                                                                                 date:[NSDate dateWithTimeIntervalSince1970:56399]
                                                                                 task:NULL
                                                                                  uri:@"punch:uri:5"
                                                                 isTimeEntryAvailable:NO
                                                                     syncedWithServer:NO
                                                                       isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                localPunchCurrentUserE = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                               nonActionedValidations:0
                                                                  previousPunchStatus:Ticking
                                                                      nextPunchStatus:Ticking
                                                                        sourceOfPunch:UnknownSourceOfPunch
                                                                           actionType:PunchActionTypePunchOut
                                                                        oefTypesArray:nil
                                                                         lastSyncTime:NULL
                                                                              project:NULL
                                                                          auditHstory:nil
                                                                            breakType:nil
                                                                             location:nil
                                                                           violations:nil
                                                                            requestID:@"ABCD1234567890"
                                                                             activity:NULL
                                                                             duration:nil
                                                                               client:NULL
                                                                              address:nil
                                                                              userURI:@"user:uri"
                                                                             imageURL:nil
                                                                                 date:[NSDate dateWithTimeIntervalSince1970:86399]
                                                                                 task:NULL
                                                                                  uri:@"punch:uri:6"
                                                                 isTimeEntryAvailable:NO
                                                                     syncedWithServer:NO
                                                                       isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                [subject storeRemotePunch:localPunchNonCurrentUserA];
                [subject storeRemotePunch:localPunchNonCurrentUserB];
                [subject storeRemotePunch:localPunchNonCurrentUserC];
                [subject storeRemotePunch:localPunchCurrentUserD];
                [subject storeRemotePunch:localPunchCurrentUserE];

                [subject deleteAllPreviousPunches:@"user:uri"];

            });

            it(@"Should delete punches for non current users", ^{
                [[subject recentPunches] count] should equal(2);
                [[subject recentPunchesForUserUri:@"some-user:uri"] count] should  equal(0);
                [[subject recentPunchesForUserUri:@"user:uri"] count] should equal(2);
            });

        });
    });

    describe(@"-deleteAllPunchesForDate:", ^{

        __block id<Punch> remotePunchA;
        __block id<Punch> remotePunchB;
        __block id<Punch> remotePunchC;
        __block id<Punch> remotePunchD;
        beforeEach(^{
            remotePunchA = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                              requestID:@"ABCD123"
                                                               activity:NULL
                                                               duration:nil
                                                                 client:NULL
                                                                address:nil
                                                                userURI:@"user:uri"
                                                               imageURL:nil
                                                                   date:[NSDate dateWithTimeIntervalSince1970:0]
                                                                   task:NULL
                                                                    uri:@"punch:uri:1"
                                                   isTimeEntryAvailable:NO
                                                       syncedWithServer:NO
                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            remotePunchB = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                                   date:[NSDate dateWithTimeIntervalSince1970:43200]
                                                                   task:NULL
                                                                    uri:@"punch:uri:special"
                                                   isTimeEntryAvailable:NO
                                                       syncedWithServer:NO
                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            remotePunchC = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                              requestID:@"ABCD12345"
                                                               activity:NULL
                                                               duration:nil
                                                                 client:NULL
                                                                address:nil
                                                                userURI:@"user:uri"
                                                               imageURL:nil
                                                                   date:[NSDate dateWithTimeIntervalSince1970:86400]
                                                                   task:NULL
                                                                    uri:@"punch:uri:special"
                                                   isTimeEntryAvailable:NO
                                                       syncedWithServer:NO
                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];



            remotePunchD = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                              requestID:@"ABCD123456"
                                                               activity:NULL
                                                               duration:nil
                                                                 client:NULL
                                                                address:nil
                                                                userURI:@"user:uri"
                                                               imageURL:nil
                                                                   date:[NSDate dateWithTimeIntervalSince1970:86399]
                                                                   task:NULL
                                                                    uri:@"punch:uri:2"
                                                   isTimeEntryAvailable:NO
                                                       syncedWithServer:NO
                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];



            [subject deleteAllPreviousPunches:nil];
            [subject storeRemotePunch:remotePunchA];
            [subject storeRemotePunch:remotePunchB];
            [subject storeRemotePunch:remotePunchC];
            [subject storeRemotePunch:remotePunchD];
            [subject deleteAllPunchesForDate:[NSDate dateWithTimeIntervalSince1970:14400]];
        });

        it(@"should delete the remote punch", ^{
            [[subject recentPunches] count] should equal(2);
            
        });
        
    });

    describe(@"-updateIsTimeEntryAvailableWithClientUri:projectUri:taskUri:isTimeEntryAvailable:", ^{

        __block id<Punch> remotePunchA;
        __block id<Punch> remotePunchB;
        __block id<Punch> remotePunchC;

        beforeEach(^{

            ClientType *c1 = [[ClientType alloc] initWithName:@"client-name-1" uri:@"client-uri-1"];
            ProjectType *p1 = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:c1 name:@"project-name-1" uri:@"project-uri-1"];
            TaskType *t1 = [[TaskType alloc] initWithProjectUri:@"project-uri-1" taskPeriod:nil name:@"task-name-1" uri:@"task-uri-1"];


            ClientType *c2 = [[ClientType alloc] initWithName:@"client-name-2" uri:@"client-uri-2"];
            ProjectType *p2 = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:c1 name:@"project-name-2" uri:@"project-uri-2"];
            TaskType *t2 = [[TaskType alloc] initWithProjectUri:@"project-uri-2" taskPeriod:nil name:@"task-name-2" uri:@"task-uri-2"];

            ClientType *c3 = [[ClientType alloc] initWithName:@"client-name-3" uri:@"client-uri-3"];
            ProjectType *p3 = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:c1 name:@"project-name-3" uri:@"project-uri-3"];
            TaskType *t3 = [[TaskType alloc] initWithProjectUri:@"project-uri-3" taskPeriod:nil name:@"task-name-3" uri:@"task-uri-3"];

            remotePunchA = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                 nonActionedValidations:0
                                                    previousPunchStatus:Unknown
                                                        nextPunchStatus:Unknown
                                                          sourceOfPunch:UnknownSourceOfPunch
                                                             actionType:PunchActionTypePunchIn
                                                          oefTypesArray:nil
                                                           lastSyncTime:NULL
                                                                project:p1
                                                            auditHstory:nil
                                                              breakType:nil
                                                               location:nil
                                                             violations:nil
                                                              requestID:@"ABCD123"
                                                               activity:NULL
                                                               duration:nil
                                                                 client:c1
                                                                address:nil
                                                                userURI:@"user:uri"
                                                               imageURL:nil
                                                                   date:[NSDate dateWithTimeIntervalSince1970:0]
                                                                   task:t1
                                                                    uri:@"punch:uri:1"
                                                   isTimeEntryAvailable:YES
                                                       syncedWithServer:NO
                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            remotePunchB = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                 nonActionedValidations:0
                                                    previousPunchStatus:Unknown
                                                        nextPunchStatus:Unknown
                                                          sourceOfPunch:UnknownSourceOfPunch
                                                             actionType:PunchActionTypePunchIn
                                                          oefTypesArray:nil
                                                           lastSyncTime:NULL
                                                                project:p2
                                                            auditHstory:nil
                                                              breakType:nil
                                                               location:nil
                                                             violations:nil
                                                              requestID:@"ABCD1234"
                                                               activity:NULL
                                                               duration:nil
                                                                 client:c2
                                                                address:nil
                                                                userURI:@"user:uri"
                                                               imageURL:nil
                                                                   date:[NSDate dateWithTimeIntervalSince1970:43200]
                                                                   task:t2
                                                                    uri:@"punch:uri:special:1"
                                                   isTimeEntryAvailable:YES
                                                       syncedWithServer:NO
                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            remotePunchC = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                 nonActionedValidations:0
                                                    previousPunchStatus:Unknown
                                                        nextPunchStatus:Unknown
                                                          sourceOfPunch:UnknownSourceOfPunch
                                                             actionType:PunchActionTypePunchIn
                                                          oefTypesArray:nil
                                                           lastSyncTime:NULL
                                                                project:p3
                                                            auditHstory:nil
                                                              breakType:nil
                                                               location:nil
                                                             violations:nil
                                                              requestID:@"ABCD12345"
                                                               activity:NULL
                                                               duration:nil
                                                                 client:c3
                                                                address:nil
                                                                userURI:@"user:uri"
                                                               imageURL:nil
                                                                   date:[NSDate dateWithTimeIntervalSince1970:86400]
                                                                   task:t3
                                                                    uri:@"punch:uri:special"
                                                   isTimeEntryAvailable:YES
                                                       syncedWithServer:NO
                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];


            [subject deleteAllPreviousPunches:nil];
            [subject storeRemotePunch:remotePunchA];
            [subject storeRemotePunch:remotePunchB];
            [subject storeRemotePunch:remotePunchC];

            [subject updateIsTimeEntryAvailableColumnMatchingClientUri:@"client-uri-2" projectUri:@"project-uri-2" taskUri:@"task-uri-2" isTimeEntryAvailable:NO];

        });

        it(@"should delete the remote punch", ^{
            id<Punch> punch = [[subject recentPunches] objectAtIndex:1];
            [punch isTimeEntryAvailable] should be_falsy;
        });

    });

});

SPEC_END
