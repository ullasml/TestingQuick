#import <MacTypes.h>
#import <Cedar/Cedar.h>
#import "PunchSerializer.h"
#import "LocalPunch.h"
#import "BreakType.h"
#import "Constants.h"
#import "OfflineLocalPunch.h"
#import "RemotePunch.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "Activity.h"
#import "OEFType.h"
#import "Enum.h"
#import "PunchActionTypes.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PunchSerializerSpec)

describe(@"PunchSerializer", ^{
    __block PunchSerializer *subject;

    beforeEach(^{
        subject = [[PunchSerializer alloc] init];
    });

    describe(@"-timePunchDictionaryForPunch:", ^{
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
        __block NSDictionary *requestBody;

        context(@"with nothing but date and action", ^{
            beforeEach(^{
                LocalPunch *punch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"ABCD1234" activity:nil client:nil oefTypes:nil address:nil userURI:@"some:user:uri" image:nil task:nil date:date];

                requestBody = [subject timePunchDictionaryForPunch:punch];
            });

            it(@"should send a correctly configured request to the client", ^{
                requestBody should equal(@{
                                           @"timePunch": @{
                                                   @"user": @{@"uri": @"some:user:uri"},
                                                   @"punchTime": @{
                                                           @"year": @1970,
                                                           @"month": @1,
                                                           @"day": @1,
                                                           @"hour": @0,
                                                           @"minute": @0,
                                                           @"second": @0,
                                                           @"timeZoneUri": @"urn:replicon:time-zone:Etc/GMT"
                                                           },
                                                   @"actionUri": @"urn:replicon:time-punch-action:out",
                                                   },
                                           @"deviceConnectivityStatusUri": @"urn:replicon:device-connectivity-status:online",
                                           @"isAuthenticTimePunch":@1,
                                           @"parameterCorrelationId":@"ABCD1234",
                                           @"audit": @{
                                                   @"timePunchAgent": [NSNull null],
                                                   @"geolocation": [NSNull null],
                                                   @"auditImageProvisioningIntentUri": @"urn:replicon:time-punch-audit-image-provisioning-intent:no-image",
                                                   @"auditImage": [NSNull null]
                                                   }
                                           });
            });
        });

        context(@"with nothing but date, action (start break), break uri", ^{
            beforeEach(^{
                BreakType *breakType = [[BreakType alloc] initWithName:@"Meal" uri:@"break-uri"];
                LocalPunch *punch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeStartBreak lastSyncTime:NULL breakType:breakType location:nil project:nil requestID:@"ABCD1234" activity:nil client:nil oefTypes:nil address:nil userURI:@"some:user:uri" image:nil task:nil date:date];
                requestBody = [subject timePunchDictionaryForPunch:punch];
            });

            it(@"should send a correctly configured request to the client", ^{
                requestBody should equal(@{
                                           @"timePunch": @{
                                                   @"user": @{@"uri": @"some:user:uri"},
                                                   @"punchTime": @{
                                                           @"year": @1970,
                                                           @"month": @1,
                                                           @"day": @1,
                                                           @"hour": @0,
                                                           @"minute": @0,
                                                           @"second": @0,
                                                           @"timeZoneUri": @"urn:replicon:time-zone:Etc/GMT"
                                                           },
                                                   @"actionUri": @"urn:replicon:time-punch-action:start-break",
                                                   @"punchStartBreakAttributes": @{@"breakType": @{@"uri": @"break-uri"}},
                                                   },
                                           @"deviceConnectivityStatusUri": @"urn:replicon:device-connectivity-status:online",
                                           @"isAuthenticTimePunch":@1,
                                           @"parameterCorrelationId":@"ABCD1234",
                                           @"audit": @{
                                                   @"timePunchAgent": [NSNull null],
                                                   @"geolocation": [NSNull null],
                                                   @"auditImageProvisioningIntentUri": @"urn:replicon:time-punch-audit-image-provisioning-intent:no-image",
                                                   @"auditImage": [NSNull null]
                                                   }
                                           });
            });
        });

        context(@"with nothing but date, action (transfer), break uri", ^{
            beforeEach(^{
                LocalPunch *punch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypeTransfer lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"ABCD1234" activity:nil client:nil oefTypes:nil address:nil userURI:@"some:user:uri" image:nil task:nil date:date];
                requestBody = [subject timePunchDictionaryForPunch:punch];
            });

            it(@"should send a correctly configured request to the client", ^{
                requestBody should equal(@{
                                           @"timePunch": @{
                                                   @"user": @{@"uri": @"some:user:uri"},
                                                   @"punchTime": @{
                                                           @"year": @1970,
                                                           @"month": @1,
                                                           @"day": @1,
                                                           @"hour": @0,
                                                           @"minute": @0,
                                                           @"second": @0,
                                                           @"timeZoneUri": @"urn:replicon:time-zone:Etc/GMT"
                                                           },
                                                   @"actionUri": @"urn:replicon:time-punch-action:transfer",
                                                   },
                                           @"deviceConnectivityStatusUri": @"urn:replicon:device-connectivity-status:online",
                                           @"isAuthenticTimePunch":@1,
                                           @"parameterCorrelationId":@"ABCD1234",
                                           @"audit": @{
                                                   @"timePunchAgent": [NSNull null],
                                                   @"geolocation": [NSNull null],
                                                   @"auditImageProvisioningIntentUri": @"urn:replicon:time-punch-audit-image-provisioning-intent:no-image",
                                                   @"auditImage": [NSNull null]
                                                   }
                                           });
            });
        });

        context(@"with just an image", ^{
            __block UIImage *image;

            beforeEach(^{
                image = [UIImage imageNamed:ExpensesImageUp];
                LocalPunch *punch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"ABCD1234" activity:nil client:nil oefTypes:nil address:nil userURI:@"some:user:uri" image:image task:nil date:date];
                requestBody = [subject timePunchDictionaryForPunch:punch];
            });

            it(@"should send a correctly configured request to the client", ^{
                requestBody should equal(@{
                                           @"timePunch": @{
                                                   @"user": @{@"uri": @"some:user:uri"},
                                                   @"punchTime": @{
                                                           @"year": @1970,
                                                           @"month": @1,
                                                           @"day": @1,
                                                           @"hour": @0,
                                                           @"minute": @0,
                                                           @"second": @0,
                                                           @"timeZoneUri": @"urn:replicon:time-zone:Etc/GMT"
                                                           },
                                                   @"actionUri": @"urn:replicon:time-punch-action:in",
                                                   },
                                           @"deviceConnectivityStatusUri": @"urn:replicon:device-connectivity-status:online",
                                           @"isAuthenticTimePunch":@1,
                                           @"parameterCorrelationId":@"ABCD1234",
                                           @"audit": @{
                                                   @"timePunchAgent": [NSNull null],
                                                   @"geolocation": [NSNull null],
                                                   @"auditImageProvisioningIntentUri": @"urn:replicon:time-punch-audit-image-provisioning-intent:image-provided",
                                                   @"auditImage": @{@"image": @{
                                                                            @"base64ImageData": [UIImageJPEGRepresentation(image, 1.0) base64EncodedStringWithOptions:0],
                                                                            @"mimeType": @"image/jpeg"
                                                                            },
                                                                    @"imageUri": [NSNull null]}
                                                   }
                                           });
            });
        });

        context(@"with just a location", ^{
            __block CLLocation *location;
            beforeEach(^{
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(38.89768, -77.03653);
                CLLocationAccuracy horizontalAccuracy = 12.5;
                CLLocationAccuracy verticalAccuracy = -1;

                location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:0 horizontalAccuracy:horizontalAccuracy verticalAccuracy:verticalAccuracy timestamp:[NSDate date]];
                LocalPunch *punch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:nil location:location project:nil requestID:@"ABCD1234" activity:nil client:nil oefTypes:nil address:nil userURI:@"some:user:uri" image:nil task:nil date:date];
                requestBody = [subject timePunchDictionaryForPunch:punch];
            });

            it(@"should send a correctly configured request to the client", ^{
                requestBody should equal(@{@"timePunch": @{
                                                   @"user": @{@"uri": @"some:user:uri"},
                                                   @"punchTime": @{
                                                           @"year": @1970,
                                                           @"month": @1,
                                                           @"day": @1,
                                                           @"hour": @0,
                                                           @"minute": @0,
                                                           @"second": @0,
                                                           @"timeZoneUri": @"urn:replicon:time-zone:Etc/GMT"
                                                           },
                                                   @"actionUri": @"urn:replicon:time-punch-action:out",
                                                   },
                                           @"deviceConnectivityStatusUri": @"urn:replicon:device-connectivity-status:online",
                                           @"isAuthenticTimePunch":@1,
                                           @"parameterCorrelationId":@"ABCD1234",
                                           @"audit": @{
                                                   @"timePunchAgent": [NSNull null],
                                                   @"geolocation": @{
                                                           @"gps": @{
                                                                   @"latitudeInDegrees": @(38.89768),
                                                                   @"longitudeInDegrees": @(-77.03653),
                                                                   @"accuracyInMeters": @(12.5)
                                                                   },
                                                           @"address": @"address unavailable"
                                                           },
                                                   @"auditImageProvisioningIntentUri": @"urn:replicon:time-punch-audit-image-provisioning-intent:no-image",
                                                   @"auditImage": [NSNull null]
                                                   }
                                           });
            });
        });

        context(@"with just location and address (no image)", ^{
            __block CLLocation *location;

            beforeEach(^{
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(38.89768, -77.03653);
                CLLocationAccuracy horizontalAccuracy = 12.5;
                CLLocationAccuracy verticalAccuracy = -1;

                location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:0 horizontalAccuracy:horizontalAccuracy verticalAccuracy:verticalAccuracy timestamp:[NSDate date]];
                LocalPunch *punch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:nil location:location project:nil requestID:@"ABCD1234" activity:nil client:nil oefTypes:nil address:@"The White House" userURI:@"some:user:uri" image:nil task:nil date:date];

                requestBody = [subject timePunchDictionaryForPunch:punch];
            });

            it(@"should send a correctly configured request to the client", ^{
                requestBody should equal(@{
                                           @"timePunch": @{
                                                   @"user": @{@"uri": @"some:user:uri"},
                                                   @"punchTime": @{
                                                           @"year": @1970,
                                                           @"month": @1,
                                                           @"day": @1,
                                                           @"hour": @0,
                                                           @"minute": @0,
                                                           @"second": @0,
                                                           @"timeZoneUri": @"urn:replicon:time-zone:Etc/GMT"
                                                           },
                                                   @"actionUri": @"urn:replicon:time-punch-action:out",
                                                   },
                                           @"deviceConnectivityStatusUri": @"urn:replicon:device-connectivity-status:online",
                                           @"isAuthenticTimePunch":@1,
                                           @"parameterCorrelationId":@"ABCD1234",
                                           @"audit": @{
                                                   @"timePunchAgent": [NSNull null],
                                                   @"geolocation": @{
                                                           @"gps": @{
                                                                   @"latitudeInDegrees": @(38.89768),
                                                                   @"longitudeInDegrees": @(-77.03653),
                                                                   @"accuracyInMeters": @(12.5)
                                                                   },
                                                           @"address": @"The White House"
                                                           },
                                                   @"auditImageProvisioningIntentUri": @"urn:replicon:time-punch-audit-image-provisioning-intent:no-image",
                                                   @"auditImage": [NSNull null]
                                                   }
                                           });
            });
        });

        context(@"with just location and image (no address)", ^{
            __block UIImage *image;

            beforeEach(^{
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(38.89768, -77.03653);
                CLLocationAccuracy horizontalAccuracy = 12.5;
                CLLocationAccuracy verticalAccuracy = -1;

                CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:0 horizontalAccuracy:horizontalAccuracy verticalAccuracy:verticalAccuracy timestamp:[NSDate date]];

                image = [UIImage imageNamed:ApprovalsImageUp];
                LocalPunch *punch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:nil location:location project:nil requestID:@"ABCD1234" activity:nil client:nil oefTypes:nil address:nil userURI:@"some:user:uri" image:image task:nil date:date];
                requestBody = [subject timePunchDictionaryForPunch:punch];
            });

            it(@"should send a correctly configured request to the client", ^{
                requestBody should equal(@{
                                           @"timePunch": @{
                                                   @"user": @{@"uri": @"some:user:uri"},
                                                   @"punchTime": @{
                                                           @"year": @1970,
                                                           @"month": @1,
                                                           @"day": @1,
                                                           @"hour": @0,
                                                           @"minute": @0,
                                                           @"second": @0,
                                                           @"timeZoneUri": @"urn:replicon:time-zone:Etc/GMT"
                                                           },
                                                   @"actionUri": @"urn:replicon:time-punch-action:out",
                                                   },
                                           @"deviceConnectivityStatusUri": @"urn:replicon:device-connectivity-status:online",
                                           @"isAuthenticTimePunch":@1,
                                           @"parameterCorrelationId":@"ABCD1234",
                                           @"audit": @{
                                                   @"timePunchAgent": [NSNull null],
                                                   @"geolocation": @{
                                                           @"gps": @{
                                                                   @"latitudeInDegrees": @(38.89768),
                                                                   @"longitudeInDegrees": @(-77.03653),
                                                                   @"accuracyInMeters": @(12.5)
                                                                   },
                                                           @"address": @"address unavailable"
                                                           },
                                                   @"auditImageProvisioningIntentUri": @"urn:replicon:time-punch-audit-image-provisioning-intent:image-provided",
                                                   @"auditImage": @{@"image": @{
                                                                            @"base64ImageData": [UIImageJPEGRepresentation(image, 1.0) base64EncodedStringWithOptions:0],
                                                                            @"mimeType": @"image/jpeg"
                                                                            },
                                                                    @"imageUri": [NSNull null]}
                                                   }
                                           });
            });
        });

        context(@"with an image, location, and address", ^{
            __block UIImage *image;

            beforeEach(^{
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(38.89768, -77.03653);
                CLLocationAccuracy horizontalAccuracy = 12.5;
                CLLocationAccuracy verticalAccuracy = -1;

                CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:0 horizontalAccuracy:horizontalAccuracy verticalAccuracy:verticalAccuracy timestamp:[NSDate date]];

                image = [UIImage imageNamed:ApprovalsImageUp];
                LocalPunch *punch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:nil location:location project:nil requestID:@"ABCD1234" activity:nil client:nil oefTypes:nil address:@"10 Downing Street" userURI:@"some:user:uri" image:image task:nil date:date];
                requestBody = [subject timePunchDictionaryForPunch:punch];
            });

            it(@"should send a correctly configured request to the client", ^{
                requestBody should equal(@{@"timePunch": @{
                                                   @"user": @{@"uri": @"some:user:uri"},
                                                   @"punchTime": @{
                                                           @"year": @1970,
                                                           @"month": @1,
                                                           @"day": @1,
                                                           @"hour": @0,
                                                           @"minute": @0,
                                                           @"second": @0,
                                                           @"timeZoneUri": @"urn:replicon:time-zone:Etc/GMT"
                                                           },
                                                   @"actionUri": @"urn:replicon:time-punch-action:out",
                                                   },
                                           @"deviceConnectivityStatusUri": @"urn:replicon:device-connectivity-status:online",
                                           @"isAuthenticTimePunch":@1,
                                           @"parameterCorrelationId":@"ABCD1234",
                                           @"audit": @{
                                                   @"timePunchAgent": [NSNull null],
                                                   @"geolocation": @{
                                                           @"gps": @{
                                                                   @"latitudeInDegrees": @(38.89768),
                                                                   @"longitudeInDegrees": @(-77.03653),
                                                                   @"accuracyInMeters": @(12.5)
                                                                   },
                                                           @"address": @"10 Downing Street"
                                                           },
                                                   @"auditImageProvisioningIntentUri": @"urn:replicon:time-punch-audit-image-provisioning-intent:image-provided",
                                                   @"auditImage": @{@"image": @{
                                                                            @"base64ImageData": [UIImageJPEGRepresentation(image, 1.0) base64EncodedStringWithOptions:0],
                                                                            @"mimeType": @"image/jpeg"
                                                                            },
                                                                    @"imageUri": [NSNull null]}
                                                   }
                                           });
            });
        });

        context(@"with a RemotePunch", ^{
            it(@"should return a correctly configured dictionary", ^{
                NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:0];

                BreakType *breakType = [[BreakType alloc] initWithName:@"Break Type Name" uri:@"break-type-uri"];

                CLLocation *location = [[CLLocation alloc] initWithLatitude:12.0 longitude:34.0];

                NSURL *imageURL = [NSURL URLWithString:@"http://example.com/image.jpg"];

                RemotePunch *punch = [[RemotePunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus)
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
                                                                         location:location
                                                                       violations:nil
                                                                        requestID:@"ABCD1234"
                                                                         activity:NULL
                                                                         duration:nil
                                                                           client:NULL
                                                                          address:@"My Special Address"
                                                                          userURI:@"My Special User's URI"
                                                                         imageURL:imageURL
                                                                             date:date
                                                                             task:NULL
                                                                              uri:@"My Special URI"
                                                             isTimeEntryAvailable:NO
                                                                 syncedWithServer:NO
                                                                   isMissingPunch:NO
                                                          previousPunchActionType:PunchActionTypeUnknown];

                NSDictionary *punchDictionary = [subject timePunchDictionaryForPunch:punch];

                NSDictionary *expectedDictionary = @{
                                                     @"audit": @{
                                                             @"auditImage": [NSNull null],
                                                             @"auditImageProvisioningIntentUri": @"urn:replicon:time-punch-audit-image-provisioning-intent:no-image",
                                                             @"geolocation": @{
                                                                     @"address": @"My Special Address",
                                                                     @"gps": @{
                                                                             @"accuracyInMeters": @0,
                                                                             @"latitudeInDegrees": @12,
                                                                             @"longitudeInDegrees": @34
                                                                             }
                                                                     },
                                                             @"timePunchAgent": [NSNull null]
                                                             },
                                                     @"deviceConnectivityStatusUri": @"urn:replicon:device-connectivity-status:online",
                                                     @"isAuthenticTimePunch":@0,
                                                     @"parameterCorrelationId":@"ABCD1234",
                                                     @"timePunch": @{
                                                             @"actionUri": @"urn:replicon:time-punch-action:start-break",
                                                             @"punchStartBreakAttributes": @{
                                                                     @"breakType": @{
                                                                             @"uri": @"break-type-uri"
                                                                             }
                                                                     },
                                                             @"punchTime": @{
                                                                     @"day": @1,
                                                                     @"hour": @0,
                                                                     @"minute": @0,
                                                                     @"month": @1,
                                                                     @"second": @0,
                                                                     @"timeZoneUri": @"urn:replicon:time-zone:Etc/GMT",
                                                                     @"year": @2001
                                                                     },
                                                             @"user": @{
                                                                     @"uri": @"My Special User's URI",
                                                                     }
                                                             }
                                                     };

                punchDictionary should equal(expectedDictionary);
            });
        });

        context(@"with nothing but project", ^{
            beforeEach(^{
                ProjectType *projectType = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO
                                                                              isTimeAllocationAllowed:NO
                                                                                        projectPeriod:nil
                                                                                           clientType:nil
                                                                                                 name:@"project-name"
                                                                                                  uri:@"project-uri"];
                LocalPunch *punch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:projectType requestID:@"ABCD1234" activity:nil client:nil oefTypes:nil address:nil userURI:@"some:user:uri" image:nil task:nil date:date];
                requestBody = [subject timePunchDictionaryForPunch:punch];


            });

            it(@"should send a correctly configured request to the client", ^{
                requestBody should equal(@{
                                           @"timePunch": @{
                                                   @"user": @{@"uri": @"some:user:uri"},
                                                   @"punchTime": @{
                                                           @"year": @1970,
                                                           @"month": @1,
                                                           @"day": @1,
                                                           @"hour": @0,
                                                           @"minute": @0,
                                                           @"second": @0,
                                                           @"timeZoneUri": @"urn:replicon:time-zone:Etc/GMT"
                                                           },
                                                   @"actionUri": @"urn:replicon:time-punch-action:in",
                                                   @"punchInAttributes": @{@"project": @{@"uri": @"project-uri", @"displayText":@"project-name"}},
                                                   },
                                           @"deviceConnectivityStatusUri": @"urn:replicon:device-connectivity-status:online",
                                           @"isAuthenticTimePunch":@1,
                                           @"parameterCorrelationId":@"ABCD1234",
                                           @"audit": @{
                                                   @"timePunchAgent": [NSNull null],
                                                   @"geolocation": [NSNull null],
                                                   @"auditImageProvisioningIntentUri": @"urn:replicon:time-punch-audit-image-provisioning-intent:no-image",
                                                   @"auditImage": [NSNull null]
                                                   }
                                           });
            });
        });

        context(@"with nothing but task", ^{
            beforeEach(^{
                TaskType *taskType = [[TaskType alloc] initWithProjectUri:nil
                                                                taskPeriod:nil
                                                                      name:@"task-name"
                                                                       uri:@"task-uri"];
                LocalPunch *punch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"ABCD1234" activity:nil client:nil oefTypes:nil address:nil userURI:@"some:user:uri" image:nil task:taskType date:date];
                requestBody = [subject timePunchDictionaryForPunch:punch];
            });

            it(@"should send a correctly configured request to the client", ^{
                requestBody should equal(@{
                                           @"timePunch": @{
                                                   @"user": @{@"uri": @"some:user:uri"},
                                                   @"punchTime": @{
                                                           @"year": @1970,
                                                           @"month": @1,
                                                           @"day": @1,
                                                           @"hour": @0,
                                                           @"minute": @0,
                                                           @"second": @0,
                                                           @"timeZoneUri": @"urn:replicon:time-zone:Etc/GMT"
                                                           },
                                                   @"actionUri": @"urn:replicon:time-punch-action:in",
                                                   @"punchInAttributes": @{@"task": @{@"uri": @"task-uri", @"displayText":@"task-name"}},
                                                   },
                                           @"deviceConnectivityStatusUri": @"urn:replicon:device-connectivity-status:online",
                                           @"isAuthenticTimePunch":@1,
                                           @"parameterCorrelationId":@"ABCD1234",
                                           @"audit": @{
                                                   @"timePunchAgent": [NSNull null],
                                                   @"geolocation": [NSNull null],
                                                   @"auditImageProvisioningIntentUri": @"urn:replicon:time-punch-audit-image-provisioning-intent:no-image",
                                                   @"auditImage": [NSNull null]
                                                   }
                                           });
            });
        });

        context(@"with nothing but activity", ^{

            beforeEach(^{
                Activity *activity = [[Activity alloc] initWithName:@"activity-name" uri:@"activity-uri"];

                LocalPunch *punch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"ABCD1234" activity:activity client:nil oefTypes:nil address:nil userURI:@"some:user:uri" image:nil task:nil date:date];
                requestBody = [subject timePunchDictionaryForPunch:punch];
            });

            it(@"should send a correctly configured request to the client", ^{
                requestBody should equal(@{
                                           @"timePunch": @{
                                                   @"user": @{@"uri": @"some:user:uri"},
                                                   @"punchTime": @{
                                                           @"year": @1970,
                                                           @"month": @1,
                                                           @"day": @1,
                                                           @"hour": @0,
                                                           @"minute": @0,
                                                           @"second": @0,
                                                           @"timeZoneUri": @"urn:replicon:time-zone:Etc/GMT"
                                                           },
                                                   @"actionUri": @"urn:replicon:time-punch-action:in",
                                                   @"punchInAttributes": @{@"activity": @{@"uri": @"activity-uri"}}
                                                   },
                                           @"deviceConnectivityStatusUri": @"urn:replicon:device-connectivity-status:online",
                                           @"isAuthenticTimePunch":@1,
                                           @"parameterCorrelationId":@"ABCD1234",
                                           @"audit": @{
                                                   @"timePunchAgent": [NSNull null],
                                                   @"geolocation": [NSNull null],
                                                   @"auditImageProvisioningIntentUri": @"urn:replicon:time-punch-audit-image-provisioning-intent:no-image",
                                                   @"auditImage": [NSNull null]
                                                   }
                                           });
            });
        });

        context(@"with nothing but project and task", ^{
            beforeEach(^{
                ProjectType *projectType = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"project-name"
                                                                                                    uri:@"project-uri"];

                TaskType *taskType = [[TaskType alloc] initWithProjectUri:nil
                                                               taskPeriod:nil
                                                                     name:@"task-name"
                                                                      uri:@"task-uri"];
                LocalPunch *punch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:projectType requestID:@"ABCD1234" activity:nil client:nil oefTypes:nil address:nil userURI:@"some:user:uri" image:nil task:taskType date:date];
                requestBody = [subject timePunchDictionaryForPunch:punch];


            });

            it(@"should send a correctly configured request to the client", ^{
                requestBody should equal(@{
                                           @"timePunch": @{
                                                   @"user": @{@"uri": @"some:user:uri"},
                                                   @"punchTime": @{
                                                           @"year": @1970,
                                                           @"month": @1,
                                                           @"day": @1,
                                                           @"hour": @0,
                                                           @"minute": @0,
                                                           @"second": @0,
                                                           @"timeZoneUri": @"urn:replicon:time-zone:Etc/GMT"
                                                           },
                                                   @"actionUri": @"urn:replicon:time-punch-action:in",
                                                   @"punchInAttributes": @{
                                                           @"project": @{@"uri": @"project-uri",
                                                                         @"displayText":@"project-name"},
                                                           @"task": @{@"uri": @"task-uri",
                                                                      @"displayText":@"task-name"},
                                                           }
                                                   },
                                           @"deviceConnectivityStatusUri": @"urn:replicon:device-connectivity-status:online",
                                           @"isAuthenticTimePunch":@1,
                                           @"parameterCorrelationId":@"ABCD1234",
                                           @"audit": @{
                                                   @"timePunchAgent": [NSNull null],
                                                   @"geolocation": [NSNull null],
                                                   @"auditImageProvisioningIntentUri": @"urn:replicon:time-punch-audit-image-provisioning-intent:no-image",
                                                   @"auditImage": [NSNull null]
                                                   }
                                           });
            });
        });

        context(@"with nothing but oef", ^{
            beforeEach(^{
                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"dipta number" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"dipta text" punchActionType:@"PunchIn" numericValue:nil textValue:@"value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                OEFType *oefType3 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:a6996497-e0c4-4d7c-bddf-8e828df8d623" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"generic oef - prompt" punchActionType:@"PunchIn" numericValue:@"56.789" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                OEFType *oefType4 = [[OEFType alloc] initWithUri:@"some-uri2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text oef 1" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                OEFType *oefType5 = [[OEFType alloc] initWithUri:@"some-uri-dropdown" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:@"dropdown-option-uri-1" dropdownOptionValue:@"test dropdpwn value" collectAtTimeOfPunch:YES disabled:NO];

                LocalPunch *punch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"ABCD1234" activity:nil client:nil oefTypes:@[oefType1, oefType2, oefType3, oefType4, oefType5] address:nil userURI:@"some:user:uri" image:nil task:nil date:date];
                requestBody = [subject timePunchDictionaryForPunch:punch];


            });

            it(@"should send a correctly configured request to the client", ^{
                requestBody should equal(@{
                                           @"timePunch": @{
                                                   @"user": @{@"uri": @"some:user:uri"},
                                                   @"punchTime": @{
                                                           @"year": @1970,
                                                           @"month": @1,
                                                           @"day": @1,
                                                           @"hour": @0,
                                                           @"minute": @0,
                                                           @"second": @0,
                                                           @"timeZoneUri": @"urn:replicon:time-zone:Etc/GMT"
                                                           },
                                                   @"actionUri": @"urn:replicon:time-punch-action:in",

                                                   @"extensionFieldValues": @[@{@"definition":@{@"uri":@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af"},@"textValue":@"value 1"},@{@"definition":@{@"uri":@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:a6996497-e0c4-4d7c-bddf-8e828df8d623"},@"numericValue":@"56.789"},@{@"definition":@{@"uri":@"some-uri-dropdown"},@"tag":@{@"uri":@"dropdown-option-uri-1"}}]
                                                   },
                                           @"deviceConnectivityStatusUri": @"urn:replicon:device-connectivity-status:online",
                                           @"isAuthenticTimePunch":@1,
                                        @"parameterCorrelationId":@"ABCD1234",
                                           @"audit": @{
                                                   @"timePunchAgent": [NSNull null],
                                                   @"geolocation": [NSNull null],
                                                   @"auditImageProvisioningIntentUri": @"urn:replicon:time-punch-audit-image-provisioning-intent:no-image",
                                                   @"auditImage": [NSNull null]
                                                   }
                                           });
            });
        });

        context(@"with nothing but activity and oef", ^{
            __block NSArray *oefTypesArray;
            beforeEach(^{
                Activity *activity = [[Activity alloc] initWithName:@"activity-name" uri:@"activity-uri"];
                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"dipta number" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"dipta text" punchActionType:@"PunchIn" numericValue:nil textValue:@"value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                OEFType *oefType3 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:a6996497-e0c4-4d7c-bddf-8e828df8d623" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"generic oef - prompt" punchActionType:@"PunchIn" numericValue:@"56.789" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                OEFType *oefType4 = [[OEFType alloc] initWithUri:@"some-uri2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text oef 1" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                OEFType *oefType5 = [[OEFType alloc] initWithUri:@"some-uri-dropdown" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:@"dropdown-option-uri-1" dropdownOptionValue:@"test dropdpwn value" collectAtTimeOfPunch:YES disabled:NO];
                oefTypesArray = @[oefType1,oefType2,oefType3,oefType4,oefType5];
                LocalPunch *punch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"ABCD1234" activity:activity client:nil oefTypes:oefTypesArray address:nil userURI:@"some:user:uri" image:nil task:nil date:date];
                requestBody = [subject timePunchDictionaryForPunch:punch];
            });

            it(@"should send a correctly configured request to the client", ^{
                requestBody should equal(@{
                                           @"timePunch": @{
                                                   @"user": @{@"uri": @"some:user:uri"},
                                                   @"punchTime": @{
                                                           @"year": @1970,
                                                           @"month": @1,
                                                           @"day": @1,
                                                           @"hour": @0,
                                                           @"minute": @0,
                                                           @"second": @0,
                                                           @"timeZoneUri": @"urn:replicon:time-zone:Etc/GMT"
                                                           },
                                                   @"actionUri": @"urn:replicon:time-punch-action:in",
                                                   @"punchInAttributes": @{@"activity": @{@"uri": @"activity-uri"}},
                                                   @"extensionFieldValues": @[@{@"definition":@{@"uri":@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af"},@"textValue":@"value 1"},@{@"definition":@{@"uri":@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:a6996497-e0c4-4d7c-bddf-8e828df8d623"},@"numericValue":@"56.789"},@{@"definition":@{@"uri":@"some-uri-dropdown"},@"tag":@{@"uri":@"dropdown-option-uri-1"}}]
                                                   },
                                           @"deviceConnectivityStatusUri": @"urn:replicon:device-connectivity-status:online",
                                           @"isAuthenticTimePunch":@1,
                                           @"parameterCorrelationId":@"ABCD1234",
                                           @"audit": @{
                                                   @"timePunchAgent": [NSNull null],
                                                   @"geolocation": [NSNull null],
                                                   @"auditImageProvisioningIntentUri": @"urn:replicon:time-punch-audit-image-provisioning-intent:no-image",
                                                   @"auditImage": [NSNull null]
                                                   }
                                           });
            });
        });

        context(@"with nothing but project and task and oef", ^{
            beforeEach(^{
                ProjectType *projectType = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO
                                                                                isTimeAllocationAllowed:NO
                                                                                          projectPeriod:nil
                                                                                             clientType:nil
                                                                                                   name:@"project-name"
                                                                                                    uri:@"project-uri"];

                TaskType *taskType = [[TaskType alloc] initWithProjectUri:nil
                                                               taskPeriod:nil
                                                                     name:@"task-name"
                                                                      uri:@"task-uri"];

                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"dipta number" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"dipta text" punchActionType:@"PunchIn" numericValue:nil textValue:@"value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                OEFType *oefType3 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:a6996497-e0c4-4d7c-bddf-8e828df8d623" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"generic oef - prompt" punchActionType:@"PunchIn" numericValue:@"56.789" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                 OEFType *oefType4 = [[OEFType alloc] initWithUri:@"some-uri2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text oef 1" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                OEFType *oefType5 = [[OEFType alloc] initWithUri:@"some-uri-dropdown" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-tag" name:@"dropdown oef 1" punchActionType:@"PunchIn" numericValue:nil textValue:nil dropdownOptionUri:@"dropdown-option-uri-1" dropdownOptionValue:@"test dropdpwn value" collectAtTimeOfPunch:YES disabled:NO];
                 NSArray *oefTypesArray = @[oefType1,oefType2,oefType3,oefType4,oefType5];

                LocalPunch *punch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:projectType requestID:@"ABCD1234" activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:@"some:user:uri" image:nil task:taskType date:date];
                requestBody = [subject timePunchDictionaryForPunch:punch];


            });

            it(@"should send a correctly configured request to the client", ^{
                requestBody should equal(@{
                                           @"timePunch": @{
                                                   @"user": @{@"uri": @"some:user:uri"},
                                                   @"punchTime": @{
                                                           @"year": @1970,
                                                           @"month": @1,
                                                           @"day": @1,
                                                           @"hour": @0,
                                                           @"minute": @0,
                                                           @"second": @0,
                                                           @"timeZoneUri": @"urn:replicon:time-zone:Etc/GMT"
                                                           },
                                                   @"actionUri": @"urn:replicon:time-punch-action:in",
                                                   @"punchInAttributes": @{
                                                           @"project": @{@"uri": @"project-uri", @"displayText":@"project-name"},
                                                           @"task": @{@"uri": @"task-uri",
                                                                      @"displayText":@"task-name"},
                                                           },
                                                   @"extensionFieldValues": @[@{@"definition":@{@"uri":@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af"},@"textValue":@"value 1"},@{@"definition":@{@"uri":@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:a6996497-e0c4-4d7c-bddf-8e828df8d623"},@"numericValue":@"56.789"},@{@"definition":@{@"uri":@"some-uri-dropdown"},@"tag":@{@"uri":@"dropdown-option-uri-1"}}]
                                                   },

                                           @"deviceConnectivityStatusUri": @"urn:replicon:device-connectivity-status:online",
                                           @"isAuthenticTimePunch":@1,
                                           @"parameterCorrelationId":@"ABCD1234",
                                           @"audit": @{
                                                   @"timePunchAgent": [NSNull null],
                                                   @"geolocation": [NSNull null],
                                                   @"auditImageProvisioningIntentUri": @"urn:replicon:time-punch-audit-image-provisioning-intent:no-image",
                                                   @"auditImage": [NSNull null]
                                                   }
                                           });
            });
        });

        context(@"with null request id", ^{

            beforeEach(^{


                LocalPunch *punch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:@"some:user:uri" image:nil task:nil date:date];
                requestBody = [subject timePunchDictionaryForPunch:punch];
            });

            it(@"should send a correctly configured request to the client", ^{
                requestBody should equal(@{
                                           @"timePunch": @{
                                                   @"user": @{@"uri": @"some:user:uri"},
                                                   @"punchTime": @{
                                                           @"year": @1970,
                                                           @"month": @1,
                                                           @"day": @1,
                                                           @"hour": @0,
                                                           @"minute": @0,
                                                           @"second": @0,
                                                           @"timeZoneUri": @"urn:replicon:time-zone:Etc/GMT"
                                                           },
                                                   @"actionUri": @"urn:replicon:time-punch-action:in",

                                                   },
                                           @"deviceConnectivityStatusUri": @"urn:replicon:device-connectivity-status:online",
                                           @"isAuthenticTimePunch":@1,
                                           @"parameterCorrelationId":[NSNull null],
                                           @"audit": @{
                                                   @"timePunchAgent": [NSNull null],
                                                   @"geolocation": [NSNull null],
                                                   @"auditImageProvisioningIntentUri": @"urn:replicon:time-punch-audit-image-provisioning-intent:no-image",
                                                   @"auditImage": [NSNull null]
                                                   }
                                           });
            });
        });

        context(@"with OEF values as an empty string", ^{
            beforeEach(^{
                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"dipta number" punchActionType:@"PunchIn" numericValue:@"" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"dipta text" punchActionType:@"PunchIn" numericValue:nil textValue:@"" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];


                LocalPunch *punch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"ABCD1234" activity:nil client:nil oefTypes:@[oefType1, oefType2] address:nil userURI:@"some:user:uri" image:nil task:nil date:date];
                requestBody = [subject timePunchDictionaryForPunch:punch];


            });

            it(@"should send a correctly configured request to the client", ^{
                requestBody should equal(@{
                                           @"timePunch": @{
                                                   @"user": @{@"uri": @"some:user:uri"},
                                                   @"punchTime": @{
                                                           @"year": @1970,
                                                           @"month": @1,
                                                           @"day": @1,
                                                           @"hour": @0,
                                                           @"minute": @0,
                                                           @"second": @0,
                                                           @"timeZoneUri": @"urn:replicon:time-zone:Etc/GMT"
                                                           },
                                                   @"actionUri": @"urn:replicon:time-punch-action:in"
                                                   },
                                           @"deviceConnectivityStatusUri": @"urn:replicon:device-connectivity-status:online",
                                           @"isAuthenticTimePunch":@1,
                                           @"parameterCorrelationId":@"ABCD1234",
                                           @"audit": @{
                                                   @"timePunchAgent": [NSNull null],
                                                   @"geolocation": [NSNull null],
                                                   @"auditImageProvisioningIntentUri": @"urn:replicon:time-punch-audit-image-provisioning-intent:no-image",
                                                   @"auditImage": [NSNull null]
                                                   }
                                           });
            });
        });

        context(@"with OEF values as an empty string and one filled OEF", ^{
            beforeEach(^{
                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:fa7f2605-6aa1-465f-ad78-34cdb72f623f" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"dipta number" punchActionType:@"PunchIn" numericValue:@"" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:0d0aaee4-acfe-4c26-9823-138e019a48af" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"dipta text" punchActionType:@"PunchIn" numericValue:nil textValue:@"" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                OEFType *oefType3 = [[OEFType alloc] initWithUri:@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:a6996497-e0c4-4d7c-bddf-8e828df8d623" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"generic oef - prompt" punchActionType:@"PunchIn" numericValue:@"56.789" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];

                LocalPunch *punch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:@"ABCD1234" activity:nil client:nil oefTypes:@[oefType1, oefType2, oefType3] address:nil userURI:@"some:user:uri" image:nil task:nil date:date];
                requestBody = [subject timePunchDictionaryForPunch:punch];


            });

            it(@"should send a correctly configured request to the client", ^{
                requestBody should equal(@{
                                           @"timePunch": @{
                                                   @"user": @{@"uri": @"some:user:uri"},
                                                   @"punchTime": @{
                                                           @"year": @1970,
                                                           @"month": @1,
                                                           @"day": @1,
                                                           @"hour": @0,
                                                           @"minute": @0,
                                                           @"second": @0,
                                                           @"timeZoneUri": @"urn:replicon:time-zone:Etc/GMT"
                                                           },
                                                   @"actionUri": @"urn:replicon:time-punch-action:in",
                                                   @"extensionFieldValues": @[@{@"definition":@{@"uri":@"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:a6996497-e0c4-4d7c-bddf-8e828df8d623"},@"numericValue":@"56.789"}]
                                                   },
                                           @"deviceConnectivityStatusUri": @"urn:replicon:device-connectivity-status:online",
                                           @"isAuthenticTimePunch":@1,
                                           @"parameterCorrelationId":@"ABCD1234",
                                           @"audit": @{
                                                   @"timePunchAgent": [NSNull null],
                                                   @"geolocation": [NSNull null],
                                                   @"auditImageProvisioningIntentUri": @"urn:replicon:time-punch-audit-image-provisioning-intent:no-image",
                                                   @"auditImage": [NSNull null]
                                                   }
                                           });
            });
        });
    });
});

SPEC_END
