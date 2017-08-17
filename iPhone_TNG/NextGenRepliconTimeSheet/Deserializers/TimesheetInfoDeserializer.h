#import <Foundation/Foundation.h>


@class CurrencyValueDeserializer;
@class TimePeriodSummary;
@class DayTimeSummary;
@class GrossHoursDeserializer;
@class ActualsByPayCodeDeserializer;
@class PayCodeHoursDeserializer;
@class RemotePunchDeserializer;
@class TimesheetInfo;

@interface TimesheetInfoDeserializer : NSObject

@property (nonatomic, readonly) CurrencyValueDeserializer *currencyValueDeserializer;
@property (nonatomic, readonly) GrossHoursDeserializer *grossHoursDeserializer;
@property (nonatomic, readonly) ActualsByPayCodeDeserializer *actualsByPayCodeDeserializer;
@property (nonatomic, readonly) PayCodeHoursDeserializer *payCodeHoursDeserializer;
@property (nonatomic, readonly) RemotePunchDeserializer *remotePunchDeserializer;

@property (nonatomic, readonly) NSCalendar *calendar;
@property (nonatomic, readonly) NSNumberFormatter *numberFormatter;
@property (nonatomic, readonly) NSDateFormatter *dateFormatterShortDate;
@property (nonatomic, readonly) NSDateFormatter *dateFormatterShortTime;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithCurrencyValueDeserializer:(CurrencyValueDeserializer *)currencyValueDeserializer
                     actualsByPayCodeDesirializer:(ActualsByPayCodeDeserializer *)actualsByPayCodeDeserializer
                         payCodeHoursDeserializer:(PayCodeHoursDeserializer *)payCodeHoursDeserializer
                          remotePunchDeserializer:(RemotePunchDeserializer *)remotePunchDeserializer
                             grossHoursSerializer:(GrossHoursDeserializer *)grossHoursDeserializer
                           dateFormatterShortDate:(NSDateFormatter *)dateFormatterShortDate
                           dateFormatterShortTime:(NSDateFormatter *)dateFormatterShortTime
                                         calendar:(NSCalendar *)calendar NS_DESIGNATED_INITIALIZER;

- (TimesheetInfo *)deserializeTimesheetInfo:(NSArray *)responseInfoArray;
- (TimesheetInfo *)deserializeTimesheetInfoForWidget:(NSDictionary *)timesheetInfo;

@end
