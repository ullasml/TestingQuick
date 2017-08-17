

#import <UIKit/UIKit.h>
#import "Constants.h"

@protocol Theme;
@protocol ApprovalCommentsControllerDelegate;

@interface ApprovalCommentsController : UIViewController<UITextViewDelegate>

@property (nonatomic, weak, readonly) id <ApprovalCommentsControllerDelegate> delegate;
@property (nonatomic, weak, readonly) UITextView *commentsTextView;
@property (weak, nonatomic, readonly) UILabel *placeholderTextLabel;
@property (nonatomic, readonly) NSNotificationCenter *notificationCenter;
@property (weak, nonatomic, readonly) NSLayoutConstraint *textViewHeightConstraint;
@property (nonatomic, readonly) id <Theme> theme;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithNotificationCenter:(NSNotificationCenter *)notificationCenter theme:(id<Theme>)theme;
- (void)setUpApprovalActionType:(ApprovalActionType )approvalActionType delegate:(id <ApprovalCommentsControllerDelegate>)delegate commentsRequired:(BOOL)isCommentsRequired;

@end

@protocol ApprovalCommentsControllerDelegate <NSObject>

-(void)approvalsCommentsControllerDidRequestApproveAction:(ApprovalCommentsController *)approvalCommentsController withComments:(NSString *)comments;
-(void)approvalsCommentsControllerDidRequestRejectAction:(ApprovalCommentsController *)approvalCommentsController withComments:(NSString *)comments;


@end
