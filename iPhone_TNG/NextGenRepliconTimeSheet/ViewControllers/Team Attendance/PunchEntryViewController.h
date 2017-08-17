//
//  PunchEntryViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 09/05/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TeamTimePunchObject.h"
#import "SearchViewController.h"
#import "LoginModel.h"
@interface PunchEntryViewController : UIViewController<UpdateEntryFieldProtocol>
{
    UIButton *deleteButton;
    NSInteger               screenMode;
    int setViewTag;
    
}
@property (nonatomic,strong)UIButton *deleteButton;
@property(nonatomic,assign) NSInteger screenMode;
@property (nonatomic,strong)NSString *currentPageDate;
@property (nonatomic,strong)NSString *currentUser;
@property(nonatomic,strong)UISegmentedControl *segmentedCtrl;
@property (nonatomic,strong)NSString *punchUri;
@property (nonatomic,strong)UIView *tableFooterView;
@property (nonatomic,strong)UIView *tableHeaderView;
@property (nonatomic,strong)NSString *BtnClicked;
@property (nonatomic,strong)TeamTimePunchObject *punchObj;
@property (nonatomic,strong)UIImageView *locationImage;
@property (nonatomic,strong) UILabel *activityLabel;
@property (nonatomic,strong) UIButton *timeBtn;
@property (nonatomic,strong) UILabel *amPmLb;
@property(nonatomic,strong) UIDatePicker *datePicker;
@property(nonatomic,strong) UIToolbar *toolbar;
@property(nonatomic,strong) UIBarButtonItem *doneButton;
@property(nonatomic,strong) UIBarButtonItem *spaceButton;
@property(nonatomic,assign) int setViewTag;
@property (nonatomic,strong) UILabel *selectedSegmentLabel;
@property (nonatomic,strong)UIImageView *selectedSegmentImageview;
@property (nonatomic,strong) UIButton *selectedSegmentBtn;
@property (nonatomic,strong)UIImageView *discloserImageview;
@property (nonatomic,strong)UILabel *imgLabel;
//Implemetation for Punch-229//JUHI
@property (nonatomic,strong) UILabel *dateBtn;
@property(nonatomic,strong)UIDatePicker *punchDatePicker;
@property(nonatomic,strong) NSString *previousDateValue;
@property(nonatomic,strong) NSString *timesheetURI;
@property(nonatomic,weak)id delegate;
@property(nonatomic,assign)BOOL hasBreakAccess,hasActivityAccess;
@property (nonatomic,strong) UIScrollView *containerview;
@property (nonatomic,strong)NSString *approvalsModuleName;

-(void)updateBreakUri:(NSString*)breakUri andBreakName:(NSString*)breakName;
-(void)loadView;
-(NSString *)checkForTrasferWithActvityPermission:(BOOL)activityPermission forSegmentCtrl :(UIView*) myView;
@end
