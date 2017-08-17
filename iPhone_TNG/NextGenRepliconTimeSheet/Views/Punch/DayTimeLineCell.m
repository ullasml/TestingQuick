
#import "DayTimeLineCell.h"

@interface DayTimeLineCell ()

@property (weak, nonatomic) IBOutlet UILabel *punchActualTime;
@property (weak, nonatomic) IBOutlet UILabel *punchServerTime;
@property (weak, nonatomic) IBOutlet UILabel *timeZone;
@property (weak, nonatomic) IBOutlet UILabel *punchType;
@property (weak, nonatomic) IBOutlet UILabel *duration;
@property (weak, nonatomic) IBOutlet UILabel *agentType;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *violationDetais;
@property (weak, nonatomic) IBOutlet UILabel *auditHistory;
@property (weak, nonatomic) IBOutlet UILabel *metaDataLabel;

@property (weak, nonatomic) IBOutlet UIImageView *descendingLineView;
@property (weak, nonatomic) IBOutlet UIView *cellSeparatorView;

@property (weak, nonatomic) IBOutlet UIImageView *punchUserImageView;
@property (weak, nonatomic) IBOutlet UIImageView *platformImageView;
@property (weak, nonatomic) IBOutlet UIImageView *locationImageView;
@property (weak, nonatomic) IBOutlet UIImageView *violationImageView;
@property (weak, nonatomic) IBOutlet UIImageView *auditHistoryImageView;
@property (weak, nonatomic) IBOutlet UIImageView *punchTypeImageView;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *punchTypeToMetaDataSpacerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *metaDataToViolationsSpacerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *violationsToAgentTypeSpacerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *punchLabelHeight;



@end

@implementation DayTimeLineCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
