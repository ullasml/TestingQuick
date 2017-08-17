#import <Foundation/Foundation.h>


@class KSPromise;
@class UserPermissionsStorage;
@class AddressControllerPresenter;
@class AddressControllerProvider;
@protocol Theme;


@interface AddressControllerPresenterProvider : NSObject

@property (nonatomic, readonly) AddressControllerProvider *addressControllerProvider;
@property (nonatomic, readonly) UserPermissionsStorage *punchRulesStorage;
@property (nonatomic, readonly) id<Theme> theme;

- (instancetype)initWithAddressControllerProvider:(AddressControllerProvider *)addressControllerProvider
                                punchRulesStorage:(UserPermissionsStorage *)punchRulesStorage
                                            theme:(id<Theme>)theme;

- (AddressControllerPresenter *)provideInstanceWith:(KSPromise *)localPunchPromise;

@end
