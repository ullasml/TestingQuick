//
//  ApprovalsCheckBoxCustomCell.h
//  Replicon
//
//  Created by Dipta Rakshit on 2/7/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol approvalSelectedUserDelegate;
@interface G2ApprovalsCheckBoxCustomCell : UITableViewCell
{
    UILabel		*leftLbl;
	UILabel		*rightLbl;
    UIImageView    *lineImageView;
    //id commonCellDelegate;
    UIButton	*radioButton;
    BOOL	userSelected;
    id <approvalSelectedUserDelegate> __weak delegate;
}

@property(nonatomic, strong) UILabel		*leftLbl;
@property(nonatomic, strong) UILabel		*rightLbl;
@property(nonatomic, strong) UIImageView    *lineImageView;
//@property(nonatomic, retain)  id commonCellDelegate;
@property(nonatomic, strong)  UIButton		*radioButton;
@property(nonatomic, assign) BOOL	userSelected;
@property (nonatomic, weak) id <approvalSelectedUserDelegate> delegate;

-(void)createCellLayoutWithParams:(NSString *)leftString   rightstr:(NSString *)rightString hairlinerequired:(BOOL)_hairlinereq radioButtonTag:(NSInteger)tagValue  overTimerequired:(BOOL)overTimeReq mealrequired:(BOOL)mealReq timeOffrequired:(BOOL)timeOffReq regularRequired:(BOOL)regularReq overTimeStr:(NSString *)overTimeString mealStr:(NSString *)mealString timeOffStr:(NSString *)timeOffString regularStr:(NSString *)regularString;

-(void)selectTaskRadioButton:(id)sender;
-(void) createRightLowerWithOverTimerequired:(BOOL)overTimeReq mealrequired:(BOOL)mealReq timeOffrequired:(BOOL)timeOffReq regularRequired:(BOOL)regularReq overTimeStr:(NSString *)overTimeString mealStr:(NSString *)mealString timeOffStr:(NSString *)timeOffString regularStr:(NSString *)regularString;


@end


@protocol approvalSelectedUserDelegate <NSObject>

@optional
- (void)handleButtonClickforSelectedUser:(NSIndexPath *)indexPath isSelected:(BOOL)isSelected;

@end