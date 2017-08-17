
#import <UIKit/UIKit.h>

@protocol Theme;
@protocol Timesheet;
@protocol HeaderButtonControllerDelegate;


@protocol HeaderButtonControllerDelegate
-(void)userDidIntendToViewViolationsWidget;
@end


@interface HeaderButtonViewController : UIViewController


@property (weak, nonatomic, readonly) UIView *containerView;
@property (weak, nonatomic, readonly) UIImageView *approvalStatusImageView;
@property (weak, nonatomic, readonly) UILabel *approvalStatusLabel;
@property (weak, nonatomic, readonly) UIImageView *issuesStatusImageView;
@property (weak, nonatomic, readonly) UILabel *issuesStatusLabel;
@property (weak, nonatomic, readonly) UIButton *issuesButton;
@property (weak, nonatomic, readonly) UIButton *approvalStatusButton;
@property (weak, nonatomic, readonly) UIView *issuesStatusView;
@property (weak, nonatomic, readonly) UILabel *issuesCountLabel;

@property (nonatomic, readonly) id<Theme> theme;
@property (nonatomic,weak, readonly) id <HeaderButtonControllerDelegate > delegate;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTheme:(id<Theme>)theme NS_DESIGNATED_INITIALIZER;
- (void)setupWithDelegate:(id <HeaderButtonControllerDelegate>)delegate
                timesheet:(id <Timesheet>)timesheet;
@end


