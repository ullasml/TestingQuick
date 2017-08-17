#import <Cedar/Cedar.h>
#import "PunchAssemblyWorkflow.h"
#import <KSDeferred/KSDeferred.h>
#import "LocalPunch.h"
#import "DateProvider.h"
#import "Constants.h"
#import "Geolocator.h"
#import "Geolocation.h"
#import <CoreLocation/CoreLocation.h>
#import "UserPermissionsStorage.h"
#import "BreakType.h"
#import "OfflineLocalPunch.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "PunchAssemblyGuard.h"
#import "Constants.h"
#import "ClientType.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "OEFType.h"
#import "Enum.h"
#import "PunchActionTypes.h"
#import "PunchOutboxStorage.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(PunchAssemblyWorkflowSpec)

describe(@"PunchAssemblyWorkflow", ^{
    __block PunchAssemblyWorkflow *subject;
    __block UserPermissionsStorage *punchRulesStorage;
    __block Geolocator *geolocator;
    __block PunchAssemblyGuard *punchAssemblyGuard;
    __block id<BSBinder, BSInjector> injector;
    __block PunchOutboxStorage *punchOutboxStorage;

    beforeEach(^{
        injector = [InjectorProvider injector];

        punchRulesStorage = nice_fake_for([UserPermissionsStorage class]);
        geolocator = nice_fake_for([Geolocator class]);
        punchAssemblyGuard = nice_fake_for([PunchAssemblyGuard class]);
        punchOutboxStorage = nice_fake_for([PunchOutboxStorage class]);

        [injector bind:[UserPermissionsStorage class] toInstance:punchRulesStorage];
        [injector bind:[Geolocator class] toInstance:geolocator];
        [injector bind:[PunchAssemblyGuard class] toInstance:punchAssemblyGuard];
        [injector bind:[PunchOutboxStorage class] toInstance:punchOutboxStorage];

        subject = [injector getInstance:[PunchAssemblyWorkflow class]];
    });

    describe(@"-assembleIncompletePunch:serverDidFinishPunchPromise:delegate:", ^{
        __block id<PunchAssemblyWorkflowDelegate> delegate;
        __block BreakType *expectedBreakType;
        __block ClientType *expectedClientType;
        __block ProjectType *expectedProjectType;
        __block TaskType *expectedTaskType;
        __block LocalPunch *incompletePunch;
        __block KSPromise *punchPromise;
        __block NSDate *expectedDate;
        __block KSPromise *serverPromise;
        __block NSString *expectedUserURI;
        __block KSDeferred *shouldAssemblePunchDeferred;
        __block NSArray *expectedOEFTypesArray;

        beforeEach(^{
            expectedUserURI = @"user-uri";
            expectedDate = [NSDate dateWithTimeIntervalSince1970:0];
            expectedBreakType = fake_for([BreakType class]);
            expectedClientType = fake_for([ClientType class]);
            expectedProjectType = fake_for([ProjectType class]);
            expectedTaskType = fake_for([TaskType class]);
            OEFType *oefType1 = nice_fake_for([OEFType class]);
            OEFType *oefType2 = nice_fake_for([OEFType class]);
            expectedOEFTypesArray = @[oefType1,oefType2];

            delegate = nice_fake_for(@protocol(PunchAssemblyWorkflowDelegate));
            serverPromise = [[KSPromise alloc] init];

            shouldAssemblePunchDeferred = [[KSDeferred alloc] init];
            punchAssemblyGuard stub_method(@selector(shouldAssemble)).and_return(shouldAssemblePunchDeferred.promise);
        });


        context(@"when the punch assembly guard indicates that the workflow should not assemble the punch", ^{
            beforeEach(^{
                incompletePunch = fake_for([LocalPunch class]);
                punchPromise = [subject assembleIncompletePunch:incompletePunch
                                    serverDidFinishPunchPromise:nil
                                                       delegate:delegate];
            });

            __block NSArray *errorsArray;
            beforeEach(^{
                errorsArray = @[];
                NSDictionary *userInfo = @{
                                           PunchAssemblyGuardChildErrorsKey: errorsArray
                                           };
                NSError *punchError = [[NSError alloc] initWithDomain:PunchAssemblyGuardErrorDomain
                                                                 code:PunchAssemblyGuardErrorCodeChildAssemblyGuardError
                                                             userInfo:userInfo];


                [shouldAssemblePunchDeferred rejectWithError:punchError];
            });


            it(@"should reject the punch promise", ^{
                punchPromise.rejected should be_truthy;
            });

            it(@"should notify the delegate that it failed to assemble a punch", ^{
                delegate should have_received(@selector(punchAssemblyWorkflow:didFailToAssembleIncompletePunch:errors:)).with(subject, incompletePunch, errorsArray);
            });
        });

        context(@"when the punch assembly guard indicates that the workflow should assemble the punch", ^{
            context(@"with a local manual punch", ^{
                beforeEach(^{
                    incompletePunch = [[OfflineLocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:expectedBreakType location:nil project:expectedProjectType requestID:@"ABCD1234" activity:nil client:expectedClientType oefTypes:expectedOEFTypesArray address:nil userURI:expectedUserURI image:nil task:expectedTaskType date:expectedDate];
                });

                context(@"when no additional data is required", ^{
                    beforeEach(^{
                        punchRulesStorage stub_method(@selector(selfieRequired)).and_return(NO);
                        punchRulesStorage stub_method(@selector(geolocationRequired)).and_return(NO);

                        punchPromise = [subject assembleIncompletePunch:incompletePunch
                                            serverDidFinishPunchPromise:serverPromise
                                                               delegate:delegate];

                        [shouldAssemblePunchDeferred resolveWithValue:(id)[NSNull null]];
                    });

                    it(@"should not notify its delegate that an image is required", ^{
                        delegate should_not have_received(@selector(punchAssemblyWorkflowNeedsImage));
                    });

                    it(@"should notify its delegate that willEventuallyFinishIncompletePunch:incompletePunch", ^{
                        delegate should have_received(@selector(punchAssemblyWorkflow:willEventuallyFinishIncompletePunch:assembledPunchPromise:serverDidFinishPunchPromise:))
                                .with(subject, incompletePunch, punchPromise, serverPromise);
                    });

                    it(@"should resolve the punch promise with a valid punch", ^{
                        OfflineLocalPunch *expectedPunch = [[OfflineLocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:expectedBreakType location:nil project:expectedProjectType requestID:@"ABCD1234" activity:nil client:expectedClientType oefTypes:expectedOEFTypesArray address:nil userURI:expectedUserURI image:nil task:expectedTaskType date:expectedDate];

                        punchPromise.value should equal(expectedPunch);
                        punchPromise.value should be_instance_of([OfflineLocalPunch class]);
                    });
                });
            });

            context(@"with a local punch", ^{
                beforeEach(^{
                    incompletePunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:expectedBreakType location:nil project:expectedProjectType requestID:@"ABCD1234" activity:nil client:expectedClientType oefTypes:expectedOEFTypesArray address:nil userURI:expectedUserURI image:nil task:expectedTaskType date:expectedDate];
                });

                context(@"when no additional data is required", ^{
                    beforeEach(^{
                        punchRulesStorage stub_method(@selector(selfieRequired)).and_return(NO);
                        punchRulesStorage stub_method(@selector(geolocationRequired)).and_return(NO);

                        punchPromise = [subject assembleIncompletePunch:incompletePunch
                                            serverDidFinishPunchPromise:serverPromise
                                                               delegate:delegate];

                        [shouldAssemblePunchDeferred resolveWithValue:(id)[NSNull null]];
                    });

                    it(@"should not notify its delegate that an image is required", ^{
                        delegate should_not have_received(@selector(punchAssemblyWorkflowNeedsImage));
                    });

                    it(@"should notify its delegate that willEventuallyFinishIncompletePunch:incompletePunch", ^{
                        delegate should have_received(@selector(punchAssemblyWorkflow:willEventuallyFinishIncompletePunch:assembledPunchPromise:serverDidFinishPunchPromise:))
                                .with(subject, incompletePunch, punchPromise, serverPromise);
                    });

                    it(@"should resolve the punch promise with a valid punch", ^{
                        LocalPunch *expectedPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:expectedBreakType location:nil project:expectedProjectType requestID:@"ABCD1234" activity:nil client:expectedClientType oefTypes:expectedOEFTypesArray address:nil userURI:expectedUserURI image:nil task:expectedTaskType date:expectedDate];

                        punchPromise.value should equal(expectedPunch);
                    });

                    it(@"should store the finished punch", ^{
                        LocalPunch *expectedPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:expectedBreakType location:nil project:expectedProjectType requestID:@"ABCD1234" activity:nil client:expectedClientType oefTypes:expectedOEFTypesArray address:nil userURI:expectedUserURI image:nil task:expectedTaskType date:expectedDate];
                        punchOutboxStorage should have_received(@selector(storeLocalPunch:)).with(expectedPunch);
                    });
                });

                context(@"when only an image is required", ^{
                    __block KSDeferred *imageDeferred;

                    beforeEach(^{
                        punchRulesStorage stub_method(@selector(selfieRequired)).and_return(YES);
                        punchRulesStorage stub_method(@selector(geolocationRequired)).and_return(NO);

                        imageDeferred = [[KSDeferred alloc] init];
                        delegate stub_method(@selector(punchAssemblyWorkflowNeedsImage)).and_return(imageDeferred.promise);

                        punchPromise = [subject assembleIncompletePunch:incompletePunch
                                            serverDidFinishPunchPromise:serverPromise
                                                               delegate:delegate];

                        [shouldAssemblePunchDeferred resolveWithValue:(id)[NSNull null]];
                    });

                    it(@"should notify its delegate that an image is required", ^{
                        delegate should have_received(@selector(punchAssemblyWorkflowNeedsImage));
                    });

                    context(@"when the image deferred is resolved", ^{
                        __block UIImage *image;

                        beforeEach(^{
                            image = [UIImage imageNamed:ExpensesImageUp];
                            [imageDeferred resolveWithValue:image];
                        });

                        it(@"should notify its delegate that all user-interactive processing is done, and the punch will eventually finish", ^{
                            delegate should have_received(@selector(punchAssemblyWorkflow:willEventuallyFinishIncompletePunch:assembledPunchPromise:serverDidFinishPunchPromise:))
                                    .with(subject, incompletePunch, punchPromise, serverPromise);
                        });

                        it(@"should resolve the punch promise with a valid punch", ^{
                            LocalPunch *expectedPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:expectedBreakType location:nil project:expectedProjectType requestID:@"ABCD1234" activity:nil client:expectedClientType oefTypes:expectedOEFTypesArray address:nil userURI:expectedUserURI image:image task:expectedTaskType date:expectedDate];

                            punchPromise.value should equal(expectedPunch);
                        });

                        it(@"should store the finished punch", ^{
                            LocalPunch *expectedPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:expectedBreakType location:nil project:expectedProjectType requestID:@"ABCD1234" activity:nil client:expectedClientType oefTypes:expectedOEFTypesArray address:nil userURI:expectedUserURI image:image task:expectedTaskType date:expectedDate];
                            punchOutboxStorage should have_received(@selector(storeLocalPunch:)).with(expectedPunch);
                        });
                    });

                    context(@"when the image deferred is rejected", ^{
                        beforeEach(^{
                            [imageDeferred rejectWithError:fake_for([NSError class])];
                        });

                        it(@"should not resolve the punch promise", ^{
                            punchPromise.fulfilled should_not be_truthy;
                            punchPromise.cancelled should_not be_truthy;
                            punchPromise.rejected should_not be_truthy;
                        });
                    });
                });

                context(@"when only a location is required", ^{
                    __block KSDeferred *geolocationDeferred;

                    beforeEach(^{
                        punchRulesStorage stub_method(@selector(selfieRequired)).and_return(NO);
                        punchRulesStorage stub_method(@selector(geolocationRequired)).and_return(YES);

                        geolocationDeferred = [[KSDeferred alloc] init];
                        geolocator stub_method(@selector(mostRecentGeolocationPromise)).and_return(geolocationDeferred.promise);

                        punchPromise = [subject assembleIncompletePunch:incompletePunch
                                            serverDidFinishPunchPromise:serverPromise
                                                               delegate:delegate];

                        [shouldAssemblePunchDeferred resolveWithValue:(id)[NSNull null]];
                    });

                    context(@"when the geolocation promise is resolved", ^{
                        __block Geolocation *geolocation;

                        beforeEach(^{
                            CLLocation *location = [[CLLocation alloc] initWithLatitude:12 longitude:34];
                            geolocation = [[Geolocation alloc] initWithLocation:location address:@"My Special Address"];

                            [geolocationDeferred resolveWithValue:geolocation];
                        });

                        it(@"should resolve the punch promise with a valid punch", ^{
                            LocalPunch *expectedPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:expectedBreakType location:geolocation.location project:expectedProjectType requestID:@"ABCD1234" activity:nil client:expectedClientType oefTypes:expectedOEFTypesArray address:geolocation.address userURI:expectedUserURI image:nil task:expectedTaskType date:expectedDate];

                            punchPromise.value should equal(expectedPunch);
                        });

                        it(@"should store the finished punch", ^{
                            LocalPunch *expectedPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:expectedBreakType location:geolocation.location project:expectedProjectType requestID:@"ABCD1234" activity:nil client:expectedClientType oefTypes:expectedOEFTypesArray address:geolocation.address userURI:expectedUserURI image:nil task:expectedTaskType date:expectedDate];
                            punchOutboxStorage should have_received(@selector(storeLocalPunch:)).with(expectedPunch);
                        });
                    });

                    context(@"when the location deferred is rejected", ^{
                        beforeEach(^{
                            [geolocationDeferred rejectWithError:fake_for([NSError class])];
                        });

                        it(@"should not resolve the punch promise", ^{
                            punchPromise.fulfilled should_not be_truthy;
                            punchPromise.cancelled should_not be_truthy;
                            punchPromise.rejected should_not be_truthy;
                        });
                    });
                });

                context(@"when both an image and a location are required", ^{
                    __block KSDeferred *geolocationDeferred;
                    __block KSDeferred *imageDeferred;

                    beforeEach(^{
                        punchRulesStorage stub_method(@selector(selfieRequired)).and_return(YES);
                        punchRulesStorage stub_method(@selector(geolocationRequired)).and_return(YES);

                        geolocationDeferred = [[KSDeferred alloc] init];
                        geolocator stub_method(@selector(mostRecentGeolocationPromise)).and_return(geolocationDeferred.promise);

                        imageDeferred = [[KSDeferred alloc] init];
                        delegate stub_method(@selector(punchAssemblyWorkflowNeedsImage)).and_return(imageDeferred.promise);

                        punchPromise = [subject assembleIncompletePunch:incompletePunch
                                            serverDidFinishPunchPromise:nil
                                                               delegate:delegate];

                        [shouldAssemblePunchDeferred resolveWithValue:(id)[NSNull null]];
                    });

                    it(@"should notify its delegate that an image is required", ^{
                        delegate should have_received(@selector(punchAssemblyWorkflowNeedsImage));
                    });

                    it(@"should ask the geolocator for the most recent geolocation", ^{
                        geolocator should have_received(@selector(mostRecentGeolocationPromise));
                    });

                    context(@"when both deferreds are resolved", ^{
                        __block Geolocation *geolocation;
                        __block UIImage *image;

                        beforeEach(^{
                            image = [UIImage imageNamed:ExpensesImageUp];
                            [imageDeferred resolveWithValue:image];

                            CLLocation *location = [[CLLocation alloc] initWithLatitude:12 longitude:34];
                            geolocation = [[Geolocation alloc] initWithLocation:location address:@"My Special Address"];
                            [geolocationDeferred resolveWithValue:geolocation];
                        });

                        it(@"should resolve the punch promise with a valid punch", ^{
                            LocalPunch *expectedPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:expectedBreakType location:geolocation.location project:expectedProjectType requestID:@"ABCD1234" activity:nil client:expectedClientType oefTypes:expectedOEFTypesArray address:geolocation.address userURI:expectedUserURI image:image task:expectedTaskType date:expectedDate];

                            punchPromise.value should equal(expectedPunch);
                        });

                        it(@"should store the finished punch", ^{
                            LocalPunch *expectedPunch = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:expectedBreakType location:geolocation.location project:expectedProjectType requestID:@"ABCD1234" activity:nil client:expectedClientType oefTypes:expectedOEFTypesArray address:geolocation.address userURI:expectedUserURI image:image task:expectedTaskType date:expectedDate];
                            punchOutboxStorage should have_received(@selector(storeLocalPunch:)).with(expectedPunch);
                        });
                    });

                    context(@"when only the image deferred is rejected", ^{
                        __block Geolocation *geolocation;

                        beforeEach(^{
                            [imageDeferred rejectWithError:fake_for([NSError class])];

                            CLLocation *location = [[CLLocation alloc] initWithLatitude:12 longitude:34];
                            geolocation = [[Geolocation alloc] initWithLocation:location address:@"My Special Address"];
                            [geolocationDeferred resolveWithValue:geolocation];
                        });

                        it(@"should not resolve the punch promise", ^{
                            punchPromise.fulfilled should_not be_truthy;
                            punchPromise.cancelled should_not be_truthy;
                            punchPromise.rejected should_not be_truthy;
                        });
                    });

                    context(@"when only the location deferred is rejected", ^{
                        __block UIImage *image;

                        beforeEach(^{
                            image = [UIImage imageNamed:ExpensesImageUp];
                            [imageDeferred resolveWithValue:image];

                            [geolocationDeferred rejectWithError:fake_for([NSError class])];
                        });

                        it(@"should not resolve the punch promise", ^{
                            punchPromise.fulfilled should_not be_truthy;
                            punchPromise.cancelled should_not be_truthy;
                            punchPromise.rejected should_not be_truthy;
                        });
                    });

                    context(@"when both deferreds are rejected", ^{
                        beforeEach(^{
                            [imageDeferred rejectWithError:fake_for([NSError class])];
                            [geolocationDeferred rejectWithError:fake_for([NSError class])];
                        });

                        it(@"should not resolve the punch promise", ^{
                            punchPromise.fulfilled should_not be_truthy;
                            punchPromise.cancelled should_not be_truthy;
                            punchPromise.rejected should_not be_truthy;
                        });
                    });
                });
            });
        });
    });
    
    describe(@"-assembleManualIncompletePunch:serverDidFinishPunchPromise:serverDidFinishPunchPromise:delegate", ^{
        
        __block id<PunchAssemblyWorkflowDelegate> delegate;
        __block BreakType *expectedBreakType;
        __block ClientType *expectedClientType;
        __block ProjectType *expectedProjectType;
        __block TaskType *expectedTaskType;
        __block LocalPunch *incompletePunch;
        __block KSPromise *punchPromise;
        __block NSDate *expectedDate;
        __block KSPromise *serverPromise;
        __block NSString *expectedUserURI;
        __block KSDeferred *shouldAssemblePunchDeferred;
        __block NSArray *expectedOEFTypesArray;
        
        beforeEach(^{
            expectedUserURI = @"user-uri";
            expectedDate = [NSDate dateWithTimeIntervalSince1970:0];
            expectedBreakType = fake_for([BreakType class]);
            expectedClientType = fake_for([ClientType class]);
            expectedProjectType = fake_for([ProjectType class]);
            expectedTaskType = fake_for([TaskType class]);
            OEFType *oefType1 = nice_fake_for([OEFType class]);
            OEFType *oefType2 = nice_fake_for([OEFType class]);
            expectedOEFTypesArray = @[oefType1,oefType2];
            
            delegate = nice_fake_for(@protocol(PunchAssemblyWorkflowDelegate));
            serverPromise = [[KSPromise alloc] init];
            
            shouldAssemblePunchDeferred = [[KSDeferred alloc] init];
            
            punchPromise = [subject assembleManualIncompletePunch:incompletePunch serverDidFinishPunchPromise:serverPromise delegate:delegate];
            
            [shouldAssemblePunchDeferred resolveWithValue:incompletePunch];
            
        });
        
        it(@"Should have received punchAssemblyWorkFlow delegate", ^{
            delegate should have_received(@selector(punchAssemblyWorkflow:willEventuallyFinishIncompletePunch:assembledPunchPromise:serverDidFinishPunchPromise:));
            
        });
        
        
    });
});

SPEC_END
