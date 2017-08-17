//
//  TimeOffDetailsViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Vijay M on 2/2/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimeOffDetailsView.h"
#import "CommentsViewController.h"

@class TimeOffObject;

@interface TimeOffDetailsViewController : UIViewController

@property(nonatomic,strong) NSString *timesheetURI;
@property(nonatomic,assign) NSInteger _screenMode;
@property(nonatomic,strong) NSString *userName;
@property(nonatomic,strong) NSString *userUri;
@property(nonatomic,strong) NSString *timeoffType;
@property(nonatomic,strong) NSString *sheetIdString;
@property(nonatomic,assign) NavigationFlow navigationFlow;
@property(nonatomic,assign) BOOL isStatusView;
@property(nonatomic,strong) TimeOffObject *timeOffObj;
@property(nonatomic,assign) BOOL isComment;
@property(nonatomic,strong)	NSString *sheetStatus;
@property(nonatomic,strong) NSString *dueDate;
@property(nonatomic,assign) NSInteger currentNumberOfView;
@property(nonatomic,assign) NSInteger totalNumberOfView;
@property(nonatomic,strong) NSString *approvalsModuleName;
@property(nonatomic,assign) id approvalDelegate;
@property(nonatomic,weak ) id parentDelegate;
@property(nonatomic,weak ) id timeSheetMainDelegate;
@property(nonatomic,assign) NSInteger currentViewTag;
@property(nonatomic,strong) NSString *startDateTimesheetString;
@property(nonatomic,strong) NSString *endDateTimesheetString;
@property (nonatomic,readonly) NSString *timesheetFormat;

-(void)createViewWithTimeOffObject:(TimeOffObject *)timeOffObj;
- (id)initWithEntryDetails :(TimeOffObject *)timeOffObj sheetId:(NSString *)_sheetIdentity screenMode:(NSInteger)_screenMode;
-(void)submitRequestForTimeOffSubmissionAndSave:(NSMutableArray *)dataArray;
-(NSMutableArray *)_createTimeOffUdfsDetailsArray;
-(void)TimeOffDetailsReceived;
-(void)TimeOffDetailsResponse;
-(void)updateComments:(NSString *)commentsText;
@end
