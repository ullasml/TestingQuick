#import "AllowAccessAlertHelper.h"
#import "Constants.h"


@interface AllowAccessAlertHelper () <UIAlertViewDelegate>

@property (nonatomic, weak) UIApplication *sharedApplication;

@end


@implementation AllowAccessAlertHelper

- (instancetype)initWithApplication:(UIApplication *)application
{
    self = [super init];
    if (self) {
        self.sharedApplication = application ;
    }
    return self;
}

- (void)handleLocationError:(NSError *)locationError cameraError:(NSError *)cameraError
{
    if (locationError) {
        NSString *title = RPLocalizedString(GPSAccessDisabledErrorAlertTitle, nil);
        NSString *message = RPLocalizedString(GPSAccessDisabledError, nil);

        [self showGoToSettingsAlertViewWithTitle:title message:message];
    }

    if (cameraError) {
        NSString *title = RPLocalizedString(CameraAccessDisabledErrorAlertTitle, nil);
        NSString *message = RPLocalizedString(CameraAccessDisabledError, nil);

        [self showGoToSettingsAlertViewWithTitle:title message:message];
    }
}

- (void)showGoToSettingsAlertViewWithTitle:(NSString *)title message:(NSString *)message
{
    NSString *cancelButtonTitle = UIApplicationOpenSettingsURLString ? RPLocalizedString(@"Cancel", @"Cancel") : RPLocalizedString(@"OK", @"OK");

    NSString *settingsButtonTitle = nil;
    if(UIApplicationOpenSettingsURLString) {
        settingsButtonTitle = RPLocalizedString(@"Settings", @"Settings");
    }

    [UIAlertView showAlertViewWithCancelButtonTitle:cancelButtonTitle
                                   otherButtonTitle:settingsButtonTitle
                                           delegate:self
                                            message:message
                                              title:title
                                                tag:LONG_MIN];

}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - <UIAlertViewDelegate>

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    AllowAccessAlertHelperAlertButton alertButtonIndex =  (AllowAccessAlertHelperAlertButton)buttonIndex;
    switch (alertButtonIndex) {
        case AllowAccessAlertHelperPunchAlertButtonSettings: {
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [self.sharedApplication openURL:url];
        }
        default:
            break;
    }
}

@end
