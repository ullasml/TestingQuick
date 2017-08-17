#import <UIKit/UIKit.h>
#import "EntryCellDetails.h"
#import "NumberKeypadDecimalPoint.h"
#import "TimesheetEntryObject.h"

@interface MultiDayInOutTimeEntryCustomCell : UITableViewCell<UITextFieldDelegate>

{
    UITableView *customTableView;
    EntryCellDetails *rowdetails;
    NSMutableArray *udfArray;
    NSString *timeEntryComments;
    UILabel	*upperLeft;
    UIButton *inTimeButton;
    UIButton *outTimeButton;
    UIImageView *commentsIcon;
    UITextField	*upperRight;
    id __weak delegate;
    NumberKeypadDecimalPoint *numberKeyPad;
    NSIndexPath *selectedPath;
    UIDatePicker *datePicker;
    UIToolbar *toolBar;
    UILabel *upperRightInOutLabel;
    BOOL isTimeoffRow;
    UIBarButtonItem *doneButton;
    UIBarButtonItem *spaceButton;
    UIBarButtonItem *cancelButton;
    NSString *previousDateUdfValue;
    UIBarButtonItem *pickerClearButton;
}

@property(nonatomic,strong)UILabel *upperLeft;
@property(nonatomic,strong)NSString *timeEntryComments;
@property(nonatomic,strong)UIButton *inTimeButton;
@property(nonatomic,strong)UIButton *outTimeButton;
@property(nonatomic,strong)UIImageView *commentsIcon;
@property(nonatomic,strong)UITextField	*upperRight;
@property(nonatomic,strong)EntryCellDetails *rowdetails;
@property(nonatomic,weak)id delegate;
@property(nonatomic,strong)NSMutableArray *udfArray;
@property(nonatomic,strong)NumberKeypadDecimalPoint *numberKeyPad;
@property(nonatomic,strong)NSIndexPath *selectedPath;
@property(nonatomic,strong)UIDatePicker *datePicker;
@property(nonatomic,strong)UIToolbar *toolBar;
@property(nonatomic,strong)UILabel *upperRightInOutLabel;
@property(nonatomic,assign)BOOL isTimeoffRow;
@property(nonatomic,strong) UIBarButtonItem *cancelButton;
@property(nonatomic,strong) NSString *previousDateUdfValue;
@property(nonatomic,strong) UIBarButtonItem *doneButton;
@property(nonatomic,strong) UIBarButtonItem *spaceButton;
@property(nonatomic,strong) UIBarButtonItem *pickerClearButton;
@property(nonatomic,strong)NSString *approvalsModuleName;
@property(nonatomic,strong)NSString *timesheetUri;


-(void)createCellLayoutWithParams:(BOOL)isTimeoffSickRow
                    timeOffString:(NSString *)timeOffString
                 upperrightString:(NSString *)upperrightString
                      commentsStr:(NSString *)commentsStr
            commentsImageRequired:(BOOL )isCommentsImageRequired
                lastUsedTextField:(UITextField *)lastUsedTextField
                         udfArray:(NSMutableArray *)tmpUdfArray
                              tag:(NSInteger)tag
                   startButtonTag:(int)startButtonTag
                     inTimeString:(NSString *)inTimeString
                    outTimeString:(NSString *)outTimeString
                        isTimeoff:(BOOL)isTimeoff
                    withEditState:(BOOL)canEdit
                     withDataDict:(NSMutableDictionary *)heightDict
                     withDelegate:(id)_delegate
                withTsEntryObject:(TimesheetEntryObject *)tsEntryObject;

-(void)doneClicked;

@end
