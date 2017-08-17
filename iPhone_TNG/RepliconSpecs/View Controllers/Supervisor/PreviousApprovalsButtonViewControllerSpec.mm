#import <Cedar/Cedar.h>
#import "UIControl+Spec.h"
#import "ButtonStylist.h"
#import "Theme.h"
#import "PreviousApprovalsButtonViewController.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PreviousApprovalsButtonViewControllerSpec)

describe(@"PreviousApprovalsButtonViewController", ^{
    __block PreviousApprovalsButtonViewController *subject;
    __block id <PreviousApprovalsButtonControllerDelegate> delegate;
    __block ButtonStylist *buttonStylist;
    __block id<Theme> theme;
    
    beforeEach(^{
        delegate = nice_fake_for(@protocol(PreviousApprovalsButtonControllerDelegate));
        buttonStylist =  nice_fake_for([ButtonStylist class]);
        theme = nice_fake_for(@protocol(Theme));
        
        subject = [[PreviousApprovalsButtonViewController alloc] initWithDelegate:delegate
                                                        buttonStylist:buttonStylist
                                                                theme:theme];
        subject.title = @"";
    });
    
    describe(@"after the view loads", ^{
        beforeEach(^{
            theme stub_method(@selector(viewPreviousApprovalsButtonTitleColor)).and_return([UIColor orangeColor]);
            theme stub_method(@selector(viewPreviousApprovalsButtonBackgroundColor)).and_return([UIColor yellowColor]);
            theme stub_method(@selector(viewPreviousApprovalsButtonBorderColor)).and_return([UIColor redColor]);
            [subject view];
        });
        
        it(@"should have a 'View Previous Approvals' button", ^{
            subject.view should contain(subject.viewPreviousApprovalsButton);
        });
        
        describe(@"when the user taps the 'View Previous Approvals' button", ^{
            beforeEach(^{
                [subject.viewPreviousApprovalsButton tap];
            });
            
            it(@"should notify its delegate", ^{
                delegate should have_received(@selector(approvalsButtonControllerWillNavigateToPreviousApprovalsScreen:)).with(subject);
            });
        });
        
        it(@"use its stylist to style the button", ^{
            buttonStylist should have_received(@selector(styleButton:title:titleColor:backgroundColor:borderColor:))
            .with(subject.viewPreviousApprovalsButton, @"", [UIColor orangeColor], [UIColor yellowColor], [UIColor redColor]);
        });
    });
});


SPEC_END
