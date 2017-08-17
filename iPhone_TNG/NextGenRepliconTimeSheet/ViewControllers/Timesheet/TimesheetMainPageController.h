#import <UIKit/UIKit.h>
#import "DayTimeEntryViewController.h"
#import "MultiDayInOutViewController.h"
#import "DaySelectionScrollView.h"
#import "CustomPickerView.h"
#import "TimesheetObject.h"
#import "WidgetTSViewController.h"
#import "TimesheetDayButton.h"
@interface TimesheetMainPageController : UIViewController<UIScrollViewDelegate,SegmentControlProtocol,DayScrollButtonClickProtocol>

{
    UIScrollView *scrollView;
    UIPageControl* pageControl;
    NSMutableArray *tsEntryDataArray;
    DayTimeEntryViewController *dayViewController;
    NSMutableArray *viewControllers;
    id __weak delegate;
    NSMutableArray *timesheetDataArray;
    BOOL isFirstTimeLoad;
    BOOL isMultiDayInOutTimesheetUser;
    MultiDayInOutViewController *multiDayInOutViewController;
    UIBarButtonItem *rightBarButton;
    NSMutableArray *dbTimeEntriesArray;
    NSString *timesheetURI;
    id __weak parentDelegate;
    NSString *timesheetStatus;
    BOOL hasUserChangedAnyValue;
    UIView *overlayView;
    CustomPickerView *customPickerView;
    NSString *selectedAdhocTimeoffName;
    NSString *selectedAdhocTimeoffUri;
    NSMutableArray *sheetLevelUdfArray;

    BOOL isDisclaimerRequired;
    BOOL isDeleteTimeEntry_AdHoc_RequestInQueue,isAddTimeEntryClicked;
    int multiDayInOutType;
    DaySelectionScrollView *daySelectionScrollView;
    id __weak daySelectionScrollViewDelegate;
    NSMutableArray *rowLevelArray;
    

}
@property (nonatomic, assign) BOOL isDeleteTimeEntry_AdHoc_RequestInQueue;
@property (nonatomic, assign) BOOL hasUserChangedAnyValue;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger currentlySelectedPage, previouslySelectedPage;
@property (nonatomic, strong) NSMutableArray *tsEntryDataArray;
@property (nonatomic, strong) UIPageControl* pageControl;
@property (nonatomic, strong) DayTimeEntryViewController *dayViewController;
@property (nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSMutableArray *timesheetDataArray;
@property (nonatomic, assign) BOOL isFirstTimeLoad;
@property (nonatomic, assign) BOOL isMultiDayInOutTimesheetUser;
@property (nonatomic, strong) MultiDayInOutViewController *multiDayInOutViewController;
@property (nonatomic, strong) UIBarButtonItem *rightBarButton;
@property (nonatomic, strong) NSMutableArray *dbTimeEntriesArray;
@property (nonatomic, strong) NSString *timesheetURI;
@property (nonatomic, weak) id parentDelegate;
@property (nonatomic, strong) NSString *timesheetStatus;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) CustomPickerView *customPickerView;
@property (nonatomic, strong) NSString *selectedAdhocTimeoffName;
@property (nonatomic, strong) NSString *selectedAdhocTimeoffUri;
@property (nonatomic, strong) NSMutableArray *sheetLevelUdfArray;
@property (nonatomic, assign) BOOL isDisclaimerRequired,isAddTimeEntryClicked,isEditForGen4InQueue;
@property (nonatomic, assign) int multiDayInOutType;
@property (nonatomic, strong) DaySelectionScrollView *daySelectionScrollView;
@property (nonatomic, weak) id daySelectionScrollViewDelegate;
@property (nonatomic, assign) NSIndexPath *indexPathForFirstResponder;
@property(nonatomic, strong) NSMutableArray *rowLevelArray;//Implementation for US9371//JUHI
@property (nonatomic, assign)BOOL isAutoSaveInQueue;
@property (nonatomic, assign)BOOL isExplicitSaveRequested;
@property(nonatomic,strong)NSDate *timesheetStartDate;
@property(nonatomic,strong)NSDate *timesheetEndDate;
@property(nonatomic,strong)NSString *userUri;
@property (nonatomic, weak) id trackTimeEntryChangeDelegate;
@property (nonatomic, assign)BOOL isTimeOffSave;
@property (nonatomic, assign)BOOL isTimesheetSaveDone;
@property (nonatomic, readonly)AppConfig *appConfig;

-(void)addInOutTimeEntryRowAction:(id)sender;

-(void)addTimeOffTypeCustomView;
-(NSMutableArray *)getArrayOfTimeEntryObjectsFromAllTheEntries;
-(void)reloadViewWithRefreshedDataAfterSave;
-(void)updateAdhocTimeoffUdfValuesAcrossEntireTimesheet:(NSInteger)index withUdfArray:(NSMutableArray *)tempUdfArray;
-(NSMutableArray *)getUDFArrayForModuleName:(NSString *)moduleName andEntryDate:(NSDate *)entryDate andEntryType:(NSString *)entryType andRowUri:(NSString *)rowUri isRowEditable:(BOOL)isRowEditable;
-(void)resetDayScrollViewPosition;
-(void)checkAndupdateCurrentButtonFilledStatus:(BOOL)hoursPresent andPageSelected:(NSInteger)pageSelected;
-(void)loadNextPageOnCrossoverSplit:(NSInteger)page;
-(void)reloadViewWithRefreshedDataAfterBookedTimeoffSave;//Implemented as per TOFF-115//JUHI
-(void)backAndSaveAction:(id)sender;
-(void)createBlankEntryForGen4:(NSInteger)index andDate:(NSDate *)todayDate;
-(void)recievedTimesheetSummaryData:(NSNotification *)notification;
-(void)createCurrentTimesheetEntryList;
-(void)savingTimesheetWhenClickedOnTimeOff;
-(NSMutableArray *)constructCellOEFObjectForTimeSheetUri:(NSString*)timesheetUri andtimesheetFormat:(NSString *)timesheetFormat andOEFLevel:(NSString *)oefLevel andTimePunchUri:(NSString*)timePunchesUri;
-(void)createNextviewController:(NSInteger)page;
@end
