//
//  ResetPasswordViewController.h
//  Replicon
//
//  Created by Siddhartha on 07/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2ViewUtil.h"
#import "G2Constants.h"
#import "G2MoreCellView.h"
#import "G2Util.h"
#import "G2RepliconServiceManager.h"

@interface G2ResetPasswordViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
	UIButton *resetPwdButton;
	UITableView *resetPwdTableView;
	UIView *responseView;
	id __weak delegate;
	NSArray *fieldsArray;
}
@property (nonatomic, strong) UIButton *resetPwdButton;
@property (nonatomic, strong) UITableView *resetPwdTableView;
@property (nonatomic, weak) id delegate;

-(void)setNavigationButtons;
-(void)cancelAction;
-(void)resetPwdButtonClicked:(id)sender;
-(BOOL)validateTableCells;
-(void)showSuccessScreen;
-(void)addTable;
@end

