
#import "PayCodeHoursDeserializer.h"
#import "Paycode.h"

@implementation PayCodeHoursDeserializer

- (Paycode *)deserializeForHoursDictionary:(NSDictionary *)grossHoursDictionary
{
    if (grossHoursDictionary!=nil || grossHoursDictionary != (id)[NSNull null])
    {
        NSString *durationText=nil;
        NSString *titleStr = nil;
        NSString *durationWithSeconds = nil;
            NSDictionary *durationDictionary = grossHoursDictionary[@"totalTimeDuration"];
            if(durationDictionary!=nil && durationDictionary!=(id)[NSNull null])
            {
                if(durationDictionary[@"hours"]!=nil && durationDictionary[@"hours"]!=(id)[NSNull null] && durationDictionary[@"minutes"]!=nil && durationDictionary[@"minutes"]!=(id)[NSNull null] && durationDictionary[@"seconds"]!=nil && durationDictionary[@"seconds"]!=(id)[NSNull null])
                {
                    
                    durationText =  [NSString stringWithFormat:@"%@h:%@m",durationDictionary[@"hours"],durationDictionary[@"minutes"]] ;
                    durationWithSeconds =  [NSString stringWithFormat:@"%@h:%@m:%@s",durationDictionary[@"hours"],durationDictionary[@"minutes"],durationDictionary[@"seconds"]] ;
                    NSDictionary *titleDictionary = grossHoursDictionary[@"payCode"];
                    
                    
                    if(titleDictionary!=nil && titleDictionary!=(id)[NSNull null])
                    {
                        titleStr = titleDictionary[@"displayText"];
                    }
                    if(titleStr!=nil && durationText!=nil)
                    {
                        return [[Paycode alloc] initWithValue:durationText title:titleStr timeSeconds:durationWithSeconds];
                    }
                }
        }
    }
    
    
    return nil;
}


@end
