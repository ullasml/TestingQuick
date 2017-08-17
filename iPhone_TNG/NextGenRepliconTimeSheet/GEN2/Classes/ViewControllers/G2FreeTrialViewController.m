    //
//  FreeTrialViewController.m
//  Replicon
//
//  Created by Swapna P on 10/10/11.
//  Copyright 2011 EnLume. All rights reserved.
//

#import "G2FreeTrialViewController.h"
#import "RepliconAppDelegate.h"


@implementation G2FreeTrialViewController
@synthesize freeSignUpTrialView;
@synthesize delegate;
@synthesize firstSectionfieldsArr;
@synthesize secondSectionfieldsArray;
@synthesize welcomeView;

#define Start 1
#define OK    0
typedef enum SectionTag {
	Second_Section_Tag = 2011
} SectionTag; 

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
	if (self != nil) {
		
	}
	return self;
}
-(void)viewWillAppear:(BOOL)animated {
	//added below call to resolve bug DE1722#6
	//[self.navigationController.navigationBar setTintColor:RepliconStandardNavBarTintColor];
	[self moveTableToTopAtIndexPath:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	[G2ViewUtil setToolbarLabel: self withText:RPLocalizedString(FreeTrial, FreeTrial) ];
	[self.view setBackgroundColor:NewExpenseSheetBackgroundColor];
	[self setFirstSectionFields ];
	[self setSecondSectionFields ];
	
	//1. Sign Up Table
	if (freeSignUpTrialView == nil) {
		freeSignUpTrialView = [[UITableView alloc] initWithFrame:SignUpforFreeTableViewFrame style:UITableViewStyleGrouped];
	}
	freeSignUpTrialView.delegate=self;
	freeSignUpTrialView.dataSource=self;
	[freeSignUpTrialView setShowsVerticalScrollIndicator:NO];
	[freeSignUpTrialView setScrollEnabled:YES];
	[self.freeSignUpTrialView setBackgroundColor:NewExpenseSheetBackgroundColor];
	[self.view addSubview:freeSignUpTrialView];
	
	//2.Table Header
	//if (header == nil) {
	UILabel  *header = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 15.0, freeSignUpTrialView.frame.size.width-10, 40.0)];
	//}
	[header setText:RPLocalizedString(Free_Sign_UP_Message, Free_Sign_UP_Message) ];
	[header setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_18]];
	[header setTextColor:RepliconTimeEntryHeaderTextColor];
	[header setTextAlignment:NSTextAlignmentLeft];
	[header setBackgroundColor:[UIColor clearColor]];
	
	//3. Table Footer
	//if (footer == nil) {
	UIView    *footer = [[UIView alloc] initWithFrame:CGRectMake(0.0, -15.0, freeSignUpTrialView.frame.size.width, 120.0)];
	//}
	
	[footer setBackgroundColor:[UIColor clearColor]];
	
	//4.a. Terms Label
	//if (repliconRegisterView == nil) {
	UILabel *repliconRegisterView = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 
																		 0.0, 
																		 footer.frame.size.width, 
																		 15.0)];
	//}
	[repliconRegisterView setNumberOfLines:1];
	[repliconRegisterView setText:RPLocalizedString(UseLogin,UseLogin)];
	[repliconRegisterView setTextColor:RepliconStandardGrayColor];
	[repliconRegisterView setFont:[UIFont italicSystemFontOfSize:RepliconFontSize_13]];
	[repliconRegisterView setBackgroundColor:[UIColor clearColor]];
	
	//4.b. Use Lable
	//if (useLable == nil) {
	UILabel *useLable = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 
															 20.0, 
															 footer.frame.size.width,
															 40.0)];
	//}
	[useLable setNumberOfLines:2];
	[useLable setLineBreakMode:NSLineBreakByWordWrapping];
	[useLable setText:RPLocalizedString(Replicon_Register_Message,Replicon_Register_Message)];
	
	//[repliconRegisterView setText:ObjectNotFoundMessage];
	[useLable setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
	[useLable setTextColor:RepliconStandardGrayColor];
	[useLable setBackgroundColor:[UIColor clearColor]];
	
	//5. Free Trial Sign Up Button
	//if (freeTrialSignupButton == nil) {
	UIButton       *freeTrialSignupButton =[UIButton buttonWithType:UIButtonTypeCustom];
	//}
	UIImage *normalImg = [G2Util thumbnailImage:submitButtonImage];
	UIImage *highlightedImg = [G2Util thumbnailImage:submitButtonImageSelected];
	[freeTrialSignupButton setBackgroundImage:normalImg forState:UIControlStateNormal];
	[freeTrialSignupButton setBackgroundImage:highlightedImg forState:UIControlStateHighlighted];
	[freeTrialSignupButton setFrame:CGRectMake(40.0, 60.0, normalImg.size.width, normalImg.size.height)];
    freeTrialSignupButton.titleEdgeInsets = UIEdgeInsetsMake(-5.0, 0, 0, 0);
	[freeTrialSignupButton setTitle:RPLocalizedString(Free_Trial_Btn_Title,Free_Trial_Btn_Title) forState:UIControlStateNormal];
	[freeTrialSignupButton addTarget:self action:@selector(freeTrialSignupButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	
	
	[footer addSubview:repliconRegisterView];
	[footer addSubview:useLable];
	[footer addSubview:freeTrialSignupButton];
	
	[freeSignUpTrialView setTableHeaderView:header];
	[freeSignUpTrialView setTableFooterView:footer];

	//6.Add Cancel Button
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																				  target:self action:@selector(cancelSignUpAction:)];
	[self.navigationItem setLeftBarButtonItem:cancelButton animated:NO];
	
	
	//7.Add Sign Up Button
	UIBarButtonItem *signUpButton = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(Sign_Up_BTN_TITLE,Sign_Up_BTN_TITLE) style:UIBarButtonItemStylePlain 
																  target:self action:@selector(freeTrialSignupButtonAction:)];
	
	[self.navigationItem setRightBarButtonItem:signUpButton animated:NO];
	
	
	
	
	
	
	
}
-(void)setFirstSectionFields{
	
	if (firstSectionfieldsArr == nil) {
		[self setFirstSectionfieldsArr:[NSMutableArray array]];
	}
	NSDictionary *firstName = [NSDictionary dictionaryWithObject:@"First Name" forKey:@"fieldName"];
	NSDictionary *lastName  = [NSDictionary dictionaryWithObject:@"Last Name" forKey:@"fieldName"];
	NSDictionary *phone       = [NSDictionary dictionaryWithObject:@"Phone" forKey:@"fieldName"];
	NSDictionary *email        = [NSDictionary dictionaryWithObject:@"Email" forKey:@"fieldName"];
	[firstSectionfieldsArr addObject:firstName];
	[firstSectionfieldsArr addObject:lastName];
	[firstSectionfieldsArr addObject:phone];
	[firstSectionfieldsArr addObject:email];
	
}
-(void)setSecondSectionFields{
	
	if (secondSectionfieldsArray == nil) {
		[self setSecondSectionfieldsArray:[NSMutableArray array]];
	}
	NSDictionary *companyName		= [NSDictionary dictionaryWithObject:@"Company Name*" forKey:@"fieldName"];
	NSDictionary *password			= [NSDictionary dictionaryWithObject:@"Password" forKey:@"fieldName"];
	NSDictionary *confirmPassword	= [NSDictionary dictionaryWithObject:@"Confirm Password" forKey:@"fieldName"];
	[secondSectionfieldsArray addObject:companyName];
	[secondSectionfieldsArray addObject:password];
	[secondSectionfieldsArray addObject:confirmPassword];
}
-(void)loadWelcomeView:(NSString *)_btntitle :(int)_tag{
	[self.navigationItem setRightBarButtonItem:nil];
	UIBarButtonItem *rightButton = nil;
	if (_tag == Start) {
		rightButton = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(Start_BTN_TITLE,Start_BTN_TITLE) style:UIBarButtonItemStylePlain 
															   target:self action:@selector(startUsingRepliconButtonAction:)];
	}else {
		rightButton = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(OK_BTN_TITLE,OK_BTN_TITLE) style:UIBarButtonItemStylePlain 
													  target:self action:@selector(goToLogin:)];

	}

	
	[self.navigationItem setRightBarButtonItem:rightButton animated:NO];
	
	//8. Add Welcome View
	//if (welcomeView == nil) {
		welcomeView = [[UIView alloc]initWithFrame:SignUpforFreeTableViewFrame];
	//}
	[welcomeView setBackgroundColor:NewExpenseSheetBackgroundColor];
	if (!_tag) {
		//[welcomeView setHidden:YES];
		[processLoadingView setHidden:YES];	
	}
	[welcomeView setHidden:NO];

	
	//9. Add Welcome Label
	UILabel  *welcome = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, welcomeView.frame.size.width, 30.0)];
	//}
	[welcome setText:RPLocalizedString(Welcome_Replicon_Message, Welcome_Replicon_Message) ];
	[welcome setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_20]];
	[welcome setTextColor:RepliconTimeEntryHeaderTextColor];
	[welcome setTextAlignment:NSTextAlignmentLeft];
	[welcome setBackgroundColor:NewExpenseSheetBackgroundColor];
	
	//10. Add Message 
	UILabel *messageLabel = [[UILabel alloc]initWithFrame:CGRectMake(10.0, welcome.frame.size.height+10.0, welcomeView.frame.size.width-10.0, 200.0)];
	[messageLabel setText:[NSString stringWithFormat:@"%@\n\n%@",RPLocalizedString(Free_Message_Label1, Free_Message_Label1),RPLocalizedString(Free_Message_Label2, Free_Message_Label2)]];
	[messageLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16]];
	[messageLabel setTextColor:RepliconStandardGrayColor];
	[messageLabel setBackgroundColor:NewExpenseSheetBackgroundColor];
	[messageLabel setNumberOfLines:10];
	[messageLabel setLineBreakMode:NSLineBreakByWordWrapping];
	
	//11. Add Replicon Use Button
	UIButton       *startUsingRepliconButton =[UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *normalImg = [G2Util thumbnailImage:submitButtonImage];
	UIImage *highlightedImg = [G2Util thumbnailImage:submitButtonImageSelected];
	[startUsingRepliconButton setBackgroundImage:normalImg forState:UIControlStateNormal];
	[startUsingRepliconButton setBackgroundImage:highlightedImg forState:UIControlStateHighlighted];
	[startUsingRepliconButton setFrame:CGRectMake(40.0, 280.0, normalImg.size.width, normalImg.size.height)];
     startUsingRepliconButton.titleEdgeInsets = UIEdgeInsetsMake(-5.0, 0, 0, 0);
	[startUsingRepliconButton setTitle:RPLocalizedString(_btntitle,_btntitle) forState:UIControlStateNormal];
	if (_tag == 1) {
		[startUsingRepliconButton addTarget:self action:@selector(startUsingRepliconButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	}else {
		[startUsingRepliconButton addTarget:self action:@selector(goToLogin:) forControlEvents:UIControlEventTouchUpInside];
	}
	[welcomeView addSubview:messageLabel];
	[welcomeView addSubview:welcome];
	[welcomeView addSubview:startUsingRepliconButton];
	[self.view addSubview:welcomeView];
	
	}
#pragma mark  Button Action Methods
-(void)cancelSignUpAction:(id)sender{
	[delegate performSelector:@selector(dehighlightSignUpButton)];
	//[self dismissViewControllerAnimated:YES completion:nil];
	[[[UIApplication sharedApplication]delegate]performSelector:@selector(flipToLoginViewController)];
}

-(void)freeTrialSignupButtonAction:(id)sender{
	DLog(@"freeTrialSignupButtonAction::");
	switch ([[self validatefreeSignUpFieldValues] intValue]) {
		case 0:
			[G2Util errorAlert:nil errorMessage:RPLocalizedString(FirstName_Error_Message,FirstName_Error_Message)];
			break;
		case 1:
			[G2Util errorAlert:nil errorMessage:RPLocalizedString(LastName_Error_Message,LastName_Error_Message)];
			break;
		case 2:
			[G2Util errorAlert:nil errorMessage:RPLocalizedString(Phone_Error_Message,Phone_Error_Message)];
			break;
		case 3:
			[G2Util errorAlert:nil errorMessage:RPLocalizedString(InvalidEmail_Error_Message,InvalidEmail_Error_Message)];
			break;
		case 4:
			[G2Util errorAlert:nil errorMessage:RPLocalizedString(Email_Error_Message,Email_Error_Message)];
			break;
		case 5:
			[G2Util errorAlert:nil errorMessage:RPLocalizedString(CompanyName_Error_Message,CompanyName_Error_Message)];
			break;
		case 6:
			[G2Util errorAlert:nil errorMessage:RPLocalizedString(Password_Error_Message,Password_Error_Message)];
			break;
		case 7:
			[G2Util errorAlert:nil errorMessage:RPLocalizedString(PasswordMisMatch_Message,PasswordMisMatch_Message)];
			break;
		default:
			[self reloadViewUponSuccessValidation];
			break;
	}
}
-(void)startUsingRepliconButtonAction:(id)sender{
	DLog(@"startUsingRepliconButtonAction::");
	processLoadingView =[[G2TaskSelectionMessageView alloc] initWithFrame:CGRectMake(10.0, 100.0, 300.0, 180.0)];
	NSString *titleString = [NSString stringWithFormat:@"%@",
							 @"Please stand by while we    process your free trial."];
	[processLoadingView showTransparentAlert:titleString message:@"This will only take a moment."];
	[processLoadingView.titleLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_18]];
	[processLoadingView.titleLabel setNumberOfLines:3];
	[processLoadingView.messageLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_18]];
	[processLoadingView.closeButton setHidden:YES];
	[processLoadingView.progressView setHidden:NO];
	[processLoadingView.loadingLabel setHidden:NO];
	[processLoadingView setHidden:NO];
	[self.view addSubview:processLoadingView];
	
	//TODO: Send Request to Start Using Replicon Services:Pending
	//For Testing the UI Only no Query(service) implemented.........
	[self.view setUserInteractionEnabled:NO];
	[self.navigationItem.leftBarButtonItem setEnabled:NO];
	[self.navigationItem.rightBarButtonItem setEnabled:NO];
	[[G2RepliconServiceManager loginService] sendRequestForFreeTrialSignUp];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(freetrialSuccessSetUpView) name:FREE_TRIAL_SIGN_UP_NOTIFICATION object:nil];
	
	[self performSelector:@selector(freetrialSuccessSetUpView) withObject:nil afterDelay:2.5];
}
-(void)goToLogin:(id)sender{
	DLog(@"GoToLogin");
	[delegate performSelector:@selector(dehighlightSignUpButton)];
	//[self dismissViewControllerAnimated:YES completion:nil];	
	[[[UIApplication sharedApplication]delegate]performSelector:@selector(flipToLoginViewController)];
	
}
-(void)reloadViewUponSuccessValidation{
	[self.freeSignUpTrialView setHidden:YES];
	//[self.welcomeView setHidden:NO];
	[self loadWelcomeView:Use_Replicon_Btn_Title :Start];
}
-(void)freetrialSuccessSetUpView{
	[self.view setUserInteractionEnabled:YES];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:FREE_TRIAL_SIGN_UP_NOTIFICATION object:nil];
	[self.navigationItem setLeftBarButtonItem:nil];
	[self.freeSignUpTrialView setHidden:YES];
	[self loadWelcomeView:OK_BTN_TITLE :OK];
}
#pragma mark Table DataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return [firstSectionfieldsArr count];
	}else if (section == 1) {
		return [secondSectionfieldsArray count];
	}
	return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
	return 35;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 40.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
    
	G2CustomTableViewCell *cell =(G2CustomTableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[G2CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	//cell.refDelegate=self;
	if (indexPath.section == 0) {
		[cell createCommonCellLayoutFields:[[firstSectionfieldsArr objectAtIndex:indexPath.row]objectForKey:@"fieldName"] row:indexPath.row];
	}
	if (indexPath.section == 1) {
		NSInteger index = Second_Section_Tag+indexPath.row;
		[cell createCommonCellLayoutFields:[[secondSectionfieldsArray objectAtIndex:indexPath.row]objectForKey:@"fieldName"] row:index];
	}
	[cell setCellSelectedIndex:indexPath];
	[cell setCommonCellDelegate:self];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	[cell setBackgroundColor:[UIColor whiteColor]];
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return nil;
}

#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
/*-(void)textfieldnextClickAction:(NSNumber *)_textfieldTag section:(NSIndexPath *)_indexpath{
	DLog(@"Section: %d Row: %d",_indexpath.section,_indexpath.row);
	DLog(@"Txt tag %d",[_textfieldTag intValue]);
	int row = [_textfieldTag intValue]+1;
	DLog(@"Row %d",row);
CustomTableViewCell *cell = (CustomTableViewCell*)[self.freeSignUpTrialView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:_indexpath.section]];
	[cell setActiveFieldAtCell:[_textfieldTag intValue]];
}*/
-(void)moveTableToTopAtIndexPath:(NSIndexPath *)_index{
	if (_index != nil && _index.section == 1) {
		if (_index.row == 0) {
			[self.freeSignUpTrialView  setFrame:CGRectMake(0.0,-70,self.view.frame.size.width-00.0,self.view.frame.size.height-10)];
		}else if(_index.row == 1) {
			[self.freeSignUpTrialView  setFrame:CGRectMake(0.0,-110,self.view.frame.size.width-00.0,self.view.frame.size.height-10)];
		}else if(_index.row == 2) {
			[self.freeSignUpTrialView  setFrame:CGRectMake(0.0,-150,self.view.frame.size.width-00.0,self.view.frame.size.height-10)];
		}
	}else {
		[self.freeSignUpTrialView setFrame:SignUpforFreeTableViewFrame];
	}
}
-(NSNumber * )validatefreeSignUpFieldValues{
	
	NSIndexPath *firstnameindex			= [NSIndexPath indexPathForRow:0 inSection:0];
	NSIndexPath *lastnameIndex			= [NSIndexPath indexPathForRow:1 inSection:0];
	NSIndexPath *phonenoIndex			= [NSIndexPath indexPathForRow:2 inSection:0];
	NSIndexPath *emailIndex				= [NSIndexPath indexPathForRow:3 inSection:0];
	NSIndexPath *companyIndex			= [NSIndexPath indexPathForRow:0 inSection:1];
	NSIndexPath *passwordIndex			= [NSIndexPath indexPathForRow:1 inSection:1];
	NSIndexPath *confirmpasswordIndex	= [NSIndexPath indexPathForRow:2 inSection:1];
	NSString *firstName					= [[[self returnCellAtIndexPath:firstnameindex] commonTxtField] text];
	NSString *lastName					= [[[self returnCellAtIndexPath:lastnameIndex] commonTxtField] text];
	NSString *phoneno					= [[[self returnCellAtIndexPath:phonenoIndex] commonTxtField] text];
	NSString *email					= [[[self returnCellAtIndexPath:emailIndex] commonTxtField] text];
	NSString *companyName				= [[[self returnCellAtIndexPath:companyIndex] commonTxtField] text];
	NSString *password					= [[[self returnCellAtIndexPath:passwordIndex] commonTxtField] text];
	NSString *confirmPassword			= [[[self returnCellAtIndexPath:confirmpasswordIndex] commonTxtField] text];
	
#ifdef DEV_DEBUG
	DLog(@"First Name %@",firstName);
	DLog(@"Last  Name %@",lastName);
	DLog(@"Phone Number  %@",phoneno);
	DLog(@"Email  %@",email);
	DLog(@"Company Name %@",companyName);
	DLog(@"Company Name %d",[companyName length]);
	DLog(@"Password  %@",password);
	DLog(@"Confirm Password %@",confirmPassword);
#endif
	NSNumber *num = [NSNumber numberWithInt:-1];
	
	if (firstName == nil || [firstName length] == 0) {
		num = [NSNumber numberWithInt:0];
		return num;
	}
	if (lastName == nil || [lastName length] == 0) {
		num = [NSNumber numberWithInt:1];
		return num;
	}
	if (phoneno == nil || [phoneno length] == 0) {
		num = [NSNumber numberWithInt:2];
		return num;
	}
	if (email == nil || [email length] == 0) {
		num = [NSNumber numberWithInt:4];
		return num;
	}else if (email != nil || [email length]>0) {
			if (![G2Util validateEmail:email]) {
				num = [NSNumber numberWithInt:3];
				return num;
			}
	}
	if (companyName == nil || [companyName length] == 0) {
		num = [NSNumber numberWithInt:5];
		return num;
	}
	if (password == nil || [password length] == 0) {
		num = [NSNumber numberWithInt:6];
		return num;
	}else if (password != nil || [password length]>0) {
		if ((confirmPassword == nil || [confirmPassword length] == 0)
			|| ![confirmPassword isEqualToString:password]) {
			num = [NSNumber numberWithInt:7];
			return num;
		}
	}
	return num;
}
-(G2CustomTableViewCell *)returnCellAtIndexPath:(NSIndexPath *)_indexpath{
	G2CustomTableViewCell *cellObj = (G2CustomTableViewCell *)[self.freeSignUpTrialView cellForRowAtIndexPath:_indexpath];
	return cellObj;
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
}




@end
