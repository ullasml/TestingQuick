//
//  LoginViewCell.m
//  Replicon
//
//  Created by Rohini on 1/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2LoginViewCell.h"
#import "G2CompanyViewController.h"
#import "G2LoginViewController.h"
@implementation G2LoginViewCell
@synthesize refDelegate,
companyTextField,
userNameText,
pwdText;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


-(void)createLablesAndTextFieldsWithIndexpath:(NSInteger) rowValue
{
	if (rowValue == 0) {
		
		
		if (self.companyTextField==nil){
			self.companyTextField=[[UITextField alloc]initWithFrame:CGRectMake(10, -2, 260, self.frame.size.height)];//CGRectMake(130, 40, 160, 30)
		}
		self.companyTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
		[self.companyTextField setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16]];
		self.companyTextField.placeholder= RPLocalizedString( @"Company",@"");
		//self.companyTextField.returnKeyType = UIReturnKeyDefault;//Fix DE1713//Juhi 
		self.companyTextField.keyboardType = UIKeyboardTypeDefault;
		self.companyTextField.borderStyle = UITextBorderStyleNone;
		self.companyTextField.autocorrectionType = UITextAutocorrectionTypeNo;
		//[self.companyTextField setClearsOnBeginEditing:YES];
		self.companyTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
		self.companyTextField.textAlignment = NSTextAlignmentLeft;
		self.companyTextField.textColor = [UIColor blackColor];
		[self.companyTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		self.companyTextField.tag=rowValue;
		[self.companyTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[self.companyTextField setDelegate:self];
		[self.companyTextField setBackgroundColor:[UIColor clearColor]];
		[self.contentView addSubview:self.companyTextField];
        
        if ([refDelegate isKindOfClass:[G2LoginViewController class]])
        {
            
            [self.companyTextField setTextColor:[UIColor lightGrayColor]];
            self.companyTextField.enabled=TRUE;
            
            UIButton *goBackBtn=[UIButton buttonWithType:UIButtonTypeCustom];
            [goBackBtn setBackgroundColor:[UIColor clearColor]];
            [goBackBtn setFrame:CGRectMake(0,0,35,35)];
            [goBackBtn setImage:[G2Util thumbnailImage:@"G2changeBack.png"] forState:UIControlStateNormal];
            [goBackBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            [goBackBtn addTarget:self action:@selector(goBackAction) forControlEvents:UIControlEventTouchUpInside];
            self.companyTextField.rightView = goBackBtn;
            self.companyTextField.rightViewMode=UITextFieldViewModeAlways;
        }
        
       
        
	} else if (rowValue == 1) {
		
		
		if (userNameText==nil){
			UITextField *tempuserNameText=[[UITextField alloc]initWithFrame:CGRectMake(10, -2, 260, self.frame.size.height)];//CGRectMake(130, 40, 160, 30)
            self.userNameText=tempuserNameText;
            
		}
		userNameText.keyboardAppearance = UIKeyboardAppearanceDefault;
		[userNameText setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16]];
		userNameText.placeholder=RPLocalizedString( @"User Name",@"");
		userNameText.autocorrectionType = UITextAutocorrectionTypeNo;
		//userNameText.returnKeyType = UIReturnKeyDefault;//Fix DE1713//Juhi 
		userNameText.keyboardType = UIKeyboardTypeDefault;
		userNameText.borderStyle = UITextBorderStyleNone;
		userNameText.clearButtonMode = UITextFieldViewModeWhileEditing;
		userNameText.textAlignment = NSTextAlignmentLeft;
		userNameText.textColor = [UIColor blackColor];
		[userNameText setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		userNameText.tag=rowValue;
		[userNameText setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[userNameText setDelegate:self];
		[userNameText setBackgroundColor:[UIColor clearColor]];
		[self.contentView addSubview:userNameText];
	} else if (rowValue == 2) {
		
		
		if (pwdText==nil){
			UITextField *temppwdText=[[UITextField alloc]initWithFrame:CGRectMake(10, -2, 260, self.frame.size.height)];
            self.pwdText=temppwdText;
            
		}
		pwdText.secureTextEntry = YES;
		pwdText.keyboardAppearance = UIKeyboardAppearanceDefault;
		[pwdText setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16]];
		pwdText.placeholder=RPLocalizedString(@"Password",@"");

		pwdText.returnKeyType = UIReturnKeyDefault;
		pwdText.keyboardType = UIKeyboardTypeDefault;
		pwdText.borderStyle = UITextBorderStyleNone;
		pwdText.clearButtonMode = UITextFieldViewModeWhileEditing;
		pwdText.textAlignment = NSTextAlignmentLeft;
		pwdText.textColor = [UIColor blackColor];
		[pwdText setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		pwdText.tag=rowValue;
		[pwdText setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[pwdText setDelegate:self];
		[self.contentView addSubview:pwdText];
	} 
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if ([refDelegate isKindOfClass:[G2LoginViewController class]] && textField==self.companyTextField)
    {
        return NO;
    }
    
    
	[refDelegate performSelector:@selector(changeSegmentControlState:) withObject:[NSNumber numberWithInteger:[textField tag]]];
	[refDelegate performSelector:@selector(setCurrentTextField:) withObject:textField];
    
    if ([refDelegate isKindOfClass:[G2CompanyViewController class] ])
    {
        if (textField.tag==1) {
            [textField setReturnKeyType:UIReturnKeyGo];
        }
    }
    else
    {
        if (textField.tag==2)
        {
            [textField setReturnKeyType:UIReturnKeyGo];
        }
    }
        
	return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	
	if ((textField.tag==0)||(textField.tag==1)) {
        //DE1713//Juhi
        if ([textField returnKeyType]==UIReturnKeyGo) {
            [refDelegate performSelector:@selector(loginAction:)];
        }
        else
        {
            if ([refDelegate isKindOfClass:[G2CompanyViewController class]])
            {
                [refDelegate doneClickAction];
            }
        }
		[textField resignFirstResponder];
		
	}
	
//	if (textField.tag==1) {
//        //DE1713//Juhi
//        if ([textField returnKeyType]==UIReturnKeyGo) {
//            [refDelegate performSelector:@selector(loginAction:)];
//        }
//
//		[textField resignFirstResponder];
//		
//	}
	
	if (textField.tag==2) {
		[refDelegate performSelector:@selector(loginAction:)];
		[textField resignFirstResponder];
		
	}
	return YES;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

-(void)activeTextField:(NSNumber *)newTag {
	if ([newTag intValue] == [self.companyTextField tag]) {
        
		[self.companyTextField becomeFirstResponder];
	}
	else if([newTag intValue] == [userNameText tag]) {
		[userNameText becomeFirstResponder];
	}
	else if([newTag intValue] == [pwdText tag]) {
		[pwdText becomeFirstResponder];
	}
}

-(void)goBackAction
{
    if ([refDelegate respondsToSelector:@selector(companyChanged)])
    {
        
        [( G2LoginViewController *)refDelegate companyChanged];
    }
}




@end
