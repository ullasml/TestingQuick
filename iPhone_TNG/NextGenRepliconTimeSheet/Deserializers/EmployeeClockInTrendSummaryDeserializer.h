#import <Foundation/Foundation.h>


@class EmployeeClockInTrendSummary;


@interface EmployeeClockInTrendSummaryDeserializer : NSObject

@property (nonatomic, readonly) NSCalendar *calendar;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary NS_UNAVAILABLE;

- (instancetype)initWithCalendar:(NSCalendar *)calendar NS_DESIGNATED_INITIALIZER;

- (EmployeeClockInTrendSummary *)deserialize:(NSDictionary *)jsonDictionary samplingIntervalSeconds:(NSUInteger)samplingIntervalSeconds;

@end
