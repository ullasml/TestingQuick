
#import "DynamicTextTableViewCell.h"
#import "Constants.h"

@interface DynamicTextTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *textValueLabel;
@property (nonatomic,assign) id <DynamicTextTableViewCellDelegate> delegate;
@property (nonatomic) NSTimer *showDecimalPointTimer;
@property (nonatomic) NSTimer *showMinusButtonTimer;
@property (nonatomic) NSTimer *showSeparatorTimer;
@property (nonatomic) KeyboardSeparatorView *separatorView;
@property (nonatomic) KeyboardDecimalPointButton *decimalPointButton;
@property (nonatomic) KeyboardMinusButton *minusButton;
@property (nonatomic) KeyBoardType keyBoardType;
@end

@implementation DynamicTextTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUpWithDelegate:(id <DynamicTextTableViewCellDelegate>)delegate withKeyboardType:(KeyBoardType)keyboardType tag:(NSInteger)tag
{
    self.delegate = delegate;
    self.keyBoardType = keyboardType;
    self.tag = tag;
    if (keyboardType == NumericKeyboard)
    {
        self.textView.keyboardType =  UIKeyboardTypeDecimalPad;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
    }


    if (keyboardType == NoKeyboard)
    {
        [self.textView removeFromSuperview];
    }
    else
    {
        [self.textValueLabel removeFromSuperview];
    }

    self.textView.textContainerInset = UIEdgeInsetsZero;

}

#pragma mark - <Keyboard Buttons Selector Methods>

- (void) decimalPointPressed {

    //Check to see if there is a . already
    NSString *currentText = self.textView.text;

    if ([currentText rangeOfString:[Util detectDecimalMark] options:NSBackwardsSearch].length == 0)
    {
        UITextRange *selectedRange = [self.textView selectedTextRange];
        NSInteger beginningOffset=[self.textView offsetFromPosition:self.textView.beginningOfDocument toPosition:selectedRange.end];
        NSInteger offset = [self.textView offsetFromPosition:self.textView.endOfDocument toPosition:selectedRange.end];

        NSString *beginText=[currentText substringToIndex:beginningOffset];
        NSString *endText=[currentText substringFromIndex:beginningOffset];
        self.textView.text = [NSString stringWithFormat:@"%@%@%@",beginText,[Util detectDecimalMark],endText];
        UITextPosition *newPos = [self.textView positionFromPosition:self.textView.endOfDocument offset:offset];
        self.textView.selectedTextRange = [self.textView textRangeFromPosition:newPos toPosition:newPos];
    }

}
- (void)minusPressed
{
    self.textView.text=[self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([self.textView.text rangeOfString:@"-" options:NSBackwardsSearch].length == 0)
    {
        [self.textView setText:[NSString stringWithFormat:@"-%@",self.textView.text]];
    }



}


#pragma mark - <UITextView Methods>

- (void)textViewDidBeginEditing:(UITextView *)textView
{

    if (self.keyBoardType == NumericKeyboard)
    {
        self.showDecimalPointTimer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(addDecimalButtonToKeyboard) userInfo:nil repeats:NO];
        self.showMinusButtonTimer=[NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(addMinusButtonToKeyboard) userInfo:nil repeats:NO];
        self.showSeparatorTimer=[NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(addSeparatorBetweenButtons) userInfo:nil repeats:NO];

        [[NSRunLoop currentRunLoop] addTimer:self.showDecimalPointTimer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] addTimer:self.showMinusButtonTimer forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] addTimer:self.showSeparatorTimer forMode:NSDefaultRunLoopMode];
    }



    if ([self.delegate respondsToSelector:@selector(dynamicTextTableViewCell:didBeginEditingTextView:)])
    {
        [self.delegate dynamicTextTableViewCell:self didBeginEditingTextView:self.textView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{

    if ([self.delegate respondsToSelector:@selector(dynamicTextTableViewCell:didEndEditingTextView:)])
    {
        [self.delegate dynamicTextTableViewCell:self didEndEditingTextView:self.textView];
    }
}

- (void) textViewDidChange:(UITextView *)textView
{

    if ([self.delegate respondsToSelector:@selector(dynamicTextTableViewCell:didUpdateTextView:)])
    {
        [self.delegate dynamicTextTableViewCell:self didUpdateTextView:self.textView];
    }

}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{

    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self removeButtonFromKeyboard];
    return YES;
}

-(void) keyboardWillHide: (NSNotification *)notif
{

     [self removeButtonFromKeyboard];
    
}

#pragma mark - <Adding Decimal & Minus Buttons>

- (void) addDecimalButtonToKeyboard
{
    //Add a button to the top, above all windows
    NSArray *allWindows = [[UIApplication sharedApplication] windows];
    NSUInteger topWindow = [allWindows count] - 1;
    UIWindow *keyboardWindow = [allWindows objectAtIndex:topWindow];
    self.decimalPointButton = [[KeyboardDecimalPointButton alloc]initWithBool:YES andDelegate:self];
    [self.decimalPointButton addTarget:self action:@selector(decimalPointPressed) forControlEvents:UIControlEventTouchUpInside];
    [keyboardWindow addSubview:self.decimalPointButton];
}

- (void) addMinusButtonToKeyboard
{
    //Add a button to the top, above all windows
    NSArray *allWindows = [[UIApplication sharedApplication] windows];
    NSUInteger topWindow = [allWindows count] - 1;
    UIWindow *keyboardWindow = [allWindows objectAtIndex:topWindow];
    self.minusButton = [[KeyboardMinusButton alloc]init];
    [self.minusButton addTarget:self action:@selector(minusPressed) forControlEvents:UIControlEventTouchUpInside];
    [keyboardWindow addSubview:self.minusButton];
}

- (void) addSeparatorBetweenButtons
{
    //Add a button to the top, above all windows
    NSArray *allWindows = [[UIApplication sharedApplication] windows];
    NSUInteger topWindow = [allWindows count] - 1;
    UIWindow *keyboardWindow = [allWindows objectAtIndex:topWindow];
    self.separatorView = [[KeyboardSeparatorView alloc]init];
    [keyboardWindow addSubview:self.separatorView];
}


- (void) removeButtonFromKeyboard {

    [self.decimalPointButton removeFromSuperview];
    [self.minusButton removeFromSuperview];
    [self.separatorView removeFromSuperview];
    [self.showMinusButtonTimer invalidate];
    [self.showSeparatorTimer invalidate];
    [self.showDecimalPointTimer invalidate];

}

@end

#pragma mark - <KeyboardDecimalPointButton>

@implementation KeyboardDecimalPointButton

- (id) initWithBool:(BOOL)isMinusBtn andDelegate:(id)delegate {
    if(self = [super init]) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        if (isMinusBtn) {
            self.frame = CGRectMake(0, screenRect.size.height-53, 52, 53);
        }
        else {
            self.frame = CGRectMake(0, screenRect.size.height-53, 104, 53);
        }

        self.titleLabel.font = [UIFont systemFontOfSize:35];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        UIImage *normalBackgroundImage = [UIImage imageNamed:@"KeyboardButtonBackgroundNormal"];
        UIImage *highlightedBackgroundImage = [UIImage imageNamed:@"KeyboardButtonBackgroundHighlighted"];

        [self setBackgroundImage:normalBackgroundImage forState:UIControlStateNormal];
        [self setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];

        [self setTitle:[Util detectDecimalMark] forState:UIControlStateNormal];

    }

    return self;
}

@end

#pragma mark - <KeyboardMinusButton>

@implementation KeyboardMinusButton


- (id) init {

    if(self = [super init]) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        self.frame = CGRectMake(53, screenRect.size.height-53, 51, 53);
        self.titleLabel.font = [UIFont systemFontOfSize:35];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setTitle:@"-" forState:UIControlStateNormal];

        UIImage *normalBackgroundImage = [UIImage imageNamed:@"KeyboardButtonBackgroundNormal"];
        UIImage *highlightedBackgroundImage = [UIImage imageNamed:@"KeyboardButtonBackgroundHighlighted"];

        [self setBackgroundImage:normalBackgroundImage forState:UIControlStateNormal];
        [self setBackgroundImage:highlightedBackgroundImage forState:UIControlStateHighlighted];

    }
    return self;
}

@end

#pragma mark - <KeyboardSeparatorView>

@implementation KeyboardSeparatorView

- (id) init {

    if(self = [super init]) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        self.frame = CGRectMake(52, screenRect.size.height-53, 1, 53);
        self.backgroundColor = [UIColor lightGrayColor];

    }
    return self;
}

@end
