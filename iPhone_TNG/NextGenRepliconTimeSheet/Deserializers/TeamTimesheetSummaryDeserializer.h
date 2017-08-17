#import <Foundation/Foundation.h>


@class TeamTimesheetSummary;
@class CurrencyValueDeserializer;
@class PayCodeHoursDeserializer;
@class GrossHoursDeserializer;
@class ActualsByPayCodeDeserializer;

@interface TeamTimesheetSummaryDeserializer : NSObject

@property (nonatomic, readonly) CurrencyValueDeserializer *currencyValueDeserializer;
@property (nonatomic, readonly) PayCodeHoursDeserializer *payCodeHoursDeserializer;
@property (nonatomic, readonly) GrossHoursDeserializer *grossHoursDeserializer;
@property (nonatomic, readonly) ActualsByPayCodeDeserializer *actualsByPayCodeDeserializer;
@property (nonatomic, readonly) NSNumberFormatter *numberFormatter;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithCurrencyValueDeserializer:(CurrencyValueDeserializer *)currencyValueDeserializer grossHoursDeserializer:(GrossHoursDeserializer *)grossHoursDeserializer actualsByPayCodeDeserializer:(ActualsByPayCodeDeserializer *)actualsByPayCodeDeserializer payCodeHoursDeserializer:(PayCodeHoursDeserializer *)payCodeHoursDeserializer NS_DESIGNATED_INITIALIZER;

- (TeamTimesheetSummary *)deserialize:(NSDictionary *)jsonDictionary;

@end
