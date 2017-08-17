
#import "BookmarkTwoEntriesCell.h"

@interface BookmarkTwoEntriesCell ()
@property (weak, nonatomic) IBOutlet UILabel *firstEntryLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondEntryLabel;
@property (weak, nonatomic) IBOutlet UIView  *borderView;
@property (weak, nonatomic) IBOutlet UIImageView *chevronImage;
@end

@implementation BookmarkTwoEntriesCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
