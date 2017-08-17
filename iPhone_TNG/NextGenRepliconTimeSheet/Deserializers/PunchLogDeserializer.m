#import "PunchLogDeserializer.h"
#import "PunchLog.h"


@implementation PunchLogDeserializer

- (NSArray *)deserialize:(NSArray *)json
{
    if (json>0)
    {
        NSArray *logDictionaryArray = json[0][@"records"];
        NSMutableArray *logs = [NSMutableArray arrayWithCapacity:logDictionaryArray.count];
        
        for (NSDictionary *logDictionary in logDictionaryArray)
        {
            NSString *displayText = logDictionary[@"displayText"];
            
            PunchLog *log = [[PunchLog alloc] initWithText:displayText];
            [logs addObject:log];
        }
        
        return logs;
    }
    
    return @[];
}

@end
