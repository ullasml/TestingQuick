#import <Cedar/Cedar.h>
#import "UIControl+Spec.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ViewMoreOrLessButtonControllerSpec)

describe(@"ViewMoreOrLessButtonController", ^{
    __block ViewMoreOrLessButtonController *subject;
    __block id<ViewMoreOrLessButtonControllerDelegate> delegate;

    beforeEach(^{
        delegate = nice_fake_for(@protocol(ViewMoreOrLessButtonControllerDelegate));
        subject = [[ViewMoreOrLessButtonController alloc]init];
    });
    
    describe(@"presenting the View More or less button", ^{
        context(@"When ViewItemsAction is of type More", ^{
            beforeEach(^{
                [subject setupWithViewItemsAction:More delegate:delegate];
                subject.view should_not be_nil;
            });
            
            it(@"should correctly set the tag", ^{
                subject.viewMoreOrLessButton.tag should equal(0);
            });
            
            it(@"should correctly set the title", ^{
                subject.viewMoreOrLessButton.currentTitle should equal(RPLocalizedString(@"Show More", nil));
            });
        });
        context(@"When ViewItemsAction is of type Less", ^{
            beforeEach(^{
                [subject setupWithViewItemsAction:Less delegate:delegate];
                subject.view should_not be_nil;

            });
            it(@"should correctly set the tag", ^{
                subject.viewMoreOrLessButton.tag should equal(1);
            });
            it(@"should correctly set the title", ^{
                subject.viewMoreOrLessButton.currentTitle should equal(RPLocalizedString(@"Show Less", nil));
            });
        });
    });
    
    describe(@"When the view loads", ^{
        beforeEach(^{
            [subject setupWithViewItemsAction:More delegate:delegate];
            subject.view should_not be_nil;
            [subject viewDidLayoutSubviews];
        });
        
        it(@"should inform its delegate to update its height", ^{
            delegate should have_received(@selector(viewMoreOrLessButtonController:intendsToUpdateItsContainerWithHeight:)).with(subject,Arguments::anything);
        });
    });
    
    describe(@"tapping the button", ^{
        beforeEach(^{
            [subject setupWithViewItemsAction:More delegate:delegate];
            subject.view should_not be_nil;
            [subject.viewMoreOrLessButton tap];
        });
        
        it(@"should inform its delegate its intent to view more items", ^{
            delegate should have_received(@selector(viewMoreOrLessButtonControllerIntendsToViewMoreItems:)).with(subject);
            subject.viewMoreOrLessButton.currentTitle should equal(RPLocalizedString(@"Show Less", nil));
            subject.viewMoreOrLessButton.tag should equal(1);
        });
        
        it(@"should inform its delegate its intent to view less items", ^{
            [subject.viewMoreOrLessButton tap];
            delegate should have_received(@selector(viewMoreOrLessButtonControllerIntendsToViewLessItems:)).with(subject);
            subject.viewMoreOrLessButton.currentTitle should equal(RPLocalizedString(@"Show More", nil));
            subject.viewMoreOrLessButton.tag should equal(0);
        });
    });
    
});

SPEC_END
