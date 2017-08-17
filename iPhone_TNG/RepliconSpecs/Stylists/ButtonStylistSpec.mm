#import <Cedar/Cedar.h>
#import "ButtonStylist.h"
#import "Theme.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ButtonStylistSpec)

describe(@"ButtonStylist", ^{
    __block ButtonStylist *subject;
    __block id<Theme> theme;

    beforeEach(^{
        theme = nice_fake_for(@protocol(Theme));
        subject = [[ButtonStylist alloc] initWithTheme:theme];
    });

    __block UIFont *expectedButtonFont;
    __block UIButton *button;

    describe(@"styleButton:title:titleColor:backgroundColor:borderColor:", ^{
        beforeEach(^{
            button = [[UIButton alloc] init];
            expectedButtonFont = [UIFont systemFontOfSize:12];

            theme stub_method(@selector(regularButtonFont)).and_return(expectedButtonFont);

            [subject styleButton:button
                           title:@"some title!"
                      titleColor:[UIColor greenColor]
                 backgroundColor:[UIColor purpleColor]
                     borderColor:[UIColor grayColor]];
        });

        it(@"should set the title", ^{
            button.titleLabel.text should equal(@"some title!");
        });

        it(@"should set the title label's font from the theme", ^{
            button.titleLabel.font should be_same_instance_as(expectedButtonFont);
        });

        it(@"should set the color of the title label", ^{
            [button titleColorForState:UIControlStateNormal] should equal([UIColor greenColor]);
        });

        it(@"should set the background color", ^{
            button.backgroundColor should equal([UIColor purpleColor]);
        });

        it(@"should set the border color", ^{
            button.layer.borderColor should equal([[UIColor grayColor] CGColor]);
        });
    });

    describe(@"styleRegularButton:title:", ^{
        __block UIColor *expectedTitleColor;
        __block UIColor *expectedBorderColor;
        __block UIColor *expectedBackgroundColor;

        beforeEach(^{
            button = [[UIButton alloc] init];
            expectedButtonFont = [UIFont systemFontOfSize:12];
            expectedTitleColor = [UIColor greenColor];
            expectedBorderColor = [UIColor magentaColor];
            expectedBackgroundColor = [UIColor cyanColor];

            theme stub_method(@selector(regularButtonFont)).and_return(expectedButtonFont);
            theme stub_method(@selector(regularButtonBackgroundColor)).and_return(expectedBackgroundColor);
            theme stub_method(@selector(regularButtonTitleColor)).and_return(expectedTitleColor);
            theme stub_method(@selector(regularButtonBorderColor)).and_return(expectedBorderColor);

            [subject styleRegularButton:button title:@"some title!"];
        });

        it(@"should set the title", ^{
            button.titleLabel.text should equal(@"some title!");
        });

        it(@"should set the title label's font from the theme", ^{
            button.titleLabel.font should be_same_instance_as(expectedButtonFont);
        });

        it(@"should set the title color from the theme", ^{
            [button titleColorForState:UIControlStateNormal] should be_same_instance_as(expectedTitleColor);
        });

        it(@"should set the background color", ^{
            button.backgroundColor should be_same_instance_as(expectedBackgroundColor);
        });

        it(@"should set the border color from the theme", ^{
            button.layer.borderColor should equal([expectedBorderColor CGColor]);
        });
    });
});

SPEC_END
