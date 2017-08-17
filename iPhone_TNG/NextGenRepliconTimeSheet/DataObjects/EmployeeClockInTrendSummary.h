#import <Foundation/Foundation.h>


@interface EmployeeClockInTrendSummary : NSObject

@property (nonatomic, copy, readonly) NSArray *dataPoints;
@property (nonatomic, readonly) NSInteger samplingIntervalSeconds;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary NS_UNAVAILABLE;

- (instancetype)initWithDataPoints:(NSArray *)dataPoints samplingIntervalSeconds:(NSInteger)samplingIntervalSeconds NS_DESIGNATED_INITIALIZER;

@end
