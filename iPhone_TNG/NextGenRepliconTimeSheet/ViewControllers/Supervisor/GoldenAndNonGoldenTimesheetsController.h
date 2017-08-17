#import <UIKit/UIKit.h>
#import "Enum.h"

@protocol Theme;
@protocol TimesheetUserControllerDelegate;
@class KSPromise;
@class TimesheetUserCellPresenter;
@class TimesheetUsersSectionHeaderViewPresenter;
@class TopViewControllerNavigationItemHelper;
@class TimesheetTablePresenter;


@interface GoldenAndNonGoldenTimesheetsController : UIViewController

@property (nonatomic, weak, readonly) UITableView *timesheetTableview;

@property (nonatomic, readonly) id<Theme> theme;
@property (nonatomic, readonly) TimesheetUserCellPresenter *cellPresenter;
@property (nonatomic, readonly) TimesheetUsersSectionHeaderViewPresenter *sectionHeaderViewPresenter;
@property (nonatomic, readonly) TimesheetTablePresenter *timesheetTablePresenter;
@property (nonatomic, assign, readonly) TimesheetUserType timesheetUserType;
@property (nonatomic, readonly) TopViewControllerNavigationItemHelper *topViewControllerNavigationItemHelper;

@property (nonatomic, readonly) UIActivityIndicatorView *spinnerView;

@property (nonatomic, weak, readonly) id<TimesheetUserControllerDelegate> delegate;
@property (nonatomic, readonly) KSPromise *timesheetUsersPromise;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTimesheetUserTypeSectionHeaderPresenter:(TimesheetUsersSectionHeaderViewPresenter *)sectionHeaderViewPresenter
                                        timesheetTablePresenter:(TimesheetTablePresenter *)timesheetTablePresenter
                                              typesheetUserType:(TimesheetUserType)typesheetUserType
                                                  cellPresenter:(TimesheetUserCellPresenter *)cellPresenter
                                                          theme:(id<Theme>)theme;

- (void) setupWithTimesheetUsersPromise:(KSPromise *)timesheetUsersPromise
                               delegate:(id<TimesheetUserControllerDelegate>)delegate;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end


@protocol TimesheetUserControllerDelegate <NSObject>

- (void)timesheetUserController:(GoldenAndNonGoldenTimesheetsController *)timesheetUserController
               didUpdateHeight:(CGFloat)height;

- (void)timesheetUserController:(GoldenAndNonGoldenTimesheetsController *)timesheetUserController
              timesheetUserType:(TimesheetUserType)timesheetUserType selectedIndex:(NSIndexPath *)indexPath;

@end
