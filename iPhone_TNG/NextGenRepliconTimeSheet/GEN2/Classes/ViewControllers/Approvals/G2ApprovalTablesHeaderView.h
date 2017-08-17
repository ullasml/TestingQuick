//
//  ApprovalTablesHeaderView.h
//  Replicon
//
//  Created by Dipta Rakshit on 2/8/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol approvalTablesHeaderViewDelegate;
@interface G2ApprovalTablesHeaderView : UIView
{
    UIButton *previousButton;
	UIButton *nextButton;
    UILabel *userNameLbl;
    UILabel *durationLbl;
    UILabel *countLbl;
     id <approvalTablesHeaderViewDelegate> __weak delegate;
        NSString  *__weak timesheetStatus;
}

@property (nonatomic, weak) NSString  *timesheetStatus;
@property(nonatomic,strong) UIButton *previousButton;
@property(nonatomic,strong) UIButton *nextButton;
@property(nonatomic,strong) UILabel *userNameLbl;
@property(nonatomic,strong) UILabel *durationLbl;
@property(nonatomic,strong) UILabel *countLbl;

@property (nonatomic, weak) id <approvalTablesHeaderViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame :(NSString *)status;
@end

@protocol approvalTablesHeaderViewDelegate <NSObject>

@optional
- (void)handleButtonClickForHeaderView:(NSInteger)senderTag;

@end

