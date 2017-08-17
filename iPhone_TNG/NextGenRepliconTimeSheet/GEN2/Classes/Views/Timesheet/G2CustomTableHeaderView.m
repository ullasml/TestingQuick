//
//  CustomTableHeaderView.m
//  Replicon
//
//  Created by Swapna P on 5/11/11.
//  Copyright 2011 EnLume. All rights reserved.
//

#import "G2CustomTableHeaderView.h"


@implementation G2CustomTableHeaderView
@synthesize enterTimeAgainstTimeOff;
@synthesize warningImage;
@synthesize warningLabel;
@synthesize previousEntryButton;
@synthesize bookedTimeOffButton;


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		[self setBackgroundColor:[UIColor clearColor]];
		if (permissionsModel == nil) {
			permissionsModel = [[G2PermissionsModel alloc] init];
		}
    }
    return self;
}
-(void)addNewTimeEntryHeaderView{
	
	UIImage  *backgroundImg = [G2Util thumbnailImage:G2LoginButtonImage];
	
	//TODO: Get permission for Booked Time Off, to show/hide "Enter Booked Time Off" field:Done
	//TODO: Based on the permission adjust the frame for Previous Button
	
	//TODO: Booked Time-off is pending,Only to show "Same as Previous Entry" button
	enterTimeAgainstTimeOff = [permissionsModel checkUserPermissionWithPermissionName:@"TimeoffTimesheet"];
	
	/*if (enterTimeAgainstTimeOff) {
		
		//1.Add previous entry Button
		 previousEntryButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[previousEntryButton setFrame:CGRectMake(self.frame.origin.x+20.0,
												 self.frame.origin.y+10.0,
												 self.frame.size.width-200, 
												 50.0)];
		[previousEntryButton setBackgroundImage:backgroundImg forState:UIControlStateNormal];
		[previousEntryButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
		//[previousEntryButton setTitle:RPLocalizedString(@"Same As Previous Entry",@"") forState:UIControlStateNormal];
		[previousEntryButton setTitle:RPLocalizedString(SameAsPreviousEntryButtonTitle,@"") forState:UIControlStateNormal];
		[previousEntryButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
		[previousEntryButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_13]];
		//[previousEntryButton addTarget:self action:@selector(sameAsPreviousEntryAction) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:previousEntryButton];
		
		//2.Add Booked Time Off Button
		bookedTimeOffButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[bookedTimeOffButton setFrame:CGRectMake(previousEntryButton.frame.size.width +70.0,
												 self.frame.origin.y+10.0,
												 self.frame.size.width-200, 
												 50.0)];
		[bookedTimeOffButton setBackgroundImage:backgroundImg forState:UIControlStateNormal];
		[bookedTimeOffButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
		//[bookedTimeOffButton setTitle:RPLocalizedString(@"Enter Unbooked Time Off",@"") forState:UIControlStateNormal];
		[bookedTimeOffButton setTitle:RPLocalizedString(EnterUnbookedTimeOffButtonTitle,@"") forState:UIControlStateNormal];
		[bookedTimeOffButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
		[bookedTimeOffButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
		//[bookedTimeOffButton addTarget:self action:@selector(enterBookedTimeOffAction) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:bookedTimeOffButton];
	}else {*/
	
	//TODO:Uncomment the above code while to show "Booked Time-Off" button as well
	
		//TODO: Adjust the frame for Previous Button
		//1.Add previous entry Button
		 previousEntryButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[previousEntryButton setFrame:CGRectMake(self.frame.origin.x+40.0,
												 self.frame.origin.y+10.0,
												 self.frame.size.width-100, 
												 50.0)];
		[previousEntryButton setBackgroundImage:backgroundImg forState:UIControlStateNormal];
		[previousEntryButton.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
		[previousEntryButton setTitle:RPLocalizedString(SameAsPreviousEntryButtonTitle,@"") forState:UIControlStateNormal];
		[previousEntryButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
		[previousEntryButton.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_13]];
		//[previousEntryButton addTarget:self action:@selector(sameAsPreviousEntryAction) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:previousEntryButton];
	//}	
}
-(void)addSubmissionErrorHeaderView{
	//1.Add Warning Image
	if (warningImage == nil) {
		//warningImage = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, 40.0, 40.0)];
		warningImage = [[UIImageView alloc] initWithFrame:WarningImageFrame];
	}
	
	
	//TODO: Need to change the Image
	[warningImage setImage:[G2Util thumbnailImage:@"warningImage.jpg"]];
	[self addSubview:warningImage];
	
	//2.Add Warning label
	if (warningLabel == nil) {
		//warningLabel = [[UILabel alloc]initWithFrame:CGRectMake(60.0, 10.0, 260.0, 40.0)];
		warningLabel = [[UILabel alloc]initWithFrame:WarningLabelFrame];
	}
	
	//[warningLabel setText:@"The following time entries are missing required fields:"];
	[warningLabel setText:RPLocalizedString(TheFollowingTimeEntriesareMissingRequiredFields,@"")];
	[warningLabel setBackgroundColor:[UIColor clearColor]];
	[warningLabel setTextAlignment:NSTextAlignmentCenter];
	[warningLabel setNumberOfLines:2];
	[self addSubview:warningLabel];


}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/




@end
