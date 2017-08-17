//
//  SelectProjectOrTaskViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 11/01/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomSelectedView.h"
#import "OverlayViewController.h"
@protocol UpdateEntryProjectAndTaskFieldProtocol;
@interface SelectProjectOrTaskViewController : UIViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,deleteCustomViewProtocol>

{
    UITextField *searchTextField;
    UITableView *listTableView;
    id __weak delegate;
    NSString *selectedItem;
    NSString *selectedValue,*selectedPath;
    //Implementation for US8849//JUHI
    CustomSelectedView *customSelectedView;
    NSMutableArray *listOfItems;
    NSMutableArray *arrayOfCharacters;
    NSMutableDictionary *objectsForCharacters;
    NSString *currentSelectedItem;
    id<UpdateEntryProjectAndTaskFieldProtocol>__weak entryDelegate;//JUHI
    NSString *client;
    NSString *project;
    NSString *task;
    BOOL isTaskPermission;
    BOOL isTimeAllowedPermission;
    NSString *selectedClientUri;
    NSString *selectedProjectUri;
    NSString *selectedTaskUri;
    NSString *selectedTimesheetUri;
    OverlayViewController *ovController;
    NSTimer *searchTimer;
    BOOL isFromTaskRowSelection;
    BOOL isMoreActionCalled;
    NSString *selectedExpenseUri;
    BOOL isForNoTaskDismiss;
    BOOL isLoadedOnce;
    
    NSString *searchProjectString;
    BOOL isPreFilledSearchString;
    BOOL directlyFromProjectTab;
    
    NSInteger		selectedMode;//DE20024//JUHI
}

@property(nonatomic,strong) NSString *searchProjectString;
@property(nonatomic,assign) BOOL isPreFilledSearchString;
@property(nonatomic,assign) BOOL isForNoTaskDismiss,isLoadedOnce;
@property(nonatomic,assign) BOOL isMoreActionCalled;
@property(nonatomic,assign) BOOL isFromTaskRowSelection;
@property(nonatomic,strong) UITextField *searchTextField;
@property(nonatomic,strong) UITableView *listTableView;
@property(nonatomic,weak) id delegate;
@property(nonatomic,strong) NSString *selectedItem;
@property(nonatomic,strong) NSString *selectedValue,*selectedPath;
@property(nonatomic,strong) NSMutableArray *listOfItems;
@property(nonatomic,strong) NSMutableArray *arrayOfCharacters;
@property(nonatomic,strong) NSMutableDictionary *objectsForCharacters;
@property(nonatomic,strong) NSString *currentSelectedItem;
@property(nonatomic,weak) id<UpdateEntryProjectAndTaskFieldProtocol>entryDelegate;
@property(nonatomic,assign) BOOL isTaskPermission;
@property(nonatomic,assign) BOOL isTimeAllowedPermission;
@property(nonatomic,strong) NSString *selectedClientUri;
@property(nonatomic,strong) NSString *selectedProjectUri;
@property(nonatomic,strong) NSString *selectedTimesheetUri;
@property(nonatomic,strong) NSTimer *searchTimer;
@property(nonatomic,strong) NSString *client;
@property(nonatomic,strong) NSString *project;
@property(nonatomic,strong) NSString *task;
@property(nonatomic,strong) NSString *selectedExpenseUri;
@property(nonatomic,assign) BOOL isTextFieldFirstResponder;
@property(nonatomic,assign) BOOL directlyFromProjectTab;
@property(nonatomic,assign)NSInteger selectedMode;//DE20024//JUHI
@property(nonatomic,assign) BOOL isFromLockedInOut,isFromAttendance;


- (void)refreshViewAfterDataRecieved:(NSNotification *)notificationObject;
@end
@protocol UpdateEntryProjectAndTaskFieldProtocol <NSObject>

-(void)updateFieldWithClient:(NSString*)client clientUri:(NSString*)clientUri project:(NSString *)projectname projectUri:(NSString *)projectUri task:(NSString*)taskName andTaskUri:(NSString*)taskUri taskPermission:(BOOL)hasTaskPermission timeAllowedPermission:(BOOL)hasTimeAllowedPermission;
@end
