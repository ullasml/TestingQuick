#import <Cedar/Cedar.h>
#import "PunchLogDeserializer.h"
#import "RepliconSpecHelper.h"
#import "PunchLog.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(PunchLogDeserializerSpec)

describe(@"PunchLogDeserializer", ^{
    __block PunchLogDeserializer *subject;

    beforeEach(^{
        subject = [[PunchLogDeserializer alloc] init];
    });

    describe(@"-deserialize:", ^{
        it(@"should return an array of punch logs", ^{
            NSArray *json = [RepliconSpecHelper jsonArrayWithFixture:@"punch_log_audit_trail"];

            NSArray *logs = [subject deserialize:json];

            logs.count should equal(2);
            
            PunchLog *punchLog1 = logs.firstObject;
            punchLog1.text should equal(@"Added 2:12 PM, Activity \"Performance Review\", By oef, pact On Jun 21, 2017 At 2:12 PM, Via Mobile");
            
            PunchLog *punchLog2 = logs.lastObject;;
            punchLog2.text should equal(@"Edited To 2:13 PM, By oef, pact On Jun 21, 2017 At 8:13 PM, Via Mobile");
        });
    });
});

SPEC_END
