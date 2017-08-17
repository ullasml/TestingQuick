#import "AddressControllerProvider.h"
#import "AddressController.h"
#import <KSDeferred/KSPromise.h>


@interface AddressControllerProvider ()

@property (nonatomic) id <Theme> theme;

@end


@implementation AddressControllerProvider

- (instancetype)initWithTheme:(id <Theme>)theme
{
    self = [super init];
    if (self) {
        self.theme = theme;
    }

    return self;
}

- (AddressController *)provideInstanceWithAddress:(NSString *)address
                                localPunchPromise:(KSPromise *)localPunchPromise
                                  backgroundColor:(UIColor *)backgroundColor
{
    return [[AddressController alloc] initWithLocalPunchPromise:localPunchPromise
                                                backgroundColor:backgroundColor
                                                        address:address
                                                          theme:self.theme];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


@end
