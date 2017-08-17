#import "DayTimeSummaryCell.h"

@interface DayTimeSummaryCell ()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *regularTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *breakTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *separator;
@property (weak, nonatomic) IBOutlet UILabel *issueCount;
@property (weak, nonatomic) IBOutlet UIImageView *violationImage;
@property (weak, nonatomic) IBOutlet UILabel *timeOffTimeLabel;

@end

@implementation DayTimeSummaryCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    if ([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        self.preservesSuperviewLayoutMargins = NO;
        self.layoutMargins = UIEdgeInsetsZero;
    }

    [self.dateLabel setAccessibilityIdentifier:@"uia_timesheet_day_label_identifier"];
    [self.regularTimeLabel setAccessibilityIdentifier:@"uia_timesheet_day_work_hours_value_label_identifier"];
    [self.breakTimeLabel setAccessibilityIdentifier:@"uia_timesheet_day_break_hours_value_label_identifier"];

}

@end
