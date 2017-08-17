//
//  SubmissionErrorViewController.h
//  ResubmitTimesheet
//
//  Created by Sridhar on 29/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2SubmissionErrorCellView.h"
#import "G2NavigationTitleView.h"
#import "G2CustomTableHeaderView.h"
#import "G2TimeSheetEntryObject.h"
#import "G2TimeEntryViewController.h"


@interface G2SubmissionErrorViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>{
	//Strings
	NSString						*errorSheet;
	NSString						*entryKey;
	
	//Labels
	UILabel							*topToolbarLabel;
	UILabel							*innerTopToolbarLabel;
	UILabel							*warningLabel;
	UILabel							*sectionHeaderlabel;
	
	//Buttons
	UIBarButtonItem					*backButton;
	
	//Views
	G2SubmissionErrorCellView			*cell;
	G2NavigationTitleView				*topTitleView;
	G2CustomTableHeaderView			*tableHeader;
	UIImageView						*warningImage;
	UITableView						*submissionTableView;
	UIView							*sectionHeader;
	
	
	//Arrays
	NSMutableArray					*uniquekeyArray;
	
	//Dictionary
	NSMutableDictionary				*submissionErrorsDict;
	
	//Other
	G2Preferences					*preferencesObj;
	G2PermissionSet				*permissionsObj;
	id							parentController;

	
	
	
	
}
//- (id) initWithTimeEntryObject:(TimeSheetEntryObject *)entryObject;
- (id) initWithPermissionSet:(G2PermissionSet *)_permissionSet :(G2Preferences *)_preferences;
-(void)submissionErrorBackAction;
-(void)entriesMissingFields:(NSMutableDictionary *)missingfields;
-(NSString *)getFormattedHeaderTitleString:(NSString *)_stringdate;
-(NSMutableString *)getMissingFieldsString:(NSMutableArray *)missingfields;
-(NSString *)getAvailableFieldsString:(NSMutableArray *)availablefields;

-(void)resetSubmissionErrorDetails;

@property(nonatomic, strong) UITableView						*submissionTableView;
@property(nonatomic, strong) UIImageView						*warningImage;

@property(nonatomic, strong) UILabel							*topToolbarLabel;
@property(nonatomic, strong) UILabel							*innerTopToolbarLabel;
@property(nonatomic, strong) UILabel							*warningLabel;
@property(nonatomic,strong)  UILabel							*sectionHeaderlabel;
@property(nonatomic,strong)   UIView							*sectionHeader;
@property(nonatomic, strong) NSString							*errorSheet;
@property(nonatomic, strong) NSString							*entryKey;
@property(nonatomic, strong) UIBarButtonItem					*backButton;

@property(nonatomic, strong) NSMutableDictionary				*submissionErrorsDict;
@property(nonatomic, strong) NSMutableArray					    *uniquekeyArray;
@property(nonatomic, strong) G2CustomTableHeaderView				*tableHeader;
@property(nonatomic, strong) id									parentController;


@end
