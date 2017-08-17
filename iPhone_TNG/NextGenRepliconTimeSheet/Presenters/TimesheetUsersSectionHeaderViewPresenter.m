#import "TimesheetUsersSectionHeaderViewPresenter.h"
#import "Theme.h"
#import "TeamTimesheetsForTimePeriod.h"

@interface TimesheetUsersSectionHeaderViewPresenter ()
@property (nonatomic) id<Theme> theme;
@property (nonatomic) NSDateFormatter *dateWithYearFormatter;
@property (nonatomic) NSDateFormatter *dateWithoutYearFormatter;
@end


@implementation TimesheetUsersSectionHeaderViewPresenter

- (instancetype)initWithTheme:(id<Theme>)theme
        dateWithYearFormatter:(NSDateFormatter *)dateWithYearFormatter
     dateWithoutYearFormatter:(NSDateFormatter *)dateWithoutYearFormatter
{
    self = [super init];
    if (self) {
        self.theme = theme;
        self.dateWithYearFormatter = dateWithYearFormatter;
        self.dateWithoutYearFormatter = dateWithoutYearFormatter;
    }

    return self;
}

- (NSString *)labelForSectionHeaderWithTimesheet:(TeamTimesheetsForTimePeriod *)timesheetsForTimePeriod
{
    NSString *startDateString = [self.dateWithoutYearFormatter stringFromDate:timesheetsForTimePeriod.startDate];
    NSString *endDateString = [self.dateWithYearFormatter stringFromDate:timesheetsForTimePeriod.endDate];

    return [NSString stringWithFormat:@"%@ - %@", startDateString, endDateString];
}

- (UIFont *)fontForSectionHeader
{
    return [self.theme supervisorTeamTimesheetsSectionHeaderFont];
}

- (UIColor *)fontColorForSectionHeader
{
    return [self.theme supervisorTeamTimesheetsSectionFontColor];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
