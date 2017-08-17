#import "GoldenAndNonGoldenTimesheetsController.h"
#import <KSDeferred/KSPromise.h>
#import "GoldenTimesheetUsersCell.h"
#import "TeamTimesheetsForTimePeriod.h"
#import "Theme.h"
#import "TimesheetUserCellPresenter.h"
#import <Blindside/Blindside.h>
#import <KSDeferred/KSDeferred.h>
#import "TimesheetUsersSectionHeaderViewPresenter.h"
#import "TimesheetUsersSectionHeaderView.h"
#import "TimesheetForUserWithWorkHours.h"
#import "TimesheetTablePresenter.h"
#import "TimesheetContainerController.h"


@interface GoldenAndNonGoldenTimesheetsController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *timesheetTableview;

@property (nonatomic) id<Theme> theme;
@property (nonatomic, assign) TimesheetUserType timesheetUserType;
@property (nonatomic) TimesheetUserCellPresenter *cellPresenter;
@property (nonatomic) TimesheetUsersSectionHeaderViewPresenter *sectionHeaderViewPresenter;
@property (nonatomic) TimesheetTablePresenter *timesheetTablePresenter;
@property (nonatomic, weak) id <BSInjector> injector;

@property (nonatomic, copy) NSArray *timesheetPeriods;

@property (nonatomic, weak) id<TimesheetUserControllerDelegate> delegate;
@property (nonatomic) KSPromise *timesheetUsersPromise;

@end


static NSString * const timesheetUsersCellReuseIdentifier = @"timesheetUsersCellReuseIdentifier";
static NSString * const timesheetSectionHeaderReuseIdentifier = @"timesheetSectionHeaderReuseIdentifier";


@implementation GoldenAndNonGoldenTimesheetsController

- (instancetype)initWithTimesheetUserTypeSectionHeaderPresenter:(TimesheetUsersSectionHeaderViewPresenter *)sectionHeaderViewPresenter
                                        timesheetTablePresenter:(TimesheetTablePresenter *)timesheetTablePresenter
                                              typesheetUserType:(TimesheetUserType)typesheetUserType
                                                  cellPresenter:(TimesheetUserCellPresenter *)cellPresenter
                                                          theme:(id<Theme>)theme
{
    self = [super init];
    if (self)
    {
        self.sectionHeaderViewPresenter = sectionHeaderViewPresenter;
        self.timesheetTablePresenter = timesheetTablePresenter;
        self.timesheetUserType = typesheetUserType;
        self.cellPresenter = cellPresenter;
        self.theme = theme;
    }
    return self;
}

- (void)setupWithTimesheetUsersPromise:(KSPromise *)timesheetUsersPromise
                              delegate:(id<TimesheetUserControllerDelegate>)delegate
{
    self.timesheetUsersPromise = timesheetUsersPromise;
    self.delegate = delegate;
}

#pragma mark - NSObject

- (void)dealloc
{
    self.timesheetTableview.dataSource = nil;
    self.timesheetTableview.delegate = nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.timesheetTableview.accessibilityLabel = @"goldenNonGolden_tableview";
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([GoldenTimesheetUsersCell class]) bundle:nil];
    UINib *sectionHeaderNib = [UINib nibWithNibName:NSStringFromClass([TimesheetUsersSectionHeaderView class]) bundle:nil];

    [self.timesheetTableview registerNib:cellNib forCellReuseIdentifier:timesheetUsersCellReuseIdentifier];
    [self.timesheetTableview registerNib:sectionHeaderNib forHeaderFooterViewReuseIdentifier:timesheetSectionHeaderReuseIdentifier];
    self.timesheetTableview.tableHeaderView = [self headerViewForTable];
    [self.timesheetTableview setSeparatorInset:UIEdgeInsetsZero];

    [self.timesheetUsersPromise then:^id(NSArray *timesheetPeriods) {
        self.timesheetPeriods = timesheetPeriods;
        [self.timesheetTableview reloadData];

        CGFloat height = [self.timesheetTablePresenter heightForTableView:self.timesheetTableview timesheetPeriods:timesheetPeriods];
        [self.delegate timesheetUserController:self didUpdateHeight:height];
        return nil;
    } error:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
   WidgetTimesheetSummaryRepository *widgetTimesheetSummaryRepository = [self.injector getInstance:[WidgetTimesheetSummaryRepository class]];
    [widgetTimesheetSummaryRepository removeAllListeners];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.timesheetPeriods.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    TeamTimesheetsForTimePeriod *timesheetsForPeriod = [self timesheetsForSection:section];
    return timesheetsForPeriod.timesheets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GoldenTimesheetUsersCell *cell = [tableView dequeueReusableCellWithIdentifier:timesheetUsersCellReuseIdentifier forIndexPath:indexPath];

    cell.userNameLabel.font = [self.theme timesheetUserNameFont];
    cell.workHoursLabel.font = [self.theme timesheetUserWorkHoursFont];
    cell.breakHoursLabel.font = [self.theme timesheetUserBreakHoursFont];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.timesheetPeriods.count < 2) {
        return 0.0f;
    }

    return 35.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [tableView dequeueReusableHeaderFooterViewWithIdentifier:timesheetSectionHeaderReuseIdentifier];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(TimesheetUsersSectionHeaderView *)headerView forSection:(NSInteger)section
{
    TeamTimesheetsForTimePeriod *timesheetForTimePeriod = self.timesheetPeriods[section];
    headerView.sectionTitleLabel.text = [self.sectionHeaderViewPresenter labelForSectionHeaderWithTimesheet:timesheetForTimePeriod];
    headerView.sectionTitleLabel.font = [self.sectionHeaderViewPresenter fontForSectionHeader];
    headerView.sectionTitleLabel.textColor = [self.sectionHeaderViewPresenter fontColorForSectionHeader];

    headerView.topSeparatorView.backgroundColor = [self.theme defaultTableViewSeparatorColor];
    headerView.bottomSeparatorView.backgroundColor = [self.theme defaultTableViewSeparatorColor];
    CGRect frame = headerView.topSeparatorView.bounds;
    frame.size.height = 0.5;
    headerView.topSeparatorView.frame = frame;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimesheetForUserWithWorkHours *timesheetForUserWithWorkHours = [self timesheetUserForIndexPath:indexPath];
    TimesheetContainerController *timesheetContainerController = [self.injector getInstance:[TimesheetContainerController class]];
    [timesheetContainerController setupWithTimesheet:timesheetForUserWithWorkHours];

    [self.navigationController pushViewController:timesheetContainerController animated:YES];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self.delegate timesheetUserController:self timesheetUserType:self.timesheetUserType selectedIndex:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(GoldenTimesheetUsersCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimesheetForUserWithWorkHours *timesheetUser = [self timesheetUserForIndexPath:indexPath];

    cell.userNameLabel.text = [self.cellPresenter userNameLabelTextWithTimesheetUser:timesheetUser];
    cell.workHoursLabel.text = [self.cellPresenter workHoursLabelTextWithTimesheetUser:timesheetUser];

    if (self.timesheetUserType == TimesheetUserTypeNongolden) {
        cell.warningImageContainerViewWidthConstraint.constant = 20.0f;
    }

    cell.breakHoursLabel.attributedText = [self.cellPresenter regularHoursLabelTextWithTimesheetUser:timesheetUser];
}

#pragma mark - Private

- (TeamTimesheetsForTimePeriod *)timesheetsForSection:(NSUInteger) section
{
    return self.timesheetPeriods[section];
}

- (TimesheetForUserWithWorkHours *)timesheetUserForIndexPath:(NSIndexPath *)indexPath
{
    TeamTimesheetsForTimePeriod *teamTimesheetsForTimePeriod = [self timesheetsForSection:indexPath.section];
    return teamTimesheetsForTimePeriod.timesheets[indexPath.row];
}

- (UITableViewHeaderFooterView *)headerViewForTable
{
    UITableViewHeaderFooterView *headerView = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, self.timesheetTableview.frame.size.width, 28)];
    
    NSOperatingSystemVersion iOS_8_1 = (NSOperatingSystemVersion){8, 1, 0};
    
    if (![[NSProcessInfo processInfo] respondsToSelector:@selector(isOperatingSystemAtLeastVersion:)]
        || [[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:iOS_8_1]) {
        headerView.textLabel.font = [self.theme timesheetUsersTableViewHeaderFont];
    }

    NSString *sectionHeaderTitle;
    if (self.timesheetUserType == TimesheetUserTypeGolden) {
        sectionHeaderTitle = RPLocalizedString(@"Without Violations or Overtime", @"Without Violations or Overtime");
    } else {
        sectionHeaderTitle = RPLocalizedString(@"With Violations or Overtime", @"With Violations or Overtime");
    }

    headerView.textLabel.text = sectionHeaderTitle;
    headerView.contentView.backgroundColor = [self.theme timesheetUsersTableViewHeaderColor];

    return headerView;
}

@end
