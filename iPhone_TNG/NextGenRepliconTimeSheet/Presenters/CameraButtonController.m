
#import "CameraButtonController.h"
#import "Constants.h"

@interface CameraButtonController ()
@property (nonatomic) id <CameraButtonControllerDelegate> delegate;
@property (nonatomic) id <Theme> theme;

@end

@implementation CameraButtonController

- (instancetype)initWithTheme:(id <Theme>)theme
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.theme = theme;
    }
    return self;
}

-(void)setUpWithDelegate:(id <CameraButtonControllerDelegate>)delegate
{
    self.delegate = delegate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.cancelButton.backgroundColor = [self.theme cancelButtonBackgroundColor];
    self.retakeButton.backgroundColor = [self.theme retakeButtonBackgroundColor];
    self.useButton.backgroundColor = [self.theme useButtonBackgroundColor];
    self.cameraButton.backgroundColor = [self.theme cameraButtonBackgroundColor];

    DeviceType deviceType = [self getDeviceType];
    if (deviceType == OnSimulator)
    {
        self.retakeButton.hidden = YES;
        self.cameraButton.hidden = YES;
    }

}

- (IBAction)cancelButtonAction:(id)sender
{
    [self.delegate userDidIntendToCancel];
}

- (IBAction)cameraButtonAction:(id)sender
{
    [self.delegate userDidIntendToCaptureImage];
}
- (IBAction)useButtonAction:(id)sender
{
    [self.delegate userDidIntendToUseImage];
}
- (IBAction)retakeButtonAction:(id)sender
{
    [self.delegate userDidIntendToRetakeImage];
}

#pragma mark - Private

-(DeviceType)getDeviceType
{
    UIDevice *currentDevice = [UIDevice currentDevice];
    if ([currentDevice.model rangeOfString:@"Simulator"].location == NSNotFound)
        return OnDevice;
    else
        return OnSimulator;

}




@end
