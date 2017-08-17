//
//  CameraCaptureViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Dipta Rakshit on 3/11/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PunchMapViewController.h"


@interface CameraCaptureViewController :  UIViewController{
    
    BOOL FrontCamera;
    BOOL haveImage;
    __weak id  _parentdelegate;
    AVCaptureSession *session;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
    UIButton *cameraCaptureBtn,*cancelCaptureBtn,*retakeCaptureBtn,*useCaptureBtn;
    UILabel *titleLbl,*subtitleLbl;
    __weak id _delegate;
    
}
@property (nonatomic, weak) id  _parentdelegate;
@property(nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;
@property(nonatomic,strong)PunchMapViewController *punchMapViewController;
//@property(nonatomic,strong) CLLocationManager   *locationManager;
@property(nonatomic,strong) NSMutableDictionary   *projectInfoDict;
@property(nonatomic, strong)UIView *imagePreview;
@property(nonatomic,assign)BOOL isUsingBreak;
@property (nonatomic, weak) id  _delegate;
//@property(nonatomic,strong) NSMutableDictionary   *locationDict;

- (void)snapImage:(id)sender;
-(void)cleanUp;
@property (nonatomic, strong)UIImageView *captureImage;

@property (nonatomic, strong)UIButton *cameraCaptureBtn,*cancelCaptureBtn,*retakeCaptureBtn,*useCaptureBtn;
@property (nonatomic, strong)UILabel *titleLbl,*subtitleLbl;
-(void)dismissCameraView;
@property(nonatomic,assign)BOOL isPunchIn;

@end
