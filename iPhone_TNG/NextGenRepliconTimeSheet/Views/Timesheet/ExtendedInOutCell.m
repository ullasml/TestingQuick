#import "ExtendedInOutCell.h"
#import "Util.h"
#import "Constants.h"
#import "MultiDayInOutViewController.h"
#import "EntryCellDetails.h"
#import "LoginModel.h"
#import "TimesheetMainPageController.h"
#import "OEFObject.h"
#import "SupportDataModel.h"
#import "UIButton+Extensions.h"

#define AM_PM_Button_Width 44
#define AM_PM_Button_Height 45

@interface ExtendedInOutCell ()
@property (nonatomic) NSString *sheetIdentity;
@property (nonatomic) BOOL     isValueChanged;
@property (nonatomic) BOOL     isSplitTimeEntryAllowedForTimesheet;
@end


@implementation ExtendedInOutCell

@synthesize _inTxt;
@synthesize _outTxt;
@synthesize delegate;
@synthesize _currentEntry;
@synthesize _hours;
@synthesize cellRow;
@synthesize cellSection;
@synthesize _startOffset;
@synthesize _formattedIn;
@synthesize _formattedOut;
@synthesize midNightCrossOverView;
@synthesize _midNightHours;
@synthesize tsEntryObj;
@synthesize numberKeyPad;
@synthesize _submit;
@synthesize isAmPmButtonClick;
@synthesize saveDictOnOverlap;
@synthesize isMidNightCrossOver;
@synthesize indexForMidnight;

- (void)createCellLayoutWithParamsForTimesheetEntryObject:(TimesheetEntryObject *)timesheetEntryObj
                                forInOutTimesheetEntryObj:(InOutTimesheetEntry *)inOutTimesheetEntry
                                                editState:(BOOL)iseditState
                                                   forRow:(NSInteger)row
                                      approvalsModuleName:(NSString *)approvalsModuleName
                                          isGen4Timesheet:(BOOL)isGen4Timesheet
{
    self.fieldBackgroundImage = [[UIImage imageNamed:@"InOutCellFieldBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 0)];
    
    
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.sheetIdentity =  timesheetEntryObj.timesheetUri;
    
    
    if (_inTxt == nil)
    {
        self._inTxt = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 0.0f, (SCREEN_WIDTH-10)/3, 45.0f)];
        self._inTxt.placeholder = RPLocalizedString(IN_TEXT, IN_TEXT);
    }
    [self._inTxt setAccessibilityIdentifier:@"uia_inout_timesheet_in_time_value_textfield_identifier"];

    [self setupTextField:_inTxt];
    [self.contentView addSubview:_inTxt];

    if (_outTxt == nil)
    {
        self._outTxt = [[UITextField alloc] initWithFrame:CGRectMake(10.0f+((SCREEN_WIDTH-10)/3), 0.0f, (SCREEN_WIDTH-10)/3, 45.0f)];
        self._outTxt.placeholder = RPLocalizedString(OUT_TEXT, OUT_TEXT);
    }
    [self._outTxt setAccessibilityIdentifier:@"uia_inout_timesheet_out_time_value_textfield_identifier"];


    [self setupTextField:_outTxt];
    [self.contentView addSubview:_outTxt];

    if (_formattedIn == nil)
    {
        self._formattedIn = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self._inTxt.frame) + 1.0f, 1.0f, self._inTxt.frame.size.width*0.6, 42.0f)];
        self._formattedIn.font = [UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17];
        self._formattedIn.textAlignment = NSTextAlignmentCenter;
        self._formattedIn.hidden = YES;
    }

    if (_formattedOut == nil)
    {
        self._formattedOut = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self._outTxt.frame) + 1.0f, 1.0f, self._inTxt.frame.size.width*0.6, 42.0f)];
        self._formattedOut.font = [UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17];
        self._formattedOut.textAlignment = NSTextAlignmentCenter;
        self._formattedOut.hidden = YES;
    }

    [self.contentView addSubview:_formattedIn];
    [self.contentView addSubview:_formattedOut];

    UIImage *chevronImage = [UIImage imageNamed:@"Chevron"];
    float xPositionForChevron = SCREEN_WIDTH - chevronImage.size.width - 5;

    UIButton* entryDetailsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    entryDetailsButton.frame = CGRectMake(10 + (2*(SCREEN_WIDTH-10)/3), 0.0f, (SCREEN_WIDTH-10)/3, 45.0f);
    entryDetailsButton.adjustsImageWhenHighlighted = NO;
    entryDetailsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    entryDetailsButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    entryDetailsButton.tag = row;
    [entryDetailsButton setBackgroundImage:self.fieldBackgroundImage forState:UIControlStateNormal];
    [entryDetailsButton addTarget:self action:@selector(entryDetailsButtonClickedByUser:) forControlEvents:UIControlEventTouchUpInside];

    CGFloat hoursX = (entryDetailsButton.frame.size.width - 51- chevronImage.size.width - 35)/2;
    if (_hours == nil)
    {
        _hours = [[UILabel alloc] initWithFrame:CGRectMake(hoursX, 0, 51, 45)];
        _hours.font = [UIFont fontWithName:RepliconFontFamilySemiBold size:RepliconFontSize_17];
        _hours.textAlignment = NSTextAlignmentRight;
    }

    if (_midNightHours == nil)
    {
        _midNightHours = [[UILabel alloc] initWithFrame:CGRectMake(_hours.frame.origin.x + 7, 30.5, 51, 16)];
        _midNightHours.font = [UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12];
        _midNightHours.textAlignment = NSTextAlignmentCenter;
    }

    _inAMPM = [self makePMButton];
    [_inAMPM setTag:row];
    [_inAMPM setFrame:CGRectMake(_formattedIn.frame.origin.x + _formattedIn.frame.size.width, 0, _inTxt.frame.size.width*0.4 - 1, AM_PM_Button_Height)];
    
    _outAMPM = [self makePMButton];
    [_outAMPM setTag:row];
    [_outAMPM setFrame:CGRectMake(_formattedOut.frame.origin.x + _formattedOut.frame.size.width, 0, _outTxt.frame.size.width*0.4 - 1, AM_PM_Button_Height)];

    if (_submit==nil)
    {
        _submit = [UIButton buttonWithType:UIButtonTypeCustom];
        _submit.frame = CGRectMake(10+(2*(SCREEN_WIDTH-10)/3)+hoursX, 5, 51, 32);
        _submit.enabled = NO;

        [_submit setBackgroundImage:[UIImage imageNamed:@"inOutEntrySubmit.png"] forState:UIControlStateNormal];
        [_submit setBackgroundImage:[UIImage imageNamed:@"inOutEntrySubmitDown.png"] forState:UIControlStateHighlighted];
        [_submit setBackgroundImage:[UIImage imageNamed:@"inOutEntrySubmitDisabled.png"] forState:UIControlStateDisabled];
        [_submit addTarget:self action:@selector(submitEntry:) forControlEvents:UIControlEventTouchUpInside];

        [_submit setHitTestEdgeInsets:UIEdgeInsetsMake(-20, -10, -10, -40)];
    
    }

    UIImage *disclosureImage = [Util thumbnailImage:MIDNIGHT_CROSSOVER_IMAGE];
    float xImage=_inAMPM.frame.origin.x+_inAMPM.frame.size.width-(disclosureImage.size.width/2);
    UIImageView *disclosureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(xImage, 0, disclosureImage.size.width,disclosureImage.size.height)];
    [disclosureImageView setImage:disclosureImage];
    self.midNightCrossOverView=disclosureImageView;

    [entryDetailsButton addSubview:_hours];
    [entryDetailsButton addSubview:_midNightHours];

    [self.contentView addSubview:entryDetailsButton];
    [self.contentView addSubview:_inAMPM];
    [self.contentView addSubview:_outAMPM];
    [self.contentView bringSubviewToFront:_inAMPM];
    [self.contentView bringSubviewToFront:_outAMPM];
    [self.contentView addSubview:_submit];
    [self.contentView addSubview:self.midNightCrossOverView];

    _inAMPM.hidden = _outAMPM.hidden = _submit.hidden = YES;

    if (!iseditState)
    {
        _inTxt.userInteractionEnabled = NO;
        _outTxt.userInteractionEnabled = NO;
        _inAMPM.userInteractionEnabled = NO;
        _outAMPM.userInteractionEnabled = NO;
        _submit.userInteractionEnabled = NO;
    }

    self._currentEntry = inOutTimesheetEntry;
    self.tag = row;

    if (_currentEntry.isMidnightCrossover)
    {
        [self.midNightCrossOverView setHidden:NO];
    }
    else
    {
        [self.midNightCrossOverView setHidden:YES];
    }

    self.tsEntryObj = timesheetEntryObj;
    self.isSplitTimeEntryAllowedForTimesheet = [self allowSplitTimeEntryForMidNightCrossPermission:AllowSplitTimeMidNightCrossEntry timesheetUri:[self.tsEntryObj timesheetUri]];
    
    if(_currentEntry.startTime != -1)
    {
        _inTxt.text = [NSString stringWithFormat:@"%i", _currentEntry.startTime];
        _formattedIn.text = [self formatTimeEntry:_currentEntry.startTime];
        [_formattedIn setHidden:NO];
        [_inAMPM setSelected:[self isPM:_currentEntry.startTime]];
        [_inAMPM setHidden:NO];
        [_inTxt setTextColor:[UIColor whiteColor]];
    }
    else
    {
        _inTxt.text = @"";
        [_inTxt setTextColor:[UIColor blackColor]];
        [_formattedIn setHidden:YES];
        [_inAMPM setHidden:YES];
    }

    if(_currentEntry.endTime != -1)
    {
        _outTxt.text = [NSString stringWithFormat:@"%i", _currentEntry.endTime];
        _formattedOut.text = [self formatTimeEntry:_currentEntry.endTime];
        [_formattedOut setHidden:NO];
        [_outAMPM setSelected:[self isPM:_currentEntry.endTime]];

        [_outAMPM setHidden:NO];
        [_outTxt setTextColor:[UIColor whiteColor]];
    }
    else
    {
        _outTxt.text = @"";
        [_formattedOut setHidden:YES];
        [_outAMPM setHidden:YES];
        [_outTxt setTextColor:[UIColor blackColor]];
    }

    NSString *midNightCrossHours = _currentEntry.crossoverHours;
    _hours.text = [NSString stringWithFormat:@"%@", _currentEntry.hours];
    BOOL hasValue = (midNightCrossHours != nil && ![midNightCrossHours isKindOfClass:[NSNull class]] && ![midNightCrossHours isEqualToString:@""] && ![midNightCrossHours isEqualToString:@"0.00"]);
    if (hasValue) {
        _midNightHours.text = [NSString stringWithFormat:@"+%@", _currentEntry.crossoverHours];
    }
    else
        _midNightHours.text = [NSString stringWithFormat:@"%@", _currentEntry.crossoverHours];

    BOOL isTimeEntryCommentsAllowed = NO;
    if (isGen4Timesheet)
    {
        NSString *tsFormat=nil;
        if(approvalsModuleName==nil)
        {
            TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
            tsFormat=[timesheetModel getTimesheetFormatforTimesheetUri:[timesheetEntryObj timesheetUri]];
        }
        else
        {
            ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
            if ([approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
               tsFormat=[approvalsModel getTimesheetFormatforTimesheetUri:[timesheetEntryObj timesheetUri] andIsPending:YES];
            }
            else
            {
                tsFormat=[approvalsModel getTimesheetFormatforTimesheetUri:[timesheetEntryObj timesheetUri] andIsPending:NO];
            }
        }
        SupportDataModel *supportDataModel=[[SupportDataModel alloc]init];
        NSDictionary *permittedApprovalAcionsDict=[supportDataModel getTimesheetPermittedApprovalActionsDataToDBWithUri:[timesheetEntryObj timesheetUri]];

        if (tsFormat!=nil && ![tsFormat isKindOfClass:[NSNull class]])
        {
            if ([tsFormat isEqualToString:GEN4_INOUT_TIMESHEET])
            {
                isTimeEntryCommentsAllowed=[[permittedApprovalAcionsDict objectForKey:@"allowTimeEntryCommentsForInOutGen4"] boolValue];
            }
            else if ([tsFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
            {
                isTimeEntryCommentsAllowed=[[permittedApprovalAcionsDict objectForKey:@"allowTimeEntryCommentsForExtInOutGen4"] boolValue];
            }
        }

        if (!isTimeEntryCommentsAllowed)
        {
            if ([timesheetEntryObj.timeEntryCellOEFArray count]>0)
            {
                isTimeEntryCommentsAllowed=YES;
            }
        }

    }
    else
    {
        isTimeEntryCommentsAllowed = YES;
    }

    BOOL isBreakEntry = [timesheetEntryObj breakUri]!=nil &&![[timesheetEntryObj breakUri] isKindOfClass:[NSNull class]]&&![[timesheetEntryObj breakUri] isEqualToString:@""];
    UIImage *commentsIconImage = [UIImage imageNamed:@"active-comment"];
    if (isTimeEntryCommentsAllowed && !isBreakEntry)
    {
        NSMutableArray *commentsImageColorStatusArray=[NSMutableArray array];
        LoginModel *loginModel=[[LoginModel alloc]init];
        NSMutableArray *requiredUdfArray=nil;
        if ([[timesheetEntryObj entryType] isEqualToString:Time_Off_Key]||[[timesheetEntryObj entryType] isEqualToString:Adhoc_Time_OffKey])
        {
            requiredUdfArray=[loginModel getRequiredOnlyUDFsforModuleName:TIMEOFF_UDF];
        }
        else
        {
            requiredUdfArray=[loginModel getRequiredOnlyUDFsforModuleName:TIMESHEET_CELL_UDF];
        }
        NSMutableArray *udfArray=[[[timesheetEntryObj timePunchesArray] objectAtIndex:row] objectForKey:@"udfArray"];
        if (isGen4Timesheet)
        {
            udfArray=nil;
            requiredUdfArray=nil;
            
            NSMutableArray *oefArr=[timesheetEntryObj timeEntryCellOEFArray];
            for (int k=0; k<[oefArr count]; k++)
            {
                OEFObject *oefObject=(OEFObject *)[oefArr objectAtIndex:k];
                NSString *oefValue=nil;
                NSString *oefDefinitionTypeUri=oefObject.oefDefinitionTypeUri;
                if ([oefDefinitionTypeUri isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI])
                {
                    oefValue=oefObject.oefTextValue;
                }
                else if ([oefDefinitionTypeUri isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI])
                {
                    oefValue=oefObject.oefNumericValue;
                }
                else if ([oefDefinitionTypeUri isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI])
                {
                    oefValue=oefObject.oefDropdownOptionValue;
                }
                if (oefValue==nil || [oefValue isKindOfClass:[NSNull class]])
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
                
                for (int k=0; k<[udfArray count]; k++)
                {
                    EntryCellDetails *udfDetails=(EntryCellDetails *)[udfArray objectAtIndex:k];
                    BOOL isUdfMandatory=NO;
                    if ([[timesheetEntryObj entryType] isEqualToString:Time_Off_Key]||[[timesheetEntryObj entryType] isEqualToString:Adhoc_Time_OffKey])
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
                for (int k=0; k<[udfArray count]; k++)
                {
                    EntryCellDetails *udfDetails=(EntryCellDetails *)[udfArray objectAtIndex:k];
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
        
        
        NSString *comments=[[[timesheetEntryObj timePunchesArray] objectAtIndex:row] objectForKey:@"comments"];
        NSMutableArray *commentsImageColorStatusArrayForComments=[NSMutableArray array];
        BOOL ifCommentsMandatory=NO;
        NSMutableArray *daySummaryArray=nil;
        if (approvalsModuleName==nil||[approvalsModuleName isKindOfClass:[NSNull class]]||[approvalsModuleName isEqualToString:@""])
        {
            TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
            daySummaryArray=[timesheetModel getAllTimesheetDaySummaryFromDBForTimesheet:[timesheetEntryObj timesheetUri]];
        }
        else
        {
            ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
            if ([approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                daySummaryArray=[approvalsModel getAllPendingTimesheetDaySummaryFromDBForTimesheet:[timesheetEntryObj timesheetUri]];
            }
            else
            {
                daySummaryArray=[approvalsModel getAllPreviousTimesheetDaySummaryFromDBForTimesheet:[timesheetEntryObj timesheetUri]];
            }
        }
        
        if ([daySummaryArray count]!=0) {
            if ([[[daySummaryArray objectAtIndex:0] objectForKey:@"isCommentsRequired"] intValue]==1)
            {
                ifCommentsMandatory=YES;
            }
        }
        
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
        
        
        if ([commentsImageColorStatusArray containsObject:@"RED"]||[commentsImageColorStatusArrayForComments containsObject:@"RED"])
        {
            commentsIconImage=[UIImage imageNamed:@"red-comment"];
        }
        else if ([commentsImageColorStatusArray containsObject:@"BLUE"]||[commentsImageColorStatusArrayForComments containsObject:@"BLUE"])
        {
            commentsIconImage=[UIImage imageNamed:@"active-comment"];
        }
        else if ([commentsImageColorStatusArray containsObject:@"GRAY"]&&[commentsImageColorStatusArrayForComments containsObject:@"GRAY"])
        {
            commentsIconImage=[UIImage imageNamed:@"in-active-comment"];
        }
        else
        {
            LoginModel *loginModel=[[LoginModel alloc]init];
            NSMutableArray *requiredUdfArray=[loginModel getRequiredOnlyUDFsforModuleName:TIMESHEET_CELL_UDF];
            if (isGen4Timesheet)
            {
                requiredUdfArray=nil;
            }
            if ([requiredUdfArray count]!=0)
            {
                commentsIconImage=[UIImage imageNamed:@"active-comment"];
            }
            else
            {
                if (comments!=nil && ![comments isEqualToString:@""]&& ![comments isKindOfClass:[NSNull class]]&&![comments isEqualToString:NULL_STRING])
                {
                    commentsIconImage=[UIImage imageNamed:@"active-comment"];
                }
                else
                {
                    commentsIconImage=[UIImage imageNamed:@"in-active-comment"];
                    
                }
            }
        }
        
        UIImageView *commentsIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_midNightHours.frame.origin.x+_midNightHours.frame.size.width, 16, commentsIconImage.size.width,commentsIconImage.size.height)];
        [commentsIconImageView setImage:commentsIconImage];
        self.commentsIconImageView=commentsIconImageView;
        [entryDetailsButton addSubview:self.commentsIconImageView];
    }
    
    UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(xPositionForChevron, 18, chevronImage.size.width,chevronImage.size.height)];
    [arrowImageView setImage:chevronImage];
    self.arrowImageView=arrowImageView;
    [self.contentView addSubview:self.arrowImageView];
    
}

-(void) calculateAndSetHours:(NSInteger)index
{
    self.commentsIconImageView.hidden=NO;
    self.arrowImageView.hidden=NO;

    if(_currentEntry.startTime == -1 || _currentEntry.endTime == -1)
    {
        _hours.text = [NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]];
        _midNightHours.text=@"";
        _submit.hidden=YES;
    }
    else
    {
        if (_currentEntry.endTime < _currentEntry.startTime)
        {
            int diffInHours = (24-((int)(_currentEntry.startTime/100)-(int)(_currentEntry.endTime/100)))*60;
            int diffInMins = (24-((int)(_currentEntry.startTime/100)-(int)(_currentEntry.endTime/100)))*60 + ((_currentEntry.startTime%100)-(_currentEntry.endTime%100));
            int mins = diffInMins%60;
            NSString *minsStr=(mins<10 ? [NSString stringWithFormat:@"0%i", mins] : [NSString stringWithFormat:@"%i", mins]);
            if (mins>0)
            {
                minsStr=[NSString stringWithFormat:@"%f",1-([minsStr newFloatValue]/60)];
            }
            else
            {
                minsStr=[NSString stringWithFormat:@"%f",[minsStr newFloatValue]/60];
            }

            NSString *hrsStr=[NSString stringWithFormat:@"%d",(int)(diffInHours/60)];
            NSString *final=[NSString stringWithFormat:@"%.2f",[hrsStr newFloatValue]+[minsStr newFloatValue]];

            if ([[Util detectDecimalMark] isEqualToString:@","])
            {
                _hours.text =[final stringByReplacingOccurrencesOfString:@"." withString:@"," ] ;
            }
            else
            {
                 _hours.text =final ;
            }

             NSMutableDictionary *inoutDict=[[self.tsEntryObj timePunchesArray]objectAtIndex:index];
            BOOL isMidCrossOverForEntry=[Util checkIsMidNightCrossOver:inoutDict];
            if (isMidCrossOverForEntry)
            {
                NSString *intimeString=[inoutDict objectForKey:@"in_time"];
                NSString *tmpOuttimeString=@"12:00 am";
                NSString *tmpintimeString=@"12:00 am";
                NSString *outtimeString=[inoutDict objectForKey:@"out_time"];
                NSString *hoursText=[Util getNumberOfHoursForInTime:intimeString outTime:tmpOuttimeString];
                NSString *midnightHours=[Util getNumberOfHoursForInTime:tmpintimeString outTime:outtimeString];
                _hours.text = hoursText;
                if(self.isSplitTimeEntryAllowedForTimesheet){
                    _outTxt.text = @"11:59";
                    _midNightHours.text = @"";
                }else{
                    _midNightHours.text=[NSString stringWithFormat:@"+%@",midnightHours];
                }
                //[self.midNightCrossOverView setHidden:NO];
            }
            else
            {
                _midNightHours.text=@"";
                //[self.midNightCrossOverView setHidden:YES];
            }
            _submit.hidden=YES;

        }
        else
        {
            BOOL isSplitEntry = [self isSplitEntry];
            int entryEndTime = _currentEntry.endTime;
            if (isSplitEntry && entryEndTime == 2359) {
                entryEndTime = 2400;
            }
            int diffInMins = ((int)(entryEndTime/100)-(int)(_currentEntry.startTime/100))*60 + ((entryEndTime%100)-(_currentEntry.startTime%100));
            int mins = diffInMins%60;
            NSString *minsStr=(mins<10 ? [NSString stringWithFormat:@"0%i", mins] : [NSString stringWithFormat:@"%i", mins]);
            minsStr=[NSString stringWithFormat:@"%f",[minsStr newFloatValue]/60];
            NSString *hrsStr=[NSString stringWithFormat:@"%d",(int)(diffInMins/60)];
            NSString *final=[NSString stringWithFormat:@"%.2f",[hrsStr newFloatValue]+[minsStr newFloatValue]];
            if ([[Util detectDecimalMark] isEqualToString:@","])
            {
                _hours.text =[final stringByReplacingOccurrencesOfString:@"." withString:@"," ] ;
            }
            else
            {
                _hours.text =final ;
            }
            NSMutableDictionary *inoutDict=[[self.tsEntryObj timePunchesArray]objectAtIndex:index];
            BOOL isMidCrossOverForEntry=[Util checkIsMidNightCrossOver:inoutDict];
            if (isMidCrossOverForEntry)
            {
                NSString *intimeString=[inoutDict objectForKey:@"in_time"];
                 NSString *tmpOuttimeString=@"12:00 am";
                NSString *tmpintimeString=@"12:00 am";
                NSString *outtimeString=[inoutDict objectForKey:@"out_time"];
                NSString *hoursText=[Util getNumberOfHoursForInTime:intimeString outTime:tmpOuttimeString];
                NSString *midnightHours=[Util getNumberOfHoursForInTime:tmpintimeString outTime:outtimeString];
                _hours.text = hoursText;
                 _midNightHours.text=[NSString stringWithFormat:@"+%@",midnightHours];
                //[self.midNightCrossOverView setHidden:NO];
            }
            else
            {
                _midNightHours.text=@"";
                //[self.midNightCrossOverView setHidden:YES];
            }

            _submit.hidden=YES;

        }

    }

    _currentEntry.hours=_hours.text;
    _currentEntry.crossoverHours=_midNightHours.text;


}

-(void) setFocus {
    [_inTxt becomeFirstResponder];
}

-(void) setInTimeFocus {
    [_inTxt becomeFirstResponder];
}

-(void) setOutTimeFocus {
    [_outTxt becomeFirstResponder];
}

-(void) resetCell {
    [_currentEntry resetEntry];
    _inTxt.text = @"";
    [_formattedIn setHidden:YES];
    _outTxt.text = @"";
    [_formattedOut setHidden:YES];
    _hours.text = @"";
    _inAMPM.titleLabel.text = @"AM";
    [_inAMPM setHidden:YES];
    _outAMPM.titleLabel.text = @"AM";
    [_outAMPM setHidden:YES];
}

- (void)saveStartTime:(int)startTime
          saveEndTime:(int)endTime
         ignoreOffset:(BOOL)ignore
              onIndex:(NSInteger)index
            onSection:(NSInteger)section
     isFromAmPmButton:(BOOL)isFromToggleButton
        isSendRequest:(BOOL)isSendRequest
{

    isMidNightCrossOver=NO;
    _currentEntry.startTime = startTime;
    _currentEntry.endTime = endTime;
    indexForMidnight=index;

    if(!ignore && _currentEntry.startTime != -1 && _currentEntry.startTime < _startOffset)
    {
        _currentEntry.startTime += 1200;
        if(_currentEntry.startTime >= 2400) _currentEntry.startTime -= 2400;
    }

    _inAMPM.hidden = _formattedIn.hidden = (_currentEntry.startTime == -1);
    [_inAMPM setSelected:(_currentEntry.startTime >= 1200)];
    _outAMPM.hidden = _formattedOut.hidden = (_currentEntry.endTime == -1);
    [_outAMPM setSelected:(_currentEntry.endTime >= 1200)];

    if (_currentEntry.startTime!=-1 && _currentEntry.endTime!=-1)
    {

        if (isFromToggleButton)
        {

            NSString *calculatedINHours=@"12";
            NSString *calculatedINMins=@"00";
            if (_currentEntry.startTime>0)
            {
                if (_currentEntry.startTime<1200)
                {
                    if ([[NSString stringWithFormat:@"%d",_currentEntry.startTime] length]<3)
                    {
                        calculatedINHours=@"12" ;
                        if ([[NSString stringWithFormat:@"%d",_currentEntry.startTime] length]==1)
                        {
                            calculatedINMins=[NSString stringWithFormat:@"0%d",_currentEntry.startTime];
                        }
                        else
                        {
                            calculatedINMins=[NSString stringWithFormat:@"%d",_currentEntry.startTime];
                        }
                    }
                    else
                    {
                        calculatedINHours= [[NSString stringWithFormat:@"%d",_currentEntry.startTime] substringToIndex:([[NSString stringWithFormat:@"%d",_currentEntry.startTime] length]-2)];
                        calculatedINMins=[[NSString stringWithFormat:@"%d",_currentEntry.startTime] substringFromIndex:([[NSString stringWithFormat:@"%d",_currentEntry.startTime] length]-2)];
                    }


                }
                else
                {
                    calculatedINHours= [[NSString stringWithFormat:@"%d",_currentEntry.startTime] substringToIndex:([[NSString stringWithFormat:@"%d",_currentEntry.startTime] length]-2)];
                    calculatedINMins=[[NSString stringWithFormat:@"%d",_currentEntry.startTime] substringFromIndex:([[NSString stringWithFormat:@"%d",_currentEntry.startTime] length]-2)];
                }

            }
            NSString *calculatedOUTHours=@"12";
            NSString *calculatedOUTMins=@"00";
            if (_currentEntry.endTime>0)
            {
                if (_currentEntry.endTime<1200)
                {
                    if ([[NSString stringWithFormat:@"%d",_currentEntry.endTime] length]<3)
                    {
                        calculatedOUTHours=@"12" ;
                        if ([[NSString stringWithFormat:@"%d",_currentEntry.endTime] length]==1)
                        {
                            calculatedOUTMins=[NSString stringWithFormat:@"0%d",_currentEntry.endTime];
                        }
                        else
                        {
                            calculatedOUTMins=[NSString stringWithFormat:@"%d",_currentEntry.endTime];
                        }
                    }
                    else
                    {
                        calculatedOUTHours= [[NSString stringWithFormat:@"%d",_currentEntry.endTime] substringToIndex:([[NSString stringWithFormat:@"%d",_currentEntry.endTime] length]-2)];
                        calculatedOUTMins=[[NSString stringWithFormat:@"%d",_currentEntry.endTime] substringFromIndex:([[NSString stringWithFormat:@"%d",_currentEntry.endTime] length]-2)];
                    }


                }
                else
                {
                    calculatedOUTHours= [[NSString stringWithFormat:@"%d",_currentEntry.endTime] substringToIndex:([[NSString stringWithFormat:@"%d",_currentEntry.endTime] length]-2)];
                    calculatedOUTMins=[[NSString stringWithFormat:@"%d",_currentEntry.endTime] substringFromIndex:([[NSString stringWithFormat:@"%d",_currentEntry.endTime] length]-2)];
                }


            }
            NSString *inTimeFormat=nil;
            if ([calculatedINHours intValue]>12)
            {
                if ([calculatedINHours intValue] >12)
                {
                    calculatedINHours=[NSString stringWithFormat:@"%d",[calculatedINHours intValue]-12];
                }

                inTimeFormat=@"pm";
            }
            else if ([calculatedINHours intValue]==12)
            {
                if (_currentEntry.startTime<1200)
                {
                    inTimeFormat=@"am";
                }
                else
                {
                    inTimeFormat=@"pm";
                }

            }

            else
            {
                inTimeFormat=@"am";
            }

            NSString *outimeFormat=nil;
            if ([calculatedOUTHours intValue]>12)
            {
                if ([calculatedOUTHours intValue] >12)
                {
                    calculatedOUTHours=[NSString stringWithFormat:@"%d",[calculatedOUTHours intValue]-12];
                }

                outimeFormat=@"pm";
            }
            else if ([calculatedOUTHours intValue]==12)
            {
                if (_currentEntry.endTime<1200)
                {
                    outimeFormat=@"am";
                }
                else
                {
                    outimeFormat=@"pm";
                }

            }

            else
            {
                outimeFormat=@"am";
            }
            NSString *saveInTime=[NSString stringWithFormat:@"%@:%@ %@",calculatedINHours,calculatedINMins, [inTimeFormat lowercaseString]];
            NSString *saveOutTime=[NSString stringWithFormat:@"%@:%@ %@",calculatedOUTHours,calculatedOUTMins,[outimeFormat lowercaseString]];

            NSMutableDictionary *saveEntryDict=[NSMutableDictionary dictionary];
            [saveEntryDict setObject:saveInTime forKey:@"in_time"];
            [saveEntryDict setObject:saveOutTime forKey:@"out_time"];

            BOOL isMidCrossOverForEntry=[Util checkIsMidNightCrossOver:saveEntryDict];
            if (isMidCrossOverForEntry)
            {
                [self.midNightCrossOverView setHidden:NO];
                saveDictOnOverlap=saveEntryDict;
                isMidNightCrossOver=YES;
            }
            else
            {
                [self.midNightCrossOverView setHidden:YES];
            }

            if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
            {
                MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)delegate;
                [ctrl updateExtendedInOutTimeEntryForIndex:index forSection:cellSection withValue:saveEntryDict sendRequest:isSendRequest];
            }

        }
        else
        {
            NSString *calculatedINHours=@"12";
            NSString *calculatedINMins=@"00";
            if (_currentEntry.startTime>0)
            {
                if (_currentEntry.startTime<1200)
                {
                    if ([[NSString stringWithFormat:@"%d",_currentEntry.startTime] length]<3)
                    {
                        calculatedINHours=@"12" ;
                        if ([[NSString stringWithFormat:@"%d",_currentEntry.startTime] length]==1)
                        {
                            calculatedINMins=[NSString stringWithFormat:@"0%d",_currentEntry.startTime];
                        }
                        else
                        {
                            calculatedINMins=[NSString stringWithFormat:@"%d",_currentEntry.startTime];
                        }
                    }
                    else
                    {
                        calculatedINHours= [[NSString stringWithFormat:@"%d",_currentEntry.startTime] substringToIndex:([[NSString stringWithFormat:@"%d",_currentEntry.startTime] length]-2)];
                        calculatedINMins=[[NSString stringWithFormat:@"%d",_currentEntry.startTime] substringFromIndex:([[NSString stringWithFormat:@"%d",_currentEntry.startTime] length]-2)];
                    }


                }
                else
                {
                    calculatedINHours= [[NSString stringWithFormat:@"%d",_currentEntry.startTime] substringToIndex:([[NSString stringWithFormat:@"%d",_currentEntry.startTime] length]-2)];
                    calculatedINMins=[[NSString stringWithFormat:@"%d",_currentEntry.startTime] substringFromIndex:([[NSString stringWithFormat:@"%d",_currentEntry.startTime] length]-2)];

                }

            }
            NSString *calculatedOUTHours=@"12";
            NSString *calculatedOUTMins=@"00";
            if (_currentEntry.endTime>0)
            {
                if (_currentEntry.endTime<1200)
                {
                    if ([[NSString stringWithFormat:@"%d",_currentEntry.endTime] length]<3)
                    {
                        calculatedOUTHours=@"12" ;
                        if ([[NSString stringWithFormat:@"%d",_currentEntry.endTime] length]==1)
                        {
                            calculatedOUTMins=[NSString stringWithFormat:@"0%d",_currentEntry.endTime];
                        }
                        else
                        {
                            calculatedOUTMins=[NSString stringWithFormat:@"%d",_currentEntry.endTime];
                        }
                    }
                    else
                    {
                        calculatedOUTHours= [[NSString stringWithFormat:@"%d",_currentEntry.endTime] substringToIndex:([[NSString stringWithFormat:@"%d",_currentEntry.endTime] length]-2)];
                        calculatedOUTMins=[[NSString stringWithFormat:@"%d",_currentEntry.endTime] substringFromIndex:([[NSString stringWithFormat:@"%d",_currentEntry.endTime] length]-2)];
                    }


                }
                else
                {
                    calculatedOUTHours= [[NSString stringWithFormat:@"%d",_currentEntry.endTime] substringToIndex:([[NSString stringWithFormat:@"%d",_currentEntry.endTime] length]-2)];
                    calculatedOUTMins=[[NSString stringWithFormat:@"%d",_currentEntry.endTime] substringFromIndex:([[NSString stringWithFormat:@"%d",_currentEntry.endTime] length]-2)];
                }


            }


            NSString *inTimeFormat=_inAMPM.titleLabel.text;
            if ([inTimeFormat isEqualToString:@"PM"] && [calculatedINHours intValue] >12)
            {
                calculatedINHours=[NSString stringWithFormat:@"%d",[calculatedINHours intValue]-12];
            }
            else if ([inTimeFormat isEqualToString:@"AM"] && [calculatedINHours intValue] >12)
            {
                calculatedINHours=[NSString stringWithFormat:@"%d",[calculatedINHours intValue]-12];
            }
            NSString *outimeFormat=_outAMPM.titleLabel.text;
            if ([outimeFormat isEqualToString:@"PM"] && [calculatedOUTHours intValue] >12)
            {
                calculatedOUTHours=[NSString stringWithFormat:@"%d",[calculatedOUTHours intValue]-12];
            }
            else if ([outimeFormat isEqualToString:@"AM"] && [calculatedOUTHours intValue] >12)
            {
                calculatedOUTHours=[NSString stringWithFormat:@"%d",[calculatedOUTHours intValue]-12];
            }


            NSString *saveInTime=[NSString stringWithFormat:@"%@:%@ %@",calculatedINHours,calculatedINMins, [inTimeFormat lowercaseString]];
            NSString *saveOutTime=[NSString stringWithFormat:@"%@:%@ %@",calculatedOUTHours,calculatedOUTMins,[outimeFormat lowercaseString]];
            
            

            NSMutableDictionary *saveEntryDict=[NSMutableDictionary dictionary];
            [saveEntryDict setObject:saveInTime forKey:@"in_time"];
            [saveEntryDict setObject:saveOutTime forKey:@"out_time"];
            
            BOOL isOutTimeChanged =  (self.isValueChanged || _currentEntry.endTime != 2359) ;
            BOOL isSplitEntry = ([self isSplitEntry] && !isOutTimeChanged);
            if (isSplitEntry) {
                saveEntryDict = [self dictionaryOfInAndOutTimeWithSeconds:saveInTime];
                saveDictOnOverlap=saveEntryDict;
            }

            BOOL isMidCrossOverForEntry=[Util checkIsMidNightCrossOver:saveEntryDict];
            if (isMidCrossOverForEntry && !isSplitEntry)
            {
                [self.midNightCrossOverView setHidden:NO];
                saveDictOnOverlap=saveEntryDict;
                isMidNightCrossOver=YES;
            }
            else
            {
                [self.midNightCrossOverView setHidden:YES];
            }

            if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
            {
                MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)delegate;
                [saveEntryDict setObject:[NSNull null] forKey:SplitTimeEntryForNextTimesheetPeriod];
                [ctrl updateExtendedInOutTimeEntryForIndex:index forSection:cellSection withValue:saveEntryDict sendRequest:isSendRequest];
            }

        }

    }
    else
    {
        if (isFromToggleButton)
        {
            if (_currentEntry.startTime!=-1)
            {
                NSString *calculatedINHours=@"12";
                NSString *calculatedINMins=@"00";
                if (_currentEntry.startTime>0)
                {
                    if (_currentEntry.startTime<1200)
                    {
                        if ([[NSString stringWithFormat:@"%d",_currentEntry.startTime] length]<3)
                        {
                            calculatedINHours=@"12" ;
                            if ([[NSString stringWithFormat:@"%d",_currentEntry.startTime] length]==1)
                            {
                                calculatedINMins=[NSString stringWithFormat:@"0%d",_currentEntry.startTime];
                            }
                            else
                            {
                                calculatedINMins=[NSString stringWithFormat:@"%d",_currentEntry.startTime];
                            }

                        }
                        else
                        {
                            calculatedINHours= [[NSString stringWithFormat:@"%d",_currentEntry.startTime] substringToIndex:([[NSString stringWithFormat:@"%d",_currentEntry.startTime] length]-2)];
                            calculatedINMins=[[NSString stringWithFormat:@"%d",_currentEntry.startTime] substringFromIndex:([[NSString stringWithFormat:@"%d",_currentEntry.startTime] length]-2)];

                        }

                    }
                    else
                    {
                        calculatedINHours= [[NSString stringWithFormat:@"%d",_currentEntry.startTime] substringToIndex:([[NSString stringWithFormat:@"%d",_currentEntry.startTime] length]-2)];
                        calculatedINMins=[[NSString stringWithFormat:@"%d",_currentEntry.startTime] substringFromIndex:([[NSString stringWithFormat:@"%d",_currentEntry.startTime] length]-2)];
                    }

                }
                NSString *inTimeFormat=nil;
                if ([calculatedINHours intValue]>12)
                {
                    if ([calculatedINHours intValue] >12)
                    {
                        calculatedINHours=[NSString stringWithFormat:@"%d",[calculatedINHours intValue]-12];
                    }

                    inTimeFormat=@"pm";
                }
                else if ([calculatedINHours intValue]==12)
                {
                    if (_currentEntry.startTime<1200)
                    {
                        inTimeFormat=@"am";
                    }
                    else
                    {
                        inTimeFormat=@"pm";
                    }

                }
                else
                {
                    inTimeFormat=@"am";
                }
                NSString *saveInTime=[NSString stringWithFormat:@"%@:%@ %@",calculatedINHours,calculatedINMins, [inTimeFormat lowercaseString]];
                NSMutableDictionary *saveEntryDict=[NSMutableDictionary dictionary];
                [saveEntryDict setObject:saveInTime forKey:@"in_time"];
                [saveEntryDict setObject:@"" forKey:@"out_time"];
                
                BOOL isMidCrossOverForEntry=[Util checkIsMidNightCrossOver:saveEntryDict];
                if (isMidCrossOverForEntry)
                {
                    [self.midNightCrossOverView setHidden:NO];
                    saveDictOnOverlap=saveEntryDict;
                    isMidNightCrossOver=YES;
                }
                else
                {
                    [self.midNightCrossOverView setHidden:YES];
                }

                if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
                {
                    MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)delegate;
                    [ctrl updateExtendedInOutTimeEntryForIndex:index forSection:cellSection withValue:saveEntryDict sendRequest:isSendRequest];
                }

            }
            else if (_currentEntry.endTime!=-1)
            {
                NSString *calculatedOUTHours=@"12";
                NSString *calculatedOUTMins=@"00";
                if (_currentEntry.endTime>0)
                {
                    if (_currentEntry.endTime<1200)
                    {
                        if ([[NSString stringWithFormat:@"%d",_currentEntry.endTime] length]<3)
                        {
                            calculatedOUTHours=@"12" ;
                            if ([[NSString stringWithFormat:@"%d",_currentEntry.endTime] length]==1)
                            {
                                calculatedOUTMins=[NSString stringWithFormat:@"0%d",_currentEntry.endTime];
                            }
                            else
                            {
                                calculatedOUTMins=[NSString stringWithFormat:@"%d",_currentEntry.endTime];
                            }

                        }
                        else
                        {
                            calculatedOUTHours= [[NSString stringWithFormat:@"%d",_currentEntry.endTime] substringToIndex:([[NSString stringWithFormat:@"%d",_currentEntry.endTime] length]-2)];
                            calculatedOUTMins=[[NSString stringWithFormat:@"%d",_currentEntry.endTime] substringFromIndex:([[NSString stringWithFormat:@"%d",_currentEntry.endTime] length]-2)];

                        }

                    }
                    else
                    {
                        calculatedOUTHours= [[NSString stringWithFormat:@"%d",_currentEntry.endTime] substringToIndex:([[NSString stringWithFormat:@"%d",_currentEntry.endTime] length]-2)];
                        calculatedOUTMins=[[NSString stringWithFormat:@"%d",_currentEntry.endTime] substringFromIndex:([[NSString stringWithFormat:@"%d",_currentEntry.endTime] length]-2)];
                    }


                }
                NSString *outimeFormat=nil;
                if ([calculatedOUTHours intValue]>12)
                {
                    if ([calculatedOUTHours intValue] >12)
                    {
                        calculatedOUTHours=[NSString stringWithFormat:@"%d",[calculatedOUTHours intValue]-12];
                    }

                    outimeFormat=@"pm";
                }
                else if ([calculatedOUTHours intValue]==12)
                {
                    if (_currentEntry.endTime<1200)
                    {
                        outimeFormat=@"am";
                    }
                    else
                    {
                        outimeFormat=@"pm";
                    }
                }
                else
                {
                    outimeFormat=@"am";
                }



                NSString *saveOutTime=[NSString stringWithFormat:@"%@:%@ %@",calculatedOUTHours,calculatedOUTMins,[outimeFormat lowercaseString]];

                NSMutableDictionary *saveEntryDict=[NSMutableDictionary dictionary];
                [saveEntryDict setObject:@"" forKey:@"in_time"];
                [saveEntryDict setObject:saveOutTime forKey:@"out_time"];
                
                
                BOOL isMidCrossOverForEntry=[Util checkIsMidNightCrossOver:saveEntryDict];
                if (isMidCrossOverForEntry)
                {
                    [self.midNightCrossOverView setHidden:NO];
                    saveDictOnOverlap=saveEntryDict;
                    isMidNightCrossOver=YES;
                }
                else
                {
                    [self.midNightCrossOverView setHidden:YES];
                }

                if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
                {
                    MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)delegate;
                    [ctrl updateExtendedInOutTimeEntryForIndex:index forSection:cellSection withValue:saveEntryDict sendRequest:isSendRequest];
                }

            }
        }
        else
        {
            if (_currentEntry.startTime!=-1)
            {
                NSString *calculatedINHours=@"12";
                NSString *calculatedINMins=@"00";
                if (_currentEntry.startTime>0)
                {
                    if (_currentEntry.startTime<1200)
                    {
                        if ([[NSString stringWithFormat:@"%d",_currentEntry.startTime] length]<3)
                        {
                            calculatedINHours=@"12" ;
                            if ([[NSString stringWithFormat:@"%d",_currentEntry.startTime] length]==1)
                            {
                                calculatedINMins=[NSString stringWithFormat:@"0%d",_currentEntry.startTime];
                            }
                            else
                            {
                                calculatedINMins=[NSString stringWithFormat:@"%d",_currentEntry.startTime];
                            }
                        }
                        else
                        {
                            calculatedINHours= [[NSString stringWithFormat:@"%d",_currentEntry.startTime] substringToIndex:([[NSString stringWithFormat:@"%d",_currentEntry.startTime] length]-2)];
                            calculatedINMins=[[NSString stringWithFormat:@"%d",_currentEntry.startTime] substringFromIndex:([[NSString stringWithFormat:@"%d",_currentEntry.startTime] length]-2)];

                        }


                    }
                    else
                    {
                        calculatedINHours= [[NSString stringWithFormat:@"%d",_currentEntry.startTime] substringToIndex:([[NSString stringWithFormat:@"%d",_currentEntry.startTime] length]-2)];
                        calculatedINMins=[[NSString stringWithFormat:@"%d",_currentEntry.startTime] substringFromIndex:([[NSString stringWithFormat:@"%d",_currentEntry.startTime] length]-2)];
                    }


                }
                NSString *inTimeFormat=_inAMPM.titleLabel.text;
                if ([inTimeFormat isEqualToString:@"PM"] && [calculatedINHours intValue] >12)
                {
                    calculatedINHours=[NSString stringWithFormat:@"%d",[calculatedINHours intValue]-12];
                }
                else if ([inTimeFormat isEqualToString:@"AM"] && [calculatedINHours intValue] >12)
                {
                    calculatedINHours=[NSString stringWithFormat:@"%d",[calculatedINHours intValue]-12];
                }
                NSString *saveInTime=[NSString stringWithFormat:@"%@:%@ %@",calculatedINHours,calculatedINMins, [inTimeFormat lowercaseString]];
                NSMutableDictionary *saveEntryDict=[NSMutableDictionary dictionary];
                [saveEntryDict setObject:saveInTime forKey:@"in_time"];
                [saveEntryDict setObject:@"" forKey:@"out_time"];

                BOOL isMidCrossOverForEntry=[Util checkIsMidNightCrossOver:saveEntryDict];
                if (isMidCrossOverForEntry)
                {
                    [self.midNightCrossOverView setHidden:NO];
                    saveDictOnOverlap=saveEntryDict;
                    isMidNightCrossOver=YES;
                }
                else
                {
                    [self.midNightCrossOverView setHidden:YES];
                }
                if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
                {
                    MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)delegate;
                    [saveEntryDict setObject:[NSNull null] forKey:SplitTimeEntryForNextTimesheetPeriod];
                    [ctrl updateExtendedInOutTimeEntryForIndex:index forSection:cellSection withValue:saveEntryDict sendRequest:isSendRequest];
                }
            }
            else if (_currentEntry.endTime!=-1)
            {
                NSString *calculatedOUTHours=@"12";
                NSString *calculatedOUTMins=@"00";
                if (_currentEntry.endTime>0)
                {
                    if (_currentEntry.endTime<1200)
                    {
                        if ([[NSString stringWithFormat:@"%d",_currentEntry.endTime] length]<3)
                        {
                            calculatedOUTHours= @"12";
                            if ([[NSString stringWithFormat:@"%d",_currentEntry.endTime] length]==1)
                            {
                                calculatedOUTMins=[NSString stringWithFormat:@"0%d",_currentEntry.endTime];
                            }
                            else
                            {
                                calculatedOUTMins=[NSString stringWithFormat:@"%d",_currentEntry.endTime];
                            }
                        }
                        else
                        {
                            calculatedOUTHours= [[NSString stringWithFormat:@"%d",_currentEntry.endTime] substringToIndex:([[NSString stringWithFormat:@"%d",_currentEntry.endTime] length]-2)];
                            calculatedOUTMins=[[NSString stringWithFormat:@"%d",_currentEntry.endTime] substringFromIndex:([[NSString stringWithFormat:@"%d",_currentEntry.endTime] length]-2)];
                        }


                    }
                    else
                    {
                        calculatedOUTHours= [[NSString stringWithFormat:@"%d",_currentEntry.endTime] substringToIndex:([[NSString stringWithFormat:@"%d",_currentEntry.endTime] length]-2)];
                        calculatedOUTMins=[[NSString stringWithFormat:@"%d",_currentEntry.endTime] substringFromIndex:([[NSString stringWithFormat:@"%d",_currentEntry.endTime] length]-2)];
                    }

                }
                NSString *outimeFormat=_outAMPM.titleLabel.text;
                if ([outimeFormat isEqualToString:@"PM"] && [calculatedOUTHours intValue] >12)
                {
                    calculatedOUTHours=[NSString stringWithFormat:@"%d",[calculatedOUTHours intValue]-12];
                }
                else if ([outimeFormat isEqualToString:@"AM"] && [calculatedOUTHours intValue] >12)
                {
                    calculatedOUTHours=[NSString stringWithFormat:@"%d",[calculatedOUTHours intValue]-12];
                }
                NSString *saveOutTime=[NSString stringWithFormat:@"%@:%@ %@",calculatedOUTHours,calculatedOUTMins,[outimeFormat lowercaseString]];
                NSMutableDictionary *saveEntryDict=[NSMutableDictionary dictionary];
                [saveEntryDict setObject:@"" forKey:@"in_time"];
                [saveEntryDict setObject:saveOutTime forKey:@"out_time"];

                BOOL isMidCrossOverForEntry=[Util checkIsMidNightCrossOver:saveEntryDict];
                if (isMidCrossOverForEntry)
                {
                    [self.midNightCrossOverView setHidden:NO];
                    saveDictOnOverlap=saveEntryDict;
                    isMidNightCrossOver=YES;
                }
                else
                {
                    [self.midNightCrossOverView setHidden:YES];
                }

                if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
                {
                    MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)delegate;
                    [saveEntryDict setObject:[NSNull null] forKey:@"splitEntryNextDayData"];
                    [ctrl updateExtendedInOutTimeEntryForIndex:index forSection:cellSection withValue:saveEntryDict sendRequest:isSendRequest];
                }

            }

        }
    }



}

-(void) toggledAMPM:(id)sender
{
    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
    if (![timesheetModel isTimesheetContainsInflightSaveOperation:[self.tsEntryObj timesheetUri]])
    {
        isAmPmButtonClick=YES;
        [_inTxt resignFirstResponder];
        [_outTxt resignFirstResponder];

        if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
        {
            MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)delegate;
            [ctrl handleTapAndResetDayScroll];
            [[ctrl lastUsedTextField] resignFirstResponder];
            [ctrl resetTableSizeForExtendedInOut:NO];
        }
        int newTime;
        UIButton* btn = (UIButton*)sender;
        [btn setSelected:!btn.isSelected];
        if(btn == _inAMPM) {
            newTime = (btn.isSelected) ? _currentEntry.startTime+1200 : _currentEntry.startTime-1200;
            [self saveStartTime:newTime saveEndTime:_currentEntry.endTime ignoreOffset:YES onIndex:[sender tag] onSection:cellSection isFromAmPmButton:YES isSendRequest:YES];
        } else if(btn == _outAMPM) {
            newTime = (btn.isSelected) ? _currentEntry.endTime+1200 : _currentEntry.endTime-1200;
            [self saveStartTime:_currentEntry.startTime saveEndTime:newTime ignoreOffset:YES onIndex:[sender tag] onSection:cellSection isFromAmPmButton:YES isSendRequest:YES];
        }

        _inTxt.text = (_currentEntry.startTime == -1) ? @"" : [NSString stringWithFormat:@"%i", _currentEntry.startTime];
        _outTxt.text = (_currentEntry.endTime == -1) ? @"" : [NSString stringWithFormat:@"%i", _currentEntry.endTime];

        _formattedIn.text = [self formatTimeEntry:_currentEntry.startTime];
        _formattedOut.text = [self formatTimeEntry:_currentEntry.endTime];


        if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
        {
            MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)delegate;
            [ctrl setRowBeingEdited:(int)cellRow];
            [ctrl setSectionBeingEdited:(int)cellSection];
            self.tsEntryObj=[ctrl.timesheetEntryObjectArray objectAtIndex:cellSection];
            [ctrl calculateAndUpdateTotalHoursValueForFooter];
            [self calculateAndSetHours:[sender tag]];
            if(btn == _inAMPM)
            {
                [ctrl setEditTextFieldTag:1111];
            }
            else
            {
                [ctrl setEditTextFieldTag:2222];
            }

            BOOL isOverlap=NO;
            isOverlap=[ctrl checkOverlapForPageForExtendedInOut];
            if (isMidNightCrossOver && !isOverlap)
            {
                MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)delegate;
                TimesheetMainPageController *tsCtrl=(TimesheetMainPageController *)ctrl.controllerDelegate;
                if (tsCtrl.pageControl.currentPage+1<[tsCtrl.tsEntryDataArray count])
                {
                    NSString *formattedDate=[NSString stringWithFormat:@"%@",[[tsCtrl.tsEntryDataArray objectAtIndex:tsCtrl.pageControl.currentPage+1] entryDate]];
                    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
                    [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                    myDateFormatter.dateFormat = @"EEEE, dd MMM yyyy";
                    
                    NSLocale *locale=[NSLocale currentLocale];
                    [myDateFormatter setLocale:locale];
                    NSDate *currentDate=[myDateFormatter dateFromString:[NSString stringWithFormat:@"%@",formattedDate]];
                    myDateFormatter.dateFormat = @"EEE, MMM dd";
                    NSString *currentDateString=[myDateFormatter stringFromDate:currentDate];
                    
                    NSString *in_Time=@"12:00 AM";
                    NSString *out_time=[[saveDictOnOverlap objectForKey:@"out_time"] uppercaseString];
                    NSString *combinedString=[NSString stringWithFormat:@"%@ %@ %@",in_Time,RPLocalizedString(TO_STRING, @""),out_time];
                    
                    
                    NSString *firstPartMsg=RPLocalizedString(MIDNIGHT_CROSSOVER_SPLIT_CONFIRMATION_MSG_PART_1, @"");
                    NSString *lastPartMsg=RPLocalizedString(MIDNIGHT_CROSSOVER_SPLIT_CONFIRMATION_MSG_PART_2, @"");
                    NSString *message=[NSString stringWithFormat:@"%@ %@ %@ %@",firstPartMsg,combinedString,lastPartMsg,currentDateString];
                    
                    BOOL allowSplitTimeMidnightCrossEntry = false;
                    if (ctrl.isGen4UserTimesheet){
                        allowSplitTimeMidnightCrossEntry= [self allowSplitTimeEntryForMidNightCrossPermission:AllowSplitTimeMidNightCrossEntry timesheetUri:[self.tsEntryObj  timesheetUri]];
                        if(allowSplitTimeMidnightCrossEntry){
                            [self splitTimeAndAddEntryForNextDay:indexForMidnight splitDataForLatDayOfTimesheet:NO];
                        }
                    }
                    else
                    {
                        UIAlertController *alertController = [UIAlertController
                                                              alertControllerWithTitle:nil
                                                              message:message
                                                              preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction *cancelAction = [UIAlertAction
                                                       actionWithTitle:RPLocalizedString(@"Cancel", @"Cancel")
                                                       style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action)
                                                       {
                                                           [self clearOutTime:indexForMidnight];
                                                       }];
                        [alertController addAction:cancelAction];
                        
                        UIAlertAction *continueAction = [UIAlertAction
                                                         actionWithTitle:RPLocalizedString(@"Continue", @"Continue")
                                                         style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
                                                         {
                                                             [self splitTimeAndAddEntryForNextDay:indexForMidnight splitDataForLatDayOfTimesheet:NO];
                                                         }];
                        [alertController addAction:continueAction];
                        
                        
                        if ([self.window.rootViewController.presentedViewController isKindOfClass:[UINavigationController class]])
                        {
                            [self.window.rootViewController.presentedViewController presentViewController:alertController animated:YES completion:nil];
                        }
                        else
                        {
                            [delegate presentViewController:alertController animated:YES completion:nil];
                        }
                    }
                    
                }
                else
                {
                    BOOL isInOutTimeWidget = [self isInOutWidgetTimesheet];
                    if(isInOutTimeWidget){
                        UIAlertController *alertController = [UIAlertController
                                                              alertControllerWithTitle:nil
                                                              message:RPLocalizedString(MIDNIGHT_CROSSOVER_MSG_ON_NEXT_TIMESHEET, @"")
                                                              preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction *okAction = [UIAlertAction
                                                   actionWithTitle:RPLocalizedString(@"OK", @"OK")
                                                   style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action)
                                                   {
                                                       [self clearOutTime:indexForMidnight];
                                                   }];
                        [alertController addAction:okAction];
                        
                        if ([self.window.rootViewController.presentedViewController isKindOfClass:[UINavigationController class]])
                        {
                            [self.window.rootViewController.presentedViewController presentViewController:alertController animated:YES completion:nil];
                        }
                        else
                        {
                            [delegate presentViewController:alertController animated:YES completion:nil];
                        }
                    }
                    else{
                        if(self.isSplitTimeEntryAllowedForTimesheet){
                            [self.midNightCrossOverView setHidden:YES];
                            [self splitTimeAndAddEntryForNextDay:indexForMidnight splitDataForLatDayOfTimesheet:YES];
                        }
                        _submit.hidden=YES;
                        self.commentsIconImageView.hidden=NO;
                        self.arrowImageView.hidden=NO;
                        [self validateCell];
                    }
                }
            }
        }
    }
    else
    {
        [self showINProgressAlertView];
    }


}

-(void) submitEntry:(id)sender
{

    int outenteredInt = [self validateSingleEntry:_outTxt.text];
    int inenteredInt = [self validateSingleEntry:_inTxt.text];
    if (inenteredInt!=-1 && outenteredInt!=-1)
    {
        if([_inTxt isFirstResponder])
        {
            [_inTxt endEditing:YES];
        }
        else if([_outTxt isFirstResponder])
        {
            [_outTxt endEditing:YES];
        }
        // [self cellDidFinishEditing:self];
        [self willJumpToNextCell:self];
        BOOL isBreak=NO;
        NSString *breakUri=[self.tsEntryObj breakUri];
        if (breakUri!=nil &&![breakUri isKindOfClass:[NSNull class]]&&![breakUri isEqualToString:@""])
        {
            isBreak=YES;
        }
        //if next cell in is not empty resign.resettablesize no
        if ([delegate isKindOfClass:[MultiDayInOutViewController class]]&&!isBreak)
        {
            MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)delegate;
            BOOL isInTimeEmpty=NO;
            if ([ctrl.timesheetEntryObjectArray count]>cellSection+1)
            {
                TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[ctrl.timesheetEntryObjectArray objectAtIndex:cellSection+1];
                if ([[tsEntryObject timePunchesArray] count]>0)
                {
                    NSString *in_time=[[[tsEntryObject timePunchesArray] objectAtIndex:0] objectForKey:@"in_time"];
                    //NSString *out_time=[[[tsEntryObject timePunchesArray] objectAtIndex:0] objectForKey:@"out_time"];
                    if (in_time==nil||[in_time isKindOfClass:[NSNull class]]||[in_time isEqualToString:@""])
                    {
                        isInTimeEmpty=YES;
                    }

                }
            }

            if (isInTimeEmpty)
            {
                [ctrl resetTableSizeForExtendedInOut:YES];
            }
            else
            {
                [ctrl resetTableSizeForExtendedInOut:NO];
            }

        }

    }
}

-(void) enableSubmitButton {
    [_submit setEnabled:(_inTxt.text.length && _outTxt.text.length)];
}


-(BOOL)checkIsMidNightCrossOverForEntryWithStartTimeValue:(int)startTime endTimeValue:(int)endTime
{
    NSString *calculatedINHours=@"12";
    NSString *calculatedINMins=@"00";
    if (startTime>0)
    {
        if (startTime<1200)
        {
            if ([[NSString stringWithFormat:@"%d",startTime] length]<3)
            {
                calculatedINHours=@"12" ;
                if ([[NSString stringWithFormat:@"%d",startTime] length]==1)
                {
                    calculatedINMins=[NSString stringWithFormat:@"0%d",startTime];
                }
                else
                {
                    calculatedINMins=[NSString stringWithFormat:@"%d",startTime];
                }
            }
            else
            {
                calculatedINHours= [[NSString stringWithFormat:@"%d",startTime] substringToIndex:([[NSString stringWithFormat:@"%d",startTime] length]-2)];
                calculatedINMins=[[NSString stringWithFormat:@"%d",startTime] substringFromIndex:([[NSString stringWithFormat:@"%d",startTime] length]-2)];
            }


        }
        else
        {
            calculatedINHours= [[NSString stringWithFormat:@"%d",startTime] substringToIndex:([[NSString stringWithFormat:@"%d",startTime] length]-2)];
            calculatedINMins=[[NSString stringWithFormat:@"%d",startTime] substringFromIndex:([[NSString stringWithFormat:@"%d",startTime] length]-2)];

        }

    }
    NSString *calculatedOUTHours=@"12";
    NSString *calculatedOUTMins=@"00";
    if (endTime>0)
    {
        if (endTime<1200)
        {
            if ([[NSString stringWithFormat:@"%d",endTime] length]<3)
            {
                calculatedOUTHours=@"12" ;
                if ([[NSString stringWithFormat:@"%d",endTime] length]==1)
                {
                    calculatedOUTMins=[NSString stringWithFormat:@"0%d",endTime];
                }
                else
                {
                    calculatedOUTMins=[NSString stringWithFormat:@"%d",endTime];
                }
            }
            else
            {
                calculatedOUTHours= [[NSString stringWithFormat:@"%d",endTime] substringToIndex:([[NSString stringWithFormat:@"%d",endTime] length]-2)];
                calculatedOUTMins=[[NSString stringWithFormat:@"%d",endTime] substringFromIndex:([[NSString stringWithFormat:@"%d",endTime] length]-2)];
            }


        }
        else
        {
            calculatedOUTHours= [[NSString stringWithFormat:@"%d",endTime] substringToIndex:([[NSString stringWithFormat:@"%d",endTime] length]-2)];
            calculatedOUTMins=[[NSString stringWithFormat:@"%d",endTime] substringFromIndex:([[NSString stringWithFormat:@"%d",endTime] length]-2)];
        }


    }


    NSString *inTimeFormat=@"am";
    if ([calculatedINHours intValue] >12)
    {
        inTimeFormat=@"pm";
        calculatedINHours=[NSString stringWithFormat:@"%d",[calculatedINHours intValue]-12];
    }


    NSString *outimeFormat=@"am";
    if ([calculatedOUTHours intValue] >12)
    {
        outimeFormat=@"pm";
        calculatedOUTHours=[NSString stringWithFormat:@"%d",[calculatedOUTHours intValue]-12];
    }



    NSString *saveInTime=[NSString stringWithFormat:@"%@:%@ %@",calculatedINHours,calculatedINMins, [inTimeFormat lowercaseString]];
    NSString *saveOutTime=[NSString stringWithFormat:@"%@:%@ %@",calculatedOUTHours,calculatedOUTMins,[outimeFormat lowercaseString]];

    NSMutableDictionary *saveEntryDict=[NSMutableDictionary dictionary];
    [saveEntryDict setObject:saveInTime forKey:@"in_time"];
    [saveEntryDict setObject:saveOutTime forKey:@"out_time"];

    BOOL isMidCrossOverForEntry=[Util checkIsMidNightCrossOver:saveEntryDict];
    if (isMidCrossOverForEntry)
    {
        return YES;
    }
    return NO;
}




#pragma mark - UITextFieldDelegate Protocol Implementation

- (void)textFieldDidBeginEditing:(UITextField *)textField
{

    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
    if (![timesheetModel isTimesheetContainsInflightSaveOperation:[self.tsEntryObj timesheetUri]])
    {
        isAmPmButtonClick=NO;
        if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
        {
            MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)delegate;
            [ctrl handleTapAndResetDayScroll];
        }
        textField.textColor = [UIColor blackColor];

        if(textField == _inTxt) {
            _formattedIn.hidden = _inAMPM.hidden = YES;
            _inTxt.text = @"";
            _midNightHours.text=@"";
            [self.midNightCrossOverView setHidden:YES];
            if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
            {
                MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)delegate;
                [ctrl setSectionBeingEdited:(int)self.cellSection];
                [ctrl setRowBeingEdited:(int)self.cellRow];
                [ctrl setLastUsedTextField:_inTxt];
            }
        } else if(textField == _outTxt) {
            _formattedOut.hidden = _outAMPM.hidden = YES;
            _outTxt.text = @"";
            _midNightHours.text=@"";
            [self.midNightCrossOverView setHidden:YES];
            if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
            {
                MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)delegate;
                [ctrl setSectionBeingEdited:(int)self.cellSection];
                [ctrl setRowBeingEdited:(int)self.cellRow];
                [ctrl setLastUsedTextField:_outTxt];
            }
        }

        if (!self.numberKeyPad)
        {
            self.numberKeyPad = [NumberKeypadDecimalPoint keypadForTextField:textField
                                                                withDelegate:delegate
                                                                   withMinus:NO
                                                              andisDoneShown:NO
                                                            withResignButton:YES];
            self.numberKeyPad.delegate = self;
        }
        else
        {
            //if we go from one field to another - just change the textfield, don't reanimate the decimal point button
            self.numberKeyPad.currentTextField = textField;
        }

        _submit.hidden = NO;
        self.commentsIconImageView.hidden=YES;
        self.arrowImageView.hidden=YES;
        [self enableSubmitButton];
        [self cellDidBeginEditing:self];

    }
    else
    {
        [self showINProgressAlertView];
        [textField resignFirstResponder];
    }



}

- (void)textFieldDidChange:(id)sender {
    isAmPmButtonClick=NO;
    UITextField* textField = sender;

    if(textField.text.length == 4) {
        // user entered 4 digits
        int enteredInt = [self validateSingleEntry:textField.text];

        if(enteredInt != -1) {

            //Implemented as per US9178//Juhi
            if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
            {
                MultiDayInOutViewController *ctrl=(MultiDayInOutViewController*)delegate;

                if ([[ctrl inoutTsObjectsArray] count]>0)
                {
                    NSMutableArray *puncharray=[[ctrl inoutTsObjectsArray]objectAtIndex:cellSection];
                    if ([puncharray count]>1)
                    {
                        if (cellRow>1)
                        {
                            InOutTimesheetEntry *obj=(InOutTimesheetEntry *)[[[ctrl inoutTsObjectsArray]objectAtIndex:cellSection] objectAtIndex:cellRow-2];
                            int previousOut=[obj endTime];

                            if (previousOut>=1200)
                            {
                                enteredInt += 1200;
                                if(previousOut==1200 && enteredInt==2400)
                                {
                                    //do nothing
                                }

                                else if(enteredInt >= 2400)
                                {
                                    enteredInt -= 2400;
                                }
                            }
                            else if (previousOut<1200 && enteredInt<1200)
                            {
                                if (enteredInt<previousOut) {
                                    enteredInt += 1200;
                                }
                            }
                            else{

                                enteredInt += 1200;
                                if(enteredInt > 2400)
                                {
                                    enteredInt -= 2400;
                                }

                            }

                        }


                    }

                }
            }
            if (textField == _outTxt)
            {
                if (_currentEntry.startTime!=-1)
                {

                    if (_currentEntry.startTime>=1200) {
                        enteredInt += 1200;
                        if(enteredInt >= 2400)
                        {
                            enteredInt -= 2400;
                        }
                    }

                    else{
                        int tempenteredInt=enteredInt;
                        enteredInt += 1200;

                        if(enteredInt >= 2400)
                        {
                            enteredInt -= 2400;

                        }



                        if ((2400-enteredInt)+_currentEntry.startTime<1200) {
                            enteredInt = tempenteredInt;
                        }
                        if (enteredInt==0)
                        {
                            if (_currentEntry.startTime<1200)
                            {
                                enteredInt=1200;
                            }
                            else
                            {
                                enteredInt=2400;
                            }
                        }

                    }
                }
            }

            // digits are valid
            if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
            {
                MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)delegate;
                [ctrl setRowBeingEdited:(int)cellRow];
                [ctrl setSectionBeingEdited:(int)cellSection];
            }
            if(textField == _inTxt) {
                self.isValueChanged = NO;
                [self saveStartTime:enteredInt saveEndTime:_currentEntry.endTime ignoreOffset:NO onIndex:[sender tag] onSection:cellSection isFromAmPmButton:NO isSendRequest:NO];
                _formattedIn.text = [self formatTimeEntry:_currentEntry.startTime];
                [self setTag:[sender tag]];
                [self cellDidFinishEditing:self];
                [_outTxt becomeFirstResponder];
            } else if(textField == _outTxt) {
                //[self saveStartTime:_currentEntry.startTime saveEndTime:enteredInt ignoreOffset:NO onIndex:[sender tag] onSection:cellSection isFromAmPmButton:NO];
                _formattedOut.text = [self formatTimeEntry:_currentEntry.endTime];
                [self setTag:[sender tag]];
                [self cellDidFinishEditing:self];
                [self willJumpToNextCell:self];
            }

        }
    }

    [self enableSubmitButton];

}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.textColor = [UIColor whiteColor];

    MultiDayInOutViewController *ctrl = (MultiDayInOutViewController *) delegate;

    int enteredInt = [self validateSingleEntry:textField.text];
    if(enteredInt != -1) {
        //Implemented as per US9178//Juhi
        if (enteredInt <= 1200)
        {
            if (textField == _inTxt)
            {
                if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
                {
                    if ([[ctrl inoutTsObjectsArray] count] > 0)
                    {
                        if (cellSection >= 1)
                        {
                            id obj = [[ctrl inoutTsObjectsArray] objectAtIndex:cellSection - 1];
                            if (obj == nil || [obj isKindOfClass:[NSNull class]])
                            {
                                if (enteredInt == 1200)
                                    enteredInt = [self makeMidNightAmEntry];
                            }
                            else
                            {
                                InOutTimesheetEntry *obj = (InOutTimesheetEntry *) [[[ctrl inoutTsObjectsArray] objectAtIndex:cellSection - 1] objectAtIndex:0];
                                int previousOut = [obj endTime];
                                if (previousOut == -1) {
                                    enteredInt = [self getEnteredTimeFromObject:obj enteredInt:enteredInt];
                                }
                                else if (previousOut >= 1200)
                                {
                                    enteredInt += 1200;

                                    if (previousOut == 1200 && enteredInt == 2400)
                                    {
                                        //do nothing
                                        enteredInt = 1200;//Mobi-532 Ullas M L
                                    }

                                    else if (enteredInt >= 2400)
                                    {
                                        enteredInt -= 2400;
                                    }
                                    else if (previousOut > enteredInt){
                                        enteredInt -= 1200;
                                    }
                                }
                                else if (previousOut < 1200 && enteredInt < 1200)
                                {
                                    if (enteredInt < previousOut)
                                    {
                                        enteredInt += 1200;
                                    }
                                }
                                else if (previousOut == 0 && enteredInt == 1200)
                                {
                                    enteredInt = 0;
                                }
                                else
                                {
                                    enteredInt += 1200;
                                    if (enteredInt > 2400)
                                    {
                                        enteredInt -= 2400;
                                    }
                                    else  if (enteredInt == 2400)
                                    {
                                        enteredInt -= 1200;
                                    }

                                }
                            }
                        }
                        else
                        {
                            if (enteredInt == 1200)
                                enteredInt = [self makeMidNightAmEntry];
                        }
                    }
                }
            }
            if (textField == _outTxt)
            {
                if (_currentEntry.startTime!=-1)
                {
                    if (_currentEntry.startTime>=1200)
                    {

                        if (_currentEntry.startTime != enteredInt+1200)
                        {
                            enteredInt += 1200;

                            if(enteredInt >= 2400)
                            {
                                enteredInt -= 2400;
                            }
                            BOOL isSplitEntry = [self isSplitEntry];
                            BOOL isMidnightCrossOver=[self checkIsMidNightCrossOverForEntryWithStartTimeValue:_currentEntry.startTime endTimeValue:enteredInt];
                            if ((isMidnightCrossOver && !isSplitEntry && enteredInt != 0) || (enteredInt==1200 && enteredInt != 0 ))
                            {
                                enteredInt-=1200;
                            }
                        }

                    }
                    else{
                        int tempenteredInt=enteredInt;
                        enteredInt += 1200;

                        if(enteredInt >= 2400)
                        {
                            enteredInt -= 2400;
                        }
                        if ((2400-enteredInt)+_currentEntry.startTime<1200) {
                            enteredInt = tempenteredInt;
                        }
                        if (enteredInt==0)
                        {
                            if (_currentEntry.startTime<1200)
                            {
                                enteredInt=1200;
                            }
                            else
                            {
                                enteredInt=2400;
                            }
                        }
                    }
                }
                else{
                    BOOL isFirstRow = (cellSection == 0);
                    if (isFirstRow && enteredInt == 1200)
                        enteredInt = [self makeMidNightAmEntry];
                    else{
                        if (cellSection >= 1)
                        {
                            id previousEntryObject = nil;
                            previousEntryObject = [[ctrl inoutTsObjectsArray] objectAtIndex:cellSection - 1];
                            if (previousEntryObject != nil && ![previousEntryObject isKindOfClass:[NSNull class]])
                            {
                                InOutTimesheetEntry *inOutTimesheetEntryObject = nil;
                                inOutTimesheetEntryObject = (InOutTimesheetEntry *) [[[ctrl inoutTsObjectsArray] objectAtIndex:cellSection - 1] objectAtIndex:0];
                                enteredInt =  [self getEnteredTimeFromObject:inOutTimesheetEntryObject enteredInt:enteredInt];
                            }
                        }
                    }
                }
            }
        }
        else
        {
            int startEntryTime = self._currentEntry.startTime;
            BOOL isNextDayFirstEntryTimeRange = (enteredInt > 1200 && enteredInt <1300);
            if (startEntryTime>=1300)
            {
                if (textField == _outTxt && isNextDayFirstEntryTimeRange)
                    enteredInt-=1200;
            }
            else if(isNextDayFirstEntryTimeRange)
            {
                if ([[ctrl inoutTsObjectsArray] count] > 0)
                {
                    if (cellSection >= 0)
                    {
                        id obj = nil;
                        if (cellSection == 0) {
                            obj = [[ctrl inoutTsObjectsArray] objectAtIndex:0];
                        }
                        else
                        {
                            obj = [[ctrl inoutTsObjectsArray] objectAtIndex:cellSection - 1];
                        }
                        if (obj != nil && ![obj isKindOfClass:[NSNull class]])
                        {
                            InOutTimesheetEntry *obj = nil;

                            if (cellSection == 0) {
                                obj = (InOutTimesheetEntry *) [[[ctrl inoutTsObjectsArray] objectAtIndex:0] objectAtIndex:0];
                            }
                            else
                            {
                                obj = (InOutTimesheetEntry *) [[[ctrl inoutTsObjectsArray] objectAtIndex:cellSection - 1] objectAtIndex:0];
                            }
                            int entryTime = 0;
                            if (textField == _inTxt)
                                entryTime = [obj endTime];
                            else
                                entryTime = _currentEntry.startTime;
                            BOOL isAmLastOutEntry = entryTime >= 0 && entryTime < 60;
                            BOOL isAmToPmSwich = (enteredInt<(entryTime+1200));
                            if (isAmLastOutEntry && isNextDayFirstEntryTimeRange && !isAmToPmSwich) {
                                enteredInt-=1200;
                            }
                            else
                            {
                                if (textField == _outTxt && _currentEntry.startTime==-1) // no in time
                                {
                                   enteredInt =  [self getEnteredTimeFromObject:obj enteredInt:enteredInt];
                                }
                                else if (textField == _inTxt ) // special case 1201 to 1259 in time which does not includes 0001 to 0059
                                {
                                    enteredInt =  [self getEnteredTimeFromObject:obj enteredInt:enteredInt];
                                }

                            }

                        }
                    }
                }
            }
        }
        
        
        int entryInTime = _currentEntry.startTime;
        BOOL validOutEntry = (textField == _outTxt && entryInTime>-1 && enteredInt>-1);
        if (validOutEntry) {
            if (entryInTime == enteredInt){
                if (entryInTime <1200)
                    enteredInt = enteredInt + 1200;
                else if(entryInTime == 1200) // same 24 hours format for out time ( If In Time == 2359 and Out Time == 2359 , Dont change anything)
                    enteredInt = enteredInt - 1200;
            }
        }

        //Special Case For First Row In Time (12:01 to 12:59 should if AM, if first entry for the day)

        BOOL isFirstEntry = NO;

        if (cellSection==0)
        {
            TimesheetEntryObject *timeEntryObject = nil;
            timeEntryObject = ctrl.timesheetEntryObjectArray[0];
            if (textField == _inTxt)
            {
                isFirstEntry = YES;
            }
            else
            {
                NSDictionary *timeEntry = [timeEntryObject multiDayInOutEntry];
                NSString *inTime = timeEntry[@"in_time"];
                BOOL hasInTime = (inTime != nil && ![inTime isKindOfClass:[NSNull class]] && ![inTime isEqualToString:@""]);
                if (!hasInTime)
                {
                    isFirstEntry = YES;
                }
            }
        }

        else
        {

            if (textField == _inTxt)
            {
                int count = (int)cellSection-1;
                isFirstEntry = [self isFirstEntryForIndex:count];

            }
            if (textField == _outTxt)
            {

                TimesheetEntryObject *timeEntryObject = nil;
                timeEntryObject = ctrl.timesheetEntryObjectArray[cellSection];
                NSDictionary *timeEntry = [timeEntryObject multiDayInOutEntry];
                NSString *inTime = timeEntry[@"in_time"];
                BOOL hasInTime = (inTime != nil && ![inTime isKindOfClass:[NSNull class]] && ![inTime isEqualToString:@""]);
                if (!hasInTime)
                {
                    isFirstEntry = YES;
                    int count = (int)cellSection-1;
                    isFirstEntry = [self isFirstEntryForIndex:count];
                }
                else
                {
                    isFirstEntry = NO;
                    int startTime = _currentEntry.startTime;
                    if (startTime>=0 && startTime<=59 && enteredInt>1200 && enteredInt<1300 && startTime<enteredInt-1200)
                    {
                        enteredInt -= 1200;
                    }

                }
                
            }

        }


        BOOL isAmEntry = (enteredInt>1200 && enteredInt <1300);
        if (isFirstEntry && isAmEntry)
            enteredInt -= 1200;
        // ends here
        
        // special case for in time from 1202 to 1259 1nd out time from 1201 to 1258
        int startTime = _currentEntry.startTime;
        BOOL isInTime12HourEntry = (startTime != -1 && (startTime > 1201 && startTime < 1300));
        if (textField == _outTxt && isInTime12HourEntry) {
            BOOL is12HourAmOutEntry = (enteredInt >1200 && enteredInt<1259);
            BOOL isValidCheck = (isInTime12HourEntry && is12HourAmOutEntry);
            BOOL isPMToAMSwitch = (isValidCheck && enteredInt<startTime);
            if (isPMToAMSwitch)
                enteredInt -= 1200;
        }
        
        if(textField == _inTxt) {
            self.isValueChanged = NO;
            [self saveStartTime:enteredInt saveEndTime:_currentEntry.endTime ignoreOffset:NO onIndex:[textField tag] onSection:cellSection isFromAmPmButton:NO isSendRequest:YES];
        } else if(textField == _outTxt) {
            self.isValueChanged = YES;
            [self saveStartTime:_currentEntry.startTime saveEndTime:enteredInt ignoreOffset:NO onIndex:[textField tag] onSection:cellSection isFromAmPmButton:NO isSendRequest:YES];
        }
        [self cellDidFinishEditing:self];
        if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
        {
            if (textField == _inTxt)
            {
                [ctrl setEditTextFieldTag:1111];
            }
            else
            {
                [ctrl setEditTextFieldTag:2222];
            }
            BOOL isOverlap=NO;
            if (!isAmPmButtonClick)
            {
                isOverlap=[ctrl checkOverlapForPageForExtendedInOut];
            }
            if (isMidNightCrossOver && !isOverlap)
            {
                TimesheetMainPageController *tsCtrl=(TimesheetMainPageController *)ctrl.controllerDelegate;
                if (tsCtrl.pageControl.currentPage +1< [tsCtrl.tsEntryDataArray count])
                {
                    NSString *formattedDate=[NSString stringWithFormat:@"%@",[[tsCtrl.tsEntryDataArray objectAtIndex:tsCtrl.pageControl.currentPage+1] entryDate]];
                    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
                    [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                    myDateFormatter.dateFormat = @"EEEE, dd MMM yyyy";

                    NSLocale *locale=[NSLocale currentLocale];
                    [myDateFormatter setLocale:locale];
                    NSDate *currentDate=[myDateFormatter dateFromString:[NSString stringWithFormat:@"%@",formattedDate]];
                    myDateFormatter.dateFormat = @"EEE, MMM dd";
                    NSString *currentDateString=[myDateFormatter stringFromDate:currentDate];

                    NSString *in_Time=@"12:00 AM";
                    NSString *out_time=[[saveDictOnOverlap objectForKey:@"out_time"] uppercaseString];
                    NSString *combinedString=[NSString stringWithFormat:@"%@ %@ %@",in_Time,RPLocalizedString(TO_STRING, @""),out_time];

                    BOOL allowSplitTimeMidnightCrossEntry= [self allowSplitTimeEntryForMidNightCrossPermission:AllowSplitTimeMidNightCrossEntry timesheetUri:[self.tsEntryObj timesheetUri]];
                    if (!ctrl.isGen4UserTimesheet)
                    {

                        NSString *firstPartMsg=RPLocalizedString(MIDNIGHT_CROSSOVER_SPLIT_CONFIRMATION_MSG_PART_1, @"");
                        NSString *lastPartMsg=RPLocalizedString(MIDNIGHT_CROSSOVER_SPLIT_CONFIRMATION_MSG_PART_2, @"");
                        NSString *message=[NSString stringWithFormat:@"%@ %@ %@ %@",firstPartMsg,combinedString,lastPartMsg,currentDateString];

                        UIAlertController *alertController = [UIAlertController
                                                              alertControllerWithTitle:nil
                                                              message:message
                                                              preferredStyle:UIAlertControllerStyleAlert];

                        UIAlertAction *cancelAction = [UIAlertAction
                                                   actionWithTitle:RPLocalizedString(@"Cancel", @"Cancel")
                                                   style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action)
                                                   {
                                                     [self clearOutTime:indexForMidnight];
                                                   }];
                        [alertController addAction:cancelAction];

                        UIAlertAction *continueAction = [UIAlertAction
                                                   actionWithTitle:RPLocalizedString(@"Continue", @"Continue")
                                                   style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action)
                                                   {
                                                     [self splitTimeAndAddEntryForNextDay:indexForMidnight splitDataForLatDayOfTimesheet:NO];
                                                   }];
                        [alertController addAction:continueAction];


                        if ([self.window.rootViewController.presentedViewController isKindOfClass:[UINavigationController class]])
                        {
                            [self.window.rootViewController.presentedViewController presentViewController:alertController animated:YES completion:nil];
                        }
                        else
                        {
                           [delegate presentViewController:alertController animated:YES completion:nil];
                        }


                    }
                    else if(allowSplitTimeMidnightCrossEntry){
                        [self splitTimeAndAddEntryForNextDay:indexForMidnight splitDataForLatDayOfTimesheet:NO];
                        [_outTxt resignFirstResponder];
                    }
                }
                else
                {
                    BOOL isInOutTimeWidget = [self isInOutWidgetTimesheet];
                    if(isInOutTimeWidget){
                        UIAlertController *alertController = [UIAlertController
                                                              alertControllerWithTitle:nil
                                                              message:RPLocalizedString(MIDNIGHT_CROSSOVER_MSG_ON_NEXT_TIMESHEET, @"")
                                                              preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction *okAction = [UIAlertAction
                                                   actionWithTitle:RPLocalizedString(@"OK", @"OK")
                                                   style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action)
                                                   {
                                                       [self clearOutTime:indexForMidnight];
                                                   }];
                        [alertController addAction:okAction];
                        
                        if ([self.window.rootViewController.presentedViewController isKindOfClass:[UINavigationController class]])
                        {
                            [self.window.rootViewController.presentedViewController presentViewController:alertController animated:YES completion:nil];
                        }
                        else
                        {
                            [delegate presentViewController:alertController animated:YES completion:nil];
                        }
                    }
                    else{
                        if(self.isSplitTimeEntryAllowedForTimesheet){
                            [self.midNightCrossOverView setHidden:YES];
                            [self splitTimeAndAddEntryForNextDay:indexForMidnight splitDataForLatDayOfTimesheet:YES];
                        }
                    }
                }
            }

        }

    }
    else {
        NSString* str=@"";
        if(textField == _inTxt && _currentEntry.startTime != -1) str = [NSString stringWithFormat:@"%i", _currentEntry.startTime];
        else if(textField == _outTxt && _currentEntry.endTime != -1) str = [NSString stringWithFormat:@"%i", _currentEntry.endTime];

        if (_currentEntry.startTime!=-1 && _currentEntry.endTime!=-1)
        {
            self.isValueChanged =  NO;
            [self saveStartTime:_currentEntry.startTime saveEndTime:_currentEntry.endTime ignoreOffset:NO onIndex:[textField tag] onSection:cellSection isFromAmPmButton:NO isSendRequest:YES];
        }

        [textField setText:str];
    }
    if (textField == numberKeyPad.currentTextField)
    {
        [self.numberKeyPad removeButtonFromKeyboard];
        self.numberKeyPad = nil;
        //Fix for MOBI-104//JUHI
        if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
        {
            if(textField == _outTxt)
            [ctrl resetTableSizeForExtendedInOut:NO];//DE19298
        }
    }
    _submit.hidden=YES;//DE19298

    self.commentsIconImageView.hidden=NO;
    self.arrowImageView.hidden=NO;

    [self validateCell];
}

-(void)resignKeyBoard:(UITextField *)textField;
{
    textField.textColor = [UIColor whiteColor];
    if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
    {
        MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)delegate;
        [ctrl resetTableSizeForExtendedInOut:NO];//DE19298
    }
    int enteredInt = [self validateSingleEntry:textField.text];
    if(enteredInt != -1) {
        if(textField == _inTxt) {
            [self saveStartTime:enteredInt saveEndTime:_currentEntry.endTime ignoreOffset:NO onIndex:[textField tag] onSection:cellSection isFromAmPmButton:NO isSendRequest:YES];
        } else if(textField == _outTxt) {
            [self saveStartTime:_currentEntry.startTime saveEndTime:enteredInt ignoreOffset:NO onIndex:[textField tag] onSection:cellSection isFromAmPmButton:NO isSendRequest:YES];
        }
        [self cellDidFinishEditing:self];
    } else {
        NSString* str=@"";
        if(textField == _inTxt && _currentEntry.startTime != -1) str = [NSString stringWithFormat:@"%i", _currentEntry.startTime];
        else if(textField == _outTxt && _currentEntry.endTime != -1) str = [NSString stringWithFormat:@"%i", _currentEntry.endTime];
        [textField setText:str];
    }
    if (textField == numberKeyPad.currentTextField)
    {
        [self.numberKeyPad removeButtonFromKeyboard];
        self.numberKeyPad = nil;

    }
    _submit.hidden=YES;//DE19298
    [self validateCell];

}
-(void)resizeKeyBoardForResigning:(UITextField *)textField
{
    if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
    {
        MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)delegate;
        [ctrl resetTableSizeForExtendedInOut:NO];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 4) ? NO : YES;
}

#pragma mark - Helpers

-(void) validateCell {
    BOOL hasStartTime = (_currentEntry.startTime != -1);
    BOOL hasEndTime = (_currentEntry.endTime != -1);

    _formattedIn.hidden = _inAMPM.hidden = !hasStartTime;
    _formattedOut.hidden = _outAMPM.hidden = !hasEndTime;

    if(hasStartTime) {
        _formattedIn.text = [self formatTimeEntry:_currentEntry.startTime];
        [_inAMPM setSelected:[self isPM:_currentEntry.startTime]];
    }

    if(hasEndTime) {
        if(self.isSplitTimeEntryAllowedForTimesheet){
            MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)delegate;
            TimesheetMainPageController *tsCtrl=(TimesheetMainPageController *)ctrl.controllerDelegate;
            if (tsCtrl.pageControl.currentPage+1>=[tsCtrl.tsEntryDataArray count] && self.isMidNightCrossOver)
            {
                _formattedOut.text = @"11:59";
                [_outAMPM setSelected:YES];
            }
            else{
                _formattedOut.text = [self formatTimeEntry:_currentEntry.endTime];
                [_outAMPM setSelected:[self isPM:_currentEntry.endTime]];
            }
        }else{
            _formattedOut.text = [self formatTimeEntry:_currentEntry.endTime];
            [_outAMPM setSelected:[self isPM:_currentEntry.endTime]];
        }
        
    }

}

-(int) validateSingleEntry:(NSString*)inputString {
    if(inputString.length == 0) return -1;

    BOOL isValidEntry = NO;

    int enteredInt = [inputString intValue];
    if(inputString.length < 3) enteredInt *= 100;

    // validate
    isValidEntry = (enteredInt/100 < 24 && enteredInt%100 <= 59);

    return isValidEntry ? enteredInt : -1;
}

-(NSString*) formatTimeEntry:(int)forEnteredHours {

    if(forEnteredHours == -1) return @"";

    int hours = forEnteredHours/100;
    int mins = forEnteredHours%100;

    NSString* minsWithLeadingZero;
    if(mins < 10) minsWithLeadingZero = [NSString stringWithFormat:@"0%i", mins];
    else minsWithLeadingZero = [NSString stringWithFormat:@"%i", mins];

    return [NSString stringWithFormat:@"%i:%@", (hours%12 == 0 ? 12 : hours%12), minsWithLeadingZero];
}

-(BOOL) isPM:(int)enteredHours {
    return ((enteredHours/100) >= 12);
}

-(UIButton*) makePMButton {
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.adjustsImageWhenHighlighted = NO;
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    btn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [btn setBackgroundImage:self.fieldBackgroundImage forState:UIControlStateNormal];

    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    btn.titleLabel.font = [UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_14];
    btn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
//    [btn setTitleEdgeInsets:UIEdgeInsetsMake(2, 3, 0, 2)];

    [btn setTitle:@"AM" forState:UIControlStateNormal];
    [btn setTitle:@"PM" forState:UIControlStateSelected];
//    [btn sizeToFit];
    [btn addTarget:self action:@selector(toggledAMPM:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)setupTextField:(UITextField *)textField
{
    textField.background = self.fieldBackgroundImage;
    textField.adjustsFontSizeToFitWidth = NO;
    textField.textColor = [UIColor blackColor];
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.keyboardAppearance = UIKeyboardAppearanceDark;
    textField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
    textField.textAlignment = NSTextAlignmentCenter;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
    textField.delegate = self;
    textField.enabled = YES;
    [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

-(void)entryDetailsButtonClickedByUser:(id)sender
{
    TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
    if (![timesheetModel isTimesheetContainsInflightSaveOperation:[self.tsEntryObj timesheetUri]])
    {
        [_inTxt resignFirstResponder];
        [_outTxt resignFirstResponder];

        if([delegate conformsToProtocol:@protocol(InOutTimesheetEntryCellDelegate)] && [delegate respondsToSelector:@selector(cellClickedAtIndex:andSection:)])
        {
            [delegate cellClickedAtIndex:[sender tag] andSection:cellSection];
        }
    }
    else
    {
        [self showINProgressAlertView];
    }

}

- (NSInteger)newObjectIndex:(NSMutableArray*)objectsArray
{
    NSInteger objectIndex = 0;
    for (NSInteger index = 0; index < [objectsArray count]; index++) {
        TimesheetEntryObject *timeEntryObject = objectsArray[index];
        NSDictionary *timeEntry = [timeEntryObject multiDayInOutEntry];
        NSString *inTime = timeEntry[@"in_time"];
        NSString *outTime = timeEntry[@"out_time"];
        BOOL hasInTime = (inTime != nil && ![inTime isKindOfClass:[NSNull class]] && ![inTime isEqualToString:@""]);
        BOOL hasOutTime = (outTime != nil && ![outTime isKindOfClass:[NSNull class]] && ![outTime isEqualToString:@""]);
        BOOL isTimeOffRow = ([[timeEntryObject entryType] isEqualToString:Time_Off_Key]);
        if (hasInTime && hasOutTime && !isTimeOffRow) {
            objectIndex = index;
        }
    }
    return objectIndex;
}


-(void)showINProgressAlertView
{

    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:RPLocalizedString(saveInProgressTitle, @"")
                                          message:RPLocalizedString(saveInProgressText, @"")
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:RPLocalizedString(@"OK", @"OK")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"OK action");
                               }];
    [alertController addAction:okAction];


    [delegate presentViewController:alertController animated:YES completion:nil];


}


#pragma mark - Delegate Protocol

-(void) cellDidFinishEditing:(ExtendedInOutCell*)entryCell {
    // update hours

    if([delegate conformsToProtocol:@protocol(InOutTimesheetEntryCellDelegate)] && [delegate respondsToSelector:@selector(cellDidFinishEditing:)]) {
        //Implentation for US8956//JUHI
        [delegate cellDidFinishEditing:entryCell];
        TimesheetEntryObject *temptsEntryObj=(TimesheetEntryObject *)[[delegate timesheetEntryObjectArray] objectAtIndex:entryCell.cellSection];
        self.tsEntryObj=temptsEntryObj;
    }
    [self calculateAndSetHours:[entryCell tag]];
}

-(void) cellDidBeginEditing:(ExtendedInOutCell *)entryCell {
    if([delegate conformsToProtocol:@protocol(InOutTimesheetEntryCellDelegate)] && [delegate respondsToSelector:@selector(cellDidBeginEditing:)]) {
        [delegate cellDidBeginEditing:entryCell];
    }
}

-(void) willJumpToNextCell:(ExtendedInOutCell *)entryCell {
    if([delegate conformsToProtocol:@protocol(InOutTimesheetEntryCellDelegate)] && [delegate respondsToSelector:@selector(willJumpToNextCell:)]) {
        [delegate willJumpToNextCell:entryCell];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 )
        [self splitTimeAndAddEntryForNextDay:[alertView tag] splitDataForLatDayOfTimesheet:NO];
    else if (buttonIndex == 0)
        [self clearOutTime:[alertView tag]];
}

- (void)splitTimeAndAddEntryForNextDay:(NSInteger)tag splitDataForLatDayOfTimesheet:(BOOL)shouldSplitDataForLatDayOfTimesheet
{
    if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
    {
        NSString *outTimeForNextDay=[saveDictOnOverlap objectForKey:@"out_time"];
        NSString *inTimeForCurrentDay=[saveDictOnOverlap objectForKey:@"in_time"];
        
        NSMutableDictionary *dictForCurrentDay= [self getCurrentDayDictionary:inTimeForCurrentDay];
        NSMutableDictionary *dictForNextDay = [self getNextDayDictionary:outTimeForNextDay];
        
        MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)delegate;
        if(!shouldSplitDataForLatDayOfTimesheet){
            [dictForCurrentDay setObject:[NSNull null] forKey:SplitTimeEntryForNextTimesheetPeriod];
        }
        else{
            [dictForCurrentDay setObject:dictForNextDay forKey:SplitTimeEntryForNextTimesheetPeriod];
        }
        [ctrl updateExtendedInOutTimeEntryForSplitOnIndex:tag forSection:cellSection withValue:dictForCurrentDay];
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:tag inSection:cellSection];
        [ctrl.multiDayTimeEntryTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        if(!shouldSplitDataForLatDayOfTimesheet){
            BOOL isGen4ExtendedInOutTimesheet =  false;
            NSString *timesheetFormat = [self getTimesheetFormat:nil];
            if (timesheetFormat != nil && ![timesheetFormat isKindOfClass:[NSNull class]]) {
                if ([timesheetFormat  isEqualToString:GEN4_EXT_INOUT_TIMESHEET]) {
                    isGen4ExtendedInOutTimesheet =  true;
                }
            }
            
            NSString *currentDayInTime= [Util appendZeroSecondsToWithoutSecondsTimeString:inTimeForCurrentDay];
            
            BOOL isInOutWidgetTimesheet = (ctrl.isGen4UserTimesheet && !isGen4ExtendedInOutTimesheet);
            
            if (isInOutWidgetTimesheet) {
                [dictForCurrentDay setObject:currentDayInTime forKey:@"in_time"];
                [dictForCurrentDay setObject:@"11:59:59 pm" forKey:@"out_time"];
                [ctrl updateExtendedInOutTimeEntryForIndex:tag forSection:cellSection withValue:dictForCurrentDay sendRequest:YES];
            }
            
            TimesheetMainPageController *timesheetMainPageControllerObj  = (TimesheetMainPageController *)ctrl.controllerDelegate;
            NSMutableArray *controllerObjectsArray = [timesheetMainPageControllerObj viewControllers];
            NSInteger nextControllerIndex = [controllerObjectsArray indexOfObject:ctrl]+1;
            
            [ctrl changeViewToNextDayView:cellSection rowIndex:tag withValue:dictForNextDay controllerIndex:nextControllerIndex];
            
            if (isInOutWidgetTimesheet) {
                NSMutableArray *entryObjectsArray = [timesheetMainPageControllerObj.timesheetDataArray objectAtIndex:nextControllerIndex];
                NSInteger objectIndex = [self newObjectIndex:entryObjectsArray];
                if ([delegate isKindOfClass:[MultiDayInOutViewController class]]){
                    MultiDayInOutViewController *multiDayInOutViewController = (MultiDayInOutViewController *)[timesheetMainPageControllerObj.viewControllers objectAtIndex:nextControllerIndex];
                    if (multiDayInOutViewController!=nil && ![multiDayInOutViewController isKindOfClass:[NSNull class]])
                    {
                        [multiDayInOutViewController updateExtendedInOutTimeEntryForIndex:tag forSection:objectIndex withValue:dictForNextDay sendRequest:YES];
                    }
                    
                }
            }
        }
    }
}

-(NSMutableDictionary *)getCurrentDayDictionary:(NSString *)inTimeForCurrentDay{
    NSMutableDictionary *dictForCurrentDay=[NSMutableDictionary dictionary];
    [dictForCurrentDay setObject:@"11:59 pm" forKey:@"out_time"];
    [dictForCurrentDay setObject:inTimeForCurrentDay forKey:@"in_time"];
    [dictForCurrentDay setObject:[NSNumber numberWithBool:YES] forKey:@"isMidnightCrossover"];
    return dictForCurrentDay;
}
-(NSMutableDictionary *)getNextDayDictionary:(NSString *)outTimeForNextDay{
    NSMutableDictionary *dictForNextDay=[NSMutableDictionary dictionary];
    [dictForNextDay setObject:outTimeForNextDay forKey:@"out_time"];
    [dictForNextDay setObject:@"12:00 am" forKey:@"in_time"];
    return dictForNextDay;
}

- (void)clearOutTime:(NSInteger)tag
{
    [_outTxt becomeFirstResponder];
    _currentEntry.endTime=-1;
    _currentEntry.hours=[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]];
    [self calculateAndSetHours:cellRow];
    NSString *inTimeForCurrentDay=[saveDictOnOverlap objectForKey:@"in_time"];
    NSMutableDictionary *dictForCurrentDay=[NSMutableDictionary dictionary];
    [dictForCurrentDay setObject:@"" forKey:@"out_time"];
    [dictForCurrentDay setObject:inTimeForCurrentDay forKey:@"in_time"];
    MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)delegate;
    BOOL sendRequest = NO;
    BOOL isInOutWidgetTimesheet =  [self isInOutWidgetTimesheet];
    if (isInOutWidgetTimesheet)
        sendRequest = YES;
    [ctrl updateExtendedInOutTimeEntryForIndex:tag forSection:cellSection withValue:dictForCurrentDay sendRequest:sendRequest];
}

- (BOOL)allowSplitTimeEntryForMidNightCrossPermission:(NSString *)permission timesheetUri:(NSString *)timesheetUri
{
    BOOL allowSplitTimeMidnightCrossEntry = false;
    MultiDayInOutViewController *multiDayInOutViewController_Object = (MultiDayInOutViewController *) delegate;
    if (multiDayInOutViewController_Object.isGen4UserTimesheet) {
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        allowSplitTimeMidnightCrossEntry = [timesheetModel readIsSplitTimeEntryForMidNightCrossOverPermission:permission forTimesheetIdentity:timesheetUri];
    }
    return allowSplitTimeMidnightCrossEntry;
}

-(NSString*)getTimesheetFormat:(NSString*)approvalsModuleName
{
    NSString *timeSheetFormat = nil;
    if(approvalsModuleName==nil)
    {
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        timeSheetFormat=[timesheetModel getTimesheetFormatforTimesheetUri:[self.tsEntryObj timesheetUri]];
    }
    else
    {
        ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];
        if ([approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
        {
            timeSheetFormat=[approvalsModel getTimesheetFormatforTimesheetUri:[self.tsEntryObj timesheetUri] andIsPending:YES];
        }
        else
        {
            timeSheetFormat=[approvalsModel getTimesheetFormatforTimesheetUri:[self.tsEntryObj timesheetUri] andIsPending:NO];
        }
    }
    return timeSheetFormat;
}

#pragma mark - New Am And Pm Logic

-(int)checkWithLastEntriesFromEnteredTime:(int)enteredInt
{
    MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)delegate;
    int currentEnteredTime = enteredInt;
    int currentCellIndex = (int)cellSection;
    BOOL hasValue = false;
    for (int index = currentCellIndex-1; index>=0; index--) {
        if ([[ctrl inoutTsObjectsArray] objectAtIndex:index]!=nil && ![[[ctrl inoutTsObjectsArray] objectAtIndex:index] isKindOfClass:[NSNull class]])
        {
            InOutTimesheetEntry *obj = (InOutTimesheetEntry *) [[[ctrl inoutTsObjectsArray] objectAtIndex:index] objectAtIndex:0];
            int previousIn = [obj startTime];
            int previousOut = [obj endTime];
            if (previousOut != -1) {
                hasValue = true;
                currentEnteredTime =  [self getTimeAfterComparingFromLastEntryTime:previousOut enteredInt:currentEnteredTime];
                return currentEnteredTime;
            }
            else  if (previousIn !=-1) {
                hasValue = true;
                currentEnteredTime =  [self getTimeAfterComparingFromLastEntryTime:previousIn enteredInt:currentEnteredTime];
                return currentEnteredTime;
            }
        }

    }
    if (enteredInt == 1200 && !hasValue) {
        currentEnteredTime =  [self makeMidNightAmEntry];
    }
    
    return currentEnteredTime;
}

-(int)getTimeAfterComparingFromLastEntryTime:(int)lastEntryTime enteredInt:(int)enteredInt
{
    int currentEnteredTime = enteredInt;
    int lastEnteredTime = lastEntryTime;
    BOOL isAmLastEntry = (lastEnteredTime<1200);
    BOOL isAmCurrentEntry = (currentEnteredTime<1200);
    
    BOOL isNextDayFirstEntryTimeRange = (currentEnteredTime > 1200 && currentEnteredTime <1300 && (lastEntryTime+1200)<=currentEnteredTime);
    BOOL isAmLastOutEntry = lastEnteredTime >= 0 && lastEnteredTime < 60;
    if (isAmLastOutEntry && isNextDayFirstEntryTimeRange) {
        return currentEnteredTime-=1200;
    }
    
    if (isAmLastEntry && isAmCurrentEntry) {
        if (lastEnteredTime>currentEnteredTime) {
            currentEnteredTime+= 1200;
        }
    }
    else if(!isAmLastEntry && !isAmCurrentEntry){
        if (lastEnteredTime>currentEnteredTime) {
            currentEnteredTime-= 1200;
        }
    }
    else if (!isAmLastEntry && isAmCurrentEntry)
    {
        currentEnteredTime+= 1200;
        if (lastEnteredTime>currentEnteredTime) {
            currentEnteredTime-= 1200;
        }
    }
    else{
        if (lastEntryTime == 0 && currentEnteredTime == 1200)
            currentEnteredTime = lastEntryTime;
        else if (lastEntryTime == 1200 && currentEnteredTime == 0)
            currentEnteredTime = lastEntryTime;
    }
    return abs(currentEnteredTime);
}

-(int)getEnteredTimeFromObject:(InOutTimesheetEntry*)inOutTimesheetEntry enteredInt:(int)enteredInt
{
    int currentEnteredTime = 0;
    int previousInTime =  [inOutTimesheetEntry startTime];
    int previousOutTime =  [inOutTimesheetEntry endTime];
    if (previousOutTime != -1)
        currentEnteredTime = [self getTimeAfterComparingFromLastEntryTime:previousOutTime enteredInt:enteredInt];
    else if (previousInTime != -1)
        currentEnteredTime = [self getTimeAfterComparingFromLastEntryTime:previousInTime enteredInt:enteredInt];
    else
        currentEnteredTime = [self checkWithLastEntriesFromEnteredTime:enteredInt];
    return currentEnteredTime;
}

-(int)makeMidNightAmEntry
{
    int currentEnteredTime = 1200;
    currentEnteredTime -= 1200;
    return currentEnteredTime;
}

-(BOOL)isInOutWidgetTimesheet
{
    MultiDayInOutViewController *multiDayInOutViewController_Object = (MultiDayInOutViewController *) delegate;
    BOOL isGen4ExtendedInOutTimesheet  = false;
    NSString *timesheetFormat = [self getTimesheetFormat:nil];
    if (timesheetFormat != nil && ![timesheetFormat isKindOfClass:[NSNull class]]) {
        if ([timesheetFormat  isEqualToString:GEN4_EXT_INOUT_TIMESHEET]) {
            isGen4ExtendedInOutTimesheet =  true;
        }
    }
    BOOL isInOutWidgetTimesheet = (multiDayInOutViewController_Object.isGen4UserTimesheet && !isGen4ExtendedInOutTimesheet);
    return isInOutWidgetTimesheet;
}

-(NSMutableDictionary*)dictionaryOfInAndOutTimeWithSeconds:(NSString*)inTime
{
    NSString *currentDayInTime= [Util appendZeroSecondsToWithoutSecondsTimeString:inTime];
    
    NSMutableDictionary *dictForCurrentDay = [NSMutableDictionary dictionary];
    [dictForCurrentDay setObject:currentDayInTime forKey:@"in_time"];
    [dictForCurrentDay setObject:@"11:59:59 pm" forKey:@"out_time"];
    return dictForCurrentDay;
}

-(BOOL)isSplitEntry
{
    BOOL isSplitEntry = NO;
    BOOL isMidNightCrossOverEntry =  false;
    NSDictionary *multiDayInOutDict = [self.tsEntryObj multiDayInOutEntry];
    NSString *outTimeEntry = multiDayInOutDict[@"out_time"];
    if (multiDayInOutDict[@"isMidnightCrossover"]!= nil && ![multiDayInOutDict[@"isMidnightCrossover"] isKindOfClass:[NSNull class]]) {
        isMidNightCrossOverEntry = multiDayInOutDict[@"isMidnightCrossover"];
    }
    BOOL isLocalEntryWithSeconds = ([outTimeEntry isEqualToString:@"11:59:59 pm"] || [outTimeEntry isEqualToString:@"11:59:59 PM"]);
    BOOL isServerEntryWithMidNightCross = (([outTimeEntry isEqualToString:@"11:59 pm"] || [outTimeEntry isEqualToString:@"11:59 PM"]) && isMidNightCrossOverEntry);
    if (isLocalEntryWithSeconds || isServerEntryWithMidNightCross)
        return YES;
    
    return isSplitEntry;
}

-(BOOL)isFirstEntryForIndex:(int)count
{
    BOOL isFirstEntry = YES;
    MultiDayInOutViewController *ctrl = (MultiDayInOutViewController *) delegate;
    do {
        TimesheetEntryObject *timeEntryObject = nil;
        timeEntryObject = ctrl.timesheetEntryObjectArray[count];
        NSDictionary *timeEntry = [timeEntryObject multiDayInOutEntry];
        NSString *inTime = timeEntry[@"in_time"];
        NSString *outTime = timeEntry[@"out_time"];
        BOOL hasInTime = (inTime != nil && ![inTime isKindOfClass:[NSNull class]] && ![inTime isEqualToString:@""]);
        BOOL hasOutTime = (outTime != nil && ![outTime isKindOfClass:[NSNull class]] && ![outTime isEqualToString:@""]);
        BOOL isTimeOffRow = ([[timeEntryObject entryType] isEqualToString:Time_Off_Key]);
        if (hasInTime || hasOutTime)
        {
            isFirstEntry = NO;
            break;
        }
        else if (isTimeOffRow)
        {
            isFirstEntry = YES;
            break;
        }
        else
        {
            isFirstEntry = YES;
        }
        count--;
    } while (count>=0 && isFirstEntry == YES);


    return isFirstEntry;
}

@end
