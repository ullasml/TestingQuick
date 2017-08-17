//
//  ClientProjectTaskViewController.h
//  Replicon
//
//  Created by Hepciba on 4/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2Constants.h"
#import "G2CustomPickerView.h"
#import "G2TaskViewController.h"
#import "G2TimeEntryCellView.h"
#import "G2SupportDataModel.h"
#import "G2TimeSheetEntryObject.h"
#import "G2RepliconServiceManager.h"
#import "FrameworkImport.h"
#import "G2PermissionSet.h"
#import "G2Preferences.h"

enum CLIENT_PROJECT_TASK {
	CLIENT_PROJECT,
	TASK
};


@interface G2ClientProjectTaskViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,
												DataPickerProtocol,DataPickerZeroIndexUpdateProtocol> {

	//Views
	UITableView          *clientProjectTaskTable;
	UIPickerView		 *customPicker;
	UIView               *headerView;
	G2CustomPickerView	 *customPickerView;
	G2TimeEntryCellView    *cell;
	
	//Arrays
	NSMutableArray       *firstSectionfieldArr;
	NSMutableArray       *clientsArr;
	NSMutableArray       *projectsArr;
	
	//Strings
	NSMutableString             *selectedName;
	
	//Other
	UIToolbar            *keyboardToolbar;
	NSIndexPath		     *selectedIndex;
	
	G2SupportDataModel	 *supportDataModel;
	G2TimeSheetEntryObject *timeEntryObject;
	UIBarButtonItem      *rightButton1;
	id					 tnewTimeEntryDelegate;
	
	G2TaskViewController   *taskViewController;
	
	
												
	
}
@property (nonatomic,strong) UIToolbar            *keyboardToolbar;
@property (nonatomic,strong) UIView               *headerView;
@property (nonatomic,strong) G2TaskViewController   *taskViewController;;
@property(nonatomic,strong) NSIndexPath		     *selectedIndex;
@property(nonatomic,strong) UITableView				*clientProjectTaskTable;
@property(nonatomic,strong) NSMutableArray			*firstSectionfieldArr;
@property(nonatomic,strong) G2CustomPickerView		*pickerBackgroundView;
@property(nonatomic,strong) UIPickerView			*customPicker;
@property(nonatomic,strong) NSMutableArray			*clientsArr;
@property(nonatomic,strong) NSMutableArray			*projectsArr;
@property(nonatomic,strong) NSMutableString			*selectedName;
@property(nonatomic,strong) id					    tnewTimeEntryDelegate;

-(void)handleButtonClicks:(NSIndexPath*)selectedButtonIndex;

- (id) initWithTimeEntryObject:(G2TimeSheetEntryObject *)entryObject 
			   withPermissions:(G2PermissionSet *)_permissions andPreferences:(G2Preferences *)_preferences;
-(void)populateClientProjectDetails:(G2TimeSheetEntryObject *)entryObject;
-(void)cancelAction:(id)sender;
-(void)doneAction:(id)sender;
-(void)enableTaskSelection;
-(void)disableTaskSelection;
-(void)pickerDoneAction:(id)sender;
-(void)setFirstSectionFields:(G2PermissionSet *)permissions;

-(void)fetchTasksForSelectedProject;
-(void)showTasksForProject;
//-(void)updateSelectedTask : (NSString *)taskName : (NSString *)taskIdentity;
-(void)updateSelectedTask : (NSString *)taskName : (NSMutableDictionary *)taskDict;
-(void)reloadDatapickerforSelectedClientProject;
-(void)tableCellTappedAtIndex:(NSIndexPath*)indexPath;
-(void)tableViewCellUntapped:(NSIndexPath*)indexPath;
-(void)animateCellWhichIsSelected;
-(void)deselectRowAtIndexPath:(NSIndexPath*)indexPath;
-(void)updateFieldAtIndexWithSelectedValue :(NSIndexPath *)selectedIndexPath :(id)selectedValue;
@end
