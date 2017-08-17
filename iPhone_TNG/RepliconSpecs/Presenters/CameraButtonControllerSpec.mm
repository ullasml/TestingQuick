#import <Cedar/Cedar.h>
#import "CameraButtonController.h"
#import "UIControl+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CameraButtonControllerSpec)

describe(@"CameraButtonController", ^{
    __block CameraButtonController *subject;
    __block id <CameraButtonControllerDelegate> delegate;
    __block id <Theme> theme;

    beforeEach(^{
        theme = nice_fake_for(@protocol(Theme));
        delegate = nice_fake_for(@protocol(CameraButtonControllerDelegate));
        subject = [[CameraButtonController alloc]initWithTheme:theme];
        [subject setUpWithDelegate:delegate];
    });

    it(@"should correctly set the delegate", ^{
        subject.delegate should be_same_instance_as(delegate);
    });

    describe(@"Styling of views", ^{
        beforeEach(^{
            theme stub_method(@selector(cancelButtonBackgroundColor)).and_return([UIColor greenColor]);
            theme stub_method(@selector(useButtonBackgroundColor)).and_return([UIColor grayColor]);
            theme stub_method(@selector(retakeButtonBackgroundColor)).and_return([UIColor yellowColor]);
            theme stub_method(@selector(cameraButtonBackgroundColor)).and_return([UIColor orangeColor]);

            subject.view should_not be_nil;
        });

        it(@"should correctly style the view", ^{
            subject.view.backgroundColor should equal([UIColor blackColor]);
            subject.cancelButton.backgroundColor should equal([UIColor greenColor]);
            subject.retakeButton.backgroundColor should equal([UIColor yellowColor]);
            subject.useButton.backgroundColor should equal([UIColor grayColor]);
            subject.cameraButton.backgroundColor should equal([UIColor orangeColor]);
        });
    });

    describe(@"When view loads", ^{

        __block UIDevice <CedarDouble> *device;
        beforeEach(^{
            device = (id)[UIDevice currentDevice];
            spy_on(device);
        });
        context(@"When operating on simulator", ^{
            beforeEach(^{
                device stub_method(@selector(model)).and_return(@"Simulator");
                subject.view should_not be_nil;
            });

            it(@"should hide cameraButton and retakeButton", ^{
                subject.cameraButton.hidden should be_truthy;
                subject.retakeButton.hidden should be_truthy;
            });
        });

        context(@"When operating on device", ^{
            beforeEach(^{
                device stub_method(@selector(model)).and_return(@"iPhone");
                subject.view should_not be_nil;
            });

            it(@"should hide cameraButton and retakeButton", ^{
                subject.cameraButton.hidden should be_falsy;
                subject.retakeButton.hidden should be_falsy;
            });
        });

    });

    describe(@"Tapping on the button", ^{
        beforeEach(^{
            subject.view should_not be_nil;
            subject.cameraButton.hidden = NO;
            subject.useButton.hidden = NO;
            subject.retakeButton.hidden = NO;
        });

        it(@"should inform delegate when cancel button is tapped", ^{
            [subject.cancelButton tap];
            delegate should have_received(@selector(userDidIntendToCancel));
        });
        it(@"should inform delegate when use button is tapped", ^{
            [subject.useButton tap];
            delegate should have_received(@selector(userDidIntendToUseImage));
        });
        it(@"should inform delegate when retake button is tapped", ^{
            [subject.retakeButton tap];
            delegate should have_received(@selector(userDidIntendToRetakeImage));
        });
        it(@"should inform delegate when camera button is tapped", ^{
            [subject.cameraButton tap];
            delegate should have_received(@selector(userDidIntendToCaptureImage));
        });
    });


});

SPEC_END
