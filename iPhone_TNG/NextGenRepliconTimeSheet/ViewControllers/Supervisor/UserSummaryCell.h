
#import <UIKit/UIKit.h>

@interface UserSummaryCell : UITableViewCell

@property (nonatomic, weak, readonly) UILabel *nameLabel;
@property (weak, nonatomic, readonly) UILabel *detailsLabel;
@property (weak, nonatomic, readonly) UILabel *hoursLabel;
@property (weak, nonatomic, readonly) UIImageView *avatarImageView;


@end
