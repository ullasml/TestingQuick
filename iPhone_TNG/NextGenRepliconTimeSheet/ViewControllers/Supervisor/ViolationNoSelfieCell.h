#import <UIKit/UIKit.h>

@interface ViolationNoSelfieCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeAndStatusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *severityImageView;

@end
