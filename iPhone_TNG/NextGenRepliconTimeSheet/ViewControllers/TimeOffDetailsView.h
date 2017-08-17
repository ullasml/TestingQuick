//
//  TimeOffDetailsView.h
//  NextGenRepliconTimeSheet
//
//  Created by Vijay M on 2/2/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeOffDetailsObject.h"
#import "Constants.h"
#import "TimeOffObject.h"
#import "DateUdfPickerView.h"
#import "UdfDropDownView.h"
#import "CommentsViewController.h"
#import "TimeSheetsUdfCell.h"

@class TimeOffDetailsView;
@class TimeOffDetailsCellView;
@class ErrorBannerViewParentPresenterHelper;


@protocol TimeOffDetailsDateSelectionDelegate <NSObject>
@optional
-(void)didSelectDateSelection:(NSIndexPath *)selectedIndex timeOffObj:(TimeOffObject *)timeOffObj;
-(void)balanceCalculationMethod:(NSInteger)startDurationEntryTypeMode :(NSInteger)endDurationEntryMode :(TimeOffObject *)timeoffObject;
-(void)timeOffCommentsNavigation;
-(void)approvalCommentDetailAction;
- (void)textUdfNavigation:(TimeOffDetailsView *)timeOffDetailsView withUdfObject:(UdfObject *)udfObject;
- (void)dropdownUdfNavigation:(TimeOffDetailsView *)timeOffDetailsView withUdfObject:(UdfObject *)udfObject;
- (void)updateUdfValue:(TimeOffDetailsView *)timesheetDetailsView withUdfObject:(UdfObject *)udfObject;
-(void)validateAndSumbit :(NSInteger)startDurationEntryTypeMode :(NSInteger)endDurationEntryMode :(TimeOffObject *)timeoffObject :(NSInteger)screenMode :(NSMutableArray *)customFieldObj;
-(void)deleteTimeOff:(TimeOffObject *)timeoffObj;
-(void)handleApprovalsAction:(NSInteger)sender withApprovalComments:(NSString *)approvalComments;
-(void)handleTableHeaderAction:(NSInteger)currentViewTag :(NSInteger)buttonTag;
-(void)hideTabBar:(BOOL)hideTabBar;
@end

@protocol UdfUpdateDelegate <NSObject>
@optional
- (void)updateUdfValue:(TimeOffDetailsView *)timeOffDetailsView withUdfObject:(UdfObject *)udfObject;
@end

@interface TimeOffDetailsView : UIView <UITableViewDelegate,UITableViewDataSource,UDFActionDelegate,DateUDFActionDelegate,CommentsActionDelegate,UdfDropDownViewDelegate>
{
    float heightofDisclaimerText;
}
@property (nonatomic,weak) id timeOffViewDelegate;
@property (nonatomic,weak) id approvalDelegate;
@property (nonatomic,weak) id parentDelegate;
@property (nonatomic,weak) id <UdfUpdateDelegate>udfDropDownDelegate;
@property (nonatomic,weak) id<TimeOffDetailsDateSelectionDelegate> timeOffDateSelectionDelegate;
@property (nonatomic,assign) TimeOffDetailsCalendarView add_Edit;
@property (nonatomic,assign) NavigationFlow navigationFlow;
@property(nonatomic,strong)UILabel *balanceValueLbl;
@property(nonatomic,strong)UILabel *requestedValueLbl;
@property (nonatomic,assign)BOOL isStatusView;
@property (nonatomic,assign)BOOL isEditAccess;
@property (nonatomic,assign)BOOL isDeleteAccess;
@property(nonatomic,strong)NSMutableArray *customFieldArray;
@property (nonatomic,assign) NSInteger screenMode;
@property (nonatomic,strong)NSString* approvalsModuleName;
@property (nonatomic,assign)NSInteger totalNumberOfView;
@property (nonatomic,assign)NSInteger currentViewTag;
@property (nonatomic,strong) TimeOffObject *timeOffDetailsObj;
@property (nonatomic,strong) NSString *userName;
@property (nonatomic,strong) NSString *timeoffType;
@property(nonatomic,strong)NSString *sheetIdString;
@property(nonatomic,assign )BOOL                            isComment;
@property(nonatomic,strong)	NSString						*sheetStatus;
@property(nonatomic,strong)NSString *dueDate;
@property(nonatomic,assign)NSInteger currentNumberOfView;
@property(nonatomic,assign )BOOL                            isShowingPicker;
@property(nonatomic,strong) UITableView *timeOffDetailsTableView;
@property(nonatomic,strong)NSString *balanceTrackingOption;
@property(nonatomic,assign)BOOL timeOffStatus;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithFrame:(CGRect)frame errorBannerViewParentPresenterHelper:(ErrorBannerViewParentPresenterHelper*)errorBannerViewParentPresenterHelper NS_DESIGNATED_INITIALIZER;


- (void)setUpTimeOffDetailsView:(TimeOffObject *)timeOffdetailsObj :(NavigationFlow)navigationType;
- (void)reloadTableViewFromTimeOffDetails;
- (void)showToolBarWithAnimation:(BOOL)animated;
- (void)hideToolBarWithAnimation:(BOOL)animated;
- (void)updateBalanceValue:(NSDictionary *)balDictionary :(NSInteger)screenMode;
- (void)UpdateComments:(NSString *)commentsStr;
- (void)updateStartAndDate :(TimeOffObject *)timeOffObj;
- (void)deselectTableViewSelection;
- (void)resetViewForApprovalsCommentAction:(BOOL)isReset andComments:(NSString *)approverComments;
- (void)ActionForSave_Edit;
-(void)setTableViewInset;
- (void)keyboardWasShown:(NSNotification*)aNotification;
- (void)keyboardWillBeHidden:(NSNotification*)aNotification;
@end

