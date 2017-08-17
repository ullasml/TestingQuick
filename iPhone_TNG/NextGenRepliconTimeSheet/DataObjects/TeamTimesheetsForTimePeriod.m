#import "TeamTimesheetsForTimePeriod.h"

@interface TeamTimesheetsForTimePeriod ()

@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSDate *endDate;
@property (nonatomic) NSArray *timesheets;

@end

@implementation TeamTimesheetsForTimePeriod

- (instancetype)initWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate timesheets:(NSArray *)timesheets
{
    self = [super init];
    if (self) {
        self.startDate = startDate;
        self.endDate = endDate;
        self.timesheets = timesheets;
    }

    return self;
}

@end
