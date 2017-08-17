#import <UIKit/UIKit.h>

@class TeamTimesheetsForTimePeriod;
@protocol Theme;

@interface TimesheetUsersSectionHeaderViewPresenter : NSObject

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTheme:(id<Theme>)theme
        dateWithYearFormatter:(NSDateFormatter *)dateWithYearFormatter
     dateWithoutYearFormatter:(NSDateFormatter *)dateWithoutYearFormatter;

@property (nonatomic, readonly) id<Theme> theme;
@property (nonatomic, readonly) NSDateFormatter *dateWithYearFormatter;
@property (nonatomic, readonly) NSDateFormatter *dateWithoutYearFormatter;

- (NSString *)labelForSectionHeaderWithTimesheet:(TeamTimesheetsForTimePeriod *)timesheetsForTimePeriod;
- (UIFont *)fontForSectionHeader;
- (UIColor *)fontColorForSectionHeader;

@end
