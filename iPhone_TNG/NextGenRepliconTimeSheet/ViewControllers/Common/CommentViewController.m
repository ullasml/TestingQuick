//
//  CommentViewController.m
//  NextGenRepliconTimeSheet


typedef enum {
    ButtonTagReopen = 5001,
    ButtonTagReSubmit = 5002,
    ButtonTagNone = 5003
} ButtonTag;

#import "CommentViewController.h"
#import "CommentViewController+Keyboard.h"
#import "Theme.h"

@interface CommentViewController ()
@property (weak, nonatomic) IBOutlet UITextView *commentsTextView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (nonatomic, copy) NSString *action;
@property (nonatomic) id <Theme> theme;
@property (nonatomic) NSNotificationCenter *notificationCenter;
@property (nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;

@end

@implementation CommentViewController

- (instancetype)initWithTheme:(id<Theme>)theme
           notificationCenter:(NSNotificationCenter *)notificationCenter {

    self = [super init];
    if (self) {
        self.theme = theme;
        self.notificationCenter = notificationCenter;
    }
    return self;
}

- (void)setupAction:(NSString *)action delegate:(id)delegate {

    self.action = action;
    self.delegate = delegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupNavigationBar];
    [self setupTextView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.textViewHeightConstraint.constant = CGRectGetHeight(self.view.bounds);
    [self observeKeyboard];
}

#pragma mark - View helper methods

- (void)setupTextView {

    self.placeholderLabel.text = [self placeholderText];
    self.placeholderLabel.textColor = [self.theme approvalPlaceholderTextColor];
    self.placeholderLabel.font = [self.theme approvalPlaceholderTextFont];
    [self.commentsTextView becomeFirstResponder];
}

- (void)setupNavigationBar {

    self.navigationItem.title = RPLocalizedString(@"Comments", @"Comments");

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonAction)];
    cancelButton.title = RPLocalizedString(@"Cancel", @"Cancel");
    [self.navigationItem setLeftBarButtonItem:cancelButton];

    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithTitle: RPLocalizedString(self.action, self.action) 
                                                                       style: UIBarButtonItemStylePlain
                                                                      target: self
                                                                      action: @selector(buttonAction:)];
    rightBarButton.tag = [self setupTagForButton:self.action];
    [self.navigationItem setRightBarButtonItem:rightBarButton];
}

#pragma mark - UIBarButtonItem Action Methods

- (void)cancelButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)buttonAction:(id)sender {

    CommentViewController *commentVC = self;

    if([self.delegate respondsToSelector:@selector(commentsViewController:didPressOnActionButton:withCommentsText:)]) {
        [self.delegate commentsViewController:commentVC didPressOnActionButton:sender withCommentsText:self.commentsTextView.text];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if ([self.delegate respondsToSelector:@selector(commentsViewController:actionType:comments:)]){
        RightBarButtonActionType actionType =  [self.action isEqualToString:@"Reopen"] ? RightBarButtonActionTypeReOpen : RightBarButtonActionTypeReSubmit;
        [self.delegate commentsViewController:commentVC actionType:actionType comments:self.commentsTextView.text];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma mark - UITextView Delegate Method

- (BOOL)textViewShouldEndEditing :(UITextView*) textView {
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {

    if([textView.text length] > 0) {
        [self.placeholderLabel setHidden:TRUE];
    } else {
        [self.placeholderLabel setHidden:FALSE];
    }
}

#pragma mark - Private Helper Methods

- (NSString*)placeholderText {
    NSString *placeholderLocalizedString = [NSString stringWithFormat:RPLocalizedString(@"Enter %@ comments", nil) , self.action];
    return placeholderLocalizedString;
}

- (ButtonTag)setupTagForButton:(NSString *)action {

    ButtonTag buttonTag = ButtonTagNone;

    if([action isEqualToString:@"Reopen"]) {
        buttonTag = ButtonTagReopen;
    }
    else if([action isEqualToString:@"Resubmit"]) {
        buttonTag = ButtonTagReSubmit;
    }
    return buttonTag;
}

#pragma mark - Dealloc

- (void)dealloc {
    self.delegate = nil;
    self.commentsTextView.delegate = nil;
}

@end
