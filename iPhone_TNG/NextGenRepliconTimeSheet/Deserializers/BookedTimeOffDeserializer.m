#import "BookedTimeOffDeserializer.h"
#import "BookedTimeOff.h"


@implementation BookedTimeOffDeserializer

- (BookedTimeOff *) deserialize:(NSDictionary *)timeOffDetailsDictionary
{
    NSString *displayText = timeOffDetailsDictionary[@"displayText"];
    return [[BookedTimeOff alloc] initWithDescriptionText:displayText];
}

@end
