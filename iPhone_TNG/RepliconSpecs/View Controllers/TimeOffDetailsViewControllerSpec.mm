#import <Cedar/Cedar.h>
#import "TimeOffDetailsViewController.h"
#import "TimeOffObject.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TimeOffDetailsViewControllerSpec)

describe(@"TimeOffDetailsViewController", ^{
    __block TimeOffDetailsViewController *subject;
    __block TimeOffObject *timeOffObject;
    __block NSString *sheetIdString;
    __block NSInteger screenMode;

    beforeEach(^{
//        NSDictionary *dataDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:<#(nonnull id), ...#>, nil]
        timeOffObject = nice_fake_for([TimeOffObject class]);
        subject = [[TimeOffDetailsViewController alloc] initWithEntryDetails:timeOffObject sheetId:sheetIdString screenMode:screenMode];
    });
    
    describe(@"ViewDidLoad", ^{
        beforeEach(^{
            subject.view should_not be_nil;
        });
        
        it(@"should color the background", ^{
            subject.view.backgroundColor should equal([UIColor whiteColor]);
        });
    });

});

SPEC_END
