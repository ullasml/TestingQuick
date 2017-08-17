

#import <UIKit/UIKit.h>
#import "Enum.h"

@protocol DynamicTextTableViewCellDelegate;
@class KeyboardSeparatorView;
@class KeyboardDecimalPointButton;
@class KeyboardMinusButton;
@interface DynamicTextTableViewCell : UITableViewCell<UITextViewDelegate>


@property (weak, nonatomic,readonly) UILabel *title;
@property (weak, nonatomic,readonly) UITextView *textView;
@property (weak, nonatomic,readonly) UILabel *textValueLabel;
@property (nonatomic,readonly) id <DynamicTextTableViewCellDelegate> delegate;
@property (nonatomic,readonly) KeyboardSeparatorView *separatorView;
@property (nonatomic,readonly) KeyboardDecimalPointButton *decimalPointButton;
@property (nonatomic,readonly) KeyboardMinusButton *minusButton;
@property (nonatomic,readonly) KeyBoardType keyBoardType;


- (void)setUpWithDelegate:(id <DynamicTextTableViewCellDelegate>)delegate withKeyboardType:(KeyBoardType)keyboardType tag:(NSInteger)tag;

@end


@protocol DynamicTextTableViewCellDelegate<NSObject>

@optional

- (void)dynamicTextTableViewCell:(DynamicTextTableViewCell *)dynamicTextTableViewCell didUpdateTextView:(UITextView *)textView;
- (void)dynamicTextTableViewCell:(DynamicTextTableViewCell *)dynamicTextTableViewCell didBeginEditingTextView:(UITextView *)textView;
- (void)dynamicTextTableViewCell:(DynamicTextTableViewCell *)dynamicTextTableViewCell didEndEditingTextView:(UITextView *)textView;


@end

@interface KeyboardDecimalPointButton : UIButton
- (id) initWithBool:(BOOL)isMinusBtn andDelegate:(id)delegate;
@end

@interface KeyboardMinusButton : UIButton
@end

@interface KeyboardSeparatorView : UIView
@end