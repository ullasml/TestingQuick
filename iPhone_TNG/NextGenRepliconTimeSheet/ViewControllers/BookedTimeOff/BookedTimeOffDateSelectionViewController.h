#import <UIKit/UIKit.h>
#import <TapkuLibrary/TapkuLibrary.h>
#import "Constants.h"

@class TKCalendarMonthView;
@protocol TKCalendarMonthViewDelegate,TKCalendarMonthViewDataSource;
@protocol BookedTimeOffDateSelectionDelegate;
@interface BookedTimeOffDateSelectionViewController : UIViewController<TKCalendarMonthViewDelegate,TKCalendarMonthViewDataSource> 
{
    NSDate *selectedStartDate;
    NSDate *selectedEndDate;
    NSDate *tempSelectedStartDate;
    NSDate *tempSelectedEndDate;
     id <BookedTimeOffDateSelectionDelegate> __weak delegate;
    UILabel *requestedTimeOffValueLb,*balanceValueLbl;
    NSInteger screenMode;
    UIView *progressView;
    id __weak entryDelegate;
}
@property(nonatomic,assign)NavigationFlow navigationFlow;
@property(nonatomic,strong)NSDate *selectedStartDate;
@property(nonatomic,strong)NSDate *selectedEndDate;
@property(nonatomic,strong)NSDate *tempSelectedStartDate;
@property(nonatomic,strong)NSDate *tempSelectedEndDate;
@property(nonatomic,weak)id <BookedTimeOffDateSelectionDelegate> delegate;
@property(nonatomic,strong) UILabel *requestedTimeOffValueLb,*balanceValueLbl;
@property (nonatomic,strong) TKCalendarMonthView *calendarView;
@property(nonatomic,assign)NSInteger screenMode;
@property (nonatomic,strong) UIView *progressView;
@property(nonatomic,weak)id entryDelegate;

-(void)paintCalendarFromAPICall;

@end


@protocol BookedTimeOffDateSelectionDelegate <NSObject>

@optional
- (void)didSelectDateForStartDate:(NSDate *)startDate forEndDate:(NSDate *)endDate;
- (void)didSelectStartAndEndDate:(NSDate *)startDate forEndDate:(NSDate *)endDate;
- (void)animateCellWhichIsSelected;
@end
