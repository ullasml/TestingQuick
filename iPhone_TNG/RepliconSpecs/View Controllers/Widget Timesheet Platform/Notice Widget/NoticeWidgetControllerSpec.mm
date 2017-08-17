#import <Cedar/Cedar.h>
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NoticeWidgetControllerSpec)

describe(@"NoticeWidgetController", ^{
    __block NoticeWidgetController *subject;    
    __block id<NoticeWidgetControllerDelegate> delegate;
    __block id<BSBinder, BSInjector> injector;
    
    beforeEach(^{
        injector = (id)[InjectorProvider injector];
        delegate = nice_fake_for(@protocol(NoticeWidgetControllerDelegate));
        subject = [injector getInstance:[NoticeWidgetController class]];
    });
    
    describe(@"When the view layouts", ^{
        beforeEach(^{
            [subject setupWithTitle:@"some-title" description:@"some-description" delegate:delegate];
            subject.view should_not be_nil;
            [subject viewDidLayoutSubviews];
        });
        
        it(@"should inform its delegate to update its height", ^{
            delegate should have_received(@selector(noticeWidgetController:didIntendToUpdateItsContainerHeight:)).with(subject,Arguments::anything);
        });
    });
    
    describe(@"When the notice widget has title", ^{
        beforeEach(^{
            [subject setupWithTitle:@"some-title" description:@"some-description" delegate:delegate];
            subject.view should_not be_nil;
            [subject viewDidLayoutSubviews];
        });
        
        it(@"should correctly set the title and description", ^{
            subject.titleLabel.text should equal(@"some-title");
            subject.descriptionLabel.text should equal(@"some-description");
        });
        
    });
    
    describe(@"When the notice widget has no title", ^{
        beforeEach(^{
            [subject setupWithTitle:nil description:@"some-description" delegate:delegate];
            subject.view should_not be_nil;
            [subject viewDidLayoutSubviews];
        });
        
        it(@"should correctly set the title and description", ^{
            subject.titleLabel.text should equal(RPLocalizedString(@"Notice", nil));
            subject.descriptionLabel.text should equal(@"some-description");
        });
    });
});

SPEC_END
