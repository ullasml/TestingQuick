#import <Cedar/Cedar.h>
#import "AddressControllerPresenter.h"
#import "AddressControllerProvider.h"
#import "Theme.h"
#import "FakeParentController.h"
#import <KSDeferred/KSPromise.h>
#import "UserPermissionsStorage.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(AddressControllerPresenterSpec)

describe(@"AddressControllerPresenter", ^{
    __block AddressControllerPresenter *subject;
    __block AddressControllerProvider *addressControllerProvider;
    __block UserPermissionsStorage *punchRulesStorage;
    __block KSPromise *localPunchPromise;
    __block id<Theme> theme;

    beforeEach(^{
        localPunchPromise = nice_fake_for([KSPromise class]);
        punchRulesStorage = nice_fake_for([UserPermissionsStorage class]);
        theme = nice_fake_for(@protocol(Theme));
        addressControllerProvider = nice_fake_for([AddressControllerProvider class]);
        subject = [[AddressControllerPresenter alloc] initWithAddressControllerProvider:addressControllerProvider
                                                                      localPunchPromise:localPunchPromise
                                                                      punchRulesStorage:punchRulesStorage
                                                                                  theme:theme];

    });

    describe(@"presenting an address if needed", ^{
        __block FakeParentController *parentController;
        __block UIViewController *expectedAddressController;
        __block UIColor *backgroundColor;

        beforeEach(^{
            backgroundColor = [UIColor orangeColor];
            expectedAddressController = [[UIViewController alloc] init];
            spy_on(expectedAddressController);
            addressControllerProvider stub_method(@selector(provideInstanceWithAddress:localPunchPromise:backgroundColor:))
                .and_return(expectedAddressController);
            parentController = [[FakeParentController alloc] init];
            [parentController view];
        });

        afterEach(^{
            stop_spying_on(expectedAddressController);
            expectedAddressController = nil;
        });

        context(@"when the punch rules require an address", ^{
            __block AddressController *addressController;
            beforeEach(^{
                punchRulesStorage stub_method(@selector(geolocationRequired)).and_return(YES);
                theme stub_method(@selector(transparentColor)).and_return([UIColor redColor]);


                addressController = [subject presentAddress:@"My address"
        ifNeededInAddressLabelContainer:parentController.containerView
                     onParentController:parentController
                        backgroundColor:backgroundColor];
            });

            it(@"should return the address controller", ^{
                addressController should be_same_instance_as(expectedAddressController);
            });

            it(@"should add an address controller as a child view controller of the parent controller", ^{
                parentController.childViewControllers.count should equal(1);
            });

            it(@"should make the address controller a child controller", ^{
               parentController.childViewControllers.firstObject should be_same_instance_as(expectedAddressController);
            });

            it(@"should add the address controller's view as a subview of the address label container", ^{
                parentController.containerView.subviews should contain(expectedAddressController.view);
            });

            it(@"should add the address controller's view as a subview of the address label container", ^{
                CGRectEqualToRect(parentController.containerView.bounds, expectedAddressController.view.frame) should be_truthy;
            });

            it(@"should always call the punch out controller provider with the correct arguments", ^{
                addressControllerProvider should have_received(@selector(provideInstanceWithAddress:localPunchPromise:backgroundColor:)).with(@"My address", localPunchPromise, backgroundColor);
            });

            it(@"should tell the address controller that it did move to parent controller", ^{
                expectedAddressController should have_received(@selector(didMoveToParentViewController:)).with(parentController);
            });

            it(@"should style the address container correctly", ^{
                parentController.containerView.backgroundColor should equal([UIColor redColor]);
            });
        });

        context(@"when the punch rules don't require an address", ^{
            beforeEach(^{
                punchRulesStorage stub_method(@selector(geolocationRequired)).and_return(NO);

                [subject presentAddress:@"My address"
        ifNeededInAddressLabelContainer:parentController.containerView
                     onParentController:parentController
                 backgroundColor:nil];
            });

            it(@"should remove the address container from its superview", ^{
                parentController.containerView.superview should be_nil;
            });
        });
    });
});

SPEC_END
