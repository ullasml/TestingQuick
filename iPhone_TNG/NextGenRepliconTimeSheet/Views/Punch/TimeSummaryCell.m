#import "TimeSummaryCell.h"


@implementation TimeSummaryCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.valueLabel setAccessibilityIdentifier:@"uia_hours_value_label_identifier"];
}


@end
