#import <UIKit/UIKit.h>


@interface DayTimeSummaryCell : UITableViewCell

@property (weak, nonatomic, readonly) UILabel *dateLabel;
@property (weak, nonatomic, readonly) UILabel *regularTimeLabel;
@property (weak, nonatomic, readonly) UILabel *breakTimeLabel;
@property (weak, nonatomic, readonly) UILabel *timeOffTimeLabel;
@property (weak, nonatomic, readonly) UIView *separator;
@property (weak, nonatomic, readonly) UILabel *issueCount;
@property (weak, nonatomic, readonly) UIImageView *violationImage;

@end
