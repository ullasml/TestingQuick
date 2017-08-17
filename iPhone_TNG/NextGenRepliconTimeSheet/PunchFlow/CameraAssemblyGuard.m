#import "CameraAssemblyGuard.h"
#import <KSDeferred/KSDeferred.h>
#import "Constants.h"
#import "UserPermissionsStorage.h"


@interface CameraAssemblyGuard ()

@property (nonatomic) UserPermissionsStorage  *userPermissionsStorage;
@property (nonatomic) NSOperationQueue *mainQueue;

@end

@implementation CameraAssemblyGuard

- (instancetype)initWithUserPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                                     mainQueue:(NSOperationQueue *)mainQueue
{
    self = [super init];
    if(self)
    {
        self.userPermissionsStorage = userPermissionsStorage;
        self.mainQueue = mainQueue;
    }
    return self;
}

- (KSPromise*)shouldAssemble
{
    KSDeferred *imageGuardDeferred = [[KSDeferred alloc] init];

    if(!self.userPermissionsStorage.selfieRequired)
    {
        [imageGuardDeferred resolveWithValue:@(YES)];
    } else {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            [self.mainQueue addOperationWithBlock:^{
                if (granted) {
                    [imageGuardDeferred resolveWithValue:@(YES)];
                }
                else {
                    NSError  *expectedError = [[NSError alloc] initWithDomain:CameraAssemblyGuardErrorDomain
                                                                         code:CameraAssemblyGuardErrorCodeDeniedAccessToCamera
                                                                     userInfo:nil];
                    [imageGuardDeferred rejectWithError:expectedError];
                }
            }];
        }];
    }

    return imageGuardDeferred.promise;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


@end
