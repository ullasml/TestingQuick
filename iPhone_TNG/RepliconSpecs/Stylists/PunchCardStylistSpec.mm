#import <Cedar/Cedar.h>
#import "PunchCardStylist.h"
#import "Theme.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(PunchCardStylistSpec)

describe(@"PunchCardStylist", ^{
    __block PunchCardStylist *subject;
    __block id <Theme> theme;

    beforeEach(^{
        theme = nice_fake_for(@protocol(Theme));

        theme stub_method(@selector(carouselPunchCardCornerRadius)).and_return((CGFloat)12.0);
        theme stub_method(@selector(carouselPunchCardContainerBorderColor)).and_return([UIColor yellowColor].CGColor);
        theme stub_method(@selector(carouselPunchCardContainerBorderWidth)).and_return((CGFloat)8.0);
        
        theme stub_method(@selector(oefPunchCardCornerRadius)).and_return((CGFloat)10.0);
        theme stub_method(@selector(oefPunchCardContainerBorderColor)).and_return([UIColor redColor].CGColor);
        theme stub_method(@selector(oefPunchCardContainerBorderWidth)).and_return((CGFloat)5.0);

        subject = [[PunchCardStylist alloc]initWithTheme:theme];

    });

    describe(@"-styleBorderForView:", ^{
        __block UIView *view;
        beforeEach(^{
            view = [[UIView alloc]init];
            [subject styleBorderForView:view];
        });

        it(@"should style the view correctly", ^{
            view.layer.cornerRadius should equal((CGFloat)12.0);
            view.layer.borderColor should equal([UIColor yellowColor].CGColor);
            view.layer.borderWidth should equal((CGFloat)8.0);
        });
    });
    
    describe(@"-styleBorderForOEFView:", ^{
        __block UIView *view;
        beforeEach(^{
            view = [[UIView alloc]init];
            [subject styleBorderForOEFView:view];
        });
        
        it(@"should style the view correctly", ^{
            view.layer.cornerRadius should equal((CGFloat)10.0);
            view.layer.borderColor should equal([UIColor redColor].CGColor);
            view.layer.borderWidth should equal((CGFloat)5.0);
        });
    });

});

SPEC_END
