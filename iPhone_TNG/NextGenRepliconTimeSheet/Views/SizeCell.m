
#import "SizeCell.h"
@interface SizeCell ()
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *valueLabelTopPaddingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *valueLabelBottomPaddingConstraint;

@end
@implementation SizeCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
