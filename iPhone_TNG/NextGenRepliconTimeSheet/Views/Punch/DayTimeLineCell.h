

#import <UIKit/UIKit.h>

@interface DayTimeLineCell : UITableViewCell

@property (weak, nonatomic, readonly) UILabel *punchActualTime;
@property (weak, nonatomic, readonly) UILabel *punchServerTime;
@property (weak, nonatomic, readonly) UILabel *timeZone;
@property (weak, nonatomic, readonly) UILabel *punchType;
@property (weak, nonatomic, readonly) UILabel *duration;
@property (weak, nonatomic, readonly) UILabel *agentType;
@property (weak, nonatomic, readonly) UILabel *address;
@property (weak, nonatomic, readonly) UILabel *violationDetais;
@property (weak, nonatomic, readonly) UILabel *auditHistory;
@property (weak, nonatomic, readonly) UILabel *metaDataLabel;

@property (weak, nonatomic, readonly) UIImageView *descendingLineView;
@property (weak, nonatomic, readonly) UIView *cellSeparatorView;

@property (weak, nonatomic, readonly) UIImageView *punchUserImageView;
@property (weak, nonatomic, readonly) UIImageView *platformImageView;
@property (weak, nonatomic, readonly) UIImageView *locationImageView;
@property (weak, nonatomic, readonly) UIImageView *violationImageView;
@property (weak, nonatomic, readonly) UIImageView *auditHistoryImageView;
@property (weak, nonatomic, readonly) UIImageView *punchTypeImageView;

@property (weak, nonatomic, readonly) NSLayoutConstraint *punchLabelHeight;
@property (weak, nonatomic, readonly) NSLayoutConstraint *punchTypeToMetaDataSpacerHeight;
@property (weak, nonatomic, readonly) NSLayoutConstraint *metaDataToViolationsSpacerHeight;
@property (weak, nonatomic, readonly) NSLayoutConstraint *violationsToAgentTypeSpacerHeight;


@end
