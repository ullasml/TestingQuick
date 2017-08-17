//
//  ChangePasswordViewController.m
//  RepliUI
//
//  Created by Swapna P on 4/5/11.
//  Copyright 2011 EnLume. All rights reserved.
//

#import "G2ChangePasswordViewController.h"
#import"G2LoginModel.h"
#import "RepliconAppDelegate.h"

@implementation G2ChangePasswordViewController
@synthesize changePasswordTableView;
@synthesize changePasswordButton;
@synthesize passwordStr;
@synthesize verifyStr;
@synthesize loginDelegate;

#pragma mark -
#pragma mark Initialization

- (id) init
{
	self = [super init];
	if (self != nil) {
		DLog(@"init::ChangePasswordViewController");
		[self.view setBackgroundColor:[UIColor colorWithRed:237/255.0 
													  green:237/255.0 
													   blue:237/255.0 
													  alpha:1.0]];//UIColor: NewExpenseSheetBackgroundColor
		//[self setTitle:@"Change Password"];
		[self setTitle:RPLocalizedString(ChangePasswordTitle,@"")];
		
		//Add CHANGEPASSWORD Table 
		if (changePasswordTableView == nil) {
			/*changePasswordTableView = [[UITableView alloc]
									   initWithFrame:CGRectMake(0.0,
																0.0, 
																320.0, 
																170.0)
									   style:UITableViewStyleGrouped];*/
			changePasswordTableView = [[UITableView alloc]
		initWithFrame:ChangePasswordTableFrame
		style:UITableViewStyleGrouped];
										
		}
		
		[changePasswordTableView setScrollEnabled:NO];
		[changePasswordTableView setDelegate:self];
		[changePasswordTableView setDataSource:self];
		[changePasswordTableView setBackgroundColor:[UIColor colorWithRed:237/255.0 
																	green:237/255.0 
																	 blue:237/255.0 
																	alpha:1.0]];//UIColor: NewExpenseSheetBackgroundColor
		[self.view addSubview:changePasswordTableView];
		
		//Add ENTERPASSWORD Label
		if (enterNewPasswordLabel ==nil) {
			enterNewPasswordLabel = [[UILabel alloc]initWithFrame:CGRectMake(10,05,320.0,40)];
			
		}
		//[enterNewPasswordLabel setFont:[UIFont fontWithName:@"Helvetica" size:16.0]];
		[enterNewPasswordLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16]];
		[enterNewPasswordLabel setText:RPLocalizedString(@"Please enter a new password",@"")];
		[enterNewPasswordLabel setBackgroundColor:[UIColor clearColor]];
		[self.view addSubview:enterNewPasswordLabel];
		
		//Add CHANGEPASSWORD Button
		if (changePasswordButton == nil) {
			changePasswordButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
			[changePasswordButton setFrame:CGRectMake(60.0,
													  170.0,
													  200.0,
													  40.0)];
			/*UIImage *img = [Util thumbnailImage:changePasswordButtonImage];
			changePasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
			//[changePasswordButton setFrame:changePasswordButtonImage];//img.size.width
			[changePasswordButton setBackgroundImage:img forState:UIControlStateNormal];*/
		}
		
		//TODO:Need confirmation on the "Change Password" button, whether it should be a Text laid Button or a Button with Image.
		
		[changePasswordButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[changePasswordButton setTitle:RPLocalizedString(@"Change Password", @"Change Password")  forState:UIControlStateNormal];
		[changePasswordButton  addTarget:self action:@selector(changePasswordAction)
						forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:changePasswordButton];
		
	}
	return self;
}
#pragma mark 
#pragma mark ButtonActions
-(void)changePasswordAction{
	
	
	
	[self validateFields];
	//Confirmation Dialog
	//[self confirmationAlert:nil confirmMessage:@"Password changed"];

}
-(void) confirmationAlert :(NSString *)_buttonTitle confirmMessage:(NSString*) message {
	
	
	UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:nil message:message
															  delegate:self cancelButtonTitle:RPLocalizedString(@"Cancel", @"Cancel")  otherButtonTitles:RPLocalizedString(SUBMIT, SUBMIT),nil];
	[confirmAlertView setDelegate:self];
	[confirmAlertView setTag:0];
	[confirmAlertView show];
	
	
}
-(void)changePasswordCancelAction{
	
	
	//Pop to Login View Controller
	//[self.navigationController popViewControllerAnimated:YES];
	[[NSNotificationCenter defaultCenter]postNotificationName:@"RESIGN_KEYBOARD_NOTIFICATION" object:nil]; 
	NSIndexPath *index;
	index = [NSIndexPath indexPathForRow:PASSWORD inSection:0];
	
	G2ChangePasswordCell *cell = (G2ChangePasswordCell *)[self.changePasswordTableView cellForRowAtIndexPath:index];
	[cell.passwordField resignFirstResponder];
	

	//[[[UIApplication sharedApplication] delegate] performSelector:@selector(launchLoginViewController)];
	[self.navigationController popViewControllerAnimated:YES];
}
-(void)validateFields{
	
	
	
	G2ChangePasswordCell *cell;
	NSIndexPath *indexPath;
	
	indexPath = [NSIndexPath indexPathForRow:PASSWORD inSection:0];
	cell = (G2ChangePasswordCell *) [self.changePasswordTableView cellForRowAtIndexPath:indexPath];
	[self setPasswordStr:cell.passwordField.text];
	
	
	indexPath = [NSIndexPath indexPathForRow:VERIFY inSection:0];
	cell = (G2ChangePasswordCell *) [self.changePasswordTableView cellForRowAtIndexPath:indexPath];
	[self setVerifyStr:cell.verifyField.text];
	
	
	if ([passwordStr length]==0 && [verifyStr length]==0) {
		//Alert with message: "Please complete all fields."
		[G2Util errorAlert:@"" errorMessage:RPLocalizedString( @"Please complete all fields.",@"")];
		return;
	}else if(![passwordStr isEqualToString:verifyStr]) {
		//Alert with message: "The values do not match."
		[G2Util errorAlert:@"" errorMessage:RPLocalizedString( @"The values do not match.",@"")];
		return;
	}else {
		[[NSUserDefaults standardUserDefaults] setObject:passwordStr forKey:@"PASSWORD_CHANGED"];
         [[NSUserDefaults standardUserDefaults]  synchronize];
		[self confirmationAlert:nil confirmMessage:RPLocalizedString( @"Change Password?",@"")];
	}
}

#pragma mark -
#pragma mark View lifecycle

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/


- (void)viewWillAppear:(BOOL)animated {
	//Add Cancel Button
	//UIImage *cancelImg=[Util thumbnailImage:CancelImage];
	//UIImage *cancelImg=[Util thumbnailImage:@"cancel_button_up_s1.png"];
//	rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	[rightButton setFrame:CGRectMake(0.0, 0.0, cancelImg.size.width, cancelImg.size.height)];
//	[rightButton setImage:cancelImg forState:UIControlStateNormal];
//	[rightButton addTarget:self action:@selector(changePasswordCancelAction) forControlEvents:UIControlEventTouchUpInside];
//	[rightButton setTag:2];
	
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(@"Cancel", @"Cancel")  
																	 style:UIBarButtonItemStylePlain 
																	target:self 
																	action:@selector(changePasswordCancelAction)];
	[self.navigationItem setRightBarButtonItem:cancelButton animated:NO];
	
	
		//[self.navigationController.navigationBar setTintColor:RepliconStandardNavBarTintColor];
    [super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
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
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	return 50.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	if (section == 0) {
		if (sectionHeader == nil) {
			sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(enterNewPasswordLabel.frame.origin.x,
																	 enterNewPasswordLabel.frame.origin.y,
																	 enterNewPasswordLabel.frame.size.width,
																	 enterNewPasswordLabel.frame.size.height)];
		}
		[sectionHeader addSubview:enterNewPasswordLabel];
		[sectionHeader setBackgroundColor:[UIColor colorWithRed:237/255.0 
														  green:237/255.0 
														   blue:237/255.0 
														  alpha:1.0]];//UIColor::NewExpenseSheetBackgroundColor
		return sectionHeader;
	}
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ChangePasswordCell";
    
    G2ChangePasswordCell *cell = (G2ChangePasswordCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[G2ChangePasswordCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (indexPath.row == 0) {
		
		[cell createTextFieldToChangePasswordCell:indexPath.row];
		[cell.passwordField setTag:PASSWORD];
		[cell.passwordField setPlaceholder:@"Password"];
		[cell.passwordField becomeFirstResponder];
		[cell.passwordField setDelegate:self];
	}else if (indexPath.row == 1) {
		[cell createTextFieldToChangePasswordCell:indexPath.row];
		[cell.verifyField setPlaceholder:RPLocalizedString(@"Verify",@"")];
		[cell.verifyField setDelegate:self];
		[cell.passwordField setTag:VERIFY];
		
	}
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	[cell setBackgroundColor:[UIColor whiteColor]];

    // Configure the cell...
    
    return cell;
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


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    
    */
}
#pragma mark -
#pragma mark Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==SAML_SESSION_TIMEOUT_TAG)
    {
        [[[UIApplication sharedApplication]delegate] performSelector:@selector(launchWebViewController)];
    }
    else
    {
        if (buttonIndex ==1) {
            
          
            
            [self submitAction];
            
        }
    }
	
}
-(void)submitAction{
	
	
	
	//Start ProgressView
	[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
	
	//Send Request for Changed Password
	[[G2RepliconServiceManager loginService] sendRequestToSubmitChangePassword:self];
}
- (void)alertViewCancel:(UIAlertView *)alertView{
	
	
}
#pragma mark ServerResponseProtocol methods
#pragma mark -

- (void) serverDidRespondWithResponse:(id) response{
	
	if (response != nil) {
		NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
		NSNumber *serviceID=[[response objectForKey:@"refDict"]objectForKey:@"refID"];
		
		if ([status isEqualToString:@"OK"]) {		  
			if ([serviceID intValue]== SubmitChangePassword_ServiceId_32) {
				
				G2LoginModel *loginModelObj=[[G2LoginModel alloc] init];
				[loginModelObj updateChangePasswordFlagManually];
				[self handleChangePasswordResponse:[[response objectForKey:@"response"]objectForKey:@"Value"]];
				
				
				}
		}else {
		
		NSString *message = [[response objectForKey:@"response"]objectForKey:@"Message"];
		[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
//		[Util errorAlert:status errorMessage:message];
            [G2Util errorAlert:@"" errorMessage:message];//Fix For DE1231//Juhi
		}
	}
}
- (void) serverDidFailWithError:(NSError *) error{
    [self showErrorAlert:error];
}


-(void)showErrorAlert:(NSError *) error
{
    RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    if ([appdelegate.errorMessageForLogging isEqualToString:SESSION_EXPIRED]) {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
        {
            UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:nil message:RPLocalizedString(SESSION_EXPIRED, SESSION_EXPIRED)
                                                                      delegate:self cancelButtonTitle:RPLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
            [confirmAlertView setDelegate:self];
            [confirmAlertView setTag:SAML_SESSION_TIMEOUT_TAG];
            [confirmAlertView show];
            
        }
        else 
        {
            [G2Util errorAlert:AUTOLOGGING_ERROR_TITLE errorMessage:RPLocalizedString(SESSION_EXPIRED, SESSION_EXPIRED) ];
        }
        
    }
    else  if ([appdelegate.errorMessageForLogging isEqualToString:G2PASSWORD_EXPIRED]) {
        [G2Util errorAlert:AUTOLOGGING_ERROR_TITLE errorMessage:RPLocalizedString(G2PASSWORD_EXPIRED, G2PASSWORD_EXPIRED) ];
        [[[UIApplication sharedApplication]delegate] performSelector:@selector(reloaDLogin)];
    }
    else
    {
        [G2Util errorAlert:RPLocalizedString( @"Connection failed",@"") errorMessage:[error localizedDescription]];
    }
}


-(void)handleChangePasswordResponse:(id)response{
	
	if (response!=nil ) {
		DLog(@"HANDLE CHANGE PASSWORD RESPONSE");
		[loginDelegate performSelector:@selector(sendrequestToCheckExistenceOfUserByLoginName)];
		//[[RepliconServiceManager loginService]sendrequestToCheckExistenceOfUserByLoginNameWithDelegate:parentController];	
	}
	
	//[[[UIApplication sharedApplication] delegate] performSelector:@selector(launchHomeViewController)];
	//[[[UIApplication sharedApplication] delegate] performSelector:@selector(stopProgression)];
}
#pragma mark UITextField Delegates
#pragma mark -

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	
	
	
	return YES;
}  

/**- (void)textFieldDidBeginEditing:(UITextField *)textField {

 
 
 }          
 
 - (BOOL)textFieldShouldEndEditing:(UITextField *)textField {

 [[self textField] resignFirstResponder];
 return YES;
 }**/
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	if ([textField tag] == PASSWORD) {
		[textField resignFirstResponder];
	}
	if ([textField tag] == VERIFY) {
		[textField resignFirstResponder];
	}
	return YES;
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

