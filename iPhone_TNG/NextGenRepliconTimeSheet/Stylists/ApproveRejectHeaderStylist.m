#import "ApproveRejectHeaderStylist.h"
#import "Theme.h"
#import "ApprovalsPendingTimeOffTableViewHeader.h"


@interface ApproveRejectHeaderStylist ()

@property (nonatomic) id<Theme> theme;

@end


@implementation ApproveRejectHeaderStylist

- (instancetype)initWithTheme:(id<Theme>)theme
{
    self = [super init];
    if (self) {
        self.theme = theme;
    }

    return self;
}

- (void)styleApproveRejectHeader:(ApprovalsPendingTimeOffTableViewHeader *)headerView
{
    headerView.contentView.backgroundColor = [self.theme defaultTableViewHeaderBackgroundColor];
    headerView.approveButton.titleLabel.font = [self.theme defaultTableViewHeaderButtonFont];
    headerView.rejectButton.titleLabel.font = [self.theme defaultTableViewHeaderButtonFont];
    headerView.separatorView.backgroundColor = [self.theme separatorViewBackgroundColor];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
