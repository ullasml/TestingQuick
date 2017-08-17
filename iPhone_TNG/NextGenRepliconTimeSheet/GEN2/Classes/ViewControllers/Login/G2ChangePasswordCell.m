//
//  ChangePasswordCell.m
//  RepliUI
//
//  Created by Swapna P on 4/5/11.
//  Copyright 2011 EnLume. All rights reserved.
//

#import "G2ChangePasswordCell.h"


@implementation G2ChangePasswordCell
@synthesize passwordField;
@synthesize verifyField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}
-(void)createTextFieldToChangePasswordCell:(NSInteger)row{
	if (row == 0) {
		if (passwordField == nil) {
			passwordField = [[UITextField alloc] initWithFrame:CGRectMake(05.0, 05.0,
																	  290.0, 35.0)];
		}
		//[passwordField setDelegate:self];
		[passwordField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		[passwordField setTextColor:[UIColor blackColor]];
		[passwordField setBackgroundColor:[UIColor clearColor]];
		[passwordField setFont:[UIFont fontWithName:@"Helvetica" size:16.0]];
		//[textField setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16]];
		[self.contentView addSubview:passwordField];
	}
	if (row == 1) {
		
		if (verifyField == nil) {
			verifyField = [[UITextField alloc] initWithFrame:CGRectMake(05.0, 05.0,
																	  290.0, 35.0)];
		}
		//[verifyField setDelegate:self];
		[verifyField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		[verifyField setTextColor:[UIColor blackColor]];
		[verifyField setBackgroundColor:[UIColor clearColor]];
		[verifyField setFont:[UIFont fontWithName:@"Helvetica" size:16.0]];
		//[textField setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_16]];
		[self.contentView addSubview:verifyField];
	}
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}
#pragma mark UITextField Delegates
#pragma mark -

/*- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	
	
	return YES;
} */ 

/**- (void)textFieldDidBeginEditing:(UITextField *)textField {
	
	
		
}          

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	
	[[self textField] resignFirstResponder];
	return YES;
}**/
/*- (BOOL)textFieldShouldReturn:(UITextField *)textField{
	
	if ([textField tag] == 0) {
		[textField resignFirstResponder];
	}
	if ([textField tag] == 1) {
		[textField resignFirstResponder];
	}
	return YES;
}*/




@end
