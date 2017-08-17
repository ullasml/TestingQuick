
#import <UIKit/UIKit.h>
#import "Theme.h"
@protocol CameraButtonControllerDelegate;

@interface CameraButtonController : UIViewController

@property (weak,nonatomic)IBOutlet UIButton *cancelButton;
@property (weak,nonatomic)IBOutlet UIButton *retakeButton;
@property (weak,nonatomic)IBOutlet UIButton *useButton;
@property (weak,nonatomic)IBOutlet UIButton *cameraButton;
@property (nonatomic,readonly) id <CameraButtonControllerDelegate> delegate;
@property (nonatomic,readonly) id <Theme> theme;


-(void)setUpWithDelegate:(id <CameraButtonControllerDelegate>)delegate;

- (instancetype)initWithTheme:(id <Theme>)theme NS_DESIGNATED_INITIALIZER;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

@end

@protocol CameraButtonControllerDelegate <NSObject>

- (void)userDidIntendToUseImage;
- (void)userDidIntendToCancel;
- (void)userDidIntendToCaptureImage;
- (void)userDidIntendToRetakeImage;


@end


