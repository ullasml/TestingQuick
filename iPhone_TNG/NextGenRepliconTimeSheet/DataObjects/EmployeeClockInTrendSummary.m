#import "EmployeeClockInTrendSummary.h"


@interface EmployeeClockInTrendSummary ()

@property (nonatomic, copy) NSArray *dataPoints;
@property (nonatomic) NSInteger samplingIntervalSeconds;

@end


@implementation EmployeeClockInTrendSummary

- (instancetype)initWithDataPoints:(NSArray *)dataPoints samplingIntervalSeconds:(NSInteger)samplingIntervalSeconds
{
    self = [super init];
    if (self) {
        self.dataPoints = dataPoints;
        self.samplingIntervalSeconds = samplingIntervalSeconds;
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
