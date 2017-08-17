#import <UIKit/UIKit.h>
#import "Constants.h"
#import "NumberKeypadDecimalPoint.h"
#import "Util.h"

@interface ExpenseEntryCustomCell : UITableViewCell <UITextFieldDelegate>
{
    UILabel *fieldName;
    UILabel *fieldButton;
    UITextField *fieldText;
    UITextField *amountTextField;
    id __weak expenseEntryCellDelegate;
    NSIndexPath *indexPath;
    NumberKeypadDecimalPoint *numberKeyPad;
    NSMutableDictionary *dataObj;
    int decimalPlaces;
    UISwitch *expenseSwitch;

}
@property (nonatomic, strong) UISwitch *expenseSwitch;
@property (nonatomic, weak) id expenseEntryCellDelegate;
@property (nonatomic, strong) UITextField *fieldText;
@property (nonatomic, strong) UITextField *amountTextField;
@property (nonatomic, strong) UILabel *fieldName;
@property (nonatomic, strong) UILabel *fieldButton;
@property (nonatomic, strong) NumberKeypadDecimalPoint *numberKeyPad;
@property (nonatomic, assign) NSInteger tagIndex;
@property (nonatomic, assign) int decimalPlaces;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSMutableDictionary *dataObj;
@property (nonatomic, assign) BOOL canNotEdit;

- (void)addFieldAtIndex:(NSIndexPath *)_indexPath
           withTagIndex:(NSInteger)_tagIndex
                withObj:(NSMutableDictionary *)_dataObj;

- (void)switchChanged:(UISwitch *)sender;

- (void)grayedOutRequiredCell;

- (void)enableRequiredCell;

- (void)addFieldsForNewExpenseSheet:(float)width
                             height:(float)_height;

- (id)initWithStyle:(enum UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
              width:(CGFloat)width;

@end
