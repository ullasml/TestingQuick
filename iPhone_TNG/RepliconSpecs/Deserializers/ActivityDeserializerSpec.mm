
#import <Cedar/Cedar.h>
#import "ActivityDeserializer.h"
#import "RepliconSpecHelper.h"
#import "ClientType.h"
#import "Activity.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ActivityDeserializerSpec)

describe(@"ActivityDeserializer", ^{
    __block ActivityDeserializer *subject;
    __block NSArray *activitiesArray;

    beforeEach(^{
        subject = [[ActivityDeserializer alloc]init];
        NSDictionary *jsonDictionary= [RepliconSpecHelper jsonWithFixture:@"get_activities"];
        activitiesArray = [subject deserialize:jsonDictionary];
    });

    it(@"should deserialize clients correctly", ^{

        Activity *activityA = [[Activity alloc]initWithName:@"12345678901234567890123456789012345678901111111111"
                                                        uri:@"urn:replicon-tenant:repliconiphone-2:activity:41"];
        Activity *activityB = [[Activity alloc]initWithName:@"Coding"
                                                        uri:@"urn:replicon-tenant:repliconiphone-2:activity:7"];
        Activity *activityC = [[Activity alloc]initWithName:@"General Admin"
                                                        uri:@"urn:replicon-tenant:repliconiphone-2:activity:1"];
        Activity *activityD = [[Activity alloc]initWithName:@"Hiring"
                                                        uri:@"urn:replicon-tenant:repliconiphone-2:activity:3"];
        NSArray *expectedActivitiesArray = @[activityA,activityB,activityC,activityD];

        activitiesArray should equal(expectedActivitiesArray);
    });
});

SPEC_END
