#import "SupervisorTeamStatusController.h"
#import "SupervisorDashboardTeamStatusSummaryCell.h"
#import "TeamStatusSummaryCardContentStylist.h"
#import "TeamStatusSummaryController.h"
#import "SupervisorDashboardSummary.h"
#import "TeamStatusSummaryRepository.h"
#import "TeamStatusSummaryControllerProvider.h"
#import "Theme.h"


@interface SupervisorTeamStatusController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;

@property (nonatomic) TeamStatusSummaryCardContentStylist *teamStatusSummaryCardContentStylist;
@property (nonatomic) TeamStatusSummaryControllerProvider *teamStatusSummaryControllerProvider;
@property (nonatomic) TeamStatusSummaryRepository *teamStatusSummaryRepository;
@property (nonatomic) id<Theme> theme;

@property (nonatomic) SupervisorDashboardSummary *supervisorDashboardSummary;
@property (nonatomic) KSPromise *teamStatusPromise;

@end


@implementation SupervisorTeamStatusController

- (instancetype)initWithTeamStatusSummaryCardContentStylist:(TeamStatusSummaryCardContentStylist *)teamStatusSummaryCardContentStylist
                        teamStatusSummaryControllerProvider:(TeamStatusSummaryControllerProvider *)teamStatusSummaryControllerProvider
                                teamStatusSummaryRepository:(TeamStatusSummaryRepository *)teamStatusSummaryRepository
                                                      theme:(id<Theme>)theme
{
    self = [super init];
    if (self)
    {
        self.teamStatusSummaryCardContentStylist = teamStatusSummaryCardContentStylist;
        self.teamStatusSummaryControllerProvider = teamStatusSummaryControllerProvider;
        self.teamStatusSummaryRepository = teamStatusSummaryRepository;
        self.theme = theme;
    }
    return self;
}

- (void)updateWithDashboardSummary:(SupervisorDashboardSummary *)supervisorDashboardSummary
{
    self.supervisorDashboardSummary = supervisorDashboardSummary;
    self.teamStatusPromise = [self.teamStatusSummaryRepository fetchTeamStatusSummary];
    [self.collectionView reloadData];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;

    self.collectionView.scrollEnabled = NO;

    self.headerLabel.text = RPLocalizedString(@"Punch Team Status", @"Punch Team Status");

    [self.collectionView registerClass:[SupervisorDashboardTeamStatusSummaryCell class]
            forCellWithReuseIdentifier:@"TeamStatusViewCell"];

    self.view.backgroundColor = [self.theme cardContainerBackgroundColor];
    self.view.layer.borderWidth = [self.theme cardContainerBorderWidth];
    self.view.layer.borderColor = [self.theme cardContainerBorderColor];
    self.headerLabel.font = [self.theme cardContainerHeaderFont];
    self.headerLabel.textColor = [self.theme cardContainerHeaderColor];
    self.separatorView.backgroundColor = [self.theme cardContainerSeparatorColor];

    self.collectionView.backgroundColor = [self.theme cardContainerSeparatorColor];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 3;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SupervisorDashboardTeamStatusSummaryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TeamStatusViewCell" forIndexPath:indexPath];

    switch (indexPath.row) {
        case TeamStatusCollectionItemClockedIn:
            [self.teamStatusSummaryCardContentStylist applyThemeForInStatusToCell:cell];
            cell.titleLabel.text = RPLocalizedString(@"In", @"In");
            cell.valueLabel.text = self.supervisorDashboardSummary ? [NSString stringWithFormat:@"%lu", (long)self.supervisorDashboardSummary.clockedInUsersCount] : @"-";
            break;

        case TeamStatusCollectionItemNotIn:
            [self.teamStatusSummaryCardContentStylist applyThemeForOutStatusToCell:cell];
            cell.titleLabel.text = RPLocalizedString(@"Not In", @"Not In");
            cell.valueLabel.text = self.supervisorDashboardSummary ? [NSString stringWithFormat:@"%lu", (long)self.supervisorDashboardSummary.notInUsersCount] : @"-";
            break;

        case TeamStatusCollectionItemOnBreak:
            [self.teamStatusSummaryCardContentStylist applyThemeForBreakStatusToCell:cell];
            cell.titleLabel.text = RPLocalizedString(@"Break", @"Break");
            cell.valueLabel.text = self.supervisorDashboardSummary ? [NSString stringWithFormat:@"%lu", (long)self.supervisorDashboardSummary.onBreakUsersCount] : @"-";
            break;

        default:
            break;
    }

    return cell;
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.teamStatusSummaryCardContentStylist calculateItemSizeForStatusSummaryCollectionView:collectionView];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{   
    return [self.teamStatusSummaryCardContentStylist teamStatusSeperatorWidth];
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.teamStatusPromise) {
        TeamStatusTableSection teamStatusTableSection;
        switch (indexPath.item) {
            case TeamStatusCollectionItemClockedIn:
                teamStatusTableSection = TeamStatusTableSectionClockedIn;
                break;
            case TeamStatusCollectionItemOnBreak:
                teamStatusTableSection = TeamStatusTableSectionOnBreak;
                break;
            case TeamStatusCollectionItemNotIn:
                teamStatusTableSection = TeamStatusTableSectionNotIn;
        }

        TeamStatusSummaryController *teamStatusSummaryController = [self.teamStatusSummaryControllerProvider provideInstanceWithTeamStatusSummaryPromise:self.teamStatusPromise initiallyDisplayedSection:teamStatusTableSection];
        [self.navigationController pushViewController:teamStatusSummaryController animated:YES];
    }
}

@end
