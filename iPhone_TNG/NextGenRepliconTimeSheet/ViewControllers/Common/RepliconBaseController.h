
#import <UIKit/UIKit.h>

@protocol Theme ;

@interface RepliconBaseController : UIViewController

@property (nonatomic,readonly) id <Theme> theme;

@end

