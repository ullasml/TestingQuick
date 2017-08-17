#import "GoldenTimesheetUsersCell.h"

@interface GoldenTimesheetUsersCell ()

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *workHoursLabel;
@property (weak, nonatomic) IBOutlet UILabel *breakHoursLabel;
@property (weak, nonatomic) IBOutlet UIImageView *warningImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *warningImageContainerViewWidthConstraint;

@end

@implementation GoldenTimesheetUsersCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        self.layoutMargins = UIEdgeInsetsZero;
        self.preservesSuperviewLayoutMargins = NO;
    }
    self.warningImageContainerViewWidthConstraint.constant = 0;
}

@end
