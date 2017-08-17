
#import <UIKit/UIKit.h>
#import "PunchCardController.h"

@class ChildControllerHelper;

@protocol ProjectCreatePunchCardControllerDelegate;
@protocol UserSession;
@protocol Theme;

@interface ProjectCreatePunchCardController : UIViewController <PunchCardControllerDelegate>

@property (nonatomic, readonly) ChildControllerHelper *childControllerHelper;
@property (nonatomic, readonly) id<Theme> theme;

@property (weak, nonatomic, readonly) id<ProjectCreatePunchCardControllerDelegate>delegate;

@property (weak, nonatomic,readonly)  UIView *cardContainerView;

@property (weak, nonatomic,readonly)  NSLayoutConstraint *punchCardHeightConstraint;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithChildControllerHelper:(ChildControllerHelper *)childControllerHelper
                                        theme:(id <Theme>)theme;

- (void)setupWithDelegate:(id <ProjectCreatePunchCardControllerDelegate>)delegate;
@end


@protocol ProjectCreatePunchCardControllerDelegate <NSObject>

- (void)projectCreatePunchCardController:(ProjectCreatePunchCardController *)punchCardController
      didChooseToCreatePunchCardWithObject:(PunchCardObject *)punchCardObject;

@end