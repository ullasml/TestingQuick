#import "OvertimeSummaryController.h"
#import <KSDeferred/KSPromise.h>
#import "OvertimeSummaryTablePresenter.h"
#import "UserSummaryCell.h"
#import "SupervisorDashboardSummary.h"
#import "UserSummaryPlaceholderCell.h"
#import "TeamSectionHeaderView.h"
#import "TeamTableStylist.h"

@interface OvertimeSummaryController ()

@property (weak, nonatomic) IBOutlet UITableView *overtimeTableView;
@property (nonatomic) KSPromise *supervisorDashboardSummaryPromise;
@property (nonatomic) NSArray *overtimeUsersArray;
@property (nonatomic) OvertimeSummaryTablePresenter *overtimeSummaryTablePresenter;
@property (nonatomic) TeamTableStylist *teamTableStylist;

@end


@implementation OvertimeSummaryController

- (instancetype)initWithOvertimeSummaryPromise:(KSPromise *)overtimeSummaryPromise
                 overtimeSummaryTablePresenter:(OvertimeSummaryTablePresenter *)overtimeSummaryTablePresenter
                              teamTableStylist:(TeamTableStylist *)teamTableStylist
{
    self = [super init];
    if (self) {
        self.supervisorDashboardSummaryPromise = overtimeSummaryPromise;
        self.overtimeSummaryTablePresenter = overtimeSummaryTablePresenter;
        self.teamTableStylist = teamTableStylist;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.overtimeTableView registerNib:[UINib nibWithNibName:@"UserSummaryCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"OvertimeSummaryUserCell"];
    [self.overtimeTableView registerNib:[UINib nibWithNibName:@"UserSummaryPlaceholderCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"UserSummaryPlaceholderCell"];

    [self.teamTableStylist applyThemeToTeamTableView:self.overtimeTableView];
    [self.supervisorDashboardSummaryPromise then:^id(SupervisorDashboardSummary *dashboardSummary) {
        self.overtimeUsersArray = dashboardSummary.overtimeUsersArray;
        [self.overtimeTableView reloadData];

        return nil;
    } error:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationItem.title = RPLocalizedString(@"Overtime", @"Overtime");
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.supervisorDashboardSummaryPromise.fulfilled ? [self.overtimeUsersArray count] : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if(self.supervisorDashboardSummaryPromise.fulfilled) {
        PunchUser *punchUser = [self.overtimeUsersArray objectAtIndex:indexPath.row];
        cell = [self.overtimeSummaryTablePresenter tableViewCellForPunchUser:punchUser
                                                                   tableView:tableView
                                                                   indexPath:indexPath];

    }
    else {
        cell = [self.overtimeSummaryTablePresenter placeholderTableViewCellForTableView:self.overtimeTableView];
    }

    return cell;
}

#pragma mark - <UITableViewDelegate>

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self.overtimeSummaryTablePresenter sectionHeaderForSection:section];
}


- (void)dealloc
{
    self.overtimeTableView.delegate = nil;
    self.overtimeTableView.dataSource = nil;
}
@end
