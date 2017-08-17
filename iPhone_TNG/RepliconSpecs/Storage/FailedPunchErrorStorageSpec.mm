#import <Cedar/Cedar.h>
#import "FailedPunchErrorStorage.h"
#import "SQLiteTableStore.h"
#import "SQLiteDatabaseConnection.h"
#import "QueryStringBuilder.h"
#import "ClientType.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "InjectorProvider.h"
#import "Punch.h"
#import "BreakType.h"
#import "Activity.h"
#import "RemotePunch.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(FailedPunchErrorStorageSpec)

describe(@"FailedPunchErrorStorage", ^{
    __block FailedPunchErrorStorage *subject;
    __block DoorKeeper *doorKeeper;
    __block SQLiteTableStore<CedarDouble> *sqlLiteStore;
    __block id <BSBinder,BSInjector> injector;
    __block id<UserSession> userSession;

    beforeEach(^{
        injector = [InjectorProvider injector];
        sqlLiteStore = (id)[[SQLiteTableStore alloc] initWithSqliteDatabaseConnection:[[SQLiteDatabaseConnection alloc] init]
                                                                   queryStringBuilder:[[QueryStringBuilder alloc] init]
                                                                         databaseName:@"Test"
                                                                            tableName:@"failed_punch_error"];
        doorKeeper = nice_fake_for([DoorKeeper class]);
        userSession = nice_fake_for(@protocol(UserSession));
        userSession stub_method(@selector(currentUserURI)).and_return(@"user:uri");
        
        subject = [[FailedPunchErrorStorage alloc] initWithUserSqliteStore:sqlLiteStore userSession:userSession doorKeeper:doorKeeper];
        spy_on(subject);
        spy_on(sqlLiteStore);
    });
    
    describe(@"-storePunchErrors:", ^{
        context(@"punch into project", ^{
            context(@"when storing a punch", ^{
                __block id<Punch> remotePunchA;
                __block id<Punch> remotePunchB;
                __block id<Punch> remotePunchC;
                beforeEach(^{
                    ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                    
                    ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:client
                                                                                                   name:@"project-name"
                                                                                                    uri:@"project-uri"];
                    
                    TaskType *task = [[TaskType alloc]initWithProjectUri:@"project-uri"
                                                               taskPeriod:nil
                                                                     name:@"task-name"
                                                                      uri:@"task-uri"];
                    
                    remotePunchA = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                         nonActionedValidations:0
                                                            previousPunchStatus:Ticking
                                                                nextPunchStatus:Ticking
                                                                  sourceOfPunch:UnknownSourceOfPunch
                                                                     actionType:PunchActionTypePunchIn
                                                                  oefTypesArray:nil
                                                                   lastSyncTime:nil
                                                                        project:project
                                                                    auditHstory:nil
                                                                      breakType:nil
                                                                       location:nil
                                                                     violations:nil
                                                                      requestID:@"ABCD123"
                                                                       activity:nil
                                                                       duration:nil
                                                                         client:client
                                                                        address:nil
                                                                        userURI:@"user:uri"
                                                                       imageURL:nil
                                                                           date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]
                                                                           task:task
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
                                                                     actionType:PunchActionTypePunchOut
                                                                  oefTypesArray:nil
                                                                   lastSyncTime:nil
                                                                        project:nil
                                                                    auditHstory:nil
                                                                      breakType:nil
                                                                       location:nil
                                                                     violations:nil
                                                                      requestID:@"ABCD1234"
                                                                       activity:nil
                                                                       duration:nil
                                                                         client:nil
                                                                        address:nil
                                                                        userURI:@"user:uri"
                                                                       imageURL:nil
                                                                           date:[NSDate dateWithTimeIntervalSinceReferenceDate:1]
                                                                           task:nil
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
                                                                     actionType:PunchActionTypeTransfer
                                                                  oefTypesArray:nil
                                                                   lastSyncTime:nil
                                                                        project:project
                                                                    auditHstory:nil
                                                                      breakType:nil
                                                                       location:nil
                                                                     violations:nil
                                                                      requestID:@"ABCD12345"
                                                                       activity:NULL
                                                                       duration:nil
                                                                         client:client
                                                                        address:nil
                                                                        userURI:@"user:uri"
                                                                       imageURL:nil
                                                                           date:[NSDate dateWithTimeIntervalSinceReferenceDate:2]
                                                                           task:task
                                                                            uri:@"punch:uri:special"
                                                           isTimeEntryAvailable:NO
                                                               syncedWithServer:NO
                                                                 isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    NSDictionary *errorDictionary = @{@"displayText":@"error-msg"};
                    
                    [subject.sqliteStore deleteAllRows];
                    [subject storeFailedPunchError:errorDictionary punch:remotePunchA];
                    [subject storeFailedPunchError:errorDictionary punch:remotePunchB];
                    [subject storeFailedPunchError:errorDictionary punch:remotePunchC];
                });
                
                it(@"should return all stored errors", ^{
                    [[subject getFailedPunchErrors] count] should equal(3);
                });
                
                it(@"should return a clock in entry with client/projecttask values", ^{
                    NSDictionary *errorDictionary = [subject getFailedPunchErrors][0];
                    errorDictionary[@"error_msg"] should equal(@"error-msg");
                    errorDictionary[@"request_id"] should equal(@"ABCD123");
                    errorDictionary[@"client_name"] should equal(@"client-name");
                    errorDictionary[@"project_name"] should equal(@"project-name");
                    errorDictionary[@"activity_name"] should equal([NSNull null]);
                    errorDictionary[@"break_name"] should equal([NSNull null]);
                    errorDictionary[@"action_type"] should equal(@"Clocked In");
                    errorDictionary[@"user_uri"] should equal(@"user:uri");
                    errorDictionary[@"task_name"] should equal(@"task-name");
                });

                it(@"should return a clock out entry", ^{
                    NSDictionary *errorDictionary = [subject getFailedPunchErrors][1];
                    
                    errorDictionary[@"error_msg"] should equal(@"error-msg");
                    errorDictionary[@"request_id"] should equal(@"ABCD1234");
                    errorDictionary[@"client_name"] should equal([NSNull null]);
                    errorDictionary[@"project_name"] should equal([NSNull null]);
                    errorDictionary[@"activity_name"] should equal([NSNull null]);
                    errorDictionary[@"break_name"] should equal([NSNull null]);
                    errorDictionary[@"action_type"] should equal(@"Clocked Out");
                    errorDictionary[@"user_uri"] should equal(@"user:uri");
                    errorDictionary[@"task_name"] should equal([NSNull null]);
                });

                it(@"should return a transfer entry", ^{
                    NSDictionary *errorDictionary = [subject getFailedPunchErrors][2];
                    
                    errorDictionary[@"error_msg"] should equal(@"error-msg");
                    errorDictionary[@"request_id"] should equal(@"ABCD12345");
                    errorDictionary[@"client_name"] should equal(@"client-name");
                    errorDictionary[@"project_name"] should equal(@"project-name");
                    errorDictionary[@"activity_name"] should equal([NSNull null]);
                    errorDictionary[@"break_name"] should equal([NSNull null]);
                    errorDictionary[@"action_type"] should equal(@"Transferred");
                    errorDictionary[@"user_uri"] should equal(@"user:uri");
                    errorDictionary[@"task_name"] should equal(@"task-name");
                });

            });
        });
        
        context(@"punch into activity", ^{
            context(@"when storing a punch", ^{
                __block id<Punch> remotePunchA;
                __block id<Punch> remotePunchB;
                __block id<Punch> remotePunchC;
                beforeEach(^{
                    Activity *activity = [[Activity alloc]initWithName:@"activity-name" uri:@"activity-uri"];
                    
                    remotePunchA = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                         nonActionedValidations:0
                                                            previousPunchStatus:Ticking
                                                                nextPunchStatus:Ticking
                                                                  sourceOfPunch:UnknownSourceOfPunch
                                                                     actionType:PunchActionTypePunchIn
                                                                  oefTypesArray:nil
                                                                   lastSyncTime:nil
                                                                        project:nil
                                                                    auditHstory:nil
                                                                      breakType:nil
                                                                       location:nil
                                                                     violations:nil
                                                                      requestID:@"ABCD123"
                                                                       activity:activity
                                                                       duration:nil
                                                                         client:nil
                                                                        address:nil
                                                                        userURI:@"user:uri"
                                                                       imageURL:nil
                                                                           date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]
                                                                           task:nil
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
                                                                     actionType:PunchActionTypePunchOut
                                                                  oefTypesArray:nil
                                                                   lastSyncTime:nil
                                                                        project:nil
                                                                    auditHstory:nil
                                                                      breakType:nil
                                                                       location:nil
                                                                     violations:nil
                                                                      requestID:@"ABCD1234"
                                                                       activity:nil
                                                                       duration:nil
                                                                         client:nil
                                                                        address:nil
                                                                        userURI:@"user:uri"
                                                                       imageURL:nil
                                                                           date:[NSDate dateWithTimeIntervalSinceReferenceDate:1]
                                                                           task:nil
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
                                                                     actionType:PunchActionTypeTransfer
                                                                  oefTypesArray:nil
                                                                   lastSyncTime:nil
                                                                        project:nil
                                                                    auditHstory:nil
                                                                      breakType:nil
                                                                       location:nil
                                                                     violations:nil
                                                                      requestID:@"ABCD12345"
                                                                       activity:activity
                                                                       duration:nil
                                                                         client:nil
                                                                        address:nil
                                                                        userURI:@"user:uri"
                                                                       imageURL:nil
                                                                           date:[NSDate dateWithTimeIntervalSinceReferenceDate:2]
                                                                           task:nil
                                                                            uri:@"punch:uri:special"
                                                           isTimeEntryAvailable:NO
                                                               syncedWithServer:NO
                                                                 isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    
                    NSDictionary *errorDictionary = @{@"displayText":@"error-msg"};
                    [subject.sqliteStore deleteAllRows];
                    [subject storeFailedPunchError:errorDictionary punch:remotePunchA];
                    [subject storeFailedPunchError:errorDictionary punch:remotePunchB];
                    [subject storeFailedPunchError:errorDictionary punch:remotePunchC];
                });
                
                it(@"should return all stored errors", ^{
                    [[subject getFailedPunchErrors] count] should equal(3);
                });
                
                it(@"should return a clock in entry with activity values", ^{
                    NSDictionary *errorDictionary = [subject getFailedPunchErrors][0];
                    errorDictionary[@"error_msg"] should equal(@"error-msg");
                    errorDictionary[@"request_id"] should equal(@"ABCD123");
                    errorDictionary[@"client_name"] should equal([NSNull null]);
                    errorDictionary[@"project_name"] should equal([NSNull null]);
                    errorDictionary[@"activity_name"] should equal(@"activity-name");
                    errorDictionary[@"break_name"] should equal([NSNull null]);
                    errorDictionary[@"action_type"] should equal(@"Clocked In");
                    errorDictionary[@"user_uri"] should equal(@"user:uri");
                    errorDictionary[@"task_name"] should equal([NSNull null]);
                });
                
                it(@"should return a clock out entry", ^{
                    NSDictionary *errorDictionary = [subject getFailedPunchErrors][1];
                    
                    errorDictionary[@"error_msg"] should equal(@"error-msg");
                    errorDictionary[@"request_id"] should equal(@"ABCD1234");
                    errorDictionary[@"client_name"] should equal([NSNull null]);
                    errorDictionary[@"project_name"] should equal([NSNull null]);
                    errorDictionary[@"activity_name"] should equal([NSNull null]);
                    errorDictionary[@"break_name"] should equal([NSNull null]);
                    errorDictionary[@"action_type"] should equal(@"Clocked Out");
                    errorDictionary[@"user_uri"] should equal(@"user:uri");
                    errorDictionary[@"task_name"] should equal([NSNull null]);
                });
                
                it(@"should return a transfer entry", ^{
                    NSDictionary *errorDictionary = [subject getFailedPunchErrors][2];
                    
                    errorDictionary[@"error_msg"] should equal(@"error-msg");
                    errorDictionary[@"request_id"] should equal(@"ABCD12345");
                    errorDictionary[@"client_name"] should equal([NSNull null]);
                    errorDictionary[@"project_name"] should equal([NSNull null]);
                    errorDictionary[@"activity_name"] should equal(@"activity-name");
                    errorDictionary[@"break_name"] should equal([NSNull null]);
                    errorDictionary[@"action_type"] should equal(@"Transferred");
                    errorDictionary[@"user_uri"] should equal(@"user:uri");
                    errorDictionary[@"task_name"] should equal([NSNull null]);
                });
                
            });
        });

        context(@"break flow", ^{
            context(@"when storing a punch", ^{
                __block id<Punch> remotePunch;
                beforeEach(^{
                    
                    BreakType *breakType = [[BreakType alloc] initWithName:@"break-name" uri:@"break-uri"];
                    
                    remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                        nonActionedValidations:0
                                                           previousPunchStatus:Ticking
                                                               nextPunchStatus:Ticking
                                                                 sourceOfPunch:UnknownSourceOfPunch
                                                                    actionType:PunchActionTypeStartBreak
                                                                 oefTypesArray:nil
                                                                  lastSyncTime:nil
                                                                       project:nil
                                                                   auditHstory:nil
                                                                     breakType:breakType
                                                                      location:nil
                                                                    violations:nil
                                                                     requestID:@"ABCD123456"
                                                                      activity:nil
                                                                      duration:nil
                                                                        client:nil
                                                                       address:nil
                                                                       userURI:@"user:uri"
                                                                      imageURL:nil
                                                                          date:[NSDate dateWithTimeIntervalSinceReferenceDate:1]
                                                                          task:nil
                                                                           uri:@"punch:uri:2"
                                                          isTimeEntryAvailable:NO
                                                              syncedWithServer:NO
                                                                isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    NSDictionary *errorDictionary = @{@"displayText":@"error-msg"};
                    [subject.sqliteStore deleteAllRows];
                    [subject storeFailedPunchError:errorDictionary punch:remotePunch];
                });
                
                it(@"should return all stored errors", ^{
                    [[subject getFailedPunchErrors] count] should equal(1);
                });
                
                it(@"should return entry with break values", ^{
                    NSDictionary *errorDictionary = [subject getFailedPunchErrors][0];
                    
                    errorDictionary[@"error_msg"] should equal(@"error-msg");
                    errorDictionary[@"request_id"] should equal(@"ABCD123456");
                    errorDictionary[@"client_name"] should equal([NSNull null]);
                    errorDictionary[@"project_name"] should equal([NSNull null]);
                    errorDictionary[@"activity_name"] should equal([NSNull null]);
                    errorDictionary[@"break_name"] should equal(@"break-name");
                    errorDictionary[@"action_type"] should equal(@"break-name Break");
                    errorDictionary[@"user_uri"] should equal(@"user:uri");
                    errorDictionary[@"task_name"] should equal([NSNull null]);
                });
            });
        });

        context(@"simple punch flow", ^{
            context(@"when storing a punch", ^{
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
                                                                   lastSyncTime:nil
                                                                        project:nil
                                                                    auditHstory:nil
                                                                      breakType:nil
                                                                       location:nil
                                                                     violations:nil
                                                                      requestID:@"ABCD123"
                                                                       activity:nil
                                                                       duration:nil
                                                                         client:nil
                                                                        address:nil
                                                                        userURI:@"user:uri"
                                                                       imageURL:nil
                                                                           date:[NSDate dateWithTimeIntervalSinceReferenceDate:0]
                                                                           task:nil
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
                                                                     actionType:PunchActionTypePunchOut
                                                                  oefTypesArray:nil
                                                                   lastSyncTime:nil
                                                                        project:nil
                                                                    auditHstory:nil
                                                                      breakType:nil
                                                                       location:nil
                                                                     violations:nil
                                                                      requestID:@"ABCD1234"
                                                                       activity:nil
                                                                       duration:nil
                                                                         client:nil
                                                                        address:nil
                                                                        userURI:@"user:uri"
                                                                       imageURL:nil
                                                                           date:[NSDate dateWithTimeIntervalSinceReferenceDate:1]
                                                                           task:nil
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
                                                                     actionType:PunchActionTypeTransfer
                                                                  oefTypesArray:nil
                                                                   lastSyncTime:nil
                                                                        project:nil
                                                                    auditHstory:nil
                                                                      breakType:nil
                                                                       location:nil
                                                                     violations:nil
                                                                      requestID:@"ABCD12345"
                                                                       activity:nil
                                                                       duration:nil
                                                                         client:nil
                                                                        address:nil
                                                                        userURI:@"user:uri"
                                                                       imageURL:nil
                                                                           date:[NSDate dateWithTimeIntervalSinceReferenceDate:2]
                                                                           task:nil
                                                                            uri:@"punch:uri:special"
                                                           isTimeEntryAvailable:NO
                                                               syncedWithServer:NO
                                                                 isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    
                    NSDictionary *errorDictionary = @{@"displayText":@"error-msg"};
                    [subject.sqliteStore deleteAllRows];
                    [subject storeFailedPunchError:errorDictionary punch:remotePunchA];
                    [subject storeFailedPunchError:errorDictionary punch:remotePunchB];
                    [subject storeFailedPunchError:errorDictionary punch:remotePunchC];
                });
                
                it(@"should return all stored errors", ^{
                    [[subject getFailedPunchErrors] count] should equal(3);
                });
                
                it(@"should return a clock in entry", ^{
                    NSDictionary *errorDictionary = [subject getFailedPunchErrors][0];
                    
                    errorDictionary[@"error_msg"] should equal(@"error-msg");
                    errorDictionary[@"request_id"] should equal(@"ABCD123");
                    errorDictionary[@"client_name"] should equal([NSNull null]);
                    errorDictionary[@"project_name"] should equal([NSNull null]);
                    errorDictionary[@"activity_name"] should equal([NSNull null]);
                    errorDictionary[@"break_name"] should equal([NSNull null]);
                    errorDictionary[@"action_type"] should equal(@"Clocked In");
                    errorDictionary[@"user_uri"] should equal(@"user:uri");
                    errorDictionary[@"task_name"] should equal([NSNull null]);
                });
                
                it(@"should return a clock out entry", ^{
                    NSDictionary *errorDictionary = [subject getFailedPunchErrors][1];
                    
                    errorDictionary[@"error_msg"] should equal(@"error-msg");
                    errorDictionary[@"request_id"] should equal(@"ABCD1234");
                    errorDictionary[@"client_name"] should equal([NSNull null]);
                    errorDictionary[@"project_name"] should equal([NSNull null]);
                    errorDictionary[@"activity_name"] should equal([NSNull null]);
                    errorDictionary[@"break_name"] should equal([NSNull null]);
                    errorDictionary[@"action_type"] should equal(@"Clocked Out");
                    errorDictionary[@"user_uri"] should equal(@"user:uri");
                    errorDictionary[@"task_name"] should equal([NSNull null]);
                });
                
                it(@"should return a transfer entry", ^{
                    NSDictionary *errorDictionary = [subject getFailedPunchErrors][2];
                    
                    errorDictionary[@"error_msg"] should equal(@"error-msg");
                    errorDictionary[@"request_id"] should equal(@"ABCD12345");
                    errorDictionary[@"client_name"] should equal([NSNull null]);
                    errorDictionary[@"project_name"] should equal([NSNull null]);
                    errorDictionary[@"activity_name"] should equal([NSNull null]);
                    errorDictionary[@"break_name"] should equal([NSNull null]);
                    errorDictionary[@"action_type"] should equal(@"Transferred");
                    errorDictionary[@"user_uri"] should equal(@"user:uri");
                    errorDictionary[@"task_name"] should equal([NSNull null]);
                });
                
            });
        });
    });
    
    describe(@"-deletePunchErrors:", ^{
            context(@"when deleting a punch", ^{
                __block id<Punch> remotePunchA;
                __block id<Punch> remotePunchB;
                __block id<Punch> remotePunchC;
                beforeEach(^{
                    ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                    
                    ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                               isTimeAllocationAllowed:NO
                                                                                         projectPeriod:nil
                                                                                            clientType:client
                                                                                                  name:@"project-name"
                                                                                                   uri:@"project-uri"];
                    
                    TaskType *task = [[TaskType alloc]initWithProjectUri:@"project-uri"
                                                              taskPeriod:nil
                                                                    name:@"task-name"
                                                                     uri:@"task-uri"];
                    
                    remotePunchA = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                         nonActionedValidations:0
                                                            previousPunchStatus:Ticking
                                                                nextPunchStatus:Ticking
                                                                  sourceOfPunch:UnknownSourceOfPunch
                                                                     actionType:PunchActionTypePunchIn
                                                                  oefTypesArray:nil
                                                                   lastSyncTime:nil
                                                                        project:project
                                                                    auditHstory:nil
                                                                      breakType:nil
                                                                       location:nil
                                                                     violations:nil
                                                                      requestID:@"ABCD123"
                                                                       activity:nil
                                                                       duration:nil
                                                                         client:client
                                                                        address:nil
                                                                        userURI:@"user:uri"
                                                                       imageURL:nil
                                                                           date:[NSDate dateWithTimeIntervalSince1970:1]
                                                                           task:task
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
                                                                     actionType:PunchActionTypePunchOut
                                                                  oefTypesArray:nil
                                                                   lastSyncTime:nil
                                                                        project:nil
                                                                    auditHstory:nil
                                                                      breakType:nil
                                                                       location:nil
                                                                     violations:nil
                                                                      requestID:@"ABCD1234"
                                                                       activity:nil
                                                                       duration:nil
                                                                         client:nil
                                                                        address:nil
                                                                        userURI:@"user:uri"
                                                                       imageURL:nil
                                                                           date:[NSDate dateWithTimeIntervalSince1970:2]
                                                                           task:nil
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
                                                                     actionType:PunchActionTypeTransfer
                                                                  oefTypesArray:nil
                                                                   lastSyncTime:nil
                                                                        project:project
                                                                    auditHstory:nil
                                                                      breakType:nil
                                                                       location:nil
                                                                     violations:nil
                                                                      requestID:@"ABCD12345"
                                                                       activity:NULL
                                                                       duration:nil
                                                                         client:client
                                                                        address:nil
                                                                        userURI:@"user:uri"
                                                                       imageURL:nil
                                                                           date:[NSDate dateWithTimeIntervalSince1970:3]
                                                                           task:task
                                                                            uri:@"punch:uri:special"
                                                           isTimeEntryAvailable:NO
                                                               syncedWithServer:NO
                                                                 isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    NSDictionary *errorDictionary = @{@"displayText":@"error-msg"};
                    
                    [subject.sqliteStore deleteAllRows];
                    [subject storeFailedPunchError:errorDictionary punch:remotePunchA];
                    [subject storeFailedPunchError:errorDictionary punch:remotePunchB];
                    [subject storeFailedPunchError:errorDictionary punch:remotePunchC];
                    [subject deletePunchErrors:@[@{@"request_id":@"ABCD123"}, @{@"request_id":@"ABCD1234"}, @{@"request_id":@"ABCD12345"}]];
                });
                
                it(@"should delete all puncches errors which already shown to user", ^{
                    [[subject getFailedPunchErrors] count] should equal(0);
                });
        });
    });
    
    describe(@"as a <DoorKeeperLogOutObserver>", ^{
        context(@"when deleting a punch", ^{
            __block id<Punch> remotePunchA;
            __block id<Punch> remotePunchB;
            __block id<Punch> remotePunchC;
            beforeEach(^{
                ClientType *client = [[ClientType alloc]initWithName:@"client-name" uri:@"client-uri"];
                
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"project-name"
                                                                                               uri:@"project-uri"];
                
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"project-uri"
                                                          taskPeriod:nil
                                                                name:@"task-name"
                                                                 uri:@"task-uri"];
                
                remotePunchA = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                     nonActionedValidations:0
                                                        previousPunchStatus:Ticking
                                                            nextPunchStatus:Ticking
                                                              sourceOfPunch:UnknownSourceOfPunch
                                                                 actionType:PunchActionTypePunchIn
                                                              oefTypesArray:nil
                                                               lastSyncTime:nil
                                                                    project:project
                                                                auditHstory:nil
                                                                  breakType:nil
                                                                   location:nil
                                                                 violations:nil
                                                                  requestID:@"ABCD123"
                                                                   activity:nil
                                                                   duration:nil
                                                                     client:client
                                                                    address:nil
                                                                    userURI:@"user:uri"
                                                                   imageURL:nil
                                                                       date:[NSDate dateWithTimeIntervalSince1970:1]
                                                                       task:task
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
                                                                 actionType:PunchActionTypePunchOut
                                                              oefTypesArray:nil
                                                               lastSyncTime:nil
                                                                    project:nil
                                                                auditHstory:nil
                                                                  breakType:nil
                                                                   location:nil
                                                                 violations:nil
                                                                  requestID:@"ABCD1234"
                                                                   activity:nil
                                                                   duration:nil
                                                                     client:nil
                                                                    address:nil
                                                                    userURI:@"user:uri"
                                                                   imageURL:nil
                                                                       date:[NSDate dateWithTimeIntervalSince1970:2]
                                                                       task:nil
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
                                                                 actionType:PunchActionTypeTransfer
                                                              oefTypesArray:nil
                                                               lastSyncTime:nil
                                                                    project:project
                                                                auditHstory:nil
                                                                  breakType:nil
                                                                   location:nil
                                                                 violations:nil
                                                                  requestID:@"ABCD12345"
                                                                   activity:NULL
                                                                   duration:nil
                                                                     client:client
                                                                    address:nil
                                                                    userURI:@"user:uri"
                                                                   imageURL:nil
                                                                       date:[NSDate dateWithTimeIntervalSince1970:3]
                                                                       task:task
                                                                        uri:@"punch:uri:special"
                                                       isTimeEntryAvailable:NO
                                                           syncedWithServer:NO
                                                             isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                NSDictionary *errorDictionary = @{@"displayText":@"error-msg"};
                
                [subject.sqliteStore deleteAllRows];
                [subject storeFailedPunchError:errorDictionary punch:remotePunchA];
                [subject storeFailedPunchError:errorDictionary punch:remotePunchB];
                [subject storeFailedPunchError:errorDictionary punch:remotePunchC];
                [subject doorKeeperDidLogOut:nil];
            });
            
            it(@"should delete all punches errors which already shown to user", ^{
                [[subject getFailedPunchErrors] count] should equal(0);
            });
        });
    });
});

SPEC_END
