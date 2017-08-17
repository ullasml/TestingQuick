#import "ApprovalsPendingTimeOffTableViewHeader.h"
#import "Constants.h"


@interface ApprovalsPendingTimeOffTableViewHeader ()

@property (weak, nonatomic) IBOutlet UIButton *rejectButton;
@property (weak, nonatomic) IBOutlet UIButton *approveButton;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UIButton *toggleButton;

@end


@implementation ApprovalsPendingTimeOffTableViewHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
    UIView *actualContentView = (id)[[nib instantiateWithOwner:self options:nil] firstObject];
    actualContentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:actualContentView];

    NSDictionary *views = @{@"childView": actualContentView};
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[childView]|" options:0 metrics:nil views:views];
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[childView]|" options:0 metrics:nil views:views];
    NSArray *constraints = [horizontalConstraints arrayByAddingObjectsFromArray:verticalConstraints];
    [self.contentView addConstraints:constraints];

    [self.rejectButton setTitle:RPLocalizedString(REJECT_TEXT, REJECT_TEXT) forState:UIControlStateNormal];
    [self.approveButton setTitle:RPLocalizedString(APPROVE_TEXT, APPROVE_TEXT) forState:UIControlStateNormal];
    [self.approveButton setAccessibilityLabel:@"approve_button_label"];
    [self.rejectButton setAccessibilityLabel:@"reject_button_label"];

    [self.toggleButton setTitle:RPLocalizedString(@"Select All", @"Select All") forState:UIControlStateNormal];
    self.toggleButton.tag = CHECK_ALL_BUTTON_TAG;


}

- (IBAction)didTapApproveButton:(id)sender
{
    [self.delegate approvalsPendingTimeOffTableViewHeaderDidSignalIntentToApprove:self];
}

- (IBAction)didTapRejectButton:(id)sender
{
    [self.delegate approvalsPendingTimeOffTableViewHeaderDidSignalIntentToReject:self];
}

- (IBAction)didToggleButtonForSelectOrClearAll:(id)sender
{
    if (self.toggleButton.tag == CHECK_ALL_BUTTON_TAG)
    {
        [self.delegate approvalsPendingTimeOffTableViewHeaderDidSignalIntentToSelectAll:self];
        [self.toggleButton setTitle:RPLocalizedString(@"Clear All", @"Clear All") forState:UIControlStateNormal];
        self.toggleButton.tag = CLEAR_ALL_BUTTON_TAG;
    }
    else
    {
        [self.delegate approvalsPendingTimeOffTableViewHeaderDidSignalIntentToClearAll:self];
        [self.toggleButton setTitle:RPLocalizedString(@"Select All", @"Select All") forState:UIControlStateNormal];
        self.toggleButton.tag = CHECK_ALL_BUTTON_TAG;
    }
}

@end
