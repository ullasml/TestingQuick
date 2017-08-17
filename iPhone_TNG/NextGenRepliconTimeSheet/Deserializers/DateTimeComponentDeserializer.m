#import "DateTimeComponentDeserializer.h"

@implementation DateTimeComponentDeserializer


- (NSDateComponents *)deserializeDateTime:(NSDictionary *)dateTimeComponentsDictionary
{
    if (dateTimeComponentsDictionary == nil || dateTimeComponentsDictionary == (id)[NSNull null]) {
        return nil;
    }
    NSDateComponents *dateTimeComponents = [[NSDateComponents alloc] init];
    BOOL hasDay = [[dateTimeComponentsDictionary allKeys] containsObject:@"day"];
    BOOL hasMonth = [[dateTimeComponentsDictionary allKeys] containsObject:@"month"];
    BOOL hasYear = [[dateTimeComponentsDictionary allKeys] containsObject:@"year"];
    BOOL hasHour = ([[dateTimeComponentsDictionary allKeys] containsObject:@"hours"]||[[dateTimeComponentsDictionary allKeys] containsObject:@"hour"]);
    BOOL hasMinute = ([[dateTimeComponentsDictionary allKeys] containsObject:@"minutes"]||[[dateTimeComponentsDictionary allKeys] containsObject:@"minute"]);
    BOOL hasSecond = ([[dateTimeComponentsDictionary allKeys] containsObject:@"seconds"]||[[dateTimeComponentsDictionary allKeys] containsObject:@"second"]);

    NSInteger day = [dateTimeComponentsDictionary[@"day"] integerValue];
    NSInteger month = [dateTimeComponentsDictionary[@"month"] integerValue];
    NSInteger year = [dateTimeComponentsDictionary[@"year"] integerValue];

    NSInteger hours = [dateTimeComponentsDictionary[@"hours"] integerValue];
    NSInteger hour = [dateTimeComponentsDictionary[@"hour"] integerValue];

    NSInteger minutes = [dateTimeComponentsDictionary[@"minutes"] integerValue];
    NSInteger minute = [dateTimeComponentsDictionary[@"minute"] integerValue];
    NSInteger seconds = [dateTimeComponentsDictionary[@"seconds"] integerValue];

    NSInteger second = [dateTimeComponentsDictionary[@"second"] integerValue];

    if (hasDay) {
        dateTimeComponents.day = day;
    }
    if (hasMonth) {
        dateTimeComponents.month = month;
    }
    if (hasYear) {
        dateTimeComponents.year = year;
    }
    if (hasHour) {
        dateTimeComponents.hour = hour + hours;
    }
    if (hasMinute) {
        dateTimeComponents.minute = minute + minutes;
    }
    if (hasSecond) {
        dateTimeComponents.second = second + seconds;
    }
    return dateTimeComponents;

}

@end
