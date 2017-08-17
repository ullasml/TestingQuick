//
//  ApprovalTablesFooterView.h
//  Replicon
//
//  Created by Dipta Rakshit on 2/8/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@protocol approvalTablesFooterViewDelegate;
@interface ApprovalTablesFooterView : UIView <UITextViewDelegate>
{
    
    UIButton *approveButton;
	UIButton *rejectButton;
    UIButton *reopenButton;
    UITextView *commentsTextView;
    UILabel *commentsTextLbl;
    id <approvalTablesFooterViewDelegate> __weak delegate;
    NSString  *__weak timesheetStatus;
    UILabel *approverCommentsLabel;
    CGFloat				 animatedDistance;

}
@property(nonatomic,strong) UILabel *commentsTextLbl;
@property (nonatomic, weak) NSString  *timesheetStatus;
@property(nonatomic,strong) UIButton *approveButton;
@property(nonatomic,strong) UIButton *rejectButton;
@property(nonatomic,strong) UIButton *reopenButton;
@property(nonatomic,strong)  UITextView *commentsTextView;
@property (nonatomic, weak) id <approvalTablesFooterViewDelegate> delegate;
@property(nonatomic,strong) UILabel *approverCommentsLabel;

- (id)initWithFrame:(CGRect)frame withStatus:(NSString *)status;
-(void)drawLayout;


@end

@protocol approvalTablesFooterViewDelegate <NSObject>

@optional
- (void)handleButtonClickForFooterView:(NSInteger)senderTag;
- (void)moreButtonClickForFooterView:(NSInteger)senderTag;
@end
