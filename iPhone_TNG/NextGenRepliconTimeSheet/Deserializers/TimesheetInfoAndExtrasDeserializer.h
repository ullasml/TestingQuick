
#import <Foundation/Foundation.h>

@class ViolationsForTimesheetPeriodDeserializer;
@class TimesheetAdditionalInfo;
@class TimeSheetPermittedActionsDeserializer;

@interface TimesheetInfoAndExtrasDeserializer : NSObject


@property (nonatomic, readonly) ViolationsForTimesheetPeriodDeserializer *violationsForTimesheetPeriodDeserializer;
@property (nonatomic, readonly) NSDateFormatter *dateFormatterShortDate;
@property (nonatomic, readonly) NSDateFormatter *dateFormatterShortTime;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithViolationsForTimesheetPeriodDeserializer:(ViolationsForTimesheetPeriodDeserializer *)violationsForTimesheetPeriodDeserializer
                           timeSheetPermittedActionsDeserializer:(TimeSheetPermittedActionsDeserializer *)timeSheetPermittedActionsDeserializer
                                          dateFormatterShortDate:(NSDateFormatter *)dateFormatterShortDate
                                          dateFormatterShortTime:(NSDateFormatter *)dateFormatterShortTime
                                                        calendar:(NSCalendar *)calendar NS_DESIGNATED_INITIALIZER;

- (TimesheetAdditionalInfo *)deserialize:(NSDictionary *)jsonDictionary;

@end
