//
//  TaskViewCell.h
//  Replicon
//
//  Created by vijaysai on 6/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface G2TaskViewCell : UITableViewCell {

	UILabel				*fieldName;
	UIButton			*fieldButton;
	UIImageView			*folderImageView;
	UIButton			*radioButton;
	UIButton			*navigationButton;
	UIButton			*disclosureButton;
	BOOL					taskSelected;
}

-(void)addFieldsForTaskViewController:(NSInteger)tagValue text:(NSString *)fieldtext isAddFolder:(BOOL)addFolder isShowNoTasksText:(BOOL)showNoTasksText isTimeEntryAllowed:(BOOL)timeEntryAllowed isassignedToUser:(BOOL)assignedToUser;
-(void)selectTaskRadioButton;
-(void)deselectTaskRadioButton;
-(void)addSelectRestrictButton;
@property (nonatomic,strong) UILabel			*fieldName;
@property (nonatomic,strong) UIButton			*fieldButton;
@property (nonatomic,strong) UIImageView		*folderImageView;
@property (nonatomic,strong) UIButton			*radioButton;
@property (nonatomic,strong) UIButton			*navigationButton;
@property (nonatomic,strong) UIButton			*disclosureButton;
@property (nonatomic,assign) BOOL				taskSelected;
@end
