#import "LocationAssemblyGuard.h"
#import "UserPermissionsStorage.h"
#import <KSDeferred/KSDeferred.h>
#import "Constants.h"
#import <CoreLocation/CoreLocation.h>

@interface LocationAssemblyGuard ()

@property (nonatomic) UserPermissionsStorage *userPermissionsStorage;

@end

@implementation LocationAssemblyGuard

- (instancetype) initWithUserPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
{
    self = [super init];
    if (self) {
        self.userPermissionsStorage = userPermissionsStorage;
    }
    return self;
}

- (KSPromise *)shouldAssemble
{

    KSDeferred *shouldAssembleDeferred = [[KSDeferred alloc] init];

    BOOL geolocationPermissionGranted = NO;

    switch ([CLLocationManager authorizationStatus]) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            geolocationPermissionGranted = YES;
            break;
        case kCLAuthorizationStatusNotDetermined:
            geolocationPermissionGranted = NO;
            break;
        default:
            geolocationPermissionGranted = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways;
    }


    if(!self.userPermissionsStorage.geolocationRequired || geolocationPermissionGranted) {
        [shouldAssembleDeferred resolveWithValue:@(YES)];
    }
    else {
        NSError *expectedError = [[NSError alloc] initWithDomain:LocationAssemblyGuardErrorDomain code:LocationAssemblyGuardErrorCodeDeniedAccessToLocation userInfo:nil];            [shouldAssembleDeferred rejectWithError:expectedError];
    }


    return shouldAssembleDeferred.promise;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
