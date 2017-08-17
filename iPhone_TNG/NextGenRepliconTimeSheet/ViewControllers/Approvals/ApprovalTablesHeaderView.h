//
//  ApprovalTablesHeaderView.h
//  Replicon
//
//  Created by Dipta Rakshit on 2/8/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol approvalTablesHeaderViewDelegate;
@interface ApprovalTablesHeaderView : UIView
{
    UIButton *previousButton;
	UIButton *nextButton;
    UILabel *userNameLbl;
    UILabel *durationLbl;
    UILabel *countLbl;
    id <approvalTablesHeaderViewDelegate> __weak delegate;
   
}
@property(nonatomic,strong) UIButton *previousButton;
@property(nonatomic,strong) UIButton *nextButton;
@property(nonatomic,strong) UILabel *userNameLbl;
@property(nonatomic,strong) UILabel *durationLbl;
@property(nonatomic,strong) UILabel *countLbl;
@property(nonatomic, weak) id <approvalTablesHeaderViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame withStatus:(NSString *)status userName:(NSString *)userName dateString:(NSString *)dateStr labelText:(NSString *)labelText withApprovalModuleName:(NSString *)moduleName isWidgetTimesheet:(BOOL)isWidgetTimesheet withErrorsAndWarningView:(UIView*)errorsAndWarningView;

@end

@protocol approvalTablesHeaderViewDelegate <NSObject>

@optional
- (void)handleButtonClickForHeaderView:(NSInteger)senderTag;
-(void)handleErrorsAndWarningsHeaderAction:(NSInteger)senderTag;
@end

