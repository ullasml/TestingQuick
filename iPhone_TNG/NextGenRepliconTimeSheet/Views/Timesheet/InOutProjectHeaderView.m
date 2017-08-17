#import "InOutProjectHeaderView.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>
#import "Util.h"
#import "MultiDayInOutViewController.h"
#import "EntryCellDetails.h"
#import <CoreText/CoreText.h>


@implementation InOutProjectHeaderView

@synthesize upperLeft;
@synthesize middleLeft;
@synthesize lowerLeft;
@synthesize entryDetailsIconBtn;
@synthesize delegate;
@synthesize addCellsIconBtn;
@synthesize attributedString;
@synthesize addCellsIconIamgeView;

#define LABEL_WIDTH SCREEN_WIDTH-20

-(void)initialiseViewWithProjectName:(TimesheetEntryObject *)tsEntryObject isProjectAccess:(BOOL )isProjectAccess isClientAccess:(BOOL )isClientAccess isActivityAccess:(BOOL)isActivityAccess isBillingAccess:(BOOL)isBillingAccess dataDict:(NSMutableDictionary *)heightDict andTag:(NSInteger)tag
{

    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }

    if (entryDetailsIconBtn==nil)
    {
        self.entryDetailsIconBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    }
    [entryDetailsIconBtn setFrame:CGRectMake(0, 0, SCREEN_WIDTH,EachDayTimeEntry_Cell_Row_Height_55)];
    [entryDetailsIconBtn setBackgroundColor:[UIColor clearColor]];
    [entryDetailsIconBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -300)];
    [entryDetailsIconBtn addTarget:self action:@selector(projectEditButtonIconClicked:) forControlEvents:UIControlEventTouchUpInside];
    [entryDetailsIconBtn setTag:tag];
    [self.contentView addSubview:entryDetailsIconBtn];
    [self.contentView bringSubviewToFront:entryDetailsIconBtn];

    BOOL isSingleLine=NO;
    BOOL isTwoLine=NO;
    BOOL isThreeLine=NO;
    NSString *line=[heightDict objectForKey:LINE];

    NSString *billingRate =[heightDict objectForKey:BILLING_RATE];
    NSString *upperStr=[heightDict objectForKey:UPPER_LABEL_STRING];
    NSString *middleStr=[heightDict objectForKey:MIDDLE_LABEL_STRING];
    NSString *lowerStr=[heightDict objectForKey:LOWER_LABEL_STRING];

    float upperLblHeight = ceilf([[heightDict objectForKey:UPPER_LABEL_HEIGHT] newFloatValue]);
    float middleLblHeight = ceilf([[heightDict objectForKey:MIDDLE_LABEL_HEIGHT] newFloatValue]);
    float lowerLblHeight = ceilf([[heightDict objectForKey:LOWER_LABEL_HEIGHT] newFloatValue]);
    float height=[[heightDict objectForKey:CELL_HEIGHT_KEY] newFloatValue];

    BOOL isMiddleLabelTextWrap=[[heightDict objectForKey:MIDDLE_LABEL_TEXT_WRAP] boolValue];

    if ([line isEqualToString:@"SINGLE"])
    {
        isSingleLine=YES;
    }
    else if ([line isEqualToString:@"DOUBLE"])
    {
        isTwoLine=YES;
    }
    else if ([line isEqualToString:@"TRIPLE"])
    {
        isThreeLine=YES;
    }


    if (isSingleLine)
    {

        if (middleLeft==nil)
        {
            UILabel *middleLabel = [[UILabel alloc] init];
            self.middleLeft=middleLabel;
        }
        self.middleLeft.frame=CGRectMake(10.0, 10.0, LABEL_WIDTH, middleLblHeight);
        [self.middleLeft setHighlightedTextColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.middleLeft];
        [self.middleLeft setText:middleStr];
        BOOL isBreakPresent=NO;
        NSString *breakUri=[tsEntryObject breakUri];
        if (breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]] && ![breakUri isEqualToString:@""])
        {
            isBreakPresent=YES;
        }
        if ([tsEntryObject isTimeoffSickRowPresent]||isBreakPresent)
        {
            if (isBreakPresent)
            {
                UIImage *breakImage = [UIImage imageNamed:@"icon_break_small"];
                UIImageView *breakImageView = [[UIImageView alloc] initWithImage:breakImage];
                breakImageView.frame = CGRectMake(10, (height-breakImage.size.height)/2, breakImage.size.width, breakImage.size.height);
                [self.contentView addSubview:breakImageView];

                self.middleLeft.frame=CGRectMake(breakImageView.frame.origin.x+breakImage.size.width+10, 15.0, LABEL_WIDTH-30, middleLblHeight);
            }
            [self.middleLeft setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];
            [self.middleLeft setNumberOfLines:100];
        }
        else
        {
            [self.middleLeft setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
            self.middleLeft.frame=CGRectMake(10.0,5.0, LABEL_WIDTH, EachDayTimeEntry_Cell_Row_Height_44);
            if (isMiddleLabelTextWrap)
            {
                [self.middleLeft setNumberOfLines:1];

                if (isBillingAccess)
                {
                    NSMutableAttributedString *tmpattributedString = [[NSMutableAttributedString alloc]  initWithString:middleStr];
                    NSString *string = @"";
                    if ([lowerStr isEqualToString:BILLABLE])
                    {
                        string = BILLABLE;
                    }
                    else
                    {
                        string = NON_BILLABLE;
                    }

                    if ([string length]==[middleStr length])
                    {

                    }
                    else
                    {
                        string = [NSString stringWithFormat:@" %@",NON_BILLABLE];
                    }

                    if ([middleStr rangeOfString:NON_BILLABLE].location != NSNotFound)
                    {
                        [tmpattributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,[string length])];
                    }

                    [self.middleLeft setAttributedText:tmpattributedString];
                }
            }
            else
            {
                [self.middleLeft setNumberOfLines:100];
            }
        }
    }
    else if (isTwoLine)
    {


        BOOL isTaskPresent=YES;
        NSString *timeEntryTaskName=[tsEntryObject timeEntryTaskName];
        if (timeEntryTaskName==nil || [timeEntryTaskName isKindOfClass:[NSNull class]]||[timeEntryTaskName isEqualToString:@""])
        {
            isTaskPresent=NO;
        }

        if (upperLeft==nil)
        {
            UILabel *upperLabel = [[UILabel alloc] init];
            self.upperLeft=upperLabel;
        }
        self.upperLeft.frame=CGRectMake(10, 10, LABEL_WIDTH, upperLblHeight);

        if (isTaskPresent)
        {
            [self.upperLeft setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];
        }
        else
        {
            [self.upperLeft setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
        }

        [self.upperLeft setText:upperStr];
        [self.upperLeft setNumberOfLines:100];
        [self.upperLeft setHighlightedTextColor:[UIColor whiteColor]];
        [self.contentView addSubview:upperLeft];

        float yLower=self.upperLeft.frame.origin.y+self.upperLeft.frame.size.height+5;
        if (lowerLeft==nil)
        {
            UILabel *lowerLabel = [[UILabel alloc] init];
            self.lowerLeft=lowerLabel;
        }
        self.lowerLeft.frame=CGRectMake(10.0, yLower, LABEL_WIDTH, lowerLblHeight);
        [self.lowerLeft setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
        [self.lowerLeft setText:billingRate];
        [self.lowerLeft setNumberOfLines:1];
        [self.lowerLeft setHighlightedTextColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.lowerLeft];
        
        float activityPositionValue = self.lowerLeft.frame.origin.y + self.lowerLeft.frame.size.height+3;
        UILabel *activityOEFLabel = [[UILabel alloc] init];
        activityOEFLabel.frame=CGRectMake(10.0, activityPositionValue, LABEL_WIDTH, lowerLblHeight);
        [activityOEFLabel setTextColor:[UIColor blackColor]];
        [activityOEFLabel setBackgroundColor:[UIColor clearColor]];
        [activityOEFLabel setTextAlignment:NSTextAlignmentLeft];
        [activityOEFLabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
        [activityOEFLabel setText:lowerStr];
        [activityOEFLabel setNumberOfLines:1];
        [activityOEFLabel setHighlightedTextColor:[UIColor whiteColor]];
        [self.contentView addSubview:activityOEFLabel];



    }
    else if (isThreeLine)
    {
        if (upperLeft==nil)
        {
            UILabel *upperLabel = [[UILabel alloc] init];
            self.upperLeft=upperLabel;
        }
        self.upperLeft.frame=CGRectMake(10, 10, LABEL_WIDTH, upperLblHeight);
        [self.upperLeft setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];
        [self.upperLeft setText:upperStr];
        [self.upperLeft setNumberOfLines:100];
        [self.upperLeft setHighlightedTextColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.upperLeft];

        float ymiddle = self.upperLeft.frame.origin.y+self.upperLeft.frame.size.height+5;
        if (middleLeft==nil)
        {
            UILabel *middleLabel = [[UILabel alloc] init];
            self.middleLeft=middleLabel;
        }
        self.middleLeft.frame=CGRectMake(10.0, ymiddle, LABEL_WIDTH, middleLblHeight);
        [self.middleLeft setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
        [self.middleLeft setText:middleStr];
        [self.middleLeft setNumberOfLines:100];
        [self.middleLeft setHighlightedTextColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.middleLeft];


        float ylower=self.middleLeft.frame.origin.y+self.middleLeft.frame.size.height+5;
        if (lowerLeft==nil)
        {
            UILabel *lowerLabel = [[UILabel alloc] init];
            self.lowerLeft=lowerLabel;
        }
        self.lowerLeft.frame=CGRectMake(10.0, ylower, LABEL_WIDTH, lowerLblHeight);
        [self.lowerLeft setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
        [self.lowerLeft setText:billingRate];
        [self.lowerLeft setNumberOfLines:1];
        [self.lowerLeft setHighlightedTextColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.lowerLeft];
        
        float activityPositionValue = self.lowerLeft.frame.origin.y + self.lowerLeft.frame.size.height+3;
        UILabel *activityOEFLabel = [[UILabel alloc] init];
        activityOEFLabel.frame=CGRectMake(10.0, activityPositionValue, LABEL_WIDTH, lowerLblHeight);
        [activityOEFLabel setTextColor:[UIColor blackColor]];
        [activityOEFLabel setBackgroundColor:[UIColor clearColor]];
        [activityOEFLabel setTextAlignment:NSTextAlignmentLeft];
        [activityOEFLabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
        [activityOEFLabel setText:lowerStr];
        [activityOEFLabel setNumberOfLines:1];
        [activityOEFLabel setHighlightedTextColor:[UIColor whiteColor]];
        [self.contentView addSubview:activityOEFLabel];

    }

    UIImage *image = [Util thumbnailImage:BTN_ADD_CELL_PRESSED];
    CGRect imageViewframe = CGRectMake(287, 12, image.size.width, image.size.height);
    if (addCellsIconIamgeView==nil)
    {
        self.addCellsIconIamgeView=[[UIImageView alloc]initWithImage:image];
    }
    [addCellsIconIamgeView setFrame:imageViewframe];
    [addCellsIconIamgeView setBackgroundColor:[UIColor clearColor]];


    CGRect frame=CGRectMake(287,12, image.size.width,image.size.height);
    if (addCellsIconBtn==nil) {
        self.addCellsIconBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    }
    [addCellsIconBtn setFrame:frame];
    [addCellsIconBtn setBackgroundColor:[UIColor clearColor]];
    [addCellsIconBtn setImage:nil forState:UIControlStateNormal];
    [addCellsIconBtn addTarget:self action:@selector(addInOutIconClicked:) forControlEvents:UIControlEventTouchUpInside];
    [addCellsIconBtn setTag:tag];
    [addCellsIconBtn setHidden:YES];//changes for mobi-92 Ullas M L
    [addCellsIconIamgeView setHidden:YES];//changes for mobi-92 Ullas M L

    if (isProjectAccess || isActivityAccess)
    {
        [self.contentView addSubview:addCellsIconIamgeView];
        [self.contentView addSubview:addCellsIconBtn];
        [self.contentView bringSubviewToFront:addCellsIconBtn];
    }

    [entryDetailsIconBtn setFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
    [addCellsIconBtn setBackgroundColor:[UIColor clearColor]];
}

- (void)projectEditButtonIconClicked:(id)sender
{
    if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
    {
        MultiDayInOutViewController *ctrl = (MultiDayInOutViewController *) delegate;
        [ctrl projectEditButtonIconClickedForSection:[sender tag]];
        [ctrl handleTapAndResetDayScroll];
    }
}

- (void)addInOutIconClicked:(id)sender
{
    if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
    {
        MultiDayInOutViewController *ctrl = (MultiDayInOutViewController *) delegate;
        [ctrl addInOutButtonIconClickedForSection:[sender tag]];
        [ctrl handleTapAndResetDayScroll];
    }
}

@end
