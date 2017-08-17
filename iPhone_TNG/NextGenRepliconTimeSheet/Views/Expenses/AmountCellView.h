#import <Foundation/Foundation.h>
#import "Constants.h"
#import "NumberKeypadDecimalPoint.h"
#import "Util.h"

@interface AmountCellView : UITableViewCell <UITextFieldDelegate>
{

	UILabel *fieldLable;
	UIButton *fieldButton;
	id __weak amountDelegate;
	UITextField *fieldText;
	NumberKeypadDecimalPoint *numberKeyPad;
}
-(void)addFieldLabelAndButton:(NSInteger)tagValue width:(CGFloat)width;
-(void)buttonAction:(UIButton*)sender withEvent:(UIEvent*)event;
-(void)grayedOutRequiredCell;

@property(nonatomic, strong) NumberKeypadDecimalPoint *numberKeyPad;
@property(nonatomic,strong)	UITextField *fieldText;
@property(nonatomic,weak)	id amountDelegate;
@property(nonatomic,strong)	UILabel *fieldLable;
@property(nonatomic,strong)	UIButton *fieldButton;


@end
