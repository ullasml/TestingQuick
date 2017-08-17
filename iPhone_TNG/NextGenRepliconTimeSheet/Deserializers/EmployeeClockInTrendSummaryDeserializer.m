#import "EmployeeClockInTrendSummaryDeserializer.h"
#import "EmployeeClockInTrendSummary.h"
#import "EmployeeClockInTrendSummaryDataPoint.h"
@interface EmployeeClockInTrendSummaryDeserializer ()

@property (nonatomic) NSCalendar *calendar;

@end


@implementation EmployeeClockInTrendSummaryDeserializer


- (instancetype)initWithCalendar:(NSCalendar *)calendar
{
    self = [super init];
    if (self) {
        self.calendar = calendar;
    }
    return self;
}

-(EmployeeClockInTrendSummary *)deserialize:(NSDictionary *)jsonDictionary samplingIntervalSeconds:(NSUInteger)samplingIntervalSeconds
{
    NSArray *dataPointsArray = jsonDictionary[@"d"];
    if ([dataPointsArray isEqual:[NSNull null]]) {
        return [[EmployeeClockInTrendSummary alloc] initWithDataPoints:nil samplingIntervalSeconds:samplingIntervalSeconds];
    }
    NSMutableArray *allDataPointsArrayForEmployeeClockInTrend = [[NSMutableArray alloc] initWithCapacity:dataPointsArray.count];

    for (NSDictionary *dataPoint in dataPointsArray) {
        NSUInteger numberOfTimePunchUsersPunchedIn = [dataPoint[@"numberOfTimePunchUsersPunchedIn"] unsignedIntegerValue];
        NSDictionary *periodDictionary = dataPoint[@"period"];
        NSDictionary *startDateDictionary = periodDictionary[@"periodStart"];
        NSDictionary *utcStartDateDictionary = startDateDictionary[@"valueInUtc"];

        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        dateComponents.year = [utcStartDateDictionary[@"year"] integerValue];
        dateComponents.month = [utcStartDateDictionary[@"month"] integerValue];
        dateComponents.day = [utcStartDateDictionary[@"day"] integerValue];
        dateComponents.hour = [utcStartDateDictionary[@"hour"] integerValue];
        dateComponents.minute = [utcStartDateDictionary[@"minute"] integerValue];
        dateComponents.second = [utcStartDateDictionary[@"second"] integerValue];

        NSDate *startDate = [self.calendar dateFromComponents:dateComponents];

        EmployeeClockInTrendSummaryDataPoint *employeeClockInTrendSummaryDataPoint = [[EmployeeClockInTrendSummaryDataPoint alloc] initWithNumberOfTimePunchUsersPunchedIn:numberOfTimePunchUsersPunchedIn
                                                                                                                                                                 startDate:startDate];

        [allDataPointsArrayForEmployeeClockInTrend addObject:employeeClockInTrendSummaryDataPoint];
    }

    return [[EmployeeClockInTrendSummary alloc] initWithDataPoints:[allDataPointsArrayForEmployeeClockInTrend copy] samplingIntervalSeconds:samplingIntervalSeconds];
}

@end
