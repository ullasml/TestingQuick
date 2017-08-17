#import <UIKit/UIKit.h>


@interface TimeLineCell : UITableViewCell

@property (weak, nonatomic, readonly) UILabel *timeLabel;
@property (weak, nonatomic, readonly) UILabel *ampmLabel;
@property (weak, nonatomic, readonly) UILabel *descriptionLabel;
@property (weak, nonatomic, readonly) UIImageView *punchActionIconImageView;
@property (weak, nonatomic, readonly) UIView *ascendingLineView;
@property (weak, nonatomic, readonly) UIView *descendingLineView;


@end
