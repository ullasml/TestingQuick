#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TeamStatusCollectionItem) {
    TeamStatusCollectionItemClockedIn = 0,
    TeamStatusCollectionItemNotIn,
    TeamStatusCollectionItemOnBreak
};


@class TeamStatusSummaryCardContentStylist;
@class TeamStatusSummaryControllerProvider;
@class TeamStatusSummaryRepository;
@class SupervisorDashboardSummary;
@protocol Theme;


@interface SupervisorTeamStatusController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic, readonly) UICollectionView *collectionView;
@property (weak, nonatomic, readonly) UIView *separatorView;
@property (weak, nonatomic, readonly) UILabel *headerLabel;

@property (nonatomic, readonly) TeamStatusSummaryCardContentStylist *teamStatusSummaryCardContentStylist;
@property (nonatomic, readonly) TeamStatusSummaryControllerProvider *teamStatusSummaryControllerProvider;
@property (nonatomic, readonly) TeamStatusSummaryRepository *teamStatusSummaryRepository;
@property (nonatomic, readonly) id<Theme> theme;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTeamStatusSummaryCardContentStylist:(TeamStatusSummaryCardContentStylist *)teamStatusSummaryCardContentStylist
                        teamStatusSummaryControllerProvider:(TeamStatusSummaryControllerProvider *)teamStatusSummaryControllerProvider
                                teamStatusSummaryRepository:(TeamStatusSummaryRepository *)teamStatusSummaryRepository
                                                      theme:(id<Theme>)theme;

- (void)updateWithDashboardSummary:(SupervisorDashboardSummary *)supervisorDashboardSummary;

@end
