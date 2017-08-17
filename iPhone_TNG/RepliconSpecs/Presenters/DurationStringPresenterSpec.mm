#import <Cedar/Cedar.h>
#import "DurationStringPresenter.h"
#import "Theme.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


void assertAttribute(NSAttributedString *string, NSUInteger location, NSUInteger length, NSString *attributeName, id attribute) {
    NSRange inRange = NSMakeRange(location, length);
    NSRange longestEffectiveRange;
    id appliedAttribute = [string attribute:attributeName
                                    atIndex:location
                      longestEffectiveRange:&longestEffectiveRange
                                    inRange:inRange];
    longestEffectiveRange.location should equal(location);
    longestEffectiveRange.length should equal(length);
    appliedAttribute should equal(attribute);
};


SPEC_BEGIN(DurationStringPresenterSpec)

describe(NSStringFromClass([DurationStringPresenter class]), ^{
    __block DurationStringPresenter *subject;
    __block id<Theme> theme;

    beforeEach(^{
        theme = nice_fake_for(@protocol(Theme));
        subject = [[DurationStringPresenter alloc] initWithTheme:theme];
    });

    describe(NSStringFromSelector(@selector(durationStringWithHours:minutes:seconds:)), ^{
        __block NSAttributedString *durationString;

        beforeEach(^{
            theme stub_method(@selector(durationLabelTextColor)).and_return([UIColor purpleColor]);

            theme stub_method(@selector(durationLabelBigNumberFont)).and_return([UIFont systemFontOfSize:20.0f]);
            theme stub_method(@selector(durationLabelLittleNumberFont)).and_return([UIFont systemFontOfSize:10.0f]);

            theme stub_method(@selector(durationLabelBigTimeUnitFont)).and_return([UIFont systemFontOfSize:15.0f]);
            theme stub_method(@selector(durationLabelLittleTimeUnitFont)).and_return([UIFont systemFontOfSize:5.0f]);

            durationString = [subject durationStringWithHours:1 minutes:2 seconds:3];
        });

        it(@"should use the same text color over the whole string", ^{
            assertAttribute(durationString, 0, 14, NSForegroundColorAttributeName, [UIColor purpleColor]);
        });

        it(@"should style the hour number correctly", ^{
            assertAttribute(durationString, 0, 1, NSFontAttributeName, [UIFont systemFontOfSize:20.0f]);
        });

        it(@"should style the hour time unit correctly", ^{
            assertAttribute(durationString, 1, 1, NSFontAttributeName, [UIFont systemFontOfSize:15.0f]);
        });

        it(@"should style the first semicolon correctly", ^{
            assertAttribute(durationString, 3, 1, NSFontAttributeName, [UIFont systemFontOfSize:20.0f]);
        });

        it(@"should style the minutes number correctly", ^{
            assertAttribute(durationString, 5, 2, NSFontAttributeName, [UIFont systemFontOfSize:20.0f]);
        });

        it(@"should style the minutes time unit correctly", ^{
            assertAttribute(durationString, 7, 1, NSFontAttributeName, [UIFont systemFontOfSize:15.0f]);
        });

        it(@"should style the second semicolon correctly", ^{
            assertAttribute(durationString, 9, 1, NSFontAttributeName, [UIFont systemFontOfSize:10.0f]);
        });

        it(@"should style the minutes number correctly", ^{
            assertAttribute(durationString, 11, 2, NSFontAttributeName, [UIFont systemFontOfSize:10.0f]);
        });

        it(@"should style the seconds time unit correctly", ^{
            assertAttribute(durationString, 13, 1, NSFontAttributeName, [UIFont systemFontOfSize:5.0f]);
        });

        it(@"should return a string with the correct value", ^{
            durationString.string should equal(@"1h : 02m : 03s");
        });
    });

});

SPEC_END

