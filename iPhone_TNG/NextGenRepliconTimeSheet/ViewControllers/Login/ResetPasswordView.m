//
//  ResetPasswordView.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta Rakshit on 1/15/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import "ResetPasswordView.h"
#import "Constants.h"
#import "LoginTableViewCell.h"

#define PADDING 22.0
#define RESET_VIEW_NUMBER_OF_ROWS 3

enum {
    oldPasswordIndex=0,
    newPasswordIndex=1,
    confirmPasswordIndex=2,
};


@interface ResetPasswordView () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITableView  *resetPasswordTableView;
@property (nonatomic, strong) UIButton	   *resetButton;
@property (nonatomic,strong)  UIActivityIndicatorView *activityIndicator;

@end



@implementation ResetPasswordView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:RepliconStandardBackgroundColor];
        [self _setupResetPasswordView];
    }
    return self;
}

-(void)_setupResetPasswordView
{
    if (self.resetPasswordTableView ==nil) {
        self.resetPasswordTableView = [[UITableView alloc]initWithFrame:CGRectMake(15.0,10, self.frame.size.width-30, LOGIN_CELL_ROW_HEIGHT * RESET_VIEW_NUMBER_OF_ROWS) style:UITableViewStylePlain];
    }
    [self.resetPasswordTableView setDelegate:self];
    [self.resetPasswordTableView setDataSource:self];
    [self.resetPasswordTableView setTag:1];
    [self.resetPasswordTableView setScrollEnabled:NO];
    [self.resetPasswordTableView setBackgroundColor:[UIColor clearColor]];
    [self.resetPasswordTableView setClipsToBounds:YES];
    [self.resetPasswordTableView.layer setCornerRadius:10.0];
    [self.resetPasswordTableView.layer setBorderWidth:.5f];
    [self.resetPasswordTableView.layer setBorderColor:RepliconStandardGrayColor.CGColor];
    [self addSubview:self.resetPasswordTableView];

    self.resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.resetButton setFrame:CGRectMake(PADDING, self.resetPasswordTableView.frame.size.height+15.0, self.frame.size.width- (2*PADDING), 44)];
    [self.resetButton setTitleColor:RepliconStandardWhiteColor forState:UIControlStateNormal];
    [self.resetButton setTitle:RPLocalizedString(RESET_PASSWORD,@"") forState:UIControlStateNormal];
    [self.resetButton  addTarget:self action:@selector(_updatePasswordAction) forControlEvents:UIControlEventTouchUpInside];
    [self.resetButton.titleLabel setFont:[UIFont fontWithName:RepliconFontHelveticaFamily size:RepliconFontSize_18]];
    [self.resetButton setTitleShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] forState:UIControlStateNormal];
    [self.resetButton setBackgroundImage:[Util imageWithColor:[UIColor colorWithRed:53/255.0 green:132/255.0 blue:219/255.0 alpha:1.0]] forState:UIControlStateNormal];
    [self.resetButton setBackgroundImage:[Util imageWithColor:[Util colorWithHex:@"#0A5CB6" alpha:1.0]] forState:UIControlStateSelected];
    [self.resetButton.layer setBorderWidth:.5f];
    [self.resetButton.layer setMasksToBounds:YES];
    [self.resetButton.layer setCornerRadius:5];
    [self.resetButton.layer setBorderColor:[UIColor colorWithRed:5/255.0 green:58/255.0 blue:115/255.0 alpha:1.0].CGColor];
    [self.resetButton.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    [self addSubview:self.resetButton];
    
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activityIndicator=activityView;
    [self.activityIndicator setFrame:CGRectMake(5, 8, 32, 32)];
    [self.resetButton addSubview:self.activityIndicator];
}

-(void)_updatePasswordAction
{
    CLS_LOG(@"-----Save New Password Action on ResetPasswordView-----");
    if ([self.resetPasswordViewDelegate respondsToSelector:@selector(resetPasswordViewAction:)])
    {
        [self.resetPasswordViewDelegate resetPasswordViewAction:self];
    }
    
}

#pragma mark Table view delegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return RESET_VIEW_NUMBER_OF_ROWS;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return LOGIN_CELL_ROW_HEIGHT;
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
        case 0:
            [cell.textField setPlaceholder:RPLocalizedString( @"Old Password",@"")];
            break;
            
        case 1:
            [cell.textField setPlaceholder:RPLocalizedString( @"New Password",@"")];
            break;
            
        case 2: 
            [cell.textField setPlaceholder:RPLocalizedString( @"Confirm New Password",@"")];
            break;
            
        default:
            [cell.textField setPlaceholder:nil];
            break;
    }
    
    [cell.textField setReturnKeyType:UIReturnKeyGo];
    [cell.textField setSecureTextEntry:YES];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


#pragma mark Text Field delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
   [self _updatePasswordAction];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string

{
    return YES;
    
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    
    return YES;
}



#pragma mark - Setters and Getters

- (UITextField *)oldPasswordTextField {
    return [(LoginTableViewCell *)[self.resetPasswordTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:oldPasswordIndex inSection:0]] textField];
}

- (UITextField *)newPasswordTextField {
    return [(LoginTableViewCell *)[self.resetPasswordTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:newPasswordIndex inSection:0]] textField];
}

- (UITextField *)confirmPasswordTextField {
    return [(LoginTableViewCell *)[self.resetPasswordTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:confirmPasswordIndex inSection:0]] textField];
}

#pragma mark - Button loading methods

- (void)startButtonLoading
{
    [self setUserInteractionEnabled:NO];
    [self.activityIndicator startAnimating];
    
    [self.oldPasswordTextField resignFirstResponder];
    [self.newPasswordTextField resignFirstResponder];
    [self.confirmPasswordTextField resignFirstResponder];
}

- (void)stopButtonLoading {
    [self setUserInteractionEnabled:YES];
    [self.activityIndicator stopAnimating];
   
}

-(void)dealloc
{
    self.resetPasswordTableView.delegate = nil;
    self.resetPasswordTableView.dataSource = nil;
}

@end
