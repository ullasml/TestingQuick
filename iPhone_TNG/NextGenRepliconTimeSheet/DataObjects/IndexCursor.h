#import <Foundation/Foundation.h>
#import "Cursor.h"
@protocol Timesheet;
@class DateProvider;

@interface IndexCursor : NSObject <Cursor>

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithDateProvider:(DateProvider *)dateProvider
                            calendar:(NSCalendar *)calendar NS_DESIGNATED_INITIALIZER;

-(void)setUpWithCurrentTimesheet:(id <Timesheet>)timesheet olderTimesheet:(id <Timesheet>)olderTimesheet;

@end
