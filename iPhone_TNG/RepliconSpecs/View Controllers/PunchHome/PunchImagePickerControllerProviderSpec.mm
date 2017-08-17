#import <Cedar/Cedar.h>
#import "PunchImagePickerControllerProvider.h"
#import "LocalPunch.h"
#import <KSDeferred/KSPromise.h>
#import "UIImagePickerController+Spec.h"
#import "CameraViewController.h"
#import <Blindside/BSInjector.h>
#import "InjectorProvider.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(PunchImagePickerControllerProviderSpec)

describe(@"PunchImagePickerControllerProvider", ^{
    __block PunchImagePickerControllerProvider *subject;
    __block id<UIImagePickerControllerDelegate, UINavigationControllerDelegate> delegate;
    __block id <BSInjector> injector;

    beforeEach(^{
        injector = [InjectorProvider injector];
        delegate = nice_fake_for(@protocol(UIImagePickerControllerDelegate), @protocol(UINavigationControllerDelegate));
        subject = [injector getInstance:[PunchImagePickerControllerProvider class]];
    });

    describe(@"provideInstanceWithDelegate", ^{
        __block UIImagePickerController *punchImagePickerController;


        context(@"when camera is unavailable", ^{
            beforeEach(^{
                [UIImagePickerController setCameraAvailable:NO];

                punchImagePickerController = [subject provideInstanceWithDelegate:delegate];
            });

            it(@"should be the correct type", ^{
                punchImagePickerController should be_instance_of([UIImagePickerController class]);
            });

            it(@"should configure the delegate correctly", ^{
                punchImagePickerController.delegate should be_same_instance_as(delegate);
            });
        });

        context(@"when camera is available", ^{
            beforeEach(^{
                [UIImagePickerController setCameraAvailable:YES];

                punchImagePickerController = [subject provideInstanceWithDelegate:delegate];
            });

            it(@"should be the correct type", ^{
                punchImagePickerController should be_instance_of([UIImagePickerController class]);
            });

            it(@"should configure the delegate correctly", ^{
                punchImagePickerController.delegate should be_same_instance_as(delegate);
            });

            it(@"should configure sourceType correctly", ^{
                punchImagePickerController.sourceType should equal(UIImagePickerControllerSourceTypeCamera);
            });

            it(@"should configure cameraDevice correctly", ^{
                punchImagePickerController.cameraDevice should equal(UIImagePickerControllerCameraDeviceFront);
            });

            it(@"should configure allowsEditing correctly", ^{
                punchImagePickerController.allowsEditing should be_falsy;
            });
        });
    });

    describe(@"provideCameraInstanceWithDelegate", ^{

        __block CameraViewController *cameraViewController;
        __block id <CameraViewControllerDelegate> delegate;
        beforeEach(^{
            delegate = nice_fake_for(@protocol(CameraViewControllerDelegate));
            cameraViewController = [subject provideCameraInstanceWithDelegate:delegate];
            spy_on(cameraViewController);
        });

        it(@"should correctly configure cameraViewController", ^{
            cameraViewController.hidesBottomBarWhenPushed should be_truthy;
            cameraViewController.delegate should be_same_instance_as(delegate);
        });
    });
});

SPEC_END
