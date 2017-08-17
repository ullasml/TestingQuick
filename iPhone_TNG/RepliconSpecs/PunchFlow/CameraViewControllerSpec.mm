#import <Cedar/Cedar.h>
#import "CameraViewController.h"
#import "Theme.h"
#import "Constants.h"
#import <Blindside/BSInjector.h>
#import <Blindside/BSBinder.h>
#import "InjectorProvider.h"
#import "CameraButtonController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(CameraViewControllerSpec)

describe(@"CameraViewController", ^{
    __block CameraViewController *subject;
    __block id <Theme> theme;
    __block id <BSInjector,BSBinder> injector;
    __block CameraButtonController *cameraButtonController;

    beforeEach(^{
        injector = [InjectorProvider injector];

        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];

        cameraButtonController = [[CameraButtonController alloc]initWithTheme:nil];
        [injector bind:[CameraButtonController class] toInstance:cameraButtonController];

        spy_on(cameraButtonController);

        subject = [injector getInstance:[CameraViewController class]];
    });

    context(@"Styling the views", ^{
        beforeEach(^{
            theme stub_method(@selector(titleLabelColor)).and_return([UIColor greenColor]);
            theme stub_method(@selector(subTitleLabelColor)).and_return([UIColor orangeColor]);

            theme stub_method(@selector(titleLabelFont)).and_return([UIFont systemFontOfSize:1]);
            theme stub_method(@selector(subTitleLabelFont)).and_return([UIFont systemFontOfSize:2]);

            [subject view];
        });

        it(@"should style the subviews correctly", ^{
            subject.view.backgroundColor should equal([UIColor blackColor]);
            subject.titleLabel.text should equal(RPLocalizedString(CAMERA_MAIN_TITLE, nil));
            subject.titleLabel.font should equal([UIFont systemFontOfSize:1]);
            subject.titleLabel.textColor should equal([UIColor greenColor]);
            subject.titleLabel.backgroundColor should equal([UIColor clearColor]);

            subject.subTitleLabel.text should equal(RPLocalizedString(CAMERA_SUB_TITLE, nil));
            subject.subTitleLabel.font should equal([UIFont systemFontOfSize:2]);
            subject.subTitleLabel.textColor should equal([UIColor orangeColor]);
            subject.subTitleLabel.backgroundColor should equal([UIColor clearColor]);
        });
    });

    context(@"When view loads", ^{
        beforeEach(^{
            subject.view should_not be_nil;
        });

        it(@"should be added as a child controller", ^{
            subject.childViewControllers.count should equal(1);
            subject.childViewControllers.firstObject should be_same_instance_as(cameraButtonController);
        });

        it(@"should correctly set the delegate for cameraButtonController", ^{
            cameraButtonController should have_received(@selector(setUpWithDelegate:)).with(subject);
        });

        it(@"should add the workHoursController's view as a subview of the workHoursContainerView", ^{
            subject.containerView.subviews.count should equal(1);
            subject.containerView.subviews.firstObject should be_same_instance_as(cameraButtonController.view);
        });

        it(@"should call didMoveToParentViewController: on the child view controller];", ^{
            cameraButtonController should have_received(@selector(didMoveToParentViewController:)).with(subject);
        });

    });
});

SPEC_END
