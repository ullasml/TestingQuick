

#import "AllPunchCardCell.h"

@interface AllPunchCardCell ()
@property (weak, nonatomic) IBOutlet UILabel *clientLabel;
@property (weak, nonatomic) IBOutlet UILabel *projectLabel;
@property (weak, nonatomic) IBOutlet UILabel *taskLabel;
@property (weak, nonatomic) IBOutlet UIView  *borderView;
@property (weak, nonatomic) IBOutlet UIImageView *chevronImage;
@end

@implementation AllPunchCardCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
