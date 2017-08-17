#import "SupervisorTrendChartPresenter.h"
#import "EmployeeClockInTrendSummaryDataPoint.h"
#import "EmployeeClockInTrendSummary.h"


@interface SupervisorTrendChartPresenter ()

@property (nonatomic) NSDateFormatter *dateFormatter;

@end


@implementation SupervisorTrendChartPresenter

- (instancetype)initWithDateFormatter:(NSDateFormatter *)dateFormatter
{
    self = [super init];
    if (self)
    {
        self.dateFormatter = dateFormatter;
    }
    return self;
}

- (NSArray *)valuesForEmployeeClockInTrendSummary:(EmployeeClockInTrendSummary *)employeeClockInTrendSummary
{
    if(employeeClockInTrendSummary)
    {
        NSMutableArray *values = [[self valuesForDataPoints:employeeClockInTrendSummary.dataPoints] mutableCopy];
        
        EmployeeClockInTrendSummaryDataPoint *lastDataPoint = employeeClockInTrendSummary.dataPoints.lastObject;
        
        NSUInteger remainingSecondsInLastHour = 3600 - ((NSUInteger)lastDataPoint.startDate.timeIntervalSince1970 % 3600);
        NSUInteger remainingNumberOfBars = remainingSecondsInLastHour / employeeClockInTrendSummary.samplingIntervalSeconds;
        
        for(NSUInteger i = 0; i < remainingNumberOfBars; i++)
        {
            [values addObject:@0];
        }
        
        NSUInteger numberOfIntervalsInHour = 3600 / employeeClockInTrendSummary.samplingIntervalSeconds;
        
        for(NSUInteger i = 0; i < numberOfIntervalsInHour; i++)
        {
            [values addObject:@0];
        }
        
        return values;
    }
    
    return nil;
    
}

- (NSInteger)maximumValueForDataPoints:(NSArray *)dataPoints
{
    NSArray *values = [self valuesForDataPoints:dataPoints];

    NSInteger maximum = [[values valueForKeyPath:@"@max.self"] integerValue];
    if (maximum % 2)
    {
        maximum++;
    }

    return maximum;
}

- (NSArray *)xLabelsForDataPoints:(NSArray *)dataPoints
{
    if(dataPoints)
    {
        NSMutableArray *dateStrings = [[NSMutableArray alloc] initWithCapacity:dataPoints.count + 2];
        
        for (EmployeeClockInTrendSummaryDataPoint *dataPoint in dataPoints)
        {
            NSString *dateString = [self.dateFormatter stringFromDate:dataPoint.startDate];
            
            if (![dateString isEqualToString:dateStrings.lastObject])
            {
                [dateStrings addObject:dateString];
            }
        }
        
        EmployeeClockInTrendSummaryDataPoint *lastDataPoint = dataPoints.lastObject;
        NSDate *nextFirstHour = [lastDataPoint.startDate dateByAddingTimeInterval:3600];
        NSString *nextFirstHourString = [self.dateFormatter stringFromDate:nextFirstHour];
        [dateStrings addObject:nextFirstHourString];
        
        NSDate *nextSecondHour = [lastDataPoint.startDate dateByAddingTimeInterval:7200];
        NSString *nextSecondHourString = [self.dateFormatter stringFromDate:nextSecondHour];
        [dateStrings addObject:nextSecondHourString];

        for (int index = 0; index<[dateStrings count]; index++) {
            NSString *dateString = [dateStrings objectAtIndex:index];
            NSRange amRange = [dateString rangeOfString:[self.dateFormatter AMSymbol]];
            NSRange pmRange = [dateString rangeOfString:[self.dateFormatter PMSymbol]];
            BOOL is24h = (amRange.location == NSNotFound && pmRange.location == NSNotFound);
            if (is24h)
            {
                dateString = [NSString stringWithFormat:@"%@:00",dateString];
                [dateStrings replaceObjectAtIndex:index withObject:dateString];
            }
        }


        return dateStrings;
    }
    
    return nil;
   
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private

- (NSArray *)valuesForDataPoints:(NSArray *)dataPoints
{
    NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:dataPoints.count];

    for (EmployeeClockInTrendSummaryDataPoint *dataPoint in dataPoints)
    {
        [values addObject:@(dataPoint.numberOfTimePunchUsersPunchedIn)];
    }

    return values;
}

@end
