#import <Cedar/Cedar.h>
#import <Blindside/Blindside.h>
#import "UIControl+Spec.h"

#import "ViolationsButtonController.h"
#import "InjectorProvider.h"
#import "Theme.h"
#import <KSDeferred/KSDeferred.h>
#import "Violation.h"
#import "ButtonStylist.h"
#import "ViolationEmployee.h"
#import "AllViolationSections.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(ViolationsButtonControllerSpec)

describe(@"ViolationsButtonController", ^{
    __block ViolationsButtonController *subject;

    __block id<Theme> theme;
    __block id<ViolationsButtonControllerDelegate> delegate;
    __block ButtonStylist *buttonStylist;
    __block NSLayoutConstraint *heightConstraint;
    __block id<BSBinder, BSInjector> injector;
    __block UINavigationController *navigationController;

    beforeEach(^{
        injector = [InjectorProvider injector];

        delegate = nice_fake_for(@protocol(ViolationsButtonControllerDelegate));

        heightConstraint = [[NSLayoutConstraint alloc] init];
        delegate stub_method(@selector(violationsButtonHeightConstraint)).and_return(heightConstraint);

        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];

        buttonStylist = nice_fake_for([ButtonStylist class]);
        [injector bind:[ButtonStylist class] toInstance:buttonStylist];

        subject = [injector getInstance:[ViolationsButtonController class]];
        [subject setupWithDelegate:delegate showViolations:YES];
        navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
        spy_on(navigationController);
        navigationController stub_method(@selector(presentedViewController)).and_return(nil);
        navigationController stub_method(@selector(viewControllers)).and_return(@[[[UIViewController alloc]init]]);

    });
    
    describe(@"when show violatiosn permission is false", ^{
        beforeEach(^{
            [subject setupWithDelegate:delegate showViolations:NO];
            subject.view should_not be_nil;
            [subject viewWillAppear:YES];
        });
        
        it(@"should keep the button hidden", ^{
            subject.violationsButton.hidden should be_truthy;
        });
        
        it(@"should tell its delegate to hide the violations button", ^{
            heightConstraint.constant should equal(0.0f);
        });
    });


    describe(@"presenting the number of violations", ^{
        __block KSDeferred *deferred;
        beforeEach(^{
            deferred = [[KSDeferred alloc] init];
            theme stub_method(@selector(violationsButtonTitleColor)).and_return([UIColor redColor]);
            theme stub_method(@selector(violationsButtonBackgroundColor)).and_return([UIColor orangeColor]);
            theme stub_method(@selector(violationsButtonBorderColor)).and_return([UIColor yellowColor]);

            delegate stub_method(@selector(violationsButtonControllerDidRequestUpdatedViolationSectionsPromise:)).and_return(deferred.promise);
            subject.view should_not be_nil;
            [subject viewWillAppear:YES];
        });

        it(@"should hide the button by default", ^{
            subject.violationsButton.hidden should be_truthy;
        });

        it(@"should ask the delegate for the violations", ^{
            delegate should have_received(@selector(violationsButtonControllerDidRequestUpdatedViolationSectionsPromise:)).with(subject);
        });

        it(@"should style the button appropriately", ^{
            buttonStylist should have_received(@selector(styleButton:title:titleColor:backgroundColor:borderColor:))
                .with(subject.violationsButton, nil, [UIColor redColor], [UIColor orangeColor], [UIColor yellowColor]);
        });

        context(@"when the fetch violations request succeeds with 0 violations", ^{
            beforeEach(^{
                AllViolationSections *allViolationSections = [[AllViolationSections alloc] initWithTotalViolationsCount:0 sections:@[]];

                heightConstraint.constant = 13.f;
                [deferred resolveWithValue:allViolationSections];
            });

            it(@"should keep the button hidden", ^{
                subject.violationsButton.hidden should be_truthy;
            });

            it(@"should tell its delegate to hide the violations button", ^{
                heightConstraint.constant should equal(0.0f);
            });
        });

        context(@"when the fetch violations request succeeds with 1 violation", ^{
            __block NSArray *expectedViolations;
            beforeEach(^{
                Violation *violation = [[Violation alloc] initWithSeverity:ViolationSeverityError waiver:nil title:nil];
                expectedViolations = @[violation];
                ViolationEmployee *violationEmployee = [[ViolationEmployee alloc] initWithName:nil uri:nil violations:expectedViolations];
                AllViolationSections *allViolationSections = [[AllViolationSections alloc] initWithTotalViolationsCount:1
                                                                                                      sections:@[violationEmployee]];
                heightConstraint.constant = 0.0f;
                [deferred resolveWithValue:allViolationSections];
            });

            it(@"should show the button", ^{
                subject.violationsButton.hidden should_not be_truthy;
            });

            it(@"should style the button appropriately", ^{
                [subject.violationsButton titleForState:UIControlStateNormal] should equal(@"1 Violation");
            });

            it(@"should notify its delegate that there are violations", ^{
                heightConstraint.constant should equal(44.0f);
            });
        });

        context(@"when the fetch violations request succeeds with 2 violation", ^{
            __block NSArray *expectedViolations;
            beforeEach(^{
                Violation *violation1 = [[Violation alloc] initWithSeverity:ViolationSeverityError waiver:nil title:nil];
                Violation *violation2 = [[Violation alloc] initWithSeverity:ViolationSeverityError waiver:nil title:nil];
                expectedViolations = @[violation1, violation2];

                ViolationEmployee *violationEmployee = [[ViolationEmployee alloc] initWithName:nil uri:nil violations:expectedViolations];
                AllViolationSections *violationSections = [[AllViolationSections alloc] initWithTotalViolationsCount:2
                                                                                                      sections:@[violationEmployee]];
                heightConstraint.constant = 0.0f;
                [deferred resolveWithValue:violationSections];
            });

            it(@"should show the button", ^{
                subject.violationsButton.hidden should_not be_truthy;
            });

            it(@"should style the button appropriately", ^{
                NSString *violationsStr = [NSString stringWithFormat:@"2 %@",RPLocalizedString(@"Violations", @"")];
                [subject.violationsButton titleForState:UIControlStateNormal] should equal(violationsStr);
            });

            it(@"should notify its delegate that there are violations", ^{
                heightConstraint.constant should equal(44.0f);
            });

            it(@"should show the button", ^{
                subject.violationsButton.hidden should_not be_truthy;
            });
        });
    });

    describe(@"presenting the number of violations when UIImagePickerController is being presenting", ^{
        __block KSDeferred *deferred;
        __block UINavigationController *navigationController;

        beforeEach(^{
            deferred = [[KSDeferred alloc] init];
            theme stub_method(@selector(violationsButtonTitleColor)).and_return([UIColor redColor]);
            theme stub_method(@selector(violationsButtonBackgroundColor)).and_return([UIColor orangeColor]);
            theme stub_method(@selector(violationsButtonBorderColor)).and_return([UIColor yellowColor]);

            delegate stub_method(@selector(violationsButtonControllerDidRequestUpdatedViolationSectionsPromise:)).and_return(deferred.promise);
            navigationController = [[UINavigationController alloc] initWithRootViewController:subject];
            spy_on(navigationController);
            navigationController stub_method(@selector(presentedViewController)).and_return(nice_fake_for([UIViewController class]));
            subject.view should_not be_nil;
            [subject viewWillAppear:YES];
        });

        it(@"should hide the button by default", ^{
            subject.violationsButton.hidden should be_truthy;
        });

        it(@"should ask the delegate for the violations", ^{
            delegate should_not have_received(@selector(violationsButtonControllerDidRequestUpdatedViolationSectionsPromise:));
        });

        it(@"should style the button appropriately", ^{
            buttonStylist should have_received(@selector(styleButton:title:titleColor:backgroundColor:borderColor:))
            .with(subject.violationsButton, nil, [UIColor redColor], [UIColor orangeColor], [UIColor yellowColor]);
        });

    });

    describe(@"presenting detail about the violations (by tapping the button)", ^{
        __block KSDeferred *deferred;
        __block NSArray *expectedViolations;
        __block AllViolationSections *violationSections;

        beforeEach(^{
            deferred = [[KSDeferred alloc] init];

            delegate stub_method(@selector(violationsButtonControllerDidRequestUpdatedViolationSectionsPromise:)).and_return(deferred.promise);
            subject.view should_not be_nil;
            [subject viewWillAppear:YES];

            Violation *violation = [[Violation alloc] initWithSeverity:ViolationSeverityError waiver:nil title:nil];
            expectedViolations = @[violation];

            ViolationEmployee *violationEmployee = [[ViolationEmployee alloc] initWithName:nil uri:nil violations:expectedViolations];
            violationSections = [[AllViolationSections alloc] initWithTotalViolationsCount:1
                                                                                                  sections:@[violationEmployee]];

            [deferred resolveWithValue:violationSections];
        });

        context(@"when the violations button is tapped", ^{
            beforeEach(^{
                [subject.violationsButton tap];
            });

            it(@"should notify its delegate that the user wants to view their violations", ^{
                delegate should have_received(@selector(violationsButtonController:didSignalIntentToViewViolationSections:)).with(subject, violationSections);
            });
        });
    });
});

SPEC_END
