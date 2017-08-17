#import "PunchImagePickerControllerProvider.h"
#import "CameraViewController.h"
#import <Blindside/BSInjector.h>

@interface PunchImagePickerControllerProvider ()

@property (weak, nonatomic) id<BSInjector> injector;

@end

@implementation PunchImagePickerControllerProvider

- (UIImagePickerController *)provideInstanceWithDelegate:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>)delegate
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.delegate = delegate;

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        controller.allowsEditing = NO;
        controller.sourceType = UIImagePickerControllerSourceTypeCamera;
        controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }

    return controller;
}

-(CameraViewController *)provideCameraInstanceWithDelegate:(id<CameraViewControllerDelegate>)delegate
{
    CameraViewController *cameraViewController = [self.injector getInstance:[CameraViewController class]];
    [cameraViewController setUpWithDelegate:delegate];
    cameraViewController.hidesBottomBarWhenPushed = YES;
    return cameraViewController;
}

@end
