#import "DayTimeSummaryCellPresenter.h"
#import "DayTimeSummary.h"
#import "Theme.h"
#import "Constants.h"


@interface DayTimeSummaryCellPresenter ()

@property (nonatomic) NSDateFormatter *dayMonthFormatter;
@property (nonatomic) NSCalendar *calendar;
@property (nonatomic) id<Theme> theme;

@end

@implementation DayTimeSummaryCellPresenter

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

- (NSAttributedString *)regularTimeStringForDayTimeSummary:(id <WorkHours>)dayTimeSummary
{
    NSDictionary *timeAttributes = @{NSForegroundColorAttributeName: [self.theme timesheetBreakdownRegularTimeTextColor]};

    NSAttributedString *timeString = [[NSAttributedString alloc] initWithString:[self stringFromTimeComponents:dayTimeSummary.regularTimeComponents]
                                                                     attributes:timeAttributes];


    NSMutableAttributedString *attributedRegularTimeString = [timeString mutableCopy];

    [attributedRegularTimeString addAttribute:NSFontAttributeName
                                        value:[self.theme timesheetRegularTimeFont]
                                        range:NSMakeRange(0, [attributedRegularTimeString length])];

    return attributedRegularTimeString;
}

- (NSAttributedString *)breakTimeStringForDayTimeSummary:(DayTimeSummary *)dayTimeSummary
{
    NSDictionary *timeAttributes = @{NSForegroundColorAttributeName: [self.theme timesheetBreakdownBreakTimeTextColor]};

    NSAttributedString *timeString = [[NSAttributedString alloc] initWithString:[self stringFromTimeComponents:dayTimeSummary.breakTimeComponents]
                                                                     attributes:timeAttributes];

    NSAttributedString *suffixString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ",RPLocalizedString(@"Break", @"Break")]];

    NSMutableAttributedString *attributedBreakTimeString = [suffixString mutableCopy];
    [attributedBreakTimeString appendAttributedString:timeString];

    [attributedBreakTimeString addAttribute:NSFontAttributeName
                                      value:[self.theme timesheetBreakdownTimeFont]
                                      range:NSMakeRange(0, [attributedBreakTimeString length])];

    return attributedBreakTimeString;
}

- (NSAttributedString *)timeOffTimeStringForDayTimeSummary:(id <WorkHours>)dayTimeSummary
{
    NSDictionary *timeAttributes = @{NSForegroundColorAttributeName: [self.theme timesheetBreakdownBreakTimeTextColor]};
    
    NSAttributedString *timeString = [[NSAttributedString alloc] initWithString:[self stringFromTimeComponents:dayTimeSummary.timeOffComponents]
                                                                     attributes:timeAttributes];
    
    NSAttributedString *suffixString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ",RPLocalizedString(Time_Off_Key, Time_Off_Key)]];
    
    NSMutableAttributedString *attributedTimeOffTimeString = [suffixString mutableCopy];
    [attributedTimeOffTimeString appendAttributedString:timeString];
    
    [attributedTimeOffTimeString addAttribute:NSFontAttributeName
                                      value:[self.theme timesheetBreakdownTimeFont]
                                      range:NSMakeRange(0, [attributedTimeOffTimeString length])];
    
    return attributedTimeOffTimeString;
}


- (NSDate *)dateForDayTimeSummary:(DayTimeSummary *)dayTimeSummary
{
    NSDate *date = [self.calendar dateFromComponents:dayTimeSummary.dateComponents];
    return date;
}

#pragma mark - Private

- (NSString *)stringFromTimeComponents:(NSDateComponents *)timeComponents {
    return [NSString stringWithFormat:@"%@h:%@m",
                                      @(timeComponents.hour),
                                      @(timeComponents.minute)];
}

@end
