//
//  PunchHistoryCustomCell.m
//  NextGenRepliconTimeSheet
//
//  Created by Prashant Shukla on 06/02/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "PunchHistoryCustomCell.h"
#import "Constants.h"
#import <CoreText/CoreText.h>


@implementation PunchHistoryCustomCell
@synthesize tsEntryObject;
@synthesize isProjectAccess;
@synthesize isActivityAccess;
@synthesize isBillingAccess;
@synthesize isBreakAccess;
@synthesize delegate;


#define LINE @"LINE"
#define LABEL_WIDTH 260.0
#define CELL_HEIGHT_KEY @"CELL-HEIGHT"
#define UPPER_LABEL_HEIGHT @"FIRST_LABEL_HEIGHT"
#define MIDDLE_LABEL_HEIGHT @"SECOND_LABEL-HEIGHT"
#define LOWER_LABEL_HEIGHT @"THIRD_LABEL-HEIGHT"
#define UPPER_LABEL_STRING @"UPPER_LABEL_STRING"
#define MIDDLE_LABEL_STRING @"MIDDLE_LABEL_STRING"
#define LOWER_LABEL_STRING @"LOWER_LABEL_STRING"

#define UPPER_LABEL_TEXT_WRAP @"UPPER_LABEL_TEXT_WRAP"
#define MIDDLE_LABEL_TEXT_WRAP @"MIDDLE_LABEL_TEXT_WRAP"
#define LOWER_LABEL_TEXT_WRAP @"LOWER_LABEL_TEXT_WRAP"





- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


-(void)createCellLayoutWithParams : (BOOL)isExtended  isProjectAccess:(BOOL)ProjectAccess isActivityAccess:(BOOL)ActivityAccess isBillingAccess:(BOOL)BillingAccess  isBreakAccess:(BOOL)isBreaksAccess row:(NSInteger)row data:(NSMutableDictionary*)data isStartBtnEnabled:(BOOL)isStartBtnEnabled
{
    
    self.isBillingAccess = BillingAccess;
    self.isProjectAccess = ProjectAccess;
    self.isActivityAccess = ActivityAccess;
    self.isBreakAccess=isBreaksAccess;
    self.tsEntryObject = [[TimesheetEntryObject alloc] init];
    [tsEntryObject setTimeEntryTaskName:[data objectForKey:@"task"]];
    [tsEntryObject setTimeEntryProjectName:[data objectForKey:@"project"]];
    [tsEntryObject setTimeEntryActivityName:[data objectForKey:@"activity"]];
    [tsEntryObject setTimeEntryClientName:[data objectForKey:@"client"]];
    [tsEntryObject setTimeEntryBillingName:@""];
    [tsEntryObject setBreakName:[data objectForKey:@"break"]];
    NSString *inTimestr=[data objectForKey:@"in_time_stamp"];
    NSString *outTimestr=[data objectForKey:@"out_time_stamp"];
    
    NSDate *inDate=[Util convertTimestampFromDBToDate:inTimestr];
    NSDate *outDate=[Util convertTimestampFromDBToDate:outTimestr];
    
    BOOL isYesterdayLabelShow=NO;
    BOOL isYesterday=NO;
    //
    
    if ([inDate compare:outDate] == NSOrderedAscending)
    {
        
        
        NSDateComponents *components1 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:inDate];
        NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:outDate];
        if ([components1 year]<[components2 year])
        {
            isYesterday=NO;
            isYesterdayLabelShow=YES;
        }
        else if ([components1 month]<[components2 month])
        {
            isYesterday=NO;
            isYesterdayLabelShow=YES;
        }
        else if ([components1 day]<[components2 day])
        {
            NSInteger diffDays=[components2 day]-[components1 day];
            if (diffDays==1)
            {
                isYesterday=YES;
                isYesterdayLabelShow=YES;
            }
            else if (diffDays>1)
            {
                isYesterday=NO;
                isYesterdayLabelShow=YES;
            }
            else if (diffDays==0)
            {
                isYesterday=NO;
                isYesterdayLabelShow=NO;
            }
            
        }
    }
    
    NSString *inTime=[data objectForKey:@"in_time"];
    NSString *outTime=[data objectForKey:@"out_time"];
    
    NSString *hrstr=@"";
    NSString *minsStr=@"";
    NSString *inAmPmStr=@"";
    NSString *outAmPmStr=@"";
    NSArray *timeInCompsArr=[inTime componentsSeparatedByString:@":"];
    if ([timeInCompsArr count]==2)
    {
        hrstr=[timeInCompsArr objectAtIndex:0];
        if ([hrstr intValue]==0) {
            hrstr=@"12";
        }
        NSArray *minsamPmCompsArr=[[timeInCompsArr objectAtIndex:1] componentsSeparatedByString:@" "];
        if ([minsamPmCompsArr count]==2)
        {
            minsStr=[minsamPmCompsArr objectAtIndex:0];
            NSString *ampmStr=[minsamPmCompsArr objectAtIndex:1];
            inAmPmStr=[ampmStr uppercaseString];
        }
    }
    
    BOOL isInTimeAMPMImageShow=NO;
    NSString *startTimeStr=@"";
    if ([timeInCompsArr count]==0||[inTime isKindOfClass:[NSNull class]]||inTime==nil||[inTime isEqualToString:@""])
    {
        startTimeStr=[NSString stringWithFormat:@"IN"];
    }
    else
    {
        isInTimeAMPMImageShow=YES;
        startTimeStr=[NSString stringWithFormat:@"%@:%@",hrstr,minsStr];
    }
    
    
    
    NSString *outhrstr=@"";
    NSString *outminsStr=@"";
    NSArray *timeOutCompsArr=[outTime componentsSeparatedByString:@":"];
    if ([timeOutCompsArr count]==2)
    {
        outhrstr=[timeOutCompsArr objectAtIndex:0];
        if ([outhrstr intValue]==0) {
            outhrstr=@"12";
        }
        NSArray *minsamPmCompsArr=[[timeOutCompsArr objectAtIndex:1] componentsSeparatedByString:@" "];
        if ([minsamPmCompsArr count]==2)
        {
            outminsStr=[minsamPmCompsArr objectAtIndex:0];
            NSString *ampmStr=[minsamPmCompsArr objectAtIndex:1];
            outAmPmStr=[ampmStr uppercaseString];
        }
    }
    BOOL isOutTimeAMPMImageShow=NO;
    NSString *endTimeStr=@"";
    if ([timeOutCompsArr count]==0||[outTime isKindOfClass:[NSNull class]]||outTime==nil||[outTime isEqualToString:@""])
    {
        endTimeStr=[NSString stringWithFormat:@"OUT"];
    }
    else
    {
        isOutTimeAMPMImageShow=YES;
        endTimeStr=[NSString stringWithFormat:@"%@:%@",outhrstr,outminsStr];
    }
    UIView *viewHeader=[self projectViewHeader];
    UIImage *timeEntryViewImage = [Util thumbnailImage:IN_OUT_ENTRY_BACKGROUND_IMAGE];
    UIImageView *tempprojectAndInOutEntryBGView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, viewHeader.frame.size.height+timeEntryViewImage.size.height+15)];
    [tempprojectAndInOutEntryBGView setBackgroundColor:[Util colorWithHex:@"#E2E2E2" alpha:1.0]];
    
    
    
    [tempprojectAndInOutEntryBGView addSubview:viewHeader];
    
    UIImageView *inOutEntryBGView = [[UIImageView alloc] initWithFrame:CGRectMake(10, viewHeader.frame.size.height, timeEntryViewImage.size.width, timeEntryViewImage.size.height)];
    [inOutEntryBGView setImage:timeEntryViewImage];
    [inOutEntryBGView setBackgroundColor:[UIColor clearColor]];
    
    float xOffset=8.0;
    float yOffset = 7;
    float _timeInHoursWidth=50+xOffset;
    UILabel *_timeInHours = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, 0, _timeInHoursWidth, timeEntryViewImage.size.height)];
    _timeInHours.backgroundColor = [UIColor clearColor];
    _timeInHours.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16];
    _timeInHours.textAlignment = NSTextAlignmentRight;
    if (isInTimeAMPMImageShow)
    {
        _timeInHours.textAlignment = NSTextAlignmentLeft;
    }
    else
    {
        CGRect _lblFrame=_timeInHours.frame;
        _lblFrame.origin.x=_timeInHours.frame.origin.x;
        [_timeInHours setFrame:_lblFrame];
    }
    _timeInHours.userInteractionEnabled=NO;
    _timeInHours.text=startTimeStr;
    [inOutEntryBGView addSubview:_timeInHours];
    
    
    
    if (isYesterdayLabelShow)
    {
        
        UILabel *_timeInYesterdayLbl = [[UILabel alloc] initWithFrame:CGRectMake(xOffset+2, _timeInHours.frame.size.height-10, 100, timeEntryViewImage.size.height)];
        _timeInYesterdayLbl.backgroundColor = [UIColor clearColor];
        _timeInYesterdayLbl.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12];
        _timeInYesterdayLbl.textAlignment = NSTextAlignmentLeft;
        _timeInYesterdayLbl.userInteractionEnabled=NO;
        if (isYesterday)
        {
            _timeInYesterdayLbl.text=RPLocalizedString(YESTERDAY_STRING, @"");
        }
        else
        {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateStyle = NSDateFormatterMediumStyle;
            [df setDateFormat:@"MMM dd, yyyy"];
            [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            
            NSLocale *locale=[NSLocale currentLocale];
            [df setLocale:locale];
            NSString *dateStr=[df stringFromDate:inDate];
            _timeInYesterdayLbl.text=dateStr;
            
        }
        
        [inOutEntryBGView addSubview:_timeInYesterdayLbl];
    }
    
    
    
    if (isInTimeAMPMImageShow)
    {
        UIImage *amImage=nil;
        if ([inAmPmStr isEqualToString:@"AM"])
        {
            amImage = [Util thumbnailImage:AM_BACKGROUND_IMAGE];
        }
        else
        {
            amImage = [Util thumbnailImage:PM_BACKGROUND_IMAGE];
        }
        
        UIButton *timeInAmPMButton = [[UIButton alloc] initWithFrame:CGRectMake(_timeInHoursWidth, (timeEntryViewImage.size.height-amImage.size.height)/2, amImage.size.width, amImage.size.height)];
        timeInAmPMButton.backgroundColor = [UIColor clearColor];
        timeInAmPMButton.titleLabel.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12];
        timeInAmPMButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        timeInAmPMButton.userInteractionEnabled=NO;
        [timeInAmPMButton setTitle:inAmPmStr forState:UIControlStateNormal];
        [timeInAmPMButton setBackgroundImage:amImage forState:UIControlStateNormal];
        [timeInAmPMButton setTitleColor:RepliconStandardBlackColor forState:UIControlStateNormal];
        [inOutEntryBGView addSubview:timeInAmPMButton];
        
    }
    
    
    float toLabelWidth=35;
    UILabel *toLabel = [[UILabel alloc] initWithFrame:CGRectMake(_timeInHoursWidth+toLabelWidth+05, 0, toLabelWidth, timeEntryViewImage.size.height)];
    toLabel.backgroundColor = [UIColor clearColor];
    toLabel.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16];
    [toLabel setTextColor:[Util colorWithHex:@"#cccccc" alpha:1.0]];
    toLabel.textAlignment = NSTextAlignmentCenter;
    if (!isInTimeAMPMImageShow && !isOutTimeAMPMImageShow)
    {
        CGRect _lblFrame=toLabel.frame;
        _lblFrame.origin.x=toLabel.frame.origin.x;
        [toLabel setFrame:_lblFrame];
    }
    else if (!isInTimeAMPMImageShow)
    {
        CGRect _lblFrame=toLabel.frame;
        _lblFrame.origin.x=toLabel.frame.origin.x-10;
        [toLabel setFrame:_lblFrame];
    }
    else if (!isOutTimeAMPMImageShow)
    {
        CGRect _lblFrame=toLabel.frame;
        _lblFrame.origin.x=toLabel.frame.origin.x+10;
        [toLabel setFrame:_lblFrame];
    }
    toLabel.userInteractionEnabled=NO;
    toLabel.text=RPLocalizedString(TO_STRING, @"");
    [inOutEntryBGView addSubview:toLabel];
    
    
    float offset=30;
    float _timeOutHoursWidth=60.0;
    UILabel *_timeOutHours = [[UILabel alloc] initWithFrame:CGRectMake(_timeInHoursWidth+toLabelWidth+offset, 0, _timeOutHoursWidth, timeEntryViewImage.size.height)];
    _timeOutHours.backgroundColor = [UIColor clearColor];
    _timeOutHours.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16];
    if (isOutTimeAMPMImageShow)
    {
        _timeOutHours.textAlignment = NSTextAlignmentCenter;
    }
    else
    {
        CGRect _lblFrame=_timeOutHours.frame;
        _lblFrame.origin.x=_timeOutHours.frame.origin.x+40;
        [_timeOutHours setFrame:_lblFrame];
    }
    
    _timeOutHours.userInteractionEnabled=NO;
    _timeOutHours.text=endTimeStr;
    [inOutEntryBGView addSubview:_timeOutHours];
    
    
    if (isOutTimeAMPMImageShow)
    {
        UIImage *pmImage = nil;
        if ([outAmPmStr isEqualToString:@"AM"])
        {
            pmImage = [Util thumbnailImage:AM_BACKGROUND_IMAGE];
        }
        else
        {
            pmImage = [Util thumbnailImage:PM_BACKGROUND_IMAGE];
        }
        
        UIButton *timeOutAmPMButton = [[UIButton alloc] initWithFrame:CGRectMake(_timeInHoursWidth+toLabelWidth+_timeOutHoursWidth+offset, (timeEntryViewImage.size.height-pmImage.size.height)/2, pmImage.size.width, pmImage.size.height)];
        timeOutAmPMButton.backgroundColor = [UIColor clearColor];
        timeOutAmPMButton.titleLabel.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12];
        timeOutAmPMButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        timeOutAmPMButton.userInteractionEnabled=NO;
        [timeOutAmPMButton setTitle:outAmPmStr forState:UIControlStateNormal];
        [timeOutAmPMButton setTitleColor:RepliconStandardBlackColor forState:UIControlStateNormal];
        [timeOutAmPMButton setBackgroundImage:pmImage forState:UIControlStateNormal];
        [inOutEntryBGView addSubview:timeOutAmPMButton];
        
    }
    
    
    NSDictionary *dict=[self getNumberOfHoursForInTime:[Util convertTimestampFromDBToDate:[data objectForKey:@"in_time_stamp"]] outTime:[Util convertTimestampFromDBToDate:[data objectForKey:@"out_time_stamp"]]];
    NSString *minutes = [dict objectForKey:@"minute"];
    NSString *hours = [dict objectForKey:@"hour"];
    
    
    UILabel  *currentHourLabel =  [[UILabel alloc] initWithFrame:CGRectMake(235, yOffset , 30 ,20.0)];
    currentHourLabel.text  = hours;
    currentHourLabel.textColor  = RepliconStandardBlackColor;
    currentHourLabel.backgroundColor=[UIColor clearColor];
    currentHourLabel.textAlignment=NSTextAlignmentRight;
    currentHourLabel.font=[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16];
    [inOutEntryBGView addSubview:currentHourLabel];
    
    UILabel  *currentColonLabel =  [[UILabel alloc] initWithFrame:CGRectMake(264, yOffset , 10 ,20.0)];
    currentColonLabel.text  = @":";
    currentColonLabel.textColor  = RepliconStandardBlackColor;
    currentColonLabel.backgroundColor=[UIColor clearColor];
    currentColonLabel.textAlignment=NSTextAlignmentCenter;
    currentColonLabel.font=[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16];
    [inOutEntryBGView addSubview:currentColonLabel];
    
    UILabel  *currentMinuteLabel =  [[UILabel alloc] initWithFrame:CGRectMake(274, yOffset , 20 ,20.0)];
    currentMinuteLabel.text  = minutes;
    currentMinuteLabel.textColor  = RepliconStandardBlackColor;
    currentMinuteLabel.backgroundColor=[UIColor clearColor];
    currentMinuteLabel.textAlignment=NSTextAlignmentCenter;
    currentMinuteLabel.font=[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16];
    [inOutEntryBGView addSubview:currentMinuteLabel];
    
    UIImage *startIconImage = [Util thumbnailImage:START_ICON_IMAGE];
    UIButton *startIconButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH -startIconImage.size.width -15, 14, startIconImage.size.width, startIconImage.size.height)];
    [startIconButton setBackgroundColor:[UIColor clearColor]];
    //[startIconButton setBackgroundImage:startIconImage forState:UIControlStateNormal];
    [startIconButton setImage:startIconImage forState:UIControlStateNormal];
    [startIconButton addTarget:self action:@selector(startIconButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [startIconButton setUserInteractionEnabled:YES];
    [startIconButton setTag:row];
    
    if (!isStartBtnEnabled) {
        [startIconButton setUserInteractionEnabled:NO];
    }
    if ([_timeOutHours.text  isEqualToString:RPLocalizedString(@"NOW", @"")]) {
        currentHourLabel.text = @"-";
        currentMinuteLabel.text = @"-";
    }
    inOutEntryBGView.backgroundColor=[UIColor clearColor];
    NSString *breakUri=[tsEntryObject breakName];
    BOOL isBreakRow=FALSE;
    if (breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]]&&![breakUri isEqualToString:@""])
    {
        isBreakRow=TRUE;
    }
    
    float yesterdayLabelOffset=0.0;
    if (isYesterdayLabelShow)
    {
        yesterdayLabelOffset=YESTERDAY_LABEL_OFFSET_HEIGHT;
        CGRect frame=tempprojectAndInOutEntryBGView.frame;
        frame.size.height=frame.size.height+yesterdayLabelOffset;
        tempprojectAndInOutEntryBGView.frame=frame;
    }
    UIView *view=[[UIView alloc]init];
    
    if (isBreakRow && self.isBreakAccess)
    {
        inOutEntryBGView.frame =CGRectMake(10, viewHeader.frame.size.height, timeEntryViewImage.size.width, timeEntryViewImage.size.height+yesterdayLabelOffset);
        [tempprojectAndInOutEntryBGView addSubview:inOutEntryBGView];
        [self.contentView addSubview:tempprojectAndInOutEntryBGView] ;
        [self.contentView addSubview:startIconButton] ;
        view.frame=CGRectMake(0, tempprojectAndInOutEntryBGView.frame.size.height-1, SCREEN_WIDTH, 1);
    }
    
    else if (isExtended && !isBreakRow) {
        inOutEntryBGView.frame =CGRectMake(10, viewHeader.frame.size.height, timeEntryViewImage.size.width, timeEntryViewImage.size.height+yesterdayLabelOffset);
        [tempprojectAndInOutEntryBGView addSubview:inOutEntryBGView];
        [self.contentView addSubview:tempprojectAndInOutEntryBGView] ;
        [self.contentView addSubview:startIconButton] ;
        view.frame=CGRectMake(0, tempprojectAndInOutEntryBGView.frame.size.height-1, SCREEN_WIDTH, 1);
        
    }
    else
    {
        inOutEntryBGView.frame =CGRectMake(10, 8, timeEntryViewImage.size.width, timeEntryViewImage.size.height+yesterdayLabelOffset);
        [tempprojectAndInOutEntryBGView addSubview:inOutEntryBGView];
        [self.contentView addSubview:tempprojectAndInOutEntryBGView] ;
        if (isYesterdayLabelShow)
        {
            view.frame=CGRectMake(0, 69, SCREEN_WIDTH, 1);
        }
        else
        {
            view.frame=CGRectMake(0, 49, SCREEN_WIDTH, 1);
        }
        
        
    }
    
    
    [view setBackgroundColor:[UIColor lightGrayColor]];
    [self.contentView addSubview:view];
    
}

-(UIView *)projectViewHeader
{
    float cellHeight=0.0;
    float verticalOffset=10.0;
    float upperLabelHeight=0.0;
    float middleLabelHeight=0.0;
    float lowerLabelHeight=0.0;
    NSString *upperStr=@"";
    NSString *middleStr=@"";
    NSString *lowerStr=@"";
    BOOL isUpperLabelTextWrap=NO;
    BOOL isMiddleLabelTextWrap=NO;
    BOOL isLowerLabelTextWrap=NO;
    NSMutableDictionary *heightDict=[NSMutableDictionary dictionary];
    BOOL isTimeoffSickRow=NO;
    BOOL isBreak=NO;
    NSString *breakUri=[tsEntryObject breakName];
    if (breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]]&&![breakUri isEqualToString:@""])
    {
        isBreak=YES;
    }
    if (isTimeoffSickRow||isBreak)
    {
        if (isBreak && self.isBreakAccess)
        {
            NSString *breakName=[tsEntryObject breakName];
            middleStr=breakName;
            middleLabelHeight=[self getHeightForString:breakName fontSize:RepliconFontSize_16 forWidth:LABEL_WIDTH];
            [heightDict setObject:@"SINGLE" forKey:LINE];
        }
        else if(isTimeoffSickRow)
        {
            NSString *timeEntryTimeOffName=[tsEntryObject timeEntryTimeOffName];
            middleStr=timeEntryTimeOffName;
            middleLabelHeight=[self getHeightForString:timeEntryTimeOffName fontSize:RepliconFontSize_16 forWidth:LABEL_WIDTH];
            [heightDict setObject:@"SINGLE" forKey:LINE];
        }
        
    }
    else
    {
        
        NSString *timeEntryTaskName=[tsEntryObject timeEntryTaskName];
        NSString *timeEntryClientName=[tsEntryObject timeEntryClientName];
        NSString *timeEntryProjectName=[tsEntryObject timeEntryProjectName];
        if (timeEntryTaskName==nil || [timeEntryTaskName isKindOfClass:[NSNull class]]||[timeEntryTaskName isEqualToString:@""])
        {
            
            if (self.isProjectAccess)
            {
                
                BOOL isBothClientAndProjectNull=[self checkIfBothProjectAndClientIsNull:timeEntryClientName projectName:timeEntryProjectName];
                
                if (isBothClientAndProjectNull)
                {
                    
                    //No task client and project.Only third row consiting of activity/udf's or billing
                    
                    NSString *attributeText=[self getTheAttributedTextForEntryObject];
                    if (attributeText==nil || [attributeText isKindOfClass:[NSNull class]]||[attributeText isEqualToString:@""])
                    {
                        attributeText=RPLocalizedString(NO_PROJECT_SELECTED_STRING, @"");
                    }
                    
                    isMiddleLabelTextWrap=YES;
                    middleStr=attributeText;
                    middleLabelHeight=[self getHeightForString:attributeText fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                    [heightDict setObject:@"SINGLE" forKey:LINE];
                    
                }
                else
                {
                    
                    NSString *attributeText=[self getTheAttributedTextForEntryObject];
                    if (attributeText==nil ||[attributeText isKindOfClass:[NSNull class]]||[attributeText isEqualToString:@""])
                    {
                        
                        //No task No activity/udf's or billing Only project/client
                        
                        if (timeEntryClientName==nil || [timeEntryClientName isKindOfClass:[NSNull class]]||[timeEntryClientName isEqualToString:@""]||[timeEntryClientName isEqualToString:NULL_STRING])
                        {
                            middleStr=[NSString stringWithFormat:@"%@",timeEntryProjectName];
                        }
                        else
                        {
                            middleStr=[NSString stringWithFormat:@"in %@ for %@",timeEntryProjectName,timeEntryClientName];
                        }
                        middleLabelHeight=[self getHeightForString:middleStr fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                        [heightDict setObject:@"SINGLE" forKey:LINE];
                        
                    }
                    else
                    {
                        //No task project/client and activity/udf's or billing
                        
                        
                        if (timeEntryClientName==nil || [timeEntryClientName isKindOfClass:[NSNull class]]||[timeEntryClientName isEqualToString:@""]||[timeEntryClientName isEqualToString:NULL_STRING])
                        {
                            upperStr=[NSString stringWithFormat:@"%@",timeEntryProjectName];
                        }
                        else
                        {
                            upperStr=[NSString stringWithFormat:@"in %@ for %@",timeEntryProjectName,timeEntryClientName];
                        }
                        lowerStr=attributeText;
                        isLowerLabelTextWrap=YES;
                        upperLabelHeight=[self getHeightForString:upperStr fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                        lowerLabelHeight=[self getHeightForString:lowerStr fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                        [heightDict setObject:@"DOUBLE" forKey:LINE];
                        
                    }
                    
                }
                
            }
            else  if (self.isActivityAccess)
            {
                
                NSString *attributeText=[self getTheAttributedTextForEntryObject];
                if (attributeText==nil || [attributeText isKindOfClass:[NSNull class]]||[attributeText isEqualToString:@""])
                {
                    attributeText=RPLocalizedString(NO_ACTIVITY_SELECTED_STRING, @"");
                }
                
                middleStr=attributeText;
                middleLabelHeight=[self getHeightForString:middleStr fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                [heightDict setObject:@"SINGLE" forKey:LINE];
                isMiddleLabelTextWrap=YES;
                
                
            }
            
            
        }
        else
        {
            upperStr=timeEntryTaskName;
            NSString *attributeText=[self getTheAttributedTextForEntryObject];
            if (attributeText==nil ||[attributeText isKindOfClass:[NSNull class]]||[attributeText isEqualToString:@""])
            {
                
                if (timeEntryClientName==nil || [timeEntryClientName isKindOfClass:[NSNull class]]||[timeEntryClientName isEqualToString:@""]||[timeEntryClientName isEqualToString:NULL_STRING])
                {
                    lowerStr=[NSString stringWithFormat:@"%@",timeEntryProjectName];
                }
                else
                {
                    lowerStr=[NSString stringWithFormat:@"in %@ for %@",timeEntryProjectName,timeEntryClientName];
                }
                upperLabelHeight=[self getHeightForString:upperStr fontSize:RepliconFontSize_16 forWidth:LABEL_WIDTH];
                lowerLabelHeight=[self getHeightForString:lowerStr fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                [heightDict setObject:@"DOUBLE" forKey:LINE];
                
                
            }
            else
            {
                
                
                
                if (timeEntryClientName==nil || [timeEntryClientName isKindOfClass:[NSNull class]]||[timeEntryClientName isEqualToString:@""]||[timeEntryClientName isEqualToString:NULL_STRING])
                {
                    middleStr=[NSString stringWithFormat:@"%@",timeEntryProjectName];
                }
                else
                {
                    middleStr=[NSString stringWithFormat:@"in %@ for %@",timeEntryProjectName,timeEntryClientName];
                }
                lowerStr=[self getTheAttributedTextForEntryObject];
                upperLabelHeight=[self getHeightForString:upperStr fontSize:RepliconFontSize_16 forWidth:LABEL_WIDTH];
                middleLabelHeight=[self getHeightForString:middleStr fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                lowerLabelHeight=[self getHeightForString:lowerStr fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                [heightDict setObject:@"TRIPLE" forKey:LINE];
                
            }
            
        }
        
        
    }
    
    float numberOfLabels=0;
    NSString *line=[heightDict objectForKey:LINE];
    if ([line isEqualToString:@"SINGLE"])
    {
        numberOfLabels=1;
    }
    else if ([line isEqualToString:@"DOUBLE"])
    {
        numberOfLabels=2;
    }
    else if ([line isEqualToString:@"TRIPLE"])
    {
        numberOfLabels=3;
    }
    
    cellHeight=upperLabelHeight+middleLabelHeight+lowerLabelHeight+2*verticalOffset+numberOfLabels*5;
    
    
    if (cellHeight<50)
    {
        cellHeight=50;
    }
    
    
    if (!isBreak && !isProjectAccess && !isActivityAccess)
    {
        cellHeight=0;
    }
    
    [heightDict setObject:[NSString stringWithFormat:@"%f",upperLabelHeight] forKey:UPPER_LABEL_HEIGHT];
    [heightDict setObject:[NSString stringWithFormat:@"%f",middleLabelHeight] forKey:MIDDLE_LABEL_HEIGHT];
    [heightDict setObject:[NSString stringWithFormat:@"%f",lowerLabelHeight] forKey:LOWER_LABEL_HEIGHT];
    [heightDict setObject:[NSString stringWithFormat:@"%@",upperStr] forKey:UPPER_LABEL_STRING];
    [heightDict setObject:[NSString stringWithFormat:@"%@",middleStr] forKey:MIDDLE_LABEL_STRING];
    [heightDict setObject:[NSString stringWithFormat:@"%@",lowerStr] forKey:LOWER_LABEL_STRING];
    [heightDict setObject:[NSString stringWithFormat:@"%d",isUpperLabelTextWrap] forKey:UPPER_LABEL_TEXT_WRAP];
    [heightDict setObject:[NSString stringWithFormat:@"%d",isMiddleLabelTextWrap] forKey:MIDDLE_LABEL_TEXT_WRAP];
    [heightDict setObject:[NSString stringWithFormat:@"%d",isLowerLabelTextWrap] forKey:LOWER_LABEL_TEXT_WRAP];
    [heightDict setObject:[NSString stringWithFormat:@"%f",cellHeight] forKey:CELL_HEIGHT_KEY];
    
    UIView *tmpProjectView=[[UIView alloc]init];
    tmpProjectView=[self initialiseView:heightDict];
    [tmpProjectView setBackgroundColor:[UIColor clearColor]];
    [tmpProjectView setFrame:CGRectMake(0, 0, 320, cellHeight)];
    return tmpProjectView;
}

-(float)getHeightForString:(NSString *)string fontSize:(int)fontSize forWidth:(float)width
{
    // Let's make an NSAttributedString first
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    //Add LineBreakMode
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
    // Add Font
    [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} range:NSMakeRange(0, attributedString.length)];
    
    //Now let's make the Bounding Rect
    CGSize mainSize  = [attributedString boundingRectWithSize:CGSizeMake(width, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    if (mainSize.width==0 && mainSize.height ==0)
    {
        mainSize=CGSizeMake(0,0);
    }
    return mainSize.height;
}

-(NSString *)getTheAttributedTextForEntryObject
{
    
    NSMutableArray *array=[NSMutableArray array];
    NSString *tsBillingName=[tsEntryObject timeEntryBillingName];
    NSString *tsActivityName=[tsEntryObject timeEntryActivityName];
    
    NSString *tmpBillingValue=@"";
    if (tsBillingName!=nil && ![tsBillingName isKindOfClass:[NSNull class]]&& ![tsBillingName isEqualToString:@""])
    {
        
        tmpBillingValue=BILLABLE;
    }
    else
    {
        tmpBillingValue=NON_BILLABLE;
    }
    if (self.isBillingAccess)
    {
        NSMutableDictionary *billingDict=[NSMutableDictionary dictionaryWithObject:tmpBillingValue forKey:@"BILLING"];
        [array addObject:billingDict];
    }
    else
    {
        tmpBillingValue=@"";
    }
    //DE18721 Ullas M L
    if (self.isActivityAccess)
    {
        if (tsActivityName!=nil && ![tsActivityName isKindOfClass:[NSNull class]]&& ![tsActivityName isEqualToString:@""])
        {
            NSMutableDictionary *activityDict=[NSMutableDictionary dictionaryWithObject:tsActivityName forKey:@"ACTIVITY"];
            [array addObject:activityDict];
            
        }
    }
    
    
    float labelWidth=230;
    int sizeExceedingCount=0;
    NSMutableArray *arrayFinal=[NSMutableArray array];
    NSString *tempCompStr=@"";
    NSString *tempCompStrrr=@"";
    
    for (int i=0; i<[array count]; i++)
    {
        //NSArray *allKeys=[[array objectAtIndex:i] allKeys];
        NSArray *allValues=[[array objectAtIndex:i] allValues];
        //NSString *key=(NSString *)[allKeys objectAtIndex:0];
        NSString *str=(NSString *)[allValues objectAtIndex:0];
        tempCompStrrr=[tempCompStrrr stringByAppendingString:[NSString stringWithFormat:@" %@ |",str]];
        tempCompStr=[tempCompStr stringByAppendingString:[NSString stringWithFormat:@" %@ | +%d",str,sizeExceedingCount]];
        CGSize stringSize = [tempCompStr sizeWithAttributes:
                             @{NSFontAttributeName:
                                   [UIFont systemFontOfSize:RepliconFontSize_12]}];
        tempCompStr=tempCompStrrr;
        CGFloat width = stringSize.width;
        if (!isBillingAccess)
        {
            if (width<labelWidth)
            {
                //do nothing
            }
            else
            {
                str=[Util stringByTruncatingToWidth:labelWidth withFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12] ForString:str addQuotes:YES];
            }
            
            [arrayFinal addObject:str];
        }
        else
        {
            if (width<labelWidth)
            {
                [arrayFinal addObject:str];
            }
            else
            {
                sizeExceedingCount++;
            }
        }
        
    }
    
    NSString *tempfinalString=@"";
    NSString *finalString=@"";
    for (int i=0; i<[arrayFinal count]; i++)
    {
        
        NSString *str=(NSString *)[arrayFinal objectAtIndex:i];
        if (i==[arrayFinal count]-1)
        {
            if (sizeExceedingCount!=0)
            {
                tempfinalString=[tempfinalString stringByAppendingString:[NSString stringWithFormat:@" %@ | +%d",str,sizeExceedingCount]];
                CGSize stringSize = [tempfinalString sizeWithAttributes:
                                     @{NSFontAttributeName:
                                           [UIFont systemFontOfSize:RepliconFontSize_12]}];
                CGFloat width = stringSize.width;
                if (width<labelWidth)
                {
                    finalString=[finalString stringByAppendingString:[NSString stringWithFormat:@" %@ | +%d",str,sizeExceedingCount]];
                }
                else
                {
                    finalString=[NSString stringWithFormat:@" %@ +%d",finalString,sizeExceedingCount+1];
                    
                }
                
            }
            else
            {
                tempfinalString=[finalString stringByAppendingString:str];
                finalString=[finalString stringByAppendingString:str];
                
            }
            
        }
        else
        {
            tempfinalString=[finalString stringByAppendingString:[NSString stringWithFormat:@" %@ | ",str]];
            finalString=[finalString stringByAppendingString:[NSString stringWithFormat:@"%@ | ",str]];
            
            
        }
        
    }
    
    return finalString;
}

-(UIView *)initialiseView:(NSMutableDictionary *)dataDict
{
    UIView *returnView=[UIView new];
    UIView *separatorView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320.0, 0.5)];
    [separatorView setBackgroundColor:[Util colorWithHex:@"#d6d6d6" alpha:1.0]];
    [returnView addSubview:separatorView];
    //[returnView bringSubviewToFront:separatorView];
    [returnView setBackgroundColor:[Util colorWithHex:@"#f2f2f2" alpha:1]];
    
    BOOL isSingleLine=NO;
    BOOL isTwoLine=NO;
    BOOL isThreeLine=NO;
    NSString *line=[dataDict objectForKey:LINE];
    NSString *upperStr=[dataDict objectForKey:UPPER_LABEL_STRING];
    NSString *middleStr=[dataDict objectForKey:MIDDLE_LABEL_STRING];
    NSString *lowerStr=[dataDict objectForKey:LOWER_LABEL_STRING];
    
    float upperLblHeight=[[dataDict objectForKey:UPPER_LABEL_HEIGHT] newFloatValue];
    float middleLblHeight=[[dataDict objectForKey:MIDDLE_LABEL_HEIGHT] newFloatValue];
    float lowerLblHeight=[[dataDict objectForKey:LOWER_LABEL_HEIGHT] newFloatValue];
    //float height=[[dataDict objectForKey:CELL_HEIGHT_KEY] newFloatValue];
    //BOOL isUpperLabelTextWrap=[[heightDict objectForKey:UPPER_LABEL_TEXT_WRAP] boolValue];
    BOOL isMiddleLabelTextWrap=[[dataDict objectForKey:MIDDLE_LABEL_TEXT_WRAP] boolValue];
    BOOL isLowerLabelTextWrap=[[dataDict objectForKey:LOWER_LABEL_TEXT_WRAP] boolValue];
    
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
        [middleLeft setTextColor:[Util colorWithHex:@"#505151" alpha:1]];
        [middleLeft setBackgroundColor:[UIColor clearColor]];
        [middleLeft setTextAlignment:NSTextAlignmentLeft];
        [middleLeft setHighlightedTextColor:[UIColor whiteColor]];
        [returnView addSubview:middleLeft];
        [middleLeft setText:middleStr];
        
        BOOL isBreakPresent=NO;
        NSString *breakName=[tsEntryObject breakName];
        if (breakName!=nil && ![breakName isKindOfClass:[NSNull class]] && ![breakName isEqualToString:@""])
        {
            isBreakPresent=YES;
        }
        
        
        if ([tsEntryObject isTimeoffSickRowPresent]||isBreakPresent)
        {
            
            if (isBreakPresent)
            {
                UIImage *breakImage=[Util thumbnailImage:BREAK_ICON];
                UIImageView *breakImageView=[[UIImageView alloc]initWithImage:breakImage];
                breakImageView.frame=CGRectMake(10.0, 12.0, breakImage.size.width, breakImage.size.height);
                UILabel *breakLb=[[UILabel alloc]initWithFrame:CGRectMake(7, 0, 10, breakImage.size.height)];
                [breakLb setBackgroundColor:[UIColor clearColor]];
                [breakLb setTextAlignment:NSTextAlignmentLeft];
                [breakLb setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_12]];
                [breakLb setText:@"B"];
                [breakImageView addSubview:breakLb];
                [returnView addSubview:breakImageView];
                
                middleLeft.frame=CGRectMake(10.0+breakImage.size.width+10, 14.0, LABEL_WIDTH-50, middleLblHeight);
            }
            
            [middleLeft setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
            [middleLeft setNumberOfLines:100];
        }
        else
        {
            [middleLeft setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
            middleLeft.frame=CGRectMake(10.0,5.0, LABEL_WIDTH, EachDayTimeEntry_Cell_Row_Height_44);
            if (isMiddleLabelTextWrap)
            {
                [middleLeft setNumberOfLines:1];
                
                if (self.isBillingAccess)
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
                    if ([middleStr rangeOfString:NON_BILLABLE].location == NSNotFound)
                    {
                        //NSLog(@"NON_BILLABLE NOT PRESENT");
                        NSString *ver = [[UIDevice currentDevice] systemVersion];
                        float ver_float = [ver newFloatValue];
                        if (ver_float < 6.0)
                        {
                            [tmpattributedString addAttribute:(NSString*)kCTForegroundColorAttributeName
                                                        value:(id)[Util colorWithHex:@"#505151" alpha:1]
                                                        range:NSMakeRange(0,[string length])];
                        }
                        else
                        {
                            [tmpattributedString addAttribute:NSForegroundColorAttributeName value:[Util colorWithHex:@"#505151" alpha:1] range:NSMakeRange(0,[string length])];
                        }
                        
                    }
                    else
                    {
                        //NSLog(@"NON_BILLABLE PRESENT");
                        //DE18817 Ullas M L
                        NSString *ver = [[UIDevice currentDevice] systemVersion];
                        float ver_float = [ver newFloatValue];
                        if (ver_float < 6.0)
                        {
                            [tmpattributedString addAttribute:(NSString*)kCTForegroundColorAttributeName
                                                        value:(id)[[UIColor redColor] CGColor]
                                                        range:NSMakeRange(0,[string length])];
                        }
                        else
                        {
                            [tmpattributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,[string length])];
                        }
                    }
                    
                    //DE18817 Ullas M L
                    NSString *ver = [[UIDevice currentDevice] systemVersion];
                    float ver_float = [ver newFloatValue];
                    if (ver_float > 6.0)
                    {
                        [middleLeft setAttributedText:tmpattributedString];
                    }
                    else
                    {
                        [middleLeft setText:[tmpattributedString string]];
                    }
                }
                
            }
            else
            {
                [middleLeft setNumberOfLines:100];
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
        
        UILabel *upperLeft = [[UILabel alloc] init];
        upperLeft.frame=CGRectMake(10, 10, LABEL_WIDTH, upperLblHeight);
        [upperLeft setTextColor:[Util colorWithHex:@"#505151" alpha:1]];
        [upperLeft setBackgroundColor:[UIColor clearColor]];
        [upperLeft setTextAlignment:NSTextAlignmentLeft];
        
        if (isTaskPresent)
        {
            [upperLeft setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
        }
        else
        {
            [upperLeft setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
        }
        
        [upperLeft setText:upperStr];
        [upperLeft setNumberOfLines:100];
        [upperLeft setHighlightedTextColor:[UIColor whiteColor]];
        [returnView addSubview:upperLeft];
        
        float yLower=upperLeft.frame.origin.y+upperLeft.frame.size.height+5;
        UILabel *lowerLeft = [[UILabel alloc] init];
        lowerLeft.frame=CGRectMake(10.0, yLower, LABEL_WIDTH, lowerLblHeight);
        [lowerLeft setTextColor:[Util colorWithHex:@"#505151" alpha:1]];
        [lowerLeft setBackgroundColor:[UIColor clearColor]];
        [lowerLeft setTextAlignment:NSTextAlignmentLeft];
        [lowerLeft setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
        [lowerLeft setText:lowerStr];
        
        if (isLowerLabelTextWrap)
        {
            [lowerLeft setNumberOfLines:1];
            
            if (self.isBillingAccess)
            {
                NSMutableAttributedString *tmpattributedString = [[NSMutableAttributedString alloc]  initWithString:lowerStr];
                NSString *string = @"";
                if ([lowerStr isEqualToString:BILLABLE])
                {
                    string = BILLABLE;
                }
                else
                {
                    string = NON_BILLABLE;
                }
                
                if ([string length]==[lowerStr length])
                {
                    
                }
                else
                {
                    string = [NSString stringWithFormat:@" %@",NON_BILLABLE];
                }
                if ([lowerStr rangeOfString:NON_BILLABLE].location == NSNotFound)
                {
                    //NSLog(@"NON_BILLABLE NOT PRESENT");
                    NSString *ver = [[UIDevice currentDevice] systemVersion];
                    float ver_float = [ver newFloatValue];
                    if (ver_float < 6.0)
                    {
                        [tmpattributedString addAttribute:(NSString*)kCTForegroundColorAttributeName
                                                    value:(id)[Util colorWithHex:@"#505151" alpha:1]
                                                    range:NSMakeRange(0,[string length])];
                    }
                    else
                    {
                        [tmpattributedString addAttribute:NSForegroundColorAttributeName value:[Util colorWithHex:@"#505151" alpha:1] range:NSMakeRange(0,[string length])];
                    }
                    
                }
                else
                {
                    //NSLog(@"NON_BILLABLE PRESENT");
                    //DE18817 Ullas M L
                    NSString *ver = [[UIDevice currentDevice] systemVersion];
                    float ver_float = [ver newFloatValue];
                    if (ver_float < 6.0)
                    {
                        [tmpattributedString addAttribute:(NSString*)kCTForegroundColorAttributeName
                                                    value:(id)[[UIColor redColor] CGColor]
                                                    range:NSMakeRange(0,[string length])];
                    }
                    else
                    {
                        [tmpattributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,[string length])];
                    }
                }
                
                //DE18817 Ullas M L
                NSString *ver = [[UIDevice currentDevice] systemVersion];
                float ver_float = [ver newFloatValue];
                if (ver_float > 6.0)
                {
                    [lowerLeft setAttributedText:tmpattributedString];
                }
                else
                {
                    [lowerLeft setText:[tmpattributedString string]];
                }
            }
            
            
            
        }
        else
        {
            [lowerLeft setNumberOfLines:100];
        }
        
        [lowerLeft setHighlightedTextColor:[UIColor whiteColor]];
        [returnView addSubview:lowerLeft];
        
        
    }
    else if (isThreeLine)
    {
        
        UILabel *upperLeft = [[UILabel alloc] init];
        upperLeft.frame=CGRectMake(10, 10, LABEL_WIDTH, upperLblHeight);
        [upperLeft setTextColor:[Util colorWithHex:@"#505151" alpha:1]];
        [upperLeft setBackgroundColor:[UIColor clearColor]];
        [upperLeft setTextAlignment:NSTextAlignmentLeft];
        [upperLeft setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
        [upperLeft setText:upperStr];
        [upperLeft setNumberOfLines:100];
        [upperLeft setHighlightedTextColor:[UIColor whiteColor]];
        [returnView addSubview:upperLeft];
        
        float ymiddle=upperLeft.frame.origin.y+upperLeft.frame.size.height+5;
        UILabel *middleLeft = [[UILabel alloc] init];
        middleLeft.frame=CGRectMake(10.0, ymiddle, LABEL_WIDTH, middleLblHeight);
        [middleLeft setTextColor:[Util colorWithHex:@"#505151" alpha:1]];
        [middleLeft setBackgroundColor:[UIColor clearColor]];
        [middleLeft setTextAlignment:NSTextAlignmentLeft];
        [middleLeft setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
        [middleLeft setText:middleStr];
        [middleLeft setNumberOfLines:100];
        [middleLeft setHighlightedTextColor:[UIColor whiteColor]];
        [returnView addSubview:middleLeft];
        
        
        float ylower=middleLeft.frame.origin.y+middleLeft.frame.size.height+5;
        UILabel *lowerLeft = [[UILabel alloc] init];
        lowerLeft.frame=CGRectMake(10.0, ylower, LABEL_WIDTH, lowerLblHeight);
        [lowerLeft setTextColor:[Util colorWithHex:@"#505151" alpha:1]];
        [lowerLeft setBackgroundColor:[UIColor clearColor]];
        [lowerLeft setTextAlignment:NSTextAlignmentLeft];
        [lowerLeft setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
        [lowerLeft setText:lowerStr];
        if (isBillingAccess)
        {
            NSMutableAttributedString *tmpattributedString = [[NSMutableAttributedString alloc]  initWithString:lowerStr];
            NSString *string = @"";
            if ([lowerStr isEqualToString:BILLABLE])
            {
                string = BILLABLE;
            }
            else
            {
                string = NON_BILLABLE;
            }
            
            if ([string length]==[lowerStr length])
            {
                
            }
            else
            {
                string = [NSString stringWithFormat:@" %@",NON_BILLABLE];
            }
            if ([lowerStr rangeOfString:NON_BILLABLE].location == NSNotFound)
            {
                //NSLog(@"NON_BILLABLE NOT PRESENT");
                NSString *ver = [[UIDevice currentDevice] systemVersion];
                float ver_float = [ver newFloatValue];
                if (ver_float < 6.0)
                {
                    [tmpattributedString addAttribute:(NSString*)kCTForegroundColorAttributeName
                                                value:(id)[Util colorWithHex:@"#505151" alpha:1]
                                                range:NSMakeRange(0,[string length])];
                }
                else
                {
                    [tmpattributedString addAttribute:NSForegroundColorAttributeName value:[Util colorWithHex:@"#505151" alpha:1] range:NSMakeRange(0,[string length])];
                }
                
            }
            else
            {
                //NSLog(@"NON_BILLABLE PRESENT");
                //DE18817 Ullas M L
                NSString *ver = [[UIDevice currentDevice] systemVersion];
                float ver_float = [ver newFloatValue];
                if (ver_float < 6.0)
                {
                    [tmpattributedString addAttribute:(NSString*)kCTForegroundColorAttributeName
                                                value:(id)[[UIColor redColor] CGColor]
                                                range:NSMakeRange(0,[string length])];
                }
                else
                {
                    [tmpattributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,[string length])];
                }
                
            }
            
            //DE18817 Ullas M L
            NSString *ver = [[UIDevice currentDevice] systemVersion];
            float ver_float = [ver newFloatValue];
            if (ver_float > 6.0)
            {
                [lowerLeft setAttributedText:tmpattributedString];
            }
            else
            {
                [lowerLeft setText:[tmpattributedString string]];
            }
        }
        
        
        
        
        
        [lowerLeft setNumberOfLines:1];
        [lowerLeft setHighlightedTextColor:[UIColor whiteColor]];
        [returnView addSubview:lowerLeft];
        
        
    }
    
    
    
    
    BOOL isTimeoffRow=NO;
    NSString *timeEntryTimeOffName=[tsEntryObject timeEntryTimeOffName];
    if (timeEntryTimeOffName!=nil && ![timeEntryTimeOffName isKindOfClass:[NSNull class]]&&![timeEntryTimeOffName isEqualToString:@""])
    {
        isTimeoffRow=YES;
    }
    
    
    
    
    return returnView;
    
    
    
    
}



-(BOOL)checkIfBothProjectAndClientIsNull:(NSString *)timeEntryClientName projectName:(NSString *)timeEntryProjectName
{
    if (timeEntryClientName==nil || [timeEntryClientName isKindOfClass:[NSNull class]]||[timeEntryClientName isEqualToString:@""]||[timeEntryClientName isEqualToString:NULL_STRING])
    {
        timeEntryClientName=@"";
    }
    if (timeEntryProjectName==nil || [timeEntryProjectName isKindOfClass:[NSNull class]]||[timeEntryProjectName isEqualToString:@""]||[timeEntryProjectName isEqualToString:NULL_STRING])
    {
        timeEntryProjectName=@"";
    }
    
    BOOL clientNull=NO;
    BOOL projectNull=NO;
    if (timeEntryClientName==nil || [timeEntryClientName isKindOfClass:[NSNull class]]||[timeEntryClientName isEqualToString:@""]||[timeEntryClientName isEqualToString:NULL_STRING])
    {
        clientNull=YES;
    }
    if (timeEntryProjectName==nil || [timeEntryProjectName isKindOfClass:[NSNull class]]||[timeEntryProjectName isEqualToString:@""]||[timeEntryProjectName isEqualToString:NULL_STRING])
    {
        projectNull=YES;
    }
    
    if (clientNull && projectNull)
    {
        return YES;
    }
    
    return NO;
    
}
- (NSMutableDictionary *)getNumberOfHoursForInTime: (NSDate *) inDate outTime:(NSDate *) outDate
{
    
    
    
    NSUInteger days =0;
    NSInteger hours=0;
    NSInteger minutes=0;
//    int seconds = 0;
    if (inDate!=nil)
    {
        
        
        NSDateComponents    *   inSeconds = [[NSCalendar currentCalendar] components: NSCalendarUnitSecond fromDate: inDate];
        [inSeconds setSecond: -[inSeconds second]];
        
        inDate = [[NSCalendar currentCalendar] dateByAddingComponents: inSeconds toDate: inDate options: 0];
        
        NSDateComponents    *   outSeconds = [[NSCalendar currentCalendar] components: NSCalendarUnitSecond fromDate: outDate];
        [outSeconds setSecond: -[outSeconds second]];
        
        outDate = [[NSCalendar currentCalendar] dateByAddingComponents: outSeconds toDate: outDate options: 0];
        
        
        NSDate *currentTimestamp = outDate;
        NSDate *punchInDateTime=inDate;
        
        unsigned int unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitMonth;
        
        NSDateComponents *conversionInfo = [[NSCalendar currentCalendar] components:unitFlags fromDate:punchInDateTime  toDate:currentTimestamp  options:0];
        
        NSRange daysRange =
        [[NSCalendar currentCalendar]
         rangeOfUnit:NSCalendarUnitDay
         inUnit:NSCalendarUnitMonth
         forDate:punchInDateTime];
        
        // daysRange.length will contain the number of the last day
        // of the month containing curDate
        
        
        NSInteger months = [conversionInfo month];
        NSUInteger addDays=0;
        if (months>0)
        {
            addDays=daysRange.length+[conversionInfo day];
        }
        days = [conversionInfo day]+addDays;
        hours = [conversionInfo hour]+(24*days);
        minutes = [conversionInfo minute];
        
        //        [self.minsLblWhileTracking setText:[NSString stringWithFormat:@"%02i", hours]];
        //        [self.secsLblWhileTracking setText:[NSString stringWithFormat:@"%02i", minutes]];
    }
    
    
    
    
    NSMutableDictionary *returnDict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [NSString stringWithFormat:@"%02li",(long)hours],@"hour",
                                     [NSString stringWithFormat:@"%02li",(long)minutes],@"minute",
                                     [NSString stringWithFormat:@"%d",0],@"second", nil];
    return returnDict;
}


-(void)startIconButtonAction :(id) sender
{
    if([delegate conformsToProtocol:@protocol(PunchTimeCellClickDelegate)] && [delegate respondsToSelector:@selector(cellClickedAtIndex:)])
    {
        [delegate cellClickedAtIndex:[sender tag]];
    }
}


@end
