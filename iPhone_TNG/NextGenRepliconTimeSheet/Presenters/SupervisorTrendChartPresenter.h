#import <Foundation/Foundation.h>

@class EmployeeClockInTrendSummary;

@interface SupervisorTrendChartPresenter : NSObject

@property (nonatomic, readonly) NSDateFormatter *dateFormatter;

- (instancetype)initWithDateFormatter:(NSDateFormatter *)dateFormatter NS_DESIGNATED_INITIALIZER;

- (NSArray *)valuesForEmployeeClockInTrendSummary:(EmployeeClockInTrendSummary *)employeeClockInTrendSummary;
- (NSInteger)maximumValueForDataPoints:(NSArray *)dataPoints;
- (NSArray *)xLabelsForDataPoints:(NSArray *)dataPoints;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary NS_UNAVAILABLE;

@end
