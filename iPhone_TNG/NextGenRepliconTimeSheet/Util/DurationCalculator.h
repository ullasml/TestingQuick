#import <Foundation/Foundation.h>

@class DateProvider;


@interface DurationCalculator : NSObject

@property (nonatomic, readonly) DateProvider *dateProvider;
@property (nonatomic, readonly) NSCalendar *calendar;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithCalendar:(NSCalendar *)calendar dateProvider:(DateProvider *)dateProvider NS_DESIGNATED_INITIALIZER;

- (NSDateComponents *)timeSinceStartDate:(NSDate *)startDate;
- (NSDateComponents *)sumOfTimeByAddingDateComponents:(NSDateComponents *)firstDateComponents toDateComponents:(NSDateComponents *)secondDateComponents;

@end
