#import <Foundation/Foundation.h>

@protocol Theme;
@class UserSummaryCell;
@class TeamSectionHeaderView;

@interface TeamTableStylist : NSObject

@property (nonatomic, readonly) id<Theme> theme;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTheme:(id<Theme>)theme NS_DESIGNATED_INITIALIZER;

- (void)applyThemeToTeamTableView:(UITableView *)teamTableview;
- (void)applyThemeToSectionHeaderView:(TeamSectionHeaderView *)sectionHeaderView;
- (void)applyThemeToUserSummaryCell:(UserSummaryCell *)userCell;

@end
