@class DayTimeSummary;
@protocol Theme;
@protocol WorkHours;

#import <Foundation/Foundation.h>

@interface DayTimeSummaryTitlePresenter : NSObject

@property (nonatomic, readonly) NSDateFormatter *dayMonthFormatter;
@property (nonatomic, readonly) NSCalendar *calendar;
@property (nonatomic, readonly) id<Theme> theme;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithDayMonthFormatter:(NSDateFormatter *)dayMonthFormatter
                                 calendar:(NSCalendar *)calendar
                                    theme:(id<Theme>)theme;

- (NSAttributedString *)dateStringForDayTimeSummary:(id <WorkHours>)dayTimeSummary;

@end
