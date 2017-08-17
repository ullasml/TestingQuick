	//
	//  MoreCellView.m
	//  Replicon
	//
	//  Created by Manoj  on 17/02/11.
	//  Copyright 2011 __MyCompanyName__. All rights reserved.
	//

#import "G2MoreCellView.h"
#import "G2Constants.h"


@implementation G2MoreCellView
@synthesize preferenceLable;
@synthesize secondLabel;
@synthesize switchMark;
@synthesize textField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
			// Initialization code.
		[self setAccessoryType:UITableViewCellAccessoryNone];
		[self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

-(void)createPreferencesLable
{
	if (preferenceLable==nil) {
		UILabel *temppreferenceLable = [[UILabel alloc]initWithFrame:CGRectMake(12, 8, 170, 30)];//US4065//Juhi
        self.preferenceLable=temppreferenceLable;
       
	}
	[preferenceLable setBackgroundColor:[UIColor clearColor]];
	[preferenceLable setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];//US4065//Juhi
    [preferenceLable setTextColor:RepliconStandardBlackColor];//US4065//Juhi
	[preferenceLable setHighlightedTextColor:iosStandaredWhiteColor];
	[self.contentView addSubview:preferenceLable];
    //Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion floatValue];
	if (switchMark==nil) {
        if (switchMark==nil) {
            float x=197.0;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
                x=214.0;
            }
            //Fix for ios7//JUHI
            CGRect frame;
            if (version>=7.0)
            {
                frame=CGRectMake(x+42, 8.0, 130.0,30.0);
              
            }
            else{
                frame=CGRectMake(x, 8.0, 130.0,30.0);
            }
            UISwitch *tempswitchMark = [[UISwitch alloc] initWithFrame:frame];//US4065//Juhi
           
            self.switchMark=tempswitchMark;
           
        }
	}
    //Fix for ios7//JUHI
    if (version>=7.0)
    {
        [self.switchMark setOnTintColor: RepliconStandardNavBarTintColor];
    }
	[self.contentView addSubview:switchMark];
	[switchMark setHidden:YES];
	
	if (secondLabel==nil) {
        //Fix for ios7//JUHI
        CGRect frame;
        if (version>=7.0)
        {
            frame=CGRectMake(210, 8, 80, 30);
            
        }
        else{
            frame=CGRectMake(190, 8, 80, 30);
        }
		UILabel *tempsecondLabel = [[UILabel alloc] initWithFrame:frame];//US4065//Juhi
        self.secondLabel=tempsecondLabel;
        
	}
	[secondLabel setBackgroundColor:[UIColor clearColor]];
	[secondLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];
	[secondLabel setTextAlignment:NSTextAlignmentRight];
	[secondLabel setTextColor:NewRepliconStandardBlueColor];//US4065//Juhi
    [secondLabel setHighlightedTextColor:iosStandaredWhiteColor];
	[self.contentView addSubview:secondLabel];
	[secondLabel setHidden:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
	[super setSelected:selected animated:animated];
	
		// Configure the view for the selected state.
}

-(void) setCellViewState: (BOOL)isSelected	{
	if (isSelected) {
		[self.preferenceLable setTextColor: iosStandaredWhiteColor];
		[self.secondLabel setTextColor: iosStandaredWhiteColor];
		if (switchMark) {
			if ([switchMark isOn]) {
				[switchMark setOn:NO animated:YES];
			}
			else {
				[switchMark setOn:YES animated:YES];
			}
		}
	}
	else {
		[self.preferenceLable setTextColor: RepliconStandardBlackColor];
		[self.secondLabel setTextColor: NewRepliconStandardBlueColor];//US4065//Juhi
	}
}

-(void)createCellForResetPassword:(NSString *)_placeholder keyboardtype:(BOOL )_type {
	if (textField == nil) {
		UITextField *temptextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 12.5, 250, 35)];
        self.textField=temptextField;
        
	}
	[textField setReturnKeyType:UIReturnKeyDone];
	[textField setTextColor:FieldButtonColor];
	if (_type == 1) {
		[textField setKeyboardType:UIKeyboardTypeEmailAddress];
	}else {
		[textField setKeyboardType:UIKeyboardTypeDefault];
	}
	[textField setPlaceholder:_placeholder];
	[textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[textField setAutocorrectionType:UITextAutocorrectionTypeNo];
	[textField setTextAlignment:NSTextAlignmentLeft];
	[self.contentView addSubview:textField];
	
}



@end
