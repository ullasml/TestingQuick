#import "TeamStatusTablePresenter.h"
#import "UserSummaryCell.h"
#import "TeamStatusSummaryNoUsersCell.h"
#import "PunchUser.h"
#import "Theme.h"
#import "TeamSectionHeaderView.h"
#import "UserSummaryPlaceholderCell.h"
#import "DurationCalculator.h"
#import "ImageFetcher.h"
#import "TeamStatusSummaryController.h"
#import <KSDeferred/KSPromise.h>
#import "BookedTimeOff.h"
#import "TeamTableStylist.h"


@interface TeamStatusTablePresenter ()

@property (nonatomic) id<Theme> theme;
@property (nonatomic) DurationCalculator *durationCalculator;
@property (nonatomic) ImageFetcher *imageFetcher;
@property (nonatomic) TeamTableStylist *teamTableStylist;

@end


@implementation TeamStatusTablePresenter

- (instancetype)initWithDurationCalculator:(DurationCalculator *)durationCalculator
                              imageFetcher:(ImageFetcher *)imageFetcher
                          teamTableStylist:(TeamTableStylist *)teamTableStylist
                                     theme:(id <Theme>)theme
{
    self = [super init];
    if (self) {
        self.durationCalculator = durationCalculator;
        self.imageFetcher = imageFetcher;
        self.teamTableStylist = teamTableStylist;
        self.theme = theme;
    }
    return self;
}

- (UserSummaryPlaceholderCell *)placeholderTableViewCellForTableView:(UITableView *)tableView
{
    UserSummaryPlaceholderCell *userSummaryPlaceholderCell = [tableView dequeueReusableCellWithIdentifier:@"UserSummaryPlaceholderCell"];
    if ([userSummaryPlaceholderCell respondsToSelector:@selector(setLayoutMargins:)]) {
        userSummaryPlaceholderCell.layoutMargins = UIEdgeInsetsZero;
    }

    return  userSummaryPlaceholderCell;
}

- (UITableViewCell *)tableViewCellForUsersArray:(NSArray *)users noUsersString:(NSString *)noUsersString tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath isShowHoursField:(BOOL)isShowHoursField {
    if([users count] > 0) {
        PunchUser *user = (PunchUser *)users[indexPath.row];
        return [self userCellForUser:user tableView:tableView indexPath:indexPath isShowHoursField:isShowHoursField];
    } else {
        return [self noUsersCellWithNoUsersString:noUsersString tableView:tableView];
    }
}


- (TeamSectionHeaderView *)sectionHeaderForSection:(NSInteger) section
{
    TeamSectionHeaderView *userSummarySectionHeaderView = [[TeamSectionHeaderView alloc] init];

    switch(section)
    {
        case TeamStatusTableSectionClockedIn:
            userSummarySectionHeaderView.sectionTitleLabel.text = RPLocalizedString(@"Clocked In", @"Clocked In");
            break;
        case TeamStatusTableSectionOnBreak:
            userSummarySectionHeaderView.sectionTitleLabel.text = RPLocalizedString(@"On Break", @"On Break");
            break;
        case TeamStatusTableSectionNotIn:
            userSummarySectionHeaderView.sectionTitleLabel.text = RPLocalizedString(@"Not In", @"Not In");
            break;
    }

    [self.teamTableStylist applyThemeToSectionHeaderView:userSummarySectionHeaderView];
    return userSummarySectionHeaderView;
}

#pragma mark - Private

- (TeamStatusSummaryNoUsersCell *)noUsersCellWithNoUsersString:(NSString *)noUsersString tableView:(UITableView *)tableView {
    TeamStatusSummaryNoUsersCell *noUsersCell = [tableView dequeueReusableCellWithIdentifier:@"TeamStatusSummaryNoUsersCell"];
    noUsersCell.noUsersCell.text = noUsersString;
    [self applyThemeToNoUsersCell:noUsersCell];
    return noUsersCell;
}

- (UserSummaryCell *)userCellForUser:(PunchUser *)user tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath isShowHoursField:(BOOL)isShowHoursField {
    UserSummaryCell *userCell = [tableView dequeueReusableCellWithIdentifier:@"UserSummaryCell"];
    [self hideDetailsLabelInUserCell:userCell];

    userCell.nameLabel.text = [user nameString];
    userCell.hoursLabel.text = [self calculateHoursStringForUser:user];

    if (isShowHoursField)
    {
        [userCell.hoursLabel setHidden:NO];
    }
    else
    {
        [userCell.hoursLabel setHidden:YES];
    }

    NSString *rawAddressString = user.addressString;


    if(indexPath.section == TeamStatusTableSectionNotIn && user.bookedTimeOffArray.count > 0) {
        [self showDetailsLabelInUserCell:userCell];
        NSMutableArray *formattedHoursStrings = [[NSMutableArray alloc] initWithCapacity:user.bookedTimeOffArray.count];

        for (BookedTimeOff *bookedTimeOff in user.bookedTimeOffArray) {
            NSString *formattedHoursString = bookedTimeOff.descriptionText;
            if (formattedHoursString) {
                [formattedHoursStrings addObject:formattedHoursString];
            }
        }

        NSString *timeOffString = [formattedHoursStrings componentsJoinedByString:@", "];
        userCell.detailsLabel.text = timeOffString;
    }
    else if(rawAddressString.length > 0) {
        [self showDetailsLabelInUserCell:userCell];
        NSString *formattedAddressString = [NSString localizedStringWithFormat:RPLocalizedString(@"at %@", @"at %@"), rawAddressString];
        userCell.detailsLabel.text = formattedAddressString;
    }

    [self loadImageForUser:user userCell:userCell indexPath:indexPath];

    [self applyThemeToUserCell:userCell forUser:user indexPath:indexPath];
    return userCell;
}

- (NSString *)calculateHoursStringForUser:(PunchUser *)user {
    NSDateComponents *sumOfHoursComponents = [self.durationCalculator sumOfTimeByAddingDateComponents:user.overtimeDateComponents
                                                                                     toDateComponents:user.regularDateComponents];
    NSString *hoursString = [NSString localizedStringWithFormat:RPLocalizedString(@"%02lu:%02lu Hrs", @"%02lu:%02lu Hrs"), sumOfHoursComponents.hour, sumOfHoursComponents.minute];
    return hoursString;
}


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

    userCell.detailsLabel.hidden = NO;
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

- (void)applyThemeToUserCell:(UserSummaryCell *)userCell forUser:(PunchUser *)user indexPath:(NSIndexPath *)indexPath {
    if ([userCell respondsToSelector:@selector(setLayoutMargins:)]) {
        userCell.layoutMargins = UIEdgeInsetsZero;
    }

    [self.teamTableStylist applyThemeToUserSummaryCell:userCell];

    userCell.hoursLabel.textColor = (user.bookedTimeOffArray.count > 0 && indexPath.section == TeamStatusTableSectionNotIn) ? [self.theme userSummaryCellHoursInactiveColor] : [self.theme userSummaryCellHoursColor];
}

- (void)applyThemeToNoUsersCell:(TeamStatusSummaryNoUsersCell *)noUsersCell
{
    if ([noUsersCell respondsToSelector:@selector(setLayoutMargins:)]) {
        noUsersCell.layoutMargins = UIEdgeInsetsZero;
    }
    noUsersCell.noUsersCell.font = [self.theme teamStatusCellNoUsersFont];
    noUsersCell.noUsersCell.textColor = [self.theme teamStatusCellNoUsersColor];
}


@end
