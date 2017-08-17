#import <Cedar/Cedar.h>
#import "UIActionSheet+Spec.h"
#import "UIControl+Spec.h"

#import "WaiverController.h"
#import "Violation.h"
#import "Waiver.h"
#import "ViolationEmployee.h"
#import "ViolationSeverityPresenter.h"
#import "Theme.h"
#import "WaiverOption.h"
#import "WaiverRepository.h"
#import "SpinnerDelegate.h"
#import <KSDeferred/KSDeferred.h>
#import "SelectedWaiverOptionPresenter.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(WaiverControllerSpec)

describe(@"WaiverController", ^{
    __block WaiverController *subject;
    __block ViolationSeverityPresenter *violationSeverityPresenter;
    __block UIImage *severityImage;
    __block Violation *violation;
    __block id<Theme> theme;
    __block Waiver *waiver;
    __block WaiverOption *waiverOptionA;
    __block WaiverOption *waiverOptionB;
    __block WaiverRepository *waiverRepository;
    __block SelectedWaiverOptionPresenter *selectedWaiverOptionPresenter;
    __block id<SpinnerDelegate> spinnerDelegate;
    __block id<WaiverControllerDelegate> delegate;

    beforeEach(^{
        waiverOptionA = [[WaiverOption alloc] initWithDisplayText:@"Reduce banana consumption" value:@"banana--"];
        waiverOptionB = [[WaiverOption alloc] initWithDisplayText:@"Ignore banana consumption" value:@"ignore"];

        waiver = nice_fake_for([Waiver class]);
        waiver stub_method(@selector(displayText)).and_return(@"You have eaten far too many bananas");
        waiver stub_method(@selector(options)).and_return(@[waiverOptionA, waiverOptionB]);

        violation = [[Violation alloc] initWithSeverity:ViolationSeverityError waiver:waiver title:@"Banana violation"];

        severityImage = [[UIImage alloc] init];

        violationSeverityPresenter = fake_for([ViolationSeverityPresenter class]);
        violationSeverityPresenter stub_method(@selector(severityImageWithViolationSeverity:)).with(ViolationSeverityError).and_return(severityImage);

        spinnerDelegate = nice_fake_for(@protocol(SpinnerDelegate));

        theme = fake_for(@protocol(Theme));
        theme stub_method(@selector(waiverBackgroundColor)).and_return([UIColor greenColor]);
        theme stub_method(@selector(waiverSectionTitleTextColor)).and_return([UIColor blueColor]);
        theme stub_method(@selector(waiverSectionTitleFont)).and_return([UIFont italicSystemFontOfSize:12]);
        theme stub_method(@selector(waiverViolationTitleTextColor)).and_return([UIColor brownColor]);
        theme stub_method(@selector(waiverViolationTitleFont)).and_return([UIFont italicSystemFontOfSize:13]);
        theme stub_method(@selector(waiverDisplayTextColor)).and_return([UIColor whiteColor]);
        theme stub_method(@selector(waiverDisplayTextFont)).and_return([UIFont italicSystemFontOfSize:14]);
        theme stub_method(@selector(waiverSeparatorColor)).and_return([UIColor orangeColor]);

        theme stub_method(@selector(waiverResponseButtonTextColor)).and_return([UIColor yellowColor]);
        theme stub_method(@selector(waiverResponseButtonBackgroundColor)).and_return([UIColor greenColor]);
        theme stub_method(@selector(waiverResponseButtonBorderColor)).and_return([UIColor redColor]);
        theme stub_method(@selector(waiverResponseButtonTitleFont)).and_return([UIFont systemFontOfSize:11.0f]);
        theme stub_method(@selector(regularButtonFont)).and_return([UIFont systemFontOfSize:12.0f]);

        waiverRepository = nice_fake_for([WaiverRepository class]);

        delegate = nice_fake_for(@protocol(WaiverControllerDelegate));

        selectedWaiverOptionPresenter = [[SelectedWaiverOptionPresenter alloc] init];
        subject = [[WaiverController alloc] initWithSelectedWaiverOptionPresenter:selectedWaiverOptionPresenter
                                                       violationSeverityPresenter:violationSeverityPresenter
                                                                 waiverRepository:waiverRepository
                                                                  spinnerDelegate:spinnerDelegate
                                                                            theme:theme];

        [subject setupWithSectionTitle:@"My special title"
                             violation:violation
                              delegate:delegate];
    });

    describe(@"showing basic information about this particular violation", ^{
        beforeEach(^{
            subject.view should_not be_nil;
        });

        it(@"should display the section title", ^{
            subject.sectionTitleLabel.text should equal(@"My special title");
        });

        it(@"should display the violation title", ^{
            subject.violationTitleLabel.text should equal(@"Banana violation");
        });

        it(@"should display the waiver display text", ^{
            subject.waiverDisplayTextLabel.text should equal(@"You have eaten far too many bananas");
        });

        it(@"should set the severity icon from the presenter", ^{
            subject.severityImageView.image should be_same_instance_as(severityImage);
        });

        it(@"should style the button", ^{
            subject.responseButton.titleLabel.textColor should equal([UIColor yellowColor]);
            subject.responseButton.backgroundColor should equal([UIColor greenColor]);
            CGColorEqualToColor(subject.responseButton.layer.borderColor, [UIColor redColor].CGColor) should be_truthy;
            subject.responseButton.titleLabel.font should equal([UIFont systemFontOfSize:11.0f]);
        });
    });

    describe(@"presenting the currently selected waiver option", ^{

        context(@"when there is no currently selected waiver option", ^{
            beforeEach(^{
                subject.view should_not be_nil;
            });

            it(@"should have an appropriate title", ^{
                [subject.responseButton titleForState:UIControlStateNormal] should equal(RPLocalizedString(@"No Response", @"No Response"));
            });
        });

        context(@"when there is no currently selected waiver option", ^{
            beforeEach(^{
                waiver stub_method(@selector(selectedOption)).and_return(waiverOptionB);
                subject.view should_not be_nil;
            });

            it(@"should show the display text of the currently selected waiver option in the button title", ^{
                [subject.responseButton titleForState:UIControlStateNormal] should equal(@"Ignore banana consumption");
            });
        });
    });

    describe(@"waiving a violation", ^{
        beforeEach(^{
            subject.view should_not be_nil;
        });

        context(@"when the user taps on the response button", ^{
            __block UIActionSheet *actionSheet;
            beforeEach(^{
                [subject.responseButton tap];
                actionSheet = [UIActionSheet currentActionSheet];
            });

            it(@"should show an action sheet with the response options", ^{

                [actionSheet title] should equal(RPLocalizedString(@"Change Waiver Response", @"Change Waiver Response"));

                actionSheet.buttonTitles should equal(@[RPLocalizedString(@"Cancel", @"Cancel"), @"Reduce banana consumption",@"Ignore banana consumption"]);
            });

            context(@"when the user selects a violation waiver", ^{
                __block KSDeferred *updateDeferred;
                beforeEach(^{
                    updateDeferred = [[KSDeferred alloc] init];
                    waiverRepository stub_method(@selector(updateWaiver:withWaiverOption:)).and_return(updateDeferred.promise);

                    [actionSheet dismissByClickingButtonWithTitle:@"Reduce banana consumption"];
                });

                it(@"should show the spinner", ^{
                    spinnerDelegate should have_received(@selector(showTransparentLoadingOverlay));
                });

                it(@"should send the waiver and the chosen waiverOption to waiver respository ", ^{
                    waiverRepository should have_received(@selector(updateWaiver:withWaiverOption:)).with(waiver, waiverOptionA);
                });

                context(@"when the request is successful", ^{
                    beforeEach(^{
                        [updateDeferred resolveWithValue:(id)[NSNull null]];
                    });

                    it(@"should hide the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });

                    it(@"should tell the delegate that a new option has been selected", ^{
                        delegate should have_received(@selector(waiverController:didSelectWaiverOption:forWaiver:)).with(subject, waiverOptionA, waiver);
                    });
                });

                context(@"when the request fails", ^{
                    beforeEach(^{
                        [updateDeferred resolveWithValue:(id)[NSNull null]];
                    });

                    it(@"should hide the spinner", ^{
                        spinnerDelegate should have_received(@selector(hideTransparentLoadingOverlay));
                    });
                });
            });

            context(@"when the user cancels", ^{
                it(@"should not raise an exception", ^{
                    ^ {[actionSheet dismissByClickingButtonWithTitle:RPLocalizedString(@"Cancel", @"Cancel")]; } should_not raise_exception;
                });
            });
        });
    });

    describe(@"styling the views", ^{

        beforeEach(^{
            subject.view should_not be_nil;
        });

        it(@"should style the view", ^{
            subject.view.backgroundColor should equal([UIColor greenColor]);
        });

        it(@"should style the separators", ^{
            subject.bottomSeparatorView.backgroundColor should equal([UIColor orangeColor]);
            subject.topSeparatorView.backgroundColor should equal([UIColor orangeColor]);
            subject.separatorView.backgroundColor should equal([UIColor orangeColor]);
        });

        it(@"should style the section title label", ^{
            subject.sectionTitleLabel.textColor should equal([UIColor blueColor]);
            subject.sectionTitleLabel.font should equal([UIFont italicSystemFontOfSize:12]);
        });

        it(@"should style the violation title", ^{
            subject.violationTitleLabel.textColor should equal([UIColor brownColor]);
            subject.violationTitleLabel.font should equal([UIFont italicSystemFontOfSize:13]);
        });

        it(@"should style the waiver text", ^{
            subject.waiverDisplayTextLabel.textColor should equal([UIColor whiteColor]);
            subject.waiverDisplayTextLabel.font should equal([UIFont italicSystemFontOfSize:14]);
        });
    });
});

SPEC_END
