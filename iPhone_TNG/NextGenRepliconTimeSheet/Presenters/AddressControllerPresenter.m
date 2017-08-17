#import "AddressControllerPresenter.h"
#import "AddressControllerProvider.h"
#import "AddressController.h"
#import "Theme.h"
#import <KSDeferred/KSPromise.h>
#import "UserPermissionsStorage.h"


@interface AddressControllerPresenter ()

@property (nonatomic) AddressControllerProvider *addressControllerProvider;
@property (nonatomic) UserPermissionsStorage *punchRulesStorage;
@property (nonatomic) KSPromise *localPunchPromise;
@property (nonatomic) id<Theme> theme;

@end


@implementation AddressControllerPresenter

- (instancetype)initWithAddressControllerProvider:(AddressControllerProvider *)addressControllerProvider
                                localPunchPromise:(KSPromise *)localPunchPromise
                                punchRulesStorage:(UserPermissionsStorage *)punchRulesStorage
                                            theme:(id<Theme>)theme
{
    self = [super init];
    if (self)
    {
        self.addressControllerProvider = addressControllerProvider;
        self.punchRulesStorage = punchRulesStorage;
        self.localPunchPromise = localPunchPromise;
        self.theme = theme;
    }
    return self;
}

- (AddressController *)presentAddress:(NSString *)address
      ifNeededInAddressLabelContainer:(UIView *)addressLabelContainer
                   onParentController:(UIViewController *)parentController
                      backgroundColor:(UIColor *)backgroundColor
{
    if ([self.punchRulesStorage geolocationRequired])
    {
        AddressController *addressController = [self.addressControllerProvider provideInstanceWithAddress:address
                                                                                        localPunchPromise:self.localPunchPromise
                                                                                          backgroundColor:backgroundColor];

        [parentController addChildViewController:addressController];
        UIView *addressControllerView = addressController.view;
        [addressLabelContainer addSubview:addressControllerView];
        addressController.view.frame = addressLabelContainer.bounds;

        [addressController didMoveToParentViewController:parentController];
        addressLabelContainer.backgroundColor = [self.theme transparentColor];

        return addressController;
    }
    else
    {
        [addressLabelContainer removeFromSuperview];
    }

    return nil;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
