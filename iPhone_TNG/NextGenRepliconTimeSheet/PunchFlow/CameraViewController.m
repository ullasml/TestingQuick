
#import "CameraViewController.h"
#import "Constants.h"
#import "Theme.h"
#import "CameraButtonController.h"
#import <Blindside/BSInjector.h>
#import <AVFoundation/AVFoundation.h>

#define DegreesToRadians(x) ((x) * M_PI / 180.0)

@interface CameraViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *capturedImageView;

@property (weak, nonatomic) IBOutlet UIView *liveFeedImageView;
@property (nonatomic,assign) BOOL isFrontCameraModeIntended;

@property (nonatomic) id <Theme> theme;
@property (nonatomic) id <CameraViewControllerDelegate> delegate;

@property (nonatomic) CameraButtonController *cameraButtonController;
@property (nonatomic) id <BSInjector> injector;
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;



@end

@implementation CameraViewController

- (instancetype)initWithTheme:(id <Theme>)theme
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.theme = theme;
    }
    return self;
}

- (void)setUpWithDelegate:(id<CameraViewControllerDelegate>)delegate
{
    self.delegate = delegate;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeAll;

    self.isFrontCameraModeIntended = YES;
    self.view.backgroundColor = [UIColor blackColor];
    self.titleLabel.text = RPLocalizedString(CAMERA_MAIN_TITLE, CAMERA_MAIN_TITLE);
    self.titleLabel.font = [self.theme titleLabelFont];
    self.titleLabel.textColor = [self.theme titleLabelColor];
    self.titleLabel.backgroundColor = [UIColor clearColor];

    self.subTitleLabel.text = RPLocalizedString(CAMERA_SUB_TITLE, CAMERA_SUB_TITLE);
    self.subTitleLabel.font = [self.theme subTitleLabelFont];
    self.subTitleLabel.textColor = [self.theme subTitleLabelColor];
    self.subTitleLabel.backgroundColor = [UIColor clearColor];

    self.cameraButtonController = [self.injector getInstance:[CameraButtonController class]];
    [self.cameraButtonController setUpWithDelegate:self];
    [self addChildViewController:self.cameraButtonController];
    self.cameraButtonController.view.frame = self.containerView.bounds;
    [self.containerView addSubview:self.cameraButtonController.view];
    [self.cameraButtonController didMoveToParentViewController:self];


}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initializeCamera];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    DeviceType deviceType = [self getDeviceType];
    if (deviceType == OnSimulator)
    {
        self.cameraButtonController.retakeButton.hidden = YES;
        [self processImage:[Util thumbnailImage:@"dummy.jpg"]];
    }
    else
    {
        [self showLiveFeed:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cleanUp];
}

#pragma mark - <CameraButtonControllerDelegate>

- (void)userDidIntendToUseImage
{
    if ([self.delegate respondsToSelector:@selector(userIntendsToUseImage:)]) {
        [self.delegate userIntendsToUseImage:self.capturedImageView.image];
    }
}
- (void)userDidIntendToCancel
{
    if ([self.delegate respondsToSelector:@selector(userIntendsToCancel)]) {
        [self.delegate userIntendsToCancel];
    }
}

- (void)userDidIntendToCaptureImage
{
    [self captureImageFromAVCaptureSessionVideoFeed];
}

- (void)userDidIntendToRetakeImage
{
    [self showLiveFeed:YES];

}

#pragma mark - Private

- (void) initializeCamera
{
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    self.captureVideoPreviewLayer.frame = self.capturedImageView.bounds;

    [self.liveFeedImageView.layer addSublayer:self.captureVideoPreviewLayer];
    self.liveFeedImageView.layer.masksToBounds = YES;

    [self addAVCaptureDeviceInputToCaptureSession];

    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    [self.session addOutput:self.stillImageOutput];
    [self.session startRunning];


}


- (void)captureImageFromAVCaptureSessionVideoFeed
{
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
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
        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
         {
             if (imageSampleBuffer != NULL) {
                 NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                 [self processImage:[UIImage imageWithData:imageData]];
                 [self showLiveFeed:NO];
             }
         }];
    }

}


/******************************************************************************************************
 @Purpose         : Called to process captured image, crop, resize and rotate
 ******************************************************************************************************/

- (void)processImage:(UIImage *)image
{
    [self cropAndResizeImage:image];
}

-(void)cleanUp
{
    if (self.session.inputs.count >0)
    {
        AVCaptureInput* input = [self.session.inputs objectAtIndex:0];
        [self.session removeInput:input];
    }
    if (self.session.outputs.count > 0)
    {
        AVCaptureVideoDataOutput* output = (AVCaptureVideoDataOutput*)self.session.outputs.firstObject;
        [self.session removeOutput:output];
    }
    [self.captureVideoPreviewLayer removeFromSuperlayer];
    if (self.session.isRunning)
    {
        [self.session stopRunning];
    }
}

-(void)addAVCaptureDeviceInputToCaptureSession
{
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    for (AVCaptureDevice *device in devices)
    {
        if ([device hasMediaType:AVMediaTypeVideo])
        {
            if ([device position] == AVCaptureDevicePositionBack)
            {
                backCamera = device;
            }
            else
            {
                frontCamera = device;
            }
        }
    }

    if (!self.isFrontCameraModeIntended)
    {
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
        if (!error) {
            [self.session addInput:input];
        }
    }

    if (self.isFrontCameraModeIntended) {
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:frontCamera error:&error];
        if (!error) {
            [self.session addInput:input];
        }
    }
}

-(void)cropAndResizeImage:(UIImage *)image
{
    if([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)
    {
        UIGraphicsBeginImageContext(CGSizeMake(768, 1022));
        [image drawInRect: CGRectMake(0, 0, 768, 1022)];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        CGRect cropRect = CGRectMake(0, 210, 768, 610);
        CGImageRef imageRef = CGImageCreateWithImageInRect([smallImage CGImage], cropRect);
        self.capturedImageView.image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);

    }
    else
    {
        float height = CGRectGetHeight(self.capturedImageView.bounds);
        float width = CGRectGetWidth(self.capturedImageView.bounds);
        CGSize size = CGSizeMake(width, height);
        UIGraphicsBeginImageContext(size);
        [image drawInRect:self.capturedImageView.bounds];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        CGRect cropRect = CGRectMake(0, 0, 320, 320);
        CGImageRef imageRef = CGImageCreateWithImageInRect([smallImage CGImage], cropRect);
        self.capturedImageView.image = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
    }

    [self resizeImageBasedOnRotation];
}
/******************************************************************************************************
 @Purpose         : Called to adjust image orientation based on device orientation
 ******************************************************************************************************/

-(void)resizeImageBasedOnRotation
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationLandscapeLeft) {

        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        self.capturedImageView.transform = CGAffineTransformMakeRotation(DegreesToRadians(-90));
        [UIView commitAnimations];

    }
    if (orientation == UIDeviceOrientationLandscapeRight)
    {
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        self.capturedImageView.transform = CGAffineTransformMakeRotation(DegreesToRadians(90));
        [UIView commitAnimations];

    }
    if (orientation == UIDeviceOrientationPortraitUpsideDown)
    {
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        self.capturedImageView.transform = CGAffineTransformMakeRotation(DegreesToRadians(180));
        [UIView commitAnimations];

    }
    if (orientation == UIDeviceOrientationPortrait)
    {
        [UIView beginAnimations:@"rotate" context:nil];
        [UIView setAnimationDuration:0.5];
        self.capturedImageView.transform = CGAffineTransformMakeRotation(DegreesToRadians(0));
        [UIView commitAnimations];
    }
}

-(DeviceType)getDeviceType
{
    if (TARGET_IPHONE_SIMULATOR)
        return OnSimulator;
    else
        return OnDevice;
}

-(void)showLiveFeed:(BOOL)showLiveFeed
{
    if (showLiveFeed)
    {
        self.capturedImageView.hidden = YES;
        self.liveFeedImageView.hidden = NO;

        self.cameraButtonController.retakeButton.hidden = YES;
        self.cameraButtonController.useButton.hidden = YES;
        self.cameraButtonController.cameraButton.hidden = NO;
    }
    else
    {
        self.capturedImageView.hidden = NO;
        self.liveFeedImageView.hidden = YES;

        self.cameraButtonController.retakeButton.hidden = NO;
        self.cameraButtonController.useButton.hidden = NO;
        self.cameraButtonController.cameraButton.hidden = YES;
    }

}


@end
