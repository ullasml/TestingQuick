#import <UIKit/UIKit.h>


@interface TimesheetTablePresenter : NSObject

- (CGFloat)heightForTableView:(UITableView *)tableView timesheetPeriods:(NSArray *)timesheetPeriods;

@end
