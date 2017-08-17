#import <UIKit/UIKit.h>

@interface TimesheetUsersSectionHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic, readonly) UILabel *sectionTitleLabel;
@property (weak, nonatomic, readonly) UIView *topSeparatorView;
@property (weak, nonatomic, readonly) UIView *bottomSeparatorView;

@end
