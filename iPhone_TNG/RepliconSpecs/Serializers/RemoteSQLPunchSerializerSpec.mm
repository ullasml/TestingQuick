#import <Cedar/Cedar.h>
#import <CoreLocation/CoreLocation.h>
#import <MacTypes.h>
#import "RemoteSQLPunchSerializer.h"
#import "RemotePunch.h"
#import "Constants.h"
#import "BreakType.h"
#import "ClientType.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "Activity.h"
#import "OEFType.h"
#import "Enum.h"
#import "PunchActionTypes.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(RemoteSQLPunchSerializerSpec)

describe(@"RemoteSQLPunchSerializer", ^{
    __block RemoteSQLPunchSerializer *subject;
    __block id <BSInjector,BSBinder> injector;
    beforeEach(^{
        injector = [InjectorProvider injector];

        subject = [injector getInstance:[RemoteSQLPunchSerializer class]];
    });
    
    describe(@"-serializePunchForStorage:", ^{

        context(@"When the punch has invalid client/project/task", ^{

            __block NSDictionary *punchDictionary;

            beforeEach(^{

                ClientType *clientType = [[ClientType alloc]initWithName:@"client name" uri:@"client:name:uri"];

                ProjectType *projectType = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"project name"
                                                                                                    uri:@"project:type:uri"];

                TaskType *taskType = [[TaskType alloc] initWithProjectUri:nil
                                                               taskPeriod:nil
                                                                     name:@"task name"
                                                                      uri:@"task:type:uri"];


                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Unknown
                                                                        nextPunchStatus:Unknown
                                                                          sourceOfPunch:UnknownSourceOfPunch
                                                                             actionType:PunchActionTypePunchIn
                                                                          oefTypesArray:nil
                                                                           lastSyncTime:NULL
                                                                                project:projectType
                                                                            auditHstory:nil
                                                                              breakType:nil
                                                                               location:nil
                                                                             violations:nil
                                                                              requestID:NULL
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:clientType
                                                                                address:@"an address"
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:taskType
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:NO
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"address": @"an address",
                                               @"client_name": @"client name",
                                               @"client_uri": @"client:name:uri",
                                               @"project_name": @"project name",
                                               @"project_uri": @"project:type:uri",
                                               @"task_name": @"task name",
                                               @"task_uri": @"task:type:uri",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@0,
                                               @"nextPunchPairStatus":@3,
                                               @"previousPunchPairStatus":@3,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
        });

        context(@"when the punch action type is punch in", ^{
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Ticking
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:UnknownSourceOfPunch
                                                                             actionType:PunchActionTypePunchIn
                                                                          oefTypesArray:nil
                                                                           lastSyncTime:nil
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
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"request_id": @"ABCD1234",
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
        });
        
        context(@"when the punch action type is punch out", ^{
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Ticking
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:UnknownSourceOfPunch
                                                                             actionType:PunchActionTypePunchOut
                                                                          oefTypesArray:nil
                                                                           lastSyncTime:nil
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
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:NO
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_OUT,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"request_id": @"ABCD1234",
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@0,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
        });
        
        context(@"when the punch action type is transfer", ^{
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Ticking
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:UnknownSourceOfPunch
                                                                             actionType:PunchActionTypeTransfer
                                                                          oefTypesArray:nil
                                                                           lastSyncTime:nil
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
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_TRANSFER,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"request_id": @"ABCD1234",
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
        });
        
        context(@"when the punch action type is start break", ^{
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                BreakType *breakType = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal:break:uri"];
                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Ticking
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:UnknownSourceOfPunch
                                                                             actionType:PunchActionTypeStartBreak
                                                                          oefTypesArray:nil
                                                                           lastSyncTime:NULL
                                                                                project:NULL
                                                                            auditHstory:nil
                                                                              breakType:breakType
                                                                               location:nil
                                                                             violations:nil
                                                                              requestID:@"ABCD1234"
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:NULL
                                                                                address:nil
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:NO
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_BREAK,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"break_type_name": @"Meal Break",
                                               @"break_type_uri": @"meal:break:uri",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"request_id": @"ABCD1234",
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@0,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
        });
        
        context(@"when the punch action type is unknown", ^{
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Ticking
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:UnknownSourceOfPunch
                                                                             actionType:PunchActionTypeUnknown
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
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": @"PunchActionTypeUnknown",
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"request_id": @"ABCD1234",
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
        });
        
        context(@"when the punch has an image url", ^{
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                NSURL *imageURL = [NSURL URLWithString:@"http://www.example.com/image.jpg"];
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
                                                                              requestID:NULL
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:NULL
                                                                                address:nil
                                                                                userURI:@"user:uri"
                                                                               imageURL:imageURL
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"image_url": @"http://www.example.com/image.jpg",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
        });
        
        context(@"when the punch has a location", ^{
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                CLLocationDegrees latitude = 80.80;
                CLLocationDegrees longitude = 120.120;
                CLLocationAccuracy horizontalAccuracy = 123.123;
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:-1 horizontalAccuracy:horizontalAccuracy verticalAccuracy:-1 timestamp:[NSDate date]];
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
                                                                               location:location
                                                                             violations:nil
                                                                              requestID:NULL
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:NULL
                                                                                address:nil
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"location_latitude": @(80.80),
                                               @"location_longitude": @(120.120),
                                               @"location_horizontal_accuracy": @(123.123),
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
        });
        
        context(@"when the punch has an address", ^{
            __block NSDictionary *punchDictionary;
            beforeEach(^{
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
                                                                              requestID:NULL
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:NULL
                                                                                address:@"an address"
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"address": @"an address",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
        });
        
        context(@"when the punch client/project/task is not null", ^{
            
            ClientType *clientType = [[ClientType alloc]initWithName:@"client name" uri:@"client:name:uri"];
            
            ProjectType *projectType = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO
                                                                            isTimeAllocationAllowed:NO
                                                                                      projectPeriod:nil
                                                                                         clientType:nil
                                                                                               name:@"project name"
                                                                                                uri:@"project:type:uri"];
            
            TaskType *taskType = [[TaskType alloc] initWithProjectUri:nil
                                                           taskPeriod:nil
                                                                 name:@"task name"
                                                                  uri:@"task:type:uri"];
            
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                
                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Ticking
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:UnknownSourceOfPunch
                                                                             actionType:PunchActionTypePunchIn
                                                                          oefTypesArray:nil
                                                                           lastSyncTime:NULL
                                                                                project:projectType
                                                                            auditHstory:nil
                                                                              breakType:nil
                                                                               location:nil
                                                                             violations:nil
                                                                              requestID:NULL
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:clientType
                                                                                address:@"an address"
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:taskType
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"address": @"an address",
                                               @"client_name": @"client name",
                                               @"client_uri": @"client:name:uri",
                                               @"project_name": @"project name",
                                               @"project_uri": @"project:type:uri",
                                               @"task_name": @"task name",
                                               @"task_uri": @"task:type:uri",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
            
        });
        
        
        context(@"when the punch has client/project and task is null", ^{
            
            ClientType *clientType = [[ClientType alloc]initWithName:@"client name" uri:@"client:name:uri"];
            
            ProjectType *projectType = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"project name" uri:@"project:type:uri"];
            
            
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                
                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Ticking
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:UnknownSourceOfPunch
                                                                             actionType:PunchActionTypePunchIn
                                                                          oefTypesArray:nil
                                                                           lastSyncTime:nil
                                                                                project:projectType
                                                                            auditHstory:nil
                                                                              breakType:nil
                                                                               location:nil
                                                                             violations:nil
                                                                              requestID:NULL
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:clientType
                                                                                address:@"an address"
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"address": @"an address",
                                               @"client_name": @"client name",
                                               @"client_uri": @"client:name:uri",
                                               @"project_name": @"project name",
                                               @"project_uri": @"project:type:uri",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
            
        });
        
        context(@"when the punch has client/task and project is null", ^{
            
            ClientType *clientType = [[ClientType alloc]initWithName:@"client name" uri:@"client:name:uri"];
            
            
            TaskType *taskType = [[TaskType alloc] initWithProjectUri:nil taskPeriod:nil name:@"task name" uri:@"task:type:uri"];
            
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                
                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Ticking
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:UnknownSourceOfPunch
                                                                             actionType:PunchActionTypePunchIn
                                                                          oefTypesArray:nil
                                                                           lastSyncTime:nil
                                                                                project:NULL
                                                                            auditHstory:nil
                                                                              breakType:nil
                                                                               location:nil
                                                                             violations:nil
                                                                              requestID:NULL
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:clientType
                                                                                address:@"an address"
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:taskType
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"address": @"an address",
                                               @"client_name": @"client name",
                                               @"client_uri": @"client:name:uri",
                                               @"task_name": @"task name",
                                               @"task_uri": @"task:type:uri",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
            
        });
        
        context(@"when the punch has project/task and client is null", ^{
            
            
            ProjectType *projectType = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"project name" uri:@"project:type:uri"];
            
            TaskType *taskType = [[TaskType alloc] initWithProjectUri:nil taskPeriod:nil name:@"task name" uri:@"task:type:uri"];
            
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                
                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Ticking
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:UnknownSourceOfPunch
                                                                             actionType:PunchActionTypePunchIn
                                                                          oefTypesArray:nil
                                                                           lastSyncTime:NULL
                                                                                project:projectType
                                                                            auditHstory:nil
                                                                              breakType:nil
                                                                               location:nil
                                                                             violations:nil
                                                                              requestID:NULL
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:NULL
                                                                                address:@"an address"
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:taskType
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"address": @"an address",
                                               @"project_name": @"project name",
                                               @"project_uri": @"project:type:uri",
                                               @"task_name": @"task name",
                                               @"task_uri": @"task:type:uri",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
            
        });
        context(@"when the punch has project/task and client uri is nil", ^{
            
            ClientType *clientType = [[ClientType alloc]initWithName:@"client name" uri:nil];
            ProjectType *projectType = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"project name" uri:@"project:type:uri"];
            
            TaskType *taskType = [[TaskType alloc] initWithProjectUri:nil taskPeriod:nil name:@"task name" uri:@"task:type:uri"];
            
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                
                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Ticking
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:UnknownSourceOfPunch
                                                                             actionType:PunchActionTypePunchIn
                                                                          oefTypesArray:nil
                                                                           lastSyncTime:NULL
                                                                                project:projectType
                                                                            auditHstory:nil
                                                                              breakType:nil
                                                                               location:nil
                                                                             violations:nil
                                                                              requestID:NULL
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:clientType
                                                                                address:@"an address"
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:taskType
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"address": @"an address",
                                               @"project_name": @"project name",
                                               @"project_uri": @"project:type:uri",
                                               @"task_name": @"task name",
                                               @"task_uri": @"task:type:uri",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
            
        });
        context(@"when the punch has client/task and project uri is nil", ^{
            
            ClientType *clientType = [[ClientType alloc]initWithName:@"client name" uri:@"client:name:uri"];
            ProjectType *projectType = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"project name" uri:nil];
            
            TaskType *taskType = [[TaskType alloc] initWithProjectUri:nil taskPeriod:nil name:@"task name" uri:@"task:type:uri"];
            
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                
                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Ticking
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:UnknownSourceOfPunch
                                                                             actionType:PunchActionTypePunchIn
                                                                          oefTypesArray:nil
                                                                           lastSyncTime:NULL
                                                                                project:projectType
                                                                            auditHstory:nil
                                                                              breakType:nil
                                                                               location:nil
                                                                             violations:nil
                                                                              requestID:NULL
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:clientType
                                                                                address:@"an address"
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:taskType
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"address": @"an address",
                                               @"client_name": @"client name",
                                               @"client_uri": @"client:name:uri",
                                               @"task_name": @"task name",
                                               @"task_uri": @"task:type:uri",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
            
        });
        
        context(@"when the punch has project/task and task uri nil", ^{
            
            ClientType *clientType = [[ClientType alloc]initWithName:@"client name" uri:@"client:name:uri"];
            ProjectType *projectType = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"project name" uri:@"project:type:uri"];
            
            TaskType *taskType = [[TaskType alloc] initWithProjectUri:nil taskPeriod:nil name:@"task name" uri:nil];
            
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                
                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Ticking
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:UnknownSourceOfPunch
                                                                             actionType:PunchActionTypePunchIn
                                                                          oefTypesArray:nil
                                                                           lastSyncTime:NULL
                                                                                project:projectType
                                                                            auditHstory:nil
                                                                              breakType:nil
                                                                               location:nil
                                                                             violations:nil
                                                                              requestID:NULL
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:clientType
                                                                                address:@"an address"
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:taskType
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"address": @"an address",
                                               @"client_name": @"client name",
                                               @"client_uri": @"client:name:uri",
                                               @"project_name": @"project name",
                                               @"project_uri": @"project:type:uri",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
            
        });
        
        context(@"when the punch has activity", ^{
            
            
            Activity *activity = [[Activity alloc] initWithName:@"activity-name" uri:@"activity:type:uri"];
            
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                
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
                                                                              requestID:NULL
                                                                               activity:activity
                                                                               duration:nil
                                                                                 client:NULL
                                                                                address:@"an address"
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"address": @"an address",
                                               @"activity_name": @"activity-name",
                                               @"activity_uri": @"activity:type:uri",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
            
        });
        
        context(@"when the punch has nil value for activity uri", ^{
            
            
            Activity *activity = [[Activity alloc] initWithName:@"activity-name" uri:nil];
            
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                
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
                                                                              requestID:NULL
                                                                               activity:activity
                                                                               duration:nil
                                                                                 client:NULL
                                                                                address:@"an address"
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"address": @"an address",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
            
        });

        context(@"when the punch has next pair punch", ^{
            
            
            Activity *activity = [[Activity alloc] initWithName:@"activity-name" uri:nil];
            
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                
                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Ticking
                                                                        nextPunchStatus:Present
                                                                          sourceOfPunch:UnknownSourceOfPunch
                                                                             actionType:PunchActionTypePunchIn
                                                                          oefTypesArray:nil
                                                                           lastSyncTime:NULL
                                                                                project:NULL
                                                                            auditHstory:nil
                                                                              breakType:nil
                                                                               location:nil
                                                                             violations:nil
                                                                              requestID:NULL
                                                                               activity:activity
                                                                               duration:nil
                                                                                 client:NULL
                                                                                address:@"an address"
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"address": @"an address",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@0,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
            
        });
        
        context(@"when the punch has previous pair punch", ^{
            
            
            Activity *activity = [[Activity alloc] initWithName:@"activity-name" uri:nil];
            
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                
                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Present
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
                                                                              requestID:NULL
                                                                               activity:activity
                                                                               duration:nil
                                                                                 client:NULL
                                                                                address:@"an address"
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:NO
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"address": @"an address",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@0,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@0,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
            
        });
        
        context(@"when the punch has source of punch", ^{
            
            
            Activity *activity = [[Activity alloc] initWithName:@"activity-name" uri:nil];
            
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                
                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Present
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:Mobile
                                                                             actionType:PunchActionTypePunchIn
                                                                          oefTypesArray:nil
                                                                           lastSyncTime:NULL
                                                                                project:NULL
                                                                            auditHstory:nil
                                                                              breakType:nil
                                                                               location:nil
                                                                             violations:nil
                                                                              requestID:NULL
                                                                               activity:activity
                                                                               duration:nil
                                                                                 client:NULL
                                                                                address:@"an address"
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:NO
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"address": @"an address",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@0,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@0,
                                               @"sourceOfPunch":@2,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
            
        });

        context(@"when the punch has nonActionedValidationsCount", ^{
            
            
            Activity *activity = [[Activity alloc] initWithName:@"activity-name" uri:nil];
            
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                
                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:1
                                                                    previousPunchStatus:Present
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:Mobile
                                                                             actionType:PunchActionTypePunchIn
                                                                          oefTypesArray:nil
                                                                           lastSyncTime:NULL
                                                                                project:NULL
                                                                            auditHstory:nil
                                                                              breakType:nil
                                                                               location:nil
                                                                             violations:nil
                                                                              requestID:NULL
                                                                               activity:activity
                                                                               duration:nil
                                                                                 client:NULL
                                                                                address:@"an address"
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:NO
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"address": @"an address",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@0,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@0,
                                               @"sourceOfPunch":@2,
                                               @"nonActionedValidationsCount":@1,
                                               });
            });
            
        });
        
        context(@"when the punch has duration", ^{
            
            
            Activity *activity = [[Activity alloc] initWithName:@"activity-name" uri:nil];
            
            NSDateComponents *components = [[NSDateComponents alloc] init];
            [components setHour:0];
            [components setMinute:0];
            [components setSecond:12];
            [components setDay:1];
            [components setMonth:1];
            [components setYear:1970];
            
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                
                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:1
                                                                    previousPunchStatus:Present
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:Mobile
                                                                             actionType:PunchActionTypePunchIn
                                                                          oefTypesArray:nil
                                                                           lastSyncTime:NULL
                                                                                project:NULL
                                                                            auditHstory:nil
                                                                              breakType:nil
                                                                               location:nil
                                                                             violations:nil
                                                                              requestID:NULL
                                                                               activity:activity
                                                                               duration:components
                                                                                 client:NULL
                                                                                address:@"an address"
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:NO
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                
                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"address": @"an address",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@0,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@0,
                                               @"sourceOfPunch":@2,
                                               @"nonActionedValidationsCount":@1,
                                               @"duration":[NSDate dateWithTimeIntervalSince1970:12],
                                               });
            });
            
        });
        
        context(@"when the punch has previousPunchActionType", ^{
            
            
            Activity *activity = [[Activity alloc] initWithName:@"activity-name" uri:nil];
            
            NSDateComponents *components = [[NSDateComponents alloc] init];
            [components setHour:0];
            [components setMinute:0];
            [components setSecond:12];
            [components setDay:1];
            [components setMonth:1];
            [components setYear:1970];
            
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                
                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:1
                                                                    previousPunchStatus:Present
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:Mobile
                                                                             actionType:PunchActionTypePunchIn
                                                                          oefTypesArray:nil
                                                                           lastSyncTime:NULL
                                                                                project:NULL
                                                                            auditHstory:nil
                                                                              breakType:nil
                                                                               location:nil
                                                                             violations:nil
                                                                              requestID:NULL
                                                                               activity:activity
                                                                               duration:components
                                                                                 client:NULL
                                                                                address:@"an address"
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:NO
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                                                previousPunchActionType:PunchActionTypePunchIn];
                
                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"address": @"an address",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@0,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@0,
                                               @"sourceOfPunch":@2,
                                               @"nonActionedValidationsCount":@1,
                                               @"duration":[NSDate dateWithTimeIntervalSince1970:12],
                                               @"previousPunchActionType":PUNCH_ACTION_URI_IN,
                                               });
            });
            
        });

    });

    describe(@"with OEF -serializePunchForStorage:", ^{

        context(@"when the punch action type is punch in", ^{
            __block NSDictionary *punchDictionary;
            __block NSArray *oefTypesArr;
            beforeEach(^{
                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                oefTypesArr = @[oefType1, oefType2];
                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Ticking
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:UnknownSourceOfPunch
                                                                             actionType:PunchActionTypePunchIn
                                                                          oefTypesArray:oefTypesArr
                                                                           lastSyncTime:NULL
                                                                                project:NULL
                                                                            auditHstory:nil
                                                                              breakType:nil
                                                                               location:nil
                                                                             violations:nil
                                                                              requestID:NULL
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:NULL
                                                                                address:nil
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
        });

        context(@"when the punch action type is punch out", ^{
            __block NSDictionary *punchDictionary;
             __block NSArray *oefTypesArr;
            beforeEach(^{
                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                oefTypesArr = @[oefType1, oefType2];
                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                                              requestID:NULL
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:NULL
                                                                                address:nil
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_OUT,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
        });

        context(@"when the punch action type is transfer", ^{
            __block NSDictionary *punchDictionary;
             __block NSArray *oefTypesArr;
            beforeEach(^{
                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                oefTypesArr = @[oefType1, oefType2];
                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
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
                                                                              requestID:NULL
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:NULL
                                                                                address:nil
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_TRANSFER,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
        });

        context(@"when the punch action type is start break", ^{
            __block NSDictionary *punchDictionary;
             __block NSArray *oefTypesArr;
            beforeEach(^{
                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                oefTypesArr = @[oefType1, oefType2];
                BreakType *breakType = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal:break:uri"];
                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Ticking
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:UnknownSourceOfPunch
                                                                             actionType:PunchActionTypeStartBreak
                                                                          oefTypesArray:nil
                                                                           lastSyncTime:NULL
                                                                                project:NULL
                                                                            auditHstory:nil
                                                                              breakType:breakType
                                                                               location:nil
                                                                             violations:nil
                                                                              requestID:NULL
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:NULL
                                                                                address:nil
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_BREAK,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"break_type_name": @"Meal Break",
                                               @"break_type_uri": @"meal:break:uri",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
        });

        context(@"when the punch action type is unknown", ^{
            __block NSDictionary *punchDictionary;
             __block NSArray *oefTypesArr;
            beforeEach(^{
                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                oefTypesArr = @[oefType1, oefType2];
                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Ticking
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:UnknownSourceOfPunch
                                                                             actionType:PunchActionTypeUnknown
                                                                          oefTypesArray:nil
                                                                           lastSyncTime:NULL
                                                                                project:NULL
                                                                            auditHstory:nil
                                                                              breakType:nil
                                                                               location:nil
                                                                             violations:nil
                                                                              requestID:NULL
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:NULL
                                                                                address:nil
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": @"PunchActionTypeUnknown",
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
        });

        context(@"when the punch has an image url", ^{
            __block NSDictionary *punchDictionary;
             __block NSArray *oefTypesArr;
            beforeEach(^{
                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                oefTypesArr = @[oefType1, oefType2];
                NSURL *imageURL = [NSURL URLWithString:@"http://www.example.com/image.jpg"];
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
                                                                              requestID:NULL
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:NULL
                                                                                address:nil
                                                                                userURI:@"user:uri"
                                                                               imageURL:imageURL
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"image_url": @"http://www.example.com/image.jpg",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
        });

        context(@"when the punch has a location", ^{
            __block NSDictionary *punchDictionary;
             __block NSArray *oefTypesArr;
            beforeEach(^{
                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                oefTypesArr = @[oefType1, oefType2];
                CLLocationDegrees latitude = 80.80;
                CLLocationDegrees longitude = 120.120;
                CLLocationAccuracy horizontalAccuracy = 123.123;
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:-1 horizontalAccuracy:horizontalAccuracy verticalAccuracy:-1 timestamp:[NSDate date]];
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
                                                                               location:location
                                                                             violations:nil
                                                                              requestID:NULL
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:NULL
                                                                                address:nil
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"location_latitude": @(80.80),
                                               @"location_longitude": @(120.120),
                                               @"location_horizontal_accuracy": @(123.123),
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
        });

        context(@"when the punch has an address", ^{
            __block NSDictionary *punchDictionary;
             __block NSArray *oefTypesArr;
            beforeEach(^{
                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                oefTypesArr = @[oefType1, oefType2];
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
                                                                              requestID:NULL
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:NULL
                                                                                address:@"an address"
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"address": @"an address",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });
        });

        context(@"when the punch client/project/task is not null", ^{

             NSArray *oefTypesArr;

            OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

            oefTypesArr = @[oefType1, oefType2];

            ClientType *clientType = [[ClientType alloc]initWithName:@"client name" uri:@"client:name:uri"];

            ProjectType *projectType = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO
                                                                            isTimeAllocationAllowed:NO
                                                                                      projectPeriod:nil
                                                                                         clientType:nil
                                                                                               name:@"project name"
                                                                                                uri:@"project:type:uri"];

            TaskType *taskType = [[TaskType alloc] initWithProjectUri:nil
                                                           taskPeriod:nil
                                                                 name:@"task name"
                                                                  uri:@"task:type:uri"];

            __block NSDictionary *punchDictionary;
            beforeEach(^{

                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Ticking
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:UnknownSourceOfPunch
                                                                             actionType:PunchActionTypePunchIn
                                                                          oefTypesArray:nil
                                                                           lastSyncTime:NULL
                                                                                project:projectType
                                                                            auditHstory:nil
                                                                              breakType:nil
                                                                               location:nil
                                                                             violations:nil
                                                                              requestID:NULL
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:clientType
                                                                                address:@"an address"
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:taskType
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"address": @"an address",
                                               @"client_name": @"client name",
                                               @"client_uri": @"client:name:uri",
                                               @"project_name": @"project name",
                                               @"project_uri": @"project:type:uri",
                                               @"task_name": @"task name",
                                               @"task_uri": @"task:type:uri",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });

        });


        context(@"when the punch has client/project and task is null", ^{

             NSArray *oefTypesArr;

            OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

            oefTypesArr = @[oefType1, oefType2];

            ClientType *clientType = [[ClientType alloc]initWithName:@"client name" uri:@"client:name:uri"];

            ProjectType *projectType = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"project name" uri:@"project:type:uri"];


            __block NSDictionary *punchDictionary;
            beforeEach(^{

                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Ticking
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:UnknownSourceOfPunch
                                                                             actionType:PunchActionTypePunchIn
                                                                          oefTypesArray:nil
                                                                           lastSyncTime:NULL
                                                                                project:projectType
                                                                            auditHstory:nil
                                                                              breakType:nil
                                                                               location:nil
                                                                             violations:nil
                                                                              requestID:NULL
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:clientType
                                                                                address:@"an address"
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"address": @"an address",
                                               @"client_name": @"client name",
                                               @"client_uri": @"client:name:uri",
                                               @"project_name": @"project name",
                                               @"project_uri": @"project:type:uri",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });

        });

        context(@"when the punch has client/task and project is null", ^{

             NSArray *oefTypesArr;

            OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

            oefTypesArr = @[oefType1, oefType2];

            ClientType *clientType = [[ClientType alloc]initWithName:@"client name" uri:@"client:name:uri"];


            TaskType *taskType = [[TaskType alloc] initWithProjectUri:nil taskPeriod:nil name:@"task name" uri:@"task:type:uri"];

            __block NSDictionary *punchDictionary;
            beforeEach(^{

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
                                                                              requestID:NULL
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:clientType
                                                                                address:@"an address"
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:taskType
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"address": @"an address",
                                               @"client_name": @"client name",
                                               @"client_uri": @"client:name:uri",
                                               @"task_name": @"task name",
                                               @"task_uri": @"task:type:uri",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });

        });

        context(@"when the punch has project/task and client is null", ^{

            NSArray *oefTypesArr;

            OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

            oefTypesArr = @[oefType1, oefType2];

            ProjectType *projectType = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"project name" uri:@"project:type:uri"];

            TaskType *taskType = [[TaskType alloc] initWithProjectUri:nil taskPeriod:nil name:@"task name" uri:@"task:type:uri"];

            __block NSDictionary *punchDictionary;
            beforeEach(^{

                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Ticking
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:UnknownSourceOfPunch
                                                                             actionType:PunchActionTypePunchIn
                                                                          oefTypesArray:nil
                                                                           lastSyncTime:NULL
                                                                                project:projectType
                                                                            auditHstory:nil
                                                                              breakType:nil
                                                                               location:nil
                                                                             violations:nil
                                                                              requestID:NULL
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:NULL
                                                                                address:@"an address"
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:taskType
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"address": @"an address",
                                               @"project_name": @"project name",
                                               @"project_uri": @"project:type:uri",
                                               @"task_name": @"task name",
                                               @"task_uri": @"task:type:uri",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });

        });
        context(@"when the punch has project/task and client uri is nil", ^{

             __block NSArray *oefTypesArr;

            OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

            oefTypesArr = @[oefType1, oefType2];

            ClientType *clientType = [[ClientType alloc]initWithName:@"client name" uri:nil];
            ProjectType *projectType = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"project name" uri:@"project:type:uri"];

            TaskType *taskType = [[TaskType alloc] initWithProjectUri:nil taskPeriod:nil name:@"task name" uri:@"task:type:uri"];

            __block NSDictionary *punchDictionary;
            beforeEach(^{

                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Ticking
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:UnknownSourceOfPunch
                                                                             actionType:PunchActionTypePunchIn
                                                                          oefTypesArray:nil
                                                                           lastSyncTime:NULL
                                                                                project:projectType
                                                                            auditHstory:nil
                                                                              breakType:nil
                                                                               location:nil
                                                                             violations:nil
                                                                              requestID:NULL
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:clientType
                                                                                address:@"an address"
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:taskType
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"address": @"an address",
                                               @"project_name": @"project name",
                                               @"project_uri": @"project:type:uri",
                                               @"task_name": @"task name",
                                               @"task_uri": @"task:type:uri",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });

        });
        context(@"when the punch has client/task and project uri is nil", ^{

             __block NSArray *oefTypesArr;

            OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

            oefTypesArr = @[oefType1, oefType2];

            ClientType *clientType = [[ClientType alloc]initWithName:@"client name" uri:@"client:name:uri"];
            ProjectType *projectType = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"project name" uri:nil];

            TaskType *taskType = [[TaskType alloc] initWithProjectUri:nil taskPeriod:nil name:@"task name" uri:@"task:type:uri"];

            __block NSDictionary *punchDictionary;
            beforeEach(^{

                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Ticking
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:UnknownSourceOfPunch
                                                                             actionType:PunchActionTypePunchIn
                                                                          oefTypesArray:nil
                                                                           lastSyncTime:NULL
                                                                                project:projectType
                                                                            auditHstory:nil
                                                                              breakType:nil
                                                                               location:nil
                                                                             violations:nil
                                                                              requestID:NULL
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:clientType
                                                                                address:@"an address"
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:taskType
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"address": @"an address",
                                               @"client_name": @"client name",
                                               @"client_uri": @"client:name:uri",
                                               @"task_name": @"task name",
                                               @"task_uri": @"task:type:uri",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });

        });

        context(@"when the punch has project/task and task uri nil", ^{

             __block NSArray *oefTypesArr;

            OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

            oefTypesArr = @[oefType1, oefType2];

            ClientType *clientType = [[ClientType alloc]initWithName:@"client name" uri:@"client:name:uri"];
            ProjectType *projectType = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"project name" uri:@"project:type:uri"];

            TaskType *taskType = [[TaskType alloc] initWithProjectUri:nil taskPeriod:nil name:@"task name" uri:nil];

            __block NSDictionary *punchDictionary;
            beforeEach(^{

                RemotePunch *remotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Ticking
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:UnknownSourceOfPunch
                                                                             actionType:PunchActionTypePunchIn
                                                                          oefTypesArray:nil
                                                                           lastSyncTime:NULL
                                                                                project:projectType
                                                                            auditHstory:nil
                                                                              breakType:nil
                                                                               location:nil
                                                                             violations:nil
                                                                              requestID:NULL
                                                                               activity:NULL
                                                                               duration:nil
                                                                                 client:clientType
                                                                                address:@"an address"
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:taskType
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"address": @"an address",
                                               @"client_name": @"client name",
                                               @"client_uri": @"client:name:uri",
                                               @"project_name": @"project name",
                                               @"project_uri": @"project:type:uri",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });

        });

        context(@"when the punch has activity", ^{

             __block NSArray *oefTypesArr;

            OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

            oefTypesArr = @[oefType1, oefType2];

            Activity *activity = [[Activity alloc] initWithName:@"activity-name" uri:@"activity:type:uri"];

            __block NSDictionary *punchDictionary;
            beforeEach(^{

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
                                                                              requestID:NULL
                                                                               activity:activity
                                                                               duration:nil
                                                                                 client:NULL
                                                                                address:@"an address"
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"address": @"an address",
                                               @"activity_name": @"activity-name",
                                               @"activity_uri": @"activity:type:uri",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });

        });

        context(@"when the punch has nil value for activity uri", ^{

             __block NSArray *oefTypesArr;

            OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
            OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

            oefTypesArr = @[oefType1, oefType2];
            Activity *activity = [[Activity alloc] initWithName:@"activity-name" uri:nil];

            __block NSDictionary *punchDictionary;
            beforeEach(^{

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
                                                                              requestID:@"ABCD1234"
                                                                               activity:activity
                                                                               duration:nil
                                                                                 client:NULL
                                                                                address:@"an address"
                                                                                userURI:@"user:uri"
                                                                               imageURL:nil
                                                                                   date:[NSDate dateWithTimeIntervalSince1970:12]
                                                                                   task:NULL
                                                                                    uri:@"remote:punch:uri"
                                                                   isTimeEntryAvailable:YES
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                punchDictionary = [subject serializePunchForStorage:remotePunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should equal(@{@"action_type": PUNCH_ACTION_URI_IN,
                                               @"user_uri": @"user:uri",
                                               @"date": [NSDate dateWithTimeIntervalSince1970:12],
                                               @"uri": @"remote:punch:uri",
                                               @"address": @"an address",
                                               @"punchSyncStatus": @(RemotePunchStatus),
                                               @"lastSyncTime": [NSNull null],
                                               @"request_id": @"ABCD1234",
                                               @"sync_with_server": @0,
                                               @"is_time_entry_available":@1,
                                               @"nextPunchPairStatus":@2,
                                               @"previousPunchPairStatus":@2,
                                               @"sourceOfPunch":@3,
                                               @"nonActionedValidationsCount":@0,
                                               });
            });

        });

    });
    
});


SPEC_END
