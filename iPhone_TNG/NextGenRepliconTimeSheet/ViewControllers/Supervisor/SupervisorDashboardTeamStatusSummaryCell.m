#import "SupervisorDashboardTeamStatusSummaryCell.h"

@interface SupervisorDashboardTeamStatusSummaryCell ()

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *valueLabel;

@end

@implementation SupervisorDashboardTeamStatusSummaryCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.valueLabel = [[UILabel alloc] init];
        self.valueLabel.textAlignment = NSTextAlignmentCenter;
        self.valueLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.contentView addSubview:self.valueLabel];
        [self.contentView addSubview:self.titleLabel];

        NSDictionary *views = @{@"valueLabel": self.valueLabel, @"titleLabel": self.titleLabel};
        NSArray *yConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(13)-[valueLabel(15)]-(0)-[titleLabel(15)]" options:0 metrics:nil views:views];
        NSArray *titleLabelXConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[titleLabel]|" options:0 metrics:nil views:views];
        NSArray *valueLabelXConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[valueLabel]|" options:0 metrics:nil views:views];

        [self addConstraints:yConstraints];
        [self addConstraints:titleLabelXConstraints];
        [self addConstraints:valueLabelXConstraints];
    }
    return self;
}

    
@end
