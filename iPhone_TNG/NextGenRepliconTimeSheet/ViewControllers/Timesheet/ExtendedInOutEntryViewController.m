//
//  ExtendedInOutEntryViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 19/11/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import "ExtendedInOutEntryViewController.h"
#import "Constants.h"
#import "Util.h"
#import "InOutProjectHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "MultiDayInOutViewController.h"
#import "EntryCellDetails.h"
#import "TimesheetUdfView.h"
#import "AddDescriptionViewController.h"
#import <CoreText/CoreText.h>
#import "NSString+Double_Float.h"
#import "SupportDataModel.h"
#import "RepliconServiceManager.h"
#import "OEFObject.h"
#import "UIView+Additions.h"

#define HEADER_LABEL_HEIGHT 26
#define LABEL_PADDING 10
#define PROJECT_HEADER_LABEL_HEIGHT 50
#define HOURS_WIDTH (SCREEN_WIDTH/4)+2
#define TIME_VIEW_HEIGHT 45
#define Each_Cell_Row_Height_44 44
#define COMMENTS_LABEL_HEIGHT 40

#define resetTableSpaceHeight 220
#define resetTableSpaceHeight_Other_UDF 180
#define resetTableSpaceHeight_Date_UDF 220
#define LABEL_WIDTH (SCREEN_WIDTH - (2*LABEL_PADDING))
#define DELETE_BUTTON_PADDING 40
#define DELETE_BUTTON_HEIGHT 44


@interface ExtendedInOutEntryViewController ()

@end

@implementation ExtendedInOutEntryViewController
@synthesize currentPageDate;
@synthesize tsEntryObject;
@synthesize isProjectAccess;
@synthesize isActivityAccess;
@synthesize row;
@synthesize section;
@synthesize hours;
@synthesize inoutEntryTableView;
@synthesize sheetApprovalStatus;
@synthesize commentsControlDelegate;
@synthesize lastUsedTextField;
@synthesize selectedUdfCell;
@synthesize datePicker;
@synthesize cancelButton;
@synthesize previousDateUdfValue;
@synthesize doneButton;
@synthesize spaceButton;
@synthesize pickerClearButton;
@synthesize toolbar;
@synthesize commentsTextView;
@synthesize tableFooterView;
@synthesize tableHeaderView;
@synthesize isEditState;
@synthesize isTextViewBecomeFirstResponder;
@synthesize userFieldArray;
@synthesize isBreakAccess;//ImplementationForExtendedInOutDeleteBreak_US9103//JUHI
@synthesize isBillingAccess;
@synthesize attributedString;
@synthesize isGen4UserTimesheet;

#pragma mark - View methods
- (void)loadView
{
	[super loadView];
    [self.view setBackgroundColor:RepliconStandardWhiteColor];
    if (isBreakAccess)
    {
       [Util setToolbarLabel: self withText:RPLocalizedString(BREAK_ENTRY_DETAILS_STRING, @"")]; 
    }
    else
        [Util setToolbarLabel: self withText:RPLocalizedString(ENTRY_DETAILS_STRING, @"")];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UITableView *tableView=[[UITableView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,[self heightForTableView])];
    self.inoutEntryTableView=tableView;
   
    [self.inoutEntryTableView setDelegate:self];
    [self.inoutEntryTableView setDataSource:self];
    [self.inoutEntryTableView setBackgroundColor:[Util colorWithHex:@"#eeeeee" alpha:1]];
    [self.inoutEntryTableView setSeparatorColor:[Util colorWithHex:@"#cccccc" alpha:1]];
    [self.view addSubview:self.inoutEntryTableView];
    
    UIBarButtonItem *tempLeftButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(Cancel_Button_Title, @"") style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)];
    [[self navigationItem ] setLeftBarButtonItem:tempLeftButtonOuterBtn animated:NO];
   
    
    self.tableFooterView=[self getTableFooter];
    self.tableHeaderView=[self getTableHeader];
    [self.inoutEntryTableView setTableFooterView:self.tableFooterView];
    [self.inoutEntryTableView setTableHeaderView:self.tableHeaderView];
    
    BOOL hasUdfOrOefField =  NO;
    if (isGen4UserTimesheet)
    {
        self.userFieldArray=[NSMutableArray array];
        self.oefFieldArray=[tsEntryObject timeEntryCellOEFArray];
        hasUdfOrOefField = (self.oefFieldArray != nil && ![self.oefFieldArray isKindOfClass:[NSNull class]] && self.oefFieldArray.count>0);
    }
    else
    {
        self.userFieldArray=[NSMutableArray arrayWithArray:[[[tsEntryObject timePunchesArray] objectAtIndex:row] objectForKey:@"udfArray"]] ;
        hasUdfOrOefField = (self.userFieldArray != nil && ![self.userFieldArray isKindOfClass:[NSNull class]] && self.userFieldArray.count>0);
    }
    
    BOOL isTimeEntryCommentsAllowed = [self isTimeEntryCommentsAllowed];
    
    BOOL shouldShowSaveButton =  (isEditState && !isBreakAccess && (isTimeEntryCommentsAllowed || hasUdfOrOefField));
    
    if (shouldShowSaveButton)
    {
        UIBarButtonItem *tempRightButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(Save_Button_Title, @"") style:UIBarButtonItemStylePlain target:self action:@selector(saveAction:)];
        [self navigationItem].rightBarButtonItem=tempRightButtonOuterBtn;
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.inoutEntryTableView setFrame:CGRectMake(0,0,self.view.frame.size.width, [self heightForTableView]) ];

}

-(void)becomeFirstResponderAction
{
    if (isEditState && ![[tsEntryObject entryType] isEqualToString:Time_Off_Key])
    {
        self.isTextViewBecomeFirstResponder=YES;
        [self.commentsTextView becomeFirstResponder];
        
        CGPoint point=[self.inoutEntryTableView convertPoint:CGPointMake(self.inoutEntryTableView.tableFooterView.bounds.origin.x, self.inoutEntryTableView.tableFooterView.bounds.origin.y) fromView:self.inoutEntryTableView.tableFooterView];
        [self.inoutEntryTableView setContentOffset:point];
    }
    
}
-(UIView *)initialiseView:(NSMutableDictionary *)dataDict
{
    UIView *returnView=[UIView new];

    UIView *separatorView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.inoutEntryTableView.width, 0.5)];
    [separatorView setBackgroundColor:[Util colorWithHex:@"#cccccc" alpha:1.0]];
    [returnView addSubview:separatorView];
    [returnView bringSubviewToFront:separatorView];

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
    BOOL isMiddleLabelTextWrap=[[dataDict objectForKey:MIDDLE_LABEL_TEXT_WRAP] boolValue];
    BOOL isLowerLabelTextWrap=[[dataDict objectForKey:LOWER_LABEL_TEXT_WRAP] boolValue];
    float height=[[dataDict objectForKey:CELL_HEIGHT_KEY] newFloatValue];


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
        [returnView addSubview:middleLeft];
        [middleLeft setText:middleStr];
        
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
                    UIImage *breakImage=[UIImage imageNamed:@"icon_break_small"];
                    UIImageView *breakImageView=[[UIImageView alloc]initWithImage:breakImage];
                    breakImageView.frame=CGRectMake(10.0, (height - breakImage.size.height)/2, breakImage.size.width, breakImage.size.height);
                    [returnView addSubview:breakImageView];
                    middleLeft.frame=CGRectMake(10.0+breakImage.size.width+10, 14.0, LABEL_WIDTH-50, middleLblHeight);
                }
            
            [middleLeft setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16]];
            [middleLeft setNumberOfLines:100];
        }
        else
        {
            [middleLeft setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
            middleLeft.frame=CGRectMake(10.0,5.0, LABEL_WIDTH, EachDayTimeEntry_Cell_Row_Height_44);
            if (isMiddleLabelTextWrap)
            {
                [middleLeft setNumberOfLines:1];
                
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

                    if ([string length]!=[middleStr length])
                    {
                        string = [NSString stringWithFormat:@" %@",NON_BILLABLE];
                    }
                    if ([middleStr rangeOfString:NON_BILLABLE].location != NSNotFound)
                    {
                            [tmpattributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,[string length])];
                    }

                    [middleLeft setText:[tmpattributedString string]];
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

        if (isTaskPresent)
        {
            [upperLeft setFont:[UIFont fontWithName:RepliconFontFamilySemiBold size:RepliconFontSize_16]];
        }
        else
        {
            [upperLeft setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
        }
        
        [upperLeft setText:upperStr];
        [upperLeft setNumberOfLines:100];
        [upperLeft setHighlightedTextColor:[UIColor whiteColor]];
        [returnView addSubview:upperLeft];
        
        float yLower=upperLeft.frame.origin.y+upperLeft.frame.size.height+5;
        UILabel *lowerLeft = [[UILabel alloc] init];
        lowerLeft.frame=CGRectMake(10.0, yLower, LABEL_WIDTH, lowerLblHeight);
        [lowerLeft setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
        [lowerLeft setText:lowerStr];
        
        if (isLowerLabelTextWrap)
        {
            [lowerLeft setNumberOfLines:1];
            
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

                if ([string length]!=[lowerStr length])
                {
                    string = [NSString stringWithFormat:@" %@",NON_BILLABLE];
                }
                if ([lowerStr rangeOfString:NON_BILLABLE].location != NSNotFound)
                {
                    [tmpattributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,[string length])];
                }
                    [lowerLeft setAttributedText:tmpattributedString];
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
        [upperLeft setFont:[UIFont fontWithName:RepliconFontFamilySemiBold size:RepliconFontSize_16]];
        [upperLeft setText:upperStr];
        [upperLeft setNumberOfLines:100];
        [returnView addSubview:upperLeft];
        
        float ymiddle=upperLeft.frame.origin.y+upperLeft.frame.size.height+5;
        UILabel *middleLeft = [[UILabel alloc] init];
        middleLeft.frame=CGRectMake(10.0, ymiddle, LABEL_WIDTH, middleLblHeight);
        [middleLeft setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
        [middleLeft setText:middleStr];
        [middleLeft setNumberOfLines:100];
        [returnView addSubview:middleLeft];
        
        
        float ylower=middleLeft.frame.origin.y+middleLeft.frame.size.height+5;
        UILabel *lowerLeft = [[UILabel alloc] init];
        lowerLeft.clipsToBounds = NO;
        lowerLeft.frame=CGRectMake(10.0, ylower - 2, LABEL_WIDTH, lowerLblHeight + 4);
        [lowerLeft setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
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

            if ([string length]!=[lowerStr length])
            {
                string = [NSString stringWithFormat:@" %@",NON_BILLABLE];
            }
            if ([lowerStr rangeOfString:NON_BILLABLE].location != NSNotFound)
            {
                [tmpattributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,[string length])];
                
            }
            [lowerLeft setAttributedText:tmpattributedString];
        }
        [lowerLeft setNumberOfLines:1];
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


-(float)getHeightForString:(NSString *)string fontSize:(int)fontSize forWidth:(float)width
{

    // Let's make an NSAttributedString first
    NSMutableAttributedString *attributedString1 = [[NSMutableAttributedString alloc] initWithString:string];
    //Add LineBreakMode
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [attributedString1 setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString1.length)];
    // Add Font
    [attributedString1 setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:RepliconFontSize_14]} range:NSMakeRange(0, attributedString1.length)];
    
    //Now let's make the Bounding Rect
    CGSize mainSize = [attributedString1 boundingRectWithSize:CGSizeMake(width, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    if (mainSize.width==0 && mainSize.height ==0)
    {
        mainSize=CGSizeMake(0,0);
    }
    NSString *fontName=nil;
    if (fontSize==RepliconFontSize_16)
    {
        fontName=RepliconFontFamilySemiBold;
    }
    else
    {
        fontName=RepliconFontFamily;
    }
    CGSize maxSize = CGSizeMake(width, MAXFLOAT);
    CGRect labelRect = [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:fontName size:fontSize]} context:nil];
    return labelRect.size.height;
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

-(NSString *)getTheAttributedTextForEntryObject
{
    NSUInteger numberOfUDF=0;
    if (isGen4UserTimesheet)
    {
        numberOfUDF=[self.oefFieldArray count];
    }
    else
    {
       numberOfUDF=[self.userFieldArray count];
    }

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
    if (isBillingAccess)
    {
        NSMutableDictionary *billingDict=[NSMutableDictionary dictionaryWithObject:tmpBillingValue forKey:@"BILLING"];
        [array addObject:billingDict];
    }
    else
    {
        tmpBillingValue=@"";
    }
    //DE18721 Ullas M L
    if (isActivityAccess)
    {
        if (tsActivityName!=nil && ![tsActivityName isKindOfClass:[NSNull class]]&& ![tsActivityName isEqualToString:@""])
        {
            NSMutableDictionary *activityDict=[NSMutableDictionary dictionaryWithObject:tsActivityName forKey:@"ACTIVITY"];
            [array addObject:activityDict];
            
        }
    }
    
    for (int i=0; i<numberOfUDF; i++)
    {
        EntryCellDetails *cellDetails=nil;
        OEFObject *oefObject=nil;
        NSString *udfValue=nil;
        NSString *udfsystemDefaultValue=nil;
        if (isGen4UserTimesheet)
        {
            oefObject=[self.oefFieldArray objectAtIndex:i];
            if (oefObject.oefNumericValue!=nil && ![oefObject.oefNumericValue isKindOfClass:[NSNull class]])
            {
                udfValue=[oefObject oefNumericValue];
            }
            else if (oefObject.oefTextValue!=nil && ![oefObject.oefTextValue isKindOfClass:[NSNull class]])
            {
                udfValue=[oefObject oefTextValue];
            }
            else if (oefObject.oefDropdownOptionValue!=nil && ![oefObject.oefDropdownOptionValue isKindOfClass:[NSNull class]])
            {
                udfValue=[oefObject oefDropdownOptionValue];
            }

        }
        else
        {
            cellDetails=[self.userFieldArray objectAtIndex:i];
            udfValue=[cellDetails fieldValue];
            udfsystemDefaultValue=[cellDetails systemDefaultValue];
        }

        if (udfValue!=nil && ![udfValue isEqualToString:RPLocalizedString(ADD_STRING, @"")] &&
            ![udfValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]&&
            ![udfValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
        {
            NSMutableDictionary *udfDict=[NSMutableDictionary dictionaryWithObject:udfValue forKey:@"UDF"];
            [array addObject:udfDict];
        }
        else
        {
            if (udfsystemDefaultValue!=nil && ![udfsystemDefaultValue isKindOfClass:[NSNull class]]&&
                ![udfsystemDefaultValue isEqualToString:@""]&&
                ![udfsystemDefaultValue isEqualToString:NULL_STRING]&&
                ![udfsystemDefaultValue isEqualToString:NULL_OBJECT_STRING])
            {
                NSMutableDictionary *udfDict=[NSMutableDictionary dictionaryWithObject:udfsystemDefaultValue forKey:@"UDF"];
                [array addObject:udfDict];
            }
        }
        
    }
    
    
    
    float labelWidth=LABEL_WIDTH;
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
                str=[Util stringByTruncatingToWidth:labelWidth withFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12] ForString:str addQuotes:YES];
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


-(UIView *)getTableFooter
{
    float yOffsetForButtonFromTextView=30;
    float textViewHeight=0;
    textViewHeight = 60;
    float footerHeight=0.0;
    if (isEditState)
    { 
        footerHeight=textViewHeight+2*yOffsetForButtonFromTextView+44+40+COMMENTS_LABEL_HEIGHT;
    }
    else
    {
        footerHeight=textViewHeight+50+COMMENTS_LABEL_HEIGHT;
    }
    //ImplementationForExtendedInOutDeleteBreak_US9103//JUHI
    UIView *tempfooterView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.inoutEntryTableView.width, footerHeight)];
    BOOL isTimeEntryCommentsAllowed=[self isTimeEntryCommentsAllowed];

    if (isTimeEntryCommentsAllowed)
    {
        UIView *lineViewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0,tempfooterView.width, 1)];
        lineViewTop.backgroundColor = [Util colorWithHex:@"#cccccc" alpha:1];
        [tempfooterView addSubview:lineViewTop];
        
        CGFloat hourLabelPadding = 10.0;
        UILabel *hourLabel = [[UILabel alloc] initWithFrame:CGRectMake(hourLabelPadding, 0,tempfooterView.width-(2*hourLabelPadding), COMMENTS_LABEL_HEIGHT)];
        hourLabel.font = [UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_16];
        hourLabel.text=[NSString stringWithFormat:@"%@:",RPLocalizedString(Comments, Comments)];
        [tempfooterView addSubview:hourLabel];

        
        UIButton *deleteButton =[UIButton buttonWithType:UIButtonTypeCustom];
        [deleteButton setFrame:CGRectMake(0, 0,tempfooterView.width, 44)];
        deleteButton.cornerRadius = 22.0f;
        [deleteButton addTarget:self action:@selector(becomeFirstResponderAction) forControlEvents:UIControlEventTouchUpInside];
        deleteButton.contentHorizontalAlignment= UIControlContentHorizontalAlignmentCenter;
        [tempfooterView addSubview:deleteButton];
    
        NSMutableDictionary *inoutDict=[[tsEntryObject timePunchesArray]objectAtIndex:row];
        NSString *comments=[inoutDict objectForKey:@"comments"];
        CGFloat textViewPadding = 2.0;
        UITextView *descTextView = [[UITextView alloc] initWithFrame:CGRectMake(textViewPadding, COMMENTS_LABEL_HEIGHT-10, self.view.width - (2*textViewPadding), textViewHeight)];
        descTextView.textColor = RepliconStandardBlackColor;
        descTextView.scrollEnabled = YES;
        [descTextView setShowsVerticalScrollIndicator:YES];
        [descTextView setShowsHorizontalScrollIndicator:NO];
        [descTextView setAutocorrectionType: UITextAutocorrectionTypeYes];
        [descTextView setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
        descTextView.font = [UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_16];
        descTextView.delegate = self;
        descTextView.backgroundColor = [UIColor clearColor];
        descTextView.keyboardType = UIKeyboardTypeASCIICapable;
        descTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.commentsTextView=descTextView;
        [descTextView setText:comments];
        [tempfooterView addSubview: descTextView];
        [tempfooterView sendSubviewToBack: descTextView];
        
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, COMMENTS_LABEL_HEIGHT+textViewHeight,self.view.frame.size.width, 1)];
        if (isBreakAccess)
        {
            lineView.frame=CGRectMake(0, COMMENTS_LABEL_HEIGHT,self.view.frame.size.width, 1);
        }
        lineView.backgroundColor = [Util colorWithHex:@"#cccccc" alpha:1];
        [tempfooterView addSubview:lineView];

        UIView *commentsBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CGRectGetMaxY(lineView.frame))];
        commentsBackgroundView.backgroundColor = [UIColor whiteColor];
        [tempfooterView insertSubview:commentsBackgroundView atIndex:0];
        
    }
    
    
    
    
    if (isEditState && ![[tsEntryObject entryType] isEqualToString:Time_Off_Key])
    {
        UIButton *deleteButton =[UIButton buttonWithType:UIButtonTypeCustom];
        CGSize deleteButtonSize = CGSizeMake(self.view.width-(2*DELETE_BUTTON_PADDING), DELETE_BUTTON_HEIGHT);
        CGPoint deleteButtonOrigin = CGPointMake(DELETE_BUTTON_PADDING, COMMENTS_LABEL_HEIGHT+textViewHeight+yOffsetForButtonFromTextView);
        [deleteButton setFrame:(CGRect){deleteButtonOrigin,deleteButtonSize}];
        if (!isTimeEntryCommentsAllowed)
        {
            deleteButtonOrigin.y = COMMENTS_LABEL_HEIGHT+1;
            [deleteButton setFrame:(CGRect){deleteButtonOrigin,deleteButtonSize}];
            BOOL isBreakPresent=NO;
            NSString *breakUri=[tsEntryObject breakUri];
            if (breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]] && ![breakUri isEqualToString:@""])
            {
                isBreakPresent=YES;
            }
            
            if (isBreakPresent)
            {
                [deleteButton setTitle:RPLocalizedString(DELETE_BREAKENTRY_STRING,@"") forState:UIControlStateNormal];
            }
            else
            {
                [deleteButton setTitle:RPLocalizedString(DELETE_ENTRY_STRING,@"") forState:UIControlStateNormal];
            }
        }
        else
        {
            [deleteButton setTitle:RPLocalizedString(DELETE_ENTRY_STRING,@"") forState:UIControlStateNormal];
        }

        [deleteButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamilySemiBold size:RepliconFontSize_16]];
        [deleteButton setTitleColor:[Util colorWithHex:@"#fa6759" alpha:1] forState:UIControlStateNormal];
        [deleteButton setBackgroundColor:[UIColor whiteColor]];
        deleteButton.layer.cornerRadius = 22.0f;
        deleteButton.layer.borderColor = [[Util colorWithHex:@"#cccccc" alpha:1] CGColor];
        deleteButton.layer.borderWidth = 1.0f;
        [deleteButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
        deleteButton.contentHorizontalAlignment= UIControlContentHorizontalAlignmentCenter;
        [tempfooterView addSubview:deleteButton];

    }
    else
    {
        [self.commentsTextView setEditable:NO];
    }

    return tempfooterView;
}

-(UIView *)getTableHeader
{
    UIView *headerView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.inoutEntryTableView.width, HEADER_LABEL_HEIGHT)];
    CGRect frame=CGRectMake(0, 0, headerView.width, HEADER_LABEL_HEIGHT);
    UIView *headerBackgroundView=[[UIView alloc]initWithFrame:frame];
    [headerBackgroundView setBackgroundColor:[Util colorWithHex:@"#eeeeee" alpha:1]];
    [headerView addSubview:headerBackgroundView];
   
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"EEEE, MMM dd, yyy"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];//MOBI-537 Ullas M L
    NSString *string=[formatter stringFromDate:currentPageDate];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectInset(frame, LABEL_PADDING, 0)];
    headerLabel.textColor = [UIColor blackColor];
    headerLabel.font = [UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12];
    headerLabel.textAlignment = NSTextAlignmentLeft;
    headerLabel.text=string;
    [headerView addSubview:headerLabel];
   
    
    UIView *separatorView=[[UIView alloc]initWithFrame:CGRectMake(0, HEADER_LABEL_HEIGHT, headerView.width, 1)];
    [separatorView setBackgroundColor:[Util colorWithHex:@"#cccccc" alpha:1]];
    [headerView addSubview:separatorView];
    
    
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
    BOOL isTimeoffSickRow=[tsEntryObject isTimeoffSickRowPresent];
    BOOL isBreak=NO;
    NSString *breakUri=[tsEntryObject breakUri];
    if (breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]]&&![breakUri isEqualToString:@""])
    {
        isBreak=YES;
    }
    if (isTimeoffSickRow||isBreak)
    {
        if (isBreak)
        {
            NSString *breakName=[tsEntryObject breakName];
            middleStr=breakName;
            middleLabelHeight=[self getHeightForString:breakName fontSize:RepliconFontSize_16 forWidth:LABEL_WIDTH];
            [heightDict setObject:@"SINGLE" forKey:LINE];
        }
        else
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
                            middleStr=[NSString stringWithFormat:@"%@ for %@",timeEntryProjectName,timeEntryClientName];
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
                            upperStr=[NSString stringWithFormat:@"%@ for %@",timeEntryProjectName,timeEntryClientName];
                        }
                        lowerStr=attributeText;
                        isLowerLabelTextWrap=YES;
                        upperLabelHeight=[self getHeightForString:upperStr fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                        lowerLabelHeight=[self getHeightForString:lowerStr fontSize:RepliconFontSize_12 forWidth:LABEL_WIDTH];
                        [heightDict setObject:@"DOUBLE" forKey:LINE];
                        
                    }
                    
                }
                
            }
            else
            {
                
                NSString *attributeText=[self getTheAttributedTextForEntryObject];
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
                    lowerStr=[NSString stringWithFormat:@"in %@",timeEntryProjectName];
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
                    middleStr=[NSString stringWithFormat:@"in %@",timeEntryProjectName];
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
    if (cellHeight<EachDayTimeEntry_Cell_Row_Height_55)
    {
        cellHeight=EachDayTimeEntry_Cell_Row_Height_55;
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
    
    headerView.backgroundColor = [UIColor whiteColor];
    UIView *tmpHeaderView=[[UIView alloc]initWithFrame:CGRectMake(0, HEADER_LABEL_HEIGHT, headerView.width, cellHeight)];
    UIView *view=[self initialiseView:heightDict];
    [tmpHeaderView addSubview:view];
    [headerView addSubview:tmpHeaderView];
    
    NSMutableDictionary *inoutDict=[[tsEntryObject timePunchesArray]objectAtIndex:row];
    NSString *inTime=[inoutDict objectForKey:@"in_time"];
    NSString *outTime=[inoutDict objectForKey:@"out_time"];
    
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
    else if ([timeInCompsArr count]==3)
    {
        hrstr=[timeInCompsArr objectAtIndex:0];
        minsStr=[timeInCompsArr objectAtIndex:1];
        if ([hrstr intValue]==0) {
            hrstr=@"12";
        }
        NSArray *amPmCompsArr=[[timeInCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
        if ([amPmCompsArr count]==2)
        {
            NSString *ampmStr=[amPmCompsArr objectAtIndex:1];
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
    else if ([timeOutCompsArr count]==3)
    {
        outhrstr=[timeOutCompsArr objectAtIndex:0];
        outminsStr=[timeOutCompsArr objectAtIndex:1];
        if ([outhrstr intValue]==0) {
            hrstr=@"12";
        }
        NSArray *amPmCompsArr=[[timeOutCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
        if ([amPmCompsArr count]==2)
        {
            NSString *ampmStr=[amPmCompsArr objectAtIndex:1];
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
    
    UIImage *timeEntryViewImage = [Util thumbnailImage:IN_OUT_ENTRY_BACKGROUND_IMAGE];
    UIView *timeInOutBackGroundView=[[UIView alloc]initWithFrame:CGRectMake(0, cellHeight+HEADER_LABEL_HEIGHT, headerView.width, timeEntryViewImage.size.height+12)];
    
    float xOffset=5.0;
    float _timeInHoursWidth=(headerView.width/5)+1;
    UILabel *_timeInHours = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, 0, _timeInHoursWidth, timeEntryViewImage.size.height)];
    _timeInHours.backgroundColor = [UIColor clearColor];
    _timeInHours.font = [UIFont fontWithName:RepliconFontFamilyRegular size:17];
    _timeInHours.textAlignment = NSTextAlignmentRight;
    _timeInHours.userInteractionEnabled=NO;
    _timeInHours.text=startTimeStr;
    [timeInOutBackGroundView addSubview:_timeInHours];
   
    CGFloat buttonWidth = headerView.width/10;
    if (isInTimeAMPMImageShow)
    {
        UIButton *timeInAmPMButton = [[UIButton alloc] initWithFrame:CGRectMake(_timeInHours.right, (timeEntryViewImage.size.height - 22)/2, buttonWidth, 22)];

        timeInAmPMButton.titleLabel.font = [UIFont fontWithName:RepliconFontFamilyRegular size:14];
        timeInAmPMButton.userInteractionEnabled=NO;
        timeInAmPMButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [timeInAmPMButton setTitle:inAmPmStr forState:UIControlStateNormal];
        [timeInAmPMButton setTitleColor:RepliconStandardBlackColor forState:UIControlStateNormal];
        [timeInOutBackGroundView addSubview:timeInAmPMButton];
        
    }
    
    float toLabelWidth= headerView.width/9;
    UILabel *toLabel = [[UILabel alloc] initWithFrame:CGRectMake(_timeInHours.right+buttonWidth, 0, toLabelWidth, timeEntryViewImage.size.height)];
    toLabel.backgroundColor = [UIColor clearColor];
    toLabel.font = [UIFont fontWithName:RepliconFontFamilyLight size:14];
    [toLabel setTextColor:[Util colorWithHex:@"#cccccc" alpha:1.0]];
    toLabel.textAlignment = NSTextAlignmentRight;
    toLabel.userInteractionEnabled=NO;
    toLabel.text=RPLocalizedString(TO_STRING, @"");
    [timeInOutBackGroundView addSubview:toLabel];
    
    float _timeOutHoursWidth=_timeInHoursWidth;
    UILabel *_timeOutHours = [[UILabel alloc] initWithFrame:CGRectMake(toLabel.right, 0, _timeOutHoursWidth, timeEntryViewImage.size.height)];
    _timeOutHours.textAlignment = NSTextAlignmentRight;
    _timeOutHours.font = [UIFont fontWithName:RepliconFontFamilyRegular size:17];
    _timeOutHours.userInteractionEnabled=NO;
    _timeOutHours.text=endTimeStr;
    [timeInOutBackGroundView addSubview:_timeOutHours];
   
    
    if (isOutTimeAMPMImageShow)
    {
        UIButton *timeOutAmPMButton = [[UIButton alloc] initWithFrame:CGRectMake(_timeOutHours.right, (timeEntryViewImage.size.height-22)/2, buttonWidth, 22)];
        timeOutAmPMButton.titleLabel.font = [UIFont fontWithName:RepliconFontFamilyRegular size:14];
        timeOutAmPMButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        timeOutAmPMButton.userInteractionEnabled=NO;
        [timeOutAmPMButton setTitle:outAmPmStr forState:UIControlStateNormal];
        [timeOutAmPMButton setTitleColor:RepliconStandardBlackColor forState:UIControlStateNormal];
        [timeInOutBackGroundView addSubview:timeOutAmPMButton];
    }
    
    float xhourLabel=timeInOutBackGroundView.width-HOURS_WIDTH-1;
    UILabel *hourLabel = [[UILabel alloc] initWithFrame:CGRectMake(xhourLabel, 0,HOURS_WIDTH, timeEntryViewImage.size.height)];
    hourLabel.font = [UIFont fontWithName:RepliconFontFamilySemiBold size:17];
    hourLabel.textAlignment = NSTextAlignmentCenter;
    hourLabel.userInteractionEnabled=NO;
    hourLabel.text=hours;
    [timeInOutBackGroundView addSubview:hourLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, timeEntryViewImage.size.height+8,self.view.frame.size.width, 1)];
    lineView.backgroundColor = [Util colorWithHex:@"#cccccc" alpha:1];
    [timeInOutBackGroundView addSubview:lineView];
    [timeInOutBackGroundView sendSubviewToBack:lineView];
    
    
    float xPositionForVerticalLine =  headerView.width - HOURS_WIDTH;
    UIView *verticalLineView = [[UIView alloc] initWithFrame:CGRectMake(xPositionForVerticalLine, 0, 1, timeEntryViewImage.size.height)];
    verticalLineView.backgroundColor = [Util colorWithHex:@"#cccccc" alpha:1];
    [timeInOutBackGroundView addSubview:verticalLineView];
    [timeInOutBackGroundView sendSubviewToBack:verticalLineView];
    
    [headerView addSubview:timeInOutBackGroundView];
    [headerView setFrame:CGRectMake(0, 0, self.inoutEntryTableView.width, HEADER_LABEL_HEIGHT+cellHeight+timeEntryViewImage.size.height+8)];
    
    return headerView;
}

-(void)reloadViewAfterEntryEdited
{
    self.tableHeaderView=[self getTableHeader];
    [self.inoutEntryTableView setTableHeaderView:self.tableHeaderView];
    
    
}

-(void)resetTableSize:(BOOL)isResetTable isFromUdf:(BOOL)isFromUdf isDateUdf:(BOOL)isDateUdf
{
    if (isResetTable)
    {
        if (isFromUdf)
        {
            CGRect frame= self.inoutEntryTableView.frame;
            
            
            if (isDateUdf)
            {
                frame.size.height=[self heightForTableView]-resetTableSpaceHeight_Date_UDF;
            }
            else
            {
                frame.size.height=[self heightForTableView]-resetTableSpaceHeight_Other_UDF;
                
            }
            
            [self.inoutEntryTableView setFrame:frame];
        }
        else
        {
            CGRect frame= self.inoutEntryTableView.frame;
            CGRect screenRect =[[UIScreen mainScreen] bounds];
            float aspectRatio=(screenRect.size.height/screenRect.size.width);
            float movementDistanceoffSet=0.0;
            if (aspectRatio<1.7)
            {
                movementDistanceoffSet=86;
            }
            else
            {
                movementDistanceoffSet=140;
            }
            frame.size.height=[self heightForTableView]-movementDistanceoffSet;
            [self.inoutEntryTableView setFrame:frame];
            
            if (!isTextViewBecomeFirstResponder)
            {
                [self.inoutEntryTableView scrollRectToVisible:[self.inoutEntryTableView convertRect:self.inoutEntryTableView.tableFooterView.bounds fromView:self.inoutEntryTableView.tableFooterView] animated:YES];
            }
            
            
            
        }
        
        
        
    }
    else
    {
        [self.inoutEntryTableView setFrame:CGRectMake(0,0,self.view.frame.size.width, [self heightForTableView]) ];
        [self.inoutEntryTableView scrollRectToVisible:CGRectMake(0,0,self.view.frame.size.width, CGRectGetHeight([[UIScreen mainScreen] bounds])) animated:NO];
        
    }
}

-(BOOL)isTimeEntryCommentsAllowed
{
    BOOL isTimeEntryCommentsAllowed = NO;
    
    if (isBreakAccess)
        isTimeEntryCommentsAllowed = NO;
    else if (isGen4UserTimesheet)
    {
        SupportDataModel *supportDataModel=[[SupportDataModel alloc]init];
        NSDictionary *permittedApprovalAcionsDict=[supportDataModel getTimesheetPermittedApprovalActionsDataToDBWithUri:[tsEntryObject timesheetUri]];
        
        if (self.timesheetFormat!=nil && ![self.timesheetFormat isKindOfClass:[NSNull class]])
        {
            if ([self.timesheetFormat isEqualToString:GEN4_INOUT_TIMESHEET])
            {
                isTimeEntryCommentsAllowed=[[permittedApprovalAcionsDict objectForKey:@"allowTimeEntryCommentsForInOutGen4"] boolValue];
            }
            else if ([self.timesheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
            {
                isTimeEntryCommentsAllowed=[[permittedApprovalAcionsDict objectForKey:@"allowTimeEntryCommentsForExtInOutGen4"] boolValue];
            }
        }
    }
    else
        isTimeEntryCommentsAllowed = YES;
    return isTimeEntryCommentsAllowed;
}

#pragma mark UITextView Delegates

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self doneClicked];
    self.lastUsedTextField =nil;
    [self resetTableSize:YES isFromUdf:NO isDateUdf:NO];
    self.isTextViewBecomeFirstResponder=NO;
    UIBarButtonItem *tempRightButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(Done_Button_Title, @"") style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonAction:)];
    [self navigationItem].rightBarButtonItem=tempRightButtonOuterBtn;
    
    [self.inoutEntryTableView setScrollEnabled:NO];
	return YES;
}

- (BOOL) textView: (UITextView*) textView shouldChangeTextInRange: (NSRange) range replacementText: (NSString*) text
{
    /*if ([text isEqualToString:@"\n"]) {
        [self resetTableSize:NO isFromUdf:NO isDateUdf:NO];
        [textView resignFirstResponder];
        
        return NO;
    }*/
    return YES;
}


-(void)textViewDidChangeSelection:(UITextView *)textView {
    [textView scrollRangeToVisible:textView.selectedRange];
}

-(void)doneButtonAction:(id)sender
{
    [self.commentsTextView setContentOffset:CGPointZero animated:NO];
    [self.inoutEntryTableView setScrollEnabled:YES];
    [self resetTableSize:NO isFromUdf:NO isDateUdf:NO];
    [self.commentsTextView resignFirstResponder];

    UIBarButtonItem *tempRightButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(Save_Button_Title, @"") style:UIBarButtonItemStylePlain target:self action:@selector(saveAction:)];
    [self navigationItem].rightBarButtonItem=tempRightButtonOuterBtn;
   

}

#pragma mark - Tableview methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return Each_Cell_Row_Height_44;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{//ImplementationForExtendedInOutDeleteBreak_US9103//JUHI
    if (!isBreakAccess)
    {
        if (isGen4UserTimesheet)
        {
          return [self.oefFieldArray count];
        }
        else
        {
          return [self.userFieldArray count];
        }

    }
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"TimeSheetCellIdentifier";
	InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];


	if (cell == nil)
    {
        cell = [[InOutEntryDetailsCustomCell  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];


	}

    NSString *fieldType=nil;
    NSString *fieldName=nil;
    NSString *fieldValue=nil;
    EntryCellDetails *udfDetails=nil;
    OEFObject *oefObject=nil;

    if (isGen4UserTimesheet)
    {
        oefObject=[self.oefFieldArray objectAtIndex:indexPath.row];
        fieldName=[oefObject oefName];
        if (oefObject.oefNumericValue!=nil && ![oefObject.oefNumericValue isKindOfClass:[NSNull class]])
        {
            fieldValue=[oefObject oefNumericValue];
        }
        else if (oefObject.oefTextValue!=nil && ![oefObject.oefTextValue isKindOfClass:[NSNull class]])
        {
            fieldValue=[oefObject oefTextValue];
        }
        else if (oefObject.oefDropdownOptionValue!=nil && ![oefObject.oefDropdownOptionValue isKindOfClass:[NSNull class]])
        {
            fieldValue=[oefObject oefDropdownOptionValue];
        }

        fieldType=[oefObject oefDefinitionTypeUri];

        [cell createCellLayoutWithParamsWithFieldName:fieldName withFieldValue:fieldValue isEditState:isEditState];
        cell.udfType=fieldType;
    }
    else
    {
        udfDetails=[self.userFieldArray objectAtIndex:indexPath.row];
        fieldName=[udfDetails fieldName];
        fieldValue=[udfDetails fieldValue];
        fieldType=[udfDetails fieldType];

        [cell createCellLayoutWithParamsWithFieldName:fieldName withFieldValue:fieldValue isEditState:isEditState];
        cell.udfType=fieldType;
    }
    

        if ([fieldType isEqualToString:UDFType_DATE])
        {
            if ([fieldValue isKindOfClass:[NSString class]] &&[fieldValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])
            {
                [cell.fieldButton setText:RPLocalizedString(NONE_STRING, @"")];
            }
            else
            {
                if ([fieldValue isKindOfClass:[NSString class]]&&[fieldValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
                {
                    [cell.fieldButton setText:fieldValue];
                }
                else
                {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    NSLocale *locale=[NSLocale currentLocale];
                    [dateFormatter setLocale:locale];
                    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
                     NSDate *date=[dateFormatter dateFromString:fieldValue];
                    if(date == nil) {
                        [dateFormatter setDateFormat:@"MMM d, yyyy"];
                        date = [dateFormatter dateFromString:fieldValue];
                    }
                    [dateFormatter setDateFormat:@"MMMM d, yyyy"];
                    [cell.fieldButton setText: [dateFormatter stringFromDate:date]];

                }
            }
            
            cell.fieldButton.hidden=NO;
            cell.fieldValue.hidden=YES;
            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
                [sheetApprovalStatus isEqualToString:APPROVED_STATUS ])
            {
                cell.contentView.userInteractionEnabled=NO;
            }
            else
            {
                cell.contentView.userInteractionEnabled=YES;
            }
            
        }
        else if([fieldType isEqualToString:UDFType_NUMERIC] || [fieldType isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI])
        {
            cell.fieldValue.text=[NSString stringWithFormat:@"%@",fieldValue];
            [cell.fieldButton setText:[NSString stringWithFormat:@"%@",fieldValue]];
            cell.fieldButton.hidden=NO;
            cell.fieldValue.hidden=YES;
            if (fieldValue==nil)
            {
                if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[sheetApprovalStatus isEqualToString:APPROVED_STATUS ])
                {
                    cell.fieldButton.text=RPLocalizedString(NONE_STRING, @"");
                }
                else
                {
                    cell.fieldButton.text=RPLocalizedString(ADD, @"");
                }

                
            }
            cell.fieldValue.keyboardType = UIKeyboardTypeNumberPad;
            //Fix for ios7//JUHI
            cell.fieldValue.keyboardAppearance=UIKeyboardAppearanceDark;
            if (!isGen4UserTimesheet)
            {
                cell.decimalPoints=[udfDetails decimalPoints];
            }
            else
            {
                cell.decimalPoints=2.0;
            }

            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
                [sheetApprovalStatus isEqualToString:APPROVED_STATUS ])
            {
                cell.contentView.userInteractionEnabled=NO;
            }
            else
            {
                cell.contentView.userInteractionEnabled=YES;
            }
            
        }
        else if ([fieldType isEqualToString:UDFType_DROPDOWN] || [fieldType isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI])
        {
            [cell.fieldButton setText:fieldValue];
            cell.fieldButton.hidden=NO;
            cell.fieldValue.hidden=YES;

            if (fieldValue==nil)
            {
                if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[sheetApprovalStatus isEqualToString:APPROVED_STATUS ])
                {
                    cell.fieldButton.text=RPLocalizedString(NONE_STRING, @"");
                }
                else
                {
                    cell.fieldButton.text=RPLocalizedString(SELECT_STRING, @"");
                }

                
            }

            if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
                [sheetApprovalStatus isEqualToString:APPROVED_STATUS ])
            {
                cell.contentView.userInteractionEnabled=NO;
            }
            else
            {
                cell.contentView.userInteractionEnabled=YES;
            }
            
        }
        
        else if([fieldType isEqualToString:UDFType_TEXT] || [fieldType isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI])
        {
            cell.fieldButton.text=fieldValue;
            if (fieldValue==nil)
            {
                if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[sheetApprovalStatus isEqualToString:APPROVED_STATUS ])
                {
                    cell.fieldButton.text=RPLocalizedString(NONE_STRING, @"");
                }
                else
                {
                    cell.fieldButton.text=RPLocalizedString(ADD, @"");
                }


            }
            cell.fieldButton.hidden=NO;
            cell.fieldValue.hidden=YES;
            if (([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||[sheetApprovalStatus isEqualToString:APPROVED_STATUS ])&&([cell.fieldButton.text isEqualToString:RPLocalizedString(ADD, @"")]||[cell.fieldButton.text isEqualToString:RPLocalizedString(NONE_STRING, @"")]))
            {
                cell.contentView.userInteractionEnabled=NO;
            }
            else
            {
                cell.contentView.userInteractionEnabled=YES;
            }
            
        }
    
    cell.isNonEditable=NO;
    if ([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||
        [sheetApprovalStatus isEqualToString:APPROVED_STATUS ])
    {
        cell.contentView.userInteractionEnabled=NO;
        cell.fieldButton.userInteractionEnabled=NO;
        cell.fieldValue.userInteractionEnabled=NO;
        cell.isNonEditable=YES;
    }

        
    
    [cell setDelegate:self];
    [cell.contentView setTag:indexPath.row];
    if (isGen4UserTimesheet)
    {
       [cell setTotalCount:[self.oefFieldArray count]];
    }
    else
    {
      [cell setTotalCount:[self.userFieldArray count]];
    }

    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
	return cell;
	
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  
}

#pragma mark - Save/Cancel methods

- (void)saveAction:(id)sender
{
    if (isGen4UserTimesheet)
    {
        NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:[[tsEntryObject timePunchesArray] objectAtIndex:row]];
        NSString *timePunchesUri=[dict objectForKey:@"timePunchesUri"];
        NSString *clientPunchID=[dict objectForKey:@"clientID"];

        NSString *entryUri = timePunchesUri != nil  && timePunchesUri != (id)[NSNull null] && ![timePunchesUri isEqualToString:@""]  ? timePunchesUri : clientPunchID;
        NSString *entryUriColumnName = timePunchesUri != nil  && timePunchesUri != (id)[NSNull null] && ![timePunchesUri isEqualToString:@""]  ? @"timePunchesUri" : @"clientPunchId";

        NSString *commetsTxt=self.commentsTextView.text;
        if (commetsTxt==nil||[commetsTxt isKindOfClass:[NSNull class]]||[commetsTxt isEqualToString:@""]) {
            commetsTxt=@"";
        }
        [dict setObject:commetsTxt forKey:@"comments"];
        
        [tsEntryObject setTimeEntryComments:commetsTxt];
        
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SAVE_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gen4TimeEntrySaveResponseReceived:) name:SAVE_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
        [[RepliconServiceManager timesheetService] sendRequestToSaveWorkTimeEntryForGen4:self withClientID:entryUri isBlankTimeEntrySave:NO withTimeEntryUri:timePunchesUri withStartDate:[tsEntryObject timeEntryDate] forTimeSheetUri:[tsEntryObject timesheetUri] withTimeDict:dict timesheetFormat:self.timesheetFormat andColumnNameForEntryUri:entryUriColumnName];
        if (commentsControlDelegate!=nil && [commentsControlDelegate isKindOfClass:[MultiDayInOutViewController class]])
        {
            MultiDayInOutViewController *multiDayInOutViewController=(MultiDayInOutViewController*)commentsControlDelegate;
            [multiDayInOutViewController updateUserChangedFlag];
        }

    }
    else
    {
        [self doneClicked];
        [lastUsedTextField resignFirstResponder];
        [self.commentsTextView resignFirstResponder];
        
        if (commentsControlDelegate!=nil && [commentsControlDelegate isKindOfClass:[MultiDayInOutViewController class]])
        {
            [commentsControlDelegate updateComments:self.commentsTextView.text andUdfArray:self.userFieldArray forRow:row forSection:section];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
        [datePicker removeFromSuperview];
        datePicker=nil;
    }
    
}

- (void)cancelAction:(id)sender
{
    if (commentsControlDelegate!=nil && [commentsControlDelegate isKindOfClass:[MultiDayInOutViewController class]])
    {
        [commentsControlDelegate setIsNavigation:FALSE];
    }
    
    [self doneClicked];
    [lastUsedTextField resignFirstResponder];
    [self.commentsTextView resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
    [datePicker removeFromSuperview];
    datePicker=nil;
}
- (void)deleteAction:(id)sender
{
    if (isGen4UserTimesheet)
    {
        if (commentsControlDelegate!=nil && [commentsControlDelegate isKindOfClass:[MultiDayInOutViewController class]])
        {
            MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)commentsControlDelegate;
            TimesheetEntryObject *deleteEntryObject=(TimesheetEntryObject *)[ctrl.timesheetEntryObjectArray objectAtIndex:section];
//            NSMutableDictionary *deleteDict=[[deleteEntryObject timePunchesArray] objectAtIndex:row];
//            NSString *timePunchesUri=[deleteDict objectForKey:@"timePunchesUri"];
            NSString *breakUri=[deleteEntryObject breakUri];
            BOOL isWorkEntry=NO;
            if (breakUri==nil||[breakUri isKindOfClass:[NSNull class]]||[breakUri isEqualToString:@""]) {
                isWorkEntry=YES;
            }
            [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:DELETE_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
           
           
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gen4TimeEntryDeleteResponseReceived:) name:DELETE_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
            
             NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:[[deleteEntryObject timePunchesArray] objectAtIndex:row]];
             NSString *clientPunchID=[dict objectForKey:@"clientID"];
             NSString *timePunchesUri=[dict objectForKey:@"timePunchesUri"];

            NSString *entryUri = timePunchesUri != nil  && timePunchesUri != (id)[NSNull null] && ![timePunchesUri isEqualToString:@""] ? timePunchesUri : clientPunchID;
            NSString *entryUriColumnName = timePunchesUri != nil  && timePunchesUri != (id)[NSNull null] && ![timePunchesUri isEqualToString:@""] ? @"timePunchesUri" : @"clientPunchId";
            
            [[RepliconServiceManager timesheetService] sendRequestToDeleteTimeEntryForGen4WithClientUri:entryUri withDelegate:self isWork:isWorkEntry withTimesheetUri:[deleteEntryObject timesheetUri] withRow:row withSection:section withEntryDate:[Util convertDateToTimestamp:[deleteEntryObject timeEntryDate]] timesheetFormat:self.timesheetFormat andColumnNameForEntryUri:entryUriColumnName];
            if (commentsControlDelegate!=nil && [commentsControlDelegate isKindOfClass:[MultiDayInOutViewController class]])
            {
                MultiDayInOutViewController *multiDayInOutViewController=(MultiDayInOutViewController*)commentsControlDelegate;
                [multiDayInOutViewController updateUserChangedFlag];
            }
        }
        
    }
    else
    {
        [self.commentsTextView resignFirstResponder];
        [self.lastUsedTextField resignFirstResponder];
        [self doneClicked];
        InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[self. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedUdfCell inSection:0]];
        [cell.fieldValue resignFirstResponder];
        if (commentsControlDelegate!=nil && [commentsControlDelegate isKindOfClass:[MultiDayInOutViewController class]])
        {
            [commentsControlDelegate deleteMutiInOutEntryforRow:row forSection:section withDelegate:self];
        }
        [self.navigationController popViewControllerAnimated:YES];
        
        [datePicker removeFromSuperview];
        datePicker=nil;
    }
    
}
-(void)gen4TimeEntryDeleteResponseReceived:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DELETE_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];;
    if (commentsControlDelegate!=nil && [commentsControlDelegate isKindOfClass:[MultiDayInOutViewController class]])
    {
        MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)commentsControlDelegate;
        [ctrl setIsNavigation:FALSE];
        [self.commentsTextView resignFirstResponder];
        [self.lastUsedTextField resignFirstResponder];
        [self doneClicked];
        InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[self. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedUdfCell inSection:0]];
        [cell.fieldValue resignFirstResponder];
        if (commentsControlDelegate!=nil && [commentsControlDelegate isKindOfClass:[MultiDayInOutViewController class]])
        {
            [ctrl gen4TimeEntryDeleteResponseReceived:[notification userInfo]];
        }
        [self.navigationController popViewControllerAnimated:YES];
        
        [datePicker removeFromSuperview];
        datePicker=nil;
        
    }
}
-(void)gen4TimeEntrySaveResponseReceived:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SAVE_TIME_ENTRY_GEN4_RECEIVED_NOTIFICATION object:nil];
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];;
    if (commentsControlDelegate!=nil && [commentsControlDelegate isKindOfClass:[MultiDayInOutViewController class]])
    {
        [self doneClicked];
        [lastUsedTextField resignFirstResponder];
        [self.commentsTextView resignFirstResponder];
        
        if (commentsControlDelegate!=nil && [commentsControlDelegate isKindOfClass:[MultiDayInOutViewController class]])
        {
            MultiDayInOutViewController *ctrl=(MultiDayInOutViewController *)commentsControlDelegate;
            NSDictionary *theData = [notification userInfo];
            NSString *receivedClientID=[theData objectForKey:@"clientId"];
            NSString *receivedPunchID=[theData objectForKey:@"timeEntryUri"];
            
            for (int i=0; i<[ctrl.timesheetEntryObjectArray count]; i++)
            {
                TimesheetEntryObject *tsObject=(TimesheetEntryObject *)[ctrl.timesheetEntryObjectArray objectAtIndex:i];
                NSString *clientID=[[[tsObject timePunchesArray] objectAtIndex:0] objectForKey:@"clientID"];
                
                if ([clientID isEqualToString:receivedClientID])
                {
                    NSMutableDictionary *tmpDict=[NSMutableDictionary dictionaryWithDictionary:[[tsObject timePunchesArray] objectAtIndex:0]];
                    if (receivedPunchID!=nil && ![receivedPunchID isKindOfClass:[NSNull class]])
                    {
                         [tmpDict setObject:receivedPunchID forKey:@"timePunchesUri"];
                    }
                    
                   
                    [[tsObject timePunchesArray] replaceObjectAtIndex:0 withObject:[NSMutableDictionary dictionaryWithDictionary:tmpDict]];
                    [ctrl.timesheetEntryObjectArray replaceObjectAtIndex:i withObject:tsObject];
                    break;
                }
            }

            [commentsControlDelegate setIsNavigation:FALSE];
            if (isGen4UserTimesheet)
            {
                [commentsControlDelegate updateComments:self.commentsTextView.text andUdfArray:self.oefFieldArray forRow:row forSection:section];
            }
            else
            {
              [commentsControlDelegate updateComments:self.commentsTextView.text andUdfArray:self.userFieldArray forRow:row forSection:section];
            }

        }
        
        [self.navigationController popViewControllerAnimated:YES];
        [datePicker removeFromSuperview];
        datePicker=nil;
 
    }
    
}
-(void) handleUdfCellClick:(NSInteger)indexPath withType:(NSString*)typeStr
{
   
    InOutEntryDetailsCustomCell *previouscell = (InOutEntryDetailsCustomCell *)[self. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedUdfCell inSection:0]];
    [previouscell setSelected:NO animated:NO];
    
    self.selectedUdfCell=indexPath;
    [lastUsedTextField resignFirstResponder];
    [self.commentsTextView resignFirstResponder];
    
    if ([typeStr isEqualToString:UDFType_DATE])
    {
        
        InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[self. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath inSection:0]];
        [cell setSelected:YES animated:NO];
        [cell.fieldValue resignFirstResponder];
        [self resetTableSize:YES isFromUdf:YES isDateUdf:YES];
        [self datePickerAction];
        [self.inoutEntryTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
        
    }
    if ([typeStr isEqualToString:UDFType_DROPDOWN] || [typeStr isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI])
    {
        [self resetTableSize:NO isFromUdf:NO isDateUdf:NO];
        [self doneClicked];
        [self dataAction:indexPath];
        [self.inoutEntryTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    if ([typeStr isEqualToString:UDFType_NUMERIC] || [typeStr isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI])
    {
        [lastUsedTextField becomeFirstResponder];
        self.datePicker.hidden=YES;
        self.toolbar.hidden=YES;
        InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[self. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath inSection:0]];
        cell.fieldButton.hidden=YES;
        [cell setSelected:YES animated:NO];
    }
    if ([typeStr isEqualToString:UDFType_TEXT] || [typeStr isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI])
    {
        [self resetTableSize:NO isFromUdf:NO isDateUdf:NO];
        [self doneClicked];
        [self textUdfAction:indexPath];
        [self.inoutEntryTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    

}

#pragma mark - Date Udf methods

-(void)datePickerAction
{
    
    InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[self. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedUdfCell inSection:0]];
    id fieldValue=nil;
    if ([cell fieldButton].text!=nil)
    {
        fieldValue =[cell fieldButton].text;
    }
    
    NSString *dateStr=fieldValue;
    //Implemented for US8763_HandleWhenDateUDFDoesNotHaveDefaultValue//JUHI
    self.previousDateUdfValue=dateStr;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIDatePicker *tempdatePicker = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    self.datePicker=tempdatePicker;
    CGFloat datePickerYPosition = screenRect.size.height-(tempdatePicker.size.height+self.tabBarController.tabBar.height+self.navigationController.navigationBar.height);
    self.datePicker.frame=CGRectMake(0, datePickerYPosition, self.view.frame.size.width, tempdatePicker.size.height);
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.timeZone=[NSTimeZone timeZoneForSecondsFromGMT:0];
    self.datePicker.hidden = NO;
    
    
    if ([fieldValue isKindOfClass:[NSString class]])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        NSLocale *locale=[NSLocale currentLocale];
        [dateFormatter setLocale:locale];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        if ([dateStr isEqualToString:RPLocalizedString(SELECT_STRING, @"")]) {
            self.datePicker.date = [NSDate date];
            
        }
        else{
            [dateFormatter setDateFormat:@"MMMM d, yyyy"];//DE10538//JUHI
            fieldValue = [dateFormatter dateFromString:dateStr];
            self.datePicker.date = fieldValue;
        }
        
    }
    
    [self.datePicker addTarget:self
                        action:@selector(updateFieldWithPickerChange:)
              forControlEvents:UIControlEventValueChanged];
    if ([[cell fieldButton].text isEqualToString:RPLocalizedString(SELECT_STRING, @"")] || [[cell fieldButton].text isKindOfClass:[NSNull class]] || [cell fieldButton].text==nil )
    {
        [self updateFieldWithPickerChange:self.datePicker];
    }
    [self.view addSubview:self.datePicker];
    
    CGFloat toolbarHeight = 50;
    UIToolbar *temptoolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, self.datePicker.y-toolbarHeight, self.view.frame.size.width, toolbarHeight)];
    self.toolbar=temptoolbar;
    self.toolbar.barStyle = UIBarStyleBlackOpaque;
    //Implementation for US8771 HandleDateUDFEmptyValue//JUHI
    UIBarButtonItem *tempDoneButton = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString(Done, @"") style: UIBarButtonItemStylePlain target: self action: @selector(doneClicked)];
    self.doneButton=tempDoneButton;
   
    
    UIBarButtonItem *tmpCancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                     target:self
                                                                                     action:@selector(pickerCancel:)];
    self.cancelButton=tmpCancelButton;
    
    
    UIBarButtonItem *tmpSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:nil
                                                                                    action:nil];
	self.spaceButton=tmpSpaceButton;
    
    
    
    //Implementation for US8771 HandleDateUDFEmptyValue//JUHI
    UIBarButtonItem *tmpClearButton = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString(@"Clear", @"") style: UIBarButtonItemStylePlain target: self action: @selector(pickerClear:)];
    self.pickerClearButton=tmpClearButton;
    self.doneButton.tintColor=RepliconStandardWhiteColor;
    self.cancelButton.tintColor=RepliconStandardWhiteColor;
    self.pickerClearButton.tintColor=RepliconStandardWhiteColor;
    UIImage *backgroundImage = [Util thumbnailImage:TOOLBAR_IMAGE];
    [toolbar setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
    [toolbar setTintColor:[Util colorWithHex:@"#dddddd" alpha:1]];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];


    NSArray *toolArray = [NSArray arrayWithObjects:cancelButton,pickerClearButton,spaceButton,doneButton,nil];
    [toolbar setItems:toolArray];
    [self.view addSubview: self.toolbar];
    
    
}

- (void)updateFieldWithPickerChange:(id)sender
{
    
    InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[self. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedUdfCell inSection:0]];
    
    //Implementation for US8771 HandleDateUDFEmptyValue//JUHI
    NSString *selectedDateString=nil;
    if ([sender isKindOfClass:[NSString class]])
    {
        selectedDateString=sender;
    }
    else
        selectedDateString=[Util convertDateToString:[sender date]];
    
    [[cell fieldButton] setText:selectedDateString];
    
    EntryCellDetails *udfDetails=[self.userFieldArray objectAtIndex:selectedUdfCell];
    NSString *udfType=[udfDetails fieldType];
    NSString *udfName=[udfDetails fieldName];
    NSString *udfUri=[udfDetails udfIdentity];
    NSString *dropdownOptionUri=[udfDetails dropdownOptionUri];
    NSString *udfSystemDefaultValue=[NSString stringWithFormat:@"%@",[udfDetails systemDefaultValue]];
    NSString *udfDefaultValue=[udfDetails defaultValue];
    NSString *udfIdentity=[udfDetails udfIdentity];
    NSString *udfModule=[udfDetails udfModule];
    
    EntryCellDetails *newCellDetails=[[EntryCellDetails alloc]initWithDefaultValue:udfDefaultValue ];
    [newCellDetails setSystemDefaultValue:udfSystemDefaultValue];
    [newCellDetails setFieldName:udfName];
    [newCellDetails setUdfIdentity:udfUri];
    [newCellDetails setDropdownOptionUri:dropdownOptionUri];
    [newCellDetails setUdfIdentity:udfIdentity];
    [newCellDetails setUdfModule:udfModule];
    [newCellDetails setFieldType:udfType];
    
    //Implementation for US8771 HandleDateUDFEmptyValue//JUHI
    if ([selectedDateString isEqualToString:RPLocalizedString(SELECT_STRING, @"")])
    {
        [newCellDetails setFieldValue: selectedDateString];
    }
    else{
        [newCellDetails setFieldValue: selectedDateString];

    }
    
    
    [self.userFieldArray replaceObjectAtIndex:selectedUdfCell withObject:newCellDetails];
    [self reloadViewAfterEntryEdited];
    
}

-(void)pickerCancel:(id)sender
{
    InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[self. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedUdfCell inSection:0]];
    [cell setSelected:NO animated:NO];
    [self resetTableSize:NO isFromUdf:NO isDateUdf:NO];
    self.datePicker.hidden=YES;
    self.toolbar.hidden=YES;
    NSArray *toolArray = [NSArray arrayWithObjects:spaceButton, doneButton,nil];
    [toolbar setItems:toolArray];
    [self updateFieldWithPickerChange:self.previousDateUdfValue];
    
}
-(void)pickerClear:(id)sender
{
    InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[self. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedUdfCell inSection:0]];
    [cell setSelected:NO animated:NO];
    [self resetTableSize:NO isFromUdf:NO isDateUdf:NO];
    self.datePicker.hidden=YES;
    self.toolbar.hidden=YES;
    NSArray *toolArray = [NSArray arrayWithObjects:spaceButton, doneButton,nil];
    [toolbar setItems:toolArray];
    [self updateFieldWithPickerChange:RPLocalizedString(SELECT_STRING, @"")];
    
}

-(void)doneClicked
{
    InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[self. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedUdfCell inSection:0]];
    [cell setSelected:NO animated:NO];
    
    [self resetTableSize:NO isFromUdf:NO isDateUdf:NO];
    self.datePicker.hidden=YES;
    self.toolbar.hidden=YES;
    
}

#pragma mark - Dropdown Udf methods


-(void)dataAction: (NSInteger)selectedCell
{
    InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[self. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedUdfCell inSection:0]];
    [cell.fieldValue resignFirstResponder];
    
    if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
    {
        [Util showOfflineAlert];
        return;
    }
    
    DropDownViewController *dropDownViewCtrl=[[DropDownViewController alloc]init];
    dropDownViewCtrl.entryDelegate=self;
    if(isGen4UserTimesheet)
    {
        OEFObject *oefObject=[self.oefFieldArray objectAtIndex:selectedCell];
        dropDownViewCtrl.dropDownUri=[oefObject oefUri];
        dropDownViewCtrl.isGen4Timesheet=YES;
        dropDownViewCtrl.selectedDropDownString=[oefObject oefDropdownOptionValue];
        dropDownViewCtrl.dropDownName=[oefObject oefName];
    }
    else
    {
        EntryCellDetails *udfDetails=[self.userFieldArray objectAtIndex:selectedCell];
        dropDownViewCtrl.dropDownUri=[udfDetails udfIdentity];
    }

    [self.navigationController pushViewController:dropDownViewCtrl animated:YES];

}

-(void)updateDropDownFieldWithFieldName:(NSString*)fieldName andFieldURI:(NSString*)fieldUri
{
    InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[self. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedUdfCell inSection:0]];
    EntryCellDetails *newCellDetails=nil;
    OEFObject *oefObject=nil;
    if (isGen4UserTimesheet)
    {
        oefObject=[self.oefFieldArray objectAtIndex:selectedUdfCell];
    }
    else
    {
        EntryCellDetails *udfDetails=[self.userFieldArray objectAtIndex:selectedUdfCell];
        NSString *udfType=[udfDetails fieldType];
        NSString *udfName=[udfDetails fieldName];
        NSString *udfUri=[udfDetails udfIdentity];
        NSString *dropdownOptionUri=[udfDetails dropdownOptionUri];
        NSString *udfSystemDefaultValue=[NSString stringWithFormat:@"%@",[udfDetails systemDefaultValue]];
        NSString *udfDefaultValue=[udfDetails defaultValue];
        NSString *udfIdentity=[udfDetails udfIdentity];
        NSString *udfModule=[udfDetails udfModule];

        newCellDetails=[[EntryCellDetails alloc]initWithDefaultValue:udfDefaultValue ];
        [newCellDetails setSystemDefaultValue:udfSystemDefaultValue];
        [newCellDetails setFieldName:udfName];
        [newCellDetails setUdfIdentity:udfUri];
        [newCellDetails setDropdownOptionUri:dropdownOptionUri];
        [newCellDetails setUdfIdentity:udfIdentity];
        [newCellDetails setUdfModule:udfModule];
        [newCellDetails setFieldType:udfType];
    }

    if (fieldName!=nil && ![fieldName isKindOfClass:[NSNull class]])
    {
        //Implemetation For MOBI-300//JUHI
        if ([fieldName isEqualToString:RPLocalizedString(NONE_STRING, NONE_STRING)]&& (fieldUri==nil || [fieldUri isKindOfClass:[NSNull class]]))
        {
            fieldName=RPLocalizedString(SELECT_STRING, @"");
            if (isGen4UserTimesheet)
            {
              [oefObject setOefDropdownOptionUri:fieldUri];
            }
            else
            {
              [newCellDetails setDropdownOptionUri:fieldUri];
            }

        }
        [cell.fieldButton setText:fieldName];
        if (isGen4UserTimesheet)
        {
            [oefObject setOefDropdownOptionValue:fieldName];
        }
        else
        {
            [newCellDetails setFieldValue:fieldName];
        }

    }
    if (fieldUri!=nil && ![fieldUri isKindOfClass:[NSNull class]])
    {
        if (isGen4UserTimesheet)
        {
            [oefObject setOefDropdownOptionUri:fieldUri];
        }
        else
        {
            [newCellDetails setDropdownOptionUri:fieldUri];
        }

    }

    if (!isGen4UserTimesheet)
    {
        [self.userFieldArray replaceObjectAtIndex:selectedUdfCell withObject:newCellDetails];
    }

    [self reloadViewAfterEntryEdited];
}

#pragma mark - Text Udf methods

-(void)textUdfAction:(NSInteger)selectedCell
{
    
    InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[self. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedCell inSection:0]];
    [cell.fieldValue resignFirstResponder];
    AddDescriptionViewController *addDescriptionViewCtrl=[[AddDescriptionViewController alloc]init];
    
    addDescriptionViewCtrl.fromTextUdf =YES;
    if ([[cell fieldButton].text isEqualToString:RPLocalizedString(ADD, @"")]||[[cell fieldButton].text isEqualToString:RPLocalizedString(NONE_STRING, @"")])
    {
        [addDescriptionViewCtrl setDescTextString:@""];
    }
    else
        [addDescriptionViewCtrl setDescTextString:[cell fieldButton].text];
    
    [addDescriptionViewCtrl setViewTitle:[cell fieldName].text ];
    addDescriptionViewCtrl.descControlDelegate=self;
    
    if (([sheetApprovalStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ]||([sheetApprovalStatus isEqualToString:APPROVED_STATUS ])))
    {
        [addDescriptionViewCtrl setIsNonEditable:YES];
    }
    else
        [addDescriptionViewCtrl setIsNonEditable:NO];
    
    
    [self.navigationController pushViewController:addDescriptionViewCtrl animated:YES];

    
}
-(void)updateTextUdf:(NSString*)udfTextValue
{
    InOutEntryDetailsCustomCell *cell = (InOutEntryDetailsCustomCell *)[self. inoutEntryTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedUdfCell inSection:0]];
    EntryCellDetails *newCellDetails=nil;
    OEFObject *oefObject=nil;
    if (isGen4UserTimesheet)
    {
      oefObject=[self.oefFieldArray objectAtIndex:selectedUdfCell];
    }
    else
    {
        EntryCellDetails *udfDetails=[self.userFieldArray objectAtIndex:selectedUdfCell];
        NSString *udfType=[udfDetails fieldType];
        NSString *udfName=[udfDetails fieldName];
        NSString *udfUri=[udfDetails udfIdentity];
        NSString *dropdownOptionUri=[udfDetails dropdownOptionUri];
        NSString *udfSystemDefaultValue=[NSString stringWithFormat:@"%@",[udfDetails systemDefaultValue]];
        NSString *udfDefaultValue=[udfDetails defaultValue];
        NSString *udfIdentity=[udfDetails udfIdentity];
        NSString *udfModule=[udfDetails udfModule];

        newCellDetails=[[EntryCellDetails alloc]initWithDefaultValue:udfDefaultValue ];
        [newCellDetails setSystemDefaultValue:udfSystemDefaultValue];
        [newCellDetails setFieldName:udfName];
        [newCellDetails setUdfIdentity:udfUri];
        [newCellDetails setDropdownOptionUri:dropdownOptionUri];
        [newCellDetails setUdfIdentity:udfIdentity];
        [newCellDetails setUdfModule:udfModule];
        [newCellDetails setFieldType:udfType];
    }



    NSString *udfTextStr=nil;
    
    if (udfTextValue!=nil && ![udfTextValue isKindOfClass:[NSNull class]])
    {
        if ([udfTextValue isEqualToString:@""])
        {
            udfTextStr=RPLocalizedString(ADD, @"");
        }
        else
            udfTextStr=udfTextValue;
    }
    else
        udfTextStr=RPLocalizedString(ADD, @"");
    
    [cell.fieldButton setText:udfTextStr];
    if (isGen4UserTimesheet)
    {
        [oefObject setOefTextValue:udfTextStr];
    }
    else
    {
        [newCellDetails setFieldValue:udfTextStr];
        [self.userFieldArray replaceObjectAtIndex:selectedUdfCell withObject:newCellDetails];
    }

    [self reloadViewAfterEntryEdited];
    
}
#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    self.inoutEntryTableView=nil;
    self.lastUsedTextField=nil;
    self.datePicker=nil;
    self.cancelButton=nil;
    self.doneButton=nil;
    self.spaceButton=nil;
    self.pickerClearButton=nil;
    self.toolbar=nil;
    self.commentsTextView=nil;
    self.tableFooterView=nil;
    self.tableHeaderView=nil;
    
}

- (void)dealloc
{
    self.inoutEntryTableView.delegate = nil;
    self.inoutEntryTableView.dataSource = nil;
}

- (CGFloat)heightForTableView
{
    static CGFloat paddingForLastCellBottomSeparatorFudgeFactor = 2.0f;
    return CGRectGetHeight([[UIScreen mainScreen] bounds]) -
    (CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) +
     CGRectGetHeight(self.navigationController.navigationBar.frame) +
     CGRectGetHeight(self.tabBarController.tabBar.frame)) +
    paddingForLastCellBottomSeparatorFudgeFactor;
}

@end
