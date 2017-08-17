#import "InboxSpinnerCell.h"


@interface InboxSpinnerCell ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end


@implementation InboxSpinnerCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)prepareForReuse {
    [self.activityIndicatorView startAnimating];
}

@end
