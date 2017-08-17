#import "TimesheetTablePresenter.h"
#import "TeamTimesheetsForTimePeriod.h"
#import "Timesheet.h"


@implementation TimesheetTablePresenter

- (CGFloat)heightForTableView:(UITableView *)tableView timesheetPeriods:(NSArray *)timesheetPeriods
{
    for (TeamTimesheetsForTimePeriod *period in timesheetPeriods) {
        for (__unused id<Timesheet> timesheet in period.timesheets) {
            CGFloat height = 0.0;
            NSUInteger sectionCount = [tableView numberOfSections];
            for (int i = 0; i < sectionCount; i++) {
                height += [tableView.delegate tableView:tableView heightForHeaderInSection:i];
                NSUInteger rowCount = [tableView numberOfRowsInSection:i];
                for (int j = 0; j < rowCount; j++) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
                    height += [tableView.delegate tableView:tableView heightForRowAtIndexPath:indexPath];
                }
            }
            height += CGRectGetHeight(tableView.tableHeaderView.bounds);
            return height;
        }
    }
    return 0.0f;
}

@end