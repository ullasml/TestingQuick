#import <Cedar/Cedar.h>
#import <CoreLocation/CoreLocation.h>
#import <MacTypes.h>
#import "RemotePunch.h"
#import "Constants.h"
#import "BreakType.h"
#import "PunchActionTypes.h"
#import "Activity.h"
#import "ProjectType.h"
#import "ClientType.h"
#import "TaskType.h"
#import "OEFType.h"
#import "Enum.h"
#import "Violation.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(RemotePunchSpec)

describe(@"RemotePunch", ^{
    describe(NSStringFromSelector(@selector(isEqual:)), ^{
        __block RemotePunch *punchA;
        __block RemotePunch *punchB;
        __block NSDate *dateA;
        __block NSDate *dateB;
        __block CLLocation *locationA;
        __block CLLocation *locationB;
        __block NSString *addressA;
        __block NSString *addressB;
        __block BreakType *breakTypeA;
        __block BreakType *breakTypeB;
        __block Activity *activityA;
        __block Activity *activityB;
        __block NSString *uriA;
        __block NSString *uriB;
        __block NSString *userUriA;
        __block NSString *userUriB;
        __block ProjectType *projectA;
        __block ProjectType *projectB;
        __block ClientType *clientA;
        __block ClientType *clientB;
        __block TaskType *taskA;
        __block TaskType *taskB;
        __block NSString *punchARequestId;
        __block NSString *punchBRequestId;

        beforeEach(^{
            breakTypeA = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break"];
            breakTypeB = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break"];
            activityA = [[Activity alloc] initWithName:@"Activity" uri:@"some-activity-uri"];
            activityB = [[Activity alloc] initWithName:@"Activity" uri:@"some-activity-uri"];
            projectA = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"Project" uri:@"uri"];
            projectB = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"Project" uri:@"uri"];
            clientA = [[ClientType alloc]initWithName:@"Client" uri:@"uri"];
            clientB = [[ClientType alloc]initWithName:@"Client" uri:@"uri"];
            taskA = [[TaskType alloc]initWithProjectUri:nil taskPeriod:nil name:@"Task" uri:@"uri"];
            taskB = [[TaskType alloc]initWithProjectUri:nil taskPeriod:nil name:@"Task" uri:@"uri"];
            punchARequestId = [[NSUUID UUID] UUIDString];
            punchBRequestId = [[NSUUID UUID] UUIDString];
        });

        it(@"should not be equal when comparing a different type of object", ^{
            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:nil
                                                      auditHstory:nil
                                                        breakType:nil
                                                         location:nil
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:nil
                                                         duration:nil
                                                           client:nil
                                                          address:nil
                                                          userURI:nil
                                                         imageURL:nil
                                                             date:nil
                                                             task:nil
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchA should_not equal((RemotePunch *)[NSDate date]);
        });

        it(@"should be equal when all members are nil", ^{

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:nil
                                                      auditHstory:nil
                                                        breakType:nil
                                                         location:nil
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:nil
                                                         duration:nil
                                                           client:nil
                                                          address:nil
                                                          userURI:nil
                                                         imageURL:nil
                                                             date:nil
                                                             task:nil
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:nil
                                                      auditHstory:nil
                                                        breakType:nil
                                                         location:nil
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:nil
                                                         duration:nil
                                                           client:nil
                                                          address:nil
                                                          userURI:nil
                                                         imageURL:nil
                                                             date:nil
                                                             task:nil
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should equal(punchB);
        });

        it(@"when all members are equal should be equal", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";

            uriA = @"uri";
            uriB = @"uri";
            userUriA = @"user-uri";
            userUriB = @"user-uri";

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:userUriA
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:uriA
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:userUriB
                                                         imageURL:[imageURL copy]
                                                             date:dateB
                                                             task:taskB
                                                              uri:uriB
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should equal(punchB);
        });

        it(@"should not be equal when the punch URI is different", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";

            uriA = @"uri";
            uriB = @"not-your-uri";
            userUriA = @"user-uri";
            userUriB = @"user-uri";

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:userUriA
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:uriA
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:userUriB
                                                         imageURL:[imageURL copy]
                                                             date:dateB
                                                             task:taskB
                                                              uri:uriB
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should not be equal when the user URI is different", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";

            uriA = @"uri";
            uriB = @"uri";
            userUriA = @"user-uri";
            userUriB = @"not-that-user-uri";

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:userUriA
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:uriA
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:userUriB
                                                         imageURL:[imageURL copy]
                                                             date:dateB
                                                             task:taskB
                                                              uri:uriB
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should not be equal when all members are equal except for date", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:101];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:nil
                                                         imageURL:[imageURL copy]
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should be equal when all members are equal and there are two nil dates", ^{
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:nil
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:nil
                                                         imageURL:[imageURL copy]
                                                             date:nil
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should equal(punchB);
        });

        it(@"should be equal when all members are equal and there are two nil locations", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:nil
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:nil
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:nil
                                                         imageURL:[imageURL copy]
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should equal(punchB);
        });

        it(@"should be equal when all member are equal and there are two nil images", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:nil
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:nil
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchA should equal(punchB);
        });

        it(@"should not be equal when all members are equal and there are two nil addresses", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:nil
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:nil
                                                          userURI:nil
                                                         imageURL:[imageURL copy]
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];


            punchA should equal(punchB);
        });

        it(@"should be equal when all members are equal and there are two nil break URIs", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:[imageURL copy]
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];


            punchA should equal(punchB);
        });

        it(@"should be equal when all members are equal and there are two nil break types", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:nil
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:nil
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:[imageURL copy]
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];


            punchA should equal(punchB);
        });

        it(@"should not be equal when all members are equal except for location's latitude", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(60.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchOut
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should not be equal when all members are equal except for location's longitude", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 4.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchOut
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should not be equal when all members are equal except for horizontal accuracy", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.6 verticalAccuracy:-1 timestamp:dateB];
            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchOut
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should not be equal when all members are equal except for address", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"The White House";

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchOut
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should not be equal when all members are equal except for breakUri", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchOut
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should not be equal when all members are equal except for image URL", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];

            NSURL *imageURLA = [NSURL URLWithString:@"http://example.org/A"];
            NSURL *imageURLB = [NSURL URLWithString:@"http://example.org/B"];

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURLA
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURLB
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should equal(punchB);

        });

        it(@"should not be equal when all members are equal except for break type", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];

            NSURL *imageURLA = [NSURL URLWithString:@"http://example.org/A"];
            NSURL *imageURLB = [NSURL URLWithString:@"http://example.org/A"];

            breakTypeA = [[BreakType alloc] initWithName:@"Talk about your feelings break" uri:@"feelings"];

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURLA
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURLB
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should not be equal when all members are equal except for Activity type", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];

            NSURL *imageURLA = [NSURL URLWithString:@"http://example.org/A"];
            NSURL *imageURLB = [NSURL URLWithString:@"http://example.org/A"];

            activityB = [[Activity alloc] initWithName:@"Talk about your feelings break" uri:@"feelings"];

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURLA
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURLB
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should not be equal when all members are equal except for Project type", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];

            NSURL *imageURLA = [NSURL URLWithString:@"http://example.org/A"];
            NSURL *imageURLB = [NSURL URLWithString:@"http://example.org/A"];

            ProjectType *projectC = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"New Project" uri:@"new uri"];

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURLA
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectC
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURLB
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should not be equal when all members are equal except for Client type", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];

            NSURL *imageURLA = [NSURL URLWithString:@"http://example.org/A"];
            NSURL *imageURLB = [NSURL URLWithString:@"http://example.org/A"];

            ClientType *clientC = [[ClientType alloc]initWithName:@"New Client" uri:@"new uri"];

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURLA
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientC
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURLB
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should not be equal when all members are equal except for Task type", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];

            NSURL *imageURLA = [NSURL URLWithString:@"http://example.org/A"];
            NSURL *imageURLB = [NSURL URLWithString:@"http://example.org/A"];

            TaskType *taskC = [[TaskType alloc]initWithProjectUri:nil taskPeriod:nil name:@"New Task" uri:@"new uri"];

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURLA
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURLB
                                                             date:dateB
                                                             task:taskC
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should not be equal when all members are equal except for oefTypes", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:101];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";

            OEFType *oefType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            NSMutableArray *tempOEFTypesArray = [NSMutableArray arrayWithObjects:oefType, nil];

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:tempOEFTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:nil
                                                         imageURL:[imageURL copy]
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should not be equal when one of the punch oeftypes array is nil", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:101];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";


            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:nil
                                                         imageURL:[imageURL copy]
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should be equal when all members are equal and there are two nil oef types", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:101];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";


            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should equal(punchB);
        });
        
        it(@"should not be equal when all members are equal except requestID", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
            
            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(60.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];
            
            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";
            
            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:punchARequestId
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchOut
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationA
                                                       violations:nil
                                                        requestID:punchBRequestId
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            
            punchA should_not equal(punchB);
        });
        
        it(@"should when all members are equal with requestID", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 4.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
            
            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];
            
            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";
            
            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationB
                                                       violations:nil
                                                        requestID:punchARequestId
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:punchARequestId
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            
            punchA should equal(punchB);
        });

    });

    it(@"should implement NSCoding", ^{

        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(50.0, 3.0);
        CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];
        NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];
        NSString *address = @"875 Howard St, San Francisco, CA";
        BreakType *mealBreak = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break"];
        Activity *activity = [[Activity alloc] initWithName:@"Activity" uri:@"uri"];
        ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"Project-Name" uri:@"Project-Uri"];
        ClientType *client = [[ClientType alloc]initWithName:@"Client-Name" uri:@"Client-Uri"];
        TaskType *task = [[TaskType alloc]initWithProjectUri:nil taskPeriod:nil name:@"Task-Name" uri:@"Task-Uri"];

        OEFType *oefType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
        NSMutableArray *oefTypesArray = [NSMutableArray arrayWithObjects:oefType, nil];
        NSString*requestID = [[NSUUID UUID] UUIDString];
        RemotePunch *punchToBeEncoded = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                              nonActionedValidations:0
                                                                 previousPunchStatus:Ticking
                                                                     nextPunchStatus:Ticking
                                                                       sourceOfPunch:UnknownSourceOfPunch
                                                                          actionType:PunchActionTypePunchIn
                                                                       oefTypesArray:oefTypesArray
                                                                        lastSyncTime:NULL
                                                                             project:project
                                                                         auditHstory:nil
                                                                           breakType:mealBreak
                                                                            location:location
                                                                          violations:nil
                                                                           requestID:requestID
                                                                            activity:activity
                                                                            duration:nil
                                                                              client:client
                                                                             address:address
                                                                             userURI:@"test user URI"
                                                                            imageURL:imageURL
                                                                                date:[NSDate date]
                                                                                task:task
                                                                                 uri:@"testuri"
                                                                isTimeEntryAvailable:NO
                                                                    syncedWithServer:NO
                                                                      isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:punchToBeEncoded];
        RemotePunch *decodedPunch = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        decodedPunch.activity should_not be_nil;
        decodedPunch.project should_not be_nil;
        decodedPunch.client should_not be_nil;
        decodedPunch.task should_not be_nil;
        decodedPunch.oefTypesArray should_not be_nil;
        decodedPunch should equal(punchToBeEncoded);
    });

    describe(@"-copyWithZone:", ^{
        it(@"should return an exact copy of the object", ^{
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(50.0, 3.0);
            CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];
            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];
            BreakType *mealBreak = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break"];
            Activity *activity = [[Activity alloc] initWithName:@"Activity" uri:@"uri"];
            ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"Project-Name" uri:@"Project-Uri"];
            ClientType *client = [[ClientType alloc]initWithName:@"Client-Name" uri:@"Client-Uri"];
            TaskType *task = [[TaskType alloc]initWithProjectUri:nil taskPeriod:nil name:@"Task-Name" uri:@"Task-Uri"];

            OEFType *oefType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            NSMutableArray *oefTypesArray = [NSMutableArray arrayWithObjects:oefType, nil];
            NSString*requestID = [[NSUUID UUID] UUIDString];
            RemotePunch *punchToBeCopied = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Ticking
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:UnknownSourceOfPunch
                                                                             actionType:PunchActionTypePunchIn
                                                                          oefTypesArray:oefTypesArray
                                                                           lastSyncTime:NULL
                                                                                project:project
                                                                            auditHstory:nil
                                                                              breakType:mealBreak
                                                                               location:location
                                                                             violations:nil
                                                                              requestID:requestID
                                                                               activity:activity
                                                                               duration:nil
                                                                                 client:client
                                                                                address:@"My House"
                                                                                userURI:@"test-user-uri"
                                                                               imageURL:imageURL
                                                                                   date:[NSDate date]
                                                                                   task:task
                                                                                    uri:@"test-uri"
                                                                   isTimeEntryAvailable:NO
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            RemotePunch *copiedPunch = [punchToBeCopied copyWithZone:nil];

            copiedPunch should equal(punchToBeCopied);
            copiedPunch should_not be_same_instance_as(punchToBeCopied);
            copiedPunch.location should_not be_same_instance_as(punchToBeCopied.location);
        });
    });

    describe(@"-copy", ^{
        it(@"should return an exact copy of the object", ^{
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(50.0, 3.0);
            CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];
            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];
            BreakType *mealBreak = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break"];
            Activity *activity = [[Activity alloc] initWithName:@"Activity" uri:@"uri"];
            ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"Project-Name" uri:@"Project-Uri"];
            ClientType *client = [[ClientType alloc]initWithName:@"Client-Name" uri:@"Client-Uri"];
            TaskType *task = [[TaskType alloc]initWithProjectUri:nil taskPeriod:nil name:@"Task-Name" uri:@"Task-Uri"];
            
            OEFType *oefType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            NSMutableArray *oefTypesArray = [NSMutableArray arrayWithObjects:oefType, nil];
            NSString*requestID = [[NSUUID UUID] UUIDString];
            RemotePunch *punchToBeCopied = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Ticking
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:UnknownSourceOfPunch
                                                                             actionType:PunchActionTypePunchIn
                                                                          oefTypesArray:oefTypesArray
                                                                           lastSyncTime:NULL
                                                                                project:project
                                                                            auditHstory:nil
                                                                              breakType:mealBreak
                                                                               location:location
                                                                             violations:nil
                                                                              requestID:requestID
                                                                               activity:activity
                                                                               duration:nil
                                                                                 client:client
                                                                                address:@"My House"
                                                                                userURI:@"test-user-uri"
                                                                               imageURL:imageURL
                                                                                   date:[NSDate date]
                                                                                   task:task
                                                                                    uri:@"test-uri"
                                                                   isTimeEntryAvailable:NO
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            
            RemotePunch *copiedPunch = [punchToBeCopied copy];
            
            copiedPunch should equal(punchToBeCopied);
            copiedPunch should_not be_same_instance_as(punchToBeCopied);
            copiedPunch.location should_not be_same_instance_as(punchToBeCopied.location);
        });
    });
});

describe(@"RemotePunch for OEF", ^{
    describe(NSStringFromSelector(@selector(isEqual:)), ^{
        __block RemotePunch *punchA;
        __block RemotePunch *punchB;
        __block NSDate *dateA;
        __block NSDate *dateB;
        __block CLLocation *locationA;
        __block CLLocation *locationB;
        __block NSString *addressA;
        __block NSString *addressB;
        __block BreakType *breakTypeA;
        __block BreakType *breakTypeB;
        __block Activity *activityA;
        __block Activity *activityB;
        __block NSString *uriA;
        __block NSString *uriB;
        __block NSString *userUriA;
        __block NSString *userUriB;
        __block ProjectType *projectA;
        __block ProjectType *projectB;
        __block ClientType *clientA;
        __block ClientType *clientB;
        __block TaskType *taskA;
        __block TaskType *taskB;
        __block NSMutableArray *oefTypesArray;
        __block OEFType *oefType1;
        __block OEFType *oefType2;
        __block OEFType *oefType3;
        __block NSString *punchARequestId;
        __block NSString *punchBRequestId;

        beforeEach(^{
            breakTypeA = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break"];
            breakTypeB = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break"];
            activityA = [[Activity alloc] initWithName:@"Activity" uri:@"some-activity-uri"];
            activityB = [[Activity alloc] initWithName:@"Activity" uri:@"some-activity-uri"];
            projectA = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"Project" uri:@"uri"];
            projectB = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"Project" uri:@"uri"];
            clientA = [[ClientType alloc]initWithName:@"Client" uri:@"uri"];
            clientB = [[ClientType alloc]initWithName:@"Client" uri:@"uri"];
            taskA = [[TaskType alloc]initWithProjectUri:nil taskPeriod:nil name:@"Task" uri:@"uri"];
            taskB = [[TaskType alloc]initWithProjectUri:nil taskPeriod:nil name:@"Task" uri:@"uri"];
            oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
            punchARequestId = [[NSUUID UUID] UUIDString];
            punchBRequestId = [[NSUUID UUID] UUIDString];
        });

        it(@"should not be equal when comparing a different type of object", ^{
            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:nil
                                                      auditHstory:nil
                                                        breakType:nil
                                                         location:nil
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:nil
                                                         duration:nil
                                                           client:nil
                                                          address:nil
                                                          userURI:nil
                                                         imageURL:nil
                                                             date:nil
                                                             task:nil
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchA should_not equal((RemotePunch *)[NSDate date]);
        });

        it(@"should be equal when all members are nil", ^{

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:nil
                                                      auditHstory:nil
                                                        breakType:nil
                                                         location:nil
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:nil
                                                         duration:nil
                                                           client:nil
                                                          address:nil
                                                          userURI:nil
                                                         imageURL:nil
                                                             date:nil
                                                             task:nil
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:nil
                                                      auditHstory:nil
                                                        breakType:nil
                                                         location:nil
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:nil
                                                         duration:nil
                                                           client:nil
                                                          address:nil
                                                          userURI:nil
                                                         imageURL:nil
                                                             date:nil
                                                             task:nil
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should equal(punchB);
        });

        it(@"when all members are equal should be equal", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";

            uriA = @"uri";
            uriB = @"uri";
            userUriA = @"user-uri";
            userUriB = @"user-uri";

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:userUriA
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:uriA
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:userUriB
                                                         imageURL:[imageURL copy]
                                                             date:dateB
                                                             task:taskB
                                                              uri:uriB
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should equal(punchB);
        });

        it(@"should not be equal when the punch URI is different", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";

            uriA = @"uri";
            uriB = @"not-your-uri";
            userUriA = @"user-uri";
            userUriB = @"user-uri";

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:userUriA
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:uriA
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:userUriB
                                                         imageURL:[imageURL copy]
                                                             date:dateB
                                                             task:taskB
                                                              uri:uriB
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should not be equal when the user URI is different", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";

            uriA = @"uri";
            uriB = @"uri";
            userUriA = @"user-uri";
            userUriB = @"not-that-user-uri";

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:userUriA
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:uriA
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:userUriB
                                                         imageURL:[imageURL copy]
                                                             date:dateB
                                                             task:taskB
                                                              uri:uriB
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should not be equal when all members are equal except for date", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:101];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:nil
                                                         imageURL:[imageURL copy]
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should be equal when all members are equal and there are two nil dates", ^{
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:nil
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:nil
                                                         imageURL:[imageURL copy]
                                                             date:nil
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should equal(punchB);
        });

        it(@"should be equal when all members are equal and there are two nil locations", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:nil
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:nil
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:nil
                                                         imageURL:[imageURL copy]
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should equal(punchB);
        });

        it(@"should be equal when all member are equal and there are two nil images", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:nil
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:nil
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchA should equal(punchB);
        });

        it(@"should not be equal when all members are equal and there are two nil addresses", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:nil
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:nil
                                                          userURI:nil
                                                         imageURL:[imageURL copy]
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];


            punchA should equal(punchB);
        });

        it(@"should be equal when all members are equal and there are two nil break URIs", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:[imageURL copy]
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];


            punchA should equal(punchB);
        });

        it(@"should be equal when all members are equal and there are two nil break types", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:nil
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:nil
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:[imageURL copy]
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];


            punchA should equal(punchB);
        });

        it(@"should not be equal when all members are equal except for location's latitude", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(60.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchOut
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should not be equal when all members are equal except for location's longitude", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 4.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchOut
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should not be equal when all members are equal except for horizontal accuracy", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.6 verticalAccuracy:-1 timestamp:dateB];
            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchOut
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should not be equal when all members are equal except for address", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"The White House";

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchOut
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should not be equal when all members are equal except for breakUri", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchOut
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should not be equal when all members are equal except for image URL", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];

            NSURL *imageURLA = [NSURL URLWithString:@"http://example.org/A"];
            NSURL *imageURLB = [NSURL URLWithString:@"http://example.org/B"];

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURLA
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURLB
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should equal(punchB);

        });

        it(@"should not be equal when all members are equal except for OEFTypes are nil for one object", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:@[]
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:nil
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:nil
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should equal(punchB);

        });

        it(@"should not be equal when all members are equal except for break type", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];

            NSURL *imageURLA = [NSURL URLWithString:@"http://example.org/A"];
            NSURL *imageURLB = [NSURL URLWithString:@"http://example.org/A"];

            breakTypeA = [[BreakType alloc] initWithName:@"Talk about your feelings break" uri:@"feelings"];

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURLA
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURLB
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should not be equal when all members are equal except for Activity type", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];

            NSURL *imageURLA = [NSURL URLWithString:@"http://example.org/A"];
            NSURL *imageURLB = [NSURL URLWithString:@"http://example.org/A"];

            activityB = [[Activity alloc] initWithName:@"Talk about your feelings break" uri:@"feelings"];

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURLA
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURLB
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should not be equal when all members are equal except for Project type", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];

            NSURL *imageURLA = [NSURL URLWithString:@"http://example.org/A"];
            NSURL *imageURLB = [NSURL URLWithString:@"http://example.org/A"];

            ProjectType *projectC = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"New Project" uri:@"new uri"];

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURLA
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectC
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURLB
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should not be equal when all members are equal except for Client type", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];

            NSURL *imageURLA = [NSURL URLWithString:@"http://example.org/A"];
            NSURL *imageURLB = [NSURL URLWithString:@"http://example.org/A"];

            ClientType *clientC = [[ClientType alloc]initWithName:@"New Client" uri:@"new uri"];

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURLA
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientC
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURLB
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should not be equal when all members are equal except for Task type", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];

            NSURL *imageURLA = [NSURL URLWithString:@"http://example.org/A"];
            NSURL *imageURLB = [NSURL URLWithString:@"http://example.org/A"];

            TaskType *taskC = [[TaskType alloc]initWithProjectUri:nil taskPeriod:nil name:@"New Task" uri:@"new uri"];

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURLA
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:@"asdf"
                                                          userURI:nil
                                                         imageURL:imageURLB
                                                             date:dateB
                                                             task:taskC
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            punchA should_not equal(punchB);
        });

        it(@"should not be equal when all members are equal except for oefTypes", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:101];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";

            OEFType *oefType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            NSMutableArray *tempOEFTypesArray = [NSMutableArray arrayWithObjects:oefType, nil];

            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:tempOEFTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:nil
                                                         imageURL:[imageURL copy]
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            
            punchA should_not equal(punchB);
        });

        it(@"should not be equal when one of the punch oeftypes array is nil", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:101];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";


            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:nil
                                                         imageURL:[imageURL copy]
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            
            punchA should_not equal(punchB);
        });

        it(@"should be equal when all members are equal and there are two nil oef types", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:101];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];

            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];

            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";


            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:nil
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:NULL
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            
            punchA should equal(punchB);
        });
        
        it(@"should not be equal when all members are equal except requestID", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
            
            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(60.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];
            
            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";
            
            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationA
                                                       violations:nil
                                                        requestID:punchARequestId
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchOut
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationA
                                                       violations:nil
                                                        requestID:punchBRequestId
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            
            punchA should_not equal(punchB);
        });
        
        it(@"should when all members are equal with requestID", ^{
            dateA = [NSDate dateWithTimeIntervalSince1970:100];
            dateB = [NSDate dateWithTimeIntervalSince1970:100];
            CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 4.0);
            locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
            
            CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
            locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];
            
            addressA = @"875 Howard St, San Francisco, CA";
            addressB = @"875 Howard St, San Francisco, CA";
            
            punchA = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectA
                                                      auditHstory:nil
                                                        breakType:breakTypeA
                                                         location:locationB
                                                       violations:nil
                                                        requestID:punchARequestId
                                                         activity:activityA
                                                         duration:nil
                                                           client:clientA
                                                          address:addressA
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateA
                                                             task:taskA
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            punchB = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                           nonActionedValidations:0
                                              previousPunchStatus:Ticking
                                                  nextPunchStatus:Ticking
                                                    sourceOfPunch:UnknownSourceOfPunch
                                                       actionType:PunchActionTypePunchIn
                                                    oefTypesArray:oefTypesArray
                                                     lastSyncTime:NULL
                                                          project:projectB
                                                      auditHstory:nil
                                                        breakType:breakTypeB
                                                         location:locationB
                                                       violations:nil
                                                        requestID:punchARequestId
                                                         activity:activityB
                                                         duration:nil
                                                           client:clientB
                                                          address:addressB
                                                          userURI:nil
                                                         imageURL:imageURL
                                                             date:dateB
                                                             task:taskB
                                                              uri:nil
                                             isTimeEntryAvailable:NO
                                                 syncedWithServer:NO
                                                   isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];
            
            punchA should equal(punchB);
        });

    });

    it(@"should implement NSCoding", ^{

        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(50.0, 3.0);
        CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];
        NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];
        NSString *address = @"875 Howard St, San Francisco, CA";
        BreakType *mealBreak = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break"];
        Activity *activity = [[Activity alloc] initWithName:@"Activity" uri:@"uri"];
        ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"Project-Name" uri:@"Project-Uri"];
        ClientType *client = [[ClientType alloc]initWithName:@"Client-Name" uri:@"Client-Uri"];
        TaskType *task = [[TaskType alloc]initWithProjectUri:nil taskPeriod:nil name:@"Task-Name" uri:@"Task-Uri"];

        OEFType *oefType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
        NSMutableArray *oefTypesArray = [NSMutableArray arrayWithObjects:oefType, nil];
        NSString*requestID = [[NSUUID UUID] UUIDString];
        RemotePunch *punchToBeEncoded = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                              nonActionedValidations:0
                                                                 previousPunchStatus:Ticking
                                                                     nextPunchStatus:Ticking
                                                                       sourceOfPunch:UnknownSourceOfPunch
                                                                          actionType:PunchActionTypePunchIn
                                                                       oefTypesArray:oefTypesArray
                                                                        lastSyncTime:NULL
                                                                             project:project
                                                                         auditHstory:nil
                                                                           breakType:mealBreak
                                                                            location:location
                                                                          violations:nil
                                                                           requestID:requestID
                                                                            activity:activity
                                                                            duration:nil
                                                                              client:client
                                                                             address:address
                                                                             userURI:@"test user URI"
                                                                            imageURL:imageURL
                                                                                date:[NSDate date]
                                                                                task:task
                                                                                 uri:@"testuri"
                                                                isTimeEntryAvailable:NO
                                                                    syncedWithServer:NO
                                                                      isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:punchToBeEncoded];
        RemotePunch *decodedPunch = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        decodedPunch.activity should_not be_nil;
        decodedPunch.project should_not be_nil;
        decodedPunch.client should_not be_nil;
        decodedPunch.task should_not be_nil;
        decodedPunch.oefTypesArray should_not be_nil;
        decodedPunch should equal(punchToBeEncoded);
    });

    describe(@"-copyWithZone:", ^{
        it(@"should return an exact copy of the object", ^{
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(50.0, 3.0);
            CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];
            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];
            BreakType *mealBreak = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break"];
            Activity *activity = [[Activity alloc] initWithName:@"Activity" uri:@"uri"];
            ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"Project-Name" uri:@"Project-Uri"];
            ClientType *client = [[ClientType alloc]initWithName:@"Client-Name" uri:@"Client-Uri"];
            TaskType *task = [[TaskType alloc]initWithProjectUri:nil taskPeriod:nil name:@"Task-Name" uri:@"Task-Uri"];

            OEFType *oefType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            NSMutableArray *oefTypesArray = [NSMutableArray arrayWithObjects:oefType, nil];
            NSString*requestID = [[NSUUID UUID] UUIDString];
            RemotePunch *punchToBeCopied = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Ticking
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:UnknownSourceOfPunch
                                                                             actionType:PunchActionTypePunchIn
                                                                          oefTypesArray:oefTypesArray
                                                                           lastSyncTime:NULL
                                                                                project:project
                                                                            auditHstory:nil
                                                                              breakType:mealBreak
                                                                               location:location
                                                                             violations:nil
                                                                              requestID:requestID
                                                                               activity:activity
                                                                               duration:nil
                                                                                 client:client
                                                                                address:@"My House"
                                                                                userURI:@"test-user-uri"
                                                                               imageURL:imageURL
                                                                                   date:[NSDate date]
                                                                                   task:task
                                                                                    uri:@"test-uri"
                                                                   isTimeEntryAvailable:NO
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            RemotePunch *copiedPunch = [punchToBeCopied copyWithZone:nil];

            copiedPunch should equal(punchToBeCopied);
            copiedPunch should_not be_same_instance_as(punchToBeCopied);
            copiedPunch.location should_not be_same_instance_as(punchToBeCopied.location);
        });
    });

    describe(@"-copy", ^{
        it(@"should return an exact copy of the object", ^{
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(50.0, 3.0);
            CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];
            NSURL *imageURL = [NSURL URLWithString:@"http://example.org/fake"];
            BreakType *mealBreak = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break"];
            Activity *activity = [[Activity alloc] initWithName:@"Activity" uri:@"uri"];
            ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"Project-Name" uri:@"Project-Uri"];
            ClientType *client = [[ClientType alloc]initWithName:@"Client-Name" uri:@"Client-Uri"];
            TaskType *task = [[TaskType alloc]initWithProjectUri:nil taskPeriod:nil name:@"Task-Name" uri:@"Task-Uri"];

            OEFType *oefType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            NSMutableArray *oefTypesArray = [NSMutableArray arrayWithObjects:oefType, nil];
            NSString*requestID = [[NSUUID UUID] UUIDString];
            RemotePunch *punchToBeCopied = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                 nonActionedValidations:0
                                                                    previousPunchStatus:Ticking
                                                                        nextPunchStatus:Ticking
                                                                          sourceOfPunch:UnknownSourceOfPunch
                                                                             actionType:PunchActionTypePunchIn
                                                                          oefTypesArray:oefTypesArray
                                                                           lastSyncTime:NULL
                                                                                project:project
                                                                            auditHstory:nil
                                                                              breakType:mealBreak
                                                                               location:location
                                                                             violations:nil
                                                                              requestID:requestID
                                                                               activity:activity
                                                                               duration:nil
                                                                                 client:client
                                                                                address:@"My House"
                                                                                userURI:@"test-user-uri"
                                                                               imageURL:imageURL
                                                                                   date:[NSDate date]
                                                                                   task:task
                                                                                    uri:@"test-uri"
                                                                   isTimeEntryAvailable:NO
                                                                       syncedWithServer:NO
                                                                         isMissingPunch:NO
                                          previousPunchActionType:PunchActionTypeUnknown];

            RemotePunch *copiedPunch = [punchToBeCopied copy];

            copiedPunch should equal(punchToBeCopied);
            copiedPunch should_not be_same_instance_as(punchToBeCopied);
            copiedPunch.location should_not be_same_instance_as(punchToBeCopied.location);
        });
    });
});

SPEC_END
