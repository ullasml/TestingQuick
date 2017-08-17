#import <Cedar/Cedar.h>
#import "CameraAssemblyGuard.h"
#import "UserPermissionsStorage.h"
#import <KSDeferred/KSDeferred.h>
#import "Constants.h"
#import "PSHKFakeOperationQueue.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CameraAssemblyGuardSpec)

describe(@"CameraAssemblyGuard", ^{
    __block CameraAssemblyGuard *subject;
    __block UserPermissionsStorage *userPermissionsStorage;
    __block PSHKFakeOperationQueue *mainQueue;

    beforeEach(^{
        mainQueue = [[PSHKFakeOperationQueue alloc] init];
        mainQueue.runSynchronously = NO;

        userPermissionsStorage = nice_fake_for([UserPermissionsStorage class]);
        subject = [[CameraAssemblyGuard alloc] initWithUserPermissionsStorage:userPermissionsStorage mainQueue:mainQueue];
    });

    describe(@"shouldAssemble", ^{
        __block KSPromise *promise;

        __block NSString *receivedMediaType;
        __block void (^receivedCompletionHandler)(BOOL);

        beforeEach(^{
            spy_on([AVCaptureDevice class]);

            [AVCaptureDevice class] stub_method(@selector(requestAccessForMediaType:completionHandler:)).and_do_block(^void(NSString *mediaType, void (^completionHandler)(BOOL granted)) {
                receivedMediaType = mediaType;
                receivedCompletionHandler = completionHandler;
            });
        });

        afterEach(^{
            stop_spying_on([AVCaptureDevice class]);
        });

        it(@"should return a promise", ^{
            promise = [subject shouldAssemble];
            promise should be_instance_of([KSPromise class]);
        });

        context(@"when the user does not require a selfie", ^{
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(selfieRequired)).and_return(NO);
                promise = [subject shouldAssemble];
            });

            it(@"should resolve the promise with a truthy value", ^{
                promise.fulfilled should be_truthy;
                promise.value should equal(@(YES));
            });

            it(@"should not request permission to use the camera", ^{
                [AVCaptureDevice class] should_not have_received(@selector(requestAccessForMediaType:completionHandler:));
            });
        });

        context(@"when the user does require a selfie", ^{
            beforeEach(^{
                userPermissionsStorage stub_method(@selector(selfieRequired)).and_return(YES);
                promise = [subject shouldAssemble];
            });

            it(@"should request permission to use the camera", ^{
                receivedMediaType should equal(AVMediaTypeVideo);
            });

            context(@"when the user grants permissions", ^{
                beforeEach(^{
                    receivedCompletionHandler(YES);
                });

                it(@"should resolve the promise with a truthy value on the main queue", ^{
                    promise.fulfilled should be_falsy;

                    [mainQueue runNextOperation];

                    promise.fulfilled should be_truthy;
                    promise.value should equal(@(YES));
                });
            });

            context(@"when the user grants permissions", ^{
                beforeEach(^{
                    receivedCompletionHandler(NO);
                });

                it(@"should reject the promise with a correctly configured error on the main queue", ^{
                    promise.rejected should be_falsy;

                    [mainQueue runNextOperation];

                    promise.rejected should be_truthy;
                    promise.error.domain should equal(CameraAssemblyGuardErrorDomain);
                    promise.error.code should equal(CameraAssemblyGuardErrorCodeDeniedAccessToCamera);
                });
            });
        });
    });
});

SPEC_END
