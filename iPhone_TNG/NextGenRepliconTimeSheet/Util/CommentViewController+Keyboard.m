//
//  CommentViewController+Keyboard.m
//  NextGenRepliconTimeSheet


#import "CommentViewController+Keyboard.h"

@implementation CommentViewController (Keyboard)

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

@end
