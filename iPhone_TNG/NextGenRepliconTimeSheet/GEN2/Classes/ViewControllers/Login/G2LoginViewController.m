//
//  LoginViewController.m
//  Replicon
//
//  Created by Devi Malladi on 1/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2LoginViewController.h"
#import "G2LoginViewCell.h"
#import "G2RepliconServiceManager.h"
#import "RepliconAppDelegate.h"

@implementation G2LoginViewController
@synthesize loginTableView;
@synthesize toolbar,companyName,userName, passWD;
@synthesize currentTextField;
static float keyBoardHeight=260.0;
@synthesize errorString;

#define Selecetd_FreeTrailLabelTextColor  [UIColor colorWithRed:0/255.0 green:122/255.0 blue:201/255.0 alpha:1.0]

#pragma mark -
#pragma mark Initialization
#define INCOMPATIBLE_ALERT_VIEW_TAG 98765

/*
 - (id)initWithStyle:(UITableViewStyle)style {
 // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 self = [super initWithStyle:style];
 if (self) {
 // Custom initialization.
 }
 return self;
 }
 */

- (id) init
{
	self = [super init];
	if (self != nil) {
		[NetworkMonitor sharedInstance];	
		//loginModel = [[LoginModel alloc]init]; 
		//permissionsModel = [[PermissionsModel alloc]init];
		//syncExpenses = [[SyncExpenses alloc] init];
		
		if (changePasswordViewController == nil) {
#ifdef _DROP_RELEASE_1_US1719
			changePasswordViewController  = [[ChangePasswordViewController alloc] init];
#endif	
		}
	}
	return self;
}

#pragma mark - 
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	CGRect screenBounds = [[UIScreen mainScreen] bounds];
    float aspectRatio=screenBounds.size.height/screenBounds.size.width;
	UIImageView *backGroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if ([UIScreen mainScreen].scale == 2.f && screenHeight == 568.0f) {
        [backGroundImageView setImage:[G2Util thumbnailImage:BackgroundImage568h]];
    } else {
        [backGroundImageView setImage:[G2Util thumbnailImage:BackgroundImage]];
    }
	
    [self.view addSubview:backGroundImageView];
	
	if (loginTableView ==nil) {
		loginTableView = [[UITableView alloc]initWithFrame:LoginTableViewFrame style:UITableViewStyleGrouped];
	}
	[loginTableView setDelegate:self];
	[loginTableView setDataSource:self];
	[loginTableView setTag:1];
	[self.loginTableView setScrollEnabled:NO];
	[loginTableView setBackgroundColor:[UIColor clearColor]];
    loginTableView.backgroundView=nil;
	[self.view addSubview:loginTableView];
	
	
    float flexibleHeight=0.0;
	if (aspectRatio>1.5) {
        flexibleHeight=50.0;
    }
	if (headerView == nil) {
		headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
															  0.0,
															  self.loginTableView.frame.size.width,
															  50.0+flexibleHeight)];
	}
	[headerView setBackgroundColor:[UIColor clearColor]];	
	
	UILabel *loginTopLabel = [[UILabel alloc] initWithFrame:LoginTopLabelFrame];
	[loginTopLabel setBackgroundColor:RepliconStandardClearColor];
	[loginTopLabel setText:RPLocalizedString(LoginTopLabelText, LoginTopLabelText)];
	loginTopLabel.textColor = ForgotPasswordTextColor;
	[loginTopLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_08]];
	[loginTopLabel setTextAlignment:NSTextAlignmentLeft];
	[loginTopLabel setNumberOfLines:1];
	//[headerView addSubview:loginTopLabel];//As per DE2220
	
	
	UILabel *welcomeLabel = [[UILabel alloc] initWithFrame:WelcomeLabelFrame];
	[welcomeLabel setBackgroundColor:[UIColor clearColor]];
	[welcomeLabel setText:RPLocalizedString(welcomeLabelText, welcomeLabelText)];
	[welcomeLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_08]];
    welcomeLabel.textColor = [UIColor blackColor];
	[welcomeLabel setTextAlignment:NSTextAlignmentLeft];
	[welcomeLabel setNumberOfLines:1];
	//[headerView addSubview:welcomeLabel];//As per DE2220
	
	
	[loginTableView setTableHeaderView:headerView];
    if (aspectRatio>1.5) {
        flexibleHeight=80.0;
    }
	if (footerView==nil) {
		footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0,
															  self.loginTableView.frame.size.height,
															  self.loginTableView.frame.size.width,
															  170.0+flexibleHeight)];
	}
	[footerView setBackgroundColor:RepliconStandardClearColor];	
	
	UIImage *img = [G2Util thumbnailImage:G2LoginButtonImage];
	UIImage *imgSelected = [G2Util thumbnailImage:G2LoginButtonSelectedImage];
	loginButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
	[loginButton1 setFrame:CGRectMake(footerView.frame.origin.x, 
									  footerView.frame.origin.y, 
									  img.size.width, 
									  img.size.height)];		//img.size.width
	[loginButton1 setTitle:RPLocalizedString(SignIn,@"Sign In") forState:UIControlStateNormal];
	[loginButton1 setBackgroundImage:img forState:UIControlStateNormal];
	[loginButton1 setBackgroundImage:imgSelected forState:UIControlStateHighlighted];
	[loginButton1 setCenter:CGPointMake(footerView.frame.size.width/2.0, footerView.frame.size.height/2.0)];
	[loginButton1  addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
    loginButton1.titleEdgeInsets = UIEdgeInsetsMake(-5.0, 0, 0, 0);
	[footerView addSubview:loginButton1];
	[loginTableView setTableFooterView:footerView];
	/* US3084 Hide ForgotPasswordView ans SignUp
	forgotPasswordView= [[UIView alloc]initWithFrame:CGRectMake(0.0, 
																0.0, 
																footerView.frame.size.width, 
																30.0)];
	[forgotPasswordView setBackgroundColor:[UIColor clearColor]];
	[footerView addSubview:forgotPasswordView];
	forgotPasswordLabel = [[UILabel alloc] initWithFrame:ForgotPasswordLabelFrame];
	[forgotPasswordLabel setBackgroundColor:[UIColor clearColor]];
	[forgotPasswordLabel setText:RPLocalizedString(ForgotPasswordLabelText, ForgotPasswordLabelText)];
	[forgotPasswordLabel setTextAlignment:NSTextAlignmentCenter];
	
	[forgotPasswordLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
	
	forgotPasswordLabel.textColor = ForgotPasswordTextColor;
	[forgotPasswordLabel setTextAlignment:NSTextAlignmentLeft];
	[forgotPasswordLabel setNumberOfLines:1];
	[forgotPasswordLabel setCenter:CGPointMake(forgotPasswordView.frame.size.width/2.0, forgotPasswordView.frame.size.height/2.0)];
	//Not supported for AppStore submission - DE2890
	[footerView addSubview:forgotPasswordLabel];
	
    
	UIButton *forgotPswdButton = [[UIButton alloc] initWithFrame:ForgotPasswordButtonFrame];
	[forgotPswdButton addTarget:self action:@selector(forgotPasswordAction:) forControlEvents:UIControlEventTouchUpInside];
	[forgotPswdButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
	[forgotPswdButton setCenter:CGPointMake(forgotPasswordView.frame.size.width/2.0, forgotPasswordView.frame.size.height/2.0)];
	//Not supported for AppStore submission - DE2890
	[footerView addSubview:forgotPswdButton];
	
    
	signUpfreetrialView = [[UIView alloc]initWithFrame:CGRectMake(10.0, 
																  120.0, 
																  footerView.frame.size.width, 
																  40.0)];
	[signUpfreetrialView setBackgroundColor:[UIColor clearColor]];
	[footerView addSubview:signUpfreetrialView];
	
	
	freeTrailLabel = [[UILabel alloc] initWithFrame:freeTrailLabelFrame];
	[freeTrailLabel setBackgroundColor:RepliconStandardClearColor];
	[freeTrailLabel setText:RPLocalizedString(FreeTrailLabelText, FreeTrailLabelText)];
	
	[freeTrailLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_18]];	
	freeTrailLabel.textColor = [UIColor whiteColor];
	[freeTrailLabel setTextAlignment:NSTextAlignmentLeft];
	[freeTrailLabel setNumberOfLines:1];
	//[freeTrailLabel setCenter:CGPointMake(signUpfreetrialView.frame.size.width/2.0, signUpfreetrialView.frame.size.height/2.0)];
	[freeTrailLabel setCenter: [signUpfreetrialView center]];
	//Not supported for AppStore submission - DE2890
	[footerView addSubview:freeTrailLabel];
	
    
	UIButton *signUpButton = [[UIButton alloc] initWithFrame:signUpButtonFrame];
	[signUpButton addTarget:self action:@selector(signUpAction:) forControlEvents:UIControlEventTouchUpInside];
	[forgotPswdButton setCenter:CGPointMake(signUpfreetrialView.frame.size.width/2.0, signUpfreetrialView.frame.size.height/2.0)];
	//Not supported for AppStore submission - DE2890
	[footerView addSubview:signUpButton];
	
	
	//As per login,new layout changes
	UILabel *forgotLabel = [[UILabel alloc] initWithFrame:forgotLabelFrame];
	[forgotLabel setBackgroundColor:RepliconStandardClearColor];
	[forgotLabel setText:RPLocalizedString(ForgotLabelText,ForgotLabelText)];
	forgotLabel.textColor = ForgotLabelTextColor;
	[forgotLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
	//[footerView addSubview:forgotLabel];
	
	
	UILabel *signUpLabel = [[UILabel alloc] initWithFrame:signUpLabelFrame];
	[signUpLabel setBackgroundColor:RepliconStandardClearColor];
	signUpLabel.textColor = SignUpLabelTextColor;
	[signUpLabel setText:RPLocalizedString(SignUpLabelText, SignUpLabelText)];
	[signUpLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
	//[footerView addSubview:signUpLabel];
	 */
	
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	//Prepopulate Remembered User details.
	[self prepopulateUserDetails];
	[self createToolbar];
}

-(void)createToolbar {
	if (toolbar == nil) {
		toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, 320.0, 45.0)];
	}
	
	[toolbar setTranslucent:YES];
	
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
//        [toolbarSegmentControl setSegmentedControlStyle:UISegmentedControlStyleBar];
        
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

-(void)segmentClick:(UISegmentedControl *)segmentControl {
    NSInteger newTag;
	if (segmentControl.selectedSegmentIndex == G2PREVIOUS) {
		newTag = [currentTextField tag]-1;
	}
	if (segmentControl.selectedSegmentIndex == G2NEXT) {
		newTag = [currentTextField tag]+1;
	}
	G2LoginViewCell *tempCell = (G2LoginViewCell*)[loginTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:newTag  inSection:0]];
    [tempCell activeTextField:[NSNumber numberWithInteger:newTag]];
}

-(void)viewWillAppear:(BOOL)animated {
   
	[super viewWillAppear:animated];
	//[self.navigationController setNavigationBarHidden:YES];
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    appDelegate.isInOutTimesheet=FALSE;
      appDelegate.isLockedTimeSheet=FALSE;
    
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
    appDelegate.isNewInOutTimesheetUser=FALSE;
    appDelegate.isTimeOffEnabled=FALSE;
	[self registerForKeyBoardNotifications];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CURRENTGEN_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReceivedForCurrentGen:)
                                                 name:CURRENTGEN_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEXTGEN_INTEGRATION_DETAILS_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReceivedForNextGen:)
                                                 name:NEXTGEN_INTEGRATION_DETAILS_NOTIFICATION
                                               object:nil];

}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    UITextField *pwdTxtField = [(G2LoginViewCell*)[loginTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] pwdText];
    if (![pwdTxtField.text isKindOfClass:[NSNull class] ]) {
        if ([pwdTxtField.text length] > 0) {
            // [self loginAction:nil];
        }
    }
   
}



#pragma mark keyBoard Handling Methods

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
	[currentTextField resignFirstResponder];
}

-(void)setCurrentTextField:(UITextField *)textField {
	currentTextField = textField;
}

/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */
/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */


#pragma mark -
#pragma mark Table view delegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return LOGIN_NUMBER_OF_ROWS;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 
	 */
}

-(void)changeSegmentControlState:(NSNumber*)row {
	if ([row intValue] == 0) {
		[toolbarSegmentControl setEnabled:NO forSegmentAtIndex:G2PREVIOUS];
		[toolbarSegmentControl setEnabled:YES forSegmentAtIndex:G2NEXT];
	}
	else if([row intValue] == LOGIN_NUMBER_OF_ROWS-1){
		[toolbarSegmentControl setEnabled:YES forSegmentAtIndex:G2PREVIOUS];
		[toolbarSegmentControl setEnabled:NO forSegmentAtIndex:G2NEXT];
	}
	else {
		[toolbarSegmentControl setEnabled:YES forSegmentAtIndex:G2PREVIOUS];
		[toolbarSegmentControl setEnabled:YES forSegmentAtIndex:G2NEXT];
	}
}

#pragma mark -
#pragma mark - actionMethods

//This method populates the last successful logged in user.

-(void)prepopulateUserDetails {
    G2LoginModel *loginModel = [[G2LoginModel alloc] init];
	NSMutableArray *users = [loginModel getAllUserInfoFromDb];
     RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
	if (users != nil && [users count] > 0) 
    {
		
		NSMutableDictionary *userDetailsDict = [users objectAtIndex:0];
 
		BOOL rememberCompany = [[userDetailsDict objectForKey:@"rememberCompany"] boolValue];
		BOOL rememberUser = [[userDetailsDict objectForKey:@"rememberUser"] boolValue];
		int rememberPassword = [[userDetailsDict objectForKey:@"rememberPassword"] intValue];
        //US3122        
//        BOOL rememberCompany = TRUE;
//        BOOL rememberUser = TRUE;
//        int rememberPassword = 0;
        

		//DE1713//Juhi
        UITextField *companyTxtField = [(G2LoginViewCell *)[loginTableView cellForRowAtIndexPath:
                                                          [NSIndexPath indexPathForRow:0 inSection:0]] companyTextField ];
        UITextField *emailTxtField = [(G2LoginViewCell *)[loginTableView cellForRowAtIndexPath:
                                                        [NSIndexPath indexPathForRow:1 inSection:0]] userNameText ];
        UITextField *pwdTxtField = [(G2LoginViewCell*)[loginTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] pwdText];
         
        if (rememberCompany && appdelegate.isNotAppFirstTimeInstalled) 
        {
			NSString *company = [userDetailsDict objectForKey:@"company"];
            
            //DE1713//Juhi            
//			UITextField *companyTxtField = [(LoginViewCell *)[loginTableView cellForRowAtIndexPath:
//															  [NSIndexPath indexPathForRow:0 inSection:0]] companyTextField ];
            
            if (company != nil && ![company isKindOfClass:[NSNull class]] ) 
            {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isConnectStagingServer"] ) 
                {
                    [[NSUserDefaults standardUserDefaults] setObject: [[NSUserDefaults standardUserDefaults] objectForKey:@"tempurlPrefixesStr" ] forKey:@"urlPrefixesStr"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [companyTxtField setText:[NSString stringWithFormat:@"%@/%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"],company]];
                }
                else
                {
                    [companyTxtField setText:company];
                }
            }
        }
        else 
        {
            if (rememberCompany)
            {
                 [companyTxtField setText: [[NSUserDefaults standardUserDefaults] objectForKey:@"SSOCompanyName"]];
            }
           
        }
        
            if (rememberUser  && appdelegate.isNotAppFirstTimeInstalled) {
                NSString *loginUser = [userDetailsDict objectForKey:@"login"];
                
                //DE1713//Juhi
//                UITextField *emailTxtField = [(LoginViewCell *)[loginTableView cellForRowAtIndexPath:
//                                                                [NSIndexPath indexPathForRow:1 inSection:0]] userNameText ];
                
                if (loginUser != nil && ![loginUser isKindOfClass:[NSNull class]]) {
                    [emailTxtField setText:loginUser];
                }
            }
            else 
            {
                if (rememberUser)
                {
                     [emailTxtField setText: [[NSUserDefaults standardUserDefaults] objectForKey:@"SSOLoginName"]];
                }
               
                appdelegate.isNotAppFirstTimeInstalled=TRUE;
            }
            
            if (rememberPassword > 0 && rememberUser && rememberCompany) {
                
                NSString *remPwdStartDateStr = [userDetailsDict objectForKey:@"rememberPwdStartDate"];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
                NSDate *remPwdStartDate = [dateFormatter dateFromString:remPwdStartDateStr];
                
                NSDate *todayDate = [NSDate date];
                unsigned unitFlag = NSCalendarUnitDay;
                NSCalendar *calendar = [NSCalendar currentCalendar];
                NSDateComponents *comps = [calendar components:unitFlag fromDate:remPwdStartDate toDate:todayDate options:0];
                NSString *encyrPwd = [userDetailsDict objectForKey:@"password"];
               
                if ((rememberPassword == 1 && [comps day] < 1) || (rememberPassword == 2 && [comps day] < 7) || 
                    (rememberPassword == 3 && [comps day] < 14) || (rememberPassword == 4 && [comps day] < 30) || (rememberPassword == 5)) 
                {
                    
                    //DE1713//Juhi
//                    UITextField *pwdTxtField = [(LoginViewCell*)[loginTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] pwdText];
                     if (![encyrPwd isKindOfClass:[NSNull class]] && encyrPwd!=nil )
                     {
                         if ([encyrPwd length] > 0) 
                         {
                             Crypto *decryption = [Crypto sharedInstance];
                             NSString *pwd = [decryption decryptString:encyrPwd];
                             if (pwd != nil && ![pwd isKindOfClass:[NSNull class]]) {
                                 [pwdTxtField setText:pwd];
                                 //DE1713//Juhi
                                 [companyTxtField setReturnKeyType:UIReturnKeyGo];
                                 [emailTxtField setReturnKeyType:UIReturnKeyGo];
                             }
                         }
                     }
                    
                    
                    
                }
                
                if (![encyrPwd isKindOfClass:[NSNull class] ] )
                {
                    if ((rememberPassword == 1 && [comps day] >= 1) || (rememberPassword == 2 && [comps day] >= 7) || 
                        (rememberPassword == 3 && [comps day] >= 14) || (rememberPassword == 4 && [comps day] >= 30) || ([encyrPwd length] == 0)) {
                        
                        //update login table set rememberPwdStartDate to [NSDate date]
                        G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
                        
                        NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSDate date],@"rememberPwdStartDate",nil];
                        
                        
                        [myDB updateTable:@"login" data:data where:nil intoDatabase:@""];
                    }
                }
                
               
                
            }
        }
    else
    {
        UITextField *companyTxtField = [(G2LoginViewCell *)[loginTableView cellForRowAtIndexPath:
                                                          [NSIndexPath indexPathForRow:0 inSection:0]] companyTextField ];
        [companyTxtField setText: [[NSUserDefaults standardUserDefaults] objectForKey:@"SSOCompanyName"]];
        UITextField *emailTxtField = [(G2LoginViewCell *)[loginTableView cellForRowAtIndexPath:
                                                        [NSIndexPath indexPathForRow:1 inSection:0]] userNameText ];
        [emailTxtField setText: [[NSUserDefaults standardUserDefaults] objectForKey:@"SSOLoginName"]];
        appdelegate.isNotAppFirstTimeInstalled=TRUE;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isConnectStagingServer"] ) 
        {
            [[NSUserDefaults standardUserDefaults] setObject: [[NSUserDefaults standardUserDefaults] objectForKey:@"tempurlPrefixesStr" ] forKey:@"urlPrefixesStr"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [companyTxtField setText:[NSString stringWithFormat:@"%@/%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"urlPrefixesStr"],[[NSUserDefaults standardUserDefaults] objectForKey:@"SSOCompanyName"]]];
        }
        else
        {
            [companyTxtField setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"SSOCompanyName"]];
        }
    }
      
        [users removeAllObjects];
    
    
    
    //Set first Time Logging flag
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"firstTimeLogging"];
     [[NSUserDefaults standardUserDefaults] synchronize];
    
   
    if ([appdelegate.errorMessageForLogging isEqualToString:SESSION_EXPIRED] || [appdelegate.errorMessageForLogging isEqualToString:G2PASSWORD_EXPIRED] ) 
    {
        UITextField *pwdTxtField = [(G2LoginViewCell*)[loginTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] pwdText];
        [pwdTxtField setText:@""];
//        appdelegate.errorMessageForLogging=@"";
    }
    
    
    
}


-(G2LoginViewCell *)getCellAtIndexPath:(NSIndexPath*)cellIndexPath
    {
        G2LoginViewCell *cellObj = (G2LoginViewCell *)[loginTableView cellForRowAtIndexPath:cellIndexPath];
        return cellObj;
    }
    
-(void)loginAction:(id)sender{
        //UIImage *img = [Util thumbnailImage:G2LoginButtonImage];
        //[loginButton1 setBackgroundImage:img forState:UIControlStateNormal];

    
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    appDelegate.isAlertOn=FALSE;
        
        NSIndexPath *companyIndex = [NSIndexPath indexPathForRow:0 inSection:0];
        NSIndexPath *userNameIndex = [NSIndexPath indexPathForRow:1 inSection:0];
        NSIndexPath *passwordIndex = [NSIndexPath indexPathForRow:2 inSection:0];
        id companyCell = [self getCellAtIndexPath:companyIndex];
        UITextField *compnyTxtField = [companyCell companyTextField];
        if (companyCell != nil) {
            [self setCompanyName:compnyTxtField.text];
            
            
            
            NSArray *companyNameArray=[companyName componentsSeparatedByString:@"/"];
            if ([companyNameArray count]>1) {
                urlPrefixesStr=[companyNameArray objectAtIndex:0];
                self.companyName=[companyNameArray objectAtIndex:1];
                [[NSUserDefaults standardUserDefaults] setObject:urlPrefixesStr forKey:@"urlPrefixesStr"];
                [[NSUserDefaults standardUserDefaults] setObject: urlPrefixesStr forKey:@"tempurlPrefixesStr"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else
            {
                
                [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"urlPrefixesStr"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                
            }
            
        }
        id userNameCell = [self getCellAtIndexPath:userNameIndex];
        if (userNameCell != nil) {
            if ([userNameCell userNameText] != nil)
                [self setUserName:[[userNameCell userNameText]text]];
        }
        id passwordCell = [self getCellAtIndexPath:passwordIndex];
        if (passwordCell != nil) {
            if ([passwordCell pwdText] != nil)
                [self setPassWD:[[passwordCell pwdText]text]];
        }
        
        /*UITextField *companyTxtField = 
         
         UITextField *emailTxtField = [(LoginViewCell *)[loginTableView cellForRowAtIndexPath:
         [NSIndexPath indexPathForRow:1 inSection:0]] userNameText ];
         UITextField *passwdTxtField = [(LoginViewCell *)[loginTableView cellForRowAtIndexPath:
         [NSIndexPath indexPathForRow:2 inSection:0]] pwdText ];
         
         companyName = [companyTxtField text];
         
         NSArray *companyNameArray=[companyName componentsSeparatedByString:@"/"];
         if ([companyNameArray count]>1) {
         urlPrefixesStr=[companyNameArray objectAtIndex:0];
         companyName=[companyNameArray objectAtIndex:1];
         [[NSUserDefaults standardUserDefaults] setObject:urlPrefixesStr forKey:@"urlPrefixesStr"];
         [[NSUserDefaults standardUserDefaults] setObject: urlPrefixesStr forKey:@"tempurlPrefixesStr"];
         
         }
         else
         {
         
         [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"urlPrefixesStr"];
         
         }
         
         
         userName =[emailTxtField text];
         passWD =[passwdTxtField text];
         
         [self clearPassword];
         if ( [companyTxtField text].length == 0) {
         companyName = @"enlume1";
         }
         
         if ( [emailTxtField text].length == 0) {
         userName = @"manoj";
         }
         
         if ([passwdTxtField text].length == 0) {
         passWD = @"password";
         }
         
         
         if ( [companyTxtField text].length == 0) {
         companyName = @"enlume1";
         }
         if ( [emailTxtField text].length == 0) {
         userName = @"account13";
         }
         
         if ([passwdTxtField text].length == 0) {
         passWD = @"password1";
         }*/
        
        
        /**
         //TODO:
         //Get and Chek whether the Change Password Field is required
         
         ***/
        
        
        
        if(![NetworkMonitor isNetworkAvailableForListener: self])
        {
#ifdef PHASE1_US2152
			[G2Util showOfflineAlert];
			return;
#else
            NSString *encryPwd=	[G2Util encryptUserPassword:passWD];
            G2LoginModel *loginModel = [[G2LoginModel alloc] init];
            NSMutableArray *loginDetails = [loginModel fetchLoginDetails:userName pwd:encryPwd companyName:companyName];
            
            if (loginDetails == nil) {
                [G2Util errorAlert:RPLocalizedString(LoginAlertErrorTitle, @"") errorMessage:RPLocalizedString(InvaliDLogin, InvaliDLogin)];
                UIImage *img1 = [G2Util thumbnailImage:G2LoginButtonImage];
                [loginButton1 setBackgroundImage:img1 forState:UIControlStateNormal];
            } else {
                UIImage *img1 = [G2Util thumbnailImage:G2LoginButtonImage];
                [loginButton1 setBackgroundImage:img1 forState:UIControlStateNormal];
                [[[UIApplication sharedApplication] delegate] performSelector:@selector(launchHomeViewController)];
            }     
#endif
        }
        else if (companyName.length !=0 && userName.length !=0 && passWD.length !=0) {
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:@"credentials" ]!=nil )
            {
                NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"credentials" ]);
                if (![[[[NSUserDefaults standardUserDefaults] objectForKey:@"credentials" ] objectForKey:@"companyName" ] isEqualToString:companyName ] ) 
                {
                    [G2Util flushDBInfoForOldUser:YES];
                }
                else
                {
                    if (![[[[NSUserDefaults standardUserDefaults] objectForKey:@"credentials" ] objectForKey:@"userName" ] isEqualToString:userName ])
                    {
                        [G2Util flushDBInfoForOldUser:YES];
                    }
                }
            }
            
            NSDictionary *credentialsDict=[NSDictionary dictionaryWithObjectsAndKeys:companyName,@"companyName",userName,@"userName",passWD,@"password", nil];
                        [[NSUserDefaults standardUserDefaults]setObject:credentialsDict forKey:@"credentials"];
             [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
            appdelegate.errorMessageForLogging=@"";
            appdelegate.isAlertOn=FALSE;
            
            //DE2100: Login: Show transition page when downloading/processing, instead of just spinner on top of current page
            G2LoginService *loginService = [G2RepliconServiceManager loginService];
            [G2TransitionPageViewController startProcessForType: ProcessType_Login withData: credentialsDict withDelegate: loginService];
            //[[RepliconServiceManager loginService] sendrequestToFetchAPIURLWithDelegate:self];
            //[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:LoadingMessage];
        }
        else {
            [G2Util errorAlert:RPLocalizedString(LoginAlertErrorTitle,@"") errorMessage:RPLocalizedString(LocalLoginValidatedErrorMessage,@"")];
            UIImage *img1 = [G2Util thumbnailImage:G2LoginButtonImage];
            [loginButton1 setBackgroundImage:img1 forState:UIControlStateNormal];
        }
        
        
        //US3122 
//        UITextField *pwdTxtField = [(LoginViewCell*)[loginTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] pwdText];
//        [pwdTxtField setText:@""];
        //US3122 
        

    }
    
    
    - (void)forgotPasswordAction:(id)sender {
        [forgotPasswordLabel setTextColor:RepliconStandardWhiteColor];
        [self performSelector:@selector(forgotPasswordURLAction) withObject:nil afterDelay:0.3];
    }
    
    -(void)forgotPasswordURLAction {
        /*	UITextField *companyTxtField = [(LoginViewCell *)[loginTableView cellForRowAtIndexPath:
         [NSIndexPath indexPathForRow:0 inSection:0]] companyTextField ];
         companyName = [companyTxtField text];
         
         if (companyName == nil) {
         companyName = @"";
         }
         NSURL *myURL = [NSURL URLWithString:[ServiceUtil getServiceURLForSupportPageWithCompanyName:companyName]]; 
         forgotPasswordLabel.textColor = ForgotPasswordTextColor;
         [[UIApplication sharedApplication] openURL:myURL];*/
        
		//As per US2875
        [forgotPasswordLabel setTextColor:ForgotPasswordTextColor];
        [[[UIApplication sharedApplication] delegate] performSelector:@selector(launchResetPasswordViewController:) withObject:self];
    }
    
    - (void)signUpAction:(id)sender {
        [freeTrailLabel setTextColor:Selecetd_FreeTrailLabelTextColor];
        [self performSelector:@selector(signUpURLAction) withObject:nil afterDelay:0.3];
        
    }
    
    -(void)signUpURLAction {
        /*NSString *signUpUrl = [[AppProperties getInstance] getAppPropertyFor:@"SignUpURL"];
         NSURL *myURL = [NSURL URLWithString:signUpUrl]; 
         freeTrailLabel.textColor = [UIColor whiteColor];
         [[UIApplication sharedApplication] openURL:myURL];*/
        
        //As per US2874
        [[[UIApplication sharedApplication]delegate] performSelector:@selector(launchFreeTrialSignUpController:) withObject:self];
    }
    -(void)dehighlightSignUpButton{
        [freeTrailLabel setTextColor:[UIColor whiteColor]];
    }
    -(void)dehighlightForgotPwdButton {
		//[forgotPasswordLabel setTextColor:ForgotPasswordTextColor];
    }
#pragma mark -
#pragma mark NetworkMonitor related
    
    - (void) networkActivated {
      
        
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
     // Return NO if you do not want the specified item to be editable.
     return YES;
     }
     */
    
    
    /*
     // Override to support editing the table view.
     - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
     
     if (editingStyle == UITableViewCellEditingStyleDelete) {
     // Delete the row from the data source.
     [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
     }   
     else if (editingStyle == UITableViewCellEditingStyleInsert) {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
     }   
     }
     */
    
    
    /*
     // Override to support rearranging the table view.
     - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
     }
     */
    
    
    /*
     // Override to support conditional rearranging of the table view.
     - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
     // Return NO if you do not want the item to be re-orderable.
     return YES;
     }
     */
    
    
#pragma mark AlertViewDelegates
    
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
        
        else if (buttonIndex==0) {
            
            UIImage *img1 = [G2Util thumbnailImage:G2LoginButtonImage];
            [loginButton1 setBackgroundImage:img1 forState:UIControlStateNormal];
            
            NSString *urlString = [G2ServiceUtil getServiceURLForSupportPageWithCompanyName:companyName];
            NSURL *myURL = [NSURL URLWithString:urlString]; 
            [[UIApplication sharedApplication] openURL:myURL];		
        }
        else {
            UIImage *img1 = [G2Util thumbnailImage:G2LoginButtonImage];
            [loginButton1 setBackgroundImage:img1 forState:UIControlStateNormal];
            
            [self clearPassword];
            return;
        }
        
    }
    
    
-(void)clearPassword
{
        UITextField *passwdTxtField = [(G2LoginViewCell *)[loginTableView cellForRowAtIndexPath:
                                                         [NSIndexPath indexPathForRow:2 inSection:0]] pwdText ];
        [passwdTxtField setText:@""];
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
       
        [[G2RepliconServiceManager loginService] sendrequestToFetchUserIntegrationDetailsWithCompanyName:self.companyName andUsername:self.userName];
    }
    
}

-(void)companyChanged
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CURRENTGEN_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEXTGEN_INTEGRATION_DETAILS_NOTIFICATION object:nil];
    [currentTextField resignFirstResponder];
    [[[UIApplication sharedApplication]delegate]performSelector:@selector(launchCompanyViewController)];
}

#pragma mark -
#pragma mark Memory management
    
    - (void)didReceiveMemoryWarning {
        // Releases the view if it doesn't have a superview.
        [super didReceiveMemoryWarning];
        
        // Relinquish ownership any cached data, images, etc. that aren't in use.
    }
    
    - (void)viewDidUnload {
        // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
        // For example: self.myOutlet = nil;
    }
    
    
   
    @end
