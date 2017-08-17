#import "TimeOffRequestedCellView.h"
#import "Constants.h"

#define LABEL_PADDING 12
#define LABEL_WIDTH (SCREEN_WIDTH - (2*LABEL_PADDING))

@implementation TimeOffRequestedCellView

-(void)createRequestedBalanceCellView:(NSString *)trackingOption :(NSString *)type :(NSString *)commentsStr :(NSString*)approvalStatus
{
    CGFloat cellWidth = SCREEN_WIDTH;

    if([type isEqualToString:@"Requested"])
    {
        if (self.requestedTitleLbl) {
            [self.requestedTitleLbl removeFromSuperview];
        }
        if (self.requestedValueLbl) {
            [self.requestedValueLbl removeFromSuperview];
        }
        if (self.balanceTitleLbl) {
            [self.balanceTitleLbl removeFromSuperview];
        }
        if (self.balanceValueLbl) {
            [self.balanceValueLbl removeFromSuperview];
        }
        self.requestedTitleLbl = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth - 225, 5, 100, 30)];
        self.requestedTitleLbl.text = RPLocalizedString(@"Requested:", @"");
        self.requestedTitleLbl.textAlignment = NSTextAlignmentRight;
        [self.requestedTitleLbl setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]];
        [self addSubview:self.requestedTitleLbl];

        self.requestedValueLbl = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth - 130, 5, 118, 30)];
        self.requestedValueLbl.textAlignment = NSTextAlignmentRight;
        self.requestedValueLbl.text = RPLocalizedString(@"Loading...", @"");
        [self.requestedValueLbl setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_17]];
        [self addSubview:self.requestedValueLbl];

        self.balanceTitleLbl = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth - 225, 35, 100, 30)];
        self.balanceTitleLbl.text = RPLocalizedString(@"Balance:", @"");
        self.balanceTitleLbl.textAlignment = NSTextAlignmentRight;
        [self.balanceTitleLbl setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]];
        [self addSubview:self.balanceTitleLbl];
        
        self.balanceValueLbl = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth - 130, 35, 118, 30)];
        self.balanceValueLbl.text = RPLocalizedString(@"Loading...", @"");
        [self.balanceValueLbl setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_17]];
        self.balanceValueLbl.textAlignment = NSTextAlignmentRight;
        [self addSubview:self.balanceValueLbl];
        
        if(![trackingOption isEqualToString:TIME_OFF_AVAILABLE_KEY] ||[approvalStatus isEqualToString:APPROVED_STATUS])
        {
            self.balanceValueLbl.hidden = YES;
            self.balanceTitleLbl.hidden = YES;
        }
    }
    
    else
    {
        if (self.requestedTitleLbl) {
            [self.requestedTitleLbl removeFromSuperview];
        }
        if (self.requestedValueLbl) {
            [self.requestedValueLbl removeFromSuperview];
        }
        if (self.balanceTitleLbl) {
            [self.balanceTitleLbl removeFromSuperview];
        }
        if (self.balanceValueLbl) {
            [self.balanceValueLbl removeFromSuperview];
        }
        self.requestedTitleLbl = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_PADDING, 2, LABEL_WIDTH, 30)];
        self.requestedTitleLbl.text = RPLocalizedString(@"Comments:", @"");
        self.requestedTitleLbl.textAlignment = NSTextAlignmentLeft;
        [self.requestedTitleLbl setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]];
        [self addSubview:self.requestedTitleLbl];

        CGFloat widthOFValuelabel=LABEL_WIDTH;
        self.requestedValueLbl = [[UILabel alloc] initWithFrame:CGRectMake(LABEL_PADDING, self.requestedTitleLbl.frame.origin.y+self.requestedTitleLbl.frame.size.height, widthOFValuelabel, 40)];
        self.requestedValueLbl.numberOfLines=0;
        [self.requestedValueLbl setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]];
        [self addSubview:self.requestedValueLbl];
        if (commentsStr!=nil && ![commentsStr isKindOfClass:[NSNull class]]&&![commentsStr isEqualToString:NULL_STRING]) {
            self.requestedValueLbl.text = commentsStr;
            CGRect frame = self.requestedValueLbl.frame;
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:commentsStr];
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
            [attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17]} range:NSMakeRange(0, attributedString.length)];
            CGSize expectedLabelSize = [attributedString boundingRectWithSize:CGSizeMake(widthOFValuelabel, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
            if (expectedLabelSize.width==0 && expectedLabelSize.height ==0)
            {
                expectedLabelSize=CGSizeMake(11.0, 18.0);
            }
            frame.size.height = expectedLabelSize.height+CGRectGetHeight(self.requestedTitleLbl.frame);
            if (frame.size.height>44)
            {
                self.requestedValueLbl.frame = frame;
            }
        }
        else
        {
            self.requestedValueLbl.text=@"";
        }
        
    }
    
}


@end
