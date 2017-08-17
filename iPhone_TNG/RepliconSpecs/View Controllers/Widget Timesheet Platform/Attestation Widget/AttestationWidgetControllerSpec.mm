#import <Cedar/Cedar.h>
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(AttestationWidgetControllerSpec)

describe(@"AttestationWidgetController", ^{
    __block AttestationWidgetController *subject;    
    __block id<AttestationWidgetControllerDelegate> delegate;
    __block id<BSBinder, BSInjector> injector;
    
    beforeEach(^{
        injector = (id)[InjectorProvider injector];
        delegate = nice_fake_for(@protocol(AttestationWidgetControllerDelegate));
        subject = [injector getInstance:[AttestationWidgetController class]];
    });
    
    describe(@"When the view layouts", ^{
        beforeEach(^{
            [subject setupWithTitle:@"some-title" description:@"some-description" status:Unattested delegate:delegate];
            subject.view should_not be_nil;
            [subject viewDidLayoutSubviews];
        });
        
        it(@"should inform its delegate to update its height", ^{
            delegate should have_received(@selector(attestationWidgetController:didIntendToUpdateItsContainerHeight:)).with(subject,Arguments::anything);
        });
    });
    
    describe(@"When the notice widget has title", ^{
        beforeEach(^{
            [subject setupWithTitle:@"some-title" description:@"some-description" status:Unattested delegate:delegate];
            subject.view should_not be_nil;
            [subject viewDidLayoutSubviews];
        });
        
        it(@"should correctly set the title and description", ^{
            subject.titleLabel.text should equal(@"some-title");
            subject.descriptionLabel.text should equal(@"some-description");
            subject.attestationStatusLabel.text should equal(RPLocalizedString(@"I don't Accept", nil));
            subject.attestationSwitch.isOn should be_falsy;
        });
        
    });
    
    describe(@"When the notice widget has no title", ^{
        beforeEach(^{
            [subject setupWithTitle:nil description:@"some-description" status:Attested delegate:delegate];
            subject.view should_not be_nil;
            [subject viewDidLayoutSubviews];
        });
        
        it(@"should correctly set the title and description", ^{
            subject.titleLabel.text should equal(RPLocalizedString(@"Attestation", nil));
            subject.descriptionLabel.text should equal(@"some-description");
            subject.attestationStatusLabel.text should equal(RPLocalizedString(@"I Accept", nil));
            subject.attestationSwitch.isOn should be_truthy;

        });
    });
});

SPEC_END
