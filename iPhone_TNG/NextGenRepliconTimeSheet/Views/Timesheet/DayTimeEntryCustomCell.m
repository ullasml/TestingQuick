//
//  DayTimeEntryCustomCell.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 10/01/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import "DayTimeEntryCustomCell.h"
#import "DayTimeEntryViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "Util.h"
#import "AppDelegate.h"
#import <CoreText/CoreText.h>
#import "LoginModel.h"
#import "TimesheetModel.h"
#import "ApprovalsModel.h"
#import "OEFObject.h"

@interface DayTimeEntryCustomCell()
@property(nonatomic)NSString *timesheetFormat;
@property(nonatomic,assign)BOOL allowNegativeTimeEntry;
@end

@implementation DayTimeEntryCustomCell
@synthesize upperLeft;
@synthesize upperRight;
@synthesize commentsIcon;
@synthesize lowerLeft;
@synthesize delegate;
@synthesize numberKeyPad;
@synthesize toolBar;
@synthesize selectedPath;
@synthesize rowdetails;
@synthesize udfArray;
@synthesize timeEntryComments;
@synthesize isTimeoffRow;
@synthesize isCellRowEditable;
@synthesize middleLeft;
@synthesize attributedString;
@synthesize doneButton;
@synthesize spaceButton;
@synthesize cancelButton;
@synthesize previousDateUdfValue;
@synthesize pickerClearButton;
@synthesize isCommentRequired;
@synthesize datePicker;
@synthesize approvalsModuleName;

#define DecimalPlaces 2
#define OffSetFor4 60
#define OffSetFor5 150
#define LEFT_PADDING 10
#define VERTICAL_SEPARATOR_IMAGE_WIDTH 1
#define RIGHT_VIEW_WIDTH 70

#define LABEL_WIDTH_WITH_COMMENTS (SCREEN_WIDTH-100-2*LEFT_PADDING)


#pragma mark - Cell Create method
-(void)createCellLayoutWithParams:(TimesheetEntryObject *)tsEntryObject
                  isProjectAccess:(BOOL)isProjectAccess
                   isClientAccess:(BOOL)isClientAccess
                 isActivityAccess:(BOOL)isActivityAccess
                 isBillingAccess:(BOOL)isBillingAccess
                 isTimeoffSickRow:(BOOL)isTimeoffSickRow
                    upperrightstr:(NSString *)upperrightString
                      commentsStr:(NSString *)commentsStr
            commentsImageRequired:(BOOL )isCommentsImageRequired
                              tag:(NSInteger)tag
                lastUsedTextField:(UITextField *)lastUsedTextField
                         udfArray:(NSMutableArray *)tmpUdfArray
                        isTimeoff:(BOOL)isTimeoff
                    withEditState:(BOOL)canEdit
                     withDelegate:(id)_delegate
                       heightDict:(NSMutableDictionary *)heightDict
                 timeSheetFormat:(NSString *)timeSheetFormat
                 hasCommentsAccess:(BOOL)hasCommentsAccess
             hasNegativeTimeEntry:(BOOL)allowNegativeTimeEntry

{
    self.allowNegativeTimeEntry = allowNegativeTimeEntry;
    self.timesheetFormat = timeSheetFormat;
    self.timeEntryComments=commentsStr;
    UIImage *lowerImage = [Util thumbnailImage:Cell_HairLine_Image];
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,0, SCREEN_WIDTH,1)];
    [lineImageView setImage:lowerImage];
    [self.contentView bringSubviewToFront:lineImageView];
    [self.contentView addSubview:lineImageView];
    isCommentRequired=isCommentsImageRequired;
    float LABEL_WIDTH=LABEL_WIDTH_WITH_COMMENTS;
    self.isCellRowEditable=canEdit;
    BOOL isSingleLine=NO;
    BOOL isTwoLine=NO;
    BOOL isThreeLine=NO;
    NSString *line=[heightDict objectForKey:LINE];
    NSString *upperStr=[heightDict objectForKey:UPPER_LABEL_STRING];
    NSString *middleStr=[heightDict objectForKey:MIDDLE_LABEL_STRING];
    NSString *lowerStr=[heightDict objectForKey:LOWER_LABEL_STRING];
    NSString *billingRate =[heightDict objectForKey:BILLING_RATE];

    float upperLblHeight=[[heightDict objectForKey:UPPER_LABEL_HEIGHT] newFloatValue];
    float middleLblHeight=[[heightDict objectForKey:MIDDLE_LABEL_HEIGHT] newFloatValue];
    float lowerLblHeight=[[heightDict objectForKey:LOWER_LABEL_HEIGHT] newFloatValue];
    float height=[[heightDict objectForKey:CELL_HEIGHT_KEY] newFloatValue];
    float billingLabelheight=[[heightDict objectForKey:BILLING_LABEL_HEIGHT] newFloatValue];
//TODO:Commenting below line because variable is unused,uncomment when using
//    BOOL isMiddleLabelTextWrap=[[heightDict objectForKey:MIDDLE_LABEL_TEXT_WRAP] boolValue];

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
        self.middleLeft.frame=CGRectMake(LEFT_PADDING, 10.0, LABEL_WIDTH, middleLblHeight);
        [self.middleLeft setTextColor:[UIColor blackColor]];
        [self.middleLeft setTextAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.middleLeft];
        [self.middleLeft setText:middleStr];
        [self.middleLeft setAccessibilityLabel:@"client_project_lbl"];
        [self.middleLeft setAccessibilityValue:middleStr];

        if (isTimeoffSickRow)
        {
            if (middleLblHeight<height)
            {
                self.middleLeft.frame=CGRectMake(LEFT_PADDING, (height-middleLblHeight)/2, LABEL_WIDTH, middleLblHeight);
            }
            [self.middleLeft setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];
            [self.middleLeft setNumberOfLines:100];
        }
        else
        {
            [self.middleLeft setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];
            self.middleLeft.frame=CGRectMake(LEFT_PADDING,5.0, LABEL_WIDTH, EachDayTimeEntry_Cell_Row_Height_44);
            [self.middleLeft setNumberOfLines:1];
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
        self.upperLeft.frame = CGRectMake(LEFT_PADDING, 10, LABEL_WIDTH, upperLblHeight);
        [self.upperLeft setTextColor:[UIColor blackColor]];
        [self.upperLeft setTextAlignment:NSTextAlignmentLeft];

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
        self.lowerLeft.frame=CGRectMake(LEFT_PADDING, yLower, LABEL_WIDTH, billingLabelheight);
        [self.lowerLeft setTextColor:[UIColor blackColor]];
        [self.lowerLeft setTextAlignment:NSTextAlignmentLeft];
        [self.lowerLeft setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
        [self.lowerLeft setText:billingRate];
        [self.lowerLeft setAccessibilityLabel:@"activity_lbl"];
        [self.lowerLeft setAccessibilityValue:lowerStr];
        [self.lowerLeft setNumberOfLines:1];

        [self.contentView addSubview:self.lowerLeft];

        float activityPositionValue = self.lowerLeft.frame.origin.y + self.lowerLeft.frame.size.height+3;
        UILabel *activityOEFLabel = [[UILabel alloc] init];
        activityOEFLabel.frame=CGRectMake(LEFT_PADDING, activityPositionValue, LABEL_WIDTH, lowerLblHeight);
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
        self.upperLeft.frame=CGRectMake(LEFT_PADDING, 10, LABEL_WIDTH, upperLblHeight);
        [self.upperLeft setTextColor:[UIColor blackColor]];
        [self.upperLeft setBackgroundColor:[UIColor clearColor]];
        [self.upperLeft setTextAlignment:NSTextAlignmentLeft];
        [self.upperLeft setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];
        [self.upperLeft setText:upperStr];
        [self.upperLeft setNumberOfLines:100];
        [self.upperLeft setHighlightedTextColor:[UIColor whiteColor]];
        [self.upperLeft setAccessibilityLabel:@"task_lbl"];
        [self.upperLeft setAccessibilityValue:upperStr];
        [self.contentView addSubview:self.upperLeft];

        float ymiddle=self.upperLeft.frame.origin.y+self.upperLeft.frame.size.height+5;
        if (middleLeft==nil)
        {
            UILabel *middleLabel = [[UILabel alloc] init];
            self.middleLeft=middleLabel;
        }
        self.middleLeft.frame=CGRectMake(LEFT_PADDING, ymiddle, LABEL_WIDTH, middleLblHeight);
        [self.middleLeft setTextColor:[UIColor blackColor]];
        [self.middleLeft setBackgroundColor:[UIColor clearColor]];
        [self.middleLeft setTextAlignment:NSTextAlignmentLeft];
        [self.middleLeft setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
        [self.middleLeft setText:middleStr];
        [self.middleLeft setNumberOfLines:100];
        [self.middleLeft setAccessibilityLabel:@"client_project_lbl"];
        [self.contentView addSubview:self.middleLeft];
        [self.middleLeft setAccessibilityValue:middleStr];

        float ylower=self.middleLeft.frame.origin.y+self.middleLeft.frame.size.height+5;
        if (lowerLeft==nil)
        {
            UILabel *lowerLabel = [[UILabel alloc] init];
            self.lowerLeft=lowerLabel;
        }
        self.lowerLeft.frame=CGRectMake(LEFT_PADDING, ylower, LABEL_WIDTH, billingLabelheight);
        [self.lowerLeft setTextColor:[UIColor blackColor]];
        [self.lowerLeft setBackgroundColor:[UIColor clearColor]];
        [self.lowerLeft setTextAlignment:NSTextAlignmentLeft];
        [self.lowerLeft setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
        [self.lowerLeft setText:billingRate];
        [self.lowerLeft setAccessibilityLabel:@"activity_lbl"];
        [self.lowerLeft setAccessibilityValue:lowerStr];

        [self.lowerLeft setNumberOfLines:1];
        [self.contentView addSubview:self.lowerLeft];

        float activityPositionValue = self.lowerLeft.frame.origin.y + self.lowerLeft.frame.size.height+3;
        UILabel *activityOEFLabel = [[UILabel alloc] init];
        activityOEFLabel.frame=CGRectMake(LEFT_PADDING, activityPositionValue, LABEL_WIDTH, lowerLblHeight);
        [activityOEFLabel setTextColor:[UIColor blackColor]];
        [activityOEFLabel setBackgroundColor:[UIColor clearColor]];
        [activityOEFLabel setTextAlignment:NSTextAlignmentLeft];
        [activityOEFLabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
        [activityOEFLabel setText:lowerStr];
        [activityOEFLabel setNumberOfLines:1];
        [activityOEFLabel setHighlightedTextColor:[UIColor whiteColor]];
        [self.contentView addSubview:activityOEFLabel];

    }
    
    CGFloat verticalImageWidth = VERTICAL_SEPARATOR_IMAGE_WIDTH;
    CGFloat rightViewWidth = RIGHT_VIEW_WIDTH;
    
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - (verticalImageWidth+ rightViewWidth), 0, verticalImageWidth, height)];
    UIImage *verticalImage=[Util thumbnailImage:VERTICAL_SEPARATOR_IMAGE];
    [verticalImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 0, height,0)];
    [imageView setBackgroundColor:[UIColor colorWithPatternImage:verticalImage]];
    [self.contentView addSubview:imageView];

    CGFloat rightViewXPosition = SCREEN_WIDTH - rightViewWidth;
    
    if (canEdit)
    {
        UIButton *tempButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - rightViewWidth, 2, rightViewWidth, height-2)];
        if (canEdit)
        {
            [tempButton setBackgroundColor:[UIColor whiteColor]];
        }
        else
        {
            [tempButton setBackgroundColor:[UIColor clearColor]];
        }
        [tempButton addTarget:self action:@selector(becomeFirstResponderForTextField) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:tempButton];
        [self.contentView bringSubviewToFront:tempButton];
    }


    if (canEdit)
    {

        if (upperRight == nil)
        {
            self.upperRight = [[UITextField alloc] init];
            [self.upperRight setAccessibilityIdentifier:@"uia_standard_timesheet_time_entry_textfield_identifier"];
        }
        if (isSingleLine)
        {
            [self.upperRight setFrame:CGRectMake(rightViewXPosition-2, (height-20)/2, rightViewWidth, 20)];
            upperRight.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        }
        else
        {
            [self.upperRight setFrame:CGRectMake(rightViewXPosition-2, 10, rightViewWidth, 20)];
            upperRight.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        }
        
        upperRight.text = upperrightString;
        if(self.timesheetFormat!=nil && self.timesheetFormat!=(id)[NSNull null])
        {
            if([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET] && !tsEntryObject.hasTimeEntryValue)
            {
                upperRight.text = @"";
                upperRight.placeholder = [Util getRoundedValueFromDecimalPlaces:[@"0.00" newDoubleValue] withDecimalPlaces:2];
            }
        }
        [self.upperRight setAccessibilityValue:upperrightString];
        upperRight.textAlignment = NSTextAlignmentCenter;
        upperRight.font = [UIFont fontWithName:RepliconFontFamilySemiBold size:RepliconFontSize_17];
        upperRight.textColor = RepliconStandardBlackColor;
        upperRight.delegate = self;
        upperRight.keyboardType = UIKeyboardTypeNumberPad;
		upperRight.borderStyle = UITextBorderStyleNone;
        upperRight.keyboardAppearance = UIKeyboardAppearanceLight;
        upperRight.tag = tag;

        [self.contentView addSubview:upperRight];
        [self.contentView bringSubviewToFront:upperRight];
    }
    else
    {
        UILabel *tempupperRight = [[UILabel alloc] init];
        if (isSingleLine)
        {
            [tempupperRight setFrame:CGRectMake(rightViewXPosition-2, (height-20)/2, rightViewWidth, 20)];

        }
        else
        {
            [tempupperRight setFrame:CGRectMake(rightViewXPosition-2, 10, rightViewWidth, 20)];

        }
        [tempupperRight setAccessibilityIdentifier:@"uia_standard_timesheet_time_entry_textfield_identifier"];
        [tempupperRight setFont:[UIFont fontWithName:RepliconFontFamilySemiBold size:RepliconFontSize_17]];
        [tempupperRight setBackgroundColor:[UIColor clearColor]];
        [tempupperRight setTextAlignment:NSTextAlignmentCenter];
        [tempupperRight setText:upperrightString];
        [tempupperRight setAccessibilityValue:upperrightString];
        if(self.timesheetFormat!=nil && self.timesheetFormat!=(id)[NSNull null])
        {
            if([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET] && !tsEntryObject.hasTimeEntryValue)
            {
                tempupperRight.textColor = [UIColor grayColor];
            }
        }
        [tempupperRight setNumberOfLines:1];
        [tempupperRight setHighlightedTextColor:[UIColor whiteColor]];
        [self.contentView addSubview:tempupperRight];

    }


    UIImage *commentsOrArrowImg=[self getColoredImageForTimesheetEntryObject:tsEntryObject andTimeSheetFormat:timeSheetFormat];
    if (commentsIcon == nil)
    {
        UIImageView *templineImageView = [[UIImageView alloc] init];
        self.commentsIcon=templineImageView;

    }
    if (isSingleLine)
    {
        [commentsIcon setFrame:CGRectMake(LABEL_WIDTH+2*LEFT_PADDING, (height-commentsOrArrowImg.size.height)/2, commentsOrArrowImg.size.width,commentsOrArrowImg.size.height)];
    }
    else
    {
       [commentsIcon setFrame:CGRectMake(LABEL_WIDTH+2*LEFT_PADDING, 12, commentsOrArrowImg.size.width,commentsOrArrowImg.size.height)];
    }

    [commentsIcon setImage:commentsOrArrowImg];
    
    if (![timeSheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
    {
        [self.contentView addSubview:commentsIcon];
    }
    
    else if ([timeSheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET] && hasCommentsAccess)
    {
        [self.contentView addSubview:commentsIcon];
    }
    
    



    [self.upperLeft sizeToFit];
    [self.middleLeft sizeToFit];
    //[self.lowerLeft sizeToFit];

}
-(void)becomeFirstResponderForTextField
{
    [self.upperRight becomeFirstResponder];
}

-(UIImage *)getColoredImageForTimesheetEntryObject:(TimesheetEntryObject *)tsEntryObject andTimeSheetFormat:(NSString *)timeSheetFormat
{
    NSMutableArray *commentsImageColorStatusArray=[NSMutableArray array];
    LoginModel *loginModel=[[LoginModel alloc]init];
    //Implementation for US9371//JUHI
    NSMutableArray *requiredUdfArray=nil;


    if ([[tsEntryObject entryType] isEqualToString:Time_Off_Key]||[[tsEntryObject entryType] isEqualToString:Adhoc_Time_OffKey])
    {
        requiredUdfArray=[loginModel getRequiredOnlyUDFsforModuleName:TIMEOFF_UDF];
    }
    else
    {
        if (![timeSheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
        {
           requiredUdfArray=[loginModel getRequiredOnlyUDFsforModuleName:TIMESHEET_ROW_UDF];
        }
    }


    
   

    if ([[tsEntryObject entryType] isEqualToString:Time_Off_Key])
    {
        for (int k=0; k<[[tsEntryObject timeEntryUdfArray] count]; k++)
        {
            EntryCellDetails *udfDetails=(EntryCellDetails *)[[tsEntryObject timeEntryUdfArray] objectAtIndex:k];
            NSString *udfValue=[udfDetails fieldValue];
            if ([udfValue isEqualToString:RPLocalizedString(ADD_STRING, @"")]|| [udfValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]|| [udfValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])
            {

                [commentsImageColorStatusArray addObject:@"GRAY"];

            }
            else
            {

                [commentsImageColorStatusArray removeObject:@"GRAY"];
                [commentsImageColorStatusArray addObject:@"BLUE"];
            }
        }

    }
    else
    {
        if ([requiredUdfArray count]!=0)
        {
            NSMutableArray *array=nil;
            if ([[tsEntryObject entryType] isEqualToString:Adhoc_Time_OffKey])
            {
                array=[tsEntryObject timeEntryUdfArray];
            }
            else
            {
                array=[tsEntryObject timeEntryRowUdfArray];
            }
            //Implementation for US9371//JUHI
            for (int k=0; k<[array count]; k++)
            {

                EntryCellDetails *udfDetails=(EntryCellDetails *)[array objectAtIndex:k];

                BOOL isUdfMandatory=NO;
                if ([[tsEntryObject entryType] isEqualToString:Time_Off_Key]||[[tsEntryObject entryType] isEqualToString:Adhoc_Time_OffKey])
                {
                    isUdfMandatory=[loginModel getMandatoryStatusforUDFWithIdentity:[udfDetails udfIdentity] forModuleName:TIMEOFF_UDF];
                }
                else
                {
                    if ([delegate isKindOfClass:[DayTimeEntryViewController class]])
                    {

                        if ([timeSheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
                        {
                            isUdfMandatory=NO;
                        }
                        else
                        {
                            isUdfMandatory=[loginModel getMandatoryStatusforUDFWithIdentity:[udfDetails udfIdentity] forModuleName:TIMESHEET_ROW_UDF];
                        }
                    }


                }
                if (isUdfMandatory)
                {//Implementation for US9371//JUHI
                    NSString *udfValue=nil;
                    if ([[udfDetails fieldValue] isKindOfClass:[NSDate class]])
                    {
                        udfValue= [Util convertDateToString:[udfDetails fieldValue]];
                    }
                    else
                        udfValue=[udfDetails fieldValue];
                    if ([udfValue isEqualToString:RPLocalizedString(ADD_STRING, @"")]|| [udfValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
                    {

                        [commentsImageColorStatusArray addObject:@"RED"];


                    }
                    else
                    {

                        [commentsImageColorStatusArray addObject:@"BLUE"];
                    }
                }
                else
                {

                    [commentsImageColorStatusArray addObject:@"BLUE"];
                }

            }
        }
        else
        {
            if ([timeSheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
            {
                for (int k=0; k<[[tsEntryObject timeEntryRowOEFArray] count]; k++)
                {
                    OEFObject *oefObject=[[tsEntryObject timeEntryRowOEFArray]  objectAtIndex:k];
                    NSString *oefValue=nil;
                    if (oefObject.oefNumericValue!=nil && ![oefObject.oefNumericValue isKindOfClass:[NSNull class]])
                    {
                        oefValue=[oefObject oefNumericValue];
                    }
                    else if (oefObject.oefTextValue!=nil && ![oefObject.oefTextValue isKindOfClass:[NSNull class]])
                    {
                        oefValue=[oefObject oefTextValue];
                    }
                    else if (oefObject.oefDropdownOptionValue!=nil && ![oefObject.oefDropdownOptionValue isKindOfClass:[NSNull class]])
                    {
                        oefValue=[oefObject oefDropdownOptionValue];
                    }

                    if (oefValue!=nil && ![oefValue isEqualToString:RPLocalizedString(ADD_STRING, @"")] &&
                        ![oefValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]&&
                        ![oefValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
                    {
                        [commentsImageColorStatusArray removeObject:@"GRAY"];
                        [commentsImageColorStatusArray addObject:@"BLUE"];
                    }
                    else
                    {
                         [commentsImageColorStatusArray addObject:@"GRAY"];
                    }

                }
                for (int k=0; k<[[tsEntryObject timeEntryCellOEFArray] count]; k++)
                {
                    OEFObject *oefObject=[[tsEntryObject timeEntryCellOEFArray]  objectAtIndex:k];
                    NSString *oefValue=nil;
                    if (oefObject.oefNumericValue!=nil && ![oefObject.oefNumericValue isKindOfClass:[NSNull class]])
                    {
                        oefValue=[oefObject oefNumericValue];
                    }
                    else if (oefObject.oefTextValue!=nil && ![oefObject.oefTextValue isKindOfClass:[NSNull class]])
                    {
                        oefValue=[oefObject oefTextValue];
                    }
                    else if (oefObject.oefDropdownOptionValue!=nil && ![oefObject.oefDropdownOptionValue isKindOfClass:[NSNull class]])
                    {
                        oefValue=[oefObject oefDropdownOptionValue];
                    }

                    if (oefValue!=nil && ![oefValue isEqualToString:RPLocalizedString(ADD_STRING, @"")] &&
                        ![oefValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]&&
                        ![oefValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
                    {
                        [commentsImageColorStatusArray removeObject:@"GRAY"];
                        [commentsImageColorStatusArray addObject:@"BLUE"];
                    }
                    else
                    {
                        [commentsImageColorStatusArray addObject:@"GRAY"];
                    }
                    
                }
            }
            else
            {
                for (int k=0; k<[[tsEntryObject timeEntryRowUdfArray] count]; k++)
                {
                    EntryCellDetails *udfDetails=(EntryCellDetails *)[[tsEntryObject timeEntryRowUdfArray] objectAtIndex:k];
                    NSString *udfValue=nil;
                    if ([[udfDetails fieldValue] isKindOfClass:[NSDate class]])
                    {
                        udfValue= [Util convertDateToString:[udfDetails fieldValue]];
                    }
                    else
                        udfValue=[udfDetails fieldValue];
                    if ([udfValue isEqualToString:RPLocalizedString(ADD_STRING, @"")]|| [udfValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]|| [udfValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])
                    {

                        [commentsImageColorStatusArray addObject:@"GRAY"];

                    }
                    else
                    {

                        [commentsImageColorStatusArray removeObject:@"GRAY"];
                        [commentsImageColorStatusArray addObject:@"BLUE"];
                    }
                }
            }

        }


    }

    NSString *comments=timeEntryComments;
    NSMutableArray *commentsImageColorStatusArrayForComments=[NSMutableArray array];
    BOOL ifCommentsMandatory=NO;
    NSMutableArray *daySummaryArray=nil;
    if (approvalsModuleName==nil||[approvalsModuleName isKindOfClass:[NSNull class]]||[approvalsModuleName isEqualToString:@""])
    {
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        daySummaryArray=[timesheetModel getAllTimesheetDaySummaryFromDBForTimesheet:[tsEntryObject timesheetUri]];
    }
    else
    {
        ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
        if ([approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            daySummaryArray=[approvalsModel getAllPendingTimesheetDaySummaryFromDBForTimesheet:[tsEntryObject timesheetUri]];
        }
        else
        {
            daySummaryArray=[approvalsModel getAllPreviousTimesheetDaySummaryFromDBForTimesheet:[tsEntryObject timesheetUri]];
        }
    }

    if ([daySummaryArray count]!=0) {
        if ([[[daySummaryArray objectAtIndex:0] objectForKey:@"isCommentsRequired"] intValue]==1)
        {
            ifCommentsMandatory=YES;
        }
    }
    if ([[tsEntryObject entryType] isEqualToString:Time_Off_Key])
    {
        if (comments!=nil && ![comments isEqualToString:@""]&& ![comments isKindOfClass:[NSNull class]]&&![comments isEqualToString:NULL_STRING])
        {

            [commentsImageColorStatusArrayForComments addObject:@"BLUE"];
        }
        else
        {

            [commentsImageColorStatusArrayForComments addObject:@"GRAY"];
        }
    }
    else
    {
        if (ifCommentsMandatory)
        {
            if (comments!=nil && ![comments isEqualToString:@""]&& ![comments isKindOfClass:[NSNull class]]&&![comments isEqualToString:NULL_STRING])
            {

                [commentsImageColorStatusArrayForComments addObject:@"BLUE"];
            }
            else
            {

                [commentsImageColorStatusArrayForComments addObject:@"RED"];
            }
        }
        else
        {
            if (comments!=nil && ![comments isEqualToString:@""]&& ![comments isKindOfClass:[NSNull class]]&&![comments isEqualToString:NULL_STRING])
            {

                [commentsImageColorStatusArrayForComments addObject:@"BLUE"];
            }
            else
            {

                [commentsImageColorStatusArrayForComments addObject:@"GRAY"];
            }

        }

    }

    UIImage *commentsOrArrowImg = nil;
    if ([commentsImageColorStatusArray containsObject:@"RED"]||[commentsImageColorStatusArrayForComments containsObject:@"RED"])
    {
        commentsOrArrowImg = [UIImage imageNamed:@"icon_comments_red"];
    }
    else if ([commentsImageColorStatusArray containsObject:@"BLUE"]||[commentsImageColorStatusArrayForComments containsObject:@"BLUE"])
    {
        commentsOrArrowImg=[UIImage imageNamed:@"icon_comments_blue"];
    }
    else if ([commentsImageColorStatusArray containsObject:@"GRAY"]&&[commentsImageColorStatusArrayForComments containsObject:@"GRAY"])
    {
        commentsOrArrowImg = [UIImage imageNamed:@"icon_comments_gray"];

    }
    else
    {
        LoginModel *loginModel=[[LoginModel alloc]init];
        NSMutableArray *requiredUdfArray=nil;
        if (![timeSheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
        {
            requiredUdfArray=[loginModel getRequiredOnlyUDFsforModuleName:TIMESHEET_CELL_UDF];
        }
        
        
        if ([requiredUdfArray count]!=0)
        {
            commentsOrArrowImg=[UIImage imageNamed:@"icon_comments_blue"];
        }
        else
        {
            if (comments!=nil && ![comments isEqualToString:@""]&& ![comments isKindOfClass:[NSNull class]]&&![comments isEqualToString:NULL_STRING])
            {
                commentsOrArrowImg=[UIImage imageNamed:@"icon_comments_blue"];
            }
            else
            {
                commentsOrArrowImg=[UIImage imageNamed:@"icon_comments_gray"];
            }

        }

    }

    return commentsOrArrowImg;

}
/************************************************************************************************************
 @Function Name   : setSelected
 @Purpose         : To change the highlighted textfield's text color
 @param           : nil
 @return          : nil
 *************************************************************************************************************/
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

#pragma mark - Textfield Delegates

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([delegate isKindOfClass:[DayTimeEntryViewController class]])
    {
         [self handleTapAndResetDayScroll];
        DayTimeEntryViewController *currentTimesheetCtrl=(DayTimeEntryViewController *)delegate;
        currentTimesheetCtrl.currentIndexpath=[NSIndexPath indexPathForRow:[textField tag] inSection:0];
        if ([textField.text isEqualToString:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]])
        {
            [textField setText:@""];
        }
    }
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([delegate isKindOfClass:[DayTimeEntryViewController class]])
    {
        DayTimeEntryViewController *currentTimesheetCtrl=(DayTimeEntryViewController *)delegate;
        [currentTimesheetCtrl setLastUsedTextField:textField];
        [currentTimesheetCtrl setIsTextFieldClicked:YES];

        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:textField.tag inSection:0];
        if (!self.numberKeyPad)
        {
            self.numberKeyPad.isDonePressed=NO;
            BOOL showNegativeButton = NO;
            if([self.timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET] && self.allowNegativeTimeEntry)
            {
                showNegativeButton = YES;
            }
            self.numberKeyPad =[NumberKeypadDecimalPoint keypadForTextField:textField withDelegate:delegate withMinus:showNegativeButton andisDoneShown:NO withResignButton:NO];
            if ([textField textAlignment] == NSTextAlignmentCenter)
            {
                [self.numberKeyPad.decimalPointButton setTag:444];
            }
        }
        else
        {
            //if we go from one field to another - just change the textfield, don't reanimate the decimal point button
            self.numberKeyPad.currentTextField = textField;
        }
        [currentTimesheetCtrl setIsTextFieldClicked:YES];
        [currentTimesheetCtrl setIsUDFieldClicked:NO];
        [currentTimesheetCtrl resetTableSize:YES];
        [[currentTimesheetCtrl timeEntryTableView] scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        [[currentTimesheetCtrl timeEntryTableView] setScrollEnabled:YES];


    }

    return YES;


}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField textAlignment] == NSTextAlignmentCenter) {
		[Util updateCenterAlignedTextField:textField withString:string withRange:range withDecimalPlaces:DecimalPlaces];
        if ([delegate isKindOfClass:[DayTimeEntryViewController class]])
        {
            DayTimeEntryViewController *currentTimesheetCtrl=(DayTimeEntryViewController *)delegate;
            [currentTimesheetCtrl updateTimeEntryHoursForIndex:textField.tag withValue:textField.text isDoneClicked:NO];
        }
		return NO;
	}
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == numberKeyPad.currentTextField) {
		/*
		 Hide the number keypad
		 */
		[self.numberKeyPad removeButtonFromKeyboard];
        if ([numberKeyPad isDonePressed])
        {
            if ([delegate isKindOfClass:[DayTimeEntryViewController class]])
            {
                DayTimeEntryViewController *currentTimesheetCtrl=(DayTimeEntryViewController *)delegate;
                [currentTimesheetCtrl resetTableSize:NO];


            }
            numberKeyPad.isDonePressed=NO;

        }

		self.numberKeyPad = nil;

	}
    if ([delegate isKindOfClass:[DayTimeEntryViewController class]])
    {
        DayTimeEntryViewController *currentTimesheetCtrl=(DayTimeEntryViewController *)delegate;

        [currentTimesheetCtrl updateTimeEntryHoursForIndex:textField.tag withValue:textField.text isDoneClicked:YES];


        [currentTimesheetCtrl.toolbar setHidden:YES];


    }

   [self setSelected:NO animated:NO];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}



-(void)doneClicked
{

    if ([delegate isKindOfClass:[DayTimeEntryViewController class]])
    {
        DayTimeEntryViewController *currentTimesheetCtrl=(DayTimeEntryViewController *)delegate;
        [currentTimesheetCtrl setIsTextFieldClicked:NO];
        [currentTimesheetCtrl setIsUDFieldClicked:NO];
        [currentTimesheetCtrl resetTableSize:NO];
        [currentTimesheetCtrl.lastUsedTextField resignFirstResponder];
        [currentTimesheetCtrl.lastUsedTextView resignFirstResponder];
    }
    self.toolBar.hidden=YES;

    //[timeEntryTableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
}


-(void)handleTapAndResetDayScroll
{
    if ([delegate isKindOfClass:[DayTimeEntryViewController class]])
    {
        DayTimeEntryViewController *currentTimesheetCtrl=(DayTimeEntryViewController *)delegate;
        [currentTimesheetCtrl handleTapAndResetDayScroll];
    }
}




@end
