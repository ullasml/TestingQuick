

#import "DateUtil.h"

@implementation DateUtil

+ (NSDate *)getUtcDateByAddingDays:(NSUInteger)days toUtcDate:(NSDate *)toUtcDate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    gregorian.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = days;
    return [gregorian dateByAddingComponents:components toDate:toUtcDate options:0];
}

@end
