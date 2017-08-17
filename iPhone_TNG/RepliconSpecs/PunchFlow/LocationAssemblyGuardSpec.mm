#import <Cedar/Cedar.h>
#import "LocationAssemblyGuard.h"
#import "UserPermissionsStorage.h"
#import <KSDeferred/KSDeferred.h>
#import "CLLocationManager+Spec.h"
#import "Constants.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(LocationAssemblyGuardSpec)

describe(@"LocationAssemblyGuard", ^{
    __block LocationAssemblyGuard *subject;
    __block UserPermissionsStorage *userPermissionsStorage;

    beforeEach(^{
        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);

        subject = [[LocationAssemblyGuard alloc] initWithUserPermissionsStorage:userPermissionsStorage];
    });

    describe(@"-shouldAssemble", ^{
        __block KSPromise *promise;

        it(@"should return a promise", ^{
            promise = [subject shouldAssemble];

            promise should be_instance_of([KSPromise class]);
        });

        context(@"when the user is  required to capture their current location", ^{
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(geolocationRequired)).and_return(YES);
            });


            context(@"when access to the user's location is authorized", ^{
                beforeEach(^{
                    [CLLocationManager setAuthorizationStatus:kCLAuthorizationStatusAuthorized];
                    promise = [subject shouldAssemble];
                });

                it(@"should resolve the promise with a truthy value", ^{
                    promise.fulfilled should be_truthy;
                    promise.value should equal(@(YES));
                });
            });

            context(@"when access to the user's location is always authorized", ^{
                beforeEach(^{
                    [CLLocationManager setAuthorizationStatus:kCLAuthorizationStatusAuthorizedAlways];
                    promise = [subject shouldAssemble];
                });

                it(@"should resolve the promise with a truthy value", ^{
                    promise.fulfilled should be_truthy;
                    promise.value should equal(@(YES));
                });
            });

            context(@"when access to the user's location is yet to be determined", ^{
                beforeEach(^{
                    [CLLocationManager setAuthorizationStatus:kCLAuthorizationStatusNotDetermined];
                    promise = [subject shouldAssemble];
                });

                it(@"should reject the promise with a correctly configured error", ^{
                    promise.rejected should be_truthy;
                    promise.error.domain should equal(LocationAssemblyGuardErrorDomain);
                    promise.error.code should equal(LocationAssemblyGuardErrorCodeDeniedAccessToLocation);
                });
            });

            context(@"when access to the user's location is restricted", ^{
                beforeEach(^{
                    [CLLocationManager setAuthorizationStatus:kCLAuthorizationStatusRestricted];
                    promise = [subject shouldAssemble];
                });

                it(@"should reject the promise with a correctly configured error", ^{
                    promise.rejected should be_truthy;
                    promise.error.domain should equal(LocationAssemblyGuardErrorDomain);
                    promise.error.code should equal(LocationAssemblyGuardErrorCodeDeniedAccessToLocation);
                });            });

            context(@"when access to the user's location is authorized when in use", ^{
                beforeEach(^{
                    [CLLocationManager setAuthorizationStatus:kCLAuthorizationStatusAuthorizedWhenInUse];
                    promise = [subject shouldAssemble];
                });

                it(@"should resolve the promise with a truthy value", ^{
                    promise.fulfilled should be_truthy;
                    promise.value should equal(@(YES));
                });
            });

            context(@"when access to the user's location is denied", ^{
                beforeEach(^{
                    [CLLocationManager setAuthorizationStatus:kCLAuthorizationStatusDenied];
                    promise = [subject shouldAssemble];
                });

                it(@"should reject the promise with a correctly configured error", ^{
                    promise.rejected should be_truthy;
                    promise.error.domain should equal(LocationAssemblyGuardErrorDomain);
                    promise.error.code should equal(LocationAssemblyGuardErrorCodeDeniedAccessToLocation);
                });            });
        });

        context(@"when the user is not required to capture their current location", ^{
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(geolocationRequired)).and_return(NO);

                promise = [subject shouldAssemble];
            });

            it(@"should resolve the promise with a truthy value", ^{
                promise.fulfilled should be_truthy;
                promise.value should equal(@(YES));
            });
        });
    });
});

SPEC_END
