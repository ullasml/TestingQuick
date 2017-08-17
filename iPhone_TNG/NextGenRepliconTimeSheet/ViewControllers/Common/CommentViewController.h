

#import <UIKit/UIKit.h>
#import "Theme.h"

@protocol CommentViewControllerDelegate;

@interface CommentViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, weak) id<CommentViewControllerDelegate> delegate;
@property (weak, nonatomic, readonly) IBOutlet UITextView *commentsTextView;
@property (nonatomic, readonly) id <Theme> theme;
@property (nonatomic, readonly) NSNotificationCenter *notificationCenter;
@property (nonatomic, readonly) IBOutlet NSLayoutConstraint *textViewHeightConstraint;
@property (weak, nonatomic, readonly) IBOutlet UILabel *placeholderLabel;

- (instancetype)initWithTheme:(id<Theme>)theme
           notificationCenter:(NSNotificationCenter *)notificationCenter;

- (void)setupAction:(NSString *)action delegate:(id)delegate;

@end


@protocol CommentViewControllerDelegate <NSObject>

@optional

- (void)commentsViewController:(CommentViewController *)commentViewController didPressOnActionButton:(id)sender withCommentsText:(NSString *)commentsText;

- (void)commentsViewController:(CommentViewController *)commentViewController 
                    actionType:(RightBarButtonActionType)actionType 
                      comments:(NSString *)comments;

@end
