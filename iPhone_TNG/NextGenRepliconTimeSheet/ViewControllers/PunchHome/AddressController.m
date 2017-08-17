#import "AddressController.h"
#import "Theme.h"
#import <KSDeferred/KSPromise.h>
#import "LocalPunch.h"


@interface AddressController ()

@property (nonatomic, weak) IBOutlet UILabel *addressLabel;

@property (nonatomic) KSPromise *localPunchPromise;
@property (nonatomic) UIColor *backgroundColor;
@property (nonatomic, copy) NSString *address;
@property (nonatomic) id<Theme> theme;

@end


@implementation AddressController

- (instancetype)initWithLocalPunchPromise:(KSPromise *)localPunchPromise
                          backgroundColor:(UIColor *)backgroundColor
                                  address:(NSString *)address
                                    theme:(id<Theme>)theme
{
    self = [super init];
    if (self)
    {
        self.localPunchPromise = localPunchPromise;
        self.backgroundColor = backgroundColor;
        self.address = address;
        self.theme = theme;
    }

    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = self.backgroundColor;
    self.view.layer.cornerRadius = 5.0f;

    if (self.address)
    {
        self.addressLabel.text = self.address;
    }
    else
    {
        self.addressLabel.text = RPLocalizedString(LOCATION_UNAVAILABLE_STRING, @"");
    }

    self.addressLabel.font = self.theme.addressLabelFont;
    self.addressLabel.textColor = self.theme.addressLabelTextColor;
    [self.localPunchPromise then:^id(LocalPunch *localCompletePunch) {
        if (localCompletePunch.address)
        {
            self.addressLabel.text = localCompletePunch.address;
        }
        else
        {
            self.addressLabel.text = RPLocalizedString(LOCATION_UNAVAILABLE_STRING, @"");
        }
        return nil;
    } error:^id(NSError *error) {
        NSLog(@"error");
        return error;
    }];
    [self.addressLabel setAccessibilityIdentifier:@"punch_address_lbl"];
}

@end
