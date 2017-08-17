
#import <UIKit/UIKit.h>
#import "CameraButtonController.h"

@protocol Theme;
@protocol CameraViewControllerDelegate;

@interface CameraViewController : UIViewController <CameraButtonControllerDelegate>

@property (weak, nonatomic, readonly)  UILabel *titleLabel;
@property (weak, nonatomic, readonly)  UILabel *subTitleLabel;
@property (weak, nonatomic, readonly)  UIView *containerView;

@property (nonatomic,readonly) id <Theme> theme;
@property (nonatomic,readonly) id <CameraViewControllerDelegate> delegate;

- (instancetype)initWithTheme:(id <Theme>)theme NS_DESIGNATED_INITIALIZER;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (void)setUpWithDelegate:(id<CameraViewControllerDelegate>)delegate;
@end

@protocol CameraViewControllerDelegate <NSObject>

- (void)userIntendsToUseImage:(UIImage *)image;
- (void)userIntendsToCancel;

@end
