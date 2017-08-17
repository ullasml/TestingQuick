//
//  FreeTrialViewController.h
//  Replicon
//
//  Created by Swapna P on 10/10/11.
//  Copyright 2011 EnLume. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2Constants.h"
#import "G2ViewUtil.h"
#import "G2CustomTableViewCell.h"
#import "G2LoginViewCell.h"
#import "G2Util.h"
#import "G2TaskSelectionMessageView.h"
#import "G2RepliconServiceManager.h"


@interface G2FreeTrialViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
	UITableView						*freeSignUpTrialView;
	id								 delegate;
	NSMutableArray				        *firstSectionfieldsArr;
	NSMutableArray				        *secondSectionfieldsArray;
	UIView							*welcomeView;
	G2TaskSelectionMessageView			*processLoadingView;
	

}
@property(nonatomic,strong) UITableView		*freeSignUpTrialView;
@property(nonatomic,strong) id				 delegate;
@property(nonatomic,strong) NSMutableArray		*firstSectionfieldsArr;
@property(nonatomic,strong) NSMutableArray		*secondSectionfieldsArray;
@property(nonatomic,strong) UIView			 *welcomeView;

-(void) cancelSignUpAction:(id)sender;
-(void) freeTrialSignupButtonAction:(id)sender;
-(void) setFirstSectionFields;
-(void) setSecondSectionFields;
-(void) moveTableToTopAtIndexPath:(NSIndexPath *)_index;
-(G2CustomTableViewCell *)returnCellAtIndexPath:(NSIndexPath *)_indexpath;
-(NSNumber * )validatefreeSignUpFieldValues;
-(void) startUsingRepliconButtonAction:(id)sender;
-(void) reloadViewUponSuccessValidation;
-(void) loadWelcomeView:(NSString *)_btntitle :(int)_tag;
-(void) goToLogin:(id)sender;
-(void)freetrialSuccessSetUpView;
//-(void)textfieldnextClickAction:(NSNumber *)_textfieldTag section:(NSIndexPath *)_indexpath;
@end
