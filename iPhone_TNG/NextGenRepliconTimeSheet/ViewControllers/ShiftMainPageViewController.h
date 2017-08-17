//
//  ShiftMainPageViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 27/02/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DaySelectionScrollView.h"

@interface ShiftMainPageViewController : UIViewController<UIScrollViewDelegate,DayScrollButtonClickProtocol>


@property(nonatomic,strong) NSMutableArray              *shiftWeekDatesArray;
@property(nonatomic,strong) NSMutableArray              *viewControllers;
@property(nonatomic,strong) UIScrollView                *scrollView;
@property(nonatomic,strong) UIPageControl               *pageControl;
@property(nonatomic,assign) NSInteger                         currentlySelectedPage;
@property(nonatomic,strong) DaySelectionScrollView      *daySelectionScrollView;
@property (nonatomic, weak) id                          daySelectionScrollViewDelegate;
@property(nonatomic,strong) NSMutableDictionary         *dateDict;
@property (nonatomic, weak) id                          delegate;

-(void)createShiftSummary:(NSNotification *)notification;
-(void)checkTimeOffAndRequestForTimeOffs:(NSNotification *)notification;
@end
