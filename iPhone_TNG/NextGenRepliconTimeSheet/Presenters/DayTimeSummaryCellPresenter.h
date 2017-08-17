#import <Foundation/Foundation.h>


@class DayTimeSummary;
@protocol Theme;
@protocol WorkHours;

@interface DayTimeSummaryCellPresenter : NSObject

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
- (NSAttributedString *)regularTimeStringForDayTimeSummary:(id <WorkHours>)dayTimeSummary;
- (NSAttributedString *)breakTimeStringForDayTimeSummary:(id <WorkHours>)dayTimeSummary;
- (NSAttributedString *)timeOffTimeStringForDayTimeSummary:(id <WorkHours>)dayTimeSummary;
- (NSDate *)dateForDayTimeSummary:(id <WorkHours>)dayTimeSummary;

@end
