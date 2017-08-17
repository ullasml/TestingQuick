
#import "TimeLinePunchesSummary.h"
#import "DayTimeSummary.h"

@interface TimeLinePunchesSummary ()

@property (nonatomic) NSArray *allPunches;
@property (nonatomic) NSArray *timeLinePunches;
@property (nonatomic) DayTimeSummary *dayTimeSummary;


@end
@implementation TimeLinePunchesSummary

- (instancetype)initWithDayTimeSummary:(DayTimeSummary *)dayTimeSummary
                       timeLinePunches:(NSArray *)timeLinePunches
                            allPunches:(NSArray *)allPunches {
    self = [super init];
    if (self) {
        self.allPunches = allPunches;
        self.timeLinePunches = timeLinePunches;
        self.dayTimeSummary = dayTimeSummary;
    }
    return self;
}
@end
