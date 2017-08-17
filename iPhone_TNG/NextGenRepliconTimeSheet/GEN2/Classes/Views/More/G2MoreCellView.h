//
//  MoreCellView.h
//  Replicon
//
//  Created by Manoj  on 17/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G2Fonts-iPhone.h"
#import "G2Colors-iPhone.h"

@interface G2MoreCellView : UITableViewCell {
	
	UILabel  *preferenceLable;
	UILabel  *secondLabel;
	UISwitch *switchMark;
	
	UITextField *textField;
}
@property(nonatomic,strong)UILabel  *preferenceLable;
@property(nonatomic,strong)UILabel  *secondLabel;
@property(nonatomic,strong)UISwitch *switchMark;
@property(nonatomic,strong)UITextField *textField;
-(void)createPreferencesLable;
-(void)setCellViewState:(BOOL)isSelected;
-(void)createCellForResetPassword:(NSString *)_placeholder keyboardtype:(BOOL )_type;
@end
