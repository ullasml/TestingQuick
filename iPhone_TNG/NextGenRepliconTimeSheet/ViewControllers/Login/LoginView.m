//
//  LoginView.m
//  NextGenRepliconTimeSheet
//
//  Created by Mike Cheng on 12/23/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "LoginView.h"
#import "Constants.h"
#import "Util.h"
#import "NSString+CompareToVersion.h"
#import "LoginTableViewCell.h"

////
enum {
	PREVIOUS,
	NEXT
};

#define PADDING 22.0

////
@interface LoginView () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic,strong) UIButton *rememberSwitchMark;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,assign) NSInteger numberOfRows;
@property (nonatomic,strong) UIView *buttonHolderView;
@property (nonatomic,strong) UILabel *rememberMeLb;
@property (nonatomic,strong) UIButton *loginButton;
@property (nonatomic,strong) UIButton *googleLoginButton;
@property (nonatomic,strong) UIView *googleButtonHolderView;
@property (nonatomic,strong) UILabel *orTextLb;
@property (nonatomic,strong) UIButton *troubleSignButton;
@property (nonatomic,strong) UIActivityIndicatorView *activityIndicator;

@property (nonatomic,strong) UIToolbar *toolbar;
@property (nonatomic,strong) UISegmentedControl *toolbarSegmentControl;
@property (nonatomic,strong) UITextField *currentTextFiled;
@end


////
@implementation LoginView

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.numberOfRows = 2;
		[self setBackgroundColor:[UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0]];
		[self _setupLoginView];
	}
	return self;
}

- (void)_setupLoginView {
	if (self.tableView == nil) {
		self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(15.0,15, self.frame.size.width-30, LOGIN_CELL_ROW_HEIGHT*2) style:UITableViewStylePlain];
	}
	[self.tableView setDelegate:self];
	[self.tableView setDataSource:self];
	[self.tableView setScrollEnabled:NO];
	[self.tableView setClipsToBounds:YES];
	[self.tableView.layer setCornerRadius:10.0];
	[self.tableView.layer setBorderWidth:.5f];
	[self.tableView.layer setBorderColor:RepliconStandardGrayColor.CGColor];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
	[self.tableView setBackgroundColor:[UIColor clearColor]];
	[self.tableView setBackgroundView:nil];
	[self.tableView reloadData];	// force cell creation at initialization
	[self addSubview:self.tableView];

	
	float tableViewHeight = self.numberOfRows * LOGIN_CELL_ROW_HEIGHT;
	
	if (self.buttonHolderView == nil) {
		self.buttonHolderView = [[UIView alloc] initWithFrame:CGRectMake(0, self.tableView.frame.origin.y+tableViewHeight+19, SCREEN_WIDTH, SCREEN_HEIGHT)];
	}
	[self.buttonHolderView setBackgroundColor:[UIColor clearColor]];
	

	if (self.rememberMeLb == nil) {
		self.rememberMeLb = [[UILabel alloc] init];
	}
	
	//Implementation as per US9414//JUHI
	
	// Let's make an NSAttributedString first
	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:RPLocalizedString(REMEMBER_ME, @"")];
	//Add LineBreakMode
	NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
	[paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
	[attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
	// Add Font
	[attributedString setAttributes:@{NSFontAttributeName:[UIFont fontWithName:RepliconFontHelveticaFamily size:RepliconFontSize_14]} range:NSMakeRange(0, attributedString.length)];
	
	//Now let's make the Bounding Rect
	CGSize mainSize1  = [attributedString boundingRectWithSize:CGSizeMake(300.0, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
	
	[self.rememberMeLb setFrame:CGRectMake(49, 10, mainSize1.width, mainSize1.height)];
	[self.rememberMeLb setNumberOfLines:2];
	[self.rememberMeLb setText:RPLocalizedString(REMEMBER_ME, @"")];
	[self.rememberMeLb setBackgroundColor:[UIColor clearColor]];
	[self.rememberMeLb setTextAlignment:NSTextAlignmentLeft];
	[self.rememberMeLb setTextColor:[Util colorWithHex:@"#666666" alpha:1]];
	[self.rememberMeLb setFont:[UIFont fontWithName:RepliconFontHelveticaFamily size:RepliconFontSize_14]];
	[self.rememberMeLb setUserInteractionEnabled:YES];
	
	[self.buttonHolderView addSubview:self.rememberMeLb];

	
	UIImage *rememberSwitchMarkImage = [Util thumbnailImage:icon_rememberMe_checked];
	if (self.rememberSwitchMark == nil) {
		self.rememberSwitchMark = [[UIButton alloc]initWithFrame:CGRectMake(10, 0, 38, 38)];
	}
	[self.rememberSwitchMark setBackgroundColor:[UIColor clearColor]];
	[self.rememberSwitchMark setImage:rememberSwitchMarkImage forState:UIControlStateNormal];
	[self.rememberSwitchMark setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[self.rememberSwitchMark setUserInteractionEnabled:YES];
	[self.rememberSwitchMark setImageEdgeInsets:UIEdgeInsetsMake(0.0, 5.0, 0, 0.0)];
	[self.rememberSwitchMark setHidden:NO];
	[self.rememberSwitchMark addTarget:self action:@selector(_rememberSwitchChanged:) forControlEvents:UIControlEventTouchUpInside];
	[self setShouldRememberMe:self.shouldRememberMe];	// force update checkmark state

	float buttonHeight = 44;
	
	[self.buttonHolderView addSubview:self.rememberSwitchMark];

	if (self.loginButton == nil) {
		self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[self.loginButton setFrame:CGRectMake(PADDING,self.rememberSwitchMark.frame.origin.y+self.rememberSwitchMark.frame.size.height+18,SCREEN_WIDTH - 2*PADDING,buttonHeight)];
	}
	[self.loginButton setTitle:RPLocalizedString(SignIn,SignIn) forState:UIControlStateNormal];
	[self.loginButton setTitleColor:RepliconStandardWhiteColor forState:UIControlStateNormal];
	[self.loginButton.titleLabel setFont:[UIFont fontWithName:RepliconFontHelveticaFamily size:RepliconFontSize_18]];
	[self.loginButton setTitleShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] forState:UIControlStateNormal];
	[self.loginButton addTarget:self action:@selector(_signInButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.loginButton setBackgroundImage:[Util imageWithColor:[UIColor colorWithRed:53/255.0 green:132/255.0 blue:219/255.0 alpha:1.0]] forState:UIControlStateNormal];
	[self.loginButton setBackgroundImage:[Util imageWithColor:[Util colorWithHex:@"#0A5CB6" alpha:1.0]] forState:UIControlStateSelected];
	[self.loginButton.layer setBorderWidth:.5f];
	[self.loginButton.layer setMasksToBounds:YES];
	[self.loginButton.layer setCornerRadius:5];
	[self.loginButton.layer setBorderColor:[UIColor colorWithRed:5/255.0 green:58/255.0 blue:115/255.0 alpha:1.0].CGColor];
	[self.loginButton.titleLabel setShadowOffset:CGSizeMake(0, -1)];
	[self.loginButton setTag:1];
    [self.loginButton setAccessibilityLabel:@"uia_login_button_identifier"];

	[self.buttonHolderView addSubview:self.loginButton];

	
	if (self.googleButtonHolderView == nil) {
		self.googleButtonHolderView = [[UIView alloc] initWithFrame:CGRectMake(0, self.loginButton.frame.origin.y+self.loginButton.frame.size.height+9, SCREEN_WIDTH, SCREEN_HEIGHT)];
	}
	[self.googleButtonHolderView setBackgroundColor:[UIColor clearColor]];

	
	CGSize size = [RPLocalizedString(OR_TEXT, @"") sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.0f]}];

    CGFloat lineLabelWidth = (SCREEN_WIDTH-(2*PADDING))/2 - size.width+5;
    
	UILabel *leftLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, self.orTextLb.frame.origin.y+9, lineLabelWidth, 0.5)];
    if (self.orTextLb == nil) {
        self.orTextLb = [[UILabel alloc] initWithFrame:CGRectMake(leftLineLabel.frame.origin.x+leftLineLabel.frame.size.width+5, 0, size.width, size.height)];
    }
    [self.orTextLb setText:NSLocalizedString(OR_TEXT, @"")];
    [self.orTextLb setBackgroundColor:[UIColor clearColor]];
    [self.orTextLb setTextAlignment:NSTextAlignmentCenter];
    [self.orTextLb setTextColor:[Util colorWithHex:@"#666666" alpha:1]];
    [self.orTextLb setFont:[UIFont fontWithName:RepliconFontHelveticaFamily size:RepliconFontSize_14]];
    
    [self.googleButtonHolderView addSubview:self.orTextLb];
    
	UILabel *rightLineLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.orTextLb.frame.origin.x+self.orTextLb.frame.size.width+5, self.orTextLb.frame.origin.y+9, lineLabelWidth, 0.5)];
	[leftLineLabel setBackgroundColor:RepliconStandardGrayColor];
	[rightLineLabel setBackgroundColor:RepliconStandardGrayColor];
	
	if (self.googleLoginButton == nil) {
		self.googleLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[self.googleLoginButton setFrame:CGRectMake(PADDING,self.orTextLb.frame.origin.y+27,SCREEN_WIDTH - 2*PADDING,buttonHeight)];
	}
	
	[self.googleLoginButton setTitle:RPLocalizedString(SIGN_IN_WITH_GOOGLE,SIGN_IN_WITH_GOOGLE) forState:UIControlStateNormal];
	[self.googleLoginButton setTitleColor:RepliconStandardBlackColor forState:UIControlStateNormal];
	[self.googleLoginButton.titleLabel setFont:[UIFont fontWithName:RepliconFontHelveticaFamily size:RepliconFontSize_18]];
	[self.googleLoginButton addTarget:self action:@selector(_googleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.googleLoginButton setBackgroundColor:RepliconStandardWhiteColor];
	[self.googleLoginButton setBackgroundImage:[Util imageWithColor:RepliconStandardWhiteColor] forState:UIControlStateNormal];
	[self.googleLoginButton setBackgroundImage:[Util imageWithColor:(UIColor *)UIColorFromRGB(0xD8D8D8)] forState:UIControlStateSelected];
	[self.googleLoginButton.layer setBorderWidth:.5f];
	[self.googleLoginButton.layer setCornerRadius:5];
	[self.googleLoginButton.layer setBorderColor:[UIColor colorWithRed:176/255.0 green:176/255.0 blue:176/255.0 alpha:1.0].CGColor];
	[self.googleLoginButton.layer setShadowOffset:CGSizeMake(0, -1)];
	[self.googleLoginButton.layer setMasksToBounds:YES];
	[self.googleLoginButton setTag:2];
	
	[self.googleButtonHolderView addSubview:leftLineLabel];
	[self.googleButtonHolderView addSubview:self.googleLoginButton];
	[self.googleButtonHolderView addSubview:rightLineLabel];
	[self.buttonHolderView addSubview:self.googleButtonHolderView];
	

	if (self.troubleSignButton == nil) {
		self.troubleSignButton = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-64-30-buttonHeight, SCREEN_WIDTH, buttonHeight)];
	}
	
	[self.troubleSignButton setTitle:RPLocalizedString(@"Having trouble signing in?", @"") forState:UIControlStateNormal];
	[self.troubleSignButton setBackgroundColor:[UIColor clearColor]];
	[self.troubleSignButton setTitleColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:201/255.0 alpha:1.0] forState:UIControlStateNormal];
	[self.troubleSignButton.titleLabel setFont:[UIFont fontWithName:RepliconFontHelveticaFamily size:RepliconFontSize_16]];
    [self.troubleSignButton.titleLabel setNumberOfLines:0];
    [self.troubleSignButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
	[self.troubleSignButton addTarget:self action:@selector(_troubleSigningInAction:) forControlEvents:UIControlEventTouchUpInside];
	
	self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[self.activityIndicator setFrame:CGRectMake(SCREEN_WIDTH-self.loginButton.frame.origin.x-5-32, self.loginButton.frame.origin.y+7, 32, 32)];
	[self.buttonHolderView addSubview:self.activityIndicator];
	
	[self addSubview:self.buttonHolderView];
	[self addSubview:self.troubleSignButton];
	
	[self createToolbar];
}


#pragma mark - Setters and Getters

- (void)setShouldRememberMe:(BOOL)shouldRememberMe {
	_shouldRememberMe = shouldRememberMe;
	
	// Set the button image if the view is initialized
	if (self.rememberSwitchMark != nil) {
		if (_shouldRememberMe) {
			[self.rememberSwitchMark setImage:[Util thumbnailImage:icon_rememberMe_checked] forState:UIControlStateNormal];
			[self.rememberSwitchMark setTag:0];
		} else {
			[self.rememberSwitchMark setImage:[Util thumbnailImage:icon_rememberMe_unchecked] forState:UIControlStateNormal];
			[self.rememberSwitchMark setTag:1];
		}
	}
}

- (void)setShouldShowGoogleSignIn:(BOOL)shouldShowGoogleSignIn {
	_shouldShowGoogleSignIn = shouldShowGoogleSignIn;
	
	if (shouldShowGoogleSignIn) {
		[self _showGoogleButtonHolder];
	} else {
		[self _hideGoogleButtonHolder];
	}
}

- (void)setShouldShowPasswordField:(BOOL)shouldShowPasswordField {
	_shouldShowPasswordField = shouldShowPasswordField;
	
	if (shouldShowPasswordField) {
		[self _showPasswordField];
	} else {
		[self _hidePasswordField];
	}
}

- (UITextField *)companyTextField {
    UITextField * companyTextField = [(LoginTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] textField];
    [companyTextField setAccessibilityLabel:@"uia_company_textfield_identifier"];
    //companyTextField.text = @"diptar-1492191972104-us-west-2-mobile.replicondev.net:805/saitest";
	return companyTextField;
}

- (UITextField *)usernameTextField {
    UITextField * usernameTextField = [(LoginTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] textField];
    [usernameTextField setAccessibilityLabel:@"uia_username_textfield_identifier"];
    //usernameTextField.text = @"sp";
	return usernameTextField;
}

- (UITextField *)passwordTextField {
    UITextField * passwordTextField = [(LoginTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] textField];
    [passwordTextField setAccessibilityLabel:@"uia_password_button_identifier"];
    //passwordTextField.text = @"Password123";
    return passwordTextField;
}


#pragma mark -

- (void)_showPasswordField {
	if (self.numberOfRows == 2) {
		self.numberOfRows = 3;
		
		[self _animateButtonHolderView];
		
		self.tableView.frame = CGRectMake(15, 15, self.frame.size.width-30, LOGIN_CELL_ROW_HEIGHT*self.numberOfRows);
		[self.tableView beginUpdates];
		NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
		[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView endUpdates];
		
		[[self passwordTextField] setText:@""];
		[[self usernameTextField] setReturnKeyType:UIReturnKeyNext];
	}
}

- (void)_hidePasswordField {
	if (self.numberOfRows == 3) {
		self.numberOfRows = 2;
		
		[self _animateButtonHolderView];
		
		[UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
			self.tableView.frame = CGRectMake(15, 15, self.frame.size.width-30, LOGIN_CELL_ROW_HEIGHT*self.numberOfRows);
		} completion:^(BOOL finished) {
			
		}];
		
		[self.tableView beginUpdates];
		NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
		[self.tableView endUpdates];
		
		[[self passwordTextField] setText:@""];
		[[self usernameTextField] setReturnKeyType:UIReturnKeyGo];
	}
}

- (void)_showGoogleButtonHolder {
	[UIView animateWithDuration:1.0f
						  delay:0
						options:UIViewAnimationOptionCurveEaseIn
					 animations:^{
						 self.googleButtonHolderView.alpha = 1.0f;
					 } completion:^(BOOL finished) {
					 }];
}

- (void)_hideGoogleButtonHolder {
	[UIView animateWithDuration:1.0f
						  delay:0
						options:UIViewAnimationOptionCurveEaseOut
					 animations:^{
						 self.googleButtonHolderView.alpha = 0.0f;
					 } completion:^(BOOL finished) {
					 }];
}

- (void)_animateButtonHolderView {
	[UIView animateWithDuration:.3f
						  delay:0
						options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 self.buttonHolderView.frame = CGRectMake(0, 15+self.numberOfRows*44+19, SCREEN_WIDTH, SCREEN_HEIGHT);
					 } completion:nil];
}

- (void)_rememberSwitchChanged:(id)sender {
	[self setShouldRememberMe:!self.shouldRememberMe];
	
	if ([self.loginViewDelegate respondsToSelector:@selector(loginView:rememberSwitchChanged:)]) {
		[self.loginViewDelegate loginView:self rememberSwitchChanged:self.shouldRememberMe];
	}
}


#pragma mark - Button loading methods

- (void)showSignInButtonLoadingWithMessage:(NSString *)message {
	[self setUserInteractionEnabled:NO];
	
	[self.loginButton setTitle:message forState:UIControlStateNormal];
	[self.googleLoginButton setTitle:RPLocalizedString(SIGN_IN_WITH_GOOGLE,SIGN_IN_WITH_GOOGLE) forState:UIControlStateNormal];
	
	[self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
	[self.activityIndicator setFrame:CGRectMake(self.frame.size.width-self.loginButton.frame.origin.x-5-32, self.loginButton.frame.origin.y+7, 32, 32)];
	[self.activityIndicator startAnimating];
}

- (void)showGoogleButtonLoadingWithMessage:(NSString *)message {
	[self setUserInteractionEnabled:NO];
	
	[self.loginButton setTitle:RPLocalizedString(SignIn,SignIn) forState:UIControlStateNormal];
	[self.googleLoginButton setTitle:message forState:UIControlStateNormal];
	
	[self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
	[self.activityIndicator setFrame:CGRectMake(self.frame.size.width-self.googleLoginButton.frame.origin.x-5-32, self.googleButtonHolderView.frame.origin.y+34, 32, 32)];
	[self.activityIndicator startAnimating];
}

- (void)stopButtonLoading {
	[self setUserInteractionEnabled:YES];
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"]) {
        [self.activityIndicator stopAnimating];
        [self.loginButton setTitle:RPLocalizedString(SignIn,SignIn) forState:UIControlStateNormal];
        [self.googleLoginButton setTitle:RPLocalizedString(SIGN_IN_WITH_GOOGLE,SIGN_IN_WITH_GOOGLE) forState:UIControlStateNormal];
    }
}


#pragma mark -
#pragma mark Toolbar methods
/************************************************************************************************************
 @Function Name   : createToolbar
 @Purpose         : Called to create toolbar with previous next buttons.
 @param           : delegate
 @return          : nil
 *************************************************************************************************************/

- (void)createToolbar {
	if (self.toolbar == nil) {
		self.toolbar = [[UIToolbar alloc] init];
        [self.toolbar sizeToFit];
	}
	
    UIImage *backgroundImage = [Util thumbnailImage:TOOLBAR_IMAGE];
    [self.toolbar setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
    [self.toolbar setTintColor:[Util colorWithHex:@"#dddddd" alpha:1]];
    [self.toolbar setBarStyle:UIBarStyleBlackTranslucent];
	[self.toolbar setTranslucent:YES];
	
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																				target:self
																				action:@selector(_doneButtonAction:)];
	UIBarButtonItem *spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																				 target:nil
																				 action:nil];
	if (self.toolbarSegmentControl == nil)
	{
		self.toolbarSegmentControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:
																				RPLocalizedString(@"Previous",@""),
																				RPLocalizedString(@"Next",@""),
																				nil]];
		[self.toolbarSegmentControl setWidth:70.0 forSegmentAtIndex:PREVIOUS];
		[self.toolbarSegmentControl setWidth:70.0 forSegmentAtIndex:NEXT];
        [self.toolbarSegmentControl sizeToFit];
	}
    UIBarButtonItem *segmentButton = [[UIBarButtonItem alloc] initWithCustomView:self.toolbarSegmentControl];
	[self.toolbarSegmentControl addTarget:self action:@selector(_segmentClick:) forControlEvents:UIControlEventValueChanged];
	[self.toolbarSegmentControl setMomentary:YES];
	[self.toolbarSegmentControl setTintColor:[UIColor whiteColor]];

    [self.toolbarSegmentControl setAccessibilityLabel:@"uia_login_screen_toolbar_identifier"];
	NSArray *toolArray = [NSArray arrayWithObjects:segmentButton,spaceButton,doneButton,nil];
	[self.toolbar setItems:toolArray];
}

- (void)showToolBar {
    [self.toolbar setHidden:NO];
    [self.currentTextFiled setInputAccessoryView:self.toolbar];
}

- (void)hideToolBar {
    [self.toolbar setHidden:YES];
}

- (void)_segmentClick:(UISegmentedControl *)segmentControl {
	NSInteger newIndex = [segmentControl tag];
	if ([segmentControl selectedSegmentIndex] == PREVIOUS) {
		newIndex--;
	}
	if ([segmentControl selectedSegmentIndex] == NEXT) {
		newIndex++;
	}
	
	LoginTableViewCell *cell = (LoginTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:newIndex inSection:0]];
	[[cell textField] becomeFirstResponder];
}

- (void)_updatePrevNextSegmentWithRow:(NSInteger)row {
	[self.toolbarSegmentControl setTag:row];
	
	if (row == 0) {
		[self.toolbarSegmentControl setEnabled:NO forSegmentAtIndex:PREVIOUS];
		[self.toolbarSegmentControl setEnabled:YES forSegmentAtIndex:NEXT];
	}
	if (row == 1) {
		[self.toolbarSegmentControl setEnabled:YES forSegmentAtIndex:PREVIOUS];
		[self.toolbarSegmentControl setEnabled:self.shouldShowPasswordField forSegmentAtIndex:NEXT];
	}
	if (row == 2) {
		[self.toolbarSegmentControl setEnabled:YES forSegmentAtIndex:PREVIOUS];
		[self.toolbarSegmentControl setEnabled:NO forSegmentAtIndex:NEXT];
	}
}


#pragma mark -

- (void)_doneButtonAction:(id)sender {
	if ([self.loginViewDelegate respondsToSelector:@selector(loginView:doneButtonAction:)]) {
		[self.loginViewDelegate loginView:self doneButtonAction:sender];
	}
}

- (void)_signInButtonAction:(id)sender {
	if ([self.loginViewDelegate respondsToSelector:@selector(loginView:signInButtonAction:)]) {
		[self.loginViewDelegate loginView:self signInButtonAction:sender];
	}
}

- (void)_googleButtonAction:(id)sender {
	if ([self.loginViewDelegate respondsToSelector:@selector(loginView:googleButtonAction:)]) {
		[self.loginViewDelegate loginView:self googleButtonAction:sender];
	}
}

- (void)_feedbackButtonAction:(id)sender {
	if ([self.loginViewDelegate respondsToSelector:@selector(loginView:feedbackButtonAction:)]) {
		[self.loginViewDelegate loginView:self feedbackButtonAction:sender];
	}
}

-(void)_troubleSigningInAction:(id)sender {
    if([self.loginViewDelegate respondsToSelector:@selector(loginView:troubleSigningInAction:)]) {
        [self.loginViewDelegate loginView:self troubleSigningInAction:sender];
    }
}


#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return LOGIN_CELL_ROW_HEIGHT;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *CellIdentifier = @"Cell";
	
	LoginTableViewCell *cell = (LoginTableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[LoginTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	[cell setBackgroundColor:[UIColor whiteColor]];
	[cell.textField setDelegate:self];
	[cell.textField setSecureTextEntry:NO];
	[cell.textField setReturnKeyType:UIReturnKeyNext];
	[cell.textField setTag:[indexPath row]];
	
	switch ([cell.textField tag]) {
		case 0:	// Company name
			[cell.textField setPlaceholder:RPLocalizedString(@"Company Name", @"")];
			break;

		case 1:	// User name
			[cell.textField setPlaceholder:RPLocalizedString(@"User Name", @"")];
			if (self.shouldShowPasswordField == NO) {
				[cell.textField setReturnKeyType:UIReturnKeyGo];
			}
			break;
			
		case 2: // Password
			[cell.textField setPlaceholder:RPLocalizedString(@"Password", @"")];
			[cell.textField setReturnKeyType:UIReturnKeyGo];
			[cell.textField setSecureTextEntry:YES];
			break;
			
		default:
			[cell.textField setPlaceholder:nil];
			break;
	}
	
	return cell;
}


#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	[self _updatePrevNextSegmentWithRow:[textField tag]];
    self.currentTextFiled = textField;
    [self showToolBar];
	return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if ([textField returnKeyType] == UIReturnKeyGo) {
		[self _signInButtonAction:nil];
	} else if ([textField returnKeyType] == UIReturnKeyNext) {
		// go to next segment
	} else {
		[self _doneButtonAction:nil];
	}
	[textField resignFirstResponder];
	[self hideToolBar];
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if ([textField tag] == 0) {
		[self setShouldShowPasswordField:NO];
		[self setShouldShowGoogleSignIn:YES];
	}
	return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	if ([textField tag] == 0) {
		[self setShouldShowPasswordField:NO];
		[self setShouldShowGoogleSignIn:YES];
	}
	return YES;
}


#pragma mark - Helper methods



- (void) dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

@end
