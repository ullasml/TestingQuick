#import <Foundation/Foundation.h>
@class DateProvider;

@interface TimesheetRequestBodyProvider : NSObject

@property (nonatomic, readonly) DateProvider *dateProvider;
@property (nonatomic, readonly) NSCalendar *calendar;


- (NSDictionary *)requestBodyDictionaryForMostRecentTimesheetWithUserURI:(NSString *)userURI;
- (NSDictionary *)requestBodyDictionaryTimesheetWithDate:(NSDate*)date;
- (NSDictionary *)requestBodyDictionaryTimesheetWithTimesheetURI:(NSString *)uri;

- (instancetype) initWithDateProvider:(DateProvider *)dateProvider calendar:(NSCalendar *)calendar;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

@end
