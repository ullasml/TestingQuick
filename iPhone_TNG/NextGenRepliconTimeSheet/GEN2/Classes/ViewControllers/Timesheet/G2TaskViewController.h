//
//  TaskViewController.h
//  Replicon
//
//  Created by Hepciba on 4/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import"G2TimeEntryCellView.h"
#import"G2Constants.h"

#import "G2TaskViewCell.h"
#import "G2RepliconServiceManager.h"
#import "FrameworkImport.h"
#import "G2TaskSelectionMessageView.h"

@interface G2TaskViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
	
	UITableView						*taskTable;
	G2TaskViewCell					*cell;
	NSMutableArray					*taskArr;
	id								clientProjectTaskDelegate;
	NSString						*parentTaskIdentity;
	NSString						*projectIdentity;
	NSIndexPath						*previousSelectedIndexPath;
	
	G2SupportDataModel				*supportDataModel;
	G2TaskViewController				*subTaskViewController;
	
	BOOL							subTaskMode;
	NSString						*selectedTaskEntityId;
	NSString						*parentEntityId;
	id								parentTaskController;

}
-(void)doneAction:(id)sender;
-(void)cancelAction:(id)sender;
-(void)handleButtonClicks:(id)sender;
-(void)hanldleTaskNavigation:(id)sender;
-(void)showSubTasks;
-(void)returnToTimeEntryScreen;
-(void)highlightTableRow:(NSIndexPath *)_indexPath;
-(void)unHighlightTableRow:(NSIndexPath *)_indexPath;
-(void)animateCellWhichIsSelected;

@property(nonatomic,strong) G2SupportDataModel	*supportDataModel;
@property(nonatomic,strong) UITableView			*taskTable;
@property(nonatomic,strong) NSMutableArray		*taskArr;
@property(nonatomic,strong)	id					clientProjectTaskDelegate;
@property(nonatomic,strong) NSString			*parentTaskIdentity;
@property(nonatomic,strong) NSString			*projectIdentity;
@property(nonatomic,assign) BOOL				subTaskMode;
@property(nonatomic,strong) NSString			*selectedTaskEntityId;
@property(nonatomic,strong) NSString			*parentEntityId;
@property(nonatomic,strong) id					parentTaskController;
@property(nonatomic,strong)	NSIndexPath						*previousSelectedIndexPath;
@property(nonatomic,strong)	G2TaskViewController				*subTaskViewController;
@end
