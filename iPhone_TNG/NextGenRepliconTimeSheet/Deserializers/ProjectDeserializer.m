

#import "ProjectDeserializer.h"
#import "ProjectType.h"
#import "Period.h"
#import "ClientType.h"
#import "DateTimeComponentDeserializer.h"

@implementation ProjectDeserializer

-(NSArray *)deserialize:(NSDictionary *)jsonDictionary
{
    NSArray *projects = jsonDictionary[@"d"];
    NSMutableArray *allProjects = [[NSMutableArray alloc]initWithCapacity:projects.count];
    for (NSDictionary *projectDictionary in projects) {

        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        NSDictionary *periodDictionary = projectDictionary[@"dateRangeWhereTimeAllocationIsAllowed"];
        NSDictionary *startDateDictionary = periodDictionary[@"startDate"];
        NSDictionary *endDateDictionary = periodDictionary[@"endDate"];

        DateTimeComponentDeserializer *dateTimeComponentsDeserializer = [[DateTimeComponentDeserializer alloc] init];
        NSDateComponents *startDateComponents = [dateTimeComponentsDeserializer deserializeDateTime:startDateDictionary];
        NSDateComponents *endDateComponents = [dateTimeComponentsDeserializer deserializeDateTime:endDateDictionary];
        NSDate *startDate = [calendar dateFromComponents:startDateComponents];
        NSDate *endDate = [calendar dateFromComponents:endDateComponents];


        NSDictionary *projectInfo = projectDictionary[@"project"];
        NSDictionary *clientInfo = projectDictionary[@"client"];
        NSString *projectName = projectInfo[@"name"];
        NSString *projectUri = projectInfo[@"uri"];

        NSString *clientName;
        NSString *clientUri;

        if (clientInfo != nil && clientInfo != (id) [NSNull null]) {
            clientName = clientInfo[@"name"];
            clientUri = clientInfo[@"uri"];
        }

        BOOL tasksAvailableForTimeAllocation = [projectDictionary[@"hasTasksAvailableForTimeAllocation"] boolValue];
        BOOL isTimeAllocationAllowed = [projectDictionary[@"isTimeAllocationAllowed"] boolValue];

        Period *period = [[Period alloc]initWithStartDate:startDate
                                                  endDate:endDate];

        ClientType *client = [[ClientType alloc]initWithName:clientName
                                                         uri:clientUri];

        ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:tasksAvailableForTimeAllocation
                                                                   isTimeAllocationAllowed:isTimeAllocationAllowed
                                                                             projectPeriod:period
                                                                                clientType:client
                                                                                      name:projectName
                                                                                       uri:projectUri];
        [allProjects addObject:project];
    }
    return allProjects;
}

@end
