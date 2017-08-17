#import "ViolationsSummaryController.h"
#import <KSDeferred/KSPromise.h>
#import "SupervisorDashboardSummary.h"
#import "ViolationEmployee.h"
#import "Violation.h"
#import "TeamTableStylist.h"
#import "TeamSectionHeaderView.h"
#import "ViolationNoSelfieCell.h"
#import "ViolationSeverityPresenter.h"
#import <Blindside/Blindside.h>
#import "Theme.h"
#import "WaiverOption.h"
#import "Waiver.h"
#import "SelectedWaiverOptionPresenter.h"
#import "SupervisorDashboardSummaryRepository.h"
#import "SpinnerDelegate.h"
#import "AllViolationSections.h"
#import "ViolationSection.h"
#import "ViolationSectionHeaderPresenter.h"


@interface ViolationsSummaryController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewWidthConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) SupervisorDashboardSummaryRepository *supervisorDashboardSummaryRepository;
@property (nonatomic) ViolationSectionHeaderPresenter *violationSectionHeaderPresenter;
@property (nonatomic) SelectedWaiverOptionPresenter *selectedWaiverOptionPresenter;
@property (nonatomic) ViolationSeverityPresenter *violationSeverityPresenter;
@property (nonatomic) KSPromise *violationSectionsPromise;
@property (nonatomic, weak) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic) AllViolationSections *allViolationSections;
@property (nonatomic) TeamTableStylist *stylist;
@property (nonatomic) id<Theme> theme;

@property (nonatomic, weak) id<ViolationsSummaryControllerDelegate> delegate;
@property (nonatomic, weak) id<BSInjector> injector;

@end


static NSString *const VIOLATION_CELL_IDENTIFIER = @"cell";
static CGFloat const HEADER_HEIGHT = 44.0f;


@implementation ViolationsSummaryController

- (instancetype)initWithSupervisorDashboardSummaryRepository:(SupervisorDashboardSummaryRepository *)supervisorDashboardSummaryRepository
                             violationSectionHeaderPresenter:(ViolationSectionHeaderPresenter *)violationSectionHeaderPresenter
                               selectedWaiverOptionPresenter:(SelectedWaiverOptionPresenter *)selectedWaiverOptionPresenter
                                  violationSeverityPresenter:(ViolationSeverityPresenter *)violationSeverityPresenter
                                            teamTableStylist:(TeamTableStylist *)teamTableStylist
                                             spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                                                       theme:(id <Theme>)theme
{
    self = [super init];
    if (self) {
        self.supervisorDashboardSummaryRepository = supervisorDashboardSummaryRepository;
        self.violationSectionHeaderPresenter = violationSectionHeaderPresenter;
        self.selectedWaiverOptionPresenter = selectedWaiverOptionPresenter;
        self.violationSeverityPresenter = violationSeverityPresenter;
        self.spinnerDelegate = spinnerDelegate;
        self.stylist = teamTableStylist;
        self.theme = theme;
    }
    return self;
}

- (void)setupWithViolationSectionsPromise:(KSPromise *)violationSectionsPromise
                                 delegate:(id<ViolationsSummaryControllerDelegate>)delegate
{
    self.violationSectionsPromise = violationSectionsPromise;
    self.delegate = delegate;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = RPLocalizedString(@"Violations", @"Violations");
    UINib *cellNib = [UINib nibWithNibName:@"ViolationNoSelfieCell" bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:VIOLATION_CELL_IDENTIFIER];
    self.tableView.estimatedRowHeight = 50;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.sectionHeaderHeight = HEADER_HEIGHT;
    [self.tableView setAccessibilityIdentifier:@"uia_violations_table_identifier"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:NO animated:animated];

    self.tableViewWidthConstraint.constant = CGRectGetWidth(self.view.bounds);

    [self.violationSectionsPromise then:^id(AllViolationSections *violationSections) {
        self.allViolationSections = violationSections;
        [self.tableView reloadData];

        return nil;
    } error:nil];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.allViolationSections.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ViolationSection *violationSection = self.allViolationSections.sections[section];

    return violationSection.violations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ViolationSection *violationSection = self.allViolationSections.sections[indexPath.section];
    Violation *violation = violationSection.violations[indexPath.row];

    ViolationNoSelfieCell *cell = [tableView dequeueReusableCellWithIdentifier:VIOLATION_CELL_IDENTIFIER forIndexPath:indexPath];
    cell.titleLabel.font = [self.theme violationsCellTitleFont];
    cell.titleLabel.textColor = [self.theme violationsCellTitleTextColor];
    [cell.titleLabel setAccessibilityIdentifier:@"uia_violation_title_label"];
    cell.titleLabel.text = [violation title];
    cell.titleLabel.numberOfLines = 0;

    cell.severityImageView.image = [self.violationSeverityPresenter severityImageWithViolationSeverity:violation.severity];

    cell.timeAndStatusLabel.font = [self.theme violationsCellTimeAndStatusFont];
    cell.timeAndStatusLabel.textColor = [self.theme violationsCellTimeAndStatusTextColor];
    [cell.timeAndStatusLabel setAccessibilityIdentifier:@"uia_violation_status_label"];
    NSString *displayText = [self.selectedWaiverOptionPresenter displayTextFromSelectedWaiverOption:violation.waiver.selectedOption];
    cell.timeAndStatusLabel.text = violation.waiver ? displayText : nil;

    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }

    cell.selectionStyle = violation.waiver ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;
    cell.accessoryType = violation.waiver ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;

    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TeamSectionHeaderView *teamSectionHeaderView = [[TeamSectionHeaderView alloc] init];
    ViolationSection *violationSection = self.allViolationSections.sections[section];
    teamSectionHeaderView.sectionTitleLabel.text = [self.violationSectionHeaderPresenter sectionHeaderTextWithViolationSection:violationSection];
    [self.stylist applyThemeToSectionHeaderView:teamSectionHeaderView];

    return teamSectionHeaderView;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ViolationSection *violationSection  = self.allViolationSections.sections[indexPath.section];
    Violation *violation = violationSection.violations[indexPath.row];

    if (violation.waiver)
    {
        WaiverController *waiverController = [self.injector getInstance:[WaiverController class]];
        NSString *sectionTitle = [self.violationSectionHeaderPresenter sectionHeaderTextWithViolationSection:violationSection];

        [waiverController setupWithSectionTitle:sectionTitle
                                      violation:violation
                                       delegate:self];

        [self.navigationController pushViewController:waiverController animated:YES];
    }
}

#pragma mark - <WaiverControllerDelegate>

- (void)waiverController:(WaiverController *)waiverController didSelectWaiverOption:(WaiverOption *)waiverOption forWaiver:(Waiver *)waiver
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.spinnerDelegate showTransparentLoadingOverlay];

    self.allViolationSections = [[AllViolationSections alloc] initWithTotalViolationsCount:0 sections:@[]];
    [self.tableView reloadData];

    self.violationSectionsPromise = [self.delegate violationsSummaryControllerDidRequestViolationSectionsPromise:self];
    [self.violationSectionsPromise then:^id(AllViolationSections *violationSections) {
        [self.spinnerDelegate hideTransparentLoadingOverlay];
        self.allViolationSections = violationSections;
        [self.tableView reloadData];
        if([self.delegate conformsToProtocol:@protocol(ViolationsSummaryControllerDelegate)] && [self.delegate respondsToSelector:@selector(violationsSummaryControllerDidRequestToUpdateUI:)])
        {
            [self.delegate violationsSummaryControllerDidRequestToUpdateUI:self];
        }
        return nil;
    } error:^id(NSError *error) {
        [self.spinnerDelegate hideTransparentLoadingOverlay];
        if([self.delegate conformsToProtocol:@protocol(ViolationsSummaryControllerDelegate)] && [self.delegate respondsToSelector:@selector(violationsSummaryControllerDidRequestToUpdateUI:)])
        {
            [self.delegate violationsSummaryControllerDidRequestToUpdateUI:self];
        }
        return nil;
    }];
}


#pragma mark - NSObject

-(void)dealloc
{
    self.tableView.delegate = nil ;
    self.tableView.dataSource = nil;
}
@end
