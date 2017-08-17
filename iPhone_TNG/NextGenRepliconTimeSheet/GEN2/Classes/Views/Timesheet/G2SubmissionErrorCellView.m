//
//  SubmissionErrorCellView.m
//  ResubmitTimesheet
//
//  Created by Sridhar on 29/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2SubmissionErrorCellView.h"
#import "G2Util.h"

@implementation G2SubmissionErrorCellView
@synthesize availableField;
@synthesize missingField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
		UIImage *img = [G2Util thumbnailImage:cellBackgroundImageView];
		UIImageView *backGroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 
																						0.0, 
																						img.size.width, 
																						img.size.height)];
		[backGroundImageView setImage:img];
		[self.contentView addSubview:backGroundImageView];
		
		
    }
    return self;
}

-(void)setSubmissionErrorFields:(NSString *)availablefieldtxt missingfield:(NSString *)_missingfieldtxt{
	DLog(@"setSubmissionErrorFields");
	//DLog(@"availablefield %@",availablefieldtxt);
	//DLog(@"Missingfield %@",_missingfieldtxt);
	
	if (availableField == nil) {
		UILabel *tempavailableField = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 5.0, 320.0, 35.0)];
        self.availableField =tempavailableField;
        
	}
	[availableField setBackgroundColor:[UIColor clearColor]];	
	[availableField setTextColor:RepliconStandardBlackColor];
	[availableField setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
	[availableField setText:availablefieldtxt];
	
	
	[self.contentView addSubview:availableField];
	
	if (missingField == nil) {
		UILabel *tempmissingField = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 40.0, 320.0, 25.0)];
        self.missingField=tempmissingField;
        
	}
	[missingField   setBackgroundColor:[UIColor clearColor]];
	[missingField   setTextColor:[UIColor redColor]];
	[missingField	setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
	[missingField	setText:_missingfieldtxt];
	[self.contentView addSubview:missingField];
	
	
	
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}





@end
