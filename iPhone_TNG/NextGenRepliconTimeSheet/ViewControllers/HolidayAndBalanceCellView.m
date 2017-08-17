#import "HolidayAndBalanceCellView.h"
#import "Constants.h"


@interface HolidayAndBalanceCellView ()

@property(nonatomic,strong)UILabel *timeOffType;
@property(nonatomic,strong)UILabel *timeOffTypeValue;

@end


@implementation HolidayAndBalanceCellView

-(void)timeOffBalanceAndHoliday:(NSString *)timeOfftype totalHrs:(NSString *)timestr
{
    UIFont *valueFont = [UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_16];
    CGFloat valueWidth = [self widthOfString:timestr withFont:valueFont] + 20;
    if (self.timeOffTypeValue==nil) {
        UILabel *temptimeOffTypeValue = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-valueWidth-12, 8.0, valueWidth ,30.0)];
        self.timeOffTypeValue=temptimeOffTypeValue;
        
    }
    
    if (self.timeOffType == nil) {
        self.timeOffType = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 8.0, self.timeOffTypeValue.frame.origin.x - 22, 30.0)];
    }
    
    [self.timeOffType setTextColor:RepliconStandardBlackColor];
    [self.timeOffType setFont:valueFont];
    [self.timeOffType setText:timeOfftype];
    [self.contentView addSubview:self.timeOffType];
    
    [self.timeOffTypeValue setTextColor:RepliconStandardBlackColor];
    [self.timeOffTypeValue setFont:valueFont];
    [self.timeOffTypeValue setTextAlignment:NSTextAlignmentRight];
    [self.timeOffTypeValue setText:timestr];
    [self.contentView addSubview:self.timeOffTypeValue];
    
    //LOWER IMAGE VIEW
    UIImage *lowerImage = [Util thumbnailImage:Cell_HairLine_Image];
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 43, SCREEN_WIDTH, lowerImage.size.height)];
    [lineImageView setImage:lowerImage];
    [self.contentView addSubview:lineImageView];
}

- (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [string sizeWithAttributes:attributes].width;
}

@end
