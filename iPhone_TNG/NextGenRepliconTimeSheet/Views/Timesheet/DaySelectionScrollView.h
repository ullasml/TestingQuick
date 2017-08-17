#import <UIKit/UIKit.h>
#import "TimesheetDayButton.h"
typedef enum ScrollDirection {
    ScrollDirectionOther,
    ScrollDirectionRight,
    ScrollDirectionLeft,
} ScrollDirection;

@interface DaySelectionScrollView : UIView <UIScrollViewDelegate,TimesheetDayButtonClickProtocol>
{
    UIScrollView *scrollView;
    NSMutableArray *_dayButtons;
    id __weak parentDelegate;
    float lastContentOffset;
    ScrollDirection scrollDirection;
    
}

@property (nonatomic,strong)UIScrollView *scrollView;
@property (nonatomic,strong)NSMutableArray *_dayButtons;
@property (nonatomic,weak)id parentDelegate;
@property (nonatomic,assign)NSInteger currentSelectedButtonTag;
@property (nonatomic,assign)float lastContentOffset;
- (id)initWithFrame:(CGRect)frame andWithTsDataArray:(NSMutableArray *)tsDataArray withCurrentlySelectedDay:(NSUInteger)currentDaySelected withDelegate:(id)delegate withTimesheetUri:(NSString *)timesheetUri approvalsModuleName:(NSString *)approvalsModuleName;
-(void)resetDayScrollViewPositionToViewSelectedButton;
-(void)updateFilledStatusOfSelectedButton:(BOOL)isFilledHours onPage:(NSInteger)page;
@end

@protocol DayScrollButtonClickProtocol;
@protocol DayScrollButtonClickProtocol <NSObject>
-(void)timesheetDayBtnClickedWithTag:(NSInteger)tag;
-(void)timesheetDayBtnHighLightOnCrossOver:(NSInteger)page;
@end
