
#import "DaySummaryDateTimeProvider.h"

@interface DaySummaryDateTimeProvider ()

@property (nonatomic) NSDateFormatter *dayMonthFormatter;
@property (nonatomic) NSCalendar *calendar;

@end

@implementation DaySummaryDateTimeProvider

- (instancetype)initWithDayMonthFormatter:(NSDateFormatter *)dayMonthFormatter
                                 calendar:(NSCalendar *)calendar{
    self = [super init];
    if (self) {
        self.dayMonthFormatter = dayMonthFormatter;
        self.calendar = calendar;
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSDate *)dateWithCurrentTime:(NSDate *)date
{
    NSDate *selectedDate = date;
    
    NSDateComponents *currentDateComps = [self.calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    
    NSDate *currentDate = [self.calendar dateFromComponents:currentDateComps];
    
    NSDateComponents *difference = [self.calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear
                                                    fromDate:currentDate toDate:selectedDate options:0];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:[difference day]];
    [components setMonth:[difference month]];
    [components setYear:[difference year]];

    selectedDate = [self.calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
    
    return selectedDate;
}

@end
