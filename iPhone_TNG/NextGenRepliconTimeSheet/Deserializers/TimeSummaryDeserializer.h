#import <Foundation/Foundation.h>


@class CurrencyValueDeserializer;
@class TimePeriodSummary;
@class DayTimeSummary;
@class GrossHoursDeserializer;
@class ActualsByPayCodeDeserializer;
@class PayCodeHoursDeserializer;

@interface TimeSummaryDeserializer : NSObject

@property (nonatomic, readonly) CurrencyValueDeserializer *currencyValueDeserializer;
@property (nonatomic, readonly) GrossHoursDeserializer *grossHoursDeserializer;
@property (nonatomic, readonly) ActualsByPayCodeDeserializer *actualsByPayCodeDeserializer;
@property (nonatomic, readonly) PayCodeHoursDeserializer *payCodeHoursDeserializer;
@property (nonatomic, readonly) NSCalendar *localTimezoneCalendar;
@property (nonatomic, readonly) NSCalendar *utcTimeZoneCalendar;
@property (nonatomic, readonly) NSNumberFormatter *numberFormatter;
@property (nonatomic, readonly) NSDateFormatter *dateFormatterShortDate;
@property (nonatomic, readonly) NSDateFormatter *dateFormatterShortTime;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithCurrencyValueDeserializer:(CurrencyValueDeserializer *)currencyValueDeserializer
                            localTimezoneCalendar:(NSCalendar *)localTimezoneCalendar
                             grossHoursSerializer:(GrossHoursDeserializer *)grossHoursDeserializer
                     actualsByPayCodeDesirializer:(ActualsByPayCodeDeserializer *)actualsByPayCodeDeserializer
                         payCodeHoursDeserializer:(PayCodeHoursDeserializer *)payCodeHoursDeserializer
                           dateFormatterShortDate:(NSDateFormatter *)dateFormatterShortDate
                           dateFormatterShortTime:(NSDateFormatter *)dateFormatterShortTime
                              utcTimeZoneCalendar:(NSCalendar *)utcTimeZoneCalendar;

- (DayTimeSummary *)deserialize:(NSDictionary *)timeSummaryDictionary forDate:(NSDate *)date;

- (TimePeriodSummary *)deserializeForTimesheet:(NSDictionary *)timeSummaryDictionary;

@end
