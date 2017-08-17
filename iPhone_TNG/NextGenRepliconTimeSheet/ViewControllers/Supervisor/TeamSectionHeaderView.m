#import "TeamSectionHeaderView.h"

@interface TeamSectionHeaderView ()

@property (nonatomic) IBOutlet UILabel *sectionTitleLabel;


@end

@implementation TeamSectionHeaderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sectionTitleLabel = [[UILabel alloc] init];
        self.sectionTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.sectionTitleLabel];

        NSDictionary *views = @{@"sectionTitleLabel":self.sectionTitleLabel};
        NSArray *xConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[sectionTitleLabel(200)]" options:0 metrics:nil views:views];
        NSArray *yConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sectionTitleLabel]|" options:0 metrics:nil views:views];
        [self addConstraints:xConstraints];
        [self addConstraints:yConstraints];
    }

    return self;
}



@end
