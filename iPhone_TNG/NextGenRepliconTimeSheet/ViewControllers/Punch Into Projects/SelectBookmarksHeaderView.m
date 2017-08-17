
#import "SelectBookmarksHeaderView.h"

@interface SelectBookmarksHeaderView ()

@property (nonatomic) IBOutlet UILabel *sectionTitleLabel;


@end

@implementation SelectBookmarksHeaderView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sectionTitleLabel = [[UILabel alloc] init];
        self.sectionTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.sectionTitleLabel];
        
        NSDictionary *views = @{@"sectionTitleLabel":self.sectionTitleLabel};
        NSArray *xConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[sectionTitleLabel]" options:0 metrics:nil views:views];
        NSArray *yConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[sectionTitleLabel]|" options:0 metrics:nil views:views];
        [self addConstraints:xConstraints];
        [self addConstraints:yConstraints];
    }
    
    return self;
}

@end
