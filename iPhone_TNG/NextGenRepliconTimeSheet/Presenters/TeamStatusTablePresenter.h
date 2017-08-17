#import <Foundation/Foundation.h>


@protocol Theme;
@class TeamSectionHeaderView;
@class UserSummaryPlaceholderCell;
@class DurationCalculator;
@class ImageFetcher;
@class TeamTableStylist;

@interface TeamStatusTablePresenter : NSObject

@property (nonatomic, readonly) id<Theme> theme;
@property (nonatomic, readonly) DurationCalculator *durationCalculator;
@property (nonatomic, readonly) ImageFetcher *imageFetcher;
@property (nonatomic, readonly) TeamTableStylist *teamTableStylist;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithDurationCalculator:(DurationCalculator *)durationCalculator
                              imageFetcher:(ImageFetcher *)imageFetcher
                          teamTableStylist:(TeamTableStylist *)teamTableStylist
                                     theme:(id <Theme>)theme;

- (UITableViewCell *)tableViewCellForUsersArray:(NSArray *)users noUsersString:(NSString *)noUsersString tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath isShowHoursField:(BOOL)isShowHoursField;
- (TeamSectionHeaderView *) sectionHeaderForSection:(NSInteger) section;

- (UserSummaryPlaceholderCell *)placeholderTableViewCellForTableView:(UITableView *)tableView;
@end
