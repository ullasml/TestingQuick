//
//  ResetPasswordView.h
//  NextGenRepliconTimeSheet
//
//  Created by Dipta Rakshit on 1/15/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ResetPasswordView;

@protocol ResetPasswordViewDelegate <NSObject>
@optional
- (void)resetPasswordViewAction:(ResetPasswordView *)resetPasswordView;
@end



@interface ResetPasswordView : UIView

@property (nonatomic,assign) id<ResetPasswordViewDelegate> resetPasswordViewDelegate;
@property (nonatomic,strong,readonly) UITextField *oldPasswordTextField;
@property (nonatomic,strong,readonly) UITextField *newPasswordTextField;
@property (nonatomic,strong,readonly) UITextField *confirmPasswordTextField;

- (void)startButtonLoading;
- (void)stopButtonLoading;
@end
