//
//  SearchViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 10/01/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OverlayViewController.h"
#import "CustomSelectedView.h"
#import "PunchMapViewController.h"
@protocol UpdateEntryFieldProtocol;

@interface SearchViewController : UIViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,deleteCustomViewProtocol>{
    UITextField *searchTextField;
    UITableView *mainTableView;
    NSMutableArray *listOfItems;
    id __weak delegate;
    NSString *selectedItem;
    NSString *selectedTimesheetUri;
    NSString *selectedProject;
    NSString *selectedProjectCode;
    NSString *selectedProjectUri;
    NSString *selectedTaskUri;
    CustomSelectedView *customSelectedView;
    OverlayViewController *ovController;
    id <UpdateEntryFieldProtocol> __weak entryDelegate;
    NSMutableArray *arrayOfCharacters;
    NSMutableDictionary *objectsForCharacters;
    NSTimer *searchTimer;
    NSInteger screenMode;
    BOOL isResult;
    
    NSString *searchProjectString;
    BOOL isPreFilledSearchString;
    NSString *selectedActivityName;//Implementation for US8849//JUHI
    NSString *selectedActivityUri;
}

@property(nonatomic,assign) BOOL isPreFilledSearchString;
@property(nonatomic,strong)  NSString *searchProjectString;
@property(nonatomic,strong) UITextField *searchTextField;
@property(nonatomic,strong) UITableView *mainTableView;
@property(nonatomic,strong) NSMutableArray *listOfItems;
@property(nonatomic,weak) id delegate;
@property(nonatomic,strong)NSString *selectedTimesheetUri;
@property(nonatomic,strong)NSString *selectedItem;
@property(nonatomic,strong)NSString *selectedProject;
@property(nonatomic,weak) id <UpdateEntryFieldProtocol>entryDelegate;
@property(nonatomic,strong)NSMutableArray *arrayOfCharacters;
@property(nonatomic,strong)NSMutableDictionary *objectsForCharacters;
@property(nonatomic,strong)NSString *selectedProjectUri;
@property(nonatomic,strong) NSTimer *searchTimer;
@property(nonatomic,strong)NSString *selectedTaskUri;
@property(nonatomic,assign) NSInteger screenMode;
@property(nonatomic,strong)NSString *selectedProjectCode;
@property(nonatomic,strong)NSString *selectedActivityName;//Implementation for US8849//JUHI
@property(nonatomic,assign) BOOL isTextFieldFirstResponder;
@property(nonatomic,assign) BOOL isFromLockedInOut,isFromAttendance,isOnlyActivity,isStartNewTask;
@property(nonatomic,strong)NSString *userId;
@property(nonatomic,strong)NSString *selectedActivityUri;
@property(nonatomic,strong)PunchMapViewController *punchMapViewController;
@end

@protocol UpdateEntryFieldProtocol <NSObject>

-(void)updateFieldWithFieldName:(NSString*)fieldName andFieldURI:(NSString*)fieldUri;
-(void)dismissCameraView;
@end
