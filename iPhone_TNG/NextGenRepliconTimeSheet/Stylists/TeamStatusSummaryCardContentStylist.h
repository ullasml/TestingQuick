#import <Foundation/Foundation.h>

@class SupervisorDashboardTeamStatusSummaryCell;
@protocol Theme;


@interface TeamStatusSummaryCardContentStylist : NSObject

@property (nonatomic, readonly) id <Theme> theme;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTheme:(id <Theme> )theme NS_DESIGNATED_INITIALIZER;

- (CGSize)calculateItemSizeForStatusSummaryCollectionView:(UICollectionView *)collectionView;
- (CGFloat)teamStatusSeperatorWidth;
- (void)applyThemeForInStatusToCell:(SupervisorDashboardTeamStatusSummaryCell *)collectionViewCell;
- (void)applyThemeForOutStatusToCell:(SupervisorDashboardTeamStatusSummaryCell *)collectionViewCell;
- (void)applyThemeForBreakStatusToCell:(SupervisorDashboardTeamStatusSummaryCell *)collectionViewCell;

@end
