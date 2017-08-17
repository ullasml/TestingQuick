//
//  LoginPreferencesViewController.h
//  Replicon
//
//  Created by Manoj  on 17/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import"G2Util.h"
#import"G2MoreCellView.h"
#import "G2ViewUtil.h"

@interface G2LoginPreferencesViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
	
	UITableView *loginPreferencesTable;
	NSIndexPath *previousSelectedRow;
	id __weak moreViewControllerObject;
}
-(void)tableViewCellUntapped:(NSIndexPath*)indexPath;
-(void)popViewController;
-(void)resetToNever;
@property(nonatomic,strong)	UITableView *loginPreferencesTable;
@property(nonatomic,strong) NSIndexPath *previousSelectedRow;
@property(nonatomic,weak) id moreViewControllerObject;

@end
