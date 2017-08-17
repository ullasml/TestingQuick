#import <Cedar/Cedar.h>
#import "TeamSectionHeaderView.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(UserSummarySectionHeaderViewSpec)

describe(@"TeamSectionHeaderView", ^{
    __block TeamSectionHeaderView *subject;

    beforeEach(^{
        subject = [[TeamSectionHeaderView alloc] init];
    });

    describe(@"initialization", ^{
        it(@"should add the section title label as a subview", ^{
            subject.subviews should contain(subject.sectionTitleLabel);
        });
    });
});

SPEC_END
