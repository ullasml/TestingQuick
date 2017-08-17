#import <Cedar/Cedar.h>
#import "LocalSQLPunchDeserializer.h"
#import "Constants.h"
#import "Punch.h"
#import "RemotePunch.h"
#import "LocalPunch.h"
#import "BreakType.h"
#import "OfflineLocalPunch.h"
#import "ClientType.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "Activity.h"
#import "Enum.h"
#import "PunchOEFStorage.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "ViolationsStorage.h"
#import "Violation.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(LocalSQLPunchDeserializerSpec)

describe(@"LocalSQLPunchDeserializer", ^{
    __block LocalSQLPunchDeserializer *subject;
    __block PunchOEFStorage *punchOEFStorage;
    __block ViolationsStorage *violationsStorage;
    __block id <BSInjector,BSBinder> injector;
    beforeEach(^{
        injector = [InjectorProvider injector];
        punchOEFStorage = nice_fake_for([PunchOEFStorage class]);
        
        violationsStorage = nice_fake_for([ViolationsStorage class]);
        [injector bind:[ViolationsStorage class] toInstance:violationsStorage];
        
        subject = [injector getInstance:[LocalSQLPunchDeserializer class]];
    });

    describe(@"-deserializeSingleSQLPunch:punchOEFStorage:", ^{

        context(@"when there is no punch in the database", ^{
            __block id<Punch> punch;
            beforeEach(^{
                punch = [subject deserializeSingleSQLPunch:nil punchOEFStorage:punchOEFStorage];
            });

            it(@"should correctly deserialize a nil punch", ^{
                punch should be_nil;
            });
        });

        context(@"when there is a punch uri (aka RemotePunch)", ^{
            __block id<Punch> punch;

            context(@"when only mandatory fields for a local punch are filled in", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": @"punch_uri:uri",
                                                    @"punchSyncStatus": @0 ,
                                                    @"lastSyncTime": @"1970-01-01 00:02:03",
                                                    @"request_id": @"ABCD1234",
                                                    @"sync_with_server": @1};
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });

                it(@"should correctly deserialize a RemotePunch", ^{
                    RemotePunch *remotePunch = punch;
                    remotePunch should be_instance_of([RemotePunch class]);
                    [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch actionType] should equal(PunchActionTypePunchIn);
                    [remotePunch userURI] should equal(@"user:uri");
                    [remotePunch uri] should equal(@"punch_uri:uri");
                    [remotePunch punchSyncStatus] should equal(UnsubmittedSyncStatus);
                    [remotePunch lastSyncTime] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch requestID] should equal(@"ABCD1234");
                    [remotePunch syncedWithServer] should be_truthy;
                    [remotePunch previousPunchActionType] should equal(PunchActionTypeUnknown);
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(@"ABCD1234");
                });
            });

            context(@"when there is a break type", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": @"punch_uri:uri",
                                                    @"break_type_name": @"Meal Break",
                                                    @"break_type_uri": @"meal:break:uri",
                                                    @"punchSyncStatus": @0 ,
                                                    @"lastSyncTime": @"1970-01-01 00:02:03",
                                                    @"request_id": @"ABCD1234",
                                                    @"sync_with_server": @1};
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });

                it(@"should correctly deserialize a RemotePunch", ^{
                    BreakType *breakType = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal:break:uri"];
                    RemotePunch *remotePunch = punch;
                    remotePunch should be_instance_of([RemotePunch class]);
                    [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch actionType] should equal(PunchActionTypePunchIn);
                    [remotePunch userURI] should equal(@"user:uri");
                    [remotePunch uri] should equal(@"punch_uri:uri");
                    [remotePunch breakType] should equal(breakType);
                    [remotePunch punchSyncStatus] should equal(UnsubmittedSyncStatus);
                    [remotePunch lastSyncTime] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch requestID] should equal(@"ABCD1234");
                    [remotePunch syncedWithServer] should be_truthy;
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(@"ABCD1234");
                });
            });

            context(@"when there is a location", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": @"punch_uri:uri",
                                                    @"location_latitude":@(70.80),
                                                    @"location_longitude":@(80.70),
                                                    @"location_horizontal_accuracy":@(123),
                                                    @"punchSyncStatus": @0 ,
                                                    @"lastSyncTime": @"1970-01-01 00:02:03",
                                                    @"request_id": @"ABCD1234",
                                                    @"sync_with_server": @1};
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });

                it(@"should correctly deserialize a RemotePunch", ^{
                    RemotePunch *remotePunch = punch;
                    remotePunch should be_instance_of([RemotePunch class]);
                    [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch actionType] should equal(PunchActionTypePunchIn);
                    [remotePunch userURI] should equal(@"user:uri");
                    [remotePunch uri] should equal(@"punch_uri:uri");
                    [[remotePunch location] coordinate].latitude should equal(70.80);
                    [[remotePunch location] coordinate].longitude should equal(80.70);
                    [[remotePunch location] horizontalAccuracy] should equal(123);
                    [remotePunch punchSyncStatus] should equal(UnsubmittedSyncStatus);
                    [remotePunch lastSyncTime] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch requestID] should equal(@"ABCD1234");
                    [remotePunch syncedWithServer] should be_truthy;
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(@"ABCD1234");
                });
            });

            context(@"when there is an address", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": @"punch_uri:uri",
                                                    @"address": @"an example address",
                                                    @"punchSyncStatus": @0 ,
                                                    @"lastSyncTime": @"1970-01-01 00:02:03",
                                                    @"request_id": @"ABCD1234"};
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });

                it(@"should correctly deserialize a RemotePunch", ^{
                    RemotePunch *remotePunch = punch;
                    remotePunch should be_instance_of([RemotePunch class]);
                    [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch actionType] should equal(PunchActionTypePunchIn);
                    [remotePunch userURI] should equal(@"user:uri");
                    [remotePunch uri] should equal(@"punch_uri:uri");
                    [remotePunch address] should equal(@"an example address");
                    [remotePunch punchSyncStatus] should equal(UnsubmittedSyncStatus);
                    [remotePunch lastSyncTime] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch requestID] should equal(@"ABCD1234");
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(@"ABCD1234");
                });
            });

            context(@"when there is an image url", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": @"punch_uri:uri",
                                                    @"image_url": @"http://example.com/image.png",
                                                    @"punchSyncStatus": @0 ,
                                                    @"lastSyncTime": @"1970-01-01 00:02:03",
                                                    @"sync_with_server": @1};
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });

                it(@"should correctly deserialize a RemotePunch", ^{
                    RemotePunch *remotePunch = punch;
                    remotePunch should be_instance_of([RemotePunch class]);
                    [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch actionType] should equal(PunchActionTypePunchIn);
                    [remotePunch userURI] should equal(@"user:uri");
                    [remotePunch uri] should equal(@"punch_uri:uri");
                    [[remotePunch imageURL] absoluteString] should equal(@"http://example.com/image.png");
                    [remotePunch punchSyncStatus] should equal(UnsubmittedSyncStatus);
                    [remotePunch lastSyncTime] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch syncedWithServer] should be_truthy;
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });

            context(@"when there null optional values", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": @"punch_uri:uri",
                                                    @"image_url": [NSNull null],
                                                    @"break_type_name": [NSNull null],
                                                    @"break_type_uri": [NSNull null],
                                                    @"location_latitude":[NSNull null],
                                                    @"location_longitude":[NSNull null],
                                                    @"location_horizontal_accuracy":[NSNull null],
                                                    @"address": [NSNull null],
                                                    @"punchSyncStatus": @0 ,
                                                    @"lastSyncTime": @"1970-01-01 00:02:03",
                                                    @"sync_with_server": @1};

                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });

                it(@"should correctly deserialize a RemotePunch", ^{
                    RemotePunch *remotePunch = punch;
                    remotePunch should be_instance_of([RemotePunch class]);
                    [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch actionType] should equal(PunchActionTypePunchIn);
                    [remotePunch userURI] should equal(@"user:uri");
                    [remotePunch uri] should equal(@"punch_uri:uri");
                    [remotePunch imageURL] should be_nil;
                    [remotePunch breakType] should be_nil;
                    [remotePunch location] should be_nil;
                    [remotePunch address] should be_nil;
                    [remotePunch punchSyncStatus] should equal(UnsubmittedSyncStatus);
                    [remotePunch lastSyncTime] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch syncedWithServer] should be_truthy;
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });
            
            context(@"when there is a client type", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": @"punch_uri:uri",
                                                    @"client_name": @"client-name",
                                                    @"client_uri": @"client-uri",
                                                    @"sync_with_server": @1
                                                    };
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });
                
                it(@"should correctly deserialize a RemotePunch", ^{
                    ClientType *clientType = [[ClientType alloc] initWithName:@"client-name" uri:@"client-uri"];
                    RemotePunch *remotePunch = punch;
                    remotePunch should be_instance_of([RemotePunch class]);
                    [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch actionType] should equal(PunchActionTypePunchIn);
                    [remotePunch userURI] should equal(@"user:uri");
                    [remotePunch uri] should equal(@"punch_uri:uri");
                    [remotePunch client] should equal(clientType);
                    [remotePunch syncedWithServer] should be_truthy;
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });
            
            context(@"when there is a project type", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": @"punch_uri:uri",
                                                    @"project_name": @"project-name",
                                                    @"project_uri": @"project-uri",
                                                    @"sync_with_server": @1
                                                    };
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });
                
                it(@"should correctly deserialize a RemotePunch", ^{
                    ProjectType *projectType = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO
                                                                                    isTimeAllocationAllowed:NO
                                                                                              projectPeriod:nil
                                                                                                 clientType:nil
                                                                                                       name:@"project-name"
                                                                                                        uri:@"project-uri"];
                    RemotePunch *remotePunch = punch;
                    remotePunch should be_instance_of([RemotePunch class]);
                    [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch actionType] should equal(PunchActionTypePunchIn);
                    [remotePunch userURI] should equal(@"user:uri");
                    [remotePunch uri] should equal(@"punch_uri:uri");
                    [remotePunch project] should equal(projectType);
                    [remotePunch syncedWithServer] should be_truthy;
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });
            
            context(@"when there is a task type", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": @"punch_uri:uri",
                                                    @"task_name": @"task-name",
                                                    @"task_uri": @"task-uri",
                                                    @"sync_with_server": @1
                                                    };
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });
                
                it(@"should correctly deserialize a RemotePunch", ^{
                    TaskType *taskType = [[TaskType alloc] initWithProjectUri:nil
                                                                   taskPeriod:nil
                                                                         name:@"task-name"
                                                                          uri:@"task-uri"];
                    RemotePunch *remotePunch = punch;
                    remotePunch should be_instance_of([RemotePunch class]);
                    [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch actionType] should equal(PunchActionTypePunchIn);
                    [remotePunch userURI] should equal(@"user:uri");
                    [remotePunch uri] should equal(@"punch_uri:uri");
                    [remotePunch task] should equal(taskType);
                    [remotePunch syncedWithServer] should be_truthy;
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });
            
            context(@"when there is a activity type", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": @"punch_uri:uri",
                                                    @"activity_name": @"activity-name",
                                                    @"activity_uri": @"activity-uri",
                                                    @"sync_with_server": @1
                                                    };
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });
                
                it(@"should correctly deserialize a RemotePunch", ^{
                    Activity *activityType = [[Activity alloc]initWithName:@"activity-name" uri:@"activity-uri"];
                    RemotePunch *remotePunch = punch;
                    remotePunch should be_instance_of([RemotePunch class]);
                    [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch actionType] should equal(PunchActionTypePunchIn);
                    [remotePunch userURI] should equal(@"user:uri");
                    [remotePunch uri] should equal(@"punch_uri:uri");
                    [remotePunch activity] should equal(activityType);
                    [remotePunch syncedWithServer] should be_truthy;
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });
            
            context(@"when there is a sourceOfPunch", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": @"punch_uri:uri",
                                                    @"activity_name": @"activity-name",
                                                    @"activity_uri": @"activity-uri",
                                                    @"sync_with_server": @1,
                                                    @"sourceOfPunch": @1,
                                                    };
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });
                
                it(@"should correctly deserialize a RemotePunch", ^{
                    Activity *activityType = [[Activity alloc]initWithName:@"activity-name" uri:@"activity-uri"];
                    RemotePunch *remotePunch = punch;
                    remotePunch should be_instance_of([RemotePunch class]);
                    [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch actionType] should equal(PunchActionTypePunchIn);
                    [remotePunch userURI] should equal(@"user:uri");
                    [remotePunch uri] should equal(@"punch_uri:uri");
                    [remotePunch activity] should equal(activityType);
                    [remotePunch syncedWithServer] should be_truthy;
                    [remotePunch sourceOfPunch] should equal(CloudClock);
                });
                
                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });
            
            context(@"when there is a previousPunchPairStatus", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": @"punch_uri:uri",
                                                    @"activity_name": @"activity-name",
                                                    @"activity_uri": @"activity-uri",
                                                    @"sync_with_server": @1,
                                                    @"previousPunchPairStatus": @1,
                                                    };
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });
                
                it(@"should correctly deserialize a RemotePunch", ^{
                    Activity *activityType = [[Activity alloc]initWithName:@"activity-name" uri:@"activity-uri"];
                    RemotePunch *remotePunch = punch;
                    remotePunch should be_instance_of([RemotePunch class]);
                    [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch actionType] should equal(PunchActionTypePunchIn);
                    [remotePunch userURI] should equal(@"user:uri");
                    [remotePunch uri] should equal(@"punch_uri:uri");
                    [remotePunch activity] should equal(activityType);
                    [remotePunch syncedWithServer] should be_truthy;
                    [remotePunch previousPunchPairStatus] should equal(Missing);
                });
                
                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });

            context(@"when there is a nextPunchPairStatus", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": @"punch_uri:uri",
                                                    @"activity_name": @"activity-name",
                                                    @"activity_uri": @"activity-uri",
                                                    @"sync_with_server": @1,
                                                    @"nextPunchPairStatus": @1,
                                                    };
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });
                
                it(@"should correctly deserialize a RemotePunch", ^{
                    Activity *activityType = [[Activity alloc]initWithName:@"activity-name" uri:@"activity-uri"];
                    RemotePunch *remotePunch = punch;
                    remotePunch should be_instance_of([RemotePunch class]);
                    [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch actionType] should equal(PunchActionTypePunchIn);
                    [remotePunch userURI] should equal(@"user:uri");
                    [remotePunch uri] should equal(@"punch_uri:uri");
                    [remotePunch activity] should equal(activityType);
                    [remotePunch syncedWithServer] should be_truthy;
                    [remotePunch nextPunchPairStatus] should equal(Missing);
                });
                
                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });
            
            context(@"when there is a nonActionedValidationsCount", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": @"punch_uri:uri",
                                                    @"activity_name": @"activity-name",
                                                    @"activity_uri": @"activity-uri",
                                                    @"sync_with_server": @1,
                                                    @"nonActionedValidationsCount": @1,
                                                    };
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });
                
                it(@"should correctly deserialize a RemotePunch", ^{
                    Activity *activityType = [[Activity alloc]initWithName:@"activity-name" uri:@"activity-uri"];
                    RemotePunch *remotePunch = punch;
                    remotePunch should be_instance_of([RemotePunch class]);
                    [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch actionType] should equal(PunchActionTypePunchIn);
                    [remotePunch userURI] should equal(@"user:uri");
                    [remotePunch uri] should equal(@"punch_uri:uri");
                    [remotePunch activity] should equal(activityType);
                    [remotePunch syncedWithServer] should be_truthy;
                    [remotePunch nonActionedValidationsCount] should equal(1);
                });
                
                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });
            
            context(@"when there is a duration", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": @"punch_uri:uri",
                                                    @"activity_name": @"activity-name",
                                                    @"activity_uri": @"activity-uri",
                                                    @"sync_with_server": @1,
                                                    @"duration": @"1970-01-01 00:02:03",
                                                    };
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });
                
                it(@"should correctly deserialize a RemotePunch", ^{
                    NSDateComponents *components = [[NSDateComponents alloc] init];
                    [components setHour:0];
                    [components setMinute:2];
                    [components setSecond:3];
                    
                    Activity *activityType = [[Activity alloc]initWithName:@"activity-name" uri:@"activity-uri"];
                    RemotePunch *remotePunch = punch;
                    remotePunch should be_instance_of([RemotePunch class]);
                    [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch actionType] should equal(PunchActionTypePunchIn);
                    [remotePunch userURI] should equal(@"user:uri");
                    [remotePunch uri] should equal(@"punch_uri:uri");
                    [remotePunch activity] should equal(activityType);
                    [remotePunch syncedWithServer] should be_truthy;
                    [remotePunch duration] should equal(components);
                });
                
                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });
            
            context(@"when there is a violations", ^{
                __block Violation *violation;
                beforeEach(^{
                    violation = [[Violation alloc] initWithSeverity:ViolationSeverityWarning waiver:nil title:@"some-message"];
                    violationsStorage stub_method(@selector(getPunchViolations:)).and_return(@[violation]);
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": @"punch_uri:uri",
                                                    @"activity_name": @"activity-name",
                                                    @"activity_uri": @"activity-uri",
                                                    @"sync_with_server": @1,
                                                    @"duration": @"1970-01-01 00:02:03",
                                                    };
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });
                
                it(@"should correctly deserialize a RemotePunch", ^{
                    Activity *activityType = [[Activity alloc]initWithName:@"activity-name" uri:@"activity-uri"];
                    RemotePunch *remotePunch = punch;
                    remotePunch should be_instance_of([RemotePunch class]);
                    [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch actionType] should equal(PunchActionTypePunchIn);
                    [remotePunch userURI] should equal(@"user:uri");
                    [remotePunch uri] should equal(@"punch_uri:uri");
                    [remotePunch activity] should equal(activityType);
                    [remotePunch syncedWithServer] should be_truthy;
                    [remotePunch violations] should equal(@[violation]);
                });
                
                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });
            
            context(@"when there is a previousPunchActionType", ^{
                
                it(@"should correctly deserialize a RemotePunch", ^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": @"punch_uri:uri",
                                                    @"previousPunchActionType":PUNCH_ACTION_URI_IN
                                                    };
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                    RemotePunch *remotePunch = punch;
                    remotePunch should be_instance_of([RemotePunch class]);
                    [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch actionType] should equal(PunchActionTypePunchIn);
                    [remotePunch userURI] should equal(@"user:uri");
                    [remotePunch uri] should equal(@"punch_uri:uri");
                    [remotePunch previousPunchActionType] should equal(PunchActionTypePunchIn);

                });
                
                it(@"should correctly deserialize a RemotePunch", ^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_OUT,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": @"punch_uri:uri",
                                                    @"previousPunchActionType":PUNCH_ACTION_URI_OUT
                                                    };
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                    RemotePunch *remotePunch = punch;
                    remotePunch should be_instance_of([RemotePunch class]);
                    [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch actionType] should equal(PunchActionTypePunchOut);
                    [remotePunch userURI] should equal(@"user:uri");
                    [remotePunch uri] should equal(@"punch_uri:uri");
                    [remotePunch previousPunchActionType] should equal(PunchActionTypePunchOut);
                    
                });
                
                it(@"should correctly deserialize a RemotePunch", ^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_TRANSFER,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": @"punch_uri:uri",
                                                    @"previousPunchActionType":PUNCH_ACTION_URI_TRANSFER
                                                    };
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                    RemotePunch *remotePunch = punch;
                    remotePunch should be_instance_of([RemotePunch class]);
                    [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch actionType] should equal(PunchActionTypeTransfer);
                    [remotePunch userURI] should equal(@"user:uri");
                    [remotePunch uri] should equal(@"punch_uri:uri");
                    [remotePunch previousPunchActionType] should equal(PunchActionTypeTransfer);
                    
                });
                
                it(@"should correctly deserialize a RemotePunch", ^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_BREAK,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": @"punch_uri:uri",
                                                    @"previousPunchActionType":PUNCH_ACTION_URI_BREAK
                                                    };
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                    RemotePunch *remotePunch = punch;
                    remotePunch should be_instance_of([RemotePunch class]);
                    [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch actionType] should equal(PunchActionTypeStartBreak);
                    [remotePunch userURI] should equal(@"user:uri");
                    [remotePunch uri] should equal(@"punch_uri:uri");
                    [remotePunch previousPunchActionType] should equal(PunchActionTypeStartBreak);
                    
                });
            });
        });

        context(@"when there is no punch uri (aka LocalPunch)", ^{
            __block id<Punch> punch;

            context(@"when only mandatory fields for a local punch are filled in", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": [NSNull null]};
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });

                it(@"should correctly deserialize a LocalPunch", ^{
                    LocalPunch *localPunch = punch;
                    localPunch should be_instance_of([LocalPunch class]);
                    [localPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [localPunch actionType] should equal(PunchActionTypePunchIn);
                    [localPunch userURI] should equal(@"user:uri");
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });

            context(@"when there is an image", ^{
                beforeEach(^{
                    UIImage *image = [UIImage imageNamed:@"icon_timesheet_has_violations"];
                    NSData *imageData = UIImagePNGRepresentation(image);

                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": [NSNull null],
                                                    @"image": imageData};
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });

                it(@"should correctly deserialize a LocalPunch", ^{
                    LocalPunch *localPunch = punch;
                    localPunch should be_instance_of([LocalPunch class]);
                    [localPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [localPunch actionType] should equal(PunchActionTypePunchIn);
                    [localPunch userURI] should equal(@"user:uri");
                    [localPunch image] should_not be_nil;
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });

            context(@"when there is no image", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": [NSNull null],
                                                    @"image": [NSNull null]};
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });

                it(@"should correctly deserialize a LocalPunch", ^{
                    LocalPunch *localPunch = punch;
                    localPunch should be_instance_of([LocalPunch class]);
                    [localPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [localPunch actionType] should equal(PunchActionTypePunchIn);
                    [localPunch userURI] should equal(@"user:uri");

                    [localPunch image] should be_nil;
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });

            context(@"when the punch is marked 'offline'", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": [NSNull null],
                                                    @"offline": @YES};
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });

                it(@"should correctly deserialize a OfflineLocalPunch", ^{
                    OfflineLocalPunch *manualLocalPunch = punch;
                    manualLocalPunch should be_instance_of([OfflineLocalPunch class]);
                    [manualLocalPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [manualLocalPunch actionType] should equal(PunchActionTypePunchIn);
                    [manualLocalPunch userURI] should equal(@"user:uri");
                    [manualLocalPunch offline] should be_truthy;
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });

            context(@"when the punch is marked 'online'", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": [NSNull null],
                                                    @"offline": @NO};
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });

                it(@"should correctly deserialize a OfflineLocalPunch", ^{
                    LocalPunch *localPunch = punch;
                    localPunch should be_instance_of([LocalPunch class]);
                    [localPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [localPunch actionType] should equal(PunchActionTypePunchIn);
                    [localPunch userURI] should equal(@"user:uri");
                    [localPunch offline] should_not be_truthy;
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });
            
            context(@"when there is a client type", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": [NSNull null],
                                                    @"client_name": @"client-name",
                                                    @"client_uri": @"client-uri",
                                                    };
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });
                
                it(@"should correctly deserialize a RemotePunch", ^{
                    ClientType *clientType = [[ClientType alloc] initWithName:@"client-name" uri:@"client-uri"];
                    LocalPunch *localPunch = punch;
                    localPunch should be_instance_of([LocalPunch class]);
                    [localPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [localPunch actionType] should equal(PunchActionTypePunchIn);
                    [localPunch userURI] should equal(@"user:uri");
                    [localPunch client] should equal(clientType);
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });
            
            context(@"when there is a project type", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": [NSNull null],
                                                    @"project_name": @"project-name",
                                                    @"project_uri": @"project-uri",
                                                    };
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });
                
                it(@"should correctly deserialize a RemotePunch", ^{
                    ProjectType *projectType = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO
                                                                                    isTimeAllocationAllowed:NO
                                                                                              projectPeriod:nil
                                                                                                 clientType:nil
                                                                                                       name:@"project-name"
                                                                                                        uri:@"project-uri"];
                    LocalPunch *localPunch = punch;
                    localPunch should be_instance_of([LocalPunch class]);
                    [localPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [localPunch actionType] should equal(PunchActionTypePunchIn);
                    [localPunch userURI] should equal(@"user:uri");
                    [localPunch project] should equal(projectType);
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });
            
            context(@"when there is a task type", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": [NSNull null],
                                                    @"task_name": @"task-name",
                                                    @"task_uri": @"task-uri",
                                                    @"offline": @YES
                                                    };
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });
                
                it(@"should correctly deserialize a RemotePunch", ^{
                    TaskType *taskType = [[TaskType alloc] initWithProjectUri:nil
                                                                   taskPeriod:nil
                                                                         name:@"task-name"
                                                                          uri:@"task-uri"];
                    LocalPunch *localPunch = punch;
                    localPunch should be_instance_of([OfflineLocalPunch class]);
                    [localPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [localPunch actionType] should equal(PunchActionTypePunchIn);
                    [localPunch userURI] should equal(@"user:uri");
                    [localPunch task] should equal(taskType);
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });
            
            context(@"when there is a activity type", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": [NSNull null],
                                                    @"activity_name": @"activity-name",
                                                    @"activity_uri": @"activity-uri",
                                                    };
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });
                
                it(@"should correctly deserialize a LocalPunch", ^{
                    Activity *activityType = [[Activity alloc]initWithName:@"activity-name" uri:@"activity-uri"];
                    LocalPunch *localPunch = punch;
                    localPunch should be_instance_of([LocalPunch class]);
                    [localPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [localPunch actionType] should equal(PunchActionTypePunchIn);
                    [localPunch userURI] should equal(@"user:uri");
                    [localPunch activity] should equal(activityType);
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });


        });

        context(@"when punch status is nil", ^{
            __block id<Punch> punch;

            context(@"when only mandatory fields for a local punch are filled in", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": @"punch_uri:uri",
                                                    @"punchSyncStatus": [NSNull null] ,
                                                    @"lastSyncTime": @"1970-01-01 00:02:03",
                                                    @"sync_with_server": @1};
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });

                it(@"should correctly deserialize a RemotePunch", ^{
                    RemotePunch *remotePunch = punch;
                    remotePunch should be_instance_of([RemotePunch class]);
                    [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch actionType] should equal(PunchActionTypePunchIn);
                    [remotePunch userURI] should equal(@"user:uri");
                    [remotePunch uri] should equal(@"punch_uri:uri");
                    [remotePunch punchSyncStatus] should equal(UnsubmittedSyncStatus);
                    [remotePunch lastSyncTime] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch syncedWithServer] should be_truthy;
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });

            context(@"when there is a break type", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": @"punch_uri:uri",
                                                    @"break_type_name": @"Meal Break",
                                                    @"break_type_uri": @"meal:break:uri",
                                                    @"punchSyncStatus": [NSNull null] ,
                                                    @"lastSyncTime": @"1970-01-01 00:02:03",
                                                    @"sync_with_server": @1};
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });

                it(@"should correctly deserialize a RemotePunch", ^{
                    BreakType *breakType = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal:break:uri"];
                    RemotePunch *remotePunch = punch;
                    remotePunch should be_instance_of([RemotePunch class]);
                    [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch actionType] should equal(PunchActionTypePunchIn);
                    [remotePunch userURI] should equal(@"user:uri");
                    [remotePunch uri] should equal(@"punch_uri:uri");
                    [remotePunch breakType] should equal(breakType);
                    [remotePunch punchSyncStatus] should equal(UnsubmittedSyncStatus);
                    [remotePunch lastSyncTime] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch syncedWithServer] should be_truthy;
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });

            context(@"when there is a location", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": @"punch_uri:uri",
                                                    @"location_latitude":@(70.80),
                                                    @"location_longitude":@(80.70),
                                                    @"location_horizontal_accuracy":@(123),
                                                    @"punchSyncStatus": [NSNull null] ,
                                                    @"lastSyncTime": @"1970-01-01 00:02:03",
                                                    @"sync_with_server": @1};
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });

                it(@"should correctly deserialize a RemotePunch", ^{
                    RemotePunch *remotePunch = punch;
                    remotePunch should be_instance_of([RemotePunch class]);
                    [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch actionType] should equal(PunchActionTypePunchIn);
                    [remotePunch userURI] should equal(@"user:uri");
                    [remotePunch uri] should equal(@"punch_uri:uri");
                    [[remotePunch location] coordinate].latitude should equal(70.80);
                    [[remotePunch location] coordinate].longitude should equal(80.70);
                    [[remotePunch location] horizontalAccuracy] should equal(123);
                    [remotePunch punchSyncStatus] should equal(UnsubmittedSyncStatus);
                    [remotePunch lastSyncTime] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch syncedWithServer] should be_truthy;
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });

            context(@"when there is an address", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": @"punch_uri:uri",
                                                    @"address": @"an example address",
                                                    @"punchSyncStatus": [NSNull null] ,
                                                    @"lastSyncTime": @"1970-01-01 00:02:03",
                                                    @"sync_with_server": @1};
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });

                it(@"should correctly deserialize a RemotePunch", ^{
                    RemotePunch *remotePunch = punch;
                    remotePunch should be_instance_of([RemotePunch class]);
                    [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch actionType] should equal(PunchActionTypePunchIn);
                    [remotePunch userURI] should equal(@"user:uri");
                    [remotePunch uri] should equal(@"punch_uri:uri");
                    [remotePunch address] should equal(@"an example address");
                    [remotePunch punchSyncStatus] should equal(UnsubmittedSyncStatus);
                    [remotePunch lastSyncTime] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch syncedWithServer] should be_truthy;
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });

            context(@"when there is an image url", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": @"punch_uri:uri",
                                                    @"image_url": @"http://example.com/image.png",
                                                    @"punchSyncStatus": [NSNull null] ,
                                                    @"lastSyncTime": @"1970-01-01 00:02:03",
                                                    @"sync_with_server": @1};
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });

                it(@"should correctly deserialize a RemotePunch", ^{
                    RemotePunch *remotePunch = punch;
                    remotePunch should be_instance_of([RemotePunch class]);
                    [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch actionType] should equal(PunchActionTypePunchIn);
                    [remotePunch userURI] should equal(@"user:uri");
                    [remotePunch uri] should equal(@"punch_uri:uri");
                    [[remotePunch imageURL] absoluteString] should equal(@"http://example.com/image.png");
                    [remotePunch punchSyncStatus] should equal(UnsubmittedSyncStatus);
                    [remotePunch lastSyncTime] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch syncedWithServer] should be_truthy;
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });

            context(@"when there null optional values", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": @"punch_uri:uri",
                                                    @"image_url": [NSNull null],
                                                    @"break_type_name": [NSNull null],
                                                    @"break_type_uri": [NSNull null],
                                                    @"location_latitude":[NSNull null],
                                                    @"location_longitude":[NSNull null],
                                                    @"location_horizontal_accuracy":[NSNull null],
                                                    @"address": [NSNull null],
                                                    @"punchSyncStatus": [NSNull null] ,
                                                    @"lastSyncTime": @"1970-01-01 00:02:03"};

                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });

                it(@"should correctly deserialize a RemotePunch", ^{
                    RemotePunch *remotePunch = punch;
                    remotePunch should be_instance_of([RemotePunch class]);
                    [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch actionType] should equal(PunchActionTypePunchIn);
                    [remotePunch userURI] should equal(@"user:uri");
                    [remotePunch uri] should equal(@"punch_uri:uri");
                    [remotePunch imageURL] should be_nil;
                    [remotePunch breakType] should be_nil;
                    [remotePunch location] should be_nil;
                    [remotePunch address] should be_nil;
                    [remotePunch punchSyncStatus] should equal(UnsubmittedSyncStatus);
                    [remotePunch lastSyncTime] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });
            
            context(@"when there is a request ID", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": @"punch_uri:uri",
                                                    @"image_url": @"http://example.com/image.png",
                                                    @"punchSyncStatus": [NSNull null] ,
                                                    @"lastSyncTime": @"1970-01-01 00:02:03",
                                                    @"request_id":@"AQBCD123",
                                                    @"sync_with_server": @1};
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });
                
                it(@"should correctly deserialize a RemotePunch", ^{
                    RemotePunch *remotePunch = punch;
                    remotePunch should be_instance_of([RemotePunch class]);
                    [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch actionType] should equal(PunchActionTypePunchIn);
                    [remotePunch userURI] should equal(@"user:uri");
                    [remotePunch uri] should equal(@"punch_uri:uri");
                    [[remotePunch imageURL] absoluteString] should equal(@"http://example.com/image.png");
                    [remotePunch punchSyncStatus] should equal(UnsubmittedSyncStatus);
                    [remotePunch lastSyncTime] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [remotePunch requestID] should equal(@"AQBCD123");
                    [remotePunch syncedWithServer] should be_truthy;
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(@"AQBCD123");
                });
            });

        });

        context(@"when there is a <null> punch uri (aka LocalPunch)", ^{
            __block id<Punch> punch;

            context(@"when only mandatory fields for a local punch are filled in", ^{
                beforeEach(^{
                    id nullValue = nice_fake_for([NSNull class]);
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": nullValue};
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });

                it(@"should correctly deserialize a LocalPunch", ^{
                    LocalPunch *localPunch = punch;
                    localPunch should be_instance_of([LocalPunch class]);
                    [localPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [localPunch actionType] should equal(PunchActionTypePunchIn);
                    [localPunch userURI] should equal(@"user:uri");
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });

            context(@"when there is an image", ^{
                beforeEach(^{
                    UIImage *image = [UIImage imageNamed:@"icon_timesheet_has_violations"];
                    NSData *imageData = UIImagePNGRepresentation(image);

                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": [NSNull null],
                                                    @"image": imageData};
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });

                it(@"should correctly deserialize a LocalPunch", ^{
                    LocalPunch *localPunch = punch;
                    localPunch should be_instance_of([LocalPunch class]);
                    [localPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [localPunch actionType] should equal(PunchActionTypePunchIn);
                    [localPunch userURI] should equal(@"user:uri");
                    [localPunch image] should_not be_nil;
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });

            context(@"when there is no image", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": [NSNull null],
                                                    @"image": [NSNull null]};
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });

                it(@"should correctly deserialize a LocalPunch", ^{
                    LocalPunch *localPunch = punch;
                    localPunch should be_instance_of([LocalPunch class]);
                    [localPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [localPunch actionType] should equal(PunchActionTypePunchIn);
                    [localPunch userURI] should equal(@"user:uri");

                    [localPunch image] should be_nil;
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });

            context(@"when the punch is marked 'offline'", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": [NSNull null],
                                                    @"offline": @YES};
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });

                it(@"should correctly deserialize a OfflineLocalPunch", ^{
                    OfflineLocalPunch *manualLocalPunch = punch;
                    manualLocalPunch should be_instance_of([OfflineLocalPunch class]);
                    [manualLocalPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [manualLocalPunch actionType] should equal(PunchActionTypePunchIn);
                    [manualLocalPunch userURI] should equal(@"user:uri");
                    [manualLocalPunch offline] should be_truthy;
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });

            context(@"when the punch is marked 'online'", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": [NSNull null],
                                                    @"offline": @NO};
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });

                it(@"should correctly deserialize a OfflineLocalPunch", ^{
                    LocalPunch *localPunch = punch;
                    localPunch should be_instance_of([LocalPunch class]);
                    [localPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [localPunch actionType] should equal(PunchActionTypePunchIn);
                    [localPunch userURI] should equal(@"user:uri");
                    [localPunch offline] should_not be_truthy;
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });

            context(@"when there is a client type", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": [NSNull null],
                                                    @"client_name": @"client-name",
                                                    @"client_uri": @"client-uri",
                                                    };
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });

                it(@"should correctly deserialize a RemotePunch", ^{
                    ClientType *clientType = [[ClientType alloc] initWithName:@"client-name" uri:@"client-uri"];
                    LocalPunch *localPunch = punch;
                    localPunch should be_instance_of([LocalPunch class]);
                    [localPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [localPunch actionType] should equal(PunchActionTypePunchIn);
                    [localPunch userURI] should equal(@"user:uri");
                    [localPunch client] should equal(clientType);
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });

            context(@"when there is a project type", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": [NSNull null],
                                                    @"project_name": @"project-name",
                                                    @"project_uri": @"project-uri",
                                                    };
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });

                it(@"should correctly deserialize a RemotePunch", ^{
                    ProjectType *projectType = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO
                                                                                    isTimeAllocationAllowed:NO
                                                                                              projectPeriod:nil
                                                                                                 clientType:nil
                                                                                                       name:@"project-name"
                                                                                                        uri:@"project-uri"];
                    LocalPunch *localPunch = punch;
                    localPunch should be_instance_of([LocalPunch class]);
                    [localPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [localPunch actionType] should equal(PunchActionTypePunchIn);
                    [localPunch userURI] should equal(@"user:uri");
                    [localPunch project] should equal(projectType);
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });

            context(@"when there is a task type", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": [NSNull null],
                                                    @"task_name": @"task-name",
                                                    @"task_uri": @"task-uri",
                                                    @"offline": @YES
                                                    };
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });

                it(@"should correctly deserialize a RemotePunch", ^{
                    TaskType *taskType = [[TaskType alloc] initWithProjectUri:nil
                                                                   taskPeriod:nil
                                                                         name:@"task-name"
                                                                          uri:@"task-uri"];
                    LocalPunch *localPunch = punch;
                    localPunch should be_instance_of([OfflineLocalPunch class]);
                    [localPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [localPunch actionType] should equal(PunchActionTypePunchIn);
                    [localPunch userURI] should equal(@"user:uri");
                    [localPunch task] should equal(taskType);
                });

                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });

            context(@"when there is a activity type", ^{
                beforeEach(^{
                    NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                    @"action_type": PUNCH_ACTION_URI_IN,
                                                    @"user_uri": @"user:uri",
                                                    @"uri": [NSNull null],
                                                    @"activity_name": @"activity-name",
                                                    @"activity_uri": @"activity-uri",
                                                    };
                    punch = [subject deserializeSingleSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
                });

                it(@"should correctly deserialize a LocalPunch", ^{
                    Activity *activityType = [[Activity alloc]initWithName:@"activity-name" uri:@"activity-uri"];
                    LocalPunch *localPunch = punch;
                    localPunch should be_instance_of([LocalPunch class]);
                    [localPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                    [localPunch actionType] should equal(PunchActionTypePunchIn);
                    [localPunch userURI] should equal(@"user:uri");
                    [localPunch activity] should equal(activityType);
                });
                
                it(@"fetch all OEFs for a punch", ^{
                    punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
                });
            });
            
            
        });
        
    });

    describe(@"deserializeLocalSQLPunches:punchOEFStorage:", ^{

        __block NSArray *expectedPunches;
        beforeEach(^{
            NSDictionary *sqlDictionary1 = @{@"date": @"1970-01-01 00:02:03",
                                            @"action_type": PUNCH_ACTION_URI_IN,
                                            @"user_uri": @"user:uri",
                                            @"uri": [NSNull null],
                                            @"offline": @YES};
            NSDictionary *sqlDictionary2 = @{@"date": @"1970-01-01 00:02:03",
                                            @"action_type": PUNCH_ACTION_URI_IN,
                                            @"user_uri": @"user:uri",
                                            @"uri": [NSNull null],
                                            @"offline": @NO};

            expectedPunches = [subject deserializeLocalSQLPunches:@[sqlDictionary1,sqlDictionary2] punchOEFStorage:punchOEFStorage];
        });

        it(@"should correctly deserialize punches and return them", ^{

            expectedPunches.count should equal(2);
            OfflineLocalPunch *manualLocalPunch = expectedPunches.firstObject;
            manualLocalPunch should be_instance_of([OfflineLocalPunch class]);
            [manualLocalPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
            [manualLocalPunch actionType] should equal(PunchActionTypePunchIn);
            [manualLocalPunch userURI] should equal(@"user:uri");
            [manualLocalPunch offline] should be_truthy;

            LocalPunch *localPunch = expectedPunches.lastObject;
            localPunch should be_instance_of([LocalPunch class]);
            [localPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
            [localPunch actionType] should equal(PunchActionTypePunchIn);
            [localPunch userURI] should equal(@"user:uri");
            [localPunch offline] should_not be_truthy;
        });

    });

    describe(@"deserializeSingleLocalSQLPunch:punchOEFStorage:", ^{

        __block id<Punch> punch;

        context(@"when only mandatory fields for a local punch are filled in", ^{
            beforeEach(^{
                NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                @"action_type": PUNCH_ACTION_URI_IN,
                                                @"user_uri": @"user:uri",
                                                @"uri": @"punch_uri:uri",
                                                @"punchSyncStatus": [NSNull null] ,
                                                @"lastSyncTime": @"1970-01-01 00:02:03"};
                punch = [subject deserializeSingleLocalSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
            });

            it(@"should correctly deserialize a LocalPunch", ^{
                punch should be_instance_of([LocalPunch class]);
                [punch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                [punch actionType] should equal(PunchActionTypePunchIn);
                [punch userURI] should equal(@"user:uri");
                [punch punchSyncStatus] should equal(UnsubmittedSyncStatus);
                [punch lastSyncTime] should equal([NSDate dateWithTimeIntervalSince1970:123]);
            });

            it(@"fetch all OEFs for a punch", ^{
                punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
            });
        });

        context(@"when there is a break type", ^{
            beforeEach(^{
                NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                @"action_type": PUNCH_ACTION_URI_IN,
                                                @"user_uri": @"user:uri",
                                                @"uri": @"punch_uri:uri",
                                                @"break_type_name": @"Meal Break",
                                                @"break_type_uri": @"meal:break:uri",
                                                @"punchSyncStatus": [NSNull null] ,
                                                @"lastSyncTime": @"1970-01-01 00:02:03"};
                punch = [subject deserializeSingleLocalSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
            });

            it(@"should correctly deserialize a LocalPunch", ^{
                BreakType *breakType = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal:break:uri"];
                punch should be_instance_of([LocalPunch class]);
                [punch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                [punch actionType] should equal(PunchActionTypePunchIn);
                [punch userURI] should equal(@"user:uri");
                [punch breakType] should equal(breakType);
                [punch punchSyncStatus] should equal(UnsubmittedSyncStatus);
                [punch lastSyncTime] should equal([NSDate dateWithTimeIntervalSince1970:123]);
            });

            it(@"fetch all OEFs for a punch", ^{
                punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
            });
        });

        context(@"when there is a location", ^{
            beforeEach(^{
                NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                @"action_type": PUNCH_ACTION_URI_IN,
                                                @"user_uri": @"user:uri",
                                                @"uri": @"punch_uri:uri",
                                                @"location_latitude":@(70.80),
                                                @"location_longitude":@(80.70),
                                                @"location_horizontal_accuracy":@(123),
                                                @"punchSyncStatus": [NSNull null] ,
                                                @"lastSyncTime": @"1970-01-01 00:02:03"};
                punch = [subject deserializeSingleLocalSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
            });

            it(@"should correctly deserialize a RemotePunch", ^{
                RemotePunch *remotePunch = punch;
                remotePunch should be_instance_of([LocalPunch class]);
                [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                [remotePunch actionType] should equal(PunchActionTypePunchIn);
                [remotePunch userURI] should equal(@"user:uri");
                [[remotePunch location] coordinate].latitude should equal(70.80);
                [[remotePunch location] coordinate].longitude should equal(80.70);
                [[remotePunch location] horizontalAccuracy] should equal(123);
                [remotePunch punchSyncStatus] should equal(UnsubmittedSyncStatus);
                [remotePunch lastSyncTime] should equal([NSDate dateWithTimeIntervalSince1970:123]);
            });

            it(@"fetch all OEFs for a punch", ^{
                punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
            });
        });

        context(@"when there is an address", ^{
            beforeEach(^{
                NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                @"action_type": PUNCH_ACTION_URI_IN,
                                                @"user_uri": @"user:uri",
                                                @"uri": @"punch_uri:uri",
                                                @"address": @"an example address",
                                                @"punchSyncStatus": [NSNull null] ,
                                                @"lastSyncTime": @"1970-01-01 00:02:03"};
                punch = [subject deserializeSingleLocalSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
            });

            it(@"should correctly deserialize a RemotePunch", ^{
                RemotePunch *remotePunch = punch;
                remotePunch should be_instance_of([LocalPunch class]);
                [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                [remotePunch actionType] should equal(PunchActionTypePunchIn);
                [remotePunch userURI] should equal(@"user:uri");
                [remotePunch address] should equal(@"an example address");
                [remotePunch punchSyncStatus] should equal(UnsubmittedSyncStatus);
                [remotePunch lastSyncTime] should equal([NSDate dateWithTimeIntervalSince1970:123]);
            });

            it(@"fetch all OEFs for a punch", ^{
                punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
            });
        });

        context(@"when there is an image url", ^{
            beforeEach(^{
                NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                @"action_type": PUNCH_ACTION_URI_IN,
                                                @"user_uri": @"user:uri",
                                                @"uri": @"punch_uri:uri",
                                                @"image_url": @"http://example.com/image.png",
                                                @"punchSyncStatus": [NSNull null] ,
                                                @"lastSyncTime": @"1970-01-01 00:02:03"};
                punch = [subject deserializeSingleLocalSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
            });

            it(@"should correctly deserialize a LocalPunch", ^{
                punch should be_instance_of([LocalPunch class]);
                [punch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                [punch actionType] should equal(PunchActionTypePunchIn);
                [punch userURI] should equal(@"user:uri");
                [punch punchSyncStatus] should equal(UnsubmittedSyncStatus);
                [punch lastSyncTime] should equal([NSDate dateWithTimeIntervalSince1970:123]);
            });

            it(@"fetch all OEFs for a punch", ^{
                punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
            });
        });

        context(@"when there null optional values", ^{
            beforeEach(^{
                NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                @"action_type": PUNCH_ACTION_URI_IN,
                                                @"user_uri": @"user:uri",
                                                @"uri": @"punch_uri:uri",
                                                @"image_url": [NSNull null],
                                                @"break_type_name": [NSNull null],
                                                @"break_type_uri": [NSNull null],
                                                @"location_latitude":[NSNull null],
                                                @"location_longitude":[NSNull null],
                                                @"location_horizontal_accuracy":[NSNull null],
                                                @"address": [NSNull null],
                                                @"punchSyncStatus": [NSNull null] ,
                                                @"lastSyncTime": @"1970-01-01 00:02:03"};

                punch = [subject deserializeSingleLocalSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
            });

            it(@"should correctly deserialize a RemotePunch", ^{
                punch should be_instance_of([LocalPunch class]);
                [punch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                [punch actionType] should equal(PunchActionTypePunchIn);
                [punch userURI] should equal(@"user:uri");
                [punch breakType] should be_nil;
                [punch location] should be_nil;
                [punch address] should be_nil;
                [punch punchSyncStatus] should equal(UnsubmittedSyncStatus);
                [punch lastSyncTime] should equal([NSDate dateWithTimeIntervalSince1970:123]);
            });

            it(@"fetch all OEFs for a punch", ^{
                punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
            });
        });

        context(@"when there is a request ID", ^{
            beforeEach(^{
                NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                @"action_type": PUNCH_ACTION_URI_IN,
                                                @"user_uri": @"user:uri",
                                                @"uri": @"punch_uri:uri",
                                                @"image_url": @"http://example.com/image.png",
                                                @"punchSyncStatus": [NSNull null] ,
                                                @"lastSyncTime": @"1970-01-01 00:02:03",
                                                @"request_id":@"AQBCD123"};
                punch = [subject deserializeSingleLocalSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
            });

            it(@"should correctly deserialize a RemotePunch", ^{
                RemotePunch *remotePunch = punch;
                remotePunch should be_instance_of([LocalPunch class]);
                [remotePunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                [remotePunch actionType] should equal(PunchActionTypePunchIn);
                [remotePunch userURI] should equal(@"user:uri");
                [remotePunch punchSyncStatus] should equal(UnsubmittedSyncStatus);
                [remotePunch lastSyncTime] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                [remotePunch requestID] should equal(@"AQBCD123");
            });

            it(@"fetch all OEFs for a punch", ^{
                punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(@"AQBCD123");
            });
        });

        context(@"when there is an image", ^{
            beforeEach(^{
                UIImage *image = [UIImage imageNamed:@"icon_timesheet_has_violations"];
                NSData *imageData = UIImagePNGRepresentation(image);

                NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                @"action_type": PUNCH_ACTION_URI_IN,
                                                @"user_uri": @"user:uri",
                                                @"uri": [NSNull null],
                                                @"image": imageData};
                punch = [subject deserializeSingleLocalSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
            });

            it(@"should correctly deserialize a LocalPunch", ^{
                LocalPunch *localPunch = punch;
                localPunch should be_instance_of([LocalPunch class]);
                [localPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                [localPunch actionType] should equal(PunchActionTypePunchIn);
                [localPunch userURI] should equal(@"user:uri");
                [localPunch image] should_not be_nil;
            });

            it(@"fetch all OEFs for a punch", ^{
                punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
            });
        });

        context(@"when there is no image", ^{
            beforeEach(^{
                NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                @"action_type": PUNCH_ACTION_URI_IN,
                                                @"user_uri": @"user:uri",
                                                @"uri": [NSNull null],
                                                @"image": [NSNull null]};
                punch = [subject deserializeSingleLocalSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
            });

            it(@"should correctly deserialize a LocalPunch", ^{
                LocalPunch *localPunch = punch;
                localPunch should be_instance_of([LocalPunch class]);
                [localPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                [localPunch actionType] should equal(PunchActionTypePunchIn);
                [localPunch userURI] should equal(@"user:uri");

                [localPunch image] should be_nil;
            });

            it(@"fetch all OEFs for a punch", ^{
                punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
            });
        });

        context(@"when the punch is marked 'offline'", ^{
            beforeEach(^{
                NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                @"action_type": PUNCH_ACTION_URI_IN,
                                                @"user_uri": @"user:uri",
                                                @"uri": [NSNull null],
                                                @"offline": @YES};
                punch = [subject deserializeSingleLocalSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
            });

            it(@"should correctly deserialize a OfflineLocalPunch", ^{
                OfflineLocalPunch *manualLocalPunch = punch;
                manualLocalPunch should be_instance_of([OfflineLocalPunch class]);
                [manualLocalPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                [manualLocalPunch actionType] should equal(PunchActionTypePunchIn);
                [manualLocalPunch userURI] should equal(@"user:uri");
                [manualLocalPunch offline] should be_truthy;
            });

            it(@"fetch all OEFs for a punch", ^{
                punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
            });
        });

        context(@"when the punch is marked 'online'", ^{
            beforeEach(^{
                NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                @"action_type": PUNCH_ACTION_URI_IN,
                                                @"user_uri": @"user:uri",
                                                @"uri": [NSNull null],
                                                @"offline": @NO};
                punch = [subject deserializeSingleLocalSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
            });

            it(@"should correctly deserialize a OfflineLocalPunch", ^{
                LocalPunch *localPunch = punch;
                localPunch should be_instance_of([LocalPunch class]);
                [localPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                [localPunch actionType] should equal(PunchActionTypePunchIn);
                [localPunch userURI] should equal(@"user:uri");
                [localPunch offline] should_not be_truthy;
            });

            it(@"fetch all OEFs for a punch", ^{
                punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
            });
        });

        context(@"when there is a client type", ^{
            beforeEach(^{
                NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                @"action_type": PUNCH_ACTION_URI_IN,
                                                @"user_uri": @"user:uri",
                                                @"uri": [NSNull null],
                                                @"client_name": @"client-name",
                                                @"client_uri": @"client-uri",
                                                };
                punch = [subject deserializeSingleLocalSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
            });

            it(@"should correctly deserialize a RemotePunch", ^{
                ClientType *clientType = [[ClientType alloc] initWithName:@"client-name" uri:@"client-uri"];
                LocalPunch *localPunch = punch;
                localPunch should be_instance_of([LocalPunch class]);
                [localPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                [localPunch actionType] should equal(PunchActionTypePunchIn);
                [localPunch userURI] should equal(@"user:uri");
                [localPunch client] should equal(clientType);
            });

            it(@"fetch all OEFs for a punch", ^{
                punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
            });
        });

        context(@"when there is a project type", ^{
            beforeEach(^{
                NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                @"action_type": PUNCH_ACTION_URI_IN,
                                                @"user_uri": @"user:uri",
                                                @"uri": [NSNull null],
                                                @"project_name": @"project-name",
                                                @"project_uri": @"project-uri",
                                                };
                punch = [subject deserializeSingleLocalSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
            });

            it(@"should correctly deserialize a RemotePunch", ^{
                ProjectType *projectType = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"project-name"
                                                                                                    uri:@"project-uri"];
                LocalPunch *localPunch = punch;
                localPunch should be_instance_of([LocalPunch class]);
                [localPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                [localPunch actionType] should equal(PunchActionTypePunchIn);
                [localPunch userURI] should equal(@"user:uri");
                [localPunch project] should equal(projectType);
            });

            it(@"fetch all OEFs for a punch", ^{
                punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
            });
        });

        context(@"when there is a task type", ^{
            beforeEach(^{
                NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                @"action_type": PUNCH_ACTION_URI_IN,
                                                @"user_uri": @"user:uri",
                                                @"uri": [NSNull null],
                                                @"task_name": @"task-name",
                                                @"task_uri": @"task-uri",
                                                @"offline": @YES
                                                };
                punch = [subject deserializeSingleLocalSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
            });

            it(@"should correctly deserialize a RemotePunch", ^{
                TaskType *taskType = [[TaskType alloc] initWithProjectUri:nil
                                                               taskPeriod:nil
                                                                     name:@"task-name"
                                                                      uri:@"task-uri"];
                LocalPunch *localPunch = punch;
                localPunch should be_instance_of([OfflineLocalPunch class]);
                [localPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                [localPunch actionType] should equal(PunchActionTypePunchIn);
                [localPunch userURI] should equal(@"user:uri");
                [localPunch task] should equal(taskType);
            });

            it(@"fetch all OEFs for a punch", ^{
                punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
            });
        });

        context(@"when there is a activity type", ^{
            beforeEach(^{
                NSDictionary *sqlDictionary = @{@"date": @"1970-01-01 00:02:03",
                                                @"action_type": PUNCH_ACTION_URI_IN,
                                                @"user_uri": @"user:uri",
                                                @"uri": [NSNull null],
                                                @"activity_name": @"activity-name",
                                                @"activity_uri": @"activity-uri",
                                                };
                punch = [subject deserializeSingleLocalSQLPunch:sqlDictionary punchOEFStorage:punchOEFStorage];
            });

            it(@"should correctly deserialize a LocalPunch", ^{
                Activity *activityType = [[Activity alloc]initWithName:@"activity-name" uri:@"activity-uri"];
                LocalPunch *localPunch = punch;
                localPunch should be_instance_of([LocalPunch class]);
                [localPunch date] should equal([NSDate dateWithTimeIntervalSince1970:123]);
                [localPunch actionType] should equal(PunchActionTypePunchIn);
                [localPunch userURI] should equal(@"user:uri");
                [localPunch activity] should equal(activityType);
            });

            it(@"fetch all OEFs for a punch", ^{
                punchOEFStorage should have_received(@selector(getPunchOEFTypesForRequestID:)).with(nil);
            });
        });

    });

});

SPEC_END
