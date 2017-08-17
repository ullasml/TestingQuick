#import <Cedar/Cedar.h>
#import "LocalSQLPunchSerializer.h"
#import "LocalPunch.h"
#import "Constants.h"
#import "OfflineLocalPunch.h"
#import "ClientType.h"
#import "TaskType.h"
#import "ProjectType.h"
#import "Activity.h"
#import "OEFType.h"
#import "Enum.h"
#import "PunchActionTypes.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(LocalSQLPunchSerializerSpec)

describe(@"LocalSQLPunchSerializer", ^{
    __block LocalSQLPunchSerializer *subject;

    beforeEach(^{
        subject = [[LocalSQLPunchSerializer alloc] init];
    });

    describe(@" without OEF -serializePunchForStorage:", ^{

        context(@"when the punch has a null image", ^{
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
                LocalPunch *localPunch = [[LocalPunch alloc]
                                                      initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                   actionType:PunchActionTypePunchIn
                                                                 lastSyncTime:[NSDate date]
                                                                    breakType:nil
                                                                     location:nil
                                                                      project:nil
                                                                    requestID:NULL
                                                                     activity:nil
                                                                       client:nil
                                                                     oefTypes:nil
                                                                      address:nil
                                                                      userURI:@"some-user"
                                                                        image:(id) [NSNull null]
                                                                         task:nil
                                                                         date:date];
                punchDictionary = [subject serializePunchForStorage:localPunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should_not be_nil;
            });
        });

        context(@"when the punch has a nil optional values", ^{
            __block NSDictionary *punchDictionary;
            __block NSDate *date;
            beforeEach(^{
                date = [NSDate dateWithTimeIntervalSince1970:0];
                LocalPunch *localPunch = [[LocalPunch alloc]
                                                      initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                                   actionType:PunchActionTypePunchIn
                                                                 lastSyncTime:date
                                                                    breakType:nil
                                                                     location:nil
                                                                      project:nil
                                                                    requestID:@"ABCD1234"
                                                                     activity:nil
                                                                       client:nil
                                                                     oefTypes:nil
                                                                      address:nil
                                                                      userURI:@"some-user"
                                                                        image:nil
                                                                         task:nil
                                                                         date:date];
                punchDictionary = [subject serializePunchForStorage:localPunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary[@"location_latitude"] should be_nil;
                punchDictionary[@"location_longitude"] should be_nil;
                punchDictionary[@"location_horizontal_accuracy"] should be_nil;
                punchDictionary[@"break_type_name"] should be_nil;
                punchDictionary[@"break_type_uri"] should be_nil;
                punchDictionary[@"address"] should be_nil;
                punchDictionary[@"image"] should be_nil;
                punchDictionary[@"punchSyncStatus"] should equal(@(UnsubmittedSyncStatus));
                punchDictionary[@"lastSyncTime"] should equal(date);
                punchDictionary[@"request_id"] should equal(@"ABCD1234");
            });
        });

        context(@"when the punch has a non - nil optional values", ^{
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                ClientType *client = nice_fake_for([ClientType class]);
                client stub_method(@selector(name)).and_return(@"client-name");
                client stub_method(@selector(uri)).and_return(@"client-uri");

                ProjectType *project = nice_fake_for([ProjectType class]);
                project stub_method(@selector(name)).and_return(@"project-name");
                project stub_method(@selector(uri)).and_return(@"project-uri");

                TaskType *task = nice_fake_for([TaskType class]);
                task stub_method(@selector(name)).and_return(@"task-name");
                task stub_method(@selector(uri)).and_return(@"task-uri");

                NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
                LocalPunch *localPunch = [[LocalPunch alloc]
                                                      initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                   actionType:PunchActionTypePunchIn
                                                                 lastSyncTime:[NSDate date]
                                                                    breakType:nil
                                                                     location:nil
                                                                      project:project
                                                                    requestID:@"ABCD1234"
                                                                     activity:nil
                                                                       client:client
                                                                     oefTypes:nil
                                                                      address:nil
                                                                      userURI:@"some-user"
                                                                        image:nil
                                                                         task:task
                                                                         date:date];
                punchDictionary = [subject serializePunchForStorage:localPunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary[@"location_latitude"] should be_nil;
                punchDictionary[@"location_longitude"] should be_nil;
                punchDictionary[@"location_horizontal_accuracy"] should be_nil;
                punchDictionary[@"break_type_name"] should be_nil;
                punchDictionary[@"break_type_uri"] should be_nil;
                punchDictionary[@"address"] should be_nil;
                punchDictionary[@"image"] should be_nil;
                punchDictionary[@"client_name"] should equal(@"client-name");
                punchDictionary[@"client_uri"] should equal( @"client-uri");
                punchDictionary[@"project_name"] should equal( @"project-name");
                punchDictionary[@"project_uri"] should equal(@"project-uri");
                punchDictionary[@"task_name"] should equal(@"task-name");
                punchDictionary[@"task_uri"] should equal(@"task-uri");
                punchDictionary[@"punchSyncStatus"] should equal(@(UnsubmittedSyncStatus));
                punchDictionary[@"request_id"] should equal(@"ABCD1234");
            });
        });
        
        context(@"when the punch has a nil uri for client", ^{
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                ClientType *client = nice_fake_for([ClientType class]);
                client stub_method(@selector(name)).and_return(@"client-name");
                client stub_method(@selector(uri)).and_return(nil);
                
                ProjectType *project = nice_fake_for([ProjectType class]);
                project stub_method(@selector(name)).and_return(@"project-name");
                project stub_method(@selector(uri)).and_return(@"project-uri");
                
                TaskType *task = nice_fake_for([TaskType class]);
                task stub_method(@selector(name)).and_return(@"task-name");
                task stub_method(@selector(uri)).and_return(@"task-uri");
                
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
                LocalPunch *localPunch = [[LocalPunch alloc]
                                                      initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                                   actionType:PunchActionTypePunchIn
                                                                 lastSyncTime:[NSDate date]
                                                                    breakType:nil
                                                                     location:nil
                                                                      project:project
                                                                    requestID:NULL
                                                                     activity:nil
                                                                       client:client
                                                                     oefTypes:nil
                                                                      address:nil
                                                                      userURI:@"some-user"
                                                                        image:nil
                                                                         task:task
                                                                         date:date];
                punchDictionary = [subject serializePunchForStorage:localPunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary[@"location_latitude"] should be_nil;
                punchDictionary[@"location_longitude"] should be_nil;
                punchDictionary[@"location_horizontal_accuracy"] should be_nil;
                punchDictionary[@"break_type_name"] should be_nil;
                punchDictionary[@"break_type_uri"] should be_nil;
                punchDictionary[@"address"] should be_nil;
                punchDictionary[@"image"] should be_nil;
                punchDictionary[@"project_name"] should equal( @"project-name");
                punchDictionary[@"project_uri"] should equal(@"project-uri");
                punchDictionary[@"task_name"] should equal(@"task-name");
                punchDictionary[@"task_uri"] should equal(@"task-uri");
                punchDictionary[@"punchSyncStatus"] should equal(@(UnsubmittedSyncStatus));
            });
        });
        
        context(@"when the punch has a nil uri for project", ^{
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                ClientType *client = nice_fake_for([ClientType class]);
                client stub_method(@selector(name)).and_return(@"client-name");
                client stub_method(@selector(uri)).and_return(@"client-uri");
                
                ProjectType *project = nice_fake_for([ProjectType class]);
                project stub_method(@selector(name)).and_return(@"project-name");
                project stub_method(@selector(uri)).and_return(nil);
                
                TaskType *task = nice_fake_for([TaskType class]);
                task stub_method(@selector(name)).and_return(@"task-name");
                task stub_method(@selector(uri)).and_return(@"task-uri");
                
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
                LocalPunch *localPunch = [[LocalPunch alloc]
                                                      initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                                   actionType:PunchActionTypePunchIn
                                                                 lastSyncTime:[NSDate date]
                                                                    breakType:nil
                                                                     location:nil
                                                                      project:project
                                                                    requestID:NULL
                                                                     activity:nil
                                                                       client:client
                                                                     oefTypes:nil
                                                                      address:nil
                                                                      userURI:@"some-user"
                                                                        image:nil
                                                                         task:task
                                                                         date:date];
                punchDictionary = [subject serializePunchForStorage:localPunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary[@"location_latitude"] should be_nil;
                punchDictionary[@"location_longitude"] should be_nil;
                punchDictionary[@"location_horizontal_accuracy"] should be_nil;
                punchDictionary[@"break_type_name"] should be_nil;
                punchDictionary[@"break_type_uri"] should be_nil;
                punchDictionary[@"address"] should be_nil;
                punchDictionary[@"image"] should be_nil;
                punchDictionary[@"client_name"] should equal(@"client-name");
                punchDictionary[@"client_uri"] should equal( @"client-uri");
                punchDictionary[@"task_name"] should equal(@"task-name");
                punchDictionary[@"task_uri"] should equal(@"task-uri");
                punchDictionary[@"punchSyncStatus"] should equal(@(UnsubmittedSyncStatus));
            });
        });

        context(@"when the punch has a nil uri for task", ^{
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                ClientType *client = nice_fake_for([ClientType class]);
                client stub_method(@selector(name)).and_return(@"client-name");
                client stub_method(@selector(uri)).and_return(@"client-uri");
                
                ProjectType *project = nice_fake_for([ProjectType class]);
                project stub_method(@selector(name)).and_return(@"project-name");
                project stub_method(@selector(uri)).and_return(@"project-uri");
                
                TaskType *task = nice_fake_for([TaskType class]);
                task stub_method(@selector(name)).and_return(@"task-name");
                task stub_method(@selector(uri)).and_return(nil);
                
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
                LocalPunch *localPunch = [[LocalPunch alloc]
                                                      initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                                   actionType:PunchActionTypePunchIn
                                                                 lastSyncTime:[NSDate date]
                                                                    breakType:nil
                                                                     location:nil
                                                                      project:project
                                                                    requestID:NULL
                                                                     activity:nil
                                                                       client:client
                                                                     oefTypes:nil
                                                                      address:nil
                                                                      userURI:@"some-user"
                                                                        image:nil
                                                                         task:task
                                                                         date:date];
                punchDictionary = [subject serializePunchForStorage:localPunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary[@"location_latitude"] should be_nil;
                punchDictionary[@"location_longitude"] should be_nil;
                punchDictionary[@"location_horizontal_accuracy"] should be_nil;
                punchDictionary[@"break_type_name"] should be_nil;
                punchDictionary[@"break_type_uri"] should be_nil;
                punchDictionary[@"address"] should be_nil;
                punchDictionary[@"image"] should be_nil;
                punchDictionary[@"client_name"] should equal(@"client-name");
                punchDictionary[@"client_uri"] should equal( @"client-uri");
                punchDictionary[@"project_name"] should equal( @"project-name");
                punchDictionary[@"project_uri"] should equal(@"project-uri");
                punchDictionary[@"punchSyncStatus"] should equal(@(UnsubmittedSyncStatus));
            });
        });

        
        context(@"when the punch has activity values", ^{
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                Activity *activity = nice_fake_for([Activity class]);
                activity stub_method(@selector(name)).and_return(@"activity-name");
                activity stub_method(@selector(uri)).and_return(@"activity-uri");
                
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
                LocalPunch *localPunch = [[LocalPunch alloc]
                                                      initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                                   actionType:PunchActionTypePunchIn
                                                                 lastSyncTime:nil
                                                                    breakType:nil
                                                                     location:nil
                                                                      project:nil
                                                                    requestID:NULL
                                                                     activity:activity
                                                                       client:nil
                                                                     oefTypes:nil
                                                                      address:nil
                                                                      userURI:@"some-user"
                                                                        image:nil
                                                                         task:nil
                                                                         date:date];
                punchDictionary = [subject serializePunchForStorage:localPunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary[@"location_latitude"] should be_nil;
                punchDictionary[@"location_longitude"] should be_nil;
                punchDictionary[@"location_horizontal_accuracy"] should be_nil;
                punchDictionary[@"break_type_name"] should be_nil;
                punchDictionary[@"break_type_uri"] should be_nil;
                punchDictionary[@"address"] should be_nil;
                punchDictionary[@"image"] should be_nil;
                punchDictionary[@"activity_name"] should equal(@"activity-name");
                punchDictionary[@"activity_uri"] should equal( @"activity-uri");
                punchDictionary[@"punchSyncStatus"] should equal(@(UnsubmittedSyncStatus));
                punchDictionary[@"lastSyncTime"] should be_nil;
            });
        });
        
        context(@"when the punch has a nil uri for activity", ^{
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                Activity *activity = nice_fake_for([Activity class]);
                activity stub_method(@selector(name)).and_return(@"activity-name");
                activity stub_method(@selector(uri)).and_return(nil);
                
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
                LocalPunch *localPunch = [[LocalPunch alloc]
                                                      initWithPunchSyncStatus:UnsubmittedSyncStatus
                                                                   actionType:PunchActionTypePunchIn
                                                                 lastSyncTime:[NSDate date]
                                                                    breakType:nil
                                                                     location:nil
                                                                      project:nil
                                                                    requestID:NULL
                                                                     activity:activity
                                                                       client:nil
                                                                     oefTypes:nil
                                                                      address:nil
                                                                      userURI:@"some-user"
                                                                        image:nil
                                                                         task:nil
                                                                         date:date];
                punchDictionary = [subject serializePunchForStorage:localPunch];
            });
            
            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary[@"location_latitude"] should be_nil;
                punchDictionary[@"location_longitude"] should be_nil;
                punchDictionary[@"location_horizontal_accuracy"] should be_nil;
                punchDictionary[@"break_type_name"] should be_nil;
                punchDictionary[@"break_type_uri"] should be_nil;
                punchDictionary[@"address"] should be_nil;
                punchDictionary[@"image"] should be_nil;
                punchDictionary[@"punchSyncStatus"] should equal(@(UnsubmittedSyncStatus));
            });
        });

        context(@"when the punch has oefs", ^{
            __block NSDictionary *punchDictionary;
            __block NSArray *oefTypesArr;
            beforeEach(^{
                OEFType *oefType = [[OEFType alloc] initWithUri:@"some-uri" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                oefTypesArr = @[oefType];

                NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
                LocalPunch *localPunch = [[LocalPunch alloc]
                                                      initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                   actionType:PunchActionTypePunchIn
                                                                 lastSyncTime:[NSDate date]
                                                                    breakType:nil
                                                                     location:nil
                                                                      project:nil
                                                                    requestID:NULL
                                                                     activity:nil
                                                                       client:nil
                                                                     oefTypes:oefTypesArr
                                                                      address:nil
                                                                      userURI:@"some-user"
                                                                        image:nil
                                                                         task:nil
                                                                         date:date];
                punchDictionary = [subject serializePunchForStorage:localPunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary[@"location_latitude"] should be_nil;
                punchDictionary[@"location_longitude"] should be_nil;
                punchDictionary[@"location_horizontal_accuracy"] should be_nil;
                punchDictionary[@"break_type_name"] should be_nil;
                punchDictionary[@"break_type_uri"] should be_nil;
                punchDictionary[@"address"] should be_nil;
                punchDictionary[@"image"] should be_nil;

                punchDictionary[@"punchSyncStatus"] should equal(@(UnsubmittedSyncStatus));
            });
        });


        context(@"when the punch is a manual punch", ^{
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
                OfflineLocalPunch *localPunch = [[OfflineLocalPunch alloc]
                                                                    initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                                 actionType:PunchActionTypePunchIn
                                                                               lastSyncTime:[NSDate date]
                                                                                  breakType:nil
                                                                                   location:nil
                                                                                    project:nil
                                                                                  requestID:NULL
                                                                                   activity:nil
                                                                                     client:nil
                                                                                   oefTypes:nil
                                                                                    address:nil
                                                                                    userURI:@"some-user"
                                                                                      image:nil
                                                                                       task:nil
                                                                                       date:date];
                punchDictionary = [subject serializePunchForStorage:localPunch];
            });

            it(@"should return the manual local punch in dictionary form, ready to write to SQLite", ^{
                [punchDictionary[@"offline"] boolValue] should be_truthy;
            });
        });

        context(@"when the punch is a non-manual punch", ^{
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
                LocalPunch *localPunch = [[LocalPunch alloc]
                                                      initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                   actionType:PunchActionTypePunchIn
                                                                 lastSyncTime:[NSDate date]
                                                                    breakType:nil
                                                                     location:nil
                                                                      project:nil
                                                                    requestID:NULL
                                                                     activity:nil
                                                                       client:nil
                                                                     oefTypes:nil
                                                                      address:nil
                                                                      userURI:@"some-user"
                                                                        image:nil
                                                                         task:nil
                                                                         date:date];
                punchDictionary = [subject serializePunchForStorage:localPunch];
            });

            it(@"should return the manual local punch in dictionary form, ready to write to SQLite", ^{
                [punchDictionary[@"offline"] boolValue] should_not be_truthy;
            });
        });
    });

    describe(@" with OEF -serializePunchForStorage:", ^{

        context(@"when the punch has a null image", ^{
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                NSArray *oefTypesArr = @[oefType1, oefType2];


                LocalPunch *localPunch = [[LocalPunch alloc]
                                                      initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                   actionType:PunchActionTypePunchIn
                                                                 lastSyncTime:[NSDate date]
                                                                    breakType:nil
                                                                     location:nil
                                                                      project:nil
                                                                    requestID:NULL
                                                                     activity:nil
                                                                       client:nil
                                                                     oefTypes:oefTypesArr
                                                                      address:nil
                                                                      userURI:@"some-user"
                                                                        image:(id) [NSNull null]
                                                                         task:nil
                                                                         date:date];
                punchDictionary = [subject serializePunchForStorage:localPunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary should_not be_nil;
            });
        });

        context(@"when the punch has a nil optional values", ^{
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                NSArray *oefTypesArr = @[oefType1, oefType2];
                LocalPunch *localPunch = [[LocalPunch alloc]
                                                      initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                   actionType:PunchActionTypePunchIn
                                                                 lastSyncTime:[NSDate date]
                                                                    breakType:nil
                                                                     location:nil
                                                                      project:nil
                                                                    requestID:NULL
                                                                     activity:nil
                                                                       client:nil
                                                                     oefTypes:oefTypesArr
                                                                      address:nil
                                                                      userURI:@"some-user"
                                                                        image:nil
                                                                         task:nil
                                                                         date:date];
                punchDictionary = [subject serializePunchForStorage:localPunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary[@"location_latitude"] should be_nil;
                punchDictionary[@"location_longitude"] should be_nil;
                punchDictionary[@"location_horizontal_accuracy"] should be_nil;
                punchDictionary[@"break_type_name"] should be_nil;
                punchDictionary[@"break_type_uri"] should be_nil;
                punchDictionary[@"address"] should be_nil;
                punchDictionary[@"punchSyncStatus"] should equal(@(UnsubmittedSyncStatus));
            });
        });

        context(@"when the punch has a non - nil optional values", ^{
            __block NSDictionary *punchDictionary;
            __block NSArray *oefTypesArr;
            beforeEach(^{
                ClientType *client = nice_fake_for([ClientType class]);
                client stub_method(@selector(name)).and_return(@"client-name");
                client stub_method(@selector(uri)).and_return(@"client-uri");

                ProjectType *project = nice_fake_for([ProjectType class]);
                project stub_method(@selector(name)).and_return(@"project-name");
                project stub_method(@selector(uri)).and_return(@"project-uri");

                TaskType *task = nice_fake_for([TaskType class]);
                task stub_method(@selector(name)).and_return(@"task-name");
                task stub_method(@selector(uri)).and_return(@"task-uri");

                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                oefTypesArr = @[oefType1, oefType2];

                NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
                LocalPunch *localPunch = [[LocalPunch alloc]
                                                      initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                   actionType:PunchActionTypePunchIn
                                                                 lastSyncTime:[NSDate date]
                                                                    breakType:nil
                                                                     location:nil
                                                                      project:project
                                                                    requestID:NULL
                                                                     activity:nil
                                                                       client:client
                                                                     oefTypes:oefTypesArr
                                                                      address:nil
                                                                      userURI:@"some-user"
                                                                        image:nil
                                                                         task:task
                                                                         date:date];
                punchDictionary = [subject serializePunchForStorage:localPunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary[@"location_latitude"] should be_nil;
                punchDictionary[@"location_longitude"] should be_nil;
                punchDictionary[@"location_horizontal_accuracy"] should be_nil;
                punchDictionary[@"break_type_name"] should be_nil;
                punchDictionary[@"break_type_uri"] should be_nil;
                punchDictionary[@"address"] should be_nil;
                punchDictionary[@"image"] should be_nil;
                punchDictionary[@"client_name"] should equal(@"client-name");
                punchDictionary[@"client_uri"] should equal( @"client-uri");
                punchDictionary[@"project_name"] should equal( @"project-name");
                punchDictionary[@"project_uri"] should equal(@"project-uri");
                punchDictionary[@"task_name"] should equal(@"task-name");
                punchDictionary[@"task_uri"] should equal(@"task-uri");
                punchDictionary[@"punchSyncStatus"] should equal(@(UnsubmittedSyncStatus));
            });
        });

        context(@"when the punch has a nil uri for client", ^{
            __block NSDictionary *punchDictionary;
            __block NSArray *oefTypesArr;
            beforeEach(^{
                ClientType *client = nice_fake_for([ClientType class]);
                client stub_method(@selector(name)).and_return(@"client-name");
                client stub_method(@selector(uri)).and_return(nil);

                ProjectType *project = nice_fake_for([ProjectType class]);
                project stub_method(@selector(name)).and_return(@"project-name");
                project stub_method(@selector(uri)).and_return(@"project-uri");

                TaskType *task = nice_fake_for([TaskType class]);
                task stub_method(@selector(name)).and_return(@"task-name");
                task stub_method(@selector(uri)).and_return(@"task-uri");

                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                oefTypesArr = @[oefType1, oefType2];

                NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
                LocalPunch *localPunch = [[LocalPunch alloc]
                                                      initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                   actionType:PunchActionTypePunchIn
                                                                 lastSyncTime:[NSDate date]
                                                                    breakType:nil
                                                                     location:nil
                                                                      project:project
                                                                    requestID:NULL
                                                                     activity:nil
                                                                       client:client
                                                                     oefTypes:oefTypesArr
                                                                      address:nil
                                                                      userURI:@"some-user"
                                                                        image:nil
                                                                         task:task
                                                                         date:date];
                punchDictionary = [subject serializePunchForStorage:localPunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary[@"location_latitude"] should be_nil;
                punchDictionary[@"location_longitude"] should be_nil;
                punchDictionary[@"location_horizontal_accuracy"] should be_nil;
                punchDictionary[@"break_type_name"] should be_nil;
                punchDictionary[@"break_type_uri"] should be_nil;
                punchDictionary[@"address"] should be_nil;
                punchDictionary[@"image"] should be_nil;
                punchDictionary[@"project_name"] should equal( @"project-name");
                punchDictionary[@"project_uri"] should equal(@"project-uri");
                punchDictionary[@"task_name"] should equal(@"task-name");
                punchDictionary[@"task_uri"] should equal(@"task-uri");
                punchDictionary[@"punchSyncStatus"] should equal(@(UnsubmittedSyncStatus));
            });
        });

        context(@"when the punch has a nil uri for project", ^{
            __block NSDictionary *punchDictionary;
            __block NSArray *oefTypesArr;
            beforeEach(^{
                ClientType *client = nice_fake_for([ClientType class]);
                client stub_method(@selector(name)).and_return(@"client-name");
                client stub_method(@selector(uri)).and_return(@"client-uri");

                ProjectType *project = nice_fake_for([ProjectType class]);
                project stub_method(@selector(name)).and_return(@"project-name");
                project stub_method(@selector(uri)).and_return(nil);

                TaskType *task = nice_fake_for([TaskType class]);
                task stub_method(@selector(name)).and_return(@"task-name");
                task stub_method(@selector(uri)).and_return(@"task-uri");

                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                oefTypesArr = @[oefType1, oefType2];

                NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
                LocalPunch *localPunch = [[LocalPunch alloc]
                                                      initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                   actionType:PunchActionTypePunchIn
                                                                 lastSyncTime:[NSDate date]
                                                                    breakType:nil
                                                                     location:nil
                                                                      project:project
                                                                    requestID:NULL
                                                                     activity:nil
                                                                       client:client
                                                                     oefTypes:oefTypesArr
                                                                      address:nil
                                                                      userURI:@"some-user"
                                                                        image:nil
                                                                         task:task
                                                                         date:date];
                punchDictionary = [subject serializePunchForStorage:localPunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary[@"location_latitude"] should be_nil;
                punchDictionary[@"location_longitude"] should be_nil;
                punchDictionary[@"location_horizontal_accuracy"] should be_nil;
                punchDictionary[@"break_type_name"] should be_nil;
                punchDictionary[@"break_type_uri"] should be_nil;
                punchDictionary[@"address"] should be_nil;
                punchDictionary[@"image"] should be_nil;
                punchDictionary[@"client_name"] should equal(@"client-name");
                punchDictionary[@"client_uri"] should equal( @"client-uri");
                punchDictionary[@"task_name"] should equal(@"task-name");
                punchDictionary[@"task_uri"] should equal(@"task-uri");
                punchDictionary[@"punchSyncStatus"] should equal(@(UnsubmittedSyncStatus));
            });
        });

        context(@"when the punch has a nil uri for task", ^{
            __block NSDictionary *punchDictionary;
            __block NSArray *oefTypesArr;
            beforeEach(^{
                ClientType *client = nice_fake_for([ClientType class]);
                client stub_method(@selector(name)).and_return(@"client-name");
                client stub_method(@selector(uri)).and_return(@"client-uri");

                ProjectType *project = nice_fake_for([ProjectType class]);
                project stub_method(@selector(name)).and_return(@"project-name");
                project stub_method(@selector(uri)).and_return(@"project-uri");

                TaskType *task = nice_fake_for([TaskType class]);
                task stub_method(@selector(name)).and_return(@"task-name");
                task stub_method(@selector(uri)).and_return(nil);

                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                oefTypesArr = @[oefType1, oefType2];

                NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
                LocalPunch *localPunch = [[LocalPunch alloc]
                                                      initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                   actionType:PunchActionTypePunchIn
                                                                 lastSyncTime:[NSDate date]
                                                                    breakType:nil
                                                                     location:nil
                                                                      project:project
                                                                    requestID:NULL
                                                                     activity:nil
                                                                       client:client
                                                                     oefTypes:oefTypesArr
                                                                      address:nil
                                                                      userURI:@"some-user"
                                                                        image:nil
                                                                         task:task
                                                                         date:date];
                punchDictionary = [subject serializePunchForStorage:localPunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary[@"location_latitude"] should be_nil;
                punchDictionary[@"location_longitude"] should be_nil;
                punchDictionary[@"location_horizontal_accuracy"] should be_nil;
                punchDictionary[@"break_type_name"] should be_nil;
                punchDictionary[@"break_type_uri"] should be_nil;
                punchDictionary[@"address"] should be_nil;
                punchDictionary[@"image"] should be_nil;
                punchDictionary[@"client_name"] should equal(@"client-name");
                punchDictionary[@"client_uri"] should equal( @"client-uri");
                punchDictionary[@"project_name"] should equal( @"project-name");
                punchDictionary[@"project_uri"] should equal(@"project-uri");
                punchDictionary[@"punchSyncStatus"] should equal(@(UnsubmittedSyncStatus));
            });
        });


        context(@"when the punch has activity values", ^{
            __block NSDictionary *punchDictionary;
            __block NSArray *oefTypesArr;
            beforeEach(^{
                Activity *activity = nice_fake_for([Activity class]);
                activity stub_method(@selector(name)).and_return(@"activity-name");
                activity stub_method(@selector(uri)).and_return(@"activity-uri");

                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                oefTypesArr = @[oefType1, oefType2];

                NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
                LocalPunch *localPunch = [[LocalPunch alloc]
                                                      initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                   actionType:PunchActionTypePunchIn
                                                                 lastSyncTime:[NSDate date]
                                                                    breakType:nil
                                                                     location:nil
                                                                      project:nil
                                                                    requestID:NULL
                                                                     activity:activity
                                                                       client:nil
                                                                     oefTypes:oefTypesArr
                                                                      address:nil
                                                                      userURI:@"some-user"
                                                                        image:nil
                                                                         task:nil
                                                                         date:date];
                punchDictionary = [subject serializePunchForStorage:localPunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary[@"location_latitude"] should be_nil;
                punchDictionary[@"location_longitude"] should be_nil;
                punchDictionary[@"location_horizontal_accuracy"] should be_nil;
                punchDictionary[@"break_type_name"] should be_nil;
                punchDictionary[@"break_type_uri"] should be_nil;
                punchDictionary[@"address"] should be_nil;
                punchDictionary[@"image"] should be_nil;
                punchDictionary[@"activity_name"] should equal(@"activity-name");
                punchDictionary[@"activity_uri"] should equal( @"activity-uri");
                punchDictionary[@"punchSyncStatus"] should equal(@(UnsubmittedSyncStatus));
            });
        });

        context(@"when the punch has a nil uri for activity", ^{
            __block NSDictionary *punchDictionary;
            __block NSArray *oefTypesArr;
            beforeEach(^{
                Activity *activity = nice_fake_for([Activity class]);
                activity stub_method(@selector(name)).and_return(@"activity-name");
                activity stub_method(@selector(uri)).and_return(nil);

                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                oefTypesArr = @[oefType1, oefType2];

                NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
                LocalPunch *localPunch = [[LocalPunch alloc]
                                                      initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                   actionType:PunchActionTypePunchIn
                                                                 lastSyncTime:[NSDate date]
                                                                    breakType:nil
                                                                     location:nil
                                                                      project:nil
                                                                    requestID:NULL
                                                                     activity:activity
                                                                       client:nil
                                                                     oefTypes:oefTypesArr
                                                                      address:nil
                                                                      userURI:@"some-user"
                                                                        image:nil
                                                                         task:nil
                                                                         date:date];
                punchDictionary = [subject serializePunchForStorage:localPunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary[@"location_latitude"] should be_nil;
                punchDictionary[@"location_longitude"] should be_nil;
                punchDictionary[@"location_horizontal_accuracy"] should be_nil;
                punchDictionary[@"break_type_name"] should be_nil;
                punchDictionary[@"break_type_uri"] should be_nil;
                punchDictionary[@"address"] should be_nil;
                punchDictionary[@"image"] should be_nil;
                punchDictionary[@"punchSyncStatus"] should equal(@(UnsubmittedSyncStatus));
            });
        });

        context(@"when the punch has oefs", ^{
            __block NSDictionary *punchDictionary;
            __block NSArray *oefTypesArr;
            beforeEach(^{
                OEFType *oefType = [[OEFType alloc] initWithUri:@"some-uri" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                oefTypesArr = @[oefType];

                NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
                LocalPunch *localPunch = [[LocalPunch alloc]
                                                      initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                   actionType:PunchActionTypePunchIn
                                                                 lastSyncTime:[NSDate date]
                                                                    breakType:nil
                                                                     location:nil
                                                                      project:nil
                                                                    requestID:NULL
                                                                     activity:nil
                                                                       client:nil
                                                                     oefTypes:oefTypesArr
                                                                      address:nil
                                                                      userURI:@"some-user"
                                                                        image:nil
                                                                         task:nil
                                                                         date:date];
                punchDictionary = [subject serializePunchForStorage:localPunch];
            });

            it(@"should return the local punch in dictionary form, ready to write to SQLite", ^{
                punchDictionary[@"location_latitude"] should be_nil;
                punchDictionary[@"location_longitude"] should be_nil;
                punchDictionary[@"location_horizontal_accuracy"] should be_nil;
                punchDictionary[@"break_type_name"] should be_nil;
                punchDictionary[@"break_type_uri"] should be_nil;
                punchDictionary[@"address"] should be_nil;
                punchDictionary[@"image"] should be_nil;
                
                punchDictionary[@"punchSyncStatus"] should equal(@(UnsubmittedSyncStatus));
            });
        });


        context(@"when the punch is a manual punch", ^{
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                NSArray *oefTypesArr = @[oefType1, oefType2];
                OfflineLocalPunch *localPunch = [[OfflineLocalPunch alloc]
                                                                    initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                                 actionType:PunchActionTypePunchIn
                                                                               lastSyncTime:[NSDate date]
                                                                                  breakType:nil
                                                                                   location:nil
                                                                                    project:nil
                                                                                  requestID:NULL
                                                                                   activity:nil
                                                                                     client:nil
                                                                                   oefTypes:oefTypesArr
                                                                                    address:nil
                                                                                    userURI:@"some-user"
                                                                                      image:nil
                                                                                       task:nil
                                                                                       date:date];
                punchDictionary = [subject serializePunchForStorage:localPunch];
            });

            it(@"should return the manual local punch in dictionary form, ready to write to SQLite", ^{
                [punchDictionary[@"offline"] boolValue] should be_truthy;
            });
        });

        context(@"when the punch is a non-manual punch", ^{
            __block NSDictionary *punchDictionary;
            beforeEach(^{
                OEFType *oefType1 = [[OEFType alloc] initWithUri:@"some-uri-1" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:@"text value 1" dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];
                OEFType *oefType2 = [[OEFType alloc] initWithUri:@"some-uri-2" definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:@"100.50" textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:YES disabled:NO];

                NSArray *oefTypesArr = @[oefType1, oefType2];
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:0];
                LocalPunch *localPunch = [[LocalPunch alloc]
                                                      initWithPunchSyncStatus:(UnsubmittedSyncStatus)
                                                                   actionType:PunchActionTypePunchIn
                                                                 lastSyncTime:[NSDate date]
                                                                    breakType:nil
                                                                     location:nil
                                                                      project:nil
                                                                    requestID:NULL
                                                                     activity:nil
                                                                       client:nil
                                                                     oefTypes:oefTypesArr
                                                                      address:nil
                                                                      userURI:@"some-user"
                                                                        image:nil
                                                                         task:nil
                                                                         date:date];
                punchDictionary = [subject serializePunchForStorage:localPunch];
            });

            it(@"should return the manual local punch in dictionary form, ready to write to SQLite", ^{
                [punchDictionary[@"offline"] boolValue] should_not be_truthy;
            });
        });
    });
});

SPEC_END
