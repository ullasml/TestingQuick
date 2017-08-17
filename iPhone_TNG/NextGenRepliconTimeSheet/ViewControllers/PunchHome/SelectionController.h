
#import <UIKit/UIKit.h>
#import "Constants.h"
#import "SVPullToRefresh.h"
#import "ClientProjectTaskRepository.h"
#import "Enum.h"

@class ClientType;
@class ProjectType;
@class TaskType;
@class Activity;
@class OEFDropDownType;
@class TimerProvider;
@class PunchCardObject;
@class OEFDropDownRepository;

@protocol SelectionControllerDelegate;
@protocol Theme;
@protocol  ClientProjectTaskRepository;
@class ProjectStorage;
@class ExpenseProjectStorage;


@interface SelectionController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@property (nonatomic,readonly) id <SelectionControllerDelegate> delegate;
@property (nonatomic,readonly) ProjectStorage *projectStorage;
@property (nonatomic,readonly) ExpenseProjectStorage *expenseProjectStorage;
@property (nonatomic,readonly) TimerProvider *timerProvider;
@property (nonatomic,readonly) NSUserDefaults *userDefaults;
@property (nonatomic,readonly) id<Theme> theme;

@property (weak, nonatomic,readonly) UITableView *tableView;
@property (weak, nonatomic,readonly) UISearchBar *searchBar;

-(void)setUpWithSelectionScreenType:(SelectionScreenType)selectionScreenType
                    punchCardObject:(PunchCardObject *)punchCardObject
                           delegate:(id <SelectionControllerDelegate>)delegate;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithProjectStorage:(ProjectStorage *)projectStorage expenseProjectStorage:(ExpenseProjectStorage *)expenseProjectStorage timerProvider:(TimerProvider *)timerProvider userDefaults:(NSUserDefaults *)userDefaults theme:(id <Theme>)theme;

-(void)fetchDataAfterDelayFromTimer:(NSTimer *)timer;

@end

@protocol SelectionControllerDelegate <NSObject>

-(id <ClientProjectTaskRepository> )selectionControllerNeedsClientProjectTaskRepository;


@optional

-(void)selectionController:(SelectionController *)selectionController didChooseClient:(ClientType *)client;

-(void)selectionController:(SelectionController *)selectionController didChooseProject:(ProjectType *)project;

-(void)selectionController:(SelectionController *)selectionController didChooseTask:(TaskType *)task;

-(void)selectionController:(SelectionController *)selectionController didChooseActivity:(Activity *)activity;

-(void)selectionController:(SelectionController *)selectionController didChooseDropDownOEF:(OEFDropDownType *)oefDropDownType;

-(OEFDropDownRepository *)selectionControllerNeedsOEFDropDownRepository;

@end
