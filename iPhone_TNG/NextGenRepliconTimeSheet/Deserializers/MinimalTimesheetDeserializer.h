#import <Foundation/Foundation.h>


@protocol Timesheet;


@interface MinimalTimesheetDeserializer : NSObject

@property (nonatomic, readonly) NSCalendar *calendar;
@property (nonatomic, readonly) NSDateFormatter *dateFormatter;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary NS_UNAVAILABLE;

- (instancetype)initWithCalendar:(NSCalendar *)calendar
                   dateFormatter:(NSDateFormatter *)dateFormatter NS_DESIGNATED_INITIALIZER;

- (id<Timesheet>)deserialize:(NSDictionary *)dictionary;

@end
