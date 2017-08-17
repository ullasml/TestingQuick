//
//  TeamTimeViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 18/03/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DaySelectionScrollView.h"
#import "TimeViewController.h"
#import "ImageViewController.h"
#import "LocationViewController.h"
#import "AuditTrialViewController.h"
#import "AuditTrialUsersViewController.h"
#import "WidgetTSViewController.h"

@protocol Theme;

@interface TeamTimeViewController : UIViewController<DayScrollButtonClickProtocol>


@property (nonatomic,assign)BOOL isCalledFromMenu;
@property (nonatomic,strong) DaySelectionScrollView *daySelectionScrollView;
@property (nonatomic,weak) id daySelectionScrollViewDelegate;
@property (nonatomic,strong) NSMutableArray *datesArray;
@property (nonatomic,strong) UISegmentedControl *segmentedCtrl;
@property (nonatomic,strong) TimeViewController *timeViewController;
@property (nonatomic,strong) LocationViewController *locationViewController;
@property (nonatomic,strong) ImageViewController *imageViewController;
@property (nonatomic,strong)NSString *btnClicked;
@property (nonatomic,strong)NSMutableArray *dataArray;
@property(nonatomic,strong)NSDate *timesheetStartDate;
@property(nonatomic,strong)NSDate *timesheetEndDate;
@property(nonatomic,assign) int setViewTag;
@property(nonatomic,assign) NSInteger currentSelectedPage;
@property (nonatomic,strong)NSString *currentDateString;
@property (nonatomic,strong)NSString *sheetIdentity;
@property (nonatomic,strong)NSString *approvalsModuleName;
@property (nonatomic,strong)NSString *approvalsModuleUserUri;
@property (nonatomic) NSString *sheetApprovalStatus;
@property (nonatomic,assign)BOOL isEditable;
@property (nonatomic, weak) id trackTimeEntryChangeDelegate;
@property (nonatomic,assign)BOOL hasUserChangedAnyValue;
@property (nonatomic,readonly)id<Theme> theme;

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)addPunch:(NSIndexPath *)indexPath isFRomAddPunch:(BOOL)isFromAddPunch;
-(void)responseRecieved;
//Mobi-854 testCase//JUHI
-(BOOL)showAddButton:(BOOL)canEditTimePunch;
-(void)receivedPunchesForTimesheet;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithTheme:(id<Theme>)theme NS_DESIGNATED_INITIALIZER;

@end
