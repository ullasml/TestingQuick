

#import "UIAlertView+Presenter.h"
#import "AppDelegate.h"

@implementation UIAlertView (Presenter)

+ (UIAlertView *)showAlertViewWithCancelButtonTitle:(NSString *)cancelButtonTitle
                                   otherButtonTitle:(NSString *)otherButtonTitle
                                           delegate:(id)delegate
                                            message:(NSString *)message
                                              title:(NSString *)title
                                                tag:(NSInteger)tag {

    [self dismissAllVisibleAlertViews];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:delegate
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:otherButtonTitle,nil];
    [alert show];
    alert.delegate = delegate;
    alert.tag = tag;
    return alert;
    
}

@end
