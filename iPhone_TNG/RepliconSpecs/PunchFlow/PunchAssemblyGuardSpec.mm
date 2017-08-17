#import <Cedar/Cedar.h>
#import "PunchAssemblyGuard.h"
#import <Blindside/Blindside.h>
#import "InjectorProvider.h"
#import "UserPermissionsStorage.h"
#import "CLLocationManager+Spec.h"
#import <AVFoundation/AVFoundation.h>
#import <KSDeferred/KSDeferred.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PunchAssemblyGuardSpec)

describe(@"PunchAssemblyGuard", ^{
    __block PunchAssemblyGuard *subject;
    __block UserPermissionsStorage *userPermissionsStorage;
    __block id<AssemblyGuard> childAssemblyGuardA;
    __block id<AssemblyGuard> childAssemblyGuardB;
    beforeEach(^{
        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);

        childAssemblyGuardA = fake_for(@protocol(AssemblyGuard));
        childAssemblyGuardB = fake_for(@protocol(AssemblyGuard));

        subject = [[PunchAssemblyGuard alloc] initWithChildAssemblyGuards:@[childAssemblyGuardA, childAssemblyGuardB]];
    });

    describe(@"shouldAssemble", ^{
        __block KSDeferred *childAssemblyGuardADeferred;
        __block KSDeferred *childAssemblyGuardBDeferred;
        __block KSPromise *promise;

        beforeEach(^{
            childAssemblyGuardADeferred = [[KSDeferred alloc] init];
            childAssemblyGuardA stub_method(@selector(shouldAssemble)).and_return(childAssemblyGuardADeferred.promise);
            childAssemblyGuardBDeferred = [[KSDeferred alloc] init];
            childAssemblyGuardB stub_method(@selector(shouldAssemble)).and_return(childAssemblyGuardBDeferred.promise);

            promise = [subject shouldAssemble];
        });


        it(@"should return a promise", ^{
            promise = [subject shouldAssemble];
            promise should be_instance_of([KSPromise class]);
        });

        describe(@"when one of the child assembly guards rejects its promise", ^{
            __block NSError *expectedError;

            beforeEach(^{
                [childAssemblyGuardADeferred resolveWithValue:(id)[NSNull null]];
                expectedError = fake_for([NSError class]);
                [childAssemblyGuardBDeferred rejectWithError:expectedError];
            });

            it(@"should reject the returned promise, forwarding the errors in the user info", ^{
                NSArray *childErrors = promise.error.userInfo[PunchAssemblyGuardChildErrorsKey];

                promise.rejected should be_truthy;
                promise.error.domain should equal(PunchAssemblyGuardErrorDomain);
                promise.error.code should equal(PunchAssemblyGuardErrorCodeChildAssemblyGuardError);
                childErrors.count should equal(1);
                childErrors.firstObject should be_same_instance_as(expectedError);
            });
        });

        context(@"when all of the child assembly guards resolve their promises successfully", ^{
            beforeEach(^{
                [childAssemblyGuardADeferred resolveWithValue:(id)[NSNull null]];
                [childAssemblyGuardBDeferred resolveWithValue:(id)[NSNull null]];
            });

            it(@"should resolve the promise with a truthy value", ^{
                promise.fulfilled should be_truthy;
                promise.value should equal(@(YES));
            });
        });
    });
});

SPEC_END
