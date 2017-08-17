#import <MacTypes.h>
#import "TeamStatusSummaryController.h"
#import "UserSummaryPlaceholderCell.h"
#import <KSDeferred/KSPromise.h>
#import "TeamStatusSummary.h"
#import "TeamStatusSummaryNoUsersCell.h"
#import "UserSummaryCell.h"
#import "PunchUser.h"
#import "TeamStatusTablePresenter.h"
#import "TeamSectionHeaderView.h"
#import "TeamTableStylist.h"
#import "ErrorBannerViewParentPresenterHelper.h"

@interface TeamStatusSummaryController ()

@property (weak, nonatomic) IBOutlet UITableView *teamTableView;

@property (nonatomic) KSPromise                             *teamStatusSummaryPromise;
@property (nonatomic) TeamStatusSummary                     *teamStatusSummary;
@property (nonatomic) TeamStatusTablePresenter              *teamStatusTablePresenter;
@property (nonatomic) TeamTableStylist                      *teamTableStylist;
@property (nonatomic) TeamStatusTableSection                initiallyDisplayedSection;
@property (nonatomic) ErrorBannerViewParentPresenterHelper  *errorBannerViewParentPresenterHelper;
@end



@implementation TeamStatusSummaryController

- (instancetype)initWithErrorBannerViewParentPresenterHelper:(ErrorBannerViewParentPresenterHelper *)errorBannerViewParentPresenterHelper
                              teamStatusSummaryCellPresenter:(TeamStatusTablePresenter *)teamStatusSummaryCellPresenter
                                   initiallyDisplayedSection:(TeamStatusTableSection)initiallyDisplayedSection
                                    teamStatusSummaryPromise:(KSPromise *)teamStatusSummaryPromise
                                            teamTableStylist:(TeamTableStylist *)teamTableStylist {
    self = [super init];
    if (self) {
        self.errorBannerViewParentPresenterHelper =  errorBannerViewParentPresenterHelper;
        self.teamStatusTablePresenter = teamStatusSummaryCellPresenter;
        self.initiallyDisplayedSection = initiallyDisplayedSection;
        self.teamStatusSummaryPromise = teamStatusSummaryPromise;
        self.teamTableStylist = teamTableStylist;
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = RPLocalizedString(@"Punch Team Status", @"Punch Team Status");
    [self.errorBannerViewParentPresenterHelper setTableViewInsetWithErrorBannerPresentation:self.teamTableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.teamTableView registerNib:[UINib nibWithNibName:@"UserSummaryPlaceholderCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"UserSummaryPlaceholderCell"];
    [self.teamTableView registerNib:[UINib nibWithNibName:@"TeamStatusSummaryNoUsersCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"TeamStatusSummaryNoUsersCell"];
    [self.teamTableView registerNib:[UINib nibWithNibName:@"UserSummaryCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"UserSummaryCell"];
    [self.teamTableStylist applyThemeToTeamTableView:self.teamTableView];

    [self.teamStatusSummaryPromise then:^id(TeamStatusSummary *teamStatusSummary) {
        self.teamStatusSummary = teamStatusSummary;
        [self.teamTableView reloadData];
        [self.teamTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.initiallyDisplayedSection] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        return nil;
    } error:nil];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case TeamStatusTableSectionClockedIn:
            return self.teamStatusSummary.usersInArray.count > 0 ?  self.teamStatusSummary.usersInArray.count : 1;
        case TeamStatusTableSectionOnBreak:
            return self.teamStatusSummary.usersOnBreakArray.count > 0 ?  self.teamStatusSummary.usersOnBreakArray.count : 1;
        case TeamStatusTableSectionNotIn:
            return self.teamStatusSummary.usersNotInArray.count > 0 ?  self.teamStatusSummary.usersNotInArray.count : 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (self.teamStatusSummary)
    {
        switch (indexPath.section)
        {
            case TeamStatusTableSectionClockedIn:
                cell = [self.teamStatusTablePresenter tableViewCellForUsersArray:self.teamStatusSummary.usersInArray noUsersString:RPLocalizedString(@"No one is clocked in", @"No one is clocked in") tableView:tableView indexPath:indexPath isShowHoursField:YES];
                break;
            case TeamStatusTableSectionOnBreak:
                cell = [self.teamStatusTablePresenter tableViewCellForUsersArray:self.teamStatusSummary.usersOnBreakArray noUsersString:RPLocalizedString(@"No one is on break", @"No one is on break") tableView:tableView indexPath:indexPath isShowHoursField:NO];
                break;
            case TeamStatusTableSectionNotIn:
                cell = [self.teamStatusTablePresenter tableViewCellForUsersArray:self.teamStatusSummary.usersNotInArray noUsersString:RPLocalizedString(@"Everyone is occupied", @"Everyone is occupied") tableView:tableView indexPath:indexPath isShowHoursField:NO];
                break;
            default:
                break;
        }
    }
    else {
        cell = [self.teamStatusTablePresenter placeholderTableViewCellForTableView:self.teamTableView];
    }

    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self.teamStatusTablePresenter sectionHeaderForSection:section];
}

#pragma mark - NSObject

-(void)dealloc
{
    self.teamTableView.delegate = nil;
    self.teamTableView.dataSource = nil;
}

@end

