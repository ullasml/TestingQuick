#import "DayTimeSummary.h"
#import "Theme.h"
#import "Constants.h"
#import "DayTimeSummaryTitlePresenter.h"


@interface DayTimeSummaryTitlePresenter ()

@property (nonatomic) NSDateFormatter *dayMonthFormatter;
@property (nonatomic) NSCalendar *calendar;
@property (nonatomic) id<Theme> theme;

@end

@implementation DayTimeSummaryTitlePresenter

- (instancetype)initWithDayMonthFormatter:(NSDateFormatter *)dayMonthFormatter
                                 calendar:(NSCalendar *)calendar
                                    theme:(id<Theme>)theme {
    self = [super init];
    if (self) {
        self.dayMonthFormatter = dayMonthFormatter;
        self.calendar = calendar;
        self.theme = theme;
    }
    return self;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSAttributedString *)dateStringForDayTimeSummary:(id <WorkHours>)dayTimeSummary
{
    NSDate *date = [self.calendar dateFromComponents:dayTimeSummary.dateComponents];
    NSDictionary *attributes = @{NSFontAttributeName: [self.theme timesheetBreakdownDateFont]};
    NSString *dateString = [self.dayMonthFormatter stringFromDate:date];
    NSAttributedString *attributedDateString = [[NSAttributedString alloc] initWithString:dateString
                                                                               attributes:attributes];
    return attributedDateString;
}

@end
