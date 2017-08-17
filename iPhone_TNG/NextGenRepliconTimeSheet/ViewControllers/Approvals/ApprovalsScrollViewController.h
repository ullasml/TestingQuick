//
//  ApprovalsScrollViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 25/01/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimesheetMainPageController.h"
#import "CurrentTimesheetViewController.h"
#import "TimeOffDetailsViewController.h"
#import "ExpenseEntryViewController.h"
#import "ListOfExpenseEntriesViewController.h"
#import "AddDescriptionViewController.h"
#import "WidgetTSViewController.h"

@protocol ApprovalDelegate <NSObject>
@optional
-(void)handleApproveOrRejectActionWithApproverComments:(NSString *)approverComments andSenderTag:(NSInteger)senderTag;
- (void)handlePreviousNextButtonFromApprovalsListforViewTag:(NSInteger)currentViewtag forbuttonTag:(NSInteger)buttonTag;
@end

@interface ApprovalsScrollViewController : UIViewController
{
    UIScrollView *mainScrollView ;
    NSArray *listOfPendingItemsArray;
    int currentViewIndex;
    BOOL hasPreviousTimeSheets;
    BOOL hasNextTimeSheets;
    NSString *sheetStatus;
    id __weak delegate;
    UIBarButtonItem *rightBarButtonItem;
    TimeOffDetailsViewController *bookedTimeOffEntryController;
    ListOfExpenseEntriesViewController *listOfExpenseEntriesViewController;
    WidgetTSViewController *widgetTSViewController;
    NSString *approvalsModuleName;
}

@property(nonatomic,weak) id <ApprovalDelegate>approvalDelegate;
@property(nonatomic,strong)	 UIScrollView *mainScrollView ;
@property(nonatomic,strong)	 NSArray *listOfPendingItemsArray;
@property(nonatomic,assign)	 int currentViewIndex;
@property(nonatomic,assign)  BOOL hasPreviousTimeSheets;
@property(nonatomic,assign)  BOOL hasNextTimeSheets;
@property(nonatomic,assign)  NSInteger indexCount;
@property(nonatomic,strong)  NSString *sheetStatus;
@property(nonatomic,weak)    id delegate;
@property(nonatomic,strong)  UIBarButtonItem *rightBarButtonItem;
@property(nonatomic,strong)  CurrentTimesheetViewController *currentTimesheetViewController;
@property(nonatomic,strong)  TimeOffDetailsViewController *bookedTimeOffEntryController;
@property(nonatomic,strong)  ListOfExpenseEntriesViewController *listOfExpenseEntriesViewController;
@property(nonatomic,strong)  WidgetTSViewController *widgetTSViewController;
@property(nonatomic,strong)  NSString *approvalsModuleName;
@property(nonatomic,assign) BOOL isGen4User;
@property(nonatomic,strong) NSMutableArray *validationMessageArray;

-(void)handlePreviousNextButtonFromApprovalsListforViewTag:(NSInteger)currentViewtag forbuttonTag:(NSInteger)buttonTag;
-(void)handleApproveOrRejectActionWithApproverComments:(NSString *)approverComments andSenderTag:(NSInteger)senderTag;
-(void)pushToViewController:(UIViewController *)viewController;
-(void)viewAllEntriesScreen:(NSNotification *)notification;
-(void)addActiVityIndicator;
-(void)removeActiVityIndicator;



@end
