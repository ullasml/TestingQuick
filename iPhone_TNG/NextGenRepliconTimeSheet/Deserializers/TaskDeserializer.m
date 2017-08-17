
#import "TaskDeserializer.h"
#import "TaskType.h"
#import "Period.h"
#import "DateTimeComponentDeserializer.h"

@implementation TaskDeserializer

-(NSArray *)deserialize:(NSDictionary *)jsonDictionary forProjectWithUri:(NSString *)projectUri
{
    NSArray *tasks = jsonDictionary[@"d"];
    NSMutableArray *allTasks = [[NSMutableArray alloc]initWithCapacity:tasks.count];
    for (NSDictionary *taskInfo in tasks) {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        calendar.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        NSDictionary *periodDictionary = taskInfo[@"dateRangeWhereTimeAllocationIsAllowed"];
        NSDictionary *startDateDictionary = periodDictionary[@"startDate"];
        NSDictionary *endDateDictionary = periodDictionary[@"endDate"];

        NSDictionary *task = taskInfo[@"task"][@"task"];
        NSString *uri = task[@"uri"];
        NSString *name = task[@"displayText"];

        DateTimeComponentDeserializer *dateTimeComponentsDeserializer = [[DateTimeComponentDeserializer alloc] init];
        NSDateComponents *startDateComponents = [dateTimeComponentsDeserializer deserializeDateTime:startDateDictionary];
        NSDateComponents *endDateComponents = [dateTimeComponentsDeserializer deserializeDateTime:endDateDictionary];
        NSDate *startDate = [calendar dateFromComponents:startDateComponents];
        NSDate *endDate = [calendar dateFromComponents:endDateComponents];

        Period *period = [[Period alloc]initWithStartDate:startDate
                                                  endDate:endDate];

        TaskType *taskType = [[TaskType alloc] initWithProjectUri:projectUri taskPeriod:period name:name uri:uri];

        [allTasks addObject:taskType];

    }

    return allTasks;
}

@end
