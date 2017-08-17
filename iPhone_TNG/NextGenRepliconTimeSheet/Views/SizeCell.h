
#import <UIKit/UIKit.h>

@interface SizeCell : UITableViewCell
@property (weak, nonatomic, readonly)UILabel *valueLabel;
@property (weak, nonatomic, readonly) NSLayoutConstraint *valueLabelTopPaddingConstraint;
@property (weak, nonatomic, readonly) NSLayoutConstraint *valueLabelBottomPaddingConstraint;

@end
