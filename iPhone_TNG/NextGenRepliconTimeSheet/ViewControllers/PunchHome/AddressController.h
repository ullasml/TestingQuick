#import <UIKit/UIKit.h>


@class KSPromise;
@protocol Theme;


@interface AddressController : UIViewController

@property (nonatomic, weak, readonly) UILabel *addressLabel;

@property (nonatomic, readonly) KSPromise *localPunchPromise;
@property (nonatomic, readonly) UIColor *backgroundColor;
@property (nonatomic, copy, readonly) NSString *address;
@property (nonatomic, readonly) id <Theme> theme;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithLocalPunchPromise:(KSPromise *)localPunchPromise
                          backgroundColor:(UIColor *)backgroundColor
                                  address:(NSString *)address
                                    theme:(id<Theme>)theme;

@end
