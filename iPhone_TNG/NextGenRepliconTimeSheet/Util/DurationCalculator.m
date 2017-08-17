#import "DurationCalculator.h"
#import "DateProvider.h"


@interface DurationCalculator ()

@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) NSCalendar *calendar;

@end


@implementation DurationCalculator

- (instancetype)initWithCalendar:(NSCalendar *)calendar dateProvider:(DateProvider *)dateProvider {
    self = [super init];
    if (self) {
        self.calendar = calendar;
        self.dateProvider = dateProvider;
    }
    return self;
}

- (NSDateComponents *)timeSinceStartDate:(NSDate *)startDate {
    NSDate *endDate = self.dateProvider.date;
    return [self.calendar components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:startDate toDate:endDate options:0];
}

- (NSDateComponents *)sumOfTimeByAddingDateComponents:(NSDateComponents *)firstDateComponents toDateComponents:(NSDateComponents *)secondDateComponents {
    NSDate *epochDate = [NSDate dateWithTimeIntervalSince1970:0];
    NSDateComponents *sumComponents = [[NSDateComponents alloc] init];

    sumComponents.hour = firstDateComponents.hour + secondDateComponents.hour;
    sumComponents.minute = firstDateComponents.minute + secondDateComponents.minute;
    sumComponents.second = firstDateComponents.second + secondDateComponents.second;

    NSDate *sumDate = [self.calendar dateByAddingComponents:sumComponents toDate:epochDate options:0];

    NSDateComponents *deltaComponents = [self.calendar components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:epochDate toDate:sumDate options:0];

    return deltaComponents;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
