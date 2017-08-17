#import "OvertimeSummaryTablePresenter.h"
#import "PunchUser.h"
#import "UserSummaryCell.h"
#import "ImageFetcher.h"
#import <KSDeferred/KSPromise.h>
#import "UserSummaryPlaceholderCell.h"
#import "TeamSectionHeaderView.h"
#import "TeamTableStylist.h"


@interface OvertimeSummaryTablePresenter ()

@property (nonatomic) ImageFetcher *imageFetcher;
@property (nonatomic) TeamTableStylist *teamTableStylist;

@end

@implementation OvertimeSummaryTablePresenter

- (instancetype)initWithImageFetcher:(ImageFetcher *)imageFetcher
                    teamTableStylist:(TeamTableStylist *)teamTableStylist
{
    self = [super init];
    if (self) {
        self.imageFetcher = imageFetcher;
        self.teamTableStylist = teamTableStylist;
    }
    return self;
}


- (TeamSectionHeaderView *)sectionHeaderForSection:(NSInteger) section
{
    TeamSectionHeaderView *userSummarySectionHeaderView = [[TeamSectionHeaderView alloc] init];
    userSummarySectionHeaderView.sectionTitleLabel.text = RPLocalizedString(@"Employees on overtime", @"Employees on overtime");
    [self.teamTableStylist applyThemeToSectionHeaderView:userSummarySectionHeaderView];
    return userSummarySectionHeaderView;
}

- (UserSummaryPlaceholderCell *)placeholderTableViewCellForTableView:(UITableView *)tableView
{
    UserSummaryPlaceholderCell *userSummaryPlaceholderCell = [tableView dequeueReusableCellWithIdentifier:@"UserSummaryPlaceholderCell"];
    if ([userSummaryPlaceholderCell respondsToSelector:@selector(setLayoutMargins:)]) {
        userSummaryPlaceholderCell.layoutMargins = UIEdgeInsetsZero;
    }

    return  userSummaryPlaceholderCell;
}

- (UserSummaryCell *)tableViewCellForPunchUser:(PunchUser *)punchUser
                                     tableView:(UITableView *)tableView
                                     indexPath:(NSIndexPath *)indexPath
{
    UserSummaryCell *userCell = [tableView dequeueReusableCellWithIdentifier:@"OvertimeSummaryUserCell"];

    [self hideDetailsLabelInUserCell:userCell];

    userCell.nameLabel.text = punchUser.nameString;

    NSDateComponents *overtimeComponents = punchUser.overtimeDateComponents;
    NSString *hoursLabelText = [NSString localizedStringWithFormat:RPLocalizedString(@"%02lu:%02lu Hrs", @"%02lu:%02lu Hrs"), overtimeComponents.hour, overtimeComponents.minute];
    userCell.hoursLabel.text = hoursLabelText;

    NSString *rawAddressString = punchUser.addressString;

    if(rawAddressString.length > 0) {
        NSString *formattedAddressString = [NSString localizedStringWithFormat:RPLocalizedString(@"at %@", @"at %@"), rawAddressString];
        userCell.detailsLabel.text = formattedAddressString;
        [self showDetailsLabelInUserCell:userCell];
    }

    [self loadImageForUser:punchUser userCell:userCell indexPath:indexPath];
    [self.teamTableStylist applyThemeToUserSummaryCell:userCell];

    return userCell;
}

#pragma mark - Private

- (void)showDetailsLabelInUserCell:(UserSummaryCell *)userCell
{
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:userCell.detailsLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:userCell.nameLabel attribute:NSLayoutAttributeLeading multiplier:1 constant:0];

    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:userCell.detailsLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:userCell.avatarImageView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];

    NSLayoutConstraint *nameLabelBottom = [NSLayoutConstraint constraintWithItem:userCell.nameLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:userCell.detailsLabel attribute:NSLayoutAttributeBottom multiplier:1 constant:-20];

    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:userCell.detailsLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:userCell.nameLabel attribute:NSLayoutAttributeWidth multiplier:1 constant:0];

    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:userCell.detailsLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:userCell.nameLabel attribute:NSLayoutAttributeHeight multiplier:1 constant:0];

    [userCell addConstraint:leadingConstraint];
    [userCell addConstraint:bottomConstraint];
    [userCell addConstraint:nameLabelBottom];
    [userCell addConstraint:widthConstraint];
    [userCell addConstraint:heightConstraint];

    [userCell.detailsLabel setHidden:NO];
}

- (void)hideDetailsLabelInUserCell:(UserSummaryCell *)userCell
{
    [userCell.detailsLabel removeConstraints:userCell.constraints];
    [userCell layoutIfNeeded];
    userCell.detailsLabel.hidden = YES;
}

- (void)loadImageForUser:(PunchUser *)user userCell:(UserSummaryCell *)userCell indexPath:(NSIndexPath *)indexPath {
    userCell.avatarImageView.image = [UIImage imageNamed:@"Avatar_placeholder_sm"];

    NSInteger tagValue = (indexPath.section * 100000) + indexPath.row;
    userCell.tag = tagValue;

    if (user.imageURL) {
        KSPromise *imageFetchPromise = [self.imageFetcher promiseWithImageURL:user.imageURL];

        [imageFetchPromise then:^id(UIImage *image) {
            if (userCell.tag == tagValue) {
                userCell.avatarImageView.image = image;
            }
            return nil;
        } error:nil];
    }
}


@end
