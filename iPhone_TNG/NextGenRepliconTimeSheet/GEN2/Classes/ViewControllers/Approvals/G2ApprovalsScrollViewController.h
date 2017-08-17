//
//  ApprovalsScrollViewController.h
//  Replicon
//
//  Created by Dipta Rakshit on 2/8/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2ApprovalsUsersListOfTimeEntriesViewController.h"
#import "G2AddDescriptionViewController.h"

@interface G2ApprovalsScrollViewController : UIViewController <approvalUsersListOfTimeEntriesViewControllerDelegate>
{
    G2AddDescriptionViewController *addDescriptionViewController;
    UIScrollView *mainScrollView ;
    NSMutableArray *listOfItemsArr;
    BOOL hasPreviousTimeSheets;
    BOOL hasNextTimeSheets;
    NSMutableArray *allPendingTimesheetsArr;
    G2TimeSheetObject *timeSheetobject;
    G2PermissionSet *permissionSet;
     G2Preferences *preferenceSet;
}

@property(nonatomic,strong)	 G2TimeSheetObject *timeSheetobject;
@property(nonatomic,strong)	 G2PermissionSet *permissionSet;
@property(nonatomic,strong)	 G2Preferences *preferenceSet;
@property(nonatomic,strong)	 NSMutableArray *allPendingTimesheetsArr;
@property(nonatomic,assign) NSInteger indexCount;
@property(nonatomic,assign) BOOL hasPreviousTimeSheets;
@property(nonatomic,assign) BOOL hasNextTimeSheets;
@property(nonatomic,strong)	NSMutableArray *listOfItemsArr;
@property(nonatomic,strong)	 UIScrollView *mainScrollView ;
@property(nonatomic,strong)	G2AddDescriptionViewController *addDescriptionViewController;
@property(nonatomic,assign) NSInteger numberOfViews;
@property(nonatomic,assign) NSInteger currentViewIndex;

-(void)refreshScrollView;
-(void)viewAllTimeEntriesScreen;
-(BOOL)userPreferenceSettings:(NSString *)_preference andUID:(NSString *)userID;
-(BOOL)checkForPermissionExistence:(NSString *)_permission :(NSString *)userID;
-(void)displayAllTimeSheetsBySheetID:(NSDictionary *)sheetDict;
-(void)fetchPendingTimeEntries;
-(void)updateTabBarItemBadge;
@end
