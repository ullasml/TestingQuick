//
//  PunchMapViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 11/03/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "PunchMapViewController.h"
#import "Constants.h"
#import "MapAnnotation.h"
#import "RepliconServiceManager.h"
#import "FrameworkImport.h"
#import "AppDelegate.h"
#import "LoginModel.h"
#import "CameraCaptureViewController.h"
#import "AttendanceModel.h"
#import "UIImageView+AFNetworking.h"
#import "ListOfTimeSheetsViewController.h"
#import "ListOfExpenseSheetsViewController.h"
#import "ListOfBookedTimeOffViewController.h"
#import "AttendanceViewController.h"
#import "TeamTimeViewController.h"
#import "ShiftsViewController.h"
#import "ApprovalsCountViewController.h"
#import "MoreViewController.h"
#import "UIView+Additions.h"

#define CLOCKED_IN_OUT_HEADER_HEIGHT 50.0f
#define IMAGE_DETAIL_VIEW_HEIGHT 50.0f
#define PROJECT_DETAIL_VIEW_HEIGHT 50.0f
#define xOFFSET 15.0f
#define yOFFSET 15.0f
#define MAP_VIEW_HEIGHT 150.0f
#define LOCATION_INFO_VIEW_HEIGHT 70.0f
#define OK_TITLE_VIEW_HEIGHT 50.0f
#define LOCATION_NO_INFO_AVAILABLE_VIEW_HEIGHT 30.0f


@implementation PunchMapViewController
@synthesize isClockIn;
@synthesize clockUserImage;
@synthesize delegate;
@synthesize locationInfoLabel;
@synthesize mapView;
@synthesize punchMapView;
@synthesize projectInfoDict;
@synthesize punchTime;
@synthesize punchTimeAmPm;
@synthesize activityView;
@synthesize timePunchDataDict;
@synthesize locationDict;
@synthesize _parentDelegate;



@synthesize originalClockUserImage;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.view.backgroundColor = [Util colorWithHex:@"#000000" alpha:0.7];
    [Util setToolbarLabel:self withText: RPLocalizedString(PunchLocatioTabbarTitle, @"") ];


    [self addMapView];

    [self setMapLocation];
    
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIBarButtonItem *tempLeftButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(BACK_STRING, @"")
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(cancelAction:)];
    [[self navigationItem ] setLeftBarButtonItem:tempLeftButtonOuterBtn animated:NO];
}


-(void)checkForLocation
{
    [[NSNotificationCenter defaultCenter] removeObserver: self name: PUNCH_RESPONSE_RECEIVED_NOTIFICATION object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(punchResponseReceivedAction:)
                                                 name: PUNCH_RESPONSE_RECEIVED_NOTIFICATION
                                               object: nil];
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    AttendanceViewController *ctrl=(AttendanceViewController *)_parentDelegate;
    
    LoginModel *loginModel=[[LoginModel alloc]init];
    BOOL isLocationAccess=[loginModel getStatusForGivenPermissions:@"timepunchGeolocationRequired"];
    if (isLocationAccess)
    {
        [ctrl getAddress:appDelegate.locationManagerTemp fromDelegate:self];
    }
    
    
    
    
    CLS_LOG(@"-----Punch Request made to the server -----");
    
/*
    
    BOOL isProjectAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchProjectAccess"];
    BOOL isActivityAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchActivityAccess"];
    BOOL isBillingAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchBillingAccess"];
    BOOL isBreakAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchBreakAccess"];
    
    NSString *breakUri=[projectInfoDict objectForKey:@"breakUri"];
    BOOL isBreakRow=FALSE;
    if (breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]]&&![breakUri isEqualToString:@""])
    {
        if (isBreakAccess)
        {
            isBreakRow=TRUE;
        }
    }
    if (isProjectAccess || isActivityAccess || isBillingAccess || isBreakRow)
    {
        if([projectInfoDict objectForKey:@"ATTENDANCE_uniqueID"]==nil)
        {
            if ([projectInfoDict objectForKey:@"clientName"]!=nil)
            {
                [dict setObject:[projectInfoDict objectForKey:@"clientName"] forKey:@"client"];
            }
            if ([projectInfoDict objectForKey:@"clientUri"]!=nil)
            {
                [dict setObject:[projectInfoDict objectForKey:@"clientUri"] forKey:@"clientUri"];
            }
            if ([projectInfoDict objectForKey:@"projectName"]!=nil)
            {
                [dict setObject:[projectInfoDict objectForKey:@"projectName"] forKey:@"project"];
            }
            if ([projectInfoDict objectForKey:@"projectUri"]!=nil)
            {
                [dict setObject:[projectInfoDict objectForKey:@"projectUri"] forKey:@"projectUri"];
            }
            if ([projectInfoDict objectForKey:@"taskName"]!=nil)
            {
                [dict setObject:[projectInfoDict objectForKey:@"taskName"] forKey:@"task"];
            }
            if ([projectInfoDict objectForKey:@"taskUri"]!=nil)
            {
                [dict setObject:[projectInfoDict objectForKey:@"taskUri"] forKey:@"taskUri"];
            }
            if ([projectInfoDict objectForKey:@"activityName"]!=nil)
            {
                [dict setObject:[projectInfoDict objectForKey:@"activityName"] forKey:@"activity"];
            }
            if ([projectInfoDict objectForKey:@"activityUri"]!=nil)
            {
                [dict setObject:[projectInfoDict objectForKey:@"activityUri"] forKey:@"activityUri"];
            }
            if ([projectInfoDict objectForKey:@"breakName"]!=nil)
            {
                [dict setObject:[projectInfoDict objectForKey:@"breakName"] forKey:@"break"];
            }
            if ([projectInfoDict objectForKey:@"breakUri"]!=nil)
            {
                [dict setObject:[projectInfoDict objectForKey:@"breakUri"] forKey:@"breakUri"];
            }
            
            [self sendBreakPunchForDataWithAutoPunchOut:[NSMutableDictionary dictionaryWithDictionary:dict]];
        }
    }
    
 */   
    if (locationDict==nil ||[locationDict isKindOfClass:[NSNull class]]||![[locationDict objectForKey:@"available"] boolValue] )
    {
        
    }
    else
    {
        
    }
    
    
    [delegate dismissCameraView];
    
    
    if (locationDict==nil ||[locationDict isKindOfClass:[NSNull class]]||![[locationDict objectForKey:@"available"] boolValue] || !isLocationAccess )
    {
        
        
        [self performSelector:@selector(geoAddressReceived:) withObject:self.locationDict afterDelay:0.3];
    }
    
    
    
}


/*-(UIView*)createViewWithLocationAvailable:(BOOL)isLocationAvailable isResponseReceived:(BOOL)isResponseReceived LocationStr:(NSString *)locationStr
{
    [self.punchMapView removeFromSuperview];
    float viewHeight=0.0;
    LoginModel *loginModel=[[LoginModel alloc]init];
    BOOL isLocationAccess=[loginModel getStatusForGivenPermissions:@"timepunchGeolocationRequired"];
    
    
    UIView *lastPunchDetailView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, 290, 60)];
    [lastPunchDetailView setBackgroundColor:[UIColor whiteColor]];
    
    
    //ImageView
    UIView *imageDetailView=[[UIView alloc]initWithFrame:CGRectMake(0, clockedInOrOutLblBgndView.frame.size.height, SCREEN_WIDTH-2*xOFFSET, IMAGE_DETAIL_VIEW_HEIGHT)];
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
    
    UILabel *projectActivityLabel=[[UILabel alloc]initWithFrame:CGRectMake(xOFFSET, 6, SCREEN_WIDTH-2*xOFFSET-20,20)];
    [projectActivityLabel setTextAlignment:NSTextAlignmentLeft];
    [projectActivityLabel setBackgroundColor:[UIColor clearColor]];
    [projectActivityLabel setNumberOfLines:1];
    [projectActivityLabel setTextColor:[Util colorWithHex:@"#999999" alpha:1]];
    [projectActivityLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
    
    
    UILabel *projectActivityValueLabel=[[UILabel alloc]initWithFrame:CGRectMake(xOFFSET, 23, SCREEN_WIDTH-2*xOFFSET-20,20)];
    [projectActivityValueLabel setTextAlignment:NSTextAlignmentLeft];
    [projectActivityValueLabel setBackgroundColor:[UIColor clearColor]];
    [projectActivityValueLabel setNumberOfLines:1];
    [projectActivityValueLabel setTextColor:RepliconStandardBlackColor];
    [projectActivityValueLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
    
    
    BOOL isProjectAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchProjectAccess"];
    BOOL isActivityAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchActivityAccess"];
    BOOL isBillingAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchBillingAccess"];
    BOOL isBreakAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchBreakAccess"];
    
    //    BOOL isProjectAccess=NO;
    //    BOOL isActivityAccess=NO;
    //    BOOL isBillingAccess=NO;
    //    BOOL isBreakAccess=NO;
    
    BOOL isActivityOnly=NO;
    BOOL isBreakOnly=NO;
    BOOL isProject=NO;
    
    NSString *activityName=[projectInfoDict objectForKey:@"activityName"];
    NSString *projectName=[projectInfoDict objectForKey:@"projectName"];
    NSString *breakName=[projectInfoDict objectForKey:@"breakName"];
    
    NSString *breakUri=[projectInfoDict objectForKey:@"breakUri"];
    BOOL isBreakRow=FALSE;
    if (breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]]&&![breakUri isEqualToString:@""])
    {
        isBreakRow=TRUE;
    }
    
    if (!isProjectAccess && !isBillingAccess && isActivityAccess && !isBreakRow)
    {
        isActivityOnly=YES;
    }
    else if (isProjectAccess && !isBreakRow)
    {
        isProject=YES;
    }
    else if (isBreakAccess &&  isBreakRow)
    {
        isBreakOnly=YES;
    }
    
    
    
    
    BOOL showDetailView=FALSE;
    
    if (breakName!=nil && ![breakName isKindOfClass:[NSNull class]]&& ![breakName isEqualToString:@""] && isBreakOnly)
    {
        [projectActivityLabel setText:RPLocalizedString(BREAK_ENTRY, @"")];
        [projectActivityValueLabel setText:breakName];
        showDetailView=TRUE;
    }
    else if (activityName!=nil && ![activityName isKindOfClass:[NSNull class]]&& ![activityName isEqualToString:@""] && isActivityOnly)
    {
        [projectActivityLabel setText:RPLocalizedString(Activity, @"")];
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
            [projectActivityLabel setText:RPLocalizedString(Activity, @"")];
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
    
    float projectDetailViewHeight=PROJECT_DETAIL_VIEW_HEIGHT;
    float locationViewHeight=0.0;
    if (!showDetailView)
    {
        projectDetailViewHeight=0.0;
    }
    
    if (isLocationAvailable)
    {
        locationViewHeight=MAP_VIEW_HEIGHT+LOCATION_INFO_VIEW_HEIGHT;
    }
    else
    {
        locationViewHeight=LOCATION_NO_INFO_AVAILABLE_VIEW_HEIGHT;
    }
    
    if (!isLocationAccess)
    {
        locationViewHeight=-10.0;
    }
    
    
    viewHeight=CLOCKED_IN_OUT_HEADER_HEIGHT+IMAGE_DETAIL_VIEW_HEIGHT+projectDetailViewHeight+locationViewHeight+OK_TITLE_VIEW_HEIGHT;
    
    CGRect screenRect =[[UIScreen mainScreen] bounds];
    
    
    //   self.punchMapView=[[UIView alloc]initWithFrame:CGRectMake(xOFFSET, (screenRect.size.height-viewHeight-offset)/2, SCREEN_WIDTH-2*xOFFSET, viewHeight)];
    [punchMapView setBackgroundColor:[UIColor clearColor]];
    
    self.punchMapView=[[UIView alloc]initWithFrame:CGRectMake(xOFFSET, (screenRect.size.height-viewHeight)/2, SCREEN_WIDTH-2*xOFFSET, viewHeight)];
    self.punchMapView.layer.borderColor = [UIColor blackColor].CGColor;
    self.punchMapView.layer.borderWidth = 0.5f;
    [self.punchMapView.layer setCornerRadius:5.0f];
    // drop shadow
    [self.punchMapView.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.punchMapView.layer setShadowOpacity:0.8];
    [self.punchMapView.layer setShadowRadius:3.0];
    [self.punchMapView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
    //   [punchMapView setBackgroundColor:[UIColor orangeColor]];
    
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: punchMapView.bounds byRoundingCorners: UIRectCornerAllCorners cornerRadii: (CGSize){5, 5}].CGPath;
    punchMapView.layer.mask = maskLayer;
    
    UIImageView *clockedInOrOutLblBgndView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-2*xOFFSET, CLOCKED_IN_OUT_HEADER_HEIGHT)];
    
    if (isResponseReceived)
    {
        if (isClockIn)
        {
            [clockedInOrOutLblBgndView setImage:[Util thumbnailImage:CLOCKED_IN_BACKGROUND_IMAGE]];
        }
        else
        {
            [clockedInOrOutLblBgndView setImage:[Util thumbnailImage:CLOCKED_OUT_BACKGROUND_IMAGE]];
        }
    }
    else
    {
        [clockedInOrOutLblBgndView setImage:[Util thumbnailImage:CLOCKING_BACKGROUND_IMAGE]];
    }
    
    
    UILabel *clockedInOrOutLbl=[[UILabel alloc]initWithFrame:CGRectMake(xOFFSET, 0, SCREEN_WIDTH-2*xOFFSET, CLOCKED_IN_OUT_HEADER_HEIGHT)];
    [clockedInOrOutLbl setBackgroundColor:[UIColor clearColor]];
    if (isResponseReceived)
    {
        if (isClockIn)
        {
            [clockedInOrOutLbl setText:RPLocalizedString(CLOCKED_IN_HEADER,@"")];
        }
        else
        {
            [clockedInOrOutLbl setText:RPLocalizedString(CLOCKED_OUT_HEADER,@"")];
        }
    }
    else
    {
        
        if (isClockIn)
        {
            [clockedInOrOutLbl setText:RPLocalizedString(CLOCKING_IN_HEADER,@"")];
        }
        else
        {
            [clockedInOrOutLbl setText:RPLocalizedString(CLOCKING_OUT_HEADER,@"")];
        }
        
    }
    
    
    [clockedInOrOutLbl setTextColor:RepliconStandardWhiteColor];
    [clockedInOrOutLbl setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_17]];
    [clockedInOrOutLblBgndView addSubview:clockedInOrOutLbl];
    [punchMapView addSubview:clockedInOrOutLblBgndView];
    
    
    
    
    UILabel *atLabel=[[UILabel alloc]initWithFrame:CGRectMake(xAtLabel, 17, 15, 20)];
    [atLabel setText:RPLocalizedString(AT_STRING,@"")];
    [atLabel setBackgroundColor:[UIColor clearColor]];
    [atLabel setTextColor:[Util colorWithHex:@"#999999" alpha:1.0]];
    [atLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
    [imageDetailView addSubview:atLabel];
    
    UILabel *timeLabel=[[UILabel alloc]initWithFrame:CGRectMake(xAtLabel+10+atLabel.frame.size.width, 15,45, 20)];
    [timeLabel setText:punchTime];
    [timeLabel setBackgroundColor:[UIColor clearColor]];
    [timeLabel setTextColor:RepliconStandardBlackColor];
    [timeLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_17]];
    [imageDetailView addSubview:timeLabel];
    
    UILabel *ampmLabel=[[UILabel alloc]initWithFrame:CGRectMake(xAtLabel+10+atLabel.frame.size.width+timeLabel.frame.size.width+5, 12, 100, 20)];
    [ampmLabel setText:[punchTimeAmPm uppercaseString]];
    [ampmLabel setTextColor:RepliconStandardBlackColor];
    [ampmLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_08]];
    [imageDetailView addSubview:ampmLabel];
    
    [punchMapView addSubview:imageDetailView];
    
    
    //Activity information View
    UIView *activityDetailView=[[UIView alloc]initWithFrame:CGRectMake(0, imageDetailView.frame.origin.y+imageDetailView.frame.size.height, SCREEN_WIDTH-2*xOFFSET, PROJECT_DETAIL_VIEW_HEIGHT)];
    [activityDetailView setBackgroundColor:RepliconStandardWhiteColor];
    
    
    UIImageView *separatorImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, activityDetailView.frame.size.width, 1)];
    [separatorImage setImage:[Util thumbnailImage:LOCKED_IN_OUT_SEPARAROR_IMAGE]];
    [activityDetailView addSubview:separatorImage];
    
    
   UIView *mapDetailView=[[UIView alloc]init];
    //map information View
    float height=0;
    if (isLocationAvailable && locationViewHeight>0)
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
        
        [punchMapView addSubview:activityDetailView];
        
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
    
    self.locationInfoLabel=[[UILabel alloc]init];
    [self.locationInfoLabel setTextAlignment:NSTextAlignmentCenter];
    if (isLocationAvailable)
    {
        self.mapView=[[MKMapView alloc]initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH-2*xOFFSET-20, MAP_VIEW_HEIGHT)];
        self.mapView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        self.mapView.layer.borderWidth = 0.5;
        [self.mapView setMapType:MKMapTypeStandard];
        [self.mapView setZoomEnabled:YES];
        [self.mapView setScrollEnabled:YES];
        [self.mapView setDelegate:self];
        [mapDetailView addSubview:self.mapView];
        
        locationInfoLabel.frame=CGRectMake(xOFFSET, mapView.frame.origin.y+mapView.frame.size.height+10, SCREEN_WIDTH-2*xOFFSET-20,LOCATION_INFO_VIEW_HEIGHT-20);
        [self.locationInfoLabel setText:locationStr];
        
    }
    else
    {
        UIImage *noLocationImage=[UIImage imageNamed:LOCATION_DISABLED_IMAGE];
        UIImageView *noLocationImageView=[[UIImageView alloc]initWithFrame:CGRectMake(xOFFSET, 10, noLocationImage.size.width, noLocationImage.size.height)];
        [noLocationImageView setImage:noLocationImage];
        [mapDetailView addSubview:noLocationImageView];
        [self.locationInfoLabel setTextAlignment:NSTextAlignmentLeft];
        locationInfoLabel.frame=CGRectMake(xOFFSET+noLocationImage.size.width+10, 15, SCREEN_WIDTH-2*xOFFSET-20,LOCATION_NO_INFO_AVAILABLE_VIEW_HEIGHT-20);
        [self.locationInfoLabel setText:RPLocalizedString(LOCATION_UNAVAILABLE_STRING, @"")];
    }
    
    [self.locationInfoLabel setBackgroundColor:[UIColor clearColor]];
    
    [self.locationInfoLabel setNumberOfLines:3];
    [self.locationInfoLabel setTextColor:RepliconStandardBlackColor];
    [self.locationInfoLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
    [mapDetailView addSubview:self.locationInfoLabel];
    
    if (locationViewHeight>0.0)
    {
        [punchMapView addSubview:mapDetailView];
    }
    
    
    
    
    //ok button View
    UIView *okButtonView=[[UIView alloc]init];
    if (locationViewHeight>0.0)
    {
        okButtonView.frame=CGRectMake(0, mapDetailView.frame.origin.y+mapDetailView.frame.size.height, SCREEN_WIDTH-2*xOFFSET,OK_TITLE_VIEW_HEIGHT);
    }
    else
    {
        if (showDetailView)
        {
            okButtonView.frame=CGRectMake(0, activityDetailView.frame.origin.y+activityDetailView.frame.size.height, SCREEN_WIDTH-2*xOFFSET,OK_TITLE_VIEW_HEIGHT);
            
        }
        else
        {
            okButtonView.frame=CGRectMake(0, imageDetailView.frame.origin.y+imageDetailView.frame.size.height, SCREEN_WIDTH-2*xOFFSET,OK_TITLE_VIEW_HEIGHT);
            
        }
        
    }
    [okButtonView setBackgroundColor:RepliconStandardWhiteColor];
    UIImageView *okButtonSeparatorImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, mapDetailView.frame.size.width, 1)];
    [okButtonSeparatorImage setImage:[Util thumbnailImage:LOCKED_IN_OUT_SEPARAROR_IMAGE]];
    [okButtonView addSubview:okButtonSeparatorImage];
    
    if (isResponseReceived)
    {
        UIButton *okBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-2*xOFFSET,40)];
        okBtn.backgroundColor = [UIColor clearColor];
        okBtn.titleLabel.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_17];
        okBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [okBtn setTitle:RPLocalizedString(@"OK", @"") forState:UIControlStateNormal];
        [okBtn addTarget:delegate action:@selector(dismissCameraView) forControlEvents:UIControlEventTouchUpInside];
        [okBtn setTitleColor:RepliconStandardBlueColor forState:UIControlStateNormal];
        [okButtonView addSubview:okBtn];
    }
    else
    {
        [self.activityView removeFromSuperview];
        self.activityView=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.activityView setFrame:CGRectMake((okButtonView.frame.size.width/2)-16, 5, 32, 32)];
        [okButtonView addSubview:self.activityView];
        [self.activityView startAnimating];
    }
    
    [delegate dismissCameraView];
    
    [punchMapView addSubview:okButtonView];
    
    //[self.view addSubview:punchMapView];
}*/

-(UIView*)createViewWithLocationAvailable:(NSDictionary*)response
{
    float y_offset_for_all = 60.0;

    LoginModel *loginModel=[[LoginModel alloc]init];
    BOOL isLocationAccess=[loginModel getStatusForGivenPermissions:@"timepunchGeolocationRequired"];
    BOOL isActivityAccess=[loginModel getStatusForGivenPermissions:@"hasTimepunchActivityAccess"];
    
    UIView *punchDetailView = [[UIView alloc] initWithFrame:CGRectMake(xOFFSET, 50, self.view.width-(2*xOFFSET), self.view.height)];
    [punchDetailView setBackgroundColor:[Util colorWithHex:@"#E2E2E2" alpha:1.0]];
    
    UIView *lastPunchDetailView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, punchDetailView.width, 60)];
    [lastPunchDetailView setBackgroundColor:RepliconStandardWhiteColor];
    

    if (isLocationAccess) {
        lastPunchDetailView.frame = CGRectMake(0, 0, punchDetailView.width, 110);
    }
    
    //ImageView
    NSString *imageLink= [response objectForKey:@"thumbnail_image_link"];
    NSString *imageUri= [response objectForKey:@"thumbnail_image_uri"];

    BOOL isImageAvailable = false;;

    // load images progressively using AFNetworking
    if (imageLink !=nil  && ![imageLink isKindOfClass:[NSNull class]] && imageUri !=nil  && ![imageUri isKindOfClass:[NSNull class]] && ![imageLink isEqualToString:@""] && ![imageUri isEqualToString:@""])
    {
        isImageAvailable = true;
         UIImageView *tempClockUserImage=[[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
        __weak UIImageView *weakClockUserImage = tempClockUserImage;
        [tempClockUserImage setImageWithURLRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:imageLink]]
    placeholderImage:[UIImage imageNamed:@"bg_punchImagePlaceholder"]
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
        weakClockUserImage.image = image;
    }
    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error){
        
    }];
         [lastPunchDetailView addSubview:tempClockUserImage];
    }
    
    UIImage *tempImage = [UIImage imageNamed:@"icon_IN-Tag-Green"];
    
    UIImageView *clockedInOrOutOrBreakLblBgndView=[[UIImageView alloc]initWithFrame:CGRectMake(65, 12, tempImage.size.width, tempImage.size.height)];
    
    UILabel *clockedInOrOutLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, -4, tempImage.size.width, tempImage.size.width)];
    [clockedInOrOutLbl setBackgroundColor:[UIColor clearColor]];
    [clockedInOrOutLbl setTextAlignment:NSTextAlignmentCenter];
    [clockedInOrOutLbl setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_09]];
    [clockedInOrOutLbl setTextColor:RepliconStandardWhiteColor];
    
    NSString *actionUri = [response objectForKey:@"actionUri"];
    
    
    if ([actionUri isEqualToString:PUNCH_IN_URI])
    {
        [clockedInOrOutOrBreakLblBgndView setImage:[UIImage imageNamed:@"icon_IN-Tag-Green"]];
        [clockedInOrOutLbl setText:RPLocalizedString(IN_TEXT,@"")];
    }
    else if([actionUri isEqualToString:PUNCH_OUT_URI])
    {
        [clockedInOrOutOrBreakLblBgndView setImage:[UIImage imageNamed:@"icon_OUT-Tag-Gray"]];
        [clockedInOrOutLbl setText:RPLocalizedString(OUT_TEXT,@"")];
        [clockedInOrOutLbl setTextColor:RepliconStandardBlackColor];
    }
    else if([actionUri isEqualToString:PUNCH_START_BREAK_URI])
    {
        [clockedInOrOutOrBreakLblBgndView setImage:[UIImage imageNamed:@"icon_Break-Tag-Yellow"]];
        [clockedInOrOutLbl setText:@""];
    }
    else{
        [clockedInOrOutOrBreakLblBgndView setImage:[UIImage imageNamed:@"icon_IN-Tag-Green"]];
        [clockedInOrOutLbl setText:RPLocalizedString(IN_TEXT,@"")];
    }
    

    [clockedInOrOutOrBreakLblBgndView addSubview:clockedInOrOutLbl];
    [lastPunchDetailView addSubview:clockedInOrOutOrBreakLblBgndView];

    
    NSString *dateStr=[response objectForKey:@"entry_date"];
    
    //NSString *entryDate = [[Util convertApiTimeDictToDateStringWithDesiredFormat:entryDateDict] isKindOfClass:[NSNull class]] ? @"": [Util convertApiTimeDictToDateStringWithDesiredFormat:entryDateDict];
    
    NSString *timeString=[response objectForKey:@"time"];
    NSString *formatString=[response objectForKey:@"time_format"];

    
    float timeStringHeight = [self getHeightForString:timeString fontSize:RepliconFontSize_18 forWidth:lastPunchDetailView.width];
    float formatStringHeight = [self getHeightForString:formatString fontSize:RepliconFontSize_09 forWidth:lastPunchDetailView.width];
    float dateStringHeight = [self getHeightForString:dateStr fontSize:RepliconFontSize_12  forWidth:lastPunchDetailView.width];

    
    UILabel *timeLabel=[[UILabel alloc]initWithFrame:CGRectMake(100, 10,lastPunchDetailView.width-100, timeStringHeight)];
    [timeLabel setText:timeString];
    [timeLabel setBackgroundColor:[UIColor clearColor]];
    [timeLabel setTextColor:RepliconStandardBlackColor];
    [timeLabel setTextAlignment:NSTextAlignmentLeft];
    [timeLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_18]];
    [lastPunchDetailView addSubview:timeLabel];
    
    UILabel *formatLabel=[[UILabel alloc]initWithFrame:CGRectMake(150, 12,lastPunchDetailView.width-150, formatStringHeight)];
    [formatLabel setText:[formatString uppercaseString]];
    [formatLabel setBackgroundColor:[UIColor clearColor]];
    [formatLabel setTextColor:RepliconStandardBlackColor];
    [formatLabel setTextAlignment:NSTextAlignmentLeft];
    [formatLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_09]];
    [lastPunchDetailView addSubview:formatLabel];

    
    UILabel *dateLabel=[[UILabel alloc]initWithFrame:CGRectMake(65, 15+timeStringHeight,lastPunchDetailView.width-65, dateStringHeight)];
    
    NSString *dateString=[NSString stringWithFormat:@"%@ %@", RPLocalizedString(ON_TEXT, @""), dateStr];
    if ([response objectForKey:@"agentTypeName"]!=nil && ![[response objectForKey:@"agentTypeName"] isKindOfClass:[NSNull class]])
    {
        dateString = [dateString stringByAppendingString:[NSString stringWithFormat:@" - %@ %@",RPLocalizedString(VIA_MOBILE_TEXT, @""),[response objectForKey:@"agentTypeName"]]];
    }
    
    
    
    [dateLabel setText:[NSString stringWithFormat:@"%@", dateString]];
    [dateLabel setTextColor:[Util colorWithHex:@"#999999" alpha:1.0]];
    [dateLabel setTextAlignment:NSTextAlignmentLeft];
    [dateLabel setBackgroundColor:[UIColor clearColor]];
    [dateLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
    [lastPunchDetailView addSubview:dateLabel];


    if (!isImageAvailable) {
        clockedInOrOutOrBreakLblBgndView.frame = CGRectMake(10, 12, tempImage.size.width, tempImage.size.height);
        timeLabel.frame = CGRectMake(45, 10,lastPunchDetailView.width-45, timeStringHeight);
        formatLabel.frame = CGRectMake(95, 12,lastPunchDetailView.width-95, formatStringHeight);
        dateLabel.frame = CGRectMake(10, 15+timeStringHeight,lastPunchDetailView.width-10, dateStringHeight);
    }
    
    /*UILabel *ampmLabel=[[UILabel alloc]initWithFrame:CGRectMake(xAtLabel+10+timeLabel.frame.size.width+timeLabel.frame.size.width+5, 12, 100, 20)];
    [ampmLabel setText:[punchTimeAmPm uppercaseString]];
    [ampmLabel setTextColor:RepliconStandardBlackColor];
    [ampmLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_09]];
    [lastPunchDetailView addSubview:ampmLabel];*/


    UILabel *locationLabel=[[UILabel alloc]init];
    NSString *tempLocationDict = [response objectForKey:@"address"];
    UIImage *locationImage=[UIImage imageNamed:LOCATION_ENABLED_IMAGE];
    UIImageView *LocationImageView=[[UIImageView alloc]initWithFrame:CGRectMake(xOFFSET, 73, locationImage.size.width, locationImage.size.height)];
    
        if (tempLocationDict!=nil  && ![tempLocationDict isKindOfClass:[NSNull class]] && ![tempLocationDict isEqualToString:@""] && ![tempLocationDict isEqualToString:@"<null>"])
        {
            UIImage *locationImage=[UIImage imageNamed:LOCATION_ENABLED_IMAGE];
            [LocationImageView setImage:locationImage];
            [lastPunchDetailView addSubview:LocationImageView];
            NSString *addressString = tempLocationDict;
            float locationStringHeight = [self getHeightForString:addressString fontSize:RepliconFontSize_12  forWidth:lastPunchDetailView.width-xOFFSET-locationImage.size.width-27];
            
            
            if (locationStringHeight<15.0)
            {
                locationStringHeight=30.0;
            }
            else
            {
                locationStringHeight=40.0;
            }
            
            locationLabel.frame=CGRectMake(xOFFSET+locationImage.size.width+5, 65, lastPunchDetailView.width-xOFFSET-locationImage.size.width-27,locationStringHeight);
            [locationLabel setText:addressString];
            [locationLabel setNumberOfLines:2];
            
       }
        else{
            UIImage *noLocationImage=[UIImage imageNamed:LOCATION_DISABLED_IMAGE];
            [LocationImageView setImage:noLocationImage];
            [lastPunchDetailView addSubview:LocationImageView];
            [locationLabel setTextAlignment:NSTextAlignmentLeft];
            locationLabel.frame=CGRectMake(xOFFSET+noLocationImage.size.width+5, 67, lastPunchDetailView.width-xOFFSET-noLocationImage.size.width-27,30);
            [locationLabel setText:RPLocalizedString(LOCATION_UNAVAILABLE_STRING, @"")];
            [locationLabel setNumberOfLines:1];
        }
    
  //      float viaStringHeight = [self getHeightForString:VIA_MOBILE_TEXT fontSize:RepliconFontSize_12  forWidth:280];

        
        [locationLabel setBackgroundColor:[UIColor clearColor]];
        
    
        [locationLabel setTextColor:RepliconStandardBlackColor];
        [locationLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
        
//        UILabel *agentTypeLabel=[[UILabel alloc]initWithFrame:CGRectMake(locationLabel.frame.origin.x, 90, SCREEN_WIDTH,viaStringHeight)];
//        [agentTypeLabel setTextAlignment:NSTextAlignmentLeft];
//        [agentTypeLabel setBackgroundColor:[UIColor clearColor]];
//        [agentTypeLabel setNumberOfLines:1];
//        [agentTypeLabel setTextColor:[Util colorWithHex:@"#999999" alpha:1]];
//        [agentTypeLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
//        [agentTypeLabel setText:[NSString stringWithFormat:@"%@ %@",RPLocalizedString(VIA_MOBILE_TEXT, @""),[response objectForKey:@"agentTypeName"]]];
    
        y_offset_for_all =  y_offset_for_all+50;

        [lastPunchDetailView addSubview:locationLabel];
//        [lastPunchDetailView addSubview:agentTypeLabel];
    
        if (!isLocationAccess && (tempLocationDict==nil || [tempLocationDict isKindOfClass:[NSNull class]] || [tempLocationDict isEqualToString:@""] || [tempLocationDict isEqualToString:@"<null>"])) {
            [LocationImageView removeFromSuperview];
            [locationLabel removeFromSuperview];
//            [agentTypeLabel removeFromSuperview];
            y_offset_for_all =  y_offset_for_all-50;
        }
    
        if (tempLocationDict!=nil  && ![tempLocationDict isKindOfClass:[NSNull class]] && ![tempLocationDict isEqualToString:@""] && ![tempLocationDict isEqualToString:@"<null>"])
        {
            UIButton *locationButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 60, lastPunchDetailView.width, 50)];
            [locationButton setBackgroundColor:[UIColor clearColor]];
            [locationButton addTarget:delegate action:@selector(goToMapView) forControlEvents:UIControlEventTouchUpInside];
            [lastPunchDetailView addSubview:locationButton];
            UIImage *disclosureImage = [UIImage imageNamed:Disclosure_Box];
            UIImageView *disclosureImageView = [[UIImageView alloc] initWithFrame:CGRectMake(locationLabel.right, 15, disclosureImage.size.width,disclosureImage.size.height)];
            [disclosureImageView setImage:disclosureImage];
            [locationButton addSubview:disclosureImageView];
        }



    float XOffset_activityLabel = 15;
    

    
    NSString *activityName= [response objectForKey:@"activityName"];
//    NSString *activityUri= [response objectForKey:@"activityUri"];
    
    float valueStringHeight = 0.0;
    
    
    if (isActivityAccess)
    {
        if ([activityName isKindOfClass:[NSNull class]] || activityName ==nil )
        {
            activityName=RPLocalizedString(NONE_STRING, NONE_STRING);
        }
        else if ([activityName isEqualToString:@""])
        {
            activityName=RPLocalizedString(NONE_STRING, NONE_STRING);
        }
        
    }
   
    if([actionUri isEqualToString:PUNCH_OUT_URI])
    {
        activityName=nil;
    }
    
    
    
    if (![activityName isKindOfClass:[NSNull class]] && activityName !=nil && ![activityName isEqualToString:@""] ) {
            valueStringHeight = [self getHeightForString:activityName fontSize:RepliconFontSize_16 forWidth:lastPunchDetailView.width];
    }
    
    NSString *breakType= [response objectForKey:@"breakType"];
   
    
    
    if([actionUri isEqualToString:PUNCH_OUT_URI])
    {
        breakType=nil;
        
    }

    
    
    if (![breakType isKindOfClass:[NSNull class]] && breakType !=nil && ![breakType isEqualToString:@""]) {
        valueStringHeight = [self getHeightForString:breakType fontSize:RepliconFontSize_16 forWidth:lastPunchDetailView.width];
    }

    float actiStringHeight = [self getHeightForString:RPLocalizedString(Activity_Type, @"") fontSize:RepliconFontSize_12 forWidth:lastPunchDetailView.width];
    

    
    UILabel *projectActivityLabel=[[UILabel alloc]initWithFrame:CGRectMake(XOffset_activityLabel, y_offset_for_all+10, lastPunchDetailView.width-xOFFSET,actiStringHeight)];
    [projectActivityLabel setTextAlignment:NSTextAlignmentLeft];
    [projectActivityLabel setBackgroundColor:[UIColor clearColor]];
    [projectActivityLabel setNumberOfLines:1];
    [projectActivityLabel setTextColor:[Util colorWithHex:@"#999999" alpha:1]];
    [projectActivityLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
    
    
    
    
    UILabel *projectActivityValueLabel=[[UILabel alloc]initWithFrame:CGRectMake(XOffset_activityLabel, y_offset_for_all+projectActivityLabel.frame.size.height+10, lastPunchDetailView.width-xOFFSET,30.0)];
    [projectActivityValueLabel setTextAlignment:NSTextAlignmentLeft];
    [projectActivityValueLabel setBackgroundColor:[UIColor clearColor]];
    [projectActivityValueLabel setNumberOfLines:1];
    [projectActivityValueLabel setTextColor:RepliconStandardBlackColor];
    [projectActivityValueLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
    
    
    if (breakType!=nil && ![breakType isKindOfClass:[NSNull class]]&& ![breakType isEqualToString:@""])
    {
        [projectActivityLabel setText:RPLocalizedString(BREAK_ENTRY, @"")];
        [projectActivityValueLabel setText:breakType];
        lastPunchDetailView.frame = CGRectMake(0, 0, lastPunchDetailView.width, y_offset_for_all+55);
        [lastPunchDetailView addSubview:projectActivityLabel];
        [lastPunchDetailView addSubview:projectActivityValueLabel];
    }
    else if (activityName!=nil && ![activityName isKindOfClass:[NSNull class]]&& ![activityName isEqualToString:@""])
    {
        [projectActivityLabel setText:RPLocalizedString(Activity_Type, @"")];
        [projectActivityValueLabel setText:activityName];
        lastPunchDetailView.frame = CGRectMake(0, 0, lastPunchDetailView.width, y_offset_for_all+55);
        [lastPunchDetailView addSubview:projectActivityLabel];
        [lastPunchDetailView addSubview:projectActivityValueLabel];
    }
    
    if (((isLocationAccess || (tempLocationDict!=nil  && ![tempLocationDict isKindOfClass:[NSNull class]] && ![tempLocationDict isEqualToString:@""] && ![tempLocationDict isEqualToString:@"<null>"]))) || (breakType!=nil && ![breakType isKindOfClass:[NSNull class]]&& ![breakType isEqualToString:@""]) || (activityName!=nil && ![activityName isKindOfClass:[NSNull class]]&& ![activityName isEqualToString:@""])) {
        UIImageView *separatorImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 60, lastPunchDetailView.frame.size.width, 1)];
        [separatorImage setImage:[Util thumbnailImage:LOCKED_IN_OUT_SEPARAROR_IMAGE]];
        [lastPunchDetailView addSubview:separatorImage];
    }
    
    if (((breakType!=nil && ![breakType isKindOfClass:[NSNull class]]&& ![breakType isEqualToString:@""]) || (activityName!=nil && ![activityName isKindOfClass:[NSNull class]]&& ![activityName isEqualToString:@""])) && (isLocationAccess || (tempLocationDict!=nil  && ![tempLocationDict isKindOfClass:[NSNull class]] && ![tempLocationDict isEqualToString:@""]))) {
        UIImageView *separatorImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, 110, lastPunchDetailView.frame.size.width, 1)];
        [separatorImage setImage:[Util thumbnailImage:LOCKED_IN_OUT_SEPARAROR_IMAGE]];
        [lastPunchDetailView addSubview:separatorImage];
    }


    
    [punchDetailView addSubview:lastPunchDetailView];
    
    punchDetailView.frame = CGRectMake(xOFFSET, 50, self.view.width-(2*xOFFSET), lastPunchDetailView.frame.size.height+100);
    
    return punchDetailView;
    
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


-(void)punchResponseReceivedAction:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PUNCH_RESPONSE_RECEIVED_NOTIFICATION object:nil];
    [self.activityView stopAnimating];
    [self.activityView removeFromSuperview];
    BOOL isError=[[notification.userInfo objectForKey:@"isError"] boolValue];
    if (isError)
    {

        
        return;
    }
    
    CLS_LOG(@"-----Punch Request successfull from the server -----");
    
    
    
 
}

-(void)setMapLocation
{
    
    
    AttendanceModel *attendanceModel=[[AttendanceModel alloc]init];
    NSMutableArray *tempArray = [attendanceModel getLastPuncheFromDB];
    
    
    if (tempArray !=nil  && ![tempArray isKindOfClass:[NSNull class]]) {
        NSDictionary *responsedict = [tempArray objectAtIndex:0];
        CLLocationCoordinate2D location;
        
        location.latitude = [[responsedict objectForKey:@"latitude"] doubleValue];
        location.longitude = [[responsedict objectForKey:@"longitude"] doubleValue];
        
        
        MKCoordinateSpan span;
        MKCoordinateRegion region ;
        span.latitudeDelta = 0.01;//more value you set your zoom level will increase
        span.longitudeDelta =0.01;//more value you set your zoom level will increase
        //mapView.showsUserLocation=YES;
        region.span = span;
        MapAnnotation *newAnnotation = [[MapAnnotation alloc]init];
        region.center = location;
        newAnnotation.title=@"";
        newAnnotation.coordinate=location;
        [self.mapView addAnnotation:newAnnotation];
        [mapView setRegion:region animated:YES];
        [mapView regionThatFits:region];
        
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:location radius:100];
        [mapView addOverlay:circle];
    }
    
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKCircleRenderer *circleView = [[MKCircleRenderer alloc] initWithOverlay:overlay];
    //circleView.strokeColor= [UIColor blackColor];
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


-(void)geoAddressReceived:(NSMutableDictionary *)addressDict
{
    self.locationDict=addressDict;
    
    AttendanceViewController *attCtrl=(AttendanceViewController *)_parentDelegate;
    attCtrl.punchMapViewController=self;
    
    //Implementation for MOBI-728//JUHI

    [attCtrl setLocationDict:locationDict];
    [attCtrl setIsClockIn:isClockIn];
    [attCtrl setClockUserImage:clockUserImage];
    [attCtrl setProjectInfoDict:projectInfoDict];
    [attCtrl showPunchData:NO];
     [self sendPunchForData:projectInfoDict actionType:attCtrl.punchActionUri];
    
    

    
}


-(void)sendPunchForData:(NSMutableDictionary *)dataDict actionType:(NSString *)action
{
    
    
    
    
    if(![NetworkMonitor isNetworkAvailableForListener: self])
    {
        [Util showOfflineAlert];
        return;
    }
    
    
    AttendanceViewController *attCtrl=(AttendanceViewController *)_parentDelegate;
    attCtrl.punchMapViewController=self;

    
    
    
    
    
    
    
    

    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateComponents *dateComponents = [calendar components:( NSCalendarUnitYear |
                                                             NSCalendarUnitMonth |
                                                             NSCalendarUnitDay   |
                                                             NSCalendarUnitHour |
                                                             NSCalendarUnitMinute |
                                                             NSCalendarUnitSecond)
                                                   fromDate:currentDate];
    
    
    NSMutableDictionary *dict=[NSMutableDictionary dictionary];
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)[dateComponents day]] forKey:@"day"];
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)[dateComponents month]] forKey:@"month"];
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)[dateComponents year]] forKey:@"year"];
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)[dateComponents hour]] forKey:@"hour"];
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)[dateComponents minute]] forKey:@"minute"];
    [dict setObject:[NSString stringWithFormat:@"%ld",(long)[dateComponents second]] forKey:@"second"];
    [dict setObject:currentDate forKey:@"PunchDate"];
    [dataDict setObject:dict forKey:@"punchTimeDict"];
    self.timePunchDataDict=dict;
    NSData *dataReceipt = UIImagePNGRepresentation(originalClockUserImage);
    NSString *imgString= [Util encodeBase64WithData:dataReceipt];
    if (imgString==nil || [imgString isKindOfClass:[NSNull class]]||[imgString isEqualToString:@""])
    {
        [dataDict setObject:[NSNull null] forKey:@"imageData"];
        
    }
    else
    {
        [dataDict setObject:imgString forKey:@"imageData"];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver: self name: PUNCH_TIME_NOTIFICATION object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: _parentDelegate
                                             selector: @selector(handlePunchDataReceivedAction:)
                                                 name: PUNCH_TIME_NOTIFICATION
                                               object: nil];
    
    
   
     [[RepliconServiceManager attendanceService] sendRequestPunchDataToServiceForDataDict:dataDict actionType:action locationDict:locationDict withDelegate:attCtrl.punchMapViewController];
    
    
    
}







-(void)addMapView
{
    self.mapView=[[MKMapView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    self.mapView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    self.mapView.layer.borderWidth = 0.5;
    [self.mapView setMapType:MKMapTypeStandard];
    [self.mapView setZoomEnabled:YES];
    [self.mapView setScrollEnabled:YES];
    [self.mapView setDelegate:self];
    [self.view addSubview:self.mapView];
}

-(void)cancelAction:(id)sender
{
    
    [self.navigationController popViewControllerAnimated:YES];
    if([delegate isKindOfClass:[AttendanceViewController class]])
    {
        [delegate showLastPunchDataView];
    }
}


#pragma mark - ServiceURL Response Handling

- (void) serverDidRespondWithResponse:(id) response
{
    if (response!=nil)
    {
        NSDictionary *errorDict=[[response objectForKey:@"response"]objectForKey:@"error"];
        
        if (errorDict!=nil)
        {
            BOOL isErrorThrown=FALSE;
            
            
            NSArray *notificationsArr=[[errorDict objectForKey:@"details"] objectForKey:@"notifications"];
            NSString *errorMsg=@"";
            if (notificationsArr!=nil && ![notificationsArr isKindOfClass:[NSNull class]])
            {
                for (int i=0; i<[notificationsArr count]; i++)
                {
                    
                    NSDictionary *notificationDict=[notificationsArr objectAtIndex:i];
                    if (![errorMsg isEqualToString:@""])
                    {
                        errorMsg=[NSString stringWithFormat:@"%@\n%@",errorMsg,[notificationDict objectForKey:@"displayText"]];
                        isErrorThrown=TRUE;
                    }
                    else
                    {
                        errorMsg=[NSString stringWithFormat:@"%@",[notificationDict objectForKey:@"displayText"]];
                        isErrorThrown=TRUE;
                        
                    }
                }
                
            }
            
            if (!isErrorThrown)
            {
                errorMsg=[[errorDict objectForKey:@"details"] objectForKey:@"displayText"];
                
            }
            if (errorMsg!=nil && ![errorMsg isKindOfClass:[NSNull class]])
            {
                [Util errorAlert:@"" errorMessage:errorMsg];
            }
            else
            {
                [Util errorAlert:@"" errorMessage:RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE)];
                NSString *serviceURL = [response objectForKey:@"serviceURL"];
                [[RepliconServiceManager loginService] sendrequestToLogtoCustomerSupportWithMsg:RPLocalizedString(UNKNOWN_ERROR_MESSAGE, UNKNOWN_ERROR_MESSAGE) serviceURL:serviceURL];            }
            
            id nullData=[NSNull null];
            [[NSNotificationCenter defaultCenter] postNotificationName:PUNCH_RESPONSE_RECEIVED_NOTIFICATION object:nil userInfo:[NSMutableDictionary dictionaryWithObjectsAndKeys:nullData,@"TIME_PUNCH_DATA",nullData,@"PUNCH_PROJECT_DATA",nullData,@"PUNCH_LOCATION_DATA",@"YES",@"isError",nil]];
            [[NSNotificationCenter defaultCenter] postNotificationName:PUNCH_TIME_NOTIFICATION object:nil userInfo:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"YES",@"isError",nil]];
            
            
        }
        else
        {
            id _serviceID=[[response objectForKey:@"refDict"]objectForKey:@"refID"];
            if ([_serviceID intValue]== Attendance_PunchTime_Service_ID_97)
            {
                AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
                [appDelegate performSelector:@selector(hideTransparentLoadingOverlay) withObject:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:PUNCH_TIME_NOTIFICATION object:nil userInfo:[NSMutableDictionary dictionaryWithObjectsAndKeys:timePunchDataDict,@"TIME_PUNCH_DATA",projectInfoDict,@"PUNCH_PROJECT_DATA", nil]];
                id locationData=[NSNull null];
                if (self.locationDict!=nil && ![self.locationDict isKindOfClass:[NSNull class]])
                {
                    locationData=locationDict;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:PUNCH_RESPONSE_RECEIVED_NOTIFICATION object:nil userInfo:[NSMutableDictionary dictionaryWithObjectsAndKeys:timePunchDataDict,@"TIME_PUNCH_DATA",projectInfoDict,@"PUNCH_PROJECT_DATA",locationData,@"PUNCH_LOCATION_DATA",@"NO",@"isError",nil]];

            }
          
            
        }
    }
}
#pragma mark - ServiceURL Error Handling
- (void)serverDidFailWithError:(NSError *) error applicationState:(ApplicateState)applicationState
{

    CLS_LOG(@"-----Punch Request failed from the server -----");
    id nullData=[NSNull null];
    [[NSNotificationCenter defaultCenter] postNotificationName:PUNCH_RESPONSE_RECEIVED_NOTIFICATION object:nil userInfo:[NSMutableDictionary dictionaryWithObjectsAndKeys:nullData,@"TIME_PUNCH_DATA",nullData,@"PUNCH_PROJECT_DATA",nullData,@"PUNCH_LOCATION_DATA", @"YES",@"isError",nil]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PUNCH_TIME_NOTIFICATION object:nil userInfo:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"YES",@"isError",nil]];

    
    ///Commenting to fix MI-1313, ViewDidLoad was getting called, inturn mapView was getting added even when device was offline.
    //self.view.backgroundColor=[UIColor clearColor];
    //[self.view removeFromSuperview];
    
    if (applicationState == Foreground)
    {
        if ([NetworkMonitor isNetworkAvailableForListener:self] == NO)
        {
            [Util showOfflineAlert];
            
        }
        else
        {
            [Util handleNSURLErrorDomainCodes:error];
            
        }
    }
    
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
