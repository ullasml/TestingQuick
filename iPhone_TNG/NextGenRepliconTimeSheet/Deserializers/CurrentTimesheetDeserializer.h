

#import <Foundation/Foundation.h>

@class IndexCursor;
@class DateProvider;

@interface CurrentTimesheetDeserializer : NSObject

@property (nonatomic, readonly) DateProvider *dateProvider;
@property (nonatomic, readonly) NSCalendar *calendar;

-(instancetype)initWithDateProvider:(DateProvider *)dateProvider
                           calendar:(NSCalendar *)calendar;


@end
