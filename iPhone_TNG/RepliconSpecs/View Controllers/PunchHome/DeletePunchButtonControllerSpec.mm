#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>

#import "DeletePunchButtonController.h"
#import "InjectorProvider.h"
#import "UIControl+Spec.h"
#import "ButtonStylist.h"
#import "Theme.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(DeletePunchButtonControllerSpec)

describe(@"DeletePunchButtonController", ^{
    __block DeletePunchButtonController *subject;
    __block ButtonStylist *buttonStylist;
    __block id<DeletePunchButtonControllerDelegate> delegate;
    __block id<Theme> theme;
    __block id<BSInjector, BSBinder> injector;

    beforeEach(^{
        injector = [InjectorProvider injector];

        buttonStylist = nice_fake_for([ButtonStylist class]);
        [injector bind:[ButtonStylist class] toInstance:buttonStylist];

        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];
        
        subject = [injector getInstance:[DeletePunchButtonController class]];

        delegate = nice_fake_for(@protocol(DeletePunchButtonControllerDelegate));
        [subject setupWithDelegate:delegate];
    });

    describe(@"deleting a punch", ^{
        beforeEach(^{
            theme stub_method(@selector(deletePunchButtonBackgroundColor)).and_return([UIColor whiteColor]);
            theme stub_method(@selector(deletePunchButtonBorderColor)).and_return([UIColor orangeColor]);
            theme stub_method(@selector(deletePunchButtonTitleColor)).and_return([UIColor greenColor]);
            subject.view should_not be_nil;

        });

        it(@"should style the punch button appropriately", ^{
            buttonStylist should have_received(@selector(styleButton:title:titleColor:backgroundColor:borderColor:))
                .with(subject.deletePunchButton, @"Delete Punch", [UIColor greenColor], [UIColor whiteColor], [UIColor orangeColor]);
        });

        context(@"when the punch button is tapped", ^{
            beforeEach(^{
                [subject.deletePunchButton tap];
            });

            it(@"should notify its delegate", ^{
                delegate should have_received(@selector(deletePunchButtonControllerDidSignalIntentToDeletePunch:)).with(subject);
            });
        });

    });
});

SPEC_END
