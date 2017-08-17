#import <Cedar/Cedar.h>
#import "NavigationBarStylist.h"
#import "Theme.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(NavigationBarStylistSpec)

describe(@"NavigationBarStylist", ^{
    __block NavigationBarStylist *subject;
    __block UIBarButtonItem *barButtonItemAppearance;
    __block UINavigationBar *navigationBarAppearance;
    __block id<Theme>theme;

    beforeEach(^{
        barButtonItemAppearance = nice_fake_for([UIBarButtonItem class]);
        navigationBarAppearance = nice_fake_for([UINavigationBar class]);
        theme = nice_fake_for(@protocol(Theme));

        subject = [[NavigationBarStylist alloc] initWithBarButtonItemAppearance:barButtonItemAppearance
                                                        navigationBarAppearance:navigationBarAppearance
                                                                          theme:theme];
    });

    describe(NSStringFromSelector(@selector(styleNavigationBar)), ^{
        beforeEach(^{
            theme stub_method(@selector(navigationBarTintColor)).and_return([UIColor greenColor]);
            theme stub_method(@selector(navigationBarTitleFont)).and_return([UIFont systemFontOfSize:18]);

            [subject styleNavigationBar];
        });

        it(@"should set the tint color of the navigation bar", ^{
            navigationBarAppearance should have_received(@selector(setTintColor:)).with([UIColor greenColor]);
        });

        it(@"should set the title text attributes of the bar button item", ^{
            NSDictionary *expectedTextAttributesDictionary = @{
                                                               NSFontAttributeName: [UIFont systemFontOfSize:18]
                                                               };

            barButtonItemAppearance should have_received(@selector(setTitleTextAttributes:forState:)).with(expectedTextAttributesDictionary, UIControlStateNormal);
        });
    });
});

SPEC_END
