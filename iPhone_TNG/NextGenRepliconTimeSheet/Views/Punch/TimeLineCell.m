#import "TimeLineCell.h"


@interface TimeLineCell ()

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *ampmLabel;
@property (weak, nonatomic) IBOutlet UIImageView *punchActionIconImageView;
@property (weak, nonatomic) IBOutlet UIView *ascendingLineView;
@property (weak, nonatomic) IBOutlet UIView *descendingLineView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;



@end


@implementation TimeLineCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    [self.rowFirstEntryLabel setAccessibilityIdentifier:@"timeline_entry_lbl"];
    [self.timeLabel setAccessibilityIdentifier:@"timeline_time_entry_lbl"];
}

@end
