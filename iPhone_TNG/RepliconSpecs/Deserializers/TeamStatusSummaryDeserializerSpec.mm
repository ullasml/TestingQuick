#import <Cedar/Cedar.h>
#import "TeamStatusSummaryDeserializer.h"
#import "TeamStatusSummary.h"
#import "RepliconSpecHelper.h"
#import "PunchUserDeserializer.h"
#import "PunchUser.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(TeamStatusSummaryDeserializerSpec)

describe(NSStringFromClass([TeamStatusSummaryDeserializer class]), ^{
    __block PunchUserDeserializer *punchUserDeserializer;
    __block TeamStatusSummaryDeserializer *subject;

    beforeEach(^{
        punchUserDeserializer = nice_fake_for([PunchUserDeserializer class]);
        subject = [[TeamStatusSummaryDeserializer alloc] initWithPunchUserDeserializer:punchUserDeserializer];
    });

    describe(NSStringFromSelector(@selector(deserialize:)), ^{
        __block TeamStatusSummary *teamStatusSummary;
        __block PunchUser *notInUserA;
        __block PunchUser *notInUserB;
        __block PunchUser *onBreakUser;
        __block PunchUser *clockedInUser;

        beforeEach(^{
            NSDictionary *jsonDictionary =  [RepliconSpecHelper jsonWithFixture:@"teamstatus_summary"];

            notInUserA = nice_fake_for([PunchUser class]);
            notInUserB = nice_fake_for([PunchUser class]);
            onBreakUser = nice_fake_for([PunchUser class]);
            clockedInUser = nice_fake_for([PunchUser class]);

            NSDictionary *dataDictionary = jsonDictionary[@"d"];
            punchUserDeserializer stub_method(@selector(deserialize:)).with(dataDictionary[@"notInUsers"][0]).and_return(notInUserA);
            punchUserDeserializer stub_method(@selector(deserialize:)).with(dataDictionary[@"notInUsers"][1]).and_return(notInUserB);
            punchUserDeserializer stub_method(@selector(deserialize:)).with(dataDictionary[@"onBreakUsers"][0]).and_return(onBreakUser);
            punchUserDeserializer stub_method(@selector(deserialize:)).with(dataDictionary[@"clockedInUsers"][0]).and_return(clockedInUser);

            teamStatusSummary = [subject deserialize:jsonDictionary];
        });

        it(@"should create correctly configured user objects for each category of user in the response", ^{
            teamStatusSummary.usersInArray.count should equal(1);
            teamStatusSummary.usersInArray.firstObject should be_same_instance_as(clockedInUser);

            teamStatusSummary.usersOnBreakArray.count should equal(1);
            teamStatusSummary.usersOnBreakArray.firstObject should be_same_instance_as(onBreakUser);

            teamStatusSummary.usersNotInArray.count should equal(2);
            teamStatusSummary.usersNotInArray.firstObject should be_same_instance_as(notInUserA);
            teamStatusSummary.usersNotInArray.lastObject should be_same_instance_as(notInUserB);
        });
    });
});

SPEC_END
