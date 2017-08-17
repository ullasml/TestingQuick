#import <UIKit/UIKit.h>


@class KSPromise;
@class AddressController;
@class AddressControllerProvider;
@class UserPermissionsStorage;
@protocol Theme;


@interface AddressControllerPresenter : NSObject

@property (nonatomic, readonly) AddressControllerProvider *addressControllerProvider;
@property (nonatomic, readonly) UserPermissionsStorage *punchRulesStorage;
@property (nonatomic, readonly) KSPromise *localPunchPromise;
@property (nonatomic, readonly) id<Theme> theme;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithAddressControllerProvider:(AddressControllerProvider *)addressControllerProvider
                                localPunchPromise:(KSPromise *)localPunchPromise
                                punchRulesStorage:(UserPermissionsStorage *)punchRulesStorage
                                            theme:(id<Theme>)theme;

- (AddressController *)presentAddress:(NSString *)address
      ifNeededInAddressLabelContainer:(UIView *)addressLabelContainer
                   onParentController:(UIViewController *)parentController
                      backgroundColor:(UIColor *)backgroundColor;

@end
