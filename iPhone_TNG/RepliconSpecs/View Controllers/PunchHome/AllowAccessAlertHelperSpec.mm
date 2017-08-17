#import <Cedar/Cedar.h>
#import "UIAlertView+Spec.h"
#import <Blindside/Blindside.h>
#import "AllowAccessAlertHelper.h"
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import "PunchAssemblyGuard.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(AllowAccessAlertHelperSpec)

describe(@"AllowAccessAlertHelper", ^{
    __block AllowAccessAlertHelper *subject;
    __block id<BSInjector, BSBinder> injector;
    __block UIApplication<CedarDouble> *sharedApplication;

    beforeEach(^{
        injector = [InjectorProvider injector];

        sharedApplication = nice_fake_for([UIApplication class]);
        [injector bind:InjectorKeySharedApplication toInstance:sharedApplication];

        subject = [injector getInstance:[AllowAccessAlertHelper class]];
    });

    describe(@"-punchAssemblyWorkflow:didFailToAssembleIncompletePunch", ^{
        __block UIAlertView *alertView;
        BOOL canOpenSettings = (&UIApplicationOpenSettingsURLString != nil);

        describe(@"when the punch assembly workflow failed to get access to the phone's location", ^{
            beforeEach(^{
                NSError *error = [[NSError alloc] initWithDomain:PunchAssemblyGuardErrorDomain code:LocationAssemblyGuardErrorCodeDeniedAccessToLocation userInfo:nil];
                [subject handleLocationError:error cameraError:nil];

                alertView = [UIAlertView currentAlertView];
            });

            it(@"should display a correctly configured alert", ^{
                alertView should_not be_nil;

                alertView.title should equal(RPLocalizedString(GPSAccessDisabledErrorAlertTitle, @""));
                alertView.message should equal(RPLocalizedString(GPSAccessDisabledError, @""));

                if(canOpenSettings) {
                    alertView.numberOfButtons should equal(2);
                    [alertView buttonTitleAtIndex:0] should equal(RPLocalizedString(@"Cancel", @""));
                    [alertView buttonTitleAtIndex:1] should equal(RPLocalizedString(@"Settings", @""));
                } else {
                    alertView.numberOfButtons should equal(1);
                    [alertView buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @""));
                }
            });

            it(@"should dismiss the alert view when the cancel button is tapped", ^{
                [alertView dismissWithCancelButton];

                [UIAlertView currentAlertView] should be_nil;
            });

            if(canOpenSettings)
            {
                it(@"should take the user to the settings screen when the settings button is tapped", ^{
                    sharedApplication stub_method(@selector(openURL:));

                    [alertView dismissWithClickedButtonIndex:AllowAccessAlertHelperPunchAlertButtonSettings animated:NO];

                    sharedApplication should have_received(@selector(openURL:));
                    NSInvocation *invocation = [[sharedApplication sent_messages] firstObject];
                    __autoreleasing NSURL *url;
                    [invocation getArgument:&url atIndex:2];
                    url.absoluteString should equal(UIApplicationOpenSettingsURLString);
                });
            }
        });

        describe(@"when the punch assembly workflow failed to get access to the phone's camera", ^{
            beforeEach(^{
                NSError *cameraError = [[NSError alloc] initWithDomain:PunchAssemblyGuardErrorDomain code:CameraAssemblyGuardErrorCodeDeniedAccessToCamera userInfo:nil];
                [subject handleLocationError:nil cameraError:cameraError];
                alertView = [UIAlertView currentAlertView];
            });

            it(@"should display a correctly configured alert", ^{
                alertView should_not be_nil;

                alertView.title should equal(RPLocalizedString(CameraAccessDisabledErrorAlertTitle, @""));
                alertView.message should equal(RPLocalizedString(CameraAccessDisabledError, @""));

                if(canOpenSettings) {
                    alertView.numberOfButtons should equal(2);
                    [alertView buttonTitleAtIndex:0] should equal(RPLocalizedString(@"Cancel", @""));
                    [alertView buttonTitleAtIndex:1] should equal(RPLocalizedString(@"Settings", @""));
                } else {
                    alertView.numberOfButtons should equal(1);
                    [alertView buttonTitleAtIndex:0] should equal(RPLocalizedString(@"OK", @""));}

            });

            it(@"should dismiss the alert view when the cancel button is tapped", ^{
                [alertView dismissWithCancelButton];

                [UIAlertView currentAlertView] should be_nil;
            });

            if(canOpenSettings)
            {
                it(@"should take the user to the settings screen when the settings button is tapped", ^{
                    sharedApplication stub_method(@selector(openURL:));

                    [alertView dismissWithClickedButtonIndex:AllowAccessAlertHelperPunchAlertButtonSettings animated:NO];

                    sharedApplication should have_received(@selector(openURL:));
                    NSInvocation *invocation = [[sharedApplication sent_messages] firstObject];
                    __autoreleasing NSURL *url;
                    [invocation getArgument:&url atIndex:2];
                    url.absoluteString should equal(UIApplicationOpenSettingsURLString);
                });
            }
        });
    });
});

SPEC_END
