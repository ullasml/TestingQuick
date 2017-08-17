#import <Cedar/Cedar.h>
#import "ProjectDeserializer.h"
#import "RepliconSpecHelper.h"
#import "ProjectType.h"
#import "ClientType.h"
#import "Period.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ProjectDeserializerSpec)

describe(@"ProjectDeserializer", ^{
    __block ProjectDeserializer *subject;
    __block NSArray *projectsArray;

    beforeEach(^{
        subject = [[ProjectDeserializer alloc]init];
        NSDictionary *jsonDictionary= [RepliconSpecHelper jsonWithFixture:@"get_projects"];
        projectsArray = [subject deserialize:jsonDictionary];
    });

    it(@"should deserialize clients correctly", ^{

        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        calendar.timeZone = timeZone;

        NSDateComponents *startDateComponentsA = [[NSDateComponents alloc] init];
        startDateComponentsA.day = 21;
        startDateComponentsA.month = 9;
        startDateComponentsA.year = 2015;

        NSDateComponents *endDateComponentsA = [[NSDateComponents alloc] init];
        endDateComponentsA.day = 27;
        endDateComponentsA.month = 9;
        endDateComponentsA.year = 2015;

        NSDate *startDateA = [calendar dateFromComponents:startDateComponentsA];
        NSDate *endDateA = [calendar dateFromComponents:endDateComponentsA];

        NSDateComponents *startDateComponentsB = [[NSDateComponents alloc] init];
        startDateComponentsB.day = 21;
        startDateComponentsB.month = 9;
        startDateComponentsB.year = 2015;

        NSDateComponents *endDateComponentsB = [[NSDateComponents alloc] init];
        endDateComponentsB.day = 27;
        endDateComponentsB.month = 9;
        endDateComponentsB.year = 2015;

        NSDate *startDateB = [calendar dateFromComponents:startDateComponentsB];
        NSDate *endDateB = [calendar dateFromComponents:endDateComponentsB];


        NSDateComponents *startDateComponentsC = [[NSDateComponents alloc] init];
        startDateComponentsC.day = 21;
        startDateComponentsC.month = 9;
        startDateComponentsC.year = 2015;

        NSDateComponents *endDateComponentsC = [[NSDateComponents alloc] init];
        endDateComponentsC.day = 27;
        endDateComponentsC.month = 9;
        endDateComponentsC.year = 2015;

        NSDate *startDateC = [calendar dateFromComponents:startDateComponentsC];
        NSDate *endDateC = [calendar dateFromComponents:endDateComponentsC];

        NSDateComponents *startDateComponentsD = [[NSDateComponents alloc] init];
        startDateComponentsD.day = 21;
        startDateComponentsD.month = 9;
        startDateComponentsD.year = 2015;

        NSDateComponents *endDateComponentsD = [[NSDateComponents alloc] init];
        endDateComponentsD.day = 27;
        endDateComponentsD.month = 9;
        endDateComponentsD.year = 2015;

        NSDate *startDateD = [calendar dateFromComponents:startDateComponentsD];
        NSDate *endDateD = [calendar dateFromComponents:endDateComponentsD];

        Period *periodA = [[Period alloc]initWithStartDate:startDateA endDate:endDateA];
        Period *periodB = [[Period alloc]initWithStartDate:startDateB endDate:endDateB];
        Period *periodC = [[Period alloc]initWithStartDate:startDateC endDate:endDateC];
        Period *periodD = [[Period alloc]initWithStartDate:startDateD endDate:endDateD];

        ClientType *clientA = [[ClientType alloc]initWithName:nil
                                                          uri:nil];
        ClientType *clientB = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                          uri:@"urn:replicon-tenant:punch:client:3"];
        ClientType *clientC = [[ClientType alloc]initWithName:@"Big Game Inc"
                                                          uri:@"urn:replicon-tenant:punch:client:3"];
        ClientType *clientD = [[ClientType alloc]initWithName:@"Xo Xo Communications"
                                                          uri:@"urn:replicon-tenant:punch:client:4"];

        ProjectType *projectA = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                    isTimeAllocationAllowed:YES
                                                                              projectPeriod:periodA
                                                                                 clientType:clientA
                                                                                       name:@"Financial Reporting"
                                                                                        uri:@"urn:replicon-tenant:punch:project:22"];

        ProjectType *projectB = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                    isTimeAllocationAllowed:YES
                                                                              projectPeriod:periodB
                                                                                 clientType:clientB
                                                                                       name:@"New Customer Service System"
                                                                                        uri:@"urn:replicon-tenant:punch:project:16"];

        ProjectType *projectC = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:YES
                                                                    isTimeAllocationAllowed:YES
                                                                              projectPeriod:periodC
                                                                                 clientType:clientC
                                                                                       name:@"Next gen ERP Deployment"
                                                                                        uri:@"urn:replicon-tenant:punch:project:18"];

        ProjectType *projectD = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO
                                                                    isTimeAllocationAllowed:NO
                                                                              projectPeriod:periodD
                                                                                 clientType:clientD
                                                                                       name:@"Online Sales ERP Enablement"
                                                                                        uri:@"urn:replicon-tenant:punch:project:24"];

        projectsArray should equal(@[projectA,projectB,projectC,projectD]);
    });
});

SPEC_END
