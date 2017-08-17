#import <Cedar/Cedar.h>
#import "ViolationSeverityPresenter.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ViolationSeverityPresenterSpec)

describe(@"ViolationSeverityPresenter", ^{
    __block ViolationSeverityPresenter *subject;

    beforeEach(^{
        subject = [[ViolationSeverityPresenter alloc] init];
    });

    describe(@"severityImageWithViolationSeverity:", ^{
        it(@"returns the correct icon for an error", ^{
            UIImage *image = [subject severityImageWithViolationSeverity:ViolationSeverityError];
            image should equal([UIImage imageNamed:@"icon_severity_error"]);
        });

        it(@"returns the correct icon for a warning", ^{
            UIImage *image = [subject severityImageWithViolationSeverity:ViolationSeverityWarning];
            image should equal([UIImage imageNamed:@"icon_severity_warning"]);
        });

        it(@"returns the correct icon for an info", ^{
            UIImage *image = [subject severityImageWithViolationSeverity:ViolationSeverityInfo];
            image should equal([UIImage imageNamed:@"icon_severity_info"]);
        });
    });
});

SPEC_END
