//
//  ResetPasswordViewController.m
//  Replicon
//
//  Created by Siddhartha on 07/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2ResetPasswordViewController.h"
#import "RepliconAppDelegate.h"

#define Reset 111
#define GoToLogin 222

@implementation G2ResetPasswordViewController
@synthesize resetPwdButton;
@synthesize resetPwdTableView;
@synthesize delegate;
#pragma mark -
#pragma mark Initialization

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
		if (fieldsArray == nil) {
			fieldsArray = [[NSArray alloc]initWithObjects:@"Company",@"Email Address",nil];
		}
	}
	return self;
}



#pragma mark -
#pragma mark View lifecycle

-(void)loadView {
	[super loadView];
	//[self.navigationController.navigationBar setTintColor:RepliconStandardNavBarTintColor];
	[self.view setBackgroundColor: G2RepliconStandardBackgroundColor];
	[G2ViewUtil setToolbarLabel:self withText:PASSWORD_RESET_TITLE];
	[self setNavigationButtons];
	
	resetPwdButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *img = [G2Util thumbnailImage:DeleteExpenseButton];
	[resetPwdButton setBackgroundImage:img forState:UIControlStateNormal];
	[resetPwdButton setBackgroundImage:[G2Util thumbnailImage:DeleteExpenseButtonSelected] forState:UIControlStateHighlighted];
	[resetPwdButton setFrame:CGRectMake(40.0, 320.0, img.size.width, img.size.height)];
    resetPwdButton.titleEdgeInsets = UIEdgeInsetsMake(-5.0, 0, 0, 0);
	[resetPwdButton setTitle:RPLocalizedString(RESET_PASSWORD_TITLE, RESET_PASSWORD_TITLE) forState:UIControlStateNormal];
	[resetPwdButton setTag:Reset];
	[resetPwdButton addTarget:self action:@selector(resetPwdButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:resetPwdButton];
	
	[self addTable];
}

-(void)addTable {
	resetPwdTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200) style:UITableViewStyleGrouped];
	[resetPwdTableView setDelegate:self];
	[resetPwdTableView setDataSource:self];
	[resetPwdTableView setScrollEnabled:NO];
	[resetPwdTableView setBackgroundColor:G2RepliconStandardBackgroundColor];
	[self.view addSubview:resetPwdTableView];	
}

-(void)setNavigationButtons {
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																				  target:self action:@selector(cancelAction)];
	[self.navigationItem setLeftBarButtonItem:cancelButton];
	
	
	UIBarButtonItem *resetButton = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(RESET,RESET) 
																style:UIBarButtonItemStylePlain 
																   target:self action:@selector(resetPwdButtonClicked:)];
	[resetButton setTag:Reset];
	[self.navigationItem setRightBarButtonItem:resetButton];
	
}

-(void)cancelAction {
	[delegate performSelector:@selector(dehighlightForgotPwdButton)];
	[[[UIApplication sharedApplication]delegate]performSelector:@selector(flipToLoginViewController)];
}

-(void)resetPwdButtonClicked:(id)sender {
	if ([sender tag] == Reset) {
		if ([self validateTableCells]) {
			
		//TODO: Request to Send Reset Password
			//For Testing the UI Only no Query(service) implemented.........
			
			[[[UIApplication sharedApplication] delegate] performSelector:@selector(startProgression:) withObject:RPLocalizedString(LoadingMessage, "")];
			[[G2RepliconServiceManager loginService]sendRequestToResetPassword];
			[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showSuccessScreen) name:RESET_PASSWORD_NOTIFICATION object:nil];
			[self performSelector:@selector(showSuccessScreen) withObject:nil afterDelay:2.5];
				
		}
	}
	else if([sender tag] == GoToLogin)
		[self cancelAction];
}

-(void)showSuccessScreen {
	[[[UIApplication sharedApplication]delegate] performSelector:@selector(stopProgression)];
	[[NSNotificationCenter defaultCenter]removeObserver:self name:RESET_PASSWORD_NOTIFICATION object:nil];
	[resetPwdTableView removeFromSuperview];
	[resetPwdButton setTitle:RPLocalizedString(OK_BTN_TITLE, OK_BTN_TITLE)  forState:UIControlStateNormal];
	[resetPwdButton setTag:GoToLogin];
	[[self.navigationItem rightBarButtonItem] setTitle:RPLocalizedString(OK_BTN_TITLE, OK_BTN_TITLE)];
	[[self.navigationItem rightBarButtonItem] setTag:GoToLogin];
	[self.navigationItem setLeftBarButtonItem:nil];
	
	NSString *labelText1 = @"Thanks John!";
	UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 30.0, 300.0, 30.0)];
	[label1 setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_23]];
	[label1 setTextColor:RepliconTimeEntryHeaderTextColor];
	[label1 setBackgroundColor:[UIColor clearColor]];
	[label1 setText:labelText1];
	NSString *labelText2 = @"We've received your request to reset your password. Please check your email inbox to complete the process.\
							\n\nIf you need additional help, please email us at: support@replicon.com.";
	UILabel	*label2= [[UILabel alloc] initWithFrame:CGRectMake(10.0,
																	80.0,
																	300.0,
																	120.0)];
	[label2 setBackgroundColor:[UIColor clearColor]];
	[label2 setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16]];
	[label2 setTextColor:RepliconStandardGrayColor];
	[label2 setText:RPLocalizedString(labelText2,@"")];
	[label2 setNumberOfLines:6];
	responseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 250)];
	[responseView setBackgroundColor:[UIColor clearColor]];
	[responseView addSubview:label1];
	
	[responseView addSubview:label2];
	
	[self.view addSubview:responseView];
}

-(BOOL)validateTableCells {
	NSString *company = [[(G2MoreCellView*)[resetPwdTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] textField] text];
	if( [company length] == 0 || company == nil) {
//		[Util errorAlert:Enter_Company_Message errorMessage:nil];
        [G2Util errorAlert:@"" errorMessage:RPLocalizedString(Enter_Company_Message, Enter_Company_Message) ];//DE1231//Juhi
		return 0;
	}
	NSString *email = [[(G2MoreCellView*)[resetPwdTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] textField] text];
	if( [email length] == 0 || email == nil) {
//		[Util errorAlert:Enter_Email_Message errorMessage:nil];
        [G2Util errorAlert:@"" errorMessage:RPLocalizedString(Enter_Email_Message, Enter_Email_Message) ];//DE1231//Juhi
		return 0;
	}
	else if (![G2Util validateEmail:email]) {
//		[Util errorAlert:InvalidEmail_Error_Message errorMessage:nil];
        [G2Util errorAlert:@"" errorMessage:RPLocalizedString(InvalidEmail_Error_Message, InvalidEmail_Error_Message) ];//DE1231//Juhi
		return 0;
	}
	return 1;
}

/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/


- (void)viewWillAppear:(BOOL)animated {
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return 95;
	}
	return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {   // custom view for header. will be adjusted to default or specified header height
	if (section ==0) {
		
		NSString *labelText = @"Use this form to request a password reset. We'll send you an email with a link to complete the process.";
		UILabel	*headerLabel= [[UILabel alloc] initWithFrame:CGRectMake(10.0,
																	   10.0,
																	   310.0,
																	   70.0)];
		[headerLabel setBackgroundColor:[UIColor clearColor]];
		[headerLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16]];
			//[otherLabel setTextColor:RepliconStandardBlackColor];
		[headerLabel setTextColor:RepliconStandardGrayColor];
		[headerLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16]];
		[headerLabel setText:RPLocalizedString(labelText,@"")];
		[headerLabel setNumberOfLines:3];
		
		UIView	*headerView = [UIView new];
		[headerView addSubview:headerLabel];
		
		return headerView;
	} 
	return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    G2MoreCellView *cell = (G2MoreCellView*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[G2MoreCellView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    // Configure the cell...
	
	BOOL _type = 0;
	if (indexPath.row == 1) {
		_type = 1;
		
	}
    [cell createCellForResetPassword:[fieldsArray objectAtIndex:indexPath.row] keyboardtype:_type];
	[[cell textField] setDelegate:self];
    return cell;
}

# pragma UITextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField {              // called when 'return' key pressed. return NO to ignore.
	[textField resignFirstResponder];
	return YES;
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
	[[(G2MoreCellView*)[tableView cellForRowAtIndexPath:indexPath] textField] becomeFirstResponder];
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

