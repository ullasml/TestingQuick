
#import <UIKit/UIKit.h>
@protocol Theme;

@interface WrongConfigurationMessageViewController : UIViewController

@property (nonatomic, readonly)  id<Theme>                  theme;

@property (nonatomic, weak, readonly) UILabel               *msgLabel;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary  UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTheme:(id<Theme>)theme;

@end
