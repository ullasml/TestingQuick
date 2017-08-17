#import <Cedar/Cedar.h>
#import "BookedTimeOff.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(BookedTimeOffSpec)

describe(@"BookedTimeOff", ^{
    describe(NSStringFromSelector(@selector(isEqual:)), ^{
        __block BookedTimeOff *bookedTimeOffA;
        __block BookedTimeOff *bookedTimeOffB;

        it(@"should not be equal when comparing a different type of object", ^{
            bookedTimeOffA = [[BookedTimeOff alloc] initWithDescriptionText:@"ASDF"];
            bookedTimeOffB = [(id)[NSObject alloc] init];

            bookedTimeOffA should_not equal(bookedTimeOffB);
        });

        it(@"should not be equal when initialized with different values", ^{
            bookedTimeOffA = [[BookedTimeOff alloc] initWithDescriptionText:@"Some Time off Description A"];
            bookedTimeOffB = [[BookedTimeOff alloc] initWithDescriptionText:@"Some Time off Description B"];

            bookedTimeOffA should_not equal(bookedTimeOffB);
        });

        it(@"should be equal when initialized with the same values", ^{
            bookedTimeOffA = [[BookedTimeOff alloc] initWithDescriptionText:@"Some Time off Description"];
            bookedTimeOffB = [[BookedTimeOff alloc] initWithDescriptionText:@"Some Time off Description"];

            bookedTimeOffA should equal(bookedTimeOffB);
        });

    });
});

SPEC_END
