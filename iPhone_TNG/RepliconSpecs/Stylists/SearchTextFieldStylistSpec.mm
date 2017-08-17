#import <Cedar/Cedar.h>
#import "SearchTextFieldStylist.h"
#import "Theme.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(SearchTextFieldStylistSpec)

describe(@"SearchTextFieldStylist", ^{
    __block SearchTextFieldStylist *subject;
    __block id<Theme> theme;

    beforeEach(^{
        theme = fake_for(@protocol(Theme));
        subject = [[SearchTextFieldStylist alloc] initWithTheme:theme];
    });

    describe(NSStringFromSelector(@selector(applyThemeToTextField:)), ^{
        __block UITextField *textField;

        beforeEach(^{
            theme stub_method(@selector(searchTextFieldFont)).and_return([UIFont systemFontOfSize:6]);
            theme stub_method(@selector(searchTextFieldBackgroundColor)).and_return([UIColor magentaColor]);

            textField = [[UITextField alloc] init];

            [subject applyThemeToTextField:textField];
        });

        it(@"should set the font from the theme", ^{
            textField.font should equal([UIFont systemFontOfSize:6]);
        });

        it(@"should set the background color from the theme", ^{
            textField.backgroundColor should equal([UIColor magentaColor]);
        });
    });
});

SPEC_END
