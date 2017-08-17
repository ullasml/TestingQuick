#import <Cedar/Cedar.h>
#import "SegmentedControlStylist.h"
#import "Theme.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(SegmentedControlStylistSpec)

describe(@"SegmentedControlStylist", ^{
    __block SegmentedControlStylist *subject;
    __block id<Theme> theme;

    beforeEach(^{
        theme = nice_fake_for(@protocol(Theme));
        subject = [[SegmentedControlStylist alloc] initWithTheme:theme];
    });

    describe(@"styling a segmented control", ^{
        __block UISegmentedControl *segmentedControl;

        beforeEach(^{
            theme stub_method(@selector(segmentedControlTintColor)).and_return([UIColor greenColor]);
            theme stub_method(@selector(segmentedControlTextColor)).and_return([UIColor magentaColor]);
            theme stub_method(@selector(segmentedControlFont)).and_return([UIFont systemFontOfSize:12.0f]);

            segmentedControl = nice_fake_for([UISegmentedControl class]);
            [subject styleSegmentedControl:segmentedControl];
        });

        it(@"should set the tint color", ^{
            segmentedControl should have_received(@selector(setTintColor:)).with([UIColor greenColor]);
        });

        it(@"should set the text color and font", ^{
            NSDictionary *expectedAttributes = @{
                                                 NSFontAttributeName : [UIFont systemFontOfSize:12.0f],
                                                 NSForegroundColorAttributeName : [UIColor magentaColor],
                                                 };
            segmentedControl should have_received(@selector(setTitleTextAttributes:forState:)).with(expectedAttributes, UIControlStateNormal);
        });
    });
});

SPEC_END
