//
//  ShiftsSummaryViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 24/02/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShiftMainPageViewController.h"

@interface ShiftsSummaryViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    UITableView *shiftSummaryTableView;
    NSMutableArray *shiftSummaryArray;
    NSString    *shiftSummaryIdentity;
    NSString  *shiftDuration;
    NSMutableArray *allEntriesArray;
    NSIndexPath *selectedIndexPath;
	NSMutableArray *entriesArray;
}
@property (nonatomic,strong)UITableView *shiftSummaryTableView;
@property (nonatomic,strong)NSMutableArray *shiftSummaryArray;
@property(nonatomic,strong)NSString    *shiftSummaryIdentity;
@property(nonatomic,strong)NSString    *shiftDuration;
@property (nonatomic,strong)NSMutableArray *allEntriesArray;
@property(nonatomic,strong) ShiftMainPageViewController *shiftMainPageController;
@property(nonatomic,strong)NSMutableArray    *entriesArray;
@property (nonatomic, readonly) ShiftSummaryPresenter *shiftSummaryPresenter;

-(void)createShiftSummary:(NSNotification *)notification;
-(void)checkTimeOffAndRequestForTimeOffs:(NSNotification *)notification;

-(instancetype)initWithSummaryPresenter:(ShiftSummaryPresenter *) shiftSummaryPresenter;
@end
