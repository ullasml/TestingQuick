#import <UIKit/UIKit.h>
#import "CameraViewController.h"

@interface PunchImagePickerControllerProvider : NSObject

- (UIImagePickerController *)provideInstanceWithDelegate:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>)delegate;

-(CameraViewController *)provideCameraInstanceWithDelegate:(id<CameraViewControllerDelegate>)delegate;

@end
