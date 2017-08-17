
#import "ApprovalCommentsController.h"
#import "Theme.h"
#import "Constants.h"

@interface ApprovalCommentsController ()
@property (nonatomic) ApprovalActionType approvalActionType;
@property (nonatomic, weak) id <ApprovalCommentsControllerDelegate> delegate;
@property (nonatomic, weak) IBOutlet UITextView *commentsTextView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderTextLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;
@property (nonatomic) NSNotificationCenter *notificationCenter;
@property (nonatomic) id <Theme> theme;
@property (nonatomic) BOOL isCommentsRequired;


@end

@implementation ApprovalCommentsController

- (instancetype)initWithNotificationCenter:(NSNotificationCenter *)notificationCenter theme:(id<Theme>)theme
{
    self = [super init];
    if (self) {
        self.notificationCenter = notificationCenter;
        self.theme = theme;
    }
    return self;
}

- (void)setUpApprovalActionType:(ApprovalActionType )approvalActionType delegate:(id <ApprovalCommentsControllerDelegate>)delegate commentsRequired:(BOOL)isCommentsRequired
{
    self.isCommentsRequired = isCommentsRequired;
    self.approvalActionType = approvalActionType;
    self.delegate = delegate;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;

    self.placeholderTextLabel.text = RPLocalizedString(@"Comments must be added before proceeding.", @"Comments must be added before proceeding.");
    if (self.approvalActionType == RejectActionType) {
        UIBarButtonItem *rejectButton = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(REJECT_TEXT, REJECT_TEXT) style:UIBarButtonItemStylePlain target:self action:@selector(rejectAction)];
        rejectButton.tintColor = [self.theme rejectButtonColor];
        self.navigationItem.rightBarButtonItem = rejectButton;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(APPROVE_TEXT,APPROVE_TEXT) style:UIBarButtonItemStylePlain target:self action:@selector(approveAction)];
    }

    self.placeholderTextLabel.textColor = [self.theme approvalPlaceholderTextColor];
    self.placeholderTextLabel.font = [self.theme approvalPlaceholderTextFont];
    self.navigationItem.title = RPLocalizedString(@"Add Comment", @"Add Comment");
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.textViewHeightConstraint.constant = CGRectGetHeight(self.view.bounds);
    [self observeKeyboard];
}

#pragma mark - Private

- (void)observeKeyboard {
    [self.notificationCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [self.notificationCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *kbFrame = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];

    CGRect keyboardInViewFrame = [self.view convertRect:keyboardFrame fromView:nil];

    CGFloat keyboardMinY = CGRectGetMinY(keyboardInViewFrame);
    self.textViewHeightConstraint.constant = keyboardMinY;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    self.textViewHeightConstraint.constant = CGRectGetHeight(self.view.bounds);
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Actions

-(void)approveAction
{
    [self.delegate approvalsCommentsControllerDidRequestApproveAction:self withComments:self.commentsTextView.text];
}

-(void)rejectAction
{
    NSString *commentsString = self.commentsTextView.text;
    BOOL hasValidCharacter = [commentsString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0;
    ;
    BOOL shouldReject =  (self.isCommentsRequired && hasValidCharacter) || !self.isCommentsRequired;
    if (shouldReject)
        [self.delegate approvalsCommentsControllerDidRequestRejectAction:self withComments:self.commentsTextView.text];
    else
    {

        [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"OK", @"OK")
                                       otherButtonTitle:nil
                                               delegate:self
                                                message:RPLocalizedString(rejectionCommentsErrorText, @"")
                                                  title:nil
                                                    tag:LONG_MIN];

    }
}

-(void)cancelAction
{
    [self.commentsTextView resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark <UITextViewDelegate>

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.placeholderTextLabel.hidden = YES;
}


@end
