#import <Cedar/Cedar.h>
#import "TaskDeserializer.h"
#import "RepliconSpecHelper.h"
#import "TaskType.h"
#import "ClientType.h"
#import "Period.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(TaskDeserializerSpec)

describe(@"TaskDeserializer", ^{
    __block TaskDeserializer *subject;
    __block NSArray *tasksArray;

    beforeEach(^{
        subject = [[TaskDeserializer alloc]init];
        NSDictionary *jsonDictionary= [RepliconSpecHelper jsonWithFixture:@"get_tasks"];
        tasksArray = [subject deserialize:jsonDictionary forProjectWithUri:@"special-project-uri"];
    });

    it(@"should deserialize clients correctly", ^{

        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        calendar.timeZone = timeZone;

        NSDateComponents *startDateComponentsA = [[NSDateComponents alloc] init];
        startDateComponentsA.day = 5;
        startDateComponentsA.month = 10;
        startDateComponentsA.year = 2015;

        NSDateComponents *endDateComponentsA = [[NSDateComponents alloc] init];
        endDateComponentsA.day = 11;
        endDateComponentsA.month = 10;
        endDateComponentsA.year = 2015;

        NSDate *startDateA = [calendar dateFromComponents:startDateComponentsA];
        NSDate *endDateA = [calendar dateFromComponents:endDateComponentsA];

        NSDateComponents *startDateComponentsB = [[NSDateComponents alloc] init];
        startDateComponentsB.day = 5;
        startDateComponentsB.month = 10;
        startDateComponentsB.year = 2015;

        NSDateComponents *endDateComponentsB = [[NSDateComponents alloc] init];
        endDateComponentsB.day = 11;
        endDateComponentsB.month = 10;
        endDateComponentsB.year = 2015;

        NSDate *startDateB = [calendar dateFromComponents:startDateComponentsB];
        NSDate *endDateB = [calendar dateFromComponents:endDateComponentsB];


        NSDateComponents *startDateComponentsC = [[NSDateComponents alloc] init];
        startDateComponentsC.day = 5;
        startDateComponentsC.month = 10;
        startDateComponentsC.year = 2015;

        NSDateComponents *endDateComponentsC = [[NSDateComponents alloc] init];
        endDateComponentsC.day = 11;
        endDateComponentsC.month = 10;
        endDateComponentsC.year = 2015;

        NSDate *startDateC = [calendar dateFromComponents:startDateComponentsC];
        NSDate *endDateC = [calendar dateFromComponents:endDateComponentsC];

        NSDateComponents *startDateComponentsD = [[NSDateComponents alloc] init];
        startDateComponentsD.day = 5;
        startDateComponentsD.month = 10;
        startDateComponentsD.year = 2015;

        NSDateComponents *endDateComponentsD = [[NSDateComponents alloc] init];
        endDateComponentsD.day = 11;
        endDateComponentsD.month = 10;
        endDateComponentsD.year = 2015;

        NSDate *startDateD = [calendar dateFromComponents:startDateComponentsD];
        NSDate *endDateD = [calendar dateFromComponents:endDateComponentsD];

        Period *periodA = [[Period alloc]initWithStartDate:startDateA endDate:endDateA];
        Period *periodB = [[Period alloc]initWithStartDate:startDateB endDate:endDateB];
        Period *periodC = [[Period alloc]initWithStartDate:startDateC endDate:endDateC];
        Period *periodD = [[Period alloc]initWithStartDate:startDateD endDate:endDateD];


        TaskType *taskA = [[TaskType alloc] initWithProjectUri:@"special-project-uri"
                                                    taskPeriod:periodA
                                                          name:@"Deployment"
                                                           uri:@"urn:replicon-tenant:iphone:task:111"];

        TaskType *taskB = [[TaskType alloc] initWithProjectUri:@"special-project-uri"
                                                    taskPeriod:periodB
                                                          name:@"Design"
                                                           uri:@"urn:replicon-tenant:iphone:task:108"];

        TaskType *taskC = [[TaskType alloc] initWithProjectUri:@"special-project-uri"
                                                    taskPeriod:periodC
                                                          name:@"Development"
                                                           uri:@"urn:replicon-tenant:iphone:task:109"];

        TaskType *taskD = [[TaskType alloc] initWithProjectUri:@"special-project-uri"
                                                    taskPeriod:periodD
                                                          name:@"Discovery"
                                                           uri:@"urn:replicon-tenant:iphone:task:106"];

        tasksArray should equal(@[taskA,taskB,taskC,taskD]);
    });
});




SPEC_END
