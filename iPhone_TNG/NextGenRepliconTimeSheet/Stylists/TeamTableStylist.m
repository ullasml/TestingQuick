#import "TeamTableStylist.h"
#import "Theme.h"
#import "TeamSectionHeaderView.h"
#import "UserSummaryCell.h"

@interface TeamTableStylist ()

@property (nonatomic) id<Theme> theme;

@end


@implementation TeamTableStylist

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initWithTheme:(id<Theme>)theme
{
    self = [super init];
    if (self) {
        self.theme = theme;
    }
    return self;
}

-(void)applyThemeToTeamTableView:(UITableView *)teamTableview
{
    if ([teamTableview respondsToSelector:@selector(setLayoutMargins:)]) {
        teamTableview.layoutMargins = UIEdgeInsetsZero;
    }
    teamTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    teamTableview.backgroundColor = [self.theme userSummaryCellBackgroundColor];
}

- (void)applyThemeToSectionHeaderView:(TeamSectionHeaderView *)sectionHeaderView
{
    sectionHeaderView.sectionTitleLabel.font = [self.theme teamTableViewSectionHeaderFont];
    sectionHeaderView.sectionTitleLabel.textColor = [self.theme teamTableViewSectionHeaderTextColor];
    sectionHeaderView.backgroundColor = [self.theme teamTableViewSectionHeaderBackgroundColor];
}

- (void)applyThemeToUserSummaryCell:(UserSummaryCell *)userCell
{
    if ([userCell respondsToSelector:@selector(setLayoutMargins:)]) {
        userCell.layoutMargins = UIEdgeInsetsZero;
    }
    userCell.nameLabel.font = [self.theme userSummaryCellNameFont];
    userCell.nameLabel.textColor = [self.theme userSummaryCellNameColor];
    userCell.detailsLabel.font = [self.theme userSummaryCellDetailsFont];
    userCell.detailsLabel.textColor = [self.theme userSummaryCellDetailsColor];
    userCell.hoursLabel.font = [self.theme userSummaryCellHoursFont];
    userCell.hoursLabel.textColor = [self.theme userSummaryCellHoursColor];

    userCell.avatarImageView.layer.cornerRadius = 21;
    userCell.avatarImageView.layer.masksToBounds = YES;
}

@end
