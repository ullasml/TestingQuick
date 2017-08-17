#import "MultiDayInOutTimeEntryCustomCell.h"
#import "Util.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>
#import "MultiDayInOutViewController.h"
#import "TimesheetEntryObject.h"
#import "LoginModel.h"
#import "TimesheetModel.h"
#import "ApprovalsModel.h"

#define DecimalPlaces 2
#define Entry_Button_Tag 555
@implementation MultiDayInOutTimeEntryCustomCell
@synthesize upperLeft;
@synthesize timeEntryComments;
@synthesize inTimeButton;
@synthesize outTimeButton;
@synthesize commentsIcon;
@synthesize upperRight;
@synthesize rowdetails;
@synthesize delegate;
@synthesize udfArray;
@synthesize numberKeyPad;
@synthesize selectedPath;
@synthesize datePicker;
@synthesize toolBar;
@synthesize upperRightInOutLabel;
@synthesize isTimeoffRow;
@synthesize doneButton;
@synthesize spaceButton;
@synthesize cancelButton;
@synthesize previousDateUdfValue;
@synthesize pickerClearButton;
@synthesize approvalsModuleName;
@synthesize timesheetUri;

#define HOURS_WIDTH 90
#define PADDING_SPACE 10
#define LABEL_WIDTH_WITH_COMMENTS (SCREEN_WIDTH)-HOURS_WIDTH-(3*PADDING_SPACE)

#define PADDING_SPACE_IN_PERCENTAGE ((0.0625)*(SCREEN_WIDTH))
#define CONTENT_SPACE_IN_PERCENTAGE ((0.25)*(SCREEN_WIDTH))

#pragma mark - Create Cell Method
-(void)createCellLayoutWithParams:(BOOL)isTimeoffSickRow
                    timeOffString:(NSString *)timeOffString
                 upperrightString:(NSString *)upperrightString
                      commentsStr:(NSString *)commentsStr
            commentsImageRequired:(BOOL )isCommentsImageRequired
                lastUsedTextField:(UITextField *)lastUsedTextField
                         udfArray:(NSMutableArray *)tmpUdfArray
                              tag:(NSInteger)tag
                   startButtonTag:(int)startButtonTag
                     inTimeString:(NSString *)inTimeString
                    outTimeString:(NSString *)outTimeString
                        isTimeoff:(BOOL)isTimeoff
                    withEditState:(BOOL)canEdit
                     withDataDict:(NSMutableDictionary *)heightDict
                     withDelegate:(id)_delegate
                withTsEntryObject:(TimesheetEntryObject *)tsEntryObject


{
    self.timeEntryComments=commentsStr;

    float cellHeight=[[heightDict objectForKey:CELL_HEIGHT_KEY] newFloatValue];

    UIImage *lowerImage = [Util thumbnailImage:Cell_HairLine_Image];
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,0, SCREEN_WIDTH,lowerImage.size.height)];
    [lineImageView setImage:lowerImage];
    [self.contentView bringSubviewToFront:lineImageView];
    [self.contentView addSubview:lineImageView];
    BOOL isSingleLine=NO;
    BOOL isTwoLine=NO;
    BOOL isThreeLine=NO;
    NSString *line=[heightDict objectForKey:LINE];
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
    float height=[[heightDict objectForKey:CELL_HEIGHT_KEY] newFloatValue];

    if (isTimeoffSickRow)
    {
        if (upperLeft == nil)
        {
            UILabel *tempupperLeft = [[UILabel alloc] init];
            self.upperLeft=tempupperLeft;

        }

        self.upperLeft.frame=CGRectMake(PADDING_SPACE,0, LABEL_WIDTH_WITH_COMMENTS, cellHeight);
        [upperLeft setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];
        [upperLeft setText:timeOffString];
        [upperLeft setNumberOfLines:100];
        [self.contentView addSubview:upperLeft];

        if (canEdit)
        {
            UIImageView *imageView=[[UIImageView alloc]initWithFrame:CGRectMake(229, 0, 1, cellHeight)];
            UIImage *verticalImage=[Util thumbnailImage:VERTICAL_SEPARATOR_IMAGE];
            [verticalImage resizableImageWithCapInsets:UIEdgeInsetsMake(1, 0, cellHeight,0)];
            [imageView setBackgroundColor:[UIColor colorWithPatternImage:verticalImage]];
            [self.contentView addSubview:imageView];
            if (self.upperRight == nil)
            {
                UITextField *tempupperRight = [[UITextField alloc] initWithFrame:CGRectMake(230.0,2, HOURS_WIDTH, cellHeight-2)];
                self.upperRight=tempupperRight;

            }
            [self.upperRight setFrame:CGRectMake(280.0, 0, HOURS_WIDTH, cellHeight)];
            [self.upperRight setBackgroundColor:[UIColor whiteColor]];
            [self.upperRight setText:upperrightString];
            [self.upperRight setTextAlignment:NSTextAlignmentRight];
            [self.upperRight setFont:[UIFont fontWithName:RepliconFontFamilySemiBold size:RepliconFontSize_16]];
            [self.upperRight setTextColor:RepliconStandardBlackColor];
            self.upperRight.delegate=self;
            self.upperRight.keyboardType = UIKeyboardTypeNumberPad;
            self.upperRight.returnKeyType = UIReturnKeyDone;
            self.upperRight.keyboardAppearance=UIKeyboardAppearanceDark;
            self.upperRight.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            self.upperRight.layer.sublayerTransform = CATransform3DMakeTranslation(-5,0, 0);
            [self.contentView addSubview:self.upperRight];
            [self.contentView bringSubviewToFront:self.upperRight];
            [self.upperRight setTag:tag];



        }
        else
        {
            UILabel *tempupperRight = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - HOURS_WIDTH - PADDING_SPACE,0, HOURS_WIDTH, cellHeight)];
            [tempupperRight setFont:[UIFont fontWithName:RepliconFontFamilySemiBold size:RepliconFontSize_16]];
            [tempupperRight setTextAlignment:NSTextAlignmentRight];
            [tempupperRight setText:upperrightString];
            [self.contentView addSubview:tempupperRight];

        }


        self.udfArray=tmpUdfArray;
        NSMutableArray *commentsImageColorStatusArray=[NSMutableArray array];
        LoginModel *loginModel=[[LoginModel alloc]init];
        NSMutableArray *requiredUdfArray=[loginModel getRequiredOnlyUDFsforModuleName:TIMESHEET_CELL_UDF];
        if ([[tsEntryObject entryType] isEqualToString:Time_Off_Key]||[[tsEntryObject entryType] isEqualToString:Adhoc_Time_OffKey])
        {
            requiredUdfArray=[loginModel getRequiredOnlyUDFsforModuleName:TIMEOFF_UDF];
        }
        else
        {
            requiredUdfArray=[loginModel getRequiredOnlyUDFsforModuleName:TIMESHEET_CELL_UDF];
        }
        if ([[tsEntryObject entryType] isEqualToString:Time_Off_Key])
        {
            for (int k=0; k<[self.udfArray count]; k++)
            {
                EntryCellDetails *udfDetails=(EntryCellDetails *)[self.udfArray objectAtIndex:k];
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

                for (int k=0; k<[self.udfArray count]; k++)
                {
                    EntryCellDetails *udfDetails=(EntryCellDetails *)[self.udfArray objectAtIndex:k];

                    BOOL isUdfMandatory=NO;
                    if ([[tsEntryObject entryType] isEqualToString:Time_Off_Key]||[[tsEntryObject entryType] isEqualToString:Adhoc_Time_OffKey])
                    {
                        isUdfMandatory=[loginModel getMandatoryStatusforUDFWithIdentity:[udfDetails udfIdentity] forModuleName:TIMEOFF_UDF];
                    }
                    else
                    {
                        isUdfMandatory=[loginModel getMandatoryStatusforUDFWithIdentity:[udfDetails udfIdentity] forModuleName:TIMESHEET_CELL_UDF];
                    }
                    if (isUdfMandatory)
                    {
                        NSString *udfValue=[udfDetails fieldValue];
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
                for (int k=0; k<[self.udfArray count]; k++)
                {
                    EntryCellDetails *udfDetails=(EntryCellDetails *)[self.udfArray objectAtIndex:k];
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

        }

        NSString *comments=timeEntryComments;
        NSMutableArray *commentsImageColorStatusArrayForComments=[NSMutableArray array];
        BOOL ifCommentsMandatory=NO;
        NSMutableArray *daySummaryArray=nil;
        if (approvalsModuleName==nil||[approvalsModuleName isKindOfClass:[NSNull class]]||[approvalsModuleName isEqualToString:@""])
        {
            TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
            daySummaryArray=[timesheetModel getAllTimesheetDaySummaryFromDBForTimesheet:timesheetUri];
        }
        else
        {
            ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
            if ([approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                daySummaryArray=[approvalsModel getAllPendingTimesheetDaySummaryFromDBForTimesheet:timesheetUri];
            }
            else
            {
                daySummaryArray=[approvalsModel getAllPreviousTimesheetDaySummaryFromDBForTimesheet:timesheetUri];
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
            commentsOrArrowImg=[UIImage imageNamed:@"icon_comments_red"];
        }
        else if ([commentsImageColorStatusArray containsObject:@"BLUE"]||[commentsImageColorStatusArrayForComments containsObject:@"BLUE"])
        {
            commentsOrArrowImg=[UIImage imageNamed:@"icon_comments_blue"];
        }
        else if ([commentsImageColorStatusArray containsObject:@"GRAY"]&&[commentsImageColorStatusArrayForComments containsObject:@"GRAY"])
        {
            commentsOrArrowImg=[UIImage imageNamed:@"icon_comments_gray"];
        }
        else
        {
            LoginModel *loginModel=[[LoginModel alloc]init];
            NSMutableArray *requiredUdfArray=[loginModel getRequiredOnlyUDFsforModuleName:TIMESHEET_CELL_UDF];
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



        if (commentsIcon == nil)
        {
            UIImageView *templineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(LABEL_WIDTH_WITH_COMMENTS+10, 10, commentsOrArrowImg.size.width,commentsOrArrowImg.size.height)];
            self.commentsIcon=templineImageView;

        }
        if (isSingleLine)
        {
            [commentsIcon setFrame:CGRectMake(LABEL_WIDTH_WITH_COMMENTS+10, (height-commentsOrArrowImg.size.height)/2, commentsOrArrowImg.size.width,commentsOrArrowImg.size.height)];
        }
        else
        {
            [commentsIcon setFrame:CGRectMake(LABEL_WIDTH_WITH_COMMENTS+10, 10, commentsOrArrowImg.size.width,commentsOrArrowImg.size.height)];
        }

        [commentsIcon setImage:commentsOrArrowImg];
        [self.contentView addSubview:commentsIcon];



    }
    else
    {

        if (upperRightInOutLabel == nil)
        {
            UILabel *tempupperLeft = [[UILabel alloc] init];
            self.upperRightInOutLabel=tempupperLeft;

        }
        self.upperRightInOutLabel.frame=CGRectMake((PADDING_SPACE_IN_PERCENTAGE*3) + (CONTENT_SPACE_IN_PERCENTAGE*2), 15, CONTENT_SPACE_IN_PERCENTAGE, 25.0);
        [upperRightInOutLabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_14]];
        [upperRightInOutLabel setTextAlignment:NSTextAlignmentCenter];
        [upperRightInOutLabel setText:upperrightString];
        [self.contentView addSubview:upperRightInOutLabel];

        UIImage *offImage =[Util thumbnailImage:IN_OUT_BUTTON_OFF_IMAGE];
        UIImage *onImage  =[Util thumbnailImage:IN_OUT_BUTTON_ON_IMAGE];
        UIButton *tmpInTimeButton=[UIButton buttonWithType:UIButtonTypeCustom];
        self.inTimeButton=tmpInTimeButton;

        [inTimeButton setFrame:CGRectMake(PADDING_SPACE_IN_PERCENTAGE, 12.0, CONTENT_SPACE_IN_PERCENTAGE, 30.0)];
        if ([_delegate isKindOfClass:[MultiDayInOutViewController class]])
        {
            MultiDayInOutViewController *currentTimesheetCtrl=(MultiDayInOutViewController *)_delegate;
            //Implemented for InOut BUTTON UI CHANGE As Per TimeEntry Status
            if (canEdit)
            {
                if (tag*2==[currentTimesheetCtrl selectedButtonTag])
                {
                    [inTimeButton setBackgroundImage:onImage forState:UIControlStateNormal];
                    [inTimeButton setBackgroundImage:onImage forState:UIControlStateHighlighted];
                }
                else
                {
                    [inTimeButton setBackgroundImage:offImage forState:UIControlStateNormal];
                    [inTimeButton setBackgroundImage:onImage forState:UIControlStateHighlighted];
                }
            }
            else{
                [inTimeButton setBackgroundImage:nil forState:UIControlStateNormal];
            }

        }
        [inTimeButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_14]];
        if (inTimeString==nil||[inTimeString isKindOfClass:[NSNull class]]||[inTimeString isEqualToString:@""])
        {
            [inTimeButton setTitle:RPLocalizedString(In_Time, @"")  forState:UIControlStateNormal];
        }
        else
        {
            [inTimeButton setTitle:inTimeString  forState:UIControlStateNormal];
        }

        [inTimeButton addTarget:self action:@selector(inButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [inTimeButton setTitleColor:RepliconStandardBlackColor forState:UIControlStateNormal];
        [inTimeButton setTag:tag*2];
        [self.contentView addSubview:self.inTimeButton];

        UIButton *tmpOutTimeButton=[UIButton buttonWithType:UIButtonTypeCustom];
        self.outTimeButton=tmpOutTimeButton;

        [outTimeButton setFrame:CGRectMake(self.inTimeButton.frame.origin.x+self.inTimeButton.frame.size.width+PADDING_SPACE_IN_PERCENTAGE, 12.0, CONTENT_SPACE_IN_PERCENTAGE, 30.0)];
        if ([_delegate isKindOfClass:[MultiDayInOutViewController class]])
        {
            MultiDayInOutViewController *currentTimesheetCtrl=(MultiDayInOutViewController *)_delegate;
            //Implemented for InOut BUTTON UI CHANGE As Per TimeEntry Status
            if (canEdit)
            {
                if (tag*2+1==[currentTimesheetCtrl selectedButtonTag])
                {
                    [outTimeButton setBackgroundImage:onImage forState:UIControlStateNormal];
                    [outTimeButton setBackgroundImage:onImage forState:UIControlStateHighlighted];
                }
                else
                {
                    [outTimeButton setBackgroundImage:offImage forState:UIControlStateNormal];
                    [outTimeButton setBackgroundImage:onImage forState:UIControlStateHighlighted];
                }
            }
            else{
                [outTimeButton setBackgroundImage:nil forState:UIControlStateNormal];
            }

        }


        [outTimeButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_14]];

        if (outTimeString==nil||[outTimeString isKindOfClass:[NSNull class]]||[outTimeString isEqualToString:@""])
        {
            [outTimeButton setTitle:RPLocalizedString(Out_Time, @"")  forState:UIControlStateNormal];
        }
        else
        {
            [outTimeButton setTitle:outTimeString  forState:UIControlStateNormal];
        }
        [outTimeButton addTarget:self action:@selector(outButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [outTimeButton setTitleColor:RepliconStandardBlackColor forState:UIControlStateNormal];
        [outTimeButton setTag:tag*2+1];
        [self.contentView addSubview:self.outTimeButton];

    }

    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.contentView.bounds) - 1, SCREEN_WIDTH, 1)];
    separatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    separatorView.backgroundColor = [Util colorWithHex:@"#CCCCCC" alpha:1.0f];
    [self.contentView addSubview:separatorView];

    [self.contentView setTag:tag];

}

#pragma mark - Textfield Delegates

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
    {

        MultiDayInOutViewController *currentTimesheetCtrl=(MultiDayInOutViewController *)delegate;
        [currentTimesheetCtrl handleButtonClick:[currentTimesheetCtrl selectedIndexPath]];
        NSInteger noOfRows=[[currentTimesheetCtrl multiDayTimeEntryTableView] numberOfRowsInSection:0];

        for (int row=0; row<noOfRows; row++)
        {
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:row inSection:0];
            MultiDayInOutTimeEntryCustomCell *selectedCell = (MultiDayInOutTimeEntryCustomCell *)[[currentTimesheetCtrl multiDayTimeEntryTableView] cellForRowAtIndexPath:indexPath];
            if ([selectedCell tag]==INOUT_CELL_TAG)
            {
                for (UIView *view in selectedCell.contentView.subviews)
                {
                    if ([view isKindOfClass:[UIButton class]])
                    {
                        UIButton *btn=(UIButton *)view;
                        if (btn.tag!=Entry_Button_Tag) {
                            [btn setBackgroundImage:[Util thumbnailImage:IN_OUT_BUTTON_OFF_IMAGE] forState:UIControlStateNormal];
                        }

                    }

                }
            }

        }
        if ([textField.text isEqualToString:@"0.00"])
        {
            [textField setText:@""];
        }

    }
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
    {
        MultiDayInOutViewController *currentTimesheetCtrl=(MultiDayInOutViewController *)delegate;
        NSInteger noOfRows=[[currentTimesheetCtrl multiDayTimeEntryTableView] numberOfRowsInSection:0];
        [currentTimesheetCtrl setLastUsedTextField:textField];
        [currentTimesheetCtrl setIsTextFieldClicked:YES];
        [currentTimesheetCtrl setIsUDFieldClicked:NO];
        if (currentTimesheetCtrl.isInOutBtnClicked)
        {
            //Implemented For overlappingTimeEntriesPermitted Permission
            if (!currentTimesheetCtrl.isOverlapEntryAllowed) {
                [currentTimesheetCtrl checkOverlapForPage];
            }

            if (currentTimesheetCtrl.isOverlap)
            {
                for (int row=0; row<noOfRows; row++)
                {
                    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:row inSection:0];
                    MultiDayInOutTimeEntryCustomCell *selectedCell = (MultiDayInOutTimeEntryCustomCell *)[[currentTimesheetCtrl multiDayTimeEntryTableView] cellForRowAtIndexPath:indexPath];

                    for (UIView *view in selectedCell.contentView.subviews)
                    {
                        if ([view isKindOfClass:[UIButton class]])
                        {
                            UIButton *btn=(UIButton *)view;
                            if ([btn tag]==currentTimesheetCtrl.selectedButtonTag)
                            {
                                NSString *btnTitle=btn.titleLabel.text;
                                if (![btnTitle isEqualToString:RPLocalizedString(In_Time, In_Time)]&& ![btnTitle isEqualToString:RPLocalizedString(Out_Time, Out_Time)])
                                {
                                    NSRange replaceRangeMM = [btnTitle rangeOfString:@"mm"];
                                    NSRange replaceRangeHH = [btnTitle rangeOfString:@"hh"];
                                    if ((replaceRangeMM.location != NSNotFound||replaceRangeHH.location != NSNotFound) && btnTitle!=nil)
                                    {
                                        //Ullas removed for multi inout changes.To revert back if required
                                        //[Util errorAlert:RPLocalizedString(Please_enter_valid_time_Message, @"") errorMessage:@""];
                                        [btn setBackgroundImage:[Util thumbnailImage:IN_OUT_BUTTON_ON_IMAGE] forState:UIControlStateNormal];
                                        currentTimesheetCtrl.selectedButtonTag=[btn tag];

                                    }
                                    else{

                                        [btn setBackgroundImage:[Util thumbnailImage:IN_OUT_BUTTON_ON_IMAGE] forState:UIControlStateNormal];

                                        currentTimesheetCtrl.selectedButtonTag=[btn tag];
                                    }
                                }

                            }
                        }

                    }
                }
                return NO;
            }
            //Ullas added for multi inout changes.To revert back if required
            else
            {
                for (int row=0; row<noOfRows; row++)
                {
                    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:row inSection:0];
                    MultiDayInOutTimeEntryCustomCell *selectedCell = (MultiDayInOutTimeEntryCustomCell *)[[currentTimesheetCtrl multiDayTimeEntryTableView] cellForRowAtIndexPath:indexPath];

                    for (UIView *view in selectedCell.contentView.subviews)
                    {
                        if ([view isKindOfClass:[UIButton class]])
                        {
                            UIButton *btn=(UIButton *)view;
                            if ([btn tag]==currentTimesheetCtrl.selectedButtonTag)
                            {
                                NSString *btnTitle=btn.titleLabel.text;
                                if (![btnTitle isEqualToString:RPLocalizedString(In_Time, In_Time)]&& ![btnTitle isEqualToString:RPLocalizedString(Out_Time, Out_Time)])
                                {
                                    NSRange replaceRangeMM = [btnTitle rangeOfString:@"mm"];
                                    NSRange replaceRangeHH = [btnTitle rangeOfString:@"hh"];
                                    NSString *tempHrsStr=@"";
                                    NSString *tempMinsStr=@"";
                                    NSString *tempFormatStr=@"";
                                    NSArray *timeCompsArr=[btnTitle componentsSeparatedByString:@":"];
                                    if ([timeCompsArr count]==2)
                                    {
                                        tempHrsStr=[NSString stringWithFormat:@"%@",[timeCompsArr objectAtIndex:0]];

                                        NSArray *amPmCompsArr=[[timeCompsArr objectAtIndex:1] componentsSeparatedByString:@" "];
                                        if ([amPmCompsArr count]==2)
                                        {
                                            tempMinsStr=[NSString stringWithFormat:@"%@",[amPmCompsArr objectAtIndex:0]];
                                            tempFormatStr=[NSString stringWithFormat:@"%@",[amPmCompsArr objectAtIndex:1]];

                                        }
                                    }

                                    if (replaceRangeMM.location != NSNotFound)
                                    {
                                        tempMinsStr=@"00";
                                    }
                                    if (replaceRangeHH.location != NSNotFound)
                                    {
                                        tempHrsStr=@"12";
                                        tempFormatStr=@"am";
                                    }
                                    NSString *tempTimeString=[NSString stringWithFormat:@"%@:%@ %@",tempHrsStr,tempMinsStr,tempFormatStr];
                                    [btn setTitle:[NSString stringWithFormat:@"%@",tempTimeString] forState:UIControlStateNormal];
                                    TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[currentTimesheetCtrl.timesheetEntryObjectArray objectAtIndex:currentTimesheetCtrl.currentSelectedButtonRow];
                                    NSString *inTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"in_time"];
                                    NSString *outTimeString=[[tsEntryObject multiDayInOutEntry] objectForKey:@"out_time"];

                                    if ([inTimeString isEqualToString:tempTimeString]&&[outTimeString isEqualToString:tempTimeString])
                                    {

                                    }
                                    else
                                    {
                                        NSMutableDictionary *entryDict=[tsEntryObject multiDayInOutEntry];
                                        if ([btn tag]%2==0)
                                        {

                                            [entryDict setObject:tempTimeString forKey:@"in_time"];
                                        }
                                        else
                                        {
                                            [entryDict setObject:tempTimeString forKey:@"out_time"];

                                        }

                                        [currentTimesheetCtrl updateMultiDayTimeEntryForIndex:currentTimesheetCtrl.currentSelectedButtonRow withValue:entryDict];

                                    }
                                }


                            }
                        }

                    }
                }
            }
        }

        NSIndexPath *indexPath=nil;
        if (currentTimesheetCtrl.multiInOutTimesheetType==EXTENDED_IN_OUT_TIMESHEET_TYPE)
        {
            indexPath=[NSIndexPath indexPathForRow:0 inSection:textField.tag];
        }
        else
        {
            indexPath=[NSIndexPath indexPathForRow:textField.tag inSection:0];

        }
        if (!self.numberKeyPad)
        {
            self.numberKeyPad.isDonePressed=NO;
            self.numberKeyPad = [NumberKeypadDecimalPoint keypadForTextField:textField withDelegate:delegate withMinus:NO andisDoneShown:NO withResignButton:NO];
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
        [currentTimesheetCtrl resetTableSize:YES isTextFieldOrTextViewClicked:YES isUdfClicked:NO];
        [[currentTimesheetCtrl multiDayTimeEntryTableView] scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        [[currentTimesheetCtrl multiDayTimeEntryTableView] setScrollEnabled:YES];


    }

    return YES;


}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField textAlignment] == NSTextAlignmentCenter) {
        [Util updateCenterAlignedTextField:textField withString:string withRange:range withDecimalPlaces:DecimalPlaces];
        if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
        {
            MultiDayInOutViewController *currentTimesheetCtrl=(MultiDayInOutViewController *)delegate;
            [currentTimesheetCtrl updateTimeEntryHoursForIndex:textField.tag withValue:textField.text withoutRoundOffValue:textField.text isDoneClicked:NO];
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
            if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
            {
                MultiDayInOutViewController *currentTimesheetCtrl=(MultiDayInOutViewController *)delegate;
                [currentTimesheetCtrl resetTableSize:NO isTextFieldOrTextViewClicked:YES isUdfClicked:NO];


            }
            numberKeyPad.isDonePressed=NO;

        }
        self.numberKeyPad = nil;

    }

    if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
    {
        MultiDayInOutViewController *currentTimesheetCtrl=(MultiDayInOutViewController *)delegate;

        [currentTimesheetCtrl updateTimeEntryHoursForIndex:textField.tag withValue:textField.text withoutRoundOffValue:textField.text  isDoneClicked:YES];
        [currentTimesheetCtrl.toolbar setHidden:YES];


    }

    [self setSelected:NO animated:NO];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - Other Methods

-(void)inButtonAction:(id)sender
{
    BOOL isKeyBoardLaunchedSuccessful=NO;
    NSInteger row = [sender superview].tag;
    if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
    {
        MultiDayInOutViewController *currentTimesheetCtrl=(MultiDayInOutViewController *)delegate;
        NSInteger noOfRows=[[currentTimesheetCtrl multiDayTimeEntryTableView] numberOfRowsInSection:0];

        for (int row=0; row<noOfRows; row++)
        {
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:row inSection:0];
            MultiDayInOutTimeEntryCustomCell *selectedCell = (MultiDayInOutTimeEntryCustomCell *)[[currentTimesheetCtrl multiDayTimeEntryTableView] cellForRowAtIndexPath:indexPath];

            for (UIView *view in selectedCell.contentView.subviews)
            {
                if ([view isKindOfClass:[UIButton class]])
                {
                    UIButton *btn=(UIButton *)view;
                    if (btn.tag!=Entry_Button_Tag) {
                        [btn setBackgroundImage:[Util thumbnailImage:IN_OUT_BUTTON_OFF_IMAGE] forState:UIControlStateNormal];
                    }

                }

            }
        }
        if ([currentTimesheetCtrl isTableRowSelected])
        {
            [currentTimesheetCtrl tableView:[currentTimesheetCtrl multiDayTimeEntryTableView] didSelectRowAtIndexPath:[currentTimesheetCtrl currentIndexpath]];
        }

        isKeyBoardLaunchedSuccessful=[currentTimesheetCtrl launchMultiInOutTimeEntryKeyBoard:(id)sender withRowClicked:row];
        if (isKeyBoardLaunchedSuccessful)
        {
            [currentTimesheetCtrl setSelectedButtonTag:[sender tag]];
            [currentTimesheetCtrl setTimeString:[[sender titleLabel] text]];
            [sender setBackgroundImage:[Util thumbnailImage:IN_OUT_BUTTON_ON_IMAGE] forState:UIControlStateNormal];
        }


    }



}
-(void)outButtonAction:(id)sender
{
    BOOL isKeyBoardLaunchedSuccessful=NO;
    NSInteger row = [sender superview].tag;
    if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
    {
        MultiDayInOutViewController *currentTimesheetCtrl=(MultiDayInOutViewController *)delegate;
        NSInteger noOfRows=[[currentTimesheetCtrl multiDayTimeEntryTableView] numberOfRowsInSection:0];

        for (int row=0; row<noOfRows; row++)
        {
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:row inSection:0];
            MultiDayInOutTimeEntryCustomCell *selectedCell = (MultiDayInOutTimeEntryCustomCell *)[[currentTimesheetCtrl multiDayTimeEntryTableView] cellForRowAtIndexPath:indexPath];

            for (UIView *view in selectedCell.contentView.subviews)
            {
                if ([view isKindOfClass:[UIButton class]])
                {
                    UIButton *btn=(UIButton *)view;
                    if (btn.tag!=Entry_Button_Tag)
                    {
                        [btn setBackgroundImage:[Util thumbnailImage:IN_OUT_BUTTON_OFF_IMAGE] forState:UIControlStateNormal];
                    }

                }

            }
        }
        if ([currentTimesheetCtrl isTableRowSelected])
        {
            [currentTimesheetCtrl tableView:[currentTimesheetCtrl multiDayTimeEntryTableView] didSelectRowAtIndexPath:[currentTimesheetCtrl currentIndexpath]];
        }

        isKeyBoardLaunchedSuccessful=[currentTimesheetCtrl launchMultiInOutTimeEntryKeyBoard:(id)sender withRowClicked:row];

        if (isKeyBoardLaunchedSuccessful)
        {
            [currentTimesheetCtrl setSelectedButtonTag:[sender tag]];
            [currentTimesheetCtrl setTimeString:[[sender titleLabel] text]];
            [sender setBackgroundImage:[Util thumbnailImage:IN_OUT_BUTTON_ON_IMAGE] forState:UIControlStateNormal];
        }
    }


}
-(void)doneClicked
{

    if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
    {
        MultiDayInOutViewController *currentTimesheetCtrl=(MultiDayInOutViewController *)delegate;
        [currentTimesheetCtrl setIsTextFieldClicked:NO];
        [currentTimesheetCtrl setIsUDFieldClicked:NO];
        [currentTimesheetCtrl resetTableSize:NO isTextFieldOrTextViewClicked:NO isUdfClicked:NO];
        [currentTimesheetCtrl.lastUsedTextField resignFirstResponder];
        [currentTimesheetCtrl.lastUsedTextView resignFirstResponder];
    }
    self.datePicker.hidden=YES;
    self.toolBar.hidden=YES;
    
}


@end
