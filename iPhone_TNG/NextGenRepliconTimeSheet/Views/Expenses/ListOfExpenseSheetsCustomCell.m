#import <CoreGraphics/CoreGraphics.h>
#import "ListOfExpenseSheetsCustomCell.h"
#import "Util.h"
#import "Constants.h"
#import "Theme.h"
#import "DefaultTheme.h"
#import "ApprovalStatusPresenter.h"
#import "UIView+Additions.h"

@implementation ListOfExpenseSheetsCustomCell

- (id)initWithStyle:(enum UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
              width:(CGFloat)width {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect frame = self.frame;
        frame.size.width = width;
        self.frame = frame;

        [self setSelectionStyle:UITableViewCellSelectionStyleGray];
    }
    
    return self;
}

-(void)createCellLayoutWithParams:(NSString *)upperleftString
                    upperrightstr:(NSString *)upperrightString
                    lowerrightStr:(NSString *)lowerrightStr
                   lowerleftImage:(UIImage *)lowerleftImage
                   approvalStatus:(NSString *)approvalStatus

{
    //UPPER LEFT STRING LABEL

    CGFloat frameWidth = CGRectGetWidth(self.frame);
    CGFloat labelPadding = 12.0;
    CGFloat labelWidth = (frameWidth-(3*labelPadding))/2;
    
    UILabel *upperLeft = [[UILabel alloc] initWithFrame:CGRectMake(labelPadding, 4.0, labelWidth, 20.0)];
   	[upperLeft setTextColor:RepliconStandardBlackColor ];
	[upperLeft setBackgroundColor:[UIColor clearColor]];
	[upperLeft setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_16]];
	[upperLeft setTextAlignment:NSTextAlignmentLeft];
	[upperLeft setText:upperleftString];
	[upperLeft setNumberOfLines:1];
	[self.contentView addSubview:upperLeft];

    //DISCLOSURE IMAGE VIEW
    
    UIImage *disclosureImage = [UIImage imageNamed:Disclosure_Box];
    UIImageView *disclosureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(frameWidth - 21.0, 22, disclosureImage.size.width, disclosureImage.size.height)];
    [disclosureImageView setImage:disclosureImage];
    [self.contentView addSubview:disclosureImageView];
    

    //UPPER RIGHT STRING LABEL

    UILabel *upperRight = [[UILabel alloc] initWithFrame:CGRectMake(upperLeft.right+labelPadding, 4.0, labelWidth-disclosureImage.size.width-labelPadding, 20.0)];
	[upperRight setTextColor:RepliconStandardBlackColor ];
	[upperRight setBackgroundColor:[UIColor clearColor]];
	[upperRight setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_15]];
	[upperRight setText:upperrightString];
	[upperRight setTextAlignment:NSTextAlignmentRight];
	[upperRight setNumberOfLines:1];
    [self.contentView addSubview:upperRight];
   

    //LOWER RIGHT STRING LABEL

    UILabel *lowerRight = [[UILabel alloc] initWithFrame:CGRectMake(upperRight.left, 28.0, labelWidth-disclosureImage.size.width-labelPadding, 20.0)];
	[lowerRight setTextColor:RepliconStandardGrayColor ];
	[lowerRight setBackgroundColor:[UIColor clearColor]];
	[lowerRight setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
	[lowerRight setText:lowerrightStr];
	[lowerRight setTextAlignment:NSTextAlignmentRight];
	[lowerRight setNumberOfLines:1];
    [self.contentView addSubview:lowerRight];


    //LOWER IMAGE VIEW

    UILabel *statusLbl=[[UILabel alloc]initWithFrame:CGRectMake(labelPadding, 28.0f, 0.0f, 0.0f)];
    [statusLbl setTextAlignment:NSTextAlignmentLeft];
    [statusLbl setBackgroundColor:[UIColor clearColor]];
    [statusLbl setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:12.0]];
    statusLbl.text = RPLocalizedString(approvalStatus, @"");
    [statusLbl sizeToFit];
    id<Theme> theme = [[DefaultTheme alloc] init];
    ApprovalStatusPresenter *approvalStatusPresenter = [[ApprovalStatusPresenter alloc] initWithTheme:theme];
    statusLbl.textColor = [approvalStatusPresenter colorForStatus:approvalStatus];
    [self.contentView addSubview:statusLbl];


    //CELL SEPARATOR IMAGE VIEW
    UIImage *lowerImage = [Util thumbnailImage:Cell_HairLine_Image];
	UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 56, frameWidth,lowerImage.size.height)];
    [lineImageView setImage:lowerImage];
    [self.contentView bringSubviewToFront:lineImageView];
	[self.contentView addSubview:lineImageView];
}


@end
