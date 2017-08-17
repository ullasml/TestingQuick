//
//  PunchEntryViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 09/05/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "PunchEntryViewController.h"
#import "Constants.h"
#import "Util.h"
#import "UISegmentedControlExtension.h"
#import "UIImageView+AFNetworking.h"
#import "TimeEntryViewController.h"
#import "FrameworkImport.h"
#import "AppDelegate.h"
#import "RepliconServiceManager.h"
#import "SearchViewController.h"
#import "TeamTimeViewController.h"
#import "TimesheetNavigationController.h"
#import "ExpensesNavigationController.h"
#import "BookedTimeOffNavigationController.h"
#import "AttendanceNavigationController.h"
#import "PunchHistoryNavigationController.h"
#import "ShiftsNavigationController.h"
#import "ApprovalsNavigationController.h"
#import "TeamTimeNavigationController.h"
#import "SupervisorDashboardNavigationController.h"
#import "UIView+Additions.h"

@interface PunchEntryViewController ()

@property (nonatomic, assign) id navigationType;
@end



@implementation PunchEntryViewController
@synthesize deleteButton;
@synthesize screenMode;
@synthesize currentPageDate;
@synthesize currentUser;
@synthesize segmentedCtrl;
@synthesize punchUri;
@synthesize tableFooterView;
@synthesize tableHeaderView;
@synthesize BtnClicked;
@synthesize punchObj;
@synthesize activityLabel;
@synthesize locationImage;
@synthesize timeBtn;
@synthesize amPmLb;
@synthesize datePicker;
@synthesize toolbar;
@synthesize doneButton;
@synthesize spaceButton;
@synthesize setViewTag;
@synthesize selectedSegmentLabel;
@synthesize selectedSegmentImageview;
@synthesize selectedSegmentBtn;
@synthesize discloserImageview;
@synthesize hasBreakAccess,hasActivityAccess;
@synthesize imgLabel;
//Implemetation for Punch-229//JUHI
@synthesize dateBtn;
@synthesize punchDatePicker;
@synthesize previousDateValue;
@synthesize timesheetURI;
@synthesize delegate;
@synthesize containerview;

#define HEADER_LABEL_HEIGHT 30
#define LABEL_PADDING 10
#define COMMENTS_LABEL_HEIGHT 40

#define kTagFirst 1
#define kTagSecond 2
#define kTagThird 3
#define kTagFour 4

#define In_Tag 0
#define Out_Tag 1
#define Transfer_Tag 2
#define Break_Tag 3
-(void)loadView
{
	[super loadView];
    self.navigationType = (UINavigationController*)self.tabBarController.selectedViewController;
	[self.view setBackgroundColor:[Util colorWithHex:@"#f8f8f8" alpha:1]];
    
    self.containerview = [[UIScrollView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    [self.containerview setBackgroundColor:[UIColor clearColor]];
    self.containerview.showsHorizontalScrollIndicator = NO;
    self.containerview.showsVerticalScrollIndicator = YES;
    [self.view addSubview:self.containerview];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if (screenMode==ADD_PUNCH_ENTRY) {
        [Util setToolbarLabel: self withText: RPLocalizedString(AddPunch_Title, @"")];
    }
    else if(screenMode==EDIT_PUNCH_ENTRY)
        [Util setToolbarLabel: self withText: RPLocalizedString(PunchDetail_Title, @"")];
    else
    {
        [Util setToolbarLabel: self withText: RPLocalizedString(PunchDetail_Title, @"")];
    }
    
    if (screenMode!=VIEW_PUNCH_ENTRY)
    {
        UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]
                                       initWithTitle: RPLocalizedString (Cancel_Button_Title, Cancel_Button_Title)
                                       style: UIBarButtonItemStylePlain
                                       target: self
                                       action: @selector(cancelAction:)];
        [self.navigationItem setLeftBarButtonItem:leftButton animated:NO];
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString(Save_Button_Title, Save_Button_Title)
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(saveAction:)];
        
        [self.navigationItem setRightBarButtonItem:rightButton animated:NO];
    }
    
    
    if ([self.navigationType isKindOfClass:[TeamTimeNavigationController class]]||
        [self.navigationType isKindOfClass:[SupervisorDashboardNavigationController class]])
    {
        TeamTimeModel *teamTimeModel=[[TeamTimeModel alloc]init];
        NSMutableDictionary *userCapabilitiesDict=[teamTimeModel getUserCapabilitiesForUserUri:self.punchObj.punchUserUri];
        
        self.hasBreakAccess=[[userCapabilitiesDict objectForKey:@"hasBreakAccess"]boolValue];
        self.hasActivityAccess=[[userCapabilitiesDict objectForKey:@"hasActivityAccess"]boolValue];
    }
    else if ([self.navigationType isKindOfClass:[PunchHistoryNavigationController class]])
    {
        LoginModel *loginModel=[[LoginModel alloc]init];
        self.hasBreakAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchBreakAccess"];
        self.hasActivityAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchActivityAccess"];
    }
    else
    {
        LoginModel *loginModel=[[LoginModel alloc]init];
        self.hasBreakAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchBreakAccess"];
        self.hasActivityAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchActivityAccess"];
    }
    
    [self initializeView];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
        [self doneClicked];
        //Implemetation for Punch-229//JUHI
        [self punchDateDoneClicked];
}

-(void)initializeView{
    
    
    //Implementation for Punch-229//JUHI
    float y=0;
    if ([self.navigationType isKindOfClass:[TeamTimeNavigationController class]])
    {
        CGRect frame=CGRectMake(0, 0, self.containerview.width, HEADER_LABEL_HEIGHT);
        UIView *headerBackgroundView=[[UIView alloc]initWithFrame:frame];
        [headerBackgroundView setBackgroundColor:[Util colorWithHex:@"#eeeeee" alpha:1]];
        [self.containerview addSubview:headerBackgroundView];
        
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectInset(frame, LABEL_PADDING, 0)];
        headerLabel.backgroundColor = [Util colorWithHex:@"#eeeeee" alpha:1];
        headerLabel.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12];
        headerLabel.textAlignment = NSTextAlignmentLeft;
        headerLabel.text=[NSString stringWithFormat:@" %@ %@ ", RPLocalizedString(FORSTRING, @""),currentUser];
        [self.containerview addSubview:headerLabel];
        
        
        UIView *separatorView=[[UIView alloc]initWithFrame:CGRectMake(0, HEADER_LABEL_HEIGHT, self.containerview.width, 1)];
        [separatorView setBackgroundColor:[Util colorWithHex:@"#D6D6D6" alpha:1]];
        [self.containerview addSubview:separatorView];
        
        
        y=HEADER_LABEL_HEIGHT;
    }
    
    float xOffset=5.0f;
    float yOffset=9.0f;
    float wSegment=self.view.frame.size.width-2*xOffset;
    float hSegment=34.0f;
    
    if (screenMode==ADD_PUNCH_ENTRY)
    {
        
        NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:
                          RPLocalizedString(IN_TEXT,@""),RPLocalizedString(OUT_TEXT,@""),nil];
        //Implementation for MOBI-829//JUHI
        if (hasActivityAccess)
        {
             [items addObject:RPLocalizedString(Transfer_Title,@"")];
        }
        
        if (hasBreakAccess)
        {
            [items addObject:RPLocalizedString(BREAK_ENTRY,@"")];
        }
        
        UISegmentedControl *tempSegmentCtrl = [[UISegmentedControl alloc] initWithItems:items];
        
        self.segmentedCtrl=tempSegmentCtrl;
        
        
        
//        [self.segmentedCtrl setSegmentedControlStyle:UISegmentedControlStyleBar];
        [self.segmentedCtrl setFrame:CGRectMake(xOffset, yOffset, wSegment, hSegment)];
        [self.segmentedCtrl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
        [self.segmentedCtrl setTag:kTagFirst forSegmentAtIndex:0];
         [self.segmentedCtrl setTag:kTagSecond forSegmentAtIndex:1];
        //Implementation for MOBI-829//JUHI
        if (hasActivityAccess)
        {
             [self.segmentedCtrl setTag:kTagThird forSegmentAtIndex:2];
            
        }
       
        if (hasBreakAccess && !hasActivityAccess)
        {
            [self.segmentedCtrl setTag:kTagThird forSegmentAtIndex:2];
            
        }
        else if(hasBreakAccess)
            [self.segmentedCtrl setTag:kTagFour forSegmentAtIndex:3];
        
        
        //Fix for ios7//JUHI
        float version=[[UIDevice currentDevice].systemVersion newFloatValue];
        if (version>=7.0)
        {
            [self.segmentedCtrl setTintColor:[Util colorWithHex:@"#107ebe" alpha:1]];
            
           
            
            [self.segmentedCtrl setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:12],NSForegroundColorAttributeName:[UIColor blackColor]}
                                              forState:UIControlStateNormal];
            
            [self.segmentedCtrl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}
                                              forState:UIControlStateSelected];
            
            
            [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagFirst];
            [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagSecond];
             //Implementation for MOBI-829//JUHI
            if (hasActivityAccess)
            {
                 [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagThird];
            }
           
            if (hasBreakAccess && !hasActivityAccess)
            {
                [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagThird];
            }
            else if(hasBreakAccess)
               [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagFour];
            
            
            [self changeUISegmentFont:self.segmentedCtrl];
             [self setTextColorsForSegmentedControl:self.segmentedCtrl];
            self.segmentedCtrl.selectedSegmentIndex=setViewTag;
        }
        else{
            [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagFirst];
            [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagSecond];
            //Implementation for MOBI-829//JUHI
            if (hasActivityAccess)
            {
                [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagThird];
            }
            
            if (hasBreakAccess && !hasActivityAccess)
            {
                [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagThird];
            }
            else if(hasBreakAccess){
                [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagFour];
            }
            
            [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#b6c1c8" alpha:1]];
        }
        
        UIView *segmentSectionView=[[UIView alloc]initWithFrame:CGRectMake(0, y, self.view.frame.size.width, 50)];
        //Fix for ios7//JUHI
        if (version>=7.0)
        {
            [segmentSectionView setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1]];
        }
        else{
            [segmentSectionView setBackgroundColor:[Util colorWithHex:@"#b6c1c8" alpha:1]];
        }
        
        UIImage *separtorImage=[Util thumbnailImage:TOP_SEPARATOR];
        
        UIImageView *separatorView=[[UIImageView alloc]initWithFrame:CGRectMake(0,hSegment, self.view.frame.size.width, separtorImage.size.height)];
        [separatorView setImage:separtorImage];
        [self.containerview addSubview:separatorView];
        
        
         [self setTextColorsForSegmentedControl:self.segmentedCtrl];
        
        [segmentSectionView addSubview:self.segmentedCtrl];
        [self.containerview addSubview:segmentSectionView];
        
        [self changeUISegmentFont:self.segmentedCtrl];
        y=segmentSectionView.frame.origin.y+segmentSectionView.frame.size.height;
        
    }
    
    
    
    
    
    
    
    
    
    UIView *tmpHeaderView=[[UIView alloc]initWithFrame:CGRectMake(5, y, SCREEN_WIDTH-10, 68)];
    UIView *view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, tmpHeaderView.frame.size.width, 68)];
    UIImage *img;
    NSString *imgLabelText=@"";
    if (screenMode==ADD_PUNCH_ENTRY)
    {
        if (setViewTag==Break_Tag)
        {
            img=[UIImage imageNamed:@"icon_Break-Tag-Yellow"];
        }
        else if (setViewTag==Out_Tag)
        {
            img=[UIImage imageNamed:@"icon_OUT-Tag-Gray"];
            imgLabelText=RPLocalizedString(OUT_TEXT, OUT_TEXT);
        }
        else
        {
            img=[UIImage imageNamed:@"icon_IN-Tag-Green"];
            imgLabelText=RPLocalizedString(IN_TEXT, IN_TEXT);
        }
    }
    if (screenMode==EDIT_PUNCH_ENTRY||screenMode==VIEW_PUNCH_ENTRY)
    {
        if (punchObj.breakUri!=nil && ![punchObj.breakUri isKindOfClass:[NSNull class]]&& ![punchObj.breakUri isEqualToString:@""] && ![BtnClicked isEqualToString:@"Out"])
        {
            img=[UIImage imageNamed:@"icon_Break-Tag-Yellow"];
        }
        else{
            if ([BtnClicked isEqualToString:@"In"])
            {
                img=[UIImage imageNamed:@"icon_IN-Tag-Green"];
                imgLabelText=RPLocalizedString(IN_TEXT, IN_TEXT);
            }
            else if ([BtnClicked isEqualToString:@"Out"])
            {
                img=[UIImage imageNamed:@"icon_OUT-Tag-Gray"];
                imgLabelText=RPLocalizedString(OUT_TEXT, OUT_TEXT);
            }
            else
            {
                img=[UIImage imageNamed:@"icon_IN-Tag-Green"];
                imgLabelText=RPLocalizedString(IN_TEXT, IN_TEXT);
            }
            
        }
    }
    
    UIImageView *entryImageView=[[UIImageView alloc]initWithImage:img];
    
    entryImageView.frame=CGRectMake(10, 35, img.size.width, img.size.height);
    self.selectedSegmentImageview=entryImageView;
    [view addSubview:entryImageView];
    
    
    self.imgLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
    self.imgLabel.backgroundColor=[UIColor clearColor];
    if ([imgLabelText isEqualToString:RPLocalizedString(IN_TEXT, IN_TEXT)])
    {
        self.imgLabel.textColor=[UIColor whiteColor];
    }
    else
    {
        self.imgLabel.textColor=[UIColor blackColor];
    }
    self.imgLabel.textAlignment=NSTextAlignmentCenter;
    self.imgLabel.text=imgLabelText;
    [self.imgLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:9.0]];
    [entryImageView addSubview:self.imgLabel];
    
    
    
    UILabel *segmentLb=[[UILabel alloc]initWithFrame:CGRectMake(img.size.width+20, 35, 200, img.size.height)];
    
    segmentLb.backgroundColor = [UIColor clearColor ];
    segmentLb.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16];
    segmentLb.textAlignment = NSTextAlignmentLeft;
    NSString *timeStr=nil;
    segmentLb.text=nil;
    if (screenMode==ADD_PUNCH_ENTRY)
    {
        if (setViewTag==Break_Tag)
        {
           segmentLb.text=RPLocalizedString(BREAK_TITLE, @"");
        }
        else if (setViewTag==Out_Tag)
        {
             segmentLb.text=RPLocalizedString(CLOCKED_OUT, @"");
        }
        else if (setViewTag==Transfer_Tag)
            segmentLb.text=RPLocalizedString(Transfer, @"");
        else
            segmentLb.text=RPLocalizedString(CLOCKED_IN, @"");
    }
    else
    {//Implemetation for Punch-229//JUHI
        if (punchObj.breakUri!=nil && ![punchObj.breakUri isKindOfClass:[NSNull class]] && ![punchObj.breakUri isEqualToString:@""]  && ![BtnClicked isEqualToString:@"Out"])
        {
            if ([BtnClicked isEqualToString:@"In"])
            {
                
                segmentLb.text=RPLocalizedString(BREAK_TITLE, @"");
                
                
            }
            else if ([BtnClicked isEqualToString:@"Out"])
            {
                if ([punchObj.punchOutActionUri isEqualToString:PUNCH_TRANSFER_URI])
                {
                    segmentLb.text=RPLocalizedString(TRANSFERRED_OUT, @"");
                }
                else
                {
                    segmentLb.text=RPLocalizedString(BREAK_OUT_TITLE, @"");
                }
                
            }
            
        }
        else if (punchObj.activityUri!=nil && ![punchObj.activityUri isKindOfClass:[NSNull class]]&& ![punchObj.activityUri isEqualToString:@""])
        {
            if ([BtnClicked isEqualToString:@"In"])
            {
                
                if ([punchObj.punchInActionUri isEqualToString:PUNCH_IN_URI])
                {
                    segmentLb.text=RPLocalizedString(CLOCKED_IN, @"");
                }
                else if ([punchObj.punchInActionUri isEqualToString:PUNCH_TRANSFER_URI])
                {
                    segmentLb.text=RPLocalizedString(TRANSFERRED_IN, @"");
                }
                else
                {
                    segmentLb.text=RPLocalizedString(CLOCKED_IN, @"");
                }
                
                
            }
            else if ([BtnClicked isEqualToString:@"Out"])
            {
                if ([punchObj.punchOutActionUri isEqualToString:PUNCH_OUT_URI])
                {
                    segmentLb.text=RPLocalizedString(CLOCKED_OUT, @"");
                }
                else if ([punchObj.punchOutActionUri isEqualToString:PUNCH_TRANSFER_URI])
                {
                    segmentLb.text=RPLocalizedString(TRANSFERRED_OUT, @"");
                }
                else if ([punchObj.punchOutActionUri isEqualToString:PUNCH_START_BREAK_URI])
                {
                    segmentLb.text=RPLocalizedString(TRANSFERRED_OUT, @"");
                }
                else
                {
                    segmentLb.text=RPLocalizedString(CLOCKED_OUT, @"");
                }
                
            }
        }
        
        
        else{
            if ([BtnClicked isEqualToString:@"In"])
            {
                
                segmentLb.text=RPLocalizedString(CLOCKED_IN, @"");
            }
            else if ([BtnClicked isEqualToString:@"Out"])
            {
                
                segmentLb.text=RPLocalizedString(CLOCKED_OUT, @"");
            }
        }
    }
    
    if (screenMode==ADD_PUNCH_ENTRY)
    {
//        if (setViewTag==In_Tag||setViewTag==Transfer_Tag||setViewTag==Break_Tag)
//        {
            NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
            NSLocale *twelveHourLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            myDateFormatter.locale = twelveHourLocale;
            NSDate *date=[NSDate date];
            [myDateFormatter setDateFormat:@"hh:mm a"];
            NSString *selectedDateString=[myDateFormatter stringFromDate:date];
            
            NSString *currentDateStr=[NSString stringWithFormat:@"%@ %@",currentPageDate,selectedDateString];
        
            [myDateFormatter setDateFormat:@"EEE, MMM dd, yyyy hh:mm a"];
            NSDate *currentDate=[myDateFormatter dateFromString:currentDateStr];
            
            if (currentDate==nil)
            {
                NSLocale *locale=[NSLocale currentLocale];
                myDateFormatter.locale =locale;
                currentDate=[myDateFormatter dateFromString:currentDateStr];
                
            }
       
//         if (setViewTag==Out_Tag){
            punchObj.PunchOutDateTimestamp=[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:[currentDate timeIntervalSince1970]]];
            
            punchObj.PunchOutTime=selectedDateString;
            timeStr=punchObj.PunchOutTime;
//        }
        
//         else
//         {
             punchObj.PunchInDateTimestamp=[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:[currentDate timeIntervalSince1970]]];
             
             punchObj.PunchInTime=selectedDateString;
             timeStr=punchObj.PunchInTime;
//         }
        
//        }
//        else if (setViewTag==Out_Tag){
//            NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
//            NSLocale *twelveHourLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
//            myDateFormatter.locale = twelveHourLocale;
//            NSDate *date=[NSDate date];
//            [myDateFormatter setDateFormat:@"hh:mm a"];
//            NSString *selectedDateString=[myDateFormatter stringFromDate:date];
//            
//            NSString *currentDateStr=[NSString stringWithFormat:@"%@ %@",currentPageDate,selectedDateString];
//            
//           
//            [myDateFormatter setDateFormat:@"EEE, MMM dd, yyyy hh:mm a"];
//            NSDate *currentDate=[myDateFormatter dateFromString:currentDateStr];
//            
//            if (currentDate==nil)
//            {
//                NSLocale *locale=[NSLocale currentLocale];
//                myDateFormatter.locale =locale;
//                currentDate=[myDateFormatter dateFromString:currentDateStr];
//                
//            }
//
//            
//            punchObj.PunchOutDateTimestamp=[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:[currentDate timeIntervalSince1970]]];
//            
//            punchObj.PunchOutTime=selectedDateString;
//            timeStr=punchObj.PunchOutTime;
//        }

        
        
//        timeStr=@"0.00";
    }
    else {
        if ([BtnClicked isEqualToString:@"In"])
        {
            timeStr=punchObj.PunchInTime;
             NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
            NSLocale *twelveHourLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            myDateFormatter.locale = twelveHourLocale;
//            NSLocale *locale=[NSLocale currentLocale];
//            myDateFormatter.locale =locale;
            [myDateFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
            NSDate *localDate=[myDateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",punchObj.PunchInDate,punchObj.PunchInTime]];
            
            if (localDate==nil)
            {
                NSLocale *locale=[NSLocale currentLocale];
                myDateFormatter.locale =locale;
                localDate=[myDateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",punchObj.PunchInDate,punchObj.PunchInTime]];
                
            }
            
            punchObj.PunchInDateTimestamp=[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:[localDate timeIntervalSince1970]]];
        }
        else if ([BtnClicked isEqualToString:@"Out"])
        {
            timeStr=punchObj.PunchOutTime;
             NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
            NSLocale *twelveHourLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            myDateFormatter.locale = twelveHourLocale;
//            NSLocale *locale=[NSLocale currentLocale];
//            myDateFormatter.locale =locale;
            [myDateFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
            NSDate *localDate=[myDateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",punchObj.PunchOutDate,punchObj.PunchOutTime]];
            if (localDate==nil)
            {
                NSLocale *locale=[NSLocale currentLocale];
                myDateFormatter.locale =locale;
                localDate=[myDateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",punchObj.PunchOutDate,punchObj.PunchOutTime]];
                
            }
            punchObj.PunchOutDateTimestamp=[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:[localDate timeIntervalSince1970]]];
        }
    }

    UIFont *font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16];
    CGRect frame = segmentLb.frame;
    frame.size.height =  [Util getHeightForString:segmentLb.text font:font forWidth:frame.size.width forHeight:1000].height;
    segmentLb.frame = frame;
    self.selectedSegmentLabel=segmentLb;
    [view addSubview:segmentLb];
    
    BOOL isInTimePM = NO;
    
    NSDictionary *startTimeDict=[Util getOnlyTimeFromStringWithAMPMString:timeStr];
    if ([[[startTimeDict objectForKey:@"FORMAT"] lowercaseString] isEqualToString:@"pm"])
    {
        isInTimePM=YES;
    }
    
    UIButton *dummyButton=[UIButton buttonWithType:UIButtonTypeCustom];
    self.timeBtn=dummyButton;
    [dummyButton setBackgroundColor:[UIColor whiteColor]];
    UILabel *tempamPmLb=[[UILabel alloc] init];
    self.amPmLb=tempamPmLb;
    self.amPmLb.frame=CGRectMake(75, 10, 50, 20);
    self.amPmLb.textColor=[Util colorWithHex:@"#333333" alpha:1];
    self.amPmLb.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_08];
//    if (screenMode==EDIT_PUNCH_ENTRY)
//    {
        [dummyButton setTitle:[startTimeDict objectForKey:@"TIME"] forState:UIControlStateNormal];
       
        
        
        self.amPmLb.text= isInTimePM ? @"PM" : @"AM";
        
       
//    }
//    else
//        [dummyButton setTitle:timeStr forState:UIControlStateNormal];
    
    [dummyButton setTitleColor:[Util colorWithHex:@"#333333" alpha:1] forState:UIControlStateNormal];
    [dummyButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
    [dummyButton addTarget:self action:@selector(editTimeEntry:) forControlEvents:UIControlEventTouchUpInside];
    [dummyButton setFrame:CGRectMake((SCREEN_WIDTH-105)-17,20,105,48)];
    dummyButton.layer.cornerRadius=0.0f;
    dummyButton.layer.masksToBounds=YES;
    dummyButton.layer.borderColor=[[UIColor grayColor]CGColor];
    dummyButton.layer.borderWidth= 0.3f;
    if (screenMode==VIEW_PUNCH_ENTRY)
    {
        [dummyButton setUserInteractionEnabled:NO];
    }
    
     [dummyButton addSubview:self.amPmLb];
    [view addSubview:dummyButton];
    
    
    
    
    [tmpHeaderView addSubview:view];
    [self.containerview addSubview:tmpHeaderView];
    
    UIView *separatorViewBottom=[[UIView alloc]initWithFrame:CGRectMake(0, y+68, SCREEN_WIDTH, 1)];
    [separatorViewBottom setBackgroundColor:[Util colorWithHex:@"#D6D6D6" alpha:1]];
    //[self.view addSubview:separatorViewBottom];
    
    y=y+68;
    
    //Implementation for Punch-229//JUHI
    UIButton *tempDateBtn=[UIButton buttonWithType:UIButtonTypeCustom];
   
    tempDateBtn.frame=CGRectMake(12, y, SCREEN_WIDTH - 24, 44);
    tempDateBtn.backgroundColor=[UIColor whiteColor];
    tempDateBtn.layer.cornerRadius=0.0f;
    tempDateBtn.layer.masksToBounds=YES;
    tempDateBtn.layer.borderColor=[[UIColor grayColor]CGColor];
    tempDateBtn.layer.borderWidth= 0.3f;
    
    if (screenMode==ADD_PUNCH_ENTRY)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        NSLocale *locale=[NSLocale currentLocale];
        [dateFormatter setLocale:locale];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter setDateFormat:@"EEE, MMM dd, yyyy"];
        NSDate *punchDate=[dateFormatter dateFromString:currentPageDate];
        
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *punchDateStr=[dateFormatter stringFromDate:punchDate];
         punchObj.PunchInDate =punchDateStr;
        NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *twelveHourLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        myDateFormatter.locale = twelveHourLocale;
        
        [myDateFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
        NSDate *localDate=[myDateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",punchObj.PunchInDate,punchObj.PunchInTime]];
        
        if (localDate==nil)
        {
            NSLocale *locale=[NSLocale currentLocale];
            dateFormatter.locale =locale;
            localDate=[dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",punchObj.PunchInDate,punchObj.PunchInTime]];
            
        }
        
        punchObj.PunchInDateTimestamp=[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:[localDate timeIntervalSince1970]]];
        
        punchObj.PunchOutDate =punchDateStr;
        NSString *localoutstr=[NSString stringWithFormat:@"%@ %@",punchObj.PunchOutDate,punchObj.PunchOutTime];
        NSDate *localOutDate=[myDateFormatter dateFromString:localoutstr];
        if (localOutDate==nil)
        {
            NSLocale *locale=[NSLocale currentLocale];
            dateFormatter.locale =locale;
            localOutDate=[dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",punchObj.PunchOutDate,punchObj.PunchOutTime]];
            
        }
        punchObj.PunchOutDateTimestamp=[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:[localOutDate timeIntervalSince1970]]];
        
        
    }
    else{
        if ([BtnClicked isEqualToString:@"In"])
        {
            timeStr=punchObj.PunchInTime;
            NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
            NSLocale *twelveHourLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            myDateFormatter.locale = twelveHourLocale;
            
            [myDateFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
            NSDate *localDate=[myDateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",punchObj.PunchInDate,punchObj.PunchInTime]];
            
            if (localDate==nil)
            {
                NSLocale *locale=[NSLocale currentLocale];
                myDateFormatter.locale =locale;
                localDate=[myDateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",punchObj.PunchInDate,punchObj.PunchInTime]];
                
            }
            
            punchObj.PunchInDateTimestamp=[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:[localDate timeIntervalSince1970]]];
        }
        else if ([BtnClicked isEqualToString:@"Out"])
        {
            timeStr=punchObj.PunchOutTime;
            NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
            NSLocale *twelveHourLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            myDateFormatter.locale = twelveHourLocale;
            
            [myDateFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
            NSDate *localDate=[myDateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",punchObj.PunchOutDate,punchObj.PunchOutTime]];
            if (localDate==nil)
            {
                NSLocale *locale=[NSLocale currentLocale];
                myDateFormatter.locale =locale;
                localDate=[myDateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",punchObj.PunchOutDate,punchObj.PunchOutTime]];
                
            }
            punchObj.PunchOutDateTimestamp=[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:[localDate timeIntervalSince1970]]];
        }
    }
    
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    
    NSLocale *locale=[NSLocale currentLocale];
    [myDateFormatter setLocale:locale];
    [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [myDateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *punchDate=nil;
    
    if ([BtnClicked isEqualToString:@"In"] || BtnClicked==nil)
    {
        punchDate=[myDateFormatter dateFromString:punchObj.PunchInDate];
    }
    else if ([BtnClicked isEqualToString:@"Out"])
    {
        punchDate=[myDateFormatter dateFromString:punchObj.PunchOutDate];
    }
    
    [myDateFormatter setDateFormat:@"EEE, MMM dd, yyyy"];
    NSString *punchDateStr=[myDateFormatter stringFromDate:punchDate];
    
    UILabel *tempdateBtnLabel = [[UILabel alloc] init];
    self.dateBtn=tempdateBtnLabel;
    self.dateBtn.text=[NSString stringWithFormat:@"  %@",punchDateStr];
    self.dateBtn.frame=CGRectMake(0, 0, 265, 44);
    self.dateBtn.backgroundColor = [UIColor whiteColor];
    self.dateBtn.textColor = RepliconStandardBlackColor;
    self.dateBtn.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14];
    self.dateBtn.textAlignment = NSTextAlignmentLeft;
    
    [tempDateBtn addSubview:dateBtn];
  
    if (screenMode!=VIEW_PUNCH_ENTRY)
    {
        [tempDateBtn addTarget:self action:@selector(dateAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.containerview addSubview:tempDateBtn];
    
    y=y+44;
    
    UIButton *selectionBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    selectionBtn.frame=CGRectMake(12, y, SCREEN_WIDTH-24, 58);
    selectionBtn.backgroundColor=[UIColor whiteColor];
    self.selectedSegmentBtn=selectionBtn;
    
    UIImage *disclosureImage = [UIImage imageNamed:Disclosure_Box];
    UIImage *disclosureHighlightedImage = [Util thumbnailImage:Disclosure_Highlighted_Box];

    
    UILabel *tempactivityLabel = [[UILabel alloc] init];
    self.activityLabel=tempactivityLabel;
   
    self.activityLabel.frame=CGRectMake(0, 0, selectionBtn.frame.size.width - disclosureImage.size.width - 15, 58);
    self.activityLabel.backgroundColor = [UIColor whiteColor];
    self.activityLabel.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14];
    self.activityLabel.textAlignment = NSTextAlignmentLeft;
    selectionBtn.layer.cornerRadius=0.0f;
    selectionBtn.layer.masksToBounds=YES;
    selectionBtn.layer.borderColor=[[UIColor grayColor]CGColor];
    selectionBtn.layer.borderWidth= 0.3f;
    if ((screenMode==EDIT_PUNCH_ENTRY && [BtnClicked isEqualToString:@"Out"]) || setViewTag==Out_Tag)
    {
        selectionBtn.hidden=YES;
    }
    else
        selectionBtn.hidden=NO;
    if (screenMode!=VIEW_PUNCH_ENTRY)
    {
        [selectionBtn addTarget:self action:@selector(selectionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    if (screenMode==ADD_PUNCH_ENTRY)
    {
        if (setViewTag==Break_Tag)
        {
            if (punchObj.breakUri!=nil && ![punchObj.breakUri isKindOfClass:[NSNull class]] && ![punchObj.breakUri isEqualToString:@""]){
                self.activityLabel.text=[NSString stringWithFormat:@"  %@",punchObj.breakName] ;
            }
            else
                self.activityLabel.text=[NSString stringWithFormat:@"  %@",RPLocalizedString(SELECT_BREAK, @"")] ;
            
            if (!hasBreakAccess)
            {
                selectionBtn.hidden=YES;
            }
        }
        else{
            if (punchObj.activityUri!=nil && ![punchObj.activityUri isKindOfClass:[NSNull class]]&& ![punchObj.activityUri isEqualToString:@""])
            {
                self.self.activityLabel.text=[NSString stringWithFormat:@"  %@",punchObj.activityName];
            }
            else{
                if (screenMode==ADD_PUNCH_ENTRY||screenMode==EDIT_PUNCH_ENTRY)
                {
                    self.activityLabel.text=[NSString stringWithFormat:@"  %@",RPLocalizedString(SELECT_ACTIVITY, @"")];
                }
                else
                {
                    self.activityLabel.text=[NSString stringWithFormat:@"  %@",RPLocalizedString(NONE_STRING, @"")];
                }
                
            }
            
            if (!hasActivityAccess)
            {
                selectionBtn.hidden=YES;
            }
        }
        
        
    }
    else
    {
        if (punchObj.breakUri!=nil && ![punchObj.breakUri isKindOfClass:[NSNull class]] && ![punchObj.breakUri isEqualToString:@""]) {
            self.activityLabel.text=[NSString stringWithFormat:@"  %@",punchObj.breakName];
            
            if (!hasBreakAccess)
            {
                selectionBtn.userInteractionEnabled=NO;
                selectionBtn.hidden=YES;
                punchObj.breakUri=nil;
                punchObj.breakName=nil;
            }
        }
        else if (punchObj.activityUri!=nil && ![punchObj.activityUri isKindOfClass:[NSNull class]]&& ![punchObj.activityUri isEqualToString:@""])
        {
            self.self.activityLabel.text=[NSString stringWithFormat:@"  %@",punchObj.activityName];
            
            if (!hasActivityAccess)
            {
                selectionBtn.userInteractionEnabled=NO;
                //selectionBtn.hidden=YES;
                punchObj.activityUri=nil;
                punchObj.activityName=nil;
            }
            
        }
        else{
            
            if (screenMode==ADD_PUNCH_ENTRY||screenMode==EDIT_PUNCH_ENTRY)
            {
                self.activityLabel.text=[NSString stringWithFormat:@"  %@",RPLocalizedString(SELECT_ACTIVITY, @"")];
            }
            else
            {
                self.activityLabel.text=[NSString stringWithFormat:@"  %@",RPLocalizedString(NONE_STRING, @"")];
            }
            if (!hasActivityAccess)
            {
                selectionBtn.userInteractionEnabled=NO;
                selectionBtn.hidden=YES;
                punchObj.activityUri=nil;
                punchObj.activityName=nil;
            }
        }
    }

    
    
    [selectionBtn addSubview:self.activityLabel];
    
    UIImageView *disclosureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(selectionBtn.frame.size.width - disclosureImage.size.width - 10, 25, disclosureImage.size.width,disclosureImage.size.height)];
    self.discloserImageview=disclosureImageView;
	[disclosureImageView setImage:disclosureImage];
    [disclosureImageView setHighlightedImage:disclosureHighlightedImage];
    if (screenMode!=VIEW_PUNCH_ENTRY)
    {
        [selectionBtn addSubview:discloserImageview];
    }
    
    
    if (!selectionBtn.userInteractionEnabled)
    {
        discloserImageview.hidden=YES;
        
    }
    
   [self.containerview addSubview:selectionBtn];
    float x=5;
    
    if (screenMode==EDIT_PUNCH_ENTRY||screenMode==VIEW_PUNCH_ENTRY)
    {
       
        if ((screenMode==EDIT_PUNCH_ENTRY && [BtnClicked isEqualToString:@"Out"]) || setViewTag==Out_Tag)
        {
            selectionBtn.hidden=YES;
        }
        else{
            //selectionBtn.hidden=NO;
            if (!selectionBtn.hidden)
            {
                 y=y+58;
            }
            
        }
        UIView *locationView = [[UIView alloc] init];
        locationView.frame=CGRectMake(12, y, SCREEN_WIDTH-24, 68);
        locationView.backgroundColor = [UIColor whiteColor];
        
        locationView.layer.cornerRadius=0.0f;
        locationView.layer.masksToBounds=YES;
        locationView.layer.borderColor=[[UIColor grayColor]CGColor];
        locationView.layer.borderWidth= 0.3f;
        NSString *inPunchImagePath=punchObj.punchInFullSizeImageLink;
        NSString *outPunchImagePath=punchObj.punchOutFullSizeImageLink;
        
       UIImageView *templocationImage=[[UIImageView alloc]initWithFrame:CGRectMake(x, 8, 50, 50)];
         self.locationImage=templocationImage;
        [locationView addSubview:self.locationImage];
        
        if ((inPunchImagePath!=nil&& ![inPunchImagePath isKindOfClass:[NSNull class]] && [BtnClicked isEqualToString:@"In"])||(outPunchImagePath!=nil&& ![outPunchImagePath isKindOfClass:[NSNull class]] && [BtnClicked isEqualToString:@"Out"] ))
        {
            
            __weak PunchEntryViewController *weakCell = self;
            
            if ([BtnClicked isEqualToString:@"In"])
            {
                [ self.locationImage setImageWithURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:inPunchImagePath]]
                                           placeholderImage:[UIImage imageNamed:@"bg_punchImagePlaceholder"]
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
                                                        weakCell.locationImage.image = image;
                                                    }
                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                                                        
                                                    }];
            }
            else if ([BtnClicked isEqualToString:@"Out"])
            {
                [ self.locationImage setImageWithURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:outPunchImagePath]]
                                           placeholderImage:[UIImage imageNamed:@"bg_punchImagePlaceholder"]
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
                                                        weakCell.locationImage.image = image;
                                                    }
                                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
                                                        
                                                    }];
            }

            
        }
        
        else
        {
            [self.locationImage setImage:[Util thumbnailImage:PlaceHolder_No_Image]];
           // x=x+2;
        }
        
        x=70;
        int locationYOrigin=44.0;
        int locationWidth = locationView.frame.size.width-x-10;
        UILabel *locationLb=[[UILabel alloc]initWithFrame:CGRectMake(x, 8 , locationWidth, 50)];
        
        locationLb.backgroundColor = [UIColor clearColor];
        locationLb.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14];
        locationLb.textAlignment = NSTextAlignmentLeft;
        //locationLb.numberOfLines=5;
        BOOL locationAvailable=NO;
        if ([BtnClicked isEqualToString:@"In"])
        {
            if (punchObj.PunchInAddress!=nil && ![punchObj.PunchInAddress isKindOfClass:[NSNull class]]) {
                
                
                
                // Let's make an NSAttributedString first
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:punchObj.PunchInAddress];
                //Add LineBreakMode
                NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
                [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
                [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
                // Add Font
                [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:RepliconFontSize_14]} range:NSMakeRange(0, attributedString.length)];
                
                //Now let's make the Bounding Rect
                CGSize size  = [attributedString boundingRectWithSize:CGSizeMake(locationWidth, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
                
                if (size.height < 20.0)
                {
                    locationLb.numberOfLines=1;
                    locationLb.frame=CGRectMake(x, 20 , locationWidth, 18);
                }
                else
                {
                     locationLb.frame=CGRectMake(x, 5 , size.width, size.height);
                    locationYOrigin=size.height +10.0;
                     locationLb.numberOfLines=100;
                    
                }

               
                locationAvailable=YES;
                locationLb.text=punchObj.PunchInAddress;
                
                
            }
            else
            {
                locationLb.numberOfLines=1;
                locationLb.frame=CGRectMake(x, 20 , locationWidth, 18);
                locationLb.text=RPLocalizedString(LOCATION_UNAVAILABLE_STRING, LOCATION_UNAVAILABLE_STRING);
            }
            
        }
        else if ([BtnClicked isEqualToString:@"Out"])
        {
            if (punchObj.PunchOutAddress!=nil && ![punchObj.PunchOutAddress isKindOfClass:[NSNull class]]) {
                
               
                
                // Let's make an NSAttributedString first
                NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:punchObj.PunchOutAddress];
                //Add LineBreakMode
                NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
                [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
                [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
                // Add Font
                [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:RepliconFontSize_14]} range:NSMakeRange(0, attributedString.length)];
                
                //Now let's make the Bounding Rect
                CGSize size  = [attributedString boundingRectWithSize:CGSizeMake(locationWidth, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
                
                if (size.height < 20.0)
                {
                    locationLb.numberOfLines=1;
                    locationLb.frame=CGRectMake(x, 20 , locationWidth, 18);
                }
                else
                {
                    locationLb.frame=CGRectMake(x, 5 , size.width, size.height);
                    locationYOrigin=size.height +10.0;
                    locationLb.numberOfLines=100;
                    
                }
                
                locationAvailable=YES;
                locationLb.text=punchObj.PunchOutAddress;
                
               
            }
            else
            {
                locationLb.numberOfLines=1;
                locationLb.frame=CGRectMake(x, 20 , locationWidth, 18);
                locationLb.text=RPLocalizedString(LOCATION_UNAVAILABLE_STRING, LOCATION_UNAVAILABLE_STRING);
            }
            
        }
        [locationView addSubview:locationLb];
        
        NSString *agent=nil;
        
        if ([BtnClicked isEqualToString:@"In"])
        {
            if (punchObj.punchInAgent!=nil && ![punchObj.punchInAgent isKindOfClass:[NSNull class]])
            {
                agent=[NSString stringWithFormat:@" via %@",punchObj.punchInAgent];
            }
            
            
        }
        else if ([BtnClicked isEqualToString:@"Out"])
        {
            if (punchObj.punchOutAgent!=nil && ![punchObj.punchOutAgent isKindOfClass:[NSNull class]])
            {
                agent=[NSString stringWithFormat:@" via %@",punchObj.punchOutAgent];
            }
            
        }
        
        
        if (agent!=nil && ![agent isKindOfClass:[NSNull class]])
        {
            UIImageView *agentImgview=[[UIImageView alloc]initWithFrame:CGRectMake(x, locationYOrigin, 8, 12)];
            agentImgview.backgroundColor=[UIColor clearColor];
            if ([agent isEqualToString:@" via Mobile"])
            {
                agentImgview.image=[Util thumbnailImage:VIA_MOBILE_ICON];
            }
            else
            {
                agentImgview.frame=CGRectMake(x, locationYOrigin, 11, 12);
                agentImgview.image=[Util thumbnailImage:VIA_CC_ICON];
            }
            
            [locationView addSubview:agentImgview];
            
            x=x+agentImgview.frame.size.width+5.0;
            
            UILabel *agentLb=[[UILabel alloc]initWithFrame:CGRectMake(x, locationYOrigin-4, locationView.frame.size.width - x - 10, 20)];
            agentLb.backgroundColor = [UIColor clearColor];
            agentLb.font = [UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_12];
            agentLb.textColor=[UIColor lightGrayColor];
            agentLb.textAlignment = NSTextAlignmentLeft;
            agentLb.text=agent;
            [locationView addSubview:agentLb];
        }
        
       
        CGRect frame=locationView.frame;
        frame.size.height=locationYOrigin+20.0;
        locationView.frame=frame;
        
        [self.containerview addSubview:locationView];
        
        y=y+locationView.frame.size.height;
        
        BOOL isManaulEditPunch=NO;
        if ([BtnClicked isEqualToString:@"In"])
        {
            if (punchObj.isInManualEditPunch) {
                isManaulEditPunch=YES;
            }
        }
        else if ([BtnClicked isEqualToString:@"Out"])
        {
            if (punchObj.isOutManualEditPunch) {
                isManaulEditPunch=YES;
            }
        }
        
        
        UIButton *auditTrialButton=[UIButton buttonWithType:UIButtonTypeCustom];
        auditTrialButton.frame=CGRectMake(12,y+10,SCREEN_WIDTH-24, 44);
        auditTrialButton.backgroundColor=[UIColor whiteColor];
        UILabel *auditTrialLabel = [[UILabel alloc] init];
        auditTrialLabel.frame=CGRectMake(12, 0, 265, 44);
        auditTrialLabel.backgroundColor = [UIColor whiteColor];
        auditTrialLabel.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14];
        auditTrialLabel.text=RPLocalizedString(AuditTrialTitle, @"");
        auditTrialLabel.textAlignment = NSTextAlignmentLeft;
        auditTrialButton.layer.cornerRadius=0.0f;
        auditTrialButton.layer.masksToBounds=YES;
        auditTrialButton.layer.borderColor=[[UIColor grayColor]CGColor];
        auditTrialButton.layer.borderWidth= 0.3f;
        [auditTrialButton addSubview:auditTrialLabel];
        [self.containerview addSubview:auditTrialButton];
        [auditTrialButton addTarget:self action:@selector(auditTrialButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        if (isManaulEditPunch)
        {
            UIImage *disclosureImage = [Util thumbnailImage:ManualEditPunchIndicatorImage];
            UIImage *disclosureHighlightedImage = [Util thumbnailImage:ManualEditPunchIndicatorImage];
            UIImageView *disclosureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(auditTrialButton.frame.size.width - disclosureImage.size.width, 0,10,10)];
            [disclosureImageView setImage:disclosureImage];
            [disclosureImageView setHighlightedImage:disclosureHighlightedImage];
            [auditTrialButton addSubview:disclosureImageView];
        }
        UIImage *disclosureImage = [UIImage imageNamed:Disclosure_Box];
        UIImage *disclosureHighlightedImage = [Util thumbnailImage:Disclosure_Highlighted_Box];
        UIImageView *disclosureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(auditTrialButton.frame.size.width - disclosureImage.size.width - 10, 16, disclosureImage.size.width,disclosureImage.size.height)];
        [disclosureImageView setImage:disclosureImage];
        [disclosureImageView setHighlightedImage:disclosureHighlightedImage];
        [auditTrialButton addSubview:disclosureImageView];
        
        
        UIImage *deleteBtnImg =[Util thumbnailImage:DeleteTimesheetButtonImage] ;
        UIImage *deletePressedBtnImg =[Util thumbnailImage:DeleteTimesheetPressedButtonImage] ;
        UIButton *tmpdeleteButton =[UIButton buttonWithType:UIButtonTypeCustom];
        self.deleteButton=tmpdeleteButton;
        float deleteOffset=0;
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        float aspectRatio=screenBounds.size.height/screenBounds.size.width;
        if (aspectRatio>1.5)
        {
            deleteOffset=60;
        }
        else
        {
            if (locationAvailable)
            {
                deleteOffset=20;
            }
            else{
                deleteOffset=60;
            }
           
        }
        [deleteButton setFrame:CGRectMake((SCREEN_WIDTH-deleteBtnImg.size.width)/2,auditTrialButton.frame.origin.y+auditTrialButton.frame.size.height+deleteOffset,deleteBtnImg.size.width, deleteBtnImg.size.height)];
        
        
        [deleteButton setBackgroundImage:deleteBtnImg forState:UIControlStateNormal];
        [deleteButton setBackgroundImage:deletePressedBtnImg forState:UIControlStateHighlighted];
        [deleteButton setTitle:RPLocalizedString(Delete_Button_title, @"")  forState:UIControlStateNormal];
        [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        deleteButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [deleteButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
        if (screenMode==VIEW_PUNCH_ENTRY)
        {
            [deleteButton setUserInteractionEnabled:NO];
            [deleteButton setHidden:YES];
        }
        [self.containerview addSubview:deleteButton];
        
        float scrollviewcontentheight = deleteButton.frame.origin.y+deleteButton.frame.size.height+50;
        self.containerview.contentSize = CGSizeMake(self.view.frame.size.width,scrollviewcontentheight+70);
    }
    
    
    
    
    
    
}

-(void)auditTrialButtonAction:(id)sender
{
    if (![NetworkMonitor isNetworkAvailableForListener:self])
    {
        [Util showOfflineAlert];
        return;
    }
    NSString *uri=@"";
    if ([BtnClicked isEqualToString:@"In"] || BtnClicked==nil)
    {
        uri=punchObj.punchInUri;
    }
    else if ([BtnClicked isEqualToString:@"Out"])
    {
        uri=punchObj.punchOutUri;
    }
    
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
    AuditTrialViewController *auditTrialVC=[[AuditTrialViewController alloc]init];
    auditTrialVC.headerDateString=[NSString stringWithFormat:@"    %@ %@",RPLocalizedString(@"On", @""),currentPageDate];
    auditTrialVC.isFromAuditHistoryForPunch=YES;
    NSString *timeString=@"";
    if ([BtnClicked isEqualToString:@"In"] || BtnClicked==nil)
    {
        timeString=punchObj.PunchInTime;
    }
    else if ([BtnClicked isEqualToString:@"Out"])
    {
        timeString=punchObj.PunchOutTime;
    }
    NSDictionary *startTimeDict=[Util getOnlyTimeFromStringWithAMPMString:timeString];
    auditTrialVC.punchTime=[startTimeDict objectForKey:@"TIME"];
    auditTrialVC.punchTimeFormat=[startTimeDict objectForKey:@"FORMAT"];
    if (punchObj.isBreakPunch)
    {
        auditTrialVC.punchActionuri=PUNCH_ACTION_URI_BREAK;
    }
    else
    {
        if ([BtnClicked isEqualToString:@"In"] || BtnClicked==nil)
        {
            auditTrialVC.punchActionuri=PUNCH_ACTION_URI_IN;
        }
        else if ([BtnClicked isEqualToString:@"Out"])
        {
            auditTrialVC.punchActionuri=PUNCH_ACTION_URI_OUT;
        }
        
        
    }
    auditTrialVC.userName=RPLocalizedString(AuditTrialTitle, AuditTrialTitle);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AUDIT_TRIAL_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:auditTrialVC selector:@selector(auditTrialDataReceivedAction:)
                                                 name:AUDIT_TRIAL_NOTIFICATION
                                               object:nil];
    [[RepliconServiceManager teamTimeService]sendRequestToGetAuditTrialDataForPunchWithUri:uri];
    [self.navigationController pushViewController:auditTrialVC animated:YES];
}
-(void)editTimeEntry:(id)sender
{
    [self punchDateDoneClicked];
    CLS_LOG(@"-----Time Entry Action on PunchEntryViewController -----");
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (datePicker!=nil)
    {
        [self doneClicked];
        datePicker=nil;
    }
    if (datePicker==nil)
    {
        UIDatePicker *tempdatePicker = [[UIDatePicker alloc] init];
        self.datePicker=tempdatePicker;
    }
    
    
    self.datePicker.backgroundColor = [UIColor whiteColor];
    self.datePicker.frame=CGRectMake(0, screenRect.size.height-210, self.view.frame.size.width, 210);
    self.datePicker.datePickerMode = UIDatePickerModeTime;
//    self.datePicker.timeZone=[NSTimeZone timeZoneForSecondsFromGMT:0];
    self.datePicker.hidden = NO;
    id fieldValue=nil;
    
//    if (screenMode==ADD_PUNCH_ENTRY)
//    {
//        if(setViewTag==In_Tag||setViewTag==Transfer_Tag||setViewTag==Break_Tag){
//            fieldValue=punchObj.PunchInTime;
//        }
//        else
//            fieldValue=punchObj.PunchOutTime;
//    }
//    else{
//        if ([BtnClicked isEqualToString:@"In"])
//        {
//            fieldValue=punchObj.PunchInTime;
//        }
//        else if ([BtnClicked isEqualToString:@"Out"])
//        {
//            fieldValue=punchObj.PunchOutTime;
//        }
//
//    }
    
    if ((screenMode==EDIT_PUNCH_ENTRY && [BtnClicked isEqualToString:@"Out"]) || setViewTag==Out_Tag)
    {
         fieldValue=punchObj.PunchOutTime;
    }
    
    else if((screenMode==EDIT_PUNCH_ENTRY && [BtnClicked isEqualToString:@"In"]) || BtnClicked==nil)
    {
        fieldValue=punchObj.PunchInTime;
    }
    
    
    NSString *dateStr=fieldValue;
    if ([fieldValue isKindOfClass:[NSString class]])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

        
        if ([dateStr isEqualToString:RPLocalizedString(SELECT, @"")]||dateStr==nil||[dateStr isKindOfClass:[NSNull class]]) {
            self.datePicker.timeZone=[NSTimeZone systemTimeZone];
            
            self.datePicker.date = [NSDate date];
            
        }
        else{
            NSLocale *twelveHourLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            dateFormatter.locale = twelveHourLocale;
            [dateFormatter setDateFormat:@"hh:mm a"];//DE10538//JUHI
            fieldValue = [dateFormatter dateFromString:dateStr];
            self.datePicker.date= fieldValue;
            NSLog(@"%@",self.datePicker.date);
        }
        
    }
    
    [self.datePicker addTarget:self
                        action:@selector(updateFieldWithPickerChange:)
              forControlEvents:UIControlEventValueChanged];

    
    if (dateStr==nil||[dateStr isKindOfClass:[NSNull class]])
    {
        self.datePicker.timeZone=[NSTimeZone systemTimeZone];
        
        self.datePicker.date = [NSDate date];
        [self updateFieldWithPickerChange:self.datePicker];
    }
    //[self.view addSubview:self.datePicker];
    AppDelegate *delegatee=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    //    delegate.rootTabBarController.tabBar.hidden=TRUE;
    [delegatee.window addSubview:self.datePicker];
    
    if (self.toolbar!=nil)
    {
        self.toolbar=nil;
    }
    UIToolbar *temptoolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, screenRect.size.height-324, self.view.frame.size.width, 50)];
    self.toolbar=temptoolbar;
    self.toolbar.barStyle = UIBarStyleBlackOpaque;
    //Implementation for US8771 HandleDateUDFEmptyValue//JUHI
    UIBarButtonItem *tempDoneButton = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString( @"Done",  @"Done") style: UIBarButtonItemStylePlain target: self action: @selector(doneClicked)];
    self.doneButton=tempDoneButton;
    
    
    
    UIBarButtonItem *tmpSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:nil
                                                                                    action:nil];
	self.spaceButton=tmpSpaceButton;
    
    

    
    //Fix for ios7//JUHI
	float version= [[UIDevice currentDevice].systemVersion newFloatValue];
    
    if (version<7.0)
    {
        [toolbar setTintColor:[UIColor clearColor]];
    }
    else
        
    {
        self.doneButton.tintColor=RepliconStandardWhiteColor;
        UIImage *backgroundImage = [Util thumbnailImage:TOOLBAR_IMAGE];
        [toolbar setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
        [toolbar setTintColor:[Util colorWithHex:@"#dddddd" alpha:1]];
        [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    }
    NSArray *toolArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
    [toolbar setItems:toolArray];
    [self.view addSubview: self.toolbar];
}
- (void)updateFieldWithPickerChange:(id)sender
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *twelveHourLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    dateFormatter.locale = twelveHourLocale;
    id fieldValue=nil;
    
//    if (screenMode==ADD_PUNCH_ENTRY)
//    {
//        if(setViewTag==In_Tag||setViewTag==Transfer_Tag||setViewTag==Break_Tag){
//            fieldValue=punchObj.PunchInTime;
//        }
//        else
//            fieldValue=punchObj.PunchOutTime;
//    }
//    else{
//        if ([BtnClicked isEqualToString:@"In"])
//        {
//            fieldValue=punchObj.PunchInTime;
//        }
//        else if ([BtnClicked isEqualToString:@"Out"])
//        {
//            fieldValue=punchObj.PunchOutTime;
//        }
//        
//    }
    
    
    if ((screenMode==EDIT_PUNCH_ENTRY && [BtnClicked isEqualToString:@"Out"]) || setViewTag==Out_Tag)
    {
        fieldValue=punchObj.PunchOutTime;
    }
    
    else if((screenMode==EDIT_PUNCH_ENTRY && [BtnClicked isEqualToString:@"In"]) || BtnClicked==nil)
    {
        fieldValue=punchObj.PunchInTime;
    }
    
    
    
  //  NSString *dateStr=fieldValue;
//    if ([dateStr isEqualToString:RPLocalizedString(SELECT, @"")]||dateStr==nil||[dateStr isKindOfClass:[NSNull class]])
//    {
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
//    }
//    else
//        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *selectedDateString=[dateFormatter stringFromDate:[sender date]];
    TeamTimePunchObject *tempPunchObj=[[TeamTimePunchObject alloc]init];
    
    tempPunchObj.PunchInAddress =punchObj.PunchInAddress;
    tempPunchObj.PunchInDate =punchObj.PunchInDate;
    
    tempPunchObj.PunchInLatitude =punchObj.PunchInLatitude;
    tempPunchObj.PunchInLongitude =punchObj.PunchInLongitude;
    
    tempPunchObj.PunchOutAddress =punchObj.PunchOutAddress;
    tempPunchObj.PunchOutDate =punchObj.PunchOutDate;
    
    tempPunchObj.PunchOutLatitude =punchObj.PunchOutLatitude;
    tempPunchObj.PunchOutLongitude =punchObj.PunchOutLongitude;
    
    tempPunchObj.activityName =punchObj.activityName;
    tempPunchObj.activityUri =punchObj.activityUri;
    tempPunchObj.punchInAgent =punchObj.punchInAgent;
    tempPunchObj.punchInFullSizeImageLink =punchObj.punchInFullSizeImageLink;
    tempPunchObj.punchInFullSizeImageUri =punchObj.punchInFullSizeImageUri;
    tempPunchObj.punchInThumbnailSizeImageLink =punchObj.punchInThumbnailSizeImageLink;
    tempPunchObj.punchInThumbnailSizeImageUri =punchObj.punchInThumbnailSizeImageUri;
    tempPunchObj.punchInUri =punchObj.punchInUri;
    tempPunchObj.punchOutAgent =punchObj.punchOutAgent;
    tempPunchObj.punchOutFullSizeImageLink =punchObj.punchOutFullSizeImageLink;
    tempPunchObj.punchOutFullSizeImageUri =punchObj.punchOutFullSizeImageUri;
    tempPunchObj.punchOutThumbnailSizeImageLink =punchObj.punchOutThumbnailSizeImageLink;
    tempPunchObj.punchOutThumbnailSizeImageUri =punchObj.punchOutThumbnailSizeImageUri;
    tempPunchObj.punchOutUri =punchObj.punchOutUri;
    tempPunchObj.punchUserName =punchObj.punchUserName;
    tempPunchObj.punchUserUri =punchObj.punchUserUri;
    tempPunchObj.totalHours =punchObj.totalHours;
    tempPunchObj.CellIdentifier=PUNCH_CELL;
    tempPunchObj.breakName=punchObj.breakName;
    tempPunchObj.breakUri=punchObj.breakUri;
    tempPunchObj.isBreakPunch=punchObj.isBreakPunch;
    
    tempPunchObj.punchInAgentUri=punchObj.punchInAgentUri;
    tempPunchObj.punchOutAgentUri=punchObj.punchOutAgentUri;
    tempPunchObj.punchInCloudClockUri=punchObj.punchInCloudClockUri;
    tempPunchObj.punchOutCloudClockUri=punchObj.punchOutCloudClockUri;
    tempPunchObj.punchInAccuracyInMeters=punchObj.punchInAccuracyInMeters;
    tempPunchObj.punchOutAccuracyInMeters=punchObj.punchOutAccuracyInMeters;
    tempPunchObj.punchInActionUri=punchObj.punchInActionUri;
    tempPunchObj.punchOutActionUri=punchObj.punchOutActionUri;
    
    
//    if (screenMode==ADD_PUNCH_ENTRY)
//    {
//        if (setViewTag==In_Tag||setViewTag==Transfer_Tag||setViewTag==Break_Tag)
//        {
//            NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
//            NSLocale *twelveHourLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
//            myDateFormatter.locale = twelveHourLocale;
////            [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
//            [myDateFormatter setDateFormat:@"EEE, MMM dd, yyyy hh:mm a"];
//            NSDate *date=[myDateFormatter dateFromString:tempcurrentPageDate];
//            tempPunchObj.PunchInDateTimestamp=[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:[date timeIntervalSince1970]]];
//            tempPunchObj.PunchInTime=selectedDateString;
//        }
//        else if (setViewTag==Out_Tag){
//            NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
//            NSLocale *twelveHourLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
//            myDateFormatter.locale = twelveHourLocale;
////            [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
//            [myDateFormatter setDateFormat:@"EEE, MMM dd, yyyy hh:mm a"];
//            NSDate *date=[myDateFormatter dateFromString:tempcurrentPageDate];
//            tempPunchObj.PunchOutDateTimestamp=[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:[date timeIntervalSince1970]]];
//            tempPunchObj.PunchOutTime=selectedDateString;
//        }
//    }
//    else{
    //Implemetation for Punch-229//JUHI
    if ((screenMode==EDIT_PUNCH_ENTRY && [BtnClicked isEqualToString:@"Out"]) || setViewTag==Out_Tag)
    {
        tempPunchObj.PunchOutTime=selectedDateString;
        NSString *tempcurrentPageDate=[NSString stringWithFormat:@"%@ %@",tempPunchObj.PunchOutDate,selectedDateString];
        NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *twelveHourLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        myDateFormatter.locale = twelveHourLocale;
        [myDateFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
        NSDate *date=[myDateFormatter dateFromString:tempcurrentPageDate];
        if (date==nil)
        {
            NSLocale *locale=[NSLocale currentLocale];
            myDateFormatter.locale =locale;
            date=[myDateFormatter dateFromString:tempcurrentPageDate];
        }
        tempPunchObj.PunchOutDateTimestamp=[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:[date timeIntervalSince1970]]];
        
    }
    
    else if((screenMode==EDIT_PUNCH_ENTRY && [BtnClicked isEqualToString:@"In"]) || BtnClicked==nil)
    {
        tempPunchObj.PunchInTime=selectedDateString;
        NSString *tempcurrentPageDate=[NSString stringWithFormat:@"%@ %@",tempPunchObj.PunchInDate,selectedDateString];
        NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *twelveHourLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        myDateFormatter.locale = twelveHourLocale;
        [myDateFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
        NSDate *date=[myDateFormatter dateFromString:tempcurrentPageDate];
        if (date==nil)
        {
            NSLocale *locale=[NSLocale currentLocale];
            myDateFormatter.locale =locale;
            date=[myDateFormatter dateFromString:tempcurrentPageDate];
        }
        tempPunchObj.PunchInDateTimestamp=[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:[date timeIntervalSince1970]]];
        
    }
    
    
   
    punchObj=tempPunchObj;
}
-(void)doneClicked
{
    CLS_LOG(@"-----Done Action on PunchEntryViewController -----");
    [self.datePicker removeFromSuperview];
    [self.toolbar removeFromSuperview];
    
    NSString *selectedDateString=nil;
//    if (screenMode==ADD_PUNCH_ENTRY)
//    {
//        if (setViewTag==In_Tag||setViewTag==Transfer_Tag||setViewTag==Break_Tag)
//        {
//            selectedDateString=punchObj.PunchInTime;
//        }
//        else if (setViewTag==Out_Tag)
//            selectedDateString= punchObj.PunchOutTime;
//    }
//    else{
//        if ([BtnClicked isEqualToString:@"In"])
//        {
//            selectedDateString=punchObj.PunchInTime;
//        }
//        else if ([BtnClicked isEqualToString:@"Out"])
//        {
//            selectedDateString= punchObj.PunchOutTime;
//        }
//    }
    
    if ((screenMode==EDIT_PUNCH_ENTRY && [BtnClicked isEqualToString:@"Out"]) || setViewTag==Out_Tag)
    {
        selectedDateString= punchObj.PunchOutTime;
    }
    
    else if((screenMode==EDIT_PUNCH_ENTRY && [BtnClicked isEqualToString:@"In"]) || BtnClicked==nil)
    {
        selectedDateString=punchObj.PunchInTime;
    }
    
    
    
    BOOL isInTimePM=NO;
    
    if (selectedDateString!=nil && ![selectedDateString isKindOfClass:[NSNull class]])
    {
        NSDictionary *startTimeDict=[Util getOnlyTimeFromStringWithAMPMString:selectedDateString];
        if ([[[startTimeDict objectForKey:@"FORMAT"] lowercaseString] isEqualToString:@"pm"])
        {
            isInTimePM=YES;
        }
        self.amPmLb.text= [startTimeDict objectForKey:@"FORMAT"];
        [self.timeBtn setTitle:[startTimeDict objectForKey:@"TIME"] forState:UIControlStateNormal];
    }
    
    
}

-(void)selectionBtnClicked:(id)sender
{
    CLS_LOG(@"-----Activity/Break Action on PunchEntryViewController -----");
    if ((screenMode==ADD_PUNCH_ENTRY && setViewTag==Break_Tag)||(punchObj.breakUri!=nil && ![punchObj.breakUri isKindOfClass:[NSNull class]]&& ![punchObj.breakUri isEqualToString:@""]&& screenMode==EDIT_PUNCH_ENTRY) )
    {
        
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
    
    else{
        SearchViewController *searchViewCtrl=[[SearchViewController alloc]init];
        
        searchViewCtrl.delegate=self;
        searchViewCtrl.selectedProject=nil;
        searchViewCtrl.entryDelegate=self;
        searchViewCtrl.selectedTimesheetUri=nil;
        searchViewCtrl.isFromLockedInOut=NO;
        searchViewCtrl.isFromAttendance=NO;
        searchViewCtrl.selectedActivityName=punchObj.activityName;
        searchViewCtrl.screenMode=ACTIVITY_SCREEN;
        searchViewCtrl.selectedItem=RPLocalizedString(ADD_ACTIVITY, @"");
        searchViewCtrl.searchProjectString=punchObj.activityName;
        searchViewCtrl.userId=punchObj.punchUserUri;
        searchViewCtrl.isPreFilledSearchString=YES;
        if (self.hasActivityAccess && !self.hasBreakAccess) {
            searchViewCtrl.isOnlyActivity=YES;
        }
        [self.navigationController pushViewController:searchViewCtrl animated:YES];
        

    }
    
    
}
-(void)updateFieldWithFieldName:(NSString*)fieldName andFieldURI:(NSString*)fieldUri
{
    activityLabel.text=[NSString stringWithFormat:@"  %@",fieldName];
    TeamTimePunchObject *tempPunchObj=[[TeamTimePunchObject alloc]init];
    
    tempPunchObj.PunchInAddress =punchObj.PunchInAddress;
    tempPunchObj.PunchInDate =punchObj.PunchInDate;
    tempPunchObj.PunchInDateTimestamp =punchObj.PunchInDateTimestamp;
    tempPunchObj.PunchInLatitude =punchObj.PunchInLatitude;
    tempPunchObj.PunchInLongitude =punchObj.PunchInLongitude;
    tempPunchObj.PunchInTime =punchObj.PunchInTime;
    tempPunchObj.PunchOutAddress =punchObj.PunchOutAddress;
    tempPunchObj.PunchOutDate =punchObj.PunchOutDate;
    tempPunchObj.PunchOutDateTimestamp =punchObj.PunchOutDateTimestamp;
    tempPunchObj.PunchOutLatitude =punchObj.PunchOutLatitude;
    tempPunchObj.PunchOutLongitude =punchObj.PunchOutLongitude;
    tempPunchObj.PunchOutTime =punchObj.PunchOutTime;
    tempPunchObj.activityName =fieldName;
    tempPunchObj.activityUri =fieldUri;
    tempPunchObj.punchInAgent =punchObj.punchInAgent;
    tempPunchObj.punchInFullSizeImageLink =punchObj.punchInFullSizeImageLink;
    tempPunchObj.punchInFullSizeImageUri =punchObj.punchInFullSizeImageUri;
    tempPunchObj.punchInThumbnailSizeImageLink =punchObj.punchInThumbnailSizeImageLink;
    tempPunchObj.punchInThumbnailSizeImageUri =punchObj.punchInThumbnailSizeImageUri;
    tempPunchObj.punchInUri =punchObj.punchInUri;
    tempPunchObj.punchOutAgent =punchObj.punchOutAgent;
    tempPunchObj.punchOutFullSizeImageLink =punchObj.punchOutFullSizeImageLink;
    tempPunchObj.punchOutFullSizeImageUri =punchObj.punchOutFullSizeImageUri;
    tempPunchObj.punchOutThumbnailSizeImageLink =punchObj.punchOutThumbnailSizeImageLink;
    tempPunchObj.punchOutThumbnailSizeImageUri =punchObj.punchOutThumbnailSizeImageUri;
    tempPunchObj.punchOutUri =punchObj.punchOutUri;
    tempPunchObj.punchUserName =punchObj.punchUserName;
    tempPunchObj.punchUserUri =punchObj.punchUserUri;
    tempPunchObj.totalHours =punchObj.totalHours;
    tempPunchObj.CellIdentifier=PUNCH_CELL;
    tempPunchObj.breakName=punchObj.breakName;
    tempPunchObj.breakUri=punchObj.breakUri;
    tempPunchObj.isBreakPunch=punchObj.isBreakPunch;
    
    tempPunchObj.punchInAgentUri=punchObj.punchInAgentUri;
    tempPunchObj.punchOutAgentUri=punchObj.punchOutAgentUri;
    tempPunchObj.punchInCloudClockUri=punchObj.punchInCloudClockUri;
    tempPunchObj.punchOutCloudClockUri=punchObj.punchOutCloudClockUri;
    tempPunchObj.punchInAccuracyInMeters=punchObj.punchInAccuracyInMeters;
    tempPunchObj.punchOutAccuracyInMeters=punchObj.punchOutAccuracyInMeters;
    tempPunchObj.punchInActionUri=punchObj.punchInActionUri;
    tempPunchObj.punchOutActionUri=punchObj.punchOutActionUri;
    
    punchObj=tempPunchObj;
    
}
-(void)updateBreakUri:(NSString*)breakUri andBreakName:(NSString*)breakName{
    if (breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]])
    {
        activityLabel.text=[NSString stringWithFormat:@"  %@",breakName];
        TeamTimePunchObject *tempPunchObj=[[TeamTimePunchObject alloc]init];
        
        tempPunchObj.PunchInAddress =punchObj.PunchInAddress;
        tempPunchObj.PunchInDate =punchObj.PunchInDate;
        tempPunchObj.PunchInDateTimestamp =punchObj.PunchInDateTimestamp;
        tempPunchObj.PunchInLatitude =punchObj.PunchInLatitude;
        tempPunchObj.PunchInLongitude =punchObj.PunchInLongitude;
        tempPunchObj.PunchInTime =punchObj.PunchInTime;
        tempPunchObj.PunchOutAddress =punchObj.PunchOutAddress;
        tempPunchObj.PunchOutDate =punchObj.PunchOutDate;
        tempPunchObj.PunchOutDateTimestamp =punchObj.PunchOutDateTimestamp;
        tempPunchObj.PunchOutLatitude =punchObj.PunchOutLatitude;
        tempPunchObj.PunchOutLongitude =punchObj.PunchOutLongitude;
        tempPunchObj.PunchOutTime =punchObj.PunchOutTime;
        tempPunchObj.activityName =punchObj.activityName;
        tempPunchObj.activityUri =punchObj.activityUri;
        tempPunchObj.punchInAgent =punchObj.punchInAgent;
        tempPunchObj.punchInFullSizeImageLink =punchObj.punchInFullSizeImageLink;
        tempPunchObj.punchInFullSizeImageUri =punchObj.punchInFullSizeImageUri;
        tempPunchObj.punchInThumbnailSizeImageLink =punchObj.punchInThumbnailSizeImageLink;
        tempPunchObj.punchInThumbnailSizeImageUri =punchObj.punchInThumbnailSizeImageUri;
        tempPunchObj.punchInUri =punchObj.punchInUri;
        tempPunchObj.punchOutAgent =punchObj.punchOutAgent;
        tempPunchObj.punchOutFullSizeImageLink =punchObj.punchOutFullSizeImageLink;
        tempPunchObj.punchOutFullSizeImageUri =punchObj.punchOutFullSizeImageUri;
        tempPunchObj.punchOutThumbnailSizeImageLink =punchObj.punchOutThumbnailSizeImageLink;
        tempPunchObj.punchOutThumbnailSizeImageUri =punchObj.punchOutThumbnailSizeImageUri;
        tempPunchObj.punchOutUri =punchObj.punchOutUri;
        tempPunchObj.punchUserName =punchObj.punchUserName;
        tempPunchObj.punchUserUri =punchObj.punchUserUri;
        tempPunchObj.totalHours =punchObj.totalHours;
        tempPunchObj.CellIdentifier=PUNCH_CELL;
        tempPunchObj.breakName=breakName;
        tempPunchObj.breakUri=breakUri;
        tempPunchObj.isBreakPunch=punchObj.isBreakPunch;
        
        tempPunchObj.punchInAgentUri=punchObj.punchInAgentUri;
        tempPunchObj.punchOutAgentUri=punchObj.punchOutAgentUri;
        tempPunchObj.punchInCloudClockUri=punchObj.punchInCloudClockUri;
        tempPunchObj.punchOutCloudClockUri=punchObj.punchOutCloudClockUri;
        tempPunchObj.punchInAccuracyInMeters=punchObj.punchInAccuracyInMeters;
        tempPunchObj.punchOutAccuracyInMeters=punchObj.punchOutAccuracyInMeters;
        tempPunchObj.punchInActionUri=punchObj.punchInActionUri;
        tempPunchObj.punchOutActionUri=punchObj.punchOutActionUri;
        
        
        punchObj=tempPunchObj;
       
    }
}
-(void)cancelAction:(id)sender
{
    CLS_LOG(@"-----Cancel Action on PunchEntryViewController -----");
    [[NSNotificationCenter defaultCenter]postNotificationName:UPDATE_VIEW_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:TRUE] forKey:@"isError"] ];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)saveAction:(id)sender
{
     CLS_LOG(@"-----Save Action on PunchEntryViewController -----");
    
    
    if (![NetworkMonitor isNetworkAvailableForListener:self])
    {
        [Util showOfflineAlert];
        return;
    }
    else
    {
        BOOL activitySelectionRequired = NO;
        if ([self.navigationType isKindOfClass:[TeamTimeNavigationController class]]||
            [self.navigationType isKindOfClass:[SupervisorDashboardNavigationController class]])
        {
            TeamTimeModel *teamTimeModel=[[TeamTimeModel alloc]init];
            NSMutableDictionary *userCapabilitiesDict = [teamTimeModel getUserCapabilitiesForUserUri:self.punchObj.punchUserUri];
            activitySelectionRequired= [[userCapabilitiesDict objectForKey:@"activitySelectionRequired"]boolValue];

        }
        else if ([self.navigationType isKindOfClass:[PunchHistoryNavigationController class]])
        {
            LoginModel *loginModel=[[LoginModel alloc]init];
            activitySelectionRequired=[loginModel getStatusForGivenPermissions:@"timepunchActivitySelectionRequired"];

        }
        else
        {
            LoginModel *loginModel=[[LoginModel alloc]init];
            activitySelectionRequired=[loginModel getStatusForGivenPermissions:@"timepunchActivitySelectionRequired"];
        }
        
        if (self.setViewTag!=Out_Tag)
        {
            if ([[self.activityLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ] isEqualToString:RPLocalizedString(SELECT_ACTIVITY, SELECT_ACTIVITY)] && activitySelectionRequired==YES)
            {
                [Util errorAlert:@"" errorMessage:RPLocalizedString(NO_ACTIVITY_MSG, NO_ACTIVITY_MSG)];
                return;
            }
        }
        
        if (self.setViewTag==Break_Tag)
        {
            if ([[self.activityLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ]isEqualToString:RPLocalizedString(SELECT_BREAK, SELECT_BREAK)])
            {
                [Util errorAlert:@"" errorMessage:RPLocalizedString(NO_BREAKS_MSG, NO_BREAKS_MSG)];
                return;
            }
        }
        
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:EDIT_OR_ADD_DATA_RECIEVED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData:) name:EDIT_OR_ADD_DATA_RECIEVED_NOTIFICATION object:nil];
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
        NSString *type=nil;
        if (screenMode==ADD_PUNCH_ENTRY)
        {
            if (setViewTag==In_Tag)
            {
                type=@"In";
                BtnClicked=@"In";
            }
            else if (setViewTag==Out_Tag){
                type=@"Out";
                 BtnClicked=@"Out";
            }
            else if (setViewTag==Break_Tag){
                type=@"Break";
                
            }
            else if (setViewTag==Transfer_Tag){
                type=@"Transfer";
                
            }
        }
        else{
            if ([BtnClicked isEqualToString:@"In"])
            {
                type=@"In";
            }
            else{
                type=@"Out";
            }
        }
        
        
        
        if ([self.navigationType isKindOfClass:[PunchHistoryNavigationController class]])
        {
            
            [[RepliconServiceManager punchHistoryService] sendEditOrAddPunchRequestServiceForDataDict:punchObj editType:type  fromMode:BtnClicked andTimesheetURI:timesheetURI];
            
        }
        else if ([self.navigationType isKindOfClass:[SupervisorDashboardNavigationController class]])
        {

            [[RepliconServiceManager timesheetService]sendRequestUpdateTimesheetAttestationStatusForTimesheetURI:self.timesheetURI forAttestationStatusUri:ATTESTATION_STATUS_UNATTESTED];
            [[RepliconServiceManager punchHistoryService] sendEditOrAddPunchRequestServiceForDataDict:punchObj editType:type  fromMode:BtnClicked andTimesheetURI:timesheetURI];

        }
        else
        {
            [[RepliconServiceManager timesheetService]sendRequestUpdateTimesheetAttestationStatusForTimesheetURI:self.timesheetURI forAttestationStatusUri:ATTESTATION_STATUS_UNATTESTED];
            [[RepliconServiceManager punchHistoryService] sendEditOrAddPunchRequestServiceForDataDict:punchObj editType:type  fromMode:BtnClicked andTimesheetURI:timesheetURI];
        }
    }
    
   
    
    
}
-(void)deleteAction:(id)sender
{
    CLS_LOG(@"-----Delete Action on PunchEntryViewController -----");

    [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"Cancel",@"Cancel")
                                   otherButtonTitle:RPLocalizedString(@"Delete",@"Delete")
                                           delegate:self
                                            message:RPLocalizedString(PUNCH_DELETE_MSG, @"")
                                              title:@""
                                                tag:LONG_MIN];


    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // the user clicked Cancel
    if (buttonIndex == 0) {
        // do something here...
    }
    else{
        CLS_LOG(@"-----Delete Action on PunchEntryViewController -----");
        if ([self.navigationType isKindOfClass:[PunchHistoryNavigationController class]])
        {
            if ([BtnClicked isEqualToString:@"In"])
            {
                [[RepliconServiceManager punchHistoryService] deletePunchRequestServiceForPunchUri:punchObj.punchInUri];
            }
            else if ([BtnClicked isEqualToString:@"Out"])
            {
                [[RepliconServiceManager punchHistoryService] deletePunchRequestServiceForPunchUri:punchObj.punchOutUri];
            }
        }
        else
        {
            [[RepliconServiceManager timesheetService]sendRequestUpdateTimesheetAttestationStatusForTimesheetURI:self.timesheetURI forAttestationStatusUri:ATTESTATION_STATUS_UNATTESTED];

            if ([BtnClicked isEqualToString:@"In"])
            {
                [[RepliconServiceManager punchHistoryService] deletePunchRequestServiceForPunchUri:punchObj.punchInUri];
            }
            else if ([BtnClicked isEqualToString:@"Out"])
            {
                [[RepliconServiceManager punchHistoryService] deletePunchRequestServiceForPunchUri:punchObj.punchOutUri];
            }
        }
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:DELETE_DATA_RECIEVED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData:) name:DELETE_DATA_RECIEVED_NOTIFICATION object:nil];
    }
}

-(void)updateData :(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDIT_OR_ADD_DATA_RECIEVED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DELETE_DATA_RECIEVED_NOTIFICATION object:nil];

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
	df.dateStyle = NSDateFormatterMediumStyle;
	[df setDateFormat:@"EEE, MMM dd, yyyy"];
    
    NSLocale *locale=[NSLocale currentLocale];
    [df setLocale:locale];
    [df setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSDictionary *dict=notification.userInfo;
    
    BOOL hasError=[[dict objectForKey:@"isError"]boolValue];
    
    if (!hasError)
    {
        if ([self.delegate isKindOfClass:[TeamTimeViewController class]]) {
            TeamTimeViewController *vc=(TeamTimeViewController *)self.delegate;
            vc.hasUserChangedAnyValue=YES;
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self name:DATA_UPDATED_RECIEVED_NOTIFICATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popView:) name:DATA_UPDATED_RECIEVED_NOTIFICATION object:nil];
        NSDate *date = [df dateFromString:currentPageDate];
        if ([self.navigationType isKindOfClass:[PunchHistoryNavigationController class]])
        {
            [[RepliconServiceManager punchHistoryService] fetchPunchHistoryDataForDate:date];
        }

        else if ([self.navigationType isKindOfClass:[SupervisorDashboardNavigationController class]])
        {
            [[RepliconServiceManager punchHistoryService] sendRequestToGetAllTimeSegmentsForTimesheet:timesheetURI WithStartDate:date withDelegate:self.navigationType andApprovalsModelName:self.approvalsModuleName];
        }

        else
        {
            [[RepliconServiceManager punchHistoryService] sendRequestToGetAllTimeSegmentsForTimesheet:timesheetURI WithStartDate:date withDelegate:self.navigationType andApprovalsModelName:self.approvalsModuleName];
        }
        
         NSDictionary *dateDict=[Util convertDateToApiDateDictionary:date];
        if (dateDict!=nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self sendRequestToRecalculateScriptDataWithDataDict:dateDict];
                
            });
        }
       
    }
    else
    {
        //MOBI-948
        if (screenMode==ADD_PUNCH_ENTRY)
        {
            BtnClicked=nil;
        }
    }
    
    

}


-(void)popView :(NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DATA_UPDATED_RECIEVED_NOTIFICATION object:nil];
    NSDictionary *dict=notification.userInfo;
    
    BOOL hasError=[[dict objectForKey:@"isError"]boolValue];
    
    if (!hasError)
    {
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_VIEW_NOTIFICATION object:nil];
}
#pragma mark -
#pragma mark Segment Delegates
-(void) changeUISegmentFont:(UIView*) myView
{
    // Getting the label subview of the passed view
    if ([myView isKindOfClass:[UILabel class]])
    {
        UILabel* label = (UILabel*)myView;
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_12]];       // Set the font size you want to change to
        [label sizeToFit];
        CGRect frame=label.frame;
        frame.size.width=label.frame.size.width+100;
        label.frame=frame;
        
        NSString *string=label.text;
        if ([string hasPrefix:RPLocalizedString(IN_TEXT,@"")])
        {
            [label setText:[NSString stringWithFormat:@"%@",RPLocalizedString(IN_TEXT,@"")]];
        }
        else if([string hasPrefix:RPLocalizedString(OUT_TEXT,@"")])
        {
            [label setText:[NSString stringWithFormat:@"%@",RPLocalizedString(OUT_TEXT,@"")]];
        }
        else if([string hasPrefix:RPLocalizedString(Transfer_Title,@"")])
        {
            [label setText:[NSString stringWithFormat:@"%@",RPLocalizedString(Transfer_Title,@"")]];
        }
        else if([string hasPrefix:RPLocalizedString(BREAK_ENTRY,@"")])
        {
            [label setText:[NSString stringWithFormat:@"%@",RPLocalizedString(BREAK_ENTRY,@"")]];
        }
    }
    
    NSArray* subViewArray = [myView subviews];                  // Getting the subview array
    NSEnumerator* iterator = [subViewArray objectEnumerator];   // For enumeration
    UIView* subView;
    // Iterating through the subviews of the view passed
    while (subView = [iterator nextObject])
    {
        [self changeUISegmentFont:subView]; // Recursion
        
    }
    
}
-(void)updateView{
    UIImage *img;
    if (setViewTag==Break_Tag)
    {
        img=[UIImage imageNamed:@"icon_Break-Tag-Yellow"];
        self.imgLabel.text=@"";
        self.imgLabel.textColor=[UIColor whiteColor];
        
    }
    else if (setViewTag==Out_Tag)
    {
        img=[UIImage imageNamed:@"icon_OUT-Tag-Gray"];
        self.imgLabel.text=RPLocalizedString(OUT_TEXT, OUT_TEXT);
        self.imgLabel.textColor=[UIColor blackColor];
    }
    else
    {
         img=[UIImage imageNamed:@"icon_IN-Tag-Green"];
        self.imgLabel.text=RPLocalizedString(IN_TEXT, IN_TEXT);
        self.imgLabel.textColor=[UIColor whiteColor];
    }
    
    if (setViewTag==Break_Tag)
    {
        //CHANGE BREAK TITILE
//        if (punchObj.breakUri!=nil && ![punchObj.breakUri isKindOfClass:[NSNull class]] && ![punchObj.breakUri isEqualToString:@""])
//        {
//            if ([BtnClicked isEqualToString:@"In"])
//            {
//                
//                selectedSegmentLabel.text=RPLocalizedString(BREAK_TITLE, @"");
//            }
//            else if ([BtnClicked isEqualToString:@"Out"])
//            {
//                
//                selectedSegmentLabel.text=RPLocalizedString(BREAK_OUT_TITLE, @"");
//            }
//            
//        }
//        else
//            //TO HERE
            selectedSegmentLabel.text=RPLocalizedString(BREAK_TITLE, @"");
        
        
    }
    else if (setViewTag==Out_Tag)
    {
        selectedSegmentLabel.text=RPLocalizedString(CLOCKED_OUT, @"");
    }
    else if (setViewTag==Transfer_Tag)
        selectedSegmentLabel.text=RPLocalizedString(Transfer, @"");
    else
        selectedSegmentLabel.text=RPLocalizedString(CLOCKED_IN, @"");
    
    selectedSegmentBtn.hidden=NO;
    
    
    if (setViewTag==Break_Tag)
    {
        if (punchObj.breakUri!=nil && ![punchObj.breakUri isKindOfClass:[NSNull class]] && ![punchObj.breakUri isEqualToString:@""]){
            self.activityLabel.text=[NSString stringWithFormat:@"  %@",punchObj.breakName] ;
            
        }
        else
        {
            self.activityLabel.text=[NSString stringWithFormat:@"  %@",RPLocalizedString(SELECT_BREAK, @"")] ;
        }
        
        if (!hasBreakAccess)
        {
            selectedSegmentBtn.hidden=YES;
        }
    }
    else{
        if (punchObj.activityUri!=nil && ![punchObj.activityUri isKindOfClass:[NSNull class]]&& ![punchObj.activityUri isEqualToString:@""])
        {
            self.self.activityLabel.text=[NSString stringWithFormat:@"  %@",punchObj.activityName];
            
            if (!hasActivityAccess)
            {
                selectedSegmentBtn.hidden=YES;
            }
        }
        else{
            if ( setViewTag==Out_Tag)
            {
                self.activityLabel.text=[NSString stringWithFormat:@"  %@",RPLocalizedString(NO_ACTIVITY_SELECTED_STRING, @"")];
            }
            else
            {
                 self.activityLabel.text=[NSString stringWithFormat:@"  %@",RPLocalizedString(SELECT_ACTIVITY, @"")];
                if (!hasActivityAccess)
                {
                    selectedSegmentBtn.hidden=YES;
                }
            }
            
        }
    }
    selectedSegmentImageview.image=img;
    
    if (setViewTag==Out_Tag)
    {
        selectedSegmentBtn.hidden=YES;
    }
    


}
/************************************************************************************************************
 @Function Name   : segmentChanged
 @Purpose         : To handle segment selected
 @param           : (id)sender
 @return          : nil
 *************************************************************************************************************/

-(void)segmentChanged:(id)sender {
    // when a segment is selected, it resets the text colors
    // so set them back
    UISegmentedControl *segmentCtrl=(UISegmentedControl *)sender;
    
    
    [self setTextColorsForSegmentedControl:(UISegmentedControl*)sender];
    
    
    
    switch (segmentCtrl.selectedSegmentIndex) {
        case 0:
            
                CLS_LOG(@"-----In View segement action on PunchEntryViewController -----");
            setViewTag=In_Tag;
                [self updateView];
                
            
            
            break;
        case 1:
            
                CLS_LOG(@"-----Out View segement action on PunchEntryViewController -----");
            setViewTag=Out_Tag;
                [self updateView];
                
            
            
            
            break;
        case 2:
           
            CLS_LOG(@"-----Transfer View segement action on PunchEntryViewController -----");
            if (hasActivityAccess)
            {
                setViewTag=Transfer_Tag;
                [self updateView];
                
            }
            else if (hasBreakAccess &&!hasActivityAccess){
                setViewTag=Break_Tag;
                [self updateView];
            }
            
            break;
        case 3:
            
                CLS_LOG(@"-----Break View segement action on PunchEntryViewController -----");
            setViewTag=Break_Tag;
                [self updateView];
            break;
        default:
            break;
    }
    

    [UIView commitAnimations];
    //Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion newFloatValue];
    if (version<7.0)
    {
        self.segmentedCtrl.selectedSegmentIndex=-1;
    }
    
    [self changeUISegmentFont:self.segmentedCtrl];
}
/************************************************************************************************************
 @Function Name   : setTextColorsForSegmentedControl
 @Purpose         : To set text color changes in the segment control
 @param           : (UISegmentedControl*)segmented
 @return          : nil
 *************************************************************************************************************/

-(void)setTextColorsForSegmentedControl:(UISegmentedControl*)segmented
{
    
    //Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion newFloatValue];
    switch (segmented.selectedSegmentIndex) {
        case 0:
            
                
                //Fix for ios7//JUHI
                if (version<7.0)
                {
                    [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagFirst];
                    [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagSecond];
                    
                    [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagThird];
                    
                    
                    //MOBI-829//JUHI
                    if (hasBreakAccess && hasActivityAccess)
                    {
                       [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagFour];
                    }
                    
                    [segmented setShadowColor:[UIColor blackColor] forTag:kTagFirst];
                    [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagSecond];
                    
                    [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagThird];
                    
                    
                    //MOBI-829//JUHI
                    if (hasBreakAccess && hasActivityAccess)
                    {
                        [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagFour];
                    }
                    
                    
                    
                    [segmented setTextColor:[Util colorWithHex:@"#ffffff" alpha:1] forTag:kTagFirst];
                    [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagSecond];
                    
                    [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagThird];
                    
                    
                    //MOBI-829//JUHI
                    if (hasBreakAccess && hasActivityAccess)
                    {
                        [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagFour];
                    }
                    
                }
                else{
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#107ebe" alpha:1] forTag:kTagFirst];
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagSecond];
                    
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagThird];
                    
                   
                    //MOBI-829//JUHI
                    if (hasBreakAccess && hasActivityAccess)
                    {
                        [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagFour];
                    }
                    
                    
                }
                
            
            
            break;
        case 1:
            
                //Fix for ios7//JUHI
                if (version<7.0)
                {
                    [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagSecond];
                    [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagFirst];
                    //Implementation for MOBI-829//JUHI
                    if (hasActivityAccess)
                    {
                        [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagThird];
                    }
                   
                    if (hasBreakAccess)
                    {
                         [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagFour];
                    }
                   
                    [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagFirst];
                    [segmented setShadowColor:[UIColor blackColor] forTag:kTagSecond];
                    
                    [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagThird];
                    
                    //MOBI-829//JUHI
                    if (hasBreakAccess && hasActivityAccess)
                    {
                        [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagFour];
                    }
                    
                    [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagFirst];
                    [segmented setTextColor:[Util colorWithHex:@"#ffffff" alpha:1] forTag:kTagSecond];
                    
                    [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagThird];
                    
                   
                    //MOBI-829//JUHI
                    if (hasBreakAccess && hasActivityAccess)
                    {
                        [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagFour];
                    }
                    
                }
                else{
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagFirst];
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#107ebe" alpha:1] forTag:kTagSecond];
                    
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagThird];
                    
                    
                    //MOBI-829//JUHI
                    if (hasBreakAccess && hasActivityAccess)
                    {
                       [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagFour];
                    }
                    
                    
                }
            
            
            
            
            break;
        case 2:
            //Fix for ios7//JUHI
            if (version<7.0)
            {
                if (hasActivityAccess)
                {
                    [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagThird];
                    [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagFirst];
                    
                    [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagSecond];
                    if (hasBreakAccess)
                    {
                        [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagFour];
                    }
                    
                    [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagFirst];
                    [segmented setShadowColor:[UIColor blackColor] forTag:kTagThird];
                    [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagSecond];
                    if (hasBreakAccess)
                    {
                        [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagFour];
                    }
                    
                    [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagFirst];
                    [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagSecond];
                    [segmented setTextColor:[Util colorWithHex:@"#ffffff" alpha:1] forTag:kTagThird];
                    if (hasBreakAccess)
                    {
                        [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagFour];
                    }
                }
                else if (hasBreakAccess &&!hasActivityAccess)
                {
                    [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagThird];
                    [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagFirst];
                    
                    [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagSecond];
                    
                    
                    [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagFirst];
                    [segmented setShadowColor:[UIColor blackColor] forTag:kTagThird];
                    [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagSecond];
                    
                    [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagFirst];
                    [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagSecond];
                    [segmented setTextColor:[Util colorWithHex:@"#ffffff" alpha:1] forTag:kTagThird];
                    
                }
                
               
            }
            else{
                if (hasActivityAccess)
                {
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagFirst];
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagSecond];
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#107ebe" alpha:1] forTag:kTagThird];
                    if (hasBreakAccess)
                    {
                        [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagFour];
                    }
                }
                else if (hasBreakAccess &&!hasActivityAccess)
                {
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagFirst];
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagSecond];
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#107ebe" alpha:1] forTag:kTagThird];
                    
                }
                
                
                
            }
            
            
            
            break;
        case 3:
            //Fix for ios7//JUHI
            if (version<7.0)
            {
                if (hasBreakAccess)
                {
                    [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagFour];
                }
               
                [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagFirst];
                [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagSecond];
                [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagThird];
                [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagFirst];
                if (hasBreakAccess)
                {
                    [segmented setShadowColor:[UIColor blackColor] forTag:kTagFour];
                }
                
                [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagSecond];
                [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagThird];
                [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagFirst];
                [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagSecond];
                if (hasBreakAccess)
                {
                    [segmented setTextColor:[Util colorWithHex:@"#ffffff" alpha:1] forTag:kTagFour];
                }
                
                [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagThird];
            }
            else{
                [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagFirst];
                [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagSecond];
                [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagThird];
                if (hasBreakAccess)
                {
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#107ebe" alpha:1] forTag:kTagFour];
                }
                
                
            }
            
            
            
            break;
        default:
            if (setViewTag==In_Tag)
            {
                //Fix for ios7//JUHI
                if (version<7.0)
                {
                    [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagFirst];
                    [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagSecond];
                    [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagThird];
                    if (hasBreakAccess)
                    {
                        [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagFour];
                    }
                    
                    // [segmented setShadowColor:[UIColor blackColor] forTag:kTagFirst];
                    [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagSecond];
                    [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagThird];
                    //MOBI-829//JUHI
                    if (hasBreakAccess && hasActivityAccess)
                    {
                        [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagFour];
                    }
                    
                    [segmented setTextColor:[Util colorWithHex:@"#ffffff" alpha:1] forTag:kTagFirst];
                    [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagSecond];
                    [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagThird];
                    if (hasBreakAccess)
                    {
                        [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagFour];
                    }
                    
                }
                else{
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#107ebe" alpha:1] forTag:kTagFirst];
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagSecond];
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagThird];
                    //MOBI-829//JUHI
                    if (hasBreakAccess && hasActivityAccess)
                    {
                        [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagFour];
                    }
                    
                    
                }
            }
            else{
                //Fix for ios7//JUHI
                if (version<7.0)
                {
                    [self.segmentedCtrl setTintColor:RepliconStandardSelectedSegmentColor forTag:kTagSecond];
                    [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagFirst];
                    [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagThird];
                    //MOBI-829//JUHI
                    if (hasBreakAccess && hasActivityAccess)
                    {
                        [self.segmentedCtrl setTintColor:RepliconStandardUnSelectedSegmentColor forTag:kTagFour];
                    }
                    
                    // [segmented setShadowColor:[UIColor blackColor] forTag:kTagFirst];
                    [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagFirst];
                    [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagThird];
                    //MOBI-829//JUHI
                    if (hasBreakAccess && hasActivityAccess)
                    {
                         [segmented setShadowColor:[UIColor lightGrayColor] forTag:kTagFour];
                    }
                   
                    [segmented setTextColor:[Util colorWithHex:@"#ffffff" alpha:1] forTag:kTagSecond];
                    [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagFirst];
                    [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagThird];
                    if (hasBreakAccess)
                    {
                         [segmented setTextColor:[Util colorWithHex:@"#333333" alpha:1] forTag:kTagFour];
                    }
                   
                }
                else{
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#107ebe" alpha:1] forTag:kTagSecond];
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagFirst];
                    [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagThird];
                    //MOBI-829//JUHI
                    if (hasBreakAccess && hasActivityAccess)
                    {
                         [self.segmentedCtrl setBackgroundColor:[Util colorWithHex:@"#e8e8e8" alpha:1] forTag:kTagFour];
                    }
                   
                    
                }
            }
            
            
            break;
    }
    
    
    
    
}

//Implemetation for Punch-229//JUHI
-(void)dateAction:(id)sender{
    [self doneClicked];
    
    id fieldValue=nil;
    if ((screenMode==EDIT_PUNCH_ENTRY && [BtnClicked isEqualToString:@"Out"]) || setViewTag==Out_Tag)
    {
        fieldValue=punchObj.PunchOutDate;
    }
    
    else if((screenMode==EDIT_PUNCH_ENTRY && [BtnClicked isEqualToString:@"In"]) || BtnClicked==nil)
    {
        fieldValue=punchObj.PunchInDate;
    }
    
    
    
    NSString *dateStr=fieldValue;
    self.previousDateValue=dateStr;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    if (punchDatePicker!=nil)
    {
        [self punchDateDoneClicked];
        punchDatePicker=nil;
    }
    if (punchDatePicker==nil)
    {
        UIDatePicker *tempdatePicker = [[UIDatePicker alloc] init];
        self.punchDatePicker=tempdatePicker;
    }
   
    self.punchDatePicker.backgroundColor = [UIColor whiteColor];
    self.punchDatePicker.frame=CGRectMake(0, screenRect.size.height-210, self.view.frame.size.width, 210);
    self.punchDatePicker.datePickerMode = UIDatePickerModeDate;
    self.punchDatePicker.timeZone=[NSTimeZone timeZoneForSecondsFromGMT:0];
    self.punchDatePicker.hidden = NO;
    
    if ([fieldValue isKindOfClass:[NSString class]])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        NSLocale *locale=[NSLocale currentLocale];
        [dateFormatter setLocale:locale];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        if ([dateStr isEqualToString:RPLocalizedString(SELECT_STRING, @"")]) {
            self.punchDatePicker.date = [NSDate date];
            
        }
        else{
           
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *punchDate=[dateFormatter dateFromString:dateStr];
            
            [dateFormatter setDateFormat:@"MMMM d, yyyy"];
            NSString *punchDateStr=[dateFormatter stringFromDate:punchDate];
            fieldValue = [dateFormatter dateFromString:punchDateStr];
            self.punchDatePicker.date = fieldValue;
        }
        
    }
    
    [self.punchDatePicker addTarget:self
                        action:@selector(updatePunchDateFieldWithPickerChange:)
              forControlEvents:UIControlEventValueChanged];
    
    AppDelegate *delegatee=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    [delegatee.window addSubview:self.punchDatePicker];
    
    if (self.toolbar!=nil)
    {
        self.toolbar=nil;
    }
    UIToolbar *temptoolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0, screenRect.size.height-324, self.view.frame.size.width, 50)];
    self.toolbar=temptoolbar;
    self.toolbar.barStyle = UIBarStyleBlackOpaque;
    //Implementation for US8771 HandleDateUDFEmptyValue//JUHI
    UIBarButtonItem *tempDoneButton = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString( @"Done",  @"Done") style: UIBarButtonItemStylePlain target: self action: @selector(punchDateDoneClicked)];
    
    
    
    UIBarButtonItem *tmpCancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                     target:self
                                                                                     action:@selector(pickerCancel:)];
   
    
    
    UIBarButtonItem *tmpSpaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                    target:nil
                                                                                    action:nil];
	
    //Fix for ios7//JUHI
	float version= [[UIDevice currentDevice].systemVersion newFloatValue];
    
    if (version<7.0)
    {
        [toolbar setTintColor:[UIColor clearColor]];
    }
    else
        
    {
        tempDoneButton.tintColor=RepliconStandardWhiteColor;
        tmpCancelButton.tintColor=RepliconStandardWhiteColor;
        
        UIImage *backgroundImage = [Util thumbnailImage:TOOLBAR_IMAGE];
        [toolbar setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
        [toolbar setTintColor:[Util colorWithHex:@"#dddddd" alpha:1]];
        [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    }
    NSArray *toolArray = [NSArray arrayWithObjects:tmpCancelButton,tmpSpaceButton,tempDoneButton,nil];
    [toolbar setItems:toolArray];
    [self.view addSubview: self.toolbar];
}
- (void)updatePunchDateFieldWithPickerChange:(id)sender{
    NSString *selectedDateString=nil;
    if ([sender isKindOfClass:[NSString class]])
    {
        selectedDateString=sender;
        
    }
    else{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale=[NSLocale currentLocale];
        dateFormatter.locale = locale;
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        selectedDateString=[dateFormatter stringFromDate:[sender date]];
    }
   
    TeamTimePunchObject *tempPunchObj=[[TeamTimePunchObject alloc]init];
    
    tempPunchObj.PunchInAddress =punchObj.PunchInAddress;
    tempPunchObj.PunchInTime =punchObj.PunchInTime;
    
    tempPunchObj.PunchInLatitude =punchObj.PunchInLatitude;
    tempPunchObj.PunchInLongitude =punchObj.PunchInLongitude;
    
    tempPunchObj.PunchOutAddress =punchObj.PunchOutAddress;
    tempPunchObj.PunchOutTime =punchObj.PunchOutTime;
    
    tempPunchObj.PunchOutLatitude =punchObj.PunchOutLatitude;
    tempPunchObj.PunchOutLongitude =punchObj.PunchOutLongitude;
    
    tempPunchObj.activityName =punchObj.activityName;
    tempPunchObj.activityUri =punchObj.activityUri;
    tempPunchObj.punchInAgent =punchObj.punchInAgent;
    tempPunchObj.punchInFullSizeImageLink =punchObj.punchInFullSizeImageLink;
    tempPunchObj.punchInFullSizeImageUri =punchObj.punchInFullSizeImageUri;
    tempPunchObj.punchInThumbnailSizeImageLink =punchObj.punchInThumbnailSizeImageLink;
    tempPunchObj.punchInThumbnailSizeImageUri =punchObj.punchInThumbnailSizeImageUri;
    tempPunchObj.punchInUri =punchObj.punchInUri;
    tempPunchObj.punchOutAgent =punchObj.punchOutAgent;
    tempPunchObj.punchOutFullSizeImageLink =punchObj.punchOutFullSizeImageLink;
    tempPunchObj.punchOutFullSizeImageUri =punchObj.punchOutFullSizeImageUri;
    tempPunchObj.punchOutThumbnailSizeImageLink =punchObj.punchOutThumbnailSizeImageLink;
    tempPunchObj.punchOutThumbnailSizeImageUri =punchObj.punchOutThumbnailSizeImageUri;
    tempPunchObj.punchOutUri =punchObj.punchOutUri;
    tempPunchObj.punchUserName =punchObj.punchUserName;
    tempPunchObj.punchUserUri =punchObj.punchUserUri;
    tempPunchObj.totalHours =punchObj.totalHours;
    tempPunchObj.CellIdentifier=PUNCH_CELL;
    tempPunchObj.breakName=punchObj.breakName;
    tempPunchObj.breakUri=punchObj.breakUri;
    tempPunchObj.isBreakPunch=punchObj.isBreakPunch;
    
    tempPunchObj.punchInAgentUri=punchObj.punchInAgentUri;
    tempPunchObj.punchOutAgentUri=punchObj.punchOutAgentUri;
    tempPunchObj.punchInCloudClockUri=punchObj.punchInCloudClockUri;
    tempPunchObj.punchOutCloudClockUri=punchObj.punchOutCloudClockUri;
    tempPunchObj.punchInAccuracyInMeters=punchObj.punchInAccuracyInMeters;
    tempPunchObj.punchOutAccuracyInMeters=punchObj.punchOutAccuracyInMeters;
    tempPunchObj.punchInActionUri=punchObj.punchInActionUri;
    tempPunchObj.punchOutActionUri=punchObj.punchOutActionUri;
    
    if ((screenMode==EDIT_PUNCH_ENTRY && [BtnClicked isEqualToString:@"Out"]) || setViewTag==Out_Tag)
    {
        tempPunchObj.PunchOutDate=selectedDateString;
        NSString *tempcurrentPageDate=[NSString stringWithFormat:@"%@ %@",tempPunchObj.PunchOutDate,tempPunchObj.PunchOutTime];
        NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *twelveHourLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        myDateFormatter.locale = twelveHourLocale;
        [myDateFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
        NSDate *date=[myDateFormatter dateFromString:tempcurrentPageDate];
        if (date==nil)
        {
            NSLocale *locale=[NSLocale currentLocale];
            myDateFormatter.locale =locale;
            date=[myDateFormatter dateFromString:tempcurrentPageDate];
        }
        tempPunchObj.PunchOutDateTimestamp=[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:[date timeIntervalSince1970]]];
        
    }
    
    else if((screenMode==EDIT_PUNCH_ENTRY && [BtnClicked isEqualToString:@"In"]) || BtnClicked==nil)
    {
        tempPunchObj.PunchInDate=selectedDateString;
        
        
        NSString *tempcurrentPageDate=[NSString stringWithFormat:@"%@ %@",tempPunchObj.PunchInDate,tempPunchObj.PunchInTime];
        NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *twelveHourLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        myDateFormatter.locale = twelveHourLocale;
        [myDateFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
        NSDate *date=[myDateFormatter dateFromString:tempcurrentPageDate];
        if (date==nil)
        {
            NSLocale *locale=[NSLocale currentLocale];
            myDateFormatter.locale =locale;
            date=[myDateFormatter dateFromString:tempcurrentPageDate];
        }
        tempPunchObj.PunchInDateTimestamp=[NSString stringWithFormat:@"%@",[NSNumber numberWithDouble:[date timeIntervalSince1970]]];
        
    }
    
    
    punchObj=tempPunchObj;
    
    NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
    
    NSLocale *locale=[NSLocale currentLocale];
    [myDateFormatter setLocale:locale];
    [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [myDateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *punchDate=nil;
    if ((screenMode==EDIT_PUNCH_ENTRY && [BtnClicked isEqualToString:@"Out"]) || setViewTag==Out_Tag)
    {
        punchDate=[myDateFormatter dateFromString:punchObj.PunchOutDate];
    }
    
    else if((screenMode==EDIT_PUNCH_ENTRY && [BtnClicked isEqualToString:@"In"]) || BtnClicked==nil)
    {
        punchDate=[myDateFormatter dateFromString:punchObj.PunchInDate];
    }
    
    
    
    [myDateFormatter setDateFormat:@"EEE, MMM dd, yyyy"];
    
    
    selectedDateString= [myDateFormatter stringFromDate:punchDate];
    
    if (selectedDateString!=nil && ![selectedDateString isKindOfClass:[NSNull class]])
    {
        self.dateBtn.text=[NSString stringWithFormat:@"  %@",selectedDateString];
    }
    
}
-(void)punchDateDoneClicked
{
    CLS_LOG(@"-----Done Action on PunchEntryViewController -----");
    [self.datePicker removeFromSuperview];
    [self.punchDatePicker removeFromSuperview];
    [self.toolbar removeFromSuperview];
    
}
-(void)pickerCancel:(id)sender
{
    [self.toolbar removeFromSuperview];
    [self.datePicker removeFromSuperview];
    [self.punchDatePicker removeFromSuperview];
    NSArray *toolArray = [NSArray arrayWithObjects:spaceButton, doneButton,nil];
    [toolbar setItems:toolArray];
    [self updatePunchDateFieldWithPickerChange:self.previousDateValue];
}

-(void)dismissCameraView
{
    
}
//MOBI-829//TestCase
-(NSString *)checkForTrasferWithActvityPermission:(BOOL)activityPermission forSegmentCtrl :(UIView*) myView
{
    if ([myView isKindOfClass:[UISegmentedControl class]])
    {
        UISegmentedControl* label = (UISegmentedControl*)myView;
        if (activityPermission)
        {
            NSString *string=[label titleForSegmentAtIndex:2];
            return string;
        }
        
    }
    return nil;
}


-(void)sendRequestToRecalculateScriptDataWithDataDict:(NSDictionary *)dateDict
{
    NSString *userID=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserUri"];
    
    if (self.punchObj.punchUserUri!=nil && ![self.punchObj.punchUserUri isKindOfClass:[NSNull class]])
    {
        userID=self.punchObj.punchUserUri;
    }
    
    if(userID!=nil)
    {
        [[RepliconServiceManager calculatePunchTotalService] sendRequestToRecalculateScriptDataForuserUri:userID WithDate:dateDict];
    }
}



@end
