//
//  LoginTableViewCell.m
//  NextGenRepliconTimeSheet
//
//  Created by Mike Cheng on 12/24/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "LoginTableViewCell.h"
#import "Constants.h"


////
@interface LoginTableViewCell ()

@property (nonatomic, strong, readwrite) UITextField *textField;

@end


////
@implementation LoginTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.textField = [[UITextField alloc] initWithFrame:CGRectMake(10, -2, SCREEN_WIDTH - 50, self.frame.size.height)];
		[self.textField setFont:[UIFont fontWithName:RepliconFontHelveticaFamily size:RepliconFontSize_16]];
		[self.textField setBorderStyle:UITextBorderStyleNone];
		
		[self.textField setTextAlignment:NSTextAlignmentLeft];
		[self.textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		
		[self.textField setKeyboardAppearance:UIKeyboardAppearanceDefault];
		[self.textField setKeyboardType:UIKeyboardTypeASCIICapable];
		[self.textField setAutocorrectionType:UITextAutocorrectionTypeNo];
		[self.textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[self.textField setBackgroundColor:[UIColor clearColor]];

		//Implementation For Mobi-190//Reset Password//JUHI
		[self.textField setTextColor:[UIColor blackColor]];
		[self.textField setClearButtonMode:UITextFieldViewModeWhileEditing];
		
		[self.contentView addSubview:self.textField];
	}
	return self;
}

@end
