#import "TimeOffCellView.h"
#import "Constants.h"
#import "Util.h"
#import "ApprovalStatusPresenter.h"
#import "DefaultTheme.h"

#define timeOff_details_hexcolor_code @"#333333"
#define date_details_hexcolor_code @"#666666"
#define HORIZONTAL_PADDING 24.0f


@interface TimeOffCellView ()

@property(nonatomic) UILabel *timeOffTypelabel;
@property(nonatomic) UILabel *statusLabel;
@property(nonatomic) UILabel *datelabel;
@property(nonatomic) UILabel *numberOfHourslabel;
@property(nonatomic) id<Theme> theme;

@end


@implementation TimeOffCellView

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        self.theme = [[DefaultTheme alloc] init];

        self.timeOffTypelabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 8.0f, 180.0f, 20.0f)];
        [self.timeOffTypelabel setTextColor:[Util colorWithHex:timeOff_details_hexcolor_code alpha:1]];
        [self.timeOffTypelabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_16]];
        [self.timeOffTypelabel setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.timeOffTypelabel];

        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 28.0f, 0, 0)];
        self.statusLabel.textAlignment = NSTextAlignmentLeft;
        self.statusLabel.font = [UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_12];
        [self.contentView addSubview:self.statusLabel];

        self.numberOfHourslabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 110.0f - HORIZONTAL_PADDING, 6, 100, 22)];
        [self.numberOfHourslabel setTextColor:[Util colorWithHex:timeOff_details_hexcolor_code alpha:1]];
        [self.numberOfHourslabel setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_17]];
        [self.numberOfHourslabel setTextAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:self.numberOfHourslabel];

        self.datelabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 170.0f - HORIZONTAL_PADDING, 28, 160, 22)];
        self.datelabel.textColor = [self.theme timeOffDayRangeColor];
        self.datelabel.font = [UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12];
        [self.datelabel setTextAlignment:NSTextAlignmentRight];
        [self.contentView addSubview:self.datelabel];

        UIImage *disclosureImage = [UIImage imageNamed:Disclosure_Box];
        UIImageView *disclosureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - HORIZONTAL_PADDING, 22, disclosureImage.size.width,disclosureImage.size.height)];
        disclosureImageView.image = disclosureImage;
        [self.contentView addSubview:disclosureImageView];

        UIImage *lowerImage = [Util thumbnailImage:Cell_HairLine_Image];
        UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 56, SCREEN_WIDTH, lowerImage.size.height)];
        [lineImageView setImage:lowerImage];
        [self.contentView bringSubviewToFront:lineImageView];
        [self.contentView addSubview:lineImageView];
    }
    return self;
}

-(void)createCellLayoutForTimeOffView:(TimeOffObject *)timeOffObject
{
    NSString *timeOffType = [timeOffObject typeName];
    NSString *startDate=[Util convertPickerDateToStringShortStyle:[timeOffObject bookedStartDate]];
    NSString *endDate=[Util convertPickerDateToStringShortStyle:[timeOffObject bookedEndDate]];

    NSString *time=nil;

    NSString *date =nil;
    NSDateFormatter *temp = [[NSDateFormatter alloc] init];
    [temp setDateFormat:@"yyyy-MM-dd"];
    
    NSLocale *locale=[NSLocale currentLocale];
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [temp setTimeZone:timeZone];
    [temp setLocale:locale];
    
    NSDate *stDt = [temp dateFromString:[temp stringFromDate:[timeOffObject bookedStartDate]]];
    NSDate *endDt =  [temp dateFromString:[temp stringFromDate:[timeOffObject bookedEndDate]]];
    
    if ((stDt!=nil && endDt!=nil) && [stDt compare:endDt]==NSOrderedSame)
    {
        date=[Util convertPickerDateToStringShortStyle:timeOffObject.bookedStartDate];
    }
    else
        date =[NSString stringWithFormat:@"%@ - %@",startDate,endDate];

    if ([[timeOffObject timeOffDisplayFormatUri] isEqualToString:TIME_Off_DISPLAY_WORK_DAYS_FORMAT_URI]) {
        if (fabs([timeOffObject.totalTimeOffDays newDoubleValue]) != 1.00) {
            time=[NSString stringWithFormat:@"%@ %@",timeOffObject.totalTimeOffDays,RPLocalizedString(@"days", @"")];
        }
        else{
            time=[NSString stringWithFormat:@"%@ %@",timeOffObject.totalTimeOffDays,RPLocalizedString(@"day", @"")];
        }
    }
    else{
        if (fabs([timeOffObject.numberOfHours newDoubleValue]) != 1.00) {
            time=[NSString stringWithFormat:@"%@ %@",timeOffObject.numberOfHours,RPLocalizedString(@"hours", @"")];
        }
        else{
            time=[NSString stringWithFormat:@"%@ %@",timeOffObject.numberOfHours,RPLocalizedString(@"hour", @"")];
        }
    }
    
    

    [self.timeOffTypelabel setText:timeOffType];
    //[self.timeOffTypelabel sizeToFitWithAlignment];

    ApprovalStatusPresenter *statusPresenter = [[ApprovalStatusPresenter alloc] initWithTheme:self.theme];
    NSString *status = timeOffObject.approvalStatus;
    self.statusLabel.text = RPLocalizedString(status, @"");
    self.statusLabel.textColor = [statusPresenter colorForStatus:status];
    [self.statusLabel sizeToFitWithAlignment];

    [self.numberOfHourslabel setText:time];
    [self.numberOfHourslabel sizeToFitWithAlignment];

    CGRect timeOffTypelabelRect = self.timeOffTypelabel.frame;
    timeOffTypelabelRect.size.width = self.numberOfHourslabel.frame.origin.x-24;
    self.timeOffTypelabel.frame = timeOffTypelabelRect;

    [self.datelabel setText:date];
    [self.datelabel sizeToFitWithAlignment];
}

@end
