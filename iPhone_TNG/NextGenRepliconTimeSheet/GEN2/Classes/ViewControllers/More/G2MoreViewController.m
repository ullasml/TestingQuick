//
//  MoreViewController.m
//  Replicon
//
//  Created by Manoj  on 17/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2MoreViewController.h"
#import "G2UIUnderlinedButton.h"
#import "RepliconAppDelegate.h"
#import "Flurry.h"

@implementation G2MoreViewController
@synthesize preferencesTable;
@synthesize logOutButton;
@synthesize currentIndexPath;
@synthesize loginPreferencesDict;
@synthesize loginPreferencesViewController;
@synthesize  isRememberPasswordClicked,isInToggleUpdateProcess;
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization.
 }
 return self;
 }
 */


- (id) init
{
	self = [super init];
	if (self != nil) {}
	return self;
}

-(void)moveBack
{
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(flipToHomeViewController)];
	//[self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)viewDidLoad
{
     [super viewDidLoad];
    //JUHI
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    float y=0.0;
    
    [self.view setBackgroundColor:[UIColor colorWithRed:204/250.0 green:204/250.0  blue:204/250.0  alpha:1.0]];
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
    {
        UITableView *temppreferencesTable=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width , self.view.frame.size.height-45) style:UITableViewStyleGrouped];
        self.preferencesTable=temppreferencesTable;
       
        preferencesTable.delegate=self;
        preferencesTable.dataSource=self;
        [preferencesTable setScrollEnabled:NO];
        [preferencesTable setBackgroundColor:G2RepliconStandardBackgroundColor];
        preferencesTable.backgroundView=nil;
        [self.view addSubview:preferencesTable];
    }
    
    
    
    RepliconAppDelegate *appDelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    if (!appDelegate.isLockedTimeSheet) 
    {
        UIImage *homeButtonImage1=[G2Util thumbnailImage:G2HomeTransparentButtonImage];
        UIBarButtonItem	*leftButton = [[UIBarButtonItem alloc]initWithImage:homeButtonImage1 style:UIBarButtonItemStylePlain
                                                                     target:self action:@selector(moveBack)];
        [self.navigationItem setLeftBarButtonItem:leftButton animated:NO];
        
        
        
        
        
        
        
    }
    
    //US4800
    UIImage *img = [G2Util thumbnailImage:DeleteExpenseButton];
    
    UIButton *reviewButton =[UIButton buttonWithType:UIButtonTypeCustom];
    
    [reviewButton setBackgroundImage:img forState:UIControlStateNormal];
    [reviewButton setBackgroundImage:[G2Util thumbnailImage:DeleteExpenseButtonSelected] forState:UIControlStateHighlighted];
    
    //US3122 
    
//    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
//    {
        //JUHI
        y=(screenRect.size.height/screenRect.size.width)*133.33;
        [reviewButton setFrame:CGRectMake(40.0, y, img.size.width, img.size.height)];
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
    {
        UIBarButtonItem	*rightButton = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(@"Logout",@"")
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(logoutClicked)];
        [self.navigationItem setRightBarButtonItem:rightButton animated:NO];
        
    }
    
        
//    }
//    else
//    {
//        //JUHI
//        y=(screenRect.size.height/screenRect.size.width)*50;
//        reviewButton.frame=CGRectMake(40.0, y, img.size.width, img.size.height);
//    }
    
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
    {
        y=(screenRect.size.height/screenRect.size.width)*50;
        reviewButton.frame=CGRectMake(40.0, y, img.size.width, img.size.height);
    }
    
    reviewButton.titleEdgeInsets = UIEdgeInsetsMake(-5.0, 0, 0, 0);
    [reviewButton setTitle:RPLocalizedString(@"Review App",@"Review App") forState:UIControlStateNormal];
    
    [reviewButton addTarget:self action:@selector(reviewClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:reviewButton];
    
    
    
    
    
    
    UILabel *versionLabel=[[UILabel alloc]init];
    versionLabel.text=[NSString stringWithFormat:@"Replicon Mobile v%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    //JUHI
    y=(screenRect.size.height/screenRect.size.width)*220;
    versionLabel.frame=CGRectMake(0, y, self.view.frame.size.width, 30);
    versionLabel.textAlignment=NSTextAlignmentCenter;
    versionLabel.textColor=[UIColor darkGrayColor];
    versionLabel.font=[UIFont systemFontOfSize:12.0];
    versionLabel.backgroundColor=[UIColor clearColor];
    [self.view addSubview:versionLabel];
   
    
    //US4800
    UIButton *feedBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [feedBackBtn setBackgroundImage:img forState:UIControlStateNormal];
    [feedBackBtn setBackgroundImage:[G2Util thumbnailImage:DeleteExpenseButtonSelected] forState:UIControlStateHighlighted];
    
    [self.view addSubview:feedBackBtn];
    [feedBackBtn setTitle:RPLocalizedString(@"Send Feedback", @"Send Feedback")  forState:UIControlStateNormal];
    
    if ([[[NSBundle mainBundle] bundleIdentifier] hasString:@".debug"] || [[[NSBundle mainBundle] bundleIdentifier] hasString:@".inhouse"])
    {
        UIImage *img = [G2Util thumbnailImage:DeleteExpenseButton];
        UIButton *syncBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [syncBtn setBackgroundImage:img forState:UIControlStateNormal];
        [syncBtn setBackgroundImage:[G2Util thumbnailImage:DeleteExpenseButtonSelected] forState:UIControlStateHighlighted];
        
        //US3122
        //JUHI
        y=(screenRect.size.height/screenRect.size.width)*1.66;
        [syncBtn setFrame:CGRectMake(220.0, y, 80.0, 35.0)];//US4065//Juhi
        syncBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, 0);
        [syncBtn setTitle:RPLocalizedString(@"Mail Log File",@"") forState:UIControlStateNormal];
        syncBtn.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [syncBtn addTarget:self action:@selector(mailLogFile:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:syncBtn];
        
    }
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
    {
        //JUHI
        y=(screenRect.size.height/screenRect.size.width)*181.33;
        feedBackBtn.frame=CGRectMake(40.0, y, img.size.width, img.size.height);//US4065//Juhi
    }
    else
    {
        //JUHI
        y=(screenRect.size.height/screenRect.size.width)*101.33;
        feedBackBtn.frame=CGRectMake(40.0, y, img.size.width, img.size.height);
    }
    feedBackBtn.titleEdgeInsets = UIEdgeInsetsMake(-5.0, 0, 0, 0);
    [feedBackBtn addTarget:self action:@selector(sendFeedbackClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
    {
        UIImage *img = [G2Util thumbnailImage:DeleteExpenseButton];
        
        UIButton *samllogOutButton =[UIButton buttonWithType:UIButtonTypeCustom];
        
        [samllogOutButton setBackgroundImage:img forState:UIControlStateNormal];
        [samllogOutButton setBackgroundImage:[G2Util thumbnailImage:DeleteExpenseButtonSelected] forState:UIControlStateHighlighted];
        y=(screenRect.size.height/screenRect.size.width)*151.33;
        samllogOutButton.frame=CGRectMake(40.0, y, img.size.width, img.size.height);
        
        samllogOutButton.titleEdgeInsets = UIEdgeInsetsMake(-5.0, 0, 0, 0);
        [samllogOutButton setTitle:RPLocalizedString(@"Change Company / User",@"Change Company / User") forState:UIControlStateNormal];
        
        [samllogOutButton addTarget:self action:@selector(logoutClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:samllogOutButton];
    }
    
    
    [[NetworkMonitor sharedInstance]  queueTheListener:self];
    
	
}

-(void)viewWillAppear:(BOOL)animated
{
    //self.title=RPLocalizedString( @"Settings",@"");
	[G2ViewUtil setToolbarLabel:self withText:RPLocalizedString( @"Settings",@"Settings")];
	[self.navigationController.navigationItem setHidesBackButton:YES];
	[self.navigationController.navigationBar setHidden:NO];
	//[self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:140.0/255.0 green:146.0/255.0 blue:159.0/255.0 alpha:1.0]];
	//[self.navigationController.navigationBar setTintColor:[Util getNavbarTintColor]];
    /*	if (![[NetworkMonitor sharedInstance] networkAvailable]) {
     [logOutButton setUserInteractionEnabled:NO];
     }*/
    self.isRememberPasswordClicked=FALSE;
    self.isInToggleUpdateProcess=FALSE;
}

-(void)getLoginPreferencesFromLoginTable {
    /*	NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];
     DLog(@"credentials %@",dict);
     NSString *encryPwd = [Util encryptUserPassword:[dict objectForKey:@"password"]];
     LoginModel *loginModel = [[LoginModel alloc] init];
     
     NSMutableArray *loginDetails = [loginModel fetchLoginDetails:[dict objectForKey:@"userName"] pwd:encryPwd companyName:[dict objectForKey:@"companyName"]];*/
	
	G2LoginModel *loginModel = [[G2LoginModel alloc] init];
	NSMutableArray *loginDetails = [loginModel getAllUserInfoFromDb];
	
    //if(loginDetails == nil || [loginDetails count] != 1)
    //return;
	NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[loginDetails objectAtIndex:0] objectForKey:@"rememberCompany"],@"rememberCompany",
									 [[loginDetails objectAtIndex:0] objectForKey:@"rememberPassword"],@"rememberPassword",
									 [[loginDetails objectAtIndex:0] objectForKey:@"rememberUser"],@"rememberUser",nil];
	
	[loginDetails removeAllObjects];
	[self setLoginPreferencesDict:tempDict];
}

-(void)logoutClicked
{
    
/*    LoginModel *loginModel = [[LoginModel alloc] init];
	NSMutableArray *loginDetails = [loginModel getAllUserInfoFromDb];
	
    
    BOOL rememberCompany = [ [[loginDetails objectAtIndex:0] objectForKey:@"rememberCompany"] boolValue];
    BOOL rememberUser = [ [[loginDetails objectAtIndex:0] objectForKey:@"rememberUser"] boolValue];
    int rememberPassword = [ [[loginDetails objectAtIndex:0] objectForKey:@"rememberPassword"] intValue];
    
     
    
    if (rememberPassword > 0 && rememberUser && rememberCompany) {
        
        NSString *remPwdStartDateStr = [[loginDetails objectAtIndex:0] objectForKey:@"rememberPwdStartDate"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
        NSDate *remPwdStartDate = [dateFormatter dateFromString:remPwdStartDateStr];
 
        NSDate *todayDate = [NSDate date];
        unsigned unitFlag = NSCalendarUnitDay;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *comps = [calendar components:unitFlag fromDate:remPwdStartDate toDate:todayDate options:0];
        if ((rememberPassword == 1 && [comps day] < 1) || (rememberPassword == 2 && [comps day] < 7) || 
            (rememberPassword == 3 && [comps day] < 14) || (rememberPassword == 4 && [comps day] < 30) || (rememberPassword == 5)) 
        {
            //DO NOTHING HERE
//            NSString *encyrPwd = [[loginDetails objectAtIndex:0] objectForKey:@"password"];
//            if ([encyrPwd length] > 0) 
//            {
//                Crypto *decryption = [Crypto sharedInstance];
//                NSString *pwd = [decryption decryptString:encyrPwd];
//                if (pwd != nil && ![pwd isKindOfClass:[NSNull class]]) {
//                    [pwdTxtField setText:pwd];
//                }
//            }
            
        }
        else
        {
            [self updateLoginTable:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"",@"password",nil]];
        }
        
    }
    else
    {
        [self updateLoginTable:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"",@"password",nil]];
    }
    
*/
//US1132 Issue 2:
[self updateLoginTable:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"",@"password",nil]];

#ifdef PHASE1_US2152
	if ([[NetworkMonitor sharedInstance]networkAvailable] == NO){
		[G2Util showOfflineAlert];
		return;
	}
#endif
	[G2TransitionPageViewController startProcessForType: ProcessType_Logout withData: nil withDelegate: [G2RepliconServiceManager loginService]];
	
    
    
   
}

- (void) networkActivated
{
	if ([NetworkMonitor isNetworkAvailableForListener:self]) {
		[logOutButton setUserInteractionEnabled:YES];
	}else {
		[logOutButton setUserInteractionEnabled:NO];
	}
}

-(void)updateRememberPwdInLoginTable:(NSNumber*)number {
	DLog(@"%d",[number intValue]);
	if ([number intValue] >= 0) {
		[loginPreferencesDict setObject:number forKey:@"rememberPassword"];
		
		NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:[loginPreferencesDict objectForKey:@"rememberPassword"],@"rememberPassword",
                                     [NSDate date],@"rememberPwdStartDate",nil];
        //@"2011-09-02 05:51:20 +0000",@"rememberPwdStartDate",nil];
		[self updateLoginTable:data];
		[[self preferencesTable] reloadData];
	}
	else {
		DLog(@"error");
	}
	
}

-(void)updateLoginTable:(NSMutableDictionary*)data {
	G2SQLiteDB *myDB = [G2SQLiteDB getInstance];
    //NSString *whereString = [NSString stringWithFormat:@"company='%@' AND login='%@'",[loginPreferencesDict objectForKey:@"companyName"],[loginPreferencesDict objectForKey:@"userName"]];
	[myDB updateTable:@"login" data:data where:nil intoDatabase:@""];
}

#pragma mark -
#pragma mark Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	if (section == 0) {
        //JUHI
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        float height=(screenRect.size.height/screenRect.size.width)*26.66;
		return height;
	}
	return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
	if (section ==0) {
		//JUHI
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        float y=(screenRect.size.height/screenRect.size.width)*6.66;
        UILabel	*otherLabel= [[UILabel alloc] initWithFrame:CGRectMake(10.0,
																	   y,
																	   250.0,
																	   30.0)];
		[otherLabel setBackgroundColor:[UIColor clearColor]];
		//[otherLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
		[otherLabel setTextColor:RepliconStandardBlackColor];
		[otherLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];//US4065//Juhi
		[otherLabel setText:RPLocalizedString(@"Login Settings",@"")];
		
		
		UIView	*otherHeader = [UIView new];
		[otherHeader addSubview:otherLabel];
		
        return otherHeader ;
	} 
	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

	return 1;
    //US3122 
//    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;//US4065//Juhi
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 3;
	}
	return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	G2MoreCellView *cell;
	static NSString *CellIdentifier = @"Cell";
	cell  = (G2MoreCellView *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[G2MoreCellView  alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];	
		
	}
	[cell createPreferencesLable];
	
	if (indexPath.row==0) {
		[cell.switchMark setHidden:NO];
		[cell.switchMark setTag:0];
		[cell.switchMark setOn:[[loginPreferencesDict objectForKey:@"rememberCompany"] boolValue]];
		[cell.preferenceLable setText:RPLocalizedString(@"Remember Company",@"")];
	}
	else if (indexPath.row==1) {
		[cell.switchMark setHidden:NO];
		[cell.switchMark setTag:1];
		[cell.switchMark setOn:[[loginPreferencesDict objectForKey:@"rememberUser"] boolValue]];
		[cell.preferenceLable setText:RPLocalizedString( @"Remember Login Name",@"")];
	}
	else if (indexPath.row==2) {
		[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
		[cell.secondLabel setHidden:NO];
		[cell.preferenceLable setText:RPLocalizedString( @"Remember Password",@"")];
		
		NSArray *timeArray = [NSArray arrayWithObjects:@"Never",@"1 day",@"1 week",@"2 weeks",@"1 month",@"Always",nil];
		int rememberPwdIndex = [[loginPreferencesDict valueForKey:@"rememberPassword"] intValue];
		
		if (rememberPwdIndex < 0) {
			rememberPwdIndex = 0;
		}
		[cell.secondLabel setTextColor:NewRepliconStandardBlueColor];//US4065//Juhi
		[cell.secondLabel setText:RPLocalizedString([timeArray objectAtIndex:rememberPwdIndex], [timeArray objectAtIndex:rememberPwdIndex])];
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	}
	[cell.switchMark addTarget:self action:@selector(updateSwitchMark:) forControlEvents:UIControlEventValueChanged];
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor whiteColor]];
	if (indexPath.row == 2) {
		[self updateRememberPwdCell:(G2MoreCellView *)cell :[self disableRememberPwdField]];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if (indexPath.row==2) {
        G2MoreCellView *cell = (G2MoreCellView*)[tableView cellForRowAtIndexPath:indexPath];
		[cell setCellViewState:YES];
		
		if(loginPreferencesViewController == nil) {
			loginPreferencesViewController = [[G2LoginPreferencesViewController alloc] init];
			[loginPreferencesViewController setMoreViewControllerObject:self];
		}
		[self.loginPreferencesViewController setPreviousSelectedRow:[NSIndexPath indexPathForRow:[[loginPreferencesDict objectForKey:@"rememberPassword"] intValue] inSection:0]];
		[self.navigationController pushViewController:loginPreferencesViewController animated:YES];
		self.currentIndexPath = indexPath;
        
	}
}

-(void)updateSelectedRow:(NSIndexPath*)indexPath withNewSwitchValue:(int)value {
	if (indexPath.row==1) {		//remember login name
		[loginPreferencesDict setObject:[NSNumber numberWithInt:value] forKey:@"rememberUser"];
		
		NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:[loginPreferencesDict objectForKey:@"rememberUser"],@"rememberUser",nil];
		[self updateLoginTable:data];
		//[self performSelector:@selector(tableViewCellUntapped:) withObject:indexPath afterDelay:0.3];
	}
	else if (indexPath.row==0) {		//remember company
		[loginPreferencesDict setObject:[NSNumber numberWithInt:value] forKey:@"rememberCompany"];
		
		NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:[loginPreferencesDict objectForKey:@"rememberCompany"],@"rememberCompany",nil];
		[self updateLoginTable:data];
		//[self performSelector:@selector(tableViewCellUntapped:) withObject:indexPath afterDelay:0.3];
	}	
}

-(BOOL)disableRememberPwdField {
	if ([[loginPreferencesDict objectForKey:@"rememberUser"] boolValue] && [[loginPreferencesDict objectForKey:@"rememberCompany"] boolValue]) {
		return NO;
	}
	else {
        //	DLog(@"disable");
		return YES;
	}
}

-(void)updateRememberPwdCell:(G2MoreCellView*)cell :(BOOL)disable {
	if (disable) {
		[cell.preferenceLable setTextColor:RepliconStandardGrayColor];
		[cell.secondLabel setTextColor:RepliconStandardGrayColor];
		[cell setUserInteractionEnabled:NO];
		
		[self updateLoginTable:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],@"rememberPassword",nil]];
		[loginPreferencesDict setObject:[NSNumber numberWithInt:0] forKey:@"rememberPassword"];
		[cell.secondLabel setText:RPLocalizedString(@"Never", @"Never") ];
		if(loginPreferencesViewController == nil) {
			loginPreferencesViewController = [[G2LoginPreferencesViewController alloc] init];
			[loginPreferencesViewController setMoreViewControllerObject:self];
		}		
		[loginPreferencesViewController performSelector:@selector(resetToNever)];
		[self.loginPreferencesViewController setPreviousSelectedRow:[NSIndexPath indexPathForRow:[[loginPreferencesDict objectForKey:@"rememberPassword"] intValue] inSection:0]];
	}
	else {
		[cell.preferenceLable setTextColor:RepliconStandardBlackColor];//US4065//Juhi
		[cell.secondLabel setTextColor:NewRepliconStandardBlueColor];//US4065//Juhi
		[cell setUserInteractionEnabled:YES];
	}
}


/*-(void)tableViewCellUntapped:(NSIndexPath*)indexPath {
 MoreCellView *cell = (MoreCellView*)[preferencesTable cellForRowAtIndexPath:indexPath];
 [preferencesTable deselectRowAtIndexPath:indexPath animated:NO];
 }*/


-(void)updateSwitchMark:(id)sender {
    /*self.isInToggleUpdateProcess=TRUE;
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(completedToggleProcess:) 
     name:@"COMPLETE_SWITCH_ACTIONS"
     object:nil];*/
	[self updateSelectedRow:[NSIndexPath indexPathForRow:[sender tag] inSection:0] withNewSwitchValue:[sender isOn]];
	[self updateRememberPwdCell:(G2MoreCellView *)[self.preferencesTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] :[self disableRememberPwdField]];
    /* [[NSNotificationCenter defaultCenter] postNotificationName:@"COMPLETE_SWITCH_ACTIONS" object:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:@"COMPLETE_SWITCH_ACTIONS" object:nil];
     self.isInToggleUpdateProcess=FALSE;*/
}

/*- (void) completedToggleProcess:(NSNotification *) notification
 {
 if (self.isRememberPasswordClicked) {
 [self rememberPasswordSelected:currentIndexPath];
 }
 
 self.isRememberPasswordClicked=FALSE;
 
 }*/

#pragma mark DeselectSelectedCells
-(void)deselectRowAtIndexPath:(NSIndexPath*)indexPath
{
	G2MoreCellView *cell = (G2MoreCellView*)[preferencesTable cellForRowAtIndexPath:indexPath];
    //	[cell.preferenceLable setTextColor:[UIColor blackColor]];
    //	[cell.secondLabel setTextColor:FieldButtonColor];
	[cell setCellViewState:NO];
	[preferencesTable deselectRowAtIndexPath:indexPath animated:YES];	
}

-(void)animateCellWhichIsSelected
{
	[preferencesTable selectRowAtIndexPath:currentIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
	//MoreCellView *cell = (MoreCellView *)[preferencesTable cellForRowAtIndexPath:currentIndexPath];
		//[self performSelector:@selector(deselectRowAtIndexPath:) withObject:currentIndexPath afterDelay:0.30];	//DE2949 FadeOut is slow
    [self performSelector:@selector(deselectRowAtIndexPath:) withObject:currentIndexPath afterDelay:0.0];	
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	[self getLoginPreferencesFromLoginTable];	
}


/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

#pragma mark serverResponseProtocols

- (void) processResponse:(id) response
{
	if (response!=nil) {
		NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
		NSNumber *serviceID=[[response objectForKey:@"refDict"]objectForKey:@"refID"];
		
		if ([status isEqualToString:@"OK"]) {	
			if ([serviceID intValue] == EndSession_39) {
				NSHTTPCookieStorage * sharedCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
				NSArray * cookies = [sharedCookieStorage cookies];
				for (NSHTTPCookie * cookie in cookies){
					NSString *domainName = [[G2AppProperties getInstance] getAppPropertyFor: @"DomainName"];
                    //ravi - domainName should be defined in the property list. If not found (to be safe) hardcoding it with "replicon.com"
					if (domainName == nil) {
						DLog(@"Critical error: domainName cannot be null");
					}
					domainName = domainName == nil ? @"replicon.com" : domainName;
					
					if ([cookie.domain rangeOfString: domainName].location != NSNotFound){
						DLog(@"COOKIES IN DOMAIN DELETION  %@",cookie.domain);
						[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"cookies"];
						[sharedCookieStorage deleteCookie:cookie];
					}
				}
				
				[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"credentials"];
				[[[UIApplication sharedApplication]delegate] performSelector:@selector(reloaDLogin)];
			}
		}else {
			if (![status isEqualToString:@"OK"]) {
                // status=@"Connection Failed"; 
			}
			NSString *value = [[response objectForKey:@"response"]objectForKey:@"Value"];
			NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
			
			[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
			if (value!=nil) {
//				[Util errorAlert:status errorMessage:value];
                [G2Util errorAlert:@"" errorMessage:value];//DE1231//Juhi
			}else {
//				[Util errorAlert:status errorMessage:message];
                [G2Util errorAlert:status errorMessage:message];//DE1231//Juhi
			}
		}
	}
	
}
- (void) processingError:(NSError *) error
{
}


-(void)sendFeedbackClicked:(id)sender
{
    if ([MFMailComposeViewController canSendMail] == NO) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:RPLocalizedString(@"This device is not configured for sending mail", @"This device is not configured for sending mail")  delegate:nil cancelButtonTitle:RPLocalizedString(@"Close", @"Close")  otherButtonTitles:nil];
		[alert show];
		
		return;
	}
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;   
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *emailSubject=nil;
    NSString *companyName=nil;
    NSString *companyDetails=nil;
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
    {
        companyName =[[NSUserDefaults standardUserDefaults] objectForKey:@"SSOCompanyName"];
    }
    else
    {
        NSDictionary *credDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];
        if (credDict != nil && ![credDict isKindOfClass:[NSNull class]]) {
            companyName = [credDict objectForKey:@"companyName"];
        } 
    }
    

    emailSubject=[RPLocalizedString(G2EMAIL_SUBJECT, "")  stringByAppendingString:version];
    if (companyName!=nil)
    {
        companyDetails=[RPLocalizedString(COMPANY_NAME, "") stringByAppendingFormat:@": %@",companyName];
        emailSubject=[NSString stringWithFormat:@"%@, %@",emailSubject,companyDetails];
    }
    
    else
    {
        emailSubject=[NSString stringWithFormat:@"%@",emailSubject];
    }
    
    [picker setSubject:emailSubject];                                 
    [picker setToRecipients:[NSArray arrayWithObject:RECIPENT_ADDRESS]]; 
    [self presentViewController:picker animated:YES completion:nil];
   

    
}

-(void)mailLogFile:(id)sender
{
    if ([MFMailComposeViewController canSendMail] == NO) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:RPLocalizedString(@"This device is not configured for sending mail", @"This device is not configured for sending mail")  delegate:nil cancelButtonTitle:RPLocalizedString(@"Close", @"Close")  otherButtonTitles:nil];
		[alert show];
		
		return;
	}
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    
    NSString *filePath = [documentsDirectory stringByAppendingFormat:@"/log.txt"];  
    NSData *myData = [NSData dataWithContentsOfFile:filePath]; 
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;   
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    [picker setSubject:[RPLocalizedString(@"Log for v", "")   stringByAppendingString:version]];                                 
    [picker setToRecipients:[NSArray arrayWithObject:@"alliphone@replicon.com"]]; 
 
    int r = arc4random() % 9999;
     [picker addAttachmentData:myData mimeType:@"text/plain" fileName:[@"log-" stringByAppendingString:[NSString stringWithFormat:@"%d",r]]];
    [self presentViewController:picker animated:YES completion:nil];
    
    
}

//US4800
-(void)reviewClicked{
    //DE7077
    if ( [NetworkMonitor isNetworkAvailableForListener:self] == YES)  {
        
        UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:nil message:RPLocalizedString(REVIEW_APP_MSG, REVIEW_APP_MSG) 
                                                                  delegate:self cancelButtonTitle:RPLocalizedString(REVIEW_APP_NO_OPTION, REVIEW_APP_NO_OPTION) otherButtonTitles:RPLocalizedString(REVIEW_APP_YES_OPTION, REVIEW_APP_YES_OPTION),nil];
        
        [confirmAlertView setDelegate:self];
        confirmAlertView.tag=1000; 
        [confirmAlertView show];
        
        
        
    }
    else {
        
        [G2Util showOfflineAlert];
        return;
    }
    
    NSString *userID=nil;
    NSString *companyName=nil;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"] != nil && ![[[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"]isKindOfClass:[NSNull class] ])
    {
        userID=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"];
        
    } 
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
    {
        companyName =[[NSUserDefaults standardUserDefaults] objectForKey:@"SSOCompanyName"];
    }
    else {
        NSDictionary *credDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];
        if (credDict != nil && ![credDict isKindOfClass:[NSNull class]]) {
            companyName = [credDict objectForKey:@"companyName"];
        }
    }


    NSString *flurryEvent= [NSString stringWithFormat:@"Review App Clicked"];
    
    if (![[[NSBundle mainBundle] bundleIdentifier] hasString:@".debug"] && ![[[NSBundle mainBundle] bundleIdentifier] hasString:@".inhouse"])
    {
         [Flurry logEvent:flurryEvent withParameters:[NSDictionary dictionaryWithObjectsAndKeys:companyName,@"CName",userID,@"UId", nil]];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag==1000)
    {
        NSString *userID=nil;
        NSString *companyName=nil;
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"] != nil && ![[[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"]isKindOfClass:[NSNull class] ])
        {
            userID=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserID"];
            
        } 
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
        {
            companyName =[[NSUserDefaults standardUserDefaults] objectForKey:@"SSOCompanyName"];
        }
        else {
            NSDictionary *credDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"credentials"];
            if (credDict != nil && ![credDict isKindOfClass:[NSNull class]]) {
                companyName = [credDict objectForKey:@"companyName"];
            }
        }

        
        if (buttonIndex==1)
        {
             NSString *flurryEvent= [NSString stringWithFormat:@"Open App Store Clicked"];
            if (![[[NSBundle mainBundle] bundleIdentifier] hasString:@".debug"] && ![[[NSBundle mainBundle] bundleIdentifier] hasString:@".inhouse"])
            {
                [Flurry logEvent:flurryEvent withParameters:[NSDictionary dictionaryWithObjectsAndKeys:companyName,@"CName",userID,@"UId", nil]];
            }
            
            
            CGFloat systemVersion = [[[ UIDevice currentDevice ] systemVersion ] floatValue ];
            if( systemVersion >= 6.0 )
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://itunes.apple.com/us/app/replicon-timesheet/id463488167?mt=8"]];
            }
            else
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=463488167"]];
            }
            
            
        }
        else
        {
             NSString *flurryEvent= [NSString stringWithFormat:@"Denied App Store"];
            if (![[[NSBundle mainBundle] bundleIdentifier] hasString:@".debug"] && ![[[NSBundle mainBundle] bundleIdentifier] hasString:@".inhouse"])
            {
                [Flurry logEvent:flurryEvent withParameters:[NSDictionary dictionaryWithObjectsAndKeys:companyName,@"CName",userID,@"UId", nil]];
            }
        }
    }
    
    
    
}
    
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{ 
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
            
        default:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:RPLocalizedString(@"Email",@"Email") message:RPLocalizedString(@"Sending Failed - Unknown Error :-(", @"Sending Failed - Unknown Error :-(") 
                                                           delegate:self cancelButtonTitle:RPLocalizedString(@"OK",@"OK") otherButtonTitles: nil];
            [alert show];
          
        }
            
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
//    self.preferencesTable=nil;
    //self.logOutButton=nil;
}




@end
