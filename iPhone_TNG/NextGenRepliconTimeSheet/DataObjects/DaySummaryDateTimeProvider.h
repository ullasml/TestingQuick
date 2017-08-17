
#import <Foundation/Foundation.h>

@interface DaySummaryDateTimeProvider : NSObject

@property (nonatomic, readonly) NSDateFormatter *dayMonthFormatter;
@property (nonatomic, readonly) NSCalendar *calendar;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithDayMonthFormatter:(NSDateFormatter *)dayMonthFormatter
                                 calendar:(NSCalendar *)calendar;

- (NSDate *)dateWithCurrentTime:(NSDate *)date;

@end
