#import <Cedar/Cedar.h>
#import "BreakTypeDeserializer.h"
#import "RepliconSpecHelper.h"
#import "BreakType.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(BreakTypeDeserializerSpec)

describe(@"BreakTypeDeserializer", ^{
    __block BreakTypeDeserializer *subject;

    beforeEach(^{
        subject = [[BreakTypeDeserializer alloc] init];
    });

    describe(@"Deserialize", ^{
        it(@"should deserialize", ^{
            NSDictionary *responseDictionary = [RepliconSpecHelper jsonWithFixture:@"break_types"];
            NSArray *breakTypeList = [subject deserialize:responseDictionary];

            BreakType *mealBreak = [[BreakType alloc] initWithName:@"Meal" uri:@"urn:replicon-tenant:astro:break-type:6c6af9ed-b4db-4507-a817-891b4605f993"];
            BreakType *restBreak = [[BreakType alloc] initWithName:@"Rest" uri:@"urn:replicon-tenant:astro:break-type:90eeab6c-0e67-49cb-a9bc-32ab7deac3e0"];
            NSArray *expectedBreakTypes = @[mealBreak, restBreak];

            breakTypeList should equal(expectedBreakTypes);
        });
    });
});

SPEC_END
