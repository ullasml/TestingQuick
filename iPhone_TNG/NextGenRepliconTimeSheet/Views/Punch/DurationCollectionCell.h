
#import <UIKit/UIKit.h>

@interface DurationCollectionCell : UICollectionViewCell

@property (weak, nonatomic, readonly) UILabel *nameLabel;
@property (weak, nonatomic, readonly) UILabel *durationHoursLabel;
@property (weak, nonatomic, readonly) UIImageView *typeImageView;
@property (weak, nonatomic, readonly) UIView *leftspacingView;
@property (weak, nonatomic, readonly) UIView *spacingView;
@property (weak, nonatomic, readonly) UIView *rightItemDivider;

@end
