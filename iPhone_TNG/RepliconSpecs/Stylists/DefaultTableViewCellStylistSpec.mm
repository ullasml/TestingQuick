#import <Cedar/Cedar.h>
#import "DefaultTableViewCellStylist.h"
#import "Theme.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(DefaultTableViewCellStylistSpec)

describe(@"DefaultTableViewCellStylist", ^{
    __block DefaultTableViewCellStylist *subject;
    __block id<Theme> theme;

    beforeEach(^{
        theme = fake_for(@protocol(Theme));
        subject = [[DefaultTableViewCellStylist alloc] initWithTheme:theme];
    });

    describe(NSStringFromSelector(@selector(applyThemeToCell:)), ^{
        __block UITableViewCell *cell;

        beforeEach(^{
            theme stub_method(@selector(defaultTableViewCellFont)).and_return([UIFont systemFontOfSize:9]);

            cell = [[UITableViewCell alloc] init];
            [subject applyThemeToCell:cell];
        });

        it(@"should set the layout margins", ^{
            if([cell respondsToSelector:@selector(layoutMargins)])
            {
                cell.layoutMargins should equal(UIEdgeInsetsZero);
            }
        });

        it(@"should not preserve the superview's layout margins", ^{
            if([cell respondsToSelector:@selector(preservesSuperviewLayoutMargins)])
            {
                cell.preservesSuperviewLayoutMargins should equal(NO);
            }
        });

        it(@"should set the separator inset", ^{
            cell.separatorInset should equal(UIEdgeInsetsZero);
        });

        it(@"should set the font from the theme", ^{
            cell.textLabel.font should equal([UIFont systemFontOfSize:9]);
        });
    });

    describe(NSStringFromSelector(@selector(styleCell:separatorOffset:)), ^{
        __block UITableViewCell *cell;

        beforeEach(^{
            theme stub_method(@selector(defaultTableViewCellFont)).and_return([UIFont systemFontOfSize:9]);

            cell = [[UITableViewCell alloc] init];
            [subject styleCell:cell separatorOffset:15.0f];
        });

        it(@"should set the font from the theme", ^{
            cell.textLabel.font should equal([UIFont systemFontOfSize:9]);
        });

        it(@"should set the left separator inset", ^{
            cell.separatorInset.left should equal(15.0f);
        });

        it(@"should set the layout margins", ^{
            if([cell respondsToSelector:@selector(layoutMargins)])
            {
                cell.layoutMargins should equal(UIEdgeInsetsZero);
            }
        });

        it(@"should not preserve the superview's layout margins", ^{
            if([cell respondsToSelector:@selector(preservesSuperviewLayoutMargins)])
            {
                cell.preservesSuperviewLayoutMargins should equal(NO);
            }
        });
    });
});

SPEC_END
