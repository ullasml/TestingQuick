#import <Cedar/Cedar.h>
#import "BookedTimeOffDeserializer.h"
#import "RepliconSpecHelper.h"
#import "BookedTimeOff.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(BookedTimeOffDeserializerSpec)

describe(@"BookedTimeOffDeserializer", ^{
    __block BookedTimeOffDeserializer *subject;

    beforeEach(^{

        subject = [[BookedTimeOffDeserializer alloc]init];
    });

    describe(NSStringFromSelector(@selector(deserialize:)), ^{

        context(@"Should deserialize the dictionary to object", ^{

            __block BookedTimeOff *expectedBookedTimeOff;
            __block BookedTimeOff *deserializedBookedTimeOff;
            beforeEach(^{

                expectedBookedTimeOff = [[BookedTimeOff alloc] initWithDescriptionText:@"Banked Time: 2:00 PM to 4:00 PM"];
                NSDictionary *jsonDictionary= [RepliconSpecHelper jsonWithFixture:@"teamstatus_summary_with_timeoff"];
                NSDictionary *bookedTimeOffDictionary = jsonDictionary[@"d"][@"notInUsers"][0][@"timeOffDetails"][0];
                deserializedBookedTimeOff= [subject deserialize:bookedTimeOffDictionary];
            });

            it(@"Expected and deserialized booked Time off objects should be equal", ^{
                expectedBookedTimeOff should equal(deserializedBookedTimeOff);
            });
        });
    });
});

SPEC_END
