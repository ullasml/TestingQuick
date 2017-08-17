#import "ListOfTimeSheetsCustomCell.h"
#import "ApprovalStatusPresenter.h"
#import "DefaultTheme.h"
#import "Util.h"
#import "Constants.h"

#define hours_details_hexcolor_code @"#999999"
#define time_details_hexcolor_code @"#000000"

@implementation ListOfTimeSheetsCustomCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleGray];
    }

    return self;
}

-(void)createCellLayoutWithParams:(NSString *)upperleftString
               upperlefttextcolor:(UIColor *)_lefttextcolor
                    upperrightstr:(NSString *)upperrightString
              upperRighttextcolor:(UIColor *)_righttextcolor
                      overTimeStr:(NSString *)overTimeString
                          mealStr:(NSString *)mealCount
                       timeOffStr:(NSString *)timeOffString
                       regularStr:(NSString *)regularString
                   approvalStatus:(NSString *)approvalStatus
                            width:(CGFloat)width
                      pendingSync:(BOOL)isPendingSync
{

    UIImageView *syncImageView;

    if (isPendingSync)
    {
        UIImage *syncImage = [Util thumbnailImage:@"sync-timesheet.png"];
        syncImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 19.5, syncImage.size.width,syncImage.size.height)];
        [syncImageView setImage:syncImage];
        [self.contentView bringSubviewToFront:syncImageView];
        [self.contentView addSubview:syncImageView];
    }




    //UPPER LEFT STRING LABEL

    UILabel *upperLeft = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 4.0, width-112, 20.0)];
    if (isPendingSync)
    {
        upperLeft.frame = CGRectMake(syncImageView.frame.origin.y+syncImageView.frame.size.width, 4.0, width-112-(syncImageView.frame.size.width), 20.0);
    }

    if (_lefttextcolor != nil)
    {
		[upperLeft setTextColor:_lefttextcolor];
	}
    else
    {
		[upperLeft setTextColor:[Util colorWithHex:time_details_hexcolor_code alpha:1]];
	}
	[upperLeft setBackgroundColor:[UIColor clearColor]];
	[upperLeft setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_16]];
	[upperLeft setTextAlignment:NSTextAlignmentLeft];
	[upperLeft setText:upperleftString];
	[upperLeft setNumberOfLines:1];
	[self.contentView addSubview:upperLeft];


    //UPPER RIGHT STRING LABEL
    CGFloat rightPadding = 30;
    UILabel *upperRight = [[UILabel alloc] initWithFrame:CGRectMake(width-70-rightPadding, 4.0, 70, 20.0)];
    
	if (_righttextcolor != nil)
    {
		[upperRight setTextColor:_righttextcolor];
	}
    else
    {
		[upperRight setTextColor:[Util colorWithHex:time_details_hexcolor_code alpha:1]];
	}
	[upperRight setBackgroundColor:[UIColor clearColor]];
	[upperRight setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_17]];
	[upperRight setText:upperrightString];
	[upperRight setTextAlignment:NSTextAlignmentRight];
	[upperRight setNumberOfLines:1];
    [self.contentView addSubview:upperRight];

    // MEAL BREAK
    if (mealCount!=nil &&
        ![mealCount isKindOfClass:[NSNull class]] &&
        [mealCount newFloatValue]!=0 )
    {
        UIImage *mealImage=[Util thumbnailImage:Mealbreaks_Box];
        UIImageView *mealBreakImageView = [[UIImageView alloc] initWithFrame:CGRectMake(210,6.0, mealImage.size.width,mealImage.size.height)];
        [mealBreakImageView setImage:mealImage];
        [self.contentView addSubview:mealBreakImageView];



        UILabel *mealLabel = [[UILabel alloc] initWithFrame:CGRectMake(230.0, 4.0, 50.0, 20.0)];
        if (_lefttextcolor != nil)
        {
            [mealLabel setTextColor:_lefttextcolor];
        }
        else
        {
            [mealLabel setTextColor:[UIColor redColor]];
        }
        [mealLabel setBackgroundColor:[UIColor clearColor]];
        [mealLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
        [mealLabel setTextAlignment:NSTextAlignmentLeft];
        [mealLabel setText:mealCount];
        [mealLabel setNumberOfLines:1];
        [self.contentView addSubview:mealLabel];
    }


    NSString *strHours = [self createRightLowerWithOverTimestr:overTimeString timeOffStr:timeOffString regularStr:regularString];

    CGFloat strHourswidth = [self widthOfString:strHours withFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];

    UILabel *rightLowerLbl =[[UILabel alloc] initWithFrame:CGRectMake(width-rightPadding-strHourswidth, 28, strHourswidth, 20)];
    [rightLowerLbl setTextColor:[Util colorWithHex:hours_details_hexcolor_code alpha:1]];
    [rightLowerLbl setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
    [rightLowerLbl setText:strHours];
    [rightLowerLbl setTextAlignment:NSTextAlignmentRight];
    [rightLowerLbl setNumberOfLines:1];
    [rightLowerLbl setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:rightLowerLbl];

    UILabel *statusLbl=[[UILabel alloc]initWithFrame:CGRectMake(10.0f, 28.0f,SCREEN_WIDTH-(42.0+strHourswidth), 20.0f)];
    if (isPendingSync)
    {
        statusLbl.frame = CGRectMake(syncImageView.frame.origin.y+syncImageView.frame.size.width, 28.0f, CGRectGetWidth(self.bounds)-(52.0+strHourswidth+syncImageView.frame.size.width), 20.0f);
    }
    [statusLbl setTextAlignment:NSTextAlignmentLeft];
    [statusLbl setBackgroundColor:[UIColor clearColor]];
    [statusLbl setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:12.0]];
    statusLbl.text = RPLocalizedString(approvalStatus, @"");



    id<Theme> theme = [[DefaultTheme alloc] init];
    ApprovalStatusPresenter *approvalStatusPresenter = [[ApprovalStatusPresenter alloc] initWithTheme:theme];
    [statusLbl setTextColor:[approvalStatusPresenter colorForStatus:approvalStatus]];

    [self.contentView addSubview:statusLbl];


    //LOWER IMAGE VIEW
    UIImage *lowerImage = [Util thumbnailImage:Cell_HairLine_Image];
	UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 56, width,lowerImage.size.height)];
    [lineImageView setImage:lowerImage];
    [self.contentView bringSubviewToFront:lineImageView];
	[self.contentView addSubview:lineImageView];


    //DISCLOSURE IMAGE VIEW

    UIImage *disclosureImage = [UIImage imageNamed:Disclosure_Box];
    UIImageView *disclosureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(width-21, 22, disclosureImage.size.width, disclosureImage.size.height)];
	[disclosureImageView setImage:disclosureImage];
	[self.contentView addSubview:disclosureImageView];


}

-(NSString *)createRightLowerWithOverTimestr:(NSString *)overTimeString timeOffStr:(NSString *)timeOffString regularStr:(NSString *)regularString
{


    NSString *strHours=@"";


    if (timeOffString!=nil &&
        ![timeOffString isKindOfClass:[NSNull class]] &&
        [timeOffString newFloatValue]!=0 )
    {

            strHours=[NSString stringWithFormat:@"%@ %@",RPLocalizedString(@"TO", @""),timeOffString];


    }



    if (overTimeString!=nil &&
        ![overTimeString isKindOfClass:[NSNull class]] &&
        [overTimeString newFloatValue]!=0 )
    {

        if (![strHours isEqualToString:@""])
        {
            strHours=[NSString stringWithFormat:@"%@, %@ %@",strHours,RPLocalizedString(@"OT", @""),overTimeString];
        }
        else
        {
            strHours=[NSString stringWithFormat:@"%@ %@",RPLocalizedString(@"OT", @""),overTimeString];
        }


    }



    if (regularString!=nil &&
        ![regularString isKindOfClass:[NSNull class]] &&
        [regularString newFloatValue]!=0 )
    {
        if (![strHours isEqualToString:@""])
        {
            strHours=[NSString stringWithFormat:@"%@, %@ %@",strHours,RPLocalizedString(@"Reg", @""),regularString];
        }
        else
        {
            strHours=[NSString stringWithFormat:@"%@ %@",RPLocalizedString(@"Reg", @""),regularString];
        }

    }


    return strHours;
}

- (CGFloat)widthOfString:(NSString *)string withFont:(UIFont *)font
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}


@end
