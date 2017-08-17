#import "AddressControllerPresenterProvider.h"
#import "AddressControllerProvider.h"
#import "AddressControllerPresenter.h"
#import <KSDeferred/KSPromise.h>
#import "UserPermissionsStorage.h"


@interface AddressControllerPresenterProvider ()

@property (nonatomic) AddressControllerProvider *addressControllerProvider;
@property (nonatomic) UserPermissionsStorage *punchRulesStorage;
@property (nonatomic) id<Theme> theme;

@end


@implementation AddressControllerPresenterProvider

- (instancetype)initWithAddressControllerProvider:(AddressControllerProvider *)addressControllerProvider
                                punchRulesStorage:(UserPermissionsStorage *)punchRulesStorage
                                            theme:(id<Theme>)theme
{
    self = [super init];
    if (self)
    {
        self.addressControllerProvider = addressControllerProvider;
        self.punchRulesStorage = punchRulesStorage;
        self.theme = theme;
    }
    return self;
}

- (AddressControllerPresenter *)provideInstanceWith:(KSPromise *)localPunchPromise
{
    return [[AddressControllerPresenter alloc] initWithAddressControllerProvider:self.addressControllerProvider
                                                               localPunchPromise:localPunchPromise
                                                               punchRulesStorage:self.punchRulesStorage
                                                                           theme:self.theme];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
