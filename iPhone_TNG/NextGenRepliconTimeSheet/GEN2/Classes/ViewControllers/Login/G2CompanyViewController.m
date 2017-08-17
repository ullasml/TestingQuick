//
//  CompanyViewController.m
//  Replicon
//
//  Created by Dipta Rakshit on 4/21/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "G2CompanyViewController.h"
#import "G2Constants.h"
#import<QuartzCore/QuartzCore.h>
#import "G2RepliconServiceManager.h"
#import "G2TransitionPageViewController.h"
#import "RepliconAppDelegate.h"

@interface G2CompanyViewController ()

@end

@implementation G2CompanyViewController

@synthesize loginButton1;
@synthesize toolbar;
@synthesize companyViewScrollView;
@synthesize loginTableView;
@synthesize toolbarSegmentControl;
@synthesize currentTextField;
@synthesize welcomeLbl1,welcomeLbl2;
@synthesize  isNotExpandedMode;
@synthesize errorString;

static float keyBoardHeight=260.0;

#define INCOMPATIBLE_ALERT_VIEW_TAG 01234

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    
	[super viewWillAppear:animated];
	//[self.navigationController setNavigationBarHidden:YES];
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    appDelegate.isInOutTimesheet=FALSE;
    appDelegate.isLockedTimeSheet=FALSE;
    appDelegate.isAlertOn=FALSE;
    appDelegate.selectedTab=0;
    appDelegate.isShowPunchButton=TRUE;
    appDelegate.isInApprovalsMainPage=FALSE;
    appDelegate.hasApprovalPermissions=FALSE;
    appDelegate.isAtHomeViewController=FALSE;
    
    appDelegate.punchClockIsZeroTimeEntries=TRUE;
    appDelegate.hasTimesheetLicenses=FALSE;
    if (appDelegate.locationController) {
        [appDelegate.locationController.locationManager stopUpdatingLocation];
        appDelegate.isLocationServiceEnabled=FALSE;
    }
    appDelegate.isAttestationPermissionTimesheets=FALSE;
    appDelegate.isAcceptanceOfDisclaimerRequired=FALSE;
    appDelegate.attestationTitleTimesheets=nil;
    appDelegate.attestationDescTimesheets=nil;
    appDelegate.disclaimerTitleTimesheets=nil;
    appDelegate.isUpdatingDisclaimerAcceptanceDate=FALSE;
	[self registerForKeyBoardNotifications];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CURRENTGEN_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReceivedForCurrentGen:)
                                                 name:CURRENTGEN_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEXTGEN_INTEGRATION_DETAILS_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReceivedForNextGen:)
                                                 name:NEXTGEN_INTEGRATION_DETAILS_NOTIFICATION
                                               object:nil];

    
    [G2Util flushDBInfoForOldUser:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    float aspectRatio=screenBounds.size.height/screenBounds.size.width;
    
    UIScrollView *scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [scrollView setBackgroundColor:G2RepliconStandardBackgroundColor];
    scrollView.contentSize= CGSizeMake(self.view.frame.size.width,self.view.frame.size.height);
    self.companyViewScrollView=scrollView;
    [self.view addSubview:self.companyViewScrollView];
    
    
    [self.view setBackgroundColor:G2RepliconStandardBackgroundColor];
    
    UIImageView *backGroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f)
    {
      [backGroundImageView setImage:[G2Util thumbnailImage:HomeBackgroundImage568h]];  //BackgroundImage
    } else
    {
      [backGroundImageView setImage:[G2Util thumbnailImage:G2HomeBackgroundImage]];  //BackgroundImage
    }
	
    [self.companyViewScrollView addSubview:backGroundImageView];
    [self.companyViewScrollView setBackgroundColor:G2RepliconStandardBackgroundColor];
   
    
    
    UILabel *tempwelcomeLbl1=[[UILabel alloc]initWithFrame:CGRectMake(0,
                                                                      140.0,
                                                                      320.0,
                                                                      44.0)];
    
    //Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    if (version>=7.0)
    {
        if (aspectRatio>1.5)
        {
            tempwelcomeLbl1.frame=CGRectMake(0,
                                             120.0,
                                             320.0,
                                             44.0);
        }
        else
        {
            tempwelcomeLbl1.frame=CGRectMake(0,
                                             80.0,
                                             320.0,
                                             44.0);
        }
        
    }
    self.welcomeLbl1=tempwelcomeLbl1;
   
    welcomeLbl1.text=RPLocalizedString(WELCOME_MESSAGE_1, "");
    [welcomeLbl1 setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_20]];
    [welcomeLbl1 setBackgroundColor:[UIColor clearColor]];
    welcomeLbl1.textAlignment=NSTextAlignmentCenter;
    [self.companyViewScrollView addSubview:welcomeLbl1];
    
    
    
    UILabel *tempwelcomeLbl2=[[UILabel alloc]initWithFrame:CGRectMake(20,
                                                                      welcomeLbl1.frame.origin.y+welcomeLbl1.frame.size.height+aspectRatio*4,
                                                                      280.0,
                                                                      54.0)];
    self.welcomeLbl2=tempwelcomeLbl2;
    
    welcomeLbl2.text=RPLocalizedString(WELCOME_MESSAGE_2, "");
    [welcomeLbl2 setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_20]];
    [welcomeLbl2 setBackgroundColor:[UIColor clearColor]];
    welcomeLbl2.numberOfLines=2.0;
    welcomeLbl2.textAlignment=NSTextAlignmentCenter;
    [self.companyViewScrollView addSubview:welcomeLbl2];
   
    
    if (loginTableView ==nil) {
		loginTableView = [[UITableView alloc]initWithFrame:CGRectMake(15.0,welcomeLbl2.frame.origin.y+welcomeLbl2.frame.size.height+aspectRatio*7.33, self.view.frame.size.width-30, self.view.frame.size.height) style:UITableViewStyleGrouped];
	}
	[loginTableView setDelegate:self];
	[loginTableView setDataSource:self];
	[loginTableView setTag:1];
	[self.loginTableView setScrollEnabled:NO];
    self.loginTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	[loginTableView setBackgroundColor:[UIColor clearColor]];
    loginTableView.backgroundView=nil;
	[self.companyViewScrollView addSubview:loginTableView];
    
    
    UIImage *img = [G2Util thumbnailImage:G2LoginButtonImage];
	UIImage *imgSelected = [G2Util thumbnailImage:G2LoginButtonSelectedImage];
	self.loginButton1= [UIButton buttonWithType:UIButtonTypeCustom];
   //Fix for ios7//JUHI
    if (version<7.0)
    {
        [self.loginButton1 setFrame:CGRectMake(40.5,loginTableView.frame.origin.y+aspectRatio*76.66,img.size.width,img.size.height)];
    }
    else
    {
        if (aspectRatio>1.5)
        {
            [self.loginButton1 setFrame:CGRectMake(40.5,loginTableView.frame.origin.y+aspectRatio*76.66+30.0,img.size.width,img.size.height)];
        }
        else
        {
            [self.loginButton1 setFrame:CGRectMake(40.5,loginTableView.frame.origin.y+aspectRatio*76.66+50.0,img.size.width,img.size.height)];
        }
        
    }
	[self.loginButton1 setTitle:RPLocalizedString(GO_BTN_TITLE,GO_BTN_TITLE) forState:UIControlStateNormal];
	[self.loginButton1 setBackgroundImage:img forState:UIControlStateNormal];
	[self.loginButton1 setBackgroundImage:imgSelected forState:UIControlStateHighlighted];
	[self.loginButton1 addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
    self.loginButton1.titleEdgeInsets = UIEdgeInsetsMake(-5.0, 0, 0, 0);
	[self.companyViewScrollView addSubview:self.loginButton1];
    
	[self createToolbar];
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return G2_LOGIN_CELL_ROW_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"Cell";
    
    G2LoginViewCell *cell =(G2LoginViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[G2LoginViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	cell.refDelegate=self;
	[cell createLablesAndTextFieldsWithIndexpath:indexPath.row];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	[cell setBackgroundColor:[UIColor whiteColor]];
	return cell;
}

-(void)createToolbar {
	if (toolbar == nil) {
		toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, 320.0, 45.0)];
	}
	
	//[toolbar setTranslucent:YES];
	
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
																				target:self 
																				action:@selector(doneClickAction)];
	UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																				 target:nil 
																				 action:nil];
	if (toolbarSegmentControl == nil) {
		toolbarSegmentControl = [[UISegmentedControl alloc] initWithItems:
								 [NSArray arrayWithObjects:RPLocalizedString(@"Previous",@""),
								  RPLocalizedString(@"Next",@""),nil]];
	}
	[toolbarSegmentControl setFrame:ToolbarSegmentControlFrame];
//	[toolbarSegmentControl setSegmentedControlStyle:UISegmentedControlStyleBar];
	[toolbarSegmentControl setWidth:70.0 forSegmentAtIndex:G2PREVIOUS];
	[toolbarSegmentControl setWidth:70.0 forSegmentAtIndex:G2NEXT];
	[toolbarSegmentControl addTarget:self action:@selector(segmentClick:) forControlEvents:UIControlEventValueChanged];
	[toolbarSegmentControl setMomentary:YES];
    //Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    if (version>=7.0)
    {
        doneButton.tintColor=RepliconStandardWhiteColor;
        [toolbarSegmentControl setTintColor:RepliconStandardWhiteColor];
        toolbar.barStyle = UIBarStyleBlackTranslucent;
        toolbar.tintColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:20/255.0 alpha:0.5];
        
    }
	else{
        [toolbarSegmentControl setTintColor:[UIColor clearColor]];
        [toolbar setTintColor:[UIColor clearColor]];
    }
	
	NSArray *toolArray = [NSArray arrayWithObjects:spaceButton,doneButton,nil];
    
	[toolbar setItems:toolArray];
	[self.view addSubview:toolbar];
	[toolbar addSubview:toolbarSegmentControl];
	[toolbar setHidden:YES];
}

-(void)loginAction:(id)selector
{
    [self doneClickAction];
    
    if(![NetworkMonitor isNetworkAvailableForListener: self])
    {
#ifdef PHASE1_US2152
        [G2Util showOfflineAlert];
        return;
#endif
    }

    
    NSIndexPath *companyIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    NSIndexPath *userNameIndex = [NSIndexPath indexPathForRow:1 inSection:0];
    id companyCell = [self getCellAtIndexPath:companyIndex];
    UITextField *compnyTxtField = [companyCell companyTextField];    
    NSString *companyName=compnyTxtField.text;
        
    NSArray *companyNameArray=[companyName componentsSeparatedByString:@"/"];
        
        if ([companyNameArray count]>1)
        {
            NSString  *urlPrefixesStr=[companyNameArray objectAtIndex:0];
            companyName=[companyNameArray objectAtIndex:1];
            [[NSUserDefaults standardUserDefaults] setObject:urlPrefixesStr forKey:@"urlPrefixesStr"];
            [[NSUserDefaults standardUserDefaults] setObject: urlPrefixesStr forKey:@"tempurlPrefixesStr"];
            
            [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"isConnectStagingServer"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"urlPrefixesStr"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
    
     [[NSUserDefaults standardUserDefaults] setObject:companyName forKey:@"SSOCompanyName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    id userNameCell = [self getCellAtIndexPath:userNameIndex];
    UITextField *usernameTxtField = [userNameCell userNameText];    
    NSString *userName=usernameTxtField.text;
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"SSOLoginName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    BOOL isCompanyNameValid=FALSE;
    BOOL isUserNameValid=FALSE;
    
    if (companyName!=nil )
    {
        
        if (companyName.length !=0) 
        {
            isCompanyNameValid=TRUE;
        }
        else 
        {
            [G2Util errorAlert:RPLocalizedString(LoginAlertErrorTitle,@"") errorMessage:RPLocalizedString(UserNameValidationMessage,@"")];
        }
    }
    else 
    {
        [G2Util errorAlert:RPLocalizedString(LoginAlertErrorTitle,@"") errorMessage:RPLocalizedString(UserNameValidationMessage,@"")];
    }
    
    if (userName!=nil )
    {
        
        if (userName.length !=0) 
        {
            isUserNameValid=TRUE;
        }
        else 
        {
            //DON"T SHOW THIS WHEN COMPANY VALIDATION ALERT IS SHOWN
            if (isCompanyNameValid)
            {
                 [G2Util errorAlert:RPLocalizedString(LoginAlertErrorTitle,@"") errorMessage:RPLocalizedString(InvaliDLoginName,@"")];
            }
            
        }
    }
    else 
    {
        //DON"T SHOW THIS WHEN COMPANY VALIDATION ALERT IS SHOWN
        if (isCompanyNameValid)
        {
            [G2Util errorAlert:RPLocalizedString(LoginAlertErrorTitle,@"") errorMessage:RPLocalizedString(InvaliDLoginName,@"")];
        }
        
    }
            
    if (isCompanyNameValid && isUserNameValid ) 
    {
        G2LoginService *loginService=[G2RepliconServiceManager loginService];
        [[G2TransitionPageViewController getInstance] setDelegate: loginService];
        float version=[[UIDevice currentDevice].systemVersion floatValue];
        if (version>=7.0)
        {
             [[G2RepliconServiceManager loginService] sendrequestToFetchNewAuthRemoteAPIUrl:self];
        }
        else
        {
             [[G2RepliconServiceManager loginService] sendrequestToFetchAuthRemoteAPIUrl:self];
        }
        
       
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:LoadingMessage];
    }
    

    
    
}

-(void)registerForKeyBoardNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];
	
    // Register notification when the keyboard will be hide
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
}


- (void)showToolBarWithAnimation{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
	[toolbar setHidden:NO];
    CGRect frame = self.toolbar.frame;
	frame.origin.y = self.view.frame.size.height -keyBoardHeight;
	self.toolbar.frame= frame;
	[UIView commitAnimations];
}

- (void)hideToolBarWithAnimation {
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
	[toolbar setHidden:YES];
    CGRect frame = self.toolbar.frame;
	frame.origin.y = self.view.frame.size.height;
	self.toolbar.frame= frame;
	[UIView commitAnimations];
}

-(void) keyboardWillShow:(NSNotification *)note {
	[self showToolBarWithAnimation];
    [self resetScrollView];
}

-(void) keyboardWillHide:(NSNotification *)note {
	[self hideToolBarWithAnimation];
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEXTGEN_INTEGRATION_DETAILS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CURRENTGEN_NOTIFICATION object:nil];
}

-(void)doneClickAction {
    
    if (self.isNotExpandedMode) 
    {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        float aspectRatio=screenBounds.size.height/screenBounds.size.width;
        float flexibleHeight=0.0;
        [currentTextField resignFirstResponder];
        //self.companyViewScrollView.contentSize=CGSizeMake(self.view.frame.size.width,self.view.frame.size.height);
        //Fix for ios7//JUHI
        float version=[[UIDevice currentDevice].systemVersion floatValue];
        CGRect frame;
        frame=self.welcomeLbl1.frame;
        
        if (version>=7.0)
        {
            if (aspectRatio>1.5)
            {
                frame.origin.y=120;
                
            }
            else
            {
                frame.origin.y=80;
               
            }
            
        }
        [self.welcomeLbl1 setFrame:frame];
        [self.welcomeLbl2 setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_20]];
        frame=self.welcomeLbl2.frame;
        
        if (aspectRatio>1.5)
        {
            flexibleHeight=15.0;
        }

        frame.origin.y=frame.origin.y-7.5-flexibleHeight;
        self.welcomeLbl2.frame=frame;
        frame=self.loginTableView.frame;
        if (aspectRatio>1.5)
        {
            flexibleHeight=35.0;
        }
        frame.origin.y=welcomeLbl2.frame.origin.y+welcomeLbl2.frame.size.height+aspectRatio*7.33;
        self.loginTableView.frame=frame;
        frame=self.loginButton1.frame;
        if (aspectRatio>1.5)
        {
            flexibleHeight=45.0;
        }
        
        //Fix for ios7//JUHI
        if (version<7.0)
        {
            frame.origin.y=loginTableView.frame.origin.y+aspectRatio*76.66;
           
        }
        else
        {
            if (aspectRatio>1.5)
            {
                frame.origin.y=loginTableView.frame.origin.y+aspectRatio*76.66+30.0;
                
            }
            else
            {
                frame.origin.y=loginTableView.frame.origin.y+aspectRatio*76.66+50.0;
            }
            
        }
        
        self.loginButton1.frame=frame;
        [self.companyViewScrollView setContentOffset:CGPointMake(0,0) animated:YES];
        [self.companyViewScrollView setScrollEnabled:YES];
        
        self.isNotExpandedMode=FALSE;
    }
    

     
}

-(void)resetScrollView
{
    if (!self.isNotExpandedMode) 
    {
        //self.companyViewScrollView.contentSize=CGSizeMake(self.view.frame.size.width,self.view.frame.size.height);
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        float aspectRatio=screenBounds.size.height/screenBounds.size.width;
        float flexibleHeight=0.0;
        //Fix for ios7//JUHI
         float version= [[UIDevice currentDevice].systemVersion floatValue];
        [self.welcomeLbl2 setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_18]];
        CGRect frame=self.welcomeLbl2.frame;
        if (aspectRatio>1.5)
        {
            flexibleHeight=15.0;
        }
        
        frame.origin.y=frame.origin.y+7.5+flexibleHeight;
        self.welcomeLbl2.frame=frame;
        frame=self.loginTableView.frame;
        //Fix for ios7//JUHI
        if (version<7.0)
        {
            if (aspectRatio>1.5)
            {
                flexibleHeight=35.0;
            }
        }
        else
        {
            if (aspectRatio>1.5)
            {
                flexibleHeight=25.0;
            }
            else
            {
                flexibleHeight=-25.0;
            }
            
            
        }
        frame.origin.y=frame.origin.y-12.5+flexibleHeight;
        self.loginTableView.frame=frame;
        frame=self.loginButton1.frame;
        //Fix for ios7//JUHI
        if (version<7.0)
        {
            if (aspectRatio>1.5)
            {
                flexibleHeight=45.0;
            }
        }
        else
        {
            if (aspectRatio>1.5)
            {
                flexibleHeight=30.0;
            }
            else
            {
                flexibleHeight=-50.0;
            }
            
        }

        frame.origin.y=frame.origin.y-27.5+flexibleHeight;
        self.loginButton1.frame=frame;
        //Fix for ios7//JUHI
        if (version<7.0)
        {
            [self.companyViewScrollView setContentOffset:CGPointMake(0,200) animated:YES];
        }
        else
        {
            if (aspectRatio>1.5)
            {
                [self.companyViewScrollView setContentOffset:CGPointMake(0,170) animated:YES];
            }
            else
            {
                [self.companyViewScrollView setContentOffset:CGPointMake(0,120) animated:YES];
            }
            
        }

        [self.companyViewScrollView setScrollEnabled:NO];
        
        self.isNotExpandedMode=TRUE;
    }
   
   
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}





- (void) networkActivated {
   
    
}

-(G2LoginViewCell *)getCellAtIndexPath:(NSIndexPath*)cellIndexPath
{
    G2LoginViewCell *cellObj = (G2LoginViewCell *)[loginTableView cellForRowAtIndexPath:cellIndexPath];
    return cellObj;
}

-(void)changeSegmentControlState:(NSNumber*)row {
	if ([row intValue] == 0) {
		[toolbarSegmentControl setEnabled:NO forSegmentAtIndex:G2PREVIOUS];
		[toolbarSegmentControl setEnabled:YES forSegmentAtIndex:G2NEXT];
	}
	else if([row intValue] ==1){
		[toolbarSegmentControl setEnabled:YES forSegmentAtIndex:G2PREVIOUS];
		[toolbarSegmentControl setEnabled:NO forSegmentAtIndex:G2NEXT];
	}
	
}

-(void)segmentClick:(UISegmentedControl *)segmentControl {
	NSNumber *newTag=nil;
	if (segmentControl.selectedSegmentIndex == G2PREVIOUS) {
		newTag = [NSNumber numberWithInteger:[currentTextField tag]-1];
	}
	if (segmentControl.selectedSegmentIndex == G2NEXT) {
		newTag = [NSNumber numberWithInteger:[currentTextField tag]+1];
	}
	G2LoginViewCell *tempCell = (G2LoginViewCell*)[loginTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[newTag intValue] inSection:0]];
	[tempCell activeTextField:newTag];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0;
}


-(void)dataReceivedForNextGen:(NSNotification *) notification
{
   // [[NSNotificationCenter defaultCenter] removeObserver:self name:NEXTGEN_INTEGRATION_DETAILS_NOTIFICATION object:nil];
    
    NSDictionary *dict=notification.userInfo;
    
    BOOL hasError=[[dict objectForKey:@"hasError"]boolValue];
    
    if (hasError)
    {
        if (self.errorString!=nil)
        {
            [G2Util errorAlert:@"" errorMessage:self.errorString];
        }
    }
    else
    {
        //SHOW THE CUSTOMIZED ERROR
        UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:@"" message:RPLocalizedString(GEN3_LAUNCH_APP_MSG, GEN3_LAUNCH_APP_MSG)
                                                                  delegate:self cancelButtonTitle:RPLocalizedString(Incompatible_App_Later, Incompatible_App_Later) otherButtonTitles:RPLocalizedString(@"OK", @"OK") ,nil];
        [confirmAlertView setDelegate:self];
        [confirmAlertView setTag:INCOMPATIBLE_ALERT_VIEW_TAG];
        [confirmAlertView show];
        
        
        NSIndexPath *companyIndex = [NSIndexPath indexPathForRow:0 inSection:0];
        NSIndexPath *userNameIndex = [NSIndexPath indexPathForRow:1 inSection:0];
        id companyCell = [self getCellAtIndexPath:companyIndex];
        UITextField *compnyTxtField = [companyCell companyTextField];
        compnyTxtField.text=@"";
        id userNameCell = [self getCellAtIndexPath:userNameIndex];
        UITextField *userTxtField = [userNameCell userNameText];
        userTxtField.text=@"";
    }
    
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
    self.view.userInteractionEnabled=TRUE;
    
}

-(void)dataReceivedForCurrentGen:(NSNotification *) notification
{
  //  [[NSNotificationCenter defaultCenter] removeObserver:self name:CURRENTGEN_NOTIFICATION object:nil];
    
    NSDictionary *dict=notification.userInfo;
    
    BOOL hasError=[[dict objectForKey:@"hasError"]boolValue];
    NSString *errorMsg=[dict objectForKey:@"errorMsg"];
    
    if (hasError)
    {
        self.errorString=errorMsg;
         [[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:LoadingMessage];
        self.view.userInteractionEnabled=FALSE;
        //HERE CURRENT GEN AUTH API IS BEING CALLED TO CHECK FOR THE RIGHT APP
        NSString *companyName = [[NSUserDefaults standardUserDefaults] objectForKey:@"SSOCompanyName"];
        NSString *loginName = [[NSUserDefaults standardUserDefaults] objectForKey:@"SSOLoginName"];
        [[G2RepliconServiceManager loginService] sendrequestToFetchUserIntegrationDetailsWithCompanyName:companyName andUsername:loginName];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 1 && alertView.tag==INCOMPATIBLE_ALERT_VIEW_TAG)
    {
        [[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary] forName:[[NSBundle mainBundle] bundleIdentifier]];
        
        [[NSUserDefaults standardUserDefaults]setBool:FALSE forKey:@"IS_GEN2_INSTANCE"];
        [[NSUserDefaults standardUserDefaults]synchronize];
        CLSLog(@"---CREATE DUMMY CRASH TO SWITCH TO GEN 3---");
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        [defaults setBool:TRUE forKey:@"RememberMe"];
        [defaults synchronize];
        exit(0);
    }
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;

    self.loginButton1=nil;
    self.toolbar=nil;
    self.companyViewScrollView=nil;
    self.loginTableView=nil;
    self.toolbarSegmentControl=nil;
    self.currentTextField=nil;
    self.welcomeLbl1=nil;
    self.welcomeLbl2=nil;
}




@end
