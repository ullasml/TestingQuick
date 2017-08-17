//
//  LoginView.h
//  NextGenRepliconTimeSheet
//
//  Created by Mike Cheng on 12/23/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoginView;

@protocol LoginViewDelegate <NSObject>
@optional
- (void)loginView:(LoginView *)loginView rememberSwitchChanged:(BOOL)shouldRememberMe;
- (void)loginView:(LoginView *)loginView doneButtonAction:(id)sender;
- (void)loginView:(LoginView *)loginView signInButtonAction:(id)sender;
- (void)loginView:(LoginView *)loginView googleButtonAction:(id)sender;
- (void)loginView:(LoginView *)loginView feedbackButtonAction:(id)sender;
- (void)loginView:(LoginView *)loginView troubleSigningInAction:(id)sender;
@end


@interface LoginView : UIView

@property (nonatomic,assign) id<LoginViewDelegate> loginViewDelegate;

@property (nonatomic,assign) BOOL shouldRememberMe;
@property (nonatomic,assign) BOOL shouldShowGoogleSignIn;
@property (nonatomic,assign) BOOL shouldShowPasswordField;

@property (nonatomic,strong,readonly) UITextField *companyTextField;
@property (nonatomic,strong,readonly) UITextField *usernameTextField;
@property (nonatomic,strong,readonly) UITextField *passwordTextField;

- (void)showSignInButtonLoadingWithMessage:(NSString *)message;
- (void)showGoogleButtonLoadingWithMessage:(NSString *)message;
- (void)stopButtonLoading;

@end
