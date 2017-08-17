#import "TimesheetUserCellPresenter.h"
#import "TimesheetForUserWithWorkHours.h"
#import "Theme.h"


@interface TimesheetUserCellPresenter ()

@property (nonatomic) id<Theme> theme;

@end


@implementation TimesheetUserCellPresenter

- (instancetype)initWithTheme:(id<Theme>)theme
{
    self = [super init];
    if (self) {
        self.theme = theme;
    }

    return self;
}

- (NSString *)userNameLabelTextWithTimesheetUser:(TimesheetForUserWithWorkHours *)timesheetUser
{
    return timesheetUser.userName;
}

- (NSString *)workHoursLabelTextWithTimesheetUser:(TimesheetForUserWithWorkHours *)timesheetUser
{
    return [self stringWithDateComponents:timesheetUser.totalWorkHours];
}

- (NSAttributedString *)regularHoursLabelTextWithTimesheetUser:(TimesheetForUserWithWorkHours *)timesheetUser
{
    UIColor *textColor = [self.theme timesheetUserBreakHoursColor];
    NSString *breakHours = [self stringWithDateComponents:timesheetUser.totalBreakHours];
    NSString *breakHoursString = [NSString stringWithFormat:@"%@ %@",breakHours,RPLocalizedString(@"Break", @"")];
                              
    NSString *overtimeHours = [self stringWithDateComponents:timesheetUser.totalOvertimeHours];
    NSMutableArray *stringsToJoin = [NSMutableArray arrayWithCapacity:3];

    NSMutableAttributedString *breakHoursAttributedString = [[NSMutableAttributedString alloc] initWithString:breakHoursString attributes:@{NSForegroundColorAttributeName : textColor}];

    NSString *plusString = @" + ";
    NSMutableAttributedString *plusAttributedString = [[NSMutableAttributedString alloc] initWithString:plusString];
    NSRange plusStringRange = NSMakeRange(0, [plusString length]);
    [plusAttributedString addAttribute:NSForegroundColorAttributeName value:textColor range:plusStringRange];

    [stringsToJoin addObject:breakHoursAttributedString];

    BOOL hasOvertime = (timesheetUser.totalOvertimeHours.hour + timesheetUser.totalOvertimeHours.minute) > 0;
    if (hasOvertime)
    {
        UIColor *warningColor = [self.theme timesheetUserOvertimeAndViolationsColor];
        NSString *overtimeHoursString = [NSString stringWithFormat:@"%@ %@",overtimeHours,RPLocalizedString(@"OT", @"")];
        NSMutableAttributedString *overtimeHoursAttributedString = [[NSMutableAttributedString alloc] initWithString:overtimeHoursString];
        NSRange overtimeHoursStringRange = NSMakeRange(0, [overtimeHoursString length]);
        [overtimeHoursAttributedString addAttribute:NSForegroundColorAttributeName value:warningColor range:overtimeHoursStringRange];

        [stringsToJoin addObject:plusAttributedString];
        [stringsToJoin addObject:overtimeHoursAttributedString];
    }

    NSUInteger violationCount = [timesheetUser.violationsCount unsignedIntegerValue];
    if (violationCount > 0)
    {
        UIColor *warningColor = [self.theme timesheetUserOvertimeAndViolationsColor];
        NSString *violationsCountString;
        if(violationCount==1)
        {
         violationsCountString = [NSString stringWithFormat:@"%lu %@",(unsigned long)violationCount,RPLocalizedString(@"Violation", @"supervisor-dashboard.%lu Violation")];
        }
        else
        {
         violationsCountString = [NSString stringWithFormat:@"%lu %@",(unsigned long)violationCount,RPLocalizedString(@"Violations", @"supervisor-dashboard.%lu Violations")];
        }
        NSMutableAttributedString *violationsCountAttributedString = [[NSMutableAttributedString alloc] initWithString:violationsCountString];
        NSRange violationsCountRange = NSMakeRange(0, [violationsCountString length]);
        [violationsCountAttributedString addAttribute:NSForegroundColorAttributeName value:warningColor range:violationsCountRange];

        [stringsToJoin addObject:plusAttributedString];
        [stringsToJoin addObject:violationsCountAttributedString];
    }

    NSMutableAttributedString *finalAttributedString = [[NSMutableAttributedString alloc] init];
    for (NSAttributedString *attributedString in stringsToJoin) {
        [finalAttributedString appendAttributedString:attributedString];
    }

    return finalAttributedString;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - Private

- (NSString *)stringWithDateComponents:(NSDateComponents *)dateComponents
{
    return [NSString stringWithFormat:@"%02ldh:%02ldm", (long)dateComponents.hour, ABS((long)dateComponents.minute)];
}

@end
