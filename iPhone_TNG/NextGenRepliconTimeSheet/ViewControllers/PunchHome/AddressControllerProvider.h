#import <Foundation/Foundation.h>


@class AddressController;
@protocol Theme;
@class KSPromise;

@interface AddressControllerProvider : NSObject

@property (nonatomic, readonly) id <Theme> theme;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithTheme:(id <Theme>)theme NS_DESIGNATED_INITIALIZER;

- (AddressController *)provideInstanceWithAddress:(NSString *)address
                                localPunchPromise:(KSPromise *)localPunchPromise
                                  backgroundColor:(UIColor *)backgroundColor;


@end
