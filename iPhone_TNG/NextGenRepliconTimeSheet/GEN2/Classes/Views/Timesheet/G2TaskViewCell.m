//
//  TaskViewCell.m
//  Replicon
//
//  Created by vijaysai on 6/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2TaskViewCell.h"
#import "G2Constants.h"
#import "G2Colors-iPhone.h"
#import "G2Util.h"

@implementation G2TaskViewCell

@synthesize fieldName;
@synthesize fieldButton;
@synthesize folderImageView;
@synthesize radioButton;
@synthesize navigationButton;
@synthesize disclosureButton;
@synthesize taskSelected;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}

-(void)addFieldsForTaskViewController:(NSInteger)tagValue text:(NSString *)fieldtext isAddFolder:(BOOL)addFolder isShowNoTasksText:(BOOL)showNoTasksText isTimeEntryAllowed:(BOOL)timeEntryAllowed isassignedToUser:(BOOL)assignedToUser{
	
	UIImage *radioDeselectedImage = [G2Util thumbnailImage:RadioDeselectedImage];
	if (radioButton == nil) {
		radioButton = [UIButton buttonWithType:UIButtonTypeCustom];
		
	}
	[radioButton setBackgroundColor:[UIColor clearColor]];
	[radioButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[radioButton setUserInteractionEnabled:YES];
	[radioButton setHidden:NO];
	[radioButton setTag:tagValue];
	[radioButton setImage:radioDeselectedImage forState:UIControlStateNormal];
    [radioButton setImage:radioDeselectedImage forState:UIControlStateHighlighted];
	[self.contentView addSubview:radioButton];
	
	
	if (fieldName == nil) {
		UILabel *tempfieldLb=[[UILabel alloc]init];
        self.fieldName=tempfieldLb;
		
	}
	
	if (addFolder) {
        
        [radioButton setFrame:CGRectMake(0,0.0 ,45.0 ,
										 44.0)];
        
		UIImage *folderImg=nil;
        if (timeEntryAllowed && assignedToUser) 
        {
             folderImg=[G2Util thumbnailImage:FolderImage];
        }
       else
       {
            folderImg=[G2Util thumbnailImage:FolderImageDisabled];
       }
        
		if (folderImageView==nil) {
			UIImageView *tempfolderImageView=[[UIImageView alloc]initWithFrame:CGRectMake(45.0, 
																		 12.0,
																		 folderImg.size.width,
																		 folderImg.size.height)];
            self.folderImageView=tempfolderImageView;
            self.folderImageView.highlightedImage=[G2Util thumbnailImage:FolderImage_WHITE];
            
			[folderImageView setBackgroundColor:[UIColor clearColor]];
		}
		[folderImageView setImage:folderImg];
		[self.contentView addSubview:folderImageView];
		[fieldName setFrame:CGRectMake(folderImageView.frame.size.width+50.0
										 ,9.0 ,218,30)];
		//[fieldName setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
		
		//[self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		
		if (navigationButton == nil) {
			navigationButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[navigationButton setFrame:CGRectMake(250.0, 0.0,150, 40)];
			[navigationButton setBackgroundColor:[UIColor clearColor]];
			[navigationButton setEnabled:YES];
			[navigationButton setUserInteractionEnabled:YES];
			[navigationButton setHidden:NO];
			[navigationButton setTag: tagValue];
			[self.contentView addSubview:navigationButton];
		}
		if (disclosureButton == nil) {
			disclosureButton = [UIButton buttonWithType:UIButtonTypeCustom];
			
			UIImage *indicatorImage = [G2Util thumbnailImage:DISCLOSURE_INDICATOR_IMAGE];
			[disclosureButton setFrame:CGRectMake(300, 16.5,indicatorImage.size.width, indicatorImage.size.height)];
			[disclosureButton setBackgroundImage:indicatorImage forState:UIControlStateNormal];
            [disclosureButton setBackgroundImage:[G2Util thumbnailImage:DISCLOSURE_INDICATOR_IMAGE_WHITE] forState:UIControlStateHighlighted];
			[disclosureButton setBackgroundColor:[UIColor clearColor]];
			[disclosureButton setEnabled:YES];
			[disclosureButton setUserInteractionEnabled:YES];
			[disclosureButton setHidden:NO];
			[disclosureButton setTag: tagValue];
			[self.contentView addSubview:disclosureButton];
		}
	}
	else {
        [radioButton setFrame:CGRectMake(0,0.0 ,50.0 ,
										 44.0)];

		[fieldName setFrame:CGRectMake(50,8.0 ,248 ,30)];
		//[fieldButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
	}

	[radioButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 8.0, -3, 0.0)];
    
	[fieldName setBackgroundColor:[UIColor clearColor]];
    fieldName.highlightedTextColor=[UIColor whiteColor];
	[fieldName setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_14]];
	//[fieldName setTextColor:RepliconStandardBlueColor];
	[fieldName setTextColor:RepliconStandardBlackColor];
	[fieldName setHidden:NO];
	[fieldName setText:fieldtext];
	[fieldName setTag: tagValue];
	//[fieldButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[self.contentView addSubview:fieldName];
	
}

-(void)selectTaskRadioButton {
	
	UIImage *selectedRadioImage = [G2Util thumbnailImage:RadioSelectedImage];
	if (radioButton != nil) {
		[radioButton setImage:selectedRadioImage forState:UIControlStateNormal];
        [radioButton setImage:selectedRadioImage forState:UIControlStateHighlighted];
		[self setTaskSelected:YES];
	}

}
-(void)deselectTaskRadioButton {
	
	UIImage *deselectedRadioImage = [G2Util thumbnailImage:RadioDeselectedImage];
	if (radioButton != nil) {
		[radioButton setImage:deselectedRadioImage forState:UIControlStateNormal];
        [radioButton setImage:deselectedRadioImage forState:UIControlStateHighlighted];
		[self setTaskSelected:NO];
	}

}

-(void)addSelectRestrictButton {
	
	UILabel *restrictButton = [[UILabel alloc]init];//[UIButton buttonWithType:UIButtonTypeCustom];
	[restrictButton setFrame:CGRectMake(0.0, 0.0,250.0, 40.0)];
	[restrictButton setBackgroundColor:[UIColor clearColor]];
	//[restrictButton addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:restrictButton];
    
}


@end
