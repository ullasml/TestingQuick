
#import "AddPunchTimeLineCell.h"

@interface AddPunchTimeLineCell ()

@property (weak, nonatomic) IBOutlet UIButton *addPunchBtn;
@property (nonatomic) id <AddPunchTimeLineCellDelegate>delegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addPunchTopConstraint;
@end


@implementation AddPunchTimeLineCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setUpWithDelegate:(id<AddPunchTimeLineCellDelegate>)delegate topConstraint:(CGFloat)topPadding
{
    self.delegate = delegate;
    self.addPunchTopConstraint.constant = topPadding;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
- (IBAction)addPunchButtonClicked:(id)sender {
    if([self.delegate respondsToSelector:@selector(addPunchTimeLineCell:intendedToAddManualPunch:)])
    {
        [self.delegate addPunchTimeLineCell:self intendedToAddManualPunch:sender];
    }
}

@end
