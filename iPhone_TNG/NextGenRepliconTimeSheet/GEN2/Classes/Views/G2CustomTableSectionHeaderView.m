//
//  CustomTableSectionHeaderView.m
//  Replicon
//
//  Created by vijaysai on 6/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2CustomTableSectionHeaderView.h"


@implementation G2CustomTableSectionHeaderView

@synthesize headerImage;
@synthesize headerLabel;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
		
    }
    return self;
}

-(void)setViewProperties:(NSString *)imageName :(CGRect)labelFrame :(NSString *)labelText {
	
	if (headerLabel == nil) {
		headerLabel = [[UILabel alloc] initWithFrame:labelFrame];
	}
	[headerLabel setBackgroundColor:[UIColor clearColor]];
	[headerLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];//US4065//Juhi
	[headerLabel setTextColor:RepliconStandardBlackColor];
	[headerLabel setText:labelText];
	
    //US4065//Juhi
//	if (headerImage == nil) {
//		headerImage = [Util thumbnailImage:imageName];
//	}
//	if (headerImageView == nil) {
//		headerImageView = [[UIImageView alloc] initWithFrame:
//						   CGRectMake(10.0, 4.0, headerImage.size.width, headerImage.size.height)];
//	}
//	[headerImageView setImage:headerImage];
//	[headerImageView setBackgroundColor:[UIColor clearColor]];
//	
//	[self addSubview:headerImageView];
	[self addSubview:headerLabel];
	
	
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/



@end
