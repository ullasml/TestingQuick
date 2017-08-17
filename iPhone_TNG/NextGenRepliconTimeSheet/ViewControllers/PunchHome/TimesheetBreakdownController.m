#import <Foundation/Foundation.h>
#import "TimesheetBreakdownController.h"
#import "TimePeriodSummary.h"
#import "DayTimeSummaryCell.h"
#import "DayTimeSummary.h"
#import "DayTimeSummaryCellPresenter.h"
#import "Theme.h"
#import "WorkHoursDeferred.h"
#import "TimePeriodSummaryDeferred.h"
#import "TimesheetDaySummary.h"


@interface TimesheetBreakdownController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) DayTimeSummaryCellPresenter *dayTimeSummaryCellPresenter;
@property (nonatomic) NSArray *dayTimeSummaries;
@property (nonatomic) id<Theme> theme;
@property (nonatomic, weak) id<TimesheetBreakdownControllerDelegate> delegate;

@end


@implementation TimesheetBreakdownController

- (instancetype)initWithDayTimeSummaryCellPresenter:(DayTimeSummaryCellPresenter *)dayTimeSummaryCellPresenter
                                              theme:(id<Theme>)theme {
    self = [super init];
    if (self) {
        self.dayTimeSummaryCellPresenter = dayTimeSummaryCellPresenter;
        self.theme = theme;
    }
    return self;
}

- (void)setupWithDayTimeSummaries:(NSArray *)dayTimeSummaries
                         delegate:(id <TimesheetBreakdownControllerDelegate>)delegate
{
    self.dayTimeSummaries = dayTimeSummaries;
    self.delegate = delegate;
}

#pragma mark - NSObject

- (instancetype)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.backgroundColor = [self.theme timesheetBreakdownBackgroundColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.separatorStyle = self.delegate ? UITableViewCellSeparatorStyleSingleLine : UITableViewCellSeparatorStyleNone;
    [self.tableView setAccessibilityIdentifier:@"uia_timesheet_breakdown_table_identifier"];

    NSString *cellClassName = NSStringFromClass([DayTimeSummaryCell class]);
    [self.tableView registerNib:[UINib nibWithNibName:cellClassName bundle:nil] forCellReuseIdentifier:cellClassName];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGFloat newHeight = self.dayTimeSummaries.count * self.tableView.rowHeight;
    [self.delegate timeSheetBreakdownController:self didUpdateHeight:newHeight];

}

- (void)updateWithDayTimeSummaries:(NSArray *)dayTimeSummaries
{
    self.dayTimeSummaries = dayTimeSummaries;
    [self.tableView reloadData];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dayTimeSummaries.count;
}

- (DayTimeSummaryCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TimesheetDaySummary *dayTimeSummary = self.dayTimeSummaries[indexPath.row];
    DayTimeSummaryCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DayTimeSummaryCell class])];
    cell.backgroundColor = [self.theme timesheetBreakdownBackgroundColor];
    cell.separator.backgroundColor = [self.theme timesheetBreakdownSeparatorColor];

    if (self.delegate)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    cell.dateLabel.attributedText = [self.dayTimeSummaryCellPresenter dateStringForDayTimeSummary:dayTimeSummary];
    cell.regularTimeLabel.attributedText = [self.dayTimeSummaryCellPresenter regularTimeStringForDayTimeSummary:dayTimeSummary];
    cell.breakTimeLabel.attributedText = [self.dayTimeSummaryCellPresenter breakTimeStringForDayTimeSummary:dayTimeSummary];
    
    NSDateComponents *timeoffComponents = dayTimeSummary.timeOffComponents;
    if (timeoffComponents.hour != 0 ||  timeoffComponents.minute != 0 || timeoffComponents.second != 0)
    {
        cell.timeOffTimeLabel.attributedText = [self.dayTimeSummaryCellPresenter timeOffTimeStringForDayTimeSummary:dayTimeSummary];
    }
    else
    {
        [cell.timeOffTimeLabel setHidden:YES];
        [cell.separator setHidden:YES];
    }
    
    NSInteger issueCount = dayTimeSummary.totalViolationMessageCount;
    if (issueCount > 0)
    {
        cell.violationImage.image = [UIImage imageNamed:@"violation-active-day"];
        cell.issueCount.textColor = [self.theme timesheetBreakdownViolationCountColor];
        cell.issueCount.text = [NSString stringWithFormat:@"%ld", (long)issueCount];;
        cell.issueCount.highlightedTextColor = [self.theme timesheetBreakdownViolationCountColor];
        cell.issueCount.font = [self.theme timesheetBreakdownViolationCountFont];
        cell.violationImage.highlightedImage = [UIImage imageNamed:@"violation-active-day"];
    }
    else
    {
        [cell.violationImage removeFromSuperview];
        [cell.issueCount removeFromSuperview];
    }
    
    if (!dayTimeSummary.isScheduledDay)
    {
        cell.dateLabel.alpha = 0.55;
        cell.breakTimeLabel.alpha = 0.55;
        cell.timeOffTimeLabel.alpha = 0.55;
        cell.regularTimeLabel.alpha = 0.55;
    }
    
    return cell;
}

-(BOOL)isTimeOffPresent:(NSDateComponents*)dateComponents
{
    return (dateComponents.hour != 0 ||  dateComponents.minute != 0 || dateComponents.second != 0);
}


#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DayTimeSummary *dayTimeSummary = self.dayTimeSummaries[indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDate *date = [self.dayTimeSummaryCellPresenter dateForDayTimeSummary:dayTimeSummary];
    [self.delegate timeSheetBreakdownController:self
                           didSelectDayWithDate:date
                               dayTimeSummaries:self.dayTimeSummaries
                                      indexPath:indexPath];
}

#pragma mark - NSObject

-(void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

@end
