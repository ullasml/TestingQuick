#import <Cedar/Cedar.h>
#import "InboxSpinnerCell.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(InboxSpinnerCellSpec)

describe(@"InboxSpinnerCell", ^{
    __block InboxSpinnerCell *subject;

    beforeEach(^{
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSArray *nib = [mainBundle loadNibNamed:@"InboxSpinnerCell" owner:nil options:nil];
        subject = (id)[nib objectAtIndex:0];

    });

    describe(NSStringFromSelector(@selector(prepareForReuse)), ^{
        __block UIActivityIndicatorView *activityIndicatorView;
        beforeEach(^{
            activityIndicatorView = subject.activityIndicatorView;
            [activityIndicatorView stopAnimating];
            [subject prepareForReuse];
        });

        it(@"should start the animation for the activity indicator", ^{
            activityIndicatorView.isAnimating should be_truthy;
        });
    });
});

SPEC_END
