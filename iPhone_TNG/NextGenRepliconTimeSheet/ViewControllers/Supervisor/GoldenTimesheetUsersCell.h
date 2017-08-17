#import <UIKit/UIKit.h>

@interface GoldenTimesheetUsersCell : UITableViewCell

@property (weak, nonatomic, readonly) UILabel *userNameLabel;
@property (weak, nonatomic, readonly) UILabel *workHoursLabel;
@property (weak, nonatomic, readonly) UILabel *breakHoursLabel;
@property (weak, nonatomic, readonly) UIImageView *warningImageView;

@property (weak, nonatomic, readonly) NSLayoutConstraint *warningImageContainerViewWidthConstraint;

@end
