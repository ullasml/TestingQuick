//
//  CustomTableHeaderView.h
//  Replicon
//
//  Created by Swapna P on 5/11/11.
//  Copyright 2011 EnLume. All rights reserved.
//

#import <UIKit/UIKit.h>
//*****
//#import "PermissionsModel.h"
//*****
@interface CustomTableHeaderView : UIView {
    //*****
//	PermissionsModel *permissionsModel;
    //*****
	BOOL enterTimeAgainstTimeOff;
	UILabel							*warningLabel;
	UIImageView						*warningImage;
	UIButton						*previousEntryButton;
	UIButton						*bookedTimeOffButton;

}
-(void)addNewTimeEntryHeaderView;
-(void)addSubmissionErrorHeaderView;
@property(nonatomic ,assign) BOOL				enterTimeAgainstTimeOff;
@property(nonatomic, strong) UIImageView		*warningImage;
@property(nonatomic, strong) UILabel			*warningLabel;
@property(nonatomic, strong) UIButton			*previousEntryButton;
@property(nonatomic, strong) UIButton			*bookedTimeOffButton;

@end
