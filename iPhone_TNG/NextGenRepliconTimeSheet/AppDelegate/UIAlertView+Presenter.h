
#import <UIKit/UIKit.h>

@interface UIAlertView (Presenter)

+ (UIAlertView *)showAlertViewWithCancelButtonTitle:(NSString *)cancelButtonTitle
                                   otherButtonTitle:(NSString *)otherButtonTitle
                                           delegate:(id)delegate
                                            message:(NSString *)message
                                              title:(NSString *)title
                                                tag:(NSInteger)tag;
@end
