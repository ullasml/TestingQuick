#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TimesheetEntryObject.h"
#import "InOutTimesheetEntry.h"
#import "NumberKeypadDecimalPoint.h"
#import "UIButton+Extensions.h"

@interface ExtendedInOutCell : UITableViewCell <UITextFieldDelegate>
{
    UITextField* _inTxt;
    UITextField* _outTxt;
    UILabel* _hours;
    UIButton *_inAMPM;
    UIButton *_outAMPM;
    UIButton *_submit;
    id __weak delegate;
    int _startOffset;
    UILabel *_formattedIn;
    UILabel *_formattedOut;
    UIImageView *midNightCrossOverView;
    UILabel *_midNightHours;
    TimesheetEntryObject *tsEntryObj;
    NumberKeypadDecimalPoint *numberKeyPad;
}
@property (nonatomic,strong) TimesheetEntryObject *tsEntryObj;
@property (nonatomic,strong) UILabel *_midNightHours;
@property (nonatomic,strong) UIImageView *midNightCrossOverView;
@property (nonatomic,strong) UITextField* _inTxt;
@property (nonatomic,strong) UITextField* _outTxt;
@property (nonatomic,strong) UILabel *_formattedIn;
@property (nonatomic,strong) UILabel *_formattedOut;
@property (nonatomic,strong) UILabel* _hours;
@property (nonatomic,weak) id delegate;
@property (nonatomic,strong) InOutTimesheetEntry* _currentEntry;
@property (nonatomic,assign) NSInteger cellRow;
@property (nonatomic,assign) NSInteger cellSection;
@property int _startOffset;
@property (nonatomic,strong) NumberKeypadDecimalPoint *numberKeyPad;
@property (nonatomic,strong) UIImageView *commentsIconImageView;
@property (nonatomic,strong) UIImageView *arrowImageView;
@property (nonatomic,strong) UIButton *_submit;
@property (nonatomic,assign) BOOL isAmPmButtonClick;
@property (nonatomic,strong) NSMutableDictionary *saveDictOnOverlap;
@property (nonatomic,assign) BOOL isMidNightCrossOver;
@property (nonatomic,assign) NSInteger indexForMidnight;
@property (nonatomic,strong) UIImage *fieldBackgroundImage;


-(void)resignKeyBoard:(UITextField *)textField;
-(void)createCellLayoutWithParamsForTimesheetEntryObject:(TimesheetEntryObject *)tsEntryObj forInOutTimesheetEntryObj:(InOutTimesheetEntry *)inOutTimesheetEntry editState:(BOOL)iseditState forRow:(NSInteger)row approvalsModuleName:(NSString *)approvalsModuleName isGen4Timesheet:(BOOL)isGen4Timesheet;
-(void) setFocus;
-(void) setInTimeFocus;
-(void) setOutTimeFocus;
-(void)resizeKeyBoardForResigning:(UITextField *)textField;

@end

@protocol InOutTimesheetEntryCellDelegate <NSObject>
@optional
-(void) cellDidFinishEditing:(ExtendedInOutCell *)entryCell;
-(void) cellDidBeginEditing:(ExtendedInOutCell *)entryCell;
-(void) willJumpToNextCell:(ExtendedInOutCell *)entryCell;
@end

@protocol InOutEntryCellClickDelegate <NSObject>
@optional
-(void) cellClickedAtIndex:(NSInteger)row andSection:(NSInteger)section;
@end
