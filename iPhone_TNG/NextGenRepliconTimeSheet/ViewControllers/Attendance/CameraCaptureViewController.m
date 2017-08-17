//
//  CameraCaptureViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta Rakshit on 3/11/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "CameraCaptureViewController.h"
#import "Constants.h"
#import "PunchMapViewController.h"
#import "FrameworkImport.h"
#import "AttendanceService.h"
#import "RepliconServiceManager.h"
#import "AppDelegate.h"
#import "AttendanceViewController.h"
#import "UIView+Additions.h"

#define DegreesToRadians(x) ((x) * M_PI / 180.0)

@interface CameraCaptureViewController ()

@end

@implementation CameraCaptureViewController

@synthesize stillImageOutput, imagePreview, captureImage;
@synthesize _parentdelegate;
@synthesize cameraCaptureBtn,cancelCaptureBtn,retakeCaptureBtn,useCaptureBtn;
@synthesize titleLbl,subtitleLbl;
@synthesize punchMapViewController;
//@synthesize locationManager;
@synthesize projectInfoDict;
@synthesize isUsingBreak;
@synthesize _delegate;
//@synthesize locationDict;
@synthesize isPunchIn;


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;

    FrontCamera = YES;
    captureImage.hidden = YES;

    self.view.backgroundColor=[UIColor clearColor];
    //    [self.view setFrame:CGRectMake(0, 0, 320, 480)];


    self.titleLbl=[[UILabel alloc]initWithFrame:CGRectMake(0, 10, self.view.width, 25)];
    self.titleLbl.text=RPLocalizedString(CAMERA_MAIN_TITLE, CAMERA_MAIN_TITLE);
    [self.titleLbl setFont:[UIFont fontWithName:RepliconFontFamilyBold size:18.0]];
    self.titleLbl.textAlignment=NSTextAlignmentCenter;
    self.titleLbl.textColor=[UIColor whiteColor];
    self.titleLbl.backgroundColor=[UIColor clearColor];
    [self.view addSubview:self.titleLbl];

    CGFloat subtitlePadding = 30;
    self.subtitleLbl=[[UILabel alloc]initWithFrame:CGRectMake(subtitlePadding, self.titleLbl.bottom, self.view.width-(2*subtitlePadding), 50)];
    
    self.subtitleLbl.text=RPLocalizedString(CAMERA_SUB_TITLE, CAMERA_MAIN_TITLE);
    [self.subtitleLbl setFont:[UIFont fontWithName:RepliconFontFamily size:14.0]];
    self.subtitleLbl.textAlignment=NSTextAlignmentCenter;
    self.subtitleLbl.textColor=[UIColor grayColor];
    self.subtitleLbl.backgroundColor=[UIColor clearColor];
    self.subtitleLbl.numberOfLines=2;
    [self.view addSubview:self.subtitleLbl];

    CGSize captureButtonSize = CGSizeMake(66.0, 66.0);
    
    CGFloat y=(((SCREEN_HEIGHT-SCREEN_WIDTH)/2)+SCREEN_WIDTH)-captureButtonSize.height;
    CGFloat availableSpace=(SCREEN_HEIGHT-y)/2;
    y=y+availableSpace;
    
    self.cameraCaptureBtn=[[UIButton alloc]initWithFrame:CGRectMake((self.view.width-captureButtonSize.width)/2,y, captureButtonSize.width, captureButtonSize.height)];
    [self.cameraCaptureBtn setBackgroundImage:[Util thumbnailImage:BTN_CAMERA_CAPTURE] forState:UIControlStateNormal];
    [self.cameraCaptureBtn setBackgroundColor:[UIColor clearColor]];
    [self.cameraCaptureBtn addTarget:self action:@selector(cameraBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cameraCaptureBtn];

    CGFloat buttonPadding = 10.0;
    CGFloat buttonWidth = (self.view.width-(4*buttonPadding))/3;

    self.cancelCaptureBtn=[[UIButton alloc]initWithFrame:CGRectMake(buttonPadding,y, buttonWidth, 66.0)];
    [self.cancelCaptureBtn setTitle:RPLocalizedString(CANCEL_STRING, CANCEL_STRING) forState:UIControlStateNormal];
    [self.cancelCaptureBtn setBackgroundColor:[UIColor clearColor]];
    [self.cancelCaptureBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.cancelCaptureBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelCaptureBtn];

    self.retakeCaptureBtn=[[UIButton alloc]initWithFrame:CGRectMake(self.cancelCaptureBtn.right+buttonPadding,y, buttonWidth, 66.0)];
    [self.retakeCaptureBtn setTitle:RPLocalizedString(RETAKE_STRING, RETAKE_STRING) forState:UIControlStateNormal];
    [self.retakeCaptureBtn setBackgroundColor:[UIColor clearColor]];
    [self.retakeCaptureBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    self.retakeCaptureBtn.hidden=TRUE;
    [self.retakeCaptureBtn addTarget:self action:@selector(cameraBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.retakeCaptureBtn];

    self.useCaptureBtn=[[UIButton alloc]initWithFrame:CGRectMake(self.view.width-buttonWidth-buttonPadding,y, buttonWidth, 66.0)];
    [self.useCaptureBtn setTitle:RPLocalizedString(USE_STRING, USE_STRING) forState:UIControlStateNormal];
    //[self.useCaptureBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.useCaptureBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.useCaptureBtn setBackgroundColor:[UIColor clearColor]];
    self.useCaptureBtn.hidden=TRUE;
    //self.useCaptureBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 50, 0, 0);
    [self.useCaptureBtn addTarget:self action:@selector(useBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.useCaptureBtn];
}

- (void)viewDidAppear:(BOOL)animated {


    DeviceType deviceType = [self getDeviceType];
    if (deviceType == OnDevice)
    {
        //running on device
    } else {
        [self processImage:[Util thumbnailImage:@"dummy.jpg"]];
    }



}

-(void)viewWillAppear:(BOOL)animated{

    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    [self initializeCamera];
    self.view.backgroundColor=[UIColor blackColor];


}


-(void)viewWillDisappear:(BOOL)animated{

    [super viewWillDisappear:animated];

    [self.tabBarController.tabBar setHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];    // it shows
    [self cleanUp];
}


//AVCaptureSession to show live video feed in view
- (void) initializeCamera {

    [self.tabBarController.tabBar setHidden:YES];
    self.view.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);


    session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetPhoto;

    captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];

    self.imagePreview=[[UIView alloc]initWithFrame:CGRectMake(0, (SCREEN_HEIGHT-SCREEN_WIDTH)/2, SCREEN_WIDTH, SCREEN_WIDTH)];
    self.imagePreview.backgroundColor=[UIColor clearColor];
    self.captureImage=[[UIImageView alloc]initWithFrame:CGRectMake(0, (SCREEN_HEIGHT-SCREEN_WIDTH)/2, SCREEN_WIDTH, SCREEN_WIDTH)];
    self.captureImage.backgroundColor=[UIColor clearColor];
    [self.view addSubview:imagePreview];
    [self.view addSubview:captureImage];

    captureVideoPreviewLayer.frame = self.imagePreview.bounds;
    [self.imagePreview.layer addSublayer:captureVideoPreviewLayer];

    UIView *view = [self imagePreview];
    CALayer *viewLayer = [view layer];
    [viewLayer setMasksToBounds:YES];

    CGRect bounds = [view bounds];
    [captureVideoPreviewLayer setFrame:bounds];

    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;

    for (AVCaptureDevice *device in devices) {

        //        NSLog(@"Device name: %@", [device localizedName]);

        if ([device hasMediaType:AVMediaTypeVideo]) {

            if ([device position] == AVCaptureDevicePositionBack) {
                NSLog(@"Device position : back");
                backCamera = device;
            }
            else {
                NSLog(@"Device position : front");
                frontCamera = device;
            }
        }
    }

    if (!FrontCamera) {
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
        if (!input) {
            NSLog(@"ERROR: trying to open camera: %@", error);
        }
        else
        {
            [session addInput:input];
        }

    }

    if (FrontCamera) {
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        if (!input) {
            NSLog(@"ERROR: trying to open camera: %@", error);
        }
        else
        {
            [session addInput:input];
        }

    }

    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [stillImageOutput setOutputSettings:outputSettings];

    [session addOutput:stillImageOutput];

    [session startRunning];
}











- (void)snapImage:(id)sender {
    if (!haveImage) {
        captureImage.image = nil; //remove old image from view
        captureImage.hidden = NO; //show the captured image view
        imagePreview.hidden = YES; //hide the live video feed



        [self capImage];
    }
    else {
        captureImage.hidden = YES;
        imagePreview.hidden = NO;
        haveImage = NO;


    }

    self.retakeCaptureBtn.hidden=TRUE;
    self.useCaptureBtn.hidden=TRUE;

    self.cameraCaptureBtn.hidden=FALSE;

    self.titleLbl.text=RPLocalizedString(CAMERA_MAIN_TITLE, CAMERA_MAIN_TITLE);
}

- (void) capImage { //method to capture image from AVCaptureSession video feed
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stillImageOutput.connections) {

        for (AVCaptureInputPort *port in [connection inputPorts]) {

            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }

        if (videoConnection) {
            break;
        }
    }

    if(videoConnection.active)
    {
        [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {

            if (imageSampleBuffer != NULL) {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                [self processImage:[UIImage imageWithData:imageData]];
            }
        }];
    }

}


- (void) processImage:(UIImage *)image { //process captured image, crop, resize and rotate
    haveImage = YES;


    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
    { //Device is ipad
        // Resize image
        UIGraphicsBeginImageContext(CGSizeMake(768, 1022));
        [image drawInRect: CGRectMake(0, 0, 768, 1022)];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        //CGRect cropRect = CGRectMake(0, 130, 768, 768);
        CGRect cropRect = CGRectMake(0, 210, 768, 610);
        CGImageRef imageRef = CGImageCreateWithImageInRect([smallImage CGImage], cropRect);
        //or use the UIImage wherever you like

        [captureImage setImage:[UIImage imageWithCGImage:imageRef]];

        CGImageRelease(imageRef);

    }
    else{ //Device is iphone
        // Resize image
        UIGraphicsBeginImageContext(CGSizeMake(320, 427));
        [image drawInRect: CGRectMake(0, 0, 320, 427)];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        CGRect cropRect = CGRectMake(0, 50, 320, 320);
        CGImageRef imageRef = CGImageCreateWithImageInRect([smallImage CGImage], cropRect);

        [captureImage setImage:[UIImage imageWithCGImage:imageRef]];

        CGImageRelease(imageRef);
    }

    //adjust image orientation based on device orientation
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) {
        NSLog(@"landscape left image");

        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        captureImage.transform = CGAffineTransformMakeRotation(DegreesToRadians(-90));
        [UIView commitAnimations];

    }
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight) {
        NSLog(@"landscape right");

        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        captureImage.transform = CGAffineTransformMakeRotation(DegreesToRadians(90));
        [UIView commitAnimations];

    }
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
        NSLog(@"upside down");
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        captureImage.transform = CGAffineTransformMakeRotation(DegreesToRadians(180));
        [UIView commitAnimations];

    }
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait) {
        NSLog(@"upside upright");
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        captureImage.transform = CGAffineTransformMakeRotation(DegreesToRadians(0));
        [UIView commitAnimations];
    }


    self.retakeCaptureBtn.hidden=FALSE;
    self.useCaptureBtn.hidden=FALSE;

    self.cameraCaptureBtn.hidden=TRUE;

    self.titleLbl.text=RPLocalizedString(CAMERA_PREVIEW_TITLE, CAMERA_PREVIEW_TITLE);

    //SET THIS IMAGE IN PARENT DELEGATE

}



-(void)cleanUp
{
    if ([session.inputs count]>0)
    {
        AVCaptureInput* input = [session.inputs objectAtIndex:0];
        [session removeInput:input];
    }
    if ([session.outputs count]>0)
    {
        AVCaptureVideoDataOutput* output = (AVCaptureVideoDataOutput*)[session.outputs objectAtIndex:0];
        [session removeOutput:output];
    }



    [captureVideoPreviewLayer removeFromSuperlayer];

    if (session.isRunning)
    {
        [session stopRunning];
    }


}

-(void)dismissCameraView
{
    // [locationManager stopUpdatingLocation];
    self.view.backgroundColor=[UIColor clearColor];
    //[self.punchMapViewController.view removeFromSuperview];
    if([_delegate isKindOfClass:[AttendanceViewController class]])
    {
        AttendanceViewController *vc = (AttendanceViewController*)_delegate;
        [self.navigationController popToViewController:vc animated:YES];
        [_delegate  addActiVityIndicator];
    }
    else
        [self.navigationController popToRootViewControllerAnimated:YES];
}


-(void)cameraBtnClicked:(id)sender
{
    CLS_LOG(@"-----Camera Capture Button clicked for a photo -----");
    [self snapImage:sender];
}

-(void)cancelBtnClicked:(id)sender
{
    CLS_LOG(@"-----cancel Button clicked for a photo -----");
    [self.navigationController popViewControllerAnimated:TRUE];
    if([_delegate isKindOfClass:[AttendanceViewController class]])
    {
        [_delegate showLastPunchDataView];
    }
}

-(void)useBtnClicked:(id)sender
{
    CLS_LOG(@"-----Use Button clicked for a photo -----");

    if (![NetworkMonitor isNetworkAvailableForListener:self])
    {
        [Util showOfflineAlert];

    }
    else
    {
        //self.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        UIImage *capturedImage=(UIImage *)self.captureImage.image;
        PunchMapViewController *cameraViewCtrl=[[PunchMapViewController alloc]init];
        self.punchMapViewController=cameraViewCtrl;
        cameraViewCtrl.isClockIn=isPunchIn;
        cameraViewCtrl.clockUserImage=capturedImage;
        cameraViewCtrl.originalClockUserImage=capturedImage;
        cameraViewCtrl.delegate=self;
        cameraViewCtrl.punchTime=[Util getCurrentTime:YES];
        cameraViewCtrl.punchTimeAmPm=[Util getCurrentTime:NO];
        cameraViewCtrl._parentDelegate=_delegate;

        if ([_delegate isKindOfClass:[AttendanceViewController class]])
        {
            AttendanceViewController *attCtrl=(AttendanceViewController *)_delegate;
            cameraViewCtrl.locationDict=attCtrl.locationDict;
        }

        AttendanceViewController *attCtrl=(AttendanceViewController *)_parentdelegate;
        attCtrl.punchMapViewController=self.punchMapViewController;





        cameraViewCtrl.projectInfoDict=projectInfoDict;
        [cameraViewCtrl checkForLocation];
        //    CGRect frame=cameraViewCtrl.view.frame;
        //    frame.origin.y=frame.origin.y+50;
        //    cameraViewCtrl.view.frame=frame;
        //AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        //[appDelegate.window addSubview:cameraViewCtrl.view];

    }



}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(DeviceType)getDeviceType
{
    if (TARGET_IPHONE_SIMULATOR)
        return OnSimulator;
    else
        return OnDevice;
}

@end
