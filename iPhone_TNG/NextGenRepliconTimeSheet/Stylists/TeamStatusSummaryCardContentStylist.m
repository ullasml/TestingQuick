#import "TeamStatusSummaryCardContentStylist.h"
#import "SupervisorDashboardTeamStatusSummaryCell.h"
#import "Theme.h"


#define TEAM_STATUS_CONTENT_HEIGHT 54
#define TEAM_STATUS_ITEM_HEIGHT 54
#define TEAM_STATUS_SEPERATOR_WIDTH 1


@interface TeamStatusSummaryCardContentStylist ()

@property (nonatomic) id <Theme> theme;
@end
@implementation TeamStatusSummaryCardContentStylist

-(instancetype)initWithTheme:(id <Theme> )theme;
{
    self = [super init];
    if (self) {
        self.theme = theme;
    }
    return self;
}
- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(CGSize)calculateItemSizeForStatusSummaryCollectionView:(UICollectionView *)collectionView
{
    CGFloat collectionViewWidth = collectionView.frame.size.width;
    CGFloat width = (collectionViewWidth - (2 * TEAM_STATUS_SEPERATOR_WIDTH)) / 3;

    return CGSizeMake(width, TEAM_STATUS_ITEM_HEIGHT);
}

-(CGFloat)teamStatusSeperatorWidth
{
    return TEAM_STATUS_SEPERATOR_WIDTH;
}

-(void)applyThemeForInStatusToCell:(SupervisorDashboardTeamStatusSummaryCell *)collectionViewCell
{
    [self applyDefaultThemeToStatusCell:collectionViewCell];
    collectionViewCell.valueLabel.textColor = [self.theme teamStatusInColor];
}

- (void)applyThemeForOutStatusToCell:(SupervisorDashboardTeamStatusSummaryCell *)collectionViewCell
{
    [self applyDefaultThemeToStatusCell:collectionViewCell];
    collectionViewCell.valueLabel.textColor = [self.theme teamStatusOutColor];
}

- (void)applyThemeForBreakStatusToCell:(SupervisorDashboardTeamStatusSummaryCell *)collectionViewCell
{
    [self applyDefaultThemeToStatusCell:collectionViewCell];
    collectionViewCell.valueLabel.textColor = [self.theme teamStatusBreakColor];
}

#pragma mark - Private

- (void)applyDefaultThemeToStatusCell:(SupervisorDashboardTeamStatusSummaryCell *)collectionViewCell {
    collectionViewCell.backgroundColor = [self.theme userSummaryCellBackgroundColor];
    collectionViewCell.titleLabel.font = [self.theme teamStatusTitleFont];
    collectionViewCell.titleLabel.textColor = [self.theme teamStatusTitleColor];
    collectionViewCell.valueLabel.font = [self.theme teamStatusValueFont];
}

@end
