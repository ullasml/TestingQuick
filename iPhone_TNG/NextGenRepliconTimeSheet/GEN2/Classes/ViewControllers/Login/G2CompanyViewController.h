//
//  CompanyViewController.h
//  Replicon
//
//  Created by Dipta Rakshit on 4/21/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2CustomUITextField.h"
#import "FrameworkImport.h"

@class G2LoginViewCell;
@interface G2CompanyViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,NetworkServiceProtocol>
{
    

    UIButton *loginButton1;
    UIToolbar *toolbar;
    UIScrollView *companyViewScrollView;
    UITableView    *loginTableView;
    UISegmentedControl *toolbarSegmentControl;
    UITextField *currentTextField;
    UILabel *welcomeLbl1,*welcomeLbl2;
    BOOL isNotExpandedMode;
    NSString                *errorString;
}
@property(nonatomic,strong)  NSString                *errorString;
@property(nonatomic,assign) BOOL isNotExpandedMode;
@property(nonatomic,strong)  UILabel *welcomeLbl1,*welcomeLbl2;
@property(nonatomic,strong) UITextField *currentTextField;
@property(nonatomic,strong) UISegmentedControl *toolbarSegmentControl;
@property(nonatomic,strong)UITableView    *loginTableView;

@property(nonatomic,strong) UIButton *loginButton1;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong)UIScrollView *companyViewScrollView;
-(void)loginAction:(id)selector;
-(void)registerForKeyBoardNotifications;
-(void)createToolbar;
-(void)resetScrollView;
-(G2LoginViewCell *)getCellAtIndexPath:(NSIndexPath*)cellIndexPath;
-(void)doneClickAction;
-(void)dataReceivedForCurrentGen:(NSNotification *) notification;
-(void)dataReceivedForNextGen:(NSNotification *) notification;
@end
