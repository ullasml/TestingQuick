
#import "GrossHoursDeserializer.h"
#import "GrossHours.h"

@implementation GrossHoursDeserializer

- (GrossHours *)deserializeForHoursDictionary:(NSDictionary *)grossHoursDictionary
{
    if (!grossHoursDictionary || grossHoursDictionary == (id)[NSNull null])
    {
        return nil;
    }
    
    NSString *hoursText =  grossHoursDictionary == (id)[NSNull null] ? [NSString stringWithFormat:@"%@",@0] :[NSString stringWithFormat:@"%@",grossHoursDictionary[@"hours"]]  ;
    NSString *minutesText = grossHoursDictionary == (id)[NSNull null] ? [NSString stringWithFormat:@"%@",@0] : [NSString stringWithFormat:@"%@",grossHoursDictionary[@"minutes"]];    
    return [[GrossHours alloc] initWithHours:hoursText minutes:minutesText];
}

@end
