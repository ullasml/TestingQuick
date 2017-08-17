

#import <Foundation/Foundation.h>

@interface EmployeeClockInTrendSummaryDataPoint : NSObject

@property (nonatomic, readonly) NSUInteger numberOfTimePunchUsersPunchedIn;
@property (nonatomic, readonly) NSDate *startDate;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary NS_UNAVAILABLE;

- (instancetype)initWithNumberOfTimePunchUsersPunchedIn:(NSUInteger)numberOfTimePunchUsersPunchedIn
                                              startDate:(NSDate *)startDate NS_DESIGNATED_INITIALIZER;


@end
