#import <Cedar/Cedar.h>
#import "ApproveRejectHeaderStylist.h"
#import "Theme.h"
#import "ApprovalsPendingTimeOffTableViewHeader.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(ApproveRejectHeaderStylistSpec)

describe(@"ApproveRejectHeaderStylist", ^{
    __block ApproveRejectHeaderStylist *subject;
    __block id<Theme> theme;

    beforeEach(^{
        theme = nice_fake_for(@protocol(Theme));
        subject = [[ApproveRejectHeaderStylist alloc] initWithTheme:theme];
    });

    describe(@"styling a header view", ^{
        __block ApprovalsPendingTimeOffTableViewHeader *headerView;

        beforeEach(^{
            headerView = [[ApprovalsPendingTimeOffTableViewHeader alloc] initWithReuseIdentifier:@""];

            theme stub_method(@selector(defaultTableViewHeaderButtonFont)).and_return([UIFont systemFontOfSize:9.0f]);
            theme stub_method(@selector(defaultTableViewHeaderBackgroundColor)).and_return([UIColor magentaColor]);
            theme stub_method(@selector(separatorViewBackgroundColor)).and_return([UIColor greenColor]);

            [subject styleApproveRejectHeader:headerView];
        });

        it(@"should set the background color", ^{
            headerView.contentView.backgroundColor should equal([UIColor magentaColor]);
        });

        it(@"should set the fonts on the buttons", ^{
            headerView.approveButton.titleLabel.font should equal([UIFont systemFontOfSize:9.0f]);
            headerView.rejectButton.titleLabel.font should equal([UIFont systemFontOfSize:9.0f]);
        });

        it(@"should set the color on the separator view", ^{
            headerView.separatorView.backgroundColor should equal([UIColor greenColor]);
        });
    });
});

SPEC_END
