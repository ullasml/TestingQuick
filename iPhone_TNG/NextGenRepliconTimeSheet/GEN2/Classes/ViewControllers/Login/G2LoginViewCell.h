//
//  LoginViewCell.h
//  Replicon
//
//  Created by Rohini on 1/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2Constants.h"

@interface G2LoginViewCell : UITableViewCell<UITextFieldDelegate> {

	
	
	UITextField   *companyTextField;
	UITextField   *userNameText;
	UITextField   *pwdText;
	id __strong            refDelegate;
}

@property(nonatomic,strong) id refDelegate;
@property(nonatomic,strong)UITextField *companyTextField;
@property(nonatomic,strong)UITextField *userNameText;
@property(nonatomic,strong)UITextField *pwdText;
-(void)createLablesAndTextFieldsWithIndexpath:(NSInteger) rowValue;
-(void)activeTextField:(NSNumber*)newTag;
@end
