
#import "ActivityDeserializer.h"
#import "Activity.h"

@implementation ActivityDeserializer

-(NSArray *)deserialize:(NSDictionary *)jsonDictionary
{
    NSArray *activities = jsonDictionary[@"d"];
    NSMutableArray *allactivities = [[NSMutableArray alloc]initWithCapacity:activities.count];
    for (NSDictionary *activityInfo in activities) {
        Activity *activity = [[Activity alloc]initWithName:activityInfo[@"name"] uri:activityInfo[@"uri"]];
        [allactivities addObject:activity];
    }
    return allactivities;
}
@end
