#import <UIKit/UIKit.h>


@class DayTimeSummary;
@class DayTimeSummaryCellPresenter;
@protocol Theme;
@protocol TimesheetBreakdownControllerDelegate;


@interface TimesheetBreakdownController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic, readonly) UITableView *tableView;
@property (nonatomic, readonly) NSArray *dayTimeSummaries;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithDayTimeSummaryCellPresenter:(DayTimeSummaryCellPresenter *)dayTimeSummaryCellPresenter
                                              theme:(id<Theme>)theme;

- (void)setupWithDayTimeSummaries:(NSArray *)dayTimeSummaries
                         delegate:(id <TimesheetBreakdownControllerDelegate>)delegate;

- (void)updateWithDayTimeSummaries:(NSArray *)dayTimeSummaries;

@end


@protocol TimesheetBreakdownControllerDelegate <NSObject>

- (void)timeSheetBreakdownController:(TimesheetBreakdownController *)timeSheetBreakdownController didSelectDayWithDate:(NSDate *)date dayTimeSummaries:(NSArray *)dayTimeSummaries indexPath:(NSIndexPath *)indexPath;
- (void)timeSheetBreakdownController:(TimesheetBreakdownController *)timeSheetBreakdownController didUpdateHeight:(CGFloat) height;

@end
