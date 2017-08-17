//
//  BookedTimeOffCellView.h
//  Replicon
//
//  Created by Dipta Rakshit on 6/27/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeOffObject.h"

@interface BookedTimeOffCellView : UITableViewCell
{
    UILabel *timeOffTypelabel;
	UIImageView *statusImgView;
	UILabel *datelabel;
	UILabel *numberOfHourslabel;

	
}

@property(nonatomic,strong)UILabel *timeOffTypelabel;
@property(nonatomic,strong)UIImageView *statusImgView;
@property(nonatomic,strong)UILabel *datelabel;
@property(nonatomic,strong)UILabel *numberOfHourslabel;

-(void)bookedTimeOffCelllayout:(NSString *)timeOfftype totalHrs:(NSString *)timestr date:(NSString *)dateStr status:(UIImage *)lowerleftImage approvalStatus:(NSString *)approvalStatus;
-(void)createCellLayoutForTimeOffView:(TimeOffObject *)timeOffObject;
@end
