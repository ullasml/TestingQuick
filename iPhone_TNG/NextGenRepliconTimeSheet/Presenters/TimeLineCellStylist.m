#import "TimeLineCellStylist.h"
#import "TimeLineCell.h"
#import "Theme.h"
#import "DayTimeLineCell.h"


@interface TimeLineCellStylist ()

@property (nonatomic) id <Theme> theme;

@end


@implementation TimeLineCellStylist

- (instancetype)initWithTheme:(id <Theme>)theme
{
    self = [super init];
    if (self) {
        self.theme = theme;
    }
    return self;
}

- (void)applyStyleToCell:(TimeLineCell *)timeLineCell
     hidesDescendingLine:(BOOL)hidesDescendingLine
{
    if (hidesDescendingLine)
    {
        timeLineCell.separatorInset = UIEdgeInsetsMake(0, 0, 0, CGRectGetWidth(timeLineCell.bounds));
    }
    else
    {
        timeLineCell.separatorInset = UIEdgeInsetsMake(0.0f, 114, 0.0f, 0.0f);
    }

    timeLineCell.timeLabel.font = [self.theme timeLineCellTimeLabelFont];
    timeLineCell.timeLabel.textColor = [self.theme newTimeLineCellTimeLabelTextColor];
    timeLineCell.ampmLabel.textColor = [self.theme newTimeLineCellTimeLabelTextColor];
    timeLineCell.descriptionLabel.backgroundColor = [self.theme transparentBackgroundColor];
    timeLineCell.ascendingLineView.backgroundColor = [self.theme timeLineCellVerticalLineColor];
    timeLineCell.descendingLineView.backgroundColor = [self.theme timeLineCellVerticalLineColor];
    timeLineCell.descendingLineView.hidden = hidesDescendingLine;
}

- (void)applyStyleToDayTimeLineCell:(DayTimeLineCell *)timeLineCell hidesDescendingLine:(BOOL)hidesDescendingLine
{
    timeLineCell.punchActualTime.font = [self.theme actualPunchTimeFont];
    timeLineCell.punchActualTime.textColor = [self.theme actualPunchTimeTextColor];
    timeLineCell.punchType.font = [self.theme timeLinePunchTypeTexFont];
    timeLineCell.punchType.textColor = [self.theme timeLinePunchTypeTextColor];
    timeLineCell.duration.font = [self.theme punchDurationFont];
    timeLineCell.duration.textColor = [self.theme punchDurationTextColor];
    timeLineCell.metaDataLabel.font = [self.theme timeLineMetadataFont];
    timeLineCell.metaDataLabel.textColor = [self.theme timeLineMetadataTextColor];
    timeLineCell.violationDetais.font = [self.theme timeLineMetadataFont];
    timeLineCell.violationDetais.textColor = [self.theme timeLineMetadataTextColor];
    timeLineCell.auditHistory.font = [self.theme timeLineMetadataFont];
    timeLineCell.auditHistory.textColor = [self.theme timeLineMetadataTextColor];
    timeLineCell.agentType.font = [self.theme timeLineMetadataFont];
    timeLineCell.agentType.textColor = [self.theme timeLineMetadataTextColor];
    timeLineCell.address.font = [self.theme timeLineMetadataFont];
    timeLineCell.address.textColor = [self.theme timeLineMetadataTextColor];
    timeLineCell.punchType.backgroundColor = [self.theme transparentBackgroundColor];
    timeLineCell.punchUserImageView.backgroundColor = [UIColor clearColor];
    timeLineCell.punchActualTime.backgroundColor = [UIColor clearColor];
    timeLineCell.punchType.backgroundColor = [UIColor clearColor];
    timeLineCell.duration.backgroundColor = [UIColor clearColor];
    timeLineCell.metaDataLabel.backgroundColor = [UIColor clearColor];
    timeLineCell.violationDetais.backgroundColor = [UIColor clearColor];
    timeLineCell.address.backgroundColor = [UIColor clearColor];
    timeLineCell.agentType.backgroundColor = [UIColor clearColor];
    timeLineCell.punchUserImageView.backgroundColor = [UIColor clearColor];
    timeLineCell.platformImageView.backgroundColor = [UIColor clearColor];
    timeLineCell.locationImageView.backgroundColor = [UIColor clearColor];
    timeLineCell.violationImageView.backgroundColor = [UIColor clearColor];
    timeLineCell.auditHistoryImageView.backgroundColor = [UIColor clearColor];
    timeLineCell.punchTypeImageView.backgroundColor = [UIColor clearColor];
}



@end
