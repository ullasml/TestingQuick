
#import "MissingPunchCell.h"


@interface MissingPunchCell ()

@property (weak, nonatomic) IBOutlet UILabel *punchType;
@property (weak, nonatomic) IBOutlet UIView *descendingLineView;
@property (weak, nonatomic) IBOutlet UIImageView *punchUserImageView;
@property (weak, nonatomic) IBOutlet UIView *cellSeparator;

@end


@implementation MissingPunchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
