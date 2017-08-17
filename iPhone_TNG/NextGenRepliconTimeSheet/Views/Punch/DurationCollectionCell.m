
#import "DurationCollectionCell.h"

@interface DurationCollectionCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationHoursLabel;
@property (weak, nonatomic) IBOutlet UIImageView *typeImageView;
@property (weak, nonatomic) IBOutlet UIView *leftspacingView;
@property (weak, nonatomic) IBOutlet UIView *spacingView;
@property (weak, nonatomic) IBOutlet UIView *rightItemDivider;

@end


@implementation DurationCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.spacingView.hidden = true;
    self.spacingView.backgroundColor = [UIColor clearColor];
    
    self.leftspacingView.hidden = true;
    self.leftspacingView.backgroundColor = [UIColor clearColor];
}

@end
