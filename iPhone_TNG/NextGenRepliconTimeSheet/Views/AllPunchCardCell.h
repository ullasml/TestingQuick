
#import <UIKit/UIKit.h>

@interface AllPunchCardCell : UITableViewCell
@property (weak, nonatomic,readonly) UILabel *clientLabel;
@property (weak, nonatomic,readonly) UILabel *projectLabel;
@property (weak, nonatomic,readonly) UILabel *taskLabel;
@property (weak, nonatomic,readonly) UIView  *borderView;
@property (weak, nonatomic,readonly) UIImageView *chevronImage;

@end
