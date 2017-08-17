//
//  ApprovalsCustomCell.m
//  Replicon
//
//  Created by Dipta Rakshit on 2/7/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "G2ApprovalsCustomCell.h"
#import "G2Constants.h"
#import "G2Util.h"

@implementation G2ApprovalsCustomCell
@synthesize  leftLbl;
@synthesize  rightLbl;
@synthesize  lineImageView;
@synthesize commonCellDelegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

-(void)createCellLayoutWithParams:(NSString *)leftString   rightstr:(NSString *)rightString hairlinerequired:(BOOL)_hairlinereq
{
    if (leftLbl == nil) {
		UILabel *templeftLbl = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 12.0, 145.0, 20.0)];
        self.leftLbl=templeftLbl;
    }
	[self.leftLbl setBackgroundColor:[UIColor clearColor]];
    [self.leftLbl setTextColor:RepliconStandardBlackColor];
	
	[self.leftLbl setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];
	[self.leftLbl setTextAlignment:NSTextAlignmentLeft];
	[self.leftLbl setText:leftString];
	[self.leftLbl setNumberOfLines:1];
	[self.contentView addSubview:self.leftLbl];
	
	if (rightLbl == nil) {
		UILabel *temprightLbl = [[UILabel alloc] initWithFrame:CGRectMake(160.0, 12.0, 150.0, 20.0)];
        self.rightLbl=temprightLbl;
        
	}
	
	 [self.rightLbl setBackgroundColor:[UIColor clearColor]];
     [self.rightLbl setTextColor:RepliconStandardBlackColor];
     
     [self.rightLbl setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];
     [self.rightLbl setTextAlignment:NSTextAlignmentRight];
     [self.rightLbl setText:rightString];
     [self.rightLbl setNumberOfLines:1];
     [self.contentView addSubview:self.rightLbl];
	
	
	
    [self.leftLbl setHighlightedTextColor:iosStandaredWhiteColor];
	[self.rightLbl setHighlightedTextColor:iosStandaredWhiteColor]; 
    

	UIImage *lineImage = [G2Util thumbnailImage:G2Cell_HairLine_Image];
	if (lineImageView == nil) {
		UIImageView *templineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 42.0, 320.0,lineImage.size.height)];
        self.lineImageView=templineImageView;
        
	}
	[lineImageView setImage:lineImage];
	if (_hairlinereq) {
		[self.contentView addSubview:lineImageView];
	}

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




@end
