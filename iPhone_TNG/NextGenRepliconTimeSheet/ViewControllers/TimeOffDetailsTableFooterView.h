//
//  TimeOffDetailsTableFooterView.h
//  NextGenRepliconTimeSheet
//
//  Created by Vijay M on 2/4/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "TimeOffDetailsObject.h"
#import "TimeOffObject.h"

@protocol TimeOffSaveDeleteDelegate <NSObject>
@optional
-(void)ActionForSave_Edit;
-(void)ActionForDelete;

@end

@interface TimeOffDetailsTableFooterView : UIView
@property(nonatomic,assign) id  timeOffDetailsViewControllerDelegate;

@property(nonatomic,assign)UILabel *balnaceLb;
@property(nonatomic,strong) NSString *balanceValue;
@property(nonatomic,assign)NavigationFlow navigationFlow;
@property (nonatomic,assign) TimeOffDetailsCalendarView add_editFlow;
@property(nonatomic,strong) TimeOffObject *timeOffDetailsObj;
@property(nonatomic,strong) NSString* approvalsModuleName;
@property(nonatomic,assign)BOOL isEditAcess;
@property(nonatomic,assign)BOOL isDeleteAcess;
@property(nonatomic,assign) id <TimeOffSaveDeleteDelegate> timeOffSaveDeleteDelegate;
@property(nonatomic,weak) id approvalsDelegate;
@property(nonatomic,weak) id parentDelegate;
-(void)setUpTimeOffTableFooterView:(TimeOffObject *)timeoffDetailsObj :(NSString *)commentsStr :(NSInteger)screenMode :(NSString *)balanceTracking;
@end
