#import <Cedar/Cedar.h>
#import <CoreLocation/CoreLocation.h>
#import <MacTypes.h>
#import "RemotePunchDeserializer.h"
#import "RemotePunch.h"
#import "Util.h"
#import "RepliconSpecHelper.h"
#import "BreakType.h"
#import "RemotePunch.h"
#import "PunchActionTypes.h"
#import "Activity.h"
#import "ProjectType.h"
#import "ClientType.h"
#import "TaskType.h"
#import "OEFType.h"
#import "Enum.h"
#import "GUIDProvider.h"
#import "PunchActionTypeDeserializer.h"
#import "OEFDeserializer.h"
#import "ViolationsDeserializer.h"
#import "SingleViolationDeserializer.h"
#import <Blindside/BSInjector.h>
#import <Blindside/BSBinder.h>
#import "InjectorProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(RemotePunchDeserializerSpec)

describe(@"RemotePunchDeserializer", ^{
    __block RemotePunchDeserializer *subject;
    __block GUIDProvider *guidProvider;
    __block PunchActionTypeDeserializer *punchActionTypeDeserializer;
    __block OEFDeserializer *oefDeserializer;
    __block ViolationsDeserializer *violationsDeserializer;
    __block id<BSInjector, BSBinder> injector;

    beforeEach(^{
        injector = [InjectorProvider injector];

        guidProvider = nice_fake_for([GUIDProvider class]);
        guidProvider stub_method(@selector(guid)).and_return(@"guid-A");
        
        punchActionTypeDeserializer =  [[PunchActionTypeDeserializer alloc] init];
        oefDeserializer =  [[OEFDeserializer alloc] init];
        
        violationsDeserializer = [injector getInstance:[ViolationsDeserializer class]];
        
        subject = [[RemotePunchDeserializer alloc]initWithPunchActionTypeDeserializer:punchActionTypeDeserializer
                                                        dateTimeComponentDeserializer:nil
                                                               violationsDeserializer:violationsDeserializer
                                                                      oefDeserializer:oefDeserializer
                                                                         guidProvider:guidProvider
                                                                             calendar:nil];
    });

    describe(@"deserialize:", ^{
        __block RemotePunch *deserializedPunch;
        __block RemotePunch *expectedPunch;

        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(37.3323, -122.0312);
        CLLocation *expectedLocation = [[CLLocation alloc] initWithCoordinate:coordinate altitude:-1 horizontalAccuracy:5 verticalAccuracy:-1 timestamp:[NSDate date]];
        NSDictionary *mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"most_recent_punch"][@"d"];
        NSDate *expectedDate = [NSDate dateWithTimeIntervalSince1970:1427390854];

        context(@"with a punch out and location and address", ^{
            beforeEach(^{
                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];
                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                 uri:@"urn:replicon-tenant:iphone:client:3"];

                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];


                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypePunchOut
                                                               oefTypesArray:nil
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:expectedLocation
                                                                  violations:@[]
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:client
                                                                     address:@"address unavailable"
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                deserializedPunch = [subject deserialize:mostRecentPunchDictionary];
            });

            it(@"should return a correctly configured RemotePunch object with an actionType of 'punch out'", ^{
                deserializedPunch should equal(expectedPunch);
            });

            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });

        context(@"with a punch out and location and address", ^{
            beforeEach(^{
                NSDictionary *dictionary = [RepliconSpecHelper jsonWithFixture:@"most_recent_punch_null_address"][@"d"];
                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];
                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                 uri:@"urn:replicon-tenant:iphone:client:3"];

                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];

                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];



                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypePunchOut
                                                               oefTypesArray:nil
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:expectedLocation
                                                                  violations:@[]
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:client
                                                                     address:nil
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                deserializedPunch = [subject deserialize:dictionary];
            });

            it(@"should return a correctly configured RemotePunch object with an actionType of 'punch out'", ^{
                deserializedPunch should equal(expectedPunch);
            });

            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });

        context(@"with a punch in", ^{
            beforeEach(^{
                NSDictionary *mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"most_recent_punch_in"][@"d"];
                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];
                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                 uri:@"urn:replicon-tenant:iphone:client:3"];
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];

                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];




                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypePunchIn
                                                               oefTypesArray:nil
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:nil
                                                                  violations:@[]
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:client
                                                                     address:nil
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                deserializedPunch = [subject deserialize:mostRecentPunchDictionary];
            });

            it(@"should return a correctly configured RemotePunch object with an actionType of 'punch in'", ^{
                deserializedPunch should equal(expectedPunch);
            });

            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });

        context(@"With a punch transfer", ^{
            beforeEach(^{
                NSDictionary *mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"most_recent_punch_transfer"][@"d"];
                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];

                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                 uri:@"urn:replicon-tenant:iphone:client:3"];

                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];
                deserializedPunch = [subject deserialize:mostRecentPunchDictionary];


                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypeTransfer
                                                               oefTypesArray:nil
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:nil
                                                                  violations:@[]
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:client
                                                                     address:nil
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            });

            it(@"should return a correctly configured RemotePunch object with an actionType of 'transfer'", ^{
                deserializedPunch should equal(expectedPunch);
            });

            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });

        context(@"with a start break", ^{
            beforeEach(^{
                NSDate *expectedDate = [NSDate dateWithTimeIntervalSince1970:1429207435];
                NSDictionary *mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"start_break_punch_response"][@"d"];
                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];

                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                 uri:@"urn:replicon-tenant:iphone:client:3"];

                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];
                BreakType *expectedBreakType = [[BreakType alloc] initWithName:@"Meal" uri:@"urn:replicon-tenant:astro:break-type:6c6af9ed-b4db-4507-a817-891b4605f993"];



                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypeStartBreak
                                                               oefTypesArray:nil
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:expectedBreakType
                                                                    location:expectedLocation
                                                                  violations:@[]
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:client
                                                                     address:@"address unavailable"
                                                                     userURI:@"urn:replicon-tenant:astro:user:70"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:astro:time-punch:50f2f354-4d77-4105-8d26-5f94d284dca6"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                deserializedPunch = [subject deserialize:mostRecentPunchDictionary];
            });

            it(@"should return a correctly configured RemotePunch object with an actionType of 'punch in'", ^{
                deserializedPunch should equal(expectedPunch);
            });

            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });

        context(@"with a punch with client equal to nil", ^{
            beforeEach(^{
                NSDictionary *dictionary = [[RepliconSpecHelper jsonWithFixture:@"most_recent_punch_null_address"][@"d"] mutableCopy];

                NSMutableDictionary *clientNulldict = [dictionary mutableCopy];

                NSMutableDictionary *punchInAttributes = [[clientNulldict objectForKey:@"punchInAttributes"] mutableCopy];
                [punchInAttributes removeObjectForKey:@"client"];
                [clientNulldict setObject:punchInAttributes forKey:@"punchInAttributes"];

                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:nil
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];



                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypePunchOut
                                                               oefTypesArray:nil
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:expectedLocation
                                                                  violations:@[]
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:nil
                                                                     address:nil
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                deserializedPunch = [subject deserialize:clientNulldict];
            });

            it(@"should return a correctly configured RemotePunch object with a client type", ^{
                deserializedPunch should equal(expectedPunch);
            });

            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });

        context(@"with a punch with task equal to nil", ^{
            beforeEach(^{
                NSDictionary *dictionary = [[RepliconSpecHelper jsonWithFixture:@"most_recent_punch_null_address"][@"d"] mutableCopy];

                NSMutableDictionary *clientNulldict = [dictionary mutableCopy];

                NSMutableDictionary *punchInAttributes = [[clientNulldict objectForKey:@"punchInAttributes"] mutableCopy];
                [punchInAttributes removeObjectForKey:@"task"];
                [clientNulldict setObject:punchInAttributes forKey:@"punchInAttributes"];

                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];

                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                 uri:@"urn:replicon-tenant:iphone:client:3"];

                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];

                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypePunchOut
                                                               oefTypesArray:nil
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:expectedLocation
                                                                  violations:@[]
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:client
                                                                     address:nil
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:nil
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                deserializedPunch = [subject deserialize:clientNulldict];
            });

            it(@"should return a correctly configured RemotePunch object with a valid Task", ^{
                deserializedPunch should equal(expectedPunch);
            });

            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });

        context(@"with a punch with project equal to nil", ^{
            beforeEach(^{
                NSDictionary *dictionary = [[RepliconSpecHelper jsonWithFixture:@"most_recent_punch_null_address"][@"d"] mutableCopy];

                NSMutableDictionary *clientNulldict = [dictionary mutableCopy];

                NSMutableDictionary *punchInAttributes = [[clientNulldict objectForKey:@"punchInAttributes"] mutableCopy];
                [punchInAttributes removeObjectForKey:@"project"];
                [clientNulldict setObject:punchInAttributes forKey:@"punchInAttributes"];

                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];
                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc" uri:@"urn:replicon-tenant:iphone:client:3"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:nil taskPeriod:nil name:@"Deployment" uri:@"urn:replicon-tenant:mobile:task:111"];


                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypePunchOut
                                                               oefTypesArray:nil
                                                                lastSyncTime:NULL
                                                                     project:nil
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:expectedLocation
                                                                  violations:@[]
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:client
                                                                     address:nil
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                deserializedPunch = [subject deserialize:clientNulldict];
            });

            it(@"should return a correctly configured RemotePunch object with a valid project", ^{
                deserializedPunch should equal(expectedPunch);
            });

            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });

        context(@"with a punch with activity equal to nil", ^{
            beforeEach(^{
                NSDictionary *dictionary = [[RepliconSpecHelper jsonWithFixture:@"most_recent_punch_null_address"][@"d"] mutableCopy];

                NSMutableDictionary *clientNulldict = [dictionary mutableCopy];

                NSMutableDictionary *punchInAttributes = [[clientNulldict objectForKey:@"punchInAttributes"] mutableCopy];
                [punchInAttributes removeObjectForKey:@"activity"];
                [clientNulldict setObject:punchInAttributes forKey:@"punchInAttributes"];

                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                 uri:@"urn:replicon-tenant:iphone:client:3"];

                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];

                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];


                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypePunchOut
                                                               oefTypesArray:nil
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:expectedLocation
                                                                  violations:@[]
                                                                   requestID:@"guid-A"
                                                                    activity:nil
                                                                    duration:nil
                                                                      client:client
                                                                     address:nil
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                deserializedPunch = [subject deserialize:clientNulldict];
            });

            it(@"should return a correctly configured RemotePunch object with a valid project", ^{
                deserializedPunch should equal(expectedPunch);
            });

            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });

        context(@"with an unknown punch type", ^{
            beforeEach(^{
                NSDictionary *mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"most_recent_punch_bogus"][@"d"];
                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];

                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                 uri:@"urn:replicon-tenant:iphone:client:3"];

                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];



                deserializedPunch = [subject deserialize:mostRecentPunchDictionary];
                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypeUnknown
                                                               oefTypesArray:nil
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:nil
                                                                  violations:@[]
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:client
                                                                     address:nil
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            });

            it(@"should return a correctly configured RemotePunch object with an actionType of 'unknown'", ^{
                deserializedPunch should equal(expectedPunch);
            });

            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });
        
        context(@"with an nextpunchpair", ^{
            beforeEach(^{
                NSDictionary *mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"most_recent_punch_with_nextpunchpairStatus"];
                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];
                
                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                 uri:@"urn:replicon-tenant:iphone:client:3"];
                
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];
                
                
                
                deserializedPunch = [subject deserialize:mostRecentPunchDictionary];
                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Ticking
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypeUnknown
                                                               oefTypesArray:nil
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:nil
                                                                  violations:@[]
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:client
                                                                     address:nil
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                                     previousPunchActionType:PunchActionTypeUnknown];
            });
            
            it(@"should return a correctly configured RemotePunch object with an actionType of 'unknown'", ^{
                deserializedPunch should equal(expectedPunch);
            });
            
            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });

        context(@"with an previouspunchpair", ^{
            beforeEach(^{
                NSDictionary *mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"most_recent_punch_with_previouspunchpairStatus"];
                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];
                
                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                 uri:@"urn:replicon-tenant:iphone:client:3"];
                
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];
                
                
                
                deserializedPunch = [subject deserialize:mostRecentPunchDictionary];
                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Ticking
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypeUnknown
                                                               oefTypesArray:nil
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:nil
                                                                  violations:@[]
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:client
                                                                     address:nil
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                                     previousPunchActionType:PunchActionTypeUnknown];
            });
            
            it(@"should return a correctly configured RemotePunch object with an actionType of 'unknown'", ^{
                deserializedPunch should equal(expectedPunch);
            });
            
            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });
        
        context(@"with an sourceofpunch", ^{
            beforeEach(^{
                NSDictionary *mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"most_recent_punch_with_sourceofpunch"];
                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];
                
                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                 uri:@"urn:replicon-tenant:iphone:client:3"];
                
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];
                
                
                
                deserializedPunch = [subject deserialize:mostRecentPunchDictionary];
                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:Mobile
                                                                  actionType:PunchActionTypeUnknown
                                                               oefTypesArray:nil
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:nil
                                                                  violations:@[]
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:client
                                                                     address:nil
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                                     previousPunchActionType:PunchActionTypeUnknown];
            });
            
            it(@"should return a correctly configured RemotePunch object with an actionType of 'unknown'", ^{
                deserializedPunch should equal(expectedPunch);
            });
            
            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });
        
        context(@"without timepunchagent", ^{
            beforeEach(^{
                NSDictionary *mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"most_recent_punch_without_timepunchagent"];
                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];
                
                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                 uri:@"urn:replicon-tenant:iphone:client:3"];
                
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];
                
                
                
                deserializedPunch = [subject deserialize:mostRecentPunchDictionary];
                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypeUnknown
                                                               oefTypesArray:nil
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:nil
                                                                  violations:@[]
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:client
                                                                     address:nil
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                                     previousPunchActionType:PunchActionTypeUnknown];
            });
            
            it(@"should return a correctly configured RemotePunch object with an actionType of 'unknown'", ^{
                deserializedPunch should equal(expectedPunch);
            });
            
            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });
        
        context(@"with an violation", ^{
            beforeEach(^{
                NSDictionary *mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"most_recent_punch_with_violation"];
                NSArray *violations = [NSArray array];
                violations = [violationsDeserializer deserializeViolationsFromPunchValidationResult:mostRecentPunchDictionary];

                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];
                
                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                 uri:@"urn:replicon-tenant:iphone:client:3"];
                
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];
                
                
                
                deserializedPunch = [subject deserialize:mostRecentPunchDictionary];
                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:Mobile
                                                                  actionType:PunchActionTypeUnknown
                                                               oefTypesArray:nil
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:nil
                                                                  violations:violations
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:client
                                                                     address:nil
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                                     previousPunchActionType:PunchActionTypeUnknown];
            });
            
            it(@"should return a correctly configured RemotePunch object with an actionType of 'unknown'", ^{
                deserializedPunch should equal(expectedPunch);
            });
            
            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });

        context(@"with an nonActionedValidationsCount and violations", ^{
            beforeEach(^{
                NSDictionary *mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"most_recent_punch_with_nonActionedValidationsCount"];
                
                NSArray *violations = [NSArray array];
                violations = [violationsDeserializer deserializeViolationsFromPunchValidationResult:mostRecentPunchDictionary];

                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];
                
                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                 uri:@"urn:replicon-tenant:iphone:client:3"];
                
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];
                
                
                
                deserializedPunch = [subject deserialize:mostRecentPunchDictionary];
                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:1
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:Mobile
                                                                  actionType:PunchActionTypeUnknown
                                                               oefTypesArray:nil
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:nil
                                                                  violations:violations
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:client
                                                                     address:nil
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                                     previousPunchActionType:PunchActionTypeUnknown];
            });
            
            it(@"should return a correctly configured RemotePunch object with an actionType of 'unknown'", ^{
                deserializedPunch should equal(expectedPunch);
            });
            
            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });

        context(@"with a selfie", ^{
            __block RemotePunch *expectedRemotePunch;

            beforeEach(^{
                NSURL *expectedImageURL = [NSURL URLWithString:@"https://example.org/selfies"];

                NSDictionary *punchDictionary = [RepliconSpecHelper jsonWithFixture:@"punch_with_selfie"][@"d"];
                deserializedPunch = [subject deserialize:punchDictionary];
                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];
                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc" uri:@"urn:replicon-tenant:iphone:client:3"];

                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];

                
                expectedRemotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                            nonActionedValidations:0
                                                               previousPunchStatus:Unknown
                                                                   nextPunchStatus:Unknown
                                                                     sourceOfPunch:UnknownSourceOfPunch
                                                                        actionType:PunchActionTypePunchOut
                                                                     oefTypesArray:nil
                                                                      lastSyncTime:NULL
                                                                           project:project
                                                                       auditHstory:nil
                                                                         breakType:nil
                                                                          location:nil
                                                                        violations:@[]
                                                                         requestID:@"guid-A"
                                                                          activity:activity
                                                                          duration:nil
                                                                            client:client
                                                                           address:nil
                                                                           userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                          imageURL:expectedImageURL
                                                                              date:expectedDate
                                                                              task:task
                                                                               uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                              isTimeEntryAvailable:NO
                                                                  syncedWithServer:NO
                                                                    isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            });
            
            it(@"should add the image to the punch", ^{
                deserializedPunch should equal(expectedRemotePunch);
            });
        });
        
        context(@"with null", ^{
            it(@"should return nil", ^{
                [subject deserialize:(id)[NSNull null]] should be_nil;
            });
        });
    });

    describe(@"With OEF deserialize:", ^{
        __block RemotePunch *deserializedPunch;
        __block RemotePunch *expectedPunch;

        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(37.3323, -122.0312);
        CLLocation *expectedLocation = [[CLLocation alloc] initWithCoordinate:coordinate altitude:-1 horizontalAccuracy:5 verticalAccuracy:-1 timestamp:[NSDate date]];
        NSDictionary *mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"most_recent_punch_oef"][@"d"];
        NSDate *expectedDate = [NSDate dateWithTimeIntervalSince1970:1427390854];

        context(@"with a punch out and location and address", ^{
            beforeEach(^{
                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];
                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                 uri:@"urn:replicon-tenant:iphone:client:3"];

                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];


                OEFType *oefType1 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"dipta number" punchActionType:@"PunchOut" numericValue:@"123" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

            

                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"dipta text" punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];


                OEFType *oefType3 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:4fbaccf1-5056-4701-bdad-eec31a209c79" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@
                                     "number not prompt"      punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                OEFType *oefType4 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:ad78693e-a0d9-470e-8e87-b626eb9a8997" definitionTypeUri:@
                                     "urn:replicon:object-extension-definition-type:object-extension-type-text"                                               name:@
                                     "text- not prompt"                                                                                            punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypePunchOut
                                                               oefTypesArray:@[oefType1, oefType2, oefType3, oefType4]
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:expectedLocation
                                                                  violations:@[]
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:client
                                                                     address:@"address unavailable"
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                deserializedPunch = [subject deserialize:mostRecentPunchDictionary];
            });

            it(@"should return a correctly configured RemotePunch object with an actionType of 'punch out'", ^{
                deserializedPunch should equal(expectedPunch);
            });

            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });

        context(@"with a punch out and location and address", ^{
            beforeEach(^{
                NSDictionary *dictionary = [RepliconSpecHelper jsonWithFixture:@"most_recent_punch_null_address_oef"][@"d"];
                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];
                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                 uri:@"urn:replicon-tenant:iphone:client:3"];

                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];

                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];

                OEFType *oefType1 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"dipta number" punchActionType:@"PunchOut" numericValue:@"123" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];



                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"dipta text" punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];


                OEFType *oefType3 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:4fbaccf1-5056-4701-bdad-eec31a209c79" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@
                                     "number not prompt"      punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                OEFType *oefType4 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:ad78693e-a0d9-470e-8e87-b626eb9a8997" definitionTypeUri:@
                                     "urn:replicon:object-extension-definition-type:object-extension-type-text"                                               name:@
                                     "text- not prompt"                                                                                            punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypePunchOut
                                                               oefTypesArray:@[oefType1, oefType2, oefType3, oefType4]
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:expectedLocation
                                                                  violations:@[]
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:client
                                                                     address:nil
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                deserializedPunch = [subject deserialize:dictionary];
            });

            it(@"should return a correctly configured RemotePunch object with an actionType of 'punch out'", ^{
                deserializedPunch should equal(expectedPunch);
            });

            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });

        context(@"with a punch in", ^{
            beforeEach(^{
                NSDictionary *mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"most_recent_punch_in_oef"][@"d"];
                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];
                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                 uri:@"urn:replicon-tenant:iphone:client:3"];
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];

                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];

                OEFType *oefType1 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"dipta number" punchActionType:@"PunchIn" numericValue:@"123" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"dipta text" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                OEFType *oefType3 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:4fbaccf1-5056-4701-bdad-eec31a209c79" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@
                                     "number not prompt"      punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                OEFType *oefType4 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:ad78693e-a0d9-470e-8e87-b626eb9a8997" definitionTypeUri:@
                                     "urn:replicon:object-extension-definition-type:object-extension-type-text"                                               name:@
                                     "text- not prompt"                                                                                            punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypePunchIn
                                                               oefTypesArray:@[oefType1, oefType2, oefType3, oefType4]
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:nil
                                                                  violations:@[]
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:client
                                                                     address:nil
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                deserializedPunch = [subject deserialize:mostRecentPunchDictionary];
            });

            it(@"should return a correctly configured RemotePunch object with an actionType of 'punch in'", ^{
                deserializedPunch should equal(expectedPunch);
            });

            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });

        context(@"With a punch transfer", ^{
            beforeEach(^{
                NSDictionary *mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"most_recent_punch_transfer_oef"][@"d"];
                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];

                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                 uri:@"urn:replicon-tenant:iphone:client:3"];

                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];
                deserializedPunch = [subject deserialize:mostRecentPunchDictionary];

                OEFType *oefType1 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"dipta number" punchActionType:@"Transfer" numericValue:@"123" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"dipta text" punchActionType:@"Transfer" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                OEFType *oefType3 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:4fbaccf1-5056-4701-bdad-eec31a209c79" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@
                                     "number not prompt"      punchActionType:@"Transfer" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                OEFType *oefType4 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:ad78693e-a0d9-470e-8e87-b626eb9a8997" definitionTypeUri:@
                                     "urn:replicon:object-extension-definition-type:object-extension-type-text"                                               name:@
                                     "text- not prompt"                                                                                            punchActionType:@"Transfer" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypeTransfer
                                                               oefTypesArray:@[oefType1, oefType2, oefType3, oefType4]
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:nil
                                                                  violations:@[]
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:client
                                                                     address:nil
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            });

            it(@"should return a correctly configured RemotePunch object with an actionType of 'transfer'", ^{
                deserializedPunch should equal(expectedPunch);
            });

            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });

        context(@"with a start break", ^{
            beforeEach(^{
                NSDate *expectedDate = [NSDate dateWithTimeIntervalSince1970:1429207435];
                NSDictionary *mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"start_break_punch_response_oef"][@"d"];
                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];

                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                 uri:@"urn:replicon-tenant:iphone:client:3"];

                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];
                BreakType *expectedBreakType = [[BreakType alloc] initWithName:@"Meal" uri:@"urn:replicon-tenant:astro:break-type:6c6af9ed-b4db-4507-a817-891b4605f993"];



                OEFType *oefType1 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"dipta number" punchActionType:@"StartBreak" numericValue:@"123" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"dipta text" punchActionType:@"StartBreak" numericValue:nil textValue:@"test123" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];


                OEFType *oefType3 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:4fbaccf1-5056-4701-bdad-eec31a209c79" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@
                                     "number not prompt"      punchActionType:@"StartBreak" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                OEFType *oefType4 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:ad78693e-a0d9-470e-8e87-b626eb9a8997" definitionTypeUri:@
                                     "urn:replicon:object-extension-definition-type:object-extension-type-text"                                               name:@
                                     "text- not prompt"                                                                                            punchActionType:@"StartBreak" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypeStartBreak
                                                               oefTypesArray:@[oefType1, oefType2, oefType3, oefType4]
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:expectedBreakType
                                                                    location:expectedLocation
                                                                  violations:@[]
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:client
                                                                     address:@"address unavailable"
                                                                     userURI:@"urn:replicon-tenant:astro:user:70"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:astro:time-punch:50f2f354-4d77-4105-8d26-5f94d284dca6"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                deserializedPunch = [subject deserialize:mostRecentPunchDictionary];
            });

            it(@"should return a correctly configured RemotePunch object with an actionType of 'punch in'", ^{
                deserializedPunch should equal(expectedPunch);
            });

            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });

        context(@"with a punch with client equal to nil", ^{
            beforeEach(^{
                NSDictionary *dictionary = [[RepliconSpecHelper jsonWithFixture:@"most_recent_punch_null_address_oef"][@"d"] mutableCopy];

                NSMutableDictionary *clientNulldict = [dictionary mutableCopy];

                NSMutableDictionary *punchInAttributes = [[clientNulldict objectForKey:@"punchInAttributes"] mutableCopy];
                [punchInAttributes removeObjectForKey:@"client"];
                [clientNulldict setObject:punchInAttributes forKey:@"punchInAttributes"];

                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:nil
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];

                OEFType *oefType1 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"dipta number" punchActionType:@"PunchOut" numericValue:@"123" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"dipta text" punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                OEFType *oefType3 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:4fbaccf1-5056-4701-bdad-eec31a209c79" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@
                                     "number not prompt"      punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                OEFType *oefType4 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:ad78693e-a0d9-470e-8e87-b626eb9a8997" definitionTypeUri:@
                                     "urn:replicon:object-extension-definition-type:object-extension-type-text"                                               name:@
                                     "text- not prompt"                                                                                            punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];


                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypePunchOut
                                                               oefTypesArray:@[oefType1, oefType2, oefType3, oefType4]
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:expectedLocation
                                                                  violations:@[]
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:nil
                                                                     address:nil
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                deserializedPunch = [subject deserialize:clientNulldict];
            });

            it(@"should return a correctly configured RemotePunch object with a client type", ^{
                deserializedPunch should equal(expectedPunch);
            });

            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });

        context(@"with a punch with task equal to nil", ^{
            beforeEach(^{
                NSDictionary *dictionary = [[RepliconSpecHelper jsonWithFixture:@"most_recent_punch_null_address_oef"][@"d"] mutableCopy];

                NSMutableDictionary *clientNulldict = [dictionary mutableCopy];

                NSMutableDictionary *punchInAttributes = [[clientNulldict objectForKey:@"punchInAttributes"] mutableCopy];
                [punchInAttributes removeObjectForKey:@"task"];
                [clientNulldict setObject:punchInAttributes forKey:@"punchInAttributes"];

                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];

                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                 uri:@"urn:replicon-tenant:iphone:client:3"];

                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];


                OEFType *oefType1 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"dipta number" punchActionType:@"PunchOut" numericValue:@"123" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"dipta text" punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];


                OEFType *oefType3 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:4fbaccf1-5056-4701-bdad-eec31a209c79" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@
                                     "number not prompt"      punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                OEFType *oefType4 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:ad78693e-a0d9-470e-8e87-b626eb9a8997" definitionTypeUri:@
                                     "urn:replicon:object-extension-definition-type:object-extension-type-text"                                               name:@
                                     "text- not prompt"                                                                                            punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypePunchOut
                                                               oefTypesArray:@[oefType1, oefType2, oefType3, oefType4]
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:expectedLocation
                                                                  violations:@[]
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:client
                                                                     address:nil
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:nil
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                deserializedPunch = [subject deserialize:clientNulldict];
            });

            it(@"should return a correctly configured RemotePunch object with a valid Task", ^{
                deserializedPunch should equal(expectedPunch);
            });

            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });

        context(@"with a punch with project equal to nil", ^{
            beforeEach(^{
                NSDictionary *dictionary = [[RepliconSpecHelper jsonWithFixture:@"most_recent_punch_null_address_oef"][@"d"] mutableCopy];

                NSMutableDictionary *clientNulldict = [dictionary mutableCopy];

                NSMutableDictionary *punchInAttributes = [[clientNulldict objectForKey:@"punchInAttributes"] mutableCopy];
                [punchInAttributes removeObjectForKey:@"project"];
                [clientNulldict setObject:punchInAttributes forKey:@"punchInAttributes"];

                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];
                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc" uri:@"urn:replicon-tenant:iphone:client:3"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:nil taskPeriod:nil name:@"Deployment" uri:@"urn:replicon-tenant:mobile:task:111"];


                OEFType *oefType1 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"dipta number" punchActionType:@"PunchOut" numericValue:@"123" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"dipta text" punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];


                OEFType *oefType3 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:4fbaccf1-5056-4701-bdad-eec31a209c79" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@
                                     "number not prompt"      punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                OEFType *oefType4 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:ad78693e-a0d9-470e-8e87-b626eb9a8997" definitionTypeUri:@
                                     "urn:replicon:object-extension-definition-type:object-extension-type-text"                                               name:@
                                     "text- not prompt"                                                                                            punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];



                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypePunchOut
                                                               oefTypesArray:@[oefType1, oefType2, oefType3, oefType4]
                                                                lastSyncTime:NULL
                                                                     project:nil
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:expectedLocation
                                                                  violations:@[]
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:client
                                                                     address:nil
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                deserializedPunch = [subject deserialize:clientNulldict];
            });

            it(@"should return a correctly configured RemotePunch object with a valid project", ^{
                deserializedPunch should equal(expectedPunch);
            });

            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });

        context(@"with a punch with activity equal to nil", ^{
            beforeEach(^{
                NSDictionary *dictionary = [[RepliconSpecHelper jsonWithFixture:@"most_recent_punch_null_address_oef"][@"d"] mutableCopy];

                NSMutableDictionary *clientNulldict = [dictionary mutableCopy];

                NSMutableDictionary *punchInAttributes = [[clientNulldict objectForKey:@"punchInAttributes"] mutableCopy];
                [punchInAttributes removeObjectForKey:@"activity"];
                [clientNulldict setObject:punchInAttributes forKey:@"punchInAttributes"];

                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                 uri:@"urn:replicon-tenant:iphone:client:3"];

                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];

                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];

                OEFType *oefType1 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"dipta number" punchActionType:@"PunchOut" numericValue:@"123" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"dipta text" punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                OEFType *oefType3 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:4fbaccf1-5056-4701-bdad-eec31a209c79" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@
                                     "number not prompt"      punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                OEFType *oefType4 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:ad78693e-a0d9-470e-8e87-b626eb9a8997" definitionTypeUri:@
                                     "urn:replicon:object-extension-definition-type:object-extension-type-text"                                               name:@
                                     "text- not prompt"                                                                                            punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypePunchOut
                                                               oefTypesArray:@[oefType1, oefType2, oefType3, oefType4]
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:expectedLocation
                                                                  violations:@[]
                                                                   requestID:@"guid-A"
                                                                    activity:nil
                                                                    duration:nil
                                                                      client:client
                                                                     address:nil
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

                deserializedPunch = [subject deserialize:clientNulldict];
            });

            it(@"should return a correctly configured RemotePunch object with a valid project", ^{
                deserializedPunch should equal(expectedPunch);
            });

            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });


        context(@"with an unknown punch type", ^{
            beforeEach(^{
                NSDictionary *mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"most_recent_punch_bogus_oef"][@"d"];
                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];

                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                 uri:@"urn:replicon-tenant:iphone:client:3"];

                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];


                OEFType *oefType1 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"dipta number" punchActionType:nil numericValue:@"123" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"dipta text" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];



                OEFType *oefType3 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:4fbaccf1-5056-4701-bdad-eec31a209c79" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@
                                     "number not prompt"      punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                OEFType *oefType4 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:ad78693e-a0d9-470e-8e87-b626eb9a8997" definitionTypeUri:@
                                     "urn:replicon:object-extension-definition-type:object-extension-type-text"                                               name:@
                                     "text- not prompt"                                                                                            punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];


                deserializedPunch = [subject deserialize:mostRecentPunchDictionary];
                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypeUnknown
                                                               oefTypesArray:@[oefType1, oefType2, oefType3, oefType4]
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:nil
                                                                  violations:@[]
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:client
                                                                     address:nil
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            });

            it(@"should return a correctly configured RemotePunch object with an actionType of 'unknown'", ^{
                deserializedPunch should equal(expectedPunch);
            });

            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });
        
        context(@"with an nextpunchpair", ^{
            beforeEach(^{
                NSDictionary *mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"most_recent_punch_with_nextpunchpairStatus_and_oef"];
                
                OEFType *oefType1 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"dipta number" punchActionType:nil numericValue:@"123" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"dipta text" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                
                
                OEFType *oefType3 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:4fbaccf1-5056-4701-bdad-eec31a209c79" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@
                                     "number not prompt"      punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                OEFType *oefType4 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:ad78693e-a0d9-470e-8e87-b626eb9a8997" definitionTypeUri:@
                                     "urn:replicon:object-extension-definition-type:object-extension-type-text"                                               name:@
                                     "text- not prompt"                                                                                            punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];
                
                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                 uri:@"urn:replicon-tenant:iphone:client:3"];
                
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];
                
                
                
                deserializedPunch = [subject deserialize:mostRecentPunchDictionary];
                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Ticking
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypeUnknown
                                                               oefTypesArray:@[oefType1, oefType2, oefType3, oefType4]
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:nil
                                                                  violations:@[]
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:client
                                                                     address:nil
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                                     previousPunchActionType:PunchActionTypeUnknown];
            });
            
            it(@"should return a correctly configured RemotePunch object with an actionType of 'unknown'", ^{
                deserializedPunch should equal(expectedPunch);
            });
            
            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });
        
        context(@"with an previouspunchpair", ^{
            beforeEach(^{
                NSDictionary *mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"most_recent_punch_with_previouspunchpairStatus_and_oef"];
                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];
                
                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                 uri:@"urn:replicon-tenant:iphone:client:3"];
                
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];
                
                OEFType *oefType1 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"dipta number" punchActionType:nil numericValue:@"123" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"dipta text" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                
                
                OEFType *oefType3 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:4fbaccf1-5056-4701-bdad-eec31a209c79" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@
                                     "number not prompt"      punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                OEFType *oefType4 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:ad78693e-a0d9-470e-8e87-b626eb9a8997" definitionTypeUri:@
                                     "urn:replicon:object-extension-definition-type:object-extension-type-text"                                               name:@
                                     "text- not prompt"                                                                                            punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                
                deserializedPunch = [subject deserialize:mostRecentPunchDictionary];
                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Ticking
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:UnknownSourceOfPunch
                                                                  actionType:PunchActionTypeUnknown
                                                               oefTypesArray:@[oefType1, oefType2, oefType3, oefType4]
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:nil
                                                                  violations:@[]
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:client
                                                                     address:nil
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                                     previousPunchActionType:PunchActionTypeUnknown];
            });
            
            it(@"should return a correctly configured RemotePunch object with an actionType of 'unknown'", ^{
                deserializedPunch should equal(expectedPunch);
            });
            
            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });
        
        context(@"with an sourceofpunch", ^{
            beforeEach(^{
                NSDictionary *mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"most_recent_punch_with_sourceofpunch_and_oef"];
                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];
                
                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                 uri:@"urn:replicon-tenant:iphone:client:3"];
                
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];
                
                OEFType *oefType1 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"dipta number" punchActionType:nil numericValue:@"123" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"dipta text" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                
                
                OEFType *oefType3 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:4fbaccf1-5056-4701-bdad-eec31a209c79" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@
                                     "number not prompt"      punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                OEFType *oefType4 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:ad78693e-a0d9-470e-8e87-b626eb9a8997" definitionTypeUri:@
                                     "urn:replicon:object-extension-definition-type:object-extension-type-text"                                               name:@
                                     "text- not prompt"                                                                                            punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                
                deserializedPunch = [subject deserialize:mostRecentPunchDictionary];
                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:Mobile
                                                                  actionType:PunchActionTypeUnknown
                                                               oefTypesArray:@[oefType1, oefType2, oefType3, oefType4]
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:nil
                                                                  violations:@[]
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:client
                                                                     address:nil
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                                     previousPunchActionType:PunchActionTypeUnknown];
            });
            
            it(@"should return a correctly configured RemotePunch object with an actionType of 'unknown'", ^{
                deserializedPunch should equal(expectedPunch);
            });
            
            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });
        
        context(@"with an violation", ^{
            beforeEach(^{
                NSDictionary *mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"most_recent_punch_with_violation_and_oef"];
                NSArray *violations = [NSArray array];
                violations = [violationsDeserializer deserializeViolationsFromPunchValidationResult:mostRecentPunchDictionary];
                
                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];
                
                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                 uri:@"urn:replicon-tenant:iphone:client:3"];
                
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];
                
                OEFType *oefType1 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"dipta number" punchActionType:nil numericValue:@"123" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"dipta text" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                
                
                OEFType *oefType3 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:4fbaccf1-5056-4701-bdad-eec31a209c79" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@
                                     "number not prompt"      punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                OEFType *oefType4 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:ad78693e-a0d9-470e-8e87-b626eb9a8997" definitionTypeUri:@
                                     "urn:replicon:object-extension-definition-type:object-extension-type-text"                                               name:@
                                     "text- not prompt"                                                                                            punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                
                deserializedPunch = [subject deserialize:mostRecentPunchDictionary];
                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:0
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:Mobile
                                                                  actionType:PunchActionTypeUnknown
                                                               oefTypesArray:@[oefType1, oefType2, oefType3, oefType4]
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:nil
                                                                  violations:violations
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:client
                                                                     address:nil
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                                     previousPunchActionType:PunchActionTypeUnknown];
            });
            
            it(@"should return a correctly configured RemotePunch object with an actionType of 'unknown'", ^{
                deserializedPunch should equal(expectedPunch);
            });
            
            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });
        
        context(@"with an nonActionedValidationsCount and violations", ^{
            beforeEach(^{
                NSDictionary *mostRecentPunchDictionary = [RepliconSpecHelper jsonWithFixture:@"most_recent_punch_with_nonActionedValidationsCount_and_oef"];
                
                NSArray *violations = [NSArray array];
                violations = [violationsDeserializer deserializeViolationsFromPunchValidationResult:mostRecentPunchDictionary];
                
                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];
                
                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                 uri:@"urn:replicon-tenant:iphone:client:3"];
                
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];
                
                OEFType *oefType1 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"dipta number" punchActionType:nil numericValue:@"123" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"dipta text" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                
                
                OEFType *oefType3 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:4fbaccf1-5056-4701-bdad-eec31a209c79" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@
                                     "number not prompt"      punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                
                OEFType *oefType4 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:ad78693e-a0d9-470e-8e87-b626eb9a8997" definitionTypeUri:@
                                     "urn:replicon:object-extension-definition-type:object-extension-type-text"                                               name:@
                                     "text- not prompt"                                                                                            punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                
                deserializedPunch = [subject deserialize:mostRecentPunchDictionary];
                expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                      nonActionedValidations:1
                                                         previousPunchStatus:Unknown
                                                             nextPunchStatus:Unknown
                                                               sourceOfPunch:Mobile
                                                                  actionType:PunchActionTypeUnknown
                                                               oefTypesArray:@[oefType1, oefType2, oefType3, oefType4]
                                                                lastSyncTime:NULL
                                                                     project:project
                                                                 auditHstory:nil
                                                                   breakType:nil
                                                                    location:nil
                                                                  violations:violations
                                                                   requestID:@"guid-A"
                                                                    activity:activity
                                                                    duration:nil
                                                                      client:client
                                                                     address:nil
                                                                     userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                    imageURL:nil
                                                                        date:expectedDate
                                                                        task:task
                                                                         uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                        isTimeEntryAvailable:NO
                                                            syncedWithServer:NO
                                                              isMissingPunch:NO
                                                     previousPunchActionType:PunchActionTypeUnknown];
            });
            
            it(@"should return a correctly configured RemotePunch object with an actionType of 'unknown'", ^{
                deserializedPunch should equal(expectedPunch);
            });
            
            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
        });


        context(@"with a selfie", ^{
            __block RemotePunch *expectedRemotePunch;

            beforeEach(^{
                NSURL *expectedImageURL = [NSURL URLWithString:@"https://example.org/selfies"];

                NSDictionary *punchDictionary = [RepliconSpecHelper jsonWithFixture:@"punch_with_selfie_oef"][@"d"];
                deserializedPunch = [subject deserialize:punchDictionary];
                Activity *activity = [[Activity alloc]initWithName:@"Meeting"
                                                               uri:@"urn:replicon-tenant:repliconiphone-2:activity:2"];
                ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc" uri:@"urn:replicon-tenant:iphone:client:3"];

                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                           isTimeAllocationAllowed:NO
                                                                                     projectPeriod:nil
                                                                                        clientType:client
                                                                                              name:@"Automated Reporting & Dashboards"
                                                                                               uri:@"urn:replicon-tenant:mobile:project:21"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                          taskPeriod:nil
                                                                name:@"Deployment"
                                                                 uri:@"urn:replicon-tenant:mobile:task:111"];


                OEFType *oefType1 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"dipta number" punchActionType:@"PunchOut" numericValue:@"123" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"dipta text" punchActionType:@"PunchOut" numericValue:nil textValue:@"test123" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];


                OEFType *oefType3 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:4fbaccf1-5056-4701-bdad-eec31a209c79" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@
                                     "number not prompt"      punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                OEFType *oefType4 = [[OEFType alloc]                                                                                      initWithUri:@
                                     "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:ad78693e-a0d9-470e-8e87-b626eb9a8997" definitionTypeUri:@
                                     "urn:replicon:object-extension-definition-type:object-extension-type-text"                                               name:@
                                     "text- not prompt"                                                                                            punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                expectedRemotePunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                            nonActionedValidations:0
                                                               previousPunchStatus:Unknown
                                                                   nextPunchStatus:Unknown
                                                                     sourceOfPunch:UnknownSourceOfPunch
                                                                        actionType:PunchActionTypePunchOut
                                                                     oefTypesArray:@[oefType1, oefType2, oefType3, oefType4]
                                                                      lastSyncTime:NULL
                                                                           project:project
                                                                       auditHstory:nil
                                                                         breakType:nil
                                                                          location:nil
                                                                        violations:@[]
                                                                         requestID:@"guid-A"
                                                                          activity:activity
                                                                          duration:nil
                                                                            client:client
                                                                           address:nil
                                                                           userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                          imageURL:expectedImageURL
                                                                              date:expectedDate
                                                                              task:task
                                                                               uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                              isTimeEntryAvailable:NO
                                                                  syncedWithServer:NO
                                                                    isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            });

            it(@"should add the image to the punch", ^{
                deserializedPunch should equal(expectedRemotePunch);
            });

            it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                deserializedPunch.syncedWithServer should be_truthy;
            });
            
            
            context(@"with a punch with requestid", ^{
                beforeEach(^{
                    NSDictionary *dictionary = [[RepliconSpecHelper jsonWithFixture:@"most_recent_punch_null_address_oef"][@"d"] mutableCopy];
                    
                    NSMutableDictionary *clientNulldict = [dictionary mutableCopy];
                    
                    NSMutableDictionary *punchInAttributes = [[clientNulldict objectForKey:@"punchInAttributes"] mutableCopy];
                    [punchInAttributes removeObjectForKey:@"activity"];
                    [clientNulldict setObject:punchInAttributes forKey:@"punchInAttributes"];
                    [clientNulldict setObject:@"ABCD123" forKey:@"request_id"];
                    
                    ClientType *client = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                                     uri:@"urn:replicon-tenant:iphone:client:3"];
                    
                    ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                               isTimeAllocationAllowed:NO
                                                                                         projectPeriod:nil
                                                                                            clientType:client
                                                                                                  name:@"Automated Reporting & Dashboards"
                                                                                                   uri:@"urn:replicon-tenant:mobile:project:21"];
                    
                    TaskType *task = [[TaskType alloc]initWithProjectUri:@"urn:replicon-tenant:mobile:project:21"
                                                              taskPeriod:nil
                                                                    name:@"Deployment"
                                                                     uri:@"urn:replicon-tenant:mobile:task:111"];
                    
                    OEFType *oefType1 = [[OEFType alloc]                                                                                      initWithUri:@
                                         "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"dipta number" punchActionType:@"PunchOut" numericValue:@"123" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                    OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"dipta text" punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                    OEFType *oefType3 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:4fbaccf1-5056-4701-bdad-eec31a209c79" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@
                                         "number not prompt"      punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                    OEFType *oefType4 = [[OEFType alloc]                                                                                      initWithUri:@
                                         "urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:ad78693e-a0d9-470e-8e87-b626eb9a8997" definitionTypeUri:@
                                         "urn:replicon:object-extension-definition-type:object-extension-type-text"                                               name:@
                                         "text- not prompt"                                                                                            punchActionType:@"PunchOut" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                    
                    expectedPunch = [[RemotePunch alloc] initWithPunchSyncStatus:RemotePunchStatus
                                                          nonActionedValidations:0
                                                             previousPunchStatus:Unknown
                                                                 nextPunchStatus:Unknown
                                                                   sourceOfPunch:UnknownSourceOfPunch
                                                                      actionType:PunchActionTypePunchOut
                                                                   oefTypesArray:@[oefType1, oefType2, oefType3, oefType4]
                                                                    lastSyncTime:NULL
                                                                         project:project
                                                                     auditHstory:nil
                                                                       breakType:nil
                                                                        location:expectedLocation
                                                                      violations:@[]
                                                                       requestID:@"guid-A"
                                                                        activity:nil
                                                                        duration:nil
                                                                          client:client
                                                                         address:nil
                                                                         userURI:@"urn:replicon-tenant:repliconmobile:user:2"
                                                                        imageURL:nil
                                                                            date:expectedDate
                                                                            task:task
                                                                             uri:@"urn:replicon-tenant:repliconmobile:time-punch:182067e0-82da-4bcb-af42-204e8fd59e25"
                                                            isTimeEntryAvailable:NO
                                                                syncedWithServer:NO
                                                                  isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
                    
                    deserializedPunch = [subject deserialize:clientNulldict];
                });
                
                it(@"should return a correctly configured RemotePunch object with a valid project", ^{
                    deserializedPunch should equal(expectedPunch);
                });

                it(@"should return correctly configured RemotePunch object with syncedWithServer as truthy", ^{
                    deserializedPunch.syncedWithServer should be_truthy;
                });
            });

        });
        

        context(@"with null", ^{
            it(@"should return nil", ^{
                [subject deserialize:(id)[NSNull null]] should be_nil;
            });
        });
    });
});


SPEC_END
