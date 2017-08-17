//
//  TimeSheetCellView.h
//  Replicon
//
//  Created by Hepciba on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2Constants.h"

@interface G2TimeSheetCellView : UITableViewCell {
	
	UILabel *fromToDatelabel;
	UILabel *totalTimelabel;
	UILabel *clientProjectTasklabel;
	UILabel *statuslabel;
	UILabel *clientProjectlabel;
	UILabel *numberOfHourslabel;
	UILabel *activitylabel;
	UILabel *commentslabel;
	
}

@property(nonatomic,strong)UILabel *fromToDatelabel;
@property(nonatomic,strong)UILabel *totalTimelabel;
@property(nonatomic,strong)UILabel *clientProjectTasklabel;
@property(nonatomic,strong)UILabel *statuslabel;
@property(nonatomic,strong)UILabel *clientProjectlabel;
@property(nonatomic,strong)UILabel *numberOfHourslabel;
@property(nonatomic,strong)UILabel *activitylabel;
@property(nonatomic,strong)UILabel *commentslabel;

//-(void)setStatusLabelText:(NSString *)statusText atIndex:(int)index;
-(void)timeSheetCelllayout:(NSString *)fromToDate 
				  totalHrs:(NSString *)time clientProjectTask:(NSString *)_clientProjectTask 
					status:(NSString *)_status textColor:(UIColor *)color;
-(void)timeEntryCelllayout:(NSString *)clientProject 
			   numberofhrs:(NSString *)hours activityOrtask:(NSString *)_task 
				  comments:(NSString *)_comments;
/*-(void)timeOffEntryCelllayout:(NSString *)_type 
				  numberofhrs:(NSString *)hours comments:(NSString *)_comments;*/

-(void)timeEntryCellLayout:(NSString *)project_type numberofhours:(NSString *)_hours 
			  taskComments:(NSString *)task_comments commentsStatus:(NSString *)comments_status 
				 entryType:(NSString *)_entryType;


@end
