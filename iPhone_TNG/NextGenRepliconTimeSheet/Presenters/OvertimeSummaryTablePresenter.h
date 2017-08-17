
#import <Foundation/Foundation.h>

@protocol Theme;

@class ImageFetcher;
@class TeamSectionHeaderView;
@class UserSummaryPlaceholderCell;
@class UserSummaryCell;
@class PunchUser;
@class TeamTableStylist;

@interface OvertimeSummaryTablePresenter : NSObject

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithImageFetcher:(ImageFetcher *)imageFetcher
                    teamTableStylist:(TeamTableStylist *)teamTableStylist;

- (TeamSectionHeaderView *)sectionHeaderForSection:(NSInteger) section;
- (UserSummaryPlaceholderCell *)placeholderTableViewCellForTableView:(UITableView *)tableView;
- (UserSummaryCell *)tableViewCellForPunchUser:(PunchUser *)punchUser
                                     tableView:(UITableView *)tableView
                                     indexPath:(NSIndexPath *)indexPath;

@end
