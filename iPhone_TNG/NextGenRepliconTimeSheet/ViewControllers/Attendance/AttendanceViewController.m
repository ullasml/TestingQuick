#import "AttendanceViewController.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "Util.h"
#import "LoginModel.h"
#import <CoreText/CoreText.h>

#import "CameraCaptureViewController.h"

#import "MapAnnotation.h"
#import "FrameworkImport.h"
#import "UIImageView+AFNetworking.h"
#import "SupportDataModel.h"

#import "AttendanceModel.h"
#import "TimesheetModel.h"
#import "RepliconServiceManager.h"
#import "PunchHistoryNavigationController.h"
#import "Theme.h"
#import "DefaultTheme.h"
#import "UIView+Additions.h"
#import "NSString+IntConversion.h"

@interface AttendanceViewController ()

@property (nonatomic) id<Theme> theme;
@property (nonatomic, strong) UIScrollView *mainScrollview;

@end

@implementation AttendanceViewController

@synthesize isCalledFromMenu;
@synthesize isProjectAccess;
@synthesize isActivityAccess;
@synthesize isBillingAccess;
@synthesize isBreakAccess;
@synthesize tsEntryObject;
@synthesize trackTimeView;
@synthesize buttonView;



@synthesize timeFormatBtn;

@synthesize timePunchDict;

@synthesize punchActionUri;



@synthesize locationManager;
@synthesize locationDict;
@synthesize locationImgView;
@synthesize currentServiceCall;
@synthesize totalServiceCall;
@synthesize attendanceLocationUpdatedDelegate;
@synthesize currentDateLabel;
@synthesize isUsingAuditImages;
@synthesize punchMapViewController;
@synthesize previousDifferenceOfDays;
@synthesize lastPunchView;
@synthesize activityView;
@synthesize isButtonAction;
//Implementation for MOBI-728//JUHI
@synthesize punchInfoView;
@synthesize clockUserImage;
@synthesize isClockIn;
@synthesize projectInfoDict;
@synthesize okButtonView;
@synthesize punchInfoActivityView;
@synthesize clockedInOutInfoLbl;
@synthesize clockedInOutInfoLblBgndView;
@synthesize mapView;
#define BUTTON_WIDTH_WITH_BREAK 134
#define BUTTON_WIDTH_WITHOUT_BREAK 240
#define CURRENT_TIME_HEADER_HEIGHT 50
#define CURRENT_DATE_HEADER_HEIGHT 28
#define BUTTON_WIDTH_TASK 280
#define BUTTON_WIDTH_USING_BREAK 280
#define EXTENDED__IN_OUT_CELL_HEIGHT 110
#define SIMPLE_IN_OUT_CELL_HEIGHT 50
#define SIMPLE_IN_OUT_CELL_WITH_DATE_HEIGHT 69
#define ALL_BUTTON_HEIGHT 44
#define BUTTON_LEFT_PADDING 15

#define LABEL_LEFT_PADDING 10.0
#define END_BREAK_TEXT @"Clock Out"//punch-123 Ullas
#define BREAK @"Break"
#define START_NEW_TASK_TEXT @"Transfer"//punch-123 Ullas
#define START_NEW_ACTIVITY_TEXT @"Transfer"//punch-123 Ullas
#define START @"Clock In"
#define STOP @"Clock Out"
#define RESUME_WORK_TEXT @"Resume Work"//punch-123 Ullas


#define CLOCKED_IN_OUT_HEADER_HEIGHT 50.0f
#define IMAGE_DETAIL_VIEW_HEIGHT 50.0f
#define PROJECT_DETAIL_VIEW_HEIGHT 50.0f
#define xOFFSET 15.0f
#define yOFFSET 15.0f
#define MAP_VIEW_HEIGHT 150.0f
#define LOCATION_INFO_VIEW_HEIGHT 60.0f
#define LOCATION_NO_INFO_AVAILABLE_VIEW_HEIGHT 35.0f
#define OK_TITLE_VIEW_HEIGHT 40.0f


- (instancetype)initWithTheme:(id<Theme>)theme
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.theme = theme;
    }
    return self;
}

-(void)loadView
{
    [super loadView];

    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate.locationManagerTemp stopUpdatingLocation];
    appDelegate.locationManagerTemp=nil;
    if (!appDelegate.locationManagerTemp)
    {
        self.locationManager = [[CLLocationManager alloc] init];

        self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    }
    else
    {
        self.locationManager=appDelegate.locationManagerTemp;
    }
    self.locationManager.delegate = self;
    [appDelegate setLocationManagerTemp:self.locationManager];

    [Util setToolbarLabel:self withText: RPLocalizedString(AttendanceTabbarTitle, @"") ];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;

    LoginModel *loginModel=[[LoginModel alloc]init];
    self.isProjectAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchProjectAccess"];
    self.isActivityAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchActivityAccess"];
    self.isBillingAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchBillingAccess"];
    self.isBreakAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchBreakAccess"];
    self.isUsingAuditImages=[loginModel getStatusForGivenPermissions:@"timepunchAuditImageRequired"];

    if (self.isProjectAccess||self.isActivityAccess||self.isBillingAccess)
    {
        self.isExtendedInOut=YES;
    }
    self.isExtendedInOut=YES;
    BOOL isLocationAccess=[loginModel getStatusForGivenPermissions:@"timepunchGeolocationRequired"];



    if (isLocationAccess)
    {
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        [self.locationManager startUpdatingLocation];

    }
    else
    {
        [self.locationManager stopUpdatingLocation];
    }

    SupportDataModel *supportDataModel = [[SupportDataModel alloc] init];
    NSMutableArray *userDetailsArr=[supportDataModel getUserDetailsFromDatabase];
    BOOL canViewTimePunch=FALSE;
    if ([userDetailsArr count]>0) {
        canViewTimePunch=[[[userDetailsArr objectAtIndex:0] objectForKey:@"canViewTimePunch"] boolValue];
    }
    if (canViewTimePunch)
    {
        UIImage *punchHistoryImage = [UIImage imageNamed:@"icon_punch_history"];
        UIBarButtonItem *punchHistoryBtn = [[UIBarButtonItem alloc] initWithImage:punchHistoryImage
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(punchHistoryAction:)];
        [self.navigationItem setRightBarButtonItem:punchHistoryBtn animated:NO];
    }



}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.view setBackgroundColor:[Util colorWithHex:@"#E2E2E2" alpha:1.0]];

    self.lastPunchView = [[UIView alloc] init];
    [self.lastPunchView setBackgroundColor:[UIColor clearColor]];

    self.mainScrollview=[[UIScrollView alloc]initWithFrame:self.view.frame];
    [self.mainScrollview setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.mainScrollview];
    
    [self createView];

    [self sendRequestToGetLastPunchData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    if (isButtonAction) {
        if (self.lastPunchView) {
            [self.lastPunchView removeFromSuperview];
        }
        [self removeActiVityIndicator];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    self.mainScrollview.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.mainScrollview setContentOffset:CGPointMake(self.mainScrollview.contentOffset.x, 0)
                                 animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    isButtonAction = false;
    
     self.mainScrollview.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.mainScrollview setContentOffset:CGPointMake(self.mainScrollview.contentOffset.x, 0)
                                 animated:YES];

    
    [self dismissView];
    
}




#pragma mark - View methods



-(void)createButtonViewFromYoffset:(float)headerHeight
{
    CGFloat buttonWidth = self.view.width - (2* BUTTON_LEFT_PADDING);
    [self.buttonView removeFromSuperview];
    UIImage *startButtonImage=[Util getResizedImageForImageWithName:START_BUTTON_IMAGE];
    UIImage *stopButtonImage=[Util getResizedImageForImageWithName:STOP_BUTTON_IMAGE];
    UIImage *breakButtonImage=[Util getResizedImageForImageWithName:BREAK_BUTTON_IMAGE];
    UIImage *startNewTaskButtonImage=[Util getResizedImageForImageWithName:START_NEW_TASK_BUTTON_IMAGE];
    float buttonBGViewHeight=0.0;


    UIView *buttonBGView=[[UIView alloc]initWithFrame:CGRectMake(0, CURRENT_DATE_HEADER_HEIGHT+headerHeight, SCREEN_WIDTH,buttonBGViewHeight)];
    [buttonBGView setBackgroundColor:[Util colorWithHex:@"#E2E2E2" alpha:1.0]];

    UIButton   *startButton =  [[UIButton alloc] initWithFrame:CGRectMake(BUTTON_LEFT_PADDING, 15, buttonWidth, startButtonImage.size.height)];
    [startButton setBackgroundImage:startButtonImage forState:UIControlStateNormal];
    [startButton setTitle:RPLocalizedString(START, @"") forState:UIControlStateNormal];
    [startButton setTitleColor:RepliconStandardWhiteColor forState:UIControlStateNormal];
    [startButton setTitleShadowColor:[UIColor colorWithHex:[@"#000000" intFromHexString] alpha:.5] forState:UIControlStateNormal];
    startButton.titleLabel.font =[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_18];
    [startButton addTarget:self action:@selector(startButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [startButton setUserInteractionEnabled:YES];
    [buttonBGView addSubview:startButton];

    buttonBGViewHeight = 15+startButtonImage.size.height+9;


    UIButton   *startNewTaskButton =  [[UIButton alloc] initWithFrame:CGRectMake(BUTTON_LEFT_PADDING, buttonBGViewHeight, buttonWidth, startNewTaskButtonImage.size.height)];


    if (!isProjectAccess && !isBillingAccess && isActivityAccess)
    {
        [startNewTaskButton setBackgroundImage:startNewTaskButtonImage forState:UIControlStateNormal];
        [startNewTaskButton setTitle:RPLocalizedString(START_NEW_ACTIVITY_TEXT, @"") forState:UIControlStateNormal];
        [startNewTaskButton setTitleColor:RepliconStandardBlackColor forState:UIControlStateNormal];
        [startNewTaskButton setTitleShadowColor:[UIColor colorWithHex:[@"#FFFFFF" intFromHexString] alpha:1.0] forState:UIControlStateNormal];
        startNewTaskButton.titleLabel.font =[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_18];
        [startNewTaskButton addTarget:self action:@selector(startNewTaskAction) forControlEvents:UIControlEventTouchUpInside];
        [startNewTaskButton setUserInteractionEnabled:YES];

    }

    UIImage *disclosureImage = [UIImage imageNamed:Disclosure_Box];
    UIImageView *disclosureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(buttonWidth-30, startNewTaskButtonImage.size.height/2-8, disclosureImage.size.width,disclosureImage.size.height)];
    [disclosureImageView setImage:disclosureImage];

    if(isActivityAccess)
    {
        [buttonBGView addSubview:startNewTaskButton];
        [startNewTaskButton addSubview:disclosureImageView];
        buttonBGViewHeight = buttonBGViewHeight+startNewTaskButtonImage.size.height+9;
    }

    UIButton   *breakButton =  [[UIButton alloc] initWithFrame:CGRectMake(BUTTON_LEFT_PADDING, buttonBGViewHeight, buttonWidth, breakButtonImage.size.height)];
    [breakButton setBackgroundImage:breakButtonImage forState:UIControlStateNormal];
    [breakButton setTitle:RPLocalizedString(BREAK, @"") forState:UIControlStateNormal];
    [breakButton setTitleColor:RepliconStandardBlackColor forState:UIControlStateNormal];
    [breakButton setTitleShadowColor:[UIColor colorWithHex:[@"#FFFFFF" intFromHexString] alpha:1.0] forState:UIControlStateNormal];
    breakButton.titleLabel.font =[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_18];
    [breakButton addTarget:self action:@selector(breakButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [breakButton setUserInteractionEnabled:YES];
    if (isBreakAccess) {
        [buttonBGView addSubview:breakButton];
        buttonBGViewHeight = buttonBGViewHeight+breakButtonImage.size.height+9;
    }


    UIButton   *stopButton =  [[UIButton alloc] initWithFrame:CGRectMake(BUTTON_LEFT_PADDING, buttonBGViewHeight, buttonWidth, stopButtonImage.size.height)];
    [stopButton setBackgroundImage:stopButtonImage forState:UIControlStateNormal];
    [stopButton setTitle:RPLocalizedString(STOP, @"")  forState:UIControlStateNormal];
    [stopButton setTitleColor:RepliconStandardWhiteColor forState:UIControlStateNormal];
    [stopButton setTitleShadowColor:[UIColor colorWithHex:[@"#000000" intFromHexString] alpha:.5] forState:UIControlStateNormal];
    stopButton.titleLabel.font =[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_18];
    [stopButton addTarget:self action:@selector(stopButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [stopButton setUserInteractionEnabled:YES];
    [buttonBGView addSubview:stopButton];

    buttonBGViewHeight = buttonBGViewHeight+stopButtonImage.size.height+15;



    buttonBGView.frame = CGRectMake(0, 0, self.view.width,buttonBGViewHeight);
    self.buttonView=buttonBGView;
    UIView *separatorView=[[UIView alloc]initWithFrame:CGRectMake(0, buttonBGViewHeight, buttonBGView.width, 1)];
    [separatorView setBackgroundColor:[Util colorWithHex:@"#D6D6D6" alpha:1]];
    [buttonBGView addSubview:separatorView];
    [self.mainScrollview addSubview:buttonBGView];
    //Implementation for MOBI-728//JUHI
    [self.mainScrollview sendSubviewToBack:buttonBGView];
    [self.mainScrollview bringSubviewToFront:self.punchInfoView];
    
    self.mainScrollview.contentSize = CGSizeMake(self.view.width,buttonBGView.bottom);
}

-(void)createView
{

    [self createButtonViewFromYoffset:0];


}



-(UIView *)initialiseView:(NSMutableDictionary *)dataDict
{
    CGFloat labelWidth = self.view.width - (2*LABEL_LEFT_PADDING);
    UIView *returnView=[UIView new];
    UIView *separatorView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 0.5)];
    [separatorView setBackgroundColor:[Util colorWithHex:@"#d6d6d6" alpha:1.0]];
    [returnView addSubview:separatorView];
    [returnView bringSubviewToFront:separatorView];
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
        middleLeft.frame=CGRectMake(LABEL_LEFT_PADDING, 10.0, labelWidth, middleLblHeight);
        [middleLeft setTextColor:[Util colorWithHex:@"#505151" alpha:1]];
        [middleLeft setBackgroundColor:[UIColor clearColor]];
        [middleLeft setTextAlignment:NSTextAlignmentLeft];
        [middleLeft setHighlightedTextColor:[UIColor whiteColor]];
        [returnView addSubview:middleLeft];
        [middleLeft setText:middleStr];

        BOOL isBreakPresent=NO;
        NSString *breakUri=[tsEntryObject breakName];
        if (breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]] && ![breakUri isEqualToString:@""])
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

                middleLeft.frame=CGRectMake((2*LABEL_LEFT_PADDING)+breakImage.size.width, 14.0, labelWidth-50, middleLblHeight);
            }

            [middleLeft setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
            [middleLeft setNumberOfLines:100];
        }
        else
        {
            [middleLeft setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
            middleLeft.frame=CGRectMake(LABEL_LEFT_PADDING,5.0, labelWidth, EachDayTimeEntry_Cell_Row_Height_44);
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

                    if ([string length]==[middleStr length])
                    {

                    }
                    else
                    {
                        string = [NSString stringWithFormat:@" %@",NON_BILLABLE];
                    }
                    if ([middleStr rangeOfString:NON_BILLABLE].location == NSNotFound)
                    {
                        [tmpattributedString addAttribute:NSForegroundColorAttributeName value:[Util colorWithHex:@"#505151" alpha:1] range:NSMakeRange(0,[string length])];

                    }
                    else
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
        upperLeft.frame=CGRectMake(LABEL_LEFT_PADDING, 10, labelWidth, upperLblHeight);
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

        float yLower=upperLeft.bottom+5;
        UILabel *lowerLeft = [[UILabel alloc] init];
        lowerLeft.frame=CGRectMake(LABEL_LEFT_PADDING, yLower, labelWidth, lowerLblHeight);
        [lowerLeft setTextColor:[Util colorWithHex:@"#505151" alpha:1]];
        [lowerLeft setBackgroundColor:[UIColor clearColor]];
        [lowerLeft setTextAlignment:NSTextAlignmentLeft];
        [lowerLeft setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
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

                if ([string length]==[lowerStr length])
                {

                }
                else
                {
                    string = [NSString stringWithFormat:@" %@",NON_BILLABLE];
                }
                if ([lowerStr rangeOfString:NON_BILLABLE].location == NSNotFound)
                {
                    [tmpattributedString addAttribute:NSForegroundColorAttributeName value:[Util colorWithHex:@"#505151" alpha:1] range:NSMakeRange(0,[string length])];

                }
                else
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
        upperLeft.frame=CGRectMake(LABEL_LEFT_PADDING, 10, labelWidth, upperLblHeight);
        [upperLeft setTextColor:[Util colorWithHex:@"#505151" alpha:1]];
        [upperLeft setBackgroundColor:[UIColor clearColor]];
        [upperLeft setTextAlignment:NSTextAlignmentLeft];
        [upperLeft setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
        [upperLeft setText:upperStr];
        [upperLeft setNumberOfLines:100];
        [upperLeft setHighlightedTextColor:[UIColor whiteColor]];
        [returnView addSubview:upperLeft];

        float ymiddle=upperLeft.bottom+5;
        UILabel *middleLeft = [[UILabel alloc] init];
        middleLeft.frame=CGRectMake(LABEL_LEFT_PADDING, ymiddle, labelWidth, middleLblHeight);
        [middleLeft setTextColor:[Util colorWithHex:@"#505151" alpha:1]];
        [middleLeft setBackgroundColor:[UIColor clearColor]];
        [middleLeft setTextAlignment:NSTextAlignmentLeft];
        [middleLeft setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
        [middleLeft setText:middleStr];
        [middleLeft setNumberOfLines:100];
        [middleLeft setHighlightedTextColor:[UIColor whiteColor]];
        [returnView addSubview:middleLeft];


        float ylower=middleLeft.bottom+5;
        UILabel *lowerLeft = [[UILabel alloc] init];
        lowerLeft.frame=CGRectMake(LABEL_LEFT_PADDING, ylower, labelWidth, lowerLblHeight);
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
                [tmpattributedString addAttribute:NSForegroundColorAttributeName value:[Util colorWithHex:@"#505151" alpha:1] range:NSMakeRange(0,[string length])];
            }
            else
            {
                [tmpattributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,[string length])];
            }

            [lowerLeft setAttributedText:tmpattributedString];
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





#pragma mark - Other methods


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
    CGSize mainSize = [attributedString boundingRectWithSize:CGSizeMake(width, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;

    if (mainSize.width==0 && mainSize.height ==0)
    {
        mainSize=CGSizeMake(0,0);
    }
    return mainSize.height;
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
-(NSString *)getTheAttributedTextForEntryObject:(BOOL)isForEntryObj forDataDict:(NSMutableDictionary *)dataDict
{

    NSMutableArray *array=[NSMutableArray array];

    NSString *tsBillingName=@"";
    NSString *tsActivityName=@"";
    if (isForEntryObj)
    {
        tsBillingName=[tsEntryObject timeEntryBillingName];
        tsActivityName=[tsEntryObject timeEntryActivityName];
    }
    else
    {
        tsActivityName=[dataDict objectForKey:@"activity"];
        tsBillingName=[dataDict objectForKey:@"billing"];
    }


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


    float labelWidth=self.view.width-90;
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

-(NSString*) getCurrentDate
{
    //Get current date
    NSDate* now = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE, MMMM dd, yyyy"];

    NSString *formattedDateString = [dateFormatter stringFromDate:now];
    return formattedDateString;
}

-(NSDateComponents *) getCurrentTimeComponents
{
    //Get current time
    NSDate *now= [NSDate dateWithTimeIntervalSinceNow:0];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [gregorian components:(NSCalendarUnitHour  | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:now];
    return dateComponents;

}





-(void)handleStartNewTaskAction
{
    [[NSNotificationCenter defaultCenter] removeObserver: self name: START_NEW_TASK_NOTIFICATION object: nil];
    [self startButtonAction];
}



-(void)handlePunchDataReceivedAction:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver: self name: PUNCH_TIME_NOTIFICATION object: nil];
    NSDictionary *dataDict=notification.userInfo;

    BOOL isError = TRUE;
    NSDictionary *punchTimeDict = nil;

    if (![dataDict isKindOfClass:[NSNull class]] && dataDict !=nil)
    {
        isError=[[notification.userInfo objectForKey:@"isError"] boolValue];
        punchTimeDict=[dataDict objectForKey:@"TIME_PUNCH_DATA"];

    }
    if (!isError) {
        if(punchTimeDict !=nil)
        {
            NSMutableDictionary *dateDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[punchTimeDict objectForKey:@"year"],@"year",
                                             [punchTimeDict objectForKey:@"month"],@"month",
                                             [punchTimeDict objectForKey:@"day"],@"day",nil];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self sendRequestToRecalculateScriptDataWithDataDict:dateDict];

            });


        }

        //Implementation for MOBI-728//JUHI

        [self updatePunchDataView];


        [self sendRequestToGetLastPunchData];


        [self createView];

    }
    else{
        [self dismissView];
        [self showLastPunchDataView];
    }
}

//Implementation for MOBI-728//JUHI
-(void)updatePunchDataView
{
    if (isClockIn)
    {
        self.clockedInOutInfoLbl.textColor = [self.theme clockedInLabelColor];
        self.clockedInOutInfoLbl.text = RPLocalizedString(CLOCKED_IN_HEADER,@"");
    }
    else
    {
        self.clockedInOutInfoLbl.textColor = [self.theme clockedOutLabelColor];
        self.clockedInOutInfoLbl.text = RPLocalizedString(CLOCKED_OUT_HEADER,@"");
    }

    [punchInfoActivityView removeFromSuperview];

    UIButton *okBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-2*xOFFSET,40)];
    okBtn.titleLabel.font = [UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_17];
    okBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [okBtn setTitle:RPLocalizedString(@"OK", @"") forState:UIControlStateNormal];
    [okBtn addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
    [okBtn setTitleColor:RepliconStandardBlueColor forState:UIControlStateNormal];
    [okButtonView addSubview:okBtn];
}
-(void)showPunchData:(BOOL)isResponseReceived
{
    
    [self.view setBackgroundColor:[UIColor grayColor]];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
    //[self.tabBarController.tabBar setHidden:YES];
    
    [punchInfoView removeFromSuperview];
    
    NSMutableDictionary * punchDict=self.projectInfoDict;
    float viewHeight=0.0;
    LoginModel *loginModel=[[LoginModel alloc]init];
    BOOL isLocationAccess=[loginModel getStatusForGivenPermissions:@"timepunchGeolocationRequired"];

    UILabel *projectActivityLabel=[[UILabel alloc]initWithFrame:CGRectMake(xOFFSET, 6, SCREEN_WIDTH-2*xOFFSET-20, 18)];
    projectActivityLabel.textColor = [self.theme punchConfirmationLightTextColor];
    [projectActivityLabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_14]];


    UILabel *projectActivityValueLabel=[[UILabel alloc]initWithFrame:CGRectMake(xOFFSET, 23, SCREEN_WIDTH-2*xOFFSET-20, 22)];
    [projectActivityValueLabel setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_17]];


    BOOL isProjectAccessAllowed=[loginModel getStatusForGivenPermissions:@"hasTimepunchProjectAccess"];
    BOOL isActivityAccessAllowed=[loginModel getStatusForGivenPermissions:@"hasTimepunchActivityAccess"];
    BOOL isBillingAccessAllowed=[loginModel getStatusForGivenPermissions:@"hasTimepunchBillingAccess"];
    BOOL isBreakAccessAllowed=[loginModel getStatusForGivenPermissions:@"hasTimepunchBreakAccess"];
    BOOL isActivityOnly=NO;
    BOOL isBreakOnly=NO;
    BOOL isProject=NO;

    NSString *activityName=[punchDict objectForKey:@"activityName"];
    NSString *projectName=[punchDict objectForKey:@"projectName"];
    NSString *breakName=[punchDict objectForKey:@"breakName"];

    NSString *breakUri=[punchDict objectForKey:@"breakUri"];
    BOOL isBreakRow=FALSE;
    if (breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]]&&![breakUri isEqualToString:@""])
    {
        isBreakRow=TRUE;
    }

    if (!isProjectAccessAllowed && !isBillingAccessAllowed && isActivityAccessAllowed && !isBreakRow)
    {
        isActivityOnly=YES;
    }
    else if (isProjectAccessAllowed && !isBreakRow)
    {
        isProject=YES;
    }
    else if (isBreakAccessAllowed &&  isBreakRow)
    {
        isBreakOnly=YES;
    }




    BOOL showDetailView=FALSE;
    
    if (isClockIn)
    {
        if (breakName!=nil && ![breakName isKindOfClass:[NSNull class]]&& ![breakName isEqualToString:@""] && isBreakOnly)
        {
            [projectActivityLabel setText:RPLocalizedString(BREAK_ENTRY, @"")];
            [projectActivityValueLabel setText:breakName];
            showDetailView=TRUE;
        }
        else if (activityName!=nil && ![activityName isKindOfClass:[NSNull class]]&& ![activityName isEqualToString:@""] && isActivityOnly)
        {
            [projectActivityLabel setText:RPLocalizedString(Activity_Type, @"")];
            [projectActivityValueLabel setText:activityName];
            showDetailView=TRUE;
        }
        else if (projectName!=nil && ![projectName isKindOfClass:[NSNull class]]&& ![projectName isEqualToString:@""] && isProject)
        {
            [projectActivityLabel setText:RPLocalizedString(Project, @"")];
            [projectActivityValueLabel setText:projectName];
            showDetailView=TRUE;
        }
        else
        {
            if (isActivityOnly)
            {
                [projectActivityLabel setText:RPLocalizedString(Activity_Type, @"")];
                [projectActivityValueLabel setText:RPLocalizedString(NO_ACTIVITY_SELECTED_STRING, @"")];
                showDetailView=TRUE;
            }
            else if (isProject)
            {
                [projectActivityLabel setText:RPLocalizedString(Project, @"")];
                [projectActivityValueLabel setText:RPLocalizedString(NO_PROJECT_SELECTED_STRING, @"")];
                showDetailView=TRUE;
            }
            
            
        }
    }

  

    float projectDetailViewHeight=PROJECT_DETAIL_VIEW_HEIGHT;
    float locationViewHeight=0.0;
    if (!showDetailView)
    {
        projectDetailViewHeight=0.0;
    }
    NSString *tempLocationDict = [locationDict objectForKey:@"LOCATION_INFO_STRING"];
    if (tempLocationDict!=nil  && ![tempLocationDict isKindOfClass:[NSNull class]] && ![tempLocationDict isEqualToString:@""] && ![tempLocationDict isEqualToString:@"<null>"])
    {
        locationViewHeight=MAP_VIEW_HEIGHT+LOCATION_INFO_VIEW_HEIGHT;
    }
    else
    {
        locationViewHeight = LOCATION_NO_INFO_AVAILABLE_VIEW_HEIGHT;
    }

    if (!isLocationAccess)
    {
        locationViewHeight=-10.0;
    }


    viewHeight=CLOCKED_IN_OUT_HEADER_HEIGHT+IMAGE_DETAIL_VIEW_HEIGHT+projectDetailViewHeight+locationViewHeight+OK_TITLE_VIEW_HEIGHT+10;

    punchInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width,SCREEN_HEIGHT-44.0)];
    [punchInfoView setBackgroundColor:[[UIColor grayColor] colorWithAlphaComponent:0.9]];
    punchInfoView.hidden=YES;
    

    UIView* punchTempInfoView = [[UIView alloc]initWithFrame:CGRectMake(xOFFSET, 10, SCREEN_WIDTH-2*xOFFSET, self.view.bounds.size.height-20.0)];
    punchTempInfoView.cornerRadius = 5.0f;
    punchTempInfoView.clipsToBounds = YES;
    [punchInfoView addSubview:punchTempInfoView];

    self.clockedInOutInfoLblBgndView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-2*xOFFSET, CLOCKED_IN_OUT_HEADER_HEIGHT)];
    [self.clockedInOutInfoLblBgndView setBackgroundColor:[self.theme punchConfirmationHeaderBackgroundColor]];

    self.clockedInOutInfoLbl = [[UILabel alloc]initWithFrame:CGRectMake(xOFFSET, 0, SCREEN_WIDTH-2*xOFFSET, CLOCKED_IN_OUT_HEADER_HEIGHT)];

    if (isResponseReceived)
    {
        if (isClockIn)
        {
            self.clockedInOutInfoLbl.textColor = [self.theme clockedInLabelColor];
            [self.clockedInOutInfoLbl setText:RPLocalizedString(CLOCKED_IN_HEADER,@"")];
        }
        else
        {
            self.clockedInOutInfoLbl.textColor = [self.theme clockedOutLabelColor];
            [self.clockedInOutInfoLbl setText:RPLocalizedString(CLOCKED_OUT_HEADER,@"")];

        }
    }
    else
    {
        if (isClockIn)
        {
            self.clockedInOutInfoLbl.textColor = [self.theme clockingInLabelColor];
            [self.clockedInOutInfoLbl setText:RPLocalizedString(CLOCKING_IN_HEADER,@"")];
        }
        else
        {
            self.clockedInOutInfoLbl.textColor = [self.theme clockingOutLabelColor];
            [self.clockedInOutInfoLbl setText:RPLocalizedString(CLOCKING_OUT_HEADER,@"")];
        }
    }

    [self.clockedInOutInfoLbl setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_17]];
    [self.clockedInOutInfoLblBgndView addSubview:self.clockedInOutInfoLbl];
    [punchTempInfoView addSubview:self.clockedInOutInfoLblBgndView];


    //ImageView
    UIView *imageDetailView=[[UIView alloc]initWithFrame:CGRectMake(0, self.clockedInOutInfoLblBgndView.frame.size.height, SCREEN_WIDTH-2*xOFFSET, IMAGE_DETAIL_VIEW_HEIGHT)];
    [imageDetailView setBackgroundColor:RepliconStandardWhiteColor];



    if (clockUserImage)
    {
        clockUserImage=[Util imageWithImage:clockUserImage scaledToSize:CGSizeMake(40, 40)];
        UIImageView *tempClockUserImage=[[UIImageView alloc]initWithFrame:CGRectMake(xOFFSET, 5, clockUserImage.size.width, clockUserImage.size.height)];
        [tempClockUserImage setImage:clockUserImage];
        [imageDetailView addSubview:tempClockUserImage];
    }
    float xAtLabel=xOFFSET;
    if (clockUserImage)
    {
        xAtLabel=xOFFSET+clockUserImage.size.width+10;
    }

    NSString *timeString=[Util getCurrentTime:YES];
    NSString *formatString=[Util getCurrentTime:NO];
    UILabel *atLabel=[[UILabel alloc]initWithFrame:CGRectMake(xAtLabel, 17, 15, 20)];
    [atLabel setText:RPLocalizedString(AT_STRING,@"")];
    atLabel.textColor = [self.theme punchConfirmationLightTextColor];
    [atLabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_14]];
    [imageDetailView addSubview:atLabel];

    UILabel *timeLabel=[[UILabel alloc]initWithFrame:CGRectMake(atLabel.right+5, 15, 60, 20)];
    [timeLabel setText:timeString];
    timeLabel.textColor = RepliconStandardBlackColor;
    [timeLabel setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_20]];
    [imageDetailView addSubview:timeLabel];

    UILabel *ampmLabel=[[UILabel alloc]initWithFrame:CGRectMake(xAtLabel + atLabel.frame.size.width+timeLabel.frame.size.width, 12, 100, 20)];
    [ampmLabel setText:[formatString uppercaseString]];
    ampmLabel.textColor = [self.theme punchConfirmationDarkTextColor];
    [ampmLabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
    [imageDetailView addSubview:ampmLabel];

    [punchTempInfoView addSubview:imageDetailView];


    //Activity information View
    UIView *activityDetailView=[[UIView alloc]initWithFrame:CGRectMake(0, imageDetailView.frame.origin.y+imageDetailView.frame.size.height, SCREEN_WIDTH-2*xOFFSET, PROJECT_DETAIL_VIEW_HEIGHT)];
    [activityDetailView setBackgroundColor:RepliconStandardWhiteColor];

    UIImageView *separatorImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, activityDetailView.frame.size.width, 1)];
    [separatorImage setImage:[Util thumbnailImage:LOCKED_IN_OUT_SEPARAROR_IMAGE]];
    [activityDetailView addSubview:separatorImage];


    UIView *mapDetailView=[[UIView alloc]init];
    //map information View
    float height=0;
    if ((tempLocationDict!=nil  && ![tempLocationDict isKindOfClass:[NSNull class]] && ![tempLocationDict isEqualToString:@""] && ![tempLocationDict isEqualToString:@"<null>"]) && locationViewHeight>0)
    {
        height=10+locationViewHeight;
    }
    else if (locationViewHeight>0)
    {
        height=10+locationViewHeight;
    }


    if (showDetailView)
    {
        [activityDetailView addSubview:projectActivityLabel];
        [activityDetailView addSubview:projectActivityValueLabel];

        [punchTempInfoView addSubview:activityDetailView];

        mapDetailView.frame=CGRectMake(0, activityDetailView.frame.origin.y+activityDetailView.frame.size.height, SCREEN_WIDTH-2*xOFFSET, height);
    }

    else
    {
        mapDetailView.frame=CGRectMake(0, imageDetailView.frame.origin.y+imageDetailView.frame.size.height, SCREEN_WIDTH-2*xOFFSET, height);

    }





    [mapDetailView setBackgroundColor:RepliconStandardWhiteColor];
    UIImageView *mapSeparatorImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, mapDetailView.frame.size.width, 1)];
    [mapSeparatorImage setImage:[Util thumbnailImage:LOCKED_IN_OUT_SEPARAROR_IMAGE]];
    [mapDetailView addSubview:mapSeparatorImage];
    UIImage *locationImage=[UIImage imageNamed:LOCATION_ENABLED_IMAGE];
    UILabel *locationInfoLabel=[[UILabel alloc]init];
    [locationInfoLabel setTextAlignment:NSTextAlignmentCenter];
    if ((tempLocationDict!=nil  && ![tempLocationDict isKindOfClass:[NSNull class]] && ![tempLocationDict isEqualToString:@""] && ![tempLocationDict isEqualToString:@"<null>"]))
    {
        MKMapView *tempmapView=[[MKMapView alloc]initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH-2*xOFFSET-20, MAP_VIEW_HEIGHT)];
        self.mapView=tempmapView;
        mapView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        mapView.layer.borderWidth = 0.5;
        [mapView setMapType:MKMapTypeStandard];
        [mapView setZoomEnabled:YES];
        [mapView setScrollEnabled:YES];
        [mapView setDelegate:self];

        CLLocationCoordinate2D location;

        location.latitude = [[[locationDict objectForKey:@"LOCATION_INFO_DICT"] objectForKey:@"lat"] doubleValue];
        location.longitude = [[[locationDict objectForKey:@"LOCATION_INFO_DICT"] objectForKey:@"lng"] doubleValue];


        MKCoordinateSpan span;
        MKCoordinateRegion region ;
        span.latitudeDelta = 0.01;//more value you set your zoom level will increase
        span.longitudeDelta =0.01;//more value you set your zoom level will increase
        region.span = span;
        MapAnnotation *newAnnotation = [[MapAnnotation alloc]init];
        region.center = location;
        newAnnotation.title=@"";
        newAnnotation.coordinate=location;
        [mapView addAnnotation:newAnnotation];
        [mapView setRegion:region animated:YES];
        [mapView regionThatFits:region];

        MKCircle *circle = [MKCircle circleWithCenterCoordinate:location radius:250];
        [mapView addOverlay:circle];


        [mapDetailView addSubview:mapView];
        NSString *addressString = tempLocationDict;
        float locationStringHeight = [self getHeightForString:addressString fontSize:RepliconFontSize_12  forWidth:290-xOFFSET-locationImage.size.width-27];


        if (locationStringHeight<15.0)
        {
            locationStringHeight=30.0;
        }
        else
        {
            locationStringHeight=40.0;
        }

        [locationInfoLabel setText:addressString];
        locationInfoLabel.frame=CGRectMake(xOFFSET - 5.0f, mapView.frame.origin.y+mapView.frame.size.height, SCREEN_WIDTH-2*xOFFSET-20,LOCATION_INFO_VIEW_HEIGHT);
        locationInfoLabel.textAlignment = NSTextAlignmentLeft;
    }
    else
    {
        UIImage *noLocationImage=[UIImage imageNamed:LOCATION_DISABLED_IMAGE];
        UIImageView *noLocationImageView=[[UIImageView alloc]initWithFrame:CGRectMake(xOFFSET, 10, noLocationImage.size.width, noLocationImage.size.height)];
        [noLocationImageView setImage:noLocationImage];
        [mapDetailView addSubview:noLocationImageView];
        [locationInfoLabel setTextAlignment:NSTextAlignmentLeft];
        locationInfoLabel.frame=CGRectMake(xOFFSET+noLocationImage.size.width+10, 15, SCREEN_WIDTH-2*xOFFSET-20, LOCATION_NO_INFO_AVAILABLE_VIEW_HEIGHT - 20);
        [locationInfoLabel setText:RPLocalizedString(LOCATION_UNAVAILABLE_STRING, @"")];
    }

    [locationInfoLabel setNumberOfLines:2];
    [locationInfoLabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_14]];
    [mapDetailView addSubview:locationInfoLabel];

    if (locationViewHeight>0.0)
    {
        [punchTempInfoView addSubview:mapDetailView];
    }
    //ok button View
    self.okButtonView=[[UIView alloc]init];
    if (locationViewHeight>0.0)
    {
        self.okButtonView.frame=CGRectMake(0, mapDetailView.frame.origin.y+mapDetailView.frame.size.height, SCREEN_WIDTH-2*xOFFSET,OK_TITLE_VIEW_HEIGHT);
    }
    else
    {
        if (showDetailView)
        {
            self.okButtonView.frame=CGRectMake(0, activityDetailView.frame.origin.y+activityDetailView.frame.size.height, SCREEN_WIDTH-2*xOFFSET,OK_TITLE_VIEW_HEIGHT);

        }
        else
        {
            self.okButtonView.frame=CGRectMake(0, imageDetailView.frame.origin.y+imageDetailView.frame.size.height, SCREEN_WIDTH-2*xOFFSET,OK_TITLE_VIEW_HEIGHT);

        }

    }
    [self.okButtonView setBackgroundColor:RepliconStandardWhiteColor];
    UIImageView *okButtonSeparatorImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, mapDetailView.frame.size.width, 1)];
    [okButtonSeparatorImage setImage:[Util thumbnailImage:LOCKED_IN_OUT_SEPARAROR_IMAGE]];
    [self.okButtonView addSubview:okButtonSeparatorImage];

    if (isResponseReceived)
    {
        UIButton *okBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-2*xOFFSET,40)];
        okBtn.backgroundColor = [UIColor clearColor];
        okBtn.titleLabel.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_17];
        okBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [okBtn setTitle:RPLocalizedString(@"OK", @"") forState:UIControlStateNormal];
        [okBtn addTarget:self action:@selector(dismissView) forControlEvents:UIControlEventTouchUpInside];
        [okBtn setTitleColor:RepliconStandardBlueColor forState:UIControlStateNormal];
        [okButtonView addSubview:okBtn];
    }
    else
    {
        UIActivityIndicatorView *temActivityView=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        punchInfoActivityView=temActivityView;
        [punchInfoActivityView setFrame:CGRectMake((okButtonView.frame.size.width/2)-16, 0, 32, 32)];
        [okButtonView addSubview:punchInfoActivityView];
        [punchInfoActivityView startAnimating];
    }
    
    CGRect frame=punchTempInfoView.frame;
    float y=(punchInfoView.frame.size.height-okButtonView.frame.origin.y-okButtonView.frame.size.height)/2;
    if(y<0)
    {
       y=10.0;
    }
    
    frame.origin.y=y;
    frame.size.height=okButtonView.frame.origin.y+okButtonView.frame.size.height;
    punchTempInfoView.frame=frame;
    [punchTempInfoView addSubview:okButtonView];
    [self.mainScrollview addSubview:punchInfoView];
   punchInfoView.hidden=NO;
    [self.mainScrollview bringSubviewToFront:punchInfoView];
    
    self.mainScrollview.contentSize = CGSizeMake(self.view.frame.size.width,punchInfoView.frame.origin.y+punchInfoView.frame.size.height);
    
}

-(void)dismissView{
    [punchInfoView removeFromSuperview];
    [self.view setBackgroundColor:[Util colorWithHex:@"#E2E2E2" alpha:1.0]];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKCircleRenderer *circleView = [[MKCircleRenderer alloc] initWithCircle:(MKCircle *)overlay] ;
    circleView.fillColor = [Util colorWithHex:@"#157EFB" alpha:0.3];
    return circleView;
}

-(MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:
(id <MKAnnotation>)annotation {
    MKPinAnnotationView *pinView = nil;
    if(annotation != mapView.userLocation)
    {
        static NSString *defaultPinID = @"com.invasivecode.pin";
        pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
        if ( pinView == nil ) pinView = [[MKPinAnnotationView alloc]
                                         initWithAnnotation:annotation reuseIdentifier:defaultPinID];

        pinView.canShowCallout = YES;
        if (isClockIn)
        {
            pinView.image=[Util thumbnailImage:CLOCKED_IN_MAP_NEW_PIN_IMAGE];
        }
        else
        {
            pinView.image=[Util thumbnailImage:CLOCKED_OUT_MAP_NEW_PIN_IMAGE];
        }

    }
    else {
        //[mapView.userLocation setTitle:@"I am here"];
    }
    return pinView;
}

-(void)handleLastPunchResponse:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver: self name: LAST_PUNCH_DATA_NOTIFICATION object: nil];

    NSDictionary *dataDict=notification.userInfo;
    BOOL isError= TRUE;

    if (![dataDict isKindOfClass:[NSNull class]] && dataDict !=nil)
    {
        isError=[[notification.userInfo objectForKey:@"isError"] boolValue];
    }




    if(!isError)
    {

        if (![dataDict isKindOfClass:[NSNull class]] && dataDict !=nil) {

            NSString *fullImageimageLink= @"";
            NSString *fullImageUri= @"";
            NSString *thumbnailImageLink= @"";
            NSString *thumbnailImageUri= @"";

            if ([dataDict objectForKey:@"auditImage"] !=nil  && ![[dataDict objectForKey:@"auditImage"] isKindOfClass:[NSNull class]] )
            {
                if ([[dataDict objectForKey:@"auditImage"] objectForKey:@"imageLink"]!=nil && ![[[dataDict objectForKey:@"auditImage"] objectForKey:@"imageLink"] isKindOfClass:[NSNull class]])
                {
                    fullImageimageLink = [[[dataDict objectForKey:@"auditImage"] objectForKey:@"imageLink"] objectForKey:@"href"];
                    NSDictionary *thumbnailImageDict = [dataDict objectForKey:@"thumbnailImage"];
                    if (thumbnailImageDict!=nil && ![thumbnailImageDict isKindOfClass:[NSNull class]])
                    {
                        if ([thumbnailImageDict objectForKey:@"imageLink"] !=nil && ![[thumbnailImageDict objectForKey:@"imageLink"] isKindOfClass:[NSNull class]])
                        {
                            thumbnailImageLink = [[thumbnailImageDict objectForKey:@"imageLink"] objectForKey:@"href"];
                        }
                        thumbnailImageUri = [thumbnailImageDict objectForKey:@"imageUri"];
                    }
                }
                fullImageUri = [[dataDict objectForKey:@"auditImage"] objectForKey:@"imageUri"];
            }

            NSString *actionUri = [dataDict objectForKey:@"actionUri"];


            NSDictionary *timepunchDataDict=[dataDict objectForKey:@"punchTime"];
            NSMutableDictionary *entryDateDict=[NSMutableDictionary dictionary];
            [entryDateDict setObject:[NSString stringWithFormat:@"%@",[timepunchDataDict objectForKey:@"day"]] forKey:@"day"];
            [entryDateDict setObject:[NSString stringWithFormat:@"%@",[timepunchDataDict objectForKey:@"month"]] forKey:@"month"];
            [entryDateDict setObject:[NSString stringWithFormat:@"%@",[timepunchDataDict objectForKey:@"year"]] forKey:@"year"];

            NSMutableDictionary *timeDict=[NSMutableDictionary dictionary];
            [timeDict setObject:[NSString stringWithFormat:@"%@",[timepunchDataDict objectForKey:@"hour"]] forKey:@"Hour"];
            [timeDict setObject:[NSString stringWithFormat:@"%@",[timepunchDataDict objectForKey:@"minute"]] forKey:@"Minute"];
            [timeDict setObject:[NSString stringWithFormat:@"%@",[timepunchDataDict objectForKey:@"second"]] forKey:@"Second"];


            int day   = [[entryDateDict objectForKey:@"day"] intValue];
            int month = [[entryDateDict objectForKey:@"month"] intValue];
            int year = [[entryDateDict objectForKey:@"year"] intValue];

            NSDateComponents *components = [[NSDateComponents alloc] init];
            [components setHour:[[timepunchDataDict objectForKey:@"hour"] intValue]];
            [components setMinute:[[timepunchDataDict objectForKey:@"minute"]intValue ]];
            [components setSecond:[[timepunchDataDict objectForKey:@"second"] intValue]];
            [components setDay:day];
            [components setMonth:month];
            [components setYear:year];
            NSCalendar *gregorianCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            [gregorianCalendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            NSDate *date = [gregorianCalendar dateFromComponents:components];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];

            NSLocale *locale=[NSLocale currentLocale];
            [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [dateFormat setLocale:locale];
            [dateFormat setDateFormat:@"MMMM dd, yyyy"];
            NSString *dateStr=[dateFormat stringFromDate:date];


            NSString *timeString=[Util convertDateToGetTimeOnly:date];
            NSString *formatString=[Util convertDateToGetFormatOnly:date];



            NSDictionary *tempLocationDict = [dataDict objectForKey:@"geolocation"];

            NSString *addressString= @"";
            float latitude = 0.0;
            float longitude = 0.0;
            if (tempLocationDict!=nil  && ![tempLocationDict isKindOfClass:[NSNull class]] )
            {
                addressString = [tempLocationDict objectForKey:@"address"];
                latitude = [[[tempLocationDict objectForKey:@"gps"] objectForKey:@"latitudeInDegrees"]  floatValue];
                longitude = [[[tempLocationDict objectForKey:@"gps"] objectForKey:@"longitudeInDegrees"]  floatValue];

            }





            NSDictionary *punchInDetail = [dataDict objectForKey:@"punchInAttributes"];
            NSDictionary *breakDetail = [dataDict objectForKey:@"punchStartBreakAttributes"];


            NSString *activityName= @"";
            NSString *activityUri= @"";


            if (![punchInDetail isKindOfClass:[NSNull class]] && punchInDetail !=nil) {
                if (![[punchInDetail objectForKey:@"activity"] isKindOfClass:[NSNull class]] && [punchInDetail objectForKey:@"activity"] !=nil) {
                    activityName = [[punchInDetail objectForKey:@"activity"] objectForKey:@"displayText"];
                    activityUri = [[punchInDetail objectForKey:@"activity"] objectForKey:@"uri"];
                }
            }

            NSString *breakType= @"";
            NSString *breakUri= @"";
            if (![breakDetail isKindOfClass:[NSNull class]] && breakDetail !=nil) {
                if (![[breakDetail objectForKey:@"breakType"] isKindOfClass:[NSNull class]] && [breakDetail objectForKey:@"breakType"] !=nil) {
                    breakType = [[breakDetail objectForKey:@"breakType"] objectForKey:@"displayText"];
                    breakUri = [[breakDetail objectForKey:@"breakType"] objectForKey:@"uri"];
                }
            }

            NSString *agentTypeName= @"";
            NSString *agentTypeUri= @"";


            NSDictionary *agentTypeDetail = [dataDict objectForKey:@"timePunchAgent"];
            if (![agentTypeDetail isKindOfClass:[NSNull class]] && agentTypeDetail !=nil) {
                if (![[agentTypeDetail objectForKey:@"agentTypeUri"] isKindOfClass:[NSNull class]] && [agentTypeDetail objectForKey:@"agentTypeUri"] !=nil) {
                    agentTypeName = [agentTypeDetail objectForKey:@"displayText"];
                    agentTypeUri = [agentTypeDetail objectForKey:@"agentTypeUri"];
                }
            }

            NSMutableDictionary  * responseDict = [NSMutableDictionary dictionary];
            [responseDict setValue:actionUri forKey:@"actionUri"];
            [responseDict setValue:activityName forKey:@"activityName"];
            [responseDict setValue:activityUri forKey:@"activityUri"];
            [responseDict setValue:breakType forKey:@"breakType"];
            [responseDict setValue:breakUri forKey:@"breakUri"];
            [responseDict setValue:dateStr forKey:@"entry_date"];
            [responseDict setValue:fullImageimageLink forKey:@"full_image_link"];
            [responseDict setValue:fullImageUri forKey:@"full_image_uri"];
            [responseDict setValue:thumbnailImageLink forKey:@"thumbnail_image_link"];
            [responseDict setValue:thumbnailImageUri forKey:@"thumbnail_image_uri"];
            [responseDict setValue:timeString forKey:@"time"];
            [responseDict setValue:formatString forKey:@"time_format"];
            [responseDict setValue:addressString forKey:@"address"];
            [responseDict setObject:[NSNumber numberWithFloat:latitude] forKey:@"latitude"];
            [responseDict setObject:[NSNumber numberWithFloat:longitude] forKey:@"longitude"];
            [responseDict setObject:[NSNumber numberWithDouble:[[[NSCalendar currentCalendar] dateFromComponents:components] timeIntervalSince1970]] forKey:@"time_stamp"];
            [responseDict setValue:agentTypeName forKey:@"agentTypeName"];
            [responseDict setValue:agentTypeUri forKey:@"agentTypeUri"];

            AttendanceModel *obj_ttendanceModel = [[AttendanceModel alloc] init];
            [obj_ttendanceModel saveLastPuchDataFromApiToDB:responseDict];

            [self showLastPunchDataView];

        }


    }
    else
    {

        [self showLastPunchDataView];
    }


}


-(void)handlePunchDataNotification :(NSNotification *)notification
{

}






-(NSMutableDictionary*)getPunchDataDictionary
{
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    NSString *projectName=tsEntryObject.timeEntryProjectName;
    NSString *projectUri=tsEntryObject.timeEntryProjectUri;
    NSString *clientName=tsEntryObject.timeEntryClientName;
    NSString *clientUri=tsEntryObject.timeEntryClientUri;
    NSString *taskName=tsEntryObject.timeEntryTaskName;
    NSString *taskUri=tsEntryObject.timeEntryTaskUri;
    NSString *activityName=tsEntryObject.timeEntryActivityName;
    NSString *activityUri=tsEntryObject.timeEntryActivityUri;
    NSString *billingName=tsEntryObject.timeEntryBillingName;
    NSString *billingUri=tsEntryObject.timeEntryBillingUri;
    NSString *breakName=tsEntryObject.breakName;
    NSString *breakUri=tsEntryObject.breakUri;

    if (projectUri == nil || [projectUri isKindOfClass:[NSNull class]]||[projectUri isEqualToString:@""])
    {
        projectUri=nil;
    }
    else
    {
        [dict setObject:projectName forKey:@"projectName"];
        [dict setObject:projectUri forKey:@"projectUri"];
    }
    if (clientUri == nil || [clientUri isKindOfClass:[NSNull class]]||[clientUri isEqualToString:@""])
    {
        clientUri=nil;
    }
    else
    {
        [dict setObject:clientUri forKey:@"clientName"];
        [dict setObject:clientName forKey:@"clientUri"];
    }

    if (taskUri == nil || [taskUri isKindOfClass:[NSNull class]]||[taskUri isEqualToString:@""])
    {
        taskUri=nil;
    }
    else
    {
        [dict setObject:taskName forKey:@"taskName"];
        [dict setObject:taskUri forKey:@"taskUri"];
    }
    if (billingUri == nil || [billingUri isKindOfClass:[NSNull class]]||[billingUri isEqualToString:@""])
    {
        billingUri=nil;
    }
    else
    {
        [dict setObject:billingName forKey:@"billingName"];
        [dict setObject:billingUri forKey:@"billingUri"];

    }
    if (activityUri == nil || [activityUri isKindOfClass:[NSNull class]]||[activityUri isEqualToString:@""])
    {
        activityUri=nil;
    }
    else
    {
        [dict setObject:activityName forKey:@"activityName"];
        [dict setObject:activityUri forKey:@"activityUri"];
    }

    if (breakUri == nil || [breakUri isKindOfClass:[NSNull class]]||[breakUri isEqualToString:@""])
    {
        breakUri=nil;
    }
    else
    {
        [dict setObject:breakName forKey:@"breakName"];
        [dict setObject:breakUri forKey:@"breakUri"];
    }

    return dict;
}

-(void)sendRequestToGetLastPunchData
{
    if(![NetworkMonitor isNetworkAvailableForListener: self])
    {
        [Util showOfflineAlert];
        return;
    }

    [self addActiVityIndicator];

    if (self.lastPunchView) {
        [self.lastPunchView removeFromSuperview];
    }


    //REQUET TO GET LAST PUNCH
    NSString *userID=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserUri"];
    [[RepliconServiceManager attendanceService] sendRequestToGetLastPunchDataToServiceForuserUri:userID];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LAST_PUNCH_DATA_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleLastPunchResponse:)
                                                 name: LAST_PUNCH_DATA_NOTIFICATION
                                               object: nil];

}

-(void)showLastPunchDataView
{
    self.lastPunchView.frame = CGRectMake(0, buttonView.bottom, self.view.width, self.view.height-buttonView.height);
    AttendanceModel *attendanceModel=[[AttendanceModel alloc]init];
    NSMutableArray *tempArray = [attendanceModel getLastPuncheFromDB];

    if (tempArray !=nil  && ![tempArray isKindOfClass:[NSNull class]]) {
        NSDictionary *responsedict = [tempArray objectAtIndex:0];
        for (UIView *subView in self.lastPunchView.subviews) {
            [subView removeFromSuperview];
        }
        CGFloat topViewPadding = 17.0;
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(topViewPadding, 25, self.lastPunchView.width-(2*topViewPadding), 25)];
        [topView setBackgroundColor: RepliconStandardGrayColor];
        
        CGFloat lastPunchLabelPadding = 9;
        UILabel *lastPunchLabel=[[UILabel alloc]initWithFrame:CGRectMake(lastPunchLabelPadding, 0,topView.width-(2*lastPunchLabelPadding), 25)];
        [lastPunchLabel setText:RPLocalizedString(LAST_PUNCH_TEXT, @"")];
        [lastPunchLabel setBackgroundColor:[UIColor clearColor]];
        [lastPunchLabel setTextColor:RepliconStandardWhiteColor];
        [lastPunchLabel setTextAlignment:NSTextAlignmentLeft];
        [lastPunchLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
        [topView addSubview:lastPunchLabel];

        PunchMapViewController  *obj_punchMapViewController=[[PunchMapViewController alloc]init];
        obj_punchMapViewController.delegate = self;
        UIView *tempView =  [obj_punchMapViewController createViewWithLocationAvailable:responsedict];
        CGRect lastPunchViewFrame=self.lastPunchView.frame;
        lastPunchViewFrame.size.height=tempView.height+topView.height;
        self.lastPunchView.frame =lastPunchViewFrame;
        [self.lastPunchView addSubview: tempView];
        [self.lastPunchView addSubview:topView];
        [self.mainScrollview addSubview:self.lastPunchView];
        //Implementation for MOBI-728//JUHI
        [self.mainScrollview sendSubviewToBack:lastPunchView];
        [self.mainScrollview bringSubviewToFront:self.punchInfoView];
        
        self.mainScrollview.frame=CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        
        self.mainScrollview.contentSize = CGSizeMake(self.view.frame.size.width,self.lastPunchView.bottom);
    }
    [self removeActiVityIndicator];
}

-(void)addActiVityIndicator
{
    [self.activityView removeFromSuperview];
    self.activityView=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self.activityView setFrame:CGRectMake(0, buttonView.frame.size.height, SCREEN_WIDTH, SCREEN_WIDTH- buttonView.frame.size.height)];
    [self.activityView setBackgroundColor:[UIColor clearColor]];
    [self.mainScrollview addSubview:self.activityView];
    [self.activityView startAnimating];
    
     self.mainScrollview.contentSize = CGSizeMake(self.view.frame.size.width,self.activityView.frame.origin.y+self.activityView.frame.size.height);
}

-(void)removeActiVityIndicator
{
    [self.activityView removeFromSuperview];
    [self.activityView stopAnimating];
}



#pragma mark - BUTTON ACTION

-(void)startButtonAction
{
    if(![NetworkMonitor isNetworkAvailableForListener: self])
    {
        [Util showOfflineAlert];
        return;
    }

    isButtonAction = true;

    self.punchActionUri=PUNCH_IN_URI;

    NSString *timesheetUri=nil;
    TimeEntryViewController *timeEntryVC=[[TimeEntryViewController alloc] init];
    timeEntryVC.delegate=self;
    timeEntryVC.isEditBreak=FALSE;
    NSString *projectName=nil;
    NSString *projectUri=nil;
    NSString *clientName=nil;
    NSString *clientUri=nil;
    NSString *taskName=nil;
    NSString *taskUri=nil;
    NSString *activityName=nil;
    NSString *activityUri=nil;
    NSString *billingName=nil;
    NSString *billingUri=nil;
    NSString *breakName=nil;
    NSString *breakUri=nil;

    TimesheetObject *timesheetObject=[[TimesheetObject alloc] init];
    [timesheetObject setProjectName:projectName];
    [timesheetObject setProjectIdentity: projectUri];
    [timesheetObject setClientName:clientName];
    [timesheetObject setClientIdentity: clientUri];
    [timesheetObject setProjectName:projectName];
    [timesheetObject setProjectIdentity: projectUri];
    [timesheetObject setTaskName: taskName];
    [timesheetObject setTaskIdentity: taskUri];
    [timesheetObject setBillingName: billingName];
    [timesheetObject setBillingIdentity:billingUri];
    [timesheetObject setActivityName:activityName];
    [timesheetObject setActivityIdentity:activityUri];
    [timesheetObject setBreakName:breakName];
    [timesheetObject setBreakUri:breakUri];
    [timesheetObject setTimesheetURI:timesheetUri];
    timeEntryVC.timesheetObject=timesheetObject;
    timeEntryVC.screenViewMode=ADD_PROJECT_ENTRY;
    timeEntryVC.timesheetURI=timesheetUri;
    timeEntryVC.isFromLockedInOut=NO;
    timeEntryVC.isFromAttendance=YES;
    if (isActivityAccess && !isProjectAccess && !isBillingAccess)
    {
        SearchViewController *searchViewCtrl=[[SearchViewController alloc]init];

        searchViewCtrl.delegate=self;
        searchViewCtrl.isFromLockedInOut=NO;
        searchViewCtrl.isFromAttendance=YES;
        searchViewCtrl.selectedProject=timesheetObject.projectName;
        searchViewCtrl.entryDelegate=timeEntryVC;
        searchViewCtrl.selectedTimesheetUri=timesheetObject.timesheetURI;
        searchViewCtrl.selectedProjectUri=timesheetObject.projectIdentity;
        searchViewCtrl.selectedTaskUri=timesheetObject.taskIdentity;
        searchViewCtrl.isOnlyActivity=YES;
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        //Implementation for US8849//JUHI
        NSMutableArray *activityDetail=[timesheetModel getActivityDetailsFromDBForActivityUri:timesheetObject.activityIdentity];

        if ([activityDetail count]>0)
        {
            searchViewCtrl.selectedActivityName=[[activityDetail objectAtIndex:0] objectForKey:@"activity_Name"];

        }
        else
            searchViewCtrl.selectedActivityName=timesheetObject.activityName;


        searchViewCtrl.screenMode=ACTIVITY_SCREEN;
        searchViewCtrl.selectedItem=RPLocalizedString(ADD_ACTIVITY, @"");
        searchViewCtrl.searchProjectString=timesheetObject.activityName;
        searchViewCtrl.isPreFilledSearchString=YES;
        [self.navigationController pushViewController:searchViewCtrl animated:YES];

        //[self.navigationController pushViewController:timeEntryVC animated:YES];
    }
    else if (!isProjectAccess && !isActivityAccess && !isBillingAccess)
    {

        LoginModel *loginModel=[[LoginModel alloc]init];
        timeEntryVC.isProjectAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchProjectAccess"];
        timeEntryVC.isClientAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchClientAccess"];
        timeEntryVC.isActivityAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchActivityAccess"];
        timeEntryVC.isBillingAccess =[loginModel getStatusForGivenPermissions:@"hasTimepunchBillingAccess"];
        timeEntryVC.activitySelectionRequired=[loginModel getStatusForGivenPermissions:@"timepunchActivitySelectionRequired"];
        timeEntryVC.isUsingAuditImages=[loginModel getStatusForGivenPermissions:@"timepunchAuditImageRequired"];
        timeEntryVC.delegate=self;

        [timeEntryVC continueAction:nil];
    }
    else
    {
        [self.navigationController pushViewController:timeEntryVC animated:YES];
    }





}
-(void)stopButtonAction
{

    self.punchActionUri=PUNCH_OUT_URI;


    BOOL isCameraPermission=TRUE;

    DeviceType deviceType = [self getDeviceType];
    if (deviceType == OnDevice)
    {

        NSArray *devices = [AVCaptureDevice devices];
        AVCaptureDevice *frontCamera;
        AVCaptureDevice *backCamera;

        for (AVCaptureDevice *device in devices) {

            if ([device hasMediaType:AVMediaTypeVideo]) {

                if ([device position] == AVCaptureDevicePositionBack) {
                    NSLog(@"Device position : back");
                    backCamera = device;
                }
                else {
                    NSLog(@"Device position : front");
                    frontCamera = device;
                }
            }
        }
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        if (!input)
        {
            isCameraPermission=FALSE;
        }

    }
    else

    {
        isCameraPermission=TRUE;
    }

    if (!isCameraPermission && self.isUsingAuditImages) {

        [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                       otherButtonTitle:nil
                                               delegate:self
                                                message:RPLocalizedString(CameraDisableMsg, @"")
                                                  title:@""
                                                    tag:001];


    }
    else{
        if (self.isUsingAuditImages && isCameraPermission)
        {
            CameraCaptureViewController *cameraViewCtrl=[[CameraCaptureViewController alloc]init];
            cameraViewCtrl._parentdelegate=self;
            cameraViewCtrl.projectInfoDict=[self getPunchDataDictionary];
            isButtonAction = true;
            cameraViewCtrl._delegate=self;
            cameraViewCtrl.isPunchIn=NO;
            cameraViewCtrl.hidesBottomBarWhenPushed = YES ;
            [self.navigationController pushViewController:cameraViewCtrl animated:FALSE];
        }
        else
        {
            if (![NetworkMonitor isNetworkAvailableForListener:self])
            {
                [Util showOfflineAlert];

            }
            else
            {
                isButtonAction = true;



                self.punchMapViewController=[[PunchMapViewController alloc]init];
                self.punchMapViewController.isClockIn=NO;
                self.punchMapViewController.delegate=self;
                self.punchMapViewController.punchTime=[Util getCurrentTime:YES];
                self.punchMapViewController.punchTimeAmPm=[Util getCurrentTime:NO];
                self.punchMapViewController._parentDelegate=self;


                punchMapViewController.locationDict=self.locationDict;


                punchMapViewController.projectInfoDict=[self getPunchDataDictionary];

                [punchMapViewController checkForLocation];
            }
        }
    }





}//MOBI-849
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==001)
    {
        // DO NOTHING
    }
}

-(void)breakButtonAction
{
    if(![NetworkMonitor isNetworkAvailableForListener: self])
    {
        [Util showOfflineAlert];
        return;
    }

    isButtonAction = true;

    self.punchActionUri=PUNCH_START_BREAK_URI;

    CLS_LOG(@"-----Break Selected to start punch-----");
    TimeEntryViewController *timeEntryVC=[[TimeEntryViewController alloc] init];
    TimesheetObject *sheetObj=[[TimesheetObject alloc]init];
    timeEntryVC.delegate=self;
    timeEntryVC.isEditBreak=TRUE;
    timeEntryVC.timesheetObject=sheetObj;
    timeEntryVC.isFromLockedInOut=NO;
    timeEntryVC.isFromAttendance=YES;
    timeEntryVC.screenMode=EDIT_BREAK_ENTRY;
    timeEntryVC.isStartNewTask=YES;
    [self.navigationController pushViewController:timeEntryVC animated:YES];
}

-(void)startNewTaskAction
{
    if(![NetworkMonitor isNetworkAvailableForListener: self])
    {
        [Util showOfflineAlert];
        return;
    }

    isButtonAction = true;

    self.punchActionUri=PUNCH_TRANSFER_URI;

    CLS_LOG(@"-----Start New Task for punch-----");
    NSString *timesheetUri=nil;
    TimeEntryViewController *timeEntryVC=[[TimeEntryViewController alloc] init];
    timeEntryVC.delegate=self;
    timeEntryVC.isEditBreak=FALSE;
    NSString *projectName=nil;
    NSString *projectUri=nil;
    NSString *clientName=nil;
    NSString *clientUri=nil;
    NSString *taskName=nil;
    NSString *taskUri=nil;
    NSString *activityName=nil;
    NSString *activityUri=nil;
    NSString *billingName=nil;
    NSString *billingUri=nil;
    NSString *breakName=nil;
    NSString *breakUri=nil;

    TimesheetObject *timesheetObject=[[TimesheetObject alloc] init];
    [timesheetObject setProjectName:projectName];
    [timesheetObject setProjectIdentity: projectUri];
    [timesheetObject setClientName:clientName];
    [timesheetObject setClientIdentity: clientUri];
    [timesheetObject setProjectName:projectName];
    [timesheetObject setProjectIdentity: projectUri];
    [timesheetObject setTaskName: taskName];
    [timesheetObject setTaskIdentity: taskUri];
    [timesheetObject setBillingName: billingName];
    [timesheetObject setBillingIdentity:billingUri];
    [timesheetObject setActivityName:activityName];
    [timesheetObject setActivityIdentity:activityUri];
    [timesheetObject setBreakName:breakName];
    [timesheetObject setBreakUri:breakUri];
    [timesheetObject setTimesheetURI:timesheetUri];
    timeEntryVC.timesheetObject=timesheetObject;
    timeEntryVC.screenViewMode=ADD_PROJECT_ENTRY;
    timeEntryVC.timesheetURI=timesheetUri;
    timeEntryVC.isFromLockedInOut=NO;
    timeEntryVC.isFromAttendance=YES;
    timeEntryVC.isStartNewTask=YES;

    if (isActivityAccess && !isProjectAccess && !isBillingAccess)
    {
        SearchViewController *searchViewCtrl=[[SearchViewController alloc]init];

        searchViewCtrl.delegate=self;
        searchViewCtrl.isFromLockedInOut=NO;
        searchViewCtrl.isFromAttendance=YES;
        searchViewCtrl.selectedProject=timesheetObject.projectName;
        searchViewCtrl.entryDelegate=timeEntryVC;
        searchViewCtrl.selectedTimesheetUri=timesheetObject.timesheetURI;
        searchViewCtrl.selectedProjectUri=timesheetObject.projectIdentity;
        searchViewCtrl.selectedTaskUri=timesheetObject.taskIdentity;
        searchViewCtrl.isOnlyActivity=YES;
        searchViewCtrl.isStartNewTask=YES;
        TimesheetModel *timesheetModel=[[TimesheetModel alloc]init];
        //Implementation for US8849//JUHI
        NSMutableArray *activityDetail=[timesheetModel getActivityDetailsFromDBForActivityUri:timesheetObject.activityIdentity];

        if ([activityDetail count]>0)
        {
            searchViewCtrl.selectedActivityName=[[activityDetail objectAtIndex:0] objectForKey:@"activity_Name"];

        }
        else
            searchViewCtrl.selectedActivityName=timesheetObject.activityName;


        searchViewCtrl.screenMode=ACTIVITY_SCREEN;
        searchViewCtrl.selectedItem=RPLocalizedString(ADD_ACTIVITY, @"");
        searchViewCtrl.searchProjectString=timesheetObject.activityName;
        searchViewCtrl.isPreFilledSearchString=YES;
        [self.navigationController pushViewController:searchViewCtrl animated:YES];
    }
    else if (!isProjectAccess && !isActivityAccess && !isBillingAccess)
    {
        LoginModel *loginModel=[[LoginModel alloc]init];
        timeEntryVC.isProjectAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchProjectAccess"];
        timeEntryVC.isClientAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchClientAccess"];
        timeEntryVC.isActivityAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchActivityAccess"];
        timeEntryVC.isBillingAccess =[loginModel getStatusForGivenPermissions:@"hasTimepunchBillingAccess"];
        timeEntryVC.activitySelectionRequired=[loginModel getStatusForGivenPermissions:@"timepunchActivitySelectionRequired"];
        timeEntryVC.isUsingAuditImages=[loginModel getStatusForGivenPermissions:@"timepunchAuditImageRequired"];
        timeEntryVC.delegate=self;
        [timeEntryVC continueAction:nil];
    }
    else
    {
        [self.navigationController pushViewController:timeEntryVC animated:YES];
    }






}

-(void)goToMapView
{
    isButtonAction = true;

    PunchMapViewController *obj_PunchMapViewController = [[PunchMapViewController alloc] init];

    AttendanceModel *attendanceModel=[[AttendanceModel alloc]init];
    NSMutableArray *tempArray = [attendanceModel getLastPuncheFromDB];


    if (tempArray !=nil  && ![tempArray isKindOfClass:[NSNull class]]) {
        NSDictionary *responsedict = [tempArray objectAtIndex:0];
        NSString *actionUri = [responsedict objectForKey:@"actionUri"];
        if ([actionUri isEqualToString:PUNCH_IN_URI] || [actionUri isEqualToString:PUNCH_START_BREAK_URI] ||[actionUri isEqualToString:PUNCH_TRANSFER_URI])
        {
            obj_PunchMapViewController.isClockIn = true;
        }
        else
        {
            obj_PunchMapViewController.isClockIn = false;
        }

    }

    obj_PunchMapViewController.delegate = self;
    [self.navigationController pushViewController:obj_PunchMapViewController animated:YES];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //add location data
    locationDict = [NSMutableDictionary dictionary];

    [locationDict setValue:@"" forKey:@"lng"];
    [locationDict setValue:@"" forKey:@"lat"];
    [locationDict setObject:[NSNumber numberWithBool:NO] forKey:@"available"];

    UIImage *locationDisabledImage = [UIImage imageNamed:LOCATION_DISABLED_IMAGE];
    [locationImgView setBackgroundImage:locationDisabledImage forState:UIControlStateNormal];
    [locationImgView setUserInteractionEnabled:YES];
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    [locationImgView setUserInteractionEnabled:NO];
    if (currentLocation != nil)
    {
        NSMutableDictionary *finalLocationDict=[NSMutableDictionary dictionary];
        NSMutableDictionary *dict=[NSMutableDictionary dictionary];
        [dict setValue:[NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude] forKey:@"lng"];
        [dict setValue:[NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude] forKey:@"lat"];
        [dict setValue:[NSString stringWithFormat:@"%.8f", currentLocation.verticalAccuracy] forKey:@"verticalAccuracy"];
        [dict setValue:[NSString stringWithFormat:@"%.8f", currentLocation.horizontalAccuracy] forKey:@"horizontalAccuracy"];

        [finalLocationDict setObject:@"" forKey:@"LOCATION_INFO_STRING"];
        [finalLocationDict setObject:dict forKey:@"LOCATION_INFO_DICT"];
        self.locationDict=finalLocationDict;
        [self.locationDict setObject:[NSNumber numberWithBool:YES] forKey:@"available"];
        UIImage *locationEnabledImage = [UIImage imageNamed:LOCATION_ENABLED_IMAGE];
        [locationImgView setBackgroundImage:locationEnabledImage forState:UIControlStateNormal];

    }
    if (attendanceLocationUpdatedDelegate != nil && ![attendanceLocationUpdatedDelegate isKindOfClass:[NSNull class]] &&
        [attendanceLocationUpdatedDelegate conformsToProtocol:@protocol(AttendanceLocationUpdatedDelegateProtocol)])
    {
        [attendanceLocationUpdatedDelegate handleLocationUpdatedwithlocationManager:manager didUpdateToLocation:newLocation fromLocation:oldLocation];

    }
}

-(void)getAddress:(CLLocationManager *)locationManger fromDelegate:(id)delegate
{

    CLLocation *currentLocation =locationManager.location;
    __block NSMutableDictionary *finalLocationDict=nil;

    if (currentLocation != nil)
    {
        CLLocation *location = currentLocation;


        NSString *urlAsString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f",location.coordinate.latitude,location.coordinate.longitude];
        NSURL *url = [NSURL URLWithString:urlAsString];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];


        [NSURLConnection
         sendAsynchronousRequest:urlRequest
         queue:[NSOperationQueue mainQueue]
         completionHandler:^(NSURLResponse *response,
                             NSData *data,
                             NSError *error)



         {


             if (error) {
                 NSLog(@"Error %@", error.description);
                 [delegate geoAddressReceived:self.locationDict];
             }

             if ([data length] >0 && error == nil)
             {

                 NSDictionary *parsedData =(NSDictionary *) [JsonWrapper parseJson: data error: nil];
                 if ([[parsedData objectForKey:@"status"]isEqualToString:@"OK"])
                 {
                     NSArray *resultsArr=(NSArray *)[parsedData objectForKey:@"results"];
                     if ([resultsArr count]>0)
                     {
                         NSDictionary *addressDictionary = [resultsArr objectAtIndex:0];
                         NSString *formattedAddressString=[addressDictionary objectForKey:@"formatted_address"];
                         if (formattedAddressString==nil)
                         {
                             formattedAddressString=@"";
                         }
                         finalLocationDict=[NSMutableDictionary dictionary];
                         NSMutableDictionary *dict=[NSMutableDictionary dictionary];
                         [dict setValue:[NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude] forKey:@"lng"];
                         [dict setValue:[NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude] forKey:@"lat"];
                         [dict setValue:[NSString stringWithFormat:@"%.8f", currentLocation.verticalAccuracy] forKey:@"verticalAccuracy"];
                         [dict setValue:[NSString stringWithFormat:@"%.8f", currentLocation.horizontalAccuracy] forKey:@"horizontalAccuracy"];
                         
                         [finalLocationDict setObject:formattedAddressString forKey:@"LOCATION_INFO_STRING"];
                         [finalLocationDict setObject:dict forKey:@"LOCATION_INFO_DICT"];
                         self.locationDict=finalLocationDict;
                         [self.locationDict setObject:[NSNumber numberWithBool:YES] forKey:@"available"];
                         UIImage *locationEnabledImage = [UIImage imageNamed:LOCATION_ENABLED_IMAGE];
                         [locationImgView setBackgroundImage:locationEnabledImage forState:UIControlStateNormal];
                         //NSLog(@"LOCATION:::%@",locationDict);
                         [delegate geoAddressReceived:finalLocationDict];
                         
                     }
                     else
                     {
                         [delegate geoAddressReceived:self.locationDict];
                     }
                 }
                 else
                 {
                     [delegate geoAddressReceived:self.locationDict];
                 }
                 
             }
             else if ([data length] == 0 && error == nil)
             {
                 NSLog(@"Nothing was downloaded.");
                 [delegate geoAddressReceived:self.locationDict];
             }
             
         }];
        
    }
    
}

-(void)dismissCameraView
{
    if (self.lastPunchView) {
        [self.lastPunchView removeFromSuperview];
    }
    [self addActiVityIndicator];
}


-(void)sendPunchForData:(NSMutableDictionary *)dataDict actionType:(NSString *)action
{
    if(![NetworkMonitor isNetworkAvailableForListener: self])
    {
        [Util showOfflineAlert];
        return;
    }
}

-(void)locationButtonClicked:(id)sender
{
    if (![[locationDict objectForKey:@"available"] boolValue])
    {
        [Util errorAlert:@"" errorMessage:RPLocalizedString( LOCATION_SETTINGS_ALERT,@"")];
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)punchHistoryAction:(id)sender
{
    NSArray *xViewController = self.tabBarController.viewControllers;
    
    for(int i=0; i<[xViewController count]; i++)
    {
        if ([[xViewController objectAtIndex:i] isKindOfClass:[PunchHistoryNavigationController class]])
        {
            UITabBarController *tabBar = self.tabBarController;
            [tabBar setSelectedIndex:i];
            break;
        }
    }
}


-(void)sendRequestToRecalculateScriptDataWithDataDict:(NSDictionary *)dateDict
{
    NSString *userID=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserUri"];
    
    if(userID!=nil)
    {
        [[RepliconServiceManager calculatePunchTotalService] sendRequestToRecalculateScriptDataForuserUri:userID WithDate:dateDict];
    }
}

-(DeviceType)getDeviceType
{
    if (TARGET_IPHONE_SIMULATOR)
        return OnSimulator;
    else
        return OnDevice;
}

@end
