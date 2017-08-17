

#import "EmployeeClockInTrendSummaryDataPoint.h"
@interface EmployeeClockInTrendSummaryDataPoint ()

@property (nonatomic) NSUInteger numberOfTimePunchUsersPunchedIn;
@property (nonatomic) NSDate *startDate;

@end

@implementation EmployeeClockInTrendSummaryDataPoint

- (instancetype)initWithNumberOfTimePunchUsersPunchedIn:(NSUInteger)numberOfTimePunchUsersPunchedIn
                                              startDate:(NSDate *)startDate
{
    self = [super init];
    if (self) {
        self.numberOfTimePunchUsersPunchedIn = numberOfTimePunchUsersPunchedIn;
        self.startDate = startDate;
    }
    return self;
}

@end
