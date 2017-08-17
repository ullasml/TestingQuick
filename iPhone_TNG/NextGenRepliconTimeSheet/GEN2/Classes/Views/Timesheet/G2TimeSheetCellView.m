//
//  TimeSheetCellView.m
//  Replicon
//
//  Created by Hepciba on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2TimeSheetCellView.h"
#import "G2Util.h"

@implementation G2TimeSheetCellView

@synthesize fromToDatelabel;
@synthesize totalTimelabel;
@synthesize clientProjectTasklabel;
@synthesize clientProjectlabel;
@synthesize statuslabel;
@synthesize numberOfHourslabel;
@synthesize activitylabel;
@synthesize commentslabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
	UIImage *img = [G2Util thumbnailImage:cellBackgroundImageView];
	UIImageView *backGroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
	[backGroundImageView setImage:img];
	[self.contentView addSubview:backGroundImageView];
	
	}
	return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}

-(void)timeSheetCelllayout:(NSString *)fromToDate totalHrs:(NSString *)timestr clientProjectTask:(NSString *)_clientProjectTask status:(NSString *)_status textColor:(UIColor *)color{
	DLog(@"timeSheetCelllayout :::TimeSheetCellView");
	if (fromToDatelabel == nil) {
		UILabel *tempfromToDatelabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 12, 225, 20)];
        self.fromToDatelabel=tempfromToDatelabel;
        
	}
	[fromToDatelabel setTextColor:RepliconStandardBlackColor];
	[fromToDatelabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
	[fromToDatelabel setTextAlignment:NSTextAlignmentLeft];
	[fromToDatelabel setBackgroundColor:[UIColor clearColor]];
	[fromToDatelabel setText:fromToDate];
	[self.contentView addSubview:fromToDatelabel];
	
	
	
	if (totalTimelabel==nil) {
		UILabel *temptotalTimelabel = [[UILabel alloc] initWithFrame:CGRectMake(235, 10, 70, 20)]; //25y
        self.totalTimelabel=temptotalTimelabel;
       
	}
	
	[totalTimelabel setTextColor:RepliconStandardBlackColor];
	[totalTimelabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
	//[totalTimelabel setTextAlignment:NSTextAlignmentLeft];
	[totalTimelabel setTextAlignment:NSTextAlignmentRight];
	[totalTimelabel setBackgroundColor:[UIColor clearColor]];
	DLog(@"TIME :%@",timestr);
	[totalTimelabel setText:timestr];
	[self.contentView addSubview:totalTimelabel];
	
	if (clientProjectTasklabel==nil) {
		UILabel *tempclientProjectTasklabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 52, 150, 16)]; //60
        self.clientProjectTasklabel=tempclientProjectTasklabel;
        
	}
	
	[clientProjectTasklabel setBackgroundColor:[UIColor clearColor]];
	[clientProjectTasklabel setTextColor:RepliconStandardBlackColor];
	[clientProjectTasklabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
	[clientProjectTasklabel setTextAlignment:NSTextAlignmentLeft];
	[clientProjectTasklabel setText:_clientProjectTask];
	[self.contentView addSubview:clientProjectTasklabel];
	
	if (statuslabel==nil) {
		UILabel *tempstatuslabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 52, 150, 16)];
        self.statuslabel=tempstatuslabel;
        
	}
	
	[statuslabel setTextColor:RepliconStandardBlackColor];
	[statuslabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_12]];
	[statuslabel setTextAlignment:NSTextAlignmentRight];
	[statuslabel setBackgroundColor:[UIColor clearColor]];
	[statuslabel setText:_status];
	
	[statuslabel setTextColor:color];
	[self.contentView addSubview:statuslabel];
	
}

-(void)timeEntryCelllayout:(NSString *)clientProject numberofhrs:(NSString *)hours 
			activityOrtask:(NSString *)_task comments:(NSString *)_comments{
	DLog(@"timeEntryCelllayout::TimeSheetCellView");
	DLog(@"clientProject= %@",clientProject);
	DLog(@"numberofhrs= %@",hours);
	DLog(@"activityOrtask= %@",_task);
	DLog(@"clientProject= %@",clientProject);
	DLog(@"_comments= %@",_comments);
	if (clientProjectlabel == nil) {
		DLog(@"clientProjectLabel ==>1 nil");
		UILabel *tempclientProjectlabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 15.0, 225.0, 20.0)];
        self.clientProjectlabel=tempclientProjectlabel;
       
	}
	[clientProjectlabel setTextColor:RepliconStandardBlackColor];
	[clientProjectlabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_18]];
	[clientProjectlabel setTextAlignment:NSTextAlignmentLeft];
	[clientProjectlabel setBackgroundColor:[UIColor clearColor]];
	[clientProjectlabel setText:clientProject];
	[self.contentView addSubview:clientProjectlabel];
	
	if (numberOfHourslabel==nil) {
		UILabel *tempnumberOfHourslabel = [[UILabel alloc] initWithFrame:CGRectMake(230.0, 14.0, 70.0, 20.0)]; //25y
        self.numberOfHourslabel=tempnumberOfHourslabel;
       
	}
	[numberOfHourslabel setTextColor:RepliconStandardBlackColor];
	[numberOfHourslabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
	//Modified,As per new requirement .......
	//[numberOfHourslabel setTextAlignment:NSTextAlignmentLeft];
	[numberOfHourslabel setTextAlignment:NSTextAlignmentRight];
	[numberOfHourslabel setBackgroundColor:[UIColor clearColor]];
	[numberOfHourslabel setText:hours];
	[self.contentView addSubview:numberOfHourslabel];
	
	if (activitylabel==nil) {
		//activitylabel = [[UILabel alloc] initWithFrame:CGRectMake(155.0, 55.0, 150.0, 18.0)]; //60
		UILabel *tempactivitylabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 55.0, 150.0, 18.0)];//13.0x
        self.activitylabel=tempactivitylabel;
        
		
	}
	
	[activitylabel setBackgroundColor:[UIColor clearColor]];
	
	//Modified,As per new requirement .......
	//[activitylabel setTextColor:RepliconStandardGrayColor];
	//[activitylabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_12]];
	//[activitylabel setTextAlignment:NSTextAlignmentRight];
	
	[activitylabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
	[activitylabel setTextColor:[UIColor blackColor]];
	[activitylabel setTextAlignment:NSTextAlignmentLeft];
	[activitylabel setBackgroundColor:[UIColor clearColor]];
	[activitylabel setText:_task];
	[self.contentView addSubview:activitylabel];
	
	if (commentslabel==nil) {
		//commentslabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 55.0, 150.0, 18.0)];//13.0x
		UILabel *tempcommentslabel = [[UILabel alloc] initWithFrame:CGRectMake(155.0, 55.0, 150.0, 18.0)]; //60
        self.commentslabel=tempcommentslabel;
        
	}
	
	[commentslabel setTextColor:RepliconStandardGrayColor];
	[commentslabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
	[commentslabel setTextAlignment:NSTextAlignmentLeft];
	[commentslabel setBackgroundColor:[UIColor clearColor]];
	[commentslabel setText:@""];
	[self.contentView addSubview:commentslabel];
}

-(void)timeEntryCellLayout:(NSString *)project_type numberofhours:(NSString *)_hours 
			  taskComments:(NSString *)task_comments commentsStatus:(NSString *)comments_status 
				 entryType:(NSString *)_entryType{
	
	DLog(@"timeEntryCelllayout::TimeSheetCellView");
	DLog(@"clientProject= %@",project_type);
	DLog(@"numberofhrs= %@",_hours);
	DLog(@"activityOrtask= %@",task_comments);
	DLog(@"_comments= %@",comments_status);
	
	if (clientProjectlabel == nil) {
		UILabel *tempclientProjectlabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 15.0, 225.0, 20.0)];
        self.clientProjectlabel=tempclientProjectlabel;
        
	}
	if ([_entryType isEqualToString:@"TimeEntry"]) {
		[clientProjectlabel setTextColor:RepliconStandardBlackColor];
	}else {
		[clientProjectlabel setTextColor:[UIColor grayColor]];
	}
	
	[clientProjectlabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_18]];
	[clientProjectlabel setTextAlignment:NSTextAlignmentLeft];
	[clientProjectlabel setBackgroundColor:[UIColor clearColor]];
	[clientProjectlabel setText:project_type];
	[self.contentView addSubview:clientProjectlabel];
	
	if (numberOfHourslabel==nil) {
		UILabel *tempnumberOfHourslabel = [[UILabel alloc] initWithFrame:CGRectMake(230.0, 14.0, 70.0, 20.0)]; //25y
        self.numberOfHourslabel=tempnumberOfHourslabel;
        
	}
	[numberOfHourslabel setTextColor:RepliconStandardBlackColor];
	[numberOfHourslabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_16]];
	//Modified,As per new requirement .......
	//[numberOfHourslabel setTextAlignment:NSTextAlignmentLeft];
	[numberOfHourslabel setTextAlignment:NSTextAlignmentRight];
	[numberOfHourslabel setBackgroundColor:[UIColor clearColor]];
	[numberOfHourslabel setText:_hours];
	[self.contentView addSubview:numberOfHourslabel];
	
	if (activitylabel==nil) {
		//activitylabel = [[UILabel alloc] initWithFrame:CGRectMake(155.0, 55.0, 150.0, 18.0)]; //60
		UILabel *tempactivitylabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 55.0, 150.0, 18.0)];//13.0x
        self.activitylabel=tempactivitylabel;
        
		
	}
	
	[activitylabel setBackgroundColor:[UIColor clearColor]];
	
	//Modified,As per new requirement .......
	//[activitylabel setTextColor:RepliconStandardGrayColor];
	//[activitylabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_12]];
	//[activitylabel setTextAlignment:NSTextAlignmentRight];
	
	[activitylabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
	[activitylabel setTextColor:[UIColor blackColor]];
	[activitylabel setTextAlignment:NSTextAlignmentLeft];
	[activitylabel setBackgroundColor:[UIColor clearColor]];
	[activitylabel setText:task_comments];
	[self.contentView addSubview:activitylabel];
	
	if (commentslabel==nil) {
		//commentslabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 55.0, 150.0, 18.0)];//13.0x
		UILabel *tempcommentslabel = [[UILabel alloc] initWithFrame:CGRectMake(155.0, 55.0, 150.0, 18.0)]; //60
        self.commentslabel=tempcommentslabel;
        
	}
	
	[commentslabel setTextColor:RepliconStandardGrayColor];
	[commentslabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
	//[commentslabel setTextAlignment:NSTextAlignmentLeft];
	[commentslabel setTextAlignment:NSTextAlignmentRight];
	[commentslabel setBackgroundColor:[UIColor clearColor]];
	[commentslabel setText:comments_status];
	[self.contentView addSubview:commentslabel];
	
}



@end
