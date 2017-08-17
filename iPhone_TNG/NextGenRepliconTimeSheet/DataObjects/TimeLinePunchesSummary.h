
#import <Foundation/Foundation.h>

@class DayTimeSummary;

@interface TimeLinePunchesSummary : NSObject

@property (nonatomic,readonly) DayTimeSummary *dayTimeSummary;
@property (nonatomic,readonly) NSArray *timeLinePunches;
@property (nonatomic,readonly) NSArray *allPunches;

- (instancetype)initWithDayTimeSummary:(DayTimeSummary *)dayTimeSummary
                       timeLinePunches:(NSArray *)timeLinePunches
                            allPunches:(NSArray *)allPunches;
@end
