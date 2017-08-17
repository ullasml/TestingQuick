#import "SuggestionView.h"
#import "Constants.h"
#import "Util.h"
#import "LoginModel.h"
#import <CoreText/CoreText.h>

@implementation SuggestionView
@synthesize attributedString;

#define LABEL_WIDTH SCREEN_WIDTH-20

- (id)initWithFrame:(CGRect)frame
    andWithDataDict:(NSMutableDictionary *)heightDict
      suggestionObj:(NSMutableDictionary *)suggestionObj
            withTag:(int)tag
       withDelegate:(id)delegate
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.tag = tag;
        [self setBackgroundColor:RepliconStandardBackgroundColor];

        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), 1.0f)];
        separatorView.backgroundColor = [Util colorWithHex:@"#cccccc" alpha:1.0f];
        [self addSubview:separatorView];

        NSString *taskName = suggestionObj[@"taskName"];
        NSString *timeoffUri = suggestionObj[@"timeOffUri"];
        NSString *breakUri = suggestionObj[@"breakUri"];
//TODO:Commenting below line because variable is unused,uncomment when using
//        LoginModel *loginModel = [[LoginModel alloc] init];

        BOOL isSingleLine = NO;
        BOOL isTwoLine = NO;
        BOOL isThreeLine = NO;
        NSString *line = heightDict[LINE];
        NSString *upperStr = heightDict[UPPER_LABEL_STRING];
        NSString *middleStr = heightDict[MIDDLE_LABEL_STRING];
        NSString *lowerStr = heightDict[LOWER_LABEL_STRING];
        NSString *billingRate =heightDict[BILLING_RATE];

        float upperLblHeight = ceilf([heightDict[UPPER_LABEL_HEIGHT] newFloatValue]);
        float middleLblHeight = ceilf([heightDict[MIDDLE_LABEL_HEIGHT] newFloatValue]);
        float lowerLblHeight = ceilf([heightDict[LOWER_LABEL_HEIGHT] newFloatValue]);

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
            UILabel *middleLeft = [[UILabel alloc] init];
            middleLeft.frame=CGRectMake(10.0, 10.0, LABEL_WIDTH, middleLblHeight);
            [middleLeft setHighlightedTextColor:[UIColor whiteColor]];
            [self addSubview:middleLeft];
            [middleLeft setText:middleStr];
            BOOL isBreakPresent=NO;
            if (breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]] && ![breakUri isEqualToString:@""])
            {
                isBreakPresent=YES;
            }
            BOOL isTimeoffSickRowPresent=NO;
            if (timeoffUri!=nil && ![timeoffUri isKindOfClass:[NSNull class]] && ![timeoffUri isEqualToString:@""])
            {
                isTimeoffSickRowPresent=YES;
            }
            if (isTimeoffSickRowPresent||isBreakPresent)
            {
                if (isBreakPresent)
                {
                    UIImage *breakImage = [UIImage imageNamed:@"icon_break_small"];
                    UIImageView *breakImageView = [[UIImageView alloc] initWithImage:breakImage];
                    [self addSubview:breakImageView];

                    middleLeft.frame=CGRectMake(10.0+breakImage.size.width+10, 14.0, LABEL_WIDTH, middleLblHeight);
                    breakImageView.center = CGPointMake(20.0f, CGRectGetMidY(middleLeft.frame));
                }
                [middleLeft setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];
                [middleLeft setNumberOfLines:100];
            }
            else
            {
                [middleLeft setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
                middleLeft.frame=CGRectMake(10.0,5.0, LABEL_WIDTH, EachDayTimeEntry_Cell_Row_Height_44);
                [middleLeft setNumberOfLines:1];
            }
        }
        else if (isTwoLine)
        {
            BOOL isTaskPresent=YES;
            NSString *timeEntryTaskName=taskName;
            if (timeEntryTaskName==nil || [timeEntryTaskName isKindOfClass:[NSNull class]]||[timeEntryTaskName isEqualToString:@""])
            {
                isTaskPresent=NO;
            }

            UILabel *upperLeft = [[UILabel alloc] init];
            upperLeft.frame=CGRectMake(10, 10, LABEL_WIDTH, upperLblHeight);

            if (isTaskPresent)
            {
                [upperLeft setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];
            }
            else
            {
                [upperLeft setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
            }

            [upperLeft setText:upperStr];
            [upperLeft setNumberOfLines:100];
            [upperLeft setHighlightedTextColor:[UIColor whiteColor]];
            [self addSubview:upperLeft];

            float yLower = CGRectGetMaxY(upperLeft.frame) + 5.0f;

            UILabel *lowerLeft = [[UILabel alloc] init];
            lowerLeft.frame=CGRectMake(10.0, yLower, LABEL_WIDTH, lowerLblHeight);
            [lowerLeft setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
            [lowerLeft setText:billingRate];
            [lowerLeft setNumberOfLines:1];

            [lowerLeft setHighlightedTextColor:[UIColor whiteColor]];
            [self addSubview:lowerLeft];
        
        float activityPositionValue = lowerLeft.frame.origin.y + lowerLeft.frame.size.height+3;
        UILabel *activityOEFLabel = [[UILabel alloc] init];
        activityOEFLabel.frame=CGRectMake(10.0, activityPositionValue, LABEL_WIDTH, lowerLblHeight);
        [activityOEFLabel setTextColor:[UIColor blackColor]];
        [activityOEFLabel setBackgroundColor:[UIColor clearColor]];
        [activityOEFLabel setTextAlignment:NSTextAlignmentLeft];
        [activityOEFLabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
        [activityOEFLabel setText:lowerStr];
        [activityOEFLabel setNumberOfLines:1];
        [activityOEFLabel setHighlightedTextColor:[UIColor whiteColor]];
        [self addSubview:activityOEFLabel];

        }
        else if (isThreeLine)
        {

            UILabel *upperLeft = [[UILabel alloc] init];
            upperLeft.frame=CGRectMake(10, 10, LABEL_WIDTH, upperLblHeight);
            [upperLeft setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];
            [upperLeft setText:upperStr];
            [upperLeft setNumberOfLines:100];
            [upperLeft setHighlightedTextColor:[UIColor whiteColor]];
            [self addSubview:upperLeft];

            float ymiddle = CGRectGetMaxY(upperLeft.frame) + 5.0f;

            UILabel *middleLeft = [[UILabel alloc] init];
            middleLeft.frame = CGRectMake(10.0, ymiddle, LABEL_WIDTH, middleLblHeight);
            [middleLeft setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
            [middleLeft setText:middleStr];
            [middleLeft setNumberOfLines:100];
            [middleLeft setHighlightedTextColor:[UIColor whiteColor]];
            [self addSubview:middleLeft];

            float ylower = CGRectGetMaxY(middleLeft.frame) + 5.0f;

            UILabel *lowerLeft = [[UILabel alloc] init];
            lowerLeft.frame=CGRectMake(10.0, ylower, LABEL_WIDTH, lowerLblHeight);
            [lowerLeft setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
            [lowerLeft setText:billingRate];
            [lowerLeft setNumberOfLines:1];
            [lowerLeft setHighlightedTextColor:[UIColor whiteColor]];
            [self addSubview:lowerLeft];
            
            float activityPositionValue =lowerLeft.frame.origin.y + lowerLeft.frame.size.height+3;
            UILabel *activityOEFLabel = [[UILabel alloc] init];
            activityOEFLabel.frame=CGRectMake(10.0, activityPositionValue, LABEL_WIDTH, lowerLblHeight);
            [activityOEFLabel setTextColor:[UIColor blackColor]];
            [activityOEFLabel setBackgroundColor:[UIColor clearColor]];
            [activityOEFLabel setTextAlignment:NSTextAlignmentLeft];
            [activityOEFLabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
            [activityOEFLabel setText:lowerStr];
            [activityOEFLabel setNumberOfLines:1];
            [activityOEFLabel setHighlightedTextColor:[UIColor whiteColor]];
            [self addSubview:activityOEFLabel];

        }
    }
    [self setAccessibilityIdentifier:@"uia_suggestion_view_identifier"];
    return self;
}

@end
